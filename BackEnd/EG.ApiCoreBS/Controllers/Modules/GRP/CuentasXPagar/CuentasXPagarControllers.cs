using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.CuentasXPagar;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.CuentasXPagar
{
    [ApiController]
    [Authorize]
    public abstract class CuentasXPagarControllerBase<TResponse>(
        IAdquisicionCrudAppService<TResponse> service,
        IUserContextService userContext) : ControllerBase
        where TResponse : class
    {
        protected readonly IAdquisicionCrudAppService<TResponse> Service = service;
        protected readonly IUserContextService UserContext = userContext;

        [HttpGet]
        public async Task<ActionResult<PagedResult<TResponse>>> GetAll() => Ok(await Service.GetAllAsync());

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<TResponse>>> GetById(int id)
        {
            var result = await Service.GetByIdAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<TResponse>>> Create([FromBody] TResponse response)
        {
            var result = await Service.CreateAsync(response, UserContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<TResponse>>> Update(int id, [FromBody] TResponse response)
        {
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
            var result = await Service.DeleteAsync(id);
            if (result.Success)
            {
                return Ok(result);
            }

            return result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<TResponse>>> GetAllPaginado([FromBody] PagedRequest request) =>
            Ok(await Service.GetAllPaginadoAsync(request));

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<TResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
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
    }

    [Route("api/[controller]")]
    public class ContratoController(IAdquisicionCrudAppService<ContratoResponse> service, IUserContextService userContext)
        : CuentasXPagarControllerBase<ContratoResponse>(service, userContext);

    [Route("api/[controller]")]
    public class ContratoDetalleController(IAdquisicionCrudAppService<ContratoDetalleResponse> service, IUserContextService userContext)
        : CuentasXPagarControllerBase<ContratoDetalleResponse>(service, userContext);

    [Route("api/[controller]")]
    public class FacturaController(IAdquisicionCrudAppService<FacturaResponse> service, IUserContextService userContext)
        : CuentasXPagarControllerBase<FacturaResponse>(service, userContext);

    [Route("api/[controller]")]
    public class FacturaDetalleController(IAdquisicionCrudAppService<FacturaDetalleResponse> service, IUserContextService userContext)
        : CuentasXPagarControllerBase<FacturaDetalleResponse>(service, userContext);

    [Route("api/[controller]")]
    public class CLCController(IAdquisicionCrudAppService<CLCResponse> service, IUserContextService userContext)
        : CuentasXPagarControllerBase<CLCResponse>(service, userContext);

    [Route("api/[controller]")]
    public class CLCDetalleController(IAdquisicionCrudAppService<CLCDetalleResponse> service, IUserContextService userContext)
        : CuentasXPagarControllerBase<CLCDetalleResponse>(service, userContext);

    [Route("api/[controller]")]
    public class CLCFacturaController(IAdquisicionCrudAppService<CLCFacturaResponse> service, IUserContextService userContext)
        : CuentasXPagarControllerBase<CLCFacturaResponse>(service, userContext);

    [Route("api/[controller]")]
    public class ChequeController(IAdquisicionCrudAppService<ChequeResponse> service, IUserContextService userContext)
        : CuentasXPagarControllerBase<ChequeResponse>(service, userContext);

    [Route("api/[controller]")]
    public class ChequePartidaController(IAdquisicionCrudAppService<ChequePartidaResponse> service, IUserContextService userContext)
        : CuentasXPagarControllerBase<ChequePartidaResponse>(service, userContext);
}
