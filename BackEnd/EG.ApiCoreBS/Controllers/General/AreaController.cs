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
    public class AreaController : ControllerBase
    {
        private readonly IAreaAppService _appService;

        public AreaController(IAreaAppService appService)
        {
            _appService = appService;
        }

        [HttpGet("por-persona/{personaId}")]
        public async Task<ActionResult<PagedResult<AreaResponse>>> GetAreasByPersona(int personaId)
        {
            var result = await _appService.GetAreasByPersona(personaId);
            return Ok(result);
        }
    }
}
