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
            var validation = await NormalizeAndValidateAsync(response, isCreate: true);
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

            var validation = await NormalizeAndValidateAsync(response, isCreate: false);
            if (validation != null)
            {
                return validation;
            }

            response.FkidEstatusOrdenCompraOrco = current.FkidEstatusOrdenCompraOrco;

            try
            {
                var spResult = await ExecuteMantenimientoAsync(2, id, response, usuarioActual);
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
            bool isCreate)
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

            if (isCreate || response.FkidEstatusOrdenCompraOrco <= 0)
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

            var proveedorExists = await _context.Proveedors
                .AsNoTracking()
                .AnyAsync(x => x.PkidProveedor == response.FkidProveedorSis && x.Activo);

            if (!proveedorExists)
            {
                return Failure<OrdenCompraResponse>("El proveedor seleccionado no existe o esta inactivo.");
            }

            if (!await HasAuthorizedSuficienciaAsync(response.FkidRequisicionOrco))
            {
                return Failure<OrdenCompraResponse>(
                    "La requisicion debe tener suficiencia autorizada antes de generar orden de compra.",
                    "SUFICIENCIA_REQUIRED");
            }

            if (response.FechaOrdenCompra.Date < requisicion.FechaRequisicion.Date)
            {
                return Failure<OrdenCompraResponse>("La fecha de la orden de compra debe ser igual o mayor a la fecha de requisicion.");
            }

            return null;
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
