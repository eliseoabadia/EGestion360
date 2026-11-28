using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Almacen;

namespace EG.Business.Interfaces;

public interface IDetalleSolicitudSalidaOperations
{
    Task<PagedResult<DetalleSolicitudSalidaResponse>> GetAllAsync();
    Task<PagedResult<DetalleSolicitudSalidaResponse>> GetByIdAsync(int id);
    Task<PagedResult<DetalleSolicitudSalidaResponse>> CreateAsync(DetalleSolicitudSalidaResponse response, int usuarioActual);
    Task<PagedResult<DetalleSolicitudSalidaResponse>> UpdateAsync(int id, DetalleSolicitudSalidaResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<DetalleSolicitudSalidaResponse>> GetAllPaginadoAsync(PagedRequest request);
    Task<PagedResult<DetalleSolicitudSalidaResponse>> ActualizarEntregaAsync(
            int id,
            DetalleSolicitudSalidaResponse response,
            int usuarioActual);
}
