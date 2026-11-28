using EG.Application.Interfaces.General;
using EG.Business.Interfaces;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;

namespace EG.Application.Services.General;

public sealed class AreaAppService(IAreaService service) : IAreaAppService
{
    public Task<PagedResult<AreaResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<AreaResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<AreaResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
    public Task<PagedResult<AreaResponse>> GetAreasByPersona(int personaId) => service.GetAreasByPersona(personaId);
}
