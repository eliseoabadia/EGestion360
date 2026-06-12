using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Application.Interfaces.Patrimonio
{
    public interface IPartidaService
    {
        Task<PagedResult<PartidaResponse>> GetAllAsync();
        Task<PagedResult<PartidaResponse>> GetByIdAsync(int id);
        Task<PagedResult<PartidaResponse>> CreateAsync(PartidaResponse request);
        Task<PagedResult<PartidaResponse>> UpdateAsync(int id, PartidaResponse request);
        Task<PagedResult<bool>> DeleteAsync(int id);
        Task<PagedResult<PartidaResponse>> GetAllPaginadoAsync(PagedRequest request);
        Task<List<LookupItem>> GetLookupAsync();
        Task<PagedResult<LookupItem>> GetLookupPaginadoAsync(int page = 1, int pageSize = 25, string? filter = null);
    }
}
