using System.Diagnostics;
using System.IO.Compression;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml.Linq;
using EG.Domain.DTOs.Requests.DocumentRag;
using EG.Domain.Platform.Settings;
using Microsoft.Extensions.Logging;

namespace EG.Application.Services.DocumentRag
{
    internal sealed class DocumentTextExtractionResult
    {
        public string Text { get; init; } = string.Empty;
        public string Status { get; init; } = "INDEXED";
        public string Message { get; init; } = "Documento indexado correctamente.";
    }

    internal static partial class DocumentTextExtractor
    {
        public static async Task<DocumentTextExtractionResult> ExtractAsync(
            DocumentRagUploadRequest request,
            DocumentRagSettings settings,
            ILogger logger)
        {
            var extension = NormalizeExtension(Path.GetExtension(request.NombreOriginal));
            DocumentTextExtractionResult result = extension switch
            {
                ".txt" or ".csv" or ".md" => ExtractPlainText(request.Contenido),
                ".docx" => ExtractDocx(request.Contenido),
                ".xlsx" => ExtractXlsx(request.Contenido),
                ".pdf" => ExtractPdf(request.Contenido),
                ".png" or ".jpg" or ".jpeg" or ".webp" or ".tif" or ".tiff" or ".bmp" =>
                    await ExtractImageTextAsync(request, settings, logger),
                ".doc" or ".xls" => new DocumentTextExtractionResult
                {
                    Status = "UNSUPPORTED",
                    Message = "Formato Office antiguo cargado, pero no indexado. Convierte el archivo a DOCX/XLSX para extraer texto."
                },
                _ => new DocumentTextExtractionResult
                {
                    Status = "UNSUPPORTED",
                    Message = $"La extension {extension} no tiene extractor configurado."
                }
            };

            var cleanText = NormalizeExtractedText(result.Text);
            if (string.IsNullOrWhiteSpace(cleanText) && result.Status == "INDEXED")
            {
                return new DocumentTextExtractionResult
                {
                    Status = "EMPTY",
                    Message = "El archivo se cargo, pero no se encontro texto para indexar."
                };
            }

            return new DocumentTextExtractionResult
            {
                Text = cleanText,
                Status = result.Status,
                Message = result.Message
            };
        }

        private static DocumentTextExtractionResult ExtractPlainText(byte[] content)
        {
            using var stream = new MemoryStream(content);
            using var reader = new StreamReader(stream, Encoding.UTF8, detectEncodingFromByteOrderMarks: true);
            return Indexed(reader.ReadToEnd());
        }

        private static DocumentTextExtractionResult ExtractDocx(byte[] content)
        {
            using var memory = new MemoryStream(content);
            using var archive = new ZipArchive(memory, ZipArchiveMode.Read);
            var builder = new StringBuilder();

            foreach (var entryName in GetWordEntryNames(archive))
            {
                var entry = archive.GetEntry(entryName);
                if (entry == null)
                    continue;

                using var stream = entry.Open();
                var document = XDocument.Load(stream);
                AppendWordXmlText(document, builder);
            }

            return Indexed(builder.ToString());
        }

        private static IEnumerable<string> GetWordEntryNames(ZipArchive archive)
        {
            if (archive.GetEntry("word/document.xml") != null)
                yield return "word/document.xml";

            foreach (var entry in archive.Entries
                .Where(x => x.FullName.StartsWith("word/header", StringComparison.OrdinalIgnoreCase)
                    || x.FullName.StartsWith("word/footer", StringComparison.OrdinalIgnoreCase))
                .OrderBy(x => x.FullName))
            {
                yield return entry.FullName;
            }
        }

        private static void AppendWordXmlText(XDocument document, StringBuilder builder)
        {
            foreach (var paragraph in document.Descendants().Where(x => x.Name.LocalName == "p"))
            {
                foreach (var node in paragraph.Descendants())
                {
                    if (node.Name.LocalName == "t")
                    {
                        builder.Append(node.Value);
                    }
                    else if (node.Name.LocalName == "tab")
                    {
                        builder.Append('\t');
                    }
                    else if (node.Name.LocalName is "br" or "cr")
                    {
                        builder.AppendLine();
                    }
                }

                builder.AppendLine();
            }
        }

