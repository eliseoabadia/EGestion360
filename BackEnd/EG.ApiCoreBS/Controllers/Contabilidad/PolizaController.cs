using EG.Application.Interfaces.Contabilidad;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Contabilidad
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class PolizaController : ControllerBase
    {
        private readonly IPolizaService _service;
        private readonly IUserContextService _userContext;

        public PolizaController(IPolizaService service, IUserContextService userContext)
        {
            _service = service;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<PolizaResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<PolizaResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<PolizaResponse>>> Create([FromBody] PolizaResponse response)
        {
            var result = await _service.CreateAsync(response, _userContext.GetCurrentUserId());
            if (!result.Success)
            {
                return BadRequest(result);
            }

            return CreatedAtAction(nameof(GetById), new { id = response.PkidPoliza }, result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<PolizaResponse>>> Update(int id, [FromBody] PolizaResponse response)
        {
            var result = await _service.UpdateAsync(id, response, _userContext.GetCurrentUserId());
            if (!result.Success)
            {
                return result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
            }

            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            var result = await _service.DeleteAsync(id, _userContext.GetCurrentUserId());
            if (!result.Success)
            {
                return result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
            }

            return Ok(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<PolizaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<PolizaResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };

            var result = await _service.GetAllPaginadoAsync(pagedRequest);
            return Ok(result);
        }
    }
}
