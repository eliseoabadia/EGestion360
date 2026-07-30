using EG.Application.Interfaces.Adquisicion;
using EG.Application.Interfaces.CuentasXPagar;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.CuentasXPagar;
using EG.Domain.DTOs.Requests.CuentasXPagar;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.CuentasXPagar
{
    [ApiController]
    [Authorize]
    public abstract class CuentasXPagarControllerBase<TResponse>(
        IAdquisicionCrudAppService<TResponse> service,
        IUserContextService userContext,
        IAuthorizationService authorization,
        string createAction,
        params string[] permissionPrefixes) : ControllerBase
        where TResponse : class
    {
        protected readonly IAdquisicionCrudAppService<TResponse> Service = service;
        protected readonly IUserContextService UserContext = userContext;

        [HttpGet]
        public async Task<ActionResult<PagedResult<TResponse>>> GetAll() =>
            await HasPermissionAsync("view") ? Ok(await Service.GetAllAsync()) : Forbid();

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<TResponse>>> GetById(int id)
        {
            if (!await HasPermissionAsync("view")) return Forbid();
            var result = await Service.GetByIdAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<TResponse>>> Create([FromBody] TResponse response)
        {
            if (!await HasPermissionAsync(createAction)) return Forbid();
            var result = await Service.CreateAsync(response, UserContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<TResponse>>> Update(int id, [FromBody] TResponse response)
        {
            if (!await HasPermissionAsync("update")) return Forbid();
            var result = await Service.UpdateAsync(id, response, UserContext.GetCurrentUserId());
            if (result.Success)
            {
                return Ok(result);
            }

            return result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            if (!await HasPermissionAsync("delete")) return Forbid();
            var result = await Service.DeleteAsync(id);
            if (result.Success)
            {
                return Ok(result);
            }

            return result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<TResponse>>> GetAllPaginado([FromBody] PagedRequest request) =>
            await HasPermissionAsync("view") ? Ok(await Service.GetAllPaginadoAsync(request)) : Forbid();

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

            return Ok(await Service.GetAllPaginadoAsync(pagedRequest));
        }

        protected async Task<bool> HasPermissionAsync(string action)
        {
            foreach (var prefix in permissionPrefixes)
            {
                if ((await authorization.AuthorizeAsync(User, null, $"{prefix}|{action}")).Succeeded)
                    return true;
            }
            return false;
        }
    }

    [Route("api/[controller]")]
    public class ContratoController(IAdquisicionCrudAppService<ContratoResponse> service, IUserContextService userContext, IAuthorizationService authorization)
        : CuentasXPagarControllerBase<ContratoResponse>(service, userContext, authorization, "new",
            "Tesoreria|Solicitud_Reintegros", "PEF_Unipartida_TES|RecepcionFactura_ComprobantePago",
            "Tesoreria|Provision_Pago", "PEF_Unipartida_TES|Provision_Pago", "PEF_Unipartida_TES|ElaboracionCheque_Transferencia");

    [Route("api/[controller]")]
    public class ContratoDetalleController(IAdquisicionCrudAppService<ContratoDetalleResponse> service, IUserContextService userContext, IAuthorizationService authorization)
        : CuentasXPagarControllerBase<ContratoDetalleResponse>(service, userContext, authorization, "new",
            "Tesoreria|Solicitud_Reintegros", "PEF_Unipartida_TES|RecepcionFactura_ComprobantePago",
            "Tesoreria|Provision_Pago", "PEF_Unipartida_TES|Provision_Pago", "PEF_Unipartida_TES|ElaboracionCheque_Transferencia");

    [Route("api/[controller]")]
    public class FacturaController(IAdquisicionCrudAppService<FacturaResponse> service, IUserContextService userContext, IAuthorizationService authorization)
        : CuentasXPagarControllerBase<FacturaResponse>(service, userContext, authorization, "new",
            "Tesoreria|Solicitud_Reintegros", "PEF_Unipartida_TES|RecepcionFactura_ComprobantePago");

    [Route("api/[controller]")]
    public class FacturaDetalleController(IAdquisicionCrudAppService<FacturaDetalleResponse> service, IUserContextService userContext, IAuthorizationService authorization)
        : CuentasXPagarControllerBase<FacturaDetalleResponse>(service, userContext, authorization, "new",
            "Tesoreria|Solicitud_Reintegros", "PEF_Unipartida_TES|RecepcionFactura_ComprobantePago");

    [Route("api/[controller]")]
    public class CLCController(IAdquisicionCrudAppService<CLCResponse> service, IUserContextService userContext, IAuthorizationService authorization)
        : CuentasXPagarControllerBase<CLCResponse>(service, userContext, authorization, "authorize",
            "Tesoreria|Solicitud_Reintegros", "PEF_Unipartida_TES|RecepcionFactura_ComprobantePago",
            "Tesoreria|Provision_Pago", "Tesoreria|Autorizar_Solicitud_Reingresos", "PEF_Unipartida_TES|Provision_Pago");

    [Route("api/[controller]")]
    public class CLCDetalleController(IAdquisicionCrudAppService<CLCDetalleResponse> service, IUserContextService userContext, IAuthorizationService authorization)
        : CuentasXPagarControllerBase<CLCDetalleResponse>(service, userContext, authorization, "authorize",
            "Tesoreria|Solicitud_Reintegros", "PEF_Unipartida_TES|RecepcionFactura_ComprobantePago",
            "Tesoreria|Provision_Pago", "Tesoreria|Autorizar_Solicitud_Reingresos", "PEF_Unipartida_TES|Provision_Pago");

    [Route("api/[controller]")]
    public class CLCFacturaController(IAdquisicionCrudAppService<CLCFacturaResponse> service, IUserContextService userContext, IAuthorizationService authorization)
        : CuentasXPagarControllerBase<CLCFacturaResponse>(service, userContext, authorization, "authorize",
            "Tesoreria|Solicitud_Reintegros", "PEF_Unipartida_TES|RecepcionFactura_ComprobantePago",
            "Tesoreria|Provision_Pago", "Tesoreria|Autorizar_Solicitud_Reingresos", "PEF_Unipartida_TES|Provision_Pago");

    [Route("api/[controller]")]
    public class ChequeController(IChequeAppService service, IUserContextService userContext, IAuthorizationService authorization)
        : CuentasXPagarControllerBase<ChequeResponse>(service, userContext, authorization, "authorize",
            "Tesoreria|Provision_Pago", "PEF_Unipartida_TES|ElaboracionCheque_Transferencia")
    {
        [HttpPost("{id:int}/regresar-solicitud-suficiencia")]
        public async Task<ActionResult<PagedResult<ChequeResponse>>> RegresarASolicitudSuficiencia(
            int id,
            [FromBody] RegresarChequeSuficienciaRequest request)
        {
            if (!await HasPermissionAsync("authorize")) return Forbid();
            var result = await service.RegresarASolicitudSuficienciaAsync(id, request.Motivo);
            if (result.Success)
                return Ok(result);

            return result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
        }
    }

    [Route("api/[controller]")]
    public class ChequePartidaController(IAdquisicionCrudAppService<ChequePartidaResponse> service, IUserContextService userContext, IAuthorizationService authorization)
        : CuentasXPagarControllerBase<ChequePartidaResponse>(service, userContext, authorization, "authorize",
            "Tesoreria|Provision_Pago", "PEF_Unipartida_TES|ElaboracionCheque_Transferencia");

    [Route("api/[controller]")]
    public class DepositoController(IDepositoAppService service, IUserContextService userContext, IAuthorizationService authorization)
        : CuentasXPagarControllerBase<DepositoResponse>(service, userContext, authorization, "new", "CuentasXCobrar|Depositos_CLC")
    {
        [HttpPost("{id:int}/autorizar")]
        public async Task<ActionResult<PagedResult<DepositoResponse>>> Autorizar(int id)
        {
            if (!await HasPermissionAsync("authorize")) return Forbid();
            var result = await service.AutorizarAsync(id);
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpGet("{id:int}/poliza")]
        public async Task<ActionResult<PagedResult<DepositoPolizaResponse>>> GetPoliza(int id)
        {
            if (!await HasPermissionAsync("view")) return Forbid();
            var result = await service.GetPolizaAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpGet("GetIngresoAutorizadoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetIngresoAutorizadoLookupPaginado(
            int page = 1,
            int pageSize = 25,
            string? filter = null,
            int? idAnio = null)
            => await HasPermissionAsync("view")
                ? Ok(await service.GetIngresoAutorizadoLookupPaginadoAsync(page, pageSize, filter, idAnio))
                : Forbid();

        [HttpGet("GetCLCFacturaLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetCLCFacturaLookupPaginado(
            int page = 1,
            int pageSize = 25,
            string? filter = null)
            => await HasPermissionAsync("view")
                ? Ok(await service.GetCLCFacturaLookupPaginadoAsync(page, pageSize, filter))
                : Forbid();

        [HttpGet("GetTipoDoctoPagoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetTipoDoctoPagoLookupPaginado(
            int page = 1,
            int pageSize = 25,
            string? filter = null)
            => await HasPermissionAsync("view")
                ? Ok(await service.GetTipoDoctoPagoLookupPaginadoAsync(page, pageSize, filter))
                : Forbid();

        [HttpGet("GetCuentaContableLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetCuentaContableLookupPaginado(
            int page = 1,
            int pageSize = 25,
            string? filter = null)
            => await HasPermissionAsync("view")
                ? Ok(await service.GetCuentaContableLookupPaginadoAsync(page, pageSize, filter))
                : Forbid();
    }
}
