# Ejecutar una sola vez desde PowerShell como Administrador.
$serviceName = 'SQLSERVERAGENT'
$service = Get-Service -Name $serviceName -ErrorAction Stop

Set-Service -Name $serviceName -StartupType Automatic
if ($service.Status -ne 'Running')
{
    Start-Service -Name $serviceName
}

Get-Service -Name $serviceName | Select-Object Name, DisplayName, Status, StartType

