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
    public class FuenteFinanciamientoController : ControllerBase
    {
        private readonly GenericService<FuenteFinanciamiento, FuenteFinanciamientoDto, FuenteFinanciamientoResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public FuenteFinanciamientoController(
            GenericService<FuenteFinanciamiento, FuenteFinanciamientoDto, FuenteFinanciamientoResponse> service,
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
            _service.AddValidationRule("UniqueFuenteFinanciamiento", async (dto) =>
            {
                var itemDto = dto as FuenteFinanciamientoDto;
                if (itemDto == null) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(f => f.Clave.ToLower() == itemDto.Clave.ToLower() && f.Activo);
            });

            _service.AddValidationRuleWithId("UniqueFuenteFinanciamientoUpdate", async (dto, id) =>
            {
                var itemDto = dto as FuenteFinanciamientoDto;
                if (itemDto == null || !id.HasValue) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(f => f.Clave.ToLower() == itemDto.Clave.ToLower() && f.PkidFuenteFinanciamiento != id.Value && f.Activo);
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<FuenteFinanciamientoResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<FuenteFinanciamientoResponse>
            {
                Success = true,
                Message = "Fuentes de Financiamiento obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<FuenteFinanciamientoResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id, idPropertyName: "PkidFuenteFinanciamiento");
            if (result == null)
                return NotFound(new PagedResult<FuenteFinanciamientoResponse>
                {
                    Success = false,
                    Message = "Fuente de Financiamiento no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            return Ok(new PagedResult<FuenteFinanciamientoResponse>
            {
                Success = true,
                Message = "Fuente de Financiamiento encontrada",
                Code = "SUCCESS",
                Data = result,
                Items = new List<FuenteFinanciamientoResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<FuenteFinanciamientoResponse>>> Create([FromBody] FuenteFinanciamientoResponse response)
        {
            try
            {
                var dto = _mapper.Map<FuenteFinanciamientoDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                    return Conflict(new PagedResult<FuenteFinanciamientoResponse>
                    {
                        Success = false,
                        Message = "Ya existe una Fuente de Financiamiento activa con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });

                await _service.AddAsync(dto);
                return CreatedAtAction(nameof(GetById), new { id = dto.PkidFuenteFinanciamiento },
                    new PagedResult<FuenteFinanciamientoResponse>
                    {
                        Success = true,
                        Message = "Fuente de Financiamiento creada correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<FuenteFinanciamientoResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<FuenteFinanciamientoResponse>>> Update(int id, [FromBody] FuenteFinanciamientoResponse response)
        {
            try
            {
                var dto = _mapper.Map<FuenteFinanciamientoDto>(response);
                dto.PkidFuenteFinanciamiento = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                    return Conflict(new PagedResult<FuenteFinanciamientoResponse>
                    {
                        Success = false,
                        Message = "Ya existe otra Fuente de Financiamiento activa con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });

                await _service.UpdateAsync(id, dto);
                return Ok(new PagedResult<FuenteFinanciamientoResponse>
                {
                    Success = true,
                    Message = "Fuente de Financiamiento actualizada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<FuenteFinanciamientoResponse>
                {
                    Success = false,
                    Message = $"Fuente de Financiamiento con ID {id} no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<FuenteFinanciamientoResponse>
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
                    Message = "Fuente de Financiamiento eliminada correctamente",
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
                    Message = $"Fuente de Financiamiento con ID {id} no encontrada",
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
        public async Task<ActionResult<PagedResult<FuenteFinanciamientoResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<FuenteFinanciamientoResponse>
            {
                Success = true,
                Message = "Fuentes de Financiamiento obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<FuenteFinanciamientoResponse>>> Buscar([FromBody] BusquedaRequest request)
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
            return Ok(new PagedResult<FuenteFinanciamientoResponse>
            {
                Success = true,
                Message = "Fuentes de Financiamiento filtradas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
    }
}
