-- =============================================
-- CREACIÓN DE BASE DE DATOS (opcional)
-- =============================================
-- Si la base de datos no existe, créala:
-- IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'GestionEmpresarial')
-- BEGIN
--     CREATE DATABASE GestionEmpresarial;
-- END
-- GO

USE [GestionEmpresarial];
GO

-- =============================================
-- ESQUEMAS
-- =============================================
CREATE SCHEMA SIS;  -- Sistema (catálogos generales)
GO
CREATE SCHEMA NOM;  -- Nómina
GO
CREATE SCHEMA ALMA; -- Almacén
GO
CREATE SCHEMA CONTA; -- Contabilidad
GO
CREATE SCHEMA ORCO;
GO
CREATE SCHEMA PRES;
GO
CREATE SCHEMA TES; --//tesoreria
GO
CREATE SCHEMA HIS;
GO
-- =============================================
-- TIPO DE DATO PERSONALIZADO
-- =============================================
CREATE TYPE [dbo].[dmoney] FROM [decimal](20, 4) NULL;
GO

-- =============================================
-- CATÁLOGOS BASE
-- =============================================

-- Tabla de Idiomas
CREATE TABLE SIS.Idioma (
    PKIdIdioma INT IDENTITY(1,1) NOT NULL,
    Nombre NVARCHAR(50) NOT NULL,
    CodigoISO639_1 CHAR(2) NOT NULL,
    NombreNativo NVARCHAR(50) NULL,
    Activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_Idioma PRIMARY KEY CLUSTERED (PKIdIdioma),
    CONSTRAINT UQ_Idioma_Codigo UNIQUE (CodigoISO639_1)
);

-- Tabla de Monedas
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

-- Tabla de Países
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

-- Tabla de Estados
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

-- Tabla de Municipios
CREATE TABLE SIS.Municipios (
    PKIdMunicipio INT IDENTITY(1,1) NOT NULL,
    FKIdEstado_SIS INT NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    CodigoMunicipio VARCHAR(10) NULL,
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT PK_Municipios PRIMARY KEY CLUSTERED (PKIdMunicipio),
    CONSTRAINT FK_Municipios_Estados FOREIGN KEY (FKIdEstado_SIS) REFERENCES SIS.Estados(PKIdEstado)
    -- CONSTRAINT UQ_Municipios_Estado_Nombre UNIQUE (FKIdEstado_SIS, Nombre)  -- Comentada según original
);

-- =============================================
-- ESTRUCTURA DE EMPRESA
-- =============================================

-- Tabla de Empresa
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
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Empresa PRIMARY KEY CLUSTERED (PKIdEmpresa),
    CONSTRAINT FK_Empresa_Moneda FOREIGN KEY (FKIdMonedaBase_SIS) REFERENCES SIS.Moneda(PKIdMoneda),
    CONSTRAINT FK_Empresa_Idioma FOREIGN KEY (FKIdIdiomaPreferido_SIS) REFERENCES SIS.Idioma(PKIdIdioma),
    CONSTRAINT UQ_Empresa_RFC UNIQUE (RFC)
);

-- Tabla de relación Empresa-Estado (dónde opera la empresa)
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

-- Catálogo de Tipos de Sucursal
CREATE TABLE SIS.CatTipoSucursal (
    PKIdTipoSucursal INT IDENTITY(1,1) NOT NULL,
    Descripcion NVARCHAR(50) NOT NULL,
    Activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_TipoSucursal PRIMARY KEY CLUSTERED (PKIdTipoSucursal),
    CONSTRAINT UQ_TipoSucursal_Descripcion UNIQUE (Descripcion)
);

-- Tabla de Sucursal
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

-- Tabla de Departamento
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

-- =============================================
-- USUARIOS (Integración con ASP.NET Identity)
-- =============================================

-- =============================================
-- 6. NOM.Persona (desde RHCT.Persona)
-- =============================================
-- Tabla Persona
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

-- Tabla Usuario
CREATE TABLE SIS.Usuario (
    PkIdUsuario INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdPersona_NOM INT NOT NULL,
    AspNetUserId NVARCHAR(450) NOT NULL,
    PayrollID NVARCHAR(20) NOT NULL,
    FKIdIdiomaPreferido_SIS INT NULL,
    FKIdMonedaPreferida_SIS INT NULL,
    EsAdministrador BIT NOT NULL DEFAULT 0,
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Usuario PRIMARY KEY (PkIdUsuario),
    CONSTRAINT FK_Usuario_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_Usuario_Idioma FOREIGN KEY (FKIdIdiomaPreferido_SIS) REFERENCES SIS.Idioma(PKIdIdioma),
    CONSTRAINT FK_Usuario_Moneda FOREIGN KEY (FKIdMonedaPreferida_SIS) REFERENCES SIS.Moneda(PKIdMoneda),
    CONSTRAINT UQ_Usuario_AspNetUserId UNIQUE (AspNetUserId),
    CONSTRAINT UQ_Usuario_PayrollID UNIQUE (PayrollID)
);
GO

-- FK en Persona hacia Usuario
ALTER TABLE NOM.Persona
ADD CONSTRAINT FK_Persona_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Persona_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario);

-- FK en Usuario hacia Persona
ALTER TABLE SIS.Usuario
ADD CONSTRAINT FK_Usuario_Persona FOREIGN KEY (FKIdPersona_NOM) REFERENCES NOM.Persona(PKIdPersona);
GO

--update sis.usuario  set FKIdPersona_NOM = 9997 where pkIdUsuario = 1 

--ALTER TABLE SIS.Usuario ADD FKIdPersona_NOM INT NULL;
--ALTER TABLE SIS.Usuario ADD CONSTRAINT FK_Usuario_Persona FOREIGN KEY (FKIdPersona_NOM) REFERENCES NOM.Persona(PKIdPersona);
-- =============================================
-- RELACIONES USUARIO-SUCURSAL-DEPARTAMENTO
-- =============================================

-- Relación Usuario-Sucursal (acceso directo a sucursales)
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

-- Relación Usuario-Departamento (solo relación, SIN permisos duplicados)
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

-- =============================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- =============================================

--CREATE INDEX IX_Usuario_Empresa ON SIS.Usuario(FKIdEmpresa_SIS) INCLUDE (Nombre, ApellidoPaterno, Email) WHERE Activo = 1;
--CREATE INDEX IX_Usuario_AspNetUserId ON SIS.Usuario(AspNetUserId) INCLUDE (PkIdUsuario, FKIdEmpresa_SIS);
--CREATE INDEX IX_Usuario_Email ON SIS.Usuario(Email) INCLUDE (Activo) WHERE Activo = 1;

----CREATE INDEX IX_UsuarioSucursal_Usuario ON SIS.UsuarioSucursal(FKIdUsuario_SIS) INCLUDE (FKIdSucursal_SIS, PuedeAcceder) WHERE Activo = 1;
----CREATE INDEX IX_UsuarioSucursal_Sucursal ON SIS.UsuarioSucursal(FKIdSucursal_SIS) INCLUDE (FKIdUsuario_SIS) WHERE Activo = 1;

----drop index  IX_UsuarioDepartamento_Usuario
----drop index IX_UsuarioDepartamento_Departamento
----CREATE INDEX IX_UsuarioDepartamento_Usuario ON SIS.UsuarioDepartamento(FKIdUsuario_SIS) INCLUDE (FKIdDepartamento_SIS, EsJefe) WHERE Activo = 1;
----CREATE INDEX IX_UsuarioDepartamento_Departamento ON SIS.UsuarioDepartamento(FKIdDepartamento_SIS) INCLUDE (FKIdUsuario_SIS) WHERE Activo = 1;

--CREATE INDEX IX_Sucursal_Empresa ON SIS.Sucursal(FKIdEmpresa_SIS) INCLUDE (Nombre, CodigoSucursal, Ciudad) WHERE Activo = 1;
--CREATE INDEX IX_Departamento_Empresa ON SIS.Departamento(FKIdEmpresa_SIS) INCLUDE (Nombre) WHERE Activo = 1;
--CREATE INDEX IX_Departamento_Sucursal ON SIS.Departamento(FKIdSucursal_SIS) INCLUDE (Nombre) WHERE Activo = 1;

-- =============================================
-- TABLAS DE ASP.NET IDENTITY
-- =============================================

/*  ---------------------------------------------------------------------------                   ------------------------------------------------------------------------*/
/*
user:ADMIN001
pasword: Tecno.2025
*/
/*  ---------------------------------------------------------------------------                   ------------------------------------------------------------------------*/

-- Roles
CREATE TABLE dbo.AspNetRoles (
    Id NVARCHAR(128) NOT NULL,
    Name NVARCHAR(256) NOT NULL,
    Code NVARCHAR(10),
    CONSTRAINT CONSTRAINT_PK_AspNetRoles PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT CONSTRAINT_UX_AspNetRoles_Name UNIQUE NONCLUSTERED (Name)
);
GO

INSERT INTO [dbo].[AspNetRoles] ([Id], [Name], [Code]) VALUES 
('71804e93-9753-4684-84fd-cf037349c111', 'SYSTEMADMIN', '10000'),
('739CC754-488B-4BB4-B7FB-62F6BF3C26D0', 'SOPORTE', '20000'),
('67A6E679-DBC4-402D-AE6E-7F28DDB11BD8', 'CONFIGURATION', '30000');

/* user */
INSERT INTO [dbo].[AspNetUsers]
([Id],[Email],[EmailConfirmed],[PasswordHash],[SecurityStamp],[PhoneNumber],[PhoneNumberConfirmed],[TwoFactorEnabled],[LockoutEndDateUtc],[LockoutEnabled],[AccessFailedCount]
,[ReferenceId],[AccessNumber],[PkIdUsuario])
VALUES (NEWID(),'',1,'UOxg2B7HCZwZZ/drSkwHrA==','C5F91B8B-9E25-4576-96E7-CD3317F1AB87',null,0,0,null,0,0,10000,'0000010000',1)

-- Claim Types
CREATE TABLE dbo.AspNetClaimTypes (
    Id INT IDENTITY(1,1) NOT NULL,
    Name NVARCHAR(50) NOT NULL,
    Created DATETIME NOT NULL,
    CONSTRAINT CONSTRAINT_PK_AspNetClaimTypes PRIMARY KEY CLUSTERED (Id)
);
GO

INSERT INTO dbo.AspNetClaimTypes (Name, Created) VALUES ('Template', GETDATE()), ('Role', GETDATE());

-- Claims
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

-- Insert claims (role-independientes)
-- =====================================================================
INSERT INTO dbo.AspNetClaims (ClaimTypeId, Name, [Group], RoleId, TokenFormat, Created, SubGroup, Code, [Description], [Values], ReferenceId)
VALUES 
(2, 'Configuracion', 'Configuracion', NULL, 'app://{0}/{1}', GETDATE(), 'Configuracion', 'CON001', 'Configuracion', 'view,view-menu', 1),
(2, 'Presupuesto', 'Presupuesto', NULL, 'app://{0}/{1}', GETDATE(), 'Presupuesto', 'PRE001', 'Presupuesto', 'view,view-menu', 2),
(2, 'Contabilidad', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Contabilidad', 'CTB001', 'Contabilidad', 'view,view-menu', 3),
(2, 'Adquisiciones', 'Adquisiciones', NULL, 'app://{0}/{1}', GETDATE(), 'Adquisiciones', 'ADQ001', 'Adquisiciones', 'view,view-menu', 4),
(2, 'Patrimonio', 'Patrimonio', NULL, 'app://{0}/{1}', GETDATE(), 'Patrimonio', 'PAT001', 'Patrimonio', 'view,view-menu', 5),
(2, 'Almacen', 'Almacen', NULL, 'app://{0}/{1}', GETDATE(), 'Almacen', 'ALM001', 'Almacen', 'view,view-menu', 6),
(2, 'Reportes CxC', 'Reportes CxC', NULL, 'app://{0}/{1}', GETDATE(), 'Reportes CxC', 'RPT001', 'Reportes CxC', 'view,view-menu', 7),
(2, 'Nomina', 'Nomina', NULL, 'app://{0}/{1}', GETDATE(), 'Nomina', 'NOM001', 'Nomina', 'view,view-menu', 8),
(2, 'PRB', 'PRB', NULL, 'app://{0}/{1}', GETDATE(), 'PRB', 'PRB001', 'PRB', 'view,view-menu', 9),
(2, 'Ayuda', 'Ayuda', NULL, 'app://{0}/{1}', GETDATE(), 'Ayuda', 'HLP001', 'Ayuda', 'view,view-menu', 10),

(2, 'Configuracion', 'Configuracion', NULL, 'app://{0}/{1}', GETDATE(), 'Sistema', 'CONSIS01', 'Sistema', 'view,view-menu', 20),
(2, 'Configuracion', 'Sistema', NULL, 'app://{0}/{1}', GETDATE(), 'MiPerfil', 'CONSISS01', 'Mi Perfil', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Sistema', NULL, 'app://{0}/{1}', GETDATE(), 'Usuario', 'CONSISS02', 'Usuario', 'view,view-menu,delete,new,update,CanExportToExcel', 21),
(2, 'Configuracion', 'Sistema', NULL, 'app://{0}/{1}', GETDATE(), 'Menu', 'CONSISS03', 'Menú', 'view,view-menu,delete,new,update,CanExportToExcel', 22),
(2, 'Configuracion', 'Sistema', NULL, 'app://{0}/{1}', GETDATE(), 'General', 'CONSISS04', 'General', 'view,view-menu,delete,new,update,CanExportToExcel', 23),
(2, 'Configuracion', 'Sistema', NULL, 'app://{0}/{1}', GETDATE(), 'Empresa', 'CONSISS05', 'Empresa', 'view,view-menu,delete,new,update,CanExportToExcel', 24),
(2, 'Configuracion', 'Sistema', NULL, 'app://{0}/{1}', GETDATE(), 'Departamento', 'CONSISS06', 'Departamento', 'view,view-menu,delete,new,update,CanExportToExcel', 25),

(2, 'Configuracion', 'Configuracion', NULL, 'app://{0}/{1}', GETDATE(), 'Catalogos_presupuestales', 'CONCP01', 'Presupuestales', 'view,view-menu', 30),
(2, 'Configuracion', 'Catalogos_presupuestales', NULL, 'app://{0}/{1}', GETDATE(), 'Programas_Presupuestales', 'CONCPS01', 'Programas Presupuestales', 'view,view-menu,delete,new,update,CanExportToExcel', 31),
(2, 'Configuracion', 'Catalogos_presupuestales', NULL, 'app://{0}/{1}', GETDATE(), 'ClavePrograma', 'CONCPCP01', 'Clave del Programa', 'view,view-menu', 32),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'UnidadResponsable', 'CONCPCPS01', 'Unidad Responsable', 'view,view-menu,delete,new,update,CanExportToExcel', 33),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'Finalidad', 'CONCPCPS02', 'Finalidad', 'view,view-menu,delete,new,update,CanExportToExcel', 34),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'Funcion', 'CONCPCPS03', 'Función', 'view,view-menu,delete,new,update,CanExportToExcel', 35),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'SubFuncion', 'CONCPCPS04', 'SubFunción', 'view,view-menu,delete,new,update,CanExportToExcel', 36),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'Actividad_Institucional', 'CONCPCPS05', 'Actividad Institucional', 'view,view-menu,delete,new,update,CanExportToExcel', 37),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'Programa_Presupuestal', 'CONCPCPS06', 'Programa Presupuestal', 'view,view-menu,delete,new,update,CanExportToExcel', 38),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'Anios', 'CONCPCPS07', 'Años', 'view,view-menu,delete,new,update,CanExportToExcel', 39),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'Sector', 'CONCPCPS08', 'Sector', 'view,view-menu,delete,new,update,CanExportToExcel', 40),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'TipoRecurso', 'CONCPCPS09', 'Tipo Recurso', 'view,view-menu,delete,new,update,CanExportToExcel', 41),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'Fuente_Financiamiento', 'CONCPCPS10', 'Fuente Financiamiento', 'view,view-menu,delete,new,update,CanExportToExcel', 42),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'PG', 'CONCPCPS11', 'PG', 'view,view-menu,delete,new,update,CanExportToExcel', 43),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'Ramo', 'CONCPCPS12', 'Ramo', 'view,view-menu,delete,new,update,CanExportToExcel', 44),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'Proyecto', 'CONCPCPS13', 'Proyecto', 'view,view-menu,delete,new,update,CanExportToExcel', 45),

