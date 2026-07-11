using EG.Application.Interfaces.Adquisicion;
using EG.ApiCoreBS.Helpers;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Controllers.Catalogos.Adquisicion
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ProveedorController : ControllerBase
    {
        private readonly IProveedorAppService _appService;
        private readonly IUserContextService _userContext;
        private readonly EGestionContext _context;

        public ProveedorController(
            IProveedorAppService appService,
            IUserContextService userContext,
            EGestionContext context)
        {
            _appService = appService;
            _userContext = userContext;
            _context = context;
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
            var query = _context.CuentaContables.AsNoTracking()
                .Where(x => x.Activo && x.IsCuentaDetalle == 1 && x.ClaveOrd.Replace(" ", "").StartsWith("2112"))
                .OrderBy(x => x.ClaveOrd)
                .Select(x => new LookupItem { Id = x.PkidCuentaContable, Text = x.ClaveOrd + " - " + x.Descripcion });
            return Ok(await LookupPagingHelper.ToPagedResultAsync(query, page, pageSize, filter));
        }

        [HttpGet("GetTipoProveedorLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetTipoProveedorLookupPaginado(
            int page = 1, int pageSize = 25, string? filter = null)
        {
            var query = _context.TipoProveedors.AsNoTracking().Where(x => x.Activo)
                .OrderBy(x => x.Descripcion)
                .Select(x => new LookupItem { Id = x.PkIdTipoProveedor, Text = x.Descripcion });
            return Ok(await LookupPagingHelper.ToPagedResultAsync(query, page, pageSize, filter));
        }

        [HttpGet("GetEstatusProveedorLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetEstatusProveedorLookupPaginado(
            int page = 1, int pageSize = 25, string? filter = null)
        {
            var query = _context.EstatusProveedors.AsNoTracking().Where(x => x.Activo)
                .OrderBy(x => x.Descripcion)
                .Select(x => new LookupItem { Id = x.PkidEstatusProveedor, Text = x.Descripcion });
            return Ok(await LookupPagingHelper.ToPagedResultAsync(query, page, pageSize, filter));
        }

        [HttpGet("GetPaisLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetPaisLookupPaginado(
            int page = 1, int pageSize = 25, string? filter = null)
        {
            var query = _context.Paises.AsNoTracking().Where(x => x.Activo)
                .OrderBy(x => x.Nombre)
                .Select(x => new LookupItem { Id = x.PkidPais, Text = x.Nombre });
            return Ok(await LookupPagingHelper.ToPagedResultAsync(query, page, pageSize, filter));
        }

        [HttpGet("GetEstadoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetEstadoLookupPaginado(
            int page = 1, int pageSize = 25, string? filter = null, int? paisId = null)
        {
            var query = _context.Estados.AsNoTracking()
                .Where(x => x.Activo && (!paisId.HasValue || x.FkidPaisSis == paisId.Value))
                .OrderBy(x => x.Nombre)
                .Select(x => new LookupItem { Id = x.PkidEstado, Text = x.Nombre });
            return Ok(await LookupPagingHelper.ToPagedResultAsync(query, page, pageSize, filter));
        }

        [HttpGet("GetMunicipioLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetMunicipioLookupPaginado(
            int page = 1, int pageSize = 25, string? filter = null, int? estadoId = null)
        {
            var query = _context.Municipios.AsNoTracking()
                .Where(x => x.Activo && (!estadoId.HasValue || x.FkidEstadoSis == estadoId.Value))
                .OrderBy(x => x.Nombre)
                .Select(x => new LookupItem { Id = x.PkidMunicipio, Text = x.Nombre });
            return Ok(await LookupPagingHelper.ToPagedResultAsync(query, page, pageSize, filter));
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
