
--create database test


use [GestionEmpresarial]
GO
--drop database GestionEmpresarial
-- =============================================
-- ESQUEMAS
-- =============================================
-- =============================================
CREATE SCHEMA SIS  -- Sistema (catálogos generales)
GO
CREATE SCHEMA NOM  -- Nómina
GO
CREATE SCHEMA ALMA  -- Almacén

GO
CREATE SCHEMA CONTA  -- Contabilidad
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
    FKIdSucursal_SIS INT NULL,  -- NULL = departamento corporativo
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
    FKIdEmpresa_SIS INT NOT NULL,  -- Relación directa con empresa
    AspNetUserId NVARCHAR(450) NOT NULL,  -- ID del usuario en AspNetUsers
    Nombre NVARCHAR(64) NOT NULL,
    ApellidoPaterno NVARCHAR(64) NOT NULL,
    ApellidoMaterno NVARCHAR(64) NULL,
    Iniciales NVARCHAR(3) NOT NULL,
    PayrollID NVARCHAR(20) NOT NULL,
    CodigoPostal NVARCHAR(9) NULL,
    Telefono NVARCHAR(16) NOT NULL,
    Direccion1 NVARCHAR(128) NOT NULL,
    Direccion2 NVARCHAR(64) NULL,
    Email nvarchar(60) NOT NULL,
    NumeroSocial nvarchar(12) NOT NULL,
    Gafete nvarchar(11) NOT NULL,
    Sexo bit NOT NULL,
    FechaIngreso DATE NULL,
    FKIdIdiomaPreferido_SIS INT NULL,
    FKIdMonedaPreferida_SIS INT NULL,
    EsAdministrador BIT NOT NULL DEFAULT 0,  -- Usuario con permisos globales
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
    -- Los permisos van aquí, NO en UsuarioDepartamento
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
    EsJefe BIT NOT NULL DEFAULT 0,  -- Indica si es jefe del departamento
    -- NOTA: Los permisos de acceso (PuedeAcceder, PuedeConfigurar, etc.) 
    -- se heredan de UsuarioSucursal o se definen por el departamento/sucursal
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


/*  ---------------------------------------------------------------------------                   ------------------------------------------------------------------------*/
/*
user:admon01
pasword: Tecno.2025
*/
/*  ---------------------------------------------------------------------------                   ------------------------------------------------------------------------*/


/*  ROLES*/
CREATE TABLE dbo.AspNetRoles
(
	Id nvarchar(128) NOT NULL,
	Name nvarchar(256) NOT NULL,
	Code nvarchar(10),
	CONSTRAINT CONSTRAINT_PK_AspNetRoles PRIMARY KEY CLUSTERED (Id),
	CONSTRAINT CONSTRAINT_UX_AspNetRoles_Name UNIQUE NONCLUSTERED (Name)
)
GO
INSERT INTO [dbo].[AspNetRoles] ([Id],[Name],[Code]) VALUES ('71804e93-9753-4684-84fd-cf037349c111','SYSTEMADMIN',10000)
INSERT INTO [dbo].[AspNetRoles] ([Id],[Name],[Code]) VALUES ('739CC754-488B-4BB4-B7FB-62F6BF3C26D0','SOPORTE',20000)
INSERT INTO [dbo].[AspNetRoles] ([Id],[Name],[Code]) VALUES ('67A6E679-DBC4-402D-AE6E-7F28DDB11BD8','CONFIGURATION',30000)

 CREATE TABLE dbo.AspNetClaimTypes (
    Id INT IDENTITY(1,1) NOT NULL,
    Name NVARCHAR(50) NOT NULL,
    Created DATETIME NOT NULL,
    CONSTRAINT CONSTRAINT_PK_AspNetClaimTypes PRIMARY KEY CLUSTERED (Id)
);

insert into AspNetClaimTypes values('Template',getdate())
insert into AspNetClaimTypes values('Role',getdate())

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
    ReferenceId INT NOT NULL CONSTRAINT CONSTRAINT_DF_AspNetClaims_ReferenceId DEFAULT(0),
    CONSTRAINT CONSTRAINT_PK_AspNetClaims PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT CONSTRAINT_FK_AspNetClaims_ClaimType FOREIGN KEY (ClaimTypeId)
        REFERENCES dbo.AspNetClaimTypes(Id),
    CONSTRAINT CONSTRAINT_FK_AspNetClaims_Role FOREIGN KEY (RoleId)
        REFERENCES dbo.AspNetRoles(Id)
);


