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
    public class EstatusArticuloConteoController : ControllerBase
    {
        private readonly Logger.Log4NetLogger _logger = new Logger.Log4NetLogger(typeof(EstatusArticuloConteoController));
        private readonly IEstatusArticuloConteoAppService _appService;
        private readonly IUserContextService _userContext;

        public EstatusArticuloConteoController(
            IEstatusArticuloConteoAppService appService,
            IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<EstatusArticuloConteoResponse>>> GetAll()
        {
            try
            {
                var result = await _appService.GetAllAsync();
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetAll: {ex.Message}", ex);
                return StatusCode(500, new PagedResult<EstatusArticuloConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<EstatusArticuloConteoResponse>> GetById(int id)
        {
            try
            {
                var estatus = await _appService.GetByIdAsync(id);

                if (estatus == null)
                {
                    return NotFound(new PagedResult<EstatusArticuloConteoResponse>
                    {
                        Success = false,
                        Message = "Estatus no encontrado",
                        Code = "NOTFOUND",
                        TotalCount = 0
                    });
                }

                return Ok(new PagedResult<EstatusArticuloConteoResponse>
                {
                    Success = true,
                    Message = "Estatus encontrado",
                    Code = "SUCCESS",
                    Data = estatus,
                    Items = new List<EstatusArticuloConteoResponse> { estatus },
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
        public async Task<ActionResult<PagedResult<EstatusArticuloConteoResponse>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
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

        [HttpPost]
        public async Task<ActionResult<PagedResult<EstatusArticuloConteoResponse>>> Create([FromBody] EstatusArticuloConteoDto dto)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.CreateAsync(dto, usuarioActual);

                return CreatedAtAction(nameof(GetById), new { id = result.PkidEstatusArticulo },
                    new PagedResult<EstatusArticuloConteoResponse>
                    {
                        Success = true,
                        Message = "Estatus creado correctamente",
                        Code = "SUCCESS",
                        Data = result,
                        Items = new List<EstatusArticuloConteoResponse> { result },
                        TotalCount = 1
                    });
            }
            catch (ArgumentNullException ex)
            {
                _logger.LogError(ex.Message, ex);
                return BadRequest(new PagedResult<EstatusArticuloConteoResponse>
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
                return BadRequest(new PagedResult<EstatusArticuloConteoResponse>
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
                return Conflict(new PagedResult<EstatusArticuloConteoResponse>
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
        public async Task<ActionResult<PagedResult<EstatusArticuloConteoResponse>>> Update(int id, [FromBody] EstatusArticuloConteoDto dto)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.UpdateAsync(id, dto, usuarioActual);

                return Ok(new PagedResult<EstatusArticuloConteoResponse>
                {
                    Success = true,
                    Message = "Estatus actualizado correctamente",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<EstatusArticuloConteoResponse> { result },
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
                return Ok(new { success = result, message = "Estatus eliminado correctamente" });
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