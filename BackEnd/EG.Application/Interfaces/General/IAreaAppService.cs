using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;

namespace EG.Application.Interfaces.General
{
    public interface IAreaAppService
    {
        Task<PagedResult<AreaResponse>> GetAllAsync();
        Task<PagedResult<AreaResponse>> GetByIdAsync(int id);
        Task<PagedResult<AreaResponse>> GetAllPaginadoAsync(PagedRequest request);
        Task<PagedResult<AreaResponse>> GetAreasByPersona(int personaId);
    }
}
