using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Application.Interfaces.Adquisicion
{
    public interface ITipoContratoAppService
    {
        Task<PagedResult<TipoContratoResponse>> GetAllAsync();
        Task<PagedResult<TipoContratoResponse>> GetByIdAsync(int id);
        Task<PagedResult<TipoContratoResponse>> CreateAsync(TipoContratoResponse response, int usuarioActual);
        Task<PagedResult<TipoContratoResponse>> UpdateAsync(int id, TipoContratoResponse response, int usuarioActual);
        Task<PagedResult<bool>> DeleteAsync(int id);
        Task<PagedResult<TipoContratoResponse>> GetAllPaginadoAsync(PagedRequest request);
    }
}
