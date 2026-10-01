/*
EXUX | Universidad Maya | Propuesta de reestructura SQL Server 2022
MÓDULO 12: Fiscal
Generado a partir de metadatos: EmptyProjects (26 tablas) y GestionEmpresarial (309 tablas).
SOLO ARCHIVO GENERADO. NO APLICADO. SIN DATOS, SIN USUARIOS, SIN CREDENCIALES.
FASE A: tablas, columnas, PK, índices y CHECK. No crea relaciones a otros módulos.
FASE B: ejecutar 02_Relaciones.sql después de todas las FASE A.
Dependencias para cerrar relaciones: 01 Base_Organizacion, 11 Cumplimiento, 14 Documentos.
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
IF SCHEMA_ID(N'FIS') IS NULL
EXEC sys.sp_executesql N'CREATE SCHEMA [FIS] AUTHORIZATION [dbo];';

-- FIS.ActualizacionRecargo | ERD EXUX
IF OBJECT_ID(N'FIS.ActualizacionRecargo',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [FIS].[ActualizacionRecargo] (
 [IdActualizacionRecargo] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdDeterminacion] bigint NOT NULL,
 [Periodo] nvarchar(30) NOT NULL,
 [ParametrosJson] nvarchar(max) NOT NULL,
 [Actualizacion] decimal(20,4) NOT NULL,
 [Recargo] decimal(20,4) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_ActualizacionRecargo_IdActualizacionRecargo] PRIMARY KEY CLUSTERED ([IdActualizacionRecargo] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdActualizacionRecargo","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdDeterminacion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Periodo","type":"nvarchar","length":60,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"ParametrosJson","type":"nvarchar","length":-1,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Actualizacion","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"Recargo","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'FIS.ActualizacionRecargo',N'U')
) THROW 51001,N'Estructura incompatible: FIS.ActualizacionRecargo. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'FIS.ActualizacionRecargo') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: FIS.ActualizacionRecargo.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.ActualizacionRecargo') AND name=N'UX_FIS_ActualizacionRecargo_IdActualizacionRecargo' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.ActualizacionRecargo.UX_FIS_ActualizacionRecargo_IdActualizacionRecargo',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdActualizacionRecargo","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.ActualizacionRecargo') AND i.name=N'UX_FIS_ActualizacionRecargo_IdActualizacionRecargo') THROW 51003,N'Columnas de índice incompatibles: FIS.ActualizacionRecargo.UX_FIS_ActualizacionRecargo_IdActualizacionRecargo',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.ActualizacionRecargo') AND i.name=N'UX_FIS_ActualizacionRecargo_IdActualizacionRecargo')<>1 THROW 51003,N'Número de columnas de índice incompatible: FIS.ActualizacionRecargo.UX_FIS_ActualizacionRecargo_IdActualizacionRecargo',1;
IF OBJECT_ID(N'FIS.CK_EXUX_FIS_ActualizacionRecargo_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [FIS].[ActualizacionRecargo] WITH CHECK ADD CONSTRAINT [CK_EXUX_FIS_ActualizacionRecargo_1] CHECK (ISJSON(ParametrosJson)=1 AND Actualizacion >= 0 AND Recargo >= 0);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'FIS.ActualizacionRecargo') AND name=N'CK_EXUX_FIS_ActualizacionRecargo_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'isjsonparametrosjson=1andactualizacion>=0andrecargo>=0') THROW 51004,N'CHECK incompatible: FIS.ActualizacionRecargo.CK_EXUX_FIS_ActualizacionRecargo_1',1;

-- FIS.AuditoriaFiscal | ERD EXUX
IF OBJECT_ID(N'FIS.AuditoriaFiscal',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [FIS].[AuditoriaFiscal] (
 [IdAuditoriaFiscal] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [Autoridad] nvarchar(200) NOT NULL,
 [Periodo] nvarchar(100) NOT NULL,
 [Expediente] nvarchar(100) NOT NULL,
 [FechaInicio] date NOT NULL,
 [FechaFin] date NULL,
 [Estado] varchar(20) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_AuditoriaFiscal_IdAuditoriaFiscal] PRIMARY KEY CLUSTERED ([IdAuditoriaFiscal] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdAuditoriaFiscal","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Autoridad","type":"nvarchar","length":400,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Periodo","type":"nvarchar","length":200,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Expediente","type":"nvarchar","length":200,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FechaInicio","type":"date","length":3,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FechaFin","type":"date","length":3,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Estado","type":"varchar","length":20,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'FIS.AuditoriaFiscal',N'U')
) THROW 51001,N'Estructura incompatible: FIS.AuditoriaFiscal. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'FIS.AuditoriaFiscal') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: FIS.AuditoriaFiscal.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.AuditoriaFiscal') AND name=N'UX_FIS_AuditoriaFiscal_IdAuditoriaFiscal' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.AuditoriaFiscal.UX_FIS_AuditoriaFiscal_IdAuditoriaFiscal',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdAuditoriaFiscal","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.AuditoriaFiscal') AND i.name=N'UX_FIS_AuditoriaFiscal_IdAuditoriaFiscal') THROW 51003,N'Columnas de índice incompatibles: FIS.AuditoriaFiscal.UX_FIS_AuditoriaFiscal_IdAuditoriaFiscal',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.AuditoriaFiscal') AND i.name=N'UX_FIS_AuditoriaFiscal_IdAuditoriaFiscal')<>1 THROW 51003,N'Número de columnas de índice incompatible: FIS.AuditoriaFiscal.UX_FIS_AuditoriaFiscal_IdAuditoriaFiscal',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.AuditoriaFiscal') AND name=N'UX_FIS_AuditoriaFiscal_IdEmpresa_Autoridad_Expediente')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_AuditoriaFiscal_IdEmpresa_Autoridad_Expediente] ON [FIS].[AuditoriaFiscal] ([IdEmpresa] ASC, [Autoridad] ASC, [Expediente] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.AuditoriaFiscal') AND name=N'UX_FIS_AuditoriaFiscal_IdEmpresa_Autoridad_Expediente' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.AuditoriaFiscal.UX_FIS_AuditoriaFiscal_IdEmpresa_Autoridad_Expediente',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"Autoridad","ordinal":2,"descending":0,"included":0},{"name":"Expediente","ordinal":3,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.AuditoriaFiscal') AND i.name=N'UX_FIS_AuditoriaFiscal_IdEmpresa_Autoridad_Expediente') THROW 51003,N'Columnas de índice incompatibles: FIS.AuditoriaFiscal.UX_FIS_AuditoriaFiscal_IdEmpresa_Autoridad_Expediente',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.AuditoriaFiscal') AND i.name=N'UX_FIS_AuditoriaFiscal_IdEmpresa_Autoridad_Expediente')<>3 THROW 51003,N'Número de columnas de índice incompatible: FIS.AuditoriaFiscal.UX_FIS_AuditoriaFiscal_IdEmpresa_Autoridad_Expediente',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.AuditoriaFiscal') AND name=N'UX_FIS_AuditoriaFiscal_IdEmpresa_IdAuditoriaFiscal')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_AuditoriaFiscal_IdEmpresa_IdAuditoriaFiscal] ON [FIS].[AuditoriaFiscal] ([IdEmpresa] ASC, [IdAuditoriaFiscal] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.AuditoriaFiscal') AND name=N'UX_FIS_AuditoriaFiscal_IdEmpresa_IdAuditoriaFiscal' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.AuditoriaFiscal.UX_FIS_AuditoriaFiscal_IdEmpresa_IdAuditoriaFiscal',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"IdAuditoriaFiscal","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.AuditoriaFiscal') AND i.name=N'UX_FIS_AuditoriaFiscal_IdEmpresa_IdAuditoriaFiscal') THROW 51003,N'Columnas de índice incompatibles: FIS.AuditoriaFiscal.UX_FIS_AuditoriaFiscal_IdEmpresa_IdAuditoriaFiscal',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.AuditoriaFiscal') AND i.name=N'UX_FIS_AuditoriaFiscal_IdEmpresa_IdAuditoriaFiscal')<>2 THROW 51003,N'Número de columnas de índice incompatible: FIS.AuditoriaFiscal.UX_FIS_AuditoriaFiscal_IdEmpresa_IdAuditoriaFiscal',1;
IF OBJECT_ID(N'FIS.CK_EXUX_FIS_AuditoriaFiscal_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [FIS].[AuditoriaFiscal] WITH CHECK ADD CONSTRAINT [CK_EXUX_FIS_AuditoriaFiscal_1] CHECK (FechaFin IS NULL OR FechaFin >= FechaInicio);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'FIS.AuditoriaFiscal') AND name=N'CK_EXUX_FIS_AuditoriaFiscal_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'fechafinisnullorfechafin>=fechainicio') THROW 51004,N'CHECK incompatible: FIS.AuditoriaFiscal.CK_EXUX_FIS_AuditoriaFiscal_1',1;

-- FIS.Cfdi | ERD EXUX
IF OBJECT_ID(N'FIS.Cfdi',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [FIS].[Cfdi] (
 [IdCfdi] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [UUID] uniqueidentifier NOT NULL,
 [Tipo] char(1) NOT NULL,
 [RFCEmisor] varchar(13) NOT NULL,
 [RFCReceptor] varchar(13) NOT NULL,
 [FechaEmision] datetime2(7) NOT NULL,
 [IdMoneda] int NOT NULL,
 [Subtotal] decimal(20,4) NOT NULL,
 [Total] decimal(20,4) NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [IdDocumentoXml] bigint NOT NULL,
 [IdDocumentoPdf] bigint NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_Cfdi_IdCfdi] PRIMARY KEY CLUSTERED ([IdCfdi] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdCfdi","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"UUID","type":"uniqueidentifier","length":16,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Tipo","type":"char","length":1,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"RFCEmisor","type":"varchar","length":13,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"RFCReceptor","type":"varchar","length":13,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FechaEmision","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"IdMoneda","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Subtotal","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"Total","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"Estado","type":"varchar","length":20,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdDocumentoXml","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdDocumentoPdf","type":"bigint","length":8,"precision":19,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'FIS.Cfdi',N'U')
) THROW 51001,N'Estructura incompatible: FIS.Cfdi. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'FIS.Cfdi') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: FIS.Cfdi.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.Cfdi') AND name=N'UX_FIS_Cfdi_IdCfdi' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.Cfdi.UX_FIS_Cfdi_IdCfdi',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdCfdi","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.Cfdi') AND i.name=N'UX_FIS_Cfdi_IdCfdi') THROW 51003,N'Columnas de índice incompatibles: FIS.Cfdi.UX_FIS_Cfdi_IdCfdi',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.Cfdi') AND i.name=N'UX_FIS_Cfdi_IdCfdi')<>1 THROW 51003,N'Número de columnas de índice incompatible: FIS.Cfdi.UX_FIS_Cfdi_IdCfdi',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.Cfdi') AND name=N'UX_FIS_Cfdi_IdEmpresa_UUID')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_Cfdi_IdEmpresa_UUID] ON [FIS].[Cfdi] ([IdEmpresa] ASC, [UUID] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.Cfdi') AND name=N'UX_FIS_Cfdi_IdEmpresa_UUID' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.Cfdi.UX_FIS_Cfdi_IdEmpresa_UUID',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"UUID","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.Cfdi') AND i.name=N'UX_FIS_Cfdi_IdEmpresa_UUID') THROW 51003,N'Columnas de índice incompatibles: FIS.Cfdi.UX_FIS_Cfdi_IdEmpresa_UUID',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.Cfdi') AND i.name=N'UX_FIS_Cfdi_IdEmpresa_UUID')<>2 THROW 51003,N'Número de columnas de índice incompatible: FIS.Cfdi.UX_FIS_Cfdi_IdEmpresa_UUID',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.Cfdi') AND name=N'UX_FIS_Cfdi_IdEmpresa_IdCfdi')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_Cfdi_IdEmpresa_IdCfdi] ON [FIS].[Cfdi] ([IdEmpresa] ASC, [IdCfdi] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.Cfdi') AND name=N'UX_FIS_Cfdi_IdEmpresa_IdCfdi' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.Cfdi.UX_FIS_Cfdi_IdEmpresa_IdCfdi',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"IdCfdi","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.Cfdi') AND i.name=N'UX_FIS_Cfdi_IdEmpresa_IdCfdi') THROW 51003,N'Columnas de índice incompatibles: FIS.Cfdi.UX_FIS_Cfdi_IdEmpresa_IdCfdi',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.Cfdi') AND i.name=N'UX_FIS_Cfdi_IdEmpresa_IdCfdi')<>2 THROW 51003,N'Número de columnas de índice incompatible: FIS.Cfdi.UX_FIS_Cfdi_IdEmpresa_IdCfdi',1;
IF OBJECT_ID(N'FIS.CK_EXUX_FIS_Cfdi_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [FIS].[Cfdi] WITH CHECK ADD CONSTRAINT [CK_EXUX_FIS_Cfdi_1] CHECK (Tipo IN (''I'',''E'',''T'',''N'',''P''));';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'FIS.Cfdi') AND name=N'CK_EXUX_FIS_Cfdi_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'tipoin''i'',''e'',''t'',''n'',''p''') THROW 51004,N'CHECK incompatible: FIS.Cfdi.CK_EXUX_FIS_Cfdi_1',1;
IF OBJECT_ID(N'FIS.CK_EXUX_FIS_Cfdi_2',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [FIS].[Cfdi] WITH CHECK ADD CONSTRAINT [CK_EXUX_FIS_Cfdi_2] CHECK (Total >= 0);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'FIS.Cfdi') AND name=N'CK_EXUX_FIS_Cfdi_2' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'total>=0') THROW 51004,N'CHECK incompatible: FIS.Cfdi.CK_EXUX_FIS_Cfdi_2',1;

-- FIS.CfdiConcepto | ERD EXUX
IF OBJECT_ID(N'FIS.CfdiConcepto',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [FIS].[CfdiConcepto] (
 [IdCfdiConcepto] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdCfdi] bigint NOT NULL,
 [Renglon] int NOT NULL,
 [ClaveProductoServicio] varchar(12) NOT NULL,
 [ClaveUnidad] varchar(10) NOT NULL,
 [Descripcion] nvarchar(1000) NOT NULL,
 [Cantidad] decimal(20,4) NOT NULL,
 [ValorUnitario] decimal(20,4) NOT NULL,
 [Importe] decimal(20,4) NOT NULL,
 [Descuento] decimal(20,4) NOT NULL DEFAULT 0,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_CfdiConcepto_IdCfdiConcepto] PRIMARY KEY CLUSTERED ([IdCfdiConcepto] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdCfdiConcepto","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdCfdi","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Renglon","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"ClaveProductoServicio","type":"varchar","length":12,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"ClaveUnidad","type":"varchar","length":10,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Descripcion","type":"nvarchar","length":2000,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Cantidad","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"ValorUnitario","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"Importe","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"Descuento","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'FIS.CfdiConcepto',N'U')
) THROW 51001,N'Estructura incompatible: FIS.CfdiConcepto. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'FIS.CfdiConcepto') AND c.name=N'Descuento' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'0') THROW 51002,N'DEFAULT incompatible: FIS.CfdiConcepto.Descuento',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'FIS.CfdiConcepto') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: FIS.CfdiConcepto.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.CfdiConcepto') AND name=N'UX_FIS_CfdiConcepto_IdCfdiConcepto' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.CfdiConcepto.UX_FIS_CfdiConcepto_IdCfdiConcepto',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdCfdiConcepto","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.CfdiConcepto') AND i.name=N'UX_FIS_CfdiConcepto_IdCfdiConcepto') THROW 51003,N'Columnas de índice incompatibles: FIS.CfdiConcepto.UX_FIS_CfdiConcepto_IdCfdiConcepto',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.CfdiConcepto') AND i.name=N'UX_FIS_CfdiConcepto_IdCfdiConcepto')<>1 THROW 51003,N'Número de columnas de índice incompatible: FIS.CfdiConcepto.UX_FIS_CfdiConcepto_IdCfdiConcepto',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.CfdiConcepto') AND name=N'UX_FIS_CfdiConcepto_IdCfdi_Renglon')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_CfdiConcepto_IdCfdi_Renglon] ON [FIS].[CfdiConcepto] ([IdCfdi] ASC, [Renglon] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.CfdiConcepto') AND name=N'UX_FIS_CfdiConcepto_IdCfdi_Renglon' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.CfdiConcepto.UX_FIS_CfdiConcepto_IdCfdi_Renglon',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdCfdi","ordinal":1,"descending":0,"included":0},{"name":"Renglon","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.CfdiConcepto') AND i.name=N'UX_FIS_CfdiConcepto_IdCfdi_Renglon') THROW 51003,N'Columnas de índice incompatibles: FIS.CfdiConcepto.UX_FIS_CfdiConcepto_IdCfdi_Renglon',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.CfdiConcepto') AND i.name=N'UX_FIS_CfdiConcepto_IdCfdi_Renglon')<>2 THROW 51003,N'Número de columnas de índice incompatible: FIS.CfdiConcepto.UX_FIS_CfdiConcepto_IdCfdi_Renglon',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.CfdiConcepto') AND name=N'UX_FIS_CfdiConcepto_IdEmpresa_IdCfdiConcepto')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_CfdiConcepto_IdEmpresa_IdCfdiConcepto] ON [FIS].[CfdiConcepto] ([IdEmpresa] ASC, [IdCfdiConcepto] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.CfdiConcepto') AND name=N'UX_FIS_CfdiConcepto_IdEmpresa_IdCfdiConcepto' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.CfdiConcepto.UX_FIS_CfdiConcepto_IdEmpresa_IdCfdiConcepto',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"IdCfdiConcepto","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.CfdiConcepto') AND i.name=N'UX_FIS_CfdiConcepto_IdEmpresa_IdCfdiConcepto') THROW 51003,N'Columnas de índice incompatibles: FIS.CfdiConcepto.UX_FIS_CfdiConcepto_IdEmpresa_IdCfdiConcepto',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.CfdiConcepto') AND i.name=N'UX_FIS_CfdiConcepto_IdEmpresa_IdCfdiConcepto')<>2 THROW 51003,N'Número de columnas de índice incompatible: FIS.CfdiConcepto.UX_FIS_CfdiConcepto_IdEmpresa_IdCfdiConcepto',1;
IF OBJECT_ID(N'FIS.CK_EXUX_FIS_CfdiConcepto_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [FIS].[CfdiConcepto] WITH CHECK ADD CONSTRAINT [CK_EXUX_FIS_CfdiConcepto_1] CHECK (Renglon > 0 AND Cantidad > 0 AND ValorUnitario >= 0 AND Importe >= 0 AND Descuento >= 0);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'FIS.CfdiConcepto') AND name=N'CK_EXUX_FIS_CfdiConcepto_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'renglon>0andcantidad>0andvalorunitario>=0andimporte>=0anddescuento>=0') THROW 51004,N'CHECK incompatible: FIS.CfdiConcepto.CK_EXUX_FIS_CfdiConcepto_1',1;

-- FIS.CfdiImpuesto | ERD EXUX
IF OBJECT_ID(N'FIS.CfdiImpuesto',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [FIS].[CfdiImpuesto] (
 [IdCfdiImpuesto] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdCfdiConcepto] bigint NOT NULL,
 [CodigoImpuesto] varchar(3) NOT NULL,
 [Tipo] varchar(12) NOT NULL,
 [TipoFactor] varchar(10) NOT NULL,
 [Base] decimal(20,4) NOT NULL,
 [TasaOCuota] decimal(18,6) NULL,
 [Importe] decimal(20,4) NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_CfdiImpuesto_IdCfdiImpuesto] PRIMARY KEY CLUSTERED ([IdCfdiImpuesto] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdCfdiImpuesto","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdCfdiConcepto","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CodigoImpuesto","type":"varchar","length":3,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Tipo","type":"varchar","length":12,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"TipoFactor","type":"varchar","length":10,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Base","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"TasaOCuota","type":"decimal","length":9,"precision":18,"scale":6,"nullable":1,"identity":0,"computed":0},{"name":"Importe","type":"decimal","length":13,"precision":20,"scale":4,"nullable":1,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'FIS.CfdiImpuesto',N'U')
) THROW 51001,N'Estructura incompatible: FIS.CfdiImpuesto. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'FIS.CfdiImpuesto') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: FIS.CfdiImpuesto.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.CfdiImpuesto') AND name=N'UX_FIS_CfdiImpuesto_IdCfdiImpuesto' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.CfdiImpuesto.UX_FIS_CfdiImpuesto_IdCfdiImpuesto',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdCfdiImpuesto","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.CfdiImpuesto') AND i.name=N'UX_FIS_CfdiImpuesto_IdCfdiImpuesto') THROW 51003,N'Columnas de índice incompatibles: FIS.CfdiImpuesto.UX_FIS_CfdiImpuesto_IdCfdiImpuesto',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.CfdiImpuesto') AND i.name=N'UX_FIS_CfdiImpuesto_IdCfdiImpuesto')<>1 THROW 51003,N'Número de columnas de índice incompatible: FIS.CfdiImpuesto.UX_FIS_CfdiImpuesto_IdCfdiImpuesto',1;
IF OBJECT_ID(N'FIS.CK_EXUX_FIS_CfdiImpuesto_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [FIS].[CfdiImpuesto] WITH CHECK ADD CONSTRAINT [CK_EXUX_FIS_CfdiImpuesto_1] CHECK (Tipo IN (''TRASLADO'',''RETENCION''));';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'FIS.CfdiImpuesto') AND name=N'CK_EXUX_FIS_CfdiImpuesto_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'tipoin''traslado'',''retencion''') THROW 51004,N'CHECK incompatible: FIS.CfdiImpuesto.CK_EXUX_FIS_CfdiImpuesto_1',1;
IF OBJECT_ID(N'FIS.CK_EXUX_FIS_CfdiImpuesto_2',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [FIS].[CfdiImpuesto] WITH CHECK ADD CONSTRAINT [CK_EXUX_FIS_CfdiImpuesto_2] CHECK (Base >= 0);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'FIS.CfdiImpuesto') AND name=N'CK_EXUX_FIS_CfdiImpuesto_2' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'base>=0') THROW 51004,N'CHECK incompatible: FIS.CfdiImpuesto.CK_EXUX_FIS_CfdiImpuesto_2',1;

-- FIS.ComprobanteGasto | ERD EXUX
IF OBJECT_ID(N'FIS.ComprobanteGasto',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [FIS].[ComprobanteGasto] (
 [IdComprobanteGasto] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdDocumento] bigint NOT NULL,
 [IdCfdi] bigint NULL,
 [Fecha] date NOT NULL,
 [IdMoneda] int NOT NULL,
 [Total] decimal(20,4) NOT NULL,
 [Concepto] nvarchar(500) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_ComprobanteGasto_IdComprobanteGasto] PRIMARY KEY CLUSTERED ([IdComprobanteGasto] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdComprobanteGasto","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdDocumento","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdCfdi","type":"bigint","length":8,"precision":19,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Fecha","type":"date","length":3,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdMoneda","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Total","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"Concepto","type":"nvarchar","length":1000,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'FIS.ComprobanteGasto',N'U')
) THROW 51001,N'Estructura incompatible: FIS.ComprobanteGasto. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'FIS.ComprobanteGasto') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: FIS.ComprobanteGasto.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.ComprobanteGasto') AND name=N'UX_FIS_ComprobanteGasto_IdComprobanteGasto' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.ComprobanteGasto.UX_FIS_ComprobanteGasto_IdComprobanteGasto',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdComprobanteGasto","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.ComprobanteGasto') AND i.name=N'UX_FIS_ComprobanteGasto_IdComprobanteGasto') THROW 51003,N'Columnas de índice incompatibles: FIS.ComprobanteGasto.UX_FIS_ComprobanteGasto_IdComprobanteGasto',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.ComprobanteGasto') AND i.name=N'UX_FIS_ComprobanteGasto_IdComprobanteGasto')<>1 THROW 51003,N'Número de columnas de índice incompatible: FIS.ComprobanteGasto.UX_FIS_ComprobanteGasto_IdComprobanteGasto',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.ComprobanteGasto') AND name=N'UX_FIS_ComprobanteGasto_IdDocumento')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_ComprobanteGasto_IdDocumento] ON [FIS].[ComprobanteGasto] ([IdDocumento] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.ComprobanteGasto') AND name=N'UX_FIS_ComprobanteGasto_IdDocumento' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.ComprobanteGasto.UX_FIS_ComprobanteGasto_IdDocumento',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdDocumento","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.ComprobanteGasto') AND i.name=N'UX_FIS_ComprobanteGasto_IdDocumento') THROW 51003,N'Columnas de índice incompatibles: FIS.ComprobanteGasto.UX_FIS_ComprobanteGasto_IdDocumento',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.ComprobanteGasto') AND i.name=N'UX_FIS_ComprobanteGasto_IdDocumento')<>1 THROW 51003,N'Número de columnas de índice incompatible: FIS.ComprobanteGasto.UX_FIS_ComprobanteGasto_IdDocumento',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.ComprobanteGasto') AND name=N'UX_FIS_ComprobanteGasto_IdCfdi')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_ComprobanteGasto_IdCfdi] ON [FIS].[ComprobanteGasto] ([IdCfdi] ASC) WHERE [IdCfdi] IS NOT NULL;';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.ComprobanteGasto') AND name=N'UX_FIS_ComprobanteGasto_IdCfdi' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'idcfdiisnotnull') THROW 51003,N'Índice incompatible: FIS.ComprobanteGasto.UX_FIS_ComprobanteGasto_IdCfdi',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdCfdi","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.ComprobanteGasto') AND i.name=N'UX_FIS_ComprobanteGasto_IdCfdi') THROW 51003,N'Columnas de índice incompatibles: FIS.ComprobanteGasto.UX_FIS_ComprobanteGasto_IdCfdi',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.ComprobanteGasto') AND i.name=N'UX_FIS_ComprobanteGasto_IdCfdi')<>1 THROW 51003,N'Número de columnas de índice incompatible: FIS.ComprobanteGasto.UX_FIS_ComprobanteGasto_IdCfdi',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.ComprobanteGasto') AND name=N'UX_FIS_ComprobanteGasto_IdEmpresa_IdComprobanteGasto')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_ComprobanteGasto_IdEmpresa_IdComprobanteGasto] ON [FIS].[ComprobanteGasto] ([IdEmpresa] ASC, [IdComprobanteGasto] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.ComprobanteGasto') AND name=N'UX_FIS_ComprobanteGasto_IdEmpresa_IdComprobanteGasto' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.ComprobanteGasto.UX_FIS_ComprobanteGasto_IdEmpresa_IdComprobanteGasto',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"IdComprobanteGasto","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.ComprobanteGasto') AND i.name=N'UX_FIS_ComprobanteGasto_IdEmpresa_IdComprobanteGasto') THROW 51003,N'Columnas de índice incompatibles: FIS.ComprobanteGasto.UX_FIS_ComprobanteGasto_IdEmpresa_IdComprobanteGasto',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.ComprobanteGasto') AND i.name=N'UX_FIS_ComprobanteGasto_IdEmpresa_IdComprobanteGasto')<>2 THROW 51003,N'Número de columnas de índice incompatible: FIS.ComprobanteGasto.UX_FIS_ComprobanteGasto_IdEmpresa_IdComprobanteGasto',1;
IF OBJECT_ID(N'FIS.CK_EXUX_FIS_ComprobanteGasto_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [FIS].[ComprobanteGasto] WITH CHECK ADD CONSTRAINT [CK_EXUX_FIS_ComprobanteGasto_1] CHECK (Total > 0);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'FIS.ComprobanteGasto') AND name=N'CK_EXUX_FIS_ComprobanteGasto_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'total>0') THROW 51004,N'CHECK incompatible: FIS.ComprobanteGasto.CK_EXUX_FIS_ComprobanteGasto_1',1;

-- FIS.Declaracion | ERD EXUX
IF OBJECT_ID(N'FIS.Declaracion',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [FIS].[Declaracion] (
 [IdDeclaracion] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdVencimiento] bigint NOT NULL,
 [Tipo] varchar(40) NOT NULL,
 [Ejercicio] smallint NOT NULL,
 [Periodo] nvarchar(30) NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_Declaracion_IdDeclaracion] PRIMARY KEY CLUSTERED ([IdDeclaracion] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdDeclaracion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdVencimiento","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Tipo","type":"varchar","length":40,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Ejercicio","type":"smallint","length":2,"precision":5,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Periodo","type":"nvarchar","length":60,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Estado","type":"varchar","length":20,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'FIS.Declaracion',N'U')
) THROW 51001,N'Estructura incompatible: FIS.Declaracion. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'FIS.Declaracion') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: FIS.Declaracion.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.Declaracion') AND name=N'UX_FIS_Declaracion_IdDeclaracion' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.Declaracion.UX_FIS_Declaracion_IdDeclaracion',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdDeclaracion","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.Declaracion') AND i.name=N'UX_FIS_Declaracion_IdDeclaracion') THROW 51003,N'Columnas de índice incompatibles: FIS.Declaracion.UX_FIS_Declaracion_IdDeclaracion',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.Declaracion') AND i.name=N'UX_FIS_Declaracion_IdDeclaracion')<>1 THROW 51003,N'Número de columnas de índice incompatible: FIS.Declaracion.UX_FIS_Declaracion_IdDeclaracion',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.Declaracion') AND name=N'UX_FIS_Declaracion_IdVencimiento_Tipo')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_Declaracion_IdVencimiento_Tipo] ON [FIS].[Declaracion] ([IdVencimiento] ASC, [Tipo] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.Declaracion') AND name=N'UX_FIS_Declaracion_IdVencimiento_Tipo' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.Declaracion.UX_FIS_Declaracion_IdVencimiento_Tipo',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdVencimiento","ordinal":1,"descending":0,"included":0},{"name":"Tipo","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.Declaracion') AND i.name=N'UX_FIS_Declaracion_IdVencimiento_Tipo') THROW 51003,N'Columnas de índice incompatibles: FIS.Declaracion.UX_FIS_Declaracion_IdVencimiento_Tipo',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.Declaracion') AND i.name=N'UX_FIS_Declaracion_IdVencimiento_Tipo')<>2 THROW 51003,N'Número de columnas de índice incompatible: FIS.Declaracion.UX_FIS_Declaracion_IdVencimiento_Tipo',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.Declaracion') AND name=N'UX_FIS_Declaracion_IdEmpresa_IdDeclaracion')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_Declaracion_IdEmpresa_IdDeclaracion] ON [FIS].[Declaracion] ([IdEmpresa] ASC, [IdDeclaracion] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.Declaracion') AND name=N'UX_FIS_Declaracion_IdEmpresa_IdDeclaracion' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.Declaracion.UX_FIS_Declaracion_IdEmpresa_IdDeclaracion',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"IdDeclaracion","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.Declaracion') AND i.name=N'UX_FIS_Declaracion_IdEmpresa_IdDeclaracion') THROW 51003,N'Columnas de índice incompatibles: FIS.Declaracion.UX_FIS_Declaracion_IdEmpresa_IdDeclaracion',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.Declaracion') AND i.name=N'UX_FIS_Declaracion_IdEmpresa_IdDeclaracion')<>2 THROW 51003,N'Número de columnas de índice incompatible: FIS.Declaracion.UX_FIS_Declaracion_IdEmpresa_IdDeclaracion',1;

-- FIS.DeclaracionCfdi | ERD EXUX
IF OBJECT_ID(N'FIS.DeclaracionCfdi',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [FIS].[DeclaracionCfdi] (
 [IdDeclaracionCfdi] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdDeclaracionVersion] bigint NOT NULL,
 [IdCfdi] bigint NOT NULL,
 [Importe] decimal(20,4) NOT NULL,
 [Criterio] nvarchar(500) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_DeclaracionCfdi_IdDeclaracionCfdi] PRIMARY KEY CLUSTERED ([IdDeclaracionCfdi] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdDeclaracionCfdi","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdDeclaracionVersion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdCfdi","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Importe","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"Criterio","type":"nvarchar","length":1000,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'FIS.DeclaracionCfdi',N'U')
) THROW 51001,N'Estructura incompatible: FIS.DeclaracionCfdi. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'FIS.DeclaracionCfdi') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: FIS.DeclaracionCfdi.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.DeclaracionCfdi') AND name=N'UX_FIS_DeclaracionCfdi_IdDeclaracionCfdi' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.DeclaracionCfdi.UX_FIS_DeclaracionCfdi_IdDeclaracionCfdi',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdDeclaracionCfdi","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.DeclaracionCfdi') AND i.name=N'UX_FIS_DeclaracionCfdi_IdDeclaracionCfdi') THROW 51003,N'Columnas de índice incompatibles: FIS.DeclaracionCfdi.UX_FIS_DeclaracionCfdi_IdDeclaracionCfdi',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.DeclaracionCfdi') AND i.name=N'UX_FIS_DeclaracionCfdi_IdDeclaracionCfdi')<>1 THROW 51003,N'Número de columnas de índice incompatible: FIS.DeclaracionCfdi.UX_FIS_DeclaracionCfdi_IdDeclaracionCfdi',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.DeclaracionCfdi') AND name=N'UX_FIS_DeclaracionCfdi_IdDeclaracionVersion_IdCfdi')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_DeclaracionCfdi_IdDeclaracionVersion_IdCfdi] ON [FIS].[DeclaracionCfdi] ([IdDeclaracionVersion] ASC, [IdCfdi] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.DeclaracionCfdi') AND name=N'UX_FIS_DeclaracionCfdi_IdDeclaracionVersion_IdCfdi' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.DeclaracionCfdi.UX_FIS_DeclaracionCfdi_IdDeclaracionVersion_IdCfdi',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdDeclaracionVersion","ordinal":1,"descending":0,"included":0},{"name":"IdCfdi","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.DeclaracionCfdi') AND i.name=N'UX_FIS_DeclaracionCfdi_IdDeclaracionVersion_IdCfdi') THROW 51003,N'Columnas de índice incompatibles: FIS.DeclaracionCfdi.UX_FIS_DeclaracionCfdi_IdDeclaracionVersion_IdCfdi',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.DeclaracionCfdi') AND i.name=N'UX_FIS_DeclaracionCfdi_IdDeclaracionVersion_IdCfdi')<>2 THROW 51003,N'Número de columnas de índice incompatible: FIS.DeclaracionCfdi.UX_FIS_DeclaracionCfdi_IdDeclaracionVersion_IdCfdi',1;

-- FIS.DeclaracionVersion | ERD EXUX
IF OBJECT_ID(N'FIS.DeclaracionVersion',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [FIS].[DeclaracionVersion] (
 [IdDeclaracionVersion] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdDeclaracion] bigint NOT NULL,
 [Version] int NOT NULL,
 [Complementaria] bit NOT NULL DEFAULT 0,
 [Fecha] datetime2(7) NOT NULL,
 [IdDocumentoAcuse] bigint NULL,
 [IdUsuarioValidacion] int NULL,
 [ValidadaUtc] datetime2(7) NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_DeclaracionVersion_IdDeclaracionVersion] PRIMARY KEY CLUSTERED ([IdDeclaracionVersion] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdDeclaracionVersion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdDeclaracion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Version","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Complementaria","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Fecha","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"IdDocumentoAcuse","type":"bigint","length":8,"precision":19,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"IdUsuarioValidacion","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"ValidadaUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":1,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'FIS.DeclaracionVersion',N'U')
) THROW 51001,N'Estructura incompatible: FIS.DeclaracionVersion. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'FIS.DeclaracionVersion') AND c.name=N'Complementaria' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'0') THROW 51002,N'DEFAULT incompatible: FIS.DeclaracionVersion.Complementaria',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'FIS.DeclaracionVersion') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: FIS.DeclaracionVersion.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.DeclaracionVersion') AND name=N'UX_FIS_DeclaracionVersion_IdDeclaracionVersion' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.DeclaracionVersion.UX_FIS_DeclaracionVersion_IdDeclaracionVersion',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdDeclaracionVersion","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.DeclaracionVersion') AND i.name=N'UX_FIS_DeclaracionVersion_IdDeclaracionVersion') THROW 51003,N'Columnas de índice incompatibles: FIS.DeclaracionVersion.UX_FIS_DeclaracionVersion_IdDeclaracionVersion',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.DeclaracionVersion') AND i.name=N'UX_FIS_DeclaracionVersion_IdDeclaracionVersion')<>1 THROW 51003,N'Número de columnas de índice incompatible: FIS.DeclaracionVersion.UX_FIS_DeclaracionVersion_IdDeclaracionVersion',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.DeclaracionVersion') AND name=N'UX_FIS_DeclaracionVersion_IdDeclaracion_Version')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_DeclaracionVersion_IdDeclaracion_Version] ON [FIS].[DeclaracionVersion] ([IdDeclaracion] ASC, [Version] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.DeclaracionVersion') AND name=N'UX_FIS_DeclaracionVersion_IdDeclaracion_Version' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.DeclaracionVersion.UX_FIS_DeclaracionVersion_IdDeclaracion_Version',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdDeclaracion","ordinal":1,"descending":0,"included":0},{"name":"Version","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.DeclaracionVersion') AND i.name=N'UX_FIS_DeclaracionVersion_IdDeclaracion_Version') THROW 51003,N'Columnas de índice incompatibles: FIS.DeclaracionVersion.UX_FIS_DeclaracionVersion_IdDeclaracion_Version',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.DeclaracionVersion') AND i.name=N'UX_FIS_DeclaracionVersion_IdDeclaracion_Version')<>2 THROW 51003,N'Número de columnas de índice incompatible: FIS.DeclaracionVersion.UX_FIS_DeclaracionVersion_IdDeclaracion_Version',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.DeclaracionVersion') AND name=N'UX_FIS_DeclaracionVersion_IdEmpresa_IdDeclaracionVersion')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_DeclaracionVersion_IdEmpresa_IdDeclaracionVersion] ON [FIS].[DeclaracionVersion] ([IdEmpresa] ASC, [IdDeclaracionVersion] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.DeclaracionVersion') AND name=N'UX_FIS_DeclaracionVersion_IdEmpresa_IdDeclaracionVersion' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.DeclaracionVersion.UX_FIS_DeclaracionVersion_IdEmpresa_IdDeclaracionVersion',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"IdDeclaracionVersion","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.DeclaracionVersion') AND i.name=N'UX_FIS_DeclaracionVersion_IdEmpresa_IdDeclaracionVersion') THROW 51003,N'Columnas de índice incompatibles: FIS.DeclaracionVersion.UX_FIS_DeclaracionVersion_IdEmpresa_IdDeclaracionVersion',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.DeclaracionVersion') AND i.name=N'UX_FIS_DeclaracionVersion_IdEmpresa_IdDeclaracionVersion')<>2 THROW 51003,N'Número de columnas de índice incompatible: FIS.DeclaracionVersion.UX_FIS_DeclaracionVersion_IdEmpresa_IdDeclaracionVersion',1;
IF OBJECT_ID(N'FIS.CK_EXUX_FIS_DeclaracionVersion_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [FIS].[DeclaracionVersion] WITH CHECK ADD CONSTRAINT [CK_EXUX_FIS_DeclaracionVersion_1] CHECK (Version > 0);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'FIS.DeclaracionVersion') AND name=N'CK_EXUX_FIS_DeclaracionVersion_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'version>0') THROW 51004,N'CHECK incompatible: FIS.DeclaracionVersion.CK_EXUX_FIS_DeclaracionVersion_1',1;

-- FIS.DeterminacionImpuesto | ERD EXUX
IF OBJECT_ID(N'FIS.DeterminacionImpuesto',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [FIS].[DeterminacionImpuesto] (
 [IdDeterminacionImpuesto] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdDeclaracionVersion] bigint NOT NULL,
 [IdReglaFiscalVersion] bigint NOT NULL,
 [Base] decimal(20,4) NOT NULL,
 [ImporteImpuesto] decimal(20,4) NOT NULL,
 [ResultadoJson] nvarchar(max) NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_DeterminacionImpuesto_IdDeterminacionImpuesto] PRIMARY KEY CLUSTERED ([IdDeterminacionImpuesto] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdDeterminacionImpuesto","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdDeclaracionVersion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdReglaFiscalVersion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Base","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"ImporteImpuesto","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"ResultadoJson","type":"nvarchar","length":-1,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'FIS.DeterminacionImpuesto',N'U')
) THROW 51001,N'Estructura incompatible: FIS.DeterminacionImpuesto. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'FIS.DeterminacionImpuesto') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: FIS.DeterminacionImpuesto.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.DeterminacionImpuesto') AND name=N'UX_FIS_DeterminacionImpuesto_IdDeterminacionImpuesto' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.DeterminacionImpuesto.UX_FIS_DeterminacionImpuesto_IdDeterminacionImpuesto',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdDeterminacionImpuesto","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.DeterminacionImpuesto') AND i.name=N'UX_FIS_DeterminacionImpuesto_IdDeterminacionImpuesto') THROW 51003,N'Columnas de índice incompatibles: FIS.DeterminacionImpuesto.UX_FIS_DeterminacionImpuesto_IdDeterminacionImpuesto',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.DeterminacionImpuesto') AND i.name=N'UX_FIS_DeterminacionImpuesto_IdDeterminacionImpuesto')<>1 THROW 51003,N'Número de columnas de índice incompatible: FIS.DeterminacionImpuesto.UX_FIS_DeterminacionImpuesto_IdDeterminacionImpuesto',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.DeterminacionImpuesto') AND name=N'UX_FIS_DeterminacionImpuesto_IdDeclaracionVersion_IdReglaFiscalVersion')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_DeterminacionImpuesto_IdDeclaracionVersion_IdReglaFiscalVersion] ON [FIS].[DeterminacionImpuesto] ([IdDeclaracionVersion] ASC, [IdReglaFiscalVersion] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.DeterminacionImpuesto') AND name=N'UX_FIS_DeterminacionImpuesto_IdDeclaracionVersion_IdReglaFiscalVersion' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.DeterminacionImpuesto.UX_FIS_DeterminacionImpuesto_IdDeclaracionVersion_IdReglaFiscalVersion',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdDeclaracionVersion","ordinal":1,"descending":0,"included":0},{"name":"IdReglaFiscalVersion","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.DeterminacionImpuesto') AND i.name=N'UX_FIS_DeterminacionImpuesto_IdDeclaracionVersion_IdReglaFiscalVersion') THROW 51003,N'Columnas de índice incompatibles: FIS.DeterminacionImpuesto.UX_FIS_DeterminacionImpuesto_IdDeclaracionVersion_IdReglaFiscalVersion',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.DeterminacionImpuesto') AND i.name=N'UX_FIS_DeterminacionImpuesto_IdDeclaracionVersion_IdReglaFiscalVersion')<>2 THROW 51003,N'Número de columnas de índice incompatible: FIS.DeterminacionImpuesto.UX_FIS_DeterminacionImpuesto_IdDeclaracionVersion_IdReglaFiscalVersion',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.DeterminacionImpuesto') AND name=N'UX_FIS_DeterminacionImpuesto_IdEmpresa_IdDeterminacionImpuesto')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_DeterminacionImpuesto_IdEmpresa_IdDeterminacionImpuesto] ON [FIS].[DeterminacionImpuesto] ([IdEmpresa] ASC, [IdDeterminacionImpuesto] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.DeterminacionImpuesto') AND name=N'UX_FIS_DeterminacionImpuesto_IdEmpresa_IdDeterminacionImpuesto' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.DeterminacionImpuesto.UX_FIS_DeterminacionImpuesto_IdEmpresa_IdDeterminacionImpuesto',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"IdDeterminacionImpuesto","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.DeterminacionImpuesto') AND i.name=N'UX_FIS_DeterminacionImpuesto_IdEmpresa_IdDeterminacionImpuesto') THROW 51003,N'Columnas de índice incompatibles: FIS.DeterminacionImpuesto.UX_FIS_DeterminacionImpuesto_IdEmpresa_IdDeterminacionImpuesto',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.DeterminacionImpuesto') AND i.name=N'UX_FIS_DeterminacionImpuesto_IdEmpresa_IdDeterminacionImpuesto')<>2 THROW 51003,N'Número de columnas de índice incompatible: FIS.DeterminacionImpuesto.UX_FIS_DeterminacionImpuesto_IdEmpresa_IdDeterminacionImpuesto',1;
IF OBJECT_ID(N'FIS.CK_EXUX_FIS_DeterminacionImpuesto_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [FIS].[DeterminacionImpuesto] WITH CHECK ADD CONSTRAINT [CK_EXUX_FIS_DeterminacionImpuesto_1] CHECK (ResultadoJson IS NULL OR ISJSON(ResultadoJson)=1);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'FIS.DeterminacionImpuesto') AND name=N'CK_EXUX_FIS_DeterminacionImpuesto_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'resultadojsonisnullorisjsonresultadojson=1') THROW 51004,N'CHECK incompatible: FIS.DeterminacionImpuesto.CK_EXUX_FIS_DeterminacionImpuesto_1',1;

-- FIS.EventoCfdi | ERD EXUX
IF OBJECT_ID(N'FIS.EventoCfdi',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [FIS].[EventoCfdi] (
 [IdEventoCfdi] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdCfdi] bigint NOT NULL,
 [Tipo] varchar(30) NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [IdDocumentoAcuse] bigint NULL,
 [ClaveOperacion] uniqueidentifier NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_EventoCfdi_IdEventoCfdi] PRIMARY KEY CLUSTERED ([IdEventoCfdi] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdEventoCfdi","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdCfdi","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Tipo","type":"varchar","length":30,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Fecha","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"IdDocumentoAcuse","type":"bigint","length":8,"precision":19,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"ClaveOperacion","type":"uniqueidentifier","length":16,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'FIS.EventoCfdi',N'U')
) THROW 51001,N'Estructura incompatible: FIS.EventoCfdi. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'FIS.EventoCfdi') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: FIS.EventoCfdi.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.EventoCfdi') AND name=N'UX_FIS_EventoCfdi_IdEventoCfdi' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.EventoCfdi.UX_FIS_EventoCfdi_IdEventoCfdi',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEventoCfdi","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.EventoCfdi') AND i.name=N'UX_FIS_EventoCfdi_IdEventoCfdi') THROW 51003,N'Columnas de índice incompatibles: FIS.EventoCfdi.UX_FIS_EventoCfdi_IdEventoCfdi',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.EventoCfdi') AND i.name=N'UX_FIS_EventoCfdi_IdEventoCfdi')<>1 THROW 51003,N'Número de columnas de índice incompatible: FIS.EventoCfdi.UX_FIS_EventoCfdi_IdEventoCfdi',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.EventoCfdi') AND name=N'UX_FIS_EventoCfdi_IdEmpresa_ClaveOperacion')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_EventoCfdi_IdEmpresa_ClaveOperacion] ON [FIS].[EventoCfdi] ([IdEmpresa] ASC, [ClaveOperacion] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.EventoCfdi') AND name=N'UX_FIS_EventoCfdi_IdEmpresa_ClaveOperacion' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.EventoCfdi.UX_FIS_EventoCfdi_IdEmpresa_ClaveOperacion',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"ClaveOperacion","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.EventoCfdi') AND i.name=N'UX_FIS_EventoCfdi_IdEmpresa_ClaveOperacion') THROW 51003,N'Columnas de índice incompatibles: FIS.EventoCfdi.UX_FIS_EventoCfdi_IdEmpresa_ClaveOperacion',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.EventoCfdi') AND i.name=N'UX_FIS_EventoCfdi_IdEmpresa_ClaveOperacion')<>2 THROW 51003,N'Número de columnas de índice incompatible: FIS.EventoCfdi.UX_FIS_EventoCfdi_IdEmpresa_ClaveOperacion',1;

-- FIS.ObservacionFiscal | ERD EXUX
IF OBJECT_ID(N'FIS.ObservacionFiscal',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [FIS].[ObservacionFiscal] (
 [IdObservacionFiscal] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdAuditoria] bigint NOT NULL,
 [Descripcion] nvarchar(1500) NOT NULL,
 [Vencimiento] date NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [IdDocumentoEvidencia] bigint NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_ObservacionFiscal_IdObservacionFiscal] PRIMARY KEY CLUSTERED ([IdObservacionFiscal] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdObservacionFiscal","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdAuditoria","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Descripcion","type":"nvarchar","length":3000,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Vencimiento","type":"date","length":3,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Estado","type":"varchar","length":20,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdDocumentoEvidencia","type":"bigint","length":8,"precision":19,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'FIS.ObservacionFiscal',N'U')
) THROW 51001,N'Estructura incompatible: FIS.ObservacionFiscal. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'FIS.ObservacionFiscal') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: FIS.ObservacionFiscal.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.ObservacionFiscal') AND name=N'UX_FIS_ObservacionFiscal_IdObservacionFiscal' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.ObservacionFiscal.UX_FIS_ObservacionFiscal_IdObservacionFiscal',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdObservacionFiscal","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.ObservacionFiscal') AND i.name=N'UX_FIS_ObservacionFiscal_IdObservacionFiscal') THROW 51003,N'Columnas de índice incompatibles: FIS.ObservacionFiscal.UX_FIS_ObservacionFiscal_IdObservacionFiscal',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.ObservacionFiscal') AND i.name=N'UX_FIS_ObservacionFiscal_IdObservacionFiscal')<>1 THROW 51003,N'Número de columnas de índice incompatible: FIS.ObservacionFiscal.UX_FIS_ObservacionFiscal_IdObservacionFiscal',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.ObservacionFiscal') AND name=N'UX_FIS_ObservacionFiscal_IdEmpresa_IdObservacionFiscal')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_ObservacionFiscal_IdEmpresa_IdObservacionFiscal] ON [FIS].[ObservacionFiscal] ([IdEmpresa] ASC, [IdObservacionFiscal] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.ObservacionFiscal') AND name=N'UX_FIS_ObservacionFiscal_IdEmpresa_IdObservacionFiscal' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.ObservacionFiscal.UX_FIS_ObservacionFiscal_IdEmpresa_IdObservacionFiscal',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"IdObservacionFiscal","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.ObservacionFiscal') AND i.name=N'UX_FIS_ObservacionFiscal_IdEmpresa_IdObservacionFiscal') THROW 51003,N'Columnas de índice incompatibles: FIS.ObservacionFiscal.UX_FIS_ObservacionFiscal_IdEmpresa_IdObservacionFiscal',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.ObservacionFiscal') AND i.name=N'UX_FIS_ObservacionFiscal_IdEmpresa_IdObservacionFiscal')<>2 THROW 51003,N'Número de columnas de índice incompatible: FIS.ObservacionFiscal.UX_FIS_ObservacionFiscal_IdEmpresa_IdObservacionFiscal',1;

-- FIS.ReglaFiscalVersion | ERD EXUX
IF OBJECT_ID(N'FIS.ReglaFiscalVersion',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [FIS].[ReglaFiscalVersion] (
 [IdReglaFiscalVersion] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [Impuesto] varchar(40) NOT NULL,
 [Version] int NOT NULL,
 [ParametrosJson] nvarchar(max) NOT NULL,
 [Fuente] nvarchar(1000) NOT NULL,
 [Desde] date NOT NULL,
 [Hasta] date NULL,
 [IdUsuarioAprobacion] int NULL,
 [AprobadaUtc] datetime2(7) NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_ReglaFiscalVersion_IdReglaFiscalVersion] PRIMARY KEY CLUSTERED ([IdReglaFiscalVersion] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdReglaFiscalVersion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Impuesto","type":"varchar","length":40,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Version","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"ParametrosJson","type":"nvarchar","length":-1,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Fuente","type":"nvarchar","length":2000,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Desde","type":"date","length":3,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Hasta","type":"date","length":3,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"IdUsuarioAprobacion","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"AprobadaUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":1,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'FIS.ReglaFiscalVersion',N'U')
) THROW 51001,N'Estructura incompatible: FIS.ReglaFiscalVersion. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'FIS.ReglaFiscalVersion') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: FIS.ReglaFiscalVersion.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.ReglaFiscalVersion') AND name=N'UX_FIS_ReglaFiscalVersion_IdReglaFiscalVersion' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.ReglaFiscalVersion.UX_FIS_ReglaFiscalVersion_IdReglaFiscalVersion',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdReglaFiscalVersion","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.ReglaFiscalVersion') AND i.name=N'UX_FIS_ReglaFiscalVersion_IdReglaFiscalVersion') THROW 51003,N'Columnas de índice incompatibles: FIS.ReglaFiscalVersion.UX_FIS_ReglaFiscalVersion_IdReglaFiscalVersion',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.ReglaFiscalVersion') AND i.name=N'UX_FIS_ReglaFiscalVersion_IdReglaFiscalVersion')<>1 THROW 51003,N'Número de columnas de índice incompatible: FIS.ReglaFiscalVersion.UX_FIS_ReglaFiscalVersion_IdReglaFiscalVersion',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.ReglaFiscalVersion') AND name=N'UX_FIS_ReglaFiscalVersion_IdEmpresa_Impuesto_Version')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_ReglaFiscalVersion_IdEmpresa_Impuesto_Version] ON [FIS].[ReglaFiscalVersion] ([IdEmpresa] ASC, [Impuesto] ASC, [Version] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.ReglaFiscalVersion') AND name=N'UX_FIS_ReglaFiscalVersion_IdEmpresa_Impuesto_Version' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.ReglaFiscalVersion.UX_FIS_ReglaFiscalVersion_IdEmpresa_Impuesto_Version',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"Impuesto","ordinal":2,"descending":0,"included":0},{"name":"Version","ordinal":3,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.ReglaFiscalVersion') AND i.name=N'UX_FIS_ReglaFiscalVersion_IdEmpresa_Impuesto_Version') THROW 51003,N'Columnas de índice incompatibles: FIS.ReglaFiscalVersion.UX_FIS_ReglaFiscalVersion_IdEmpresa_Impuesto_Version',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.ReglaFiscalVersion') AND i.name=N'UX_FIS_ReglaFiscalVersion_IdEmpresa_Impuesto_Version')<>3 THROW 51003,N'Número de columnas de índice incompatible: FIS.ReglaFiscalVersion.UX_FIS_ReglaFiscalVersion_IdEmpresa_Impuesto_Version',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.ReglaFiscalVersion') AND name=N'UX_FIS_ReglaFiscalVersion_IdEmpresa_IdReglaFiscalVersion')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_ReglaFiscalVersion_IdEmpresa_IdReglaFiscalVersion] ON [FIS].[ReglaFiscalVersion] ([IdEmpresa] ASC, [IdReglaFiscalVersion] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.ReglaFiscalVersion') AND name=N'UX_FIS_ReglaFiscalVersion_IdEmpresa_IdReglaFiscalVersion' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.ReglaFiscalVersion.UX_FIS_ReglaFiscalVersion_IdEmpresa_IdReglaFiscalVersion',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"IdReglaFiscalVersion","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.ReglaFiscalVersion') AND i.name=N'UX_FIS_ReglaFiscalVersion_IdEmpresa_IdReglaFiscalVersion') THROW 51003,N'Columnas de índice incompatibles: FIS.ReglaFiscalVersion.UX_FIS_ReglaFiscalVersion_IdEmpresa_IdReglaFiscalVersion',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.ReglaFiscalVersion') AND i.name=N'UX_FIS_ReglaFiscalVersion_IdEmpresa_IdReglaFiscalVersion')<>2 THROW 51003,N'Número de columnas de índice incompatible: FIS.ReglaFiscalVersion.UX_FIS_ReglaFiscalVersion_IdEmpresa_IdReglaFiscalVersion',1;
IF OBJECT_ID(N'FIS.CK_EXUX_FIS_ReglaFiscalVersion_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [FIS].[ReglaFiscalVersion] WITH CHECK ADD CONSTRAINT [CK_EXUX_FIS_ReglaFiscalVersion_1] CHECK (Version > 0 AND ISJSON(ParametrosJson)=1);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'FIS.ReglaFiscalVersion') AND name=N'CK_EXUX_FIS_ReglaFiscalVersion_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'version>0andisjsonparametrosjson=1') THROW 51004,N'CHECK incompatible: FIS.ReglaFiscalVersion.CK_EXUX_FIS_ReglaFiscalVersion_1',1;
IF OBJECT_ID(N'FIS.CK_EXUX_FIS_ReglaFiscalVersion_2',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [FIS].[ReglaFiscalVersion] WITH CHECK ADD CONSTRAINT [CK_EXUX_FIS_ReglaFiscalVersion_2] CHECK (Hasta IS NULL OR Hasta >= Desde);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'FIS.ReglaFiscalVersion') AND name=N'CK_EXUX_FIS_ReglaFiscalVersion_2' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'hastaisnullorhasta>=desde') THROW 51004,N'CHECK incompatible: FIS.ReglaFiscalVersion.CK_EXUX_FIS_ReglaFiscalVersion_2',1;

-- FIS.SancionFiscal | ERD EXUX
IF OBJECT_ID(N'FIS.SancionFiscal',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [FIS].[SancionFiscal] (
 [IdSancionFiscal] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdObservacion] bigint NOT NULL,
 [Concepto] nvarchar(500) NOT NULL,
 [Importe] decimal(20,4) NOT NULL,
 [Vencimiento] date NOT NULL,
 [IdMoneda] int NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_SancionFiscal_IdSancionFiscal] PRIMARY KEY CLUSTERED ([IdSancionFiscal] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdSancionFiscal","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdObservacion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Concepto","type":"nvarchar","length":1000,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Importe","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"Vencimiento","type":"date","length":3,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdMoneda","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'FIS.SancionFiscal',N'U')
) THROW 51001,N'Estructura incompatible: FIS.SancionFiscal. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'FIS.SancionFiscal') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: FIS.SancionFiscal.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.SancionFiscal') AND name=N'UX_FIS_SancionFiscal_IdSancionFiscal' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.SancionFiscal.UX_FIS_SancionFiscal_IdSancionFiscal',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdSancionFiscal","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.SancionFiscal') AND i.name=N'UX_FIS_SancionFiscal_IdSancionFiscal') THROW 51003,N'Columnas de índice incompatibles: FIS.SancionFiscal.UX_FIS_SancionFiscal_IdSancionFiscal',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.SancionFiscal') AND i.name=N'UX_FIS_SancionFiscal_IdSancionFiscal')<>1 THROW 51003,N'Número de columnas de índice incompatible: FIS.SancionFiscal.UX_FIS_SancionFiscal_IdSancionFiscal',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.SancionFiscal') AND name=N'UX_FIS_SancionFiscal_IdEmpresa_IdSancionFiscal')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_SancionFiscal_IdEmpresa_IdSancionFiscal] ON [FIS].[SancionFiscal] ([IdEmpresa] ASC, [IdSancionFiscal] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.SancionFiscal') AND name=N'UX_FIS_SancionFiscal_IdEmpresa_IdSancionFiscal' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.SancionFiscal.UX_FIS_SancionFiscal_IdEmpresa_IdSancionFiscal',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"IdSancionFiscal","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.SancionFiscal') AND i.name=N'UX_FIS_SancionFiscal_IdEmpresa_IdSancionFiscal') THROW 51003,N'Columnas de índice incompatibles: FIS.SancionFiscal.UX_FIS_SancionFiscal_IdEmpresa_IdSancionFiscal',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.SancionFiscal') AND i.name=N'UX_FIS_SancionFiscal_IdEmpresa_IdSancionFiscal')<>2 THROW 51003,N'Número de columnas de índice incompatible: FIS.SancionFiscal.UX_FIS_SancionFiscal_IdEmpresa_IdSancionFiscal',1;
IF OBJECT_ID(N'FIS.CK_EXUX_FIS_SancionFiscal_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [FIS].[SancionFiscal] WITH CHECK ADD CONSTRAINT [CK_EXUX_FIS_SancionFiscal_1] CHECK (Importe >= 0);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'FIS.SancionFiscal') AND name=N'CK_EXUX_FIS_SancionFiscal_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'importe>=0') THROW 51004,N'CHECK incompatible: FIS.SancionFiscal.CK_EXUX_FIS_SancionFiscal_1',1;

-- FIS.ValidacionCfdi | ERD EXUX
IF OBJECT_ID(N'FIS.ValidacionCfdi',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [FIS].[ValidacionCfdi] (
 [IdValidacionCfdi] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdCfdi] bigint NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [Fuente] nvarchar(150) NOT NULL,
 [Resultado] nvarchar(500) NOT NULL,
 [IdDocumentoEvidencia] bigint NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_ValidacionCfdi_IdValidacionCfdi] PRIMARY KEY CLUSTERED ([IdValidacionCfdi] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdValidacionCfdi","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdCfdi","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Fecha","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"Fuente","type":"nvarchar","length":300,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Resultado","type":"nvarchar","length":1000,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdDocumentoEvidencia","type":"bigint","length":8,"precision":19,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'FIS.ValidacionCfdi',N'U')
) THROW 51001,N'Estructura incompatible: FIS.ValidacionCfdi. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'FIS.ValidacionCfdi') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: FIS.ValidacionCfdi.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'FIS.ValidacionCfdi') AND name=N'UX_FIS_ValidacionCfdi_IdValidacionCfdi' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: FIS.ValidacionCfdi.UX_FIS_ValidacionCfdi_IdValidacionCfdi',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdValidacionCfdi","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'FIS.ValidacionCfdi') AND i.name=N'UX_FIS_ValidacionCfdi_IdValidacionCfdi') THROW 51003,N'Columnas de índice incompatibles: FIS.ValidacionCfdi.UX_FIS_ValidacionCfdi_IdValidacionCfdi',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'FIS.ValidacionCfdi') AND i.name=N'UX_FIS_ValidacionCfdi_IdValidacionCfdi')<>1 THROW 51003,N'Número de columnas de índice incompatible: FIS.ValidacionCfdi.UX_FIS_ValidacionCfdi_IdValidacionCfdi',1;
COMMIT TRANSACTION;
END TRY
BEGIN CATCH
 IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;
PRINT N'FASE A completa: Fiscal. Relaciones pendientes en 02_Relaciones.sql.';
