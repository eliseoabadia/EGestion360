namespace EG.Web.Pages.Shared;

/// <summary>Presentation groups for the fields actually exposed by metadata editors.</summary>
public static class CrudFieldLayout
{
    public sealed record FieldGroup<T>(string Title, IReadOnlyList<T> Fields, bool ShowHeading);

    public static IEnumerable<FieldGroup<T>> Group<T>(IEnumerable<T> fields, Func<T, string> name)
    {
        var visible = fields.ToList();
        if (visible.Count <= 4)
        {
            yield return new("Datos del registro", visible, false);
            yield break;
        }

        foreach (var group in visible.GroupBy(field => Section(name(field))))
            yield return new(group.Key, group.ToList(), true);
    }

    private static string Section(string name)
    {
        if (name.Contains("Fecha", StringComparison.OrdinalIgnoreCase))
            return "Fechas y vigencia";
        if (name.StartsWith("Fkid", StringComparison.OrdinalIgnoreCase) || name.StartsWith("Id", StringComparison.OrdinalIgnoreCase))
            return "Relaciones y clasificación";
        if (new[] { "Valor", "Importe", "Monto", "Porcentaje", "Tasa", "Limite", "Cuota", "Factor", "Meta", "Formula", "Frecuencia", "UnidadMedida", "Sentido" }
            .Any(term => name.Contains(term, StringComparison.OrdinalIgnoreCase)))
            return "Valores y parámetros";
        if (new[] { "Objetivo", "Resumen", "Supuesto", "Verificacion", "Observacion", "Justificacion" }
            .Any(term => name.Contains(term, StringComparison.OrdinalIgnoreCase)))
            return "Objetivos y seguimiento";
        return "Identificación y descripción";
    }
}
