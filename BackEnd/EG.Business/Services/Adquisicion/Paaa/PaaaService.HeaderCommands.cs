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
    public Task<PagedResult<PaaaResponse>> CreateAsync(PaaaResponse request) => SaveHeaderAsync(null, request);
    public Task<PagedResult<PaaaResponse>> UpdateAsync(int id, PaaaResponse request) => SaveHeaderAsync(id, request);

    private Task<PagedResult<PaaaResponse>> SaveHeaderAsync(int? id, PaaaResponse request) => ExecuteAsync(async () =>
    {
        if (request.FkidAnioSis <= 0 || request.FkidAreaSis <= 0 || request.FkidPersonaNom <= 0 ||
            string.IsNullOrWhiteSpace(request.Descripcion) || request.Fecha == default)
        {
            throw new UserVisibleException("Captura ejercicio, área, responsable, descripción y fecha válidos.", "INVALID_HEADER");
        }
        Paaa? original = null;
        if (id.HasValue)
        {
            original = await OwnedHeaderAsync(id.Value);
        }
        if (!(await AuthorizedAreasAsync()).Contains(request.FkidAreaSis))
        {
            throw new UnauthorizedAccessException();
        }
        var dto = request.Adapt<PaaaDto>();
        dto.PkidPaaas = id ?? 0;
        dto.FkidEmpresaSis = userContext.GetCurrentEmpresaId();
        dto.UsuarioCreacion = original?.UsuarioCreacion ?? userContext.GetCurrentUserId();
        dto.FechaCreacion = original?.FechaCreacion ?? DateTime.Now;
        dto.UsuarioModificacion = id.HasValue ? userContext.GetCurrentUserId() : null;
        dto.FechaModificacion = id.HasValue ? DateTime.Now : null;
        var saved = await persistence.ExecuteAsync(new PaaaWriteCommand
        {
            Action = id.HasValue ? PaaaWriteAction.Update : PaaaWriteAction.Create,
            Id = id ?? 0, PaaaId = id ?? 0, Header = dto,
            EmpresaId = dto.FkidEmpresaSis, UsuarioId = userContext.GetCurrentUserId()
        });
        var response = dto.Adapt<PaaaResponse>();
        response.PkidPaaas = id ?? saved.Id ?? 0;
        return Single(response, saved.Message);
    });

    public Task<PagedResult<bool>> DeleteAsync(int id) => ExecuteAsync(async () =>
    {
        await OwnedHeaderAsync(id);
        var saved = await persistence.ExecuteAsync(Command(PaaaWriteAction.Delete, id, id));
        return Single(true, saved.Message);
    });
}
