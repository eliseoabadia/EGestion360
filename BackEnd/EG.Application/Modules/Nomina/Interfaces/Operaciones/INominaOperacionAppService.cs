using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Nomina;

namespace EG.Application.Interfaces.Nomina
{
    public interface INominaOperacionAppService
    {
        Task<PagedResult<NominaOperacionResponse>> GetAllPaginadoAsync(PagedRequest request);
        Task<PagedResult<NominaOperacionResponse>> EnviarVacacionAAutorizarAsync(int id, int usuarioId);
        Task<PagedResult<NominaOperacionResponse>> AutorizarVacacionAsync(int id, int usuarioId);
    }
}
