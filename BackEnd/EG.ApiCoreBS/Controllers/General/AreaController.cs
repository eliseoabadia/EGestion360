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

        [HttpGet]
        public async Task<ActionResult<PagedResult<AreaResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<AreaResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<AreaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpGet("por-persona/{personaId}")]
        public async Task<ActionResult<PagedResult<AreaResponse>>> GetAreasByPersona(int personaId)
        {
            var result = await _appService.GetAreasByPersona(personaId);
            return Ok(result);
        }
    }
}
