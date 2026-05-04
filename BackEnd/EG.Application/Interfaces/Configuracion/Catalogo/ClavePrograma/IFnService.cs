using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;

namespace EG.Application.Interfaces.Configuracion.Catalogo.ClavePrograma
{
    public interface IFnService
    {
        Task<IEnumerable<FnResponse>> GetAllAsync();
        Task<FnResponse?> GetByIdAsync(int id);
        Task<FnResponse> AddAsync(FnDto dto, int usuarioId);
        Task UpdateAsync(int id, FnDto dto, int usuarioId);
        Task DeleteAsync(int id);
        Task<PagedResult<FnResponse>> GetAllPaginadoAsync(PagedRequest request);
        Task<bool> CanAddAsync(FnDto dto);
        Task<bool> CanUpdateAsync(int id, FnDto dto);
    }
}
