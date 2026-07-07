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
public class UsuarioDepartamentoController : ControllerBase
{
    private readonly IUsuarioDepartamentoAppService _appService;
    private readonly IUserContextService _userContext;

    public UsuarioDepartamentoController(
        IUsuarioDepartamentoAppService appService,
        IUserContextService userContext)
    {
        _appService = appService;
        _userContext = userContext;
    }

    [HttpGet("usuario/{usuarioId:int}")]
    public async Task<ActionResult<PagedResult<UsuarioDepartamentoResponse>>> GetByUsuario(int usuarioId)
    {
        var result = await _appService.GetByUsuarioAsync(usuarioId);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [HttpPost("usuario-departamento")]
    public async Task<ActionResult<PagedResult<UsuarioDepartamentoResponse>>> Asignar(
        [FromBody] UsuarioDepartamentoAsignacionRequest request)
    {
        var usuarioId = _userContext.GetCurrentUserId();
        var result = await _appService.AsignarAsync(request, usuarioId);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [HttpDelete("{usuarioId:int}/{departamentoId:int}")]
    public async Task<ActionResult<PagedResult<UsuarioDepartamentoResponse>>> Eliminar(
        int usuarioId,
        int departamentoId)
    {
        var usuarioActual = _userContext.GetCurrentUserId();
        var result = await _appService.EliminarAsync(usuarioId, departamentoId, usuarioActual);
        return result.Success ? Ok(result) : BadRequest(result);
    }
}
