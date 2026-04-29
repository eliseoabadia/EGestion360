using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Contabilidad
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ConceptoController : ControllerBase
    {
        private readonly GenericService<Concepto, ConceptoDto, ConceptoResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public ConceptoController(
            GenericService<Concepto, ConceptoDto, ConceptoResponse> service,
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
            _service.AddInclude(c => c.FkidCapituloContaNavigation);
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueConcepto", async (dto) =>
            {
                var itemDto = dto as ConceptoDto;
                if (itemDto == null) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(c => c.Descripcion.ToLower() == itemDto.Descripcion.ToLower() && c.Activo);
            });

            _service.AddValidationRuleWithId("UniqueConceptoUpdate", async (dto, id) =>
            {
                var itemDto = dto as ConceptoDto;
                if (itemDto == null || !id.HasValue) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(c => c.Descripcion.ToLower() == itemDto.Descripcion.ToLower() && c.PkidConcepto != id.Value && c.Activo);
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<ConceptoResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<ConceptoResponse>
            {
                Success = true,
                Message = "Conceptos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<ConceptoResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            if (result == null)
                return NotFound(new PagedResult<ConceptoResponse>
                {
                    Success = false,
                    Message = "Concepto no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            return Ok(new PagedResult<ConceptoResponse>
            {
                Success = true,
                Message = "Concepto encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<ConceptoResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<ConceptoResponse>>> Create([FromBody] ConceptoResponse response)
        {
            try
            {
                var dto = _mapper.Map<ConceptoDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                {
                    return Conflict(new PagedResult<ConceptoResponse>
                    {
                        Success = false,
                        Message = "Ya existe un concepto con esa descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                await _service.AddAsync(dto);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidConcepto },
                    new PagedResult<ConceptoResponse>
                    {
                        Success = true,
                        Message = "Concepto creado correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<ConceptoResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<ConceptoResponse>>> Update(int id, [FromBody] ConceptoResponse response)
        {
            try
            {
                var dto = _mapper.Map<ConceptoDto>(response);
                dto.PkidConcepto = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return Conflict(new PagedResult<ConceptoResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro concepto con esa descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<ConceptoResponse>
                {
                    Success = true,
                    Message = "Concepto actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<ConceptoResponse>
                {
                    Success = false,
                    Message = $"Concepto con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<ConceptoResponse>
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
                    Message = "Concepto eliminado correctamente",
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
                    Message = $"Concepto con ID {id} no encontrado",
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
        public async Task<ActionResult<PagedResult<ConceptoResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<ConceptoResponse>
            {
                Success = true,
                Message = "Conceptos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<ConceptoResponse>>> Buscar([FromBody] BusquedaRequest request)
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

            return Ok(new PagedResult<ConceptoResponse>
            {
                Success = true,
                Message = "Conceptos filtrados correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
    }
}
