USE [GestionEmpresarial];
GO

-- =============================================
-- TABLAS DEL MÓDULO TES (Tesoría)
-- =============================================

-- 1. TES.TipoMoneda (Catálogo de monedas)
IF OBJECT_ID('TES.TipoMoneda', 'U') IS NOT NULL DROP TABLE TES.TipoMoneda;
GO
CREATE TABLE TES.TipoMoneda (
    PKIdTipoMoneda INT IDENTITY(1,1) NOT NULL,
    FKIdPais_SIS INT NOT NULL,
    Descripcion NVARCHAR(50) NOT NULL,
    CodigoISO4217 CHAR(3) NULL,
    Simbolo NVARCHAR(5) NULL,
    Decimales INT NOT NULL DEFAULT 2,
    Activo BIT NOT NULL CONSTRAINT DF_TipoMoneda_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_TipoMoneda_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_TipoMoneda PRIMARY KEY (PKIdTipoMoneda),
    CONSTRAINT FK_TipoMoneda_Pais FOREIGN KEY (FKIdPais_SIS) REFERENCES SIS.Paises(PKIdPais),
    CONSTRAINT FK_TipoMoneda_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_TipoMoneda_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

SET IDENTITY_INSERT TES.TipoMoneda ON;
INSERT INTO TES.TipoMoneda (PKIdTipoMoneda, FKIdPais_SIS, Descripcion, CodigoISO4217, Simbolo, Decimales, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdTipoMoneda, Fk_IdPais__SIS = 1, Descripcion, NULL, NULL, 2, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.TES.TipoMoneda
WHERE NOT EXISTS (SELECT 1 FROM TES.TipoMoneda WHERE PKIdTipoMoneda = PK_IdTipoMoneda);
SET IDENTITY_INSERT TES.TipoMoneda OFF;
GO

-- 2. TES.TipoCambio (Tipo de cambio diario)
IF OBJECT_ID('TES.TipoCambio', 'U') IS NOT NULL DROP TABLE TES.TipoCambio;
GO
CREATE TABLE TES.TipoCambio (
    PKIdTipoCambio INT IDENTITY(1,1) NOT NULL,
    FKIdTipoMoneda_TES INT NOT NULL,
    Cantidad DECIMAL(18,2) NOT NULL,
    Fecha DATETIME NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_TipoCambio_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_TipoCambio_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_TipoCambio PRIMARY KEY (PKIdTipoCambio),
    CONSTRAINT FK_TipoCambio_TipoMoneda FOREIGN KEY (FKIdTipoMoneda_TES) REFERENCES TES.TipoMoneda(PKIdTipoMoneda),
    CONSTRAINT FK_TipoCambio_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_TipoCambio_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

SET IDENTITY_INSERT TES.TipoCambio ON;
INSERT INTO TES.TipoCambio (PKIdTipoCambio, FKIdTipoMoneda_TES, Cantidad, Fecha, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdTipoCambio, FK_IdTipoMoneda__TES, Cantidad, Fecha, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.TES.TipoCambio
WHERE NOT EXISTS (SELECT 1 FROM TES.TipoCambio WHERE PKIdTipoCambio = PK_IdTipoCambio);
SET IDENTITY_INSERT TES.TipoCambio OFF;
GO

-- 3. TES.TipoInversion (Catálogo de tipos de inversión)
IF OBJECT_ID('TES.TipoInversion', 'U') IS NOT NULL DROP TABLE TES.TipoInversion;
GO
CREATE TABLE TES.TipoInversion (
    PKIdTipoInversion INT IDENTITY(1,1) NOT NULL,
    Descripcion NVARCHAR(50) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_TipoInversion_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_TipoInversion_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_TipoInversion PRIMARY KEY (PKIdTipoInversion),
    CONSTRAINT FK_TipoInversion_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_TipoInversion_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

SET IDENTITY_INSERT TES.TipoInversion ON;
INSERT INTO TES.TipoInversion (PKIdTipoInversion, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdTipoInversion, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.TES.TipoInversion
WHERE NOT EXISTS (SELECT 1 FROM TES.TipoInversion WHERE PKIdTipoInversion = PK_IdTipoInversion);
SET IDENTITY_INSERT TES.TipoInversion OFF;
GO

-- 4. TES.TipoPago (Catálogo de tipos de pago)
IF OBJECT_ID('TES.TipoPago', 'U') IS NOT NULL DROP TABLE TES.TipoPago;
GO
CREATE TABLE TES.TipoPago (
    PKIdTipoPago INT IDENTITY(1,1) NOT NULL,
    Descripcion NVARCHAR(50) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_TipoPago_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_TipoPago_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_TipoPago PRIMARY KEY (PKIdTipoPago),
    CONSTRAINT FK_TipoPago_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_TipoPago_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

SET IDENTITY_INSERT TES.TipoPago ON;
INSERT INTO TES.TipoPago (PKIdTipoPago, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdTipoPago, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.TES.TipoPago
WHERE NOT EXISTS (SELECT 1 FROM TES.TipoPago WHERE PKIdTipoPago = PK_IdTipoPago);
SET IDENTITY_INSERT TES.TipoPago OFF;
GO

-- 5. TES.TipoPagoSF (Catálogo de tipos de pago para sistema financiero)
IF OBJECT_ID('TES.TipoPagoSF', 'U') IS NOT NULL DROP TABLE TES.TipoPagoSF;
GO
CREATE TABLE TES.TipoPagoSF (
    PKIdTipoPagoSF INT IDENTITY(1,1) NOT NULL,
    Descripcion NVARCHAR(50) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_TipoPagoSF_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_TipoPagoSF_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_TipoPagoSF PRIMARY KEY (PKIdTipoPagoSF),
    CONSTRAINT FK_TipoPagoSF_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_TipoPagoSF_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

SET IDENTITY_INSERT TES.TipoPagoSF ON;
INSERT INTO TES.TipoPagoSF (PKIdTipoPagoSF, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdTipoPagoSF, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.TES.TipoPagoSF
WHERE NOT EXISTS (SELECT 1 FROM TES.TipoPagoSF WHERE PKIdTipoPagoSF = PK_IdTipoPagoSF);
SET IDENTITY_INSERT TES.TipoPagoSF OFF;
GO

-- 6. TES.TipoSolicitudCLC (Catálogo de tipos de solicitud CLC)
IF OBJECT_ID('TES.TipoSolicitudCLC', 'U') IS NOT NULL DROP TABLE TES.TipoSolicitudCLC;
GO
CREATE TABLE TES.TipoSolicitudCLC (
    PKIdTipoSolicitudCLC INT IDENTITY(1,1) NOT NULL,
    Descripcion NVARCHAR(50) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_TipoSolicitudCLC_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_TipoSolicitudCLC_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_TipoSolicitudCLC PRIMARY KEY (PKIdTipoSolicitudCLC),
    CONSTRAINT FK_TipoSolicitudCLC_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_TipoSolicitudCLC_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

SET IDENTITY_INSERT TES.TipoSolicitudCLC ON;
INSERT INTO TES.TipoSolicitudCLC (PKIdTipoSolicitudCLC, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdTipoSolicitudCLC, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.TES.TipoSolicitudCLC
WHERE NOT EXISTS (SELECT 1 FROM TES.TipoSolicitudCLC WHERE PKIdTipoSolicitudCLC = PK_IdTipoSolicitudCLC);
SET IDENTITY_INSERT TES.TipoSolicitudCLC OFF;
GO

-- =============================================
-- TABLAS DEL MÓDULO SIS
-- =============================================

-- 7. SIS.TipoDoctoCLC (Catálogo de tipos de documento CLC)
IF OBJECT_ID('SIS.TipoDoctoCLC', 'U') IS NOT NULL DROP TABLE SIS.TipoDoctoCLC;
GO
CREATE TABLE SIS.TipoDoctoCLC (
    PKIdTipoDoctoCLC INT IDENTITY(1,1) NOT NULL,
    Clave NVARCHAR(50) NOT NULL,
    Nombre NVARCHAR(50) NOT NULL,
    TipoRecurso VARCHAR(1) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_TipoDoctoCLC_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_TipoDoctoCLC_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_TipoDoctoCLC PRIMARY KEY (PKIdTipoDoctoCLC),
    CONSTRAINT FK_TipoDoctoCLC_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_TipoDoctoCLC_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

SET IDENTITY_INSERT SIS.TipoDoctoCLC ON;
INSERT INTO SIS.TipoDoctoCLC (PKIdTipoDoctoCLC, Clave, Nombre, TipoRecurso, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdTipoDoctoCLC, Clave, Nombre, TipoRecurso, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SIS.TipoDoctoCLC
WHERE NOT EXISTS (SELECT 1 FROM SIS.TipoDoctoCLC WHERE PKIdTipoDoctoCLC = PK_IdTipoDoctoCLC);
SET IDENTITY_INSERT SIS.TipoDoctoCLC OFF;
GO

-- Otorgar permisos de lectura
--GRANT SELECT ON TES.TipoMoneda TO PUBLIC;
--GRANT SELECT ON TES.TipoCambio TO PUBLIC;
--GRANT SELECT ON TES.TipoInversion TO PUBLIC;
--GRANT SELECT ON TES.TipoPago TO PUBLIC;
--GRANT SELECT ON TES.TipoPagoSF TO PUBLIC;
--GRANT SELECT ON TES.TipoSolicitudCLC TO PUBLIC;
--GRANT SELECT ON SIS.TipoDoctoCLC TO PUBLIC;
--GO

PRINT 'Todas las tablas de TES y SIS han sido creadas y migradas exitosamente.';