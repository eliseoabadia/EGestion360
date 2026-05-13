-- =============================================
-- Script: GP.Sql
-- Description: Full database schema for GestionEmpresarial
-- =============================================

USE [GestionEmpresarial];
GO

-- =============================================
-- ESQUEMAS
-- =============================================
CREATE SCHEMA SIS;
GO
CREATE SCHEMA NOM;
GO
CREATE SCHEMA ALMA;
GO
CREATE SCHEMA CONTA;
GO
CREATE SCHEMA ORCO;
GO
CREATE SCHEMA PRES;
GO
CREATE SCHEMA TES;
GO

-- =============================================
-- TIPO DE DATO PERSONALIZADO
-- =============================================
CREATE TYPE [dbo].[dmoney] FROM [decimal](20, 4) NULL;
GO

-- =============================================
-- TABLAS SIN DEPENDENCIAS DE FK (FASE 1)
-- =============================================

-- dbo.AspNetRoles
CREATE TABLE dbo.AspNetRoles (
    Id NVARCHAR(128) NOT NULL,
    Name NVARCHAR(256) NOT NULL,
    Code NVARCHAR(10),
    CONSTRAINT CONSTRAINT_PK_AspNetRoles PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT CONSTRAINT_UX_AspNetRoles_Name UNIQUE NONCLUSTERED (Name)
);
GO

-- dbo.AspNetClaimTypes
CREATE TABLE dbo.AspNetClaimTypes (
    Id INT IDENTITY(1,1) NOT NULL,
    Name NVARCHAR(50) NOT NULL,
    Created DATETIME NOT NULL,
    CONSTRAINT CONSTRAINT_PK_AspNetClaimTypes PRIMARY KEY CLUSTERED (Id)
);
GO

-- SIS.Idioma
CREATE TABLE SIS.Idioma (
    PKIdIdioma INT IDENTITY(1,1) NOT NULL,
    Nombre NVARCHAR(50) NOT NULL,
    CodigoISO639_1 CHAR(2) NOT NULL,
    NombreNativo NVARCHAR(50) NULL,
    Activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_Idioma PRIMARY KEY CLUSTERED (PKIdIdioma),
    CONSTRAINT UQ_Idioma_Codigo UNIQUE (CodigoISO639_1)
);
GO

-- SIS.Moneda
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
GO

-- SIS.CatTipoSucursal
CREATE TABLE SIS.CatTipoSucursal (
    PKIdTipoSucursal INT IDENTITY(1,1) NOT NULL,
    Descripcion NVARCHAR(50) NOT NULL,
    Activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_TipoSucursal PRIMARY KEY CLUSTERED (PKIdTipoSucursal),
    CONSTRAINT UQ_TipoSucursal_Descripcion UNIQUE (Descripcion)
);
GO

-- SIS.OrigenLogMessage
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
GO

-- SIS.SystemParamCatalog
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
GO

-- SIS.Paises
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
GO

-- SIS.Estados
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
GO

-- SIS.Municipios
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
GO

-- SIS.Empresa
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
ALTER TABLE NOM.Persona
ADD CONSTRAINT FK_Persona_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Persona_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario);
GO

-- FK en Usuario hacia Persona
ALTER TABLE SIS.Usuario
ADD CONSTRAINT FK_Usuario_Persona FOREIGN KEY (FKIdPersona_NOM) REFERENCES NOM.Persona(PKIdPersona);
GO

-- SIS.Anio
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
GO

-- SIS.ActividadInstitucional
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
GO

-- SIS.Capitulo
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
GO

-- SIS.Concepto
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
GO

-- SIS.Partida
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
GO

-- SIS.TipoPoliza
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
GO

-- SIS.TipoDetallePoliza
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
GO

-- SIS.TipoProveedor
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
GO

-- SIS.EstatusProveedor
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
GO
-- SIS.TipoDoctoCLC
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

-- CONTA.TipoCuenta
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
GO

