using System.Security.Claims;
using EG.ApiCoreBS.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging.Abstractions;

namespace EG.UnidTest.ApiCoreBS;

public sealed class UserContextServiceTests
{
    [Fact]
    public void TryGetCurrentUserId_Returns_UserId_From_NameIdentifierClaim()
    {
        var service = CreateService(
            new Claim(ClaimTypes.NameIdentifier, "42"),
            new Claim("empresaId", "7"));

        Assert.Equal(42, service.TryGetCurrentUserId());
        Assert.Equal(42, service.GetCurrentUserId());
    }

    [Fact]
    public void TryGetCurrentUserId_Extracts_NumericUserId_From_MixedClaimValue()
    {
        var service = CreateService(new Claim("UserId", "user-983-active"));

        Assert.Equal(983, service.TryGetCurrentUserId());
    }

    [Fact]
    public void TryGetCurrentEmpresaId_Returns_EmpresaId_From_SupportedClaimNames()
    {
        var service = CreateService(new Claim("Empresa", "21"));

        Assert.Equal(21, service.TryGetCurrentEmpresaId());
        Assert.Equal(21, service.GetCurrentEmpresaId());
    }

    [Fact]
    public void GetCurrentUserId_Throws_When_UserIsNotAuthenticated()
    {
        var accessor = new HttpContextAccessor
        {
            HttpContext = new DefaultHttpContext
            {
                User = new ClaimsPrincipal(new ClaimsIdentity())
            }
        };
        var service = new UserContextService(accessor, NullLogger<UserContextService>.Instance);

        Assert.Null(service.TryGetCurrentUserId());
        Assert.Throws<InvalidOperationException>(() => service.GetCurrentUserId());
    }

    private static UserContextService CreateService(params Claim[] claims)
    {
        var accessor = new HttpContextAccessor
        {
            HttpContext = new DefaultHttpContext
            {
                User = new ClaimsPrincipal(new ClaimsIdentity(claims, "UnitTest"))
            }
        };

        return new UserContextService(accessor, NullLogger<UserContextService>.Instance);
    }
}
