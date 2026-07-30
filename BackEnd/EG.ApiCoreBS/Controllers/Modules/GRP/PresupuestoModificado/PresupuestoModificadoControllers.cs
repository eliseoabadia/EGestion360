using EG.Application.Interfaces.Adquisicion;
using EG.Application.Interfaces.PresupuestoModificado;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.PresupuestoModificado;
using EG.Domain.DTOs.Responses.PresupuestoModificado;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace EG.ApiCoreBS.Controllers.PresupuestoModificado
{
    [ApiController]
    [Authorize]
    public abstract class PresupuestoModificadoReadOnlyControllerBase<TResponse>(
        IAdquisicionCrudAppService<TResponse> service) : ControllerBase
        where TResponse : class
    {
        protected readonly IAdquisicionCrudAppService<TResponse> Service = service;

        [HttpGet]
        public async Task<ActionResult<PagedResult<TResponse>>> GetAll() => Ok(await Service.GetAllAsync());

        [HttpGet("{id:int}")]
        public async Task<ActionResult<PagedResult<TResponse>>> GetById(int id)
        {
            var result = await Service.GetByIdAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<TResponse>>> GetAllPaginado([FromBody] PagedRequest request) =>
            Ok(await Service.GetAllPaginadoAsync(request));
    }

    public abstract class PresupuestoModificadoControllerBase<TResponse>(
        IAdquisicionCrudAppService<TResponse> service,
        IUserContextService userContext) : PresupuestoModificadoReadOnlyControllerBase<TResponse>(service)
        where TResponse : class
    {
        protected readonly IUserContextService UserContext = userContext;

        [HttpPost]
        public async Task<ActionResult<PagedResult<TResponse>>> Create([FromBody] TResponse response)
        {
            var result = await Service.CreateAsync(response, UserContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPut("{id:int}")]
        public async Task<ActionResult<PagedResult<TResponse>>> Update(int id, [FromBody] TResponse response)
        {
            var result = await Service.UpdateAsync(id, response, UserContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpDelete("{id:int}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            var result = await Service.DeleteAsync(id);
            return result.Success ? Ok(result) : BadRequest(result);
        }
    }

    [Route("api/[controller]")]
    public class EgreAdecuacionController(
        IPresupuestoModificadoAppService service,
        IUserContextService userContext)
        : PresupuestoModificadoControllerBase<EgreAdecuacionResponse>(service, userContext)
    {
        private readonly IPresupuestoModificadoAppService _service = service;

        [HttpPost("{id:int}/enviar-solicitud")]
        public async Task<ActionResult<PagedResult<EgreAdecuacionResponse>>> EnviarSolicitud(int id)
        {
            var current = await _service.GetByIdAsync(id);
            if (!current.Success || current.Data == null) return NotFound(current);
            if (!HasPermission(User, GetSubModuleName(current.Data.FkidTipoAdecuacionPres), "update")) return Forbid();

            var result = await _service.EnviarSolicitudAsync(id, UserContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("{id:int}/autorizar")]
        public async Task<ActionResult<PagedResult<EgreAdecuacionResponse>>> Autorizar(int id)
        {
            var current = await _service.GetByIdAsync(id);
            if (!current.Success || current.Data == null) return NotFound(current);

            var subModule = GetSubModuleName(current.Data.FkidTipoAdecuacionPres);
            if (!HasPermission(User, subModule, "authorize")) return Forbid();

            var result = await _service.AutorizarAsync(id, UserContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("{id:int}/rechazar")]
        public async Task<ActionResult<PagedResult<EgreAdecuacionResponse>>> Rechazar(int id)
        {
            var current = await _service.GetByIdAsync(id);
            if (!current.Success || current.Data == null) return NotFound(current);
            if (!HasPermission(User, GetSubModuleName(current.Data.FkidTipoAdecuacionPres), "authorize")) return Forbid();

            var result = await _service.RechazarAsync(id, UserContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("{id:int}/cancelar-solicitud")]
        public async Task<ActionResult<PagedResult<EgreAdecuacionResponse>>> CancelarSolicitud(int id)
        {
            var current = await _service.GetByIdAsync(id);
            if (!current.Success || current.Data == null) return NotFound(current);
            if (!HasPermission(User, GetSubModuleName(current.Data.FkidTipoAdecuacionPres), "update")) return Forbid();

            var result = await _service.CancelarSolicitudAsync(id, UserContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        private static string GetSubModuleName(int tipoAdecuacionId) => tipoAdecuacionId switch
        {
            1 => "Adecuaciones_Compensadas",
            2 => "Reducciones",
            3 => "Ampliaciones",
            _ => string.Empty
        };

        private static bool HasPermission(ClaimsPrincipal user, string subModule, string action)
        {
            if (string.IsNullOrWhiteSpace(subModule)) return false;

            if (user.IsInRole("SuperAdmin")
                || user.Claims.Any(c => string.Equals(c.Type, ClaimTypes.Role, StringComparison.OrdinalIgnoreCase)
                    && string.Equals(c.Value, "SuperAdmin", StringComparison.OrdinalIgnoreCase)))
            {
                return true;
            }

            var claims = user.Claims.ToList();
            for (var index = 0; index < claims.Count; index++)
            {
                if (!IsClaim(claims[index], "Group", "Presupuesto_Modificado"))
                {
                    continue;
                }

                var subGroup = claims.Skip(index + 1).FirstOrDefault(c => IsClaimType(c, "SubGroup"));
                var values = claims.Skip(index + 1).FirstOrDefault(c => IsClaimType(c, "Values"));

                if (subGroup != null
                    && values != null
                    && string.Equals(subGroup.Value, subModule, StringComparison.OrdinalIgnoreCase)
                    && HasAction(values.Value, action))
                {
                    return true;
                }
            }

            return user.Claims.Any(c => IsClaim(c, "Group", "Presupuesto_Modificado"))
                && user.Claims.Any(c => IsClaim(c, "SubGroup", subModule))
                && user.Claims.Any(c => IsClaimType(c, "Values") && HasAction(c.Value, action));
        }

        private static bool IsClaim(Claim claim, string type, string value) =>
            IsClaimType(claim, type) && string.Equals(claim.Value, value, StringComparison.OrdinalIgnoreCase);

        private static bool IsClaimType(Claim claim, string type) =>
            string.Equals(claim.Type, type, StringComparison.OrdinalIgnoreCase);

        private static bool HasAction(string values, string action) =>
            values.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                .Any(value => string.Equals(value, action, StringComparison.OrdinalIgnoreCase));
    }

    [Route("api/[controller]")]
    public class EgreAdecuacionDetalleController(
        IAdquisicionCrudAppService<EgreAdecuacionDetalleResponse> service,
        IUserContextService userContext)
        : PresupuestoModificadoControllerBase<EgreAdecuacionDetalleResponse>(service, userContext);

    [Route("api/[controller]")]
    public class TipoAdecuacionController(GenericService<TipoAdecuacion, TipoAdecuacionDto, TipoAdecuacionResponse> service)
        : ReadOnlyCatalogController<TipoAdecuacionResponse>(service, "PkidTipoAdecuacion");

    [Route("api/[controller]")]
    public class EstatusAdecuacionController(GenericService<EstatusAdecuacion, EstatusAdecuacionDto, EstatusAdecuacionResponse> service)
        : ReadOnlyCatalogController<EstatusAdecuacionResponse>(service, "PkidEstatusAdecuacion");

    [Route("api/[controller]")]
    public class TipoMovimientoController(GenericService<TipoMovimiento, TipoMovimientoDto, TipoMovimientoResponse> service)
        : ReadOnlyCatalogController<TipoMovimientoResponse>(service, "PkidTipoMovimiento");

    [Route("api/[controller]")]
    public class EgresoDisponibleController(
        IAdquisicionCrudAppService<EgresoDisponibleResponse> service)
        : PresupuestoModificadoReadOnlyControllerBase<EgresoDisponibleResponse>(service);

    [ApiController]
    [Authorize]
    public abstract class ReadOnlyCatalogController<TResponse>(
        dynamic service,
        string idPropertyName) : ControllerBase
        where TResponse : class
    {
        [HttpGet("{id:int}")]
        public async Task<ActionResult<PagedResult<TResponse>>> GetById(int id)
        {
            TResponse? item = await service.GetByIdAsync(id, idPropertyName: idPropertyName);
            return item == null
                ? NotFound(new PagedResult<TResponse> { Success = false, Message = "Registro no encontrado", Code = "NOT_FOUND" })
                : Ok(new PagedResult<TResponse> { Success = true, Data = item, Items = new List<TResponse> { item }, TotalCount = 1 });
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<TResponse>>> GetAllPaginado([FromBody] PagedRequest request) =>
            Ok(await service.GetAllPaginadoAsync(request));
    }
}
