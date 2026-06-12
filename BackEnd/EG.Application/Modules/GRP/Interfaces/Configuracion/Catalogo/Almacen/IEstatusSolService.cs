using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Almacen
{
    public interface IEstatusSolService
    {
        Task<EstatusSolicitudResponse?> GetByIdAsync(int id);
        Task<EstatusSolicitudResponse> CreateAsync(EstatusSolicitudDto dto, int usuarioId);
        Task<EstatusSolicitudResponse?> UpdateAsync(int id, EstatusSolicitudDto dto, int usuarioId);
        Task DeleteAsync(int id);
        Task<PagedResult<EstatusSolicitudResponse>> GetAllPaginadoAsync(PagedRequest request);
        Task<object> GetAllPaginadoAsync(int page, int pageSize, string? sortBy, string? sortDirection, string? filter);
    }
}
