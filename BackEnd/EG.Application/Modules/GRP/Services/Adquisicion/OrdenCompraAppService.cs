using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Common;
using EG.Common.Exceptions;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Adquisicion
{
    public class OrdenCompraAppService
        : AdquisicionCrudAppService<OrdenCompra, VwOrdenCompra, OrdenCompraDto, OrdenCompraResponse>,
            IOrdenCompraAppService
    {
        private const int EstatusInicial = 1;
        private const int EstatusPorSurtir = 2;

        private readonly EGestionContext _context;

        public OrdenCompraAppService(
            GenericService<OrdenCompra, OrdenCompraDto, OrdenCompraResponse> service,
            GenericService<VwOrdenCompra, OrdenCompraDto, OrdenCompraResponse> serviceView,
            EGestionContext context)
            : base(
                service,
                serviceView,
                "PkidOrdenCompra",
                "Orden de compra",
                (dto, id) => dto.PkidOrdenCompra = id)
        {
            _context = context;
        }

        public override async Task<PagedResult<OrdenCompraResponse>> GetAllAsync()
        {
            var result = await base.GetAllAsync();
            await ApplyChildCountsAsync(result.Items);
            return result;
        }

        public override async Task<PagedResult<OrdenCompraResponse>> GetByIdAsync(int id)
        {
            var result = await base.GetByIdAsync(id);
            if (result.Success)
            {
                await ApplyChildCountsAsync(result.Items);
                if (result.Data != null)
                {
                    await ApplyChildCountsAsync(new List<OrdenCompraResponse> { result.Data });
                }
            }

            return result;
        }

        public override async Task<PagedResult<OrdenCompraResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var result = await base.GetAllPaginadoAsync(request);
            await ApplyChildCountsAsync(result.Items);
            return result;
        }

        public override async Task<PagedResult<OrdenCompraResponse>> CreateAsync(
            OrdenCompraResponse response,
            int usuarioActual)
        {
            var validation = await NormalizeAndValidateAsync(response, currentId: null);
            if (validation != null)
            {
                return validation;
            }

            try
            {
                var spResult = await ExecuteMantenimientoAsync(1, null, response, usuarioActual);
                response.PkidOrdenCompra = spResult.GetId() ?? 0;

                var result = await GetByIdAsync(response.PkidOrdenCompra);
                result.Message = spResult.Mensaje;
                return result;
            }
            catch (Exception ex)
            {
                if (ex is UserVisibleException userVisibleException)
                {
                    LogUserVisibleMessage("crear", userVisibleException);
                    return Failure<OrdenCompraResponse>(userVisibleException.UserMessage, userVisibleException.Code);
                }

                LogException("crear", ex);
                return Failure<OrdenCompraResponse>(
                    UserFacingMessages.OperationFailed("crear orden de compra"),
                    "ERROR");
            }
        }

        public override async Task<PagedResult<OrdenCompraResponse>> UpdateAsync(
            int id,
            OrdenCompraResponse response,
            int usuarioActual)
        {
            var current = await GetActiveOrdenAsync(id);
            if (current == null)
            {
                return Failure<OrdenCompraResponse>($"Orden de compra con ID {id} no encontrada.", "NOT_FOUND");
            }

            if (IsLocked(current.FkidEstatusOrdenCompraOrco))
            {
                return Failure<OrdenCompraResponse>("La orden de compra ya fue autorizada. No se puede editar.", "LOCKED");
            }

            var validation = await NormalizeAndValidateAsync(response, currentId: id);
            if (validation != null)
            {
                return validation;
            }

            response.FkidEstatusOrdenCompraOrco = current.FkidEstatusOrdenCompraOrco;

            try
            {
                var spResult = await StoredProcedureExecutor.ExecuteConcurrencyCheckedAsync<OrdenCompra>(
                    _context,
                    id,
                    response.RowVersion,
                    "Orden de compra",
                    () => ExecuteMantenimientoAsync(2, id, response, usuarioActual));
                var result = await GetByIdAsync(id);
                result.Message = spResult.Mensaje;
                return result;
            }
            catch (Exception ex)
            {
                if (ex is UserVisibleException userVisibleException)
                {
                    LogUserVisibleMessage("actualizar", userVisibleException);
                    return Failure<OrdenCompraResponse>(userVisibleException.UserMessage, userVisibleException.Code);
                }

                LogException("actualizar", ex);
                return Failure<OrdenCompraResponse>(
                    UserFacingMessages.OperationFailed("actualizar orden de compra"),
                    "ERROR");
            }
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var current = await GetActiveOrdenAsync(id);
            if (current == null)
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Orden de compra con ID {id} no encontrada.",
                    Code = "NOT_FOUND",
                    Data = false,
                    TotalCount = 0
                };
            }

            if (IsLocked(current.FkidEstatusOrdenCompraOrco))
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = "La orden de compra ya fue autorizada. No se puede eliminar.",
                    Code = "LOCKED",
                    Data = false,
                    TotalCount = 0
                };
            }

            try
            {
                var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    "[ORCO].[SP_MantenimientoOrdenCompra]",
                    StoredProcedureExecutor.Param("@Action", 3),
                    StoredProcedureExecutor.Param("@PKIdOrdenCompra", id));

                return new PagedResult<bool>
                {
                    Success = true,
                    Message = spResult.Mensaje,
                    Code = "SUCCESS",
                    Data = true,
                    Items = new List<bool> { true },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                if (ex is UserVisibleException userVisibleException)
                {
                    LogUserVisibleMessage("eliminar", userVisibleException);
                    return new PagedResult<bool>
                    {
                        Success = false,
                        Message = userVisibleException.UserMessage,
                        Code = userVisibleException.Code,
                        Data = false,
                        TotalCount = 0
                    };
                }

                LogException("eliminar", ex);
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = UserFacingMessages.OperationFailed("eliminar orden de compra"),
                    Code = "ERROR",
                    Data = false,
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<OrdenCompraResponse>> AutorizarAsync(int id, int usuarioActual)
        {
            var result = await GetByIdAsync(id);
            if (!result.Success || result.Data == null)
            {
                return Failure<OrdenCompraResponse>($"Orden de compra con ID {id} no encontrada.", "NOT_FOUND");
            }

            var orden = result.Data;
            if (orden.FkidEstatusOrdenCompraOrco != EstatusInicial)
            {
                return Failure<OrdenCompraResponse>("Solo se pueden autorizar ordenes de compra en estatus INICIAL.", "LOCKED");
            }

            var readiness = await ValidateOrdenReadyToAuthorizeAsync(id);
            if (readiness != null)
            {
                return readiness;
            }

            orden.FkidEstatusOrdenCompraOrco = EstatusPorSurtir;

            try
            {
                var spResult = await ExecuteMantenimientoAsync(2, id, orden, usuarioActual);
                var refreshed = await GetByIdAsync(id);
                refreshed.Message = string.IsNullOrWhiteSpace(spResult.Mensaje)
                    ? "Orden de compra autorizada correctamente."
                    : "Orden de compra autorizada correctamente.";
                return refreshed;
            }
            catch (Exception ex)
            {
                if (ex is UserVisibleException userVisibleException)
                {
                    LogUserVisibleMessage("autorizar", userVisibleException);
                    return Failure<OrdenCompraResponse>(userVisibleException.UserMessage, userVisibleException.Code);
                }

                LogException("autorizar", ex);
                return Failure<OrdenCompraResponse>(
                    UserFacingMessages.OperationFailed("autorizar orden de compra"),
                    "ERROR");
            }
        }

        private async Task<PagedResult<OrdenCompraResponse>?> NormalizeAndValidateAsync(
            OrdenCompraResponse response,
            int? currentId)
        {
            _service.ApplyCurrentEmpresaIfPresent(response);

            if (response.FkidEmpresaSis <= 0)
            {
                return Failure<OrdenCompraResponse>("Debe existir una empresa seleccionada.");
            }

            if (response.FkidRequisicionOrco <= 0)
            {
                return Failure<OrdenCompraResponse>("Debe seleccionar una requisicion.");
            }

            if (response.FkidProveedorSis <= 0)
            {
                return Failure<OrdenCompraResponse>("Debe seleccionar un proveedor.");
            }

            if (string.IsNullOrWhiteSpace(response.Descripcion))
            {
                return Failure<OrdenCompraResponse>("La descripcion es requerida.");
            }

            if (response.FechaOrdenCompra == default)
            {
                response.FechaOrdenCompra = DateTime.Today;
            }

            if (!currentId.HasValue || response.FkidEstatusOrdenCompraOrco <= 0)
            {
                response.FkidEstatusOrdenCompraOrco = EstatusInicial;
            }

            response.NumeroOrdenCompra ??= string.Empty;
            response.Observaciones ??= string.Empty;
            response.MotivoCancelacion ??= string.Empty;
            response.FlDocumento ??= string.Empty;
            response.TipoCambio ??= 1m;

            var requisicion = await _context.Requisicions
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidRequisicion == response.FkidRequisicionOrco && x.Activo);

            if (requisicion == null)
            {
                return Failure<OrdenCompraResponse>("La requisicion seleccionada no existe o esta inactiva.");
            }

            if (requisicion.FkidEmpresaSis != response.FkidEmpresaSis)
            {
                return Failure<OrdenCompraResponse>("La requisicion seleccionada pertenece a otra empresa.");
            }

            response.CompraDirecta = requisicion.CompraDirecta == true;

            Cotizacion? cotizacion = null;
            if (response.FkidCotizacionOrco.HasValue && response.FkidCotizacionOrco.Value > 0)
            {
                cotizacion = await _context.Cotizacions
                    .AsNoTracking()
                    .FirstOrDefaultAsync(x =>
                        x.PkidCotizacion == response.FkidCotizacionOrco.Value &&
                        x.Activo);

                if (cotizacion == null)
                {
                    return Failure<OrdenCompraResponse>("La cotizacion seleccionada no existe o esta inactiva.");
                }

                if (cotizacion.FkidRequisicionOrco != requisicion.PkidRequisicion)
                {
                    return Failure<OrdenCompraResponse>("La cotizacion no pertenece a la requisicion de la orden.");
                }

                response.FkidProveedorSis = cotizacion.FkidProveedorSis;
            }
            else if (!response.CompraDirecta)
            {
                return Failure<OrdenCompraResponse>(
                    "Debe seleccionar la cotizacion adjudicada para generar la orden de compra.",
                    "COTIZACION_REQUIRED");
            }

            var proveedorExists = await _context.Proveedors
                .AsNoTracking()
                .AnyAsync(x => x.PkidProveedor == response.FkidProveedorSis && x.Activo);

            if (!proveedorExists)
            {
                return Failure<OrdenCompraResponse>("El proveedor seleccionado no existe o esta inactivo.");
            }

            if (!response.CompraDirecta)
            {
                if (!await HasThreeCompleteQuotationsAsync(requisicion.PkidRequisicion))
                {
                    return Failure<OrdenCompraResponse>(
                        "La requisicion requiere por lo menos tres cotizaciones completas de proveedores distintos antes de generar la orden.",
                        "THREE_QUOTES_REQUIRED");
                }

                if (!await IsCompleteQuotationAsync(
                        requisicion.PkidRequisicion,
                        response.FkidCotizacionOrco!.Value))
                {
                    return Failure<OrdenCompraResponse>(
                        "La cotizacion adjudicada no contiene precio para todos los bienes activos de la requisicion.",
                        "INCOMPLETE_QUOTE");
                }
            }

            if (!await HasAuthorizedSuficienciaAsync(response.FkidRequisicionOrco))
            {
                return Failure<OrdenCompraResponse>(
                    "La requisicion debe tener suficiencia autorizada antes de generar orden de compra.",
                    "SUFICIENCIA_REQUIRED");
            }

            if (!await HasAuthorizedCommitmentAsync(
                    response.FkidRequisicionOrco,
                    response.FkidProveedorSis))
            {
                return Failure<OrdenCompraResponse>(
                    "Debe existir un compromiso presupuestal vigente para la requisicion y el proveedor adjudicado.",
                    "COMMITMENT_REQUIRED");
            }

            if (currentId.HasValue)
            {
                var hasInconsistentDetails = await _context.OrdenCompraDetalles
                    .AsNoTracking()
                    .AnyAsync(x =>
                        x.FkidOrdenCompraOrco == currentId.Value &&
                        x.Activo &&
                        (!response.CompraDirecta &&
                         x.FkidCotizacionDetalleOrco.HasValue &&
                         !_context.CotizacionDetalles.Any(cd =>
                             cd.PkidCotizacionDetalle == x.FkidCotizacionDetalleOrco.Value &&
                             cd.FkidCotizacionOrco == response.FkidCotizacionOrco)));

                if (hasInconsistentDetails)
                {
                    return Failure<OrdenCompraResponse>(
                        "No se puede cambiar la cotizacion porque existen detalles vinculados a otra cotizacion.");
                }
            }

            if (response.FechaOrdenCompra.Date < requisicion.FechaRequisicion.Date)
            {
                return Failure<OrdenCompraResponse>("La fecha de la orden de compra debe ser igual o mayor a la fecha de requisicion.");
            }

            if (cotizacion?.FechaProveedorCotiza.HasValue == true &&
                response.FechaOrdenCompra.Date < cotizacion.FechaProveedorCotiza.Value.Date)
            {
                return Failure<OrdenCompraResponse>(
                    "La fecha de la orden no puede ser anterior a la fecha en que el proveedor cotizo.");
            }

            return null;
        }

        private async Task<bool> HasThreeCompleteQuotationsAsync(int requisicionId)
        {
            var detailIds = await _context.RequisicionDetalles
                .AsNoTracking()
                .Where(x => x.FkidRequisicionOrco == requisicionId && x.Activo)
                .Select(x => x.PkidRequisicionDetalle)
                .ToListAsync();

            if (detailIds.Count == 0)
            {
                return false;
            }

            var coverage = await (
                from cotizacion in _context.Cotizacions.AsNoTracking()
                join detalle in _context.CotizacionDetalles.AsNoTracking()
                    on cotizacion.PkidCotizacion equals detalle.FkidCotizacionOrco
                where cotizacion.FkidRequisicionOrco == requisicionId &&
                      cotizacion.Activo &&
                      detalle.Activo &&
                      detalle.PrecioUnitario > 0 &&
                      detailIds.Contains(detalle.FkidRequisicionDetalleOrco)
                group detalle by new
                {
                    cotizacion.PkidCotizacion,
                    cotizacion.FkidProveedorSis
                }
                into grouped
                select new
                {
                    grouped.Key.FkidProveedorSis,
                    DetailCount = grouped.Select(x => x.FkidRequisicionDetalleOrco).Distinct().Count()
                }).ToListAsync();

            return coverage
                .Where(x => x.DetailCount == detailIds.Count)
                .Select(x => x.FkidProveedorSis)
                .Distinct()
                .Count() >= 3;
        }

        private async Task<bool> IsCompleteQuotationAsync(int requisicionId, int cotizacionId)
        {
            var requisicionDetails = await _context.RequisicionDetalles
                .AsNoTracking()
                .CountAsync(x => x.FkidRequisicionOrco == requisicionId && x.Activo);

            if (requisicionDetails == 0)
            {
                return false;
            }

            var quotedDetails = await _context.CotizacionDetalles
                .AsNoTracking()
                .Where(x =>
                    x.FkidCotizacionOrco == cotizacionId &&
                    x.Activo &&
                    x.PrecioUnitario > 0 &&
                    x.FkidRequisicionDetalleOrcoNavigation.FkidRequisicionOrco == requisicionId &&
                    x.FkidRequisicionDetalleOrcoNavigation.Activo)
                .Select(x => x.FkidRequisicionDetalleOrco)
                .Distinct()
                .CountAsync();

            return quotedDetails == requisicionDetails;
        }

        private Task<bool> HasAuthorizedCommitmentAsync(int requisicionId, int proveedorId)
        {
            return (
                from solicitud in _context.SolicitudSuficiencia.AsNoTracking()
                join autorizacion in _context.AutorizacionSuficiencia.AsNoTracking()
                    on solicitud.PkidSolicitudSuficiencia equals autorizacion.FkidSolicitudSuficienciaPres
                join contrato in _context.Contratos1.AsNoTracking()
                    on autorizacion.PkidAutorizacionSuficiencia equals contrato.FkidAutorizacionSuficienciaPres
                where solicitud.Activo &&
                      autorizacion.Activo &&
                      contrato.Activo &&
                      solicitud.FkidRequisicionOrco == requisicionId &&
                      solicitud.Estatus == 3 &&
                      autorizacion.Estatus == 2 &&
                      contrato.Estatus >= 2 &&
                      contrato.FkidProveedorSis == proveedorId
                select contrato.PkidContrato)
                .AnyAsync();
        }

        private async Task<PagedResult<OrdenCompraResponse>?> ValidateOrdenReadyToAuthorizeAsync(int ordenCompraId)
        {
            var detalles = await _context.OrdenCompraDetalles
                .AsNoTracking()
                .Where(x => x.FkidOrdenCompraOrco == ordenCompraId && x.Activo)
                .Select(x => new
                {
                    x.CantidadSolicitada,
                    x.PrecioUnitario,
                    x.Iva,
                    x.TotalDetalle
                })
                .ToListAsync();

            if (!detalles.Any())
            {
                return Failure<OrdenCompraResponse>("Agrega al menos un detalle antes de autorizar la orden de compra.");
            }

            if (detalles.Any(x => x.CantidadSolicitada <= 0m))
            {
                return Failure<OrdenCompraResponse>("Todos los detalles de la orden deben tener cantidad mayor a cero.");
            }

            if (detalles.Any(x => x.PrecioUnitario <= 0m))
            {
                return Failure<OrdenCompraResponse>("Todos los detalles de la orden deben tener precio unitario mayor a cero.");
            }

            var totalDetalles = detalles.Sum(x =>
                x.TotalDetalle ?? (x.CantidadSolicitada * x.PrecioUnitario) + x.Iva);

            var partidas = await _context.OrdenCompraPartida
                .AsNoTracking()
                .Where(x => x.FkidOrdenCompraOrco == ordenCompraId && x.Activo)
                .Select(x => x.Importe)
                .ToListAsync();

            if (!partidas.Any())
            {
                return Failure<OrdenCompraResponse>("Agrega al menos una partida presupuestal antes de autorizar la orden de compra.");
            }

            if (partidas.Any(x => x <= 0m))
            {
                return Failure<OrdenCompraResponse>("Todas las partidas de la orden deben tener importe mayor a cero.");
            }

            var totalPartidas = partidas.Sum();
            if (Math.Abs(totalDetalles - totalPartidas) > 0.01m)
            {
                return Failure<OrdenCompraResponse>(
                    "El total de partidas debe coincidir con el total de detalles antes de autorizar.");
            }

            return null;
        }

        private Task<bool> HasAuthorizedSuficienciaAsync(int requisicionId)
        {
            return (
                from solicitud in _context.SolicitudSuficiencia.AsNoTracking()
                join autorizacion in _context.AutorizacionSuficiencia.AsNoTracking()
                    on solicitud.PkidSolicitudSuficiencia equals autorizacion.FkidSolicitudSuficienciaPres
                where solicitud.Activo &&
                      autorizacion.Activo &&
                      solicitud.FkidRequisicionOrco == requisicionId &&
                      solicitud.Estatus == 3 &&
                      autorizacion.Estatus == 2
                select autorizacion.PkidAutorizacionSuficiencia)
                .AnyAsync();
        }

        private Task<StoredProcedureResult> ExecuteMantenimientoAsync(
            int action,
            int? id,
            OrdenCompraResponse response,
            int usuarioActual)
        {
            return StoredProcedureExecutor.ExecuteResultAsync(
                _context,
                "[ORCO].[SP_MantenimientoOrdenCompra]",
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdOrdenCompra", id),
                StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", response.FkidEmpresaSis),
                StoredProcedureExecutor.Param("@FKIdRequisicion_ORCO", response.FkidRequisicionOrco),
                StoredProcedureExecutor.Param("@FKIdCotizacion_ORCO", response.FkidCotizacionOrco),
                StoredProcedureExecutor.Param("@FKIdProveedor_SIS", response.FkidProveedorSis),
                StoredProcedureExecutor.Param("@FKIdPoliza_CONTA", response.FkidPolizaConta),
                StoredProcedureExecutor.Param("@FKIdEstatusOrdenCompra_ORCO", response.FkidEstatusOrdenCompraOrco),
                StoredProcedureExecutor.Param("@NumeroOrdenCompra", response.NumeroOrdenCompra),
                StoredProcedureExecutor.Param("@Descripcion", response.Descripcion),
                StoredProcedureExecutor.Param("@FechaOrdenCompra", response.FechaOrdenCompra.Date),
                StoredProcedureExecutor.Param("@FechaRequerida", response.FechaRequerida?.Date),
                StoredProcedureExecutor.Param("@FechaEntrega", response.FechaEntrega?.Date),
                StoredProcedureExecutor.Param("@FechaVigencia", response.FechaVigencia?.Date),
                StoredProcedureExecutor.Param("@FechaCancelacion", response.FechaCancelacion?.Date),
                StoredProcedureExecutor.Param("@MotivoCancelacion", response.MotivoCancelacion),
                StoredProcedureExecutor.Param("@Subtotal", response.Subtotal),
                StoredProcedureExecutor.Param("@Iva", response.Iva),
                StoredProcedureExecutor.Param("@Total", response.Total),
                StoredProcedureExecutor.Param("@MonedaId", response.MonedaId),
                StoredProcedureExecutor.Param("@TipoCambio", response.TipoCambio),
                StoredProcedureExecutor.Param("@Observaciones", response.Observaciones),
                StoredProcedureExecutor.Param("@CompraDirecta", response.CompraDirecta),
                StoredProcedureExecutor.Param("@FL_Documento", response.FlDocumento),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual),
                StoredProcedureExecutor.Param("@IdAnio", response.FechaOrdenCompra.Year));
        }

        private async Task ApplyChildCountsAsync(IList<OrdenCompraResponse>? items)
        {
            if (items == null || items.Count == 0)
            {
                return;
            }

            var ids = items.Select(x => x.PkidOrdenCompra).Distinct().ToList();
            var detalles = await _context.OrdenCompraDetalles
                .Where(x => ids.Contains(x.FkidOrdenCompraOrco) && x.Activo)
                .GroupBy(x => x.FkidOrdenCompraOrco)
                .Select(x => new { Id = x.Key, Count = x.Count() })
                .ToDictionaryAsync(x => x.Id, x => x.Count);

            var partidas = await _context.OrdenCompraPartida
                .Where(x => ids.Contains(x.FkidOrdenCompraOrco) && x.Activo)
                .GroupBy(x => x.FkidOrdenCompraOrco)
                .Select(x => new { Id = x.Key, Count = x.Count() })
                .ToDictionaryAsync(x => x.Id, x => x.Count);

            foreach (var item in items)
            {
                item.TotalDetalles = detalles.TryGetValue(item.PkidOrdenCompra, out var totalDetalles) ? totalDetalles : 0;
                item.TotalPartidas = partidas.TryGetValue(item.PkidOrdenCompra, out var totalPartidas) ? totalPartidas : 0;
            }
        }

        private Task<OrdenCompra?> GetActiveOrdenAsync(int id)
        {
            return _context.OrdenCompras
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidOrdenCompra == id && x.Activo);
        }

        private static bool IsLocked(int estatusId) => estatusId > EstatusInicial;

        private static new PagedResult<T> Failure<T>(string message, string code = "ERROR")
            where T : class
        {
            return new PagedResult<T>
            {
                Success = false,
                Message = message,
                Code = code,
                TotalCount = 0
            };
        }
    }
}
