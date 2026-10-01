$ErrorActionPreference='Stop'
$taskDacPath='C:/Program Files/Microsoft Visual Studio/2022/Enterprise/Common7/IDE/Extensions/Microsoft/SQLDB/DAC'
Add-Type -Path (Join-Path $taskDacPath 'Microsoft.SqlServer.Dac.dll')
Add-Type -Path (Join-Path $taskDacPath 'Microsoft.SqlServer.Dac.Extensions.dll')
$taskModel=[Microsoft.SqlServer.Dac.Model.TSqlModel]::new([Microsoft.SqlServer.Dac.Model.SqlServerVersion]::Sql160,[Microsoft.SqlServer.Dac.Model.TSqlModelOptions]::new())
try {
 $taskSql=[IO.File]::ReadAllText((Join-Path (Get-Location) 'tmp/maya_fitgap/sql_complete_model_offline.sql'))
 $taskModel.AddObjects($taskSql)
 $taskIssues=@($taskModel.Validate())
 $taskIssues|ForEach-Object{[PSCustomObject]@{Message=$_.Message;Severity=$_.Severity;Code=$_.Code}}|ConvertTo-Json -Depth 4|Set-Content -LiteralPath 'tmp/maya_fitgap/sql_model_validation.json' -Encoding utf8
 Write-Output ('Offline model issues: '+$taskIssues.Count)
 $taskIssues|Select-Object -First 15 Message,Severity,Code|Format-List
} finally {$taskModel.Dispose()}
