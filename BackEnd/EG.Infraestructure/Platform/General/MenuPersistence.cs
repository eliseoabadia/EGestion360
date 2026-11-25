using System.Data;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.Interfaces;
using EG.Domain.Rules;
using EG.Dommain.DTOs.Responses;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Infrastructure;

public sealed class MenuPersistence(EGestionContext context) : IMenuPersistence
{
    private Task<List<MenuItemsDto>> GetActiveMenusAsync() => context.Menus.AsNoTracking()
        .Where(menu => menu.Activo)
        .Select(menu => new MenuItemsDto
        {
            PkidMenu = menu.PkidMenu, Nombre = menu.Nombre, Tipo = menu.Tipo,
            FkidMenuSis = menu.FkidMenuSis, Activo = menu.Activo
        }).ToListAsync();

    public async Task ValidateAsync(MenuItemsDto dto, int? id = null) =>
        MenuRules.Validate(dto, await GetActiveMenusAsync(), id);

    public Task<MenuItemsResponse> SaveAsync(MenuItemsDto dto, int? id, int userId) => context.ExecuteResilientTransactionAsync(async token =>
    {
        // Read and validate the entire hierarchy before changing any tracked record.
        await ValidateAsync(dto, id);
        var menu = id.HasValue
            ? await context.Menus.SingleOrDefaultAsync(item => item.PkidMenu == id && item.Activo, token)
                ?? throw new KeyNotFoundException("El menú no existe.")
            : new Menu { CreatedByOperatorId = userId, CreatedDateTime = DateTime.Now };
        var parent = dto.FkidMenuSis.HasValue
            ? await context.Menus.SingleAsync(item => item.PkidMenu == dto.FkidMenuSis && item.Activo, token)
            : null;

        menu.Nombre = dto.Nombre.Trim();
        menu.Tipo = dto.Tipo;
        menu.FkidMenuSis = dto.FkidMenuSis;
        menu.LegacyName = menu.Nombre[..Math.Min(menu.Nombre.Length, 80)];
        menu.Ruta = dto.Tipo == 1 ? "/" : dto.Ruta.Trim();
        menu.ImageUrl = dto.ImageUrl;
        menu.Lenguaje = "ESP";
        menu.Orden = dto.Orden;
        menu.Activo = dto.Activo;
        if (id.HasValue)
        {
            menu.ModifiedByOperatorId = userId;
            menu.ModifiedDateTime = DateTime.Now;
        }
        else
        {
            context.Menus.Add(menu);
        }
        if (parent is { Tipo: not 1 })
        {
            parent.Tipo = 1;
            parent.Ruta = "/";
            parent.ModifiedByOperatorId = userId;
            parent.ModifiedDateTime = DateTime.Now;
        }
        await context.SaveChangesAsync(token);
        return new MenuItemsResponse
        {
            PkidMenu = menu.PkidMenu,
            Nombre = menu.Nombre,
            Tipo = menu.Tipo,
            FkidMenuSis = menu.FkidMenuSis,
            NombreMenuPadre = parent?.Nombre,
            LegacyName = menu.LegacyName,
            Ruta = menu.Ruta,
            ImageUrl = menu.ImageUrl,
            Lenguaje = menu.Lenguaje,
            Orden = menu.Orden,
            Activo = menu.Activo,
            CreatedByOperatorId = menu.CreatedByOperatorId,
            CreatedDateTime = menu.CreatedDateTime,
            ModifiedByOperatorId = menu.ModifiedByOperatorId,
            ModifiedDateTime = menu.ModifiedDateTime
        };
    }, IsolationLevel.Serializable);

    public Task DeleteAsync(int id, int userId) => context.ExecuteResilientTransactionAsync(async token =>
    {
        var menu = await context.Menus.SingleOrDefaultAsync(item => item.PkidMenu == id && item.Activo, token)
            ?? throw new KeyNotFoundException("El menú no existe.");
        if (await context.Menus.AnyAsync(item => item.FkidMenuSis == id && item.Activo, token))
            throw new InvalidOperationException("No se puede eliminar un menú que tiene hijos activos.");
        menu.Activo = false;
        menu.ModifiedByOperatorId = userId;
        menu.ModifiedDateTime = DateTime.Now;
        await context.SaveChangesAsync(token);
    }, IsolationLevel.Serializable);

    public Task ReorderAsync(IReadOnlyCollection<MenuOrderDto> menus, int userId) => context.ExecuteResilientTransactionAsync(async token =>
    {
        var ids = menus.Select(menu => menu.PkidMenu).ToArray();
        var existing = await context.Menus.Where(menu => menu.Activo && ids.Contains(menu.PkidMenu)).ToListAsync(token);
        MenuRules.ValidateOrder(menus, existing.Select(menu => menu.PkidMenu).ToArray());
        var byId = existing.ToDictionary(menu => menu.PkidMenu);
        foreach (var change in menus)
        {
            var menu = byId[change.PkidMenu];
            menu.Orden = change.Orden;
            menu.ModifiedByOperatorId = userId;
            menu.ModifiedDateTime = DateTime.Now;
        }
        await context.SaveChangesAsync(token);
    }, IsolationLevel.Serializable);
}
