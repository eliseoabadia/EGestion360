using EG.ApiCoreBS.Services;
using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.General;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class UsuarioAreaController : ControllerBase
{
    private readonly IUsuarioAreaAppService _appService;
    private readonly IUserContextService _userContext;

    public UsuarioAreaController(
        IUsuarioAreaAppService appService,
        IUserContextService userContext)
    {
        _appService = appService;
        _userContext = userContext;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<UsuarioAreaResponse>>> GetAll()
    {
        var usuarioId = _userContext.GetCurrentUserId();
        var result = await _appService.GetAllAsync(usuarioId);
        return Ok(result);
    }

    [HttpGet("persona/{personaId:int}")]
    public async Task<ActionResult<PagedResult<UsuarioAreaResponse>>> GetByPersona(int personaId)
    {
        var result = await _appService.GetByPersonaAsync(personaId);
        return Ok(result);
    }

    [HttpPost("persona-area")]
    public async Task<ActionResult<PagedResult<UsuarioAreaResponse>>> AsignarArea([FromBody] UsuarioAreaAsignacionRequest request)
    {
        var usuarioId = _userContext.GetCurrentUserId();
        var result = await _appService.AsignarAreaAsync(request, usuarioId);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [HttpDelete("persona-area/{personaAreaId:int}")]
    public async Task<ActionResult<PagedResult<UsuarioAreaResponse>>> EliminarArea(int personaAreaId)
    {
        var usuarioId = _userContext.GetCurrentUserId();
        var result = await _appService.EliminarAsignacionAsync(personaAreaId, usuarioId);
        return result.Success ? Ok(result) : BadRequest(result);
    }
}
