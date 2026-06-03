USE [GestionEmpresarial]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF SCHEMA_ID(N'PRES') IS NULL
    EXEC(N'CREATE SCHEMA [PRES]');
GO

IF OBJECT_ID(N'[PRES].[TipoAdecuacion]', N'U') IS NULL
BEGIN
    CREATE TABLE [PRES].[TipoAdecuacion](
        [PKIdTipoAdecuacion] [int] IDENTITY(1,1) NOT NULL,
        [Descripcion] [nvarchar](50) NOT NULL,
        [Activo] [bit] NOT NULL CONSTRAINT [DF_TipoAdecuacion_Activo] DEFAULT ((1)),
        [FechaCreacion] [datetime2](7) NULL CONSTRAINT [DF_TipoAdecuacion_FechaCreacion] DEFAULT (SYSDATETIME()),
        [UsuarioCreacion] [int] NOT NULL CONSTRAINT [DF_TipoAdecuacion_UsuarioCreacion] DEFAULT ((1)),
        [FechaModificacion] [datetime2](7) NULL,
        [UsuarioModificacion] [int] NULL,
        CONSTRAINT [PK_TipoAdecuacion] PRIMARY KEY CLUSTERED ([PKIdTipoAdecuacion] ASC)
    );
END
GO

IF OBJECT_ID(N'[PRES].[EstatusAdecuacion]', N'U') IS NULL
BEGIN
    CREATE TABLE [PRES].[EstatusAdecuacion](
        [PKIdEstatusAdecuacion] [int] IDENTITY(1,1) NOT NULL,
        [Descripcion] [nvarchar](100) NOT NULL,
        [Color] [nvarchar](8) NULL,
        [Activo] [bit] NOT NULL CONSTRAINT [DF_EstatusAdecuacion_Activo] DEFAULT ((1)),
        [FechaCreacion] [datetime2](7) NULL CONSTRAINT [DF_EstatusAdecuacion_FechaCreacion] DEFAULT (SYSDATETIME()),
        [UsuarioCreacion] [int] NOT NULL CONSTRAINT [DF_EstatusAdecuacion_UsuarioCreacion] DEFAULT ((1)),
        [FechaModificacion] [datetime2](7) NULL,
        [UsuarioModificacion] [int] NULL,
        CONSTRAINT [PK_EstatusAdecuacion] PRIMARY KEY CLUSTERED ([PKIdEstatusAdecuacion] ASC)
    );
END
GO

IF OBJECT_ID(N'[PRES].[AccionAdecuacionMaster]', N'U') IS NULL
BEGIN
    CREATE TABLE [PRES].[AccionAdecuacionMaster](
        [PKIdAccionAdecuacionMaster] [int] IDENTITY(1,1) NOT NULL,
        [Accion] [nvarchar](50) NOT NULL,
        [Comentario] [nvarchar](250) NULL,
        [Activo] [bit] NOT NULL CONSTRAINT [DF_AccionAdecuacionMaster_Activo] DEFAULT ((1)),
        [FechaCreacion] [datetime2](7) NULL CONSTRAINT [DF_AccionAdecuacionMaster_FechaCreacion] DEFAULT (SYSDATETIME()),
        [UsuarioCreacion] [int] NOT NULL CONSTRAINT [DF_AccionAdecuacionMaster_UsuarioCreacion] DEFAULT ((1)),
        [FechaModificacion] [datetime2](7) NULL,
        [UsuarioModificacion] [int] NULL,
        CONSTRAINT [PK_AccionAdecuacionMaster] PRIMARY KEY CLUSTERED ([PKIdAccionAdecuacionMaster] ASC)
    );
END
GO

IF OBJECT_ID(N'[PRES].[TipoMovimiento]', N'U') IS NULL
BEGIN
    CREATE TABLE [PRES].[TipoMovimiento](
        [PKIdTipoMovimiento] [int] IDENTITY(1,1) NOT NULL,
        [Descripcion] [nvarchar](50) NOT NULL,
        [Activo] [bit] NOT NULL CONSTRAINT [DF_TipoMovimiento_Activo] DEFAULT ((1)),
        [FechaCreacion] [datetime2](7) NULL CONSTRAINT [DF_TipoMovimiento_FechaCreacion] DEFAULT (SYSDATETIME()),
        [UsuarioCreacion] [int] NOT NULL CONSTRAINT [DF_TipoMovimiento_UsuarioCreacion] DEFAULT ((1)),
        [FechaModificacion] [datetime2](7) NULL,
        [UsuarioModificacion] [int] NULL,
        CONSTRAINT [PK_TipoMovimiento] PRIMARY KEY CLUSTERED ([PKIdTipoMovimiento] ASC)
    );
END
GO

IF OBJECT_ID(N'[PRES].[EgreAdecuacion]', N'U') IS NULL
BEGIN
    CREATE TABLE [PRES].[EgreAdecuacion](
        [PKIdEgreAdecuacion] [int] IDENTITY(1,1) NOT NULL,
        [Clave] [nvarchar](50) NOT NULL,
        [FKIdTipoAdecuacion_PRES] [int] NOT NULL,
        [FKIdEstatusAdecuacion_PRES] [int] NOT NULL,
        [Justificacion] [nvarchar](max) NULL,
        [Fecha] [date] NOT NULL,
        [FKIdPoliza_CONTA] [int] NULL,
        [FKIdAnio_SIS] [int] NOT NULL,
        [Autorizado] [bit] NULL,
        [FKIdAccionAdecuacionMaster_PRES] [int] NULL,
        [FechaSolicitud] [datetime2](7) NULL,
        [FechaAutorizacion] [datetime2](7) NULL,
        [Activo] [bit] NOT NULL CONSTRAINT [DF_EgreAdecuacion_Activo] DEFAULT ((1)),
        [FechaCreacion] [datetime2](7) NULL CONSTRAINT [DF_EgreAdecuacion_FechaCreacion] DEFAULT (SYSDATETIME()),
        [UsuarioCreacion] [int] NOT NULL CONSTRAINT [DF_EgreAdecuacion_UsuarioCreacion] DEFAULT ((1)),
        [FechaModificacion] [datetime2](7) NULL,
        [UsuarioModificacion] [int] NULL,
        CONSTRAINT [PK_EgreAdecuacion] PRIMARY KEY CLUSTERED ([PKIdEgreAdecuacion] ASC)
    );
END
GO

IF OBJECT_ID(N'[PRES].[EgreAdecuacionDetalle]', N'U') IS NULL
BEGIN
    CREATE TABLE [PRES].[EgreAdecuacionDetalle](
        [PKIdEgreAdecuacionDetalle] [int] IDENTITY(1,1) NOT NULL,
        [FKIdEgresoAutorizado_PRES] [int] NULL,
        [Justificacion] [nvarchar](max) NULL,
        [Fecha] [date] NOT NULL,
        [FKIdEgreAdecuacion_PRES] [int] NOT NULL,
        [FKIdTipoMovimiento_PRES] [int] NOT NULL,
        [Enero] [dbo].[dmoney] NULL CONSTRAINT [DF_EgreAdecuacionDetalle_Enero] DEFAULT ((0)),
        [Febrero] [dbo].[dmoney] NULL CONSTRAINT [DF_EgreAdecuacionDetalle_Febrero] DEFAULT ((0)),
        [Marzo] [dbo].[dmoney] NULL CONSTRAINT [DF_EgreAdecuacionDetalle_Marzo] DEFAULT ((0)),
        [Abril] [dbo].[dmoney] NULL CONSTRAINT [DF_EgreAdecuacionDetalle_Abril] DEFAULT ((0)),
        [Mayo] [dbo].[dmoney] NULL CONSTRAINT [DF_EgreAdecuacionDetalle_Mayo] DEFAULT ((0)),
        [Junio] [dbo].[dmoney] NULL CONSTRAINT [DF_EgreAdecuacionDetalle_Junio] DEFAULT ((0)),
        [Julio] [dbo].[dmoney] NULL CONSTRAINT [DF_EgreAdecuacionDetalle_Julio] DEFAULT ((0)),
        [Agosto] [dbo].[dmoney] NULL CONSTRAINT [DF_EgreAdecuacionDetalle_Agosto] DEFAULT ((0)),
        [Septiembre] [dbo].[dmoney] NULL CONSTRAINT [DF_EgreAdecuacionDetalle_Septiembre] DEFAULT ((0)),
        [Octubre] [dbo].[dmoney] NULL CONSTRAINT [DF_EgreAdecuacionDetalle_Octubre] DEFAULT ((0)),
        [Noviembre] [dbo].[dmoney] NULL CONSTRAINT [DF_EgreAdecuacionDetalle_Noviembre] DEFAULT ((0)),
        [Diciembre] [dbo].[dmoney] NULL CONSTRAINT [DF_EgreAdecuacionDetalle_Diciembre] DEFAULT ((0)),
        [Total] AS (((((((((((ISNULL([Enero],(0))+ISNULL([Febrero],(0)))+ISNULL([Marzo],(0)))+ISNULL([Abril],(0)))+ISNULL([Mayo],(0)))+ISNULL([Junio],(0)))+ISNULL([Julio],(0)))+ISNULL([Agosto],(0)))+ISNULL([Septiembre],(0)))+ISNULL([Octubre],(0)))+ISNULL([Noviembre],(0)))+ISNULL([Diciembre],(0))),
        [Activo] [bit] NOT NULL CONSTRAINT [DF_EgreAdecuacionDetalle_Activo] DEFAULT ((1)),
        [FechaCreacion] [datetime2](7) NULL CONSTRAINT [DF_EgreAdecuacionDetalle_FechaCreacion] DEFAULT (SYSDATETIME()),
        [UsuarioCreacion] [int] NOT NULL CONSTRAINT [DF_EgreAdecuacionDetalle_UsuarioCreacion] DEFAULT ((1)),
        [FechaModificacion] [datetime2](7) NULL,
        [UsuarioModificacion] [int] NULL,
        CONSTRAINT [PK_EgreAdecuacionDetalle] PRIMARY KEY CLUSTERED ([PKIdEgreAdecuacionDetalle] ASC)
    );
