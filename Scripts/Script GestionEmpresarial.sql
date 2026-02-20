
/*
--create database test


use test
GO
--drop database GestionEmpresarial

CREATE SCHEMA SIS  --//Sistema
GO
CREATE SCHEMA NOM  --//Nómina
GO
CREATE SCHEMA ALM  --//Almacen
GO
CREATE SCHEMA CONTA  --//Contabilidad
GO



*/

-- Eliminar si ya existe
-- DROP TABLE SIS.Paises

CREATE TABLE SIS.Paises (
    PKIdPais INT NOT NULL,
    Nombre VARCHAR(64) NOT NULL,
    CONSTRAINT CONSTRAINT_PKIdPaises PRIMARY KEY CLUSTERED (PKIdPais)
);

INSERT INTO SIS.Paises (PKIdPais, Nombre) VALUES
(1, 'México'),
(2, 'Estados Unidos'),
(3, 'Canadá'),
(4, 'Brasil'),
(5, 'Argentina'),
(6, 'Colombia'),
(7, 'Chile'),
(8, 'Perú'),
(9, 'España'),
(10, 'Francia'),
(11, 'Alemania'),
(12, 'Italia'),
(13, 'Reino Unido'),
(14, 'Japón'),
(15, 'China'),
(16, 'India'),
(17, 'Australia'),
(18, 'Rusia'),
(19, 'Sudáfrica'),
(20, 'Egipto');

--drop table SIS.Estados
CREATE TABLE SIS.Estados (
    PKIdEstado INT NOT NULL,
    FKIdPais_SIS INT NOT NULL,
    Nombre VARCHAR(64) NOT NULL,
    CONSTRAINT CONSTRAINT_PK_Estados PRIMARY KEY CLUSTERED (PKIdEstado),
    CONSTRAINT CONSTRAINT_FK_Estados_Paises FOREIGN KEY (FKIdPais_SIS)
        REFERENCES SIS.Paises(PKIdPais)
);

INSERT INTO SIS.Estados (PKIdEstado,FKIdPais_SIS, Nombre) VALUES
(1,1, 'Aguascalientes'),
(2,1, 'Baja California'),
(3,1, 'Baja California Sur'),
(4,1, 'Campeche'),
(5,1, 'Coahuila de Zaragoza'),
(6,1, 'Colima'),
(7,1, 'Chiapas'),
(8,1, 'Chihuahua'),
(9,1, 'Ciudad de México'),
(10,1, 'Durango'),
(11,1, 'Guanajuato'),
(12,1, 'Guerrero'),
(13,1, 'Hidalgo'),
(14,1, 'Jalisco'),
(15,1, 'México'),
(16,1, 'Michoacán de Ocampo'),
(17,1, 'Morelos'),
(18,1, 'Nayarit'),
(19,1, 'Nuevo León'),
(20,1, 'Oaxaca'),
(21,1, 'Puebla'),
(22,1, 'Querétaro'),
(23,1, 'Quintana Roo'),
(24,1, 'San Luis Potosí'),
(25,1, 'Sinaloa'),
(26,1, 'Sonora'),
(27,1, 'Tabasco'),
(28,1, 'Tamaulipas'),
(29,1, 'Tlaxcala'),
(30,1, 'Veracruz'),
(31,1, 'Yucatán'),
(32,1, 'Zacatecas');


-- Tabla de Empresa
--drop table SIS.Empresa
CREATE TABLE SIS.Empresa (
    PKIdEmpresa INT IDENTITY(1,1) NOT NULL,
    Nombre NVARCHAR(128) NOT NULL,
    RFC NVARCHAR(13) NOT NULL,
	Activo BIT NOT NULL DEFAULT 1,						-- borrado lógico
	FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),      -- cuándo fue creado
    UsuarioCreacion INT NOT NULL,                      -- quién lo creó
    FechaModificacion DATETIME2 NULL,                   -- última modificación
    UsuarioModificacion INT NULL              -- quién modificó
    CONSTRAINT CONSTRAINT_PK_Empresa PRIMARY KEY CLUSTERED (PKIdEmpresa)
);



