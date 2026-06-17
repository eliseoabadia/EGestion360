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
