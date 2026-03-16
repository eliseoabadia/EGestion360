using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;

namespace EG.Application.Interfaces.General
{
    public interface ITipoConteoAppService
    {
        Task<PagedResult<TipoConteoResponse>> GetAllAsync();
        Task<TipoConteoResponse> GetByIdAsync(int id);
        Task<PagedResult<TipoConteoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest);
        Task<TipoConteoResponse> CreateAsync(TipoConteoDto dto, int usuarioActual);
        Task<TipoConteoResponse> UpdateAsync(int id, TipoConteoDto dto, int usuarioActual);
        Task<bool> DeleteAsync(int id, int usuarioActual);
    }
}