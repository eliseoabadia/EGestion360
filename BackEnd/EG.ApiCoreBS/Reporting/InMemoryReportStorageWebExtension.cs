using System.Collections.Concurrent;
using DevExpress.XtraReports.UI;
using DevExpress.XtraReports.Web.ClientControls;
using DevExpress.XtraReports.Web.Extensions;

namespace EG.ApiCoreBS.Reporting;

public sealed class InMemoryReportStorageWebExtension : ReportStorageWebExtension
{
    private readonly ConcurrentDictionary<string, byte[]> _reports = new(StringComparer.OrdinalIgnoreCase);
    private readonly object _loadLock = new();
    private readonly IWebHostEnvironment _environment;
    private readonly StoredProcedureReportRegistry _storedProcedureReports;
    private readonly StoredProcedureReportFactory _storedProcedureReportFactory;
    private readonly ReportConnectionConfigurator _reportConnectionConfigurator;
    private readonly ILogger<InMemoryReportStorageWebExtension> _logger;
    private bool _initialReportsLoaded;

    public InMemoryReportStorageWebExtension(
        IWebHostEnvironment environment,
        StoredProcedureReportRegistry storedProcedureReports,
        StoredProcedureReportFactory storedProcedureReportFactory,
        ReportConnectionConfigurator reportConnectionConfigurator,
        ILogger<InMemoryReportStorageWebExtension> logger)
    {
        _environment = environment;
        _storedProcedureReports = storedProcedureReports;
        _storedProcedureReportFactory = storedProcedureReportFactory;
        _reportConnectionConfigurator = reportConnectionConfigurator;
        _logger = logger;
    }

    public override bool CanSetData(string url) => IsValidUrl(url);

    public override byte[] GetData(string url)
    {
        if (!TryGetReportLayout(url, out var reportLayout))
        {
            throw ReportNotFound(url);
        }

        return reportLayout;
    }

    public bool TryGetReportLayout(string url, out byte[] reportLayout)
    {
        reportLayout = [];
        if (!IsValidUrl(url))
        {
            return false;
        }

        EnsureInitialReportsLoaded();

        var reportName = NormalizeUrl(url);
        if (_reports.TryGetValue(reportName, out var storedLayout))
        {
            reportLayout = storedLayout.ToArray();
            return true;
        }

        if (!TryCreateStoredProcedureReportLayout(reportName, out var generatedLayout))
        {
            return false;
        }

        _reports[reportName] = generatedLayout;
        reportLayout = generatedLayout.ToArray();
        return true;
    }

    public override Dictionary<string, string> GetUrls()
    {
        EnsureInitialReportsLoaded();

        var reports = _reports.Keys.ToDictionary(name => name, name => name, StringComparer.OrdinalIgnoreCase);
        foreach (var report in _storedProcedureReports.Reports)
        {
            if (ReportPathResolver.TryNormalize(report.ReportName, out _))
            {
                reports[report.ReportName] = report.DisplayName;
            }
        }

        return reports;
    }

    public override bool IsValidUrl(string url)
    {
        return ReportPathResolver.TryNormalize(url, out _);
    }

    public override void SetData(XtraReport report, string url)
    {
        if (!IsValidUrl(url))
        {
            throw new FaultException($"El nombre del reporte '{url}' no es valido.");
        }

        SaveReportInMemory(report, NormalizeUrl(url));
    }

    public override string SetNewData(XtraReport report, string defaultUrl)
    {
        var reportName = NormalizeUrl(defaultUrl);
        if (string.IsNullOrWhiteSpace(reportName))
        {
            reportName = "NuevoReporte";
        }

        reportName = GetAvailableReportName(reportName);
        SaveReportInMemory(report, reportName);
        return reportName;
    }

    private void EnsureInitialReportsLoaded()
    {
        if (_initialReportsLoaded)
        {
            return;
        }

        lock (_loadLock)
        {
            if (_initialReportsLoaded)
            {
                return;
            }

            var reportsRoot = ReportPathResolver.GetReportsRoot(_environment.ContentRootPath);
            if (Directory.Exists(reportsRoot))
            {
                foreach (var reportPath in Directory.EnumerateFiles(reportsRoot, "*.repx", SearchOption.AllDirectories))
                {
                    var reportName = ReportPathResolver.GetReportNameFromPath(_environment.ContentRootPath, reportPath);
                    if (string.IsNullOrWhiteSpace(reportName))
                    {
                        continue;
                    }

                    _reports[reportName] = File.ReadAllBytes(reportPath);
                }
            }

            _logger.LogInformation("Reportes cargados en memoria: {Count}", _reports.Count);
            _initialReportsLoaded = true;
        }
    }

    private bool TryCreateStoredProcedureReportLayout(string reportName, out byte[] reportLayout)
    {
        reportLayout = [];
        if (!_storedProcedureReports.TryGet(reportName, out var definition))
        {
            return false;
        }

        using var stream = new MemoryStream();
        var report = _storedProcedureReportFactory.Create(definition, ReportRequest.Parse(reportName));
        _reportConnectionConfigurator.TryRebuildResultSchemasWithoutPersistingConnection(report);
        report.SaveLayoutToXml(stream);
        reportLayout = stream.ToArray();
        return true;
    }

    private void SaveReportInMemory(XtraReport report, string reportName)
    {
        using var stream = new MemoryStream();
        report.SaveLayoutToXml(stream);
        _reports[reportName] = stream.ToArray();
    }

    private string GetAvailableReportName(string reportName)
    {
        EnsureInitialReportsLoaded();

        var candidate = reportName;
        var index = 1;

        while (_reports.ContainsKey(candidate))
        {
            candidate = $"{reportName}_{index++}";
        }

        return candidate;
    }

    private static string NormalizeUrl(string url)
    {
        return ReportPathResolver.TryNormalize(url, out var reportName)
            ? reportName
            : string.Empty;
    }

    private static FaultException ReportNotFound(string reportName) =>
        new($"No se encontro el reporte '{reportName}'.");
}
