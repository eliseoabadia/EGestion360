using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Mapster;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Adquisicion
{
    public class SolicitudSuficienciaAppService
        : AdquisicionCrudAppService<SolicitudSuficiencium, VwSolicitudSuficiencium, SolicitudSuficienciaDto, SolicitudSuficienciaResponse>,
            ISolicitudSuficienciaAppService
    {
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;

        public SolicitudSuficienciaAppService(
            GenericService<SolicitudSuficiencium, SolicitudSuficienciaDto, SolicitudSuficienciaResponse> service,
            GenericService<VwSolicitudSuficiencium, SolicitudSuficienciaDto, SolicitudSuficienciaResponse> serviceView,
            EGestionContext context,
            IUserContextService userContext)
            : base(
                service,
                serviceView,
                "PkidSolicitudSuficiencia",
                "Solicitud de suficiencia",
                (dto, id) => dto.PkidSolicitudSuficiencia = id)
        {
            _context = context;
            _userContext = userContext;
        }

        public override async Task<PagedResult<SolicitudSuficienciaResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            if (!request.AdditionalFilters.TryGetValue("FkidAnioSis", out var anioRaw) ||
                !int.TryParse(anioRaw?.ToString(), out var anioId) || anioId <= 0)
            {
                return Failure<SolicitudSuficienciaResponse>("Debe seleccionar un ejercicio presupuestal.", "YEAR_REQUIRED");
            }
            request.AdditionalFilters["FkidAnioSis"] = anioId;
            request.AdditionalFilters["FkidEmpresaSis"] = RequisicionWorkflowGuard.GetCurrentEmpresaId(_userContext);
            var result = await base.GetAllPaginadoAsync(request);
            await MarkLockedAsync(result.Items);
            return result;
        }

        public override async Task<PagedResult<SolicitudSuficienciaResponse>> GetAllAsync()
        {
            var result = await base.GetAllAsync();
            var empresaId = RequisicionWorkflowGuard.GetCurrentEmpresaId(_userContext);
            result.Items = result.Items?.Where(x => x.FkidEmpresaSis == empresaId).ToList() ?? new List<SolicitudSuficienciaResponse>();
            result.TotalCount = result.Items.Count;
            await MarkLockedAsync(result.Items);
            return result;
        }

        public override async Task<PagedResult<SolicitudSuficienciaResponse>> GetByIdAsync(int id)
        {
            var result = await base.GetByIdAsync(id);
            if (result.Success && result.Data?.FkidEmpresaSis != RequisicionWorkflowGuard.GetCurrentEmpresaId(_userContext))
                return Failure<SolicitudSuficienciaResponse>("Solicitud de suficiencia no encontrada.", "NOT_FOUND");
            if (result.Success && result.Data != null)
                await MarkLockedAsync(new[] { result.Data });
            return result;
        }

        public override async Task<PagedResult<SolicitudSuficienciaResponse>> CreateAsync(
            SolicitudSuficienciaResponse response,
            int usuarioActual)
        {
            var validation = await NormalizeAndValidateAsync(response, null);
            if (validation != null)
            {
                return validation;
            }

            var readiness = await ValidateRequisicionReadyForSolicitudAsync(response.FkidRequisicionOrco, null);
            if (readiness != null)
            {
                return readiness;
            }

            try
            {
                var spResult = await ExecuteMantenimientoAsync(1, null, response, usuarioActual);
                response.PkidSolicitudSuficiencia = spResult.GetId() ?? 0;
                var result = await GetByIdAsync(response.PkidSolicitudSuficiencia);
                result.Message = spResult.Mensaje;
                return result;
            }
            catch (Exception ex)
            {
                return Failure<SolicitudSuficienciaResponse>($"Error al crear solicitud de suficiencia: {ex.Message}", "ERROR");
            }
        }

        public override async Task<PagedResult<SolicitudSuficienciaResponse>> UpdateAsync(
            int id,
            SolicitudSuficienciaResponse response,
            int usuarioActual)
        {
            response.PkidSolicitudSuficiencia = id;
            var validation = await NormalizeAndValidateAsync(response, id);
            if (validation != null)
            {
                return validation;
            }

            try
            {
                var spResult = await ExecuteMantenimientoAsync(2, id, response, usuarioActual);
                var result = await GetByIdAsync(id);
                result.Message = spResult.Mensaje;
                return result;
            }
            catch (Exception ex)
            {
                return Failure<SolicitudSuficienciaResponse>($"Error al actualizar solicitud de suficiencia: {ex.Message}", "ERROR");
            }
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var empresaId = RequisicionWorkflowGuard.GetCurrentEmpresaId(_userContext);
            var solicitud = await _context.SolicitudSuficiencia.AsNoTracking().FirstOrDefaultAsync(x =>
                x.PkidSolicitudSuficiencia == id && x.FkidEmpresaSis == empresaId && x.Activo);
            if (solicitud == null)
                return Failure<bool>("Solicitud de suficiencia no encontrada.", "NOT_FOUND");
            if (await HasActiveAuthorizationAsync(id))
                return Failure<bool>("La solicitud tiene una autorizacion vigente. Cancela o elimina la autorizacion antes de regresar a esta etapa.", "LOCKED");

            try
            {
                var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    "[PRES].[SP_MantenimientoSolicitudSuficiencia]",
                    StoredProcedureExecutor.Param("@Action", 3),
                    StoredProcedureExecutor.Param("@PKIdSolicitudSuficiencia", id));

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
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Error al eliminar solicitud de suficiencia: {ex.Message}",
                    Code = "ERROR",
                    Data = false,
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<SolicitudSuficienciaResponse>> GenerarDesdeRequisicionAsync(
            SolicitudSuficienciaGenerarRequest request,
            int usuarioActual)
        {
            try
            {
                if (request == null || request.FkidRequisicionOrco <= 0)
                {
                    return Failure<SolicitudSuficienciaResponse>("Debe seleccionar una requisicion.");
                }

                if (request.PorcentajeAjuste < 0m)
                {
                    return Failure<SolicitudSuficienciaResponse>("El porcentaje de ajuste no puede ser negativo.");
                }

                var fechaSolicitud = request.FechaSolicitud == default
                    ? DateOnly.FromDateTime(DateTime.Today)
                    : request.FechaSolicitud;

                var fechaRequisicion = await _context.Requisicions.AsNoTracking()
                    .Where(x => x.PkidRequisicion == request.FkidRequisicionOrco && x.Activo)
                    .Select(x => (DateTime?)x.FechaRequisicion)
                    .FirstOrDefaultAsync();
                if (!fechaRequisicion.HasValue || fechaSolicitud > DateOnly.FromDateTime(fechaRequisicion.Value))
                    return Failure<SolicitudSuficienciaResponse>("La fecha de solicitud debe ser menor o igual a la fecha de requisicion.");

                var readiness = await ValidateRequisicionReadyForSolicitudAsync(request.FkidRequisicionOrco, null);
                if (readiness != null)
                {
                    return readiness;
                }

                var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    "[PRES].[SP_MantenimientoSolicitudSuficiencia]",
                    StoredProcedureExecutor.Param("@Action", 10),
                    StoredProcedureExecutor.Param("@FKIdRequisicion_ORCO", request.FkidRequisicionOrco),
                    StoredProcedureExecutor.Param("@FechaSolicitud", fechaSolicitud.ToDateTime(TimeOnly.MinValue)),
                    StoredProcedureExecutor.Param("@Justificacion", request.Justificacion),
                    StoredProcedureExecutor.Param("@GastoNoProgramable", request.GastoNoProgramable),
                    StoredProcedureExecutor.Param("@IdGastoNoProgramable", request.IdGastoNoProgramable),
                    StoredProcedureExecutor.Param("@IdCompromisoNomina", request.IdCompromisoNomina),
                    StoredProcedureExecutor.Param("@PorcentajeAjuste", request.PorcentajeAjuste),
                    StoredProcedureExecutor.Param("@IdUser", usuarioActual));

                var id = spResult.GetId() ?? 0;
                var result = await GetByIdAsync(id);
                result.Message = spResult.Mensaje;
                return result;
            }
            catch (Exception ex)
            {
                return Failure<SolicitudSuficienciaResponse>($"Error al generar solicitud de suficiencia: {ex.Message}", "ERROR");
            }
        }

        private Task<StoredProcedureResult> ExecuteMantenimientoAsync(
            int action,
            int? id,
            SolicitudSuficienciaResponse response,
            int usuarioActual)
        {
            var fechaSolicitud = response.FechaSolicitud == default
                ? DateOnly.FromDateTime(DateTime.Today)
                : response.FechaSolicitud;

            return StoredProcedureExecutor.ExecuteResultAsync(
                _context,
                "[PRES].[SP_MantenimientoSolicitudSuficiencia]",
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdSolicitudSuficiencia", id),
                StoredProcedureExecutor.Param("@FKIdRequisicion_ORCO", response.FkidRequisicionOrco),
                StoredProcedureExecutor.Param("@FechaSolicitud", fechaSolicitud.ToDateTime(TimeOnly.MinValue)),
                StoredProcedureExecutor.Param("@Justificacion", response.Justificacion),
                StoredProcedureExecutor.Param("@GastoNoProgramable", response.GastoNoProgramable),
                StoredProcedureExecutor.Param("@IdGastoNoProgramable", response.IdGastoNoProgramable),
                StoredProcedureExecutor.Param("@IdCompromisoNomina", response.IdCompromisoNomina),
                StoredProcedureExecutor.Param("@Estatus", response.Estatus),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual));
        }

        private async Task<PagedResult<SolicitudSuficienciaResponse>?> NormalizeAndValidateAsync(
            SolicitudSuficienciaResponse response,
            int? currentId)
        {
            if (response == null)
            {
                return Failure<SolicitudSuficienciaResponse>("La solicitud no contiene datos.");
            }

            if (response.FkidRequisicionOrco <= 0)
            {
                return Failure<SolicitudSuficienciaResponse>("Debe seleccionar una requisicion.");
            }

            var requisicion = await _context.Requisicions
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidRequisicion == response.FkidRequisicionOrco && x.Activo);

            if (requisicion == null)
            {
                return Failure<SolicitudSuficienciaResponse>("La requisicion no existe o esta inactiva.");
            }

            if (requisicion.FkidEmpresaSis != RequisicionWorkflowGuard.GetCurrentEmpresaId(_userContext))
                return Failure<SolicitudSuficienciaResponse>("La requisicion no pertenece a la empresa activa.", "NOT_FOUND");

            var fechaSolicitud = response.FechaSolicitud == default
                ? DateOnly.FromDateTime(DateTime.Today)
                : response.FechaSolicitud;
            if (fechaSolicitud > DateOnly.FromDateTime(requisicion.FechaRequisicion))
                return Failure<SolicitudSuficienciaResponse>("La fecha de solicitud debe ser menor o igual a la fecha de requisicion.");

            if (currentId.HasValue)
            {
                var actual = await _context.SolicitudSuficiencia.AsNoTracking().FirstOrDefaultAsync(x =>
                    x.PkidSolicitudSuficiencia == currentId.Value && x.FkidEmpresaSis == requisicion.FkidEmpresaSis && x.Activo);
                if (actual == null)
                    return Failure<SolicitudSuficienciaResponse>("Solicitud de suficiencia no encontrada.", "NOT_FOUND");
                if (await HasActiveAuthorizationAsync(actual.PkidSolicitudSuficiencia))
                    return Failure<SolicitudSuficienciaResponse>("La solicitud tiene una autorizacion vigente. Cancela o elimina la autorizacion antes de modificarla.", "LOCKED");
                response.Estatus = actual.Estatus;
            }

            if (!requisicion.FkidProgramaPres.HasValue || !requisicion.FkidFuenteFinanciamientoPres.HasValue ||
                !requisicion.FkidTipoGastoPres.HasValue || !requisicion.FkidDigitoIdentificadorPres.HasValue ||
                !requisicion.FkidDestinoGastoPres.HasValue)
            {
                return Failure<SolicitudSuficienciaResponse>(
                    "No se puede solicitar suficiencia: completa programa, fuente de financiamiento, TG, DI y DG.");
            }

            var duplicate = await _context.SolicitudSuficiencia
                .AsNoTracking()
                .AnyAsync(x =>
                    x.Activo &&
                    x.FkidRequisicionOrco == response.FkidRequisicionOrco &&
                    x.PkidSolicitudSuficiencia != (currentId ?? response.PkidSolicitudSuficiencia) &&
                    x.Estatus != 4);

            if (duplicate)
            {
                return Failure<SolicitudSuficienciaResponse>(
                    "Ya existe una solicitud de suficiencia activa para esta requisicion.",
                    "DUPLICATE");
            }

            response.FkidEmpresaSis = requisicion.FkidEmpresaSis;
            response.FechaSolicitud = response.FechaSolicitud == default
                ? DateOnly.FromDateTime(DateTime.Today)
                : response.FechaSolicitud;
            response.Justificacion ??= string.Empty;
            response.GastoNoProgramable = string.IsNullOrWhiteSpace(response.GastoNoProgramable)
                ? null
                : response.GastoNoProgramable.Trim();
            if (!currentId.HasValue)
                response.Estatus = 1;

            return null;
        }

        private async Task<PagedResult<SolicitudSuficienciaResponse>?> ValidateRequisicionReadyForSolicitudAsync(
            int requisicionId,
            int? currentSolicitudId)
        {
            var requisicion = await _context.Requisicions
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidRequisicion == requisicionId && x.Activo);

            if (requisicion == null)
            {
                return Failure<SolicitudSuficienciaResponse>("La requisicion no existe o esta inactiva.");
            }

            if (requisicion.FkidEmpresaSis != RequisicionWorkflowGuard.GetCurrentEmpresaId(_userContext))
                return Failure<SolicitudSuficienciaResponse>("La requisicion no pertenece a la empresa activa.", "NOT_FOUND");

            var duplicate = await _context.SolicitudSuficiencia
                .AsNoTracking()
                .AnyAsync(x =>
                    x.Activo &&
                    x.FkidRequisicionOrco == requisicionId &&
                    x.PkidSolicitudSuficiencia != (currentSolicitudId ?? 0) &&
                    x.Estatus != 4);

            if (duplicate)
            {
                return Failure<SolicitudSuficienciaResponse>(
                    "Ya existe una solicitud de suficiencia activa para esta requisicion.",
                    "DUPLICATE");
            }

            var detalles = await GetRequisicionDetallesAsync(requisicionId);
            if (!detalles.Any())
            {
                return Failure<SolicitudSuficienciaResponse>(
                    "La requisicion debe tener bienes o servicios antes de solicitar suficiencia.");
            }

            if (detalles.Any(x => x.PartidaId <= 0))
            {
                return Failure<SolicitudSuficienciaResponse>(
                    "Todos los bienes de la requisicion deben tener partida presupuestal.");
            }

            var cotizaciones = await GetCotizacionesCapturadasAsync(requisicionId);
            var cotizados = cotizaciones
                .Select(x => x.RequisicionDetalleId)
                .Distinct()
                .ToHashSet();

            var pendientes = detalles
                .Where(x => !cotizados.Contains(x.RequisicionDetalleId))
                .Select(x => x.BienDescripcion)
                .Take(3)
                .ToList();

            if (pendientes.Any())
            {
                var ejemplo = string.Join(", ", pendientes);
                return Failure<SolicitudSuficienciaResponse>(
                    $"No se puede generar suficiencia: faltan montos cotizados en {ejemplo}.");
            }

            if (requisicion.CompraDirecta != true)
            {
                var detallesIds = detalles.Select(x => x.RequisicionDetalleId).ToHashSet();
                var proveedoresCompletos = cotizaciones
                    .GroupBy(x => x.ProveedorId)
                    .Count(g => detallesIds.All(id => g.Any(x => x.RequisicionDetalleId == id)));
                if (proveedoresCompletos < 3)
                {
                    return Failure<SolicitudSuficienciaResponse>(
                        "La suficiencia requiere tres cotizaciones completas de proveedores distintos o compra directa autorizada.");
                }
            }

            return null;
        }

        private async Task<List<RequisicionDetalleBase>> GetRequisicionDetallesAsync(int requisicionId)
        {
            return await (
                from detalle in _context.RequisicionDetalles.AsNoTracking()
                join tipoBien in _context.TipoBiens.AsNoTracking()
                    on detalle.FkidTipoBienAlma equals tipoBien.PkidTipoBien
                where detalle.Activo &&
                      tipoBien.Activo &&
                      detalle.FkidRequisicionOrco == requisicionId
                orderby tipoBien.FkidPartidaConta, tipoBien.CodigoClave, tipoBien.Descripcion
                select new RequisicionDetalleBase
                {
                    RequisicionDetalleId = detalle.PkidRequisicionDetalle,
                    BienDescripcion = ((tipoBien.CodigoClave ?? string.Empty) + " - " + (tipoBien.Descripcion ?? string.Empty)).Trim(' ', '-'),
                    Cantidad = detalle.Cantidad,
                    PartidaId = tipoBien.FkidPartidaConta ?? 0
                })
                .ToListAsync();
        }

        private async Task<List<CotizacionDetalleBase>> GetCotizacionesCapturadasAsync(int requisicionId)
        {
            return await (
                from cotizacionDetalle in _context.CotizacionDetalles.AsNoTracking()
                join cotizacion in _context.Cotizacions.AsNoTracking()
                    on cotizacionDetalle.FkidCotizacionOrco equals cotizacion.PkidCotizacion
                where cotizacionDetalle.Activo &&
                      cotizacion.Activo &&
                      cotizacion.FkidRequisicionOrco == requisicionId &&
                      cotizacionDetalle.PrecioUnitario.HasValue &&
                      cotizacionDetalle.PrecioUnitario.Value > 0m
                select new CotizacionDetalleBase
                {
                    RequisicionDetalleId = cotizacionDetalle.FkidRequisicionDetalleOrco,
                    ProveedorId = cotizacion.FkidProveedorSis,
                    PrecioUnitario = cotizacionDetalle.PrecioUnitario.Value
                })
                .ToListAsync();
        }

        private static string BuildObservaciones(int quoteCount, decimal porcentajeAjuste)
        {
            return porcentajeAjuste == 0m
                ? $"Promedio de {quoteCount} cotizacion(es)."
                : $"Promedio de {quoteCount} cotizacion(es) mas {porcentajeAjuste:0.##}% de ajuste.";
        }

        private static void SetMonthAmount(SolicitudSuficienciaDetalle detalle, int month, decimal amount)
        {
            detalle.Enero = 0m;
            detalle.Febrero = 0m;
            detalle.Marzo = 0m;
            detalle.Abril = 0m;
            detalle.Mayo = 0m;
            detalle.Junio = 0m;
            detalle.Julio = 0m;
            detalle.Agosto = 0m;
            detalle.Septiembre = 0m;
            detalle.Octubre = 0m;
            detalle.Noviembre = 0m;
            detalle.Diciembre = 0m;

            switch (month)
            {
                case 1:
                    detalle.Enero = amount;
                    break;
                case 2:
                    detalle.Febrero = amount;
                    break;
                case 3:
                    detalle.Marzo = amount;
                    break;
                case 4:
                    detalle.Abril = amount;
                    break;
                case 5:
                    detalle.Mayo = amount;
                    break;
                case 6:
                    detalle.Junio = amount;
                    break;
                case 7:
                    detalle.Julio = amount;
                    break;
                case 8:
                    detalle.Agosto = amount;
                    break;
                case 9:
                    detalle.Septiembre = amount;
                    break;
                case 10:
                    detalle.Octubre = amount;
                    break;
                case 11:
                    detalle.Noviembre = amount;
                    break;
                case 12:
                    detalle.Diciembre = amount;
                    break;
            }
        }

        private static new PagedResult<T> Failure<T>(string message, string code = "VALIDATION") => new()
        {
            Success = false,
            Message = message,
            Code = code,
            TotalCount = 0
        };

        private sealed class RequisicionDetalleBase
        {
            public int RequisicionDetalleId { get; set; }
            public string BienDescripcion { get; set; } = string.Empty;
            public decimal Cantidad { get; set; }
            public int PartidaId { get; set; }
        }

        private sealed class CotizacionDetalleBase
        {
            public int RequisicionDetalleId { get; set; }
            public int ProveedorId { get; set; }
            public decimal PrecioUnitario { get; set; }
        }

        private Task<bool> HasActiveAuthorizationAsync(int solicitudId) =>
            _context.AutorizacionSuficiencia.AsNoTracking().AnyAsync(x =>
                x.FkidSolicitudSuficienciaPres == solicitudId && x.Activo && x.Estatus != 3);

        private async Task MarkLockedAsync(IEnumerable<SolicitudSuficienciaResponse>? items)
        {
            if (items == null) return;
            var list = items.ToList();
            var ids = list.Select(x => x.PkidSolicitudSuficiencia).ToList();
            if (ids.Count == 0) return;
            var lockedIds = await _context.AutorizacionSuficiencia.AsNoTracking()
                .Where(x => ids.Contains(x.FkidSolicitudSuficienciaPres) && x.Activo && x.Estatus != 3)
                .Select(x => x.FkidSolicitudSuficienciaPres)
                .Distinct()
                .ToListAsync();
            var locked = lockedIds.ToHashSet();
            foreach (var item in list)
                item.BloqueadaPorAutorizacion = locked.Contains(item.PkidSolicitudSuficiencia);
        }
    }
}
