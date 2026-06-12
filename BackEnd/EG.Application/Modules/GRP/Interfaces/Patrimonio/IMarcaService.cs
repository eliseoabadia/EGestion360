using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Application.Interfaces.Patrimonio
{
    public interface IMarcaService
    {
        Task<PagedResult<MarcaResponse>> GetAllAsync();
        Task<PagedResult<MarcaResponse>> GetByIdAsync(int id);
        Task<PagedResult<MarcaResponse>> CreateAsync(MarcaResponse request);
        Task<PagedResult<MarcaResponse>> UpdateAsync(int id, MarcaResponse request);
        Task<PagedResult<bool>> DeleteAsync(int id);
        Task<PagedResult<MarcaResponse>> GetAllPaginadoAsync(PagedRequest request);
    }
}
