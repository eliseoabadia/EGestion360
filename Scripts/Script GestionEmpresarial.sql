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

-- Tabla de Usuario (se sincroniza con AspNetUsers)
CREATE TABLE SIS.Usuario (
    PkIdUsuario INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    AspNetUserId NVARCHAR(450) NOT NULL,
    Nombre NVARCHAR(64) NOT NULL,
    ApellidoPaterno NVARCHAR(64) NOT NULL,
    ApellidoMaterno NVARCHAR(64) NULL,
    Iniciales NVARCHAR(3) NOT NULL,
    PayrollID NVARCHAR(20) NOT NULL,
    CodigoPostal NVARCHAR(9) NULL,
    Telefono NVARCHAR(16) NOT NULL,
    Direccion1 NVARCHAR(128) NOT NULL,
    Direccion2 NVARCHAR(64) NULL,
    Email NVARCHAR(60) NOT NULL,
    NumeroSocial NVARCHAR(12) NOT NULL,
    Gafete NVARCHAR(11) NOT NULL,
    Sexo BIT NOT NULL,
    FechaIngreso DATE NULL,
    FKIdIdiomaPreferido_SIS INT NULL,
    FKIdMonedaPreferida_SIS INT NULL,
    EsAdministrador BIT NOT NULL DEFAULT 0,
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Usuario PRIMARY KEY CLUSTERED (PkIdUsuario),
    CONSTRAINT FK_Usuario_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_Usuario_Idioma FOREIGN KEY (FKIdIdiomaPreferido_SIS) REFERENCES SIS.Idioma(PKIdIdioma),
    CONSTRAINT FK_Usuario_Moneda FOREIGN KEY (FKIdMonedaPreferida_SIS) REFERENCES SIS.Moneda(PKIdMoneda),
    CONSTRAINT UQ_Usuario_Email UNIQUE (Email),
    CONSTRAINT UQ_Usuario_PayrollID UNIQUE (PayrollID),
    CONSTRAINT UQ_Usuario_Gafete UNIQUE (Gafete),
    CONSTRAINT UQ_Usuario_AspNetUserId UNIQUE (AspNetUserId)
);

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

CREATE INDEX IX_Usuario_Empresa ON SIS.Usuario(FKIdEmpresa_SIS) INCLUDE (Nombre, ApellidoPaterno, Email) WHERE Activo = 1;
CREATE INDEX IX_Usuario_AspNetUserId ON SIS.Usuario(AspNetUserId) INCLUDE (PkIdUsuario, FKIdEmpresa_SIS);
CREATE INDEX IX_Usuario_Email ON SIS.Usuario(Email) INCLUDE (Activo) WHERE Activo = 1;

CREATE INDEX IX_UsuarioSucursal_Usuario ON SIS.UsuarioSucursal(FKIdUsuario_SIS) INCLUDE (FKIdSucursal_SIS, PuedeAcceder) WHERE Activo = 1;
CREATE INDEX IX_UsuarioSucursal_Sucursal ON SIS.UsuarioSucursal(FKIdSucursal_SIS) INCLUDE (FKIdUsuario_SIS) WHERE Activo = 1;

CREATE INDEX IX_UsuarioDepartamento_Usuario ON SIS.UsuarioDepartamento(FKIdUsuario_SIS) INCLUDE (FKIdDepartamento_SIS, EsJefe) WHERE Activo = 1;
CREATE INDEX IX_UsuarioDepartamento_Departamento ON SIS.UsuarioDepartamento(FKIdDepartamento_SIS) INCLUDE (FKIdUsuario_SIS) WHERE Activo = 1;

CREATE INDEX IX_Sucursal_Empresa ON SIS.Sucursal(FKIdEmpresa_SIS) INCLUDE (Nombre, CodigoSucursal, Ciudad) WHERE Activo = 1;
CREATE INDEX IX_Departamento_Empresa ON SIS.Departamento(FKIdEmpresa_SIS) INCLUDE (Nombre) WHERE Activo = 1;
CREATE INDEX IX_Departamento_Sucursal ON SIS.Departamento(FKIdSucursal_SIS) INCLUDE (Nombre) WHERE Activo = 1;

