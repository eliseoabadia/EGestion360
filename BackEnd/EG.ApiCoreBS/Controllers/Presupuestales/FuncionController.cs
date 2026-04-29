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
    public class FuncionController : ControllerBase
    {
        private readonly GenericService<Fn, FuncionDto, FuncionResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public FuncionController(
            GenericService<Fn, FuncionDto, FuncionResponse> service,
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
            _service.AddInclude(f => f.FkidGfPresNavigation);
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueFuncion", async (dto) =>
            {
                var itemDto = dto as FuncionDto;
                if (itemDto == null) return true;

                return !_service.GetQueryWithIncludes()
                    .Any(f => f.Clave == itemDto.Clave && f.Activo);
            });

            _service.AddValidationRuleWithId("UniqueFuncionUpdate", async (dto, id) =>
            {
                var itemDto = dto as FuncionDto;
                if (itemDto == null || !id.HasValue) return true;

                return !_service.GetQueryWithIncludes()
                    .Any(f => f.Clave == itemDto.Clave && f.PkidFn != id.Value && f.Activo);
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<FuncionResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<FuncionResponse>
            {
                Success = true,
                Message = "Funciones obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<FuncionResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id, idPropertyName: "PkidFn");

            if (result == null)
                return NotFound(new PagedResult<FuncionResponse>
                {
                    Success = false,
                    Message = "Función no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            return Ok(new PagedResult<FuncionResponse>
            {
                Success = true,
                Message = "Función encontrada",
                Code = "SUCCESS",
                Data = result,
                Items = new List<FuncionResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<FuncionResponse>>> Create([FromBody] FuncionResponse response)
        {
            try
            {
                var dto = _mapper.Map<FuncionDto>(response);

                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                {
                    return Conflict(new PagedResult<FuncionResponse>
                    {
                        Success = false,
                        Message = "Ya existe una Función activa con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                await _service.AddAsync(dto);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidFn },
                    new PagedResult<FuncionResponse>
                    {
                        Success = true,
                        Message = "Función creada correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<FuncionResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<FuncionResponse>>> Update(int id, [FromBody] FuncionResponse response)
        {
            try
            {
                var dto = _mapper.Map<FuncionDto>(response);
                dto.PkidFn = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return Conflict(new PagedResult<FuncionResponse>
                    {
                        Success = false,
                        Message = "Ya existe otra Función activa con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<FuncionResponse>
                {
                    Success = true,
                    Message = "Función actualizada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<FuncionResponse>
                {
                    Success = false,
                    Message = $"Función con ID {id} no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<FuncionResponse>
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
                    Message = "Función eliminada correctamente",
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
                    Message = $"Función con ID {id} no encontrada",
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
        public async Task<ActionResult<PagedResult<FuncionResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<FuncionResponse>
            {
                Success = true,
                Message = "Funciones obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<FuncionResponse>>> Buscar([FromBody] BusquedaRequest request)
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

            return Ok(new PagedResult<FuncionResponse>
            {
                Success = true,
                Message = "Funciones filtradas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
    }
}
