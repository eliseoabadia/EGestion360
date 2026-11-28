using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Business.Interfaces;

public interface ITipoBienOperations
{
    Task<PagedResult<TipoBienResponse>> GetAllAsync();
    Task<PagedResult<TipoBienResponse>> GetByIdAsync(int id);
    Task<PagedResult<TipoBienResponse>> CreateAsync(TipoBienResponse request);
    Task<PagedResult<TipoBienResponse>> UpdateAsync(int id, TipoBienResponse request);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<TipoBienResponse>> GetAllPaginadoAsync(PagedRequest request);
}
