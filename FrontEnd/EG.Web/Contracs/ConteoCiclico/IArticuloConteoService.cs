using EG.Web.Models;
using EG.Web.Models.ConteoCiclico;
using SortDirection = MudBlazor.SortDirection;

namespace EG.Web.Contracs.Configuration
{
    public interface IArticuloConteoService
    {
        Task<ApiResponse<List<ArticuloConteoResponse>>> GetAllAsync();
        Task<ApiResponse<ArticuloConteoResponse>> GetByIdAsync(int id);
        Task<ApiResponse<ArticuloConteoResponse>> GetAllPaginadoAsync(
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection sortDirection = SortDirection.Ascending,
            int? periodoId = null,
            int? usuarioId = null,
            int? estatusId = null);
        Task<ApiResponse<ArticuloConteoResponse>> CreateAsync(ArticuloConteoResponse entity);
        Task<ApiResponse<ArticuloConteoResponse>> UpdateAsync(ArticuloConteoResponse entity);
        Task<ApiResponse<bool>> DeleteAsync(int id);
        Task<ApiResponse<List<ArticuloConteoResponse>>> GetByPeriodoAsync(int periodoId);
        Task<ApiResponse<List<ArticuloConteoResponse>>> GetByUsuarioAsync(int usuarioId);
        Task<ApiResponse<ArticuloConteoResponse>> GetPaginadoByPeriodoAsync(
            int periodoId,
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection sortDirection = SortDirection.Ascending);
        Task<ApiResponse<bool>> CambiarEstatusAsync(int id, int estatusId);
        Task<ApiResponse<bool>> AsignarUsuarioAsync(int id, int usuarioId);
        //Task<ApiResponse<EstadisticasArticulosResponse>> GetEstadisticasAsync(int periodoId);
        Task<ApiResponse<List<ArticuloConteoResponse>>> AddBatchAsync(List<ArticuloConteoResponse> articulos);
    }
}