        private static DocumentTextExtractionResult ExtractXlsx(byte[] content)
        {
            using var memory = new MemoryStream(content);
            using var archive = new ZipArchive(memory, ZipArchiveMode.Read);
            var sharedStrings = ReadSharedStrings(archive);
            var builder = new StringBuilder();

            foreach (var entry in archive.Entries
                .Where(x => x.FullName.StartsWith("xl/worksheets/sheet", StringComparison.OrdinalIgnoreCase)
                    && x.FullName.EndsWith(".xml", StringComparison.OrdinalIgnoreCase))
                .OrderBy(x => x.FullName))
            {
                builder.AppendLine(Path.GetFileNameWithoutExtension(entry.FullName));
                using var stream = entry.Open();
                var document = XDocument.Load(stream);

                foreach (var row in document.Descendants().Where(x => x.Name.LocalName == "row"))
                {
                    var values = row.Elements().Where(x => x.Name.LocalName == "c")
                        .Select(cell => ReadCellValue(cell, sharedStrings))
                        .Where(value => !string.IsNullOrWhiteSpace(value))
                        .ToList();

                    if (values.Count > 0)
                        builder.AppendLine(string.Join('\t', values));
                }

                builder.AppendLine();
            }

            return Indexed(builder.ToString());
        }

        private static List<string> ReadSharedStrings(ZipArchive archive)
        {
            var result = new List<string>();
            var entry = archive.GetEntry("xl/sharedStrings.xml");
            if (entry == null)
                return result;

            using var stream = entry.Open();
            var document = XDocument.Load(stream);
            foreach (var item in document.Descendants().Where(x => x.Name.LocalName == "si"))
            {
                result.Add(string.Concat(item.Descendants().Where(x => x.Name.LocalName == "t").Select(x => x.Value)));
            }

            return result;
        }

        private static string ReadCellValue(XElement cell, IReadOnlyList<string> sharedStrings)
        {
            var type = cell.Attribute("t")?.Value;
            if (type == "inlineStr")
                return string.Concat(cell.Descendants().Where(x => x.Name.LocalName == "t").Select(x => x.Value));

            var rawValue = cell.Elements().FirstOrDefault(x => x.Name.LocalName == "v")?.Value ?? string.Empty;
            if (type == "s" && int.TryParse(rawValue, out var sharedIndex) && sharedIndex >= 0 && sharedIndex < sharedStrings.Count)
                return sharedStrings[sharedIndex];

            return rawValue;
        }

        private static DocumentTextExtractionResult ExtractPdf(byte[] content)
        {
            var builder = new StringBuilder();
            foreach (var streamBytes in ReadPdfStreams(content))
            {
                var streamText = Encoding.Latin1.GetString(streamBytes);
                var extracted = ExtractPdfTextOperators(streamText);
                if (!string.IsNullOrWhiteSpace(extracted))
                    builder.AppendLine(extracted);
            }

            if (builder.Length == 0)
            {
                var fallback = ExtractPdfTextOperators(Encoding.Latin1.GetString(content));
                if (!string.IsNullOrWhiteSpace(fallback))
                    builder.AppendLine(fallback);
            }

            return Indexed(builder.ToString());
        }

        private static IEnumerable<byte[]> ReadPdfStreams(byte[] content)
        {
            var pdf = Encoding.Latin1.GetString(content);
            var searchIndex = 0;

            while (searchIndex < pdf.Length)
            {
                var streamIndex = pdf.IndexOf("stream", searchIndex, StringComparison.Ordinal);
                if (streamIndex < 0)
                    break;

                var endIndex = pdf.IndexOf("endstream", streamIndex + 6, StringComparison.Ordinal);
                if (endIndex < 0)
                    break;

                var dataStart = streamIndex + 6;
                if (dataStart < content.Length && content[dataStart] == '\r')
                    dataStart++;
                if (dataStart < content.Length && content[dataStart] == '\n')
                    dataStart++;

                var dataEnd = endIndex;
                while (dataEnd > dataStart && (content[dataEnd - 1] == '\r' || content[dataEnd - 1] == '\n'))
                    dataEnd--;

                if (dataEnd > dataStart && dataEnd <= content.Length)
                {
                    var streamBytes = content.AsSpan(dataStart, dataEnd - dataStart).ToArray();
                    var dictionaryStart = Math.Max(0, streamIndex - 1000);
                    var dictionary = pdf[dictionaryStart..streamIndex];
                    if (dictionary.Contains("/FlateDecode", StringComparison.Ordinal)
                        || dictionary.Contains("/Fl", StringComparison.Ordinal))
                    {
                        yield return TryDecompress(streamBytes);
                    }
                    else
                    {
                        yield return streamBytes;
                    }
                }

                searchIndex = endIndex + "endstream".Length;
            }
        }

