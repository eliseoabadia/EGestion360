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
    public class SolicitudSuficienciaController : ControllerBase
    {
        private readonly ISolicitudSuficienciaAppService _appService;
        private readonly IUserContextService _userContext;

        public SolicitudSuficienciaController(
            ISolicitudSuficienciaAppService appService,
            IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<SolicitudSuficienciaResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<SolicitudSuficienciaResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<SolicitudSuficienciaResponse>>> Create([FromBody] SolicitudSuficienciaResponse response)
        {
            var result = await _appService.CreateAsync(response, _userContext.GetCurrentUserId());
            return result.Success
                ? CreatedAtAction(nameof(GetById), new { id = response.PkidSolicitudSuficiencia }, result)
                : BadRequest(result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<SolicitudSuficienciaResponse>>> Update(int id, [FromBody] SolicitudSuficienciaResponse response)
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
        public async Task<ActionResult<PagedResult<SolicitudSuficienciaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpPost("generar-desde-requisicion")]
        public async Task<ActionResult<PagedResult<SolicitudSuficienciaResponse>>> GenerarDesdeRequisicion(
            [FromBody] SolicitudSuficienciaGenerarRequest request)
        {
            var result = await _appService.GenerarDesdeRequisicionAsync(request, _userContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<SolicitudSuficienciaResponse>>> Buscar([FromBody] BusquedaRequest request)
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
