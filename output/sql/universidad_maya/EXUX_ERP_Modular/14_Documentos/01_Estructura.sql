/*
EXUX | Universidad Maya | Propuesta de reestructura SQL Server 2022
MÓDULO 14: Documentos
Generado a partir de metadatos: EmptyProjects (26 tablas) y GestionEmpresarial (309 tablas).
SOLO ARCHIVO GENERADO. NO APLICADO. SIN DATOS, SIN USUARIOS, SIN CREDENCIALES.
FASE A: tablas, columnas, PK, índices y CHECK. No crea relaciones a otros módulos.
FASE B: ejecutar 02_Relaciones.sql después de todas las FASE A.
Dependencias para cerrar relaciones: 01 Base_Organizacion.
Se conservan nombres heredados; el detalle de reestructura se enumera debajo.
Sin cargas de catálogos: requerirán preparación funcional posterior.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
DECLARE @BaseDestino sysname = N'EmptyProjects';
IF DB_NAME() <> @BaseDestino THROW 51000, N'Base incorrecta. Seleccione EmptyProjects o edite @BaseDestino para una copia autorizada.', 1;
IF DB_NAME() IN (N'GestionEmpresarial',N'master',N'model',N'msdb',N'tempdb') THROW 51000, N'Destino protegido: este paquete no se aplica en la base origen.', 1;
IF @@TRANCOUNT <> 0 THROW 51000, N'Ejecute cada archivo fuera de una transacción previa.', 1;
BEGIN TRY
BEGIN TRANSACTION;
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"PKIdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"Nombre","type":"nvarchar","length":512,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"RFC","type":"nvarchar","length":52,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"RazonSocial","type":"nvarchar","length":1020,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Giro","type":"nvarchar","length":400,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"FKIdMonedaBase_SIS","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FKIdIdiomaPreferido_SIS","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Logo","type":"nvarchar","length":4096,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Activo","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FechaCreacion","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":1,"identity":0,"computed":0},{"name":"UsuarioCreacion","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"FechaModificacion","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":1,"identity":0,"computed":0},{"name":"UsuarioModificacion","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"RegIMSS","type":"nvarchar","length":100,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"RegInfonavit","type":"nvarchar","length":100,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CedEmpadronam","type":"nvarchar","length":100,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"NoFonacot","type":"nvarchar","length":100,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"UsAdmin","type":"nvarchar","length":400,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"EmailAdmin","type":"nvarchar","length":400,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"FKIdPeriodoPago_SIS","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"PrimaRiesgoIMSS","type":"decimal","length":9,"precision":18,"scale":4,"nullable":1,"identity":0,"computed":0},{"name":"UsaSueldoTabular","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FKIdTipoPago_NOM","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"LogoEmpresa","type":"varbinary","length":-1,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"NombreCorto","type":"nvarchar","length":256,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'SIS.Empresa',N'U')
) THROW 51001,N'Estructura incompatible: SIS.Empresa. No se modifica ni sustituye automáticamente.',1;
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"PKIdSucursal","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"FKIdEmpresa_SIS","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FKIdEstado_SIS","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Nombre","type":"nvarchar","length":512,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CodigoSucursal","type":"nvarchar","length":80,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Alias","type":"nvarchar","length":200,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"FKIdTipoSucursal","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FKIdMonedaLocal_SIS","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Direccion","type":"nvarchar","length":1024,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Colonia","type":"nvarchar","length":400,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Ciudad","type":"nvarchar","length":400,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CodigoPostal","type":"nvarchar","length":40,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"TelefonoPrincipal","type":"nvarchar","length":80,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"TelefonoSecundario","type":"nvarchar","length":80,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Email","type":"nvarchar","length":400,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"HorarioApertura","type":"time","length":5,"precision":16,"scale":7,"nullable":1,"identity":0,"computed":0},{"name":"HorarioCierre","type":"time","length":5,"precision":16,"scale":7,"nullable":1,"identity":0,"computed":0},{"name":"EsMatriz","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"EsActiva","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Latitud","type":"decimal","length":5,"precision":9,"scale":6,"nullable":1,"identity":0,"computed":0},{"name":"Longitud","type":"decimal","length":5,"precision":9,"scale":6,"nullable":1,"identity":0,"computed":0},{"name":"Activo","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FechaCreacion","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":1,"identity":0,"computed":0},{"name":"UsuarioCreacion","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FechaModificacion","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":1,"identity":0,"computed":0},{"name":"UsuarioModificacion","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'SIS.Sucursal',N'U')
) THROW 51001,N'Estructura incompatible: SIS.Sucursal. No se modifica ni sustituye automáticamente.',1;
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"PkIdUsuario","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"FKIdEmpresa_SIS","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"FKIdPersona_NOM","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"AspNetUserId","type":"nvarchar","length":900,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"PayrollID","type":"nvarchar","length":80,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FKIdIdiomaPreferido_SIS","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"FKIdMonedaPreferida_SIS","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"EsAdministrador","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Activo","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FechaCreacion","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":1,"identity":0,"computed":0},{"name":"UsuarioCreacion","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"FechaModificacion","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":1,"identity":0,"computed":0},{"name":"UsuarioModificacion","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'SIS.Usuario',N'U')
) THROW 51001,N'Estructura incompatible: SIS.Usuario. No se modifica ni sustituye automáticamente.',1;
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"Id","type":"nvarchar","length":512,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Name","type":"nvarchar","length":1024,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Code","type":"nvarchar","length":40,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'dbo.AspNetRoles',N'U')
) THROW 51001,N'Estructura incompatible: dbo.AspNetRoles. No se modifica ni sustituye automáticamente.',1;
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"PKIdMoneda","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"Nombre","type":"nvarchar","length":200,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CodigoISO4217","type":"char","length":3,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Simbolo","type":"nvarchar","length":20,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Decimales","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Activo","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'SIS.Moneda',N'U')
) THROW 51001,N'Estructura incompatible: SIS.Moneda. No se modifica ni sustituye automáticamente.',1;
IF SCHEMA_ID(N'DOC') IS NULL
EXEC sys.sp_executesql N'CREATE SCHEMA [DOC] AUTHORIZATION [dbo];';
IF SCHEMA_ID(N'SIS') IS NULL
EXEC sys.sp_executesql N'CREATE SCHEMA [SIS] AUTHORIZATION [dbo];';

-- DOC.CampoExtraido | ERD EXUX
IF OBJECT_ID(N'DOC.CampoExtraido',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [DOC].[CampoExtraido] (
 [IdCampoExtraido] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdExtraccion] bigint NOT NULL,
 [Nombre] nvarchar(100) NOT NULL,
 [ValorDetectado] nvarchar(max) NULL,
 [Confianza] decimal(9,6) NULL,
 [ValorCorregido] nvarchar(max) NULL,
 [Validado] bit NOT NULL DEFAULT 0,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_DOC_CampoExtraido_IdCampoExtraido] PRIMARY KEY CLUSTERED ([IdCampoExtraido] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdCampoExtraido","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdExtraccion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Nombre","type":"nvarchar","length":200,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"ValorDetectado","type":"nvarchar","length":-1,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Confianza","type":"decimal","length":5,"precision":9,"scale":6,"nullable":1,"identity":0,"computed":0},{"name":"ValorCorregido","type":"nvarchar","length":-1,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Validado","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'DOC.CampoExtraido',N'U')
) THROW 51001,N'Estructura incompatible: DOC.CampoExtraido. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'DOC.CampoExtraido') AND c.name=N'Validado' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'0') THROW 51002,N'DEFAULT incompatible: DOC.CampoExtraido.Validado',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'DOC.CampoExtraido') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: DOC.CampoExtraido.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'DOC.CampoExtraido') AND name=N'UX_DOC_CampoExtraido_IdCampoExtraido' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: DOC.CampoExtraido.UX_DOC_CampoExtraido_IdCampoExtraido',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdCampoExtraido","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'DOC.CampoExtraido') AND i.name=N'UX_DOC_CampoExtraido_IdCampoExtraido') THROW 51003,N'Columnas de índice incompatibles: DOC.CampoExtraido.UX_DOC_CampoExtraido_IdCampoExtraido',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'DOC.CampoExtraido') AND i.name=N'UX_DOC_CampoExtraido_IdCampoExtraido')<>1 THROW 51003,N'Número de columnas de índice incompatible: DOC.CampoExtraido.UX_DOC_CampoExtraido_IdCampoExtraido',1;
IF OBJECT_ID(N'DOC.CK_EXUX_DOC_CampoExtraido_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [DOC].[CampoExtraido] WITH CHECK ADD CONSTRAINT [CK_EXUX_DOC_CampoExtraido_1] CHECK (Confianza IS NULL OR Confianza BETWEEN 0 AND 1);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'DOC.CampoExtraido') AND name=N'CK_EXUX_DOC_CampoExtraido_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'confianzaisnullorconfianzabetween0and1') THROW 51004,N'CHECK incompatible: DOC.CampoExtraido.CK_EXUX_DOC_CampoExtraido_1',1;

-- DOC.ExtraccionDocumento | ERD EXUX
IF OBJECT_ID(N'DOC.ExtraccionDocumento',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [DOC].[ExtraccionDocumento] (
 [IdExtraccionDocumento] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdDocumento] bigint NOT NULL,
 [Motor] nvarchar(100) NOT NULL,
 [VersionMotor] nvarchar(60) NOT NULL,
 [EstadoRevision] varchar(20) NOT NULL,
 [IdUsuarioRevision] int NULL,
 [FechaRevision] datetime2(7) NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_DOC_ExtraccionDocumento_IdExtraccionDocumento] PRIMARY KEY CLUSTERED ([IdExtraccionDocumento] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdExtraccionDocumento","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdDocumento","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Motor","type":"nvarchar","length":200,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"VersionMotor","type":"nvarchar","length":120,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"EstadoRevision","type":"varchar","length":20,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdUsuarioRevision","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"FechaRevision","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":1,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'DOC.ExtraccionDocumento',N'U')
) THROW 51001,N'Estructura incompatible: DOC.ExtraccionDocumento. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'DOC.ExtraccionDocumento') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: DOC.ExtraccionDocumento.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'DOC.ExtraccionDocumento') AND name=N'UX_DOC_ExtraccionDocumento_IdExtraccionDocumento' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: DOC.ExtraccionDocumento.UX_DOC_ExtraccionDocumento_IdExtraccionDocumento',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdExtraccionDocumento","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'DOC.ExtraccionDocumento') AND i.name=N'UX_DOC_ExtraccionDocumento_IdExtraccionDocumento') THROW 51003,N'Columnas de índice incompatibles: DOC.ExtraccionDocumento.UX_DOC_ExtraccionDocumento_IdExtraccionDocumento',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'DOC.ExtraccionDocumento') AND i.name=N'UX_DOC_ExtraccionDocumento_IdExtraccionDocumento')<>1 THROW 51003,N'Número de columnas de índice incompatible: DOC.ExtraccionDocumento.UX_DOC_ExtraccionDocumento_IdExtraccionDocumento',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'DOC.ExtraccionDocumento') AND name=N'UX_DOC_ExtraccionDocumento_IdEmpresa_IdExtraccionDocumento')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_DOC_ExtraccionDocumento_IdEmpresa_IdExtraccionDocumento] ON [DOC].[ExtraccionDocumento] ([IdEmpresa] ASC, [IdExtraccionDocumento] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'DOC.ExtraccionDocumento') AND name=N'UX_DOC_ExtraccionDocumento_IdEmpresa_IdExtraccionDocumento' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: DOC.ExtraccionDocumento.UX_DOC_ExtraccionDocumento_IdEmpresa_IdExtraccionDocumento',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"IdExtraccionDocumento","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'DOC.ExtraccionDocumento') AND i.name=N'UX_DOC_ExtraccionDocumento_IdEmpresa_IdExtraccionDocumento') THROW 51003,N'Columnas de índice incompatibles: DOC.ExtraccionDocumento.UX_DOC_ExtraccionDocumento_IdEmpresa_IdExtraccionDocumento',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'DOC.ExtraccionDocumento') AND i.name=N'UX_DOC_ExtraccionDocumento_IdEmpresa_IdExtraccionDocumento')<>2 THROW 51003,N'Número de columnas de índice incompatible: DOC.ExtraccionDocumento.UX_DOC_ExtraccionDocumento_IdEmpresa_IdExtraccionDocumento',1;

-- DOC.OperacionDocumento | ERD EXUX
IF OBJECT_ID(N'DOC.OperacionDocumento',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [DOC].[OperacionDocumento] (
 [IdOperacionDocumento] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdOperacion] bigint NOT NULL,
 [IdDocumento] bigint NOT NULL,
 [Rol] varchar(40) NOT NULL,
 [Clasificacion] varchar(30) NOT NULL,
 [VigenteDesde] datetime2(7) NOT NULL,
 [VigenteHasta] datetime2(7) NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_DOC_OperacionDocumento_IdOperacionDocumento] PRIMARY KEY CLUSTERED ([IdOperacionDocumento] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdOperacionDocumento","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdOperacion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdDocumento","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Rol","type":"varchar","length":40,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Clasificacion","type":"varchar","length":30,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"VigenteDesde","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VigenteHasta","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":1,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'DOC.OperacionDocumento',N'U')
) THROW 51001,N'Estructura incompatible: DOC.OperacionDocumento. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'DOC.OperacionDocumento') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: DOC.OperacionDocumento.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'DOC.OperacionDocumento') AND name=N'UX_DOC_OperacionDocumento_IdOperacionDocumento' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: DOC.OperacionDocumento.UX_DOC_OperacionDocumento_IdOperacionDocumento',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdOperacionDocumento","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'DOC.OperacionDocumento') AND i.name=N'UX_DOC_OperacionDocumento_IdOperacionDocumento') THROW 51003,N'Columnas de índice incompatibles: DOC.OperacionDocumento.UX_DOC_OperacionDocumento_IdOperacionDocumento',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'DOC.OperacionDocumento') AND i.name=N'UX_DOC_OperacionDocumento_IdOperacionDocumento')<>1 THROW 51003,N'Número de columnas de índice incompatible: DOC.OperacionDocumento.UX_DOC_OperacionDocumento_IdOperacionDocumento',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'DOC.OperacionDocumento') AND name=N'UX_DOC_OperacionDocumento_IdOperacion_IdDocumento_Rol')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_DOC_OperacionDocumento_IdOperacion_IdDocumento_Rol] ON [DOC].[OperacionDocumento] ([IdOperacion] ASC, [IdDocumento] ASC, [Rol] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'DOC.OperacionDocumento') AND name=N'UX_DOC_OperacionDocumento_IdOperacion_IdDocumento_Rol' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: DOC.OperacionDocumento.UX_DOC_OperacionDocumento_IdOperacion_IdDocumento_Rol',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdOperacion","ordinal":1,"descending":0,"included":0},{"name":"IdDocumento","ordinal":2,"descending":0,"included":0},{"name":"Rol","ordinal":3,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'DOC.OperacionDocumento') AND i.name=N'UX_DOC_OperacionDocumento_IdOperacion_IdDocumento_Rol') THROW 51003,N'Columnas de índice incompatibles: DOC.OperacionDocumento.UX_DOC_OperacionDocumento_IdOperacion_IdDocumento_Rol',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'DOC.OperacionDocumento') AND i.name=N'UX_DOC_OperacionDocumento_IdOperacion_IdDocumento_Rol')<>3 THROW 51003,N'Número de columnas de índice incompatible: DOC.OperacionDocumento.UX_DOC_OperacionDocumento_IdOperacion_IdDocumento_Rol',1;
IF OBJECT_ID(N'DOC.CK_EXUX_DOC_OperacionDocumento_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [DOC].[OperacionDocumento] WITH CHECK ADD CONSTRAINT [CK_EXUX_DOC_OperacionDocumento_1] CHECK (VigenteHasta IS NULL OR VigenteHasta >= VigenteDesde);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'DOC.OperacionDocumento') AND name=N'CK_EXUX_DOC_OperacionDocumento_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'vigentehastaisnullorvigentehasta>=vigentedesde') THROW 51004,N'CHECK incompatible: DOC.OperacionDocumento.CK_EXUX_DOC_OperacionDocumento_1',1;

-- SIS.Documento | GestionEmpresarial.SIS.Documento
-- CAMBIO FkidEmpresaSis: Obligatoria; protección de pertenencia documental
IF OBJECT_ID(N'SIS.Documento',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [SIS].[Documento] (
 [PkidDocumento] bigint IDENTITY(1,1) NOT NULL,
 [Modulo] nvarchar(120) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [SubModulo] nvarchar(120) COLLATE Modern_Spanish_CI_AS NULL,
 [Controlador] nvarchar(160) COLLATE Modern_Spanish_CI_AS NULL,
 [Servicio] nvarchar(160) COLLATE Modern_Spanish_CI_AS NULL,
 [EntidadId] bigint NOT NULL,
 [FkidEmpresaSis] int NOT NULL,
 [Titulo] nvarchar(250) COLLATE Modern_Spanish_CI_AS NULL,
 [Descripcion] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [NombreOriginal] nvarchar(260) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [NombreAlmacenado] nvarchar(260) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Extension] nvarchar(16) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [TipoMime] nvarchar(120) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [TamanoBytes] bigint NOT NULL,
 [ModoAlmacenamiento] nvarchar(20) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [ContenidoArchivo] varbinary(max) NULL,
 [RutaRelativa] nvarchar(700) COLLATE Modern_Spanish_CI_AS NULL,
 [HashSha256] varbinary(32) NULL,
 [VersionDocumento] int NOT NULL DEFAULT ((1)),
 [EsImagen] bit NOT NULL DEFAULT ((0)),
 [EsPdf] bit NOT NULL DEFAULT ((0)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [CT_CreatedBy] int NOT NULL,
 [CT_CreatedDate] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [CT_ModifiedBy] int NULL,
 [CT_ModifiedDate] datetime2(0) NULL,
 [RowVersion] rowversion NOT NULL,
 CONSTRAINT [PK__Document__F6FE159DD4142EAC] PRIMARY KEY CLUSTERED ([PkidDocumento] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"PkidDocumento","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"Modulo","type":"nvarchar","length":240,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"SubModulo","type":"nvarchar","length":240,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Controlador","type":"nvarchar","length":320,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Servicio","type":"nvarchar","length":320,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"EntidadId","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FkidEmpresaSis","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Titulo","type":"nvarchar","length":500,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Descripcion","type":"nvarchar","length":-1,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"NombreOriginal","type":"nvarchar","length":520,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"NombreAlmacenado","type":"nvarchar","length":520,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Extension","type":"nvarchar","length":32,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"TipoMime","type":"nvarchar","length":240,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"TamanoBytes","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"ModoAlmacenamiento","type":"nvarchar","length":40,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"ContenidoArchivo","type":"varbinary","length":-1,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"RutaRelativa","type":"nvarchar","length":1400,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"HashSha256","type":"varbinary","length":32,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"VersionDocumento","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"EsImagen","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"EsPdf","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Activo","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CT_CreatedBy","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CT_CreatedDate","type":"datetime2","length":6,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CT_ModifiedBy","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CT_ModifiedDate","type":"datetime2","length":6,"precision":19,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"RowVersion","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'SIS.Documento',N'U')
) THROW 51001,N'Estructura incompatible: SIS.Documento. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'SIS.Documento') AND c.name=N'VersionDocumento' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'1') THROW 51002,N'DEFAULT incompatible: SIS.Documento.VersionDocumento',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'SIS.Documento') AND c.name=N'EsImagen' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'0') THROW 51002,N'DEFAULT incompatible: SIS.Documento.EsImagen',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'SIS.Documento') AND c.name=N'EsPdf' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'0') THROW 51002,N'DEFAULT incompatible: SIS.Documento.EsPdf',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'SIS.Documento') AND c.name=N'Activo' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'1') THROW 51002,N'DEFAULT incompatible: SIS.Documento.Activo',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'SIS.Documento') AND c.name=N'CT_CreatedDate' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysdatetime') THROW 51002,N'DEFAULT incompatible: SIS.Documento.CT_CreatedDate',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.Documento') AND name=N'PK__Document__F6FE159DD4142EAC' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.Documento.PK__Document__F6FE159DD4142EAC',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"PkidDocumento","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.Documento') AND i.name=N'PK__Document__F6FE159DD4142EAC') THROW 51003,N'Columnas de índice incompatibles: SIS.Documento.PK__Document__F6FE159DD4142EAC',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.Documento') AND i.name=N'PK__Document__F6FE159DD4142EAC')<>1 THROW 51003,N'Número de columnas de índice incompatible: SIS.Documento.PK__Document__F6FE159DD4142EAC',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.Documento') AND name=N'IX_Documento_Entidad')
EXEC sys.sp_executesql N'CREATE NONCLUSTERED INDEX [IX_Documento_Entidad] ON [SIS].[Documento] ([Modulo] ASC, [SubModulo] ASC, [Controlador] ASC, [Servicio] ASC, [EntidadId] ASC, [FkidEmpresaSis] ASC, [Activo] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.Documento') AND name=N'IX_Documento_Entidad' AND is_unique=0 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.Documento.IX_Documento_Entidad',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"Modulo","ordinal":1,"descending":0,"included":0},{"name":"SubModulo","ordinal":2,"descending":0,"included":0},{"name":"Controlador","ordinal":3,"descending":0,"included":0},{"name":"Servicio","ordinal":4,"descending":0,"included":0},{"name":"EntidadId","ordinal":5,"descending":0,"included":0},{"name":"FkidEmpresaSis","ordinal":6,"descending":0,"included":0},{"name":"Activo","ordinal":7,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.Documento') AND i.name=N'IX_Documento_Entidad') THROW 51003,N'Columnas de índice incompatibles: SIS.Documento.IX_Documento_Entidad',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.Documento') AND i.name=N'IX_Documento_Entidad')<>7 THROW 51003,N'Número de columnas de índice incompatible: SIS.Documento.IX_Documento_Entidad',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.Documento') AND name=N'IX_Documento_Fecha')
EXEC sys.sp_executesql N'CREATE NONCLUSTERED INDEX [IX_Documento_Fecha] ON [SIS].[Documento] ([CT_CreatedDate] DESC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.Documento') AND name=N'IX_Documento_Fecha' AND is_unique=0 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.Documento.IX_Documento_Fecha',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"CT_CreatedDate","ordinal":1,"descending":1,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.Documento') AND i.name=N'IX_Documento_Fecha') THROW 51003,N'Columnas de índice incompatibles: SIS.Documento.IX_Documento_Fecha',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.Documento') AND i.name=N'IX_Documento_Fecha')<>1 THROW 51003,N'Número de columnas de índice incompatible: SIS.Documento.IX_Documento_Fecha',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.Documento') AND name=N'UX_SIS_Documento_FkidEmpresaSis_PkidDocumento')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_SIS_Documento_FkidEmpresaSis_PkidDocumento] ON [SIS].[Documento] ([FkidEmpresaSis] ASC, [PkidDocumento] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.Documento') AND name=N'UX_SIS_Documento_FkidEmpresaSis_PkidDocumento' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.Documento.UX_SIS_Documento_FkidEmpresaSis_PkidDocumento',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"FkidEmpresaSis","ordinal":1,"descending":0,"included":0},{"name":"PkidDocumento","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.Documento') AND i.name=N'UX_SIS_Documento_FkidEmpresaSis_PkidDocumento') THROW 51003,N'Columnas de índice incompatibles: SIS.Documento.UX_SIS_Documento_FkidEmpresaSis_PkidDocumento',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.Documento') AND i.name=N'UX_SIS_Documento_FkidEmpresaSis_PkidDocumento')<>2 THROW 51003,N'Número de columnas de índice incompatible: SIS.Documento.UX_SIS_Documento_FkidEmpresaSis_PkidDocumento',1;
IF OBJECT_ID(N'SIS.CK_Documento_ModoAlmacenamiento',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [SIS].[Documento] WITH CHECK ADD CONSTRAINT [CK_Documento_ModoAlmacenamiento] CHECK (([ModoAlmacenamiento]=N''FILESYSTEM'' OR [ModoAlmacenamiento]=N''DATABASE''));';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'SIS.Documento') AND name=N'CK_Documento_ModoAlmacenamiento' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'modoalmacenamiento=n''filesystem''ormodoalmacenamiento=n''database''') THROW 51004,N'CHECK incompatible: SIS.Documento.CK_Documento_ModoAlmacenamiento',1;
IF OBJECT_ID(N'SIS.CK_Documento_Storage',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [SIS].[Documento] WITH CHECK ADD CONSTRAINT [CK_Documento_Storage] CHECK (([ModoAlmacenamiento]=N''DATABASE'' AND [ContenidoArchivo] IS NOT NULL OR [ModoAlmacenamiento]=N''FILESYSTEM'' AND [RutaRelativa] IS NOT NULL));';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'SIS.Documento') AND name=N'CK_Documento_Storage' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'modoalmacenamiento=n''database''andcontenidoarchivoisnotnullormodoalmacenamiento=n''filesystem''andrutarelativaisnotnull') THROW 51004,N'CHECK incompatible: SIS.Documento.CK_Documento_Storage',1;

-- SIS.DocumentoAnotacion | GestionEmpresarial.SIS.DocumentoAnotacion
-- CAMBIO IdEmpresa: Contexto obligatorio por relación de negocio
IF OBJECT_ID(N'SIS.DocumentoAnotacion',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [SIS].[DocumentoAnotacion] (
 [PkidDocumentoAnotacion] bigint IDENTITY(1,1) NOT NULL,
 [FkidDocumento] bigint NOT NULL,
 [FkidDocumentoTipoAnotacion] int NOT NULL,
 [Comentario] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [TextoSeleccionado] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [Pagina] int NULL,
 [PosicionX] decimal(9,6) NULL,
 [PosicionY] decimal(9,6) NULL,
 [Ancho] decimal(9,6) NULL,
 [Alto] decimal(9,6) NULL,
 [Color] nvarchar(20) COLLATE Modern_Spanish_CI_AS NOT NULL DEFAULT (N''#FFE066''),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [CT_CreatedBy] int NOT NULL,
 [CT_CreatedDate] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [CT_ModifiedBy] int NULL,
 [CT_ModifiedDate] datetime2(0) NULL,
 [RowVersion] rowversion NOT NULL,
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK__Document__3F4C0AC06E908D55] PRIMARY KEY CLUSTERED ([PkidDocumentoAnotacion] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"PkidDocumentoAnotacion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"FkidDocumento","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FkidDocumentoTipoAnotacion","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Comentario","type":"nvarchar","length":-1,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"TextoSeleccionado","type":"nvarchar","length":-1,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Pagina","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"PosicionX","type":"decimal","length":5,"precision":9,"scale":6,"nullable":1,"identity":0,"computed":0},{"name":"PosicionY","type":"decimal","length":5,"precision":9,"scale":6,"nullable":1,"identity":0,"computed":0},{"name":"Ancho","type":"decimal","length":5,"precision":9,"scale":6,"nullable":1,"identity":0,"computed":0},{"name":"Alto","type":"decimal","length":5,"precision":9,"scale":6,"nullable":1,"identity":0,"computed":0},{"name":"Color","type":"nvarchar","length":40,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Activo","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CT_CreatedBy","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CT_CreatedDate","type":"datetime2","length":6,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CT_ModifiedBy","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CT_ModifiedDate","type":"datetime2","length":6,"precision":19,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"RowVersion","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'SIS.DocumentoAnotacion',N'U')
) THROW 51001,N'Estructura incompatible: SIS.DocumentoAnotacion. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'SIS.DocumentoAnotacion') AND c.name=N'Color' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'n''#ffe066''') THROW 51002,N'DEFAULT incompatible: SIS.DocumentoAnotacion.Color',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'SIS.DocumentoAnotacion') AND c.name=N'Activo' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'1') THROW 51002,N'DEFAULT incompatible: SIS.DocumentoAnotacion.Activo',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'SIS.DocumentoAnotacion') AND c.name=N'CT_CreatedDate' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysdatetime') THROW 51002,N'DEFAULT incompatible: SIS.DocumentoAnotacion.CT_CreatedDate',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.DocumentoAnotacion') AND name=N'PK__Document__3F4C0AC06E908D55' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.DocumentoAnotacion.PK__Document__3F4C0AC06E908D55',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"PkidDocumentoAnotacion","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.DocumentoAnotacion') AND i.name=N'PK__Document__3F4C0AC06E908D55') THROW 51003,N'Columnas de índice incompatibles: SIS.DocumentoAnotacion.PK__Document__3F4C0AC06E908D55',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.DocumentoAnotacion') AND i.name=N'PK__Document__3F4C0AC06E908D55')<>1 THROW 51003,N'Número de columnas de índice incompatible: SIS.DocumentoAnotacion.PK__Document__3F4C0AC06E908D55',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.DocumentoAnotacion') AND name=N'IX_DocumentoAnotacion_Documento')
EXEC sys.sp_executesql N'CREATE NONCLUSTERED INDEX [IX_DocumentoAnotacion_Documento] ON [SIS].[DocumentoAnotacion] ([FkidDocumento] ASC, [Activo] ASC, [CT_CreatedDate] DESC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.DocumentoAnotacion') AND name=N'IX_DocumentoAnotacion_Documento' AND is_unique=0 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.DocumentoAnotacion.IX_DocumentoAnotacion_Documento',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"FkidDocumento","ordinal":1,"descending":0,"included":0},{"name":"Activo","ordinal":2,"descending":0,"included":0},{"name":"CT_CreatedDate","ordinal":3,"descending":1,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.DocumentoAnotacion') AND i.name=N'IX_DocumentoAnotacion_Documento') THROW 51003,N'Columnas de índice incompatibles: SIS.DocumentoAnotacion.IX_DocumentoAnotacion_Documento',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.DocumentoAnotacion') AND i.name=N'IX_DocumentoAnotacion_Documento')<>3 THROW 51003,N'Número de columnas de índice incompatible: SIS.DocumentoAnotacion.IX_DocumentoAnotacion_Documento',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.DocumentoAnotacion') AND name=N'IX_DocumentoAnotacion_FkidDocumentoTipoAnotacion_43863223')
EXEC sys.sp_executesql N'CREATE NONCLUSTERED INDEX [IX_DocumentoAnotacion_FkidDocumentoTipoAnotacion_43863223] ON [SIS].[DocumentoAnotacion] ([FkidDocumentoTipoAnotacion] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.DocumentoAnotacion') AND name=N'IX_DocumentoAnotacion_FkidDocumentoTipoAnotacion_43863223' AND is_unique=0 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.DocumentoAnotacion.IX_DocumentoAnotacion_FkidDocumentoTipoAnotacion_43863223',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"FkidDocumentoTipoAnotacion","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.DocumentoAnotacion') AND i.name=N'IX_DocumentoAnotacion_FkidDocumentoTipoAnotacion_43863223') THROW 51003,N'Columnas de índice incompatibles: SIS.DocumentoAnotacion.IX_DocumentoAnotacion_FkidDocumentoTipoAnotacion_43863223',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.DocumentoAnotacion') AND i.name=N'IX_DocumentoAnotacion_FkidDocumentoTipoAnotacion_43863223')<>1 THROW 51003,N'Número de columnas de índice incompatible: SIS.DocumentoAnotacion.IX_DocumentoAnotacion_FkidDocumentoTipoAnotacion_43863223',1;
IF OBJECT_ID(N'SIS.CK_DocumentoAnotacion_Coordenadas',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [SIS].[DocumentoAnotacion] WITH CHECK ADD CONSTRAINT [CK_DocumentoAnotacion_Coordenadas] CHECK ((([PosicionX] IS NULL OR [PosicionX]>=(0) AND [PosicionX]<=(1)) AND ([PosicionY] IS NULL OR [PosicionY]>=(0) AND [PosicionY]<=(1)) AND ([Ancho] IS NULL OR [Ancho]>=(0) AND [Ancho]<=(1)) AND ([Alto] IS NULL OR [Alto]>=(0) AND [Alto]<=(1))));';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'SIS.DocumentoAnotacion') AND name=N'CK_DocumentoAnotacion_Coordenadas' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'posicionxisnullorposicionx>=0andposicionx<=1andposicionyisnullorposiciony>=0andposiciony<=1andanchoisnullorancho>=0andancho<=1andaltoisnulloralto>=0andalto<=1') THROW 51004,N'CHECK incompatible: SIS.DocumentoAnotacion.CK_DocumentoAnotacion_Coordenadas',1;

-- SIS.DocumentoEvento | GestionEmpresarial.SIS.DocumentoEvento
-- CAMBIO IdEmpresa: Contexto obligatorio por relación de negocio
IF OBJECT_ID(N'SIS.DocumentoEvento',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [SIS].[DocumentoEvento] (
 [PkidDocumentoEvento] bigint IDENTITY(1,1) NOT NULL,
 [FkidDocumento] bigint NOT NULL,
 [Evento] nvarchar(40) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Comentario] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [CT_CreatedBy] int NOT NULL,
 [CT_CreatedDate] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK__Document__CCABDED747D5EFD1] PRIMARY KEY CLUSTERED ([PkidDocumentoEvento] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"PkidDocumentoEvento","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"FkidDocumento","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Evento","type":"nvarchar","length":80,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Comentario","type":"nvarchar","length":1000,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CT_CreatedBy","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CT_CreatedDate","type":"datetime2","length":6,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'SIS.DocumentoEvento',N'U')
) THROW 51001,N'Estructura incompatible: SIS.DocumentoEvento. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'SIS.DocumentoEvento') AND c.name=N'CT_CreatedDate' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysdatetime') THROW 51002,N'DEFAULT incompatible: SIS.DocumentoEvento.CT_CreatedDate',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.DocumentoEvento') AND name=N'PK__Document__CCABDED747D5EFD1' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.DocumentoEvento.PK__Document__CCABDED747D5EFD1',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"PkidDocumentoEvento","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.DocumentoEvento') AND i.name=N'PK__Document__CCABDED747D5EFD1') THROW 51003,N'Columnas de índice incompatibles: SIS.DocumentoEvento.PK__Document__CCABDED747D5EFD1',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.DocumentoEvento') AND i.name=N'PK__Document__CCABDED747D5EFD1')<>1 THROW 51003,N'Número de columnas de índice incompatible: SIS.DocumentoEvento.PK__Document__CCABDED747D5EFD1',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.DocumentoEvento') AND name=N'IX_DocumentoEvento_Documento')
EXEC sys.sp_executesql N'CREATE NONCLUSTERED INDEX [IX_DocumentoEvento_Documento] ON [SIS].[DocumentoEvento] ([FkidDocumento] ASC, [CT_CreatedDate] DESC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.DocumentoEvento') AND name=N'IX_DocumentoEvento_Documento' AND is_unique=0 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.DocumentoEvento.IX_DocumentoEvento_Documento',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"FkidDocumento","ordinal":1,"descending":0,"included":0},{"name":"CT_CreatedDate","ordinal":2,"descending":1,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.DocumentoEvento') AND i.name=N'IX_DocumentoEvento_Documento') THROW 51003,N'Columnas de índice incompatibles: SIS.DocumentoEvento.IX_DocumentoEvento_Documento',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.DocumentoEvento') AND i.name=N'IX_DocumentoEvento_Documento')<>2 THROW 51003,N'Número de columnas de índice incompatible: SIS.DocumentoEvento.IX_DocumentoEvento_Documento',1;

-- SIS.DocumentoExtensionPermitida | GestionEmpresarial.SIS.DocumentoExtensionPermitida
IF OBJECT_ID(N'SIS.DocumentoExtensionPermitida',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [SIS].[DocumentoExtensionPermitida] (
 [PkidDocumentoExtensionPermitida] int IDENTITY(1,1) NOT NULL,
 [Extension] nvarchar(16) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [TipoMime] nvarchar(120) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [EsImagen] bit NOT NULL DEFAULT ((0)),
 [EsPdf] bit NOT NULL DEFAULT ((0)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [CT_CreatedBy] int NULL,
 [CT_CreatedDate] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 CONSTRAINT [PK__Document__93C2CD58C16F4811] PRIMARY KEY CLUSTERED ([PkidDocumentoExtensionPermitida] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"PkidDocumentoExtensionPermitida","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"Extension","type":"nvarchar","length":32,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"TipoMime","type":"nvarchar","length":240,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"EsImagen","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"EsPdf","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Activo","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CT_CreatedBy","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CT_CreatedDate","type":"datetime2","length":6,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'SIS.DocumentoExtensionPermitida',N'U')
) THROW 51001,N'Estructura incompatible: SIS.DocumentoExtensionPermitida. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'SIS.DocumentoExtensionPermitida') AND c.name=N'EsImagen' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'0') THROW 51002,N'DEFAULT incompatible: SIS.DocumentoExtensionPermitida.EsImagen',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'SIS.DocumentoExtensionPermitida') AND c.name=N'EsPdf' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'0') THROW 51002,N'DEFAULT incompatible: SIS.DocumentoExtensionPermitida.EsPdf',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'SIS.DocumentoExtensionPermitida') AND c.name=N'Activo' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'1') THROW 51002,N'DEFAULT incompatible: SIS.DocumentoExtensionPermitida.Activo',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'SIS.DocumentoExtensionPermitida') AND c.name=N'CT_CreatedDate' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysdatetime') THROW 51002,N'DEFAULT incompatible: SIS.DocumentoExtensionPermitida.CT_CreatedDate',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.DocumentoExtensionPermitida') AND name=N'PK__Document__93C2CD58C16F4811' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.DocumentoExtensionPermitida.PK__Document__93C2CD58C16F4811',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"PkidDocumentoExtensionPermitida","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.DocumentoExtensionPermitida') AND i.name=N'PK__Document__93C2CD58C16F4811') THROW 51003,N'Columnas de índice incompatibles: SIS.DocumentoExtensionPermitida.PK__Document__93C2CD58C16F4811',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.DocumentoExtensionPermitida') AND i.name=N'PK__Document__93C2CD58C16F4811')<>1 THROW 51003,N'Número de columnas de índice incompatible: SIS.DocumentoExtensionPermitida.PK__Document__93C2CD58C16F4811',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.DocumentoExtensionPermitida') AND name=N'IX_DocumentoExtensionPermitida_Activo_1823345560')
EXEC sys.sp_executesql N'CREATE NONCLUSTERED INDEX [IX_DocumentoExtensionPermitida_Activo_1823345560] ON [SIS].[DocumentoExtensionPermitida] ([Activo] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.DocumentoExtensionPermitida') AND name=N'IX_DocumentoExtensionPermitida_Activo_1823345560' AND is_unique=0 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.DocumentoExtensionPermitida.IX_DocumentoExtensionPermitida_Activo_1823345560',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"Activo","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.DocumentoExtensionPermitida') AND i.name=N'IX_DocumentoExtensionPermitida_Activo_1823345560') THROW 51003,N'Columnas de índice incompatibles: SIS.DocumentoExtensionPermitida.IX_DocumentoExtensionPermitida_Activo_1823345560',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.DocumentoExtensionPermitida') AND i.name=N'IX_DocumentoExtensionPermitida_Activo_1823345560')<>1 THROW 51003,N'Número de columnas de índice incompatible: SIS.DocumentoExtensionPermitida.IX_DocumentoExtensionPermitida_Activo_1823345560',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.DocumentoExtensionPermitida') AND name=N'UX_DocumentoExtensionPermitida_Extension')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_DocumentoExtensionPermitida_Extension] ON [SIS].[DocumentoExtensionPermitida] ([Extension] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.DocumentoExtensionPermitida') AND name=N'UX_DocumentoExtensionPermitida_Extension' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.DocumentoExtensionPermitida.UX_DocumentoExtensionPermitida_Extension',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"Extension","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.DocumentoExtensionPermitida') AND i.name=N'UX_DocumentoExtensionPermitida_Extension') THROW 51003,N'Columnas de índice incompatibles: SIS.DocumentoExtensionPermitida.UX_DocumentoExtensionPermitida_Extension',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.DocumentoExtensionPermitida') AND i.name=N'UX_DocumentoExtensionPermitida_Extension')<>1 THROW 51003,N'Número de columnas de índice incompatible: SIS.DocumentoExtensionPermitida.UX_DocumentoExtensionPermitida_Extension',1;

-- SIS.DocumentoTipoAnotacion | GestionEmpresarial.SIS.DocumentoTipoAnotacion
IF OBJECT_ID(N'SIS.DocumentoTipoAnotacion',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [SIS].[DocumentoTipoAnotacion] (
 [PkidDocumentoTipoAnotacion] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(30) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(120) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [CT_CreatedBy] int NULL,
 [CT_CreatedDate] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 CONSTRAINT [PK__Document__D28FD9AAED98051C] PRIMARY KEY CLUSTERED ([PkidDocumentoTipoAnotacion] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"PkidDocumentoTipoAnotacion","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"Clave","type":"nvarchar","length":60,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Descripcion","type":"nvarchar","length":240,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Activo","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CT_CreatedBy","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CT_CreatedDate","type":"datetime2","length":6,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'SIS.DocumentoTipoAnotacion',N'U')
) THROW 51001,N'Estructura incompatible: SIS.DocumentoTipoAnotacion. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'SIS.DocumentoTipoAnotacion') AND c.name=N'Activo' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'1') THROW 51002,N'DEFAULT incompatible: SIS.DocumentoTipoAnotacion.Activo',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'SIS.DocumentoTipoAnotacion') AND c.name=N'CT_CreatedDate' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysdatetime') THROW 51002,N'DEFAULT incompatible: SIS.DocumentoTipoAnotacion.CT_CreatedDate',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.DocumentoTipoAnotacion') AND name=N'PK__Document__D28FD9AAED98051C' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.DocumentoTipoAnotacion.PK__Document__D28FD9AAED98051C',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"PkidDocumentoTipoAnotacion","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.DocumentoTipoAnotacion') AND i.name=N'PK__Document__D28FD9AAED98051C') THROW 51003,N'Columnas de índice incompatibles: SIS.DocumentoTipoAnotacion.PK__Document__D28FD9AAED98051C',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.DocumentoTipoAnotacion') AND i.name=N'PK__Document__D28FD9AAED98051C')<>1 THROW 51003,N'Número de columnas de índice incompatible: SIS.DocumentoTipoAnotacion.PK__Document__D28FD9AAED98051C',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.DocumentoTipoAnotacion') AND name=N'IX_DocumentoTipoAnotacion_Activo_2127346643')
EXEC sys.sp_executesql N'CREATE NONCLUSTERED INDEX [IX_DocumentoTipoAnotacion_Activo_2127346643] ON [SIS].[DocumentoTipoAnotacion] ([Activo] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.DocumentoTipoAnotacion') AND name=N'IX_DocumentoTipoAnotacion_Activo_2127346643' AND is_unique=0 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.DocumentoTipoAnotacion.IX_DocumentoTipoAnotacion_Activo_2127346643',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"Activo","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.DocumentoTipoAnotacion') AND i.name=N'IX_DocumentoTipoAnotacion_Activo_2127346643') THROW 51003,N'Columnas de índice incompatibles: SIS.DocumentoTipoAnotacion.IX_DocumentoTipoAnotacion_Activo_2127346643',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.DocumentoTipoAnotacion') AND i.name=N'IX_DocumentoTipoAnotacion_Activo_2127346643')<>1 THROW 51003,N'Número de columnas de índice incompatible: SIS.DocumentoTipoAnotacion.IX_DocumentoTipoAnotacion_Activo_2127346643',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.DocumentoTipoAnotacion') AND name=N'IX_DocumentoTipoAnotacion_Clave_2127346643')
EXEC sys.sp_executesql N'CREATE NONCLUSTERED INDEX [IX_DocumentoTipoAnotacion_Clave_2127346643] ON [SIS].[DocumentoTipoAnotacion] ([Clave] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.DocumentoTipoAnotacion') AND name=N'IX_DocumentoTipoAnotacion_Clave_2127346643' AND is_unique=0 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.DocumentoTipoAnotacion.IX_DocumentoTipoAnotacion_Clave_2127346643',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"Clave","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.DocumentoTipoAnotacion') AND i.name=N'IX_DocumentoTipoAnotacion_Clave_2127346643') THROW 51003,N'Columnas de índice incompatibles: SIS.DocumentoTipoAnotacion.IX_DocumentoTipoAnotacion_Clave_2127346643',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.DocumentoTipoAnotacion') AND i.name=N'IX_DocumentoTipoAnotacion_Clave_2127346643')<>1 THROW 51003,N'Número de columnas de índice incompatible: SIS.DocumentoTipoAnotacion.IX_DocumentoTipoAnotacion_Clave_2127346643',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.DocumentoTipoAnotacion') AND name=N'UX_DocumentoTipoAnotacion_Clave')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_DocumentoTipoAnotacion_Clave] ON [SIS].[DocumentoTipoAnotacion] ([Clave] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.DocumentoTipoAnotacion') AND name=N'UX_DocumentoTipoAnotacion_Clave' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.DocumentoTipoAnotacion.UX_DocumentoTipoAnotacion_Clave',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"Clave","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.DocumentoTipoAnotacion') AND i.name=N'UX_DocumentoTipoAnotacion_Clave') THROW 51003,N'Columnas de índice incompatibles: SIS.DocumentoTipoAnotacion.UX_DocumentoTipoAnotacion_Clave',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.DocumentoTipoAnotacion') AND i.name=N'UX_DocumentoTipoAnotacion_Clave')<>1 THROW 51003,N'Número de columnas de índice incompatible: SIS.DocumentoTipoAnotacion.UX_DocumentoTipoAnotacion_Clave',1;
COMMIT TRANSACTION;
END TRY
BEGIN CATCH
 IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;
PRINT N'FASE A completa: Documentos. Relaciones pendientes en 02_Relaciones.sql.';
