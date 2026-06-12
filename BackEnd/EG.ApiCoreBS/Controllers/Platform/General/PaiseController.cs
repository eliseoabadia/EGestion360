using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class PaiseController : ControllerBase
    {
        private readonly IPaisAppService _appService;

        public PaiseController(IPaisAppService appService)
        {
            _appService = appService;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<PaiseDto>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<PaiseDto>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            if (result == null)
                return NotFound();

            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult> Create([FromBody] PaiseDto dto)
        {
            await _appService.CreateAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = dto.PkidPais }, dto);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult> Update(int id, [FromBody] PaiseDto dto)
        {
            await _appService.UpdateAsync(id, dto);
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            await _appService.DeleteAsync(id);
            return NoContent();
        }
    }
}