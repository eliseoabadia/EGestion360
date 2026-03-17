using EG.ApiCore.Services;
using EG.Application.Interfaces.ConteoCiclico;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using AutoMapper;

namespace EG.ApiCore.Controllers.ConteoCiclico
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class BienController : ControllerBase
    {
        private readonly Logger.Log4NetLogger _logger = new Logger.Log4NetLogger(typeof(BienController));
        private readonly IBienAppService _appService;
        private readonly IUserContextService _userContext;
        private readonly IMapper _mapper;

        public BienController(
            IBienAppService appService,
            IUserContextService userContext,
            IMapper mapper)
        {
            _appService = appService;
            _userContext = userContext;
            _mapper = mapper;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<BienResponse>>> GetAll()
        {
            try
            {
                var result = await _appService.GetAllAsync();
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetAll: {ex.Message}", ex);
                return StatusCode(500, new PagedResult<BienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<BienResponse>> GetById(int id)
        {
            try
            {
                var item = await _appService.GetByIdAsync(id);
                if (item == null)
                {
                    return NotFound(new PagedResult<BienResponse>
                    {
                        Success = false,
                        Message = "Bien no encontrado",
                        Code = "NOTFOUND",
                        TotalCount = 0
                    });
                }

                return Ok(new PagedResult<BienResponse>
                {
                    Success = true,
                    Message = "Bien encontrado",
                    Code = "SUCCESS",
                    Data = item,
                    Items = new List<BienResponse> { item },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetById: {ex.Message}", ex);
                return StatusCode(500, new PagedResult<BienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPost("paginated")]
        public async Task<ActionResult<PagedResult<BienResponse>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
        {
            try
            {
                var result = await _appService.GetAllPaginadoAsync(pageRequest);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetAllPaginado: {ex.Message}", ex);
                return StatusCode(500, new PagedResult<BienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpGet("periodo/{periodoId}")]
        public async Task<ActionResult<PagedResult<BienResponse>>> GetByPeriodoId(int periodoId)
        {
            try
            {
                var result = await _appService.GetByPeriodoIdAsync(periodoId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetByPeriodoId: {ex.Message}", ex);
                return StatusCode(500, new PagedResult<BienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpGet("sucursal/{sucursalId}")]
        public async Task<ActionResult<PagedResult<BienResponse>>> GetBySucursalId(int sucursalId)
        {
            try
            {
                var result = await _appService.GetBySucursalIdAsync(sucursalId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetBySucursalId: {ex.Message}", ex);
                return StatusCode(500, new PagedResult<BienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpGet("area/{areaId}")]
        public async Task<ActionResult<PagedResult<BienResponse>>> GetByAreaId(int areaId)
        {
            try
            {
                var result = await _appService.GetByAreaIdAsync(areaId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetByAreaId: {ex.Message}", ex);
                return StatusCode(500, new PagedResult<BienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpGet("activos")]
        public async Task<ActionResult<PagedResult<BienResponse>>> GetActivos()
        {
            try
            {
                var result = await _appService.GetActivosAsync();
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetActivos: {ex.Message}", ex);
                return StatusCode(500, new PagedResult<BienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<BienResponse>>> Create([FromBody] BienResponse response)
        {
            try
            {
                var dto = _mapper.Map<BienDto>(response);
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.CreateAsync(dto, usuarioActual);
                return Ok(new PagedResult<BienResponse>
                {
                    Success = true,
                    Message = "Bien creado exitosamente",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<BienResponse> { result },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en Create: {ex.Message}", ex);
                return StatusCode(500, new PagedResult<BienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<BienResponse>>> Update(int id, [FromBody] BienResponse response)
        {
            try
            {
                var dto = _mapper.Map<BienDto>(response);
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.UpdateAsync(id, dto, usuarioActual);
                return Ok(new PagedResult<BienResponse>
                {
                    Success = true,
                    Message = "Bien actualizado exitosamente",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<BienResponse> { result },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en Update: {ex.Message}", ex);
                return StatusCode(500, new PagedResult<BienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<BienResponse>>> Delete(int id)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.DeleteAsync(id, usuarioActual);
                if (result)
                {
                    return Ok(new PagedResult<BienResponse>
                    {
                        Success = true,
                        Message = "Bien eliminado exitosamente",
                        Code = "SUCCESS",
                        TotalCount = 0
                    });
                }
                return BadRequest(new PagedResult<BienResponse>
                {
                    Success = false,
                    Message = "No se pudo eliminar el bien",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en Delete: {ex.Message}", ex);
                return StatusCode(500, new PagedResult<BienResponse>
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