-- =============================================
-- TABLAS DE ASP.NET IDENTITY
-- =============================================

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
INSERT INTO dbo.AspNetClaims (ClaimTypeId, Name, [Group], RoleId, TokenFormat, Created, SubGroup, Code, [Description], [Values], ReferenceId)
VALUES 
(1, 'administration', 'administration', NULL, 'app://{0}/{1}', GETDATE(), 'administration', 'AD0001', 'Administracion', 'view,view-menu,delete,new,update', 0),
(1, 'configuration', 'configuracion', NULL, 'app://{0}/{1}', GETDATE(), 'configuracion', 'AD0001', 'Configuración', 'view,view-menu', 0),
(1, 'conteociclico', 'conteociclico', NULL, 'app://{0}/{1}', GETDATE(), 'conteociclico', 'CO0001', 'Configuración', 'view,view-menu', 0),
(1, 'almacen', 'almacen', NULL, 'app://{0}/{1}', GETDATE(), 'almacen', 'AL0001', 'Configuración', 'view,view-menu', 0),
(2, 'administration', 'administration', NULL, 'app://{0}/{1}', GETDATE(), 'administration', 'AD0001', 'Administracion', 'view,view-menu,delete,new,update', 0),
(2, 'configuracion', 'configuracion', NULL, 'app://{0}/{1}', GETDATE(), 'configuracion', 'AD0001', 'Configuración', 'view,view-menu', 0),
(2, 'configuracion', 'configuracion', NULL, 'app://{0}/{1}', GETDATE(), 'perfil', 'AD0001', 'Administracion', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'configuracion', 'configuracion', NULL, 'app://{0}/{1}', GETDATE(), 'usuarios', 'AD0001', 'Administracion', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'configuracion', 'configuracion', NULL, 'app://{0}/{1}', GETDATE(), 'empresas', 'AD0001', 'Administracion', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'configuracion', 'configuracion', NULL, 'app://{0}/{1}', GETDATE(), 'departamentos', 'AD0001', 'Administracion', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'configuracion', 'configuracion', NULL, 'app://{0}/{1}', GETDATE(), 'menus', 'AD0001', 'Administracion', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'configuracion', 'configuracion', NULL, 'app://{0}/{1}', GETDATE(), 'almacen', 'AL0001', 'Almacén', 'view,view-menu', 0),
(2, 'configuracion', 'configuracion', NULL, 'app://{0}/{1}', GETDATE(), 'numero-conteo', 'AL0001', 'Número de conteo', 'view,view-menu', 0),
(2, 'conteociclico', 'conteociclico', NULL, 'app://{0}/{1}', GETDATE(), 'conteociclico', 'CO0001', 'conteociclico', 'view,view-menu', 0),
(2, 'conteociclico', 'conteociclico', NULL, 'app://{0}/{1}', GETDATE(), 'periodo', 'CO0001', 'conteociclico', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'conteociclico', 'conteociclico', NULL, 'app://{0}/{1}', GETDATE(), 'mis-periodos', 'CO0001', 'conteociclico', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'almacen', 'almacen', NULL, 'app://{0}/{1}', GETDATE(), 'almacen', 'AL0001', 'almacen', 'view,view-menu', 0),
(2, 'almacen', 'almacen', NULL, 'app://{0}/{1}', GETDATE(), 'familia', 'AL0001', 'almacen', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'almacen', 'almacen', NULL, 'app://{0}/{1}', GETDATE(), 'tipo-bien', 'AL0001', 'almacen', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'almacen', 'almacen', NULL, 'app://{0}/{1}', GETDATE(), 'bien', 'AL0001', 'almacen', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'support', 'support', NULL, 'app://{0}/{1}', GETDATE(), 'support', 'SO0001', 'Soporte', 'view,view-menu', 0),
(2, 'configuration', 'configuration', NULL, 'app://{0}/{1}', GETDATE(), 'configuration', 'CO0001', 'Configuracion', 'view,view-menu,delete,new,update', 0);

INSERT INTO dbo.AspNetClaims (ClaimTypeId, Name, [Group], RoleId, TokenFormat, Created, SubGroup, Code, [Description], [Values], ReferenceId)
VALUES 
(2, 'configuracion', 'configuracion', NULL, 'app://{0}/{1}', GETDATE(), 'almacen', 'AL0001', 'Almacén', 'view,view-menu', 0),
(2, 'configuracion', 'configuracion', NULL, 'app://{0}/{1}', GETDATE(), 'numero-conteo', 'AL0002', 'Número de conteo', 'view,view-menu', 0);


