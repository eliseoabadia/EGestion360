using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;

namespace EG.Application.Interfaces.General
{
    public interface INotificacionAppService
    {
        Task<PagedResult<NotificacionResumenResponse>> GetResumenAsync(int usuarioId);
        Task<PagedResult<NotificacionUsuarioResponse>> GetMisNotificacionesAsync(int usuarioId, int take = 30, bool soloPendientes = false);
        Task<PagedResult<bool>> MarcarLeidaAsync(long notificacionDestinoId, int usuarioId);
        Task<PagedResult<bool>> AtenderAsync(long notificacionDestinoId, int usuarioId);
        Task<PagedResult<bool>> ResponderAsync(long notificacionDestinoId, int usuarioId, string mensaje);
    }
}
