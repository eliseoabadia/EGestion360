using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class PeriodoPagoController(ICatalogLookupAppService service) : ControllerBase
    {
        [HttpGet]
        public async Task<ActionResult<PagedResult<PeriodoPagoResponse>>> GetAll()
        {
            return Ok(await service.GetPeriodosPagoAsync());
        }
    }
}
