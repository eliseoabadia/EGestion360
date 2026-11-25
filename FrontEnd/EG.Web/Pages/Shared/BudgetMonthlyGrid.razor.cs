using EG.Web.Models.PresupuestoModificado;
using Microsoft.AspNetCore.Components;

namespace EG.Web.Pages.Shared;

public partial class BudgetMonthlyGrid
{
    [Parameter, EditorRequired] public Func<int, decimal?> GetAmount { get; set; } = null!;
    [Parameter] public EventCallback<BudgetMonthChange> OnAmountChanged { get; set; }
    [Parameter] public bool Disabled { get; set; }
}
