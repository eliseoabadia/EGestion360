param(
    [string]$Server = "DESKTOP-B2UQJB2",
    [string]$Database = "GestionEmpresarial",
    [string]$User = "sa",
    [string]$Password = "Sitio2010"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$backendRoot = Join-Path $repoRoot "BackEnd"
$files = Get-ChildItem -Path $backendRoot -Recurse -Filter *.cs

$viewRefs = New-Object System.Collections.Generic.List[object]
$procRefs = New-Object System.Collections.Generic.List[object]

foreach ($file in $files) {
    $text = Get-Content -LiteralPath $file.FullName -Raw
    $relativePath = $file.FullName.Replace($repoRoot + "\", "")

    foreach ($match in [regex]::Matches($text, 'ToView\(\s*"(?<name>[^"]+)"\s*,\s*"(?<schema>[^"]+)"\s*\)')) {
        $viewRefs.Add([pscustomobject]@{
            Kind = "VIEW"
            Schema = $match.Groups["schema"].Value
            Name = $match.Groups["name"].Value
            File = $relativePath
        })
    }

    foreach ($match in [regex]::Matches($text, '"\[(?<schema>[^\]]+)\]\.\[(?<name>[^\]]+)\]"')) {
        $name = $match.Groups["name"].Value
        if ($name -match '^(SP_|sp_|SPR_|CierreMensual|WriteSystemLog|LoginInformationEmployee)') {
            $procRefs.Add([pscustomobject]@{
                Kind = "PROC"
                Schema = $match.Groups["schema"].Value
                Name = $name
                File = $relativePath
            })
        }
    }

    foreach ($match in [regex]::Matches($text, 'EXEC(?:UTE)?\s+\[?(?<schema>[A-Za-z0-9_]+)\]?\.\[?(?<name>[A-Za-z0-9_]+)\]?')) {
        $name = $match.Groups["name"].Value
        if ($name -match '^(SP_|sp_|SPR_|CierreMensual|WriteSystemLog|LoginInformationEmployee)') {
            $procRefs.Add([pscustomobject]@{
                Kind = "PROC"
                Schema = $match.Groups["schema"].Value
                Name = $name
                File = $relativePath
            })
        }
    }
}

$dbRaw = sqlcmd -S $Server -d $Database -U $User -P $Password -C -W -s "|" -h -1 -Q "SET NOCOUNT ON; SELECT SCHEMA_NAME(schema_id), name, type FROM sys.objects WHERE type IN ('V','P');"
$objectSet = @{}
foreach ($line in $dbRaw) {
    $parts = $line -split "\|"
    if ($parts.Count -lt 3) {
        continue
    }

    $kind = if ($parts[2].Trim() -eq "V") { "VIEW" } else { "PROC" }
    $key = ($kind + "|" + $parts[0].Trim() + "|" + $parts[1].Trim()).ToUpperInvariant()
    $objectSet[$key] = $true
}

$refs = @($viewRefs + $procRefs) | Sort-Object Kind, Schema, Name, File -Unique
$missing = $refs | Where-Object {
    $key = ($_.Kind + "|" + $_.Schema + "|" + $_.Name).ToUpperInvariant()
    -not $objectSet.ContainsKey($key)
}

[pscustomobject]@{
    ViewReferenceCount = (@($viewRefs | Sort-Object Schema, Name -Unique)).Count
    ProcReferenceCount = (@($procRefs | Sort-Object Schema, Name -Unique)).Count
    MissingReferenceCount = @($missing).Count
}

if ($missing) {
    ""
    "MISSING REFERENCES"
    $missing | Sort-Object Kind, Schema, Name, File | Format-Table Kind, Schema, Name, File -AutoSize
}