-- CONTA.TipoDoctoPago
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
GO

-- CONTA.Capitulo
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
GO

-- CONTA.Concepto
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
GO

-- CONTA.Partida
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
GO

-- PRES.GF
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
GO

-- PRES.FN
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
GO

-- PRES.SF
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
GO

-- PRES.PP
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
GO

-- PRES.TipoRecurso
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
GO

-- PRES.Sector
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
GO

-- PRES.Ramo
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
GO

-- PRES.PG
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
GO

-- PRES.Programa
CREATE TABLE PRES.Programa (
    PKIdPrograma INT IDENTITY(1,1) NOT NULL,
    Clave NVARCHAR(50) NOT NULL,
    Descripcion NVARCHAR(255) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Programa_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Programa_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Programa PRIMARY KEY (PKIdPrograma),
    CONSTRAINT FK_Programa_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Programa_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

-- PRES.Origen
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
GO

-- PRES.TipoGasto
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
GO

-- PRES.DigitoIdentificador
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
GO

-- PRES.DestinoGasto
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
GO

-- PRES.Suficiencia
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
GO

-- PRES.PY
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
GO

-- ALMA.Nivel
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
GO
-- ALMA.Unidades
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
GO

-- ALMA.Familia
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
GO

-- ALMA.GrupoBien
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
GO

-- ALMA.TipoPatrimonio
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
GO

-- ALMA.Marca
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
GO

-- ALMA.Material
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
GO

-- ALMA.EstadoBien
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
GO

-- ALMA.TipoAdquisicion
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
GO

-- ALMA.EstatusPeriodo
CREATE TABLE ALMA.EstatusPeriodo (
    PKIdEstatusPeriodo INT IDENTITY(1,1) NOT NULL,
    Nombre NVARCHAR(30) NOT NULL,
    Descripcion NVARCHAR(100) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_EstatusPeriodo_Activo DEFAULT (1),
    CONSTRAINT PK_EstatusPeriodo PRIMARY KEY (PKIdEstatusPeriodo),
    CONSTRAINT UQ_EstatusPeriodo_Nombre UNIQUE (Nombre)
);
GO

-- ALMA.TipoConteo
CREATE TABLE ALMA.TipoConteo (
    PKIdTipoConteo INT IDENTITY(1,1) NOT NULL,
    Nombre NVARCHAR(30) NOT NULL,
    Descripcion NVARCHAR(100) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_TipoConteo_Activo DEFAULT (1),
    CONSTRAINT PK_TipoConteo PRIMARY KEY (PKIdTipoConteo)
);
GO

-- ALMA.EstatusArticuloConteo
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
GO

-- ALMA.MotivoES
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
GO

-- ALMA.EstatusSolicitud
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
GO

-- ORCO.Modalidad
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

-- ORCO.TipoContrato
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

-- ORCO.TipoDocumento
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

-- ORCO.TipoGarantia
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

-- ORCO.ProcedimientoContratacion
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

-- ORCO.EstatusRequisicion
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

-- ORCO.Articulo
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

-- ORCO.Fraccion
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

-- ORCO.Proyecto
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
GO

-- TES.TipoInversion
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

-- TES.TipoPago
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

-- TES.TipoPagoSF
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

-- TES.TipoSolicitudCLC
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
-- =============================================
-- TABLAS CON DEPENDENCIAS DE FK (FASE 2)
-- =============================================

-- SIS.EmpresaEstado
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
GO

-- SIS.Sucursal
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
GO

-- SIS.Departamento
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
GO

-- SIS.Area
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
GO

-- TES.TipoMoneda
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

-- TES.TipoCambio
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

-- PRES.FuenteFinanciamiento
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
GO

-- CONTA.CuentaContable
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
GO

-- ALMA.TipoBien
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
GO
-- =============================================
-- TABLAS CON DEPENDENCIAS (FASE 3)
-- =============================================

-- SIS.UsuarioSucursal
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
GO

-- SIS.UsuarioDepartamento
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
GO

-- SIS.Menu
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
GO

-- SIS.MenuRole
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
GO

-- dbo.AspNetClaims
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
GO

-- dbo.AspNetClaimValues
CREATE TABLE dbo.AspNetClaimValues (
    Id INT IDENTITY NOT NULL,
    ClaimId INT,
    Value NVARCHAR(50) NOT NULL,
    Created DATETIME NOT NULL CONSTRAINT CONSTRAINT_DF_AspNetClaimValues_Created DEFAULT GETDATE(),
    CONSTRAINT CONSTRAINT_PK_AspNetClaimValues PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT CONSTRAINT_FK_AspNetClaimValues_Claim FOREIGN KEY (ClaimId) REFERENCES dbo.AspNetClaims(Id)
);
GO

-- dbo.AspNetUsers
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
GO

-- dbo.AspNetUserRoles
CREATE TABLE dbo.AspNetUserRoles (
    UserId NVARCHAR(128) NOT NULL,
    RoleId NVARCHAR(128) NOT NULL,
    ExpireDate DATETIME,
    CONSTRAINT CONSTRAINT_PK_AspNetUserRoles PRIMARY KEY CLUSTERED (UserId, RoleId),
    CONSTRAINT CONSTRAINT_FK_AspNetUserRoles_User FOREIGN KEY (UserId) REFERENCES dbo.AspNetUsers(Id),
    CONSTRAINT CONSTRAINT_FK_AspNetUserRoles_Role FOREIGN KEY (RoleId) REFERENCES dbo.AspNetRoles(Id)
);
GO

-- SIS.PerfilUsuario
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
GO

-- SIS.SystemLog
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
GO

-- SIS.SystemParamValue
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
GO

-- ALMA.PeriodoConteo
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
GO

-- SIS.Proveedor
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
GO

-- NOM.PersonaArea
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
GO

-- PRES.EgresoAutorizado
CREATE TABLE PRES.EgresoAutorizado (
    PKIdEgresoAutorizado INT IDENTITY(1,1) NOT NULL,
    FKIdPrograma_PRES INT NOT NULL,
    FKIdPartida_CONTA INT NOT NULL,
    FKIdArea_SIS INT NOT NULL,
    Descripcion NVARCHAR(250) NULL,
    Fecha DATE NOT NULL,
    FKIdPoliza_CONTA INT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_EgresoAutorizado_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_EgresoAutorizado_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_EgresoAutorizado PRIMARY KEY (PKIdEgresoAutorizado),
    CONSTRAINT FK_EgresoAutorizado_Programa FOREIGN KEY (FKIdPrograma_PRES) REFERENCES PRES.Programa(PKIdPrograma),
    CONSTRAINT FK_EgresoAutorizado_Partida FOREIGN KEY (FKIdPartida_CONTA) REFERENCES CONTA.Partida(PKIdPartida),
    CONSTRAINT FK_EgresoAutorizado_Area FOREIGN KEY (FKIdArea_SIS) REFERENCES SIS.Area(PKIdArea),
    CONSTRAINT FK_EgresoAutorizado_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_EgresoAutorizado_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

-- CONTA.MatrizConversion
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
GO

-- CONTA.MatrizIngreso
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
GO
-- ALMA.Bien
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
GO

-- ALMA.Conteo
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
GO

-- ALMA.ConteoDetalle
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
GO

-- ALMA.ConteoDetalleEscaneo
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
GO

-- ALMA.ConteoHist
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
GO

-- ORCO.Requisicion
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
GO

-- ORCO.DetalleRequisicion
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
GO

-- ORCO.RequisicionPartida
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
GO

-- ORCO.PAAAS
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
GO

-- ORCO.PAAASPartida
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
GO

-- ORCO.PAAASDetalle
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
GO

-- ORCO.EstudioMercado
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
GO

-- ORCO.EstudioMercadoDetalle
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
GO

-- ORCO.SolicitudCotizacion
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
GO

-- ORCO.CotizacionDetalle
CREATE TABLE ORCO.CotizacionDetalle (
    PKIdCotizacionDetalle INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdSolicitudCotizacion_ORCO INT NOT NULL,
    FKIdEstudioMercadoDetalle_ORCO INT NOT NULL,
    PrecioUnitario [dbo].[dmoney] NULL,
    TiempoEntregaDias INT NULL,
    Condiciones NVARCHAR(500) NULL,
    FechaRespuesta DATETIME NULL,
    Activo BIT NOT NULL CONSTRAINT DF_CotizacionDetalle_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_CotizacionDetalle_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_CotizacionDetalle PRIMARY KEY (PKIdCotizacionDetalle),
    CONSTRAINT FK_CotizacionDetalle_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_CotizacionDetalle_SolicitudCotizacion FOREIGN KEY (FKIdSolicitudCotizacion_ORCO) REFERENCES ORCO.SolicitudCotizacion(PKIdSolicitudCotizacion),
    CONSTRAINT FK_CotizacionDetalle_EstudioMercadoDetalle FOREIGN KEY (FKIdEstudioMercadoDetalle_ORCO) REFERENCES ORCO.EstudioMercadoDetalle(PKIdEstudioMercadoDetalle),
    CONSTRAINT FK_CotizacionDetalle_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_CotizacionDetalle_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO
-- =============================================
-- ALTER TABLE PARA CLAVES FORANEAS DE AUDITORIA
-- =============================================

ALTER TABLE SIS.Empresa ADD CONSTRAINT FK_Empresa_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario);
ALTER TABLE SIS.Empresa ADD CONSTRAINT FK_Empresa_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario);
GO

ALTER TABLE SIS.Sucursal ADD CONSTRAINT FK_Sucursal_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario);
ALTER TABLE SIS.Sucursal ADD CONSTRAINT FK_Sucursal_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario);
GO

