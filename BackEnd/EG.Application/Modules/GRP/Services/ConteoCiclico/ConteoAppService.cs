using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Application.Interfaces.ConteoCiclico;
using EG.Business.Interfaces;

namespace EG.Application.Services.ConteoCiclico;

public sealed class ConteoAppService(IConteoOperations service) : IConteoAppService
{
    public Task<PagedResult<ConteoResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<ConteoResponse> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<ConteoResponse> CreateAsync(ConteoDto dto, int usuarioActual) => service.CreateAsync(dto, usuarioActual);
    public Task<ConteoResponse> UpdateAsync(int id, ConteoDto dto, int usuarioActual) => service.UpdateAsync(id, dto, usuarioActual);
    public Task<bool> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<ConteoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest) => service.GetAllPaginadoAsync(pageRequest);
}
