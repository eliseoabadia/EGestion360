using DevExpress.DataAccess.ConnectionParameters;
using DevExpress.DataAccess.Sql;
using DevExpress.XtraReports.UI;
using EG.Common;

namespace EG.ApiCoreBS.Reporting;

public sealed class ReportConnectionConfigurator
{
    private readonly IConfiguration _configuration;

    public ReportConnectionConfigurator(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public void Apply(XtraReport report)
    {
        foreach (var dataSource in EnumerateSqlDataSources(report))
        {
            var connectionName = string.IsNullOrWhiteSpace(dataSource.ConnectionName)
                ? dataSource.Name
                : dataSource.ConnectionName;

            var connectionString = _configuration.GetConnectionString(Constants.BD_CON)
                ?? _configuration.GetConnectionString(connectionName);
            if (!string.IsNullOrWhiteSpace(connectionString))
            {
                dataSource.ConnectionParameters = new CustomStringConnectionParameters(connectionString);
            }
        }
    }

    public void TryRebuildResultSchemasWithoutPersistingConnection(XtraReport report)
    {
        Apply(report);

        foreach (var dataSource in EnumerateSqlDataSources(report))
        {
            try
            {
                dataSource.RebuildResultSchema();
            }
            catch
            {
                // The designer can still open the layout even when the database is unavailable.
            }
            finally
            {
                dataSource.ConnectionParameters = null!;
            }
        }
    }

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
}
