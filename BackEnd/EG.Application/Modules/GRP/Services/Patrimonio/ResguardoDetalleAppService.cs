using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Application.Interfaces.Patrimonio;
using EG.Business.Interfaces;

namespace EG.Application.Services.Patrimonio;

public sealed class ResguardoDetalleAppService(IResguardoDetalleOperations service) : IResguardoDetalleAppService
{
    public Task<PagedResult<ResguardoDetalleResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<ResguardoDetalleResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<ResguardoDetalleResponse>> CreateAsync(ResguardoDetalleResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<ResguardoDetalleResponse>> UpdateAsync(int id, ResguardoDetalleResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<ResguardoDetalleResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
}
