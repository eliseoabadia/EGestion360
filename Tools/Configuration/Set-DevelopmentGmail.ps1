#requires -Version 5.1
[CmdletBinding()]
param(
    [string]$FrontendUrl,
    [string]$Sender = 'eliseo.abadia@gmail.com'
)

$ErrorActionPreference = 'Stop'
$project = Join-Path $PSScriptRoot '../../BackEnd/EG.ApiCoreBS/EG.ApiCoreBS.csproj'
if (!(Test-Path -LiteralPath $project)) { throw 'No se encontró el proyecto de la API.' }
if ([string]::IsNullOrWhiteSpace($FrontendUrl)) {
    $FrontendUrl = Read-Host 'Dirección del portal EGestion360 (no la dirección de la API)'
}
$portal = $null
if (![Uri]::TryCreate($FrontendUrl, [UriKind]::Absolute, [ref]$portal) -or
    $portal.UserInfo -or $portal.Query -or $portal.Fragment -or
    ($portal.Scheme -ne 'https' -and !($portal.IsLoopback -and $portal.Scheme -eq 'http'))) {
    throw 'Indica una dirección HTTPS del portal, o HTTP únicamente para localhost.'
}
try {
    $senderAddress = [System.Net.Mail.MailAddress]::new($Sender)
}
catch {
    throw 'El correo remitente no es válido.'
}

Write-Host 'Configuración local de desarrollo. No configura IIS ni envía correos.'
Write-Host 'La clave se almacena con Secret Manager de .NET, fuera del repositorio, sin cifrado en disco.'
$securePassword = Read-Host 'Pega la contraseña de aplicación de Google (entrada oculta)' -AsSecureString
$pointer = [IntPtr]::Zero
$process = $null
try {
    $pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
    $password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($pointer) -replace '\s', ''
    if ($password.Length -ne 16) { throw 'La contraseña de aplicación debe contener 16 caracteres.' }
    $settings = @{
        'EmailSettings:Host' = 'smtp.gmail.com'
        'EmailSettings:Port' = '587'
        'EmailSettings:EnableSsl' = 'true'
        'EmailSettings:UserName' = $Sender
        'EmailSettings:FromEmail' = $Sender
        'EmailSettings:FromName' = 'EGestion360'
        'EmailSettings:Password' = $password
        'PasswordReset:FrontendUrl' = $portal.AbsoluteUri.TrimEnd('/')
    }

    # Pass the secret over standard input, never as a command-line argument or a temporary file.
    $start = [Diagnostics.ProcessStartInfo]::new('dotnet')
    $start.UseShellExecute = $false
    $start.CreateNoWindow = $true
    $start.RedirectStandardInput = $true
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    $start.EnvironmentVariables['DOTNET_CLI_TELEMETRY_OPTOUT'] = '1'
    # .NET Framework (PowerShell 5.1) does not expose ArgumentList.
    # The project path is local, and Windows paths cannot contain a double quote.
    $start.Arguments = 'user-secrets set --project "' + [IO.Path]::GetFullPath($project) + '"'
    $process = [Diagnostics.Process]::Start($start)
    $output = $process.StandardOutput.ReadToEndAsync()
    $errors = $process.StandardError.ReadToEndAsync()
    $process.StandardInput.WriteLine(($settings | ConvertTo-Json -Compress))
    $process.StandardInput.Close()
    $process.WaitForExit()
    $null = $output.GetAwaiter().GetResult()
    $null = $errors.GetAwaiter().GetResult()
    if ($process.ExitCode -ne 0) { throw 'No se pudo guardar la configuración local. Comprueba que el SDK .NET esté instalado.' }
    Write-Host 'Configuración guardada. Reinicia la API en el entorno Development para cargarla.'
    Write-Host 'Esto no verifica la contraseña con Google. Falta probar la recuperación desde el portal.'
}
finally {
    if ($pointer -ne [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($pointer) }
    $password = $null
    $settings = $null
    $securePassword.Dispose()
    if ($null -ne $process) { $process.Dispose() }
}
