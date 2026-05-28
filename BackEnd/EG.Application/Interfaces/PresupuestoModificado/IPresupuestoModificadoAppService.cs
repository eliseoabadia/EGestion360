using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.PresupuestoModificado;

namespace EG.Application.Interfaces.PresupuestoModificado
{
    public interface IPresupuestoModificadoAppService : IAdquisicionCrudAppService<EgreAdecuacionResponse>
    {
        Task<PagedResult<EgreAdecuacionResponse>> EnviarSolicitudAsync(int id, int usuarioActual);
        Task<PagedResult<EgreAdecuacionResponse>> AutorizarAsync(int id, int usuarioActual);
        Task<PagedResult<EgreAdecuacionResponse>> RechazarAsync(int id, int usuarioActual);
    }
}
