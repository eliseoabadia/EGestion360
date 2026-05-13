using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;

namespace EG.Application.Interfaces.General
{
    public interface IEstadoAppService
    {
        Task<PagedResult<EstadoResponse>> GetAllAsync();
        Task<EstadoResponse> GetByIdAsync(int id);
        Task<PagedResult<EstadoResponse>> GetAllPaginadoAsync(PagedRequest request);
        Task<EstadoResponse> CreateAsync(EstadoDto dto, int usuarioActual);
        Task<EstadoResponse> UpdateAsync(int id, EstadoDto dto, int usuarioActual);
        Task<bool> DeleteAsync(int id);
    }
}