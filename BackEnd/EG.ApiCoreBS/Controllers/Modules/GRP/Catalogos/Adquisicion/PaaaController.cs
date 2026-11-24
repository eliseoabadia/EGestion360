using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Catalogos.Adquisicion;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public sealed class PaaaController(IPaaaAppService service) : ControllerBase
{
    private const string ReadPermission = "Adquisiciones|Programa_Anual_Adquisiciones|view";
    private const string CreatePermission = "Adquisiciones|Programa_Anual_Adquisiciones|new";
    private const string UpdatePermission = "Adquisiciones|Programa_Anual_Adquisiciones|update";
    private const string DeletePermission = "Adquisiciones|Programa_Anual_Adquisiciones|delete";

    [HttpGet]
    [Authorize(Policy = ReadPermission)]
    public async Task<ActionResult<PagedResult<PaaaResponse>>> GetAll() => Result(await service.GetAllAsync());

    [HttpGet("{id}")]
    [Authorize(Policy = ReadPermission)]
    public async Task<ActionResult<PagedResult<PaaaResponse>>> GetById(int id) => Result(await service.GetByIdAsync(id));

    [HttpPost("GetAllPaginado")]
    [Authorize(Policy = ReadPermission)]
    public async Task<ActionResult<PagedResult<PaaaResponse>>> GetAllPaginado(PagedRequest request) => Result(await service.GetAllPaginadoAsync(request));

    [HttpPost]
    [Authorize(Policy = CreatePermission)]
    public async Task<ActionResult<PagedResult<PaaaResponse>>> Create(PaaaResponse request)
    {
        var result = await service.CreateAsync(request);
        return result.Success ? CreatedAtAction(nameof(GetById), new { id = result.Data?.PkidPaaas }, result) : Result(result);
    }

    [HttpPut("{id}")]
    [Authorize(Policy = UpdatePermission)]
    public async Task<ActionResult<PagedResult<PaaaResponse>>> Update(int id, PaaaResponse request) => Result(await service.UpdateAsync(id, request));

    [HttpDelete("{id}")]
    [Authorize(Policy = DeletePermission)]
    public async Task<ActionResult<PagedResult<bool>>> Delete(int id) => Result(await service.DeleteAsync(id));

    [HttpGet("{id}/partidas")]
    [Authorize(Policy = ReadPermission)]
    public async Task<ActionResult<PagedResult<PaaaspartidumResponse>>> GetPartidasByPaaa(int id) => Result(await service.GetPartidasAsync(id));

    [HttpGet("partida/{partidaId}/detalles")]
    [Authorize(Policy = ReadPermission)]
    public async Task<ActionResult<PagedResult<PaaasdetalleResponse>>> GetDetallesByPartida(int partidaId) => Result(await service.GetDetallesAsync(partidaId));

    [HttpPost("partida/{partidaId}/tipos-bien")]
    [Authorize(Policy = ReadPermission)]
    public async Task<ActionResult<PagedResult<LookupItem>>> GetTiposBienByPartida(int partidaId, PagedRequest request) => Result(await service.GetTiposBienAsync(partidaId, request));

    [HttpPost("{id}/partidas-disponibles")]
    [Authorize(Policy = ReadPermission)]
    public async Task<ActionResult<PagedResult<LookupItem>>> GetPartidasDisponibles(int id, PagedRequest request) => Result(await service.GetPartidasDisponiblesAsync(id, request));

    [HttpPost("meses")]
    [Authorize(Policy = ReadPermission)]
    public async Task<ActionResult<PagedResult<LookupItem>>> GetMeses(PagedRequest request) => Result(await service.GetMesesAsync(request));

    [HttpPost("partida")]
    [Authorize(Policy = CreatePermission)]
    public async Task<ActionResult<PagedResult<PaaaspartidumResponse>>> CreatePartida(PaaaspartidaDto request)
    {
        var result = await service.CreatePartidaAsync(request);
        return result.Success ? CreatedAtAction(nameof(GetPartidasByPaaa), new { id = request.FkidPaaasOrco }, result) : Result(result);
    }

    [HttpPost("detalle")]
    [Authorize(Policy = CreatePermission)]
    public async Task<ActionResult<PagedResult<PaaasdetalleResponse>>> CreateDetalle(PaaasdetalleDto request)
    {
        var result = await service.CreateDetalleAsync(request);
        return result.Success ? CreatedAtAction(nameof(GetDetallesByPartida), new { partidaId = request.FkidPaaaspartidaOrco }, result) : Result(result);
    }

    [HttpPut("detalle/{detalleId}")]
    [Authorize(Policy = UpdatePermission)]
    public async Task<ActionResult<PagedResult<PaaasdetalleResponse>>> UpdateDetalle(int detalleId, PaaasdetalleDto request) => Result(await service.UpdateDetalleAsync(detalleId, request));

    [HttpDelete("detalle/{detalleId}")]
    [Authorize(Policy = DeletePermission)]
    public async Task<ActionResult<PagedResult<bool>>> DeleteDetalle(int detalleId) => Result(await service.DeleteDetalleAsync(detalleId));

    [HttpDelete("partida/{partidaId}")]
    [Authorize(Policy = DeletePermission)]
    public async Task<ActionResult<PagedResult<bool>>> DeletePartida(int partidaId) => Result(await service.DeletePartidaAsync(partidaId));

    private ActionResult<PagedResult<T>> Result<T>(PagedResult<T> result)
    {
        if (result.Success) return Ok(result);
        return result.Code switch
        {
            "NOT_FOUND" => NotFound(result),
            "FORBIDDEN" => StatusCode(StatusCodes.Status403Forbidden, result),
            "PAAA_LOCKED" or "DUPLICATE_AREA_ANIO" => Conflict(result),
            _ => BadRequest(result)
        };
    }
}