END
GO

IF COL_LENGTH(N'PRES.EgreAdecuacion', N'Justificacion') IS NOT NULL
    ALTER TABLE [PRES].[EgreAdecuacion] ALTER COLUMN [Justificacion] NVARCHAR(MAX) NULL;
GO

IF COL_LENGTH(N'PRES.EgreAdecuacionDetalle', N'Justificacion') IS NOT NULL
    ALTER TABLE [PRES].[EgreAdecuacionDetalle] ALTER COLUMN [Justificacion] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'[PRES].[FK_EgreAdecuacion_TipoAdecuacion]', N'F') IS NULL
    ALTER TABLE [PRES].[EgreAdecuacion] WITH NOCHECK ADD CONSTRAINT [FK_EgreAdecuacion_TipoAdecuacion] FOREIGN KEY([FKIdTipoAdecuacion_PRES]) REFERENCES [PRES].[TipoAdecuacion]([PKIdTipoAdecuacion]);
GO
IF OBJECT_ID(N'[PRES].[FK_EgreAdecuacion_EstatusAdecuacion]', N'F') IS NULL
    ALTER TABLE [PRES].[EgreAdecuacion] WITH NOCHECK ADD CONSTRAINT [FK_EgreAdecuacion_EstatusAdecuacion] FOREIGN KEY([FKIdEstatusAdecuacion_PRES]) REFERENCES [PRES].[EstatusAdecuacion]([PKIdEstatusAdecuacion]);
GO
IF OBJECT_ID(N'[PRES].[FK_EgreAdecuacion_AccionAdecuacionMaster]', N'F') IS NULL
    ALTER TABLE [PRES].[EgreAdecuacion] WITH NOCHECK ADD CONSTRAINT [FK_EgreAdecuacion_AccionAdecuacionMaster] FOREIGN KEY([FKIdAccionAdecuacionMaster_PRES]) REFERENCES [PRES].[AccionAdecuacionMaster]([PKIdAccionAdecuacionMaster]);
GO
IF OBJECT_ID(N'[PRES].[FK_EgreAdecuacionDetalle_EgreAdecuacion]', N'F') IS NULL
    ALTER TABLE [PRES].[EgreAdecuacionDetalle] WITH NOCHECK ADD CONSTRAINT [FK_EgreAdecuacionDetalle_EgreAdecuacion] FOREIGN KEY([FKIdEgreAdecuacion_PRES]) REFERENCES [PRES].[EgreAdecuacion]([PKIdEgreAdecuacion]);
GO
IF OBJECT_ID(N'[PRES].[FK_EgreAdecuacionDetalle_EgresoAutorizado]', N'F') IS NULL
    ALTER TABLE [PRES].[EgreAdecuacionDetalle] WITH NOCHECK ADD CONSTRAINT [FK_EgreAdecuacionDetalle_EgresoAutorizado] FOREIGN KEY([FKIdEgresoAutorizado_PRES]) REFERENCES [PRES].[EgresoAutorizado]([PKIdEgresoAutorizado]);
GO
IF OBJECT_ID(N'[PRES].[FK_EgreAdecuacionDetalle_TipoMovimiento]', N'F') IS NULL
    ALTER TABLE [PRES].[EgreAdecuacionDetalle] WITH NOCHECK ADD CONSTRAINT [FK_EgreAdecuacionDetalle_TipoMovimiento] FOREIGN KEY([FKIdTipoMovimiento_PRES]) REFERENCES [PRES].[TipoMovimiento]([PKIdTipoMovimiento]);
GO

IF DB_ID(N'BD_PRESUPUESTO') IS NOT NULL
BEGIN
    SET IDENTITY_INSERT [PRES].[TipoAdecuacion] ON;
    INSERT INTO [PRES].[TipoAdecuacion] (PKIdTipoAdecuacion, Descripcion, Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion)
    SELECT src.PK_IdTipoAdecuacion, src.Descripcion, ISNULL(src.CT_LIVE, 1), src.CT_CreatedDate, src.CT_CreatedBy, src.CT_ModifiedDate, src.CT_ModifiedBy
    FROM [BD_PRESUPUESTO].[PRES].[TipoAdecuacion] src
    WHERE NOT EXISTS (SELECT 1 FROM [PRES].[TipoAdecuacion] dst WHERE dst.PKIdTipoAdecuacion = src.PK_IdTipoAdecuacion);
    SET IDENTITY_INSERT [PRES].[TipoAdecuacion] OFF;

    SET IDENTITY_INSERT [PRES].[EstatusAdecuacion] ON;
    INSERT INTO [PRES].[EstatusAdecuacion] (PKIdEstatusAdecuacion, Descripcion, Color, Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion)
    SELECT src.PK_IdEstatusAdecuacion, src.Descripcion, src.Color, ISNULL(src.CT_LIVE, 1), src.CT_CreatedDate, src.CT_CreatedBy, src.CT_ModifiedDate, src.CT_ModifiedBy
    FROM [BD_PRESUPUESTO].[PRES].[EstatusAdecuacion] src
    WHERE NOT EXISTS (SELECT 1 FROM [PRES].[EstatusAdecuacion] dst WHERE dst.PKIdEstatusAdecuacion = src.PK_IdEstatusAdecuacion);
    SET IDENTITY_INSERT [PRES].[EstatusAdecuacion] OFF;

    SET IDENTITY_INSERT [PRES].[AccionAdecuacionMaster] ON;
    INSERT INTO [PRES].[AccionAdecuacionMaster] (PKIdAccionAdecuacionMaster, Accion, Comentario, Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion)
    SELECT src.Pk_IdAccionAdecuacionMaster, src.Accion, src.Comentario, ISNULL(src.CT_LIVE, 1), src.CT_CreatedDate, src.CT_CreatedBy, src.CT_ModifiedDate, src.CT_ModifiedBy
    FROM [BD_PRESUPUESTO].[PRES].[AccionAdecuacionMaster] src
    WHERE NOT EXISTS (SELECT 1 FROM [PRES].[AccionAdecuacionMaster] dst WHERE dst.PKIdAccionAdecuacionMaster = src.Pk_IdAccionAdecuacionMaster);
    SET IDENTITY_INSERT [PRES].[AccionAdecuacionMaster] OFF;

    SET IDENTITY_INSERT [PRES].[TipoMovimiento] ON;
    INSERT INTO [PRES].[TipoMovimiento] (PKIdTipoMovimiento, Descripcion, Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion)
    SELECT src.PK_IdTipoMovimiento, src.Descripcion, ISNULL(src.CT_LIVE, 1), src.CT_CreatedDate, src.CT_CreatedBy, src.CT_ModifiedDate, src.CT_ModifiedBy
    FROM [BD_PRESUPUESTO].[PRES].[TipoMovimiento] src
    WHERE NOT EXISTS (SELECT 1 FROM [PRES].[TipoMovimiento] dst WHERE dst.PKIdTipoMovimiento = src.PK_IdTipoMovimiento);
    SET IDENTITY_INSERT [PRES].[TipoMovimiento] OFF;

    
END
GO

CREATE OR ALTER VIEW [PRES].[Vw_EgresoAdecuacion]
AS
SELECT
    ea.PKIdEgreAdecuacion,
    ea.Clave,
    ea.FKIdTipoAdecuacion_PRES,
    ta.Descripcion AS TipoAdecuacionDescripcion,
    ea.FKIdEstatusAdecuacion_PRES,
    est.Descripcion AS EstatusAdecuacionDescripcion,
    est.Color AS EstatusAdecuacionColor,
    ea.Justificacion,
    ea.Fecha,
    ea.FKIdPoliza_CONTA,
    pol.ClavePoliza,
    ea.FKIdAnio_SIS,
    anio.Clave AS AnioClave,
    ea.Autorizado,
    ea.FKIdAccionAdecuacionMaster_PRES,
    acc.Accion AS AccionAdecuacion,
    acc.Comentario AS AccionComentario,
    ea.FechaSolicitud,
    ea.FechaAutorizacion,
    ea.Activo,
    ea.FechaCreacion,
    ea.UsuarioCreacion,
    ea.FechaModificacion,
    ea.UsuarioModificacion,
    CONCAT(ea.Clave, ' - ', ISNULL(ea.Justificacion, '')) AS ClaveNombre
