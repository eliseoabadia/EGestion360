using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Patrimonio
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class NivelController : ControllerBase
    {
        private readonly GenericService<Nivel, NivelDto, NivelResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public NivelController(
            GenericService<Nivel, NivelDto, NivelResponse> service,
            IMapper mapper,
            IUserContextService userContext)
        {
            _service = service;
            _mapper = mapper;
            _userContext = userContext;
            ConfigureValidations();
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueNivel", async (dto) =>
            {
                var nDto = dto as NivelDto;
                if (nDto == null) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(n => n.Nivel1 == nDto.Nivel1 && n.Activo);
            });

            _service.AddValidationRuleWithId("UniqueNivelUpdate", async (dto, id) =>
            {
                var nDto = dto as NivelDto;
                if (nDto == null || !id.HasValue) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(n => n.Nivel1 == nDto.Nivel1 && n.PkidNivel != id.Value && n.Activo);
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<NivelResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<NivelResponse>
            {
                Success = true,
                Message = "Niveles obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<NivelResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id, idPropertyName: "PkidNivel");
            if (result == null)
                return NotFound(new PagedResult<NivelResponse>
                {
                    Success = false,
                    Message = "Nivel no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            return Ok(new PagedResult<NivelResponse>
            {
                Success = true,
                Message = "Nivel encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<NivelResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<NivelResponse>>> Create([FromBody] NivelResponse response)
        {
            try
            {
                var dto = _mapper.Map<NivelDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                    return Conflict(new PagedResult<NivelResponse>
                    {
                        Success = false,
                        Message = "Ya existe un Nivel activo con ese número",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });

                await _service.AddAsync(dto);
                return CreatedAtAction(nameof(GetById), new { id = dto.PkidNivel },
                    new PagedResult<NivelResponse>
                    {
                        Success = true,
                        Message = "Nivel creado correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<NivelResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<NivelResponse>>> Update(int id, [FromBody] NivelResponse response)
        {
            try
            {
                var dto = _mapper.Map<NivelDto>(response);
                dto.PkidNivel = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                    return Conflict(new PagedResult<NivelResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro Nivel activo con ese número",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });

                await _service.UpdateAsync(id, dto);
                return Ok(new PagedResult<NivelResponse>
                {
                    Success = true,
                    Message = "Nivel actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<NivelResponse>
                {
                    Success = false,
                    Message = $"Nivel con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<NivelResponse>
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
                    Message = "Nivel eliminado correctamente",
                    Code = "SUCCESS",
                    Data = true,
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Nivel con ID {id} no encontrado",
                    Code = "NOT_FOUND",
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

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<NivelResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<NivelResponse>
            {
                Success = true,
                Message = "Niveles obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
    }
}
