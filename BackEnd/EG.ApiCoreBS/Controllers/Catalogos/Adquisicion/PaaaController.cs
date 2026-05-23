using Mapster;
using EG.Application.Services.Adquisicion;
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
using System.Text.Json;

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
        private readonly IUserContextService _userContext;

        public PaaaController(
            GenericService<Paaa, PaaaDto, PaaaResponse> service,
            GenericService<VwPaaa, PaaaDto, PaaaResponse> serviceView,
            IRepository<Paaaspartidum> partidaRepository,
            EGestionContext context,
            IUserContextService userContext)
        {
            _service = service;
            _serviceView = serviceView;
            _partidaRepository = partidaRepository;
            _context = context;
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
                var dto = response.Adapt<PaaaDto>();
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

                var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    "[ORCO].[SP_MantenimientoPAAAS]",
                    StoredProcedureExecutor.Param("@Action", 1),
                    StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", dto.FkidEmpresaSis),
                    StoredProcedureExecutor.Param("@FKIdAnio_SIS", dto.FkidAnioSis),
                    StoredProcedureExecutor.Param("@FKIdArea_SIS", dto.FkidAreaSis),
                    StoredProcedureExecutor.Param("@FKIdPersona_NOM", dto.FkidPersonaNom),
                    StoredProcedureExecutor.Param("@Descripcion", dto.Descripcion),
                    StoredProcedureExecutor.Param("@Observaciones", dto.Observaciones),
                    StoredProcedureExecutor.Param("@Fecha", dto.Fecha),
                    StoredProcedureExecutor.Param("@FKIdProyecto_ORCO", dto.FkidProyectoOrco),
                    StoredProcedureExecutor.Param("@FKIdPrograma_PRES", dto.FkidProgramaPres),
                    StoredProcedureExecutor.Param("@FKIdFuenteFinanciamiento_PRES", dto.FkidFuenteFinanciamientoPres),
                    StoredProcedureExecutor.Param("@IdUser", dto.UsuarioCreacion));

                dto.PkidPaaas = spResult.GetId() ?? 0;

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidPaaas },
                    new PagedResult<PaaaResponse>
                    {
                        Success = true,
                        Message = spResult.Mensaje,
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
                var dto = response.Adapt<PaaaDto>();
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

                var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    "[ORCO].[SP_MantenimientoPAAAS]",
                    StoredProcedureExecutor.Param("@Action", 2),
                    StoredProcedureExecutor.Param("@PKIdPAAAS", id),
                    StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", dto.FkidEmpresaSis),
                    StoredProcedureExecutor.Param("@FKIdAnio_SIS", dto.FkidAnioSis),
                    StoredProcedureExecutor.Param("@FKIdArea_SIS", dto.FkidAreaSis),
                    StoredProcedureExecutor.Param("@FKIdPersona_NOM", dto.FkidPersonaNom),
                    StoredProcedureExecutor.Param("@Descripcion", dto.Descripcion),
                    StoredProcedureExecutor.Param("@Observaciones", dto.Observaciones),
                    StoredProcedureExecutor.Param("@Fecha", dto.Fecha),
                    StoredProcedureExecutor.Param("@FKIdProyecto_ORCO", dto.FkidProyectoOrco),
                    StoredProcedureExecutor.Param("@FKIdPrograma_PRES", dto.FkidProgramaPres),
                    StoredProcedureExecutor.Param("@FKIdFuenteFinanciamiento_PRES", dto.FkidFuenteFinanciamientoPres),
                    StoredProcedureExecutor.Param("@IdUser", dto.UsuarioModificacion));

                return Ok(new PagedResult<PaaaResponse>
                {
                    Success = true,
                    Message = spResult.Mensaje,
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
                var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    "[ORCO].[SP_MantenimientoPAAAS]",
                    StoredProcedureExecutor.Param("@Action", 3),
                    StoredProcedureExecutor.Param("@PKIdPAAAS", id),
                    StoredProcedureExecutor.Param("@IdUser", _userContext.GetCurrentUserId()));
                return Ok(new PagedResult<bool>
                {
                    Success = true,
                    Message = spResult.Mensaje,
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

                if (TryGetIntFilter(request, "FkidAnioSis", out var anioId))
                {
                    query = query.Where(e => e.FkidAnioSis == anioId);
                }

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
                    Items = items.Adapt<List<PaaaResponse>>(),
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

            var response = partidas.Adapt<List<PaaaspartidumResponse>>();

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

            var response = detalles.Adapt<List<PaaasdetalleResponse>>();

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
            var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                _context,
                "[ORCO].[SP_MantenimientoPAAAS]",
                StoredProcedureExecutor.Param("@Action", 5),
                StoredProcedureExecutor.Param("@PKIdPAAAS", dto.FkidPaaasOrco),
                StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", dto.FkidEmpresaSis),
                StoredProcedureExecutor.Param("@FKIdPartida_CONTA", dto.FkidPartidaConta),
                StoredProcedureExecutor.Param("@Observaciones", dto.Observaciones),
                StoredProcedureExecutor.Param("@IdUser", _userContext.GetCurrentUserId()));

            var partidaId = spResult.GetId() ?? 0;
            var response = (await _context.VwPaaaspartida.AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidPaaaspartida == partidaId))?.Adapt<PaaaspartidumResponse>()
                ?? new PaaaspartidumResponse { PkidPaaaspartida = partidaId, FkidPaaasOrco = dto.FkidPaaasOrco };

            return CreatedAtAction(nameof(GetPartidasByPaaa), new { id = dto.FkidPaaasOrco },
                new PagedResult<PaaaspartidumResponse>
                {
                    Items = new List<PaaaspartidumResponse> { response },
                    TotalCount = 1,
                    Success = true,
                    Message = spResult.Mensaje,
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
                var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    "[ORCO].[SP_MantenimientoPAAAS]",
                    StoredProcedureExecutor.Param("@Action", 7),
                    StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", dto.FkidEmpresaSis),
                    StoredProcedureExecutor.Param("@PKIdPAAASPartida", dto.FkidPaaaspartidaOrco),
                    StoredProcedureExecutor.Param("@FKIdTipoBien_ALMA", dto.FkidTipoBienAlma),
                    StoredProcedureExecutor.Param("@FKIdUnidades_ALMA", dto.FkidUnidadesAlma),
                    StoredProcedureExecutor.Param("@Cantidad", dto.Cantidad),
                    StoredProcedureExecutor.Param("@Observaciones", dto.Observaciones),
                    StoredProcedureExecutor.Param("@LugarEntrega", dto.LugarEntrega),
                    StoredProcedureExecutor.Param("@IdUser", _userContext.GetCurrentUserId()));

                var detalleId = spResult.GetId() ?? 0;
                var response = await GetDetalleResponseAsync(detalleId)
                    ?? new PaaasdetalleResponse { PkidPaaasdetalle = detalleId };

            return CreatedAtAction(nameof(GetDetallesByPartida), new { partidaId = dto.FkidPaaaspartidaOrco },
                new PagedResult<PaaasdetalleResponse>
                {
                    Data = response,
                    Items = new List<PaaasdetalleResponse> { response },
                    TotalCount = 1,
                    Success = true,
                    Message = spResult.Mensaje,
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
            var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                _context,
                "[ORCO].[SP_MantenimientoPAAAS]",
                StoredProcedureExecutor.Param("@Action", 8),
                StoredProcedureExecutor.Param("@PKIdPAAASDetalle", detalleId),
                StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", dto.FkidEmpresaSis),
                StoredProcedureExecutor.Param("@PKIdPAAASPartida", dto.FkidPaaaspartidaOrco),
                StoredProcedureExecutor.Param("@FKIdTipoBien_ALMA", dto.FkidTipoBienAlma),
                StoredProcedureExecutor.Param("@FKIdUnidades_ALMA", dto.FkidUnidadesAlma),
                StoredProcedureExecutor.Param("@Cantidad", dto.Cantidad),
                StoredProcedureExecutor.Param("@Observaciones", dto.Observaciones),
                StoredProcedureExecutor.Param("@LugarEntrega", dto.LugarEntrega),
                StoredProcedureExecutor.Param("@IdUser", _userContext.GetCurrentUserId()));

            var response = await GetDetalleResponseAsync(detalleId)
                ?? new PaaasdetalleResponse { PkidPaaasdetalle = detalleId };

            return Ok(new PagedResult<PaaasdetalleResponse>
            {
                Data = response,
                Items = new List<PaaasdetalleResponse> { response },
                TotalCount = 1,
                Success = true,
                Message = spResult.Mensaje,
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
            var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                _context,
                "[ORCO].[SP_MantenimientoPAAAS]",
                StoredProcedureExecutor.Param("@Action", 9),
                StoredProcedureExecutor.Param("@PKIdPAAASDetalle", detalleId),
                StoredProcedureExecutor.Param("@IdUser", _userContext.GetCurrentUserId()));

            return Ok(new PagedResult<bool>
            {
                Success = true,
                Message = spResult.Mensaje,
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

        return view == null ? null : view.Adapt<PaaasdetalleResponse>();
    }

    private static bool TryGetIntFilter(PagedRequest request, string key, out int value)
    {
        value = 0;
        if (request.AdditionalFilters == null || !request.AdditionalFilters.TryGetValue(key, out var raw) || raw == null)
            return false;

        if (raw is JsonElement json)
        {
            if (json.ValueKind == JsonValueKind.Number && json.TryGetInt32(out value))
                return true;

            if (json.ValueKind == JsonValueKind.String && int.TryParse(json.GetString(), out value))
                return true;
        }

        return int.TryParse(raw.ToString(), out value);
    }

    [HttpDelete("partida/{partidaId}")]
    public async Task<ActionResult<PagedResult<bool>>> DeletePartida(int partidaId)
    {
        try
        {
            var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                _context,
                "[ORCO].[SP_MantenimientoPAAAS]",
                StoredProcedureExecutor.Param("@Action", 6),
                StoredProcedureExecutor.Param("@PKIdPAAASPartida", partidaId),
                StoredProcedureExecutor.Param("@IdUser", _userContext.GetCurrentUserId()));
            return Ok(new PagedResult<bool>
            {
                Success = true,
                Message = spResult.Mensaje,
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
