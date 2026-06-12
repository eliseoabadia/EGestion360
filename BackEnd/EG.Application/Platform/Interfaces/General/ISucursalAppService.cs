using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;

namespace EG.Application.Interfaces.General
{
    public interface ISucursalAppService
    {
        Task<PagedResult<SucursalResponse>> GetAllAsync();
        Task<SucursalResponse> GetByIdAsync(int id);
        Task<PagedResult<SucursalResponse>> GetAllPaginadoAsync(PagedRequest pageRequest);
        Task<SucursalResponse> CreateAsync(SucursalDto dto, int usuarioActual);
        Task<SucursalResponse> UpdateAsync(int id, SucursalDto dto, int usuarioActual);
        Task<bool> DeleteAsync(int id);
    }
}