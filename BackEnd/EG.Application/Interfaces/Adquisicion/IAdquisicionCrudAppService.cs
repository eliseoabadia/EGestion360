using EG.Common.GenericModel;

namespace EG.Application.Interfaces.Adquisicion
{
    public interface IAdquisicionCrudAppService<TResponse>
        where TResponse : class
    {
        Task<PagedResult<TResponse>> GetAllAsync();
        Task<PagedResult<TResponse>> GetByIdAsync(int id);
        Task<PagedResult<TResponse>> CreateAsync(TResponse response, int usuarioActual);
        Task<PagedResult<TResponse>> UpdateAsync(int id, TResponse response, int usuarioActual);
        Task<PagedResult<bool>> DeleteAsync(int id);
        Task<PagedResult<TResponse>> GetAllPaginadoAsync(PagedRequest request);
    }
}
