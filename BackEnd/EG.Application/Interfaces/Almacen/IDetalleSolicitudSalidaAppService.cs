using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Almacen;

namespace EG.Application.Interfaces.Almacen
{
    public interface IDetalleSolicitudSalidaAppService : IAdquisicionCrudAppService<DetalleSolicitudSalidaResponse>
    {
        Task<PagedResult<DetalleSolicitudSalidaResponse>> ActualizarEntregaAsync(
            int id,
            DetalleSolicitudSalidaResponse response,
            int usuarioActual);
    }
}
