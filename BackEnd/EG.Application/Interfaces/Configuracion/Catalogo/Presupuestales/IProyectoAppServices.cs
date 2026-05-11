using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales
{
    public interface IProyectoAppServices
    {
        Task<IEnumerable<ProyectoResponse>> GetAllAsync();
        Task<ProyectoResponse> GetByIdAsync(int id);
        Task<PagedResult<ProyectoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest, Func<ProyectoResponse, bool>? predicate = null);
        Task<ProyectoResponse> CreateAsync(ProyectoResponse response, int usuarioCreacion);
        Task<ProyectoResponse> UpdateAsync(int id, ProyectoResponse response, int usuarioModificacion);
        Task<bool> DeleteAsync(int id, int usuarioActual);
        Task<bool> ExistsAsync(int id);
    }
}
