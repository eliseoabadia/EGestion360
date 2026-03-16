using EG.ApiCore.Services;
using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Dommain.DTOs.Responses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class UsuarioController : ControllerBase
    {
        private readonly Logger.Log4NetLogger _logger = new Logger.Log4NetLogger(typeof(UsuarioController));
        private readonly IUsuarioAppService _appService;
        private readonly IUserContextService _userContext;

        public UsuarioController(
            IUsuarioAppService appService,
            IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<UsuarioResponse>>> GetAll()
        {
            try
            {
                var result = await _appService.GetAllAsync();
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetAll: {ex.Message}", ex);
                return StatusCode(500, new PagedResult<UsuarioResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    ////Items = new(),
                    TotalCount = 0
                });
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<UsuarioResponse>> GetById(int id)
        {
            try
            {
                var usuario = await _appService.GetByIdAsync(id);

                if (usuario == null)
                {
                    return NotFound(new PagedResult<UsuarioResponse>
                    {
                        Success = false,
                        Message = "Usuario no encontrado",
                        Code = "NOTFOUND_USER",
                        ////Items = new(),
                        TotalCount = 0
                    });
                }

                return Ok(new PagedResult<UsuarioResponse>
                {
                    Success = true,
                    Message = "Usuario encontrado",
                    Code = "SUCCESS",
                    Data = usuario,
                    Items = new List<UsuarioResponse> { usuario },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetById: {ex.Message}", ex);
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpGet("empresa/{empresaId}")]
        public async Task<ActionResult<PagedResult<UsuarioResponse>>> GetByEmpresaId(int empresaId)
        {
            try
            {
                var result = await _appService.GetByEmpresaIdAsync(empresaId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetByEmpresaId: {ex.Message}", ex);
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<UsuarioResponse>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
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
        public async Task<ActionResult<PagedResult<UsuarioResponse>>> Create([FromBody] UsuarioDto dto)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.CreateAsync(dto, usuarioActual);

                return CreatedAtAction(nameof(GetById), new { id = result.PkIdUsuario },
                    new PagedResult<UsuarioResponse>
                    {
                        Success = true,
                        Message = "Usuario creado correctamente",
                        Code = "SUCCESS",
                        Data = result,
                        Items = new List<UsuarioResponse> { result },
                        TotalCount = 1
                    });
            }
            catch (ArgumentNullException ex)
            {
                _logger.LogError(ex.Message, ex);
                return BadRequest(new PagedResult<UsuarioResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "INVALID_DATA",
                    ////Items = new(),
                    TotalCount = 0
                });
            }
            catch (ArgumentException ex)
            {
                _logger.LogError(ex.Message, ex);
                return BadRequest(new PagedResult<UsuarioResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "MISSING_REQUIRED_FIELDS",
                    ////Items = new(),
                    TotalCount = 0
                });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogError(ex.Message, ex);
                return Conflict(new PagedResult<UsuarioResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "DUPLICATE_USER",
                    ////Items = new(),
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
        public async Task<ActionResult<PagedResult<UsuarioResponse>>> Update(int id, [FromBody] UsuarioDto dto)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.UpdateAsync(id, dto, usuarioActual);

                return Ok(new PagedResult<UsuarioResponse>
                {
                    Success = true,
                    Message = "Usuario actualizado correctamente",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<UsuarioResponse> { result },
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
                return Ok(new { success = result, message = "Usuario eliminado correctamente" });
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