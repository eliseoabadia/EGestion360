using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Application.Interfaces.Configuracion.Catalogo.ClavePrograma;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Presupuestales;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Catalogos.Presupuestales
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class GfController : ControllerBase
    {
        private readonly IGfService _gfService;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public GfController(IGfService gfService, IMapper mapper, IUserContextService userContext)
        {
            _gfService = gfService;
            _mapper = mapper;
            _userContext = userContext;
        }

        /// <summary>
        /// Obtiene todos los registros (sin paginación)
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<PagedResult<GfResponse>>> GetAll()
        {
            var items = await _gfService.GetAllAsync();
            return Ok(new PagedResult<GfResponse>
            {
                Success = true,
                Message = "Registros obtenidos correctamente",
                Code = "SUCCESS",
                Items = items.ToList(),
                TotalCount = items.Count()
            });
        }

        /// <summary>
        /// Obtiene un registro por su ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<GfResponse>>> GetById(int id)
        {
            var result = await _gfService.GetByIdAsync(id);
            if (result == null)
            {
                return NotFound(new PagedResult<GfResponse>
                {
                    Success = false,
                    Message = $"No se encontró el registro con ID {id}",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }

            return Ok(new PagedResult<GfResponse>
            {
                Success = true,
                Message = "Registro encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<GfResponse> { result },
                TotalCount = 1
            });
        }

        /// <summary>
        /// Crea un nuevo registro
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<PagedResult<GfResponse>>> Create([FromBody] GfResponse request)
        {
            try
            {
                // Validación básica de modelo (automática por [ApiController])
                if (!ModelState.IsValid)
                {
                    return BadRequest(new PagedResult<GfResponse>
                    {
                        Success = false,
                        Message = "Datos inválidos",
                        Code = "INVALID_MODEL",
                        TotalCount = 0
                    });
                }

                var dto = _mapper.Map<GfDto>(request);

                // Validar reglas de negocio (unicidad, etc.)
                if (!await _gfService.CanAddAsync(dto))
                {
                    return Conflict(new PagedResult<GfResponse>
                    {
                        Success = false,
                        Message = "Ya existe un registro activo con la misma Clave o Descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                int currentUserId = _userContext.GetCurrentUserId();
                var created = await _gfService.AddAsync(dto, currentUserId);

                return CreatedAtAction(nameof(GetById), new { id = created.PkidGf },
                    new PagedResult<GfResponse>
                    {
                        Success = true,
                        Message = "Registro creado exitosamente",
                        Code = "SUCCESS",
                        Data = created,
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                // Log del error (puedes inyectar ILogger)
                return StatusCode(500, new PagedResult<GfResponse>
                {
                    Success = false,
                    Message = "Ocurrió un error interno al crear el registro",
                    Code = "INTERNAL_ERROR",
                    TotalCount = 0
                });
            }
        }

        /// <summary>
        /// Actualiza un registro existente
        /// </summary>
        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<GfResponse>>> Update(int id, [FromBody] GfResponse request)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(new PagedResult<GfResponse>
                    {
                        Success = false,
                        Message = "Datos inválidos",
                        Code = "INVALID_MODEL",
                        TotalCount = 0
                    });
                }

                var dto = _mapper.Map<GfDto>(request);
                dto.PkidGf = id;

                if (!await _gfService.CanUpdateAsync(id, dto))
                {
                    return Conflict(new PagedResult<GfResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro registro activo con la misma Clave o Descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                int currentUserId = _userContext.GetCurrentUserId();
                await _gfService.UpdateAsync(id, dto, currentUserId);

                // Opcional: obtener el registro actualizado para devolverlo
                var updated = await _gfService.GetByIdAsync(id);

                return Ok(new PagedResult<GfResponse>
                {
                    Success = true,
                    Message = "Registro actualizado correctamente",
                    Code = "SUCCESS",
                    Data = updated,
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<GfResponse>
                {
                    Success = false,
                    Message = $"No se encontró el registro con ID {id}",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new PagedResult<GfResponse>
                {
                    Success = false,
                    Message = "Ocurrió un error interno al actualizar el registro",
                    Code = "INTERNAL_ERROR",
                    TotalCount = 0
                });
            }
        }

        /// <summary>
        /// Elimina un registro (borrado lógico o físico, según implementación del servicio)
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<GfResponse>>> Delete(int id)
        {
            try
            {
                await _gfService.DeleteAsync(id);
                return Ok(new PagedResult<GfResponse>
                {
                    Success = true,
                    Message = "Registro eliminado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<GfResponse>
                {
                    Success = false,
                    Message = $"No se encontró el registro con ID {id}",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new PagedResult<GfResponse>
                {
                    Success = false,
                    Message = "Ocurrió un error interno al eliminar el registro",
                    Code = "INTERNAL_ERROR",
                    TotalCount = 0
                });
            }
        }

        /// <summary>
        /// Obtiene registros paginados con filtros y ordenamiento
        /// </summary>
        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<GfResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            try
            {
                var result = await _gfService.GetAllPaginadoAsync(request);
                return Ok(new PagedResult<GfResponse>
                {
                    Success = true,
                    Message = "Registros obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount,
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new PagedResult<GfResponse>
                {
                    Success = false,
                    Message = "Error al obtener los registros paginados",
                    Code = "INTERNAL_ERROR",
                    TotalCount = 0
                });
            }
        }

        /// <summary>
        /// Búsqueda dinámica (usa el mismo método paginado con filtro)
        /// </summary>
        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<GfResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            try
            {
                var pagedRequest = new PagedRequest
                {
                    Page = request.Page,
                    PageSize = request.PageSize,
                    Filtro = request.TerminoBusqueda,
                    SortLabel = request.SortLabel,
                    SortDirection = request.SortDirection
                };
                var result = await _gfService.GetAllPaginadoAsync(pagedRequest);
                return Ok(new PagedResult<GfResponse>
                {
                    Success = true,
                    Message = "Búsqueda realizada correctamente",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new PagedResult<GfResponse>
                {
                    Success = false,
                    Message = "Error al realizar la búsqueda",
                    Code = "INTERNAL_ERROR",
                    TotalCount = 0
                });
            }
        }
    }
}