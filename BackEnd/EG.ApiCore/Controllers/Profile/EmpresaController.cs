using EG.Application.CommonModel;
using EG.Business.Interfaces;
using EG.Business.Services;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Entities;
using EG.Dommain.DTOs.Responses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.Api.Controllers.Profile
{
    [Route("api/[controller]")]
    [ApiController]
    //[RequiredScope(RequiredScopesConfigurationKey = "AzureAdB2C:Scopes:Read")]
    [Authorize]
    public class EmpresaController(GenericService<Empresa, EmpresaDto, EmpresaResponse> service) : ControllerBase
    {
        private readonly GenericService<Empresa, EmpresaDto, EmpresaResponse> _service = service;

        [HttpGet("")]
        public async Task<ActionResult<IEnumerable<EmpresaDto>>> GetEmpresas()
        {
            //var IpAddress = "10.0.0.0";
            //int UserId = 1;
            //_logger.LogMessage(LogLevelGRP.Info, $"Log GetEmpresas ", (byte)SystemLogTypes.Error, "GetEmpresas", UserId.ToString(), IpAddress);
            return Ok(await _service.GetAllAsync());
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<EmpresaDto>> GetEmpresa( int id)
        {
            var item = await _service.GetByIdAsync(id);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost]
        //[RequiredScope(RequiredScopesConfigurationKey = "AzureAdB2C:Scopes:Write")]
        //[Authorize]
        public async Task<IActionResult> Create([FromBody] EmpresaDto dto)
        {
            await _service.AddAsync(dto);
            return Created(); //CreatedAtAction(nameof(GetDepts), new { questionId = dto.QuestionId });
        }

        [HttpPut("{id}")]
        //[RequiredScope(RequiredScopesConfigurationKey = "AzureAdB2C:Scopes:Write")]
        //[Authorize]
        public async Task<IActionResult> Update(int id, [FromBody] EmpresaDto dto)
        {
            await _service.UpdateAsync(id, dto);
            return NoContent();
        }

        //[HttpPatch("{id}")]
        ////[RequiredScope(RequiredScopesConfigurationKey = "AzureAdB2C:Scopes:Write")]
        ////[Authorize]
        //public async Task<IActionResult> UpdateUserEmpresa(int id, [FromBody] EmpresaDto dto)
        //{
        //    await _service.UpdateAsync(id, dto);
        //    return NoContent();
        //}

        [HttpDelete("{id}")]
        //[RequiredScope(RequiredScopesConfigurationKey = "AzureAdB2C:Scopes:Write")]
        //[Authorize]
        public async Task<IActionResult> Delete(int id)
        {
            await _service.DeleteAsync(id);
            return NoContent();
        }

        [HttpPost("GetAllDepartamentosPaginado")]
        public async Task<ActionResult<IList<EmpresaResponse>>> GetAllEmpresasPaginado([FromBody] PagedRequest _params)
        {
            return Ok(await _service.GetAllPaginadoAsync(_params));
        }
    }

}
