using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Controllers.Catalogos.Adquisicion
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class PaaaController : ControllerBase
    {
        private readonly GenericService<Paaa, PaaaDto, PaaaResponse> _service;
        private readonly GenericService<VwPaaa, PaaaDto, PaaaResponse> _serviceView;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public PaaaController(
            GenericService<Paaa, PaaaDto, PaaaResponse> service,
            GenericService<VwPaaa, PaaaDto, PaaaResponse> serviceView,
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
            _service.AddInclude(e => e.FkidAnioSisNavigation);
            _service.AddInclude(e => e.FkidAreaSisNavigation);
            _service.AddInclude(e => e.FkidPersonaNomNavigation);
            _service.AddInclude(e => e.FkidProyectoOrcoNavigation);
            _service.AddInclude(e => e.FkidProgramaPresNavigation);
            _service.AddInclude(e => e.FkidFuenteFinanciamientoPresNavigation);
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRuleWithId("UniqueAreaAnio", async (dto, id) =>
            {
                var pDto = dto as PaaaDto;
                if (pDto == null) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.FkidAreaSis == pDto.FkidAreaSis
                        && x.FkidAnioSis == pDto.FkidAnioSis
                        && x.Activo
                        && (!id.HasValue || x.PkidPaaas != id.Value));
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<PaaaResponse>>> GetAll()
        {
            try
            {
                var items = await _serviceView.GetAllAsync();
                return Ok(new PagedResult<PaaaResponse>
                {
                    Items = items.ToList(),
                    TotalCount = items.Count(),
                    Success = true,
                    Message = "Programas anuales obtenidos correctamente",
                    Code = "SUCCESS"
                });
            }
            catch (Exception ex)
            {
                return Ok(new PagedResult<PaaaResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                });
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<PaaaResponse>>> GetById(int id)
        {
            try
            {
                var result = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidPaaas");
                if (result == null)
                    return NotFound(new PagedResult<PaaaResponse>
                    {
                        Success = false, Message = "Programa anual no encontrado", Code = "NOT_FOUND", TotalCount = 0
                    });

                return Ok(new PagedResult<PaaaResponse>
                {
                    Success = true,
                    Message = "Programa anual encontrado",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<PaaaResponse> { result },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return Ok(new PagedResult<PaaaResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                });
            }
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<PaaaResponse>>> Create([FromBody] PaaaResponse response)
        {
            try
            {
                var dto = _mapper.Map<PaaaDto>(response);
                dto.FkidEmpresaSis = _userContext.GetCurrentEmpresaId();
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                {
                    return Conflict(new PagedResult<PaaaResponse>
                    {
                        Success = false,
                        Message = "Ya existe un programa anual activo para el mismo año y área",
                        Code = "DUPLICATE_AREA_ANIO",
                        TotalCount = 0
                    });
                }

                await _service.AddAsync(dto);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidPaaas },
                    new PagedResult<PaaaResponse>
                    {
                        Success = true,
                        Message = "Programa anual creado correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<PaaaResponse>
                {
                    Success = false,
                    Message = $"Error al crear programa anual: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<PaaaResponse>>> Update(int id, [FromBody] PaaaResponse response)
        {
            try
            {
                var dto = _mapper.Map<PaaaDto>(response);
                dto.PkidPaaas = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return Conflict(new PagedResult<PaaaResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro programa anual activo para el mismo año y área",
                        Code = "DUPLICATE_AREA_ANIO",
                        TotalCount = 0
                    });
                }

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<PaaaResponse>
                {
                    Success = true,
                    Message = "Programa anual actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<PaaaResponse>
                {
                    Success = false,
                    Message = $"Programa anual con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<PaaaResponse>
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
                    Message = "Programa anual eliminado correctamente",
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
                    Message = $"Programa anual con ID {id} no encontrado",
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
        public async Task<ActionResult<PagedResult<PaaaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            try
            {
                var query = _serviceView.GetQueryWithIncludes();

                if (!string.IsNullOrWhiteSpace(request.Filtro))
                {
                    var filtro = request.Filtro.ToLower();
                    query = query.Where(e =>
                        (e.Descripcion != null && e.Descripcion.ToLower().Contains(filtro)) ||
                        (e.AreaNombre != null && e.AreaNombre.ToLower().Contains(filtro)) ||
                        (e.ResponsableCompleto != null && e.ResponsableCompleto.ToLower().Contains(filtro)));
                }

                if (!string.IsNullOrEmpty(request.SortLabel))
                {
                    var isAsc = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                    query = request.SortLabel switch
                    {
                        "PkidPaaas" => isAsc ? query.OrderBy(e => e.PkidPaaas) : query.OrderByDescending(e => e.PkidPaaas),
                        "Descripcion" => isAsc ? query.OrderBy(e => e.Descripcion) : query.OrderByDescending(e => e.Descripcion),
                        "AreaNombre" => isAsc ? query.OrderBy(e => e.AreaNombre) : query.OrderByDescending(e => e.AreaNombre),
                        "ResponsableCompleto" => isAsc ? query.OrderBy(e => e.ResponsableCompleto) : query.OrderByDescending(e => e.ResponsableCompleto),
                        "Fecha" => isAsc ? query.OrderBy(e => e.Fecha) : query.OrderByDescending(e => e.Fecha),
                        "Activo" => isAsc ? query.OrderBy(e => e.Activo) : query.OrderByDescending(e => e.Activo),
                        _ => query.OrderByDescending(e => e.PkidPaaas)
                    };
                }
                else
                {
                    query = query.OrderByDescending(e => e.PkidPaaas);
                }

                var totalItems = await query.CountAsync();
                var items = await query
                    .Skip((request.Page - 1) * request.PageSize)
                    .Take(request.PageSize)
                    .ToListAsync();

                return Ok(new PagedResult<PaaaResponse>
                {
                    Items = _mapper.Map<List<PaaaResponse>>(items),
                    TotalCount = totalItems,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                });
            }
            catch (Exception ex)
            {
                return Ok(new PagedResult<PaaaResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                });
            }
        }
    }
}
