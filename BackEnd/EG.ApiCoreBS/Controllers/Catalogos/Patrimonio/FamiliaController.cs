using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;
using EG.Domain.DTOs.Responses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Patrimonio
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class FamiliaController : ControllerBase
    {
        private readonly GenericService<Familium, FamiliaDto, FamiliaResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public FamiliaController(
            GenericService<Familium, FamiliaDto, FamiliaResponse> service,
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
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueClave", async (dto) =>
            {
                var fDto = dto as FamiliaDto;
                if (fDto == null) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(f => f.Clave == fDto.Clave && f.Activo);
            });

            _service.AddValidationRuleWithId("UniqueClaveUpdate", async (dto, id) =>
            {
                var fDto = dto as FamiliaDto;
                if (fDto == null || !id.HasValue) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(f => f.Clave == fDto.Clave && f.PkidFamilia != id.Value && f.Activo);
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<FamiliaResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<FamiliaResponse>
            {
                Success = true,
                Message = "Familias obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<FamiliaResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id, idPropertyName: "PkidFamilia");
            if (result == null)
                return NotFound(new PagedResult<FamiliaResponse>
                {
                    Success = false,
                    Message = "Familia no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            return Ok(new PagedResult<FamiliaResponse>
            {
                Success = true,
                Message = "Familia encontrada",
                Code = "SUCCESS",
                Data = result,
                Items = new List<FamiliaResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<FamiliaResponse>>> Create([FromBody] FamiliaResponse response)
        {
            try
            {
                var dto = _mapper.Map<FamiliaDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                    return Conflict(new PagedResult<FamiliaResponse>
                    {
                        Success = false,
                        Message = "Ya existe una Familia activa con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });

                await _service.AddAsync(dto);
                return CreatedAtAction(nameof(GetById), new { id = dto.PkidFamilia },
                    new PagedResult<FamiliaResponse>
                    {
                        Success = true,
                        Message = "Familia creada correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<FamiliaResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<FamiliaResponse>>> Update(int id, [FromBody] FamiliaResponse response)
        {
            try
            {
                var dto = _mapper.Map<FamiliaDto>(response);
                dto.PkidFamilia = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                    return Conflict(new PagedResult<FamiliaResponse>
                    {
                        Success = false,
                        Message = "Ya existe otra Familia activa con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });

                await _service.UpdateAsync(id, dto);
                return Ok(new PagedResult<FamiliaResponse>
                {
                    Success = true,
                    Message = "Familia actualizada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<FamiliaResponse>
                {
                    Success = false,
                    Message = $"Familia con ID {id} no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<FamiliaResponse>
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
                    Message = "Familia eliminada correctamente",
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
                    Message = $"Familia con ID {id} no encontrada",
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
        public async Task<ActionResult<PagedResult<FamiliaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<FamiliaResponse>
            {
                Success = true,
                Message = "Familias obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<FamiliaResponse>>> Buscar([FromBody] BusquedaRequest request)
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
            return Ok(new PagedResult<FamiliaResponse>
            {
                Success = true,
                Message = "Familias filtradas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
    }
}
