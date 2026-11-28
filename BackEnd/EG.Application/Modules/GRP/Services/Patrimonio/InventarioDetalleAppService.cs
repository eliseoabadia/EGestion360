using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Application.Interfaces.Patrimonio;
using EG.Business.Interfaces;

namespace EG.Application.Services.Patrimonio;

public sealed class InventarioDetalleAppService(IInventarioDetalleOperations service) : IInventarioDetalleAppService
{
    public Task<PagedResult<InventarioDetalleResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<InventarioDetalleResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<InventarioDetalleResponse>> CreateAsync(InventarioDetalleResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<InventarioDetalleResponse>> UpdateAsync(int id, InventarioDetalleResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<InventarioDetalleResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
}
