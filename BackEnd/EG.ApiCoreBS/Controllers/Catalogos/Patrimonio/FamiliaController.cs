using EG.ApiCoreBS.Services;
using EG.Application.Interfaces.Patrimonio;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Patrimonio;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Patrimonio
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class FamiliaController : ControllerBase
    {
        private readonly IFamiliaService _familiaService;

        public FamiliaController(IFamiliaService familiaService)
        {
            _familiaService = familiaService;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<FamiliaResponse>>> GetAll()
        {
            var result = await _familiaService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<FamiliaResponse>>> GetById(int id)
        {
            var result = await _familiaService.GetByIdAsync(id);
            if (!result.Success && result.Code == "NOT_FOUND")
                return NotFound(result);
            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<FamiliaResponse>>> Create([FromBody] FamiliaResponse response)
        {
            var result = await _familiaService.CreateAsync(response);
            if (!result.Success && result.Code == "DUPLICATE")
                return Conflict(result);
            if (!result.Success)
                return BadRequest(result);
            return CreatedAtAction(nameof(GetById), new { id = result.Data?.PkidFamilia }, result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<FamiliaResponse>>> Update(int id, [FromBody] FamiliaResponse response)
        {
            var result = await _familiaService.UpdateAsync(id, response);
            if (!result.Success && result.Code == "NOT_FOUND")
                return NotFound(result);
            if (!result.Success && result.Code == "DUPLICATE")
                return Conflict(result);
            if (!result.Success)
                return BadRequest(result);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            var result = await _familiaService.DeleteAsync(id);
            if (!result.Success && result.Code == "NOT_FOUND")
                return NotFound(result);
            if (!result.Success)
                return BadRequest(result);
            return Ok(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<FamiliaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _familiaService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<FamiliaResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            var result = await _familiaService.BuscarAsync(request);
            return Ok(result);
        }
    }
}
