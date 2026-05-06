using EG.ApiCoreBS.Services;
using EG.Domain.Interfaces;
using AutoMapper;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using EG.Domain.DTOs.Responses.ConteoCiclico;

namespace EG.ApiCoreBS.Controllers.Almacen
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class PeriodoConteoController : ControllerBase
    {
        private readonly ILogger<PeriodoConteoController> _logger;
        private readonly IRepository<PeriodoConteo> _repository;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContextService;

        public PeriodoConteoController(
            ILogger<PeriodoConteoController> logger,
            IRepository<PeriodoConteo> repository,
            IMapper mapper,
            IUserContextService userContextService)
        {
            _logger = logger;
            _repository = repository;
            _mapper = mapper;
            _userContextService = userContextService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAllPaginado(int page = 1, int pageSize = 10, string? sortBy = null, string? filter = null)
        {
            var all = await _repository.GetAllAsync(); var result = new { Items = all.Skip((page - 1) * pageSize).Take(pageSize), TotalCount = all.Count(), Page = page, PageSize = pageSize };
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) return NotFound();
            var response = _mapper.Map<PeriodoConteoResponse>(entity);
            return Ok(response);
        }

        [HttpPost]
        [Authorize(Policy = "Almacen_Conteo_Periodo_new")]
        public async Task<IActionResult> Create([FromBody] PeriodoConteoDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var entity = _mapper.Map<PeriodoConteo>(dto);
            entity.FechaCreacion = DateTime.UtcNow;
            entity.UsuarioCreacion = _userContextService.GetCurrentUserId();

            await _repository.AddAsync(entity);
            // IRepository ya guarda cambios

            var response = _mapper.Map<PeriodoConteoResponse>(entity);
            return CreatedAtAction(nameof(GetById), new { id = entity.PkidPeriodoConteo }, response);
        }

        [HttpPut("{id}")]
        [Authorize(Policy = "Almacen_Conteo_Periodo_update")]
        public async Task<IActionResult> Update(int id, [FromBody] PeriodoConteoDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) return NotFound();

            _mapper.Map(dto, entity);
            entity.FechaModificacion = DateTime.UtcNow;
            entity.UsuarioModificacion = _userContextService.GetCurrentUserId();

            await _repository.UpdateAsync(entity);
            // IRepository ya guarda cambios

            var response = _mapper.Map<PeriodoConteoResponse>(entity);
            return Ok(response);
        }

        [HttpDelete("{id}")]
        [Authorize(Policy = "Almacen_Conteo_Periodo_delete")]
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









