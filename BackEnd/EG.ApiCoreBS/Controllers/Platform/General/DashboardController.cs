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
    public class DashboardController : ControllerBase
    {
        private readonly IDashboardAppService _appService;

        public DashboardController(IDashboardAppService appService)
        {
            _appService = appService;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<DashboardResumenResponse>>> GetResumen()
        {
            var result = await _appService.GetResumenAsync();
            return Ok(result);
        }
    }
}
