-- Solo lectura: metadatos agregados, sin texto de consultas ni datos personales.
SET NOCOUNT ON;
SET LOCK_TIMEOUT 3000;

SELECT TOP(15) N'QueryStoreTop' AS Section,q.query_id,q.object_id,
    OBJECT_SCHEMA_NAME(q.object_id) AS SchemaName,OBJECT_NAME(q.object_id) AS ObjectName,
    SUM(r.count_executions) AS Executions,
    SUM(CONVERT(float,r.count_executions)*r.avg_duration)/NULLIF(SUM(r.count_executions),0)/1000.0 AS WeightedAverageMs,
    MAX(r.max_duration)/1000.0 AS MaxMs,
    SUM(CONVERT(float,r.count_executions)*r.avg_logical_io_reads)/NULLIF(SUM(r.count_executions),0) AS AverageLogicalReads,
    MIN(r.first_execution_time) AS FirstExecution,MAX(r.last_execution_time) AS LastExecution
FROM sys.query_store_query q JOIN sys.query_store_plan p ON p.query_id=q.query_id
JOIN sys.query_store_runtime_stats r ON r.plan_id=p.plan_id
GROUP BY q.query_id,q.object_id ORDER BY SUM(CONVERT(float,r.count_executions)*r.avg_duration) DESC;

SELECT N'CrossSchemaReferences' AS Section,OBJECT_SCHEMA_NAME(d.referenced_id) AS SchemaName,
    OBJECT_NAME(d.referenced_id) AS TableName,COUNT(DISTINCT d.referencing_id) AS ReferencingObjects
FROM sys.sql_expression_dependencies d JOIN sys.tables t ON t.object_id=d.referenced_id
WHERE OBJECT_SCHEMA_NAME(t.object_id) IN('dbo','SIS','NOM','ALMA')
GROUP BY d.referenced_id ORDER BY ReferencingObjects DESC;

SELECT N'ActiveRequests' AS Section,COUNT(*) AS UserRequests,
    COALESCE(SUM(CASE WHEN r.total_elapsed_time>5000 THEN 1 ELSE 0 END),0) AS LongerThan5s,
    COALESCE(SUM(CASE WHEN r.blocking_session_id<>0 THEN 1 ELSE 0 END),0) AS BlockedRequests
FROM sys.dm_exec_requests r JOIN sys.dm_exec_sessions s ON s.session_id=r.session_id
WHERE s.is_user_process=1 AND r.session_id<>@@SPID AND r.database_id=DB_ID();

SELECT N'DeadlockRingBuffer' AS Section,
    x.data.value('(/RingBufferTarget/@truncated)[1]','int') AS BufferTruncated,
    x.data.value('count(/RingBufferTarget/event[@name="xml_deadlock_report"])','int') AS RetainedDeadlocks
FROM sys.dm_xe_session_targets t JOIN sys.dm_xe_sessions s ON s.address=t.event_session_address
CROSS APPLY(SELECT TRY_CAST(t.target_data AS xml) AS data) x
WHERE s.name=N'system_health' AND t.target_name=N'ring_buffer';

SELECT N'Statistics' AS Section,OBJECT_SCHEMA_NAME(s.object_id) AS SchemaName,OBJECT_NAME(s.object_id) AS TableName,
    s.name AS StatisticsName,p.last_updated,p.rows,p.rows_sampled,p.modification_counter
FROM sys.stats s JOIN sys.tables t ON t.object_id=s.object_id
OUTER APPLY sys.dm_db_stats_properties(s.object_id,s.stats_id) p
WHERE t.is_ms_shipped=0 AND (p.modification_counter>100 OR (p.rows>1000 AND (p.last_updated IS NULL OR p.rows_sampled<p.rows/10)))
ORDER BY p.modification_counter DESC;
