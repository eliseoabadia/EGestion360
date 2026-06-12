using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;

namespace EG.Application.Interfaces.Contabilidad
{
    public interface ITipoPolizaService
    {
        Task<IEnumerable<TipoPolizaResponse>> GetAllAsync();
        Task<TipoPolizaResponse?> GetByIdAsync(int id);
        Task<TipoPolizaResponse> AddAsync(TipoPolizaDto dto, int usuarioId);
        Task UpdateAsync(int id, TipoPolizaDto dto, int usuarioId);
        Task DeleteAsync(int id);
        Task<PagedResult<TipoPolizaResponse>> GetAllPaginadoAsync(PagedRequest request);
        Task<bool> CanAddAsync(TipoPolizaDto dto);
        Task<bool> CanUpdateAsync(int id, TipoPolizaDto dto);
    }
}
