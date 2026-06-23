using EG.Application.Services.PBR;
using EG.Domain.DTOs.Responses.PBR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.PBR
{
    [ApiController]
    [Authorize]
    [Route("api/[controller]")]
    public class PbrDashboardController : ControllerBase
    {
        private readonly IPbrDashboardAppService _service;

        public PbrDashboardController(IPbrDashboardAppService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<ActionResult<PbrDashboardResponse>> Get([FromQuery] int? anio)
        {
            var ejercicio = anio.GetValueOrDefault(DateTime.Now.Year);
            return Ok(await _service.GetAsync(ejercicio));
        }
    }
}
