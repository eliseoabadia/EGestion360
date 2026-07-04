using System.Globalization;
using System.IO.Compression;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml.Linq;
using EG.Domain.DTOs.Requests.Presupuestales;

namespace EG.Application.Services.Configuracion.Catalogo.Presupuestales
{
    internal sealed class EgresoProyectadoAiParsedDocument
    {
        public Dictionary<string, string> HeaderValues { get; } = new(StringComparer.OrdinalIgnoreCase);
        public List<EgresoProyectadoAiImportRowRequest> Rows { get; } = [];
        public List<EgresoProyectadoAiImportValidationMessage> Messages { get; } = [];
        public List<string> DetectedColumns { get; } = [];
    }

    internal static class EgresoProyectadoAiImportParser
    {
        private static readonly Dictionary<string, string[]> Aliases = new(StringComparer.OrdinalIgnoreCase)
        {
            ["Anio"] = ["anio", "ano", "ejercicio"],
            ["Programa"] = ["programa", "programapresupuestal", "programapres", "claveprograma"],
            ["Partida"] = ["partida", "partidapresupuestal", "partidaconta", "clavepartida"],
            ["Area"] = ["area", "unidad", "unidadarea", "areasolicitante", "clavearea"],
            ["Descripcion"] = ["descripcion", "concepto", "detalle", "justificacion", "observacion"],
            ["Fecha"] = ["fecha", "fechainicio", "fecharegistro"],
            ["FuenteFinanciamiento"] = ["fuente", "fuentefinanciamiento", "ff", "clasificacion", "fuenteffinanciamiento"],
            ["TipoGasto"] = ["tipogasto", "tg", "tipodegasto"],
            ["DigitoIdentificador"] = ["digitoidentificador", "di", "digito"],
            ["DestinoGasto"] = ["destinogasto", "dg", "destino"],
            ["Py"] = ["py", "proyecto", "proyectopy"],
            ["Enero"] = ["enero", "ene", "mes1", "m01", "01"],
            ["Febrero"] = ["febrero", "feb", "mes2", "m02", "02"],
            ["Marzo"] = ["marzo", "mar", "mes3", "m03", "03"],
            ["Abril"] = ["abril", "abr", "mes4", "m04", "04"],
            ["Mayo"] = ["mayo", "may", "mes5", "m05", "05"],
            ["Junio"] = ["junio", "jun", "mes6", "m06", "06"],
            ["Julio"] = ["julio", "jul", "mes7", "m07", "07"],
            ["Agosto"] = ["agosto", "ago", "mes8", "m08", "08"],
            ["Septiembre"] = ["septiembre", "setiembre", "sep", "mes9", "m09", "09"],
            ["Octubre"] = ["octubre", "oct", "mes10", "m10", "10"],
            ["Noviembre"] = ["noviembre", "nov", "mes11", "m11", "11"],
            ["Diciembre"] = ["diciembre", "dic", "mes12", "m12", "12"],
            ["Total"] = ["total", "importe", "monto", "presupuesto"]
        };

        private static readonly string[] MonthKeys =
        [
            "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
            "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
        ];

        public static EgresoProyectadoAiParsedDocument Parse(string fileName, byte[] content)
        {
            var extension = NormalizeExtension(Path.GetExtension(fileName));
            var rows = extension switch
            {
                ".xlsx" => ReadXlsxRows(content),
                ".csv" or ".txt" => ReadDelimitedRows(content),
                _ => []
            };

            var result = new EgresoProyectadoAiParsedDocument();
            if (rows.Count == 0)
            {
                result.Messages.Add(Error("EMPTY_FILE", "No se encontro contenido tabular para analizar."));
                return result;
            }

            var headerRowIndex = FindHeaderRow(rows);
            if (headerRowIndex < 0)
            {
                result.Messages.Add(Error("HEADER_NOT_FOUND", "No pude detectar una tabla de anteproyecto. Usa columnas como Partida, Area, Descripcion y Enero-Diciembre. Programa puede completarse con el campo de ayuda."));
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
                var item = new EgresoProyectadoAiImportRowRequest
                {
                    RowNumber = rowIndex + 1,
                    Programa = NullIfWhiteSpace(Get(row, columnMap, "Programa")),
                    Partida = NullIfWhiteSpace(Get(row, columnMap, "Partida")),
                    Area = NullIfWhiteSpace(Get(row, columnMap, "Area")),
                    Descripcion = NullIfWhiteSpace(Get(row, columnMap, "Descripcion")),
                    Fecha = ParseDate(Get(row, columnMap, "Fecha")),
                    FuenteFinanciamiento = NullIfWhiteSpace(Get(row, columnMap, "FuenteFinanciamiento")),
                    TipoGasto = NullIfWhiteSpace(Get(row, columnMap, "TipoGasto")),
                    DigitoIdentificador = NullIfWhiteSpace(Get(row, columnMap, "DigitoIdentificador")),
                    DestinoGasto = NullIfWhiteSpace(Get(row, columnMap, "DestinoGasto")),
                    Py = NullIfWhiteSpace(Get(row, columnMap, "Py")),
                    Enero = ParseAmount(Get(row, columnMap, "Enero")) ?? 0m,
                    Febrero = ParseAmount(Get(row, columnMap, "Febrero")) ?? 0m,
                    Marzo = ParseAmount(Get(row, columnMap, "Marzo")) ?? 0m,
                    Abril = ParseAmount(Get(row, columnMap, "Abril")) ?? 0m,
                    Mayo = ParseAmount(Get(row, columnMap, "Mayo")) ?? 0m,
                    Junio = ParseAmount(Get(row, columnMap, "Junio")) ?? 0m,
                    Julio = ParseAmount(Get(row, columnMap, "Julio")) ?? 0m,
                    Agosto = ParseAmount(Get(row, columnMap, "Agosto")) ?? 0m,
                    Septiembre = ParseAmount(Get(row, columnMap, "Septiembre")) ?? 0m,
                    Octubre = ParseAmount(Get(row, columnMap, "Octubre")) ?? 0m,
                    Noviembre = ParseAmount(Get(row, columnMap, "Noviembre")) ?? 0m,
                    Diciembre = ParseAmount(Get(row, columnMap, "Diciembre")) ?? 0m
                };

                item.Total = item.Enero + item.Febrero + item.Marzo + item.Abril + item.Mayo + item.Junio
                    + item.Julio + item.Agosto + item.Septiembre + item.Octubre + item.Noviembre + item.Diciembre;

                var explicitTotal = ParseAmount(Get(row, columnMap, "Total"));
                if (item.Total == 0m && explicitTotal.GetValueOrDefault() > 0m)
                {
                    item.Enero = explicitTotal.Value;
                    item.Total = explicitTotal.Value;
                }

                if (IsEmptyBusinessRow(item))
                    continue;

                result.Rows.Add(item);
            }

            if (result.Rows.Count == 0)
                result.Messages.Add(Error("ROWS_NOT_FOUND", "No encontre filas de anteproyecto en el archivo."));

            return result;
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

            if (decimal.TryParse(clean, NumberStyles.Number, CultureInfo.GetCultureInfo("es-MX"), out var parsed)
                || decimal.TryParse(clean, NumberStyles.Number, CultureInfo.InvariantCulture, out parsed))
            {
                return decimal.Round(negative ? -parsed : parsed, 2);
            }

            return null;
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

            foreach (var culture in new[] { CultureInfo.GetCultureInfo("es-MX"), CultureInfo.InvariantCulture })
            {
                if (DateTime.TryParse(clean, culture, DateTimeStyles.None, out var parsed))
                    return parsed.Date;
            }

            return null;
        }

