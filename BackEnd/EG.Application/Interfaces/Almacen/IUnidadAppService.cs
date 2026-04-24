using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;

namespace EG.Application.Interfaces.Almacen
{
    public interface IUnidadAppService
    {
        Task<PagedResult<UnidadResponse>> GetAllAsync();
        Task<UnidadResponse> GetByIdAsync(int id);
        Task<UnidadResponse> CreateAsync(UnidadDto dto, int usuarioActual);
        Task<UnidadResponse> UpdateAsync(int id, UnidadDto dto, int usuarioActual);
        Task<bool> DeleteAsync(int id);
        Task<PagedResult<UnidadResponse>> GetAllPaginadoAsync(PagedRequest pageRequest);
    }
}