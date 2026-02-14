using AutoMapper;
using EG.Business.Services;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class EstadoController : ControllerBase
    {
        private readonly GenericService<Estado, EstadoDto, EstadoResponse> _service;
        private readonly IMapper _mapper;

        public EstadoController(
            GenericService<Estado, EstadoDto, EstadoResponse> service,
            IMapper mapper)
        {
            _service = service;
            _mapper = mapper;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<EstadoResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<EstadoResponse>
            {
                Success = true,
                Message = "Estado obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<EstadoResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id, idPropertyName: "PKIdEstado");
            if (result == null)
                return NotFound(new PagedResult<EstadoResponse>
                {
                    Success = false,
                    Message = "Estado no encontrada",
                    Code = "NOTFOUND_EMPRESA",
                    TotalCount = 0
                });

            return Ok(new PagedResult<EstadoResponse>
            {
                Success = true,
                Message = "Estado encontrada",
                Code = "SUCCESS",
                Data = result,
                Items = new List<EstadoResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult> Create([FromBody] EstadoDto estadoDto)
        {
            await _service.AddAsync(estadoDto);
            return Ok();
        }

        [HttpPut("{id}")]
        public async Task<ActionResult> Update(int id, [FromBody] EstadoDto estadoDto)
        {
            await _service.UpdateAsync(id, estadoDto);
            return Ok();
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            await _service.DeleteAsync(id);
            return Ok();
        }
    }
}