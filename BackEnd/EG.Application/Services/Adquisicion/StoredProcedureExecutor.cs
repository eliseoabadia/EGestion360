using System.Data;
using System.Text.Json;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Adquisicion
{
    public sealed class StoredProcedureResult
    {
        public string Tipo { get; init; } = string.Empty;
        public string Mensaje { get; init; } = string.Empty;
        public string Liga { get; init; } = string.Empty;

        public bool Success =>
            Tipo.Equals("OK", StringComparison.OrdinalIgnoreCase) ||
            Tipo.Equals("EXITO", StringComparison.OrdinalIgnoreCase) ||
            Tipo.Equals("SUCCESS", StringComparison.OrdinalIgnoreCase);

        public int? GetId()
        {
            var value = Liga.Split(':', StringSplitOptions.RemoveEmptyEntries).LastOrDefault();
            return int.TryParse(value, out var id) ? id : null;
        }
    }

    public static class StoredProcedureExecutor
    {
        public static SqlParameter Param(string name, object? value)
        {
            return new SqlParameter(name, value ?? DBNull.Value);
        }

        public static SqlParameter JsonParam<T>(string name, T value)
        {
            return new SqlParameter(name, SqlDbType.NVarChar, -1)
            {
                Value = JsonSerializer.Serialize(value) ?? "[]"
            };
        }

        public static async Task<StoredProcedureResult> ExecuteResultAsync(
            EGestionContext context,
            string storedProcedure,
            params SqlParameter[] parameters)
        {
            var connection = context.Database.GetDbConnection();
            await using var command = connection.CreateCommand();
            command.CommandText = storedProcedure;
            command.CommandType = CommandType.StoredProcedure;

            foreach (var parameter in parameters)
            {
                command.Parameters.Add(parameter);
            }

            if (connection.State != ConnectionState.Open)
            {
                await connection.OpenAsync();
            }

            await using var reader = await command.ExecuteReaderAsync();
            if (!await reader.ReadAsync())
            {
                throw new InvalidOperationException($"El procedimiento {storedProcedure} no regreso ResultJson.");
            }

            var json = reader["ResultJson"]?.ToString();
            if (string.IsNullOrWhiteSpace(json))
            {
                throw new InvalidOperationException($"El procedimiento {storedProcedure} regreso ResultJson vacio.");
            }

            var result = JsonSerializer.Deserialize<StoredProcedureResult>(
                json,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true }) ?? new StoredProcedureResult();

            if (!result.Success)
            {
                throw new InvalidOperationException(result.Mensaje);
            }

            return result;
        }
    }
}
