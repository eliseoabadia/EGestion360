using EG.Application.Interfaces.Patrimonio;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Patrimonio
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class BajaController : ControllerBase
    {
        private readonly IBajaAppService _appService;
        private readonly IUserContextService _userContext;
        private readonly IAuthorizationService _authorization;

        public BajaController(IBajaAppService appService, IUserContextService userContext, IAuthorizationService authorization)
        {
            _appService = appService;
            _userContext = userContext;
            _authorization = authorization;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<BajaResponse>>> GetAll()
        {
            if (!await HasPermissionAsync("view")) return Forbid();
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<BajaResponse>>> GetById(int id)
        {
            if (!await HasPermissionAsync("view")) return Forbid();
            var result = await _appService.GetByIdAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<BajaResponse>>> Create([FromBody] BajaResponse response)
        {
            if (!await HasPermissionAsync("new")) return Forbid();
            var result = await _appService.CreateAsync(response, _userContext.GetCurrentUserId());
            if (!result.Success)
            {
                return result.Code == "DUPLICATE" ? Conflict(result) : BadRequest(result);
            }

            var id = result.Data?.PkidBaja ?? response.PkidBaja;
            return CreatedAtAction(nameof(GetById), new { id }, result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<BajaResponse>>> Update(int id, [FromBody] BajaResponse response)
        {
            if (!await HasPermissionAsync("update")) return Forbid();
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

        [HttpPost("{id:int}/aplicar")]
        public async Task<ActionResult<PagedResult<BajaResponse>>> Aplicar(int id, [FromBody] AplicarBajaRequest request)
        {
            var permission = await _authorization.AuthorizeAsync(User, null, "Patrimonio|Bajas|authorize");
            if (!permission.Succeeded) return Forbid();

            var result = await _appService.AplicarAsync(id, request.FkidAnioSis, _userContext.GetCurrentUserId());
            return result.Success ? Ok(result) : result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            if (!await HasPermissionAsync("delete")) return Forbid();
            var result = await _appService.DeleteAsync(id);
            if (result.Success)
            {
                return Ok(result);
            }

            return result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<BajaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            if (!await HasPermissionAsync("view")) return Forbid();
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<BajaResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            if (!await HasPermissionAsync("view")) return Forbid();
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

        private async Task<bool> HasPermissionAsync(string action) =>
            (await _authorization.AuthorizeAsync(User, null, $"Patrimonio|Bajas|{action}")).Succeeded;
    }
}
