using System.Text.Json;
using EG.Business.Interfaces;
using EG.Common;
using EG.Common.Exceptions;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Mapster;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace EG.Business.Services;

public sealed partial class PaaaService
{
    public Task<PagedResult<PaaaResponse>> GetAllAsync() => ExecuteAsync(async () =>
    {
        var items = (await (await ScopedHeadersAsync()).OrderByDescending(x => x.PkidPaaas).ToListAsync()).Adapt<List<PaaaResponse>>();
        await MarkLockedAsync(items);
        return Success(items, "Programas anuales obtenidos correctamente");
    });

    public Task<PagedResult<PaaaResponse>> GetByIdAsync(int id) => ExecuteAsync(async () =>
    {
        var view = await (await ScopedHeadersAsync()).FirstOrDefaultAsync(x => x.PkidPaaas == id)
            ?? throw new KeyNotFoundException();
        var item = view.Adapt<PaaaResponse>();
        await MarkLockedAsync([item]);
        return Single(item, "Programa anual encontrado");
    });

    public Task<PagedResult<PaaaResponse>> GetAllPaginadoAsync(PagedRequest request) => ExecuteAsync(async () =>
    {
        if (!TryReadYear(request, out var year) || year <= 0)
        {
            throw new UserVisibleException("El ejercicio presupuestal es obligatorio.", "YEAR_REQUIRED");
        }
        if (year != userContext.GetCurrentAnioPresupuestalId())
        {
            throw new UserVisibleException("El ejercicio solicitado no coincide con el ejercicio activo.", "INVALID_YEAR");
        }
        var query = (await ScopedHeadersAsync()).Where(x => x.FkidAnioSis == year);
        if (!string.IsNullOrWhiteSpace(request.Filtro))
        {
            var filter = request.Filtro.Trim();
            query = query.Where(x => (x.Descripcion != null && x.Descripcion.Contains(filter)) ||
                (x.AreaNombre != null && x.AreaNombre.Contains(filter)) || (x.ResponsableCompleto != null && x.ResponsableCompleto.Contains(filter)));
        }
        var ascending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
        query = request.SortLabel switch
        {
            "PkidPaaas" => ascending ? query.OrderBy(x => x.PkidPaaas) : query.OrderByDescending(x => x.PkidPaaas),
            "Descripcion" => ascending ? query.OrderBy(x => x.Descripcion) : query.OrderByDescending(x => x.Descripcion),
            "AreaNombre" => ascending ? query.OrderBy(x => x.AreaNombre) : query.OrderByDescending(x => x.AreaNombre),
            "ResponsableCompleto" => ascending ? query.OrderBy(x => x.ResponsableCompleto) : query.OrderByDescending(x => x.ResponsableCompleto),
            "Fecha" => ascending ? query.OrderBy(x => x.Fecha) : query.OrderByDescending(x => x.Fecha),
            "Activo" => ascending ? query.OrderBy(x => x.Activo) : query.OrderByDescending(x => x.Activo),
            _ => query.OrderByDescending(x => x.PkidPaaas)
        };
        var count = await query.CountAsync();
        var (page, size) = Paging(request);
        var items = (await query.Skip((page - 1) * size).Take(size).ToListAsync()).Adapt<List<PaaaResponse>>();
        await MarkLockedAsync(items);
        var result = Success(items, "OK");
        result.TotalCount = count;
        return result;
    });
}
