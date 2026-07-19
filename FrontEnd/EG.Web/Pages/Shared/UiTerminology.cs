namespace EG.Web.Shared;

/// <summary>
/// Terminología exclusiva de la interfaz. Los contratos y nombres técnicos
/// conservan "Empresa" para mantener compatibilidad con los servicios.
/// </summary>
public static class UiTerminology
{
    public static string Display(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
            return value ?? string.Empty;

        return value
            .Replace("Empresas", "Entidades", StringComparison.Ordinal)
            .Replace("empresas", "entidades", StringComparison.Ordinal)
            .Replace("Empresa", "Entidad", StringComparison.Ordinal)
            .Replace("empresa", "entidad", StringComparison.Ordinal);
    }
}
