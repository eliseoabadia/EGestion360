using EG.Common.Helper;
using EG.Web.Contracts;
using EG.Web.Models;
using EG.Web.Models.Notificaciones;
using Microsoft.JSInterop;

namespace EG.Web.Services;

public class NotificacionService : BaseService, INotificacionService
{
    private const string Endpoint = "api/Notificacion";

    public NotificacionService(
        IConfiguration configuration,
        HttpClient httpClient,
        IJSRuntime jsRuntime,
        ApplicationInstance application)
        : base(httpClient, jsRuntime, application, configuration)
    {
    }

    public async Task<ApiResponse<NotificacionResumenModel>> GetResumenAsync()
    {
        return await GetAsync<ApiResponse<NotificacionResumenModel>>($"{Endpoint}/resumen", useBaseUrl: false)
            ?? new ApiResponse<NotificacionResumenModel>();
    }

    public async Task<ApiResponse<NotificacionUsuarioModel>> GetMisNotificacionesAsync(int take = 30, bool soloPendientes = false)
    {
        return await GetAsync<ApiResponse<NotificacionUsuarioModel>>(
                $"{Endpoint}/mis?take={take}&soloPendientes={soloPendientes.ToString().ToLowerInvariant()}",
                useBaseUrl: false)
            ?? new ApiResponse<NotificacionUsuarioModel>();
    }

    public async Task<ApiResponse<NotificacionUsuarioModel>> GetConversacionAsync(long id)
    {
        return await GetAsync<ApiResponse<NotificacionUsuarioModel>>($"{Endpoint}/{id}/conversacion", useBaseUrl: false)
            ?? new ApiResponse<NotificacionUsuarioModel>();
    }

    public async Task<ApiResponse<bool>> MarcarLeidaAsync(long id)
    {
        return await PostAsync<ApiResponse<bool>>($"{Endpoint}/{id}/leer", new { }, useBaseUrl: false)
            ?? new ApiResponse<bool>();
    }

    public async Task<ApiResponse<bool>> AtenderAsync(long id)
    {
        return await PostAsync<ApiResponse<bool>>($"{Endpoint}/{id}/atender", new { }, useBaseUrl: false)
            ?? new ApiResponse<bool>();
    }

    public async Task<ApiResponse<bool>> ResponderAsync(long id, string mensaje)
    {
        return await PostAsync<ApiResponse<bool>>(
                $"{Endpoint}/{id}/responder",
                new NotificacionResponderRequest { Mensaje = mensaje },
                useBaseUrl: false)
            ?? new ApiResponse<bool>();
    }
}
