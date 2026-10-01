/*
EXUX | Universidad Maya | Propuesta de reestructura SQL Server 2022
MÓDULO 10: Viaticos
Generado a partir de metadatos: EmptyProjects (26 tablas) y GestionEmpresarial (309 tablas).
SOLO ARCHIVO GENERADO. NO APLICADO. SIN DATOS, SIN USUARIOS, SIN CREDENCIALES.
FASE A: tablas, columnas, PK, índices y CHECK. No crea relaciones a otros módulos.
FASE B: ejecutar 02_Relaciones.sql después de todas las FASE A.
Dependencias para cerrar relaciones: 01 Base_Organizacion, 08 Bancos_Tesoreria, 12 Fiscal, 14 Documentos.
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
IF SCHEMA_ID(N'VIA') IS NULL
EXEC sys.sp_executesql N'CREATE SCHEMA [VIA] AUTHORIZATION [dbo];';

-- VIA.AnticipoViatico | ERD EXUX
IF OBJECT_ID(N'VIA.AnticipoViatico',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [VIA].[AnticipoViatico] (
 [IdAnticipoViatico] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdSolicitud] bigint NOT NULL,
 [Importe] decimal(20,4) NOT NULL,
 [Fecha] date NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_VIA_AnticipoViatico_IdAnticipoViatico] PRIMARY KEY CLUSTERED ([IdAnticipoViatico] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdAnticipoViatico","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdSolicitud","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Importe","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"Fecha","type":"date","length":3,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Estado","type":"varchar","length":20,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'VIA.AnticipoViatico',N'U')
) THROW 51001,N'Estructura incompatible: VIA.AnticipoViatico. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'VIA.AnticipoViatico') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: VIA.AnticipoViatico.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'VIA.AnticipoViatico') AND name=N'UX_VIA_AnticipoViatico_IdAnticipoViatico' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: VIA.AnticipoViatico.UX_VIA_AnticipoViatico_IdAnticipoViatico',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdAnticipoViatico","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'VIA.AnticipoViatico') AND i.name=N'UX_VIA_AnticipoViatico_IdAnticipoViatico') THROW 51003,N'Columnas de índice incompatibles: VIA.AnticipoViatico.UX_VIA_AnticipoViatico_IdAnticipoViatico',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'VIA.AnticipoViatico') AND i.name=N'UX_VIA_AnticipoViatico_IdAnticipoViatico')<>1 THROW 51003,N'Número de columnas de índice incompatible: VIA.AnticipoViatico.UX_VIA_AnticipoViatico_IdAnticipoViatico',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'VIA.AnticipoViatico') AND name=N'UX_VIA_AnticipoViatico_IdEmpresa_IdAnticipoViatico')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_VIA_AnticipoViatico_IdEmpresa_IdAnticipoViatico] ON [VIA].[AnticipoViatico] ([IdEmpresa] ASC, [IdAnticipoViatico] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'VIA.AnticipoViatico') AND name=N'UX_VIA_AnticipoViatico_IdEmpresa_IdAnticipoViatico' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: VIA.AnticipoViatico.UX_VIA_AnticipoViatico_IdEmpresa_IdAnticipoViatico',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"IdAnticipoViatico","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'VIA.AnticipoViatico') AND i.name=N'UX_VIA_AnticipoViatico_IdEmpresa_IdAnticipoViatico') THROW 51003,N'Columnas de índice incompatibles: VIA.AnticipoViatico.UX_VIA_AnticipoViatico_IdEmpresa_IdAnticipoViatico',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'VIA.AnticipoViatico') AND i.name=N'UX_VIA_AnticipoViatico_IdEmpresa_IdAnticipoViatico')<>2 THROW 51003,N'Número de columnas de índice incompatible: VIA.AnticipoViatico.UX_VIA_AnticipoViatico_IdEmpresa_IdAnticipoViatico',1;
IF OBJECT_ID(N'VIA.CK_EXUX_VIA_AnticipoViatico_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [VIA].[AnticipoViatico] WITH CHECK ADD CONSTRAINT [CK_EXUX_VIA_AnticipoViatico_1] CHECK (Importe > 0);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'VIA.AnticipoViatico') AND name=N'CK_EXUX_VIA_AnticipoViatico_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'importe>0') THROW 51004,N'CHECK incompatible: VIA.AnticipoViatico.CK_EXUX_VIA_AnticipoViatico_1',1;

-- VIA.ComprobacionViatico | ERD EXUX
IF OBJECT_ID(N'VIA.ComprobacionViatico',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [VIA].[ComprobacionViatico] (
 [IdComprobacionViatico] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdSolicitud] bigint NOT NULL,
 [IdComprobanteGasto] bigint NOT NULL,
 [ImporteAceptado] decimal(20,4) NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_VIA_ComprobacionViatico_IdComprobacionViatico] PRIMARY KEY CLUSTERED ([IdComprobacionViatico] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdComprobacionViatico","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdSolicitud","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdComprobanteGasto","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"ImporteAceptado","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"Estado","type":"varchar","length":20,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Fecha","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'VIA.ComprobacionViatico',N'U')
) THROW 51001,N'Estructura incompatible: VIA.ComprobacionViatico. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'VIA.ComprobacionViatico') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: VIA.ComprobacionViatico.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'VIA.ComprobacionViatico') AND name=N'UX_VIA_ComprobacionViatico_IdComprobacionViatico' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: VIA.ComprobacionViatico.UX_VIA_ComprobacionViatico_IdComprobacionViatico',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdComprobacionViatico","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'VIA.ComprobacionViatico') AND i.name=N'UX_VIA_ComprobacionViatico_IdComprobacionViatico') THROW 51003,N'Columnas de índice incompatibles: VIA.ComprobacionViatico.UX_VIA_ComprobacionViatico_IdComprobacionViatico',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'VIA.ComprobacionViatico') AND i.name=N'UX_VIA_ComprobacionViatico_IdComprobacionViatico')<>1 THROW 51003,N'Número de columnas de índice incompatible: VIA.ComprobacionViatico.UX_VIA_ComprobacionViatico_IdComprobacionViatico',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'VIA.ComprobacionViatico') AND name=N'UX_VIA_ComprobacionViatico_IdSolicitud_IdComprobanteGasto')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_VIA_ComprobacionViatico_IdSolicitud_IdComprobanteGasto] ON [VIA].[ComprobacionViatico] ([IdSolicitud] ASC, [IdComprobanteGasto] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'VIA.ComprobacionViatico') AND name=N'UX_VIA_ComprobacionViatico_IdSolicitud_IdComprobanteGasto' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: VIA.ComprobacionViatico.UX_VIA_ComprobacionViatico_IdSolicitud_IdComprobanteGasto',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdSolicitud","ordinal":1,"descending":0,"included":0},{"name":"IdComprobanteGasto","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'VIA.ComprobacionViatico') AND i.name=N'UX_VIA_ComprobacionViatico_IdSolicitud_IdComprobanteGasto') THROW 51003,N'Columnas de índice incompatibles: VIA.ComprobacionViatico.UX_VIA_ComprobacionViatico_IdSolicitud_IdComprobanteGasto',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'VIA.ComprobacionViatico') AND i.name=N'UX_VIA_ComprobacionViatico_IdSolicitud_IdComprobanteGasto')<>2 THROW 51003,N'Número de columnas de índice incompatible: VIA.ComprobacionViatico.UX_VIA_ComprobacionViatico_IdSolicitud_IdComprobanteGasto',1;
IF OBJECT_ID(N'VIA.CK_EXUX_VIA_ComprobacionViatico_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [VIA].[ComprobacionViatico] WITH CHECK ADD CONSTRAINT [CK_EXUX_VIA_ComprobacionViatico_1] CHECK (ImporteAceptado > 0);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'VIA.ComprobacionViatico') AND name=N'CK_EXUX_VIA_ComprobacionViatico_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'importeaceptado>0') THROW 51004,N'CHECK incompatible: VIA.ComprobacionViatico.CK_EXUX_VIA_ComprobacionViatico_1',1;

-- VIA.ReintegroViatico | ERD EXUX
IF OBJECT_ID(N'VIA.ReintegroViatico',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [VIA].[ReintegroViatico] (
 [IdReintegroViatico] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdSolicitud] bigint NOT NULL,
 [IdMovimientoBancario] bigint NULL,
 [Importe] decimal(20,4) NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [IdDocumentoEvidencia] bigint NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_VIA_ReintegroViatico_IdReintegroViatico] PRIMARY KEY CLUSTERED ([IdReintegroViatico] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdReintegroViatico","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdSolicitud","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdMovimientoBancario","type":"bigint","length":8,"precision":19,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Importe","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"Fecha","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"IdDocumentoEvidencia","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'VIA.ReintegroViatico',N'U')
) THROW 51001,N'Estructura incompatible: VIA.ReintegroViatico. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'VIA.ReintegroViatico') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: VIA.ReintegroViatico.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'VIA.ReintegroViatico') AND name=N'UX_VIA_ReintegroViatico_IdReintegroViatico' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: VIA.ReintegroViatico.UX_VIA_ReintegroViatico_IdReintegroViatico',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdReintegroViatico","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'VIA.ReintegroViatico') AND i.name=N'UX_VIA_ReintegroViatico_IdReintegroViatico') THROW 51003,N'Columnas de índice incompatibles: VIA.ReintegroViatico.UX_VIA_ReintegroViatico_IdReintegroViatico',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'VIA.ReintegroViatico') AND i.name=N'UX_VIA_ReintegroViatico_IdReintegroViatico')<>1 THROW 51003,N'Número de columnas de índice incompatible: VIA.ReintegroViatico.UX_VIA_ReintegroViatico_IdReintegroViatico',1;
IF OBJECT_ID(N'VIA.CK_EXUX_VIA_ReintegroViatico_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [VIA].[ReintegroViatico] WITH CHECK ADD CONSTRAINT [CK_EXUX_VIA_ReintegroViatico_1] CHECK (Importe > 0);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'VIA.ReintegroViatico') AND name=N'CK_EXUX_VIA_ReintegroViatico_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'importe>0') THROW 51004,N'CHECK incompatible: VIA.ReintegroViatico.CK_EXUX_VIA_ReintegroViatico_1',1;

-- VIA.SolicitudViatico | ERD EXUX
IF OBJECT_ID(N'VIA.SolicitudViatico',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [VIA].[SolicitudViatico] (
 [IdSolicitudViatico] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdOperacion] bigint NOT NULL,
 [IdResponsable] bigint NOT NULL,
 [IdCentroCosto] bigint NOT NULL,
 [IdMoneda] int NOT NULL,
 [Comision] nvarchar(800) NOT NULL,
 [Destino] nvarchar(300) NOT NULL,
 [FechaInicio] date NOT NULL,
 [FechaFin] date NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_VIA_SolicitudViatico_IdSolicitudViatico] PRIMARY KEY CLUSTERED ([IdSolicitudViatico] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdSolicitudViatico","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdOperacion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdResponsable","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdCentroCosto","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdMoneda","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Comision","type":"nvarchar","length":1600,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Destino","type":"nvarchar","length":600,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FechaInicio","type":"date","length":3,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FechaFin","type":"date","length":3,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Estado","type":"varchar","length":20,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'VIA.SolicitudViatico',N'U')
) THROW 51001,N'Estructura incompatible: VIA.SolicitudViatico. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'VIA.SolicitudViatico') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: VIA.SolicitudViatico.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'VIA.SolicitudViatico') AND name=N'UX_VIA_SolicitudViatico_IdSolicitudViatico' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: VIA.SolicitudViatico.UX_VIA_SolicitudViatico_IdSolicitudViatico',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdSolicitudViatico","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'VIA.SolicitudViatico') AND i.name=N'UX_VIA_SolicitudViatico_IdSolicitudViatico') THROW 51003,N'Columnas de índice incompatibles: VIA.SolicitudViatico.UX_VIA_SolicitudViatico_IdSolicitudViatico',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'VIA.SolicitudViatico') AND i.name=N'UX_VIA_SolicitudViatico_IdSolicitudViatico')<>1 THROW 51003,N'Número de columnas de índice incompatible: VIA.SolicitudViatico.UX_VIA_SolicitudViatico_IdSolicitudViatico',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'VIA.SolicitudViatico') AND name=N'UX_VIA_SolicitudViatico_IdOperacion')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_VIA_SolicitudViatico_IdOperacion] ON [VIA].[SolicitudViatico] ([IdOperacion] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'VIA.SolicitudViatico') AND name=N'UX_VIA_SolicitudViatico_IdOperacion' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: VIA.SolicitudViatico.UX_VIA_SolicitudViatico_IdOperacion',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdOperacion","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'VIA.SolicitudViatico') AND i.name=N'UX_VIA_SolicitudViatico_IdOperacion') THROW 51003,N'Columnas de índice incompatibles: VIA.SolicitudViatico.UX_VIA_SolicitudViatico_IdOperacion',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'VIA.SolicitudViatico') AND i.name=N'UX_VIA_SolicitudViatico_IdOperacion')<>1 THROW 51003,N'Número de columnas de índice incompatible: VIA.SolicitudViatico.UX_VIA_SolicitudViatico_IdOperacion',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'VIA.SolicitudViatico') AND name=N'UX_VIA_SolicitudViatico_IdEmpresa_IdSolicitudViatico')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_VIA_SolicitudViatico_IdEmpresa_IdSolicitudViatico] ON [VIA].[SolicitudViatico] ([IdEmpresa] ASC, [IdSolicitudViatico] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'VIA.SolicitudViatico') AND name=N'UX_VIA_SolicitudViatico_IdEmpresa_IdSolicitudViatico' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: VIA.SolicitudViatico.UX_VIA_SolicitudViatico_IdEmpresa_IdSolicitudViatico',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"IdSolicitudViatico","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'VIA.SolicitudViatico') AND i.name=N'UX_VIA_SolicitudViatico_IdEmpresa_IdSolicitudViatico') THROW 51003,N'Columnas de índice incompatibles: VIA.SolicitudViatico.UX_VIA_SolicitudViatico_IdEmpresa_IdSolicitudViatico',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'VIA.SolicitudViatico') AND i.name=N'UX_VIA_SolicitudViatico_IdEmpresa_IdSolicitudViatico')<>2 THROW 51003,N'Número de columnas de índice incompatible: VIA.SolicitudViatico.UX_VIA_SolicitudViatico_IdEmpresa_IdSolicitudViatico',1;
IF OBJECT_ID(N'VIA.CK_EXUX_VIA_SolicitudViatico_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [VIA].[SolicitudViatico] WITH CHECK ADD CONSTRAINT [CK_EXUX_VIA_SolicitudViatico_1] CHECK (FechaFin >= FechaInicio);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'VIA.SolicitudViatico') AND name=N'CK_EXUX_VIA_SolicitudViatico_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'fechafin>=fechainicio') THROW 51004,N'CHECK incompatible: VIA.SolicitudViatico.CK_EXUX_VIA_SolicitudViatico_1',1;
COMMIT TRANSACTION;
END TRY
BEGIN CATCH
 IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;
PRINT N'FASE A completa: Viaticos. Relaciones pendientes en 02_Relaciones.sql.';
