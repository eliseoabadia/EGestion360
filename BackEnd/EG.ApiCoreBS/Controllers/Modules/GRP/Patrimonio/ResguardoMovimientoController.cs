using EG.Common.Enums;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;

namespace EG.ApiCoreBS.Controllers.Patrimonio
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ResguardoMovimientoController : ControllerBase
    {
        private readonly EGestionContext _context;

        public ResguardoMovimientoController(EGestionContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<ResguardoMovimientoResponse>>> GetAll()
        {
            var items = await BaseQuery()
                .OrderByDescending(x => x.FechaMovimiento)
                .Take(500)
                .Select(x => Map(x))
                .ToListAsync();

            return Ok(Success(items, items.Count));
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<ResguardoMovimientoResponse>>> GetById(int id)
        {
            var item = await BaseQuery()
                .Where(x => x.PkidResguardoMovimiento == id)
                .Select(x => Map(x))
                .FirstOrDefaultAsync();

            return item == null
                ? NotFound(new PagedResult<ResguardoMovimientoResponse>
                {
                    Success = false,
                    Message = $"Movimiento de resguardo con ID {id} no encontrado.",
                    Code = ApiResponseCode.NotFound.ToCode()
                })
                : Ok(Success(new List<ResguardoMovimientoResponse> { item }, 1, item));
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<ResguardoMovimientoResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var page = request.Page <= 0 ? 1 : request.Page;
            var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;
            var query = ApplySearch(ApplyEmpresaFilter(BaseQuery(), request), request.SearchString ?? request.Filtro);
            var total = await query.CountAsync();
            var items = await ApplySort(query, request.SortLabel, request.SortDirection)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(x => Map(x))
                .ToListAsync();

            return Ok(Success(items, total));
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

        private static IQueryable<ResguardoMovimiento> ApplyEmpresaFilter(IQueryable<ResguardoMovimiento> query, PagedRequest request)
        {
            if (!TryGetIntFilter(request, "FkidEmpresaSis", out var empresaId) || empresaId <= 0)
            {
                return query;
            }

            return query.Where(x =>
                (x.FkidResguardoOrigenAlmaNavigation != null && x.FkidResguardoOrigenAlmaNavigation.FkidEmpresaSis == empresaId) ||
                (x.FkidResguardoDestinoAlmaNavigation != null && x.FkidResguardoDestinoAlmaNavigation.FkidEmpresaSis == empresaId));
        }

        private static bool TryGetIntFilter(PagedRequest request, string key, out int value)
        {
            value = 0;
            if (request.AdditionalFilters == null || !request.AdditionalFilters.TryGetValue(key, out var raw) || raw == null)
            {
                return false;
            }

            if (raw is JsonElement json)
            {
                return json.ValueKind switch
                {
                    JsonValueKind.Number => json.TryGetInt32(out value),
                    JsonValueKind.String => int.TryParse(json.GetString(), out value),
                    _ => false
                };
            }

            return int.TryParse(raw.ToString(), out value);
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

        private static PagedResult<ResguardoMovimientoResponse> Success(
            IList<ResguardoMovimientoResponse> items,
            int total,
            ResguardoMovimientoResponse? data = null) =>
            new()
            {
                Success = true,
                Message = "Movimientos de resguardo obtenidos correctamente.",
                Code = ApiResponseCode.Success.ToCode(),
                Items = items,
                Data = data,
                TotalCount = total
            };
    }
}
