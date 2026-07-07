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
    private readonly ReportContextParameterConfigurator _reportContextParameterConfigurator;
    private readonly ReportLogoConfigurator _reportLogoConfigurator;
    private readonly ReportCompanyHeaderConfigurator _reportCompanyHeaderConfigurator;

    public GenericReportProvider(
        InMemoryReportStorageWebExtension reportStorage,
        StoredProcedureReportRegistry storedProcedureReports,
        StoredProcedureReportFactory storedProcedureReportFactory,
        ReportConnectionConfigurator reportConnectionConfigurator,
        ReportContextParameterConfigurator reportContextParameterConfigurator,
        ReportLogoConfigurator reportLogoConfigurator,
        ReportCompanyHeaderConfigurator reportCompanyHeaderConfigurator)
    {
        _reportStorage = reportStorage;
        _storedProcedureReports = storedProcedureReports;
        _storedProcedureReportFactory = storedProcedureReportFactory;
        _reportConnectionConfigurator = reportConnectionConfigurator;
        _reportContextParameterConfigurator = reportContextParameterConfigurator;
        _reportLogoConfigurator = reportLogoConfigurator;
        _reportCompanyHeaderConfigurator = reportCompanyHeaderConfigurator;
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

        _reportContextParameterConfigurator.Apply(report, request);
        ApplyParameters(report, request);
        _reportConnectionConfigurator.Apply(report);
        _reportLogoConfigurator.Apply(report, request);
        _reportCompanyHeaderConfigurator.Apply(report, request);
        return report;
    }

    private XtraReport? TryLoadStoredReport(ReportRequest request)
    {
        if (!_reportStorage.TryGetReportLayout(request.Name, out var reportLayout))
        {
            return null;
        }

        reportLayout = _reportLogoConfigurator.ApplyToLayout(reportLayout, request);
        using var stream = new MemoryStream(reportLayout);
        var report = XtraReport.FromXmlStream(stream, true);
        _reportContextParameterConfigurator.Apply(report, request);
        ApplyParameters(report, request);
        _reportConnectionConfigurator.Apply(report);
        _reportCompanyHeaderConfigurator.Apply(report, request);
        return report;
    }

    private void ApplyParameters(XtraReport report, ReportRequest request)
    {
        report.RequestParameters = false;

        foreach (DevExpress.XtraReports.Parameters.Parameter parameter in report.Parameters)
        {
            if (!TryGetParameterValue(parameter.Name, request, out var rawValue))
            {
                if (!TryGetDefaultParameterValue(parameter.Name, parameter.Type, out var defaultValue))
                {
                    parameter.Visible = false;
                    continue;
                }

                parameter.Value = defaultValue;
                parameter.Visible = false;
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

    private static bool TryGetDefaultParameterValue(string parameterName, Type parameterType, out object value)
    {
        var today = DateTime.Today;

        if (IsStartDateParameter(parameterName))
        {
            value = ConvertDefaultValue(new DateTime(today.Year, 1, 1), parameterType);
            return true;
        }

        if (IsEndDateParameter(parameterName))
        {
            value = ConvertDefaultValue(today, parameterType);
            return true;
        }

        value = string.Empty;
        return false;
    }

    private static object ConvertDefaultValue(DateTime value, Type parameterType)
    {
        var targetType = Nullable.GetUnderlyingType(parameterType) ?? parameterType;
        if (targetType == typeof(DateTime))
        {
            return value;
        }

        return value.ToString("yyyy-MM-dd");
    }

    private static bool IsStartDateParameter(string parameterName) =>
        MatchesParameterName(parameterName, "p_FecInicio", "p_FechaInicio", "p_FechaInicio2", "FechaInicio");

    private static bool IsEndDateParameter(string parameterName) =>
        MatchesParameterName(parameterName, "p_FecFin", "p_FechaFin", "p_FechaFin2", "FechaFin");

    private static bool MatchesParameterName(string parameterName, params string[] names) =>
        names.Any(name => string.Equals(parameterName, name, StringComparison.OrdinalIgnoreCase));

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
