USE [GestionEmpresarial];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF SCHEMA_ID(N'TES') IS NULL EXEC(N'CREATE SCHEMA TES;');
GO

-- =============================================
-- SIS.Banco
-- =============================================
IF OBJECT_ID(N'SIS.Banco', N'U') IS NULL
BEGIN
CREATE TABLE SIS.Banco (
    PKIdBanco INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    Clave NVARCHAR(10) NOT NULL,
    Nombre NVARCHAR(200) NOT NULL,
    NombreCorto NVARCHAR(50) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Banco_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Banco_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Banco PRIMARY KEY (PKIdBanco),
    CONSTRAINT FK_Banco_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_Banco_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Banco_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
END
GO
IF OBJECT_ID(N'SIS.Banco', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Banco_Empresa' AND object_id = OBJECT_ID(N'SIS.Banco'))
CREATE INDEX IX_Banco_Empresa ON SIS.Banco (FKIdEmpresa_SIS) WHERE Activo = 1;
GO
IF OBJECT_ID(N'SIS.Banco', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Banco_Clave' AND object_id = OBJECT_ID(N'SIS.Banco'))
CREATE INDEX IX_Banco_Clave ON SIS.Banco (Clave) WHERE Activo = 1;
GO

IF OBJECT_ID(N'PRES.Contrato', N'U') IS NULL
BEGIN
CREATE TABLE PRES.Contrato (
    PKIdContrato INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdAutorizacionSuficiencia_PRES INT NOT NULL,
    FKIdProveedor_SIS INT NOT NULL,
    FKIdPoliza_CONTA INT NULL,
    NumeroContrato NVARCHAR(50) NOT NULL,
    Descripcion NVARCHAR(500) NOT NULL,
    FechaContrato DATE NOT NULL,
    FechaInicioVigencia DATE NULL,
    FechaFinVigencia DATE NULL,
    MontoTotal [dbo].[dmoney] NOT NULL,
    PlazoEjecucion NVARCHAR(100) NULL,
    Observaciones NVARCHAR(MAX) NULL,
    Estatus INT NOT NULL CONSTRAINT DF_Contrato_Estatus DEFAULT (1),
    Activo BIT NOT NULL CONSTRAINT DF_Contrato_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Contrato_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Contrato PRIMARY KEY (PKIdContrato),
    CONSTRAINT FK_Contrato_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_Contrato_AutorizacionSuficiencia FOREIGN KEY (FKIdAutorizacionSuficiencia_PRES) REFERENCES PRES.AutorizacionSuficiencia(PKIdAutorizacionSuficiencia),
    CONSTRAINT FK_Contrato_Proveedor FOREIGN KEY (FKIdProveedor_SIS) REFERENCES SIS.Proveedor(PKIdProveedor),
    CONSTRAINT FK_Contrato_Poliza FOREIGN KEY (FKIdPoliza_CONTA) REFERENCES CONTA.Poliza(PKIdPoliza),
    CONSTRAINT FK_Contrato_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Contrato_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
END
GO
IF OBJECT_ID(N'PRES.Contrato', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Contrato_Autorizacion' AND object_id = OBJECT_ID(N'PRES.Contrato'))
CREATE INDEX IX_Contrato_Autorizacion ON PRES.Contrato (FKIdAutorizacionSuficiencia_PRES) WHERE Activo = 1;
GO
IF OBJECT_ID(N'PRES.Contrato', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Contrato_Proveedor' AND object_id = OBJECT_ID(N'PRES.Contrato'))
CREATE INDEX IX_Contrato_Proveedor ON PRES.Contrato (FKIdProveedor_SIS) WHERE Activo = 1;
GO
IF OBJECT_ID(N'PRES.Contrato', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Contrato_Estatus' AND object_id = OBJECT_ID(N'PRES.Contrato'))
CREATE INDEX IX_Contrato_Estatus ON PRES.Contrato (Estatus) WHERE Activo = 1;
GO

IF OBJECT_ID(N'PRES.ContratoDetalle', N'U') IS NULL
BEGIN
CREATE TABLE PRES.ContratoDetalle (
    PKIdContratoDetalle INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdContrato_PRES INT NOT NULL,
    FKIdAutorizacionSuficienciaDetalle_PRES INT NOT NULL,
    FKIdPartida_CONTA INT NOT NULL,
    Enero [dbo].[dmoney] NULL CONSTRAINT DF_ContratoDetalle_Ene DEFAULT (0),
    Febrero [dbo].[dmoney] NULL CONSTRAINT DF_ContratoDetalle_Feb DEFAULT (0),
    Marzo [dbo].[dmoney] NULL CONSTRAINT DF_ContratoDetalle_Mar DEFAULT (0),
    Abril [dbo].[dmoney] NULL CONSTRAINT DF_ContratoDetalle_Abr DEFAULT (0),
    Mayo [dbo].[dmoney] NULL CONSTRAINT DF_ContratoDetalle_May DEFAULT (0),
    Junio [dbo].[dmoney] NULL CONSTRAINT DF_ContratoDetalle_Jun DEFAULT (0),
    Julio [dbo].[dmoney] NULL CONSTRAINT DF_ContratoDetalle_Jul DEFAULT (0),
    Agosto [dbo].[dmoney] NULL CONSTRAINT DF_ContratoDetalle_Ago DEFAULT (0),
    Septiembre [dbo].[dmoney] NULL CONSTRAINT DF_ContratoDetalle_Sep DEFAULT (0),
    Octubre [dbo].[dmoney] NULL CONSTRAINT DF_ContratoDetalle_Oct DEFAULT (0),
    Noviembre [dbo].[dmoney] NULL CONSTRAINT DF_ContratoDetalle_Nov DEFAULT (0),
    Diciembre [dbo].[dmoney] NULL CONSTRAINT DF_ContratoDetalle_Dic DEFAULT (0),
    Total AS (ISNULL(Enero,0) + ISNULL(Febrero,0) + ISNULL(Marzo,0) + ISNULL(Abril,0) +
              ISNULL(Mayo,0) + ISNULL(Junio,0) + ISNULL(Julio,0) + ISNULL(Agosto,0) +
              ISNULL(Septiembre,0) + ISNULL(Octubre,0) + ISNULL(Noviembre,0) + ISNULL(Diciembre,0)),
    Observaciones NVARCHAR(500) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_ContratoDetalle_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_ContratoDetalle_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_ContratoDetalle PRIMARY KEY (PKIdContratoDetalle),
    CONSTRAINT FK_ContratoDetalle_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_ContratoDetalle_Contrato FOREIGN KEY (FKIdContrato_PRES) REFERENCES PRES.Contrato(PKIdContrato),
    CONSTRAINT FK_ContratoDetalle_AutorizacionDetalle FOREIGN KEY (FKIdAutorizacionSuficienciaDetalle_PRES) REFERENCES PRES.AutorizacionSuficienciaDetalle(PKIdAutorizacionSuficienciaDetalle),
    CONSTRAINT FK_ContratoDetalle_Partida FOREIGN KEY (FKIdPartida_CONTA) REFERENCES CONTA.Partida(PKIdPartida),
    CONSTRAINT FK_ContratoDetalle_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_ContratoDetalle_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
END
GO
IF OBJECT_ID(N'PRES.ContratoDetalle', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ContratoDetalle_Contrato' AND object_id = OBJECT_ID(N'PRES.ContratoDetalle'))
CREATE INDEX IX_ContratoDetalle_Contrato ON PRES.ContratoDetalle (FKIdContrato_PRES) WHERE Activo = 1;
GO
IF OBJECT_ID(N'PRES.ContratoDetalle', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ContratoDetalle_AutorizacionDetalle' AND object_id = OBJECT_ID(N'PRES.ContratoDetalle'))
CREATE INDEX IX_ContratoDetalle_AutorizacionDetalle ON PRES.ContratoDetalle (FKIdAutorizacionSuficienciaDetalle_PRES) WHERE Activo = 1;
GO

IF OBJECT_ID(N'PRES.Factura', N'U') IS NULL
BEGIN
CREATE TABLE PRES.Factura (
    PKIdFactura INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdContrato_PRES INT NOT NULL,
    FKIdPoliza_CONTA INT NOT NULL,
    NumFactura NVARCHAR(250) NOT NULL,
    SerieFactura NVARCHAR(20) NULL,
    FechaEmision DATE NOT NULL,
    FechaRecepcion DATE NULL,
    Subtotal [dbo].[dmoney] NULL,
    IVA [dbo].[dmoney] NULL,
    Retencion [dbo].[dmoney] NULL,
    Total [dbo].[dmoney] NOT NULL,
    UUID NVARCHAR(36) NULL,
    FL_Docto NVARCHAR(1000) NULL,
    Observaciones NVARCHAR(MAX) NULL,
    Estatus INT NOT NULL CONSTRAINT DF_Factura_Estatus DEFAULT (1),
    Activo BIT NOT NULL CONSTRAINT DF_Factura_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Factura_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Factura PRIMARY KEY (PKIdFactura),
    CONSTRAINT FK_Factura_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_Factura_Contrato FOREIGN KEY (FKIdContrato_PRES) REFERENCES PRES.Contrato(PKIdContrato),
    CONSTRAINT FK_Factura_Poliza FOREIGN KEY (FKIdPoliza_CONTA) REFERENCES CONTA.Poliza(PKIdPoliza),
    CONSTRAINT FK_Factura_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Factura_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
END
GO
IF OBJECT_ID(N'PRES.Factura', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Factura_Contrato' AND object_id = OBJECT_ID(N'PRES.Factura'))
CREATE INDEX IX_Factura_Contrato ON PRES.Factura (FKIdContrato_PRES) WHERE Activo = 1;
GO
IF OBJECT_ID(N'PRES.Factura', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Factura_NumFactura' AND object_id = OBJECT_ID(N'PRES.Factura'))
CREATE INDEX IX_Factura_NumFactura ON PRES.Factura (NumFactura) WHERE Activo = 1;
GO

IF OBJECT_ID(N'PRES.FacturaDetalle', N'U') IS NULL
BEGIN
CREATE TABLE PRES.FacturaDetalle (
    PKIdFacturaDetalle INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdFactura_PRES INT NOT NULL,
    FKIdContratoDetalle_PRES INT NOT NULL,
    FKIdPartida_CONTA INT NOT NULL,
    MontoAplicado [dbo].[dmoney] NOT NULL,
    Observaciones NVARCHAR(500) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_FacturaDetalle_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_FacturaDetalle_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_FacturaDetalle PRIMARY KEY (PKIdFacturaDetalle),
    CONSTRAINT FK_FacturaDetalle_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_FacturaDetalle_Factura FOREIGN KEY (FKIdFactura_PRES) REFERENCES PRES.Factura(PKIdFactura),
    CONSTRAINT FK_FacturaDetalle_ContratoDetalle FOREIGN KEY (FKIdContratoDetalle_PRES) REFERENCES PRES.ContratoDetalle(PKIdContratoDetalle),
    CONSTRAINT FK_FacturaDetalle_Partida FOREIGN KEY (FKIdPartida_CONTA) REFERENCES CONTA.Partida(PKIdPartida),
    CONSTRAINT FK_FacturaDetalle_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_FacturaDetalle_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
END
GO
IF OBJECT_ID(N'PRES.FacturaDetalle', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_FacturaDetalle_Factura' AND object_id = OBJECT_ID(N'PRES.FacturaDetalle'))
CREATE INDEX IX_FacturaDetalle_Factura ON PRES.FacturaDetalle (FKIdFactura_PRES) WHERE Activo = 1;
GO
IF OBJECT_ID(N'PRES.FacturaDetalle', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_FacturaDetalle_ContratoDetalle' AND object_id = OBJECT_ID(N'PRES.FacturaDetalle'))
CREATE INDEX IX_FacturaDetalle_ContratoDetalle ON PRES.FacturaDetalle (FKIdContratoDetalle_PRES) WHERE Activo = 1;
GO

IF OBJECT_ID(N'PRES.CLC', N'U') IS NULL
BEGIN
CREATE TABLE PRES.CLC (
    PKIdCLC INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdContrato_PRES INT NOT NULL,
    FKIdPoliza_CONTA INT NOT NULL,
    NumCLC NVARCHAR(20) NOT NULL,
    FechaSolicitud DATE NOT NULL,
    FechaAutorizacion DATE NULL,
    ImporteTotal [dbo].[dmoney] NOT NULL,
    Observaciones NVARCHAR(500) NULL,
    Estatus INT NOT NULL CONSTRAINT DF_CLC_Estatus DEFAULT (1),
    Activo BIT NOT NULL CONSTRAINT DF_CLC_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_CLC_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_CLC PRIMARY KEY (PKIdCLC),
    CONSTRAINT FK_CLC_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_CLC_Contrato FOREIGN KEY (FKIdContrato_PRES) REFERENCES PRES.Contrato(PKIdContrato),
    CONSTRAINT FK_CLC_Poliza FOREIGN KEY (FKIdPoliza_CONTA) REFERENCES CONTA.Poliza(PKIdPoliza),
    CONSTRAINT FK_CLC_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_CLC_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
END
GO
IF OBJECT_ID(N'PRES.CLC', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_CLC_Contrato' AND object_id = OBJECT_ID(N'PRES.CLC'))
CREATE INDEX IX_CLC_Contrato ON PRES.CLC (FKIdContrato_PRES) WHERE Activo = 1;
GO
IF OBJECT_ID(N'PRES.CLC', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_CLC_NumCLC' AND object_id = OBJECT_ID(N'PRES.CLC'))
CREATE INDEX IX_CLC_NumCLC ON PRES.CLC (NumCLC) WHERE Activo = 1;
GO

IF OBJECT_ID(N'PRES.CLCDetalle', N'U') IS NULL
BEGIN
CREATE TABLE PRES.CLCDetalle (
    PKIdCLCDetalle INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdCLC_PRES INT NOT NULL,
    FKIdContratoDetalle_PRES INT NOT NULL,
    FKIdPartida_CONTA INT NOT NULL,
    Enero [dbo].[dmoney] NULL CONSTRAINT DF_CLCDetalle_Ene DEFAULT (0),
    Febrero [dbo].[dmoney] NULL CONSTRAINT DF_CLCDetalle_Feb DEFAULT (0),
    Marzo [dbo].[dmoney] NULL CONSTRAINT DF_CLCDetalle_Mar DEFAULT (0),
    Abril [dbo].[dmoney] NULL CONSTRAINT DF_CLCDetalle_Abr DEFAULT (0),
    Mayo [dbo].[dmoney] NULL CONSTRAINT DF_CLCDetalle_May DEFAULT (0),
    Junio [dbo].[dmoney] NULL CONSTRAINT DF_CLCDetalle_Jun DEFAULT (0),
    Julio [dbo].[dmoney] NULL CONSTRAINT DF_CLCDetalle_Jul DEFAULT (0),
    Agosto [dbo].[dmoney] NULL CONSTRAINT DF_CLCDetalle_Ago DEFAULT (0),
    Septiembre [dbo].[dmoney] NULL CONSTRAINT DF_CLCDetalle_Sep DEFAULT (0),
    Octubre [dbo].[dmoney] NULL CONSTRAINT DF_CLCDetalle_Oct DEFAULT (0),
    Noviembre [dbo].[dmoney] NULL CONSTRAINT DF_CLCDetalle_Nov DEFAULT (0),
    Diciembre [dbo].[dmoney] NULL CONSTRAINT DF_CLCDetalle_Dic DEFAULT (0),
    Total AS (ISNULL(Enero,0) + ISNULL(Febrero,0) + ISNULL(Marzo,0) + ISNULL(Abril,0) +
              ISNULL(Mayo,0) + ISNULL(Junio,0) + ISNULL(Julio,0) + ISNULL(Agosto,0) +
              ISNULL(Septiembre,0) + ISNULL(Octubre,0) + ISNULL(Noviembre,0) + ISNULL(Diciembre,0)),
    Observaciones NVARCHAR(500) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_CLCDetalle_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_CLCDetalle_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_CLCDetalle PRIMARY KEY (PKIdCLCDetalle),
    CONSTRAINT FK_CLCDetalle_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_CLCDetalle_CLC FOREIGN KEY (FKIdCLC_PRES) REFERENCES PRES.CLC(PKIdCLC),
    CONSTRAINT FK_CLCDetalle_ContratoDetalle FOREIGN KEY (FKIdContratoDetalle_PRES) REFERENCES PRES.ContratoDetalle(PKIdContratoDetalle),
    CONSTRAINT FK_CLCDetalle_Partida FOREIGN KEY (FKIdPartida_CONTA) REFERENCES CONTA.Partida(PKIdPartida),
    CONSTRAINT FK_CLCDetalle_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_CLCDetalle_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
END
GO
IF OBJECT_ID(N'PRES.CLCDetalle', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_CLCDetalle_CLC' AND object_id = OBJECT_ID(N'PRES.CLCDetalle'))
CREATE INDEX IX_CLCDetalle_CLC ON PRES.CLCDetalle (FKIdCLC_PRES) WHERE Activo = 1;
GO
IF OBJECT_ID(N'PRES.CLCDetalle', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_CLCDetalle_ContratoDetalle' AND object_id = OBJECT_ID(N'PRES.CLCDetalle'))
CREATE INDEX IX_CLCDetalle_ContratoDetalle ON PRES.CLCDetalle (FKIdContratoDetalle_PRES) WHERE Activo = 1;
GO

IF OBJECT_ID(N'PRES.CLCFactura', N'U') IS NULL
BEGIN
CREATE TABLE PRES.CLCFactura (
    PKIdCLCFactura INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdCLC_PRES INT NOT NULL,
    FKIdFactura_PRES INT NOT NULL,
    FKIdFacturaDetalle_PRES INT NOT NULL,
    MontoAplicado [dbo].[dmoney] NOT NULL,
    Observaciones NVARCHAR(500) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_CLCFactura_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_CLCFactura_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_CLCFactura PRIMARY KEY (PKIdCLCFactura),
    CONSTRAINT FK_CLCFactura_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_CLCFactura_CLC FOREIGN KEY (FKIdCLC_PRES) REFERENCES PRES.CLC(PKIdCLC),
    CONSTRAINT FK_CLCFactura_Factura FOREIGN KEY (FKIdFactura_PRES) REFERENCES PRES.Factura(PKIdFactura),
    CONSTRAINT FK_CLCFactura_FacturaDetalle FOREIGN KEY (FKIdFacturaDetalle_PRES) REFERENCES PRES.FacturaDetalle(PKIdFacturaDetalle),
    CONSTRAINT FK_CLCFactura_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_CLCFactura_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
END
GO
IF OBJECT_ID(N'PRES.CLCFactura', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_CLCFactura_CLC' AND object_id = OBJECT_ID(N'PRES.CLCFactura'))
CREATE INDEX IX_CLCFactura_CLC ON PRES.CLCFactura (FKIdCLC_PRES) WHERE Activo = 1;
GO
IF OBJECT_ID(N'PRES.CLCFactura', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_CLCFactura_Factura' AND object_id = OBJECT_ID(N'PRES.CLCFactura'))
CREATE INDEX IX_CLCFactura_Factura ON PRES.CLCFactura (FKIdFactura_PRES) WHERE Activo = 1;
GO

-- =============================================
-- TES.CuentaBancaria
-- =============================================
IF OBJECT_ID(N'TES.CuentaBancaria', N'U') IS NULL
BEGIN
CREATE TABLE TES.CuentaBancaria (
    PKIdCuentaBancaria INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdBanco_SIS INT NULL,
    FKIdTipoMoneda_TES INT NOT NULL,
    NumeroCuenta NVARCHAR(50) NOT NULL,
    CLABE NVARCHAR(18) NULL,
    Titular NVARCHAR(200) NOT NULL,
    SaldoInicial [dbo].[dmoney] NOT NULL CONSTRAINT DF_CuentaBancaria_SaldoInicial DEFAULT (0),
    SaldoActual [dbo].[dmoney] NOT NULL CONSTRAINT DF_CuentaBancaria_SaldoActual DEFAULT (0),
    FechaApertura DATE NULL,
    Activo BIT NOT NULL CONSTRAINT DF_CuentaBancaria_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_CuentaBancaria_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_CuentaBancaria PRIMARY KEY (PKIdCuentaBancaria),
    CONSTRAINT FK_CuentaBancaria_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_CuentaBancaria_Banco FOREIGN KEY (FKIdBanco_SIS) REFERENCES SIS.Banco(PKIdBanco),
    CONSTRAINT FK_CuentaBancaria_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_CuentaBancaria_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
END
GO
IF OBJECT_ID(N'TES.CuentaBancaria', N'U') IS NOT NULL
   AND OBJECT_ID(N'TES.TipoMoneda', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_CuentaBancaria_TipoMoneda' AND parent_object_id = OBJECT_ID(N'TES.CuentaBancaria'))
EXEC(N'ALTER TABLE TES.CuentaBancaria ADD CONSTRAINT FK_CuentaBancaria_TipoMoneda FOREIGN KEY (FKIdTipoMoneda_TES) REFERENCES TES.TipoMoneda(PKIdTipoMoneda);');
GO
IF OBJECT_ID(N'TES.CuentaBancaria', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_CuentaBancaria_Empresa' AND object_id = OBJECT_ID(N'TES.CuentaBancaria'))
CREATE INDEX IX_CuentaBancaria_Empresa ON TES.CuentaBancaria (FKIdEmpresa_SIS) WHERE Activo = 1;
GO
IF OBJECT_ID(N'TES.CuentaBancaria', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_CuentaBancaria_Banco' AND object_id = OBJECT_ID(N'TES.CuentaBancaria'))
CREATE INDEX IX_CuentaBancaria_Banco ON TES.CuentaBancaria (FKIdBanco_SIS) WHERE Activo = 1;
GO
IF OBJECT_ID(N'TES.CuentaBancaria', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_CuentaBancaria_NumeroCuenta' AND object_id = OBJECT_ID(N'TES.CuentaBancaria'))
CREATE INDEX IX_CuentaBancaria_NumeroCuenta ON TES.CuentaBancaria (NumeroCuenta) WHERE Activo = 1;
GO

IF OBJECT_ID(N'PRES.Cheque', N'U') IS NULL
BEGIN
CREATE TABLE PRES.Cheque (
    PKIdCheque INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdCLC_PRES INT NOT NULL,
    FKIdCuentaBancaria_TES INT NOT NULL,
    FKIdPoliza_CONTA INT NOT NULL,
    FechaEmision DATE NOT NULL,
    NumeroCheque NVARCHAR(50) NOT NULL,
    Concepto NVARCHAR(150) NOT NULL,
    ImporteTotal [dbo].[dmoney] NOT NULL,
    Observaciones NVARCHAR(500) NULL,
    Estatus INT NOT NULL CONSTRAINT DF_Cheque_Estatus DEFAULT (1),
    Activo BIT NOT NULL CONSTRAINT DF_Cheque_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Cheque_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Cheque PRIMARY KEY (PKIdCheque),
    CONSTRAINT FK_Cheque_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_Cheque_CLC FOREIGN KEY (FKIdCLC_PRES) REFERENCES PRES.CLC(PKIdCLC),
    CONSTRAINT FK_Cheque_Poliza FOREIGN KEY (FKIdPoliza_CONTA) REFERENCES CONTA.Poliza(PKIdPoliza),
    CONSTRAINT FK_Cheque_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Cheque_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
END
GO
IF OBJECT_ID(N'PRES.Cheque', N'U') IS NOT NULL
   AND OBJECT_ID(N'TES.CuentaBancaria', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Cheque_CuentaBancaria' AND parent_object_id = OBJECT_ID(N'PRES.Cheque'))
EXEC(N'ALTER TABLE PRES.Cheque ADD CONSTRAINT FK_Cheque_CuentaBancaria FOREIGN KEY (FKIdCuentaBancaria_TES) REFERENCES TES.CuentaBancaria(PKIdCuentaBancaria);');
GO
IF OBJECT_ID(N'PRES.Cheque', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Cheque_CLC' AND object_id = OBJECT_ID(N'PRES.Cheque'))
CREATE INDEX IX_Cheque_CLC ON PRES.Cheque (FKIdCLC_PRES) WHERE Activo = 1;
GO
IF OBJECT_ID(N'PRES.Cheque', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Cheque_Numero' AND object_id = OBJECT_ID(N'PRES.Cheque'))
CREATE INDEX IX_Cheque_Numero ON PRES.Cheque (NumeroCheque) WHERE Activo = 1;
GO

IF OBJECT_ID(N'PRES.ChequePartidas', N'U') IS NULL
BEGIN
CREATE TABLE PRES.ChequePartidas (
    PKIdChequePartida INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdCheque_PRES INT NOT NULL,
    FKIdCLCDetalle_PRES INT NOT NULL,
    FKIdPartida_CONTA INT NOT NULL,
    MontoPagado [dbo].[dmoney] NOT NULL,
    Observaciones NVARCHAR(500) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_ChequePartidas_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_ChequePartidas_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_ChequePartidas PRIMARY KEY (PKIdChequePartida),
    CONSTRAINT FK_ChequePartidas_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_ChequePartidas_Cheque FOREIGN KEY (FKIdCheque_PRES) REFERENCES PRES.Cheque(PKIdCheque),
    CONSTRAINT FK_ChequePartidas_CLCDetalle FOREIGN KEY (FKIdCLCDetalle_PRES) REFERENCES PRES.CLCDetalle(PKIdCLCDetalle),
    CONSTRAINT FK_ChequePartidas_Partida FOREIGN KEY (FKIdPartida_CONTA) REFERENCES CONTA.Partida(PKIdPartida),
    CONSTRAINT FK_ChequePartidas_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_ChequePartidas_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
END
GO
IF OBJECT_ID(N'PRES.ChequePartidas', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ChequePartidas_Cheque' AND object_id = OBJECT_ID(N'PRES.ChequePartidas'))
CREATE INDEX IX_ChequePartidas_Cheque ON PRES.ChequePartidas (FKIdCheque_PRES) WHERE Activo = 1;
GO
IF OBJECT_ID(N'PRES.ChequePartidas', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ChequePartidas_CLCDetalle' AND object_id = OBJECT_ID(N'PRES.ChequePartidas'))
CREATE INDEX IX_ChequePartidas_CLCDetalle ON PRES.ChequePartidas (FKIdCLCDetalle_PRES) WHERE Activo = 1;
GO

-- =============================================
-- Seguridad y menu: Cuentas por pagar
-- =============================================
IF OBJECT_ID(N'SIS.Menu', N'U') IS NOT NULL
BEGIN
    SET IDENTITY_INSERT SIS.Menu ON;

    MERGE INTO SIS.Menu AS TARGET
    USING (VALUES
        (313, N'Solicitud Suficiencia', 1, 300, N'Solicitud Suficiencia', N'/Presupuesto/Egreso/Presupuesto_Comprometido/Solicitud_Suficiencia', N'FaTag', 1, 'ESP', 3, 1, GETDATE()),
        (314, N'Autorizacion Suficiencia', 1, 300, N'Autorizacion Suficiencia', N'/Presupuesto/Egreso/Presupuesto_Comprometido/Autorizacion_Suficiencia', N'FaTag', 1, 'ESP', 4, 1, GETDATE()),
        (315, N'Registro Comprometido', 1, 300, N'Registro Comprometido', N'/Presupuesto/Egreso/Presupuesto_Comprometido/Registro_Comprometido', N'FaTag', 1, 'ESP', 5, 1, GETDATE()),
        (350, N'Tesorería', 1, 2, N'Tesorería', N'/', N'FaTag', 1, 'ESP', 1, 1, GETDATE()),
        (351, N'Cuentas por Pagar', 1, 350, N'Cuentas por Pagar', N'/', N'FaTag', 1, 'ESP', 1, 1, GETDATE()),
        (352, N'Recepción de Facturas y Comprobantes de Pago', 1, 351, N'Recepción de Facturas y Comprobantes de Pago', N'/Presupuesto/Tesorería/CuentasXPagar/Factura_Pago', N'FaTag', 1, 'ESP', 1, 1, GETDATE()),
        (353, N'Provisión del Pago', 1, 351, N'Provisión del Pago', N'/Presupuesto/Tesorería/CuentasXPagar/Provision_Pago', N'FaTag', 1, 'ESP', 1, 1, GETDATE()),
        (354, N'Elaboración de Cheques o Transferencias', 1, 351, N'Elaboración de Cheques o Transferencias', N'/Presupuesto/Tesorería/CuentasXPagar/Cheque_Transferencia', N'FaTag', 1, 'ESP', 1, 1, GETDATE())
    ) AS SOURCE (PKIdMenu, Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta, ImageUrl, Activo, Lenguaje, [Orden], CreatedByOperatorId, CreatedDateTime)
    ON TARGET.PKIdMenu = SOURCE.PKIdMenu
    WHEN MATCHED THEN
        UPDATE SET
            TARGET.Nombre = SOURCE.Nombre,
            TARGET.Tipo = SOURCE.Tipo,
            TARGET.FKIdMenu_SIS = SOURCE.FKIdMenu_SIS,
            TARGET.LegacyName = SOURCE.LegacyName,
            TARGET.Ruta = SOURCE.Ruta,
            TARGET.ImageUrl = SOURCE.ImageUrl,
            TARGET.Activo = SOURCE.Activo,
            TARGET.Lenguaje = SOURCE.Lenguaje,
            TARGET.[Orden] = SOURCE.[Orden]
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (PKIdMenu, Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta, ImageUrl, Activo, Lenguaje, [Orden], CreatedByOperatorId, CreatedDateTime)
        VALUES (SOURCE.PKIdMenu, SOURCE.Nombre, SOURCE.Tipo, SOURCE.FKIdMenu_SIS, SOURCE.LegacyName, SOURCE.Ruta, SOURCE.ImageUrl, SOURCE.Activo, SOURCE.Lenguaje, SOURCE.[Orden], SOURCE.CreatedByOperatorId, SOURCE.CreatedDateTime);

    SET IDENTITY_INSERT SIS.Menu OFF;
END
GO

IF OBJECT_ID(N'dbo.spConfiguracionDeRolYClaims', N'P') IS NOT NULL
BEGIN
    EXEC spConfiguracionDeRolYClaims 'Presupuesto_Comprometido', 'Solicitud_Suficiencia', '10000', 'view,view-menu,CanExportToExcel,authorize';
    EXEC spConfiguracionDeRolYClaims 'CuentasXPagar', 'RecepcionFactura_ComprobantePago', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
    EXEC spConfiguracionDeRolYClaims 'CuentasXPagar', 'Provision_Pago', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
    EXEC spConfiguracionDeRolYClaims 'CuentasXPagar', 'ElaboracionCheque_Transferencia', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
    EXEC spConfiguracionDeRolYClaims 'Presupuesto_Comprometido', 'Autorizacion_Suficiencia', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
    EXEC spConfiguracionDeRolYClaims 'Presupuesto_Comprometido', 'Registro_Comprometido', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
END
GO
