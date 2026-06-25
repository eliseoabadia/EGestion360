using DevExpress.XtraPrinting;
using DevExpress.XtraPrinting.Drawing;
using DevExpress.XtraReports.UI;
using System.Globalization;

namespace EG.ApiCoreBS.Reporting;

public sealed class ReportLogoConfigurator
{
    private static readonly string[] ImageExtensions = [".png", ".jpg", ".jpeg", ".webp"];

    private readonly IWebHostEnvironment _environment;
    private readonly IConfiguration _configuration;
    private readonly ILogger<ReportLogoConfigurator> _logger;

    public ReportLogoConfigurator(
        IWebHostEnvironment environment,
        IConfiguration configuration,
        ILogger<ReportLogoConfigurator> logger)
    {
        _environment = environment;
        _configuration = configuration;
        _logger = logger;
    }

    public void Apply(XtraReport report, string reportName)
    {
        var logoPath = ResolveLogoPath();
        if (string.IsNullOrWhiteSpace(logoPath))
        {
            _logger.LogWarning("No se encontro el logo para el reporte {ReportName}.", reportName);
            return;
        }

        var pictureBoxName = _configuration["Reporting:LogoPictureBoxName"] ?? "xrPictureBox1";
        foreach (var pictureBox in EnumerateControls(report).OfType<XRPictureBox>())
        {
            if (!IsLogoPictureBox(pictureBox, pictureBoxName))
            {
                continue;
            }

            pictureBox.ImageSource = ImageSource.FromFile(logoPath);
            pictureBox.Sizing = ImageSizeMode.ZoomImage;

            if (string.Equals(reportName, ReportKeys.Poliza, StringComparison.OrdinalIgnoreCase))
            {
                ApplyConfiguredLayout(pictureBox);
            }
        }
    }

    private static bool IsLogoPictureBox(XRPictureBox pictureBox, string pictureBoxName) =>
        string.Equals(pictureBox.Name, pictureBoxName, StringComparison.OrdinalIgnoreCase) ||
        pictureBox.Name.StartsWith("xrPictureBox", StringComparison.OrdinalIgnoreCase);

    private void ApplyConfiguredLayout(XRPictureBox pictureBox)
    {
        var section = _configuration.GetSection("Reporting:PolizaLogo");
        pictureBox.LeftF = GetFloat(section, "Left", pictureBox.LeftF);
        pictureBox.TopF = GetFloat(section, "Top", pictureBox.TopF);
        pictureBox.WidthF = GetFloat(section, "Width", pictureBox.WidthF);
        pictureBox.HeightF = GetFloat(section, "Height", pictureBox.HeightF);
    }

    private string? ResolveLogoPath()
    {
        var configuredPath = _configuration["Reporting:LogoPath"];
        var configuredFileName = _configuration["Reporting:LogoFileName"] ?? "logo_ift_horizontal.png";

        if (!string.IsNullOrWhiteSpace(configuredPath))
        {
            var resolvedPath = ResolveConfiguredPath(configuredPath, configuredFileName);
            if (!string.IsNullOrWhiteSpace(resolvedPath))
            {
                return resolvedPath;
            }
        }

        foreach (var imageFolder in EnumerateImageFolders())
        {
            var configuredLogo = Path.Combine(imageFolder, configuredFileName);
            if (File.Exists(configuredLogo))
            {
                return configuredLogo;
            }

            var firstImage = Directory
                .EnumerateFiles(imageFolder)
                .FirstOrDefault(file => ImageExtensions.Contains(Path.GetExtension(file), StringComparer.OrdinalIgnoreCase));

            if (!string.IsNullOrWhiteSpace(firstImage))
            {
                return firstImage;
            }
        }

        return null;
    }

    private string? ResolveConfiguredPath(string configuredPath, string configuredFileName)
    {
        var candidate = Path.IsPathRooted(configuredPath)
            ? configuredPath
            : Path.GetFullPath(Path.Combine(_environment.ContentRootPath, configuredPath));

        if (File.Exists(candidate))
        {
            return candidate;
        }

        if (Directory.Exists(candidate))
        {
            var logoPath = Path.Combine(candidate, configuredFileName);
            return File.Exists(logoPath)
                ? logoPath
                : Directory
                    .EnumerateFiles(candidate)
                    .FirstOrDefault(file => ImageExtensions.Contains(Path.GetExtension(file), StringComparer.OrdinalIgnoreCase));
        }

        return null;
    }

    private static float GetFloat(IConfiguration section, string key, float defaultValue)
    {
        var value = section[key];
        return float.TryParse(value, NumberStyles.Float, CultureInfo.InvariantCulture, out var parsed)
            ? parsed
            : defaultValue;
    }

    private IEnumerable<string> EnumerateImageFolders()
    {
        var starts = new[]
        {
            _environment.ContentRootPath,
            AppContext.BaseDirectory
        };

        var visited = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var start in starts)
        {
            var directory = new DirectoryInfo(start);
            while (directory != null)
            {
                var frontEndImgPath = Path.Combine(directory.FullName, "FrontEnd", "EG.Web", "wwwroot", "img");
                if (visited.Add(frontEndImgPath) && Directory.Exists(frontEndImgPath))
                {
                    yield return frontEndImgPath;
                }

                var localImgPath = Path.Combine(directory.FullName, "wwwroot", "img");
                if (visited.Add(localImgPath) && Directory.Exists(localImgPath))
                {
                    yield return localImgPath;
                }

                directory = directory.Parent;
            }
        }
    }

    private static IEnumerable<XRControl> EnumerateControls(XtraReport report)
    {
        foreach (Band band in report.Bands)
        {
            foreach (var control in EnumerateControls(band.Controls))
            {
                yield return control;
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
}
