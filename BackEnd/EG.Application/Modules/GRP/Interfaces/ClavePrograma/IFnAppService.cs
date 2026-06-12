using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Domain.DTOs.Responses;

namespace EG.Application.Interfaces.ClavePrograma
{
    public interface IFnAppService
    {
        Task<PagedResult<FnResponse>> GetAllAsync();
        Task<PagedResult<FnResponse>> GetByIdAsync(int id);
        Task<PagedResult<FnResponse>> GetAllPaginadoAsync(PagedRequest request);
        Task<PagedResult<FnResponse>> CreateAsync(FnResponse request, int usuarioActual);
        Task<PagedResult<FnResponse>> UpdateAsync(int id, FnResponse request, int usuarioActual);
        Task<PagedResult<FnResponse>> DeleteAsync(int id);
        Task<PagedResult<FnResponse>> BuscarAsync(BusquedaRequest request);
    }
}
