using System.Security.Cryptography;
using System.Text.Json;
using Microsoft.AspNetCore.DataProtection;

namespace EG.ApiCoreBS.Services.Licensing;

public sealed class LicenseMachineStateProtector
{
    private readonly IDataProtector _protector;

    public LicenseMachineStateProtector(IDataProtectionProvider provider)
    {
        _protector = provider.CreateProtector("GE360.Licensing.InstallationState.v1");
    }

    internal ProtectedLicenseState Create()
    {
        var secret = RandomNumberGenerator.GetBytes(32);
        return new ProtectedLicenseState(
            Guid.NewGuid(),
            Convert.ToBase64String(secret),
            0,
            DateTimeOffset.UtcNow);
    }

    internal string Protect(ProtectedLicenseState state) =>
        _protector.Protect(JsonSerializer.Serialize(state));

    internal bool TryUnprotect(string? protectedValue, out ProtectedLicenseState state)
    {
        state = default!;
        if (string.IsNullOrWhiteSpace(protectedValue))
            return false;

        try
        {
            var json = _protector.Unprotect(protectedValue);
            var parsed = JsonSerializer.Deserialize<ProtectedLicenseState>(json);
            if (parsed is null || parsed.InstallationId == Guid.Empty || parsed.Serial < 0)
                return false;

            var secret = Convert.FromBase64String(parsed.Secret);
            if (secret.Length != 32)
                return false;

            state = parsed;
            return true;
        }
        catch (CryptographicException)
        {
            return false;
        }
        catch (FormatException)
        {
            return false;
        }
        catch (JsonException)
        {
            return false;
        }
    }

    internal static string GetFingerprint(ProtectedLicenseState state)
    {
        var secret = Convert.FromBase64String(state.Secret);
        return Convert.ToHexString(SHA256.HashData(secret));
    }
}

internal sealed record ProtectedLicenseState(
    Guid InstallationId,
    string Secret,
    long Serial,
    DateTimeOffset LastObservedUtc);
