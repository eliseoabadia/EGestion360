using MudBlazor;

namespace EG.Web.Models.ProcessAssistance;

public sealed record ProcessAssistanceModel(
    string Status,
    string Title,
    string Detail,
    string MenuPath,
    string Owner,
    string ActionLabel,
    string Action,
    string? HelpKey,
    string Icon,
    Color Color);
