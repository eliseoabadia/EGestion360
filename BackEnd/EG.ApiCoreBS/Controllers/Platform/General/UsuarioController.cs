using Mapster;
using EG.ApiCoreBS.Services;
using EG.Domain.Interfaces;
using EG.Application.Interfaces.General;
using EG.Common.Enums;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Dommain.DTOs.Responses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.General
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
                return StatusCode(500, Error(ex.Message));
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<UsuarioResponse>>> GetById(int id)
        {
            try
            {
                var usuario = await _appService.GetByIdAsync(id);

                if (usuario == null)
                {
                    return NotFound(Error("Usuario no encontrado", ApiResponseCode.NotFound));
                }

                return Ok(Success("Usuario encontrado", usuario));
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetById: {ex.Message}", ex);
                return StatusCode(500, Error(ex.Message));
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
                return StatusCode(500, Error(ex.Message));
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<UsuarioResponse>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
        {
            try
            {
                var result = await _appService.GetAllPaginadoAsync(pageRequest);
                return Ok(new PagedResult<UsuarioResponse>
                {
                    Success = true,
                    Message = "Usuarios obtenidos correctamente",
                    Code = ApiResponseCode.Success.ToCode(),
                    Items = result.Items,
                    TotalCount = result.TotalCount
                });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetAllPaginado: {ex.Message}", ex);
                return StatusCode(500, Error(ex.Message));
            }
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<UsuarioResponse>>> Create([FromBody] UsuarioResponse request)
        {
            ModelState.Clear();
            if (!request.IdPersona.HasValue || request.IdPersona.Value <= 0)
            {
                return BadRequest(Error("Debe seleccionar una persona vinculada", ApiResponseCode.InvalidData));
            }

            try
            {
                var dto = request.Adapt<UsuarioDto>();
                NormalizeUsuarioDtoEmpresa(request, dto);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;

                var result = await _appService.CreateAsync(dto, dto.UsuarioCreacion);

                return CreatedAtAction(nameof(GetById), new { id = result.PkIdUsuario },
                    Success("Usuario creado correctamente", result));
            }
            catch (ArgumentNullException ex)
            {
                _logger.LogError(ex.Message, ex);
                return BadRequest(Error(ex.Message, ApiResponseCode.InvalidData));
            }
            catch (ArgumentException ex)
            {
                _logger.LogError(ex.Message, ex);
                return BadRequest(Error(ex.Message, ApiResponseCode.MissingRequiredFields));
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogError(ex.Message, ex);
                return Conflict(Error(ex.Message, ApiResponseCode.Duplicated));
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en Create: {ex.Message}", ex);
                return StatusCode(500, Error(ex.Message));
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<UsuarioResponse>>> Update(int id, [FromBody] UsuarioResponse request)
        {
            ModelState.Clear();
            try
            {
                var dto = request.Adapt<UsuarioDto>();
                NormalizeUsuarioDtoEmpresa(request, dto);
                dto.PkIdUsuario = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                var result = await _appService.UpdateAsync(id, dto, dto.UsuarioModificacion ?? 0);

                return Ok(Success("Usuario actualizado correctamente", result));
            }
            catch (ArgumentNullException ex)
            {
                _logger.LogError(ex.Message, ex);
                return BadRequest(Error(ex.Message, ApiResponseCode.InvalidData));
            }
            catch (ArgumentException ex)
            {
                _logger.LogError(ex.Message, ex);
                return BadRequest(Error(ex.Message, ApiResponseCode.MissingRequiredFields));
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogError(ex.Message, ex);
                return Conflict(Error(ex.Message, ApiResponseCode.Duplicated));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, ex);
                return StatusCode(500, Error(ex.Message));
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<UsuarioResponse>>> Delete(int id)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                await _appService.DeleteAsync(id, usuarioActual);
                return Ok(new PagedResult<UsuarioResponse>
                {
                    Success = true,
                    Message = "Usuario eliminado correctamente",
                    Code = ApiResponseCode.Success.ToCode(),
                    TotalCount = 0
                });
            }
            catch (ArgumentException ex)
            {
                _logger.LogError(ex.Message, ex);
                return BadRequest(Error(ex.Message, ApiResponseCode.InvalidData));
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogError(ex.Message, ex);
                return NotFound(Error(ex.Message, ApiResponseCode.NotFound));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, ex);
                return StatusCode(500, Error(ex.Message));
            }
        }

        private static PagedResult<UsuarioResponse> Success(string message, UsuarioResponse data) =>
            new()
            {
                Success = true,
                Message = message,
                Code = ApiResponseCode.Success.ToCode(),
                Data = data,
                Items = new List<UsuarioResponse> { data },
                TotalCount = 1
            };

        private static PagedResult<UsuarioResponse> Error(string message, ApiResponseCode code = ApiResponseCode.Error) =>
            new()
            {
                Success = false,
                Message = message,
                Code = code.ToCode(),
                TotalCount = 0
            };

        private static void NormalizeUsuarioDtoEmpresa(UsuarioResponse request, UsuarioDto dto)
        {
            dto.FkidEmpresaSis = dto.FkidEmpresaSis > 0
                ? dto.FkidEmpresaSis
                : request.IdEmpresa > 0
                    ? request.IdEmpresa
                    : request.PkidEmpresa;

            // Los contratos de lectura y escritura usan nombres diferentes.
            // Sin esta normalizacion la edicion desvinculaba a la persona o
            // guardaba el usuario como inactivo.
            dto.FkidPersonaNom = request.IdPersona;
            dto.Activo = request.UsuarioActivo;
        }
    }
}
