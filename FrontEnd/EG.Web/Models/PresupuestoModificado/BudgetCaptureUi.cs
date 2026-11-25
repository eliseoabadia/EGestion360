using System.Globalization;

namespace EG.Web.Models.PresupuestoModificado;

public static class BudgetCaptureUi
{
    public static CultureInfo NumberCulture { get; } = CultureInfo.InvariantCulture;
    public static CultureInfo DateCulture { get; } = CultureInfo.GetCultureInfo("es-MX");
    public static IReadOnlyList<BudgetMonth> Months { get; } = Array.AsReadOnly<BudgetMonth>(
    [
        new(1, "Ene"), new(2, "Feb"), new(3, "Mar"), new(4, "Abr"),
        new(5, "May"), new(6, "Jun"), new(7, "Jul"), new(8, "Ago"),
        new(9, "Sep"), new(10, "Oct"), new(11, "Nov"), new(12, "Dic")
    ]);

    public static string? ValidateDate(DateTime? date, int? expectedYear = null)
    {
        if (!date.HasValue)
            return "Captura una fecha válida.";
        if (expectedYear.HasValue && date.Value.Year != expectedYear.Value)
            return $"La fecha debe pertenecer al ejercicio {expectedYear.Value}.";
        return null;
    }

    public static string? ValidateAmount(decimal? amount) => amount is < 0m
        ? "El importe no puede ser negativo." : null;
}

public readonly record struct BudgetMonth(int Index, string Label);
public readonly record struct BudgetMonthChange(int Index, decimal? Amount);
