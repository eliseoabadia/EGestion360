using System.Data;
using EG.Application.Interfaces.PresupuestoModificado;
using EG.Application.Services.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.PresupuestoModificado;
using EG.Domain.DTOs.Responses.PresupuestoModificado;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.PresupuestoModificado
{
    public class EgreAdecuacionAppService(
        GenericService<EgreAdecuacion, EgreAdecuacionDto, EgreAdecuacionResponse> service,
        GenericService<VwEgresoAdecuacion, EgreAdecuacionDto, EgreAdecuacionResponse> serviceView,
        EGestionContext context)
        : StoredProcedureCrudAppService<EgreAdecuacion, VwEgresoAdecuacion, EgreAdecuacionDto, EgreAdecuacionResponse>(
            service,
            serviceView,
            context,
            "PkidEgreAdecuacion",
            "Adecuacion",
            (dto, id) => dto.PkidEgreAdecuacion = id,
            "PRES.sp_MantenimientoEgresoAdecuacion",
            response => response.PkidEgreAdecuacion,
            BuildParameters),
            IPresupuestoModificadoAppService
    {
        private readonly EGestionContext _context = context;

        public override async Task<PagedResult<EgreAdecuacionResponse>> UpdateAsync(int id, EgreAdecuacionResponse response, int usuarioActual)
        {
            if (await IsAuthorizedAsync(id))
                return Failure<EgreAdecuacionResponse>("La adecuacion ya fue autorizada y no puede modificarse.");

            return await base.UpdateAsync(id, response, usuarioActual);
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            if (await IsAuthorizedAsync(id))
                return new PagedResult<bool> { Success = false, Message = "La adecuacion ya fue autorizada y no puede eliminarse.", Code = "VALIDATION" };

            return await base.DeleteAsync(id);
        }

        public async Task<PagedResult<EgreAdecuacionResponse>> EnviarSolicitudAsync(int id, int usuarioActual)
        {
            var entity = await _context.EgreAdecuacions.FirstOrDefaultAsync(x => x.PkidEgreAdecuacion == id && x.Activo);
            if (entity == null) return Failure<EgreAdecuacionResponse>("No se encontro la adecuacion.", "NOT_FOUND");
            if (entity.Autorizado == true) return Failure<EgreAdecuacionResponse>("La adecuacion ya fue autorizada.");
            if (entity.FkidAccionAdecuacionMasterPres == 2) return Failure<EgreAdecuacionResponse>("La solicitud de autorizacion ya fue enviada.");

            var balanceValidation = await ValidateBalancedPolizaAsync(entity);
            if (balanceValidation != null) return balanceValidation;

            entity.FkidAccionAdecuacionMasterPres = 2;
            entity.FechaSolicitud = DateTime.Now;
            entity.UsuarioModificacion = usuarioActual;
            entity.FechaModificacion = DateTime.Now;
            await _context.SaveChangesAsync();
            return await RefreshedAsync(id, "Se proceso la solicitud para autorizacion.");
        }

        public async Task<PagedResult<EgreAdecuacionResponse>> AutorizarAsync(int id, int usuarioActual)
        {
            var entity = await _context.EgreAdecuacions.FirstOrDefaultAsync(x => x.PkidEgreAdecuacion == id && x.Activo);
            if (entity == null) return Failure<EgreAdecuacionResponse>("No se encontro la adecuacion.", "NOT_FOUND");
            if (entity.Autorizado == true) return Failure<EgreAdecuacionResponse>("La adecuacion ya fue autorizada.");
            if (entity.FkidAccionAdecuacionMasterPres != 2) return Failure<EgreAdecuacionResponse>("Primero envia la solicitud de autorizacion.");

            var hasDetails = await _context.EgreAdecuacionDetalles.AnyAsync(x => x.FkidEgreAdecuacionPres == id && x.Activo);
            if (!hasDetails) return Failure<EgreAdecuacionResponse>("Agrega al menos un movimiento antes de autorizar.");

            var balanceValidation = await ValidateBalancedPolizaAsync(entity);
            if (balanceValidation != null) return balanceValidation;

            entity.FkidAccionAdecuacionMasterPres = 3;
            entity.Autorizado = true;
            entity.FechaAutorizacion = DateTime.Now;
            entity.UsuarioModificacion = usuarioActual;
            entity.FechaModificacion = DateTime.Now;

            if (entity.FkidPolizaConta.HasValue)
            {
                var poliza = await _context.Polizas.FirstOrDefaultAsync(x => x.PkidPoliza == entity.FkidPolizaConta.Value && x.Activo);
                if (poliza != null)
                {
                    poliza.Autorizado = true;
                    poliza.PermitirModificar = false;
                    poliza.FechaAutorizacion = DateTime.Now;
                    poliza.UsuarioModificacion = usuarioActual;
                    poliza.FechaModificacion = DateTime.Now;
                }
            }

            await _context.SaveChangesAsync();
            return await RefreshedAsync(id, "Se proceso la autorizacion.");
        }

        public async Task<PagedResult<EgreAdecuacionResponse>> RechazarAsync(int id, int usuarioActual)
        {
            var entity = await _context.EgreAdecuacions.FirstOrDefaultAsync(x => x.PkidEgreAdecuacion == id && x.Activo);
            if (entity == null) return Failure<EgreAdecuacionResponse>("No se encontro la adecuacion.", "NOT_FOUND");
            if (entity.Autorizado == true) return Failure<EgreAdecuacionResponse>("La adecuacion ya fue autorizada y no puede rechazarse.");

            entity.FkidAccionAdecuacionMasterPres = 4;
            entity.UsuarioModificacion = usuarioActual;
            entity.FechaModificacion = DateTime.Now;
            await _context.SaveChangesAsync();
            return await RefreshedAsync(id, "Se rechazo la solicitud.");
        }

        private async Task<bool> IsAuthorizedAsync(int id) =>
            await _context.EgreAdecuacions.AnyAsync(x => x.PkidEgreAdecuacion == id && x.Activo && x.Autorizado == true);

        private async Task<PagedResult<EgreAdecuacionResponse>> RefreshedAsync(int id, string message)
        {
            var result = await GetByIdAsync(id);
            result.Message = message;
            return result;
        }

        private async Task<PagedResult<EgreAdecuacionResponse>?> ValidateBalancedPolizaAsync(EgreAdecuacion entity)
        {
            if (!entity.FkidPolizaConta.HasValue)
                return Failure<EgreAdecuacionResponse>("La adecuacion no tiene una poliza asociada.");

            var poliza = await _context.Polizas
                .Where(x => x.PkidPoliza == entity.FkidPolizaConta.Value && x.Activo)
                .Select(x => new { x.PkidPoliza, x.EstaBalanceado })
                .FirstOrDefaultAsync();

            if (poliza == null)
                return Failure<EgreAdecuacionResponse>("No se encontro la poliza asociada a la adecuacion.");

            var totals = await _context.PolizaDetalles
                .Where(x => x.FkidPolizaConta == poliza.PkidPoliza && x.Activo)
                .GroupBy(_ => 1)
                .Select(g => new
                {
                    Count = g.Count(),
                    Debe = g.Sum(x => x.ImporteDebe ?? 0m),
                    Haber = g.Sum(x => x.ImporteHaber ?? 0m)
                })
                .FirstOrDefaultAsync();

            if (totals == null || totals.Count == 0)
                return Failure<EgreAdecuacionResponse>("La poliza no tiene movimientos contables.");

            if (totals.Debe != totals.Haber)
                return Failure<EgreAdecuacionResponse>($"La poliza no esta balanceada. Debe {totals.Debe:0.00}, Haber {totals.Haber:0.00}.");

            if (!poliza.EstaBalanceado)
            {
                var entityPoliza = await _context.Polizas.FirstAsync(x => x.PkidPoliza == poliza.PkidPoliza);
                entityPoliza.EstaBalanceado = true;
            }

            return null;
        }

        private static SqlParameter[] BuildParameters(int action, int? id, EgreAdecuacionResponse? response, int? usuarioActual)
        {
            return new[]
            {
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdEgreAdecuacion", id ?? response?.PkidEgreAdecuacion),
                StoredProcedureExecutor.Param("@Autorizado", response?.Autorizado ?? false),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual),
                StoredProcedureExecutor.Param("@idMenu", 85),
                StoredProcedureExecutor.Param("@AlertMessage", "Presupuesto modificado"),
                StoredProcedureExecutor.Param("@FkIdPolizaConta", response?.FkidPolizaConta),
                StoredProcedureExecutor.Param("@FkIdAnioSis", response?.FkidAnioSis),
                StoredProcedureExecutor.Param("@FkIdTipoAdecuacionPres", response?.FkidTipoAdecuacionPres),
                StoredProcedureExecutor.Param("@FkIdEstatusAdecuacionPres", response?.FkidEstatusAdecuacionPres),
                new SqlParameter("@Justificacion", SqlDbType.NVarChar, -1)
                {
                    Value = response?.Justificacion ?? (object)DBNull.Value
                },
                StoredProcedureExecutor.Param("@Fecha", response?.Fecha.ToDateTime(TimeOnly.MinValue)),
                StoredProcedureExecutor.Param("@FkIdAccionAdecuacionMasterPres", response?.FkidAccionAdecuacionMasterPres),
                StoredProcedureExecutor.Param("@FechaSolicitud", response?.FechaSolicitud),
                StoredProcedureExecutor.Param("@FechaAutorizacion", response?.FechaAutorizacion)
            };
        }

        private static PagedResult<T> Failure<T>(string message, string code = "VALIDATION") => new()
        {
            Success = false,
            Message = message,
            Code = code,
            TotalCount = 0
        };
    }

    public class EgreAdecuacionDetalleAppService(
        GenericService<EgreAdecuacionDetalle, EgreAdecuacionDetalleDto, EgreAdecuacionDetalleResponse> service,
        GenericService<VwEgresoAdecuacionDetalle, EgreAdecuacionDetalleDto, EgreAdecuacionDetalleResponse> serviceView,
        EGestionContext context)
        : StoredProcedureCrudAppService<EgreAdecuacionDetalle, VwEgresoAdecuacionDetalle, EgreAdecuacionDetalleDto, EgreAdecuacionDetalleResponse>(
            service,
            serviceView,
            context,
            "PkidEgreAdecuacionDetalle",
            "Detalle de adecuacion",
            (dto, id) => dto.PkidEgreAdecuacionDetalle = id,
            "PRES.sp_MantenimientoAdecuacionDisminucion",
            response => response.PkidEgreAdecuacionDetalle,
            BuildParameters)
    {
        private readonly EGestionContext _context = context;

        public override async Task<PagedResult<EgreAdecuacionDetalleResponse>> CreateAsync(EgreAdecuacionDetalleResponse response, int usuarioActual)
        {
            var validation = await ValidateParentAsync(response.FkidEgreAdecuacionPres);
            return validation ?? await base.CreateAsync(response, usuarioActual);
        }

        public override async Task<PagedResult<EgreAdecuacionDetalleResponse>> UpdateAsync(int id, EgreAdecuacionDetalleResponse response, int usuarioActual)
        {
            var validation = await ValidateParentAsync(response.FkidEgreAdecuacionPres);
            return validation ?? await base.UpdateAsync(id, response, usuarioActual);
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var parentId = await _context.EgreAdecuacionDetalles
                .Where(x => x.PkidEgreAdecuacionDetalle == id)
                .Select(x => x.FkidEgreAdecuacionPres)
                .FirstOrDefaultAsync();

            if (await _context.EgreAdecuacions.AnyAsync(x => x.PkidEgreAdecuacion == parentId && x.Activo && x.Autorizado == true))
                return new PagedResult<bool> { Success = false, Message = "La adecuacion ya fue autorizada y no puede modificarse.", Code = "VALIDATION" };

            return await base.DeleteAsync(id);
        }

        private async Task<PagedResult<EgreAdecuacionDetalleResponse>?> ValidateParentAsync(int parentId)
        {
            var locked = await _context.EgreAdecuacions.AnyAsync(x => x.PkidEgreAdecuacion == parentId && x.Activo && x.Autorizado == true);
            return locked
                ? new PagedResult<EgreAdecuacionDetalleResponse> { Success = false, Message = "La adecuacion ya fue autorizada y no puede modificarse.", Code = "VALIDATION" }
                : null;
        }

        private static SqlParameter[] BuildParameters(int action, int? id, EgreAdecuacionDetalleResponse? response, int? usuarioActual)
        {
            return new[]
            {
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdEgreAdecuacionDetalle", id ?? response?.PkidEgreAdecuacionDetalle),
                StoredProcedureExecutor.Param("@FKIdEgresoAutorizado_PRES", response?.FkidEgresoAutorizadoPres),
                new SqlParameter("@Justificacion", SqlDbType.NVarChar, -1)
                {
                    Value = response?.Justificacion ?? (object)DBNull.Value
                },
                StoredProcedureExecutor.Param("@Fecha", response?.Fecha.ToDateTime(TimeOnly.MinValue)),
                StoredProcedureExecutor.Param("@FKIdEgreAdecuacion_PRES", response?.FkidEgreAdecuacionPres),
                StoredProcedureExecutor.Param("@FKIdTipoMovimiento_PRES", response?.FkidTipoMovimientoPres),
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
                StoredProcedureExecutor.Param("@IdC", id ?? response?.PkidEgreAdecuacionDetalle),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual)
            };
        }
    }

    public class EgresoDisponibleAppService(
        GenericService<VwEgresoDisponible, EgresoDisponibleDto, EgresoDisponibleResponse> service,
        GenericService<VwEgresoDisponible, EgresoDisponibleDto, EgresoDisponibleResponse> serviceView)
        : AdquisicionCrudAppService<VwEgresoDisponible, VwEgresoDisponible, EgresoDisponibleDto, EgresoDisponibleResponse>(
            service,
            serviceView,
            "PkidEgresoAutorizado",
            "Presupuesto disponible",
            (dto, id) => dto.PkidEgresoAutorizado = id)
    {
        public override Task<PagedResult<EgresoDisponibleResponse>> CreateAsync(EgresoDisponibleResponse response, int usuarioActual) =>
            Task.FromResult(ReadOnlyFailure<EgresoDisponibleResponse>());

        public override Task<PagedResult<EgresoDisponibleResponse>> UpdateAsync(int id, EgresoDisponibleResponse response, int usuarioActual) =>
            Task.FromResult(ReadOnlyFailure<EgresoDisponibleResponse>());

        public override Task<PagedResult<bool>> DeleteAsync(int id) =>
            Task.FromResult(ReadOnlyFailure<bool>());

        private static PagedResult<T> ReadOnlyFailure<T>() => new()
        {
            Success = false,
            Message = "El presupuesto disponible es solo lectura.",
            Code = "READ_ONLY",
            TotalCount = 0
        };
    }
}
