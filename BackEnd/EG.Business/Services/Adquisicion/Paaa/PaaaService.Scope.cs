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
    private PaaaWriteCommand Command(PaaaWriteAction action, int id, int paaaId) => new()
    {
        Action = action, Id = id, PaaaId = paaaId,
        EmpresaId = userContext.GetCurrentEmpresaId(), UsuarioId = userContext.GetCurrentUserId()
    };

    private async Task<IQueryable<VwPaaa>> ScopedHeadersAsync()
    {
        var company = userContext.GetCurrentEmpresaId();
        var areas = await AuthorizedAreasAsync();
        return Query<VwPaaa>().Where(x => x.Activo && x.FkidEmpresaSis == company && areas.Contains(x.FkidAreaSis));
    }

    private Task<List<int>> AuthorizedAreasAsync()
    {
        var user = userContext.GetCurrentUserId();
        return Query<VwUsuarioPersonaArea>().Where(x => x.PkIdUsuario == user && x.UsuarioActivo && x.PersonaActivo == true &&
            x.AreaActivo == true && x.PkidArea.HasValue).Select(x => x.PkidArea!.Value).Distinct().ToListAsync();
    }

    private async Task<Paaa> OwnedHeaderAsync(int id)
    {
        var company = userContext.GetCurrentEmpresaId();
        var areas = await AuthorizedAreasAsync();
        return await Query<Paaa>().FirstOrDefaultAsync(x => x.PkidPaaas == id && x.Activo && x.FkidEmpresaSis == company && areas.Contains(x.FkidAreaSis))
            ?? throw new KeyNotFoundException();
    }

    private async Task<Paaaspartidum> OwnedPartidaAsync(int id)
    {
        var item = await Query<Paaaspartidum>().FirstOrDefaultAsync(x => x.PkidPaaaspartida == id && x.Activo)
            ?? throw new KeyNotFoundException();
        await OwnedHeaderAsync(item.FkidPaaasOrco);
        return item;
    }

    private IQueryable<VwEgresoDisponible> AvailableBudget(Paaa header) => Query<VwEgresoDisponible>()
        .Where(x => x.FkidAnioSis == header.FkidAnioSis && x.FkidAreaSis == header.FkidAreaSis &&
            (!header.FkidProgramaPres.HasValue || x.FkidProgramaPres == header.FkidProgramaPres.Value) &&
            (!header.FkidFuenteFinanciamientoPres.HasValue || x.FkidFuenteFinanciamientoPres == header.FkidFuenteFinanciamientoPres.Value));

    private async Task MarkLockedAsync(List<PaaaResponse> items)
    {
        if (items.Count == 0) return;
        var ids = items.Select(x => x.PkidPaaas).ToArray();
        var locked = await Query<EstudioMercadoDetalle>().Where(x => x.Activo && x.FkidPaaasdetalleOrcoNavigation.Activo &&
            x.FkidPaaasdetalleOrcoNavigation.FkidPaaaspartidaOrcoNavigation.Activo &&
            ids.Contains(x.FkidPaaasdetalleOrcoNavigation.FkidPaaaspartidaOrcoNavigation.FkidPaaasOrco) &&
            x.FkidEstudioMercadoOrcoNavigation.Activo && x.FkidEstudioMercadoOrcoNavigation.Estatus != 5)
            .Select(x => x.FkidPaaasdetalleOrcoNavigation.FkidPaaaspartidaOrcoNavigation.FkidPaaasOrco).Distinct().ToListAsync();
        var set = locked.ToHashSet();
        foreach (var item in items) item.BloqueadoPorEstudioMercado = set.Contains(item.PkidPaaas);
    }
}
