using EG.Dommain.DTOs.Responses;

namespace EG.Application.Services.General;

public static class MenuTreeBuilder
{
    public static IList<MenuItemsResponse> Build(IEnumerable<MenuItemsResponse> source)
    {
        var menus = source.OrderBy(menu => menu.Orden).ThenBy(menu => menu.Nombre).ToList();
        var byId = menus.ToDictionary(menu => menu.PkidMenu);
        foreach (var menu in menus)
        {
            menu.Children = [];
            var visited = new HashSet<int> { menu.PkidMenu };
            var parentId = menu.FkidMenuSis;
            while (parentId.HasValue && byId.TryGetValue(parentId.Value, out var parent))
            {
                if (!visited.Add(parentId.Value))
                    throw new InvalidOperationException("La estructura del menú contiene una dependencia circular.");
                parentId = parent.FkidMenuSis;
            }
        }
        foreach (var menu in menus)
        {
            if (menu.FkidMenuSis.HasValue && byId.TryGetValue(menu.FkidMenuSis.Value, out var parent))
                parent.Children.Add(menu);
        }
        return menus.Where(menu => !menu.FkidMenuSis.HasValue || !byId.ContainsKey(menu.FkidMenuSis.Value)).ToList();
    }
}
