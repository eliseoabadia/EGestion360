/*
    TES.Instrumento
    - La vista [TES].[Vw_Instrumento] ya existe en Scripts\Vista.sql y Scripts\Vistas.sql.
    - Este script agrega el SP de mantenimiento faltante para alta, actualizacion y baja logica.
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [TES].[SP_MantenimientoInstrumento]
    @Action INT,
    @PKIdInstrumento INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdTipoInversion_TES INT = NULL,
    @FKIdIntermediarioFinanciero_TES INT = NULL,
    @FKIdTipoPlazo_TES INT = NULL,
    @FKIdTipoMoneda_TES INT = NULL,
    @Nombre NVARCHAR(200) = NULL,
    @TasaInteres DECIMAL(10, 4) = NULL,
    @PlazoOriginal INT = NULL,
    @FechaEmision DATE = NULL,
    @FechaVencimiento DATE = NULL,
    @MontoMinimo dbo.dmoney = NULL,
    @Observaciones NVARCHAR(MAX) = NULL,
    @Activo BIT = NULL,
    @IdUser INT,
    @Id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Msg NVARCHAR(4000);

    BEGIN TRY
        IF @Action NOT IN (1, 2, 3)
            THROW 51000, 'Accion no valida para el mantenimiento de instrumentos.', 1;

        IF @IdUser IS NULL
            THROW 51000, 'El usuario es requerido para el mantenimiento de instrumentos.', 1;

        IF @Action IN (1, 2)
        BEGIN
            SET @Nombre = NULLIF(LTRIM(RTRIM(@Nombre)), N'');

            IF @Nombre IS NULL
                THROW 51000, 'El nombre del instrumento es requerido.', 1;

            IF @FKIdEmpresa_SIS IS NULL
                THROW 51000, 'La empresa es requerida.', 1;

            IF @FKIdTipoInversion_TES IS NULL
                THROW 51000, 'El tipo de inversion es requerido.', 1;

            IF @FKIdIntermediarioFinanciero_TES IS NULL
                THROW 51000, 'El intermediario financiero es requerido.', 1;

            IF @FKIdTipoMoneda_TES IS NULL
                THROW 51000, 'La moneda es requerida.', 1;

            IF NOT EXISTS (SELECT 1 FROM [SIS].[Empresa] WHERE [PKIdEmpresa] = @FKIdEmpresa_SIS AND [Activo] = 1)
                THROW 51000, 'La empresa no existe o esta inactiva.', 1;

            IF NOT EXISTS (SELECT 1 FROM [TES].[TipoInversion] WHERE [PKIdTipoInversion] = @FKIdTipoInversion_TES AND [Activo] = 1)
                THROW 51000, 'El tipo de inversion no existe o esta inactivo.', 1;

            IF NOT EXISTS (SELECT 1 FROM [TES].[IntermediarioFinanciero] WHERE [PKIdIntermediarioFinanciero] = @FKIdIntermediarioFinanciero_TES AND [Activo] = 1)
                THROW 51000, 'El intermediario financiero no existe o esta inactivo.', 1;

            IF @FKIdTipoPlazo_TES IS NOT NULL
                AND NOT EXISTS (SELECT 1 FROM [TES].[TipoPlazo] WHERE [PKIdTipoPlazo] = @FKIdTipoPlazo_TES AND [Activo] = 1)
                THROW 51000, 'El tipo de plazo no existe o esta inactivo.', 1;

            IF NOT EXISTS (SELECT 1 FROM [TES].[TipoMoneda] WHERE [PKIdTipoMoneda] = @FKIdTipoMoneda_TES AND [Activo] = 1)
                THROW 51000, 'La moneda no existe o esta inactiva.', 1;

            IF @TasaInteres IS NOT NULL AND @TasaInteres < 0
                THROW 51000, 'La tasa de interes no puede ser negativa.', 1;

            IF @PlazoOriginal IS NOT NULL AND @PlazoOriginal < 0
                THROW 51000, 'El plazo original no puede ser negativo.', 1;

            IF @MontoMinimo IS NOT NULL AND @MontoMinimo < 0
                THROW 51000, 'El monto minimo no puede ser negativo.', 1;

            IF @FechaEmision IS NOT NULL
                AND @FechaVencimiento IS NOT NULL
                AND @FechaVencimiento < @FechaEmision
                THROW 51000, 'La fecha de vencimiento no puede ser menor a la fecha de emision.', 1;
        END

        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            INSERT INTO [TES].[Instrumento]
            (
                [FKIdEmpresa_SIS],
                [FKIdTipoInversion_TES],
                [FKIdIntermediarioFinanciero_TES],
                [FKIdTipoPlazo_TES],
                [FKIdTipoMoneda_TES],
                [Nombre],
                [TasaInteres],
                [PlazoOriginal],
                [FechaEmision],
                [FechaVencimiento],
                [MontoMinimo],
                [Observaciones],
                [Activo],
                [FechaCreacion],
                [UsuarioCreacion]
            )
            VALUES
            (
                @FKIdEmpresa_SIS,
                @FKIdTipoInversion_TES,
                @FKIdIntermediarioFinanciero_TES,
                @FKIdTipoPlazo_TES,
                @FKIdTipoMoneda_TES,
                @Nombre,
                @TasaInteres,
                @PlazoOriginal,
                @FechaEmision,
                @FechaVencimiento,
                @MontoMinimo,
                @Observaciones,
                ISNULL(@Activo, 1),
                SYSDATETIME(),
                @IdUser
            );

            SET @Id = CONVERT(INT, SCOPE_IDENTITY());
            SET @Msg = N'Instrumento creado correctamente.';
        END

        IF @Action = 2
        BEGIN
            IF @PKIdInstrumento IS NULL
                THROW 51000, 'El identificador del instrumento es requerido para actualizar.', 1;

            IF NOT EXISTS (SELECT 1 FROM [TES].[Instrumento] WHERE [PKIdInstrumento] = @PKIdInstrumento AND [Activo] = 1)
                THROW 51000, 'El instrumento no existe o esta inactivo.', 1;

            UPDATE [TES].[Instrumento]
            SET [FKIdEmpresa_SIS] = @FKIdEmpresa_SIS,
                [FKIdTipoInversion_TES] = @FKIdTipoInversion_TES,
                [FKIdIntermediarioFinanciero_TES] = @FKIdIntermediarioFinanciero_TES,
                [FKIdTipoPlazo_TES] = @FKIdTipoPlazo_TES,
                [FKIdTipoMoneda_TES] = @FKIdTipoMoneda_TES,
                [Nombre] = @Nombre,
                [TasaInteres] = @TasaInteres,
                [PlazoOriginal] = @PlazoOriginal,
                [FechaEmision] = @FechaEmision,
                [FechaVencimiento] = @FechaVencimiento,
                [MontoMinimo] = @MontoMinimo,
                [Observaciones] = @Observaciones,
                [Activo] = ISNULL(@Activo, [Activo]),
                [FechaModificacion] = SYSDATETIME(),
                [UsuarioModificacion] = @IdUser
            WHERE [PKIdInstrumento] = @PKIdInstrumento
              AND [Activo] = 1;

            SET @Id = @PKIdInstrumento;
            SET @Msg = N'Instrumento actualizado correctamente.';
        END

        IF @Action = 3
        BEGIN
            IF @PKIdInstrumento IS NULL
                THROW 51000, 'El identificador del instrumento es requerido para eliminar.', 1;

            IF NOT EXISTS (SELECT 1 FROM [TES].[Instrumento] WHERE [PKIdInstrumento] = @PKIdInstrumento AND [Activo] = 1)
                THROW 51000, 'El instrumento no existe o ya esta inactivo.', 1;

            IF EXISTS (SELECT 1 FROM [TES].[Inversion] WHERE [FKIdInstrumento] = @PKIdInstrumento AND [Activo] = 1)
                THROW 51000, 'No se puede eliminar el instrumento porque tiene inversiones activas relacionadas.', 1;

            UPDATE [TES].[Instrumento]
            SET [Activo] = 0,
                [FechaModificacion] = SYSDATETIME(),
                [UsuarioModificacion] = @IdUser
            WHERE [PKIdInstrumento] = @PKIdInstrumento
              AND [Activo] = 1;

            SET @Id = @PKIdInstrumento;
            SET @Msg = N'Instrumento eliminado correctamente.';
        END

        COMMIT TRANSACTION;

        SELECT ResultJson = (
            SELECT N'success' AS Tipo,
                   @Msg AS Mensaje,
                   CONCAT(N'id:', @Id) AS Liga
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT ResultJson = (
            SELECT N'error' AS Tipo,
                   ERROR_MESSAGE() AS Mensaje,
                   NULL AS Liga
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
    END CATCH
END;
GO

/*
    Seguridad y menu para la pantalla de consulta:
    /Presupuesto/Tesoreria/Instrumentos_Inversion
*/

