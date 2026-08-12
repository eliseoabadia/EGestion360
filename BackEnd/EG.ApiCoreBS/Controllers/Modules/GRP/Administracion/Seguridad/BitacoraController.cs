using EG.Business.Interfaces;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Seguridad;
using EG.Domain.DTOs.Responses.Seguridad;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Modules.GRP.Administracion.Seguridad;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public sealed class BitacoraController(IBitacoraService service) : ControllerBase
{
    [HttpPost("GetAllPaginado")]
    public async Task<ActionResult<PagedResult<BitacoraResponse>>> GetAllPaginado([FromBody] BitacoraRequest request)
        => Ok(await service.ConsultarAsync(request));

    [HttpPost("Filtros")]
    public async Task<ActionResult<PagedResult<BitacoraResponse>>> Filtros([FromBody] BitacoraRequest request)
        => Ok(await service.ObtenerFiltrosAsync(request));
}
