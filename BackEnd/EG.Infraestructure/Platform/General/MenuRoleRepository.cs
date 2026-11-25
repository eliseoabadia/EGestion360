using System.Data;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Infrastructure;

public sealed class MenuRoleRepository(EGestionContext context) : IMenuRoleRepository
{
    public async Task<IReadOnlyList<MenuRoleDto>> GetAllAsync(int? menuId = null) =>
        await context.MenuRoles.AsNoTracking().Where(item => item.Activo && (!menuId.HasValue || item.FkidMenuSis == menuId))
            .OrderBy(item => item.FkidMenuSis).ThenBy(item => item.RoleId)
            .Select(item => new MenuRoleDto { FkidMenuSis = item.FkidMenuSis, RoleId = item.RoleId, Activo = item.Activo }).ToListAsync();

    public Task<MenuRoleDto?> GetByKeyAsync(int menuId, string roleId) => context.MenuRoles.AsNoTracking()
        .Where(item => item.Activo && item.FkidMenuSis == menuId && item.RoleId == roleId)
        .Select(item => new MenuRoleDto { FkidMenuSis = item.FkidMenuSis, RoleId = item.RoleId, Activo = item.Activo })
        .SingleOrDefaultAsync();

    public Task SaveAsync(MenuRoleDto dto, bool create, int userId) => context.ExecuteResilientTransactionAsync(async token =>
    {
        if (dto.FkidMenuSis <= 0 || string.IsNullOrWhiteSpace(dto.RoleId) || dto.RoleId.Length > 128)
            throw new InvalidOperationException("Selecciona un menú y un rol válidos.");
        if (!await context.Menus.AnyAsync(menu => menu.PkidMenu == dto.FkidMenuSis && menu.Activo, token) ||
            !await context.AspNetRoles.AnyAsync(role => role.Id == dto.RoleId, token))
            throw new InvalidOperationException("El menú o el rol seleccionado no existe o no está disponible.");
        var existing = await context.MenuRoles.SingleOrDefaultAsync(item => item.FkidMenuSis == dto.FkidMenuSis && item.RoleId == dto.RoleId, token);
        if (create && existing is { Activo: true })
            throw new InvalidOperationException("El menú ya está asignado a ese rol.");
        if (!create && existing == null)
            throw new KeyNotFoundException("La asignación de menú y rol no existe.");
        if (existing == null)
        {
            existing = new MenuRole
            {
                FkidMenuSis = dto.FkidMenuSis,
                RoleId = dto.RoleId,
                CreatedByOperatorId = userId,
                CreatedDateTime = DateTime.Now
            };
            context.MenuRoles.Add(existing);
        }
        else
        {
            existing.ModifiedByOperatorId = userId;
            existing.ModifiedDateTime = DateTime.Now;
        }
        existing.Activo = dto.Activo;
        await context.SaveChangesAsync(token);
    }, IsolationLevel.Serializable);

    public Task DeleteAsync(int menuId, string? roleId, int userId) => context.ExecuteResilientTransactionAsync(async token =>
    {
        var matches = await context.MenuRoles.Where(item => item.Activo && item.FkidMenuSis == menuId &&
            (roleId == null || item.RoleId == roleId)).Take(2).ToListAsync(token);
        if (matches.Count == 0)
            throw new KeyNotFoundException("La asignación de menú y rol no existe.");
        if (matches.Count > 1)
            throw new InvalidOperationException("El menú tiene varios roles. Indica también el identificador del rol.");
        var existing = matches[0];
        existing.Activo = false;
        existing.ModifiedByOperatorId = userId;
        existing.ModifiedDateTime = DateTime.Now;
        await context.SaveChangesAsync(token);
    }, IsolationLevel.Serializable);
}
