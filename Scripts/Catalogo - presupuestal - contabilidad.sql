USE [GestionEmpresarial];
GO

-- =============================================
-- 1. SIS.Capitulo (dependencia de SIS.Concepto)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Capitulo' AND schema_id = SCHEMA_ID('SIS'))
BEGIN
    CREATE TABLE SIS.Capitulo (
        PKIdCapitulo INT IDENTITY(1,1) NOT NULL,
        Clave NVARCHAR(30) NULL,
        Descripcion NVARCHAR(120) NULL,
        Activo BIT NOT NULL CONSTRAINT DF_Capitulo_Activo DEFAULT (1),
        FechaCreacion DATETIME2 CONSTRAINT DF_Capitulo_FechaCreacion DEFAULT SYSDATETIME(),
        UsuarioCreacion INT NOT NULL,
        FechaModificacion DATETIME2 NULL,
        UsuarioModificacion INT NULL,
        CONSTRAINT PK_Capitulo PRIMARY KEY (PKIdCapitulo),
        CONSTRAINT FK_Capitulo_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
        CONSTRAINT FK_Capitulo_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
    );
END
GO

SET IDENTITY_INSERT SIS.Capitulo ON;
INSERT INTO SIS.Capitulo (PKIdCapitulo, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdCapitulo, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SIS.Capitulo
WHERE NOT EXISTS (SELECT 1 FROM SIS.Capitulo WHERE PKIdCapitulo = PK_IdCapitulo);
SET IDENTITY_INSERT SIS.Capitulo OFF;
GO

-- =============================================
-- 2. SIS.Concepto (Partidas Presupuestales)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Concepto' AND schema_id = SCHEMA_ID('SIS'))
BEGIN
    CREATE TABLE SIS.Concepto (
        PKIdConcepto INT IDENTITY(1,1) NOT NULL,
        FKIdCapitulo_SIS INT NOT NULL,
        Clave NVARCHAR(30) NULL,
        Descripcion NVARCHAR(120) NULL,
        Activo BIT NOT NULL CONSTRAINT DF_Concepto_Activo DEFAULT (1),
        FechaCreacion DATETIME2 CONSTRAINT DF_Concepto_FechaCreacion DEFAULT SYSDATETIME(),
        UsuarioCreacion INT NOT NULL,
        FechaModificacion DATETIME2 NULL,
        UsuarioModificacion INT NULL,
        CONSTRAINT PK_Concepto PRIMARY KEY (PKIdConcepto),
        CONSTRAINT FK_Concepto_Capitulo FOREIGN KEY (FKIdCapitulo_SIS) REFERENCES SIS.Capitulo(PKIdCapitulo),
        CONSTRAINT FK_Concepto_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
        CONSTRAINT FK_Concepto_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
    );
END
GO

SET IDENTITY_INSERT SIS.Concepto ON;
INSERT INTO SIS.Concepto (PKIdConcepto, FKIdCapitulo_SIS, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdConcepto, FK_IdCapitulo__SIS, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SIS.Concepto
WHERE NOT EXISTS (SELECT 1 FROM SIS.Concepto WHERE PKIdConcepto = PK_IdConcepto);
SET IDENTITY_INSERT SIS.Concepto OFF;
GO

-- =============================================
-- 3. SIS.Partida (requerida por MatrizConversion)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Partida' AND schema_id = SCHEMA_ID('SIS'))
BEGIN
    CREATE TABLE SIS.Partida (
        PKIdPartida INT IDENTITY(1,1) NOT NULL,
        FKIdConcepto_SIS INT NULL,
        Clave NVARCHAR(10) NOT NULL,
        Descripcion NVARCHAR(255) NOT NULL,
        Activo BIT NOT NULL CONSTRAINT DF_Partida_Activo DEFAULT (1),
        FechaCreacion DATETIME2 CONSTRAINT DF_Partida_FechaCreacion DEFAULT SYSDATETIME(),
        UsuarioCreacion INT NOT NULL,
        FechaModificacion DATETIME2 NULL,
        UsuarioModificacion INT NULL,
        CONSTRAINT PK_Partida PRIMARY KEY (PKIdPartida),
        CONSTRAINT FK_Partida_Concepto FOREIGN KEY (FKIdConcepto_SIS) REFERENCES SIS.Concepto(PKIdConcepto),
        CONSTRAINT FK_Partida_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
        CONSTRAINT FK_Partida_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
    );
END
GO

SET IDENTITY_INSERT SIS.Partida ON;
INSERT INTO SIS.Partida (PKIdPartida, FKIdConcepto_SIS, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdPartida, FK_IdConcepto__SIS, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SIS.Partida
WHERE NOT EXISTS (SELECT 1 FROM SIS.Partida WHERE PKIdPartida = PK_IdPartida);
SET IDENTITY_INSERT SIS.Partida OFF;
GO

-- =============================================
-- 4. SIS.TipoPoliza
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TipoPoliza' AND schema_id = SCHEMA_ID('SIS'))
BEGIN
    CREATE TABLE SIS.TipoPoliza (
        PKIdTipoPoliza INT IDENTITY(1,1) NOT NULL,
        Descripcion NVARCHAR(25) NOT NULL,
        Activo BIT NOT NULL CONSTRAINT DF_TipoPoliza_Activo DEFAULT (1),
        FechaCreacion DATETIME2 CONSTRAINT DF_TipoPoliza_FechaCreacion DEFAULT SYSDATETIME(),
        UsuarioCreacion INT NOT NULL,
        FechaModificacion DATETIME2 NULL,
        UsuarioModificacion INT NULL,
        CONSTRAINT PK_TipoPoliza PRIMARY KEY (PKIdTipoPoliza),
        CONSTRAINT FK_TipoPoliza_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
        CONSTRAINT FK_TipoPoliza_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
    );
END
GO

SET IDENTITY_INSERT SIS.TipoPoliza ON;
INSERT INTO SIS.TipoPoliza (PKIdTipoPoliza, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdTipoPoliza, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SIS.TipoPoliza
WHERE NOT EXISTS (SELECT 1 FROM SIS.TipoPoliza WHERE PKIdTipoPoliza = PK_IdTipoPoliza);
SET IDENTITY_INSERT SIS.TipoPoliza OFF;
GO

-- =============================================
-- 5. SIS.TipoDetallePoliza
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TipoDetallePoliza' AND schema_id = SCHEMA_ID('SIS'))
BEGIN
    CREATE TABLE SIS.TipoDetallePoliza (
        PkIdTipoDetallePoliza INT IDENTITY(1,1) NOT NULL,
        Descripcion NVARCHAR(25) NOT NULL,
        Activo BIT NOT NULL CONSTRAINT DF_TipoDetallePoliza_Activo DEFAULT (1),
        FechaCreacion DATETIME2 CONSTRAINT DF_TipoDetallePoliza_FechaCreacion DEFAULT SYSDATETIME(),
        UsuarioCreacion INT NOT NULL,
        FechaModificacion DATETIME2 NULL,
        UsuarioModificacion INT NULL,
        CONSTRAINT PK_TipoDetallePoliza PRIMARY KEY (PkIdTipoDetallePoliza),
        CONSTRAINT FK_TipoDetallePoliza_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
        CONSTRAINT FK_TipoDetallePoliza_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
    );
END
GO

SET IDENTITY_INSERT SIS.TipoDetallePoliza ON;
INSERT INTO SIS.TipoDetallePoliza (PkIdTipoDetallePoliza, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT Pk_IdTipoDetallePoliza, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SIS.TipoDetallePoliza
WHERE NOT EXISTS (SELECT 1 FROM SIS.TipoDetallePoliza WHERE PkIdTipoDetallePoliza = Pk_IdTipoDetallePoliza);
SET IDENTITY_INSERT SIS.TipoDetallePoliza OFF;
GO

-- =============================================
-- 6. CONTA.TipoDoctoPago (ya existe, solo se migran datos)
-- =============================================
--SET IDENTITY_INSERT CONTA.TipoDoctoPago ON;
--INSERT INTO CONTA.TipoDoctoPago (PK_IdTipoDoctoPago, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
--SELECT PK_IdTipoDoctoPago, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
--FROM BD_PRESUPUESTO.CONTA.TipoDoctoPago
--WHERE NOT EXISTS (SELECT 1 FROM CONTA.TipoDoctoPago WHERE PK_IdTipoDoctoPago = PK_IdTipoDoctoPago);
--SET IDENTITY_INSERT CONTA.TipoDoctoPago OFF;
--GO

-- =============================================
-- 7. PRES.Origen (dependencia de MatrizIngreso)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Origen' AND schema_id = SCHEMA_ID('PRES'))
BEGIN
    CREATE TABLE PRES.Origen (
        PKIdOrigen INT IDENTITY(1,1) NOT NULL,
        Clave INT NOT NULL,
        Descripcion NVARCHAR(50) NOT NULL,
        Activo BIT NOT NULL CONSTRAINT DF_Origen_Activo DEFAULT (1),
        FechaCreacion DATETIME2 CONSTRAINT DF_Origen_FechaCreacion DEFAULT SYSDATETIME(),
        UsuarioCreacion INT NOT NULL,
        FechaModificacion DATETIME2 NULL,
        UsuarioModificacion INT NULL,
        CONSTRAINT PK_Origen PRIMARY KEY (PKIdOrigen),
        CONSTRAINT FK_Origen_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
        CONSTRAINT FK_Origen_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
    );
END
GO

SET IDENTITY_INSERT PRES.Origen ON;
INSERT INTO PRES.Origen (PKIdOrigen, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdOrigen, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.Origen
WHERE NOT EXISTS (SELECT 1 FROM PRES.Origen WHERE PKIdOrigen = PK_IdOrigen);
SET IDENTITY_INSERT PRES.Origen OFF;
GO

-- =============================================
-- 8. CONTA.CuentaContable (ya existe, migramos datos faltantes)
-- =============================================
SET IDENTITY_INSERT CONTA.CuentaContable ON;
INSERT INTO CONTA.CuentaContable (
    PKIdCuentaContable, FKIdEmpresa_SIS, FKIdTipoCuenta_CONTA,
    Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta,
    Saldo, Descripcion, Activo, FechaCreacion, UsuarioCreacion,
    S5, S6, S7, ClaveOrd, Padre, Hijo, NivelCuenta,
    Cta_Coi, Desc_Coi, TipoCuenta, S8, S9, S10
)
SELECT
    s.PK_IdCuentaContable, 1, s.FK_IdTipoCuenta__SIS,
    s.Cuenta, s.SubCuenta, s.SubSubCuenta, s.SubSubSubCuenta, s.SubSubSubSubCuenta,
    s.Saldo, s.Descripcion, s.CT_LIVE, s.CT_CreatedDate, s.CT_CreatedBy,
    s.S5, s.S6, s.S7, s.ClaveOrd, s.Padre, s.Hijo, s.NivelCuenta,
    s.Cta_Coi, s.Desc_Coi, s.TipoCuenta, s.S8, s.S9, s.S10
FROM BD_PRESUPUESTO.SIS.CuentaContable s
WHERE s.FK_IdTipoCuenta__SIS IN (1, 2)
  AND NOT EXISTS (SELECT 1 FROM CONTA.CuentaContable c WHERE c.PKIdCuentaContable = s.PK_IdCuentaContable);
SET IDENTITY_INSERT CONTA.CuentaContable OFF;
GO

-- =============================================
-- 9. CONTA.MatrizConversion
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MatrizConversion' AND schema_id = SCHEMA_ID('CONTA'))
BEGIN
    CREATE TABLE CONTA.MatrizConversion (
        PKIdMatrizConversion INT IDENTITY(1,1) NOT NULL,
        FKIdAnio_SIS INT NOT NULL,
        FKIdPrograma_PRES INT NOT NULL,
        FKIdPartida_SIS INT NOT NULL,
        FKIdCuentaContableAprobado INT NOT NULL,
        FKIdCuentaContablePorEjercer INT NOT NULL,
        FKIdCuentaContableModificado INT NOT NULL,
        FKIdCuentaContableComprometido INT NOT NULL,
        FKIdCuentaContableDevengado INT NOT NULL,
        FKIdCuentaContableEjercido INT NOT NULL,
        FKIdCuentaContablePagado INT NOT NULL,
        FKIdCuentaContableGasto INT NOT NULL,
        Activo BIT NOT NULL CONSTRAINT DF_MatrizConversion_Activo DEFAULT (1),
        FechaCreacion DATETIME2 CONSTRAINT DF_MatrizConversion_FechaCreacion DEFAULT SYSDATETIME(),
        UsuarioCreacion INT NOT NULL,
        FechaModificacion DATETIME2 NULL,
        UsuarioModificacion INT NULL,
        CONSTRAINT PK_MatrizConversion PRIMARY KEY (PKIdMatrizConversion),
        CONSTRAINT FK_MatrizConversion_Anio FOREIGN KEY (FKIdAnio_SIS) REFERENCES SIS.Anio(PKIdAnio),
        CONSTRAINT FK_MatrizConversion_Programa FOREIGN KEY (FKIdPrograma_PRES) REFERENCES PRES.Programa(PKIdPrograma),
        CONSTRAINT FK_MatrizConversion_Partida FOREIGN KEY (FKIdPartida_SIS) REFERENCES SIS.Partida(PKIdPartida),
        CONSTRAINT FK_MatrizConversion_CtaAprobado FOREIGN KEY (FKIdCuentaContableAprobado) REFERENCES CONTA.CuentaContable(PKIdCuentaContable),
        CONSTRAINT FK_MatrizConversion_CtaPorEjercer FOREIGN KEY (FKIdCuentaContablePorEjercer) REFERENCES CONTA.CuentaContable(PKIdCuentaContable),
        CONSTRAINT FK_MatrizConversion_CtaModificado FOREIGN KEY (FKIdCuentaContableModificado) REFERENCES CONTA.CuentaContable(PKIdCuentaContable),
        CONSTRAINT FK_MatrizConversion_CtaComprometido FOREIGN KEY (FKIdCuentaContableComprometido) REFERENCES CONTA.CuentaContable(PKIdCuentaContable),
        CONSTRAINT FK_MatrizConversion_CtaDevengado FOREIGN KEY (FKIdCuentaContableDevengado) REFERENCES CONTA.CuentaContable(PKIdCuentaContable),
        CONSTRAINT FK_MatrizConversion_CtaEjercido FOREIGN KEY (FKIdCuentaContableEjercido) REFERENCES CONTA.CuentaContable(PKIdCuentaContable),
        CONSTRAINT FK_MatrizConversion_CtaPagado FOREIGN KEY (FKIdCuentaContablePagado) REFERENCES CONTA.CuentaContable(PKIdCuentaContable),
        CONSTRAINT FK_MatrizConversion_CtaGasto FOREIGN KEY (FKIdCuentaContableGasto) REFERENCES CONTA.CuentaContable(PKIdCuentaContable),
        CONSTRAINT FK_MatrizConversion_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
        CONSTRAINT FK_MatrizConversion_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
    );
END
GO

SET IDENTITY_INSERT CONTA.MatrizConversion ON;
INSERT INTO CONTA.MatrizConversion (
    PKIdMatrizConversion, FKIdAnio_SIS, FKIdPrograma_PRES, FKIdPartida_SIS,
    FKIdCuentaContableAprobado, FKIdCuentaContablePorEjercer, FKIdCuentaContableModificado,
    FKIdCuentaContableComprometido, FKIdCuentaContableDevengado, FKIdCuentaContableEjercido,
    FKIdCuentaContablePagado, FKIdCuentaContableGasto,
    Activo, FechaCreacion, UsuarioCreacion
)
SELECT
    PK_IdMatrizConversion, FK_IdAnio__SIS, FK_IdPrograma__PRES, FK_IdPartida__SIS,
    FK_IdCuentaContableAprobado, FK_IdCuentaContablePorEjercer, FK_IdCuentaContableModificado,
    FK_IdCuentaContableComprometido, FK_IdCuentaContableDevengado, FK_IdCuentaContableEjercido,
    FK_IdCuentaContablePagado, FK_IdCuentaContableGasto,
    ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), 1
FROM BD_PRESUPUESTO.CONTA.MatrizConversion
WHERE NOT EXISTS (SELECT 1 FROM CONTA.MatrizConversion WHERE PKIdMatrizConversion = PK_IdMatrizConversion);
SET IDENTITY_INSERT CONTA.MatrizConversion OFF;
GO

-- =============================================
-- 10. CONTA.MatrizIngreso
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MatrizIngreso' AND schema_id = SCHEMA_ID('CONTA'))
BEGIN
    CREATE TABLE CONTA.MatrizIngreso (
        Pk_IdMatrizIngreso INT IDENTITY(1,1) NOT NULL,
        Fk_IdPrograma INT NULL,
        Fk_IdOrigen INT NULL,
        Fk_IdCuentaContableAutorizado INT NULL,
        Fk_IdCuentaContablePorEjercer INT NULL,
        Fk_IdCuentaContableModificado INT NULL,
        Fk_IdCuentaContableDevengado INT NULL,
        Fk_IdCuentaContableRecaudado INT NULL,
        Fk_IdCuentaContableDeposito INT NULL,
        FK_IdAnio__SIS INT NULL,
        Activo BIT NOT NULL CONSTRAINT DF_MatrizIngreso_Activo DEFAULT (1),
        FechaCreacion DATETIME2 CONSTRAINT DF_MatrizIngreso_FechaCreacion DEFAULT SYSDATETIME(),
        UsuarioCreacion INT NOT NULL,
        FechaModificacion DATETIME2 NULL,
        UsuarioModificacion INT NULL,
        CONSTRAINT PK_MatrizIngreso PRIMARY KEY (Pk_IdMatrizIngreso),
        CONSTRAINT FK_MatrizIngreso_Programa FOREIGN KEY (Fk_IdPrograma) REFERENCES PRES.Programa(PKIdPrograma),
        CONSTRAINT FK_MatrizIngreso_Origen FOREIGN KEY (Fk_IdOrigen) REFERENCES PRES.Origen(PKIdOrigen),
        CONSTRAINT FK_MatrizIngreso_CtaAutorizado FOREIGN KEY (Fk_IdCuentaContableAutorizado) REFERENCES CONTA.CuentaContable(PKIdCuentaContable),
        CONSTRAINT FK_MatrizIngreso_CtaPorEjercer FOREIGN KEY (Fk_IdCuentaContablePorEjercer) REFERENCES CONTA.CuentaContable(PKIdCuentaContable),
        CONSTRAINT FK_MatrizIngreso_CtaModificado FOREIGN KEY (Fk_IdCuentaContableModificado) REFERENCES CONTA.CuentaContable(PKIdCuentaContable),
        CONSTRAINT FK_MatrizIngreso_CtaDevengado FOREIGN KEY (Fk_IdCuentaContableDevengado) REFERENCES CONTA.CuentaContable(PKIdCuentaContable),
        CONSTRAINT FK_MatrizIngreso_CtaRecaudado FOREIGN KEY (Fk_IdCuentaContableRecaudado) REFERENCES CONTA.CuentaContable(PKIdCuentaContable),
        CONSTRAINT FK_MatrizIngreso_CtaDeposito FOREIGN KEY (Fk_IdCuentaContableDeposito) REFERENCES CONTA.CuentaContable(PKIdCuentaContable),
        CONSTRAINT FK_MatrizIngreso_Anio FOREIGN KEY (FK_IdAnio__SIS) REFERENCES SIS.Anio(PKIdAnio),
        CONSTRAINT FK_MatrizIngreso_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
        CONSTRAINT FK_MatrizIngreso_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
    );
END
GO

SET IDENTITY_INSERT CONTA.MatrizIngreso ON;
INSERT INTO CONTA.MatrizIngreso (
    Pk_IdMatrizIngreso, Fk_IdPrograma, Fk_IdOrigen,
    Fk_IdCuentaContableAutorizado, Fk_IdCuentaContablePorEjercer, Fk_IdCuentaContableModificado,
    Fk_IdCuentaContableDevengado, Fk_IdCuentaContableRecaudado, Fk_IdCuentaContableDeposito,
    FK_IdAnio__SIS, Activo, FechaCreacion, UsuarioCreacion
)
SELECT
    Pk_IdMatrizIngreso, Fk_IdPrograma, Fk_IdOrigen,
    Fk_IdCuentaContableAutorizado, Fk_IdCuentaContablePorEjercer, Fk_IdCuentaContableModificado,
    Fk_IdCuentaContableDevengado, Fk_IdCuentaContableRecaudado, Fk_IdCuentaContableDeposito,
    FK_IdAnio__SIS, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()),1
FROM BD_PRESUPUESTO.CONTA.MatrizIngreso
WHERE NOT EXISTS (SELECT 1 FROM CONTA.MatrizIngreso WHERE Pk_IdMatrizIngreso = Pk_IdMatrizIngreso);
SET IDENTITY_INSERT CONTA.MatrizIngreso OFF;
GO

PRINT 'Todas las tablas solicitadas y sus dependencias han sido creadas y migradas exitosamente.';