using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;

namespace EG.Application.Interfaces.Configuracion.Catalogo.ClavePrograma
{
    public interface ISfService
    {
        Task<IEnumerable<SubFuncionResponse>> GetAllAsync();
        Task<SubFuncionResponse?> GetByIdAsync(int id);
        Task<SubFuncionResponse> AddAsync(SubFuncionDto dto, int usuarioId);
        Task UpdateAsync(int id, SubFuncionDto dto, int usuarioId);
        Task DeleteAsync(int id);
        Task<string?> GetDeleteBlockReasonAsync(int id);
        Task<PagedResult<SubFuncionResponse>> GetAllPaginadoAsync(PagedRequest request);
        Task<bool> CanAddAsync(SubFuncionDto dto);
        Task<bool> CanUpdateAsync(int id, SubFuncionDto dto);
    }
}
