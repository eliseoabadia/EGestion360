using EG.Application.Services.General;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.Interfaces;
using EG.UnidTest.Support;

namespace EG.UnidTest.Application;

public sealed class MenuRoleAppServiceTests
{
    [Fact]
    public async Task LegacySingleIdCannotChooseAnArbitraryRole()
    {
        var repository = new Roles();
        var service = new MenuRoleAppService(repository, new FixedUserContext(7, 3));
        await Assert.ThrowsAsync<InvalidOperationException>(() => service.GetAsync(1));
        Assert.Equal(0, repository.Writes);
    }

    [Fact]
    public async Task CompositeKeySelectsOnlyTheRequestedRole()
    {
        var service = new MenuRoleAppService(new Roles(), new FixedUserContext(7, 3));
        var role = await service.GetAsync(1, "role-b");
        Assert.Equal("role-b", role!.RoleId);
        Assert.Equal(1, role.FkidMenuSis);
    }

    [Fact]
    public async Task DeleteForwardsExactCompositeKeyAndServerIdentity()
    {
        var repository = new Roles();
        var service = new MenuRoleAppService(repository, new FixedUserContext(7, 3));
        await service.DeleteAsync(1, "role-b");
        Assert.Equal((1, "role-b", 7), repository.Deleted);
    }

    private sealed class Roles : IMenuRoleRepository
    {
        private readonly MenuRoleDto[] _roles =
        [
            new() { FkidMenuSis = 1, RoleId = "role-a", Activo = true },
            new() { FkidMenuSis = 1, RoleId = "role-b", Activo = true }
        ];
        public int Writes { get; private set; }
        public (int, string?, int)? Deleted { get; private set; }
        public Task<IReadOnlyList<MenuRoleDto>> GetAllAsync(int? menuId = null) => Task.FromResult<IReadOnlyList<MenuRoleDto>>(_roles);
        public Task<MenuRoleDto?> GetByKeyAsync(int menuId, string roleId) => Task.FromResult(_roles.SingleOrDefault(role => role.FkidMenuSis == menuId && role.RoleId == roleId));
        public Task SaveAsync(MenuRoleDto dto, bool create, int userId)
        {
            Writes++;
            return Task.CompletedTask;
        }
        public Task DeleteAsync(int menuId, string? roleId, int userId)
        {
            Writes++;
            Deleted = (menuId, roleId, userId);
            return Task.CompletedTask;
        }
    }
}
