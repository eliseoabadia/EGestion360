using System.Reflection;

namespace EG.Web.Services;

/// <summary>
/// Removes database keys and numeric audit actors from user-facing exports.
/// Export projections should still use business labels; this is a final guard
/// against accidentally exposing internal identifiers in a mapped row.
/// </summary>
public static class ExportProjectionSanitizer
{
    public static IEnumerable<IDictionary<string, object?>> RemoveInternalIdentifiers(IEnumerable<object> rows)
    {
        ArgumentNullException.ThrowIfNull(rows);

        foreach (var row in rows)
        {
            if (row is null)
            {
                continue;
            }

            var properties = row is IDictionary<string, object?> dictionary
                ? dictionary.Where(pair => !IsInternalIdentifier(pair.Key))
                : row.GetType()
                    .GetProperties(BindingFlags.Instance | BindingFlags.Public)
                    .Where(property => property.CanRead && property.GetIndexParameters().Length == 0 && !IsInternalIdentifier(property.Name))
                    .Select(property => new KeyValuePair<string, object?>(property.Name, property.GetValue(row)));

            yield return properties.ToDictionary(pair => pair.Key, pair => pair.Value);
        }
    }

    public static bool IsInternalIdentifier(string name)
        => !name.Equals("PayrollId", StringComparison.OrdinalIgnoreCase)
            && !name.Equals("IdPeriodo", StringComparison.OrdinalIgnoreCase)
            && (name.StartsWith("Pkid", StringComparison.OrdinalIgnoreCase)
            || name.StartsWith("Fkid", StringComparison.OrdinalIgnoreCase)
            || name.Equals("Id", StringComparison.OrdinalIgnoreCase)
            || name.EndsWith("Id", StringComparison.OrdinalIgnoreCase)
            || name.Equals("UsuarioCreacion", StringComparison.OrdinalIgnoreCase)
            || name.Equals("UsuarioModificacion", StringComparison.OrdinalIgnoreCase));
}
