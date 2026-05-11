using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales
{
    public interface IActividadInstitucionalAppServices
    {
        Task<IEnumerable<ActividadInstitucionalResponse>> GetAllAsync();
        Task<ActividadInstitucionalResponse> GetByIdAsync(int id);
        Task<PagedResult<ActividadInstitucionalResponse>> GetAllPaginadoAsync(PagedRequest pageRequest, Func<ActividadInstitucionalResponse, bool>? predicate = null);
        Task<ActividadInstitucionalResponse> CreateAsync(ActividadInstitucionalResponse response, int usuarioCreacion);
        Task<ActividadInstitucionalResponse> UpdateAsync(int id, ActividadInstitucionalResponse response, int usuarioModificacion);
        Task<bool> DeleteAsync(int id, int usuarioActual);
        Task<bool> ExistsAsync(int id);
    }
}
