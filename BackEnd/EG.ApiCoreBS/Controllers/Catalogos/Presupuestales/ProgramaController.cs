using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Configuracion.Catalogo.Presupuestales
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ProgramaController : ControllerBase
    {
        private readonly Logger.Log4NetLogger _logger = new Logger.Log4NetLogger(typeof(ProgramaController));
        private readonly IProgramaAppServices _appService;
        private readonly IUserContextService _userContext;
        private readonly IMapper _mapper;

        public ProgramaController(
            IProgramaAppServices appService,
            IUserContextService userContext,
            IMapper mapper)
        {
            _appService = appService;
            _userContext = userContext;
            _mapper = mapper;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<ProgramaResponse>>> GetAll()
        {
            try
            {
                var result = await _appService.GetAllAsync();
                // Convertir el IEnumerable a PagedResult estándar
                var lista = result.ToList();
                return Ok(new PagedResult<ProgramaResponse>
                {
                    Success = true,
                    Message = "Programas obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = lista,
                    TotalCount = lista.Count
                });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetAll: {ex.Message}", ex);
                return StatusCode(500, new PagedResult<ProgramaResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    Items = new List<ProgramaResponse>(),
                    TotalCount = 0
                });
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<ProgramaResponse>>> GetById(int id)
        {
            try
            {
                var programa = await _appService.GetByIdAsync(id);

                if (programa == null)
                {
                    return NotFound(new PagedResult<ProgramaResponse>
                    {
                        Success = false,
                        Message = "Programa no encontrado",
                        Code = "NOTFOUND_PROGRAMA",
                        Items = new List<ProgramaResponse>(),
                        TotalCount = 0
                    });
                }

                return Ok(new PagedResult<ProgramaResponse>
                {
                    Success = true,
                    Message = "Programa encontrado",
                    Code = "SUCCESS",
                    Data = programa,
                    Items = new List<ProgramaResponse> { programa },
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
        public async Task<ActionResult<PagedResult<ProgramaResponse>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
        {
            try
            {
                var result = await _appService.GetAllPaginadoAsync(pageRequest);
                return Ok(new PagedResult<ProgramaResponse>
                {
                    Success = true,
                    Message = "Programas obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetAllPaginado: {ex.Message}", ex);
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<ProgramaResponse>>> Create([FromBody] ProgramaResponse request)
        {
            try
            {
                var dto = _mapper.Map<ProgramaDto>(request);
                int usuarioActual = _userContext.GetCurrentUserId();
                dto.UsuarioCreacion = usuarioActual;
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                var result = await _appService.CreateAsync(dto, usuarioActual);

                return CreatedAtAction(nameof(GetById), new { id = result.PkidPrograma },
                    new PagedResult<ProgramaResponse>
                    {
                        Success = true,
                        Message = "Programa creado correctamente",
                        Code = "SUCCESS",
                        Data = result,
                        Items = new List<ProgramaResponse> { result },
                        TotalCount = 1
                    });
            }
            catch (ArgumentNullException ex)
            {
                _logger.LogError(ex.Message, ex);
                return BadRequest(new PagedResult<ProgramaResponse>
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
                return BadRequest(new PagedResult<ProgramaResponse>
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
                return Conflict(new PagedResult<ProgramaResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "DUPLICATE_PROGRAMA",
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
        public async Task<ActionResult<PagedResult<ProgramaResponse>>> Update(int id, [FromBody] ProgramaResponse request)
        {
            try
            {
                var dto = _mapper.Map<ProgramaDto>(request);
                dto.PkidPrograma = id;
                int usuarioActual = _userContext.GetCurrentUserId();
                dto.UsuarioModificacion = usuarioActual;
                dto.FechaModificacion = DateTime.Now;

                var result = await _appService.UpdateAsync(id, dto, usuarioActual);

                return Ok(new PagedResult<ProgramaResponse>
                {
                    Success = true,
                    Message = "Programa actualizado correctamente",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<ProgramaResponse> { result },
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
                int usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.DeleteAsync(id, usuarioActual);
                return Ok(new { success = result, message = "Programa eliminado correctamente" });
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