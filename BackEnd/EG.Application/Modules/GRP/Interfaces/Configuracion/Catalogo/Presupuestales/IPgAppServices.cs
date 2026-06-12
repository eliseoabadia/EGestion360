using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales
{
    public interface IPgAppServices
    {
        Task<IEnumerable<PgResponse>> GetAllAsync();
        Task<PgResponse> GetByIdAsync(int id);
        Task<PagedResult<PgResponse>> GetAllPaginadoAsync(PagedRequest pageRequest, Func<PgResponse, bool>? predicate = null);
        Task<PgResponse> CreateAsync(PgResponse response, int usuarioCreacion);
        Task<PgResponse> UpdateAsync(int id, PgResponse response, int usuarioModificacion);
        Task<bool> DeleteAsync(int id, int usuarioActual);
        Task<bool> ExistsAsync(int id);
    }
}
