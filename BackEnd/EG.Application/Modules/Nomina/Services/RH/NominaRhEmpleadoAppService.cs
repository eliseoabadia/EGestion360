using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Nomina;
using EG.Application.Interfaces.Nomina;
using EG.Business.Interfaces;

namespace EG.Application.Services.Nomina;

public sealed class NominaRhEmpleadoAppService(INominaRhEmpleadoOperations service) : INominaRhEmpleadoAppService
{
    public Task<PagedResult<NominaRhEmpleadoResponse>> GetAllAsync(int? empresaId) => service.GetAllAsync(empresaId);
    public Task<PagedResult<NominaRhEmpleadoResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<NominaRhEmpleadoResponse>> CreateAsync(NominaRhEmpleadoResponse response, int usuarioActual, int? empresaId) => service.CreateAsync(response, usuarioActual, empresaId);
    public Task<PagedResult<NominaRhEmpleadoResponse>> UpdateAsync(int id, NominaRhEmpleadoResponse response, int usuarioActual, int? empresaId) => service.UpdateAsync(id, response, usuarioActual, empresaId);
    public Task<PagedResult<bool>> DeleteAsync(int id, int usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public Task<PagedResult<NominaRhEmpleadoResponse>> GetAllPaginadoAsync(PagedRequest request, int? empresaId) => service.GetAllPaginadoAsync(request, empresaId);
}

public sealed class NominaRhEmpleadoDetalleAppService(INominaRhEmpleadoDetalleOperations service) : INominaRhEmpleadoDetalleAppService
{
    public Task<PagedResult<NominaRhEmpleadoDetalleResponse>> GetAllPaginadoAsync(PagedRequest request, int? empresaId) => service.GetAllPaginadoAsync(request, empresaId);
}
