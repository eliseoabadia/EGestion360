using EG.ApiCore.Services;
using EG.Application.Interfaces.ConteoCiclico;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.ConteoCiclico
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ArticuloConteoController : ControllerBase
    {
        private readonly Logger.Log4NetLogger _logger = new Logger.Log4NetLogger(typeof(ArticuloConteoController));
        private readonly IArticuloConteoAppService _appService;
        private readonly IUserContextService _userContext;

        public ArticuloConteoController(
            IArticuloConteoAppService appService,
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
                        Message = "Artículo no encontrado",
                        Code = "NOTFOUND",
                        TotalCount = 0
                    });
                }

                return Ok(new PagedResult<PeriodoConteoResponse>
                {
                    Success = true,
                    Message = "Artículo encontrado",
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

        [HttpGet("periodo/{periodoId}")]
        public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> GetByPeriodoId(int periodoId)
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

        [HttpGet("pendientes")]
        public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> GetPendientes([FromQuery] int periodoId, [FromQuery] int sucursalId)
        {
            try
            {
                var result = await _appService.GetPendientesAsync(periodoId, sucursalId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetPendientes: {ex.Message}", ex);
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpGet("concluidos")]
        public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> GetConcluidos([FromQuery] int periodoId, [FromQuery] int sucursalId)
        {
            try
            {
                var result = await _appService.GetConcluidosAsync(periodoId, sucursalId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetConcluidos: {ex.Message}", ex);
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        // ==================== ESCRITURA ====================

        [HttpPost]
        public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> Create([FromBody] ArticuloConteoDto dto)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.CreateAsync(dto, usuarioActual);

                return CreatedAtAction(nameof(GetById), new { id = result.Id },
                    new PagedResult<PeriodoConteoResponse>
                    {
                        Success = true,
                        Message = "Artículo creado correctamente",
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
        public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> Update(int id, [FromBody] ArticuloConteoDto dto)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.UpdateAsync(id, dto, usuarioActual);

                return Ok(new PagedResult<PeriodoConteoResponse>
                {
                    Success = true,
                    Message = "Artículo actualizado correctamente",
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
                return Ok(new { success = result, message = "Artículo eliminado correctamente" });
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

        [HttpPost("{id}/iniciar")]
        public async Task<ActionResult<bool>> IniciarConteo(int id)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.IniciarConteoAsync(id, usuarioActual);
                return Ok(new { success = result, message = "Conteo iniciado correctamente" });
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

        [HttpPost("{id}/concluir")]
        public async Task<ActionResult<bool>> ConcluirConteo(int id, [FromBody] decimal existenciaFinal)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.ConcluirConteoAsync(id, existenciaFinal, usuarioActual);
                return Ok(new { success = result, message = "Conteo concluido correctamente" });
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
    }
}