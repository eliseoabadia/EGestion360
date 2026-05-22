-- =============================================
-- Script: GP.Sql
-- Description: Full database schema for GestionEmpresarial
-- =============================================

USE [GestionEmpresarial];

GO

-- =============================================
-- ESQUEMAS
-- =============================================
IF SCHEMA_ID(N'SIS') IS NULL EXEC(N'CREATE SCHEMA SIS;');

GO

IF SCHEMA_ID(N'NOM') IS NULL EXEC(N'CREATE SCHEMA NOM;');

GO

IF SCHEMA_ID(N'ALMA') IS NULL EXEC(N'CREATE SCHEMA ALMA;');

GO

IF SCHEMA_ID(N'CONTA') IS NULL EXEC(N'CREATE SCHEMA CONTA;');

GO

IF SCHEMA_ID(N'ORCO') IS NULL EXEC(N'CREATE SCHEMA ORCO;');

GO

IF SCHEMA_ID(N'PRES') IS NULL EXEC(N'CREATE SCHEMA PRES;');

GO

IF SCHEMA_ID(N'TES') IS NULL EXEC(N'CREATE SCHEMA TES;');

GO

-- =============================================
-- TIPO DE DATO PERSONALIZADO
-- =============================================
IF TYPE_ID(N'dbo.dmoney') IS NULL EXEC(N'CREATE TYPE [dbo].[dmoney] FROM [decimal](20, 4) NULL;');

GO

-- =============================================
-- TABLAS SIN DEPENDENCIAS DE FK (FASE 1)
-- =============================================

-- dbo.AspNetRoles
IF OBJECT_ID(N'dbo.AspNetRoles', N'U') IS NULL
BEGIN
CREATE TABLE dbo.AspNetRoles (
    Id NVARCHAR(128) NOT NULL,
    Name NVARCHAR(256) NOT NULL,
    Code NVARCHAR(10),
    CONSTRAINT CONSTRAINT_PK_AspNetRoles PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT CONSTRAINT_UX_AspNetRoles_Name UNIQUE NONCLUSTERED (Name)
);

END
GO

-- dbo.AspNetClaimTypes
IF OBJECT_ID(N'dbo.AspNetClaimTypes', N'U') IS NULL
BEGIN
CREATE TABLE dbo.AspNetClaimTypes (
    Id INT IDENTITY(1,1) NOT NULL,
    Name NVARCHAR(50) NOT NULL,
    Created DATETIME NOT NULL,
    CONSTRAINT CONSTRAINT_PK_AspNetClaimTypes PRIMARY KEY CLUSTERED (Id)
);

END
GO

-- SIS.Idioma
IF OBJECT_ID(N'SIS.Idioma', N'U') IS NULL
BEGIN
CREATE TABLE SIS.Idioma (
    PKIdIdioma INT IDENTITY(1,1) NOT NULL,
    Nombre NVARCHAR(50) NOT NULL,
    CodigoISO639_1 CHAR(2) NOT NULL,
    NombreNativo NVARCHAR(50) NULL,
    Activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_Idioma PRIMARY KEY CLUSTERED (PKIdIdioma),
    CONSTRAINT UQ_Idioma_Codigo UNIQUE (CodigoISO639_1)
);

END
GO

-- SIS.Moneda
IF OBJECT_ID(N'SIS.Moneda', N'U') IS NULL
BEGIN
CREATE TABLE SIS.Moneda (
    PKIdMoneda INT IDENTITY(1,1) NOT NULL,
    Nombre NVARCHAR(50) NOT NULL,
    CodigoISO4217 CHAR(3) NOT NULL,
    Simbolo NVARCHAR(5) NOT NULL,
    Decimales INT NOT NULL DEFAULT 2,
    Activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_Moneda PRIMARY KEY CLUSTERED (PKIdMoneda),
    CONSTRAINT UQ_Moneda_Codigo UNIQUE (CodigoISO4217)
);

END
GO

-- SIS.CatTipoSucursal
IF OBJECT_ID(N'SIS.CatTipoSucursal', N'U') IS NULL
BEGIN
CREATE TABLE SIS.CatTipoSucursal (
    PKIdTipoSucursal INT IDENTITY(1,1) NOT NULL,
    Descripcion NVARCHAR(50) NOT NULL,
    Activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_TipoSucursal PRIMARY KEY CLUSTERED (PKIdTipoSucursal),
    CONSTRAINT UQ_TipoSucursal_Descripcion UNIQUE (Descripcion)
);

END
GO

-- SIS.OrigenLogMessage
IF OBJECT_ID(N'SIS.OrigenLogMessage', N'U') IS NULL
BEGIN
CREATE TABLE SIS.OrigenLogMessage (
    PKIdOrigenLogMessage INT NOT NULL,
    Descripcion NVARCHAR(50) NULL,
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT CONSTRAINT_PK_OrigenLogMessage PRIMARY KEY CLUSTERED (PKIdOrigenLogMessage)
);

END
GO

-- SIS.SystemParamCatalog
IF OBJECT_ID(N'SIS.SystemParamCatalog', N'U') IS NULL
BEGIN
CREATE TABLE SIS.SystemParamCatalog (
    PKIdSystemParamCatalog INT NOT NULL,
    Code NVARCHAR(50) NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT CONSTRAINT_PK_SystemParamCatalog PRIMARY KEY CLUSTERED (PKIdSystemParamCatalog)
);

END
GO

-- SIS.Paises
IF OBJECT_ID(N'SIS.Paises', N'U') IS NULL
BEGIN
CREATE TABLE SIS.Paises (
    PKIdPais INT IDENTITY(1,1) NOT NULL,
    Nombre VARCHAR(64) NOT NULL,
    CodigoISO2 CHAR(2) NOT NULL,
    CodigoISO3 CHAR(3) NOT NULL,
    FKIdIdiomaPrincipal_SIS INT NULL,
    FKIdMonedaPrincipal_SIS INT NULL,
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT PK_Paises PRIMARY KEY CLUSTERED (PKIdPais),
    CONSTRAINT FK_Paises_Idioma FOREIGN KEY (FKIdIdiomaPrincipal_SIS) REFERENCES SIS.Idioma(PKIdIdioma),
    CONSTRAINT FK_Paises_Moneda FOREIGN KEY (FKIdMonedaPrincipal_SIS) REFERENCES SIS.Moneda(PKIdMoneda),
    CONSTRAINT UQ_Paises_CodigoISO2 UNIQUE (CodigoISO2),
    CONSTRAINT UQ_Paises_CodigoISO3 UNIQUE (CodigoISO3)
);

END
GO

-- SIS.Estados
IF OBJECT_ID(N'SIS.Estados', N'U') IS NULL
BEGIN
CREATE TABLE SIS.Estados (
    PKIdEstado INT IDENTITY(1,1) NOT NULL,
    FKIdPais_SIS INT NOT NULL,
    Nombre VARCHAR(64) NOT NULL,
    CodigoEstado VARCHAR(10) NULL,
    Activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_Estados PRIMARY KEY CLUSTERED (PKIdEstado),
    CONSTRAINT FK_Estados_Paises FOREIGN KEY (FKIdPais_SIS) REFERENCES SIS.Paises(PKIdPais),
    CONSTRAINT UQ_Estados_Pais_Nombre UNIQUE (FKIdPais_SIS, Nombre)
);

END
GO

-- SIS.Municipios
IF OBJECT_ID(N'SIS.Municipios', N'U') IS NULL
BEGIN
CREATE TABLE SIS.Municipios (
    PKIdMunicipio INT IDENTITY(1,1) NOT NULL,
    FKIdEstado_SIS INT NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    CodigoMunicipio VARCHAR(10) NULL,
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT PK_Municipios PRIMARY KEY CLUSTERED (PKIdMunicipio),
    CONSTRAINT FK_Municipios_Estados FOREIGN KEY (FKIdEstado_SIS) REFERENCES SIS.Estados(PKIdEstado)
);

END
GO

-- SIS.Empresa
IF OBJECT_ID(N'SIS.Empresa', N'U') IS NULL
BEGIN
CREATE TABLE SIS.Empresa (
    PKIdEmpresa INT IDENTITY(1,1) NOT NULL,
    Nombre NVARCHAR(128) NOT NULL,
    RFC NVARCHAR(13) NOT NULL,
    RazonSocial NVARCHAR(255) NULL,
    Giro NVARCHAR(100) NULL,
    FKIdMonedaBase_SIS INT NOT NULL,
    FKIdIdiomaPreferido_SIS INT NULL,
    Logo VARBINARY(MAX) NULL,
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Empresa PRIMARY KEY CLUSTERED (PKIdEmpresa),
    --CONSTRAINT FK_Empresa_Moneda FOREIGN KEY (FKIdMonedaBase_SIS) REFERENCES SIS.Moneda(PKIdMoneda),
    --CONSTRAINT FK_Empresa_Idioma FOREIGN KEY (FKIdIdiomaPreferido_SIS) REFERENCES SIS.Idioma(PKIdIdioma),
    CONSTRAINT UQ_Empresa_RFC UNIQUE (RFC)
);

END
GO

-- =============================================
-- NOM.Persona (nueva definicion)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Persona' AND schema_id = SCHEMA_ID('NOM'))
BEGIN
    CREATE TABLE NOM.Persona (
        PKIdPersona INT IDENTITY(1,1) NOT NULL,
        Clave NVARCHAR(15) NOT NULL,
        Iniciales NVARCHAR(3) NULL,
        Nombre NVARCHAR(50) NOT NULL,
        Paterno NVARCHAR(50) NOT NULL,
        Materno NVARCHAR(50) NOT NULL,
        Sexo NVARCHAR(10) NULL,
        FechaNacimiento DATETIME NOT NULL,
        ESTADO_CIVIL NVARCHAR(20) NULL,
        RFC NVARCHAR(15) NOT NULL,
        Curp NVARCHAR(18) NOT NULL,
        REG_IMSS NVARCHAR(12) NULL,
        NoCartilla NVARCHAR(16) NULL,
        NoLicencia NVARCHAR(16) NULL,
        NoPasaporte NVARCHAR(16) NULL,
        NoCredencialElector NVARCHAR(32) NULL,
        Gafete NVARCHAR(11) NULL,
        CORREO_ELECTRONICO NVARCHAR(250) NULL,
        Telefono_particular NVARCHAR(15) NULL,
        Telefono_movil NVARCHAR(15) NULL,
        Calle NVARCHAR(40) NULL,
        Num_exterior NVARCHAR(10) NULL,
        Num_interior NVARCHAR(10) NULL,
        Colonia NVARCHAR(40) NULL,
        CP NVARCHAR(6) NULL,
        Municipio NVARCHAR(20) NULL,
        Estado NVARCHAR(30) NULL,
        Fecha_de_Inicio DATETIME NOT NULL,
        Fecha_Fin DATETIME NULL,
        TIPO_CONTRATACION NVARCHAR(50) NULL,
        PUESTO NVARCHAR(100) NULL,
        SUELDO_BASE FLOAT NULL,
        COMPENSACION_GARANTIZADA FLOAT NULL,
        BANCO NVARCHAR(100) NULL,
        NUMERO_CUENTA NVARCHAR(25) NULL,
        CLABE NVARCHAR(50) NULL,
        Activo BIT NOT NULL DEFAULT 1,
        FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
        UsuarioCreacion INT NOT NULL,
        FechaModificacion DATETIME2 NULL,
        UsuarioModificacion INT NULL,
        CONSTRAINT PK_Persona PRIMARY KEY (PKIdPersona)
    );
END

GO

-- =============================================
-- SIS.Usuario (nueva definicion)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Usuario' AND schema_id = SCHEMA_ID('SIS'))
BEGIN
    CREATE TABLE SIS.Usuario (
        PkIdUsuario INT IDENTITY(1,1) NOT NULL,
        FKIdEmpresa_SIS INT NULL,
        FKIdPersona_NOM INT NULL,
        AspNetUserId NVARCHAR(450) NOT NULL,
        PayrollID NVARCHAR(20) NOT NULL,
        FKIdIdiomaPreferido_SIS INT NULL,
        FKIdMonedaPreferida_SIS INT NULL,
        EsAdministrador BIT NOT NULL DEFAULT 0,
        Activo BIT NOT NULL DEFAULT 1,
        FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
        UsuarioCreacion INT NULL,
        FechaModificacion DATETIME2 NULL,
        UsuarioModificacion INT NULL,
        CONSTRAINT PK_Usuario PRIMARY KEY (PkIdUsuario),
        CONSTRAINT FK_Usuario_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
        CONSTRAINT FK_Usuario_Idioma FOREIGN KEY (FKIdIdiomaPreferido_SIS) REFERENCES SIS.Idioma(PKIdIdioma),
        CONSTRAINT FK_Usuario_Moneda FOREIGN KEY (FKIdMonedaPreferida_SIS) REFERENCES SIS.Moneda(PKIdMoneda),
        CONSTRAINT UQ_Usuario_AspNetUserId UNIQUE (AspNetUserId),
        CONSTRAINT UQ_Usuario_PayrollID UNIQUE (PayrollID)
    );
END

GO

-- FK en Persona hacia Usuario
IF OBJECT_ID(N'NOM.FK_Persona_UsuarioCreacion', N'F') IS NULL
    ALTER TABLE NOM.Persona ADD CONSTRAINT FK_Persona_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario);

IF OBJECT_ID(N'NOM.FK_Persona_UsuarioModificacion', N'F') IS NULL
    ALTER TABLE NOM.Persona ADD CONSTRAINT FK_Persona_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario);

GO

-- FK en Usuario hacia Persona
IF OBJECT_ID(N'SIS.FK_Usuario_Persona', N'F') IS NULL
    ALTER TABLE SIS.Usuario ADD CONSTRAINT FK_Usuario_Persona FOREIGN KEY (FKIdPersona_NOM) REFERENCES NOM.Persona(PKIdPersona);

GO

