-- =============================================
-- SCRIPT DE CREACIÓN Y MIGRACIÓN DE TABLAS
-- Tablas: PRES.PY, PRES.Ramo, PRES.PG, PRES.FuenteFinanciamiento,
--         PRES.TipoRecurso, PRES.Sector, PRES.PP, SIS.ActividadInstitucional,
--         PRES.SF, PRES.GF, SIS.Area
-- Base de datos destino: GestionEmpresarial
-- =============================================

USE [GestionEmpresarial];
GO

-- =============================================
-- 1. PRES.GF (Grupo Funcional)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'GF' AND schema_id = SCHEMA_ID('PRES'))
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

SET IDENTITY_INSERT PRES.GF ON;
INSERT INTO PRES.GF (PKIdGF, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdGF, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.GF
WHERE NOT EXISTS (SELECT 1 FROM PRES.GF WHERE PKIdGF = PK_IdGF);
SET IDENTITY_INSERT PRES.GF OFF;
GO

-- =============================================
-- 2. PRES.FN (Función) - Requerida por PRES.SF
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FN' AND schema_id = SCHEMA_ID('PRES'))
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

SET IDENTITY_INSERT PRES.FN ON;
INSERT INTO PRES.FN (PKIdFN, FKIdGF_PRES, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdFN, FK_IdGF__PRES, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.FN
WHERE NOT EXISTS (SELECT 1 FROM PRES.FN WHERE PKIdFN = PK_IdFN);
SET IDENTITY_INSERT PRES.FN OFF;
GO

-- =============================================
-- 3. PRES.SF (Subfunción)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SF' AND schema_id = SCHEMA_ID('PRES'))
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

SET IDENTITY_INSERT PRES.SF ON;
INSERT INTO PRES.SF (PKIdSF, FKIdFN_PRES, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdSF, FK_IdFN__PRES, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.SF
WHERE NOT EXISTS (SELECT 1 FROM PRES.SF WHERE PKIdSF = PK_IdSF);
SET IDENTITY_INSERT PRES.SF OFF;
GO

-- =============================================
-- 4. PRES.PP (Programa Presupuestal)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PP' AND schema_id = SCHEMA_ID('PRES'))
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

SET IDENTITY_INSERT PRES.PP ON;
INSERT INTO PRES.PP (PKIdPP, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdPP, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.PP
WHERE NOT EXISTS (SELECT 1 FROM PRES.PP WHERE PKIdPP = PK_IdPP);
SET IDENTITY_INSERT PRES.PP OFF;
GO

-- =============================================
-- 5. PRES.TipoRecurso
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TipoRecurso' AND schema_id = SCHEMA_ID('PRES'))
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

SET IDENTITY_INSERT PRES.TipoRecurso ON;
INSERT INTO PRES.TipoRecurso (PKIdTipoRecurso, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdTipoRecurso, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.TipoRecurso
WHERE NOT EXISTS (SELECT 1 FROM PRES.TipoRecurso WHERE PKIdTipoRecurso = PK_IdTipoRecurso);
SET IDENTITY_INSERT PRES.TipoRecurso OFF;
GO

-- =============================================
-- 6. PRES.Sector
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Sector' AND schema_id = SCHEMA_ID('PRES'))
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

SET IDENTITY_INSERT PRES.Sector ON;
INSERT INTO PRES.Sector (PKIdSector, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdSector, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.Sector
WHERE NOT EXISTS (SELECT 1 FROM PRES.Sector WHERE PKIdSector = PK_IdSector);
SET IDENTITY_INSERT PRES.Sector OFF;
GO

-- =============================================
-- 7. PRES.Ramo
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Ramo' AND schema_id = SCHEMA_ID('PRES'))
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

SET IDENTITY_INSERT PRES.Ramo ON;
INSERT INTO PRES.Ramo (PKIdRamo, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdRamo, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.Ramo
WHERE NOT EXISTS (SELECT 1 FROM PRES.Ramo WHERE PKIdRamo = PK_IdRamo);
SET IDENTITY_INSERT PRES.Ramo OFF;
GO

-- =============================================
-- 8. PRES.PG
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PG' AND schema_id = SCHEMA_ID('PRES'))
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

SET IDENTITY_INSERT PRES.PG ON;
INSERT INTO PRES.PG (PKIdPG, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdPG, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.PG
WHERE NOT EXISTS (SELECT 1 FROM PRES.PG WHERE PKIdPG = PK_IdPG);
SET IDENTITY_INSERT PRES.PG OFF;
GO

-- =============================================
-- 9. PRES.PY (Proyecto)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PY' AND schema_id = SCHEMA_ID('PRES'))
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

SET IDENTITY_INSERT PRES.PY ON;
INSERT INTO PRES.PY (
    PKIdPY, Clave, Descripcion, NombreProyecto, InicioProyecto, FinProyecto,
    Plurianual, TieneTICS, EsPAT, AnexosTransversales, ProgramaPresupuestario,
    ProyectoInversion, RecursosAdicionales, Prioridad, FuenteFinanciamiento,
    DescripcionProyecto, ResponsableProyecto, ObjetivoProyecto, LineaEstrategica,
    LineaAccionRegulatoria, TemaAccionRegulatoria, FundamentoLegal, Justificacion,
    Beneficios, Indicador, Meta, Activo, FechaCreacion, UsuarioCreacion
)
SELECT
    PK_IdPY, Clave, Descripcion, NombreProyecto, InicioProyecto, FinProyecto,
    Plurianual, TieneTICS, EsPAT, AnexosTransversales, ProgramaPresupuestario,
    ProyectoInversion, RecursosAdicionales, Prioridad, FuenteFinanciamiento,
    DescripcionProyecto, ResponsableProyecto, ObjetivoProyecto, LineaEstrategica,
    LineaAccionRegulatoria, TemaAccionRegulatoria, FundamentoLegal, Justificacion,
    Beneficios, Indicador, Meta, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.PY
WHERE NOT EXISTS (SELECT 1 FROM PRES.PY WHERE PKIdPY = PK_IdPY);
SET IDENTITY_INSERT PRES.PY OFF;
GO

-- =============================================
-- 10. PRES.FuenteFinanciamiento (se aseguran columnas adicionales)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FuenteFinanciamiento' AND schema_id = SCHEMA_ID('PRES'))
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

-- Si la tabla ya existe pero le faltan columnas, se agregan (opcional)
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'FuenteFinanciamiento' AND schema_id = SCHEMA_ID('PRES'))
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('PRES.FuenteFinanciamiento') AND name = 'FF')
        ALTER TABLE PRES.FuenteFinanciamiento ADD FF NVARCHAR(2) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('PRES.FuenteFinanciamiento') AND name = 'FG')
        ALTER TABLE PRES.FuenteFinanciamiento ADD FG NVARCHAR(1) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('PRES.FuenteFinanciamiento') AND name = 'FE')
        ALTER TABLE PRES.FuenteFinanciamiento ADD FE NVARCHAR(1) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('PRES.FuenteFinanciamiento') AND name = 'AD')
        ALTER TABLE PRES.FuenteFinanciamiento ADD AD NVARCHAR(1) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('PRES.FuenteFinanciamiento') AND name = 'ORI')
        ALTER TABLE PRES.FuenteFinanciamiento ADD ORI NVARCHAR(1) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('PRES.FuenteFinanciamiento') AND name = 'FKIdAnio_SIS')
        ALTER TABLE PRES.FuenteFinanciamiento ADD FKIdAnio_SIS INT NULL;
END
GO

SET IDENTITY_INSERT PRES.FuenteFinanciamiento ON;
INSERT INTO PRES.FuenteFinanciamiento (PKIdFuenteFinanciamiento, Clave, Descripcion, FKIdAnio_SIS, FF, FG, FE, AD, ORI, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdFuenteFinanciamiento, Clave, Descripcion, FK_IdAnio__SIS, FF, FG, FE, AD, ORI,
    ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.FuenteFinanciamiento
WHERE NOT EXISTS (SELECT 1 FROM PRES.FuenteFinanciamiento WHERE PKIdFuenteFinanciamiento = PK_IdFuenteFinanciamiento);
SET IDENTITY_INSERT PRES.FuenteFinanciamiento OFF;
GO

-- =============================================
-- 11. SIS.ActividadInstitucional
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ActividadInstitucional' AND schema_id = SCHEMA_ID('SIS'))
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

SET IDENTITY_INSERT SIS.ActividadInstitucional ON;
INSERT INTO SIS.ActividadInstitucional (PKIdActividadInstitucional, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdActividadInstitucional, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SIS.ActividadInstitucional
WHERE NOT EXISTS (SELECT 1 FROM SIS.ActividadInstitucional WHERE PKIdActividadInstitucional = PK_IdActividadInstitucional);
SET IDENTITY_INSERT SIS.ActividadInstitucional OFF;
GO

-- =============================================
-- 12. SIS.Area (se asegura existencia y se migran datos)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Area' AND schema_id = SCHEMA_ID('SIS'))
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

SET IDENTITY_INSERT SIS.Area ON;
INSERT INTO SIS.Area (PKIdArea, FKIdArea_SIS, Clave, Nombre, UltimoInv, ZonaEconomica, Direccion, Colonia, CP, Telefono, Aprovado, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdArea, FK_IdArea__SIS, Clave, Nombre, UltimoInv, ZonaEconomica, Direccion, Colonia, CP, Telefono, Aprovado,
    ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SIS.Area
WHERE NOT EXISTS (SELECT 1 FROM SIS.Area WHERE PKIdArea = PK_IdArea);
SET IDENTITY_INSERT SIS.Area OFF;
GO

PRINT 'Todas las tablas solicitadas han sido creadas y migradas exitosamente.';