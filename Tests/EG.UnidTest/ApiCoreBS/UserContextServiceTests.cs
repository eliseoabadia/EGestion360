using System.Security.Claims;
using EG.ApiCoreBS.Services;
using EG.Application.Services.Security;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
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
    public void TryGetCurrentUserId_Rejects_MixedClaimValue()
    {
        var service = CreateService(new Claim("UserId", "user-983-active"));

        Assert.Null(service.TryGetCurrentUserId());
    }

    [Fact]
    public void TryGetCurrentEmpresaId_Returns_EmpresaId_From_SupportedClaimNames()
    {
        var service = CreateService(new Claim(ClaimTypes.NameIdentifier, "42"), new Claim("Empresa", "21"));

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
        var service = CreateService(accessor);

        Assert.Null(service.TryGetCurrentUserId());
        Assert.Throws<UnauthorizedAccessException>(() => service.GetCurrentUserId());
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

        return CreateService(accessor);
    }

    private static UserContextService CreateService(IHttpContextAccessor accessor)
    {
        return new UserContextService(new HttpUserRequestContext(accessor), NullLogger<UserContextService>.Instance, new Queries());
    }

    private sealed class Queries : EG.Domain.Interfaces.IUserContextQueries
    {
        public bool CanAccessEmpresa(int userId, int companyId) => userId == 42 && companyId == 21;
        public bool IsActiveAnio(int yearId) => true;
    }

    [Theory]
    [InlineData("fkidSucursal")]
    [InlineData("OtraEmpresa")]
    public void UnrelatedClaimsCannotSelectACompany(string claimType)
    {
        Assert.Null(CreateService(new Claim(ClaimTypes.NameIdentifier, "42"), new Claim(claimType, "21")).TryGetCurrentEmpresaId());
    }
}
