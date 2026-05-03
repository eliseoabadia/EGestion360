using EG.ApiCoreBS.Services;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using AutoMapper;
using EG.Domain.Interfaces;

namespace EG.ApiCoreBS.Controllers.Catalogos.Tesoreria
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class TipoCambioController : ControllerBase
    {
        private readonly ILogger<TipoCambioController> _logger;
        private readonly IRepository<TipoCambio> _repository;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContextService;

        public TipoCambioController(
            ILogger<TipoCambioController> logger,
            IRepository<TipoCambio> repository,
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
            // IRepository ya guarda cambios

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
            // IRepository ya guarda cambios

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
            // IRepository ya guarda cambios

            return NoContent();
        }
    }
}







