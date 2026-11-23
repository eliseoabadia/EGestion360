using EG.Contracts.Platform.Licensing;
using EG.Domain.Platform.Licensing;

namespace EG.ApiCoreBS.Services.Licensing;

public sealed class LicenseRuntimeState : ILicenseRuntimeState
{
    private static readonly TimeSpan ClockRollbackTolerance = TimeSpan.FromMinutes(5);
    private readonly object _gate = new();
    private LicenseRuntimeSnapshot _snapshot = new(
        Guid.Empty,
        string.Empty,
        null,
        0,
        false,
        DateTimeOffset.UtcNow,
        false,
        []);

    public void Replace(LicenseRuntimeSnapshot snapshot)
    {
        ArgumentNullException.ThrowIfNull(snapshot);
        lock (_gate)
        {
            _snapshot = snapshot with { Grants = snapshot.Grants.ToArray() };
        }
    }

    public LicenseDecision Evaluate(string moduleCode, DateTimeOffset? utcNow = null)
    {
        if (!LicenseModuleCodes.IsKnown(moduleCode))
        {
            return new LicenseDecision(
                false,
                moduleCode,
                "LIC_MODULE_UNKNOWN",
                "La operación no tiene un módulo comercial reconocido.");
        }

        lock (_gate)
        {
            var now = utcNow ?? DateTimeOffset.UtcNow;
            ObserveClock(now);
            return EvaluateUnsafe(moduleCode, now);
        }
    }

    public LicenseSnapshotResponse GetSnapshot(DateTimeOffset? utcNow = null)
    {
        lock (_gate)
        {
            var now = utcNow ?? DateTimeOffset.UtcNow;
            ObserveClock(now);

            var modules = LicenseModuleCodes.All
                .OrderBy(module => module.Order)
                .Select(module => BuildModuleStatusUnsafe(module, now))
                .ToArray();

            var validLicense = _snapshot.SignatureValid && !_snapshot.ClockSuspicious;
            var stateCode = _snapshot.ClockSuspicious
                ? "LIC_CLOCK_SUSPICIOUS"
                : _snapshot.SignatureValid
                    ? "LIC_VALID"
                    : "LIC_NOT_CONFIGURED";
            var message = stateCode switch
            {
                "LIC_VALID" => "Licencia válida. Los módulos se evalúan según contrato y configuración local.",
                "LIC_CLOCK_SUSPICIOUS" => "El reloj del servidor retrocedió. Se bloquearon los módulos comerciales hasta corregirlo.",
                _ => "La instalación todavía no tiene una licencia válida."
            };

            return new LicenseSnapshotResponse
            {
                InstallationId = _snapshot.InstallationId,
                InstallationFingerprint = _snapshot.InstallationFingerprint,
                LicenseId = _snapshot.LicenseId,
                Serial = _snapshot.Serial,
                HasValidLicense = validLicense,
                StateCode = stateCode,
                Message = message,
                ClockState = _snapshot.ClockSuspicious ? "SUSPICIOUS" : "VALID",
                EvaluatedAtUtc = now,
                Modules = modules
            };
        }
    }

    public LicenseRuntimeSnapshot GetRuntimeSnapshot()
    {
        lock (_gate)
        {
            return _snapshot with { Grants = _snapshot.Grants.ToArray() };
        }
    }

    private void ObserveClock(DateTimeOffset now)
    {
        if (now < _snapshot.LastObservedUtc - ClockRollbackTolerance)
        {
            _snapshot = _snapshot with { ClockSuspicious = true };
            return;
        }

        if (now > _snapshot.LastObservedUtc)
        {
            _snapshot = _snapshot with { LastObservedUtc = now };
        }
    }

    private LicenseDecision EvaluateUnsafe(string moduleCode, DateTimeOffset now)
    {
        if (_snapshot.ClockSuspicious)
        {
            return new LicenseDecision(
                false,
                moduleCode,
                "LIC_CLOCK_SUSPICIOUS",
                "El reloj del servidor requiere revisión antes de continuar.");
        }

        if (!_snapshot.SignatureValid)
        {
            return new LicenseDecision(
                false,
                moduleCode,
                "LIC_NOT_CONFIGURED",
                "La instalación no tiene una licencia válida.");
        }

        var grant = _snapshot.Grants.FirstOrDefault(candidate =>
            string.Equals(candidate.ModuleCode, moduleCode, StringComparison.OrdinalIgnoreCase));

        if (grant is null)
        {
            return new LicenseDecision(
                false,
                moduleCode,
                "LIC_MODULE_NOT_CONTRACTED",
                "El módulo no está incluido en el contrato de esta instalación.");
        }

        if (now < grant.StartsAtUtc)
        {
            return new LicenseDecision(
                false,
                moduleCode,
                "LIC_MODULE_NOT_STARTED",
                "La vigencia del módulo todavía no inicia.");
        }

        if (grant.EndsAtUtc.HasValue && now >= grant.EndsAtUtc.Value)
        {
            return new LicenseDecision(
                false,
                moduleCode,
                "LIC_MODULE_EXPIRED",
                "La vigencia del módulo terminó. Importe una renovación para continuar.");
        }

        if (!grant.ActiveLocally)
        {
            return new LicenseDecision(
                false,
                moduleCode,
                "LIC_MODULE_DISABLED",
                "El módulo está apagado en la configuración de esta instalación.");
        }

        return new LicenseDecision(true, moduleCode, "LIC_ALLOWED", "Módulo autorizado.");
    }

    private LicenseModuleStatusResponse BuildModuleStatusUnsafe(
        LicenseModuleDefinition module,
        DateTimeOffset now)
    {
        var grant = _snapshot.Grants.FirstOrDefault(candidate =>
            string.Equals(candidate.ModuleCode, module.Code, StringComparison.OrdinalIgnoreCase));
        var decision = EvaluateUnsafe(module.Code, now);
        var contracted = _snapshot.SignatureValid && grant is not null;
        int? remainingDays = null;

        if (grant?.EndsAtUtc is { } endsAtUtc)
        {
            remainingDays = Math.Max(0, (int)Math.Ceiling((endsAtUtc - now).TotalDays));
        }

        return new LicenseModuleStatusResponse
        {
            Code = module.Code,
            Name = module.Name,
            Group = module.Group,
            Contracted = contracted,
            ActiveLocally = grant?.ActiveLocally ?? false,
            Effective = decision.Allowed,
            StateCode = decision.Code,
            Message = decision.Message,
            StartsAtUtc = grant?.StartsAtUtc,
            EndsAtUtc = grant?.EndsAtUtc,
            RemainingDays = remainingDays
        };
    }
}
