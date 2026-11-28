using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Application.Interfaces.General;
using EG.Business.Interfaces;

namespace EG.Application.Services.General;

public sealed class SucursalAppService(ISucursalService service) : ISucursalAppService
{
    public Task<PagedResult<SucursalResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<SucursalResponse> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<SucursalResponse>> GetAllPaginadoAsync(PagedRequest pageRequest) => service.GetAllPaginadoAsync(pageRequest);
    public Task<SucursalResponse> CreateAsync(SucursalDto dto, int usuarioActual) => service.CreateAsync(dto, usuarioActual);
    public Task<SucursalResponse> UpdateAsync(int id, SucursalDto dto, int usuarioActual) => service.UpdateAsync(id, dto, usuarioActual);
    public Task<bool> DeleteAsync(int id) => service.DeleteAsync(id);
}
