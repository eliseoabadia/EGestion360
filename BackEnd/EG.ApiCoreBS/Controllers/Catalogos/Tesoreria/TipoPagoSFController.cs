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
    public class TipoPagoSFController : ControllerBase
    {
        private readonly ILogger<TipoPagoSFController> _logger;
        private readonly IRepository<TipoPagoSf> _repository;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContextService;

        public TipoPagoSFController(
            ILogger<TipoPagoSFController> logger,
            IRepository<TipoPagoSf> repository,
            IMapper mapper,
            IUserContextService userContextService)
        {
            _logger = logger;
            _repository = repository;
            _mapper = mapper;
            _userContextService = userContextService;
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<TipoPagoSFResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var query = _repository.QueryWithIncludes(x => true);

            if (!string.IsNullOrWhiteSpace(request.Filtro))
            {
                var f = request.Filtro;
                query = query.Where(e => e.Descripcion.Contains(f));
            }

            if (!string.IsNullOrEmpty(request.SortLabel))
            {
                var isAscending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                query = request.SortLabel switch
                {
                    "PkidTipoPagoSf" => isAscending ? query.OrderBy(e => e.PkidTipoPagoSf) : query.OrderByDescending(e => e.PkidTipoPagoSf),
                    "Descripcion" => isAscending ? query.OrderBy(e => e.Descripcion) : query.OrderByDescending(e => e.Descripcion),
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

            return Ok(new PagedResult<TipoPagoSFResponse>
            {
                Items = _mapper.Map<List<TipoPagoSFResponse>>(items),
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
            var response = _mapper.Map<TipoPagoSFResponse>(entity);
            return Ok(response);
        }

        [HttpPost]
        [Authorize(Policy = "Tesoreria_Tipo_Pago_SF_new")]
        public async Task<IActionResult> Create([FromBody] TipoPagoSFDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            var entity = _mapper.Map<TipoPagoSf>(dto);
            entity.FechaCreacion = DateTime.UtcNow;
            entity.UsuarioCreacion = _userContextService.GetCurrentUserId();
            await _repository.AddAsync(entity);
            var response = _mapper.Map<TipoPagoSFResponse>(entity);
            return CreatedAtAction(nameof(GetById), new { id = entity.PkidTipoPagoSf }, response);
        }

        [HttpPut("{id}")]
        [Authorize(Policy = "Tesoreria_Tipo_Pago_SF_update")]
        public async Task<IActionResult> Update(int id, [FromBody] TipoPagoSFDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) return NotFound();
            _mapper.Map(dto, entity);
            entity.FechaModificacion = DateTime.UtcNow;
            entity.UsuarioModificacion = _userContextService.GetCurrentUserId();
            await _repository.UpdateAsync(entity);
            var response = _mapper.Map<TipoPagoSFResponse>(entity);
            return Ok(response);
        }

        [HttpDelete("{id}")]
        [Authorize(Policy = "Tesoreria_Tipo_Pago_SF_delete")]
        public async Task<IActionResult> Delete(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) return NotFound();
            await _repository.DeleteAsync(id);
            return NoContent();
        }
    }
}
