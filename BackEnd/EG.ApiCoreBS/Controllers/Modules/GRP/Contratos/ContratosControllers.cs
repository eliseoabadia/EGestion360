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
    public abstract class ContratosControllerBase<TResponse>(
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
            return result.Success ? Ok(result) : result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            var result = await Service.DeleteAsync(id);
            return result.Success ? Ok(result) : result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
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
        IAdquisicionCrudAppService<SaldosContratoResponse> service,
        IUserContextService userContext)
        : ContratosControllerBase<SaldosContratoResponse>(service, userContext);

    [Route("api/[controller]")]
    public class EstadoContratoController(
        IAdquisicionCrudAppService<EstadoContratoResponse> service,
        IUserContextService userContext)
        : ContratosControllerBase<EstadoContratoResponse>(service, userContext);
}
