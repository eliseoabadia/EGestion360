using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Nomina;

namespace EG.Business.Interfaces;

public interface INominaRhEmpleadoDetalleOperations
{
    Task<PagedResult<NominaRhEmpleadoDetalleResponse>> GetAllPaginadoAsync(PagedRequest request, int? empresaId);
}
