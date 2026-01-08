using EG.Business.Interfaces;
using EG.Dommain.DTOs.Responses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.Api.Controllers.Profile
{
    [Route("api/[controller]")]
    [ApiController]
    //[RequiredScope(RequiredScopesConfigurationKey = "AzureAdB2C:Scopes:Read")]
    [Authorize]
    public class EmpresaController : ControllerBase
    {
        private readonly Logger.Log4NetLogger _logger = new Logger.Log4NetLogger(typeof(EmpresaController));
        private readonly IEmpresaService _service;

        public EmpresaController(IEmpresaService service)
        {
            _service = service;
        }

        [HttpGet("")]
        public async Task<ActionResult<IEnumerable<EmpresaDto>>> GetEmpresas()
        {
            //var IpAddress = "10.0.0.0";
            //int UserId = 1;
            //_logger.LogMessage(LogLevelGRP.Info, $"Log GetEmpresas ", (byte)SystemLogTypes.Error, "GetEmpresas", UserId.ToString(), IpAddress);
            return Ok(await _service.GetAllEmpresasAsync());
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<EmpresaDto>> GetEmpresa( int id)
        {
            var item = await _service.GetEmpresaByIdAsync(id);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost]
        //[RequiredScope(RequiredScopesConfigurationKey = "AzureAdB2C:Scopes:Write")]
        //[Authorize]
        public async Task<IActionResult> CreateDept([FromBody] EmpresaDto dto)
        {
            await _service.AddEmpresaAsync(dto);
            return Created(); //CreatedAtAction(nameof(GetDepts), new { questionId = dto.QuestionId });
        }

        [HttpPut("{id}")]
        //[RequiredScope(RequiredScopesConfigurationKey = "AzureAdB2C:Scopes:Write")]
        //[Authorize]
        public async Task<IActionResult> UpdateEmpresa(int id, [FromBody] EmpresaDto dto)
        {
            await _service.UpdateEmpresaAsync(id, dto);
            return NoContent();
        }

        [HttpPatch("{id}")]
        //[RequiredScope(RequiredScopesConfigurationKey = "AzureAdB2C:Scopes:Write")]
        //[Authorize]
        public async Task<IActionResult> UpdateUserEmpresa(int id, [FromBody] EmpresaDto dto)
        {
            await _service.UpdateUserEmpresaAsync(id, dto);
            return NoContent();
        }

        [HttpDelete("{id}")]
        //[RequiredScope(RequiredScopesConfigurationKey = "AzureAdB2C:Scopes:Write")]
        //[Authorize]
        public async Task<IActionResult> DeleteEmpresa(int id)
        {
            await _service.DeleteEmpresaAsync(id);
            return NoContent();
        }
    }

}
