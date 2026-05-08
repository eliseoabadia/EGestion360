using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Controllers.Catalogos.Presupuestales
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class UnidadResponsableController : ControllerBase
    {
        private readonly ILogger<UnidadResponsableController> _logger;
        private readonly IRepository<Area> _repository;
        private readonly EGestionContext _context;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public UnidadResponsableController(
            ILogger<UnidadResponsableController> logger,
            IRepository<Area> repository,
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
        public async Task<ActionResult<PagedResult<UnidadResponsableResponse>>> GetAll()
        {
            try
            {
                var items = await _context.VwAreas.ToListAsync();
                var mapped = _mapper.Map<List<UnidadResponsableResponse>>(items);
                var dict = mapped.ToDictionary(m => m.PkidUnidadResponsable);
                foreach (var item in mapped)
                {
                    if (item.FkidAreaSis.HasValue && dict.ContainsKey(item.FkidAreaSis.Value))
                    {
                        dict[item.FkidAreaSis.Value].Children.Add(item);
                    }
                }
                var roots = mapped.Where(m => !m.FkidAreaSis.HasValue).ToList();
                return Ok(new PagedResult<UnidadResponsableResponse>
                {
                    Items = roots,
                    TotalCount = mapped.Count,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener todas las Unidades Responsables desde VwAreas");
                return Ok(new PagedResult<UnidadResponsableResponse>
                {
                    Success = false,
                    Message = $"Error interno: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<UnidadResponsableResponse>>> GetById(int id)
        {
            try
            {
                var entity = await _context.VwAreas.FirstOrDefaultAsync(e => e.PkidArea == id);
                if (entity == null)
                    return NotFound(new PagedResult<UnidadResponsableResponse>
                    {
                        Success = false,
                        Message = "Unidad Responsable no encontrada",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    });

                var response = _mapper.Map<UnidadResponsableResponse>(entity);
                return Ok(new PagedResult<UnidadResponsableResponse>
                {
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS",
                    Data = response,
                    Items = new List<UnidadResponsableResponse> { response },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetById de UnidadResponsable para ID {Id}", id);
                return Ok(new PagedResult<UnidadResponsableResponse>
                {
                    Success = false,
                    Message = $"Error interno: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<UnidadResponsableResponse>>> Create([FromBody] UnidadResponsableResponse response)
        {
            try
            {
                var dto = _mapper.Map<UnidadResponsableDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.UtcNow;
                dto.Activo = true;

                var exists = await _repository.GetAllWithIncludesAsync(e => e.Clave.ToLower() == dto.Clave.ToLower() && e.Activo);
                if (exists.Any())
                {
                    return Conflict(new PagedResult<UnidadResponsableResponse>
                    {
                        Success = false,
                        Message = "Ya existe una Unidad Responsable activa con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                var entity = _mapper.Map<Area>(dto);
                await _repository.AddAsync(entity);

                return CreatedAtAction(nameof(GetById), new { id = entity.PkidArea },
                    new PagedResult<UnidadResponsableResponse>
                    {
                        Success = true,
                        Message = "Unidad Responsable creada correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<UnidadResponsableResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<UnidadResponsableResponse>>> Update(int id, [FromBody] UnidadResponsableResponse response)
        {
            try
            {
                var entity = await _repository.GetByIdAsync(id);
                if (entity == null)
                    return NotFound(new PagedResult<UnidadResponsableResponse>
                    {
                        Success = false,
                        Message = $"Unidad Responsable con ID {id} no encontrada",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    });

                var dto = _mapper.Map<UnidadResponsableDto>(response);
                dto.PkidUnidadResponsable = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.UtcNow;

                var duplicate = await _repository.GetAllWithIncludesAsync(e => e.Clave.ToLower() == dto.Clave.ToLower() && e.PkidArea != id && e.Activo);
                if (duplicate.Any())
                {
                    return Conflict(new PagedResult<UnidadResponsableResponse>
                    {
                        Success = false,
                        Message = "Ya existe otra Unidad Responsable activa con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                _mapper.Map(dto, entity);
                entity.FechaModificacion = dto.FechaModificacion;
                entity.UsuarioModificacion = dto.UsuarioModificacion;
                await _repository.UpdateAsync(entity);

                return Ok(new PagedResult<UnidadResponsableResponse>
                {
                    Success = true,
                    Message = "Unidad Responsable actualizada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<UnidadResponsableResponse>
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
                        Message = $"Unidad Responsable con ID {id} no encontrada",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    });

                var hasChildren = await _repository.GetAllWithIncludesAsync(e => e.FkidAreaSis == id && e.Activo);
                if (hasChildren.Any())
                {
                    return BadRequest(new PagedResult<bool>
                    {
                        Success = false,
                        Message = "No se puede eliminar un área que tiene hijos activos",
                        Code = "HAS_CHILDREN",
                        TotalCount = 0
                    });
                }

                await _repository.DeleteAsync(id);
                return Ok(new PagedResult<bool>
                {
                    Success = true,
                    Message = "Unidad Responsable eliminada correctamente",
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
        public async Task<ActionResult<PagedResult<UnidadResponsableResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            try
            {
                var query = _context.VwAreas.AsQueryable();

                if (!string.IsNullOrWhiteSpace(request.Filtro))
                {
                    var f = request.Filtro;
                    query = query.Where(e => e.Clave.Contains(f) || e.Nombre.Contains(f) || e.AreaPadreNombre.Contains(f));
                }

                if (!string.IsNullOrEmpty(request.SortLabel))
                {
                    var isAscending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                    query = request.SortLabel switch
                    {
                        "PkidUnidadResponsable" or "PkidArea" => isAscending ? query.OrderBy(e => e.PkidArea) : query.OrderByDescending(e => e.PkidArea),
                        "Clave" => isAscending ? query.OrderBy(e => e.Clave) : query.OrderByDescending(e => e.Clave),
                        "Descripcion" => isAscending ? query.OrderBy(e => e.Nombre) : query.OrderByDescending(e => e.Nombre),
                        "AreaPadreNombre" => isAscending ? query.OrderBy(e => e.AreaPadreNombre) : query.OrderByDescending(e => e.AreaPadreNombre),
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

                return Ok(new PagedResult<UnidadResponsableResponse>
                {
                    Items = _mapper.Map<List<UnidadResponsableResponse>>(items),
                    TotalCount = totalItems,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetAllPaginado de UnidadResponsable");
                return Ok(new PagedResult<UnidadResponsableResponse>
                {
                    Success = false,
                    Message = $"Error interno: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<UnidadResponsableResponse>>> Buscar([FromBody] BusquedaRequest request)
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
