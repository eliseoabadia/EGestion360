using EG.Application.Interfaces.Configuracion.Catalogo.Almacen;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Almacen
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class MotivoEsController : EG.ApiCoreBS.Controllers.BaseApiController
    {
        private readonly IMotivoEsService _service;

        public MotivoEsController(IMotivoEsService service)
        {
            _service = service;
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<MotivoEsResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpGet]
        public async Task<IActionResult> GetAllPaginado(int page = 1, int pageSize = 10, string? sortBy = null, string? sortDirection = null, string? filter = null)
        {
            var result = await _service.GetAllPaginadoAsync(page, pageSize, sortBy, sortDirection, filter);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            if (result == null) return NotFound(Error("Motivo no encontrado", "NOT_FOUND"));
            return Ok(Success("Motivo encontrado", result));
        }

        [HttpPost]
        [Authorize(Policy = "Almacen_Movimiento_Entrada_Salida_new")]
        public async Task<IActionResult> Create([FromBody] MotivoEsDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            var response = await _service.CreateAsync(dto, GetCurrentUserId());
            return CreatedAtAction(nameof(GetById), new { id = response.PkidMotivoEs },
                Success("Motivo creado correctamente", response));
        }

        [HttpPut("{id}")]
        [Authorize(Policy = "Almacen_Movimiento_Entrada_Salida_update")]
        public async Task<IActionResult> Update(int id, [FromBody] MotivoEsDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            var response = await _service.UpdateAsync(id, dto, GetCurrentUserId());
            if (response == null) return NotFound(Error("Motivo no encontrado", "NOT_FOUND"));
            return Ok(Success("Motivo actualizado correctamente", response));
        }

        [HttpDelete("{id}")]
        [Authorize(Policy = "Almacen_Movimiento_Entrada_Salida_delete")]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                await _service.DeleteAsync(id);
                return Ok(new PagedResult<MotivoEsResponse>
                {
                    Success = true,
                    Message = "Motivo eliminado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(Error("Motivo no encontrado", "NOT_FOUND"));
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(Error(ex.Message, "BUSINESS_RULE"));
            }
        }

        private static PagedResult<MotivoEsResponse> Success(string message, MotivoEsResponse data) =>
            new()
            {
                Success = true,
                Message = message,
                Code = "SUCCESS",
                Data = data,
                Items = new List<MotivoEsResponse> { data },
                TotalCount = 1
            };

        private static PagedResult<MotivoEsResponse> Error(string message, string code = "ERROR") =>
            new()
            {
                Success = false,
                Message = message,
                Code = code,
                TotalCount = 0
            };

    }
}









