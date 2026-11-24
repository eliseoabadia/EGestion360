using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Interfaces;

namespace EG.Application.Interfaces.General;

public interface ICatalogLookupAppService
{
    Task<PagedResult<LookupItem>> GetAsync(CatalogLookupKind catalog, int page, int pageSize, string? filter, int? parentId = null);
    Task<PagedResult<PeriodoPagoResponse>> GetPeriodosPagoAsync();
    Task<PagedResult<OrcoProyectoResponse>> GetProyectosAsync(PagedRequest? request = null);
    Task<PagedResult<OrcoProyectoResponse>> GetProyectoByIdAsync(int id);
    Task<IReadOnlyList<CatalogLookupValue>> GetLegacyAsync(CatalogLookupKind catalog, int? anioId = null);
}
