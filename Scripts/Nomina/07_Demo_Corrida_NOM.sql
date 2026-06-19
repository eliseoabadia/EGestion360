SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- Demo funcional de corrida de nomina.
-- Crea una capa de corrida controlada sin modificar los movimientos historicos migrados.

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'NOM')
    EXEC(N'CREATE SCHEMA [NOM]');
GO

IF OBJECT_ID(N'[NOM].[CorridaNomina]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[CorridaNomina] (
        [PKIdCorridaNomina] int IDENTITY(1,1) NOT NULL,
        [FKIdEmpresaNomina_NOM] int NOT NULL,
        [IdPeriodo] int NOT NULL,
        [Anio] int NULL,
        [TipoCorrida] nvarchar(30) NOT NULL CONSTRAINT [DF_NOM_CorridaNomina_Tipo] DEFAULT N'DEMO',
        [Estatus] nvarchar(30) NOT NULL CONSTRAINT [DF_NOM_CorridaNomina_Estatus] DEFAULT N'Calculada',
        [FechaProceso] date NOT NULL,
        [Observaciones] nvarchar(500) NULL,
        [TotalPersonas] int NOT NULL CONSTRAINT [DF_NOM_CorridaNomina_TotalPersonas] DEFAULT 0,
        [TotalMovimientos] int NOT NULL CONSTRAINT [DF_NOM_CorridaNomina_TotalMovimientos] DEFAULT 0,
        [TotalPercepcion] decimal(19,4) NOT NULL CONSTRAINT [DF_NOM_CorridaNomina_TotalPercepcion] DEFAULT 0,
        [TotalDeduccion] decimal(19,4) NOT NULL CONSTRAINT [DF_NOM_CorridaNomina_TotalDeduccion] DEFAULT 0,
        [TotalAportacion] decimal(19,4) NOT NULL CONSTRAINT [DF_NOM_CorridaNomina_TotalAportacion] DEFAULT 0,
        [TotalNeto] decimal(19,4) NOT NULL CONSTRAINT [DF_NOM_CorridaNomina_TotalNeto] DEFAULT 0,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NOT NULL CONSTRAINT [DF_NOM_CorridaNomina_FechaCreacion] DEFAULT SYSUTCDATETIME(),
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_NOM_CorridaNomina_Activo] DEFAULT 1,
        CONSTRAINT [PK_NOM_CorridaNomina] PRIMARY KEY ([PKIdCorridaNomina])
    );
END
GO

