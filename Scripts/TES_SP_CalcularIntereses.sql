SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [TES].[SP_CalcularIntereses]
    @PKIdInversion INT,
    @IdUser INT = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @today DATETIME2(7) = SYSDATETIME(),
        @tipo NVARCHAR(20) = N'OK',
        @message NVARCHAR(MAX) = N'',
        @liga NVARCHAR(200) = N'',
        @FechaInicio DATE,
        @FechaFin DATE,
        @MontoInversion DECIMAL(20, 4),
        @TasaInteres DECIMAL(10, 4),
        @DiasPeriodo INT,
        @MontoInteres DECIMAL(20, 4),
        @RegistrosInsertados INT = 0;

    BEGIN TRY
        SELECT
            @FechaInicio = inv.FechaInversion,
            @FechaFin = inv.FechaVencimiento,
            @MontoInversion = inv.Monto,
            @TasaInteres = ISNULL(inst.TasaInteres, 0),
            @DiasPeriodo = COALESCE(NULLIF(inst.PlazoOriginal, 0), NULLIF(tp.Dias, 0))
        FROM TES.Inversion AS inv
        INNER JOIN TES.Instrumento AS inst
            ON inst.PKIdInstrumento = inv.FKIdInstrumento
            AND inst.Activo = 1
        LEFT JOIN TES.TipoPlazo AS tp
            ON tp.PKIdTipoPlazo = inst.FKIdTipoPlazo_TES
            AND tp.Activo = 1
        WHERE inv.PKIdInversion = @PKIdInversion
            AND inv.Activo = 1;

        IF @FechaInicio IS NULL
        BEGIN
            SELECT (SELECT 'ERROR' AS tipo, 'No se encontro una inversion activa para calcular intereses.' AS mensaje, '' AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
            RETURN -1;
        END

        IF @FechaFin IS NULL OR @FechaFin <= @FechaInicio
        BEGIN
            SELECT (SELECT 'ERROR' AS tipo, 'La inversion debe tener fecha de vencimiento mayor a la fecha de inversion.' AS mensaje, '' AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
            RETURN -1;
        END

        IF ISNULL(@DiasPeriodo, 0) <= 0
        BEGIN
            SELECT (SELECT 'ERROR' AS tipo, 'El instrumento debe tener plazo original o tipo de plazo con dias mayor a cero.' AS mensaje, '' AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
            RETURN -1;
        END

        SET @MontoInteres = ROUND(@MontoInversion * @TasaInteres / 100.0, 4);

        BEGIN TRANSACTION;

        UPDATE TES.Interes
        SET Activo = 0,
            FechaModificacion = @today,
            UsuarioModificacion = @IdUser
        WHERE FKIdInversion = @PKIdInversion
            AND Activo = 1;

        ;WITH Numeros AS
        (
            SELECT 0 AS N
            UNION ALL
            SELECT N + 1
            FROM Numeros
            WHERE DATEADD(DAY, (N + 1) * @DiasPeriodo, @FechaInicio) <= @FechaFin
        ),
        FechasInteres AS
        (
            SELECT DATEADD(DAY, N * @DiasPeriodo, @FechaInicio) AS FechaGeneracion
            FROM Numeros
        )
        INSERT INTO TES.Interes
        (
            FKIdInversion,
            Monto,
            FechaGeneracion,
            Activo,
            FechaCreacion,
            UsuarioCreacion
        )
        SELECT
            @PKIdInversion,
            @MontoInteres,
            f.FechaGeneracion,
            1,
            @today,
            @IdUser
        FROM FechasInteres AS f
        OPTION (MAXRECURSION 32767);

        SET @RegistrosInsertados = @@ROWCOUNT;
        SET @message = CONCAT('Se realizo el calculo de intereses correctamente. Registros insertados: ', @RegistrosInsertados, '.');
        SET @liga = CONCAT('idInversion:', @PKIdInversion);

        COMMIT TRANSACTION;

        SELECT (SELECT @tipo AS tipo, @message AS mensaje, @liga AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @tipo = N'ERROR';
        SET @message = CONCAT(ISNULL(PROGRAM_NAME(), ''), CHAR(10), 'Error: ', ERROR_MESSAGE(), CHAR(10), 'Linea: ', ERROR_LINE());

        EXEC [SIS].[WriteSystemLog]
            @FK_IdOrigenLogMessage__SIS = 1,
            @Date = @today,
            @_Type = 1,
            @ProgName = 'TES.SP_CalcularIntereses',
            @EmployeeNo = @IdUser,
            @Category = NULL,
            @IPClient = NULL,
            @HostName = NULL,
            @Thread = NULL,
            @Level = 'ERROR',
            @Logger = NULL,
            @Message = @message,
            @Exception = NULL,
            @Context = NULL,
            @MethodName = 'TES.SP_CalcularIntereses',
            @Parameters = CONCAT('PKIdInversion=', ISNULL(CONVERT(NVARCHAR(30), @PKIdInversion), 'NULL')),
            @ExecutionTime = '0';

        SELECT (SELECT @tipo AS tipo, @message AS mensaje, '' AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN -1;
    END CATCH
END
GO
