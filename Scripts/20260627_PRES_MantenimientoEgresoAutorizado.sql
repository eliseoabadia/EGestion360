USE [GestionEmpresarial]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [PRES].[SP_MantenimientoEgresoAutorizado]
    @Action INT,
    @PKIdEgresoAutorizado INT = NULL,
    @FKIdPrograma_PRES INT = NULL,
    @FKIdFuenteFinanciamiento_PRES INT = NULL,
    @FKIdTipoGasto_PRES INT = NULL,
    @FKIdDigitoIdentificador_PRES INT = NULL,
    @FKIdDestinoGasto_PRES INT = NULL,
    @FKIdPY_PRES INT = NULL,
    @FKIdPartida_CONTA INT = NULL,
    @FKIdArea_SIS INT = NULL,
    @Descripcion NVARCHAR(250) = NULL,
    @Fecha DATE = NULL,
    @FKIdPoliza_CONTA INT = NULL,
    @Enero DECIMAL(18, 2) = 0,
    @Febrero DECIMAL(18, 2) = 0,
    @Marzo DECIMAL(18, 2) = 0,
    @Abril DECIMAL(18, 2) = 0,
    @Mayo DECIMAL(18, 2) = 0,
    @Junio DECIMAL(18, 2) = 0,
    @Julio DECIMAL(18, 2) = 0,
    @Agosto DECIMAL(18, 2) = 0,
    @Septiembre DECIMAL(18, 2) = 0,
    @Octubre DECIMAL(18, 2) = 0,
    @Noviembre DECIMAL(18, 2) = 0,
    @Diciembre DECIMAL(18, 2) = 0,
    @IdUser INT = NULL,
    @FKIdEgresoProyectado_PRES INT = NULL
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @Tipo NVARCHAR(20) = N'OK',
        @Mensaje NVARCHAR(MAX) = N'',
        @Liga NVARCHAR(100) = N'',
        @ErrorMessage NVARCHAR(MAX),
        @Hoy DATETIME2(7) = SYSDATETIME(),
        @IdMenu INT = 83,
        @AccionNotificacion INT = @Action,
        @FKIdAnio_SIS INT,
        @FKIdMes_SIS INT,
        @FKIdTipoPoliza_SIS INT = 1,
        @NombrePoliza NVARCHAR(1000),
        @ClavePoliza NVARCHAR(50),
        @ErrorPoliza NVARCHAR(MAX),
        @PolizaActual INT,
        @PolizaNueva INT,
        @CuentaAprobado INT,
        @CuentaPorEjercer INT,
        @Importe DECIMAL(18, 2),
        @Debe DECIMAL(18, 2),
        @Haber DECIMAL(18, 2);

    BEGIN TRY
        IF @Action NOT IN (1, 2, 3)
        BEGIN
            SET @Tipo = N'ERROR';
            SET @Mensaje = N'Accion no valida. Use 1=Insert, 2=Update, 3=Delete.';
            GOTO Finish;
        END

        IF @IdUser IS NULL OR @IdUser <= 0
        BEGIN
            SET @Tipo = N'ERROR';
            SET @Mensaje = N'No se recibio usuario para aplicar el mantenimiento.';
            GOTO Finish;
        END

        IF @Action IN (1, 2)
        BEGIN
            IF @FKIdPrograma_PRES IS NULL OR @FKIdPartida_CONTA IS NULL OR @FKIdArea_SIS IS NULL OR @Fecha IS NULL
            BEGIN
                SET @Tipo = N'ERROR';
                SET @Mensaje = N'Faltan datos obligatorios del presupuesto autorizado.';
                GOTO Finish;
            END

            SELECT @FKIdAnio_SIS = a.PKIdAnio
            FROM SIS.Anio AS a
            WHERE a.Clave = YEAR(@Fecha)
              AND a.Activo = 1;

            IF @FKIdAnio_SIS IS NULL
            BEGIN
                SET @Tipo = N'ERROR';
                SET @Mensaje = CONCAT(N'No existe anio presupuestal activo para ', YEAR(@Fecha), N'.');
                GOTO Finish;
            END

            SET @FKIdMes_SIS = MONTH(@Fecha);
            SET @NombrePoliza = CONCAT(N'Presupuesto de Egresos Autorizado: ', YEAR(@Fecha), N' ', ISNULL(@Descripcion, N''));
            SET @Importe = ISNULL(@Enero, 0) + ISNULL(@Febrero, 0) + ISNULL(@Marzo, 0) + ISNULL(@Abril, 0)
                + ISNULL(@Mayo, 0) + ISNULL(@Junio, 0) + ISNULL(@Julio, 0) + ISNULL(@Agosto, 0)
                + ISNULL(@Septiembre, 0) + ISNULL(@Octubre, 0) + ISNULL(@Noviembre, 0) + ISNULL(@Diciembre, 0);

            SELECT TOP (1)
                @CuentaAprobado = mc.FKIdCuentaContableAprobado,
                @CuentaPorEjercer = mc.FKIdCuentaContablePorEjercer
            FROM CONTA.MatrizConversion AS mc
            WHERE mc.FKIdAnio_SIS = @FKIdAnio_SIS
              AND mc.FKIdPrograma_PRES = @FKIdPrograma_PRES
              AND mc.FKIdPartida_SIS = @FKIdPartida_CONTA
              AND mc.Activo = 1;

            IF @CuentaAprobado IS NULL OR @CuentaPorEjercer IS NULL
            BEGIN
                SET @Tipo = N'ERROR';
                SET @Mensaje = CONCAT(
                    N'No existe matriz de conversion activa para programa ',
                    @FKIdPrograma_PRES,
                    N' y partida ',
                    @FKIdPartida_CONTA,
                    N'.');
                GOTO Finish;
            END
        END

        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            SET @PolizaNueva = NULLIF(@FKIdPoliza_CONTA, 0);

            IF @PolizaNueva IS NULL
                OR ISNULL((SELECT TOP (1) ClavePoliza FROM CONTA.Poliza WHERE PKIdPoliza = @PolizaNueva), N'') = N'NUEVA'
            BEGIN
                EXEC CONTA.SP_CREATE_ClavePoliza
                    @FK_IdAnio__SIS = @FKIdAnio_SIS,
                    @FK_IdMesConta__SIS = @FKIdMes_SIS,
                    @FK_IdTipoPolizaConta__SIS = @FKIdTipoPoliza_SIS,
                    @CT_ModifiedBy = @IdUser,
                    @ClavePoliza = @ClavePoliza OUTPUT,
                    @Error = @ErrorPoliza OUTPUT;

                IF ISNULL(@ClavePoliza, N'') = N''
                    THROW 51000, 'No se pudo generar la clave de poliza.', 1;

                INSERT INTO CONTA.Poliza (
                    FKIdAnio_SIS,
                    FKIdMes_SIS,
                    FKIdTipoPoliza_SIS,
                    ClavePoliza,
                    NombrePoliza,
                    FechaPoliza,
                    EstaBalanceado,
                    Activo,
                    FechaCreacion,
                    UsuarioCreacion,
                    PermitirModificar,
                    Autorizado
                )
                VALUES (
                    @FKIdAnio_SIS,
                    @FKIdMes_SIS,
                    @FKIdTipoPoliza_SIS,
                    @ClavePoliza,
                    @NombrePoliza,
                    @Fecha,
                    0,
                    1,
                    @Hoy,
                    @IdUser,
                    1,
                    0
                );

                SET @PolizaNueva = SCOPE_IDENTITY();
            END

            INSERT INTO PRES.EgresoAutorizado (
                FKIdPrograma_PRES,
                FKIdPartida_CONTA,
                FKIdArea_SIS,
                Descripcion,
                Fecha,
                FKIdPoliza_CONTA,
                Activo,
                FechaCreacion,
                UsuarioCreacion,
                FKIdEgresoProyectado_PRES,
                Enero,
                Febrero,
                Marzo,
                Abril,
                Mayo,
                Junio,
                Julio,
                Agosto,
                Septiembre,
                Octubre,
                Noviembre,
                Diciembre,
                FechaAutorizacion,
                UsuarioAutorizacion,
                FKIdFuenteFinanciamiento_PRES,
                FKIdTipoGasto_PRES,
                FKIdDigitoIdentificador_PRES,
                FKIdDestinoGasto_PRES,
                FKIdPY_PRES
            )
            VALUES (
                @FKIdPrograma_PRES,
                @FKIdPartida_CONTA,
                @FKIdArea_SIS,
                @Descripcion,
                @Fecha,
                @PolizaNueva,
                1,
                @Hoy,
                @IdUser,
                @FKIdEgresoProyectado_PRES,
                ISNULL(@Enero, 0),
                ISNULL(@Febrero, 0),
                ISNULL(@Marzo, 0),
                ISNULL(@Abril, 0),
                ISNULL(@Mayo, 0),
                ISNULL(@Junio, 0),
                ISNULL(@Julio, 0),
                ISNULL(@Agosto, 0),
                ISNULL(@Septiembre, 0),
                ISNULL(@Octubre, 0),
                ISNULL(@Noviembre, 0),
                ISNULL(@Diciembre, 0),
                @Hoy,
                @IdUser,
                @FKIdFuenteFinanciamiento_PRES,
                @FKIdTipoGasto_PRES,
                @FKIdDigitoIdentificador_PRES,
                @FKIdDestinoGasto_PRES,
                @FKIdPY_PRES
            );

            SET @PKIdEgresoAutorizado = SCOPE_IDENTITY();
            SET @FKIdPoliza_CONTA = @PolizaNueva;
            SET @Mensaje = CONCAT(N'Se registro correctamente el presupuesto autorizado de egresos ', @PKIdEgresoAutorizado, N'. Presupuesto afectado ', @Importe);
        END
        ELSE IF @Action = 2
        BEGIN
            SELECT @PolizaActual = ea.FKIdPoliza_CONTA
            FROM PRES.EgresoAutorizado AS ea
            WHERE ea.PKIdEgresoAutorizado = @PKIdEgresoAutorizado
              AND ea.Activo = 1;

            IF @PolizaActual IS NULL AND NOT EXISTS (
                SELECT 1 FROM PRES.EgresoAutorizado WHERE PKIdEgresoAutorizado = @PKIdEgresoAutorizado AND Activo = 1
            )
                THROW 51001, 'Presupuesto autorizado no encontrado.', 1;

            SET @PolizaNueva = COALESCE(NULLIF(@FKIdPoliza_CONTA, 0), @PolizaActual);

            UPDATE CONTA.PolizaDetalle
            SET Activo = 0,
                FechaModificacion = @Hoy,
                UsuarioModificacion = @IdUser
            WHERE FKIdReferencia = @PKIdEgresoAutorizado
              AND FKIdPoliza_CONTA IN (@PolizaActual, @PolizaNueva)
              AND Activo = 1;

            UPDATE PRES.EgresoAutorizado
            SET FKIdPrograma_PRES = @FKIdPrograma_PRES,
                FKIdFuenteFinanciamiento_PRES = @FKIdFuenteFinanciamiento_PRES,
                FKIdTipoGasto_PRES = @FKIdTipoGasto_PRES,
                FKIdDigitoIdentificador_PRES = @FKIdDigitoIdentificador_PRES,
                FKIdDestinoGasto_PRES = @FKIdDestinoGasto_PRES,
                FKIdPY_PRES = @FKIdPY_PRES,
                FKIdPartida_CONTA = @FKIdPartida_CONTA,
                FKIdArea_SIS = @FKIdArea_SIS,
                Descripcion = @Descripcion,
                Fecha = @Fecha,
                FKIdPoliza_CONTA = @PolizaNueva,
                Enero = ISNULL(@Enero, 0),
                Febrero = ISNULL(@Febrero, 0),
                Marzo = ISNULL(@Marzo, 0),
                Abril = ISNULL(@Abril, 0),
                Mayo = ISNULL(@Mayo, 0),
                Junio = ISNULL(@Junio, 0),
                Julio = ISNULL(@Julio, 0),
                Agosto = ISNULL(@Agosto, 0),
                Septiembre = ISNULL(@Septiembre, 0),
                Octubre = ISNULL(@Octubre, 0),
                Noviembre = ISNULL(@Noviembre, 0),
                Diciembre = ISNULL(@Diciembre, 0),
                FechaModificacion = @Hoy,
                UsuarioModificacion = @IdUser
            WHERE PKIdEgresoAutorizado = @PKIdEgresoAutorizado
              AND Activo = 1;

            SET @FKIdPoliza_CONTA = @PolizaNueva;
            SET @Mensaje = CONCAT(N'Se actualizo correctamente el presupuesto autorizado de egresos ', @PKIdEgresoAutorizado, N'. Presupuesto afectado ', @Importe);
        END
        ELSE IF @Action = 3
        BEGIN
            SELECT @PolizaActual = ea.FKIdPoliza_CONTA
            FROM PRES.EgresoAutorizado AS ea
            WHERE ea.PKIdEgresoAutorizado = @PKIdEgresoAutorizado
              AND ea.Activo = 1;

            IF @PolizaActual IS NULL AND NOT EXISTS (
                SELECT 1 FROM PRES.EgresoAutorizado WHERE PKIdEgresoAutorizado = @PKIdEgresoAutorizado AND Activo = 1
            )
                THROW 51002, 'Presupuesto autorizado no encontrado.', 1;

            UPDATE PRES.EgresoAutorizado
            SET Activo = 0,
                FechaModificacion = @Hoy,
                UsuarioModificacion = @IdUser
            WHERE PKIdEgresoAutorizado = @PKIdEgresoAutorizado;

            UPDATE CONTA.PolizaDetalle
            SET Activo = 0,
                FechaModificacion = @Hoy,
                UsuarioModificacion = @IdUser
            WHERE FKIdPoliza_CONTA = @PolizaActual
              AND FKIdReferencia = @PKIdEgresoAutorizado
              AND Activo = 1;

            SET @FKIdPoliza_CONTA = @PolizaActual;
            SET @Mensaje = CONCAT(N'Se elimino correctamente el presupuesto autorizado de egresos ', @PKIdEgresoAutorizado, N'.');
        END

        IF @Action IN (1, 2)
        BEGIN
            INSERT INTO CONTA.PolizaDetalle (
                FKIdCuentaContable_CONTA,
                FKIdPoliza_CONTA,
                Descripcion,
                ImporteDebe,
                ImporteHaber,
                FKIdReferencia,
                FKIdTipoDetallePoliza_SIS,
                Activo,
                FechaCreacion,
                UsuarioCreacion
            )
            VALUES
            (
                @CuentaAprobado,
                @FKIdPoliza_CONTA,
                @NombrePoliza,
                @Importe,
                0,
                @PKIdEgresoAutorizado,
                1,
                1,
                @Hoy,
                @IdUser
            ),
            (
                @CuentaPorEjercer,
                @FKIdPoliza_CONTA,
                @NombrePoliza,
                0,
                @Importe,
                @PKIdEgresoAutorizado,
                2,
                1,
                @Hoy,
                @IdUser
            );
        END

        IF @FKIdPoliza_CONTA IS NOT NULL
        BEGIN
            SELECT
                @Debe = ISNULL(SUM(ImporteDebe), 0),
                @Haber = ISNULL(SUM(ImporteHaber), 0)
            FROM CONTA.PolizaDetalle
            WHERE FKIdPoliza_CONTA = @FKIdPoliza_CONTA
              AND Activo = 1;

            UPDATE CONTA.Poliza
            SET EstaBalanceado = CASE WHEN @Debe = @Haber THEN 1 ELSE 0 END,
                FechaModificacion = @Hoy,
                UsuarioModificacion = @IdUser
            WHERE PKIdPoliza = @FKIdPoliza_CONTA
              AND Activo = 1;
        END

        IF @PolizaActual IS NOT NULL AND @PolizaActual <> ISNULL(@FKIdPoliza_CONTA, 0)
        BEGIN
            SELECT
                @Debe = ISNULL(SUM(ImporteDebe), 0),
                @Haber = ISNULL(SUM(ImporteHaber), 0)
            FROM CONTA.PolizaDetalle
            WHERE FKIdPoliza_CONTA = @PolizaActual
              AND Activo = 1;

            UPDATE CONTA.Poliza
            SET EstaBalanceado = CASE WHEN @Debe = @Haber THEN 1 ELSE 0 END,
                FechaModificacion = @Hoy,
                UsuarioModificacion = @IdUser
            WHERE PKIdPoliza = @PolizaActual
              AND Activo = 1;
        END

        EXEC [SIS].[SP_MantenimientoNotificacion]
            @Action = 1,
            @Fk_IdUsuarioOrigen = @IdUser,
            @Fk_IdMenu = @IdMenu,
            @Fk_IdAccionSuscrita = @AccionNotificacion,
            @Mensaje = @Mensaje,
            @IdUser = @IdUser,
            @Controlador = NULL,
            @Pk_IdNotificacion = NULL,
            @Fk_IdNotificacionPadre = NULL,
            @Fk_IdUnidades = NULL,
            @Fk_IdEstadoNotificacion = NULL,
            @Fk_IdCliente = NULL,
            @Fk_IdEmpresa = NULL,
            @Importe = NULL,
            @IdRegistro = @PKIdEgresoAutorizado,
            @FechaCreacion = NULL,
            @FechaRecibido = NULL,
            @IntervaloNormal = NULL,
            @IntervaloAlerta = NULL,
            @IntervaloCritico = NULL,
            @Fk_IdUsuarioDestino = NULL;

        COMMIT TRANSACTION;

        SET @Liga = CONCAT(N'id:', @PKIdEgresoAutorizado);

Finish:
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT CAST(JSON_QUERY(
            CONCAT(
                N'{"tipo":"',
                STRING_ESCAPE(@Tipo, 'json'),
                N'","mensaje":"',
                STRING_ESCAPE(ISNULL(@Mensaje, N''), 'json'),
                N'","liga":"',
                STRING_ESCAPE(ISNULL(@Liga, N''), 'json'),
                N'"}'
            )
        ) AS NVARCHAR(MAX)) AS ResultJson;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @ErrorMessage = CONCAT(
            ISNULL(PROGRAM_NAME(), N''),
            CHAR(10),
            N'Error: ',
            ERROR_MESSAGE(),
            CHAR(10),
            N'Linea: ',
            ERROR_LINE()
        );

        SELECT CAST(JSON_QUERY(
            CONCAT(
                N'{"tipo":"ERROR","mensaje":"',
                STRING_ESCAPE(@ErrorMessage, 'json'),
                N'","liga":""}'
            )
        ) AS NVARCHAR(MAX)) AS ResultJson;
    END CATCH
END
GO
