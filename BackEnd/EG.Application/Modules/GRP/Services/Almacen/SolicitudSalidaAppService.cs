using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Application.Interfaces.Almacen;
using EG.Business.Interfaces;

namespace EG.Application.Services.Almacen;

public sealed class SolicitudSalidaAppService(ISolicitudSalidaOperations service) : ISolicitudSalidaAppService
{
    public Task<PagedResult<SolicitudSalidaResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<SolicitudSalidaResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<SolicitudSalidaResponse>> CreateAsync(SolicitudSalidaResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<SolicitudSalidaResponse>> UpdateAsync(int id, SolicitudSalidaResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<SolicitudSalidaResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
    public Task<PagedResult<SolicitudSalidaResponse>> AutorizarAsync(int id, int usuarioActual) => service.AutorizarAsync(id, usuarioActual);
}
