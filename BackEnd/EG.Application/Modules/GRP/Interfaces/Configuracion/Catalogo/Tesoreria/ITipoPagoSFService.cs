using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Tesoreria
{
    public interface ITipoPagoSFService
    {
        Task<TipoPagoSFResponse?> GetByIdAsync(int id);
        Task<TipoPagoSFResponse> CreateAsync(TipoPagoSFDto dto, int usuarioId);
        Task<TipoPagoSFResponse?> UpdateAsync(int id, TipoPagoSFDto dto, int usuarioId);
        Task DeleteAsync(int id);
        Task<PagedResult<TipoPagoSFResponse>> GetAllPaginadoAsync(PagedRequest request);
    }
}
