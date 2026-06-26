param(
    [Parameter(Mandatory = $true)]
    [string]$TargetPath,

    [string]$ArchivePath = (Join-Path $PSScriptRoot 'Front.rar'),

    [string]$RarPath = 'C:\Program Files\WinRAR\Rar.exe'
)

$resolvedTarget = Resolve-Path -LiteralPath $TargetPath -ErrorAction Stop

if ($resolvedTarget.Path -match '^[A-Z]:\\$') {
    throw 'TargetPath no puede ser la raiz de una unidad.'
}

if (-not (Test-Path -LiteralPath $ArchivePath)) {
    throw "No existe el archivo RAR: $ArchivePath"
}

if (-not (Test-Path -LiteralPath $RarPath)) {
    throw "No existe WinRAR en: $RarPath"
}

Write-Host "Limpiando destino: $($resolvedTarget.Path)"
Get-ChildItem -LiteralPath $resolvedTarget.Path -Force | Remove-Item -Recurse -Force

Write-Host "Extrayendo: $ArchivePath"
& $RarPath x -o+ $ArchivePath "$($resolvedTarget.Path)\"

if ($LASTEXITCODE -ne 0) {
    throw "WinRAR termino con codigo $LASTEXITCODE"
}

Write-Host 'Deploy Front completado.'
