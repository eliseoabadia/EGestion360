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
    public class PartidaController : ControllerBase
    {
        private readonly GenericService<Partidum, PartidaDto, PartidaResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public PartidaController(
            GenericService<Partidum, PartidaDto, PartidaResponse> service,
            IMapper mapper,
            IUserContextService userContext)
        {
            _service = service;
            _mapper = mapper;
            _userContext = userContext;
            _service.AddInclude(e => e.FkidConceptoSisNavigation);
            ConfigureValidations();
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueClave", async (dto) =>
            {
                var pDto = dto as PartidaDto;
                if (pDto == null) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(p => p.Clave == pDto.Clave && p.Activo);
            });

            _service.AddValidationRuleWithId("UniqueClaveUpdate", async (dto, id) =>
            {
                var pDto = dto as PartidaDto;
                if (pDto == null || !id.HasValue) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(p => p.Clave == pDto.Clave && p.PkidPartida != id.Value && p.Activo);
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<PartidaResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<PartidaResponse>
            {
                Success = true,
                Message = "Partidas obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<PartidaResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id, idPropertyName: "PkidPartida");
            if (result == null)
                return NotFound(new PagedResult<PartidaResponse>
                {
                    Success = false,
                    Message = "Partida no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            return Ok(new PagedResult<PartidaResponse>
            {
                Success = true,
                Message = "Partida encontrada",
                Code = "SUCCESS",
                Data = result,
                Items = new List<PartidaResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<PartidaResponse>>> Create([FromBody] PartidaResponse response)
        {
            try
            {
                var dto = _mapper.Map<PartidaDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                    return Conflict(new PagedResult<PartidaResponse>
                    {
                        Success = false,
                        Message = "Ya existe una Partida activa con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });

                await _service.AddAsync(dto);
                return CreatedAtAction(nameof(GetById), new { id = dto.PkidPartida },
                    new PagedResult<PartidaResponse>
                    {
                        Success = true,
                        Message = "Partida creada correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<PartidaResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<PartidaResponse>>> Update(int id, [FromBody] PartidaResponse response)
        {
            try
            {
                var dto = _mapper.Map<PartidaDto>(response);
                dto.PkidPartida = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                    return Conflict(new PagedResult<PartidaResponse>
                    {
                        Success = false,
                        Message = "Ya existe otra Partida activa con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });

                await _service.UpdateAsync(id, dto);
                return Ok(new PagedResult<PartidaResponse>
                {
                    Success = true,
                    Message = "Partida actualizada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<PartidaResponse>
                {
                    Success = false,
                    Message = $"Partida con ID {id} no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<PartidaResponse>
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
                    Message = "Partida eliminada correctamente",
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
                    Message = $"Partida con ID {id} no encontrada",
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
        public async Task<ActionResult<PagedResult<PartidaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<PartidaResponse>
            {
                Success = true,
                Message = "Partidas obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
    }
}
