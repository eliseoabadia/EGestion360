using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Nomina;
using EG.Application.Interfaces.Nomina;
using EG.Business.Interfaces;

namespace EG.Application.Services.Nomina;

public sealed class NominaOperacionAppService(INominaOperacionOperations service) : INominaOperacionAppService
{
    public Task<PagedResult<NominaOperacionResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
    public Task<PagedResult<NominaOperacionResponse>> EnviarVacacionAAutorizarAsync(int id, int usuarioId) => service.EnviarVacacionAAutorizarAsync(id, usuarioId);
    public Task<PagedResult<NominaOperacionResponse>> AutorizarVacacionAsync(int id, int usuarioId) => service.AutorizarVacacionAsync(id, usuarioId);
}
