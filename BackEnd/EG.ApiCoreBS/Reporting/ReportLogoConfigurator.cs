using DevExpress.Drawing;
using DevExpress.XtraPrinting;
using DevExpress.XtraPrinting.Drawing;
using DevExpress.XtraReports.UI;
using EG.Domain.Platform.Settings;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using System.Drawing;
using System.Drawing.Imaging;
using System.Globalization;
using System.Xml.Linq;

namespace EG.ApiCoreBS.Reporting;

public sealed class ReportLogoConfigurator
{
    private const string DatabaseMode = "DATABASE";
    private const string FileSystemMode = "FILESYSTEM";
    private static readonly string[] ImageExtensions = [".png", ".jpg", ".jpeg", ".webp"];

    private readonly IWebHostEnvironment _environment;
    private readonly IConfiguration _configuration;
    private readonly DocumentStorageSettings _storageSettings;
    private readonly EGestionContext _context;
    private readonly ILogger<ReportLogoConfigurator> _logger;

    public ReportLogoConfigurator(
        IWebHostEnvironment environment,
        IConfiguration configuration,
        IOptions<DocumentStorageSettings> storageOptions,
        EGestionContext context,
        ILogger<ReportLogoConfigurator> logger)
    {
        _environment = environment;
        _configuration = configuration;
        _storageSettings = storageOptions.Value;
        _context = context;
        _logger = logger;
    }

    public void Apply(XtraReport report, ReportRequest request)
    {
        var logos = ResolveLogos(request).ToList();
        if (logos.Count == 0)
        {
            _logger.LogWarning("No se encontro el logo para el reporte {ReportName}.", request.Name);
            return;
        }

        var pictureBoxName = _configuration["Reporting:LogoPictureBoxName"] ?? "xrPictureBox1";
        var matchedPictureBoxes = 0;
        var appliedLogo = false;

        foreach (var pictureBox in EnumerateControls(report).OfType<XRPictureBox>())
        {
            if (!IsLogoPictureBox(pictureBox, pictureBoxName))
            {
                continue;
            }

            matchedPictureBoxes++;

            var logoAppliedToControl = false;
            foreach (var logo in logos)
            {
                if (!TryApplyLogo(pictureBox, logo))
                {
                    continue;
                }

                logoAppliedToControl = true;
                appliedLogo = true;
                break;
            }

            if (!logoAppliedToControl)
            {
                _logger.LogWarning(
                    "No fue posible aplicar logo en el control {PictureBoxName} del reporte {ReportName}.",
                    pictureBox.Name,
                    request.Name);
            }

            pictureBox.Sizing = ImageSizeMode.ZoomImage;

            if (string.Equals(request.Name, ReportKeys.Poliza, StringComparison.OrdinalIgnoreCase))
            {
                ApplyConfiguredLayout(pictureBox);
            }
        }

        if (matchedPictureBoxes == 0)
        {
            _logger.LogWarning(
                "El reporte {ReportName} no contiene un XRPictureBox compatible con {PictureBoxName}.",
                request.Name,
                pictureBoxName);
        }
        else if (!appliedLogo)
        {
            _logger.LogWarning(
                "El reporte {ReportName} tiene controles de logo, pero ninguna fuente de imagen pudo cargarse.",
                request.Name);
        }
    }