INSERT INTO AspNetClaims(ClaimTypeId,Name,[Group],RoleId,TokenFormat,Created,SubGroup,Code,[Description],[Values],ReferenceId)
				VALUES(1,'administration','administration',NULL,'app://{0}/{1}',GETDATE(),'administration','AD0001','Administracion','view,view-menu,delete,new,update',0)
INSERT INTO AspNetClaims(ClaimTypeId,Name,[Group],RoleId,TokenFormat,Created,SubGroup,Code,[Description],[Values],ReferenceId)
				VALUES(1,'configuration','configuracion',NULL,'app://{0}/{1}',GETDATE(),'configuracion','AD0001','Configuración','view,view-menu',0)

INSERT INTO AspNetClaims(ClaimTypeId,Name,[Group],RoleId,TokenFormat,Created,SubGroup,Code,[Description],[Values],ReferenceId)
				VALUES(2,'administration','administration',NULL,'app://{0}/{1}',GETDATE(),'administration','AD0001','Administracion','view,view-menu,delete,new,update',0)
INSERT INTO AspNetClaims(ClaimTypeId,Name,[Group],RoleId,TokenFormat,Created,SubGroup,Code,[Description],[Values],ReferenceId)
				VALUES(2,'configuracion','configuracion',NULL,'app://{0}/{1}',GETDATE(),'configuracion','AD0001','Configuración','view,view-menu',0)
INSERT INTO AspNetClaims(ClaimTypeId,Name,[Group],RoleId,TokenFormat,Created,SubGroup,Code,[Description],[Values],ReferenceId)
				VALUES(2,'configuracion','configuracion',NULL,'app://{0}/{1}',GETDATE(),'perfil','AD0001','Administracion','view,view-menu,delete,new,update,CanExportToExcel',0)
INSERT INTO AspNetClaims(ClaimTypeId,Name,[Group],RoleId,TokenFormat,Created,SubGroup,Code,[Description],[Values],ReferenceId)
				VALUES(2,'configuracion','configuracion',NULL,'app://{0}/{1}',GETDATE(),'usuarios','AD0001','Administracion','view,view-menu,delete,new,update,CanExportToExcel',0)
INSERT INTO AspNetClaims(ClaimTypeId,Name,[Group],RoleId,TokenFormat,Created,SubGroup,Code,[Description],[Values],ReferenceId)
				VALUES(2,'configuracion','configuracion',NULL,'app://{0}/{1}',GETDATE(),'empresas','AD0001','Administracion','view,view-menu,delete,new,update,CanExportToExcel',0)
INSERT INTO AspNetClaims(ClaimTypeId,Name,[Group],RoleId,TokenFormat,Created,SubGroup,Code,[Description],[Values],ReferenceId)
				VALUES(2,'configuracion','configuracion',NULL,'app://{0}/{1}',GETDATE(),'departamentos','AD0001','Administracion','view,view-menu,delete,new,update,CanExportToExcel',0)
INSERT INTO AspNetClaims(ClaimTypeId,Name,[Group],RoleId,TokenFormat,Created,SubGroup,Code,[Description],[Values],ReferenceId)
				VALUES(2,'configuracion','configuracion',NULL,'app://{0}/{1}',GETDATE(),'menus','AD0001','Administracion','view,view-menu,delete,new,update,CanExportToExcel',0)


INSERT INTO AspNetClaims(ClaimTypeId,Name,[Group],RoleId,TokenFormat,Created,SubGroup,Code,[Description],[Values],ReferenceId)
				VALUES(2,'support','support',NULL,'app://{0}/{1}',GETDATE(),'support','SO0001','Soporte','view,view-menu',0)
INSERT INTO AspNetClaims(ClaimTypeId,Name,[Group],RoleId,TokenFormat,Created,SubGroup,Code,[Description],[Values],ReferenceId)
				VALUES(2,'configuration','configuration',NULL,'app://{0}/{1}',GETDATE(),'configuration','CO0001','Configuracion','view,view-menu,delete,new,update',0)

