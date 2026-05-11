using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Almacen
{
    public interface IMotivoEsService
    {
        Task<MotivoEsResponse?> GetByIdAsync(int id);
        Task<MotivoEsResponse> CreateAsync(MotivoEsDto dto, int usuarioId);
        Task<MotivoEsResponse?> UpdateAsync(int id, MotivoEsDto dto, int usuarioId);
        Task DeleteAsync(int id);
        Task<PagedResult<MotivoEsResponse>> GetAllPaginadoAsync(PagedRequest request);
        Task<object> GetAllPaginadoAsync(int page, int pageSize, string? sortBy, string? sortDirection, string? filter);
    }
}
