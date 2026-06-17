using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Nomina;

namespace EG.Application.Interfaces.Nomina
{
    public interface INominaOperacionAppService
    {
        Task<PagedResult<NominaOperacionResponse>> GetAllPaginadoAsync(PagedRequest request);
    }
}
