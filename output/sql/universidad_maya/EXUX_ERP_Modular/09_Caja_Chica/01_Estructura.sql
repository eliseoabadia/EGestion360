/*
EXUX | Universidad Maya | Propuesta de reestructura SQL Server 2022
MÓDULO 09: Caja_Chica
Generado a partir de metadatos: EmptyProjects (26 tablas) y GestionEmpresarial (309 tablas).
SOLO ARCHIVO GENERADO. NO APLICADO. SIN DATOS, SIN USUARIOS, SIN CREDENCIALES.
FASE A: tablas, columnas, PK, índices y CHECK. No crea relaciones a otros módulos.
FASE B: ejecutar 02_Relaciones.sql después de todas las FASE A.
Dependencias para cerrar relaciones: 01 Base_Organizacion, 12 Fiscal.
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
IF SCHEMA_ID(N'CAJA') IS NULL
EXEC sys.sp_executesql N'CREATE SCHEMA [CAJA] AUTHORIZATION [dbo];';

-- CAJA.ArqueoCaja | ERD EXUX
IF OBJECT_ID(N'CAJA.ArqueoCaja',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [CAJA].[ArqueoCaja] (
 [IdArqueoCaja] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdFondo] bigint NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [SaldoTeorico] decimal(20,4) NOT NULL,
 [SaldoFisico] decimal(20,4) NOT NULL,
 [IdResponsable] bigint NOT NULL,
 [Observaciones] nvarchar(600) NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_CAJA_ArqueoCaja_IdArqueoCaja] PRIMARY KEY CLUSTERED ([IdArqueoCaja] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdArqueoCaja","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdFondo","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Fecha","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"SaldoTeorico","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"SaldoFisico","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"IdResponsable","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Observaciones","type":"nvarchar","length":1200,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'CAJA.ArqueoCaja',N'U')
) THROW 51001,N'Estructura incompatible: CAJA.ArqueoCaja. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'CAJA.ArqueoCaja') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: CAJA.ArqueoCaja.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.ArqueoCaja') AND name=N'UX_CAJA_ArqueoCaja_IdArqueoCaja' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CAJA.ArqueoCaja.UX_CAJA_ArqueoCaja_IdArqueoCaja',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdArqueoCaja","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CAJA.ArqueoCaja') AND i.name=N'UX_CAJA_ArqueoCaja_IdArqueoCaja') THROW 51003,N'Columnas de índice incompatibles: CAJA.ArqueoCaja.UX_CAJA_ArqueoCaja_IdArqueoCaja',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CAJA.ArqueoCaja') AND i.name=N'UX_CAJA_ArqueoCaja_IdArqueoCaja')<>1 THROW 51003,N'Número de columnas de índice incompatible: CAJA.ArqueoCaja.UX_CAJA_ArqueoCaja_IdArqueoCaja',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.ArqueoCaja') AND name=N'UX_CAJA_ArqueoCaja_IdEmpresa_IdArqueoCaja')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_ArqueoCaja_IdEmpresa_IdArqueoCaja] ON [CAJA].[ArqueoCaja] ([IdEmpresa] ASC, [IdArqueoCaja] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.ArqueoCaja') AND name=N'UX_CAJA_ArqueoCaja_IdEmpresa_IdArqueoCaja' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CAJA.ArqueoCaja.UX_CAJA_ArqueoCaja_IdEmpresa_IdArqueoCaja',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"IdArqueoCaja","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CAJA.ArqueoCaja') AND i.name=N'UX_CAJA_ArqueoCaja_IdEmpresa_IdArqueoCaja') THROW 51003,N'Columnas de índice incompatibles: CAJA.ArqueoCaja.UX_CAJA_ArqueoCaja_IdEmpresa_IdArqueoCaja',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CAJA.ArqueoCaja') AND i.name=N'UX_CAJA_ArqueoCaja_IdEmpresa_IdArqueoCaja')<>2 THROW 51003,N'Número de columnas de índice incompatible: CAJA.ArqueoCaja.UX_CAJA_ArqueoCaja_IdEmpresa_IdArqueoCaja',1;
IF OBJECT_ID(N'CAJA.CK_EXUX_CAJA_ArqueoCaja_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [CAJA].[ArqueoCaja] WITH CHECK ADD CONSTRAINT [CK_EXUX_CAJA_ArqueoCaja_1] CHECK (SaldoFisico >= 0);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'CAJA.ArqueoCaja') AND name=N'CK_EXUX_CAJA_ArqueoCaja_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'saldofisico>=0') THROW 51004,N'CHECK incompatible: CAJA.ArqueoCaja.CK_EXUX_CAJA_ArqueoCaja_1',1;

-- CAJA.ArqueoDetalle | ERD EXUX
IF OBJECT_ID(N'CAJA.ArqueoDetalle',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [CAJA].[ArqueoDetalle] (
 [IdArqueoDetalle] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdArqueo] bigint NOT NULL,
 [Denominacion] decimal(20,4) NOT NULL,
 [Cantidad] int NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_CAJA_ArqueoDetalle_IdArqueoDetalle] PRIMARY KEY CLUSTERED ([IdArqueoDetalle] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdArqueoDetalle","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdArqueo","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Denominacion","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"Cantidad","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'CAJA.ArqueoDetalle',N'U')
) THROW 51001,N'Estructura incompatible: CAJA.ArqueoDetalle. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'CAJA.ArqueoDetalle') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: CAJA.ArqueoDetalle.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.ArqueoDetalle') AND name=N'UX_CAJA_ArqueoDetalle_IdArqueoDetalle' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CAJA.ArqueoDetalle.UX_CAJA_ArqueoDetalle_IdArqueoDetalle',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdArqueoDetalle","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CAJA.ArqueoDetalle') AND i.name=N'UX_CAJA_ArqueoDetalle_IdArqueoDetalle') THROW 51003,N'Columnas de índice incompatibles: CAJA.ArqueoDetalle.UX_CAJA_ArqueoDetalle_IdArqueoDetalle',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CAJA.ArqueoDetalle') AND i.name=N'UX_CAJA_ArqueoDetalle_IdArqueoDetalle')<>1 THROW 51003,N'Número de columnas de índice incompatible: CAJA.ArqueoDetalle.UX_CAJA_ArqueoDetalle_IdArqueoDetalle',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.ArqueoDetalle') AND name=N'UX_CAJA_ArqueoDetalle_IdArqueo_Denominacion')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_ArqueoDetalle_IdArqueo_Denominacion] ON [CAJA].[ArqueoDetalle] ([IdArqueo] ASC, [Denominacion] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.ArqueoDetalle') AND name=N'UX_CAJA_ArqueoDetalle_IdArqueo_Denominacion' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CAJA.ArqueoDetalle.UX_CAJA_ArqueoDetalle_IdArqueo_Denominacion',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdArqueo","ordinal":1,"descending":0,"included":0},{"name":"Denominacion","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CAJA.ArqueoDetalle') AND i.name=N'UX_CAJA_ArqueoDetalle_IdArqueo_Denominacion') THROW 51003,N'Columnas de índice incompatibles: CAJA.ArqueoDetalle.UX_CAJA_ArqueoDetalle_IdArqueo_Denominacion',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CAJA.ArqueoDetalle') AND i.name=N'UX_CAJA_ArqueoDetalle_IdArqueo_Denominacion')<>2 THROW 51003,N'Número de columnas de índice incompatible: CAJA.ArqueoDetalle.UX_CAJA_ArqueoDetalle_IdArqueo_Denominacion',1;
IF OBJECT_ID(N'CAJA.CK_EXUX_CAJA_ArqueoDetalle_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [CAJA].[ArqueoDetalle] WITH CHECK ADD CONSTRAINT [CK_EXUX_CAJA_ArqueoDetalle_1] CHECK (Denominacion > 0 AND Cantidad >= 0);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'CAJA.ArqueoDetalle') AND name=N'CK_EXUX_CAJA_ArqueoDetalle_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'denominacion>0andcantidad>=0') THROW 51004,N'CHECK incompatible: CAJA.ArqueoDetalle.CK_EXUX_CAJA_ArqueoDetalle_1',1;

-- CAJA.ComprobacionCaja | ERD EXUX
IF OBJECT_ID(N'CAJA.ComprobacionCaja',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [CAJA].[ComprobacionCaja] (
 [IdComprobacionCaja] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdVale] bigint NOT NULL,
 [IdComprobanteGasto] bigint NOT NULL,
 [ImporteAceptado] decimal(20,4) NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_CAJA_ComprobacionCaja_IdComprobacionCaja] PRIMARY KEY CLUSTERED ([IdComprobacionCaja] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdComprobacionCaja","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdVale","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdComprobanteGasto","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"ImporteAceptado","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"Estado","type":"varchar","length":20,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Fecha","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'CAJA.ComprobacionCaja',N'U')
) THROW 51001,N'Estructura incompatible: CAJA.ComprobacionCaja. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'CAJA.ComprobacionCaja') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: CAJA.ComprobacionCaja.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.ComprobacionCaja') AND name=N'UX_CAJA_ComprobacionCaja_IdComprobacionCaja' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CAJA.ComprobacionCaja.UX_CAJA_ComprobacionCaja_IdComprobacionCaja',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdComprobacionCaja","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CAJA.ComprobacionCaja') AND i.name=N'UX_CAJA_ComprobacionCaja_IdComprobacionCaja') THROW 51003,N'Columnas de índice incompatibles: CAJA.ComprobacionCaja.UX_CAJA_ComprobacionCaja_IdComprobacionCaja',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CAJA.ComprobacionCaja') AND i.name=N'UX_CAJA_ComprobacionCaja_IdComprobacionCaja')<>1 THROW 51003,N'Número de columnas de índice incompatible: CAJA.ComprobacionCaja.UX_CAJA_ComprobacionCaja_IdComprobacionCaja',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.ComprobacionCaja') AND name=N'UX_CAJA_ComprobacionCaja_IdVale_IdComprobanteGasto')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_ComprobacionCaja_IdVale_IdComprobanteGasto] ON [CAJA].[ComprobacionCaja] ([IdVale] ASC, [IdComprobanteGasto] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.ComprobacionCaja') AND name=N'UX_CAJA_ComprobacionCaja_IdVale_IdComprobanteGasto' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CAJA.ComprobacionCaja.UX_CAJA_ComprobacionCaja_IdVale_IdComprobanteGasto',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdVale","ordinal":1,"descending":0,"included":0},{"name":"IdComprobanteGasto","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CAJA.ComprobacionCaja') AND i.name=N'UX_CAJA_ComprobacionCaja_IdVale_IdComprobanteGasto') THROW 51003,N'Columnas de índice incompatibles: CAJA.ComprobacionCaja.UX_CAJA_ComprobacionCaja_IdVale_IdComprobanteGasto',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CAJA.ComprobacionCaja') AND i.name=N'UX_CAJA_ComprobacionCaja_IdVale_IdComprobanteGasto')<>2 THROW 51003,N'Número de columnas de índice incompatible: CAJA.ComprobacionCaja.UX_CAJA_ComprobacionCaja_IdVale_IdComprobanteGasto',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.ComprobacionCaja') AND name=N'UX_CAJA_ComprobacionCaja_IdEmpresa_IdComprobacionCaja')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_ComprobacionCaja_IdEmpresa_IdComprobacionCaja] ON [CAJA].[ComprobacionCaja] ([IdEmpresa] ASC, [IdComprobacionCaja] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.ComprobacionCaja') AND name=N'UX_CAJA_ComprobacionCaja_IdEmpresa_IdComprobacionCaja' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CAJA.ComprobacionCaja.UX_CAJA_ComprobacionCaja_IdEmpresa_IdComprobacionCaja',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"IdComprobacionCaja","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CAJA.ComprobacionCaja') AND i.name=N'UX_CAJA_ComprobacionCaja_IdEmpresa_IdComprobacionCaja') THROW 51003,N'Columnas de índice incompatibles: CAJA.ComprobacionCaja.UX_CAJA_ComprobacionCaja_IdEmpresa_IdComprobacionCaja',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CAJA.ComprobacionCaja') AND i.name=N'UX_CAJA_ComprobacionCaja_IdEmpresa_IdComprobacionCaja')<>2 THROW 51003,N'Número de columnas de índice incompatible: CAJA.ComprobacionCaja.UX_CAJA_ComprobacionCaja_IdEmpresa_IdComprobacionCaja',1;
IF OBJECT_ID(N'CAJA.CK_EXUX_CAJA_ComprobacionCaja_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [CAJA].[ComprobacionCaja] WITH CHECK ADD CONSTRAINT [CK_EXUX_CAJA_ComprobacionCaja_1] CHECK (ImporteAceptado > 0);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'CAJA.ComprobacionCaja') AND name=N'CK_EXUX_CAJA_ComprobacionCaja_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'importeaceptado>0') THROW 51004,N'CHECK incompatible: CAJA.ComprobacionCaja.CK_EXUX_CAJA_ComprobacionCaja_1',1;

-- CAJA.FondoCaja | ERD EXUX
IF OBJECT_ID(N'CAJA.FondoCaja',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [CAJA].[FondoCaja] (
 [IdFondoCaja] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdResponsable] bigint NOT NULL,
 [IdCentroCosto] bigint NOT NULL,
 [Codigo] nvarchar(30) NOT NULL,
 [IdMoneda] int NOT NULL,
 [MontoAutorizado] decimal(20,4) NOT NULL,
 [Activo] bit NOT NULL DEFAULT 1,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_CAJA_FondoCaja_IdFondoCaja] PRIMARY KEY CLUSTERED ([IdFondoCaja] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdFondoCaja","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdResponsable","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdCentroCosto","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Codigo","type":"nvarchar","length":60,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdMoneda","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"MontoAutorizado","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"Activo","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'CAJA.FondoCaja',N'U')
) THROW 51001,N'Estructura incompatible: CAJA.FondoCaja. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'CAJA.FondoCaja') AND c.name=N'Activo' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'1') THROW 51002,N'DEFAULT incompatible: CAJA.FondoCaja.Activo',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'CAJA.FondoCaja') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: CAJA.FondoCaja.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.FondoCaja') AND name=N'UX_CAJA_FondoCaja_IdFondoCaja' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CAJA.FondoCaja.UX_CAJA_FondoCaja_IdFondoCaja',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdFondoCaja","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CAJA.FondoCaja') AND i.name=N'UX_CAJA_FondoCaja_IdFondoCaja') THROW 51003,N'Columnas de índice incompatibles: CAJA.FondoCaja.UX_CAJA_FondoCaja_IdFondoCaja',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CAJA.FondoCaja') AND i.name=N'UX_CAJA_FondoCaja_IdFondoCaja')<>1 THROW 51003,N'Número de columnas de índice incompatible: CAJA.FondoCaja.UX_CAJA_FondoCaja_IdFondoCaja',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.FondoCaja') AND name=N'UX_CAJA_FondoCaja_IdEmpresa_Codigo')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_FondoCaja_IdEmpresa_Codigo] ON [CAJA].[FondoCaja] ([IdEmpresa] ASC, [Codigo] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.FondoCaja') AND name=N'UX_CAJA_FondoCaja_IdEmpresa_Codigo' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CAJA.FondoCaja.UX_CAJA_FondoCaja_IdEmpresa_Codigo',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"Codigo","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CAJA.FondoCaja') AND i.name=N'UX_CAJA_FondoCaja_IdEmpresa_Codigo') THROW 51003,N'Columnas de índice incompatibles: CAJA.FondoCaja.UX_CAJA_FondoCaja_IdEmpresa_Codigo',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CAJA.FondoCaja') AND i.name=N'UX_CAJA_FondoCaja_IdEmpresa_Codigo')<>2 THROW 51003,N'Número de columnas de índice incompatible: CAJA.FondoCaja.UX_CAJA_FondoCaja_IdEmpresa_Codigo',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.FondoCaja') AND name=N'UX_CAJA_FondoCaja_IdEmpresa_IdFondoCaja')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_FondoCaja_IdEmpresa_IdFondoCaja] ON [CAJA].[FondoCaja] ([IdEmpresa] ASC, [IdFondoCaja] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.FondoCaja') AND name=N'UX_CAJA_FondoCaja_IdEmpresa_IdFondoCaja' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CAJA.FondoCaja.UX_CAJA_FondoCaja_IdEmpresa_IdFondoCaja',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"IdFondoCaja","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CAJA.FondoCaja') AND i.name=N'UX_CAJA_FondoCaja_IdEmpresa_IdFondoCaja') THROW 51003,N'Columnas de índice incompatibles: CAJA.FondoCaja.UX_CAJA_FondoCaja_IdEmpresa_IdFondoCaja',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CAJA.FondoCaja') AND i.name=N'UX_CAJA_FondoCaja_IdEmpresa_IdFondoCaja')<>2 THROW 51003,N'Número de columnas de índice incompatible: CAJA.FondoCaja.UX_CAJA_FondoCaja_IdEmpresa_IdFondoCaja',1;
IF OBJECT_ID(N'CAJA.CK_EXUX_CAJA_FondoCaja_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [CAJA].[FondoCaja] WITH CHECK ADD CONSTRAINT [CK_EXUX_CAJA_FondoCaja_1] CHECK (MontoAutorizado > 0);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'CAJA.FondoCaja') AND name=N'CK_EXUX_CAJA_FondoCaja_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'montoautorizado>0') THROW 51004,N'CHECK incompatible: CAJA.FondoCaja.CK_EXUX_CAJA_FondoCaja_1',1;

-- CAJA.MovimientoFondo | ERD EXUX
IF OBJECT_ID(N'CAJA.MovimientoFondo',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [CAJA].[MovimientoFondo] (
 [IdMovimientoFondo] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdFondo] bigint NOT NULL,
 [IdOperacion] bigint NOT NULL,
 [IdVale] bigint NULL,
 [Tipo] varchar(20) NOT NULL,
 [Importe] decimal(20,4) NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [ClaveOperacion] uniqueidentifier NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 [IdMovimientoReversa] bigint NULL,
 [IdReposicion] bigint NULL,
 CONSTRAINT [UX_CAJA_MovimientoFondo_IdMovimientoFondo] PRIMARY KEY CLUSTERED ([IdMovimientoFondo] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdMovimientoFondo","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdFondo","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdOperacion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdVale","type":"bigint","length":8,"precision":19,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Tipo","type":"varchar","length":20,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Importe","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"Fecha","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"ClaveOperacion","type":"uniqueidentifier","length":16,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdMovimientoReversa","type":"bigint","length":8,"precision":19,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"IdReposicion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":1,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'CAJA.MovimientoFondo',N'U')
) THROW 51001,N'Estructura incompatible: CAJA.MovimientoFondo. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'CAJA.MovimientoFondo') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: CAJA.MovimientoFondo.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.MovimientoFondo') AND name=N'UX_CAJA_MovimientoFondo_IdMovimientoFondo' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CAJA.MovimientoFondo.UX_CAJA_MovimientoFondo_IdMovimientoFondo',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdMovimientoFondo","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CAJA.MovimientoFondo') AND i.name=N'UX_CAJA_MovimientoFondo_IdMovimientoFondo') THROW 51003,N'Columnas de índice incompatibles: CAJA.MovimientoFondo.UX_CAJA_MovimientoFondo_IdMovimientoFondo',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CAJA.MovimientoFondo') AND i.name=N'UX_CAJA_MovimientoFondo_IdMovimientoFondo')<>1 THROW 51003,N'Número de columnas de índice incompatible: CAJA.MovimientoFondo.UX_CAJA_MovimientoFondo_IdMovimientoFondo',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.MovimientoFondo') AND name=N'UX_CAJA_MovimientoFondo_IdEmpresa_ClaveOperacion')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_MovimientoFondo_IdEmpresa_ClaveOperacion] ON [CAJA].[MovimientoFondo] ([IdEmpresa] ASC, [ClaveOperacion] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.MovimientoFondo') AND name=N'UX_CAJA_MovimientoFondo_IdEmpresa_ClaveOperacion' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CAJA.MovimientoFondo.UX_CAJA_MovimientoFondo_IdEmpresa_ClaveOperacion',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"ClaveOperacion","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CAJA.MovimientoFondo') AND i.name=N'UX_CAJA_MovimientoFondo_IdEmpresa_ClaveOperacion') THROW 51003,N'Columnas de índice incompatibles: CAJA.MovimientoFondo.UX_CAJA_MovimientoFondo_IdEmpresa_ClaveOperacion',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CAJA.MovimientoFondo') AND i.name=N'UX_CAJA_MovimientoFondo_IdEmpresa_ClaveOperacion')<>2 THROW 51003,N'Número de columnas de índice incompatible: CAJA.MovimientoFondo.UX_CAJA_MovimientoFondo_IdEmpresa_ClaveOperacion',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.MovimientoFondo') AND name=N'UX_CAJA_MovimientoFondo_IdMovimientoReversa')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_MovimientoFondo_IdMovimientoReversa] ON [CAJA].[MovimientoFondo] ([IdMovimientoReversa] ASC) WHERE [IdMovimientoReversa] IS NOT NULL;';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.MovimientoFondo') AND name=N'UX_CAJA_MovimientoFondo_IdMovimientoReversa' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'idmovimientoreversaisnotnull') THROW 51003,N'Índice incompatible: CAJA.MovimientoFondo.UX_CAJA_MovimientoFondo_IdMovimientoReversa',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdMovimientoReversa","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CAJA.MovimientoFondo') AND i.name=N'UX_CAJA_MovimientoFondo_IdMovimientoReversa') THROW 51003,N'Columnas de índice incompatibles: CAJA.MovimientoFondo.UX_CAJA_MovimientoFondo_IdMovimientoReversa',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CAJA.MovimientoFondo') AND i.name=N'UX_CAJA_MovimientoFondo_IdMovimientoReversa')<>1 THROW 51003,N'Número de columnas de índice incompatible: CAJA.MovimientoFondo.UX_CAJA_MovimientoFondo_IdMovimientoReversa',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.MovimientoFondo') AND name=N'UX_CAJA_MovimientoFondo_IdEmpresa_IdMovimientoFondo')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_MovimientoFondo_IdEmpresa_IdMovimientoFondo] ON [CAJA].[MovimientoFondo] ([IdEmpresa] ASC, [IdMovimientoFondo] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.MovimientoFondo') AND name=N'UX_CAJA_MovimientoFondo_IdEmpresa_IdMovimientoFondo' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CAJA.MovimientoFondo.UX_CAJA_MovimientoFondo_IdEmpresa_IdMovimientoFondo',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"IdMovimientoFondo","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CAJA.MovimientoFondo') AND i.name=N'UX_CAJA_MovimientoFondo_IdEmpresa_IdMovimientoFondo') THROW 51003,N'Columnas de índice incompatibles: CAJA.MovimientoFondo.UX_CAJA_MovimientoFondo_IdEmpresa_IdMovimientoFondo',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CAJA.MovimientoFondo') AND i.name=N'UX_CAJA_MovimientoFondo_IdEmpresa_IdMovimientoFondo')<>2 THROW 51003,N'Número de columnas de índice incompatible: CAJA.MovimientoFondo.UX_CAJA_MovimientoFondo_IdEmpresa_IdMovimientoFondo',1;
IF OBJECT_ID(N'CAJA.CK_EXUX_CAJA_MovimientoFondo_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [CAJA].[MovimientoFondo] WITH CHECK ADD CONSTRAINT [CK_EXUX_CAJA_MovimientoFondo_1] CHECK (Importe <> 0);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'CAJA.MovimientoFondo') AND name=N'CK_EXUX_CAJA_MovimientoFondo_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'importe<>0') THROW 51004,N'CHECK incompatible: CAJA.MovimientoFondo.CK_EXUX_CAJA_MovimientoFondo_1',1;
IF OBJECT_ID(N'CAJA.CK_EXUX_CAJA_MovimientoFondo_2',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [CAJA].[MovimientoFondo] WITH CHECK ADD CONSTRAINT [CK_EXUX_CAJA_MovimientoFondo_2] CHECK (Tipo IN (''APERTURA'',''GASTO'',''REPOSICION'',''REINTEGRO'',''REVERSA''));';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'CAJA.MovimientoFondo') AND name=N'CK_EXUX_CAJA_MovimientoFondo_2' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'tipoin''apertura'',''gasto'',''reposicion'',''reintegro'',''reversa''') THROW 51004,N'CHECK incompatible: CAJA.MovimientoFondo.CK_EXUX_CAJA_MovimientoFondo_2',1;

-- CAJA.ReposicionCaja | ERD EXUX
IF OBJECT_ID(N'CAJA.ReposicionCaja',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [CAJA].[ReposicionCaja] (
 [IdReposicionCaja] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdFondo] bigint NOT NULL,
 [IdOperacion] bigint NOT NULL,
 [Importe] decimal(20,4) NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_CAJA_ReposicionCaja_IdReposicionCaja] PRIMARY KEY CLUSTERED ([IdReposicionCaja] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdReposicionCaja","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdFondo","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdOperacion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Importe","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"Estado","type":"varchar","length":20,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Fecha","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'CAJA.ReposicionCaja',N'U')
) THROW 51001,N'Estructura incompatible: CAJA.ReposicionCaja. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'CAJA.ReposicionCaja') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: CAJA.ReposicionCaja.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.ReposicionCaja') AND name=N'UX_CAJA_ReposicionCaja_IdReposicionCaja' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CAJA.ReposicionCaja.UX_CAJA_ReposicionCaja_IdReposicionCaja',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdReposicionCaja","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CAJA.ReposicionCaja') AND i.name=N'UX_CAJA_ReposicionCaja_IdReposicionCaja') THROW 51003,N'Columnas de índice incompatibles: CAJA.ReposicionCaja.UX_CAJA_ReposicionCaja_IdReposicionCaja',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CAJA.ReposicionCaja') AND i.name=N'UX_CAJA_ReposicionCaja_IdReposicionCaja')<>1 THROW 51003,N'Número de columnas de índice incompatible: CAJA.ReposicionCaja.UX_CAJA_ReposicionCaja_IdReposicionCaja',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.ReposicionCaja') AND name=N'UX_CAJA_ReposicionCaja_IdOperacion')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_ReposicionCaja_IdOperacion] ON [CAJA].[ReposicionCaja] ([IdOperacion] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.ReposicionCaja') AND name=N'UX_CAJA_ReposicionCaja_IdOperacion' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CAJA.ReposicionCaja.UX_CAJA_ReposicionCaja_IdOperacion',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdOperacion","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CAJA.ReposicionCaja') AND i.name=N'UX_CAJA_ReposicionCaja_IdOperacion') THROW 51003,N'Columnas de índice incompatibles: CAJA.ReposicionCaja.UX_CAJA_ReposicionCaja_IdOperacion',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CAJA.ReposicionCaja') AND i.name=N'UX_CAJA_ReposicionCaja_IdOperacion')<>1 THROW 51003,N'Número de columnas de índice incompatible: CAJA.ReposicionCaja.UX_CAJA_ReposicionCaja_IdOperacion',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.ReposicionCaja') AND name=N'UX_CAJA_ReposicionCaja_IdEmpresa_IdReposicionCaja')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_ReposicionCaja_IdEmpresa_IdReposicionCaja] ON [CAJA].[ReposicionCaja] ([IdEmpresa] ASC, [IdReposicionCaja] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.ReposicionCaja') AND name=N'UX_CAJA_ReposicionCaja_IdEmpresa_IdReposicionCaja' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CAJA.ReposicionCaja.UX_CAJA_ReposicionCaja_IdEmpresa_IdReposicionCaja',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"IdReposicionCaja","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CAJA.ReposicionCaja') AND i.name=N'UX_CAJA_ReposicionCaja_IdEmpresa_IdReposicionCaja') THROW 51003,N'Columnas de índice incompatibles: CAJA.ReposicionCaja.UX_CAJA_ReposicionCaja_IdEmpresa_IdReposicionCaja',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CAJA.ReposicionCaja') AND i.name=N'UX_CAJA_ReposicionCaja_IdEmpresa_IdReposicionCaja')<>2 THROW 51003,N'Número de columnas de índice incompatible: CAJA.ReposicionCaja.UX_CAJA_ReposicionCaja_IdEmpresa_IdReposicionCaja',1;
IF OBJECT_ID(N'CAJA.CK_EXUX_CAJA_ReposicionCaja_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [CAJA].[ReposicionCaja] WITH CHECK ADD CONSTRAINT [CK_EXUX_CAJA_ReposicionCaja_1] CHECK (Importe > 0);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'CAJA.ReposicionCaja') AND name=N'CK_EXUX_CAJA_ReposicionCaja_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'importe>0') THROW 51004,N'CHECK incompatible: CAJA.ReposicionCaja.CK_EXUX_CAJA_ReposicionCaja_1',1;

-- CAJA.ReposicionDetalle | ERD EXUX
IF OBJECT_ID(N'CAJA.ReposicionDetalle',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [CAJA].[ReposicionDetalle] (
 [IdReposicionDetalle] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdReposicion] bigint NOT NULL,
 [IdComprobacionCaja] bigint NOT NULL,
 [Importe] decimal(20,4) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_CAJA_ReposicionDetalle_IdReposicionDetalle] PRIMARY KEY CLUSTERED ([IdReposicionDetalle] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdReposicionDetalle","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdReposicion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdComprobacionCaja","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Importe","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'CAJA.ReposicionDetalle',N'U')
) THROW 51001,N'Estructura incompatible: CAJA.ReposicionDetalle. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'CAJA.ReposicionDetalle') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: CAJA.ReposicionDetalle.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.ReposicionDetalle') AND name=N'UX_CAJA_ReposicionDetalle_IdReposicionDetalle' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CAJA.ReposicionDetalle.UX_CAJA_ReposicionDetalle_IdReposicionDetalle',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdReposicionDetalle","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CAJA.ReposicionDetalle') AND i.name=N'UX_CAJA_ReposicionDetalle_IdReposicionDetalle') THROW 51003,N'Columnas de índice incompatibles: CAJA.ReposicionDetalle.UX_CAJA_ReposicionDetalle_IdReposicionDetalle',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CAJA.ReposicionDetalle') AND i.name=N'UX_CAJA_ReposicionDetalle_IdReposicionDetalle')<>1 THROW 51003,N'Número de columnas de índice incompatible: CAJA.ReposicionDetalle.UX_CAJA_ReposicionDetalle_IdReposicionDetalle',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.ReposicionDetalle') AND name=N'UX_CAJA_ReposicionDetalle_IdComprobacionCaja')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_ReposicionDetalle_IdComprobacionCaja] ON [CAJA].[ReposicionDetalle] ([IdComprobacionCaja] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.ReposicionDetalle') AND name=N'UX_CAJA_ReposicionDetalle_IdComprobacionCaja' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CAJA.ReposicionDetalle.UX_CAJA_ReposicionDetalle_IdComprobacionCaja',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdComprobacionCaja","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CAJA.ReposicionDetalle') AND i.name=N'UX_CAJA_ReposicionDetalle_IdComprobacionCaja') THROW 51003,N'Columnas de índice incompatibles: CAJA.ReposicionDetalle.UX_CAJA_ReposicionDetalle_IdComprobacionCaja',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CAJA.ReposicionDetalle') AND i.name=N'UX_CAJA_ReposicionDetalle_IdComprobacionCaja')<>1 THROW 51003,N'Número de columnas de índice incompatible: CAJA.ReposicionDetalle.UX_CAJA_ReposicionDetalle_IdComprobacionCaja',1;
IF OBJECT_ID(N'CAJA.CK_EXUX_CAJA_ReposicionDetalle_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [CAJA].[ReposicionDetalle] WITH CHECK ADD CONSTRAINT [CK_EXUX_CAJA_ReposicionDetalle_1] CHECK (Importe > 0);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'CAJA.ReposicionDetalle') AND name=N'CK_EXUX_CAJA_ReposicionDetalle_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'importe>0') THROW 51004,N'CHECK incompatible: CAJA.ReposicionDetalle.CK_EXUX_CAJA_ReposicionDetalle_1',1;

-- CAJA.ValeCaja | ERD EXUX
IF OBJECT_ID(N'CAJA.ValeCaja',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [CAJA].[ValeCaja] (
 [IdValeCaja] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdFondo] bigint NOT NULL,
 [IdOperacion] bigint NOT NULL,
 [Importe] decimal(20,4) NOT NULL,
 [Fecha] date NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [Concepto] nvarchar(500) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_CAJA_ValeCaja_IdValeCaja] PRIMARY KEY CLUSTERED ([IdValeCaja] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdValeCaja","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdFondo","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdOperacion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Importe","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"Fecha","type":"date","length":3,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Estado","type":"varchar","length":20,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Concepto","type":"nvarchar","length":1000,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'CAJA.ValeCaja',N'U')
) THROW 51001,N'Estructura incompatible: CAJA.ValeCaja. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'CAJA.ValeCaja') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: CAJA.ValeCaja.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.ValeCaja') AND name=N'UX_CAJA_ValeCaja_IdValeCaja' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CAJA.ValeCaja.UX_CAJA_ValeCaja_IdValeCaja',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdValeCaja","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CAJA.ValeCaja') AND i.name=N'UX_CAJA_ValeCaja_IdValeCaja') THROW 51003,N'Columnas de índice incompatibles: CAJA.ValeCaja.UX_CAJA_ValeCaja_IdValeCaja',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CAJA.ValeCaja') AND i.name=N'UX_CAJA_ValeCaja_IdValeCaja')<>1 THROW 51003,N'Número de columnas de índice incompatible: CAJA.ValeCaja.UX_CAJA_ValeCaja_IdValeCaja',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.ValeCaja') AND name=N'UX_CAJA_ValeCaja_IdOperacion')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_ValeCaja_IdOperacion] ON [CAJA].[ValeCaja] ([IdOperacion] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.ValeCaja') AND name=N'UX_CAJA_ValeCaja_IdOperacion' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CAJA.ValeCaja.UX_CAJA_ValeCaja_IdOperacion',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdOperacion","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CAJA.ValeCaja') AND i.name=N'UX_CAJA_ValeCaja_IdOperacion') THROW 51003,N'Columnas de índice incompatibles: CAJA.ValeCaja.UX_CAJA_ValeCaja_IdOperacion',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CAJA.ValeCaja') AND i.name=N'UX_CAJA_ValeCaja_IdOperacion')<>1 THROW 51003,N'Número de columnas de índice incompatible: CAJA.ValeCaja.UX_CAJA_ValeCaja_IdOperacion',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.ValeCaja') AND name=N'UX_CAJA_ValeCaja_IdEmpresa_IdValeCaja')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_ValeCaja_IdEmpresa_IdValeCaja] ON [CAJA].[ValeCaja] ([IdEmpresa] ASC, [IdValeCaja] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CAJA.ValeCaja') AND name=N'UX_CAJA_ValeCaja_IdEmpresa_IdValeCaja' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CAJA.ValeCaja.UX_CAJA_ValeCaja_IdEmpresa_IdValeCaja',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"IdValeCaja","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CAJA.ValeCaja') AND i.name=N'UX_CAJA_ValeCaja_IdEmpresa_IdValeCaja') THROW 51003,N'Columnas de índice incompatibles: CAJA.ValeCaja.UX_CAJA_ValeCaja_IdEmpresa_IdValeCaja',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CAJA.ValeCaja') AND i.name=N'UX_CAJA_ValeCaja_IdEmpresa_IdValeCaja')<>2 THROW 51003,N'Número de columnas de índice incompatible: CAJA.ValeCaja.UX_CAJA_ValeCaja_IdEmpresa_IdValeCaja',1;
IF OBJECT_ID(N'CAJA.CK_EXUX_CAJA_ValeCaja_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [CAJA].[ValeCaja] WITH CHECK ADD CONSTRAINT [CK_EXUX_CAJA_ValeCaja_1] CHECK (Importe > 0);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'CAJA.ValeCaja') AND name=N'CK_EXUX_CAJA_ValeCaja_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'importe>0') THROW 51004,N'CHECK incompatible: CAJA.ValeCaja.CK_EXUX_CAJA_ValeCaja_1',1;
COMMIT TRANSACTION;
END TRY
BEGIN CATCH
 IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;
PRINT N'FASE A completa: Caja_Chica. Relaciones pendientes en 02_Relaciones.sql.';
