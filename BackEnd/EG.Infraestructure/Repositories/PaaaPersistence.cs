using System.Data;
using System.Text.Json;
using EG.Common.Exceptions;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;

namespace EG.Infrastructure;

public sealed class PaaaPersistence(EGestionContext context) : IPaaaPersistence
{
    public Task<PaaaWriteResult> ExecuteAsync(PaaaWriteCommand request)
    {
        ArgumentNullException.ThrowIfNull(request);
        if (request.UsuarioId <= 0 || request.EmpresaId <= 0)
        {
            throw new UnauthorizedAccessException("Se requiere una identidad y empresa activas.");
        }
        if (!Enum.IsDefined(request.Action))
        {
            throw new ArgumentOutOfRangeException(nameof(request.Action));
        }
        if ((request.Action is PaaaWriteAction.Create or PaaaWriteAction.Update) && request.Header == null)
        {
            throw new ArgumentException("Falta el encabezado del programa anual.", nameof(request));
        }
        if (request.Action != PaaaWriteAction.Create && request.PaaaId <= 0)
        {
            throw new ArgumentException("Falta el programa anual de la operación.", nameof(request));
        }
        if (request.Action == PaaaWriteAction.CreatePartida &&
            (request.Partida == null || request.Partida.FkidPaaasOrco != request.PaaaId))
        {
            throw new ArgumentException("La partida debe pertenecer al programa anual de la operación.", nameof(request));
        }
        if ((request.Action is PaaaWriteAction.CreateDetalle or PaaaWriteAction.UpdateDetalle) && request.Detalle == null)
        {
            throw new ArgumentException("Falta el detalle de la operación.", nameof(request));
        }
        return ExecuteCoreAsync(request);
    }

