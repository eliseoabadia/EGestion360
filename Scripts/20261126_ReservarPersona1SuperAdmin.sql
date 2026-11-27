-- Migración autorizada de identificadores, sólo en desarrollo. Sin respaldo de datos.
-- Conserva íntegramente a Erasmo y sus referencias; reserva Persona 1 para SYS-SUPERADMIN.
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET LOCK_TIMEOUT 5000;
IF DB_NAME()<>N'GestionEmpresarial' OR SERVERPROPERTY('ServerName')<>N'DESKTOP-B2UQJB2'
 THROW 51300,'Destino distinto al desarrollo local autorizado.',1;
BEGIN TRY
 BEGIN TRANSACTION;
 DECLARE @Tecnica int,@DestinoErasmo int,@Columnas nvarchar(max),@Sql nvarchar(max);
 SELECT @Tecnica=PKIdPersona FROM NOM.Persona WITH(UPDLOCK,HOLDLOCK)
 WHERE Clave=N'SYS-SUPERADMIN' AND EsPersonaSistema=1 AND Activo=0;
 IF @Tecnica IS NULL THROW 51301,'No se encuentra la persona técnica.',1;
 IF @Tecnica=1
 BEGIN
  COMMIT TRANSACTION;
  SELECT N'Ya aplicado' AS Estado,1 AS PersonaSuperAdmin;
  RETURN;
 END;
 IF NOT EXISTS(SELECT 1 FROM NOM.Persona WITH(UPDLOCK,HOLDLOCK) WHERE PKIdPersona=1 AND Nombre=N'Erasmo' AND Paterno=N'Flores' AND EsPersonaSistema=0)
  THROW 51302,'La persona 1 no coincide con Erasmo Flores.',1;
 IF NOT EXISTS(SELECT 1 FROM SIS.Usuario WITH(UPDLOCK,HOLDLOCK) WHERE PkIdUsuario=2 AND FKIdPersona_NOM=1)
  THROW 51303,'La cuenta de Erasmo no tiene la relación esperada.',1;
 IF NOT EXISTS(SELECT 1 FROM SIS.Usuario WITH(UPDLOCK,HOLDLOCK) WHERE PkIdUsuario=1 AND FKIdPersona_NOM=@Tecnica)
  THROW 51304,'La cuenta SuperAdmin no tiene la relación esperada.',1;

 DECLARE @Relaciones TABLE(Tabla nvarchar(256),Columna sysname,ReferenciasAntes bigint);
 INSERT @Relaciones(Tabla,Columna)
 SELECT DISTINCT QUOTENAME(OBJECT_SCHEMA_NAME(fc.parent_object_id))+N'.'+QUOTENAME(OBJECT_NAME(fc.parent_object_id)),c.name
 FROM sys.foreign_key_columns fc JOIN sys.columns c ON c.object_id=fc.parent_object_id AND c.column_id=fc.parent_column_id
 WHERE fc.referenced_object_id=OBJECT_ID('NOM.Persona');
 INSERT @Relaciones(Tabla,Columna)
 SELECT QUOTENAME(OBJECT_SCHEMA_NAME(c.object_id))+N'.'+QUOTENAME(OBJECT_NAME(c.object_id)),c.name
 FROM sys.columns c JOIN sys.tables t ON t.object_id=c.object_id
 WHERE (c.name LIKE N'FKIdPersona%[_]NOM' OR c.name=N'Fk_IdPersona__RHCT') AND c.system_type_id=56
 AND NOT EXISTS(SELECT 1 FROM sys.foreign_key_columns fc WHERE fc.parent_object_id=c.object_id AND fc.parent_column_id=c.column_id);

 SELECT @Columnas=STRING_AGG(CONVERT(nvarchar(max),QUOTENAME(name)),N',') WITHIN GROUP(ORDER BY column_id)
 FROM sys.columns WHERE object_id=OBJECT_ID('NOM.Persona') AND is_identity=0 AND is_computed=0;
 SET @Sql=N'INSERT NOM.Persona('+@Columnas+N') SELECT '+@Columnas+N' FROM NOM.Persona WHERE PKIdPersona=1; SET @Nuevo=CONVERT(int,SCOPE_IDENTITY());
 IF EXISTS(SELECT '+@Columnas+N' FROM NOM.Persona WHERE PKIdPersona=1 EXCEPT SELECT '+@Columnas+N' FROM NOM.Persona WHERE PKIdPersona=@Nuevo)
 THROW 51305,''Los datos de Erasmo no se conservaron íntegros.'',1;';
 EXEC sys.sp_executesql @Sql,N'@Nuevo int OUTPUT',@Nuevo=@DestinoErasmo OUTPUT;

 DECLARE @Tabla nvarchar(256),@Columna sysname,@Antes bigint,@Despues bigint,@Tecnicas bigint;
 DECLARE relaciones CURSOR LOCAL FAST_FORWARD FOR SELECT Tabla,Columna FROM @Relaciones;
 OPEN relaciones;
 FETCH NEXT FROM relaciones INTO @Tabla,@Columna;
 WHILE @@FETCH_STATUS=0
 BEGIN
  SET @Sql=N'SELECT @Antes=COUNT_BIG(*) FROM '+@Tabla+N' WITH(UPDLOCK,HOLDLOCK) WHERE '+QUOTENAME(@Columna)+N'=1;
   SELECT @Tecnicas=COUNT_BIG(*) FROM '+@Tabla+N' WITH(UPDLOCK,HOLDLOCK) WHERE '+QUOTENAME(@Columna)+N'=@Tecnica;
   UPDATE '+@Tabla+N' SET '+QUOTENAME(@Columna)+N'=@Nuevo WHERE '+QUOTENAME(@Columna)+N'=1;
   SELECT @Despues=COUNT_BIG(*) FROM '+@Tabla+N' WHERE '+QUOTENAME(@Columna)+N'=@Nuevo;';
  EXEC sys.sp_executesql @Sql,N'@Tecnica int,@Nuevo int,@Antes bigint OUTPUT,@Despues bigint OUTPUT,@Tecnicas bigint OUTPUT',
   @Tecnica=@Tecnica,@Nuevo=@DestinoErasmo,@Antes=@Antes OUTPUT,@Despues=@Despues OUTPUT,@Tecnicas=@Tecnicas OUTPUT;
  IF @Antes<>@Despues THROW 51306,'No coincide el total de relaciones trasladadas.',1;
  IF @Tecnicas>0 AND @Tabla<>N'[SIS].[Usuario]' THROW 51307,'La persona técnica ya tenía referencias operativas.',1;
  UPDATE @Relaciones SET ReferenciasAntes=@Antes WHERE Tabla=@Tabla AND Columna=@Columna;
  FETCH NEXT FROM relaciones INTO @Tabla,@Columna;
 END;
 CLOSE relaciones;
 DEALLOCATE relaciones;

 DELETE NOM.Persona WHERE PKIdPersona=1 AND EsPersonaSistema=0;
 IF @@ROWCOUNT<>1 THROW 51308,'No se liberó exactamente el identificador esperado.',1;
 SET IDENTITY_INSERT NOM.Persona ON;
 SET @Sql=N'INSERT NOM.Persona(PKIdPersona,'+@Columnas+N') SELECT 1,'+@Columnas+N' FROM NOM.Persona WHERE PKIdPersona=@Tecnica;';
 EXEC sys.sp_executesql @Sql,N'@Tecnica int',@Tecnica=@Tecnica;
 SET IDENTITY_INSERT NOM.Persona OFF;
 UPDATE SIS.Usuario SET FKIdPersona_NOM=1,UsuarioModificacion=1,FechaModificacion=SYSDATETIME() WHERE PkIdUsuario=1 AND FKIdPersona_NOM=@Tecnica;
 IF @@ROWCOUNT<>1 THROW 51309,'No se vinculó exactamente la cuenta SuperAdmin.',1;
 DELETE NOM.Persona WHERE PKIdPersona=@Tecnica AND EsPersonaSistema=1;
 IF @@ROWCOUNT<>1 THROW 51310,'No se retiró el identificador técnico anterior.',1;
 IF EXISTS(SELECT 1 FROM NOM.Vw_RhEmpleado WHERE Id=1) THROW 51311,'El SuperAdmin apareció como empleado.',1;
 IF EXISTS(SELECT 1 FROM NOM.Vw_OperacionNomina WHERE Operacion=N'empleados' AND Id=1) THROW 51312,'El SuperAdmin apareció en operaciones de nómina.',1;
 IF NOT EXISTS(SELECT 1 FROM SIS.Usuario WHERE PkIdUsuario=2 AND FKIdPersona_NOM=@DestinoErasmo) THROW 51313,'La cuenta de Erasmo perdió su persona.',1;
 COMMIT TRANSACTION;
 SELECT 1 AS PersonaSuperAdmin,@DestinoErasmo AS PersonaErasmo,@Tecnica AS IdTecnicoRetirado;
 SELECT Tabla,Columna,ReferenciasAntes AS RelacionesConservadas FROM @Relaciones WHERE ReferenciasAntes>0;
END TRY
BEGIN CATCH
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 SET IDENTITY_INSERT NOM.Persona OFF;
 THROW;
END CATCH;
