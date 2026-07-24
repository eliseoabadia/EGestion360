param(
    [string]$IpAddress = "74.208.88.178",
    [Parameter(Mandatory = $true)]
    [string]$Email,
    [int[]]$Ports = @(443, 8440),
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

$port80Listeners = @(Get-NetTCPConnection -LocalPort 80 -State Listen -ErrorAction SilentlyContinue)
if ($port80Listeners.Count -gt 0) {
    throw "El puerto 80 esta ocupado. Libera temporalmente el binding o servicio que lo usa para que Certbot standalone pueda validar la IP."
}

& "$PSScriptRoot\01_EmitirCertificadoIP.ps1" `
    -IpAddress $IpAddress `
    -Email $Email `
    -ForceRenewal `
    -CertbotPath $CertbotPath

& "$PSScriptRoot\02_InstalarCertificadoIIS.ps1" `
    -IpAddress $IpAddress `
    -Ports $Ports

& "$PSScriptRoot\04_CrearTareaRenovacion.ps1"

Write-Host "Reparacion terminada. Certificado renovado y aplicado a: $($Ports -join ', ')." -ForegroundColor Green
