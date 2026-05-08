using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Controllers.Contabilidad
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ConceptoController : ControllerBase
    {
        private readonly ILogger<ConceptoController> _logger;
        private readonly IRepository<Concepto> _repository;
        private readonly EGestionContext _context;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public ConceptoController(
            ILogger<ConceptoController> logger,
            IRepository<Concepto> repository,
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
        public async Task<ActionResult<PagedResult<ConceptoResponse>>> GetAll()
        {
            try
            {
                var items = await _context.VwConceptos.ToListAsync();
                return Ok(new PagedResult<ConceptoResponse>
                {
                    Items = _mapper.Map<List<ConceptoResponse>>(items),
                    TotalCount = items.Count,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetAll de Concepto");
                return Ok(new PagedResult<ConceptoResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                });
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<ConceptoResponse>>> GetById(int id)
        {
            try
            {
                var entity = await _context.VwConceptos.FirstOrDefaultAsync(e => e.PkidConcepto == id);
                if (entity == null)
                    return NotFound(new PagedResult<ConceptoResponse>
                    {
                        Success = false,
                        Message = "Concepto no encontrado",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    });

                var response = _mapper.Map<ConceptoResponse>(entity);
                return Ok(new PagedResult<ConceptoResponse>
                {
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS",
                    Data = response,
                    Items = new List<ConceptoResponse> { response },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetById de Concepto para ID {Id}", id);
                return Ok(new PagedResult<ConceptoResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                });
            }
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<ConceptoResponse>>> Create([FromBody] ConceptoResponse response)
        {
            try
            {
                var dto = _mapper.Map<ConceptoDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.UtcNow;
                dto.Activo = true;

                var exists = await _repository.GetAllWithIncludesAsync(e => e.Descripcion.ToLower() == dto.Descripcion.ToLower() && e.Activo);
                if (exists.Any())
                {
                    return Conflict(new PagedResult<ConceptoResponse>
                    {
                        Success = false,
                        Message = "Ya existe un concepto con esa descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                var entity = _mapper.Map<Concepto>(dto);
                await _repository.AddAsync(entity);

                return CreatedAtAction(nameof(GetById), new { id = entity.PkidConcepto },
                    new PagedResult<ConceptoResponse>
                    {
                        Success = true,
                        Message = "Concepto creado correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<ConceptoResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<ConceptoResponse>>> Update(int id, [FromBody] ConceptoResponse response)
        {
            try
            {
                var entity = await _repository.GetByIdAsync(id);
                if (entity == null)
                    return NotFound(new PagedResult<ConceptoResponse>
                    {
                        Success = false,
                        Message = $"Concepto con ID {id} no encontrado",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    });

                var dto = _mapper.Map<ConceptoDto>(response);
                dto.PkidConcepto = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.UtcNow;

                var duplicate = await _repository.GetAllWithIncludesAsync(e => e.Descripcion.ToLower() == dto.Descripcion.ToLower() && e.PkidConcepto != id && e.Activo);
                if (duplicate.Any())
                {
                    return Conflict(new PagedResult<ConceptoResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro concepto con esa descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                _mapper.Map(dto, entity);
                entity.FechaModificacion = dto.FechaModificacion;
                entity.UsuarioModificacion = dto.UsuarioModificacion;
                await _repository.UpdateAsync(entity);

                return Ok(new PagedResult<ConceptoResponse>
                {
                    Success = true,
                    Message = "Concepto actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<ConceptoResponse>
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
                        Message = $"Concepto con ID {id} no encontrado",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    });

                await _repository.DeleteAsync(id);
                return Ok(new PagedResult<bool>
                {
                    Success = true,
                    Message = "Concepto eliminado correctamente",
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
        public async Task<ActionResult<PagedResult<ConceptoResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            try
            {
                var query = _context.VwConceptos.AsQueryable();

                if (!string.IsNullOrWhiteSpace(request.Filtro))
                {
                    var f = request.Filtro;
                    query = query.Where(e => e.Descripcion.Contains(f) || e.Clave.Contains(f) || e.CapituloDescripcion.Contains(f));
                }

                if (!string.IsNullOrEmpty(request.SortLabel))
                {
                    var isAscending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                    query = request.SortLabel switch
                    {
                        "PkidConcepto" => isAscending ? query.OrderBy(e => e.PkidConcepto) : query.OrderByDescending(e => e.PkidConcepto),
                        "Clave" => isAscending ? query.OrderBy(e => e.Clave) : query.OrderByDescending(e => e.Clave),
                        "Descripcion" => isAscending ? query.OrderBy(e => e.Descripcion) : query.OrderByDescending(e => e.Descripcion),
                        "CapituloDescripcion" => isAscending ? query.OrderBy(e => e.CapituloDescripcion) : query.OrderByDescending(e => e.CapituloDescripcion),
                        "CapituloClave" => isAscending ? query.OrderBy(e => e.CapituloClave) : query.OrderByDescending(e => e.CapituloClave),
                        "Activo" => isAscending ? query.OrderBy(e => e.Activo) : query.OrderByDescending(e => e.Activo),
                        _ => query.OrderBy(e => e.Descripcion)
                    };
                }
                else
                {
                    query = query.OrderBy(e => e.Descripcion);
                }

                var totalItems = await query.CountAsync();
                var items = await query
                    .Skip((request.Page - 1) * request.PageSize)
                    .Take(request.PageSize)
                    .ToListAsync();

                return Ok(new PagedResult<ConceptoResponse>
                {
                    Items = _mapper.Map<List<ConceptoResponse>>(items),
                    TotalCount = totalItems,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetAllPaginado de Concepto");
                return Ok(new PagedResult<ConceptoResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                });
            }
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<ConceptoResponse>>> Buscar([FromBody] BusquedaRequest request)
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
