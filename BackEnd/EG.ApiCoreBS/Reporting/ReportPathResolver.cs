namespace EG.ApiCoreBS.Reporting;

public static class ReportPathResolver
{
    public static string GetReportsRoot(string contentRootPath) =>
        Path.Combine(contentRootPath, ReportFolders.Root);

    public static bool TryNormalize(string? url, out string reportName)
    {
        reportName = string.Empty;
        if (string.IsNullOrWhiteSpace(url))
        {
            return false;
        }

        var normalized = url.Trim().Replace('\\', '/');
        if (normalized.EndsWith(".repx", StringComparison.OrdinalIgnoreCase))
        {
            normalized = normalized[..^5];
        }

        normalized = normalized.Trim('/');
        if (string.IsNullOrWhiteSpace(normalized) || Path.IsPathRooted(normalized))
        {
            return false;
        }

        var invalidFileNameChars = Path.GetInvalidFileNameChars();
        var segments = normalized.Split('/', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
        if (segments.Length == 0)
        {
            return false;
        }

        foreach (var segment in segments)
        {
            if (segment is "." or ".." || segment.IndexOfAny(invalidFileNameChars) >= 0)
            {
                return false;
            }
        }

        reportName = string.Join('/', segments);
        return true;
    }

    public static string GetReportPath(string contentRootPath, string reportName)
    {
        if (!TryNormalize(reportName, out var normalizedReportName))
        {
            throw new ArgumentException($"El nombre del reporte '{reportName}' no es valido.", nameof(reportName));
        }

        var reportsRoot = Path.GetFullPath(GetReportsRoot(contentRootPath));
        var relativeReportName = normalizedReportName.Contains('/', StringComparison.Ordinal)
            ? normalizedReportName
            : $"{ReportFolders.ExportedXml}/{normalizedReportName}";

        var reportPath = Path.GetFullPath(Path.Combine(
            reportsRoot,
            $"{relativeReportName.Replace('/', Path.DirectorySeparatorChar)}.repx"));

        if (!reportPath.StartsWith(reportsRoot, StringComparison.OrdinalIgnoreCase))
        {
            throw new ArgumentException($"El nombre del reporte '{reportName}' no es valido.", nameof(reportName));
        }

        return reportPath;
    }

    public static string GetReportNameFromPath(string contentRootPath, string reportPath)
    {
        var reportsRoot = GetReportsRoot(contentRootPath);
        var relativePath = Path.GetRelativePath(reportsRoot, reportPath);
        var reportName = Path.ChangeExtension(relativePath, null)
            .Replace(Path.DirectorySeparatorChar, '/')
            .Replace(Path.AltDirectorySeparatorChar, '/');

        var exportedXmlPrefix = $"{ReportFolders.ExportedXml}/";
        return reportName.StartsWith(exportedXmlPrefix, StringComparison.OrdinalIgnoreCase)
            ? reportName[exportedXmlPrefix.Length..]
            : reportName;
    }
}
