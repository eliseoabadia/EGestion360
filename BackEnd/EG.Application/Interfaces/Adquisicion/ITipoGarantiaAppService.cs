using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Application.Interfaces.Adquisicion
{
    public interface ITipoGarantiaAppService
    {
        Task<PagedResult<TipoGarantiaResponse>> GetAllAsync();
        Task<PagedResult<TipoGarantiaResponse>> GetByIdAsync(int id);
        Task<PagedResult<TipoGarantiaResponse>> CreateAsync(TipoGarantiaResponse response, int usuarioActual);
        Task<PagedResult<TipoGarantiaResponse>> UpdateAsync(int id, TipoGarantiaResponse response, int usuarioActual);
        Task<PagedResult<bool>> DeleteAsync(int id);
        Task<PagedResult<TipoGarantiaResponse>> GetAllPaginadoAsync(PagedRequest request);
    }
}
