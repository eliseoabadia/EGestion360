USE [GestionEmpresarial];
GO

-- =============================================
-- SP: ALMA.SP_MantenimientoTipoBien
-- Descripción: Mantenimiento (Insert, Update, Delete lógico) de TipoBien.
-- =============================================
IF OBJECT_ID('ALMA.SP_MantenimientoTipoBien', 'P') IS NOT NULL 
    DROP PROCEDURE ALMA.SP_MantenimientoTipoBien;
GO

CREATE PROCEDURE ALMA.SP_MantenimientoTipoBien
    -- Acción: 1 = Insert, 2 = Update, 3 = Delete lógico
    @Action INT,
    -- Parámetros para Insert/Update
    @PKIdTipoBien INT = NULL,                    -- Necesario para Update
    @FKIdGrupoBien_ALMA INT = NULL,
    @FKIdNivel_ALMA INT = NULL,
    @FKIdPartida_CONTA INT = NULL,
    @FKIdCuentaContable_CONTA INT = NULL,
    @FKIdUnidades_ALMA INT = NULL,
    @FKIdLocalizacion_ALMA INT = NULL,
    @FKIdUnidades_Equivalente INT = NULL,
    @CodigoClave NVARCHAR(200) = NULL,
    @Descripcion NVARCHAR(1200) = NULL,
    @DepreciacionAnual DECIMAL(18,4) = NULL,
    @Consecutivo INT = NULL,
    @CABMS NVARCHAR(50) = NULL,
    @Identificador NVARCHAR(50) = NULL,
    @ExistenciaMinima DECIMAL(18,4) = NULL,
    @ExistenciaMaxima DECIMAL(18,4) = NULL,
    @TiempoVida INT = NULL,
    @Pk_IdTratadoInt INT = NULL,
    @Cuota NUMERIC(8,2) = NULL,
    @ProveeduriaNac BIT = NULL,
    @CatalogoBasico BIT = NULL,
    @CUCOP_PLUS VARCHAR(25) = NULL,
    @Cantidad_Equivalente INT = NULL,
    -- Parámetros de control
    @IdC INT = NULL,       -- ID para eliminar (Action=3)
    @IdUser INT = NULL,    -- Usuario que ejecuta la operación
    @Id INT = NULL OUTPUT  -- ID generado (para Insert) o afectado (para Delete)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    DECLARE @tipo NVARCHAR(100);
    DECLARE @message NVARCHAR(100);
    DECLARE @FKIdPartidaCalculada INT;
    DECLARE @CABMSCalculada VARCHAR(50);

    BEGIN TRY
        IF @Action = 1  -- INSERT
        BEGIN
            -- Obtener datos del grupo (partida y CABMS) si no se enviaron explícitamente
            --IF @FKIdPartida_CONTA IS NULL OR @CABMS IS NULL
            --BEGIN
            --    SELECT 
            --        @FKIdPartidaCalculada = gb.fk,
            --        @CABMSCalculada = gb.CABM_ACT
            --    FROM ALMA.GrupoBien gb
            --    WHERE gb.PKIdGrupoBien = @FKIdGrupoBien_ALMA;
            --END
            --ELSE
            --BEGIN
                SET @FKIdPartidaCalculada = @FKIdPartida_CONTA;
                SET @CABMSCalculada = @CABMS;
            --END

            BEGIN TRANSACTION;

            INSERT INTO ALMA.TipoBien (
                FKIdGrupoBien_ALMA,
                FKIdNivel_ALMA,
                FKIdPartida_CONTA,
                FKIdCuentaContable_CONTA,
                FKIdUnidades_ALMA,
                FKIdLocalizacion_ALMA,
                FKIdUnidades_Equivalente,
                CodigoClave,
                Descripcion,
                DepreciacionAnual,
                Consecutivo,
                CABMS,
                Identificador,
                ExistenciaMinima,
                ExistenciaMaxima,
                TiempoVida,
                Pk_IdTratadoInt,
                Cuota,
                ProveeduriaNac,
                CatalogoBasico,
                CUCOP_PLUS,
                Cantidad_Equivalente,
                Activo,
                FechaCreacion,
                UsuarioCreacion,
                FechaModificacion,
                UsuarioModificacion
            )
            VALUES (
                @FKIdGrupoBien_ALMA,
                @FKIdNivel_ALMA,
                @FKIdPartidaCalculada,
                @FKIdCuentaContable_CONTA,
                @FKIdUnidades_ALMA,
                @FKIdLocalizacion_ALMA,
                @FKIdUnidades_Equivalente,
                @CodigoClave,
                @Descripcion,
                @DepreciacionAnual,
                @Consecutivo,
                @CABMSCalculada,
                @Identificador,
                @ExistenciaMinima,
                @ExistenciaMaxima,
                @TiempoVida,
                @Pk_IdTratadoInt,
                @Cuota,
                @ProveeduriaNac,
                @CatalogoBasico,
                @CUCOP_PLUS,
                @Cantidad_Equivalente,
                1,                                  -- Activo = 1
                GETDATE(),                          -- FechaCreacion
                @IdUser,                            -- UsuarioCreacion
                NULL,                               -- FechaModificacion
                NULL                                -- UsuarioModificacion
            );

            SET @Id = SCOPE_IDENTITY();

            SET @tipo = 'OK';
            SET @message = 'Los datos se han guardado correctamente.';
        END
        ELSE IF @Action = 2  -- UPDATE
        BEGIN
            BEGIN TRANSACTION;

            UPDATE ALMA.TipoBien
            SET 
                FKIdGrupoBien_ALMA = @FKIdGrupoBien_ALMA,
                FKIdNivel_ALMA = @FKIdNivel_ALMA,
                FKIdPartida_CONTA = @FKIdPartida_CONTA,
                FKIdCuentaContable_CONTA = @FKIdCuentaContable_CONTA,
                FKIdUnidades_ALMA = @FKIdUnidades_ALMA,
                FKIdLocalizacion_ALMA = @FKIdLocalizacion_ALMA,
                FKIdUnidades_Equivalente = @FKIdUnidades_Equivalente,
                CodigoClave = @CodigoClave,
                Descripcion = @Descripcion,
                DepreciacionAnual = @DepreciacionAnual,
                Consecutivo = @Consecutivo,
                CABMS = @CABMS,
                Identificador = @Identificador,
                ExistenciaMinima = @ExistenciaMinima,
                ExistenciaMaxima = @ExistenciaMaxima,
                TiempoVida = @TiempoVida,
                Pk_IdTratadoInt = @Pk_IdTratadoInt,
                Cuota = @Cuota,
                ProveeduriaNac = @ProveeduriaNac,
                CatalogoBasico = @CatalogoBasico,
                CUCOP_PLUS = @CUCOP_PLUS,
                Cantidad_Equivalente = @Cantidad_Equivalente,
                FechaModificacion = GETDATE(),
                UsuarioModificacion = @IdUser
            WHERE PKIdTipoBien = @PKIdTipoBien;

            SET @Id = @PKIdTipoBien;

            SET @tipo = 'OK';
            SET @message = 'Los datos se han actualizado correctamente.';
        END
        ELSE IF @Action = 3  -- DELETE lógico
        BEGIN
            BEGIN TRANSACTION;

            UPDATE ALMA.TipoBien
            SET 
                Activo = 0,
                FechaModificacion = GETDATE(),
                UsuarioModificacion = @IdUser
            WHERE PKIdTipoBien = @IdC;

            SET @Id = @IdC;

            SET @tipo = 'OK';
            SET @message = 'Registro eliminado correctamente.';
        END
        ELSE
        BEGIN
            SET @tipo = 'ERROR';
            SET @message = 'Acción no válida. Use 1=Insert, 2=Update, 3=Delete';
            GOTO ERR_HANDLER;
        END

        IF @@TRANCOUNT > 0 COMMIT TRANSACTION;

        SELECT JSON_QUERY(
            CONCAT('{"tipo":"', @tipo, '","mensaje":"', @message, '","liga":""}')
        ) AS ResultJson;

        RETURN 0;

    END TRY
    BEGIN CATCH
        ERR_HANDLER:
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage VARCHAR(MAX);
        SELECT @ErrorMessage = CONCAT(
            ISNULL(PROGRAM_NAME(), ''), CHAR(10),
            'Error: ', ERROR_MESSAGE(), CHAR(10),
            'Línea: ', ERROR_LINE()
        );

        SELECT JSON_QUERY(
            CONCAT('{"tipo":"ERROR","mensaje":"', @ErrorMessage, '","liga":""}')
        ) AS ResultJson;

        RETURN -1;
    END CATCH
END;
GO