using System.Globalization;
using System.IO.Compression;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml.Linq;
using EG.Domain.DTOs.Requests.Contabilidad;

namespace EG.ApiCoreBS.Services.Contabilidad
{
    internal sealed class PolizaAiParsedDocument
    {
        public Dictionary<string, string> HeaderValues { get; } = new(StringComparer.OrdinalIgnoreCase);
        public List<PolizaAiImportDetailRequest> Details { get; } = [];
        public List<PolizaAiImportValidationMessage> Messages { get; } = [];
        public List<string> DetectedColumns { get; } = [];
    }

    internal static class PolizaAiImportParser
    {
        private static readonly Dictionary<string, string[]> DetailAliases = new(StringComparer.OrdinalIgnoreCase)
        {
            ["Cuenta"] = ["cuenta", "cuentacontable", "cta", "ctacontable", "clavecuenta", "cuentaid"],
            ["Descripcion"] = ["descripcion", "concepto", "detalle", "glosa", "referencia", "observacion"],
            ["Debe"] = ["debe", "cargo", "cargos", "importedebe", "importecargo", "debit", "debitamount"],
            ["Haber"] = ["haber", "abono", "abonos", "importehaber", "importeabono", "credit", "creditamount"],
            ["Importe"] = ["importe", "monto", "amount", "valor"],
            ["Naturaleza"] = ["naturaleza", "movimiento", "tipomovimiento", "cargoabono", "debehaber"],
            ["TipoDetalle"] = ["tipodetalle", "tipodetallepoliza", "clavetipo"],
            ["ClavePoliza"] = ["clavepoliza", "poliza", "clave"],
            ["NombrePoliza"] = ["nombrepoliza", "nombre", "descripcionpoliza", "conceptopoliza"],
            ["FechaPoliza"] = ["fechapoliza", "fecha"],
            ["TipoPoliza"] = ["tipopoliza", "tipodepoliza", "tipo"],
            ["Anio"] = ["anio", "ano", "ejercicio"],
            ["Mes"] = ["mes", "periodo"]
        };

        private static readonly HashSet<string> HeaderKeys = new(StringComparer.OrdinalIgnoreCase)
        {
            "ClavePoliza", "NombrePoliza", "FechaPoliza", "TipoPoliza", "Anio", "Mes"
        };

        public static PolizaAiParsedDocument Parse(string fileName, byte[] content)
        {
            var extension = NormalizeExtension(Path.GetExtension(fileName));
            var rows = extension switch
            {
                ".xlsx" => ReadXlsxRows(content),
                ".csv" or ".txt" => ReadDelimitedRows(content),
                _ => []
            };

            var result = new PolizaAiParsedDocument();
            if (rows.Count == 0)
            {
                result.Messages.Add(Error("EMPTY_FILE", "No se encontro contenido tabular para analizar."));
                return result;
            }

            var headerRowIndex = FindHeaderRow(rows);
            if (headerRowIndex < 0)
            {
                result.Messages.Add(Error("HEADER_NOT_FOUND", "No pude detectar una tabla con importes. Usa encabezados como Cuenta, Concepto, Debe y Haber."));
                return result;
            }

            ExtractKeyValueHeader(rows.Take(headerRowIndex), result.HeaderValues);

            var headers = rows[headerRowIndex];
            var columnMap = BuildColumnMap(headers);
            result.DetectedColumns.AddRange(headers.Where(x => !string.IsNullOrWhiteSpace(x)).Select(x => x.Trim()));

            for (var rowIndex = headerRowIndex + 1; rowIndex < rows.Count; rowIndex++)
            {
                var row = rows[rowIndex];
                if (row.All(string.IsNullOrWhiteSpace))
                    continue;

                CaptureHeaderColumns(row, columnMap, result.HeaderValues);

                var account = Get(row, columnMap, "Cuenta");
                var description = Get(row, columnMap, "Descripcion");
                var debeText = Get(row, columnMap, "Debe");
                var haberText = Get(row, columnMap, "Haber");
                var importeText = Get(row, columnMap, "Importe");
                var debe = ParseAmount(debeText);
                var haber = ParseAmount(haberText);
                var importe = ParseAmount(importeText);
                var naturaleza = Get(row, columnMap, "Naturaleza");

                AddInvalidAmountMessage(result, debeText, debe, rowIndex + 1, "Debe");
                AddInvalidAmountMessage(result, haberText, haber, rowIndex + 1, "Haber");
                AddInvalidAmountMessage(result, importeText, importe, rowIndex + 1, "Importe");

                if (!debe.HasValue && !haber.HasValue && importe.HasValue)
                {
                    if (IsHaber(naturaleza))
                        haber = importe;
                    else
                        debe = importe;
                }

                if (string.IsNullOrWhiteSpace(account)
                    && string.IsNullOrWhiteSpace(description)
                    && !debe.HasValue
                    && !haber.HasValue)
                {
                    continue;
                }

                result.Details.Add(new PolizaAiImportDetailRequest
                {
                    RowNumber = rowIndex + 1,
                    Cuenta = account.Trim(),
                    Descripcion = string.IsNullOrWhiteSpace(description) ? null : description.Trim(),
                    TipoDetallePoliza = NullIfWhiteSpace(Get(row, columnMap, "TipoDetalle")),
                    ImporteDebe = NormalizeAmount(debe),
                    ImporteHaber = NormalizeAmount(haber)
                });
            }

            if (result.Details.Count == 0)
                result.Messages.Add(Error("DETAILS_NOT_FOUND", "No encontre movimientos contables en el archivo."));

            return result;
        }

