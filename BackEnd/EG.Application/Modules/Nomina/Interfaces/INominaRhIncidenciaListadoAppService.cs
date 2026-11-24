using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Nomina;

namespace EG.Application.Interfaces.Nomina;

public interface INominaRhIncidenciaListadoAppService
{
    Task<PagedResult<VwRhIncidenciaResponse>> GetAllPaginadoAsync(PagedRequest request);
}
