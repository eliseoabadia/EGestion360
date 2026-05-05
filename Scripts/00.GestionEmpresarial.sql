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

--CREATE INDEX IX_Usuario_Empresa ON SIS.Usuario(FKIdEmpresa_SIS) INCLUDE (Nombre, ApellidoPaterno, Email) WHERE Activo = 1;
CREATE INDEX IX_Usuario_AspNetUserId ON SIS.Usuario(AspNetUserId) INCLUDE (PkIdUsuario, FKIdEmpresa_SIS);
CREATE INDEX IX_Usuario_Email ON SIS.Usuario(Email) INCLUDE (Activo) WHERE Activo = 1;

--CREATE INDEX IX_UsuarioSucursal_Usuario ON SIS.UsuarioSucursal(FKIdUsuario_SIS) INCLUDE (FKIdSucursal_SIS, PuedeAcceder) WHERE Activo = 1;
--CREATE INDEX IX_UsuarioSucursal_Sucursal ON SIS.UsuarioSucursal(FKIdSucursal_SIS) INCLUDE (FKIdUsuario_SIS) WHERE Activo = 1;

--drop index  IX_UsuarioDepartamento_Usuario
--drop index IX_UsuarioDepartamento_Departamento
--CREATE INDEX IX_UsuarioDepartamento_Usuario ON SIS.UsuarioDepartamento(FKIdUsuario_SIS) INCLUDE (FKIdDepartamento_SIS, EsJefe) WHERE Activo = 1;
--CREATE INDEX IX_UsuarioDepartamento_Departamento ON SIS.UsuarioDepartamento(FKIdDepartamento_SIS) INCLUDE (FKIdUsuario_SIS) WHERE Activo = 1;

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

