param(
    [string]$IpAddress = "74.208.88.178",
    [Alias("Port")]
    [int[]]$Ports = @(443, 8440),
    [string]$CertbotLivePath = "",
    [string]$PfxPassword = "",
    [string]$PfxOutputPath = "C:\Temp\GestionEmpresarialDeploy\Certificado\egestion360-api-ip.pfx"
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

$Ports = @($Ports | Sort-Object -Unique)
if ($Ports.Count -eq 0 -or @($Ports | Where-Object { $_ -lt 1 -or $_ -gt 65535 }).Count -gt 0) {
    throw "Especifica al menos un puerto TCP valido entre 1 y 65535."
}

if ([string]::IsNullOrWhiteSpace($CertbotLivePath)) {
    $CertbotLivePath = "C:\Certbot\live\$IpAddress"
}

$fullchain = Join-Path $CertbotLivePath "fullchain.pem"
$privkey = Join-Path $CertbotLivePath "privkey.pem"

if (-not (Test-Path -LiteralPath $fullchain)) {
    throw "No existe fullchain.pem en $CertbotLivePath."
}

if (-not (Test-Path -LiteralPath $privkey)) {
    throw "No existe privkey.pem en $CertbotLivePath."
}

if ([string]::IsNullOrWhiteSpace($PfxPassword)) {
    $PfxPassword = [Guid]::NewGuid().ToString("N")
    Write-Host "Password PFX generado: $PfxPassword" -ForegroundColor Yellow
    Write-Host "Guardalo, se necesita si vas a importar este PFX manualmente." -ForegroundColor Yellow
}

$openssl = Get-Command openssl -ErrorAction SilentlyContinue
if ($null -eq $openssl) {
    throw "No se encontro openssl en PATH. Instala OpenSSL o usa Certbot/Windows con exportacion PFX equivalente."
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $PfxOutputPath) | Out-Null

& $openssl.Source pkcs12 -export `
    -out $PfxOutputPath `
    -inkey $privkey `
    -in $fullchain `
    -passout "pass:$PfxPassword"

if ($LASTEXITCODE -ne 0) {
    throw "OpenSSL termino con codigo $LASTEXITCODE."
}

$securePassword = ConvertTo-SecureString $PfxPassword -AsPlainText -Force
$cert = Import-PfxCertificate -FilePath $PfxOutputPath -CertStoreLocation Cert:\LocalMachine\My -Password $securePassword

if ($null -eq $cert) {
    throw "No se pudo importar el certificado PFX."
}

if ($cert.NotBefore -gt (Get-Date) -or $cert.NotAfter -le (Get-Date)) {
    throw "El certificado importado no esta vigente. Valido de $($cert.NotBefore.ToString('u')) a $($cert.NotAfter.ToString('u'))."
}

$appId = "{00112233-4455-6677-8899-AABBCCDDEEFF}"
$webAdministrationAvailable = $null -ne (Get-Module -ListAvailable -Name WebAdministration)
if ($webAdministrationAvailable) {
    Import-Module WebAdministration -ErrorAction Stop
}

foreach ($port in $Ports) {
    $iisBindings = @()
    if ($webAdministrationAvailable) {
        $iisBindings = @(Get-WebBinding -Protocol "https" | Where-Object {
            $parts = ([string]$_.bindingInformation).Split(':')
            $parts.Count -ge 3 -and
            $parts[$parts.Count - 2] -eq [string]$port -and
            [string]::IsNullOrWhiteSpace($parts[$parts.Count - 1])
        })
    }

    if ($iisBindings.Count -gt 0) {
        foreach ($binding in $iisBindings) {
            $binding.AddSslCertificate($cert.Thumbprint, "My")
        }

        Write-Host "Certificado aplicado a $($iisBindings.Count) binding(s) IIS en el puerto $port." -ForegroundColor Green
    }
    else {
        & netsh.exe http update sslcert ipport=0.0.0.0:$port certhash=$($cert.Thumbprint) appid=$appId certstorename=MY 2>$null | Out-Null

        if ($LASTEXITCODE -ne 0) {
            & netsh.exe http add sslcert ipport=0.0.0.0:$port certhash=$($cert.Thumbprint) appid=$appId certstorename=MY | Out-Null
        }

        if ($LASTEXITCODE -ne 0) {
            throw "No se pudo crear o actualizar el binding HTTPS en 0.0.0.0:$port."
        }

        Write-Host "Certificado aplicado al binding HTTP.sys 0.0.0.0:$port." -ForegroundColor Green
    }
}

Write-Host "Thumbprint: $($cert.Thumbprint)" -ForegroundColor Green
Write-Host "Vigencia: $($cert.NotBefore.ToString('u')) - $($cert.NotAfter.ToString('u'))" -ForegroundColor Green

