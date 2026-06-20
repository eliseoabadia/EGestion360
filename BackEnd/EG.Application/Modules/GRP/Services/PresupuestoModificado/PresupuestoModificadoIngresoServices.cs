using System.Data;
using EG.Application.Interfaces.PresupuestoModificado;
using EG.Application.Services.Adquisicion;
using EG.Business.Services;
using EG.Common.Exceptions;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.PresupuestoModificado;
using EG.Domain.DTOs.Responses.PresupuestoModificado;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.PresupuestoModificado
{
    public class IngreAdecuacionAppService(
        GenericService<IngreAdecuacion, IngreAdecuacionDto, IngreAdecuacionResponse> service,
        GenericService<VwIngresoAdecuacion, IngreAdecuacionDto, IngreAdecuacionResponse> serviceView,
        EGestionContext context,
        IUserContextService userContext)
        : StoredProcedureCrudAppService<IngreAdecuacion, VwIngresoAdecuacion, IngreAdecuacionDto, IngreAdecuacionResponse>(
            service,
            serviceView,
            context,
            "PkidIngreAdecuacion",
            "Adecuacion de ingresos",
            (dto, id) => dto.PkidIngreAdecuacion = id,
            "PRES.sp_MantenimientoIngresoAdecuacion",
            response => response.PkidIngreAdecuacion,
            BuildParameters),
            IIngresoAdecuacionAppService
    {
        private const string StoredProcedure = "PRES.sp_MantenimientoIngresoAdecuacion";
        private readonly EGestionContext _context = context;
        private readonly IUserContextService _userContext = userContext;

        public override Task<PagedResult<IngreAdecuacionResponse>> GetAllAsync()
        {
            var failure = ValidateEmpresaContext<IngreAdecuacionResponse>();
            return failure != null ? Task.FromResult(failure) : base.GetAllAsync();
        }

        public override Task<PagedResult<IngreAdecuacionResponse>> GetByIdAsync(int id)
        {
            var failure = ValidateEmpresaContext<IngreAdecuacionResponse>();
            return failure != null ? Task.FromResult(failure) : base.GetByIdAsync(id);
        }

        public override Task<PagedResult<IngreAdecuacionResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var failure = ValidateEmpresaContext<IngreAdecuacionResponse>();
            return failure != null ? Task.FromResult(failure) : base.GetAllPaginadoAsync(request);
        }

        public override async Task<PagedResult<IngreAdecuacionResponse>> CreateAsync(
            IngreAdecuacionResponse response,
            int usuarioActual)
        {
            var companyFailure = ValidateEmpresaContext<IngreAdecuacionResponse>();
            if (companyFailure != null) return companyFailure;

            response.Autorizado = false;
            response.FkidAccionAdecuacionMasterPres ??= 1;
            response.Justificacion = response.Justificacion?.Trim();
            return await base.CreateAsync(response, usuarioActual);
        }

        public override async Task<PagedResult<IngreAdecuacionResponse>> UpdateAsync(
            int id,
            IngreAdecuacionResponse response,
            int usuarioActual)
        {
            var companyFailure = ValidateEmpresaContext<IngreAdecuacionResponse>();
            if (companyFailure != null) return companyFailure;

            if (await IsLockedAsync(id))
                return Failure<IngreAdecuacionResponse>("La adecuacion esta en autorizacion o ya fue autorizada y no puede modificarse.");

            response.Justificacion = response.Justificacion?.Trim();
            return await base.UpdateAsync(id, response, usuarioActual);
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var companyFailure = ValidateEmpresaContext<bool>();
            if (companyFailure != null) return companyFailure;

            if (await IsLockedAsync(id))
                return Failure<bool>("La adecuacion esta en autorizacion o ya fue autorizada y no puede eliminarse.");

            try
            {
                await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    StoredProcedure,
                    BuildParameters(3, id, null, _userContext.GetCurrentUserId()));

                return new PagedResult<bool>
                {
                    Success = true,
                    Message = "Adecuacion de ingresos eliminada correctamente.",
                    Code = "SUCCESS",
                    Data = true,
                    Items = [true],
                    TotalCount = 1
                };
            }
            catch (UserVisibleException ex)
            {
                return Failure<bool>(ex.UserMessage, ex.Code);
            }
        }

        public async Task<PagedResult<IngreAdecuacionResponse>> EnviarSolicitudAsync(int id, int usuarioActual)
        {
            var companyFailure = ValidateEmpresaContext<IngreAdecuacionResponse>();
            if (companyFailure != null) return companyFailure;

            var current = await GetByIdAsync(id);
            if (!current.Success || current.Data == null)
                return Failure<IngreAdecuacionResponse>("No se encontro la adecuacion.", "NOT_FOUND");

            if (current.Data.Autorizado)
                return Failure<IngreAdecuacionResponse>("La adecuacion ya fue autorizada.");

            if (current.Data.FkidAccionAdecuacionMasterPres == 2)
                return Failure<IngreAdecuacionResponse>("La solicitud de autorizacion ya fue enviada.");

            if (!await HasDetailsAsync(id))
                return Failure<IngreAdecuacionResponse>("Agrega al menos un movimiento antes de solicitar autorizacion.");

            var balanceFailure = await ValidateBalancedPolizaAsync(current.Data);
            if (balanceFailure != null) return balanceFailure;

            current.Data.FkidAccionAdecuacionMasterPres = 2;
            current.Data.FechaSolicitud = DateTime.Now;
            current.Data.Autorizado = false;

            var result = await ExecuteWorkflowAsync(id, current.Data, usuarioActual, "Solicitud enviada para autorizacion.");
            if (result.Success)
                await NotifyAuthorizersAsync(current.Data, usuarioActual);

            return result;
        }

        public async Task<PagedResult<IngreAdecuacionResponse>> AutorizarAsync(int id, int usuarioActual)
        {
            var companyFailure = ValidateEmpresaContext<IngreAdecuacionResponse>();
            if (companyFailure != null) return companyFailure;

            var current = await GetByIdAsync(id);
            if (!current.Success || current.Data == null)
                return Failure<IngreAdecuacionResponse>("No se encontro la adecuacion.", "NOT_FOUND");

            if (current.Data.Autorizado)
                return Failure<IngreAdecuacionResponse>("La adecuacion ya fue autorizada.");

            if (current.Data.FkidAccionAdecuacionMasterPres != 2)
                return Failure<IngreAdecuacionResponse>("Primero envia la solicitud de autorizacion.");

            if (!await HasDetailsAsync(id))
                return Failure<IngreAdecuacionResponse>("La adecuacion no tiene movimientos.");

            var balanceFailure = await ValidateBalancedPolizaAsync(current.Data);
            if (balanceFailure != null) return balanceFailure;

            current.Data.FkidAccionAdecuacionMasterPres = 3;
            current.Data.Autorizado = true;
            current.Data.FechaAutorizacion = DateTime.Now;

            var result = await ExecuteWorkflowAsync(id, current.Data, usuarioActual, "Adecuacion de ingresos autorizada.");
            if (result.Success)
                await NotifyCreatorAsync(current.Data, usuarioActual, "Autorizada", "La adecuacion de ingresos fue autorizada.");

            return result;
        }

        public async Task<PagedResult<IngreAdecuacionResponse>> RechazarAsync(int id, int usuarioActual)
        {
            var companyFailure = ValidateEmpresaContext<IngreAdecuacionResponse>();
            if (companyFailure != null) return companyFailure;

            var current = await GetByIdAsync(id);
            if (!current.Success || current.Data == null)
                return Failure<IngreAdecuacionResponse>("No se encontro la adecuacion.", "NOT_FOUND");

            if (current.Data.Autorizado)
                return Failure<IngreAdecuacionResponse>("La adecuacion autorizada no puede rechazarse.");

            if (current.Data.FkidAccionAdecuacionMasterPres != 2)
                return Failure<IngreAdecuacionResponse>("La adecuacion no tiene una solicitud pendiente.");

            current.Data.FkidAccionAdecuacionMasterPres = 4;
            current.Data.Autorizado = false;
            current.Data.FechaAutorizacion = null;

            var result = await ExecuteWorkflowAsync(id, current.Data, usuarioActual, "Solicitud rechazada; la captura fue reabierta.");
            if (result.Success)
                await NotifyCreatorAsync(current.Data, usuarioActual, "Rechazada", "La solicitud fue rechazada y quedo disponible para correccion.");

            return result;
        }

        private async Task<PagedResult<IngreAdecuacionResponse>> ExecuteWorkflowAsync(
            int id,
            IngreAdecuacionResponse response,
            int usuarioActual,
            string successMessage)
        {
            try
            {
                await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    StoredProcedure,
                    BuildParameters(2, id, response, usuarioActual));

                var refreshed = await GetByIdAsync(id);
                refreshed.Message = successMessage;
                return refreshed;
            }
            catch (UserVisibleException ex)
            {
                return Failure<IngreAdecuacionResponse>(ex.UserMessage, ex.Code);
            }
        }

        private async Task<PagedResult<IngreAdecuacionResponse>?> ValidateBalancedPolizaAsync(
            IngreAdecuacionResponse response)
        {
            if (!response.FkidPolizaConta.HasValue)
                return Failure<IngreAdecuacionResponse>("La adecuacion no tiene una poliza asociada.");

            var totals = await _context.PolizaDetalles
                .AsNoTracking()
                .Where(x => x.FkidPolizaConta == response.FkidPolizaConta.Value && x.Activo)
                .GroupBy(_ => 1)
                .Select(group => new
                {
                    Count = group.Count(),
                    Debe = group.Sum(x => x.ImporteDebe ?? 0m),
                    Haber = group.Sum(x => x.ImporteHaber ?? 0m)
                })
                .FirstOrDefaultAsync();

            if (totals == null || totals.Count == 0)
                return Failure<IngreAdecuacionResponse>("La poliza no tiene movimientos contables.");

            return totals.Debe != totals.Haber
                ? Failure<IngreAdecuacionResponse>($"La poliza no esta balanceada. Debe {totals.Debe:0.00}, Haber {totals.Haber:0.00}.")
                : null;
        }

        private Task<bool> HasDetailsAsync(int id) =>
            _context.IngreAdecuacionDetalles.AnyAsync(x => x.FkidIngreAdecuacionPres == id && x.Activo);

        private Task<bool> IsLockedAsync(int id) =>
            _context.IngreAdecuacions.AnyAsync(x =>
                x.PkidIngreAdecuacion == id &&
                x.Activo &&
                (x.Autorizado || x.FkidAccionAdecuacionMasterPres == 2));

        private PagedResult<T>? ValidateEmpresaContext<T>()
        {
            var empresaId = _userContext.TryGetCurrentEmpresaId();
            return empresaId.HasValue && empresaId.Value > 0
                ? null
                : Failure<T>("No se encontro la empresa activa en la sesion.", "EMPRESA_REQUIRED");
        }

        private async Task NotifyAuthorizersAsync(IngreAdecuacionResponse item, int usuarioActual)
        {
            try
            {
                var idNotification = new SqlParameter("@IdNotificacion", SqlDbType.BigInt)
                {
                    Direction = ParameterDirection.Output
                };

                await _context.Database.ExecuteSqlRawAsync(
                    "EXEC SIS.sp_NotificacionCrearPorPermiso @ClaveTipo, @Fk_IdUsuarioOrigen, @Modulo, @SubModulo, @Accion, @Evento, @Entidad, @Fk_IdEntidad, @Titulo, @Mensaje, @Url, @JsonData, @IdUser, @IdNotificacion OUTPUT",
                    new SqlParameter("@ClaveTipo", "ADECUACION_INGRESO_AUTORIZAR"),
                    new SqlParameter("@Fk_IdUsuarioOrigen", usuarioActual),
                    new SqlParameter("@Modulo", "Presupuesto_Modificado"),
                    new SqlParameter("@SubModulo", GetSubModule(item.FkidTipoAdecuacionPres)),
                    new SqlParameter("@Accion", "authorize"),
                    new SqlParameter("@Evento", "SolicitudAutorizacion"),
                    new SqlParameter("@Entidad", "IngreAdecuacion"),
                    new SqlParameter("@Fk_IdEntidad", item.PkidIngreAdecuacion),
                    new SqlParameter("@Titulo", $"Autorizar {item.Clave}"),
                    new SqlParameter("@Mensaje", item.Justificacion ?? "Adecuacion de ingresos pendiente de autorizacion."),
                    new SqlParameter("@Url", GetRoute(item.FkidTipoAdecuacionPres)),
                    new SqlParameter("@JsonData", $"{{\"id\":{item.PkidIngreAdecuacion}}}"),
                    new SqlParameter("@IdUser", usuarioActual),
                    idNotification);
            }
            catch
            {
                // La notificacion es complementaria y no revierte el flujo presupuestal.
            }
        }

        private async Task NotifyCreatorAsync(
            IngreAdecuacionResponse item,
            int usuarioActual,
            string eventName,
            string message)
        {
            if (item.UsuarioCreacion <= 0) return;

            try
            {
                var users = new DataTable();
                users.Columns.Add("Fk_IdUsuarioDestino", typeof(int));
                users.Rows.Add(item.UsuarioCreacion);
                var idNotification = new OutputParameter<long?>();

                await _context.Procedures.sp_NotificacionCrearAsync(
                    claveTipo: "ADECUACION_INGRESO_RESULTADO",
                    fk_IdUsuarioOrigen: usuarioActual,
                    modulo: "Presupuesto_Modificado",
                    subModulo: GetSubModule(item.FkidTipoAdecuacionPres),
                    evento: eventName,
                    entidad: "IngreAdecuacion",
                    fk_IdEntidad: item.PkidIngreAdecuacion,
                    titulo: $"{eventName}: {item.Clave}",
                    mensaje: message,
                    url: GetRoute(item.FkidTipoAdecuacionPres),
                    jsonData: $"{{\"id\":{item.PkidIngreAdecuacion}}}",
                    usuarios: users,
                    idUser: usuarioActual,
                    idNotificacion: idNotification);
            }
            catch
            {
                // La notificacion es complementaria y no revierte el flujo presupuestal.
            }
        }

        private static string GetSubModule(int tipoAdecuacionId) => tipoAdecuacionId switch
        {
            1 => "Adecuaciones_Compensadas",
            2 => "Reducciones",
            3 => "Ampliaciones",
            _ => "Adecuaciones_Compensadas"
        };

        private static string GetRoute(int tipoAdecuacionId) => tipoAdecuacionId switch
        {
            1 => "/Presupuesto/Tesoreria/Cuentas_Cobrar/Modificado_Ingreso/Adecuaciones_Compensadas_Ingresos",
            2 => "/Presupuesto/Tesoreria/Cuentas_Cobrar/Modificado_Ingreso/Reduccion_Presupuesto_Ingreso",
            3 => "/Presupuesto/Tesoreria/Cuentas_Cobrar/Modificado_Ingreso/Aumentos_Presupuesto_Ingreso",
            _ => "/Presupuesto/Tesoreria/Cuentas_Cobrar/Modificado_Ingreso/Adecuaciones_Compensadas_Ingresos"
        };

        private static SqlParameter[] BuildParameters(
            int action,
            int? id,
            IngreAdecuacionResponse? response,
            int? usuarioActual)
        {
            return
            [
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdIngreAdecuacion", id ?? response?.PkidIngreAdecuacion),
                StoredProcedureExecutor.Param("@Autorizado", response?.Autorizado ?? false),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual),
                StoredProcedureExecutor.Param("@idMenu", 127),
                StoredProcedureExecutor.Param("@AlertMessage", "Presupuesto modificado de ingresos"),
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
            ];
        }

        private new static PagedResult<T> Failure<T>(string message, string code = "VALIDATION") => new()
        {
            Success = false,
            Message = message,
            Code = code,
            TotalCount = 0
        };
    }

    public class IngreAdecuacionDetalleAppService(
        GenericService<IngreAdecuacionDetalle, IngreAdecuacionDetalleDto, IngreAdecuacionDetalleResponse> service,
        GenericService<VwIngresoAdecuacionDetalle, IngreAdecuacionDetalleDto, IngreAdecuacionDetalleResponse> serviceView,
        EGestionContext context,
        IUserContextService userContext)
        : StoredProcedureCrudAppService<IngreAdecuacionDetalle, VwIngresoAdecuacionDetalle, IngreAdecuacionDetalleDto, IngreAdecuacionDetalleResponse>(
            service,
            serviceView,
            context,
            "PkidIngreAdecuacionDetalle",
            "Detalle de adecuacion de ingresos",
            (dto, id) => dto.PkidIngreAdecuacionDetalle = id,
            "PRES.sp_MantenimientoAdecuacionDisminucionIngreso",
            response => response.PkidIngreAdecuacionDetalle,
            BuildParameters)
    {
        private const string StoredProcedure = "PRES.sp_MantenimientoAdecuacionDisminucionIngreso";
        private readonly EGestionContext _context = context;
        private readonly IUserContextService _userContext = userContext;

        public override Task<PagedResult<IngreAdecuacionDetalleResponse>> GetAllAsync()
        {
            var failure = ValidateCompany();
            return failure != null ? Task.FromResult(failure) : base.GetAllAsync();
        }

        public override Task<PagedResult<IngreAdecuacionDetalleResponse>> GetByIdAsync(int id)
        {
            var failure = ValidateCompany();
            return failure != null ? Task.FromResult(failure) : base.GetByIdAsync(id);
        }

        public override Task<PagedResult<IngreAdecuacionDetalleResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var failure = ValidateCompany();
            return failure != null ? Task.FromResult(failure) : base.GetAllPaginadoAsync(request);
        }

        public override async Task<PagedResult<IngreAdecuacionDetalleResponse>> CreateAsync(
            IngreAdecuacionDetalleResponse response,
            int usuarioActual)
        {
            var validation = await ValidateMutationAsync(response.FkidIngreAdecuacionPres);
            return validation ?? await base.CreateAsync(response, usuarioActual);
        }

        public override async Task<PagedResult<IngreAdecuacionDetalleResponse>> UpdateAsync(
            int id,
            IngreAdecuacionDetalleResponse response,
            int usuarioActual)
        {
            var validation = await ValidateMutationAsync(response.FkidIngreAdecuacionPres);
            return validation ?? await base.UpdateAsync(id, response, usuarioActual);
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var companyId = _userContext.TryGetCurrentEmpresaId();
            if (!companyId.HasValue || companyId.Value <= 0)
                return Failure<bool>("No se encontro la empresa activa en la sesion.", "EMPRESA_REQUIRED");

            var parent = await _context.IngreAdecuacionDetalles
                .Where(x => x.PkidIngreAdecuacionDetalle == id && x.Activo)
                .Select(x => x.FkidIngreAdecuacionPres)
                .FirstOrDefaultAsync();

            var validation = await ValidateMutationAsync(parent);
            if (validation != null) return Failure<bool>(validation.Message, validation.Code ?? "VALIDATION");

            try
            {
                await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    StoredProcedure,
                    BuildParameters(3, id, null, _userContext.GetCurrentUserId()));

                return new PagedResult<bool>
                {
                    Success = true,
                    Message = "Movimiento eliminado correctamente.",
                    Code = "SUCCESS",
                    Data = true,
                    Items = [true],
                    TotalCount = 1
                };
            }
            catch (UserVisibleException ex)
            {
                return Failure<bool>(ex.UserMessage, ex.Code);
            }
        }

        private async Task<PagedResult<IngreAdecuacionDetalleResponse>?> ValidateMutationAsync(int parentId)
        {
            var companyFailure = ValidateCompany();
            if (companyFailure != null) return companyFailure;

            var parent = await _context.IngreAdecuacions
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidIngreAdecuacion == parentId && x.Activo);

            if (parent == null)
                return Failure<IngreAdecuacionDetalleResponse>("No se encontro la adecuacion.", "NOT_FOUND");

            return parent.Autorizado || parent.FkidAccionAdecuacionMasterPres == 2
                ? Failure<IngreAdecuacionDetalleResponse>("La captura esta en autorizacion o ya fue autorizada y no puede modificarse.")
                : null;
        }

        private PagedResult<IngreAdecuacionDetalleResponse>? ValidateCompany()
        {
            var companyId = _userContext.TryGetCurrentEmpresaId();
            return companyId.HasValue && companyId.Value > 0
                ? null
                : Failure<IngreAdecuacionDetalleResponse>("No se encontro la empresa activa en la sesion.", "EMPRESA_REQUIRED");
        }

        private static SqlParameter[] BuildParameters(
            int action,
            int? id,
            IngreAdecuacionDetalleResponse? response,
            int? usuarioActual)
        {
            return
            [
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdIngreAdecuacionDetalle", id ?? response?.PkidIngreAdecuacionDetalle),
                StoredProcedureExecutor.Param("@FKIdIngresoAutorizado_PRES", response?.FkidIngresoAutorizadoPres),
                new SqlParameter("@Justificacion", SqlDbType.NVarChar, -1)
                {
                    Value = response?.Justificacion ?? (object)DBNull.Value
                },
                StoredProcedureExecutor.Param("@Fecha", response?.Fecha.ToDateTime(TimeOnly.MinValue)),
                StoredProcedureExecutor.Param("@FKIdIngreAdecuacion_PRES", response?.FkidIngreAdecuacionPres),
                StoredProcedureExecutor.Param("@FKIdTipoMovimiento_PRES", response?.FkidTipoMovimientoPres),
                StoredProcedureExecutor.Param("@Enero", Math.Abs(response?.Enero ?? 0m)),
                StoredProcedureExecutor.Param("@Febrero", Math.Abs(response?.Febrero ?? 0m)),
                StoredProcedureExecutor.Param("@Marzo", Math.Abs(response?.Marzo ?? 0m)),
                StoredProcedureExecutor.Param("@Abril", Math.Abs(response?.Abril ?? 0m)),
                StoredProcedureExecutor.Param("@Mayo", Math.Abs(response?.Mayo ?? 0m)),
                StoredProcedureExecutor.Param("@Junio", Math.Abs(response?.Junio ?? 0m)),
                StoredProcedureExecutor.Param("@Julio", Math.Abs(response?.Julio ?? 0m)),
                StoredProcedureExecutor.Param("@Agosto", Math.Abs(response?.Agosto ?? 0m)),
                StoredProcedureExecutor.Param("@Septiembre", Math.Abs(response?.Septiembre ?? 0m)),
                StoredProcedureExecutor.Param("@Octubre", Math.Abs(response?.Octubre ?? 0m)),
                StoredProcedureExecutor.Param("@Noviembre", Math.Abs(response?.Noviembre ?? 0m)),
                StoredProcedureExecutor.Param("@Diciembre", Math.Abs(response?.Diciembre ?? 0m)),
                StoredProcedureExecutor.Param("@IdC", id ?? response?.PkidIngreAdecuacionDetalle),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual)
            ];
        }

        private new static PagedResult<T> Failure<T>(string message, string code = "VALIDATION") => new()
        {
            Success = false,
            Message = message,
            Code = code,
            TotalCount = 0
        };
    }
}
