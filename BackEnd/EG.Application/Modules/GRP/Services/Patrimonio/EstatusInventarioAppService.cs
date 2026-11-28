using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Application.Interfaces.Patrimonio;
using EG.Business.Interfaces;

namespace EG.Application.Services.Patrimonio;

public sealed class EstatusInventarioAppService(IEstatusInventarioOperations service) : IEstatusInventarioAppService
{
    public Task<PagedResult<EstatusInventarioResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<EstatusInventarioResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<EstatusInventarioResponse>> CreateAsync(EstatusInventarioResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<EstatusInventarioResponse>> UpdateAsync(int id, EstatusInventarioResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<EstatusInventarioResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
}
