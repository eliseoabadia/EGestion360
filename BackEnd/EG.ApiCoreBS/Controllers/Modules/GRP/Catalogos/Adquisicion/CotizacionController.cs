using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
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
    public class CotizacionController : ControllerBase
    {
        private readonly ICotizacionAppService _appService;
        private readonly IUserContextService _userContext;

        public CotizacionController(
            ICotizacionAppService appService,
            IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<CotizacionResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<CotizacionResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<CotizacionResponse>>> Create([FromBody] CotizacionResponse response)
        {
            var result = await _appService.CreateAsync(response, _userContext.GetCurrentUserId());
            return result.Success
                ? CreatedAtAction(nameof(GetById), new { id = response.PkidCotizacion }, result)
                : BadRequest(result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<CotizacionResponse>>> Update(int id, [FromBody] CotizacionResponse response)
        {
            var result = await _appService.UpdateAsync(id, response, _userContext.GetCurrentUserId());
            if (result.Success)
            {
                return Ok(result);
            }

            return result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
        }

        [HttpDelete("{id}")]
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
        public async Task<ActionResult<PagedResult<CotizacionResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpPost("{id}/enviar-correo")]
        public async Task<ActionResult<PagedResult<CotizacionResponse>>> SendCotizacionEmail(int id)
        {
            var result = await _appService.SendCotizacionEmailAsync(id, _userContext.GetCurrentUserId());
            return result.Success
                ? Ok(result)
                : result.Code == "ALREADY_SENT" ? Conflict(result) : BadRequest(result);
        }

        [HttpPost("{id}/rechazar-envio")]
        public async Task<ActionResult<PagedResult<CotizacionResponse>>> RejectCotizacionEmail(
            int id,
            [FromBody] string? motivo = null)
        {
            var result = await _appService.RejectCotizacionEmailAsync(
                id,
                _userContext.GetCurrentUserId(),
                motivo);
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpGet("recepcion/{cotizacionId}")]
        public async Task<ActionResult<PagedResult<CotizacionDetalleResponse>>> GetRecepcionCotizacion(int cotizacionId)
        {
            var result = await _appService.GetRecepcionCotizacionAsync(cotizacionId);
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("recepcion")]
        public async Task<ActionResult<PagedResult<CotizacionDetalleResponse>>> SaveRecepcionCotizacion([FromBody] CotizacionRecepcionRequest request)
        {
            var result = await _appService.SaveRecepcionCotizacionAsync(request, _userContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<CotizacionResponse>>> Buscar([FromBody] BusquedaRequest request)
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
