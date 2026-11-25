using EG.Application.Interfaces.General;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.Interfaces;
using EG.Dommain.DTOs.Responses;
using EG.Infraestructure.Models;

namespace EG.Application.Services.General;

public sealed class MenuAppService(
    GenericService<VwMenu, MenuItemsDto, MenuItemsResponse> queries,
    IMenuPersistence persistence,
    IUserContextService userContext) : IMenuAppService
{
    public async Task<PagedResult<MenuItemsResponse>> GetAllAsync()
    {
        var roots = MenuTreeBuilder.Build(await queries.GetAllAsync());
        return new() { Success = true, Code = "SUCCESS", Items = roots, TotalCount = roots.Count };
    }

    public async Task<PagedResult<MenuItemsResponse>> GetByIdAsync(int id)
    {
        var menu = await queries.GetByIdAsync(id, idPropertyName: nameof(VwMenu.PkidMenu));
        return menu == null
            ? new() { Success = false, Code = "NOTFOUND_MENU", Message = "Menú no encontrado." }
            : new() { Success = true, Code = "SUCCESS", Data = menu, Items = [menu], TotalCount = 1 };
    }

    public Task<PagedResult<MenuItemsResponse>> GetAllPaginadoAsync(PagedRequest request) => queries.GetAllPaginadoAsync(request);

    public async Task<PagedResult<MenuItemsResponse>> ExportAsync(PagedRequest request)
    {
        var items = await queries.GetAllForExportAsync(request);
        return new() { Success = true, Code = "SUCCESS", Items = items, TotalCount = items.Count };
    }

    public async Task<PagedResult<MenuItemsResponse>> GetTreePageAsync(PagedRequest request)
    {
        var page = await queries.GetAllPaginadoAsync(request, menu => !menu.FkidMenuSis.HasValue);
        if (!page.Success || page.Items.Count == 0)
            return page;
        // Count and page roots before attaching descendants.
        var roots = MenuTreeBuilder.Build(await queries.GetAllAsync()).ToDictionary(menu => menu.PkidMenu);
        page.Items = page.Items.Select(menu => roots.GetValueOrDefault(menu.PkidMenu, menu)).ToList();
        return page;
    }

    public async Task<PagedResult<MenuItemsResponse>> SaveAsync(MenuItemsDto dto, int? id = null)
    {
        if (!id.HasValue)
            dto.Tipo = 2;
        var saved = await persistence.SaveAsync(dto, id, userContext.GetCurrentUserId());
        return new()
        {
            Success = true,
            Code = "SUCCESS",
            Data = saved,
            Items = [saved],
            TotalCount = 1,
            Message = id.HasValue ? "Menú actualizado correctamente." : "Menú creado correctamente."
        };
    }

    public async Task<PagedResult<MenuItemsResponse>> DeleteAsync(int id)
    {
        await persistence.DeleteAsync(id, userContext.GetCurrentUserId());
        return new() { Success = true, Code = "SUCCESS", Message = "Menú eliminado correctamente." };
    }

    public async Task<PagedResult<MenuItemsResponse>> ValidateAsync(MenuItemsDto dto)
    {
        try
        {
            if (dto.PkidMenu == 0)
                dto.Tipo = 2;
            await persistence.ValidateAsync(dto, dto.PkidMenu > 0 ? dto.PkidMenu : null);
            return new() { Success = true, Code = "SUCCESS", Message = "El menú es válido." };
        }
        catch (InvalidOperationException)
        {
            return new() { Success = false, Code = "DUPLICATE_OR_INVALID_MENU", Message = "Revisa el nombre, la ruta y la estructura del menú." };
        }
    }

    public async Task<PagedResult<MenuItemsResponse>> ReorderAsync(IReadOnlyCollection<MenuOrderDto> menus)
    {
        await persistence.ReorderAsync(menus, userContext.GetCurrentUserId());
        return new() { Success = true, Code = "SUCCESS", Message = "Menús reordenados correctamente.", TotalCount = menus.Count };
    }
}
