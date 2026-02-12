using EG.Web.Models.Configuration;
using SortDirection = MudBlazor.SortDirection;

namespace EG.Web.Contracs.Configuration
{
    public interface IEstadoService
    {
        // ============ CONSULTAS ============
        Task<IList<EstadoResponse>> GetAllEstadosAsync();

        Task<EstadoResponse> GetEstadoByIdAsync(int estadoId);

        // ============ PAGINACIÓN ============
        Task<(List<EstadoResponse> Estados, int TotalCount)> GetAllEstadosPaginadoAsync(
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection sortDirection = SortDirection.Ascending,
            string? estado = null);

        // ============ CRUD ============
        Task<(bool resultado, string mensaje)> CreateEstadoAsync(EstadoResponse estado);

        Task<(bool resultado, string mensaje)> UpdateEstadoAsync(EstadoResponse estado);

        Task<(bool resultado, string mensaje)> DeleteEstadoAsync(int estadoId);
    }
}
