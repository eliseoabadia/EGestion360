using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Application.Interfaces.Patrimonio
{
    public interface IGrupoBienService
    {
        Task<PagedResult<GrupoBienResponse>> GetAllAsync();
        Task<PagedResult<GrupoBienResponse>> GetByIdAsync(int id);
        Task<PagedResult<GrupoBienResponse>> CreateAsync(GrupoBienResponse request);
        Task<PagedResult<GrupoBienResponse>> UpdateAsync(int id, GrupoBienResponse request);
        Task<PagedResult<bool>> DeleteAsync(int id);
        Task<PagedResult<GrupoBienResponse>> GetAllPaginadoAsync(PagedRequest request);
        Task<PagedResult<GrupoBienResponse>> GetGrupoBienAsync();
        Task<List<LookupItem>> GetLookupAsync();
        Task<PagedResult<LookupItem>> GetLookupPaginadoAsync(int page = 1, int pageSize = 25, string? filter = null);
    }
}
