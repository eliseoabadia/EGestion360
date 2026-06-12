using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales
{
    public interface ISectorAppServices
    {
        Task<IEnumerable<SectorResponse>> GetAllAsync();
        Task<SectorResponse> GetByIdAsync(int id);
        Task<PagedResult<SectorResponse>> GetAllPaginadoAsync(PagedRequest pageRequest, Func<SectorResponse, bool>? predicate = null);
        Task<SectorResponse> CreateAsync(SectorResponse response, int usuarioCreacion);
        Task<SectorResponse> UpdateAsync(int id, SectorResponse response, int usuarioModificacion);
        Task<bool> DeleteAsync(int id, int usuarioActual);
        Task<bool> ExistsAsync(int id);
    }
}
