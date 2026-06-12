using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Application.Interfaces.Patrimonio
{
    public interface IFamiliaService
    {
        Task<PagedResult<FamiliaResponse>> GetAllAsync();
        Task<PagedResult<FamiliaResponse>> GetByIdAsync(int id);
        Task<PagedResult<FamiliaResponse>> CreateAsync(FamiliaResponse request);
        Task<PagedResult<FamiliaResponse>> UpdateAsync(int id, FamiliaResponse request);
        Task<PagedResult<bool>> DeleteAsync(int id);
        Task<PagedResult<FamiliaResponse>> GetAllPaginadoAsync(PagedRequest request);
        Task<PagedResult<FamiliaResponse>> BuscarAsync(BusquedaRequest request);
    }
}
