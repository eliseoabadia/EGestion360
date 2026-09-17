param([Parameter(Mandatory=$true)][string]$Payload)
$ErrorActionPreference = 'Stop'
Import-Module WebAdministration
$base = 'C:\GestionEmpresarial'
$front = Join-Path $base 'Front'
$back = Join-Path $base 'GE_BACK'
$taskName = 'EGestion360-Backend-5555'
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = Join-Path $base ('RespaldosDeploy\' + $stamp)
New-Item -ItemType Directory -Force $backup | Out-Null
Start-Transcript -Path (Join-Path $backup 'instalacion.log')
try {
    Write-Host 'Comprobando IIS, runtime y sitio HTTPS...'
    $modules = @(Get-WebGlobalModule | Select-Object -ExpandProperty Name)
    if ('RewriteModule' -notin $modules -or 'ApplicationRequestRouting' -notin $modules) { throw 'Este servidor necesita URL Rewrite y ARR instalados. No se modifico el despliegue.' }
    $dotnet = Join-Path $env:ProgramFiles 'dotnet\dotnet.exe'
    if (!(Test-Path $dotnet) -or !((& $dotnet --list-runtimes) -match 'Microsoft.AspNetCore.App 10\.')) { throw 'Falta ASP.NET Core Runtime 10 x64.' }
    $sites = @(Get-Website | Where-Object { [Environment]::ExpandEnvironmentVariables($_.physicalPath).TrimEnd('\') -ieq $front })
    if ($sites.Count -ne 1) { throw "Debe existir un unico sitio IIS cuya ruta sea $front. No se modifico ningun sitio." }
    $site = $sites[0].Name
    if (!(@(Get-WebBinding -Name $site -Protocol https | Where-Object { $_.bindingInformation -match ':443:' }).Count)) { throw 'El sitio frontend debe tener su enlace HTTPS 443 y certificado.' }
    $bindings5555 = @(Get-Website | ForEach-Object { $n=$_.Name; Get-WebBinding -Name $n | Where-Object { $_.bindingInformation -match ':5555:' } | ForEach-Object { $n } })
    if (@($bindings5555 | Where-Object { $_ -ne 'GE_BACK' }).Count) { throw 'Otro sitio distinto de GE_BACK ocupa 5555. No se detendra automaticamente.' }
    $stage = Join-Path $backup 'Paquete'
    Expand-Archive -LiteralPath $Payload -DestinationPath $stage
    if (!(Test-Path "$stage\Back\EG.ApiCoreBS.dll") -or !(Test-Path "$stage\Front\web.config")) { throw 'Paquete incompleto.' }
    $indexContent = Get-Content "$stage\Front\wwwroot\index.html" -Raw
    if ($indexContent.Contains(':8440') -or !$indexContent.Contains('window.location.origin')) { throw 'El paquete frontend contiene una URL de API incorrecta.' }
    # Conservar las configuraciones propias del servidor, sin imprimir secretos.
    foreach ($configName in @('appsettings.json','appsettings.Production.json')) {
        if (Test-Path "$back\$configName") { Copy-Item -LiteralPath "$back\$configName" -Destination "$stage\Back\$configName" -Force }
    }
    $cfgPath = "$stage\Back\appsettings.Production.json"
    $cfg = Get-Content $cfgPath -Raw | ConvertFrom-Json
    $cfg | Add-Member -Force NoteProperty Kestrel ([pscustomobject]@{Endpoints=[pscustomobject]@{LocalHttp=[pscustomobject]@{Url='http://localhost:5555'}}})
    $cfg | Add-Member -Force NoteProperty Hosting ([pscustomobject]@{UseHttpsRedirection=$false})
    $cfg | ConvertTo-Json -Depth 100 | Set-Content $cfgPath -Encoding UTF8
    Backup-WebConfiguration -Name ('EGestion360-' + $stamp)
    foreach ($pair in @(@($front,'Front'),@($back,'GE_BACK'))) {
        if (Test-Path $pair[0]) { Copy-Item -LiteralPath $pair[0] -Destination (Join-Path $backup $pair[1]) -Recurse -Force }
    }
    $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($existingTask) { Export-ScheduledTask -TaskName $taskName | Set-Content "$backup\tarea-anterior.xml"; Stop-ScheduledTask -TaskName $taskName }
    if ('GE_BACK' -in $bindings5555) {
        Stop-Website -Name 'GE_BACK'
        Set-ItemProperty 'IIS:\Sites\GE_BACK' -Name serverAutoStart -Value $false
    }
    # Detener solamente procesos del backend cuya carpeta se puede identificar.
    Get-CimInstance Win32_Process | Where-Object {
        $_.Name -eq 'dotnet.exe' -and $_.CommandLine -like ('*' + $back + '\EG.ApiCoreBS.dll*')
    } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
    Start-Sleep -Seconds 2
    $listeners = @(Get-NetTCPConnection -LocalPort 5555 -State Listen -ErrorAction SilentlyContinue)
    if ($listeners.Count) {
        # El CMD anterior usa ruta relativa: identificar el DLL cargado antes de detenerlo.
        foreach ($ownerId in ($listeners.OwningProcess | Select-Object -Unique)) {
            if ($ownerId -eq 4) { throw 'HTTP.sys sigue ocupando 5555. Se guardo el respaldo; no se detuvo ningun servicio del sistema.' }
            $p = Get-Process -Id $ownerId
            $command = (Get-CimInstance Win32_Process -Filter "ProcessId=$ownerId").CommandLine
            $ours = ($p.ProcessName -eq 'dotnet') -and ($command -match '(?i)(?:^|\s)"?EG\.ApiCoreBS\.dll"?\s*$' -or @($p.Modules | Where-Object { $_.FileName -ieq "$back\EG.ApiCoreBS.dll" }).Count -gt 0)
            if (!$ours) { throw "El proceso $ownerId ocupa 5555 y no se pudo verificar que sea este backend. Cierra su CMD y ejecuta nuevamente el instalador." }
            Stop-Process -Id $ownerId -Force
        }
    }
    Stop-Website -Name $site
    $frontStopped = $true
    New-Item -ItemType Directory -Force $front,$back | Out-Null
    Copy-Item "$stage\Front\*" $front -Recurse -Force
    Copy-Item "$stage\Back\*" $back -Recurse -Force
    $runner = @"
@echo off
cd /d "$back"
set ASPNETCORE_ENVIRONMENT=Production
set DOTNET_ENVIRONMENT=Production
"$dotnet" "$back\EG.ApiCoreBS.dll" >> "$back\logs\backend.log" 2>&1
exit /b %errorlevel%
"@
    [IO.File]::WriteAllText("$back\Ejecutar-Backend-Automatico.cmd", $runner, [Text.Encoding]::Default)
    New-Item -ItemType Directory -Force "$back\logs" | Out-Null
    & icacls.exe $back /grant '*S-1-5-20:(OI)(CI)M' /T /Q | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'No se pudieron asignar permisos a NETWORK SERVICE.' }
    Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter 'system.webServer/proxy' -Name enabled -Value $true
    $action = New-ScheduledTaskAction -Execute "$env:SystemRoot\System32\cmd.exe" -Argument ('/d /c ""' + $back + '\Ejecutar-Backend-Automatico.cmd""') -WorkingDirectory $back
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $principal = New-ScheduledTaskPrincipal -UserId 'S-1-5-20' -LogonType ServiceAccount
    $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit ([TimeSpan]::Zero) -RestartCount 999 -RestartInterval (New-TimeSpan -Minutes 1) -StartWhenAvailable -MultipleInstances IgnoreNew -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
    Start-ScheduledTask -TaskName $taskName
    Start-Website -Name $site
    $frontStopped = $false
    Write-Host 'Esperando respuesta del backend...'
    $healthy = $false
    for ($i=0; $i -lt 30; $i++) {
        try { $result=Invoke-RestMethod 'http://localhost:5555/api/Navigate/version' -TimeoutSec 3; if ($result.success) { $healthy=$true; break } } catch {}
        Start-Sleep -Seconds 2
    }
    if (!$healthy) { throw "El backend no respondio. Revisa $back\logs\backend.log. Respaldo: $backup" }
    $public = Invoke-RestMethod 'https://74.208.88.178/api/Navigate/version' -TimeoutSec 15
    if (!$public.success) { throw 'La API local funciona, pero fallo la comprobacion HTTPS publica.' }
    $page = Invoke-WebRequest ('https://74.208.88.178/index.html?deploy=' + $stamp) -UseBasicParsing -TimeoutSec 15
    if ($page.Content.Contains(':8440') -or !$page.Content.Contains('window.location.origin')) { throw 'La API funciona, pero IIS no esta entregando el index.html corregido. Revisar la ruta del sitio frontend.' }
    Write-Host "INSTALACION CORRECTA. Version $($public.version). Puedes cerrar esta ventana."
    Write-Host 'Front: https://74.208.88.178/ - Back: http://localhost:5555/'
    Write-Host "Arranque automatico: tarea $taskName. Respaldo: $backup"
} catch {
    if ($frontStopped) { try { Start-Website -Name $site } catch {} }
    Write-Host ('ERROR: ' + $_.Exception.Message) -ForegroundColor Red
    Write-Host "Respaldo y registro: $backup. No se ejecuta una restauracion automatica."
    exit 1
} finally { Stop-Transcript }