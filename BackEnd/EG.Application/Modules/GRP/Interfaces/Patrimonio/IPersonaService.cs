using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Application.Interfaces.Patrimonio
{
    public interface IPersonaService
    {
        Task<PagedResult<PersonaResponse>> GetAllAsync();
        Task<PagedResult<PersonaResponse>> GetByIdAsync(int id);
        Task<PagedResult<PersonaResponse>> CreateAsync(PersonaResponse request);
        Task<PagedResult<PersonaResponse>> UpdateAsync(int id, PersonaResponse request);
        Task<PagedResult<bool>> DeleteAsync(int id);
        Task<PagedResult<PersonaResponse>> GetAllPaginadoAsync(PagedRequest request);
        Task<PagedResult<PersonaResponse>> BuscarAsync(BusquedaRequest request);
    }
}
