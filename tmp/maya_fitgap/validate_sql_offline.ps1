$ErrorActionPreference='Stop'
Add-Type -Path 'C:/Program Files/Microsoft Visual Studio/2022/Enterprise/Common7/IDE/Extensions/Microsoft/SQLDB/DAC/Microsoft.SqlServer.TransactSql.ScriptDom.dll'
$taskParser=[Microsoft.SqlServer.TransactSql.ScriptDom.TSql160Parser]::new($true)
$taskErrorsAll=@();$taskCount=0;$taskDynamic=0
foreach($taskFile in Get-ChildItem -LiteralPath 'output/sql/universidad_maya/EXUX_ERP_Modular' -Filter '*.sql' -Recurse) {
 $taskText=[IO.File]::ReadAllText($taskFile.FullName)
 $taskErrors=$null
 [void]$taskParser.Parse([IO.StringReader]::new($taskText),[ref]$taskErrors)
 foreach($taskError in $taskErrors){$taskErrorsAll += [PSCustomObject]@{File=$taskFile.Name;Module=$taskFile.Directory.Name;Line=$taskError.Line;Message=$taskError.Message}}
 foreach($taskMatch in [regex]::Matches($taskText,"EXEC sys\.sp_executesql N'((?:[^']|'')*)';",[Text.RegularExpressions.RegexOptions]::Singleline)){
  $taskDdl=$taskMatch.Groups[1].Value.Replace("''","'");$taskErrors=$null
  [void]$taskParser.Parse([IO.StringReader]::new($taskDdl),[ref]$taskErrors);$taskDynamic++
  foreach($taskError in $taskErrors){$taskErrorsAll += [PSCustomObject]@{File=$taskFile.Name;Module=$taskFile.Directory.Name;Line=$taskError.Line;Message=$taskError.Message;Ddl=$taskDdl.Substring(0,[Math]::Min(120,$taskDdl.Length))}}
 }
 $taskCount++
}
$taskReport=[PSCustomObject]@{Files=$taskCount;DynamicStatements=$taskDynamic;Errors=@($taskErrorsAll)}
$taskReport|ConvertTo-Json -Depth 5|Set-Content -LiteralPath 'tmp/maya_fitgap/sql_syntax_report.json' -Encoding utf8
[PSCustomObject]@{Files=$taskCount;DynamicStatements=$taskDynamic;ErrorCount=$taskErrorsAll.Count;FirstErrors=@($taskErrorsAll|Select-Object -First 8)}|ConvertTo-Json -Depth 5
if($taskErrorsAll.Count -gt 0){exit 1}
