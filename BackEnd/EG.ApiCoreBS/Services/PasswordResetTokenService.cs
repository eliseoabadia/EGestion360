using System.Security.Cryptography;
using System.Text.Json;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.DataProtection;

namespace EG.ApiCoreBS.Services;

public sealed class PasswordResetTokenService(IDataProtectionProvider provider) : IPasswordResetTokenService
{
    private readonly ITimeLimitedDataProtector _protector = provider
        .CreateProtector("EGestion360.PasswordReset.v1").ToTimeLimitedDataProtector();

    public string Create(PasswordResetAccount account) =>
        _protector.Protect(JsonSerializer.Serialize(account), TimeSpan.FromMinutes(30));

    public PasswordResetAccount? Read(string token)
    {
        try
        {
            return JsonSerializer.Deserialize<PasswordResetAccount>(_protector.Unprotect(token));
        }
        catch (Exception exception) when (exception is CryptographicException or JsonException or FormatException or ArgumentException)
        {
            return null;
        }
    }
}