IF OBJECT_ID(N'dbo.AspNetClaims', N'U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM dbo.AspNetClaims WHERE ReferenceId = 204)
    BEGIN
        UPDATE dbo.AspNetClaims
        SET
            Name = 'Tesoreria',
            [Group] = 'Tesoreria',
            SubGroup = 'Instrumentos_Inversion',
            Code = 'PRETIS04',
            [Description] = 'Instrumentos de Inversion',
            [Values] = 'view,view-menu,CanExportToExcel'
        WHERE ReferenceId = 204;
    END
    ELSE IF EXISTS (
        SELECT 1
        FROM dbo.AspNetClaims
        WHERE [Group] = 'Inversiones'
          AND SubGroup = 'Instrumentos_Inversion'
    )
    BEGIN
        UPDATE dbo.AspNetClaims
        SET
            Name = 'Tesoreria',
            [Group] = 'Tesoreria',
            Code = 'PRETIS04',
            [Description] = 'Instrumentos de Inversion',
            [Values] = 'view,view-menu,CanExportToExcel',
            ReferenceId = 204
        WHERE [Group] = 'Inversiones'
          AND SubGroup = 'Instrumentos_Inversion';
    END
    ELSE IF NOT EXISTS (
        SELECT 1
        FROM dbo.AspNetClaims
        WHERE [Group] = 'Tesoreria'
          AND SubGroup = 'Instrumentos_Inversion'
    )
    BEGIN
        INSERT INTO dbo.AspNetClaims
        (
            ClaimTypeId,
            Name,
            [Group],
            RoleId,
            TokenFormat,
            Created,
            SubGroup,
            Code,
            [Description],
            [Values],
            ReferenceId
        )
        VALUES
        (
            2,
            'Tesoreria',
            'Tesoreria',
            NULL,
            'app://{0}/{1}',
            GETDATE(),
            'Instrumentos_Inversion',
            'PRETIS04',
            'Instrumentos de Inversion',
            'view,view-menu,CanExportToExcel',
            204
        );
    END
END
GO

IF OBJECT_ID(N'dbo.spConfiguracionDeRolYClaims', N'P') IS NOT NULL
BEGIN
    EXEC dbo.spConfiguracionDeRolYClaims
        'Tesoreria',
        'Instrumentos_Inversion',
        '10000',
        'view,view-menu,CanExportToExcel';
END
GO

IF OBJECT_ID(N'SIS.Menu', N'U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM SIS.Menu WHERE PKIdMenu = 204)
    BEGIN
        UPDATE SIS.Menu
        SET
            Nombre = N'Instrumentos de Inversion',
            Tipo = 2,
            FKIdMenu_SIS = 200,
            LegacyName = N'Instrumentos de Inversion',
            Ruta = N'/Presupuesto/Tesoreria/Instrumentos_Inversion',
            ImageUrl = N'FaChartPie',
            Activo = 1,
            Lenguaje = N'ESP',
            [Orden] = 4,
            ModifiedByOperatorId = 1,
            ModifiedDateTime = GETDATE()
        WHERE PKIdMenu = 204;
    END
    ELSE
    BEGIN
        SET IDENTITY_INSERT SIS.Menu ON;

        INSERT INTO SIS.Menu
        (
            PKIdMenu,
            Nombre,
            Tipo,
            FKIdMenu_SIS,
            LegacyName,
            Ruta,
            ImageUrl,
            Activo,
            Lenguaje,
            [Orden],
            CreatedByOperatorId,
            CreatedDateTime
        )
        VALUES
        (
            204,
            N'Instrumentos de Inversion',
            2,
            200,
            N'Instrumentos de Inversion',
            N'/Presupuesto/Tesoreria/Instrumentos_Inversion',
            N'FaChartPie',
            1,
            N'ESP',
            4,
            1,
            GETDATE()
        );

        SET IDENTITY_INSERT SIS.Menu OFF;
    END
END
GO

IF OBJECT_ID(N'SIS.MenuRole', N'U') IS NOT NULL
   AND EXISTS (SELECT 1 FROM dbo.AspNetRoles WHERE Id = N'10000')
   AND EXISTS (SELECT 1 FROM SIS.Menu WHERE PKIdMenu = 204)
BEGIN
    MERGE SIS.MenuRole AS target
    USING (
        SELECT 204 AS FKIdMenu_SIS, N'10000' AS RoleId
    ) AS source
    ON target.FKIdMenu_SIS = source.FKIdMenu_SIS
   AND target.RoleId = source.RoleId
    WHEN MATCHED THEN UPDATE SET
        target.Activo = 1,
        target.ModifiedByOperatorId = 1,
        target.ModifiedDateTime = GETDATE()
    WHEN NOT MATCHED THEN INSERT
    (
        FKIdMenu_SIS,
        RoleId,
        Activo,
        CreatedByOperatorId,
        CreatedDateTime
    )
    VALUES
    (
        source.FKIdMenu_SIS,
        source.RoleId,
        1,
        1,
        GETDATE()
    );
END
GO
