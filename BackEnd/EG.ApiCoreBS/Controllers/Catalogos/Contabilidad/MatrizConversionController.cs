using AutoMapper;
using EG.ApiCoreBS.Services;
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
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;
        private readonly EGestionContext _context;

        public MatrizConversionController(
            IMatrizConversionService service,
            IMapper mapper,
            IUserContextService userContext,
            EGestionContext context)
        {
            _service = service;
            _mapper = mapper;
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
                    Message = $"No se encontró el registro con ID {id}",
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
                    Message = "Datos inválidos",
                    Code = "INVALID_MODEL",
                    TotalCount = 0
                });
            }

            var dto = _mapper.Map<MatrizConversionDto>(request);

            var existe = await _service.ExisteRegistroAsync(dto.FkidAnioSis, dto.FkidProgramaPres, dto.FkidPartidaSis);
            if (existe)
            {
                return Conflict(new PagedResult<MatrizConversionResponse>
                {
                    Success = false,
                    Message = "El Programa y Partida ya se encuentran dados de alta para el año presupuestal seleccionado",
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
                    Message = "Datos inválidos",
                    Code = "INVALID_MODEL",
                    TotalCount = 0
                });
            }

            var dto = _mapper.Map<MatrizConversionDto>(request);
            dto.PkidMatrizConversion = id;

            var existe = await _service.ExisteRegistroUpdateAsync(id, dto.FkidAnioSis, dto.FkidProgramaPres, dto.FkidPartidaSis);
            if (existe)
            {
                return Conflict(new PagedResult<MatrizConversionResponse>
                {
                    Success = false,
                    Message = "El Programa y Partida ya se encuentran dados de alta para el año presupuestal seleccionado",
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
                    Message = $"No se encontró el registro con ID {id}",
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
                Message = "Búsqueda realizada correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpGet("GetPrograma")]
        public async Task<IActionResult> GetPrograma([FromQuery] int? idAnio = null)
        {
            var programas = await _service.GetProgramasAsync(idAnio);
            return Ok(programas);
        }

        [HttpGet("GetAllProgramas")]
        public async Task<IActionResult> GetAllProgramas()
        {
            var programas = await _service.GetProgramasAsync(null);
            return Ok(programas);
        }

        [HttpGet("GetPartida")]
        public async Task<IActionResult> GetPartida()
        {
            var partidas = await _context.Set<MatrizConversion>()
                .Where(mc => mc.Activo)
                .Select(mc => new
                {
                    mc.FkidPartidaSisNavigation.PkidPartida,
                    mc.FkidPartidaSisNavigation.Descripcion
                })
                .Distinct()
                .ToListAsync();

            return Ok(partidas);
        }

        [HttpGet("GetCuentaContableAprobado")]
        public async Task<IActionResult> GetCuentaContableAprobado()
        {
            var cuentas = await _context.Set<CuentaContable>()
                .Where(c => c.ClaveOrd.StartsWith("8 2 1") && c.NivelCuenta == 7)
                .Select(c => new { PkidCuenta = c.PkidCuentaContable, ClaveNombre = c.Cuenta + " - " + c.Descripcion })
                .ToListAsync();

            return Ok(cuentas);
        }

        [HttpGet("GetCuentaContablePorEjercer")]
        public async Task<IActionResult> GetCuentaContablePorEjercer()
        {
            var cuentas = await _context.Set<CuentaContable>()
                .Where(c => c.ClaveOrd.StartsWith("8 2 2") && c.NivelCuenta == 7)
                .Select(c => new { PkidCuenta = c.PkidCuentaContable, ClaveNombre = c.Cuenta + " - " + c.Descripcion })
                .ToListAsync();

            return Ok(cuentas);
        }

        [HttpGet("GetCuentaContableModificado")]
        public async Task<IActionResult> GetCuentaContableModificado()
        {
            var cuentas = await _context.Set<CuentaContable>()
                .Where(c => c.ClaveOrd.StartsWith("8 2 3") && c.NivelCuenta == 7)
                .Select(c => new { PkidCuenta = c.PkidCuentaContable, ClaveNombre = c.Cuenta + " - " + c.Descripcion })
                .ToListAsync();

            return Ok(cuentas);
        }

        [HttpGet("GetCuentaContableComprometido")]
        public async Task<IActionResult> GetCuentaContableComprometido()
        {
            var cuentas = await _context.Set<CuentaContable>()
                .Where(c => c.ClaveOrd.StartsWith("8 2 4") && c.NivelCuenta == 7)
                .Select(c => new { PkidCuenta = c.PkidCuentaContable, ClaveNombre = c.Cuenta + " - " + c.Descripcion })
                .ToListAsync();

            return Ok(cuentas);
        }

        [HttpGet("GetCuentaContableDevengado")]
        public async Task<IActionResult> GetCuentaContableDevengado()
        {
            var cuentas = await _context.Set<CuentaContable>()
                .Where(c => c.ClaveOrd.StartsWith("8 2 5") && c.NivelCuenta == 7)
                .Select(c => new { PkidCuenta = c.PkidCuentaContable, ClaveNombre = c.Cuenta + " - " + c.Descripcion })
                .ToListAsync();

            return Ok(cuentas);
        }

        [HttpGet("GetCuentaContableEjercido")]
        public async Task<IActionResult> GetCuentaContableEjercido()
        {
            var cuentas = await _context.Set<CuentaContable>()
                .Where(c => c.ClaveOrd.StartsWith("8 2 6") && c.NivelCuenta == 7)
                .Select(c => new { PkidCuenta = c.PkidCuentaContable, ClaveNombre = c.Cuenta + " - " + c.Descripcion })
                .ToListAsync();

            return Ok(cuentas);
        }

        [HttpGet("GetCuentaContablePagado")]
        public async Task<IActionResult> GetCuentaContablePagado()
        {
            var cuentas = await _context.Set<CuentaContable>()
                .Where(c => c.ClaveOrd.StartsWith("8 2 7") && c.NivelCuenta == 7)
                .Select(c => new { PkidCuenta = c.PkidCuentaContable, ClaveNombre = c.Cuenta + " - " + c.Descripcion })
                .ToListAsync();

            return Ok(cuentas);
        }

        [HttpGet("GetCuentaContableGasto")]
        public async Task<IActionResult> GetCuentaContableGasto()
        {
            var cuentas = await _context.Set<CuentaContable>()
                .Where(c => c.ClaveOrd.StartsWith("5") && c.NivelCuenta == 7)
                .Select(c => new { PkidCuenta = c.PkidCuentaContable, ClaveNombre = c.Cuenta + " - " + c.Descripcion })
                .ToListAsync();

            return Ok(cuentas);
        }
    }
}