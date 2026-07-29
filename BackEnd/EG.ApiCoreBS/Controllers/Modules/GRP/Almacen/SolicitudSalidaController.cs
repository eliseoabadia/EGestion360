using EG.Application.Interfaces.Almacen;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Almacen
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class SolicitudSalidaController : ControllerBase
    {
        private readonly ISolicitudSalidaAppService _appService;
        private readonly IUserContextService _userContext;
        private readonly IAuthorizationService _authorization;

        public SolicitudSalidaController(ISolicitudSalidaAppService appService, IUserContextService userContext, IAuthorizationService authorization)
        {
            _appService = appService;
            _userContext = userContext;
            _authorization = authorization;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<SolicitudSalidaResponse>>> GetAll()
        {
            if (!await HasViewAsync()) return Forbid();
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<SolicitudSalidaResponse>>> GetById(int id)
        {
            if (!await HasViewAsync()) return Forbid();
            var result = await _appService.GetByIdAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<SolicitudSalidaResponse>>> Create([FromBody] SolicitudSalidaResponse response)
        {
            if (!await HasPermissionAsync("new")) return Forbid();
            var result = await _appService.CreateAsync(response, _userContext.GetCurrentUserId());
            if (!result.Success)
            {
                return BadRequest(result);
            }

            var id = result.Data?.PkidSolicitudSalida ?? response.PkidSolicitudSalida;
            return CreatedAtAction(nameof(GetById), new { id }, result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<SolicitudSalidaResponse>>> Update(int id, [FromBody] SolicitudSalidaResponse response)
        {
            if (!await HasPermissionAsync("update")) return Forbid();
            var result = await _appService.UpdateAsync(id, response, _userContext.GetCurrentUserId());
            if (result.Success)
            {
                return Ok(result);
            }

            return result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
        }

        [HttpPost("{id}/autorizar")]
        public async Task<ActionResult<PagedResult<SolicitudSalidaResponse>>> Autorizar(int id)
        {
            if (!await HasPermissionAsync("authorize")) return Forbid();
            var result = await _appService.AutorizarAsync(id, _userContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            if (!await HasPermissionAsync("delete")) return Forbid();
            var result = await _appService.DeleteAsync(id);
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<SolicitudSalidaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            if (!await HasViewAsync()) return Forbid();
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<SolicitudSalidaResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            if (!await HasViewAsync()) return Forbid();
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

        private async Task<bool> HasViewAsync() =>
            await HasPermissionAsync("view") ||
            (await _authorization.AuthorizeAsync(User, null, "Almacen|Suministros_Salida|view")).Succeeded;

        private async Task<bool> HasPermissionAsync(string action) =>
            (await _authorization.AuthorizeAsync(User, null, $"Almacen|Solicitudes_Salida|{action}")).Succeeded;
    }
}
