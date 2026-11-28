using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Application.Interfaces.General;
using EG.Business.Interfaces;

namespace EG.Application.Services.General;

public sealed class UsuarioAreaAppService(IUsuarioAreaOperations service) : IUsuarioAreaAppService
{
    public Task<PagedResult<UsuarioAreaResponse>> GetAllAsync(int usuarioId) => service.GetAllAsync(usuarioId);
    public Task<PagedResult<UsuarioAreaResponse>> GetByPersonaAsync(int personaId) => service.GetByPersonaAsync(personaId);
    public Task<PagedResult<UsuarioAreaResponse>> AsignarAreaAsync(UsuarioAreaAsignacionRequest request, int usuarioActual) => service.AsignarAreaAsync(request, usuarioActual);
    public Task<PagedResult<UsuarioAreaResponse>> EliminarAsignacionAsync(int personaAreaId, int usuarioActual) => service.EliminarAsignacionAsync(personaAreaId, usuarioActual);
}
