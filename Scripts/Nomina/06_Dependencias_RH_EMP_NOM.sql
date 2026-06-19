-- Segunda migracion funcional de dependencias RH/EMP hacia NOM.
-- Preserva los IDs del sistema origen para que los tabuladores existentes sigan enlazando.
-- Ejecutar despues de 01_Estructura_NOM.sql, 02_Datos_NOM_Migracion.sql y 04_Vistas_NOM.sql.

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'NOM')
    EXEC(N'CREATE SCHEMA [NOM]');
GO

IF OBJECT_ID(N'[NOM].[EmpresaNomina]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[EmpresaNomina] (
        [PKIdEmpresaNomina] int IDENTITY(1,1) NOT NULL,
        [RazonSocial] nvarchar(100) NOT NULL,
        [RegIMSS] nvarchar(25) NULL,
        [RegInfonavit] nvarchar(25) NULL,
        [CedEmpadronam] nvarchar(25) NULL,
        [NoFonacot] nvarchar(25) NULL,
        [UsAdmin] nvarchar(100) NULL,
        [EmailAdmin] nvarchar(100) NULL,
        [FKIdPeriodoPago_SIS] int NULL,
        [PrimaRiesgoIMSS] decimal(18,4) NULL,
        [UsaSueldoTabular] bit NOT NULL CONSTRAINT [DF_NOM_EmpresaNomina_UsaSueldoTabular] DEFAULT 0,
        [FKIdTipoPago_NOM] int NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_NOM_EmpresaNomina_Activo] DEFAULT 1,
        CONSTRAINT [PK_NOM_EmpresaNomina] PRIMARY KEY ([PKIdEmpresaNomina])
    );
END
GO

IF OBJECT_ID(N'[NOM].[Universo]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[Universo] (
        [PKIdUniverso] int IDENTITY(1,1) NOT NULL,
        [Descripcion] nvarchar(2) NOT NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_NOM_Universo_Activo] DEFAULT 1,
        CONSTRAINT [PK_NOM_Universo] PRIMARY KEY ([PKIdUniverso])
    );
END
GO

IF OBJECT_ID(N'[NOM].[Nivel]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[Nivel] (
        [PKIdNivel] int IDENTITY(1,1) NOT NULL,
        [Clave] nvarchar(5) NOT NULL,
        [FKIdUniverso_NOM] int NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_NOM_Nivel_Activo] DEFAULT 1,
        CONSTRAINT [PK_NOM_Nivel] PRIMARY KEY ([PKIdNivel])
    );
END
GO

IF OBJECT_ID(N'[NOM].[ClasePuesto]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[ClasePuesto] (
        [PKIdClasePuesto] int IDENTITY(1,1) NOT NULL,
        [Descripcion] nvarchar(64) NOT NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_NOM_ClasePuesto_Activo] DEFAULT 1,
        CONSTRAINT [PK_NOM_ClasePuesto] PRIMARY KEY ([PKIdClasePuesto])
    );
END
GO

IF OBJECT_ID(N'[NOM].[Puesto]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[Puesto] (
        [PKIdPuesto] int IDENTITY(1,1) NOT NULL,
        [FKIdPuestoPadre_NOM] int NULL,
        [FKIdEmpresaNomina_NOM] int NOT NULL,
        [Nombre] nvarchar(150) NULL,
        [FKIdNivel_NOM] int NULL,
        [FKIdClasePuesto_NOM] int NULL,
        [Descripcion1] nvarchar(150) NULL,
        [Descripcion2] nvarchar(150) NULL,
        [Orden] int NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_NOM_Puesto_Activo] DEFAULT 1,
        CONSTRAINT [PK_NOM_Puesto] PRIMARY KEY ([PKIdPuesto])
    );
END
GO

IF OBJECT_ID(N'[NOM].[Nombramiento]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[Nombramiento] (
        [PKIdNombramiento] int IDENTITY(1,1) NOT NULL,
        [Descripcion] nvarchar(80) NOT NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_NOM_Nombramiento_Activo] DEFAULT 1,
        CONSTRAINT [PK_NOM_Nombramiento] PRIMARY KEY ([PKIdNombramiento])
    );
END
GO

IF OBJECT_ID(N'[NOM].[ImporteNivel]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[ImporteNivel] (
        [PKIdImporteNivel] int IDENTITY(1,1) NOT NULL,
        [Clave] nvarchar(5) NOT NULL,
        [ImpSDI] decimal(18,2) NOT NULL,
        [ImpImss15] decimal(18,2) NOT NULL,
        [ImpImss16] decimal(18,2) NOT NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_NOM_ImporteNivel_Activo] DEFAULT 1,
        CONSTRAINT [PK_NOM_ImporteNivel] PRIMARY KEY ([PKIdImporteNivel])
    );
END
GO

IF OBJECT_ID(N'[NOM].[ContratoLaboral]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[ContratoLaboral] (
        [PKIdContratoLaboral] int IDENTITY(1,1) NOT NULL,
        [FKIdEmpresaNomina_NOM] int NOT NULL,
        [FKIdPersona_NOM] int NOT NULL,
        [FechaInicio] date NOT NULL,
        [FechaFin] date NOT NULL,
        [FKIdPuesto_NOM] int NOT NULL,
        [NumeroContrato] nvarchar(20) NOT NULL,
        [Vigencia] nvarchar(100) NULL,
        [SueldoMensual] decimal(18,2) NOT NULL CONSTRAINT [DF_NOM_ContratoLaboral_SueldoMensual] DEFAULT 0,
        [FKIdNombramiento_NOM] int NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_NOM_ContratoLaboral_Activo] DEFAULT 1,
        CONSTRAINT [PK_NOM_ContratoLaboral] PRIMARY KEY ([PKIdContratoLaboral])
    );
