$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host ''
Write-Host 'COMPARADOR DE NOMBRES DE ARCHIVO' -ForegroundColor Cyan
Write-Host 'No mueve, modifica ni elimina archivos.'
Write-Host ''

$drives = [System.IO.DriveInfo]::GetDrives() |
    Where-Object { $_.IsReady -and $_.DriveType -in @('Fixed', 'Removable') } |
    Sort-Object Name

Write-Host 'Unidades disponibles:' -ForegroundColor Yellow
foreach ($drive in $drives) {
    $sizeGB = [Math]::Round($drive.TotalSize / 1GB, 1)
    $freeGB = [Math]::Round($drive.AvailableFreeSpace / 1GB, 1)
    $label = if ([string]::IsNullOrWhiteSpace($drive.VolumeLabel)) { '(sin etiqueta)' } else { $drive.VolumeLabel }
    Write-Host ("  {0}  {1}  {2} GB totales, {3} GB libres" -f $drive.Name, $label, $sizeGB, $freeGB)
}

Write-Host ''
$answer = Read-Host 'Escribe las 4 letras separadas por coma (ejemplo: E,F,G,H)'
$requested = @($answer -split '[,; ]+' | Where-Object { $_ } | ForEach-Object {
    $letter = $_.Trim().TrimEnd(':', '\')
    if ($letter.Length -ne 1 -or $letter -notmatch '^[A-Za-z]$') {
        throw "Unidad no valida: $_"
    }
    ($letter.ToUpperInvariant() + ':\')
} | Select-Object -Unique)

if ($requested.Count -lt 2) {
    throw 'Selecciona al menos dos unidades.'
}

foreach ($root in $requested) {
    if (-not [System.IO.Directory]::Exists($root)) {
        throw "No se puede acceder a $root"
    }
}

$thresholdText = Read-Host 'Porcentaje minimo (Enter = mas de 80%)'
$threshold = 80.0
if (-not [string]::IsNullOrWhiteSpace($thresholdText)) {
    $parsed = 0.0
    if (-not [double]::TryParse($thresholdText, [Globalization.NumberStyles]::Float,
            [Globalization.CultureInfo]::CurrentCulture, [ref]$parsed)) {
        throw 'El porcentaje no es valido.'
    }
    if ($parsed -lt 0 -or $parsed -ge 100) {
        throw 'El porcentaje debe estar entre 0 y menos de 100.'
    }
    $threshold = $parsed
}

$source = @'
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;

public static class FilenameComparison
{
    private sealed class Occurrence
    {
        public string Name;
        public string Unit;
        public string Path;
    }

    private sealed class Entry
    {
        public string Key;
        public readonly List<Occurrence> Files = new List<Occurrence>();
        public readonly HashSet<string> DisplayNames = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
    }

    private sealed class Match
    {
        public Entry A;
        public Entry B;
        public double Score;
        public bool ExactGroup;
    }

    private sealed class BKNode
    {
        public string Term;
        public readonly Dictionary<int, BKNode> Children = new Dictionary<int, BKNode>();
        public BKNode(string term) { Term = term; }
    }

    private sealed class BKTree
    {
        private BKNode root;

        public void Add(string term)
        {
            if (root == null) { root = new BKNode(term); return; }
            BKNode node = root;
            while (true)
            {
                int d = Distance(term, node.Term);
                BKNode child;
                if (!node.Children.TryGetValue(d, out child))
                {
                    node.Children[d] = new BKNode(term);
                    return;
                }
                node = child;
            }
        }

        public List<string> Search(string term, int radius)
        {
            var result = new List<string>();
            if (root != null) SearchNode(root, term, radius, result);
            return result;
        }

        private static void SearchNode(BKNode node, string term, int radius, List<string> result)
        {
            int d = Distance(term, node.Term);
            if (d <= radius) result.Add(node.Term);
            int low = d - radius;
            int high = d + radius;
            foreach (var child in node.Children)
                if (child.Key >= low && child.Key <= high)
                    SearchNode(child.Value, term, radius, result);
        }
    }

    public static void Run(string[] roots, string outputDirectory, double threshold)
    {
        var entries = new Dictionary<string, Entry>(StringComparer.Ordinal);
        int inaccessible = 0;
        long fileCount = 0;

        foreach (string root in roots)
        {
            Console.WriteLine("Revisando " + root + " ...");
            var pending = new Stack<string>();
            pending.Push(root);
            while (pending.Count > 0)
            {
                string folder = pending.Pop();
                try
                {
                    foreach (string subfolder in Directory.EnumerateDirectories(folder))
                        pending.Push(subfolder);
                }
                catch { inaccessible++; }

                try
                {
                    foreach (string path in Directory.EnumerateFiles(folder))
                    {
                        string name = Path.GetFileName(path);
                        string key = Normalize(name);
                        if (key.Length == 0) continue;
                        Entry entry;
                        if (!entries.TryGetValue(key, out entry))
                        {
                            entry = new Entry { Key = key };
                            entries.Add(key, entry);
                        }
                        entry.DisplayNames.Add(name);
                        entry.Files.Add(new Occurrence { Name = name, Unit = root, Path = path });
                        fileCount++;
                        if (fileCount % 5000 == 0)
                            Console.WriteLine("  " + fileCount.ToString("N0") + " archivos inventariados...");
                    }
                }
                catch { inaccessible++; }
            }
        }

        Console.WriteLine("Comparando " + entries.Count.ToString("N0") + " nombres diferentes...");
        var matches = new List<Match>();

        foreach (Entry entry in entries.Values)
            if (entry.Files.Count > 1)
                matches.Add(new Match { A = entry, B = null, Score = 100.0, ExactGroup = true });

        var tree = new BKTree();
        var byKey = entries;
        foreach (string key in entries.Keys.OrderBy(k => k, StringComparer.Ordinal))
        {
            int radius = Math.Max(1, (int)Math.Ceiling(key.Length * 0.25));
            foreach (string otherKey in tree.Search(key, radius))
            {
                int longer = Math.Max(key.Length, otherKey.Length);
                int shorter = Math.Min(key.Length, otherKey.Length);
                if (shorter * 100.0 / longer <= threshold) continue;
                int distance = Distance(key, otherKey);
                double score = 100.0 * (1.0 - ((double)distance / longer));
                if (score > threshold)
                    matches.Add(new Match { A = byKey[otherKey], B = byKey[key], Score = score, ExactGroup = false });
            }
            tree.Add(key);
        }

        Directory.CreateDirectory(outputDirectory);
        string detailPath = Path.Combine(outputDirectory, "Coincidencias_mas_de_" + threshold.ToString("0.##", CultureInfo.InvariantCulture) + "_porciento.csv");
        string summaryPath = Path.Combine(outputDirectory, "Resumen.txt");

        var rows = new List<string[]>();
        int groupNumber = 0;
        foreach (Match match in matches.OrderBy(m => FirstName(m.A), StringComparer.CurrentCultureIgnoreCase)
                                      .ThenBy(m => m.B == null ? "" : FirstName(m.B), StringComparer.CurrentCultureIgnoreCase))
        {
            groupNumber++;
            string group = "G" + groupNumber.ToString("D6");
            if (match.ExactGroup)
            {
                string names = String.Join(" | ", match.A.DisplayNames.OrderBy(x => x, StringComparer.CurrentCultureIgnoreCase));
                foreach (Occurrence file in match.A.Files)
                    rows.Add(new [] { group, "100.0", file.Name, names, file.Unit, file.Path });
            }
            else
            {
                string namesA = String.Join(" | ", match.A.DisplayNames.OrderBy(x => x, StringComparer.CurrentCultureIgnoreCase));
                string namesB = String.Join(" | ", match.B.DisplayNames.OrderBy(x => x, StringComparer.CurrentCultureIgnoreCase));
                string score = match.Score.ToString("0.0", CultureInfo.InvariantCulture);
                foreach (Occurrence file in match.A.Files)
                    rows.Add(new [] { group, score, file.Name, namesB, file.Unit, file.Path });
                foreach (Occurrence file in match.B.Files)
                    rows.Add(new [] { group, score, file.Name, namesA, file.Unit, file.Path });
            }
        }

        rows = rows.OrderBy(r => r[2], StringComparer.CurrentCultureIgnoreCase)
                   .ThenBy(r => r[4], StringComparer.CurrentCultureIgnoreCase)
                   .ThenBy(r => r[5], StringComparer.CurrentCultureIgnoreCase)
                   .ToList();

        using (var writer = new StreamWriter(detailPath, false, new UTF8Encoding(true)))
        {
            writer.WriteLine("Grupo,Porcentaje,Nombre,Coincide_con,Unidad,Ruta_completa");
            foreach (string[] row in rows)
                writer.WriteLine(String.Join(",", row.Select(Csv)));
        }

        using (var writer = new StreamWriter(summaryPath, false, new UTF8Encoding(true)))
        {
            writer.WriteLine("RESULTADO DEL COMPARADOR DE NOMBRES");
            writer.WriteLine("Fecha: " + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
            writer.WriteLine("Unidades: " + String.Join(", ", roots));
            writer.WriteLine("Archivos revisados: " + fileCount.ToString("N0"));
            writer.WriteLine("Nombres diferentes: " + entries.Count.ToString("N0"));
            writer.WriteLine("Grupos encontrados: " + matches.Count.ToString("N0"));
            writer.WriteLine("Filas en el listado: " + rows.Count.ToString("N0"));
            writer.WriteLine("Carpetas sin acceso: " + inaccessible.ToString("N0"));
            writer.WriteLine("Criterio: similitud estrictamente mayor que " + threshold.ToString("0.##") + "%.");
            writer.WriteLine("El porcentaje usa distancia de edicion sobre el nombre completo, sin distinguir mayusculas, acentos ni separadores comunes.");
        }

        Console.WriteLine();
        Console.WriteLine("Listo. Archivos revisados: " + fileCount.ToString("N0"));
        Console.WriteLine("Grupos encontrados: " + matches.Count.ToString("N0"));
        Console.WriteLine("Listado: " + detailPath);
        Console.WriteLine("Resumen: " + summaryPath);
    }

    private static string FirstName(Entry entry)
    {
        return entry.DisplayNames.OrderBy(x => x, StringComparer.CurrentCultureIgnoreCase).FirstOrDefault() ?? "";
    }

    private static string Normalize(string value)
    {
        string decomposed = value.Normalize(NormalizationForm.FormD).ToLowerInvariant();
        var sb = new StringBuilder(decomposed.Length);
        bool previousSpace = false;
        foreach (char c in decomposed)
        {
            UnicodeCategory category = CharUnicodeInfo.GetUnicodeCategory(c);
            if (category == UnicodeCategory.NonSpacingMark) continue;
            if (Char.IsLetterOrDigit(c))
            {
                sb.Append(c);
                previousSpace = false;
            }
            else if (!previousSpace && sb.Length > 0)
            {
                sb.Append(' ');
                previousSpace = true;
            }
        }
        return sb.ToString().Trim();
    }

    private static int Distance(string a, string b)
    {
        if (a == b) return 0;
        if (a.Length == 0) return b.Length;
        if (b.Length == 0) return a.Length;
        if (a.Length > b.Length) { string temp = a; a = b; b = temp; }
        int[] previous = new int[a.Length + 1];
        int[] current = new int[a.Length + 1];
        for (int i = 0; i <= a.Length; i++) previous[i] = i;
        for (int j = 1; j <= b.Length; j++)
        {
            current[0] = j;
            for (int i = 1; i <= a.Length; i++)
            {
                int cost = a[i - 1] == b[j - 1] ? 0 : 1;
                current[i] = Math.Min(Math.Min(current[i - 1] + 1, previous[i] + 1), previous[i - 1] + cost);
            }
            int[] swap = previous; previous = current; current = swap;
        }
        return previous[a.Length];
    }

    private static string Csv(string value)
    {
        if (value == null) value = "";
        return "\"" + value.Replace("\"", "\"\"") + "\"";
    }
}
'@

if (-not ('FilenameComparison' -as [type])) {
    Add-Type -TypeDefinition $source -Language CSharp
}

$timestamp = Get-Date -Format 'yyyy-MM-dd_HHmmss'
$output = Join-Path $PSScriptRoot ("Resultados_" + $timestamp)

Write-Host ''
Write-Host 'El proceso puede tardar si hay muchos archivos. Puedes seguir el avance en pantalla.' -ForegroundColor Yellow
[FilenameComparison]::Run([string[]]$requested, $output, [double]$threshold)

Write-Host ''
Write-Host 'Se abrira la carpeta de resultados.' -ForegroundColor Green
Start-Process explorer.exe -ArgumentList $output

