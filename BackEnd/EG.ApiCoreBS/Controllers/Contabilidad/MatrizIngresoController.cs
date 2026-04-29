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
    public class MatrizIngresoController : ControllerBase
    {
        private readonly GenericService<MatrizIngreso, MatrizIngresoDto, MatrizIngresoResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public MatrizIngresoController(
            GenericService<MatrizIngreso, MatrizIngresoDto, MatrizIngresoResponse> service,
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
            // MatrizIngreso no tiene propiedad Descripcion en la entidad
            // Solo validar que no exista duplicado por PK
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<MatrizIngresoResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<MatrizIngresoResponse>
            {
                Success = true,
                Message = "Matrices de ingresos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<MatrizIngresoResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id, idPropertyName: "PkidMatrizIngreso");
            if (result == null)
                return NotFound(new PagedResult<MatrizIngresoResponse>
                {
                    Success = false,
                    Message = "Matriz de ingreso no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            return Ok(new PagedResult<MatrizIngresoResponse>
            {
                Success = true,
                Message = "Matriz de ingreso encontrada",
                Code = "SUCCESS",
                Data = result,
                Items = new List<MatrizIngresoResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<MatrizIngresoResponse>>> Create([FromBody] MatrizIngresoResponse response)
        {
            try
            {
                var dto = _mapper.Map<MatrizIngresoDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                {
                    return Conflict(new PagedResult<MatrizIngresoResponse>
                    {
                        Success = false,
                        Message = "Ya existe una matriz de ingreso con esa descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                await _service.AddAsync(dto);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidMatrizIngreso },
                    new PagedResult<MatrizIngresoResponse>
                    {
                        Success = true,
                        Message = "Matriz de ingreso creada correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<MatrizIngresoResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<MatrizIngresoResponse>>> Update(int id, [FromBody] MatrizIngresoResponse response)
        {
            try
            {
                var dto = _mapper.Map<MatrizIngresoDto>(response);
                dto.PkidMatrizIngreso = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return Conflict(new PagedResult<MatrizIngresoResponse>
                    {
                        Success = false,
                        Message = "Ya existe otra matriz de ingreso con esa descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<MatrizIngresoResponse>
                {
                    Success = true,
                    Message = "Matriz de ingreso actualizada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<MatrizIngresoResponse>
                {
                    Success = false,
                    Message = $"Matriz de ingreso con ID {id} no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<MatrizIngresoResponse>
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
                    Message = "Matriz de ingreso eliminada correctamente",
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
                    Message = $"Matriz de ingreso con ID {id} no encontrada",
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
        public async Task<ActionResult<PagedResult<MatrizIngresoResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<MatrizIngresoResponse>
            {
                Success = true,
                Message = "Matrices de ingresos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<MatrizIngresoResponse>>> Buscar([FromBody] BusquedaRequest request)
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

            return Ok(new PagedResult<MatrizIngresoResponse>
            {
                Success = true,
                Message = "Matrices de ingresos filtrados correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
    }
}
