using EG.Application.Interfaces.General;
using EG.Application.Interfaces.Patrimonio;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Patrimonio
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class BienController : ControllerBase
    {
        private readonly IBienAppService _appService;
        private readonly IUserContextService _userContext;
        private readonly ICatalogLookupAppService _lookups;
        private readonly IAuthorizationService _authorization;

        public BienController(
            IBienAppService appService,
            IUserContextService userContext,
            ICatalogLookupAppService lookups,
            IAuthorizationService authorization)
        {
            _appService = appService;
            _userContext = userContext;
            _lookups = lookups;
            _authorization = authorization;
        }

        [HttpGet]
        [Authorize(Policy = "Patrimonio|Bienes|view")]
        public async Task<ActionResult<PagedResult<BienResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        [Authorize(Policy = "Patrimonio|Bienes|view")]
        public async Task<ActionResult<PagedResult<BienResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpPost]
        [Authorize(Policy = "Patrimonio|Bienes|new")]
        public async Task<ActionResult<PagedResult<BienResponse>>> Create([FromBody] BienResponse response)
        {
            var result = await _appService.CreateAsync(response, _userContext.GetCurrentUserId());
            if (!result.Success)
            {
                return BadRequest(result);
            }

            var id = result.Data?.PkidBien ?? response.PkidBien;
            return CreatedAtAction(nameof(GetById), new { id }, result);
        }

        [HttpPut("{id}")]
        [Authorize(Policy = "Patrimonio|Bienes|update")]
        public async Task<ActionResult<PagedResult<BienResponse>>> Update(int id, [FromBody] BienResponse response)
        {
            var result = await _appService.UpdateAsync(id, response, _userContext.GetCurrentUserId());
            if (result.Success)
            {
                return Ok(result);
            }

            return result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
        }

        [HttpDelete("{id}")]
        [Authorize(Policy = "Patrimonio|Bienes|delete")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            var result = await _appService.DeleteAsync(id);
            if (result.Success)
            {
                return Ok(result);
            }

            return result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
        }

        [HttpPost("GetAllPaginado")]
        [Authorize(Policy = "Patrimonio|Bienes|view")]
        public async Task<ActionResult<PagedResult<BienResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpPost("generar-desde-detalle/{detalleOrdenCompraId:int}")]
        public async Task<ActionResult<PagedResult<BienResponse>>> GenerarDesdeDetalle(int detalleOrdenCompraId)
        {
            if (!await CanOperateClassificationAsync()) return Forbid();
            var result = await _appService.GenerarDesdeDetalleOrdenCompraAsync(
                detalleOrdenCompraId,
                _userContext.GetCurrentUserId());

            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("registrar-recepcion/{detalleOrdenCompraId:int}")]
        public async Task<ActionResult<PagedResult<BienResponse>>> RegistrarRecepcion(
            int detalleOrdenCompraId,
            [FromBody] RecepcionDetalleOrdenCompraRequest request)
        {
            if (!await CanOperateClassificationAsync()) return Forbid();
            var result = await _appService.RegistrarRecepcionAsync(
                detalleOrdenCompraId,
                request.CantidadRecibida,
                _userContext.GetCurrentUserId());

            return result.Success ? Ok(result) : BadRequest(result);
        }

        private async Task<bool> CanOperateClassificationAsync() =>
            (await _authorization.AuthorizeAsync(
                User,
                null,
                "Patrimonio|Clasificacion_Bienes_Muebles|update")).Succeeded;

        [HttpPost("tipos-bien-capitulo-5000")]
        [Authorize(Policy = "Patrimonio|Bienes|view")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetTiposBienCapitulo5000([FromBody] PagedRequest request)
        {
            return Ok(await _lookups.GetAsync(CatalogLookupKind.TipoBienCapitulo5000, request.Page, request.PageSize <= 0 ? 25 : request.PageSize, request.Filtro));
        }

        [HttpPost("buscar")]
        [Authorize(Policy = "Patrimonio|Bienes|view")]
        public async Task<ActionResult<PagedResult<BienResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SearchString = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };

            var result = await _appService.GetAllPaginadoAsync(pagedRequest);
            return Ok(result);
        }
    }
}
