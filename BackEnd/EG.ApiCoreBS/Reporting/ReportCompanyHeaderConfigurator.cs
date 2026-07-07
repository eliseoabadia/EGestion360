using DevExpress.XtraReports.Parameters;
using DevExpress.XtraReports.UI;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;
using System.Text.RegularExpressions;

namespace EG.ApiCoreBS.Reporting;

public sealed class ReportCompanyHeaderConfigurator
{
    private static readonly string[] CompanyNameParameters =
    [
        "EmpresaNombre",
        "NombreEmpresa",
        "CompanyName"
    ];

    private static readonly string[] CompanyShortNameParameters =
    [
        "EmpresaNombreCorto",
        "NombreCortoEmpresa",
        "CompanyShortName"
    ];

    private static readonly string[] CompanyLegalNameParameters =
    [
        "EmpresaRazonSocial",
        "RazonSocial",
        "RazonSocialEmpresa",
        "CompanyLegalName"
    ];

    private static readonly string[] CompanyRfcParameters =
    [
        "EmpresaRfc",
        "RfcEmpresa",
        "RFC",
        "CompanyRfc"
    ];

    private readonly EGestionContext _context;
    private readonly ILogger<ReportCompanyHeaderConfigurator> _logger;

    public ReportCompanyHeaderConfigurator(
        EGestionContext context,
        ILogger<ReportCompanyHeaderConfigurator> logger)
    {
        _context = context;
        _logger = logger;
    }

    public void Apply(XtraReport report, ReportRequest request)
    {
        if (!TryGetEmpresaId(request, out var empresaId))
        {
            return;
        }

        var company = LoadCompany(empresaId);
        if (company == null)
        {
            _logger.LogWarning(
                "No se encontro la empresa {EmpresaId} para actualizar encabezados del reporte {ReportName}.",
                empresaId,
                request.Name);
            return;
        }

        EnsureCompanyParameters(report, company);
        var updatedLabels = ApplyCompanyText(report, company);

        if (updatedLabels > 0)
        {
            _logger.LogInformation(
                "Encabezado de empresa actualizado en reporte {ReportName}. Empresa: {EmpresaName}. Controles: {UpdatedLabels}.",
                request.Name,
                company.Name,
                updatedLabels);
        }
    }

    private ReportCompanyHeader? LoadCompany(int empresaId)
    {
        return _context.Empresas
            .AsNoTracking()
            .Where(item => item.PkidEmpresa == empresaId)
            .Select(item => new ReportCompanyHeader(
                FirstNotBlank(item.Nombre, item.RazonSocial, item.NombreCorto),
                FirstNotBlank(item.NombreCorto, item.Nombre, item.RazonSocial),
                FirstNotBlank(item.RazonSocial, item.Nombre, item.NombreCorto),
                item.Rfc ?? string.Empty))
            .FirstOrDefault();
    }

    private static void EnsureCompanyParameters(XtraReport report, ReportCompanyHeader company)
    {
        SetStringParameters(report, CompanyNameParameters, company.Name);
        SetStringParameters(report, CompanyShortNameParameters, company.ShortName);
        SetStringParameters(report, CompanyLegalNameParameters, company.LegalName);
        SetStringParameters(report, CompanyRfcParameters, company.Rfc);
    }

    private static void SetStringParameters(XtraReport report, IEnumerable<string> parameterNames, string value)
    {
        foreach (var parameterName in parameterNames)
        {
            var parameter = report.Parameters[parameterName];
            if (parameter == null)
            {
                parameter = new Parameter
                {
                    Name = parameterName,
                    Type = typeof(string)
                };
                report.Parameters.Add(parameter);
            }

            parameter.Type = typeof(string);
            parameter.Value = value;
            parameter.Visible = false;
        }
    }

