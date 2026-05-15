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
    public class DetalleRequisicionController : ControllerBase
    {
        private readonly IDetalleRequisicionAppService _appService;
        private readonly IUserContextService _userContext;

        public DetalleRequisicionController(
            IDetalleRequisicionAppService appService,
            IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<DetalleRequisicionResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<DetalleRequisicionResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            if (!result.Success)
            {
                return NotFound(result);
            }

            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<DetalleRequisicionResponse>>> Create([FromBody] DetalleRequisicionResponse response)
        {
            var result = await _appService.CreateAsync(response, _userContext.GetCurrentUserId());
            if (!result.Success)
            {
                return BadRequest(result);
            }

            return CreatedAtAction(nameof(GetById), new { id = response.PkidDetalleRequisicion }, result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<DetalleRequisicionResponse>>> Update(int id, [FromBody] DetalleRequisicionResponse response)
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
        public async Task<ActionResult<PagedResult<DetalleRequisicionResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<DetalleRequisicionResponse>>> Buscar([FromBody] BusquedaRequest request)
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
