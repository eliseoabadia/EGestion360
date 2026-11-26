using EG.Business.Interfaces;
using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Interfaces;

namespace EG.Application.Services.General;

public sealed class CatalogLookupAppService(ICatalogLookupService service) : ICatalogLookupAppService
{
    public Task<PagedResult<LookupItem>> GetAsync(CatalogLookupKind catalog, int page, int pageSize, string? filter, int? parentId = null)
        => service.GetAsync(catalog, page, pageSize, filter, parentId);
    public Task<PagedResult<PeriodoPagoResponse>> GetPeriodosPagoAsync() => service.GetPeriodosPagoAsync();
    public Task<PagedResult<OrcoProyectoResponse>> GetProyectosAsync(PagedRequest? request = null) => service.GetProyectosAsync(request);
    public Task<PagedResult<OrcoProyectoResponse>> GetProyectoByIdAsync(int id) => service.GetProyectoByIdAsync(id);
    public Task<IReadOnlyList<CatalogLookupValue>> GetLegacyAsync(CatalogLookupKind catalog, int? anioId = null) => service.GetLegacyAsync(catalog, anioId);
}
