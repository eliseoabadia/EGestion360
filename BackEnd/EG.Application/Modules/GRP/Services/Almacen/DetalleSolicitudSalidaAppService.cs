using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Application.Interfaces.Almacen;
using EG.Business.Interfaces;

namespace EG.Application.Services.Almacen;

public sealed class DetalleSolicitudSalidaAppService(IDetalleSolicitudSalidaOperations service) : IDetalleSolicitudSalidaAppService
{
    public Task<PagedResult<DetalleSolicitudSalidaResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<DetalleSolicitudSalidaResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<DetalleSolicitudSalidaResponse>> CreateAsync(DetalleSolicitudSalidaResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<DetalleSolicitudSalidaResponse>> UpdateAsync(int id, DetalleSolicitudSalidaResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<DetalleSolicitudSalidaResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
    public Task<PagedResult<DetalleSolicitudSalidaResponse>> ActualizarEntregaAsync( int id, DetalleSolicitudSalidaResponse response, int usuarioActual) => service.ActualizarEntregaAsync(id, response, usuarioActual);
}
