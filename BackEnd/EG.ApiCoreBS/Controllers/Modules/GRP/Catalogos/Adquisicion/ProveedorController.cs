using EG.Application.Interfaces.General;
using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Catalogos.Adquisicion
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ProveedorController : ControllerBase
    {
        private readonly IProveedorAppService _appService;
        private readonly IUserContextService _userContext;
        private readonly ICatalogLookupAppService _lookups;

        public ProveedorController(
            IProveedorAppService appService,
            IUserContextService userContext,
            ICatalogLookupAppService lookups)
        {
            _appService = appService;
            _userContext = userContext;
            _lookups = lookups;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<ProveedorResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<ProveedorResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            if (!result.Success)
                return NotFound(result);
            return Ok(result);
        }

        [HttpPost]
        [Authorize(Policy = "Adquisiciones|Proveedores|new")]
        public async Task<ActionResult<PagedResult<ProveedorResponse>>> Create([FromBody] ProveedorResponse response)
        {
            var result = await _appService.CreateAsync(response, _userContext.GetCurrentUserId());
            if (!result.Success)
            {
                if (result.Code == "DUPLICATE")
                    return Conflict(result);
                return BadRequest(result);
            }
            return CreatedAtAction(nameof(GetById), new { id = 0 }, result);
        }

        [HttpPut("{id}")]
        [Authorize(Policy = "Adquisiciones|Proveedores|update")]
        public async Task<ActionResult<PagedResult<ProveedorResponse>>> Update(int id, [FromBody] ProveedorResponse response)
        {
            var result = await _appService.UpdateAsync(id, response, _userContext.GetCurrentUserId());
            if (!result.Success)
            {
                if (result.Code == "DUPLICATE")
                    return Conflict(result);
                if (result.Code == "NOT_FOUND")
                    return NotFound(result);
                return BadRequest(result);
            }
            return Ok(result);
        }

        [HttpDelete("{id}")]
        [Authorize(Policy = "Adquisiciones|Proveedores|delete")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            var result = await _appService.DeleteAsync(id, _userContext.GetCurrentUserId());
            if (!result.Success)
            {
                if (result.Code == "NOT_FOUND")
                    return NotFound(result);
                return BadRequest(result);
            }
            return Ok(result);
        }

        [HttpGet("GetCuentaAuxiliarLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetCuentaAuxiliarLookupPaginado(
            int page = 1, int pageSize = 25, string? filter = null)
        {
            return Ok(await _lookups.GetAsync(CatalogLookupKind.CuentaAuxiliarProveedor, page, pageSize, filter));
        }

        [HttpGet("GetTipoProveedorLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetTipoProveedorLookupPaginado(
            int page = 1, int pageSize = 25, string? filter = null)
        {
            return Ok(await _lookups.GetAsync(CatalogLookupKind.TipoProveedor, page, pageSize, filter));
        }

        [HttpGet("GetEstatusProveedorLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetEstatusProveedorLookupPaginado(
            int page = 1, int pageSize = 25, string? filter = null)
        {
            return Ok(await _lookups.GetAsync(CatalogLookupKind.EstatusProveedor, page, pageSize, filter));
        }

        [HttpGet("GetPaisLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetPaisLookupPaginado(
            int page = 1, int pageSize = 25, string? filter = null)
        {
            return Ok(await _lookups.GetAsync(CatalogLookupKind.Pais, page, pageSize, filter));
        }

        [HttpGet("GetEstadoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetEstadoLookupPaginado(
            int page = 1, int pageSize = 25, string? filter = null, int? paisId = null)
        {
            return Ok(await _lookups.GetAsync(CatalogLookupKind.Estado, page, pageSize, filter, paisId));
        }

        [HttpGet("GetMunicipioLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetMunicipioLookupPaginado(
            int page = 1, int pageSize = 25, string? filter = null, int? estadoId = null)
        {
            return Ok(await _lookups.GetAsync(CatalogLookupKind.Municipio, page, pageSize, filter, estadoId));
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<ProveedorResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<ProveedorResponse>>> Buscar([FromBody] BusquedaRequest request)
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
    }
}
