using EG.Web.Models;
using EG.Web.Models.Notificaciones;

namespace EG.Web.Contracts;

public interface INotificacionService
{
    Task<ApiResponse<NotificacionResumenModel>> GetResumenAsync();
    Task<ApiResponse<NotificacionUsuarioModel>> GetMisNotificacionesAsync(int take = 30, bool soloPendientes = false);
    Task<ApiResponse<NotificacionUsuarioModel>> GetConversacionAsync(long id);
    Task<ApiResponse<bool>> MarcarLeidaAsync(long id);
    Task<ApiResponse<bool>> AtenderAsync(long id);
    Task<ApiResponse<bool>> ResponderAsync(long id, string mensaje);
}
