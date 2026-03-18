using AutoMapper;
using EG.ApiCore.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;
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
        private readonly IUserContextService _userContext;

        public EstadoController(
            GenericService<Estado, EstadoDto, EstadoResponse> service,
            IMapper mapper,
            IUserContextService userContext)
        {
            _service = service;
            _mapper = mapper;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<EstadoResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<EstadoResponse>
            {
                Success = true,
                Message = "Estados obtenidos correctamente",
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
                    Message = "Estado no encontrado",
                    Code = "NOTFOUND_ESTADO",
                    TotalCount = 0
                });

            return Ok(new PagedResult<EstadoResponse>
            {
                Success = true,
                Message = "Estado encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<EstadoResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<EstadoResponse>>> Create([FromBody] EstadoResponse response)
        {
            try
            {
                var dto = _mapper.Map<EstadoDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;

                await _service.AddAsync(dto);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidEstado },
                    new PagedResult<EstadoResponse>
                    {
                        Success = true,
                        Message = "Estado creado correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<EstadoResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<EstadoResponse>>> Update(int id, [FromBody] EstadoResponse response)
        {
            try
            {
                var dto = _mapper.Map<EstadoDto>(response);
                dto.PkidEstado = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<EstadoResponse>
                {
                    Success = true,
                    Message = "Estado actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<EstadoResponse>
                {
                    Success = false,
                    Message = $"Estado con ID {id} no encontrado",
                    Code = "NOTFOUND_ESTADO",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<EstadoResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
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
                    Message = "Estado eliminado correctamente",
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
                    Message = $"Estado con ID {id} no encontrado",
                    Code = "NOTFOUND_ESTADO",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Error al eliminar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }
    }
}
