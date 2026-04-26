using AutoMapper;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.DTOs.Responses;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using EG.ApiCoreBS.Services;

namespace EG.ApiCoreBS.Controllers.Catalogos.Adquisicion
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class EstatusRequisicionController : ControllerBase
    {
        private readonly GenericService<EstatusRequisicion, EstatusRequisicionDto, EstatusRequisicionResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public EstatusRequisicionController(
            GenericService<EstatusRequisicion, EstatusRequisicionDto, EstatusRequisicionResponse> service,
            IMapper mapper,
            IUserContextService userContext)
        {
            _service = service;
            _mapper = mapper;
            _userContext = userContext;
            ConfigureValidations();
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueDescripcion", async (dto) =>
            {
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.Descripcion.ToLower() == dto.Descripcion.ToLower() && x.Activo);
            });

            _service.AddValidationRuleWithId("UniqueDescripcionUpdate", async (dto, id) =>
            {
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.Descripcion.ToLower() == dto.Descripcion.ToLower() && x.PkidEstatusRequisicion != id.Value && x.Activo);
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<EstatusRequisicionResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<EstatusRequisicionResponse>
            {
                Success = true,
                Message = "Estatus de Requisición obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<EstatusRequisicionResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id, idPropertyName: "PkidEstatusRequisicion");

            if (result == null)
                return NotFound(new PagedResult<EstatusRequisicionResponse>
                {
                    Success = false,
                    Message = "Estatus de Requisición no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            return Ok(new PagedResult<EstatusRequisicionResponse>
            {
                Success = true,
                Message = "Estatus de Requisición encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<EstatusRequisicionResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<EstatusRequisicionResponse>>> Create([FromBody] EstatusRequisicionResponse response)
        {
            try
            {
                var dto = _mapper.Map<EstatusRequisicionDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                {
                    return Conflict(new PagedResult<EstatusRequisicionResponse>
                    {
                        Success = false,
                        Message = "Ya existe un estatus de requisición activo con esa descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                await _service.AddAsync(dto);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidEstatusRequisicion },
                    new PagedResult<EstatusRequisicionResponse>
                    {
                        Success = true,
                        Message = "Estatus de Requisición creado correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<EstatusRequisicionResponse>
                {
                    Success = false,
                    Message = $"Error al crear estatus de requisición: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<EstatusRequisicionResponse>>> Update(int id, [FromBody] EstatusRequisicionResponse response)
        {
            try
            {
                var dto = _mapper.Map<EstatusRequisicionDto>(response);
                dto.PkidEstatusRequisicion = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return Conflict(new PagedResult<EstatusRequisicionResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro estatus de requisición activo con esa descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<EstatusRequisicionResponse>
                {
                    Success = true,
                    Message = "Estatus de Requisición actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<EstatusRequisicionResponse>
                {
                    Success = false,
                    Message = $"Estatus de Requisición con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<EstatusRequisicionResponse>
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
                    Message = "Estatus de Requisición eliminado correctamente",
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
                    Message = $"Estatus de Requisición con ID {id} no encontrado",
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
        public async Task<ActionResult<PagedResult<EstatusRequisicionResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<EstatusRequisicionResponse>
            {
                Success = true,
                Message = "Estatus de Requisición obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<EstatusRequisicionResponse>>> Buscar([FromBody] BusquedaRequest request)
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

            return Ok(new PagedResult<EstatusRequisicionResponse>
            {
                Success = true,
                Message = "Estatus de Requisición filtrados correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
    }
}