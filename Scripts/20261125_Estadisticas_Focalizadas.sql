-- Mantenimiento focalizado: no reconstruye indices ni cambia filas de negocio.
SET NOCOUNT ON;
SET LOCK_TIMEOUT 5000;
IF DB_NAME()<>N'GestionEmpresarial' THROW 51230,'Destino incorrecto.',1;
DECLARE @tables TABLE(Id int IDENTITY PRIMARY KEY,SchemaName sysname,TableName sysname);
INSERT @tables VALUES(N'SIS',N'SystemLog'),(N'ALMA',N'PlanConteoCiclico'),
(N'dbo',N'AspNetClaims'),(N'SIS',N'Menu'),(N'SIS',N'MenuRole'),
(N'CONTA',N'PolizaDetalle'),(N'dbo',N'AspNetClaimValues'),(N'SIS',N'NotificacionDestino');
DECLARE @n int=1,@schema sysname,@table sysname,@obj int,@sql nvarchar(max);
WHILE @n<=8
BEGIN
 SELECT @schema=SchemaName,@table=TableName FROM @tables WHERE Id=@n;
 SET @obj=OBJECT_ID(QUOTENAME(@schema)+N'.'+QUOTENAME(@table),N'U');
 IF @obj IS NULL THROW 51231,'Tabla de mantenimiento inexistente.',1;
 IF (SELECT SUM(row_count) FROM sys.dm_db_partition_stats WHERE object_id=@obj AND index_id IN(0,1))>50000
    THROW 51232,'El volumen cambio; reevaluar el mantenimiento focalizado.',1;
 SET @sql=N'UPDATE STATISTICS '+QUOTENAME(@schema)+N'.'+QUOTENAME(@table)+N' WITH FULLSCAN;';
 EXEC sys.sp_executesql @sql;
 SET @n+=1;
END;
