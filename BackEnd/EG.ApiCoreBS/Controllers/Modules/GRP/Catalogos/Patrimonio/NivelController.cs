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
    public class NivelController : ControllerBase
    {
        private readonly INivelService _nivelService;

        public NivelController(INivelService nivelService)
        {
            _nivelService = nivelService;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<NivelResponse>>> GetAll()
        {
            var result = await _nivelService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<NivelResponse>>> GetById(int id)
        {
            var result = await _nivelService.GetByIdAsync(id);
            if (!result.Success && result.Code == "NOT_FOUND")
                return NotFound(result);
            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<NivelResponse>>> Create([FromBody] NivelResponse response)
        {
            var result = await _nivelService.CreateAsync(response);
            if (!result.Success && result.Code == "DUPLICATE")
                return Conflict(result);
            if (!result.Success)
                return BadRequest(result);
            return CreatedAtAction(nameof(GetById), new { id = result.Data?.PkidNivel }, result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<NivelResponse>>> Update(int id, [FromBody] NivelResponse response)
        {
            var result = await _nivelService.UpdateAsync(id, response);
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
            var result = await _nivelService.DeleteAsync(id);
            if (!result.Success && result.Code == "NOT_FOUND")
                return NotFound(result);
            if (!result.Success)
                return BadRequest(result);
            return Ok(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<NivelResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _nivelService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpGet("GetLookup")]
        public async Task<ActionResult<List<LookupItem>>> GetLookup()
        {
            var result = await _nivelService.GetLookupAsync();
            return Ok(result);
        }

        [HttpGet("GetLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var result = await _nivelService.GetLookupPaginadoAsync(page, pageSize, filter);
            return Ok(result);
        }
    }
}
