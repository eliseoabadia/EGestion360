using EG.Application.Interfaces.General;
using EG.Business.Services;
using EG.Common.GenericModel;

namespace EG.Application.Services.General;

public sealed class ReadOnlyCatalogAppService<TEntity, TDto, TResponse>(
    GenericService<TEntity, TDto, TResponse> service, string idPropertyName) : IReadOnlyCatalogAppService<TResponse>
    where TEntity : class
    where TDto : class
    where TResponse : class
{
    public Task<IEnumerable<TResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<TResponse?> GetByIdAsync(int id) => service.GetByIdAsync(id, idPropertyName: idPropertyName);
    public Task<PagedResult<TResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
}
