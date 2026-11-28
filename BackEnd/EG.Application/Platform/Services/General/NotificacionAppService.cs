using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;
using EG.Application.Interfaces.General;
using EG.Business.Interfaces;

namespace EG.Application.Services.General;

public sealed class NotificacionAppService(INotificacionOperations service) : INotificacionAppService
{
    public Task<PagedResult<NotificacionResumenResponse>> GetResumenAsync(int usuarioId) => service.GetResumenAsync(usuarioId);
    public Task<PagedResult<NotificacionUsuarioResponse>> GetMisNotificacionesAsync(int usuarioId, int take = 30, bool soloPendientes = false) => service.GetMisNotificacionesAsync(usuarioId, take, soloPendientes);
    public Task<PagedResult<NotificacionUsuarioResponse>> GetConversacionAsync(long notificacionDestinoId, int usuarioId) => service.GetConversacionAsync(notificacionDestinoId, usuarioId);
    public Task<PagedResult<bool>> MarcarLeidaAsync(long notificacionDestinoId, int usuarioId) => service.MarcarLeidaAsync(notificacionDestinoId, usuarioId);
    public Task<PagedResult<bool>> AtenderAsync(long notificacionDestinoId, int usuarioId) => service.AtenderAsync(notificacionDestinoId, usuarioId);
    public Task<PagedResult<bool>> ResponderAsync(long notificacionDestinoId, int usuarioId, string mensaje) => service.ResponderAsync(notificacionDestinoId, usuarioId, mensaje);
    public Task<PagedResult<bool>> SolicitarAyudaProcesoAsync(int usuarioId, SolicitudAyudaProcesoRequest request) => service.SolicitarAyudaProcesoAsync(usuarioId, request);
}
