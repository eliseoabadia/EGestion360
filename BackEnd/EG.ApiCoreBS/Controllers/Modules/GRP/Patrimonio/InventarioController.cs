using EG.Application.Interfaces.Patrimonio;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Patrimonio
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class InventarioController : ControllerBase
    {
        private readonly IInventarioAppService _appService;
        private readonly IUserContextService _userContext;
        private readonly IAuthorizationService _authorization;

        public InventarioController(IInventarioAppService appService, IUserContextService userContext, IAuthorizationService authorization)
        {
            _appService = appService;
            _userContext = userContext;
            _authorization = authorization;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<InventarioResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<InventarioResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<InventarioResponse>>> Create([FromBody] InventarioResponse response)
        {
            var result = await _appService.CreateAsync(response, _userContext.GetCurrentUserId());
            if (!result.Success)
            {
                return result.Code == "DUPLICATE" ? Conflict(result) : BadRequest(result);
            }

            var id = result.Data?.PkidInventario ?? response.PkidInventario;
            return CreatedAtAction(nameof(GetById), new { id }, result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<InventarioResponse>>> Update(int id, [FromBody] InventarioResponse response)
        {
            var result = await _appService.UpdateAsync(id, response, _userContext.GetCurrentUserId());
            if (result.Success)
            {
                return Ok(result);
            }

            return result.Code switch
            {
                "NOT_FOUND" => NotFound(result),
                "DUPLICATE" => Conflict(result),
                _ => BadRequest(result)
            };
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            var result = await _appService.DeleteAsync(id);
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("{id:int}/autorizar")]
        public async Task<ActionResult<PagedResult<InventarioResponse>>> Autorizar(int id)
        {
            var permission = await _authorization.AuthorizeAsync(User, null, "Patrimonio|Inventarios|authorize");
            if (!permission.Succeeded)
            {
                return Forbid();
            }

            var result = await _appService.AutorizarAsync(id, _userContext.GetCurrentUserId());
            return result.Success ? Ok(result) : result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<InventarioResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<InventarioResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SearchString = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };

            var result = await _appService.GetAllPaginadoAsync(pagedRequest);
            return Ok(result);
        }
    }
}
