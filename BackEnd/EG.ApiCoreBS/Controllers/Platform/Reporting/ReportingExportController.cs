using DevExpress.XtraReports.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Reporting;

[ApiController]
[Authorize]
[Route("api/Reporting")]
public sealed class ReportingExportController : ControllerBase
{
    private readonly IReportProvider _reportProvider;

    public ReportingExportController(IReportProvider reportProvider)
    {
        _reportProvider = reportProvider;
    }

    [HttpGet("pdf")]
    public IActionResult ExportPdf([FromQuery] string report)
    {
        if (string.IsNullOrWhiteSpace(report))
        {
            return BadRequest("El nombre del reporte es requerido.");
        }

        var document = _reportProvider.GetReport(report, null!);
        using var stream = new MemoryStream();
        document.ExportToPdf(stream);

        var fileName = BuildFileName(report);
        return File(stream.ToArray(), "application/pdf", fileName);
    }

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
