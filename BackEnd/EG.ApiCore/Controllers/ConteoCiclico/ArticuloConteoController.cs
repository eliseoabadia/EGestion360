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
            _service.AddInclude(a => a.FkidSucursalSisNavigation);
            _service.AddInclude(a => a.FkidEstatusAlmaNavigation);
            _service.AddInclude(a => a.FkidUsuarioConcluyoSisNavigation);
            _service.AddInclude(a => a.RegistroConteos);
            _service.AddInclude(a => a.DiscrepanciaConteos);
            _service.AddInclude(a => a.HistorialEstatusArticulos);

            // Configurar relaciones para búsqueda en el servicio de vista
            _serviceView.AddRelationFilter("Periodo", new List<string> { "CodigoPeriodo", "PeriodoNombre" });
            _serviceView.AddRelationFilter("TipoBien", new List<string> { "CodigoArticulo", "DescripcionArticulo" });
            _serviceView.AddRelationFilter("Sucursal", new List<string> { "SucursalNombre" });
            _serviceView.AddRelationFilter("Estatus", new List<string> { "EstatusNombre", "EstatusDescripcion" });
            _serviceView.AddRelationFilter("UsuarioConcluyo", new List<string> { "UsuarioConcluyoNombre" });
        }

        private void ConfigureValidations()
        {
            // REGLA 1: Validar que el artículo no esté duplicado en el mismo período (código de barras único por período)
            _service.AddValidationRule("UniqueArticuloEnPeriodo", async (dto) =>
            {
                var articuloDto = dto as ArticuloConteoDto;
                if (articuloDto == null || string.IsNullOrWhiteSpace(articuloDto.CodigoBarras))
                    return false;

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(a => a.FkidPeriodoConteoAlma == articuloDto.FkidPeriodoConteoAlma &&
                                  a.CodigoBarras.ToLower() == articuloDto.CodigoBarras.ToLower() &&
                                  a.Activo);

                return !exists;
            });

            // REGLA 2: Validar código de barras único en actualización (excluyendo el mismo registro)
            _service.AddValidationRuleWithId("UniqueArticuloEnPeriodoUpdate", async (dto, id) =>
            {
                var articuloDto = dto as ArticuloConteoDto;
                if (articuloDto == null || !id.HasValue || string.IsNullOrWhiteSpace(articuloDto.CodigoBarras))
                    return true;

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(a => a.FkidPeriodoConteoAlma == articuloDto.FkidPeriodoConteoAlma &&
                                  a.CodigoBarras.ToLower() == articuloDto.CodigoBarras.ToLower() &&
                                  a.PkidArticuloConteo != id.Value &&
                                  a.Activo);

                return !exists;
            });

            // REGLA 3: Validar campos obligatorios
            _service.AddValidationRule("ValidCodigoBarras", async (dto) =>
            {
                var articuloDto = dto as ArticuloConteoDto;
                return !string.IsNullOrWhiteSpace(articuloDto?.CodigoBarras);
            });

            _service.AddValidationRule("ValidDescripcion", async (dto) =>
            {
                var articuloDto = dto as ArticuloConteoDto;
                return !string.IsNullOrWhiteSpace(articuloDto?.DescripcionArticulo);
            });

            _service.AddValidationRule("ValidPeriodo", async (dto) =>
            {
                var articuloDto = dto as ArticuloConteoDto;
                return articuloDto?.FkidPeriodoConteoAlma > 0;
            });

            _service.AddValidationRule("ValidTipoBien", async (dto) =>
            {
                var articuloDto = dto as ArticuloConteoDto;
                return articuloDto?.FkidTipoBienAlma > 0;
            });

            _service.AddValidationRule("ValidSucursal", async (dto) =>
            {
                var articuloDto = dto as ArticuloConteoDto;
                return articuloDto?.FkidSucursalSis > 0;
            });

            _service.AddValidationRule("ValidEstatus", async (dto) =>
            {
                var articuloDto = dto as ArticuloConteoDto;
                return articuloDto?.FkidEstatusAlma > 0;
            });

            // REGLA 4: Validar que la existencia final no sea negativa
            _service.AddValidationRule("ExistenciaFinalNoNegativa", async (dto) =>
            {
                var articuloDto = dto as ArticuloConteoDto;
                return !articuloDto.ExistenciaFinal.HasValue || articuloDto.ExistenciaFinal.Value >= 0;
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<VwArticuloConteoResponse>>> GetAll()
        {
            var result = await _serviceView.GetAllAsync();
            var response = _mapper.Map<List<VwArticuloConteoResponse>>(result);
            return Ok(new { success = true, Items = response, TotalCount = response.Count });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<VwArticuloConteoResponse>>> GetById(int id)
        {
            var articulo = await _serviceView.GetByIdAsync(id, idPropertyName: "Id");

            if (articulo == null)
            {
                return Ok(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = false,
                    Message = "Artículo de conteo no encontrado",
                    Code = "NOTFOUND_ARTICULO",
                    Items = new List<VwArticuloConteoResponse>(),
                    TotalCount = 0
                });
            }

            return Ok(new PagedResult<VwArticuloConteoResponse>
            {
                Success = true,
                Message = "Artículo de conteo encontrado",
                Code = "SUCCESS",
                Data = articulo,
                Items = new List<VwArticuloConteoResponse> { articulo },
                TotalCount = 1
            });
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<VwArticuloConteoResponse>>> GetAllPaginado([FromBody] PagedRequest _params)
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
                        Message = "Los datos del artículo son requeridos",
                        Code = "INVALID_DATA",
                        TotalCount = 0
                    });
                }

                // Validaciones mínimas
                if (string.IsNullOrWhiteSpace(viewDto.CodigoBarras) ||
                    string.IsNullOrWhiteSpace(viewDto.DescripcionArticulo))
                {
                    return BadRequest(new PagedResult<VwArticuloConteoResponse>
                    {
                        Success = false,
                        Message = "El código de barras y la descripción son campos obligatorios",
                        Code = "MISSING_REQUIRED_FIELDS",
                        TotalCount = 0
                    });
                }

                var dto = _mapper.Map<ArticuloConteoDto>(viewDto);
                //dto.Activo = true;
                //dto.FechaCreacion = DateTime.Now;
                //dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.ConteosRealizados = 0;
                dto.ConteosPendientes = viewDto.MaximoConteosPorArticulo; // Inicialmente pendientes igual al máximo

                // Validar reglas de negocio
                if (!await _service.CanAddAsync(dto))
                {
                    // Verificar duplicado
                    var duplicado = await _service.GetQueryWithIncludes()
                        .AnyAsync(a => a.FkidPeriodoConteoAlma == dto.FkidPeriodoConteoAlma &&
                                      a.CodigoBarras.ToLower() == dto.CodigoBarras.ToLower() &&
                                      a.Activo);

                    if (duplicado)
                    {
                        return Conflict(new PagedResult<VwArticuloConteoResponse>
                        {
                            Success = false,
                            Message = $"El código de barras '{dto.CodigoBarras}' ya existe en este período",
                            Code = "DUPLICATE_ARTICULO",
                            TotalCount = 0
                        });
                    }

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
                        Message = "Artículo de conteo creado correctamente",
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
                    Message = $"Error al crear artículo: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

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

                if (string.IsNullOrWhiteSpace(viewDto.CodigoBarras) ||
                    string.IsNullOrWhiteSpace(viewDto.DescripcionArticulo))
                {
                    return BadRequest(new PagedResult<VwArticuloConteoResponse>
                    {
                        Success = false,
                        Message = "El código de barras y la descripción son campos obligatorios",
                        Code = "MISSING_REQUIRED_FIELDS",
                        TotalCount = 0
                    });
                }

                var dto = _mapper.Map<ArticuloConteoDto>(viewDto);
                dto.PkidArticuloConteo = id;
                //dto.FechaModificacion = DateTime.Now;
                //dto.UsuarioModificacion = _userContext.GetCurrentUserId();

                if (!await _service.CanUpdateAsync(id, dto))
                {
                    var duplicado = await _service.GetQueryWithIncludes()
                        .AnyAsync(a => a.FkidPeriodoConteoAlma == dto.FkidPeriodoConteoAlma &&
                                      a.CodigoBarras.ToLower() == dto.CodigoBarras.ToLower() &&
                                      a.PkidArticuloConteo != id &&
                                      a.Activo);

                    if (duplicado)
                    {
                        return Conflict(new PagedResult<VwArticuloConteoResponse>
                        {
                            Success = false,
                            Message = $"El código de barras '{dto.CodigoBarras}' ya está en uso en este período",
                            Code = "DUPLICATE_ARTICULO",
                            TotalCount = 0
                        });
                    }

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
                    Code = "NOTFOUND_ARTICULO",
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

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<VwArticuloConteoResponse>>> Delete(int id)
        {
            try
            {
                // Verificar si tiene registros de conteo o discrepancias asociadas
                var tieneRegistros = await _service.GetQueryWithIncludes()
                    .AnyAsync(a => a.PkidArticuloConteo == id && a.RegistroConteos.Any());

                var tieneDiscrepancias = await _service.GetQueryWithIncludes()
                    .AnyAsync(a => a.PkidArticuloConteo == id && a.DiscrepanciaConteos.Any());

                if (tieneRegistros || tieneDiscrepancias)
                {
                    return BadRequest(new PagedResult<VwArticuloConteoResponse>
                    {
                        Success = false,
                        Message = "No se puede eliminar el artículo porque tiene conteos o discrepancias asociadas. Desactívelo en su lugar.",
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
                    Code = "NOTFOUND_ARTICULO",
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
                        Code = "NOTFOUND_ARTICULO",
                        TotalCount = 0
                    });
                }

                var dto = _mapper.Map<ArticuloConteoDto>(articulo);
                dto.FkidEstatusAlma = estatusId;
                //dto.FechaModificacion = DateTime.Now;
                //dto.UsuarioModificacion = _userContext.GetCurrentUserId();

                // Si se está concluyendo, establecer fecha de conclusión
                if (estatusId == 3 && !dto.FechaConclusion.HasValue) // Concluido
                {
                    dto.FechaConclusion = DateTime.Now;
                }

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

        [HttpPatch("{id}/concluir")]
        public async Task<ActionResult<PagedResult<VwArticuloConteoResponse>>> ConcluirArticulo(int id)
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
                        Code = "NOTFOUND_ARTICULO",
                        TotalCount = 0
                    });
                }

                // Verificar si tiene conteos pendientes
                if (articulo.ConteosPendientes > 0)
                {
                    return BadRequest(new PagedResult<VwArticuloConteoResponse>
                    {
                        Success = false,
                        Message = "No se puede concluir el artículo porque tiene conteos pendientes",
                        Code = "PENDING_COUNTS",
                        TotalCount = 0
                    });
                }

                var dto = _mapper.Map<ArticuloConteoDto>(articulo);
                dto.FkidEstatusAlma = 3; // Concluido
                dto.FechaConclusion = DateTime.Now;
                //dto.FechaModificacion = DateTime.Now;
                //dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FkidUsuarioConcluyoSis = _userContext.GetCurrentUserId();

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = true,
                    Message = "Artículo concluido correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<VwArticuloConteoResponse>
                {
                    Success = false,
                    Message = $"Error al concluir artículo: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }
    }
}