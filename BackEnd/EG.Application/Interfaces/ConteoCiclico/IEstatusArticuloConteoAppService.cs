using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;

namespace EG.Application.Interfaces.ConteoCiclico
{
    public interface IEstatusArticuloConteoAppService
    {
        Task<PagedResult<EstatusArticuloConteoResponse>> GetAllAsync();
        Task<EstatusArticuloConteoResponse> GetByIdAsync(int id);
        Task<PagedResult<EstatusArticuloConteoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest);
        Task<EstatusArticuloConteoResponse> CreateAsync(EstatusArticuloConteoDto dto, int usuarioActual);
        Task<EstatusArticuloConteoResponse> UpdateAsync(int id, EstatusArticuloConteoDto dto, int usuarioActual);
        Task<bool> DeleteAsync(int id, int usuarioActual);
    }
}