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
    public class PartidaController : ControllerBase
    {
        private readonly IPartidaService _partidaService;

        public PartidaController(IPartidaService partidaService)
        {
            _partidaService = partidaService;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<PartidaResponse>>> GetAll()
        {
            var result = await _partidaService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<PartidaResponse>>> GetById(int id)
        {
            var result = await _partidaService.GetByIdAsync(id);
            if (!result.Success && result.Code == "NOT_FOUND")
                return NotFound(result);
            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<PartidaResponse>>> Create([FromBody] PartidaResponse response)
        {
            var result = await _partidaService.CreateAsync(response);
            if (!result.Success && result.Code == "DUPLICATE")
                return Conflict(result);
            if (!result.Success)
                return BadRequest(result);
            return CreatedAtAction(nameof(GetById), new { id = result.Data?.PkidPartida }, result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<PartidaResponse>>> Update(int id, [FromBody] PartidaResponse response)
        {
            var result = await _partidaService.UpdateAsync(id, response);
            if (!result.Success && result.Code == "NOT_FOUND")
                return NotFound(result);
            if (!result.Success && result.Code == "DUPLICATE")
                return Conflict(result);
            if (!result.Success)
                return BadRequest(result);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            var result = await _partidaService.DeleteAsync(id);
            if (!result.Success && result.Code == "NOT_FOUND")
                return NotFound(result);
            if (!result.Success)
                return BadRequest(result);
            return Ok(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<PartidaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _partidaService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpGet("GetLookup")]
        public async Task<ActionResult<List<LookupItem>>> GetLookup()
        {
            var result = await _partidaService.GetLookupAsync();
            return Ok(result);
        }

        [HttpGet("GetLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var result = await _partidaService.GetLookupPaginadoAsync(page, pageSize, filter);
            return Ok(result);
        }
    }
}
