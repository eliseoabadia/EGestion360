using EG.ApiCoreBS.Services;
using EG.Application.Interfaces.ClavePrograma;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Catalogos.ClavePrograma
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class GfController : ControllerBase
    {
        private readonly IGfAppService _appService;
        private readonly IUserContextService _userContext;

        public GfController(IGfAppService appService, IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<GfResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<GfResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<GfResponse>>> Create([FromBody] GfResponse request)
        {
            var usuarioActual = _userContext.GetCurrentUserId();
            var result = await _appService.CreateAsync(request, usuarioActual);
            if (result.Code == "DUPLICATE")
                return Conflict(result);
            return CreatedAtAction(nameof(GetById), new { id = request.PkidGf }, result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<GfResponse>>> Update(int id, [FromBody] GfResponse request)
        {
            var usuarioActual = _userContext.GetCurrentUserId();
            var result = await _appService.UpdateAsync(id, request, usuarioActual);
            if (result.Code == "DUPLICATE")
                return Conflict(result);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<GfResponse>>> Delete(int id)
        {
            var result = await _appService.DeleteAsync(id);
            if (result.Code == "BUSINESS_RULE")
                return Conflict(result);
            if (result.Code == "NOT_FOUND")
                return NotFound(result);
            return Ok(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<GfResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<GfResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            var result = await _appService.BuscarAsync(request);
            return Ok(result);
        }
    }
}
