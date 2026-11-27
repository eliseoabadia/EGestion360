using System.Security.Claims;
using EG.ApiCoreBS.Auth;
using EG.Business.Interfaces;
using EG.Domain.DTOs.Requests;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging.Abstractions;

namespace EG.UnidTest.ApiCoreBS;

public sealed class PermissionHandlerRegressionTests
{
    [Theory]
    [InlineData(false)]
    [InlineData(true)]
    public async Task ModuleAndActionMustBelongToTheSameStoredPermission(bool matching)
    {
        var permissions = new List<spGetClaimsByUserResult>
        {
            new() { Group = "Presupuesto_Modificado", SubGroup = "Reducciones", Values = "view" },
            new() { Group = "Presupuesto_Modificado", SubGroup = "Ampliaciones", Values = "authorize" }
        };
        if (matching)
            permissions.Add(new() { Group = "Presupuesto_Modificado", SubGroup = "Reducciones", Values = "view,authorize" });
        using var cache = new MemoryCache(new MemoryCacheOptions());
        var handler = new PermissionAuthorizationHandler(new Auth(permissions), cache, NullLogger<PermissionAuthorizationHandler>.Instance);
        var requirement = new PermissionRequirement("Presupuesto_Modificado", "Reducciones", "authorize");
        var user = new ClaimsPrincipal(new ClaimsIdentity([
            new Claim(ClaimTypes.NameIdentifier, "7"),
            new Claim("permissions", "Presupuesto_Modificado|Reducciones|authorize")
        ], "test"));
        var context = new AuthorizationHandlerContext([requirement], user, null);

        await handler.HandleAsync(context);

        Assert.Equal(matching, context.HasSucceeded);
    }

    private sealed class Auth(List<spGetClaimsByUserResult> permissions) : IAuthService
    {
        public Task<List<spGetClaimsByUserResult>> ObtenerClaimsUsuarioAsync(int userId) => Task.FromResult(permissions);
        public Task<LoginInformationEmployeeResult> ValidarCredencialesAsync(LoginRequestDto request) => throw new NotSupportedException();
    }

    [Theory]
    [InlineData("-7")]
    [InlineData("0")]
    [InlineData("user-7")]
    public async Task MalformedIdentityCannotUseStoredPermissions(string id)
    {
        using var cache = new MemoryCache(new MemoryCacheOptions());
        var handler = new PermissionAuthorizationHandler(new Auth([
            new() { Group = "Sistema", SubGroup = "Menu", Values = "delete" }
        ]), cache, NullLogger<PermissionAuthorizationHandler>.Instance);
        var requirement = new PermissionRequirement("Sistema", "Menu", "delete");
        var context = new AuthorizationHandlerContext([requirement],
            new ClaimsPrincipal(new ClaimsIdentity([new(ClaimTypes.NameIdentifier, id)], "test")), null);
        await handler.HandleAsync(context);
        Assert.False(context.HasSucceeded);
    }

    [Fact]
    public async Task AuthenticatedSuperAdminRetainsPermissionExemption()
    {
        using var cache = new MemoryCache(new MemoryCacheOptions());
        var handler = new PermissionAuthorizationHandler(new Auth([]), cache, NullLogger<PermissionAuthorizationHandler>.Instance);
        var requirement = new PermissionRequirement("Sistema", "Menu", "delete");
        var context = new AuthorizationHandlerContext([requirement], new ClaimsPrincipal(new ClaimsIdentity([
            new(ClaimTypes.NameIdentifier, "1"), new(ClaimTypes.Role, EG.Common.Security.SystemRoles.SuperAdmin)
        ], "test")), null);
        await handler.HandleAsync(context);
        Assert.True(context.HasSucceeded);
    }
}
