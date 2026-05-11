using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Application.Interfaces.Adquisicion
{
    public interface ITipoDocumentoAppService
    {
        Task<PagedResult<TipoDocumentoResponse>> GetAllAsync();
        Task<PagedResult<TipoDocumentoResponse>> GetByIdAsync(int id);
        Task<PagedResult<TipoDocumentoResponse>> CreateAsync(TipoDocumentoResponse response, int usuarioActual);
        Task<PagedResult<TipoDocumentoResponse>> UpdateAsync(int id, TipoDocumentoResponse response, int usuarioActual);
        Task<PagedResult<bool>> DeleteAsync(int id);
        Task<PagedResult<TipoDocumentoResponse>> GetAllPaginadoAsync(PagedRequest request);
    }
}
