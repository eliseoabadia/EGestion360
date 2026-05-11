using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Application.Interfaces.Adquisicion
{
    public interface IArticuloAppService
    {
        Task<PagedResult<ArticuloResponse>> GetAllAsync();
        Task<PagedResult<ArticuloResponse>> GetByIdAsync(int id);
        Task<PagedResult<ArticuloResponse>> CreateAsync(ArticuloResponse response, int usuarioActual);
        Task<PagedResult<ArticuloResponse>> UpdateAsync(int id, ArticuloResponse response, int usuarioActual);
        Task<PagedResult<bool>> DeleteAsync(int id);
        Task<PagedResult<ArticuloResponse>> GetAllPaginadoAsync(PagedRequest request);
    }
}
