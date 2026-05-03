using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;

namespace EG.Application.Interfaces.Configuracion.Catalogo.ClavePrograma
{
    public interface IGfService
    {
        Task<IEnumerable<GfResponse>> GetAllAsync();
        Task<GfResponse> GetByIdAsync(int id);
        Task<GfResponse> AddAsync(GfDto dto, int usuarioCreacion);
        Task UpdateAsync(int id, GfDto dto, int usuarioModificacion);
        Task DeleteAsync(int id);
        Task<PagedResult<GfResponse>> GetAllPaginadoAsync(PagedRequest request);
        Task<bool> CanAddAsync(GfDto dto);
        Task<bool> CanUpdateAsync(int id, GfDto dto);
    }
}