using System.Text.Json.Serialization;

namespace EG.Contracts.Platform.Licensing;

public static class LicenseModuleCodes
{
    public const string GrpAdministracion = "GRP.ADMIN";
    public const string GrpAdquisiciones = "GRP.ADQ";
    public const string GrpAlmacen = "GRP.ALMA";
    public const string GrpContabilidad = "GRP.CONTA";
    public const string GrpPatrimonio = "GRP.PATRI";
    public const string GrpPresupuesto = "GRP.PRES";
    public const string Nomina = "NOM";
    public const string Pbr = "PBR";

    public static IReadOnlyList<LicenseModuleDefinition> All { get; } =
    [
        new(GrpAdministracion, "Administración", "GRP", 10),
        new(GrpAdquisiciones, "Adquisiciones", "GRP", 20),
        new(GrpAlmacen, "Almacén", "GRP", 30),
        new(GrpContabilidad, "Contabilidad", "GRP", 40),
        new(GrpPatrimonio, "Patrimonio", "GRP", 50),
        new(GrpPresupuesto, "Presupuesto", "GRP", 60),
        new(Nomina, "Nómina", "INDEPENDIENTE", 70),
        new(Pbr, "PBR", "INDEPENDIENTE", 80)
    ];

    public static bool IsKnown(string? code) =>
        All.Any(module => string.Equals(module.Code, code, StringComparison.OrdinalIgnoreCase));

    public static LicenseModuleDefinition? Find(string? code) =>
        All.FirstOrDefault(module => string.Equals(module.Code, code, StringComparison.OrdinalIgnoreCase));
}

public sealed record LicenseModuleDefinition(string Code, string Name, string Group, short Order);

public sealed class LicenseInstallationRequestResponse
{
    public string Product { get; set; } = "GE360";
    public short FormatVersion { get; set; } = 1;
    public Guid InstallationId { get; set; }
    public string InstallationFingerprint { get; set; } = string.Empty;
    public DateTimeOffset GeneratedAtUtc { get; set; }
}

public sealed class ImportLicenseRequest
{
    public string SignedLicense { get; set; } = string.Empty;
}

public sealed class SetLicenseModuleStateRequest
{
    public bool Active { get; set; }
    public string? Reason { get; set; }
}

public sealed class LicenseSnapshotResponse
{
    public Guid InstallationId { get; set; }
    public string InstallationFingerprint { get; set; } = string.Empty;
    public Guid? LicenseId { get; set; }
    public long Serial { get; set; }
    public bool HasValidLicense { get; set; }
    public string StateCode { get; set; } = "LIC_NOT_CONFIGURED";
    public string Message { get; set; } = "La instalación todavía no tiene una licencia válida.";
    public string ClockState { get; set; } = "VALID";
    public DateTimeOffset EvaluatedAtUtc { get; set; }
    public IReadOnlyList<LicenseModuleStatusResponse> Modules { get; set; } = [];
}

public sealed class LicenseModuleStatusResponse
{
    public string Code { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Group { get; set; } = string.Empty;
    public bool Contracted { get; set; }
    public bool ActiveLocally { get; set; }
    public bool Effective { get; set; }
    public string StateCode { get; set; } = "LIC_MODULE_NOT_CONTRACTED";
    public string Message { get; set; } = string.Empty;
    public DateTimeOffset? StartsAtUtc { get; set; }
    public DateTimeOffset? EndsAtUtc { get; set; }
    public int? RemainingDays { get; set; }
}

public sealed class LicenseTokenPayload
{
    [JsonPropertyName("product")]
    public string Product { get; set; } = "GE360";

    [JsonPropertyName("formatVersion")]
    public short FormatVersion { get; set; } = 1;

    [JsonPropertyName("licenseId")]
    public Guid LicenseId { get; set; }

    [JsonPropertyName("installationId")]
    public Guid InstallationId { get; set; }

    [JsonPropertyName("installationFingerprint")]
    public string InstallationFingerprint { get; set; } = string.Empty;

    [JsonPropertyName("serial")]
    public long Serial { get; set; }

    [JsonPropertyName("issuedAtUtc")]
    public DateTimeOffset IssuedAtUtc { get; set; }

    [JsonPropertyName("modules")]
    public List<LicenseTokenModule> Modules { get; set; } = [];
}

public sealed class LicenseTokenModule
{
    [JsonPropertyName("code")]
    public string Code { get; set; } = string.Empty;

    [JsonPropertyName("startsAtUtc")]
    public DateTimeOffset StartsAtUtc { get; set; }

    [JsonPropertyName("endsAtUtc")]
    public DateTimeOffset? EndsAtUtc { get; set; }
}

public sealed class LicenseIssueContract
{
    public Guid LicenseId { get; set; }
    public long Serial { get; set; }
    public DateTimeOffset? IssuedAtUtc { get; set; }
    public List<LicenseIssueModule> Modules { get; set; } = [];
}

public sealed class LicenseIssueModule
{
    public string Code { get; set; } = string.Empty;
    public DateTimeOffset StartsAtUtc { get; set; }
    public DateTimeOffset? EndsAtUtc { get; set; }
}
