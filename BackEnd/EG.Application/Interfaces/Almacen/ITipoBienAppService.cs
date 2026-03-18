using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;

namespace EG.Application.Interfaces.Almacen
{
    public interface ITipoBienAppService
    {
        Task<PagedResult<TipoBienResponse>> GetAllAsync();
        Task<TipoBienResponse> GetByIdAsync(int id);
        Task<PagedResult<TipoBienResponse>> GetAllPaginadoAsync(PagedRequest request);
        Task<TipoBienResponse> CreateAsync(TipoBienDto dto, int usuarioActual);
        Task<TipoBienResponse> UpdateAsync(int id, TipoBienDto dto, int usuarioActual);
        Task DeleteAsync(int id);
    }
}