CREATE TABLE dbo.AspNetClaimValues (
    Id INT IDENTITY NOT NULL,
    ClaimId INT,
    Value NVARCHAR(50) NOT NULL,
    Created DATETIME NOT NULL CONSTRAINT CONSTRAINT_DF_AspNetClaimValues_Created DEFAULT GETDATE(),
    CONSTRAINT CONSTRAINT_PK_AspNetClaimValues PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT CONSTRAINT_FK_AspNetClaimValues_Claim FOREIGN KEY (ClaimId)
        REFERENCES dbo.AspNetClaims(Id)
);


EXEC spConfiguracionDeRolYClaims 'administration','administration','10000','view'
EXEC spConfiguracionDeRolYClaims 'administration','administration','10000','view-menu'
EXEC spConfiguracionDeRolYClaims 'configuracion','configuracion','10000','view'
EXEC spConfiguracionDeRolYClaims 'configuracion','configuracion','10000','view-menu'
                                  
EXEC spConfiguracionDeRolYClaims 'configuracion','perfil','10000','view'
EXEC spConfiguracionDeRolYClaims 'configuracion','perfil','10000','view-menu'
EXEC spConfiguracionDeRolYClaims 'configuracion','perfil','10000','delete'
EXEC spConfiguracionDeRolYClaims 'configuracion','perfil','10000','new'
EXEC spConfiguracionDeRolYClaims 'configuracion','perfil','10000','update'
EXEC spConfiguracionDeRolYClaims 'configuracion','perfil','10000','CanExportToExcel'
                                  
EXEC spConfiguracionDeRolYClaims 'configuracion','usuarios','10000','view'
EXEC spConfiguracionDeRolYClaims 'configuracion','usuarios','10000','view-menu'
EXEC spConfiguracionDeRolYClaims 'configuracion','usuarios','10000','delete'
EXEC spConfiguracionDeRolYClaims 'configuracion','usuarios','10000','new'
EXEC spConfiguracionDeRolYClaims 'configuracion','usuarios','10000','update'
EXEC spConfiguracionDeRolYClaims 'configuracion','usuarios','10000','CanExportToExcel'
                                  
EXEC spConfiguracionDeRolYClaims 'configuracion','empresas','10000','view'
EXEC spConfiguracionDeRolYClaims 'configuracion','empresas','10000','view-menu'
EXEC spConfiguracionDeRolYClaims 'configuracion','empresas','10000','delete'
EXEC spConfiguracionDeRolYClaims 'configuracion','empresas','10000','new'
EXEC spConfiguracionDeRolYClaims 'configuracion','empresas','10000','update'
EXEC spConfiguracionDeRolYClaims 'configuracion','empresas','10000','CanExportToExcel'
                                  
EXEC spConfiguracionDeRolYClaims 'configuracion','departamentos','10000','view'
EXEC spConfiguracionDeRolYClaims 'configuracion','departamentos','10000','view-menu'
EXEC spConfiguracionDeRolYClaims 'configuracion','departamentos','10000','delete'
EXEC spConfiguracionDeRolYClaims 'configuracion','departamentos','10000','new'
EXEC spConfiguracionDeRolYClaims 'configuracion','departamentos','10000','update'
EXEC spConfiguracionDeRolYClaims 'configuracion','departamentos','10000','CanExportToExcel'
                                  
EXEC spConfiguracionDeRolYClaims 'configuracion','menus','10000','view'
EXEC spConfiguracionDeRolYClaims 'configuracion','menus','10000','view-menu'
EXEC spConfiguracionDeRolYClaims 'configuracion','menus','10000','delete'
EXEC spConfiguracionDeRolYClaims 'configuracion','menus','10000','new'
EXEC spConfiguracionDeRolYClaims 'configuracion','menus','10000','update'
EXEC spConfiguracionDeRolYClaims 'configuracion','menus','10000','CanExportToExcel'


EXEC spConfiguracionDeRolYClaims 'support','support','20000','view'
EXEC spConfiguracionDeRolYClaims 'support','support','20000','view-menu'
EXEC spConfiguracionDeRolYClaims 'configuration','configuration','30000','view'
EXEC spConfiguracionDeRolYClaims 'configuration','configuration','30000','view-menu'
EXEC spConfiguracionDeRolYClaims 'configuration','configuration','30000','delete'
EXEC spConfiguracionDeRolYClaims 'configuration','configuration','30000','new'
EXEC spConfiguracionDeRolYClaims 'configuration','configuration','30000','update'




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
    CONSTRAINT CONSTRAINT_FK_AspNetUsers_Usuario FOREIGN KEY (PkIdUsuario)
        REFERENCES SIS.Usuario(PkIdUsuario)
);

