using Microsoft.AspNetCore.WebUtilities;

namespace EG.ApiCoreBS.Reporting;

public sealed class ReportRequest
{
    private static readonly IReadOnlyDictionary<string, string[]> ParameterAliases =
        new Dictionary<string, string[]>(StringComparer.OrdinalIgnoreCase)
        {
            ["p_FecInicio"] = ["p_FechaInicio", "p_FechaInicio2", "FechaInicio"],
            ["p_FecFin"] = ["p_FechaFin", "p_FechaFin2", "FechaFin"],
            ["p_FechaInicio"] = ["p_FecInicio", "p_FechaInicio2", "FechaInicio"],
            ["p_FechaFin"] = ["p_FecFin", "p_FechaFin2", "FechaFin"],
            ["p_FechaInicio2"] = ["p_FechaInicio", "p_FecInicio", "FechaInicio"],
            ["p_FechaFin2"] = ["p_FechaFin", "p_FecFin", "FechaFin"],
            ["IdEmpresa"] = ["p_IdEmpresa", "EmpresaId", "FKIdEmpresa", "FKIdEmpresa_SIS"],
            ["p_IdEmpresa"] = ["IdEmpresa", "EmpresaId", "FKIdEmpresa", "FKIdEmpresa_SIS"],
            ["EmpresaId"] = ["IdEmpresa", "p_IdEmpresa", "FKIdEmpresa", "FKIdEmpresa_SIS"],
            ["IdEmpleado"] = ["p_IdEmpleado", "IdUsuario", "UsuarioId", "UserId"],
            ["p_IdEmpleado"] = ["IdEmpleado", "IdUsuario", "UsuarioId", "UserId"],
            ["IdUsuario"] = ["IdEmpleado", "p_IdEmpleado", "UsuarioId", "UserId"],
            ["UsuarioId"] = ["IdEmpleado", "p_IdEmpleado", "IdUsuario", "UserId"]
        };

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

    public string? GetValue(string name)
    {
        if (Parameters.TryGetValue(name, out var value))
        {
            return value;
        }

        if (!ParameterAliases.TryGetValue(name, out var aliases))
        {
            return null;
        }

        foreach (var alias in aliases)
        {
            if (Parameters.TryGetValue(alias, out value))
            {
                return value;
            }
        }

        return null;
    }
}
