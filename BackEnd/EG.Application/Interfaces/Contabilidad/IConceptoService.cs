using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;

namespace EG.Application.Interfaces.Contabilidad
{
    public interface IConceptoService
    {
        Task<PagedResult<ConceptoResponse>> GetAllAsync();
        Task<ConceptoResponse?> GetByIdAsync(int id);
        Task<ConceptoResponse> CreateAsync(ConceptoResponse response, int usuarioId);
        Task<ConceptoResponse?> UpdateAsync(int id, ConceptoResponse response, int usuarioId);
        Task DeleteAsync(int id);
        Task<PagedResult<ConceptoResponse>> GetAllPaginadoAsync(PagedRequest request);
    }
}
