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
    public class BienDisponibleBajaController : ControllerBase
    {
        private readonly IBienDisponibleBajaAppService _appService;
        private readonly IUserContextService _userContext;

        public BienDisponibleBajaController(IBienDisponibleBajaAppService appService, IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<BienDisponibleBajaResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<BienDisponibleBajaResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<BienDisponibleBajaResponse>>> Create([FromBody] BienDisponibleBajaResponse response)
        {
            var result = await _appService.CreateAsync(response, _userContext.GetCurrentUserId());
            return BadRequest(result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<BienDisponibleBajaResponse>>> Update(int id, [FromBody] BienDisponibleBajaResponse response)
        {
            var result = await _appService.UpdateAsync(id, response, _userContext.GetCurrentUserId());
            return BadRequest(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            var result = await _appService.DeleteAsync(id);
            return BadRequest(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<BienDisponibleBajaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<BienDisponibleBajaResponse>>> Buscar([FromBody] BusquedaRequest request)
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
