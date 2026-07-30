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

namespace EG.Application.Services.PresupuestoModificado;

public class EgreAdecuacionAppService(
    GenericService<EgreAdecuacion, EgreAdecuacionDto, EgreAdecuacionResponse> service,
    GenericService<VwEgresoAdecuacion, EgreAdecuacionDto, EgreAdecuacionResponse> serviceView,
    EGestionContext context,
    IUserContextService userContext)
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
    private const string StoredProcedure = "PRES.sp_MantenimientoEgresoAdecuacion";
    private const int EnCaptura = 1;
    private const int SolicitudEnviada = 2;
    private const int Autorizada = 3;
    private const int Rechazada = 4;

    private readonly EGestionContext _context = context;
    private readonly IUserContextService _userContext = userContext;

    public override async Task<PagedResult<EgreAdecuacionResponse>> GetAllAsync()
    {
        var (scope, failure) = await TryGetScopeAsync<EgreAdecuacionResponse>();
        if (failure != null) return failure;

        var result = await base.GetAllAsync();
        result.Items = result.Items
            .Where(x => x.FkidEmpresaSis == scope!.Value.EmpresaId && x.FkidAnioSis == scope.Value.AnioId)
            .ToList();
        result.TotalCount = result.Items.Count;
        return result;
    }

    public override async Task<PagedResult<EgreAdecuacionResponse>> GetByIdAsync(int id)
    {
        var (scope, failure) = await TryGetScopeAsync<EgreAdecuacionResponse>();
        if (failure != null) return failure;

        var result = await base.GetByIdAsync(id);
        return result.Success && result.Data is not null &&
               (result.Data.FkidEmpresaSis != scope!.Value.EmpresaId || result.Data.FkidAnioSis != scope.Value.AnioId)
            ? Failure<EgreAdecuacionResponse>("La adecuacion no pertenece a la empresa y ejercicio seleccionados.", "NOT_FOUND")
            : result;
    }

    public override async Task<PagedResult<EgreAdecuacionResponse>> GetAllPaginadoAsync(PagedRequest request)
    {
        var (scope, failure) = await TryGetScopeAsync<EgreAdecuacionResponse>();
        if (failure != null) return failure;

        ApplyScope(request, scope!.Value);
        return await base.GetAllPaginadoAsync(request);
    }

    public override async Task<PagedResult<EgreAdecuacionResponse>> CreateAsync(
        EgreAdecuacionResponse response,
        int usuarioActual)
    {
        var (scope, failure) = await TryGetScopeAsync<EgreAdecuacionResponse>();
        if (failure != null) return failure;

        var validation = ValidateHeaderInput(response, scope!.Value);
        if (validation != null) return validation;

        response.FkidEmpresaSis = scope.Value.EmpresaId;
        response.FkidAnioSis = scope.Value.AnioId;
        response.FkidEstatusAdecuacionPres = EnCaptura;
        response.FkidAccionAdecuacionMasterPres = EnCaptura;
        response.Autorizado = false;
        response.FkidPolizaConta = null;
        return await base.CreateAsync(response, usuarioActual);
    }

    public override async Task<PagedResult<EgreAdecuacionResponse>> UpdateAsync(
        int id,
        EgreAdecuacionResponse response,
        int usuarioActual)
    {
        var (scope, failure) = await TryGetScopeAsync<EgreAdecuacionResponse>();
        if (failure != null) return failure;

        var current = await _context.EgreAdecuacions
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.PkidEgreAdecuacion == id && x.Activo &&
                x.FkidEmpresaSis == scope!.Value.EmpresaId && x.FkidAnioSis == scope.Value.AnioId);
        if (current == null)
            return Failure<EgreAdecuacionResponse>("La adecuacion no pertenece al contexto activo.", "NOT_FOUND");
        if (IsLocked(current))
            return Failure<EgreAdecuacionResponse>("La adecuacion esta en autorizacion, autorizada o rechazada y no puede modificarse.");
        if (response.FkidTipoAdecuacionPres != current.FkidTipoAdecuacionPres)
            return Failure<EgreAdecuacionResponse>("No es posible cambiar el tipo de adecuacion.");

        var validation = ValidateHeaderInput(response, scope.Value);
        if (validation != null) return validation;

        response.FkidEmpresaSis = current.FkidEmpresaSis;
        response.FkidAnioSis = current.FkidAnioSis;
        response.FkidTipoAdecuacionPres = current.FkidTipoAdecuacionPres;
        response.FkidEstatusAdecuacionPres = EnCaptura;
        response.FkidAccionAdecuacionMasterPres = EnCaptura;
        response.Autorizado = false;
        response.FkidPolizaConta = current.FkidPolizaConta;
        response.FechaSolicitud = current.FechaSolicitud;
        response.FechaAutorizacion = current.FechaAutorizacion;
        return await base.UpdateAsync(id, response, usuarioActual);
    }

    public override async Task<PagedResult<bool>> DeleteAsync(int id)
    {
        var (scope, failure) = await TryGetScopeAsync<bool>();
        if (failure != null) return failure;

        var current = await _context.EgreAdecuacions
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.PkidEgreAdecuacion == id && x.Activo &&
                x.FkidEmpresaSis == scope!.Value.EmpresaId && x.FkidAnioSis == scope.Value.AnioId);
        if (current == null)
            return Failure<bool>("La adecuacion no pertenece al contexto activo.", "NOT_FOUND");
        if (IsLocked(current))
            return Failure<bool>("La adecuacion solo puede eliminarse mientras esta en captura.");

        try
        {
            await StoredProcedureExecutor.ExecuteResultAsync(
                _context,
                StoredProcedure,
                BuildParameters(3, id, null, _userContext.GetCurrentUserId(), scope.Value.EmpresaId));

            return new PagedResult<bool>
            {
                Success = true,
                Message = "Adecuacion eliminada correctamente.",
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

    public async Task<PagedResult<EgreAdecuacionResponse>> EnviarSolicitudAsync(int id, int usuarioActual)
    {
        var current = await GetByIdAsync(id);
        if (!current.Success || current.Data == null) return Failure<EgreAdecuacionResponse>("No se encontro la adecuacion.", "NOT_FOUND");
        if (current.Data.FkidAccionAdecuacionMasterPres != EnCaptura || current.Data.Autorizado == true)
            return Failure<EgreAdecuacionResponse>("La adecuacion ya no esta disponible para enviar a autorizacion.");

        var detailValidation = await ValidateDetailsForWorkflowAsync(current.Data);
        if (detailValidation != null) return detailValidation;
        var balanceValidation = await ValidateBalancedPolizaAsync(current.Data);
        if (balanceValidation != null) return balanceValidation;

        current.Data.FkidAccionAdecuacionMasterPres = SolicitudEnviada;
        current.Data.FkidEstatusAdecuacionPres = EnCaptura;
        current.Data.Autorizado = false;
        current.Data.FechaSolicitud = DateTime.Now;
        var result = await ExecuteWorkflowAsync(id, current.Data, usuarioActual, "Solicitud enviada para autorizacion.");
        if (result.Success) await NotifyAuthorizersAsync(current.Data, usuarioActual);
        return result;
    }

    public async Task<PagedResult<EgreAdecuacionResponse>> AutorizarAsync(int id, int usuarioActual)
    {
        var current = await GetByIdAsync(id);
        if (!current.Success || current.Data == null) return Failure<EgreAdecuacionResponse>("No se encontro la adecuacion.", "NOT_FOUND");
        if (current.Data.FkidAccionAdecuacionMasterPres != SolicitudEnviada || current.Data.Autorizado == true)
            return Failure<EgreAdecuacionResponse>("La adecuacion no tiene una solicitud de autorizacion pendiente.");

        var detailValidation = await ValidateDetailsForWorkflowAsync(current.Data);
        if (detailValidation != null) return detailValidation;
        var balanceValidation = await ValidateBalancedPolizaAsync(current.Data);
        if (balanceValidation != null) return balanceValidation;

        current.Data.FkidAccionAdecuacionMasterPres = Autorizada;
        current.Data.FkidEstatusAdecuacionPres = 3;
        current.Data.Autorizado = true;
        current.Data.FechaAutorizacion = DateTime.Now;
        var result = await ExecuteWorkflowAsync(id, current.Data, usuarioActual, "Adecuacion autorizada.");
        if (result.Success) await NotifyCreatorAsync(current.Data, usuarioActual, "Autorizada", "La adecuacion presupuestal fue autorizada.");
        return result;
    }

    public async Task<PagedResult<EgreAdecuacionResponse>> RechazarAsync(int id, int usuarioActual)
    {
        var current = await GetByIdAsync(id);
        if (!current.Success || current.Data == null) return Failure<EgreAdecuacionResponse>("No se encontro la adecuacion.", "NOT_FOUND");
        if (current.Data.FkidAccionAdecuacionMasterPres != SolicitudEnviada || current.Data.Autorizado == true)
            return Failure<EgreAdecuacionResponse>("La adecuacion no tiene una solicitud de autorizacion pendiente.");

        current.Data.FkidAccionAdecuacionMasterPres = Rechazada;
        current.Data.FkidEstatusAdecuacionPres = 4;
        current.Data.Autorizado = false;
        current.Data.FechaAutorizacion = DateTime.Now;
        var result = await ExecuteWorkflowAsync(id, current.Data, usuarioActual, "Solicitud rechazada.");
        if (result.Success) await NotifyCreatorAsync(current.Data, usuarioActual, "Rechazada", "La solicitud de adecuacion fue rechazada.");
        return result;
    }

    public async Task<PagedResult<EgreAdecuacionResponse>> CancelarSolicitudAsync(int id, int usuarioActual)
    {
        var current = await GetByIdAsync(id);
        if (!current.Success || current.Data == null) return Failure<EgreAdecuacionResponse>("No se encontro la adecuacion.", "NOT_FOUND");
        if (current.Data.FkidAccionAdecuacionMasterPres != SolicitudEnviada || current.Data.Autorizado == true)
            return Failure<EgreAdecuacionResponse>("Solo se puede cancelar una solicitud pendiente de autorizacion.");

        current.Data.FkidAccionAdecuacionMasterPres = EnCaptura;
        current.Data.FkidEstatusAdecuacionPres = EnCaptura;
        current.Data.Autorizado = false;
        current.Data.FechaAutorizacion = null;
        return await ExecuteWorkflowAsync(id, current.Data, usuarioActual, "Solicitud cancelada; la adecuacion regreso a captura.");
    }

    private async Task<PagedResult<EgreAdecuacionResponse>> ExecuteWorkflowAsync(
        int id,
        EgreAdecuacionResponse response,
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
            return Failure<EgreAdecuacionResponse>(ex.UserMessage, ex.Code);
        }
    }

    private async Task<PagedResult<EgreAdecuacionResponse>?> ValidateDetailsForWorkflowAsync(EgreAdecuacionResponse header)
    {
        var details = await _context.EgreAdecuacionDetalles
            .AsNoTracking()
            .Where(x => x.FkidEgreAdecuacionPres == header.PkidEgreAdecuacion && x.Activo)
            .Select(x => new { x.FkidTipoMovimientoPres, x.Total })
            .ToListAsync();
        if (details.Count == 0)
            return Failure<EgreAdecuacionResponse>("Agrega al menos un movimiento antes de solicitar autorizacion.");

        var aumentos = details.Where(x => x.FkidTipoMovimientoPres == 1).Sum(x => Math.Abs(x.Total ?? 0m));
        var reducciones = details.Where(x => x.FkidTipoMovimientoPres == 2).Sum(x => Math.Abs(x.Total ?? 0m));

        return header.FkidTipoAdecuacionPres switch
        {
            1 when aumentos <= 0m || reducciones <= 0m => Failure<EgreAdecuacionResponse>("La adecuacion compensada requiere al menos un aumento y una reduccion."),
            1 when aumentos != reducciones => Failure<EgreAdecuacionResponse>("La adecuacion compensada debe tener el mismo importe en aumentos y reducciones."),
            2 when aumentos > 0m || reducciones <= 0m => Failure<EgreAdecuacionResponse>("La reduccion solo admite movimientos de reduccion."),
            3 when reducciones > 0m || aumentos <= 0m => Failure<EgreAdecuacionResponse>("La ampliacion solo admite movimientos de aumento."),
            _ => null
        };
    }

    private async Task<PagedResult<EgreAdecuacionResponse>?> ValidateBalancedPolizaAsync(EgreAdecuacionResponse response)
    {
        if (!response.FkidPolizaConta.HasValue)
            return Failure<EgreAdecuacionResponse>("La adecuacion no tiene una poliza asociada.");

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
            return Failure<EgreAdecuacionResponse>("La poliza no tiene movimientos contables.");
        if (totals.Debe != totals.Haber)
            return Failure<EgreAdecuacionResponse>($"La poliza no esta balanceada. Debe {totals.Debe:0.00}, Haber {totals.Haber:0.00}.");

        return null;
    }

    private static PagedResult<EgreAdecuacionResponse>? ValidateHeaderInput(
        EgreAdecuacionResponse response,
        PresupuestoModificadoScope scope)
    {
        response.Justificacion = response.Justificacion?.Trim();
        if (string.IsNullOrWhiteSpace(response.Justificacion))
            return Failure<EgreAdecuacionResponse>("La justificacion es obligatoria.");
        if (response.FkidTipoAdecuacionPres is < 1 or > 3)
            return Failure<EgreAdecuacionResponse>("El tipo de adecuacion no es valido.");
        if (response.Fecha.Year != scope.AnioClave)
            return Failure<EgreAdecuacionResponse>($"La fecha debe pertenecer al ejercicio presupuestal {scope.AnioClave}.");
        return null;
    }

    private static bool IsLocked(EgreAdecuacion header) =>
        header.Autorizado == true || header.FkidAccionAdecuacionMasterPres != EnCaptura;

    private static void ApplyScope(PagedRequest request, PresupuestoModificadoScope scope)
    {
        request.AdditionalFilters ??= new Dictionary<string, object>();
        request.AdditionalFilters["FkidEmpresaSis"] = scope.EmpresaId;
        request.AdditionalFilters["FkidAnioSis"] = scope.AnioId;
    }

    private async Task<(PresupuestoModificadoScope? Scope, PagedResult<T>? Failure)> TryGetScopeAsync<T>()
    {
        try
        {
            return (await PresupuestoModificadoScopeResolver.RequireAsync(_context, _userContext), null);
        }
        catch (UserVisibleException ex)
        {
            return (null, Failure<T>(ex.UserMessage, ex.Code));
        }
    }

    private async Task NotifyAuthorizersAsync(EgreAdecuacionResponse item, int usuarioActual)
    {
        try
        {
            var idNotification = new SqlParameter("@IdNotificacion", SqlDbType.BigInt) { Direction = ParameterDirection.Output };
            await _context.Database.ExecuteSqlRawAsync(
                "EXEC SIS.sp_NotificacionCrearPorPermiso @ClaveTipo, @Fk_IdUsuarioOrigen, @Modulo, @SubModulo, @Accion, @Evento, @Entidad, @Fk_IdEntidad, @Titulo, @Mensaje, @Url, @JsonData, @IdUser, @IdNotificacion OUTPUT",
                new SqlParameter("@ClaveTipo", "ADECUACION_EGRESO_AUTORIZAR"),
                new SqlParameter("@Fk_IdUsuarioOrigen", usuarioActual),
                new SqlParameter("@Modulo", "Presupuesto_Modificado"),
                new SqlParameter("@SubModulo", GetSubModule(item.FkidTipoAdecuacionPres)),
                new SqlParameter("@Accion", "authorize"),
                new SqlParameter("@Evento", "SolicitudAutorizacion"),
                new SqlParameter("@Entidad", "EgreAdecuacion"),
                new SqlParameter("@Fk_IdEntidad", item.PkidEgreAdecuacion),
                new SqlParameter("@Titulo", $"Autorizar {item.Clave}"),
                new SqlParameter("@Mensaje", item.Justificacion ?? "Adecuacion presupuestal pendiente de autorizacion."),
                new SqlParameter("@Url", GetRoute(item.FkidTipoAdecuacionPres)),
                new SqlParameter("@JsonData", $"{{\"id\":{item.PkidEgreAdecuacion}}}"),
                new SqlParameter("@IdUser", usuarioActual),
                idNotification);
        }
        catch
        {
            // La notificacion no revierte el movimiento presupuestal.
        }
    }

    private async Task NotifyCreatorAsync(EgreAdecuacionResponse item, int usuarioActual, string eventName, string message)
    {
        if (item.UsuarioCreacion <= 0) return;

        try
        {
            var users = new DataTable();
            users.Columns.Add("Fk_IdUsuarioDestino", typeof(int));
            users.Rows.Add(item.UsuarioCreacion);
            var idNotification = new OutputParameter<long?>();
            await _context.Procedures.sp_NotificacionCrearAsync(
                "ADECUACION_EGRESO_RESULTADO", usuarioActual, "Presupuesto_Modificado", GetSubModule(item.FkidTipoAdecuacionPres),
                eventName, "EgreAdecuacion", item.PkidEgreAdecuacion, $"{eventName}: {item.Clave}", message,
                GetRoute(item.FkidTipoAdecuacionPres), $"{{\"id\":{item.PkidEgreAdecuacion}}}", users, usuarioActual, idNotification);
        }
        catch
        {
            // La notificacion no revierte el movimiento presupuestal.
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
        1 => "/Presupuesto/Egreso/Presupesto_Modificado/Adecuaciones_Compensadas",
        2 => "/Presupuesto/Egreso/Presupesto_Modificado/Reducciones",
        3 => "/Presupuesto/Egreso/Presupesto_Modificado/Adecuaciones",
        _ => "/Presupuesto/Egreso/Presupesto_Modificado/Adecuaciones_Compensadas"
    };

    private static SqlParameter[] BuildParameters(int action, int? id, EgreAdecuacionResponse? response, int? usuarioActual) =>
        BuildParameters(action, id, response, usuarioActual, response?.FkidEmpresaSis);

    private static SqlParameter[] BuildParameters(int action, int? id, EgreAdecuacionResponse? response, int? usuarioActual, int? empresaId) =>
    [
        StoredProcedureExecutor.Param("@Action", action),
        StoredProcedureExecutor.Param("@PKIdEgreAdecuacion", id ?? response?.PkidEgreAdecuacion),
        StoredProcedureExecutor.Param("@Autorizado", response?.Autorizado ?? false),
        StoredProcedureExecutor.Param("@IdUser", usuarioActual),
        StoredProcedureExecutor.Param("@idMenu", 85),
        StoredProcedureExecutor.Param("@AlertMessage", "Presupuesto modificado de egresos"),
        StoredProcedureExecutor.Param("@FkIdPolizaConta", response?.FkidPolizaConta),
        StoredProcedureExecutor.Param("@FkIdEmpresaSis", empresaId),
        StoredProcedureExecutor.Param("@FkIdAnioSis", response?.FkidAnioSis),
        StoredProcedureExecutor.Param("@FkIdTipoAdecuacionPres", response?.FkidTipoAdecuacionPres),
        StoredProcedureExecutor.Param("@FkIdEstatusAdecuacionPres", response?.FkidEstatusAdecuacionPres),
        new SqlParameter("@Justificacion", SqlDbType.NVarChar, -1) { Value = response?.Justificacion ?? (object)DBNull.Value },
        StoredProcedureExecutor.Param("@Fecha", response?.Fecha.ToDateTime(TimeOnly.MinValue)),
        StoredProcedureExecutor.Param("@FkIdAccionAdecuacionMasterPres", response?.FkidAccionAdecuacionMasterPres),
        StoredProcedureExecutor.Param("@FechaSolicitud", response?.FechaSolicitud),
        StoredProcedureExecutor.Param("@FechaAutorizacion", response?.FechaAutorizacion)
    ];

    private new static PagedResult<T> Failure<T>(string message, string code = "VALIDATION") => new()
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
    EGestionContext context,
    IUserContextService userContext)
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
    private const string StoredProcedure = "PRES.sp_MantenimientoAdecuacionDisminucion";
    private readonly EGestionContext _context = context;
    private readonly IUserContextService _userContext = userContext;

    public override async Task<PagedResult<EgreAdecuacionDetalleResponse>> GetAllAsync()
    {
        var (scope, failure) = await TryGetScopeAsync<EgreAdecuacionDetalleResponse>();
        if (failure != null) return failure;

        var result = await base.GetAllAsync();
        result.Items = result.Items
            .Where(x => x.FkidEmpresaSis == scope!.Value.EmpresaId && x.FkidAnioSis == scope.Value.AnioId)
            .ToList();
        result.TotalCount = result.Items.Count;
        return result;
    }

    public override async Task<PagedResult<EgreAdecuacionDetalleResponse>> GetByIdAsync(int id)
    {
        var (scope, failure) = await TryGetScopeAsync<EgreAdecuacionDetalleResponse>();
        if (failure != null) return failure;

        var result = await base.GetByIdAsync(id);
        return result.Success && result.Data is not null &&
               (result.Data.FkidEmpresaSis != scope!.Value.EmpresaId || result.Data.FkidAnioSis != scope.Value.AnioId)
            ? Failure<EgreAdecuacionDetalleResponse>("El movimiento no pertenece al contexto activo.", "NOT_FOUND")
            : result;
    }

    public override async Task<PagedResult<EgreAdecuacionDetalleResponse>> GetAllPaginadoAsync(PagedRequest request)
    {
        var (scope, failure) = await TryGetScopeAsync<EgreAdecuacionDetalleResponse>();
        if (failure != null) return failure;

        ApplyScope(request, scope!.Value);
        return await base.GetAllPaginadoAsync(request);
    }

    public override async Task<PagedResult<EgreAdecuacionDetalleResponse>> CreateAsync(
        EgreAdecuacionDetalleResponse response,
        int usuarioActual)
    {
        var (scope, failure) = await TryGetScopeAsync<EgreAdecuacionDetalleResponse>();
        if (failure != null) return failure;

        var validation = await ValidateMutationAsync(response, scope!.Value);
        if (validation != null) return validation;

        response.FkidEmpresaSis = scope.Value.EmpresaId;
        response.FkidAnioSis = scope.Value.AnioId;
        NormalizeAmounts(response);
        return await base.CreateAsync(response, usuarioActual);
    }

    public override async Task<PagedResult<EgreAdecuacionDetalleResponse>> UpdateAsync(
        int id,
        EgreAdecuacionDetalleResponse response,
        int usuarioActual)
    {
        var (scope, failure) = await TryGetScopeAsync<EgreAdecuacionDetalleResponse>();
        if (failure != null) return failure;

        var existing = await _context.EgreAdecuacionDetalles
            .AsNoTracking()
            .Where(x => x.PkidEgreAdecuacionDetalle == id && x.Activo)
            .Select(x => new { x.FkidEgreAdecuacionPres, x.FkidTipoMovimientoPres })
            .FirstOrDefaultAsync();
        if (existing == null)
            return Failure<EgreAdecuacionDetalleResponse>("No se encontro el movimiento.", "NOT_FOUND");

        response.FkidEgreAdecuacionPres = existing.FkidEgreAdecuacionPres;
        response.FkidTipoMovimientoPres = existing.FkidTipoMovimientoPres;
        var validation = await ValidateMutationAsync(response, scope!.Value, id);
        if (validation != null) return validation;

        response.FkidEmpresaSis = scope.Value.EmpresaId;
        response.FkidAnioSis = scope.Value.AnioId;
        NormalizeAmounts(response);
        return await base.UpdateAsync(id, response, usuarioActual);
    }

    public override async Task<PagedResult<bool>> DeleteAsync(int id)
    {
        var (scope, failure) = await TryGetScopeAsync<bool>();
        if (failure != null) return failure;

        var detail = await _context.EgreAdecuacionDetalles
            .AsNoTracking()
            .Where(x => x.PkidEgreAdecuacionDetalle == id && x.Activo)
            .Select(x => new { x.FkidEgreAdecuacionPres, x.FkidTipoMovimientoPres })
            .FirstOrDefaultAsync();
        if (detail == null)
            return Failure<bool>("No se encontro el movimiento.", "NOT_FOUND");

        var validation = await ValidateParentAsync(detail.FkidEgreAdecuacionPres, scope!.Value);
        if (validation != null) return Failure<bool>(validation.Message, validation.Code ?? "VALIDATION");

        try
        {
            await StoredProcedureExecutor.ExecuteResultAsync(
                _context,
                StoredProcedure,
                BuildParameters(3, id, null, _userContext.GetCurrentUserId(), scope.Value.EmpresaId));
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

    private async Task<PagedResult<EgreAdecuacionDetalleResponse>?> ValidateMutationAsync(
        EgreAdecuacionDetalleResponse response,
        PresupuestoModificadoScope scope,
        int? currentDetailId = null)
    {
        var parentValidation = await ValidateParentAsync(response.FkidEgreAdecuacionPres, scope);
        if (parentValidation != null) return parentValidation;

        if (response.FkidEgresoAutorizadoPres is not > 0)
            return Failure<EgreAdecuacionDetalleResponse>("Selecciona un egreso autorizado disponible.");
        if (response.Fecha.Year != scope.AnioClave)
            return Failure<EgreAdecuacionDetalleResponse>($"La fecha del movimiento debe pertenecer al ejercicio {scope.AnioClave}.");
        if (HasAmountsBeforeDate(response))
            return Failure<EgreAdecuacionDetalleResponse>("No es posible capturar importes en meses anteriores a la fecha del movimiento.");
        if (GetAbsoluteTotal(response) <= 0m)
            return Failure<EgreAdecuacionDetalleResponse>("Captura un importe para al menos un mes.");

        var parent = await _context.EgreAdecuacions
            .AsNoTracking()
            .Where(x => x.PkidEgreAdecuacion == response.FkidEgreAdecuacionPres)
            .Select(x => new { x.FkidTipoAdecuacionPres })
            .FirstAsync();
        if (!IsAllowedMovement(parent.FkidTipoAdecuacionPres, response.FkidTipoMovimientoPres))
            return Failure<EgreAdecuacionDetalleResponse>("El tipo de movimiento no corresponde al tipo de adecuacion.");

        var egreso = await _context.VwEgresoAutorizados
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.PkidEgresoAutorizado == response.FkidEgresoAutorizadoPres.Value &&
                x.FkidEmpresaSis == scope.EmpresaId && x.FkidAnioSis == scope.AnioId);
        if (egreso == null)
            return Failure<EgreAdecuacionDetalleResponse>("El egreso autorizado no pertenece a la empresa y ejercicio seleccionados.");

        if (response.FkidTipoMovimientoPres == 2)
        {
            var disponible = await _context.VwEgresoDisponibles
                .AsNoTracking()
                .Where(x => x.PkidEgresoAutorizado == response.FkidEgresoAutorizadoPres.Value &&
                    x.FkidEmpresaSis == scope.EmpresaId && x.FkidAnioSis == scope.AnioId)
                .Select(x => x.Total ?? 0m)
                .FirstOrDefaultAsync();
            var pendientes = await _context.EgreAdecuacionDetalles
                .AsNoTracking()
                .Where(x => x.FkidEgreAdecuacionPres == response.FkidEgreAdecuacionPres &&
                    x.FkidEgresoAutorizadoPres == response.FkidEgresoAutorizadoPres && x.Activo &&
                    (!currentDetailId.HasValue || x.PkidEgreAdecuacionDetalle != currentDetailId.Value))
                .SumAsync(x => x.Total ?? 0m);

            if (disponible + pendientes - GetAbsoluteTotal(response) < 0m)
                return Failure<EgreAdecuacionDetalleResponse>("La reduccion supera el presupuesto disponible de la partida seleccionada.");
        }

        return null;
    }

    private async Task<PagedResult<EgreAdecuacionDetalleResponse>?> ValidateParentAsync(int parentId, PresupuestoModificadoScope scope)
    {
        var parent = await _context.EgreAdecuacions
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.PkidEgreAdecuacion == parentId && x.Activo &&
                x.FkidEmpresaSis == scope.EmpresaId && x.FkidAnioSis == scope.AnioId);
        if (parent == null)
            return Failure<EgreAdecuacionDetalleResponse>("La adecuacion no pertenece a la empresa y ejercicio seleccionados.", "NOT_FOUND");
        return parent.Autorizado == true || parent.FkidAccionAdecuacionMasterPres != 1
            ? Failure<EgreAdecuacionDetalleResponse>("La adecuacion no esta en captura y sus movimientos no pueden modificarse.")
            : null;
    }

    private static bool IsAllowedMovement(int tipoAdecuacion, int tipoMovimiento) => tipoAdecuacion switch
    {
        1 => tipoMovimiento is 1 or 2,
        2 => tipoMovimiento == 2,
        3 => tipoMovimiento == 1,
        _ => false
    };

    private static bool HasAmountsBeforeDate(EgreAdecuacionDetalleResponse response)
    {
        var month = response.Fecha.Month;
        return GetMonths(response).Take(month - 1).Any(value => Math.Abs(value) > 0m);
    }

    private static decimal GetAbsoluteTotal(EgreAdecuacionDetalleResponse response) => GetMonths(response).Sum(Math.Abs);

    private static IEnumerable<decimal> GetMonths(EgreAdecuacionDetalleResponse response) =>
    [
        response.Enero ?? 0m, response.Febrero ?? 0m, response.Marzo ?? 0m, response.Abril ?? 0m,
        response.Mayo ?? 0m, response.Junio ?? 0m, response.Julio ?? 0m, response.Agosto ?? 0m,
        response.Septiembre ?? 0m, response.Octubre ?? 0m, response.Noviembre ?? 0m, response.Diciembre ?? 0m
    ];

    private static void NormalizeAmounts(EgreAdecuacionDetalleResponse response)
    {
        response.Enero = Math.Abs(response.Enero ?? 0m);
        response.Febrero = Math.Abs(response.Febrero ?? 0m);
        response.Marzo = Math.Abs(response.Marzo ?? 0m);
        response.Abril = Math.Abs(response.Abril ?? 0m);
        response.Mayo = Math.Abs(response.Mayo ?? 0m);
        response.Junio = Math.Abs(response.Junio ?? 0m);
        response.Julio = Math.Abs(response.Julio ?? 0m);
        response.Agosto = Math.Abs(response.Agosto ?? 0m);
        response.Septiembre = Math.Abs(response.Septiembre ?? 0m);
        response.Octubre = Math.Abs(response.Octubre ?? 0m);
        response.Noviembre = Math.Abs(response.Noviembre ?? 0m);
        response.Diciembre = Math.Abs(response.Diciembre ?? 0m);
    }

    private static void ApplyScope(PagedRequest request, PresupuestoModificadoScope scope)
    {
        request.AdditionalFilters ??= new Dictionary<string, object>();
        request.AdditionalFilters["FkidEmpresaSis"] = scope.EmpresaId;
        request.AdditionalFilters["FkidAnioSis"] = scope.AnioId;
    }

    private async Task<(PresupuestoModificadoScope? Scope, PagedResult<T>? Failure)> TryGetScopeAsync<T>()
    {
        try
        {
            return (await PresupuestoModificadoScopeResolver.RequireAsync(_context, _userContext), null);
        }
        catch (UserVisibleException ex)
        {
            return (null, Failure<T>(ex.UserMessage, ex.Code));
        }
    }

    private static SqlParameter[] BuildParameters(int action, int? id, EgreAdecuacionDetalleResponse? response, int? usuarioActual) =>
        BuildParameters(action, id, response, usuarioActual, response?.FkidEmpresaSis);

    private static SqlParameter[] BuildParameters(int action, int? id, EgreAdecuacionDetalleResponse? response, int? usuarioActual, int? empresaId) =>
    [
        StoredProcedureExecutor.Param("@Action", action),
        StoredProcedureExecutor.Param("@PKIdEgreAdecuacionDetalle", id ?? response?.PkidEgreAdecuacionDetalle),
        StoredProcedureExecutor.Param("@FKIdEgresoAutorizado_PRES", response?.FkidEgresoAutorizadoPres),
        new SqlParameter("@Justificacion", SqlDbType.NVarChar, -1) { Value = response?.Justificacion?.Trim() ?? (object)DBNull.Value },
        StoredProcedureExecutor.Param("@Fecha", response?.Fecha.ToDateTime(TimeOnly.MinValue)),
        StoredProcedureExecutor.Param("@FKIdEgreAdecuacion_PRES", response?.FkidEgreAdecuacionPres),
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
        StoredProcedureExecutor.Param("@IdC", id ?? response?.PkidEgreAdecuacionDetalle),
        StoredProcedureExecutor.Param("@IdUser", usuarioActual),
        StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", empresaId)
    ];

    private new static PagedResult<T> Failure<T>(string message, string code = "VALIDATION") => new()
    {
        Success = false,
        Message = message,
        Code = code,
        TotalCount = 0
    };
}

