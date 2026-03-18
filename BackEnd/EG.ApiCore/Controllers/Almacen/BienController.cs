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
    public class BienController : ControllerBase
    {
        private readonly GenericService<Bien, BienDto, BienResponse> _service;
        private readonly GenericService<VwBien, BienDto, BienResponse> _serviceView;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public BienController(
            GenericService<Bien, BienDto, BienResponse> service,
            GenericService<VwBien, BienDto, BienResponse> serviceView,
            IMapper mapper,
            IUserContextService userContext)
        {
            _service = service;
            _serviceView = serviceView;
            _mapper = mapper;
            _userContext = userContext;

            ConfigureService();
        }

        private void ConfigureService()
        {
            // VwBien is a view - it doesn't have navigation properties
            // The serviceView is used for reading data only
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<BienResponse>>> GetAll()
        {
            var result = await _serviceView.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<BienResponse>>> GetById(int id)
        {
            try
            {
                var result = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidBien");
                if (result == null)
                {
                    return NotFound(new PagedResult<BienResponse>
                    {
                        Success = false,
                        Message = "Bien no encontrado",
                        Code = "NOT_FOUND"
                    });
                }

                return Ok(new PagedResult<BienResponse>
                {
                    Success = true,
                    Message = "Bien encontrado",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<BienResponse> { result },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<BienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<BienResponse>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
        {
            try
            {
                _serviceView.ClearConfiguration();
                ConfigureService();

                var result = await _serviceView.GetAllPaginadoAsync(pageRequest);
                return Ok(new PagedResult<BienResponse>
                {
                    Success = true,
                    Items = result.Items,
                    TotalCount = result.TotalCount
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<BienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                });
            }
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<BienResponse>>> Create([FromBody] BienResponse response)
        {
            try
            {
                var dto = _mapper.Map<BienDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;

                await _service.AddAsync(dto);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidBien }, new PagedResult<BienResponse>
                {
                    Success = true,
                    Message = "Bien creado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<BienResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR"
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<BienResponse>>> Update(int id, [FromBody] BienResponse response)
        {
            try
            {
                var dto = _mapper.Map<BienDto>(response);
                dto.PkidBien = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<BienResponse>
                {
                    Success = true,
                    Message = "Bien actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<BienResponse>
                {
                    Success = false,
                    Message = $"Bien con ID {id} no encontrado",
                    Code = "NOT_FOUND"
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<BienResponse>
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
                    Message = "Bien eliminado correctamente",
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
                    Message = $"Bien con ID {id} no encontrado",
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
