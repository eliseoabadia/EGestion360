#if !EG_BROWSER_WASM
using Microsoft.Data.SqlClient;

namespace EG.Domain.Interfaces
{
    public interface IRepositorySP<T> where T : class
    {
        Task<IEnumerable<T>> ExecuteStoredProcedureAsync<T>(string storedProcedure, params SqlParameter[] parameters);

        //Task<int> ExecuteNonQueryStoredProcedureAsync(string storedProcedure, params object[] parameters);
    }
}
#endif
