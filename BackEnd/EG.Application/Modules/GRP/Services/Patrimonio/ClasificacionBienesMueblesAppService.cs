using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Application.Interfaces.Patrimonio;
using EG.Business.Interfaces;

namespace EG.Application.Services.Patrimonio;

public sealed class ClasificacionBienesMueblesAppService(IClasificacionBienesMueblesOperations service) : IClasificacionBienesMueblesAppService
{
    public Task<PagedResult<ClasificacionBienesMueblesResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<ClasificacionBienesMueblesResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<ClasificacionBienesMueblesResponse>> CreateAsync(ClasificacionBienesMueblesResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<ClasificacionBienesMueblesResponse>> UpdateAsync(int id, ClasificacionBienesMueblesResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<ClasificacionBienesMueblesResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
}
