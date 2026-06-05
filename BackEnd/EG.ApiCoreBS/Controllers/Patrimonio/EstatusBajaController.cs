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
    public class EstatusBajaController : ControllerBase
    {
        private readonly IEstatusBajaAppService _appService;
        private readonly IUserContextService _userContext;

        public EstatusBajaController(IEstatusBajaAppService appService, IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<EstatusBajaResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<EstatusBajaResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<EstatusBajaResponse>>> Create([FromBody] EstatusBajaResponse response)
        {
            var result = await _appService.CreateAsync(response, _userContext.GetCurrentUserId());
            if (!result.Success)
            {
                return result.Code == "DUPLICATE" ? Conflict(result) : BadRequest(result);
            }

            return CreatedAtAction(nameof(GetById), new { id = response.PkidEstatusBaja }, result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<EstatusBajaResponse>>> Update(int id, [FromBody] EstatusBajaResponse response)
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
        public async Task<ActionResult<PagedResult<EstatusBajaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<EstatusBajaResponse>>> Buscar([FromBody] BusquedaRequest request)
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