ALTER TABLE SIS.Departamento ADD CONSTRAINT FK_Departamento_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario);
ALTER TABLE SIS.Departamento ADD CONSTRAINT FK_Departamento_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario);
GO

ALTER TABLE SIS.Usuario ADD CONSTRAINT FK_Usuario_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario);
ALTER TABLE SIS.Usuario ADD CONSTRAINT FK_Usuario_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario);
GO

ALTER TABLE SIS.UsuarioSucursal ADD CONSTRAINT FK_UsuarioSucursal_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario);
ALTER TABLE SIS.UsuarioSucursal ADD CONSTRAINT FK_UsuarioSucursal_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario);
GO

ALTER TABLE SIS.UsuarioDepartamento ADD CONSTRAINT FK_UsuarioDepartamento_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario);
ALTER TABLE SIS.UsuarioDepartamento ADD CONSTRAINT FK_UsuarioDepartamento_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario);
GO

ALTER TABLE SIS.PerfilUsuario ADD CONSTRAINT FK_PerfilUsuario_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario);
ALTER TABLE SIS.PerfilUsuario ADD CONSTRAINT FK_PerfilUsuario_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario);
GO

ALTER TABLE SIS.OrigenLogMessage ADD CONSTRAINT FK_OrigenLogMessage_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario);
ALTER TABLE SIS.OrigenLogMessage ADD CONSTRAINT FK_OrigenLogMessage_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario);
GO

ALTER TABLE SIS.SystemParamCatalog ADD CONSTRAINT FK_SystemParamCatalog_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario);
ALTER TABLE SIS.SystemParamCatalog ADD CONSTRAINT FK_SystemParamCatalog_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario);
GO

ALTER TABLE SIS.SystemParamValue ADD CONSTRAINT FK_SystemParamValue_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario);
ALTER TABLE SIS.SystemParamValue ADD CONSTRAINT FK_SystemParamValue_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario);
GO

PRINT 'Base de datos GestionEmpresarial creada exitosamente.';
GO
