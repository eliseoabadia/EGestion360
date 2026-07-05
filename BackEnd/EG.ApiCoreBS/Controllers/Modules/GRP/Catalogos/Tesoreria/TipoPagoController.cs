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
    public class TipoPagoController : EG.ApiCoreBS.Controllers.BaseApiController
    {
        private readonly ITipoPagoService _service;

        public TipoPagoController(ITipoPagoService service)
        {
            _service = service;
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<TipoPagoResponse>>> GetAllPaginado([FromBody] PagedRequest request)
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
        [Authorize(Policy = "Tesoreria_Tipo_Pago_new")]
        public async Task<IActionResult> Create([FromBody] TipoPagoDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            var response = await _service.CreateAsync(dto, GetCurrentUserId());
            return CreatedAtAction(nameof(GetById), new { id = response.PkidTipoPago }, response);
        }

        [HttpPut("{id}")]
        [Authorize(Policy = "Tesoreria_Tipo_Pago_update")]
        public async Task<IActionResult> Update(int id, [FromBody] TipoPagoDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            var response = await _service.UpdateAsync(id, dto, GetCurrentUserId());
            if (response == null) return NotFound();
            return Ok(response);
        }

        [HttpDelete("{id}")]
        [Authorize(Policy = "Tesoreria_Tipo_Pago_delete")]
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
