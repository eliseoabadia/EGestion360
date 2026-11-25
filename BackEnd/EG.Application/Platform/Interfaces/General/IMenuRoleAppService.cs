using EG.Domain.DTOs.Requests.General;

namespace EG.Application.Interfaces.General;

public interface IMenuRoleAppService
{
    Task<IReadOnlyList<MenuRoleDto>> GetAllAsync();
    Task<MenuRoleDto?> GetAsync(int menuId, string? roleId = null);
    Task SaveAsync(MenuRoleDto dto, bool create);
    Task DeleteAsync(int menuId, string? roleId = null);
}
