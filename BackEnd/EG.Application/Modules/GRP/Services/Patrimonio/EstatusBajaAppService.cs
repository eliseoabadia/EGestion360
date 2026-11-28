using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Application.Interfaces.Patrimonio;
using EG.Business.Interfaces;

namespace EG.Application.Services.Patrimonio;

public sealed class EstatusBajaAppService(IEstatusBajaOperations service) : IEstatusBajaAppService
{
    public Task<PagedResult<EstatusBajaResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<EstatusBajaResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<EstatusBajaResponse>> CreateAsync(EstatusBajaResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<EstatusBajaResponse>> UpdateAsync(int id, EstatusBajaResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<EstatusBajaResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
}
