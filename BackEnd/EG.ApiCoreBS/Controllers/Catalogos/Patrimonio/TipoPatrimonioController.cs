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
    public class TipoPatrimonioController : ControllerBase
    {
        private readonly ITipoPatrimonioService _tipoPatrimonioService;

        public TipoPatrimonioController(ITipoPatrimonioService tipoPatrimonioService)
        {
            _tipoPatrimonioService = tipoPatrimonioService;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<TipoPatrimonioResponse>>> GetAll()
        {
            var result = await _tipoPatrimonioService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<TipoPatrimonioResponse>>> GetById(int id)
        {
            var result = await _tipoPatrimonioService.GetByIdAsync(id);
            if (!result.Success && result.Code == "NOT_FOUND")
                return NotFound(result);
            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<TipoPatrimonioResponse>>> Create([FromBody] TipoPatrimonioResponse response)
        {
            var result = await _tipoPatrimonioService.CreateAsync(response);
            if (!result.Success)
                return BadRequest(result);
            return CreatedAtAction(nameof(GetById), new { id = result.Data?.PkidTipoPatrimonio }, result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<TipoPatrimonioResponse>>> Update(int id, [FromBody] TipoPatrimonioResponse response)
        {
            var result = await _tipoPatrimonioService.UpdateAsync(id, response);
            if (!result.Success && result.Code == "NOT_FOUND")
                return NotFound(result);
            if (!result.Success)
                return BadRequest(result);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            var result = await _tipoPatrimonioService.DeleteAsync(id);
            if (!result.Success && result.Code == "NOT_FOUND")
                return NotFound(result);
            if (!result.Success)
                return BadRequest(result);
            return Ok(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<TipoPatrimonioResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _tipoPatrimonioService.GetAllPaginadoAsync(request);
            return Ok(result);
        }
    }
}
