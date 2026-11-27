-- Sólo desarrollo local: separar usuario 1 de la persona laboral 31.
-- El ID 1 de Persona está ocupado y se conserva. Sin copias ni reasignación histórica.
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET LOCK_TIMEOUT 5000;
IF DB_NAME() <> N'GestionEmpresarial' THROW 51200, 'Base de datos no esperada.', 1;
IF SERVERPROPERTY('ServerName') <> N'DESKTOP-B2UQJB2' THROW 51201, 'Este cambio sólo está autorizado en desarrollo local.', 1;
BEGIN TRANSACTION;
IF COL_LENGTH('NOM.Persona','EsPersonaSistema') IS NULL
 ALTER TABLE NOM.Persona ADD EsPersonaSistema bit NOT NULL CONSTRAINT DF_Persona_EsPersonaSistema DEFAULT(0) WITH VALUES;
GO
IF OBJECT_ID(N'NOM.EsPersonaDeSistema',N'FN') IS NULL
EXEC(N'CREATE FUNCTION NOM.EsPersonaDeSistema(@PersonaId int)
RETURNS bit
AS
BEGIN
 DECLARE @Resultado bit=0;
 SELECT @Resultado=EsPersonaSistema FROM NOM.Persona WHERE PKIdPersona=@PersonaId;
 RETURN @Resultado;
END;');
GO
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID('NOM.Persona') AND name='CK_Persona_SistemaSinRelacionLaboral')
 ALTER TABLE NOM.Persona WITH CHECK ADD CONSTRAINT CK_Persona_SistemaSinRelacionLaboral CHECK
 (EsPersonaSistema=0 OR (Activo=0 AND FKIdEmpresa_SIS IS NULL AND SUELDO_BASE IS NULL AND COMPENSACION_GARANTIZADA IS NULL AND BANCO IS NULL AND NUMERO_CUENTA IS NULL AND CLABE IS NULL AND TIPO_CONTRATACION IS NULL AND PUESTO IS NULL));

-- Las vistas operativas no deben listar personas de sistema, ni siquiera al consultar bajas.
DECLARE @Objeto nvarchar(256),@Definicion nvarchar(max),@Patron nvarchar(200),@Nueva nvarchar(max);
DECLARE vistas CURSOR LOCAL FAST_FORWARD FOR SELECT Objeto FROM (VALUES(N'NOM.Vw_Persona'),(N'RHCT.Persona'),(N'NOM.Vw_RhEmpleado'),(N'NOM.Vw_OperacionNomina'),(N'NOM.Vw_RhEntidadNomina')) v(Objeto);
OPEN vistas;
FETCH NEXT FROM vistas INTO @Objeto;
WHILE @@FETCH_STATUS=0
BEGIN
 SET @Definicion=OBJECT_DEFINITION(OBJECT_ID(@Objeto));
 IF @Definicion IS NULL THROW 51202,'No se encuentra una vista operativa requerida.',1;
 IF @Definicion NOT LIKE N'%EsPersonaSistema%'
 BEGIN
  SET @Nueva=LTRIM(@Definicion);
  IF @Nueva NOT LIKE N'CREATE VIEW%' THROW 51203,'Definición inesperada de vista.',1;
  SET @Nueva=STUFF(@Nueva,1,6,N'ALTER');
  SET @Nueva=RTRIM(@Nueva);
  IF RIGHT(@Nueva,1)=N';' SET @Nueva=LEFT(@Nueva,LEN(@Nueva)-1);
  IF @Objeto IN(N'NOM.Vw_OperacionNomina',N'NOM.Vw_RhEntidadNomina')
   SET @Nueva=REPLACE(@Nueva,N'[NOM].[Persona]',N'(SELECT * FROM [NOM].[Persona] WHERE [EsPersonaSistema]=0)')+N';';
  ELSE IF @Objeto=N'NOM.Vw_RhEmpleado' SET @Nueva+=N' AND p.[EsPersonaSistema]=0;';
  ELSE SET @Nueva+=N' WHERE p.[EsPersonaSistema]=0;';
  EXEC sys.sp_executesql @Nueva;
 END;
 FETCH NEXT FROM vistas INTO @Objeto;
