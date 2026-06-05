USE [GestionEmpresarial];
GO

-- =========================
-- CATALOGOS
-- =========================
IF OBJECT_ID(N'ALMA.EstatusInventario', N'U') IS NULL
CREATE TABLE ALMA.EstatusInventario (
    PKIdEstatusInventario INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_EstatusInventario PRIMARY KEY,
    Descripcion NVARCHAR(80) NOT NULL,
    Color NVARCHAR(20) NULL,
    Orden INT NOT NULL CONSTRAINT DF_EstatusInventario_Orden DEFAULT(0),
    EsFinal BIT NOT NULL CONSTRAINT DF_EstatusInventario_EsFinal DEFAULT(0),
    Activo BIT NOT NULL CONSTRAINT DF_EstatusInventario_Activo DEFAULT(1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_EstatusInventario_FechaCreacion DEFAULT(SYSDATETIME()),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2(0) NULL,
    UsuarioModificacion INT NULL
);
GO

IF OBJECT_ID(N'ALMA.EstatusSolicitudSalida', N'U') IS NULL
CREATE TABLE ALMA.EstatusSolicitudSalida (
    PKIdEstatusSolicitudSalida INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_EstatusSolicitudSalida PRIMARY KEY,
    Descripcion NVARCHAR(80) NOT NULL,
    Color NVARCHAR(20) NULL,
    Orden INT NOT NULL CONSTRAINT DF_EstatusSolicitudSalida_Orden DEFAULT(0),
    EsFinal BIT NOT NULL CONSTRAINT DF_EstatusSolicitudSalida_EsFinal DEFAULT(0),
    Activo BIT NOT NULL CONSTRAINT DF_EstatusSolicitudSalida_Activo DEFAULT(1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_EstatusSolicitudSalida_FechaCreacion DEFAULT(SYSDATETIME()),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2(0) NULL,
    UsuarioModificacion INT NULL
);
GO

-- =========================
-- CALENDARIO INVENTARIOS
-- =========================
IF OBJECT_ID(N'ALMA.CalendarioInventario', N'U') IS NULL
CREATE TABLE ALMA.CalendarioInventario (
    PKIdCalendarioInventario INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_CalendarioInventario PRIMARY KEY,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdArea_SIS INT NULL,
    Anio INT NOT NULL,
    Folio NVARCHAR(30) NOT NULL,
    Descripcion NVARCHAR(300) NOT NULL,
    FechaInicio DATE NOT NULL,
    FechaFin DATE NOT NULL,
    Observaciones NVARCHAR(1000) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_CalendarioInventario_Activo DEFAULT(1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_CalendarioInventario_FechaCreacion DEFAULT(SYSDATETIME()),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2(0) NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT UQ_CalendarioInventario_Folio UNIQUE(Folio),
    CONSTRAINT FK_CalendarioInventario_Empresa FOREIGN KEY(FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_CalendarioInventario_Area FOREIGN KEY(FKIdArea_SIS) REFERENCES SIS.Area(PKIdArea)
);
GO

-- =========================
-- INVENTARIO PATRIMONIAL
-- =========================
IF OBJECT_ID(N'ALMA.Inventario', N'U') IS NULL
CREATE TABLE ALMA.Inventario (
    PKIdInventario INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Inventario PRIMARY KEY,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdCalendarioInventario_ALMA INT NULL,
    FKIdArea_SIS INT NULL,
    FKIdEstatusInventario_ALMA INT NOT NULL,
    Folio NVARCHAR(30) NOT NULL,
    FechaInventario DATE NOT NULL,
    Responsable NVARCHAR(250) NULL,
    Observaciones NVARCHAR(1000) NULL,
    TotalBienes INT NOT NULL CONSTRAINT DF_Inventario_TotalBienes DEFAULT(0),
    TotalLocalizados INT NOT NULL CONSTRAINT DF_Inventario_TotalLocalizados DEFAULT(0),
    TotalDiferencias INT NOT NULL CONSTRAINT DF_Inventario_TotalDiferencias DEFAULT(0),
    Autorizado BIT NOT NULL CONSTRAINT DF_Inventario_Autorizado DEFAULT(0),
    FechaAutorizacion DATETIME2(0) NULL,
    UsuarioAutorizacion INT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Inventario_Activo DEFAULT(1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_Inventario_FechaCreacion DEFAULT(SYSDATETIME()),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2(0) NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT UQ_Inventario_Folio UNIQUE(Folio),
    CONSTRAINT FK_Inventario_Empresa FOREIGN KEY(FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_Inventario_Calendario FOREIGN KEY(FKIdCalendarioInventario_ALMA) REFERENCES ALMA.CalendarioInventario(PKIdCalendarioInventario),
    CONSTRAINT FK_Inventario_Area FOREIGN KEY(FKIdArea_SIS) REFERENCES SIS.Area(PKIdArea),
    CONSTRAINT FK_Inventario_Estatus FOREIGN KEY(FKIdEstatusInventario_ALMA) REFERENCES ALMA.EstatusInventario(PKIdEstatusInventario)
);
GO

IF OBJECT_ID(N'ALMA.InventarioDetalle', N'U') IS NULL
CREATE TABLE ALMA.InventarioDetalle (
    PKIdInventarioDetalle INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_InventarioDetalle PRIMARY KEY,
    FKIdInventario_ALMA INT NOT NULL,
    FKIdBien_ALMA INT NOT NULL,
    ClaveBien NVARCHAR(50) NULL,
    DescripcionBien NVARCHAR(1000) NULL,
    Serie NVARCHAR(1000) NULL,
    UbicacionSistema NVARCHAR(250) NULL,
    UbicacionFisica NVARCHAR(250) NULL,
    Localizado BIT NOT NULL CONSTRAINT DF_InventarioDetalle_Localizado DEFAULT(0),
    TieneDiferencia BIT NOT NULL CONSTRAINT DF_InventarioDetalle_TieneDiferencia DEFAULT(0),
    Observaciones NVARCHAR(1000) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_InventarioDetalle_Activo DEFAULT(1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_InventarioDetalle_FechaCreacion DEFAULT(SYSDATETIME()),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2(0) NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT FK_InventarioDetalle_Inventario FOREIGN KEY(FKIdInventario_ALMA) REFERENCES ALMA.Inventario(PKIdInventario),
    CONSTRAINT FK_InventarioDetalle_Bien FOREIGN KEY(FKIdBien_ALMA) REFERENCES ALMA.Bien(PKIdBien)
);
GO

-- =========================
-- ALMACEN
-- =========================
IF OBJECT_ID(N'ALMA.Almacen', N'U') IS NULL
CREATE TABLE ALMA.Almacen (
    PKIdAlmacen INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Almacen PRIMARY KEY,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdArea_SIS INT NULL,
    FKIdTipoBien_ALMA INT NOT NULL,
    FKIdUnidades_ALMA INT NULL,
    FKIdMotivoES_ALMA INT NULL,
    FKIdDetalleOrdenCompra_ORCO INT NULL,
    Clave NVARCHAR(30) NULL,
    Cantidad DECIMAL(20,4) NOT NULL CONSTRAINT DF_Almacen_Cantidad DEFAULT(0),
    CostoUnitario DECIMAL(20,4) NULL,
    Costo DECIMAL(20,4) NULL,
    Factura NVARCHAR(50) NULL,
    Remision NVARCHAR(50) NULL,
    Lote NVARCHAR(50) NULL,
    FechaEntrada DATE NOT NULL CONSTRAINT DF_Almacen_FechaEntrada DEFAULT(CONVERT(date, GETDATE())),
    FechaCaducidad DATE NULL,
    AplicaAlmacen BIT NOT NULL CONSTRAINT DF_Almacen_AplicaAlmacen DEFAULT(1),
    InventarioCerrado BIT NOT NULL CONSTRAINT DF_Almacen_InventarioCerrado DEFAULT(0),
    EsContabilizado BIT NOT NULL CONSTRAINT DF_Almacen_EsContabilizado DEFAULT(0),
    Activo BIT NOT NULL CONSTRAINT DF_Almacen_Activo DEFAULT(1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_Almacen_FechaCreacion DEFAULT(SYSDATETIME()),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2(0) NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT FK_Almacen_Empresa FOREIGN KEY(FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_Almacen_Area FOREIGN KEY(FKIdArea_SIS) REFERENCES SIS.Area(PKIdArea),
    CONSTRAINT FK_Almacen_TipoBien FOREIGN KEY(FKIdTipoBien_ALMA) REFERENCES ALMA.TipoBien(PKIdTipoBien),
    CONSTRAINT FK_Almacen_MotivoES FOREIGN KEY(FKIdMotivoES_ALMA) REFERENCES ALMA.MotivoES(PKIdMotivoES)
);
GO

/*   ----------------------------------------------------------------------------------  */


-- =========================
-- CATALOGOS BASE
-- =========================
IF NOT EXISTS (SELECT 1 FROM ALMA.EstatusInventario WHERE Descripcion = N'INICIAL')
INSERT INTO ALMA.EstatusInventario (Descripcion, Color, Orden, EsFinal, UsuarioCreacion)
VALUES (N'INICIAL', N'#E3F2FD', 1, 0, 1),
       (N'EN PROCESO', N'#FFF8CC', 2, 0, 1),
       (N'CERRADO', N'#DFF6DD', 3, 1, 1),
       (N'CANCELADO', N'#FFD6D6', 4, 1, 1);
GO

IF NOT EXISTS (SELECT 1 FROM ALMA.EstatusSolicitudSalida WHERE Descripcion = N'INICIAL')
INSERT INTO ALMA.EstatusSolicitudSalida (Descripcion, Color, Orden, EsFinal, UsuarioCreacion)
VALUES (N'INICIAL', N'#E3F2FD', 1, 0, 1),
       (N'AUTORIZADA', N'#FFF8CC', 2, 0, 1),
       (N'SURTIDA', N'#DFF6DD', 3, 1, 1),
       (N'CANCELADA', N'#FFD6D6', 4, 1, 1);
GO

-- =========================
-- SOLICITUD SALIDA
-- =========================
IF OBJECT_ID(N'ALMA.SolicitudSalida', N'U') IS NULL
CREATE TABLE ALMA.SolicitudSalida (
    PKIdSolicitudSalida INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_SolicitudSalida PRIMARY KEY,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdAreaSolicita_SIS INT NULL,
    FKIdAreaEntrega_SIS INT NULL,
    FKIdEstatusSolicitudSalida_ALMA INT NOT NULL,
    Folio NVARCHAR(30) NOT NULL,
    FechaSolicitud DATE NOT NULL CONSTRAINT DF_SolicitudSalida_FechaSolicitud DEFAULT(CONVERT(date, GETDATE())),
    FechaRequerida DATE NULL,
    Solicitante NVARCHAR(250) NULL,
    Justificacion NVARCHAR(1000) NULL,
    Observaciones NVARCHAR(1000) NULL,
    Autorizado BIT NOT NULL CONSTRAINT DF_SolicitudSalida_Autorizado DEFAULT(0),
    FechaAutorizacion DATETIME2(0) NULL,
    UsuarioAutorizacion INT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_SolicitudSalida_Activo DEFAULT(1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_SolicitudSalida_FechaCreacion DEFAULT(SYSDATETIME()),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2(0) NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT UQ_SolicitudSalida_Folio UNIQUE(Folio),
    CONSTRAINT FK_SolicitudSalida_Empresa FOREIGN KEY(FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_SolicitudSalida_AreaSolicita FOREIGN KEY(FKIdAreaSolicita_SIS) REFERENCES SIS.Area(PKIdArea),
    CONSTRAINT FK_SolicitudSalida_AreaEntrega FOREIGN KEY(FKIdAreaEntrega_SIS) REFERENCES SIS.Area(PKIdArea),
    CONSTRAINT FK_SolicitudSalida_Estatus FOREIGN KEY(FKIdEstatusSolicitudSalida_ALMA) REFERENCES ALMA.EstatusSolicitudSalida(PKIdEstatusSolicitudSalida)
);
GO

IF OBJECT_ID(N'ALMA.DetalleSolicitudSalida', N'U') IS NULL
CREATE TABLE ALMA.DetalleSolicitudSalida (
    PKIdDetalleSolicitudSalida INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DetalleSolicitudSalida PRIMARY KEY,
    FKIdSolicitudSalida_ALMA INT NOT NULL,
    FKIdAlmacen_ALMA INT NULL,
    FKIdTipoBien_ALMA INT NOT NULL,
    FKIdUnidades_ALMA INT NULL,
    CantidadSolicitada DECIMAL(20,4) NOT NULL,
    CantidadAutorizada DECIMAL(20,4) NULL,
    CantidadEntregada DECIMAL(20,4) NULL,
    CantidadPendiente DECIMAL(20,4) NOT NULL CONSTRAINT DF_DetalleSolicitudSalida_CantidadPendiente DEFAULT(0),
    Observaciones NVARCHAR(1000) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_DetalleSolicitudSalida_Activo DEFAULT(1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_DetalleSolicitudSalida_FechaCreacion DEFAULT(SYSDATETIME()),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2(0) NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT FK_DetalleSolicitudSalida_Solicitud FOREIGN KEY(FKIdSolicitudSalida_ALMA) REFERENCES ALMA.SolicitudSalida(PKIdSolicitudSalida),
    CONSTRAINT FK_DetalleSolicitudSalida_Almacen FOREIGN KEY(FKIdAlmacen_ALMA) REFERENCES ALMA.Almacen(PKIdAlmacen),
    CONSTRAINT FK_DetalleSolicitudSalida_TipoBien FOREIGN KEY(FKIdTipoBien_ALMA) REFERENCES ALMA.TipoBien(PKIdTipoBien)
);
GO

-- =========================
-- HISTORICOS
-- =========================
IF OBJECT_ID(N'HIS.Inventario_Hist', N'U') IS NULL
CREATE TABLE HIS.Inventario_Hist (
    PKIdInventarioHist INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Inventario_Hist PRIMARY KEY,
    FKIdInventario_ALMA INT NOT NULL,
    AccionHist NVARCHAR(30) NOT NULL,
    Folio NVARCHAR(30) NULL,
    FKIdEmpresa_SIS INT NULL,
    FKIdArea_SIS INT NULL,
    FKIdEstatusInventario_ALMA INT NULL,
    FechaInventario DATE NULL,
    Responsable NVARCHAR(250) NULL,
    Observaciones NVARCHAR(1000) NULL,
    TotalBienes INT NULL,
    TotalLocalizados INT NULL,
    TotalDiferencias INT NULL,
    Activo BIT NOT NULL,
    FechaCreacion DATETIME2(0) NULL,
    UsuarioCreacion INT NULL,
    FechaModificacion DATETIME2(0) NULL,
    UsuarioModificacion INT NULL,
    FechaHist DATETIME2(0) NOT NULL CONSTRAINT DF_InventarioHist_FechaHist DEFAULT(SYSDATETIME()),
    UsuarioHist INT NOT NULL
);
GO

IF OBJECT_ID(N'HIS.InventarioDet_Hist', N'U') IS NULL
CREATE TABLE HIS.InventarioDet_Hist (
    PKIdInventarioDetalleHist INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_InventarioDet_Hist PRIMARY KEY,
    FKIdInventarioDetalle_ALMA INT NOT NULL,
    FKIdInventario_ALMA INT NOT NULL,
    FKIdBien_ALMA INT NOT NULL,
    AccionHist NVARCHAR(30) NOT NULL,
    ClaveBien NVARCHAR(50) NULL,
    DescripcionBien NVARCHAR(1000) NULL,
    Serie NVARCHAR(1000) NULL,
    UbicacionSistema NVARCHAR(250) NULL,
    UbicacionFisica NVARCHAR(250) NULL,
    Localizado BIT NULL,
    TieneDiferencia BIT NULL,
    Observaciones NVARCHAR(1000) NULL,
    Activo BIT NOT NULL,
    FechaHist DATETIME2(0) NOT NULL CONSTRAINT DF_InventarioDetHist_FechaHist DEFAULT(SYSDATETIME()),
    UsuarioHist INT NOT NULL
);
GO

-- =========================
-- VISTAS
-- =========================
CREATE OR ALTER VIEW ALMA.Vw_CalendarioInventarios AS
SELECT c.PKIdCalendarioInventario, c.FKIdEmpresa_SIS, e.Nombre AS EmpresaNombre,
       c.FKIdArea_SIS, a.Nombre AS AreaNombre, c.Anio, c.Folio, c.Descripcion,
       c.FechaInicio, c.FechaFin, c.Observaciones,
       c.Activo, c.FechaCreacion, c.UsuarioCreacion, c.FechaModificacion, c.UsuarioModificacion
FROM ALMA.CalendarioInventario c
INNER JOIN SIS.Empresa e ON c.FKIdEmpresa_SIS = e.PKIdEmpresa
LEFT JOIN SIS.Area a ON c.FKIdArea_SIS = a.PKIdArea;
GO

CREATE OR ALTER VIEW ALMA.Vw_Inventarios AS
SELECT i.PKIdInventario, i.FKIdEmpresa_SIS, e.Nombre AS EmpresaNombre,
       i.FKIdCalendarioInventario_ALMA, c.Folio AS CalendarioFolio,
       i.FKIdArea_SIS, a.Nombre AS AreaNombre,
       i.FKIdEstatusInventario_ALMA, est.Descripcion AS EstatusDescripcion, est.Color AS EstatusColor,
       i.Folio, i.FechaInventario, i.Responsable, i.Observaciones,
       i.TotalBienes, i.TotalLocalizados, i.TotalDiferencias,
       i.Autorizado, i.FechaAutorizacion, i.UsuarioAutorizacion,
       i.Activo, i.FechaCreacion, i.UsuarioCreacion, i.FechaModificacion, i.UsuarioModificacion
FROM ALMA.Inventario i
INNER JOIN SIS.Empresa e ON i.FKIdEmpresa_SIS = e.PKIdEmpresa
LEFT JOIN ALMA.CalendarioInventario c ON i.FKIdCalendarioInventario_ALMA = c.PKIdCalendarioInventario
LEFT JOIN SIS.Area a ON i.FKIdArea_SIS = a.PKIdArea
INNER JOIN ALMA.EstatusInventario est ON i.FKIdEstatusInventario_ALMA = est.PKIdEstatusInventario;
GO

CREATE OR ALTER VIEW ALMA.Vw_InventarioDetalle AS
SELECT d.PKIdInventarioDetalle, d.FKIdInventario_ALMA, i.Folio AS InventarioFolio,
       d.FKIdBien_ALMA, b.Clave AS BienClave, b.Descripcion AS BienDescripcion,
       b.Modelo, b.Serie, b.ValorActual,
       d.ClaveBien, d.DescripcionBien, d.Serie AS SerieCapturada,
       d.UbicacionSistema, d.UbicacionFisica,
       d.Localizado, d.TieneDiferencia, d.Observaciones,
       d.Activo, d.FechaCreacion, d.UsuarioCreacion, d.FechaModificacion, d.UsuarioModificacion
FROM ALMA.InventarioDetalle d
INNER JOIN ALMA.Inventario i ON d.FKIdInventario_ALMA = i.PKIdInventario
INNER JOIN ALMA.Bien b ON d.FKIdBien_ALMA = b.PKIdBien;
GO

CREATE OR ALTER VIEW ALMA.Vw_Almacen AS
SELECT a.PKIdAlmacen, a.FKIdEmpresa_SIS, e.Nombre AS EmpresaNombre,
       a.FKIdArea_SIS, ar.Nombre AS AreaNombre,
       a.FKIdTipoBien_ALMA, tb.CodigoClave AS TipoBienClave, tb.Descripcion AS TipoBienDescripcion,
       a.FKIdUnidades_ALMA, u.Descripcion AS UnidadDescripcion,
       a.FKIdMotivoES_ALMA, m.Descripcion AS MotivoDescripcion,
       a.Clave, a.Cantidad, a.CostoUnitario, a.Costo,
       a.Factura, a.Remision, a.Lote, a.FechaEntrada, a.FechaCaducidad,
       a.AplicaAlmacen, a.InventarioCerrado, a.EsContabilizado,
       a.Activo, a.FechaCreacion, a.UsuarioCreacion, a.FechaModificacion, a.UsuarioModificacion
FROM ALMA.Almacen a
INNER JOIN SIS.Empresa e ON a.FKIdEmpresa_SIS = e.PKIdEmpresa
LEFT JOIN SIS.Area ar ON a.FKIdArea_SIS = ar.PKIdArea
INNER JOIN ALMA.TipoBien tb ON a.FKIdTipoBien_ALMA = tb.PKIdTipoBien
LEFT JOIN ALMA.Unidades u ON a.FKIdUnidades_ALMA = u.PKIdUnidades
LEFT JOIN ALMA.MotivoES m ON a.FKIdMotivoES_ALMA = m.PKIdMotivoES;
GO

CREATE OR ALTER VIEW ALMA.Vw_SolicitudSalida AS
SELECT s.PKIdSolicitudSalida, s.FKIdEmpresa_SIS, e.Nombre AS EmpresaNombre,
       s.FKIdAreaSolicita_SIS, areaSol.Nombre AS AreaSolicitaNombre,
       s.FKIdAreaEntrega_SIS, areaEnt.Nombre AS AreaEntregaNombre,
       s.FKIdEstatusSolicitudSalida_ALMA, est.Descripcion AS EstatusDescripcion, est.Color AS EstatusColor,
       s.Folio, s.FechaSolicitud, s.FechaRequerida, s.Solicitante,
       s.Justificacion, s.Observaciones, s.Autorizado, s.FechaAutorizacion, s.UsuarioAutorizacion,
       s.Activo, s.FechaCreacion, s.UsuarioCreacion, s.FechaModificacion, s.UsuarioModificacion
FROM ALMA.SolicitudSalida s
INNER JOIN SIS.Empresa e ON s.FKIdEmpresa_SIS = e.PKIdEmpresa
LEFT JOIN SIS.Area areaSol ON s.FKIdAreaSolicita_SIS = areaSol.PKIdArea
LEFT JOIN SIS.Area areaEnt ON s.FKIdAreaEntrega_SIS = areaEnt.PKIdArea
INNER JOIN ALMA.EstatusSolicitudSalida est ON s.FKIdEstatusSolicitudSalida_ALMA = est.PKIdEstatusSolicitudSalida;
GO

CREATE OR ALTER VIEW ALMA.Vw_DetalleSolicitudSalida AS
SELECT d.PKIdDetalleSolicitudSalida, d.FKIdSolicitudSalida_ALMA, s.Folio AS SolicitudFolio,
       d.FKIdAlmacen_ALMA, alm.Clave AS AlmacenClave,
       d.FKIdTipoBien_ALMA, tb.CodigoClave AS TipoBienClave, tb.Descripcion AS TipoBienDescripcion,
       d.FKIdUnidades_ALMA, u.Descripcion AS UnidadDescripcion,
       d.CantidadSolicitada, d.CantidadAutorizada, d.CantidadEntregada, d.CantidadPendiente,
       d.Observaciones, d.Activo, d.FechaCreacion, d.UsuarioCreacion, d.FechaModificacion, d.UsuarioModificacion
FROM ALMA.DetalleSolicitudSalida d
INNER JOIN ALMA.SolicitudSalida s ON d.FKIdSolicitudSalida_ALMA = s.PKIdSolicitudSalida
LEFT JOIN ALMA.Almacen alm ON d.FKIdAlmacen_ALMA = alm.PKIdAlmacen
INNER JOIN ALMA.TipoBien tb ON d.FKIdTipoBien_ALMA = tb.PKIdTipoBien
LEFT JOIN ALMA.Unidades u ON d.FKIdUnidades_ALMA = u.PKIdUnidades;
GO

/*  ------------------------------------------------------------------------------------------------------ */

-- =========================
-- SP CALENDARIO
-- =========================
CREATE OR ALTER PROCEDURE ALMA.SP_MantenimientoCalendarioInventario
    @Action INT,
    @PKIdCalendarioInventario INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdArea_SIS INT = NULL,
    @Anio INT = NULL,
    @Descripcion NVARCHAR(300) = NULL,
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
    @Observaciones NVARCHAR(1000) = NULL,
    @IdUser INT,
    @Id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Folio NVARCHAR(30), @Consecutivo INT, @Msg NVARCHAR(4000);

    BEGIN TRY
        IF @Action = 1
        BEGIN
            SELECT @Consecutivo = ISNULL(MAX(TRY_CONVERT(INT, RIGHT(Folio, 5))), 0) + 1
            FROM ALMA.CalendarioInventario WITH (UPDLOCK, HOLDLOCK)
            WHERE Folio LIKE CONCAT(N'CAL-', @Anio, N'-%');

            SET @Folio = CONCAT(N'CAL-', @Anio, N'-', RIGHT(CONCAT(N'00000', @Consecutivo), 5));

            INSERT INTO ALMA.CalendarioInventario
                (FKIdEmpresa_SIS, FKIdArea_SIS, Anio, Folio, Descripcion, FechaInicio, FechaFin, Observaciones, UsuarioCreacion)
            VALUES
                (@FKIdEmpresa_SIS, @FKIdArea_SIS, @Anio, @Folio, @Descripcion, @FechaInicio, @FechaFin, @Observaciones, @IdUser);

            SET @Id = SCOPE_IDENTITY();
            SET @Msg = N'Calendario creado correctamente.';
        END

        IF @Action = 2
        BEGIN
            UPDATE ALMA.CalendarioInventario
            SET FKIdArea_SIS = @FKIdArea_SIS,
                Anio = @Anio,
                Descripcion = @Descripcion,
                FechaInicio = @FechaInicio,
                FechaFin = @FechaFin,
                Observaciones = @Observaciones,
                FechaModificacion = SYSDATETIME(),
                UsuarioModificacion = @IdUser
            WHERE PKIdCalendarioInventario = @PKIdCalendarioInventario AND Activo = 1;

            SET @Id = @PKIdCalendarioInventario;
            SET @Msg = N'Calendario actualizado correctamente.';
        END

        IF @Action = 3
        BEGIN
            UPDATE ALMA.CalendarioInventario
            SET Activo = 0, FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
            WHERE PKIdCalendarioInventario = @PKIdCalendarioInventario;

            SET @Id = @PKIdCalendarioInventario;
            SET @Msg = N'Calendario eliminado correctamente.';
        END

        SELECT ResultJson = (SELECT N'success' AS Tipo, @Msg AS Mensaje, CONCAT(N'id:', @Id) AS Liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        SELECT ResultJson = (SELECT N'error' AS Tipo, ERROR_MESSAGE() AS Mensaje, NULL AS Liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE ALMA.SP_MantenimientoInventario
    @Action INT,
    @PKIdInventario INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdCalendarioInventario_ALMA INT = NULL,
    @FKIdArea_SIS INT = NULL,
    @FKIdEstatusInventario_ALMA INT = NULL,
    @FechaInventario DATE = NULL,
    @Responsable NVARCHAR(250) = NULL,
    @Observaciones NVARCHAR(1000) = NULL,
    @IdUser INT,
    @Id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Folio NVARCHAR(30), @Consecutivo INT, @Anio INT, @Msg NVARCHAR(4000), @EstatusCerrado INT;

    BEGIN TRY
        SELECT @EstatusCerrado = PKIdEstatusInventario FROM ALMA.EstatusInventario WHERE Descripcion = N'CERRADO' AND Activo = 1;

        IF @Action = 1
        BEGIN
            SET @Anio = YEAR(ISNULL(@FechaInventario, GETDATE()));

            SELECT @Consecutivo = ISNULL(MAX(TRY_CONVERT(INT, RIGHT(Folio, 5))), 0) + 1
            FROM ALMA.Inventario WITH (UPDLOCK, HOLDLOCK)
            WHERE Folio LIKE CONCAT(N'INV-', @Anio, N'-%');

            SET @Folio = CONCAT(N'INV-', @Anio, N'-', RIGHT(CONCAT(N'00000', @Consecutivo), 5));

            INSERT INTO ALMA.Inventario
                (FKIdEmpresa_SIS, FKIdCalendarioInventario_ALMA, FKIdArea_SIS, FKIdEstatusInventario_ALMA,
                 Folio, FechaInventario, Responsable, Observaciones, UsuarioCreacion)
            VALUES
                (@FKIdEmpresa_SIS, @FKIdCalendarioInventario_ALMA, @FKIdArea_SIS, @FKIdEstatusInventario_ALMA,
                 @Folio, ISNULL(@FechaInventario, CONVERT(date, GETDATE())), @Responsable, @Observaciones, @IdUser);

            SET @Id = SCOPE_IDENTITY();
            SET @Msg = N'Inventario creado correctamente.';
        END

        IF @Action = 2
        BEGIN
            INSERT INTO HIS.Inventario_Hist
                (FKIdInventario_ALMA, AccionHist, Folio, FKIdEmpresa_SIS, FKIdArea_SIS, FKIdEstatusInventario_ALMA,
                 FechaInventario, Responsable, Observaciones, TotalBienes, TotalLocalizados, TotalDiferencias,
                 Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion, UsuarioHist)
            SELECT PKIdInventario, N'UPDATE', Folio, FKIdEmpresa_SIS, FKIdArea_SIS, FKIdEstatusInventario_ALMA,
                   FechaInventario, Responsable, Observaciones, TotalBienes, TotalLocalizados, TotalDiferencias,
                   Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion, @IdUser
            FROM ALMA.Inventario WHERE PKIdInventario = @PKIdInventario;

            UPDATE ALMA.Inventario
            SET FKIdCalendarioInventario_ALMA = @FKIdCalendarioInventario_ALMA,
                FKIdArea_SIS = @FKIdArea_SIS,
                FKIdEstatusInventario_ALMA = @FKIdEstatusInventario_ALMA,
                FechaInventario = @FechaInventario,
                Responsable = @Responsable,
                Observaciones = @Observaciones,
                FechaModificacion = SYSDATETIME(),
                UsuarioModificacion = @IdUser
            WHERE PKIdInventario = @PKIdInventario AND Activo = 1;

            SET @Id = @PKIdInventario;
            SET @Msg = N'Inventario actualizado correctamente.';
        END

        IF @Action = 3
        BEGIN
            UPDATE ALMA.Inventario
            SET Activo = 0, FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
            WHERE PKIdInventario = @PKIdInventario;

            SET @Id = @PKIdInventario;
            SET @Msg = N'Inventario eliminado correctamente.';
        END

        IF @Action = 4
        BEGIN
            UPDATE i
            SET TotalBienes = x.TotalBienes,
                TotalLocalizados = x.TotalLocalizados,
                TotalDiferencias = x.TotalDiferencias,
                FKIdEstatusInventario_ALMA = @EstatusCerrado,
                Autorizado = 1,
                FechaAutorizacion = SYSDATETIME(),
                UsuarioAutorizacion = @IdUser,
                FechaModificacion = SYSDATETIME(),
                UsuarioModificacion = @IdUser
            FROM ALMA.Inventario i
            CROSS APPLY (
                SELECT COUNT(1) TotalBienes,
                       SUM(CASE WHEN Localizado = 1 THEN 1 ELSE 0 END) TotalLocalizados,
                       SUM(CASE WHEN TieneDiferencia = 1 THEN 1 ELSE 0 END) TotalDiferencias
                FROM ALMA.InventarioDetalle d
                WHERE d.FKIdInventario_ALMA = i.PKIdInventario AND d.Activo = 1
            ) x
            WHERE i.PKIdInventario = @PKIdInventario;

            SET @Id = @PKIdInventario;
            SET @Msg = N'Inventario cerrado correctamente.';
        END

        SELECT ResultJson = (SELECT N'success' AS Tipo, @Msg AS Mensaje, CONCAT(N'id:', @Id) AS Liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        SELECT ResultJson = (SELECT N'error' AS Tipo, ERROR_MESSAGE() AS Mensaje, NULL AS Liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE ALMA.SP_MantenimientoInventarioDetalle
    @Action INT,
    @PKIdInventarioDetalle INT = NULL,
    @FKIdInventario_ALMA INT = NULL,
    @FKIdBien_ALMA INT = NULL,
    @UbicacionSistema NVARCHAR(250) = NULL,
    @UbicacionFisica NVARCHAR(250) = NULL,
    @Localizado BIT = NULL,
    @TieneDiferencia BIT = NULL,
    @Observaciones NVARCHAR(1000) = NULL,
    @IdUser INT,
    @Id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Msg NVARCHAR(4000);

    BEGIN TRY
        IF @Action = 1
        BEGIN
            INSERT INTO ALMA.InventarioDetalle
                (FKIdInventario_ALMA, FKIdBien_ALMA, ClaveBien, DescripcionBien, Serie,
                 UbicacionSistema, UbicacionFisica, Localizado, TieneDiferencia, Observaciones, UsuarioCreacion)
            SELECT @FKIdInventario_ALMA, b.PKIdBien, b.Clave, b.Descripcion, b.Serie,
                   @UbicacionSistema, @UbicacionFisica, ISNULL(@Localizado,0), ISNULL(@TieneDiferencia,0), @Observaciones, @IdUser
            FROM ALMA.Bien b WHERE b.PKIdBien = @FKIdBien_ALMA;

            SET @Id = SCOPE_IDENTITY();
            SET @Msg = N'Detalle de inventario creado correctamente.';
        END

        IF @Action = 2
        BEGIN
            INSERT INTO HIS.InventarioDet_Hist
                (FKIdInventarioDetalle_ALMA, FKIdInventario_ALMA, FKIdBien_ALMA, AccionHist, ClaveBien,
                 DescripcionBien, Serie, UbicacionSistema, UbicacionFisica, Localizado, TieneDiferencia,
                 Observaciones, Activo, UsuarioHist)
            SELECT PKIdInventarioDetalle, FKIdInventario_ALMA, FKIdBien_ALMA, N'UPDATE', ClaveBien,
                   DescripcionBien, Serie, UbicacionSistema, UbicacionFisica, Localizado, TieneDiferencia,
                   Observaciones, Activo, @IdUser
            FROM ALMA.InventarioDetalle WHERE PKIdInventarioDetalle = @PKIdInventarioDetalle;

            UPDATE ALMA.InventarioDetalle
            SET UbicacionSistema = @UbicacionSistema,
                UbicacionFisica = @UbicacionFisica,
                Localizado = ISNULL(@Localizado, Localizado),
                TieneDiferencia = ISNULL(@TieneDiferencia, TieneDiferencia),
                Observaciones = @Observaciones,
                FechaModificacion = SYSDATETIME(),
                UsuarioModificacion = @IdUser
            WHERE PKIdInventarioDetalle = @PKIdInventarioDetalle AND Activo = 1;

            SET @Id = @PKIdInventarioDetalle;
            SET @Msg = N'Detalle de inventario actualizado correctamente.';
        END

        IF @Action = 3
        BEGIN
            UPDATE ALMA.InventarioDetalle
            SET Activo = 0, FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
            WHERE PKIdInventarioDetalle = @PKIdInventarioDetalle;

            SET @Id = @PKIdInventarioDetalle;
            SET @Msg = N'Detalle de inventario eliminado correctamente.';
        END

        SELECT ResultJson = (SELECT N'success' AS Tipo, @Msg AS Mensaje, CONCAT(N'id:', @Id) AS Liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        SELECT ResultJson = (SELECT N'error' AS Tipo, ERROR_MESSAGE() AS Mensaje, NULL AS Liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END CATCH
END;
GO

-- =========================
-- SP CALENDARIO
-- =========================
CREATE OR ALTER PROCEDURE ALMA.SP_MantenimientoCalendarioInventario
    @Action INT,
    @PKIdCalendarioInventario INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdArea_SIS INT = NULL,
    @Anio INT = NULL,
    @Descripcion NVARCHAR(300) = NULL,
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
    @Observaciones NVARCHAR(1000) = NULL,
    @IdUser INT,
    @Id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Folio NVARCHAR(30), @Consecutivo INT, @Msg NVARCHAR(4000);

    BEGIN TRY
        IF @Action = 1
        BEGIN
            SELECT @Consecutivo = ISNULL(MAX(TRY_CONVERT(INT, RIGHT(Folio, 5))), 0) + 1
            FROM ALMA.CalendarioInventario WITH (UPDLOCK, HOLDLOCK)
            WHERE Folio LIKE CONCAT(N'CAL-', @Anio, N'-%');

            SET @Folio = CONCAT(N'CAL-', @Anio, N'-', RIGHT(CONCAT(N'00000', @Consecutivo), 5));

            INSERT INTO ALMA.CalendarioInventario
                (FKIdEmpresa_SIS, FKIdArea_SIS, Anio, Folio, Descripcion, FechaInicio, FechaFin, Observaciones, UsuarioCreacion)
            VALUES
                (@FKIdEmpresa_SIS, @FKIdArea_SIS, @Anio, @Folio, @Descripcion, @FechaInicio, @FechaFin, @Observaciones, @IdUser);

            SET @Id = SCOPE_IDENTITY();
            SET @Msg = N'Calendario creado correctamente.';
        END

        IF @Action = 2
        BEGIN
            UPDATE ALMA.CalendarioInventario
            SET FKIdArea_SIS = @FKIdArea_SIS,
                Anio = @Anio,
                Descripcion = @Descripcion,
                FechaInicio = @FechaInicio,
                FechaFin = @FechaFin,
                Observaciones = @Observaciones,
                FechaModificacion = SYSDATETIME(),
                UsuarioModificacion = @IdUser
            WHERE PKIdCalendarioInventario = @PKIdCalendarioInventario AND Activo = 1;

            SET @Id = @PKIdCalendarioInventario;
            SET @Msg = N'Calendario actualizado correctamente.';
        END

        IF @Action = 3
        BEGIN
            UPDATE ALMA.CalendarioInventario
            SET Activo = 0, FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
            WHERE PKIdCalendarioInventario = @PKIdCalendarioInventario;

            SET @Id = @PKIdCalendarioInventario;
            SET @Msg = N'Calendario eliminado correctamente.';
        END

        SELECT ResultJson = (SELECT N'success' AS Tipo, @Msg AS Mensaje, CONCAT(N'id:', @Id) AS Liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        SELECT ResultJson = (SELECT N'error' AS Tipo, ERROR_MESSAGE() AS Mensaje, NULL AS Liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE ALMA.SP_MantenimientoInventario
    @Action INT,
    @PKIdInventario INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdCalendarioInventario_ALMA INT = NULL,
    @FKIdArea_SIS INT = NULL,
    @FKIdEstatusInventario_ALMA INT = NULL,
    @FechaInventario DATE = NULL,
    @Responsable NVARCHAR(250) = NULL,
    @Observaciones NVARCHAR(1000) = NULL,
    @IdUser INT,
    @Id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Folio NVARCHAR(30), @Consecutivo INT, @Anio INT, @Msg NVARCHAR(4000), @EstatusCerrado INT;

    BEGIN TRY
        SELECT @EstatusCerrado = PKIdEstatusInventario FROM ALMA.EstatusInventario WHERE Descripcion = N'CERRADO' AND Activo = 1;

        IF @Action = 1
        BEGIN
            SET @Anio = YEAR(ISNULL(@FechaInventario, GETDATE()));

            SELECT @Consecutivo = ISNULL(MAX(TRY_CONVERT(INT, RIGHT(Folio, 5))), 0) + 1
            FROM ALMA.Inventario WITH (UPDLOCK, HOLDLOCK)
            WHERE Folio LIKE CONCAT(N'INV-', @Anio, N'-%');

            SET @Folio = CONCAT(N'INV-', @Anio, N'-', RIGHT(CONCAT(N'00000', @Consecutivo), 5));

            INSERT INTO ALMA.Inventario
                (FKIdEmpresa_SIS, FKIdCalendarioInventario_ALMA, FKIdArea_SIS, FKIdEstatusInventario_ALMA,
                 Folio, FechaInventario, Responsable, Observaciones, UsuarioCreacion)
            VALUES
                (@FKIdEmpresa_SIS, @FKIdCalendarioInventario_ALMA, @FKIdArea_SIS, @FKIdEstatusInventario_ALMA,
                 @Folio, ISNULL(@FechaInventario, CONVERT(date, GETDATE())), @Responsable, @Observaciones, @IdUser);

            SET @Id = SCOPE_IDENTITY();
            SET @Msg = N'Inventario creado correctamente.';
        END

        IF @Action = 2
        BEGIN
            INSERT INTO HIS.Inventario_Hist
                (FKIdInventario_ALMA, AccionHist, Folio, FKIdEmpresa_SIS, FKIdArea_SIS, FKIdEstatusInventario_ALMA,
                 FechaInventario, Responsable, Observaciones, TotalBienes, TotalLocalizados, TotalDiferencias,
                 Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion, UsuarioHist)
            SELECT PKIdInventario, N'UPDATE', Folio, FKIdEmpresa_SIS, FKIdArea_SIS, FKIdEstatusInventario_ALMA,
                   FechaInventario, Responsable, Observaciones, TotalBienes, TotalLocalizados, TotalDiferencias,
                   Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion, @IdUser
            FROM ALMA.Inventario WHERE PKIdInventario = @PKIdInventario;

            UPDATE ALMA.Inventario
            SET FKIdCalendarioInventario_ALMA = @FKIdCalendarioInventario_ALMA,
                FKIdArea_SIS = @FKIdArea_SIS,
                FKIdEstatusInventario_ALMA = @FKIdEstatusInventario_ALMA,
                FechaInventario = @FechaInventario,
                Responsable = @Responsable,
                Observaciones = @Observaciones,
                FechaModificacion = SYSDATETIME(),
                UsuarioModificacion = @IdUser
            WHERE PKIdInventario = @PKIdInventario AND Activo = 1;

            SET @Id = @PKIdInventario;
            SET @Msg = N'Inventario actualizado correctamente.';
        END

        IF @Action = 3
        BEGIN
            UPDATE ALMA.Inventario
            SET Activo = 0, FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
            WHERE PKIdInventario = @PKIdInventario;

            SET @Id = @PKIdInventario;
            SET @Msg = N'Inventario eliminado correctamente.';
        END

        IF @Action = 4
        BEGIN
            UPDATE i
            SET TotalBienes = x.TotalBienes,
                TotalLocalizados = x.TotalLocalizados,
                TotalDiferencias = x.TotalDiferencias,
                FKIdEstatusInventario_ALMA = @EstatusCerrado,
                Autorizado = 1,
                FechaAutorizacion = SYSDATETIME(),
                UsuarioAutorizacion = @IdUser,
                FechaModificacion = SYSDATETIME(),
                UsuarioModificacion = @IdUser
            FROM ALMA.Inventario i
            CROSS APPLY (
                SELECT COUNT(1) TotalBienes,
                       SUM(CASE WHEN Localizado = 1 THEN 1 ELSE 0 END) TotalLocalizados,
                       SUM(CASE WHEN TieneDiferencia = 1 THEN 1 ELSE 0 END) TotalDiferencias
                FROM ALMA.InventarioDetalle d
                WHERE d.FKIdInventario_ALMA = i.PKIdInventario AND d.Activo = 1
            ) x
            WHERE i.PKIdInventario = @PKIdInventario;

            SET @Id = @PKIdInventario;
            SET @Msg = N'Inventario cerrado correctamente.';
        END

        SELECT ResultJson = (SELECT N'success' AS Tipo, @Msg AS Mensaje, CONCAT(N'id:', @Id) AS Liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        SELECT ResultJson = (SELECT N'error' AS Tipo, ERROR_MESSAGE() AS Mensaje, NULL AS Liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE ALMA.SP_MantenimientoInventarioDetalle
    @Action INT,
    @PKIdInventarioDetalle INT = NULL,
    @FKIdInventario_ALMA INT = NULL,
    @FKIdBien_ALMA INT = NULL,
    @UbicacionSistema NVARCHAR(250) = NULL,
    @UbicacionFisica NVARCHAR(250) = NULL,
    @Localizado BIT = NULL,
    @TieneDiferencia BIT = NULL,
    @Observaciones NVARCHAR(1000) = NULL,
    @IdUser INT,
    @Id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Msg NVARCHAR(4000);

    BEGIN TRY
        IF @Action = 1
        BEGIN
            INSERT INTO ALMA.InventarioDetalle
                (FKIdInventario_ALMA, FKIdBien_ALMA, ClaveBien, DescripcionBien, Serie,
                 UbicacionSistema, UbicacionFisica, Localizado, TieneDiferencia, Observaciones, UsuarioCreacion)
            SELECT @FKIdInventario_ALMA, b.PKIdBien, b.Clave, b.Descripcion, b.Serie,
                   @UbicacionSistema, @UbicacionFisica, ISNULL(@Localizado,0), ISNULL(@TieneDiferencia,0), @Observaciones, @IdUser
            FROM ALMA.Bien b WHERE b.PKIdBien = @FKIdBien_ALMA;

            SET @Id = SCOPE_IDENTITY();
            SET @Msg = N'Detalle de inventario creado correctamente.';
        END

        IF @Action = 2
        BEGIN
            INSERT INTO HIS.InventarioDet_Hist
                (FKIdInventarioDetalle_ALMA, FKIdInventario_ALMA, FKIdBien_ALMA, AccionHist, ClaveBien,
                 DescripcionBien, Serie, UbicacionSistema, UbicacionFisica, Localizado, TieneDiferencia,
                 Observaciones, Activo, UsuarioHist)
            SELECT PKIdInventarioDetalle, FKIdInventario_ALMA, FKIdBien_ALMA, N'UPDATE', ClaveBien,
                   DescripcionBien, Serie, UbicacionSistema, UbicacionFisica, Localizado, TieneDiferencia,
                   Observaciones, Activo, @IdUser
            FROM ALMA.InventarioDetalle WHERE PKIdInventarioDetalle = @PKIdInventarioDetalle;

            UPDATE ALMA.InventarioDetalle
            SET UbicacionSistema = @UbicacionSistema,
                UbicacionFisica = @UbicacionFisica,
                Localizado = ISNULL(@Localizado, Localizado),
                TieneDiferencia = ISNULL(@TieneDiferencia, TieneDiferencia),
                Observaciones = @Observaciones,
                FechaModificacion = SYSDATETIME(),
                UsuarioModificacion = @IdUser
            WHERE PKIdInventarioDetalle = @PKIdInventarioDetalle AND Activo = 1;

            SET @Id = @PKIdInventarioDetalle;
            SET @Msg = N'Detalle de inventario actualizado correctamente.';
        END

        IF @Action = 3
        BEGIN
            UPDATE ALMA.InventarioDetalle
            SET Activo = 0, FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
            WHERE PKIdInventarioDetalle = @PKIdInventarioDetalle;

            SET @Id = @PKIdInventarioDetalle;
            SET @Msg = N'Detalle de inventario eliminado correctamente.';
        END

        SELECT ResultJson = (SELECT N'success' AS Tipo, @Msg AS Mensaje, CONCAT(N'id:', @Id) AS Liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        SELECT ResultJson = (SELECT N'error' AS Tipo, ERROR_MESSAGE() AS Mensaje, NULL AS Liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END CATCH
END;
GO

-- =========================
-- SP CALENDARIO
-- =========================
CREATE OR ALTER PROCEDURE ALMA.SP_MantenimientoCalendarioInventario
    @Action INT,
    @PKIdCalendarioInventario INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdArea_SIS INT = NULL,
    @Anio INT = NULL,
    @Descripcion NVARCHAR(300) = NULL,
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
    @Observaciones NVARCHAR(1000) = NULL,
    @IdUser INT,
    @Id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Folio NVARCHAR(30), @Consecutivo INT, @Msg NVARCHAR(4000);

    BEGIN TRY
        IF @Action = 1
        BEGIN
            SELECT @Consecutivo = ISNULL(MAX(TRY_CONVERT(INT, RIGHT(Folio, 5))), 0) + 1
            FROM ALMA.CalendarioInventario WITH (UPDLOCK, HOLDLOCK)
            WHERE Folio LIKE CONCAT(N'CAL-', @Anio, N'-%');

            SET @Folio = CONCAT(N'CAL-', @Anio, N'-', RIGHT(CONCAT(N'00000', @Consecutivo), 5));

            INSERT INTO ALMA.CalendarioInventario
                (FKIdEmpresa_SIS, FKIdArea_SIS, Anio, Folio, Descripcion, FechaInicio, FechaFin, Observaciones, UsuarioCreacion)
            VALUES
                (@FKIdEmpresa_SIS, @FKIdArea_SIS, @Anio, @Folio, @Descripcion, @FechaInicio, @FechaFin, @Observaciones, @IdUser);

            SET @Id = SCOPE_IDENTITY();
            SET @Msg = N'Calendario creado correctamente.';
        END

        IF @Action = 2
        BEGIN
            UPDATE ALMA.CalendarioInventario
            SET FKIdArea_SIS = @FKIdArea_SIS,
                Anio = @Anio,
                Descripcion = @Descripcion,
                FechaInicio = @FechaInicio,
                FechaFin = @FechaFin,
                Observaciones = @Observaciones,
                FechaModificacion = SYSDATETIME(),
                UsuarioModificacion = @IdUser
            WHERE PKIdCalendarioInventario = @PKIdCalendarioInventario AND Activo = 1;

            SET @Id = @PKIdCalendarioInventario;
            SET @Msg = N'Calendario actualizado correctamente.';
        END

        IF @Action = 3
        BEGIN
            UPDATE ALMA.CalendarioInventario
            SET Activo = 0, FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
            WHERE PKIdCalendarioInventario = @PKIdCalendarioInventario;

            SET @Id = @PKIdCalendarioInventario;
            SET @Msg = N'Calendario eliminado correctamente.';
        END

        SELECT ResultJson = (SELECT N'success' AS Tipo, @Msg AS Mensaje, CONCAT(N'id:', @Id) AS Liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        SELECT ResultJson = (SELECT N'error' AS Tipo, ERROR_MESSAGE() AS Mensaje, NULL AS Liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE ALMA.SP_MantenimientoInventario
    @Action INT,
    @PKIdInventario INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdCalendarioInventario_ALMA INT = NULL,
    @FKIdArea_SIS INT = NULL,
    @FKIdEstatusInventario_ALMA INT = NULL,
    @FechaInventario DATE = NULL,
    @Responsable NVARCHAR(250) = NULL,
    @Observaciones NVARCHAR(1000) = NULL,
    @IdUser INT,
    @Id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Folio NVARCHAR(30), @Consecutivo INT, @Anio INT, @Msg NVARCHAR(4000), @EstatusCerrado INT;

    BEGIN TRY
        SELECT @EstatusCerrado = PKIdEstatusInventario FROM ALMA.EstatusInventario WHERE Descripcion = N'CERRADO' AND Activo = 1;

        IF @Action = 1
        BEGIN
            SET @Anio = YEAR(ISNULL(@FechaInventario, GETDATE()));

            SELECT @Consecutivo = ISNULL(MAX(TRY_CONVERT(INT, RIGHT(Folio, 5))), 0) + 1
            FROM ALMA.Inventario WITH (UPDLOCK, HOLDLOCK)
            WHERE Folio LIKE CONCAT(N'INV-', @Anio, N'-%');

            SET @Folio = CONCAT(N'INV-', @Anio, N'-', RIGHT(CONCAT(N'00000', @Consecutivo), 5));

            INSERT INTO ALMA.Inventario
                (FKIdEmpresa_SIS, FKIdCalendarioInventario_ALMA, FKIdArea_SIS, FKIdEstatusInventario_ALMA,
                 Folio, FechaInventario, Responsable, Observaciones, UsuarioCreacion)
            VALUES
                (@FKIdEmpresa_SIS, @FKIdCalendarioInventario_ALMA, @FKIdArea_SIS, @FKIdEstatusInventario_ALMA,
                 @Folio, ISNULL(@FechaInventario, CONVERT(date, GETDATE())), @Responsable, @Observaciones, @IdUser);

            SET @Id = SCOPE_IDENTITY();
            SET @Msg = N'Inventario creado correctamente.';
        END

        IF @Action = 2
        BEGIN
            INSERT INTO HIS.Inventario_Hist
                (FKIdInventario_ALMA, AccionHist, Folio, FKIdEmpresa_SIS, FKIdArea_SIS, FKIdEstatusInventario_ALMA,
                 FechaInventario, Responsable, Observaciones, TotalBienes, TotalLocalizados, TotalDiferencias,
                 Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion, UsuarioHist)
            SELECT PKIdInventario, N'UPDATE', Folio, FKIdEmpresa_SIS, FKIdArea_SIS, FKIdEstatusInventario_ALMA,
                   FechaInventario, Responsable, Observaciones, TotalBienes, TotalLocalizados, TotalDiferencias,
                   Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion, @IdUser
            FROM ALMA.Inventario WHERE PKIdInventario = @PKIdInventario;

            UPDATE ALMA.Inventario
            SET FKIdCalendarioInventario_ALMA = @FKIdCalendarioInventario_ALMA,
                FKIdArea_SIS = @FKIdArea_SIS,
                FKIdEstatusInventario_ALMA = @FKIdEstatusInventario_ALMA,
                FechaInventario = @FechaInventario,
                Responsable = @Responsable,
                Observaciones = @Observaciones,
                FechaModificacion = SYSDATETIME(),
                UsuarioModificacion = @IdUser
            WHERE PKIdInventario = @PKIdInventario AND Activo = 1;

            SET @Id = @PKIdInventario;
            SET @Msg = N'Inventario actualizado correctamente.';
        END

        IF @Action = 3
        BEGIN
            UPDATE ALMA.Inventario
            SET Activo = 0, FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
            WHERE PKIdInventario = @PKIdInventario;

            SET @Id = @PKIdInventario;
            SET @Msg = N'Inventario eliminado correctamente.';
        END

        IF @Action = 4
        BEGIN
            UPDATE i
            SET TotalBienes = x.TotalBienes,
                TotalLocalizados = x.TotalLocalizados,
                TotalDiferencias = x.TotalDiferencias,
                FKIdEstatusInventario_ALMA = @EstatusCerrado,
                Autorizado = 1,
                FechaAutorizacion = SYSDATETIME(),
                UsuarioAutorizacion = @IdUser,
                FechaModificacion = SYSDATETIME(),
                UsuarioModificacion = @IdUser
            FROM ALMA.Inventario i
            CROSS APPLY (
                SELECT COUNT(1) TotalBienes,
                       SUM(CASE WHEN Localizado = 1 THEN 1 ELSE 0 END) TotalLocalizados,
                       SUM(CASE WHEN TieneDiferencia = 1 THEN 1 ELSE 0 END) TotalDiferencias
                FROM ALMA.InventarioDetalle d
                WHERE d.FKIdInventario_ALMA = i.PKIdInventario AND d.Activo = 1
            ) x
            WHERE i.PKIdInventario = @PKIdInventario;

            SET @Id = @PKIdInventario;
            SET @Msg = N'Inventario cerrado correctamente.';
        END

        SELECT ResultJson = (SELECT N'success' AS Tipo, @Msg AS Mensaje, CONCAT(N'id:', @Id) AS Liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        SELECT ResultJson = (SELECT N'error' AS Tipo, ERROR_MESSAGE() AS Mensaje, NULL AS Liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE ALMA.SP_MantenimientoInventarioDetalle
    @Action INT,
    @PKIdInventarioDetalle INT = NULL,
    @FKIdInventario_ALMA INT = NULL,
    @FKIdBien_ALMA INT = NULL,
    @UbicacionSistema NVARCHAR(250) = NULL,
    @UbicacionFisica NVARCHAR(250) = NULL,
    @Localizado BIT = NULL,
    @TieneDiferencia BIT = NULL,
    @Observaciones NVARCHAR(1000) = NULL,
    @IdUser INT,
    @Id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Msg NVARCHAR(4000);

    BEGIN TRY
        IF @Action = 1
        BEGIN
            INSERT INTO ALMA.InventarioDetalle
                (FKIdInventario_ALMA, FKIdBien_ALMA, ClaveBien, DescripcionBien, Serie,
                 UbicacionSistema, UbicacionFisica, Localizado, TieneDiferencia, Observaciones, UsuarioCreacion)
            SELECT @FKIdInventario_ALMA, b.PKIdBien, b.Clave, b.Descripcion, b.Serie,
                   @UbicacionSistema, @UbicacionFisica, ISNULL(@Localizado,0), ISNULL(@TieneDiferencia,0), @Observaciones, @IdUser
            FROM ALMA.Bien b WHERE b.PKIdBien = @FKIdBien_ALMA;

            SET @Id = SCOPE_IDENTITY();
            SET @Msg = N'Detalle de inventario creado correctamente.';
        END

        IF @Action = 2
        BEGIN
            INSERT INTO HIS.InventarioDet_Hist
                (FKIdInventarioDetalle_ALMA, FKIdInventario_ALMA, FKIdBien_ALMA, AccionHist, ClaveBien,
                 DescripcionBien, Serie, UbicacionSistema, UbicacionFisica, Localizado, TieneDiferencia,
                 Observaciones, Activo, UsuarioHist)
            SELECT PKIdInventarioDetalle, FKIdInventario_ALMA, FKIdBien_ALMA, N'UPDATE', ClaveBien,
                   DescripcionBien, Serie, UbicacionSistema, UbicacionFisica, Localizado, TieneDiferencia,
                   Observaciones, Activo, @IdUser
            FROM ALMA.InventarioDetalle WHERE PKIdInventarioDetalle = @PKIdInventarioDetalle;

            UPDATE ALMA.InventarioDetalle
            SET UbicacionSistema = @UbicacionSistema,
                UbicacionFisica = @UbicacionFisica,
                Localizado = ISNULL(@Localizado, Localizado),
                TieneDiferencia = ISNULL(@TieneDiferencia, TieneDiferencia),
                Observaciones = @Observaciones,
                FechaModificacion = SYSDATETIME(),
                UsuarioModificacion = @IdUser
            WHERE PKIdInventarioDetalle = @PKIdInventarioDetalle AND Activo = 1;

            SET @Id = @PKIdInventarioDetalle;
            SET @Msg = N'Detalle de inventario actualizado correctamente.';
        END

        IF @Action = 3
        BEGIN
            UPDATE ALMA.InventarioDetalle
            SET Activo = 0, FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
            WHERE PKIdInventarioDetalle = @PKIdInventarioDetalle;

            SET @Id = @PKIdInventarioDetalle;
            SET @Msg = N'Detalle de inventario eliminado correctamente.';
        END

        SELECT ResultJson = (SELECT N'success' AS Tipo, @Msg AS Mensaje, CONCAT(N'id:', @Id) AS Liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        SELECT ResultJson = (SELECT N'error' AS Tipo, ERROR_MESSAGE() AS Mensaje, NULL AS Liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE ALMA.SP_ReporteInventario
    @PKIdInventario INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT * FROM ALMA.Vw_Inventarios WHERE PKIdInventario = @PKIdInventario;
    SELECT * FROM ALMA.Vw_InventarioDetalle WHERE FKIdInventario_ALMA = @PKIdInventario ORDER BY PKIdInventarioDetalle;
END;
GO

CREATE OR ALTER PROCEDURE ALMA.SP_ReporteSolicitudSalida
    @PKIdSolicitudSalida INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT * FROM ALMA.Vw_SolicitudSalida WHERE PKIdSolicitudSalida = @PKIdSolicitudSalida;
    SELECT * FROM ALMA.Vw_DetalleSolicitudSalida WHERE FKIdSolicitudSalida_ALMA = @PKIdSolicitudSalida ORDER BY PKIdDetalleSolicitudSalida;
END;
GO
