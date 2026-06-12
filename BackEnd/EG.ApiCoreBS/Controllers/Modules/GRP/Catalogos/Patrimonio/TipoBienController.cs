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
    public class TipoBienController : ControllerBase
    {
        private readonly ITipoBienService _tipoBienService;

        public TipoBienController(ITipoBienService tipoBienService)
        {
            _tipoBienService = tipoBienService;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<TipoBienResponse>>> GetAll()
        {
            var result = await _tipoBienService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<TipoBienResponse>>> GetById(int id)
        {
            var result = await _tipoBienService.GetByIdAsync(id);
            if (!result.Success && result.Code == "NOT_FOUND")
                return NotFound(result);
            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<TipoBienResponse>>> Create([FromBody] TipoBienResponse response)
        {
            var result = await _tipoBienService.CreateAsync(response);
            if (!result.Success)
                return BadRequest(result);
            return CreatedAtAction(nameof(GetById), new { id = result.Data?.PkidTipoBien }, result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<TipoBienResponse>>> Update(int id, [FromBody] TipoBienResponse response)
        {
            var result = await _tipoBienService.UpdateAsync(id, response);
            if (!result.Success && result.Code == "NOT_FOUND")
                return NotFound(result);
            if (!result.Success)
                return BadRequest(result);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            var result = await _tipoBienService.DeleteAsync(id);
            if (!result.Success && result.Code == "NOT_FOUND")
                return NotFound(result);
            if (!result.Success)
                return BadRequest(result);
            return Ok(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<TipoBienResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _tipoBienService.GetAllPaginadoAsync(request);
            return Ok(result);
        }
    }
}
