using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Tesoreria
{
    public interface ITipoPagoService
    {
        Task<TipoPagoResponse?> GetByIdAsync(int id);
        Task<TipoPagoResponse> CreateAsync(TipoPagoDto dto, int usuarioId);
        Task<TipoPagoResponse?> UpdateAsync(int id, TipoPagoDto dto, int usuarioId);
        Task DeleteAsync(int id);
        Task<PagedResult<TipoPagoResponse>> GetAllPaginadoAsync(PagedRequest request);
    }
}
