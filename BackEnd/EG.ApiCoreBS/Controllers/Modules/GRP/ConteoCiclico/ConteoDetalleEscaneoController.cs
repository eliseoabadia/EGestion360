using EG.ApiCoreBS.Services;
using EG.Application.Interfaces.ConteoCiclico;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.ConteoCiclico;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ConteoDetalleEscaneoController : ControllerBase
{
    private readonly IConteoDetalleEscaneoAppService _appService;
    private readonly IUserContextService _userContext;

    public ConteoDetalleEscaneoController(
        IConteoDetalleEscaneoAppService appService,
        IUserContextService userContext)
    {
        _appService = appService;
        _userContext = userContext;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<ConteoDetalleEscaneoResponse>>> GetAll()
    {
        var result = await _appService.GetAllAsync();
        return Ok(result);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<PagedResult<ConteoDetalleEscaneoResponse>>> GetById(int id)
    {
        var result = await _appService.GetByIdAsync(id);
        return Ok(result);
    }

    [HttpPost("GetAllPaginado")]
    public async Task<ActionResult<PagedResult<ConteoDetalleEscaneoResponse>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
    {
        var result = await _appService.GetAllPaginadoAsync(pageRequest);
        return Ok(result);
    }

    [HttpGet("ByConteo/{conteoId}")]
    public async Task<ActionResult<PagedResult<ConteoDetalleEscaneoResponse>>> GetByConteo(int conteoId)
    {
        var result = await _appService.GetByConteoAsync(conteoId);
        return Ok(result);
    }

    [HttpPost]
    public async Task<ActionResult<PagedResult<ConteoDetalleEscaneoResponse>>> Create([FromBody] ConteoDetalleEscaneoResponse request)
    {
        var usuarioActual = _userContext.GetCurrentUserId();
        var result = await _appService.CreateAsync(request, usuarioActual);
        return Ok(result);
    }
}
