USE [GestionEmpresarial];
GO

IF SCHEMA_ID('PRES') IS NULL
    EXEC('CREATE SCHEMA PRES');
GO

IF OBJECT_ID('PRES.GrupoPresupuesto', 'U') IS NULL
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
        CONSTRAINT PK_GrupoPresupuesto PRIMARY KEY (PKIdGrupoPresupuesto)
    );
END
GO

IF OBJECT_ID('PRES.UR', 'U') IS NULL
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
        CONSTRAINT PK_UR PRIMARY KEY (PKIdUR)
    );
END
GO

IF OBJECT_ID('PRES.Eje', 'U') IS NULL
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
        CONSTRAINT PK_Eje PRIMARY KEY (PKIdEje)
    );
END
GO

IF OBJECT_ID('PRES.SubEje', 'U') IS NULL
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
        CONSTRAINT PK_SubEje PRIMARY KEY (PKIdSubEje)
    );
END
GO

IF OBJECT_ID('PRES.SubSubEje', 'U') IS NULL
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
        CONSTRAINT PK_SubSubEje PRIMARY KEY (PKIdSubSubEje)
    );
END
GO

IF OBJECT_ID('PRES.Finalidad', 'U') IS NULL
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
        CONSTRAINT PK_Finalidad PRIMARY KEY (PKIdFinalidad)
    );
END
GO

IF OBJECT_ID('PRES.VertienteGasto', 'U') IS NULL
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
        CONSTRAINT PK_VertienteGasto PRIMARY KEY (PKIdVertienteGasto)
    );
END
GO

IF OBJECT_ID('PRES.Resultado', 'U') IS NULL
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
        CONSTRAINT PK_Resultado PRIMARY KEY (PKIdResultado)
    );
END
GO

IF OBJECT_ID('PRES.Subresultado', 'U') IS NULL
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
        CONSTRAINT PK_Subresultado PRIMARY KEY (PKIdSubresultado)
    );
END
GO

IF OBJECT_ID('PRES.SubSector', 'U') IS NULL
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
        CONSTRAINT PK_SubSector PRIMARY KEY (PKIdSubSector)
    );
END
GO

IF OBJECT_ID('PRES.FuenteFinanciamiento', 'U') IS NULL
BEGIN
    CREATE TABLE PRES.FuenteFinanciamiento (
        PKIdFuenteFinanciamiento INT IDENTITY(1,1) NOT NULL,
        Clave NVARCHAR(6) NULL,
        Descripcion NVARCHAR(200) NOT NULL,
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
        CONSTRAINT PK_FuenteFinanciamiento PRIMARY KEY (PKIdFuenteFinanciamiento)
    );
END
GO

IF OBJECT_ID('PRES.FuenteFinanciamiento', 'U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FuenteFinanciamiento_Anio')
        ALTER TABLE PRES.FuenteFinanciamiento DROP CONSTRAINT FK_FuenteFinanciamiento_Anio;

    IF COL_LENGTH('PRES.FuenteFinanciamiento', 'FKIdAnio_SIS') IS NOT NULL
        ALTER TABLE PRES.FuenteFinanciamiento DROP COLUMN FKIdAnio_SIS;

    IF COL_LENGTH('PRES.FuenteFinanciamiento', 'FF') IS NULL ALTER TABLE PRES.FuenteFinanciamiento ADD FF NVARCHAR(2) NULL;
    IF COL_LENGTH('PRES.FuenteFinanciamiento', 'FG') IS NULL ALTER TABLE PRES.FuenteFinanciamiento ADD FG NVARCHAR(1) NULL;
    IF COL_LENGTH('PRES.FuenteFinanciamiento', 'FE') IS NULL ALTER TABLE PRES.FuenteFinanciamiento ADD FE NVARCHAR(1) NULL;
    IF COL_LENGTH('PRES.FuenteFinanciamiento', 'AD') IS NULL ALTER TABLE PRES.FuenteFinanciamiento ADD AD NVARCHAR(1) NULL;
    IF COL_LENGTH('PRES.FuenteFinanciamiento', 'ORI') IS NULL ALTER TABLE PRES.FuenteFinanciamiento ADD ORI NVARCHAR(1) NULL;
END
GO

