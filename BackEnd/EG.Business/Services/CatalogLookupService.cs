using EG.Business.Interfaces;

using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace EG.Business.Services;

public sealed class CatalogLookupService(ICatalogLookupQueries queries, IUserContextService userContext) : ICatalogLookupService
{
    public async Task<PagedResult<LookupItem>> GetAsync(CatalogLookupKind catalog, int page, int pageSize, string? filter, int? parentId = null)
    {
        pageSize = Math.Clamp(pageSize, 1, catalog == CatalogLookupKind.TipoBienCapitulo5000 ? 250 : 100);
        page = Math.Clamp(page, 1, int.MaxValue / pageSize);
        var empresaId = catalog == CatalogLookupKind.CuentaAuxiliarProveedor ? userContext.GetCurrentEmpresaId() : (int?)null;
        var query = queries.Query(catalog, parentId, empresaId).Select(x => new LookupItem { Id = x.Id, Text = x.Text });
        if (!string.IsNullOrWhiteSpace(filter))
        {
            var value = filter.Trim();
            query = query.Where(x => x.Text.Contains(value));
        }
        var count = await query.CountAsync();
        var items = await query.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();
        return Success(items, count, catalog == CatalogLookupKind.TipoBienCapitulo5000 ? "Tipos patrimoniales" : "OK");
    }

    public async Task<PagedResult<PeriodoPagoResponse>> GetPeriodosPagoAsync()
    {
        var items = await queries.PeriodosPago().ToListAsync();
        return Success(items, items.Count, "Periodos de pago obtenidos correctamente");
    }

    public async Task<PagedResult<OrcoProyectoResponse>> GetProyectosAsync(PagedRequest? request = null)
    {
        var query = queries.ProyectosActivos();
        if (!string.IsNullOrWhiteSpace(request?.Filtro))
        {
            var filter = request.Filtro.Trim();
            query = query.Where(x => x.Descripcion.Contains(filter) || x.PkidProyecto.ToString().Contains(filter));
        }
        var ascending = string.IsNullOrWhiteSpace(request?.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
        query = request?.SortLabel == nameof(OrcoProyectoResponse.PkidProyecto)
            ? ascending ? query.OrderBy(x => x.PkidProyecto) : query.OrderByDescending(x => x.PkidProyecto)
            : ascending ? query.OrderBy(x => x.Descripcion) : query.OrderByDescending(x => x.Descripcion);
        var count = await query.CountAsync();
        if (request != null)
        {
            var size = Math.Clamp(request.PageSize <= 0 ? 10 : request.PageSize, 1, 250);
            var page = Math.Clamp(request.Page, 1, int.MaxValue / size);
            query = query.Skip((page - 1) * size).Take(size);
        }
        return Success(await query.ToListAsync(), count, "Proyectos ORCO obtenidos correctamente");
    }

    public async Task<PagedResult<OrcoProyectoResponse>> GetProyectoByIdAsync(int id)
    {
        var item = await queries.ProyectosActivos().FirstOrDefaultAsync(x => x.PkidProyecto == id);
        if (item == null)
        {
            return new() { Success = false, Message = "Proyecto ORCO no encontrado", Code = "NOT_FOUND" };
        }
        var result = Success<OrcoProyectoResponse>([item], 1, "Proyecto ORCO encontrado");
        result.Data = item;
        return result;
    }

    private static PagedResult<T> Success<T>(IList<T> items, int count, string message) => new()
    {
        Success = true, Code = "SUCCESS", Message = message, Items = items, TotalCount = count
    };

    public async Task<IReadOnlyList<CatalogLookupValue>> GetLegacyAsync(CatalogLookupKind catalog, int? anioId = null)
        => await queries.QueryLegacy(catalog, anioId).ToListAsync();
}
