using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales
{
    public interface IFuenteFinanciamientoAppServices
    {
        Task<IEnumerable<FuenteFinanciamientoResponse>> GetAllAsync();
        Task<FuenteFinanciamientoResponse> GetByIdAsync(int id);
        Task<PagedResult<FuenteFinanciamientoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest, Func<FuenteFinanciamientoResponse, bool>? predicate = null);
        Task<FuenteFinanciamientoResponse> CreateAsync(FuenteFinanciamientoResponse response, int usuarioCreacion);
        Task<FuenteFinanciamientoResponse> UpdateAsync(int id, FuenteFinanciamientoResponse response, int usuarioModificacion);
        Task<bool> DeleteAsync(int id, int usuarioActual);
        Task<bool> ExistsAsync(int id);
    }
}
