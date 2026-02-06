using EG.Application.CommonModel;
using EG.Business.Services;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Entities;
using EG.Dommain.DTOs.Responses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.Profile
{
    [Route("api/[controller]")]
    [ApiController]
    //[RequiredScope(RequiredScopesConfigurationKey = "AzureAdB2C:Scopes:Read")]
    [Authorize]
    public class DepartamentoController(GenericService<Departamento, DepartamentoDto, DepartamentoResponse> service) : ControllerBase
    {
        private readonly GenericService<Departamento, DepartamentoDto, DepartamentoResponse> _service = service;

        [HttpGet]
        public async Task<ActionResult<IEnumerable<DepartamentoDto>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<DepartamentoDto>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            return result == null ? NotFound() : Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult> Add(DepartamentoDto dto)
        {
            await _service.AddAsync(dto);
            return CreatedAtAction(nameof(GetById), dto);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult> Update(int id, DepartamentoDto dto)
        {
            await _service.UpdateAsync(id, dto);
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            await _service.DeleteAsync(id);
            return NoContent();
        }

        [HttpPost("GetAllDepartamentosPaginado")]
        public async Task<ActionResult<IList<DepartamentoResponse>>> GetAllDepartamentosPaginado([FromBody] PagedRequest _params)
        {
            return Ok(await _service.GetAllPaginadoAsync(_params));
        }
    }
}
