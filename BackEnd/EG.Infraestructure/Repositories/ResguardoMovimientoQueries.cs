

using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Infrastructure;

public sealed class ResguardoMovimientoQueries(EGestionContext context) : IResguardoMovimientoQueries
{
    private readonly EGestionContext _context = context;

    public async Task<ResguardoMovimientoPage> GetAllAsync(int empresaId, int anioId)
    {
        var scope = await GetScopeAsync(empresaId, anioId);
        var items = await ApplyScopeFilter(BaseQuery(), scope.EmpresaId, scope.Anio)
            .OrderByDescending(x => x.FechaMovimiento).Take(500).Select(x => Map(x)).ToListAsync();
        return new ResguardoMovimientoPage(items, items.Count);
    }

    public async Task<ResguardoMovimientoResponse?> GetByIdAsync(int id, int empresaId, int anioId)
    {
        var scope = await GetScopeAsync(empresaId, anioId);
        var item = await ApplyScopeFilter(BaseQuery(), scope.EmpresaId, scope.Anio)
            .Where(x => x.PkidResguardoMovimiento == id).Select(x => Map(x)).FirstOrDefaultAsync();
        return item;
    }

    public async Task<ResguardoMovimientoPage> GetAllPaginadoAsync(ResguardoMovimientoFilter request, int empresaId, int anioId)
    {
        var pageSize = Math.Clamp(request.PageSize <= 0 ? 10 : request.PageSize, 1, 250);
        var page = Math.Clamp(request.Page, 1, int.MaxValue / pageSize);
        var scope = await GetScopeAsync(empresaId, anioId);
        var query = ApplySearch(ApplyScopeFilter(BaseQuery(), scope.EmpresaId, scope.Anio), request.SearchString);
        var total = await query.CountAsync();
        var items = await ApplySort(query, request.SortLabel, request.SortDirection)
            .Skip((page - 1) * pageSize).Take(pageSize).Select(x => Map(x)).ToListAsync();
        return new ResguardoMovimientoPage(items, total);
    }
        private IQueryable<ResguardoMovimiento> BaseQuery() =>
            _context.ResguardoMovimientos
                .AsNoTracking()
                .Include(x => x.FkidBienAlmaNavigation)
                .Include(x => x.FkidResguardoOrigenAlmaNavigation)
                .Include(x => x.FkidResguardoDestinoAlmaNavigation)
                .Where(x => x.Activo);

        private static IQueryable<ResguardoMovimiento> ApplySearch(IQueryable<ResguardoMovimiento> query, string? filter)
        {
            if (string.IsNullOrWhiteSpace(filter))
            {
                return query;
            }

            var value = filter.Trim();
            return query.Where(x =>
                (x.TipoMovimiento != null && x.TipoMovimiento.Contains(value)) ||
                (x.Observaciones != null && x.Observaciones.Contains(value)) ||
                (x.FkidBienAlmaNavigation != null && (
                    (x.FkidBienAlmaNavigation.Clave != null && x.FkidBienAlmaNavigation.Clave.Contains(value)) ||
                    (x.FkidBienAlmaNavigation.Descripcion != null && x.FkidBienAlmaNavigation.Descripcion.Contains(value)) ||
                    (x.FkidBienAlmaNavigation.Serie != null && x.FkidBienAlmaNavigation.Serie.Contains(value)))) ||
                (x.FkidResguardoOrigenAlmaNavigation != null && (
                    (x.FkidResguardoOrigenAlmaNavigation.Folio != null && x.FkidResguardoOrigenAlmaNavigation.Folio.Contains(value)) ||
                    (x.FkidResguardoOrigenAlmaNavigation.Responsable != null && x.FkidResguardoOrigenAlmaNavigation.Responsable.Contains(value)))) ||
                (x.FkidResguardoDestinoAlmaNavigation != null && (
                    (x.FkidResguardoDestinoAlmaNavigation.Folio != null && x.FkidResguardoDestinoAlmaNavigation.Folio.Contains(value)) ||
                    (x.FkidResguardoDestinoAlmaNavigation.Responsable != null && x.FkidResguardoDestinoAlmaNavigation.Responsable.Contains(value)))));
        }

