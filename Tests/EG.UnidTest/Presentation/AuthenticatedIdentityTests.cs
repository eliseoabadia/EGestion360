using EG.Web.Services;
using Microsoft.AspNetCore.Components.Authorization;
using System.Security.Claims;

namespace EG.UnidTest.Presentation;

public sealed class AuthenticatedIdentityTests
{
    [Theory]
    [InlineData("42", 42)]
    [InlineData("user-42", 0)]
    [InlineData("-42", 0)]
    [InlineData("0", 0)]
    [InlineData("2147483648", 0)]
    [InlineData("9223372036854775807", 0)]
    [InlineData("", 0)]
    public async Task IdentityMustBeCompletePositiveInteger(string value, int expected)
    {
        var service = new AuthService(new Provider(new ClaimsIdentity([new(ClaimTypes.NameIdentifier, value)], "test")));
        Assert.Equal(expected, await service.GetUserIdAsync());
    }

    [Fact]
    public async Task AnonymousClaimsCannotSupplyAnIdentity()
    {
        var service = new AuthService(new Provider(new ClaimsIdentity([new(ClaimTypes.NameIdentifier, "42")])));
        Assert.Equal(0, await service.GetUserIdAsync());
    }

    [Fact]
    public async Task InvalidCanonicalIdentifierDoesNotFallBackToAnotherClaim()
    {
        var service = new AuthService(new Provider(new ClaimsIdentity([
            new(ClaimTypes.NameIdentifier, "invalid"), new("sub", "42")
        ], "test")));
        Assert.Equal(0, await service.GetUserIdAsync());
    }

    [Theory]
    [InlineData("sub")]
    [InlineData("UserId")]
    [InlineData("PkIdUsuario")]
    public async Task SupportedLegacyClaimNamesRemainCompatible(string key)
    {
        var service = new AuthService(new Provider(new ClaimsIdentity([new(key, "42")], "test")));
        Assert.Equal(42, await service.GetUserIdAsync());
    }

    private sealed class Provider(ClaimsIdentity identity) : AuthenticationStateProvider
    {
        public override Task<AuthenticationState> GetAuthenticationStateAsync() =>
            Task.FromResult(new AuthenticationState(new ClaimsPrincipal(identity)));
    }
}
