using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;
using EG.Application.Interfaces.General;
using EG.Business.Interfaces;

namespace EG.Application.Services.General;

public sealed class UsuarioSucursalAppService(IUsuarioSucursalOperations service) : IUsuarioSucursalAppService
{
    public Task<PagedResult<UsuarioSucursalResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<UsuarioSucursalResponse> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<UsuarioSucursalResponse> GetByUsuarioAndSucursalAsync(int usuarioId, int sucursalId) => service.GetByUsuarioAndSucursalAsync(usuarioId, sucursalId);
    public Task<PagedResult<UsuarioSucursalResponse>> GetByUsuarioAsync(int usuarioId) => service.GetByUsuarioAsync(usuarioId);
    public Task<PagedResult<UsuarioSucursalResponse>> GetBySucursalAsync(int sucursalId) => service.GetBySucursalAsync(sucursalId);
    public Task<PagedResult<UsuarioSucursalResponse>> GetGerentesBySucursalAsync(int sucursalId) => service.GetGerentesBySucursalAsync(sucursalId);
    public Task<UsuarioSucursalResponse> AddAsync(UsuarioSucursalResponse dto, int usuarioActual) => service.AddAsync(dto, usuarioActual);
    public Task<bool> DeleteAsync(int usuarioId, int sucursalId, int usuarioActual) => service.DeleteAsync(usuarioId, sucursalId, usuarioActual);
    public Task<PagedResult<UsuarioSucursalResponse>> GetAllPaginadoAsync(PagedRequest pageRequest) => service.GetAllPaginadoAsync(pageRequest);
}
