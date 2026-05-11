using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales
{
    public interface IRamoAppServices
    {
        Task<IEnumerable<RamoResponse>> GetAllAsync();
        Task<RamoResponse> GetByIdAsync(int id);
        Task<PagedResult<RamoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest, Func<RamoResponse, bool>? predicate = null);
        Task<RamoResponse> CreateAsync(RamoResponse response, int usuarioCreacion);
        Task<RamoResponse> UpdateAsync(int id, RamoResponse response, int usuarioModificacion);
        Task<bool> DeleteAsync(int id, int usuarioActual);
        Task<bool> ExistsAsync(int id);
    }
}
