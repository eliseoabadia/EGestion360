using EG.Application.Interfaces.Patrimonio;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Patrimonio;

[ApiController]
[Route("api/[controller]")]
[Authorize(Policy = "Patrimonio|Resguardo_Historico|view")]
public sealed class ResguardoMovimientoController(IResguardoMovimientoAppService service) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<PagedResult<ResguardoMovimientoResponse>>> GetAll()
        => Ok(await service.GetAllAsync());

    [HttpGet("{id}")]
    public async Task<ActionResult<PagedResult<ResguardoMovimientoResponse>>> GetById(int id)
    {
        var result = await service.GetByIdAsync(id);
        return result.Success ? Ok(result) : NotFound(result);
    }

    [HttpPost("GetAllPaginado")]
    public async Task<ActionResult<PagedResult<ResguardoMovimientoResponse>>> GetAllPaginado(PagedRequest request)
        => Ok(await service.GetAllPaginadoAsync(request));
}
