using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Controllers.Patrimonio
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class GrupoBienController : ControllerBase
    {
        private readonly ILogger<GrupoBienController> _logger;
        private readonly IRepository<GrupoBien> _repository;
        private readonly EGestionContext _context;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public GrupoBienController(
            ILogger<GrupoBienController> logger,
            IRepository<GrupoBien> repository,
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
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> GetAll()
        {
            try
            {
                var items = await _context.VwGrupoBiens.ToListAsync();
                return Ok(new PagedResult<GrupoBienResponse>
                {
                    Items = _mapper.Map<List<GrupoBienResponse>>(items),
                    TotalCount = items.Count,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetAll de GrupoBien");
                return Ok(new PagedResult<GrupoBienResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                });
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> GetById(int id)
        {
            try
            {
                var entity = await _context.VwGrupoBiens.FirstOrDefaultAsync(e => e.PkidGrupoBien == id);
                if (entity == null)
                    return NotFound(new PagedResult<GrupoBienResponse> { Success = false, Message = "Grupo de bien no encontrado", Code = "NOT_FOUND" });

                var response = _mapper.Map<GrupoBienResponse>(entity);
                return Ok(new PagedResult<GrupoBienResponse>
                {
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS",
                    Data = response,
                    Items = new List<GrupoBienResponse> { response },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetById de GrupoBien para ID {Id}", id);
                return Ok(new PagedResult<GrupoBienResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                });
            }
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> Create([FromBody] GrupoBienResponse response)
        {
            try
            {
                var dto = _mapper.Map<GrupoBienDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.UtcNow;

                var exists = await _repository.GetAllWithIncludesAsync(e => e.Descripcion.ToLower() == dto.Descripcion.ToLower() && e.Activo);
                if (exists.Any())
                {
                    return Conflict(new PagedResult<GrupoBienResponse>
                    {
                        Success = false,
                        Message = "Ya existe un grupo de bien con esa descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                var entity = _mapper.Map<GrupoBien>(dto);
                await _repository.AddAsync(entity);

                return CreatedAtAction(nameof(GetById), new { id = entity.PkidGrupoBien },
                    new PagedResult<GrupoBienResponse>
                    {
                        Success = true,
                        Message = "Grupo de bien creado correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<GrupoBienResponse> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> Update(int id, [FromBody] GrupoBienResponse response)
        {
            try
            {
                var entity = await _repository.GetByIdAsync(id);
                if (entity == null)
                    return NotFound(new PagedResult<GrupoBienResponse> { Success = false, Message = "Grupo de bien no encontrado", Code = "NOT_FOUND" });

                var dto = _mapper.Map<GrupoBienDto>(response);
                dto.PkidGrupoBien = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.UtcNow;

                var duplicate = await _repository.GetAllWithIncludesAsync(e => e.Descripcion.ToLower() == dto.Descripcion.ToLower() && e.PkidGrupoBien != id && e.Activo);
                if (duplicate.Any())
                {
                    return Conflict(new PagedResult<GrupoBienResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro grupo de bien con esa descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                _mapper.Map(dto, entity);
                entity.FechaModificacion = dto.FechaModificacion;
                entity.UsuarioModificacion = dto.UsuarioModificacion;
                await _repository.UpdateAsync(entity);

                return Ok(new PagedResult<GrupoBienResponse>
                {
                    Success = true,
                    Message = "Grupo de bien actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<GrupoBienResponse> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            try
            {
                var entity = await _repository.GetByIdAsync(id);
                if (entity == null)
                    return NotFound(new PagedResult<bool> { Success = false, Message = "Grupo de bien no encontrado", Code = "NOT_FOUND" });

                await _repository.DeleteAsync(id);
                return Ok(new PagedResult<bool> { Success = true, Message = "Grupo de bien eliminado correctamente", Code = "SUCCESS", Items = new List<bool> { true }, TotalCount = 1 });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<bool> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            try
            {
                var query = _context.VwGrupoBiens.AsQueryable();

                if (!string.IsNullOrWhiteSpace(request.Filtro))
                {
                    var f = request.Filtro;
                    query = query.Where(e =>
                        e.Descripcion.Contains(f) ||
                        e.FamiliaDescripcion.Contains(f) ||
                        e.FamiliaClave.Contains(f));
                }

                if (!string.IsNullOrEmpty(request.SortLabel))
                {
                    var isAscending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                    query = request.SortLabel switch
                    {
                        "PkidGrupoBien" => isAscending ? query.OrderBy(e => e.PkidGrupoBien) : query.OrderByDescending(e => e.PkidGrupoBien),
                        "GrupoBienDescripcion" => isAscending ? query.OrderBy(e => e.Descripcion) : query.OrderByDescending(e => e.Descripcion),
                        "FamiliaDescripcion" => isAscending ? query.OrderBy(e => e.FamiliaDescripcion) : query.OrderByDescending(e => e.FamiliaDescripcion),
                        "FamiliaClave" => isAscending ? query.OrderBy(e => e.FamiliaClave) : query.OrderByDescending(e => e.FamiliaClave),
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

                return Ok(new PagedResult<GrupoBienResponse>
                {
                    Items = _mapper.Map<List<GrupoBienResponse>>(items),
                    TotalCount = totalItems,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetAllPaginado de GrupoBien");
                return Ok(new PagedResult<GrupoBienResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                });
            }
        }

        [HttpGet("GetGrupoBien")]
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> GetGrupoBien()
        {
            var items = await _context.GrupoBiens
                .Where(g => (g.Clave ?? 0) > 2000 && g.Activo)
                .OrderBy(g => g.ClaveCucop)
                .Select(g => new GrupoBienResponse
                {
                    PkidGrupoBien = g.PkidGrupoBien,
                    GrupoBienDescripcion = g.Descripcion,
                    GrupoBienClave = g.Clave,
                    ClaveAn = g.ClaveAn,
                    CabmAct = g.CabmAct,
                    ClaveCucop = g.ClaveCucop,
                    Activo = g.Activo
                })
                .ToListAsync();

            return Ok(new PagedResult<GrupoBienResponse>
            {
                Success = true,
                Message = "OK",
                Code = "SUCCESS",
                Items = items,
                TotalCount = items.Count
            });
        }

        [HttpGet("GetLookup")]
        public async Task<ActionResult<List<LookupItem>>> GetLookup()
        {
            var items = await _context.GrupoBiens
                .Where(g => (g.Clave ?? 0) > 2000 && g.Activo)
                .OrderBy(g => g.ClaveAn)
                .Select(g => new LookupItem
                {
                    Id = g.PkidGrupoBien,
                    Text = (g.ClaveAn ?? "") + " / " + (g.CabmAct ?? "") + " / " + (g.Descripcion ?? "")
                })
                .ToListAsync();
            return Ok(items);
        }
    }
}
