SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

SET NOCOUNT ON;

DECLARE @Now datetime2(7) = SYSDATETIME();

IF OBJECT_ID(N'[SIS].[Parentesco]', N'U') IS NOT NULL
BEGIN
    SET IDENTITY_INSERT [SIS].[Parentesco] ON;

    MERGE [SIS].[Parentesco] AS target
    USING (
        SELECT
            src.[Pk_IdParentesco] AS [PKIdParentesco],
            LEFT(COALESCE(NULLIF(LTRIM(RTRIM(src.[Descripcion])), N''), N'Sin descripcion'), 50) AS [Descripcion],
            CAST(COALESCE(src.[CT_LIVE], 1) AS bit) AS [Activo],
            COALESCE(src.[CT_CreatedDate], @Now) AS [FechaCreacion],
            COALESCE(src.[CT_CreatedBy], 1) AS [UsuarioCreacion],
            src.[CT_ModifiedDate] AS [FechaModificacion],
            src.[CT_ModifiedBy] AS [UsuarioModificacion]
        FROM [BD_GRP_INVEA].[dbo].[SIS_Parentesco] AS src
    ) AS source
    ON target.[PKIdParentesco] = source.[PKIdParentesco]
    WHEN MATCHED THEN
        UPDATE SET
            [Descripcion] = source.[Descripcion],
            [Activo] = source.[Activo],
            [FechaModificacion] = COALESCE(source.[FechaModificacion], target.[FechaModificacion]),
            [UsuarioModificacion] = COALESCE(source.[UsuarioModificacion], target.[UsuarioModificacion])
    WHEN NOT MATCHED BY TARGET THEN
        INSERT ([PKIdParentesco], [Descripcion], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion])
        VALUES (source.[PKIdParentesco], source.[Descripcion], source.[Activo], source.[FechaCreacion], source.[UsuarioCreacion], source.[FechaModificacion], source.[UsuarioModificacion]);

    SET IDENTITY_INSERT [SIS].[Parentesco] OFF;
END;

IF OBJECT_ID(N'[SIS].[TipoContratacion]', N'U') IS NOT NULL
BEGIN
    SET IDENTITY_INSERT [SIS].[TipoContratacion] ON;

    MERGE [SIS].[TipoContratacion] AS target
    USING (
        SELECT
            src.[Pk_IdTipoContratacion] AS [PKIdTipoContratacion],
            LEFT(NULLIF(LTRIM(RTRIM(src.[Tipo])), N''), 2) AS [Tipo],
            LEFT(COALESCE(NULLIF(LTRIM(RTRIM(src.[Descripcion])), N''), N'Sin descripcion'), 80) AS [Descripcion],
            LEFT(NULLIF(LTRIM(RTRIM(src.[Explicacion])), N''), 1000) AS [Explicacion],
            LEFT(NULLIF(LTRIM(RTRIM(src.[DoctoComprobacion])), N''), 50) AS [DoctoComprobacion],
            LEFT(NULLIF(LTRIM(RTRIM(src.[Normatividad])), N''), 500) AS [Normatividad],
            LEFT(NULLIF(LTRIM(RTRIM(src.[Deducciones])), N''), 500) AS [Deducciones],
            LEFT(NULLIF(LTRIM(RTRIM(src.[DoctoComprob])), N''), 50) AS [DoctoComprob],
            LEFT(NULLIF(LTRIM(RTRIM(src.[RelacionLaboral])), N''), 500) AS [RelacionLaboral],
            CAST(COALESCE(src.[CT_LIVE], 1) AS bit) AS [Activo],
            COALESCE(src.[CT_CreatedDate], @Now) AS [FechaCreacion],
            COALESCE(src.[CT_CreatedBy], 1) AS [UsuarioCreacion],
            src.[CT_ModifiedDate] AS [FechaModificacion],
            src.[CT_ModifiedBy] AS [UsuarioModificacion]
        FROM [BD_GRP_INVEA].[dbo].[SIS_TipoContratacion] AS src
    ) AS source
    ON target.[PKIdTipoContratacion] = source.[PKIdTipoContratacion]
    WHEN MATCHED THEN
        UPDATE SET
            [Tipo] = source.[Tipo],
            [Descripcion] = source.[Descripcion],
            [Explicacion] = source.[Explicacion],
            [DoctoComprobacion] = source.[DoctoComprobacion],
            [Normatividad] = source.[Normatividad],
            [Deducciones] = source.[Deducciones],
            [DoctoComprob] = source.[DoctoComprob],
            [RelacionLaboral] = source.[RelacionLaboral],
            [Activo] = source.[Activo],
            [FechaModificacion] = COALESCE(source.[FechaModificacion], target.[FechaModificacion]),
            [UsuarioModificacion] = COALESCE(source.[UsuarioModificacion], target.[UsuarioModificacion])
    WHEN NOT MATCHED BY TARGET THEN
        INSERT ([PKIdTipoContratacion], [Tipo], [Descripcion], [Explicacion], [DoctoComprobacion], [Normatividad], [Deducciones], [DoctoComprob], [RelacionLaboral], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion])
        VALUES (source.[PKIdTipoContratacion], source.[Tipo], source.[Descripcion], source.[Explicacion], source.[DoctoComprobacion], source.[Normatividad], source.[Deducciones], source.[DoctoComprob], source.[RelacionLaboral], source.[Activo], source.[FechaCreacion], source.[UsuarioCreacion], source.[FechaModificacion], source.[UsuarioModificacion]);

    SET IDENTITY_INSERT [SIS].[TipoContratacion] OFF;
