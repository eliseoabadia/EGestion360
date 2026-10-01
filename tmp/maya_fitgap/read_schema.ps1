$ErrorActionPreference='Stop'
$taskConfig=Get-Content -LiteralPath 'BackEnd/EG.ApiCoreBS/appsettings.json' -Raw | ConvertFrom-Json
$taskOut=Join-Path (Get-Location) 'tmp/maya_fitgap/sql_metadata'
New-Item -ItemType Directory -Path $taskOut -Force | Out-Null
$taskQuery=@'
SELECT DB_NAME() database_name, CONVERT(nvarchar(100),SERVERPROPERTY('ProductVersion')) server_version,
 JSON_QUERY((SELECT s.name [schema],t.name [name],t.object_id,
 JSON_QUERY((SELECT c.name,c.column_id,ty.name type_name,TYPE_NAME(c.system_type_id) base_type_name,SCHEMA_NAME(ty.schema_id) type_schema,c.max_length,c.precision,c.scale,c.is_nullable,c.is_identity,
 CONVERT(nvarchar(50),ic.seed_value) identity_seed,CONVERT(nvarchar(50),ic.increment_value) identity_increment,
 c.is_computed,cc.definition computed_definition,cc.is_persisted,dc.definition default_definition,c.collation_name
 FROM sys.columns c JOIN sys.types ty ON ty.user_type_id=c.user_type_id
 LEFT JOIN sys.identity_columns ic ON ic.object_id=c.object_id AND ic.column_id=c.column_id
 LEFT JOIN sys.computed_columns cc ON cc.object_id=c.object_id AND cc.column_id=c.column_id
 LEFT JOIN sys.default_constraints dc ON dc.object_id=c.default_object_id
 WHERE c.object_id=t.object_id ORDER BY c.column_id FOR JSON PATH)) columns,
 JSON_QUERY((SELECT i.name,i.is_unique,i.is_primary_key,i.is_unique_constraint,i.type_desc,i.filter_definition,
 JSON_QUERY((SELECT c.name,ic.key_ordinal,ic.is_descending_key,ic.is_included_column FROM sys.index_columns ic
 JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id
 WHERE ic.object_id=i.object_id AND ic.index_id=i.index_id ORDER BY ic.index_column_id FOR JSON PATH)) columns
 FROM sys.indexes i WHERE i.object_id=t.object_id AND i.index_id>0 AND i.is_hypothetical=0 FOR JSON PATH)) indexes,
 JSON_QUERY((SELECT fk.name,rs.name referenced_schema,rt.name referenced_table,fk.delete_referential_action_desc,fk.update_referential_action_desc,
 JSON_QUERY((SELECT pc.name [column],rc.name referenced_column FROM sys.foreign_key_columns fc
 JOIN sys.columns pc ON pc.object_id=fc.parent_object_id AND pc.column_id=fc.parent_column_id
 JOIN sys.columns rc ON rc.object_id=fc.referenced_object_id AND rc.column_id=fc.referenced_column_id
 WHERE fc.constraint_object_id=fk.object_id ORDER BY fc.constraint_column_id FOR JSON PATH)) columns
 FROM sys.foreign_keys fk JOIN sys.tables rt ON rt.object_id=fk.referenced_object_id JOIN sys.schemas rs ON rs.schema_id=rt.schema_id
 WHERE fk.parent_object_id=t.object_id FOR JSON PATH)) foreign_keys,
 JSON_QUERY((SELECT name,definition FROM sys.check_constraints ck WHERE ck.parent_object_id=t.object_id FOR JSON PATH)) checks
 FROM sys.tables t JOIN sys.schemas s ON s.schema_id=t.schema_id WHERE t.is_ms_shipped=0 ORDER BY s.name,t.name FOR JSON PATH)) tables
FOR JSON PATH,WITHOUT_ARRAY_WRAPPER
'@
foreach($taskDb in @('EmptyProjects','GestionEmpresarial')) {
 $taskBuilder=New-Object System.Data.SqlClient.SqlConnectionStringBuilder($taskConfig.ConnectionStrings.GestionEmpresarialConn)
 $taskBuilder['Initial Catalog']=$taskDb
 $taskBuilder['Connect Timeout']=10
 $taskBuilder['Application Name']='EXUX Metadata SELECT only'
 $taskConnection=New-Object System.Data.SqlClient.SqlConnection($taskBuilder.ConnectionString)
 try {
  $taskConnection.Open();$taskCmd=$taskConnection.CreateCommand();$taskCmd.CommandText=$taskQuery;$taskCmd.CommandTimeout=60
  $taskReader=$taskCmd.ExecuteReader();$taskText=New-Object System.Text.StringBuilder
  while($taskReader.Read()){[void]$taskText.Append($taskReader.GetString(0))};$taskReader.Close()
  [IO.File]::WriteAllText((Join-Path $taskOut ($taskDb+'.json')),$taskText.ToString(),[Text.UTF8Encoding]::new($false))
  $taskParsed=$taskText.ToString()|ConvertFrom-Json
  Write-Output ($taskDb+': '+$taskParsed.tables.Count+' tablas; solo metadatos leídos.')
 } finally {$taskConnection.Dispose()}
}
