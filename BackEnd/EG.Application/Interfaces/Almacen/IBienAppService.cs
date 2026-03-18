using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;

namespace EG.Application.Interfaces.Almacen
{
    public interface IBienAppService
    {
        Task<PagedResult<BienResponse>> GetAllAsync();
        Task<BienResponse> GetByIdAsync(int id);
        Task<PagedResult<BienResponse>> GetAllPaginadoAsync(PagedRequest request);
        Task<BienResponse> CreateAsync(BienDto dto, int usuarioActual);
        Task<BienResponse> UpdateAsync(int id, BienDto dto, int usuarioActual);
        Task DeleteAsync(int id);
    }
}