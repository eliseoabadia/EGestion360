using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;

namespace EG.Application.Interfaces.General
{
    public interface IUsuarioSucursalAppService
    {
        Task<PagedResult<UsuarioSucursalResponse>> GetAllAsync();
        Task<UsuarioSucursalResponse> GetByIdAsync(int id);
        Task<UsuarioSucursalResponse> GetByUsuarioAndSucursalAsync(int usuarioId, int sucursalId);
        Task<PagedResult<UsuarioSucursalResponse>> GetByUsuarioAsync(int usuarioId);
        Task<PagedResult<UsuarioSucursalResponse>> GetBySucursalAsync(int sucursalId);
        Task<PagedResult<UsuarioSucursalResponse>> GetGerentesBySucursalAsync(int sucursalId);
        Task<UsuarioSucursalResponse> AddAsync(UsuarioSucursalResponse dto, int usuarioActual);
        Task<bool> DeleteAsync(int usuarioId, int sucursalId, int usuarioActual);
        Task<PagedResult<UsuarioSucursalResponse>> GetAllPaginadoAsync(PagedRequest pageRequest);
    }
}
