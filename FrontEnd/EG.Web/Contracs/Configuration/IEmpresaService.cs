using EG.Web.Models;
using EG.Web.Models.Configuration;
using SortDirection = MudBlazor.SortDirection;

namespace EG.Web.Contracs.Configuration
{
    /// <summary>
    /// Servicio para la gestión de empresas
    /// </summary>
    public interface IEmpresaService
    {
        Task<ApiResponse<EmpresaResponse>> GetAllEmpresasAsync();

        Task<ApiResponse<EmpresaResponse>> GetAllEmpresasPaginadoAsync(
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection _sortDirection = SortDirection.Ascending,
            string estado = null);

        Task<ApiResponse<EmpresaResponse>> GetEmpresaByIdAsync(int empresaId);

        Task<ApiResponse<EmpresaResponse>> CreateEmpresaAsync(EmpresaResponse empresa);

        Task<ApiResponse<EmpresaResponse>> UpdateEmpresaAsync(EmpresaResponse empresa);

        Task<ApiResponse<EmpresaResponse>> DeleteEmpresaAsync(int empresaId);
    }
}