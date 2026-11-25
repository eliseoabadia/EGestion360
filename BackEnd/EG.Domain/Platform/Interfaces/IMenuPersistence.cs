using EG.Domain.DTOs.Requests.General;
using EG.Dommain.DTOs.Responses;

namespace EG.Domain.Interfaces;

public interface IMenuPersistence
{
    Task ValidateAsync(MenuItemsDto dto, int? id = null);
    Task<MenuItemsResponse> SaveAsync(MenuItemsDto dto, int? id, int userId);
    Task DeleteAsync(int id, int userId);
    Task ReorderAsync(IReadOnlyCollection<MenuOrderDto> menus, int userId);
}
