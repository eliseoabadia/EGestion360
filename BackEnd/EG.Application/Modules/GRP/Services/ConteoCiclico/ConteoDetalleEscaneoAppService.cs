using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Application.Interfaces.ConteoCiclico;
using EG.Business.Interfaces;

namespace EG.Application.Services.ConteoCiclico;

public sealed class ConteoDetalleEscaneoAppService(IConteoDetalleEscaneoOperations service) : IConteoDetalleEscaneoAppService
{
    public Task<PagedResult<ConteoDetalleEscaneoResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<ConteoDetalleEscaneoResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<ConteoDetalleEscaneoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest) => service.GetAllPaginadoAsync(pageRequest);
    public Task<PagedResult<ConteoDetalleEscaneoResponse>> GetByConteoAsync(int conteoId) => service.GetByConteoAsync(conteoId);
    public Task<PagedResult<ConteoDetalleEscaneoResponse>> CreateAsync(ConteoDetalleEscaneoResponse request, int usuarioActual) => service.CreateAsync(request, usuarioActual);
}
