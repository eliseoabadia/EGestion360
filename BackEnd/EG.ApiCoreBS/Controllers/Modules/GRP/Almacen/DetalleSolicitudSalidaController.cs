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
    public class DetalleSolicitudSalidaController : ControllerBase
    {
        private readonly IDetalleSolicitudSalidaAppService _appService;
        private readonly IUserContextService _userContext;
        private readonly IAuthorizationService _authorization;

        public DetalleSolicitudSalidaController(IDetalleSolicitudSalidaAppService appService, IUserContextService userContext, IAuthorizationService authorization)
        {
            _appService = appService;
            _userContext = userContext;
            _authorization = authorization;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<DetalleSolicitudSalidaResponse>>> GetAll()
        {
            if (!await HasViewAsync()) return Forbid();
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<DetalleSolicitudSalidaResponse>>> GetById(int id)
        {
            if (!await HasViewAsync()) return Forbid();
            var result = await _appService.GetByIdAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<DetalleSolicitudSalidaResponse>>> Create([FromBody] DetalleSolicitudSalidaResponse response)
        {
            if (!await HasSolicitudPermissionAsync("new")) return Forbid();
            var result = await _appService.CreateAsync(response, _userContext.GetCurrentUserId());
            if (!result.Success)
            {
                return BadRequest(result);
            }

            var id = result.Data?.PkidDetalleSolicitudSalida ?? response.PkidDetalleSolicitudSalida;
            return CreatedAtAction(nameof(GetById), new { id }, result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<DetalleSolicitudSalidaResponse>>> Update(int id, [FromBody] DetalleSolicitudSalidaResponse response)
        {
            if (!await HasSolicitudPermissionAsync("update")) return Forbid();
            var result = await _appService.UpdateAsync(id, response, _userContext.GetCurrentUserId());
            if (result.Success)
            {
                return Ok(result);
            }

            return result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
        }

        [HttpPost("{id}/entrega")]
        public async Task<ActionResult<PagedResult<DetalleSolicitudSalidaResponse>>> ActualizarEntrega(int id, [FromBody] DetalleSolicitudSalidaResponse response)
        {
            if (!(await _authorization.AuthorizeAsync(User, null, "Almacen|Suministros_Salida|authorize")).Succeeded) return Forbid();
            var result = await _appService.ActualizarEntregaAsync(id, response, _userContext.GetCurrentUserId());
            if (result.Success)
            {
                return Ok(result);
            }

            return result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            if (!await HasSolicitudPermissionAsync("delete")) return Forbid();
            var result = await _appService.DeleteAsync(id);
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<DetalleSolicitudSalidaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            if (!await HasViewAsync()) return Forbid();
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<DetalleSolicitudSalidaResponse>>> Buscar([FromBody] BusquedaRequest request)
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
            await HasSolicitudPermissionAsync("view") ||
            (await _authorization.AuthorizeAsync(User, null, "Almacen|Suministros_Salida|view")).Succeeded;

        private async Task<bool> HasSolicitudPermissionAsync(string action) =>
            (await _authorization.AuthorizeAsync(User, null, $"Almacen|Solicitudes_Salida|{action}")).Succeeded;
    }
}
