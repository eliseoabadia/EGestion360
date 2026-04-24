using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class DepartamentoController : ControllerBase
    {
        private readonly GenericService<Departamento, DepartamentoDto, DepartamentoResponse> _service;
        private readonly GenericService<VwEmpresaDepartamanto, DepartamentoDto, DepartamentoResponse> _serviceView;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public DepartamentoController(
            GenericService<Departamento, DepartamentoDto, DepartamentoResponse> service,
            GenericService<VwEmpresaDepartamanto, DepartamentoDto, DepartamentoResponse> serviceView,
            IMapper mapper,
            IUserContextService userContext)
        {
            _service = service;
            _serviceView = serviceView;
            _mapper = mapper;
            _userContext = userContext;

            ConfigureService();
            ConfigureValidations();
        }

        private void ConfigureService()
        {
            _service.AddInclude(d => d.FkidEmpresaSisNavigation);
            _service.AddInclude(d => d.FkidSucursalSisNavigation);
            _service.AddInclude(d => d.UsuarioCreacionNavigation);
            _service.AddRelationFilter("FkidEmpresaSisNavigation", new List<string> { "Nombre" });
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueDepartmentPerCompany", async (dto) =>
            {
                var deptoDto = dto as DepartamentoDto;
                if (deptoDto == null) return true;

                return !_service.GetQueryWithIncludes()
                    .Any(d => d.FkidEmpresaSis == deptoDto.FkidEmpresaSis &&
                             d.Nombre.ToLower() == deptoDto.Nombre.ToLower() &&
                             d.Activo);
            });

            _service.AddValidationRuleWithId("UniqueDepartmentPerCompanyUpdate", async (dto, id) =>
            {
                var deptoDto = dto as DepartamentoDto;
                if (deptoDto == null || !id.HasValue) return true;

                return !_service.GetQueryWithIncludes()
                    .Any(d => d.FkidEmpresaSis == deptoDto.FkidEmpresaSis &&
                             d.Nombre.ToLower() == deptoDto.Nombre.ToLower() &&
                             d.PkidDepartamento != id.Value &&
                             d.Activo);
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<DepartamentoResponse>>> GetAll()
        {
            var result = await _serviceView.GetAllAsync();
            return Ok(new PagedResult<DepartamentoResponse>
            {
                Success = true,
                Message = "Departamentos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<DepartamentoResponse>>> GetById(int id)
        {
            var result = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidDepartamento");

            if (result == null)
                return NotFound(new PagedResult<DepartamentoResponse>
                {
                    Success = false,
                    Message = "Departamento no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            return Ok(new PagedResult<DepartamentoResponse>
            {
                Success = true,
                Message = "Departamento encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<DepartamentoResponse> { result },
                TotalCount = 1
            });
        }

        [HttpGet("empresa/{empresaId}")]
        public async Task<ActionResult<PagedResult<DepartamentoResponse>>> GetByEmpresaId(int empresaId)
        {
            var result = await _service.GetAllPaginadoAsync(
                new PagedRequest { Page = 1, PageSize = 1000 },
                d => d.FkidEmpresaSis == empresaId);

            return Ok(new PagedResult<DepartamentoResponse>
            {
                Success = true,
                Message = "Departamentos por empresa obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<DepartamentoResponse>>> Create([FromBody] DepartamentoResponse response)
        {
            try
            {
                var dto = _mapper.Map<DepartamentoDto>(response);

                dto.FkidEmpresaSis = _userContext.GetCurrentEmpresaId();
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                {
                    return Conflict(new PagedResult<DepartamentoResponse>
                    {
                        Success = false,
                        Message = "Ya existe un departamento activo con ese nombre en esta empresa",
                        Code = "DUPLICATE_DEPARTMENT",
                        TotalCount = 0
                    });
                }

                await _service.AddAsync(dto);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidDepartamento },
                    new PagedResult<DepartamentoResponse>
                    {
                        Success = true,
                        Message = "Departamento creado correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<DepartamentoResponse>
                {
                    Success = false,
                    Message = $"Error al crear departamento: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<DepartamentoResponse>>> Update(int id, [FromBody] DepartamentoResponse response)
        {
            try
            {
                var dto = _mapper.Map<DepartamentoDto>(response);
                dto.PkidDepartamento = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return Conflict(new PagedResult<DepartamentoResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro departamento activo con ese nombre en esta empresa",
                        Code = "DUPLICATE_DEPARTMENT",
                        TotalCount = 0
                    });
                }

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<DepartamentoResponse>
                {
                    Success = true,
                    Message = "Departamento actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<DepartamentoResponse>
                {
                    Success = false,
                    Message = $"Departamento con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<DepartamentoResponse>
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
                    Message = "Departamento eliminado correctamente",
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
                    Message = $"Departamento con ID {id} no encontrado",
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
        public async Task<ActionResult<PagedResult<DepartamentoResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var empresaId = _userContext.TryGetCurrentEmpresaId();
            if (empresaId.HasValue)
            {
                var result = await _service.GetAllPaginadoAsync(request, d => d.FkidEmpresaSis == empresaId.Value);
                return Ok(new PagedResult<DepartamentoResponse>
                {
                    Success = true,
                    Message = "Departamentos obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                });
            }

            var allResult = await _serviceView.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<DepartamentoResponse>
            {
                Success = true,
                Message = "Departamentos obtenidos correctamente",
                Code = "SUCCESS",
                Items = allResult.Items,
                TotalCount = allResult.TotalCount
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<DepartamentoResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };

            var result = await _serviceView.GetAllPaginadoAsync(pagedRequest);

            return Ok(new PagedResult<DepartamentoResponse>
            {
                Success = true,
                Message = "Departamentos filtrados correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
    }
}
