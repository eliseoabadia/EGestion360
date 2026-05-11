using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Tesoreria
{
    public interface ITipoMonedaService
    {
        Task<TipoMonedaResponse?> GetByIdAsync(int id);
        Task<TipoMonedaResponse> CreateAsync(TipoMonedaDto dto, int usuarioId);
        Task<TipoMonedaResponse?> UpdateAsync(int id, TipoMonedaDto dto, int usuarioId);
        Task DeleteAsync(int id);
        Task<PagedResult<TipoMonedaResponse>> GetAllPaginadoAsync(PagedRequest request);
    }
}
