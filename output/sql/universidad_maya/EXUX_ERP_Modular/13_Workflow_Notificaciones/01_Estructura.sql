/*
EXUX | Universidad Maya | Propuesta de reestructura SQL Server 2022
MÓDULO 13: Workflow_Notificaciones
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
IF SCHEMA_ID(N'PBR') IS NULL
EXEC sys.sp_executesql N'CREATE SCHEMA [PBR] AUTHORIZATION [dbo];';
IF SCHEMA_ID(N'SIS') IS NULL
EXEC sys.sp_executesql N'CREATE SCHEMA [SIS] AUTHORIZATION [dbo];';
IF SCHEMA_ID(N'WF') IS NULL
EXEC sys.sp_executesql N'CREATE SCHEMA [WF] AUTHORIZATION [dbo];';

-- PBR.WorkflowEstado | GestionEmpresarial.PBR.WorkflowEstado
-- CAMBIO IdEmpresa: Nueva pertenencia obligatoria a empresa
IF OBJECT_ID(N'PBR.WorkflowEstado',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [PBR].[WorkflowEstado] (
 [PKIdWorkflowEstado] int IDENTITY(1,1) NOT NULL,
 [FKIdWorkflowTemplate_PBR] int NOT NULL,
 [Codigo] nvarchar(30) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Nombre] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Orden] int NOT NULL,
 [EsInicial] bit NOT NULL DEFAULT ((0)),
 [EsFinal] bit NOT NULL DEFAULT ((0)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK_PBR_WorkflowEstado] PRIMARY KEY CLUSTERED ([PKIdWorkflowEstado] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"PKIdWorkflowEstado","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"FKIdWorkflowTemplate_PBR","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Codigo","type":"nvarchar","length":60,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Nombre","type":"nvarchar","length":400,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Orden","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"EsInicial","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"EsFinal","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Activo","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'PBR.WorkflowEstado',N'U')
) THROW 51001,N'Estructura incompatible: PBR.WorkflowEstado. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'PBR.WorkflowEstado') AND c.name=N'EsInicial' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'0') THROW 51002,N'DEFAULT incompatible: PBR.WorkflowEstado.EsInicial',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'PBR.WorkflowEstado') AND c.name=N'EsFinal' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'0') THROW 51002,N'DEFAULT incompatible: PBR.WorkflowEstado.EsFinal',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'PBR.WorkflowEstado') AND c.name=N'Activo' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'1') THROW 51002,N'DEFAULT incompatible: PBR.WorkflowEstado.Activo',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'PBR.WorkflowEstado') AND name=N'PK_PBR_WorkflowEstado' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: PBR.WorkflowEstado.PK_PBR_WorkflowEstado',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"PKIdWorkflowEstado","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'PBR.WorkflowEstado') AND i.name=N'PK_PBR_WorkflowEstado') THROW 51003,N'Columnas de índice incompatibles: PBR.WorkflowEstado.PK_PBR_WorkflowEstado',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'PBR.WorkflowEstado') AND i.name=N'PK_PBR_WorkflowEstado')<>1 THROW 51003,N'Número de columnas de índice incompatible: PBR.WorkflowEstado.PK_PBR_WorkflowEstado',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'PBR.WorkflowEstado') AND name=N'UX_PBR_WorkflowEstado_IdEmpresa_PKIdWorkflowEstado')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_PBR_WorkflowEstado_IdEmpresa_PKIdWorkflowEstado] ON [PBR].[WorkflowEstado] ([IdEmpresa] ASC, [PKIdWorkflowEstado] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'PBR.WorkflowEstado') AND name=N'UX_PBR_WorkflowEstado_IdEmpresa_PKIdWorkflowEstado' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: PBR.WorkflowEstado.UX_PBR_WorkflowEstado_IdEmpresa_PKIdWorkflowEstado',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"PKIdWorkflowEstado","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'PBR.WorkflowEstado') AND i.name=N'UX_PBR_WorkflowEstado_IdEmpresa_PKIdWorkflowEstado') THROW 51003,N'Columnas de índice incompatibles: PBR.WorkflowEstado.UX_PBR_WorkflowEstado_IdEmpresa_PKIdWorkflowEstado',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'PBR.WorkflowEstado') AND i.name=N'UX_PBR_WorkflowEstado_IdEmpresa_PKIdWorkflowEstado')<>2 THROW 51003,N'Número de columnas de índice incompatible: PBR.WorkflowEstado.UX_PBR_WorkflowEstado_IdEmpresa_PKIdWorkflowEstado',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'PBR.WorkflowEstado') AND name=N'UX_PBR_WorkflowEstado_IdEmpresa_FKIdWorkflowTemplate_PBR_PKIdWorkflowEstado')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_PBR_WorkflowEstado_IdEmpresa_FKIdWorkflowTemplate_PBR_PKIdWorkflowEstado] ON [PBR].[WorkflowEstado] ([IdEmpresa] ASC, [FKIdWorkflowTemplate_PBR] ASC, [PKIdWorkflowEstado] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'PBR.WorkflowEstado') AND name=N'UX_PBR_WorkflowEstado_IdEmpresa_FKIdWorkflowTemplate_PBR_PKIdWorkflowEstado' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: PBR.WorkflowEstado.UX_PBR_WorkflowEstado_IdEmpresa_FKIdWorkflowTemplate_PBR_PKIdWorkflowEstado',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"FKIdWorkflowTemplate_PBR","ordinal":2,"descending":0,"included":0},{"name":"PKIdWorkflowEstado","ordinal":3,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'PBR.WorkflowEstado') AND i.name=N'UX_PBR_WorkflowEstado_IdEmpresa_FKIdWorkflowTemplate_PBR_PKIdWorkflowEstado') THROW 51003,N'Columnas de índice incompatibles: PBR.WorkflowEstado.UX_PBR_WorkflowEstado_IdEmpresa_FKIdWorkflowTemplate_PBR_PKIdWorkflowEstado',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'PBR.WorkflowEstado') AND i.name=N'UX_PBR_WorkflowEstado_IdEmpresa_FKIdWorkflowTemplate_PBR_PKIdWorkflowEstado')<>3 THROW 51003,N'Número de columnas de índice incompatible: PBR.WorkflowEstado.UX_PBR_WorkflowEstado_IdEmpresa_FKIdWorkflowTemplate_PBR_PKIdWorkflowEstado',1;

-- PBR.WorkflowTemplate | GestionEmpresarial.PBR.WorkflowTemplate
-- CAMBIO IdEmpresa: Nueva pertenencia obligatoria a empresa
IF OBJECT_ID(N'PBR.WorkflowTemplate',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [PBR].[WorkflowTemplate] (
 [PKIdWorkflowTemplate] int IDENTITY(1,1) NOT NULL,
 [Codigo] nvarchar(30) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Nombre] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NOT NULL DEFAULT (getdate()),
 [IdEmpresa] int NOT NULL,
 [Version] int NOT NULL DEFAULT 1,
 [VigenciaDesde] date NOT NULL,
 [VigenciaHasta] date NULL,
 CONSTRAINT [PK_PBR_WorkflowTemplate] PRIMARY KEY CLUSTERED ([PKIdWorkflowTemplate] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"PKIdWorkflowTemplate","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"Codigo","type":"nvarchar","length":60,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Nombre","type":"nvarchar","length":400,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Activo","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FechaCreacion","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Version","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"VigenciaDesde","type":"date","length":3,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"VigenciaHasta","type":"date","length":3,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'PBR.WorkflowTemplate',N'U')
) THROW 51001,N'Estructura incompatible: PBR.WorkflowTemplate. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'PBR.WorkflowTemplate') AND c.name=N'Activo' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'1') THROW 51002,N'DEFAULT incompatible: PBR.WorkflowTemplate.Activo',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'PBR.WorkflowTemplate') AND c.name=N'FechaCreacion' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'getdate') THROW 51002,N'DEFAULT incompatible: PBR.WorkflowTemplate.FechaCreacion',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'PBR.WorkflowTemplate') AND c.name=N'Version' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'1') THROW 51002,N'DEFAULT incompatible: PBR.WorkflowTemplate.Version',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'PBR.WorkflowTemplate') AND name=N'PK_PBR_WorkflowTemplate' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: PBR.WorkflowTemplate.PK_PBR_WorkflowTemplate',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"PKIdWorkflowTemplate","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'PBR.WorkflowTemplate') AND i.name=N'PK_PBR_WorkflowTemplate') THROW 51003,N'Columnas de índice incompatibles: PBR.WorkflowTemplate.PK_PBR_WorkflowTemplate',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'PBR.WorkflowTemplate') AND i.name=N'PK_PBR_WorkflowTemplate')<>1 THROW 51003,N'Número de columnas de índice incompatible: PBR.WorkflowTemplate.PK_PBR_WorkflowTemplate',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'PBR.WorkflowTemplate') AND name=N'UX_PBR_WorkflowTemplate_IdEmpresa_PKIdWorkflowTemplate')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_PBR_WorkflowTemplate_IdEmpresa_PKIdWorkflowTemplate] ON [PBR].[WorkflowTemplate] ([IdEmpresa] ASC, [PKIdWorkflowTemplate] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'PBR.WorkflowTemplate') AND name=N'UX_PBR_WorkflowTemplate_IdEmpresa_PKIdWorkflowTemplate' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: PBR.WorkflowTemplate.UX_PBR_WorkflowTemplate_IdEmpresa_PKIdWorkflowTemplate',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"PKIdWorkflowTemplate","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'PBR.WorkflowTemplate') AND i.name=N'UX_PBR_WorkflowTemplate_IdEmpresa_PKIdWorkflowTemplate') THROW 51003,N'Columnas de índice incompatibles: PBR.WorkflowTemplate.UX_PBR_WorkflowTemplate_IdEmpresa_PKIdWorkflowTemplate',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'PBR.WorkflowTemplate') AND i.name=N'UX_PBR_WorkflowTemplate_IdEmpresa_PKIdWorkflowTemplate')<>2 THROW 51003,N'Número de columnas de índice incompatible: PBR.WorkflowTemplate.UX_PBR_WorkflowTemplate_IdEmpresa_PKIdWorkflowTemplate',1;

-- PBR.WorkflowTransicion | GestionEmpresarial.PBR.WorkflowTransicion
-- CAMBIO IdEmpresa: Nueva pertenencia obligatoria a empresa
IF OBJECT_ID(N'PBR.WorkflowTransicion',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [PBR].[WorkflowTransicion] (
 [PKIdWorkflowTransicion] int IDENTITY(1,1) NOT NULL,
 [FKIdWorkflowTemplate_PBR] int NOT NULL,
 [FKIdEstadoOrigen_PBR] int NOT NULL,
 [FKIdEstadoDestino_PBR] int NOT NULL,
 [Nombre] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [RolesPermitidos] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [RequiereFirma] bit NOT NULL DEFAULT ((0)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK_PBR_WorkflowTransicion] PRIMARY KEY CLUSTERED ([PKIdWorkflowTransicion] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"PKIdWorkflowTransicion","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"FKIdWorkflowTemplate_PBR","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FKIdEstadoOrigen_PBR","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FKIdEstadoDestino_PBR","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Nombre","type":"nvarchar","length":400,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"RolesPermitidos","type":"nvarchar","length":1000,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"RequiereFirma","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Activo","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'PBR.WorkflowTransicion',N'U')
) THROW 51001,N'Estructura incompatible: PBR.WorkflowTransicion. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'PBR.WorkflowTransicion') AND c.name=N'RequiereFirma' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'0') THROW 51002,N'DEFAULT incompatible: PBR.WorkflowTransicion.RequiereFirma',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'PBR.WorkflowTransicion') AND c.name=N'Activo' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'1') THROW 51002,N'DEFAULT incompatible: PBR.WorkflowTransicion.Activo',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'PBR.WorkflowTransicion') AND name=N'PK_PBR_WorkflowTransicion' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: PBR.WorkflowTransicion.PK_PBR_WorkflowTransicion',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"PKIdWorkflowTransicion","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'PBR.WorkflowTransicion') AND i.name=N'PK_PBR_WorkflowTransicion') THROW 51003,N'Columnas de índice incompatibles: PBR.WorkflowTransicion.PK_PBR_WorkflowTransicion',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'PBR.WorkflowTransicion') AND i.name=N'PK_PBR_WorkflowTransicion')<>1 THROW 51003,N'Número de columnas de índice incompatible: PBR.WorkflowTransicion.PK_PBR_WorkflowTransicion',1;

-- SIS.EnvioWorkflow | GestionEmpresarial.SIS.EnvioWorkflow
-- CAMBIO IdEmpresa: Nueva pertenencia obligatoria a empresa
IF OBJECT_ID(N'SIS.EnvioWorkflow',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [SIS].[EnvioWorkflow] (
 [PKIdEnvioWorkflow] bigint IDENTITY(1,1) NOT NULL,
 [Proceso] varchar(60) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [EntidadId] bigint NOT NULL,
 [Estado] varchar(20) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [EstadoAnterior] varchar(20) COLLATE Modern_Spanish_CI_AS NULL,
 [TokenOperacion] uniqueidentifier NULL,
 [FechaEnvio] datetime2(7) NULL,
 [FechaRechazo] datetime2(7) NULL,
 [UsuarioEnvio] int NULL,
 [UsuarioRechazo] int NULL,
 [MotivoRechazo] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [FechaActualizacion] datetime2(7) NOT NULL DEFAULT (sysdatetime()),
 [IdEmpresa] int NOT NULL,
 [IdOperacion] bigint NOT NULL,
 [IdTemplate] int NOT NULL,
 CONSTRAINT [PK_SIS_EnvioWorkflow] PRIMARY KEY CLUSTERED ([PKIdEnvioWorkflow] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"PKIdEnvioWorkflow","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"Proceso","type":"varchar","length":60,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"EntidadId","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Estado","type":"varchar","length":20,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"EstadoAnterior","type":"varchar","length":20,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"TokenOperacion","type":"uniqueidentifier","length":16,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"FechaEnvio","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":1,"identity":0,"computed":0},{"name":"FechaRechazo","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":1,"identity":0,"computed":0},{"name":"UsuarioEnvio","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"UsuarioRechazo","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"MotivoRechazo","type":"nvarchar","length":1000,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"FechaActualizacion","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdOperacion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdTemplate","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'SIS.EnvioWorkflow',N'U')
) THROW 51001,N'Estructura incompatible: SIS.EnvioWorkflow. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'SIS.EnvioWorkflow') AND c.name=N'FechaActualizacion' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysdatetime') THROW 51002,N'DEFAULT incompatible: SIS.EnvioWorkflow.FechaActualizacion',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.EnvioWorkflow') AND name=N'PK_SIS_EnvioWorkflow' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.EnvioWorkflow.PK_SIS_EnvioWorkflow',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"PKIdEnvioWorkflow","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.EnvioWorkflow') AND i.name=N'PK_SIS_EnvioWorkflow') THROW 51003,N'Columnas de índice incompatibles: SIS.EnvioWorkflow.PK_SIS_EnvioWorkflow',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.EnvioWorkflow') AND i.name=N'PK_SIS_EnvioWorkflow')<>1 THROW 51003,N'Número de columnas de índice incompatible: SIS.EnvioWorkflow.PK_SIS_EnvioWorkflow',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.EnvioWorkflow') AND name=N'UQ_SIS_EnvioWorkflow_ProcesoEntidad')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UQ_SIS_EnvioWorkflow_ProcesoEntidad] ON [SIS].[EnvioWorkflow] ([Proceso] ASC, [EntidadId] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.EnvioWorkflow') AND name=N'UQ_SIS_EnvioWorkflow_ProcesoEntidad' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.EnvioWorkflow.UQ_SIS_EnvioWorkflow_ProcesoEntidad',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"Proceso","ordinal":1,"descending":0,"included":0},{"name":"EntidadId","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.EnvioWorkflow') AND i.name=N'UQ_SIS_EnvioWorkflow_ProcesoEntidad') THROW 51003,N'Columnas de índice incompatibles: SIS.EnvioWorkflow.UQ_SIS_EnvioWorkflow_ProcesoEntidad',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.EnvioWorkflow') AND i.name=N'UQ_SIS_EnvioWorkflow_ProcesoEntidad')<>2 THROW 51003,N'Número de columnas de índice incompatible: SIS.EnvioWorkflow.UQ_SIS_EnvioWorkflow_ProcesoEntidad',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.EnvioWorkflow') AND name=N'UX_SIS_EnvioWorkflow_IdEmpresa_PKIdEnvioWorkflow')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_SIS_EnvioWorkflow_IdEmpresa_PKIdEnvioWorkflow] ON [SIS].[EnvioWorkflow] ([IdEmpresa] ASC, [PKIdEnvioWorkflow] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.EnvioWorkflow') AND name=N'UX_SIS_EnvioWorkflow_IdEmpresa_PKIdEnvioWorkflow' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.EnvioWorkflow.UX_SIS_EnvioWorkflow_IdEmpresa_PKIdEnvioWorkflow',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"PKIdEnvioWorkflow","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.EnvioWorkflow') AND i.name=N'UX_SIS_EnvioWorkflow_IdEmpresa_PKIdEnvioWorkflow') THROW 51003,N'Columnas de índice incompatibles: SIS.EnvioWorkflow.UX_SIS_EnvioWorkflow_IdEmpresa_PKIdEnvioWorkflow',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.EnvioWorkflow') AND i.name=N'UX_SIS_EnvioWorkflow_IdEmpresa_PKIdEnvioWorkflow')<>2 THROW 51003,N'Número de columnas de índice incompatible: SIS.EnvioWorkflow.UX_SIS_EnvioWorkflow_IdEmpresa_PKIdEnvioWorkflow',1;
IF OBJECT_ID(N'SIS.CK_SIS_EnvioWorkflow_Estado',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [SIS].[EnvioWorkflow] WITH CHECK ADD CONSTRAINT [CK_SIS_EnvioWorkflow_Estado] CHECK (([Estado]=''RECHAZADO'' OR [Estado]=''ENVIADO'' OR [Estado]=''PROCESANDO'' OR [Estado]=''PENDIENTE''));';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'SIS.EnvioWorkflow') AND name=N'CK_SIS_EnvioWorkflow_Estado' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'estado=''rechazado''orestado=''enviado''orestado=''procesando''orestado=''pendiente''') THROW 51004,N'CHECK incompatible: SIS.EnvioWorkflow.CK_SIS_EnvioWorkflow_Estado',1;

-- SIS.Notificacion | GestionEmpresarial.SIS.Notificacion
-- CAMBIO IdEmpresa: Nueva pertenencia obligatoria a empresa
IF OBJECT_ID(N'SIS.Notificacion',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [SIS].[Notificacion] (
 [Pk_IdNotificacion] bigint IDENTITY(1,1) NOT NULL,
 [Fk_IdNotificacionTipo] int NOT NULL,
 [Fk_IdUsuarioOrigen] int NULL,
 [Modulo] nvarchar(120) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [SubModulo] nvarchar(120) COLLATE Modern_Spanish_CI_AS NULL,
 [Evento] nvarchar(120) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Entidad] nvarchar(150) COLLATE Modern_Spanish_CI_AS NULL,
 [Fk_IdEntidad] bigint NULL,
 [Titulo] nvarchar(250) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Mensaje] nvarchar(max) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Url] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [JsonData] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [CT_CreatedBy] int NULL,
 [CT_CreatedDate] datetime2(0) NOT NULL DEFAULT (getdate()),
 [CT_ModifiedBy] int NULL,
 [CT_ModifiedDate] datetime2(0) NULL,
 [CT_LIVE] bit NOT NULL DEFAULT ((1)),
 [IdEmpresa] int NOT NULL,
 [IdEventoPendiente] bigint NULL,
 [IdRegla] int NULL,
 CONSTRAINT [PK__Notifica__C4DE1487A33A9F52] PRIMARY KEY CLUSTERED ([Pk_IdNotificacion] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"Pk_IdNotificacion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"Fk_IdNotificacionTipo","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Fk_IdUsuarioOrigen","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Modulo","type":"nvarchar","length":240,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"SubModulo","type":"nvarchar","length":240,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Evento","type":"nvarchar","length":240,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Entidad","type":"nvarchar","length":300,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Fk_IdEntidad","type":"bigint","length":8,"precision":19,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Titulo","type":"nvarchar","length":500,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Mensaje","type":"nvarchar","length":-1,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Url","type":"nvarchar","length":2000,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"JsonData","type":"nvarchar","length":-1,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CT_CreatedBy","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CT_CreatedDate","type":"datetime2","length":6,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CT_ModifiedBy","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CT_ModifiedDate","type":"datetime2","length":6,"precision":19,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CT_LIVE","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdEventoPendiente","type":"bigint","length":8,"precision":19,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"IdRegla","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'SIS.Notificacion',N'U')
) THROW 51001,N'Estructura incompatible: SIS.Notificacion. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'SIS.Notificacion') AND c.name=N'CT_CreatedDate' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'getdate') THROW 51002,N'DEFAULT incompatible: SIS.Notificacion.CT_CreatedDate',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'SIS.Notificacion') AND c.name=N'CT_LIVE' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'1') THROW 51002,N'DEFAULT incompatible: SIS.Notificacion.CT_LIVE',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.Notificacion') AND name=N'PK__Notifica__C4DE1487A33A9F52' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.Notificacion.PK__Notifica__C4DE1487A33A9F52',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"Pk_IdNotificacion","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.Notificacion') AND i.name=N'PK__Notifica__C4DE1487A33A9F52') THROW 51003,N'Columnas de índice incompatibles: SIS.Notificacion.PK__Notifica__C4DE1487A33A9F52',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.Notificacion') AND i.name=N'PK__Notifica__C4DE1487A33A9F52')<>1 THROW 51003,N'Número de columnas de índice incompatible: SIS.Notificacion.PK__Notifica__C4DE1487A33A9F52',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.Notificacion') AND name=N'IX_Notificacion_Fk_IdNotificacionTipo_1055342824')
EXEC sys.sp_executesql N'CREATE NONCLUSTERED INDEX [IX_Notificacion_Fk_IdNotificacionTipo_1055342824] ON [SIS].[Notificacion] ([Fk_IdNotificacionTipo] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.Notificacion') AND name=N'IX_Notificacion_Fk_IdNotificacionTipo_1055342824' AND is_unique=0 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.Notificacion.IX_Notificacion_Fk_IdNotificacionTipo_1055342824',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"Fk_IdNotificacionTipo","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.Notificacion') AND i.name=N'IX_Notificacion_Fk_IdNotificacionTipo_1055342824') THROW 51003,N'Columnas de índice incompatibles: SIS.Notificacion.IX_Notificacion_Fk_IdNotificacionTipo_1055342824',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.Notificacion') AND i.name=N'IX_Notificacion_Fk_IdNotificacionTipo_1055342824')<>1 THROW 51003,N'Número de columnas de índice incompatible: SIS.Notificacion.IX_Notificacion_Fk_IdNotificacionTipo_1055342824',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.Notificacion') AND name=N'IX_Notificacion_ModuloEvento')
EXEC sys.sp_executesql N'CREATE NONCLUSTERED INDEX [IX_Notificacion_ModuloEvento] ON [SIS].[Notificacion] ([Modulo] ASC, [SubModulo] ASC, [Evento] ASC, [Fk_IdEntidad] ASC) INCLUDE ([Titulo], [CT_CreatedDate]);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.Notificacion') AND name=N'IX_Notificacion_ModuloEvento' AND is_unique=0 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.Notificacion.IX_Notificacion_ModuloEvento',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"Modulo","ordinal":1,"descending":0,"included":0},{"name":"SubModulo","ordinal":2,"descending":0,"included":0},{"name":"Evento","ordinal":3,"descending":0,"included":0},{"name":"Fk_IdEntidad","ordinal":4,"descending":0,"included":0},{"name":"Titulo","ordinal":0,"descending":0,"included":1},{"name":"CT_CreatedDate","ordinal":0,"descending":0,"included":1}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.Notificacion') AND i.name=N'IX_Notificacion_ModuloEvento') THROW 51003,N'Columnas de índice incompatibles: SIS.Notificacion.IX_Notificacion_ModuloEvento',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.Notificacion') AND i.name=N'IX_Notificacion_ModuloEvento')<>6 THROW 51003,N'Número de columnas de índice incompatible: SIS.Notificacion.IX_Notificacion_ModuloEvento',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.Notificacion') AND name=N'UX_SIS_Notificacion_IdEmpresa_Pk_IdNotificacion')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_SIS_Notificacion_IdEmpresa_Pk_IdNotificacion] ON [SIS].[Notificacion] ([IdEmpresa] ASC, [Pk_IdNotificacion] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.Notificacion') AND name=N'UX_SIS_Notificacion_IdEmpresa_Pk_IdNotificacion' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.Notificacion.UX_SIS_Notificacion_IdEmpresa_Pk_IdNotificacion',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"Pk_IdNotificacion","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.Notificacion') AND i.name=N'UX_SIS_Notificacion_IdEmpresa_Pk_IdNotificacion') THROW 51003,N'Columnas de índice incompatibles: SIS.Notificacion.UX_SIS_Notificacion_IdEmpresa_Pk_IdNotificacion',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.Notificacion') AND i.name=N'UX_SIS_Notificacion_IdEmpresa_Pk_IdNotificacion')<>2 THROW 51003,N'Número de columnas de índice incompatible: SIS.Notificacion.UX_SIS_Notificacion_IdEmpresa_Pk_IdNotificacion',1;

-- SIS.NotificacionDestino | GestionEmpresarial.SIS.NotificacionDestino
-- CAMBIO IdEmpresa: Contexto obligatorio por relación de negocio
IF OBJECT_ID(N'SIS.NotificacionDestino',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [SIS].[NotificacionDestino] (
 [Pk_IdNotificacionDestino] bigint IDENTITY(1,1) NOT NULL,
 [Fk_IdNotificacion] bigint NOT NULL,
 [Fk_IdUsuarioDestino] int NOT NULL,
 [Fk_IdNotificacionEstado] int NOT NULL DEFAULT ((1)),
 [FechaLeido] datetime2(0) NULL,
 [FechaAtendido] datetime2(0) NULL,
 [CT_CreatedBy] int NULL,
 [CT_CreatedDate] datetime2(0) NOT NULL DEFAULT (getdate()),
 [CT_ModifiedBy] int NULL,
 [CT_ModifiedDate] datetime2(0) NULL,
 [CT_LIVE] bit NOT NULL DEFAULT ((1)),
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK__Notifica__3741935BF94B83DF] PRIMARY KEY CLUSTERED ([Pk_IdNotificacionDestino] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"Pk_IdNotificacionDestino","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"Fk_IdNotificacion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Fk_IdUsuarioDestino","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Fk_IdNotificacionEstado","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FechaLeido","type":"datetime2","length":6,"precision":19,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"FechaAtendido","type":"datetime2","length":6,"precision":19,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CT_CreatedBy","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CT_CreatedDate","type":"datetime2","length":6,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CT_ModifiedBy","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CT_ModifiedDate","type":"datetime2","length":6,"precision":19,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CT_LIVE","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'SIS.NotificacionDestino',N'U')
) THROW 51001,N'Estructura incompatible: SIS.NotificacionDestino. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'SIS.NotificacionDestino') AND c.name=N'Fk_IdNotificacionEstado' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'1') THROW 51002,N'DEFAULT incompatible: SIS.NotificacionDestino.Fk_IdNotificacionEstado',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'SIS.NotificacionDestino') AND c.name=N'CT_CreatedDate' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'getdate') THROW 51002,N'DEFAULT incompatible: SIS.NotificacionDestino.CT_CreatedDate',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'SIS.NotificacionDestino') AND c.name=N'CT_LIVE' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'1') THROW 51002,N'DEFAULT incompatible: SIS.NotificacionDestino.CT_LIVE',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.NotificacionDestino') AND name=N'PK__Notifica__3741935BF94B83DF' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.NotificacionDestino.PK__Notifica__3741935BF94B83DF',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"Pk_IdNotificacionDestino","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.NotificacionDestino') AND i.name=N'PK__Notifica__3741935BF94B83DF') THROW 51003,N'Columnas de índice incompatibles: SIS.NotificacionDestino.PK__Notifica__3741935BF94B83DF',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.NotificacionDestino') AND i.name=N'PK__Notifica__3741935BF94B83DF')<>1 THROW 51003,N'Número de columnas de índice incompatible: SIS.NotificacionDestino.PK__Notifica__3741935BF94B83DF',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.NotificacionDestino') AND name=N'IX_NotificacionDestino_Notificacion')
EXEC sys.sp_executesql N'CREATE NONCLUSTERED INDEX [IX_NotificacionDestino_Notificacion] ON [SIS].[NotificacionDestino] ([Fk_IdNotificacion] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.NotificacionDestino') AND name=N'IX_NotificacionDestino_Notificacion' AND is_unique=0 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.NotificacionDestino.IX_NotificacionDestino_Notificacion',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"Fk_IdNotificacion","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.NotificacionDestino') AND i.name=N'IX_NotificacionDestino_Notificacion') THROW 51003,N'Columnas de índice incompatibles: SIS.NotificacionDestino.IX_NotificacionDestino_Notificacion',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.NotificacionDestino') AND i.name=N'IX_NotificacionDestino_Notificacion')<>1 THROW 51003,N'Número de columnas de índice incompatible: SIS.NotificacionDestino.IX_NotificacionDestino_Notificacion',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.NotificacionDestino') AND name=N'IX_NotificacionDestino_UsuarioEstado')
EXEC sys.sp_executesql N'CREATE NONCLUSTERED INDEX [IX_NotificacionDestino_UsuarioEstado] ON [SIS].[NotificacionDestino] ([Fk_IdUsuarioDestino] ASC, [Fk_IdNotificacionEstado] ASC, [CT_LIVE] ASC) INCLUDE ([Fk_IdNotificacion], [FechaLeido], [FechaAtendido]);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.NotificacionDestino') AND name=N'IX_NotificacionDestino_UsuarioEstado' AND is_unique=0 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.NotificacionDestino.IX_NotificacionDestino_UsuarioEstado',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"Fk_IdUsuarioDestino","ordinal":1,"descending":0,"included":0},{"name":"Fk_IdNotificacionEstado","ordinal":2,"descending":0,"included":0},{"name":"CT_LIVE","ordinal":3,"descending":0,"included":0},{"name":"Fk_IdNotificacion","ordinal":0,"descending":0,"included":1},{"name":"FechaLeido","ordinal":0,"descending":0,"included":1},{"name":"FechaAtendido","ordinal":0,"descending":0,"included":1}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.NotificacionDestino') AND i.name=N'IX_NotificacionDestino_UsuarioEstado') THROW 51003,N'Columnas de índice incompatibles: SIS.NotificacionDestino.IX_NotificacionDestino_UsuarioEstado',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.NotificacionDestino') AND i.name=N'IX_NotificacionDestino_UsuarioEstado')<>6 THROW 51003,N'Número de columnas de índice incompatible: SIS.NotificacionDestino.IX_NotificacionDestino_UsuarioEstado',1;

-- SIS.NotificacionEstado | GestionEmpresarial.SIS.NotificacionEstado
IF OBJECT_ID(N'SIS.NotificacionEstado',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [SIS].[NotificacionEstado] (
 [Pk_IdNotificacionEstado] int NOT NULL,
 [Descripcion] nvarchar(80) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 CONSTRAINT [PK__Notifica__90095BB311E5894C] PRIMARY KEY CLUSTERED ([Pk_IdNotificacionEstado] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"Pk_IdNotificacionEstado","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Descripcion","type":"nvarchar","length":160,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Activo","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'SIS.NotificacionEstado',N'U')
) THROW 51001,N'Estructura incompatible: SIS.NotificacionEstado. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'SIS.NotificacionEstado') AND c.name=N'Activo' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'1') THROW 51002,N'DEFAULT incompatible: SIS.NotificacionEstado.Activo',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.NotificacionEstado') AND name=N'PK__Notifica__90095BB311E5894C' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.NotificacionEstado.PK__Notifica__90095BB311E5894C',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"Pk_IdNotificacionEstado","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.NotificacionEstado') AND i.name=N'PK__Notifica__90095BB311E5894C') THROW 51003,N'Columnas de índice incompatibles: SIS.NotificacionEstado.PK__Notifica__90095BB311E5894C',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.NotificacionEstado') AND i.name=N'PK__Notifica__90095BB311E5894C')<>1 THROW 51003,N'Número de columnas de índice incompatible: SIS.NotificacionEstado.PK__Notifica__90095BB311E5894C',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.NotificacionEstado') AND name=N'IX_NotificacionEstado_Activo_1007342653')
EXEC sys.sp_executesql N'CREATE NONCLUSTERED INDEX [IX_NotificacionEstado_Activo_1007342653] ON [SIS].[NotificacionEstado] ([Activo] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.NotificacionEstado') AND name=N'IX_NotificacionEstado_Activo_1007342653' AND is_unique=0 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.NotificacionEstado.IX_NotificacionEstado_Activo_1007342653',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"Activo","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.NotificacionEstado') AND i.name=N'IX_NotificacionEstado_Activo_1007342653') THROW 51003,N'Columnas de índice incompatibles: SIS.NotificacionEstado.IX_NotificacionEstado_Activo_1007342653',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.NotificacionEstado') AND i.name=N'IX_NotificacionEstado_Activo_1007342653')<>1 THROW 51003,N'Número de columnas de índice incompatible: SIS.NotificacionEstado.IX_NotificacionEstado_Activo_1007342653',1;

-- SIS.NotificacionRegla | GestionEmpresarial.SIS.NotificacionRegla
-- CAMBIO IdEmpresa: Nueva pertenencia obligatoria a empresa
IF OBJECT_ID(N'SIS.NotificacionRegla',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [SIS].[NotificacionRegla] (
 [Pk_IdNotificacionRegla] int IDENTITY(1,1) NOT NULL,
 [Modulo] nvarchar(120) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [SubModulo] nvarchar(120) COLLATE Modern_Spanish_CI_AS NULL,
 [Evento] nvarchar(120) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [TipoDestino] nvarchar(40) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [ClaveDestino] nvarchar(150) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [CT_CreatedBy] int NULL,
 [CT_CreatedDate] datetime2(0) NOT NULL DEFAULT (getdate()),
 [CT_ModifiedBy] int NULL,
 [CT_ModifiedDate] datetime2(0) NULL,
 [CT_LIVE] bit NOT NULL DEFAULT ((1)),
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK__Notifica__C28A7778191B7192] PRIMARY KEY CLUSTERED ([Pk_IdNotificacionRegla] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"Pk_IdNotificacionRegla","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"Modulo","type":"nvarchar","length":240,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"SubModulo","type":"nvarchar","length":240,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Evento","type":"nvarchar","length":240,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"TipoDestino","type":"nvarchar","length":80,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"ClaveDestino","type":"nvarchar","length":300,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Activo","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CT_CreatedBy","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CT_CreatedDate","type":"datetime2","length":6,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CT_ModifiedBy","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CT_ModifiedDate","type":"datetime2","length":6,"precision":19,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CT_LIVE","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'SIS.NotificacionRegla',N'U')
) THROW 51001,N'Estructura incompatible: SIS.NotificacionRegla. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'SIS.NotificacionRegla') AND c.name=N'Activo' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'1') THROW 51002,N'DEFAULT incompatible: SIS.NotificacionRegla.Activo',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'SIS.NotificacionRegla') AND c.name=N'CT_CreatedDate' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'getdate') THROW 51002,N'DEFAULT incompatible: SIS.NotificacionRegla.CT_CreatedDate',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'SIS.NotificacionRegla') AND c.name=N'CT_LIVE' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'1') THROW 51002,N'DEFAULT incompatible: SIS.NotificacionRegla.CT_LIVE',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.NotificacionRegla') AND name=N'PK__Notifica__C28A7778191B7192' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.NotificacionRegla.PK__Notifica__C28A7778191B7192',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"Pk_IdNotificacionRegla","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.NotificacionRegla') AND i.name=N'PK__Notifica__C28A7778191B7192') THROW 51003,N'Columnas de índice incompatibles: SIS.NotificacionRegla.PK__Notifica__C28A7778191B7192',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.NotificacionRegla') AND i.name=N'PK__Notifica__C28A7778191B7192')<>1 THROW 51003,N'Número de columnas de índice incompatible: SIS.NotificacionRegla.PK__Notifica__C28A7778191B7192',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.NotificacionRegla') AND name=N'IX_NotificacionRegla_Activo_1247343508')
EXEC sys.sp_executesql N'CREATE NONCLUSTERED INDEX [IX_NotificacionRegla_Activo_1247343508] ON [SIS].[NotificacionRegla] ([Activo] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.NotificacionRegla') AND name=N'IX_NotificacionRegla_Activo_1247343508' AND is_unique=0 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.NotificacionRegla.IX_NotificacionRegla_Activo_1247343508',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"Activo","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.NotificacionRegla') AND i.name=N'IX_NotificacionRegla_Activo_1247343508') THROW 51003,N'Columnas de índice incompatibles: SIS.NotificacionRegla.IX_NotificacionRegla_Activo_1247343508',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.NotificacionRegla') AND i.name=N'IX_NotificacionRegla_Activo_1247343508')<>1 THROW 51003,N'Número de columnas de índice incompatible: SIS.NotificacionRegla.IX_NotificacionRegla_Activo_1247343508',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.NotificacionRegla') AND name=N'IX_NotificacionRegla_Evento')
EXEC sys.sp_executesql N'CREATE NONCLUSTERED INDEX [IX_NotificacionRegla_Evento] ON [SIS].[NotificacionRegla] ([Modulo] ASC, [SubModulo] ASC, [Evento] ASC, [TipoDestino] ASC, [ClaveDestino] ASC) WHERE ([CT_LIVE]=(1) AND [Activo]=(1));';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.NotificacionRegla') AND name=N'IX_NotificacionRegla_Evento' AND is_unique=0 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'ct_live=1andactivo=1') THROW 51003,N'Índice incompatible: SIS.NotificacionRegla.IX_NotificacionRegla_Evento',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"Modulo","ordinal":1,"descending":0,"included":0},{"name":"SubModulo","ordinal":2,"descending":0,"included":0},{"name":"Evento","ordinal":3,"descending":0,"included":0},{"name":"TipoDestino","ordinal":4,"descending":0,"included":0},{"name":"ClaveDestino","ordinal":5,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.NotificacionRegla') AND i.name=N'IX_NotificacionRegla_Evento') THROW 51003,N'Columnas de índice incompatibles: SIS.NotificacionRegla.IX_NotificacionRegla_Evento',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.NotificacionRegla') AND i.name=N'IX_NotificacionRegla_Evento')<>5 THROW 51003,N'Número de columnas de índice incompatible: SIS.NotificacionRegla.IX_NotificacionRegla_Evento',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.NotificacionRegla') AND name=N'UX_SIS_NotificacionRegla_IdEmpresa_Pk_IdNotificacionRegla')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_SIS_NotificacionRegla_IdEmpresa_Pk_IdNotificacionRegla] ON [SIS].[NotificacionRegla] ([IdEmpresa] ASC, [Pk_IdNotificacionRegla] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.NotificacionRegla') AND name=N'UX_SIS_NotificacionRegla_IdEmpresa_Pk_IdNotificacionRegla' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.NotificacionRegla.UX_SIS_NotificacionRegla_IdEmpresa_Pk_IdNotificacionRegla',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"Pk_IdNotificacionRegla","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.NotificacionRegla') AND i.name=N'UX_SIS_NotificacionRegla_IdEmpresa_Pk_IdNotificacionRegla') THROW 51003,N'Columnas de índice incompatibles: SIS.NotificacionRegla.UX_SIS_NotificacionRegla_IdEmpresa_Pk_IdNotificacionRegla',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.NotificacionRegla') AND i.name=N'UX_SIS_NotificacionRegla_IdEmpresa_Pk_IdNotificacionRegla')<>2 THROW 51003,N'Número de columnas de índice incompatible: SIS.NotificacionRegla.UX_SIS_NotificacionRegla_IdEmpresa_Pk_IdNotificacionRegla',1;

-- SIS.NotificacionTipo | GestionEmpresarial.SIS.NotificacionTipo
IF OBJECT_ID(N'SIS.NotificacionTipo',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [SIS].[NotificacionTipo] (
 [Pk_IdNotificacionTipo] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(80) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(250) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 CONSTRAINT [PK__Notifica__81A1FC0ECA91077B] PRIMARY KEY CLUSTERED ([Pk_IdNotificacionTipo] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"Pk_IdNotificacionTipo","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"Clave","type":"nvarchar","length":160,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Descripcion","type":"nvarchar","length":500,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Activo","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'SIS.NotificacionTipo',N'U')
) THROW 51001,N'Estructura incompatible: SIS.NotificacionTipo. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'SIS.NotificacionTipo') AND c.name=N'Activo' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'1') THROW 51002,N'DEFAULT incompatible: SIS.NotificacionTipo.Activo',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.NotificacionTipo') AND name=N'PK__Notifica__81A1FC0ECA91077B' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.NotificacionTipo.PK__Notifica__81A1FC0ECA91077B',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"Pk_IdNotificacionTipo","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.NotificacionTipo') AND i.name=N'PK__Notifica__81A1FC0ECA91077B') THROW 51003,N'Columnas de índice incompatibles: SIS.NotificacionTipo.PK__Notifica__81A1FC0ECA91077B',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.NotificacionTipo') AND i.name=N'PK__Notifica__81A1FC0ECA91077B')<>1 THROW 51003,N'Número de columnas de índice incompatible: SIS.NotificacionTipo.PK__Notifica__81A1FC0ECA91077B',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.NotificacionTipo') AND name=N'UQ__Notifica__E8181E1184A89DCD')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UQ__Notifica__E8181E1184A89DCD] ON [SIS].[NotificacionTipo] ([Clave] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.NotificacionTipo') AND name=N'UQ__Notifica__E8181E1184A89DCD' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.NotificacionTipo.UQ__Notifica__E8181E1184A89DCD',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"Clave","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.NotificacionTipo') AND i.name=N'UQ__Notifica__E8181E1184A89DCD') THROW 51003,N'Columnas de índice incompatibles: SIS.NotificacionTipo.UQ__Notifica__E8181E1184A89DCD',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.NotificacionTipo') AND i.name=N'UQ__Notifica__E8181E1184A89DCD')<>1 THROW 51003,N'Número de columnas de índice incompatible: SIS.NotificacionTipo.UQ__Notifica__E8181E1184A89DCD',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.NotificacionTipo') AND name=N'IX_NotificacionTipo_Activo_943342425')
EXEC sys.sp_executesql N'CREATE NONCLUSTERED INDEX [IX_NotificacionTipo_Activo_943342425] ON [SIS].[NotificacionTipo] ([Activo] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.NotificacionTipo') AND name=N'IX_NotificacionTipo_Activo_943342425' AND is_unique=0 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.NotificacionTipo.IX_NotificacionTipo_Activo_943342425',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"Activo","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.NotificacionTipo') AND i.name=N'IX_NotificacionTipo_Activo_943342425') THROW 51003,N'Columnas de índice incompatibles: SIS.NotificacionTipo.IX_NotificacionTipo_Activo_943342425',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.NotificacionTipo') AND i.name=N'IX_NotificacionTipo_Activo_943342425')<>1 THROW 51003,N'Número de columnas de índice incompatible: SIS.NotificacionTipo.IX_NotificacionTipo_Activo_943342425',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.NotificacionTipo') AND name=N'IX_NotificacionTipo_Clave_943342425')
EXEC sys.sp_executesql N'CREATE NONCLUSTERED INDEX [IX_NotificacionTipo_Clave_943342425] ON [SIS].[NotificacionTipo] ([Clave] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'SIS.NotificacionTipo') AND name=N'IX_NotificacionTipo_Clave_943342425' AND is_unique=0 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: SIS.NotificacionTipo.IX_NotificacionTipo_Clave_943342425',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"Clave","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'SIS.NotificacionTipo') AND i.name=N'IX_NotificacionTipo_Clave_943342425') THROW 51003,N'Columnas de índice incompatibles: SIS.NotificacionTipo.IX_NotificacionTipo_Clave_943342425',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'SIS.NotificacionTipo') AND i.name=N'IX_NotificacionTipo_Clave_943342425')<>1 THROW 51003,N'Número de columnas de índice incompatible: SIS.NotificacionTipo.IX_NotificacionTipo_Clave_943342425',1;

-- WF.CalendarioAtencion | ERD EXUX
IF OBJECT_ID(N'WF.CalendarioAtencion',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [WF].[CalendarioAtencion] (
 [IdCalendarioAtencion] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [Codigo] nvarchar(30) NOT NULL,
 [ZonaHoraria] nvarchar(100) NOT NULL,
 [HorarioJson] nvarchar(max) NOT NULL,
 [ExcepcionesJson] nvarchar(max) NULL,
 [Activo] bit NOT NULL DEFAULT 1,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_WF_CalendarioAtencion_IdCalendarioAtencion] PRIMARY KEY CLUSTERED ([IdCalendarioAtencion] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdCalendarioAtencion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Codigo","type":"nvarchar","length":60,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"ZonaHoraria","type":"nvarchar","length":200,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"HorarioJson","type":"nvarchar","length":-1,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"ExcepcionesJson","type":"nvarchar","length":-1,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Activo","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'WF.CalendarioAtencion',N'U')
) THROW 51001,N'Estructura incompatible: WF.CalendarioAtencion. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'WF.CalendarioAtencion') AND c.name=N'Activo' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'1') THROW 51002,N'DEFAULT incompatible: WF.CalendarioAtencion.Activo',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'WF.CalendarioAtencion') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: WF.CalendarioAtencion.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'WF.CalendarioAtencion') AND name=N'UX_WF_CalendarioAtencion_IdCalendarioAtencion' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: WF.CalendarioAtencion.UX_WF_CalendarioAtencion_IdCalendarioAtencion',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdCalendarioAtencion","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'WF.CalendarioAtencion') AND i.name=N'UX_WF_CalendarioAtencion_IdCalendarioAtencion') THROW 51003,N'Columnas de índice incompatibles: WF.CalendarioAtencion.UX_WF_CalendarioAtencion_IdCalendarioAtencion',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'WF.CalendarioAtencion') AND i.name=N'UX_WF_CalendarioAtencion_IdCalendarioAtencion')<>1 THROW 51003,N'Número de columnas de índice incompatible: WF.CalendarioAtencion.UX_WF_CalendarioAtencion_IdCalendarioAtencion',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'WF.CalendarioAtencion') AND name=N'UX_WF_CalendarioAtencion_IdEmpresa_Codigo')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_WF_CalendarioAtencion_IdEmpresa_Codigo] ON [WF].[CalendarioAtencion] ([IdEmpresa] ASC, [Codigo] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'WF.CalendarioAtencion') AND name=N'UX_WF_CalendarioAtencion_IdEmpresa_Codigo' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: WF.CalendarioAtencion.UX_WF_CalendarioAtencion_IdEmpresa_Codigo',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"Codigo","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'WF.CalendarioAtencion') AND i.name=N'UX_WF_CalendarioAtencion_IdEmpresa_Codigo') THROW 51003,N'Columnas de índice incompatibles: WF.CalendarioAtencion.UX_WF_CalendarioAtencion_IdEmpresa_Codigo',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'WF.CalendarioAtencion') AND i.name=N'UX_WF_CalendarioAtencion_IdEmpresa_Codigo')<>2 THROW 51003,N'Número de columnas de índice incompatible: WF.CalendarioAtencion.UX_WF_CalendarioAtencion_IdEmpresa_Codigo',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'WF.CalendarioAtencion') AND name=N'UX_WF_CalendarioAtencion_IdEmpresa_IdCalendarioAtencion')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_WF_CalendarioAtencion_IdEmpresa_IdCalendarioAtencion] ON [WF].[CalendarioAtencion] ([IdEmpresa] ASC, [IdCalendarioAtencion] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'WF.CalendarioAtencion') AND name=N'UX_WF_CalendarioAtencion_IdEmpresa_IdCalendarioAtencion' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: WF.CalendarioAtencion.UX_WF_CalendarioAtencion_IdEmpresa_IdCalendarioAtencion',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"IdCalendarioAtencion","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'WF.CalendarioAtencion') AND i.name=N'UX_WF_CalendarioAtencion_IdEmpresa_IdCalendarioAtencion') THROW 51003,N'Columnas de índice incompatibles: WF.CalendarioAtencion.UX_WF_CalendarioAtencion_IdEmpresa_IdCalendarioAtencion',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'WF.CalendarioAtencion') AND i.name=N'UX_WF_CalendarioAtencion_IdEmpresa_IdCalendarioAtencion')<>2 THROW 51003,N'Número de columnas de índice incompatible: WF.CalendarioAtencion.UX_WF_CalendarioAtencion_IdEmpresa_IdCalendarioAtencion',1;
IF OBJECT_ID(N'WF.CK_EXUX_WF_CalendarioAtencion_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [WF].[CalendarioAtencion] WITH CHECK ADD CONSTRAINT [CK_EXUX_WF_CalendarioAtencion_1] CHECK (ISJSON(HorarioJson)=1);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'WF.CalendarioAtencion') AND name=N'CK_EXUX_WF_CalendarioAtencion_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'isjsonhorariojson=1') THROW 51004,N'CHECK incompatible: WF.CalendarioAtencion.CK_EXUX_WF_CalendarioAtencion_1',1;
IF OBJECT_ID(N'WF.CK_EXUX_WF_CalendarioAtencion_2',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [WF].[CalendarioAtencion] WITH CHECK ADD CONSTRAINT [CK_EXUX_WF_CalendarioAtencion_2] CHECK (ExcepcionesJson IS NULL OR ISJSON(ExcepcionesJson)=1);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'WF.CalendarioAtencion') AND name=N'CK_EXUX_WF_CalendarioAtencion_2' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'excepcionesjsonisnullorisjsonexcepcionesjson=1') THROW 51004,N'CHECK incompatible: WF.CalendarioAtencion.CK_EXUX_WF_CalendarioAtencion_2',1;

-- WF.DecisionAutorizacion | ERD EXUX
IF OBJECT_ID(N'WF.DecisionAutorizacion',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [WF].[DecisionAutorizacion] (
 [IdDecisionAutorizacion] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdEnvio] bigint NOT NULL,
 [IdRegla] bigint NOT NULL,
 [IdUsuario] int NOT NULL,
 [Decision] varchar(16) NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [Motivo] nvarchar(1000) NULL,
 [ClaveOperacion] uniqueidentifier NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_WF_DecisionAutorizacion_IdDecisionAutorizacion] PRIMARY KEY CLUSTERED ([IdDecisionAutorizacion] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdDecisionAutorizacion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdEnvio","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdRegla","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdUsuario","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Decision","type":"varchar","length":16,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Fecha","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"Motivo","type":"nvarchar","length":2000,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"ClaveOperacion","type":"uniqueidentifier","length":16,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'WF.DecisionAutorizacion',N'U')
) THROW 51001,N'Estructura incompatible: WF.DecisionAutorizacion. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'WF.DecisionAutorizacion') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: WF.DecisionAutorizacion.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'WF.DecisionAutorizacion') AND name=N'UX_WF_DecisionAutorizacion_IdDecisionAutorizacion' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: WF.DecisionAutorizacion.UX_WF_DecisionAutorizacion_IdDecisionAutorizacion',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdDecisionAutorizacion","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'WF.DecisionAutorizacion') AND i.name=N'UX_WF_DecisionAutorizacion_IdDecisionAutorizacion') THROW 51003,N'Columnas de índice incompatibles: WF.DecisionAutorizacion.UX_WF_DecisionAutorizacion_IdDecisionAutorizacion',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'WF.DecisionAutorizacion') AND i.name=N'UX_WF_DecisionAutorizacion_IdDecisionAutorizacion')<>1 THROW 51003,N'Número de columnas de índice incompatible: WF.DecisionAutorizacion.UX_WF_DecisionAutorizacion_IdDecisionAutorizacion',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'WF.DecisionAutorizacion') AND name=N'UX_WF_DecisionAutorizacion_IdEmpresa_ClaveOperacion')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_WF_DecisionAutorizacion_IdEmpresa_ClaveOperacion] ON [WF].[DecisionAutorizacion] ([IdEmpresa] ASC, [ClaveOperacion] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'WF.DecisionAutorizacion') AND name=N'UX_WF_DecisionAutorizacion_IdEmpresa_ClaveOperacion' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: WF.DecisionAutorizacion.UX_WF_DecisionAutorizacion_IdEmpresa_ClaveOperacion',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"ClaveOperacion","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'WF.DecisionAutorizacion') AND i.name=N'UX_WF_DecisionAutorizacion_IdEmpresa_ClaveOperacion') THROW 51003,N'Columnas de índice incompatibles: WF.DecisionAutorizacion.UX_WF_DecisionAutorizacion_IdEmpresa_ClaveOperacion',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'WF.DecisionAutorizacion') AND i.name=N'UX_WF_DecisionAutorizacion_IdEmpresa_ClaveOperacion')<>2 THROW 51003,N'Número de columnas de índice incompatible: WF.DecisionAutorizacion.UX_WF_DecisionAutorizacion_IdEmpresa_ClaveOperacion',1;
IF OBJECT_ID(N'WF.CK_EXUX_WF_DecisionAutorizacion_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [WF].[DecisionAutorizacion] WITH CHECK ADD CONSTRAINT [CK_EXUX_WF_DecisionAutorizacion_1] CHECK (Decision IN (''AUTORIZAR'',''RECHAZAR'',''DEVOLVER''));';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'WF.DecisionAutorizacion') AND name=N'CK_EXUX_WF_DecisionAutorizacion_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'decisionin''autorizar'',''rechazar'',''devolver''') THROW 51004,N'CHECK incompatible: WF.DecisionAutorizacion.CK_EXUX_WF_DecisionAutorizacion_1',1;

-- WF.EventoPendiente | ERD EXUX
IF OBJECT_ID(N'WF.EventoPendiente',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [WF].[EventoPendiente] (
 [IdEventoPendiente] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdOperacion] bigint NOT NULL,
 [Tipo] varchar(60) NOT NULL,
 [FechaPrevista] datetime2(7) NOT NULL,
 [Estado] varchar(16) NOT NULL,
 [ClaveOperacion] uniqueidentifier NOT NULL,
 [Intentos] int NOT NULL DEFAULT 0,
 [UltimoError] nvarchar(1000) NULL,
 [DatosJson] nvarchar(max) NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_WF_EventoPendiente_IdEventoPendiente] PRIMARY KEY CLUSTERED ([IdEventoPendiente] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdEventoPendiente","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdOperacion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Tipo","type":"varchar","length":60,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FechaPrevista","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"Estado","type":"varchar","length":16,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"ClaveOperacion","type":"uniqueidentifier","length":16,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Intentos","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"UltimoError","type":"nvarchar","length":2000,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"DatosJson","type":"nvarchar","length":-1,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'WF.EventoPendiente',N'U')
) THROW 51001,N'Estructura incompatible: WF.EventoPendiente. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'WF.EventoPendiente') AND c.name=N'Intentos' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'0') THROW 51002,N'DEFAULT incompatible: WF.EventoPendiente.Intentos',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'WF.EventoPendiente') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: WF.EventoPendiente.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'WF.EventoPendiente') AND name=N'UX_WF_EventoPendiente_IdEventoPendiente' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: WF.EventoPendiente.UX_WF_EventoPendiente_IdEventoPendiente',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEventoPendiente","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'WF.EventoPendiente') AND i.name=N'UX_WF_EventoPendiente_IdEventoPendiente') THROW 51003,N'Columnas de índice incompatibles: WF.EventoPendiente.UX_WF_EventoPendiente_IdEventoPendiente',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'WF.EventoPendiente') AND i.name=N'UX_WF_EventoPendiente_IdEventoPendiente')<>1 THROW 51003,N'Número de columnas de índice incompatible: WF.EventoPendiente.UX_WF_EventoPendiente_IdEventoPendiente',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'WF.EventoPendiente') AND name=N'UX_WF_EventoPendiente_IdEmpresa_ClaveOperacion')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_WF_EventoPendiente_IdEmpresa_ClaveOperacion] ON [WF].[EventoPendiente] ([IdEmpresa] ASC, [ClaveOperacion] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'WF.EventoPendiente') AND name=N'UX_WF_EventoPendiente_IdEmpresa_ClaveOperacion' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: WF.EventoPendiente.UX_WF_EventoPendiente_IdEmpresa_ClaveOperacion',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"ClaveOperacion","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'WF.EventoPendiente') AND i.name=N'UX_WF_EventoPendiente_IdEmpresa_ClaveOperacion') THROW 51003,N'Columnas de índice incompatibles: WF.EventoPendiente.UX_WF_EventoPendiente_IdEmpresa_ClaveOperacion',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'WF.EventoPendiente') AND i.name=N'UX_WF_EventoPendiente_IdEmpresa_ClaveOperacion')<>2 THROW 51003,N'Número de columnas de índice incompatible: WF.EventoPendiente.UX_WF_EventoPendiente_IdEmpresa_ClaveOperacion',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'WF.EventoPendiente') AND name=N'UX_WF_EventoPendiente_IdEmpresa_IdEventoPendiente')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_WF_EventoPendiente_IdEmpresa_IdEventoPendiente] ON [WF].[EventoPendiente] ([IdEmpresa] ASC, [IdEventoPendiente] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'WF.EventoPendiente') AND name=N'UX_WF_EventoPendiente_IdEmpresa_IdEventoPendiente' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: WF.EventoPendiente.UX_WF_EventoPendiente_IdEmpresa_IdEventoPendiente',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"IdEventoPendiente","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'WF.EventoPendiente') AND i.name=N'UX_WF_EventoPendiente_IdEmpresa_IdEventoPendiente') THROW 51003,N'Columnas de índice incompatibles: WF.EventoPendiente.UX_WF_EventoPendiente_IdEmpresa_IdEventoPendiente',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'WF.EventoPendiente') AND i.name=N'UX_WF_EventoPendiente_IdEmpresa_IdEventoPendiente')<>2 THROW 51003,N'Número de columnas de índice incompatible: WF.EventoPendiente.UX_WF_EventoPendiente_IdEmpresa_IdEventoPendiente',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'WF.EventoPendiente') AND name=N'IX_WF_EventoPendiente_Estado_FechaPrevista')
EXEC sys.sp_executesql N'CREATE NONCLUSTERED INDEX [IX_WF_EventoPendiente_Estado_FechaPrevista] ON [WF].[EventoPendiente] ([Estado] ASC, [FechaPrevista] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'WF.EventoPendiente') AND name=N'IX_WF_EventoPendiente_Estado_FechaPrevista' AND is_unique=0 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: WF.EventoPendiente.IX_WF_EventoPendiente_Estado_FechaPrevista',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"Estado","ordinal":1,"descending":0,"included":0},{"name":"FechaPrevista","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'WF.EventoPendiente') AND i.name=N'IX_WF_EventoPendiente_Estado_FechaPrevista') THROW 51003,N'Columnas de índice incompatibles: WF.EventoPendiente.IX_WF_EventoPendiente_Estado_FechaPrevista',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'WF.EventoPendiente') AND i.name=N'IX_WF_EventoPendiente_Estado_FechaPrevista')<>2 THROW 51003,N'Número de columnas de índice incompatible: WF.EventoPendiente.IX_WF_EventoPendiente_Estado_FechaPrevista',1;
IF OBJECT_ID(N'WF.CK_EXUX_WF_EventoPendiente_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [WF].[EventoPendiente] WITH CHECK ADD CONSTRAINT [CK_EXUX_WF_EventoPendiente_1] CHECK (Intentos >= 0);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'WF.EventoPendiente') AND name=N'CK_EXUX_WF_EventoPendiente_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'intentos>=0') THROW 51004,N'CHECK incompatible: WF.EventoPendiente.CK_EXUX_WF_EventoPendiente_1',1;
IF OBJECT_ID(N'WF.CK_EXUX_WF_EventoPendiente_2',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [WF].[EventoPendiente] WITH CHECK ADD CONSTRAINT [CK_EXUX_WF_EventoPendiente_2] CHECK (DatosJson IS NULL OR ISJSON(DatosJson)=1);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'WF.EventoPendiente') AND name=N'CK_EXUX_WF_EventoPendiente_2' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'datosjsonisnullorisjsondatosjson=1') THROW 51004,N'CHECK incompatible: WF.EventoPendiente.CK_EXUX_WF_EventoPendiente_2',1;
IF OBJECT_ID(N'WF.CK_EXUX_WF_EventoPendiente_3',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [WF].[EventoPendiente] WITH CHECK ADD CONSTRAINT [CK_EXUX_WF_EventoPendiente_3] CHECK (Estado IN (''PENDIENTE'',''PROCESANDO'',''ENVIADO'',''ERROR'',''CANCELADO''));';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'WF.EventoPendiente') AND name=N'CK_EXUX_WF_EventoPendiente_3' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'estadoin''pendiente'',''procesando'',''enviado'',''error'',''cancelado''') THROW 51004,N'CHECK incompatible: WF.EventoPendiente.CK_EXUX_WF_EventoPendiente_3',1;

-- WF.PlazoOperacion | ERD EXUX
IF OBJECT_ID(N'WF.PlazoOperacion',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [WF].[PlazoOperacion] (
 [IdPlazoOperacion] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdEnvio] bigint NOT NULL,
 [IdPoliticaSLA] bigint NOT NULL,
 [Inicio] datetime2(7) NOT NULL,
 [Limite] datetime2(7) NOT NULL,
 [MinutosPausa] int NOT NULL DEFAULT 0,
 [Cierre] datetime2(7) NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_WF_PlazoOperacion_IdPlazoOperacion] PRIMARY KEY CLUSTERED ([IdPlazoOperacion] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdPlazoOperacion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdEnvio","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdPoliticaSLA","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Inicio","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"Limite","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"MinutosPausa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Cierre","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":1,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'WF.PlazoOperacion',N'U')
) THROW 51001,N'Estructura incompatible: WF.PlazoOperacion. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'WF.PlazoOperacion') AND c.name=N'MinutosPausa' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'0') THROW 51002,N'DEFAULT incompatible: WF.PlazoOperacion.MinutosPausa',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'WF.PlazoOperacion') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: WF.PlazoOperacion.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'WF.PlazoOperacion') AND name=N'UX_WF_PlazoOperacion_IdPlazoOperacion' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: WF.PlazoOperacion.UX_WF_PlazoOperacion_IdPlazoOperacion',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdPlazoOperacion","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'WF.PlazoOperacion') AND i.name=N'UX_WF_PlazoOperacion_IdPlazoOperacion') THROW 51003,N'Columnas de índice incompatibles: WF.PlazoOperacion.UX_WF_PlazoOperacion_IdPlazoOperacion',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'WF.PlazoOperacion') AND i.name=N'UX_WF_PlazoOperacion_IdPlazoOperacion')<>1 THROW 51003,N'Número de columnas de índice incompatible: WF.PlazoOperacion.UX_WF_PlazoOperacion_IdPlazoOperacion',1;
IF OBJECT_ID(N'WF.CK_EXUX_WF_PlazoOperacion_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [WF].[PlazoOperacion] WITH CHECK ADD CONSTRAINT [CK_EXUX_WF_PlazoOperacion_1] CHECK (Limite >= Inicio AND MinutosPausa >= 0 AND (Cierre IS NULL OR Cierre >= Inicio));';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'WF.PlazoOperacion') AND name=N'CK_EXUX_WF_PlazoOperacion_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'limite>=inicioandminutospausa>=0andcierreisnullorcierre>=inicio') THROW 51004,N'CHECK incompatible: WF.PlazoOperacion.CK_EXUX_WF_PlazoOperacion_1',1;

-- WF.PoliticaSLA | ERD EXUX
IF OBJECT_ID(N'WF.PoliticaSLA',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [WF].[PoliticaSLA] (
 [IdPoliticaSLA] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdTemplate] int NOT NULL,
 [IdCalendario] bigint NOT NULL,
 [Etapa] nvarchar(60) NOT NULL,
 [PlazoMinutos] int NOT NULL,
 [EscalamientoJson] nvarchar(max) NULL,
 [Version] int NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_WF_PoliticaSLA_IdPoliticaSLA] PRIMARY KEY CLUSTERED ([IdPoliticaSLA] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdPoliticaSLA","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdTemplate","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdCalendario","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Etapa","type":"nvarchar","length":120,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"PlazoMinutos","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"EscalamientoJson","type":"nvarchar","length":-1,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Version","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'WF.PoliticaSLA',N'U')
) THROW 51001,N'Estructura incompatible: WF.PoliticaSLA. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'WF.PoliticaSLA') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: WF.PoliticaSLA.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'WF.PoliticaSLA') AND name=N'UX_WF_PoliticaSLA_IdPoliticaSLA' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: WF.PoliticaSLA.UX_WF_PoliticaSLA_IdPoliticaSLA',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdPoliticaSLA","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'WF.PoliticaSLA') AND i.name=N'UX_WF_PoliticaSLA_IdPoliticaSLA') THROW 51003,N'Columnas de índice incompatibles: WF.PoliticaSLA.UX_WF_PoliticaSLA_IdPoliticaSLA',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'WF.PoliticaSLA') AND i.name=N'UX_WF_PoliticaSLA_IdPoliticaSLA')<>1 THROW 51003,N'Número de columnas de índice incompatible: WF.PoliticaSLA.UX_WF_PoliticaSLA_IdPoliticaSLA',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'WF.PoliticaSLA') AND name=N'UX_WF_PoliticaSLA_IdTemplate_Etapa_Version')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_WF_PoliticaSLA_IdTemplate_Etapa_Version] ON [WF].[PoliticaSLA] ([IdTemplate] ASC, [Etapa] ASC, [Version] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'WF.PoliticaSLA') AND name=N'UX_WF_PoliticaSLA_IdTemplate_Etapa_Version' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: WF.PoliticaSLA.UX_WF_PoliticaSLA_IdTemplate_Etapa_Version',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdTemplate","ordinal":1,"descending":0,"included":0},{"name":"Etapa","ordinal":2,"descending":0,"included":0},{"name":"Version","ordinal":3,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'WF.PoliticaSLA') AND i.name=N'UX_WF_PoliticaSLA_IdTemplate_Etapa_Version') THROW 51003,N'Columnas de índice incompatibles: WF.PoliticaSLA.UX_WF_PoliticaSLA_IdTemplate_Etapa_Version',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'WF.PoliticaSLA') AND i.name=N'UX_WF_PoliticaSLA_IdTemplate_Etapa_Version')<>3 THROW 51003,N'Número de columnas de índice incompatible: WF.PoliticaSLA.UX_WF_PoliticaSLA_IdTemplate_Etapa_Version',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'WF.PoliticaSLA') AND name=N'UX_WF_PoliticaSLA_IdEmpresa_IdPoliticaSLA')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_WF_PoliticaSLA_IdEmpresa_IdPoliticaSLA] ON [WF].[PoliticaSLA] ([IdEmpresa] ASC, [IdPoliticaSLA] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'WF.PoliticaSLA') AND name=N'UX_WF_PoliticaSLA_IdEmpresa_IdPoliticaSLA' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: WF.PoliticaSLA.UX_WF_PoliticaSLA_IdEmpresa_IdPoliticaSLA',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"IdPoliticaSLA","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'WF.PoliticaSLA') AND i.name=N'UX_WF_PoliticaSLA_IdEmpresa_IdPoliticaSLA') THROW 51003,N'Columnas de índice incompatibles: WF.PoliticaSLA.UX_WF_PoliticaSLA_IdEmpresa_IdPoliticaSLA',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'WF.PoliticaSLA') AND i.name=N'UX_WF_PoliticaSLA_IdEmpresa_IdPoliticaSLA')<>2 THROW 51003,N'Número de columnas de índice incompatible: WF.PoliticaSLA.UX_WF_PoliticaSLA_IdEmpresa_IdPoliticaSLA',1;
IF OBJECT_ID(N'WF.CK_EXUX_WF_PoliticaSLA_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [WF].[PoliticaSLA] WITH CHECK ADD CONSTRAINT [CK_EXUX_WF_PoliticaSLA_1] CHECK (PlazoMinutos > 0 AND Version > 0);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'WF.PoliticaSLA') AND name=N'CK_EXUX_WF_PoliticaSLA_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'plazominutos>0andversion>0') THROW 51004,N'CHECK incompatible: WF.PoliticaSLA.CK_EXUX_WF_PoliticaSLA_1',1;
IF OBJECT_ID(N'WF.CK_EXUX_WF_PoliticaSLA_2',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [WF].[PoliticaSLA] WITH CHECK ADD CONSTRAINT [CK_EXUX_WF_PoliticaSLA_2] CHECK (EscalamientoJson IS NULL OR ISJSON(EscalamientoJson)=1);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'WF.PoliticaSLA') AND name=N'CK_EXUX_WF_PoliticaSLA_2' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'escalamientojsonisnullorisjsonescalamientojson=1') THROW 51004,N'CHECK incompatible: WF.PoliticaSLA.CK_EXUX_WF_PoliticaSLA_2',1;

-- WF.ReglaAutorizacion | ERD EXUX
IF OBJECT_ID(N'WF.ReglaAutorizacion',N'U') IS NULL
EXEC sys.sp_executesql N'CREATE TABLE [WF].[ReglaAutorizacion] (
 [IdReglaAutorizacion] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdTemplate] int NOT NULL,
 [IdSucursal] int NULL,
 [RoleId] nvarchar(256) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Nivel] int NOT NULL,
 [Version] int NOT NULL,
 [MontoDesde] decimal(20,4) NOT NULL,
 [MontoHasta] decimal(20,4) NULL,
 [Desde] date NOT NULL,
 [Hasta] date NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_WF_ReglaAutorizacion_IdReglaAutorizacion] PRIMARY KEY CLUSTERED ([IdReglaAutorizacion] ASC)
);';
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"IdReglaAutorizacion","type":"bigint","length":8,"precision":19,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"IdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdTemplate","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"IdSucursal","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"RoleId","type":"nvarchar","length":512,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Nivel","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Version","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"MontoDesde","type":"decimal","length":13,"precision":20,"scale":4,"nullable":0,"identity":0,"computed":0},{"name":"MontoHasta","type":"decimal","length":13,"precision":20,"scale":4,"nullable":1,"identity":0,"computed":0},{"name":"Desde","type":"date","length":3,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Hasta","type":"date","length":3,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CreadoUtc","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":0,"identity":0,"computed":0},{"name":"VersionFila","type":"timestamp","length":8,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'WF.ReglaAutorizacion',N'U')
) THROW 51001,N'Estructura incompatible: WF.ReglaAutorizacion. No se modifica ni sustituye automáticamente.',1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID(N'WF.ReglaAutorizacion') AND c.name=N'CreadoUtc' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(d.definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'sysutcdatetime') THROW 51002,N'DEFAULT incompatible: WF.ReglaAutorizacion.CreadoUtc',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'WF.ReglaAutorizacion') AND name=N'UX_WF_ReglaAutorizacion_IdReglaAutorizacion' AND is_unique=1 AND is_primary_key=1 AND type_desc=N'CLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: WF.ReglaAutorizacion.UX_WF_ReglaAutorizacion_IdReglaAutorizacion',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdReglaAutorizacion","ordinal":1,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'WF.ReglaAutorizacion') AND i.name=N'UX_WF_ReglaAutorizacion_IdReglaAutorizacion') THROW 51003,N'Columnas de índice incompatibles: WF.ReglaAutorizacion.UX_WF_ReglaAutorizacion_IdReglaAutorizacion',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'WF.ReglaAutorizacion') AND i.name=N'UX_WF_ReglaAutorizacion_IdReglaAutorizacion')<>1 THROW 51003,N'Número de columnas de índice incompatible: WF.ReglaAutorizacion.UX_WF_ReglaAutorizacion_IdReglaAutorizacion',1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'WF.ReglaAutorizacion') AND name=N'UX_WF_ReglaAutorizacion_IdEmpresa_IdReglaAutorizacion')
EXEC sys.sp_executesql N'CREATE UNIQUE NONCLUSTERED INDEX [UX_WF_ReglaAutorizacion_IdEmpresa_IdReglaAutorizacion] ON [WF].[ReglaAutorizacion] ([IdEmpresa] ASC, [IdReglaAutorizacion] ASC);';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'WF.ReglaAutorizacion') AND name=N'UX_WF_ReglaAutorizacion_IdEmpresa_IdReglaAutorizacion' AND is_unique=1 AND is_primary_key=0 AND type_desc=N'NONCLUSTERED' AND is_disabled=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(filter_definition,N''),N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'') THROW 51003,N'Índice incompatible: WF.ReglaAutorizacion.UX_WF_ReglaAutorizacion_IdEmpresa_IdReglaAutorizacion',1;
IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON(N'[{"name":"IdEmpresa","ordinal":1,"descending":0,"included":0},{"name":"IdReglaAutorizacion","ordinal":2,"descending":0,"included":0}]') WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID(N'WF.ReglaAutorizacion') AND i.name=N'UX_WF_ReglaAutorizacion_IdEmpresa_IdReglaAutorizacion') THROW 51003,N'Columnas de índice incompatibles: WF.ReglaAutorizacion.UX_WF_ReglaAutorizacion_IdEmpresa_IdReglaAutorizacion',1;
IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID(N'WF.ReglaAutorizacion') AND i.name=N'UX_WF_ReglaAutorizacion_IdEmpresa_IdReglaAutorizacion')<>2 THROW 51003,N'Número de columnas de índice incompatible: WF.ReglaAutorizacion.UX_WF_ReglaAutorizacion_IdEmpresa_IdReglaAutorizacion',1;
IF OBJECT_ID(N'WF.CK_EXUX_WF_ReglaAutorizacion_1',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [WF].[ReglaAutorizacion] WITH CHECK ADD CONSTRAINT [CK_EXUX_WF_ReglaAutorizacion_1] CHECK (Nivel > 0 AND Version > 0 AND MontoDesde >= 0 AND (MontoHasta IS NULL OR MontoHasta >= MontoDesde));';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'WF.ReglaAutorizacion') AND name=N'CK_EXUX_WF_ReglaAutorizacion_1' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'nivel>0andversion>0andmontodesde>=0andmontohastaisnullormontohasta>=montodesde') THROW 51004,N'CHECK incompatible: WF.ReglaAutorizacion.CK_EXUX_WF_ReglaAutorizacion_1',1;
IF OBJECT_ID(N'WF.CK_EXUX_WF_ReglaAutorizacion_2',N'C') IS NULL
EXEC sys.sp_executesql N'ALTER TABLE [WF].[ReglaAutorizacion] WITH CHECK ADD CONSTRAINT [CK_EXUX_WF_ReglaAutorizacion_2] CHECK (Hasta IS NULL OR Hasta >= Desde);';
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'WF.ReglaAutorizacion') AND name=N'CK_EXUX_WF_ReglaAutorizacion_2' AND is_disabled=0 AND is_not_trusted=0 AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(definition,N' ',N''),N'[',N''),N']',N''),N'(',N''),N')',N''),N'',N''),N'
',N''),N'	',N''))=N'hastaisnullorhasta>=desde') THROW 51004,N'CHECK incompatible: WF.ReglaAutorizacion.CK_EXUX_WF_ReglaAutorizacion_2',1;
COMMIT TRANSACTION;
END TRY
BEGIN CATCH
 IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;
PRINT N'FASE A completa: Workflow_Notificaciones. Relaciones pendientes en 02_Relaciones.sql.';