        private static List<List<string>> ReadDelimitedRows(byte[] content)
        {
            using var stream = new MemoryStream(content);
            using var reader = new StreamReader(stream, Encoding.UTF8, detectEncodingFromByteOrderMarks: true);
            var text = reader.ReadToEnd();
            var lines = text.Replace("\r\n", "\n", StringComparison.Ordinal).Replace('\r', '\n')
                .Split('\n', StringSplitOptions.RemoveEmptyEntries);

            var delimiter = DetectDelimiter(lines.Take(10));
            return lines.Select(line => SplitDelimitedLine(line, delimiter)).ToList();
        }

        private static char DetectDelimiter(IEnumerable<string> lines)
        {
            var candidates = new[] { ',', ';', '\t', '|' };
            return candidates
                .Select(candidate => new { Delimiter = candidate, Count = lines.Sum(line => line.Count(ch => ch == candidate)) })
                .OrderByDescending(x => x.Count)
                .FirstOrDefault(x => x.Count > 0)?.Delimiter ?? ',';
        }

        private static List<string> SplitDelimitedLine(string line, char delimiter)
        {
            var values = new List<string>();
            var current = new StringBuilder();
            var inQuotes = false;

            for (var index = 0; index < line.Length; index++)
            {
                var ch = line[index];
                if (ch == '"')
                {
                    if (inQuotes && index + 1 < line.Length && line[index + 1] == '"')
                    {
                        current.Append('"');
                        index++;
                    }
                    else
                    {
                        inQuotes = !inQuotes;
                    }

                    continue;
                }

                if (ch == delimiter && !inQuotes)
                {
                    values.Add(current.ToString().Trim());
                    current.Clear();
                    continue;
                }

                current.Append(ch);
            }

            values.Add(current.ToString().Trim());
            return values;
        }

        private static List<List<string>> ReadXlsxRows(byte[] content)
        {
            using var memory = new MemoryStream(content);
            using var archive = new ZipArchive(memory, ZipArchiveMode.Read);
            var sharedStrings = ReadSharedStrings(archive);
            var sheet = archive.Entries
                .Where(x => x.FullName.StartsWith("xl/worksheets/sheet", StringComparison.OrdinalIgnoreCase)
                    && x.FullName.EndsWith(".xml", StringComparison.OrdinalIgnoreCase))
                .OrderBy(x => x.FullName)
                .FirstOrDefault();

            if (sheet == null)
                return [];

            using var stream = sheet.Open();
            var document = XDocument.Load(stream);
            var rows = new List<List<string>>();

            foreach (var row in document.Descendants().Where(x => x.Name.LocalName == "row"))
            {
                var values = new SortedDictionary<int, string>();
                foreach (var cell in row.Elements().Where(x => x.Name.LocalName == "c"))
                {
                    var column = GetColumnIndex(cell.Attribute("r")?.Value);
                    values[column] = ReadCellValue(cell, sharedStrings);
                }

                if (values.Count == 0)
                {
                    rows.Add([]);
                    continue;
                }

                var max = values.Keys.Max();
                var rowValues = Enumerable.Range(0, max + 1)
                    .Select(index => values.TryGetValue(index, out var value) ? value : string.Empty)
                    .ToList();
                rows.Add(rowValues);
            }

            return rows;
        }

