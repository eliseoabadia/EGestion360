using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Application.Interfaces.Patrimonio
{
    public interface ITipoPatrimonioService
    {
        Task<PagedResult<TipoPatrimonioResponse>> GetAllAsync();
        Task<PagedResult<TipoPatrimonioResponse>> GetByIdAsync(int id);
        Task<PagedResult<TipoPatrimonioResponse>> CreateAsync(TipoPatrimonioResponse request);
        Task<PagedResult<TipoPatrimonioResponse>> UpdateAsync(int id, TipoPatrimonioResponse request);
        Task<PagedResult<bool>> DeleteAsync(int id);
        Task<PagedResult<TipoPatrimonioResponse>> GetAllPaginadoAsync(PagedRequest request);
    }
}
