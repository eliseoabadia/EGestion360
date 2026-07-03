using System.Collections.Concurrent;
using DevExpress.DataAccess;
using DevExpress.DataAccess.Sql;
using DevExpress.XtraReports.Parameters;
using DevExpress.XtraReports.UI;
using EG.Common;
using Microsoft.Data.SqlClient;

namespace EG.ApiCoreBS.Reporting;

public sealed class ReportContextParameterConfigurator
{
    private static readonly ReportContextParameter[] ContextParameters =
    [
        new("@IdEmpresa", "IdEmpresa"),
        new("@IdEmpleado", "IdEmpleado")
    ];

    private readonly IConfiguration _configuration;
    private readonly ConcurrentDictionary<string, IReadOnlySet<string>> _storedProcedureParameters = new(StringComparer.OrdinalIgnoreCase);

    public ReportContextParameterConfigurator(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public void Apply(XtraReport report, ReportRequest request)
    {
        foreach (var dataSource in EnumerateSqlDataSources(report))
        {
            foreach (var query in dataSource.Queries.OfType<StoredProcQuery>())
            {
                var storedProcedureParameters = GetStoredProcedureParameters(query.StoredProcName);
                if (storedProcedureParameters.Count == 0)
                {
                    continue;
                }

                foreach (var contextParameter in ContextParameters)
                {
                    if (!storedProcedureParameters.Contains(contextParameter.StoredProcedureName))
                    {
                        continue;
                    }

                    EnsureReportParameter(report, contextParameter.ReportParameterName, request);
                    if (!HasQueryParameter(query, contextParameter.StoredProcedureName))
                    {
                        query.Parameters.Add(new QueryParameter(
                            contextParameter.StoredProcedureName,
                            typeof(Expression),
                            new Expression($"?{contextParameter.ReportParameterName}", typeof(int))));
                    }
                }
            }
        }
    }

    private void EnsureReportParameter(XtraReport report, string parameterName, ReportRequest request)
    {
        var parameter = report.Parameters[parameterName];
        if (parameter is null)
        {
            parameter = new Parameter
            {
                Name = parameterName,
                Type = typeof(int),
                Visible = false
            };
            report.Parameters.Add(parameter);
        }

        parameter.Type = typeof(int);
        parameter.Visible = false;
        parameter.Value = TryResolveIntValue(request, parameterName, out var value) ? value : 0;
    }

    private static bool TryResolveIntValue(ReportRequest request, string parameterName, out int value)
    {
        var raw = request.GetValue(parameterName);
        return int.TryParse(raw, out value);
    }

    private IReadOnlySet<string> GetStoredProcedureParameters(string storedProcedureName)
    {
        if (!TryParseStoredProcedureName(storedProcedureName, out var schemaName, out var procedureName))
        {
            return EmptyParameterSet.Value;
        }

        var cacheKey = $"{schemaName}.{procedureName}";
        return _storedProcedureParameters.GetOrAdd(cacheKey, _ => LoadStoredProcedureParameters(schemaName, procedureName));
    }

    private IReadOnlySet<string> LoadStoredProcedureParameters(string schemaName, string procedureName)
    {
        var connectionString = _configuration.GetConnectionString(Constants.BD_CON);
        if (string.IsNullOrWhiteSpace(connectionString))
        {
            return EmptyParameterSet.Value;
        }

        var parameters = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        using var connection = new SqlConnection(connectionString);
        using var command = connection.CreateCommand();
        command.CommandText = """
            SELECT PARAMETER_NAME
            FROM INFORMATION_SCHEMA.PARAMETERS
            WHERE SPECIFIC_SCHEMA = @schemaName
              AND SPECIFIC_NAME = @procedureName
            """;
        command.Parameters.AddWithValue("@schemaName", schemaName);
        command.Parameters.AddWithValue("@procedureName", procedureName);

        connection.Open();
        using var reader = command.ExecuteReader();
        while (reader.Read())
        {
            if (!reader.IsDBNull(0))
            {
                parameters.Add(reader.GetString(0));
            }
        }

        return parameters;
    }

    private static bool HasQueryParameter(StoredProcQuery query, string parameterName) =>
        query.Parameters.Any(parameter =>
            string.Equals(parameter.Name, parameterName, StringComparison.OrdinalIgnoreCase));

    private static bool TryParseStoredProcedureName(string? storedProcedureName, out string schemaName, out string procedureName)
    {
        schemaName = string.Empty;
        procedureName = string.Empty;

        if (string.IsNullOrWhiteSpace(storedProcedureName))
        {
            return false;
        }

        var parts = storedProcedureName
            .Split('.', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
            .Select(NormalizeSqlIdentifier)
            .Where(part => !string.IsNullOrWhiteSpace(part))
            .ToArray();

        if (parts.Length == 0)
        {
            return false;
        }

        procedureName = parts[^1];
        schemaName = parts.Length >= 2 ? parts[^2] : "dbo";
        return true;
    }

    private static string NormalizeSqlIdentifier(string value) =>
        value.Trim().Trim('[', ']', '"');

    private static IEnumerable<SqlDataSource> EnumerateSqlDataSources(XtraReport report)
    {
        var visited = new HashSet<SqlDataSource>();

        if (report.DataSource is SqlDataSource reportDataSource)
        {
            visited.Add(reportDataSource);
            yield return reportDataSource;
        }

        foreach (var component in report.ComponentStorage.OfType<SqlDataSource>())
        {
            if (visited.Add(component))
            {
                yield return component;
            }
        }
    }

    private sealed record ReportContextParameter(string StoredProcedureName, string ReportParameterName);

    private static class EmptyParameterSet
    {
        public static IReadOnlySet<string> Value { get; } = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
    }
}
