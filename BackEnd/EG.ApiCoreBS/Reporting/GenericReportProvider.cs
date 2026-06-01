using DevExpress.XtraReports.Services;
using DevExpress.XtraReports.UI;
using DevExpress.XtraReports.Web.ClientControls;

namespace EG.ApiCoreBS.Reporting;

public sealed class GenericReportProvider : IReportProvider
{
    private readonly InMemoryReportStorageWebExtension _reportStorage;
    private readonly StoredProcedureReportRegistry _storedProcedureReports;
    private readonly StoredProcedureReportFactory _storedProcedureReportFactory;
    private readonly ReportConnectionConfigurator _reportConnectionConfigurator;
    private readonly ReportLogoConfigurator _reportLogoConfigurator;

    public GenericReportProvider(
        InMemoryReportStorageWebExtension reportStorage,
        StoredProcedureReportRegistry storedProcedureReports,
        StoredProcedureReportFactory storedProcedureReportFactory,
        ReportConnectionConfigurator reportConnectionConfigurator,
        ReportLogoConfigurator reportLogoConfigurator)
    {
        _reportStorage = reportStorage;
        _storedProcedureReports = storedProcedureReports;
        _storedProcedureReportFactory = storedProcedureReportFactory;
        _reportConnectionConfigurator = reportConnectionConfigurator;
        _reportLogoConfigurator = reportLogoConfigurator;
    }

    XtraReport IReportProvider.GetReport(string id, ReportProviderContext context)
    {
        var request = ReportRequest.Parse(id);
        var storedReport = TryLoadStoredReport(request);
        if (storedReport != null)
        {
            return storedReport;
        }

        var report = request.Name switch
        {
            ReportKeys.PaaasHelloWorld => new Reports.PaaasHelloWorldReport(request),
            _ when _storedProcedureReports.TryGet(request.Name, out var definition) =>
                _storedProcedureReportFactory.Create(definition, request),
            _ => throw ReportNotFound(request.Name)
        };

        ApplyParameters(report, request);
        _reportConnectionConfigurator.Apply(report);
        _reportLogoConfigurator.Apply(report, request.Name);
        return report;
    }

    private XtraReport? TryLoadStoredReport(ReportRequest request)
    {
        if (!_reportStorage.TryGetReportLayout(request.Name, out var reportLayout))
        {
            return null;
        }

        using var stream = new MemoryStream(reportLayout);
        var report = XtraReport.FromXmlStream(stream, true);
        ApplyParameters(report, request);
        _reportConnectionConfigurator.Apply(report);
        _reportLogoConfigurator.Apply(report, request.Name);
        return report;
    }

    private void ApplyParameters(XtraReport report, ReportRequest request)
    {
        foreach (DevExpress.XtraReports.Parameters.Parameter parameter in report.Parameters)
        {
            if (!TryGetParameterValue(parameter.Name, request, out var rawValue))
            {
                continue;
            }

            try
            {
                parameter.Value = Convert.ChangeType(rawValue, parameter.Type);
            }
            catch
            {
                parameter.Value = rawValue;
            }

            parameter.Visible = false;
        }
    }

    private bool TryGetParameterValue(string parameterName, ReportRequest request, out string rawValue)
    {
        if (request.Parameters.TryGetValue(parameterName, out rawValue!))
        {
            return true;
        }

        if (!_storedProcedureReports.TryGet(request.Name, out var definition))
        {
            return false;
        }

        var mappedParameter = definition.Parameters.FirstOrDefault(parameter =>
            string.Equals(parameter.ReportParameterName, parameterName, StringComparison.OrdinalIgnoreCase));

        if (mappedParameter == null)
        {
            return false;
        }

        rawValue = request.GetValue(mappedParameter.RequestParameterName) ??
                   request.GetValue(mappedParameter.ReportParameterName) ??
                   string.Empty;

        return !string.IsNullOrWhiteSpace(rawValue);
    }

    private static FaultException ReportNotFound(string reportName) =>
        new($"No se encontro el reporte '{reportName}'.");
}