-- Claim Values
CREATE TABLE dbo.AspNetClaimValues (
    Id INT IDENTITY NOT NULL,
    ClaimId INT,
    Value NVARCHAR(50) NOT NULL,
    Created DATETIME NOT NULL CONSTRAINT CONSTRAINT_DF_AspNetClaimValues_Created DEFAULT GETDATE(),
    CONSTRAINT CONSTRAINT_PK_AspNetClaimValues PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT CONSTRAINT_FK_AspNetClaimValues_Claim FOREIGN KEY (ClaimId) REFERENCES dbo.AspNetClaims(Id)
);
GO



-- Ejecución del procedimiento para asignar valores a los roles
EXEC spConfiguracionDeRolYClaims 'administration', 'administration', '10000', 'view';
EXEC spConfiguracionDeRolYClaims 'administration', 'administration', '10000', 'view-menu';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'configuracion', '10000', 'view';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'configuracion', '10000', 'view-menu';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'perfil', '10000', 'view';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'perfil', '10000', 'view-menu';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'perfil', '10000', 'delete';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'perfil', '10000', 'new';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'perfil', '10000', 'update';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'perfil', '10000', 'CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'usuarios', '10000', 'view';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'usuarios', '10000', 'view-menu';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'usuarios', '10000', 'delete';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'usuarios', '10000', 'new';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'usuarios', '10000', 'update';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'usuarios', '10000', 'CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'empresas', '10000', 'view';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'empresas', '10000', 'view-menu';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'empresas', '10000', 'delete';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'empresas', '10000', 'new';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'empresas', '10000', 'update';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'empresas', '10000', 'CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'departamentos', '10000', 'view';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'departamentos', '10000', 'view-menu';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'departamentos', '10000', 'delete';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'departamentos', '10000', 'new';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'departamentos', '10000', 'update';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'departamentos', '10000', 'CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'menus', '10000', 'view';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'menus', '10000', 'view-menu';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'menus', '10000', 'delete';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'menus', '10000', 'new';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'menus', '10000', 'update';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'menus', '10000', 'CanExportToExcel';

EXEC spConfiguracionDeRolYClaims 'configuracion', 'almacen', '10000', 'view';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'almacen', '10000', 'view-menu';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'numero-conteo', '10000', 'view';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'numero-conteo', '10000', 'view-menu';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'numero-conteo', '10000', 'delete';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'numero-conteo', '10000', 'new';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'numero-conteo', '10000', 'update';
EXEC spConfiguracionDeRolYClaims 'configuracion', 'numero-conteo', '10000', 'CanExportToExcel';

