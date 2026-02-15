using EG.Web.Models;
using MudBlazor;

namespace EG.Web.Contracs
{
    public interface IGenericCrudService<TResponse> where TResponse : class
    {
        Task<ApiResponse<TResponse>> GetByIdAsync(int id);
        Task<ApiResponse<TResponse>> GetAllAsync();
        Task<ApiResponse<TResponse>> GetAllPaginadoAsync(
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection sortDirection = SortDirection.Ascending,
            Dictionary<string, object>? parametrosAdicionales = null);
        Task<ApiResponse<TResponse>> CreateAsync(TResponse entity);
        Task<ApiResponse<TResponse>> UpdateAsync(TResponse entity, int id);
        Task<ApiResponse<TResponse>> DeleteAsync(int id);
    }
}