using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Business.Interfaces;

namespace EG.Application.Services.Configuracion.Catalogo.Presupuestales;

public sealed class IngresoAutorizadoAppService(IIngresoAutorizadoOperations service) : IIngresoAutorizadoAppService
{
    public Task<PagedResult<IngresoAutorizadoResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<IngresoAutorizadoResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<IngresoAutorizadoResponse>> CreateAsync(IngresoAutorizadoResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<IngresoAutorizadoResponse>> UpdateAsync(int id, IngresoAutorizadoResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<IngresoAutorizadoResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
    public Task<PagedResult<IngresoAutorizadoResponse>> AutorizarAsync(int id) => service.AutorizarAsync(id);
    public Task<PagedResult<IngresoAutorizadoPolizaResponse>> GetPolizaAsync(int id) => service.GetPolizaAsync(id);
    public Task<PagedResult<LookupItem>> GetProgramaLookupPaginadoAsync(int page, int pageSize, string? filter, int? idAnio) => service.GetProgramaLookupPaginadoAsync(page, pageSize, filter, idAnio);
    public Task<PagedResult<LookupItem>> GetOrigenLookupPaginadoAsync(int page, int pageSize, string? filter) => service.GetOrigenLookupPaginadoAsync(page, pageSize, filter);
    public Task<PagedResult<LookupItem>> GetFuenteFinanciamientoLookupPaginadoAsync(int page, int pageSize, string? filter) => service.GetFuenteFinanciamientoLookupPaginadoAsync(page, pageSize, filter);
    public Task<PagedResult<LookupItem>> GetTipoGastoLookupPaginadoAsync(int page, int pageSize, string? filter) => service.GetTipoGastoLookupPaginadoAsync(page, pageSize, filter);
    public Task<PagedResult<LookupItem>> GetDigitoIdentificadorLookupPaginadoAsync(int page, int pageSize, string? filter) => service.GetDigitoIdentificadorLookupPaginadoAsync(page, pageSize, filter);
    public Task<PagedResult<LookupItem>> GetDestinoGastoLookupPaginadoAsync(int page, int pageSize, string? filter) => service.GetDestinoGastoLookupPaginadoAsync(page, pageSize, filter);
}
