USE [GestionEmpresarial];
GO

-- =============================================
-- 1. ALMA.Familia
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Familia' AND schema_id = SCHEMA_ID('ALMA'))
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

SET IDENTITY_INSERT ALMA.Familia ON;
INSERT INTO ALMA.Familia (PKIdFamilia, Descripcion, Clave, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdFamilia, Descripcion, Clave, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SICOP.Familia
WHERE NOT EXISTS (SELECT 1 FROM ALMA.Familia WHERE PKIdFamilia = PK_IdFamilia);
SET IDENTITY_INSERT ALMA.Familia OFF;
GO

-- =============================================
-- 2. ALMA.GrupoBien (depende de ALMA.Familia)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'GrupoBien' AND schema_id = SCHEMA_ID('ALMA'))
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

SET IDENTITY_INSERT ALMA.GrupoBien ON;
INSERT INTO ALMA.GrupoBien (
    PKIdGrupoBien, FKIdFamilia_ALMA, Descripcion, Clave, ClaveAN, CABM_ACT, CLAVE_CUCOP, MEDIDA,
    Activo, FechaCreacion, UsuarioCreacion
)
SELECT
    PK_IdGrupoBien, FK_IdFamilia__SICOP, Descripcion, Clave, ClaveAN, CABM_ACT, CLAVE_CUCOP, MEDIDA,
    ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SICOP.GrupoBien
WHERE NOT EXISTS (SELECT 1 FROM ALMA.GrupoBien WHERE PKIdGrupoBien = PK_IdGrupoBien);
SET IDENTITY_INSERT ALMA.GrupoBien OFF;
GO

-- =============================================
-- 3. ALMA.TipoPatrimonio
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TipoPatrimonio' AND schema_id = SCHEMA_ID('ALMA'))
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

