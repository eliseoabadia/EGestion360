using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Tesoreria
{
    public interface ITipoCambioService
    {
        Task<TipoCambioResponse?> GetByIdAsync(int id);
        Task<TipoCambioResponse> CreateAsync(TipoCambioDto dto, int usuarioId);
        Task<TipoCambioResponse?> UpdateAsync(int id, TipoCambioDto dto, int usuarioId);
        Task DeleteAsync(int id);
        Task<PagedResult<TipoCambioResponse>> GetAllPaginadoAsync(PagedRequest request);
    }
}
