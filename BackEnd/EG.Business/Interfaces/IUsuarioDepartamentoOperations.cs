using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;

namespace EG.Business.Interfaces;

public interface IUsuarioDepartamentoOperations
{
    Task<PagedResult<UsuarioDepartamentoResponse>> GetByUsuarioAsync(int usuarioId);
    Task<PagedResult<UsuarioDepartamentoResponse>> AsignarAsync(UsuarioDepartamentoAsignacionRequest request, int usuarioActual);
    Task<PagedResult<UsuarioDepartamentoResponse>> EliminarAsync(int usuarioId, int departamentoId, int usuarioActual);
}