public class EgresoDisponibleAppService(
    GenericService<VwEgresoDisponible, EgresoDisponibleDto, EgresoDisponibleResponse> service,
    GenericService<VwEgresoDisponible, EgresoDisponibleDto, EgresoDisponibleResponse> serviceView,
    EGestionContext context,
    IUserContextService userContext)
    : AdquisicionCrudAppService<VwEgresoDisponible, VwEgresoDisponible, EgresoDisponibleDto, EgresoDisponibleResponse>(
        service,
        serviceView,
        "PkidEgresoAutorizado",
        "Presupuesto disponible",
        (dto, id) => dto.PkidEgresoAutorizado = id)
{
    private readonly EGestionContext _context = context;
    private readonly IUserContextService _userContext = userContext;

    public override async Task<PagedResult<EgresoDisponibleResponse>> GetAllAsync()
    {
        var (scope, failure) = await TryGetScopeAsync<EgresoDisponibleResponse>();
        if (failure != null) return failure;

        var result = await base.GetAllAsync();
        result.Items = result.Items
            .Where(x => x.FkidEmpresaSis == scope!.Value.EmpresaId && x.FkidAnioSis == scope.Value.AnioId)
            .ToList();
        result.TotalCount = result.Items.Count;
        return result;
    }

    public override async Task<PagedResult<EgresoDisponibleResponse>> GetByIdAsync(int id)
    {
        var (scope, failure) = await TryGetScopeAsync<EgresoDisponibleResponse>();
        if (failure != null) return failure;

        var result = await base.GetByIdAsync(id);
        return result.Success && result.Data is not null &&
               (result.Data.FkidEmpresaSis != scope!.Value.EmpresaId || result.Data.FkidAnioSis != scope.Value.AnioId)
            ? Failure<EgresoDisponibleResponse>("El egreso disponible no pertenece al contexto activo.", "NOT_FOUND")
            : result;
    }

    public override async Task<PagedResult<EgresoDisponibleResponse>> GetAllPaginadoAsync(PagedRequest request)
    {
        var (scope, failure) = await TryGetScopeAsync<EgresoDisponibleResponse>();
        if (failure != null) return failure;

        request.AdditionalFilters ??= new Dictionary<string, object>();
        request.AdditionalFilters["FkidEmpresaSis"] = scope!.Value.EmpresaId;
        request.AdditionalFilters["FkidAnioSis"] = scope.Value.AnioId;
        return await base.GetAllPaginadoAsync(request);
    }

    public override Task<PagedResult<EgresoDisponibleResponse>> CreateAsync(EgresoDisponibleResponse response, int usuarioActual) =>
        Task.FromResult(Failure<EgresoDisponibleResponse>("El presupuesto disponible es solo lectura.", "READ_ONLY"));

    public override Task<PagedResult<EgresoDisponibleResponse>> UpdateAsync(int id, EgresoDisponibleResponse response, int usuarioActual) =>
        Task.FromResult(Failure<EgresoDisponibleResponse>("El presupuesto disponible es solo lectura.", "READ_ONLY"));

    public override Task<PagedResult<bool>> DeleteAsync(int id) =>
        Task.FromResult(Failure<bool>("El presupuesto disponible es solo lectura.", "READ_ONLY"));

    private async Task<(PresupuestoModificadoScope? Scope, PagedResult<T>? Failure)> TryGetScopeAsync<T>()
    {
        try
        {
            return (await PresupuestoModificadoScopeResolver.RequireAsync(_context, _userContext), null);
        }
        catch (UserVisibleException ex)
        {
            return (null, Failure<T>(ex.UserMessage, ex.Code));
        }
    }

    private new static PagedResult<T> Failure<T>(string message, string code) => new()
    {
        Success = false,
        Message = message,
        Code = code,
        TotalCount = 0
    };
}
