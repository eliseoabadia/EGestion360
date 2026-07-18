namespace EG.Web.Pages.Shared;

public sealed class CinematicRecordModel
{
    public string Eyebrow { get; init; } = "EXPEDIENTE OPERATIVO";
    public string Title { get; init; } = "Detalle del registro";
    public string Subtitle { get; init; } = string.Empty;
    public string RecordCode { get; init; } = "SIN-CÓDIGO";
    public string Status { get; init; } = "CONSULTA";
    public string StatusTone { get; init; } = "info";
    public string Classification { get; init; } = "SOLO LECTURA";
    public string? HeroLabel { get; init; }
    public string? HeroValue { get; init; }
    public IReadOnlyList<CinematicRecordSection> Sections { get; init; } = [];
}

public sealed class CinematicRecordSection
{
    public string Code { get; init; } = "01";
    public string Title { get; init; } = "Información";
    public IReadOnlyList<CinematicRecordField> Fields { get; init; } = [];
}

public sealed class CinematicRecordField
{
    public string Label { get; init; } = string.Empty;
    public string Value { get; init; } = "—";
    public bool Emphasized { get; init; }
    public bool Wide { get; init; }
}
