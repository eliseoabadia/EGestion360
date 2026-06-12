using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales
{
    public interface IProgramaAppServices
    {
        Task<IEnumerable<ProgramaResponse>> GetAllAsync();
        Task<ProgramaResponse> GetByIdAsync(int id);
        Task<PagedResult<ProgramaResponse>> GetAllPaginadoAsync(PagedRequest pageRequest, Func<ProgramaResponse, bool>? predicate = null);
        Task<ProgramaResponse> CreateAsync(ProgramaResponse response, int usuarioCreacion);
        Task<ProgramaResponse> UpdateAsync(int id, ProgramaResponse response, int usuarioModificacion);
        Task<bool> DeleteAsync(int id, int usuarioActual);
        Task<bool> ExistsAsync(int id);
    }
}
