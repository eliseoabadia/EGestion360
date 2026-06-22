using EG.Application.Interfaces.Nomina;
using EG.Common;
using EG.Common.Enums;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Nomina;
using EG.Domain.DTOs.Responses.Nomina;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Mapster;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Controllers.Modules.Nomina.RH;

[ApiController]
[Authorize]
public abstract class NominaRhDetailControllerBase<TDto, TResponse>(
    INominaRhDetailAppService<TDto, TResponse> appService,
    IUserContextService userContext,
    string entityName) : ControllerBase
    where TDto : class
    where TResponse : class
{
    private readonly INominaRhDetailAppService<TDto, TResponse> _appService = appService;
    private readonly IUserContextService _userContext = userContext;
    private readonly string _entityName = entityName;
    private readonly Logger.Log4NetLogger _logger = new(typeof(NominaRhDetailControllerBase<TDto, TResponse>));

    [HttpGet]
    public async Task<ActionResult<PagedResult<TResponse>>> GetAll()
        => Ok(await _appService.GetAllAsync(_userContext.TryGetCurrentEmpresaId()));

    [HttpGet("{id:int}")]
    public async Task<ActionResult<PagedResult<TResponse>>> GetById(int id)
    {
        var result = await _appService.GetByIdAsync(id, _userContext.TryGetCurrentEmpresaId());
        return ToActionResult(result);
    }

    [HttpPost]
    public async Task<ActionResult<PagedResult<TResponse>>> Create([FromBody] TResponse response)
    {
        try
        {
            var result = await _appService.CreateAsync(
                response.Adapt<TDto>(),
                _userContext.GetCurrentUserId(),
                _userContext.TryGetCurrentEmpresaId());
            return ToActionResult(result);
        }
        catch (Exception ex)
        {
            LogException("crear", ex);
            return BadRequest(Failure<TResponse>(UserFacingMessages.OperationFailed($"crear {_entityName}")));
        }
    }

    [HttpPut("{id:int}")]
    public async Task<ActionResult<PagedResult<TResponse>>> Update(int id, [FromBody] TResponse response)
    {
        try
        {
            var result = await _appService.UpdateAsync(
                id,
                response.Adapt<TDto>(),
                _userContext.GetCurrentUserId(),
                _userContext.TryGetCurrentEmpresaId());
            return ToActionResult(result);
        }
        catch (Exception ex)
        {
            LogException("actualizar", ex);
            return BadRequest(Failure<TResponse>(UserFacingMessages.OperationFailed($"actualizar {_entityName}")));
        }
    }

    [HttpDelete("{id:int}")]
    public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
    {
        try
        {
            var result = await _appService.DeleteAsync(
                id,
                _userContext.GetCurrentUserId(),
                _userContext.TryGetCurrentEmpresaId());

            if (!result.Success && result.Code == "NOT_FOUND")
            {
                return NotFound(result);
            }

            if (!result.Success && result.Code == "FORBIDDEN")
            {
                return Forbid();
            }

            return result.Success ? Ok(result) : BadRequest(result);
        }
        catch (Exception ex)
        {
            LogException("eliminar", ex);
            return BadRequest(Failure<bool>(UserFacingMessages.OperationFailed($"eliminar {_entityName}")));
        }
    }

    [HttpPost("GetAllPaginado")]
    public async Task<ActionResult<PagedResult<TResponse>>> GetAllPaginado([FromBody] PagedRequest request)
    {
        try
        {
            var result = await _appService.GetAllPaginadoAsync(request, _userContext.TryGetCurrentEmpresaId());
            return ToActionResult(result);
        }
        catch (Exception ex)
        {
            LogException("obtener paginado", ex);
            return BadRequest(Failure<TResponse>(UserFacingMessages.OperationFailed($"obtener {_entityName}")));
        }
    }

    private ActionResult<PagedResult<TResponse>> ToActionResult(PagedResult<TResponse> result)
    {
        if (!result.Success && result.Code == "NOT_FOUND")
        {
            return NotFound(result);
        }

        if (!result.Success && result.Code == "FORBIDDEN")
        {
            return StatusCode(StatusCodes.Status403Forbidden, result);
        }

        return result.Success ? Ok(result) : BadRequest(result);
    }

    private static PagedResult<TResult> Failure<TResult>(string message) => new()
    {
        Success = false,
        Code = "ERROR",
        Message = message,
        TotalCount = 0
    };

    private void LogException(string operation, Exception ex)
        => _logger.LogMessage(
            LogLevelGRP.Error,
            $"Error al {operation} {_entityName}: {ex}",
            (byte)SystemLogTypes.Error,
            GetType().Name,
            string.Empty,
            string.Empty);
}

