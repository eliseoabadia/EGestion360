using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Application.Interfaces.Patrimonio;
using EG.Business.Interfaces;

namespace EG.Application.Services.Patrimonio;

public sealed class BajaAppService(IBajaOperations service) : IBajaAppService
{
    public Task<PagedResult<BajaResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<BajaResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<BajaResponse>> CreateAsync(BajaResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<BajaResponse>> UpdateAsync(int id, BajaResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<BajaResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
    public Task<EG.Common.GenericModel.PagedResult<BajaResponse>> AplicarAsync(int id, int fkidAnioSis, int usuarioActual) => service.AplicarAsync(id, fkidAnioSis, usuarioActual);
}
