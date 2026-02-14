using EG.Business.Services;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.ProGeneralfile
{
    [Route("api/[controller]")]
    [ApiController]
    //[RequiredScope(RequiredScopesConfigurationKey = "AzureAdB2C:Scopes:Read")]
    [Authorize]
    public class MenuRoleController(GenericService<MenuRole, MenuRoleDto> service) : ControllerBase
    {
        private readonly GenericService<MenuRole, MenuRoleDto> _service = service;

        [HttpGet]
        public async Task<ActionResult<IEnumerable<MenuRoleDto>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<MenuRoleDto>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            return result == null ? NotFound() : Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult> Add(MenuRoleDto dto)
        {
            await _service.AddAsync(dto);
            return CreatedAtAction(nameof(GetById), dto);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult> Update(int id, MenuRoleDto dto)
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
    }
}