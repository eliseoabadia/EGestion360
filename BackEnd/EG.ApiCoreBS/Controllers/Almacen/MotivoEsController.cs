using EG.ApiCoreBS.Services;
using EG.Common.GenericModel;
using EG.Domain.Interfaces;
using AutoMapper;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace EG.ApiCoreBS.Controllers.Almacen
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class MotivoEsController : ControllerBase
    {
        private readonly ILogger<MotivoEsController> _logger;
        private readonly IRepository<Motivo> _repository;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContextService;

        public MotivoEsController(
            ILogger<MotivoEsController> logger,
            IRepository<Motivo> repository,
            IMapper mapper,
            IUserContextService userContextService)
        {
            _logger = logger;
            _repository = repository;
            _mapper = mapper;
            _userContextService = userContextService;
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<MotivoEsResponse>>> GetAllPaginado([FromBody] PagedRequest request)
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
                    "PkidMotivoEs" => isAscending ? query.OrderBy(e => e.PkidMotivoEs) : query.OrderByDescending(e => e.PkidMotivoEs),
                    "Descripcion" => isAscending ? query.OrderBy(e => e.Descripcion) : query.OrderByDescending(e => e.Descripcion),
                    "AplicaEntrada" => isAscending ? query.OrderBy(e => e.AplicaEntrada) : query.OrderByDescending(e => e.AplicaEntrada),
                    "AplicaSalida" => isAscending ? query.OrderBy(e => e.AplicaSalida) : query.OrderByDescending(e => e.AplicaSalida),
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

            return Ok(new PagedResult<MotivoEsResponse>
            {
                Items = _mapper.Map<List<MotivoEsResponse>>(items),
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
                    "PkidMotivoEs" => isAscending ? all.OrderBy(e => e.PkidMotivoEs) : all.OrderByDescending(e => e.PkidMotivoEs),
                    "Descripcion" => isAscending ? all.OrderBy(e => e.Descripcion) : all.OrderByDescending(e => e.Descripcion),
                    "AplicaEntrada" => isAscending ? all.OrderBy(e => e.AplicaEntrada) : all.OrderByDescending(e => e.AplicaEntrada),
                    "AplicaSalida" => isAscending ? all.OrderBy(e => e.AplicaSalida) : all.OrderByDescending(e => e.AplicaSalida),
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
            var response = _mapper.Map<MotivoEsResponse>(entity);
            return Ok(response);
        }

        [HttpPost]
        [Authorize(Policy = "Almacen_Movimiento_Entrada_Salida_new")]
        public async Task<IActionResult> Create([FromBody] MotivoEsDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var entity = _mapper.Map<Motivo>(dto);
            entity.FechaCreacion = DateTime.UtcNow;
            entity.UsuarioCreacion = _userContextService.GetCurrentUserId();

            await _repository.AddAsync(entity);
            // IRepository ya guarda cambios

            var response = _mapper.Map<MotivoEsResponse>(entity);
            return CreatedAtAction(nameof(GetById), new { id = entity.PkidMotivoEs }, response);
        }

        [HttpPut("{id}")]
        [Authorize(Policy = "Almacen_Movimiento_Entrada_Salida_update")]
        public async Task<IActionResult> Update(int id, [FromBody] MotivoEsDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) return NotFound();

            _mapper.Map(dto, entity);
            entity.FechaModificacion = DateTime.UtcNow;
            entity.UsuarioModificacion = _userContextService.GetCurrentUserId();

            await _repository.UpdateAsync(entity);
            // IRepository ya guarda cambios

            var response = _mapper.Map<MotivoEsResponse>(entity);
            return Ok(response);
        }

        [HttpDelete("{id}")]
        [Authorize(Policy = "Almacen_Movimiento_Entrada_Salida_delete")]
        public async Task<IActionResult> Delete(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) return NotFound();

            await _repository.DeleteAsync(id);
            // IRepository ya guarda cambios

            return NoContent();
        }
    }
}