FROM PRES.EgreAdecuacion ea
LEFT JOIN PRES.TipoAdecuacion ta ON ea.FKIdTipoAdecuacion_PRES = ta.PKIdTipoAdecuacion AND ta.Activo = 1
LEFT JOIN PRES.EstatusAdecuacion est ON ea.FKIdEstatusAdecuacion_PRES = est.PKIdEstatusAdecuacion AND est.Activo = 1
LEFT JOIN CONTA.Poliza pol ON ea.FKIdPoliza_CONTA = pol.PKIdPoliza AND pol.Activo = 1
LEFT JOIN SIS.Anio anio ON ea.FKIdAnio_SIS = anio.PKIdAnio AND anio.Activo = 1
LEFT JOIN PRES.AccionAdecuacionMaster acc ON ea.FKIdAccionAdecuacionMaster_PRES = acc.PKIdAccionAdecuacionMaster AND acc.Activo = 1
WHERE ea.Activo = 1;
GO

CREATE OR ALTER VIEW [PRES].[Vw_EgresoAdecuacionDetalle]
AS
SELECT
    det.PKIdEgreAdecuacionDetalle,
    det.FKIdEgreAdecuacion_PRES,
    enc.Clave AS EgreAdecuacionClave,
    enc.Autorizado,
    det.FKIdEgresoAutorizado_PRES,
    egr.Descripcion AS EgresoAutorizadoDescripcion,
    det.FKIdTipoMovimiento_PRES,
    tm.Descripcion AS TipoMovimientoDescripcion,
    det.Justificacion,
    det.Fecha,
    det.Enero,
    det.Febrero,
    det.Marzo,
    det.Abril,
    det.Mayo,
    det.Junio,
    det.Julio,
    det.Agosto,
    det.Septiembre,
    det.Octubre,
    det.Noviembre,
    det.Diciembre,
    det.Total,
    det.Activo,
    det.FechaCreacion,
    det.UsuarioCreacion,
    det.FechaModificacion,
    det.UsuarioModificacion
FROM PRES.EgreAdecuacionDetalle det
INNER JOIN PRES.EgreAdecuacion enc ON det.FKIdEgreAdecuacion_PRES = enc.PKIdEgreAdecuacion AND enc.Activo = 1
LEFT JOIN PRES.EgresoAutorizado egr ON det.FKIdEgresoAutorizado_PRES = egr.PKIdEgresoAutorizado AND egr.Activo = 1
LEFT JOIN PRES.TipoMovimiento tm ON det.FKIdTipoMovimiento_PRES = tm.PKIdTipoMovimiento AND tm.Activo = 1
WHERE det.Activo = 1;
GO

CREATE OR ALTER VIEW [PRES].[VW_EgresoDisponible]
AS
WITH AdecXEgreAut AS (
    SELECT
        det.FKIdEgresoAutorizado_PRES,
        SUM(det.Enero) AS Enero,
        SUM(det.Febrero) AS Febrero,
        SUM(det.Marzo) AS Marzo,
        SUM(det.Abril) AS Abril,
        SUM(det.Mayo) AS Mayo,
        SUM(det.Junio) AS Junio,
        SUM(det.Julio) AS Julio,
        SUM(det.Agosto) AS Agosto,
        SUM(det.Septiembre) AS Septiembre,
        SUM(det.Octubre) AS Octubre,
        SUM(det.Noviembre) AS Noviembre,
        SUM(det.Diciembre) AS Diciembre,
        SUM(det.Total) AS Total
    FROM PRES.EgreAdecuacionDetalle det
    INNER JOIN PRES.EgreAdecuacion enc ON det.FKIdEgreAdecuacion_PRES = enc.PKIdEgreAdecuacion AND enc.Activo = 1
    INNER JOIN PRES.EgresoAutorizado egr ON det.FKIdEgresoAutorizado_PRES = egr.PKIdEgresoAutorizado AND egr.Activo = 1
    WHERE det.Activo = 1
      AND egr.FKIdFuenteFinanciamiento_PRES <> 6
      AND enc.Autorizado = 1
    GROUP BY det.FKIdEgresoAutorizado_PRES
),
CtoXEgreAut AS (
    SELECT
        req.FKIdEgresoAutorizado_PRES,
        SUM(cd.Enero) AS Enero,
        SUM(cd.Febrero) AS Febrero,
        SUM(cd.Marzo) AS Marzo,
        SUM(cd.Abril) AS Abril,
        SUM(cd.Mayo) AS Mayo,
        SUM(cd.Junio) AS Junio,
        SUM(cd.Julio) AS Julio,
        SUM(cd.Agosto) AS Agosto,
        SUM(cd.Septiembre) AS Septiembre,
        SUM(cd.Octubre) AS Octubre,
        SUM(cd.Noviembre) AS Noviembre,
        SUM(cd.Diciembre) AS Diciembre,
        SUM(cd.Total) AS Total
    FROM PRES.ContratoDetalle cd
    INNER JOIN PRES.Contrato c ON cd.FKIdContrato_PRES = c.PKIdContrato AND c.Activo = 1
    INNER JOIN PRES.AutorizacionSuficiencia au ON c.FKIdAutorizacionSuficiencia_PRES = au.PKIdAutorizacionSuficiencia AND au.Activo = 1
    INNER JOIN PRES.SolicitudSuficiencia ss ON au.FKIdSolicitudSuficiencia_PRES = ss.PKIdSolicitudSuficiencia AND ss.Activo = 1
    INNER JOIN ORCO.Requisicion req ON ss.FKIdRequisicion_ORCO = req.PKIdRequisicion AND req.Activo = 1
    INNER JOIN PRES.EgresoAutorizado egr ON req.FKIdEgresoAutorizado_PRES = egr.PKIdEgresoAutorizado AND egr.Activo = 1
    WHERE cd.Activo = 1
      AND egr.FKIdFuenteFinanciamiento_PRES <> 6
    GROUP BY req.FKIdEgresoAutorizado_PRES
)
SELECT
    egr.PKIdEgresoAutorizado,
    egr.FKIdEgresoProyectado_PRES,
    egr.FKIdAnio_SIS,
    egr.AnioClave,
    egr.FKIdPrograma_PRES,
    egr.ProgramaClave,
    egr.ProgramaDescripcion,
    egr.ProgramaClaveNombre,
    egr.FKIdPartida_CONTA,
    egr.PartidaClave,
    egr.PartidaDescripcion,
    egr.PartidaClaveNombre,
    egr.FKIdArea_SIS,
    egr.AreaClave,
    egr.AreaNombre,
    egr.FKIdFuenteFinanciamiento_PRES,
    egr.FuenteFinanciamientoClave,
    egr.FuenteFinanciamientoDescripcion,
    egr.FuenteFinanciamientoClaveNombre,
    egr.FKIdTipoGasto_PRES,
    egr.TipoGastoClave,
    egr.TipoGastoDescripcion,
    egr.TipoGastoClaveNombre,
    egr.FKIdDigitoIdentificador_PRES,
    egr.DigitoIdentificadorClave,
    egr.DigitoIdentificadorDescripcion,
    egr.DigitoIdentificadorClaveNombre,
    egr.FKIdDestinoGasto_PRES,
    egr.DestinoGastoClave,
    egr.DestinoGastoDescripcion,
    egr.DestinoGastoClaveNombre,
    egr.FKIdPY_PRES,
    egr.PyClave,
    egr.PyDescripcion,
    egr.PyClaveNombre,
    egr.Descripcion,
    egr.Fecha,
    ISNULL(egr.Enero, 0) + ISNULL(ad.Enero, 0) - ISNULL(ct.Enero, 0) AS Enero,
    ISNULL(egr.Febrero, 0) + ISNULL(ad.Febrero, 0) - ISNULL(ct.Febrero, 0) AS Febrero,
    ISNULL(egr.Marzo, 0) + ISNULL(ad.Marzo, 0) - ISNULL(ct.Marzo, 0) AS Marzo,
    ISNULL(egr.Abril, 0) + ISNULL(ad.Abril, 0) - ISNULL(ct.Abril, 0) AS Abril,
    ISNULL(egr.Mayo, 0) + ISNULL(ad.Mayo, 0) - ISNULL(ct.Mayo, 0) AS Mayo,
    ISNULL(egr.Junio, 0) + ISNULL(ad.Junio, 0) - ISNULL(ct.Junio, 0) AS Junio,
    ISNULL(egr.Julio, 0) + ISNULL(ad.Julio, 0) - ISNULL(ct.Julio, 0) AS Julio,
    ISNULL(egr.Agosto, 0) + ISNULL(ad.Agosto, 0) - ISNULL(ct.Agosto, 0) AS Agosto,
    ISNULL(egr.Septiembre, 0) + ISNULL(ad.Septiembre, 0) - ISNULL(ct.Septiembre, 0) AS Septiembre,
    ISNULL(egr.Octubre, 0) + ISNULL(ad.Octubre, 0) - ISNULL(ct.Octubre, 0) AS Octubre,
    ISNULL(egr.Noviembre, 0) + ISNULL(ad.Noviembre, 0) - ISNULL(ct.Noviembre, 0) AS Noviembre,
    ISNULL(egr.Diciembre, 0) + ISNULL(ad.Diciembre, 0) - ISNULL(ct.Diciembre, 0) AS Diciembre,
    ISNULL(egr.Total, 0) + ISNULL(ad.Total, 0) - ISNULL(ct.Total, 0) AS Total,
    CAST('' AS varchar(max)) AS [Message],
    CONCAT(
        egr.PartidaClaveNombre,
        ' ',
        FORMAT(ISNULL(egr.Total, 0) + ISNULL(ad.Total, 0) - ISNULL(ct.Total, 0), 'C', 'es-MX'),
        ' ',
        LEFT(ISNULL(egr.Descripcion, ''), 30)
    ) AS DescripcionRequisicion
