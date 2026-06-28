using System.Data;
using System.Text.Json;
using EG.Application.Interfaces.Nomina;
using EG.Common;
using EG.Common.Enums;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Nomina;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Nomina
{
    public class NominaOperacionAppService(EGestionContext context) : INominaOperacionAppService
    {
        private readonly EGestionContext _context = context;
        private readonly Logger.Log4NetLogger _logger = new(typeof(NominaOperacionAppService));

        private const string VacacionesModule = "Vacaciones";
        private const string SolicitudVacacionesSubModule = "Solicitud_Vacaciones";
        private const string AutorizacionVacacionesSubModule = "Autorizacion_Vacaciones";

        public async Task<PagedResult<NominaOperacionResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            request ??= new PagedRequest();

            try
            {
                var operacion = ReadFilter(request, "Operacion");
                var page = request.Page <= 0 ? 1 : request.Page;
                var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;
                var filtro = request.Filtro ?? request.SearchString ?? string.Empty;
                var sortLabel = string.IsNullOrWhiteSpace(request.SortLabel) ? "Fecha" : request.SortLabel;
                var sortDirection = string.IsNullOrWhiteSpace(request.SortDirection) ? "Descending" : request.SortDirection;

                await using var command = _context.Database.GetDbConnection().CreateCommand();
                command.CommandText = "[NOM].[spOperacionNomina_List]";
                command.CommandType = CommandType.StoredProcedure;
                command.CommandTimeout = 120;
                command.Parameters.Add(new SqlParameter("@Operacion", SqlDbType.NVarChar, 80) { Value = operacion });
                command.Parameters.Add(new SqlParameter("@Page", SqlDbType.Int) { Value = page });
                command.Parameters.Add(new SqlParameter("@PageSize", SqlDbType.Int) { Value = pageSize });
                command.Parameters.Add(new SqlParameter("@Filtro", SqlDbType.NVarChar, 250) { Value = filtro });
                command.Parameters.Add(new SqlParameter("@SortLabel", SqlDbType.NVarChar, 80) { Value = sortLabel });
                command.Parameters.Add(new SqlParameter("@SortDirection", SqlDbType.NVarChar, 20) { Value = sortDirection });

                if (command.Connection?.State != ConnectionState.Open)
                {
                    await _context.Database.OpenConnectionAsync();
                }

                var items = new List<NominaOperacionResponse>();
                var totalCount = 0;

                await using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    var item = Map(reader);
                    totalCount = item.TotalCount;
                    items.Add(item);
                }

                return new PagedResult<NominaOperacionResponse>
                {
                    Success = true,
                    Code = "SUCCESS",
                    Message = "Operaciones de nomina obtenidas correctamente",
                    Items = items,
                    TotalCount = totalCount
                };
            }
            catch (Exception ex)
            {
                _logger.LogMessage(
                    LogLevelGRP.Error,
                    $"Error al obtener operaciones de nomina: {ex}",
                    (byte)SystemLogTypes.Error,
                    nameof(NominaOperacionAppService),
                    string.Empty,
                    string.Empty);

                return new PagedResult<NominaOperacionResponse>
                {
                    Success = false,
                    Code = "ERROR",
                    Message = UserFacingMessages.OperationFailed("obtener operaciones de nomina"),
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<NominaOperacionResponse>> EnviarVacacionAAutorizarAsync(int id, int usuarioId)
        {
            if (id <= 0)
            {
                return Failure("La solicitud de vacaciones no es valida.", "INVALID_ID");
            }

            try
            {
                await EnsureVacacionWorkflowSchemaAsync();

                var current = await _context.Vacacions
                    .AsNoTracking()
                    .Where(x => x.PkidVacacion == id && x.Activo)
                    .Select(x => new { x.PkidVacacion, x.Validado })
                    .FirstOrDefaultAsync();

                if (current == null)
                {
                    return Failure("La solicitud de vacaciones no existe o esta inactiva.", "NOT_FOUND");
                }

                if (current.Validado == 1)
                {
                    return Failure("La solicitud de vacaciones ya esta autorizada.", "ALREADY_AUTHORIZED");
                }

                await _context.Database.ExecuteSqlInterpolatedAsync($@"
UPDATE [NOM].[Vacacion]
SET [EnviadoAAutorizar] = 1,
    [FechaEnvioAutorizacion] = COALESCE([FechaEnvioAutorizacion], SYSUTCDATETIME()),
    [UsuarioEnvioAutorizacion] = COALESCE([UsuarioEnvioAutorizacion], {usuarioId}),
    [UsuarioModificacion] = {usuarioId},
    [FechaModificacion] = SYSUTCDATETIME()
WHERE [PKIdVacacion] = {id}
  AND [Activo] = 1
  AND ISNULL([Validado], 0) <> 1;");

                await TryNotifyVacationAuthorizationRequestedAsync(id, usuarioId);

                return Success("Solicitud enviada a autorizacion. Se notifico a los responsables disponibles.");
            }
            catch (Exception ex)
            {
                LogError($"Error al enviar vacaciones a autorizacion: {ex}");
                return Failure(UserFacingMessages.OperationFailed("enviar la solicitud de vacaciones a autorizacion"));
            }
        }

        public async Task<PagedResult<NominaOperacionResponse>> AutorizarVacacionAsync(int id, int usuarioId)
        {
            if (id <= 0)
            {
                return Failure("La solicitud de vacaciones no es valida.", "INVALID_ID");
            }

            try
            {
                await EnsureVacacionWorkflowSchemaAsync();

                var current = await _context.Vacacions
                    .AsNoTracking()
                    .Where(x => x.PkidVacacion == id && x.Activo)
                    .Select(x => new { x.PkidVacacion, x.Validado })
                    .FirstOrDefaultAsync();

                if (current == null)
                {
                    return Failure("La solicitud de vacaciones no existe o esta inactiva.", "NOT_FOUND");
                }

                if (current.Validado == 1)
                {
                    return Failure("La solicitud de vacaciones ya esta autorizada.", "ALREADY_AUTHORIZED");
                }

                var usuarioEnvio = await ReadNullableIntAsync(
                    "SELECT TOP (1) [UsuarioEnvioAutorizacion] FROM [NOM].[Vacacion] WHERE [PKIdVacacion] = @Id;",
                    new SqlParameter("@Id", SqlDbType.Int) { Value = id });

                var affected = await _context.Database.ExecuteSqlInterpolatedAsync($@"
UPDATE [NOM].[Vacacion]
SET [Validado] = 1,
    [EnviadoAAutorizar] = 1,
    [FechaEnvioAutorizacion] = COALESCE([FechaEnvioAutorizacion], SYSUTCDATETIME()),
    [UsuarioEnvioAutorizacion] = COALESCE([UsuarioEnvioAutorizacion], {usuarioId}),
    [FechaAutorizacion] = SYSUTCDATETIME(),
    [UsuarioAutorizacion] = {usuarioId},
    [UsuarioModificacion] = {usuarioId},
    [FechaModificacion] = SYSUTCDATETIME()
WHERE [PKIdVacacion] = {id}
  AND [Activo] = 1
  AND ISNULL([Validado], 0) <> 1;");

                if (affected <= 0)
                {
                    return Failure("No fue posible autorizar la solicitud de vacaciones.", "NOT_UPDATED");
                }

                await TryNotifyVacationAuthorizedAsync(id, usuarioId, usuarioEnvio);

                return Success("Solicitud de vacaciones autorizada correctamente.");
            }
            catch (Exception ex)
            {
                LogError($"Error al autorizar vacaciones: {ex}");
                return Failure(UserFacingMessages.OperationFailed("autorizar la solicitud de vacaciones"));
            }
        }

        private static string ReadFilter(PagedRequest request, string key)
        {
            if (request.AdditionalFilters == null ||
                !request.AdditionalFilters.TryGetValue(key, out var value) ||
                value == null)
            {
                return string.Empty;
            }

            return value switch
            {
                string text => text.Trim(),
                JsonElement json when json.ValueKind == JsonValueKind.String => (json.GetString() ?? string.Empty).Trim(),
                JsonElement json when json.ValueKind == JsonValueKind.Number => json.GetRawText(),
                _ => Convert.ToString(value)?.Trim() ?? string.Empty
            };
        }

        private async Task EnsureVacacionWorkflowSchemaAsync()
        {
            await _context.Database.ExecuteSqlRawAsync(@"
IF OBJECT_ID(N'[NOM].[Vacacion]', N'U') IS NOT NULL AND COL_LENGTH(N'NOM.Vacacion', N'EnviadoAAutorizar') IS NULL
    ALTER TABLE [NOM].[Vacacion] ADD [EnviadoAAutorizar] bit NOT NULL CONSTRAINT [DF_NOM_Vacacion_EnviadoAAutorizar] DEFAULT 0;
IF OBJECT_ID(N'[NOM].[Vacacion]', N'U') IS NOT NULL AND COL_LENGTH(N'NOM.Vacacion', N'FechaEnvioAutorizacion') IS NULL
    ALTER TABLE [NOM].[Vacacion] ADD [FechaEnvioAutorizacion] datetime2(6) NULL;
IF OBJECT_ID(N'[NOM].[Vacacion]', N'U') IS NOT NULL AND COL_LENGTH(N'NOM.Vacacion', N'UsuarioEnvioAutorizacion') IS NULL
    ALTER TABLE [NOM].[Vacacion] ADD [UsuarioEnvioAutorizacion] int NULL;
IF OBJECT_ID(N'[NOM].[Vacacion]', N'U') IS NOT NULL AND COL_LENGTH(N'NOM.Vacacion', N'FechaAutorizacion') IS NULL
    ALTER TABLE [NOM].[Vacacion] ADD [FechaAutorizacion] datetime2(6) NULL;
IF OBJECT_ID(N'[NOM].[Vacacion]', N'U') IS NOT NULL AND COL_LENGTH(N'NOM.Vacacion', N'UsuarioAutorizacion') IS NULL
    ALTER TABLE [NOM].[Vacacion] ADD [UsuarioAutorizacion] int NULL;
IF OBJECT_ID(N'[NOM].[Vacacion]', N'U') IS NOT NULL AND COL_LENGTH(N'NOM.Vacacion', N'ComentarioAutorizacion') IS NULL
    ALTER TABLE [NOM].[Vacacion] ADD [ComentarioAutorizacion] nvarchar(500) NULL;");
        }

        private async Task TryNotifyVacationAuthorizationRequestedAsync(int id, int usuarioId)
        {
            try
            {
                var idNotificacion = new OutputParameter<long?>();
                await _context.Procedures.sp_NotificacionCrearPorPermisoAsync(
                    claveTipo: "AUTORIZACION_SOLICITADA",
                    fk_IdUsuarioOrigen: usuarioId,
                    modulo: VacacionesModule,
                    subModulo: AutorizacionVacacionesSubModule,
                    accion: "update",
                    evento: "Envio a autorizacion",
                    entidad: "NOM.Vacacion",
                    fk_IdEntidad: id,
                    titulo: $"Vacaciones por autorizar #{id}",
                    mensaje: "Se envio una solicitud de vacaciones para autorizacion.",
                    url: "/sis/autorizacionvacaciones",
                    jsonData: null,
                    idUser: usuarioId,
                    idNotificacion: idNotificacion);
            }
            catch (Exception ex)
            {
                LogWarn($"No se pudo crear notificacion de envio de vacaciones #{id}: {ex.Message}");
            }
        }

        private async Task TryNotifyVacationAuthorizedAsync(int id, int usuarioId, int? usuarioEnvio)
        {
            if (!usuarioEnvio.HasValue || usuarioEnvio.Value <= 0 || usuarioEnvio.Value == usuarioId)
            {
                return;
            }

            try
            {
                var usuarios = new DataTable();
                usuarios.Columns.Add("Fk_IdUsuarioDestino", typeof(int));
                usuarios.Rows.Add(usuarioEnvio.Value);

                var idNotificacion = new OutputParameter<long?>();
                await _context.Procedures.sp_NotificacionCrearAsync(
                    claveTipo: "AUTORIZACION_REALIZADA",
                    fk_IdUsuarioOrigen: usuarioId,
                    modulo: VacacionesModule,
                    subModulo: SolicitudVacacionesSubModule,
                    evento: "Autorizacion",
                    entidad: "NOM.Vacacion",
                    fk_IdEntidad: id,
                    titulo: $"Vacaciones autorizadas #{id}",
                    mensaje: "Tu solicitud de vacaciones fue autorizada.",
                    url: "/sis/solicitudvacaciones",
                    jsonData: null,
                    usuarios: usuarios,
                    idUser: usuarioId,
                    idNotificacion: idNotificacion);
            }
            catch (Exception ex)
            {
                LogWarn($"No se pudo crear notificacion de autorizacion de vacaciones #{id}: {ex.Message}");
            }
        }

        private async Task<int?> ReadNullableIntAsync(string sql, params SqlParameter[] parameters)
        {
            await using var command = _context.Database.GetDbConnection().CreateCommand();
            command.CommandText = sql;
            command.CommandType = CommandType.Text;
            foreach (var parameter in parameters)
            {
                command.Parameters.Add(parameter);
            }

            if (command.Connection?.State != ConnectionState.Open)
            {
                await _context.Database.OpenConnectionAsync();
            }

            var value = await command.ExecuteScalarAsync();
            return value == null || value == DBNull.Value ? null : Convert.ToInt32(value);
        }

        private void LogError(string message)
            => _logger.LogMessage(LogLevelGRP.Error, message, (byte)SystemLogTypes.Error, nameof(NominaOperacionAppService), string.Empty, string.Empty);

        private void LogWarn(string message)
            => _logger.LogMessage(LogLevelGRP.Warn, message, (byte)SystemLogTypes.Warning, nameof(NominaOperacionAppService), string.Empty, string.Empty);

        private static PagedResult<NominaOperacionResponse> Success(string message)
            => new()
            {
                Success = true,
                Code = "SUCCESS",
                Message = message,
                Items = new List<NominaOperacionResponse>(),
                TotalCount = 0
            };

        private static PagedResult<NominaOperacionResponse> Failure(string message, string code = "ERROR")
            => new()
            {
                Success = false,
                Code = code,
                Message = message,
                Items = new List<NominaOperacionResponse>(),
                TotalCount = 0
            };

        private static NominaOperacionResponse Map(IDataRecord reader)
            => new()
            {
                Operacion = GetString(reader, "Operacion"),
                Id = GetInt(reader, "Id"),
                Clave = GetString(reader, "Clave"),
                Persona = GetString(reader, "Persona"),
                Empleado = GetString(reader, "Empleado"),
                Empresa = GetString(reader, "Empresa"),
                Periodo = GetString(reader, "Periodo"),
                Tipo = GetString(reader, "Tipo"),
                Estatus = GetString(reader, "Estatus"),
                Fecha = GetNullableDateTime(reader, "Fecha"),
                FechaInicio = GetNullableDateTime(reader, "FechaInicio"),
                FechaFin = GetNullableDateTime(reader, "FechaFin"),
                Importe = GetNullableDecimal(reader, "Importe"),
                Percepcion = GetNullableDecimal(reader, "Percepcion"),
                Deduccion = GetNullableDecimal(reader, "Deduccion"),
                Neto = GetNullableDecimal(reader, "Neto"),
                Documento = GetString(reader, "Documento"),
                Descripcion = GetString(reader, "Descripcion"),
                Comentario = GetString(reader, "Comentario"),
                Observaciones = GetString(reader, "Observaciones"),
                Activo = GetBool(reader, "Activo"),
                TotalCount = GetInt(reader, "TotalCount")
            };

        private static string GetString(IDataRecord reader, string name)
            => reader[name] == DBNull.Value ? string.Empty : Convert.ToString(reader[name]) ?? string.Empty;

        private static int GetInt(IDataRecord reader, string name)
            => reader[name] == DBNull.Value ? 0 : Convert.ToInt32(reader[name]);

        private static bool GetBool(IDataRecord reader, string name)
            => reader[name] != DBNull.Value && Convert.ToBoolean(reader[name]);

        private static DateTime? GetNullableDateTime(IDataRecord reader, string name)
            => reader[name] == DBNull.Value ? null : Convert.ToDateTime(reader[name]);

        private static decimal? GetNullableDecimal(IDataRecord reader, string name)
            => reader[name] == DBNull.Value ? null : Convert.ToDecimal(reader[name]);
    }
}
