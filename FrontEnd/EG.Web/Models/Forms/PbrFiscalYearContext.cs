using System.Reflection;

namespace EG.Web.Models.Forms;

public static class PbrFiscalYearContext
{
    private const string YearPropertyName = "Anio";

    public static bool TryGetSelectedYear(int? selectedYear, out int year)
    {
        year = selectedYear.GetValueOrDefault();
        return year > 0;
    }

    public static bool Apply(object item, int? selectedYear, bool overwrite)
    {
        ArgumentNullException.ThrowIfNull(item);

        var property = item.GetType().GetProperty(YearPropertyName, BindingFlags.Instance | BindingFlags.Public);
        if (property is null || !property.CanRead || !property.CanWrite || !IsSupported(property.PropertyType))
        {
            return property is null;
        }

        if (selectedYear is > 0 && (overwrite || !HasPositiveYear(property.GetValue(item))))
        {
            property.SetValue(item, selectedYear.Value);
        }

        return HasPositiveYear(property.GetValue(item));
    }

    private static bool IsSupported(Type propertyType)
    {
        var valueType = Nullable.GetUnderlyingType(propertyType) ?? propertyType;
        return valueType == typeof(int);
    }

    private static bool HasPositiveYear(object? value) => value switch
    {
        int year => year > 0,
        _ => false
    };
}
