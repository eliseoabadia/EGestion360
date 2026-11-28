using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Application.Interfaces.Contabilidad;
using EG.Business.Interfaces;

namespace EG.ApiCoreBS.Services.Contabilidad;

public sealed class MatrizIngresoService(IMatrizIngresoOperations service) : IMatrizIngresoService
{
    public Task<IEnumerable<MatrizIngresoResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<MatrizIngresoResponse?> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<MatrizIngresoResponse> CreateAsync(MatrizIngresoResponse request, int usuarioId) => service.CreateAsync(request, usuarioId);
    public Task<MatrizIngresoResponse?> UpdateAsync(int id, MatrizIngresoResponse request, int usuarioId) => service.UpdateAsync(id, request, usuarioId);
    public Task DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<MatrizIngresoResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
    public Task<PagedResult<MatrizIngresoResponse>> GetAllPaginadoAsync(PagedRequest request, int usuarioId) => service.GetAllPaginadoAsync(request, usuarioId);
    public Task<IEnumerable<object>> GetProgramasAsync() => service.GetProgramasAsync();
    public Task<IEnumerable<object>> GetOrigenAsync() => service.GetOrigenAsync();
    public Task<IEnumerable<object>> GetCuentaContableAsync() => service.GetCuentaContableAsync();
    public Task<PagedResult<LookupItem>> GetProgramaLookupPaginadoAsync(int page, int pageSize, string? filter, int? idAnio) => service.GetProgramaLookupPaginadoAsync(page, pageSize, filter, idAnio);
    public Task<PagedResult<LookupItem>> GetOrigenLookupPaginadoAsync(int page, int pageSize, string? filter) => service.GetOrigenLookupPaginadoAsync(page, pageSize, filter);
    public Task<PagedResult<LookupItem>> GetCuentaContableLookupPaginadoAsync(int page, int pageSize, string? filter) => service.GetCuentaContableLookupPaginadoAsync(page, pageSize, filter);
}