-- SIS.Anio
IF OBJECT_ID(N'SIS.Anio', N'U') IS NULL
BEGIN
CREATE TABLE SIS.Anio (
    PKIdAnio INT IDENTITY(1,1) NOT NULL,
    Clave INT NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Anio_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Anio_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Anio PRIMARY KEY (PKIdAnio),
    CONSTRAINT FK_Anio_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Anio_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- SIS.ActividadInstitucional
IF OBJECT_ID(N'SIS.ActividadInstitucional', N'U') IS NULL
BEGIN
CREATE TABLE SIS.ActividadInstitucional (
    PKIdActividadInstitucional INT IDENTITY(1,1) NOT NULL,
    Clave NVARCHAR(3) NOT NULL,
    Descripcion NVARCHAR(64) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_ActividadInstitucional_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_ActividadInstitucional_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_ActividadInstitucional PRIMARY KEY (PKIdActividadInstitucional),
    CONSTRAINT FK_ActividadInstitucional_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_ActividadInstitucional_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- SIS.Capitulo
IF OBJECT_ID(N'SIS.Capitulo', N'U') IS NULL
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

-- SIS.Concepto
IF OBJECT_ID(N'SIS.Concepto', N'U') IS NULL
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

-- SIS.Partida
IF OBJECT_ID(N'SIS.Partida', N'U') IS NULL
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

-- SIS.TipoPoliza
IF OBJECT_ID(N'SIS.TipoPoliza', N'U') IS NULL
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

-- SIS.TipoDetallePoliza
IF OBJECT_ID(N'SIS.TipoDetallePoliza', N'U') IS NULL
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

-- SIS.TipoProveedor
IF OBJECT_ID(N'SIS.TipoProveedor', N'U') IS NULL
BEGIN
CREATE TABLE SIS.TipoProveedor (
    PkIdTipoProveedor INT IDENTITY(1,1) NOT NULL,
    Descripcion VARCHAR(80) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_TipoProveedor_Activo DEFAULT (1),
    FechaCreacion DATETIME CONSTRAINT DF_TipoProveedor_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_TipoProveedor PRIMARY KEY (PkIdTipoProveedor),
    CONSTRAINT FK_TipoProveedor_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_TipoProveedor_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- SIS.EstatusProveedor
IF OBJECT_ID(N'SIS.EstatusProveedor', N'U') IS NULL
BEGIN
CREATE TABLE SIS.EstatusProveedor (
    PKIdEstatusProveedor INT IDENTITY(1,1) NOT NULL,
    Descripcion NVARCHAR(150) NOT NULL,
    Color NVARCHAR(8) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_EstatusProveedor_Activo DEFAULT (1),
    FechaCreacion DATETIME CONSTRAINT DF_EstatusProveedor_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_EstatusProveedor PRIMARY KEY (PKIdEstatusProveedor),
    CONSTRAINT FK_EstatusProveedor_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_EstatusProveedor_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- SIS.TipoDoctoCLC
IF OBJECT_ID(N'SIS.TipoDoctoCLC', N'U') IS NULL
BEGIN
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

END
GO

-- CONTA.TipoCuenta
IF OBJECT_ID(N'CONTA.TipoCuenta', N'U') IS NULL
BEGIN
CREATE TABLE CONTA.TipoCuenta (
    PKIdTipoCuenta INT IDENTITY(1,1) NOT NULL,
    Color NVARCHAR(5) NOT NULL,
    Descripcion NVARCHAR(25) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_TipoCuenta_Activo DEFAULT (1),
    FechaCreacion DATETIME CONSTRAINT DF_TipoCuenta_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_TipoCuenta PRIMARY KEY CLUSTERED (PKIdTipoCuenta),
    CONSTRAINT FK_TipoCuenta_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_TipoCuenta_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- CONTA.TipoDoctoPago
IF OBJECT_ID(N'CONTA.TipoDoctoPago', N'U') IS NULL
BEGIN
CREATE TABLE CONTA.TipoDoctoPago (
    PKIdTipoDoctoPago INT IDENTITY(1,1) NOT NULL,
    Descripcion NVARCHAR(50) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_TipoDoctoPago_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_TipoDoctoPago_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_TipoDoctoPago PRIMARY KEY (PKIdTipoDoctoPago),
    CONSTRAINT FK_TipoDoctoPago_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_TipoDoctoPago_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- CONTA.Capitulo
IF OBJECT_ID(N'CONTA.Capitulo', N'U') IS NULL
BEGIN
CREATE TABLE CONTA.Capitulo (
    PKIdCapitulo INT IDENTITY(1,1) NOT NULL,
    Clave NVARCHAR(30) NULL,
    Descripcion NVARCHAR(120) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Capitulo_Activo DEFAULT (1),
    FechaCreacion DATETIME CONSTRAINT DF_Capitulo_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Capitulo PRIMARY KEY (PKIdCapitulo),
    CONSTRAINT FK_Capitulo_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Capitulo_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- CONTA.Concepto
IF OBJECT_ID(N'CONTA.Concepto', N'U') IS NULL
BEGIN
CREATE TABLE CONTA.Concepto (
    PKIdConcepto INT IDENTITY(1,1) NOT NULL,
    FKIdCapitulo_CONTA INT NOT NULL,
    Clave NVARCHAR(30) NULL,
    Descripcion NVARCHAR(120) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Concepto_Activo DEFAULT (1),
    FechaCreacion DATETIME CONSTRAINT DF_Concepto_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Concepto PRIMARY KEY (PKIdConcepto),
    CONSTRAINT FK_Concepto_Capitulo FOREIGN KEY (FKIdCapitulo_CONTA) REFERENCES CONTA.Capitulo(PKIdCapitulo),
    CONSTRAINT FK_Concepto_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Concepto_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- CONTA.Partida
IF OBJECT_ID(N'CONTA.Partida', N'U') IS NULL
BEGIN
CREATE TABLE CONTA.Partida (
    PKIdPartida INT IDENTITY(1,1) NOT NULL,
    FKIdConcepto_SIS INT NULL,
    Clave NVARCHAR(10) NOT NULL,
    Descripcion NVARCHAR(255) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Partida_Activo DEFAULT (1),
    FechaCreacion DATETIME CONSTRAINT DF_Partida_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Partida PRIMARY KEY (PKIdPartida),
    CONSTRAINT FK_Partida_Concepto FOREIGN KEY (FKIdConcepto_SIS) REFERENCES CONTA.Concepto(PKIdConcepto),
    CONSTRAINT FK_Partida_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Partida_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.GF
IF OBJECT_ID(N'PRES.GF', N'U') IS NULL
BEGIN
CREATE TABLE PRES.GF (
    PKIdGF INT IDENTITY(1,1) NOT NULL,
    Clave INT NOT NULL,
    Descripcion NVARCHAR(30) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_GF_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_GF_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_GF PRIMARY KEY (PKIdGF),
    CONSTRAINT FK_GF_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_GF_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.FN
IF OBJECT_ID(N'PRES.FN', N'U') IS NULL
BEGIN
CREATE TABLE PRES.FN (
    PKIdFN INT IDENTITY(1,1) NOT NULL,
    FKIdGF_PRES INT NOT NULL,
    Clave INT NOT NULL,
    Descripcion NVARCHAR(50) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_FN_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_FN_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_FN PRIMARY KEY (PKIdFN),
    CONSTRAINT FK_FN_GF FOREIGN KEY (FKIdGF_PRES) REFERENCES PRES.GF(PKIdGF),
    CONSTRAINT FK_FN_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_FN_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.SF
IF OBJECT_ID(N'PRES.SF', N'U') IS NULL
BEGIN
CREATE TABLE PRES.SF (
    PKIdSF INT IDENTITY(1,1) NOT NULL,
    FKIdFN_PRES INT NOT NULL,
    Clave INT NOT NULL,
    Descripcion NVARCHAR(50) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_SF_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_SF_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_SF PRIMARY KEY (PKIdSF),
    CONSTRAINT FK_SF_FN FOREIGN KEY (FKIdFN_PRES) REFERENCES PRES.FN(PKIdFN),
    CONSTRAINT FK_SF_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_SF_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.PP
IF OBJECT_ID(N'PRES.PP', N'U') IS NULL
BEGIN
CREATE TABLE PRES.PP (
    PKIdPP INT IDENTITY(1,1) NOT NULL,
    Clave NVARCHAR(4) NOT NULL,
    Descripcion NVARCHAR(150) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_PP_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_PP_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_PP PRIMARY KEY (PKIdPP),
    CONSTRAINT FK_PP_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_PP_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.TipoRecurso
IF OBJECT_ID(N'PRES.TipoRecurso', N'U') IS NULL
BEGIN
CREATE TABLE PRES.TipoRecurso (
    PKIdTipoRecurso INT IDENTITY(1,1) NOT NULL,
    Clave NVARCHAR(1) NOT NULL,
    Descripcion NVARCHAR(200) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_TipoRecurso_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_TipoRecurso_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_TipoRecurso PRIMARY KEY (PKIdTipoRecurso),
    CONSTRAINT FK_TipoRecurso_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_TipoRecurso_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.Sector
IF OBJECT_ID(N'PRES.Sector', N'U') IS NULL
BEGIN
CREATE TABLE PRES.Sector (
    PKIdSector INT IDENTITY(1,1) NOT NULL,
    Clave NVARCHAR(2) NOT NULL,
    Descripcion NVARCHAR(200) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Sector_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Sector_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Sector PRIMARY KEY (PKIdSector),
    CONSTRAINT FK_Sector_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Sector_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.GrupoPresupuesto
IF OBJECT_ID(N'PRES.GrupoPresupuesto', N'U') IS NULL
BEGIN
CREATE TABLE PRES.GrupoPresupuesto (
    PKIdGrupoPresupuesto INT IDENTITY(1,1) NOT NULL,
    Clave INT NOT NULL,
    Descripcion NVARCHAR(50) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_GrupoPresupuesto_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_GrupoPresupuesto_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_GrupoPresupuesto PRIMARY KEY (PKIdGrupoPresupuesto),
    CONSTRAINT FK_GrupoPresupuesto_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_GrupoPresupuesto_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.UR
IF OBJECT_ID(N'PRES.UR', N'U') IS NULL
BEGIN
CREATE TABLE PRES.UR (
    PKIdUR INT IDENTITY(1,1) NOT NULL,
    FKIdGrupoPresupuesto_PRES INT NOT NULL,
    Clave NVARCHAR(10) NULL,
    Descripcion NVARCHAR(50) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_UR_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_UR_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_UR PRIMARY KEY (PKIdUR),
    CONSTRAINT FK_UR_GrupoPresupuesto FOREIGN KEY (FKIdGrupoPresupuesto_PRES) REFERENCES PRES.GrupoPresupuesto(PKIdGrupoPresupuesto),
    CONSTRAINT FK_UR_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_UR_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.Eje
IF OBJECT_ID(N'PRES.Eje', N'U') IS NULL
BEGIN
CREATE TABLE PRES.Eje (
    PKIdEje INT IDENTITY(1,1) NOT NULL,
    Clave NVARCHAR(1) NOT NULL,
    Descripcion NVARCHAR(200) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Eje_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Eje_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Eje PRIMARY KEY (PKIdEje),
    CONSTRAINT FK_Eje_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Eje_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.SubEje
IF OBJECT_ID(N'PRES.SubEje', N'U') IS NULL
BEGIN
CREATE TABLE PRES.SubEje (
    PKIdSubEje INT IDENTITY(1,1) NOT NULL,
    FKIdEje_PRES INT NOT NULL,
    Clave NVARCHAR(2) NOT NULL,
    Descripcion NVARCHAR(200) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_SubEje_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_SubEje_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_SubEje PRIMARY KEY (PKIdSubEje),
    CONSTRAINT FK_SubEje_Eje FOREIGN KEY (FKIdEje_PRES) REFERENCES PRES.Eje(PKIdEje),
    CONSTRAINT FK_SubEje_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_SubEje_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.SubSubEje
IF OBJECT_ID(N'PRES.SubSubEje', N'U') IS NULL
BEGIN
CREATE TABLE PRES.SubSubEje (
    PKIdSubSubEje INT IDENTITY(1,1) NOT NULL,
    FKIdSubEje_PRES INT NOT NULL,
    Clave NVARCHAR(2) NOT NULL,
    Descripcion NVARCHAR(200) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_SubSubEje_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_SubSubEje_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_SubSubEje PRIMARY KEY (PKIdSubSubEje),
    CONSTRAINT FK_SubSubEje_SubEje FOREIGN KEY (FKIdSubEje_PRES) REFERENCES PRES.SubEje(PKIdSubEje),
    CONSTRAINT FK_SubSubEje_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_SubSubEje_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.Finalidad
IF OBJECT_ID(N'PRES.Finalidad', N'U') IS NULL
BEGIN
CREATE TABLE PRES.Finalidad (
    PKIdFinalidad INT IDENTITY(1,1) NOT NULL,
    Clave NVARCHAR(2) NOT NULL,
    Descripcion NVARCHAR(200) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Finalidad_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Finalidad_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Finalidad PRIMARY KEY (PKIdFinalidad),
    CONSTRAINT FK_Finalidad_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Finalidad_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.VertienteGasto
IF OBJECT_ID(N'PRES.VertienteGasto', N'U') IS NULL
BEGIN
CREATE TABLE PRES.VertienteGasto (
    PKIdVertienteGasto INT IDENTITY(1,1) NOT NULL,
    Clave NVARCHAR(2) NOT NULL,
    Descripcion NVARCHAR(200) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_VertienteGasto_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_VertienteGasto_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_VertienteGasto PRIMARY KEY (PKIdVertienteGasto),
    CONSTRAINT FK_VertienteGasto_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_VertienteGasto_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.Resultado
IF OBJECT_ID(N'PRES.Resultado', N'U') IS NULL
BEGIN
CREATE TABLE PRES.Resultado (
    PKIdResultado INT IDENTITY(1,1) NOT NULL,
    Clave NVARCHAR(2) NOT NULL,
    Descripcion NVARCHAR(200) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Resultado_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Resultado_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Resultado PRIMARY KEY (PKIdResultado),
    CONSTRAINT FK_Resultado_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Resultado_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.Subresultado
IF OBJECT_ID(N'PRES.Subresultado', N'U') IS NULL
BEGIN
CREATE TABLE PRES.Subresultado (
    PKIdSubresultado INT IDENTITY(1,1) NOT NULL,
    Clave NVARCHAR(2) NOT NULL,
    Descripcion NVARCHAR(200) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Subresultado_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Subresultado_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Subresultado PRIMARY KEY (PKIdSubresultado),
    CONSTRAINT FK_Subresultado_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Subresultado_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.SubSector
IF OBJECT_ID(N'PRES.SubSector', N'U') IS NULL
BEGIN
CREATE TABLE PRES.SubSector (
    PKIdSubSector INT IDENTITY(1,1) NOT NULL,
    Clave NVARCHAR(2) NOT NULL,
    Descripcion NVARCHAR(200) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_SubSector_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_SubSector_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_SubSector PRIMARY KEY (PKIdSubSector),
    CONSTRAINT FK_SubSector_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_SubSector_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.FuenteFinanciamiento
IF OBJECT_ID(N'PRES.FuenteFinanciamiento', N'U') IS NULL
BEGIN
CREATE TABLE PRES.FuenteFinanciamiento (
    PKIdFuenteFinanciamiento INT IDENTITY(1,1) NOT NULL,
    Clave NVARCHAR(6) NULL,
    Descripcion NVARCHAR(200) NOT NULL,
    FKIdAnio_SIS INT NULL,
    FF NVARCHAR(2) NULL,
    FG NVARCHAR(1) NULL,
    FE NVARCHAR(1) NULL,
    AD NVARCHAR(1) NULL,
    ORI NVARCHAR(1) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_FuenteFinanciamiento_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_FuenteFinanciamiento_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_FuenteFinanciamiento PRIMARY KEY (PKIdFuenteFinanciamiento),
    CONSTRAINT FK_FuenteFinanciamiento_Anio FOREIGN KEY (FKIdAnio_SIS) REFERENCES SIS.Anio(PKIdAnio),
    CONSTRAINT FK_FuenteFinanciamiento_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_FuenteFinanciamiento_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.Ramo
IF OBJECT_ID(N'PRES.Ramo', N'U') IS NULL
BEGIN
CREATE TABLE PRES.Ramo (
    PKIdRamo INT IDENTITY(1,1) NOT NULL,
    Clave INT NOT NULL,
    Descripcion NVARCHAR(1000) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Ramo_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Ramo_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Ramo PRIMARY KEY (PKIdRamo),
    CONSTRAINT FK_Ramo_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Ramo_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.PG
IF OBJECT_ID(N'PRES.PG', N'U') IS NULL
BEGIN
CREATE TABLE PRES.PG (
    PKIdPG INT IDENTITY(1,1) NOT NULL,
    Clave INT NOT NULL,
    Descripcion NVARCHAR(1000) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_PG_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_PG_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_PG PRIMARY KEY (PKIdPG),
    CONSTRAINT FK_PG_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_PG_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.Programa
IF OBJECT_ID(N'PRES.Programa', N'U') IS NULL
BEGIN
CREATE TABLE PRES.Programa (
    PKIdPrograma INT IDENTITY(1,1) NOT NULL,
    FKIdUR_PRES INT NOT NULL,
    FKIdGF_PRES INT NOT NULL,
    FKIdFN_PRES INT NOT NULL,
    FKIdSF_PRES INT NOT NULL,
    FKIdActividadInstitucional_SIS INT NOT NULL,
    FKIdEje_PRES INT NULL,
    FKIdVertienteGasto_PRES INT NULL,
    FKIdResultado_PRES INT NULL,
    FKIdSubresultado_PRES INT NULL,
    FKIdAnio_SIS INT NULL,
    FKIdSector_PRES INT NULL,
    FKIdSubSector_PRES INT NULL,
    FKIdTipoRecurso_PRES INT NULL,
    FKIdFuenteFinanciamiento_PRES INT NULL,
    Clave NVARCHAR(50) NOT NULL,
    Objetivo NVARCHAR(500) NULL,
    Descripcion NVARCHAR(50) NULL,
    FKIdSubEje_PRES INT NULL,
    FKIdSubSubEje_PRES INT NULL,
    FKIdFinalidad_PRES INT NULL,
    FKIdPP_PRES INT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Programa_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Programa_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Programa PRIMARY KEY (PKIdPrograma),
    CONSTRAINT FK_Programa_UR FOREIGN KEY (FKIdUR_PRES) REFERENCES PRES.UR(PKIdUR),
    CONSTRAINT FK_Programa_GF FOREIGN KEY (FKIdGF_PRES) REFERENCES PRES.GF(PKIdGF),
    CONSTRAINT FK_Programa_FN FOREIGN KEY (FKIdFN_PRES) REFERENCES PRES.FN(PKIdFN),
    CONSTRAINT FK_Programa_SF FOREIGN KEY (FKIdSF_PRES) REFERENCES PRES.SF(PKIdSF),
    CONSTRAINT FK_Programa_ActividadInstitucional FOREIGN KEY (FKIdActividadInstitucional_SIS) REFERENCES SIS.ActividadInstitucional(PKIdActividadInstitucional),
    CONSTRAINT FK_Programa_Eje FOREIGN KEY (FKIdEje_PRES) REFERENCES PRES.Eje(PKIdEje),
    CONSTRAINT FK_Programa_VertienteGasto FOREIGN KEY (FKIdVertienteGasto_PRES) REFERENCES PRES.VertienteGasto(PKIdVertienteGasto),
    CONSTRAINT FK_Programa_Resultado FOREIGN KEY (FKIdResultado_PRES) REFERENCES PRES.Resultado(PKIdResultado),
    CONSTRAINT FK_Programa_Subresultado FOREIGN KEY (FKIdSubresultado_PRES) REFERENCES PRES.Subresultado(PKIdSubresultado),
    CONSTRAINT FK_Programa_Anio FOREIGN KEY (FKIdAnio_SIS) REFERENCES SIS.Anio(PKIdAnio),
    CONSTRAINT FK_Programa_Sector FOREIGN KEY (FKIdSector_PRES) REFERENCES PRES.Sector(PKIdSector),
    CONSTRAINT FK_Programa_SubSector FOREIGN KEY (FKIdSubSector_PRES) REFERENCES PRES.SubSector(PKIdSubSector),
    CONSTRAINT FK_Programa_TipoRecurso FOREIGN KEY (FKIdTipoRecurso_PRES) REFERENCES PRES.TipoRecurso(PKIdTipoRecurso),
    CONSTRAINT FK_Programa_FuenteFinanciamiento FOREIGN KEY (FKIdFuenteFinanciamiento_PRES) REFERENCES PRES.FuenteFinanciamiento(PKIdFuenteFinanciamiento),
    CONSTRAINT FK_Programa_SubEje FOREIGN KEY (FKIdSubEje_PRES) REFERENCES PRES.SubEje(PKIdSubEje),
    CONSTRAINT FK_Programa_SubSubEje FOREIGN KEY (FKIdSubSubEje_PRES) REFERENCES PRES.SubSubEje(PKIdSubSubEje),
    CONSTRAINT FK_Programa_Finalidad FOREIGN KEY (FKIdFinalidad_PRES) REFERENCES PRES.Finalidad(PKIdFinalidad),
    CONSTRAINT FK_Programa_PP FOREIGN KEY (FKIdPP_PRES) REFERENCES PRES.PP(PKIdPP),
    CONSTRAINT FK_Programa_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Programa_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.Origen
IF OBJECT_ID(N'PRES.Origen', N'U') IS NULL
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

-- PRES.TipoGasto
IF OBJECT_ID(N'PRES.TipoGasto', N'U') IS NULL
BEGIN
CREATE TABLE PRES.TipoGasto (
    PKIdTipoGasto INT IDENTITY(1,1) NOT NULL,
    Clave INT NOT NULL,
    Descripcion NVARCHAR(200) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_TipoGasto_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_TipoGasto_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_TipoGasto PRIMARY KEY (PKIdTipoGasto),
    CONSTRAINT FK_TipoGasto_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_TipoGasto_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.DigitoIdentificador
IF OBJECT_ID(N'PRES.DigitoIdentificador', N'U') IS NULL
BEGIN
CREATE TABLE PRES.DigitoIdentificador (
    PKIdDigitoIdentificador INT IDENTITY(1,1) NOT NULL,
    Clave NVARCHAR(1) NOT NULL,
    Descripcion NVARCHAR(200) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_DigitoIdentificador_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_DigitoIdentificador_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_DigitoIdentificador PRIMARY KEY (PKIdDigitoIdentificador),
    CONSTRAINT FK_DigitoIdentificador_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_DigitoIdentificador_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.DestinoGasto
IF OBJECT_ID(N'PRES.DestinoGasto', N'U') IS NULL
BEGIN
CREATE TABLE PRES.DestinoGasto (
    PKIdDestinoGasto INT IDENTITY(1,1) NOT NULL,
    Clave NVARCHAR(2) NOT NULL,
    Descripcion NVARCHAR(250) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_DestinoGasto_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_DestinoGasto_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_DestinoGasto PRIMARY KEY (PKIdDestinoGasto),
    CONSTRAINT FK_DestinoGasto_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_DestinoGasto_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.Suficiencia
IF OBJECT_ID(N'PRES.Suficiencia', N'U') IS NULL
BEGIN
CREATE TABLE PRES.Suficiencia (
    PKIdSuficiencia INT IDENTITY(1,1) NOT NULL,
    Descripcion NVARCHAR(50) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Suficiencia_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Suficiencia_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Suficiencia PRIMARY KEY (PKIdSuficiencia),
    CONSTRAINT FK_Suficiencia_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Suficiencia_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.PY
IF OBJECT_ID(N'PRES.PY', N'U') IS NULL
BEGIN
CREATE TABLE PRES.PY (
    PKIdPY INT IDENTITY(1,1) NOT NULL,
    Clave VARCHAR(15) NULL,
    Descripcion NVARCHAR(150) NOT NULL,
    NombreProyecto NVARCHAR(500) NULL,
    InicioProyecto DATE NULL,
    FinProyecto DATE NULL,
    Plurianual BIT NULL,
    TieneTICS BIT NULL,
    EsPAT BIT NULL,
    AnexosTransversales BIT NULL,
    ProgramaPresupuestario NVARCHAR(24) NULL,
    ProyectoInversion BIT NULL,
    RecursosAdicionales BIT NULL,
    Prioridad SMALLINT NULL,
    FuenteFinanciamiento NVARCHAR(500) NULL,
    DescripcionProyecto NVARCHAR(500) NULL,
    ResponsableProyecto NVARCHAR(128) NULL,
    ObjetivoProyecto NVARCHAR(500) NULL,
    LineaEstrategica NVARCHAR(500) NULL,
    LineaAccionRegulatoria NVARCHAR(500) NULL,
    TemaAccionRegulatoria NVARCHAR(500) NULL,
    FundamentoLegal NVARCHAR(500) NULL,
    Justificacion NVARCHAR(500) NULL,
    Beneficios NVARCHAR(500) NULL,
    Indicador NVARCHAR(128) NULL,
    Meta NVARCHAR(128) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_PY_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_PY_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_PY PRIMARY KEY (PKIdPY),
    CONSTRAINT FK_PY_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_PY_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- ALMA.Nivel
IF OBJECT_ID(N'ALMA.Nivel', N'U') IS NULL
BEGIN
CREATE TABLE ALMA.Nivel (
    PKIdNivel INT IDENTITY(1,1) NOT NULL,
    Nivel INT NOT NULL,
    Descripcion NVARCHAR(20) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Nivel_Activo DEFAULT (1),
    FechaCreacion DATETIME CONSTRAINT DF_Nivel_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Nivel PRIMARY KEY (PKIdNivel),
    CONSTRAINT FK_Nivel_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Nivel_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- ALMA.Unidades
IF OBJECT_ID(N'ALMA.Unidades', N'U') IS NULL
BEGIN
CREATE TABLE ALMA.Unidades (
    PKIdUnidades INT IDENTITY(1,1) NOT NULL,
    Descripcion NVARCHAR(50) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Unidades_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Unidades_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Unidades PRIMARY KEY (PKIdUnidades),
    CONSTRAINT FK_Unidades_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Unidades_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- ALMA.Familia
IF OBJECT_ID(N'ALMA.Familia', N'U') IS NULL
BEGIN
CREATE TABLE ALMA.Familia (
    PKIdFamilia INT IDENTITY(1,1) NOT NULL,
    Descripcion NVARCHAR(80) NOT NULL,
    Clave NVARCHAR(50) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Familia_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Familia_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Familia PRIMARY KEY (PKIdFamilia),
    CONSTRAINT FK_Familia_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Familia_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- ALMA.GrupoBien
IF OBJECT_ID(N'ALMA.GrupoBien', N'U') IS NULL
BEGIN
CREATE TABLE ALMA.GrupoBien (
    PKIdGrupoBien INT IDENTITY(1,1) NOT NULL,
    FKIdFamilia_ALMA INT NOT NULL,
    Descripcion NVARCHAR(800) NULL,
    Clave INT NULL,
    ClaveAN NVARCHAR(50) NULL,
    CABM_ACT NVARCHAR(50) NULL,
    CLAVE_CUCOP NVARCHAR(50) NULL,
    MEDIDA NVARCHAR(50) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_GrupoBien_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_GrupoBien_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_GrupoBien PRIMARY KEY (PKIdGrupoBien),
    CONSTRAINT FK_GrupoBien_Familia FOREIGN KEY (FKIdFamilia_ALMA) REFERENCES ALMA.Familia(PKIdFamilia),
    CONSTRAINT FK_GrupoBien_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_GrupoBien_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- ALMA.TipoPatrimonio
IF OBJECT_ID(N'ALMA.TipoPatrimonio', N'U') IS NULL
BEGIN
CREATE TABLE ALMA.TipoPatrimonio (
    PKIdTipoPatrimonio INT IDENTITY(1,1) NOT NULL,
    Descripcion NVARCHAR(50) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_TipoPatrimonio_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_TipoPatrimonio_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_TipoPatrimonio PRIMARY KEY (PKIdTipoPatrimonio),
    CONSTRAINT FK_TipoPatrimonio_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_TipoPatrimonio_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- ALMA.Marca
IF OBJECT_ID(N'ALMA.Marca', N'U') IS NULL
BEGIN
CREATE TABLE ALMA.Marca (
    PKIdMarca INT IDENTITY(1,1) NOT NULL,
    Descripcion NVARCHAR(50) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Marca_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Marca_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Marca PRIMARY KEY (PKIdMarca),
    CONSTRAINT FK_Marca_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Marca_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- ALMA.Material
IF OBJECT_ID(N'ALMA.Material', N'U') IS NULL
BEGIN
CREATE TABLE ALMA.Material (
    PKIdMaterial INT IDENTITY(1,1) NOT NULL,
    Descripcion NVARCHAR(50) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Material_Activo DEFAULT (1),
    FechaCreacion DATETIME CONSTRAINT DF_Material_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Material PRIMARY KEY (PKIdMaterial),
    CONSTRAINT FK_Material_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Material_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- ALMA.EstadoBien
IF OBJECT_ID(N'ALMA.EstadoBien', N'U') IS NULL
BEGIN
CREATE TABLE ALMA.EstadoBien (
    PKIdEstadoBien INT IDENTITY(1,1) NOT NULL,
    DESCRIPCION_GENERAL NVARCHAR(150) NOT NULL,
    DESCRIPCION_ESPECIFICA NVARCHAR(200) NOT NULL,
    DESCRIPCION_CORTA NVARCHAR(100) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_EstadoBien_Activo DEFAULT (1),
    FechaCreacion DATETIME CONSTRAINT DF_EstadoBien_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_EstadoBien PRIMARY KEY (PKIdEstadoBien),
    CONSTRAINT FK_EstadoBien_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_EstadoBien_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- ALMA.TipoAdquisicion
IF OBJECT_ID(N'ALMA.TipoAdquisicion', N'U') IS NULL
BEGIN
CREATE TABLE ALMA.TipoAdquisicion (
    PKIdTipoAdq INT IDENTITY(1,1) NOT NULL,
    Clave NVARCHAR(10) NOT NULL,
    Descripcion NVARCHAR(100) NOT NULL,
    Descripmovto NVARCHAR(100) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_TipoAdquisicion_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_TipoAdquisicion_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_TipoAdquisicion PRIMARY KEY (PKIdTipoAdq),
    CONSTRAINT FK_TipoAdquisicion_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_TipoAdquisicion_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- ALMA.EstatusPeriodo
IF OBJECT_ID(N'ALMA.EstatusPeriodo', N'U') IS NULL
BEGIN
CREATE TABLE ALMA.EstatusPeriodo (
    PKIdEstatusPeriodo INT IDENTITY(1,1) NOT NULL,
    Nombre NVARCHAR(30) NOT NULL,
    Descripcion NVARCHAR(100) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_EstatusPeriodo_Activo DEFAULT (1),
    CONSTRAINT PK_EstatusPeriodo PRIMARY KEY (PKIdEstatusPeriodo),
    CONSTRAINT UQ_EstatusPeriodo_Nombre UNIQUE (Nombre)
);

END
GO

-- ALMA.TipoConteo
IF OBJECT_ID(N'ALMA.TipoConteo', N'U') IS NULL
BEGIN
CREATE TABLE ALMA.TipoConteo (
    PKIdTipoConteo INT IDENTITY(1,1) NOT NULL,
    Nombre NVARCHAR(30) NOT NULL,
    Descripcion NVARCHAR(100) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_TipoConteo_Activo DEFAULT (1),
    CONSTRAINT PK_TipoConteo PRIMARY KEY (PKIdTipoConteo)
);

END
GO

-- ALMA.EstatusArticuloConteo
IF OBJECT_ID(N'ALMA.EstatusArticuloConteo', N'U') IS NULL
BEGIN
CREATE TABLE ALMA.EstatusArticuloConteo (
    PKIdEstatusArticulo INT IDENTITY(1,1) NOT NULL,
    Nombre NVARCHAR(30) NOT NULL,
    Descripcion NVARCHAR(100) NULL,
    Orden INT NOT NULL,
    Color NVARCHAR(8) NULL,
    Icono NVARCHAR(30) NULL,
    BadgeTexto NVARCHAR(50) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_EstatusArticuloConteo_Activo DEFAULT (1),
    CONSTRAINT PK_EstatusArticuloConteo PRIMARY KEY (PKIdEstatusArticulo),
    CONSTRAINT UQ_EstatusArticuloConteo_Nombre UNIQUE (Nombre)
);

END
GO

-- ALMA.MotivoES
IF OBJECT_ID(N'ALMA.MotivoES', N'U') IS NULL
BEGIN
CREATE TABLE ALMA.MotivoES (
    PKIdMotivoES INT IDENTITY(1,1) NOT NULL,
    Descripcion NVARCHAR(50) NOT NULL,
    AplicaEntrada BIT NOT NULL,
    AplicaSalida BIT NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_MotivoES_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_MotivoES_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_MotivoES PRIMARY KEY (PKIdMotivoES),
    CONSTRAINT FK_MotivoES_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_MotivoES_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- ALMA.EstatusSolicitud
IF OBJECT_ID(N'ALMA.EstatusSolicitud', N'U') IS NULL
BEGIN
CREATE TABLE ALMA.EstatusSolicitud (
    PKIdEstatusSolicitud INT IDENTITY(1,1) NOT NULL,
    Descripcion NVARCHAR(150) NOT NULL,
    Color NVARCHAR(8) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_EstatusSolicitud_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_EstatusSolicitud_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_EstatusSolicitud PRIMARY KEY (PKIdEstatusSolicitud),
    CONSTRAINT FK_EstatusSolicitud_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_EstatusSolicitud_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- ORCO.Modalidad
IF OBJECT_ID(N'ORCO.Modalidad', N'U') IS NULL
BEGIN
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

END
GO

-- ORCO.TipoContrato
IF OBJECT_ID(N'ORCO.TipoContrato', N'U') IS NULL
BEGIN
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

END
GO

-- ORCO.TipoDocumento
IF OBJECT_ID(N'ORCO.TipoDocumento', N'U') IS NULL
BEGIN
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

END
GO

-- ORCO.TipoGarantia
IF OBJECT_ID(N'ORCO.TipoGarantia', N'U') IS NULL
BEGIN
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

END
GO

-- ORCO.ProcedimientoContratacion
IF OBJECT_ID(N'ORCO.ProcedimientoContratacion', N'U') IS NULL
BEGIN
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

END
GO

-- ORCO.EstatusRequisicion
IF OBJECT_ID(N'ORCO.EstatusRequisicion', N'U') IS NULL
BEGIN
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

END
GO

-- ORCO.Articulo
IF OBJECT_ID(N'ORCO.Articulo', N'U') IS NULL
BEGIN
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

END
GO

-- ORCO.Fraccion
IF OBJECT_ID(N'ORCO.Fraccion', N'U') IS NULL
BEGIN
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

END
GO

-- ORCO.Proyecto
IF OBJECT_ID(N'ORCO.Proyecto', N'U') IS NULL
BEGIN
CREATE TABLE ORCO.Proyecto (
    PKIdProyecto INT IDENTITY(1,1) NOT NULL,
    Descripcion NVARCHAR(MAX) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Proyecto_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Proyecto_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Proyecto PRIMARY KEY (PKIdProyecto),
    CONSTRAINT FK_Proyecto_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Proyecto_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- TES.TipoInversion
IF OBJECT_ID(N'TES.TipoInversion', N'U') IS NULL
BEGIN
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

END
GO

-- TES.TipoPago
IF OBJECT_ID(N'TES.TipoPago', N'U') IS NULL
BEGIN
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

END
GO

-- TES.TipoPagoSF
IF OBJECT_ID(N'TES.TipoPagoSF', N'U') IS NULL
BEGIN
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

END
GO

-- TES.TipoSolicitudCLC
IF OBJECT_ID(N'TES.TipoSolicitudCLC', N'U') IS NULL
BEGIN
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

END
GO

-- =============================================
-- TABLAS CON DEPENDENCIAS DE FK (FASE 2)
-- =============================================

-- SIS.EmpresaEstado
IF OBJECT_ID(N'SIS.EmpresaEstado', N'U') IS NULL
BEGIN
CREATE TABLE SIS.EmpresaEstado (
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdEstado_SIS INT NOT NULL,
    FechaApertura DATE NULL,
    EsOficinaPrincipal BIT NOT NULL DEFAULT 0,
    Activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_EmpresaEstado PRIMARY KEY CLUSTERED (FKIdEmpresa_SIS, FKIdEstado_SIS),
    CONSTRAINT FK_EmpresaEstado_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_EmpresaEstado_Estado FOREIGN KEY (FKIdEstado_SIS) REFERENCES SIS.Estados(PKIdEstado)
);

END
GO

-- SIS.Sucursal
IF OBJECT_ID(N'SIS.Sucursal', N'U') IS NULL
BEGIN
CREATE TABLE SIS.Sucursal (
    PKIdSucursal INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdEstado_SIS INT NOT NULL,
    Nombre NVARCHAR(128) NOT NULL,
    CodigoSucursal NVARCHAR(20) NOT NULL,
    Alias NVARCHAR(50) NULL,
    FKIdTipoSucursal INT NOT NULL DEFAULT 2,
    FKIdMonedaLocal_SIS INT NULL,
    Direccion NVARCHAR(256) NOT NULL,
    Colonia NVARCHAR(100) NULL,
    Ciudad NVARCHAR(100) NULL,
    CodigoPostal NVARCHAR(10) NULL,
    TelefonoPrincipal NVARCHAR(20) NULL,
    TelefonoSecundario NVARCHAR(20) NULL,
    Email NVARCHAR(100) NULL,
    HorarioApertura TIME NULL,
    HorarioCierre TIME NULL,
    EsMatriz BIT NOT NULL DEFAULT 0,
    EsActiva BIT NOT NULL DEFAULT 1,
    Latitud DECIMAL(9,6) NULL,
    Longitud DECIMAL(9,6) NULL,
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Sucursal PRIMARY KEY CLUSTERED (PKIdSucursal),
    CONSTRAINT FK_Sucursal_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_Sucursal_Estado FOREIGN KEY (FKIdEstado_SIS) REFERENCES SIS.Estados(PKIdEstado),
    CONSTRAINT FK_Sucursal_Tipo FOREIGN KEY (FKIdTipoSucursal) REFERENCES SIS.CatTipoSucursal(PKIdTipoSucursal),
    CONSTRAINT FK_Sucursal_Moneda FOREIGN KEY (FKIdMonedaLocal_SIS) REFERENCES SIS.Moneda(PKIdMoneda),
    CONSTRAINT UQ_Sucursal_Codigo UNIQUE (CodigoSucursal)
);

END
GO

-- SIS.Departamento
IF OBJECT_ID(N'SIS.Departamento', N'U') IS NULL
BEGIN
CREATE TABLE SIS.Departamento (
    PKIdDepartamento INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdSucursal_SIS INT NULL,
    Nombre NVARCHAR(128) NOT NULL,
    Descripcion NVARCHAR(255) NULL,
    NivelJerarquico INT DEFAULT 1,
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Departamento PRIMARY KEY CLUSTERED (PKIdDepartamento),
    CONSTRAINT FK_Departamento_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_Departamento_Sucursal FOREIGN KEY (FKIdSucursal_SIS) REFERENCES SIS.Sucursal(PKIdSucursal)
);

END
GO

-- SIS.Area
IF OBJECT_ID(N'SIS.Area', N'U') IS NULL
BEGIN
CREATE TABLE SIS.Area (
    PKIdArea INT IDENTITY(1,1) NOT NULL,
    FKIdArea_SIS INT NULL,
    FKIdAreaDocto_SIS INT NULL,
    Clave NVARCHAR(15) NOT NULL,
    Nombre NVARCHAR(200) NOT NULL,
    UltimoInv DATETIME NULL,
    ZonaEconomica NVARCHAR(100) NULL,
    Direccion NVARCHAR(64) NULL,
    Colonia NVARCHAR(64) NULL,
    CP NVARCHAR(5) NULL,
    Telefono NVARCHAR(32) NULL,
    Aprovado BIT NOT NULL CONSTRAINT DF_Area_Aprovado DEFAULT (0),
    Activo BIT NOT NULL CONSTRAINT DF_Area_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Area_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Area PRIMARY KEY (PKIdArea),
    CONSTRAINT FK_Area_Padre FOREIGN KEY (FKIdArea_SIS) REFERENCES SIS.Area(PKIdArea),
    CONSTRAINT FK_Area_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Area_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- TES.TipoMoneda
IF OBJECT_ID(N'TES.TipoMoneda', N'U') IS NULL
BEGIN
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

END
GO

-- TES.TipoCambio
IF OBJECT_ID(N'TES.TipoCambio', N'U') IS NULL
BEGIN
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

END
GO

-- CONTA.CuentaContable
IF OBJECT_ID(N'CONTA.CuentaContable', N'U') IS NULL
BEGIN
CREATE TABLE CONTA.CuentaContable (
    PKIdCuentaContable INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdTipoCuenta_CONTA INT NOT NULL,
    Cuenta NVARCHAR(5) NOT NULL,
    SubCuenta NVARCHAR(5) NOT NULL,
    SubSubCuenta NVARCHAR(5) NOT NULL,
    SubSubSubCuenta NVARCHAR(5) NOT NULL,
    SubSubSubSubCuenta NVARCHAR(5) NOT NULL,
    Saldo NUMERIC(18,2) NOT NULL,
    Descripcion VARCHAR(250) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_CuentaContable_Activo DEFAULT (1),
    FechaCreacion DATETIME CONSTRAINT DF_CuentaContable_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME NULL,
    UsuarioModificacion INT NULL,
    S5 NVARCHAR(5) NULL,
    S6 NVARCHAR(5) NULL,
    S7 NVARCHAR(5) NULL,
    ClaveOrd VARCHAR(50) NULL,
    Padre VARCHAR(10) NULL,
    Hijo VARCHAR(20) NULL,
    NivelCuenta INT NULL,
    Cta_Coi NVARCHAR(20) NULL,
    Desc_Coi NVARCHAR(160) NULL,
    TipoCuenta NCHAR(1) NULL,
    S8 NVARCHAR(5) NULL,
    S9 NVARCHAR(5) NULL,
    S10 NVARCHAR(5) NULL,
    IsCuentaDetalle AS (CASE WHEN TipoCuenta = 'D' THEN 1 ELSE 0 END),
    CONSTRAINT PK_CuentaContable PRIMARY KEY (PKIdCuentaContable),
    CONSTRAINT FK_CuentaContable_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_CuentaContable_TipoCuenta FOREIGN KEY (FKIdTipoCuenta_CONTA) REFERENCES CONTA.TipoCuenta(PKIdTipoCuenta),
    CONSTRAINT FK_CuentaContable_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_CuentaContable_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- CONTA.Poliza
IF OBJECT_ID(N'CONTA.Poliza', N'U') IS NULL
BEGIN
CREATE TABLE CONTA.Poliza (
    PKIdPoliza INT IDENTITY(1,1) NOT NULL,
    FKIdAnio_SIS INT NOT NULL,
    FKIdMes_SIS INT NOT NULL,
    FKIdTipoPoliza_SIS INT NOT NULL,
    ClavePoliza NVARCHAR(10) NOT NULL,
    NombrePoliza NVARCHAR(1000) NOT NULL,
    FechaPoliza DATETIME NOT NULL,
    EstaBalanceado BIT NOT NULL CONSTRAINT DF_Poliza_EstaBalanceado DEFAULT (0),
    Activo BIT NOT NULL CONSTRAINT DF_Poliza_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Poliza_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    PermitirModificar BIT NULL,
    FKIdAccionAutorizar_SIS INT NULL,
    Autorizado BIT NULL,
    FechaSolicitud DATETIME NULL,
    FechaAutorizacion DATETIME NULL,
    CONSTRAINT PK_Poliza PRIMARY KEY (PKIdPoliza),
    CONSTRAINT FK_Poliza_Anio FOREIGN KEY (FKIdAnio_SIS) REFERENCES SIS.Anio(PKIdAnio),
    CONSTRAINT FK_Poliza_TipoPoliza FOREIGN KEY (FKIdTipoPoliza_SIS) REFERENCES SIS.TipoPoliza(PKIdTipoPoliza),
    CONSTRAINT FK_Poliza_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Poliza_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- CONTA.ConsecutivoPoliza (consecutivo anual por mes y tipo de p?liza)
IF OBJECT_ID(N'CONTA.ConsecutivoPoliza', N'U') IS NULL
BEGIN
CREATE TABLE CONTA.ConsecutivoPoliza (
    PKIdConsecutivoPoliza INT IDENTITY(1,1) NOT NULL,
    FK_IdAnio__SIS INT NOT NULL,
    FK_IdMes__SIS INT NOT NULL,
    FK_IdTipoPoliza__SIS INT NOT NULL,
    UltimoValor INT NOT NULL CONSTRAINT DF_ConsecutivoPoliza_UltimoValor DEFAULT (0),
    Activo BIT NOT NULL CONSTRAINT DF_ConsecutivoPoliza_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_ConsecutivoPoliza_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_ConsecutivoPoliza PRIMARY KEY (PKIdConsecutivoPoliza),
    CONSTRAINT FK_ConsecutivoPoliza_Anio FOREIGN KEY (FK_IdAnio__SIS) REFERENCES SIS.Anio(PKIdAnio),
    CONSTRAINT FK_ConsecutivoPoliza_TipoPoliza FOREIGN KEY (FK_IdTipoPoliza__SIS) REFERENCES SIS.TipoPoliza(PKIdTipoPoliza),
    CONSTRAINT UQ_ConsecutivoPoliza UNIQUE (FK_IdAnio__SIS, FK_IdMes__SIS, FK_IdTipoPoliza__SIS),
    CONSTRAINT FK_ConsecutivoPoliza_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_ConsecutivoPoliza_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- CONTA.PolizaDetalle (origen CONTA.DetallePoliza)
IF OBJECT_ID(N'CONTA.PolizaDetalle', N'U') IS NULL
BEGIN
CREATE TABLE CONTA.PolizaDetalle (
    PKIdPolizaDetalle INT IDENTITY(1,1) NOT NULL,
    FKIdCuentaContable_CONTA INT NOT NULL,
    FKIdPoliza_CONTA INT NOT NULL,
    Descripcion NVARCHAR(600) NULL,
    ImporteDebe [dbo].[dmoney] NULL,
    ImporteHaber [dbo].[dmoney] NULL,
    FKIdReferencia INT NULL,
    FKIdTipoDetallePoliza_SIS INT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_PolizaDetalle_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_PolizaDetalle_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_PolizaDetalle PRIMARY KEY (PKIdPolizaDetalle),
    CONSTRAINT FK_PolizaDetalle_CuentaContable FOREIGN KEY (FKIdCuentaContable_CONTA) REFERENCES CONTA.CuentaContable(PKIdCuentaContable),
    CONSTRAINT FK_PolizaDetalle_Poliza FOREIGN KEY (FKIdPoliza_CONTA) REFERENCES CONTA.Poliza(PKIdPoliza),
    CONSTRAINT FK_PolizaDetalle_TipoDetallePoliza FOREIGN KEY (FKIdTipoDetallePoliza_SIS) REFERENCES SIS.TipoDetallePoliza(PkIdTipoDetallePoliza),
    CONSTRAINT FK_PolizaDetalle_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_PolizaDetalle_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- ALMA.TipoBien
IF OBJECT_ID(N'ALMA.TipoBien', N'U') IS NULL
BEGIN
CREATE TABLE ALMA.TipoBien (
    PKIdTipoBien INT IDENTITY(1,1) NOT NULL,
    FKIdGrupoBien_ALMA INT NULL,
    FKIdNivel_ALMA INT NULL,
    FKIdPartida_CONTA INT NULL,
    FKIdCuentaContable_CONTA INT NULL,
    FKIdUnidades_ALMA INT NULL,
    FKIdLocalizacion_ALMA INT NULL,
    CodigoClave NVARCHAR(200) NULL,
    Descripcion NVARCHAR(1200) NULL,
    DepreciacionAnual DECIMAL(18,4) NULL,
    Consecutivo INT NULL,
    CABMS NVARCHAR(50) NULL,
    Identificador NVARCHAR(50) NULL,
    ExistenciaMinima DECIMAL(18,4) NULL,
    ExistenciaMaxima DECIMAL(18,4) NULL,
    TiempoVida INT NULL,
    Pk_IdTratadoInt INT NULL,
    Cuota NUMERIC(8,2) NULL,
    ProveeduriaNac BIT NULL,
    CatalogoBasico BIT NULL,
    CUCOP_PLUS VARCHAR(25) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_TipoBien_Activo DEFAULT (1),
    FechaCreacion DATETIME CONSTRAINT DF_TipoBien_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME NULL,
    UsuarioModificacion INT NULL,
    FKIdUnidades_Equivalente INT NULL,
    Cantidad_Equivalente INT NULL,
    CONSTRAINT PK_TipoBien PRIMARY KEY (PKIdTipoBien),
    CONSTRAINT FK_TipoBien_GrupoBien FOREIGN KEY (FKIdGrupoBien_ALMA) REFERENCES ALMA.GrupoBien(PKIdGrupoBien),
    CONSTRAINT FK_TipoBien_Nivel FOREIGN KEY (FKIdNivel_ALMA) REFERENCES ALMA.Nivel(PKIdNivel),
    CONSTRAINT FK_TipoBien_Partida FOREIGN KEY (FKIdPartida_CONTA) REFERENCES CONTA.Partida(PKIdPartida),
    CONSTRAINT FK_TipoBien_CuentaContable FOREIGN KEY (FKIdCuentaContable_CONTA) REFERENCES CONTA.CuentaContable(PKIdCuentaContable),
    CONSTRAINT FK_TipoBien_Unidades FOREIGN KEY (FKIdUnidades_ALMA) REFERENCES ALMA.Unidades(PKIdUnidades),
    CONSTRAINT FK_TipoBien_UnidadesEquivalente FOREIGN KEY (FKIdUnidades_Equivalente) REFERENCES ALMA.Unidades(PKIdUnidades),
    CONSTRAINT FK_TipoBien_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_TipoBien_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- =============================================
-- TABLAS CON DEPENDENCIAS (FASE 3)
-- =============================================

-- SIS.UsuarioSucursal
IF OBJECT_ID(N'SIS.UsuarioSucursal', N'U') IS NULL
BEGIN
CREATE TABLE SIS.UsuarioSucursal (
    FKIdUsuario_SIS INT NOT NULL,
    FKIdSucursal_SIS INT NOT NULL,
    PuedeAcceder BIT NOT NULL DEFAULT 1,
    PuedeConfigurar BIT NOT NULL DEFAULT 0,
    PuedeOperar BIT NOT NULL DEFAULT 1,
    PuedeReportes BIT NOT NULL DEFAULT 0,
    EsGerente BIT NOT NULL DEFAULT 0,
    EsSupervisor BIT NOT NULL DEFAULT 0,
    FechaAsignacion DATETIME2 DEFAULT SYSDATETIME(),
    FechaFinAsignacion DATETIME2 NULL,
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_UsuarioSucursal PRIMARY KEY (FKIdUsuario_SIS, FKIdSucursal_SIS),
    CONSTRAINT FK_UsuarioSucursal_Usuario FOREIGN KEY (FKIdUsuario_SIS) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_UsuarioSucursal_Sucursal FOREIGN KEY (FKIdSucursal_SIS) REFERENCES SIS.Sucursal(PKIdSucursal)
);

END
GO

-- SIS.UsuarioDepartamento
IF OBJECT_ID(N'SIS.UsuarioDepartamento', N'U') IS NULL
BEGIN
CREATE TABLE SIS.UsuarioDepartamento (
    FKIdUsuario_SIS INT NOT NULL,
    FKIdDepartamento_SIS INT NOT NULL,
    EsJefe BIT NOT NULL DEFAULT 0,
    FechaAsignacion DATETIME2 DEFAULT SYSDATETIME(),
    FechaFinAsignacion DATETIME2 NULL,
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_UsuarioDepartamento PRIMARY KEY (FKIdUsuario_SIS, FKIdDepartamento_SIS, FechaAsignacion),
    CONSTRAINT FK_UsuarioDepartamento_Usuario FOREIGN KEY (FKIdUsuario_SIS) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_UsuarioDepartamento_Departamento FOREIGN KEY (FKIdDepartamento_SIS) REFERENCES SIS.Departamento(PKIdDepartamento)
);

END
GO

-- SIS.Menu
IF OBJECT_ID(N'SIS.Menu', N'U') IS NULL
BEGIN
CREATE TABLE SIS.Menu (
    PKIdMenu INT IDENTITY NOT NULL,
    Nombre NVARCHAR(150) NOT NULL,
    Tipo INT NOT NULL,
    FKIdMenu_SIS INT NULL,
    LegacyName NVARCHAR(80),
    Ruta NVARCHAR(200),
    ImageUrl NVARCHAR(120),
    Lenguaje CHAR(3) NOT NULL,
    [Orden] INT NULL,
    Activo BIT NOT NULL DEFAULT 1,
    CreatedByOperatorId INT,
    CreatedDateTime DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedByOperatorId INT,
    ModifiedDateTime DATETIME,
    CONSTRAINT CONSTRAINT_PK_Menu PRIMARY KEY CLUSTERED (PKIdMenu),
    CONSTRAINT CONSTRAINT_FK_Menu_Padre FOREIGN KEY (FKIdMenu_SIS) REFERENCES SIS.Menu(PKIdMenu)
);

END
GO

-- SIS.MenuRole
IF OBJECT_ID(N'SIS.MenuRole', N'U') IS NULL
BEGIN
CREATE TABLE SIS.MenuRole (
    FKIdMenu_SIS INT NOT NULL,
    RoleId NVARCHAR(128) NOT NULL,
    Activo BIT NOT NULL DEFAULT 1,
    CreatedByOperatorId INT,
    CreatedDateTime DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedByOperatorId INT,
    ModifiedDateTime DATETIME,
    CONSTRAINT CONSTRAINT_PK_MenuRole PRIMARY KEY CLUSTERED (FKIdMenu_SIS, RoleId),
    CONSTRAINT CONSTRAINT_FK_MenuRole_Menu FOREIGN KEY (FKIdMenu_SIS) REFERENCES SIS.Menu(PKIdMenu),
    CONSTRAINT CONSTRAINT_FK_MenuRole_Role FOREIGN KEY (RoleId) REFERENCES dbo.AspNetRoles(Id)
);

END
GO

-- dbo.AspNetClaims
IF OBJECT_ID(N'dbo.AspNetClaims', N'U') IS NULL
BEGIN
CREATE TABLE dbo.AspNetClaims (
    Id INT IDENTITY(1,1) NOT NULL,
    ClaimTypeId INT,
    Name NVARCHAR(150) NOT NULL,
    [Group] NVARCHAR(100),
    RoleId NVARCHAR(128),
    TokenFormat NVARCHAR(50),
    Created DATETIME NOT NULL,
    SubGroup NVARCHAR(100),
    Code NVARCHAR(10),
    Description NVARCHAR(200),
    [Values] VARCHAR(MAX),
    ReferenceId INT NOT NULL CONSTRAINT CONSTRAINT_DF_AspNetClaims_ReferenceId DEFAULT (0),
    CONSTRAINT CONSTRAINT_PK_AspNetClaims PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT CONSTRAINT_FK_AspNetClaims_ClaimType FOREIGN KEY (ClaimTypeId) REFERENCES dbo.AspNetClaimTypes(Id),
    CONSTRAINT CONSTRAINT_FK_AspNetClaims_Role FOREIGN KEY (RoleId) REFERENCES dbo.AspNetRoles(Id)
);

END
GO

-- dbo.AspNetClaimValues
IF OBJECT_ID(N'dbo.AspNetClaimValues', N'U') IS NULL
BEGIN
CREATE TABLE dbo.AspNetClaimValues (
    Id INT IDENTITY NOT NULL,
    ClaimId INT,
    Value NVARCHAR(50) NOT NULL,
    Created DATETIME NOT NULL CONSTRAINT CONSTRAINT_DF_AspNetClaimValues_Created DEFAULT GETDATE(),
    CONSTRAINT CONSTRAINT_PK_AspNetClaimValues PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT CONSTRAINT_FK_AspNetClaimValues_Claim FOREIGN KEY (ClaimId) REFERENCES dbo.AspNetClaims(Id)
);

END
GO

-- dbo.AspNetUsers
IF OBJECT_ID(N'dbo.AspNetUsers', N'U') IS NULL
BEGIN
CREATE TABLE dbo.AspNetUsers (
    Id NVARCHAR(128) NOT NULL,
    Email NVARCHAR(256),
    EmailConfirmed BIT NOT NULL,
    PasswordHash NVARCHAR(MAX),
    SecurityStamp NVARCHAR(MAX),
    PhoneNumber NVARCHAR(MAX),
    PhoneNumberConfirmed BIT NOT NULL,
    TwoFactorEnabled BIT NOT NULL,
    LockoutEndDateUtc DATETIME,
    LockoutEnabled BIT NOT NULL,
    AccessFailedCount INT NOT NULL,
    ReferenceId INT,
    AccessNumber NVARCHAR(25),
    PkIdUsuario INT,
    CONSTRAINT CONSTRAINT_PK_AspNetUsers PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT CONSTRAINT_FK_AspNetUsers_Usuario FOREIGN KEY (PkIdUsuario) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- dbo.AspNetUserRoles
IF OBJECT_ID(N'dbo.AspNetUserRoles', N'U') IS NULL
BEGIN
CREATE TABLE dbo.AspNetUserRoles (
    UserId NVARCHAR(128) NOT NULL,
    RoleId NVARCHAR(128) NOT NULL,
    ExpireDate DATETIME,
    CONSTRAINT CONSTRAINT_PK_AspNetUserRoles PRIMARY KEY CLUSTERED (UserId, RoleId),
    CONSTRAINT CONSTRAINT_FK_AspNetUserRoles_User FOREIGN KEY (UserId) REFERENCES dbo.AspNetUsers(Id),
    CONSTRAINT CONSTRAINT_FK_AspNetUserRoles_Role FOREIGN KEY (RoleId) REFERENCES dbo.AspNetRoles(Id)
);

END
GO

-- SIS.PerfilUsuario
IF OBJECT_ID(N'SIS.PerfilUsuario', N'U') IS NULL
BEGIN
CREATE TABLE SIS.PerfilUsuario (
    FKIdUsuario_SIS INT PRIMARY KEY,
    Fotografia VARBINARY(MAX),
    ContentType NVARCHAR(50),
    [FileName] NVARCHAR(64) NULL,
    [FileExtension] NVARCHAR(8) NULL,
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT FK_PerfilUsuario_Usuario FOREIGN KEY (FKIdUsuario_SIS) REFERENCES SIS.Usuario(PKIdUsuario) ON DELETE CASCADE
);

END
GO

-- SIS.SystemLog
IF OBJECT_ID(N'SIS.SystemLog', N'U') IS NULL
BEGIN
CREATE TABLE SIS.SystemLog (
    PKIdSystemLog INT IDENTITY(1,1) NOT NULL,
    FKIdOrigenLogMessage_SIS INT NOT NULL,
    [Date] DATETIME2 DEFAULT SYSDATETIME(),
    [Type] NVARCHAR(24) NULL,
    ProgName NVARCHAR(256) NULL,
    EmployeeNo NVARCHAR(24) NULL,
    Category NVARCHAR(24) NULL,
    IPClient NVARCHAR(24) NULL,
    HostName NVARCHAR(32) NULL,
    Thread VARCHAR(255) NULL,
    [Level] VARCHAR(20) NULL,
    Logger VARCHAR(255) NULL,
    Message VARCHAR(4000) NULL,
    Exception NVARCHAR(4000) NULL,
    Context NVARCHAR(10) NULL,
    MethodName NVARCHAR(200) NULL,
    Parameters NVARCHAR(4000) NULL,
    ExecutionTime INT NULL,
    CONSTRAINT CONSTRAINT_PK_SystemLog PRIMARY KEY CLUSTERED (PKIdSystemLog),
    CONSTRAINT CONSTRAINT_FK_SystemLog_OrigenLogMessage FOREIGN KEY (FKIdOrigenLogMessage_SIS) REFERENCES SIS.OrigenLogMessage(PKIdOrigenLogMessage)
);

END
GO

-- SIS.SystemParamValue
IF OBJECT_ID(N'SIS.SystemParamValue', N'U') IS NULL
BEGIN
CREATE TABLE SIS.SystemParamValue (
    PKIdSystemParamValue INT NOT NULL,
    FKIdSystemParamCatalog_SIS INT NOT NULL,
    Value NVARCHAR(MAX) NOT NULL,
    Descripcion VARCHAR(128) NOT NULL,
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT CONSTRAINT_PK_SystemParamValue PRIMARY KEY CLUSTERED (PKIdSystemParamValue),
    CONSTRAINT CONSTRAINT_FK_SystemParamCatalog_SystemParamValue FOREIGN KEY (FKIdSystemParamCatalog_SIS) REFERENCES SIS.SystemParamCatalog(PKIdSystemParamCatalog)
);

END
GO

-- ALMA.PeriodoConteo
IF OBJECT_ID(N'ALMA.PeriodoConteo', N'U') IS NULL
BEGIN
CREATE TABLE ALMA.PeriodoConteo (
    PKIdPeriodoConteo INT IDENTITY(1,1) NOT NULL,
    FKIdSucursal_SIS INT NOT NULL,
    FKIdTipoConteo_ALMA INT NOT NULL,
    FKIdEstatus_ALMA INT NOT NULL,
    CodigoPeriodo NVARCHAR(20) NOT NULL,
    Nombre NVARCHAR(100) NOT NULL,
    Descripcion NVARCHAR(500) NULL,
    FechaInicio DATE NOT NULL,
    FechaFin DATE NULL,
    FechaCierre DATETIME NULL,
    MaximoConteosPorArticulo INT NOT NULL CONSTRAINT DF_PeriodoConteo_MaxConteos DEFAULT (3),
    RequiereAprobacionSupervisor BIT NOT NULL CONSTRAINT DF_PeriodoConteo_ReqAprobacion DEFAULT (1),
    FKIdResponsable_SIS INT NULL,
    FKIdSupervisor_SIS INT NULL,
    TotalArticulos INT NULL,
    ArticulosConcluidos INT NULL,
    ArticulosConDiferencia INT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_PeriodoConteo_Activo DEFAULT (1),
    FechaCreacion DATETIME CONSTRAINT DF_PeriodoConteo_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_PeriodoConteo PRIMARY KEY (PKIdPeriodoConteo),
    CONSTRAINT FK_PeriodoConteo_Sucursal FOREIGN KEY (FKIdSucursal_SIS) REFERENCES SIS.Sucursal(PKIdSucursal),
    CONSTRAINT FK_PeriodoConteo_TipoConteo FOREIGN KEY (FKIdTipoConteo_ALMA) REFERENCES ALMA.TipoConteo(PKIdTipoConteo),
    CONSTRAINT FK_PeriodoConteo_Estatus FOREIGN KEY (FKIdEstatus_ALMA) REFERENCES ALMA.EstatusPeriodo(PKIdEstatusPeriodo),
    CONSTRAINT FK_PeriodoConteo_Responsable FOREIGN KEY (FKIdResponsable_SIS) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_PeriodoConteo_Supervisor FOREIGN KEY (FKIdSupervisor_SIS) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT UQ_PeriodoConteo_Codigo UNIQUE (FKIdSucursal_SIS, CodigoPeriodo),
    CONSTRAINT FK_PeriodoConteo_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_PeriodoConteo_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- SIS.Proveedor
IF OBJECT_ID(N'SIS.Proveedor', N'U') IS NULL
BEGIN
CREATE TABLE SIS.Proveedor (
    PKIdProveedor INT IDENTITY(1,1) NOT NULL,
    FkIdTipoProveedor_SIS INT NULL,
    FKIdEstatusProveedor_SIS INT NULL,
    FKIdCuentaContable_SIS INT NULL,
    FKIdMunicipio_SIS INT NOT NULL,
    FKIdEstado_SIS INT NOT NULL,
    FKIdPais_SIS INT NOT NULL,
    FKIdResponsable_SIS INT NULL,
    FKIdAESector_SIS INT NULL,
    FKIdAEDivision_SIS INT NULL,
    FKIdAEGrupo_SIS INT NULL,
    FKIdAEClase_SIS INT NULL,
    Nombre NVARCHAR(500) NOT NULL,
    RFC NVARCHAR(50) NULL,
    Colonia NVARCHAR(50) NULL,
    CP NVARCHAR(50) NULL,
    Ciudad NVARCHAR(50) NULL,
    EMAIL NVARCHAR(50) NULL,
    Clave NVARCHAR(10) NOT NULL,
    Calle NVARCHAR(50) NULL,
    Numero NVARCHAR(10) NULL,
    FechaAlta DATETIME NULL,
    TelefonoInstitucional NVARCHAR(20) NULL,
    Notas NVARCHAR(MAX) NULL,
    PaginaWeb NVARCHAR(100) NULL,
    NumeroInt NVARCHAR(10) NULL,
    CURP NVARCHAR(18) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Proveedor_Activo DEFAULT (1),
    FechaCreacion DATETIME CONSTRAINT DF_Proveedor_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Proveedor PRIMARY KEY (PKIdProveedor),
    CONSTRAINT FK_Proveedor_TipoProveedor FOREIGN KEY (FkIdTipoProveedor_SIS) REFERENCES SIS.TipoProveedor(PkIdTipoProveedor),
    CONSTRAINT FK_Proveedor_EstatusProveedor FOREIGN KEY (FKIdEstatusProveedor_SIS) REFERENCES SIS.EstatusProveedor(PKIdEstatusProveedor),
    CONSTRAINT FK_Proveedor_CuentaContable FOREIGN KEY (FKIdCuentaContable_SIS) REFERENCES CONTA.CuentaContable(PKIdCuentaContable),
    CONSTRAINT FK_Proveedor_Municipio FOREIGN KEY (FKIdMunicipio_SIS) REFERENCES SIS.Municipios(PKIdMunicipio),
    CONSTRAINT FK_Proveedor_Estado FOREIGN KEY (FKIdEstado_SIS) REFERENCES SIS.Estados(PKIdEstado),
    CONSTRAINT FK_Proveedor_Pais FOREIGN KEY (FKIdPais_SIS) REFERENCES SIS.Paises(PKIdPais)
);

END
GO

-- NOM.PersonaArea
IF OBJECT_ID(N'NOM.PersonaArea', N'U') IS NULL
BEGIN
CREATE TABLE NOM.PersonaArea (
    PKIdPersonaArea INT IDENTITY(1,1) NOT NULL,
    FKIdPersona_NOM INT NOT NULL,
    FKIdArea_SIS INT NOT NULL,
    IsAdscrito BIT NOT NULL,
    EsSolicitante BIT NULL,
    EsAutorizador BIT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_PersonaArea_Activo DEFAULT (1),
    FechaCreacion DATETIME CONSTRAINT DF_PersonaArea_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_PersonaArea PRIMARY KEY (PKIdPersonaArea),
    CONSTRAINT FK_PersonaArea_Persona FOREIGN KEY (FKIdPersona_NOM) REFERENCES NOM.Persona(PKIdPersona),
    CONSTRAINT FK_PersonaArea_Area FOREIGN KEY (FKIdArea_SIS) REFERENCES SIS.Area(PKIdArea),
    CONSTRAINT FK_PersonaArea_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_PersonaArea_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.EgresoProyectado
IF OBJECT_ID(N'PRES.EgresoProyectado', N'U') IS NULL
BEGIN
CREATE TABLE PRES.EgresoProyectado (
    PKIdEgresoProyectado INT IDENTITY(1,1) NOT NULL,
    FKIdPrograma_PRES INT NOT NULL,
    FKIdPartida_CONTA INT NOT NULL,
    FKIdArea_SIS INT NOT NULL,
    Descripcion NVARCHAR(250) NULL,
    Fecha DATE NOT NULL,
    FKIdFuenteFinanciamiento_PRES INT NULL,
    FKIdTipoGasto_PRES INT NULL,
    FKIdDigitoIdentificador_PRES INT NULL,
    FKIdDestinoGasto_PRES INT NULL,
    FKIdPY_PRES INT NULL,
    Enero DECIMAL(18,2) NOT NULL CONSTRAINT DF_EgresoProyectado_Enero DEFAULT (0),
    Febrero DECIMAL(18,2) NOT NULL CONSTRAINT DF_EgresoProyectado_Febrero DEFAULT (0),
    Marzo DECIMAL(18,2) NOT NULL CONSTRAINT DF_EgresoProyectado_Marzo DEFAULT (0),
    Abril DECIMAL(18,2) NOT NULL CONSTRAINT DF_EgresoProyectado_Abril DEFAULT (0),
    Mayo DECIMAL(18,2) NOT NULL CONSTRAINT DF_EgresoProyectado_Mayo DEFAULT (0),
    Junio DECIMAL(18,2) NOT NULL CONSTRAINT DF_EgresoProyectado_Junio DEFAULT (0),
    Julio DECIMAL(18,2) NOT NULL CONSTRAINT DF_EgresoProyectado_Julio DEFAULT (0),
    Agosto DECIMAL(18,2) NOT NULL CONSTRAINT DF_EgresoProyectado_Agosto DEFAULT (0),
    Septiembre DECIMAL(18,2) NOT NULL CONSTRAINT DF_EgresoProyectado_Septiembre DEFAULT (0),
    Octubre DECIMAL(18,2) NOT NULL CONSTRAINT DF_EgresoProyectado_Octubre DEFAULT (0),
    Noviembre DECIMAL(18,2) NOT NULL CONSTRAINT DF_EgresoProyectado_Noviembre DEFAULT (0),
    Diciembre DECIMAL(18,2) NOT NULL CONSTRAINT DF_EgresoProyectado_Diciembre DEFAULT (0),
    Total AS (
        Enero + Febrero + Marzo + Abril + Mayo + Junio +
        Julio + Agosto + Septiembre + Octubre + Noviembre + Diciembre
    ),
    Activo BIT NOT NULL CONSTRAINT DF_EgresoProyectado_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_EgresoProyectado_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_EgresoProyectado PRIMARY KEY (PKIdEgresoProyectado),
    CONSTRAINT FK_EgresoProyectado_Programa FOREIGN KEY (FKIdPrograma_PRES) REFERENCES PRES.Programa(PKIdPrograma),
    CONSTRAINT FK_EgresoProyectado_Partida FOREIGN KEY (FKIdPartida_CONTA) REFERENCES CONTA.Partida(PKIdPartida),
    CONSTRAINT FK_EgresoProyectado_Area FOREIGN KEY (FKIdArea_SIS) REFERENCES SIS.Area(PKIdArea),
    CONSTRAINT FK_EgresoProyectado_FuenteFinanciamiento FOREIGN KEY (FKIdFuenteFinanciamiento_PRES) REFERENCES PRES.FuenteFinanciamiento(PKIdFuenteFinanciamiento),
    CONSTRAINT FK_EgresoProyectado_TipoGasto FOREIGN KEY (FKIdTipoGasto_PRES) REFERENCES PRES.TipoGasto(PKIdTipoGasto),
    CONSTRAINT FK_EgresoProyectado_DigitoIdentificador FOREIGN KEY (FKIdDigitoIdentificador_PRES) REFERENCES PRES.DigitoIdentificador(PKIdDigitoIdentificador),
    CONSTRAINT FK_EgresoProyectado_DestinoGasto FOREIGN KEY (FKIdDestinoGasto_PRES) REFERENCES PRES.DestinoGasto(PKIdDestinoGasto),
    CONSTRAINT FK_EgresoProyectado_PY FOREIGN KEY (FKIdPY_PRES) REFERENCES PRES.PY(PKIdPY),
    CONSTRAINT FK_EgresoProyectado_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_EgresoProyectado_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- PRES.EgresoAutorizado
IF OBJECT_ID(N'PRES.EgresoAutorizado', N'U') IS NULL
BEGIN
CREATE TABLE PRES.EgresoAutorizado (
    PKIdEgresoAutorizado INT IDENTITY(1,1) NOT NULL,
    FKIdEgresoProyectado_PRES INT NULL,
    FKIdPrograma_PRES INT NOT NULL,
    FKIdPartida_CONTA INT NOT NULL,
    FKIdArea_SIS INT NOT NULL,
    Descripcion NVARCHAR(250) NULL,
    Fecha DATE NOT NULL,
    FKIdPoliza_CONTA INT NULL,
    FKIdFuenteFinanciamiento_PRES INT NULL,
    FKIdTipoGasto_PRES INT NULL,
    FKIdDigitoIdentificador_PRES INT NULL,
    FKIdDestinoGasto_PRES INT NULL,
    FKIdPY_PRES INT NULL,
    Enero DECIMAL(18,2) NOT NULL CONSTRAINT DF_EgresoAutorizado_Enero DEFAULT (0),
    Febrero DECIMAL(18,2) NOT NULL CONSTRAINT DF_EgresoAutorizado_Febrero DEFAULT (0),
    Marzo DECIMAL(18,2) NOT NULL CONSTRAINT DF_EgresoAutorizado_Marzo DEFAULT (0),
    Abril DECIMAL(18,2) NOT NULL CONSTRAINT DF_EgresoAutorizado_Abril DEFAULT (0),
    Mayo DECIMAL(18,2) NOT NULL CONSTRAINT DF_EgresoAutorizado_Mayo DEFAULT (0),
    Junio DECIMAL(18,2) NOT NULL CONSTRAINT DF_EgresoAutorizado_Junio DEFAULT (0),
    Julio DECIMAL(18,2) NOT NULL CONSTRAINT DF_EgresoAutorizado_Julio DEFAULT (0),
    Agosto DECIMAL(18,2) NOT NULL CONSTRAINT DF_EgresoAutorizado_Agosto DEFAULT (0),
    Septiembre DECIMAL(18,2) NOT NULL CONSTRAINT DF_EgresoAutorizado_Septiembre DEFAULT (0),
    Octubre DECIMAL(18,2) NOT NULL CONSTRAINT DF_EgresoAutorizado_Octubre DEFAULT (0),
    Noviembre DECIMAL(18,2) NOT NULL CONSTRAINT DF_EgresoAutorizado_Noviembre DEFAULT (0),
    Diciembre DECIMAL(18,2) NOT NULL CONSTRAINT DF_EgresoAutorizado_Diciembre DEFAULT (0),
    Total AS (
        Enero + Febrero + Marzo + Abril + Mayo + Junio +
        Julio + Agosto + Septiembre + Octubre + Noviembre + Diciembre
    ),
    FechaAutorizacion DATETIME2 NULL,
    UsuarioAutorizacion INT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_EgresoAutorizado_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_EgresoAutorizado_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_EgresoAutorizado PRIMARY KEY (PKIdEgresoAutorizado),
    CONSTRAINT FK_EgresoAutorizado_EgresoProyectado FOREIGN KEY (FKIdEgresoProyectado_PRES) REFERENCES PRES.EgresoProyectado(PKIdEgresoProyectado),
    CONSTRAINT FK_EgresoAutorizado_Programa FOREIGN KEY (FKIdPrograma_PRES) REFERENCES PRES.Programa(PKIdPrograma),
    CONSTRAINT FK_EgresoAutorizado_Partida FOREIGN KEY (FKIdPartida_CONTA) REFERENCES CONTA.Partida(PKIdPartida),
    CONSTRAINT FK_EgresoAutorizado_Area FOREIGN KEY (FKIdArea_SIS) REFERENCES SIS.Area(PKIdArea),
    CONSTRAINT FK_EgresoAutorizado_FuenteFinanciamiento FOREIGN KEY (FKIdFuenteFinanciamiento_PRES) REFERENCES PRES.FuenteFinanciamiento(PKIdFuenteFinanciamiento),
    CONSTRAINT FK_EgresoAutorizado_TipoGasto FOREIGN KEY (FKIdTipoGasto_PRES) REFERENCES PRES.TipoGasto(PKIdTipoGasto),
    CONSTRAINT FK_EgresoAutorizado_DigitoIdentificador FOREIGN KEY (FKIdDigitoIdentificador_PRES) REFERENCES PRES.DigitoIdentificador(PKIdDigitoIdentificador),
    CONSTRAINT FK_EgresoAutorizado_DestinoGasto FOREIGN KEY (FKIdDestinoGasto_PRES) REFERENCES PRES.DestinoGasto(PKIdDestinoGasto),
    CONSTRAINT FK_EgresoAutorizado_PY FOREIGN KEY (FKIdPY_PRES) REFERENCES PRES.PY(PKIdPY),
    CONSTRAINT FK_EgresoAutorizado_Poliza FOREIGN KEY (FKIdPoliza_CONTA) REFERENCES CONTA.Poliza(PKIdPoliza),
    CONSTRAINT FK_EgresoAutorizado_UsuarioAutorizacion FOREIGN KEY (UsuarioAutorizacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_EgresoAutorizado_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_EgresoAutorizado_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_EgresoAutorizado_EgresoProyectado_Activo' AND object_id = OBJECT_ID(N'PRES.EgresoAutorizado'))
BEGIN
CREATE UNIQUE INDEX UX_EgresoAutorizado_EgresoProyectado_Activo
    ON PRES.EgresoAutorizado(FKIdEgresoProyectado_PRES)
    WHERE FKIdEgresoProyectado_PRES IS NOT NULL AND Activo = 1;

END
GO

-- CONTA.MatrizConversion
IF OBJECT_ID(N'CONTA.MatrizConversion', N'U') IS NULL
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

-- CONTA.MatrizIngreso
IF OBJECT_ID(N'CONTA.MatrizIngreso', N'U') IS NULL
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

-- ALMA.Bien
IF OBJECT_ID(N'ALMA.Bien', N'U') IS NULL
BEGIN
CREATE TABLE ALMA.Bien (
    PKIdBien INT IDENTITY(1,1) NOT NULL,
    FKIdGrupoBien_ALMA INT NULL,
    FKIdTipoBien_ALMA INT NOT NULL,
    FKIdArea_SIS INT NULL,
    FKIdProveedor_SIS INT NULL,
    FKIdEstadoBien_ALMA INT NULL,
    FKIdTipoPatrimonio_ALMA INT NULL,
    FKIdMarca_ALMA INT NULL,
    FKIdMaterial_ALMA INT NULL,
    FKIdTipoAdq_ALMA INT NULL,
    FKIdPartida_CONTA INT NULL,
    FKIdDetalleOrdenCompra_ORCO INT NULL,
    Clave NVARCHAR(50) NULL,
    ClaveAnt NVARCHAR(50) NULL,
    Descripcion NVARCHAR(1000) NULL,
    Modelo NVARCHAR(50) NULL,
    Serie NVARCHAR(1000) NULL,
    Requisicion NVARCHAR(25) NULL,
    Factura NVARCHAR(50) NULL,
    Costo [dbo].[dmoney] NULL,
    FechaAdq DATETIME NULL,
    Referencia NVARCHAR(50) NULL,
    Notas NVARCHAR(250) NULL,
    Ubicacion NVARCHAR(50) NULL,
    AAdquisicion NVARCHAR(2) NULL,
    Frente INT NULL,
    Fondo INT NULL,
    Altura INT NULL,
    Diametro INT NULL,
    VerificacionesDias INT NOT NULL,
    MantenimientoDias INT NOT NULL,
    Mantenimiento BIT NOT NULL,
    Calibracion BIT NOT NULL,
    Rango NVARCHAR(20) NULL,
    Resolucion NVARCHAR(20) NULL,
    FechaUltInv DATETIME NULL,
    FechaReqscn DATETIME NULL,
    Estatus NVARCHAR(1) NULL,
    Caracteristicas NVARCHAR(50) NULL,
    Resguardo INT NULL,
    ResguardoAnterior INT NULL,
    RelId INT NULL,
    ValorRescate [dbo].[dmoney] NULL,
    ValorActual [dbo].[dmoney] NULL,
    Antiguedad INT NULL,
    Progresivo INT NULL,
    Consecutivo INT NULL,
    ClaveHist NVARCHAR(50) NULL,
    EstaResguardado BIT NULL,
    FechaResguardado DATETIME NULL,
    Localizado BIT NULL,
    esContabilizado BIT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Bien_Activo DEFAULT (1),
    FechaCreacion DATETIME CONSTRAINT DF_Bien_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Bien PRIMARY KEY (PKIdBien),
    CONSTRAINT FK_Bien_GrupoBien FOREIGN KEY (FKIdGrupoBien_ALMA) REFERENCES ALMA.GrupoBien(PKIdGrupoBien),
    CONSTRAINT FK_Bien_TipoBien FOREIGN KEY (FKIdTipoBien_ALMA) REFERENCES ALMA.TipoBien(PKIdTipoBien),
    CONSTRAINT FK_Bien_Area FOREIGN KEY (FKIdArea_SIS) REFERENCES SIS.Area(PKIdArea),
    CONSTRAINT FK_Bien_Proveedor FOREIGN KEY (FKIdProveedor_SIS) REFERENCES SIS.Proveedor(PKIdProveedor),
    CONSTRAINT FK_Bien_EstadoBien FOREIGN KEY (FKIdEstadoBien_ALMA) REFERENCES ALMA.EstadoBien(PKIdEstadoBien),
    CONSTRAINT FK_Bien_TipoPatrimonio FOREIGN KEY (FKIdTipoPatrimonio_ALMA) REFERENCES ALMA.TipoPatrimonio(PKIdTipoPatrimonio),
    CONSTRAINT FK_Bien_Marca FOREIGN KEY (FKIdMarca_ALMA) REFERENCES ALMA.Marca(PKIdMarca),
    CONSTRAINT FK_Bien_Material FOREIGN KEY (FKIdMaterial_ALMA) REFERENCES ALMA.Material(PKIdMaterial),
    CONSTRAINT FK_Bien_TipoAdquisicion FOREIGN KEY (FKIdTipoAdq_ALMA) REFERENCES ALMA.TipoAdquisicion(PKIdTipoAdq),
    CONSTRAINT FK_Bien_Partida FOREIGN KEY (FKIdPartida_CONTA) REFERENCES CONTA.Partida(PKIdPartida),
    CONSTRAINT FK_Bien_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Bien_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- ALMA.Conteo
IF OBJECT_ID(N'ALMA.Conteo', N'U') IS NULL
BEGIN
CREATE TABLE ALMA.Conteo (
    PKIdConteo INT IDENTITY(1,1) NOT NULL,
    FKIdTipoBien_ALMA INT NOT NULL,
    CantidadInventario DECIMAL(18,2) NOT NULL,
    Descripcion NVARCHAR(MAX) NOT NULL,
    FechaInicio DATETIME NOT NULL,
    FechaFin DATETIME NULL,
    FKIdPeriodoConteo_ALMA INT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Conteo_Activo DEFAULT (1),
    FechaCreacion DATETIME CONSTRAINT DF_Conteo_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Conteo PRIMARY KEY (PKIdConteo),
    CONSTRAINT FK_Conteo_TipoBien FOREIGN KEY (FKIdTipoBien_ALMA) REFERENCES ALMA.TipoBien(PKIdTipoBien),
    CONSTRAINT FK_Conteo_PeriodoConteo FOREIGN KEY (FKIdPeriodoConteo_ALMA) REFERENCES ALMA.PeriodoConteo(PKIdPeriodoConteo),
    CONSTRAINT FK_Conteo_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Conteo_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- ALMA.ConteoDetalle
IF OBJECT_ID(N'ALMA.ConteoDetalle', N'U') IS NULL
BEGIN
CREATE TABLE ALMA.ConteoDetalle (
    PKIdDetalleConteo INT IDENTITY(1,1) NOT NULL,
    FKIdConteo_ALMA INT NOT NULL,
    FKIdNumeroConteo_ALMA INT NOT NULL,
    FKIdPersona_NOM INT NOT NULL,
    Cantidad DECIMAL(18,2) NOT NULL,
    Fecha DATETIME NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_ConteoDetalle_Activo DEFAULT (1),
    FechaCreacion DATETIME CONSTRAINT DF_ConteoDetalle_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_ConteoDetalle PRIMARY KEY (PKIdDetalleConteo),
    CONSTRAINT FK_ConteoDetalle_Conteo FOREIGN KEY (FKIdConteo_ALMA) REFERENCES ALMA.Conteo(PKIdConteo),
    CONSTRAINT FK_ConteoDetalle_Persona FOREIGN KEY (FKIdPersona_NOM) REFERENCES NOM.Persona(PKIdPersona),
    CONSTRAINT FK_ConteoDetalle_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_ConteoDetalle_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- ALMA.ConteoDetalleEscaneo
IF OBJECT_ID(N'ALMA.ConteoDetalleEscaneo', N'U') IS NULL
BEGIN
CREATE TABLE ALMA.ConteoDetalleEscaneo (
    PKIdDetalleEscaneo INT IDENTITY(1,1) NOT NULL,
    FKIdConteo_ALMA INT NOT NULL,
    FKIdPersona_NOM INT NOT NULL,
    CodigoBarras NVARCHAR(100) NOT NULL,
    FKIdTipoBien_ALMA INT NOT NULL,
    FKIdBien_ALMA INT NULL,
    FechaEscaneo DATETIME NOT NULL CONSTRAINT DF_ConteoDetalleEscaneo_FechaEscaneo DEFAULT SYSDATETIME(),
    Activo BIT NOT NULL CONSTRAINT DF_ConteoDetalleEscaneo_Activo DEFAULT (1),
    FechaCreacion DATETIME CONSTRAINT DF_ConteoDetalleEscaneo_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_ConteoDetalleEscaneo PRIMARY KEY (PKIdDetalleEscaneo),
    CONSTRAINT FK_ConteoDetalleEscaneo_Conteo FOREIGN KEY (FKIdConteo_ALMA) REFERENCES ALMA.Conteo(PKIdConteo),
    CONSTRAINT FK_ConteoDetalleEscaneo_Persona FOREIGN KEY (FKIdPersona_NOM) REFERENCES NOM.Persona(PKIdPersona),
    CONSTRAINT FK_ConteoDetalleEscaneo_TipoBien FOREIGN KEY (FKIdTipoBien_ALMA) REFERENCES ALMA.TipoBien(PKIdTipoBien),
    CONSTRAINT FK_ConteoDetalleEscaneo_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_ConteoDetalleEscaneo_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- ALMA.ConteoHist
IF OBJECT_ID(N'ALMA.ConteoHist', N'U') IS NULL
BEGIN
CREATE TABLE ALMA.ConteoHist (
    PKIdConteoHist INT IDENTITY(1,1) NOT NULL,
    PKIdConteo INT NOT NULL,
    FKIdTipoBien_ALMA INT NOT NULL,
    CantidadInventario DECIMAL(18,2) NOT NULL,
    Descripcion NVARCHAR(MAX) NOT NULL,
    FechaInicio DATETIME NOT NULL,
    FechaFin DATETIME NULL,
    PrimerConteo DECIMAL(18,2) NOT NULL,
    SegundoConteo DECIMAL(18,2) NOT NULL,
    TercerConteo DECIMAL(18,2) NOT NULL,
    Diferencias NVARCHAR(MAX) NOT NULL,
    Nivel INT NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_ConteoHist_Activo DEFAULT (1),
    FechaCreacion DATETIME CONSTRAINT DF_ConteoHist_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_ConteoHist PRIMARY KEY (PKIdConteoHist)
);

END
GO

-- ORCO.Requisicion
IF OBJECT_ID(N'ORCO.Requisicion', N'U') IS NULL
BEGIN
CREATE TABLE ORCO.Requisicion (
    PKIdRequisicion INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdPersona_NOM INT NOT NULL,
    FKIdArea_SIS INT NOT NULL,
    Descripcion NVARCHAR(100) NOT NULL,
    Observaciones NVARCHAR(1000) NULL,
    FechaRequisicion DATETIME NOT NULL,
    Servicio BIT NOT NULL,
    FL_FOTO NVARCHAR(1000) NULL,
    FKIdProyecto_ORCO INT NULL,
    FechaRequiereInicio DATETIME NULL,
    FechaRequiereFin DATETIME NULL,
    FKIdPrograma_PRES INT NULL,
    Importe [dbo].[dmoney] NULL,
    FKIdJefeAlmacen_NOM INT NULL,
    FKIdSuficiencia_PRES INT NULL,
    FKIdSuperviso_NOM INT NULL,
    FKIdAutorizo_NOM INT NULL,
    FKIdPSolicita_NOM INT NULL,
    FKIdPJefeAlmacen_NOM INT NULL,
    FKIdPSuficiencia_NOM INT NULL,
    FKIdPSuperviso_NOM INT NULL,
    FKIdPAutorizo_NOM INT NULL,
    FKIdFuenteFinanciamiento_PRES INT NULL,
    FKIdAnio_SIS INT NULL,
    FKIdTipoGasto_PRES INT NULL,
    FKIdDigitoIdentificador_PRES INT NULL,
    FKIdDestinoGasto_PRES INT NULL,
    FKIdEgresoAutorizado_PRES INT NULL,
    Oficio VARCHAR(120) NULL,
    FechaOficio DATETIME NULL,
    CompraDirecta BIT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Requisicion_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Requisicion_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Requisicion PRIMARY KEY (PKIdRequisicion),
    CONSTRAINT FK_Requisicion_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_Requisicion_Persona FOREIGN KEY (FKIdPersona_NOM) REFERENCES NOM.Persona(PKIdPersona),
    CONSTRAINT FK_Requisicion_Area FOREIGN KEY (FKIdArea_SIS) REFERENCES SIS.Area(PKIdArea),
    CONSTRAINT FK_Requisicion_Proyecto FOREIGN KEY (FKIdProyecto_ORCO) REFERENCES ORCO.Proyecto(PKIdProyecto),
    CONSTRAINT FK_Requisicion_Programa FOREIGN KEY (FKIdPrograma_PRES) REFERENCES PRES.Programa(PKIdPrograma),
    CONSTRAINT FK_Requisicion_JefeAlmacen FOREIGN KEY (FKIdJefeAlmacen_NOM) REFERENCES NOM.Persona(PKIdPersona),
    CONSTRAINT FK_Requisicion_Suficiencia FOREIGN KEY (FKIdSuficiencia_PRES) REFERENCES PRES.Suficiencia(PKIdSuficiencia),
    CONSTRAINT FK_Requisicion_Superviso FOREIGN KEY (FKIdSuperviso_NOM) REFERENCES NOM.Persona(PKIdPersona),
    CONSTRAINT FK_Requisicion_Autorizo FOREIGN KEY (FKIdAutorizo_NOM) REFERENCES NOM.Persona(PKIdPersona),
    CONSTRAINT FK_Requisicion_PSolicita FOREIGN KEY (FKIdPSolicita_NOM) REFERENCES NOM.Persona(PKIdPersona),
    CONSTRAINT FK_Requisicion_PJefeAlmacen FOREIGN KEY (FKIdPJefeAlmacen_NOM) REFERENCES NOM.Persona(PKIdPersona),
    CONSTRAINT FK_Requisicion_PSuficiencia FOREIGN KEY (FKIdPSuficiencia_NOM) REFERENCES NOM.Persona(PKIdPersona),
    CONSTRAINT FK_Requisicion_PSuperviso FOREIGN KEY (FKIdPSuperviso_NOM) REFERENCES NOM.Persona(PKIdPersona),
    CONSTRAINT FK_Requisicion_PAutorizo FOREIGN KEY (FKIdPAutorizo_NOM) REFERENCES NOM.Persona(PKIdPersona),
    CONSTRAINT FK_Requisicion_FuenteFinanciamiento FOREIGN KEY (FKIdFuenteFinanciamiento_PRES) REFERENCES PRES.FuenteFinanciamiento(PKIdFuenteFinanciamiento),
    CONSTRAINT FK_Requisicion_Anio FOREIGN KEY (FKIdAnio_SIS) REFERENCES SIS.Anio(PKIdAnio),
    CONSTRAINT FK_Requisicion_TipoGasto FOREIGN KEY (FKIdTipoGasto_PRES) REFERENCES PRES.TipoGasto(PKIdTipoGasto),
    CONSTRAINT FK_Requisicion_DigitoIdentificador FOREIGN KEY (FKIdDigitoIdentificador_PRES) REFERENCES PRES.DigitoIdentificador(PKIdDigitoIdentificador),
    CONSTRAINT FK_Requisicion_DestinoGasto FOREIGN KEY (FKIdDestinoGasto_PRES) REFERENCES PRES.DestinoGasto(PKIdDestinoGasto),
    CONSTRAINT FK_Requisicion_EgresoAutorizado FOREIGN KEY (FKIdEgresoAutorizado_PRES) REFERENCES PRES.EgresoAutorizado(PKIdEgresoAutorizado),
    CONSTRAINT FK_Requisicion_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Requisicion_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- ORCO.DetalleRequisicion
IF OBJECT_ID(N'ORCO.DetalleRequisicion', N'U') IS NULL
BEGIN
CREATE TABLE ORCO.DetalleRequisicion (
    PKIdDetalleRequisicion INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdRequisicion_ORCO INT NOT NULL,
    FKIdTipoBien_ALMA INT NOT NULL,
    FKIdUnidades_ALMA INT NULL,
    Cantidad NUMERIC(8,2) NOT NULL,
    Observaciones NVARCHAR(MAX) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_DetalleRequisicion_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_DetalleRequisicion_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_DetalleRequisicion PRIMARY KEY (PKIdDetalleRequisicion),
    CONSTRAINT FK_DetalleRequisicion_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_DetalleRequisicion_Requisicion FOREIGN KEY (FKIdRequisicion_ORCO) REFERENCES ORCO.Requisicion(PKIdRequisicion),
    CONSTRAINT FK_DetalleRequisicion_TipoBien FOREIGN KEY (FKIdTipoBien_ALMA) REFERENCES ALMA.TipoBien(PKIdTipoBien),
    CONSTRAINT FK_DetalleRequisicion_Unidades FOREIGN KEY (FKIdUnidades_ALMA) REFERENCES ALMA.Unidades(PKIdUnidades),
    CONSTRAINT FK_DetalleRequisicion_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_DetalleRequisicion_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- ORCO.Cotizacion
IF OBJECT_ID(N'ORCO.Cotizacion', N'U') IS NULL
BEGIN
CREATE TABLE ORCO.Cotizacion (
    PKIdCotizacion INT IDENTITY(1,1) NOT NULL,
    FKIdRequisicion_ORCO INT NOT NULL,
    FKIdProveedor_SIS INT NOT NULL,
    FechaSolicitud DATETIME NOT NULL,
    FechaProveedorCotiza DATETIME NULL,
    FechaProveedorCompromiso DATETIME NULL,
    Comentarios NVARCHAR(MAX) NULL,
    Servicio BIT NOT NULL CONSTRAINT DF_Cotizacion_Servicio DEFAULT (0),
    FL_Documento NVARCHAR(1000) NULL,
    Entrega NVARCHAR(MAX) NULL,
    Vigencia NVARCHAR(MAX) NULL,
    Condiciones NVARCHAR(200) NULL,
    FKIdAnio_SIS INT NULL,
    FKIdContenedorCot_ORCO INT NULL,
    FKIdContenedorMultiCot_ORCO INT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Cotizacion_Activo DEFAULT (1),
    FechaCreacion DATETIME2 NOT NULL CONSTRAINT DF_Cotizacion_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Cotizacion PRIMARY KEY (PKIdCotizacion),
    CONSTRAINT FK_Cotizacion_Requisicion FOREIGN KEY (FKIdRequisicion_ORCO) REFERENCES ORCO.Requisicion(PKIdRequisicion),
    CONSTRAINT FK_Cotizacion_Proveedor FOREIGN KEY (FKIdProveedor_SIS) REFERENCES SIS.Proveedor(PKIdProveedor),
    CONSTRAINT FK_Cotizacion_Anio FOREIGN KEY (FKIdAnio_SIS) REFERENCES SIS.Anio(PKIdAnio),
    CONSTRAINT FK_Cotizacion_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Cotizacion_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Cotizacion_Requisicion' AND object_id = OBJECT_ID(N'ORCO.Cotizacion'))
BEGIN
CREATE INDEX IX_Cotizacion_Requisicion ON ORCO.Cotizacion(FKIdRequisicion_ORCO);

END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Cotizacion_Proveedor' AND object_id = OBJECT_ID(N'ORCO.Cotizacion'))
BEGIN
CREATE INDEX IX_Cotizacion_Proveedor ON ORCO.Cotizacion(FKIdProveedor_SIS);

END
GO

-- ORCO.CotizacionDetalle
IF OBJECT_ID(N'ORCO.CotizacionDetalle', N'U') IS NULL
BEGIN
CREATE TABLE ORCO.CotizacionDetalle (
    PKIdCotizacionDetalle INT IDENTITY(1,1) NOT NULL,
    FKIdCotizacion_ORCO INT NOT NULL,
    FKIdDetalleRequisicion_ORCO INT NOT NULL,
    PrecioUnitario [dbo].[dmoney] NULL,
    Activo BIT NOT NULL CONSTRAINT DF_CotizacionDetalle_Activo DEFAULT (1),
    FechaCreacion DATETIME2 NOT NULL CONSTRAINT DF_CotizacionDetalle_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_CotizacionDetalle PRIMARY KEY (PKIdCotizacionDetalle),
    CONSTRAINT FK_CotizacionDetalle_Cotizacion FOREIGN KEY (FKIdCotizacion_ORCO) REFERENCES ORCO.Cotizacion(PKIdCotizacion),
    CONSTRAINT FK_CotizacionDetalle_DetalleRequisicion FOREIGN KEY (FKIdDetalleRequisicion_ORCO) REFERENCES ORCO.DetalleRequisicion(PKIdDetalleRequisicion),
    CONSTRAINT FK_CotizacionDetalle_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_CotizacionDetalle_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_CotizacionDetalle_Cotizacion' AND object_id = OBJECT_ID(N'ORCO.CotizacionDetalle'))
BEGIN
CREATE INDEX IX_CotizacionDetalle_Cotizacion ON ORCO.CotizacionDetalle(FKIdCotizacion_ORCO);

END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_CotizacionDetalle_DetalleRequisicion' AND object_id = OBJECT_ID(N'ORCO.CotizacionDetalle'))
BEGIN
CREATE INDEX IX_CotizacionDetalle_DetalleRequisicion ON ORCO.CotizacionDetalle(FKIdDetalleRequisicion_ORCO);

END
GO

-- ORCO.RequisicionPartida
IF OBJECT_ID(N'ORCO.RequisicionPartida', N'U') IS NULL
BEGIN
CREATE TABLE ORCO.RequisicionPartida (
    PKIdRequisicionPartida INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdRequisicion_ORCO INT NOT NULL,
    FKIdPartida_CONTA INT NOT NULL,
    Monto [dbo].[dmoney] NULL,
    Observaciones NVARCHAR(500) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_RequisicionPartida_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_RequisicionPartida_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_RequisicionPartida PRIMARY KEY (PKIdRequisicionPartida),
    CONSTRAINT FK_RequisicionPartida_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_RequisicionPartida_Requisicion FOREIGN KEY (FKIdRequisicion_ORCO) REFERENCES ORCO.Requisicion(PKIdRequisicion),
    CONSTRAINT FK_RequisicionPartida_Partida FOREIGN KEY (FKIdPartida_CONTA) REFERENCES CONTA.Partida(PKIdPartida),
    CONSTRAINT FK_RequisicionPartida_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_RequisicionPartida_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- ORCO.PAAAS
IF OBJECT_ID(N'ORCO.PAAAS', N'U') IS NULL
BEGIN
CREATE TABLE ORCO.PAAAS (
    PKIdPAAAS INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdAnio_SIS INT NOT NULL,
    FKIdArea_SIS INT NOT NULL,
    FKIdPersona_NOM INT NOT NULL,
    Descripcion NVARCHAR(100) NOT NULL,
    Observaciones NVARCHAR(1000) NULL,
    Fecha DATETIME NOT NULL,
    FKIdProyecto_ORCO INT NULL,
    FKIdPrograma_PRES INT NULL,
    FKIdFuenteFinanciamiento_PRES INT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_PAAAS_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_PAAAS_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_PAAAS PRIMARY KEY (PKIdPAAAS),
    CONSTRAINT FK_PAAAS_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_PAAAS_Anio FOREIGN KEY (FKIdAnio_SIS) REFERENCES SIS.Anio(PKIdAnio),
    CONSTRAINT FK_PAAAS_Area FOREIGN KEY (FKIdArea_SIS) REFERENCES SIS.Area(PKIdArea),
    CONSTRAINT FK_PAAAS_Persona FOREIGN KEY (FKIdPersona_NOM) REFERENCES NOM.Persona(PKIdPersona),
    CONSTRAINT FK_PAAAS_Proyecto FOREIGN KEY (FKIdProyecto_ORCO) REFERENCES ORCO.Proyecto(PKIdProyecto),
    CONSTRAINT FK_PAAAS_Programa FOREIGN KEY (FKIdPrograma_PRES) REFERENCES PRES.Programa(PKIdPrograma),
    CONSTRAINT FK_PAAAS_FuenteFinanciamiento FOREIGN KEY (FKIdFuenteFinanciamiento_PRES) REFERENCES PRES.FuenteFinanciamiento(PKIdFuenteFinanciamiento),
    CONSTRAINT UQ_PAAAS_Area_Anio UNIQUE (FKIdArea_SIS, FKIdAnio_SIS),
    CONSTRAINT FK_PAAAS_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_PAAAS_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- ORCO.PAAASPartida
IF OBJECT_ID(N'ORCO.PAAASPartida', N'U') IS NULL
BEGIN
CREATE TABLE ORCO.PAAASPartida (
    PKIdPAAASPartida INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdPAAAS_ORCO INT NOT NULL,
    FKIdPartida_CONTA INT NOT NULL,
    Observaciones NVARCHAR(1000) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_PAAASPartida_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_PAAASPartida_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_PAAASPartida PRIMARY KEY (PKIdPAAASPartida),
    CONSTRAINT FK_PAAASPartida_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_PAAASPartida_PAAAS FOREIGN KEY (FKIdPAAAS_ORCO) REFERENCES ORCO.PAAAS(PKIdPAAAS),
    CONSTRAINT FK_PAAASPartida_Partida FOREIGN KEY (FKIdPartida_CONTA) REFERENCES CONTA.Partida(PKIdPartida),
    CONSTRAINT FK_PAAASPartida_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_PAAASPartida_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- ORCO.PAAASDetalle
IF OBJECT_ID(N'ORCO.PAAASDetalle', N'U') IS NULL
BEGIN
CREATE TABLE ORCO.PAAASDetalle (
    PKIdPAAASDetalle INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdPAAASPartida_ORCO INT NOT NULL,
    FKIdTipoBien_ALMA INT NOT NULL,
    FKIdUnidades_ALMA INT NULL,
    Cantidad NUMERIC(8,2) NOT NULL,
    Observaciones NVARCHAR(MAX) NOT NULL,
    LugarEntrega VARCHAR(200) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_PAAASDetalle_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_PAAASDetalle_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_PAAASDetalle PRIMARY KEY (PKIdPAAASDetalle),
    CONSTRAINT FK_PAAASDetalle_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_PAAASDetalle_PAAASPartida FOREIGN KEY (FKIdPAAASPartida_ORCO) REFERENCES ORCO.PAAASPartida(PKIdPAAASPartida),
    CONSTRAINT FK_PAAASDetalle_TipoBien FOREIGN KEY (FKIdTipoBien_ALMA) REFERENCES ALMA.TipoBien(PKIdTipoBien),
    CONSTRAINT FK_PAAASDetalle_Unidades FOREIGN KEY (FKIdUnidades_ALMA) REFERENCES ALMA.Unidades(PKIdUnidades),
    CONSTRAINT FK_PAAASDetalle_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_PAAASDetalle_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- ORCO.EstudioMercado
IF OBJECT_ID(N'ORCO.EstudioMercado', N'U') IS NULL
BEGIN
CREATE TABLE ORCO.EstudioMercado (
    PKIdEstudioMercado INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdAnio_SIS INT NOT NULL,
    Nombre VARCHAR(80) NOT NULL,
    Descripcion NVARCHAR(500) NULL,
    FechaSolicitud DATETIME NOT NULL,
    FechaCierre DATETIME NULL,
    FKIdResponsable_NOM INT NOT NULL,
    Estatus INT NOT NULL CONSTRAINT DF_EstudioMercado_Estatus DEFAULT (1),
    Activo BIT NOT NULL CONSTRAINT DF_EstudioMercado_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_EstudioMercado_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_EstudioMercado PRIMARY KEY (PKIdEstudioMercado),
    CONSTRAINT FK_EstudioMercado_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_EstudioMercado_Anio FOREIGN KEY (FKIdAnio_SIS) REFERENCES SIS.Anio(PKIdAnio),
    CONSTRAINT FK_EstudioMercado_Responsable FOREIGN KEY (FKIdResponsable_NOM) REFERENCES NOM.Persona(PKIdPersona),
    CONSTRAINT FK_EstudioMercado_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_EstudioMercado_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- ORCO.EstudioMercadoDetalle
IF OBJECT_ID(N'ORCO.EstudioMercadoDetalle', N'U') IS NULL
BEGIN
CREATE TABLE ORCO.EstudioMercadoDetalle (
    PKIdEstudioMercadoDetalle INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdEstudioMercado_ORCO INT NOT NULL,
    FKIdPAAASDetalle_ORCO INT NOT NULL,
    FKIdTipoBien_ALMA INT NOT NULL,
    Cantidad NUMERIC(8,2) NOT NULL,
    Observaciones NVARCHAR(MAX) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_EstudioMercadoDetalle_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_EstudioMercadoDetalle_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_EstudioMercadoDetalle PRIMARY KEY (PKIdEstudioMercadoDetalle),
    CONSTRAINT FK_EstudioMercadoDetalle_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_EstudioMercadoDetalle_EstudioMercado FOREIGN KEY (FKIdEstudioMercado_ORCO) REFERENCES ORCO.EstudioMercado(PKIdEstudioMercado),
    CONSTRAINT FK_EstudioMercadoDetalle_PAAASDetalle FOREIGN KEY (FKIdPAAASDetalle_ORCO) REFERENCES ORCO.PAAASDetalle(PKIdPAAASDetalle),
    CONSTRAINT FK_EstudioMercadoDetalle_TipoBien FOREIGN KEY (FKIdTipoBien_ALMA) REFERENCES ALMA.TipoBien(PKIdTipoBien),
    CONSTRAINT FK_EstudioMercadoDetalle_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_EstudioMercadoDetalle_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- ORCO.SolicitudCotizacion
IF OBJECT_ID(N'ORCO.SolicitudCotizacion', N'U') IS NULL
BEGIN
CREATE TABLE ORCO.SolicitudCotizacion (
    PKIdSolicitudCotizacion INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdEstudioMercado_ORCO INT NOT NULL,
    FKIdProveedor_SIS INT NOT NULL,
    FechaSolicitud DATETIME NOT NULL,
    FechaCompromisoEntrega DATETIME NULL,
    Comentarios TEXT NULL,
    FL_Documento NVARCHAR(1000) NULL,
    Estatus INT NOT NULL CONSTRAINT DF_SolicitudCotizacion_Estatus DEFAULT (1),
    Activo BIT NOT NULL CONSTRAINT DF_SolicitudCotizacion_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_SolicitudCotizacion_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_SolicitudCotizacion PRIMARY KEY (PKIdSolicitudCotizacion),
    CONSTRAINT FK_SolicitudCotizacion_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_SolicitudCotizacion_EstudioMercado FOREIGN KEY (FKIdEstudioMercado_ORCO) REFERENCES ORCO.EstudioMercado(PKIdEstudioMercado),
    CONSTRAINT FK_SolicitudCotizacion_Proveedor FOREIGN KEY (FKIdProveedor_SIS) REFERENCES SIS.Proveedor(PKIdProveedor),
    CONSTRAINT FK_SolicitudCotizacion_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_SolicitudCotizacion_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- ORCO.EstudioMercadoDetalleCosto
IF OBJECT_ID(N'ORCO.EstudioMercadoDetalleCosto', N'U') IS NULL
BEGIN
CREATE TABLE ORCO.EstudioMercadoDetalleCosto (
    PKIdEstudioMercadoDetalleCosto INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdSolicitudCotizacion_ORCO INT NOT NULL,
    FKIdEstudioMercadoDetalle_ORCO INT NOT NULL,
    PrecioUnitario [dbo].[dmoney] NULL,
    TiempoEntregaDias INT NULL,
    Condiciones NVARCHAR(500) NULL,
    FechaRespuesta DATETIME NULL,
    Activo BIT NOT NULL CONSTRAINT DF_EstudioMercadoDetalleCosto_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_EstudioMercadoDetalleCosto_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_EstudioMercadoDetalleCosto PRIMARY KEY (PKIdEstudioMercadoDetalleCosto),
    CONSTRAINT FK_EstudioMercadoDetalleCosto_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_EstudioMercadoDetalleCosto_SolicitudCotizacion FOREIGN KEY (FKIdSolicitudCotizacion_ORCO) REFERENCES ORCO.SolicitudCotizacion(PKIdSolicitudCotizacion),
    CONSTRAINT FK_EstudioMercadoDetalleCosto_EstudioMercadoDetalle FOREIGN KEY (FKIdEstudioMercadoDetalle_ORCO) REFERENCES ORCO.EstudioMercadoDetalle(PKIdEstudioMercadoDetalle),
    CONSTRAINT FK_EstudioMercadoDetalleCosto_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_EstudioMercadoDetalleCosto_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);

END
GO

-- =============================================
-- ALTER TABLE PARA CLAVES FORANEAS DE AUDITORIA
-- =============================================

IF OBJECT_ID(N'SIS.FK_Empresa_UsuarioCreacion', N'F') IS NULL
    ALTER TABLE SIS.Empresa ADD CONSTRAINT FK_Empresa_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario);
IF OBJECT_ID(N'SIS.FK_Empresa_UsuarioModificacion', N'F') IS NULL
    ALTER TABLE SIS.Empresa ADD CONSTRAINT FK_Empresa_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario);

GO

IF OBJECT_ID(N'SIS.FK_Sucursal_UsuarioCreacion', N'F') IS NULL
    ALTER TABLE SIS.Sucursal ADD CONSTRAINT FK_Sucursal_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario);
IF OBJECT_ID(N'SIS.FK_Sucursal_UsuarioModificacion', N'F') IS NULL
    ALTER TABLE SIS.Sucursal ADD CONSTRAINT FK_Sucursal_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario);

GO

IF OBJECT_ID(N'SIS.FK_Departamento_UsuarioCreacion', N'F') IS NULL
    ALTER TABLE SIS.Departamento ADD CONSTRAINT FK_Departamento_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario);
IF OBJECT_ID(N'SIS.FK_Departamento_UsuarioModificacion', N'F') IS NULL
    ALTER TABLE SIS.Departamento ADD CONSTRAINT FK_Departamento_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario);

GO

IF OBJECT_ID(N'SIS.FK_Usuario_UsuarioCreacion', N'F') IS NULL
    ALTER TABLE SIS.Usuario ADD CONSTRAINT FK_Usuario_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario);
IF OBJECT_ID(N'SIS.FK_Usuario_UsuarioModificacion', N'F') IS NULL
    ALTER TABLE SIS.Usuario ADD CONSTRAINT FK_Usuario_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario);

GO

IF OBJECT_ID(N'SIS.FK_UsuarioSucursal_UsuarioCreacion', N'F') IS NULL
    ALTER TABLE SIS.UsuarioSucursal ADD CONSTRAINT FK_UsuarioSucursal_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario);
IF OBJECT_ID(N'SIS.FK_UsuarioSucursal_UsuarioModificacion', N'F') IS NULL
    ALTER TABLE SIS.UsuarioSucursal ADD CONSTRAINT FK_UsuarioSucursal_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario);

GO

IF OBJECT_ID(N'SIS.FK_UsuarioDepartamento_UsuarioCreacion', N'F') IS NULL
    ALTER TABLE SIS.UsuarioDepartamento ADD CONSTRAINT FK_UsuarioDepartamento_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario);
IF OBJECT_ID(N'SIS.FK_UsuarioDepartamento_UsuarioModificacion', N'F') IS NULL
    ALTER TABLE SIS.UsuarioDepartamento ADD CONSTRAINT FK_UsuarioDepartamento_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario);

GO

IF OBJECT_ID(N'SIS.FK_PerfilUsuario_UsuarioCreacion', N'F') IS NULL
    ALTER TABLE SIS.PerfilUsuario ADD CONSTRAINT FK_PerfilUsuario_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario);
IF OBJECT_ID(N'SIS.FK_PerfilUsuario_UsuarioModificacion', N'F') IS NULL
    ALTER TABLE SIS.PerfilUsuario ADD CONSTRAINT FK_PerfilUsuario_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario);

GO

IF OBJECT_ID(N'SIS.FK_OrigenLogMessage_UsuarioCreacion', N'F') IS NULL
    ALTER TABLE SIS.OrigenLogMessage ADD CONSTRAINT FK_OrigenLogMessage_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario);
IF OBJECT_ID(N'SIS.FK_OrigenLogMessage_UsuarioModificacion', N'F') IS NULL
    ALTER TABLE SIS.OrigenLogMessage ADD CONSTRAINT FK_OrigenLogMessage_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario);

GO

IF OBJECT_ID(N'SIS.FK_SystemParamCatalog_UsuarioCreacion', N'F') IS NULL
    ALTER TABLE SIS.SystemParamCatalog ADD CONSTRAINT FK_SystemParamCatalog_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario);
IF OBJECT_ID(N'SIS.FK_SystemParamCatalog_UsuarioModificacion', N'F') IS NULL
    ALTER TABLE SIS.SystemParamCatalog ADD CONSTRAINT FK_SystemParamCatalog_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario);

GO

IF OBJECT_ID(N'SIS.FK_SystemParamValue_UsuarioCreacion', N'F') IS NULL
    ALTER TABLE SIS.SystemParamValue ADD CONSTRAINT FK_SystemParamValue_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario);
IF OBJECT_ID(N'SIS.FK_SystemParamValue_UsuarioModificacion', N'F') IS NULL
    ALTER TABLE SIS.SystemParamValue ADD CONSTRAINT FK_SystemParamValue_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario);

GO

PRINT 'Base de datos GestionEmpresarial creada exitosamente.';

GO