67A6E679-DBC4-402D-AE6E-7F28DDB11BD8
71804e93-9753-4684-84fd-cf037349c111
739CC754-488B-4BB4-B7FB-62F6BF3C26D0

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
(2, 'Configuracion', 'Configuracion', NULL, 'app://{0}/{1}', GETDATE(), 'Configuracion', 'CON001', 'Configuracion', 'view,view-menu', 0),
(2, 'Presupuesto', 'Presupuesto', NULL, 'app://{0}/{1}', GETDATE(), 'Presupuesto', 'PRE001', 'Presupuesto', 'view,view-menu', 0),
(2, 'Contabilidad', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Contabilidad', 'CTB001', 'Contabilidad', 'view,view-menu', 0),
(2, 'Adquisiciones', 'Adquisiciones', NULL, 'app://{0}/{1}', GETDATE(), 'Adquisiciones', 'ADQ001', 'Adquisiciones', 'view,view-menu', 0),
(2, 'Patrimonio', 'Patrimonio', NULL, 'app://{0}/{1}', GETDATE(), 'Patrimonio', 'PAT001', 'Patrimonio', 'view,view-menu', 0),
(2, 'Almacen', 'Almacen', NULL, 'app://{0}/{1}', GETDATE(), 'Almacen', 'ALM001', 'Almacen', 'view,view-menu', 0),
(2, 'Reportes CxC', 'Reportes CxC', NULL, 'app://{0}/{1}', GETDATE(), 'Reportes CxC', 'RPT001', 'Reportes CxC', 'view,view-menu', 0),
(2, 'Ayuda', 'Ayuda', NULL, 'app://{0}/{1}', GETDATE(), 'Ayuda', 'HLP001', 'Ayuda', 'view,view-menu', 0),

(2, 'Configuracion', 'Configuracion', NULL, 'app://{0}/{1}', GETDATE(), 'Sistema', 'CONSIS01', 'Configuracion', 'view,view-menu', 0),
(2, 'Configuracion', 'Sistema', NULL, 'app://{0}/{1}', GETDATE(), 'Usuario', 'CONSIS02', 'Sistema', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Sistema', NULL, 'app://{0}/{1}', GETDATE(), 'Menu', 'CONSIS03', 'Sistema', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Sistema', NULL, 'app://{0}/{1}', GETDATE(), 'General', 'CONSIS04', 'Sistema', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Sistema', NULL, 'app://{0}/{1}', GETDATE(), 'Empresa', 'CONSIS05', 'Sistema', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Sistema', NULL, 'app://{0}/{1}', GETDATE(), 'Departamento', 'CONSIS06', 'Sistema', 'view,view-menu,delete,new,update,CanExportToExcel', 0),

(2, 'Configuracion', 'Configuracion', NULL, 'app://{0}/{1}', GETDATE(), 'Catalogos_presupuestales', 'CONCP01', 'Configuracion', 'view,view-menu', 0),
--(2, 'Configuracion', 'Catalogos_presupuestales', NULL, 'app://{0}/{1}', GETDATE(), 'Historico', 'CONCP02', 'Catalogos_presupuestales', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
--(2, 'Configuracion', 'Catalogos_presupuestales', NULL, 'app://{0}/{1}', GETDATE(), 'Catalogos_presupuestales', 'CONCP03', 'Catalogos_presupuestales', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Catalogos_presupuestales', NULL, 'app://{0}/{1}', GETDATE(), 'ClavePrograma', 'CONCP02', 'Catalogos_presupuestales', 'view,view-menu', 0),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'UnidadResponsable', 'CONCLP01', 'ClavePrograma', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'Finalidad', 'CONCLP02', 'ClavePrograma', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'Funcion', 'CONCLP03', 'ClavePrograma', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'SubFunción', 'CONCLP04', 'ClavePrograma', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'Actividad_Institucional', 'CONCLP05', 'ClavePrograma', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'Eje', 'CONCLP06', 'ClavePrograma', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'SubEje', 'CONCLP07', 'ClavePrograma', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'Programa_Presupuestal', 'CONCLP08', 'ClavePrograma', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'Vertiente_Gasto', 'CONCLP09', 'ClavePrograma', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'Resultado', 'CONCLP10', 'ClavePrograma', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'Subresultado', 'CONCLP11', 'ClavePrograma', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'Anios', 'CONCLP12', 'ClavePrograma', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'Sector', 'CONCLP13', 'ClavePrograma', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'SubSector', 'CONCLP14', 'ClavePrograma', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'TipoRecurso', 'CONCLP15', 'ClavePrograma', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'Fuente_Financiamiento', 'CONCLP16', 'ClavePrograma', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'PG', 'CONCLP17', 'ClavePrograma', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'Ramo', 'CONCLP18', 'ClavePrograma', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'ClavePrograma', NULL, 'app://{0}/{1}', GETDATE(), 'Proyecto', 'CONCLP19', 'ClavePrograma', 'view,view-menu,delete,new,update,CanExportToExcel', 0),



(2, 'Configuracion', 'Catalogos_presupuestales', NULL, 'app://{0}/{1}', GETDATE(), 'Contabilidad', 'CONCP03', 'Catalogos_presupuestales', 'view,view-menu', 0),
(2, 'Configuracion', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_Polizas', 'CONCON01', 'Contabilidad', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_detalles_Polizas', 'CONCON02', 'Contabilidad', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Matriz_Conversion', 'CONCON03', 'Contabilidad', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Matriz_Conversión_Ingresos', 'CONCON04', 'Contabilidad', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Partidas_Presupuestales', 'CONCON05', 'Contabilidad', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Cuentas_Contables', 'CONCON06', 'Contabilidad', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Formas_Pago', 'CONCON07', 'Contabilidad', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Contabilidad', NULL, 'app://{0}/{1}', GETDATE(), 'Sigevi_Partidas', 'CONCON08', 'Contabilidad', 'view,view-menu,delete,new,update,CanExportToExcel', 0),


(2, 'Configuracion', 'Configuracion', NULL, 'app://{0}/{1}', GETDATE(), 'Adquisiciones', 'CON002', 'Configuracion', 'view,view-menu', 0),
(2, 'Configuracion', 'Adquisiciones', NULL, 'app://{0}/{1}', GETDATE(), 'Modalidad', 'CONADQ01', 'Adquisiciones', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Adquisiciones', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_Contrato', 'CONADQ02', 'Adquisiciones', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Adquisiciones', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_Documentos', 'CONADQ03', 'Adquisiciones', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Adquisiciones', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_Garantia', 'CONADQ04', 'Adquisiciones', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Adquisiciones', NULL, 'app://{0}/{1}', GETDATE(), 'Procedimientos_Contratacion', 'CONADQ05', 'Adquisiciones', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Adquisiciones', NULL, 'app://{0}/{1}', GETDATE(), 'Estatus_Requisicion', 'CONADQ06', 'Adquisiciones', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Adquisiciones', NULL, 'app://{0}/{1}', GETDATE(), 'Proveedores', 'CONADQ07', 'Adquisiciones', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Adquisiciones', NULL, 'app://{0}/{1}', GETDATE(), 'Articulo', 'CONADQ07', 'Adquisiciones', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Adquisiciones', NULL, 'app://{0}/{1}', GETDATE(), 'Fraccion', 'CONADQ07', 'Adquisiciones', 'view,view-menu,delete,new,update,CanExportToExcel', 0),



(2, 'Configuracion', 'Configuracion', NULL, 'app://{0}/{1}', GETDATE(), 'Patrimonio', 'CONPAT01', 'Configuracion', 'view,view-menu', 0),
(2, 'Configuracion', 'Patrimonio', NULL, 'app://{0}/{1}', GETDATE(), 'Familia', 'CONPAT02', 'Patrimonio', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Patrimonio', NULL, 'app://{0}/{1}', GETDATE(), 'Grupo_Bien', 'CONPAT03', 'Patrimonio', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Patrimonio', NULL, 'app://{0}/{1}', GETDATE(), 'Bienes_Servicios', 'CONPAT04', 'Patrimonio', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Patrimonio', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_Patrimonio', 'CONPAT05', 'Patrimonio', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Patrimonio', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_Adquisicion', 'CONPAT06', 'Patrimonio', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Patrimonio', NULL, 'app://{0}/{1}', GETDATE(), 'Marca', 'CONPAT07', 'Patrimonio', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Patrimonio', NULL, 'app://{0}/{1}', GETDATE(), 'Personas', 'CONPAT08', 'Patrimonio', 'view,view-menu,delete,new,update,CanExportToExcel', 0),


(2, 'Configuracion', 'Configuracion', NULL, 'app://{0}/{1}', GETDATE(), 'Almacen', 'CON002', 'Configuracion', 'view,view-menu', 0),
(2, 'Configuracion', 'Almacen', NULL, 'app://{0}/{1}', GETDATE(), 'Movimiento_Entrada_Salida', 'CONALM0101', 'Almacen', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Almacen', NULL, 'app://{0}/{1}', GETDATE(), 'Estatus_Solicitud', 'CONALM0102', 'Almacen', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Almacen', NULL, 'app://{0}/{1}', GETDATE(), 'Unidades', 'CONALM0103', 'Almacen', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Almacen', NULL, 'app://{0}/{1}', GETDATE(), 'Conteo_Periodo', 'CONALM0104', 'Almacen', 'view,view-menu,delete,new,update,CanExportToExcel', 0),


(2, 'Configuracion', 'Configuracion', NULL, 'app://{0}/{1}', GETDATE(), 'Tesoreria', 'CONTES01', 'Configuracion', 'view,view-menu', 0),
(2, 'Configuracion', 'Tesoreria', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_Cambio', 'CONTES02', 'CONTES01', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Tesoreria', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_Inversion', 'CONTES03', 'CONTES01', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Tesoreria', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_Moneda', 'CONTES04', 'CONTES01', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Tesoreria', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_Pago', 'CONTES05', 'CONTES01', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Tesoreria', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_PagoSF', 'CONTES06', 'CONTES01', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Tesoreria', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_SolicitudCLC', 'CONTES07', 'CONTES01', 'view,view-menu,delete,new,update,CanExportToExcel', 0),
(2, 'Configuracion', 'Tesoreria', NULL, 'app://{0}/{1}', GETDATE(), 'Tipo_DoctoCLC', 'CONTES08', 'CONTES01', 'view,view-menu,delete,new,update,CanExportToExcel', 0),




(2, 'Presupuesto', 'Presupuesto', NULL, 'app://{0}/{1}', GETDATE(), 'Presupuesto', 'PRE001', 'Presupuesto', 'view,view-menu', 0),
(2, 'Presupuesto', 'Presupuesto', NULL, 'app://{0}/{1}', GETDATE(), 'submodulo_egreso', 'PREEGRE01', 'Presupuesto', 'view,view-menu', 0),
(2, 'Presupuesto', 'submodulo_egreso', NULL, 'app://{0}/{1}', GETDATE(), 'planeacion', 'PREEGRE01', 'submodulo_egreso', 'view,view-menu', 0),
(2, 'Presupuesto', 'planeacion', NULL, 'app://{0}/{1}', GETDATE(), 'catalgo_planeacion', 'PREPLAN01', 'planeacion', 'view,view-menu', 0),
(2, 'Presupuesto', 'catalgo_planeacion', NULL, 'app://{0}/{1}', GETDATE(), 'indicadores', 'PREPLAN01', 'catalgo_planeacion', 'view,view-menu,delete,new,update', 0),


(1, 'almacen', 'almacen', NULL, 'app://{0}/{1}', GETDATE(), 'almacen', 'AL0001', 'Configuración', 'view,view-menu', 0),

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
EXEC spConfiguracionDeRolYClaims 'Ayuda', 'Ayuda', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Configuracion', 'Sistema', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Sistema', 'Usuario', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Sistema', 'Menu', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Sistema', 'General', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Sistema', 'Empresa', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Sistema', 'Departamento', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Configuracion', 'Catalogos_presupuestales', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Catalogos_presupuestales', 'ClavePrograma', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'UnidadResponsable', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'Finalidad', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'Funcion', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'SubFunción', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'Actividad_Institucional', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'Eje', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'SubEje', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'Programa_Presupuestal', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'Vertiente_Gasto', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'Resultado', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'Subresultado', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'Anios', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'Sector', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'SubSector', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'TipoRecurso', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'Fuente_Financiamiento', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'PG', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'Ramo', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'ClavePrograma', 'Proyecto', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Catalogos_presupuestales', 'Contabilidad', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'Tipo_Polizas', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'Tipo_detalles_Polizas', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'Matriz_Conversion', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'Matriz_Conversión_Ingresos', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'Partidas_Presupuestales', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'Cuentas_Contables', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'Formas_Pago', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contabilidad', 'Sigevi_Partidas', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
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
EXEC spConfiguracionDeRolYClaims 'Configuracion', 'Tesoreria', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'Tipo_Cambio', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'Tipo_Inversion', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'Tipo_Moneda', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'Tipo_Pago', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'Tipo_PagoSF', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'Tipo_SolicitudCLC', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'Tipo_DoctoCLC', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
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

SET IDENTITY_INSERT SIS.Menu ON

MERGE INTO SIS.Menu AS TARGET
USING (VALUES
    -- Módulos principales (Tipo = 1: agrupador, Tipo = 2: hoja)
    (1, N'Configuración', 1, NULL, N'Configuración', N'/', N'FaRegSun', 1, 'ESP', 1, 1, GETDATE()),
    (2, N'Presupuesto', 1, NULL, N'Presupuesto', N'/', N'FaMoneyBillWave', 1, 'ESP', 2, 1, GETDATE()),
    (3, N'Contabilidad', 1, NULL, N'Contabilidad', N'/', N'FaBook', 1, 'ESP', 3, 1, GETDATE()),
    (4, N'Adquisiciones', 1, NULL, N'Adquisiciones', N'/', N'FaShoppingCart', 1, 'ESP', 4, 1, GETDATE()),
    (5, N'Patrimonio', 1, NULL, N'Patrimonio', N'/', N'FaBuilding', 1, 'ESP', 5, 1, GETDATE()),
    (6, N'Almacén', 1, NULL, N'Almacén', N'/', N'FaWarehouse', 1, 'ESP', 6, 1, GETDATE()),
    (7, N'Reportes CxC', 1, NULL, N'Reportes CxC', N'/', N'FaFileInvoice', 1, 'ESP', 7, 1, GETDATE()),
    (8, N'Ayuda', 2, NULL, N'Ayuda', N'/ayuda', N'FaQuestionCircle', 1, 'ESP', 8, 1, GETDATE()),

    -- Configuración -> Sistema
    (50, N'Sistema', 1, 1, N'Sistema', N'/', N'FaServer', 1, 'ESP', 1, 1, GETDATE()),
    (51, N'Usuario', 2, 50, N'Usuario', N'/configuracion/sistema/usuarios', N'FaUser', 1, 'ESP', 2, 1, GETDATE()),
    (52, N'Menú', 2, 50, N'Menú', N'/configuracion/sistema/menu', N'FaBars', 1, 'ESP', 3, 1, GETDATE()),
    (53, N'General', 2, 50, N'General', N'/configuracion/sistema/general', N'FaCog', 1, 'ESP', 4, 1, GETDATE()),
    (54, N'Empresa', 2, 50, N'Empresa', N'/configuracion/sistema/empresa', N'FaBuilding', 1, 'ESP', 5, 1, GETDATE()),
    (55, N'Departamento', 2, 50, N'Departamento', N'/configuracion/sistema/departamento', N'FaUsers', 1, 'ESP', 6, 1, GETDATE()),

    

    -- Configuración -> Catálogos presupuestales
    (100, N'Presupuestales', 1, 1, N'Presupuestales', N'/', N'FaListAlt', 1, 'ESP', 1, 1, GETDATE()),
    (220, N'Clave del Programa', 1, 100, N'ClavePrograma', N'/', N'FaKey', 1, 'ESP', 1, 1, GETDATE()),
    (221, N'Unidad Responsable', 2, 220, N'Unidad Responsable', N'/configuracion/presupuestales/clave-programa/unidad-responsable', N'FaUserTie', 1, 'ESP', 2, 1, GETDATE()),
    (222, N'Finalidad', 2, 220, N'Finalidad', N'/configuracion/presupuestales/clave-programa/finalidad', N'FaBullseye', 1, 'ESP', 3, 1, GETDATE()),
    (223, N'Función', 2, 220, N'Función', N'/configuracion/presupuestales/clave-programa/funcion', N'FaCogs', 1, 'ESP', 4, 1, GETDATE()),
    (224, N'SubFunción', 2, 220, N'SubFunción', N'/configuracion/presupuestales/clave-programa/subfuncion', N'FaCog', 1, 'ESP', 5, 1, GETDATE()),
    (225, N'Actividad Institucional', 2, 220, N'Actividad Institucional', N'/configuracion/presupuestales/clave-programa/actividad-institucional', N'FaTasks', 1, 'ESP', 6, 1, GETDATE()),
    (226, N'Eje', 2, 220, N'Eje', N'/configuracion/presupuestales/clave-programa/eje', N'FaArrowsAlt', 1, 'ESP', 7, 1, GETDATE()),
    (227, N'SubEje', 2, 220, N'SubEje', N'/configuracion/presupuestales/clave-programa/subeje', N'FaArrowsAltH', 1, 'ESP', 8, 1, GETDATE()),
    (228, N'Programa Presupuestal', 2, 220, N'Programa Presupuestal', N'/configuracion/presupuestales/clave-programa/programa-presupuestal', N'FaCalendarAlt', 1, 'ESP', 9, 1, GETDATE()),
    --(229, N'Vertiente Gasto', 2, 220, N'Vertiente Gasto', N'/configuracion/presupuestales/clave-programa/vertiente-gasto', N'FaChartPie', 1, 'ESP', 10, 1, GETDATE()),
    --(230, N'Resultado', 2, 220, N'Resultado', N'/configuracion/presupuestales/clave-programa/resultado', N'FaChartLine', 1, 'ESP', 11, 1, GETDATE()),
    --(231, N'Subresultado', 2, 220, N'Subresultado', N'/configuracion/presupuestales/clave-programa/subresultado', N'FaChartLine', 1, 'ESP', 12, 1, GETDATE()),
    (232, N'Años', 2, 220, N'Años', N'/configuracion/presupuestales/clave-programa/anios', N'FaCalendar', 1, 'ESP', 13, 1, GETDATE()),
    (233, N'Sector', 2, 220, N'Sector', N'/configuracion/presupuestales/clave-programa/sector', N'FaIndustry', 1, 'ESP', 14, 1, GETDATE()),
    --(234, N'SubSector', 2, 220, N'SubSector', N'/configuracion/presupuestales/clave-programa/subsector', N'FaIndustry', 1, 'ESP', 15, 1, GETDATE()),
    (235, N'Tipo Recurso', 2, 220, N'Tipo Recurso', N'/configuracion/presupuestales/clave-programa/tipo-recurso', N'FaDollarSign', 1, 'ESP', 16, 1, GETDATE()),
    (236, N'Fuente Financiamiento', 2, 220, N'Fuente Financiamiento', N'/configuracion/presupuestales/clave-programa/fuente-financiamiento', N'FaMoneyBillWave', 1, 'ESP', 17, 1, GETDATE()),
    (237, N'PG', 2, 220, N'PG', N'/configuracion/presupuestales/clave-programa/pg', N'FaFileAlt', 1, 'ESP', 18, 1, GETDATE()),
    (238, N'Ramo', 2, 220, N'Ramo', N'/configuracion/presupuestales/clave-programa/ramo', N'FaTree', 1, 'ESP', 19, 1, GETDATE()),
    (239, N'Proyecto', 2, 220, N'Proyecto', N'/configuracion/presupuestales/clave-programa/proyecto', N'FaProjectDiagram', 1, 'ESP', 20, 1, GETDATE()),

    -- Configuración -> Contabilidad
    (240, N'Contabilidad', 1, 100, N'Contabilidad', N'/', N'FaCalculator', 1, 'ESP', 2, 1, GETDATE()),
    (241, N'Tipo Pólizas', 2, 240, N'Tipo Pólizas', N'/configuracion/contabilidad/tipo-polizas', N'FaFileInvoice', 1, 'ESP', 2, 1, GETDATE()),
    (242, N'Tipo Detalles Pólizas', 2, 240, N'Tipo Detalles Pólizas', N'/configuracion/contabilidad/tipo-detalles-polizas', N'FaList', 1, 'ESP', 3, 1, GETDATE()),
    (243, N'Matriz Conversión', 2, 240, N'Matriz Conversión', N'/configuracion/contabilidad/matriz-conversion', N'FaExchangeAlt', 1, 'ESP', 4, 1, GETDATE()),
    (244, N'Matriz Conversión Ingresos', 2, 240, N'Matriz Conversión Ingresos', N'/configuracion/contabilidad/matriz-conversion-ingresos', N'FaExchangeAlt', 1, 'ESP', 5, 1, GETDATE()),
    (245, N'Partidas Presupuestales', 2, 240, N'Partidas Presupuestales', N'/configuracion/contabilidad/partidas-presupuestales', N'FaMoneyBill', 1, 'ESP', 6, 1, GETDATE()),
    (246, N'Cuentas Contables', 2, 240, N'Cuentas Contables', N'/configuracion/contabilidad/cuentas-contables', N'FaBook', 1, 'ESP', 7, 1, GETDATE()),
    (247, N'Formas Pago', 2, 240, N'Formas Pago', N'/configuracion/contabilidad/formas-pago', N'FaCreditCard', 1, 'ESP', 8, 1, GETDATE()),
    (248, N'Sigevi Partidas', 2, 240, N'Sigevi Partidas', N'/configuracion/contabilidad/sigevi-partidas', N'FaCode', 1, 'ESP', 9, 1, GETDATE()),

    -- Configuración -> Adquisiciones
    (250, N'Adquisiciones', 1, 1, N'Adquisiciones', N'/', N'FaShoppingCart', 1, 'ESP', 3, 1, GETDATE()),
    (251, N'Modalidad', 2, 250, N'Modalidad', N'/configuracion/adquisiciones/modalidad', N'FaTags', 1, 'ESP', 4, 1, GETDATE()),
    (252, N'Tipo de Contrato', 2, 250, N'Tipo de Contrato', N'/configuracion/adquisiciones/tipo-contrato', N'FaFileSignature', 1, 'ESP', 5, 1, GETDATE()),
    (253, N'Tipo de Documentos', 2, 250, N'Tipo de Documentos', N'/configuracion/adquisiciones/tipo-documento', N'FaFileAlt', 1, 'ESP', 6, 1, GETDATE()),
    (254, N'Tipo de Garantía', 2, 250, N'Tipo de Garantía', N'/configuracion/adquisiciones/tipo-garantia', N'FaShieldAlt', 1, 'ESP', 7, 1, GETDATE()),
    (255, N'Procedimientos de Contratación', 2, 250, N'Procedimientos de Contratación', N'/configuracion/adquisiciones/procedimientos-contratacion', N'FaGavel', 1, 'ESP', 8, 1, GETDATE()),
    (256, N'Estatus Requisición', 2, 250, N'Estatus Requisición', N'/configuracion/adquisiciones/estatus-requisicion', N'FaFlagCheckered', 1, 'ESP', 9, 1, GETDATE()),
    (257, N'Proveedores', 2, 250, N'Proveedores', N'/configuracion/adquisiciones/proveedores', N'FaTruck', 1, 'ESP', 10, 1, GETDATE()),
    (258, N'Artículo', 2, 250, N'Artículo', N'/configuracion/adquisiciones/articulo', N'FaBox', 1, 'ESP', 11, 1, GETDATE()),
    (259, N'Fracción', 2, 250, N'Fracción', N'/configuracion/adquisiciones/fraccion', N'FaPercent', 1, 'ESP', 12, 1, GETDATE()),

    -- Configuración -> Patrimonio
    (260, N'Patrimonio', 1, 1, N'Patrimonio', N'/', N'FaBuilding', 1, 'ESP', 3, 1, GETDATE()),
    (261, N'Familia', 2, 260, N'Familia', N'/configuracion/Patrimonio/Familia', N'FaBuilding', 1, 'ESP', 1, 1, GETDATE()),
    (262, N'Grupo Bien', 2, 260, N'Grupo Bien', N'/configuracion/Patrimonio/Grupo_Bien', N'FaBuilding', 1, 'ESP', 2, 1, GETDATE()),
    (263, N'Bienes y Servicios', 2, 260, N'Bienes y Servicios', N'/configuracion/Patrimonio/Bienes_Servicios', N'FaBuilding', 1, 'ESP', 3, 1, GETDATE()),
    (264, N'Tipo de Patrimonio', 2, 260, N'Tipo de Patrimonio', N'/configuracion/Patrimonio/Tipo_Patrimonio', N'FaBuilding', 1, 'ESP', 4, 1, GETDATE()),
    (265, N'Tipo de Adquisición', 2, 260, N'Tipo de Adquisición', N'/configuracion/Patrimonio/Tipo_Adquisicion', N'FaBuilding', 1, 'ESP', 5, 1, GETDATE()),
    (266, N'Marca', 2, 260, N'Marca', N'/configuracion/Patrimonio/Marca', N'FaBuilding', 1, 'ESP', 6, 1, GETDATE()),
    (267, N'Personas', 2, 260, N'Personas', N'/configuracion/Patrimonio/Personas', N'FaBuilding', 1, 'ESP', 7, 1, GETDATE()),




    ---- Configuración -> Almacén
    (270, N'Almacén', 1, 1, N'Almacén', N'/', N'FaWarehouse', 1, 'ESP', 4, 1, GETDATE()),
    (271, N'Motivo de Entradas Salidas', 2, 270, N'Motivo de Entradas Salidas', N'/configuracion/almacen/Motivo_Entradas_Salidas', N'FaWarehouse', 1, 'ESP', 1, 1, GETDATE()),
    (272, N'Estatus Solicitud', 2, 270, N'Estatus Solicitud', N'/configuracion/almacen/Estatus_Solicitud', N'FaWarehouse', 1, 'ESP', 2, 1, GETDATE()),
    (273, N'Unidades', 2, 270, N'Unidades', N'/configuracion/almacen/Unidades', N'FaWarehouse', 1, 'ESP', 3, 1, GETDATE()),
    (274, N'Perido de Conteo', 2, 270, N'Perido de Conteo', N'/configuracion/almacen/Perido_Conteo', N'FaWarehouse', 1, 'ESP', 4, 1, GETDATE()),

    ---- Configuración -> Tesorería
    (280, N'Tesoreria', 1, 1, N'Tesoreria', N'/', N'FaMoneyBill', 1, 'ESP', 5, 1, GETDATE()),
    (281, N'Tipo de Cambio', 2, 280, N'Tipo de Cambio', N'/configuracion/tesoreria/Tipo_Cambio', N'FaWarehouse', 1, 'ESP', 1, 1, GETDATE()),
    (282, N'Tipo Inversion', 2, 280, N'Tipo Inversion', N'/configuracion/tesoreria/Tipo_Inversion', N'FaWarehouse', 1, 'ESP', 2, 1, GETDATE()), 
    (283, N'Tipo Moneda', 2, 280, N'Tipo Moneda', N'/configuracion/tesoreria/Tipo_Moneda', N'FaWarehouse', 1, 'ESP', 3, 1, GETDATE()), 
    (284, N'Tipo de Pago', 2, 280, N'Tipo de Pago', N'/configuracion/tesoreria/Tipo_Pago', N'FaWarehouse', 1, 'ESP', 4, 1, GETDATE()), 
    (285, N'Tipo de Pago SF', 2, 280, N'Tipo de Pago SF', N'/configuracion/tesoreria/Tipo_PagoSF', N'FaWarehouse', 1, 'ESP', 5, 1, GETDATE()), 
    (286, N'Tipo Solicitud CLC', 2, 280, N'Tipo Solicitud CLC', N'/configuracion/tesoreria/Tipo_Solicitud_CLC', N'FaWarehouse', 1, 'ESP', 6, 1, GETDATE()), 
    (287, N'Tipo Documento CLC', 2, 280, N'Tipo Documento CLC', N'/configuracion/tesoreria/Tipo_Documento_CLC', N'FaWarehouse', 1, 'ESP', 7, 1, GETDATE())

        

) AS SOURCE (PKIdMenu, Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta, ImageUrl, Activo, Lenguaje, [Orden], CreatedByOperatorId, CreatedDateTime)
ON (TARGET.PKIdMenu = SOURCE.PKIdMenu)
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
    VALUES (PKIdMenu, Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta, ImageUrl, Activo, Lenguaje, [Orden], CreatedByOperatorId, CreatedDateTime);


SET IDENTITY_INSERT Sis.Menu OFF;


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