IF OBJECT_ID('PRES.Programa', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('PRES.Programa', 'FKIdUR_PRES') IS NULL ALTER TABLE PRES.Programa ADD FKIdUR_PRES INT NULL;
    IF COL_LENGTH('PRES.Programa', 'FKIdGF_PRES') IS NULL ALTER TABLE PRES.Programa ADD FKIdGF_PRES INT NULL;
    IF COL_LENGTH('PRES.Programa', 'FKIdFN_PRES') IS NULL ALTER TABLE PRES.Programa ADD FKIdFN_PRES INT NULL;
    IF COL_LENGTH('PRES.Programa', 'FKIdSF_PRES') IS NULL ALTER TABLE PRES.Programa ADD FKIdSF_PRES INT NULL;
    IF COL_LENGTH('PRES.Programa', 'FKIdActividadInstitucional_SIS') IS NULL ALTER TABLE PRES.Programa ADD FKIdActividadInstitucional_SIS INT NULL;
    IF COL_LENGTH('PRES.Programa', 'FKIdEje_PRES') IS NULL ALTER TABLE PRES.Programa ADD FKIdEje_PRES INT NULL;
    IF COL_LENGTH('PRES.Programa', 'FKIdVertienteGasto_PRES') IS NULL ALTER TABLE PRES.Programa ADD FKIdVertienteGasto_PRES INT NULL;
    IF COL_LENGTH('PRES.Programa', 'FKIdResultado_PRES') IS NULL ALTER TABLE PRES.Programa ADD FKIdResultado_PRES INT NULL;
    IF COL_LENGTH('PRES.Programa', 'FKIdSubresultado_PRES') IS NULL ALTER TABLE PRES.Programa ADD FKIdSubresultado_PRES INT NULL;
    IF COL_LENGTH('PRES.Programa', 'FKIdAnio_SIS') IS NULL ALTER TABLE PRES.Programa ADD FKIdAnio_SIS INT NULL;
    IF COL_LENGTH('PRES.Programa', 'FKIdSector_PRES') IS NULL ALTER TABLE PRES.Programa ADD FKIdSector_PRES INT NULL;
    IF COL_LENGTH('PRES.Programa', 'FKIdSubSector_PRES') IS NULL ALTER TABLE PRES.Programa ADD FKIdSubSector_PRES INT NULL;
    IF COL_LENGTH('PRES.Programa', 'FKIdTipoRecurso_PRES') IS NULL ALTER TABLE PRES.Programa ADD FKIdTipoRecurso_PRES INT NULL;
    IF COL_LENGTH('PRES.Programa', 'FKIdFuenteFinanciamiento_PRES') IS NULL ALTER TABLE PRES.Programa ADD FKIdFuenteFinanciamiento_PRES INT NULL;
    IF COL_LENGTH('PRES.Programa', 'Objetivo') IS NULL ALTER TABLE PRES.Programa ADD Objetivo NVARCHAR(500) NULL;
    IF COL_LENGTH('PRES.Programa', 'FKIdSubEje_PRES') IS NULL ALTER TABLE PRES.Programa ADD FKIdSubEje_PRES INT NULL;
    IF COL_LENGTH('PRES.Programa', 'FKIdSubSubEje_PRES') IS NULL ALTER TABLE PRES.Programa ADD FKIdSubSubEje_PRES INT NULL;
    IF COL_LENGTH('PRES.Programa', 'FKIdFinalidad_PRES') IS NULL ALTER TABLE PRES.Programa ADD FKIdFinalidad_PRES INT NULL;
    IF COL_LENGTH('PRES.Programa', 'FKIdPP_PRES') IS NULL ALTER TABLE PRES.Programa ADD FKIdPP_PRES INT NULL;
END
GO

IF OBJECT_ID('BD_PRESUPUESTO.PRES.GrupoPresupuesto', 'U') IS NOT NULL
BEGIN
    SET IDENTITY_INSERT PRES.GrupoPresupuesto ON;
    INSERT INTO PRES.GrupoPresupuesto (PKIdGrupoPresupuesto, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion)
    SELECT PK_IdGrupoPresupuesto, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1), CT_ModifiedDate, CT_ModifiedBy
    FROM BD_PRESUPUESTO.PRES.GrupoPresupuesto s
    WHERE NOT EXISTS (SELECT 1 FROM PRES.GrupoPresupuesto d WHERE d.PKIdGrupoPresupuesto = s.PK_IdGrupoPresupuesto);
    SET IDENTITY_INSERT PRES.GrupoPresupuesto OFF;
END
GO

IF OBJECT_ID('BD_PRESUPUESTO.PRES.UR', 'U') IS NOT NULL
BEGIN
    SET IDENTITY_INSERT PRES.UR ON;
    INSERT INTO PRES.UR (PKIdUR, FKIdGrupoPresupuesto_PRES, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion)
    SELECT PK_IdUR, FK_IdGrupoPresupuesto__PRES, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1), CT_ModifiedDate, CT_ModifiedBy
    FROM BD_PRESUPUESTO.PRES.UR s
    WHERE NOT EXISTS (SELECT 1 FROM PRES.UR d WHERE d.PKIdUR = s.PK_IdUR);
    SET IDENTITY_INSERT PRES.UR OFF;
