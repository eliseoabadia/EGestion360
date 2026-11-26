namespace EG.Common.Modules;

public static class IncomeAmountRules
{
    // Matches decimal(18,2) in the income adjustment procedure.
    public const decimal MaximumAmount = 9_999_999_999_999_999.99m;

    public static string? ValidateMonth(decimal? amount)
    {
        if (amount is < 0m) return "El importe no puede ser negativo.";
        if (amount > MaximumAmount) return "El importe supera la capacidad del registro.";
        if (amount.HasValue && decimal.Round(amount.Value, 2) != amount.Value)
            return "El importe debe tener como maximo dos decimales.";
        return null;
    }

    public static bool TrySum(IEnumerable<decimal> amounts, out decimal total)
    {
        total = 0m;
        foreach (var amount in amounts)
        {
            if (ValidateMonth(amount) != null || amount > MaximumAmount - total)
            {
                total = 0m;
                return false;
            }
            total += amount;
        }
        return true;
    }
}
