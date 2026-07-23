using DevExpress.XtraReports.Services;
using EG.ApiCoreBS.Reporting;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.WebUtilities;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace EG.ApiCoreBS.Controllers.Reporting;

[ApiController]
[Authorize]
[Route("api/Reporting")]
public sealed class ReportingExportController : ControllerBase
{
    private readonly IReportProvider _reportProvider;
    private readonly IUserContextService _userContext;
    private readonly IAuthorizationService _authorization;

    public ReportingExportController(
        IReportProvider reportProvider,
        IUserContextService userContext,
        IAuthorizationService authorization)
    {
        _reportProvider = reportProvider;
        _userContext = userContext;
        _authorization = authorization;
    }

    [HttpGet("pdf")]
    public async Task<IActionResult> ExportPdf([FromQuery] string report)
    {
        if (string.IsNullOrWhiteSpace(report))
        {
            return BadRequest("El nombre del reporte es requerido.");
        }

        var reportName = report.Split('?', 2, StringSplitOptions.TrimEntries)[0];
        var requiredPolicy = GetReportPolicy(reportName);
        if (requiredPolicy == null ||
            !(await _authorization.AuthorizeAsync(User, null, requiredPolicy)).Succeeded)
        {
            return Forbid();
        }

        var enrichedReport = AddRequestContextParameters(report);
        var document = _reportProvider.GetReport(enrichedReport, null!);
        using var stream = new MemoryStream();
        document.CreateDocument();
        document.ExportToPdf(stream);

        var fileName = BuildFileName(report);
        return File(stream.ToArray(), "application/pdf", fileName);
    }

    private string AddRequestContextParameters(string report)
    {
        var parts = report.Split('?', 2, StringSplitOptions.TrimEntries);
        var reportName = parts[0];
        var parameters = new Dictionary<string, string?>(StringComparer.OrdinalIgnoreCase);

        if (parts.Length == 2)
        {
            foreach (var parameter in QueryHelpers.ParseQuery(parts[1]))
            {
                parameters[parameter.Key] = parameter.Value.ToString();
            }
        }

        SetContextParameter(parameters, "IdEmpleado", GetUserId());
        SetContextParameter(parameters, "IdEmpresa", _userContext.GetCurrentEmpresaId().ToString());

        var query = BuildQuery(parameters);
        return string.IsNullOrWhiteSpace(query) ? reportName : $"{reportName}?{query}";
    }

    private string? GetUserId() =>
        User.FindFirstValue(ClaimTypes.NameIdentifier)
        ?? User.FindFirstValue("sub")
        ?? User.FindFirstValue("nameid")
        ?? User.FindFirstValue("Id")
        ?? User.FindFirstValue("id");

    private static void SetContextParameter(
        IDictionary<string, string?> parameters,
        string parameterName,
        string? contextValue)
    {
        if (string.IsNullOrWhiteSpace(contextValue))
        {
            return;
        }

        parameters[parameterName] = contextValue;
    }

    private static string? GetReportPolicy(string reportName) => reportName switch
    {
        ReportKeys.Poliza => "Reportes_Contabilidad|Polizas|CanExportToExcel",
        ReportKeys.PaaasHelloWorld => "PBR|PBR|CanExportToExcel",
        _ => null
    };

    private static string BuildQuery(IReadOnlyDictionary<string, string?> values) =>
        string.Join("&",
            values
                .Where(value => !string.IsNullOrWhiteSpace(value.Key) && !string.IsNullOrWhiteSpace(value.Value))
                .Select(value => $"{Uri.EscapeDataString(value.Key)}={Uri.EscapeDataString(value.Value!)}"));

    private static string BuildFileName(string report)
    {
        var name = report.Split('?', 2)[0];
        var invalidChars = Path.GetInvalidFileNameChars();
        var safeName = new string(name.Select(character =>
            invalidChars.Contains(character) ? '_' : character).ToArray());

        return string.IsNullOrWhiteSpace(safeName)
            ? "reporte.pdf"
            : $"{safeName}.pdf";
    }
}
