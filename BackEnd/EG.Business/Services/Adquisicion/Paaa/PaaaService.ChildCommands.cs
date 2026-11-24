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
    public Task<PagedResult<PaaaspartidumResponse>> CreatePartidaAsync(PaaaspartidaDto request) => ExecuteAsync(async () =>
    {
        var header = await OwnedHeaderAsync(request.FkidPaaasOrco);
        if (!await AvailableBudget(header).AnyAsync(x => x.FkidPartidaConta == request.FkidPartidaConta))
        {
            throw new UserVisibleException("La partida no tiene presupuesto autorizado para el ejercicio, area y estructura del programa.", "PARTIDA_NOT_AVAILABLE");
        }
        request.FkidEmpresaSis = userContext.GetCurrentEmpresaId();
        var saved = await persistence.ExecuteAsync(new PaaaWriteCommand
        {
            Action = PaaaWriteAction.CreatePartida, PaaaId = header.PkidPaaas, Partida = request,
            EmpresaId = request.FkidEmpresaSis, UsuarioId = userContext.GetCurrentUserId()
        });
        var view = await Query<VwPaaaspartidum>().FirstOrDefaultAsync(x => x.PkidPaaaspartida == saved.Id);
        return Single(view?.Adapt<PaaaspartidumResponse>() ?? new() { PkidPaaaspartida = saved.Id ?? 0, FkidPaaasOrco = header.PkidPaaas }, saved.Message);
    });

    public Task<PagedResult<PaaasdetalleResponse>> CreateDetalleAsync(PaaasdetalleDto request) => SaveDetalleAsync(null, request);
    public Task<PagedResult<PaaasdetalleResponse>> UpdateDetalleAsync(int id, PaaasdetalleDto request) => SaveDetalleAsync(id, request);

    private Task<PagedResult<PaaasdetalleResponse>> SaveDetalleAsync(int? id, PaaasdetalleDto request) => ExecuteAsync(async () =>
    {
        if (id.HasValue)
        {
            var existing = await Query<Paaasdetalle>().FirstOrDefaultAsync(x => x.PkidPaaasdetalle == id.Value && x.Activo)
                ?? throw new KeyNotFoundException();
            request.FkidPaaaspartidaOrco = existing.FkidPaaaspartidaOrco;
        }
        if (request.FkidPaaaspartidaOrco <= 0)
        {
            throw new UserVisibleException("Debe seleccionar una partida valida", "INVALID_PARTIDA");
        }
        if (request.FkidTipoBienAlma <= 0)
        {
            throw new UserVisibleException("Debe seleccionar un tipo de bien valido", "INVALID_TIPO_BIEN");
        }
        if (request.Cantidad <= 0)
        {
            throw new UserVisibleException("La cantidad debe ser mayor a cero", "INVALID_CANTIDAD");
        }
        if (!request.FkidMesSis.HasValue || !await Query<Me>().AnyAsync(x => x.PkidMes == request.FkidMesSis && x.Activo == true))
        {
            throw new UserVisibleException("Debe seleccionar un mes activo", "INVALID_MONTH");
        }
        var partida = await OwnedPartidaAsync(request.FkidPaaaspartidaOrco);
        var type = await Query<TipoBien>().FirstOrDefaultAsync(x => x.PkidTipoBien == request.FkidTipoBienAlma && x.Activo)
            ?? throw new KeyNotFoundException();
        if (type.FkidPartidaConta != partida.FkidPartidaConta)
        {
            throw new UserVisibleException("El tipo de bien no pertenece a la partida seleccionada", "TIPO_BIEN_PARTIDA_MISMATCH");
        }
        request.FkidEmpresaSis = userContext.GetCurrentEmpresaId();
        var saved = await persistence.ExecuteAsync(new PaaaWriteCommand
        {
            Action = id.HasValue ? PaaaWriteAction.UpdateDetalle : PaaaWriteAction.CreateDetalle,
            Id = id ?? 0, PaaaId = partida.FkidPaaasOrco, Detalle = request,
            EmpresaId = request.FkidEmpresaSis, UsuarioId = userContext.GetCurrentUserId()
        });
        var key = id ?? saved.Id ?? 0;
        var view = await Query<VwPaaasdetalle>().FirstOrDefaultAsync(x => x.PkidPaaasdetalle == key && x.Activo);
        return Single(view?.Adapt<PaaasdetalleResponse>() ?? new() { PkidPaaasdetalle = key }, saved.Message);
    });

    public Task<PagedResult<bool>> DeleteDetalleAsync(int id) => ExecuteAsync(async () =>
    {
        var detail = await Query<Paaasdetalle>().FirstOrDefaultAsync(x => x.PkidPaaasdetalle == id && x.Activo)
            ?? throw new KeyNotFoundException();
        var partida = await OwnedPartidaAsync(detail.FkidPaaaspartidaOrco);
        var saved = await persistence.ExecuteAsync(Command(PaaaWriteAction.DeleteDetalle, id, partida.FkidPaaasOrco));
        return Single(true, saved.Message);
    });

    public Task<PagedResult<bool>> DeletePartidaAsync(int id) => ExecuteAsync(async () =>
    {
        var partida = await OwnedPartidaAsync(id);
        var saved = await persistence.ExecuteAsync(Command(PaaaWriteAction.DeletePartida, id, partida.FkidPaaasOrco));
        return Single(true, saved.Message);
    });
}
