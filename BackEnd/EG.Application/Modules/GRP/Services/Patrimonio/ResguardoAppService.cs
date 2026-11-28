using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Application.Interfaces.Patrimonio;
using EG.Business.Interfaces;

namespace EG.Application.Services.Patrimonio;

public sealed class ResguardoAppService(IResguardoOperations service) : IResguardoAppService
{
    public Task<PagedResult<ResguardoResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<ResguardoResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<ResguardoResponse>> CreateAsync(ResguardoResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<ResguardoResponse>> UpdateAsync(int id, ResguardoResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<ResguardoResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
}
