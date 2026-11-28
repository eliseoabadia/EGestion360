using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Application.Interfaces.General;
using EG.Business.Interfaces;

namespace EG.Application.Services.General;

public sealed class UsuarioDepartamentoAppService(IUsuarioDepartamentoOperations service) : IUsuarioDepartamentoAppService
{
    public Task<PagedResult<UsuarioDepartamentoResponse>> GetByUsuarioAsync(int usuarioId) => service.GetByUsuarioAsync(usuarioId);
    public Task<PagedResult<UsuarioDepartamentoResponse>> AsignarAsync(UsuarioDepartamentoAsignacionRequest request, int usuarioActual) => service.AsignarAsync(request, usuarioActual);
    public Task<PagedResult<UsuarioDepartamentoResponse>> EliminarAsync(int usuarioId, int departamentoId, int usuarioActual) => service.EliminarAsync(usuarioId, departamentoId, usuarioActual);
}