END;
CLOSE vistas;
DEALLOCATE vistas;

-- Impedir también por SQL que la persona técnica se asigne a cualquier FK operativa.
-- SIS.Usuario es la única relación permitida; la auditoría usa IDs de usuario y se conserva.
DECLARE @Tabla nvarchar(256),@Columna sysname,@Restriccion sysname,@Sql nvarchar(max);
DECLARE relaciones CURSOR LOCAL FAST_FORWARD FOR
 SELECT QUOTENAME(OBJECT_SCHEMA_NAME(f.parent_object_id))+N'.'+QUOTENAME(OBJECT_NAME(f.parent_object_id)),
        c.name,CONVERT(sysname,N'CK_PersonaSistema_'+CONVERT(nvarchar(20),f.object_id))
 FROM sys.foreign_keys f JOIN sys.foreign_key_columns fc ON fc.constraint_object_id=f.object_id
 JOIN sys.columns c ON c.object_id=fc.parent_object_id AND c.column_id=fc.parent_column_id
 WHERE f.referenced_object_id=OBJECT_ID('NOM.Persona') AND f.parent_object_id<>OBJECT_ID('SIS.Usuario');
OPEN relaciones;
FETCH NEXT FROM relaciones INTO @Tabla,@Columna,@Restriccion;
WHILE @@FETCH_STATUS=0
BEGIN
 IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(@Tabla) AND name=@Restriccion)
 BEGIN
  SET @Sql=N'ALTER TABLE '+@Tabla+N' WITH CHECK ADD CONSTRAINT '+QUOTENAME(@Restriccion)+N' CHECK (NOM.EsPersonaDeSistema('+QUOTENAME(@Columna)+N')=0);';
  EXEC sys.sp_executesql @Sql;
 END;
 FETCH NEXT FROM relaciones INTO @Tabla,@Columna,@Restriccion;
END;
CLOSE relaciones;
DEALLOCATE relaciones;

-- Columnas heredadas de persona sin FK declarada: también deben excluir la cuenta técnica.
DECLARE heredadas CURSOR LOCAL FAST_FORWARD FOR
 SELECT QUOTENAME(OBJECT_SCHEMA_NAME(c.object_id))+N'.'+QUOTENAME(OBJECT_NAME(c.object_id)),c.name,
 CONVERT(sysname,N'CK_PersonaSistema_H_'+CONVERT(nvarchar(20),c.object_id)+N'_'+CONVERT(nvarchar(10),c.column_id))
 FROM sys.columns c JOIN sys.tables t ON t.object_id=c.object_id
 WHERE (c.name LIKE N'FKIdPersona%[_]NOM' OR c.name=N'Fk_IdPersona__RHCT') AND c.system_type_id=56 AND c.object_id<>OBJECT_ID('SIS.Usuario')
 AND NOT EXISTS(SELECT 1 FROM sys.foreign_key_columns fc WHERE fc.parent_object_id=c.object_id AND fc.parent_column_id=c.column_id);
OPEN heredadas;
FETCH NEXT FROM heredadas INTO @Tabla,@Columna,@Restriccion;
WHILE @@FETCH_STATUS=0
BEGIN
 IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(@Tabla) AND name=@Restriccion)
 BEGIN
  SET @Sql=N'ALTER TABLE '+@Tabla+N' WITH CHECK ADD CONSTRAINT '+QUOTENAME(@Restriccion)+N' CHECK (NOM.EsPersonaDeSistema('+QUOTENAME(@Columna)+N')=0);';
  EXEC sys.sp_executesql @Sql;
 END;
 FETCH NEXT FROM heredadas INTO @Tabla,@Columna,@Restriccion;