EXEC spConfiguracionDeRolYClaims 'conteociclico', 'conteociclico', '10000', 'view';
EXEC spConfiguracionDeRolYClaims 'conteociclico', 'conteociclico', '10000', 'view-menu';
EXEC spConfiguracionDeRolYClaims 'conteociclico', 'periodo', '10000', 'view';
EXEC spConfiguracionDeRolYClaims 'conteociclico', 'periodo', '10000', 'view-menu';
EXEC spConfiguracionDeRolYClaims 'conteociclico', 'periodo', '10000', 'delete';
EXEC spConfiguracionDeRolYClaims 'conteociclico', 'periodo', '10000', 'new';
EXEC spConfiguracionDeRolYClaims 'conteociclico', 'periodo', '10000', 'update';
EXEC spConfiguracionDeRolYClaims 'conteociclico', 'periodo', '10000', 'CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'conteociclico', 'mis-periodos', '10000', 'view';
EXEC spConfiguracionDeRolYClaims 'conteociclico', 'mis-periodos', '10000', 'view-menu';
EXEC spConfiguracionDeRolYClaims 'conteociclico', 'mis-periodos', '10000', 'delete';
EXEC spConfiguracionDeRolYClaims 'conteociclico', 'mis-periodos', '10000', 'new';
EXEC spConfiguracionDeRolYClaims 'conteociclico', 'mis-periodos', '10000', 'update';
EXEC spConfiguracionDeRolYClaims 'conteociclico', 'mis-periodos', '10000', 'CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'almacen', 'almacen', '10000', 'view';
EXEC spConfiguracionDeRolYClaims 'almacen', 'almacen', '10000', 'view-menu';
EXEC spConfiguracionDeRolYClaims 'almacen', 'familia', '10000', 'view';
EXEC spConfiguracionDeRolYClaims 'almacen', 'familia', '10000', 'view-menu';
EXEC spConfiguracionDeRolYClaims 'almacen', 'familia', '10000', 'delete';
EXEC spConfiguracionDeRolYClaims 'almacen', 'familia', '10000', 'new';
EXEC spConfiguracionDeRolYClaims 'almacen', 'familia', '10000', 'update';
EXEC spConfiguracionDeRolYClaims 'almacen', 'familia', '10000', 'CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'almacen', 'tipo-bien', '10000', 'view';
EXEC spConfiguracionDeRolYClaims 'almacen', 'tipo-bien', '10000', 'view-menu';
EXEC spConfiguracionDeRolYClaims 'almacen', 'tipo-bien', '10000', 'delete';
EXEC spConfiguracionDeRolYClaims 'almacen', 'tipo-bien', '10000', 'new';
EXEC spConfiguracionDeRolYClaims 'almacen', 'tipo-bien', '10000', 'update';
EXEC spConfiguracionDeRolYClaims 'almacen', 'tipo-bien', '10000', 'CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'almacen', 'bien', '10000', 'view';
EXEC spConfiguracionDeRolYClaims 'almacen', 'bien', '10000', 'view-menu';
EXEC spConfiguracionDeRolYClaims 'almacen', 'bien', '10000', 'delete';
EXEC spConfiguracionDeRolYClaims 'almacen', 'bien', '10000', 'new';
EXEC spConfiguracionDeRolYClaims 'almacen', 'bien', '10000', 'update';
EXEC spConfiguracionDeRolYClaims 'almacen', 'bien', '10000', 'CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'support', 'support', '20000', 'view';
EXEC spConfiguracionDeRolYClaims 'support', 'support', '20000', 'view-menu';
EXEC spConfiguracionDeRolYClaims 'configuration', 'configuration', '30000', 'view';
EXEC spConfiguracionDeRolYClaims 'configuration', 'configuration', '30000', 'view-menu';
EXEC spConfiguracionDeRolYClaims 'configuration', 'configuration', '30000', 'delete';
EXEC spConfiguracionDeRolYClaims 'configuration', 'configuration', '30000', 'new';
EXEC spConfiguracionDeRolYClaims 'configuration', 'configuration', '30000', 'update';

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
INSERT INTO [dbo].[AspNetUsers] (
    [Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber],
    [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled],
    [AccessFailedCount], [ReferenceId], [AccessNumber], [PkIdUsuario]
)
VALUES 
    (NEWID(), '', 1, 'UOxg2B7HCZwZZ/drSkwHrA==', 'C5F91B8B-9E25-4576-96E7-CD3317F1AB87', NULL, 0, 0, NULL, 0, 0, 10000, '0000010000', 1),
    (NEWID(), '', 1, 'UOxg2B7HCZwZZ/drSkwHrA==', 'C5F91B8B-9E25-4576-96E7-CD3317F1AB87', NULL, 0, 0, NULL, 0, 0, 10000, '0000010000', 2),
    (NEWID(), '', 1, 'UOxg2B7HCZwZZ/drSkwHrA==', 'C5F91B8B-9E25-4576-96E7-CD3317F1AB87', NULL, 0, 0, NULL, 0, 0, 10000, '0000010000', 3);

-- Tabla AspNetUserRoles
--drop table dbo.AspNetUserRoles
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
WHERE PkIdUsuario IN (1);

