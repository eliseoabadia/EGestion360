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
    public class RequisicionPartidaController : ControllerBase
    {
        private readonly IRequisicionPartidaAppService _appService;
        private readonly IUserContextService _userContext;

        public RequisicionPartidaController(
            IRequisicionPartidaAppService appService,
            IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        [Authorize(Policy = "Adquisiciones|Requisicion|view")]
        public async Task<ActionResult<PagedResult<RequisicionPartidaResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        [Authorize(Policy = "Adquisiciones|Requisicion|view")]
        public async Task<ActionResult<PagedResult<RequisicionPartidaResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            if (!result.Success)
            {
                return NotFound(result);
            }

            return Ok(result);
        }

        [HttpPost]
        [Authorize(Policy = "Adquisiciones|Requisicion|new")]
        public async Task<ActionResult<PagedResult<RequisicionPartidaResponse>>> Create([FromBody] RequisicionPartidaResponse response)
        {
            var result = await _appService.CreateAsync(response, _userContext.GetCurrentUserId());
            if (!result.Success)
            {
                return BadRequest(result);
            }

            return CreatedAtAction(nameof(GetById), new { id = response.PkidRequisicionPartida }, result);
        }

        [HttpPut("{id}")]
        [Authorize(Policy = "Adquisiciones|Requisicion|update")]
        public async Task<ActionResult<PagedResult<RequisicionPartidaResponse>>> Update(int id, [FromBody] RequisicionPartidaResponse response)
        {
            var result = await _appService.UpdateAsync(id, response, _userContext.GetCurrentUserId());
            if (!result.Success)
            {
                if (result.Code == "NOT_FOUND")
                {
                    return NotFound(result);
                }

                return BadRequest(result);
            }

            return Ok(result);
        }

        [HttpDelete("{id}")]
        [Authorize(Policy = "Adquisiciones|Requisicion|delete")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            var result = await _appService.DeleteAsync(id);
            if (!result.Success)
            {
                if (result.Code == "NOT_FOUND")
                {
                    return NotFound(result);
                }

                return BadRequest(result);
            }

            return Ok(result);
        }

        [HttpPost("GetAllPaginado")]
        [Authorize(Policy = "Adquisiciones|Requisicion|view")]
        public async Task<ActionResult<PagedResult<RequisicionPartidaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpPost("buscar")]
        [Authorize(Policy = "Adquisiciones|Requisicion|view")]
        public async Task<ActionResult<PagedResult<RequisicionPartidaResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };

            var result = await _appService.GetAllPaginadoAsync(pagedRequest);
            return Ok(result);
        }
    }
}
