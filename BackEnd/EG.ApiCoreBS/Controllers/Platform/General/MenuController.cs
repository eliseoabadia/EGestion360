using EG.Common.Modules;
using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses;
using EG.Dommain.DTOs.Responses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.General;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public sealed class MenuController(IMenuAppService service) : ControllerBase
{
    [HttpGet]
    [Authorize(Policy = MenuModule.ViewPolicy)]
    public async Task<ActionResult<PagedResult<MenuItemsResponse>>> GetAll() => Ok(await service.GetAllAsync());

    [HttpGet("{id:int}")]
    [Authorize(Policy = MenuModule.ViewPolicy)]
    public async Task<ActionResult<PagedResult<MenuItemsResponse>>> GetById(int id)
    {
        var result = await service.GetByIdAsync(id);
        return result.Success ? Ok(result) : NotFound(result);
    }

    [HttpPost]
    [Authorize(Policy = MenuModule.CreatePolicy)]
    public async Task<ActionResult<PagedResult<MenuItemsResponse>>> Add([FromBody] MenuItemsDto dto)
    {
        var result = await service.SaveAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = result.Data?.PkidMenu }, result);
    }

    [HttpPut("{id:int}")]
    [Authorize(Policy = MenuModule.UpdatePolicy)]
    public async Task<ActionResult<PagedResult<MenuItemsResponse>>> Update(int id, [FromBody] MenuItemsDto dto) =>
        Ok(await service.SaveAsync(dto, id));

    [HttpDelete("{id:int}")]
    [Authorize(Policy = MenuModule.DeletePolicy)]
    public async Task<ActionResult<PagedResult<MenuItemsResponse>>> Delete(int id) => Ok(await service.DeleteAsync(id));

    [HttpPost("GetAllMenusPaginado")]
    [Authorize(Policy = MenuModule.ViewPolicy)]
    public async Task<ActionResult<PagedResult<MenuItemsResponse>>> GetAllMenusPaginado([FromBody] PagedRequest request) =>
        Ok(await service.GetTreePageAsync(request));

    [HttpPost("GetAllPaginado")]
    [Authorize(Policy = MenuModule.ViewPolicy)]
    public async Task<ActionResult<PagedResult<MenuItemsResponse>>> GetAllPaginado([FromBody] PagedRequest request) =>
        Ok(await service.GetAllPaginadoAsync(request));

    [HttpPost("buscar")]
    [Authorize(Policy = MenuModule.ViewPolicy)]
    public async Task<ActionResult<PagedResult<MenuItemsResponse>>> BuscarMenus([FromBody] BusquedaRequest request) =>
        Ok(await service.GetAllPaginadoAsync(new PagedRequest
        {
            Page = request.Page,
            PageSize = request.PageSize,
            Filtro = request.TerminoBusqueda,
            SortLabel = request.SortLabel,
            SortDirection = request.SortDirection
        }));

    [HttpPost("validar")]
    [Authorize(Policy = MenuModule.ViewPolicy)]
    public async Task<ActionResult<PagedResult<MenuItemsResponse>>> ValidarMenu([FromBody] MenuItemsDto dto) =>
        Ok(await service.ValidateAsync(dto));

    [HttpPost("reordenar")]
    [Authorize(Policy = MenuModule.UpdatePolicy)]
    public async Task<ActionResult<PagedResult<MenuItemsResponse>>> ReordenarMenus([FromBody] List<MenuOrderDto> menus) =>
        Ok(await service.ReorderAsync(menus));

    [HttpPost(MenuModule.ExportAction)]
    [Authorize(Policy = MenuModule.ExportPolicy)]
    public async Task<ActionResult<PagedResult<MenuItemsResponse>>> Export([FromBody] PagedRequest request) =>
        Ok(await service.ExportAsync(request));
}