    private Task<PaaaWriteResult> ExecuteCoreAsync(PaaaWriteCommand request) => context.ExecuteResilientTransactionAsync(async cancellationToken =>
    {
        if (request.UsuarioId <= 0 || request.EmpresaId <= 0)
        {
            throw new UnauthorizedAccessException("Se requiere una identidad y empresa activas.");
        }
        if (!Enum.IsDefined(request.Action))
        {
            throw new ArgumentOutOfRangeException(nameof(request.Action));
        }
        if (request.PaaaId > 0)
        {
            var root = await context.Paaas.AsNoTracking().FirstOrDefaultAsync(x => x.PkidPaaas == request.PaaaId && x.Activo && x.FkidEmpresaSis == request.EmpresaId, cancellationToken);
            if (root == null)
            {
                throw new UserVisibleException("Programa anual no encontrado.", "NOT_FOUND");
            }
            await EnsureAreaAccessAsync(root.FkidAreaSis, request.UsuarioId, cancellationToken);
            var locked = await context.EstudioMercadoDetalles.AnyAsync(x => x.Activo && x.FkidPaaasdetalleOrcoNavigation.Activo &&
                x.FkidPaaasdetalleOrcoNavigation.FkidPaaaspartidaOrcoNavigation.Activo &&
                x.FkidPaaasdetalleOrcoNavigation.FkidPaaaspartidaOrcoNavigation.FkidPaaasOrco == request.PaaaId &&
                x.FkidEstudioMercadoOrcoNavigation.Activo && x.FkidEstudioMercadoOrcoNavigation.Estatus != 5, cancellationToken);
            if (locked)
            {
                throw new UserVisibleException("El programa está bloqueado por un estudio de mercado activo.", "PAAA_LOCKED");
            }
        }

        var parameters = new List<SqlParameter> { Parameter("@Action", (int)request.Action), Parameter("@IdUser", request.UsuarioId) };
        if (request.Header is { } header)
        {
            await EnsureAreaAccessAsync(header.FkidAreaSis, request.UsuarioId, cancellationToken);
            if (!await OrcoProyectoCatalog.EnsureProyectoOrcoAsync(context, header.FkidProyectoOrco, request.UsuarioId))
            {
                throw new UserVisibleException("El proyecto seleccionado no existe o está inactivo.", "INVALID_ORCO_PROJECT");
            }
            if (await context.Paaas.AnyAsync(x => x.Activo && x.FkidEmpresaSis == request.EmpresaId &&
                x.FkidAreaSis == header.FkidAreaSis && x.FkidAnioSis == header.FkidAnioSis && x.PkidPaaas != request.Id, cancellationToken))
            {
                throw new UserVisibleException("Ya existe un programa anual activo para el mismo año y área.", "DUPLICATE_AREA_ANIO");
            }
            parameters.AddRange([
                Parameter("@FKIdEmpresa_SIS", request.EmpresaId), Parameter("@FKIdAnio_SIS", header.FkidAnioSis),
                Parameter("@FKIdArea_SIS", header.FkidAreaSis), Parameter("@FKIdPersona_NOM", header.FkidPersonaNom),
                Parameter("@Descripcion", header.Descripcion), Parameter("@Observaciones", header.Observaciones),
                Parameter("@Fecha", header.Fecha), Parameter("@FKIdProyecto_ORCO", header.FkidProyectoOrco),
                Parameter("@FKIdPrograma_PRES", header.FkidProgramaPres), Parameter("@FKIdFuenteFinanciamiento_PRES", header.FkidFuenteFinanciamientoPres)
            ]);
        }
        if (request.Partida is { } partida)
        {
            parameters.AddRange([
                Parameter("@FKIdEmpresa_SIS", request.EmpresaId), Parameter("@FKIdPartida_CONTA", partida.FkidPartidaConta),
                Parameter("@Observaciones", partida.Observaciones)
            ]);
        }
        if (request.Detalle is { } detalle)
        {
            var parentExists = await context.Paaaspartida.AnyAsync(x => x.PkidPaaaspartida == detalle.FkidPaaaspartidaOrco &&
                x.Activo && x.FkidPaaasOrco == request.PaaaId, cancellationToken);
            if (!parentExists)
            {
                throw new UserVisibleException("Partida no encontrada.", "NOT_FOUND");
            }
            parameters.AddRange([
                Parameter("@FKIdEmpresa_SIS", request.EmpresaId), Parameter("@PKIdPAAASPartida", detalle.FkidPaaaspartidaOrco),
                Parameter("@FKIdTipoBien_ALMA", detalle.FkidTipoBienAlma), Parameter("@FKIdUnidades_ALMA", detalle.FkidUnidadesAlma),
                Parameter("@FKIdMes_SIS", detalle.FkidMesSis), Parameter("@Cantidad", detalle.Cantidad),
                Parameter("@Observaciones", detalle.Observaciones), Parameter("@LugarEntrega", detalle.LugarEntrega)
            ]);
        }
        switch (request.Action)
        {
            case PaaaWriteAction.Update:
            case PaaaWriteAction.Delete:
                parameters.Add(Parameter("@PKIdPAAAS", request.Id));
                break;
            case PaaaWriteAction.CreatePartida:
                parameters.Add(Parameter("@PKIdPAAAS", request.PaaaId));
                break;
            case PaaaWriteAction.DeletePartida:
                parameters.Add(Parameter("@PKIdPAAASPartida", request.Id));
                break;
            case PaaaWriteAction.UpdateDetalle:
            case PaaaWriteAction.DeleteDetalle:
                parameters.Add(Parameter("@PKIdPAAASDetalle", request.Id));
                break;
        }
        if (request.Action is PaaaWriteAction.DeleteDetalle or PaaaWriteAction.UpdateDetalle)
        {
            if (!await context.Paaasdetalles.AnyAsync(x => x.PkidPaaasdetalle == request.Id && x.Activo &&
                x.FkidPaaaspartidaOrcoNavigation.Activo && x.FkidPaaaspartidaOrcoNavigation.FkidPaaasOrco == request.PaaaId, cancellationToken))
            {
                throw new UserVisibleException("Detalle no encontrado.", "NOT_FOUND");
            }
        }
        if (request.Action == PaaaWriteAction.DeletePartida && !await context.Paaaspartida.AnyAsync(x =>
                x.PkidPaaaspartida == request.Id && x.Activo && x.FkidPaaasOrco == request.PaaaId, cancellationToken))
        {
            throw new UserVisibleException("Partida no encontrada.", "NOT_FOUND");
        }
        await using var command = context.Database.GetDbConnection().CreateCommand();
        command.CommandText = "[ORCO].[SP_MantenimientoPAAASV2]";
        command.CommandType = CommandType.StoredProcedure;
        command.Transaction = context.Database.CurrentTransaction!.GetDbTransaction();
        foreach (var parameter in parameters)
        {
            command.Parameters.Add(parameter);
        }
        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (!await reader.ReadAsync(cancellationToken))
        {
            throw new InvalidOperationException("El mantenimiento de PAAAS no devolvió un resultado.");
        }
        var result = JsonSerializer.Deserialize<ProcedureResult>(reader["ResultJson"].ToString() ?? "", new JsonSerializerOptions { PropertyNameCaseInsensitive = true })
            ?? throw new InvalidOperationException("El mantenimiento de PAAAS devolvió un resultado inválido.");
        if (!new[] { "OK", "EXITO", "SUCCESS" }.Contains(result.Tipo, StringComparer.OrdinalIgnoreCase))
        {
            throw new UserVisibleException(result.Mensaje, result.Tipo);
        }
        var lastSegment = (result.Liga ?? string.Empty).Split(':', StringSplitOptions.RemoveEmptyEntries).LastOrDefault();
        int? key = int.TryParse(lastSegment, out var id) ? id : null;
        if ((request.Action is PaaaWriteAction.Create or PaaaWriteAction.CreatePartida or PaaaWriteAction.CreateDetalle) && key is not > 0)
        {
            throw new InvalidOperationException("El mantenimiento de PAAAS no devolvió el identificador creado.");
        }
        return new PaaaWriteResult(key, result.Mensaje);
    }, IsolationLevel.Serializable);

    private static SqlParameter Parameter(string name, object? value) => new(name, value ?? DBNull.Value);

    private async Task EnsureAreaAccessAsync(int areaId, int usuarioId, CancellationToken cancellationToken)
    {
        if (!await context.VwUsuarioPersonaAreas.AnyAsync(x => x.PkIdUsuario == usuarioId && x.UsuarioActivo &&
            x.PersonaActivo == true && x.AreaActivo == true && x.PkidArea == areaId, cancellationToken))
        {
            throw new UnauthorizedAccessException("No tienes acceso al área del programa anual.");
        }
    }

    private sealed class ProcedureResult
    {
        public ProcedureResult() { }
        public string Tipo { get; set; } = string.Empty;
        public string Mensaje { get; set; } = string.Empty;
        public string Liga { get; set; } = string.Empty;
    }
}