        private static int GetColumnIndex(string? reference)
        {
            if (string.IsNullOrWhiteSpace(reference))
                return 0;

            var letters = new string(reference.TakeWhile(char.IsLetter).ToArray()).ToUpperInvariant();
            if (letters.Length == 0)
                return 0;

            var index = 0;
            foreach (var ch in letters)
                index = index * 26 + (ch - 'A' + 1);

            return Math.Max(0, index - 1);
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
                result.Add(string.Concat(item.Descendants().Where(x => x.Name.LocalName == "t").Select(x => x.Value)));

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

        private static int FindHeaderRow(IReadOnlyList<List<string>> rows)
        {
            var limit = Math.Min(rows.Count, 30);
            for (var index = 0; index < limit; index++)
            {
                var map = BuildColumnMap(rows[index]);
                var hasAccount = map.ContainsKey("Cuenta");
                var hasAmounts = map.ContainsKey("Debe") || map.ContainsKey("Haber") || map.ContainsKey("Importe");
                var hasPolicyHeader = HeaderKeys.Any(map.ContainsKey);
                if (hasAmounts && (hasAccount || hasPolicyHeader))
                    return index;
            }

            return -1;
        }

        private static Dictionary<string, int> BuildColumnMap(IReadOnlyList<string> headers)
        {
            var result = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
            for (var index = 0; index < headers.Count; index++)
            {
                var normalized = NormalizeKey(headers[index]);
                if (string.IsNullOrWhiteSpace(normalized))
                    continue;

                foreach (var alias in DetailAliases)
                {
                    if (alias.Value.Any(value => NormalizeKey(value) == normalized))
                    {
                        result.TryAdd(alias.Key, index);
                        break;
                    }
                }
            }

            return result;
        }

        private static void ExtractKeyValueHeader(IEnumerable<IReadOnlyList<string>> rows, Dictionary<string, string> headerValues)
        {
            foreach (var row in rows)
            {
                if (row.Count == 0)
                    continue;

                var first = row[0]?.Trim() ?? string.Empty;
                var second = row.Count > 1 ? row[1]?.Trim() ?? string.Empty : string.Empty;

                if (first.Contains(':', StringComparison.Ordinal))
                {
                    var parts = first.Split(':', 2);
                    AddHeaderValue(parts[0], parts[1], headerValues);
                }
                else if (!string.IsNullOrWhiteSpace(first) && !string.IsNullOrWhiteSpace(second))
                {
                    AddHeaderValue(first, second, headerValues);
                }
            }
        }

        private static void CaptureHeaderColumns(IReadOnlyList<string> row, IReadOnlyDictionary<string, int> columnMap, Dictionary<string, string> headerValues)
        {
            foreach (var key in HeaderKeys)
            {
                var value = Get(row, columnMap, key);
                if (!string.IsNullOrWhiteSpace(value))
                    headerValues.TryAdd(key, value.Trim());
            }
        }

        private static void AddHeaderValue(string key, string value, Dictionary<string, string> headerValues)
        {
            var canonical = DetailAliases
                .Where(alias => HeaderKeys.Contains(alias.Key))
                .FirstOrDefault(alias => alias.Value.Any(item => NormalizeKey(item) == NormalizeKey(key))).Key;

            if (!string.IsNullOrWhiteSpace(canonical) && !string.IsNullOrWhiteSpace(value))
                headerValues.TryAdd(canonical, value.Trim());
        }

        private static string Get(IReadOnlyList<string> row, IReadOnlyDictionary<string, int> columnMap, string key)
        {
            if (!columnMap.TryGetValue(key, out var index) || index < 0 || index >= row.Count)
                return string.Empty;

            return row[index] ?? string.Empty;
        }

        public static decimal? ParseAmount(string? value)
        {
            if (string.IsNullOrWhiteSpace(value))
                return null;

            var clean = value.Trim();
            var negative = clean.StartsWith('(') && clean.EndsWith(')');
            clean = clean.Trim('(', ')')
                .Replace("$", string.Empty, StringComparison.Ordinal)
                .Replace("MXN", string.Empty, StringComparison.OrdinalIgnoreCase)
                .Replace(" ", string.Empty, StringComparison.Ordinal);

            if (decimal.TryParse(clean, NumberStyles.Number, CultureInfo.GetCultureInfo("es-MX"), out var esValue)
                || decimal.TryParse(clean, NumberStyles.Number, CultureInfo.InvariantCulture, out esValue))
            {
                return negative ? -esValue : esValue;
            }

            return null;
        }

        private static decimal? NormalizeAmount(decimal? value)
        {
            if (!value.HasValue || value.Value == 0m)
                return null;

            return decimal.Round(value.Value, 2);
        }

        public static DateTime? ParseDate(string? value)
        {
            if (string.IsNullOrWhiteSpace(value))
                return null;

            var clean = value.Trim();
            if (double.TryParse(clean, NumberStyles.Number, CultureInfo.InvariantCulture, out var serial)
                && serial > 20000
                && serial < 90000)
            {
                return DateTime.FromOADate(serial).Date;
            }

            var cultures = new[] { CultureInfo.GetCultureInfo("es-MX"), CultureInfo.InvariantCulture };
            foreach (var culture in cultures)
            {
                if (DateTime.TryParse(clean, culture, DateTimeStyles.None, out var parsed))
                    return parsed.Date;
            }

            return null;
        }

        public static int? ParseMonth(string? value)
        {
            if (string.IsNullOrWhiteSpace(value))
                return null;

            if (int.TryParse(value.Trim(), out var numeric) && numeric is >= 1 and <= 12)
                return numeric;

            var normalized = NormalizeKey(value);
            var months = new Dictionary<string, int>
            {
                ["enero"] = 1,
                ["febrero"] = 2,
                ["marzo"] = 3,
                ["abril"] = 4,
                ["mayo"] = 5,
                ["junio"] = 6,
                ["julio"] = 7,
                ["agosto"] = 8,
                ["septiembre"] = 9,
                ["setiembre"] = 9,
                ["octubre"] = 10,
                ["noviembre"] = 11,
                ["diciembre"] = 12
            };

            return months.TryGetValue(normalized, out var month) ? month : null;
        }

        private static bool IsHaber(string value)
        {
            var normalized = NormalizeKey(value);
            return normalized.Contains("haber", StringComparison.Ordinal)
                || normalized.Contains("abono", StringComparison.Ordinal)
                || normalized.Contains("credit", StringComparison.Ordinal)
                || normalized == "h";
        }

        private static string NormalizeKey(string? value)
        {
            if (string.IsNullOrWhiteSpace(value))
                return string.Empty;

            var normalized = value.Normalize(NormalizationForm.FormD);
            var builder = new StringBuilder(normalized.Length);
            foreach (var ch in normalized)
            {
                if (CharUnicodeInfo.GetUnicodeCategory(ch) != UnicodeCategory.NonSpacingMark && char.IsLetterOrDigit(ch))
                    builder.Append(char.ToLowerInvariant(ch));
            }

            return builder.ToString().Normalize(NormalizationForm.FormC);
        }

        public static string NormalizeAccountKey(string? value)
            => Regex.Replace(NormalizeKey(value), @"[^a-z0-9]", string.Empty);

        private static string NormalizeExtension(string? value)
        {
            var extension = (value ?? string.Empty).Trim().ToLowerInvariant();
            return extension.StartsWith('.') ? extension : $".{extension}";
        }

        private static string? NullIfWhiteSpace(string value)
            => string.IsNullOrWhiteSpace(value) ? null : value.Trim();

        private static void AddInvalidAmountMessage(
            PolizaAiParsedDocument result,
            string value,
            decimal? parsedValue,
            int rowNumber,
            string field)
        {
            if (string.IsNullOrWhiteSpace(value) || parsedValue.HasValue)
                return;

            result.Messages.Add(new PolizaAiImportValidationMessage
            {
                Severity = "Error",
                Code = "INVALID_AMOUNT",
                Message = $"El importe de {field} no tiene un formato numerico valido.",
                RowNumber = rowNumber,
                Field = field
            });
        }

        private static PolizaAiImportValidationMessage Error(string code, string message) => new()
        {
            Severity = "Error",
            Code = code,
            Message = message
        };
    }
}
