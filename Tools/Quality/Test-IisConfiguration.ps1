[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$frontendRoot = Join-Path $repoRoot 'FrontEnd\EG.Web'
[xml]$rootConfig = Get-Content -LiteralPath (Join-Path $frontendRoot 'web.config') -Raw
[xml]$staticConfig = Get-Content -LiteralPath (Join-Path $frontendRoot 'wwwroot\web.config') -Raw

$apiRules = @($rootConfig.configuration.'system.webServer'.rewrite.rules.rule | Where-Object {
    $_.match.url.StartsWith('^api') -and $_.action.type -eq 'Rewrite'
})
if ($apiRules.Count -ne 1) {
    throw 'El frontend debe declarar una regla de proxy para api.'
}

$proxyAddress = [uri]$apiRules[0].action.url.Replace('{R:0}', 'api')
if (-not $proxyAddress.IsLoopback) {
    throw 'El proxy de API debe apuntar al enlace privado local del backend.'
}

$redirect = @($staticConfig.configuration.'system.webServer'.rewrite.rules.rule | Where-Object {
    $_.action.type -eq 'Redirect' -and $_.action.url.StartsWith('https://')
})
if ($redirect.Count -eq 0) {
    throw 'Falta la redirección HTTPS pública.'
}

foreach ($relative in @('appsettings.Production.json', 'wwwroot\appsettings.Production.json')) {
    $settings = Get-Content -LiteralPath (Join-Path $frontendRoot $relative) -Raw | ConvertFrom-Json
    if ($settings.ApiSetting.baseUrl -ne '/') {
        throw "La configuración $relative debe usar la API relativa al mismo origen."
    }
}

$backend = Get-Content -LiteralPath (Join-Path $repoRoot 'BackEnd\EG.ApiCoreBS\appsettings.Production.json') -Raw | ConvertFrom-Json
foreach ($origin in $backend.CorsSettings.AllowOrigins) {
    $address = $null
    if (-not [uri]::TryCreate($origin, [UriKind]::Absolute, [ref]$address) -or $address.Scheme -ne 'https') {
        throw 'CORS de producción debe declarar orígenes HTTPS explícitos.'
    }
}

Write-Output 'Configuración IIS válida: XML, proxy local, HTTPS, API del mismo origen y CORS explícito.'
Write-Output 'Comprobación de archivos fuente; no instala ni modifica IIS y no comprueba conectividad del servidor.'
