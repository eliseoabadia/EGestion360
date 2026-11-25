using EG.Application.Interfaces.General;
using EG.Domain.DTOs.Requests.General;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.General;

[Route("api/[controller]")]
[ApiController]
[Authorize(Policy = "Sistema|Configurar_Accesos|view")]
public sealed class MenuRoleController(IMenuRoleAppService service) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IEnumerable<MenuRoleDto>>> GetAll() => Ok(await service.GetAllAsync());

    [HttpGet("{id:int}")]
    public async Task<ActionResult<MenuRoleDto>> GetById(int id) => await GetByKey(id, null);

    [HttpGet("{id:int}/roles/{roleId}")]
    public async Task<ActionResult<MenuRoleDto>> GetByKey(int id, string? roleId)
    {
        var result = await service.GetAsync(id, roleId);
        return result == null ? NotFound() : Ok(result);
    }

    [HttpPost]
    [Authorize(Policy = "Sistema|Configurar_Accesos|update")]
    public async Task<ActionResult> Add([FromBody] MenuRoleDto dto)
    {
        await service.SaveAsync(dto, create: true);
        return CreatedAtAction(nameof(GetByKey), new { id = dto.FkidMenuSis, roleId = dto.RoleId }, dto);
    }

    [HttpPut("{id:int}")]
    [Authorize(Policy = "Sistema|Configurar_Accesos|update")]
    public async Task<ActionResult> Update(int id, [FromBody] MenuRoleDto dto)
    {
        if (id != dto.FkidMenuSis)
            return BadRequest(new { success = false, message = "El menú de la ruta no coincide con la asignación.", code = "INVALID_MENU" });
        await service.SaveAsync(dto, create: false);
        return NoContent();
    }

    [HttpDelete("{id:int}")]
    [Authorize(Policy = "Sistema|Configurar_Accesos|update")]
    public async Task<ActionResult> Delete(int id) => await DeleteByKey(id, null);

    [HttpDelete("{id:int}/roles/{roleId}")]
    [Authorize(Policy = "Sistema|Configurar_Accesos|update")]
    public async Task<ActionResult> DeleteByKey(int id, string? roleId)
    {
        await service.DeleteAsync(id, roleId);
        return NoContent();
    }
}
