using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;

namespace EG.Business.Interfaces;

public interface IAreaService
{
    Task<PagedResult<AreaResponse>> GetAllAsync();
    Task<PagedResult<AreaResponse>> GetByIdAsync(int id);
    Task<PagedResult<AreaResponse>> GetAllPaginadoAsync(PagedRequest request);
    Task<PagedResult<AreaResponse>> GetAreasByPersona(int personaId);
}
