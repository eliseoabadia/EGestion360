using EG.ApiCoreBS.Services;
using EG.ApiCoreBS.Helpers;
using EG.Domain.Interfaces;
using AutoMapper;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Controllers.Almacen
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class UnidadesController : ControllerBase
    {
        private readonly ILogger<UnidadesController> _logger;
        private readonly IRepository<Unidade> _repository;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContextService;

        public UnidadesController(
            ILogger<UnidadesController> logger,
            IRepository<Unidade> repository,
            IMapper mapper,
            IUserContextService userContextService)
        {
            _logger = logger;
            _repository = repository;
            _mapper = mapper;
            _userContextService = userContextService;
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<UnidadeResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var query = _repository.QueryWithIncludes(x => true);

            if (!string.IsNullOrWhiteSpace(request.Filtro))
            {
                query = query.Where(e => e.Descripcion.Contains(request.Filtro));
            }

            if (!string.IsNullOrEmpty(request.SortLabel))
            {
                var isAscending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                query = request.SortLabel switch
                {
                    "PkidUnidades" => isAscending ? query.OrderBy(e => e.PkidUnidades) : query.OrderByDescending(e => e.PkidUnidades),
                    "Descripcion" => isAscending ? query.OrderBy(e => e.Descripcion) : query.OrderByDescending(e => e.Descripcion),
                    "Activo" => isAscending ? query.OrderBy(e => e.Activo) : query.OrderByDescending(e => e.Activo),
                    "FechaCreacion" => isAscending ? query.OrderBy(e => e.FechaCreacion) : query.OrderByDescending(e => e.FechaCreacion),
                    "UsuarioCreacion" => isAscending ? query.OrderBy(e => e.UsuarioCreacion) : query.OrderByDescending(e => e.UsuarioCreacion),
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

            return Ok(new PagedResult<UnidadeResponse>
            {
                Items = _mapper.Map<List<UnidadeResponse>>(items),
                TotalCount = totalItems,
                Success = true,
                Message = "OK",
                Code = "SUCCESS"
            });
        }

        [HttpGet]
        public async Task<IActionResult> GetAllPaginado(int page = 1, int pageSize = 10, string? sortBy = null, string? sortDirection = null, string? filter = null)
        {
            var all = await _repository.GetAllAsync();

            if (!string.IsNullOrEmpty(sortBy))
            {
                var isAscending = string.IsNullOrEmpty(sortDirection) || sortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                all = sortBy switch
                {
                    "PkidUnidades" => isAscending ? all.OrderBy(e => e.PkidUnidades) : all.OrderByDescending(e => e.PkidUnidades),
                    "Descripcion" => isAscending ? all.OrderBy(e => e.Descripcion) : all.OrderByDescending(e => e.Descripcion),
                    "Activo" => isAscending ? all.OrderBy(e => e.Activo) : all.OrderByDescending(e => e.Activo),
                    "FechaCreacion" => isAscending ? all.OrderBy(e => e.FechaCreacion) : all.OrderByDescending(e => e.FechaCreacion),
                    "UsuarioCreacion" => isAscending ? all.OrderBy(e => e.UsuarioCreacion) : all.OrderByDescending(e => e.UsuarioCreacion),
                    _ => all.OrderBy(e => e.Descripcion)
                };
            }
            else
            {
                all = all.OrderBy(e => e.Descripcion);
            }

            var result = new { Items = all.Skip((page - 1) * pageSize).Take(pageSize).ToList(), TotalCount = all.Count(), Page = page, PageSize = pageSize };
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) return NotFound();
            var response = _mapper.Map<UnidadeResponse>(entity);
            return Ok(response);
        }

        [HttpPost]
        [Authorize(Policy = "Almacen_Unidades_new")]
        public async Task<IActionResult> Create([FromBody] UnidadeDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var entity = _mapper.Map<Unidade>(dto);
            entity.FechaCreacion = DateTime.UtcNow;
            entity.UsuarioCreacion = _userContextService.GetCurrentUserId();

            await _repository.AddAsync(entity);
            // IRepository ya guarda cambios

            var response = _mapper.Map<UnidadeResponse>(entity);
            return CreatedAtAction(nameof(GetById), new { id = entity.PkidUnidades }, response);
        }

        [HttpPut("{id}")]
        [Authorize(Policy = "Almacen_Unidades_update")]
        public async Task<IActionResult> Update(int id, [FromBody] UnidadeDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) return NotFound();

            _mapper.Map(dto, entity);
            entity.FechaModificacion = DateTime.UtcNow;
            entity.UsuarioModificacion = _userContextService.GetCurrentUserId();

            await _repository.UpdateAsync(entity);
            // IRepository ya guarda cambios

            var response = _mapper.Map<UnidadeResponse>(entity);
            return Ok(response);
        }

        [HttpDelete("{id}")]
        [Authorize(Policy = "Almacen_Unidades_delete")]
        public async Task<IActionResult> Delete(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) return NotFound();

            await _repository.DeleteAsync(id);
            // IRepository ya guarda cambios

            return NoContent();
        }

        [HttpGet("GetLookup")]
        public async Task<ActionResult<List<LookupItem>>> GetLookup()
        {
            var all = await _repository.GetAllAsync();
            var items = all.Where(u => u.Activo).OrderBy(u => u.Descripcion)
                .Select(u => new LookupItem { Id = u.PkidUnidades, Text = u.Descripcion ?? "" })
                .ToList();
            return Ok(items);
        }

        [HttpGet("GetLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var query = _repository.QueryWithIncludes(u => u.Activo)
                .OrderBy(u => u.Descripcion)
                .Select(u => new LookupItem { Id = u.PkidUnidades, Text = u.Descripcion ?? "" });

            return Ok(await LookupPagingHelper.ToPagedResultAsync(query, page, pageSize, filter));
        }
    }
}









