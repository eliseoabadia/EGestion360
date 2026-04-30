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
    public class SubFuncionController : ControllerBase
    {
        private readonly GenericService<Sf, SubFuncionDto, SubFuncionResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public SubFuncionController(
            GenericService<Sf, SubFuncionDto, SubFuncionResponse> service,
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
            _service.AddInclude(s => s.FkidFnPresNavigation);
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueSubFuncion", async (dto) =>
            {
                var itemDto = dto as SubFuncionDto;
                if (itemDto == null) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(s => s.Clave == itemDto.Clave && s.Activo);
            });

            _service.AddValidationRuleWithId("UniqueSubFuncionUpdate", async (dto, id) =>
            {
                var itemDto = dto as SubFuncionDto;
                if (itemDto == null || !id.HasValue) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(s => s.Clave == itemDto.Clave && s.PkidSf != id.Value && s.Activo);
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<SubFuncionResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<SubFuncionResponse>
            {
                Success = true,
                Message = "SubFunciones obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<SubFuncionResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id, idPropertyName: "PkidSf");
            if (result == null)
                return NotFound(new PagedResult<SubFuncionResponse>
                {
                    Success = false,
                    Message = "SubFunción no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            return Ok(new PagedResult<SubFuncionResponse>
            {
                Success = true,
                Message = "SubFunción encontrada",
                Code = "SUCCESS",
                Data = result,
                Items = new List<SubFuncionResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<SubFuncionResponse>>> Create([FromBody] SubFuncionResponse response)
        {
            try
            {
                var dto = _mapper.Map<SubFuncionDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                    return Conflict(new PagedResult<SubFuncionResponse>
                    {
                        Success = false,
                        Message = "Ya existe una SubFunción activa con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });

                await _service.AddAsync(dto);
                return CreatedAtAction(nameof(GetById), new { id = dto.PkidSf },
                    new PagedResult<SubFuncionResponse>
                    {
                        Success = true,
                        Message = "SubFunción creada correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<SubFuncionResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<SubFuncionResponse>>> Update(int id, [FromBody] SubFuncionResponse response)
        {
            try
            {
                var dto = _mapper.Map<SubFuncionDto>(response);
                dto.PkidSf = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                    return Conflict(new PagedResult<SubFuncionResponse>
                    {
                        Success = false,
                        Message = "Ya existe otra SubFunción activa con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });

                await _service.UpdateAsync(id, dto);
                return Ok(new PagedResult<SubFuncionResponse>
                {
                    Success = true,
                    Message = "SubFunción actualizada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<SubFuncionResponse>
                {
                    Success = false,
                    Message = $"SubFunción con ID {id} no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<SubFuncionResponse>
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
                    Message = "SubFunción eliminada correctamente",
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
                    Message = $"SubFunción con ID {id} no encontrada",
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
        public async Task<ActionResult<PagedResult<SubFuncionResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<SubFuncionResponse>
            {
                Success = true,
                Message = "SubFunciones obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<SubFuncionResponse>>> Buscar([FromBody] BusquedaRequest request)
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
            return Ok(new PagedResult<SubFuncionResponse>
            {
                Success = true,
                Message = "SubFunciones filtradas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
    }
}
