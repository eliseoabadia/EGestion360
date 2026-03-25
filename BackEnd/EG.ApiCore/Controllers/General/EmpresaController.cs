using AutoMapper;
using EG.ApiCore.Services;
using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class EmpresaController : ControllerBase
    {
        private readonly Logger.Log4NetLogger _logger = new Logger.Log4NetLogger(typeof(EmpresaController));
        private readonly IEmpresaAppService _appService;
        private readonly IUserContextService _userContext;
        private readonly IMapper _mapper;

        public EmpresaController(
            IEmpresaAppService appService,
            IUserContextService userContext,
            IMapper mapper)
        {
            _appService = appService;
            _userContext = userContext;
            _mapper = mapper;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> GetAll()
        {
            try
            {
                var result = await _appService.GetAllAsync();
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetAll: {ex.Message}", ex);
                return StatusCode(500, new PagedResult<EmpresaResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<EmpresaResponse>> GetById(int id)
        {
            try
            {
                var empresa = await _appService.GetByIdAsync(id);

                if (empresa == null)
                {
                    return NotFound(new PagedResult<EmpresaResponse>
                    {
                        Success = false,
                        Message = "Empresa no encontrada",
                        Code = "NOTFOUND_EMPRESA",
                        TotalCount = 0
                    });
                }

                return Ok(new PagedResult<EmpresaResponse>
                {
                    Success = true,
                    Message = "Empresa encontrada",
                    Code = "SUCCESS",
                    Data = empresa,
                    Items = new List<EmpresaResponse> { empresa },
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
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
        {
            try
            {
                var result = await _appService.GetAllPaginadoAsync(pageRequest);
                return Ok(new PagedResult<EmpresaResponse>
                {
                    Success = true,
                    Message = "Empresas obtenidas correctamente",
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
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> Create([FromBody] EmpresaResponse request)
        {
            try
            {
                var dto = _mapper.Map<EmpresaDto>(request);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;

                var result = await _appService.CreateAsync(dto, dto.UsuarioCreacion);

                return CreatedAtAction(nameof(GetById), new { id = result.PkidEmpresa },
                    new PagedResult<EmpresaResponse>
                    {
                        Success = true,
                        Message = "Empresa creada correctamente",
                        Code = "SUCCESS",
                        Data = result,
                        Items = new List<EmpresaResponse> { result },
                        TotalCount = 1
                    });
            }
            catch (ArgumentNullException ex)
            {
                _logger.LogError(ex.Message, ex);
                return BadRequest(new PagedResult<EmpresaResponse>
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
                return BadRequest(new PagedResult<EmpresaResponse>
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
                return Conflict(new PagedResult<EmpresaResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "DUPLICATE_RFC",
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
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> Update(int id, [FromBody] EmpresaResponse request)
        {
            try
            {
                var dto = _mapper.Map<EmpresaDto>(request);
                dto.PkidEmpresa = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                var result = await _appService.UpdateAsync(id, dto, dto.UsuarioModificacion ?? 0);

                return Ok(new PagedResult<EmpresaResponse>
                {
                    Success = true,
                    Message = "Empresa actualizada correctamente",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<EmpresaResponse> { result },
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
                return Ok(new { success = result, message = "Empresa eliminada correctamente" });
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