using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Application.Interfaces.Adquisicion;
using EG.Business.Interfaces;

namespace EG.Application.Services.Adquisicion;

public sealed class FraccionAppService(IFraccionOperations service) : IFraccionAppService
{
    public Task<PagedResult<FraccionResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<FraccionResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<FraccionResponse>> CreateAsync(FraccionResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<FraccionResponse>> UpdateAsync(int id, FraccionResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<FraccionResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
}
