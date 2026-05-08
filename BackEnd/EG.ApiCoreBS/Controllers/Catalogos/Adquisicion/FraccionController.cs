using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Controllers.Catalogos.Adquisicion
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class FraccionController : ControllerBase
    {
        private readonly ILogger<FraccionController> _logger;
        private readonly IRepository<Fraccion> _repository;
        private readonly EGestionContext _context;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public FraccionController(
            ILogger<FraccionController> logger,
            IRepository<Fraccion> repository,
            EGestionContext context,
            IMapper mapper,
            IUserContextService userContext)
        {
            _logger = logger;
            _repository = repository;
            _context = context;
            _mapper = mapper;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<FraccionResponse>>> GetAll()
        {
            try
            {
                var items = await _context.VwFraccions.ToListAsync();
                return Ok(new PagedResult<FraccionResponse>
                {
                    Items = _mapper.Map<List<FraccionResponse>>(items),
                    TotalCount = items.Count,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetAll de Fraccion");
                return Ok(new PagedResult<FraccionResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                });
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<FraccionResponse>>> GetById(int id)
        {
            try
            {
                var entity = await _context.VwFraccions.FirstOrDefaultAsync(e => e.PkidFraccion == id);
                if (entity == null)
                    return NotFound(new PagedResult<FraccionResponse>
                    {
                        Success = false,
                        Message = "Fracción no encontrada",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    });

                var response = _mapper.Map<FraccionResponse>(entity);
                return Ok(new PagedResult<FraccionResponse>
                {
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS",
                    Data = response,
                    Items = new List<FraccionResponse> { response },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetById de Fraccion para ID {Id}", id);
                return Ok(new PagedResult<FraccionResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                });
            }
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<FraccionResponse>>> Create([FromBody] FraccionResponse response)
        {
            try
            {
                var dto = _mapper.Map<FraccionDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.UtcNow;
                dto.Activo = true;

                var exists = await _repository.GetAllWithIncludesAsync(e => e.Clave.ToLower() == dto.Clave.ToLower() && e.Activo);
                if (exists.Any())
                {
                    return Conflict(new PagedResult<FraccionResponse>
                    {
                        Success = false,
                        Message = "Ya existe una fracción activa con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                var entity = _mapper.Map<Fraccion>(dto);
                await _repository.AddAsync(entity);

                return CreatedAtAction(nameof(GetById), new { id = entity.PkidFraccion },
                    new PagedResult<FraccionResponse>
                    {
                        Success = true,
                        Message = "Fracción creada correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<FraccionResponse>
                {
                    Success = false,
                    Message = $"Error al crear fracción: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<FraccionResponse>>> Update(int id, [FromBody] FraccionResponse response)
        {
            try
            {
                var entity = await _repository.GetByIdAsync(id);
                if (entity == null)
                    return NotFound(new PagedResult<FraccionResponse>
                    {
                        Success = false,
                        Message = $"Fracción con ID {id} no encontrada",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    });

                var dto = _mapper.Map<FraccionDto>(response);
                dto.PkidFraccion = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.UtcNow;

                var duplicate = await _repository.GetAllWithIncludesAsync(e => e.Clave.ToLower() == dto.Clave.ToLower() && e.PkidFraccion != id && e.Activo);
                if (duplicate.Any())
                {
                    return Conflict(new PagedResult<FraccionResponse>
                    {
                        Success = false,
                        Message = "Ya existe otra fracción activa con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                _mapper.Map(dto, entity);
                entity.FechaModificacion = dto.FechaModificacion;
                entity.UsuarioModificacion = dto.UsuarioModificacion;
                await _repository.UpdateAsync(entity);

                return Ok(new PagedResult<FraccionResponse>
                {
                    Success = true,
                    Message = "Fracción actualizada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<FraccionResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            try
            {
                var entity = await _repository.GetByIdAsync(id);
                if (entity == null)
                    return NotFound(new PagedResult<bool>
                    {
                        Success = false,
                        Message = $"Fracción con ID {id} no encontrada",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    });

                await _repository.DeleteAsync(id);
                return Ok(new PagedResult<bool>
                {
                    Success = true,
                    Message = "Fracción eliminada correctamente",
                    Code = "SUCCESS",
                    Data = true,
                    Items = new List<bool> { true },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Error al eliminar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<FraccionResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            try
            {
                var query = _context.VwFraccions.AsQueryable();

                if (!string.IsNullOrWhiteSpace(request.Filtro))
                {
                    var f = request.Filtro;
                    query = query.Where(e => e.Clave.Contains(f) || e.Descripcion.Contains(f) || e.ArticuloDescripcion.Contains(f));
                }

                if (!string.IsNullOrEmpty(request.SortLabel))
                {
                    var isAscending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                    query = request.SortLabel switch
                    {
                        "PkidFraccion" => isAscending ? query.OrderBy(e => e.PkidFraccion) : query.OrderByDescending(e => e.PkidFraccion),
                        "Clave" => isAscending ? query.OrderBy(e => e.Clave) : query.OrderByDescending(e => e.Clave),
                        "Descripcion" => isAscending ? query.OrderBy(e => e.Descripcion) : query.OrderByDescending(e => e.Descripcion),
                        "NombreArticulo" or "ArticuloDescripcion" => isAscending ? query.OrderBy(e => e.ArticuloDescripcion) : query.OrderByDescending(e => e.ArticuloDescripcion),
                        "Activo" => isAscending ? query.OrderBy(e => e.Activo) : query.OrderByDescending(e => e.Activo),
                        _ => query.OrderBy(e => e.Clave)
                    };
                }
                else
                {
                    query = query.OrderBy(e => e.Clave);
                }

                var totalItems = await query.CountAsync();
                var items = await query
                    .Skip((request.Page - 1) * request.PageSize)
                    .Take(request.PageSize)
                    .ToListAsync();

                return Ok(new PagedResult<FraccionResponse>
                {
                    Items = _mapper.Map<List<FraccionResponse>>(items),
                    TotalCount = totalItems,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetAllPaginado de Fraccion");
                return Ok(new PagedResult<FraccionResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                });
            }
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<FraccionResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };

            return await GetAllPaginado(pagedRequest);
        }
    }
}