using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Nomina;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Patrimonio
{
    public interface IPersonaAppService
    {
        Task<PagedResult<PersonaResponse>> GetAllAsync();
        Task<PersonaResponse?> GetByIdAsync(int id);
        Task<PagedResult<PersonaResponse>> GetByEmpresaIdAsync(int empresaId);
        Task<PagedResult<PersonaResponse>> GetAllPaginadoAsync(PagedRequest pageRequest);
        Task<PersonaResponse> CreateAsync(PersonaDto dto, int usuarioCreacion);
        Task<PersonaResponse> UpdateAsync(int id, PersonaDto dto, int usuarioModificacion);
        Task<bool> DeleteAsync(int id, int usuarioEliminacion);
    }
}


