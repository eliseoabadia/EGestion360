using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Application.Interfaces.Patrimonio
{
    public interface INivelService
    {
        Task<PagedResult<NivelResponse>> GetAllAsync();
        Task<PagedResult<NivelResponse>> GetByIdAsync(int id);
        Task<PagedResult<NivelResponse>> CreateAsync(NivelResponse request);
        Task<PagedResult<NivelResponse>> UpdateAsync(int id, NivelResponse request);
        Task<PagedResult<bool>> DeleteAsync(int id);
        Task<PagedResult<NivelResponse>> GetAllPaginadoAsync(PagedRequest request);
        Task<List<LookupItem>> GetLookupAsync();
        Task<PagedResult<LookupItem>> GetLookupPaginadoAsync(int page = 1, int pageSize = 25, string? filter = null);
    }
}