IF OBJECT_ID(N'[NOM].[CorridaNominaDetalle]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[CorridaNominaDetalle] (
        [PKIdCorridaNominaDetalle] int IDENTITY(1,1) NOT NULL,
        [FKIdCorridaNomina_NOM] int NOT NULL,
        [FKIdPersona_NOM] int NOT NULL,
        [FKIdContratoLaboral_NOM] int NULL,
        [FKIdPuesto_NOM] int NULL,
        [FKIdConcepto_NOM] int NOT NULL,
        [ConceptoClave] nvarchar(20) NOT NULL,
        [ConceptoNombre] nvarchar(500) NOT NULL,
        [TipoMovimiento] nvarchar(20) NOT NULL,
        [Percepcion] decimal(19,4) NOT NULL CONSTRAINT [DF_NOM_CorridaNominaDetalle_Percepcion] DEFAULT 0,
        [Deduccion] decimal(19,4) NOT NULL CONSTRAINT [DF_NOM_CorridaNominaDetalle_Deduccion] DEFAULT 0,
        [Aportacion] decimal(19,4) NOT NULL CONSTRAINT [DF_NOM_CorridaNominaDetalle_Aportacion] DEFAULT 0,
        [Neto] decimal(19,4) NOT NULL CONSTRAINT [DF_NOM_CorridaNominaDetalle_Neto] DEFAULT 0,
        [Referencia] nvarchar(250) NULL,
        [Origen] nvarchar(40) NOT NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NOT NULL CONSTRAINT [DF_NOM_CorridaNominaDetalle_FechaCreacion] DEFAULT SYSUTCDATETIME(),
        [Activo] bit NOT NULL CONSTRAINT [DF_NOM_CorridaNominaDetalle_Activo] DEFAULT 1,
        CONSTRAINT [PK_NOM_CorridaNominaDetalle] PRIMARY KEY ([PKIdCorridaNominaDetalle]),
        CONSTRAINT [FK_NOM_CorridaNominaDetalle_Corrida] FOREIGN KEY ([FKIdCorridaNomina_NOM])
            REFERENCES [NOM].[CorridaNomina] ([PKIdCorridaNomina])
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_NOM_CorridaNomina_Demo' AND object_id = OBJECT_ID(N'[NOM].[CorridaNomina]'))
    CREATE UNIQUE INDEX [UX_NOM_CorridaNomina_Demo]
        ON [NOM].[CorridaNomina] ([FKIdEmpresaNomina_NOM], [IdPeriodo], [TipoCorrida])
        WHERE [Activo] = 1;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_NOM_CorridaNominaDetalle_CorridaPersona' AND object_id = OBJECT_ID(N'[NOM].[CorridaNominaDetalle]'))
    CREATE INDEX [IX_NOM_CorridaNominaDetalle_CorridaPersona]
        ON [NOM].[CorridaNominaDetalle] ([FKIdCorridaNomina_NOM], [FKIdPersona_NOM], [FKIdConcepto_NOM]);
GO

CREATE OR ALTER VIEW [NOM].[Vw_UsuarioNomina]
AS
SELECT
    u.[PkIdUsuario] AS [UsuarioId],
    u.[AspNetUserId],
    COALESCE(au.[Email], N'') AS [Email],
    COALESCE(au.[AccessNumber], N'') AS [AccessNumber],
    u.[PayrollID],
    u.[FKIdEmpresa_SIS] AS [EmpresaSisId],
    u.[FKIdPersona_NOM] AS [PersonaId],
    vp.[ClaveNombre] AS [PersonaClaveNombre],
    cl.[EmpresaNominaId],
    cl.[EmpresaNominaNombre],
    cl.[PKIdContratoLaboral] AS [ContratoLaboralId],
    cl.[PuestoId],
    cl.[PuestoNombre],
    cl.[NumeroContrato],
    cl.[Vigente] AS [ContratoVigente],
    u.[EsAdministrador],
    u.[Activo],
    u.[FechaCreacion],
    u.[UsuarioCreacion],
    u.[FechaModificacion],
    u.[UsuarioModificacion]
FROM [SIS].[Usuario] u
OUTER APPLY
(
    SELECT TOP (1) au.*
    FROM [dbo].[AspNetUsers] au
    WHERE au.[PkIdUsuario] = u.[PkIdUsuario]
       OR au.[Id] = u.[AspNetUserId]
    ORDER BY CASE WHEN au.[Id] = u.[AspNetUserId] THEN 0 ELSE 1 END, au.[Id]
) au
LEFT JOIN [NOM].[Vw_Persona] vp
    ON vp.[PKIdPersona] = u.[FKIdPersona_NOM]
OUTER APPLY
(
    SELECT TOP (1) c.*
    FROM [NOM].[Vw_ContratoLaboral] c
    WHERE c.[PersonaId] = u.[FKIdPersona_NOM]
      AND c.[Activo] = 1
    ORDER BY c.[Vigente] DESC, c.[FechaInicio] DESC, c.[PKIdContratoLaboral] DESC
) cl;
GO

CREATE OR ALTER VIEW [NOM].[Vw_CorridaNomina]
AS
SELECT
    c.[PKIdCorridaNomina],
    c.[FKIdEmpresaNomina_NOM] AS [EmpresaNominaId],
    en.[RazonSocial] AS [EmpresaNominaNombre],
    c.[IdPeriodo],
    c.[Anio],
    c.[TipoCorrida],
    c.[Estatus],
    c.[FechaProceso],
    c.[Observaciones],
    c.[TotalPersonas],
    c.[TotalMovimientos],
    c.[TotalPercepcion],
    c.[TotalDeduccion],
    c.[TotalAportacion],
    c.[TotalNeto],
    c.[Activo],
    c.[FechaCreacion],
    c.[UsuarioCreacion],
    c.[FechaModificacion],
    c.[UsuarioModificacion]
FROM [NOM].[CorridaNomina] c
LEFT JOIN [NOM].[EmpresaNomina] en
    ON en.[PKIdEmpresaNomina] = c.[FKIdEmpresaNomina_NOM];
GO

CREATE OR ALTER VIEW [NOM].[Vw_CorridaNominaDetalle]
AS
SELECT
    d.[PKIdCorridaNominaDetalle],
    d.[FKIdCorridaNomina_NOM] AS [CorridaNominaId],
    c.[EmpresaNominaId],
    c.[EmpresaNominaNombre],
    c.[IdPeriodo],
    c.[Anio],
    c.[TipoCorrida],
    c.[Estatus],
    d.[FKIdPersona_NOM] AS [PersonaId],
    vp.[ClaveNombre] AS [PersonaClaveNombre],
    d.[FKIdContratoLaboral_NOM] AS [ContratoLaboralId],
    d.[FKIdPuesto_NOM] AS [PuestoId],
    p.[Nombre] AS [PuestoNombre],
    d.[FKIdConcepto_NOM] AS [ConceptoId],
    d.[ConceptoClave],
    d.[ConceptoNombre],
    d.[TipoMovimiento],
    d.[Percepcion],
    d.[Deduccion],
    d.[Aportacion],
    d.[Neto],
    d.[Referencia],
    d.[Origen],
    d.[Activo],
    d.[FechaCreacion],
    d.[UsuarioCreacion]
FROM [NOM].[CorridaNominaDetalle] d
INNER JOIN [NOM].[Vw_CorridaNomina] c
    ON c.[PKIdCorridaNomina] = d.[FKIdCorridaNomina_NOM]
LEFT JOIN [NOM].[Vw_Persona] vp
    ON vp.[PKIdPersona] = d.[FKIdPersona_NOM]
LEFT JOIN [NOM].[Puesto] p
    ON p.[PKIdPuesto] = d.[FKIdPuesto_NOM];
GO

CREATE OR ALTER PROCEDURE [NOM].[spUsuariosNomina_AdaptarDemo]
    @UsuarioId int = NULL,
    @EmpresaNominaId int = NULL,
    @PersonaId int = NULL,
    @UsuarioActual int = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UsuarioObjetivo int = COALESCE(@UsuarioId, @UsuarioActual);
    IF @UsuarioObjetivo IS NULL
    BEGIN
        SELECT TOP (1) @UsuarioObjetivo = [PkIdUsuario]
        FROM [SIS].[Usuario]
        WHERE [Activo] = 1
        ORDER BY [PkIdUsuario];
    END

    IF @UsuarioObjetivo IS NULL
        THROW 51000, 'No hay usuarios activos para adaptar a nomina.', 1;

    DECLARE @PersonaObjetivo int = @PersonaId;
    DECLARE @EmpresaObjetivo int = NULL;

    IF @PersonaObjetivo IS NULL
    BEGIN
        SELECT @PersonaObjetivo = [FKIdPersona_NOM]
        FROM [SIS].[Usuario]
        WHERE [PkIdUsuario] = @UsuarioObjetivo;
    END

    IF @EmpresaNominaId IS NOT NULL
       AND EXISTS (
            SELECT 1
            FROM [NOM].[PeriodoActivo] pa
            WHERE pa.[FKIdEmpresa_SIS] = @EmpresaNominaId
              AND pa.[Activo] = 1
       )
    BEGIN
        SET @EmpresaObjetivo = @EmpresaNominaId;
    END

    IF @PersonaObjetivo IS NOT NULL AND @EmpresaObjetivo IS NULL
    BEGIN
        SELECT TOP (1) @EmpresaObjetivo = c.[EmpresaNominaId]
        FROM [NOM].[Vw_ContratoLaboral] c
        WHERE c.[PersonaId] = @PersonaObjetivo
          AND c.[Activo] = 1
        ORDER BY c.[Vigente] DESC, c.[FechaInicio] DESC;
    END

    IF @EmpresaObjetivo IS NULL
    BEGIN
        SELECT TOP (1) @EmpresaObjetivo = pa.[FKIdEmpresa_SIS]
        FROM [NOM].[PeriodoActivo] pa
        WHERE pa.[Activo] = 1
        ORDER BY pa.[EstaCerrado], pa.[IdPeriodo] DESC, pa.[FKIdEmpresa_SIS];
    END

    IF @PersonaObjetivo IS NULL
    BEGIN
        SELECT TOP (1) @PersonaObjetivo = c.[PersonaId]
        FROM [NOM].[Vw_ContratoLaboral] c
        WHERE c.[EmpresaNominaId] = @EmpresaObjetivo
          AND c.[Activo] = 1
        ORDER BY c.[Vigente] DESC, c.[PersonaId];
    END

    IF @PersonaObjetivo IS NULL
        THROW 51001, 'No hay persona NOM disponible para adaptar al usuario.', 1;

    IF @EmpresaObjetivo IS NULL
        THROW 51002, 'No hay empresa de nomina disponible para la demo.', 1;

    UPDATE u
        SET [FKIdPersona_NOM] = @PersonaObjetivo,
            [PayrollID] = COALESCE(NULLIF(u.[PayrollID], N''), CONVERT(nvarchar(20), @PersonaObjetivo)),
            [FKIdEmpresa_SIS] = COALESCE(u.[FKIdEmpresa_SIS], @EmpresaObjetivo),
            [FechaModificacion] = SYSUTCDATETIME(),
            [UsuarioModificacion] = @UsuarioObjetivo
    FROM [SIS].[Usuario] u
    WHERE u.[PkIdUsuario] = @UsuarioObjetivo;

    UPDATE au
        SET [PkIdUsuario] = @UsuarioObjetivo,
            [ReferenceId] = COALESCE(au.[ReferenceId], @UsuarioObjetivo),
            [AccessNumber] = COALESCE(NULLIF(au.[AccessNumber], N''), RIGHT(N'0000000000' + CONVERT(nvarchar(20), @UsuarioObjetivo), 10))
    FROM [dbo].[AspNetUsers] au
    WHERE au.[PkIdUsuario] = @UsuarioObjetivo
       OR au.[PkIdUsuario] IS NULL
       OR EXISTS (
            SELECT 1
            FROM [SIS].[Usuario] u
            WHERE u.[PkIdUsuario] = @UsuarioObjetivo
              AND u.[AspNetUserId] = au.[Id]
       );

    SELECT
        u.[PkIdUsuario] AS [UsuarioId],
        u.[FKIdPersona_NOM] AS [PersonaId],
        vp.[ClaveNombre] AS [PersonaClaveNombre],
        @EmpresaObjetivo AS [EmpresaNominaId],
        en.[RazonSocial] AS [EmpresaNominaNombre],
        u.[PayrollID],
        CAST(N'Usuario adaptado para demo de nomina.' AS nvarchar(500)) AS [Mensaje]
    FROM [SIS].[Usuario] u
    LEFT JOIN [NOM].[Vw_Persona] vp
        ON vp.[PKIdPersona] = u.[FKIdPersona_NOM]
    LEFT JOIN [NOM].[EmpresaNomina] en
        ON en.[PKIdEmpresaNomina] = @EmpresaObjetivo
    WHERE u.[PkIdUsuario] = @UsuarioObjetivo;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[spCorridaNomina_Demo]
    @EmpresaId int = NULL,
    @PeriodoId int = NULL,
    @PersonaId int = NULL,
    @Anio int = NULL,
    @FechaProceso date = NULL,
    @Observaciones nvarchar(500) = NULL,
    @UsuarioId int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Adapt TABLE
    (
        UsuarioId int,
        PersonaId int,
        PersonaClaveNombre nvarchar(600),
        EmpresaNominaId int,
        EmpresaNominaNombre nvarchar(250),
        PayrollID nvarchar(20),
        Mensaje nvarchar(500)
    );

    INSERT INTO @Adapt
    EXEC [NOM].[spUsuariosNomina_AdaptarDemo]
        @UsuarioId = @UsuarioId,
        @EmpresaNominaId = @EmpresaId,
        @PersonaId = @PersonaId,
        @UsuarioActual = @UsuarioId;

    DECLARE @UsuarioObjetivo int;
    DECLARE @EmpresaNominaId int;
    DECLARE @PersonaObjetivo int;

    SELECT TOP (1)
        @UsuarioObjetivo = [UsuarioId],
        @EmpresaNominaId = [EmpresaNominaId],
        @PersonaObjetivo = [PersonaId]
    FROM @Adapt;

    IF @PersonaId IS NOT NULL
        SET @PersonaObjetivo = @PersonaId;

    IF @FechaProceso IS NULL
        SET @FechaProceso = CONVERT(date, GETDATE());

    IF @PeriodoId IS NULL
    BEGIN
        SELECT TOP (1) @PeriodoId = [IdPeriodo]
        FROM [NOM].[PeriodoActivo]
        WHERE [FKIdEmpresa_SIS] = @EmpresaNominaId
          AND [Activo] = 1
        ORDER BY [EstaCerrado], [IdPeriodo] DESC;
    END

    IF @PeriodoId IS NULL
        THROW 51003, 'No hay periodo disponible para generar la corrida de nomina.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM [NOM].[PeriodoActivo]
        WHERE [FKIdEmpresa_SIS] = @EmpresaNominaId
          AND [IdPeriodo] = @PeriodoId
          AND [Activo] = 1
    )
    BEGIN
        INSERT INTO [NOM].[PeriodoActivo]
            ([FKIdEmpresa_SIS], [IdPeriodo], [EstaCerrado], [UsuarioCreacion], [FechaCreacion], [Activo], [EstaComprometido], [EstaDevengado], [EstaEjercido])
        VALUES
            (@EmpresaNominaId, @PeriodoId, 0, @UsuarioObjetivo, SYSUTCDATETIME(), 1, 0, 0, 0);
    END

    DECLARE @CorridaId int;

    BEGIN TRANSACTION;

    SELECT @CorridaId = [PKIdCorridaNomina]
    FROM [NOM].[CorridaNomina]
    WHERE [FKIdEmpresaNomina_NOM] = @EmpresaNominaId
      AND [IdPeriodo] = @PeriodoId
      AND [TipoCorrida] = N'DEMO'
      AND [Activo] = 1;

    IF @CorridaId IS NULL
    BEGIN
        INSERT INTO [NOM].[CorridaNomina]
            ([FKIdEmpresaNomina_NOM], [IdPeriodo], [Anio], [TipoCorrida], [Estatus], [FechaProceso], [Observaciones], [UsuarioCreacion], [FechaCreacion], [Activo])
        VALUES
            (@EmpresaNominaId, @PeriodoId, @Anio, N'DEMO', N'Calculada', @FechaProceso, @Observaciones, @UsuarioObjetivo, SYSUTCDATETIME(), 1);

        SET @CorridaId = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE [NOM].[CorridaNomina]
            SET [Anio] = @Anio,
                [Estatus] = N'Calculada',
                [FechaProceso] = @FechaProceso,
                [Observaciones] = @Observaciones,
                [UsuarioModificacion] = @UsuarioObjetivo,
                [FechaModificacion] = SYSUTCDATETIME()
        WHERE [PKIdCorridaNomina] = @CorridaId;

        DELETE FROM [NOM].[CorridaNominaDetalle]
        WHERE [FKIdCorridaNomina_NOM] = @CorridaId;
    END

    INSERT INTO [NOM].[CorridaNominaDetalle]
        ([FKIdCorridaNomina_NOM], [FKIdPersona_NOM], [FKIdContratoLaboral_NOM], [FKIdPuesto_NOM], [FKIdConcepto_NOM],
         [ConceptoClave], [ConceptoNombre], [TipoMovimiento], [Percepcion], [Deduccion], [Aportacion], [Neto],
         [Referencia], [Origen], [UsuarioCreacion], [FechaCreacion], [Activo])
    SELECT
        @CorridaId,
        m.[PersonaId],
        contrato.[PKIdContratoLaboral],
        contrato.[PuestoId],
        m.[ConceptoId],
        LEFT(COALESCE(m.[ConceptoClave], N''), 20),
        LEFT(COALESCE(m.[ConceptoNombre], N''), 500),
        CASE
            WHEN COALESCE(m.[Deduccion], 0) > 0 THEN N'Deduccion'
            WHEN COALESCE(m.[Aportacion], 0) > 0 THEN N'Aportacion'
            ELSE N'Percepcion'
        END,
        COALESCE(m.[Percepcion], 0),
        COALESCE(m.[Deduccion], 0),
        COALESCE(m.[Aportacion], 0),
        COALESCE(m.[Neto], 0),
        LEFT(COALESCE(NULLIF(m.[Referencia], N''), m.[TipoNomina]), 250),
        N'MOVIMIENTO_MIGRADO',
        @UsuarioObjetivo,
        SYSUTCDATETIME(),
        1
    FROM [NOM].[Vw_MovimientosNomina] m
    OUTER APPLY
    (
        SELECT TOP (1) c.[PKIdContratoLaboral], c.[PuestoId]
        FROM [NOM].[Vw_ContratoLaboral] c
        WHERE c.[EmpresaNominaId] = @EmpresaNominaId
          AND c.[PersonaId] = m.[PersonaId]
          AND c.[Activo] = 1
        ORDER BY c.[Vigente] DESC, c.[FechaInicio] DESC
    ) contrato
    WHERE m.[EmpresaId] = @EmpresaNominaId
      AND m.[PeriodoId] = @PeriodoId
      AND m.[Activo] = 1
      AND (@PersonaId IS NULL OR m.[PersonaId] = @PersonaId);

    IF @@ROWCOUNT = 0
    BEGIN
        INSERT INTO [NOM].[CorridaNominaDetalle]
            ([FKIdCorridaNomina_NOM], [FKIdPersona_NOM], [FKIdContratoLaboral_NOM], [FKIdPuesto_NOM], [FKIdConcepto_NOM],
             [ConceptoClave], [ConceptoNombre], [TipoMovimiento], [Percepcion], [Deduccion], [Aportacion], [Neto],
             [Referencia], [Origen], [UsuarioCreacion], [FechaCreacion], [Activo])
        SELECT
            @CorridaId,
            c.[PersonaId],
            c.[PKIdContratoLaboral],
            c.[PuestoId],
            ct.[ConceptoId],
            LEFT(COALESCE(ct.[ConceptoClave], N''), 20),
            LEFT(COALESCE(ct.[ConceptoNombre], N''), 500),
            CASE WHEN vc.[PerDed] = N'D' THEN N'Deduccion' ELSE N'Percepcion' END,
            CAST(CASE WHEN vc.[PerDed] = N'D' THEN 0 ELSE ROUND(ct.[ImporteMensual] / 2.0, 4) END AS decimal(19,4)),
            CAST(CASE WHEN vc.[PerDed] = N'D' THEN ROUND(ct.[ImporteMensual] / 2.0, 4) ELSE 0 END AS decimal(19,4)),
            CAST(0 AS decimal(19,4)),
            CAST(CASE WHEN vc.[PerDed] = N'D' THEN -ROUND(ct.[ImporteMensual] / 2.0, 4) ELSE ROUND(ct.[ImporteMensual] / 2.0, 4) END AS decimal(19,4)),
            N'Tabulador demo',
            N'TABULADOR_DEMO',
            @UsuarioObjetivo,
            SYSUTCDATETIME(),
            1
        FROM [NOM].[Vw_ContratoLaboral] c
        INNER JOIN [NOM].[Vw_ConceptoTabular] ct
            ON ct.[EmpresaId] = c.[EmpresaNominaId]
           AND ct.[PuestoId] = c.[PuestoId]
           AND ct.[Activo] = 1
           AND ct.[Vigente] = 1
        LEFT JOIN [NOM].[Vw_NOM_Concepto] vc
            ON vc.[PKIdConcepto] = ct.[ConceptoId]
        WHERE c.[EmpresaNominaId] = @EmpresaNominaId
          AND c.[Activo] = 1
          AND c.[Vigente] = 1
          AND (@PersonaId IS NULL OR c.[PersonaId] = @PersonaId);
    END

    IF NOT EXISTS (SELECT 1 FROM [NOM].[CorridaNominaDetalle] WHERE [FKIdCorridaNomina_NOM] = @CorridaId)
        THROW 51004, 'No hay contratos o movimientos para generar la corrida de nomina.', 1;

    UPDATE c
        SET [TotalPersonas] = resumen.[TotalPersonas],
            [TotalMovimientos] = resumen.[TotalMovimientos],
            [TotalPercepcion] = resumen.[TotalPercepcion],
            [TotalDeduccion] = resumen.[TotalDeduccion],
            [TotalAportacion] = resumen.[TotalAportacion],
            [TotalNeto] = resumen.[TotalNeto],
            [UsuarioModificacion] = @UsuarioObjetivo,
            [FechaModificacion] = SYSUTCDATETIME()
    FROM [NOM].[CorridaNomina] c
    CROSS APPLY
    (
        SELECT
            COUNT(DISTINCT d.[FKIdPersona_NOM]) AS [TotalPersonas],
            COUNT(1) AS [TotalMovimientos],
            CAST(SUM(d.[Percepcion]) AS decimal(19,4)) AS [TotalPercepcion],
            CAST(SUM(d.[Deduccion]) AS decimal(19,4)) AS [TotalDeduccion],
            CAST(SUM(d.[Aportacion]) AS decimal(19,4)) AS [TotalAportacion],
            CAST(SUM(d.[Neto]) AS decimal(19,4)) AS [TotalNeto]
        FROM [NOM].[CorridaNominaDetalle] d
        WHERE d.[FKIdCorridaNomina_NOM] = @CorridaId
          AND d.[Activo] = 1
    ) resumen
    WHERE c.[PKIdCorridaNomina] = @CorridaId;

    COMMIT TRANSACTION;

    SELECT
        c.[PKIdCorridaNomina] AS [CorridaId],
        c.[FKIdEmpresaNomina_NOM] AS [EmpresaId],
        en.[RazonSocial] AS [EmpresaNombre],
        c.[IdPeriodo] AS [PeriodoId],
        c.[Anio],
        c.[TotalPersonas],
        c.[TotalMovimientos],
        c.[TotalPercepcion],
        c.[TotalDeduccion],
        c.[TotalAportacion],
        c.[TotalNeto],
        CAST(N'Calcular nomina' AS nvarchar(100)) AS [Proceso],
        CAST(N'SUCCESS' AS nvarchar(40)) AS [Codigo],
        CAST(1 AS bit) AS [Ejecutado],
        SYSUTCDATETIME() AS [FechaIntento],
        CAST(CONCAT(N'Corrida demo generada: ', c.[TotalPersonas], N' personas, ', c.[TotalMovimientos], N' movimientos.') AS nvarchar(500)) AS [Mensaje]
    FROM [NOM].[CorridaNomina] c
    LEFT JOIN [NOM].[EmpresaNomina] en
        ON en.[PKIdEmpresaNomina] = c.[FKIdEmpresaNomina_NOM]
    WHERE c.[PKIdCorridaNomina] = @CorridaId;
END
GO
