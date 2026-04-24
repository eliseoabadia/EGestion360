using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;

namespace EG.Application.Interfaces.ConteoCiclico
{
    public interface IConteoDetalleAppService
    {
        Task<PagedResult<ConteoDetalleResponse>> GetAllAsync();
        Task<ConteoDetalleResponse> GetByIdAsync(int id);
        Task<ConteoDetalleResponse> CreateAsync(ConteoDetalleDto dto, int usuarioActual);
        Task<ConteoDetalleResponse> UpdateAsync(int id, ConteoDetalleDto dto, int usuarioActual);
        Task<bool> DeleteAsync(int id);
    }
}