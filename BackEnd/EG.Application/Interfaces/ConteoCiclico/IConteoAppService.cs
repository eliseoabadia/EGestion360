using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;

namespace EG.Application.Interfaces.ConteoCiclico
{
    public interface IConteoAppService
    {
        Task<PagedResult<ConteoResponse>> GetAllAsync();
        Task<ConteoResponse> GetByIdAsync(int id);
        Task<ConteoResponse> CreateAsync(ConteoDto dto, int usuarioActual);
        Task<ConteoResponse> UpdateAsync(int id, ConteoDto dto, int usuarioActual);
        Task<bool> DeleteAsync(int id);
        Task<PagedResult<ConteoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest);
    }
}