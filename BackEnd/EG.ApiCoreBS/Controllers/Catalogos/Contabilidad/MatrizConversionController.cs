using Mapster;
using EG.ApiCoreBS.Helpers;
using EG.ApiCoreBS.Services;
using EG.Domain.Interfaces;
using EG.Application.Interfaces.Contabilidad;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Controllers.Catalogos.Contabilidad
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class MatrizConversionController : ControllerBase
    {
        private readonly IMatrizConversionService _service;
        private readonly IUserContextService _userContext;
        private readonly EGestionContext _context;

        public MatrizConversionController(
            IMatrizConversionService service,
            IUserContextService userContext,
            EGestionContext context)
        {
            _service = service;
            _userContext = userContext;
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<MatrizConversionResponse>>> GetAll()
        {
            var items = await _service.GetAllAsync();
            return Ok(new PagedResult<MatrizConversionResponse>
            {
                Success = true,
                Message = "Registros obtenidos correctamente",
                Code = "SUCCESS",
                Items = items.ToList(),
                TotalCount = items.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<MatrizConversionResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            if (result == null)
            {
                return NotFound(new PagedResult<MatrizConversionResponse>
                {
                    Success = false,
                    Message = $"No se encontrÃ³ el registro con ID {id}",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }

            return Ok(new PagedResult<MatrizConversionResponse>
            {
                Success = true,
                Message = "Registro encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<MatrizConversionResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<MatrizConversionResponse>>> Create([FromBody] MatrizConversionResponse request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new PagedResult<MatrizConversionResponse>
                {
                    Success = false,
                    Message = "Datos invÃ¡lidos",
                    Code = "INVALID_MODEL",
                    TotalCount = 0
                });
            }

            var dto = request.Adapt<MatrizConversionDto>();

            var existe = await _service.ExisteRegistroAsync(dto.FkidAnioSis, dto.FkidProgramaPres, dto.FkidPartidaSis);
            if (existe)
            {
                return Conflict(new PagedResult<MatrizConversionResponse>
                {
                    Success = false,
                    Message = "El Programa y Partida ya se encuentran dados de alta para el aÃ±o presupuestal seleccionado",
                    Code = "DUPLICATE",
                    TotalCount = 0
                });
            }

            int currentUserId = _userContext.GetCurrentUserId();
            var created = await _service.AddAsync(dto, currentUserId);

            return CreatedAtAction(nameof(GetById), new { id = created.PkidMatrizConversion },
                new PagedResult<MatrizConversionResponse>
                {
                    Success = true,
                    Message = "Registro creado exitosamente",
                    Code = "SUCCESS",
                    Data = created,
                    TotalCount = 1
                });
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<MatrizConversionResponse>>> Update(int id, [FromBody] MatrizConversionResponse request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new PagedResult<MatrizConversionResponse>
                {
                    Success = false,
                    Message = "Datos invÃ¡lidos",
                    Code = "INVALID_MODEL",
                    TotalCount = 0
                });
            }

            var dto = request.Adapt<MatrizConversionDto>();
            dto.PkidMatrizConversion = id;

            var existe = await _service.ExisteRegistroUpdateAsync(id, dto.FkidAnioSis, dto.FkidProgramaPres, dto.FkidPartidaSis);
            if (existe)
            {
                return Conflict(new PagedResult<MatrizConversionResponse>
                {
                    Success = false,
                    Message = "El Programa y Partida ya se encuentran dados de alta para el aÃ±o presupuestal seleccionado",
                    Code = "DUPLICATE",
                    TotalCount = 0
                });
            }

            int currentUserId = _userContext.GetCurrentUserId();
            await _service.UpdateAsync(id, dto, currentUserId);

            var updated = await _service.GetByIdAsync(id);

            return Ok(new PagedResult<MatrizConversionResponse>
            {
                Success = true,
                Message = "Registro actualizado correctamente",
                Code = "SUCCESS",
                Data = updated,
                TotalCount = 1
            });
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<MatrizConversionResponse>>> Delete(int id)
        {
            try
            {
                await _service.DeleteAsync(id);
                return Ok(new PagedResult<MatrizConversionResponse>
                {
                    Success = true,
                    Message = "Registro eliminado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<MatrizConversionResponse>
                {
                    Success = false,
                    Message = $"No se encontrÃ³ el registro con ID {id}",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<MatrizConversionResponse>>> GetAllPaginado([FromBody] PagedRequest request, [FromQuery] int? idAnio = null)
        {
            var filters = new Dictionary<string, object>();
            if (idAnio.HasValue)
            {
                filters.Add("FkidAnioSis", idAnio.Value);
            }

            var result = await _service.GetAllPaginadoAsync(request, filters);
            return Ok(new PagedResult<MatrizConversionResponse>
            {
                Success = true,
                Message = "Registros obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount,
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<MatrizConversionResponse>>> Buscar([FromBody] BusquedaRequest request, [FromQuery] int? idAnio = null)
        {
            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };

            var filters = new Dictionary<string, object>();
            if (idAnio.HasValue)
            {
                filters.Add("FkidAnioSis", idAnio.Value);
            }

            var result = await _service.GetAllPaginadoAsync(pagedRequest, filters);
            return Ok(new PagedResult<MatrizConversionResponse>
            {
                Success = true,
                Message = "BÃºsqueda realizada correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpGet("GetPrograma")]
        public async Task<IActionResult> GetPrograma([FromQuery] int? idAnio = null)
        {
            var query = _context.Set<Programa>().AsQueryable();
            if (idAnio.HasValue)
            {
                query = query.Where(p => p.MatrizConversions.Any(mc => mc.FkidAnioSis == idAnio.Value && mc.Activo));
            }

            var programas = await query
                .Select(p => new { PkidCuenta = p.PkidPrograma, ClaveNombre = p.Clave })
                .Distinct()
                .ToListAsync();

            return Ok(programas);
        }

        [HttpGet("GetAllProgramas")]
        public async Task<IActionResult> GetAllProgramas()
        {
            var programas = await _context.Set<Programa>()
                .Select(p => new { PkidCuenta = p.PkidPrograma, ClaveNombre = p.Clave })
                .Distinct()
                .ToListAsync();

            return Ok(programas);
        }

        [HttpGet("GetAllProgramasLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetAllProgramasLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var query = _context.Set<Programa>()
                .OrderBy(p => p.Clave)
                .Select(p => new LookupItem
                {
                    Id = p.PkidPrograma,
                    Text = p.Clave ?? ""
                });

            return Ok(await LookupPagingHelper.ToPagedResultAsync(query, page, pageSize, filter));
        }

        [HttpGet("GetPartida")]
        public async Task<IActionResult> GetPartida()
        {
            var partidas = await _context.Set<Partidum1>()
                .Where(p => p.Activo)
                .Select(p => new { PkidCuenta = p.PkidPartida, ClaveNombre = p.Descripcion })
                .Distinct()
                .ToListAsync();

            return Ok(partidas);
        }

        [HttpGet("GetPartidaLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetPartidaLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var query = _context.Set<Partidum1>()
                .Where(p => p.Activo)
                .OrderBy(p => p.Descripcion)
                .Select(p => new LookupItem
                {
                    Id = p.PkidPartida,
                    Text = p.Descripcion ?? ""
                });

            return Ok(await LookupPagingHelper.ToPagedResultAsync(query, page, pageSize, filter));
        }

        [HttpGet("GetCuentaContableAprobado")]
        public async Task<IActionResult> GetCuentaContableAprobado()
        {
            var cuentas = await _context.VwCuentas
                .Where(c => c.ClaveOrd.StartsWith("8 2 1") && c.NivelCuenta == 7)
                .Select(c => new { c.PkIdCuenta, c.ClaveNombre })
                .Distinct()
                .ToListAsync();

            return Ok(cuentas);
        }

        [HttpGet("GetCuentaContableAprobadoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetCuentaContableAprobadoLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var query = _context.VwCuentas
                .Where(c => c.ClaveOrd.StartsWith("8 2 1") && c.NivelCuenta == 7)
                .OrderBy(c => c.ClaveNombre)
                .Select(c => new LookupItem { Id = c.PkIdCuenta, Text = c.ClaveNombre ?? "" });

            return Ok(await LookupPagingHelper.ToPagedResultAsync(query, page, pageSize, filter));
        }

        [HttpGet("GetCuentaContablePorEjercer")]
        public async Task<IActionResult> GetCuentaContablePorEjercer()
        {
            var cuentas = await _context.VwCuentas
                .Where(c => c.ClaveOrd.StartsWith("8 2 2"))
                .Select(c => new { c.PkIdCuenta, c.ClaveNombre })
                .Distinct()
                .ToListAsync();

            return Ok(cuentas);
        }

        [HttpGet("GetCuentaContablePorEjercerLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetCuentaContablePorEjercerLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var query = _context.VwCuentas
                .Where(c => c.ClaveOrd.StartsWith("8 2 2"))
                .OrderBy(c => c.ClaveNombre)
                .Select(c => new LookupItem { Id = c.PkIdCuenta, Text = c.ClaveNombre ?? "" });

            return Ok(await LookupPagingHelper.ToPagedResultAsync(query, page, pageSize, filter));
        }

        [HttpGet("GetCuentaContableModificado")]
        public async Task<IActionResult> GetCuentaContableModificado()
        {
            var cuentas = await _context.VwCuentas
                .Where(c => c.ClaveOrd.StartsWith("8 2 3"))
                .Select(c => new { c.PkIdCuenta, c.ClaveNombre })
                .Distinct()
                .ToListAsync();

            return Ok(cuentas);
        }

        [HttpGet("GetCuentaContableModificadoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetCuentaContableModificadoLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var query = _context.VwCuentas
                .Where(c => c.ClaveOrd.StartsWith("8 2 3"))
                .OrderBy(c => c.ClaveNombre)
                .Select(c => new LookupItem { Id = c.PkIdCuenta, Text = c.ClaveNombre ?? "" });

            return Ok(await LookupPagingHelper.ToPagedResultAsync(query, page, pageSize, filter));
        }

        [HttpGet("GetCuentaContableComprometido")]
        public async Task<IActionResult> GetCuentaContableComprometido()
        {
            var cuentas = await _context.VwCuentas
                .Where(c => c.ClaveOrd.StartsWith("8 2 4"))
                .Select(c => new { c.PkIdCuenta, c.ClaveNombre })
                .Distinct()
                .ToListAsync();

            return Ok(cuentas);
        }

        [HttpGet("GetCuentaContableComprometidoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetCuentaContableComprometidoLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var query = _context.VwCuentas
                .Where(c => c.ClaveOrd.StartsWith("8 2 4"))
                .OrderBy(c => c.ClaveNombre)
                .Select(c => new LookupItem { Id = c.PkIdCuenta, Text = c.ClaveNombre ?? "" });

            return Ok(await LookupPagingHelper.ToPagedResultAsync(query, page, pageSize, filter));
        }

        [HttpGet("GetCuentaContableDevengado")]
        public async Task<IActionResult> GetCuentaContableDevengado()
        {
            var cuentas = await _context.VwCuentas
                .Where(c => c.ClaveOrd.StartsWith("8 2 5"))
                .Select(c => new { c.PkIdCuenta, c.ClaveNombre })
                .Distinct()
                .ToListAsync();

            return Ok(cuentas);
        }

        [HttpGet("GetCuentaContableDevengadoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetCuentaContableDevengadoLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var query = _context.VwCuentas
                .Where(c => c.ClaveOrd.StartsWith("8 2 5"))
                .OrderBy(c => c.ClaveNombre)
                .Select(c => new LookupItem { Id = c.PkIdCuenta, Text = c.ClaveNombre ?? "" });

            return Ok(await LookupPagingHelper.ToPagedResultAsync(query, page, pageSize, filter));
        }

        [HttpGet("GetCuentaContableEjercido")]
        public async Task<IActionResult> GetCuentaContableEjercido()
        {
            var cuentas = await _context.VwCuentas
                .Where(c => c.ClaveOrd.StartsWith("8 2 6"))
                .Select(c => new { c.PkIdCuenta, c.ClaveNombre })
                .Distinct()
                .ToListAsync();

            return Ok(cuentas);
        }

        [HttpGet("GetCuentaContableEjercidoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetCuentaContableEjercidoLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var query = _context.VwCuentas
                .Where(c => c.ClaveOrd.StartsWith("8 2 6"))
                .OrderBy(c => c.ClaveNombre)
                .Select(c => new LookupItem { Id = c.PkIdCuenta, Text = c.ClaveNombre ?? "" });

            return Ok(await LookupPagingHelper.ToPagedResultAsync(query, page, pageSize, filter));
        }

        [HttpGet("GetCuentaContablePagado")]
        public async Task<IActionResult> GetCuentaContablePagado()
        {
            var cuentas = await _context.VwCuentas
                .Where(c => c.ClaveOrd.StartsWith("8 2 7"))
                .Select(c => new { c.PkIdCuenta, c.ClaveNombre })
                .Distinct()
                .ToListAsync();

            return Ok(cuentas);
        }

        [HttpGet("GetCuentaContablePagadoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetCuentaContablePagadoLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var query = _context.VwCuentas
                .Where(c => c.ClaveOrd.StartsWith("8 2 7"))
                .OrderBy(c => c.ClaveNombre)
                .Select(c => new LookupItem { Id = c.PkIdCuenta, Text = c.ClaveNombre ?? "" });

            return Ok(await LookupPagingHelper.ToPagedResultAsync(query, page, pageSize, filter));
        }

        [HttpGet("GetCuentaContableGasto")]
        public async Task<IActionResult> GetCuentaContableGasto()
        {
            var cuentas = await _context.VwCuentas
                .Where(c => c.ClaveOrd.StartsWith("5"))
                .Select(c => new { c.PkIdCuenta, c.ClaveNombre })
                .Distinct()
                .ToListAsync();

            return Ok(cuentas);
        }

        [HttpGet("GetCuentaContableGastoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetCuentaContableGastoLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var query = _context.VwCuentas
                .Where(c => c.ClaveOrd.StartsWith("5"))
                .OrderBy(c => c.ClaveNombre)
                .Select(c => new LookupItem { Id = c.PkIdCuenta, Text = c.ClaveNombre ?? "" });

            return Ok(await LookupPagingHelper.ToPagedResultAsync(query, page, pageSize, filter));
        }
    }
}
