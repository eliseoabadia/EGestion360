using EG.Application.Interfaces.General;
using Mapster;
using EG.ApiCoreBS.Services;
using EG.Domain.Interfaces;
using EG.Application.Interfaces.Contabilidad;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Contabilidad;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Catalogos.Contabilidad
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class MatrizConversionController : ControllerBase
    {
        private readonly IMatrizConversionService _service;
        private readonly IUserContextService _userContext;
        private readonly ICatalogLookupAppService _lookups;
        private readonly IMatrizConversionValidationService _validation;

        public MatrizConversionController(
            IMatrizConversionService service,
            IUserContextService userContext,
            ICatalogLookupAppService lookups,
            IMatrizConversionValidationService validation)
        {
            _service = service;
            _userContext = userContext;
            _lookups = lookups;
            _validation = validation;
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
        [Authorize(Policy = "Contabilidad|Matriz_Conversion|new")]
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

            var dto = request.Adapt<MatrizConversionDto>();

            var validationMessage = await ValidateAccountingRulesAsync(request);
            if (validationMessage != null)
            {
                return BadRequest(ValidationFailure(validationMessage));
            }

            var existe = await _service.ExisteRegistroAsync(dto.FkidAnioSis, dto.FkidProgramaPres, dto.FkidPartidaSis, dto.FkidTipoGastoPres);
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
        [Authorize(Policy = "Contabilidad|Matriz_Conversion|update")]
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

            var dto = request.Adapt<MatrizConversionDto>();
            dto.PkidMatrizConversion = id;

            var validationMessage = await ValidateAccountingRulesAsync(request);
            if (validationMessage != null)
            {
                return BadRequest(ValidationFailure(validationMessage));
            }

            var existe = await _service.ExisteRegistroUpdateAsync(id, dto.FkidAnioSis, dto.FkidProgramaPres, dto.FkidPartidaSis, dto.FkidTipoGastoPres);
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
        [Authorize(Policy = "Contabilidad|Matriz_Conversion|delete")]
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
            catch (InvalidOperationException ex)
            {
                return Conflict(new PagedResult<MatrizConversionResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "BUSINESS_RULE",
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
            var items = await _lookups.GetLegacyAsync(CatalogLookupKind.Programa, idAnio);
            return Ok(items.Select(item => new { PkidCuenta = item.Id, ClaveNombre = item.Text }));
        }

        [HttpGet("GetAllProgramas")]
        public async Task<IActionResult> GetAllProgramas()
        {
            var items = await _lookups.GetLegacyAsync(CatalogLookupKind.Programa);
            return Ok(items.Select(item => new { PkidCuenta = item.Id, ClaveNombre = item.Text }));
        }

        [HttpGet("GetAllProgramasLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetAllProgramasLookupPaginado(int page = 1, int pageSize = 25, string? filter = null, int? idAnio = null)
        {
            return Ok(await _lookups.GetAsync(CatalogLookupKind.Programa, page, pageSize, filter, idAnio));
        }

        [HttpGet("GetPartida")]
        public async Task<IActionResult> GetPartida()
        {
            var items = await _lookups.GetLegacyAsync(CatalogLookupKind.Partida);
            return Ok(items.Select(item => new { PkidCuenta = item.Id, ClaveNombre = item.Text }));
        }

        [HttpGet("GetPartidaLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetPartidaLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            return Ok(await _lookups.GetAsync(CatalogLookupKind.Partida, page, pageSize, filter));
        }

        [HttpGet("GetTipoGastoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetTipoGastoLookupPaginado(
            int page = 1, int pageSize = 25, string? filter = null)
        {
            return Ok(await _lookups.GetAsync(CatalogLookupKind.TipoGasto, page, pageSize, filter));
        }

        [HttpGet("GetCuentaContableAprobado")]
        public async Task<IActionResult> GetCuentaContableAprobado()
        {
            var items = await _lookups.GetLegacyAsync(CatalogLookupKind.CuentaAprobado);
            return Ok(items.Select(item => new { PkIdCuenta = item.Id, ClaveNombre = item.Text }));
        }

        [HttpGet("GetCuentaContableAprobadoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetCuentaContableAprobadoLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            return Ok(await _lookups.GetAsync(CatalogLookupKind.CuentaAprobado, page, pageSize, filter));
        }

        [HttpGet("GetCuentaContablePorEjercer")]
        public async Task<IActionResult> GetCuentaContablePorEjercer()
        {
            var items = await _lookups.GetLegacyAsync(CatalogLookupKind.CuentaPorEjercer);
            return Ok(items.Select(item => new { PkIdCuenta = item.Id, ClaveNombre = item.Text }));
        }

        [HttpGet("GetCuentaContablePorEjercerLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetCuentaContablePorEjercerLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            return Ok(await _lookups.GetAsync(CatalogLookupKind.CuentaPorEjercer, page, pageSize, filter));
        }

        [HttpGet("GetCuentaContableModificado")]
        public async Task<IActionResult> GetCuentaContableModificado()
        {
            var items = await _lookups.GetLegacyAsync(CatalogLookupKind.CuentaModificado);
            return Ok(items.Select(item => new { PkIdCuenta = item.Id, ClaveNombre = item.Text }));
        }

        [HttpGet("GetCuentaContableModificadoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetCuentaContableModificadoLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            return Ok(await _lookups.GetAsync(CatalogLookupKind.CuentaModificado, page, pageSize, filter));
        }

        [HttpGet("GetCuentaContableComprometido")]
        public async Task<IActionResult> GetCuentaContableComprometido()
        {
            var items = await _lookups.GetLegacyAsync(CatalogLookupKind.CuentaComprometido);
            return Ok(items.Select(item => new { PkIdCuenta = item.Id, ClaveNombre = item.Text }));
        }

        [HttpGet("GetCuentaContableComprometidoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetCuentaContableComprometidoLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            return Ok(await _lookups.GetAsync(CatalogLookupKind.CuentaComprometido, page, pageSize, filter));
        }

        [HttpGet("GetCuentaContableDevengado")]
        public async Task<IActionResult> GetCuentaContableDevengado()
        {
            var items = await _lookups.GetLegacyAsync(CatalogLookupKind.CuentaDevengado);
            return Ok(items.Select(item => new { PkIdCuenta = item.Id, ClaveNombre = item.Text }));
        }

        [HttpGet("GetCuentaContableDevengadoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetCuentaContableDevengadoLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            return Ok(await _lookups.GetAsync(CatalogLookupKind.CuentaDevengado, page, pageSize, filter));
        }

        [HttpGet("GetCuentaContableEjercido")]
        public async Task<IActionResult> GetCuentaContableEjercido()
        {
            var items = await _lookups.GetLegacyAsync(CatalogLookupKind.CuentaEjercido);
            return Ok(items.Select(item => new { PkIdCuenta = item.Id, ClaveNombre = item.Text }));
        }

        [HttpGet("GetCuentaContableEjercidoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetCuentaContableEjercidoLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            return Ok(await _lookups.GetAsync(CatalogLookupKind.CuentaEjercido, page, pageSize, filter));
        }

        [HttpGet("GetCuentaContablePagado")]
        public async Task<IActionResult> GetCuentaContablePagado()
        {
            var items = await _lookups.GetLegacyAsync(CatalogLookupKind.CuentaPagado);
            return Ok(items.Select(item => new { PkIdCuenta = item.Id, ClaveNombre = item.Text }));
        }

        [HttpGet("GetCuentaContablePagadoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetCuentaContablePagadoLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            return Ok(await _lookups.GetAsync(CatalogLookupKind.CuentaPagado, page, pageSize, filter));
        }

        [HttpGet("GetCuentaContableGasto")]
        public async Task<IActionResult> GetCuentaContableGasto()
        {
            var items = await _lookups.GetLegacyAsync(CatalogLookupKind.CuentaGasto);
            return Ok(items.Select(item => new { PkIdCuenta = item.Id, ClaveNombre = item.Text }));
        }

        [HttpGet("GetCuentaContableGastoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetCuentaContableGastoLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            return Ok(await _lookups.GetAsync(CatalogLookupKind.CuentaGasto, page, pageSize, filter));
        }

        private async Task<string?> ValidateAccountingRulesAsync(MatrizConversionResponse request)
        {
            return await _validation.ValidateAsync(request);
        }

        private static PagedResult<MatrizConversionResponse> ValidationFailure(string message) => new()
        {
            Success = false,
            Message = message,
            Code = "BUSINESS_RULE",
            TotalCount = 0
        };
    }
}
