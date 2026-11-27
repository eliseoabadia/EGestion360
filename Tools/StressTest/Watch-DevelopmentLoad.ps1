param([int]$Seconds = 180, [string]$Output = 'tmp/capacity-dev/resources.json')
$ErrorActionPreference = 'Stop'
$connection = [System.Data.SqlClient.SqlConnection]::new('Data Source=.;Initial Catalog=GestionEmpresarial;Integrated Security=True;TrustServerCertificate=True;Application Name=EGestion360-DevCapacityReadOnly;Connect Timeout=5')
$samples = [System.Collections.Generic.List[object]]::new()
$until = [DateTime]::UtcNow.AddSeconds($Seconds)
try {
    $connection.Open()
    while ([DateTime]::UtcNow -lt $until) {
        $command = $connection.CreateCommand()
        $command.CommandTimeout = 5
        $command.CommandText = @'
SELECT
 (SELECT COUNT(*) FROM sys.dm_exec_requests WHERE database_id=DB_ID() AND session_id<>@@SPID) AS ActiveRequests,
 (SELECT COUNT(*) FROM sys.dm_exec_requests WHERE database_id=DB_ID() AND session_id<>@@SPID AND blocking_session_id<>0) AS BlockedRequests,
 (SELECT COUNT(*) FROM sys.dm_exec_requests WHERE database_id=DB_ID() AND session_id<>@@SPID AND total_elapsed_time>5000) AS LongerThan5s,
 (SELECT cntr_value FROM sys.dm_os_performance_counters WHERE counter_name='Number of Deadlocks/sec' AND instance_name='_Total') AS ServerDeadlocks
'@
        try {
            $reader = $command.ExecuteReader()
            $table = [System.Data.DataTable]::new()
            $table.Load($reader)
            $row = $table.Rows[0]
            $processes = @(Get-Process -Name dotnet,sqlservr -ErrorAction SilentlyContinue | Select-Object Id,ProcessName,CPU,WorkingSet64)
            $samples.Add([pscustomobject]@{ Utc=[DateTime]::UtcNow.ToString('o');ActiveRequests=[int]$row.ActiveRequests;BlockedRequests=[int]$row.BlockedRequests;LongerThan5s=[int]$row.LongerThan5s;ServerDeadlocks=$row.ServerDeadlocks;Processes=$processes })
            $samples | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $Output
        } finally { $command.Dispose() }
        Start-Sleep -Seconds 2
    }
} finally { $connection.Dispose() }
