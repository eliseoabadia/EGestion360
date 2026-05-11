using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;

namespace EG.Application.Interfaces.Contabilidad
{
    public interface ITipoDetallePolizaService
    {
        Task<IEnumerable<TipoDetallePolizaResponse>> GetAllAsync();
        Task<TipoDetallePolizaResponse?> GetByIdAsync(int id);
        Task<TipoDetallePolizaResponse> CreateAsync(TipoDetallePolizaResponse response, int usuarioId);
        Task<TipoDetallePolizaResponse?> UpdateAsync(int id, TipoDetallePolizaResponse response, int usuarioId);
        Task DeleteAsync(int id);
        Task<PagedResult<TipoDetallePolizaResponse>> GetAllPaginadoAsync(PagedRequest request);
    }
}
