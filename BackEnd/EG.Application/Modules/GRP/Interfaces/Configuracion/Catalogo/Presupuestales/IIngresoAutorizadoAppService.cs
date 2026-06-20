using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Presupuestales;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales
{
    public interface IIngresoAutorizadoAppService : IAdquisicionCrudAppService<IngresoAutorizadoResponse>
    {
        Task<PagedResult<IngresoAutorizadoResponse>> AutorizarAsync(int id);
        Task<PagedResult<IngresoAutorizadoPolizaResponse>> GetPolizaAsync(int id);
        Task<PagedResult<LookupItem>> GetProgramaLookupPaginadoAsync(int page, int pageSize, string? filter, int? idAnio);
        Task<PagedResult<LookupItem>> GetOrigenLookupPaginadoAsync(int page, int pageSize, string? filter);
        Task<PagedResult<LookupItem>> GetFuenteFinanciamientoLookupPaginadoAsync(int page, int pageSize, string? filter);
        Task<PagedResult<LookupItem>> GetTipoGastoLookupPaginadoAsync(int page, int pageSize, string? filter);
        Task<PagedResult<LookupItem>> GetDigitoIdentificadorLookupPaginadoAsync(int page, int pageSize, string? filter);
        Task<PagedResult<LookupItem>> GetDestinoGastoLookupPaginadoAsync(int page, int pageSize, string? filter);
    }
}
