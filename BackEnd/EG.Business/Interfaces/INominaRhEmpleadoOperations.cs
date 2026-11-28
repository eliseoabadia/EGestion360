using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Nomina;

namespace EG.Business.Interfaces;

public interface INominaRhEmpleadoOperations
{
    Task<PagedResult<NominaRhEmpleadoResponse>> GetAllAsync(int? empresaId);
    Task<PagedResult<NominaRhEmpleadoResponse>> GetByIdAsync(int id);
    Task<PagedResult<NominaRhEmpleadoResponse>> CreateAsync(NominaRhEmpleadoResponse response, int usuarioActual, int? empresaId);
    Task<PagedResult<NominaRhEmpleadoResponse>> UpdateAsync(int id, NominaRhEmpleadoResponse response, int usuarioActual, int? empresaId);
    Task<PagedResult<bool>> DeleteAsync(int id, int usuarioActual);
    Task<PagedResult<NominaRhEmpleadoResponse>> GetAllPaginadoAsync(PagedRequest request, int? empresaId);
}
