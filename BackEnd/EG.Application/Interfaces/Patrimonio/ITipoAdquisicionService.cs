using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Application.Interfaces.Patrimonio
{
    public interface ITipoAdquisicionService
    {
        Task<PagedResult<TipoAdquisicionResponse>> GetAllAsync();
        Task<PagedResult<TipoAdquisicionResponse>> GetByIdAsync(int id);
        Task<PagedResult<TipoAdquisicionResponse>> CreateAsync(TipoAdquisicionResponse request);
        Task<PagedResult<TipoAdquisicionResponse>> UpdateAsync(int id, TipoAdquisicionResponse request);
        Task<PagedResult<bool>> DeleteAsync(int id);
        Task<PagedResult<TipoAdquisicionResponse>> GetAllPaginadoAsync(PagedRequest request);
    }
}
