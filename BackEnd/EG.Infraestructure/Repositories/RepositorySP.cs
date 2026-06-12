using Dapper;
using EG.Common;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System.Data;

namespace EG.Infrastructure
{
    public class RepositorySP<T> : IRepositorySP<T> where T : class
    {
        private readonly EGestionContext _context;
        private readonly DbSet<T> _dbSet;
        private readonly ILogger<RepositorySP<T>> _logger;

        public RepositorySP(EGestionContext context, ILogger<RepositorySP<T>> logger)
        {
            _context = context;
            _dbSet = _context.Set<T>();
            _logger = logger;
        }



        public async Task<IEnumerable<T>> ExecuteStoredProcedureAsync<T>(string storedProcedure, params SqlParameter[] parameters)
        {
            _logger.LogDebug(
                "Ejecutando SP {StoredProcedure} con parametros {Parameters}",
                storedProcedure,
                string.Join(", ", parameters.Select(param => param.ParameterName)));

            var connection = _context.Database.GetDbConnection();
            try
            {
                if (connection.State != ConnectionState.Open)
                {
                    await connection.OpenAsync();
                }

                var result = await connection.QueryAsync<T>(
                    storedProcedure,
                    parameters.ToDictionary(p => p.ParameterName.Replace("@", ""), p => p.Value ?? DBNull.Value),
                    commandType: CommandType.StoredProcedure
                );

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al ejecutar SP {StoredProcedure}", storedProcedure);
                throw new InvalidOperationException(UserFacingMessages.UnexpectedError, ex);
            }
            finally
            {
                if (connection.State == ConnectionState.Open)
                {
                    await connection.CloseAsync();
                }
            }
        }


    }
}
