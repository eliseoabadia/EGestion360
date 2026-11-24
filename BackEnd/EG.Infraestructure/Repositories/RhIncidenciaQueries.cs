using EG.Domain.DTOs.Responses.Nomina;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Infrastructure;

public sealed class RhIncidenciaQueries(EGestionContext context) : IRhIncidenciaQueries
{
    public async Task<RhIncidenciaPage> GetAsync(RhIncidenciaFilter request, int empresaId)
    {
        if (empresaId <= 0)
        {
            throw new UnauthorizedAccessException("Se requiere una empresa activa para consultar incidencias.");
        }



        var filter = request.Filter;
        var pageSize = Math.Clamp(request.PageSize <= 0 ? 10 : request.PageSize, 1, 2000);
        var page = Math.Clamp(request.Page, 1, int.MaxValue / pageSize);

        var query =
            from incidencia in context.VwIncidencia.AsNoTracking()
            join persona in context.Personas.AsNoTracking()
                on incidencia.FkidPersonaNom equals persona.PkidPersona
            where persona.Activo
                && (persona.FkidEmpresaSis == empresaId)
            select new
            {
                Incidencia = incidencia,
                Periodo = context.VwPeriodoQuincenals.AsNoTracking()
                    .Where(periodo => incidencia.FkidPeriodoQuincenalSis.HasValue
                        && periodo.LegacyId == incidencia.FkidPeriodoQuincenalSis.Value
                        && (periodo.FkidEmpresaSis == null || periodo.FkidEmpresaSis == empresaId))
                    .OrderByDescending(periodo => periodo.FechaFin)
                    .FirstOrDefault()
            };

        if (!string.IsNullOrWhiteSpace(filter))
        {
            query = query.Where(item =>
                item.Incidencia.NombreCompleto.Contains(filter) ||
                item.Incidencia.ClavePersona.Contains(filter) ||
                item.Incidencia.TipoIncidenciaDescripcion.Contains(filter) ||
                item.Incidencia.Comentario.Contains(filter) ||
                item.Incidencia.TipoJustificacionDescripcion.Contains(filter));
        }

        var total = await query.CountAsync();
        var descending = string.Equals(request.SortDirection, "Descending", StringComparison.OrdinalIgnoreCase)
            || string.Equals(request.SortDirection, "Desc", StringComparison.OrdinalIgnoreCase);
        var sorted = (request.SortLabel ?? string.Empty) switch
        {
            nameof(VwRhIncidenciaResponse.NombreCompleto) => descending
                ? query.OrderByDescending(item => item.Incidencia.NombreCompleto)
                : query.OrderBy(item => item.Incidencia.NombreCompleto),
            nameof(VwRhIncidenciaResponse.TipoIncidenciaDescripcion) => descending
                ? query.OrderByDescending(item => item.Incidencia.TipoIncidenciaDescripcion)
                : query.OrderBy(item => item.Incidencia.TipoIncidenciaDescripcion),
            nameof(VwRhIncidenciaResponse.Activo) => descending
                ? query.OrderByDescending(item => item.Incidencia.Activo)
                : query.OrderBy(item => item.Incidencia.Activo),
            nameof(VwRhIncidenciaResponse.PkidIncidencia) => descending
                ? query.OrderByDescending(item => item.Incidencia.PkidIncidencia)
                : query.OrderBy(item => item.Incidencia.PkidIncidencia),
            _ => descending
                ? query.OrderByDescending(item => item.Incidencia.Fecha)
                : query.OrderBy(item => item.Incidencia.Fecha)
        };

        var items = await sorted
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(item => new VwRhIncidenciaResponse
            {
                PkidIncidencia = item.Incidencia.PkidIncidencia,
                FkidPersonaNom = item.Incidencia.FkidPersonaNom,
                NombreCompleto = item.Incidencia.NombreCompleto,
                ClavePersona = item.Incidencia.ClavePersona,
                Rfc = item.Incidencia.Rfc,
                Curp = item.Incidencia.Curp,
                FkidTipoIncidenciaNom = item.Incidencia.FkidTipoIncidenciaNom,
                TipoIncidenciaDescripcion = item.Incidencia.TipoIncidenciaDescripcion,
                Fecha = item.Incidencia.Fecha,
                Comentario = item.Incidencia.Comentario,
                FkidTipoJustificacionNom = item.Incidencia.FkidTipoJustificacionNom,
                TipoJustificacionDescripcion = item.Incidencia.TipoJustificacionDescripcion,
                AplicaDescuento = item.Incidencia.AplicaDescuento,
                ComentarioJustificacion = item.Incidencia.ComentarioJustificacion,
                FkidPeriodoQuincenalSis = item.Incidencia.FkidPeriodoQuincenalSis,
                FechaInicio = item.Periodo == null ? null : item.Periodo.FechaInicio,
                FechaFin = item.Periodo == null ? null : item.Periodo.FechaFin,
                Activo = item.Incidencia.Activo,
                UsuarioCreacion = item.Incidencia.UsuarioCreacion.HasValue ? item.Incidencia.UsuarioCreacion.Value.ToString() : string.Empty,
                FechaCreacion = item.Incidencia.FechaCreacion,
                UsuarioModificacion = item.Incidencia.UsuarioModificacion.HasValue ? item.Incidencia.UsuarioModificacion.Value.ToString() : string.Empty,
                FechaModificacion = item.Incidencia.FechaModificacion
            })
            .ToListAsync();

        return new RhIncidenciaPage(items, total);
    }
}
