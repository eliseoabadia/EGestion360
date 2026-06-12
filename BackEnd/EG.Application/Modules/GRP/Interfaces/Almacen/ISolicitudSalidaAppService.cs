using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Almacen;

namespace EG.Application.Interfaces.Almacen
{
    public interface ISolicitudSalidaAppService : IAdquisicionCrudAppService<SolicitudSalidaResponse>
    {
        Task<PagedResult<SolicitudSalidaResponse>> AutorizarAsync(int id, int usuarioActual);
    }
}
