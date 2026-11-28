using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Application.Interfaces.Patrimonio;
using EG.Business.Interfaces;

namespace EG.Application.Services.Patrimonio;

public sealed class InventarioAppService(IInventarioOperations service) : IInventarioAppService
{
    public Task<PagedResult<InventarioResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<InventarioResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<InventarioResponse>> CreateAsync(InventarioResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<InventarioResponse>> UpdateAsync(int id, InventarioResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<InventarioResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
    public Task<EG.Common.GenericModel.PagedResult<InventarioResponse>> AutorizarAsync(int id, int usuarioActual) => service.AutorizarAsync(id, usuarioActual);
}
