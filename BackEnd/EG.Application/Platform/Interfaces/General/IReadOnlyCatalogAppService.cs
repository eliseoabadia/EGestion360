using EG.Common.GenericModel;

namespace EG.Application.Interfaces.General;

public interface IReadOnlyCatalogAppService<TResponse> where TResponse : class
{
    Task<IEnumerable<TResponse>> GetAllAsync();
    Task<TResponse?> GetByIdAsync(int id);
    Task<PagedResult<TResponse>> GetAllPaginadoAsync(PagedRequest request);
}
