param(
    [string]$IpAddress = "74.208.88.178",
    [int]$Port = 8440,
    [string]$CertbotPath = "C:\Program Files\Certbot\bin\certbot.exe"
)

$ErrorActionPreference = "Stop"

function Require-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Ejecuta PowerShell como administrador."
    }
}

Require-Administrator

if (-not (Test-Path -LiteralPath $CertbotPath)) {
    $cmd = Get-Command certbot -ErrorAction SilentlyContinue
    if ($null -eq $cmd) {
        throw "No se encontro Certbot."
    }

    $CertbotPath = $cmd.Source
}

& $CertbotPath renew --quiet

if ($LASTEXITCODE -ne 0) {
    throw "Certbot renew termino con codigo $LASTEXITCODE."
}

& "$PSScriptRoot\02_InstalarCertificadoIIS.ps1" -IpAddress $IpAddress -Port $Port

Write-Host "Renovacion aplicada correctamente." -ForegroundColor Green

