using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Catalogos.Presupuestales
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class EgresoProyectadoController : ControllerBase
    {
        private readonly IEgresoProyectadoAppService _appService;
        private readonly IUserContextService _userContext;

        public EgresoProyectadoController(
            IEgresoProyectadoAppService appService,
            IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<EgresoProyectadoResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<EgresoProyectadoResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            if (!result.Success)
                return NotFound(result);

            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<EgresoProyectadoResponse>>> Create([FromBody] EgresoProyectadoResponse response)
        {
            var result = await _appService.CreateAsync(response, _userContext.GetCurrentUserId());
            if (!result.Success)
                return BadRequest(result);

            return CreatedAtAction(nameof(GetById), new { id = response.PkidEgresoProyectado }, result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<EgresoProyectadoResponse>>> Update(int id, [FromBody] EgresoProyectadoResponse response)
        {
            var result = await _appService.UpdateAsync(id, response, _userContext.GetCurrentUserId());
            if (!result.Success)
            {
                if (result.Code == "NOT_FOUND")
                    return NotFound(result);

                return BadRequest(result);
            }

            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            var result = await _appService.DeleteAsync(id);
            if (!result.Success)
            {
                if (result.Code == "NOT_FOUND")
                    return NotFound(result);

                return BadRequest(result);
            }

            return Ok(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<EgresoProyectadoResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpGet("GetFuenteFinanciamientoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetFuenteFinanciamientoLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var result = await _appService.GetFuenteFinanciamientoLookupPaginadoAsync(page, pageSize, filter);
            return Ok(result);
        }

        [HttpGet("GetTipoGastoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetTipoGastoLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var result = await _appService.GetTipoGastoLookupPaginadoAsync(page, pageSize, filter);
            return Ok(result);
        }

        [HttpGet("GetDigitoIdentificadorLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetDigitoIdentificadorLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var result = await _appService.GetDigitoIdentificadorLookupPaginadoAsync(page, pageSize, filter);
            return Ok(result);
        }

        [HttpGet("GetDestinoGastoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetDestinoGastoLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var result = await _appService.GetDestinoGastoLookupPaginadoAsync(page, pageSize, filter);
            return Ok(result);
        }

        [HttpGet("GetPyLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetPyLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var result = await _appService.GetPyLookupPaginadoAsync(page, pageSize, filter);
            return Ok(result);
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<EgresoProyectadoResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };

            var result = await _appService.GetAllPaginadoAsync(pagedRequest);
            return Ok(result);
        }
    }
}
