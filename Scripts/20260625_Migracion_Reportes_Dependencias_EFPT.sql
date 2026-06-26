USE [GestionEmpresarial];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF SCHEMA_ID(N'RHCT') IS NULL
    EXEC(N'CREATE SCHEMA [RHCT]');
GO

IF OBJECT_ID(N'[SIS].[Reporte]', N'U') IS NULL
BEGIN
    CREATE TABLE [SIS].[Reporte](
        [Pk_IdReporte] [int] IDENTITY(1,1) NOT NULL,
        [Nombre] [varchar](50) NOT NULL,
        [Descripcion] [varchar](250) NOT NULL,
        [Controlador] [varchar](50) NULL,
        [Fk_IdTipoFirma] [int] NOT NULL,
        [UsuarioCreacion] [int] NOT NULL,
        [FechaCreacion] [datetime2](6) NOT NULL CONSTRAINT [DF_SIS_Reporte_FechaCreacion] DEFAULT (sysdatetime()),
        [UsuarioModificacion] [int] NULL,
        [FechaModificacion] [datetime2](6) NULL,
        [Activo] [bit] NOT NULL CONSTRAINT [DF_SIS_Reporte_Activo] DEFAULT ((1)),
        CONSTRAINT [PK_SIS_Reporte] PRIMARY KEY CLUSTERED ([Pk_IdReporte] ASC)
    );
END;
GO

IF OBJECT_ID(N'[SIS].[FirmaAutorizada]', N'U') IS NULL
BEGIN
    CREATE TABLE [SIS].[FirmaAutorizada](
        [Pk_IdFirmaAutorizada] [int] IDENTITY(1,1) NOT NULL,
        [Fk_IdReporte__SIS] [int] NOT NULL,
        [Fk_IdPersona__RHCT] [int] NULL,
        [Funcion] [varchar](100) NOT NULL,
        [UsuarioCreacion] [int] NOT NULL,
        [FechaCreacion] [datetime2](6) NOT NULL CONSTRAINT [DF_SIS_FirmaAutorizada_FechaCreacion] DEFAULT (sysdatetime()),
        [UsuarioModificacion] [int] NULL,
        [FechaModificacion] [datetime2](6) NULL,
        [Activo] [bit] NOT NULL CONSTRAINT [DF_SIS_FirmaAutorizada_Activo] DEFAULT ((1)),
        CONSTRAINT [PK_SIS_FirmaAutorizada] PRIMARY KEY CLUSTERED ([Pk_IdFirmaAutorizada] ASC)
    );
END;
GO

IF DB_ID(N'BD_PRESUPUESTO') IS NOT NULL
   AND OBJECT_ID(N'BD_PRESUPUESTO.SIS.Reporte', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM [SIS].[Reporte])
