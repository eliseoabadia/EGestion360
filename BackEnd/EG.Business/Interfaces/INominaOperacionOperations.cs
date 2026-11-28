using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Nomina;

namespace EG.Business.Interfaces;

public interface INominaOperacionOperations
{
    Task<PagedResult<NominaOperacionResponse>> GetAllPaginadoAsync(PagedRequest request);
    Task<PagedResult<NominaOperacionResponse>> EnviarVacacionAAutorizarAsync(int id, int usuarioId);
    Task<PagedResult<NominaOperacionResponse>> AutorizarVacacionAsync(int id, int usuarioId);
}