INSERT INTO SIS.Empresa ( Nombre, RFC, UsuarioCreacion) VALUES
('TechNova S.A. de C.V.', 'TNV010101AAA', 1),
('Grupo Constructora Delta', 'GCD020202BBB', 1),
('Alimentos La Laguna', 'ALL030303CCC', 1);

CREATE TABLE SIS.EmpresaEstado (
    FKIdEmpresa_SIS INT  NOT NULL,
    FKIdEstado_SIS INT NOT NULL,
	Activo BIT NOT NULL DEFAULT 1,						-- borrado lógico
	FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),      -- cuándo fue creado
    UsuarioCreacion INT NOT NULL,                      -- quién lo creó
    FechaModificacion DATETIME2 NULL,                   -- última modificación
    UsuarioModificacion INT NULL              -- quién modificó
    CONSTRAINT CONSTRAINT_PK_EmpresaEstado_Empresa_Estado PRIMARY KEY CLUSTERED (FKIdEmpresa_SIS, FKIdEstado_SIS),
    CONSTRAINT CONSTRAINT_FK_EmpresaEstado_Empresa FOREIGN KEY (FKIdEmpresa_SIS)
        REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT CONSTRAINT_FK_EmpresaEstado_Estados FOREIGN KEY (FKIdEstado_SIS)
        REFERENCES SIS.Estados(PKIdEstado)
);

INSERT INTO SIS.EmpresaEstado ( FKIdEmpresa_SIS, FKIdEstado_SIS,UsuarioCreacion) VALUES
(1,15,1),
(1,9,1),
(1,21,1);

-- Tabla de Departamento
--drop table SIS.Departamento
CREATE TABLE SIS.Departamento (
    PKIdDepartamento  INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    Nombre NVARCHAR(128) NOT NULL,
	Activo BIT NOT NULL DEFAULT 1,						-- borrado lógico
	FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),      -- cuándo fue creado
    UsuarioCreacion INT NOT NULL,                      -- quién lo creó
    FechaModificacion DATETIME2 NULL,                   -- última modificación
    UsuarioModificacion INT NULL              -- quién modificó
    CONSTRAINT CONSTRAINT_PK_Departamento PRIMARY KEY CLUSTERED (PKIdDepartamento),
    CONSTRAINT CONSTRAINT_FK_Departamento_Empresa FOREIGN KEY (FKIdEmpresa_SIS)
        REFERENCES SIS.Empresa(PKIdEmpresa)
);

INSERT INTO SIS.Departamento (FKIdEmpresa_SIS, Nombre,UsuarioCreacion) VALUES
(1, 'GERENTE GENERAL',1),
(1,'GERENTE DE OPERACIONES',1),
(1, 'GERENTE DE VENTAS',1),
(1,'RECURSOS HUMANOS',1)

--update SIS.Departamento set Nombre = 'GERENTE GENERAL' where PKIdDepartamento = 1
--update SIS.Departamento set Nombre = 'GERENTE DE OPERACIONES' where PKIdDepartamento = 2

/*
pws: Tecno.2025
*/

--update SIS.Usuario set Sexo = 0 where PkIdUsuario = 1

