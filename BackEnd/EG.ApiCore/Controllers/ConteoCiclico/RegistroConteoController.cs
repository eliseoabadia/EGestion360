using EG.ApiCore.Services;
using EG.Application.Interfaces.ConteoCiclico;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.ConteoCiclico
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class RegistroConteoController : ControllerBase
    {
        private readonly Logger.Log4NetLogger _logger = new Logger.Log4NetLogger(typeof(RegistroConteoController));
        private readonly IRegistroConteoAppService _appService;
        private readonly IUserContextService _userContext;

        public RegistroConteoController(
            IRegistroConteoAppService appService,
            IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        // ==================== CONSULTAS ====================

        [HttpGet]
        public async Task<ActionResult<PagedResult<RegistroConteoResponse>>> GetAll()
        {
            try
            {
                var result = await _appService.GetAllAsync();
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetAll: {ex.Message}", ex);
                return StatusCode(500, new PagedResult<RegistroConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<RegistroConteoResponse>> GetById(int id)
        {
            try
            {
                var item = await _appService.GetByIdAsync(id);
                if (item == null)
                {
                    return NotFound(new PagedResult<RegistroConteoResponse>
                    {
                        Success = false,
                        Message = "Registro no encontrado",
                        Code = "NOTFOUND",
                        TotalCount = 0
                    });
                }

                return Ok(new PagedResult<RegistroConteoResponse>
                {
                    Success = true,
                    Message = "Registro encontrado",
                    Code = "SUCCESS",
                    Data = item,
                    Items = new List<RegistroConteoResponse> { item },
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
        public async Task<ActionResult<PagedResult<RegistroConteoResponse>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
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

        [HttpGet("articulo/{articuloConteoId}")]
        public async Task<ActionResult<PagedResult<RegistroConteoResponse>>> GetByArticuloConteoId(int articuloConteoId)
        {
            try
            {
                var result = await _appService.GetByArticuloConteoIdAsync(articuloConteoId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetByArticuloConteoId: {ex.Message}", ex);
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpGet("periodo/{periodoId}")]
        public async Task<ActionResult<PagedResult<RegistroConteoResponse>>> GetByPeriodoId(int periodoId)
        {
            try
            {
                var result = await _appService.GetByPeriodoIdAsync(periodoId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetByPeriodoId: {ex.Message}", ex);
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpGet("sucursal/{sucursalId}")]
        public async Task<ActionResult<PagedResult<RegistroConteoResponse>>> GetBySucursalId(int sucursalId)
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

        [HttpGet("usuario/{usuarioId}")]
        public async Task<ActionResult<PagedResult<RegistroConteoResponse>>> GetByUsuarioId(int usuarioId)
        {
            try
            {
                var result = await _appService.GetByUsuarioIdAsync(usuarioId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetByUsuarioId: {ex.Message}", ex);
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpGet("articulo/{articuloConteoId}/ultimos")]
        public async Task<ActionResult<PagedResult<RegistroConteoResponse>>> GetUltimosConteosPorArticulo(int articuloConteoId, [FromQuery] int cantidad = 5)
        {
            try
            {
                var result = await _appService.GetUltimosConteosPorArticuloAsync(articuloConteoId, cantidad);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetUltimosConteosPorArticulo: {ex.Message}", ex);
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        // ==================== ESCRITURA ====================

        [HttpPost]
        public async Task<ActionResult<PagedResult<RegistroConteoResponse>>> Create([FromBody] RegistroConteoDto dto)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.CreateAsync(dto, usuarioActual);

                return CreatedAtAction(nameof(GetById), new { id = result.Id },
                    new PagedResult<RegistroConteoResponse>
                    {
                        Success = true,
                        Message = "Registro creado correctamente",
                        Code = "SUCCESS",
                        Data = result,
                        Items = new List<RegistroConteoResponse> { result },
                        TotalCount = 1
                    });
            }
            catch (ArgumentNullException ex)
            {
                _logger.LogError(ex.Message, ex);
                return BadRequest(new PagedResult<RegistroConteoResponse>
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
                return BadRequest(new PagedResult<RegistroConteoResponse>
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
                return Conflict(new PagedResult<RegistroConteoResponse>
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
        public async Task<ActionResult<PagedResult<RegistroConteoResponse>>> Update(int id, [FromBody] RegistroConteoDto dto)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.UpdateAsync(id, dto, usuarioActual);

                return Ok(new PagedResult<RegistroConteoResponse>
                {
                    Success = true,
                    Message = "Registro actualizado correctamente",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<RegistroConteoResponse> { result },
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
                return Ok(new { success = result, message = "Registro eliminado correctamente" });
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
    }
}