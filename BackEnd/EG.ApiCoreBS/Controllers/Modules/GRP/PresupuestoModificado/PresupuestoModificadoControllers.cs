using EG.Common.Enums;
using EG.Application.Interfaces.General;
using EG.Application.Interfaces.Adquisicion;
using EG.Application.Interfaces.PresupuestoModificado;
using EG.Common.GenericModel;

using EG.Domain.DTOs.Responses.PresupuestoModificado;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.PresupuestoModificado
{
    [Route("api/[controller]")]
    public class EgreAdecuacionController(
        IPresupuestoModificadoAppService service,
        IUserContextService userContext,
        IAuthorizationService authorization)
        : PresupuestoModificadoControllerBase<EgreAdecuacionResponse>(service, userContext, authorization)
    {
        private readonly IPresupuestoModificadoAppService _service = service;
        protected override string PermissionFilterName => nameof(EgreAdecuacionResponse.FkidTipoAdecuacionPres);
        protected override Task<int?> GetTipoAdecuacionAsync(EgreAdecuacionResponse response) =>
            Task.FromResult<int?>(response.FkidTipoAdecuacionPres);
        protected override Task<int?> GetFilterTipoAdecuacionAsync(int value) => Task.FromResult<int?>(value);

        [HttpPost("{id:int}/enviar-solicitud")]
        public async Task<ActionResult<PagedResult<EgreAdecuacionResponse>>> EnviarSolicitud(int id)
        {
            var current = await _service.GetByIdAsync(id);
            if (!current.Success || current.Data == null) return NotFound(current);
            if (!await HasPermissionAsync(current.Data.FkidTipoAdecuacionPres, PermissionAction.Update)) return Forbid();

            var result = await _service.EnviarSolicitudAsync(id, UserContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("{id:int}/autorizar")]
        public async Task<ActionResult<PagedResult<EgreAdecuacionResponse>>> Autorizar(int id)
        {
            var current = await _service.GetByIdAsync(id);
            if (!current.Success || current.Data == null) return NotFound(current);

            if (!await HasPermissionAsync(current.Data.FkidTipoAdecuacionPres, PermissionAction.Authorize)) return Forbid();

            var result = await _service.AutorizarAsync(id, UserContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("{id:int}/rechazar")]
        public async Task<ActionResult<PagedResult<EgreAdecuacionResponse>>> Rechazar(int id)
        {
            var current = await _service.GetByIdAsync(id);
            if (!current.Success || current.Data == null) return NotFound(current);
            if (!await HasPermissionAsync(current.Data.FkidTipoAdecuacionPres, PermissionAction.Authorize)) return Forbid();

            var result = await _service.RechazarAsync(id, UserContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("{id:int}/cancelar-solicitud")]
        public async Task<ActionResult<PagedResult<EgreAdecuacionResponse>>> CancelarSolicitud(int id)
        {
            var current = await _service.GetByIdAsync(id);
            if (!current.Success || current.Data == null) return NotFound(current);
            if (!await HasPermissionAsync(current.Data.FkidTipoAdecuacionPres, PermissionAction.Update)) return Forbid();

            var result = await _service.CancelarSolicitudAsync(id, UserContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

    }

    [Route("api/[controller]")]
    public class EgreAdecuacionDetalleController(
        IAdquisicionCrudAppService<EgreAdecuacionDetalleResponse> service,
        IUserContextService userContext,
        IAuthorizationService authorization,
        IPresupuestoModificadoAppService headers)
        : PresupuestoModificadoControllerBase<EgreAdecuacionDetalleResponse>(service, userContext, authorization)
    {
        protected override string PermissionFilterName => nameof(EgreAdecuacionDetalleResponse.FkidEgreAdecuacionPres);
        protected override Task<int?> GetTipoAdecuacionAsync(EgreAdecuacionDetalleResponse response) =>
            GetFilterTipoAdecuacionAsync(response.FkidEgreAdecuacionPres);
        protected override async Task<int?> GetFilterTipoAdecuacionAsync(int value)
        {
            var parent = await headers.GetByIdAsync(value);
            return parent.Success ? parent.Data?.FkidTipoAdecuacionPres : null;
        }
    }

    [Route("api/[controller]")]
    public class TipoAdecuacionController(IReadOnlyCatalogAppService<TipoAdecuacionResponse> service)
        : ReadOnlyCatalogController<TipoAdecuacionResponse>(service);

    [Route("api/[controller]")]
    public class EstatusAdecuacionController(IReadOnlyCatalogAppService<EstatusAdecuacionResponse> service)
        : ReadOnlyCatalogController<EstatusAdecuacionResponse>(service);

    [Route("api/[controller]")]
    public class TipoMovimientoController(IReadOnlyCatalogAppService<TipoMovimientoResponse> service)
        : ReadOnlyCatalogController<TipoMovimientoResponse>(service);

    [Route("api/[controller]")]
    public class EgresoDisponibleController(
        IAdquisicionCrudAppService<EgresoDisponibleResponse> service)
        : PresupuestoModificadoReadOnlyControllerBase<EgresoDisponibleResponse>(service);
}
