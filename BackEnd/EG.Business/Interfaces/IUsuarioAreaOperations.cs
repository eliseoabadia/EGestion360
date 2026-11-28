using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;

namespace EG.Business.Interfaces;

public interface IUsuarioAreaOperations
{
    Task<PagedResult<UsuarioAreaResponse>> GetAllAsync(int usuarioId);
    Task<PagedResult<UsuarioAreaResponse>> GetByPersonaAsync(int personaId);
    Task<PagedResult<UsuarioAreaResponse>> AsignarAreaAsync(UsuarioAreaAsignacionRequest request, int usuarioActual);
    Task<PagedResult<UsuarioAreaResponse>> EliminarAsignacionAsync(int personaAreaId, int usuarioActual);
}
