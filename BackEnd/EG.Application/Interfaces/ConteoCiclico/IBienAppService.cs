using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;

namespace EG.Application.Interfaces.ConteoCiclico
{
    public interface IBienAppService
    {
        Task<PagedResult<BienResponse>> GetAllAsync();
        Task<BienResponse> GetByIdAsync(int id);
        Task<PagedResult<BienResponse>> GetAllPaginadoAsync(PagedRequest pageRequest);

        Task<PagedResult<BienResponse>> GetByPeriodoIdAsync(int periodoId);
        Task<PagedResult<BienResponse>> GetBySucursalIdAsync(int sucursalId);
        Task<PagedResult<BienResponse>> GetByAreaIdAsync(int areaId);
        Task<PagedResult<BienResponse>> GetActivosAsync();

        Task<BienResponse> CreateAsync(BienDto dto, int usuarioActual);
        Task<BienResponse> UpdateAsync(int id, BienDto dto, int usuarioActual);
        Task<bool> DeleteAsync(int id, int usuarioActual);
    }
}
