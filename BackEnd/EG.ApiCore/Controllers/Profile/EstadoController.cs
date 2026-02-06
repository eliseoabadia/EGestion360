using EG.Business.Services;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.Profile
{
    [Route("api/[controller]")]
    [ApiController]
    //[RequiredScope(RequiredScopesConfigurationKey = "AzureAdB2C:Scopes:Read")]
    [Authorize]
    public class EstadoController(GenericService<Estado, EstadoDto> service) : ControllerBase
    {
        private readonly GenericService<Estado, EstadoDto> _service = service;

        [HttpGet]
        public async Task<ActionResult<IEnumerable<EstadoDto>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<EstadoDto>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            return result == null ? NotFound() : Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult> Add(EstadoDto dto)
        {
            await _service.AddAsync(dto);
            return CreatedAtAction(nameof(GetById), dto);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult> Update(int id, EstadoDto dto)
        {
            await _service.UpdateAsync(id, dto);
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            await _service.DeleteAsync(id);
            return NoContent();
        }
    }
}