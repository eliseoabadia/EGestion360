using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Business.Interfaces;

public interface IPaaaService
{
    Task<PagedResult<PaaaResponse>> GetAllAsync();
    Task<PagedResult<PaaaResponse>> GetByIdAsync(int id);
    Task<PagedResult<PaaaResponse>> GetAllPaginadoAsync(PagedRequest request);
    Task<PagedResult<PaaaResponse>> CreateAsync(PaaaResponse request);
    Task<PagedResult<PaaaResponse>> UpdateAsync(int id, PaaaResponse request);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<PaaaspartidumResponse>> GetPartidasAsync(int id);
    Task<PagedResult<PaaasdetalleResponse>> GetDetallesAsync(int partidaId);
    Task<PagedResult<LookupItem>> GetTiposBienAsync(int partidaId, PagedRequest request);
    Task<PagedResult<LookupItem>> GetPartidasDisponiblesAsync(int id, PagedRequest request);
    Task<PagedResult<LookupItem>> GetMesesAsync(PagedRequest request);
    Task<PagedResult<PaaaspartidumResponse>> CreatePartidaAsync(PaaaspartidaDto request);
    Task<PagedResult<PaaasdetalleResponse>> CreateDetalleAsync(PaaasdetalleDto request);
    Task<PagedResult<PaaasdetalleResponse>> UpdateDetalleAsync(int id, PaaasdetalleDto request);
    Task<PagedResult<bool>> DeleteDetalleAsync(int id);
    Task<PagedResult<bool>> DeletePartidaAsync(int id);
}
