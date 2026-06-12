using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Contabilidad;

namespace EG.Application.Interfaces.Contabilidad
{
    public interface IMatrizIngresoService
    {
        Task<IEnumerable<MatrizIngresoResponse>> GetAllAsync();
        Task<MatrizIngresoResponse?> GetByIdAsync(int id);
        Task<MatrizIngresoResponse> CreateAsync(MatrizIngresoResponse request, int usuarioId);
        Task<MatrizIngresoResponse?> UpdateAsync(int id, MatrizIngresoResponse request, int usuarioId);
        Task DeleteAsync(int id);
        Task<PagedResult<MatrizIngresoResponse>> GetAllPaginadoAsync(PagedRequest request);
        Task<PagedResult<MatrizIngresoResponse>> GetAllPaginadoAsync(PagedRequest request, int usuarioId);
        Task<IEnumerable<object>> GetProgramasAsync();
        Task<IEnumerable<object>> GetOrigenAsync();
        Task<IEnumerable<object>> GetCuentaContableAsync();
        Task<PagedResult<LookupItem>> GetProgramaLookupPaginadoAsync(int page, int pageSize, string? filter, int? idAnio);
        Task<PagedResult<LookupItem>> GetOrigenLookupPaginadoAsync(int page, int pageSize, string? filter);
        Task<PagedResult<LookupItem>> GetCuentaContableLookupPaginadoAsync(int page, int pageSize, string? filter);
    }
}
