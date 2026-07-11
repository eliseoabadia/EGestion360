using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.PresupuestoComprometido;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.PresupuestoComprometido
{
    [ApiController]
    [Authorize]
    public abstract class PresupuestoComprometidoControllerBase<TResponse>(
        IAdquisicionCrudAppService<TResponse> service,
        IUserContextService userContext,
        IAuthorizationService authorization,
        string permissionGroup,
        string permissionSubGroup) : ControllerBase
        where TResponse : class
    {
        [HttpGet]
        public async Task<ActionResult<PagedResult<TResponse>>> GetAll()
        {
            if (!await HasPermissionAsync("view")) return Forbid();
            return Ok(await service.GetAllAsync());
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<TResponse>>> GetById(int id)
        {
            if (!await HasPermissionAsync("view")) return Forbid();
            var result = await service.GetByIdAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<TResponse>>> Create([FromBody] TResponse response)
        {
            if (!await HasPermissionAsync("authorize")) return Forbid();
            var result = await service.CreateAsync(response, userContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<TResponse>>> Update(int id, [FromBody] TResponse response)
        {
            if (!await HasPermissionAsync("update")) return Forbid();
            var result = await service.UpdateAsync(id, response, userContext.GetCurrentUserId());
            return result.Success ? Ok(result) : result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            if (!await HasPermissionAsync("delete")) return Forbid();
            var result = await service.DeleteAsync(id);
            return result.Success ? Ok(result) : result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<TResponse>>> GetAllPaginado([FromBody] PagedRequest request) =>
            await HasPermissionAsync("view") ? Ok(await service.GetAllPaginadoAsync(request)) : Forbid();

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<TResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            if (!await HasPermissionAsync("view")) return Forbid();
            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };

            return Ok(await service.GetAllPaginadoAsync(pagedRequest));
        }

        private async Task<bool> HasPermissionAsync(string action) =>
            (await authorization.AuthorizeAsync(User, null, $"{permissionGroup}|{permissionSubGroup}|{action}")).Succeeded;
    }

    [Route("api/[controller]")]
    public class AutorizacionSuficienciaController(
        IAdquisicionCrudAppService<AutorizacionSuficienciaResponse> service,
        IUserContextService userContext,
        IAuthorizationService authorization)
        : PresupuestoComprometidoControllerBase<AutorizacionSuficienciaResponse>(
            service, userContext, authorization, "Presupuesto_Comprometido", "Autorizacion_Suficiencia");

    [Route("api/[controller]")]
    public class AutorizacionSuficienciaDetalleController(
        IAdquisicionCrudAppService<AutorizacionSuficienciaDetalleResponse> service,
        IUserContextService userContext,
        IAuthorizationService authorization)
        : PresupuestoComprometidoControllerBase<AutorizacionSuficienciaDetalleResponse>(
            service, userContext, authorization, "Presupuesto_Comprometido", "Autorizacion_Suficiencia");
}
