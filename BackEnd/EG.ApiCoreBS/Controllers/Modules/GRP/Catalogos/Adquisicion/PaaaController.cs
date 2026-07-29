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
                        && x.FkidEmpresaSis == pDto.FkidEmpresaSis
                        && x.Activo
                        && (!id.HasValue || x.PkidPaaas != id.Value));
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<PaaaResponse>>> GetAll()
        {
            try
            {
                var companyId = _userContext.GetCurrentEmpresaId();
                var areaIds = await GetAuthorizedAreaIdsAsync();
                var views = await _context.VwPaaas.AsNoTracking()
                    .Where(x => x.Activo && x.FkidEmpresaSis == companyId && areaIds.Contains(x.FkidAreaSis))
                    .OrderByDescending(x => x.PkidPaaas).ToListAsync();
                var items = views.Adapt<List<PaaaResponse>>();
                await MarkLockedAsync(items);
                return Ok(new PagedResult<PaaaResponse>
                {
                    Items = items,
                    TotalCount = items.Count,
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
                var companyId = _userContext.GetCurrentEmpresaId();
                var areaIds = await GetAuthorizedAreaIdsAsync();
                var view = await _context.VwPaaas.AsNoTracking()
                    .FirstOrDefaultAsync(x => x.PkidPaaas == id && x.Activo && x.FkidEmpresaSis == companyId && areaIds.Contains(x.FkidAreaSis));
                if (view == null)
                    return NotFound(new PagedResult<PaaaResponse>
                    {
                        Success = false, Message = "Programa anual no encontrado", Code = "NOT_FOUND", TotalCount = 0
                    });

                var result = view.Adapt<PaaaResponse>();
                await MarkLockedAsync(new List<PaaaResponse> { result });
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
                dto.FkidEmpresaSis = _userContext.GetCurrentEmpresaId();
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await IsAuthorizedAreaAsync(dto.FkidAreaSis))
                    return Forbid();

                if (!await ProyectoOrcoExistsAsync(dto.FkidProyectoOrco, dto.UsuarioCreacion))
                {
                    return BadRequest(InvalidProyectoResult(dto.FkidProyectoOrco));
                }

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
                    "[ORCO].[SP_MantenimientoPAAASV2]",
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
                dto.FkidEmpresaSis = _userContext.GetCurrentEmpresaId();
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                if (!await OwnsPaaaAsync(id) || await IsPaaaLockedAsync(id))
                    return Conflict(new PagedResult<PaaaResponse> { Success = false, Message = "El programa esta bloqueado por un estudio de mercado activo o no pertenece a la empresa actual.", Code = "PAAA_LOCKED", TotalCount = 0 });
                if (!await IsAuthorizedAreaAsync(dto.FkidAreaSis))
                    return Forbid();

                if (!await ProyectoOrcoExistsAsync(dto.FkidProyectoOrco, dto.UsuarioModificacion ?? _userContext.GetCurrentUserId()))
                {
                    return BadRequest(InvalidProyectoResult(dto.FkidProyectoOrco));
                }

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
                    "[ORCO].[SP_MantenimientoPAAASV2]",
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
                if (!await OwnsPaaaAsync(id) || await IsPaaaLockedAsync(id))
                    return Conflict(new PagedResult<bool> { Success = false, Message = "El programa esta bloqueado por un estudio de mercado activo o no pertenece a la empresa actual.", Code = "PAAA_LOCKED", TotalCount = 0 });
                var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    "[ORCO].[SP_MantenimientoPAAASV2]",
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
                var companyId = _userContext.GetCurrentEmpresaId();
                var areaIds = await GetAuthorizedAreaIdsAsync();
                var query = _serviceView.GetQueryWithIncludes()
                    .Where(e => e.Activo && e.FkidEmpresaSis == companyId && areaIds.Contains(e.FkidAreaSis));

                if (TryGetIntFilter(request, "FkidAnioSis", out var anioId) && anioId > 0)
                {
                    query = query.Where(e => e.FkidAnioSis == anioId);
                }
                else
                {
                    return BadRequest(new PagedResult<PaaaResponse> { Success = false, Message = "El ejercicio presupuestal es obligatorio.", Code = "YEAR_REQUIRED", TotalCount = 0 });
                }

                if (!string.IsNullOrWhiteSpace(request.Filtro))
                {
                    var filtro = request.Filtro.Trim();
                    query = query.Where(e =>
                        (e.Descripcion != null && e.Descripcion.Contains(filtro)) ||
                        (e.AreaNombre != null && e.AreaNombre.Contains(filtro)) ||
                        (e.ResponsableCompleto != null && e.ResponsableCompleto.Contains(filtro)));
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

                var responses = items.Adapt<List<PaaaResponse>>();
                await MarkLockedAsync(responses);
                return Ok(new PagedResult<PaaaResponse>
                {
                    Items = responses,
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
            var paaa = await GetOwnedPaaaAsync(id);

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
            var partida = await GetOwnedPartidaAsync(partidaId);
            if (partida == null)
                return NotFound(new PagedResult<PaaasdetalleResponse> { Success = false, Message = "Partida no encontrada", Code = "NOT_FOUND", TotalCount = 0 });
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
            var partida = await GetOwnedPartidaAsync(partidaId);

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
            var paaa = await GetOwnedPaaaAsync(dto.FkidPaaasOrco);
            if (paaa == null) return NotFound();
            if (await IsPaaaLockedAsync(paaa.PkidPaaas))
                return Conflict(new PagedResult<PaaaspartidumResponse> { Success = false, Message = "El programa esta bloqueado por un estudio de mercado activo.", Code = "PAAA_LOCKED", TotalCount = 0 });
            if (!await IsPartidaAvailableAsync(paaa, dto.FkidPartidaConta))
                return BadRequest(new PagedResult<PaaaspartidumResponse> { Success = false, Message = "La partida no tiene presupuesto autorizado para el ejercicio, area y estructura del programa.", Code = "PARTIDA_NOT_AVAILABLE", TotalCount = 0 });
            dto.FkidEmpresaSis = _userContext.GetCurrentEmpresaId();
            var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                _context,
                "[ORCO].[SP_MantenimientoPAAASV2]",
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
                var validation = await ValidateDetalleAsync(dto);
                if (validation.Result != null) return validation.Result;
                var paaaId = validation.Value.Partida.FkidPaaasOrco;
                if (await IsPaaaLockedAsync(paaaId))
                    return Conflict(new PagedResult<PaaasdetalleResponse> { Success = false, Message = "El programa esta bloqueado por un estudio de mercado activo.", Code = "PAAA_LOCKED", TotalCount = 0 });
                dto.FkidEmpresaSis = _userContext.GetCurrentEmpresaId();
                var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    "[ORCO].[SP_MantenimientoPAAASV2]",
                    StoredProcedureExecutor.Param("@Action", 7),
                    StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", dto.FkidEmpresaSis),
                    StoredProcedureExecutor.Param("@PKIdPAAASPartida", dto.FkidPaaaspartidaOrco),
                    StoredProcedureExecutor.Param("@FKIdTipoBien_ALMA", dto.FkidTipoBienAlma),
                    StoredProcedureExecutor.Param("@FKIdUnidades_ALMA", dto.FkidUnidadesAlma),
                    StoredProcedureExecutor.Param("@FKIdMes_SIS", dto.FkidMesSis),
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
            var existing = await _context.Paaasdetalles.AsNoTracking().FirstOrDefaultAsync(x => x.PkidPaaasdetalle == detalleId && x.Activo);
            if (existing == null) return NotFound();
            dto.FkidPaaaspartidaOrco = existing.FkidPaaaspartidaOrco;
            var validation = await ValidateDetalleAsync(dto);
            if (validation.Result != null) return validation.Result;
            if (await IsPaaaLockedAsync(validation.Value.Partida.FkidPaaasOrco))
                return Conflict(new PagedResult<PaaasdetalleResponse> { Success = false, Message = "El programa esta bloqueado por un estudio de mercado activo.", Code = "PAAA_LOCKED", TotalCount = 0 });
            dto.FkidEmpresaSis = _userContext.GetCurrentEmpresaId();
            var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                _context,
                "[ORCO].[SP_MantenimientoPAAASV2]",
                StoredProcedureExecutor.Param("@Action", 8),
                StoredProcedureExecutor.Param("@PKIdPAAASDetalle", detalleId),
                StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", dto.FkidEmpresaSis),
                StoredProcedureExecutor.Param("@PKIdPAAASPartida", dto.FkidPaaaspartidaOrco),
                StoredProcedureExecutor.Param("@FKIdTipoBien_ALMA", dto.FkidTipoBienAlma),
                StoredProcedureExecutor.Param("@FKIdUnidades_ALMA", dto.FkidUnidadesAlma),
                StoredProcedureExecutor.Param("@FKIdMes_SIS", dto.FkidMesSis),
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
            var paaaId = await GetPaaaIdByDetalleAsync(detalleId);
            if (!paaaId.HasValue) return NotFound();
            if (await IsPaaaLockedAsync(paaaId.Value))
                return Conflict(new PagedResult<bool> { Success = false, Message = "El programa esta bloqueado por un estudio de mercado activo.", Code = "PAAA_LOCKED", TotalCount = 0 });
            var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                _context,
                "[ORCO].[SP_MantenimientoPAAASV2]",
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

        if (!dto.FkidMesSis.HasValue || !await _context.Mes.AsNoTracking().AnyAsync(x => x.PkidMes == dto.FkidMesSis && x.Activo == true))
        {
            return (BadRequest(new PagedResult<PaaasdetalleResponse>
            {
                Success = false, Message = "Debe seleccionar un mes activo", Code = "INVALID_MONTH", TotalCount = 0
            }), default);
        }

        var partida = await GetOwnedPartidaAsync(dto.FkidPaaaspartidaOrco);

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

    [HttpPost("{id}/partidas-disponibles")]
    public async Task<ActionResult<PagedResult<LookupItem>>> GetPartidasDisponibles(int id, [FromBody] PagedRequest request)
    {
        var paaa = await GetOwnedPaaaAsync(id);
        if (paaa == null) return NotFound();

        var query = _context.VwEgresoDisponibles.AsNoTracking()
            .Where(x => x.FkidAnioSis == paaa.FkidAnioSis && x.FkidAreaSis == paaa.FkidAreaSis);
        if (paaa.FkidProgramaPres.HasValue) query = query.Where(x => x.FkidProgramaPres == paaa.FkidProgramaPres.Value);
        if (paaa.FkidFuenteFinanciamientoPres.HasValue) query = query.Where(x => x.FkidFuenteFinanciamientoPres == paaa.FkidFuenteFinanciamientoPres.Value);

        var partidas = query.Select(x => new { x.FkidPartidaConta, x.PartidaClave, x.PartidaDescripcion }).Distinct();
        if (!string.IsNullOrWhiteSpace(request.Filtro))
        {
            var filter = request.Filtro.Trim();
            partidas = partidas.Where(x => x.PartidaClave.Contains(filter) || x.PartidaDescripcion.Contains(filter));
        }

        var page = Math.Max(1, request.Page);
        var pageSize = request.PageSize <= 0 ? 25 : request.PageSize;
        var total = await partidas.CountAsync();
        var items = await partidas.OrderBy(x => x.PartidaClave).Skip((page - 1) * pageSize).Take(pageSize)
            .Select(x => new LookupItem { Id = x.FkidPartidaConta, Text = x.PartidaClave + " - " + x.PartidaDescripcion }).ToListAsync();
        return Ok(new PagedResult<LookupItem> { Success = true, Code = "SUCCESS", Message = "Partidas disponibles", Items = items, TotalCount = total });
    }

    [HttpPost("meses")]
    public async Task<ActionResult<PagedResult<LookupItem>>> GetMeses([FromBody] PagedRequest request)
    {
        var query = _context.Mes.AsNoTracking().Where(x => x.Activo == true);
        if (!string.IsNullOrWhiteSpace(request.Filtro))
        {
            var filter = request.Filtro.Trim();
            query = query.Where(x => x.Descripcion.Contains(filter) || x.Abreviatura.Contains(filter));
        }
        var page = Math.Max(1, request.Page);
        var pageSize = request.PageSize <= 0 ? 25 : request.PageSize;
        var total = await query.CountAsync();
        var items = await query.OrderBy(x => x.PkidMes).Skip((page - 1) * pageSize).Take(pageSize)
            .Select(x => new LookupItem { Id = x.PkidMes, Text = x.Descripcion }).ToListAsync();
        return Ok(new PagedResult<LookupItem> { Success = true, Code = "SUCCESS", Message = "Meses", Items = items, TotalCount = total });
    }

    private async Task<List<int>> GetAuthorizedAreaIdsAsync()
    {
        var userId = _userContext.GetCurrentUserId();
        return await _context.VwUsuarioPersonaAreas.AsNoTracking()
            .Where(x => x.PkIdUsuario == userId && x.UsuarioActivo && x.PersonaActivo == true && x.AreaActivo == true && x.PkidArea.HasValue)
            .Select(x => x.PkidArea!.Value).Distinct().ToListAsync();
    }

    private async Task<bool> IsAuthorizedAreaAsync(int areaId) => (await GetAuthorizedAreaIdsAsync()).Contains(areaId);

    private async Task<Paaa?> GetOwnedPaaaAsync(int id)
    {
        var companyId = _userContext.GetCurrentEmpresaId();
        var areaIds = await GetAuthorizedAreaIdsAsync();
        return await _context.Paaas.AsNoTracking().FirstOrDefaultAsync(x => x.PkidPaaas == id && x.Activo && x.FkidEmpresaSis == companyId && areaIds.Contains(x.FkidAreaSis));
    }

    private async Task<bool> OwnsPaaaAsync(int id) => await GetOwnedPaaaAsync(id) != null;

    private async Task<Paaaspartidum?> GetOwnedPartidaAsync(int id)
    {
        var partida = await _context.Paaaspartida.AsNoTracking().FirstOrDefaultAsync(x => x.PkidPaaaspartida == id && x.Activo);
        return partida != null && await OwnsPaaaAsync(partida.FkidPaaasOrco) ? partida : null;
    }

    private async Task<int?> GetPaaaIdByDetalleAsync(int detalleId) => await _context.Paaasdetalles.AsNoTracking()
        .Where(x => x.PkidPaaasdetalle == detalleId && x.Activo)
        .Select(x => (int?)x.FkidPaaaspartidaOrcoNavigation.FkidPaaasOrco).FirstOrDefaultAsync();

    private Task<bool> IsPaaaLockedAsync(int id) => _context.EstudioMercadoDetalles.AsNoTracking().AnyAsync(d =>
        d.Activo && d.FkidPaaasdetalleOrcoNavigation.Activo && d.FkidPaaasdetalleOrcoNavigation.FkidPaaaspartidaOrcoNavigation.Activo &&
        d.FkidPaaasdetalleOrcoNavigation.FkidPaaaspartidaOrcoNavigation.FkidPaaasOrco == id &&
        d.FkidEstudioMercadoOrcoNavigation.Activo && d.FkidEstudioMercadoOrcoNavigation.Estatus != 5);

    private async Task MarkLockedAsync(List<PaaaResponse> items)
    {
        if (items.Count == 0) return;
        var ids = items.Select(x => x.PkidPaaas).ToList();
        var lockedIds = await _context.EstudioMercadoDetalles.AsNoTracking()
            .Where(d => d.Activo && d.FkidPaaasdetalleOrcoNavigation.Activo && d.FkidPaaasdetalleOrcoNavigation.FkidPaaaspartidaOrcoNavigation.Activo &&
                ids.Contains(d.FkidPaaasdetalleOrcoNavigation.FkidPaaaspartidaOrcoNavigation.FkidPaaasOrco) &&
                d.FkidEstudioMercadoOrcoNavigation.Activo && d.FkidEstudioMercadoOrcoNavigation.Estatus != 5)
            .Select(d => d.FkidPaaasdetalleOrcoNavigation.FkidPaaaspartidaOrcoNavigation.FkidPaaasOrco).Distinct().ToListAsync();
        foreach (var item in items) item.BloqueadoPorEstudioMercado = lockedIds.Contains(item.PkidPaaas);
    }

    private Task<bool> IsPartidaAvailableAsync(Paaa paaa, int partidaId)
    {
        return _context.VwEgresoDisponibles.AsNoTracking().AnyAsync(x => x.FkidAnioSis == paaa.FkidAnioSis &&
            x.FkidAreaSis == paaa.FkidAreaSis && x.FkidPartidaConta == partidaId &&
            (!paaa.FkidProgramaPres.HasValue || x.FkidProgramaPres == paaa.FkidProgramaPres.Value) &&
            (!paaa.FkidFuenteFinanciamientoPres.HasValue || x.FkidFuenteFinanciamientoPres == paaa.FkidFuenteFinanciamientoPres.Value));
    }

    private Task<bool> ProyectoOrcoExistsAsync(int? proyectoId, int usuarioId)
    {
        return OrcoProyectoCatalog.EnsureProyectoOrcoAsync(_context, proyectoId, usuarioId);
    }

    private static PagedResult<PaaaResponse> InvalidProyectoResult(int? proyectoId)
    {
        return new PagedResult<PaaaResponse>
        {
            Success = false,
            Message = proyectoId.HasValue
                ? $"El proyecto seleccionado ({proyectoId.Value}) no existe en ORCO.Proyecto o no esta activo."
                : "El proyecto seleccionado no es valido.",
            Code = "INVALID_ORCO_PROJECT",
            TotalCount = 0
        };
    }

    [HttpDelete("partida/{partidaId}")]
    public async Task<ActionResult<PagedResult<bool>>> DeletePartida(int partidaId)
    {
        try
        {
            var partida = await GetOwnedPartidaAsync(partidaId);
            if (partida == null) return NotFound();
            if (await IsPaaaLockedAsync(partida.FkidPaaasOrco))
                return Conflict(new PagedResult<bool> { Success = false, Message = "El programa esta bloqueado por un estudio de mercado activo.", Code = "PAAA_LOCKED", TotalCount = 0 });
            var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                _context,
                "[ORCO].[SP_MantenimientoPAAASV2]",
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
