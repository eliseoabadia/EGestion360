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
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Controllers.Presupuestales
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class UnidadResponsableController : ControllerBase
    {
        private readonly GenericService<Area, UnidadResponsableDto, UnidadResponsableResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public UnidadResponsableController(
            GenericService<Area, UnidadResponsableDto, UnidadResponsableResponse> service,
            IMapper mapper,
            IUserContextService userContext)
        {
            _service = service;
            _mapper = mapper;
            _userContext = userContext;
            ConfigureService();
            ConfigureValidations();
        }

        private void ConfigureService()
        {
            // Incluir la relación con el área padre para obtener datos completos
            _service.AddInclude(a => a.FkidAreaSisNavigation);
            _service.AddInclude(a => a.InverseFkidAreaSisNavigation);
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueUnidadResponsable", async (dto) =>
            {
                var itemDto = dto as UnidadResponsableDto;
                if (itemDto == null) return true;

                return !_service.GetQueryWithIncludes()
                    .Any(d => d.Clave.ToLower() == itemDto.Clave.ToLower() && d.Activo);
            });

            _service.AddValidationRuleWithId("UniqueUnidadResponsableUpdate", async (dto, id) =>
            {
                var itemDto = dto as UnidadResponsableDto;
                if (itemDto == null || !id.HasValue) return true;

                return !_service.GetQueryWithIncludes()
                    .Any(d => d.Clave.ToLower() == itemDto.Clave.ToLower() && d.PkidArea != id.Value && d.Activo);
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<UnidadResponsableResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<UnidadResponsableResponse>
            {
                Success = true,
                Message = "Unidades Responsables obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<UnidadResponsableResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id, idPropertyName: "PkidArea");

            if (result == null)
                return NotFound(new PagedResult<UnidadResponsableResponse>
                {
                    Success = false,
                    Message = "Unidad Responsable no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            return Ok(new PagedResult<UnidadResponsableResponse>
            {
                Success = true,
                Message = "Unidad Responsable encontrada",
                Code = "SUCCESS",
                Data = result,
                Items = new List<UnidadResponsableResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<UnidadResponsableResponse>>> Create([FromBody] UnidadResponsableResponse response)
        {
            try
            {
                var dto = _mapper.Map<UnidadResponsableDto>(response);

                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                {
                    return Conflict(new PagedResult<UnidadResponsableResponse>
                    {
                        Success = false,
                        Message = "Ya existe una Unidad Responsable activa con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                await _service.AddAsync(dto);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidUnidadResponsable },
                    new PagedResult<UnidadResponsableResponse>
                    {
                        Success = true,
                        Message = "Unidad Responsable creada correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<UnidadResponsableResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<UnidadResponsableResponse>>> Update(int id, [FromBody] UnidadResponsableResponse response)
        {
            try
            {
                var dto = _mapper.Map<UnidadResponsableDto>(response);
                dto.PkidUnidadResponsable = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return Conflict(new PagedResult<UnidadResponsableResponse>
                    {
                        Success = false,
                        Message = "Ya existe otra Unidad Responsable activa con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<UnidadResponsableResponse>
                {
                    Success = true,
                    Message = "Unidad Responsable actualizada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<UnidadResponsableResponse>
                {
                    Success = false,
                    Message = $"Unidad Responsable con ID {id} no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<UnidadResponsableResponse>
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
                    Message = "Unidad Responsable eliminada correctamente",
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
                    Message = $"Unidad Responsable con ID {id} no encontrada",
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
        public async Task<ActionResult<PagedResult<UnidadResponsableResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<UnidadResponsableResponse>
            {
                Success = true,
                Message = "Unidades Responsables obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<UnidadResponsableResponse>>> Buscar([FromBody] BusquedaRequest request)
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

            return Ok(new PagedResult<UnidadResponsableResponse>
            {
                Success = true,
                Message = "Unidades Responsables filtradas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
    }
}
