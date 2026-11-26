namespace EG.Common.Modules;

public static class RequiredDateRules
{
    public static string? Validate(DateTime? value, string fieldName)
    {
        if (value is null || value.Value == default)
        {
            return $"La fecha de {fieldName} es requerida.";
        }

        return null;
    }
}
