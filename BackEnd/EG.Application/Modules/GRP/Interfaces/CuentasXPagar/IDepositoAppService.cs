using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.CuentasXPagar;

namespace EG.Application.Interfaces.CuentasXPagar
{
    public interface IDepositoAppService : IAdquisicionCrudAppService<DepositoResponse>
    {
        Task<PagedResult<DepositoResponse>> AutorizarAsync(int id);
        Task<PagedResult<DepositoPolizaResponse>> GetPolizaAsync(int id);
        Task<PagedResult<LookupItem>> GetIngresoAutorizadoLookupPaginadoAsync(int page, int pageSize, string? filter, int? idAnio);
        Task<PagedResult<LookupItem>> GetCLCFacturaLookupPaginadoAsync(int page, int pageSize, string? filter);
        Task<PagedResult<LookupItem>> GetTipoDoctoPagoLookupPaginadoAsync(int page, int pageSize, string? filter);
        Task<PagedResult<LookupItem>> GetCuentaContableLookupPaginadoAsync(int page, int pageSize, string? filter);
    }
}