        private static IQueryable<ResguardoMovimiento> ApplyScopeFilter(IQueryable<ResguardoMovimiento> query, int empresaId, int anio)
        {
            return query.Where(x =>
                (x.FkidResguardoOrigenAlmaNavigation != null && x.FkidResguardoOrigenAlmaNavigation.FkidEmpresaSis == empresaId) ||
                (x.FkidResguardoDestinoAlmaNavigation != null && x.FkidResguardoDestinoAlmaNavigation.FkidEmpresaSis == empresaId))
                .Where(x => x.FechaMovimiento.Year == anio);
        }

        private async Task<(int EmpresaId, int Anio)> GetScopeAsync(int empresaId, int anioId)
        {


            var anio = await _context.Anios.AsNoTracking()
                .Where(x => x.PkidAnio == anioId && x.Activo)
                .Select(x => (int?)x.Clave)
                .SingleOrDefaultAsync();
            if (!anio.HasValue)
            {
                throw new InvalidOperationException("El ejercicio presupuestal seleccionado no existe o está inactivo.");
            }

            return (empresaId, anio.Value);
        }

        private static IQueryable<ResguardoMovimiento> ApplySort(IQueryable<ResguardoMovimiento> query, string? sortLabel, string? sortDirection)
        {
            var descending = string.Equals(sortDirection, "Descending", StringComparison.OrdinalIgnoreCase)
                || string.Equals(sortDirection, "Desc", StringComparison.OrdinalIgnoreCase);

            return sortLabel switch
            {
                "PkidResguardoMovimiento" => descending ? query.OrderByDescending(x => x.PkidResguardoMovimiento) : query.OrderBy(x => x.PkidResguardoMovimiento),
                "BienClave" => descending ? query.OrderByDescending(x => x.FkidBienAlmaNavigation.Clave) : query.OrderBy(x => x.FkidBienAlmaNavigation.Clave),
                "TipoMovimiento" => descending ? query.OrderByDescending(x => x.TipoMovimiento) : query.OrderBy(x => x.TipoMovimiento),
                "FechaMovimiento" => descending ? query.OrderByDescending(x => x.FechaMovimiento) : query.OrderBy(x => x.FechaMovimiento),
                "ResguardoOrigenFolio" => descending ? query.OrderByDescending(x => x.FkidResguardoOrigenAlmaNavigation.Folio) : query.OrderBy(x => x.FkidResguardoOrigenAlmaNavigation.Folio),
                "ResguardoDestinoFolio" => descending ? query.OrderByDescending(x => x.FkidResguardoDestinoAlmaNavigation.Folio) : query.OrderBy(x => x.FkidResguardoDestinoAlmaNavigation.Folio),
                _ => query.OrderByDescending(x => x.FechaMovimiento)
            };
        }

        private static ResguardoMovimientoResponse Map(ResguardoMovimiento x) => new()
        {
            PkidResguardoMovimiento = x.PkidResguardoMovimiento,
            FkidResguardoDetalleAlma = x.FkidResguardoDetalleAlma,
            FkidBienAlma = x.FkidBienAlma,
            BienClave = x.FkidBienAlmaNavigation?.Clave ?? string.Empty,
            BienDescripcion = x.FkidBienAlmaNavigation?.Descripcion ?? string.Empty,
            BienSerie = x.FkidBienAlmaNavigation?.Serie ?? string.Empty,
            FkidResguardoOrigenAlma = x.FkidResguardoOrigenAlma,
            ResguardoOrigenFolio = x.FkidResguardoOrigenAlmaNavigation?.Folio ?? string.Empty,
            ResguardoOrigenResponsable = x.FkidResguardoOrigenAlmaNavigation?.Responsable ?? string.Empty,
            FkidResguardoDestinoAlma = x.FkidResguardoDestinoAlma,
            ResguardoDestinoFolio = x.FkidResguardoDestinoAlmaNavigation?.Folio ?? string.Empty,
            ResguardoDestinoResponsable = x.FkidResguardoDestinoAlmaNavigation?.Responsable ?? string.Empty,
            TipoMovimiento = x.TipoMovimiento ?? string.Empty,
            FechaMovimiento = x.FechaMovimiento,
            Observaciones = x.Observaciones ?? string.Empty,
            Activo = x.Activo,
            FechaCreacion = x.FechaCreacion,
            UsuarioCreacion = x.UsuarioCreacion
        };

}
