using EG.ApiCoreBS.Services;
using EG.Application.Interfaces.ConteoCiclico;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.ConteoCiclico;

[ApiController]
[Route("api/[controller]")]
public class ConteoDetalleController : ControllerBase
{
    private readonly IConteoDetalleAppService _appService;
    private readonly IUserContextService _userContext;

    public ConteoDetalleController(
        IConteoDetalleAppService appService,
        IUserContextService userContext)
    {
        _appService = appService;
        _userContext = userContext;
    }

    [HttpGet("buscar-bienes")]
    public async Task<ActionResult<PagedResult<BienResponse>>> BuscarBienes(
        [FromQuery] string? filtro,
        [FromQuery] string? tipoBienCodigo,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        var result = await _appService.BuscarBienes(filtro, tipoBienCodigo, page, pageSize);
        return Ok(result);
    }

    [HttpGet("buscar-por-codigo/{codigo}")]
    public async Task<ActionResult<PagedResult<BienResponse>>> BuscarPorCodigo(
        string codigo,
        [FromQuery] string? tipoBienCodigo = null)
    {
        var result = await _appService.BuscarPorCodigo(codigo, tipoBienCodigo);
        return Ok(result);
    }

    [HttpPost("agregar-bien")]
    public async Task<ActionResult<PagedResult<ConteoDetalleResponse>>> AgregarBien([FromBody] AgregarBienConteoDto dto)
    {
        var usuarioActual = _userContext.GetCurrentUserId();
        var result = await _appService.AgregarBien(dto, usuarioActual);
        return Ok(result);
    }

    [HttpGet("por-conteo/{conteoId}")]
    public async Task<ActionResult<PagedResult<ConteoDetalleResponse>>> GetPorConteo(int conteoId)
    {
        var result = await _appService.GetPorConteo(conteoId);
        return Ok(result);
    }

    [HttpPut("{id}/cantidad")]
    public async Task<ActionResult<PagedResult<ConteoDetalleResponse>>> ActualizarCantidad(int id, [FromBody] decimal cantidad)
    {
        var usuarioActual = _userContext.GetCurrentUserId();
        var result = await _appService.ActualizarCantidad(id, cantidad, usuarioActual);
        return Ok(result);
    }

    [HttpDelete("{id}")]
    public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
    {
        var result = await _appService.Delete(id);
        return Ok(result);
    }
}
