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
    public class TipoPolizaController : ControllerBase
    {
        private readonly GenericService<TipoPoliza, TipoPolizaDto, TipoPolizaResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public TipoPolizaController(
            GenericService<TipoPoliza, TipoPolizaDto, TipoPolizaResponse> service,
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
            _service.AddValidationRule("UniqueTipoPoliza", async (dto) =>
            {
                var itemDto = dto as TipoPolizaDto;
                if (itemDto == null) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(t => t.Descripcion.ToLower() == itemDto.Descripcion.ToLower() && t.Activo);
            });

            _service.AddValidationRuleWithId("UniqueTipoPolizaUpdate", async (dto, id) =>
            {
                var itemDto = dto as TipoPolizaDto;
                if (itemDto == null || !id.HasValue) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(t => t.Descripcion.ToLower() == itemDto.Descripcion.ToLower() && t.PkidTipoPoliza != id.Value && t.Activo);
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<TipoPolizaResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<TipoPolizaResponse>
            {
                Success = true,
                Message = "Tipos de póliza obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<TipoPolizaResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            if (result == null)
                return NotFound(new PagedResult<TipoPolizaResponse>
                {
                    Success = false,
                    Message = "Tipo de póliza no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            return Ok(new PagedResult<TipoPolizaResponse>
            {
                Success = true,
                Message = "Tipo de póliza encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<TipoPolizaResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<TipoPolizaResponse>>> Create([FromBody] TipoPolizaResponse response)
        {
            try
            {
                var dto = _mapper.Map<TipoPolizaDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                {
                    return Conflict(new PagedResult<TipoPolizaResponse>
                    {
                        Success = false,
                        Message = "Ya existe un tipo de póliza con esa descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                await _service.AddAsync(dto);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidTipoPoliza },
                    new PagedResult<TipoPolizaResponse>
                    {
                        Success = true,
                        Message = "Tipo de póliza creado correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoPolizaResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<TipoPolizaResponse>>> Update(int id, [FromBody] TipoPolizaResponse response)
        {
            try
            {
                var dto = _mapper.Map<TipoPolizaDto>(response);
                dto.PkidTipoPoliza = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return Conflict(new PagedResult<TipoPolizaResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro tipo de póliza con esa descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<TipoPolizaResponse>
                {
                    Success = true,
                    Message = "Tipo de póliza actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<TipoPolizaResponse>
                {
                    Success = false,
                    Message = $"Tipo de póliza con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoPolizaResponse>
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
                    Message = "Tipo de póliza eliminado correctamente",
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
                    Message = $"Tipo de póliza con ID {id} no encontrado",
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
        public async Task<ActionResult<PagedResult<TipoPolizaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<TipoPolizaResponse>
            {
                Success = true,
                Message = "Tipos de póliza obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<TipoPolizaResponse>>> Buscar([FromBody] BusquedaRequest request)
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

            return Ok(new PagedResult<TipoPolizaResponse>
            {
                Success = true,
                Message = "Tipos de póliza filtrados correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
    }
}
