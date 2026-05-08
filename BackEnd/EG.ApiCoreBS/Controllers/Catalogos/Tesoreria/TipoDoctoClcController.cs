using EG.ApiCoreBS.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using AutoMapper;
using EG.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Controllers.Catalogos.Tesoreria
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class TipoDoctoClcController : ControllerBase
    {
        private readonly ILogger<TipoDoctoClcController> _logger;
        private readonly IRepository<TipoDoctoClc> _repository;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContextService;

        public TipoDoctoClcController(
            ILogger<TipoDoctoClcController> logger,
            IRepository<TipoDoctoClc> repository,
            IMapper mapper,
            IUserContextService userContextService)
        {
            _logger = logger;
            _repository = repository;
            _mapper = mapper;
            _userContextService = userContextService;
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<TipoDoctoClcResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var query = _repository.QueryWithIncludes(x => true);

            if (!string.IsNullOrWhiteSpace(request.Filtro))
            {
                var f = request.Filtro;
                query = query.Where(e => e.Clave.Contains(f) || e.Nombre.Contains(f));
            }

            if (!string.IsNullOrEmpty(request.SortLabel))
            {
                var isAscending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                query = request.SortLabel switch
                {
                    "PkidTipoDoctoClc" => isAscending ? query.OrderBy(e => e.PkidTipoDoctoClc) : query.OrderByDescending(e => e.PkidTipoDoctoClc),
                    "Clave" => isAscending ? query.OrderBy(e => e.Clave) : query.OrderByDescending(e => e.Clave),
                    "Nombre" => isAscending ? query.OrderBy(e => e.Nombre) : query.OrderByDescending(e => e.Nombre),
                    "TipoRecurso" => isAscending ? query.OrderBy(e => e.TipoRecurso) : query.OrderByDescending(e => e.TipoRecurso),
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

            return Ok(new PagedResult<TipoDoctoClcResponse>
            {
                Items = _mapper.Map<List<TipoDoctoClcResponse>>(items),
                TotalCount = totalItems,
                Success = true,
                Message = "OK",
                Code = "SUCCESS"
            });
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) return NotFound();
            var response = _mapper.Map<TipoDoctoClcResponse>(entity);
            return Ok(response);
        }

        [HttpPost]
        [Authorize(Policy = "Tesoreria_Tipo_Docto_CLC_new")]
        public async Task<IActionResult> Create([FromBody] TipoDoctoClcDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            var entity = _mapper.Map<TipoDoctoClc>(dto);
            entity.FechaCreacion = DateTime.UtcNow;
            entity.UsuarioCreacion = _userContextService.GetCurrentUserId();
            await _repository.AddAsync(entity);
            var response = _mapper.Map<TipoDoctoClcResponse>(entity);
            return CreatedAtAction(nameof(GetById), new { id = entity.PkidTipoDoctoClc }, response);
        }

        [HttpPut("{id}")]
        [Authorize(Policy = "Tesoreria_Tipo_Docto_CLC_update")]
        public async Task<IActionResult> Update(int id, [FromBody] TipoDoctoClcDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) return NotFound();
            _mapper.Map(dto, entity);
            entity.FechaModificacion = DateTime.UtcNow;
            entity.UsuarioModificacion = _userContextService.GetCurrentUserId();
            await _repository.UpdateAsync(entity);
            var response = _mapper.Map<TipoDoctoClcResponse>(entity);
            return Ok(response);
        }

        [HttpDelete("{id}")]
        [Authorize(Policy = "Tesoreria_Tipo_Docto_CLC_delete")]
        public async Task<IActionResult> Delete(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) return NotFound();
            await _repository.DeleteAsync(id);
            return NoContent();
        }
    }
}
