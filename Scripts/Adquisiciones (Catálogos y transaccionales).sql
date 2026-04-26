-- =============================================
-- SCRIPT DE CREACIÓN Y MIGRACIÓN DE TABLAS
-- Módulo: Adquisiciones (Catálogos y transaccionales)
-- Base de datos destino: GestionEmpresarial
-- Basado en estructura fuente: BD_PRESUPUESTO
-- =============================================

USE [GestionEmpresarial];
GO

-- =============================================
-- 1. ORCO.Modalidad
-- =============================================
IF OBJECT_ID('ORCO.Modalidad', 'U') IS NOT NULL DROP TABLE ORCO.Modalidad;
GO
CREATE TABLE ORCO.Modalidad (
    PKIdModalidad INT IDENTITY(1,1) NOT NULL,
    Descripcion NVARCHAR(30) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Modalidad_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Modalidad_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Modalidad PRIMARY KEY (PKIdModalidad),
    CONSTRAINT FK_Modalidad_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Modalidad_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

SET IDENTITY_INSERT ORCO.Modalidad ON;
INSERT INTO ORCO.Modalidad (PKIdModalidad, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdModalidad,
    Descripcion,
    ISNULL(CT_LIVE, 1),
    ISNULL(CT_CreatedDate, GETDATE()),
    ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.ORCO.Modalidad
WHERE NOT EXISTS (SELECT 1 FROM ORCO.Modalidad WHERE PKIdModalidad = PK_IdModalidad);
SET IDENTITY_INSERT ORCO.Modalidad OFF;
GO

-- =============================================
-- 2. ORCO.TipoContrato
-- =============================================
IF OBJECT_ID('ORCO.TipoContrato', 'U') IS NOT NULL DROP TABLE ORCO.TipoContrato;
GO
CREATE TABLE ORCO.TipoContrato (
    PKIdTipoContrato INT IDENTITY(1,1) NOT NULL,
    Descripcion NVARCHAR(25) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_TipoContrato_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_TipoContrato_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_TipoContrato PRIMARY KEY (PKIdTipoContrato),
    CONSTRAINT FK_TipoContrato_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_TipoContrato_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

SET IDENTITY_INSERT ORCO.TipoContrato ON;
INSERT INTO ORCO.TipoContrato (PKIdTipoContrato, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdTipoContrato,
    Descripcion,
    ISNULL(CT_LIVE, 1),
    ISNULL(CT_CreatedDate, GETDATE()),
    ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.ORCO.TipoContrato
WHERE NOT EXISTS (SELECT 1 FROM ORCO.TipoContrato WHERE PKIdTipoContrato = PK_IdTipoContrato);
SET IDENTITY_INSERT ORCO.TipoContrato OFF;
GO

-- =============================================
-- 3. ORCO.TipoDocumento
-- =============================================
IF OBJECT_ID('ORCO.TipoDocumento', 'U') IS NOT NULL DROP TABLE ORCO.TipoDocumento;
GO
CREATE TABLE ORCO.TipoDocumento (
    PKIdTipoDocumento INT IDENTITY(1,1) NOT NULL,
    Descripcion NVARCHAR(25) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_TipoDocumento_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_TipoDocumento_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_TipoDocumento PRIMARY KEY (PKIdTipoDocumento),
    CONSTRAINT FK_TipoDocumento_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_TipoDocumento_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

SET IDENTITY_INSERT ORCO.TipoDocumento ON;
INSERT INTO ORCO.TipoDocumento (PKIdTipoDocumento, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdTipoDocumento,
    Descripcion,
    ISNULL(CT_LIVE, 1),
    ISNULL(CT_CreatedDate, GETDATE()),
    1
FROM BD_PRESUPUESTO.ORCO.TipoDocumento
WHERE NOT EXISTS (SELECT 1 FROM ORCO.TipoDocumento WHERE PKIdTipoDocumento = PK_IdTipoDocumento);
SET IDENTITY_INSERT ORCO.TipoDocumento OFF;
GO

-- =============================================
-- 4. ORCO.TipoGarantia
-- =============================================
IF OBJECT_ID('ORCO.TipoGarantia', 'U') IS NOT NULL DROP TABLE ORCO.TipoGarantia;
GO
CREATE TABLE ORCO.TipoGarantia (
    PKIdTipoGarantia INT IDENTITY(1,1) NOT NULL,
    Descripcion NVARCHAR(25) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_TipoGarantia_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_TipoGarantia_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_TipoGarantia PRIMARY KEY (PKIdTipoGarantia),
    CONSTRAINT FK_TipoGarantia_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_TipoGarantia_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

SET IDENTITY_INSERT ORCO.TipoGarantia ON;
INSERT INTO ORCO.TipoGarantia (PKIdTipoGarantia, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdTipoGarantia,
    Descripcion,
    ISNULL(CT_LIVE, 1),
    ISNULL(CT_CreatedDate, GETDATE()),
    ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.ORCO.TipoGarantia
WHERE NOT EXISTS (SELECT 1 FROM ORCO.TipoGarantia WHERE PKIdTipoGarantia = PK_IdTipoGarantia);
SET IDENTITY_INSERT ORCO.TipoGarantia OFF;
GO

-- =============================================
-- 5. ORCO.ProcedimientoContratacion
-- =============================================
IF OBJECT_ID('ORCO.ProcedimientoContratacion', 'U') IS NOT NULL DROP TABLE ORCO.ProcedimientoContratacion;
GO
CREATE TABLE ORCO.ProcedimientoContratacion (
    PKIdProcedimientoContratacion INT IDENTITY(1,1) NOT NULL,
    Descripcion NVARCHAR(50) NOT NULL,
    FundamentoJuridico TEXT NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_ProcedimientoContratacion_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_ProcedimientoContratacion_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_ProcedimientoContratacion PRIMARY KEY (PKIdProcedimientoContratacion),
    CONSTRAINT FK_ProcedimientoContratacion_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_ProcedimientoContratacion_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

SET IDENTITY_INSERT ORCO.ProcedimientoContratacion ON;
INSERT INTO ORCO.ProcedimientoContratacion (PKIdProcedimientoContratacion, Descripcion, FundamentoJuridico, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdProcedimientoContratacion,
    Descripcion,
    FundamentoJuridico,
    ISNULL(CT_LIVE, 1),
    ISNULL(CT_CreatedDate, GETDATE()),
    ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.ORCO.ProcedimientoContratacion
WHERE NOT EXISTS (SELECT 1 FROM ORCO.ProcedimientoContratacion WHERE PKIdProcedimientoContratacion = PK_IdProcedimientoContratacion);
SET IDENTITY_INSERT ORCO.ProcedimientoContratacion OFF;
GO

-- =============================================
-- 6. ORCO.EstatusRequisicion (Catálogo de estatus para requisiciones)
--    Nota: En origen no existe tabla equivalente, se crea según necesidades.
-- =============================================
IF OBJECT_ID('ORCO.EstatusRequisicion', 'U') IS NOT NULL DROP TABLE ORCO.EstatusRequisicion;
GO
CREATE TABLE ORCO.EstatusRequisicion (
    PKIdEstatusRequisicion INT IDENTITY(1,1) NOT NULL,
    Descripcion NVARCHAR(50) NOT NULL,
    Color NVARCHAR(8) NULL,
    Orden INT NOT NULL DEFAULT 0,
    Icono NVARCHAR(50) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_EstatusRequisicion_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_EstatusRequisicion_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_EstatusRequisicion PRIMARY KEY (PKIdEstatusRequisicion),
    CONSTRAINT FK_EstatusRequisicion_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_EstatusRequisicion_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

-- INSERT de datos iniciales (ejemplo)
SET IDENTITY_INSERT ORCO.EstatusRequisicion ON;
INSERT INTO ORCO.EstatusRequisicion (PKIdEstatusRequisicion, Descripcion, Color, Orden, Icono, Activo, FechaCreacion, UsuarioCreacion)
VALUES 
    (1, 'Borrador', '#6c757d', 10, 'edit', 1, GETDATE(), 1),
    (2, 'Enviada', '#007bff', 20, 'send', 1, GETDATE(), 1),
    (3, 'En Revisión', '#ffc107', 30, 'search', 1, GETDATE(), 1),
    (4, 'Suficiencia', '#17a2b8', 40, 'check-circle', 1, GETDATE(), 1),
    (5, 'Autorizada', '#28a745', 50, 'check', 1, GETDATE(), 1),
    (6, 'Rechazada', '#dc3545', 60, 'times', 1, GETDATE(), 1),
    (7, 'Cancelada', '#6c757d', 70, 'ban', 1, GETDATE(), 1);
SET IDENTITY_INSERT ORCO.EstatusRequisicion OFF;
GO

-- =============================================
-- 7. SIS.TipoProveedor (ya existe en script CONTA, pero se asegura)
-- =============================================
--IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TipoProveedor' AND schema_id = SCHEMA_ID('SIS'))
--BEGIN
--    CREATE TABLE SIS.TipoProveedor (
--        PkIdTipoProveedor INT IDENTITY(1,1) NOT NULL,
--        Descripcion VARCHAR(80) NOT NULL,
--        Activo BIT NOT NULL CONSTRAINT DF_TipoProveedor_Activo DEFAULT (1),
--        FechaCreacion DATETIME CONSTRAINT DF_TipoProveedor_FechaCreacion DEFAULT SYSDATETIME(),
--        UsuarioCreacion INT NOT NULL,
--        FechaModificacion DATETIME NULL,
--        UsuarioModificacion INT NULL,
--        CONSTRAINT PK_TipoProveedor PRIMARY KEY (PkIdTipoProveedor),
--        CONSTRAINT FK_TipoProveedor_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
--        CONSTRAINT FK_TipoProveedor_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
--    );
--END
--GO

--SET IDENTITY_INSERT SIS.TipoProveedor ON;
--INSERT INTO SIS.TipoProveedor (PkIdTipoProveedor, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
--SELECT 
--    Pk_IdTipoProveedor,
--    Descripcion,
--    ISNULL(CT_LIVE, 1),
--    ISNULL(CT_CreatedDate, GETDATE()),
--    ISNULL(CT_CreatedBy, 1)
--FROM BD_PRESUPUESTO.SIS.TipoProveedor
--WHERE NOT EXISTS (SELECT 1 FROM SIS.TipoProveedor WHERE PkIdTipoProveedor = Pk_IdTipoProveedor);
--SET IDENTITY_INSERT SIS.TipoProveedor OFF;
--GO

-- =============================================
-- 8. SIS.EstatusProveedor (ya existe en script CONTA, se asegura)
-- =============================================
--IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EstatusProveedor' AND schema_id = SCHEMA_ID('SIS'))
--BEGIN
--    CREATE TABLE SIS.EstatusProveedor (
--        PKIdEstatusProveedor INT IDENTITY(1,1) NOT NULL,
--        Descripcion NVARCHAR(150) NOT NULL,
--        Color NVARCHAR(8) NULL,
--        Activo BIT NOT NULL CONSTRAINT DF_EstatusProveedor_Activo DEFAULT (1),
--        FechaCreacion DATETIME CONSTRAINT DF_EstatusProveedor_FechaCreacion DEFAULT SYSDATETIME(),
--        UsuarioCreacion INT NOT NULL,
--        FechaModificacion DATETIME NULL,
--        UsuarioModificacion INT NULL,
--        CONSTRAINT PK_EstatusProveedor PRIMARY KEY (PKIdEstatusProveedor),
--        CONSTRAINT FK_EstatusProveedor_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
--        CONSTRAINT FK_EstatusProveedor_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
--    );
--END
--GO

--SET IDENTITY_INSERT SIS.EstatusProveedor ON;
--INSERT INTO SIS.EstatusProveedor (PKIdEstatusProveedor, Descripcion, Color, Activo, FechaCreacion, UsuarioCreacion)
--SELECT 
--    PK_IdEstatusProveedor,
--    Descripcion,
--    Color,
--    ISNULL(CT_LIVE, 1),
--    ISNULL(CT_CreatedDate, GETDATE()),
--    ISNULL(CT_CreatedBy, 1)
--FROM BD_PRESUPUESTO.SIS.EstatusProveedor
--WHERE NOT EXISTS (SELECT 1 FROM SIS.EstatusProveedor WHERE PKIdEstatusProveedor = PK_IdEstatusProveedor);
--SET IDENTITY_INSERT SIS.EstatusProveedor OFF;
--GO

-- =============================================
-- 9. SIS.Proveedor (ya existe en script CONTA, se migran datos adicionales)
-- =============================================
-- La tabla ya fue creada en CONTA.CuentaContable.sql, solo se migran datos faltantes.
--IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Proveedor' AND schema_id = SCHEMA_ID('SIS'))
--BEGIN
--    SET IDENTITY_INSERT SIS.Proveedor ON;
--    INSERT INTO SIS.Proveedor (
--        PKIdProveedor, FkIdTipoProveedor_SIS, FKIdEstatusProveedor_SIS, FKIdCuentaContable_SIS,
--        FKIdMunicipio_SIS, FKIdEstado_SIS, FKIdPais_SIS,
--        Nombre, RFC, Colonia, CP, Ciudad, EMAIL, Clave, Calle, Numero,
--        FechaAlta, TelefonoInstitucional, Notas, PaginaWeb, NumeroInt, CURP,
--        Activo, FechaCreacion, UsuarioCreacion
--    )
--    SELECT 
--        p.PK_IdProveedor, p.Fk_IdTipoProveedor, p.FK_IdEstatusProveedor, tp2.PKIdCuentaContable,
--        p.FK_IdMunicipio__SIS, p.FK_IdEstado__SIS, p.FK_IdPais__SIS,
--        p.Nombre, p.RFC, p.Colonia, p.CP, p.Ciudad, p.EMAIL, p.Clave, p.Calle, p.Numero,
--        p.FechaAlta, p.TelefonoInstitucional, p.Notas, p.PaginaWeb, p.NumeroInt, p.CURP,
--        p.CT_LIVE, p.CT_CreatedDate, p.CT_CreatedBy
--    FROM BD_PRESUPUESTO.SIS.Proveedor p
--    INNER JOIN BD_PRESUPUESTO.SIS.CuentaContable c ON p.FK_IdCuentaContable__SIS = c.PK_IdCuentaContable
--    INNER JOIN SIS.CuentaContable tp2 ON c.Descripcion = tp2.Descripcion
--    WHERE NOT EXISTS (SELECT 1 FROM SIS.Proveedor dest WHERE dest.PKIdProveedor = p.PK_IdProveedor)
--      AND p.Fk_IdTipoProveedor IS NOT NULL
--      AND p.FK_IdEstatusProveedor IS NOT NULL
--      AND p.FK_IdEstado__SIS IS NOT NULL
--      AND p.FK_IdPais__SIS IS NOT NULL
--      AND p.FK_IdMunicipio__SIS IN (SELECT PKIdMunicipio FROM SIS.Municipios);
--    SET IDENTITY_INSERT SIS.Proveedor OFF;
--END
--GO

-- =============================================
-- 10. ORCO.Articulo
-- =============================================
IF OBJECT_ID('ORCO.Articulo', 'U') IS NOT NULL DROP TABLE ORCO.Articulo;
GO
CREATE TABLE ORCO.Articulo (
    PKIdArticulo INT IDENTITY(1,1) NOT NULL,
    Clave NVARCHAR(20) NOT NULL,
    Descripcion NVARCHAR(250) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Articulo_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Articulo_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Articulo PRIMARY KEY (PKIdArticulo),
    CONSTRAINT FK_Articulo_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Articulo_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

SET IDENTITY_INSERT ORCO.Articulo ON;
INSERT INTO ORCO.Articulo (PKIdArticulo, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdArticulo, Clave, Descripcion,
    ISNULL(CT_LIVE, 1),
    ISNULL(CT_CreatedDate, GETDATE()),
    ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.ORCO.Articulo
WHERE NOT EXISTS (SELECT 1 FROM ORCO.Articulo WHERE PKIdArticulo = PK_IdArticulo);
SET IDENTITY_INSERT ORCO.Articulo OFF;
GO

-- =============================================
-- 11. ORCO.Fraccion
-- =============================================
IF OBJECT_ID('ORCO.Fraccion', 'U') IS NOT NULL DROP TABLE ORCO.Fraccion;
GO
CREATE TABLE ORCO.Fraccion (
    PKIdFraccion INT IDENTITY(1,1) NOT NULL,
    FKIdArticulo_ORCO INT NOT NULL,
    Clave NVARCHAR(20) NOT NULL,
    Descripcion NVARCHAR(250) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Fraccion_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Fraccion_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Fraccion PRIMARY KEY (PKIdFraccion),
    CONSTRAINT FK_Fraccion_Articulo FOREIGN KEY (FKIdArticulo_ORCO) REFERENCES ORCO.Articulo(PKIdArticulo),
    CONSTRAINT FK_Fraccion_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Fraccion_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

SET IDENTITY_INSERT ORCO.Fraccion ON;
INSERT INTO ORCO.Fraccion (PKIdFraccion, FKIdArticulo_ORCO, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdFraccion, FK_IdArticulo__ORCO, Clave, Descripcion,
    ISNULL(CT_LIVE, 1),
    ISNULL(CT_CreatedDate, GETDATE()),
    ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.ORCO.Fraccion
WHERE NOT EXISTS (SELECT 1 FROM ORCO.Fraccion WHERE PKIdFraccion = PK_IdFraccion);
SET IDENTITY_INSERT ORCO.Fraccion OFF;
GO

-- =============================================
-- FIN DEL SCRIPT
-- =============================================