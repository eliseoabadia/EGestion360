using EG.ApiCore.Services;
using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;


namespace EG.ApiCore.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class UsuarioSucursalController : ControllerBase
    {
        private readonly IUserContextService _userContext;
        private readonly IUsuarioSucursalAppService _appService;

        public UsuarioSucursalController(
            IUsuarioSucursalAppService appService,
            IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        /// <summary>
        /// Obtiene todas las asignaciones usuario-sucursal
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<PagedResult<VwUsuarioSucursalResponse>>> GetAll()
        {
            try
            {
                var result = await _appService.GetAllAsync();
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new PagedResult<VwUsuarioSucursalResponse>
                {
                    Success = false,
                    Message = $"Error al obtener asignaciones: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        /// <summary>
        /// Obtiene una asignación específica por ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<VwUsuarioSucursalResponse>>> GetById(int id)
        {
            try
            {
                var result = await _appService.GetByIdAsync(id);

                if (result == null)
                    return NotFound(new PagedResult<VwUsuarioSucursalResponse>
                    {
                        Success = false,
                        Message = "Asignación no encontrada",
                        Code = "NOTFOUND_ASIGNACION",
                        TotalCount = 0
                    });

                return Ok(new PagedResult<VwUsuarioSucursalResponse>
                {
                    Success = true,
                    Message = "Asignación encontrada",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<VwUsuarioSucursalResponse> { result },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new PagedResult<VwUsuarioSucursalResponse>
                {
                    Success = false,
                    Message = $"Error al obtener asignación: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        /// <summary>
        /// Obtiene una asignación específica por usuario y sucursal
        /// </summary>
        [HttpGet("usuario/{usuarioId}/sucursal/{sucursalId}")]
        public async Task<ActionResult<PagedResult<VwUsuarioSucursalResponse>>> GetByUsuarioAndSucursal(int usuarioId, int sucursalId)
        {
            try
            {
                var result = await _appService.GetByUsuarioAndSucursalAsync(usuarioId, sucursalId);

                if (result == null)
                    return NotFound(new PagedResult<VwUsuarioSucursalResponse>
                    {
                        Success = false,
                        Message = "Asignación no encontrada",
                        Code = "NOTFOUND_ASIGNACION",
                        TotalCount = 0
                    });

                return Ok(new PagedResult<VwUsuarioSucursalResponse>
                {
                    Success = true,
                    Message = "Asignación encontrada",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<VwUsuarioSucursalResponse> { result },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new PagedResult<VwUsuarioSucursalResponse>
                {
                    Success = false,
                    Message = $"Error al obtener asignación: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        /// <summary>
        /// Obtiene todas las sucursales asignadas a un usuario
        /// </summary>
        [HttpGet("usuario/{usuarioId}")]
        public async Task<ActionResult<PagedResult<VwUsuarioSucursalResponse>>> GetByUsuario(int usuarioId)
        {
            try
            {
                var result = await _appService.GetByUsuarioAsync(usuarioId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new PagedResult<VwUsuarioSucursalResponse>
                {
                    Success = false,
                    Message = $"Error al obtener sucursales: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        /// <summary>
        /// Obtiene todos los usuarios asignados a una sucursal
        /// </summary>
        [HttpGet("sucursal/{sucursalId}")]
        public async Task<ActionResult<PagedResult<VwUsuarioSucursalResponse>>> GetBySucursal(int sucursalId)
        {
            try
            {
                var result = await _appService.GetBySucursalAsync(sucursalId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new PagedResult<VwUsuarioSucursalResponse>
                {
                    Success = false,
                    Message = $"Error al obtener usuarios: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        /// <summary>
        /// Obtiene los gerentes de una sucursal
        /// </summary>
        [HttpGet("sucursal/{sucursalId}/gerentes")]
        public async Task<ActionResult<PagedResult<VwUsuarioSucursalResponse>>> GetGerentesBySucursal(int sucursalId)
        {
            try
            {
                var result = await _appService.GetGerentesBySucursalAsync(sucursalId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new PagedResult<VwUsuarioSucursalResponse>
                {
                    Success = false,
                    Message = $"Error al obtener gerentes: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        /// <summary>
        /// Asigna un usuario a una sucursal
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<PagedResult<VwUsuarioSucursalResponse>>> Add([FromBody] VwUsuarioSucursalResponse _dto)
        {
            try
            {
                var result = await _appService.AddAsync(_dto, _userContext.GetCurrentUserId());

                return Ok(new PagedResult<VwUsuarioSucursalResponse>
                {
                    Success = true,
                    Message = "¡Usuario asignado correctamente a la sucursal!",
                    Code = "SUCCESS",
                    Data = result,
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<VwUsuarioSucursalResponse>
                {
                    Success = false,
                    Message = $"Error al asignar usuario: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        /// <summary>
        /// Elimina una asignación (baja física)
        /// </summary>
        [HttpDelete("{usuarioId}/{sucursalId}")]
        public async Task<ActionResult<PagedResult<VwUsuarioSucursalResponse>>> Delete(int usuarioId, int sucursalId)
        {
            try
            {
                await _appService.DeleteAsync(usuarioId, sucursalId, _userContext.GetCurrentUserId());

                return Ok(new PagedResult<VwUsuarioSucursalResponse>
                {
                    Success = true,
                    Message = "Asignación eliminada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<VwUsuarioSucursalResponse>
                {
                    Success = false,
                    Message = $"Error al eliminar asignación: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<VwUsuarioSucursalResponse>>> GetAllPaginado([FromBody] PagedRequest _params)
        {
            //_appService.ClearConfiguration();
            //ConfigureService(); // Reconfigurar includes si los necesitas para la vista

            var result = await _appService.GetAllPaginadoAsync(_params);
            return Ok(new PagedResult<VwUsuarioSucursalResponse>
            {
                Success = true,
                Message = "Usuario Sucursal optenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

    }
}