using EG.Contracts.Platform.Licensing;

namespace EG.Domain.Platform.Licensing;

public interface ILicensingService
{
    Task EnsureInitializedAsync(CancellationToken cancellationToken = default);
    Task<LicenseSnapshotResponse> GetSnapshotAsync(CancellationToken cancellationToken = default);
    Task<LicenseInstallationRequestResponse> GetInstallationRequestAsync(CancellationToken cancellationToken = default);
    Task<LicenseSnapshotResponse> ImportAsync(
        string signedLicense,
        int operatorUserId,
        CancellationToken cancellationToken = default);
    Task<LicenseSnapshotResponse> SetModuleStateAsync(
        string moduleCode,
        bool active,
        string? reason,
        int operatorUserId,
        CancellationToken cancellationToken = default);
    Task PersistTrustedClockAsync(CancellationToken cancellationToken = default);
}

public interface ILicenseRuntimeState
{
    void Replace(LicenseRuntimeSnapshot snapshot);
    LicenseDecision Evaluate(string moduleCode, DateTimeOffset? utcNow = null);
    LicenseSnapshotResponse GetSnapshot(DateTimeOffset? utcNow = null);
    LicenseRuntimeSnapshot GetRuntimeSnapshot();
}

public sealed record LicenseRuntimeSnapshot(
    Guid InstallationId,
    string InstallationFingerprint,
    Guid? LicenseId,
    long Serial,
    bool SignatureValid,
    DateTimeOffset LastObservedUtc,
    bool ClockSuspicious,
    IReadOnlyList<LicenseRuntimeGrant> Grants);

public sealed record LicenseRuntimeGrant(
    string ModuleCode,
    DateTimeOffset StartsAtUtc,
    DateTimeOffset? EndsAtUtc,
    bool ActiveLocally);

public sealed record LicenseDecision(
    bool Allowed,
    string ModuleCode,
    string Code,
    string Message);

public sealed class LicenseOperationException : InvalidOperationException
{
    public LicenseOperationException(string code, string message) : base(message)
    {
        Code = code;
    }

    public string Code { get; }
}
