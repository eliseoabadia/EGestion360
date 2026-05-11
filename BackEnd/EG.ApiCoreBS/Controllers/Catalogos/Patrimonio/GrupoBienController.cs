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
    public class GrupoBienController : ControllerBase
    {
        private readonly IGrupoBienService _grupoBienService;

        public GrupoBienController(IGrupoBienService grupoBienService)
        {
            _grupoBienService = grupoBienService;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> GetAll()
        {
            var result = await _grupoBienService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> GetById(int id)
        {
            var result = await _grupoBienService.GetByIdAsync(id);
            if (!result.Success && result.Code == "NOT_FOUND")
                return NotFound(result);
            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> Create([FromBody] GrupoBienResponse response)
        {
            var result = await _grupoBienService.CreateAsync(response);
            if (!result.Success && result.Code == "DUPLICATE")
                return Conflict(result);
            if (!result.Success)
                return BadRequest(result);
            return CreatedAtAction(nameof(GetById), new { id = result.Data?.PkidGrupoBien }, result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> Update(int id, [FromBody] GrupoBienResponse response)
        {
            var result = await _grupoBienService.UpdateAsync(id, response);
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
            var result = await _grupoBienService.DeleteAsync(id);
            if (!result.Success && result.Code == "NOT_FOUND")
                return NotFound(result);
            if (!result.Success)
                return BadRequest(result);
            return Ok(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _grupoBienService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpGet("GetGrupoBien")]
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> GetGrupoBien()
        {
            var result = await _grupoBienService.GetGrupoBienAsync();
            return Ok(result);
        }

        [HttpGet("GetLookup")]
        public async Task<ActionResult<List<LookupItem>>> GetLookup()
        {
            var result = await _grupoBienService.GetLookupAsync();
            return Ok(result);
        }

        [HttpGet("GetLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var result = await _grupoBienService.GetLookupPaginadoAsync(page, pageSize, filter);
            return Ok(result);
        }
    }
}
