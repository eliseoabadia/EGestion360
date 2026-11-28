using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Presupuestales;

namespace EG.Business.Interfaces;

public interface IIngresoAutorizadoOperations
{
    Task<PagedResult<IngresoAutorizadoResponse>> GetAllAsync();
    Task<PagedResult<IngresoAutorizadoResponse>> GetByIdAsync(int id);
    Task<PagedResult<IngresoAutorizadoResponse>> CreateAsync(IngresoAutorizadoResponse response, int usuarioActual);
    Task<PagedResult<IngresoAutorizadoResponse>> UpdateAsync(int id, IngresoAutorizadoResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<IngresoAutorizadoResponse>> GetAllPaginadoAsync(PagedRequest request);
    Task<PagedResult<IngresoAutorizadoResponse>> AutorizarAsync(int id);
    Task<PagedResult<IngresoAutorizadoPolizaResponse>> GetPolizaAsync(int id);
    Task<PagedResult<LookupItem>> GetProgramaLookupPaginadoAsync(int page, int pageSize, string? filter, int? idAnio);
    Task<PagedResult<LookupItem>> GetOrigenLookupPaginadoAsync(int page, int pageSize, string? filter);
    Task<PagedResult<LookupItem>> GetFuenteFinanciamientoLookupPaginadoAsync(int page, int pageSize, string? filter);
    Task<PagedResult<LookupItem>> GetTipoGastoLookupPaginadoAsync(int page, int pageSize, string? filter);
    Task<PagedResult<LookupItem>> GetDigitoIdentificadorLookupPaginadoAsync(int page, int pageSize, string? filter);
    Task<PagedResult<LookupItem>> GetDestinoGastoLookupPaginadoAsync(int page, int pageSize, string? filter);
}