-- Tabla de Usuario
--drop table SIS.Usuario
--select * from SIS.Usuario
CREATE TABLE SIS.Usuario (
    PkIdUsuario INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    Nombre NVARCHAR(64) NOT NULL,
    ApellidoPaterno NVARCHAR(64) NOT NULL,
    ApellidoMaterno NVARCHAR(64) NOT NULL,
    Iniciales NVARCHAR(3) NOT NULL,
    PayrollID NVARCHAR(20) NOT NULL,
    CodigoPostal NVARCHAR(9),
    Telefono NVARCHAR(16) NOT NULL,
    Direccion1 NVARCHAR(128) NOT NULL,
    Direccion2 NVARCHAR(64) NOT NULL,

	Email nvarchar(60) NOT NULL,
	NumeroSocial nvarchar(12) NOT NULL,
	Gafete nvarchar(11) NOT NULL,
	Sexo bit NOT NULL,

	Activo BIT NOT NULL DEFAULT 1,						-- borrado lógico
	FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),      -- cuándo fue creado
    UsuarioCreacion INT NOT NULL,                      -- quién lo creó
    FechaModificacion DATETIME2 NULL,                   -- última modificación
    UsuarioModificacion INT NULL              -- quién modificó

    CONSTRAINT CONSTRAINT_PK_Usuario PRIMARY KEY CLUSTERED (PkIdUsuario),

    CONSTRAINT CONSTRAINT_FK_Usuario_Empresa FOREIGN KEY (FKIdEmpresa_SIS)
        REFERENCES SIS.Empresa(PKIdEmpresa)
);


INSERT INTO SIS.Usuario (
    FKIdEmpresa_SIS, Nombre, ApellidoPaterno, ApellidoMaterno, Iniciales,
    PayrollID, CodigoPostal, Telefono,
    Direccion1, Direccion2,
    Email, NumeroSocial, Gafete, Sexo,UsuarioCreacion
) VALUES
(1, 'Administrador', '-', '-', 'CMR', 'admon01', '11000', '5512345678',
 'Calle Roble 101', 'Piso 2', 'eliseo_eae@htomail.com', 'NS1234567890', 'GF001A', 1, 1),

(2, 'Administrador', '-', '-', 'PZL', 'admon02', '76000', '4425678910',
 'Av. Universidad 45', 'Edif. B', 'eliseo2_eae@htomail.com', 'NS0987654321', 'GF002B', 0,1 ),

(3, 'Administrador', '-', '-', 'ESR', 'admon03', '80000', '6671234567',
 'Prol. Obregón 321', 'Int. 5', 'eliseo3_eae@htomail.com', 'NS5678901234', 'GF003C', 1,1);


-- Tabla de Sucursal (reemplaza Tienda)
-- Tabla para tipos de sucursal (catálogo)
CREATE TABLE SIS.CatTipoSucursal (
    PKIdTipoSucursal INT NOT NULL,
    Descripcion NVARCHAR(50) NOT NULL,
    Activo BIT NOT NULL DEFAULT 1,						-- borrado lógico
	FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),      -- cuándo fue creado
    UsuarioCreacion int NOT NULL,                      -- quién lo creó
    FechaModificacion DATETIME2 NULL,                   -- última modificación
    UsuarioModificacion INT NULL              -- quién modificó
    CONSTRAINT PK_TipoSucursal PRIMARY KEY (PKIdTipoSucursal)
);


CREATE TABLE SIS.Sucursal (
    PKIdSucursal INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdEstado_SIS INT NOT NULL,
    Nombre NVARCHAR(128) NOT NULL,
    CodigoSucursal NVARCHAR(20) NOT NULL UNIQUE,
    Alias NVARCHAR(50) NULL,                           -- Nombre corto o alias
    TipoSucursal INT NOT NULL DEFAULT 1,                -- 1=Comercial, 2=Almacén, 3=Oficina, etc.
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
    EsActiva BIT NOT NULL DEFAULT 1,                    -- Si está operando actualmente
    Latitud DECIMAL(9,6) NULL,
    Longitud DECIMAL(9,6) NULL,
    MetrosCuadrados DECIMAL(10,2) NULL,                 -- Tamaño físico
    CapacidadPersonas INT NULL,                         -- Capacidad de atención
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    
    CONSTRAINT CONSTRAINT_PK_Sucursal PRIMARY KEY CLUSTERED (PKIdSucursal),
    CONSTRAINT CONSTRAINT_FK_Sucursal_Empresa FOREIGN KEY (FKIdEmpresa_SIS)
        REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT CONSTRAINT_FK_Sucursal_Estado FOREIGN KEY (FKIdEstado_SIS)
        REFERENCES SIS.Estados(PKIdEstado),
    CONSTRAINT CHK_TipoSucursal CHECK (TipoSucursal IN (1,2,3,4,5)) -- Puedes definir más tipos
);


