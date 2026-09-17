param([Parameter(Mandatory=$true)][string]$PackagePath)
$ErrorActionPreference='Stop'
try {
 Import-Module WebAdministration
 $appcmd="$env:windir\System32\inetsrv\appcmd.exe"
 $modules = (& $appcmd list modules) -join "`n"
 if ($modules -notmatch 'AspNetCoreModuleV2') { throw 'Instale .NET 10 Hosting Bundle (despues de IIS) y vuelva a ejecutar.' }
 if ($modules -notmatch 'RewriteModule') { throw 'Instale IIS URL Rewrite 2.1 y vuelva a ejecutar.' }
 if (!(Test-Path "$env:windir\System32\inetsrv\config\schema\arr_schema.xml")) { throw 'Instale IIS Application Request Routing 3.0 y vuelva a ejecutar.' }
 foreach($name in @('GE360Almacen.zip','GE360Almacen_Back.zip')) { if (!(Test-Path (Join-Path $PackagePath $name))) { throw "Falta $name junto al EXE." } }
 $site='GE360Almacen'; $backSite='GE360Almacen_Back'; $root='C:\inetpub\wwwroot\GE360Almacen'
 $other = Get-Website | Where-Object { $_.Name -ne $site -and @($_.Bindings.Collection | Where-Object { $_.bindingInformation -match ':8480:' }).Count -gt 0 }
 if ($other) { throw 'El puerto 8480 pertenece a otro sitio IIS. Libere o ajuste ese enlace antes de continuar.' }
 $otherBack=Get-Website | Where-Object { $_.Name -ne $backSite -and @($_.Bindings.Collection | Where-Object { $_.bindingInformation -match ':5580:' }).Count -gt 0 }
 if ($otherBack) { throw 'El puerto 5580 pertenece a otro sitio IIS.' }
 foreach($l in @(Get-NetTCPConnection -LocalPort 5580 -State Listen -ErrorAction SilentlyContinue)) { if($l.OwningProcess -ne 4) { throw 'El puerto 5580 esta ocupado por un proceso ajeno a IIS.' } }
 foreach($n in @($site,$backSite)) {
  $expected=if($n -eq $site){"$root\Front"}else{"$root\Back"}
  if ((Test-Path "IIS:\Sites\$n") -and (Get-Item "IIS:\Sites\$n").physicalPath -ne $expected) { throw "El sitio $n ya existe con otra ruta. No se modifico." }
 }
 $certs=@(Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.HasPrivateKey -and $_.NotAfter -gt (Get-Date) })
 $certs | Format-Table Subject,Thumbprint,NotAfter
 $thumb=(Read-Host 'Pegue la huella del certificado HTTPS para 74.208.88.178').Replace(' ','')
 $cert=$certs | Where-Object Thumbprint -eq $thumb
 if (!$cert) { throw 'Certificado no encontrado o vencido. Importe un certificado valido en Equipo local / Personal.' }
 & $appcmd add backup ("GE360Almacen-" + (Get-Date -Format yyyyMMdd-HHmmss))
 if ($LASTEXITCODE -ne 0) { throw 'No se pudo respaldar IIS.' }
 if (Test-Path $root) {
  $backup="$root-backup-$(Get-Date -Format yyyyMMdd-HHmmss)"
  Copy-Item -LiteralPath $root -Destination $backup -Recurse
 }
 if (Test-Path "IIS:\Sites\$site") { Stop-Website $site }
 if (Test-Path "IIS:\Sites\$backSite") { Stop-Website $backSite }
 foreach($n in @($site,$backSite)) { if ((Test-Path "IIS:\AppPools\$n") -and (Get-WebAppPoolState $n).Value -ne 'Stopped') { Stop-WebAppPool $n } }
 Start-Sleep -Seconds 2
 New-Item "$root\Front","$root\Back" -ItemType Directory -Force | Out-Null
 Expand-Archive (Join-Path $PackagePath 'GE360Almacen.zip') "$root\Front" -Force
 Expand-Archive (Join-Path $PackagePath 'GE360Almacen_Back.zip') "$root\Back" -Force
 if (!(Test-Path "IIS:\AppPools\$site")) { New-WebAppPool $site | Out-Null }
 Set-ItemProperty "IIS:\AppPools\$site" managedRuntimeVersion ''
 if (!(Test-Path "IIS:\Sites\$site")) { New-Website -Name $site -PhysicalPath "$root\Front" -ApplicationPool $site -Port 8480 -Ssl | Out-Null }
 Set-ItemProperty "IIS:\Sites\$site" physicalPath "$root\Front"
 Set-ItemProperty "IIS:\Sites\$site" applicationPool $site
 if (!(Get-WebBinding -Name $site -Protocol https -Port 8480)) { New-WebBinding -Name $site -Protocol https -Port 8480 -IPAddress '*' }
 (Get-WebBinding -Name $site -Protocol https -Port 8480).AddSslCertificate($thumb,'My')
 Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter 'system.webServer/proxy' -Name enabled -Value true
 & icacls "$root\Front" /grant "IIS AppPool\${site}:(OI)(CI)RX" /T /Q | Out-Null
 if ($LASTEXITCODE -ne 0) { throw 'No se pudieron configurar los permisos del frontend.' }
 if (!(Test-Path "IIS:\AppPools\$backSite")) { New-WebAppPool $backSite | Out-Null }
 if (!(Test-Path "IIS:\Sites\$backSite")) { New-Website -Name $backSite -PhysicalPath "$root\Back" -ApplicationPool $backSite -Port 5580 -IPAddress '127.0.0.1' | Out-Null }
 if (!(Get-WebBinding -Name $backSite -Protocol http | Where-Object bindingInformation -eq '127.0.0.1:5580:')) { New-WebBinding -Name $backSite -Protocol http -Port 5580 -IPAddress '127.0.0.1' }
 foreach($n in @($site,$backSite)) {
  Set-ItemProperty "IIS:\AppPools\$n" managedRuntimeVersion ''
  Set-ItemProperty "IIS:\AppPools\$n" enable32BitAppOnWin64 false
  Set-ItemProperty "IIS:\AppPools\$n" autoStart true
  Set-ItemProperty "IIS:\AppPools\$n" startMode AlwaysRunning
  Set-ItemProperty "IIS:\AppPools\$n" processModel.idleTimeout ([TimeSpan]::Zero)
  Set-ItemProperty "IIS:\Sites\$n" serverAutoStart true
  Set-ItemProperty "IIS:\Sites\$n" applicationPool $n
  if($modules -match 'ApplicationInitializationModule') { Set-ItemProperty "IIS:\Sites\$n" applicationDefaults.preloadEnabled true }
 }
 & icacls "$root\Back" /grant "IIS AppPool\${backSite}:(OI)(CI)RX" /T /Q | Out-Null
 if ($LASTEXITCODE -ne 0) { throw 'No se pudieron configurar los permisos del backend.' }
 foreach($folder in @('logs','Documentos','RagTemp')) {
  New-Item "$root\Back\$folder" -ItemType Directory -Force | Out-Null
  & icacls "$root\Back\$folder" /grant "IIS AppPool\${backSite}:(OI)(CI)M" /T /Q | Out-Null
  if ($LASTEXITCODE -ne 0) { throw "No se pudieron configurar permisos de $folder." }
 }
 if (!(Get-NetFirewallRule -DisplayName 'GE360Almacen HTTPS 8480' -ErrorAction SilentlyContinue)) { New-NetFirewallRule -DisplayName 'GE360Almacen HTTPS 8480' -Direction Inbound -Protocol TCP -LocalPort 8480 -Action Allow | Out-Null }
 Set-Service WAS -StartupType Automatic
 Set-Service W3SVC -StartupType Automatic
 Start-Service WAS
 Start-Service W3SVC
 foreach($n in @($site,$backSite)) { if((Get-WebAppPoolState $n).Value -ne 'Started') { Start-WebAppPool $n } }
 Start-Website $backSite
 Start-Website $site
 $ok=$false
 for($i=0;$i -lt 30;$i++) { try { $r=Invoke-RestMethod 'http://localhost:5580/api/Navigate/ping' -TimeoutSec 2; if($r.success) {$ok=$true; break} } catch {}; Start-Sleep -Seconds 2 }
 if (!$ok) { throw 'Backend sin respuesta. Revise el sitio IIS GE360Almacen_Back, los logs y el Visor de eventos.' }
 $public=Invoke-RestMethod 'https://74.208.88.178:8480/api/Navigate/ping' -TimeoutSec 15
 if (!$public.success) { throw 'Fallo la comprobacion del proxy HTTPS.' }
 Write-Host 'Listo: https://74.208.88.178:8480/ y backend http://localhost:5580/'
 Write-Host 'Valide inicio de sesion y operaciones de almacen para comprobar SQL Server.'
 exit 0
} catch { Write-Host $_ -ForegroundColor Red; exit 1 }
