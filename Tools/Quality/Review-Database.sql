-- Diagnostico de solo lectura. Ejecutar en la base que se desea revisar.
-- No ejecuta procedimientos de negocio ni cambia opciones del servidor/base.
SET NOCOUNT ON;
SET LOCK_TIMEOUT 3000;

SELECT N'Environment' AS Section, DB_NAME() AS DatabaseName,
    CONVERT(nvarchar(128), SERVERPROPERTY('ProductVersion')) AS ProductVersion,
    d.compatibility_level, d.is_read_committed_snapshot_on, d.snapshot_isolation_state_desc,
    d.recovery_model_desc, d.is_auto_close_on, d.is_auto_shrink_on,
    (SELECT sqlserver_start_time FROM sys.dm_os_sys_info) AS MetricsSince
FROM sys.databases d WHERE d.database_id=DB_ID();

SELECT N'Schemas' AS Section, s.name AS SchemaName, COUNT(*) AS Tables,
    SUM(COALESCE(p.RowsTotal,0)) AS ApproximateRows
FROM sys.tables t JOIN sys.schemas s ON s.schema_id=t.schema_id
OUTER APPLY (SELECT SUM(rows) AS RowsTotal FROM sys.partitions WHERE object_id=t.object_id AND index_id IN (0,1)) p
WHERE t.is_ms_shipped=0 GROUP BY s.name ORDER BY Tables DESC;

SELECT N'Tables' AS Section, s.name AS SchemaName,t.name AS TableName,
    p.RowsTotal AS ApproximateRows, p.UsedPages*8 AS UsedKB,
    CASE WHEN EXISTS(SELECT 1 FROM sys.key_constraints k WHERE k.parent_object_id=t.object_id AND k.type='PK') THEN 1 ELSE 0 END AS HasPrimaryKey,
    CASE WHEN EXISTS(SELECT 1 FROM sys.columns c WHERE c.object_id=t.object_id AND c.system_type_id=189) THEN 1 ELSE 0 END AS HasRowVersion,
    CASE WHEN EXISTS(SELECT 1 FROM sys.columns c WHERE c.object_id=t.object_id AND c.name LIKE '%Empresa%') THEN 1 ELSE 0 END AS HasEmpresaNamedColumn
FROM sys.tables t JOIN sys.schemas s ON s.schema_id=t.schema_id
OUTER APPLY(SELECT SUM(CASE WHEN index_id IN(0,1) THEN row_count ELSE 0 END) AS RowsTotal,SUM(used_page_count) AS UsedPages FROM sys.dm_db_partition_stats WHERE object_id=t.object_id) p
WHERE t.is_ms_shipped=0 ORDER BY s.name,t.name;

SELECT N'ForeignKeys' AS Section, OBJECT_SCHEMA_NAME(f.parent_object_id) AS SchemaName,
    OBJECT_NAME(f.parent_object_id) AS TableName, f.name AS ForeignKeyName,
    OBJECT_SCHEMA_NAME(f.referenced_object_id) AS ReferencedSchema,OBJECT_NAME(f.referenced_object_id) AS ReferencedTable,
    f.is_disabled,f.is_not_trusted,
    STUFF((SELECT ','+COL_NAME(fc.parent_object_id,fc.parent_column_id) FROM sys.foreign_key_columns fc WHERE fc.constraint_object_id=f.object_id ORDER BY fc.constraint_column_id FOR XML PATH(''),TYPE).value('.','nvarchar(max)'),1,1,'') AS Columns,
    CASE WHEN EXISTS(
        SELECT 1 FROM sys.indexes i WHERE i.object_id=f.parent_object_id AND i.is_disabled=0 AND i.is_hypothetical=0 AND i.has_filter=0
        AND NOT EXISTS(SELECT 1 FROM sys.foreign_key_columns fc WHERE fc.constraint_object_id=f.object_id
            AND NOT EXISTS(SELECT 1 FROM sys.index_columns ic WHERE ic.object_id=i.object_id AND ic.index_id=i.index_id AND ic.key_ordinal=fc.constraint_column_id AND ic.column_id=fc.parent_column_id))
    ) THEN 1 ELSE 0 END AS HasLeadingIndex
FROM sys.foreign_keys f ORDER BY SchemaName,TableName;

SELECT N'CheckConstraints' AS Section,OBJECT_SCHEMA_NAME(parent_object_id) AS SchemaName,
    OBJECT_NAME(parent_object_id) AS TableName,name AS ConstraintName,is_disabled,is_not_trusted
FROM sys.check_constraints ORDER BY SchemaName,TableName;

SELECT N'Indexes' AS Section,OBJECT_SCHEMA_NAME(i.object_id) AS SchemaName,OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,i.type_desc,i.is_unique,i.is_primary_key,i.is_disabled,i.has_filter,i.filter_definition,
    STUFF((SELECT ','+CONVERT(nvarchar(10),ic.column_id)+CASE WHEN ic.is_descending_key=1 THEN 'D' ELSE 'A' END FROM sys.index_columns ic WHERE ic.object_id=i.object_id AND ic.index_id=i.index_id AND ic.key_ordinal>0 ORDER BY ic.key_ordinal FOR XML PATH(''),TYPE).value('.','nvarchar(max)'),1,1,'') AS KeySignature,
    STUFF((SELECT ','+CONVERT(nvarchar(10),ic.column_id) FROM sys.index_columns ic WHERE ic.object_id=i.object_id AND ic.index_id=i.index_id AND ic.is_included_column=1 ORDER BY ic.column_id FOR XML PATH(''),TYPE).value('.','nvarchar(max)'),1,1,'') AS IncludeSignature,
    COALESCE(u.user_seeks,0) AS UserSeeks,COALESCE(u.user_scans,0) AS UserScans,
    COALESCE(u.user_lookups,0) AS UserLookups,COALESCE(u.user_updates,0) AS UserUpdates