[Route("api/NomRhExpediente")]
public sealed class NominaRhExpedienteController(
    INominaRhDetailAppService<NominaRhExpedienteDto, NominaRhExpedienteResponse> appService,
    IUserContextService userContext)
    : NominaRhDetailControllerBase<NominaRhExpedienteDto, NominaRhExpedienteResponse>(appService, userContext, "expediente")
{
}

[Route("api/NomRhContrato")]
public sealed class NominaRhContratoController(
    INominaRhDetailAppService<NominaRhContratoDto, NominaRhContratoResponse> appService,
    IUserContextService userContext)
    : NominaRhDetailControllerBase<NominaRhContratoDto, NominaRhContratoResponse>(appService, userContext, "contrato laboral")
{
}

[Route("api/NomRhDependiente")]
public sealed class NominaRhDependienteController(
    INominaRhDetailAppService<NominaRhDependienteDto, NominaRhDependienteResponse> appService,
    IUserContextService userContext)
    : NominaRhDetailControllerBase<NominaRhDependienteDto, NominaRhDependienteResponse>(appService, userContext, "dependiente")
{
}

[Route("api/NomRhIncidencia")]
public sealed class NominaRhIncidenciaController(
    INominaRhDetailAppService<NominaRhIncidenciaDto, NominaRhIncidenciaResponse> appService,
    IUserContextService userContext)
    : NominaRhDetailControllerBase<NominaRhIncidenciaDto, NominaRhIncidenciaResponse>(appService, userContext, "incidencia")
{
}

