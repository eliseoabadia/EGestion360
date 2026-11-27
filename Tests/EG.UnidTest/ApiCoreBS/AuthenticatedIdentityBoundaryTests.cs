using System.Security.Claims;
using EG.Common.Security;

namespace EG.UnidTest.ApiCoreBS;

public sealed class AuthenticatedIdentityBoundaryTests
{
    [Theory]
    [InlineData("42", 42)]
    [InlineData("user-42", null)]
    [InlineData("-42", null)]
    [InlineData("0", null)]
    [InlineData("+42", null)]
    [InlineData(" 42", null)]
    [InlineData("2147483648", null)]
    public void IdentityRequiresCompletePositiveInteger(string value, int? expected) =>
        Assert.Equal(expected, AuthenticatedIdentity.GetUserId(Principal(new Claim(ClaimTypes.NameIdentifier, value))));

    [Theory]
    [InlineData("invalid")]
    [InlineData("43")]
    public void ConflictingOrMalformedIdentityCannotUseAnotherClaim(string canonical) =>
        Assert.Null(AuthenticatedIdentity.GetUserId(Principal(new(ClaimTypes.NameIdentifier, canonical), new("sub", "42"))));

    [Fact]
    public void AnonymousIdentityIsRejected() => Assert.Null(AuthenticatedIdentity.GetUserId(
        new ClaimsPrincipal(new ClaimsIdentity([new(ClaimTypes.NameIdentifier, "42")]))));

    [Fact]
    public void MatchingTokenAliasesAreAccepted() => Assert.Equal(42, AuthenticatedIdentity.GetUserId(
        Principal(new(ClaimTypes.NameIdentifier, "42"), new("sub", "42"))));

    private static ClaimsPrincipal Principal(params Claim[] claims) => new(new ClaimsIdentity(claims, "test"));
}