(2, 'Configuracion', 'Catalogos_presupuestales', NULL, 'app://{0}/{1}', GETDATE(), 'Contabilidad', 'CONCPC01', 'Contabilidad', 'view,view-menu', 50),
(2, 'Configuracion', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_Polizas', 'CONCPCS01', 'Tipo Pólizas', 'view,view-menu,delete,new,update,CanExportToExcel', 51),
(2, 'Configuracion', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_detalles_Polizas', 'CONCPCS02', 'Tipo Detalles Pólizas', 'view,view-menu,delete,new,update,CanExportToExcel', 52),
(2, 'Configuracion', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Matriz_Conversion', 'CONCPCS03', 'Matriz Conversión', 'view,view-menu,delete,new,update,CanExportToExcel', 53),
(2, 'Configuracion', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Matriz_Conversion_Ingresos', 'CONCPCS04', 'Matriz Conversión Ingresos', 'view,view-menu,delete,new,update,CanExportToExcel', 54),
(2, 'Configuracion', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Partidas_Presupuestales', 'CONCPCS05', 'Partidas Presupuestales', 'view,view-menu,delete,new,update,CanExportToExcel', 55),
(2, 'Configuracion', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Cuentas_Contables', 'CONCPCS06', 'Cuentas Contables', 'view,view-menu,delete,new,update,CanExportToExcel', 56),
(2, 'Configuracion', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Formas_Pago', 'CONCPCS07', 'Formas Pago', 'view,view-menu,delete,new,update,CanExportToExcel', 57),

(2, 'Configuracion', 'Configuracion', NULL, 'app://{0}/{1}', GETDATE(), 'Adquisiciones', 'CONAD01', 'Adquisiciones', 'view,view-menu', 70),
(2, 'Configuracion', 'Adquisiciones', NULL, 'app://{0}/{1}', GETDATE(), 'Modalidad', 'CONADS01', 'Modalidad', 'view,view-menu,delete,new,update,CanExportToExcel', 71),
(2, 'Configuracion', 'Adquisiciones', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_Contrato', 'CONADS02', 'Tipo de Contrato', 'view,view-menu,delete,new,update,CanExportToExcel', 72),
(2, 'Configuracion', 'Adquisiciones', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_Documentos', 'CONADS03', 'Tipo de Documentos', 'view,view-menu,delete,new,update,CanExportToExcel', 73),
(2, 'Configuracion', 'Adquisiciones', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_Garantia', 'CONADS04', 'Tipo de Garantí­a', 'view,view-menu,delete,new,update,CanExportToExcel', 74),
(2, 'Configuracion', 'Adquisiciones', NULL, 'app://{0}/{1}', GETDATE(), 'Procedimientos_Contratacion', 'CONADS05', 'Procedimientos de Contratación', 'view,view-menu,delete,new,update,CanExportToExcel', 75),
(2, 'Configuracion', 'Adquisiciones', NULL, 'app://{0}/{1}', GETDATE(), 'Estatus_Requisicion', 'CONADS06', 'Estatus Requisición', 'view,view-menu,delete,new,update,CanExportToExcel', 76),
(2, 'Configuracion', 'Adquisiciones', NULL, 'app://{0}/{1}', GETDATE(), 'Proveedores', 'CONADS07', 'Proveedores', 'view,view-menu,delete,new,update,CanExportToExcel', 77),
(2, 'Configuracion', 'Adquisiciones', NULL, 'app://{0}/{1}', GETDATE(), 'Articulo', 'CONADS08', 'Artí­culo', 'view,view-menu,delete,new,update,CanExportToExcel', 78),
(2, 'Configuracion', 'Adquisiciones', NULL, 'app://{0}/{1}', GETDATE(), 'Fraccion', 'CONADS09', 'Fracción', 'view,view-menu,delete,new,update,CanExportToExcel', 79),

(2, 'Configuracion', 'Configuracion', NULL, 'app://{0}/{1}', GETDATE(), 'Patrimonio', 'CONP01', 'Patrimonio', 'view,view-menu', 90),
(2, 'Configuracion', 'Patrimonio', NULL, 'app://{0}/{1}', GETDATE(), 'Familia', 'CONPS01', 'Familia', 'view,view-menu,delete,new,update,CanExportToExcel', 91),
(2, 'Configuracion', 'Patrimonio', NULL, 'app://{0}/{1}', GETDATE(), 'Grupo_Bien', 'CONPS02', 'Grupo Bien', 'view,view-menu,delete,new,update,CanExportToExcel', 92),
(2, 'Configuracion', 'Patrimonio', NULL, 'app://{0}/{1}', GETDATE(), 'Bienes_Servicios', 'CONPS03', 'Bienes y Servicios', 'view,view-menu,delete,new,update,CanExportToExcel', 93),
(2, 'Configuracion', 'Patrimonio', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_Patrimonio', 'CONPS04', 'Tipo de Patrimonio', 'view,view-menu,delete,new,update,CanExportToExcel', 94),
(2, 'Configuracion', 'Patrimonio', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_Adquisicion', 'CONPS05', 'Tipo de Adquisición', 'view,view-menu,delete,new,update,CanExportToExcel', 95),
(2, 'Configuracion', 'Patrimonio', NULL, 'app://{0}/{1}', GETDATE(), 'Marca', 'CONPS06', 'Marca', 'view,view-menu,delete,new,update,CanExportToExcel', 96),
(2, 'Configuracion', 'Patrimonio', NULL, 'app://{0}/{1}', GETDATE(), 'Personas', 'CONPS07', 'Personas', 'view,view-menu,delete,new,update,CanExportToExcel', 97),

(2, 'Configuracion', 'Configuracion', NULL, 'app://{0}/{1}', GETDATE(), 'Almacen', 'CONAL01', 'Almacén', 'view,view-menu', 100),
(2, 'Configuracion', 'Almacen', NULL, 'app://{0}/{1}', GETDATE(), 'Movimiento_Entrada_Salida', 'CONALS01', 'Motivo de Entradas Salidas', 'view,view-menu,delete,new,update,CanExportToExcel', 101),
(2, 'Configuracion', 'Almacen', NULL, 'app://{0}/{1}', GETDATE(), 'Estatus_Solicitud', 'CONALS02', 'Estatus Solicitud', 'view,view-menu,delete,new,update,CanExportToExcel', 102),
(2, 'Configuracion', 'Almacen', NULL, 'app://{0}/{1}', GETDATE(), 'Unidades', 'CONALS03', 'Unidades', 'view,view-menu,delete,new,update,CanExportToExcel', 103),
(2, 'Configuracion', 'Almacen', NULL, 'app://{0}/{1}', GETDATE(), 'Conteo_Periodo', 'CONALS04', 'Periodo de Conteo', 'view,view-menu,delete,new,update,CanExportToExcel', 104),
(2, 'Configuracion', 'Almacen', NULL, 'app://{0}/{1}', GETDATE(), 'Familia', 'CONALS05', 'Familia', 'view,view-menu,delete,new,update,CanExportToExcel', 105),
(2, 'Configuracion', 'Almacen', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_Bien', 'CONALS06', 'Tipo Bien', 'view,view-menu,delete,new,update,CanExportToExcel', 106),
(2, 'Configuracion', 'Almacen', NULL, 'app://{0}/{1}', GETDATE(), 'Bien', 'CONALS07', 'Bien', 'view,view-menu,delete,new,update,CanExportToExcel', 107),
(2, 'Configuracion', 'Almacen', NULL, 'app://{0}/{1}', GETDATE(), 'Numero_Conteo', 'CONALS08', 'Número Conteo', 'view,view-menu,delete,new,update,CanExportToExcel', 108),

(2, 'Configuracion', 'Configuracion', NULL, 'app://{0}/{1}', GETDATE(), 'Tesoreria', 'CONT01', 'Tesorerí­a', 'view,view-menu', 120),
(2, 'Configuracion', 'Tesoreria', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_Cambio', 'CONTS01', 'Tipo de Cambio', 'view,view-menu,delete,new,update,CanExportToExcel', 121),
(2, 'Configuracion', 'Tesoreria', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_Inversion', 'CONTS02', 'Tipo Inversión', 'view,view-menu,delete,new,update,CanExportToExcel', 122),
(2, 'Configuracion', 'Tesoreria', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_Moneda', 'CONTS03', 'Tipo Moneda', 'view,view-menu,delete,new,update,CanExportToExcel', 123),
(2, 'Configuracion', 'Tesoreria', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_Pago', 'CONTS04', 'Tipo de Pago', 'view,view-menu,delete,new,update,CanExportToExcel', 124),
(2, 'Configuracion', 'Tesoreria', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_PagoSF', 'CONTS05', 'Tipo de Pago SF', 'view,view-menu,delete,new,update,CanExportToExcel', 125),
(2, 'Configuracion', 'Tesoreria', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_SolicitudCLC', 'CONTS06', 'Tipo Solicitud CLC', 'view,view-menu,delete,new,update,CanExportToExcel', 126),
(2, 'Configuracion', 'Tesoreria', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_DoctoCLC', 'CONTS07', 'Tipo Documento CLC', 'view,view-menu,delete,new,update,CanExportToExcel', 127),

--ESTAS NO VAN AQUI
(2, 'Adquisiciones', 'Adquisiciones', NULL, 'app://{0}/{1}', GETDATE(), 'Programa_Anual_Adquisiciones', 'ADQPAA01', 'Adquisiciones', 'view,view-menu,delete,new,update', 0),
(2, 'Adquisiciones', 'Adquisiciones', NULL, 'app://{0}/{1}', GETDATE(), 'Requisicion', 'ADQREQ01', 'Adquisiciones', 'view,view-menu,delete,new,update,CanExportToExcel,authorize', 0),
(2, 'Adquisiciones', 'Adquisiciones', NULL, 'app://{0}/{1}', GETDATE(), 'Cotizacion', 'ADQCOT01', 'Adquisiciones', 'view,view-menu,delete,new,update,CanExportToExcel,authorize', 0),
(2, 'Adquisiciones', 'Adquisiciones', NULL, 'app://{0}/{1}', GETDATE(), 'SolicitudSuficiencia', 'ADQSUF01', 'Adquisiciones', 'view,view-menu,delete,new,update,CanExportToExcel,authorize', 0),
(2, 'Adquisiciones', 'Adquisiciones', NULL, 'app://{0}/{1}', GETDATE(), 'OrdenCompra', 'ADQORD01', 'Adquisiciones', 'view,view-menu,delete,new,update,CanExportToExcel,authorize', 0),
(2, 'Adquisiciones', 'Adquisiciones', NULL, 'app://{0}/{1}', GETDATE(), 'Contratos', 'ADQCON01', 'Adquisiciones', 'view,view-menu', 310),
(2, 'Adquisiciones', 'Contratos', NULL, 'app://{0}/{1}', GETDATE(), 'Registro_Compromiso', 'ADQCONRC01', 'Registro de Compromiso', 'view,view-menu,delete,new,update,CanExportToExcel',311),
(2, 'Adquisiciones', 'Contratos', NULL, 'app://{0}/{1}', GETDATE(), 'Saldos_Contratos', 'ADQCONSC01', 'Saldos de Contratos', 'view,view-menu,delete,new,update,CanExportToExcel', 312),
(2, 'Adquisiciones', 'Contratos', NULL, 'app://{0}/{1}', GETDATE(), 'Estado_Contrato', 'ADQCONEC01', 'Estado de Contratos', 'view,view-menu,delete,new,update,CanExportToExcel', 313),
--HASTA AQUI ESTA MAL

(2, 'Presupuesto', 'Presupuesto', NULL, 'app://{0}/{1}', GETDATE(), 'Egreso', 'PREEG01', 'Egreso', 'view,view-menu', 140),
(2, 'Presupuesto', 'Egreso', NULL, 'app://{0}/{1}', GETDATE(), 'Planeacion', 'PREEGP01', 'Planeación', 'view,view-menu', 141),

(2, 'Presupuesto', 'Egreso', NULL, 'app://{0}/{1}', GETDATE(), 'Catalogos_Planeacion', 'PREEGPCP01', 'Catalogos de Planeación', 'view,view-menu', 142),
(2, 'Egreso', 'Catalogos_Planeacion', NULL, 'app://{0}/{1}', GETDATE(), 'Indicadores', 'PREEGPCPS01', 'Indicadores', 'view,view-menu,new,update,delete,CanExportToExcel,authorize', 143),
(2, 'Egreso', 'Catalogos_Planeacion', NULL, 'app://{0}/{1}', GETDATE(), 'Resumen_Narrativo', 'PREEGPCPS02', 'Resúmen Narrativo', 'view,view-menu,new,update,delete,CanExportToExcel,authorize', 144),

(2, 'Egreso', 'Planeacion', NULL, 'app://{0}/{1}', GETDATE(), 'Anteproyecto_Egresos', 'PREEGPS01', 'Anteproyecto de Egresos', 'view,view-menu,delete,new,update,CanExportToExcel,authorize', 145),
--falta autorizacion/desautorizacion de anteproyecto

(2, 'Presupuesto', 'Egreso', NULL, 'app://{0}/{1}', GETDATE(), 'Presupuesto_Disponible', 'PREEGS01', 'Presupuesto Autorizado', 'view,view-menu,delete,new,update,CanExportToExcel,authorize', 146),

(2, 'Presupuesto', 'Egreso', NULL, 'app://{0}/{1}', GETDATE(), 'Presupuesto_Modificado', 'PREEGPM01', 'Presupuesto Modificado', 'view,view-menu', 147),
(2, 'Egreso', 'Presupuesto_Modificado', NULL, 'app://{0}/{1}', GETDATE(), 'Adecuaciones_Compensadas', 'PREEGPMS01', 'Adecuaciones Compensadas', 'view,view-menu,new,update,delete,CanExportToExcel,authorize', 148),
(2, 'Egreso', 'Presupuesto_Modificado', NULL, 'app://{0}/{1}', GETDATE(), 'Ampliaciones', 'PREEGPMS02', 'Adecuaciones', 'view,view-menu,new,update,delete,CanExportToExcel,authorize', 149),
(2, 'Egreso', 'Presupuesto_Modificado', NULL, 'app://{0}/{1}', GETDATE(), 'Reducciones', 'PREEGPMS03', 'Reducciones', 'view,view-menu,new,update,delete,CanExportToExcel,authorize', 150),


(2, 'Presupuesto', 'Egreso', NULL, 'app://{0}/{1}', GETDATE(), 'Presupuesto_Comprometido', 'PREEGS02', 'Presupuesto Disponible PEF', 'view,view-menu,new,update,delete,CanExportToExcel,authorize', 151),

(2, 'Presupuesto', 'Egreso', NULL, 'app://{0}/{1}', GETDATE(), 'Presupuesto_Comprometido', 'PREEGPC01', 'Presupuesto Comprometido', 'view,view-menu', 152),
(2, 'Egreso', 'Presupuesto_Comprometido', NULL, 'app://{0}/{1}', GETDATE(), 'Solicitud_Suficiencia', 'PREEGPCS01', 'Solicitud Suficiencia', 'view,view-menu,new,update,delete,CanExportToExcel,authorize', 153),
(2, 'Egreso', 'Presupuesto_Comprometido', NULL, 'app://{0}/{1}', GETDATE(), 'Autorizacion_Suficiencia', 'PREEGPCS02', 'Autorización Suficiencia', 'view,view-menu,delete,new,update,CanExportToExcel,authorize', 154),
(2, 'Egreso', 'Presupuesto_Comprometido', NULL, 'app://{0}/{1}', GETDATE(), 'Registro_Comprometido', 'PREEGPCS03', 'Registro Comprometido', 'view,view-menu,delete,new,update,CanExportToExcel,authorize', 155),

	
(2, 'Presupuesto', 'Presupuesto', NULL, 'app://{0}/{1}', GETDATE(), 'Tesoreria', 'PRET01', 'Tesorerí­a', 'view,view-menu', 160),
(2, 'Presupuesto', 'Tesoreria', NULL, 'app://{0}/{1}', GETDATE(), 'CuentasXCobrar', 'PRETECC01', 'Cuentas por Cobrar', 'view,view-menu', 161),
(2, 'Tesoreria', 'CuentasXCobrar', NULL, 'app://{0}/{1}', GETDATE(), 'Ley_Ingresos_Estimados', 'PRETECCS01', 'Ley de Ingresos Estimados', 'view,view-menu,delete,new,update,CanExportToExcel,authorize', 162),

(2, 'Tesoreria', 'CuentasXCobrar', NULL, 'app://{0}/{1}', GETDATE(), 'Presupuesto_Modificado', 'PRETCCPM01', 'Modificado de Ingresos', 'view,view-menu', 163),
(2, 'CuentasXCobrar', 'Presupuesto_Modificado', NULL, 'app://{0}/{1}', GETDATE(), 'Adecuaciones_Compensadas', 'PRETCCPMS01', 'Adecuaciones Compensadas de Ingresos', 'view,view-menu,delete,new,update,CanExportToExcel,authorize', 164),
(2, 'CuentasXCobrar', 'Presupuesto_Modificado', NULL, 'app://{0}/{1}', GETDATE(), 'Aumento_Presupuesto', 'PRETCCPMS02', 'Aumentos al presupuesto de Ingresos', 'view,view-menu,delete,new,update,CanExportToExcel,authorize', 165),
(2, 'CuentasXCobrar', 'Presupuesto_Modificado', NULL, 'app://{0}/{1}', GETDATE(), 'Reduccion_Presupuesto', 'PRETCCPMS03', 'Reduccion al presupuesto de Ingresos', 'view,view-menu,delete,new,update,CanExportToExcel,authorize', 166),

(2, 'Tesoreria', 'CuentasXCobrar', NULL, 'app://{0}/{1}', GETDATE(), 'Ingresos_Devengados', 'PRETCCID01', 'Ingresos Devengados', 'view,view-menu', 167),
(2, 'CuentasXCobrar', 'Ingresos_Devengados', NULL, 'app://{0}/{1}', GETDATE(), 'Ingresos', 'PRETCCIDS01', 'Ingresos (CLCs)', 'view,view-menu,delete,new,update,CanExportToExcel,authorize', 168),
(2, 'CuentasXCobrar', 'Ingresos_Devengados', NULL, 'app://{0}/{1}', GETDATE(), 'Ingresos_Propios', 'PRETCCIDS02', 'Ingresos Propios (Recibos y Facturas)', 'view,view-menu,delete,new,update,CanExportToExcel,authorize', 169),

(2, 'Tesoreria', 'CuentasXCobrar', NULL, 'app://{0}/{1}', GETDATE(), 'Ingresos_Recaudar', 'PRETECCS02', 'Ingresos por Recaudar', 'view,view-menu,delete,new,update,CanExportToExcel,authorize', 170),
(2, 'Tesoreria', 'CuentasXCobrar', NULL, 'app://{0}/{1}', GETDATE(), 'Depositos_CLC', 'PRETECCS03', 'Depósitos CLC', 'view,view-menu,delete,new,update,CanExportToExcel,authorize', 171),
(2, 'Tesoreria', 'CuentasXCobrar', NULL, 'app://{0}/{1}', GETDATE(), 'Otros_Ingresos', 'PRETECCS04', 'Otros Ingresos', 'view,view-menu,delete,new,update,CanExportToExcel,authorize', 172),

(2, 'Tesoreria', 'CuentasXCobrar', NULL, 'app://{0}/{1}', GETDATE(), 'Reportes_CxC', 'PRETCCR01', 'Reportes CxC', 'view,view-menu', 173),
(2, 'CuentasXCobrar', 'Reportes_CxC', NULL, 'app://{0}/{1}', GETDATE(), 'Antiguedad_Saldos', 'PRETCCRS01', 'Antigüedad de saldos', 'view,view-menu,delete,new,update,CanExportToExcel,authorize', 174),
(2, 'CuentasXCobrar', 'Reportes_CxC', NULL, 'app://{0}/{1}', GETDATE(), 'Integracion_Saldos', 'PRETCCRS02', 'Integración de saldos', 'view,view-menu,delete,new,update,CanExportToExcel,authorize', 175),
(2, 'CuentasXCobrar', 'Reportes_CxC', NULL, 'app://{0}/{1}', GETDATE(), 'Estado_Cuenta', 'PRETCCRS03', 'Estado de cuenta', 'view,view-menu,delete,new,update,CanExportToExcel,authorize', 176),
(2, 'CuentasXCobrar', 'Reportes_CxC', NULL, 'app://{0}/{1}', GETDATE(), 'Analisis_Saldos', 'PRETCCRS04', 'Análisis de saldos', 'view,view-menu,delete,new,update,CanExportToExcel,authorize', 177),
(2, 'CuentasXCobrar', 'Reportes_CxC', NULL, 'app://{0}/{1}', GETDATE(), 'Consulta_Documentos', 'PRETCCRS05', 'Consulta de documentos', 'view,view-menu,delete,new,update,CanExportToExcel,authorize', 178),
 
(2, 'Presupuesto', 'Tesoreria', NULL, 'app://{0}/{1}', GETDATE(), 'CuentasXPagar', 'PRETCP01', 'Cuentas por Pagar', 'view,view-menu', 190),
(2, 'Tesoreria', 'CuentasXPagar', NULL, 'app://{0}/{1}', GETDATE(), 'PEF_Unipartida_TES', 'PRETCPPUT01', 'PEF Unipartida TES', 'view,view-menu', 191),
(2, 'CuentasXPagar', 'PEF_Unipartida_TES', NULL, 'app://{0}/{1}', GETDATE(), 'RecepcionFactura_ComprobantePago', 'PRETCPPUTS01', 'Recepción de Facturas y Comprobantes de Pago', 'view,view-menu,delete,new,update,CanExportToExcel,authorize', 192),
(2, 'CuentasXPagar', 'PEF_Unipartida_TES', NULL, 'app://{0}/{1}', GETDATE(), 'Provision_Pago', 'PRETCPPUTS02', 'Provisión del Pago', 'view,view-menu,delete,new,update,CanExportToExcel,authorize', 193),
(2, 'CuentasXPagar', 'PEF_Unipartida_TES', NULL, 'app://{0}/{1}', GETDATE(), 'ElaboracionCheque_Transferencia', 'PRETCPPUTS03', 'Elaboración de Cheques o Transferencias', 'view,view-menu,delete,new,update,CanExportToExcel,authorize', 194),

(2, 'Presupuesto', 'Tesoreria', NULL, 'app://{0}/{1}', GETDATE(), 'Planeacion_Gastos', 'PRETS01', 'Planeación de gastos', 'view,view-menu,delete,new,update,CanExportToExcel', 195),
(2, 'Presupuesto', 'Tesoreria', NULL, 'app://{0}/{1}', GETDATE(), 'Saldos_Cuentas', 'PRETS02', 'Saldos Cuentas', 'view,view-menu,delete,new,update,CanExportToExcel', 196),
(2, 'Presupuesto', 'Tesoreria', NULL, 'app://{0}/{1}', GETDATE(), 'Solicitud_Reintegros', 'PRETS03', 'Solicitud de reintegros', 'view,view-menu,delete,new,update,CanExportToExcel', 197),
(2, 'Presupuesto', 'Tesoreria', NULL, 'app://{0}/{1}', GETDATE(), 'Autorizar_Solicitud_Reingresos', 'PRETS04', 'Autorizar solicitud de reingresos', 'view,view-menu,delete,new,update,CanExportToExcel', 198),
(2, 'Presupuesto', 'Tesoreria', NULL, 'app://{0}/{1}', GETDATE(), 'Provision_Pago', 'PRETS05', 'Provisión del Pago', 'view,view-menu,delete,new,update,CanExportToExcel', 199),

(2, 'Presupuesto', 'Tesoreria', NULL, 'app://{0}/{1}', GETDATE(), 'Inversiones', 'PRETI01', 'Inversiones', 'view,view-menu', 200),
(2, 'Tesoreria', 'Inversiones', NULL, 'app://{0}/{1}', GETDATE(), 'Banco', 'PRETIS01', 'Banco', 'view,view-menu,delete,new,update,CanExportToExcel', 201),
(2, 'Tesoreria', 'Inversiones', NULL, 'app://{0}/{1}', GETDATE(), 'Cuenta_Bancaria', 'PRETIS02', 'Cuenta Bancaria', 'view,view-menu,delete,new,update,CanExportToExcel', 202),
(2, 'Tesoreria', 'Inversiones', NULL, 'app://{0}/{1}', GETDATE(), 'Intermediarios_Financiero', 'PRETIS03', 'Intermediarios Financiero', 'view,view-menu,delete,new,update,CanExportToExcel', 203),
(2, 'Tesoreria', 'Inversiones', NULL, 'app://{0}/{1}', GETDATE(), 'Instrumentos_Inversion', 'PRETIS04', 'Instrumentos de Inversión', 'view,view-menu,CanExportToExcel', 204),
(2, 'Tesoreria', 'Inversiones', NULL, 'app://{0}/{1}', GETDATE(), 'Listado_Inversiones', 'PRETIS05', 'Listado de Inversiones', 'view,view-menu,delete,new,update,CanExportToExcel', 205),
(2, 'Tesoreria', 'Inversiones', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_Instrumentos', 'PRETIS06', 'TTipo de Instrumentos', 'view,view-menu,delete,new,update,CanExportToExcel', 206),
(2, 'Tesoreria', 'Inversiones', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_Plazos', 'PRETIS07', 'Tipo de Plazos', 'view,view-menu,delete,new,update,CanExportToExcel', 207),
(2, 'Tesoreria', 'Inversiones', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_Retiro', 'PRETIS08', 'Tipo de Retiro', 'view,view-menu,delete,new,update,CanExportToExcel', 208),
(2, 'Tesoreria', 'Inversiones', NULL, 'app://{0}/{1}', GETDATE(), 'Simulador', 'PRETIS09', 'Simulador', 'view,view-menu,delete,new,update,CanExportToExcel', 209),

(2, 'Contabilidad', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Polizas', 'CTBS01', 'Pólizas', 'view,view-menu,delete,new,update,CanExportToExcel', 220),
(2, 'Contabilidad', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Autorizacion_Polizas', 'CTBS02', 'Autorización de Pólizas', 'view,view-menu,delete,new,update,CanExportToExcel', 221),
(2, 'Contabilidad', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Balanza_Comprobacion', 'CTBS03', 'Balanza de Comprobación', 'view,view-menu,delete,new,update,CanExportToExcel', 222),
(2, 'Contabilidad', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Auxiliares', 'CTBS04', 'Auxiliares', 'view,view-menu,delete,new,update,CanExportToExcel', 223),

(2, 'Contabilidad', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Reportes_Contabilidad', 'CTBRC01', 'Reportes Contabilidad', 'view,view-menu', 224),
(2, 'Contabilidad', 'Reportes_Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Libro_Diario', 'CTBRCS01', 'Libro Diario', 'view,view-menu,delete,new,update,CanExportToExcel', 225),
(2, 'Contabilidad', 'Reportes_Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Libro_Mayor', 'CTBRCS02', 'Libro Mayor', 'view,view-menu,delete,new,update,CanExportToExcel', 226),
(2, 'Contabilidad', 'Reportes_Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Libro_Inventarios_Materiales', 'CTBRCS03', 'Libro Inventarios Materiales', 'view,view-menu,delete,new,update,CanExportToExcel', 227),
(2, 'Contabilidad', 'Reportes_Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Libro_Almacen_Suministros', 'CTBRCS04', 'Libro Almacén Suministros', 'view,view-menu,delete,new,update,CanExportToExcel', 228),
(2, 'Contabilidad', 'Reportes_Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Libro_Inventarios_Muebles', 'CTBRCS05', 'Libro Inventarios Muebles', 'view,view-menu,delete,new,update,CanExportToExcel', 229),
(2, 'Contabilidad', 'Reportes_Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Polizas', 'CTBRCS06', 'Pólizas', 'view,view-menu,delete,new,update,CanExportToExcel', 230),
(2, 'Contabilidad', 'Reportes_Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Reporte_Retenciones', 'CTBRCS07', 'Reporte de Retenciones', 'view,view-menu,delete,new,update,CanExportToExcel', 231),
(2, 'Contabilidad', 'Reportes_Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Reporte_Depreciacion_Acumulada', 'CTBRCS08', 'Reporte de Depreciación Acumulada', 'view,view-menu,delete,new,update,CanExportToExcel', 232),
(2, 'Contabilidad', 'Reportes_Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Reporte_Activos_Fijos', 'CTBRCS09', 'Reporte de Activos Fijos', 'view,view-menu,delete,new,update,CanExportToExcel', 233),
(2, 'Contabilidad', 'Reportes_Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Reporte_Facturas_Emitidas', 'CTBRCS10', 'Reporte de Facturas Emitidas', 'view,view-menu,delete,new,update,CanExportToExcel', 234),
(2, 'Contabilidad', 'Reportes_Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Reporte_DIOT', 'CTBRCS11', 'Reporte DIOT', 'view,view-menu,delete,new,update,CanExportToExcel', 235),

(2, 'Contabilidad', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'EI_Contable', 'CTBEIC01', 'Estados e Información Contable', 'view,view-menu', 236),
(2, 'Contabilidad', 'EI_Contable', NULL, 'app://{0}/{1}', GETDATE(), 'Estados_Actividades', 'CTBEICS01', 'Estados de Actividades', 'view,view-menu,delete,new,update,CanExportToExcel', 237),
(2, 'Contabilidad', 'EI_Contable', NULL, 'app://{0}/{1}', GETDATE(), 'Estado_Situacion_Financiera', 'CTBEICS02', 'Estado de Situación Financiera', 'view,view-menu,delete,new,update,CanExportToExcel', 238),
(2, 'Contabilidad', 'EI_Contable', NULL, 'app://{0}/{1}', GETDATE(), 'Estado_VHP', 'CTBEICS03', 'Estado de Variaciones en la Hacienda Pública', 'view,view-menu,delete,new,update,CanExportToExcel', 239),
(2, 'Contabilidad', 'EI_Contable', NULL, 'app://{0}/{1}', GETDATE(), 'Estados_CSF', 'CTBEICS04', 'Estados de Cambios en la Situación Financiera', 'view,view-menu,delete,new,update,CanExportToExcel', 240),
(2, 'Contabilidad', 'EI_Contable', NULL, 'app://{0}/{1}', GETDATE(), 'Estado_Flujos_Efectivo', 'CTBEICS05', 'Estado de Flujos de Efectivo', 'view,view-menu,delete,new,update,CanExportToExcel', 241),
(2, 'Contabilidad', 'EI_Contable', NULL, 'app://{0}/{1}', GETDATE(), 'Estado_Analitico_Activo', 'CTBEICS06', 'Estado Analítico del Activo', 'view,view-menu,delete,new,update,CanExportToExcel', 242),
(2, 'Contabilidad', 'EI_Contable', NULL, 'app://{0}/{1}', GETDATE(), 'Estado_ADOP', 'CTBEICS07', 'Estado Analítico de la Deuda y Otros Pasivos', 'view,view-menu,delete,new,update,CanExportToExcel', 243),
(2, 'Contabilidad', 'EI_Contable', NULL, 'app://{0}/{1}', GETDATE(), 'Informe_Pasivos_Contingentes', 'CTBEICS08', 'Informe sobre Pasivos Contingentes', 'view,view-menu,delete,new,update,CanExportToExcel', 244),
(2, 'Contabilidad', 'EI_Contable', NULL, 'app://{0}/{1}', GETDATE(), 'Notas_Estados_Financieros', 'CTBEICS09', 'Notas Estados Financieros', 'view,view-menu,delete,new,update,CanExportToExcel', 245),

(2, 'Contabilidad', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Conciliacion_IE', 'CTBS05', 'Conciliación Ingresos-Egresos', 'view,view-menu,delete,new,update,CanExportToExcel', 246),

(2, 'Contabilidad', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'EI_Presupuestarios', 'CTBEIP01', 'Estados e Informes Presupuestarios', 'view,view-menu', 247),
(2, 'Contabilidad', 'EI_Presupuestarios', NULL, 'app://{0}/{1}', GETDATE(), 'Estado_Analitico_Ingresos', 'CTBEIPS01', 'Estado Analítico de Ingresos', 'view,view-menu,delete,new,update,CanExportToExcel', 248),
(2, 'Contabilidad', 'EI_Presupuestarios', NULL, 'app://{0}/{1}', GETDATE(), 'Estado_AECA', 'CTBEIPS02', 'Estado Analítico de Egresos con Clasificación Administrativa', 'view,view-menu,delete,new,update,CanExportToExcel', 249),
(2, 'Contabilidad', 'EI_Presupuestarios', NULL, 'app://{0}/{1}', GETDATE(), 'Estado_AECE', 'CTBEIPS03', 'Estado Analítico de Egresos con Clasificación Económica', 'view,view-menu,delete,new,update,CanExportToExcel', 250),
(2, 'Contabilidad', 'EI_Presupuestarios', NULL, 'app://{0}/{1}', GETDATE(), 'Estado_AECOG', 'CTBEIPS04', 'Estado Analítico de Egresos con Clasificación por Objeto del Gasto', 'view,view-menu,delete,new,update,CanExportToExcel', 251),
(2, 'Contabilidad', 'EI_Presupuestarios', NULL, 'app://{0}/{1}', GETDATE(), 'Estado_AECF', 'CTBEIPS05', 'Estado Analítico de Egresos con Clasificación Funcional', 'view,view-menu,delete,new,update,CanExportToExcel', 252),
(2, 'Contabilidad', 'EI_Presupuestarios', NULL, 'app://{0}/{1}', GETDATE(), 'Endeudamiento_Neto', 'CTBEIPS06', 'Endeudamiento Neto', 'view,view-menu,delete,new,update,CanExportToExcel', 253),
(2, 'Contabilidad', 'EI_Presupuestarios', NULL, 'app://{0}/{1}', GETDATE(), 'Intereses_Deuda', 'CTBEIPS07', 'Intereses de la Deuda', 'view,view-menu,delete,new,update,CanExportToExcel', 254),
(2, 'Contabilidad', 'EI_Presupuestarios', NULL, 'app://{0}/{1}', GETDATE(), 'Proyecciones_Egresos', 'CTBEIPS08', 'Proyecciones de Egresos', 'view,view-menu,delete,new,update,CanExportToExcel', 255),
(2, 'Contabilidad', 'EI_Presupuestarios', NULL, 'app://{0}/{1}', GETDATE(), 'Proyecciones_Ingresos', 'CTBEIPS09', 'Proyecciones de Ingresos', 'view,view-menu,delete,new,update,CanExportToExcel', 256),
(2, 'Contabilidad', 'EI_Presupuestarios', NULL, 'app://{0}/{1}', GETDATE(), 'Indicadores_APP', 'CTBEIPS10', 'Indicadores Asociados a Programas Presupuestarios', 'view,view-menu,delete,new,update,CanExportToExcel', 257),
(2, 'Contabilidad', 'EI_Presupuestarios', NULL, 'app://{0}/{1}', GETDATE(), 'Pp_Inversion', 'CTBEIPS11', 'Programas y proyectos de Inversión', 'view,view-menu,delete,new,update,CanExportToExcel', 258),
(2, 'Contabilidad', 'EI_Presupuestarios', NULL, 'app://{0}/{1}', GETDATE(), 'Resultados_Ingresos', 'CTBEIPS12', 'Resultados de Ingresos', 'view,view-menu,delete,new,update,CanExportToExcel', 259),
(2, 'Contabilidad', 'EI_Presupuestarios', NULL, 'app://{0}/{1}', GETDATE(), 'Resultados_Egresos', 'CTBEIPS13', 'Resultados de Egresos', 'view,view-menu,delete,new,update,CanExportToExcel', 260),

(2, 'Contabilidad', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'EI_Programaticos', 'CTBS06', 'Estados e Informes Programaticos', 'view,view-menu,delete,new,update,CanExportToExcel', 261),
(2, 'Contabilidad', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Indicadores_Postura_Fiscal', 'CTBS07', 'Indicadores de Postura Fiscal', 'view,view-menu,delete,new,update,CanExportToExcel', 262),
(2, 'Contabilidad', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Cierre_Mensual', 'CTBS08', 'Cierre Mensual', 'view,view-menu,delete,new,update,CanExportToExcel', 263),
--HASTA AQUI VOY BIEN


(2, 'Patrimonio', 'Patrimonio', NULL, 'app://{0}/{1}', GETDATE(), 'Bienes', 'PATBIEN001', 'Patrimonio', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Patrimonio', 'Patrimonio', NULL, 'app://{0}/{1}', GETDATE(), 'Clasificacion_Bienes_Muebles', 'PATBIEN002', 'Patrimonio', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Patrimonio', 'Patrimonio', NULL, 'app://{0}/{1}', GETDATE(), 'Bajas', 'PATBIEN003', 'Patrimonio', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Patrimonio', 'Patrimonio', NULL, 'app://{0}/{1}', GETDATE(), 'Calendario_Inventarios', 'PATBIEN004', 'Patrimonio', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Patrimonio', 'Patrimonio', NULL, 'app://{0}/{1}', GETDATE(), 'Inventarios', 'PATBIEN005', 'Patrimonio', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Patrimonio', 'Patrimonio', NULL, 'app://{0}/{1}', GETDATE(), 'Cedula_Diferencia', 'PATBIEN006', 'Patrimonio', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Patrimonio', 'Patrimonio', NULL, 'app://{0}/{1}', GETDATE(), 'Resguardos', 'PATBIEN007', 'Patrimonio', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Patrimonio', 'Patrimonio', NULL, 'app://{0}/{1}', GETDATE(), 'Firma_Resguardos', 'PATBIEN008', 'Patrimonio', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Patrimonio', 'Patrimonio', NULL, 'app://{0}/{1}', GETDATE(), 'Resguardo_Historico', 'PATBIEN008', 'Patrimonio', 'view,view-menu,delete,new,update,CanExportToExcel', 0),

(2, 'Almacen', 'Almacen', NULL, 'app://{0}/{1}', GETDATE(), 'Recepcion_Pedidos', 'AL0001', 'Almacen', 'view,view-menu', 0),
(2, 'Almacen', 'Almacen', NULL, 'app://{0}/{1}', GETDATE(), 'Entradas_Ajuste', 'AL0002', 'Almacen', 'view,view-menu', 0),
(2, 'Almacen', 'Almacen', NULL, 'app://{0}/{1}', GETDATE(), 'Solicitudes_Salida', 'AL0003', 'Almacen', 'view,view-menu', 0),
(2, 'Almacen', 'Almacen', NULL, 'app://{0}/{1}', GETDATE(), 'Suministros_Salida', 'AL0004', 'Almacen', 'view,view-menu', 0),
(2, 'Almacen', 'Almacen', NULL, 'app://{0}/{1}', GETDATE(), 'Existencias_Registradas', 'AL0005', 'Almacen', 'view,view-menu', 0),
(2, 'Almacen', 'Almacen', NULL, 'app://{0}/{1}', GETDATE(), 'conteo_ciclico', 'AL0006', 'Almacen', 'view,view-menu', 0),
(2, 'Almacen', 'Almacen', NULL, 'app://{0}/{1}', GETDATE(), 'Reporte_diferencias_Conteo', 'AL0007', 'Almacen', 'view,view-menu', 0),
(2, 'Almacen', 'Almacen', NULL, 'app://{0}/{1}', GETDATE(), 'conteo_ciclico_anual', 'AL0008', 'Almacen', 'view,view-menu', 0),
(2, 'Almacen', 'Almacen', NULL, 'app://{0}/{1}', GETDATE(), 'Reporte_diferencias_conteo_anual', 'AL0009', 'Almacen', 'view,view-menu', 0),

(2, N'Nomina', N'Nomina', NULL, N'app://{0}/{1}', GETDATE(), N'Nomina', N'NOM001', N'Nomina', 'view,view-menu', 0),
(2, N'Nomina', N'Nomina', NULL, N'app://{0}/{1}', GETDATE(), N'Nomina_Calculo', N'NOM002', N'Calculo', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina', NULL, N'app://{0}/{1}', GETDATE(), N'Infonavit', N'NOM004', N'Infonavit', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina', NULL, N'app://{0}/{1}', GETDATE(), N'Procesos', N'NOM005', N'Procesos', 'view,view-menu,delete,new,update', 0),

(2, N'Nomina', N'Configuracion_Nominas', NULL, N'app://{0}/{1}', GETDATE(), N'Nomina_Catalogos', N'NOM100', N'Catalogos', 'view,view-menu', 0),
(2, N'Nomina', N'Configuracion_Nominas', NULL, N'app://{0}/{1}', GETDATE(), N'Nomina_Periodos', N'NOM101', N'Periodos', 'view,view-menu', 0),
(2, N'Nomina', N'Configuracion_Nominas', NULL, N'app://{0}/{1}', GETDATE(), N'Nomina_Tablas_ISR', N'NOM102', N'Tablas ISR', 'view,view-menu', 0),
(2, N'Nomina', N'Configuracion_Nominas', NULL, N'app://{0}/{1}', GETDATE(), N'Nomina_Subsidios_ISR', N'NOM103', N'Subsidios ISR', 'view,view-menu', 0),
(2, N'Nomina', N'Configuracion_Nominas', NULL, N'app://{0}/{1}', GETDATE(), N'Nomina_IMSS', N'NOM104', N'IMSS', 'view,view-menu', 0),

(2, N'Nomina', N'Nomina', NULL, N'app://{0}/{1}', GETDATE(), N'Recursos_Humanos', N'NOMRH001', N'Nomina', 'view,view-menu', 0),
(2, N'Nomina', N'Nomina', NULL, N'app://{0}/{1}', GETDATE(), N'Empleados', N'NOMRH001', N'Nomina', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina', NULL, N'app://{0}/{1}', GETDATE(), N'Movimientos_Personal', N'NOMRHMOV1', N'Nomina', 'view,view-menu', 0),
(2, N'Nomina', N'Nomina', NULL, N'app://{0}/{1}', GETDATE(), N'De_Personal', N'NOMRHMOV2', N'Nomina', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina', NULL, N'app://{0}/{1}', GETDATE(), N'Reporte Quincenal MP', N'NOMRHMOV3', N'Nomina', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina', NULL, N'app://{0}/{1}', GETDATE(), N'Creditos_Trabajadores', N'NOMRH002', N'Nomina', 'view,view-menu,delete,new,update', 0),

(2, N'Nomina', N'Nomina', NULL, N'app://{0}/{1}', GETDATE(), N'Nomina_Nomina', N'NOM001', N'Nomina', 'view,view-menu', 0),
(2, N'Nomina', N'Calculo', NULL, N'app://{0}/{1}', GETDATE(), N'Calculo_2050', N'NOM002', N'Calculo', 'view,view-menu,delete,new,update', 0),

(2, N'Nomina', N'Auxiliares', NULL, N'app://{0}/{1}', GETDATE(), N'Auxiliares', N'NOMAUX001', N'Auxiliares', 'view,view-menu', 0),
(2, N'Nomina', N'Auxiliares', NULL, N'app://{0}/{1}', GETDATE(), N'Calculo_ISSSTE_4134', N'NOMAUX002', N'Auxiliares', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Auxiliares', NULL, N'app://{0}/{1}', GETDATE(), N'Calculo_ISR_2053', N'NOMAUX003', N'Auxiliares', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Auxiliares', NULL, N'app://{0}/{1}', GETDATE(), N'Calculo_FOVISSSTE_4136', N'NOMAUX004', N'Auxiliares', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Auxiliares', NULL, N'app://{0}/{1}', GETDATE(), N'Calculo_Infonavit_139', N'NOMAUX005', N'Auxiliares', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Auxiliares', NULL, N'app://{0}/{1}', GETDATE(), N'Calculo_IMSS_3084', N'NOMAUX006', N'Auxiliares', 'view,view-menu,delete,new,update', 0),

(2, N'Nomina', N'Productos', NULL, N'app://{0}/{1}', GETDATE(), N'Resumen', N'NOMPROD001', N'Productos', 'view,view-menu', 0),
(2, N'Nomina', N'Productos', NULL, N'app://{0}/{1}', GETDATE(), N'Recibos', N'NOMPROD002', N'Productos', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Productos', NULL, N'app://{0}/{1}', GETDATE(), N'Archivos_Dispersion', N'NOMPROD003', N'Productos', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Productos', NULL, N'app://{0}/{1}', GETDATE(), N'Archivos_Timbrado', N'NOMPROD004', N'Productos', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Productos', NULL, N'app://{0}/{1}', GETDATE(), N'Reporte_Cuotas_IMSS', N'NOMPROD005', N'Productos', 'view,view-menu', 0),
(2, N'Nomina', N'Productos', NULL, N'app://{0}/{1}', GETDATE(), N'Reporte_Nomina', N'NOMPROD006', N'Productos', 'view,view-menu', 0),
(2, N'Nomina', N'Productos', NULL, N'app://{0}/{1}', GETDATE(), N'Reporte_ISR', N'NOMPROD007', N'Productos', 'view,view-menu', 0),
(2, N'Nomina', N'Productos', NULL, N'app://{0}/{1}', GETDATE(), N'Editar_Reg_Quincenal', N'NOMPROD008', N'Productos', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Productos', NULL, N'app://{0}/{1}', GETDATE(), N'Editar_Reg_Mensual', N'NOMPROD009', N'Productos', 'view,view-menu,delete,new,update', 0),

(2, N'Nomina', N'Incidencias', NULL, N'app://{0}/{1}', GETDATE(), N'Captura_Incidencias', N'NOMINC001', N'Incidencias', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Incidencias', NULL, N'app://{0}/{1}', GETDATE(), N'Justificacion_Incidencias', N'NOMINC002', N'Incidencias', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Incidencias', NULL, N'app://{0}/{1}', GETDATE(), N'Reporte_Incidencias', N'NOMINC003', N'Incidencias', 'view,view-menu', 0),

(2, N'Nomina', N'Pagos_Extraordinarios', NULL, N'app://{0}/{1}', GETDATE(), N'Conceptos_Variables', N'NOMEXTRA01', N'Pagos Extraordinarios', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Cierre_Periodo', NULL, N'app://{0}/{1}', GETDATE(), N'Cierre_Periodo', N'NOMCIERRE1', N'Cierre de Periodo', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Finiquito_Liquidacion', NULL, N'app://{0}/{1}', GETDATE(), N'Liquidacion', N'NOMLIQ001', N'Finiquito/Liquidacion', 'view,view-menu,delete,new,update', 0),

(2, N'Nomina', N'Nominas_Especiales', NULL, N'app://{0}/{1}', GETDATE(), N'Calc_Aguinaldo', N'NOMESP001', N'Nominas Especiales', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nominas_Especiales', NULL, N'app://{0}/{1}', GETDATE(), N'Configura_Aguinaldo', N'NOMESP002', N'Nominas Especiales', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nominas_Especiales', NULL, N'app://{0}/{1}', GETDATE(), N'Aguinaldo', N'NOMESP003', N'Nominas Especiales', 'view,view-menu', 0),
(2, N'Nomina', N'Nominas_Especiales', NULL, N'app://{0}/{1}', GETDATE(), N'Faltas_Especial', N'NOMESP004', N'Nominas Especiales', 'view,view-menu,delete,new,update', 0),

(2, N'Nomina', N'Historicos', NULL, N'app://{0}/{1}', GETDATE(), N'Historicos_Nomina', N'NOMH001', N'Históricos de Nómina', 'view,view-menu', 0),
(2, N'Nomina', N'Productos_Historicos', NULL, N'app://{0}/{1}', GETDATE(), N'Consulta_Nomina', N'NOMH002', N'Consulta de Nómina', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Productos_Historicos', NULL, N'app://{0}/{1}', GETDATE(), N'Analisis', N'NOMH003', N'Análisis', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Productos_Historicos', NULL, N'app://{0}/{1}', GETDATE(), N'Recibos_Historicos', N'NOMH004', N'Recibos', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Productos_Historicos', NULL, N'app://{0}/{1}', GETDATE(), N'Archivos_Dispersion_Historicos', N'NOMH005', N'Archivos de Dispersión', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Productos_Historicos', NULL, N'app://{0}/{1}', GETDATE(), N'Archivos_Timbrado_Historicos', N'NOMH006', N'Archivos de Timbrado', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Productos_Historicos', NULL, N'app://{0}/{1}', GETDATE(), N'Reporte_Nomina_Quincenal', N'NOMH007', N'Reporte Nómina Quincenal', 'view,view-menu', 0),
(2, N'Nomina', N'Productos_Historicos', NULL, N'app://{0}/{1}', GETDATE(), N'Resumen_Nomina_Historica', N'NOMH008', N'Resumen de Nómina Histórica', 'view,view-menu', 0),
(2, N'Nomina', N'Productos_Historicos', NULL, N'app://{0}/{1}', GETDATE(), N'Reporte_Nomina_Historica', N'NOMH009', N'Reporte de Nómina Histórica', 'view,view-menu', 0),
(2, N'Nomina', N'Productos_Historicos', NULL, N'app://{0}/{1}', GETDATE(), N'Cubo_Nomina_Historica', N'NOMH010', N'Cubo Nómina Histórica', 'view,view-menu', 0),

(2, N'Nomina', N'Reportes_IMSS_Historicos', NULL, N'app://{0}/{1}', GETDATE(), N'Salario_Base_Cotizacion', N'NOMH011', N'Salario Base de Cotización', 'view,view-menu', 0),
(2, N'Nomina', N'Reportes_IMSS_Historicos', NULL, N'app://{0}/{1}', GETDATE(), N'Acumulados_IMSS', N'NOMH012', N'Acumulados IMSS', 'view,view-menu', 0),
(2, N'Nomina', N'Reportes_IMSS_Historicos', NULL, N'app://{0}/{1}', GETDATE(), N'SBC_Historico', N'NOMH013', N'SBC Histórico', 'view,view-menu', 0),
(2, N'Nomina', N'Reportes_IMSS_Historicos', NULL, N'app://{0}/{1}', GETDATE(), N'Acumulados_Bimestre_IMSS', N'NOMH014', N'Acumulados en el Bimestre IMSS', 'view,view-menu', 0),

(2, N'Nomina', N'Reportes_SAT_Historicos', NULL, N'app://{0}/{1}', GETDATE(), N'Acumulado_Mensual_ISR', N'NOMH015', N'Acumulado Mensual ISR', 'view,view-menu', 0),
(2, N'Nomina', N'Reportes_SAT_Historicos', NULL, N'app://{0}/{1}', GETDATE(), N'Acumulados_ISR', N'NOMH016', N'Acumulados de ISR', 'view,view-menu', 0),

(2, N'Nomina', N'Impuestos_Locales_Historicos', NULL, N'app://{0}/{1}', GETDATE(), N'Impuestos_Locales', N'NOMH017', N'Impuestos sobre Nómina locales', 'view,view-menu', 0),

(2, N'Nomina', N'Configuracion_Nominas', NULL, N'app://{0}/{1}', GETDATE(), N'Configuracion_Nominas', N'NOMCFG001', N'Configuración Nóminas', 'view,view-menu', 0),
(2, N'Nomina', N'Catalogos', NULL, N'app://{0}/{1}', GETDATE(), N'Tipo_Nomina', N'NOMCFG002', N'Tipo de Nómina', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Catalogos', NULL, N'app://{0}/{1}', GETDATE(), N'Cuotas_IMSS', N'NOMCFG003', N'Cuotas IMSS', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Catalogos', NULL, N'app://{0}/{1}', GETDATE(), N'Conceptos_Nomina', N'NOMCFG004', N'Conceptos de Nómina', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Catalogos', NULL, N'app://{0}/{1}', GETDATE(), N'UMA', N'NOMCFG005', N'UMA', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Catalogos', NULL, N'app://{0}/{1}', GETDATE(), N'Tipo_Contratacion', N'NOMCFG006', N'Tipo de Contratación', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Catalogos', NULL, N'app://{0}/{1}', GETDATE(), N'Tipo_Descanso', N'NOMCFG007', N'Tipo de descanso', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Catalogos', NULL, N'app://{0}/{1}', GETDATE(), N'Tipo_Incidencia', N'NOMCFG008', N'Tipo de Incidencia', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Catalogos', NULL, N'app://{0}/{1}', GETDATE(), N'Concepto_Fijo', N'NOMCFG009', N'Conceptos de importe Fijo', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Catalogos', NULL, N'app://{0}/{1}', GETDATE(), N'Tipo_Justificacion', N'NOMCFG010', N'Tipo de Justificación', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Catalogos', NULL, N'app://{0}/{1}', GETDATE(), N'Tabulador', N'NOMCFG011', N'Tabulador', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Catalogos', NULL, N'app://{0}/{1}', GETDATE(), N'Unidad_Infonavit', N'NOMCFG012', N'Unidad Infonavit', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Catalogos', NULL, N'app://{0}/{1}', GETDATE(), N'Salario_Minimo', N'NOMCFG013', N'Salario Mínimo General', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Catalogos', NULL, N'app://{0}/{1}', GETDATE(), N'Forma_Pago', N'NOMCFG014', N'Forma de Pago', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Catalogos', NULL, N'app://{0}/{1}', GETDATE(), N'Forma_Calculo', N'NOMCFG015', N'Forma de Cálculo', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Catalogos', NULL, N'app://{0}/{1}', GETDATE(), N'Capitulos', N'NOMCFG016', N'Capitulos', 'view,view-menu,delete,new,update', 0),

(2, N'Nomina', N'Periodos', NULL, N'app://{0}/{1}', GETDATE(), N'Periodo_Semanal', N'NOMCFG017', N'Semanal', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Periodos', NULL, N'app://{0}/{1}', GETDATE(), N'Periodo_Quincenal', N'NOMCFG018', N'Quincenal', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Periodos', NULL, N'app://{0}/{1}', GETDATE(), N'Periodo_Mensual', N'NOMCFG019', N'Mensual', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Periodos', NULL, N'app://{0}/{1}', GETDATE(), N'Periodo_Bimestral', N'NOMCFG020', N'Bimestral', 'view,view-menu,delete,new,update', 0),

(2, N'Nomina', N'Tablas_ISR', NULL, N'app://{0}/{1}', GETDATE(), N'Tabla_ISR_Semanal', N'NOMCFG021', N'Semanal', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Tablas_ISR', NULL, N'app://{0}/{1}', GETDATE(), N'Tabla_ISR_Quincenal', N'NOMCFG022', N'Quincenal', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Tablas_ISR', NULL, N'app://{0}/{1}', GETDATE(), N'Tabla_ISR_Mensual', N'NOMCFG023', N'Mensual', 'view,view-menu,delete,new,update', 0),

(2, N'Nomina', N'Prestaciones', NULL, N'app://{0}/{1}', GETDATE(), N'Prestaciones', N'NOMCFG024', N'Prestaciones', 'view,view-menu,delete,new,update', 0),

(2, N'Nomina', N'Subsidios_ISR', NULL, N'app://{0}/{1}', GETDATE(), N'Subsidio_ISR_Semanal', N'NOMCFG025', N'Semanal', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Subsidios_ISR', NULL, N'app://{0}/{1}', GETDATE(), N'Subsidio_ISR_Quincenal', N'NOMCFG026', N'Quincenal', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Subsidios_ISR', NULL, N'app://{0}/{1}', GETDATE(), N'Subsidio_ISR_Mensual', N'NOMCFG027', N'Mensual', 'view,view-menu,delete,new,update', 0),

(2, N'Nomina', N'Impuestos', NULL, N'app://{0}/{1}', GETDATE(), N'Base_Gravable', N'NOMCFG028', N'Base Gravable', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Impuestos', NULL, N'app://{0}/{1}', GETDATE(), N'Impuestos_Locales', N'NOMCFG029', N'Impuestos Locales', 'view,view-menu,delete,new,update', 0),

(2, N'Nomina', N'IMSS', NULL, N'app://{0}/{1}', GETDATE(), N'Prestaciones_Minimas', N'NOMCFG030', N'Prestaciones Mínimas de Ley', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'IMSS', NULL, N'app://{0}/{1}', GETDATE(), N'Clase_IMSS', N'NOMCFG031', N'Clase IMSS', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'IMSS', NULL, N'app://{0}/{1}', GETDATE(), N'Fraccion_IMSS', N'NOMCFG032', N'Fracción IMSS', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'IMSS', NULL, N'app://{0}/{1}', GETDATE(), N'Base_Gravable_IMSS', N'NOMCFG033', N'Base Gravable IMSS', 'view,view-menu,delete,new,update', 0),

(2, N'RecursosHumanos', N'Configuracion_RH', NULL, N'app://{0}/{1}', GETDATE(), N'Configuracion_RH', N'RHCFG001', N'Configuración RH', 'view,view-menu', 0),
(2, N'RecursosHumanos', N'Plazas_Autorizadas', NULL, N'app://{0}/{1}', GETDATE(), N'Plazas_Autorizadas', N'RHCFG002', N'Plazas Autorizadas', 'view,view-menu,delete,new,update', 0),
(2, N'RecursosHumanos', N'Universo', NULL, N'app://{0}/{1}', GETDATE(), N'Universo', N'RHCFG003', N'Universo', 'view,view-menu,delete,new,update', 0),
(2, N'RecursosHumanos', N'Nivel', NULL, N'app://{0}/{1}', GETDATE(), N'Nivel', N'RHCFG004', N'Nivel', 'view,view-menu,delete,new,update', 0),
(2, N'RecursosHumanos', N'Sexo', NULL, N'app://{0}/{1}', GETDATE(), N'Sexo', N'RHCFG005', N'Sexo', 'view,view-menu,delete,new,update', 0),
(2, N'RecursosHumanos', N'Estado_Civil', NULL, N'app://{0}/{1}', GETDATE(), N'Estado_Civil', N'RHCFG006', N'Estado Civil', 'view,view-menu,delete,new,update', 0),
(2, N'RecursosHumanos', N'Escolaridad', NULL, N'app://{0}/{1}', GETDATE(), N'Escolaridad', N'RHCFG007', N'Escolaridad', 'view,view-menu,delete,new,update', 0),
(2, N'RecursosHumanos', N'Tipo_Parentesco', NULL, N'app://{0}/{1}', GETDATE(), N'Tipo_Parentesco', N'RHCFG008', N'Tipo de Parentesco', 'view,view-menu,delete,new,update', 0),
(2, N'RecursosHumanos', N'Estado', NULL, N'app://{0}/{1}', GETDATE(), N'Estado', N'RHCFG009', N'Estado', 'view,view-menu,delete,new,update', 0),
(2, N'RecursosHumanos', N'Banco', NULL, N'app://{0}/{1}', GETDATE(), N'Banco', N'RHCFG010', N'Banco', 'view,view-menu,delete,new,update', 0),
(2, N'RecursosHumanos', N'Municipio', NULL, N'app://{0}/{1}', GETDATE(), N'Municipio', N'RHCFG011', N'Municipio', 'view,view-menu,delete,new,update', 0),
(2, N'RecursosHumanos', N'Contratos', NULL, N'app://{0}/{1}', GETDATE(), N'Contratos', N'RHCFG012', N'Contratos', 'view,view-menu', 0),
(2, N'RecursosHumanos', N'Contratos', NULL, N'app://{0}/{1}', GETDATE(), N'Base_Pago', N'RHCFG013', N'Base Pago', 'view,view-menu,delete,new,update', 0),
(2, N'RecursosHumanos', N'Contratos', NULL, N'app://{0}/{1}', GETDATE(), N'Metodo_Pago', N'RHCFG014', N'Método de Pago', 'view,view-menu,delete,new,update', 0),
(2, N'RecursosHumanos', N'Contratos', NULL, N'app://{0}/{1}', GETDATE(), N'Tipo_Regimen', N'RHCFG015', N'Tipo de Régimen', 'view,view-menu,delete,new,update', 0),
(2, N'RecursosHumanos', N'Contratos', NULL, N'app://{0}/{1}', GETDATE(), N'Base_Cotizacion', N'RHCFG016', N'Base de Cotización', 'view,view-menu,delete,new,update', 0),
(2, N'RecursosHumanos', N'Contratos', NULL, N'app://{0}/{1}', GETDATE(), N'Zona_Geografica', N'RHCFG017', N'Zona Geográfica', 'view,view-menu,delete,new,update', 0),
(2, N'RecursosHumanos', N'Contratos', NULL, N'app://{0}/{1}', GETDATE(), N'Dia_Semana', N'RHCFG018', N'Día de la Semana', 'view,view-menu,delete,new,update', 0)

;
 

SELECT 'EXEC spConfiguracionDeRolYClaims ''' + [Group] + ''', ''' + [SubGroup] + ''', ''10000'', ''' + [Values] + ''';'
from dbo.AspNetClaims

---- Ejecución del procedimiento para asignar valores a los roles
EXEC spConfiguracionDeRolYClaims 'Configuracion', 'Configuracion', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Presupuesto', 'Presupuesto', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'Contabilidad', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Adquisiciones', 'Adquisiciones', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Patrimonio', 'Patrimonio', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Almacen', 'Almacen', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Reportes CxC', 'Reportes CxC', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Nomina', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'PRB', 'PRB', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Ayuda', 'Ayuda', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Configuracion', 'Sistema', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Sistema', 'MiPerfil', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Sistema', 'Usuario', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Sistema', 'Menu', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Sistema', 'General', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Sistema', 'Empresa', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Sistema', 'Departamento', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Configuracion', 'Catalogos_presupuestales', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Catalogos_presupuestales', 'Programas_Presupuestales', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Catalogos_presupuestales', 'ClavePrograma', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'UnidadResponsable', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'Finalidad', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'Funcion', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'SubFuncion', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'Actividad_Institucional', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'Programa_Presupuestal', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'Anios', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'Sector', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'TipoRecurso', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'Fuente_Financiamiento', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'PG', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'Ramo', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'Proyecto', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Catalogos_presupuestales', 'Contabilidad', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'Tipo_Polizas', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'Tipo_detalles_Polizas', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'Matriz_Conversion', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'Matriz_Conversion_Ingresos', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'Partidas_Presupuestales', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'Cuentas_Contables', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'Formas_Pago', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Configuracion', 'Adquisiciones', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Adquisiciones', 'Modalidad', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Adquisiciones', 'Tipo_Contrato', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Adquisiciones', 'Tipo_Documentos', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Adquisiciones', 'Tipo_Garantia', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Adquisiciones', 'Procedimientos_Contratacion', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Adquisiciones', 'Estatus_Requisicion', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Adquisiciones', 'Proveedores', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Adquisiciones', 'Articulo', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Adquisiciones', 'Fraccion', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Configuracion', 'Patrimonio', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Patrimonio', 'Familia', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Patrimonio', 'Grupo_Bien', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Patrimonio', 'Bienes_Servicios', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Patrimonio', 'Tipo_Patrimonio', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Patrimonio', 'Tipo_Adquisicion', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Patrimonio', 'Marca', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Patrimonio', 'Personas', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Configuracion', 'Almacen', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Almacen', 'Movimiento_Entrada_Salida', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Almacen', 'Estatus_Solicitud', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Almacen', 'Unidades', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Almacen', 'Conteo_Periodo', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Almacen', 'Familia', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Almacen', 'Tipo_Bien', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Almacen', 'Bien', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Almacen', 'Numero_Conteo', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Configuracion', 'Tesoreria', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'Tipo_Cambio', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'Tipo_Inversion', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'Tipo_Moneda', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'Tipo_Pago', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'Tipo_PagoSF', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'Tipo_SolicitudCLC', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'Tipo_DoctoCLC', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Adquisiciones', 'Programa_Anual_Adquisiciones', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Adquisiciones', 'Requisicion', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'Adquisiciones', 'Cotizacion', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'Adquisiciones', 'SolicitudSuficiencia', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'Adquisiciones', 'OrdenCompra', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'Adquisiciones', 'Contratos', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Contratos', 'Registro_Compromiso', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contratos', 'Saldos_Contratos', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contratos', 'Estado_Contrato', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Presupuesto', 'Egreso', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Egreso', 'Planeacion', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Egreso', 'Catalogos_Planeacion', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Catalogos_Planeacion', 'Indicadores', '10000', 'view,view-menu,new,update,delete,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'Catalogos_Planeacion', 'Resumen_Narrativo', '10000', 'view,view-menu,new,update,delete,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'Planeacion', 'Anteproyecto_Egresos', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'Egreso', 'Presupuesto_Disponible', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'Egreso', 'Presupuesto_Modificado', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Presupuesto_Modificado', 'Adecuaciones_Compensadas', '10000', 'view,view-menu,new,update,delete,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'Presupuesto_Modificado', 'Ampliaciones', '10000', 'view,view-menu,new,update,delete,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'Presupuesto_Modificado', 'Reducciones', '10000', 'view,view-menu,new,update,delete,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'Egreso', 'Presupuesto_Comprometido', '10000', 'view,view-menu,new,update,delete,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'Egreso', 'Presupuesto_Comprometido', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Presupuesto_Comprometido', 'Solicitud_Suficiencia', '10000', 'view,view-menu,new,update,delete,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'Presupuesto_Comprometido', 'Autorizacion_Suficiencia', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'Presupuesto_Comprometido', 'Registro_Comprometido', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'Presupuesto', 'Tesoreria', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'CuentasXCobrar', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'CuentasXCobrar', 'Ley_Ingresos_Estimados', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'CuentasXCobrar', 'Presupuesto_Modificado', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Presupuesto_Modificado', 'Adecuaciones_Compensadas', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'Presupuesto_Modificado', 'Aumento_Presupuesto', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'Presupuesto_Modificado', 'Reduccion_Presupuesto', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'CuentasXCobrar', 'Ingresos_Devengados', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Ingresos_Devengados', 'Ingresos', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'Ingresos_Devengados', 'Ingresos_Propios', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'CuentasXCobrar', 'Ingresos_Recaudar', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'CuentasXCobrar', 'Depositos_CLC', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'CuentasXCobrar', 'Otros_Ingresos', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'CuentasXCobrar', 'Reportes_CxC', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Reportes_CxC', 'Antiguedad_Saldos', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'Reportes_CxC', 'Integracion_Saldos', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'Reportes_CxC', 'Estado_Cuenta', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'Reportes_CxC', 'Analisis_Saldos', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'Reportes_CxC', 'Consulta_Documentos', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'CuentasXPagar', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'CuentasXPagar', 'PEF_Unipartida_TES', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'PEF_Unipartida_TES', 'RecepcionFactura_ComprobantePago', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'PEF_Unipartida_TES', 'Provision_Pago', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'PEF_Unipartida_TES', 'ElaboracionCheque_Transferencia', '10000', 'view,view-menu,delete,new,update,CanExportToExcel,authorize';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'Planeacion_Gastos', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'Saldos_Cuentas', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'Solicitud_Reintegros', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'Autorizar_Solicitud_Reingresos', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'Provision_Pago', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'Inversiones', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Inversiones', 'Banco', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Inversiones', 'Cuenta_Bancaria', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Inversiones', 'Intermediarios_Financiero', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Inversiones', 'Instrumentos_Inversion', '10000', 'view,view-menu,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Inversiones', 'Listado_Inversiones', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Inversiones', 'Tipo_Instrumentos', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Inversiones', 'Tipo_Plazos', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Inversiones', 'Tipo_Retiro', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Inversiones', 'Simulador', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'Polizas', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'Autorizacion_Polizas', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'Balanza_Comprobacion', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'Auxiliares', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'Reportes_Contabilidad', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Reportes_Contabilidad', 'Libro_Diario', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Reportes_Contabilidad', 'Libro_Mayor', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Reportes_Contabilidad', 'Libro_Inventarios_Materiales', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Reportes_Contabilidad', 'Libro_Almacen_Suministros', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Reportes_Contabilidad', 'Libro_Inventarios_Muebles', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Reportes_Contabilidad', 'Polizas', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Reportes_Contabilidad', 'Reporte_Retenciones', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Reportes_Contabilidad', 'Reporte_Depreciacion_Acumulada', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Reportes_Contabilidad', 'Reporte_Activos_Fijos', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Reportes_Contabilidad', 'Reporte_Facturas_Emitidas', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Reportes_Contabilidad', 'Reporte_DIOT', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'EI_Contable', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'EI_Contable', 'Estados_Actividades', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'EI_Contable', 'Estado_Situacion_Financiera', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'EI_Contable', 'Estado_VHP', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'EI_Contable', 'Estados_CSF', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'EI_Contable', 'Estado_Flujos_Efectivo', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'EI_Contable', 'Estado_Analitico_Activo', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'EI_Contable', 'Estado_ADOP', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'EI_Contable', 'Informe_Pasivos_Contingentes', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'EI_Contable', 'Notas_Estados_Financieros', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'Conciliacion_IE', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'EI_Presupuestarios', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'EI_Presupuestarios', 'Estado_Analitico_Ingresos', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'EI_Presupuestarios', 'Estado_AECA', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'EI_Presupuestarios', 'Estado_AECE', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'EI_Presupuestarios', 'Estado_AECOG', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'EI_Presupuestarios', 'Estado_AECF', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'EI_Presupuestarios', 'Endeudamiento_Neto', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'EI_Presupuestarios', 'Intereses_Deuda', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'EI_Presupuestarios', 'Proyecciones_Egresos', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'EI_Presupuestarios', 'Proyecciones_Ingresos', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'EI_Presupuestarios', 'Indicadores_APP', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'EI_Presupuestarios', 'Pp_Inversion', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'EI_Presupuestarios', 'Resultados_Ingresos', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'EI_Presupuestarios', 'Resultados_Egresos', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'EI_Programaticos', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'Indicadores_Postura_Fiscal', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'Cierre_Mensual', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Patrimonio', 'Bienes', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Patrimonio', 'Clasificacion_Bienes_Muebles', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Patrimonio', 'Bajas', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Patrimonio', 'Calendario_Inventarios', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Patrimonio', 'Inventarios', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Patrimonio', 'Cedula_Diferencia', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Patrimonio', 'Resguardos', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Patrimonio', 'Firma_Resguardos', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Patrimonio', 'Resguardo_Historico', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Almacen', 'Recepcion_Pedidos', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Almacen', 'Entradas_Ajuste', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Almacen', 'Solicitudes_Salida', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Almacen', 'Suministros_Salida', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Almacen', 'Existencias_Registradas', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Almacen', 'conteo_ciclico', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Almacen', 'Reporte_diferencias_Conteo', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Almacen', 'conteo_ciclico_anual', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Almacen', 'Reporte_diferencias_conteo_anual', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Nomina', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Nomina_Calculo', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Infonavit', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Procesos', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Configuracion_Nominas', 'Nomina_Catalogos', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Configuracion_Nominas', 'Nomina_Periodos', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Configuracion_Nominas', 'Nomina_Tablas_ISR', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Configuracion_Nominas', 'Nomina_Subsidios_ISR', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Configuracion_Nominas', 'Nomina_IMSS', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Recursos_Humanos', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Empleados', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Movimientos_Personal', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'De_Personal', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Reporte Quincenal MP', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Creditos_Trabajadores', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Nomina_Nomina', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Calculo', 'Calculo_2050', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Auxiliares', 'Auxiliares', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Auxiliares', 'Calculo_ISSSTE_4134', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Auxiliares', 'Calculo_ISR_2053', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Auxiliares', 'Calculo_FOVISSSTE_4136', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Auxiliares', 'Calculo_Infonavit_139', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Auxiliares', 'Calculo_IMSS_3084', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Productos', 'Resumen', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Productos', 'Recibos', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Productos', 'Archivos_Dispersion', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Productos', 'Archivos_Timbrado', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Productos', 'Reporte_Cuotas_IMSS', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Productos', 'Reporte_Nomina', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Productos', 'Reporte_ISR', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Productos', 'Editar_Reg_Quincenal', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Productos', 'Editar_Reg_Mensual', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Incidencias', 'Captura_Incidencias', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Incidencias', 'Justificacion_Incidencias', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Incidencias', 'Reporte_Incidencias', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Pagos_Extraordinarios', 'Conceptos_Variables', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Cierre_Periodo', 'Cierre_Periodo', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Finiquito_Liquidacion', 'Liquidacion', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nominas_Especiales', 'Calc_Aguinaldo', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nominas_Especiales', 'Configura_Aguinaldo', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nominas_Especiales', 'Aguinaldo', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Nominas_Especiales', 'Faltas_Especial', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Historicos', 'Historicos_Nomina', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Productos_Historicos', 'Consulta_Nomina', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Productos_Historicos', 'Analisis', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Productos_Historicos', 'Recibos_Historicos', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Productos_Historicos', 'Archivos_Dispersion_Historicos', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Productos_Historicos', 'Archivos_Timbrado_Historicos', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Productos_Historicos', 'Reporte_Nomina_Quincenal', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Productos_Historicos', 'Resumen_Nomina_Historica', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Productos_Historicos', 'Reporte_Nomina_Historica', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Productos_Historicos', 'Cubo_Nomina_Historica', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Reportes_IMSS_Historicos', 'Salario_Base_Cotizacion', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Reportes_IMSS_Historicos', 'Acumulados_IMSS', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Reportes_IMSS_Historicos', 'SBC_Historico', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Reportes_IMSS_Historicos', 'Acumulados_Bimestre_IMSS', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Reportes_SAT_Historicos', 'Acumulado_Mensual_ISR', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Reportes_SAT_Historicos', 'Acumulados_ISR', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Impuestos_Locales_Historicos', 'Impuestos_Locales', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Configuracion_Nominas', 'Configuracion_Nominas', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Catalogos', 'Tipo_Nomina', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Catalogos', 'Cuotas_IMSS', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Catalogos', 'Conceptos_Nomina', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Catalogos', 'UMA', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Catalogos', 'Tipo_Contratacion', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Catalogos', 'Tipo_Descanso', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Catalogos', 'Tipo_Incidencia', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Catalogos', 'Concepto_Fijo', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Catalogos', 'Tipo_Justificacion', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Catalogos', 'Tabulador', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Catalogos', 'Unidad_Infonavit', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Catalogos', 'Salario_Minimo', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Catalogos', 'Forma_Pago', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Catalogos', 'Forma_Calculo', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Catalogos', 'Capitulos', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Periodos', 'Periodo_Semanal', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Periodos', 'Periodo_Quincenal', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Periodos', 'Periodo_Mensual', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Periodos', 'Periodo_Bimestral', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Tablas_ISR', 'Tabla_ISR_Semanal', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Tablas_ISR', 'Tabla_ISR_Quincenal', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Tablas_ISR', 'Tabla_ISR_Mensual', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Prestaciones', 'Prestaciones', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Subsidios_ISR', 'Subsidio_ISR_Semanal', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Subsidios_ISR', 'Subsidio_ISR_Quincenal', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Subsidios_ISR', 'Subsidio_ISR_Mensual', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Impuestos', 'Base_Gravable', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Impuestos', 'Impuestos_Locales', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'IMSS', 'Prestaciones_Minimas', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'IMSS', 'Clase_IMSS', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'IMSS', 'Fraccion_IMSS', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'IMSS', 'Base_Gravable_IMSS', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Configuracion_RH', 'Configuracion_RH', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Plazas_Autorizadas', 'Plazas_Autorizadas', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Universo', 'Universo', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nivel', 'Nivel', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Sexo', 'Sexo', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Estado_Civil', 'Estado_Civil', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Escolaridad', 'Escolaridad', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Tipo_Parentesco', 'Tipo_Parentesco', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Estado', 'Estado', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Banco', 'Banco', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Municipio', 'Municipio', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Contratos', 'Contratos', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Contratos', 'Base_Pago', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Contratos', 'Metodo_Pago', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Contratos', 'Tipo_Regimen', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Contratos', 'Base_Cotizacion', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Contratos', 'Zona_Geografica', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Contratos', 'Dia_Semana', '10000', 'view,view-menu,delete,new,update';
-- Tabla AspNetUsers
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

-- Insertar usuarios de prueba
update [dbo].[AspNetUsers] set [PasswordHash] = 'UOxg2B7HCZwZZ/drSkwHrA==', [SecurityStamp] = 'C5F91B8B-9E25-4576-96E7-CD3317F1AB87' where PkIdUsuario in (1,2,3);
INSERT INTO [dbo].[AspNetUsers] (
    [Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber],
    [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled],
    [AccessFailedCount], [ReferenceId], [AccessNumber], [PkIdUsuario]
)
VALUES 
    (NEWID(), '', 1, 'UOxg2B7HCZwZZ/drSkwHrA==', 'C5F91B8B-9E25-4576-96E7-CD3317F1AB87', NULL, 0, 0, NULL, 0, 0, 10000, '0000010000', 1)--,
    --(NEWID(), '', 1, 'UOxg2B7HCZwZZ/drSkwHrA==', 'C5F91B8B-9E25-4576-96E7-CD3317F1AB87', NULL, 0, 0, NULL, 0, 0, 10000, '0000010000', 2),
    --(NEWID(), '', 1, 'UOxg2B7HCZwZZ/drSkwHrA==', 'C5F91B8B-9E25-4576-96E7-CD3317F1AB87', NULL, 0, 0, NULL, 0, 0, 10000, '0000010000', 3);

-- Tabla AspNetUserRoles
--drop table dbo.AspNetUserRoles
update AspNetUserRoles set  UserId = '52BEDE02-1F81-41E2-A93E-8666AB0873CE'
CREATE TABLE dbo.AspNetUserRoles (
    UserId NVARCHAR(128) NOT NULL,
    RoleId NVARCHAR(128) NOT NULL,
    ExpireDate DATETIME,
    CONSTRAINT CONSTRAINT_PK_AspNetUserRoles PRIMARY KEY CLUSTERED (UserId, RoleId),
    CONSTRAINT CONSTRAINT_FK_AspNetUserRoles_User FOREIGN KEY (UserId) REFERENCES dbo.AspNetUsers(Id),
    CONSTRAINT CONSTRAINT_FK_AspNetUserRoles_Role FOREIGN KEY (RoleId) REFERENCES dbo.AspNetRoles(Id)
);
GO

INSERT INTO [dbo].[AspNetUserRoles] ([UserId], [RoleId], [ExpireDate])
SELECT [Id], '71804e93-9753-4684-84fd-cf037349c111', '2027-12-31'
FROM [dbo].[AspNetUsers]
WHERE PkIdUsuario  IN (1,2,3);

-- =============================================
-- MENÚS
-- =============================================
--select * from SIS.Menu where nombre like '%Usu%'
--drop table SIS.Menu
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
--drop table SIS.MenuRole
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

/*
UPDATE SIS.Menu
SET Tipo = CASE WHEN Ruta = '/' THEN 1 ELSE 2 END
*/
-- Insertar menús
--select * from SIS.Menu

SET IDENTITY_INSERT SIS.Menu ON;

MERGE INTO SIS.Menu AS TARGET
USING (VALUES
      -- Módulos principales
    (1, N'Configuración', 1, NULL, N'Configuración', N'/', N'FaCog', 1, N'ESP', 1, 1, GETDATE()),
    (2, N'Presupuesto', 1, NULL, N'Presupuesto', N'/', N'FaChartPie', 1, N'ESP', 2, 1, GETDATE()),
    (3, N'Contabilidad', 1, NULL, N'Contabilidad', N'/', N'FaTable', 1, N'ESP', 3, 1, GETDATE()),
    (4, N'Adquisiciones', 1, NULL, N'Adquisiciones', N'/', N'RiListCheck2', 1, N'ESP', 4, 1, GETDATE()),
    (5, N'Patrimonio', 1, NULL, N'Patrimonio', N'/', N'FaFolder', 1, N'ESP', 5, 1, GETDATE()),
    (6, N'Almacén', 1, NULL, N'Almacén', N'/', N'FaFolderOpen', 1, N'ESP', 6, 1, GETDATE()),
    (7, N'Nómina', 1, NULL, N'Nómina', N'/', N'FaMoneyBillWave', 1, N'ESP', 7, 1, GETDATE()),
    (8, N'Reportes CxC', 1, NULL, N'Reportes CxC', N'/', N'FaChartLine', 1, N'ESP', 8, 1, GETDATE()),
    (9, N'PRB', 2, NULL, N'PRB', N'/PRB', N'FaDashboard', 1, N'ESP', 9, 1, GETDATE()),
    (10, N'Ayuda', 2, NULL, N'Ayuda', N'/ayuda', N'FaInfo', 1, N'ESP', 10, 1, GETDATE()),

    -- Configuración -> Sistema
    (20, N'Sistema', 1, 1, N'Sistema', N'/', N'FaTools', 1, N'ESP', 1, 1, GETDATE()),
    (21, N'Usuario', 2, 20, N'Usuario', N'/configuracion/sistema/usuarios', N'FaUserCircle', 1, N'ESP', 1, 1, GETDATE()),
    (22, N'Menú', 2, 20, N'Menú', N'/configuracion/sistema/menu', N'RiMenuLine', 1, N'ESP', 2, 1, GETDATE()),
    (23, N'General', 2, 20, N'General', N'/configuracion/sistema/general', N'FaGears', 1, N'ESP', 3, 1, GETDATE()),
    (24, N'Empresa', 2, 20, N'Empresa', N'/configuracion/sistema/empresa', N'FaHome', 1, N'ESP', 4, 1, GETDATE()),
    (25, N'Departamento', 2, 20, N'Departamento', N'/configuracion/sistema/departamento', N'FaUserGroup', 1, N'ESP', 5, 1, GETDATE()),

    -- Configuración -> Presupuestales
    (30, N'Presupuestales', 1, 1, N'Presupuestales', N'/', N'FaChartBar', 1, N'ESP', 2, 1, GETDATE()),
    (31, N'Programas Presupuestales', 2, 30, N'Programas Presupuestales.', N'/configuracion/presupuestales/programas-presupuesta', N'FaFolderOpen', 1, N'ESP', 1, 1, GETDATE()),
    (32, N'Clave del Programa', 1, 30, N'Clave del Programa', N'/', N'FaKey', 1, N'ESP', 2, 1, GETDATE()),
    (33, N'Unidad Responsable', 2, 32, N'Unidad Responsable', N'/configuracion/presupuestales/clave-programa/unidad-responsable', N'FaUserGroup', 1, N'ESP', 1, 1, GETDATE()),
    (34, N'Finalidad', 2, 32, N'Finalidad', N'/configuracion/presupuestales/clave-programa/finalidad', N'FaFlag', 1, N'ESP', 2, 1, GETDATE()),
    (35, N'Función', 2, 32, N'Función', N'/configuracion/presupuestales/clave-programa/funcion', N'FaGears', 1, N'ESP', 3, 1, GETDATE()),
    (36, N'SubFunción', 2, 32, N'SubFunción', N'/configuracion/presupuestales/clave-programa/subfuncion', N'FaTools', 1, N'ESP', 4, 1, GETDATE()),
    (37, N'Actividad Institucional', 2, 32, N'Actividad Institucional', N'/configuracion/presupuestales/clave-programa/actividad-institucional', N'RiListCheck2', 1, N'ESP', 5, 1, GETDATE()),
    (38, N'Programa Presupuestal', 2, 32, N'Programa Presupuestal', N'/configuracion/presupuestales/clave-programa/programa-presupuestal', N'FaDocument', 1, N'ESP', 6, 1, GETDATE()),
    (39, N'Años', 2, 32, N'Años', N'/configuracion/presupuestales/clave-programa/anios', N'FaCalendar', 1, N'ESP', 7, 1, GETDATE()),
    (40, N'Sector', 2, 32, N'Sector', N'/configuracion/presupuestales/clave-programa/sector', N'FaFolder', 1, N'ESP', 8, 1, GETDATE()),
    (41, N'Tipo Recurso', 2, 32, N'Tipo Recurso', N'/configuracion/presupuestales/clave-programa/tipo-recurso', N'FaTag', 1, N'ESP', 9, 1, GETDATE()),
    (42, N'Fuente Financiamiento', 2, 32, N'Fuente Financiamiento', N'/configuracion/presupuestales/clave-programa/fuente-financiamiento', N'FaChartPie', 1, N'ESP', 10, 1, GETDATE()),
    (43, N'PG', 2, 32, N'PG', N'/configuracion/presupuestales/clave-programa/pg', N'FaDocument', 1, N'ESP', 11, 1, GETDATE()),
    (44, N'Ramo', 2, 32, N'Ramo', N'/configuracion/presupuestales/clave-programa/ramo', N'FaFolderOpen', 1, N'ESP', 12, 1, GETDATE()),
    (45, N'Proyecto', 2, 32, N'Proyecto', N'/configuracion/presupuestales/clave-programa/proyecto', N'FaFolder', 1, N'ESP', 13, 1, GETDATE()),

    -- Configuración -> Contabilidad
    (50, N'Contabilidad', 1, 1, N'Contabilidad', N'/', N'FaTable', 1, N'ESP', 3, 1, GETDATE()),
    (51, N'Tipo Pólizas', 2, 50, N'Tipo Pólizas', N'/configuracion/contabilidad/tipo-polizas', N'FaDocument', 1, N'ESP', 1, 1, GETDATE()),
    (52, N'Tipo Detalles Pólizas', 2, 50, N'Tipo Detalles Pólizas', N'/configuracion/contabilidad/tipo-detalles-polizas', N'RiListCheck2', 1, N'ESP', 2, 1, GETDATE()),
    (53, N'Matriz Conversión', 2, 50, N'Matriz Conversión', N'/configuracion/contabilidad/matriz-conversion', N'FaGears', 1, N'ESP', 3, 1, GETDATE()),
    (54, N'Matriz Conversión Ingresos', 2, 50, N'Matriz Conversión Ingresos', N'/configuracion/contabilidad/matriz-conversion-ingresos', N'FaChartBar', 1, N'ESP', 4, 1, GETDATE()),
    (55, N'Partidas Presupuestales', 2, 50, N'Partidas Presupuestales', N'/configuracion/contabilidad/partidas-presupuestales', N'FaTag', 1, N'ESP', 5, 1, GETDATE()),
    (56, N'Cuentas Contables', 2, 50, N'Cuentas Contables', N'/configuracion/contabilidad/cuentas-contables', N'FaTable', 1, N'ESP', 6, 1, GETDATE()),
    (57, N'Formas Pago', 2, 50, N'Formas Pago', N'/configuracion/contabilidad/formas-pago', N'FaSave', 1, N'ESP', 7, 1, GETDATE()),

    -- Configuración -> Adquisiciones
    (70, N'Adquisiciones', 1, 1, N'Adquisiciones', N'/', N'RiListCheck2', 1, N'ESP', 3, 1, GETDATE()),
    (71, N'Modalidad', 2, 70, N'Modalidad', N'/configuracion/adquisiciones/modalidad', N'FaTag', 1, N'ESP', 1, 1, GETDATE()),
    (72, N'Tipo de Contrato', 2, 70, N'Tipo de Contrato', N'/configuracion/adquisiciones/tipo-contrato', N'FaDocument', 1, N'ESP', 2, 1, GETDATE()),
    (73, N'Tipo de Documentos', 2, 70, N'Tipo de Documentos', N'/configuracion/adquisiciones/tipo-documento', N'FaFile', 1, N'ESP', 3, 1, GETDATE()),
    (74, N'Tipo de Garantí­a', 2, 70, N'Tipo de Garantí­a', N'/configuracion/adquisiciones/tipo-garantia', N'FaLock', 1, N'ESP', 4, 1, GETDATE()),
    (75, N'Procedimientos de Contratación', 2, 70, N'Procedimientos de Contratación', N'/configuracion/adquisiciones/procedimientos-contratacion', N'FaGears', 1, N'ESP', 5, 1, GETDATE()),
    (76, N'Estatus Requisición', 2, 70, N'Estatus Requisición', N'/configuracion/adquisiciones/estatus-requisicion', N'FaFlag', 1, N'ESP', 6, 1, GETDATE()),
    (77, N'Proveedores', 2, 70, N'Proveedores', N'/configuracion/adquisiciones/proveedores', N'FaUsers', 1, N'ESP', 7, 1, GETDATE()),
    (78, N'Artí­culo', 2, 70, N'Artí­culo', N'/configuracion/adquisiciones/articulo', N'FaTag', 1, N'ESP', 8, 1, GETDATE()),
    (79, N'Fracción', 2, 70, N'Fracción', N'/configuracion/adquisiciones/fraccion', N'RiListCheck2', 1, N'ESP', 9, 1, GETDATE()),

    -- Configuración -> Patrimonio
    (90, N'Patrimonio', 1, 1, N'Patrimonio', N'/', N'FaFolder', 1, N'ESP', 4, 1, GETDATE()),
    (91, N'Familia', 2, 90, N'Familia', N'/configuracion/Patrimonio/Familia', N'FaFolder', 1, N'ESP', 1, 1, GETDATE()),
    (92, N'Grupo Bien', 2, 90, N'Grupo Bien', N'/configuracion/Patrimonio/Grupo_Bien', N'FaFolderOpen', 1, N'ESP', 2, 1, GETDATE()),
    (93, N'Bienes y Servicios', 2, 90, N'Bienes y Servicios', N'/configuracion/Patrimonio/Bienes_Servicios', N'FaTag', 1, N'ESP', 3, 1, GETDATE()),
    (94, N'Tipo de Patrimonio', 2, 90, N'Tipo de Patrimonio', N'/configuracion/Patrimonio/Tipo_Patrimonio', N'FaFolder', 1, N'ESP', 4, 1, GETDATE()),
    (95, N'Tipo de Adquisición', 2, 90, N'Tipo de Adquisición', N'/configuracion/Patrimonio/Tipo_Adquisicion', N'FaTag', 1, N'ESP', 5, 1, GETDATE()),
    (96, N'Marca', 2, 90, N'Marca', N'/configuracion/Patrimonio/Marca', N'FaStar', 1, N'ESP', 6, 1, GETDATE()),
    (97, N'Personas', 2, 90, N'Personas', N'/configuracion/Patrimonio/Personas', N'FaUsers', 1, N'ESP', 7, 1, GETDATE()),

    -- Configuración -> Almacén
    (100, N'Almacén', 1, 1, N'Almacén', N'/', N'FaFolderOpen', 1, N'ESP', 5, 1, GETDATE()),
    (101, N'Motivo de Entradas Salidas', 2, 100, N'Motivo de Entradas Salidas', N'/configuracion/almacen/Motivo_Entradas_Salidas', N'FaTools', 1, N'ESP', 1, 1, GETDATE()),
    (102, N'Estatus Solicitud', 2, 100, N'Estatus Solicitud', N'/configuracion/almacen/Estatus_Solicitud', N'FaFlag', 1, N'ESP', 2, 1, GETDATE()),
    (103, N'Unidades', 2, 100, N'Unidades', N'/configuracion/almacen/Unidades', N'RiListCheck2', 1, N'ESP', 3, 1, GETDATE()),
    (104, N'Periodo de Conteo', 2, 100, N'Periodo de Conteo', N'/configuracion/almacen/Perido_Conteo', N'FaCalendar', 1, N'ESP', 4, 1, GETDATE()),
    (105, N'Familia', 2, 100, N'Familia', N'/configuracion/almacen/Familia', N'FaFolder', 1, N'ESP', 5, 1, GETDATE()),
    (106, N'Tipo Bien', 2, 100, N'Tipo Bien', N'/configuracion/almacen/Tipo_Bien', N'FaTag', 1, N'ESP', 6, 1, GETDATE()),
    (107, N'Bien', 2, 100, N'Bien', N'/configuracion/almacen/Bien', N'FaTag', 1, N'ESP', 7, 1, GETDATE()),
    (108, N'Número Conteo', 2, 100, N'Número Conteo', N'/configuracion/almacen/Numero_Conteo', N'RiListCheck2', 1, N'ESP', 8, 1, GETDATE()),

    -- Configuración -> Tesorerí­a
    (120, N'Tesorerí­a', 1, 1, N'Tesorerí­a', N'/', N'FaChartLine', 1, N'ESP', 6, 1, GETDATE()),
    (121, N'Tipo de Cambio', 2, 120, N'Tipo de Cambio', N'/configuracion/tesoreria/Tipo_Cambio', N'FaChartLine', 1, N'ESP', 1, 1, GETDATE()),
    (122, N'Tipo Inversión', 2, 120, N'Tipo Inversión', N'/configuracion/tesoreria/Tipo_Inversion', N'FaChartBar', 1, N'ESP', 2, 1, GETDATE()),
    (123, N'Tipo Moneda', 2, 120, N'Tipo Moneda', N'/configuracion/tesoreria/Tipo_Moneda', N'FaTag', 1, N'ESP', 3, 1, GETDATE()),
    (124, N'Tipo de Pago', 2, 120, N'Tipo de Pago', N'/configuracion/tesoreria/Tipo_Pago', N'FaDocument', 1, N'ESP', 4, 1, GETDATE()),
    (125, N'Tipo de Pago SF', 2, 120, N'Tipo de Pago SF', N'/configuracion/tesoreria/Tipo_PagoSF', N'FaDocument', 1, N'ESP', 5, 1, GETDATE()),
    (126, N'Tipo Solicitud CLC', 2, 120, N'Tipo Solicitud CLC', N'/configuracion/tesoreria/Tipo_Solicitud_CLC', N'FaFile', 1, N'ESP', 6, 1, GETDATE()),
    (127, N'Tipo Documento CLC', 2, 120, N'Tipo Documento CLC', N'/configuracion/tesoreria/Tipo_Documento_CLC', N'FaDocument', 1, N'ESP', 7, 1, GETDATE()),

    -- Presupuesto -> Egreso
    (140, N'Egreso', 1, 2, N'Egreso', N'/', N'FaChartPie', 1, N'ESP', 1, 1, GETDATE()),
    (141, N'Planeación', 1, 140, N'Planeación', N'/', N'FaCalendar', 1, N'ESP', 1, 1, GETDATE()),
   
	(142, N'Catalogos de Planeación', 1, 141, N'Presupuesto Modificado', N'/', N'FaEdit', 1, N'ESP', 1, 1, GETDATE()),
	(143, N'Indicadores', 2, 142, N'Adecuaciones Compensadas', N'/Presupuesto/Egreso/Planeacion/Catalogos_Planeacion/Indicadores', N'FaDocument', 1, N'ESP', 1, 1, GETDATE()),
    (144, N'Resúmen Narrativo', 2, 142, N'Adecuaciones', N'/Presupuesto/Egreso/Planeacion/Catalogos_Planeacion/Resumen_Narrativo', N'FaDocument', 1, N'ESP', 2, 1, GETDATE()),

	(145, N'Anteproyecto de Egresos', 2, 141, N'Anteproyecto de Egresos', N'/Presupuesto/Egreso/Planeacion/Anteproyecto_Egresos', N'FaDocument', 1, N'ESP', 2, 1, GETDATE()),
	--falta autorizacion/desautorizacion de anteproyecto
	
	(146, N'Presupuesto Autorizado', 2, 140, N'Presupuesto Autorizado', N'/Presupuesto/Egreso/Presupuesto_Autorizado', N'FaLock', 1, N'ESP', 2, 1, GETDATE()),
    
	(147, N'Presupuesto Modificado', 1, 140, N'Presupuesto Modificado', N'/', N'FaEdit', 1, N'ESP', 3, 1, GETDATE()),
	(148, N'Adecuaciones Compensadas', 2, 147, N'Adecuaciones Compensadas', N'/Presupuesto/Egreso/Presupesto_Modificado/Adecuaciones_Compensadas', N'FaDocument', 1, N'ESP', 1, 1, GETDATE()),
    (149, N'Adecuaciones', 2, 147, N'Adecuaciones', N'/Presupuesto/Egreso/Presupesto_Modificado/Adecuaciones', N'FaDocument', 1, N'ESP', 2, 1, GETDATE()),
    (150, N'Reducciones', 2, 147, N'Reducciones', N'/Presupuesto/Egreso/Presupesto_Modificado/Reducciones', N'FaDocument', 1, N'ESP', 3, 1, GETDATE()),
    
	(151, N'Presupuesto Disponible PEF', 2, 140, N'Presupuesto Disponible PEF', N'/Presupuesto/Egreso/Presupuesto_Disponible', N'FaLock', 1, N'ESP', 4, 1, GETDATE()),

	(152, N'Presupuesto Comprometido', 1, 140, N'Presupuesto Comprometido', N'/', N'FaLock', 1, N'ESP', 5, 1, GETDATE()),
    (153, N'Solicitud Suficiencia', 2, 152, N'Solicitud Suficiencia', N'/Presupuesto/Egreso/Presupuesto_Comprometido/Solicitud_Suficiencia', N'FaDocument', 1, N'ESP', 1, 1, GETDATE()),
    (154, N'Autorización Suficiencia', 2, 152, N'Autorización Suficiencia', N'/Presupuesto/Egreso/Presupuesto_Comprometido/Autorizacion_Suficiencia', N'FaFlag', 1, N'ESP', 2, 1, GETDATE()),
    (155, N'Registro Comprometido', 2, 152, N'Registro Comprometido', N'/Presupuesto/Egreso/Presupuesto_Comprometido/Registro_Comprometido', N'FaSave', 1, N'ESP', 3, 1, GETDATE()),

    -- Presupuesto -> Tesorerí­a   -> Cuentas por Cobrar
    (160, N'Tesorerí­a', 1, 2, N'Tesorerí­a', N'/', N'FaChartLine', 1, N'ESP', 2, 1, GETDATE()),
    (161, N'Cuentas por Cobrar', 1, 160, N'Cuentas por Cobrar', N'/', N'FaDocument', 1, N'ESP', 1, 1, GETDATE()),
    (162, N'Ley de Ingresos Estimados', 2, 161, N'Ley de Ingresos Estimados', N'/Presupuesto/Tesoreria/Cuentas_Cobrar/Ingresos_Estimados', N'FaHome', 1, N'ESP', 1, 1, GETDATE()),
    
	(163, N'Modificado de Ingresos', 1, 161, N'Modificado de Ingresos', N'/', N'FaMoneyBillWave', 1, N'ESP', 2, 1, GETDATE()),
    (164, N'Adecuaciones Compensadas de Ingresos', 2, 163, N'Adecuaciones Compensadas de Ingresos', N'/Presupuesto/Tesoreria/Cuentas_Cobrar/Modificado_Ingreso/Adecuaciones_Compensadas_Ingresos', N'FaChartBar', 1, N'ESP', 1, 1, GETDATE()),
    (165, N'Aumentos al presupuesto de Ingresos', 2, 163, N'Aumentos al presupuesto de Ingresos', N'/Presupuesto/Tesoreria/Cuentas_Cobrar/Modificado_Ingreso/Aumentos_Presupuesto_Ingreso', N'FaChartLine', 1, N'ESP', 2, 1, GETDATE()),
    (166, N'Reduccion al presupuesto de Ingresos', 2, 163, N'Reduccion al presupuesto de Ingresos', N'/Presupuesto/Tesoreria/Cuentas_Cobrar/Modificado_Ingreso/Reduccion_Presupuesto_Ingreso', N'FaChartLine', 1, N'ESP', 3, 1, GETDATE()),

	(167, N'Ingresos Devengados', 1, 161, N'Ingresos Devengados', N'/', N'FaMoneyBillWave', 1, N'ESP', 3, 1, GETDATE()),
    (168, N'Ingresos (CLCs)', 2, 127, N'Ingresos (CLCs)', N'/Presupuesto/Tesoreria/Cuentas_Cobrar/Ingresos_Devengados/Ingresos', N'FaChartBar', 1, N'ESP', 1, 1, GETDATE()),
    (169, N'Ingresos Propios (Recibos y Facturas)', 2, 127, N'Ingresos Propios (Recibos y Facturas)', N'/Presupuesto/Tesoreria/Cuentas_Cobrar/Ingresos_Devengados/Ingresos_Propios', N'FaChartLine', 1, N'ESP', 2, 1, GETDATE()),
    
	(170, N'Ingresos por Recaudar', 2, 161, N'Ingresos por Recaudar', N'/Presupuesto/Tesoreria/Cuentas_Cobrar/Ingresos_Recaudar', N'FaHome', 1, N'ESP', 4, 1, GETDATE()),
	(171, N'Depósitos CLC', 2, 161, N'Depósitos CLC', N'/Presupuesto/Tesoreria/Cuentas_Cobrar/Depositos_CLC', N'FaHome', 1, N'ESP', 5, 1, GETDATE()),
	(172, N'Otros Ingresos', 2, 161, N'Otros Ingresos', N'/Presupuesto/Tesoreria/Cuentas_Cobrar/Otros_Ingresos', N'FaHome', 1, N'ESP', 6, 1, GETDATE()),

	(173, N'Reportes CxC', 1, 161, N'Reportes CxC', N'/', N'FaMoneyBillWave', 1, N'ESP', 7, 1, GETDATE()),
    (174, N'Antigüedad de saldos', 2, 173, N'Antigüedad de saldos', N'/Presupuesto/Tesoreria/Cuentas_Cobrar/Reportes_CxC/Antiguedad_Saldos', N'FaChartBar', 1, N'ESP', 1, 1, GETDATE()),
	(175, N'Integración de saldos', 2, 173, N'Integración de saldos', N'/Presupuesto/Tesoreria/Cuentas_Cobrar/Reportes_CxC/Integracion_Saldos', N'FaChartBar', 1, N'ESP', 2, 1, GETDATE()),
	(176, N'Estado de cuenta', 2, 173, N'Estado de cuenta', N'/Presupuesto/Tesoreria/Cuentas_Cobrar/Reportes_CxC/Estado_Cuenta', N'FaChartBar', 1, N'ESP', 3, 1, GETDATE()),
	(177, N'Análisis de saldos', 2, 173, N'Análisis de saldos', N'/Presupuesto/Tesoreria/Cuentas_Cobrar/Reportes_CxC/Analisis_Saldos', N'FaChartBar', 1, N'ESP', 4, 1, GETDATE()),
	(178, N'Consulta de documentos', 2, 173, N'Consulta de documentos', N'/Presupuesto/Tesoreria/Cuentas_Cobrar/Reportes_CxC/Consulta_Documentos', N'FaChartBar', 1, N'ESP', 5, 1, GETDATE()),
	
	 -- Presupuesto -> Tesorerí­a   -> Cuentas por Pagar
    (190, N'Cuentas por Pagar', 1, 160, N'Cuentas por Pagar', N'/', N'FaDocument', 1, N'ESP', 2, 1, GETDATE()),
	(191, N'PEF Unipartida TES', 1, 190, N'PEF Unipartida TES', N'/', N'FaDocument', 1, N'ESP', 1, 1, GETDATE()),
	(192, N'Recepción de Facturas y Comprobantes de Pago', 2, 191, N'Recepción de Facturas y Comprobantes de Pago', N'/Presupuesto/Tesoreria/CuentasXPagar/PEF_Unipartida_TES/Factura_Pago', N'FaFile', 1, N'ESP', 1, 1, GETDATE()),   
	(193, N'Provisión del Pago', 2, 191, N'Provisión del Pago', N'/Presupuesto/Tesoreria/CuentasXPagar/PEF_Unipartida_TES/Provision_Pago', N'FaClock', 1, N'ESP', 2, 1, GETDATE()),
    (194, N'Elaboración de Cheques o Transferencias', 2, 191, N'Elaboración de Cheques o Transferencias', N'/Presupuesto/Tesoreria/CuentasXPagar/PEF_Unipartida_TES/Cheque_Transferencia', N'FaSave', 1, N'ESP', 3, 1, GETDATE()), 
	
	-- Presupuesto -> Tesorerí­a
	(195, N'Planeación de gastos', 2, 160, N'Planeación de gastos', N'/Presupuesto/Tesoreria/Planeacion_Gastos', N'FaChartBar', 1, N'ESP', 3, 1, GETDATE()),
	(196, N'Saldos Cuentas', 2, 160, N'Saldos Cuentas', N'/Presupuesto/Tesoreria/Saldos_Cuentas', N'FaChartBar', 1, N'ESP', 4, 1, GETDATE()),
	(197, N'Solicitud de reintegros', 2, 160, N'Solicitud de reintegros', N'/Presupuesto/Tesoreria/Solicitud_Reintegros', N'FaChartBar', 1, N'ESP', 5, 1, GETDATE()),
	(198, N'Autorizar solicitud de reingresos', 2, 160, N'Autorizar solicitud de reingresos', N'/Presupuesto/Tesoreria/Autorizar_Solicitud_Reingresos', N'FaChartBar', 1, N'ESP', 6, 1, GETDATE()),
	(199, N'Provisión del Pago', 2, 160, N'Provisión del Pago', N'/Presupuesto/Tesoreria/Provision_Pago', N'FaChartBar', 1, N'ESP', 7, 1, GETDATE()),

	(200, N'Inversiones', 1, 160, N'Inversiones', N'/', N'FaChartBar', 1, N'ESP', 8, 1, GETDATE()),
    (201, N'Banco', 2, 200, N'Banco', N'/Presupuesto/Tesoreria/Inversiones/Banco', N'FaHome', 1, N'ESP', 1, 1, GETDATE()),
    (202, N'Cuenta Bancaria', 2, 200, N'Cuenta Bancaria', N'/Presupuesto/Tesoreria/Inversiones/Cuenta_Bancaria', N'FaFile', 1, N'ESP', 2, 1, GETDATE()),
    (203, N'Intermediarios Financiero', 2, 200, N'Intermediarios Financiero', N'/Presupuesto/Tesoreria/Inversiones/Intermediarios_Financiero', N'FaUsers', 1, N'ESP', 3, 1, GETDATE()),
    (204, N'Instrumentos de Inversión', 2, 200, N'Instrumentos de Inversión', N'/Presupuesto/Tesoreria/Instrumentos_Inversion', N'FaChartPie', 1, N'ESP', 4, 1, GETDATE()),
    (205, N'Listado de Inversiones', 2, 200, N'Listado de Inversiones', N'/Presupuesto/Tesoreria/Inversiones/Listado_Inversiones', N'RiListCheck2', 1, N'ESP', 5, 1, GETDATE()),
    (206, N'Tipo de Instrumentos', 2, 200, N'Tipo de Instrumentos', N'/Presupuesto/Tesoreria/Inversiones/Tipo_Instrumentos', N'FaClock', 1, N'ESP', 6, 1, GETDATE()),
	(207, N'Tipo de Plazos', 2, 200, N'Tipo de Plazos', N'/Presupuesto/Tesoreria/Inversiones/Tipo_Plazos', N'FaClock', 1, N'ESP', 7, 1, GETDATE()),
    (208, N'Tipo de Retiro', 2, 200, N'Tipo de Retiro', N'/Presupuesto/Tesoreria/Inversiones/Tipo_Retiro', N'FaLockOpen', 1, N'ESP', 8, 1, GETDATE()),
	(209, N'Simulador', 2, 200, N'Simulador', N'/Presupuesto/Tesoreria/Inversiones/Simulador', N'FaClock', 1, N'ESP', 9, 1, GETDATE()),

    -- Contabilidad
    (220, N'Pólizas', 2, 3, N'Pólizas', N'/Contabilidad/Polizas', N'FaDocument', 1, N'ESP', 1, 1, GETDATE()),
	(221, N'Autorización de Pólizas', 2, 3, N'Autorización de Pólizas', N'/Contabilidad/Autorizacion_Polizas', N'FaDocument', 1, N'ESP', 2, 1, GETDATE()),
	(222, N'Balanza de Comprobación', 2, 3, N'Balanza de Comprobación', N'/Contabilidad/Balanza_Comprobacion', N'FaDocument', 1, N'ESP', 3, 1, GETDATE()),
	(223, N'Auxiliares', 2, 3, N'Auxiliares', N'/Contabilidad/Auxiliares', N'FaDocument', 1, N'ESP', 4, 1, GETDATE()),

	(224, N'Reportes Contabilidad', 1, 3, N'Reportes Contabilidad', N'/', N'FaDocument', 1, N'ESP', 5, 1, GETDATE()),
	(225, N'Libro Diario', 2, 224, N'Libro Diario', N'/Contabilidad/Reportes_Contabilidad/Libro_Diario', N'FaDocument', 1, N'ESP', 1, 1, GETDATE()),
	(226, N'Libro Mayor', 2, 224, N'Libro Mayor', N'/Contabilidad/Reportes_Contabilidad/Libro_Mayor', N'FaDocument', 1, N'ESP', 2, 1, GETDATE()),
	(227, N'Libro Inventarios Materiales', 2, 224, N'Libro Inventarios Materiales', N'/Contabilidad/Reportes_Contabilidad/Libro_Inventarios_Materiales', N'FaDocument', 1, N'ESP', 3, 1, GETDATE()),
	(228, N'Libro Almacén Suministros', 2, 224, N'Libro Almacén Suministros', N'/Contabilidad/Reportes_Contabilidad/Libro_Almacen_Suministros', N'FaDocument', 1, N'ESP', 4, 1, GETDATE()),
	(229, N'Libro Inventarios Muebles', 2, 224, N'Libro Inventarios Muebles', N'/Contabilidad/Reportes_Contabilidad/Libro_Inventarios_Muebles', N'FaDocument', 1, N'ESP', 5, 1, GETDATE()),
	(230, N'Pólizas', 2, 224, N'Pólizas', N'/Contabilidad/Reportes_Contabilidad/Polizas', N'FaDocument', 1, N'ESP', 6, 1, GETDATE()),
	(231, N'Reporte de Retenciones', 2, 224, N'Reporte de Retenciones', N'/Contabilidad/Reportes_Contabilidad/Reporte_Retenciones', N'FaDocument', 1, N'ESP', 7, 1, GETDATE()),
	(232, N'Reporte de Depreciación Acumulada', 2, 224, N'Reporte de Depreciación Acumulada', N'/Contabilidad/Reportes_Contabilidad/Reporte_Depreciacion_Acumulada', N'FaDocument', 1, N'ESP', 8, 1, GETDATE()),
	(233, N'Reporte de Activos Fijos', 2, 224, N'Reporte de Activos Fijos', N'/Contabilidad/Reportes_Contabilidad/Reporte_Activos_Fijos', N'FaDocument', 1, N'ESP', 9, 1, GETDATE()),
	(234, N'Reporte de Facturas Emitidas', 2, 224, N'Reporte de Facturas Emitidas', N'/Contabilidad/Reportes_Contabilidad/Reporte_Facturas_Emitidas', N'FaDocument', 1, N'ESP', 10, 1, GETDATE()),
	(235, N'Reporte DIOT', 2, 224, N'Reporte DIOT', N'/Contabilidad/Reportes_Contabilidad/Reporte_DIOT', N'FaDocument', 1, N'ESP', 11, 1, GETDATE()),

	(236, N'Estados e Información Contable', 1, 3, N'Estados e Información Contable', N'/', N'FaDocument', 1, N'ESP', 6, 1, GETDATE()),
	(237, N'Estados de Actividades', 2, 236, N'Estados de Actividades', N'/Contabilidad/EI_Contable/Estados_Actividades', N'FaDocument', 1, N'ESP', 1, 1, GETDATE()),
	(238, N'Estado de Situación Financiera', 2, 236, N'Estado de Situación Financiera', N'/Contabilidad/EI_Contable/Estado_Situacion_Financiera', N'FaDocument', 1, N'ESP', 2, 1, GETDATE()),
	(239, N'Estado de Variaciones en la Hacienda Pública', 2, 236, N'Estado de Variaciones en la Hacienda Pública', N'/Contabilidad/EI_Contable/Estado_VHP', N'FaDocument', 1, N'ESP', 3, 1, GETDATE()),
	(240, N'Estados de Cambios en la Situación Financiera', 2, 236, N'Estados de Cambios en la Situación Financiera', N'/Contabilidad/EI_Contable/Estados_CSF', N'FaDocument', 1, N'ESP', 4, 1, GETDATE()),
	(241, N'Estado de Flujos de Efectivo', 2, 236, N'Estado de Flujos de Efectivo', N'/Contabilidad/EI_Contable/Estado_Flujos_Efectivo', N'FaDocument', 1, N'ESP', 5, 1, GETDATE()),
	(242, N'Estado Analítico del Activo', 2, 236, N'Estado Analítico del Activo', N'/Contabilidad/EI_Contable/Estado_Analitico_Activo', N'FaDocument', 1, N'ESP', 6, 1, GETDATE()),
	(243, N'Estado Analítico de la Deuda y Otros Pasivos', 2, 236, N'Estado Analítico de la Deuda y Otros Pasivos', N'/Contabilidad/EI_Contable/Estado_ADOP', N'FaDocument', 1, N'ESP', 7, 1, GETDATE()),
	(244, N'Informe sobre Pasivos Contingentes', 2, 236, N'Informe sobre Pasivos Contingentes', N'/Contabilidad/EI_Contable/Informe_Pasivos_Contingentes', N'FaDocument', 1, N'ESP', 8, 1, GETDATE()),
	(245, N'Notas Estados Financieros', 2, 236, N'Notas Estados Financieros', N'/Contabilidad/EI_Contable/Notas_Estados_Financieros', N'FaDocument', 1, N'ESP', 9, 1, GETDATE()),

	(246, N'Conciliación Ingresos-Egresos', 2, 3, N'Conciliación Ingresos-Egresos', N'/Contabilidad/Conciliacion_IE', N'FaDocument', 1, N'ESP', 7, 1, GETDATE()),

	(247, N'Estados e Informes Presupuestarios', 1, 3, N'Estados e Informes Presupuestarios', N'/', N'FaDocument', 1, N'ESP', 8, 1, GETDATE()),
	(248, N'Estado Analítico de Ingresos', 2, 247, N'Estado Analítico de Ingresos', N'/Contabilidad/EI_Presupuestarios/Estado_Analitico_Ingresos', N'FaDocument', 1, N'ESP', 1, 1, GETDATE()),
	(249, N'Estado Analítico de Egresos con Clasificación Administrativa', 2, 247, N'Estado Analítico de Egresos con Clasificación Administrativa', N'/Contabilidad/EI_Presupuestarios/Estado_AECA', N'FaDocument', 1, N'ESP', 2, 1, GETDATE()),
	(250, N'Estado Analítico de Egresos con Clasificación Económica', 2, 247, N'Estado Analítico de Egresos con Clasificación Económica', N'/Contabilidad/EI_Presupuestarios/Estado_AECE', N'FaDocument', 1, N'ESP', 3, 1, GETDATE()),
	(251, N'Estado Analítico de Egresos con Clasificación por Objeto del Gasto', 2, 247, N'Estado Analítico de Egresos con Clasificación por Objeto del Gasto', N'/Contabilidad/EI_Presupuestarios/Estado_AECOG', N'FaDocument', 1, N'ESP', 4, 1, GETDATE()),
	(252, N'Estado Analítico de Egresos con Clasificación Funcional', 2, 247, N'Estado Analítico de Egresos con Clasificación Funcional', N'/Contabilidad/EI_Presupuestarios/Estado_AECF', N'FaDocument', 1, N'ESP', 5, 1, GETDATE()),
	(253, N'Endeudamiento Neto', 2, 247, N'Endeudamiento Neto', N'/Contabilidad/EI_Presupuestarios/Endeudamiento_Neto', N'FaDocument', 1, N'ESP', 6, 1, GETDATE()),
	(254, N'Intereses de la Deuda', 2, 247, N'Intereses de la Deuda', N'/Contabilidad/EI_Presupuestarios/Intereses_Deuda', N'FaDocument', 1, N'ESP', 7, 1, GETDATE()),
	(255, N'Proyecciones de Egresos', 2, 247, N'Proyecciones de Egresos', N'/Contabilidad/EI_Presupuestarios/Proyecciones_Egresos', N'FaDocument', 1, N'ESP', 8, 1, GETDATE()),
	(256, N'Proyecciones de Ingresos', 2, 247, N'Proyecciones de Ingresos', N'/Contabilidad/EI_Presupuestarios/Proyecciones_Ingresos', N'FaDocument', 1, N'ESP', 9, 1, GETDATE()),
	(257, N'Indicadores Asociados a Programas Presupuestarios', 2, 247, N'Indicadores Asociados a Programas Presupuestarios', N'/Contabilidad/EI_Presupuestarios/Indicadores_APP', N'FaDocument', 1, N'ESP', 10, 1, GETDATE()),
	(258, N'Programas y proyectos de Inversión', 2, 247, N'Programas y proyectos de Inversión', N'/Contabilidad/EI_Presupuestarios/Pp_Inversion', N'FaDocument', 1, N'ESP', 11, 1, GETDATE()),
	(259, N'Resultados de Ingresos', 2, 247, N'Resultados de Ingresos', N'/Contabilidad/EI_Presupuestarios/Resultados_Ingresos', N'FaDocument', 1, N'ESP', 12, 1, GETDATE()),
	(260, N'Resultados de Egresos', 2, 247, N'Resultados de Egresos', N'/Contabilidad/EI_Presupuestarios/Resultados_Egresos', N'FaDocument', 1, N'ESP', 13, 1, GETDATE()),

	(261, N'Estados e Informes Programaticos', 2, 3, N'Estados e Informes Programaticos', N'/Contabilidad/EI_Programaticos', N'FaDocument', 1, N'ESP', 9, 1, GETDATE()),
	(262, N'Indicadores de Postura Fiscal', 2, 3, N'Indicadores de Postura Fiscal', N'/Contabilidad/Indicadores_Postura_Fiscal', N'FaDocument', 1, N'ESP', 10, 1, GETDATE()),
	(263, N'Cierre Mensual', 2, 3, N'Cierre Mensual', N'/Contabilidad/Cierre_Mensual', N'FaDocument', 1, N'ESP', 11, 1, GETDATE()),
	--Aqui voy bien

    -- Adquisiciones
    (300, N'Programa Anual', 2, 4, N'Programa Anual', N'/Adquisiciones/Programa_Anual', N'FaCalendar', 1, N'ESP', 1, 1, GETDATE()),
    (301, N'Requisición', 2, 4, N'Requisición', N'/Adquisiciones/Requisicion', N'RiListCheck2', 1, N'ESP', 2, 1, GETDATE()),
    (302, N'Cotización', 2, 4, N'Cotización', N'/Adquisiciones/Cotizacion', N'FaDocument', 1, N'ESP', 3, 1, GETDATE()),
    (303, N'Solicitud Suficiencia', 2, 4, N'Solicitud Suficiencia', N'/Adquisiciones/Solicitud_Suficiencia', N'FaDocument', 1, N'ESP', 4, 1, GETDATE()),
    (304, N'Orden de Compra', 2, 4, N'Orden de Compra', N'/Adquisiciones/Orden_Compra', N'FaDocument', 1, N'ESP', 5, 1, GETDATE()),

    (310, N'Contratos', 1, 4, N'Contratos', N'/', N'FaCalendar', 1, N'ESP', 6, 1, GETDATE()),
    (311, N'Registro de Compromiso', 2, 310, N'Registro de Compromiso', N'/Adquisiciones/Contratos/Registro_Compromiso', N'FaCalendar', 1, N'ESP', 1, 1, GETDATE()),
    (312, N'Saldos de Contratos', 2, 310, N'Saldos de Contratos', N'/Adquisiciones/Contratos/Saldos_Contratos', N'FaCalendar', 1, N'ESP', 2, 1, GETDATE()),
    (313, N'Estado de Contratos', 2, 310, N'Estado de Contratos', N'/Adquisiciones/Contratos/Estado_Contrato', N'FaCalendar', 1, N'ESP', 3, 1, GETDATE()),

    -- Patrimonio
    (400, N'Bienes', 2, 5, N'Bienes', N'/Patrimonio/Bienes', N'FaFolderOpen', 1, N'ESP', 6, 1, GETDATE()),
    (401, N'Clasificación de Bienes Muebles', 2, 5, N'Clasificación de Bienes Muebles', N'/Patrimonio/Clasificacion_Bienes_Muebles', N'FaFolder', 1, N'ESP', 2, 1, GETDATE()),
    (402, N'Bajas', 2, 5, N'Bajas', N'/Patrimonio/Bajas', N'FaTrash', 1, N'ESP', 3, 1, GETDATE()),
    (403, N'Calendario de Inventarios', 2, 5, N'Calendario de Inventarios', N'/Patrimonio/Calendario_Inventarios', N'FaCalendar', 1, N'ESP', 4, 1, GETDATE()),
    (404, N'Inventarios', 2, 5, N'Inventarios', N'/Patrimonio/Inventarios', N'RiListCheck2', 1, N'ESP', 5, 1, GETDATE()),
    (405, N'Cédula de Diferencia', 2, 5, N'Cédula de Diferencia', N'/Patrimonio/Cedula_Diferencia', N'FaDocument', 1, N'ESP', 6, 1, GETDATE()),
    (406, N'Resguardos', 2, 5, N'Resguardos', N'/Patrimonio/Resguardos', N'FaLock', 1, N'ESP', 7, 1, GETDATE()),
    (407, N'Firma Resguardos', 2, 5, N'Firma Resguardos', N'/Patrimonio/Firma_Resguardos', N'FaEdit', 1, N'ESP', 8, 1, GETDATE()),
    (408, N'Resguardo Histórico', 2, 5, N'Resguardo Histórico', N'/Patrimonio/Resguardo_Historico', N'FaFile', 1, N'ESP', 9, 1, GETDATE()),

    -- Almacén
    (500, N'Recepción de Pedidos', 2, 6, N'Recepción de Pedidos', N'/Almacen/Recepcion_Pedidos', N'FaFolderOpen', 1, N'ESP', 1, 1, GETDATE()),
    (501, N'Entradas por Ajuste', 2, 6, N'Entradas por Ajuste', N'/Almacen/Entradas_Ajuste', N'FaPlus', 1, N'ESP', 2, 1, GETDATE()),
    (502, N'Solicitudes de Salida', 2, 6, N'Solicitudes de Salida', N'/Almacen/Solicitudes_Salida', N'RiListCheck2', 1, N'ESP', 3, 1, GETDATE()),
    (503, N'Suministros de Salida', 2, 6, N'Suministros de Salida', N'/Almacen/Suministros_Salida', N'FaFile', 1, N'ESP', 4, 1, GETDATE()),
    (504, N'Existencias Registradas', 2, 6, N'Existencias Registradas', N'/Almacen/Existencias_Registradas', N'FaTable', 1, N'ESP', 5, 1, GETDATE()),
    (505, N'Conteo Cí­clico', 2, 6, N'Conteo Cí­clico', N'/Almacen/Conteo_ciclico', N'RiListCheck2', 1, N'ESP', 6, 1, GETDATE()),
    (506, N'Reporte de Diferencias de Conteo', 2, 6, N'Reporte de Diferencias de Conteo', N'/Almacen/Reporte_diferencias_Conteo', N'FaChartBar', 1, N'ESP', 7, 1, GETDATE()),
    (507, N'Conteo Cí­clico Anual', 2, 6, N'Conteo Cí­clico Anual', N'/Almacen/Conteo_ciclico_anual', N'FaCalendar', 1, N'ESP', 8, 1, GETDATE()),
    (508, N'Reporte de Diferencias de Conteo Anual', 2, 6, N'Reporte de Diferencias de Conteo Anual', N'/Almacen/Reporte_diferencias_Conteo_anual', N'FaChartLine', 1, N'ESP', 9, 1, GETDATE()),

    -- Nómina -> Recursos Humanos
    (600, N'Recursos Humanos', 1, 7, N'Nomina_Recursos_Humanos', N'/', N'FaUsers', 1, N'ESP', 1, 1, GETDATE()),
    (601, N'Empleados', 2, 600, N'Empleados', N'/nomina/empleados', N'FaUser', 1, N'ESP', 1, 1, GETDATE()),
    (602, N'Movimientos de Personal', 2, 600, N'Movimientos_Personal', N'/nomina/movimientos', N'FaEdit', 1, N'ESP', 2, 1, GETDATE()),
    (603, N'De Personal', 2, 600, N'De_Personal', N'/nomina/depersonal', N'FaUsers', 1, N'ESP', 3, 1, GETDATE()),
    (604, N'Reporte Quincenal MP', 2, 600, N'Reporte_Quincenal_MP', N'/nomina/reportequincenal', N'FaDateRange', 1, N'ESP', 4, 1, GETDATE()),
    (605, N'Créditos Trabajadores', 2, 600, N'Creditos_Trabajadores', N'/nomina/creditos', N'FaMoneyBillWave', 1, N'ESP', 5, 1, GETDATE()),

    -- Nómina -> Cálculo
    (610, N'Cálculo', 1, 7, N'Nomina_Calculo', N'/nom/calcnomina', N'FaCalculate', 1, N'ESP', 2, 1, GETDATE()),

    -- Nómina -> Auxiliares
    (620, N'Auxiliares', 1, 7, N'Nomina_Auxiliares', N'/', N'FaFolderOpen', 1, N'ESP', 3, 1, GETDATE()),
    (621, N'Calculo ISSSTE', 2, 620, N'Calculo_ISSSTE_4134', N'/aux/auxcalcissste', N'FaPercent', 1, N'ESP', 1, 1, GETDATE()),
    (622, N'Calculo ISR', 2, 620, N'Calculo_ISR_2053', N'/aux/auxcalcisrquincenal', N'FaPercent', 1, N'ESP', 2, 1, GETDATE()),
    (623, N'Calculo FOVISSSTE', 2, 620, N'Calculo_FOVISSSTE_4136', N'/aux/auxcalcfovissste', N'FaHouse', 1, N'ESP', 3, 1, GETDATE()),
    (624, N'Calculo Infonavit', 2, 620, N'Calculo_Infonavit_139', N'/aux/auxcalcinfonavitquincenal', N'FaHomeWork', 1, N'ESP', 4, 1, GETDATE()),
    (625, N'Calculo Cuotas IMSS', 2, 620, N'Calculo_IMSS_3084', N'/aux/auxcalcimssquincenal', N'FaPercent', 1, N'ESP', 5, 1, GETDATE()),

    -- Nómina -> Productos
    (630, N'Productos', 1, 7, N'Nomina_Productos', N'/', N'FaFolderOpen', 1, N'ESP', 4, 1, GETDATE()),
    (631, N'Resumen', 2, 630, N'Resumen_Nomina', N'/nom/resumennomina', N'FaChartPie', 1, N'ESP', 1, 1, GETDATE()),
    (632, N'Recibos', 2, 630, N'Recibos_Nomina', N'/nom/recibonomina', N'FaReceiptLong', 1, N'ESP', 2, 1, GETDATE()),
    (633, N'Archivos de Dispersión', 2, 630, N'Archivos_Dispersion', N'/nom/archivodispercion', N'FaFile', 1, N'ESP', 3, 1, GETDATE()),
    (634, N'Archivos de Timbrado', 2, 630, N'Archivos_Timbrado', N'/nom/timbradopercepciones', N'FaVerified', 1, N'ESP', 4, 1, GETDATE()),
    (635, N'Reporte Cuotas IMSS', 2, 630, N'Reporte_IMSS', N'/aux/imssquincenal_rep', N'FaChartBar', 1, N'ESP', 5, 1, GETDATE()),
    (636, N'Reporte Nómina Actual', 2, 630, N'Reporte_Nomina', N'/nom/reportenomina', N'FaDocument', 1, N'ESP', 6, 1, GETDATE()),

    -- Nómina -> Incidencias
    (640, N'Incidencias', 1, 7, N'Nomina_Incidencias', N'/', N'RiListCheck2', 1, N'ESP', 5, 1, GETDATE()),
    (641, N'Captura de Incidencias', 2, 640, N'Captura_Incidencias', N'/rh/incidencia', N'FaEdit', 1, N'ESP', 1, 1, GETDATE()),
    (642, N'Justificación de Incidencias', 2, 640, N'Justificacion_Incidencias', N'/rh/justificacion', N'FaVerified', 1, N'ESP', 2, 1, GETDATE()),
    (643, N'Reporte de Incidencias', 2, 640, N'Reporte_Incidencias', N'/rh/incidenciareport', N'FaChartLine', 1, N'ESP', 3, 1, GETDATE()),

    -- Nómina -> Pagos Extraordinarios
    (650, N'Pagos Extraordinarios', 1, 7, N'Concepto_Variable', N'/nom/conceptovariable', N'FaAttachMoney', 1, N'ESP', 6, 1, GETDATE()),

    -- Nómina -> Cierre de Periodo
    (660, N'Cierre de Periodo', 1, 7, N'Nomina_Cierre_Periodo', N'/nom/cierraperiodo', N'FaLock', 1, N'ESP', 7, 1, GETDATE()),

    -- Nómina -> Finiquito/Liquidación
    (670, N'Finiquito/Liquidación', 1, 7, N'Nomina_Finiquito_Liquidacion', N'/rh/liquidacion', N'FaReceiptLong', 1, N'ESP', 8, 1, GETDATE()),

    -- Nómina -> Nóminas Especiales
    (680, N'Nominas Especiales', 1, 7, N'Nominas_Especiales', N'/', N'FaCog', 1, N'ESP', 9, 1, GETDATE()),
    (681, N'Cálculo de Aguinaldo', 2, 680, N'Calc_Aguinaldo', N'/nom/calcaguinaldo', N'FaStar', 1, N'ESP', 1, 1, GETDATE()),
    (682, N'Configura Aguinaldo', 2, 680, N'Configura_Aguinaldo', N'/sis/nominaespecial', N'FaCog', 1, N'ESP', 2, 1, GETDATE()),
    (683, N'Aguinaldo', 2, 680, N'Aguinaldo', N'/sis/vwnominaespecial', N'FaStar', 1, N'ESP', 3, 1, GETDATE()),
    (684, N'Faltas Especiales', 2, 680, N'Faltas_Especial', N'/emp/faltasxempresa', N'FaClock', 1, N'ESP', 4, 1, GETDATE()),

    -- Nómina -> Históricos
    (700, N'Históricos de Nómina', 0, 7, N'Nomina_Historicos', N'/', N'FaClock', 1, N'ESP', 10, 1, GETDATE()),
    (710, N'Productos', 1, 700, N'Nomina_Productos_Historicos', N'/', N'FaFolderOpen', 1, N'ESP', 1, 1, GETDATE()),
    (711, N'Consulta de Nómina', 2, 710, N'Consulta_Nomina', N'/nomina/historicos/consulta', N'FaSearch', 1, N'ESP', 1, 1, GETDATE()),
    (712, N'Análisis', 2, 710, N'Analisis', N'/nomina/historicos/analisis', N'FaChartLine', 1, N'ESP', 2, 1, GETDATE()),
    (713, N'Recibos', 2, 710, N'Recibos_Historicos', N'/nomina/historicos/recibos', N'FaReceiptLong', 1, N'ESP', 3, 1, GETDATE()),
    (714, N'Archivos de Dispersión', 2, 710, N'Archivos_Dispersion_Historicos', N'/nomina/historicos/dispersion', N'FaFile', 1, N'ESP', 4, 1, GETDATE()),
    (715, N'Archivos de Timbrado', 2, 710, N'Archivos_Timbrado_Historicos', N'/nomina/historicos/timbrado', N'FaVerified', 1, N'ESP', 5, 1, GETDATE()),
    (716, N'Reporte Nómina Quincenal', 2, 710, N'Reporte_Nomina_Quincenal', N'/nomina/historicos/reportequincenal', N'FaDateRange', 1, N'ESP', 6, 1, GETDATE()),
    (717, N'Resumen de Nómina Histórica', 2, 710, N'Resumen_Nomina_Historica', N'/nomina/historicos/resumen', N'FaChartPie', 1, N'ESP', 7, 1, GETDATE()),
    (718, N'Reporte de Nómina Histórica', 2, 710, N'Reporte_Nomina_Historica', N'/nomina/historicos/reportehistorico', N'FaDocument', 1, N'ESP', 8, 1, GETDATE()),
    (719, N'Cubo Nómina Histórica', 2, 710, N'Cubo_Nomina_Historica', N'/nomina/historicos/cubo', N'FaTable', 1, N'ESP', 9, 1, GETDATE()),

    (720, N'Reportes del IMSS', 1, 700, N'Reportes_IMSS_Historicos', N'/', N'FaChartBar', 1, N'ESP', 2, 1, GETDATE()),
    (721, N'Salario Base de Cotización', 2, 720, N'Salario_Base_Cotizacion', N'/nomina/historicos/sbc', N'FaPercent', 1, N'ESP', 1, 1, GETDATE()),
    (722, N'Acumulados IMSS', 2, 720, N'Acumulados_IMSS', N'/nomina/historicos/acumuladosimss', N'FaChartBar', 1, N'ESP', 2, 1, GETDATE()),
    (723, N'SBC Histórico', 2, 720, N'SBC_Historico', N'/nomina/historicos/sbchistorico', N'FaClock', 1, N'ESP', 3, 1, GETDATE()),
    (724, N'Acumulados en el Bimestre IMSS', 2, 720, N'Acumulados_Bimestre_IMSS', N'/nomina/historicos/acumuladosbimestre', N'FaDateRange', 1, N'ESP', 4, 1, GETDATE()),

    (730, N'Reportes del SAT', 1, 700, N'Reportes_SAT_Historicos', N'/', N'FaChartLine', 1, N'ESP', 3, 1, GETDATE()),
    (731, N'Acumulado Mensual ISR', 2, 730, N'Acumulado_Mensual_ISR', N'/nomina/historicos/isr_mensual', N'FaPercent', 1, N'ESP', 1, 1, GETDATE()),
    (732, N'Acumulados de ISR', 2, 730, N'Acumulados_ISR', N'/nomina/historicos/isr_acumulados', N'FaChartLine', 1, N'ESP', 2, 1, GETDATE()),

    (740, N'Impuestos sobre Nómina locales', 1, 700, N'Impuestos_Locales_Historicos', N'/nomina/historicos/impuestoslocales', N'FaHouse', 1, N'ESP', 4, 1, GETDATE()),

    -- Nómina -> Configuración Nóminas
    (800, N'Configuración Nóminas', 0, 7, N'Configuracion_Nominas', N'/', N'FaCog', 1, N'ESP', 11, 1, GETDATE()),
    (810, N'Catálogos', 1, 800, N'Nomina_Catalogos', N'/', N'FaFolderOpen', 1, N'ESP', 1, 1, GETDATE()),
    (811, N'Tipo de Nómina', 2, 810, N'Tipo_Nomina', N'/nomina/configuracion/catalogos/tipo-nomina', N'FaEventAvailable', 1, N'ESP', 1, 1, GETDATE()),
    (812, N'Cuotas IMSS', 2, 810, N'Cuotas_IMSS', N'/nomina/configuracion/catalogos/cuotas-imss', N'FaPercent', 1, N'ESP', 2, 1, GETDATE()),
    (813, N'Conceptos de Nómina', 2, 810, N'Conceptos_Nomina', N'/nomina/configuracion/catalogos/conceptos', N'FaPayments', 1, N'ESP', 3, 1, GETDATE()),
    (814, N'UMA', 2, 810, N'UMA', N'/nomina/configuracion/catalogos/uma', N'FaPriceChange', 1, N'ESP', 4, 1, GETDATE()),
    (815, N'Tipo de Contratación', 2, 810, N'Tipo_Contratacion', N'/nomina/configuracion/catalogos/tipo-contratacion', N'FaUserGroup', 1, N'ESP', 5, 1, GETDATE()),
    (816, N'Tipo de descanso', 2, 810, N'Tipo_Descanso', N'/nomina/configuracion/catalogos/tipo-descanso', N'FaClock', 1, N'ESP', 6, 1, GETDATE()),
    (817, N'Tipo de Incidencia', 2, 810, N'Tipo_Incidencia', N'/nomina/configuracion/catalogos/tipo-incidencia', N'FaSick', 1, N'ESP', 7, 1, GETDATE()),
    (818, N'Conceptos de importe Fijo', 2, 810, N'Concepto_Fijo', N'/nomina/configuracion/catalogos/concepto-fijo', N'FaAttachMoney', 1, N'ESP', 8, 1, GETDATE()),
    (819, N'Tipo de Justificación', 2, 810, N'Tipo_Justificacion', N'/nomina/configuracion/catalogos/tipo-justificacion', N'FaVerified', 1, N'ESP', 9, 1, GETDATE()),
    (820, N'Tabulador', 2, 810, N'Tabulador', N'/nomina/configuracion/catalogos/tabulador', N'FaTableRows', 1, N'ESP', 10, 1, GETDATE()),
    (821, N'Unidad Infonavit', 2, 810, N'Unidad_Infonavit', N'/nomina/configuracion/catalogos/unidad-infonavit', N'FaHomeWork', 1, N'ESP', 11, 1, GETDATE()),
    (822, N'Salario Mí­nimo General', 2, 810, N'Salario_Minimo', N'/nomina/configuracion/catalogos/smg', N'FaMoneyBillWave', 1, N'ESP', 12, 1, GETDATE()),
    (823, N'Forma de Pago', 2, 810, N'Forma_Pago', N'/nomina/configuracion/catalogos/forma-pago', N'FaPointOfSale', 1, N'ESP', 13, 1, GETDATE()),
    (824, N'Forma de Cálculo', 2, 810, N'Forma_Calculo', N'/nomina/configuracion/catalogos/forma-calculo', N'FaFunctions', 1, N'ESP', 14, 1, GETDATE()),
    (825, N'Capí­tulos', 2, 810, N'Capitulos', N'/nomina/configuracion/catalogos/capitulos', N'RiListCheck2', 1, N'ESP', 15, 1, GETDATE()),

    (830, N'Periodos', 1, 800, N'Nomina_Periodos', N'/', N'FaCalendarMonth', 1, N'ESP', 2, 1, GETDATE()),
    (831, N'Semanal', 2, 830, N'Periodo_Semanal', N'/nomina/configuracion/periodos/semanal', N'FaViewWeek', 1, N'ESP', 1, 1, GETDATE()),
    (832, N'Quincenal', 2, 830, N'Periodo_Quincenal', N'/nomina/configuracion/periodos/quincenal', N'FaDateRange', 1, N'ESP', 2, 1, GETDATE()),
    (833, N'Mensual', 2, 830, N'Periodo_Mensual', N'/nomina/configuracion/periodos/mensual', N'FaCalendarMonth', 1, N'ESP', 3, 1, GETDATE()),
    (834, N'Bimestral', 2, 830, N'Periodo_Bimestral', N'/nomina/configuracion/periodos/bimestral', N'FaCalendar', 1, N'ESP', 4, 1, GETDATE()),

    (840, N'Tablas ISR', 1, 800, N'Nomina_Tablas_ISR', N'/', N'FaTable', 1, N'ESP', 3, 1, GETDATE()),
    (841, N'Semanal', 2, 840, N'Tabla_ISR_Semanal', N'/nomina/configuracion/isr/semanal', N'FaPercent', 1, N'ESP', 1, 1, GETDATE()),
    (842, N'Quincenal', 2, 840, N'Tabla_ISR_Quincenal', N'/nomina/configuracion/isr/quincenal', N'FaPercent', 1, N'ESP', 2, 1, GETDATE()),
    (843, N'Mensual', 2, 840, N'Tabla_ISR_Mensual', N'/nomina/configuracion/isr/mensual', N'FaPercent', 1, N'ESP', 3, 1, GETDATE()),

    (850, N'Prestaciones', 1, 800, N'Nomina_Prestaciones', N'/', N'FaStar', 1, N'ESP', 4, 1, GETDATE()),

    (860, N'Subsidios ISR', 1, 800, N'Nomina_Subsidios_ISR', N'/', N'FaPercent', 1, N'ESP', 5, 1, GETDATE()),
    (861, N'Semanal', 2, 860, N'Subsidio_ISR_Semanal', N'/nomina/configuracion/subsidios/semanal', N'FaPercent', 1, N'ESP', 1, 1, GETDATE()),
    (862, N'Quincenal', 2, 860, N'Subsidio_ISR_Quincenal', N'/nomina/configuracion/subsidios/quincenal', N'FaPercent', 1, N'ESP', 2, 1, GETDATE()),
    (863, N'Mensual', 2, 860, N'Subsidio_ISR_Mensual', N'/nomina/configuracion/subsidios/mensual', N'FaPercent', 1, N'ESP', 3, 1, GETDATE()),

    (870, N'Impuestos', 1, 800, N'Nomina_Impuestos', N'/', N'FaPercent', 1, N'ESP', 6, 1, GETDATE()),
    (871, N'Base Gravable', 2, 870, N'Base_Gravable', N'/nomina/configuracion/impuestos/base-gravable', N'FaPercent', 1, N'ESP', 1, 1, GETDATE()),
    (872, N'Impuestos Locales', 2, 870, N'Impuestos_Locales', N'/nomina/configuracion/impuestos/locales', N'FaHouse', 1, N'ESP', 2, 1, GETDATE()),

    (880, N'IMSS', 1, 800, N'Nomina_IMSS', N'/', N'FaUsers', 1, N'ESP', 7, 1, GETDATE()),
    (881, N'Prestaciones Mí­nimas de Ley', 2, 880, N'Prestaciones_Minimas', N'/nomina/configuracion/imss/prestaciones', N'FaDocument', 1, N'ESP', 1, 1, GETDATE()),
    (882, N'Clase IMSS', 2, 880, N'Clase_IMSS', N'/nomina/configuracion/imss/clase', N'FaVerified', 1, N'ESP', 2, 1, GETDATE()),
    (883, N'Fracción IMSS', 2, 880, N'Fraccion_IMSS', N'/nomina/configuracion/imss/fraccion', N'FaPercent', 1, N'ESP', 3, 1, GETDATE()),
    (884, N'Base Gravable IMSS', 2, 880, N'Base_Gravable_IMSS', N'/nomina/configuracion/imss/base-gravable', N'FaPercent', 1, N'ESP', 4, 1, GETDATE()),

    -- Nómina -> Configuración RH
    (900, N'Configuración RH', 0, 7, N'Configuracion_RH', N'/rh/configuracion', N'FaGears', 1, N'ESP', 12, 1, GETDATE()),
    (901, N'Plazas Autorizadas', 1, 900, N'Plazas Autorizadas', N'/rh/configuracion/plazas', N'FaVerified', 1, N'ESP', 1, 1, GETDATE()),
    (902, N'Universo', 1, 900, N'Universo', N'/rh/configuracion/universo', N'FaUsers', 1, N'ESP', 2, 1, GETDATE()),
    (903, N'Nivel', 1, 900, N'Nivel', N'/rh/configuracion/nivel', N'FaChartBar', 1, N'ESP', 3, 1, GETDATE()),
    (904, N'Sexo', 1, 900, N'Sexo', N'/rh/configuracion/sexo', N'FaUsers', 1, N'ESP', 4, 1, GETDATE()),
    (905, N'Estado Civil', 1, 900, N'Estado_Civil', N'/rh/configuracion/estado-civil', N'FaHeart', 1, N'ESP', 5, 1, GETDATE()),
    (906, N'Escolaridad', 1, 900, N'Escolaridad', N'/rh/configuracion/escolaridad', N'FaDocument', 1, N'ESP', 6, 1, GETDATE()),
    (907, N'Tipo de Parentesco', 1, 900, N'Tipo_Parentesco', N'/rh/configuracion/parentesco', N'FaUsers', 1, N'ESP', 7, 1, GETDATE()),
    (908, N'Estado', 1, 900, N'Estado', N'/rh/configuracion/estado', N'FaHouse', 1, N'ESP', 8, 1, GETDATE()),
    (909, N'Banco', 1, 900, N'Banco', N'/rh/configuracion/banco', N'FaHouse', 1, N'ESP', 9, 1, GETDATE()),
    (910, N'Municipio', 1, 900, N'Municipio', N'/rh/configuracion/municipio', N'FaHouse', 1, N'ESP', 10, 1, GETDATE()),
    (911, N'Contratos', 1, 900, N'Contratos', N'/rh/configuracion/contratos', N'FaDocument', 1, N'ESP', 11, 1, GETDATE()),
    (912, N'Base Pago', 2, 911, N'Base_Pago', N'/rh/configuracion/contratos/base-pago', N'FaMoneyBillWave', 1, N'ESP', 1, 1, GETDATE()),
    (913, N'Método de Pago', 2, 911, N'Metodo_Pago', N'/rh/configuracion/contratos/metodo-pago', N'FaCreditCard', 1, N'ESP', 2, 1, GETDATE()),
    (914, N'Tipo de Régimen', 2, 911, N'Tipo_Regimen', N'/rh/configuracion/contratos/tipo-regimen', N'FaDocument', 1, N'ESP', 3, 1, GETDATE()),
    (915, N'Base de Cotización', 2, 911, N'Base_Cotizacion', N'/rh/configuracion/contratos/base-cotizacion', N'FaPercent', 1, N'ESP', 4, 1, GETDATE()),
    (916, N'Zona Geográfica', 2, 911, N'Zona_Geografica', N'/rh/configuracion/contratos/zona-geografica', N'FaHouse', 1, N'ESP', 5, 1, GETDATE()),
    (917, N'Dí­a de la Semana', 2, 911, N'Dia_Semana', N'/rh/configuracion/contratos/dia-semana', N'FaCalendar', 1, N'ESP', 6, 1, GETDATE())--,
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
        TARGET.[Orden] = SOURCE.[Orden],
        TARGET.CreatedByOperatorId = SOURCE.CreatedByOperatorId,
        TARGET.CreatedDateTime = SOURCE.CreatedDateTime
WHEN NOT MATCHED BY TARGET THEN
    INSERT (PKIdMenu, Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta, ImageUrl, Activo, Lenguaje, [Orden], CreatedByOperatorId, CreatedDateTime)
    VALUES (SOURCE.PKIdMenu, SOURCE.Nombre, SOURCE.Tipo, SOURCE.FKIdMenu_SIS, SOURCE.LegacyName, SOURCE.Ruta, SOURCE.ImageUrl, SOURCE.Activo, SOURCE.Lenguaje, SOURCE.[Orden], SOURCE.CreatedByOperatorId, SOURCE.CreatedDateTime);

SET IDENTITY_INSERT Sis.Menu OFF;


-- =====================================================================
-- Asignación de menús a roles basado en claims (sin cambios en la lógica)
-- =====================================================================
MERGE INTO SIS.MenuRole AS TARGET
USING (
    SELECT DISTINCT M.PKIdMenu, R.Id AS RoleId, 1 AS Activo, 1 AS CreatedByOperatorId, GETDATE() AS CreatedDateTime
    FROM dbo.AspNetRoles AS R
    INNER JOIN dbo.AspNetUserRoles AS UR ON R.Id = UR.RoleId
    INNER JOIN dbo.AspNetUsers AS U ON U.Id = UR.UserId
    INNER JOIN dbo.AspNetClaims AS C ON C.RoleId = R.Id
    INNER JOIN dbo.AspNetClaimValues AS CV ON C.Id = CV.ClaimId
    INNER JOIN SIS.Menu AS M ON M.Activo = 1
    WHERE CV.Value like '%view-menu%'
) AS SOURCE (FKIdMenu_SIS, RoleId, Activo, CreatedByOperatorId, CreatedDateTime)
ON (TARGET.FKIdMenu_SIS = SOURCE.FKIdMenu_SIS AND TARGET.RoleId = SOURCE.RoleId)
WHEN MATCHED THEN
    UPDATE SET
        TARGET.Activo = SOURCE.Activo,
        TARGET.CreatedByOperatorId = SOURCE.CreatedByOperatorId,
        TARGET.CreatedDateTime = SOURCE.CreatedDateTime
WHEN NOT MATCHED BY TARGET THEN
    INSERT (FKIdMenu_SIS, RoleId, Activo, CreatedByOperatorId, CreatedDateTime)
    VALUES (SOURCE.FKIdMenu_SIS, SOURCE.RoleId, SOURCE.Activo, SOURCE.CreatedByOperatorId, SOURCE.CreatedDateTime)
WHEN NOT MATCHED BY SOURCE THEN DELETE;
GO

-- =============================================
-- TABLAS ADICIONALES (Perfil, Logs, Parámetros)
-- =============================================
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

INSERT INTO SIS.OrigenLogMessage (PKIdOrigenLogMessage, Descripcion, UsuarioCreacion) VALUES
(1, 'Sistema', 1),
(2, 'Aplicación', 1),
(3, 'Seguridad', 1),
(4, 'Base de Datos', 1),
(5, 'Red', 1),
(6, 'Hardware', 1),
(7, 'Usuario', 1),
(8, 'Otro', 1);
GO

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

INSERT INTO SIS.SystemParamCatalog (PKIdSystemParamCatalog, Code, Name, Activo, UsuarioCreacion) VALUES
(1, 'SISTEMA', 'SISTEMA', 1, 1),
(2, 'CATALOGOS', 'CATALOGOS', 1, 1);
GO

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

INSERT INTO SIS.SystemParamValue (PKIdSystemParamValue, FKIdSystemParamCatalog_SIS, Value, Descripcion, Activo, UsuarioCreacion) VALUES
(1, 1, '1', 'Variable que activa o desactiva el poder insertar en la tabla SystemLog', 1, 1);
GO

-- =============================================
-- AGREGAR CLAVES FORÁNEAS FALTANTES
-- =============================================
-- Relación de SIS.Usuario con dbo.AspNetUsers
--ALTER TABLE SIS.Usuario ADD CONSTRAINT FK_Usuario_AspNetUsers FOREIGN KEY (AspNetUserId) REFERENCES dbo.AspNetUsers(Id);
--GO

-- Auditoría (columnas UsuarioCreacion, UsuarioModificacion) – todas referencian SIS.Usuario
-- Se agregan después de que la tabla SIS.Usuario ya existe
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

-- Nota: Las claves foráneas existentes ya siguen el patrón FK_<tabla>_<tabla_referenciada>
-- y se han conservado tal cual. Solo se agregaron las que faltaban.

select * from sis.SystemLog

truncate table [SIS].[SystemLog]

select * from [BD_PRESUPUESTO].SIS.TipoPoliza
select * from [BD_PRESUPUESTO].SIS.TipoDetallePoliza
select * from [BD_PRESUPUESTO].CONTA.TipoDoctoPago
select * from [BD_PRESUPUESTO].CONTA.MatrizConversion
select * from [BD_PRESUPUESTO].CONTA.MatrizIngreso
select * from [BD_PRESUPUESTO].[SIS].[Concepto]                  --Partidas Presupuestales
select * from [BD_PRESUPUESTO].SIS.CuentaContable
select * from [BD_PRESUPUESTO].
select * from [BD_PRESUPUESTO].
select * from [BD_PRESUPUESTO].
select * from [BD_PRESUPUESTO].
select * from [BD_PRESUPUESTO].
select * from CONTA.TipoDoctoPago

select * from SIS.TipoPoliza
select * from SIS.TipoDetallePoliza

select * from CONTA.MatrizConversion
select * from CONTA.MatrizIngreso
select * from [SIS].[Concepto]                  --Partidas Presupuestales
select * from SIS.CuentaContable
