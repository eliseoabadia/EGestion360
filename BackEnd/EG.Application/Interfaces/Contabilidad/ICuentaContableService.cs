using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Contabilidad;

namespace EG.Application.Interfaces.Contabilidad
{
    public interface ICuentaContableService
    {
        Task<IEnumerable<CuentaContableResponse>> GetAllAsync();
        Task<CuentaContableResponse?> GetByIdAsync(int id);
        Task<CuentaContableResponse> CreateAsync(CuentaContableResponse response, int usuarioId);
        Task<CuentaContableResponse?> UpdateAsync(int id, CuentaContableResponse response, int usuarioId);
        Task DeleteAsync(int id);
        Task<PagedResult<CuentaContableResponse>> GetAllPaginadoAsync(PagedRequest request);
        Task<List<LookupItem>> GetLookupAsync();
        Task<PagedResult<LookupItem>> GetLookupPaginadoAsync(int page, int pageSize, string? filter);
    }
}
