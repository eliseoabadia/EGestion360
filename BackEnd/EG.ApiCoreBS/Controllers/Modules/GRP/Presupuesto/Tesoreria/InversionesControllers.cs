using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Presupuesto.Tesoreria
{
    [ApiController]
    [Authorize]
    public abstract class InversionesControllerBase<TResponse>(
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

        protected async Task<ActionResult<PagedResult<TResponse>>> CreateInternal(TResponse response)
        {
            SetEmpresaFromContext(response);
            var result = await Service.CreateAsync(response, UserContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        protected async Task<ActionResult<PagedResult<TResponse>>> UpdateInternal(int id, TResponse response)
        {
            SetEmpresaFromContext(response);
            var result = await Service.UpdateAsync(id, response, UserContext.GetCurrentUserId());
            if (result.Success)
            {
                return Ok(result);
            }

            return result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
        }

        protected async Task<ActionResult<PagedResult<bool>>> DeleteInternal(int id)
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

        private void SetEmpresaFromContext(TResponse response)
        {
            var property = response.GetType().GetProperty("FkidEmpresaSis");
            if (property == null || !property.CanWrite)
            {
                return;
            }

            var currentValue = property.GetValue(response);
            if (currentValue is int empresaId && empresaId > 0)
            {
                return;
            }

            property.SetValue(response, UserContext.GetCurrentEmpresaId());
        }
    }

    [Route("api/[controller]")]
    public class BancoController(
        IAdquisicionCrudAppService<BancoResponse> service,
        IUserContextService userContext)
        : InversionesControllerBase<BancoResponse>(service, userContext)
    {
        [HttpPost]
        [Authorize(Policy = "Inversiones_Banco_new")]
        public async Task<ActionResult<PagedResult<BancoResponse>>> Create([FromBody] BancoResponse response) =>
            await CreateInternal(response);

        [HttpPut("{id}")]
        [Authorize(Policy = "Inversiones_Banco_update")]
        public async Task<ActionResult<PagedResult<BancoResponse>>> Update(int id, [FromBody] BancoResponse response) =>
            await UpdateInternal(id, response);

        [HttpDelete("{id}")]
        [Authorize(Policy = "Inversiones_Banco_delete")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id) =>
            await DeleteInternal(id);
    }

    [Route("api/[controller]")]
    public class CuentaBancariaController(
        IAdquisicionCrudAppService<CuentaBancariaResponse> service,
        IUserContextService userContext)
        : InversionesControllerBase<CuentaBancariaResponse>(service, userContext)
    {
        [HttpPost]
        [Authorize(Policy = "Inversiones_Cuenta_Bancaria_new")]
        public async Task<ActionResult<PagedResult<CuentaBancariaResponse>>> Create([FromBody] CuentaBancariaResponse response) =>
            await CreateInternal(response);

        [HttpPut("{id}")]
        [Authorize(Policy = "Inversiones_Cuenta_Bancaria_update")]
        public async Task<ActionResult<PagedResult<CuentaBancariaResponse>>> Update(int id, [FromBody] CuentaBancariaResponse response) =>
            await UpdateInternal(id, response);

        [HttpDelete("{id}")]
        [Authorize(Policy = "Inversiones_Cuenta_Bancaria_delete")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id) =>
            await DeleteInternal(id);
    }

    [Route("api/[controller]")]
    public class IntermediarioFinancieroController(
        IAdquisicionCrudAppService<IntermediarioFinancieroResponse> service,
        IUserContextService userContext)
        : InversionesControllerBase<IntermediarioFinancieroResponse>(service, userContext)
    {
        [HttpPost]
        [Authorize(Policy = "Inversiones_Intermediarios_Financiero_new")]
        public async Task<ActionResult<PagedResult<IntermediarioFinancieroResponse>>> Create([FromBody] IntermediarioFinancieroResponse response) =>
            await CreateInternal(response);

        [HttpPut("{id}")]
        [Authorize(Policy = "Inversiones_Intermediarios_Financiero_update")]
        public async Task<ActionResult<PagedResult<IntermediarioFinancieroResponse>>> Update(int id, [FromBody] IntermediarioFinancieroResponse response) =>
            await UpdateInternal(id, response);

        [HttpDelete("{id}")]
        [Authorize(Policy = "Inversiones_Intermediarios_Financiero_delete")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id) =>
            await DeleteInternal(id);
    }

    [Route("api/[controller]")]
    public class InstrumentoController(
        IAdquisicionCrudAppService<InstrumentoResponse> service,
        IUserContextService userContext)
        : InversionesControllerBase<InstrumentoResponse>(service, userContext)
    {
        [HttpPost]
        [Authorize(Policy = "Tesoreria_Instrumentos_Inversion_new")]
        public async Task<ActionResult<PagedResult<InstrumentoResponse>>> Create([FromBody] InstrumentoResponse response) =>
            await CreateInternal(response);

        [HttpPut("{id}")]
        [Authorize(Policy = "Tesoreria_Instrumentos_Inversion_update")]
        public async Task<ActionResult<PagedResult<InstrumentoResponse>>> Update(int id, [FromBody] InstrumentoResponse response) =>
            await UpdateInternal(id, response);

        [HttpDelete("{id}")]
        [Authorize(Policy = "Tesoreria_Instrumentos_Inversion_delete")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id) =>
            await DeleteInternal(id);
    }

    [Route("api/[controller]")]
    public class InversionController(
        IAdquisicionCrudAppService<InversionResponse> service,
        IUserContextService userContext)
        : InversionesControllerBase<InversionResponse>(service, userContext)
    {
        [HttpPost]
        [Authorize(Policy = "Inversiones_Listado_Inversiones_new")]
        public async Task<ActionResult<PagedResult<InversionResponse>>> Create([FromBody] InversionResponse response) =>
            await CreateInternal(response);

        [HttpPut("{id}")]
        [Authorize(Policy = "Inversiones_Listado_Inversiones_update")]
        public async Task<ActionResult<PagedResult<InversionResponse>>> Update(int id, [FromBody] InversionResponse response) =>
            await UpdateInternal(id, response);

        [HttpDelete("{id}")]
        [Authorize(Policy = "Inversiones_Listado_Inversiones_delete")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id) =>
            await DeleteInternal(id);
    }

    [Route("api/[controller]")]
    public class InteresController(
        IAdquisicionCrudAppService<InteresResponse> service,
        IUserContextService userContext)
        : InversionesControllerBase<InteresResponse>(service, userContext)
    {
        [HttpPost]
        [Authorize(Policy = "Inversiones_Listado_Inversiones_new")]
        public async Task<ActionResult<PagedResult<InteresResponse>>> Create([FromBody] InteresResponse response) =>
            await CreateInternal(response);

        [HttpPut("{id}")]
        [Authorize(Policy = "Inversiones_Listado_Inversiones_update")]
        public async Task<ActionResult<PagedResult<InteresResponse>>> Update(int id, [FromBody] InteresResponse response) =>
            await UpdateInternal(id, response);

        [HttpDelete("{id}")]
        [Authorize(Policy = "Inversiones_Listado_Inversiones_delete")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id) =>
            await DeleteInternal(id);
    }

    [Route("api/[controller]")]
    public class RetiroController(
        IAdquisicionCrudAppService<RetiroResponse> service,
        IUserContextService userContext)
        : InversionesControllerBase<RetiroResponse>(service, userContext)
    {
        [HttpPost]
        [Authorize(Policy = "Inversiones_Listado_Inversiones_new")]
        public async Task<ActionResult<PagedResult<RetiroResponse>>> Create([FromBody] RetiroResponse response) =>
            await CreateInternal(response);

        [HttpPut("{id}")]
        [Authorize(Policy = "Inversiones_Listado_Inversiones_update")]
        public async Task<ActionResult<PagedResult<RetiroResponse>>> Update(int id, [FromBody] RetiroResponse response) =>
            await UpdateInternal(id, response);

        [HttpDelete("{id}")]
        [Authorize(Policy = "Inversiones_Listado_Inversiones_delete")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id) =>
            await DeleteInternal(id);
    }

    [Route("api/[controller]")]
    public class TipoPlazoController(
        IAdquisicionCrudAppService<TipoPlazoResponse> service,
        IUserContextService userContext)
        : InversionesControllerBase<TipoPlazoResponse>(service, userContext)
    {
        [HttpPost]
        [Authorize(Policy = "Inversiones_Tipo_Plazos_new")]
        public async Task<ActionResult<PagedResult<TipoPlazoResponse>>> Create([FromBody] TipoPlazoResponse response) =>
            await CreateInternal(response);

        [HttpPut("{id}")]
        [Authorize(Policy = "Inversiones_Tipo_Plazos_update")]
        public async Task<ActionResult<PagedResult<TipoPlazoResponse>>> Update(int id, [FromBody] TipoPlazoResponse response) =>
            await UpdateInternal(id, response);

        [HttpDelete("{id}")]
        [Authorize(Policy = "Inversiones_Tipo_Plazos_delete")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id) =>
            await DeleteInternal(id);
    }

    [Route("api/[controller]")]
    public class TipoRetiroController(
        IAdquisicionCrudAppService<TipoRetiroResponse> service,
        IUserContextService userContext)
        : InversionesControllerBase<TipoRetiroResponse>(service, userContext)
    {
        [HttpPost]
        [Authorize(Policy = "Inversiones_Tipo_Retiro_new")]
        public async Task<ActionResult<PagedResult<TipoRetiroResponse>>> Create([FromBody] TipoRetiroResponse response) =>
            await CreateInternal(response);

        [HttpPut("{id}")]
        [Authorize(Policy = "Inversiones_Tipo_Retiro_update")]
        public async Task<ActionResult<PagedResult<TipoRetiroResponse>>> Update(int id, [FromBody] TipoRetiroResponse response) =>
            await UpdateInternal(id, response);

        [HttpDelete("{id}")]
        [Authorize(Policy = "Inversiones_Tipo_Retiro_delete")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id) =>
            await DeleteInternal(id);
    }
}
