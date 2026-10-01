param(
    [string]$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path,
    [string]$OutputDirectory = '',
    [string]$BaselineDate = '2026-09-08'
)

$ErrorActionPreference = 'Stop'
$RepositoryRoot = (Resolve-Path -LiteralPath $RepositoryRoot).Path.TrimEnd('\')
if (-not $OutputDirectory) {
    $OutputDirectory = Join-Path $RepositoryRoot 'artifacts\implementacion_2026\indice_codigo'
}
$OutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
if (-not $OutputDirectory.StartsWith($RepositoryRoot + '\', [StringComparison]::OrdinalIgnoreCase)) {
    throw 'La salida debe permanecer dentro del repositorio.'
}

# Solo se extraen nombres y ubicaciones; no se exporta contenido de configuraciones.
$excludedDirectories = @(
    '.git', '.vs', '.artifacts', 'artifacts', '.codex', '.codex-tmp', '.agents',
    'bin', 'obj', 'publish', 'output', 'tmp', 'temp', 'node_modules', 'packages',
    'TestResults', 'coverage', 'dist', 'build', '_framework', '_content', 'vendor'
)
$sourceExtensions = @(
    '.cs', '.razor', '.cshtml', '.html', '.js', '.ts', '.css', '.scss', '.json',
    '.xml', '.config', '.sql', '.ps1', '.cmd', '.bat', '.md', '.txt', '.csproj',
    '.sln', '.slnx', '.props', '.targets', '.yml', '.yaml', '.resx', '.py'
)
$sensitiveNamePattern = '(^|/)(?:\.env(?:\..*)?|secrets(?:\..*)?|credentials(?:\..*)?)$|\.(?:pfx|p12|pem|key|cer|crt|snk)$'
$generatedNamePattern = '(?:\.g\.cs|\.min\.(?:js|css)|\.map)$'
$scanArgs = @('--files', '--hidden', '--no-ignore')
foreach ($directory in $excludedDirectories) { $scanArgs += @('--glob', ('!**/' + $directory + '/**')) }

Push-Location -LiteralPath $RepositoryRoot
try {
    $listedFiles = @(& rg @scanArgs)
    if ($LASTEXITCODE -gt 1) { throw 'No fue posible enumerar el repositorio con rg.' }
    $commit = (& git rev-parse HEAD).Trim()
    $gitChanges = @(& git status --porcelain --untracked-files=normal)
} finally { Pop-Location }

$relativeFiles = @($listedFiles | ForEach-Object { $_.Replace('\', '/') } | Where-Object {
    $sourceExtensions -contains [IO.Path]::GetExtension($_).ToLowerInvariant() -and
    $_ -notmatch $sensitiveNamePattern -and $_ -notmatch $generatedNamePattern
} | Sort-Object -Unique)
$symbols = [Collections.Generic.List[object]]::new()
$routes = [Collections.Generic.List[object]]::new()
$projects = [Collections.Generic.List[object]]::new()
$typePattern = '^\s*(?:(?:public|internal|protected|private|static|abstract|sealed|partial|readonly|file|new|ref)\s+)*(class|record(?:\s+(?:class|struct))?|interface|enum|struct)\s+([A-Za-z_][A-Za-z0-9_]*)'
$memberPattern = '^\s*(?:(?:public|internal|protected|private)\s+)(?:(?:static|virtual|override|abstract|async|sealed|new|partial|unsafe|extern)\s+)*(?:[A-Za-z_][A-Za-z0-9_<>,?.\[\]\s]*)\s+([A-Za-z_][A-Za-z0-9_]*)\s*\('
$routePattern = '^\s*\[(Route|HttpGet|HttpPost|HttpPut|HttpDelete|HttpPatch|HttpHead|HttpOptions)(?:Attribute)?\s*(?:\(\s*(?:"([^"]*)")?[^\]]*\))?\s*\]'
$pagePattern = '^\s*@page\s+"([^"]+)"'

foreach ($relative in $relativeFiles) {
    $fullName = Join-Path $RepositoryRoot $relative
    $extension = [IO.Path]::GetExtension($relative).ToLowerInvariant()
    if ($extension -in '.cs', '.razor') {
        $lineNumber = 0
        foreach ($line in [IO.File]::ReadLines($fullName)) {
            $lineNumber++
            if ($line -match $typePattern) {
                $symbols.Add([pscustomobject]@{ Kind = $Matches[1]; Name = $Matches[2]; File = $relative; Line = $lineNumber })
            } elseif ($line -match $memberPattern) {
                $symbols.Add([pscustomobject]@{ Kind = 'member'; Name = $Matches[1]; File = $relative; Line = $lineNumber })
            }
            if ($extension -eq '.razor' -and $line -match $pagePattern) {
                $route = [pscustomobject]@{ Kind = 'page'; Name = $Matches[1]; File = $relative; Line = $lineNumber }
                $symbols.Add($route); $routes.Add($route)
            }
            if ($extension -eq '.cs' -and $line -match $routePattern) {
                $attribute = $Matches[1]
                $template = if ($Matches[2]) { $Matches[2] } else { '(sin plantilla literal)' }
                $route = [pscustomobject]@{ Kind = $attribute; Name = $template; File = $relative; Line = $lineNumber }
                $routes.Add($route)
                $symbols.Add([pscustomobject]@{ Kind = 'route'; Name = ($attribute + ': ' + $template); File = $relative; Line = $lineNumber })
            }
        }
    }
    if ($extension -eq '.csproj') {
        [xml]$projectXml = [IO.File]::ReadAllText($fullName)
        $frameworks = @($projectXml.SelectNodes('//TargetFramework|//TargetFrameworks') | ForEach-Object { $_.InnerText } | Sort-Object -Unique)
        $references = @($projectXml.SelectNodes('//ProjectReference') | ForEach-Object { $_.GetAttribute('Include') })
        $packages = @($projectXml.SelectNodes('//PackageReference') | ForEach-Object { $_.GetAttribute('Include') })
        $projects.Add([pscustomobject]@{
            Path = $relative; Sdk = $projectXml.DocumentElement.GetAttribute('Sdk')
            Framework = ($frameworks -join ', '); References = ($references -join '; ')
            Packages = ($packages -join '; ')
        })
    }
}

New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$relativeFiles | Set-Content -LiteralPath (Join-Path $OutputDirectory 'files.txt') -Encoding utf8
$symbols | Sort-Object Kind, Name, File, Line | Export-Csv -LiteralPath (Join-Path $OutputDirectory 'symbols.tsv') -Delimiter "`t" -NoTypeInformation -Encoding UTF8
$routes | Sort-Object Kind, Name, File, Line | Export-Csv -LiteralPath (Join-Path $OutputDirectory 'routes.tsv') -Delimiter "`t" -NoTypeInformation -Encoding UTF8
$projects | Sort-Object Path | Export-Csv -LiteralPath (Join-Path $OutputDirectory 'projects.csv') -NoTypeInformation -Encoding UTF8
$projects | Sort-Object Path | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $OutputDirectory 'projects.json') -Encoding UTF8

$extensionStats = @($relativeFiles | Group-Object { [IO.Path]::GetExtension($_).ToLowerInvariant() } | Sort-Object Count -Descending)
$topFolders = @($relativeFiles | Group-Object { ($_ -split '/')[0] } | Sort-Object Count -Descending)
$metadata = [ordered]@{
    BaselineDate = $BaselineDate
    GeneratedAt = (Get-Date -Format 'yyyy-MM-ddTHH:mm:sszzz')
    RepositoryRoot = $RepositoryRoot
    Commit = $commit
    WorkingTreeHasChanges = ($gitChanges.Count -gt 0)
    Files = $relativeFiles.Count
    SymbolsAndRoutes = $symbols.Count
    Routes = $routes.Count
    RazorPages = @($routes | Where-Object Kind -eq 'page').Count
    Projects = $projects.Count
    SourceExtensions = $sourceExtensions
    ExcludedDirectories = $excludedDirectories
    Extraction = 'Regex por linea para C#/Razor; XML de proyectos; no compilacion ni analisis semantico.'
    Privacy = 'Solo nombres de archivo, simbolos y rutas. Sin valores de appsettings, cadenas de conexion ni llaves.'
}
$metadata | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $OutputDirectory 'metadata.json') -Encoding UTF8

$map = [Collections.Generic.List[string]]::new()
$map.Add('# EGestion360: indice de codigo actualizado')
$map.Add('')
$map.Add(('Corte de planeacion: {0}. Generado: {1}.' -f $BaselineDate, $metadata.GeneratedAt))
$map.Add(('Repositorio: `{0}`.' -f $RepositoryRoot))
$map.Add(('Commit base: `{0}`. Incluye archivos de trabajo con cambios locales: {1}.' -f $commit, $metadata.WorkingTreeHasChanges))
$map.Add('')
$map.Add('## Inventario')
$map.Add('')
$map.Add(('- Archivos de codigo y soporte: {0}.' -f $metadata.Files))
$map.Add(('- Simbolos, miembros y rutas: {0}.' -f $metadata.SymbolsAndRoutes))
$map.Add(('- Declaraciones de rutas/verbos y paginas: {0}; paginas Razor: {1}.' -f $metadata.Routes, $metadata.RazorPages))
$map.Add(('- Proyectos .NET: {0}.' -f $metadata.Projects))
$map.Add('')
$map.Add('## Archivos del indice')
$map.Add('')
$map.Add('- `files.txt`: rutas de archivos; `symbols.tsv`: nombres y lineas; `routes.tsv`: atributos HTTP y paginas Razor.')
$map.Add('- `projects.csv` y `projects.json`: SDK, frameworks, referencias y paquetes directos de cada proyecto.')
$map.Add('- `metadata.json`: fecha, commit, conteos y criterios reproducibles.')
$map.Add('')
$map.Add('## Proyectos .NET')
$map.Add('')
$map.Add('| Proyecto | SDK | Framework | Referencias internas |')
$map.Add('|---|---|---|---|')
foreach ($project in $projects | Sort-Object Path) {
    $map.Add(('| `{0}` | {1} | {2} | {3} |' -f $project.Path, $project.Sdk, $project.Framework, $project.References.Replace('|', '\|')))
}
$map.Add('')
$map.Add('## Distribucion por extension')
$map.Add('')
foreach ($group in $extensionStats) { $map.Add(('- `{0}`: {1}.' -f $group.Name, $group.Count)) }
$map.Add('')
$map.Add('## Distribucion por carpeta principal')
$map.Add('')
foreach ($group in $topFolders) { $map.Add(('- `{0}`: {1}.' -f $group.Name, $group.Count)) }
$map.Add('')
$map.Add('## Limites y exclusiones')
$map.Add('')
$map.Add('Es un indice lexicografico basado en expresiones regulares por linea; no demuestra compilacion, cobertura funcional, calidad ni disponibilidad de una funcionalidad. Puede omitir declaraciones multilínea, constructores, funciones locales, sintaxis inusual y rutas dinamicas; tambien puede incluir falsos positivos en comentarios multilínea. Las rutas de controlador y accion se listan por separado, sin resolver prefijos ni construir endpoints efectivos.')
$map.Add('')
$map.Add('Se excluyen artefactos, compilaciones, dependencias y temporales: ' + ($excludedDirectories -join ', ') + '. Se omiten archivos de secretos/certificados/llaves, archivos .g.cs, minificados y mapas de origen. Los appsettings se inventarian solo por nombre; su contenido no se exporta.')
$map.Add('')
$map.Add('Los conteos cubren el arbol de trabajo actual, incluidos archivos no versionados que cumplen las reglas. No se aplican filtros de .gitignore para evitar omitir codigo de trabajo; las exclusiones anteriores delimitan el universo. No son comparables directamente con el indice de julio, que tenia menos exclusiones y extensiones.')
$map.Add('')
$map.Add('## Regenerar y consultar')
$map.Add('')
$map.Add('```powershell')
$map.Add('& .\Tools\ProjectIndex\Generate-ProjectIndex.ps1')
$map.Add('rg -n -i ''Presupuesto|Contabilidad'' artifacts/implementacion_2026/indice_codigo/files.txt')
$map.Add('rg -n -i ''Nombre|ruta'' artifacts/implementacion_2026/indice_codigo/symbols.tsv')
$map.Add('```')
$map | Set-Content -LiteralPath (Join-Path $OutputDirectory 'PROJECT_MAP.md') -Encoding UTF8
$metadata | ConvertTo-Json -Depth 5
