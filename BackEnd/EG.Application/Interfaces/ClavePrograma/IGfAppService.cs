using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Domain.DTOs.Responses;

namespace EG.Application.Interfaces.ClavePrograma
{
    public interface IGfAppService
    {
        Task<PagedResult<GfResponse>> GetAllAsync();
        Task<PagedResult<GfResponse>> GetByIdAsync(int id);
        Task<PagedResult<GfResponse>> GetAllPaginadoAsync(PagedRequest request);
        Task<PagedResult<GfResponse>> CreateAsync(GfResponse request, int usuarioActual);
        Task<PagedResult<GfResponse>> UpdateAsync(int id, GfResponse request, int usuarioActual);
        Task<PagedResult<GfResponse>> DeleteAsync(int id);
        Task<PagedResult<GfResponse>> BuscarAsync(BusquedaRequest request);
    }
}
