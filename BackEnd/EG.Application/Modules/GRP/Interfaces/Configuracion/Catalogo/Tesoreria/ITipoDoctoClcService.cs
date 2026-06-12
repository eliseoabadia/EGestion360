using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Tesoreria
{
    public interface ITipoDoctoClcService
    {
        Task<TipoDoctoClcResponse?> GetByIdAsync(int id);
        Task<TipoDoctoClcResponse> CreateAsync(TipoDoctoClcDto dto, int usuarioId);
        Task<TipoDoctoClcResponse?> UpdateAsync(int id, TipoDoctoClcDto dto, int usuarioId);
        Task DeleteAsync(int id);
        Task<PagedResult<TipoDoctoClcResponse>> GetAllPaginadoAsync(PagedRequest request);
    }
}
