using System.Data;
using System.Text.Json;
using EG.Common;
using EG.Common.Enums;
using EG.Common.Exceptions;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;

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
        private static readonly Logger.Log4NetLogger Logger = new(typeof(StoredProcedureExecutor));

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
            try
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

                var currentTransaction = context.Database.CurrentTransaction;
                if (currentTransaction != null)
                {
                    command.Transaction = currentTransaction.GetDbTransaction();
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
                    throw new UserVisibleException(
                        result.Mensaje,
                        string.IsNullOrWhiteSpace(result.Tipo) ? "SP_MESSAGE" : result.Tipo);
                }

                return result;
            }
            catch (UserVisibleException ex)
            {
                Logger.LogMessage(
                    LogLevelGRP.Warn,
                    $"Mensaje controlado del SP {storedProcedure}: {ex.UserMessage}",
                    (byte)SystemLogTypes.Warning,
                    "StoredProcedure",
                    string.Empty,
                    string.Empty);
                throw;
            }
            catch (Exception ex)
            {
                Logger.LogMessage(
                    LogLevelGRP.Error,
                    $"Error tecnico ejecutando SP {storedProcedure}: {ex}",
                    (byte)SystemLogTypes.Error,
                    "StoredProcedure",
                    string.Empty,
                    string.Empty);

                throw new InvalidOperationException(UserFacingMessages.UnexpectedError, ex);
            }
        }

        public static async Task<StoredProcedureResult> ExecuteConcurrencyCheckedAsync<TEntity>(
            EGestionContext context,
            int id,
            byte[]? expectedRowVersion,
            string entityName,
            Func<Task<StoredProcedureResult>> operation)
            where TEntity : class
        {
            await using var transaction = await context.Database.BeginTransactionAsync(IsolationLevel.Serializable);

            var entity = await context.Set<TEntity>().FindAsync(id);
            if (entity == null)
            {
                throw new UserVisibleException($"{entityName} no encontrado.", "NOT_FOUND");
            }

            if (expectedRowVersion is { Length: > 0 })
            {
                var property = typeof(TEntity).GetProperty("RowVersion");
                var currentRowVersion = property?.GetValue(entity) as byte[];
                if (currentRowVersion == null || !currentRowVersion.SequenceEqual(expectedRowVersion))
                {
                    throw new UserVisibleException(
                        "El registro fue modificado por otro usuario. Recarga la información antes de guardar nuevamente.",
                        "CONCURRENCY_CONFLICT");
                }
            }

            var result = await operation();
            await transaction.CommitAsync();
            return result;
        }
    }
}
