using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales
{
    public interface IProgramaPresupuestalAppServices
    {
        Task<IEnumerable<ProgramaPresupuestalResponse>> GetAllAsync();
        Task<ProgramaPresupuestalResponse> GetByIdAsync(int id);
        Task<PagedResult<ProgramaPresupuestalResponse>> GetAllPaginadoAsync(PagedRequest pageRequest, Func<ProgramaPresupuestalResponse, bool>? predicate = null);
        Task<ProgramaPresupuestalResponse> CreateAsync(ProgramaPresupuestalResponse response, int usuarioCreacion);
        Task<ProgramaPresupuestalResponse> UpdateAsync(int id, ProgramaPresupuestalResponse response, int usuarioModificacion);
        Task<bool> DeleteAsync(int id, int usuarioActual);
        Task<bool> ExistsAsync(int id);
    }
}
