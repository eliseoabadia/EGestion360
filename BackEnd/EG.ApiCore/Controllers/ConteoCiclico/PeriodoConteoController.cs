using AutoMapper;
using EG.ApiCore.Services;
using EG.Application.CommonModel;
using EG.Business.Services;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;
using EG.Web.Models.ConteoCiclico;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCore.Controllers.General
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

            // Configurar relaciones para búsqueda
            _service.AddRelationFilter("Sucursal", new List<string> { "Nombre", "CodigoSucursal" });
            _service.AddRelationFilter("TipoConteo", new List<string> { "Nombre" });
            _service.AddRelationFilter("EstatusPeriodo", new List<string> { "Nombre" });
            _service.AddRelationFilter("Responsable", new List<string> { "Nombre", "ApellidoPaterno", "Email" });
            _service.AddRelationFilter("Supervisor", new List<string> { "Nombre", "ApellidoPaterno", "Email" });

            // Configurar filtros de búsqueda para la vista
            _serviceView.AddRelationFilter("Sucursal", new List<string> {
                "SucursalNombre", "SucursalId"
            });
            _serviceView.AddRelationFilter("TipoConteo", new List<string> {
                "TipoConteoNombre"
            });
            _serviceView.AddRelationFilter("Estatus", new List<string> {
                "EstatusNombre"
            });
        }

        private void ConfigureValidations()
        {
            // REGLA 1: Validar código de período único por sucursal (para creación)
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

            // REGLA 2: Validar código de período único para ACTUALIZACIÓN
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

            // REGLA 3: Validar fechas
            _service.AddValidationRule("ValidFechas", async (dto) =>
            {
                var periodoDto = dto as PeriodoConteoDto;
                if (periodoDto == null)
                    return false;

                // Fecha fin no puede ser menor a fecha inicio
                if (periodoDto.FechaFin.HasValue && periodoDto.FechaFin.Value < periodoDto.FechaInicio)
                    return false;

                // Fecha cierre no puede ser menor a fecha inicio
                if (periodoDto.FechaCierre.HasValue && periodoDto.FechaCierre.Value.Date < periodoDto.FechaInicio.ToDateTime(TimeOnly.MinValue))
                    return false;

                return true;
            });

            // REGLA 4: Validar campos obligatorios
            _service.AddValidationRule("ValidNombre", async (dto) =>
            {
                var periodoDto = dto as PeriodoConteoDto;
                return !string.IsNullOrWhiteSpace(periodoDto?.Nombre);
            });

            _service.AddValidationRule("ValidCodigoPeriodo", async (dto) =>
            {
                var periodoDto = dto as PeriodoConteoDto;
                return !string.IsNullOrWhiteSpace(periodoDto?.CodigoPeriodo);
            });

            _service.AddValidationRule("ValidSucursal", async (dto) =>
            {
                var periodoDto = dto as PeriodoConteoDto;
                return periodoDto?.FkidSucursalSis > 0;
            });

            _service.AddValidationRule("ValidTipoConteo", async (dto) =>
            {
                var periodoDto = dto as PeriodoConteoDto;
                return periodoDto?.FkidTipoConteoAlma > 0;
            });

            // REGLA 5: Validar máximo de conteos por artículo
            _service.AddValidationRule("ValidMaximoConteos", async (dto) =>
            {
                var periodoDto = dto as PeriodoConteoDto;
                return periodoDto?.MaximoConteosPorArticulo >= 1 && periodoDto?.MaximoConteosPorArticulo <= 5;
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
            var PeriodoConteo = await _serviceView.GetByIdAsync(id, idPropertyName: "PkIdPeriodoConteo");

            if (PeriodoConteo == null)
            {
                return Ok(new PagedResult<VwPeriodoConteoResponse>
                {
                    Success = false,
                    Message = "PeriodoConteo no encontrado",
                    Code = "NOTFOUND_USER",
                    //Data = default,
                    Items = new List<VwPeriodoConteoResponse>(),
                    TotalCount = 0
                });
            }

            return Ok(new PagedResult<VwPeriodoConteoResponse>
            {
                Success = true,
                Message = "PeriodoConteo encontrado",
                Code = "SUCCESS",
                Data = PeriodoConteo,
                Items = new List<VwPeriodoConteoResponse> { PeriodoConteo },
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
                Message = "PeriodoConteos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("GetAllPeriodoConteosPaginado")]
        public async Task<ActionResult<PagedResult<VwPeriodoConteoResponse>>> GetAllPeriodoConteosPaginado([FromBody] PagedRequest _params)
        {
            _serviceView.ClearConfiguration();
            ConfigureService();

            var result = await _serviceView.GetAllPaginadoAsync(_params);
            return Ok(new PagedResult<VwPeriodoConteoResponse>
            {
                Success = true,
                Message = "PeriodoConteos obtenidos correctamente",
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
                // Validación básica del DTO
                if (viewDto == null)
                {
                    return BadRequest(new PagedResult<VwPeriodoConteoResponse>
                    {
                        Success = false,
                        Message = "Los datos del periodo son requeridos",
                        Code = "INVALID_DATA",
                        TotalCount = 0
                    });
                }

                // Validar campos obligatorios mínimos
                if (string.IsNullOrWhiteSpace(viewDto.CodigoPeriodo) ||
                    string.IsNullOrWhiteSpace(viewDto.Nombre))
                {
                    return BadRequest(new PagedResult<VwPeriodoConteoResponse>
                    {
                        Success = false,
                        Message = "El código y nombre del periodo son campos obligatorios",
                        Code = "MISSING_REQUIRED_FIELDS",
                        TotalCount = 0
                    });
                }

                // Mapear y preparar el DTO
                var dto = _mapper.Map<PeriodoConteoDto>(viewDto);
                //dto.Fecha = DateTime.Now;
                //dto.Usuario = _userContext.GetCurrentUserId();
                //dto.Activo = true;

                // Si no se especifica, establecer valores por defecto
                if (dto.MaximoConteosPorArticulo == 0)
                    dto.MaximoConteosPorArticulo = 3;

                if (dto.FkidEstatusAlma == 0)
                    dto.FkidEstatusAlma = 1; // Pendiente por defecto

                // Validar si puede agregar (aplicará todas las reglas de validación configuradas)
                if (!await _service.CanAddAsync(dto))
                {
                    // Verificar cuál es el conflicto específico
                    var codigoExists = await _service.GetQueryWithIncludes()
                        .AnyAsync(p => p.FkidSucursalSis == dto.FkidSucursalSis &&
                                      p.CodigoPeriodo.ToLower() == dto.CodigoPeriodo.ToLower() &&
                                      p.Activo);

                    if (codigoExists)
                    {
                        return Conflict(new PagedResult<VwPeriodoConteoResponse>
                        {
                            Success = false,
                            Message = $"El código de periodo '{dto.CodigoPeriodo}' ya existe para esta sucursal",
                            Code = "DUPLICATE_CODIGO",
                            TotalCount = 0
                        });
                    }

                    return Conflict(new PagedResult<VwPeriodoConteoResponse>
                    {
                        Success = false,
                        Message = "No se pudo crear el periodo. Verifique los datos.",
                        Code = "VALIDATION_ERROR",
                        TotalCount = 0
                    });
                }

                // Guardar el periodo
                await _service.AddAsync(dto);

                // Obtener el periodo creado para devolverlo
                var periodoCreado = await _serviceView.GetByIdAsync(dto.PkidPeriodoConteo, idPropertyName: "Id");
                var response = _mapper.Map<VwPeriodoConteoResponse>(periodoCreado);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidPeriodoConteo },
                    new PagedResult<VwPeriodoConteoResponse>
                    {
                        Success = true,
                        Message = "Periodo de conteo creado correctamente",
                        Code = "SUCCESS",
                        Data = response,
                        Items = new List<VwPeriodoConteoResponse> { response },
                        TotalCount = 1
                    });
            }
            catch (DbUpdateException dbEx)
            {
                var innerMessage = dbEx.InnerException?.Message ?? dbEx.Message;
                return BadRequest(new PagedResult<VwPeriodoConteoResponse>
                {
                    Success = false,
                    Message = $"Error de base de datos al crear periodo: {innerMessage}",
                    Code = "DB_ERROR",
                    TotalCount = 0
                });
            }
            catch (AutoMapperMappingException mapEx)
            {
                return BadRequest(new PagedResult<VwPeriodoConteoResponse>
                {
                    Success = false,
                    Message = $"Error al mapear los datos del periodo: {mapEx.Message}",
                    Code = "MAPPING_ERROR",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<VwPeriodoConteoResponse>
                {
                    Success = false,
                    Message = $"Error al crear periodo: {ex.Message}",
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
                // Validar que el ID coincida
                if (id != viewDto.Id)
                {
                    return BadRequest(new PagedResult<VwPeriodoConteoResponse>
                    {
                        Success = false,
                        Message = "El ID del periodo no coincide con el parámetro de la URL",
                        Code = "ID_MISMATCH",
                        TotalCount = 0
                    });
                }

                // Validar campos obligatorios mínimos
                if (string.IsNullOrWhiteSpace(viewDto.CodigoPeriodo) ||
                    string.IsNullOrWhiteSpace(viewDto.Nombre))
                {
                    return BadRequest(new PagedResult<VwPeriodoConteoResponse>
                    {
                        Success = false,
                        Message = "El código y nombre del periodo son campos obligatorios",
                        Code = "MISSING_REQUIRED_FIELDS",
                        TotalCount = 0
                    });
                }

                var dto = _mapper.Map<PeriodoConteoDto>(viewDto);
                dto.PkidPeriodoConteo = id;
                //dto.FechaModificacion = DateTime.Now;
                //dto.UsuarioModificacion = _userContext.GetCurrentUserId();

                // Validar si puede actualizar
                var canUpdate = await _service.CanUpdateAsync(id, dto);

                if (!canUpdate)
                {
                    // Verificar cuál es el conflicto específico
                    var existingPeriodo = await _service.GetQueryWithIncludes()
                        .FirstOrDefaultAsync(p => p.FkidSucursalSis == dto.FkidSucursalSis &&
                                                p.CodigoPeriodo.ToLower() == dto.CodigoPeriodo.ToLower() &&
                                                p.PkidPeriodoConteo != id &&
                                                p.Activo);

                    if (existingPeriodo != null)
                    {
                        return Conflict(new PagedResult<VwPeriodoConteoResponse>
                        {
                            Success = false,
                            Message = $"El código de periodo '{dto.CodigoPeriodo}' ya está siendo utilizado por otro periodo (ID: {existingPeriodo.PkidPeriodoConteo})",
                            Code = "DUPLICATE_CODIGO",
                            TotalCount = 0
                        });
                    }

                    return Conflict(new PagedResult<VwPeriodoConteoResponse>
                    {
                        Success = false,
                        Message = "No se pudo actualizar el periodo. Verifique los datos.",
                        Code = "VALIDATION_ERROR",
                        TotalCount = 0
                    });
                }

                await _service.UpdateAsync(id, dto);

                // Obtener el periodo actualizado para devolverlo
                var periodoActualizado = await _serviceView.GetByIdAsync(id, idPropertyName: "Id");
                var response = _mapper.Map<VwPeriodoConteoResponse>(periodoActualizado);

                return Ok(new PagedResult<VwPeriodoConteoResponse>
                {
                    Success = true,
                    Message = "Periodo de conteo actualizado correctamente",
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
                    Message = $"Periodo de conteo con ID {id} no encontrado",
                    Code = "NOTFOUND_PERIODO",
                    TotalCount = 0
                });
            }
            catch (DbUpdateException dbEx)
            {
                var innerMessage = dbEx.InnerException?.Message ?? dbEx.Message;
                return BadRequest(new PagedResult<VwPeriodoConteoResponse>
                {
                    Success = false,
                    Message = $"Error de base de datos al actualizar periodo: {innerMessage}",
                    Code = "DB_ERROR",
                    TotalCount = 0
                });
            }
            catch (AutoMapperMappingException mapEx)
            {
                return BadRequest(new PagedResult<VwPeriodoConteoResponse>
                {
                    Success = false,
                    Message = $"Error al mapear los datos del periodo: {mapEx.Message}",
                    Code = "MAPPING_ERROR",
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
                // Verificar si tiene artículos asociados antes de eliminar
                var tieneArticulos = await _service.GetQueryWithIncludes()
                    .AnyAsync(p => p.PkidPeriodoConteo == id && p.ArticuloConteos.Any());

                if (tieneArticulos)
                {
                    return BadRequest(new PagedResult<VwPeriodoConteoResponse>
                    {
                        Success = false,
                        Message = "No se puede eliminar el periodo porque tiene artículos asociados. Desactive el periodo en su lugar.",
                        Code = "HAS_CHILDREN",
                        TotalCount = 0
                    });
                }

                await _service.DeleteAsync(id);
                return Ok(new PagedResult<VwPeriodoConteoResponse>
                {
                    Success = true,
                    Message = "Periodo de conteo eliminado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<VwPeriodoConteoResponse>
                {
                    Success = false,
                    Message = $"Periodo de conteo con ID {id} no encontrado",
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
                        Message = "Periodo de conteo no encontrado",
                        Code = "NOTFOUND_PERIODO",
                        TotalCount = 0
                    });
                }

                var dto = _mapper.Map<PeriodoConteoDto>(periodo);
                dto.FkidEstatusAlma = estatusId;
                //dto.FechaModificacion = DateTime.Now;
                //dto.UsuarioModificacion = _userContext.GetCurrentUserId();

                // Si se está marcando como completado, establecer fecha fin
                if (estatusId == 3 && !dto.FechaFin.HasValue) // Completado
                {
                    dto.FechaFin = DateOnly.FromDateTime(DateTime.Now);
                }

                // Si se está cerrando, establecer fecha cierre
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
                    Message = $"Estatus del periodo actualizado correctamente",
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
                        Message = "Periodo de conteo no encontrado",
                        Code = "NOTFOUND_PERIODO",
                        TotalCount = 0
                    });
                }

                // Verificar si hay artículos pendientes
                //var tienePendientes = periodo.ArticulosConcluidos.Value < 1 ?? false;
                if (periodo.ArticulosConcluidos.HasValue && periodo.ArticulosConcluidos.Value < 1)
                {
                    return BadRequest(new PagedResult<VwPeriodoConteoResponse>
                    {
                        Success = false,
                        Message = "No se puede cerrar el periodo porque tiene artículos pendientes",
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
                    Message = "Periodo cerrado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<VwPeriodoConteoResponse>
                {
                    Success = false,
                    Message = $"Error al cerrar periodo: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }
    }
}