using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Presupuestales
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ProgramaPresupuestalController : ControllerBase
    {
        private readonly GenericService<Pp, ProgramaPresupuestalDto, ProgramaPresupuestalResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public ProgramaPresupuestalController(
            GenericService<Pp, ProgramaPresupuestalDto, ProgramaPresupuestalResponse> service,
            IMapper mapper,
            IUserContextService userContext)
        {
            _service = service;
            _mapper = mapper;
            _userContext = userContext;
            ConfigureService();
            ConfigureValidations();
        }

        private void ConfigureService() { }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueProgramaPresupuestal", async (dto) =>
            {
                var itemDto = dto as ProgramaPresupuestalDto;
                if (itemDto == null) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(p => p.Clave.ToLower() == itemDto.Clave.ToLower() && p.Activo);
            });

            _service.AddValidationRuleWithId("UniqueProgramaPresupuestalUpdate", async (dto, id) =>
            {
                var itemDto = dto as ProgramaPresupuestalDto;
                if (itemDto == null || !id.HasValue) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(p => p.Clave.ToLower() == itemDto.Clave.ToLower() && p.PkidPp != id.Value && p.Activo);
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<ProgramaPresupuestalResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<ProgramaPresupuestalResponse>
            {
                Success = true,
                Message = "Programas Presupuestales obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<ProgramaPresupuestalResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id, idPropertyName: "PkidPp");
            if (result == null)
                return NotFound(new PagedResult<ProgramaPresupuestalResponse>
                {
                    Success = false,
                    Message = "Programa Presupuestal no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            return Ok(new PagedResult<ProgramaPresupuestalResponse>
            {
                Success = true,
                Message = "Programa Presupuestal encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<ProgramaPresupuestalResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<ProgramaPresupuestalResponse>>> Create([FromBody] ProgramaPresupuestalResponse response)
        {
            try
            {
                var dto = _mapper.Map<ProgramaPresupuestalDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                    return Conflict(new PagedResult<ProgramaPresupuestalResponse>
                    {
                        Success = false,
                        Message = "Ya existe un Programa Presupuestal activo con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });

                await _service.AddAsync(dto);
                return CreatedAtAction(nameof(GetById), new { id = dto.PkidPp },
                    new PagedResult<ProgramaPresupuestalResponse>
                    {
                        Success = true,
                        Message = "Programa Presupuestal creado correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<ProgramaPresupuestalResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<ProgramaPresupuestalResponse>>> Update(int id, [FromBody] ProgramaPresupuestalResponse response)
        {
            try
            {
                var dto = _mapper.Map<ProgramaPresupuestalDto>(response);
                dto.PkidPp = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                    return Conflict(new PagedResult<ProgramaPresupuestalResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro Programa Presupuestal activo con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });

                await _service.UpdateAsync(id, dto);
                return Ok(new PagedResult<ProgramaPresupuestalResponse>
                {
                    Success = true,
                    Message = "Programa Presupuestal actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<ProgramaPresupuestalResponse>
                {
                    Success = false,
                    Message = $"Programa Presupuestal con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<ProgramaPresupuestalResponse>
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
                    Message = "Programa Presupuestal eliminado correctamente",
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
                    Message = $"Programa Presupuestal con ID {id} no encontrado",
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
        public async Task<ActionResult<PagedResult<ProgramaPresupuestalResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<ProgramaPresupuestalResponse>
            {
                Success = true,
                Message = "Programas Presupuestales obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<ProgramaPresupuestalResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };

            var result = await _service.GetAllPaginadoAsync(pagedRequest);
            return Ok(new PagedResult<ProgramaPresupuestalResponse>
            {
                Success = true,
                Message = "Programas Presupuestales filtrados correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
    }
}
