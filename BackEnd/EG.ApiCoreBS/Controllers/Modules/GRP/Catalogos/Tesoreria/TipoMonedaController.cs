using EG.Application.Interfaces.Configuracion.Catalogo.Tesoreria;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Catalogos.Tesoreria
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class TipoMonedaController : EG.ApiCoreBS.Controllers.BaseApiController
    {
        private readonly ITipoMonedaService _service;

        public TipoMonedaController(ITipoMonedaService service)
        {
            _service = service;
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<TipoMonedaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            if (result == null) return NotFound();
            return Ok(result);
        }

        [HttpPost]
        [Authorize(Policy = "Tesoreria_Tipo_Moneda_new")]
        public async Task<IActionResult> Create([FromBody] TipoMonedaDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            var response = await _service.CreateAsync(dto, GetCurrentUserId());
            return CreatedAtAction(nameof(GetById), new { id = response.PkidTipoMoneda }, response);
        }

        [HttpPut("{id}")]
        [Authorize(Policy = "Tesoreria_Tipo_Moneda_update")]
        public async Task<IActionResult> Update(int id, [FromBody] TipoMonedaDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            var response = await _service.UpdateAsync(id, dto, GetCurrentUserId());
            if (response == null) return NotFound();
            return Ok(response);
        }

        [HttpDelete("{id}")]
        [Authorize(Policy = "Tesoreria_Tipo_Moneda_delete")]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                await _service.DeleteAsync(id);
                return NoContent();
            }
            catch (KeyNotFoundException)
            {
                return NotFound();
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new { Success = false, Message = ex.Message, Code = "BUSINESS_RULE" });
            }
        }
    }
}
