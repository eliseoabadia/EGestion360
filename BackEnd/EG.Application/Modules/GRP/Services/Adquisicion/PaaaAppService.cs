using EG.Application.Interfaces.Adquisicion;
using EG.Business.Interfaces;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Application.Services.Adquisicion;

public sealed class PaaaAppService(IPaaaService service) : IPaaaAppService
{
    public Task<PagedResult<PaaaResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<PaaaResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<PaaaResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
    public Task<PagedResult<PaaaResponse>> CreateAsync(PaaaResponse request) => service.CreateAsync(request);
    public Task<PagedResult<PaaaResponse>> UpdateAsync(int id, PaaaResponse request) => service.UpdateAsync(id, request);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<PaaaspartidumResponse>> GetPartidasAsync(int id) => service.GetPartidasAsync(id);
    public Task<PagedResult<PaaasdetalleResponse>> GetDetallesAsync(int partidaId) => service.GetDetallesAsync(partidaId);
    public Task<PagedResult<LookupItem>> GetTiposBienAsync(int partidaId, PagedRequest request) => service.GetTiposBienAsync(partidaId, request);
    public Task<PagedResult<LookupItem>> GetPartidasDisponiblesAsync(int id, PagedRequest request) => service.GetPartidasDisponiblesAsync(id, request);
    public Task<PagedResult<LookupItem>> GetMesesAsync(PagedRequest request) => service.GetMesesAsync(request);
    public Task<PagedResult<PaaaspartidumResponse>> CreatePartidaAsync(PaaaspartidaDto request) => service.CreatePartidaAsync(request);
    public Task<PagedResult<PaaasdetalleResponse>> CreateDetalleAsync(PaaasdetalleDto request) => service.CreateDetalleAsync(request);
    public Task<PagedResult<PaaasdetalleResponse>> UpdateDetalleAsync(int id, PaaasdetalleDto request) => service.UpdateDetalleAsync(id, request);
    public Task<PagedResult<bool>> DeleteDetalleAsync(int id) => service.DeleteDetalleAsync(id);
    public Task<PagedResult<bool>> DeletePartidaAsync(int id) => service.DeletePartidaAsync(id);
}
