using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Application.Interfaces.Adquisicion;
using EG.Business.Interfaces;

namespace EG.Application.Services.Adquisicion;

public sealed class ProveedorAppService(IProveedorOperations service) : IProveedorAppService
{
    public Task<PagedResult<ProveedorResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<ProveedorResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<ProveedorResponse>> CreateAsync(ProveedorResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<ProveedorResponse>> UpdateAsync(int id, ProveedorResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id, int usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public Task<PagedResult<ProveedorResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
}
