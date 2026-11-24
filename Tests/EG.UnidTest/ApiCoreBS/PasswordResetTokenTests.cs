using System.ComponentModel.DataAnnotations;
using System.Text.Json;
using EG.ApiCoreBS.Services;
using EG.Domain.DTOs.Requests;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.DataProtection;

namespace EG.UnidTest.ApiCoreBS;

public sealed class PasswordResetTokenTests
{
    private static readonly PasswordResetAccount Account = new("account-id", "test@example.com", "stamp", "version");

    [Fact]
    public void ProtectedTokenPreservesAccountState()
    {
        var service = new PasswordResetTokenService(new EphemeralDataProtectionProvider());
        var token = service.Create(Account);

        Assert.Equal(Account, service.Read(token));
        Assert.DoesNotContain(Account.Email, token);
    }

    [Fact]
    public void TokenCannotBeReadWithDifferentKeys()
    {
        var issuer = new PasswordResetTokenService(new EphemeralDataProtectionProvider());
        var other = new PasswordResetTokenService(new EphemeralDataProtectionProvider());

        Assert.Null(other.Read(issuer.Create(Account)));
    }

    [Fact]
    public void ExpiredTokenIsRejected()
    {
        var provider = new EphemeralDataProtectionProvider();
        var protector = provider.CreateProtector("EGestion360.PasswordReset.v1").ToTimeLimitedDataProtector();
        var token = protector.Protect(JsonSerializer.Serialize(Account), DateTimeOffset.UtcNow.AddMinutes(-1));

        Assert.Null(new PasswordResetTokenService(provider).Read(token));
    }

    [Fact]
    public void ModifiedTokenIsRejected()
    {
        var service = new PasswordResetTokenService(new EphemeralDataProtectionProvider());
        var token = service.Create(Account);
        var modified = token[..20] + (token[20] == 'A' ? "B" : "A") + token[21..];

        Assert.Null(service.Read(modified));
    }

    [Theory]
    [InlineData("")]
    [InlineData("invalid-token")]
    public void MalformedTokenIsRejected(string token)
    {
        var service = new PasswordResetTokenService(new EphemeralDataProtectionProvider());
        Assert.Null(service.Read(token));
    }

    [Theory]
    [InlineData("12345", "12345", false)]
    [InlineData("123456", "123456", true)]
    [InlineData("123456", "different", false)]
    [InlineData("      ", "      ", false)]
    public void ResetContractValidatesPasswordAndConfirmation(string password, string confirmation, bool valid)
    {
        var request = new ResetPasswordRequest
        {
            Token = "protected-token",
            NewPassword = password,
            ConfirmPassword = confirmation
        };
        Assert.Equal(valid, Validator.TryValidateObject(request, new ValidationContext(request), [], true));
    }
}
