using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Tesoreria
{
    public interface ITipoInversionService
    {
        Task<TipoInversionResponse?> GetByIdAsync(int id);
        Task<TipoInversionResponse> CreateAsync(TipoInversionDto dto, int usuarioId);
        Task<TipoInversionResponse?> UpdateAsync(int id, TipoInversionDto dto, int usuarioId);
        Task DeleteAsync(int id);
        Task<PagedResult<TipoInversionResponse>> GetAllPaginadoAsync(PagedRequest request);
    }
}