    public byte[] ApplyToLayout(byte[] reportLayout, ReportRequest request)
    {
        var content = ResolveLogoContent(request);
        if (content is not { Length: > 0 })
        {
            return reportLayout;
        }

        try
        {
            var pictureBoxName = _configuration["Reporting:LogoPictureBoxName"] ?? "xrPictureBox1";
            using var input = new MemoryStream(reportLayout);
            var layout = XDocument.Load(input, LoadOptions.PreserveWhitespace);
            var reportLogoContent = NormalizeLogoContent(content);
            var imageSource = $"img,{Convert.ToBase64String(reportLogoContent)}";
            var updated = 0;

            foreach (var element in layout.Descendants().Where(element => IsLogoPictureBoxElement(element, pictureBoxName)))
            {
                element.SetAttributeValue("ImageSource", imageSource);
                element.SetAttributeValue("Sizing", "ZoomImage");

                if (string.Equals(request.Name, ReportKeys.Poliza, StringComparison.OrdinalIgnoreCase))
                {
                    ApplyConfiguredLayout(element);
                }

                updated++;
            }

            if (updated == 0)
            {
                _logger.LogWarning(
                    "El layout del reporte {ReportName} no contiene un XRPictureBox compatible con {PictureBoxName}.",
                    request.Name,
                    pictureBoxName);
                return reportLayout;
            }

            using var output = new MemoryStream();
            layout.Save(output, SaveOptions.DisableFormatting);
            _logger.LogInformation(
                "Logo incrustado en layout del reporte {ReportName}. Controles actualizados: {UpdatedLogoControls}.",
                request.Name,
                updated);
            return output.ToArray();
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "No fue posible incrustar el logo en el layout del reporte {ReportName}.", request.Name);
            return reportLayout;
        }
    }

    private static bool IsLogoPictureBox(XRPictureBox pictureBox, string pictureBoxName) =>
        string.Equals(pictureBox.Name, pictureBoxName, StringComparison.OrdinalIgnoreCase) ||
        pictureBox.Name.StartsWith("xrPictureBox", StringComparison.OrdinalIgnoreCase);

    private static bool IsLogoPictureBoxElement(XElement element, string pictureBoxName)
    {
        var controlType = element.Attribute("ControlType")?.Value;
        if (!string.Equals(controlType, "XRPictureBox", StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }

        var name = element.Attribute("Name")?.Value;
        return !string.IsNullOrWhiteSpace(name) &&
               (string.Equals(name, pictureBoxName, StringComparison.OrdinalIgnoreCase) ||
                name.StartsWith("xrPictureBox", StringComparison.OrdinalIgnoreCase));
    }

    private byte[]? ResolveLogoContent(ReportRequest request)
    {
        foreach (var logo in ResolveLogos(request))
        {
            if (logo.Content is { Length: > 0 })
            {
                return logo.Content;
            }

            if (!string.IsNullOrWhiteSpace(logo.FilePath) && File.Exists(logo.FilePath))
            {
                try
                {
                    return File.ReadAllBytes(logo.FilePath);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "No fue posible leer el archivo de logo {LogoPath}.", logo.FilePath);
                }
            }
        }

        return null;
    }

    private static byte[] NormalizeLogoContent(byte[] content)
    {
        using var input = new MemoryStream(content);
        using var image = Image.FromStream(input);
        using var canvas = new Bitmap(image.Width, image.Height);
        using (var graphics = Graphics.FromImage(canvas))
        {
            graphics.Clear(Color.White);
            graphics.DrawImage(image, 0, 0, image.Width, image.Height);
        }

        using var output = new MemoryStream();
        canvas.Save(output, ImageFormat.Jpeg);
        return output.ToArray();
    }

    private bool TryApplyLogo(XRPictureBox pictureBox, ResolvedLogo logo)
    {
        if (logo.Content is { Length: > 0 })
        {
            return TryApplyImageBytes(pictureBox, logo.Content, logo.Source);
        }

        if (!string.IsNullOrWhiteSpace(logo.FilePath))
        {
            return TryApplyImageFile(pictureBox, logo.FilePath, logo.Source);
        }

        if (!string.IsNullOrWhiteSpace(logo.Url))
        {
            _logger.LogWarning(
                "El logo {LogoUrl} es una URL externa y no se incrustara directo en el PDF; se intentara la siguiente fuente disponible.",
                logo.Url);
            return false;
        }

        return false;
    }

    private bool TryApplyImageFile(XRPictureBox pictureBox, string filePath, string source)
    {
        try
        {
            var resolvedPath = Path.GetFullPath(filePath);
            if (!File.Exists(resolvedPath))
            {
                _logger.LogWarning("No existe el archivo de logo {LogoPath}. Fuente: {LogoSource}.", resolvedPath, source);
                return false;
            }

            var content = File.ReadAllBytes(resolvedPath);
            return TryApplyImageBytes(pictureBox, content, resolvedPath);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "No fue posible leer el archivo de logo {LogoPath}. Fuente: {LogoSource}.", filePath, source);
            return false;
        }
    }

    private bool TryApplyImageBytes(XRPictureBox pictureBox, byte[] content, string source)
    {
        try
        {
            ApplyImageBytesSource(pictureBox, content);
            pictureBox.BeforePrint += (_, _) => ApplyImageBytesSource(pictureBox, content);
            _logger.LogInformation("Logo aplicado en reporte desde {LogoSource}.", source);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "No fue posible cargar el logo desde {LogoSource}.", source);
            return false;
        }
    }

    private static void ApplyImageBytesSource(XRPictureBox pictureBox, byte[] content)
    {
        using var stream = new MemoryStream(content);
        pictureBox.Visible = true;
        pictureBox.ImageSource = new ImageSource(DXImage.FromStream(stream));
        pictureBox.ImageUrl = null;
        pictureBox.Image = null;
    }

    private void ApplyConfiguredLayout(XRPictureBox pictureBox)
    {
        var section = _configuration.GetSection("Reporting:PolizaLogo");
        pictureBox.LeftF = GetFloat(section, "Left", pictureBox.LeftF);
        pictureBox.TopF = GetFloat(section, "Top", pictureBox.TopF);
        pictureBox.WidthF = GetFloat(section, "Width", pictureBox.WidthF);
        pictureBox.HeightF = GetFloat(section, "Height", pictureBox.HeightF);
    }

    private void ApplyConfiguredLayout(XElement pictureBox)
    {
        var section = _configuration.GetSection("Reporting:PolizaLogo");
        var left = GetFloat(section, "Left", 0);
        var top = GetFloat(section, "Top", 25);
        var width = GetFloat(section, "Width", 430);
        var height = GetFloat(section, "Height", 145);

        pictureBox.SetAttributeValue("LocationFloat", FormatPoint(left, top));
        pictureBox.SetAttributeValue("SizeF", FormatPoint(width, height));
    }

    private IEnumerable<ResolvedLogo> ResolveLogos(ReportRequest request)
    {
        foreach (var companyLogo in ResolveCompanyLogos(request))
        {
            yield return companyLogo;
        }

        var fallbackPath = ResolveLogoPath();
        if (!string.IsNullOrWhiteSpace(fallbackPath))
        {
            yield return ResolvedLogo.FromFile(fallbackPath, "logo neutral configurado");
        }
    }

    private IEnumerable<ResolvedLogo> ResolveCompanyLogos(ReportRequest request)
    {
        if (!TryGetEmpresaId(request, out var empresaId))
        {
            yield break;
        }

        var empresa = _context.Empresas
            .AsNoTracking()
            .Where(item => item.PkidEmpresa == empresaId)
            .Select(item => new
            {
                item.Logo,
                item.LogoEmpresa
            })
            .FirstOrDefault();

        if (empresa == null)
        {
            yield break;
        }

        var mode = NormalizeStorageMode(_storageSettings.Mode);
        if (mode == DatabaseMode && empresa.LogoEmpresa is { Length: > 0 })
        {
            yield return ResolvedLogo.FromBytes(empresa.LogoEmpresa, "SIS.Empresa.LogoEmpresa");
        }

        var fileLogo = ResolveFileSystemLogo(empresa.Logo);
        if (fileLogo != null)
        {
            yield return fileLogo;
        }

        if (mode == FileSystemMode && empresa.LogoEmpresa is { Length: > 0 })
        {
            yield return ResolvedLogo.FromBytes(empresa.LogoEmpresa, "SIS.Empresa.LogoEmpresa");
        }
    }

    private ResolvedLogo? ResolveFileSystemLogo(string? logo)
    {
        if (string.IsNullOrWhiteSpace(logo))
        {
            return null;
        }

        var value = logo.Trim();
        if (Uri.TryCreate(value, UriKind.Absolute, out var uri))
        {
            if (uri.IsFile && File.Exists(uri.LocalPath))
            {
                return ResolvedLogo.FromFile(uri.LocalPath, "SIS.Empresa.Logo");
            }

            if (uri.Scheme is "http" or "https")
            {
                var localPathLogo = ResolveLogoValuePath(uri.LocalPath);
                if (!string.IsNullOrWhiteSpace(localPathLogo))
                {
                    return ResolvedLogo.FromFile(localPathLogo, "SIS.Empresa.Logo");
                }

                return ResolvedLogo.FromUrl(value, "SIS.Empresa.Logo");
            }
        }

        var resolvedPath = ResolveLogoValuePath(value);
        return string.IsNullOrWhiteSpace(resolvedPath)
            ? null
            : ResolvedLogo.FromFile(resolvedPath, "SIS.Empresa.Logo");
    }

    private string? ResolveLogoValuePath(string logo)
    {
        var normalized = logo
            .Replace('/', Path.DirectorySeparatorChar)
            .Replace('\\', Path.DirectorySeparatorChar)
            .TrimStart('~', Path.DirectorySeparatorChar);

        if (Path.IsPathRooted(normalized) && File.Exists(normalized))
        {
            return normalized;
        }

        foreach (var root in EnumerateLogoRoots())
        {
            var candidate = Path.GetFullPath(Path.Combine(root, normalized));
            if (File.Exists(candidate))
            {
                return candidate;
            }
        }

        return null;
    }

    private IEnumerable<string> EnumerateLogoRoots()
    {
        var roots = new[]
        {
            _storageSettings.BasePath,
            _environment.WebRootPath,
            _environment.ContentRootPath,
            AppContext.BaseDirectory
        };

        var visited = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var root in roots)
        {
            if (string.IsNullOrWhiteSpace(root))
            {
                continue;
            }

            var fullPath = Path.IsPathRooted(root)
                ? Path.GetFullPath(root)
                : Path.GetFullPath(Path.Combine(_environment.ContentRootPath, root));

            if (visited.Add(fullPath) && Directory.Exists(fullPath))
            {
                yield return fullPath;
            }
        }

        foreach (var imageFolder in EnumerateImageFolders())
        {
            if (visited.Add(imageFolder))
            {
                yield return imageFolder;
            }

            var wwwRoot = Directory.GetParent(imageFolder)?.FullName;
            if (!string.IsNullOrWhiteSpace(wwwRoot) && visited.Add(wwwRoot))
            {
                yield return wwwRoot;
            }
        }
    }

    private static bool TryGetEmpresaId(ReportRequest request, out int empresaId)
    {
        var value = request.GetValue("IdEmpresa");
        return int.TryParse(value, out empresaId) && empresaId > 0;
    }

    private static string NormalizeStorageMode(string? value)
    {
        var mode = (value ?? DatabaseMode).Trim().ToUpperInvariant();
        return mode == FileSystemMode ? FileSystemMode : DatabaseMode;
    }

    private string? ResolveLogoPath()
    {
        var configuredPath = _configuration["Reporting:LogoPath"];
        var configuredFileName = _configuration["Reporting:LogoFileName"] ?? "logo_egestion_empresarial_horizontal.png";

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

    private static string FormatPoint(float first, float second) =>
        $"{first.ToString(CultureInfo.InvariantCulture)},{second.ToString(CultureInfo.InvariantCulture)}";

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

    private sealed record ResolvedLogo(string? FilePath, byte[]? Content, string? Url, string Source)
    {
        public static ResolvedLogo FromFile(string filePath, string source) => new(filePath, null, null, source);
        public static ResolvedLogo FromBytes(byte[] content, string source) => new(null, content, null, source);
        public static ResolvedLogo FromUrl(string url, string source) => new(null, null, url, source);
    }
}
