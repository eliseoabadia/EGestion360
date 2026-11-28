namespace EG.Domain.DTOs.Responses.Adquisicion;

public sealed record RequisitionJourneyStep(string Label, bool Recorded, string Detail, bool Partial = false);

public sealed class RequisitionJourney
{
    public List<RequisitionJourneyStep> Steps { get; set; } = [];
}
