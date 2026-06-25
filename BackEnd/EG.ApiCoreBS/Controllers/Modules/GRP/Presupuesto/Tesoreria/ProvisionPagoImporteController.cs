using EG.Application.Interfaces.Configuracion.Catalogo.Tesoreria;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Tesoreria;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Presupuesto.Tesoreria
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ProvisionPagoImporteController(IProvisionPagoImporteAppService service) : ControllerBase
    {
        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<VwClcfacturaImporteResponse>>> GetAllPaginado([FromBody] PagedRequest request) =>
            Ok(await service.GetAllPaginadoAsync(request));

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<VwClcfacturaImporteResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };

            return Ok(await service.GetAllPaginadoAsync(pagedRequest));
        }
    }
}
