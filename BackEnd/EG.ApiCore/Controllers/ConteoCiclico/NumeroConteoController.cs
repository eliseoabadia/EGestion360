using AutoMapper;
using EG.ApiCore.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.ConteoCiclico
{
    [ApiController]
    [Route("api/[controller]")]
    public class NumeroConteoController : ControllerBase
    {
        // Servicio para la vista (consultas)
        private readonly GenericService<VwPeriodoConteo, NumeroConteoResponse, NumeroConteoResponse> _viewService;
        // Servicio para la entidad (operaciones de escritura)
        private readonly GenericService<PeriodoConteo, NumeroConteoDto, NumeroConteoResponse> _entityService;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public NumeroConteoController(
            GenericService<VwPeriodoConteo, NumeroConteoResponse, NumeroConteoResponse> viewService,
            GenericService<PeriodoConteo, NumeroConteoDto, NumeroConteoResponse> entityService,
            IMapper mapper,
            IUserContextService userContext)
        {
            _viewService = viewService;
            _entityService = entityService;
            _mapper = mapper;
            _userContext = userContext;
        }

        // ============================
        // MÉTODOS DE CONSULTA (VISTA)
        // ============================

        [HttpGet]
        public async Task<ActionResult<PagedResult<NumeroConteoResponse>>> GetAll()
        {
            var result = await _viewService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<NumeroConteoResponse>>> GetById(int id)
        {
            try
            {
                var result = await _viewService.GetByIdAsync(id, idPropertyName: "PkidPeriodoConteo");
                if (result == null)
                {
                    return NotFound(new PagedResult<NumeroConteoResponse>
                    {
                        Success = false,
                        Message = "Periodo de conteo no encontrado",
                        Code = "NOT_FOUND"
                    });
                }

                return Ok(new PagedResult<NumeroConteoResponse>
                {
                    Success = true,
                    Message = "Periodo de conteo encontrado",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<NumeroConteoResponse> { result },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<NumeroConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<NumeroConteoResponse>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
        {
            try
            {
                var result = await _viewService.GetAllPaginadoAsync(pageRequest);
                return Ok(new PagedResult<NumeroConteoResponse>
                {
                    Success = true,
                    Message = "Empresas obtenidas correctamente",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<NumeroConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                });
            }
        }

        // ============================
        // OPERACIONES CRUD (ENTIDAD)
        // ============================

        [HttpPost]
        public async Task<ActionResult<PagedResult<NumeroConteoResponse>>> Create([FromBody] NumeroConteoResponse response)
        {
            try
            {
                // Mapear de Response a DTO de escritura
                var dto = _mapper.Map<NumeroConteoDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                await _entityService.AddAsync(dto);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidPeriodoConteo }, new PagedResult<NumeroConteoResponse>
                {
                    Success = true,
                    Message = "Periodo de conteo creado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<NumeroConteoResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR"
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<NumeroConteoResponse>>> Update(int id, [FromBody] NumeroConteoResponse response)
        {
            try
            {
                // Mapear de Response a DTO de escritura
                var dto = _mapper.Map<NumeroConteoDto>(response);
                dto.PkidPeriodoConteo = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                await _entityService.UpdateAsync(id, dto);

                return Ok(new PagedResult<NumeroConteoResponse>
                {
                    Success = true,
                    Message = "Periodo de conteo actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<NumeroConteoResponse>
                {
                    Success = false,
                    Message = $"Periodo de conteo con ID {id} no encontrado",
                    Code = "NOT_FOUND"
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<NumeroConteoResponse>
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
                await _entityService.DeleteAsync(id);
                return Ok(new PagedResult<bool>
                {
                    Success = true,
                    Message = "Periodo de conteo eliminado correctamente",
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
                    Message = $"Periodo de conteo con ID {id} no encontrado",
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