BEGIN
    SET IDENTITY_INSERT [SIS].[Reporte] ON;

    INSERT INTO [SIS].[Reporte]
        ([Pk_IdReporte], [Nombre], [Descripcion], [Controlador], [Fk_IdTipoFirma],
         [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT
        src.[Pk_IdReporte],
        src.[Nombre],
        src.[Descripcion],
        src.[Controlador],
        src.[Fk_IdTipoFirma],
        src.[CT_CreatedBy],
        CONVERT(datetime2(6), src.[CT_CreatedDate]),
        src.[CT_ModifiedBy],
        CONVERT(datetime2(6), src.[CT_ModifiedDate]),
        CONVERT(bit, src.[CT_LIVE])
    FROM [BD_PRESUPUESTO].[SIS].[Reporte] AS src;

    SET IDENTITY_INSERT [SIS].[Reporte] OFF;

    DECLARE @MaxReporte int = ISNULL((SELECT MAX([Pk_IdReporte]) FROM [SIS].[Reporte]), 0);
    DBCC CHECKIDENT ('[SIS].[Reporte]', RESEED, @MaxReporte) WITH NO_INFOMSGS;
END;
GO

IF DB_ID(N'BD_PRESUPUESTO') IS NOT NULL
   AND OBJECT_ID(N'BD_PRESUPUESTO.SIS.FirmaAutorizada', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM [SIS].[FirmaAutorizada])
BEGIN
    SET IDENTITY_INSERT [SIS].[FirmaAutorizada] ON;

    INSERT INTO [SIS].[FirmaAutorizada]
        ([Pk_IdFirmaAutorizada], [Fk_IdReporte__SIS], [Fk_IdPersona__RHCT], [Funcion],
         [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT
        src.[Pk_IdFirmaAutorizada],
        src.[Fk_IdReporte__SIS],
        src.[Fk_IdPersona__RHCT],
        src.[Funcion],
        src.[CT_CreatedBy],
        CONVERT(datetime2(6), src.[CT_CreatedDate]),
        src.[CT_ModifiedBy],
        CONVERT(datetime2(6), src.[CT_ModifiedDate]),
        CONVERT(bit, src.[CT_LIVE])
    FROM [BD_PRESUPUESTO].[SIS].[FirmaAutorizada] AS src;

    SET IDENTITY_INSERT [SIS].[FirmaAutorizada] OFF;

    DECLARE @MaxFirma int = ISNULL((SELECT MAX([Pk_IdFirmaAutorizada]) FROM [SIS].[FirmaAutorizada]), 0);
    DBCC CHECKIDENT ('[SIS].[FirmaAutorizada]', RESEED, @MaxFirma) WITH NO_INFOMSGS;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_SIS_Reporte_Controlador_Activo' AND object_id = OBJECT_ID(N'[SIS].[Reporte]'))
    CREATE INDEX [IX_SIS_Reporte_Controlador_Activo] ON [SIS].[Reporte] ([Controlador], [Activo]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_SIS_FirmaAutorizada_Reporte_Activo' AND object_id = OBJECT_ID(N'[SIS].[FirmaAutorizada]'))
    CREATE INDEX [IX_SIS_FirmaAutorizada_Reporte_Activo] ON [SIS].[FirmaAutorizada] ([Fk_IdReporte__SIS], [Activo]);
GO

CREATE OR ALTER VIEW [RHCT].[Persona]
AS
SELECT
    p.[PKIdPersona] AS [PK_IdPersona],
    p.[Clave],
    p.[Nombre],
    p.[Paterno],
    p.[Materno],
    p.[Telefono_particular],
    p.[Telefono_movil],
    p.[Fecha_de_Inicio],
    p.[Fecha_Fin],
    p.[RFC],
    p.[Curp],
    p.[FechaNacimiento],
    p.[Sexo],
    p.[ESTADO_CIVIL],
    p.[Municipio],
    p.[REG_IMSS],
    p.[NoCartilla],
    p.[NoLicencia],
    p.[NoPasaporte],
    p.[NoCredencialElector],
    p.[Calle],
    p.[Num_exterior],
    p.[Num_interior],
    p.[Colonia],
    p.[CP],
    p.[Estado],
    p.[CORREO_ELECTRONICO],
    p.[TIPO_CONTRATACION],
    p.[PUESTO] AS [Puesto],
    p.[SUELDO_BASE],
    p.[COMPENSACION_GARANTIZADA],
    p.[BANCO],
    p.[NUMERO_CUENTA],
    p.[CLABE],
    p.[UsuarioCreacion],
    p.[FechaCreacion],
    p.[UsuarioModificacion],
    p.[FechaModificacion],
    p.[Activo],
    p.[UsuarioCreacion] AS [CT_CreatedBy],
    CONVERT(datetime, p.[FechaCreacion]) AS [CT_CreatedDate],
    p.[UsuarioModificacion] AS [CT_ModifiedBy],
    CONVERT(datetime, p.[FechaModificacion]) AS [CT_ModifiedDate],
    p.[Activo] AS [CT_LIVE]
FROM [NOM].[Persona] AS p;
GO

CREATE OR ALTER VIEW [RHCT].[PersonaPlaza]
AS
SELECT
    pp.[PKIdPersonaPlaza] AS [PK_IdPersonaPlaza],
    pp.[FKIdPersona_NOM] AS [FK_IdPersona__RHCT],
    pp.[FKIdPersona_NOM] AS [FK_IdPersona__RH],
    pp.[FKIdPlazaAutorizada_NOM] AS [FK_IdPlazaAutorizada__RHCT],
    pp.[FKIdPlazaAutorizada_NOM] AS [FK_IdPlazaAutorizada__RH],
    pp.[FKIdSituacionPersona_RH] AS [FK_IdSituacionPersona__RH],
    pp.[FKIdNombramiento_NOM] AS [FK_IdNombramiento__RH],
    pp.[FKIdPuesto_NOM] AS [FK_IdPuesto__RH],
    pp.[FKIdMotivoMovimiento_NOM] AS [FK_IdMotivoMovto__RH],
    pp.[ZonaEconomica],
    pp.[FechaInicio],
    pp.[FechaFin],
    pp.[Horas],
    pp.[QuincenaInicio],
    pp.[QuincenaFin],
    pp.[Documento],
    pp.[FormaPago],
    pp.[ChecaTarjeta],
    pp.[UsuarioCreacion],
    pp.[FechaCreacion],
    pp.[UsuarioModificacion],
    pp.[FechaModificacion],
    pp.[Activo],
    pp.[UsuarioCreacion] AS [CT_CreatedBy],
    CONVERT(datetime, pp.[FechaCreacion]) AS [CT_CreatedDate],
    pp.[UsuarioModificacion] AS [CT_ModifiedBy],
    CONVERT(datetime, pp.[FechaModificacion]) AS [CT_ModifiedDate],
    pp.[Activo] AS [CT_LIVE]
FROM [NOM].[PersonaPlaza] AS pp;
GO

CREATE OR ALTER VIEW [RHCT].[PlazaAutorizada]
AS
SELECT
    pa.[PKIdPlazaAutorizada] AS [PK_IdPlazaAutorizada],
    pa.[FKIdPuesto_NOM] AS [FK_IdPuesto__RHCT],
    pa.[FKIdPuesto_NOM] AS [FK_IdPuesto__RH],
    pa.[FKIdArea_SIS] AS [Fk_IdArea__SIS],
    pa.[FKIdSituacionPlaza_RH] AS [Fk_IdSituacionPlaza__RH],
    pa.[Plaza],
    pa.[FechaInicio],
    pa.[FechaFin],
    pa.[TipoPlaza],
    pa.[Documento],
    pa.[FechaDocumento],
    pa.[Descripcion],
    pa.[FKIdEmpresa_SIS] AS [Fk_IdEmpresa__EMP],
    pa.[UsuarioCreacion],
    pa.[FechaCreacion],
    pa.[UsuarioModificacion],
    pa.[FechaModificacion],
    pa.[Activo],
    pa.[UsuarioCreacion] AS [CT_CreatedBy],
    CONVERT(datetime, pa.[FechaCreacion]) AS [CT_CreatedDate],
    pa.[UsuarioModificacion] AS [CT_ModifiedBy],
    CONVERT(datetime, pa.[FechaModificacion]) AS [CT_ModifiedDate],
    pa.[Activo] AS [CT_LIVE]
FROM [NOM].[PlazaAutorizada] AS pa;
GO

CREATE OR ALTER VIEW [RHCT].[Puesto]
AS
SELECT
    pu.[PKIdPuesto] AS [PK_IdPuesto],
    pu.[FKIdPuestoPadre_NOM] AS [Fk_IdPuesto__RH],
    pu.[FKIdEmpresa_SIS] AS [Fk_IdEmpresa__EMP],
    pu.[Nombre],
    pu.[FKIdNivel_NOM] AS [Fk_IdNivel__RH],
    pu.[FKIdClasePuesto_NOM] AS [Fk_IdClasePuesto__RH],
    pu.[Descripcion1],
    pu.[Descripcion2],
    pu.[Orden],
    pu.[UsuarioCreacion],
    pu.[FechaCreacion],
    pu.[UsuarioModificacion],
    pu.[FechaModificacion],
    pu.[Activo],
    pu.[UsuarioCreacion] AS [CT_CreatedBy],
    CONVERT(datetime, pu.[FechaCreacion]) AS [CT_CreatedDate],
    pu.[UsuarioModificacion] AS [CT_ModifiedBy],
    CONVERT(datetime, pu.[FechaModificacion]) AS [CT_ModifiedDate],
    pu.[Activo] AS [CT_LIVE]
FROM [NOM].[Puesto] AS pu;
GO

CREATE OR ALTER VIEW [SICOP].[GrupoBien]
AS
SELECT
    gb.[PKIdGrupoBien] AS [PK_IdGrupoBien],
    gb.[FKIdFamilia_ALMA] AS [FK_IdFamilia__SICOP],
    gb.[Descripcion],
    gb.[Clave],
    gb.[ClaveAN],
    gb.[CABM_ACT],
    gb.[CLAVE_CUCOP],
    gb.[MEDIDA],
    gb.[Activo],
    gb.[UsuarioCreacion] AS [CT_CreatedBy],
    CONVERT(datetime, gb.[FechaCreacion]) AS [CT_CreatedDate],
    gb.[UsuarioModificacion] AS [CT_ModifiedBy],
    CONVERT(datetime, gb.[FechaModificacion]) AS [CT_ModifiedDate],
    gb.[Activo] AS [CT_LIVE]
FROM [ALMA].[GrupoBien] AS gb;
GO

CREATE OR ALTER VIEW [SICOP].[TipoBien]
AS
SELECT
    tb.[PKIdTipoBien] AS [PK_IdTipoBien],
    tb.[FKIdGrupoBien_ALMA] AS [FK_IdGrupoBien__SICOP],
    tb.[FKIdNivel_ALMA] AS [FK_IdNivel__SICOP],
    tb.[FKIdPartida_CONTA] AS [FK_IdPartida__SIS],
    tb.[FKIdCuentaContable_CONTA] AS [FK_IdCuentaContable__SIS],
    tb.[CodigoClave],
    tb.[Descripcion],
    tb.[DepreciacionAnual],
    tb.[Consecutivo],
    tb.[CABMS],
    tb.[Identificador],
    tb.[ExistenciaMinima],
    tb.[ExistenciaMaxima],
    tb.[TiempoVida],
    tb.[FKIdUnidades_ALMA] AS [FK_IdUnidades__ALMA],
    tb.[FKIdLocalizacion_ALMA] AS [FK_IdLocalizacion__ALMA],
    tb.[Pk_IdTratadoInt],
    tb.[Cuota],
    tb.[ProveeduriaNac],
    tb.[CatalogoBasico],
    tb.[CUCOP_PLUS],
    tb.[Cantidad_Equivalente],
    tb.[FKIdUnidades_Equivalente] AS [FK_IdUnidades_Equivalente],
    tb.[Activo],
    tb.[UsuarioCreacion] AS [CT_CreatedBy],
    CONVERT(datetime, tb.[FechaCreacion]) AS [CT_CreatedDate],
    tb.[UsuarioModificacion] AS [CT_ModifiedBy],
    CONVERT(datetime, tb.[FechaModificacion]) AS [CT_ModifiedDate],
    tb.[Activo] AS [CT_LIVE]
FROM [ALMA].[TipoBien] AS tb;
GO

CREATE OR ALTER VIEW [SICOP].[Marca]
AS
SELECT
    m.[PKIdMarca] AS [PK_IdMarca],
    m.[Descripcion],
    m.[Activo],
    m.[UsuarioCreacion] AS [CT_CreatedBy],
    CONVERT(datetime, m.[FechaCreacion]) AS [CT_CreatedDate],
    m.[UsuarioModificacion] AS [CT_ModifiedBy],
    CONVERT(datetime, m.[FechaModificacion]) AS [CT_ModifiedDate],
    m.[Activo] AS [CT_LIVE]
FROM [ALMA].[Marca] AS m;
GO

CREATE OR ALTER VIEW [SICOP].[EstadoBien]
AS
SELECT
    eb.[PKIdEstadoBien] AS [PK_IdEstadoBien],
    eb.[DESCRIPCION_GENERAL],
    eb.[DESCRIPCION_ESPECIFICA],
    eb.[DESCRIPCION_CORTA],
    eb.[Activo],
    eb.[UsuarioCreacion] AS [CT_CreatedBy],
    CONVERT(datetime, eb.[FechaCreacion]) AS [CT_CreatedDate],
    eb.[UsuarioModificacion] AS [CT_ModifiedBy],
    CONVERT(datetime, eb.[FechaModificacion]) AS [CT_ModifiedDate],
    eb.[Activo] AS [CT_LIVE]
FROM [ALMA].[EstadoBien] AS eb;
GO

CREATE OR ALTER VIEW [SICOP].[TipoPatrimonio]
AS
SELECT
    tp.[PKIdTipoPatrimonio] AS [PK_IdTipoPatrimonio],
    tp.[Descripcion],
    tp.[Activo],
    tp.[UsuarioCreacion] AS [CT_CreatedBy],
    CONVERT(datetime, tp.[FechaCreacion]) AS [CT_CreatedDate],
    tp.[UsuarioModificacion] AS [CT_ModifiedBy],
    CONVERT(datetime, tp.[FechaModificacion]) AS [CT_ModifiedDate],
    tp.[Activo] AS [CT_LIVE]
FROM [ALMA].[TipoPatrimonio] AS tp;
GO

CREATE OR ALTER VIEW [SICOP].[Material]
AS
SELECT
    ma.[PKIdMaterial] AS [PK_IdMaterial],
    ma.[Descripcion],
    ma.[Activo],
    ma.[UsuarioCreacion] AS [CT_CreatedBy],
    CONVERT(datetime, ma.[FechaCreacion]) AS [CT_CreatedDate],
    ma.[UsuarioModificacion] AS [CT_ModifiedBy],
    CONVERT(datetime, ma.[FechaModificacion]) AS [CT_ModifiedDate],
    ma.[Activo] AS [CT_LIVE]
FROM [ALMA].[Material] AS ma;
GO

CREATE OR ALTER VIEW [SICOP].[TipoAdq]
AS
SELECT
    ta.[PKIdTipoAdq] AS [PK_IdTipoAdq],
    ta.[Clave],
    ta.[Descripcion],
    ta.[Descripmovto],
    ta.[Activo],
    ta.[UsuarioCreacion] AS [CT_CreatedBy],
    CONVERT(datetime, ta.[FechaCreacion]) AS [CT_CreatedDate],
    ta.[UsuarioModificacion] AS [CT_ModifiedBy],
    CONVERT(datetime, ta.[FechaModificacion]) AS [CT_ModifiedDate],
    ta.[Activo] AS [CT_LIVE]
FROM [ALMA].[TipoAdquisicion] AS ta;
GO

CREATE OR ALTER VIEW [SICOP].[Bajas]
AS
SELECT
    b.[PKIdBaja] AS [PK_IdBajas],
    b.[FKIdBien_ALMA] AS [FK_IdBien__SICOP],
    b.[FKIdEstadoBienDestino_ALMA] AS [FK_IdDestinoFinal__SICOP],
    CONVERT(datetime, b.[FechaBaja]) AS [FechaBaja],
    b.[Referencia],
    CONVERT(datetime, b.[FechaReferencia]) AS [FechaRef],
    b.[Destinatario],
    b.[Recibo],
    b.[Cantidad],
    b.[Motivo] AS [Comentario],
    b.[FKIdPoliza_CONTA] AS [Fk_IdPoliza__CONTA],
    b.[Activo],
    b.[UsuarioCreacion] AS [CT_CreatedBy],
    CONVERT(datetime, b.[FechaCreacion]) AS [CT_CreatedDate],
    b.[UsuarioModificacion] AS [CT_ModifiedBy],
    CONVERT(datetime, b.[FechaModificacion]) AS [CT_ModifiedDate],
    b.[Activo] AS [CT_LIVE]
FROM [ALMA].[Bajas] AS b;
GO

CREATE OR ALTER VIEW [SICOP].[Bien]
AS
SELECT
    b.[PKIdBien] AS [PK_IdBien],
    b.[Clave],
    b.[ClaveAnt],
    b.[FKIdGrupoBien_ALMA] AS [FK_IdGrupoBien__SICOP],
    b.[FKIdTipoBien_ALMA] AS [FK_IdTipoBien__SICOP],
    b.[FKIdArea_SIS] AS [FK_IdArea__SIS],
    b.[Descripcion],
    b.[FKIdMarca_ALMA] AS [FK_IdMarca__SICOP],
    b.[Modelo],
    b.[Serie],
    b.[FKIdProveedor_SIS] AS [FK_IdProveedor__SIS],
    b.[Requisicion],
    b.[Factura],
    b.[Costo],
    b.[FKIdEstadoBien_ALMA] AS [FK_IdEstadoBien__SICOP],
    b.[FechaAdq],
    b.[Referencia],
    b.[Notas],
    b.[Resguardo] AS [FK_IdPersona__RHCT],
    b.[Ubicacion],
    b.[FKIdTipoPatrimonio_ALMA] AS [FK_IdTipoPatrimonio__SICOP],
    b.[AAdquisicion],
    CAST(NULL AS nvarchar(2000)) AS [FL_FOTO],
    b.[FKIdMaterial_ALMA] AS [FK_IdMaterial__SICOP],
    CAST(NULL AS int) AS [FK_IdColor__SICOP],
    b.[Frente],
    b.[Fondo],
    b.[Altura],
    b.[Diametro],
    b.[VerificacionesDias],
    b.[MantenimientoDias],
    b.[Mantenimiento],
    b.[Calibracion],
    b.[Rango],
    b.[Resolucion],
    b.[FKIdArea_SIS] AS [FK_IdAreaUlt__SIS],
    b.[FechaUltInv],
    b.[FKIdPartida_CONTA] AS [FK_IdPartida__SIS],
    b.[FKIdTipoAdq_ALMA] AS [FK_IdTipoAdq__SICOP],
    b.[FechaReqscn],
    CAST(NULL AS nvarchar(2000)) AS [FL_Factura],
    b.[Estatus],
    b.[Caracteristicas],
    b.[Resguardo],
    b.[ResguardoAnterior],
    b.[RelId],
    b.[ValorRescate],
    b.[ValorActual],
    b.[Antiguedad],
    b.[Progresivo],
    b.[Consecutivo],
    b.[FKIdDetalleOrdenCompra_ORCO] AS [FK_IdDetalleOrdenCompra__ORCO],
    b.[ClaveHist],
    b.[EstaResguardado],
    b.[FechaResguardado],
    b.[Localizado],
    b.[esContabilizado],
    b.[Activo],
    b.[UsuarioCreacion] AS [CT_CreatedBy],
    CONVERT(datetime, b.[FechaCreacion]) AS [CT_CreatedDate],
    b.[UsuarioModificacion] AS [CT_ModifiedBy],
    CONVERT(datetime, b.[FechaModificacion]) AS [CT_ModifiedDate],
    b.[Activo] AS [CT_LIVE]
FROM [ALMA].[Bien] AS b;
GO

CREATE OR ALTER VIEW [SICOP].[VW_Bien]
AS
SELECT * FROM [SICOP].[Bien];
GO

CREATE OR ALTER VIEW [dbo].[pivotBien]
AS
SELECT
    B.[Clave],
    B.[ClaveAnt],
    GB.[Descripcion] AS [GrupoBien],
    TB.[Descripcion] AS [TipoBien],
    A.[Nombre] AS [Area],
    B.[Descripcion],
    M.[Descripcion] AS [Marca],
    ISNULL(B.[Modelo], N'----') AS [Modelo],
    B.[Factura],
    ISNULL(B.[Requisicion], N'----') AS [Requisicion],
    ISNULL(P.[Nombre], N'SIN PROVEEDOR') AS [Proveedor],
    B.[Costo],
    EB.[DESCRIPCION_GENERAL] AS [Estadobien],
    B.[FechaAdq],
    ISNULL(B.[Referencia], N'-----') AS [Referencia],
    ISNULL(B.[Notas], N'--') AS [Notas],
    NULLIF(CONCAT(PE.[Nombre], N' ', PE.[Paterno], N' ', PE.[Materno]), N'  ') AS [Persona],
    ISNULL(B.[Serie], N'S/S') AS [Serie],
    ISNULL(B.[Ubicacion], N'----') AS [Ubicacion],
    TP.[Descripcion] AS [TipoPatrimonio],
    B.[AAdquisicion],
    MAT.[Descripcion] AS [Material],
    CAST(NULL AS nvarchar(50)) AS [Color],
    ISNULL(CAST(B.[Frente] AS varchar(30)), '----') AS [Frente],
    ISNULL(CAST(B.[Fondo] AS varchar(30)), '----') AS [Fondo],
    ISNULL(CAST(B.[Altura] AS varchar(30)), '----') AS [Altura],
    ISNULL(CAST(B.[Diametro] AS varchar(30)), '----') AS [Diametro],
    B.[VerificacionesDias],
    B.[MantenimientoDias],
    B.[Mantenimiento],
    B.[Calibracion],
    ISNULL(B.[Rango], N'----') AS [Rango],
    ISNULL(B.[Resolucion], N'----') AS [Resolucion],
    B.[FK_IdAreaUlt__SIS],
    B.[FechaUltInv],
    ISNULL(CONCAT(PA.[Clave], N'-', PA.[Descripcion]), N'---------') AS [Partida],
    ISNULL(TA.[Descripcion], N'----------') AS [TipoAdq],
    B.[FechaReqscn],
    B.[Caracteristicas],
    B.[Resguardo],
    B.[ResguardoAnterior],
    B.[RelId],
    B.[ValorRescate],
    B.[ValorActual],
    ISNULL(CAST(B.[Antiguedad] AS varchar(30)), '--') AS [Antiguedad],
    B.[Progresivo],
    B.[Consecutivo],
    DOC.[CantidadSolicitada] AS [DetaOrdenCompra],
    B.[ClaveHist],
    B.[FechaResguardado],
    CASE WHEN B.[EstaResguardado] = 1 THEN 'SI' ELSE 'NO' END AS [EstaResguardado],
    B.[PK_IdBien]
FROM [SICOP].[Bien] AS B
LEFT JOIN [SICOP].[GrupoBien] AS GB ON GB.[PK_IdGrupoBien] = B.[FK_IdGrupoBien__SICOP]
LEFT JOIN [SICOP].[TipoBien] AS TB ON TB.[PK_IdTipoBien] = B.[FK_IdTipoBien__SICOP]
LEFT JOIN [SIS].[Area] AS A ON A.[PKIdArea] = B.[FK_IdArea__SIS]
LEFT JOIN [SICOP].[Marca] AS M ON M.[PK_IdMarca] = B.[FK_IdMarca__SICOP]
LEFT JOIN [SIS].[Proveedor] AS P ON P.[PKIdProveedor] = B.[FK_IdProveedor__SIS]
LEFT JOIN [SICOP].[EstadoBien] AS EB ON EB.[PK_IdEstadoBien] = B.[FK_IdEstadoBien__SICOP]
LEFT JOIN [RHCT].[Persona] AS PE ON PE.[PK_IdPersona] = B.[FK_IdPersona__RHCT]
LEFT JOIN [SICOP].[TipoPatrimonio] AS TP ON TP.[PK_IdTipoPatrimonio] = B.[FK_IdTipoPatrimonio__SICOP]
LEFT JOIN [SICOP].[Material] AS MAT ON MAT.[PK_IdMaterial] = B.[FK_IdMaterial__SICOP]
LEFT JOIN [SIS].[Partida] AS PA ON PA.[PKIdPartida] = B.[FK_IdPartida__SIS]
LEFT JOIN [SICOP].[TipoAdq] AS TA ON TA.[PK_IdTipoAdq] = B.[FK_IdTipoAdq__SICOP]
LEFT JOIN [ORCO].[OrdenCompraDetalle] AS DOC ON DOC.[PKIdOrdenCompraDetalle] = B.[FK_IdDetalleOrdenCompra__ORCO];
GO

CREATE OR ALTER VIEW [PRES].[VW_FacturasPendientesPago]
AS
SELECT
    Fac.[PKIdFactura] AS [Id],
    ISNULL(CC.[ClaveNombre], 'Configure Cuenta Prov') AS [nocuenta],
    ISNULL(Prov.[Nombre], 'Sin Proveedor') AS [nomdeno],
    Fac.[Total] AS [saldo],
    CONVERT(datetime, Fac.[FechaEmision]) AS [fechaemi],
    DATEDIFF(day, Fac.[FechaEmision], GETDATE()) AS [diasvencidos],
    CASE WHEN DATEDIFF(day, Fac.[FechaEmision], GETDATE()) < 30 THEN DATEDIFF(day, Fac.[FechaEmision], GETDATE()) END AS [rango01],
    CASE WHEN DATEDIFF(day, Fac.[FechaEmision], GETDATE()) > 30 AND DATEDIFF(day, Fac.[FechaEmision], GETDATE()) < 60 THEN DATEDIFF(day, Fac.[FechaEmision], GETDATE()) END AS [rango31],
    CASE WHEN DATEDIFF(day, Fac.[FechaEmision], GETDATE()) > 60 AND DATEDIFF(day, Fac.[FechaEmision], GETDATE()) < 90 THEN DATEDIFF(day, Fac.[FechaEmision], GETDATE()) END AS [rango61],
    CASE WHEN DATEDIFF(day, Fac.[FechaEmision], GETDATE()) > 90 THEN DATEDIFF(day, Fac.[FechaEmision], GETDATE()) END AS [rango90mas],
    Cto.[Descripcion] AS [Motivo]
FROM [PRES].[Factura] AS Fac
INNER JOIN [PRES].[Contrato] AS Cto ON Cto.[PKIdContrato] = Fac.[FKIdContrato_PRES] AND Cto.[Activo] = 1
LEFT JOIN [SIS].[Proveedor] AS Prov ON Cto.[FKIdProveedor_SIS] = Prov.[PKIdProveedor]
LEFT JOIN [CONTA].[VW_CUENTAS] AS CC ON Prov.[FKIdCuentaContable_SIS] = CC.[PkIdCuenta]
LEFT JOIN [PRES].[CLCFactura] AS CFac ON CFac.[FKIdFactura_PRES] = Fac.[PKIdFactura] AND CFac.[Activo] = 1
LEFT JOIN [PRES].[CLC] AS Clc ON Clc.[PKIdCLC] = CFac.[FKIdCLC_PRES] AND Clc.[Activo] = 1
LEFT JOIN [PRES].[Cheque] AS Cheq ON Cheq.[FKIdCLC_PRES] = Clc.[PKIdCLC] AND Cheq.[Activo] = 1
WHERE Fac.[Activo] = 1
  AND Cheq.[PKIdCheque] IS NULL;
GO

CREATE OR ALTER VIEW [PRES].[VW_ClasificacionEgreso]
AS
WITH AdecXEgreAut AS
(
    SELECT
        d.[FKIdEgresoAutorizado_PRES] AS [FKIdEgresoAutorizado],
        SUM(d.[Total]) AS [Total]
    FROM [PRES].[EgreAdecuacionDetalle] AS d
    INNER JOIN [PRES].[EgreAdecuacion] AS m ON m.[PKIdEgreAdecuacion] = d.[FKIdEgreAdecuacion_PRES]
    INNER JOIN [PRES].[EgresoAutorizado] AS ea ON ea.[PKIdEgresoAutorizado] = d.[FKIdEgresoAutorizado_PRES]
    WHERE d.[Activo] = 1
      AND m.[Activo] = 1
      AND m.[Autorizado] = 1
      AND ea.[Activo] = 1
      AND ISNULL(ea.[FKIdFuenteFinanciamiento_PRES], 0) <> 6
    GROUP BY d.[FKIdEgresoAutorizado_PRES]
),
CtoXEgreAut AS
(
    SELECT
        req.[FKIdEgresoAutorizado_PRES] AS [FKIdEgresoAutorizado],
        SUM(cto.[MontoTotal]) AS [Total]
    FROM [PRES].[Contrato] AS cto
    INNER JOIN [PRES].[AutorizacionSuficiencia] AS aus ON aus.[PKIdAutorizacionSuficiencia] = cto.[FKIdAutorizacionSuficiencia_PRES] AND aus.[Activo] = 1
    INNER JOIN [PRES].[SolicitudSuficiencia] AS ss ON ss.[PKIdSolicitudSuficiencia] = aus.[FKIdSolicitudSuficiencia_PRES] AND ss.[Activo] = 1
    INNER JOIN [ORCO].[Requisicion] AS req ON req.[PKIdRequisicion] = ss.[FKIdRequisicion_ORCO] AND req.[Activo] = 1
    INNER JOIN [PRES].[EgresoAutorizado] AS ea ON ea.[PKIdEgresoAutorizado] = req.[FKIdEgresoAutorizado_PRES] AND ea.[Activo] = 1
    WHERE cto.[Activo] = 1
      AND ISNULL(ea.[FKIdFuenteFinanciamiento_PRES], 0) <> 6
    GROUP BY req.[FKIdEgresoAutorizado_PRES]
),
FacXEgreAut AS
(
    SELECT
        req.[FKIdEgresoAutorizado_PRES] AS [PKIdEgresoAutorizado],
        SUM(fac.[Total]) AS [Total]
    FROM [PRES].[Factura] AS fac
    INNER JOIN [PRES].[Contrato] AS cto ON cto.[PKIdContrato] = fac.[FKIdContrato_PRES] AND cto.[Activo] = 1
    INNER JOIN [PRES].[AutorizacionSuficiencia] AS aus ON aus.[PKIdAutorizacionSuficiencia] = cto.[FKIdAutorizacionSuficiencia_PRES] AND aus.[Activo] = 1
    INNER JOIN [PRES].[SolicitudSuficiencia] AS ss ON ss.[PKIdSolicitudSuficiencia] = aus.[FKIdSolicitudSuficiencia_PRES] AND ss.[Activo] = 1
    INNER JOIN [ORCO].[Requisicion] AS req ON req.[PKIdRequisicion] = ss.[FKIdRequisicion_ORCO] AND req.[Activo] = 1
    INNER JOIN [PRES].[EgresoAutorizado] AS ea ON ea.[PKIdEgresoAutorizado] = req.[FKIdEgresoAutorizado_PRES] AND ea.[Activo] = 1
    WHERE fac.[Activo] = 1
      AND ISNULL(ea.[FKIdFuenteFinanciamiento_PRES], 0) <> 6
    GROUP BY req.[FKIdEgresoAutorizado_PRES]
),
ClcXEgreAut AS
(
    SELECT
        req.[FKIdEgresoAutorizado_PRES] AS [PKIdEgresoAutorizado],
        SUM(cf.[MontoAplicado]) AS [Total]
    FROM [PRES].[CLCFactura] AS cf
    INNER JOIN [PRES].[Factura] AS fac ON fac.[PKIdFactura] = cf.[FKIdFactura_PRES] AND fac.[Activo] = 1
    INNER JOIN [PRES].[Contrato] AS cto ON cto.[PKIdContrato] = fac.[FKIdContrato_PRES] AND cto.[Activo] = 1
    INNER JOIN [PRES].[AutorizacionSuficiencia] AS aus ON aus.[PKIdAutorizacionSuficiencia] = cto.[FKIdAutorizacionSuficiencia_PRES] AND aus.[Activo] = 1
    INNER JOIN [PRES].[SolicitudSuficiencia] AS ss ON ss.[PKIdSolicitudSuficiencia] = aus.[FKIdSolicitudSuficiencia_PRES] AND ss.[Activo] = 1
    INNER JOIN [ORCO].[Requisicion] AS req ON req.[PKIdRequisicion] = ss.[FKIdRequisicion_ORCO] AND req.[Activo] = 1
    INNER JOIN [PRES].[EgresoAutorizado] AS ea ON ea.[PKIdEgresoAutorizado] = req.[FKIdEgresoAutorizado_PRES] AND ea.[Activo] = 1
    WHERE cf.[Activo] = 1
      AND ISNULL(ea.[FKIdFuenteFinanciamiento_PRES], 0) <> 6
    GROUP BY req.[FKIdEgresoAutorizado_PRES]
),
ChqXEgreAut AS
(
    SELECT
        req.[FKIdEgresoAutorizado_PRES] AS [PKIdEgresoAutorizado],
        SUM(chq.[ImporteTotal]) AS [Total]
    FROM [PRES].[Cheque] AS chq
    INNER JOIN [PRES].[CLC] AS clc ON clc.[PKIdCLC] = chq.[FKIdCLC_PRES] AND clc.[Activo] = 1
    INNER JOIN [PRES].[CLCFactura] AS cf ON cf.[FKIdCLC_PRES] = clc.[PKIdCLC] AND cf.[Activo] = 1
    INNER JOIN [PRES].[Factura] AS fac ON fac.[PKIdFactura] = cf.[FKIdFactura_PRES] AND fac.[Activo] = 1
    INNER JOIN [PRES].[Contrato] AS cto ON cto.[PKIdContrato] = fac.[FKIdContrato_PRES] AND cto.[Activo] = 1
    INNER JOIN [PRES].[AutorizacionSuficiencia] AS aus ON aus.[PKIdAutorizacionSuficiencia] = cto.[FKIdAutorizacionSuficiencia_PRES] AND aus.[Activo] = 1
    INNER JOIN [PRES].[SolicitudSuficiencia] AS ss ON ss.[PKIdSolicitudSuficiencia] = aus.[FKIdSolicitudSuficiencia_PRES] AND ss.[Activo] = 1
    INNER JOIN [ORCO].[Requisicion] AS req ON req.[PKIdRequisicion] = ss.[FKIdRequisicion_ORCO] AND req.[Activo] = 1
    INNER JOIN [PRES].[EgresoAutorizado] AS ea ON ea.[PKIdEgresoAutorizado] = req.[FKIdEgresoAutorizado_PRES] AND ea.[Activo] = 1
    WHERE chq.[Activo] = 1
      AND ISNULL(ea.[FKIdFuenteFinanciamiento_PRES], 0) <> 6
    GROUP BY req.[FKIdEgresoAutorizado_PRES]
)
SELECT
    pea.[PKIdEgresoAutorizado] AS [Pk_IdEgresoAutorizado],
    pea.[AreaNombre] AS [AreaFuncional],
    pea.[AnioClave] AS [Año],
    pea.[AreaNombre] AS [Area],
    pea.[PartidaClave] AS [Partida],
    pea.[FuenteFinanciamientoClave] AS [FF],
    pea.[TipoGastoClave] AS [TG],
    pea.[DigitoIdentificadorClave] AS [DI],
    pea.[DestinoGastoClave] AS [DG],
    pea.[PyClave] AS [PY],
    CONCAT(pea.[AreaClave], ' ', pea.[PartidaClave], ' ', pea.[FuenteFinanciamientoClave], ' ', pea.[TipoGastoClave], ' ', pea.[DigitoIdentificadorClave], ' ', pea.[DestinoGastoClave], ' ', pea.[PyClave]) AS [PosicionPresupuestal],
    ISNULL(pea.[Total], 0) AS [EgresoAutorizado],
    ISNULL(pa.[Total], 0) AS [Adecuaciones],
    ISNULL(pc.[Total], 0) AS [Comprometido],
    CAST(0 AS decimal(18, 2)) AS [ReservadoSigevi],
    ISNULL(pea.[Total], 0) + ISNULL(pa.[Total], 0) - ISNULL(pc.[Total], 0) AS [Disponible],
    ISNULL(fac.[Total], 0) AS [Devengado],
    ISNULL(clc.[Total], 0) AS [Ejercido],
    ISNULL(chq.[Total], 0) AS [Pagado],
    pea.[FKIdPrograma_PRES] AS [Fk_IdPrograma__PRES],
    pea.[FKIdFuenteFinanciamiento_PRES] AS [Fk_IdFuenteFinanciamiento__PRES],
    pea.[FKIdTipoGasto_PRES] AS [Fk_IdTipoGasto__PRES],
    pea.[FKIdDigitoIdentificador_PRES] AS [Fk_IdDigitoIdentificador__PRES],
    pea.[FKIdDestinoGasto_PRES] AS [Fk_IdDestinoGasto__PRES],
    pea.[FKIdPY_PRES] AS [Fk_IdPY__PRES],
    pea.[FKIdPartida_CONTA] AS [Fk_IdPartida__SIS],
    pea.[FKIdArea_SIS] AS [Fk_IdArea__SIS],
    pea.[PartidaDescripcion] AS [Descripcion],
    pea.[Fecha],
    pea.[FKIdAnio_SIS] AS [Fk_IdAnio__SIS],
    CAST('' AS varchar(max)) AS [Message],
    CONCAT(pea.[PartidaClaveNombre], ' ', FORMAT(ISNULL(pea.[Total], 0) + ISNULL(pa.[Total], 0) - ISNULL(pc.[Total], 0), 'C', 'es-MX')) AS [DescripcionRequisicion]
FROM [PRES].[Vw_EgresoAutorizado] AS pea
LEFT JOIN AdecXEgreAut AS pa ON pa.[FKIdEgresoAutorizado] = pea.[PKIdEgresoAutorizado]
LEFT JOIN CtoXEgreAut AS pc ON pc.[FKIdEgresoAutorizado] = pea.[PKIdEgresoAutorizado]
LEFT JOIN FacXEgreAut AS fac ON fac.[PKIdEgresoAutorizado] = pea.[PKIdEgresoAutorizado]
LEFT JOIN ClcXEgreAut AS clc ON clc.[PKIdEgresoAutorizado] = pea.[PKIdEgresoAutorizado]
LEFT JOIN ChqXEgreAut AS chq ON chq.[PKIdEgresoAutorizado] = pea.[PKIdEgresoAutorizado]
WHERE ISNULL(pea.[FKIdFuenteFinanciamiento_PRES], 0) <> 6;
GO

CREATE OR ALTER VIEW [SICOP].[VW_DepreciacionBien]
AS
SELECT
    bn.[PK_IdBien],
    bn.[Clave],
    bn.[Descripcion],
    bn.[Costo],
    bn.[FechaAdq],
    tb.[FK_IdPartida__SIS],
    pa.[Descripcion] AS [Partida],
    DATEDIFF(month, bn.[FechaAdq], GETDATE()) AS [AntiguedadMeses],
    tb.[CodigoClave],
    tb.[DepreciacionAnual],
    (tb.[DepreciacionAnual] / 12) / 100 AS [PorcDepMensual],
    CASE WHEN DATEDIFF(month, bn.[FechaAdq], GETDATE()) >= 120 THEN 0
         ELSE bn.[Costo] * DATEDIFF(month, bn.[FechaAdq], GETDATE()) * (tb.[DepreciacionAnual] / 12) / 100 END AS [DepreciacionAcumulada],
    CASE WHEN DATEDIFF(month, bn.[FechaAdq], GETDATE()) >= 120 THEN 0
         ELSE bn.[Costo] - (bn.[Costo] * DATEDIFF(month, bn.[FechaAdq], GETDATE()) * (tb.[DepreciacionAnual] / 12) / 100) END AS [ValorAcual],
    CASE WHEN DATEDIFF(month, bn.[FechaAdq], GETDATE()) >= 120 THEN 0
         ELSE bn.[Costo] * tb.[DepreciacionAnual] / 100 END AS [DepreciacionAnio],
    CASE WHEN DATEDIFF(month, bn.[FechaAdq], GETDATE()) >= 120 THEN 0
         ELSE bn.[Costo] * (tb.[DepreciacionAnual] / 12) / 100 END AS [DepreciacionMes]
FROM [SICOP].[VW_Bien] AS bn
INNER JOIN [SICOP].[TipoBien] AS tb ON bn.[FK_IdTipoBien__SICOP] = tb.[PK_IdTipoBien]
LEFT JOIN [SIS].[Partida] AS pa ON tb.[FK_IdPartida__SIS] = pa.[PKIdPartida];
GO
