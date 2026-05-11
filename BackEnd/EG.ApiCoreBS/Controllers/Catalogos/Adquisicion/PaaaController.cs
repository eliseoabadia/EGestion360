using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.Interfaces;
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
        private readonly IRepository<Paaaspartidum> _partidaRepository;
        private readonly EGestionContext _context;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public PaaaController(
            GenericService<Paaa, PaaaDto, PaaaResponse> service,
            GenericService<VwPaaa, PaaaDto, PaaaResponse> serviceView,
            IRepository<Paaaspartidum> partidaRepository,
            EGestionContext context,
            IMapper mapper,
            IUserContextService userContext)
        {
            _service = service;
            _serviceView = serviceView;
            _partidaRepository = partidaRepository;
            _context = context;
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
        _service.AddInclude(e => e.Paaaspartida);
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
                //dto.FkidEmpresaSis = _userContext.GetCurrentEmpresaId();
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

    [HttpGet("{id}/partidas")]
    public async Task<ActionResult<PagedResult<PaaaspartidumResponse>>> GetPartidasByPaaa(int id)
    {
        try
        {
            var paaa = await _context.Paaas.AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidPaaas == id && x.Activo);

            if (paaa == null)
                return NotFound(new PagedResult<PaaaspartidumResponse>
                {
                    Success = false, Message = "PAAA no encontrado", Code = "NOT_FOUND", TotalCount = 0
                });

            var partidas = await _context.VwPaaaspartida.AsNoTracking()
                .Where(x => x.FkidPaaasOrco == id && x.Activo)
                .OrderBy(x => x.PartidaClave)
                .ToListAsync();

            var response = _mapper.Map<List<PaaaspartidumResponse>>(partidas);

            return Ok(new PagedResult<PaaaspartidumResponse>
            {
                Items = response,
                TotalCount = response.Count,
                Success = true,
                Message = "Partidas obtenidas correctamente",
                Code = "SUCCESS"
            });
        }
        catch (Exception ex)
        {
            return Ok(new PagedResult<PaaaspartidumResponse>
            {
                Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
            });
        }
    }

    [HttpGet("partida/{partidaId}/detalles")]
    public async Task<ActionResult<PagedResult<PaaasdetalleResponse>>> GetDetallesByPartida(int partidaId)
    {
        try
        {
            var detalles = await _context.VwPaaasdetalles.AsNoTracking()
                .Where(x => x.FkidPaaaspartidaOrco == partidaId && x.Activo)
                .OrderBy(x => x.TipoBienCodigoClave)
                .ThenBy(x => x.TipoBienDescripcion)
                .ToListAsync();

            var response = _mapper.Map<List<PaaasdetalleResponse>>(detalles);

            return Ok(new PagedResult<PaaasdetalleResponse>
            {
                Items = response,
                TotalCount = response.Count,
                Success = true,
                Message = "OK",
                Code = "SUCCESS"
            });
        }
        catch (Exception ex)
        {
            return Ok(new PagedResult<PaaasdetalleResponse>
            {
                Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
            });
        }
    }

    [HttpPost("partida/{partidaId}/tipos-bien")]
    public async Task<ActionResult<PagedResult<LookupItem>>> GetTiposBienByPartida(int partidaId, [FromBody] PagedRequest request)
    {
        try
        {
            var partida = await _context.Paaaspartida.AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidPaaaspartida == partidaId && x.Activo);

            if (partida == null)
                return NotFound(new PagedResult<LookupItem>
                {
                    Success = false,
                    Message = "Partida no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            var page = request.Page < 1 ? 1 : request.Page;
            var pageSize = request.PageSize <= 0 ? 25 : request.PageSize;
            var filtro = request.Filtro?.Trim() ?? string.Empty;

            var query = _context.TipoBiens.AsNoTracking()
                .Where(x => x.Activo && x.FkidPartidaConta == partida.FkidPartidaConta);

            if (!string.IsNullOrWhiteSpace(filtro))
            {
                query = query.Where(x =>
                    (x.CodigoClave != null && x.CodigoClave.Contains(filtro)) ||
                    (x.Descripcion != null && x.Descripcion.Contains(filtro)));
            }

            query = query.OrderBy(x => x.CodigoClave).ThenBy(x => x.Descripcion);

            var totalItems = await query.CountAsync();
            var items = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(x => new LookupItem
                {
                    Id = x.PkidTipoBien,
                    Text = (x.CodigoClave ?? string.Empty) + " - " + (x.Descripcion ?? string.Empty)
                })
                .ToListAsync();

            return Ok(new PagedResult<LookupItem>
            {
                Items = items,
                TotalCount = totalItems,
                Success = true,
                Message = "Tipos de bien obtenidos correctamente",
                Code = "SUCCESS"
            });
        }
        catch (Exception ex)
        {
            return Ok(new PagedResult<LookupItem>
            {
                Success = false,
                Message = $"Error interno: {ex.Message}",
                Code = "ERROR",
                TotalCount = 0
            });
        }
    }

    [HttpPost("partida")]
    public async Task<ActionResult<PagedResult<PaaaspartidumResponse>>> CreatePartida([FromBody] PaaaspartidaDto dto)
    {
        try
        {
            var entity = _mapper.Map<Paaaspartidum>(dto);
            entity.FechaCreacion = DateTime.Now;
            entity.UsuarioCreacion = _userContext.GetCurrentUserId();

            await _partidaRepository.AddAsync(entity);

            var response = _mapper.Map<PaaaspartidumResponse>(entity);

            return CreatedAtAction(nameof(GetPartidasByPaaa), new { id = entity.FkidPaaasOrco },
                new PagedResult<PaaaspartidumResponse>
                {
                    Items = new List<PaaaspartidumResponse> { response },
                    TotalCount = 1,
                    Success = true,
                    Message = "Partida creada correctamente",
                    Code = "SUCCESS"
                });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<PaaaspartidumResponse>
            {
                Success = false,
                Message = $"Error al crear partida: {ex.Message}",
                Code = "ERROR",
                TotalCount = 0
            });
        }
    }

    [HttpPost("detalle")]
    public async Task<ActionResult<PagedResult<PaaasdetalleResponse>>> CreateDetalle([FromBody] PaaasdetalleDto dto)
    {
        try
        {
            var validation = await ValidateDetalleAsync(dto);
            if (validation.Result != null)
                return validation.Result;

            var (partida, tipoBien) = validation.Value;
            var entity = _mapper.Map<Paaasdetalle>(dto);
            entity.FkidEmpresaSis = dto.FkidEmpresaSis > 0 ? dto.FkidEmpresaSis : partida.FkidEmpresaSis;
            entity.FkidUnidadesAlma = dto.FkidUnidadesAlma ?? tipoBien.FkidUnidadesAlma;
            entity.Observaciones = dto.Observaciones ?? string.Empty;
            entity.LugarEntrega = dto.LugarEntrega ?? string.Empty;
            entity.Activo = true;
            entity.FechaCreacion = DateTime.Now;
            entity.UsuarioCreacion = _userContext.GetCurrentUserId();

            await _context.Paaasdetalles.AddAsync(entity);
            await _context.SaveChangesAsync();

            var response = await GetDetalleResponseAsync(entity.PkidPaaasdetalle)
                ?? _mapper.Map<PaaasdetalleResponse>(entity);

            return CreatedAtAction(nameof(GetDetallesByPartida), new { partidaId = entity.FkidPaaaspartidaOrco },
                new PagedResult<PaaasdetalleResponse>
                {
                    Data = response,
                    Items = new List<PaaasdetalleResponse> { response },
                    TotalCount = 1,
                    Success = true,
                    Message = "Tipo de bien agregado correctamente",
                    Code = "SUCCESS"
                });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<PaaasdetalleResponse>
            {
                Success = false,
                Message = $"Error al agregar tipo de bien: {ex.Message}",
                Code = "ERROR",
                TotalCount = 0
            });
        }
    }

    [HttpPut("detalle/{detalleId}")]
    public async Task<ActionResult<PagedResult<PaaasdetalleResponse>>> UpdateDetalle(int detalleId, [FromBody] PaaasdetalleDto dto)
    {
        try
        {
            var entity = await _context.Paaasdetalles
                .FirstOrDefaultAsync(x => x.PkidPaaasdetalle == detalleId && x.Activo);

            if (entity == null)
                return NotFound(new PagedResult<PaaasdetalleResponse>
                {
                    Success = false,
                    Message = "Detalle no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            dto.PkidPaaasdetalle = detalleId;
            var validation = await ValidateDetalleAsync(dto);
            if (validation.Result != null)
                return validation.Result;

            var (_, tipoBien) = validation.Value;
            entity.FkidPaaaspartidaOrco = dto.FkidPaaaspartidaOrco;
            entity.FkidTipoBienAlma = dto.FkidTipoBienAlma;
            entity.FkidUnidadesAlma = dto.FkidUnidadesAlma ?? tipoBien.FkidUnidadesAlma;
            entity.Cantidad = dto.Cantidad;
            entity.Observaciones = dto.Observaciones ?? string.Empty;
            entity.LugarEntrega = dto.LugarEntrega ?? string.Empty;
            entity.FechaModificacion = DateTime.Now;
            entity.UsuarioModificacion = _userContext.GetCurrentUserId();

            await _context.SaveChangesAsync();

            var response = await GetDetalleResponseAsync(detalleId)
                ?? _mapper.Map<PaaasdetalleResponse>(entity);

            return Ok(new PagedResult<PaaasdetalleResponse>
            {
                Data = response,
                Items = new List<PaaasdetalleResponse> { response },
                TotalCount = 1,
                Success = true,
                Message = "Tipo de bien actualizado correctamente",
                Code = "SUCCESS"
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<PaaasdetalleResponse>
            {
                Success = false,
                Message = $"Error al actualizar tipo de bien: {ex.Message}",
                Code = "ERROR",
                TotalCount = 0
            });
        }
    }

    [HttpDelete("detalle/{detalleId}")]
    public async Task<ActionResult<PagedResult<bool>>> DeleteDetalle(int detalleId)
    {
        try
        {
            var entity = await _context.Paaasdetalles
                .FirstOrDefaultAsync(x => x.PkidPaaasdetalle == detalleId && x.Activo);

            if (entity == null)
                return NotFound(new PagedResult<bool>
                {
                    Success = false,
                    Message = "Detalle no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            entity.Activo = false;
            entity.FechaModificacion = DateTime.Now;
            entity.UsuarioModificacion = _userContext.GetCurrentUserId();
            await _context.SaveChangesAsync();

            return Ok(new PagedResult<bool>
            {
                Success = true,
                Message = "Tipo de bien eliminado correctamente",
                Code = "SUCCESS",
                Data = true,
                Items = new List<bool> { true },
                TotalCount = 1
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<bool>
            {
                Success = false,
                Message = $"Error al eliminar tipo de bien: {ex.Message}",
                Code = "ERROR",
                TotalCount = 0
            });
        }
    }

    private async Task<(ActionResult<PagedResult<PaaasdetalleResponse>>? Result, (Paaaspartidum Partida, TipoBien TipoBien) Value)> ValidateDetalleAsync(PaaasdetalleDto dto)
    {
        if (dto.FkidPaaaspartidaOrco <= 0)
        {
            return (BadRequest(new PagedResult<PaaasdetalleResponse>
            {
                Success = false,
                Message = "Debe seleccionar una partida valida",
                Code = "INVALID_PARTIDA",
                TotalCount = 0
            }), default);
        }

        if (dto.FkidTipoBienAlma <= 0)
        {
            return (BadRequest(new PagedResult<PaaasdetalleResponse>
            {
                Success = false,
                Message = "Debe seleccionar un tipo de bien valido",
                Code = "INVALID_TIPO_BIEN",
                TotalCount = 0
            }), default);
        }

        if (dto.Cantidad <= 0)
        {
            return (BadRequest(new PagedResult<PaaasdetalleResponse>
            {
                Success = false,
                Message = "La cantidad debe ser mayor a cero",
                Code = "INVALID_CANTIDAD",
                TotalCount = 0
            }), default);
        }

        var partida = await _context.Paaaspartida.AsNoTracking()
            .FirstOrDefaultAsync(x => x.PkidPaaaspartida == dto.FkidPaaaspartidaOrco && x.Activo);

        if (partida == null)
        {
            return (NotFound(new PagedResult<PaaasdetalleResponse>
            {
                Success = false,
                Message = "Partida no encontrada",
                Code = "NOT_FOUND",
                TotalCount = 0
            }), default);
        }

        var tipoBien = await _context.TipoBiens.AsNoTracking()
            .FirstOrDefaultAsync(x => x.PkidTipoBien == dto.FkidTipoBienAlma && x.Activo);

        if (tipoBien == null)
        {
            return (NotFound(new PagedResult<PaaasdetalleResponse>
            {
                Success = false,
                Message = "Tipo de bien no encontrado",
                Code = "NOT_FOUND",
                TotalCount = 0
            }), default);
        }

        if (tipoBien.FkidPartidaConta != partida.FkidPartidaConta)
        {
            return (BadRequest(new PagedResult<PaaasdetalleResponse>
            {
                Success = false,
                Message = "El tipo de bien no pertenece a la partida seleccionada",
                Code = "TIPO_BIEN_PARTIDA_MISMATCH",
                TotalCount = 0
            }), default);
        }

        return (null, (partida, tipoBien));
    }

    private async Task<PaaasdetalleResponse?> GetDetalleResponseAsync(int detalleId)
    {
        var view = await _context.VwPaaasdetalles.AsNoTracking()
            .FirstOrDefaultAsync(x => x.PkidPaaasdetalle == detalleId && x.Activo);

        return view == null ? null : _mapper.Map<PaaasdetalleResponse>(view);
    }

    [HttpDelete("partida/{partidaId}")]
    public async Task<ActionResult<PagedResult<bool>>> DeletePartida(int partidaId)
    {
        try
        {
            var repoDetalle = HttpContext.RequestServices.GetRequiredService<IRepository<Paaasdetalle>>();
            var detalles = await repoDetalle.GetAllWithIncludesAsync(d => d.FkidPaaaspartidaOrco == partidaId);
            foreach (var detalle in detalles)
                await repoDetalle.DeleteAsync(detalle.PkidPaaasdetalle);

            await _partidaRepository.DeleteAsync(partidaId);
            return Ok(new PagedResult<bool>
            {
                Success = true,
                Message = "Partida eliminada correctamente",
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
                Message = "Partida no encontrada",
                Code = "NOT_FOUND",
                TotalCount = 0
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new PagedResult<bool>
            {
                Success = false,
                Message = $"Error al eliminar partida: {ex.Message}",
                Code = "ERROR",
                TotalCount = 0
            });
        }
    }
}
}
