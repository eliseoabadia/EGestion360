using System.Security.Claims;
using EG.ApiCoreBS.Controllers.PresupuestoModificado;
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

namespace EG.ApiCoreBS.Controllers.PresupuestoModificado
{
    [Route("api/[controller]")]
    public class IngreAdecuacionController(
        IIngresoAdecuacionAppService service,
        IUserContextService userContext)
        : PresupuestoModificadoControllerBase<IngreAdecuacionResponse>(service, userContext)
    {
        private readonly IIngresoAdecuacionAppService _service = service;

        [HttpPost("{id:int}/enviar-solicitud")]
        public async Task<ActionResult<PagedResult<IngreAdecuacionResponse>>> EnviarSolicitud(int id)
        {
            var result = await _service.EnviarSolicitudAsync(id, UserContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("{id:int}/autorizar")]
        public async Task<ActionResult<PagedResult<IngreAdecuacionResponse>>> Autorizar(int id)
        {
            var current = await _service.GetByIdAsync(id);
            if (!current.Success || current.Data == null) return NotFound(current);

            var subModule = GetSubModuleName(current.Data.FkidTipoAdecuacionPres);
            if (!HasAuthorizePermission(User, subModule)) return Forbid();

            var result = await _service.AutorizarAsync(id, UserContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("{id:int}/rechazar")]
        public async Task<ActionResult<PagedResult<IngreAdecuacionResponse>>> Rechazar(int id)
        {
            var current = await _service.GetByIdAsync(id);
            if (!current.Success || current.Data == null) return NotFound(current);

            var subModule = GetSubModuleName(current.Data.FkidTipoAdecuacionPres);
            if (!HasAuthorizePermission(User, subModule)) return Forbid();

            var result = await _service.RechazarAsync(id, UserContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        private static string GetSubModuleName(int tipoAdecuacionId) => tipoAdecuacionId switch
        {
            1 => "Adecuaciones_Compensadas",
            2 => "Reducciones",
            3 => "Ampliaciones",
            _ => string.Empty
        };

        private static bool HasAuthorizePermission(ClaimsPrincipal user, string subModule)
        {
            if (string.IsNullOrWhiteSpace(subModule)) return false;
            if (user.IsInRole("SuperAdmin") || user.Claims.Any(claim =>
                    string.Equals(claim.Type, ClaimTypes.Role, StringComparison.OrdinalIgnoreCase) &&
                    string.Equals(claim.Value, "SuperAdmin", StringComparison.OrdinalIgnoreCase)))
                return true;

            var claims = user.Claims.ToList();
            for (var index = 0; index < claims.Count; index++)
            {
                if (!IsClaim(claims[index], "Group", "Presupuesto_Modificado")) continue;

                var subGroup = claims.Skip(index + 1).FirstOrDefault(claim => IsClaimType(claim, "SubGroup"));
                var values = claims.Skip(index + 1).FirstOrDefault(claim => IsClaimType(claim, "Values"));
                if (subGroup != null && values != null &&
                    string.Equals(subGroup.Value, subModule, StringComparison.OrdinalIgnoreCase) &&
                    HasAction(values.Value, "authorize"))
                    return true;
            }

            return user.Claims.Any(claim => IsClaim(claim, "Group", "Presupuesto_Modificado")) &&
                   user.Claims.Any(claim => IsClaim(claim, "SubGroup", subModule)) &&
                   user.Claims.Any(claim => IsClaimType(claim, "Values") && HasAction(claim.Value, "authorize"));
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
    public class IngreAdecuacionDetalleController(
        IAdquisicionCrudAppService<IngreAdecuacionDetalleResponse> service,
        IUserContextService userContext)
        : PresupuestoModificadoControllerBase<IngreAdecuacionDetalleResponse>(service, userContext);

    [ApiController]
    [Authorize]
    [Route("api/[controller]")]
    public class IngresoDisponibleController(
        GenericService<VwIngresoDisponible, IngresoDisponibleDto, IngresoDisponibleResponse> service,
        IUserContextService userContext) : ControllerBase
    {
        [HttpGet("{id:int}")]
        public async Task<ActionResult<PagedResult<IngresoDisponibleResponse>>> GetById(int id)
        {
            if (!userContext.TryGetCurrentEmpresaId().HasValue)
                return BadRequest(CompanyRequired());

            var item = await service.GetByIdAsync(id, idPropertyName: "PkidIngresoAutorizado");
            return item == null
                ? NotFound(new PagedResult<IngresoDisponibleResponse> { Success = false, Message = "Registro no encontrado", Code = "NOT_FOUND" })
                : Ok(new PagedResult<IngresoDisponibleResponse> { Success = true, Data = item, Items = [item], TotalCount = 1 });
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<IngresoDisponibleResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            if (!userContext.TryGetCurrentEmpresaId().HasValue)
                return BadRequest(CompanyRequired());

            return Ok(await service.GetAllPaginadoAsync(request));
        }

        private static PagedResult<IngresoDisponibleResponse> CompanyRequired() => new()
        {
            Success = false,
            Message = "No se encontro la empresa activa en la sesion.",
            Code = "EMPRESA_REQUIRED"
        };
    }

    [ApiController]
    [Authorize]
    [Route("api/[controller]")]
    public class IngresoRecaudarController(
        GenericService<VwIngreXejer, IngreXEjerDto, IngreXEjerResponse> service,
        IUserContextService userContext) : ControllerBase
    {
        [HttpGet("{id:int}")]
        public async Task<ActionResult<PagedResult<IngreXEjerResponse>>> GetById(int id)
        {
            if (!userContext.TryGetCurrentEmpresaId().HasValue)
                return BadRequest(CompanyRequired());

            var item = await service.GetByIdAsync(id, idPropertyName: "PkIdIngresoAutorizado");
            return item == null
                ? NotFound(new PagedResult<IngreXEjerResponse> { Success = false, Message = "Registro no encontrado", Code = "NOT_FOUND" })
                : Ok(new PagedResult<IngreXEjerResponse> { Success = true, Data = item, Items = [item], TotalCount = 1 });
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<IngreXEjerResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            if (!userContext.TryGetCurrentEmpresaId().HasValue)
                return BadRequest(CompanyRequired());

            return Ok(await service.GetAllPaginadoAsync(request));
        }

        private static PagedResult<IngreXEjerResponse> CompanyRequired() => new()
        {
            Success = false,
            Message = "No se encontro la empresa activa en la sesion.",
            Code = "EMPRESA_REQUIRED"
        };
    }

    [ApiController]
    [Authorize]
    [Route("api/[controller]")]
    public class IngresoCLCFacturaController(
        GenericService<VwClcfactura, IngresoCLCFacturaDto, IngresoCLCFacturaResponse> service,
        IUserContextService userContext) : ControllerBase
    {
        [HttpGet("{id:int}")]
        public async Task<ActionResult<PagedResult<IngresoCLCFacturaResponse>>> GetById(int id)
        {
            if (!userContext.TryGetCurrentEmpresaId().HasValue)
                return BadRequest(CompanyRequired());

            var item = await service.GetByIdAsync(id, idPropertyName: "PkidClcfactura");
            return item == null
                ? NotFound(new PagedResult<IngresoCLCFacturaResponse> { Success = false, Message = "Registro no encontrado", Code = "NOT_FOUND" })
                : Ok(new PagedResult<IngresoCLCFacturaResponse> { Success = true, Data = item, Items = [item], TotalCount = 1 });
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<IngresoCLCFacturaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            if (!userContext.TryGetCurrentEmpresaId().HasValue)
                return BadRequest(CompanyRequired());

            return Ok(await service.GetAllPaginadoAsync(request));
        }

        private static PagedResult<IngresoCLCFacturaResponse> CompanyRequired() => new()
        {
            Success = false,
            Message = "No se encontro la empresa activa en la sesion.",
            Code = "EMPRESA_REQUIRED"
        };
    }
}
