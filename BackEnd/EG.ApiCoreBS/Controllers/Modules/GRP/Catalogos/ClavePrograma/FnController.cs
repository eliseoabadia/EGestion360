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
    public class FnController : ControllerBase
    {
        private readonly IFnAppService _appService;
        private readonly IUserContextService _userContext;

        public FnController(IFnAppService appService, IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<FnResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<FnResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<FnResponse>>> Create([FromBody] FnResponse request)
        {
            var usuarioActual = _userContext.GetCurrentUserId();
            var result = await _appService.CreateAsync(request, usuarioActual);
            if (result.Code == "DUPLICATE")
                return Conflict(result);
            return CreatedAtAction(nameof(GetById), new { id = request.PkidFn }, result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<FnResponse>>> Update(int id, [FromBody] FnResponse request)
        {
            var usuarioActual = _userContext.GetCurrentUserId();
            var result = await _appService.UpdateAsync(id, request, usuarioActual);
            if (result.Code == "DUPLICATE")
                return Conflict(result);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<FnResponse>>> Delete(int id)
        {
            var result = await _appService.DeleteAsync(id);
            if (result.Code == "BUSINESS_RULE")
                return Conflict(result);
            if (result.Code == "NOT_FOUND")
                return NotFound(result);
            return Ok(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<FnResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<FnResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            var result = await _appService.BuscarAsync(request);
            return Ok(result);
        }
    }
}
