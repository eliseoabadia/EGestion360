using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Application.Interfaces.Contabilidad;
using EG.Business.Interfaces;

namespace EG.ApiCoreBS.Services.Contabilidad;

public sealed class CuentaContableService(ICuentaContableOperations service) : ICuentaContableService
{
    public Task<IEnumerable<CuentaContableResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<CuentaContableResponse?> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<CuentaContableResponse> CreateAsync(CuentaContableResponse response, int usuarioId) => service.CreateAsync(response, usuarioId);
    public Task<CuentaContableResponse?> UpdateAsync(int id, CuentaContableResponse response, int usuarioId) => service.UpdateAsync(id, response, usuarioId);
    public Task DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<CuentaContableResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
    public Task<List<LookupItem>> GetLookupAsync() => service.GetLookupAsync();
    public Task<PagedResult<LookupItem>> GetLookupPaginadoAsync(int page, int pageSize, string? filter) => service.GetLookupPaginadoAsync(page, pageSize, filter);
}
