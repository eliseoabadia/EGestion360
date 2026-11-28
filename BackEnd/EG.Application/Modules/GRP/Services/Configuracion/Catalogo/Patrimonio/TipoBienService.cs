using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Application.Interfaces.Patrimonio;
using EG.Business.Interfaces;

namespace EG.Application.Services.Configuracion.Catalogo.Patrimonio;

public sealed class TipoBienService(ITipoBienOperations service) : ITipoBienService
{
    public Task<PagedResult<TipoBienResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<TipoBienResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<TipoBienResponse>> CreateAsync(TipoBienResponse request) => service.CreateAsync(request);
    public Task<PagedResult<TipoBienResponse>> UpdateAsync(int id, TipoBienResponse request) => service.UpdateAsync(id, request);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<TipoBienResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
}