--update [dbo].[AspNetUsers] set [PasswordHash] = 'UOxg2B7HCZwZZ/drSkwHrA=='
--update [dbo].[AspNetUsers] set [Email] = 'eliseo_eae@htomail.com'

/* user */
INSERT INTO [dbo].[AspNetUsers]
([Id],[Email],[EmailConfirmed],[PasswordHash],[SecurityStamp],[PhoneNumber],[PhoneNumberConfirmed],[TwoFactorEnabled],[LockoutEndDateUtc],[LockoutEnabled],[AccessFailedCount]
,[ReferenceId],[AccessNumber],[PkIdUsuario])
VALUES (NEWID(),'',1,'UOxg2B7HCZwZZ/drSkwHrA==','C5F91B8B-9E25-4576-96E7-CD3317F1AB87',null,0,0,null,0,0,10000,'0000010000',1)
INSERT INTO [dbo].[AspNetUsers]
([Id],[Email],[EmailConfirmed],[PasswordHash],[SecurityStamp],[PhoneNumber],[PhoneNumberConfirmed],[TwoFactorEnabled],[LockoutEndDateUtc],[LockoutEnabled],[AccessFailedCount]
,[ReferenceId],[AccessNumber],[PkIdUsuario])
VALUES (NEWID(),'',1,'UOxg2B7HCZwZZ/drSkwHrA==','C5F91B8B-9E25-4576-96E7-CD3317F1AB87',null,0,0,null,0,0,10000,'0000010000',2)
INSERT INTO [dbo].[AspNetUsers]
([Id],[Email],[EmailConfirmed],[PasswordHash],[SecurityStamp],[PhoneNumber],[PhoneNumberConfirmed],[TwoFactorEnabled],[LockoutEndDateUtc],[LockoutEnabled],[AccessFailedCount]
,[ReferenceId],[AccessNumber],[PkIdUsuario])
VALUES (NEWID(),'',1,'UOxg2B7HCZwZZ/drSkwHrA==','C5F91B8B-9E25-4576-96E7-CD3317F1AB87',null,0,0,null,0,0,10000,'0000010000',3)




CREATE TABLE dbo.AspNetUserRoles (
    UserId NVARCHAR(128) NOT NULL,
    RoleId NVARCHAR(128) NOT NULL,
    ExpireDate DATETIME,
    CONSTRAINT CONSTRAINT_PK_AspNetUserRoles PRIMARY KEY CLUSTERED (UserId, RoleId),
    CONSTRAINT CONSTRAINT_FK_AspNetUserRoles_User FOREIGN KEY (UserId)
        REFERENCES dbo.AspNetUsers(Id),
    CONSTRAINT CONSTRAINT_FK_AspNetUserRoles_Role FOREIGN KEY (RoleId)
        REFERENCES dbo.AspNetRoles(Id)
);

/*  [dbo].[AspNetUserRoles]  */
INSERT INTO [dbo].[AspNetUserRoles] ([UserId] ,[RoleId] ,[ExpireDate]) VALUES ('3E3B05E8-0A87-49DF-97D3-A5FA7AF97825' ,'71804e93-9753-4684-84fd-cf037349c111' ,GETDATE())
INSERT INTO [dbo].[AspNetUserRoles] ([UserId] ,[RoleId] ,[ExpireDate]) VALUES ('A06C2BE9-5070-46B3-9759-D3ACDFBB00B4' ,'739CC754-488B-4BB4-B7FB-62F6BF3C26D0' ,GETDATE())
INSERT INTO [dbo].[AspNetUserRoles] ([UserId] ,[RoleId] ,[ExpireDate]) VALUES ('F567D8EC-47C1-4B34-827B-20F0FF182BAF' ,'67A6E679-DBC4-402D-AE6E-7F28DDB11BD8' ,GETDATE())

--select a.Id,b.Id,dateadd(day,29,GETDATE())
--from dbo.AspNetUsers as a
--inner join [dbo].[AspNetRoles] as b on 1=1


