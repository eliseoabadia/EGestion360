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
    public class BajaController : ControllerBase
    {
        private readonly IBajaAppService _appService;
        private readonly IUserContextService _userContext;

        public BajaController(IBajaAppService appService, IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<BajaResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<BajaResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<BajaResponse>>> Create([FromBody] BajaResponse response)
        {
            var result = await _appService.CreateAsync(response, _userContext.GetCurrentUserId());
            if (!result.Success)
            {
                return result.Code == "DUPLICATE" ? Conflict(result) : BadRequest(result);
            }

            var id = result.Data?.PkidBaja ?? response.PkidBaja;
            return CreatedAtAction(nameof(GetById), new { id }, result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<BajaResponse>>> Update(int id, [FromBody] BajaResponse response)
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
            if (result.Success)
            {
                return Ok(result);
            }

            return result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<BajaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<BajaResponse>>> Buscar([FromBody] BusquedaRequest request)
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
