-- Procesos de compatibilidad para Nomina.
-- No sustituyen la logica fiscal completa legacy; habilitan flujo operativo
-- sobre las tablas NOM migradas mientras se adapta el calculo definitivo.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF SCHEMA_ID(N'NOM') IS NULL
    EXEC(N'CREATE SCHEMA NOM');
GO

/*
    Compatibilidad para bases donde NOM.CorridaNomina ya existia con la
    columna normalizada anterior FKIdEmpresaNomina_NOM. Los SP de procesos
    operan contra SIS.Empresa mediante FKIdEmpresa_SIS.
*/
IF OBJECT_ID(N'[NOM].[CorridaNomina]', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH(N'NOM.CorridaNomina', N'FKIdEmpresa_SIS') IS NULL
    BEGIN
        ALTER TABLE [NOM].[CorridaNomina]
            ADD [FKIdEmpresa_SIS] int NULL;
    END;

    IF COL_LENGTH(N'NOM.CorridaNomina', N'FKIdEmpresaNomina_NOM') IS NOT NULL
    BEGIN
        IF COLUMNPROPERTY(OBJECT_ID(N'NOM.CorridaNomina'), N'FKIdEmpresaNomina_NOM', 'AllowsNull') = 0
        BEGIN
            ALTER TABLE [NOM].[CorridaNomina]
                ALTER COLUMN [FKIdEmpresaNomina_NOM] int NULL;
        END;

        EXEC(N'
            UPDATE [NOM].[CorridaNomina]
            SET [FKIdEmpresa_SIS] = COALESCE([FKIdEmpresa_SIS], [FKIdEmpresaNomina_NOM])
            WHERE [FKIdEmpresa_SIS] IS NULL;
        ');
    END;
END;
GO

CREATE OR ALTER PROCEDURE [NOM].[spProcesoNomina_ResolverContexto]
    @EmpresaId int OUTPUT,
    @PeriodoId int OUTPUT,
    @Anio int OUTPUT,
    @FechaProceso date OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @FechaProceso IS NULL
        SET @FechaProceso = CONVERT(date, GETDATE());

    IF @Anio IS NULL
        SET @Anio = YEAR(@FechaProceso);

    IF @EmpresaId IS NULL
    BEGIN
        SELECT TOP (1) @EmpresaId = [PKIdEmpresa]
        FROM [SIS].[Empresa]
        WHERE [Activo] = 1
        ORDER BY [PKIdEmpresa];
    END

    IF @EmpresaId IS NULL
        THROW 51010, 'No hay empresa de nomina disponible para ejecutar el proceso.', 1;

    IF @PeriodoId IS NULL
    BEGIN
        SELECT TOP (1) @PeriodoId = [IdPeriodo]
        FROM [NOM].[PeriodoActivo]
        WHERE [FKIdEmpresa_SIS] = @EmpresaId
          AND [Activo] = 1
        ORDER BY [EstaCerrado], [IdPeriodo] DESC;
    END

    IF @PeriodoId IS NULL
        SET @PeriodoId = (DATEPART(month, @FechaProceso) * 2) - CASE WHEN DATEPART(day, @FechaProceso) <= 15 THEN 1 ELSE 0 END;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[spProcesoNomina_AsegurarConcepto]
    @Clave nchar(4),
    @Nombre nvarchar(500),
    @UsuarioId int = NULL,
    @ConceptoId int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1) @ConceptoId = [PKIdConcepto]
    FROM [NOM].[Concepto]
    WHERE [Clave] = @Clave
      AND [SubClave] = N'0000'
      AND [Activo] = 1
    ORDER BY [PKIdConcepto];

    IF @ConceptoId IS NULL
    BEGIN
        INSERT INTO [NOM].[Concepto]
            ([Clave], [SubClave], [PerDed], [Nombre], [FKIdFormaCalculo_NOM], [UsuarioCreacion], [FechaCreacion], [Activo])
        VALUES
            (@Clave, N'0000', N'P', @Nombre, 0, @UsuarioId, SYSUTCDATETIME(), 1);

        SET @ConceptoId = SCOPE_IDENTITY();
    END
END
GO

CREATE OR ALTER PROCEDURE [NOM].[spProcesoNomina_ActualizarTotales]
    @CorridaId int
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE c
        SET [TotalPersonas] = COALESCE(resumen.[TotalPersonas], 0),
            [TotalMovimientos] = COALESCE(resumen.[TotalMovimientos], 0),
            [TotalPercepcion] = COALESCE(resumen.[TotalPercepcion], 0),
            [TotalDeduccion] = COALESCE(resumen.[TotalDeduccion], 0),
            [TotalAportacion] = COALESCE(resumen.[TotalAportacion], 0),
            [TotalNeto] = COALESCE(resumen.[TotalNeto], 0),
            [FechaModificacion] = SYSUTCDATETIME()
    FROM [NOM].[CorridaNomina] c
    OUTER APPLY
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
END
GO

CREATE OR ALTER PROCEDURE [NOM].[spProcesoNomina_Resultado]
    @Proceso nvarchar(100),
    @Codigo nvarchar(40),
    @Ejecutado bit,
    @Mensaje nvarchar(500),
    @CorridaId int = NULL,
    @EmpresaId int = NULL,
    @PeriodoId int = NULL,
    @Anio int = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @EmpresaNombre nvarchar(250) = N'',
        @TotalPersonas int = 0,
        @TotalMovimientos int = 0,
        @TotalPercepcion decimal(19,4) = 0,
        @TotalDeduccion decimal(19,4) = 0,
        @TotalAportacion decimal(19,4) = 0,
        @TotalNeto decimal(19,4) = 0;

    SELECT TOP (1)
        @CorridaId = c.[PKIdCorridaNomina],
        @EmpresaId = c.[FKIdEmpresa_SIS],
        @EmpresaNombre = COALESCE(en.[RazonSocial], N''),
        @PeriodoId = c.[IdPeriodo],
        @Anio = c.[Anio],
        @TotalPersonas = c.[TotalPersonas],
        @TotalMovimientos = c.[TotalMovimientos],
        @TotalPercepcion = c.[TotalPercepcion],
        @TotalDeduccion = c.[TotalDeduccion],
        @TotalAportacion = c.[TotalAportacion],
        @TotalNeto = c.[TotalNeto]
    FROM [NOM].[CorridaNomina] c
    LEFT JOIN [SIS].[Empresa] en
        ON en.[PKIdEmpresa] = c.[FKIdEmpresa_SIS]
    WHERE c.[Activo] = 1
      AND (@CorridaId IS NULL OR c.[PKIdCorridaNomina] = @CorridaId)
      AND (@EmpresaId IS NULL OR c.[FKIdEmpresa_SIS] = @EmpresaId)
      AND (@PeriodoId IS NULL OR c.[IdPeriodo] = @PeriodoId)
    ORDER BY
        CASE WHEN @CorridaId IS NOT NULL AND c.[PKIdCorridaNomina] = @CorridaId THEN 0 ELSE 1 END,
        c.[FechaModificacion] DESC,
        c.[FechaCreacion] DESC,
        c.[PKIdCorridaNomina] DESC;

    IF @EmpresaId IS NOT NULL AND @EmpresaNombre = N''
    BEGIN
        SELECT @EmpresaNombre = COALESCE([RazonSocial], N'')
        FROM [SIS].[Empresa]
        WHERE [PKIdEmpresa] = @EmpresaId;
    END

    SELECT
        @CorridaId AS [CorridaId],
        @EmpresaId AS [EmpresaId],
        COALESCE(@EmpresaNombre, N'') AS [EmpresaNombre],
        @PeriodoId AS [PeriodoId],
        @Anio AS [Anio],
        COALESCE(@TotalPersonas, 0) AS [TotalPersonas],
        COALESCE(@TotalMovimientos, 0) AS [TotalMovimientos],
        COALESCE(@TotalPercepcion, 0) AS [TotalPercepcion],
        COALESCE(@TotalDeduccion, 0) AS [TotalDeduccion],
        COALESCE(@TotalAportacion, 0) AS [TotalAportacion],
        COALESCE(@TotalNeto, 0) AS [TotalNeto],
        @Proceso AS [Proceso],
        @Codigo AS [Codigo],
        @Ejecutado AS [Ejecutado],
        SYSUTCDATETIME() AS [FechaIntento],
        @Mensaje AS [Mensaje];
END
GO

CREATE OR ALTER PROCEDURE [NOM].[spProcesoNomina_Calcular]
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

    EXEC [NOM].[spCorridaNomina_Demo]
        @EmpresaId = @EmpresaId,
        @PeriodoId = @PeriodoId,
        @PersonaId = @PersonaId,
        @Anio = @Anio,
        @FechaProceso = @FechaProceso,
        @Observaciones = @Observaciones,
        @UsuarioId = @UsuarioId;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[spProcesoNomina_CerrarPeriodo]
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

    EXEC [NOM].[spProcesoNomina_ResolverContexto]
        @EmpresaId = @EmpresaId OUTPUT,
        @PeriodoId = @PeriodoId OUTPUT,
        @Anio = @Anio OUTPUT,
        @FechaProceso = @FechaProceso OUTPUT;

    DECLARE @CorridaId int;

    BEGIN TRANSACTION;

    IF NOT EXISTS
    (
        SELECT 1
        FROM [NOM].[PeriodoActivo]
        WHERE [FKIdEmpresa_SIS] = @EmpresaId
          AND [IdPeriodo] = @PeriodoId
          AND [Activo] = 1
    )
    BEGIN
        INSERT INTO [NOM].[PeriodoActivo]
            ([FKIdEmpresa_SIS], [IdPeriodo], [EstaCerrado], [UsuarioCreacion], [FechaCreacion], [Activo], [EstaComprometido], [EstaDevengado], [EstaEjercido])
        VALUES
            (@EmpresaId, @PeriodoId, 1, @UsuarioId, SYSUTCDATETIME(), 1, 0, 0, 0);
    END
    ELSE
    BEGIN
        UPDATE [NOM].[PeriodoActivo]
            SET [EstaCerrado] = 1,
                [UsuarioModificacion] = @UsuarioId,
                [FechaModificacion] = SYSUTCDATETIME()
        WHERE [FKIdEmpresa_SIS] = @EmpresaId
          AND [IdPeriodo] = @PeriodoId
          AND [Activo] = 1;
    END

    UPDATE [NOM].[CorridaNomina]
        SET [Estatus] = N'Cerrada',
            [UsuarioModificacion] = @UsuarioId,
            [FechaModificacion] = SYSUTCDATETIME()
    WHERE [FKIdEmpresa_SIS] = @EmpresaId
      AND [IdPeriodo] = @PeriodoId
      AND [Activo] = 1;

    SELECT TOP (1) @CorridaId = [PKIdCorridaNomina]
    FROM [NOM].[CorridaNomina]
    WHERE [FKIdEmpresa_SIS] = @EmpresaId
      AND [IdPeriodo] = @PeriodoId
      AND [Activo] = 1
    ORDER BY [FechaModificacion] DESC, [FechaCreacion] DESC, [PKIdCorridaNomina] DESC;

    COMMIT TRANSACTION;

    EXEC [NOM].[spProcesoNomina_Resultado]
        @Proceso = N'Cerrar periodo',
        @Codigo = N'SUCCESS',
        @Ejecutado = 1,
        @Mensaje = N'Periodo cerrado correctamente.',
        @CorridaId = @CorridaId,
        @EmpresaId = @EmpresaId,
        @PeriodoId = @PeriodoId,
        @Anio = @Anio;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[spProcesoNomina_CalcularAguinaldo]
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

    EXEC [NOM].[spProcesoNomina_ResolverContexto]
        @EmpresaId = @EmpresaId OUTPUT,
        @PeriodoId = @PeriodoId OUTPUT,
        @Anio = @Anio OUTPUT,
        @FechaProceso = @FechaProceso OUTPUT;

    DECLARE @ConceptoId int;
    EXEC [NOM].[spProcesoNomina_AsegurarConcepto]
        @Clave = N'AGUI',
        @Nombre = N'Aguinaldo',
        @UsuarioId = @UsuarioId,
        @ConceptoId = @ConceptoId OUTPUT;

    DECLARE @CorridaId int;

    BEGIN TRANSACTION;

    SELECT @CorridaId = [PKIdCorridaNomina]
    FROM [NOM].[CorridaNomina]
    WHERE [FKIdEmpresa_SIS] = @EmpresaId
      AND [IdPeriodo] = @PeriodoId
      AND [TipoCorrida] = N'AGUINALDO'
      AND [Activo] = 1;

    IF @CorridaId IS NULL
    BEGIN
        INSERT INTO [NOM].[CorridaNomina]
            ([FKIdEmpresa_SIS], [IdPeriodo], [Anio], [TipoCorrida], [Estatus], [FechaProceso], [Observaciones], [UsuarioCreacion], [FechaCreacion], [Activo])
        VALUES
            (@EmpresaId, @PeriodoId, @Anio, N'AGUINALDO', N'Calculada', @FechaProceso, @Observaciones, @UsuarioId, SYSUTCDATETIME(), 1);

        SET @CorridaId = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE [NOM].[CorridaNomina]
            SET [Anio] = @Anio,
                [Estatus] = N'Calculada',
                [FechaProceso] = @FechaProceso,
                [Observaciones] = @Observaciones,
                [UsuarioModificacion] = @UsuarioId,
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
        c.[PersonaId],
        c.[PKIdContratoLaboral],
        c.[PuestoId],
        @ConceptoId,
        N'AGUI',
        N'Aguinaldo',
        N'Percepcion',
        CAST(ROUND((COALESCE(c.[SueldoMensual], 0) / 30.0) * 15.0, 4) AS decimal(19,4)),
        CAST(0 AS decimal(19,4)),
        CAST(0 AS decimal(19,4)),
        CAST(ROUND((COALESCE(c.[SueldoMensual], 0) / 30.0) * 15.0, 4) AS decimal(19,4)),
        N'15 dias compatibilidad',
        N'PROCESO_COMPAT',
        @UsuarioId,
        SYSUTCDATETIME(),
        1
    FROM [NOM].[Vw_ContratoLaboral] c
    WHERE c.[EmpresaNominaId] = @EmpresaId
      AND c.[Activo] = 1
      AND c.[Vigente] = 1
      AND COALESCE(c.[SueldoMensual], 0) > 0
      AND (@PersonaId IS NULL OR c.[PersonaId] = @PersonaId);

    IF @@ROWCOUNT = 0
        THROW 51011, 'No hay contratos vigentes con sueldo para calcular aguinaldo.', 1;

    EXEC [NOM].[spProcesoNomina_ActualizarTotales] @CorridaId = @CorridaId;

    COMMIT TRANSACTION;

    EXEC [NOM].[spProcesoNomina_Resultado]
        @Proceso = N'Calcular aguinaldo',
        @Codigo = N'SUCCESS',
        @Ejecutado = 1,
        @Mensaje = N'Aguinaldo generado con regla de compatibilidad.',
        @CorridaId = @CorridaId,
        @EmpresaId = @EmpresaId,
        @PeriodoId = @PeriodoId,
        @Anio = @Anio;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[spProcesoNomina_PrimaVacacionalIndividual]
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

    IF @PersonaId IS NULL
        THROW 51012, 'La prima vacacional individual requiere PersonaId.', 1;

    EXEC [NOM].[spProcesoNomina_ResolverContexto]
        @EmpresaId = @EmpresaId OUTPUT,
        @PeriodoId = @PeriodoId OUTPUT,
        @Anio = @Anio OUTPUT,
        @FechaProceso = @FechaProceso OUTPUT;

    DECLARE @ConceptoId int;
    EXEC [NOM].[spProcesoNomina_AsegurarConcepto]
        @Clave = N'PVAC',
        @Nombre = N'Prima vacacional',
        @UsuarioId = @UsuarioId,
        @ConceptoId = @ConceptoId OUTPUT;

    DECLARE @CorridaId int;
    DECLARE @TipoCorrida nvarchar(30) = LEFT(CONCAT(N'PVAC_', @PersonaId), 30);

    BEGIN TRANSACTION;

    SELECT @CorridaId = [PKIdCorridaNomina]
    FROM [NOM].[CorridaNomina]
    WHERE [FKIdEmpresa_SIS] = @EmpresaId
      AND [IdPeriodo] = @PeriodoId
      AND [TipoCorrida] = @TipoCorrida
      AND [Activo] = 1;

    IF @CorridaId IS NULL
    BEGIN
        INSERT INTO [NOM].[CorridaNomina]
            ([FKIdEmpresa_SIS], [IdPeriodo], [Anio], [TipoCorrida], [Estatus], [FechaProceso], [Observaciones], [UsuarioCreacion], [FechaCreacion], [Activo])
        VALUES
            (@EmpresaId, @PeriodoId, @Anio, @TipoCorrida, N'Calculada', @FechaProceso, @Observaciones, @UsuarioId, SYSUTCDATETIME(), 1);

        SET @CorridaId = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE [NOM].[CorridaNomina]
            SET [Anio] = @Anio,
                [Estatus] = N'Calculada',
                [FechaProceso] = @FechaProceso,
                [Observaciones] = @Observaciones,
                [UsuarioModificacion] = @UsuarioId,
                [FechaModificacion] = SYSUTCDATETIME()
        WHERE [PKIdCorridaNomina] = @CorridaId;

        DELETE FROM [NOM].[CorridaNominaDetalle]
        WHERE [FKIdCorridaNomina_NOM] = @CorridaId;
    END

    INSERT INTO [NOM].[CorridaNominaDetalle]
        ([FKIdCorridaNomina_NOM], [FKIdPersona_NOM], [FKIdContratoLaboral_NOM], [FKIdPuesto_NOM], [FKIdConcepto_NOM],
         [ConceptoClave], [ConceptoNombre], [TipoMovimiento], [Percepcion], [Deduccion], [Aportacion], [Neto],
         [Referencia], [Origen], [UsuarioCreacion], [FechaCreacion], [Activo])
    SELECT TOP (1)
        @CorridaId,
        c.[PersonaId],
        c.[PKIdContratoLaboral],
        c.[PuestoId],
        @ConceptoId,
        N'PVAC',
        N'Prima vacacional',
        N'Percepcion',
        CAST(ROUND((COALESCE(c.[SueldoMensual], 0) / 30.0) * 6.0 * 0.25, 4) AS decimal(19,4)),
        CAST(0 AS decimal(19,4)),
        CAST(0 AS decimal(19,4)),
        CAST(ROUND((COALESCE(c.[SueldoMensual], 0) / 30.0) * 6.0 * 0.25, 4) AS decimal(19,4)),
        N'6 dias al 25% compatibilidad',
        N'PROCESO_COMPAT',
        @UsuarioId,
        SYSUTCDATETIME(),
        1
    FROM [NOM].[Vw_ContratoLaboral] c
    WHERE c.[EmpresaNominaId] = @EmpresaId
      AND c.[PersonaId] = @PersonaId
      AND c.[Activo] = 1
      AND c.[Vigente] = 1
      AND COALESCE(c.[SueldoMensual], 0) > 0
    ORDER BY c.[FechaInicio] DESC, c.[PKIdContratoLaboral] DESC;

    IF @@ROWCOUNT = 0
        THROW 51013, 'No hay contrato vigente con sueldo para calcular prima vacacional.', 1;

    EXEC [NOM].[spProcesoNomina_ActualizarTotales] @CorridaId = @CorridaId;

    COMMIT TRANSACTION;

    EXEC [NOM].[spProcesoNomina_Resultado]
        @Proceso = N'Calcular prima vacacional individual',
        @Codigo = N'SUCCESS',
        @Ejecutado = 1,
        @Mensaje = N'Prima vacacional individual generada con regla de compatibilidad.',
        @CorridaId = @CorridaId,
        @EmpresaId = @EmpresaId,
        @PeriodoId = @PeriodoId,
        @Anio = @Anio;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[spProcesoNomina_MarcarPresupuesto]
    @EmpresaId int = NULL,
    @PeriodoId int = NULL,
    @PersonaId int = NULL,
    @Anio int = NULL,
    @FechaProceso date = NULL,
    @Observaciones nvarchar(500) = NULL,
    @UsuarioId int = NULL,
    @Estado nvarchar(30),
    @Proceso nvarchar(100),
    @Mensaje nvarchar(500)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    EXEC [NOM].[spProcesoNomina_ResolverContexto]
        @EmpresaId = @EmpresaId OUTPUT,
        @PeriodoId = @PeriodoId OUTPUT,
        @Anio = @Anio OUTPUT,
        @FechaProceso = @FechaProceso OUTPUT;

    DECLARE @CorridaId int;

    BEGIN TRANSACTION;

    IF NOT EXISTS
    (
        SELECT 1
        FROM [NOM].[PeriodoActivo]
        WHERE [FKIdEmpresa_SIS] = @EmpresaId
          AND [IdPeriodo] = @PeriodoId
          AND [Activo] = 1
    )
    BEGIN
        INSERT INTO [NOM].[PeriodoActivo]
            ([FKIdEmpresa_SIS], [IdPeriodo], [EstaCerrado], [UsuarioCreacion], [FechaCreacion], [Activo], [EstaComprometido], [EstaDevengado], [EstaEjercido])
        VALUES
            (@EmpresaId, @PeriodoId, 0, @UsuarioId, SYSUTCDATETIME(), 1,
             CASE WHEN @Estado = N'Comprometida' THEN 1 ELSE 0 END,
             CASE WHEN @Estado = N'Devengada' THEN 1 ELSE 0 END,
             CASE WHEN @Estado = N'Ejercida' THEN 1 ELSE 0 END);
    END
    ELSE
    BEGIN
        UPDATE [NOM].[PeriodoActivo]
            SET [EstaComprometido] = CASE WHEN @Estado = N'Comprometida' THEN 1 ELSE COALESCE([EstaComprometido], 0) END,
                [EstaDevengado] = CASE WHEN @Estado = N'Devengada' THEN 1 ELSE COALESCE([EstaDevengado], 0) END,
                [EstaEjercido] = CASE WHEN @Estado = N'Ejercida' THEN 1 ELSE COALESCE([EstaEjercido], 0) END,
                [UsuarioModificacion] = @UsuarioId,
                [FechaModificacion] = SYSUTCDATETIME()
        WHERE [FKIdEmpresa_SIS] = @EmpresaId
          AND [IdPeriodo] = @PeriodoId
          AND [Activo] = 1;
    END

    UPDATE [NOM].[CorridaNomina]
        SET [Estatus] = @Estado,
            [UsuarioModificacion] = @UsuarioId,
            [FechaModificacion] = SYSUTCDATETIME()
    WHERE [FKIdEmpresa_SIS] = @EmpresaId
      AND [IdPeriodo] = @PeriodoId
      AND [Activo] = 1;

    SELECT TOP (1) @CorridaId = [PKIdCorridaNomina]
    FROM [NOM].[CorridaNomina]
    WHERE [FKIdEmpresa_SIS] = @EmpresaId
      AND [IdPeriodo] = @PeriodoId
      AND [Activo] = 1
    ORDER BY [FechaModificacion] DESC, [FechaCreacion] DESC, [PKIdCorridaNomina] DESC;

    COMMIT TRANSACTION;

    EXEC [NOM].[spProcesoNomina_Resultado]
        @Proceso = @Proceso,
        @Codigo = N'SUCCESS',
        @Ejecutado = 1,
        @Mensaje = @Mensaje,
        @CorridaId = @CorridaId,
        @EmpresaId = @EmpresaId,
        @PeriodoId = @PeriodoId,
        @Anio = @Anio;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[spProcesoNomina_CrearComprometido]
    @EmpresaId int = NULL,
    @PeriodoId int = NULL,
    @PersonaId int = NULL,
    @Anio int = NULL,
    @FechaProceso date = NULL,
    @Observaciones nvarchar(500) = NULL,
    @UsuarioId int = NULL
AS
BEGIN
    EXEC [NOM].[spProcesoNomina_MarcarPresupuesto]
        @EmpresaId = @EmpresaId,
        @PeriodoId = @PeriodoId,
        @PersonaId = @PersonaId,
        @Anio = @Anio,
        @FechaProceso = @FechaProceso,
        @Observaciones = @Observaciones,
        @UsuarioId = @UsuarioId,
        @Estado = N'Comprometida',
        @Proceso = N'Crear comprometido de nomina',
        @Mensaje = N'Comprometido de nomina marcado correctamente.';
END
GO

CREATE OR ALTER PROCEDURE [NOM].[spProcesoNomina_CrearDevengado]
    @EmpresaId int = NULL,
    @PeriodoId int = NULL,
    @PersonaId int = NULL,
    @Anio int = NULL,
    @FechaProceso date = NULL,
    @Observaciones nvarchar(500) = NULL,
    @UsuarioId int = NULL
AS
BEGIN
    EXEC [NOM].[spProcesoNomina_MarcarPresupuesto]
        @EmpresaId = @EmpresaId,
        @PeriodoId = @PeriodoId,
        @PersonaId = @PersonaId,
        @Anio = @Anio,
        @FechaProceso = @FechaProceso,
        @Observaciones = @Observaciones,
        @UsuarioId = @UsuarioId,
        @Estado = N'Devengada',
        @Proceso = N'Crear devengado de nomina',
        @Mensaje = N'Devengado de nomina marcado correctamente.';
END
GO

CREATE OR ALTER PROCEDURE [NOM].[spProcesoNomina_CrearEjercido]
    @EmpresaId int = NULL,
    @PeriodoId int = NULL,
    @PersonaId int = NULL,
    @Anio int = NULL,
    @FechaProceso date = NULL,
    @Observaciones nvarchar(500) = NULL,
    @UsuarioId int = NULL
AS
BEGIN
    EXEC [NOM].[spProcesoNomina_MarcarPresupuesto]
        @EmpresaId = @EmpresaId,
        @PeriodoId = @PeriodoId,
        @PersonaId = @PersonaId,
        @Anio = @Anio,
        @FechaProceso = @FechaProceso,
        @Observaciones = @Observaciones,
        @UsuarioId = @UsuarioId,
        @Estado = N'Ejercida',
        @Proceso = N'Crear ejercido de nomina',
        @Mensaje = N'Ejercido de nomina marcado correctamente.';
END
GO

PRINT N'Procesos de compatibilidad de Nomina creados correctamente.';
