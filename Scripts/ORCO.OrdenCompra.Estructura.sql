USE [GestionEmpresarial];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF SCHEMA_ID(N'ORCO') IS NULL
    EXEC(N'CREATE SCHEMA ORCO');
GO

IF OBJECT_ID(N'ORCO.EstatusOrdenCompra', N'U') IS NULL
BEGIN
    CREATE TABLE ORCO.EstatusOrdenCompra
    (
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

SET IDENTITY_INSERT ORCO.EstatusOrdenCompra ON;

MERGE ORCO.EstatusOrdenCompra AS target
USING
(
    VALUES
        (1, N'INICIAL', N'#FFD6D6', 1, CAST(GETDATE() AS DATETIME), NULL, NULL, 1),
        (2, N'POR SURTIR', N'#FFD6D6', 1, CAST(GETDATE() AS DATETIME), NULL, NULL, 1),
        (3, N'SURTIDO PARCIAL', N'#FFF8CC', 1, CAST(GETDATE() AS DATETIME), NULL, NULL, 1),
        (4, N'SURTIDO TOTAL', N'#DFF6DD', 1, CAST(GETDATE() AS DATETIME), NULL, NULL, 1),
        (5, N'CERRADO', N'#DFF6DD', 1, CAST(GETDATE() AS DATETIME), NULL, NULL, 1)
) AS source (PK_IdEstatusOrdenCompra, Descripcion, Color, CT_CreatedBy, CT_CreatedDate, CT_ModifiedBy, CT_ModifiedDate, CT_LIVE)
ON target.PK_IdEstatusOrdenCompra = source.PK_IdEstatusOrdenCompra
WHEN MATCHED THEN
    UPDATE SET
        Descripcion = source.Descripcion,
        Color = source.Color,
        CT_LIVE = source.CT_LIVE
WHEN NOT MATCHED THEN
    INSERT (PK_IdEstatusOrdenCompra, Descripcion, Color, CT_CreatedBy, CT_CreatedDate, CT_ModifiedBy, CT_ModifiedDate, CT_LIVE)
    VALUES (source.PK_IdEstatusOrdenCompra, source.Descripcion, source.Color, source.CT_CreatedBy, source.CT_CreatedDate, source.CT_ModifiedBy, source.CT_ModifiedDate, source.CT_LIVE);

SET IDENTITY_INSERT ORCO.EstatusOrdenCompra OFF;
GO

IF OBJECT_ID(N'ORCO.OrdenCompra', N'U') IS NULL
BEGIN
    CREATE TABLE ORCO.OrdenCompra
    (
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

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OrdenCompra_Estatus' AND object_id = OBJECT_ID(N'ORCO.OrdenCompra'))
    CREATE INDEX IX_OrdenCompra_Estatus ON ORCO.OrdenCompra (FKIdEstatusOrdenCompra_ORCO) WHERE Activo = 1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OrdenCompra_Proveedor' AND object_id = OBJECT_ID(N'ORCO.OrdenCompra'))
    CREATE INDEX IX_OrdenCompra_Proveedor ON ORCO.OrdenCompra (FKIdProveedor_SIS) WHERE Activo = 1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OrdenCompra_Fecha' AND object_id = OBJECT_ID(N'ORCO.OrdenCompra'))
    CREATE INDEX IX_OrdenCompra_Fecha ON ORCO.OrdenCompra (FechaOrdenCompra) WHERE Activo = 1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OrdenCompra_Requisicion' AND object_id = OBJECT_ID(N'ORCO.OrdenCompra'))
    CREATE INDEX IX_OrdenCompra_Requisicion ON ORCO.OrdenCompra (FKIdRequisicion_ORCO) WHERE Activo = 1;
GO

IF OBJECT_ID(N'ORCO.OrdenCompraDetalle', N'U') IS NULL
BEGIN
    CREATE TABLE ORCO.OrdenCompraDetalle
    (
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

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OrdenCompraDetalle_Orden' AND object_id = OBJECT_ID(N'ORCO.OrdenCompraDetalle'))
    CREATE INDEX IX_OrdenCompraDetalle_Orden ON ORCO.OrdenCompraDetalle (FKIdOrdenCompra_ORCO) WHERE Activo = 1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OrdenCompraDetalle_TipoBien' AND object_id = OBJECT_ID(N'ORCO.OrdenCompraDetalle'))
    CREATE INDEX IX_OrdenCompraDetalle_TipoBien ON ORCO.OrdenCompraDetalle (FKIdTipoBien_ALMA) WHERE Activo = 1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OrdenCompraDetalle_RequisicionDet' AND object_id = OBJECT_ID(N'ORCO.OrdenCompraDetalle'))
    CREATE INDEX IX_OrdenCompraDetalle_RequisicionDet ON ORCO.OrdenCompraDetalle (FKIdRequisicionDetalle_ORCO) WHERE Activo = 1;
GO

IF OBJECT_ID(N'ORCO.OrdenCompraPartida', N'U') IS NULL
BEGIN
    CREATE TABLE ORCO.OrdenCompraPartida
    (
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

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OrdenCompraPartida_Orden' AND object_id = OBJECT_ID(N'ORCO.OrdenCompraPartida'))
    CREATE INDEX IX_OrdenCompraPartida_Orden ON ORCO.OrdenCompraPartida (FKIdOrdenCompra_ORCO) WHERE Activo = 1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OrdenCompraPartida_Partida' AND object_id = OBJECT_ID(N'ORCO.OrdenCompraPartida'))
    CREATE INDEX IX_OrdenCompraPartida_Partida ON ORCO.OrdenCompraPartida (FKIdPartida_CONTA) WHERE Activo = 1;
GO