FROM sys.indexes i JOIN sys.tables t ON t.object_id=i.object_id
LEFT JOIN sys.dm_db_index_usage_stats u ON u.database_id=DB_ID() AND u.object_id=i.object_id AND u.index_id=i.index_id
WHERE t.is_ms_shipped=0 AND i.index_id>0 ORDER BY SchemaName,TableName,IndexName;

SELECT N'Columns' AS Section,s.name AS SchemaName,t.name AS TableName,c.name AS ColumnName,
    ty.name AS DataType,c.max_length,c.precision,c.scale,c.is_nullable
FROM sys.columns c JOIN sys.tables t ON t.object_id=c.object_id JOIN sys.schemas s ON s.schema_id=t.schema_id
JOIN sys.types ty ON ty.user_type_id=c.user_type_id
WHERE t.is_ms_shipped=0 AND (ty.name IN('float','real','money','smallmoney','text','ntext','image') OR c.name LIKE '%Empresa%' OR ty.name IN('decimal','numeric'))
ORDER BY s.name,t.name,c.column_id;

SELECT N'Modules' AS Section,s.name AS SchemaName,o.name AS ObjectName,o.type_desc,
    LEN(m.definition) AS DefinitionLength,
    CASE WHEN m.definition LIKE '%NOLOCK%' OR m.definition LIKE '%READUNCOMMITTED%' THEN 1 ELSE 0 END AS DirtyReadText,
    CASE WHEN m.definition LIKE '%SELECT%*%FROM%' THEN 1 ELSE 0 END AS SelectStarText,
    CASE WHEN m.definition LIKE '%CURSOR%' THEN 1 ELSE 0 END AS CursorText,
    CASE WHEN m.definition LIKE '%BEGIN TRAN%' THEN 1 ELSE 0 END AS TransactionText,
    CASE WHEN m.definition LIKE '%XACT_ABORT%' THEN 1 ELSE 0 END AS XactAbortText,
    CASE WHEN m.definition LIKE '%BEGIN CATCH%' THEN 1 ELSE 0 END AS CatchText,
    CASE WHEN m.definition LIKE '%sp_executesql%' OR m.definition LIKE '%EXEC(%' OR m.definition LIKE '%EXEC (%' THEN 1 ELSE 0 END AS DynamicSqlText
FROM sys.sql_modules m JOIN sys.objects o ON o.object_id=m.object_id JOIN sys.schemas s ON s.schema_id=o.schema_id
WHERE o.is_ms_shipped=0 AND o.type IN('P','V','FN','IF','TF','TR') ORDER BY DefinitionLength DESC;

SELECT TOP(15) N'ProcedureStats' AS Section,OBJECT_SCHEMA_NAME(object_id) AS SchemaName,OBJECT_NAME(object_id) AS ProcedureName,
    cached_time,execution_count,last_execution_time,
    total_elapsed_time/1000.0/NULLIF(execution_count,0) AS AverageMs,max_elapsed_time/1000.0 AS MaxMs,
    total_logical_reads/NULLIF(execution_count,0) AS AverageLogicalReads
FROM sys.dm_exec_procedure_stats WHERE database_id=DB_ID() ORDER BY total_elapsed_time DESC;

SELECT N'QueryStore' AS Section,actual_state_desc,desired_state_desc,current_storage_size_mb,max_storage_size_mb,readonly_reason
FROM sys.database_query_store_options;

SELECT TOP(15) N'MissingIndexCandidates' AS Section,OBJECT_SCHEMA_NAME(d.object_id) AS SchemaName,OBJECT_NAME(d.object_id) AS TableName,
    d.equality_columns,d.inequality_columns,d.included_columns,
    gs.user_seeks,gs.user_scans,gs.avg_total_user_cost,gs.avg_user_impact,
    gs.last_user_seek
FROM sys.dm_db_missing_index_details d JOIN sys.dm_db_missing_index_groups g ON g.index_handle=d.index_handle
JOIN sys.dm_db_missing_index_group_stats gs ON gs.group_handle=g.index_group_handle
WHERE d.database_id=DB_ID() ORDER BY (gs.user_seeks+gs.user_scans)*gs.avg_total_user_cost*gs.avg_user_impact DESC;

SELECT N'Synonyms' AS Section,SCHEMA_NAME(schema_id) AS SchemaName,name AS SynonymName,base_object_name FROM sys.synonyms;

SELECT N'PotentialDependencies' AS Section,OBJECT_SCHEMA_NAME(d.referencing_id) AS SchemaName,
    OBJECT_NAME(d.referencing_id) AS ObjectName,d.referenced_schema_name,d.referenced_entity_name,d.is_schema_bound_reference
FROM sys.sql_expression_dependencies d JOIN sys.objects o ON o.object_id=d.referencing_id
WHERE d.referenced_id IS NULL AND d.referenced_entity_name IS NOT NULL AND o.is_ms_shipped=0
ORDER BY SchemaName,ObjectName;
