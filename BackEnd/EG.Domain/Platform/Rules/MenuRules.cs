using EG.Domain.DTOs.Requests.General;

namespace EG.Domain.Rules;

public static class MenuRules
{
    public static void Validate(MenuItemsDto dto, IReadOnlyCollection<MenuItemsDto> activeMenus, int? id)
    {
        if (string.IsNullOrWhiteSpace(dto.Nombre) || dto.Nombre.Trim().Length < 2)
            throw new InvalidOperationException("El nombre del menú debe tener al menos dos caracteres.");
        if (dto.Tipo is not (1 or 2))
            throw new InvalidOperationException("Selecciona un tipo de menú válido.");
        if (dto.Tipo == 2 && string.IsNullOrWhiteSpace(dto.Ruta))
            throw new InvalidOperationException("Los elementos del menú requieren una ruta.");
        if (dto.Nombre.Trim().Length > 150 || dto.Ruta?.Length > 200 || dto.ImageUrl?.Length > 120)
            throw new InvalidOperationException("El nombre, la ruta o la imagen del menú exceden su longitud permitida.");
        if (dto.Orden is < 0)
            throw new InvalidOperationException("El orden del menú no puede ser negativo.");
        if (activeMenus.Any(menu => menu.PkidMenu != id && menu.FkidMenuSis == dto.FkidMenuSis &&
            string.Equals(menu.Nombre.Trim(), dto.Nombre.Trim(), StringComparison.OrdinalIgnoreCase)))
            throw new InvalidOperationException("Ya existe otro menú activo con ese nombre en el mismo nivel.");

        var byId = activeMenus.ToDictionary(menu => menu.PkidMenu);
        var visited = new HashSet<int>();
        var parentId = dto.FkidMenuSis;
        while (parentId.HasValue)
        {
            if (parentId == id || !visited.Add(parentId.Value))
                throw new InvalidOperationException("El menú no puede depender de sí mismo ni de uno de sus descendientes.");
            if (!byId.TryGetValue(parentId.Value, out var parent))
                throw new InvalidOperationException("El menú padre no existe o está inactivo.");
            parentId = parent.FkidMenuSis;
        }

        if (id.HasValue && activeMenus.Any(menu => menu.FkidMenuSis == id) && (!dto.Activo || dto.Tipo != 1))
            throw new InvalidOperationException("Un menú con hijos activos debe permanecer activo y ser contenedor.");
    }

    public static void ValidateOrder(IReadOnlyCollection<MenuOrderDto> changes, IReadOnlyCollection<int> activeIds)
    {
        if (changes.Count == 0 || changes.Any(menu => menu.PkidMenu <= 0 || !menu.Orden.HasValue || menu.Orden < 0))
            throw new InvalidOperationException("Indica menús y posiciones válidos para reordenar.");
        if (changes.Select(menu => menu.PkidMenu).Distinct().Count() != changes.Count)
            throw new InvalidOperationException("No se puede reordenar el mismo menú más de una vez.");
        var existing = activeIds.ToHashSet();
        if (changes.Any(menu => !existing.Contains(menu.PkidMenu)))
            throw new KeyNotFoundException("Uno de los menús no existe o está inactivo.");
    }
}
