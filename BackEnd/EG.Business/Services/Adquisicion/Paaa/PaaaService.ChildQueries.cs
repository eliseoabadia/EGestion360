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
    public Task<PagedResult<PaaaspartidumResponse>> GetPartidasAsync(int id) => ExecuteAsync(async () =>
    {
        await OwnedHeaderAsync(id);
        var rows = await Query<VwPaaaspartidum>().Where(x => x.FkidPaaasOrco == id && x.Activo).OrderBy(x => x.PartidaClave).ToListAsync();
        return Success(rows.Adapt<List<PaaaspartidumResponse>>(), "Partidas obtenidas correctamente");
    });

    public Task<PagedResult<PaaasdetalleResponse>> GetDetallesAsync(int partidaId) => ExecuteAsync(async () =>
    {
        await OwnedPartidaAsync(partidaId);
        var rows = await Query<VwPaaasdetalle>().Where(x => x.FkidPaaaspartidaOrco == partidaId && x.Activo)
            .OrderBy(x => x.TipoBienCodigoClave).ThenBy(x => x.TipoBienDescripcion).ToListAsync();
        return Success(rows.Adapt<List<PaaasdetalleResponse>>(), "OK");
    });

    public Task<PagedResult<LookupItem>> GetTiposBienAsync(int partidaId, PagedRequest request) => ExecuteAsync(async () =>
    {
        var partida = await OwnedPartidaAsync(partidaId);
        var query = Query<TipoBien>().Where(x => x.Activo && x.FkidPartidaConta == partida.FkidPartidaConta);
        var filter = request.Filtro?.Trim();
        if (!string.IsNullOrWhiteSpace(filter))
        {
            query = query.Where(x => x.CodigoClave.Contains(filter) || x.Descripcion.Contains(filter));
        }
        return await LookupAsync(query.OrderBy(x => x.CodigoClave).ThenBy(x => x.Descripcion)
            .Select(x => new LookupItem { Id = x.PkidTipoBien, Text = (x.CodigoClave ?? "") + " - " + (x.Descripcion ?? "") }), request, "Tipos de bien obtenidos correctamente");
    });

    public Task<PagedResult<LookupItem>> GetPartidasDisponiblesAsync(int id, PagedRequest request) => ExecuteAsync(async () =>
    {
        var header = await OwnedHeaderAsync(id);
        var query = AvailableBudget(header).Select(x => new { x.FkidPartidaConta, x.PartidaClave, x.PartidaDescripcion }).Distinct();
        var filter = request.Filtro?.Trim();
        if (!string.IsNullOrWhiteSpace(filter))
        {
            query = query.Where(x => x.PartidaClave.Contains(filter) || x.PartidaDescripcion.Contains(filter));
        }
        return await LookupAsync(query.OrderBy(x => x.PartidaClave)
            .Select(x => new LookupItem { Id = x.FkidPartidaConta, Text = x.PartidaClave + " - " + x.PartidaDescripcion }), request, "Partidas disponibles");
    });

    public Task<PagedResult<LookupItem>> GetMesesAsync(PagedRequest request) => ExecuteAsync(async () =>
    {
        var query = Query<Me>().Where(x => x.Activo == true);
        var filter = request.Filtro?.Trim();
        if (!string.IsNullOrWhiteSpace(filter))
        {
            query = query.Where(x => x.Descripcion.Contains(filter) || x.Abreviatura.Contains(filter));
        }
        return await LookupAsync(query.OrderBy(x => x.PkidMes).Select(x => new LookupItem { Id = x.PkidMes, Text = x.Descripcion }), request, "Meses");
    });
}
