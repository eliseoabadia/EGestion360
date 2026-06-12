using EG.Application.Interfaces.Patrimonio;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Patrimonio
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class TipoAdquisicionController : ControllerBase
    {
        private readonly ITipoAdquisicionService _tipoAdquisicionService;

        public TipoAdquisicionController(ITipoAdquisicionService tipoAdquisicionService)
        {
            _tipoAdquisicionService = tipoAdquisicionService;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<TipoAdquisicionResponse>>> GetAll()
        {
            var result = await _tipoAdquisicionService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<TipoAdquisicionResponse>>> GetById(int id)
        {
            var result = await _tipoAdquisicionService.GetByIdAsync(id);
            if (!result.Success && result.Code == "NOT_FOUND")
                return NotFound(result);
            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<TipoAdquisicionResponse>>> Create([FromBody] TipoAdquisicionResponse response)
        {
            var result = await _tipoAdquisicionService.CreateAsync(response);
            if (!result.Success)
                return BadRequest(result);
            return CreatedAtAction(nameof(GetById), new { id = result.Data?.PkidTipoAdq }, result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<TipoAdquisicionResponse>>> Update(int id, [FromBody] TipoAdquisicionResponse response)
        {
            var result = await _tipoAdquisicionService.UpdateAsync(id, response);
            if (!result.Success && result.Code == "NOT_FOUND")
                return NotFound(result);
            if (!result.Success)
                return BadRequest(result);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            var result = await _tipoAdquisicionService.DeleteAsync(id);
            if (!result.Success && result.Code == "NOT_FOUND")
                return NotFound(result);
            if (!result.Success)
                return BadRequest(result);
            return Ok(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<TipoAdquisicionResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _tipoAdquisicionService.GetAllPaginadoAsync(request);
            return Ok(result);
        }
    }
}
