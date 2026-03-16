using EG.ApiCore.Services;
using EG.Application.Interfaces.ConteoCiclico;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class PeriodoConteoController : ControllerBase
    {
        private readonly Logger.Log4NetLogger _logger = new Logger.Log4NetLogger(typeof(PeriodoConteoController));
        private readonly IPeriodoConteoAppService _appService;
        private readonly IUserContextService _userContext;

        public PeriodoConteoController(
            IPeriodoConteoAppService appService,
            IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        // ==================== CONSULTAS ====================

        [HttpGet]
        public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> GetAll()
        {
            try
            {
                var result = await _appService.GetAllAsync();
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetAll: {ex.Message}", ex);
                return StatusCode(500, new PagedResult<PeriodoConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PeriodoConteoResponse>> GetById(int id)
        {
            try
            {
                var item = await _appService.GetByIdAsync(id);
                if (item == null)
                {
                    return NotFound(new PagedResult<PeriodoConteoResponse>
                    {
                        Success = false,
                        Message = "Periodo no encontrado",
                        Code = "NOTFOUND",
                        TotalCount = 0
                    });
                }

                return Ok(new PagedResult<PeriodoConteoResponse>
                {
                    Success = true,
                    Message = "Periodo encontrado",
                    Code = "SUCCESS",
                    Data = item,
                    Items = new List<PeriodoConteoResponse> { item },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetById: {ex.Message}", ex);
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
        {
            try
            {
                var result = await _appService.GetAllPaginadoAsync(pageRequest);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetAllPaginado: {ex.Message}", ex);
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpGet("sucursal/{sucursalId}")]
        public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> GetBySucursalId(int sucursalId)
        {
            try
            {
                var result = await _appService.GetBySucursalIdAsync(sucursalId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetBySucursalId: {ex.Message}", ex);
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpGet("estatus/{estatusId}")]
        public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> GetByEstatusId(int estatusId)
        {
            try
            {
                var result = await _appService.GetByEstatusIdAsync(estatusId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetByEstatusId: {ex.Message}", ex);
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpGet("abiertos")]
        public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> GetPeriodosAbiertos()
        {
            try
            {
                var result = await _appService.GetPeriodosAbiertosAsync();
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetPeriodosAbiertos: {ex.Message}", ex);
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpGet("cerrados")]
        public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> GetPeriodosCerrados()
        {
            try
            {
                var result = await _appService.GetPeriodosCerradosAsync();
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetPeriodosCerrados: {ex.Message}", ex);
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        // ==================== ESCRITURA ====================

        [HttpPost]
        public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> Create([FromBody] PeriodoConteoDto dto)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.CreateAsync(dto, usuarioActual);

                return CreatedAtAction(nameof(GetById), new { id = result.Id },
                    new PagedResult<PeriodoConteoResponse>
                    {
                        Success = true,
                        Message = "Periodo creado correctamente",
                        Code = "SUCCESS",
                        Data = result,
                        Items = new List<PeriodoConteoResponse> { result },
                        TotalCount = 1
                    });
            }
            catch (ArgumentNullException ex)
            {
                _logger.LogError(ex.Message, ex);
                return BadRequest(new PagedResult<PeriodoConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "INVALID_DATA",
                    TotalCount = 0
                });
            }
            catch (ArgumentException ex)
            {
                _logger.LogError(ex.Message, ex);
                return BadRequest(new PagedResult<PeriodoConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "MISSING_REQUIRED_FIELDS",
                    TotalCount = 0
                });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogError(ex.Message, ex);
                return Conflict(new PagedResult<PeriodoConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "DUPLICATE_ENTITY",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en Create: {ex.Message}", ex);
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> Update(int id, [FromBody] PeriodoConteoDto dto)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.UpdateAsync(id, dto, usuarioActual);

                return Ok(new PagedResult<PeriodoConteoResponse>
                {
                    Success = true,
                    Message = "Periodo actualizado correctamente",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<PeriodoConteoResponse> { result },
                    TotalCount = 1
                });
            }
            catch (ArgumentNullException ex)
            {
                _logger.LogError(ex.Message, ex);
                return BadRequest(new { success = false, message = ex.Message });
            }
            catch (ArgumentException ex)
            {
                _logger.LogError(ex.Message, ex);
                return BadRequest(new { success = false, message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogError(ex.Message, ex);
                return Conflict(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, ex);
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<bool>> Delete(int id)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.DeleteAsync(id, usuarioActual);
                return Ok(new { success = result, message = "Periodo eliminado correctamente" });
            }
            catch (ArgumentException ex)
            {
                _logger.LogError(ex.Message, ex);
                return BadRequest(new { success = false, message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogError(ex.Message, ex);
                return NotFound(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, ex);
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        // ==================== ACCIONES DE NEGOCIO ====================

        [HttpPost("{id}/cerrar")]
        public async Task<ActionResult<bool>> CerrarPeriodo(int id)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.CerrarPeriodoAsync(id, usuarioActual);
                return Ok(new { success = result, message = "Periodo cerrado correctamente" });
            }
            catch (ArgumentException ex)
            {
                _logger.LogError(ex.Message, ex);
                return BadRequest(new { success = false, message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogError(ex.Message, ex);
                return Conflict(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, ex);
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpPost("{id}/reabrir")]
        public async Task<ActionResult<bool>> ReabrirPeriodo(int id)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.ReabrirPeriodoAsync(id, usuarioActual);
                return Ok(new { success = result, message = "Periodo reabierto correctamente" });
            }
            catch (ArgumentException ex)
            {
                _logger.LogError(ex.Message, ex);
                return BadRequest(new { success = false, message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogError(ex.Message, ex);
                return Conflict(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, ex);
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpPost("{id}/actualizar-estadisticas")]
        public async Task<ActionResult<bool>> ActualizarEstadisticas(int id)
        {
            try
            {
                var result = await _appService.ActualizarEstadisticasAsync(id);
                return Ok(new { success = result, message = "Estadísticas actualizadas correctamente" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, ex);
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpPatch("{id}/cambiar-estatus")]
        public async Task<ActionResult<bool>> CambiarEstatus(int id, [FromBody] int estatusId)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.CambiarEstatusAsync(id, estatusId, usuarioActual);
                return Ok(new { success = result, message = "Estatus cambiado correctamente" });
            }
            catch (ArgumentException ex)
            {
                _logger.LogError(ex.Message, ex);
                return BadRequest(new { success = false, message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogError(ex.Message, ex);
                return Conflict(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en CambiarEstatus: {ex.Message}", ex);
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpGet("mis-periodos/{usuarioId}")]
        public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> GetMisPeriodos(int usuarioId)
        {
            try
            {
                var result = await _appService.GetMisPeriodosAsync(usuarioId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetMisPeriodos: {ex.Message}", ex);
                return StatusCode(500, new PagedResult<PeriodoConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }
    }
}