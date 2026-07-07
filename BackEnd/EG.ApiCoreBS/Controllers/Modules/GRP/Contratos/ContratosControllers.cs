using EG.Application.Interfaces.Adquisicion;
using EG.Application.Interfaces.Contratos;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Contratos;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Contratos
{
    [ApiController]
    [Authorize]
    public abstract class ContratosReadOnlyControllerBase<TResponse>(
        IAdquisicionCrudAppService<TResponse> service) : ControllerBase
        where TResponse : class
    {
        protected readonly IAdquisicionCrudAppService<TResponse> Service = service;

        [HttpGet]
        public async Task<ActionResult<PagedResult<TResponse>>> GetAll() => Ok(await Service.GetAllAsync());

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<TResponse>>> GetById(int id)
        {
            var result = await Service.GetByIdAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
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

    public abstract class ContratosUpdateOnlyControllerBase<TResponse>(
        IAdquisicionCrudAppService<TResponse> service,
        IUserContextService userContext) : ContratosReadOnlyControllerBase<TResponse>(service)
        where TResponse : class
    {
        protected readonly IUserContextService UserContext = userContext;

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<TResponse>>> Update(int id, [FromBody] TResponse response)
        {
            var result = await Service.UpdateAsync(id, response, UserContext.GetCurrentUserId());
            return result.Success ? Ok(result) : result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
        }
    }

    public abstract class ContratosControllerBase<TResponse>(
        IAdquisicionCrudAppService<TResponse> service,
        IUserContextService userContext) : ContratosUpdateOnlyControllerBase<TResponse>(service, userContext)
        where TResponse : class
    {
        [HttpPost]
        public async Task<ActionResult<PagedResult<TResponse>>> Create([FromBody] TResponse response)
        {
            var result = await Service.CreateAsync(response, UserContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            var result = await Service.DeleteAsync(id);
            return result.Success ? Ok(result) : result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
        }
    }

    [Route("api/[controller]")]
    public class RegistroCompromisoController(
        IRegistroCompromisoAppService service,
        IUserContextService userContext)
        : ContratosControllerBase<OrcoContratoResponse>(service, userContext)
    {
        [HttpPost("{id:int}/autorizar")]
        public async Task<ActionResult<PagedResult<OrcoContratoResponse>>> Autorizar(int id)
        {
            var result = await service.AutorizarAsync(id, UserContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }
    }

    [Route("api/[controller]")]
    public class SaldosContratosController(
        IAdquisicionCrudAppService<SaldosContratoResponse> service)
        : ContratosReadOnlyControllerBase<SaldosContratoResponse>(service);

    [Route("api/[controller]")]
    public class EstadoContratoController(
        IEstadoContratoAppService service,
        IUserContextService userContext)
        : ContratosControllerBase<EstadoContratoResponse>(service, userContext)
    {
        [HttpPost("{id:int}/autorizar")]
        public async Task<ActionResult<PagedResult<EstadoContratoResponse>>> Autorizar(int id)
        {
            var result = await service.AutorizarAsync(id, UserContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("{id:int}/liberar-remanente")]
        public async Task<ActionResult<PagedResult<EstadoContratoResponse>>> LiberarRemanente(int id)
        {
            var result = await service.LiberarRemanenteAsync(id, UserContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }
    }
}
