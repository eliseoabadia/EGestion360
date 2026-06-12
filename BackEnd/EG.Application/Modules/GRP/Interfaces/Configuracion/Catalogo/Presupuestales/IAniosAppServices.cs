using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales
{
    public interface IAniosAppServices
    {
        Task<IEnumerable<AniosResponse>> GetAllAsync();
        Task<AniosResponse> GetByIdAsync(int id);
        Task<PagedResult<AniosResponse>> GetAllPaginadoAsync(PagedRequest pageRequest, Func<AniosResponse, bool>? predicate = null);
        Task<AniosResponse> CreateAsync(AniosResponse response, int usuarioCreacion);
        Task<AniosResponse> UpdateAsync(int id, AniosResponse response, int usuarioModificacion);
        Task<bool> DeleteAsync(int id, int usuarioActual);
        Task<bool> ExistsAsync(int id);
    }
}