END
GO

IF OBJECT_ID('BD_PRESUPUESTO.PRES.Eje', 'U') IS NOT NULL
BEGIN
    SET IDENTITY_INSERT PRES.Eje ON;
    INSERT INTO PRES.Eje (PKIdEje, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion)
    SELECT PK_IdEje, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1), CT_ModifiedDate, CT_ModifiedBy
    FROM BD_PRESUPUESTO.PRES.Eje s
    WHERE NOT EXISTS (SELECT 1 FROM PRES.Eje d WHERE d.PKIdEje = s.PK_IdEje);
    SET IDENTITY_INSERT PRES.Eje OFF;
END
GO

IF OBJECT_ID('BD_PRESUPUESTO.PRES.SubEje', 'U') IS NOT NULL
BEGIN
    SET IDENTITY_INSERT PRES.SubEje ON;
    INSERT INTO PRES.SubEje (PKIdSubEje, FKIdEje_PRES, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion)
    SELECT PK_IdSubEje, FK_IdEje, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1), CT_ModifiedDate, CT_ModifiedBy
    FROM BD_PRESUPUESTO.PRES.SubEje s
    WHERE NOT EXISTS (SELECT 1 FROM PRES.SubEje d WHERE d.PKIdSubEje = s.PK_IdSubEje);
    SET IDENTITY_INSERT PRES.SubEje OFF;
END
GO

IF OBJECT_ID('BD_PRESUPUESTO.PRES.SubSubEje', 'U') IS NOT NULL
BEGIN
    SET IDENTITY_INSERT PRES.SubSubEje ON;
    INSERT INTO PRES.SubSubEje (PKIdSubSubEje, FKIdSubEje_PRES, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion)
    SELECT PK_IdSubSubEje, FK_IdSubEje, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1), CT_ModifiedDate, CT_ModifiedBy
    FROM BD_PRESUPUESTO.PRES.SubSubEje s
    WHERE NOT EXISTS (SELECT 1 FROM PRES.SubSubEje d WHERE d.PKIdSubSubEje = s.PK_IdSubSubEje);
    SET IDENTITY_INSERT PRES.SubSubEje OFF;
END
GO

IF OBJECT_ID('BD_PRESUPUESTO.PRES.Finalidad', 'U') IS NOT NULL
BEGIN
    SET IDENTITY_INSERT PRES.Finalidad ON;
    INSERT INTO PRES.Finalidad (PKIdFinalidad, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion)
    SELECT PK_IdFinalidad, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1), CT_ModifiedDate, CT_ModifiedBy
    FROM BD_PRESUPUESTO.PRES.Finalidad s
    WHERE NOT EXISTS (SELECT 1 FROM PRES.Finalidad d WHERE d.PKIdFinalidad = s.PK_IdFinalidad);
    SET IDENTITY_INSERT PRES.Finalidad OFF;
END
GO

IF OBJECT_ID('BD_PRESUPUESTO.PRES.VertienteGasto', 'U') IS NOT NULL
BEGIN
    SET IDENTITY_INSERT PRES.VertienteGasto ON;
    INSERT INTO PRES.VertienteGasto (PKIdVertienteGasto, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion)
    SELECT PK_IdVertienteGasto, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1), CT_ModifiedDate, CT_ModifiedBy
    FROM BD_PRESUPUESTO.PRES.VertienteGasto s
    WHERE NOT EXISTS (SELECT 1 FROM PRES.VertienteGasto d WHERE d.PKIdVertienteGasto = s.PK_IdVertienteGasto);
    SET IDENTITY_INSERT PRES.VertienteGasto OFF;
END
GO

IF OBJECT_ID('BD_PRESUPUESTO.PRES.Resultado', 'U') IS NOT NULL
BEGIN
    SET IDENTITY_INSERT PRES.Resultado ON;
    INSERT INTO PRES.Resultado (PKIdResultado, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion)
    SELECT PK_IdResultado, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1), CT_ModifiedDate, CT_ModifiedBy
    FROM BD_PRESUPUESTO.PRES.Resultado s
    WHERE NOT EXISTS (SELECT 1 FROM PRES.Resultado d WHERE d.PKIdResultado = s.PK_IdResultado);
    SET IDENTITY_INSERT PRES.Resultado OFF;
END
GO

