using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using AutoMapper;
using EG.Domain.Interfaces;
using EG.ApiCoreBS.Services;

namespace EG.ApiCoreBS.Controllers.Catalogos.Presupuestales
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class FnController : ControllerBase
    {
        private readonly ILogger<FnController> _logger;
        private readonly IRepository<Fn> _repository;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContextService;

        public FnController(
            ILogger<FnController> logger,
            IRepository<Fn> repository,
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
            var all = await _repository.GetAllAsync();
            // Filtrar solo los registros activos
            var activos = all.Where(x => x.Activo).ToList();
            var result = new { Items = activos.Skip((page - 1) * pageSize).Take(pageSize), TotalCount = activos.Count, Page = page, PageSize = pageSize };
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null || !entity.Activo) return NotFound();
            var response = _mapper.Map<FnResponse>(entity);
            return Ok(response);
        }

        [HttpPost]
        [Authorize(Policy = "Presupuestales_Finalidad_new")]
        public async Task<IActionResult> Create([FromBody] FnDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var entity = _mapper.Map<Fn>(dto);
            entity.FechaCreacion = DateTime.UtcNow;
            entity.UsuarioCreacion = _userContextService.GetCurrentUserId();

            await _repository.AddAsync(entity);
            // IRepository guarda autom�ticamente

            var response = _mapper.Map<FnResponse>(entity);
            return CreatedAtAction(nameof(GetById), new { id = entity.PkidFn }, response);
        }

        [HttpPut("{id}")]
        [Authorize(Policy = "Presupuestales_Finalidad_update")]
        public async Task<IActionResult> Update(int id, [FromBody] FnDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) return NotFound();

            _mapper.Map(dto, entity);
            entity.FechaModificacion = DateTime.UtcNow;
            entity.UsuarioModificacion = _userContextService.GetCurrentUserId();

            await _repository.UpdateAsync(entity);
            // IRepository guarda autom�ticamente

            var response = _mapper.Map<FnResponse>(entity);
            return Ok(response);
        }

        [HttpDelete("{id}")]
        [Authorize(Policy = "Presupuestales_Finalidad_delete")]
        public async Task<IActionResult> Delete(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) return NotFound();

            await _repository.DeleteAsync(id);
            // IRepository guarda autom�ticamente

            return NoContent();
        }
    }
}

