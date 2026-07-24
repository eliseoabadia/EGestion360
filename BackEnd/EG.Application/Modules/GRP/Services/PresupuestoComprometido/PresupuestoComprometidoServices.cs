using EG.Application.Services.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.PresupuestoComprometido;
using EG.Domain.DTOs.Responses.PresupuestoComprometido;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System.Data;

namespace EG.Application.Services.PresupuestoComprometido
{
    public class AutorizacionSuficienciaAppService(
        GenericService<AutorizacionSuficiencium, AutorizacionSuficienciaDto, AutorizacionSuficienciaResponse> service,
        GenericService<VwAutorizacionSuficiencium, AutorizacionSuficienciaDto, AutorizacionSuficienciaResponse> serviceView,
        EGestionContext context)
        : StoredProcedureCrudAppService<AutorizacionSuficiencium, VwAutorizacionSuficiencium, AutorizacionSuficienciaDto, AutorizacionSuficienciaResponse>(
            service,
            serviceView,
            context,
            "PkidAutorizacionSuficiencia",
            "Autorizacion de suficiencia",
            (dto, id) => dto.PkidAutorizacionSuficiencia = id,
            "PRES.SP_MantenimientoAutorizacionSuficiencia",
            response => response.PkidAutorizacionSuficiencia,
            BuildParameters)
    {
        private readonly EGestionContext _context = context;

        public override async Task<PagedResult<AutorizacionSuficienciaResponse>> CreateAsync(
            AutorizacionSuficienciaResponse response,
            int usuarioActual)
        {
            var validation = await NormalizeAndValidateAsync(response, null);
            if (validation != null)
                return validation;

            var strategy = _context.Database.CreateExecutionStrategy();
            try
            {
                return await strategy.ExecuteAsync(async () =>
                {
                    await using var transaction = await _context.Database.BeginTransactionAsync(
                        IsolationLevel.Serializable);
                    try
                    {
                        var budgetValidation = await ValidateBudgetAvailabilityAsync(
                            response.FkidSolicitudSuficienciaPres);
                        if (budgetValidation != null)
                        {
                            await transaction.RollbackAsync();
                            return budgetValidation;
                        }

                        var result = await base.CreateAsync(response, usuarioActual);
                        if (!result.Success)
                        {
                            await transaction.RollbackAsync();
                            return result;
                        }

                        var authorizationId = result.Data?.PkidAutorizacionSuficiencia
                            ?? result.Items?.FirstOrDefault()?.PkidAutorizacionSuficiencia
                            ?? 0;
                        if (authorizationId <= 0)
                        {
                            throw new InvalidOperationException(
                                "No se recupero el identificador de la autorizacion.");
                        }

                        var requestedDetails = await _context.SolicitudSuficienciaDetalles
                            .AsNoTracking()
                            .Where(x =>
                                x.FkidSolicitudSuficienciaPres == response.FkidSolicitudSuficienciaPres &&
                                x.Activo)
                            .ToListAsync();

                        foreach (var detail in requestedDetails)
                        {
                            _context.AutorizacionSuficienciaDetalles.Add(
                                new AutorizacionSuficienciaDetalle
                                {
                                    FkidEmpresaSis = response.FkidEmpresaSis,
                                    FkidAutorizacionSuficienciaPres = authorizationId,
                                    FkidSolicitudSuficienciaDetallePres =
                                        detail.PkidSolicitudSuficienciaDetalle,
                                    FkidPartidaConta = detail.FkidPartidaConta,
                                    Enero = detail.Enero,
                                    Febrero = detail.Febrero,
                                    Marzo = detail.Marzo,
                                    Abril = detail.Abril,
                                    Mayo = detail.Mayo,
                                    Junio = detail.Junio,
                                    Julio = detail.Julio,
                                    Agosto = detail.Agosto,
                                    Septiembre = detail.Septiembre,
                                    Octubre = detail.Octubre,
                                    Noviembre = detail.Noviembre,
                                    Diciembre = detail.Diciembre,
                                    Observaciones = detail.Observaciones ?? string.Empty,
                                    Activo = true,
                                    FechaCreacion = DateTime.UtcNow,
                                    UsuarioCreacion = usuarioActual
                                });
                        }

                        await _context.SaveChangesAsync();
                        await transaction.CommitAsync();
                        result.Message =
                            "Suficiencia autorizada y reservada en una sola transaccion.";
                        return result;
                    }
                    catch
                    {
                        await transaction.RollbackAsync();
                        throw;
                    }
                });
            }
            catch (Exception ex)
            {
                LogException("reservar suficiencia", ex);
                return Failure<AutorizacionSuficienciaResponse>(
                    "No fue posible reservar la suficiencia. Intenta nuevamente; si el problema continúa, consulta el registro técnico.",
                    "BUDGET_ERROR");
            }
        }

        public override async Task<PagedResult<AutorizacionSuficienciaResponse>> UpdateAsync(
            int id,
            AutorizacionSuficienciaResponse response,
            int usuarioActual)
        {
            var validation = await NormalizeAndValidateAsync(response, id);
            return validation ?? await base.UpdateAsync(id, response, usuarioActual);
        }

        private async Task<PagedResult<AutorizacionSuficienciaResponse>?> NormalizeAndValidateAsync(
            AutorizacionSuficienciaResponse response,
            int? currentId)
        {
            if (response == null)
            {
                return Failure<AutorizacionSuficienciaResponse>("La autorizacion no contiene datos.");
            }

            if (response.FkidSolicitudSuficienciaPres <= 0)
            {
                return Failure<AutorizacionSuficienciaResponse>("Debe seleccionar una solicitud de suficiencia.");
            }

            var solicitud = await _context.SolicitudSuficiencia
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidSolicitudSuficiencia == response.FkidSolicitudSuficienciaPres && x.Activo);

            if (solicitud == null)
            {
                return Failure<AutorizacionSuficienciaResponse>("La solicitud de suficiencia no existe o esta inactiva.");
            }

            if (solicitud.Estatus == 4)
            {
                return Failure<AutorizacionSuficienciaResponse>("No se puede autorizar una solicitud rechazada.");
            }

            var duplicate = await _context.AutorizacionSuficiencia
                .AsNoTracking()
                .AnyAsync(x =>
                    x.Activo &&
                    x.FkidSolicitudSuficienciaPres == response.FkidSolicitudSuficienciaPres &&
                    x.PkidAutorizacionSuficiencia != (currentId ?? response.PkidAutorizacionSuficiencia) &&
                    x.Estatus != 3);

            if (duplicate)
            {
                return Failure<AutorizacionSuficienciaResponse>(
                    "Ya existe una autorizacion activa para esta solicitud de suficiencia.",
                    "DUPLICATE");
            }

            var hasDetails = await _context.SolicitudSuficienciaDetalles
                .AsNoTracking()
                .AnyAsync(x => x.FkidSolicitudSuficienciaPres == solicitud.PkidSolicitudSuficiencia && x.Activo);

            if (!hasDetails)
            {
                return Failure<AutorizacionSuficienciaResponse>("La solicitud no tiene detalle para autorizar.");
            }

            if (response.AutorizadoPorNom <= 0)
            {
                return Failure<AutorizacionSuficienciaResponse>("Debe indicar la persona autorizadora.");
            }

            var personaExists = await _context.Personas
                .AsNoTracking()
                .AnyAsync(x => x.PkidPersona == response.AutorizadoPorNom && x.Activo);

            if (!personaExists)
            {
                return Failure<AutorizacionSuficienciaResponse>("La persona autorizadora no existe o esta inactiva.");
            }

            response.FkidEmpresaSis = solicitud.FkidEmpresaSis;
            response.FechaSolicitud = solicitud.FechaSolicitud;
            response.FechaAutorizacion = response.FechaAutorizacion == default
                ? DateOnly.FromDateTime(DateTime.Today)
                : response.FechaAutorizacion;
            response.Justificacion = string.IsNullOrWhiteSpace(response.Justificacion)
                ? solicitud.Justificacion ?? string.Empty
                : response.Justificacion.Trim();
            response.GastoNoProgramable = string.IsNullOrWhiteSpace(response.GastoNoProgramable)
                ? solicitud.GastoNoProgramable
                : response.GastoNoProgramable.Trim();
            response.IdGastoNoProgramable ??= solicitud.IdGastoNoProgramable;
            response.IdCompromisoNomina ??= solicitud.IdCompromisoNomina;
            response.Observaciones ??= string.Empty;
            response.Estatus = response.Estatus <= 0 ? 2 : response.Estatus;
            response.Activo = true;

            return null;
        }