IF OBJECT_ID('BD_PRESUPUESTO.PRES.Subresultado', 'U') IS NOT NULL
BEGIN
    SET IDENTITY_INSERT PRES.Subresultado ON;
    INSERT INTO PRES.Subresultado (PKIdSubresultado, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion)
    SELECT PK_IdSubresultado, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1), CT_ModifiedDate, CT_ModifiedBy
    FROM BD_PRESUPUESTO.PRES.Subresultado s
    WHERE NOT EXISTS (SELECT 1 FROM PRES.Subresultado d WHERE d.PKIdSubresultado = s.PK_IdSubresultado);
    SET IDENTITY_INSERT PRES.Subresultado OFF;
END
GO

IF OBJECT_ID('BD_PRESUPUESTO.PRES.SubSector', 'U') IS NOT NULL
BEGIN
    SET IDENTITY_INSERT PRES.SubSector ON;
    INSERT INTO PRES.SubSector (PKIdSubSector, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion)
    SELECT PK_IdSubSector, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1), CT_ModifiedDate, CT_ModifiedBy
    FROM BD_PRESUPUESTO.PRES.SubSector s
    WHERE NOT EXISTS (SELECT 1 FROM PRES.SubSector d WHERE d.PKIdSubSector = s.PK_IdSubSector);
    SET IDENTITY_INSERT PRES.SubSector OFF;
END
GO

IF OBJECT_ID('BD_PRESUPUESTO.PRES.FuenteFinanciamiento', 'U') IS NOT NULL
BEGIN
    SET IDENTITY_INSERT PRES.FuenteFinanciamiento ON;
    INSERT INTO PRES.FuenteFinanciamiento (
        PKIdFuenteFinanciamiento, Clave, Descripcion,
        FF, FG, FE, AD, ORI, Activo, FechaCreacion, UsuarioCreacion,
        FechaModificacion, UsuarioModificacion
    )
    SELECT
        PK_IdFuenteFinanciamiento, Clave, Descripcion,
        FF, FG, FE, AD, ORI, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1),
        CT_ModifiedDate, CT_ModifiedBy
    FROM BD_PRESUPUESTO.PRES.FuenteFinanciamiento s
    WHERE NOT EXISTS (SELECT 1 FROM PRES.FuenteFinanciamiento d WHERE d.PKIdFuenteFinanciamiento = s.PK_IdFuenteFinanciamiento);
    SET IDENTITY_INSERT PRES.FuenteFinanciamiento OFF;

    UPDATE d
    SET
        d.Clave = s.Clave,
        d.Descripcion = s.Descripcion,
        d.FF = s.FF,
        d.FG = s.FG,
        d.FE = s.FE,
        d.AD = s.AD,
        d.ORI = s.ORI
    FROM PRES.FuenteFinanciamiento d
    INNER JOIN BD_PRESUPUESTO.PRES.FuenteFinanciamiento s ON s.PK_IdFuenteFinanciamiento = d.PKIdFuenteFinanciamiento;
END
GO

IF OBJECT_ID('BD_PRESUPUESTO.PRES.Programa', 'U') IS NOT NULL
BEGIN
    UPDATE d
    SET
        d.FKIdUR_PRES = p.FK_IdUR__PRES,
        d.FKIdGF_PRES = p.FK_IdGF__PRES,
        d.FKIdFN_PRES = p.FK_IdFN__PRES,
        d.FKIdSF_PRES = p.FK_IdSF__PRES,
        d.FKIdActividadInstitucional_SIS = p.FK_IdActividadInstitucional__SIS,
        d.FKIdEje_PRES = p.FK_IdEje__PRES,
        d.FKIdVertienteGasto_PRES = p.FK_IdVertienteGasto__PRES,
        d.FKIdResultado_PRES = p.FK_IdResultado__PRES,
        d.FKIdSubresultado_PRES = p.FK_IdSubresultado__PRES,
        d.FKIdAnio_SIS = p.FK_IdAnio__SIS,
        d.FKIdSector_PRES = p.FK_IdSector__PRES,
        d.FKIdSubSector_PRES = p.FK_IdSubSector__PRES,
        d.FKIdTipoRecurso_PRES = p.FK_IdTipoRecurso__PRES,
        d.FKIdFuenteFinanciamiento_PRES = p.FK_IdFuenteFinanciamiento__PRES,
        d.Objetivo = p.Objetivo,
        d.FKIdSubEje_PRES = p.FK_IdSubEje_PRES,
        d.FKIdSubSubEje_PRES = p.FK_IdSubSubEje_PRES,
        d.FKIdFinalidad_PRES = p.FK_IdFinalidad_PRES,
        d.FKIdPP_PRES = p.FK_IdPP__PRES
    FROM PRES.Programa d
    INNER JOIN BD_PRESUPUESTO.PRES.Programa p ON p.PK_IdPrograma = d.PKIdPrograma;
END
GO