        private static byte[] TryDecompress(byte[] streamBytes)
        {
            if (TryDecompressWithZLib(streamBytes, out var zlibBytes))
                return zlibBytes;

            if (TryDecompressWithDeflate(streamBytes, out var deflateBytes))
                return deflateBytes;

            return streamBytes;
        }

        private static bool TryDecompressWithZLib(byte[] streamBytes, out byte[] result)
        {
            try
            {
                using var input = new MemoryStream(streamBytes);
                using var zlib = new ZLibStream(input, CompressionMode.Decompress);
                using var output = new MemoryStream();
                zlib.CopyTo(output);
                result = output.ToArray();
                return result.Length > 0;
            }
            catch
            {
                result = [];
                return false;
            }
        }

        private static bool TryDecompressWithDeflate(byte[] streamBytes, out byte[] result)
        {
            try
            {
                using var input = new MemoryStream(streamBytes);
                using var deflate = new DeflateStream(input, CompressionMode.Decompress);
                using var output = new MemoryStream();
                deflate.CopyTo(output);
                result = output.ToArray();
                return result.Length > 0;
            }
            catch
            {
                result = [];
                return false;
            }
        }

        private static string ExtractPdfTextOperators(string content)
        {
            var builder = new StringBuilder();

            foreach (Match match in PdfLiteralTextRegex().Matches(content))
                AppendDecodedPdfText(builder, DecodePdfLiteral(match.Groups["value"].Value));

            foreach (Match match in PdfHexTextRegex().Matches(content))
                AppendDecodedPdfText(builder, DecodePdfHex(match.Groups["hex"].Value));

            foreach (Match arrayMatch in PdfArrayTextRegex().Matches(content))
            {
                foreach (Match itemMatch in PdfArrayItemRegex().Matches(arrayMatch.Groups["array"].Value))
                {
                    var text = itemMatch.Groups["value"].Success
                        ? DecodePdfLiteral(itemMatch.Groups["value"].Value)
                        : DecodePdfHex(itemMatch.Groups["hex"].Value);
                    AppendDecodedPdfText(builder, text, addSpace: false);
                }

                builder.AppendLine();
            }

            return builder.ToString();
        }

        private static void AppendDecodedPdfText(StringBuilder builder, string text, bool addSpace = true)
        {
            if (string.IsNullOrWhiteSpace(text))
                return;

            builder.Append(text);
            builder.Append(addSpace ? ' ' : string.Empty);
        }

        private static string DecodePdfLiteral(string value)
        {
            var bytes = new List<byte>(value.Length);
            for (var index = 0; index < value.Length; index++)
            {
                var current = value[index];
                if (current != '\\')
                {
                    bytes.Add((byte)(current & 0xFF));
                    continue;
                }

                if (++index >= value.Length)
                    break;

                var escaped = value[index];
                switch (escaped)
                {
                    case 'n':
                        bytes.Add((byte)'\n');
                        break;
                    case 'r':
                        bytes.Add((byte)'\r');
                        break;
                    case 't':
                        bytes.Add((byte)'\t');
                        break;
                    case 'b':
                        bytes.Add(0x08);
                        break;
                    case 'f':
                        bytes.Add(0x0C);
                        break;
                    case '(':
                    case ')':
                    case '\\':
                        bytes.Add((byte)escaped);
                        break;
                    case '\r':
                        if (index + 1 < value.Length && value[index + 1] == '\n')
                            index++;
                        break;
                    case '\n':
                        break;
                    default:
                        if (escaped is >= '0' and <= '7')
                        {
                            var octal = escaped.ToString();
                            for (var count = 0; count < 2 && index + 1 < value.Length && value[index + 1] is >= '0' and <= '7'; count++)
                                octal += value[++index];

                            bytes.Add(Convert.ToByte(octal, 8));
                        }
                        else
                        {
                            bytes.Add((byte)(escaped & 0xFF));
                        }

                        break;
                }
            }

            return DecodePdfBytes(bytes.ToArray());
        }

        private static string DecodePdfHex(string hex)
        {
            var clean = Regex.Replace(hex, @"\s+", string.Empty);
            if (clean.Length == 0)
                return string.Empty;
            if (clean.Length % 2 == 1)
                clean += "0";

            var bytes = new byte[clean.Length / 2];
            for (var index = 0; index < bytes.Length; index++)
                bytes[index] = Convert.ToByte(clean.Substring(index * 2, 2), 16);

            return DecodePdfBytes(bytes);
        }