SET IDENTITY_INSERT ALMA.TipoPatrimonio ON;
INSERT INTO ALMA.TipoPatrimonio (PKIdTipoPatrimonio, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdTipoPatrimonio, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SICOP.TipoPatrimonio
WHERE NOT EXISTS (SELECT 1 FROM ALMA.TipoPatrimonio WHERE PKIdTipoPatrimonio = PK_IdTipoPatrimonio);
SET IDENTITY_INSERT ALMA.TipoPatrimonio OFF;
GO

-- =============================================
-- 4. ALMA.TipoAdquisicion (desde SICOP.TipoAdq)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TipoAdquisicion' AND schema_id = SCHEMA_ID('ALMA'))
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

SET IDENTITY_INSERT ALMA.TipoAdquisicion ON;
INSERT INTO ALMA.TipoAdquisicion (PKIdTipoAdq, Clave, Descripcion, Descripmovto, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdTipoAdq, Clave, Descripcion, Descripmovto, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SICOP.TipoAdq
WHERE NOT EXISTS (SELECT 1 FROM ALMA.TipoAdquisicion WHERE PKIdTipoAdq = PK_IdTipoAdq);
SET IDENTITY_INSERT ALMA.TipoAdquisicion OFF;
GO

-- =============================================
-- 5. ALMA.Marca
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Marca' AND schema_id = SCHEMA_ID('ALMA'))
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

SET IDENTITY_INSERT ALMA.Marca ON;
INSERT INTO ALMA.Marca (PKIdMarca, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdMarca, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SICOP.Marca
WHERE NOT EXISTS (SELECT 1 FROM ALMA.Marca WHERE PKIdMarca = PK_IdMarca);
SET IDENTITY_INSERT ALMA.Marca OFF;
GO

-- =============================================
-- 6. NOM.Persona (desde RHCT.Persona)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Persona' AND schema_id = SCHEMA_ID('NOM'))
BEGIN
    CREATE TABLE NOM.Persona (
        PKIdPersona INT IDENTITY(1,1) NOT NULL,
        Clave NVARCHAR(15) NOT NULL,
        Nombre NVARCHAR(50) NOT NULL,
        Paterno NVARCHAR(50) NOT NULL,
        Materno NVARCHAR(50) NOT NULL,
        Telefono_particular NVARCHAR(15) NULL,
        Telefono_movil NVARCHAR(15) NULL,
        Fecha_de_Inicio DATETIME NOT NULL,
        Fecha_Fin DATETIME NULL,
        RFC NVARCHAR(15) NOT NULL,
        Curp NVARCHAR(18) NOT NULL,
        FechaNacimiento DATETIME NOT NULL,
        Sexo NVARCHAR(10) NULL,
        ESTADO_CIVIL NVARCHAR(20) NULL,
        Municipio NVARCHAR(20) NULL,
        REG_IMSS NVARCHAR(12) NULL,
        NoCartilla NVARCHAR(16) NULL,
        NoLicencia NVARCHAR(16) NULL,
        NoPasaporte NVARCHAR(16) NULL,
        NoCredencialElector NVARCHAR(32) NULL,
        Calle NVARCHAR(40) NULL,
        Num_exterior NVARCHAR(10) NULL,
        Num_interior NVARCHAR(10) NULL,
        Colonia NVARCHAR(40) NULL,
        CP NVARCHAR(6) NULL,
        Estado NVARCHAR(30) NULL,
        CORREO_ELECTRONICO NVARCHAR(250) NULL,
        TIPO_CONTRATACION NVARCHAR(50) NULL,
        PUESTO NVARCHAR(100) NULL,
        SUELDO_BASE FLOAT NULL,
        COMPENSACION_GARANTIZADA FLOAT NULL,
        BANCO NVARCHAR(100) NULL,
        NUMERO_CUENTA NVARCHAR(25) NULL,
        CLABE NVARCHAR(50) NULL,
        Activo BIT NOT NULL CONSTRAINT DF_Persona_Activo DEFAULT (1),
        FechaCreacion DATETIME2 CONSTRAINT DF_Persona_FechaCreacion DEFAULT SYSDATETIME(),
        UsuarioCreacion INT NOT NULL,
        FechaModificacion DATETIME2 NULL,
        UsuarioModificacion INT NULL,
        CONSTRAINT PK_Persona PRIMARY KEY (PKIdPersona),
        CONSTRAINT FK_Persona_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
        CONSTRAINT FK_Persona_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
    );
END
GO

SET IDENTITY_INSERT NOM.Persona ON;
INSERT INTO NOM.Persona (
    PKIdPersona, Clave, Nombre, Paterno, Materno,
    Telefono_particular, Telefono_movil, Fecha_de_Inicio, Fecha_Fin,
    RFC, Curp, FechaNacimiento, Sexo, ESTADO_CIVIL, Municipio,
    REG_IMSS, NoCartilla, NoLicencia, NoPasaporte, NoCredencialElector,
    Calle, Num_exterior, Num_interior, Colonia, CP, Estado,
    CORREO_ELECTRONICO, TIPO_CONTRATACION, PUESTO, SUELDO_BASE, COMPENSACION_GARANTIZADA,
    BANCO, NUMERO_CUENTA, CLABE, Activo, FechaCreacion, UsuarioCreacion
)
SELECT
    PK_IdPersona, Clave, Nombre, Paterno, Materno,
    Telefono_particular, Telefono_movil, Fecha_de_Inicio, Fecha_Fin,
    RFC, Curp, FechaNacimiento, Sexo, ESTADO_CIVIL, Municipio,
    REG_IMSS, NoCartilla, NoLicencia, NoPasaporte, NoCredencialElector,
    Calle, Num_exterior, Num_interior, Colonia, CP, Estado,
    CORREO_ELECTRONICO, TIPO_CONTRATACION, PUESTO, SUELDO_BASE, COMPENSACION_GARANTIZADA,
    BANCO, NUMERO_CUENTA, CLABE, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.RHCT.Persona
WHERE NOT EXISTS (SELECT 1 FROM NOM.Persona WHERE PKIdPersona = PK_IdPersona);
SET IDENTITY_INSERT NOM.Persona OFF;
GO

PRINT 'Tablas SICOP.Familia, SICOP.GrupoBien, SICOP.TipoPatrimonio, SICOP.TipoAdq, SICOP.Marca y RHCT.Persona creadas en sus esquemas correspondientes.';