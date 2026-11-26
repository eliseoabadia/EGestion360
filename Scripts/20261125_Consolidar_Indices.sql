-- Consolida cuatro indices no unicos cuya cobertura ya existe en otro unico.
-- No elimina PK, restricciones unicas ni datos. Guarda integridad y metadatos.
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET LOCK_TIMEOUT 5000;
IF DB_NAME()<>N'GestionEmpresarial' THROW 51220,'Destino incorrecto.',1;
DECLARE @plan TABLE(Id int IDENTITY PRIMARY KEY,TableName nvarchar(260),RemoveName sysname,KeepName sysname);
INSERT @plan(TableName,RemoveName,KeepName) VALUES
(N'ALMA.TipoBaja',N'IX_TipoBaja_Clave_1243867498',N'UQ_TipoBaja_Clave'),
(N'CONTA.CuentaEspecial',N'IX_CuentaEspecial_Clave_1035866757',N'UQ_CuentaEspecial_Clave'),
(N'SIS.DocumentoTipoAnotacion',N'IX_DocumentoTipoAnotacion_Clave_2127346643',N'UX_DocumentoTipoAnotacion_Clave'),
(N'SIS.NotificacionTipo',N'IX_NotificacionTipo_Clave_943342425',N'UQ__Notifica__E8181E1184A89DCD');
BEGIN TRY
 BEGIN TRANSACTION;
 DECLARE @n int=1,@table nvarchar(260),@remove sysname,@keep sysname,@obj int,@old int,@new int,@sql nvarchar(max);
 WHILE @n<=4
 BEGIN
  SELECT @table=TableName,@remove=RemoveName,@keep=KeepName FROM @plan WHERE Id=@n;
  SET @obj=OBJECT_ID(@table,N'U');
  IF @obj IS NULL THROW 51221,'No existe tabla esperada.',1;
  SET @old=(SELECT index_id FROM sys.indexes WHERE object_id=@obj AND name=@remove);
  SET @new=(SELECT index_id FROM sys.indexes WHERE object_id=@obj AND name=@keep);
  IF @new IS NULL THROW 51222,'No existe indice conservado.',1;
  IF @old IS NOT NULL
  BEGIN
   IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=@obj AND index_id=@old AND type=2 AND is_unique=0 AND is_primary_key=0 AND is_unique_constraint=0 AND has_filter=0 AND is_disabled=0)
      OR NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=@obj AND index_id=@new AND type=2 AND is_unique=1 AND has_filter=0 AND is_disabled=0)
     THROW 51223,'Los indices no tienen la estructura revisada.',1;
   IF EXISTS(SELECT column_id,key_ordinal,is_descending_key,is_included_column FROM sys.index_columns WHERE object_id=@obj AND index_id=@old
             EXCEPT SELECT column_id,key_ordinal,is_descending_key,is_included_column FROM sys.index_columns WHERE object_id=@obj AND index_id=@new)
      OR EXISTS(SELECT column_id,key_ordinal,is_descending_key,is_included_column FROM sys.index_columns WHERE object_id=@obj AND index_id=@new
             EXCEPT SELECT column_id,key_ordinal,is_descending_key,is_included_column FROM sys.index_columns WHERE object_id=@obj AND index_id=@old)
     THROW 51224,'La cobertura de columnas difiere.',1;
   IF EXISTS(SELECT 1 FROM sys.sql_modules WHERE definition LIKE N'%'+@remove+N'%')
      OR EXISTS(SELECT 1 FROM sys.query_store_plan WHERE is_forced_plan=1 AND query_plan LIKE N'%'+@remove+N'%')
     THROW 51225,'Hay un consumidor explicito del indice.',1;
   SET @sql=N'DROP INDEX '+QUOTENAME(@remove)+N' ON '+QUOTENAME(OBJECT_SCHEMA_NAME(@obj))+N'.'+QUOTENAME(OBJECT_NAME(@obj))+N';';
   EXEC sys.sp_executesql @sql;
  END;
  SET @n+=1;
 END;
 COMMIT TRANSACTION;
END TRY
BEGIN CATCH
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;
