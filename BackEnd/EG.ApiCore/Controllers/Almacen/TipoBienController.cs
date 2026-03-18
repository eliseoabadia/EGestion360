using AutoMapper;
using EG.ApiCore.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.Almacen
{
    [ApiController]
    [Route("api/[controller]")]
    public class TipoBienController : ControllerBase
    {
        private readonly GenericService<TipoBien, TipoBienDto, TipoBienResponse> _service;
        private readonly GenericService<VwTipoBienConteo, TipoBienDto, TipoBienResponse> _serviceView;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public TipoBienController(
            GenericService<TipoBien, TipoBienDto, TipoBienResponse> service,
            GenericService<VwTipoBienConteo, TipoBienDto, TipoBienResponse> serviceView,
            IMapper mapper,
            IUserContextService userContext)
        {
            _service = service;
            _serviceView = serviceView;
            _mapper = mapper;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<TipoBienResponse>>> GetAll()
        {
            var result = await _serviceView.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<TipoBienResponse>>> GetById(int id)
        {
            try
            {
                var result = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidTipoBien");
                if (result == null)
                {
                    return NotFound(new PagedResult<TipoBienResponse>
                    {
                        Success = false,
                        Message = "Tipo de bien no encontrado",
                        Code = "NOT_FOUND"
                    });
                }

                return Ok(new PagedResult<TipoBienResponse>
                {
                    Success = true,
                    Message = "Tipo de bien encontrado",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<TipoBienResponse> { result },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoBienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<TipoBienResponse>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
        {
            try
            {
                var result = await _serviceView.GetAllPaginadoAsync(pageRequest);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoBienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                });
            }
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<TipoBienResponse>>> Create([FromBody] TipoBienResponse response)
        {
            try
            {
                var dto = _mapper.Map<TipoBienDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;

                await _service.AddAsync(dto);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidTipoBien }, new PagedResult<TipoBienResponse>
                {
                    Success = true,
                    Message = "Tipo de bien creado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoBienResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR"
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<TipoBienResponse>>> Update(int id, [FromBody] TipoBienResponse response)
        {
            try
            {
                var dto = _mapper.Map<TipoBienDto>(response);
                dto.PkidTipoBien = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<TipoBienResponse>
                {
                    Success = true,
                    Message = "Tipo de bien actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<TipoBienResponse>
                {
                    Success = false,
                    Message = $"Tipo de bien con ID {id} no encontrado",
                    Code = "NOT_FOUND"
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoBienResponse>
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
                    Message = "Tipo de bien eliminado correctamente",
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
                    Message = $"Tipo de bien con ID {id} no encontrado",
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