END
GO

IF DB_ID(N'BD_GRP_INVEA') IS NOT NULL
BEGIN
    SET IDENTITY_INSERT [NOM].[EmpresaNomina] ON;
    MERGE [NOM].[EmpresaNomina] AS target
    USING (
        SELECT
            [Pk_IdEmpresa],
            COALESCE(NULLIF(LTRIM(RTRIM([RazonSocial])), N''), CONCAT(N'Empresa nomina ', [Pk_IdEmpresa])) AS [RazonSocial],
            NULLIF(LTRIM(RTRIM([RegIMSS])), N'') AS [RegIMSS],
            NULLIF(LTRIM(RTRIM([RegInfonavit])), N'') AS [RegInfonavit],
            NULLIF(LTRIM(RTRIM([CedEmpadronam])), N'') AS [CedEmpadronam],
            NULLIF(LTRIM(RTRIM([NoFonacot])), N'') AS [NoFonacot],
            NULLIF(LTRIM(RTRIM([UsAdmin])), N'') AS [UsAdmin],
            NULLIF(LTRIM(RTRIM([EMailAdmin])), N'') AS [EmailAdmin],
            [Fk_IdPeriodoPago__SIS],
            TRY_CONVERT(decimal(18,4), [PrimaRiesgoIMSS]) AS [PrimaRiesgoIMSS],
            CONVERT(bit, COALESCE([UsaSueldoTabular], 0)) AS [UsaSueldoTabular],
            [Fk_IdTipoPago__NOM],
            [CT_CreatedBy],
            [CT_CreatedDate],
            [CT_ModifiedBy],
            [CT_ModifiedDate],
            CONVERT(bit, CASE WHEN COALESCE([CT_LIVE], 1) <> 0 THEN 1 ELSE 0 END) AS [Activo]
        FROM [BD_GRP_INVEA].[dbo].[EMP_Empresa]
    ) AS source
    ON target.[PKIdEmpresaNomina] = source.[Pk_IdEmpresa]
    WHEN MATCHED THEN UPDATE SET
        [RazonSocial] = source.[RazonSocial],
        [RegIMSS] = source.[RegIMSS],
        [RegInfonavit] = source.[RegInfonavit],
        [CedEmpadronam] = source.[CedEmpadronam],
        [NoFonacot] = source.[NoFonacot],
        [UsAdmin] = source.[UsAdmin],
        [EmailAdmin] = source.[EmailAdmin],
        [FKIdPeriodoPago_SIS] = source.[Fk_IdPeriodoPago__SIS],
        [PrimaRiesgoIMSS] = source.[PrimaRiesgoIMSS],
        [UsaSueldoTabular] = source.[UsaSueldoTabular],
        [FKIdTipoPago_NOM] = source.[Fk_IdTipoPago__NOM],
        [UsuarioCreacion] = source.[CT_CreatedBy],
        [FechaCreacion] = source.[CT_CreatedDate],
        [UsuarioModificacion] = source.[CT_ModifiedBy],
        [FechaModificacion] = source.[CT_ModifiedDate],
        [Activo] = source.[Activo]
    WHEN NOT MATCHED THEN INSERT
        ([PKIdEmpresaNomina], [RazonSocial], [RegIMSS], [RegInfonavit], [CedEmpadronam], [NoFonacot], [UsAdmin], [EmailAdmin], [FKIdPeriodoPago_SIS], [PrimaRiesgoIMSS], [UsaSueldoTabular], [FKIdTipoPago_NOM], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
        VALUES (source.[Pk_IdEmpresa], source.[RazonSocial], source.[RegIMSS], source.[RegInfonavit], source.[CedEmpadronam], source.[NoFonacot], source.[UsAdmin], source.[EmailAdmin], source.[Fk_IdPeriodoPago__SIS], source.[PrimaRiesgoIMSS], source.[UsaSueldoTabular], source.[Fk_IdTipoPago__NOM], source.[CT_CreatedBy], source.[CT_CreatedDate], source.[CT_ModifiedBy], source.[CT_ModifiedDate], source.[Activo]);
    SET IDENTITY_INSERT [NOM].[EmpresaNomina] OFF;

    SET IDENTITY_INSERT [NOM].[Universo] ON;
    MERGE [NOM].[Universo] AS target
    USING (
        SELECT [Pk_IdUniverso], [Descripcion], [CT_CreatedBy], [CT_CreatedDate], [CT_ModifiedBy], [CT_ModifiedDate],
               CONVERT(bit, CASE WHEN COALESCE([CT_LIVE], 1) <> 0 THEN 1 ELSE 0 END) AS [Activo]
        FROM [BD_GRP_INVEA].[dbo].[RH_Universo]
    ) AS source
    ON target.[PKIdUniverso] = source.[Pk_IdUniverso]
    WHEN MATCHED THEN UPDATE SET
        [Descripcion] = source.[Descripcion],
        [UsuarioCreacion] = source.[CT_CreatedBy],
        [FechaCreacion] = source.[CT_CreatedDate],
        [UsuarioModificacion] = source.[CT_ModifiedBy],
        [FechaModificacion] = source.[CT_ModifiedDate],
        [Activo] = source.[Activo]
    WHEN NOT MATCHED THEN INSERT
        ([PKIdUniverso], [Descripcion], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
        VALUES (source.[Pk_IdUniverso], source.[Descripcion], source.[CT_CreatedBy], source.[CT_CreatedDate], source.[CT_ModifiedBy], source.[CT_ModifiedDate], source.[Activo]);
    SET IDENTITY_INSERT [NOM].[Universo] OFF;

    SET IDENTITY_INSERT [NOM].[Nivel] ON;
    MERGE [NOM].[Nivel] AS target
    USING (
        SELECT [Pk_IdNivel], [Clave], [Fk_IdUniverso__RH], [CT_CreatedBy], [CT_CreatedDate], [CT_ModifiedBy], [CT_ModifiedDate],
               CONVERT(bit, CASE WHEN COALESCE([CT_LIVE], 1) <> 0 THEN 1 ELSE 0 END) AS [Activo]
        FROM [BD_GRP_INVEA].[dbo].[RH_Nivel]
    ) AS source
    ON target.[PKIdNivel] = source.[Pk_IdNivel]
    WHEN MATCHED THEN UPDATE SET
        [Clave] = source.[Clave],
        [FKIdUniverso_NOM] = source.[Fk_IdUniverso__RH],
        [UsuarioCreacion] = source.[CT_CreatedBy],
        [FechaCreacion] = source.[CT_CreatedDate],
        [UsuarioModificacion] = source.[CT_ModifiedBy],
        [FechaModificacion] = source.[CT_ModifiedDate],
        [Activo] = source.[Activo]
    WHEN NOT MATCHED THEN INSERT
        ([PKIdNivel], [Clave], [FKIdUniverso_NOM], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
        VALUES (source.[Pk_IdNivel], source.[Clave], source.[Fk_IdUniverso__RH], source.[CT_CreatedBy], source.[CT_CreatedDate], source.[CT_ModifiedBy], source.[CT_ModifiedDate], source.[Activo]);
    SET IDENTITY_INSERT [NOM].[Nivel] OFF;

    SET IDENTITY_INSERT [NOM].[ClasePuesto] ON;
    MERGE [NOM].[ClasePuesto] AS target
    USING (
        SELECT [Pk_IdClasePuesto], [Descripcion], [CT_CreatedBy], [CT_CreatedDate], [CT_ModifiedBy], [CT_ModifiedDate],
               CONVERT(bit, CASE WHEN COALESCE([CT_LIVE], 1) <> 0 THEN 1 ELSE 0 END) AS [Activo]
        FROM [BD_GRP_INVEA].[dbo].[RH_ClasePuesto]
    ) AS source
    ON target.[PKIdClasePuesto] = source.[Pk_IdClasePuesto]
    WHEN MATCHED THEN UPDATE SET
        [Descripcion] = source.[Descripcion],
        [UsuarioCreacion] = source.[CT_CreatedBy],
        [FechaCreacion] = source.[CT_CreatedDate],
        [UsuarioModificacion] = source.[CT_ModifiedBy],
        [FechaModificacion] = source.[CT_ModifiedDate],
        [Activo] = source.[Activo]
    WHEN NOT MATCHED THEN INSERT
        ([PKIdClasePuesto], [Descripcion], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
        VALUES (source.[Pk_IdClasePuesto], source.[Descripcion], source.[CT_CreatedBy], source.[CT_CreatedDate], source.[CT_ModifiedBy], source.[CT_ModifiedDate], source.[Activo]);
    SET IDENTITY_INSERT [NOM].[ClasePuesto] OFF;

    SET IDENTITY_INSERT [NOM].[Puesto] ON;
    MERGE [NOM].[Puesto] AS target
    USING (
        SELECT
            [Pk_IdPuesto],
            [Fk_IdPuesto__EMP],
            [Fk_IdEmpresa__EMP],
            NULLIF(LTRIM(RTRIM([Nombre])), N'') AS [Nombre],
            [Fk_IdNivel__RH],
            [Fk_IdClasePuesto__RH],
            NULLIF(LTRIM(RTRIM([Descripcion1])), N'') AS [Descripcion1],
            NULLIF(LTRIM(RTRIM([Descripcion2])), N'') AS [Descripcion2],
            [Orden],
            [CT_CreatedBy],
            [CT_CreatedDate],
            [CT_ModifiedBy],
            [CT_ModifiedDate],
            CONVERT(bit, CASE WHEN COALESCE([CT_LIVE], 1) <> 0 THEN 1 ELSE 0 END) AS [Activo]
        FROM [BD_GRP_INVEA].[dbo].[EMP_Puesto]
    ) AS source
    ON target.[PKIdPuesto] = source.[Pk_IdPuesto]
    WHEN MATCHED THEN UPDATE SET
        [FKIdPuestoPadre_NOM] = source.[Fk_IdPuesto__EMP],
        [FKIdEmpresaNomina_NOM] = source.[Fk_IdEmpresa__EMP],
        [Nombre] = source.[Nombre],
        [FKIdNivel_NOM] = source.[Fk_IdNivel__RH],
        [FKIdClasePuesto_NOM] = source.[Fk_IdClasePuesto__RH],
        [Descripcion1] = source.[Descripcion1],
        [Descripcion2] = source.[Descripcion2],
        [Orden] = source.[Orden],
        [UsuarioCreacion] = source.[CT_CreatedBy],
        [FechaCreacion] = source.[CT_CreatedDate],
        [UsuarioModificacion] = source.[CT_ModifiedBy],
        [FechaModificacion] = source.[CT_ModifiedDate],
        [Activo] = source.[Activo]
    WHEN NOT MATCHED THEN INSERT
        ([PKIdPuesto], [FKIdPuestoPadre_NOM], [FKIdEmpresaNomina_NOM], [Nombre], [FKIdNivel_NOM], [FKIdClasePuesto_NOM], [Descripcion1], [Descripcion2], [Orden], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
        VALUES (source.[Pk_IdPuesto], source.[Fk_IdPuesto__EMP], source.[Fk_IdEmpresa__EMP], source.[Nombre], source.[Fk_IdNivel__RH], source.[Fk_IdClasePuesto__RH], source.[Descripcion1], source.[Descripcion2], source.[Orden], source.[CT_CreatedBy], source.[CT_CreatedDate], source.[CT_ModifiedBy], source.[CT_ModifiedDate], source.[Activo]);
    SET IDENTITY_INSERT [NOM].[Puesto] OFF;

    SET IDENTITY_INSERT [NOM].[Nombramiento] ON;
    MERGE [NOM].[Nombramiento] AS target
    USING (
        SELECT [Pk_IdNombramiento], [Descripcion], [CT_CreatedBy], [CT_CreatedDate], [CT_ModifiedBy], [CT_ModifiedDate],
               CONVERT(bit, CASE WHEN COALESCE([CT_LIVE], 1) <> 0 THEN 1 ELSE 0 END) AS [Activo]
        FROM [BD_GRP_INVEA].[dbo].[RH_Nombramiento]
    ) AS source
    ON target.[PKIdNombramiento] = source.[Pk_IdNombramiento]
    WHEN MATCHED THEN UPDATE SET
        [Descripcion] = source.[Descripcion],
        [UsuarioCreacion] = source.[CT_CreatedBy],
        [FechaCreacion] = source.[CT_CreatedDate],
        [UsuarioModificacion] = source.[CT_ModifiedBy],
        [FechaModificacion] = source.[CT_ModifiedDate],
        [Activo] = source.[Activo]
    WHEN NOT MATCHED THEN INSERT
        ([PKIdNombramiento], [Descripcion], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
        VALUES (source.[Pk_IdNombramiento], source.[Descripcion], source.[CT_CreatedBy], source.[CT_CreatedDate], source.[CT_ModifiedBy], source.[CT_ModifiedDate], source.[Activo]);
    SET IDENTITY_INSERT [NOM].[Nombramiento] OFF;

    SET IDENTITY_INSERT [NOM].[ImporteNivel] ON;
    MERGE [NOM].[ImporteNivel] AS target
    USING (
        SELECT [Pk_IdImpNivel], [Clave], [ImpSDI], [ImpImss15], [ImpImss16], [CT_CreatedBy], [CT_CreatedDate], [CT_ModifiedBy], [CT_ModifiedDate],
               CONVERT(bit, CASE WHEN COALESCE([CT_LIVE], 1) <> 0 THEN 1 ELSE 0 END) AS [Activo]
        FROM [BD_GRP_INVEA].[dbo].[RH_ImporteNivel]
    ) AS source
    ON target.[PKIdImporteNivel] = source.[Pk_IdImpNivel]
    WHEN MATCHED THEN UPDATE SET
        [Clave] = source.[Clave],
        [ImpSDI] = source.[ImpSDI],
        [ImpImss15] = source.[ImpImss15],
        [ImpImss16] = source.[ImpImss16],
        [UsuarioCreacion] = source.[CT_CreatedBy],
        [FechaCreacion] = source.[CT_CreatedDate],
        [UsuarioModificacion] = source.[CT_ModifiedBy],
        [FechaModificacion] = source.[CT_ModifiedDate],
        [Activo] = source.[Activo]
    WHEN NOT MATCHED THEN INSERT
        ([PKIdImporteNivel], [Clave], [ImpSDI], [ImpImss15], [ImpImss16], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
        VALUES (source.[Pk_IdImpNivel], source.[Clave], source.[ImpSDI], source.[ImpImss15], source.[ImpImss16], source.[CT_CreatedBy], source.[CT_CreatedDate], source.[CT_ModifiedBy], source.[CT_ModifiedDate], source.[Activo]);
    SET IDENTITY_INSERT [NOM].[ImporteNivel] OFF;

    SET IDENTITY_INSERT [NOM].[ContratoLaboral] ON;
    MERGE [NOM].[ContratoLaboral] AS target
    USING (
        SELECT
            [Pk_IdContrato],
            [Fk_IdEmpresa__EMP],
            [Fk_IdPersona__RH],
            [F_Inicio],
            [F_Fin],
            [Fk_IdPuesto__EMP],
            [NumeroContrato],
            NULLIF(LTRIM(RTRIM([Vigencia])), N'') AS [Vigencia],
            CONVERT(decimal(18,2), COALESCE([SueldoMensual], 0)) AS [SueldoMensual],
            [Fk_IdNombramiento__RH],
            [CT_CreatedBy],
            [CT_CreatedDate],
            [CT_ModifiedBy],
            [CT_ModifiedDate],
            CONVERT(bit, CASE WHEN COALESCE([CT_LIVE], 1) <> 0 THEN 1 ELSE 0 END) AS [Activo]
        FROM [BD_GRP_INVEA].[dbo].[RH_Contrato]
    ) AS source
    ON target.[PKIdContratoLaboral] = source.[Pk_IdContrato]
    WHEN MATCHED THEN UPDATE SET
        [FKIdEmpresaNomina_NOM] = source.[Fk_IdEmpresa__EMP],
        [FKIdPersona_NOM] = source.[Fk_IdPersona__RH],
        [FechaInicio] = source.[F_Inicio],
        [FechaFin] = source.[F_Fin],
        [FKIdPuesto_NOM] = source.[Fk_IdPuesto__EMP],
        [NumeroContrato] = source.[NumeroContrato],
        [Vigencia] = source.[Vigencia],
        [SueldoMensual] = source.[SueldoMensual],
        [FKIdNombramiento_NOM] = source.[Fk_IdNombramiento__RH],
        [UsuarioCreacion] = source.[CT_CreatedBy],
        [FechaCreacion] = source.[CT_CreatedDate],
        [UsuarioModificacion] = source.[CT_ModifiedBy],
        [FechaModificacion] = source.[CT_ModifiedDate],
        [Activo] = source.[Activo]
    WHEN NOT MATCHED THEN INSERT
        ([PKIdContratoLaboral], [FKIdEmpresaNomina_NOM], [FKIdPersona_NOM], [FechaInicio], [FechaFin], [FKIdPuesto_NOM], [NumeroContrato], [Vigencia], [SueldoMensual], [FKIdNombramiento_NOM], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
        VALUES (source.[Pk_IdContrato], source.[Fk_IdEmpresa__EMP], source.[Fk_IdPersona__RH], source.[F_Inicio], source.[F_Fin], source.[Fk_IdPuesto__EMP], source.[NumeroContrato], source.[Vigencia], source.[SueldoMensual], source.[Fk_IdNombramiento__RH], source.[CT_CreatedBy], source.[CT_CreatedDate], source.[CT_ModifiedBy], source.[CT_ModifiedDate], source.[Activo]);
    SET IDENTITY_INSERT [NOM].[ContratoLaboral] OFF;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_NOM_Puesto_EmpresaNivel' AND object_id = OBJECT_ID(N'[NOM].[Puesto]'))
    CREATE INDEX [IX_NOM_Puesto_EmpresaNivel] ON [NOM].[Puesto] ([FKIdEmpresaNomina_NOM], [FKIdNivel_NOM], [Activo]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_NOM_ConceptoTabular_PuestoConcepto' AND object_id = OBJECT_ID(N'[NOM].[ConceptoTabular]'))
    CREATE INDEX [IX_NOM_ConceptoTabular_PuestoConcepto] ON [NOM].[ConceptoTabular] ([FKIdPuesto_NOM], [FKIdConcepto_NOM], [Activo]);
GO

CREATE OR ALTER VIEW [NOM].[Vw_EmpresaNomina]
AS
SELECT
    e.[PKIdEmpresaNomina],
    e.[RazonSocial],
    e.[RegIMSS],
    e.[RegInfonavit],
    e.[CedEmpadronam],
    e.[NoFonacot],
    e.[UsAdmin],
    e.[EmailAdmin],
    e.[FKIdPeriodoPago_SIS] AS [PeriodoPagoId],
    e.[PrimaRiesgoIMSS],
    e.[UsaSueldoTabular],
    e.[FKIdTipoPago_NOM] AS [TipoPagoId],
    CONCAT(e.[PKIdEmpresaNomina], N' - ', e.[RazonSocial]) AS [ClaveNombre],
    e.[Activo],
    e.[UsuarioCreacion],
    e.[FechaCreacion],
    e.[UsuarioModificacion],
    e.[FechaModificacion]
FROM [NOM].[EmpresaNomina] e;
GO

CREATE OR ALTER VIEW [NOM].[Vw_Universo]
AS
SELECT
    u.[PKIdUniverso],
    u.[Descripcion],
    CONCAT(u.[PKIdUniverso], N' - ', u.[Descripcion]) AS [ClaveNombre],
    u.[Activo],
    u.[UsuarioCreacion],
    u.[FechaCreacion],
    u.[UsuarioModificacion],
    u.[FechaModificacion]
FROM [NOM].[Universo] u;
GO

CREATE OR ALTER VIEW [NOM].[Vw_Nivel]
AS
SELECT
    n.[PKIdNivel],
    n.[Clave],
    n.[FKIdUniverso_NOM] AS [UniversoId],
    u.[Descripcion] AS [UniversoDescripcion],
    COALESCE(i.[ImpSDI], CONVERT(decimal(18,2), 0)) AS [ImpSDI],
    COALESCE(i.[ImpImss15], CONVERT(decimal(18,2), 0)) AS [ImpImss15],
    COALESCE(i.[ImpImss16], CONVERT(decimal(18,2), 0)) AS [ImpImss16],
    CONCAT(n.[Clave], N' - Universo ', COALESCE(u.[Descripcion], N'')) AS [ClaveNombre],
    n.[Activo],
    n.[UsuarioCreacion],
    n.[FechaCreacion],
    n.[UsuarioModificacion],
    n.[FechaModificacion]
FROM [NOM].[Nivel] n
LEFT JOIN [NOM].[Universo] u ON u.[PKIdUniverso] = n.[FKIdUniverso_NOM]
LEFT JOIN [NOM].[ImporteNivel] i ON i.[Clave] = n.[Clave] AND i.[Activo] = 1;
GO

CREATE OR ALTER VIEW [NOM].[Vw_ClasePuesto]
AS
SELECT
    c.[PKIdClasePuesto],
    c.[Descripcion],
    CONCAT(c.[PKIdClasePuesto], N' - ', c.[Descripcion]) AS [ClaveNombre],
    c.[Activo],
    c.[UsuarioCreacion],
    c.[FechaCreacion],
    c.[UsuarioModificacion],
    c.[FechaModificacion]
FROM [NOM].[ClasePuesto] c;
GO

CREATE OR ALTER VIEW [NOM].[Vw_Puesto]
AS
SELECT
    p.[PKIdPuesto],
    p.[FKIdPuestoPadre_NOM] AS [PuestoPadreId],
    pp.[Nombre] AS [PuestoPadreNombre],
    p.[FKIdEmpresaNomina_NOM] AS [EmpresaNominaId],
    en.[RazonSocial] AS [EmpresaNominaNombre],
    p.[Nombre],
    p.[FKIdNivel_NOM] AS [NivelId],
    n.[Clave] AS [NivelClave],
    n.[FKIdUniverso_NOM] AS [UniversoId],
    u.[Descripcion] AS [UniversoDescripcion],
    p.[FKIdClasePuesto_NOM] AS [ClasePuestoId],
    cp.[Descripcion] AS [ClasePuestoDescripcion],
    COALESCE(i.[ImpSDI], CONVERT(decimal(18,2), 0)) AS [ImpSDI],
    COALESCE(i.[ImpImss15], CONVERT(decimal(18,2), 0)) AS [ImpImss15],
    COALESCE(i.[ImpImss16], CONVERT(decimal(18,2), 0)) AS [ImpImss16],
    p.[Descripcion1],
    p.[Descripcion2],
    p.[Orden],
    CONCAT(p.[PKIdPuesto], N' - ', COALESCE(p.[Nombre], N''), N' - Nivel ', COALESCE(n.[Clave], N'')) AS [ClaveNombre],
    p.[Activo],
    p.[UsuarioCreacion],
    p.[FechaCreacion],
    p.[UsuarioModificacion],
    p.[FechaModificacion]
FROM [NOM].[Puesto] p
LEFT JOIN [NOM].[Puesto] pp ON pp.[PKIdPuesto] = p.[FKIdPuestoPadre_NOM]
LEFT JOIN [NOM].[EmpresaNomina] en ON en.[PKIdEmpresaNomina] = p.[FKIdEmpresaNomina_NOM]
LEFT JOIN [NOM].[Nivel] n ON n.[PKIdNivel] = p.[FKIdNivel_NOM]
LEFT JOIN [NOM].[Universo] u ON u.[PKIdUniverso] = n.[FKIdUniverso_NOM]
LEFT JOIN [NOM].[ClasePuesto] cp ON cp.[PKIdClasePuesto] = p.[FKIdClasePuesto_NOM]
LEFT JOIN [NOM].[ImporteNivel] i ON i.[Clave] = n.[Clave] AND i.[Activo] = 1;
GO

CREATE OR ALTER VIEW [NOM].[Vw_Nombramiento]
AS
SELECT
    n.[PKIdNombramiento],
    n.[Descripcion],
    CONCAT(n.[PKIdNombramiento], N' - ', n.[Descripcion]) AS [ClaveNombre],
    n.[Activo],
    n.[UsuarioCreacion],
    n.[FechaCreacion],
    n.[UsuarioModificacion],
    n.[FechaModificacion]
FROM [NOM].[Nombramiento] n;
GO

CREATE OR ALTER VIEW [NOM].[Vw_ImporteNivel]
AS
SELECT
    i.[PKIdImporteNivel],
    i.[Clave],
    i.[ImpSDI],
    i.[ImpImss15],
    i.[ImpImss16],
    CONCAT(i.[Clave], N' - SDI ', CONVERT(nvarchar(30), i.[ImpSDI])) AS [ClaveNombre],
    i.[Activo],
    i.[UsuarioCreacion],
    i.[FechaCreacion],
    i.[UsuarioModificacion],
    i.[FechaModificacion]
FROM [NOM].[ImporteNivel] i;
GO

CREATE OR ALTER VIEW [NOM].[Vw_ContratoLaboral]
AS
SELECT
    c.[PKIdContratoLaboral],
    c.[FKIdEmpresaNomina_NOM] AS [EmpresaNominaId],
    en.[RazonSocial] AS [EmpresaNominaNombre],
    c.[FKIdPersona_NOM] AS [PersonaId],
    vp.[ClaveNombre] AS [PersonaClaveNombre],
    c.[FechaInicio],
    c.[FechaFin],
    c.[FKIdPuesto_NOM] AS [PuestoId],
    p.[Nombre] AS [PuestoNombre],
    c.[NumeroContrato],
    c.[Vigencia],
    c.[SueldoMensual],
    c.[FKIdNombramiento_NOM] AS [NombramientoId],
    n.[Descripcion] AS [NombramientoDescripcion],
    CONVERT(bit, CASE WHEN c.[Activo] = 1 AND c.[FechaInicio] <= CONVERT(date, SYSDATETIME()) AND c.[FechaFin] >= CONVERT(date, SYSDATETIME()) THEN 1 ELSE 0 END) AS [Vigente],
    c.[Activo],
    c.[UsuarioCreacion],
    c.[FechaCreacion],
    c.[UsuarioModificacion],
    c.[FechaModificacion]
FROM [NOM].[ContratoLaboral] c
LEFT JOIN [NOM].[EmpresaNomina] en ON en.[PKIdEmpresaNomina] = c.[FKIdEmpresaNomina_NOM]
LEFT JOIN [NOM].[Vw_Persona] vp ON vp.[PKIdPersona] = c.[FKIdPersona_NOM]
LEFT JOIN [NOM].[Puesto] p ON p.[PKIdPuesto] = c.[FKIdPuesto_NOM]
LEFT JOIN [NOM].[Nombramiento] n ON n.[PKIdNombramiento] = c.[FKIdNombramiento_NOM];
GO

CREATE OR ALTER VIEW [NOM].[Vw_ConceptoFijo]
AS
SELECT
    cf.[PKIdConceptoFijo],
    cf.[FKIdEmpresa_SIS] AS [EmpresaId],
    COALESCE(en.[RazonSocial], e.[Nombre], N'') AS [EmpresaNombre],
    cf.[FKIdConcepto_NOM] AS [ConceptoId],
    vc.[Clave] AS [ConceptoClave],
    vc.[Nombre] AS [ConceptoNombre],
    vc.[ClaveNombre] AS [ConceptoClaveNombre],
    cf.[FKIdPuesto_NOM] AS [PuestoId],
    vp.[Nombre] AS [PuestoNombre],
    vp.[ClaveNombre] AS [PuestoClaveNombre],
    vp.[NivelId],
    vp.[NivelClave],
    vp.[UniversoId],
    vp.[UniversoDescripcion],
    vp.[ClasePuestoId],
    vp.[ClasePuestoDescripcion],
    CAST(cf.[ImporteMensualFijo] AS decimal(19,4)) AS [ImporteMensualFijo],
    cf.[FechaIni] AS [FechaInicio],
    cf.[FechaFin],
    CAST(
        CASE
            WHEN cf.[Activo] = 1
             AND (cf.[FechaIni] IS NULL OR cf.[FechaIni] <= CONVERT(date, SYSDATETIME()))
             AND (cf.[FechaFin] IS NULL OR cf.[FechaFin] >= CONVERT(date, SYSDATETIME()))
            THEN 1 ELSE 0
        END AS bit
    ) AS [Vigente],
    cf.[Activo],
    cf.[UsuarioCreacion],
    cf.[FechaCreacion],
    cf.[UsuarioModificacion],
    cf.[FechaModificacion]
FROM [NOM].[ConceptoFijo] cf
LEFT JOIN [SIS].[Empresa] e ON e.[PKIdEmpresa] = cf.[FKIdEmpresa_SIS]
LEFT JOIN [NOM].[EmpresaNomina] en ON en.[PKIdEmpresaNomina] = cf.[FKIdEmpresa_SIS]
LEFT JOIN [NOM].[Vw_NOM_Concepto] vc ON vc.[PKIdConcepto] = cf.[FKIdConcepto_NOM]
LEFT JOIN [NOM].[Vw_Puesto] vp ON vp.[PKIdPuesto] = cf.[FKIdPuesto_NOM];
GO

CREATE OR ALTER VIEW [NOM].[Vw_ConceptoProporcional]
AS
SELECT
    cp.[PKIdConceptoProporcional],
    cp.[FKIdEmpresa_SIS] AS [EmpresaId],
    COALESCE(en.[RazonSocial], e.[Nombre], N'') AS [EmpresaNombre],
    cp.[FKIdPuesto_NOM] AS [PuestoId],
    vp.[Nombre] AS [PuestoNombre],
    vp.[ClaveNombre] AS [PuestoClaveNombre],
    vp.[NivelId],
    vp.[NivelClave],
    vp.[UniversoId],
    vp.[UniversoDescripcion],
    vp.[ClasePuestoId],
    vp.[ClasePuestoDescripcion],
    cp.[FKIdConcepto_NOM] AS [ConceptoId],
    vc.[Clave] AS [ConceptoClave],
    vc.[Nombre] AS [ConceptoNombre],
    vc.[ClaveNombre] AS [ConceptoClaveNombre],
    cp.[Activo],
    cp.[UsuarioCreacion],
    cp.[FechaCreacion],
    cp.[UsuarioModificacion],
    cp.[FechaModificacion]
FROM [NOM].[ConceptoProporcional] cp
LEFT JOIN [SIS].[Empresa] e ON e.[PKIdEmpresa] = cp.[FKIdEmpresa_SIS]
LEFT JOIN [NOM].[EmpresaNomina] en ON en.[PKIdEmpresaNomina] = cp.[FKIdEmpresa_SIS]
LEFT JOIN [NOM].[Vw_Puesto] vp ON vp.[PKIdPuesto] = cp.[FKIdPuesto_NOM]
LEFT JOIN [NOM].[Vw_NOM_Concepto] vc ON vc.[PKIdConcepto] = cp.[FKIdConcepto_NOM];
GO

CREATE OR ALTER VIEW [NOM].[Vw_ConceptoTabular]
AS
SELECT
    ct.[PKIdConceptoTabulador],
    ct.[FKIdEmpresa_SIS] AS [EmpresaId],
    COALESCE(en.[RazonSocial], e.[Nombre], N'') AS [EmpresaNombre],
    ct.[FKIdConcepto_NOM] AS [ConceptoId],
    vc.[Clave] AS [ConceptoClave],
    vc.[Nombre] AS [ConceptoNombre],
    vc.[ClaveNombre] AS [ConceptoClaveNombre],
    ct.[FKIdPuesto_NOM] AS [PuestoId],
    vp.[Nombre] AS [PuestoNombre],
    vp.[ClaveNombre] AS [PuestoClaveNombre],
    vp.[NivelId],
    vp.[NivelClave],
    vp.[UniversoId],
    vp.[UniversoDescripcion],
    vp.[ClasePuestoId],
    vp.[ClasePuestoDescripcion],
    CAST(ct.[ImporteMensual] AS decimal(19,4)) AS [ImporteMensual],
    ct.[FechaInicio],
    ct.[FechaFin],
    CAST(
        CASE
            WHEN ct.[Activo] = 1
             AND (ct.[FechaInicio] IS NULL OR ct.[FechaInicio] <= CONVERT(date, SYSDATETIME()))
             AND (ct.[FechaFin] IS NULL OR ct.[FechaFin] >= CONVERT(date, SYSDATETIME()))
            THEN 1 ELSE 0
        END AS bit
    ) AS [Vigente],
    ct.[Activo],
    ct.[UsuarioCreacion],
    ct.[FechaCreacion],
    ct.[UsuarioModificacion],
    ct.[FechaModificacion]
FROM [NOM].[ConceptoTabular] ct
LEFT JOIN [SIS].[Empresa] e ON e.[PKIdEmpresa] = ct.[FKIdEmpresa_SIS]
LEFT JOIN [NOM].[EmpresaNomina] en ON en.[PKIdEmpresaNomina] = ct.[FKIdEmpresa_SIS]
LEFT JOIN [NOM].[Vw_NOM_Concepto] vc ON vc.[PKIdConcepto] = ct.[FKIdConcepto_NOM]
LEFT JOIN [NOM].[Vw_Puesto] vp ON vp.[PKIdPuesto] = ct.[FKIdPuesto_NOM];
GO

CREATE OR ALTER PROCEDURE [NOM].[spPuestos_List]
    @EmpresaNominaId int = NULL,
    @NivelId int = NULL,
    @Page int = 1,
    @PageSize int = 50,
    @Filtro nvarchar(200) = NULL,
    @Activo bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @Page = CASE WHEN @Page IS NULL OR @Page < 1 THEN 1 ELSE @Page END;
    SET @PageSize = CASE WHEN @PageSize IS NULL OR @PageSize < 1 THEN 50 WHEN @PageSize > 500 THEN 500 ELSE @PageSize END;
    SET @Filtro = NULLIF(LTRIM(RTRIM(@Filtro)), N'');

    ;WITH Base AS
    (
        SELECT v.*, COUNT(1) OVER() AS [TotalCount]
        FROM [NOM].[Vw_Puesto] v
        WHERE (@EmpresaNominaId IS NULL OR v.[EmpresaNominaId] = @EmpresaNominaId)
          AND (@NivelId IS NULL OR v.[NivelId] = @NivelId)
          AND (@Activo IS NULL OR v.[Activo] = @Activo)
          AND (
                @Filtro IS NULL
                OR v.[Nombre] LIKE N'%' + @Filtro + N'%'
                OR v.[NivelClave] LIKE N'%' + @Filtro + N'%'
                OR v.[EmpresaNominaNombre] LIKE N'%' + @Filtro + N'%'
                OR v.[ClasePuestoDescripcion] LIKE N'%' + @Filtro + N'%'
          )
    )
    SELECT *
    FROM Base
    ORDER BY [EmpresaNominaNombre], [NivelClave], [Nombre], [PKIdPuesto]
    OFFSET (@Page - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[spConceptosTabulares_List]
    @EmpresaId int = NULL,
    @PuestoId int = NULL,
    @ConceptoId int = NULL,
    @NivelId int = NULL,
    @Page int = 1,
    @PageSize int = 50,
    @Filtro nvarchar(200) = NULL,
    @Activo bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @Page = CASE WHEN @Page IS NULL OR @Page < 1 THEN 1 ELSE @Page END;
    SET @PageSize = CASE WHEN @PageSize IS NULL OR @PageSize < 1 THEN 50 WHEN @PageSize > 500 THEN 500 ELSE @PageSize END;
    SET @Filtro = NULLIF(LTRIM(RTRIM(@Filtro)), N'');

    ;WITH Base AS
    (
        SELECT v.*, COUNT(1) OVER() AS [TotalCount]
        FROM [NOM].[Vw_ConceptoTabular] v
        WHERE (@EmpresaId IS NULL OR v.[EmpresaId] = @EmpresaId)
          AND (@PuestoId IS NULL OR v.[PuestoId] = @PuestoId)
          AND (@ConceptoId IS NULL OR v.[ConceptoId] = @ConceptoId)
          AND (@NivelId IS NULL OR v.[NivelId] = @NivelId)
          AND (@Activo IS NULL OR v.[Activo] = @Activo)
          AND (
                @Filtro IS NULL
                OR v.[ConceptoClave] LIKE N'%' + @Filtro + N'%'
                OR v.[ConceptoNombre] LIKE N'%' + @Filtro + N'%'
                OR v.[PuestoNombre] LIKE N'%' + @Filtro + N'%'
                OR v.[NivelClave] LIKE N'%' + @Filtro + N'%'
                OR v.[EmpresaNombre] LIKE N'%' + @Filtro + N'%'
          )
    )
    SELECT *
    FROM Base
    ORDER BY [EmpresaNombre], [PuestoNombre], [ConceptoClave], [PKIdConceptoTabulador]
    OFFSET (@Page - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[spContratosLaborales_List]
    @EmpresaNominaId int = NULL,
    @PersonaId int = NULL,
    @PuestoId int = NULL,
    @NombramientoId int = NULL,
    @Page int = 1,
    @PageSize int = 50,
    @Filtro nvarchar(200) = NULL,
    @Activo bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @Page = CASE WHEN @Page IS NULL OR @Page < 1 THEN 1 ELSE @Page END;
    SET @PageSize = CASE WHEN @PageSize IS NULL OR @PageSize < 1 THEN 50 WHEN @PageSize > 500 THEN 500 ELSE @PageSize END;
    SET @Filtro = NULLIF(LTRIM(RTRIM(@Filtro)), N'');

    ;WITH Base AS
    (
        SELECT v.*, COUNT(1) OVER() AS [TotalCount]
        FROM [NOM].[Vw_ContratoLaboral] v
        WHERE (@EmpresaNominaId IS NULL OR v.[EmpresaNominaId] = @EmpresaNominaId)
          AND (@PersonaId IS NULL OR v.[PersonaId] = @PersonaId)
          AND (@PuestoId IS NULL OR v.[PuestoId] = @PuestoId)
          AND (@NombramientoId IS NULL OR v.[NombramientoId] = @NombramientoId)
          AND (@Activo IS NULL OR v.[Activo] = @Activo)
          AND (
                @Filtro IS NULL
                OR v.[PersonaClaveNombre] LIKE N'%' + @Filtro + N'%'
                OR v.[PuestoNombre] LIKE N'%' + @Filtro + N'%'
                OR v.[NombramientoDescripcion] LIKE N'%' + @Filtro + N'%'
                OR v.[NumeroContrato] LIKE N'%' + @Filtro + N'%'
          )
    )
    SELECT *
    FROM Base
    ORDER BY [FechaInicio] DESC, [PersonaClaveNombre], [PKIdContratoLaboral]
    OFFSET (@Page - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO
