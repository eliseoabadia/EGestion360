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
    public class TipoCambioController : ControllerBase
    {
        private readonly ILogger<TipoCambioController> _logger;
        private readonly IRepository<TipoCambio> _repository;
        private readonly EGestionContext _context;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContextService;

        public TipoCambioController(
            ILogger<TipoCambioController> logger,
            IRepository<TipoCambio> repository,
            EGestionContext context,
            IMapper mapper,
            IUserContextService userContextService)
        {
            _logger = logger;
            _repository = repository;
            _context = context;
            _mapper = mapper;
            _userContextService = userContextService;
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<TipoCambioResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var query = _context.VwTipoCambios.AsQueryable();

            if (!string.IsNullOrWhiteSpace(request.Filtro))
            {
                var f = request.Filtro;
                query = query.Where(e => e.MonedaDescripcion.Contains(f) || e.MonedaCodigo.Contains(f));
            }

            if (!string.IsNullOrEmpty(request.SortLabel))
            {
                var isAscending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                query = request.SortLabel switch
                {
                    "PkidTipoCambio" => isAscending ? query.OrderBy(e => e.PkidTipoCambio) : query.OrderByDescending(e => e.PkidTipoCambio),
                    "Cantidad" => isAscending ? query.OrderBy(e => e.Cantidad) : query.OrderByDescending(e => e.Cantidad),
                    "Fecha" => isAscending ? query.OrderBy(e => e.Fecha) : query.OrderByDescending(e => e.Fecha),
                    "MonedaDescripcion" => isAscending ? query.OrderBy(e => e.MonedaDescripcion) : query.OrderByDescending(e => e.MonedaDescripcion),
                    "MonedaCodigo" => isAscending ? query.OrderBy(e => e.MonedaCodigo) : query.OrderByDescending(e => e.MonedaCodigo),
                    "Activo" => isAscending ? query.OrderBy(e => e.Activo) : query.OrderByDescending(e => e.Activo),
                    _ => query.OrderBy(e => e.Fecha)
                };
            }
            else
            {
                query = query.OrderByDescending(e => e.Fecha);
            }

            var totalItems = await query.CountAsync();
            var items = await query
                .Skip((request.Page - 1) * request.PageSize)
                .Take(request.PageSize)
                .ToListAsync();

            return Ok(new PagedResult<TipoCambioResponse>
            {
                Items = _mapper.Map<List<TipoCambioResponse>>(items),
                TotalCount = totalItems,
                Success = true,
                Message = "OK",
                Code = "SUCCESS"
            });
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var entity = await _context.VwTipoCambios.FirstOrDefaultAsync(e => e.PkidTipoCambio == id);
            if (entity == null) return NotFound();
            var response = _mapper.Map<TipoCambioResponse>(entity);
            return Ok(response);
        }

        [HttpPost]
        [Authorize(Policy = "Tesoreria_Tipo_Cambio_new")]
        public async Task<IActionResult> Create([FromBody] TipoCambioDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            var entity = _mapper.Map<TipoCambio>(dto);
            entity.FechaCreacion = DateTime.UtcNow;
            entity.UsuarioCreacion = _userContextService.GetCurrentUserId();
            await _repository.AddAsync(entity);
            var response = _mapper.Map<TipoCambioResponse>(entity);
            return CreatedAtAction(nameof(GetById), new { id = entity.PkidTipoCambio }, response);
        }

        [HttpPut("{id}")]
        [Authorize(Policy = "Tesoreria_Tipo_Cambio_update")]
        public async Task<IActionResult> Update(int id, [FromBody] TipoCambioDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) return NotFound();
            _mapper.Map(dto, entity);
            entity.FechaModificacion = DateTime.UtcNow;
            entity.UsuarioModificacion = _userContextService.GetCurrentUserId();
            await _repository.UpdateAsync(entity);
            var response = _mapper.Map<TipoCambioResponse>(entity);
            return Ok(response);
        }

        [HttpDelete("{id}")]
        [Authorize(Policy = "Tesoreria_Tipo_Cambio_delete")]
        public async Task<IActionResult> Delete(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) return NotFound();
            await _repository.DeleteAsync(id);
            return NoContent();
        }
    }
}