        private async Task<PagedResult<AutorizacionSuficienciaResponse>?> ValidateBudgetAvailabilityAsync(int solicitudId)
        {
            var solicitud = await _context.SolicitudSuficiencia.AsNoTracking()
                .FirstAsync(x => x.PkidSolicitudSuficiencia == solicitudId && x.Activo);
            var requisicion = await _context.Requisicions.AsNoTracking()
                .FirstAsync(x => x.PkidRequisicion == solicitud.FkidRequisicionOrco && x.Activo);

            if (!requisicion.FkidAnioSis.HasValue || !requisicion.FkidProgramaPres.HasValue ||
                !requisicion.FkidFuenteFinanciamientoPres.HasValue || !requisicion.FkidTipoGastoPres.HasValue ||
                !requisicion.FkidDigitoIdentificadorPres.HasValue || !requisicion.FkidDestinoGastoPres.HasValue)
            {
                return Failure<AutorizacionSuficienciaResponse>(
                    "La requisicion no tiene clasificacion completa: ejercicio, programa, FF, TG, DI y DG.");
            }

            var requested = await _context.SolicitudSuficienciaDetalles.AsNoTracking()
                .Where(x => x.FkidSolicitudSuficienciaPres == solicitudId && x.Activo)
                .GroupBy(x => x.FkidPartidaConta)
                .Select(g => new { PartidaId = g.Key, Total = g.Sum(x => x.Total ?? 0m) })
                .ToListAsync();

            foreach (var item in requested)
            {
                var available = await _context.VwEgresoDisponibles.AsNoTracking()
                    .Where(x => x.FkidAnioSis == requisicion.FkidAnioSis &&
                                x.FkidProgramaPres == requisicion.FkidProgramaPres &&
                                x.FkidPartidaConta == item.PartidaId &&
                                x.FkidAreaSis == requisicion.FkidAreaSis &&
                                x.FkidFuenteFinanciamientoPres == requisicion.FkidFuenteFinanciamientoPres &&
                                x.FkidTipoGastoPres == requisicion.FkidTipoGastoPres &&
                                x.FkidDigitoIdentificadorPres == requisicion.FkidDigitoIdentificadorPres &&
                                x.FkidDestinoGastoPres == requisicion.FkidDestinoGastoPres)
                    .SumAsync(x => x.Total ?? 0m);

                var reservations = await (
                    from detail in _context.AutorizacionSuficienciaDetalles.AsNoTracking()
                    join authorization in _context.AutorizacionSuficiencia.AsNoTracking()
                        on detail.FkidAutorizacionSuficienciaPres equals authorization.PkidAutorizacionSuficiencia
                    join otherRequest in _context.SolicitudSuficiencia.AsNoTracking()
                        on authorization.FkidSolicitudSuficienciaPres equals otherRequest.PkidSolicitudSuficiencia
                    join otherRequisition in _context.Requisicions.AsNoTracking()
                        on otherRequest.FkidRequisicionOrco equals otherRequisition.PkidRequisicion
                    where detail.Activo && authorization.Activo && authorization.Estatus != 3 &&
                          otherRequest.Activo && otherRequisition.Activo &&
                          detail.FkidPartidaConta == item.PartidaId &&
                          otherRequisition.FkidAnioSis == requisicion.FkidAnioSis &&
                          otherRequisition.FkidProgramaPres == requisicion.FkidProgramaPres &&
                          otherRequisition.FkidAreaSis == requisicion.FkidAreaSis &&
                          otherRequisition.FkidFuenteFinanciamientoPres == requisicion.FkidFuenteFinanciamientoPres &&
                          otherRequisition.FkidTipoGastoPres == requisicion.FkidTipoGastoPres &&
                          otherRequisition.FkidDigitoIdentificadorPres == requisicion.FkidDigitoIdentificadorPres &&
                          otherRequisition.FkidDestinoGastoPres == requisicion.FkidDestinoGastoPres &&
                          !_context.Contratos1.Any(c => c.Activo && c.FkidAutorizacionSuficienciaPres == authorization.PkidAutorizacionSuficiencia)
                    select detail.Total ?? 0m).SumAsync();

                var netAvailable = available - reservations;
                if (item.Total > netAvailable)
                {
                    return Failure<AutorizacionSuficienciaResponse>(
                        $"Saldo insuficiente para la partida {item.PartidaId}. Solicitado: {item.Total:N2}; disponible: {netAvailable:N2}.",
                        "INSUFFICIENT_BUDGET");
                }
            }

            return null;
        }

