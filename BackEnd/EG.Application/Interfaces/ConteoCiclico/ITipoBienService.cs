using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;

namespace EG.Application.Interfaces.ConteoCiclico
{
    public interface ITipoBienService
    {
        Task<PagedResult<TipoBienResponse>> GetAllPagedAsync(int page, int pageSize, string search = null, string sortColumn = null, string sortOrder = "asc");
        Task<TipoBienResponse> GetByIdAsync(int id);
        Task<TipoBienResponse> CreateAsync(TipoBienDto dto, int usuarioId);
        Task<TipoBienResponse> UpdateAsync(int id, TipoBienDto dto, int usuarioId);
        Task<bool> DeleteAsync(int id, int usuarioId); // eliminación lógica

        // Para usar la vista optimizada
        Task<PagedResult<TipoBienResponse>> GetFromViewPagedAsync(int page, int pageSize, string search = null, string sortColumn = null, string sortOrder = "asc");
    }


}