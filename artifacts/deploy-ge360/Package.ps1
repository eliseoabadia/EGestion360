$ErrorActionPreference='Stop'
$dest='C:\Temp\GE360Almacen'
$front="$dest\Front"; $back="$dest\Back"
$connection='Data Source=2A95576;Initial Catalog=GE360Almacen;User ID=sa;Password=elneclp*1;TrustServerCertificate=True;MultipleActiveResultSets=True;Application Name=GE360Almacen;Max Pool Size=100;Min Pool Size=5;Connect Timeout=10;Pooling=True;Encrypt=False;'
foreach($file in @('appsettings.json','appsettings.Production.json')) {
 $path=Join-Path $back $file
 $cfg=Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
 $cfg.ConnectionStrings.GestionEmpresarialConn=$connection
 $cfg.PSObject.Properties.Remove('Kestrel')
 $cfg | Add-Member -Force NoteProperty Hosting ([pscustomobject]@{UseHttpsRedirection=$false})
 $cfg.CorsSettings.AllowOrigins=@('https://74.208.88.178:8480')
 $cfg.JsonWebTokenKeys.ValidIssuer='https://74.208.88.178:8480/'
 $cfg.JsonWebTokenKeys.ValidAudience='https://74.208.88.178:8480/'
 $cfg.DocumentStorage.BasePath='C:/inetpub/wwwroot/GE360Almacen/Back/Documentos'
 $cfg.DocumentRag.TempPath='C:/inetpub/wwwroot/GE360Almacen/Back/RagTemp'
 $cfg.Reporting.LogoPath='C:/inetpub/wwwroot/GE360Almacen/Front/wwwroot/img/'
 $cfg | ConvertTo-Json -Depth 50 | Set-Content -LiteralPath $path -Encoding utf8
}
foreach($file in @('appsettings.Development.json','Iniciar-Backend-Local.cmd','DESPLIEGUE-LOCAL.txt')) { $path=Join-Path $back $file; if(Test-Path $path){Remove-Item -LiteralPath $path} }
$log=Join-Path $back 'log4net.config'
(Get-Content -LiteralPath $log -Raw).Replace('C:\Temp\Logs\log.txt','C:\inetpub\wwwroot\GE360Almacen\Back\logs\log.txt') | Set-Content -LiteralPath $log -Encoding utf8
[xml]$web=Get-Content "$back\web.config"
$asp=$web.configuration.location.'system.webServer'.aspNetCore
$envs=$web.CreateElement('environmentVariables'); $env=$web.CreateElement('environmentVariable'); $env.SetAttribute('name','ASPNETCORE_ENVIRONMENT'); $env.SetAttribute('value','Production'); $envs.AppendChild($env) | Out-Null; $asp.AppendChild($envs) | Out-Null
$web.Save("$back\web.config")
foreach($base in @($front,"$front\wwwroot")) {
 foreach($name in @('appsettings.json','appsettings.Production.json')) {
  '{"ApiSetting":{"baseUrl":"/"}}' | Set-Content -LiteralPath (Join-Path $base $name) -Encoding utf8
  foreach($ext in @('.gz','.br')) { $path=Join-Path $base ($name+$ext); if(Test-Path $path){Remove-Item -LiteralPath $path} }
 }
}
(Get-Content "$front\web.config" -Raw).Replace('localhost 5555','localhost 5580').Replace('http://localhost:5555/','http://127.0.0.1:5580/') | Set-Content "$front\web.config" -Encoding utf8
(Get-Content "$front\wwwroot\web.config" -Raw).Replace('https://74.208.88.178 wss:','https://74.208.88.178:8480 wss:') | Set-Content "$front\wwwroot\web.config" -Encoding utf8
Copy-Item "$dest\ConfiguratorBuild\Configurar-GE360Almacen.exe" "$dest\Configurar-GE360Almacen.exe" -Force
Copy-Item "$PSScriptRoot\Configurar.ps1" "$dest\Configurar-IIS.ps1" -Force
Copy-Item "$PSScriptRoot\LEEME-IIS.txt" "$dest\LEEME-IIS.txt" -Force
Add-Type -AssemblyName System.IO.Compression.FileSystem
foreach($pair in @(@($front,'GE360Almacen.zip'),@($back,'GE360Almacen_Back.zip'))) {
 $zip=Join-Path $dest $pair[1]
 if(Test-Path $zip){throw "Ya existe $zip; no se sobrescribio."}
 [System.IO.Compression.ZipFile]::CreateFromDirectory($pair[0],$zip,[System.IO.Compression.CompressionLevel]::Optimal,$false)
 $check=[System.IO.Compression.ZipFile]::OpenRead($zip)
 try { foreach($entry in $check.Entries) { $stream=$entry.Open(); try{$stream.CopyTo([System.IO.Stream]::Null)}finally{$stream.Dispose()} }; Write-Host "$($pair[1]): $($check.Entries.Count) entradas verificadas" } finally {$check.Dispose()}
}
Get-FileHash "$dest\GE360Almacen.zip","$dest\GE360Almacen_Back.zip","$dest\Configurar-GE360Almacen.exe" | Select-Object Hash,Path | Format-Table -AutoSize | Out-String -Width 300 | Set-Content "$dest\SHA256.txt"
