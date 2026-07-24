using MudBlazor;

namespace EG.Web.Models;

/// <summary>
/// Describe una accion contextual sin acoplarla a una pantalla especifica.
/// El componente ProgressiveActions decide como presentar la accion principal
/// y como agrupar las acciones secundarias.
/// </summary>
public sealed class ProgressiveAction
{
    public required string Id { get; init; }
    public required string Label { get; init; }
    public required string Icon { get; init; }
    public Func<Task>? ExecuteAsync { get; init; }
    public Color Color { get; init; } = Color.Primary;
    public bool Visible { get; init; } = true;
    public bool Enabled { get; init; } = true;
    public bool IsPrimary { get; init; }
    public bool IsDestructive { get; init; }
    public int Order { get; init; }
    public string? DisabledReason { get; init; }
}
