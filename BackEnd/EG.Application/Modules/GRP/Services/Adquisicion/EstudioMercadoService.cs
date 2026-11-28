using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Application.Interfaces.Adquisicion;
using EG.Business.Interfaces;

namespace EG.Application.Services.Adquisicion;

public sealed class EstudioMercadoService(IEstudioMercadoOperations service) : IEstudioMercadoService
{
    public Task<PagedResult<EstudioMercadoResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<EstudioMercadoResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<EstudioMercadoResponse>> CreateAsync(EstudioMercadoResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<EstudioMercadoResponse>> UpdateAsync(int id, EstudioMercadoResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<EstudioMercadoResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
    public Task<PagedResult<bool>> DeleteAsync(int id, int usuarioActual) => service.DeleteAsync(id, usuarioActual);
}
