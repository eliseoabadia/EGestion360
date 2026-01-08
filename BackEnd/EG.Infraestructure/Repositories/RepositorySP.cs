using Dapper;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System.Data;

namespace EG.Infrastructure
{
    public class RepositorySP<T> : IRepositorySP<T> where T : class
    {
        private readonly EGestionContext _context;
        private readonly DbSet<T> _dbSet;

        public RepositorySP(EGestionContext context)
        {
            _context = context;
            _dbSet = _context.Set<T>();
        }



        public async Task<IEnumerable<T>> ExecuteStoredProcedureAsync<T>(string storedProcedure, params SqlParameter[] parameters)
        {
            Console.WriteLine($"Ejecutando SP: {storedProcedure}");
            Console.WriteLine("Parámetros:");
            foreach (var param in parameters)
            {
                Console.WriteLine($"{param.ParameterName} = {param.Value} (Tipo: {param.SqlDbType})");
            }

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

                Console.WriteLine($"Resultados obtenidos: {result?.Count() ?? 0}");
                return result;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error al ejecutar SP: {ex.Message}");
                throw;
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