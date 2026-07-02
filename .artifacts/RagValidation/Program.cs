using System.Reflection;
using System.Text;
using EG.Domain.DTOs.Requests.DocumentRag;
using EG.Domain.Settings;

const string pdfMarker = "PDF_RAG_VALIDACION_ELISEO_2026";
const string imagePngBase64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAFgwJ/lH5gAAAAAElFTkSuQmCC";

var extractorType = Type.GetType(
    "EG.Application.Services.DocumentRag.DocumentTextExtractor, EG.Application",
    throwOnError: true)!;
var method = extractorType.GetMethod("ExtractAsync", BindingFlags.Public | BindingFlags.Static)
    ?? throw new InvalidOperationException("No se encontro DocumentTextExtractor.ExtractAsync.");

var settings = new DocumentRagSettings
{
    TempPath = "RagTempValidation"
};

var pdfResult = await ExtractAsync(CreateRequest(
    "validacion-rag.pdf",
    "application/pdf",
    Encoding.Latin1.GetBytes(CreateSimplePdf(pdfMarker))));

var imageResult = await ExtractAsync(CreateRequest(
    "validacion-rag.png",
    "image/png",
    Convert.FromBase64String(imagePngBase64)));

Console.WriteLine($"PDF_STATUS={GetValue(pdfResult, "Status")}");
Console.WriteLine($"PDF_MESSAGE={GetValue(pdfResult, "Message")}");
Console.WriteLine($"PDF_TEXT={GetValue(pdfResult, "Text")}");
Console.WriteLine($"IMAGE_STATUS={GetValue(imageResult, "Status")}");
Console.WriteLine($"IMAGE_MESSAGE={GetValue(imageResult, "Message")}");

async Task<object> ExtractAsync(DocumentRagUploadRequest request)
{
    var task = (Task)method.Invoke(null, [request, settings, null])!;
    await task.ConfigureAwait(false);
    return task.GetType().GetProperty("Result")!.GetValue(task)!;
}

static DocumentRagUploadRequest CreateRequest(string name, string mime, byte[] content) => new()
{
    SessionId = Guid.NewGuid(),
    NombreOriginal = name,
    TipoMime = mime,
    TamanoBytes = content.Length,
    Contenido = content
};

static string GetValue(object instance, string property)
    => instance.GetType().GetProperty(property)!.GetValue(instance)?.ToString() ?? string.Empty;

static string CreateSimplePdf(string text)
{
    var stream = $"BT /F1 18 Tf 36 90 Td ({text}) Tj ET\n";
    return $"""
%PDF-1.4
1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj
2 0 obj << /Type /Pages /Kids [3 0 R] /Count 1 >> endobj
3 0 obj << /Type /Page /Parent 2 0 R /MediaBox [0 0 300 144] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >> endobj
4 0 obj << /Type /Font /Subtype /Type1 /BaseFont /Helvetica >> endobj
5 0 obj << /Length {stream.Length} >> stream
{stream}endstream endobj
xref
0 6
0000000000 65535 f 
trailer << /Root 1 0 R /Size 6 >>
startxref
0
%%EOF
""";
}
