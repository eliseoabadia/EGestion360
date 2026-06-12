using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales
{
    public interface ITipoRecursoAppServices
    {
        Task<IEnumerable<TipoRecursoResponse>> GetAllAsync();
        Task<TipoRecursoResponse> GetByIdAsync(int id);
        Task<PagedResult<TipoRecursoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest, Func<TipoRecursoResponse, bool>? predicate = null);
        Task<TipoRecursoResponse> CreateAsync(TipoRecursoResponse response, int usuarioCreacion);
        Task<TipoRecursoResponse> UpdateAsync(int id, TipoRecursoResponse response, int usuarioModificacion);
        Task<bool> DeleteAsync(int id, int usuarioActual);
        Task<bool> ExistsAsync(int id);
    }
}
