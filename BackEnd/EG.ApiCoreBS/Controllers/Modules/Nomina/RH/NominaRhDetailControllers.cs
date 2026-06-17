using EG.Application.Interfaces.Nomina;
using EG.Common;
using EG.Common.Enums;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Nomina;
using EG.Domain.DTOs.Responses.Nomina;
using EG.Domain.Interfaces;
using Mapster;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

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
