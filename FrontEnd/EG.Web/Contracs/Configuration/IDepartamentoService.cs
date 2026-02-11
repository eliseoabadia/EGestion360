using EG.Web.Models;
using EG.Web.Models.Configuration;
using SortDirection = MudBlazor.SortDirection;

namespace EG.Web.Contracs.Configuration
{
    public interface IDepartamentoService
    {
        // ============ CONSULTAS ============
        Task<IList<DepartamentoResponse>> GetAllDepartamentos();

        Task<DepartamentoResponse> GetDepartamentoByIdAsync(int departamentoId);

        Task<IList<DepartamentoResponse>> GetDepartamentosPorEmpresaAsync(int empresaId);

        // ============ PAGINACIÓN ============
        Task<(List<DepartamentoResponse> Departamentos, int TotalCount)> GetAllDepartamentosPaginadoAsync(
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection sortDirection = SortDirection.Ascending,
            int? empresaId = null,
            string? estado = null);

        // ============ CRUD ============
        Task<(bool resultado, string mensaje)> CreateDepartamentoAsync(DepartamentoResponse departamento);

        Task<(bool resultado, string mensaje)> UpdateDepartamentoAsync(DepartamentoResponse departamento);

        Task<(bool resultado, string mensaje)> DeleteDepartamentoAsync(int departamentoId);
    }
}