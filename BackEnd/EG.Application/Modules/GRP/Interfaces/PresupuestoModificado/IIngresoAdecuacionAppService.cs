using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.PresupuestoModificado;

namespace EG.Application.Interfaces.PresupuestoModificado
{
    public interface IIngresoAdecuacionAppService : IAdquisicionCrudAppService<IngreAdecuacionResponse>
    {
        Task<PagedResult<IngreAdecuacionResponse>> EnviarSolicitudAsync(int id, int usuarioActual);
        Task<PagedResult<IngreAdecuacionResponse>> AutorizarAsync(int id, int usuarioActual);
        Task<PagedResult<IngreAdecuacionResponse>> RechazarAsync(int id, int usuarioActual);
    }
}
