using EG.Domain.DTOs.Requests.General;

namespace EG.Domain.Interfaces;

public interface IMenuRoleRepository
{
    Task<IReadOnlyList<MenuRoleDto>> GetAllAsync(int? menuId = null);
    Task<MenuRoleDto?> GetByKeyAsync(int menuId, string roleId);
    Task SaveAsync(MenuRoleDto dto, bool create, int userId);
    Task DeleteAsync(int menuId, string? roleId, int userId);
}
