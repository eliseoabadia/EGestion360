using EG.Application.Interfaces.General;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.Interfaces;

namespace EG.Application.Services.General;

public sealed class MenuRoleAppService(IMenuRoleRepository repository, IUserContextService userContext) : IMenuRoleAppService
{
    public Task<IReadOnlyList<MenuRoleDto>> GetAllAsync() => repository.GetAllAsync();

    public async Task<MenuRoleDto?> GetAsync(int menuId, string? roleId = null)
    {
        if (roleId != null)
            return await repository.GetByKeyAsync(menuId, roleId);
        var matches = await repository.GetAllAsync(menuId);
        if (matches.Count > 1)
            throw new InvalidOperationException("El menú tiene varios roles. Indica también el identificador del rol.");
        return matches.SingleOrDefault();
    }

    public Task SaveAsync(MenuRoleDto dto, bool create) => repository.SaveAsync(dto, create, userContext.GetCurrentUserId());
    public Task DeleteAsync(int menuId, string? roleId = null) => repository.DeleteAsync(menuId, roleId, userContext.GetCurrentUserId());
}
