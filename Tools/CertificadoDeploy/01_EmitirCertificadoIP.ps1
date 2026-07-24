param(
    [string]$IpAddress = "74.208.88.178",
    [Parameter(Mandatory = $true)]
    [string]$Email,
    [switch]$Staging,
    [switch]$ForceRenewal,
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
        throw "No se encontro Certbot. Instala Certbot 5.4 o superior y vuelve a ejecutar este script."
    }

    $CertbotPath = $cmd.Source
}

$certbotArgs = @(
    "certonly",
    "--standalone",
    "--preferred-profile", "shortlived",
    "--ip-address", $IpAddress,
    "--cert-name", $IpAddress,
    "--agree-tos",
    "--email", $Email,
    "--non-interactive"
)

if ($Staging) {
    $certbotArgs += "--staging"
}

if ($ForceRenewal) {
    $certbotArgs += "--force-renewal"
}

Write-Host "Solicitando certificado para IP $IpAddress..." -ForegroundColor Cyan
Write-Host "Nota: el puerto 80 debe estar libre y accesible desde internet." -ForegroundColor Yellow

& $CertbotPath @certbotArgs

if ($LASTEXITCODE -ne 0) {
    throw "Certbot termino con codigo $LASTEXITCODE."
}

Write-Host "Certificado emitido correctamente." -ForegroundColor Green
Write-Host "Ruta esperada: C:\Certbot\live\$IpAddress" -ForegroundColor Green

