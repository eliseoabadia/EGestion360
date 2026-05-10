using AutoMapper;
using EG.ApiCoreBS.Helpers;
using EG.ApiCoreBS.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Controllers.Catalogos.Contabilidad
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class MatrizIngresoController : ControllerBase
    {
        private readonly GenericService<MatrizIngreso, MatrizIngresoDto, MatrizIngresoResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;
        private readonly EGestionContext _context;

        public MatrizIngresoController(
            GenericService<MatrizIngreso, MatrizIngresoDto, MatrizIngresoResponse> service,
            IMapper mapper,
            IUserContextService userContext,
            EGestionContext context)
        {
            _service = service;
            _mapper = mapper;
            _userContext = userContext;
            _context = context;
            ConfigureService();
        }

        private void ConfigureService()
        {
            _service.AddInclude(e => e.FkIdProgramaNavigation);
            _service.AddInclude(e => e.FkIdOrigenNavigation);
            _service.AddInclude(e => e.FkIdCuentaContableAutorizadoNavigation);
            _service.AddInclude(e => e.FkIdCuentaContablePorEjercerNavigation);
            _service.AddInclude(e => e.FkIdCuentaContableModificadoNavigation);
            _service.AddInclude(e => e.FkIdCuentaContableDevengadoNavigation);
            _service.AddInclude(e => e.FkIdCuentaContableRecaudadoNavigation);
            _service.AddInclude(e => e.FkIdCuentaContableDepositoNavigation);
            _service.AddInclude(e => e.UsuarioCreacionNavigation);
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<MatrizIngresoResponse>>> GetAll()
        {
            var items = await _service.GetAllAsync();
            return Ok(new PagedResult<MatrizIngresoResponse>
            {
                Success = true,
                Message = "Registros obtenidos correctamente",
                Code = "SUCCESS",
                Items = items.ToList(),
                TotalCount = items.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<MatrizIngresoResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            if (result == null)
            {
                return NotFound(new PagedResult<MatrizIngresoResponse>
                {
                    Success = false,
                    Message = $"No se encontró el registro con ID {id}",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }

            return Ok(new PagedResult<MatrizIngresoResponse>
            {
                Success = true,
                Message = "Registro encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<MatrizIngresoResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<MatrizIngresoResponse>>> Create([FromBody] MatrizIngresoResponse request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new PagedResult<MatrizIngresoResponse>
                {
                    Success = false,
                    Message = "Datos inválidos",
                    Code = "INVALID_MODEL",
                    TotalCount = 0
                });
            }

            var dto = _mapper.Map<MatrizIngresoDto>(request);
            dto.UsuarioCreacion = _userContext.GetCurrentUserId();
            dto.FechaCreacion = DateTime.UtcNow;
            dto.Activo = true;

            await _service.AddAsync(dto);

            var created = await _service.GetByIdAsync(dto.PkidMatrizIngreso);

            return CreatedAtAction(nameof(GetById), new { id = dto.PkidMatrizIngreso },
                new PagedResult<MatrizIngresoResponse>
                {
                    Success = true,
                    Message = "Registro creado exitosamente",
                    Code = "SUCCESS",
                    Data = created,
                    TotalCount = 1
                });
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<MatrizIngresoResponse>>> Update(int id, [FromBody] MatrizIngresoResponse request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new PagedResult<MatrizIngresoResponse>
                {
                    Success = false,
                    Message = "Datos inválidos",
                    Code = "INVALID_MODEL",
                    TotalCount = 0
                });
            }

            var dto = _mapper.Map<MatrizIngresoDto>(request);
            dto.PkidMatrizIngreso = id;
            dto.UsuarioModificacion = _userContext.GetCurrentUserId();
            dto.FechaModificacion = DateTime.UtcNow;

            await _service.UpdateAsync(id, dto);

            var updated = await _service.GetByIdAsync(id);

            return Ok(new PagedResult<MatrizIngresoResponse>
            {
                Success = true,
                Message = "Registro actualizado correctamente",
                Code = "SUCCESS",
                Data = updated,
                TotalCount = 1
            });
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<MatrizIngresoResponse>>> Delete(int id)
        {
            try
            {
                var existing = await _context.Set<MatrizIngreso>().FirstOrDefaultAsync(e => e.PkIdMatrizIngreso == id);
                if (existing == null)
                {
                    return NotFound(new PagedResult<MatrizIngresoResponse>
                    {
                        Success = false,
                        Message = $"No se encontró el registro con ID {id}",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    });
                }

                existing.Activo = false;
                existing.UsuarioModificacion = _userContext.GetCurrentUserId();
                existing.FechaModificacion = DateTime.UtcNow;

                await _context.SaveChangesAsync();
                return Ok(new PagedResult<MatrizIngresoResponse>
                {
                    Success = true,
                    Message = "Registro eliminado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<MatrizIngresoResponse>
                {
                    Success = false,
                    Message = $"No se encontró el registro con ID {id}",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<MatrizIngresoResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var query = _service.GetQueryWithIncludes();

            if (!string.IsNullOrWhiteSpace(request.Filtro))
            {
                query = query.Where(e =>
                    e.FkIdProgramaNavigation.Clave.Contains(request.Filtro) ||
                    e.FkIdOrigenNavigation.Descripcion.Contains(request.Filtro));
            }

            if (!string.IsNullOrEmpty(request.SortLabel))
            {
                var isAscending = request.SortDirection?.ToString().ToLower() == "ascending";
                query = request.SortLabel switch
                {
                    "PkidMatrizIngreso" => isAscending ? query.OrderBy(e => e.PkIdMatrizIngreso) : query.OrderByDescending(e => e.PkIdMatrizIngreso),
                    "ProgramaClave" => isAscending ? query.OrderBy(e => e.FkIdProgramaNavigation.Clave) : query.OrderByDescending(e => e.FkIdProgramaNavigation.Clave),
                    "OrigenDescripcion" => isAscending ? query.OrderBy(e => e.FkIdOrigenNavigation.Descripcion) : query.OrderByDescending(e => e.FkIdOrigenNavigation.Descripcion),
                    _ => query.OrderBy(e => e.PkIdMatrizIngreso)
                };
            }
            else
            {
                query = query.OrderBy(e => e.PkIdMatrizIngreso);
            }

            var totalItems = await query.CountAsync();
            var items = await query
                .Skip((request.Page - 1) * request.PageSize)
                .Take(request.PageSize)
                .ToListAsync();

            var responseItems = items.Select(e => new MatrizIngresoResponse
            {
                PkidMatrizIngreso = e.PkIdMatrizIngreso,
                FkIdPrograma = e.FkIdPrograma,
                FkIdOrigen = e.FkIdOrigen,
                FkIdCuentaContableAutorizado = e.FkIdCuentaContableAutorizado,
                FkIdCuentaContablePorEjercer = e.FkIdCuentaContablePorEjercer,
                FkIdCuentaContableModificado = e.FkIdCuentaContableModificado,
                FkIdCuentaContableDevengado = e.FkIdCuentaContableDevengado,
                FkIdCuentaContableRecaudado = e.FkIdCuentaContableRecaudado,
                FkIdCuentaContableDeposito = e.FkIdCuentaContableDeposito,
                ProgramaClave = e.FkIdProgramaNavigation?.Clave ?? string.Empty,
                ProgramaDescripcion = e.FkIdProgramaNavigation?.Descripcion ?? string.Empty,
                OrigenDescripcion = e.FkIdOrigenNavigation?.Descripcion ?? string.Empty,
                CuentaAutorizadoNombre = e.FkIdCuentaContableAutorizadoNavigation != null ? e.FkIdCuentaContableAutorizadoNavigation.Cuenta + " - " + e.FkIdCuentaContableAutorizadoNavigation.Descripcion : null,
                CuentaPorEjecutarNombre = e.FkIdCuentaContablePorEjercerNavigation != null ? e.FkIdCuentaContablePorEjercerNavigation.Cuenta + " - " + e.FkIdCuentaContablePorEjercerNavigation.Descripcion : null,
                CuentaModificadoNombre = e.FkIdCuentaContableModificadoNavigation != null ? e.FkIdCuentaContableModificadoNavigation.Cuenta + " - " + e.FkIdCuentaContableModificadoNavigation.Descripcion : null,
                CuentaDevengadoNombre = e.FkIdCuentaContableDevengadoNavigation != null ? e.FkIdCuentaContableDevengadoNavigation.Cuenta + " - " + e.FkIdCuentaContableDevengadoNavigation.Descripcion : null,
                CuentaRecaudadoNombre = e.FkIdCuentaContableRecaudadoNavigation != null ? e.FkIdCuentaContableRecaudadoNavigation.Cuenta + " - " + e.FkIdCuentaContableRecaudadoNavigation.Descripcion : null,
                CuentaDepositoNombre = e.FkIdCuentaContableDepositoNavigation != null ? e.FkIdCuentaContableDepositoNavigation.Cuenta + " - " + e.FkIdCuentaContableDepositoNavigation.Descripcion : null,
                Activo = e.Activo,
                FechaCreacion = e.FechaCreacion,
                UsuarioCreacion = e.UsuarioCreacion
            }).ToList();

            return Ok(new PagedResult<MatrizIngresoResponse>
            {
                Success = true,
                Message = "Registros obtenidos correctamente",
                Code = "SUCCESS",
                Items = responseItems,
                TotalCount = totalItems
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<MatrizIngresoResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };

            return await GetAllPaginado(pagedRequest);
        }

        [HttpGet("GetPrograma")]
        public async Task<IActionResult> GetPrograma()
        {
            var programas = await _context.Set<Programa>()
                .Select(p => new { PkidCuenta = p.PkidPrograma, ClaveNombre = p.Clave + " - " + p.Descripcion })
                .Distinct()
                .ToListAsync();

            return Ok(programas);
        }

        [HttpGet("GetProgramaLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetProgramaLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var query = _context.Set<Programa>()
                .OrderBy(p => p.Clave)
                .Select(p => new LookupItem
                {
                    Id = p.PkidPrograma,
                    Text = (p.Clave ?? "") + " - " + (p.Descripcion ?? "")
                });

            return Ok(await LookupPagingHelper.ToPagedResultAsync(query, page, pageSize, filter));
        }

        [HttpGet("GetOrigen")]
        public async Task<IActionResult> GetOrigen()
        {
            var origenes = await _context.Set<Origen>()
                .Select(o => new { PkidCuenta = o.PkidOrigen, ClaveNombre = o.Descripcion })
                .Distinct()
                .ToListAsync();

            return Ok(origenes);
        }

        [HttpGet("GetOrigenLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetOrigenLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var query = _context.Set<Origen>()
                .OrderBy(o => o.Descripcion)
                .Select(o => new LookupItem
                {
                    Id = o.PkidOrigen,
                    Text = o.Descripcion ?? ""
                });

            return Ok(await LookupPagingHelper.ToPagedResultAsync(query, page, pageSize, filter));
        }

        [HttpGet("GetCuentaContable")]
        public async Task<IActionResult> GetCuentaContable()
        {
            var cuentas = await _context.VwCuentas
                .Where(c => c.NivelCuenta == 7)
                .Select(c => new { PkidCuenta = c.PkIdCuenta, ClaveNombre = c.ClaveNombre })
                .Distinct()
                .ToListAsync();

            return Ok(cuentas);
        }

        [HttpGet("GetCuentaContableLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetCuentaContableLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var query = _context.VwCuentas
                .Where(c => c.NivelCuenta == 7)
                .OrderBy(c => c.ClaveNombre)
                .Select(c => new LookupItem
                {
                    Id = c.PkIdCuenta,
                    Text = c.ClaveNombre ?? ""
                });

            return Ok(await LookupPagingHelper.ToPagedResultAsync(query, page, pageSize, filter));
        }
    }
}
