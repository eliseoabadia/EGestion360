using EG.Web.Models;
using EG.Web.Models.Configuration;
using MudBlazor;

namespace EG.Web.Contracs
{
    public interface IGenericServiceFactory
    {
        // Métodos para Departamento
        Task<ApiResponse<DepartamentoResponse>> GetDepartamentoByIdAsync(int id);
        Task<ApiResponse<DepartamentoResponse>> GetAllDepartamentosAsync();
        Task<ApiResponse<DepartamentoResponse>> GetAllDepartamentosPaginadoAsync(
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection sortDirection = SortDirection.Ascending,
            Dictionary<string, object>? parametrosAdicionales = null);
        Task<ApiResponse<DepartamentoResponse>> CreateDepartamentoAsync(DepartamentoResponse departamento);
        Task<ApiResponse<DepartamentoResponse>> UpdateDepartamentoAsync(DepartamentoResponse departamento, int id);
        Task<ApiResponse<DepartamentoResponse>> DeleteDepartamentoAsync(int id);

        // Métodos para Usuario
        Task<ApiResponse<UsuarioResponse>> GetUsuarioByIdAsync(int id);
        Task<ApiResponse<UsuarioResponse>> GetAllUsuariosAsync();
        Task<ApiResponse<UsuarioResponse>> GetAllUsuariosPaginadoAsync(
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection sortDirection = SortDirection.Ascending,
            Dictionary<string, object>? parametrosAdicionales = null);
        Task<ApiResponse<UsuarioResponse>> CreateUsuarioAsync(UsuarioResponse usuario);
        Task<ApiResponse<UsuarioResponse>> UpdateUsuarioAsync(UsuarioResponse usuario, int id);
        Task<ApiResponse<UsuarioResponse>> DeleteUsuarioAsync(int id);

        // Método genérico por si necesitas crear servicios para otros tipos
        IGenericCrudService<TResponse> CreateService<TResponse>(string endpoint, string? paginatedAction = null) where TResponse : class;
    }
}
