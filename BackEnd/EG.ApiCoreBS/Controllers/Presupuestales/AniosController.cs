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
    public class AniosController : ControllerBase
    {
        private readonly GenericService<Anio, AniosDto, AniosResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public AniosController(
            GenericService<Anio, AniosDto, AniosResponse> service,
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
            _service.AddValidationRule("UniqueAnio", async (dto) =>
            {
                var itemDto = dto as AniosDto;
                if (itemDto == null) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(a => a.Clave == itemDto.Clave && a.Activo);
            });

            _service.AddValidationRuleWithId("UniqueAnioUpdate", async (dto, id) =>
            {
                var itemDto = dto as AniosDto;
                if (itemDto == null || !id.HasValue) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(a => a.Clave == itemDto.Clave && a.PkidAnio != id.Value && a.Activo);
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<AniosResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<AniosResponse>
            {
                Success = true,
                Message = "Años obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<AniosResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id, idPropertyName: "PkidAnio");
            if (result == null)
                return NotFound(new PagedResult<AniosResponse>
                {
                    Success = false,
                    Message = "Año no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            return Ok(new PagedResult<AniosResponse>
            {
                Success = true,
                Message = "Año encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<AniosResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<AniosResponse>>> Create([FromBody] AniosResponse response)
        {
            try
            {
                var dto = _mapper.Map<AniosDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                    return Conflict(new PagedResult<AniosResponse>
                    {
                        Success = false,
                        Message = "Ya existe un Año activo con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });

                await _service.AddAsync(dto);
                return CreatedAtAction(nameof(GetById), new { id = dto.PkidAnio },
                    new PagedResult<AniosResponse>
                    {
                        Success = true,
                        Message = "Año creado correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<AniosResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<AniosResponse>>> Update(int id, [FromBody] AniosResponse response)
        {
            try
            {
                var dto = _mapper.Map<AniosDto>(response);
                dto.PkidAnio = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                    return Conflict(new PagedResult<AniosResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro Año activo con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });

                await _service.UpdateAsync(id, dto);
                return Ok(new PagedResult<AniosResponse>
                {
                    Success = true,
                    Message = "Año actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<AniosResponse>
                {
                    Success = false,
                    Message = $"Año con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<AniosResponse>
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
                    Message = "Año eliminado correctamente",
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
                    Message = $"Año con ID {id} no encontrado",
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
        public async Task<ActionResult<PagedResult<AniosResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<AniosResponse>
            {
                Success = true,
                Message = "Años obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<AniosResponse>>> Buscar([FromBody] BusquedaRequest request)
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
            return Ok(new PagedResult<AniosResponse>
            {
                Success = true,
                Message = "Años filtrados correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
    }
}
