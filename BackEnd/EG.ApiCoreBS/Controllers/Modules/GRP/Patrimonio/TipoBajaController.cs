using EG.Application.Interfaces.Patrimonio;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Patrimonio
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class TipoBajaController : ControllerBase
    {
        private readonly ITipoBajaAppService _appService;
        private readonly IUserContextService _userContext;

        public TipoBajaController(ITipoBajaAppService appService, IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<TipoBajaResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<TipoBajaResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<TipoBajaResponse>>> Create([FromBody] TipoBajaResponse response)
        {
            var result = await _appService.CreateAsync(response, _userContext.GetCurrentUserId());
            if (!result.Success)
            {
                return result.Code == "DUPLICATE" ? Conflict(result) : BadRequest(result);
            }

            return CreatedAtAction(nameof(GetById), new { id = response.PkidTipoBaja }, result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<TipoBajaResponse>>> Update(int id, [FromBody] TipoBajaResponse response)
        {
            var result = await _appService.UpdateAsync(id, response, _userContext.GetCurrentUserId());
            if (result.Success)
            {
                return Ok(result);
            }

            return result.Code switch
            {
                "NOT_FOUND" => NotFound(result),
                "DUPLICATE" => Conflict(result),
                _ => BadRequest(result)
            };
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            var result = await _appService.DeleteAsync(id);
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<TipoBajaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<TipoBajaResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SearchString = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };

            var result = await _appService.GetAllPaginadoAsync(pagedRequest);
            return Ok(result);
        }
    }
}
