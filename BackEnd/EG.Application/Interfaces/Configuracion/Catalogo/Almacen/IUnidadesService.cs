using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Almacen;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Almacen
{
    public interface IUnidadesService
    {
        Task<UnidadeResponse?> GetByIdAsync(int id);
        Task<UnidadeResponse> CreateAsync(UnidadeDto dto, int usuarioId);
        Task<UnidadeResponse?> UpdateAsync(int id, UnidadeDto dto, int usuarioId);
        Task DeleteAsync(int id);
        Task<PagedResult<UnidadeResponse>> GetAllPaginadoAsync(PagedRequest request);
        Task<object> GetAllPaginadoAsync(int page, int pageSize, string? sortBy, string? sortDirection, string? filter);
        Task<List<LookupItem>> GetLookupAsync();
        Task<PagedResult<LookupItem>> GetLookupPaginadoAsync(int page, int pageSize, string? filter);
    }
}
