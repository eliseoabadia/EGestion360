using AutoMapper;
using EG.ApiCore.Services;
using EG.Application.CommonModel;
using EG.Business.Services;
using EG.Domain.DTOs.Requests.ConteoCiclico;
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
    public class ArticuloConteoController : ControllerBase
    {
        private readonly IUserContextService _userContext;
        private readonly GenericService<ArticuloConteo, ArticuloConteoDto, VwArticuloConteoResponse> _service;
        private readonly GenericService<VwArticuloConteo, ArticuloConteoDto, VwArticuloConteoResponse> _serviceView;
        private readonly IMapper _mapper;

        public ArticuloConteoController(
            GenericService<ArticuloConteo, ArticuloConteoDto, VwArticuloConteoResponse> service,
            GenericService<VwArticuloConteo, ArticuloConteoDto, VwArticuloConteoResponse> serviceView,
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
            _service.AddInclude(a => a.FkidPeriodoConteoAlmaNavigation);
            _service.AddInclude(a => a.FkidTipoBienAlmaNavigation);
            _service.AddInclude(a => a.FkidEstatusAlmaNavigation);
            _service.AddInclude(a => a.RegistroConteos);
            _service.AddInclude(a => a.FkidUsuarioConcluyoSisNavigation);

            // Configurar relaciones para búsqueda en la vista
            _serviceView.AddRelationFilter("Periodo", new List<string> { "PeriodoCodigo", "PeriodoNombre" });
            _serviceView.AddRelationFilter("Articulo", new List<string> { "ArticuloCodigo", "ArticuloDescripcion" });
            _serviceView.AddRelationFilter("Estatus", new List<string> { "EstatusNombre" });
            _serviceView.AddRelationFilter("UsuarioAsignado", new List<string> { "UsuarioAsignadoNombre" });
        }

        private void ConfigureValidations()
        {
            // REGLA 1: Validar que el artículo no esté duplicado en el mismo período
            _service.AddValidationRule("UniqueArticuloEnPeriodo", async (dto) =>
            {
                var articuloDto = dto as ArticuloConteoDto;
                if (articuloDto == null || articuloDto.FkidPeriodoConteoAlma <= 0 || articuloDto.PkidArticuloConteo <= 0)
                    return false;

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(a => a.FkidPeriodoConteoAlma == articuloDto.FkidPeriodoConteoAlma &&
                                  a.PkidArticuloConteo == articuloDto.PkidArticuloConteo &&
                                  a.Activo);

                return !exists;
            });

            // REGLA 2: Validar artículo único para actualización (excluyendo el mismo)
            _service.AddValidationRuleWithId("UniqueArticuloEnPeriodoUpdate", async (dto, id) =>
            {
                var articuloDto = dto as ArticuloConteoDto;
                if (articuloDto == null || !id.HasValue || articuloDto.FkidPeriodoConteoAlma <= 0 || articuloDto.PkidArticuloConteo <= 0)
                    return true;

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(a => a.FkidPeriodoConteoAlma == articuloDto.FkidPeriodoConteoAlma &&
                                  //a.id == articuloDto.FkidArticulo &&
                                  a.PkidArticuloConteo != id.Value &&
                                  a.Activo);

                return !exists;
            });

            // REGLA 3: Validar que el período esté activo y no cerrado
            _service.AddValidationRule("ValidPeriodoActivo", async (dto) =>
            {
                var articuloDto = dto as ArticuloConteoDto;
                if (articuloDto == null || articuloDto.FkidPeriodoConteoAlma <= 0)
                    return false;

                // Esta validación requiere acceso al servicio de período
                // Se implementa en el controlador o mediante un servicio inyectado
                return true; // Placeholder, se valida en el método Add/Update
            });

            // REGLA 4: Campos obligatorios
            //_service.AddValidationRule("ValidArticulo", async (dto) =>
            //    (dto as ArticuloConteoDto)?.FkidArticulo > 0);

            _service.AddValidationRule("ValidPeriodo", async (dto) =>
                (dto as ArticuloConteoDto)?.FkidPeriodoConteoAlma > 0);

            //_service.AddValidationRule("ValidEstatus", async (dto) =>
            //    (dto as ArticuloConteoDto)?.FkidEstatusArticulo > 0);
        }

        // GET: api/ArticuloConteo
        [HttpGet]
        public async Task<ActionResult<PagedResult<VwArticuloConteoResponse>>> GetAll()
        {
            try
            {
                var result = await _serviceView.GetAllAsync();
                return Ok(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = true,
                    Message = "Artículos de conteo obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = result.ToList(),
                    TotalCount = result.Count()
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = false,
                    Message = $"Error al obtener artículos de conteo: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // GET: api/ArticuloConteo/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<VwArticuloConteoResponse>>> GetById(int id)
        {
            try
            {
                var result = await _serviceView.GetByIdAsync(id, idPropertyName: "Id");

                if (result == null)
                    return NotFound(new PagedResult<VwArticuloConteoResponse>
                    {
                        Success = false,
                        Message = "Artículo de conteo no encontrado",
                        Code = "NOTFOUND_ARTICULOCONTEO",
                        TotalCount = 0
                    });

                return Ok(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = true,
                    Message = "Artículo de conteo encontrado",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<VwArticuloConteoResponse> { result },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = false,
                    Message = $"Error al obtener artículo de conteo: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // GET: api/ArticuloConteo/ByPeriodo/{periodoId}
        [HttpGet("ByPeriodo/{periodoId}")]
        public async Task<ActionResult<PagedResult<VwArticuloConteoResponse>>> GetByPeriodo(int periodoId)
        {
            try
            {
                var result = await _serviceView.GetQueryWithIncludes()
                    .Where(a => a.PeriodoId == periodoId && a.Activo)
                    .ToListAsync();

                var response = _mapper.Map<VwArticuloConteoResponse>(result);

                return Ok(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = true,
                    Message = "Artículos de conteo del período obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = new List<VwArticuloConteoResponse> { response },
                    TotalCount = result.Count
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = false,
                    Message = $"Error al obtener artículos del período: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // GET: api/ArticuloConteo/ByUsuario/{usuarioId}
        [HttpGet("ByUsuario/{usuarioId}")]
        public async Task<ActionResult<PagedResult<VwArticuloConteoResponse>>> GetByUsuario(int usuarioId)
        {
            try
            {
                var result = await _serviceView.GetQueryWithIncludes()
                    .Where(a => a.UsuarioConcluyoId == usuarioId && a.Activo)  // error va el usuario que hace el conteo
                    .ToListAsync();

                var response = _mapper.Map<VwArticuloConteoResponse>(result);

                return Ok(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = true,
                    Message = "Artículos asignados al usuario obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = new List<VwArticuloConteoResponse> { response },
                    TotalCount = result.Count
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = false,
                    Message = $"Error al obtener artículos del usuario: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // POST: api/ArticuloConteo/GetAllPaginado
        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<VwArticuloConteoResponse>>> GetAllPaginado([FromBody] PagedRequest _params)
        {
            try
            {
                _serviceView.ClearConfiguration();
                ConfigureService();

                var result = await _serviceView.GetAllPaginadoAsync(_params);

                return Ok(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = true,
                    Message = "Artículos de conteo obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = false,
                    Message = $"Error al obtener artículos de conteo paginados: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // POST: api/ArticuloConteo/GetAllPaginadoByPeriodo/{periodoId}
        [HttpPost("GetAllPaginadoByPeriodo/{periodoId}")]
        public async Task<ActionResult<PagedResult<VwArticuloConteoResponse>>> GetAllPaginadoByPeriodo(int periodoId, [FromBody] PagedRequest _params)
        {
            try
            {
                _serviceView.ClearConfiguration();
                ConfigureService();

                //// Agregar filtro por período
                //if (_params.Filters == null)
                //    _params.Filters = new List<Filter>();

                //_params.Filters.Add(new Filter
                //{
                //    PropertyName = "PeriodoId",
                //    Value = periodoId.ToString(),
                //    Operator = "eq"
                //});

                var result = await _serviceView.GetAllPaginadoAsync(_params);

                return Ok(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = true,
                    Message = "Artículos de conteo del período obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = false,
                    Message = $"Error al obtener artículos del período paginados: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // POST: api/ArticuloConteo
        [HttpPost]
        public async Task<ActionResult<PagedResult<VwArticuloConteoResponse>>> Add([FromBody] VwArticuloConteo viewDto)
        {
            try
            {
                if (viewDto == null)
                {
                    return BadRequest(new PagedResult<VwArticuloConteoResponse>
                    {
                        Success = false,
                        Message = "Los datos del artículo de conteo son requeridos",
                        Code = "INVALID_DATA",
                        TotalCount = 0
                    });
                }

                //// Validaciones básicas
                //if (viewDto.ArticuloId <= 0 || viewDto.PeriodoId <= 0)
                //{
                //    return BadRequest(new PagedResult<VwArticuloConteoResponse>
                //    {
                //        Success = false,
                //        Message = "El artículo y el período son obligatorios",
                //        Code = "MISSING_REQUIRED_FIELDS",
                //        TotalCount = 0
                //    });
                //}

                var dto = _mapper.Map<ArticuloConteoDto>(viewDto);
                dto.Activo = true;
                dto.FechaCreacion = DateTime.Now;
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                //dto.NumeroConteos = 0;
                dto.FkidEstatusAlma = dto.FkidEstatusAlma == 0 ? 1 : dto.FkidEstatusAlma; // Pendiente por defecto

                // Validar si el artículo ya existe en el período
                var existe = await _service.GetQueryWithIncludes()
                    .AnyAsync(a => a.FkidPeriodoConteoAlma == dto.FkidPeriodoConteoAlma &&
                                  a.PkidArticuloConteo == dto.PkidArticuloConteo &&
                                  a.Activo);

                if (existe)
                {
                    return Conflict(new PagedResult<VwArticuloConteoResponse>
                    {
                        Success = false,
                        Message = "Este artículo ya está registrado en el período seleccionado",
                        Code = "DUPLICATE_ARTICULO",
                        TotalCount = 0
                    });
                }

                if (!await _service.CanAddAsync(dto))
                {
                    return Conflict(new PagedResult<VwArticuloConteoResponse>
                    {
                        Success = false,
                        Message = "No se pudo agregar el artículo. Verifique los datos.",
                        Code = "VALIDATION_ERROR",
                        TotalCount = 0
                    });
                }

                await _service.AddAsync(dto);

                var articuloCreado = await _serviceView.GetByIdAsync(dto.PkidArticuloConteo, idPropertyName: "Id");
                var response = _mapper.Map<VwArticuloConteoResponse>(articuloCreado);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidArticuloConteo },
                    new PagedResult<VwArticuloConteoResponse>
                    {
                        Success = true,
                        Message = "Artículo agregado al período correctamente",
                        Code = "SUCCESS",
                        Data = response,
                        Items = new List<VwArticuloConteoResponse> { response },
                        TotalCount = 1
                    });
            }
            catch (DbUpdateException dbEx)
            {
                var inner = dbEx.InnerException?.Message ?? dbEx.Message;
                return BadRequest(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = false,
                    Message = $"Error de base de datos: {inner}",
                    Code = "DB_ERROR",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = false,
                    Message = $"Error al agregar artículo: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // POST: api/ArticuloConteo/Batch
        [HttpPost("Batch")]
        public async Task<ActionResult<PagedResult<VwArticuloConteoResponse>>> AddBatch([FromBody] List<VwArticuloConteo> articulos)
        {
            try
            {
                if (articulos == null || !articulos.Any())
                {
                    return BadRequest(new PagedResult<VwArticuloConteoResponse>
                    {
                        Success = false,
                        Message = "La lista de artículos es requerida",
                        Code = "INVALID_DATA",
                        TotalCount = 0
                    });
                }

                var periodoId = articulos.First().PeriodoId;
                var userId = _userContext.GetCurrentUserId();
                var exitosos = 0;
                var errores = new List<string>();

                foreach (var viewDto in articulos)
                {
                    try
                    {
                        // Verificar si ya existe
                        var existe = await _service.GetQueryWithIncludes()
                            .AnyAsync(a => a.FkidPeriodoConteoAlma == periodoId &&
                                          a.PkidArticuloConteo == viewDto.Id &&
                                          a.Activo);

                        if (existe)
                        {
                            errores.Add($"Artículo  ya existe en el período"); //{viewDto.ArticuloCodigo}
                            continue;
                        }

                        var dto = _mapper.Map<ArticuloConteoDto>(viewDto);
                        dto.Activo = true;
                        dto.FechaCreacion = DateTime.Now;
                        dto.UsuarioCreacion = userId;
                        //dto.NumeroConteos = 0;
                        dto.FkidEstatusAlma = 1; // Pendiente

                        await _service.AddAsync(dto);
                        exitosos++;
                    }
                    catch (Exception ex)
                    {
                        errores.Add($"Error al agregar artículo : {ex.Message}"); //{viewDto.ArticuloCodigo}
                    }
                }

                return Ok(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = true,
                    Message = $"Se agregaron {exitosos} artículos. {errores.Count} errores.",
                    Code = "SUCCESS",
                    TotalCount = exitosos
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = false,
                    Message = $"Error al agregar artículos en lote: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // PUT: api/ArticuloConteo/{id}
        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<VwArticuloConteoResponse>>> Update(int id, [FromBody] VwArticuloConteo viewDto)
        {
            try
            {
                if (id != viewDto.Id)
                {
                    return BadRequest(new PagedResult<VwArticuloConteoResponse>
                    {
                        Success = false,
                        Message = "El ID del artículo no coincide con el parámetro de la URL",
                        Code = "ID_MISMATCH",
                        TotalCount = 0
                    });
                }

                if (viewDto.Id <= 0 || viewDto.PeriodoId <= 0)
                {
                    return BadRequest(new PagedResult<VwArticuloConteoResponse>
                    {
                        Success = false,
                        Message = "El artículo y el período son obligatorios",
                        Code = "MISSING_REQUIRED_FIELDS",
                        TotalCount = 0
                    });
                }

                var dto = _mapper.Map<ArticuloConteoDto>(viewDto);
                dto.PkidArticuloConteo = id;
                dto.FechaModificacion = DateTime.Now;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();

                // Validar duplicado (excluyendo el actual)
                var existe = await _service.GetQueryWithIncludes()
                    .AnyAsync(a => a.FkidPeriodoConteoAlma == dto.FkidPeriodoConteoAlma &&
                                  //a.FkidArticulo == dto.FkidArticulo &&
                                  a.PkidArticuloConteo != id &&
                                  a.Activo);

                if (existe)
                {
                    return Conflict(new PagedResult<VwArticuloConteoResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro artículo igual en este período",
                        Code = "DUPLICATE_ARTICULO",
                        TotalCount = 0
                    });
                }

                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return Conflict(new PagedResult<VwArticuloConteoResponse>
                    {
                        Success = false,
                        Message = "No se pudo actualizar el artículo. Verifique los datos.",
                        Code = "VALIDATION_ERROR",
                        TotalCount = 0
                    });
                }

                await _service.UpdateAsync(id, dto);

                var articuloActualizado = await _serviceView.GetByIdAsync(id, idPropertyName: "Id");
                var response = _mapper.Map<VwArticuloConteoResponse>(articuloActualizado);

                return Ok(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = true,
                    Message = "Artículo de conteo actualizado correctamente",
                    Code = "SUCCESS",
                    Data = response,
                    Items = new List<VwArticuloConteoResponse> { response },
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = false,
                    Message = $"Artículo de conteo con ID {id} no encontrado",
                    Code = "NOTFOUND_ARTICULOCONTEO",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // DELETE: api/ArticuloConteo/{id}
        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<VwArticuloConteoResponse>>> Delete(int id)
        {
            try
            {
                // Verificar si tiene registros de conteo
                var tieneRegistros = await _service.GetQueryWithIncludes()
                    .AnyAsync(a => a.PkidArticuloConteo == id && a.RegistroConteos.Any());

                if (tieneRegistros)
                {
                    return BadRequest(new PagedResult<VwArticuloConteoResponse>
                    {
                        Success = false,
                        Message = "No se puede eliminar el artículo porque tiene registros de conteo asociados. Desactívelo en su lugar.",
                        Code = "HAS_CHILDREN",
                        TotalCount = 0
                    });
                }

                await _service.DeleteAsync(id);
                return Ok(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = true,
                    Message = "Artículo de conteo eliminado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = false,
                    Message = $"Artículo de conteo con ID {id} no encontrado",
                    Code = "NOTFOUND_ARTICULOCONTEO",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = false,
                    Message = $"Error al eliminar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // PATCH: api/ArticuloConteo/{id}/cambiar-estatus
        [HttpPatch("{id}/cambiar-estatus")]
        public async Task<ActionResult<PagedResult<VwArticuloConteoResponse>>> CambiarEstatus(int id, [FromBody] int estatusId)
        {
            try
            {
                var articulo = await _service.GetByIdAsync(id, idPropertyName: "PkidArticuloConteo");
                if (articulo == null)
                {
                    return NotFound(new PagedResult<VwArticuloConteoResponse>
                    {
                        Success = false,
                        Message = "Artículo de conteo no encontrado",
                        Code = "NOTFOUND_ARTICULOCONTEO",
                        TotalCount = 0
                    });
                }

                var dto = _mapper.Map<ArticuloConteoDto>(articulo);
                dto.FkidEstatusAlma = estatusId;
                dto.FechaModificacion = DateTime.Now;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = true,
                    Message = "Estatus del artículo actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = false,
                    Message = $"Error al cambiar estatus: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // PATCH: api/ArticuloConteo/{id}/asignar-usuario
        [HttpPatch("{id}/asignar-usuario")]
        public async Task<ActionResult<PagedResult<VwArticuloConteoResponse>>> AsignarUsuario(int id, [FromBody] int usuarioId)
        {
            try
            {
                var articulo = await _service.GetByIdAsync(id, idPropertyName: "PkidArticuloConteo");
                if (articulo == null)
                {
                    return NotFound(new PagedResult<VwArticuloConteoResponse>
                    {
                        Success = false,
                        Message = "Artículo de conteo no encontrado",
                        Code = "NOTFOUND_ARTICULOCONTEO",
                        TotalCount = 0
                    });
                }

                var dto = _mapper.Map<ArticuloConteoDto>(articulo);
                dto.UsuarioCreacion = usuarioId;
                dto.FechaModificacion = DateTime.Now;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = true,
                    Message = "Usuario asignado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = false,
                    Message = $"Error al asignar usuario: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // GET: api/ArticuloConteo/estadisticas/{periodoId}
        [HttpGet("estadisticas/{periodoId}")]
        public async Task<ActionResult> GetEstadisticas(int periodoId)
        {
            try
            {
                var articulos = await _serviceView.GetQueryWithIncludes()
                    .Where(a => a.PeriodoId == periodoId && a.Activo)
                    .ToListAsync();

                var estadisticas = new
                {
                    TotalArticulos = articulos.Count,
                    Pendientes = articulos.Count(a => a.EstatusId == 1),
                    EnProceso = articulos.Count(a => a.EstatusId == 2),
                    Completados = articulos.Count(a => a.EstatusId == 3),
                    ConDiferencias = articulos.Sum(a => a.Diferencia),
                    PorcentajeAvance = articulos.Any()
                        ? (articulos.Count(a => a.EstatusId == 3) * 100.0 / articulos.Count)
                        : 0
                };

                return Ok(new
                {
                    Success = true,
                    Data = estadisticas,
                    Message = "Estadísticas obtenidas correctamente"
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new
                {
                    Success = false,
                    Message = $"Error al obtener estadísticas: {ex.Message}"
                });
            }
        }
    }
}