-- Tabla de relación Usuario-Sucursal
CREATE TABLE SIS.UsuarioSucursal (
    FKIdUsuario_SIS INT NOT NULL,
    FKIdSucursal_SIS INT NOT NULL,
    FKIdDepartamento_SIS INT NULL,                      -- Departamento al que pertenece en esta sucursal
    EsGerente BIT NOT NULL DEFAULT 0,
    EsSupervisor BIT NOT NULL DEFAULT 0,
    PuedeAcceder BIT NOT NULL DEFAULT 1,
    PuedeConfigurar BIT NOT NULL DEFAULT 0,
    PuedeOperar BIT NOT NULL DEFAULT 1,
    PuedeReportes BIT NOT NULL DEFAULT 0,
    FechaAsignacion DATETIME2 DEFAULT SYSDATETIME(),
    FechaFinAsignacion DATETIME2 NULL,                  -- Para rotaciones de personal
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion NVARCHAR(100),
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion NVARCHAR(100) NULL,
    
    CONSTRAINT CONSTRAINT_PK_UsuarioSucursal PRIMARY KEY (FKIdUsuario_SIS, FKIdSucursal_SIS),
    CONSTRAINT CONSTRAINT_FK_UsuarioSucursal_Usuario FOREIGN KEY (FKIdUsuario_SIS)
        REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT CONSTRAINT_FK_UsuarioSucursal_Sucursal FOREIGN KEY (FKIdSucursal_SIS)
        REFERENCES SIS.Sucursal(PKIdSucursal),
    CONSTRAINT CONSTRAINT_FK_UsuarioSucursal_Departamento FOREIGN KEY (FKIdDepartamento_SIS)
        REFERENCES SIS.Departamento(PKIdDepartamento)
);

-- Índices para Sucursal
CREATE INDEX IX_Sucursal_Empresa ON SIS.Sucursal(FKIdEmpresa_SIS) WHERE Activo = 1;
CREATE INDEX IX_Sucursal_Estado ON SIS.Sucursal(FKIdEstado_SIS) WHERE Activo = 1;
CREATE INDEX IX_Sucursal_Codigo ON SIS.Sucursal(CodigoSucursal) WHERE Activo = 1;
CREATE INDEX IX_Sucursal_Matriz ON SIS.Sucursal(FKIdEmpresa_SIS, EsMatriz) WHERE Activo = 1;
CREATE INDEX IX_Sucursal_Tipo ON SIS.Sucursal(TipoSucursal) WHERE Activo = 1;

-- Índices para UsuarioSucursal
CREATE INDEX IX_UsuarioSucursal_Sucursal ON SIS.UsuarioSucursal(FKIdSucursal_SIS) WHERE Activo = 1;
CREATE INDEX IX_UsuarioSucursal_UsuarioAcceso ON SIS.UsuarioSucursal(FKIdUsuario_SIS, PuedeAcceder) WHERE Activo = 1;
CREATE INDEX IX_UsuarioSucursal_Departamento ON SIS.UsuarioSucursal(FKIdDepartamento_SIS) WHERE Activo = 1;


-- Insertar tipos de sucursal primero
INSERT INTO SIS.CatTipoSucursal (PKIdTipoSucursal, Descripcion, UsuarioCreacion) VALUES
(1, 'Matriz/Central',1),
(2, 'Sucursal Comercial',1),
(3, 'Almacén',1),
(4, 'Oficina Regional',1),
(5, 'Punto de Venta',1);

