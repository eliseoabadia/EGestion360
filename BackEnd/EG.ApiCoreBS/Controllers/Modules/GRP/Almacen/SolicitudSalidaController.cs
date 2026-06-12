using EG.Application.Interfaces.Almacen;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Almacen
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class SolicitudSalidaController : ControllerBase
    {
        private readonly ISolicitudSalidaAppService _appService;
        private readonly IUserContextService _userContext;

        public SolicitudSalidaController(ISolicitudSalidaAppService appService, IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<SolicitudSalidaResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<SolicitudSalidaResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<SolicitudSalidaResponse>>> Create([FromBody] SolicitudSalidaResponse response)
        {
            var result = await _appService.CreateAsync(response, _userContext.GetCurrentUserId());
            if (!result.Success)
            {
                return BadRequest(result);
            }

            var id = result.Data?.PkidSolicitudSalida ?? response.PkidSolicitudSalida;
            return CreatedAtAction(nameof(GetById), new { id }, result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<SolicitudSalidaResponse>>> Update(int id, [FromBody] SolicitudSalidaResponse response)
        {
            var result = await _appService.UpdateAsync(id, response, _userContext.GetCurrentUserId());
            if (result.Success)
            {
                return Ok(result);
            }

            return result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
        }

        [HttpPost("{id}/autorizar")]
        public async Task<ActionResult<PagedResult<SolicitudSalidaResponse>>> Autorizar(int id)
        {
            var result = await _appService.AutorizarAsync(id, _userContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            var result = await _appService.DeleteAsync(id);
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<SolicitudSalidaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<SolicitudSalidaResponse>>> Buscar([FromBody] BusquedaRequest request)
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
