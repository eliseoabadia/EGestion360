using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Application.Interfaces.Adquisicion;
using EG.Business.Interfaces;

namespace EG.Application.Services.Adquisicion;

public sealed class OrdenCompraDetalleAppService(IOrdenCompraDetalleOperations service) : IOrdenCompraDetalleAppService
{
    public Task<PagedResult<OrdenCompraDetalleResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<OrdenCompraDetalleResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<OrdenCompraDetalleResponse>> CreateAsync(OrdenCompraDetalleResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<OrdenCompraDetalleResponse>> UpdateAsync(int id, OrdenCompraDetalleResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<OrdenCompraDetalleResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
}