-- Insertar sucursales para TechNova
INSERT INTO SIS.Sucursal (
    FKIdEmpresa_SIS, FKIdEstado_SIS, Nombre, CodigoSucursal, 
    Alias, TipoSucursal, Direccion, Ciudad, TelefonoPrincipal, 
    Email, EsMatriz, EsActiva, UsuarioCreacion
) VALUES
-- Sucursal Matriz
(1, 15, 'TechNova Matriz Santa Fe', 'TECH-MAT-001', 
 'Matriz Santa Fe', 1, 'Av. Santa Fe 501, Santa Fe', 'Ciudad de México',
 '555-100-2000', 'matriz@technova.com', 1, 1,1),

-- Sucursales Comerciales
(1, 15, 'TechNova Sucursal Satélite', 'TECH-SAT-001',
 'Satélite', 2, 'Plaza Satélite Local 45', 'Naucalpan',
 '555-123-4567', 'satelite@technova.com', 0, 1,1),

(1, 9, 'TechNova Sucursal Polanco', 'TECH-POL-001',
 'Polanco', 2, 'Av. Presidente Masaryk 456', 'Ciudad de México',
 '555-456-7890', 'polanco@technova.com', 0, 1,1),

(1, 21, 'TechNova Sucursal Puebla', 'TECH-PUE-001',
 'Puebla Centro', 2, 'Av. Juárez 789', 'Puebla',
 '222-345-6789', 'puebla@technova.com', 0, 1,1),

-- Almacén
(1, 15, 'TechNova Almacén Central', 'TECH-ALM-001',
 'Almacén Toluca', 3, 'Bodega 45, Parque Industrial', 'Toluca',
 '722-111-2233', 'almacen@technova.com', 0, 1,1),

-- Oficina Regional
(1, 19, 'TechNova Oficina Monterrey', 'TECH-OFI-001',
 'Oficina MTY', 4, 'Av. Constitución 123', 'Monterrey',
 '818-999-8888', 'monterrey@technova.com', 0, 1,1);

-- Asignar sucursales al usuario administrador
INSERT INTO SIS.UsuarioSucursal (
    FKIdUsuario_SIS, FKIdSucursal_SIS, FKIdDepartamento_SIS,
    EsGerente, PuedeConfigurar, PuedeReportes, UsuarioCreacion
) VALUES
-- Administrador tiene acceso total a todas las sucursales
(1, 1, 1, 1, 1, 1, 1),  -- Matriz - Gerente General
(1, 2, 1, 1, 1, 1, 1),  -- Satélite
(1, 3, 1, 1, 1, 1, 1),  -- Polanco
(1, 4, 1, 1, 1, 1, 1),  -- Puebla
(1, 5, 1, 1, 1, 1, 1),  -- Almacén
(1, 6, 1, 1, 1, 1, 1);  -- Monterrey

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
INSERT INTO [dbo].[AspNetUserRoles] ([UserId] ,[RoleId] ,[ExpireDate]) VALUES ('5163E20B-5978-4AD8-BC38-A534F6FF6006' ,'71804e93-9753-4684-84fd-cf037349c111' ,GETDATE())
INSERT INTO [dbo].[AspNetUserRoles] ([UserId] ,[RoleId] ,[ExpireDate]) VALUES ('D0C8D24D-5817-4027-AF61-683C567C47AA' ,'739CC754-488B-4BB4-B7FB-62F6BF3C26D0' ,GETDATE())
INSERT INTO [dbo].[AspNetUserRoles] ([UserId] ,[RoleId] ,[ExpireDate]) VALUES ('D10FAE89-732F-48DF-AA76-1E6B01CA5A3F' ,'67A6E679-DBC4-402D-AE6E-7F28DDB11BD8' ,GETDATE())

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
	SELECT M.PKIdMenu	,R.id AS [RoleId] ,M.Activo	,[CreatedByOperatorId] = 1 ,[CreatedDateTime] = getdate() --, M.IsActive
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