        public static string NormalizeLookupKey(string? value)
            => Regex.Replace(NormalizeText(value), @"[^a-z0-9]", string.Empty);

        private static bool IsEmptyBusinessRow(EgresoProyectadoAiImportRowRequest item)
            => string.IsNullOrWhiteSpace(item.Programa)
                && string.IsNullOrWhiteSpace(item.Partida)
                && string.IsNullOrWhiteSpace(item.Area)
                && string.IsNullOrWhiteSpace(item.Descripcion)
                && item.Total == 0m;

        private static int FindHeaderRow(IReadOnlyList<List<string>> rows)
        {
            var limit = Math.Min(rows.Count, 30);
            for (var index = 0; index < limit; index++)
            {
                var map = BuildColumnMap(rows[index]);
                var hasBusinessColumn = map.ContainsKey("Programa")
                    || map.ContainsKey("Partida")
                    || map.ContainsKey("Area")
                    || map.ContainsKey("Descripcion");
                var hasAmount = MonthKeys.Any(map.ContainsKey) || map.ContainsKey("Total");
                if (hasBusinessColumn && hasAmount)
                    return index;
            }

            return -1;
        }

        private static Dictionary<string, int> BuildColumnMap(IReadOnlyList<string> headers)
        {
            var result = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
            for (var index = 0; index < headers.Count; index++)
            {
                var normalized = NormalizeLookupKey(headers[index]);
                if (string.IsNullOrWhiteSpace(normalized))
                    continue;

                foreach (var alias in Aliases)
                {
                    if (alias.Value.Any(value => NormalizeLookupKey(value) == normalized))
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
            var value = Get(row, columnMap, "Anio");
            if (!string.IsNullOrWhiteSpace(value))
                headerValues.TryAdd("Anio", value.Trim());
        }

        private static void AddHeaderValue(string key, string value, Dictionary<string, string> headerValues)
        {
            var canonical = Aliases
                .FirstOrDefault(alias => alias.Key == "Anio" && alias.Value.Any(item => NormalizeLookupKey(item) == NormalizeLookupKey(key))).Key;

            if (!string.IsNullOrWhiteSpace(canonical) && !string.IsNullOrWhiteSpace(value))
                headerValues.TryAdd(canonical, value.Trim());
        }

        private static string Get(IReadOnlyList<string> row, IReadOnlyDictionary<string, int> columnMap, string key)
        {
            if (!columnMap.TryGetValue(key, out var index) || index < 0 || index >= row.Count)
                return string.Empty;

            return row[index] ?? string.Empty;
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
                rows.Add(Enumerable.Range(0, max + 1)
                    .Select(index => values.TryGetValue(index, out var value) ? value : string.Empty)
                    .ToList());
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

        private static string NormalizeText(string? value)
        {
            if (string.IsNullOrWhiteSpace(value))
                return string.Empty;

            var normalized = value.Normalize(NormalizationForm.FormD);
            var builder = new StringBuilder(normalized.Length);
            foreach (var ch in normalized)
            {
                if (CharUnicodeInfo.GetUnicodeCategory(ch) != UnicodeCategory.NonSpacingMark)
                    builder.Append(char.ToLowerInvariant(ch));
            }

            return builder.ToString().Normalize(NormalizationForm.FormC).Trim();
        }

        private static string NormalizeExtension(string? value)
        {
            var extension = (value ?? string.Empty).Trim().ToLowerInvariant();
            return extension.StartsWith('.') ? extension : $".{extension}";
        }

        private static string? NullIfWhiteSpace(string value)
            => string.IsNullOrWhiteSpace(value) ? null : value.Trim();

        private static EgresoProyectadoAiImportValidationMessage Error(string code, string message) => new()
        {
            Severity = "Error",
            Code = code,
            Message = message
        };
    }
}