[ApiController]
[Authorize]
[Route("api/NomRhIncidenciaListado")]
public sealed class NominaRhIncidenciaListadoController(
    EGestionContext context,
    IUserContextService userContext) : ControllerBase
{
    [HttpPost("GetAllPaginado")]
    public async Task<ActionResult<PagedResult<VwRhIncidenciaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
    {
        request ??= new PagedRequest();

        var empresaId = ReadIntFilter(request, "EmpresaId") ?? userContext.TryGetCurrentEmpresaId();
        var filter = (request.Filtro ?? request.SearchString ?? string.Empty).Trim();
        var page = Math.Max(1, request.Page);
        var pageSize = Math.Clamp(request.PageSize <= 0 ? 10 : request.PageSize, 1, 2000);

        var query =
            from incidencia in context.VwIncidencia.AsNoTracking()
            join persona in context.Personas.AsNoTracking()
                on incidencia.FkidPersonaNom equals persona.PkidPersona
            where persona.Activo
                && (!empresaId.HasValue || empresaId <= 0 || persona.FkidEmpresaSis == empresaId.Value)
            select new
            {
                Incidencia = incidencia,
                Periodo = context.VwPeriodoQuincenals.AsNoTracking()
                    .Where(periodo => incidencia.FkidPeriodoQuincenalSis.HasValue
                        && periodo.LegacyId == incidencia.FkidPeriodoQuincenalSis.Value
                        && (!empresaId.HasValue || empresaId <= 0 || periodo.FkidEmpresaSis == null || periodo.FkidEmpresaSis == empresaId.Value))
                    .OrderByDescending(periodo => periodo.FechaFin)
                    .FirstOrDefault()
            };

        if (!string.IsNullOrWhiteSpace(filter))
        {
            query = query.Where(item =>
                item.Incidencia.NombreCompleto.Contains(filter) ||
                item.Incidencia.ClavePersona.Contains(filter) ||
                item.Incidencia.TipoIncidenciaDescripcion.Contains(filter) ||
                item.Incidencia.Comentario.Contains(filter) ||
                item.Incidencia.TipoJustificacionDescripcion.Contains(filter));
        }

        var total = await query.CountAsync();
        var descending = string.Equals(request.SortDirection, "Descending", StringComparison.OrdinalIgnoreCase)
            || string.Equals(request.SortDirection, "Desc", StringComparison.OrdinalIgnoreCase);
        var sorted = (request.SortLabel ?? string.Empty) switch
        {
            nameof(VwRhIncidenciaResponse.NombreCompleto) => descending
                ? query.OrderByDescending(item => item.Incidencia.NombreCompleto)
                : query.OrderBy(item => item.Incidencia.NombreCompleto),
            nameof(VwRhIncidenciaResponse.TipoIncidenciaDescripcion) => descending
                ? query.OrderByDescending(item => item.Incidencia.TipoIncidenciaDescripcion)
                : query.OrderBy(item => item.Incidencia.TipoIncidenciaDescripcion),
            nameof(VwRhIncidenciaResponse.Activo) => descending
                ? query.OrderByDescending(item => item.Incidencia.Activo)
                : query.OrderBy(item => item.Incidencia.Activo),
            nameof(VwRhIncidenciaResponse.PkidIncidencia) => descending
                ? query.OrderByDescending(item => item.Incidencia.PkidIncidencia)
                : query.OrderBy(item => item.Incidencia.PkidIncidencia),
            _ => descending
                ? query.OrderByDescending(item => item.Incidencia.Fecha)
                : query.OrderBy(item => item.Incidencia.Fecha)
        };

        var items = await sorted
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(item => new VwRhIncidenciaResponse
            {
                PkidIncidencia = item.Incidencia.PkidIncidencia,
                FkidPersonaNom = item.Incidencia.FkidPersonaNom,
                NombreCompleto = item.Incidencia.NombreCompleto,
                ClavePersona = item.Incidencia.ClavePersona,
                Rfc = item.Incidencia.Rfc,
                Curp = item.Incidencia.Curp,
                FkidTipoIncidenciaNom = item.Incidencia.FkidTipoIncidenciaNom,
                TipoIncidenciaDescripcion = item.Incidencia.TipoIncidenciaDescripcion,
                Fecha = item.Incidencia.Fecha,
                Comentario = item.Incidencia.Comentario,
                FkidTipoJustificacionNom = item.Incidencia.FkidTipoJustificacionNom,
                TipoJustificacionDescripcion = item.Incidencia.TipoJustificacionDescripcion,
                AplicaDescuento = item.Incidencia.AplicaDescuento,
                ComentarioJustificacion = item.Incidencia.ComentarioJustificacion,
                FkidPeriodoQuincenalSis = item.Incidencia.FkidPeriodoQuincenalSis,
                FechaInicio = item.Periodo == null ? null : item.Periodo.FechaInicio,
                FechaFin = item.Periodo == null ? null : item.Periodo.FechaFin,
                Activo = item.Incidencia.Activo,
                UsuarioCreacion = item.Incidencia.UsuarioCreacion.HasValue ? item.Incidencia.UsuarioCreacion.Value.ToString() : string.Empty,
                FechaCreacion = item.Incidencia.FechaCreacion,
                UsuarioModificacion = item.Incidencia.UsuarioModificacion.HasValue ? item.Incidencia.UsuarioModificacion.Value.ToString() : string.Empty,
                FechaModificacion = item.Incidencia.FechaModificacion
            })
            .ToListAsync();

        return Ok(new PagedResult<VwRhIncidenciaResponse>
        {
            Success = true,
            Code = "SUCCESS",
            Message = "Incidencias obtenidas correctamente.",
            Items = items,
            Data = items.FirstOrDefault(),
            TotalCount = total
        });
    }

    private static int? ReadIntFilter(PagedRequest request, string key)
    {
        if (request.AdditionalFilters == null || !request.AdditionalFilters.TryGetValue(key, out var raw) || raw == null)
        {
            return null;
        }

        return raw switch
        {
            int value => value,
            long value => Convert.ToInt32(value),
            string text when int.TryParse(text, out var value) => value,
            _ => null
        };
    }
}

[Route("api/NomRhPension")]
public sealed class NominaRhPensionController(
    INominaRhDetailAppService<NominaRhPensionDto, NominaRhPensionResponse> appService,
    IUserContextService userContext)
    : NominaRhDetailControllerBase<NominaRhPensionDto, NominaRhPensionResponse>(appService, userContext, "pension")
{
}

[ApiController]
[Authorize]
[Route("api/NomRhLookup")]
public sealed class NominaRhLookupController(
    INominaRhLookupAppService appService,
    IUserContextService userContext) : ControllerBase
{
    [HttpPost("GetAllPaginado")]
    public async Task<ActionResult<PagedResult<NominaRhLookupResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        => Ok(await appService.GetAllPaginadoAsync(request, userContext.TryGetCurrentEmpresaId()));
}