    private static int ApplyCompanyText(XtraReport report, ReportCompanyHeader company)
    {
        var updated = 0;

        foreach (var (label, band) in EnumerateLabels(report))
        {
            updated += ApplyExpressionBindings(label, company);

            if (!IsHeaderBand(band))
            {
                continue;
            }

            var replacedText = ReplaceCompanyTokens(label.Text, company, false);
            if (!string.Equals(label.Text, replacedText, StringComparison.Ordinal))
            {
                label.Text = replacedText;
                updated++;
                continue;
            }

            if (IsCompanyIdentityLabel(label))
            {
                label.Text = company.Name;
                updated++;
            }
        }

        return updated;
    }

    private static int ApplyExpressionBindings(XRLabel label, ReportCompanyHeader company)
    {
        var updated = 0;

        foreach (ExpressionBinding binding in label.ExpressionBindings)
        {
            if (!string.Equals(binding.PropertyName, nameof(XRLabel.Text), StringComparison.OrdinalIgnoreCase) ||
                string.IsNullOrWhiteSpace(binding.Expression))
            {
                continue;
            }

            var expression = ReplaceCompanyTokens(binding.Expression, company, true);
            if (string.Equals(binding.Expression, expression, StringComparison.Ordinal))
            {
                continue;
            }

            binding.Expression = expression;
            updated++;
        }

        return updated;
    }

    private static bool IsCompanyIdentityLabel(XRLabel label)
    {
        var key = Normalize($"{label.Name} {label.Text}");
        return key.Contains("razonsocial") ||
               key.Contains("razon social") ||
               key.Contains("empresa nombre") ||
               key.Contains("nombreempresa") ||
               key.Contains("companyname") ||
               key.Contains("institucion") ||
               key.Contains("ente publico") ||
               key.Contains("organismo");
    }

    private static string ReplaceCompanyTokens(string? value, ReportCompanyHeader company, bool escapeForExpression)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return value ?? string.Empty;
        }

        var companyName = escapeForExpression
            ? EscapeDevExpressExpressionText(company.Name)
            : company.Name;

        var result = value;
        result = ReplaceLiteral(result, "Plataforma de Compras Integral", companyName);
        result = ReplaceLiteral(result, "Instituto Federal de Telecomunicaciones", companyName);
        result = ReplacePattern(result, @"\bIFT\b", companyName);
        result = ReplacePattern(result, @"\bPCI\b", companyName);
        return result;
    }

    private static string ReplaceLiteral(string source, string oldValue, string newValue) =>
        ReplacePattern(source, Regex.Escape(oldValue), newValue);

    private static string ReplacePattern(string source, string pattern, string newValue) =>
        Regex.Replace(source, pattern, _ => newValue, RegexOptions.IgnoreCase);

    private static string EscapeDevExpressExpressionText(string value) =>
        value.Replace("'", "''");

    private static bool IsHeaderBand(Band band) =>
        band is ReportHeaderBand or PageHeaderBand or TopMarginBand;

    private static IEnumerable<(XRLabel Label, Band Band)> EnumerateLabels(XtraReport report)
    {
        foreach (Band band in report.Bands)
        {
            foreach (var label in EnumerateControls(band.Controls).OfType<XRLabel>())
            {
                yield return (label, band);
            }
        }
    }

    private static IEnumerable<XRControl> EnumerateControls(XRControlCollection controls)
    {
        foreach (XRControl control in controls)
        {
            yield return control;

            foreach (var child in EnumerateControls(control.Controls))
            {
                yield return child;
            }
        }
    }

    private static bool TryGetEmpresaId(ReportRequest request, out int empresaId)
    {
        var value = request.GetValue("IdEmpresa");
        return int.TryParse(value, out empresaId) && empresaId > 0;
    }

    private static string FirstNotBlank(params string?[] values) =>
        values.FirstOrDefault(value => !string.IsNullOrWhiteSpace(value))?.Trim() ?? string.Empty;

    private static string Normalize(string value) =>
        value.Replace("_", string.Empty)
            .Replace("-", string.Empty)
            .Trim()
            .ToLowerInvariant();

    private sealed record ReportCompanyHeader(string Name, string ShortName, string LegalName, string Rfc);
}
