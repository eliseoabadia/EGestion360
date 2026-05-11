using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Application.Interfaces.Adquisicion
{
    public interface IPaaaAppService
    {
        Task<PagedResult<PaaaResponse>> GetAllAsync();
        Task<PagedResult<PaaaResponse>> GetByIdAsync(int id);
        Task<PagedResult<PaaaResponse>> CreateAsync(PaaaResponse response, int usuarioActual);
        Task<PagedResult<PaaaResponse>> UpdateAsync(int id, PaaaResponse response, int usuarioActual);
        Task<PagedResult<bool>> DeleteAsync(int id);
        Task<PagedResult<PaaaResponse>> GetAllPaginadoAsync(PagedRequest request);
        Task<PagedResult<PaaaspartidumResponse>> GetPartidasByPaaaAsync(int id);
        Task<PagedResult<PaaasdetalleResponse>> GetDetallesByPartidaAsync(int partidaId);
        Task<PagedResult<LookupItem>> GetTiposBienByPartidaAsync(int partidaId, PagedRequest request);
        Task<PagedResult<PaaaspartidumResponse>> CreatePartidaAsync(PaaaspartidaDto dto, int usuarioActual);
        Task<PagedResult<PaaasdetalleResponse>> CreateDetalleAsync(PaaasdetalleDto dto, int usuarioActual);
        Task<PagedResult<PaaasdetalleResponse>> UpdateDetalleAsync(int detalleId, PaaasdetalleDto dto, int usuarioActual);
        Task<PagedResult<bool>> DeleteDetalleAsync(int detalleId, int usuarioActual);
        Task<PagedResult<bool>> DeletePartidaAsync(int partidaId, int usuarioActual);
    }
}
