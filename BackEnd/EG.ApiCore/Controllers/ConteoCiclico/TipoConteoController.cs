using AutoMapper;
using EG.ApiCore.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.ConteoCiclico
{
    [ApiController]
    [Route("api/[controller]")]
    public class TipoConteoController : ControllerBase
    {
        private readonly GenericService<TipoConteo, TipoConteoDto, TipoConteoResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public TipoConteoController(
            GenericService<TipoConteo, TipoConteoDto, TipoConteoResponse> service,
            IMapper mapper,
            IUserContextService userContext)
        {
            _service = service;
            _mapper = mapper;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<TipoConteoResponse>>> GetAllAsync()
        {
            try
            {
                var result = await _service.GetAllAsync();
                return Ok(new PagedResult<TipoConteoResponse>
                {
                    Success = true,
                    Message = "Tipo de Conteo obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = result.ToList(),
                    TotalCount = result.Count()
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new PagedResult<TipoConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<TipoConteoResponse>>> GetById(int id)
        {
            try
            {
                var result = await _service.GetByIdAsync(id, idPropertyName: "PkidTipoConteo");
                if (result == null)
                {
                    return NotFound(new PagedResult<TipoConteoResponse>
                    {
                        Success = false,
                        Message = "Tipo de conteo no encontrado",
                        Code = "NOT_FOUND"
                    });
                }

                return Ok(new PagedResult<TipoConteoResponse>
                {
                    Success = true,
                    Message = "Tipo de conteo encontrado",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<TipoConteoResponse> { result },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<TipoConteoResponse>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
        {
            try
            {
                var result = await _service.GetAllPaginadoAsync(pageRequest);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                });
            }
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<TipoConteoResponse>>> Create([FromBody] TipoConteoResponse response)
        {
            try
            {
                var dto = _mapper.Map<TipoConteoDto>(response);
                await _service.AddAsync(dto);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidTipoConteo }, new PagedResult<TipoConteoResponse>
                {
                    Success = true,
                    Message = "Tipo de conteo creado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoConteoResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR"
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<TipoConteoResponse>>> Update(int id, [FromBody] TipoConteoResponse response)
        {
            try
            {
                var dto = _mapper.Map<TipoConteoDto>(response);
                dto.PkidTipoConteo = id;

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<TipoConteoResponse>
                {
                    Success = true,
                    Message = "Tipo de conteo actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<TipoConteoResponse>
                {
                    Success = false,
                    Message = $"Tipo de conteo con ID {id} no encontrado",
                    Code = "NOT_FOUND"
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoConteoResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar: {ex.Message}",
                    Code = "ERROR"
                });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            try
            {
                await _service.DeleteAsync(id);
                return Ok(new PagedResult<bool>
                {
                    Success = true,
                    Message = "Tipo de conteo eliminado correctamente",
                    Code = "SUCCESS",
                    Data = true,
                    Items = new List<bool> { true },
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Tipo de conteo con ID {id} no encontrado",
                    Code = "NOT_FOUND"
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Error al eliminar: {ex.Message}",
                    Code = "ERROR"
                });
            }
        }
    }
}
