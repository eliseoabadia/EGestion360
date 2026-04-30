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

namespace EG.ApiCoreBS.Controllers.Catalogos.Presupuestales
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ActividadInstitucionalController : ControllerBase
    {
        private readonly GenericService<ActividadInstitucional, ActividadInstitucionalDto, ActividadInstitucionalResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public ActividadInstitucionalController(
            GenericService<ActividadInstitucional, ActividadInstitucionalDto, ActividadInstitucionalResponse> service,
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
            _service.AddValidationRule("UniqueActividad", async (dto) =>
            {
                var itemDto = dto as ActividadInstitucionalDto;
                if (itemDto == null) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(a => a.Clave.ToLower() == itemDto.Clave.ToLower() && a.Activo);
            });

            _service.AddValidationRuleWithId("UniqueActividadUpdate", async (dto, id) =>
            {
                var itemDto = dto as ActividadInstitucionalDto;
                if (itemDto == null || !id.HasValue) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(a => a.Clave.ToLower() == itemDto.Clave.ToLower() && a.PkidActividadInstitucional != id.Value && a.Activo);
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<ActividadInstitucionalResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<ActividadInstitucionalResponse>
            {
                Success = true,
                Message = "Actividades Institucionales obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<ActividadInstitucionalResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id, idPropertyName: "PkidActividadInstitucional");
            if (result == null)
                return NotFound(new PagedResult<ActividadInstitucionalResponse>
                {
                    Success = false,
                    Message = "Actividad Institucional no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            return Ok(new PagedResult<ActividadInstitucionalResponse>
            {
                Success = true,
                Message = "Actividad Institucional encontrada",
                Code = "SUCCESS",
                Data = result,
                Items = new List<ActividadInstitucionalResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<ActividadInstitucionalResponse>>> Create([FromBody] ActividadInstitucionalResponse response)
        {
            try
            {
                var dto = _mapper.Map<ActividadInstitucionalDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                    return Conflict(new PagedResult<ActividadInstitucionalResponse>
                    {
                        Success = false,
                        Message = "Ya existe una Actividad Institucional activa con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });

                await _service.AddAsync(dto);
                return CreatedAtAction(nameof(GetById), new { id = dto.PkidActividadInstitucional },
                    new PagedResult<ActividadInstitucionalResponse>
                    {
                        Success = true,
                        Message = "Actividad Institucional creada correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<ActividadInstitucionalResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<ActividadInstitucionalResponse>>> Update(int id, [FromBody] ActividadInstitucionalResponse response)
        {
            try
            {
                var dto = _mapper.Map<ActividadInstitucionalDto>(response);
                dto.PkidActividadInstitucional = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                    return Conflict(new PagedResult<ActividadInstitucionalResponse>
                    {
                        Success = false,
                        Message = "Ya existe otra Actividad Institucional activa con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });

                await _service.UpdateAsync(id, dto);
                return Ok(new PagedResult<ActividadInstitucionalResponse>
                {
                    Success = true,
                    Message = "Actividad Institucional actualizada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<ActividadInstitucionalResponse>
                {
                    Success = false,
                    Message = $"Actividad Institucional con ID {id} no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<ActividadInstitucionalResponse>
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
                    Message = "Actividad Institucional eliminada correctamente",
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
                    Message = $"Actividad Institucional con ID {id} no encontrada",
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
        public async Task<ActionResult<PagedResult<ActividadInstitucionalResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<ActividadInstitucionalResponse>
            {
                Success = true,
                Message = "Actividades Institucionales obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<ActividadInstitucionalResponse>>> Buscar([FromBody] BusquedaRequest request)
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
            return Ok(new PagedResult<ActividadInstitucionalResponse>
            {
                Success = true,
                Message = "Actividades Institucionales filtradas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
    }
}
