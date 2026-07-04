using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
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

        public SolicitudSuficienciaAppService(
            GenericService<SolicitudSuficiencium, SolicitudSuficienciaDto, SolicitudSuficienciaResponse> service,
            GenericService<VwSolicitudSuficiencium, SolicitudSuficienciaDto, SolicitudSuficienciaResponse> serviceView,
            EGestionContext context)
            : base(
                service,
                serviceView,
                "PkidSolicitudSuficiencia",
                "Solicitud de suficiencia",
                (dto, id) => dto.PkidSolicitudSuficiencia = id)
        {
            _context = context;
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
            response.Estatus = response.Estatus <= 0 ? 1 : response.Estatus;

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
            public decimal PrecioUnitario { get; set; }
        }
    }
}
