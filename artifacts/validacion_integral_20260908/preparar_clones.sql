SET NOCOUNT ON;
DECLARE @backup nvarchar(300)=CAST(SERVERPROPERTY('InstanceDefaultBackupPath') AS nvarchar(200))+N'\EG_Validation_20260908.bak';
BACKUP DATABASE GestionEmpresarial TO DISK=@backup WITH COPY_ONLY, INIT, CHECKSUM;
DECLARE @data nvarchar(250)=CAST(SERVERPROPERTY('InstanceDefaultDataPath') AS nvarchar(200));
DECLARE @name sysname;
DECLARE dbs CURSOR LOCAL FAST_FORWARD FOR SELECT name FROM (VALUES ('Validation_EG_API_20260908'),('Validation_EG_SQL_20260908'),('Validation_EG_Close_20260908')) AS d(name);
OPEN dbs; FETCH NEXT FROM dbs INTO @name;
WHILE @@FETCH_STATUS=0
BEGIN
 IF DB_ID(@name) IS NOT NULL THROW 51000, 'El clon ya existe, no se reemplaza.', 1;
 DECLARE @cmd nvarchar(max)=N'RESTORE DATABASE '+QUOTENAME(@name)+N' FROM DISK=N'''+@backup+N''' WITH MOVE N''GestionEmpresarial'' TO N'''+@data+@name+N'.mdf'', MOVE N''GestionEmpresarial_log'' TO N'''+@data+@name+N'.ldf'', RECOVERY, CHECKSUM;';
 EXEC(@cmd);
 PRINT 'CLON_READY '+@name;
 FETCH NEXT FROM dbs INTO @name;
END
CLOSE dbs; DEALLOCATE dbs;