        private static SqlParameter[] BuildParameters(int action, int? id, AutorizacionSuficienciaResponse? response, int? usuarioActual)
        {
            return new[]
            {
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdAutorizacionSuficiencia", id ?? response?.PkidAutorizacionSuficiencia),
                StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", response?.FkidEmpresaSis),
                StoredProcedureExecutor.Param("@FKIdSolicitudSuficiencia_PRES", response?.FkidSolicitudSuficienciaPres),
                StoredProcedureExecutor.Param("@FechaAutorizacion", ToDateTime(response?.FechaAutorizacion)),
                StoredProcedureExecutor.Param("@Justificacion", response?.Justificacion),
                StoredProcedureExecutor.Param("@GastoNoProgramable", response?.GastoNoProgramable),
                StoredProcedureExecutor.Param("@IdGastoNoProgramable", response?.IdGastoNoProgramable),
                StoredProcedureExecutor.Param("@IdCompromisoNomina", response?.IdCompromisoNomina),
                StoredProcedureExecutor.Param("@AutorizadoPor_NOM", response?.AutorizadoPorNom),
                StoredProcedureExecutor.Param("@Observaciones", response?.Observaciones),
                StoredProcedureExecutor.Param("@Estatus", response?.Estatus),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual)
            };
        }

        private static DateTime? ToDateTime(DateOnly? value)
        {
            return value.HasValue && value.Value != default
                ? value.Value.ToDateTime(TimeOnly.MinValue)
                : null;
        }
    }

    public class AutorizacionSuficienciaDetalleAppService(
        GenericService<AutorizacionSuficienciaDetalle, AutorizacionSuficienciaDetalleDto, AutorizacionSuficienciaDetalleResponse> service,
        GenericService<VwAutorizacionSuficienciaDetalle, AutorizacionSuficienciaDetalleDto, AutorizacionSuficienciaDetalleResponse> serviceView,
        EGestionContext context)
        : StoredProcedureCrudAppService<AutorizacionSuficienciaDetalle, VwAutorizacionSuficienciaDetalle, AutorizacionSuficienciaDetalleDto, AutorizacionSuficienciaDetalleResponse>(
            service,
            serviceView,
            context,
            "PkidAutorizacionSuficienciaDetalle",
            "Detalle de autorizacion de suficiencia",
            (dto, id) => dto.PkidAutorizacionSuficienciaDetalle = id,
            "PRES.SP_MantenimientoAutorizacionSuficiencia",
            response => response.PkidAutorizacionSuficienciaDetalle,
            BuildParameters)
    {
        private readonly EGestionContext _context = context;

        protected override int CreateAction => 5;
        protected override int UpdateAction => 6;
        protected override int DeleteAction => 7;

        public override async Task<PagedResult<AutorizacionSuficienciaDetalleResponse>> CreateAsync(
            AutorizacionSuficienciaDetalleResponse response,
            int usuarioActual)
        {
            var validation = await NormalizeAndValidateAsync(response, null);
            return validation ?? await base.CreateAsync(response, usuarioActual);
        }

        public override async Task<PagedResult<AutorizacionSuficienciaDetalleResponse>> UpdateAsync(
            int id,
            AutorizacionSuficienciaDetalleResponse response,
            int usuarioActual)
        {
            var validation = await NormalizeAndValidateAsync(response, id);
            return validation ?? await base.UpdateAsync(id, response, usuarioActual);
        }

        private async Task<PagedResult<AutorizacionSuficienciaDetalleResponse>?> NormalizeAndValidateAsync(
            AutorizacionSuficienciaDetalleResponse response,
            int? currentId)
        {
            if (response == null)
            {
                return Failure<AutorizacionSuficienciaDetalleResponse>("El detalle de autorizacion no contiene datos.");
            }

            if (response.FkidAutorizacionSuficienciaPres <= 0)
            {
                return Failure<AutorizacionSuficienciaDetalleResponse>("Debe existir una autorizacion de suficiencia.");
            }

            if (response.FkidSolicitudSuficienciaDetallePres <= 0)
            {
                return Failure<AutorizacionSuficienciaDetalleResponse>("Debe seleccionar un detalle de solicitud de suficiencia.");
            }

            var autorizacion = await _context.AutorizacionSuficiencia
                .AsNoTracking()
                .FirstOrDefaultAsync(x =>
                    x.PkidAutorizacionSuficiencia == response.FkidAutorizacionSuficienciaPres &&
                    x.Activo);

            if (autorizacion == null)
            {
                return Failure<AutorizacionSuficienciaDetalleResponse>("La autorizacion de suficiencia no existe o esta inactiva.");
            }

            if (autorizacion.Estatus == 3)
            {
                return Failure<AutorizacionSuficienciaDetalleResponse>("No se pueden agregar detalles a una autorizacion cancelada.");
            }

            var solicitudDetalle = await _context.SolicitudSuficienciaDetalles
                .AsNoTracking()
                .FirstOrDefaultAsync(x =>
                    x.PkidSolicitudSuficienciaDetalle == response.FkidSolicitudSuficienciaDetallePres &&
                    x.Activo);

            if (solicitudDetalle == null)
            {
                return Failure<AutorizacionSuficienciaDetalleResponse>("El detalle de solicitud no existe o esta inactivo.");
            }

            if (solicitudDetalle.FkidSolicitudSuficienciaPres != autorizacion.FkidSolicitudSuficienciaPres)
            {
                return Failure<AutorizacionSuficienciaDetalleResponse>("El detalle no pertenece a la solicitud autorizada.");
            }

            var duplicate = await _context.AutorizacionSuficienciaDetalles
                .AsNoTracking()
                .AnyAsync(x =>
                    x.Activo &&
                    x.FkidAutorizacionSuficienciaPres == response.FkidAutorizacionSuficienciaPres &&
                    x.FkidSolicitudSuficienciaDetallePres == response.FkidSolicitudSuficienciaDetallePres &&
                    x.PkidAutorizacionSuficienciaDetalle != (currentId ?? response.PkidAutorizacionSuficienciaDetalle));

            if (duplicate)
            {
                return Failure<AutorizacionSuficienciaDetalleResponse>(
                    "El detalle seleccionado ya esta agregado en esta autorizacion.",
                    "DUPLICATE");
            }

            response.FkidEmpresaSis = autorizacion.FkidEmpresaSis;
            response.FkidSolicitudSuficienciaPres = autorizacion.FkidSolicitudSuficienciaPres;
            response.FkidPartidaConta = solicitudDetalle.FkidPartidaConta;
            response.Observaciones ??= solicitudDetalle.Observaciones ?? string.Empty;
            response.Enero ??= solicitudDetalle.Enero;
            response.Febrero ??= solicitudDetalle.Febrero;
            response.Marzo ??= solicitudDetalle.Marzo;
            response.Abril ??= solicitudDetalle.Abril;
            response.Mayo ??= solicitudDetalle.Mayo;
            response.Junio ??= solicitudDetalle.Junio;
            response.Julio ??= solicitudDetalle.Julio;
            response.Agosto ??= solicitudDetalle.Agosto;
            response.Septiembre ??= solicitudDetalle.Septiembre;
            response.Octubre ??= solicitudDetalle.Octubre;
            response.Noviembre ??= solicitudDetalle.Noviembre;
            response.Diciembre ??= solicitudDetalle.Diciembre;
            response.Activo = true;

            if (MonthlyTotal(response) <= 0m)
            {
                return Failure<AutorizacionSuficienciaDetalleResponse>("El detalle autorizado debe tener importe mayor a cero.");
            }

            return null;
        }

        private static decimal MonthlyTotal(AutorizacionSuficienciaDetalleResponse response)
        {
            return response.Enero.GetValueOrDefault() +
                   response.Febrero.GetValueOrDefault() +
                   response.Marzo.GetValueOrDefault() +
                   response.Abril.GetValueOrDefault() +
                   response.Mayo.GetValueOrDefault() +
                   response.Junio.GetValueOrDefault() +
                   response.Julio.GetValueOrDefault() +
                   response.Agosto.GetValueOrDefault() +
                   response.Septiembre.GetValueOrDefault() +
                   response.Octubre.GetValueOrDefault() +
                   response.Noviembre.GetValueOrDefault() +
                   response.Diciembre.GetValueOrDefault();
        }

        private static SqlParameter[] BuildParameters(int action, int? id, AutorizacionSuficienciaDetalleResponse? response, int? usuarioActual)
        {
            return new[]
            {
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdAutorizacionSuficiencia", response?.FkidAutorizacionSuficienciaPres),
                StoredProcedureExecutor.Param("@PKIdAutorizacionSuficienciaDetalle", id ?? response?.PkidAutorizacionSuficienciaDetalle),
                StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", response?.FkidEmpresaSis),
                StoredProcedureExecutor.Param("@FKIdSolicitudSuficienciaDetalle_PRES", response?.FkidSolicitudSuficienciaDetallePres),
                StoredProcedureExecutor.Param("@FKIdPartida_CONTA", response?.FkidPartidaConta),
                StoredProcedureExecutor.Param("@Enero", response?.Enero),
                StoredProcedureExecutor.Param("@Febrero", response?.Febrero),
                StoredProcedureExecutor.Param("@Marzo", response?.Marzo),
                StoredProcedureExecutor.Param("@Abril", response?.Abril),
                StoredProcedureExecutor.Param("@Mayo", response?.Mayo),
                StoredProcedureExecutor.Param("@Junio", response?.Junio),
                StoredProcedureExecutor.Param("@Julio", response?.Julio),
                StoredProcedureExecutor.Param("@Agosto", response?.Agosto),
                StoredProcedureExecutor.Param("@Septiembre", response?.Septiembre),
                StoredProcedureExecutor.Param("@Octubre", response?.Octubre),
                StoredProcedureExecutor.Param("@Noviembre", response?.Noviembre),
                StoredProcedureExecutor.Param("@Diciembre", response?.Diciembre),
                StoredProcedureExecutor.Param("@Observaciones", response?.Observaciones),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual)
            };
        }
    }
}