---
--- CREATE TABLE: dbo.StoreMenu
--- drop table SIS.Menu
CREATE TABLE SIS.Menu (
    PKIdMenu INT NOT NULL,
    Nombre NVARCHAR(150) NOT NULL,
    Tipo INT NOT NULL,
    FKIdMenu_SIS INT NULL, -- Menú padre (auto-relación)
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
    CONSTRAINT CONSTRAINT_FK_Menu_Padre FOREIGN KEY (FKIdMenu_SIS)
        REFERENCES SIS.Menu(PKIdMenu)
);
GO

--drop table  SIS.MenuRole
CREATE TABLE SIS.MenuRole (
    FKIdMenu_SIS INT NOT NULL,
    RoleId NVARCHAR(128) NOT NULL,
    Activo BIT NOT NULL DEFAULT 1,
    CreatedByOperatorId INT,
    CreatedDateTime DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedByOperatorId INT,
    ModifiedDateTime DATETIME,
    CONSTRAINT CONSTRAINT_PK_MenuRole PRIMARY KEY CLUSTERED (FKIdMenu_SIS, RoleId),
    CONSTRAINT CONSTRAINT_FK_MenuRole_Menu FOREIGN KEY (FKIdMenu_SIS)
        REFERENCES SIS.Menu(PKIdMenu),
    CONSTRAINT CONSTRAINT_FK_MenuRole_Role FOREIGN KEY (RoleId)
        REFERENCES dbo.AspNetRoles(Id)
);




MERGE INTO SIS.Menu AS TARGET
	USING (VALUES
	(1, N'Principal', 2, NULL, N'Principal', N'/', N'FaHome', 1, N'ESP',100,1000,getdate())
	,(2, N'Configuración', 1, NULL, N'Configuración', N'/', N'FaRegSun', 1, N'ESP',200,1000,getdate())
	,(3, N'Mi Perfíl', 2, 2, N'Perfil de Usuario', N'/configuracion/perfil', N'FaUser', 1, N'ESP',201,1000,getdate())
	,(4, N'Usuario', 2, 2, N'Administración de Usuarios', N'/configuracion/usuarios', N'FaUser', 1, N'ESP',202,1000,getdate())
	,(5, N'Empresa', 2, 2, N'Empresa', N'/configuracion/empresas', N'FaRegUser', 1, N'ESP',203,1000,getdate())
	,(6, N'Departamento', 2, 2, N'Departamento', N'/configuracion/departamentos', N'FaRegUser', 1, N'ESP',204,1000,getdate())
	,(7, N'Menu', 2, 2, N'Menu', N'/configuracion/menus', N'RiMenuLine', 1, N'ESP',205,1000,getdate())
	,(8, N'Pedidos', 1, NULL, N'Pedidos', N'/', N'FaRegSun', 1, N'ESP',300,1000,getdate())
	,(9, N'Orden', 2, 8, N'Orden', N'/orders/order', N'RiListCheck2', 1, N'ESP',301,1000,getdate())
)
	AS SOURCE (PKIdMenu, Nombre, [Tipo], [FKIdMenu_SIS], [LegacyName], Ruta, [ImageUrl], Activo, [Lenguaje], [Orden],[CreatedByOperatorId],[CreatedDateTime])
	ON (TARGET.PKIdMenu=SOURCE.PKIdMenu)
	WHEN MATCHED THEN
				--UPDATES

				UPDATE SET
					TARGET.Nombre = SOURCE.Nombre
					,TARGET.[Tipo] = SOURCE.[Tipo]
					,TARGET.[FKIdMenu_SIS] = SOURCE.[FKIdMenu_SIS]
					,TARGET.[LegacyName] = SOURCE.[LegacyName]
					,TARGET.Ruta = SOURCE.Ruta
					,TARGET.[ImageUrl] = SOURCE.[ImageUrl]
					,TARGET.Activo = SOURCE.Activo
					,TARGET.[Lenguaje] = SOURCE.[Lenguaje]
					,TARGET.[Orden] = SOURCE.[Orden]
					,TARGET.[CreatedByOperatorId] = SOURCE.[CreatedByOperatorId]
					,TARGET.[CreatedDateTime] = SOURCE.[CreatedDateTime]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (PKIdMenu, Nombre, [Tipo], [FKIdMenu_SIS], [LegacyName], Ruta, [ImageUrl], Activo, [Lenguaje], [Orden],[CreatedByOperatorId],[CreatedDateTime])
		VALUES (PKIdMenu, Nombre, [Tipo], [FKIdMenu_SIS], [LegacyName], Ruta, [ImageUrl], Activo, [Lenguaje], [Orden],[CreatedByOperatorId],[CreatedDateTime]);


	
