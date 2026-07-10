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
    public class TipoCambioController : EG.ApiCoreBS.Controllers.BaseApiController
    {
        private readonly ITipoCambioService _service;

        public TipoCambioController(ITipoCambioService service)
        {
            _service = service;
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<TipoCambioResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            if (result == null)
            {
                return NotFound(Error("Tipo de cambio no encontrado", "NOT_FOUND"));
            }

            return Ok(Success("Tipo de cambio encontrado", result));
        }

        [HttpPost]
        [Authorize(Policy = "Tesoreria_Tipo_Cambio_new")]
        public async Task<IActionResult> Create([FromBody] TipoCambioDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            var response = await _service.CreateAsync(dto, GetCurrentUserId());
            return CreatedAtAction(nameof(GetById), new { id = response.PkidTipoCambio },
                Success("Tipo de cambio creado correctamente", response));
        }

        [HttpPut("{id}")]
        [Authorize(Policy = "Tesoreria_Tipo_Cambio_update")]
        public async Task<IActionResult> Update(int id, [FromBody] TipoCambioDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            var response = await _service.UpdateAsync(id, dto, GetCurrentUserId());
            if (response == null)
            {
                return NotFound(Error("Tipo de cambio no encontrado", "NOT_FOUND"));
            }

            return Ok(Success("Tipo de cambio actualizado correctamente", response));
        }

        [HttpDelete("{id}")]
        [Authorize(Policy = "Tesoreria_Tipo_Cambio_delete")]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                await _service.DeleteAsync(id);
                return Ok(new PagedResult<TipoCambioResponse>
                {
                    Success = true,
                    Message = "Tipo de cambio eliminado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(Error("Tipo de cambio no encontrado", "NOT_FOUND"));
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(Error(ex.Message, "BUSINESS_RULE"));
            }
        }

        private static PagedResult<TipoCambioResponse> Success(string message, TipoCambioResponse data) =>
            new()
            {
                Success = true,
                Message = message,
                Code = "SUCCESS",
                Data = data,
                Items = new List<TipoCambioResponse> { data },
                TotalCount = 1
            };

        private static PagedResult<TipoCambioResponse> Error(string message, string code = "ERROR") =>
            new()
            {
                Success = false,
                Message = message,
                Code = code,
                TotalCount = 0
            };
    }
}