END;

IF OBJECT_ID(N'[SIS].[TipoIncidencia]', N'U') IS NOT NULL
BEGIN
    SET IDENTITY_INSERT [SIS].[TipoIncidencia] ON;

    MERGE [SIS].[TipoIncidencia] AS target
    USING (
        SELECT
            src.[Pk_IdTipoIncidencia] AS [PKIdTipoIncidencia],
            LEFT(COALESCE(NULLIF(LTRIM(RTRIM(src.[Descripcion])), N''), N'Sin descripcion'), 50) AS [Descripcion],
            src.[DiasPenalizacion],
            CAST(COALESCE(src.[CT_LIVE], 1) AS bit) AS [Activo],
            COALESCE(src.[CT_CreatedDate], @Now) AS [FechaCreacion],
            COALESCE(src.[CT_CreatedBy], 1) AS [UsuarioCreacion],
            src.[CT_ModifiedDate] AS [FechaModificacion],
            src.[CT_ModifiedBy] AS [UsuarioModificacion]
        FROM [BD_GRP_INVEA].[dbo].[SIS_TipoIncidencia] AS src
    ) AS source
    ON target.[PKIdTipoIncidencia] = source.[PKIdTipoIncidencia]
    WHEN MATCHED THEN
        UPDATE SET
            [Descripcion] = source.[Descripcion],
            [DiasPenalizacion] = source.[DiasPenalizacion],
            [Activo] = source.[Activo],
            [FechaModificacion] = COALESCE(source.[FechaModificacion], target.[FechaModificacion]),
            [UsuarioModificacion] = COALESCE(source.[UsuarioModificacion], target.[UsuarioModificacion])
    WHEN NOT MATCHED BY TARGET THEN
        INSERT ([PKIdTipoIncidencia], [Descripcion], [DiasPenalizacion], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion])
        VALUES (source.[PKIdTipoIncidencia], source.[Descripcion], source.[DiasPenalizacion], source.[Activo], source.[FechaCreacion], source.[UsuarioCreacion], source.[FechaModificacion], source.[UsuarioModificacion]);

    SET IDENTITY_INSERT [SIS].[TipoIncidencia] OFF;
END;

IF OBJECT_ID(N'[SIS].[TipoJustificacion]', N'U') IS NOT NULL
BEGIN
    SET IDENTITY_INSERT [SIS].[TipoJustificacion] ON;

    MERGE [SIS].[TipoJustificacion] AS target
    USING (
        SELECT
            src.[Pk_IdTipoJustificacion] AS [PKIdTipoJustificacion],
            LEFT(COALESCE(NULLIF(LTRIM(RTRIM(src.[Descripcion])), N''), N'Sin descripcion'), 50) AS [Descripcion],
            CAST(COALESCE(src.[CT_LIVE], 1) AS bit) AS [Activo],
            COALESCE(src.[CT_CreatedDate], @Now) AS [FechaCreacion],
            COALESCE(src.[CT_CreatedBy], 1) AS [UsuarioCreacion],
            src.[CT_ModifiedDate] AS [FechaModificacion],
            src.[CT_ModifiedBy] AS [UsuarioModificacion]
        FROM [BD_GRP_INVEA].[dbo].[SIS_TipoJustificacion] AS src
    ) AS source
    ON target.[PKIdTipoJustificacion] = source.[PKIdTipoJustificacion]
    WHEN MATCHED THEN
        UPDATE SET
            [Descripcion] = source.[Descripcion],
            [Activo] = source.[Activo],
            [FechaModificacion] = COALESCE(source.[FechaModificacion], target.[FechaModificacion]),
            [UsuarioModificacion] = COALESCE(source.[UsuarioModificacion], target.[UsuarioModificacion])
    WHEN NOT MATCHED BY TARGET THEN
        INSERT ([PKIdTipoJustificacion], [Descripcion], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion])
        VALUES (source.[PKIdTipoJustificacion], source.[Descripcion], source.[Activo], source.[FechaCreacion], source.[UsuarioCreacion], source.[FechaModificacion], source.[UsuarioModificacion]);

    SET IDENTITY_INSERT [SIS].[TipoJustificacion] OFF;
END;
GO