FROM PRES.Vw_EgresoAutorizado egr
LEFT JOIN AdecXEgreAut ad ON ad.FKIdEgresoAutorizado_PRES = egr.PKIdEgresoAutorizado
LEFT JOIN CtoXEgreAut ct ON ct.FKIdEgresoAutorizado_PRES = egr.PKIdEgresoAutorizado
WHERE egr.Activo = 1
  AND egr.FKIdFuenteFinanciamiento_PRES <> 6;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'[PRES].[EgreAdecuacion]')
      AND name = N'IX_EgreAdecuacion_Activo_Autorizado'
)
    CREATE INDEX IX_EgreAdecuacion_Activo_Autorizado
    ON PRES.EgreAdecuacion (Activo, Autorizado, FKIdAnio_SIS);
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'[PRES].[EgreAdecuacionDetalle]')
      AND name = N'IX_EgreAdecuacionDetalle_Disponible'
)
    CREATE INDEX IX_EgreAdecuacionDetalle_Disponible
    ON PRES.EgreAdecuacionDetalle (Activo, FKIdEgresoAutorizado_PRES, FKIdEgreAdecuacion_PRES)
    INCLUDE (Enero, Febrero, Marzo, Abril, Mayo, Junio, Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre);
GO



CREATE OR ALTER PROCEDURE [PRES].[sp_MantenimientoEgresoAdecuacion]
    @Action INT,                                   -- 1=Insert, 2=Update, 3=Delete
    @PKIdEgreAdecuacion INT = NULL,                -- ID para Update/Delete (antes @IdC)
    @Autorizado BIT = 0,
    @IdUser INT = NULL,
    @idMenu INT = 85,
    @AlertMessage NVARCHAR(124) = NULL,
    @Id INT = NULL OUTPUT,
    -- Parámetros escalares (antes venían en Table Type)
    @FkIdPolizaConta INT = NULL,
    @FkIdAnioSis INT = NULL,
    @FkIdTipoAdecuacionPres INT = NULL,
    @FkIdEstatusAdecuacionPres INT = NULL,
    @Justificacion NVARCHAR(MAX) = NULL,
    @Fecha DATETIME2(7) = NULL,
    @FkIdAccionAdecuacionMasterPres INT = NULL,
    @FechaSolicitud DATETIME2(7) = NULL,
    @FechaAutorizacion DATETIME2(7) = NULL
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(100);
    DECLARE @message NVARCHAR(4000);
    DECLARE @Parameters NVARCHAR(4000) = '';
    DECLARE @errorMessage NVARCHAR(MAX);
    DECLARE @today DATETIME2(7) = SYSDATETIME();

    -- Variables de trabajo
    DECLARE @FKIdPoliza_CONTA INT = NULLIF(@FkIdPolizaConta, 0);
    DECLARE @FKIdAnio_SIS INT = @FkIdAnioSis;
    DECLARE @FKIdMes_SIS INT = MONTH(@Fecha);
    DECLARE @FKIdTipoPoliza_SIS INT = 4;
    DECLARE @NombrePoliza NVARCHAR(1000);
    DECLARE @FechaPoliza DATETIME2(7) = @Fecha;
    DECLARE @ClavePoliza NVARCHAR(10);
    DECLARE @ErrorPoliza NVARCHAR(MAX);
    DECLARE @CrearPoliza BIT = 0;
    DECLARE @Clave NVARCHAR(50);
    DECLARE @Consecutivo INT;

    -- ===================================================================
    -- Logging inicial
    -- ===================================================================
    SET @message = CONCAT('Iniciando SP [PRES].[sp_MantenimientoEgresoAdecuacion]', 
                          ' @PKIdEgreAdecuacion=', ISNULL(CAST(@PKIdEgreAdecuacion AS NVARCHAR), 'NULL'));
    SET @Parameters = CONCAT(
        'Action=', ISNULL(CONVERT(NVARCHAR(30), @Action), 'NULL'),
        ', PKIdEgreAdecuacion=', ISNULL(CONVERT(NVARCHAR(30), @PKIdEgreAdecuacion), 'NULL'),
        ', Autorizado=', ISNULL(CONVERT(NVARCHAR(10), @Autorizado), 'NULL'),
        ', IdUser=', ISNULL(CONVERT(NVARCHAR(30), @IdUser), 'NULL'),
        ', idMenu=', ISNULL(CONVERT(NVARCHAR(30), @idMenu), 'NULL'),
        ', FkIdAnioSis=', ISNULL(CONVERT(NVARCHAR(30), @FkIdAnioSis), 'NULL'),
        ', FkIdTipoAdecuacionPres=', ISNULL(CONVERT(NVARCHAR(30), @FkIdTipoAdecuacionPres), 'NULL'),
        ', FkIdEstatusAdecuacionPres=', ISNULL(CONVERT(NVARCHAR(30), @FkIdEstatusAdecuacionPres), 'NULL'),
        ', Justificacion=', ISNULL(LEFT(@Justificacion, 300), 'NULL'),
        ', Fecha=', ISNULL(CONVERT(NVARCHAR(50), @Fecha, 121), 'NULL')
    );

    EXEC [SIS].[WriteSystemLog]
        @FK_IdOrigenLogMessage__SIS = 1,
        @Date = @today,
        @_Type = 1,
        @ProgName = 'PRES.sp_MantenimientoEgresoAdecuacion',
        @EmployeeNo = @IdUser,
        @Category = NULL,
        @IPClient = NULL,
        @HostName = NULL,
        @Thread = NULL,
        @Level = 'INFO',
        @Logger = NULL,
        @Message = @message,
        @Exception = NULL,
        @Context = NULL,
        @MethodName = 'PRES.sp_MantenimientoEgresoAdecuacion',
        @Parameters = @Parameters,
        @ExecutionTime = '0';

    SET @message = '';

    BEGIN TRY
        -- Validaciones iniciales
        IF @Action NOT IN (1, 2, 3)
        BEGIN
            SET @tipo = 'ERROR';
            SET @message = 'Acción no válida. Use 1=Insert, 2=Update, 3=Delete';
            GOTO ERR_HANDLER;
        END

        IF @Action IN (1, 2) AND (@FkIdAnioSis IS NULL OR @FkIdTipoAdecuacionPres IS NULL OR 
                                  @FkIdEstatusAdecuacionPres IS NULL OR @Fecha IS NULL)
        BEGIN
            SET @tipo = 'ERROR';
            SET @message = 'Faltan datos obligatorios (Año, Tipo de Adecuación, Estatus o Fecha).';
            GOTO ERR_HANDLER;
        END

        -- Preparar datos comunes
        SET @NombrePoliza = CONCAT(N'Pres. Modificado: ', @FKIdAnio_SIS, N' ', ISNULL(@Justificacion, N''));

        -- Lógica de póliza para INSERT
        IF @Action = 1
        BEGIN
            IF @FKIdPoliza_CONTA IS NULL OR ISNULL((SELECT TOP (1) ClavePoliza FROM CONTA.Poliza WHERE PKIdPoliza = @FKIdPoliza_CONTA), N'') = N'NUEVA'
            BEGIN
                SET @CrearPoliza = 1;
                EXEC [CONTA].[SP_CREATE_ClavePoliza]
                    @FK_IdAnio__SIS = @FKIdAnio_SIS,
                    @FK_IdMesConta__SIS = @FKIdMes_SIS,
                    @FK_IdTipoPolizaConta__SIS = @FKIdTipoPoliza_SIS,
                    @CT_ModifiedBy = @IdUser,
                    @ClavePoliza = @ClavePoliza OUTPUT,
                    @Error = @ErrorPoliza OUTPUT;

                IF ISNULL(@ClavePoliza, N'') = N''
                BEGIN
                    SET @tipo = 'ERROR';
                    SET @message = CONCAT('No se pudo generar la póliza. ', ISNULL(@ErrorPoliza, ''));
                    GOTO ERR_HANDLER;
                END
            END
        END
        ELSE IF @Action = 2
        BEGIN
            -- Si no viene el ID de póliza, obtener el actual
            IF @FKIdPoliza_CONTA IS NULL AND @PKIdEgreAdecuacion IS NOT NULL
            BEGIN
                SELECT @FKIdPoliza_CONTA = FKIdPoliza_CONTA
                FROM PRES.EgreAdecuacion
                WHERE PKIdEgreAdecuacion = @PKIdEgreAdecuacion AND Activo = 1;
            END
        END

        BEGIN TRANSACTION;

        -- ===============================================================
        -- ACCIÓN INSERT (1)
        -- ===============================================================
        IF @Action = 1
        BEGIN
            IF @CrearPoliza = 1
            BEGIN
                INSERT INTO CONTA.Poliza (
                    FKIdAnio_SIS, FKIdMes_SIS, FKIdTipoPoliza_SIS, ClavePoliza,
                    NombrePoliza, FechaPoliza, EstaBalanceado, PermitirModificar,
                    FKIdAccionAutorizar_SIS, Autorizado, FechaSolicitud, FechaAutorizacion,
                    Activo, FechaCreacion, UsuarioCreacion
                )
                VALUES (
                    @FKIdAnio_SIS, @FKIdMes_SIS, @FKIdTipoPoliza_SIS, @ClavePoliza,
                    @NombrePoliza, @FechaPoliza, 0, 1,
                    NULL, 0, @today, NULL,
                    1, @today, @IdUser
                );
                SET @FKIdPoliza_CONTA = SCOPE_IDENTITY();
            END

            -- Obtener consecutivo seguro (con row_number optimizado)
            ;WITH ConsecutivoCTE AS (
                SELECT TOP 1
                    ISNULL(TRY_CONVERT(INT, RIGHT(Clave, 4)), 0) + 1 AS Sig
                FROM PRES.EgreAdecuacion WITH (UPDLOCK, HOLDLOCK)
                WHERE FKIdAnio_SIS = @FKIdAnio_SIS
                ORDER BY TRY_CONVERT(INT, RIGHT(Clave, 4)) DESC
            )
            SELECT @Consecutivo = Sig FROM ConsecutivoCTE;
            SET @Consecutivo = ISNULL(@Consecutivo, 1);
            SET @Clave = CONCAT(N'ADQ-', @FKIdAnio_SIS, FORMAT(@Consecutivo, N'D4'));

            INSERT INTO PRES.EgreAdecuacion (
                Clave, FKIdTipoAdecuacion_PRES, FKIdEstatusAdecuacion_PRES,
                Justificacion, Fecha, FKIdPoliza_CONTA, FKIdAnio_SIS,
                Autorizado, FKIdAccionAdecuacionMaster_PRES,
                FechaSolicitud, FechaAutorizacion, Activo, FechaCreacion, UsuarioCreacion
            )
            VALUES (
                @Clave, @FkIdTipoAdecuacionPres, @FkIdEstatusAdecuacionPres,
                @Justificacion, @Fecha, @FKIdPoliza_CONTA, @FKIdAnio_SIS,
                @Autorizado, ISNULL(@FkIdAccionAdecuacionMasterPres, 1),
                @FechaSolicitud, @FechaAutorizacion, 1, @today, @IdUser
            );

            SET @Id = SCOPE_IDENTITY();
            SET @tipo = 'OK';
            SET @message = CONCAT('Se registró correctamente la adecuación. ', ISNULL(@AlertMessage, ''), ' ', @Id);
        END

        -- ===============================================================
        -- ACCIÓN UPDATE (2)
        -- ===============================================================
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdEgreAdecuacion IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.EgreAdecuacion WHERE PKIdEgreAdecuacion = @PKIdEgreAdecuacion AND Activo = 1)
            BEGIN
                SET @tipo = 'ERROR';
                SET @message = 'Adecuación no encontrada para actualizar.';
                GOTO ERR_HANDLER;
            END

            UPDATE PRES.EgreAdecuacion
            SET
                FKIdTipoAdecuacion_PRES = @FkIdTipoAdecuacionPres,
                FKIdEstatusAdecuacion_PRES = @FkIdEstatusAdecuacionPres,
                Justificacion = @Justificacion,
                Fecha = @Fecha,
                Autorizado = @Autorizado,
                FKIdAccionAdecuacionMaster_PRES = ISNULL(@FkIdAccionAdecuacionMasterPres, FKIdAccionAdecuacionMaster_PRES),
                FechaSolicitud = @FechaSolicitud,
                FechaAutorizacion = @FechaAutorizacion,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdEgreAdecuacion = @PKIdEgreAdecuacion;

            -- Actualizar póliza asociada si existe
            IF @FKIdPoliza_CONTA IS NOT NULL
            BEGIN
                UPDATE CONTA.Poliza
                SET
                    NombrePoliza = @NombrePoliza,
                    FechaPoliza = @FechaPoliza,
                    FechaModificacion = @today,
                    UsuarioModificacion = @IdUser
                WHERE PKIdPoliza = @FKIdPoliza_CONTA AND Activo = 1;
            END

            SET @Id = @PKIdEgreAdecuacion;
            SET @tipo = 'OK';
            SET @message = CONCAT('Se actualizó correctamente la adecuación. ', ISNULL(@AlertMessage, ''), ' ', @Id);
        END

        -- ===============================================================
        -- ACCIÓN DELETE (3)
        -- ===============================================================
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdEgreAdecuacion IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.EgreAdecuacion WHERE PKIdEgreAdecuacion = @PKIdEgreAdecuacion AND Activo = 1)
            BEGIN
                SET @tipo = 'ERROR';
                SET @message = 'Adecuación no encontrada para eliminar.';
                GOTO ERR_HANDLER;
            END

            UPDATE PRES.EgreAdecuacion
            SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser
            WHERE PKIdEgreAdecuacion = @PKIdEgreAdecuacion;

            UPDATE PRES.EgreAdecuacionDetalle
            SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser
            WHERE FKIdEgreAdecuacion_PRES = @PKIdEgreAdecuacion AND Activo = 1;

            SET @Id = @PKIdEgreAdecuacion;
            SET @tipo = 'OK';
            SET @message = CONCAT('Se eliminó correctamente la adecuación. ', ISNULL(@AlertMessage, ''), ' ', @PKIdEgreAdecuacion);
        END

        -- Si llegamos aquí, todo bien -> commit y salida exitosa
        IF @@TRANCOUNT > 0 AND XACT_STATE() = 1
            COMMIT TRANSACTION;

        GOTO FINISH;

        ERR_HANDLER:
        IF @@TRANCOUNT > 0
        BEGIN
            IF XACT_STATE() = 1
                ROLLBACK TRANSACTION;
            ELSE IF XACT_STATE() = -1
                ROLLBACK TRANSACTION;
        END

        -- Salida con error controlado
        SELECT JSON_QUERY(
            CONCAT('{"tipo":"', @tipo, '","mensaje":"', STRING_ESCAPE(ISNULL(@message, ''), 'json'), '","liga":""}')
        ) AS ResultJson;
        RETURN -1;

        FINISH:
        -- Salida exitosa
        SELECT JSON_QUERY(
            CONCAT('{"tipo":"', @tipo, '","mensaje":"', STRING_ESCAPE(ISNULL(@message, ''), 'json'), '","liga":"id:', ISNULL(CAST(@Id AS NVARCHAR), ''), '"}')
        ) AS ResultJson;
        RETURN 0;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            IF XACT_STATE() = 1
                ROLLBACK TRANSACTION;
            ELSE IF XACT_STATE() = -1
                ROLLBACK TRANSACTION;
        END

        SET @errorMessage = CONCAT(
            ISNULL(PROGRAM_NAME(), ''), CHAR(10),
            'Error: ', ERROR_MESSAGE(), CHAR(10),
            'Línea: ', ERROR_LINE()
        );

        SELECT JSON_QUERY(
            CONCAT('{"tipo":"ERROR","mensaje":"', STRING_ESCAPE(@errorMessage, 'json'), '","liga":""}')
        ) AS ResultJson;
        RETURN -1;
    END CATCH
