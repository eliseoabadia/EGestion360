/*
EXUX | Universidad Maya | Propuesta de reestructura SQL Server 2022
MÓDULO 15: Control_Auditoria
Generado a partir de metadatos: EmptyProjects (26 tablas) y GestionEmpresarial (309 tablas).
SOLO ARCHIVO GENERADO. NO APLICADO. SIN DATOS, SIN USUARIOS, SIN CREDENCIALES.
FASE A: tablas, columnas, PK, índices y CHECK. No crea relaciones a otros módulos.
FASE B: ejecutar 02_Relaciones.sql después de todas las FASE A.
Dependencias para cerrar relaciones: 01 Base_Organizacion, 14 Documentos.
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
IF SCHEMA_ID(N'CTL') IS NULL
EXEC sys.sp_executesql N'CREATE SCHEMA [CTL] AUTHORIZATION [dbo];';
IF SCHEMA_ID(N'PBR') IS NULL
EXEC sys.sp_executesql N'CREATE SCHEMA [PBR] AUTHORIZATION [dbo];';

-- CTL.CasoRiesgo | ERD EXUX
IF OBJECT_ID(N'CTL.CasoRiesgo',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [CTL].[CasoRiesgo] (
 [IdCasoRiesgo] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdRegla] bigint NOT NULL,
 [IdOperacion] bigint NOT NULL,
 [IdDocumentoEvidencia] bigint NULL,
 [Descripcion] nvarchar(1500) NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [AbiertoUtc] datetime2(7) NOT NULL,
 [CerradoUtc] datetime2(7) NULL,
 [IdResponsable] bigint NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_CTL_CasoRiesgo_IdCasoRiesgo] PRIMARY KEY CLUSTERED ([IdCasoRiesgo] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdCasoRiesgo","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdRegla","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdOperacion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdDocumentoEvidencia","type":"bigint","length":8,"precision":19,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Descripcion","type":"nvarchar","length":3000,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Estado","type":"varchar","length":20,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"AbiertoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"CerradoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":1,"identity":0,"computed":0},{"name":"IdResponsable","type":"bigint","length":8,"precision":19,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'CTL.CasoRiesgo',N'U')
) THROW 51001,N'Estructura incompatible: CTL.CasoRiesgo. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'CTL.CasoRiesgo') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: CTL.CasoRiesgo.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CTL.CasoRiesgo') AND name=N'UX_CTL_CasoRiesgo_IdCasoRiesgo' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CTL.CasoRiesgo.UX_CTL_CasoRiesgo_IdCasoRiesgo',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdCasoRiesgo","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CTL.CasoRiesgo') AND i.name=N'UX_CTL_CasoRiesgo_IdCasoRiesgo') THROW 51003,N'Columnas de índice incompatibles: CTL.CasoRiesgo.UX_CTL_CasoRiesgo_IdCasoRiesgo',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CTL.CasoRiesgo') AND i.name=N'UX_CTL_CasoRiesgo_IdCasoRiesgo')<>1 THROW 51003,N'Número de columnas de índice incompatible: CTL.CasoRiesgo.UX_CTL_CasoRiesgo_IdCasoRiesgo',1;
IF OBJECT_ID(N'CTL.CK_EXUX_CTL_CasoRiesgo_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [CTL].[CasoRiesgo] WITH CHECK ADD CONSTRAINT [CK_EXUX_CTL_CasoRiesgo_1] CHECK (CerradoUtc IS NULL OR CerradoUtc >= AbiertoUtc);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'CTL.CasoRiesgo') AND name=N'CK_EXUX_CTL_CasoRiesgo_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'cerradoutcisnullorcerradoutc>=abiertoutc') THROW 51004,N'CHECK incompatible: CTL.CasoRiesgo.CK_EXUX_CTL_CasoRiesgo_1',1;

-- CTL.ReglaRiesgo | ERD EXUX
IF OBJECT_ID(N'CTL.ReglaRiesgo',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [CTL].[ReglaRiesgo] (
 [IdReglaRiesgo] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [Codigo] nvarchar(40) NOT NULL,
 [Version] int NOT NULL,
 [Escenario] nvarchar(300) NOT NULL,
 [ParametrosJson] nvarchar(max) NOT NULL,
 [Desde] date NOT NULL,
 [Hasta] date NULL,
 [Activo] bit NOT NULL DEFAULT 1,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_CTL_ReglaRiesgo_IdReglaRiesgo] PRIMARY KEY CLUSTERED ([IdReglaRiesgo] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdReglaRiesgo","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Codigo","type":"nvarchar","length":80,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Version","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Escenario","type":"nvarchar","length":600,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"ParametrosJson","type":"nvarchar","length":-1,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Desde","type":"date","length":3,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Hasta","type":"date","length":3,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Activo","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'CTL.ReglaRiesgo',N'U')
) THROW 51001,N'Estructura incompatible: CTL.ReglaRiesgo. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'CTL.ReglaRiesgo') AND c.name=N'Activo' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'1') THROW 51002,N'DEFAULT incompatible: CTL.ReglaRiesgo.Activo',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'CTL.ReglaRiesgo') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: CTL.ReglaRiesgo.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CTL.ReglaRiesgo') AND name=N'UX_CTL_ReglaRiesgo_IdReglaRiesgo' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CTL.ReglaRiesgo.UX_CTL_ReglaRiesgo_IdReglaRiesgo',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdReglaRiesgo","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CTL.ReglaRiesgo') AND i.name=N'UX_CTL_ReglaRiesgo_IdReglaRiesgo') THROW 51003,N'Columnas de índice incompatibles: CTL.ReglaRiesgo.UX_CTL_ReglaRiesgo_IdReglaRiesgo',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CTL.ReglaRiesgo') AND i.name=N'UX_CTL_ReglaRiesgo_IdReglaRiesgo')<>1 THROW 51003,N'Número de columnas de índice incompatible: CTL.ReglaRiesgo.UX_CTL_ReglaRiesgo_IdReglaRiesgo',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CTL.ReglaRiesgo') AND name=N'UX_CTL_ReglaRiesgo_IdEmpresa_Codigo_Version')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_CTL_ReglaRiesgo_IdEmpresa_Codigo_Version] ON [CTL].[ReglaRiesgo] ([IdEmpresa] ASC, [Codigo] ASC, [Version] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CTL.ReglaRiesgo') AND name=N'UX_CTL_ReglaRiesgo_IdEmpresa_Codigo_Version' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CTL.ReglaRiesgo.UX_CTL_ReglaRiesgo_IdEmpresa_Codigo_Version',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"Codigo","ordinal":2,"descending":0,"included":0},{"name":"Version","ordinal":3,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CTL.ReglaRiesgo') AND i.name=N'UX_CTL_ReglaRiesgo_IdEmpresa_Codigo_Version') THROW 51003,N'Columnas de índice incompatibles: CTL.ReglaRiesgo.UX_CTL_ReglaRiesgo_IdEmpresa_Codigo_Version',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CTL.ReglaRiesgo') AND i.name=N'UX_CTL_ReglaRiesgo_IdEmpresa_Codigo_Version')<>3 THROW 51003,N'Número de columnas de índice incompatible: CTL.ReglaRiesgo.UX_CTL_ReglaRiesgo_IdEmpresa_Codigo_Version',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CTL.ReglaRiesgo') AND name=N'UX_CTL_ReglaRiesgo_IdEmpresa_IdReglaRiesgo')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_CTL_ReglaRiesgo_IdEmpresa_IdReglaRiesgo] ON [CTL].[ReglaRiesgo] ([IdEmpresa] ASC, [IdReglaRiesgo] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CTL.ReglaRiesgo') AND name=N'UX_CTL_ReglaRiesgo_IdEmpresa_IdReglaRiesgo' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CTL.ReglaRiesgo.UX_CTL_ReglaRiesgo_IdEmpresa_IdReglaRiesgo',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"IdReglaRiesgo","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CTL.ReglaRiesgo') AND i.name=N'UX_CTL_ReglaRiesgo_IdEmpresa_IdReglaRiesgo') THROW 51003,N'Columnas de índice incompatibles: CTL.ReglaRiesgo.UX_CTL_ReglaRiesgo_IdEmpresa_IdReglaRiesgo',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CTL.ReglaRiesgo') AND i.name=N'UX_CTL_ReglaRiesgo_IdEmpresa_IdReglaRiesgo')<>2 THROW 51003,N'Número de columnas de índice incompatible: CTL.ReglaRiesgo.UX_CTL_ReglaRiesgo_IdEmpresa_IdReglaRiesgo',1;
IF OBJECT_ID(N'CTL.CK_EXUX_CTL_ReglaRiesgo_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [CTL].[ReglaRiesgo] WITH CHECK ADD CONSTRAINT [CK_EXUX_CTL_ReglaRiesgo_1] CHECK (Version > 0 AND ISJSON(ParametrosJson)=1);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'CTL.ReglaRiesgo') AND name=N'CK_EXUX_CTL_ReglaRiesgo_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'version>0andisjsonparametrosjson=1') THROW 51004,N'CHECK incompatible: CTL.ReglaRiesgo.CK_EXUX_CTL_ReglaRiesgo_1',1;
IF OBJECT_ID(N'CTL.CK_EXUX_CTL_ReglaRiesgo_2',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [CTL].[ReglaRiesgo] WITH CHECK ADD CONSTRAINT [CK_EXUX_CTL_ReglaRiesgo_2] CHECK (Hasta IS NULL OR Hasta >= Desde);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'CTL.ReglaRiesgo') AND name=N'CK_EXUX_CTL_ReglaRiesgo_2' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'hastaisnullorhasta>=desde') THROW 51004,N'CHECK incompatible: CTL.ReglaRiesgo.CK_EXUX_CTL_ReglaRiesgo_2',1;

-- CTL.ReglaSegregacion | ERD EXUX
IF OBJECT_ID(N'CTL.ReglaSegregacion',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [CTL].[ReglaSegregacion] (
 [IdReglaSegregacion] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [Codigo] nvarchar(40) NOT NULL,
 [AccionA] nvarchar(120) NOT NULL,
 [AccionB] nvarchar(120) NOT NULL,
 [Desde] date NOT NULL,
 [Hasta] date NULL,
 [Activo] bit NOT NULL DEFAULT 1,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_CTL_ReglaSegregacion_IdReglaSegregacion] PRIMARY KEY CLUSTERED ([IdReglaSegregacion] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdReglaSegregacion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Codigo","type":"nvarchar","length":80,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"AccionA","type":"nvarchar","length":240,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"AccionB","type":"nvarchar","length":240,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Desde","type":"date","length":3,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Hasta","type":"date","length":3,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Activo","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'CTL.ReglaSegregacion',N'U')
) THROW 51001,N'Estructura incompatible: CTL.ReglaSegregacion. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'CTL.ReglaSegregacion') AND c.name=N'Activo' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'1') THROW 51002,N'DEFAULT incompatible: CTL.ReglaSegregacion.Activo',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'CTL.ReglaSegregacion') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: CTL.ReglaSegregacion.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CTL.ReglaSegregacion') AND name=N'UX_CTL_ReglaSegregacion_IdReglaSegregacion' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CTL.ReglaSegregacion.UX_CTL_ReglaSegregacion_IdReglaSegregacion',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdReglaSegregacion","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CTL.ReglaSegregacion') AND i.name=N'UX_CTL_ReglaSegregacion_IdReglaSegregacion') THROW 51003,N'Columnas de índice incompatibles: CTL.ReglaSegregacion.UX_CTL_ReglaSegregacion_IdReglaSegregacion',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CTL.ReglaSegregacion') AND i.name=N'UX_CTL_ReglaSegregacion_IdReglaSegregacion')<>1 THROW 51003,N'Número de columnas de índice incompatible: CTL.ReglaSegregacion.UX_CTL_ReglaSegregacion_IdReglaSegregacion',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CTL.ReglaSegregacion') AND name=N'UX_CTL_ReglaSegregacion_IdEmpresa_Codigo')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_CTL_ReglaSegregacion_IdEmpresa_Codigo] ON [CTL].[ReglaSegregacion] ([IdEmpresa] ASC, [Codigo] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'CTL.ReglaSegregacion') AND name=N'UX_CTL_ReglaSegregacion_IdEmpresa_Codigo' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: CTL.ReglaSegregacion.UX_CTL_ReglaSegregacion_IdEmpresa_Codigo',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"Codigo","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'CTL.ReglaSegregacion') AND i.name=N'UX_CTL_ReglaSegregacion_IdEmpresa_Codigo') THROW 51003,N'Columnas de índice incompatibles: CTL.ReglaSegregacion.UX_CTL_ReglaSegregacion_IdEmpresa_Codigo',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'CTL.ReglaSegregacion') AND i.name=N'UX_CTL_ReglaSegregacion_IdEmpresa_Codigo')<>2 THROW 51003,N'Número de columnas de índice incompatible: CTL.ReglaSegregacion.UX_CTL_ReglaSegregacion_IdEmpresa_Codigo',1;
IF OBJECT_ID(N'CTL.CK_EXUX_CTL_ReglaSegregacion_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [CTL].[ReglaSegregacion] WITH CHECK ADD CONSTRAINT [CK_EXUX_CTL_ReglaSegregacion_1] CHECK (AccionA <> AccionB);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'CTL.ReglaSegregacion') AND name=N'CK_EXUX_CTL_ReglaSegregacion_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'acciona<>accionb') THROW 51004,N'CHECK incompatible: CTL.ReglaSegregacion.CK_EXUX_CTL_ReglaSegregacion_1',1;
IF OBJECT_ID(N'CTL.CK_EXUX_CTL_ReglaSegregacion_2',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [CTL].[ReglaSegregacion] WITH CHECK ADD CONSTRAINT [CK_EXUX_CTL_ReglaSegregacion_2] CHECK (Hasta IS NULL OR Hasta >= Desde);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'CTL.ReglaSegregacion') AND name=N'CK_EXUX_CTL_ReglaSegregacion_2' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'hastaisnullorhasta>=desde') THROW 51004,N'CHECK incompatible: CTL.ReglaSegregacion.CK_EXUX_CTL_ReglaSegregacion_2',1;

-- PBR.AuditoriaCambio | GestionEmpresarial.PBR.AuditoriaCambio
-- CAMBIO IdEmpresa: Nueva pertenencia obligatoria a empresa
IF OBJECT_ID(N'PBR.AuditoriaCambio',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [PBR].[AuditoriaCambio] (
 [PKIdAuditoria] int IDENTITY(1,1) NOT NULL,
 [Entidad] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [EntidadId] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Accion] nvarchar(20) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FKIdUsuario_PBR] int NULL,
 [Cambios] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [Ip] nvarchar(100) COLLATE Modern_Spanish_CI_AS NULL,
 [FechaCreacion] datetime2(7) NOT NULL DEFAULT (getdate()),
 [IdEmpresa] int NOT NULL,
 [IdOperacion] bigint NULL,
 CONSTRAINT [PK_PBR_AuditoriaCambio] PRIMARY KEY CLUSTERED ([PKIdAuditoria] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"PKIdAuditoria","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"Entidad","type":"nvarchar","length":400,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"EntidadId","type":"nvarchar","length":400,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Accion","type":"nvarchar","length":40,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FKIdUsuario_PBR","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Cambios","type":"nvarchar","length":-1,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Ip","type":"nvarchar","length":200,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"FechaCreacion","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdOperacion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":1,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'PBR.AuditoriaCambio',N'U')
) THROW 51001,N'Estructura incompatible: PBR.AuditoriaCambio. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'PBR.AuditoriaCambio') AND c.name=N'FechaCreacion' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'getdate') THROW 51002,N'DEFAULT incompatible: PBR.AuditoriaCambio.FechaCreacion',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'PBR.AuditoriaCambio') AND name=N'PK_PBR_AuditoriaCambio' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: PBR.AuditoriaCambio.PK_PBR_AuditoriaCambio',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"PKIdAuditoria","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'PBR.AuditoriaCambio') AND i.name=N'PK_PBR_AuditoriaCambio') THROW 51003,N'Columnas de índice incompatibles: PBR.AuditoriaCambio.PK_PBR_AuditoriaCambio',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'PBR.AuditoriaCambio') AND i.name=N'PK_PBR_AuditoriaCambio')<>1 THROW 51003,N'Número de columnas de índice incompatible: PBR.AuditoriaCambio.PK_PBR_AuditoriaCambio',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'PBR.AuditoriaCambio') AND name=N'IX_PBR_AuditoriaCambio_IdEmpresa_IdOperacion_FechaCreacion')
EXEC sys.sp_executesql N'CREATE NONCLUSTERED INDEX [IX_PBR_AuditoriaCambio_IdEmpresa_IdOperacion_FechaCreacion] ON [PBR].[AuditoriaCambio] ([IdEmpresa] ASC, [IdOperacion] ASC, [FechaCreacion] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'PBR.AuditoriaCambio') AND name=N'IX_PBR_AuditoriaCambio_IdEmpresa_IdOperacion_FechaCreacion' AND is_unique=0 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: PBR.AuditoriaCambio.IX_PBR_AuditoriaCambio_IdEmpresa_IdOperacion_FechaCreacion',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"IdOperacion","ordinal":2,"descending":0,"included":0},{"name":"FechaCreacion","ordinal":3,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'PBR.AuditoriaCambio') AND i.name=N'IX_PBR_AuditoriaCambio_IdEmpresa_IdOperacion_FechaCreacion') THROW 51003,N'Columnas de índice incompatibles: PBR.AuditoriaCambio.IX_PBR_AuditoriaCambio_IdEmpresa_IdOperacion_FechaCreacion',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'PBR.AuditoriaCambio') AND i.name=N'IX_PBR_AuditoriaCambio_IdEmpresa_IdOperacion_FechaCreacion')<>3 THROW 51003,N'Número de columnas de índice incompatible: PBR.AuditoriaCambio.IX_PBR_AuditoriaCambio_IdEmpresa_IdOperacion_FechaCreacion',1;
COMMIT TRANSACTION;
END TRY
BEGIN CATCH
 IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;
PRINT N'FASE A completa: Control_Auditoria. Relaciones pendientes en 02_Relaciones.sql.';
