using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Application.Interfaces.Patrimonio;
using EG.Business.Interfaces;

namespace EG.Application.Services.Patrimonio;

public sealed class TipoBajaAppService(ITipoBajaOperations service) : ITipoBajaAppService
{
    public Task<PagedResult<TipoBajaResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<TipoBajaResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<TipoBajaResponse>> CreateAsync(TipoBajaResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<TipoBajaResponse>> UpdateAsync(int id, TipoBajaResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<TipoBajaResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
}