END

GO

CREATE OR ALTER PROCEDURE [CONTA].[SP_UPDATE_PolizaBalanceada] (
    @PKIdPoliza int,
    @IdUser int = NULL,
    @Error nvarchar(max) = NULL OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        DECLARE
            @Haber decimal(18, 2),
            @Debe decimal(18, 2),
            @EstaBalanceado bit;

        SELECT
            @Haber = ISNULL(SUM(ImporteHaber), 0),
            @Debe = ISNULL(SUM(ImporteDebe), 0)
        FROM CONTA.PolizaDetalle
        WHERE Activo = 1
          AND FKIdPoliza_CONTA = @PKIdPoliza;

        SET @EstaBalanceado = CASE WHEN @Haber = @Debe THEN 1 ELSE 0 END;

        UPDATE CONTA.Poliza
        SET
            EstaBalanceado = @EstaBalanceado,
            FechaModificacion = SYSDATETIME(),
            UsuarioModificacion = @IdUser
        WHERE PKIdPoliza = @PKIdPoliza
          AND Activo = 1;

        SET @Error = NULL;
        RETURN 0;
    END TRY
    BEGIN CATCH
        SET @Error = CONCAT(N'Error: ', ERROR_MESSAGE(), N' Linea: ', ERROR_LINE());
        RETURN 1;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE [CONTA].[SP_CREATE_DetallePolizaWOM] (
    @FKIdCuentaContable_CONTA int,
    @FKIdPoliza_CONTA int,
    @Descripcion nvarchar(250),
    @ImporteDebe decimal(18, 2),
    @ImporteHaber decimal(18, 2),
    @FKIdReferencia int,
    @FKIdTipoDetallePoliza_SIS int,
    @IdUser int,
    @Error nvarchar(max) = NULL OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        INSERT INTO CONTA.PolizaDetalle (
            FKIdCuentaContable_CONTA,
            FKIdPoliza_CONTA,
            Descripcion,
            ImporteDebe,
            ImporteHaber,
            FKIdReferencia,
            FKIdTipoDetallePoliza_SIS,
            Activo,
            FechaCreacion,
            UsuarioCreacion
        )
        VALUES (
            @FKIdCuentaContable_CONTA,
            @FKIdPoliza_CONTA,
            @Descripcion,
            ISNULL(@ImporteDebe, 0),
            ISNULL(@ImporteHaber, 0),
            @FKIdReferencia,
            @FKIdTipoDetallePoliza_SIS,
            1,
            SYSDATETIME(),
            @IdUser
        );

        EXEC CONTA.SP_UPDATE_PolizaBalanceada
            @PKIdPoliza = @FKIdPoliza_CONTA,
            @IdUser = @IdUser,
            @Error = @Error OUTPUT;

        RETURN CASE WHEN ISNULL(@Error, N'') = N'' THEN 0 ELSE 1 END;
    END TRY
    BEGIN CATCH
        SET @Error = CONCAT(N'Error: ', ERROR_MESSAGE(), N' Linea: ', ERROR_LINE());
        RETURN 1;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE [PRES].[sp_MantenimientoAdecuacionDisminucion] (
    @Action int,
    @PKIdEgreAdecuacionDetalle int = NULL,
    @FKIdEgresoAutorizado_PRES int = NULL,
    @Justificacion nvarchar(MAX) = NULL,
    @Fecha datetime2(7) = NULL,
    @FKIdEgreAdecuacion_PRES int = NULL,
    @FKIdTipoMovimiento_PRES int = NULL,
    @Enero decimal(18, 2) = 0,
    @Febrero decimal(18, 2) = 0,
    @Marzo decimal(18, 2) = 0,
    @Abril decimal(18, 2) = 0,
    @Mayo decimal(18, 2) = 0,
    @Junio decimal(18, 2) = 0,
    @Julio decimal(18, 2) = 0,
    @Agosto decimal(18, 2) = 0,
    @Septiembre decimal(18, 2) = 0,
    @Octubre decimal(18, 2) = 0,
    @Noviembre decimal(18, 2) = 0,
    @Diciembre decimal(18, 2) = 0,
    @IdC int = NULL,
    @IdUser int = NULL,
    @Id int = NULL OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @tipo nvarchar(20) = N'OK',
        @message nvarchar(max) = N'',
        @liga nvarchar(100) = N'',
        @today datetime2(7) = SYSDATETIME(),
        @signo int,
        @FKIdAnio_SIS int,
        @FKIdPrograma_PRES int,
        @FKIdPartida_SIS int,
        @FKIdPoliza_CONTA int,
        @CuentaModificado int,
        @CuentaPorEjercer int,
        @Importe decimal(18, 2),
        @PresModificado nvarchar(250),
        @PresPorEjercer nvarchar(250),
        @Error nvarchar(max) = N'';

    BEGIN TRY
        IF @Action NOT IN (1, 2, 3)
        BEGIN
            SET @tipo = N'ERROR';
            SET @message = N'Accion no valida para mantenimiento de detalle de adecuacion.';
            GOTO RESULT_HANDLER;
        END

        IF @Action IN (1, 2)
        BEGIN
            SET @PKIdEgreAdecuacionDetalle = COALESCE(@PKIdEgreAdecuacionDetalle, @IdC);

            IF @FKIdEgresoAutorizado_PRES IS NULL
               OR @FKIdEgreAdecuacion_PRES IS NULL
               OR @FKIdTipoMovimiento_PRES IS NULL
            BEGIN
                SET @tipo = N'ERROR';
                SET @message = N'Debe enviar egreso autorizado, adecuacion y tipo de movimiento.';
                GOTO RESULT_HANDLER;
            END

            SET @signo = CASE WHEN @FKIdTipoMovimiento_PRES = 1 THEN 1 ELSE -1 END;

            SELECT
                @FKIdPoliza_CONTA = ea.FKIdPoliza_CONTA,
                @FKIdAnio_SIS = ea.FKIdAnio_SIS
            FROM PRES.EgreAdecuacion ea
            WHERE ea.PKIdEgreAdecuacion = @FKIdEgreAdecuacion_PRES
              AND ea.Activo = 1;

            IF @FKIdPoliza_CONTA IS NULL
            BEGIN
                SET @tipo = N'ERROR';
                SET @message = N'La adecuacion no tiene poliza activa relacionada.';
                GOTO RESULT_HANDLER;
            END

            SELECT
                @FKIdPrograma_PRES = egr.FKIdPrograma_PRES,
                @FKIdPartida_SIS = egr.FKIdPartida_CONTA
            FROM PRES.Vw_EgresoAutorizado egr
            WHERE egr.PKIdEgresoAutorizado = @FKIdEgresoAutorizado_PRES
              AND egr.Activo = 1;

            SELECT
                @CuentaModificado = mc.FKIdCuentaContableModificado,
                @CuentaPorEjercer = mc.FKIdCuentaContablePorEjercer
            FROM CONTA.MatrizConversion mc
            WHERE mc.FKIdAnio_SIS = @FKIdAnio_SIS
              AND mc.FKIdPrograma_PRES = @FKIdPrograma_PRES
              AND mc.FKIdPartida_SIS = @FKIdPartida_SIS
              AND mc.Activo = 1;

            IF @CuentaModificado IS NULL OR @CuentaPorEjercer IS NULL
            BEGIN
                SET @tipo = N'ERROR';
                SET @message = N'ERROR en la matriz de conversion.';
                GOTO RESULT_HANDLER;
            END

            SET @Importe = ABS(
                ISNULL(@Enero, 0) + ISNULL(@Febrero, 0) + ISNULL(@Marzo, 0) +
                ISNULL(@Abril, 0) + ISNULL(@Mayo, 0) + ISNULL(@Junio, 0) +
                ISNULL(@Julio, 0) + ISNULL(@Agosto, 0) + ISNULL(@Septiembre, 0) +
                ISNULL(@Octubre, 0) + ISNULL(@Noviembre, 0) + ISNULL(@Diciembre, 0)
            );

            SET @PresModificado = LEFT(CONCAT(N'Presupuesto Modificado ', ISNULL(@Justificacion, N'')), 250);
            SET @PresPorEjercer = LEFT(CONCAT(N'Presupuesto por Ejercer ', ISNULL(@Justificacion, N'')), 250);
        END

        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            INSERT INTO PRES.EgreAdecuacionDetalle (
                FKIdEgresoAutorizado_PRES,
                Justificacion,
                Fecha,
                FKIdEgreAdecuacion_PRES,
                FKIdTipoMovimiento_PRES,
                Enero,
                Febrero,
                Marzo,
                Abril,
                Mayo,
                Junio,
                Julio,
                Agosto,
                Septiembre,
                Octubre,
                Noviembre,
                Diciembre,
                Activo,
                FechaCreacion,
                UsuarioCreacion
            )
            VALUES (
                @FKIdEgresoAutorizado_PRES,
                @Justificacion,
                ISNULL(@Fecha, @today),
                @FKIdEgreAdecuacion_PRES,
                @FKIdTipoMovimiento_PRES,
                ISNULL(@Enero, 0) * @signo,
                ISNULL(@Febrero, 0) * @signo,
                ISNULL(@Marzo, 0) * @signo,
                ISNULL(@Abril, 0) * @signo,
                ISNULL(@Mayo, 0) * @signo,
                ISNULL(@Junio, 0) * @signo,
                ISNULL(@Julio, 0) * @signo,
                ISNULL(@Agosto, 0) * @signo,
                ISNULL(@Septiembre, 0) * @signo,
                ISNULL(@Octubre, 0) * @signo,
                ISNULL(@Noviembre, 0) * @signo,
                ISNULL(@Diciembre, 0) * @signo,
                1,
                @today,
                @IdUser
            );

            SET @Id = CONVERT(int, SCOPE_IDENTITY());
        END
        ELSE IF @Action = 2
        BEGIN
            SET @Id = @PKIdEgreAdecuacionDetalle;

            UPDATE PRES.EgreAdecuacionDetalle
            SET
                FKIdEgresoAutorizado_PRES = @FKIdEgresoAutorizado_PRES,
                Justificacion = @Justificacion,
                Fecha = ISNULL(@Fecha, Fecha),
                FKIdEgreAdecuacion_PRES = @FKIdEgreAdecuacion_PRES,
                FKIdTipoMovimiento_PRES = @FKIdTipoMovimiento_PRES,
                Enero = ISNULL(@Enero, 0) * @signo,
                Febrero = ISNULL(@Febrero, 0) * @signo,
                Marzo = ISNULL(@Marzo, 0) * @signo,
                Abril = ISNULL(@Abril, 0) * @signo,
                Mayo = ISNULL(@Mayo, 0) * @signo,
                Junio = ISNULL(@Junio, 0) * @signo,
                Julio = ISNULL(@Julio, 0) * @signo,
                Agosto = ISNULL(@Agosto, 0) * @signo,
                Septiembre = ISNULL(@Septiembre, 0) * @signo,
                Octubre = ISNULL(@Octubre, 0) * @signo,
                Noviembre = ISNULL(@Noviembre, 0) * @signo,
                Diciembre = ISNULL(@Diciembre, 0) * @signo,
                Activo = 1,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdEgreAdecuacionDetalle = @PKIdEgreAdecuacionDetalle
              AND Activo = 1;

            IF @@ROWCOUNT = 0
            BEGIN
                SET @tipo = N'ERROR';
                SET @message = N'No se encontro el detalle de adecuacion para modificar.';
                ROLLBACK TRANSACTION;
                GOTO RESULT_HANDLER;
            END

            UPDATE CONTA.PolizaDetalle
            SET
                Activo = 0,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE FKIdPoliza_CONTA = @FKIdPoliza_CONTA
              AND FKIdReferencia = @Id
              AND Activo = 1;
        END
        ELSE IF @Action = 3
        BEGIN
            SELECT
                @Id = det.PKIdEgreAdecuacionDetalle,
                @FKIdPoliza_CONTA = enc.FKIdPoliza_CONTA
            FROM PRES.EgreAdecuacionDetalle det
            INNER JOIN PRES.EgreAdecuacion enc ON det.FKIdEgreAdecuacion_PRES = enc.PKIdEgreAdecuacion
            WHERE det.PKIdEgreAdecuacionDetalle = @IdC
              AND det.Activo = 1;

            UPDATE PRES.EgreAdecuacionDetalle
            SET
                Activo = 0,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdEgreAdecuacionDetalle = @IdC
              AND Activo = 1;

            IF @@ROWCOUNT = 0
            BEGIN
                SET @tipo = N'ERROR';
                SET @message = N'No se encontro el detalle de adecuacion para eliminar.';
                ROLLBACK TRANSACTION;
                GOTO RESULT_HANDLER;
            END

            UPDATE CONTA.PolizaDetalle
            SET
                Activo = 0,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE FKIdPoliza_CONTA = @FKIdPoliza_CONTA
              AND FKIdReferencia = @IdC
              AND Activo = 1;

            EXEC CONTA.SP_UPDATE_PolizaBalanceada
                @PKIdPoliza = @FKIdPoliza_CONTA,
                @IdUser = @IdUser,
                @Error = @Error OUTPUT;

            IF ISNULL(@Error, N'') <> N''
            BEGIN
                SET @tipo = N'ERROR';
                SET @message = @Error;
                ROLLBACK TRANSACTION;
                GOTO RESULT_HANDLER;
            END

            SET @message = N'Se elimino el registro correctamente.';
            SET @liga = CONCAT(N'id:', @IdC);
        END

        IF @Action IN (1, 2)
        BEGIN
            IF @FKIdTipoMovimiento_PRES = 2
            BEGIN
                EXEC CONTA.SP_CREATE_DetallePolizaWOM
                    @FKIdCuentaContable_CONTA = @CuentaModificado,
                    @FKIdPoliza_CONTA = @FKIdPoliza_CONTA,
                    @Descripcion = @PresModificado,
                    @ImporteDebe = @Importe,
                    @ImporteHaber = 0,
                    @FKIdReferencia = @Id,
                    @FKIdTipoDetallePoliza_SIS = 1,
                    @IdUser = @IdUser,
                    @Error = @Error OUTPUT;

                IF ISNULL(@Error, N'') = N''
                    EXEC CONTA.SP_CREATE_DetallePolizaWOM
                        @FKIdCuentaContable_CONTA = @CuentaPorEjercer,
                        @FKIdPoliza_CONTA = @FKIdPoliza_CONTA,
                        @Descripcion = @PresPorEjercer,
                        @ImporteDebe = 0,
                        @ImporteHaber = @Importe,
                        @FKIdReferencia = @Id,
                        @FKIdTipoDetallePoliza_SIS = 2,
                        @IdUser = @IdUser,
                        @Error = @Error OUTPUT;
            END
            ELSE
            BEGIN
                EXEC CONTA.SP_CREATE_DetallePolizaWOM
                    @FKIdCuentaContable_CONTA = @CuentaPorEjercer,
                    @FKIdPoliza_CONTA = @FKIdPoliza_CONTA,
                    @Descripcion = @PresPorEjercer,
                    @ImporteDebe = 0,
                    @ImporteHaber = @Importe,
                    @FKIdReferencia = @Id,
                    @FKIdTipoDetallePoliza_SIS = 2,
                    @IdUser = @IdUser,
                    @Error = @Error OUTPUT;

                IF ISNULL(@Error, N'') = N''
                    EXEC CONTA.SP_CREATE_DetallePolizaWOM
                        @FKIdCuentaContable_CONTA = @CuentaModificado,
                        @FKIdPoliza_CONTA = @FKIdPoliza_CONTA,
                        @Descripcion = @PresModificado,
                        @ImporteDebe = @Importe,
                        @ImporteHaber = 0,
                        @FKIdReferencia = @Id,
                        @FKIdTipoDetallePoliza_SIS = 1,
                        @IdUser = @IdUser,
                        @Error = @Error OUTPUT;
            END

            IF ISNULL(@Error, N'') <> N''
            BEGIN
                SET @tipo = N'ERROR';
                SET @message = @Error;
                ROLLBACK TRANSACTION;
                GOTO RESULT_HANDLER;
            END

            SET @message = CASE
                WHEN @Action = 1 THEN CONCAT(N'Se afecto correctamente el presupuesto. Presupuesto afectado ', FORMAT(@Importe, 'C', 'es-MX'))
                ELSE CONCAT(N'Se actualizo correctamente el presupuesto. Presupuesto afectado ', FORMAT(@Importe, 'C', 'es-MX'), N' Poliza ', @FKIdPoliza_CONTA)
            END;
            SET @liga = CONCAT(N'id:', @Id);
        END

        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;

        RESULT_HANDLER:
        SELECT JSON_QUERY(
            CONCAT(
                N'{"tipo":"', @tipo,
                N'","mensaje":"', STRING_ESCAPE(ISNULL(@message, N''), 'json'),
                N'","liga":"', STRING_ESCAPE(ISNULL(@liga, N''), 'json'),
                N'"}'
            )
        ) AS ResultJson;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @message = CONCAT(
            ISNULL(@message, N''),
            N' Error: ', ERROR_MESSAGE(),
            N' Linea: ', ERROR_LINE()
        );

        IF OBJECT_ID(N'[SIS].[WriteSystemLog]', N'P') IS NOT NULL
        BEGIN
            EXEC [SIS].[WriteSystemLog]
                @FK_IdOrigenLogMessage__SIS = 1,
                @Date = @today,
                @_Type = 1,
                @ProgName = N'PRES.sp_MantenimientoAdecuacionDisminucion',
                @EmployeeNo = @IdUser,
                @Category = NULL,
                @IPClient = NULL,
                @HostName = NULL,
                @Thread = NULL,
                @Level = N'ERROR',
                @Logger = NULL,
                @Message = @message,
                @Exception = NULL,
                @Context = NULL,
                @MethodName = N'PRES.sp_MantenimientoAdecuacionDisminucion',
                @Parameters = NULL,
                @ExecutionTime = N'0';
        END

        SELECT JSON_QUERY(
            CONCAT(
                N'{"tipo":"ERROR","mensaje":"',
                STRING_ESCAPE(ISNULL(@message, N''), 'json'),
                N'","liga":""}'
            )
        ) AS ResultJson;
    END CATCH
END
GO


USE [GestionEmpresarial];
GO

-- =============================================
-- 1. Crear tabla EstatusOrdenCompra (si no existe)
-- =============================================
IF OBJECT_ID(N'ORCO.EstatusOrdenCompra', N'U') IS NULL
BEGIN
    CREATE TABLE ORCO.EstatusOrdenCompra (
        PK_IdEstatusOrdenCompra INT IDENTITY(1,1) NOT NULL,
        Descripcion NVARCHAR(50) NOT NULL,
        Color NVARCHAR(8) NOT NULL,
        CT_CreatedBy INT NOT NULL,
        CT_CreatedDate DATETIME NOT NULL,
        CT_ModifiedBy INT NULL,
        CT_ModifiedDate DATETIME NULL,
        CT_LIVE BIT NULL,
        CONSTRAINT PK_EstatusOrdenCompra PRIMARY KEY CLUSTERED (PK_IdEstatusOrdenCompra)
    );
END
GO

-- =============================================
-- 2. Crear tabla OrdenCompra
-- =============================================
IF OBJECT_ID(N'ORCO.OrdenCompra', N'U') IS NULL
BEGIN
    CREATE TABLE ORCO.OrdenCompra (
        PKIdOrdenCompra INT IDENTITY(1,1) NOT NULL,
        FKIdEmpresa_SIS INT NOT NULL,
        FKIdRequisicion_ORCO INT NOT NULL,
        FKIdProveedor_SIS INT NOT NULL,
        FKIdPoliza_CONTA INT NULL,
        FKIdEstatusOrdenCompra_ORCO INT NOT NULL,
        NumeroOrdenCompra NVARCHAR(50) NOT NULL,
        Descripcion NVARCHAR(500) NULL,
        FechaOrdenCompra DATE NOT NULL,
        FechaRequerida DATE NULL,
        FechaEntrega DATE NULL,
        FechaVigencia DATE NULL,
        FechaCancelacion DATE NULL,
        MotivoCancelacion NVARCHAR(MAX) NULL,
        Subtotal DECIMAL(20,4) NOT NULL CONSTRAINT DF_OrdenCompra_Subtotal DEFAULT 0,
        Iva DECIMAL(20,4) NOT NULL CONSTRAINT DF_OrdenCompra_Iva DEFAULT 0,
        Total DECIMAL(20,4) NOT NULL CONSTRAINT DF_OrdenCompra_Total DEFAULT 0,
        MonedaId INT NULL,
        TipoCambio DECIMAL(18,6) NULL,
        Observaciones NVARCHAR(MAX) NULL,
        CompraDirecta BIT NOT NULL CONSTRAINT DF_OrdenCompra_CompraDirecta DEFAULT 0,
        FL_Documento NVARCHAR(1000) NULL,
        Activo BIT NOT NULL CONSTRAINT DF_OrdenCompra_Activo DEFAULT 1,
        FechaCreacion DATETIME2(7) NOT NULL CONSTRAINT DF_OrdenCompra_FechaCreacion DEFAULT SYSDATETIME(),
        UsuarioCreacion INT NOT NULL,
        FechaModificacion DATETIME2(7) NULL,
        UsuarioModificacion INT NULL,
        CONSTRAINT PK_OrdenCompra PRIMARY KEY CLUSTERED (PKIdOrdenCompra),
        CONSTRAINT FK_OrdenCompra_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
        CONSTRAINT FK_OrdenCompra_Requisicion FOREIGN KEY (FKIdRequisicion_ORCO) REFERENCES ORCO.Requisicion(PKIdRequisicion),
        CONSTRAINT FK_OrdenCompra_Proveedor FOREIGN KEY (FKIdProveedor_SIS) REFERENCES SIS.Proveedor(PKIdProveedor),
        CONSTRAINT FK_OrdenCompra_Poliza FOREIGN KEY (FKIdPoliza_CONTA) REFERENCES CONTA.Poliza(PKIdPoliza),
        CONSTRAINT FK_OrdenCompra_Estatus FOREIGN KEY (FKIdEstatusOrdenCompra_ORCO) REFERENCES ORCO.EstatusOrdenCompra(PK_IdEstatusOrdenCompra),
        CONSTRAINT UQ_OrdenCompra_Numero UNIQUE (NumeroOrdenCompra)
    );
END
GO

CREATE INDEX IX_OrdenCompra_Estatus ON ORCO.OrdenCompra (FKIdEstatusOrdenCompra_ORCO) WHERE Activo = 1;
CREATE INDEX IX_OrdenCompra_Proveedor ON ORCO.OrdenCompra (FKIdProveedor_SIS) WHERE Activo = 1;
CREATE INDEX IX_OrdenCompra_Fecha ON ORCO.OrdenCompra (FechaOrdenCompra) WHERE Activo = 1;
CREATE INDEX IX_OrdenCompra_Requisicion ON ORCO.OrdenCompra (FKIdRequisicion_ORCO) WHERE Activo = 1;
GO

-- =============================================
-- 3. Crear tabla OrdenCompraDetalle
-- =============================================
IF OBJECT_ID(N'ORCO.OrdenCompraDetalle', N'U') IS NULL
BEGIN
    CREATE TABLE ORCO.OrdenCompraDetalle (
        PKIdOrdenCompraDetalle INT IDENTITY(1,1) NOT NULL,
        FKIdOrdenCompra_ORCO INT NOT NULL,
        FKIdRequisicionDetalle_ORCO INT NULL,
        FKIdCotizacionDetalle_ORCO INT NULL,
        FKIdTipoBien_ALMA INT NOT NULL,
        FKIdUnidades_ALMA INT NOT NULL,
        CantidadSolicitada DECIMAL(18,4) NOT NULL,
        CantidadRecibida DECIMAL(18,4) NOT NULL CONSTRAINT DF_OrdenCompraDetalle_CantidadRecibida DEFAULT 0,
        CantidadPendiente AS (CantidadSolicitada - CantidadRecibida),
        PrecioUnitario DECIMAL(20,4) NOT NULL,
        Importe AS (CantidadSolicitada * PrecioUnitario),
        Iva DECIMAL(20,4) NOT NULL CONSTRAINT DF_OrdenCompraDetalle_Iva DEFAULT 0,
        TotalDetalle AS ((CantidadSolicitada * PrecioUnitario) + Iva),
        Observaciones NVARCHAR(MAX) NULL,
        Activo BIT NOT NULL CONSTRAINT DF_OrdenCompraDetalle_Activo DEFAULT 1,
        FechaCreacion DATETIME2(7) NOT NULL CONSTRAINT DF_OrdenCompraDetalle_FechaCreacion DEFAULT SYSDATETIME(),
        UsuarioCreacion INT NOT NULL,
        FechaModificacion DATETIME2(7) NULL,
        UsuarioModificacion INT NULL,
        CONSTRAINT PK_OrdenCompraDetalle PRIMARY KEY CLUSTERED (PKIdOrdenCompraDetalle),
        CONSTRAINT FK_OrdenCompraDetalle_OrdenCompra FOREIGN KEY (FKIdOrdenCompra_ORCO) REFERENCES ORCO.OrdenCompra(PKIdOrdenCompra),
        CONSTRAINT FK_OrdenCompraDetalle_RequisicionDetalle FOREIGN KEY (FKIdRequisicionDetalle_ORCO) REFERENCES ORCO.RequisicionDetalle(PKIdRequisicionDetalle),
        CONSTRAINT FK_OrdenCompraDetalle_CotizacionDetalle FOREIGN KEY (FKIdCotizacionDetalle_ORCO) REFERENCES ORCO.CotizacionDetalle(PKIdCotizacionDetalle),
        CONSTRAINT FK_OrdenCompraDetalle_TipoBien FOREIGN KEY (FKIdTipoBien_ALMA) REFERENCES ALMA.TipoBien(PKIdTipoBien),
        CONSTRAINT FK_OrdenCompraDetalle_Unidades FOREIGN KEY (FKIdUnidades_ALMA) REFERENCES ALMA.Unidades(PKIdUnidades)
    );
END
GO

CREATE INDEX IX_OrdenCompraDetalle_Orden ON ORCO.OrdenCompraDetalle (FKIdOrdenCompra_ORCO) WHERE Activo = 1;
CREATE INDEX IX_OrdenCompraDetalle_TipoBien ON ORCO.OrdenCompraDetalle (FKIdTipoBien_ALMA) WHERE Activo = 1;
CREATE INDEX IX_OrdenCompraDetalle_RequisicionDet ON ORCO.OrdenCompraDetalle (FKIdRequisicionDetalle_ORCO) WHERE Activo = 1;
GO

-- =============================================
-- 4. Crear tabla OrdenCompraPartida
-- =============================================
IF OBJECT_ID(N'ORCO.OrdenCompraPartida', N'U') IS NULL
BEGIN
    CREATE TABLE ORCO.OrdenCompraPartida (
        PKIdOrdenCompraPartida INT IDENTITY(1,1) NOT NULL,
        FKIdOrdenCompra_ORCO INT NOT NULL,
        FKIdPartida_CONTA INT NOT NULL,
        FKIdFuenteFinanciamiento_PRES INT NULL,
        Importe DECIMAL(20,4) NOT NULL,
        Observaciones NVARCHAR(MAX) NULL,
        Activo BIT NOT NULL CONSTRAINT DF_OrdenCompraPartida_Activo DEFAULT 1,
        FechaCreacion DATETIME2(7) NOT NULL CONSTRAINT DF_OrdenCompraPartida_FechaCreacion DEFAULT SYSDATETIME(),
        UsuarioCreacion INT NOT NULL,
        FechaModificacion DATETIME2(7) NULL,
        UsuarioModificacion INT NULL,
        CONSTRAINT PK_OrdenCompraPartida PRIMARY KEY CLUSTERED (PKIdOrdenCompraPartida),
        CONSTRAINT FK_OrdenCompraPartida_OrdenCompra FOREIGN KEY (FKIdOrdenCompra_ORCO) REFERENCES ORCO.OrdenCompra(PKIdOrdenCompra),
        CONSTRAINT FK_OrdenCompraPartida_Partida FOREIGN KEY (FKIdPartida_CONTA) REFERENCES CONTA.Partida(PKIdPartida),
        CONSTRAINT FK_OrdenCompraPartida_Fuente FOREIGN KEY (FKIdFuenteFinanciamiento_PRES) REFERENCES PRES.FuenteFinanciamiento(PKIdFuenteFinanciamiento)
    );
END
GO

CREATE INDEX IX_OrdenCompraPartida_Orden ON ORCO.OrdenCompraPartida (FKIdOrdenCompra_ORCO) WHERE Activo = 1;
CREATE INDEX IX_OrdenCompraPartida_Partida ON ORCO.OrdenCompraPartida (FKIdPartida_CONTA) WHERE Activo = 1;
GO