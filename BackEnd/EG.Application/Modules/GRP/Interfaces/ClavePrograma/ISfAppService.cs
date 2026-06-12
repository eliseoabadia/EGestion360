using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Domain.DTOs.Responses;

namespace EG.Application.Interfaces.ClavePrograma
{
    public interface ISfAppService
    {
        Task<PagedResult<SubFuncionResponse>> GetAllAsync();
        Task<PagedResult<SubFuncionResponse>> GetByIdAsync(int id);
        Task<PagedResult<SubFuncionResponse>> GetAllPaginadoAsync(PagedRequest request);
        Task<PagedResult<SubFuncionResponse>> CreateAsync(SubFuncionResponse request, int usuarioActual);
        Task<PagedResult<SubFuncionResponse>> UpdateAsync(int id, SubFuncionResponse request, int usuarioActual);
        Task<PagedResult<SubFuncionResponse>> DeleteAsync(int id);
        Task<PagedResult<SubFuncionResponse>> BuscarAsync(BusquedaRequest request);
    }
}