-- =============================================
-- MENÚS
-- =============================================
CREATE TABLE SIS.Menu (
    PKIdMenu INT NOT NULL,
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

-- Insertar menús
MERGE INTO SIS.Menu AS TARGET
USING (VALUES
    (1, N'Principal', 2, NULL, N'Principal', N'/', N'FaHome', 'ESP', 100, 1000, GETDATE()),
    (2, N'Configuración', 1, NULL, N'Configuración', N'/', N'FaRegSun', 'ESP', 200, 1000, GETDATE()),
    (3, N'Mi Perfíl', 2, 2, N'Perfil de Usuario', N'/configuracion/perfil', N'FaUser', 'ESP', 201, 1000, GETDATE()),
    (4, N'Usuario', 2, 2, N'Administración de Usuarios', N'/configuracion/usuarios', N'FaUser', 'ESP', 202, 1000, GETDATE()),
    (5, N'Empresa', 2, 2, N'Empresa', N'/configuracion/empresas', N'FaRegUser', 'ESP', 203, 1000, GETDATE()),
    (6, N'Departamento', 2, 2, N'Departamento', N'/configuracion/departamentos', N'FaRegUser', 'ESP', 204, 1000, GETDATE()),
    (7, N'Menu', 2, 2, N'Menu', N'/configuracion/menus', N'RiMenuLine', 'ESP', 205, 1000, GETDATE()),
	(8, N'Almacén', 2, 2, N'Almacen', N'/', N'RiMenuLine', 'ESP', 205, 1000, GETDATE()),
	(9, N'Número de Conteo', 2, 8, N'Número de Conteo', N'/numero-conteo', N'RiMenuLine', 'ESP', 205, 1000, GETDATE()),
    (10, N'Conteo Cíclico', 1, NULL, N'Conteo Cíclico', N'/', N'FaRegSun', 'ESP', 300, 1000, GETDATE()),
    (11, N'Periodo', 2, 10, N'Periodo', N'/numero-conteo', N'RiListCheck2', 'ESP', 301, 1000, GETDATE()),
    (12, N'Mis Periodo', 2, 10, N'Periodo', N'/conteociclico/mis-periodos', N'RiListCheck2', 'ESP', 302, 1000, GETDATE()),
    (13, N'Almacén', 1, NULL, N'Almacén', N'/', N'FaRegSun', 'ESP', 400, 1000, GETDATE()),
    (14, N'Almacén', 2, 13, N'Familia', N'/almacen/familia', N'RiListCheck2', 'ESP', 401, 1000, GETDATE()),
    (15, N'Tipo Bien', 2, 13, N'Tipo Bien', N'/almacen/tipo-bien', N'RiListCheck2', 'ESP', 401, 1000, GETDATE()),
    (16, N'Bien', 2, 13, N'Bien', N'/almacen/bien', N'RiListCheck2', 'ESP', 402, 1000, GETDATE())
) AS SOURCE (PKIdMenu, Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta, ImageUrl, Lenguaje, Orden, CreatedByOperatorId, CreatedDateTime)
ON (TARGET.PKIdMenu = SOURCE.PKIdMenu)
WHEN MATCHED THEN
    UPDATE SET
        TARGET.Nombre = SOURCE.Nombre,
        TARGET.Tipo = SOURCE.Tipo,
        TARGET.FKIdMenu_SIS = SOURCE.FKIdMenu_SIS,
        TARGET.LegacyName = SOURCE.LegacyName,
        TARGET.Ruta = SOURCE.Ruta,
        TARGET.ImageUrl = SOURCE.ImageUrl,
        TARGET.Activo = 1,
        TARGET.Lenguaje = SOURCE.Lenguaje,
        TARGET.[Orden] = SOURCE.[Orden],
        TARGET.CreatedByOperatorId = SOURCE.CreatedByOperatorId,
        TARGET.CreatedDateTime = SOURCE.CreatedDateTime
WHEN NOT MATCHED BY TARGET THEN
    INSERT (PKIdMenu, Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta, ImageUrl, Activo, Lenguaje, [Orden], CreatedByOperatorId, CreatedDateTime)
    VALUES (PKIdMenu, Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta, ImageUrl, 1, Lenguaje, [Orden], CreatedByOperatorId, CreatedDateTime);
GO

-- Asignar menús a roles basado en claims
MERGE INTO SIS.MenuRole AS TARGET
USING (
    SELECT DISTINCT M.PKIdMenu, R.Id AS RoleId, 1 AS Activo, 1 AS CreatedByOperatorId, GETDATE() AS CreatedDateTime
    FROM dbo.AspNetRoles AS R
    INNER JOIN dbo.AspNetUserRoles AS UR ON R.Id = UR.RoleId
    INNER JOIN dbo.AspNetUsers AS U ON U.Id = UR.UserId
    INNER JOIN dbo.AspNetClaims AS C ON C.RoleId = R.Id
    INNER JOIN dbo.AspNetClaimValues AS CV ON C.Id = CV.ClaimId
    INNER JOIN SIS.Menu AS M ON M.Activo = 1
    WHERE CV.Value = 'view-menu'
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
ALTER TABLE SIS.Usuario ADD CONSTRAINT FK_Usuario_AspNetUsers FOREIGN KEY (AspNetUserId) REFERENCES dbo.AspNetUsers(Id);
GO

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