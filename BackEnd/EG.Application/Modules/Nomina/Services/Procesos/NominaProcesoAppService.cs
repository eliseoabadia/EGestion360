using System.Data;
using EG.Application.Interfaces.Nomina;
using EG.Common;
using EG.Common.Enums;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Nomina;
using EG.Domain.DTOs.Responses.Nomina;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Nomina
{
    public class NominaProcesoAppService(EGestionContext context) : INominaProcesoAppService
    {
        private const string NominaSchema = "NOM";
        private readonly Logger.Log4NetLogger _logger = new(typeof(NominaProcesoAppService));
        private readonly EGestionContext _context = context;

        public Task<PagedResult<NominaProcesoResponse>> CalcularNominaAsync(NominaProcesoRequest request, int usuarioActual)
            => ExecuteProcesoAsync("Calcular nomina", "spProcesoNomina_Calcular", "NOM_SP_Nomina", request, usuarioActual, fallbackToDemo: true);

        public Task<PagedResult<NominaProcesoResponse>> CerrarPeriodoAsync(NominaProcesoRequest request, int usuarioActual)
            => ExecuteProcesoAsync("Cerrar periodo", "spProcesoNomina_CerrarPeriodo", "NOM_SP_CierraPeriodo", request, usuarioActual);

        public Task<PagedResult<NominaProcesoResponse>> CalcularAguinaldoAsync(NominaProcesoRequest request, int usuarioActual)
            => ExecuteProcesoAsync("Calcular aguinaldo", "spProcesoNomina_CalcularAguinaldo", "NOM_SP_CalculaAguinaldo", request, usuarioActual);

        public Task<PagedResult<NominaProcesoResponse>> CalcularPrimaVacacionalIndividualAsync(NominaProcesoRequest request, int usuarioActual)
            => ExecuteProcesoAsync("Calcular prima vacacional individual", "spProcesoNomina_PrimaVacacionalIndividual", "NOM_SP_PrimaVac_Ind", request, usuarioActual);

        public Task<PagedResult<NominaProcesoResponse>> CrearComprometidoNominaAsync(NominaProcesoRequest request, int usuarioActual)
            => ExecuteProcesoAsync("Crear comprometido de nomina", "spProcesoNomina_CrearComprometido", "PRES_SP_CREATE_Comprometido_Nomina", request, usuarioActual);

        public Task<PagedResult<NominaProcesoResponse>> CrearDevengadoNominaAsync(NominaProcesoRequest request, int usuarioActual)
            => ExecuteProcesoAsync("Crear devengado de nomina", "spProcesoNomina_CrearDevengado", "PRES_SP_CREATE_Devengado_Nomina", request, usuarioActual);

        public Task<PagedResult<NominaProcesoResponse>> CrearEjercidoNominaAsync(NominaProcesoRequest request, int usuarioActual)
            => ExecuteProcesoAsync("Crear ejercido de nomina", "spProcesoNomina_CrearEjercido", "PRES_SP_CREATE_Ejercido_Nomina", request, usuarioActual);

        private async Task<PagedResult<NominaProcesoResponse>> ExecuteProcesoAsync(
            string processName,
            string storedProcedure,
            string legacyStoredProcedure,
            NominaProcesoRequest request,
            int usuarioActual,
            bool fallbackToDemo = false)
        {
            request ??= new NominaProcesoRequest();

            try
            {
                if (!await StoredProcedureExistsAsync(storedProcedure))
                {
                    if (fallbackToDemo)
                    {
                        return await EjecutarCorridaDemoAsync(request, usuarioActual);
                    }

                    return await MissingStoredProcedureAsync(
                        processName,
                        $"[{NominaSchema}].[{storedProcedure}] / {legacyStoredProcedure}",
                        request,
                        usuarioActual);
                }

                return await ExecuteStoredProcedureAsync(processName, storedProcedure, request, usuarioActual);
            }
            catch (Exception ex)
            {
                _logger.LogMessage(
                    LogLevelGRP.Error,
                    $"Error al ejecutar proceso de nomina {processName} con SP {NominaSchema}.{storedProcedure}: {ex}",
                    (byte)SystemLogTypes.Error,
                    nameof(NominaProcesoAppService),
                    string.Empty,
                    string.Empty);

                var response = new NominaProcesoResponse
                {
                    Proceso = processName,
                    Codigo = "ERROR",
                    Ejecutado = false,
                    FechaIntento = DateTime.Now,
                    Mensaje = UserFacingMessages.OperationFailed($"ejecutar {processName.ToLowerInvariant()}")
                };

                return BuildResult(response, success: false);
            }
        }

        private Task<PagedResult<NominaProcesoResponse>> MissingStoredProcedureAsync(
            string processName,
            string storedProcedure,
            NominaProcesoRequest request,
            int usuarioActual)
        {
            request ??= new NominaProcesoRequest();
            var technicalMessage =
                $"Proceso de Nomina no habilitado. Falta migrar/configurar SP {storedProcedure}. " +
                $"Usuario={usuarioActual}, EmpresaId={request.EmpresaId}, PeriodoId={request.PeriodoId}, " +
                $"PersonaId={request.PersonaId}, Anio={request.Anio}, FechaProceso={request.FechaProceso:O}.";

            _logger.LogMessage(
                LogLevelGRP.Warn,
                technicalMessage,
                (byte)SystemLogTypes.Warning,
                nameof(NominaProcesoAppService),
                string.Empty,
                string.Empty);

            var response = new NominaProcesoResponse
            {
                Proceso = processName,
                Codigo = "SP_NOT_MIGRATED",
                Ejecutado = false,
                FechaIntento = DateTime.Now,
                Mensaje = UserFacingMessages.OperationFailed($"ejecutar {processName.ToLowerInvariant()}")
            };

            return Task.FromResult(new PagedResult<NominaProcesoResponse>
            {
                Success = false,
                Message = response.Mensaje,
                Code = response.Codigo,
                Data = response,
                Items = new List<NominaProcesoResponse> { response },
                TotalCount = 1
            });
        }

        private async Task<PagedResult<NominaProcesoResponse>> EjecutarCorridaDemoAsync(
            NominaProcesoRequest request,
            int usuarioActual)
        {
            request ??= new NominaProcesoRequest();

            try
            {
                await using var command = _context.Database.GetDbConnection().CreateCommand();
                command.CommandText = "[NOM].[spCorridaNomina_Demo]";
                command.CommandType = CommandType.StoredProcedure;
                command.CommandTimeout = 120;

                command.Parameters.Add(Param("@EmpresaId", request.EmpresaId));
                command.Parameters.Add(Param("@PeriodoId", request.PeriodoId));
                command.Parameters.Add(Param("@PersonaId", request.PersonaId));
                command.Parameters.Add(Param("@Anio", request.Anio));
                command.Parameters.Add(new SqlParameter("@FechaProceso", SqlDbType.Date)
                {
                    Value = request.FechaProceso.HasValue ? request.FechaProceso.Value.Date : DBNull.Value
                });
                command.Parameters.Add(new SqlParameter("@Observaciones", SqlDbType.NVarChar, 500)
                {
                    Value = string.IsNullOrWhiteSpace(request.Observaciones) ? DBNull.Value : request.Observaciones.Trim()
                });
                command.Parameters.Add(Param("@UsuarioId", usuarioActual));

                if (command.Connection?.State != ConnectionState.Open)
                {
                    await _context.Database.OpenConnectionAsync();
                }

                await using var reader = await command.ExecuteReaderAsync();
                if (!await reader.ReadAsync())
                {
                    throw new InvalidOperationException("El SP de corrida demo no regreso resultado.");
                }

                var response = MapProcesoResult(reader);
                return BuildResult(response, success: true);
            }
            catch (Exception ex)
            {
                _logger.LogMessage(
                    LogLevelGRP.Error,
                    $"Error al ejecutar corrida demo de nomina: {ex}",
                    (byte)SystemLogTypes.Error,
                    nameof(NominaProcesoAppService),
                    string.Empty,
                    string.Empty);

                var response = new NominaProcesoResponse
                {
                    Proceso = "Calcular nomina",
                    Codigo = "ERROR",
                    Ejecutado = false,
                    FechaIntento = DateTime.Now,
                    Mensaje = UserFacingMessages.OperationFailed("generar corrida de nomina")
                };

                return BuildResult(response, success: false);
            }
        }

        private async Task<PagedResult<NominaProcesoResponse>> ExecuteStoredProcedureAsync(
            string processName,
            string storedProcedure,
            NominaProcesoRequest request,
            int usuarioActual)
        {
            request ??= new NominaProcesoRequest();

            await using var command = _context.Database.GetDbConnection().CreateCommand();
            command.CommandText = $"[{NominaSchema}].[{storedProcedure}]";
            command.CommandType = CommandType.StoredProcedure;
            command.CommandTimeout = 120;

            AddProcesoParameters(command, request, usuarioActual);

            if (command.Connection?.State != ConnectionState.Open)
            {
                await _context.Database.OpenConnectionAsync();
            }

            await using var reader = await command.ExecuteReaderAsync();
            if (!await reader.ReadAsync())
            {
                throw new InvalidOperationException($"El SP {NominaSchema}.{storedProcedure} no regreso resultado.");
            }

            var response = MapProcesoResult(reader);
            if (string.IsNullOrWhiteSpace(response.Proceso))
            {
                response.Proceso = processName;
            }

            return BuildResult(response, response.Ejecutado);
        }

        private async Task<bool> StoredProcedureExistsAsync(string storedProcedure)
        {
            await using var command = _context.Database.GetDbConnection().CreateCommand();
            command.CommandText = "SELECT OBJECT_ID(@ProcedureName, N'P')";
            command.CommandType = CommandType.Text;
            command.Parameters.Add(new SqlParameter("@ProcedureName", SqlDbType.NVarChar, 261)
            {
                Value = $"{NominaSchema}.{storedProcedure}"
            });

            if (command.Connection?.State != ConnectionState.Open)
            {
                await _context.Database.OpenConnectionAsync();
            }

            var result = await command.ExecuteScalarAsync();
            return result != null && result != DBNull.Value;
        }

        private static void AddProcesoParameters(IDbCommand command, NominaProcesoRequest request, int usuarioActual)
        {
            command.Parameters.Add(Param("@EmpresaId", request.EmpresaId));
            command.Parameters.Add(Param("@PeriodoId", request.PeriodoId));
            command.Parameters.Add(Param("@PersonaId", request.PersonaId));
            command.Parameters.Add(Param("@Anio", request.Anio));
            command.Parameters.Add(new SqlParameter("@FechaProceso", SqlDbType.Date)
            {
                Value = request.FechaProceso.HasValue ? request.FechaProceso.Value.Date : DBNull.Value
            });
            command.Parameters.Add(new SqlParameter("@Observaciones", SqlDbType.NVarChar, 500)
            {
                Value = string.IsNullOrWhiteSpace(request.Observaciones) ? DBNull.Value : request.Observaciones.Trim()
            });
            command.Parameters.Add(Param("@UsuarioId", usuarioActual));
        }

        private static PagedResult<NominaProcesoResponse> BuildResult(NominaProcesoResponse response, bool success)
            => new()
            {
                Success = success,
                Message = response.Mensaje,
                Code = response.Codigo,
                Data = response,
                Items = new List<NominaProcesoResponse> { response },
                TotalCount = 1
            };

        private static SqlParameter Param(string name, object? value)
            => new(name, value ?? DBNull.Value);

        private static NominaProcesoResponse MapProcesoResult(IDataRecord reader)
        {
            return new NominaProcesoResponse
            {
                CorridaId = GetNullableInt(reader, "CorridaId"),
                EmpresaId = GetNullableInt(reader, "EmpresaId"),
                EmpresaNombre = GetString(reader, "EmpresaNombre"),
                PeriodoId = GetNullableInt(reader, "PeriodoId"),
                Anio = GetNullableInt(reader, "Anio"),
                TotalPersonas = GetInt(reader, "TotalPersonas"),
                TotalMovimientos = GetInt(reader, "TotalMovimientos"),
                TotalPercepcion = GetDecimal(reader, "TotalPercepcion"),
                TotalDeduccion = GetDecimal(reader, "TotalDeduccion"),
                TotalAportacion = GetDecimal(reader, "TotalAportacion"),
                TotalNeto = GetDecimal(reader, "TotalNeto"),
                Proceso = GetString(reader, "Proceso"),
                Codigo = GetString(reader, "Codigo"),
                Ejecutado = GetBool(reader, "Ejecutado"),
                FechaIntento = GetDateTime(reader, "FechaIntento"),
                Mensaje = GetString(reader, "Mensaje")
            };
        }

        private static string GetString(IDataRecord reader, string name)
            => reader[name] == DBNull.Value ? string.Empty : Convert.ToString(reader[name]) ?? string.Empty;

        private static int GetInt(IDataRecord reader, string name)
            => reader[name] == DBNull.Value ? 0 : Convert.ToInt32(reader[name]);

        private static int? GetNullableInt(IDataRecord reader, string name)
            => reader[name] == DBNull.Value ? null : Convert.ToInt32(reader[name]);

        private static decimal GetDecimal(IDataRecord reader, string name)
            => reader[name] == DBNull.Value ? 0 : Convert.ToDecimal(reader[name]);

        private static bool GetBool(IDataRecord reader, string name)
            => reader[name] != DBNull.Value && Convert.ToBoolean(reader[name]);

        private static DateTime GetDateTime(IDataRecord reader, string name)
            => reader[name] == DBNull.Value ? DateTime.Now : Convert.ToDateTime(reader[name]);
    }
}