        private static string DecodePdfBytes(byte[] bytes)
        {
            if (bytes.Length >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF)
                return Encoding.BigEndianUnicode.GetString(bytes, 2, bytes.Length - 2);

            if (bytes.Length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE)
                return Encoding.Unicode.GetString(bytes, 2, bytes.Length - 2);

            try
            {
                return new UTF8Encoding(encoderShouldEmitUTF8Identifier: false, throwOnInvalidBytes: true).GetString(bytes);
            }
            catch
            {
                return Encoding.Latin1.GetString(bytes);
            }
        }

        private static async Task<DocumentTextExtractionResult> ExtractImageTextAsync(
            DocumentRagUploadRequest request,
            DocumentRagSettings settings,
            ILogger logger)
        {
            if (string.IsNullOrWhiteSpace(settings.TesseractExePath) || !File.Exists(settings.TesseractExePath))
            {
                return new DocumentTextExtractionResult
                {
                    Status = "OCR_REQUIRED",
                    Message = "Imagen cargada, pero no se indexo texto porque Tesseract OCR no esta configurado en el servidor."
                };
            }

            var tempRoot = GetTempRoot(settings.TempPath);
            Directory.CreateDirectory(tempRoot);

            var extension = NormalizeExtension(Path.GetExtension(request.NombreOriginal));
            var inputPath = Path.Combine(tempRoot, $"{Guid.NewGuid():N}{extension}");

            try
            {
                await File.WriteAllBytesAsync(inputPath, request.Contenido);

                using var process = new Process();
                process.StartInfo = new ProcessStartInfo
                {
                    FileName = settings.TesseractExePath,
                    Arguments = $"\"{inputPath}\" stdout -l {settings.TesseractLanguage}",
                    CreateNoWindow = true,
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true
                };

                process.Start();
                var outputTask = process.StandardOutput.ReadToEndAsync();
                var errorTask = process.StandardError.ReadToEndAsync();

                if (!process.WaitForExit(60000))
                {
                    process.Kill(entireProcessTree: true);
                    return new DocumentTextExtractionResult
                    {
                        Status = "OCR_TIMEOUT",
                        Message = "La imagen se cargo, pero el OCR excedio el tiempo limite."
                    };
                }

                var output = await outputTask;
                var error = await errorTask;
                if (process.ExitCode != 0)
                {
                    logger.LogWarning("Tesseract OCR fallo con codigo {ExitCode}: {Error}", process.ExitCode, error);
                    return new DocumentTextExtractionResult
                    {
                        Status = "OCR_ERROR",
                        Message = "La imagen se cargo, pero el OCR no pudo extraer texto."
                    };
                }

                return Indexed(output);
            }
            finally
            {
                if (File.Exists(inputPath))
                    File.Delete(inputPath);
            }
        }

        private static string GetTempRoot(string configuredPath)
        {
            if (string.IsNullOrWhiteSpace(configuredPath))
                configuredPath = "RagTemp";

            return Path.IsPathRooted(configuredPath)
                ? Path.GetFullPath(configuredPath)
                : Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, configuredPath));
        }

        private static DocumentTextExtractionResult Indexed(string text) => new()
        {
            Text = text,
            Status = "INDEXED",
            Message = "Documento indexado correctamente."
        };

        private static string NormalizeExtractedText(string text)
        {
            if (string.IsNullOrWhiteSpace(text))
                return string.Empty;

            var normalized = text.Replace('\u0000', ' ')
                .Replace("\r\n", "\n", StringComparison.Ordinal)
                .Replace('\r', '\n');

            normalized = Regex.Replace(normalized, @"[ \t\f\v]+", " ");
            normalized = Regex.Replace(normalized, @"\n{3,}", "\n\n");
            return normalized.Trim();
        }

        private static string NormalizeExtension(string? value)
        {
            var extension = (value ?? string.Empty).Trim().ToLowerInvariant();
            return extension.StartsWith('.') ? extension : $".{extension}";
        }

        [GeneratedRegex(@"\((?<value>(?:\\.|[^\\)])*)\)\s*(?:Tj|'|"")", RegexOptions.Singleline)]
        private static partial Regex PdfLiteralTextRegex();

        [GeneratedRegex(@"(?<!<)<(?<hex>[0-9A-Fa-f\s]+)>\s*Tj", RegexOptions.Singleline)]
        private static partial Regex PdfHexTextRegex();

        [GeneratedRegex(@"\[(?<array>.*?)\]\s*TJ", RegexOptions.Singleline)]
        private static partial Regex PdfArrayTextRegex();

        [GeneratedRegex(@"\((?<value>(?:\\.|[^\\)])*)\)|(?<!<)<(?<hex>[0-9A-Fa-f\s]+)>", RegexOptions.Singleline)]
        private static partial Regex PdfArrayItemRegex();
    }
}
