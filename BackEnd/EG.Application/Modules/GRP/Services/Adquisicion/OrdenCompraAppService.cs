using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Application.Interfaces.Adquisicion;
using EG.Business.Interfaces;

namespace EG.Application.Services.Adquisicion;

public sealed class OrdenCompraAppService(IOrdenCompraOperations service) : IOrdenCompraAppService
{
    public Task<PagedResult<OrdenCompraResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<OrdenCompraResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<OrdenCompraResponse>> CreateAsync(OrdenCompraResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<OrdenCompraResponse>> UpdateAsync(int id, OrdenCompraResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<OrdenCompraResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
    public Task<PagedResult<OrdenCompraResponse>> AutorizarAsync(int id, int usuarioActual) => service.AutorizarAsync(id, usuarioActual);
}
