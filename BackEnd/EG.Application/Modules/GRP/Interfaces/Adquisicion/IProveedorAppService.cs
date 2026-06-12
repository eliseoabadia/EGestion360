using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Application.Interfaces.Adquisicion
{
    public interface IProveedorAppService
    {
        Task<PagedResult<ProveedorResponse>> GetAllAsync();
        Task<PagedResult<ProveedorResponse>> GetByIdAsync(int id);
        Task<PagedResult<ProveedorResponse>> CreateAsync(ProveedorResponse response, int usuarioActual);
        Task<PagedResult<ProveedorResponse>> UpdateAsync(int id, ProveedorResponse response, int usuarioActual);
        Task<PagedResult<bool>> DeleteAsync(int id);
        Task<PagedResult<ProveedorResponse>> GetAllPaginadoAsync(PagedRequest request);
    }
}
