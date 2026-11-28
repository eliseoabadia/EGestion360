using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Application.Interfaces.Adquisicion;
using EG.Business.Interfaces;

namespace EG.Application.Services.Adquisicion;

public sealed class OrdenCompraPartidaAppService(IOrdenCompraPartidaOperations service) : IOrdenCompraPartidaAppService
{
    public Task<PagedResult<OrdenCompraPartidaResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<OrdenCompraPartidaResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<OrdenCompraPartidaResponse>> CreateAsync(OrdenCompraPartidaResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<OrdenCompraPartidaResponse>> UpdateAsync(int id, OrdenCompraPartidaResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<OrdenCompraPartidaResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
}
