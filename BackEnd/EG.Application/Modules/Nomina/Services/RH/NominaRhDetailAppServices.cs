using System.Data;
using System.Text.Json;
using EG.Application.Interfaces.Nomina;
using EG.Business.Services;
using EG.Common;
using EG.Common.Enums;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Nomina;
using EG.Domain.DTOs.Responses.Nomina;
using EG.Infraestructure.Models;
using Mapster;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Nomina;

public abstract class NominaRhDetailAppService<TView, TDto, TResponse>
    : INominaRhDetailAppService<TDto, TResponse>
    where TView : class
    where TDto : NominaRhDetailDtoBase
    where TResponse : NominaRhDetailResponseBase
{
    private readonly GenericService<TView, TDto, TResponse> _service;
    private readonly Logger.Log4NetLogger _logger;

    protected NominaRhDetailAppService(
        GenericService<TView, TDto, TResponse> service,
        EGestionContext context,
        string entityName,
        string idPropertyName,
        string procedureName)
    {
        _service = service;
        Context = context;
        EntityName = entityName;
        IdPropertyName = idPropertyName;
        ProcedureName = procedureName;
        _logger = new Logger.Log4NetLogger(GetType());

        _service.DisableEmpresaFilter();
    }

    protected EGestionContext Context { get; }

    protected string EntityName { get; }

    protected string IdPropertyName { get; }

    protected string ProcedureName { get; }

    protected abstract int GetId(TResponse response);

    protected abstract SqlParameter[] BuildParameters(int action, int? id, TDto dto, int usuarioActual, int? empresaId);

    public Task<PagedResult<TResponse>> GetAllAsync(int? empresaId)
        => Task.FromResult(Failure<TResponse>("Selecciona un empleado para consultar el detalle.", "PERSON_REQUIRED"));

    public async Task<PagedResult<TResponse>> GetByIdAsync(int id, int? empresaId)
    {
        try
        {
            var item = await _service.GetByIdAsync(id, idPropertyName: IdPropertyName);
            if (item == null)
            {
                return Failure<TResponse>($"{EntityName} no encontrado.", "NOT_FOUND");
            }

            if (!await CanAccessPersonaAsync(item.FkidPersonaNom))
            {
                return Failure<TResponse>("No tienes acceso al empleado solicitado.", "FORBIDDEN");
            }

            return Success($"{EntityName} obtenido correctamente.", item, [item], 1);
        }
        catch (Exception ex)
        {
            LogException("obtener por identificador", ex);
            return Failure<TResponse>(UserFacingMessages.OperationFailed($"obtener {EntityName}"));
        }
    }

    public async Task<PagedResult<TResponse>> GetAllPaginadoAsync(PagedRequest request, int? empresaId)
    {
        request ??= new PagedRequest();
        var personaId = ReadIntFilter(request, "PersonaId");
        if (!personaId.HasValue || personaId <= 0)
        {
            return Failure<TResponse>("Selecciona un empleado para consultar el detalle.", "PERSON_REQUIRED");
        }

        if (!await CanAccessPersonaAsync(personaId.Value))
        {
            return Failure<TResponse>("No tienes acceso al empleado solicitado.", "FORBIDDEN");
        }

        try
        {
            request.Page = Math.Max(1, request.Page);
            request.PageSize = Math.Clamp(request.PageSize <= 0 ? 10 : request.PageSize, 1, 2000);
            request.AdditionalFilters ??= new Dictionary<string, object>();
            request.AdditionalFilters.Remove("PersonaId");
            request.AdditionalFilters.Remove("EmpresaId");
            request.AdditionalFilters[nameof(NominaRhDetailResponseBase.FkidPersonaNom)] = personaId.Value;

            var result = await _service.GetAllPaginadoAsync(request);
            result.Message = result.Success
                ? $"{EntityName} obtenidos correctamente."
                : UserFacingMessages.OperationFailed($"obtener {EntityName}");
            result.Code = result.Success ? "SUCCESS" : "ERROR";
            return result;
        }
        catch (Exception ex)
        {
            LogException("obtener paginado", ex);
            return Failure<TResponse>(UserFacingMessages.OperationFailed($"obtener {EntityName}"));
        }
    }

    public async Task<PagedResult<TResponse>> CreateAsync(TDto dto, int usuarioActual, int? empresaId)
    {
        if (!await CanAccessPersonaAsync(dto.FkidPersonaNom))
        {
            return Failure<TResponse>("No tienes acceso al empleado solicitado.", "FORBIDDEN");
        }

        return await SaveAsync(1, null, dto, usuarioActual, empresaId);
    }

    public async Task<PagedResult<TResponse>> UpdateAsync(int id, TDto dto, int usuarioActual, int? empresaId)
    {
        var existing = await GetByIdAsync(id, empresaId);
        if (!existing.Success || existing.Data == null)
        {
            return existing;
        }

        dto.FkidPersonaNom = existing.Data.FkidPersonaNom;
        dto.UsuarioCreacion = existing.Data.UsuarioCreacion;
        dto.FechaCreacion = existing.Data.FechaCreacion;
        return await SaveAsync(2, id, dto, usuarioActual, empresaId);
    }

    public async Task<PagedResult<bool>> DeleteAsync(int id, int usuarioActual, int? empresaId)
    {
        var existing = await GetByIdAsync(id, empresaId);
        if (!existing.Success || existing.Data == null)
        {
            return Failure<bool>(existing.Message, existing.Code);
        }

        try
        {
            var dto = existing.Data.Adapt<TDto>();
            var inheritedEmpresaId = await GetPersonaEmpresaIdAsync(dto.FkidPersonaNom);
            var mutation = await ExecuteMutationAsync(3, id, dto, usuarioActual, inheritedEmpresaId);
            if (!mutation.Success)
            {
                return Failure<bool>(mutation.Message, "SQL_ERROR");
            }

            return new PagedResult<bool>
            {
                Success = true,
                Code = "SUCCESS",
                Message = mutation.Message,
                Data = true,
                Items = [true],
                TotalCount = 1
            };
        }
        catch (Exception ex)
        {
            LogException("eliminar", ex);
            return Failure<bool>(UserFacingMessages.OperationFailed($"eliminar {EntityName}"));
        }
    }

    private async Task<PagedResult<TResponse>> SaveAsync(int action, int? id, TDto dto, int usuarioActual, int? empresaId)
    {
        try
        {
            var inheritedEmpresaId = await GetPersonaEmpresaIdAsync(dto.FkidPersonaNom);
            var mutation = await ExecuteMutationAsync(action, id, dto, usuarioActual, inheritedEmpresaId);
            if (!mutation.Success)
            {
                LogMessage(LogLevelGRP.Warn, mutation.Message, SystemLogTypes.Warning);
                return Failure<TResponse>(mutation.Message, "SQL_ERROR");
            }

            var saved = await GetByIdAsync(mutation.Id, empresaId);
            if (!saved.Success || saved.Data == null)
            {
                return Failure<TResponse>(UserFacingMessages.OperationFailed($"recuperar {EntityName}"));
            }

            saved.Message = mutation.Message;
            return saved;
        }
        catch (Exception ex)
        {
            LogException(action == 1 ? "crear" : "actualizar", ex);
            return Failure<TResponse>(UserFacingMessages.OperationFailed(action == 1 ? $"crear {EntityName}" : $"actualizar {EntityName}"));
        }
    }

    private async Task<MutationResult> ExecuteMutationAsync(int action, int? id, TDto dto, int usuarioActual, int? empresaId)
    {
        await using var command = (SqlCommand)Context.Database.GetDbConnection().CreateCommand();
        command.CommandText = ProcedureName;
        command.CommandType = CommandType.StoredProcedure;
        command.CommandTimeout = 120;
        command.Parameters.AddRange(BuildParameters(action, id, dto, usuarioActual, empresaId));

        var outputId = new SqlParameter("@Id", SqlDbType.Int)
        {
            Direction = ParameterDirection.InputOutput,
            Value = id.HasValue ? id.Value : DBNull.Value
        };
        command.Parameters.Add(outputId);

        var openedHere = command.Connection?.State != ConnectionState.Open;
        if (openedHere)
        {
            await Context.Database.OpenConnectionAsync();
        }

        try
        {
            var rawJson = string.Empty;
            await using var reader = await command.ExecuteReaderAsync();
            if (await reader.ReadAsync() && reader.FieldCount > 0 && !reader.IsDBNull(0))
            {
                rawJson = reader.GetString(0);
            }

            var payload = string.IsNullOrWhiteSpace(rawJson)
                ? null
                : JsonSerializer.Deserialize<StoredProcedureMessage>(rawJson, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            var success = string.Equals(payload?.Tipo, "success", StringComparison.OrdinalIgnoreCase);
            var savedId = outputId.Value == DBNull.Value ? id.GetValueOrDefault() : Convert.ToInt32(outputId.Value);
            return new MutationResult(success, payload?.Mensaje ?? UserFacingMessages.UnexpectedError, savedId);
        }
        finally
        {
            if (openedHere)
            {
                await Context.Database.CloseConnectionAsync();
            }
        }
    }

    private async Task<bool> CanAccessPersonaAsync(int personaId)
    {
        if (personaId <= 0)
        {
            return false;
        }

        return await Context.Personas.AsNoTracking().AnyAsync(persona =>
            persona.PkidPersona == personaId &&
            persona.Activo);
    }

    private Task<int?> GetPersonaEmpresaIdAsync(int personaId)
        => Context.Personas
            .AsNoTracking()
            .Where(persona => persona.PkidPersona == personaId && persona.Activo)
            .Select(persona => (int?)persona.FkidEmpresaSis)
            .FirstOrDefaultAsync();

    protected static int? ReadIntFilter(PagedRequest request, string key)
    {
        if (request.AdditionalFilters == null || !request.AdditionalFilters.TryGetValue(key, out var raw) || raw == null)
        {
            return null;
        }

        return raw switch
        {
            int value => value,
            long value => Convert.ToInt32(value),
            JsonElement json when json.ValueKind == JsonValueKind.Number && json.TryGetInt32(out var value) => value,
            JsonElement json when json.ValueKind == JsonValueKind.String && int.TryParse(json.GetString(), out var value) => value,
            string text when int.TryParse(text, out var value) => value,
            _ => null
        };
    }

    protected static SqlParameter Param(string name, SqlDbType type, object? value, int size = 0)
    {
        var parameter = size > 0 ? new SqlParameter(name, type, size) : new SqlParameter(name, type);
        parameter.Value = value ?? DBNull.Value;
        return parameter;
    }

    protected static SqlParameter DecimalParam(string name, decimal? value, byte precision, byte scale)
        => new(name, SqlDbType.Decimal)
        {
            Precision = precision,
            Scale = scale,
            Value = value.HasValue ? value.Value : DBNull.Value
        };

    private static PagedResult<TResult> Failure<TResult>(string message, string code = "ERROR") => new()
    {
        Success = false,
        Code = code,
        Message = message,
        TotalCount = 0
    };

    private static PagedResult<TResponse> Success(string message, TResponse data, IList<TResponse> items, int totalCount) => new()
    {
        Success = true,
        Code = "SUCCESS",
        Message = message,
        Data = data,
        Items = items,
        TotalCount = totalCount
    };

    private void LogException(string operation, Exception ex)
        => LogMessage(LogLevelGRP.Error, $"Error al {operation} {EntityName}: {ex}", SystemLogTypes.Error);

    private void LogMessage(LogLevelGRP level, string message, SystemLogTypes type)
        => _logger.LogMessage(level, message, (byte)type, GetType().Name, string.Empty, string.Empty);

    private sealed record MutationResult(bool Success, string Message, int Id);

    private sealed class StoredProcedureMessage
    {
        public string Tipo { get; set; } = string.Empty;
        public string Mensaje { get; set; } = string.Empty;
    }
}

public sealed class NominaRhExpedienteAppService(
    GenericService<VwEmpleadoExpediente, NominaRhExpedienteDto, NominaRhExpedienteResponse> service,
    EGestionContext context)
    : NominaRhDetailAppService<VwEmpleadoExpediente, NominaRhExpedienteDto, NominaRhExpedienteResponse>(
        service, context, "expediente", nameof(VwEmpleadoExpediente.PkidExpediente), "[NOM].[SP_MantenimientoEmpleadoExpediente]")
{
    protected override int GetId(NominaRhExpedienteResponse response) => response.PkidExpediente;

    protected override SqlParameter[] BuildParameters(int action, int? id, NominaRhExpedienteDto dto, int usuarioActual, int? empresaId) =>
    [
        Param("@Action", SqlDbType.Int, action),
        Param("@PKIdExpediente", SqlDbType.Int, id),
        Param("@FKIdPersona_NOM", SqlDbType.Int, dto.FkidPersonaNom),
        Param("@NombreDocumento", SqlDbType.NVarChar, dto.NombreDocumento?.Trim(), 255),
        Param("@Ruta", SqlDbType.NVarChar, dto.Ruta?.Trim(), 1000),
        Param("@Descripcion", SqlDbType.NVarChar, dto.Descripcion?.Trim(), 1000),
        Param("@FechaExpedicion", SqlDbType.Date, dto.FechaExpedicion),
        Param("@NecesitaRenovacion", SqlDbType.Bit, dto.NecesitaRenovacion),
        Param("@FechaRenovacion", SqlDbType.Date, dto.FechaRenovacion),
        Param("@FKIdTipoExpediente_NOM", SqlDbType.Int, dto.FkidTipoExpedienteNom),
        Param("@Activo", SqlDbType.Bit, dto.Activo),
        Param("@IdUser", SqlDbType.Int, usuarioActual)
    ];
}

public sealed class NominaRhContratoAppService(
    GenericService<VwContratoLaboralDetalle, NominaRhContratoDto, NominaRhContratoResponse> service,
    EGestionContext context)
    : NominaRhDetailAppService<VwContratoLaboralDetalle, NominaRhContratoDto, NominaRhContratoResponse>(
        service, context, "contrato laboral", nameof(VwContratoLaboralDetalle.PkidContratoLaboral), "[NOM].[SP_MantenimientoContratoLaboral]")
{
    protected override int GetId(NominaRhContratoResponse response) => response.PkidContratoLaboral;

    protected override SqlParameter[] BuildParameters(int action, int? id, NominaRhContratoDto dto, int usuarioActual, int? empresaId) =>
    [
        Param("@Action", SqlDbType.Int, action),
        Param("@PKIdContratoLaboral", SqlDbType.Int, id),
        Param("@FKIdEmpresaNomina_NOM", SqlDbType.Int, empresaId is > 0 ? empresaId : dto.FkidEmpresaNominaNom),
        Param("@FKIdPersona_NOM", SqlDbType.Int, dto.FkidPersonaNom),
        Param("@FechaInicio", SqlDbType.Date, dto.FechaInicio),
        Param("@FechaFin", SqlDbType.Date, dto.FechaFin),
        Param("@FKIdPuesto_NOM", SqlDbType.Int, dto.FkidPuestoNom),
        Param("@NumeroContrato", SqlDbType.NVarChar, dto.NumeroContrato?.Trim(), 20),
        Param("@Vigencia", SqlDbType.NVarChar, dto.Vigencia?.Trim(), 100),
        DecimalParam("@SueldoMensual", dto.SueldoMensual, 18, 2),
        Param("@FKIdNombramiento_NOM", SqlDbType.Int, dto.FkidNombramientoNom),
        Param("@FKIdDepartamento_SIS", SqlDbType.Int, dto.FkidDepartamentoSis),
        Param("@FKIdTipoContratacion_SIS", SqlDbType.Int, dto.FkidTipoContratacionSis),
        Param("@Departamento", SqlDbType.NVarChar, dto.Departamento?.Trim(), 200),
        Param("@TipoContratacion", SqlDbType.NVarChar, dto.TipoContratacion?.Trim(), 200),
        Param("@Activo", SqlDbType.Bit, dto.Activo),
        Param("@IdUser", SqlDbType.Int, usuarioActual)
    ];
}

public sealed class NominaRhDependienteAppService(
    GenericService<VwPersonaDependiente, NominaRhDependienteDto, NominaRhDependienteResponse> service,
    EGestionContext context)
    : NominaRhDetailAppService<VwPersonaDependiente, NominaRhDependienteDto, NominaRhDependienteResponse>(
        service, context, "dependiente", nameof(VwPersonaDependiente.PkidDependiente), "[NOM].[SP_MantenimientoPersonaDependiente]")
{
    protected override int GetId(NominaRhDependienteResponse response) => response.PkidDependiente;

    protected override SqlParameter[] BuildParameters(int action, int? id, NominaRhDependienteDto dto, int usuarioActual, int? empresaId) =>
    [
        Param("@Action", SqlDbType.Int, action),
        Param("@PKIdDependiente", SqlDbType.Int, id),
        Param("@FKIdPersona_NOM", SqlDbType.Int, dto.FkidPersonaNom),
        Param("@Nombre", SqlDbType.NVarChar, dto.Nombre?.Trim(), 300),
        Param("@FKIdParentesco_SIS", SqlDbType.Int, dto.FkidParentescoSis),
        Param("@Parentesco", SqlDbType.NVarChar, dto.Parentesco?.Trim(), 120),
        Param("@FechaNacimiento", SqlDbType.Date, dto.FechaNacimiento),
        Param("@Activo", SqlDbType.Bit, dto.Activo),
        Param("@IdUser", SqlDbType.Int, usuarioActual)
    ];
}

public sealed class NominaRhIncidenciaAppService(
    GenericService<VwIncidencium, NominaRhIncidenciaDto, NominaRhIncidenciaResponse> service,
    EGestionContext context)
    : NominaRhDetailAppService<VwIncidencium, NominaRhIncidenciaDto, NominaRhIncidenciaResponse>(
        service, context, "incidencia", nameof(VwIncidencium.PkidIncidencia), "[NOM].[SP_MantenimientoIncidencia]")
{
    protected override int GetId(NominaRhIncidenciaResponse response) => response.PkidIncidencia;

    protected override SqlParameter[] BuildParameters(int action, int? id, NominaRhIncidenciaDto dto, int usuarioActual, int? empresaId) =>
    [
        Param("@Action", SqlDbType.Int, action),
        Param("@PKIdIncidencia", SqlDbType.Int, id),
        Param("@FKIdPersona_NOM", SqlDbType.Int, dto.FkidPersonaNom),
        Param("@FKIdTipoIncidencia_NOM", SqlDbType.Int, dto.FkidTipoIncidenciaNom),
        Param("@Fecha", SqlDbType.Date, dto.Fecha),
        Param("@Comentario", SqlDbType.NVarChar, dto.Comentario?.Trim(), 1000),
        Param("@FKIdTipoJustificacion_NOM", SqlDbType.Int, dto.FkidTipoJustificacionNom),
        Param("@AplicaDescuento", SqlDbType.Bit, dto.AplicaDescuento),
        Param("@ComentarioJustificacion", SqlDbType.NVarChar, dto.ComentarioJustificacion?.Trim(), 1000),
        Param("@FKIdPeriodoQuincenal_SIS", SqlDbType.Int, dto.FkidPeriodoQuincenalSis),
        Param("@Activo", SqlDbType.Bit, dto.Activo),
        Param("@IdUser", SqlDbType.Int, usuarioActual)
    ];
}

public sealed class NominaRhPensionAppService(
    GenericService<VwPersonaPension, NominaRhPensionDto, NominaRhPensionResponse> service,
    EGestionContext context)
    : NominaRhDetailAppService<VwPersonaPension, NominaRhPensionDto, NominaRhPensionResponse>(
        service, context, "pension", nameof(VwPersonaPension.PkidPension), "[NOM].[SP_MantenimientoPersonaPension]")
{
    protected override int GetId(NominaRhPensionResponse response) => response.PkidPension;

    protected override SqlParameter[] BuildParameters(int action, int? id, NominaRhPensionDto dto, int usuarioActual, int? empresaId) =>
    [
        Param("@Action", SqlDbType.Int, action),
        Param("@PKIdPension", SqlDbType.Int, id),
        Param("@FKIdPersona_NOM", SqlDbType.Int, dto.FkidPersonaNom),
        Param("@NombreBeneficiario", SqlDbType.NVarChar, dto.NombreBeneficiario?.Trim(), 150),
        Param("@Documento", SqlDbType.NVarChar, dto.Documento?.Trim(), 50),
        Param("@FechaDocumento", SqlDbType.Date, dto.FechaDocumento),
        DecimalParam("@Porcentaje", dto.Porcentaje, 9, 4),
        Param("@FKIdTipoPension_NOM", SqlDbType.Int, dto.FkidTipoPensionNom),
        Param("@FechaInicio", SqlDbType.DateTime2, dto.FechaInicio),
        Param("@FechaFin", SqlDbType.DateTime2, dto.FechaFin),
        Param("@Banco", SqlDbType.NVarChar, dto.Banco?.Trim(), 100),
        Param("@CuentaBancaria", SqlDbType.NVarChar, dto.CuentaBancaria?.Trim(), 100),
        Param("@Clabe", SqlDbType.NVarChar, dto.Clabe?.Trim(), 100),
        Param("@FormaPago", SqlDbType.NVarChar, dto.FormaPago?.Trim(), 100),
        Param("@FKIdCuentaContable_SIS", SqlDbType.Int, dto.FkidCuentaContableSis),
        Param("@Activo", SqlDbType.Bit, dto.Activo),
        Param("@IdUser", SqlDbType.Int, usuarioActual)
    ];
}

public sealed class NominaRhLookupAppService(EGestionContext context) : INominaRhLookupAppService
{
    private readonly EGestionContext _context = context;
    private readonly Logger.Log4NetLogger _logger = new(typeof(NominaRhLookupAppService));

    public async Task<PagedResult<NominaRhLookupResponse>> GetAllPaginadoAsync(PagedRequest request, int? empresaId)
    {
        request ??= new PagedRequest();
        var catalogo = ReadTextFilter(request, "Catalogo");

        try
        {
            var query = BuildQuery(catalogo, empresaId);
            var filter = (request.Filtro ?? request.SearchString ?? string.Empty).Trim();
            if (!string.IsNullOrWhiteSpace(filter))
            {
                query = query.Where(item => item.Clave.Contains(filter) || item.Descripcion.Contains(filter));
            }

            var total = await query.CountAsync();
            var page = Math.Max(1, request.Page);
            var pageSize = Math.Clamp(request.PageSize <= 0 ? 25 : request.PageSize, 1, 500);
            var items = await query
                .OrderBy(item => item.Descripcion)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return new PagedResult<NominaRhLookupResponse>
            {
                Success = true,
                Code = "SUCCESS",
                Message = "Catalogo obtenido correctamente.",
                Items = items,
                TotalCount = total
            };
        }
        catch (Exception ex)
        {
            _logger.LogMessage(LogLevelGRP.Error, $"Error al obtener catalogo RH {catalogo}: {ex}", (byte)SystemLogTypes.Error, nameof(NominaRhLookupAppService), string.Empty, string.Empty);
            return new PagedResult<NominaRhLookupResponse>
            {
                Success = false,
                Code = "ERROR",
                Message = UserFacingMessages.OperationFailed("obtener catalogo RH"),
                TotalCount = 0
            };
        }
    }

    private IQueryable<NominaRhLookupResponse> BuildQuery(string catalogo, int? empresaId)
    {
        var simpleCatalog = catalogo switch
        {
            "Sexo" => "Sexo",
            "EstadoCivil" => "Estado_Civil",
            "TipoContratacion" => "Tipo_Contratacion",
            "TipoExpediente" => "Tipo_Expediente",
            "TipoIncidencia" => "Tipo_Incidencia",
            "TipoJustificacion" => "Tipo_Justificacion",
            "Parentesco" => "Tipo_Parentesco",
            "Banco" => "Banco",
            "FormaPago" => "Metodo_Pago",
            _ => string.Empty
        };

        if (!string.IsNullOrWhiteSpace(simpleCatalog))
        {
            return _context.CatalogoSimples.AsNoTracking()
                .Where(item => item.Activo && item.Catalogo == simpleCatalog)
                .Select(item => new NominaRhLookupResponse
                {
                    Id = item.PkidCatalogoSimple,
                    Catalogo = catalogo,
                    Clave = item.Clave ?? string.Empty,
                    Descripcion = item.Descripcion,
                    Activo = item.Activo
                });
        }

        return catalogo switch
        {
            "Puesto" => _context.Puestos.AsNoTracking()
                .Where(item => item.Activo && (!empresaId.HasValue || empresaId <= 0 || item.FkidEmpresaSis == empresaId))
                .Select(item => new NominaRhLookupResponse { Id = item.PkidPuesto, Catalogo = catalogo, Clave = item.PkidPuesto.ToString(), Descripcion = item.Nombre, Activo = item.Activo }),
            "Nombramiento" => _context.Nombramientos.AsNoTracking()
                .Where(item => item.Activo)
                .Select(item => new NominaRhLookupResponse { Id = item.PkidNombramiento, Catalogo = catalogo, Clave = item.PkidNombramiento.ToString(), Descripcion = item.Descripcion, Activo = item.Activo }),
            "Departamento" => _context.Departamentos.AsNoTracking()
                .Where(item => item.Activo && (!empresaId.HasValue || empresaId <= 0 || item.FkidEmpresaSis == empresaId))
                .Select(item => new NominaRhLookupResponse { Id = item.PkidDepartamento, Catalogo = catalogo, Clave = item.PkidDepartamento.ToString(), Descripcion = item.Nombre, Activo = item.Activo }),
            "TipoPension" => _context.TipoPensions.AsNoTracking()
                .Where(item => item.Activo)
                .Select(item => new NominaRhLookupResponse { Id = item.PkidTipoPension, Catalogo = catalogo, Clave = item.PkidTipoPension.ToString(), Descripcion = item.Descripcion, Activo = item.Activo }),
            "CuentaContable" => _context.CuentaContables.AsNoTracking()
                .Where(item => item.Activo && (!empresaId.HasValue || empresaId <= 0 || item.FkidEmpresaSis == empresaId))
                .Select(item => new NominaRhLookupResponse { Id = item.PkidCuentaContable, Catalogo = catalogo, Clave = item.Cuenta, Descripcion = item.Descripcion, Activo = item.Activo }),
            "PeriodoQuincenal" => _context.PeriodoNominas.AsNoTracking()
                .Where(item => item.Activo && item.LegacyTable == "SIS_PeriodoQuincenal" && (!empresaId.HasValue || empresaId <= 0 || item.FkidEmpresaSis == null || item.FkidEmpresaSis == empresaId))
                .Select(item => new NominaRhLookupResponse { Id = item.LegacyId, Catalogo = catalogo, Clave = item.LegacyId.ToString(), Descripcion = item.TipoPeriodo + " " + item.Anio + "/" + item.Periodo, Activo = item.Activo }),
            _ => _context.CatalogoSimples.AsNoTracking().Where(_ => false)
                .Select(item => new NominaRhLookupResponse { Id = item.PkidCatalogoSimple, Catalogo = catalogo, Clave = string.Empty, Descripcion = item.Descripcion, Activo = item.Activo })
        };
    }

    private static string ReadTextFilter(PagedRequest request, string key)
    {
        if (request.AdditionalFilters == null || !request.AdditionalFilters.TryGetValue(key, out var raw) || raw == null)
        {
            return string.Empty;
        }

        return raw switch
        {
            string text => text.Trim(),
            JsonElement json when json.ValueKind == JsonValueKind.String => (json.GetString() ?? string.Empty).Trim(),
            _ => Convert.ToString(raw)?.Trim() ?? string.Empty
        };
    }
}
