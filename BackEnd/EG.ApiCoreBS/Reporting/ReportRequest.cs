using Microsoft.AspNetCore.WebUtilities;

namespace EG.ApiCoreBS.Reporting;

public sealed class ReportRequest
{
    private ReportRequest(string name, IReadOnlyDictionary<string, string> parameters)
    {
        Name = name;
        Parameters = parameters;
    }

    public string Name { get; }
    public IReadOnlyDictionary<string, string> Parameters { get; }

    public int? PrimaryKey =>
        TryGetInt("pk", out var value) ? value : null;

    public static ReportRequest Parse(string id)
    {
        if (string.IsNullOrWhiteSpace(id))
        {
            throw new ArgumentException("El nombre del reporte es requerido.", nameof(id));
        }

        var parts = id.Split('?', 2, StringSplitOptions.TrimEntries);
        var name = parts[0];
        var values = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

        if (parts.Length == 2)
        {
            var parsed = QueryHelpers.ParseQuery(parts[1]);
            foreach (var parameter in parsed)
            {
                values[parameter.Key] = parameter.Value.ToString();
            }
        }

        return new ReportRequest(name, values);
    }

    public bool TryGetInt(string name, out int value)
    {
        value = 0;
        return Parameters.TryGetValue(name, out var raw) && int.TryParse(raw, out value);
    }

    public string? GetValue(string name) =>
        Parameters.TryGetValue(name, out var value) ? value : null;
}
