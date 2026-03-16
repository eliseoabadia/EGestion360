using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;

namespace EG.Application.Interfaces.General
{
    public interface IUsuarioSucursalAppService
    {
        Task<PagedResult<VwUsuarioSucursalResponse>> GetAllAsync();
        Task<VwUsuarioSucursalResponse> GetByIdAsync(int id);
        Task<VwUsuarioSucursalResponse> GetByUsuarioAndSucursalAsync(int usuarioId, int sucursalId);
        Task<PagedResult<VwUsuarioSucursalResponse>> GetByUsuarioAsync(int usuarioId);
        Task<PagedResult<VwUsuarioSucursalResponse>> GetBySucursalAsync(int sucursalId);
        Task<PagedResult<VwUsuarioSucursalResponse>> GetGerentesBySucursalAsync(int sucursalId);
        Task<VwUsuarioSucursalResponse> AddAsync(VwUsuarioSucursalResponse dto, int usuarioActual);
        Task<bool> DeleteAsync(int usuarioId, int sucursalId, int usuarioActual);
        Task<PagedResult<VwUsuarioSucursalResponse>> GetAllPaginadoAsync(PagedRequest pageRequest);
    }
}
