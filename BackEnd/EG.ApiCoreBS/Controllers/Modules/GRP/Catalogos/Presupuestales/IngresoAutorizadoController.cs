using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Catalogos.Presupuestales
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class IngresoAutorizadoController(
        IIngresoAutorizadoAppService appService,
        IUserContextService userContext) : ControllerBase
    {
        [HttpGet]
        public async Task<ActionResult<PagedResult<IngresoAutorizadoResponse>>> GetAll()
            => Ok(await appService.GetAllAsync());

        [HttpGet("{id:int}")]
        public async Task<ActionResult<PagedResult<IngresoAutorizadoResponse>>> GetById(int id)
        {
            var result = await appService.GetByIdAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<IngresoAutorizadoResponse>>> Create(
            [FromBody] IngresoAutorizadoResponse response)
        {
            var result = await appService.CreateAsync(response, userContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPut("{id:int}")]
        public async Task<ActionResult<PagedResult<IngresoAutorizadoResponse>>> Update(
            int id,
            [FromBody] IngresoAutorizadoResponse response)
        {
            var result = await appService.UpdateAsync(id, response, userContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpDelete("{id:int}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            var result = await appService.DeleteAsync(id);
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<IngresoAutorizadoResponse>>> GetAllPaginado(
            [FromBody] PagedRequest request)
            => Ok(await appService.GetAllPaginadoAsync(request));

        [HttpPost("{id:int}/autorizar")]
        public async Task<ActionResult<PagedResult<IngresoAutorizadoResponse>>> Autorizar(int id)
        {
            var result = await appService.AutorizarAsync(id);
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpGet("{id:int}/poliza")]
        public async Task<ActionResult<PagedResult<IngresoAutorizadoPolizaResponse>>> GetPoliza(int id)
        {
            var result = await appService.GetPolizaAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpGet("GetProgramaLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetProgramaLookupPaginado(
            int page = 1,
            int pageSize = 25,
            string? filter = null,
            int? idAnio = null)
            => Ok(await appService.GetProgramaLookupPaginadoAsync(page, pageSize, filter, idAnio));

        [HttpGet("GetOrigenLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetOrigenLookupPaginado(
            int page = 1,
            int pageSize = 25,
            string? filter = null)
            => Ok(await appService.GetOrigenLookupPaginadoAsync(page, pageSize, filter));

        [HttpGet("GetFuenteFinanciamientoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetFuenteFinanciamientoLookupPaginado(
            int page = 1,
            int pageSize = 25,
            string? filter = null)
            => Ok(await appService.GetFuenteFinanciamientoLookupPaginadoAsync(page, pageSize, filter));

        [HttpGet("GetTipoGastoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetTipoGastoLookupPaginado(
            int page = 1,
            int pageSize = 25,
            string? filter = null)
            => Ok(await appService.GetTipoGastoLookupPaginadoAsync(page, pageSize, filter));

        [HttpGet("GetDigitoIdentificadorLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetDigitoIdentificadorLookupPaginado(
            int page = 1,
            int pageSize = 25,
            string? filter = null)
            => Ok(await appService.GetDigitoIdentificadorLookupPaginadoAsync(page, pageSize, filter));

        [HttpGet("GetDestinoGastoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetDestinoGastoLookupPaginado(
            int page = 1,
            int pageSize = 25,
            string? filter = null)
            => Ok(await appService.GetDestinoGastoLookupPaginadoAsync(page, pageSize, filter));
    }
}
