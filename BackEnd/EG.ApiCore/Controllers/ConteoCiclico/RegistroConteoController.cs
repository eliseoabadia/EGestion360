using AutoMapper;
using EG.Business.Services;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.ConteoCiclico
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class RegistroConteoController : ControllerBase
    {
        private readonly GenericService<RegistroConteo, RegistroConteoDto, RegistroConteoResponse> _service;
        private readonly IMapper _mapper;

        public RegistroConteoController(
            GenericService<RegistroConteo, RegistroConteoDto, RegistroConteoResponse> service,
            IMapper mapper)
        {
            _service = service;
            _mapper = mapper;
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<RegistroConteoResponse>>> Add([FromBody] RegistroConteoResponse viewDto)
        {
            try
            {
                if (viewDto == null)
                    return BadRequest(new { success = false, message = "Datos requeridos" });

                var dto = _mapper.Map<RegistroConteoDto>(viewDto);
                await _service.AddAsync(dto);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidRegistroConteo },
                    new PagedResult<RegistroConteoResponse>
                    {
                        Success = true,
                        Message = "Conteo registrado",
                        Code = "SUCCESS"
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id, idPropertyName: "PKIdRegistroConteo");
            return Ok(result);
        }
    }
}