MERGE INTO SIS.MenuRole AS TARGET
	USING (
	SELECT DISTINCT M.PKIdMenu	,R.id AS [RoleId] ,M.Activo	,[CreatedByOperatorId] = 1 ,[CreatedDateTime] = getdate() --, M.IsActive
	FROM dbo.aspnetroles AS R (NOLOCK) 
	INNER JOIN [dbo].[AspNetUserRoles] AS UR (NOLOCK)  ON R.id = UR.RoleId
	INNER JOIN [dbo].[AspNetUsers] AS U (NOLOCK)  ON u.id = UR.UserId
	INNER JOIN [dbo].[AspNetClaims] AS C (NOLOCK)  ON C.RoleId = R.Id
	INNER JOIN [dbo].[AspNetClaimValues] AS CV (NOLOCK)  ON C.Id = CV.ClaimId
	INNER JOIN SIS.Menu AS M (NOLOCK)  ON M.Activo = 1 --OR M.IsActive = 0
	WHERE CV.Value = 'view-menu'
	
)
	AS SOURCE (FKIdMenu_SIS, [RoleId], Activo, [CreatedByOperatorId],[CreatedDateTime])
	ON (TARGET.FKIdMenu_SIS=SOURCE.FKIdMenu_SIS AND TARGET.[RoleId]=SOURCE.[RoleId])
	WHEN MATCHED THEN
				--UPDATES

				UPDATE SET
					TARGET.Activo = SOURCE.Activo
					,TARGET.[CreatedByOperatorId] = SOURCE.[CreatedByOperatorId]
					,TARGET.[CreatedDateTime] = SOURCE.[CreatedDateTime]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (FKIdMenu_SIS, [RoleId], Activo, [CreatedByOperatorId],[CreatedDateTime])
		VALUES (FKIdMenu_SIS, [RoleId], Activo, [CreatedByOperatorId],[CreatedDateTime])
	WHEN NOT MATCHED BY SOURCE 
	THEN DELETE;




CREATE TABLE SIS.PerfilUsuario (
    FKIdUsuario_SIS INT PRIMARY KEY,
    Fotografia VARBINARY(MAX),
    ContentType NVARCHAR(50),
	[FileName] [nvarchar](64) NULL,
	[FileExtension] [nvarchar](8) NULL,
	Activo BIT NOT NULL DEFAULT 1,						-- borrado lógico
	FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),      -- cuándo fue creado
    UsuarioCreacion INT NOT NULL,                      -- quién lo creó
    FechaModificacion DATETIME2 NULL,                   -- última modificación
    UsuarioModificacion INT NULL              -- quién modificó
    FOREIGN KEY (FKIdUsuario_SIS) REFERENCES SIS.Usuario(PKIdUsuario) ON DELETE CASCADE
);

--drop table [SIS].[OrigenLogMessage]
CREATE TABLE [SIS].[OrigenLogMessage](
	[PKIdOrigenLogMessage] [int] NOT NULL,
	[Descripcion] [nvarchar](50) NULL,
	Activo BIT NOT NULL DEFAULT 1,						-- borrado lógico
	FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),      -- cuándo fue creado
    UsuarioCreacion INT NOT NULL,                      -- quién lo creó
    FechaModificacion DATETIME2 NULL,                   -- última modificación
    UsuarioModificacion INT NULL              -- quién modificó
    CONSTRAINT CONSTRAINT_PK_OrigenLogMessage PRIMARY KEY CLUSTERED ([PKIdOrigenLogMessage])
)

INSERT INTO [SIS].[OrigenLogMessage] (PKIdOrigenLogMessage, Descripcion, UsuarioCreacion) VALUES
(1, 'Sistema', 1),
(2, 'Aplicación', 1),
(3, 'Seguridad', 1),
(4, 'Base de Datos', 1),
(5, 'Red', 1),
(6, 'Hardware', 1),
(7, 'Usuario', 1),
(8, 'Otro', 1)

