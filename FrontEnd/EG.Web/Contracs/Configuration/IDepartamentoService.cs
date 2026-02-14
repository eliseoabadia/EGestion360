using EG.Web.Models;
using EG.Web.Models.Configuration;
using SortDirection = MudBlazor.SortDirection;

namespace EG.Web.Contracs.Configuration
{
    public interface IDepartamentoService
    {
        Task<ApiResponse<DepartamentoResponse>> GetAllDepartamentosAsync();

        Task<ApiResponse<DepartamentoResponse>> GetAllDepartamentosPaginadoAsync(
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection _sortDirection = SortDirection.Ascending,
            int? empresaId = null,
            string estado = null);

        Task<ApiResponse<DepartamentoResponse>> GetDepartamentoByIdAsync(int departamentoId);

        Task<ApiResponse<DepartamentoResponse>> CreateDepartamentoAsync(DepartamentoResponse departamento);

        Task<ApiResponse<DepartamentoResponse>> UpdateDepartamentoAsync(DepartamentoResponse departamento);

        Task<ApiResponse<DepartamentoResponse>> DeleteDepartamentoAsync(int departamentoId);

        Task<ApiResponse<DepartamentoResponse>> GetDepartamentosPorEmpresaAsync(int empresaId);
    }
}