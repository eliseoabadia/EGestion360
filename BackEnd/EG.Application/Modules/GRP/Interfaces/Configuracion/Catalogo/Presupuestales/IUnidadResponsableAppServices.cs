using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales
{
    public interface IUnidadResponsableAppServices
    {
        Task<IEnumerable<UnidadResponsableResponse>> GetAllAsync();
        Task<UnidadResponsableResponse> GetByIdAsync(int id);
        Task<PagedResult<UnidadResponsableResponse>> GetAllPaginadoAsync(PagedRequest pageRequest);
        Task<UnidadResponsableResponse> CreateAsync(UnidadResponsableResponse response, int usuarioCreacion);
        Task<UnidadResponsableResponse> UpdateAsync(int id, UnidadResponsableResponse response, int usuarioModificacion);
        Task<bool> DeleteAsync(int id, int usuarioActual);
    }
}