--drop table [SIS].[SystemLog]
CREATE TABLE [SIS].[SystemLog](
	[PKIdSystemLog] [int] IDENTITY(1,1) NOT NULL,
	[FKIdOrigenLogMessage_SIS] [int] NOT NULL,
	[Date] DATETIME2 DEFAULT SYSDATETIME(),      -- cuándo fue creado
	[Type] [nvarchar](24) NULL,
	[ProgName] [nvarchar](256) NULL,
	[EmployeeNo] [nvarchar](24) NULL,
	[Category] [nvarchar](24) NULL,
	[IPClient] [nvarchar](24) NULL,
	[HostName] [nvarchar](32) NULL,
	[Thread] [varchar](255) NULL,
	[Level] [varchar](20) NULL,
	[Logger] [varchar](255) NULL,
	[Message] [varchar](4000) NULL,
	[Exception] [nvarchar](4000) NULL,
	[Context] [nvarchar](10) NULL,
	[MethodName] [nvarchar](200) NULL,
	[Parameters] [nvarchar](4000) NULL,
	[ExecutionTime] [int] NULL,
    CONSTRAINT CONSTRAINT_PK_SystemLog PRIMARY KEY CLUSTERED ([PKIdSystemLog]),
    CONSTRAINT CONSTRAINT_FK_SystemLog_OrigenLogMessage FOREIGN KEY ([FKIdOrigenLogMessage_SIS])
        REFERENCES [SIS].[OrigenLogMessage]([PKIdOrigenLogMessage])
) ON [PRIMARY]

--drop table [SIS].[SystemParamCatalog]
CREATE TABLE [SIS].[SystemParamCatalog](
	[PKIdSystemParamCatalog] [int] NOT NULL,
	[Code] [nvarchar](50) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	Activo BIT NOT NULL DEFAULT 1,						-- borrado lógico
	FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),      -- cuándo fue creado
    UsuarioCreacion INT NOT NULL,                      -- quién lo creó
    FechaModificacion DATETIME2 NULL,                   -- última modificación
    UsuarioModificacion INT NULL              -- quién modificó
 CONSTRAINT CONSTRAINT_PK_SystemParamCatalog PRIMARY KEY CLUSTERED ([PKIdSystemParamCatalog])
) ON [PRIMARY]
GO

--truncate table [SIS].[SystemParamCatalog]
INSERT INTO [SIS].[SystemParamCatalog]
           ([PKIdSystemParamCatalog]
           ,[Code]
           ,[Name]
           ,[Activo]
           ,[UsuarioCreacion])
     VALUES
           (1           ,'SISTEMA'           ,'SISTEMA'           ,1           ,1),
           (2           ,'CATALOGOS'           ,'CATALOGOS'           ,1           ,1)

--drop table [SIS].[SystemParamValue]
CREATE TABLE [SIS].[SystemParamValue](
	[PKIdSystemParamValue] [int] NOT NULL,
	[FKIdSystemParamCatalog_SIS] [int] NOT NULL,
	[Value] [nvarchar](max) NOT NULL,
	[Descripcion] [varchar](128) NOT NULL,
	Activo BIT NOT NULL DEFAULT 1,						-- borrado lógico
	FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),      -- cuándo fue creado
    UsuarioCreacion INT NOT NULL,                      -- quién lo creó
    FechaModificacion DATETIME2 NULL,                   -- última modificación
    UsuarioModificacion INT NULL              -- quién modificó
    CONSTRAINT CONSTRAINT_PK_SystemParamValue PRIMARY KEY CLUSTERED ([PKIdSystemParamValue]),
    CONSTRAINT CONSTRAINT_FK_SystemParamCatalog_SystemParamValue FOREIGN KEY ([FKIdSystemParamCatalog_SIS])
        REFERENCES [SIS].[SystemParamCatalog]([PKIdSystemParamCatalog])
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

INSERT INTO [SIS].[SystemParamValue]
           ([PKIdSystemParamValue]
           ,[FKIdSystemParamCatalog_SIS]
           ,[Value]
           ,[Descripcion]
           ,[Activo]
           ,[UsuarioCreacion])
     VALUES
           (1
           ,1
           ,1
           ,'Variable que activa o desactiva el poder insertar en la tabla SystemLog'
           ,1
           ,1)

select * from sis.SystemLog