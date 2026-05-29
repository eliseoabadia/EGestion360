param(
    [string]$IpAddress = "74.208.88.178",
    [int]$Port = 8440,
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

netsh http delete sslcert ipport=0.0.0.0:$Port 2>$null | Out-Null
netsh http add sslcert ipport=0.0.0.0:$Port certhash=$($cert.Thumbprint) appid="{00112233-4455-6677-8899-AABBCCDDEEFF}" certstorename=MY

if ($LASTEXITCODE -ne 0) {
    throw "No se pudo crear el binding HTTPS en 0.0.0.0:$Port."
}

Write-Host "Certificado instalado correctamente en 0.0.0.0:$Port" -ForegroundColor Green
Write-Host "Thumbprint: $($cert.Thumbprint)" -ForegroundColor Green