END;
CLOSE heredadas;
DEALLOCATE heredadas;
GO
DECLARE @Usuario int=1,@Anterior int=31,@NuevaPersona int;
IF NOT EXISTS(SELECT 1 FROM SIS.Usuario u WITH(UPDLOCK,HOLDLOCK)
 JOIN dbo.AspNetUsers a ON a.PkIdUsuario=u.PkIdUsuario
 JOIN dbo.AspNetUserRoles ur ON ur.UserId=a.Id JOIN dbo.AspNetRoles r ON r.Id=ur.RoleId
 WHERE u.PkIdUsuario=@Usuario AND a.Email=N'eliseo.abadia@gmail.com' AND r.Name=N'SuperAdmin' AND u.Activo=1)
 THROW 51204,'La cuenta SuperAdmin no coincide con la confirmada.',1;

SELECT @NuevaPersona=PKIdPersona FROM NOM.Persona WITH(UPDLOCK,HOLDLOCK) WHERE Clave=N'SYS-SUPERADMIN' AND EsPersonaSistema=1;
IF @NuevaPersona IS NULL
BEGIN
 IF EXISTS(SELECT 1 FROM NOM.Persona WHERE Clave=N'SYS-SUPERADMIN') THROW 51205,'La clave técnica ya pertenece a otra persona.',1;
 INSERT NOM.Persona(Clave,Iniciales,Nombre,Paterno,Materno,FechaNacimiento,RFC,Curp,CORREO_ELECTRONICO,Fecha_de_Inicio,Activo,UsuarioCreacion,FechaCreacion,EsPersonaSistema)
 VALUES(N'SYS-SUPERADMIN',N'EA',N'Eliseo',N'Abadia',N'',CONVERT(datetime,'19000101',112),N'',N'',N'eliseo.abadia@gmail.com',CONVERT(datetime,'19000101',112),0,@Usuario,SYSDATETIME(),1);
 SET @NuevaPersona=CONVERT(int,SCOPE_IDENTITY());
END;
IF NOT EXISTS(SELECT 1 FROM SIS.Usuario WHERE PkIdUsuario=@Usuario AND FKIdPersona_NOM IN(@Anterior,@NuevaPersona))
 THROW 51206,'La vinculación anterior cambió; no se aplica automáticamente.',1;
UPDATE SIS.Usuario SET FKIdPersona_NOM=@NuevaPersona,UsuarioModificacion=@Usuario,FechaModificacion=SYSDATETIME() WHERE PkIdUsuario=@Usuario;

-- La persona laboral conserva su identidad; no se trasladan nóminas ni documentos.
UPDATE NOM.Persona SET Nombre=N'GABRIELA',Paterno=N'CORONA',Materno=N'ESPINOSA',Iniciales=NULL,
 CORREO_ELECTRONICO=N'gabriela.corona@ift.org.mx',UsuarioModificacion=@Usuario,FechaModificacion=SYSDATETIME()
 WHERE PKIdPersona=@Anterior AND Nombre=N'Eliseo' AND Paterno=N'Abadia' AND Materno=N'' AND CORREO_ELECTRONICO=N'eliseo.abadia@gmail.com';
IF EXISTS(SELECT 1 FROM NOM.Vw_RhEmpleado WHERE Id=@NuevaPersona) THROW 51207,'La persona técnica apareció en empleados.',1;
IF EXISTS(SELECT 1 FROM NOM.Vw_Persona WHERE PKIdPersona=@NuevaPersona) THROW 51208,'La persona técnica apareció en el catálogo.',1;
IF EXISTS(SELECT 1 FROM RHCT.Persona WHERE PK_IdPersona=@NuevaPersona) THROW 51209,'La persona técnica apareció en el flujo heredado.',1;
COMMIT TRANSACTION;
SELECT @Usuario AS UsuarioId,@NuevaPersona AS PersonaSistemaId,@Anterior AS PersonaLaboralConservada;
