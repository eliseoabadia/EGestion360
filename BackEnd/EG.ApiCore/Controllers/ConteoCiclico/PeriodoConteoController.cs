using EG.Application.Interfaces.ConteoCiclico;
using EG.ApiCore.Services;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using EG.Common.GenericModel;

namespace EG.ApiCore.Controllers.ConteoCiclico
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class PeriodoConteoController : ControllerBase
    {
        private readonly IPeriodoConteoAppService _appService;
        private readonly IUserContextService _userContext;

        public PeriodoConteoController(
            IPeriodoConteoAppService appService,
            IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        // ✅ CONTROLADOR LIMPIO: SOLO COORDINA Y MANEJA ERRORES HTTP

        [HttpGet]
        public async Task<ActionResult> GetAll()
        {
            try
            {
                var result = await _appService.GetAllAsync();
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult> GetById(int id)
        {
            try
            {
                var result = await _appService.GetByIdAsync(id);
                return Ok(new { success = true, data = result, items = new[] { result }, totalCount = 1 });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult> GetAllPaginado([FromBody] PagedRequest request)
        {
            try
            {
                var result = await _appService.GetAllPaginadoAsync(request);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpPost]
        public async Task<ActionResult> Add([FromBody] PeriodoConteoDto dto)
        {
            try
            {
                if (dto == null)
                    return BadRequest(new { success = false, message = "Datos requeridos" });

                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.CreateAsync(dto, usuarioActual);

                return CreatedAtAction(nameof(GetById), new { id = result.Id }, new { success = true, data = result });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { success = false, message = ex.Message, code = "INVALID_DATA" });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new { success = false, message = ex.Message, code = "VALIDATION_ERROR" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult> Update(int id, [FromBody] PeriodoConteoDto dto)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.UpdateAsync(id, dto, usuarioActual);
                return Ok(new { success = true, data = result });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            try
            {
                await _appService.DeleteAsync(id);
                return Ok(new { success = true, message = "Eliminado correctamente" });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { success = false, message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpPatch("{id}/cambiar-estatus")]
        public async Task<ActionResult> CambiarEstatus(int id, [FromBody] int estatusId)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                await _appService.CambiarEstatusAsync(id, estatusId, usuarioActual);
                return Ok(new { success = true, message = "Estatus actualizado" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpPatch("{id}/cerrar")]
        public async Task<ActionResult> CerrarPeriodo(int id)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                await _appService.CerrarPeriodoAsync(id, usuarioActual);
                return Ok(new { success = true, message = "Período cerrado" });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }
    }
}