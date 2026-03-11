using AutoMapper;
using EG.ApiCore.Services;
using EG.Application.CommonModel;
using EG.Business.Services;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCore.Controllers.ConteoCiclico
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class PeriodoConteoController : ControllerBase
    {
        private readonly IUserContextService _userContext;
        private readonly GenericService<PeriodoConteo, PeriodoConteoDto, VwPeriodoConteoResponse> _service;
        private readonly GenericService<VwPeriodoConteo, PeriodoConteoDto, VwPeriodoConteoResponse> _serviceView;
        private readonly IMapper _mapper;

        public PeriodoConteoController(
            GenericService<PeriodoConteo, PeriodoConteoDto, VwPeriodoConteoResponse> service,
            GenericService<VwPeriodoConteo, PeriodoConteoDto, VwPeriodoConteoResponse> serviceView,
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
            // Configurar includes para la entidad principal
            _service.AddInclude(p => p.FkidSucursalSisNavigation);
            _service.AddInclude(p => p.FkidTipoConteoAlmaNavigation);
            _service.AddInclude(p => p.FkidEstatusAlmaNavigation);
            _service.AddInclude(p => p.FkidResponsableSisNavigation);
            _service.AddInclude(p => p.FkidSupervisorSisNavigation);
            _service.AddInclude(p => p.ArticuloConteos);
            _service.AddInclude(p => p.RegistroConteos);

            // Configurar relaciones para búsqueda en la vista
            _serviceView.AddRelationFilter("Sucursal", new List<string> { "SucursalNombre", "SucursalId" });
            _serviceView.AddRelationFilter("TipoConteo", new List<string> { "TipoConteoNombre" });
            _serviceView.AddRelationFilter("Estatus", new List<string> { "EstatusNombre" });
        }

        private void ConfigureValidations()
        {
            // REGLA 1: Código de período único por sucursal (creación)
            _service.AddValidationRule("UniqueCodigoPeriodo", async (dto) =>
            {
                var periodoDto = dto as PeriodoConteoDto;
                if (periodoDto == null || string.IsNullOrWhiteSpace(periodoDto.CodigoPeriodo))
                    return false;

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(p => p.FkidSucursalSis == periodoDto.FkidSucursalSis &&
                                  p.CodigoPeriodo.ToLower() == periodoDto.CodigoPeriodo.ToLower() &&
                                  p.Activo);

                return !exists;
            });

            // REGLA 2: Código de período único para actualización (excluyendo el mismo)
            _service.AddValidationRuleWithId("UniqueCodigoPeriodoUpdate", async (dto, id) =>
            {
                var periodoDto = dto as PeriodoConteoDto;
                if (periodoDto == null || !id.HasValue || string.IsNullOrWhiteSpace(periodoDto.CodigoPeriodo))
                    return true;

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(p => p.FkidSucursalSis == periodoDto.FkidSucursalSis &&
                                  p.CodigoPeriodo.ToLower() == periodoDto.CodigoPeriodo.ToLower() &&
                                  p.PkidPeriodoConteo != id.Value &&
                                  p.Activo);

                return !exists;
            });

            // REGLA 3: Validar fechas (fin >= inicio, cierre >= inicio)
            _service.AddValidationRule("ValidFechas", async (dto) =>
            {
                var periodoDto = dto as PeriodoConteoDto;
                if (periodoDto == null)
                    return false;

                if (periodoDto.FechaFin.HasValue && periodoDto.FechaFin.Value < periodoDto.FechaInicio)
                    return false;

                if (periodoDto.FechaCierre.HasValue && periodoDto.FechaCierre.Value.Date < periodoDto.FechaInicio.ToDateTime(TimeOnly.MinValue))
                    return false;

                return true;
            });

            // REGLA 4: Campos obligatorios
            _service.AddValidationRule("ValidNombre", async (dto) =>
                !string.IsNullOrWhiteSpace((dto as PeriodoConteoDto)?.Nombre));

            _service.AddValidationRule("ValidCodigoPeriodo", async (dto) =>
                !string.IsNullOrWhiteSpace((dto as PeriodoConteoDto)?.CodigoPeriodo));

            _service.AddValidationRule("ValidSucursal", async (dto) =>
                (dto as PeriodoConteoDto)?.FkidSucursalSis > 0);

            _service.AddValidationRule("ValidTipoConteo", async (dto) =>
                (dto as PeriodoConteoDto)?.FkidTipoConteoAlma > 0);

            // REGLA 5: Máximo de conteos por artículo entre 1 y 5
            _service.AddValidationRule("ValidMaximoConteos", async (dto) =>
            {
                var val = (dto as PeriodoConteoDto)?.MaximoConteosPorArticulo;
                return val >= 1 && val <= 5;
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<VwPeriodoConteoResponse>>> GetAll()
        {
            var result = await _serviceView.GetAllAsync();
            var response = _mapper.Map<List<VwPeriodoConteoResponse>>(result);
            return Ok(new { success = true, Items = response, TotalCount = response.Count });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<VwPeriodoConteoResponse>>> GetById(int id)
        {
            var periodo = await _serviceView.GetByIdAsync(id, idPropertyName: "Id");

            if (periodo == null)
            {
                return Ok(new PagedResult<VwPeriodoConteoResponse>
                {
                    Success = false,
                    Message = "Período de conteo no encontrado",
                    Code = "NOTFOUND_PERIODO",
                    Items = new List<VwPeriodoConteoResponse>(),
                    TotalCount = 0
                });
            }

            return Ok(new PagedResult<VwPeriodoConteoResponse>
            {
                Success = true,
                Message = "Período de conteo encontrado",
                Code = "SUCCESS",
                Data = periodo,
                Items = new List<VwPeriodoConteoResponse> { periodo },
                TotalCount = 1
            });
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<VwPeriodoConteoResponse>>> GetAllPaginado([FromBody] PagedRequest _params)
        {
            _serviceView.ClearConfiguration();
            ConfigureService();

            var result = await _serviceView.GetAllPaginadoAsync(_params);
            return Ok(new PagedResult<VwPeriodoConteoResponse>
            {
                Success = true,
                Message = "Períodos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<VwPeriodoConteoResponse>>> Add([FromBody] VwPeriodoConteo viewDto)
        {
            try
            {
                if (viewDto == null)
                {
                    return BadRequest(new PagedResult<VwPeriodoConteoResponse>
                    {
                        Success = false,
                        Message = "Los datos del período son requeridos",
                        Code = "INVALID_DATA",
                        TotalCount = 0
                    });
                }

                if (string.IsNullOrWhiteSpace(viewDto.CodigoPeriodo) || string.IsNullOrWhiteSpace(viewDto.Nombre))
                {
                    return BadRequest(new PagedResult<VwPeriodoConteoResponse>
                    {
                        Success = false,
                        Message = "El código y nombre del período son obligatorios",
                        Code = "MISSING_REQUIRED_FIELDS",
                        TotalCount = 0
                    });
                }

                var dto = _mapper.Map<PeriodoConteoDto>(viewDto);
                dto.Activo = true;
                dto.FechaCreacion = DateTime.Now;
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FkidSupervisorSis = dto.FkidSupervisorSis == 0 ? null : dto.FkidSupervisorSis; // Pendiente por defecto
                dto.FkidEstatusAlma = dto.FkidEstatusAlma == 0 ? 1 : dto.FkidEstatusAlma; // Pendiente por defecto
                dto.MaximoConteosPorArticulo = dto.MaximoConteosPorArticulo == 0 ? 3 : dto.MaximoConteosPorArticulo;

                if (!await _service.CanAddAsync(dto))
                {
                    // Verificar duplicado específico
                    var duplicado = await _service.GetQueryWithIncludes()
                        .AnyAsync(p => p.FkidSucursalSis == dto.FkidSucursalSis &&
                                      p.CodigoPeriodo.ToLower() == dto.CodigoPeriodo.ToLower() &&
                                      p.Activo);

                    if (duplicado)
                    {
                        return Conflict(new PagedResult<VwPeriodoConteoResponse>
                        {
                            Success = false,
                            Message = $"El código de período '{dto.CodigoPeriodo}' ya existe en esta sucursal",
                            Code = "DUPLICATE_CODIGO",
                            TotalCount = 0
                        });
                    }

                    return Conflict(new PagedResult<VwPeriodoConteoResponse>
                    {
                        Success = false,
                        Message = "No se pudo crear el período. Verifique los datos.",
                        Code = "VALIDATION_ERROR",
                        TotalCount = 0
                    });
                }

                await _service.AddAsync(dto);

                var periodoCreado = await _serviceView.GetByIdAsync(dto.PkidPeriodoConteo, idPropertyName: "Id");
                var response = _mapper.Map<VwPeriodoConteoResponse>(periodoCreado);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidPeriodoConteo },
                    new PagedResult<VwPeriodoConteoResponse>
                    {
                        Success = true,
                        Message = "Período de conteo creado correctamente",
                        Code = "SUCCESS",
                        Data = response,
                        Items = new List<VwPeriodoConteoResponse> { response },
                        TotalCount = 1
                    });
            }
            catch (DbUpdateException dbEx)
            {
                var inner = dbEx.InnerException?.Message ?? dbEx.Message;
                return BadRequest(new PagedResult<VwPeriodoConteoResponse>
                {
                    Success = false,
                    Message = $"Error de base de datos: {inner}",
                    Code = "DB_ERROR",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<VwPeriodoConteoResponse>
                {
                    Success = false,
                    Message = $"Error al crear período: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<VwPeriodoConteoResponse>>> Update(int id, [FromBody] VwPeriodoConteo viewDto)
        {
            try
            {
                if (id != viewDto.Id)
                {
                    return BadRequest(new PagedResult<VwPeriodoConteoResponse>
                    {
                        Success = false,
                        Message = "El ID del período no coincide con el parámetro de la URL",
                        Code = "ID_MISMATCH",
                        TotalCount = 0
                    });
                }

                if (string.IsNullOrWhiteSpace(viewDto.CodigoPeriodo) || string.IsNullOrWhiteSpace(viewDto.Nombre))
                {
                    return BadRequest(new PagedResult<VwPeriodoConteoResponse>
                    {
                        Success = false,
                        Message = "El código y nombre del período son obligatorios",
                        Code = "MISSING_REQUIRED_FIELDS",
                        TotalCount = 0
                    });
                }

                var dto = _mapper.Map<PeriodoConteoDto>(viewDto);
                dto.PkidPeriodoConteo = id;
                dto.FechaModificacion = DateTime.Now;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();

                if (!await _service.CanUpdateAsync(id, dto))
                {
                    var duplicado = await _service.GetQueryWithIncludes()
                        .AnyAsync(p => p.FkidSucursalSis == dto.FkidSucursalSis &&
                                      p.CodigoPeriodo.ToLower() == dto.CodigoPeriodo.ToLower() &&
                                      p.PkidPeriodoConteo != id &&
                                      p.Activo);

                    if (duplicado)
                    {
                        return Conflict(new PagedResult<VwPeriodoConteoResponse>
                        {
                            Success = false,
                            Message = $"El código de período '{dto.CodigoPeriodo}' ya está en uso por otro período",
                            Code = "DUPLICATE_CODIGO",
                            TotalCount = 0
                        });
                    }

                    return Conflict(new PagedResult<VwPeriodoConteoResponse>
                    {
                        Success = false,
                        Message = "No se pudo actualizar el período. Verifique los datos.",
                        Code = "VALIDATION_ERROR",
                        TotalCount = 0
                    });
                }

                await _service.UpdateAsync(id, dto);

                var periodoActualizado = await _serviceView.GetByIdAsync(id, idPropertyName: "Id");
                var response = _mapper.Map<VwPeriodoConteoResponse>(periodoActualizado);

                return Ok(new PagedResult<VwPeriodoConteoResponse>
                {
                    Success = true,
                    Message = "Período de conteo actualizado correctamente",
                    Code = "SUCCESS",
                    Data = response,
                    Items = new List<VwPeriodoConteoResponse> { response },
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<VwPeriodoConteoResponse>
                {
                    Success = false,
                    Message = $"Período de conteo con ID {id} no encontrado",
                    Code = "NOTFOUND_PERIODO",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<VwPeriodoConteoResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<VwPeriodoConteoResponse>>> Delete(int id)
        {
            try
            {
                var tieneArticulos = await _service.GetQueryWithIncludes()
                    .AnyAsync(p => p.PkidPeriodoConteo == id && p.ArticuloConteos.Any());

                if (tieneArticulos)
                {
                    return BadRequest(new PagedResult<VwPeriodoConteoResponse>
                    {
                        Success = false,
                        Message = "No se puede eliminar el período porque tiene artículos asociados. Desactívelo en su lugar.",
                        Code = "HAS_CHILDREN",
                        TotalCount = 0
                    });
                }

                await _service.DeleteAsync(id);
                return Ok(new PagedResult<VwPeriodoConteoResponse>
                {
                    Success = true,
                    Message = "Período de conteo eliminado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<VwPeriodoConteoResponse>
                {
                    Success = false,
                    Message = $"Período de conteo con ID {id} no encontrado",
                    Code = "NOTFOUND_PERIODO",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<VwPeriodoConteoResponse>
                {
                    Success = false,
                    Message = $"Error al eliminar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPatch("{id}/cambiar-estatus")]
        public async Task<ActionResult<PagedResult<VwPeriodoConteoResponse>>> CambiarEstatus(int id, [FromBody] int estatusId)
        {
            try
            {
                var periodo = await _service.GetByIdAsync(id, idPropertyName: "PkidPeriodoConteo");
                if (periodo == null)
                {
                    return NotFound(new PagedResult<VwPeriodoConteoResponse>
                    {
                        Success = false,
                        Message = "Período de conteo no encontrado",
                        Code = "NOTFOUND_PERIODO",
                        TotalCount = 0
                    });
                }

                var dto = _mapper.Map<PeriodoConteoDto>(periodo);
                dto.FkidEstatusAlma = estatusId;
                //dto.FechaModificacion = DateTime.Now;
                //dto.UsuarioModificacion = _userContext.GetCurrentUserId();

                if (estatusId == 3 && !dto.FechaFin.HasValue) // Completado
                {
                    dto.FechaFin = DateOnly.FromDateTime(DateTime.Now);
                }

                if (estatusId == 4 && !dto.FechaCierre.HasValue) // Cerrado
                {
                    dto.FechaCierre = DateTime.Now;
                    if (!dto.FechaFin.HasValue)
                        dto.FechaFin = DateOnly.FromDateTime(DateTime.Now);
                }

                await _service.UpdateAsync(id, dto);
                return Ok(new PagedResult<VwPeriodoConteoResponse>
                {
                    Success = true,
                    Message = "Estatus del período actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<VwPeriodoConteoResponse>
                {
                    Success = false,
                    Message = $"Error al cambiar estatus: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPatch("{id}/cerrar")]
        public async Task<ActionResult<PagedResult<VwPeriodoConteoResponse>>> CerrarPeriodo(int id)
        {
            try
            {
                var periodo = await _service.GetByIdAsync(id, idPropertyName: "PkidPeriodoConteo");
                if (periodo == null)
                {
                    return NotFound(new PagedResult<VwPeriodoConteoResponse>
                    {
                        Success = false,
                        Message = "Período de conteo no encontrado",
                        Code = "NOTFOUND_PERIODO",
                        TotalCount = 0
                    });
                }

                // Verificar si hay artículos pendientes
                if (periodo.ArticulosPendientes > 0)
                {
                    return BadRequest(new PagedResult<VwPeriodoConteoResponse>
                    {
                        Success = false,
                        Message = "No se puede cerrar el período porque tiene artículos pendientes",
                        Code = "PENDING_ARTICLES",
                        TotalCount = 0
                    });
                }

                var dto = _mapper.Map<PeriodoConteoDto>(periodo);
                dto.FkidEstatusAlma = 3; // Completado
                dto.FechaFin = DateOnly.FromDateTime(DateTime.Now);
                //dto.FechaModificacion = DateTime.Now;
                //dto.UsuarioModificacion = _userContext.GetCurrentUserId();

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<VwPeriodoConteoResponse>
                {
                    Success = true,
                    Message = "Período cerrado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<VwPeriodoConteoResponse>
                {
                    Success = false,
                    Message = $"Error al cerrar período: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }
    }
}