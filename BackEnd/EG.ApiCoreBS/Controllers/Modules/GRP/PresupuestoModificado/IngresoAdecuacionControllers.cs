using EG.Common.Enums;
using EG.Application.Interfaces.General;
using EG.Application.Interfaces.Adquisicion;
using EG.Application.Interfaces.PresupuestoModificado;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.PresupuestoModificado;
using EG.Domain.DTOs.Responses.PresupuestoModificado;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.PresupuestoModificado
{
    [Route("api/[controller]")]
    public class IngreAdecuacionController(
        IIngresoAdecuacionAppService service,
        IUserContextService userContext,
        IAuthorizationService authorization)
        : PresupuestoModificadoControllerBase<IngreAdecuacionResponse>(service, userContext, authorization)
    {
        private readonly IIngresoAdecuacionAppService _service = service;
        protected override string PermissionFilterName => nameof(IngreAdecuacionResponse.FkidTipoAdecuacionPres);
        protected override Task<int?> GetTipoAdecuacionAsync(IngreAdecuacionResponse response) =>
            Task.FromResult<int?>(response.FkidTipoAdecuacionPres);
        protected override Task<int?> GetFilterTipoAdecuacionAsync(int value) => Task.FromResult<int?>(value);

        [HttpPost("{id:int}/enviar-solicitud")]
        public async Task<ActionResult<PagedResult<IngreAdecuacionResponse>>> EnviarSolicitud(int id)
        {
            var current = await _service.GetByIdAsync(id);
            if (!current.Success || current.Data == null) return NotFound(current);
            if (!await HasPermissionAsync(current.Data.FkidTipoAdecuacionPres, PermissionAction.Update)) return Forbid();
            var result = await _service.EnviarSolicitudAsync(id, UserContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("{id:int}/autorizar")]
        public async Task<ActionResult<PagedResult<IngreAdecuacionResponse>>> Autorizar(int id)
        {
            var current = await _service.GetByIdAsync(id);
            if (!current.Success || current.Data == null) return NotFound(current);

            if (!await HasPermissionAsync(current.Data.FkidTipoAdecuacionPres, PermissionAction.Authorize)) return Forbid();

            var result = await _service.AutorizarAsync(id, UserContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("{id:int}/rechazar")]
        public async Task<ActionResult<PagedResult<IngreAdecuacionResponse>>> Rechazar(int id)
        {
            var current = await _service.GetByIdAsync(id);
            if (!current.Success || current.Data == null) return NotFound(current);

            if (!await HasPermissionAsync(current.Data.FkidTipoAdecuacionPres, PermissionAction.Authorize)) return Forbid();

            var result = await _service.RechazarAsync(id, UserContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

    }

    [Route("api/[controller]")]
    public class IngreAdecuacionDetalleController(
        IAdquisicionCrudAppService<IngreAdecuacionDetalleResponse> service,
        IUserContextService userContext,
        IAuthorizationService authorization,
        IIngresoAdecuacionAppService headers)
        : PresupuestoModificadoControllerBase<IngreAdecuacionDetalleResponse>(service, userContext, authorization)
    {
        protected override string PermissionFilterName => nameof(IngreAdecuacionDetalleResponse.FkidIngreAdecuacionPres);
        protected override Task<int?> GetTipoAdecuacionAsync(IngreAdecuacionDetalleResponse response) =>
            GetFilterTipoAdecuacionAsync(response.FkidIngreAdecuacionPres);
        protected override async Task<int?> GetFilterTipoAdecuacionAsync(int value)
        {
            var parent = await headers.GetByIdAsync(value);
            return parent.Success ? parent.Data?.FkidTipoAdecuacionPres : null;
        }
    }

    [ApiController]
    [Authorize]
    [Route("api/[controller]")]
    public class IngresoDisponibleController(
        IReadOnlyCatalogAppService<IngresoDisponibleResponse> service,
        IUserContextService userContext) : ControllerBase
    {
        [HttpGet("{id:int}")]
        public async Task<ActionResult<PagedResult<IngresoDisponibleResponse>>> GetById(int id)
        {
            if (!userContext.TryGetCurrentEmpresaId().HasValue)
                return BadRequest(CompanyRequired());

            var item = await service.GetByIdAsync(id);
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
        IReadOnlyCatalogAppService<IngreXEjerResponse> service,
        IUserContextService userContext) : ControllerBase
    {
        [HttpGet("{id:int}")]
        public async Task<ActionResult<PagedResult<IngreXEjerResponse>>> GetById(int id)
        {
            if (!userContext.TryGetCurrentEmpresaId().HasValue)
                return BadRequest(CompanyRequired());

            var item = await service.GetByIdAsync(id);
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
        IReadOnlyCatalogAppService<IngresoCLCFacturaResponse> service,
        IUserContextService userContext) : ControllerBase
    {
        [HttpGet("{id:int}")]
        public async Task<ActionResult<PagedResult<IngresoCLCFacturaResponse>>> GetById(int id)
        {
            if (!userContext.TryGetCurrentEmpresaId().HasValue)
                return BadRequest(CompanyRequired());

            var item = await service.GetByIdAsync(id);
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
