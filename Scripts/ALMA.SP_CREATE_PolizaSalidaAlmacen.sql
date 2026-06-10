USE [GestionEmpresarial];
GO

IF COL_LENGTH(N'ALMA.SolicitudSalida', N'FKIdPoliza_CONTA') IS NULL
BEGIN
    ALTER TABLE ALMA.SolicitudSalida
        ADD FKIdPoliza_CONTA INT NULL;
END
GO

IF COL_LENGTH(N'ALMA.SolicitudSalida', N'FKIdPoliza_CONTA') IS NOT NULL
   AND NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = N'FK_SolicitudSalida_Poliza_CONTA'
          AND parent_object_id = OBJECT_ID(N'ALMA.SolicitudSalida')
   )
BEGIN
    ALTER TABLE ALMA.SolicitudSalida WITH CHECK
        ADD CONSTRAINT FK_SolicitudSalida_Poliza_CONTA
        FOREIGN KEY (FKIdPoliza_CONTA) REFERENCES CONTA.Poliza(PKIdPoliza);
END
GO

CREATE OR ALTER PROCEDURE [ALMA].[SP_CREATE_PolizaSalidaAlmacen]
    @PKIdSolicitudSalida INT,
    @IdUser INT = 1,
    @Error NVARCHAR(MAX) = NULL OUTPUT,
    @PKIdPoliza INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @FechaSolicitud DATETIME,
        @Folio NVARCHAR(50),
        @FKIdAnio_SIS INT,
        @FKIdMes_SIS INT,
        @FKIdTipoPoliza_SIS INT = 1,
        @ClavePoliza NVARCHAR(10),
        @NombrePoliza NVARCHAR(255),
        @CuentaCargo INT,
        @CuentaAbono INT,
        @ReturnCode INT,
        @Mensaje NVARCHAR(4000),
        @StartedTransaction BIT = 0;

    DECLARE @Detalle TABLE
    (
        PKIdDetalleSolicitudSalida INT NOT NULL,
        CantidadEntregada DECIMAL(20, 4) NOT NULL,
        CostoUnitario DECIMAL(20, 4) NOT NULL,
        Importe DECIMAL(20, 4) NOT NULL,
        Descripcion NVARCHAR(600) NOT NULL
    );

    BEGIN TRY
        SELECT
            @FechaSolicitud = ss.FechaSolicitud,
            @Folio = ss.Folio,
            @PKIdPoliza = COALESCE(@PKIdPoliza, ss.FKIdPoliza_CONTA)
        FROM ALMA.SolicitudSalida ss
        WHERE ss.PKIdSolicitudSalida = @PKIdSolicitudSalida
          AND ss.Activo = 1;

        IF @FechaSolicitud IS NULL
        BEGIN
            SET @Error = N'No existe la solicitud de salida o no esta activa.';
            GOTO Fail;
        END

        IF NOT EXISTS (
            SELECT 1
            FROM ALMA.SolicitudSalida ss
            WHERE ss.PKIdSolicitudSalida = @PKIdSolicitudSalida
              AND ss.Activo = 1
              AND ISNULL(ss.Autorizado, 0) = 1
        )
        BEGIN
            SET @Error = N'La solicitud de salida debe estar autorizada para generar la poliza.';
            GOTO Fail;
        END

        SELECT @FKIdAnio_SIS = a.PKIdAnio
        FROM SIS.Anio a
        WHERE a.Clave = YEAR(@FechaSolicitud)
          AND a.Activo = 1;

        SET @FKIdMes_SIS = MONTH(@FechaSolicitud);

        IF @FKIdAnio_SIS IS NULL
        BEGIN
            SET @Error = N'No existe configuracion de anio para la fecha de la solicitud.';
            GOTO Fail;
        END

        SELECT @CuentaCargo = ce.FKIdCuentaContable_CONTA
        FROM CONTA.CuentaEspecial ce
        WHERE ce.Clave = N'SALIDA_ALMACEN_CUENTA_CARGO'
          AND ce.Activo = 1;

        SELECT @CuentaAbono = ce.FKIdCuentaContable_CONTA
        FROM CONTA.CuentaEspecial ce
        WHERE ce.Clave = N'SALIDA_ALMACEN_CUENTA_ABONO'
          AND ce.Activo = 1;

        IF @CuentaCargo IS NULL OR @CuentaAbono IS NULL
        BEGIN
            SET @Error = N'Falta configurar las cuentas especiales SALIDA_ALMACEN_CUENTA_CARGO y SALIDA_ALMACEN_CUENTA_ABONO.';
            GOTO Fail;
        END

        ;WITH BaseDetalle AS
        (
            SELECT
                d.PKIdDetalleSolicitudSalida,
                CAST(ISNULL(d.CantidadEntregada, 0) AS DECIMAL(20, 4)) AS CantidadEntregada,
                CAST(COALESCE(
                    NULLIF(alm.CostoUnitario, 0),
                    NULLIF(alm.Costo / NULLIF(alm.Cantidad + ISNULL(d.CantidadEntregada, 0), 0), 0),
                    (
                        SELECT AVG(CAST(COALESCE(
                            NULLIF(almAvg.CostoUnitario, 0),
                            NULLIF(almAvg.Costo / NULLIF(almAvg.Cantidad, 0), 0)
                        ) AS DECIMAL(20, 4)))
                        FROM ALMA.Almacen almAvg
                        WHERE almAvg.Activo = 1
                          AND almAvg.FKIdTipoBien_ALMA = d.FKIdTipoBien_ALMA
                          AND almAvg.FKIdDetalleOrdenCompra_ORCO IS NOT NULL
                          AND almAvg.Cantidad > 0
                    ),
                    0
                ) AS DECIMAL(20, 4)) AS CostoUnitario,
                tb.CodigoClave,
                tb.Descripcion AS TipoBienDescripcion
            FROM ALMA.DetalleSolicitudSalida d
            INNER JOIN ALMA.Almacen alm
                ON alm.PKIdAlmacen = d.FKIdAlmacen_ALMA
               AND alm.Activo = 1
            LEFT JOIN ALMA.TipoBien tb
                ON tb.PKIdTipoBien = d.FKIdTipoBien_ALMA
               AND tb.Activo = 1
            WHERE d.FKIdSolicitudSalida_ALMA = @PKIdSolicitudSalida
              AND d.Activo = 1
              AND ISNULL(d.CantidadEntregada, 0) > 0
        )
        INSERT INTO @Detalle
        (
            PKIdDetalleSolicitudSalida,
            CantidadEntregada,
            CostoUnitario,
            Importe,
            Descripcion
        )
        SELECT
            bd.PKIdDetalleSolicitudSalida,
            bd.CantidadEntregada,
            bd.CostoUnitario,
            CAST(bd.CantidadEntregada * bd.CostoUnitario AS DECIMAL(20, 4)),
            LEFT(CONCAT(
                N'Salida de almacen ',
                ISNULL(@Folio, CONVERT(NVARCHAR(20), @PKIdSolicitudSalida)),
                N' - ',
                ISNULL(bd.CodigoClave, N'SIN CLAVE'),
                N' ',
                ISNULL(bd.TipoBienDescripcion, N'SIN DESCRIPCION'),
                N' - Cantidad ',
                CONVERT(NVARCHAR(40), bd.CantidadEntregada)
            ), 600)
        FROM BaseDetalle bd;

        IF NOT EXISTS (SELECT 1 FROM @Detalle)
        BEGIN
            SET @Error = N'La solicitud no tiene detalles entregados para contabilizar.';
            GOTO Fail;
        END

        IF EXISTS (SELECT 1 FROM @Detalle WHERE CostoUnitario <= 0 OR Importe <= 0)
        BEGIN
            SET @Error = N'No se pudo determinar un costo valido para uno o mas bienes entregados.';
            GOTO Fail;
        END

        IF @PKIdPoliza IS NOT NULL
           AND NOT EXISTS (
                SELECT 1
                FROM CONTA.Poliza p
                WHERE p.PKIdPoliza = @PKIdPoliza
                  AND p.Activo = 1
           )
        BEGIN
            SET @PKIdPoliza = NULL;
        END

        IF @PKIdPoliza IS NOT NULL
           AND EXISTS (
                SELECT 1
                FROM CONTA.Poliza p
                WHERE p.PKIdPoliza = @PKIdPoliza
                  AND ISNULL(p.Autorizado, 0) = 1
           )
        BEGIN
            SET @Error = N'La poliza de la solicitud ya esta autorizada y no puede regenerarse.';
            GOTO Fail;
        END

        SET @NombrePoliza = LEFT(CONCAT(N'Salida de almacen ', ISNULL(@Folio, CONVERT(NVARCHAR(20), @PKIdSolicitudSalida))), 255);

        BEGIN TRANSACTION;
        SET @StartedTransaction = 1;

        IF @PKIdPoliza IS NULL
        BEGIN
            EXEC @ReturnCode = CONTA.SP_CREATE_ClavePoliza
                @FK_IdAnio__SIS = @FKIdAnio_SIS,
                @FK_IdMesConta__SIS = @FKIdMes_SIS,
                @FK_IdTipoPolizaConta__SIS = @FKIdTipoPoliza_SIS,
                @CT_ModifiedBy = @IdUser,
                @ClavePoliza = @ClavePoliza OUTPUT,
                @Error = @Error OUTPUT;

            IF @ReturnCode <> 0 OR @ClavePoliza IS NULL
            BEGIN
                SET @Error = COALESCE(@Error, N'No se pudo generar la clave de la poliza.');
                GOTO Fail;
            END

            INSERT INTO CONTA.Poliza
            (
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
            VALUES
            (
                @FKIdAnio_SIS,
                @FKIdMes_SIS,
                @FKIdTipoPoliza_SIS,
                @ClavePoliza,
                @NombrePoliza,
                @FechaSolicitud,
                0,
                1,
                SYSDATETIME(),
                @IdUser,
                1,
                0
            );

            SET @PKIdPoliza = CONVERT(INT, SCOPE_IDENTITY());
        END
        ELSE
        BEGIN
            UPDATE CONTA.Poliza
            SET
                NombrePoliza = @NombrePoliza,
                FechaPoliza = @FechaSolicitud,
                FechaModificacion = SYSDATETIME(),
                UsuarioModificacion = @IdUser,
                EstaBalanceado = 0
            WHERE PKIdPoliza = @PKIdPoliza;

            UPDATE pd
            SET
                Activo = 0,
                FechaModificacion = SYSDATETIME(),
                UsuarioModificacion = @IdUser
            FROM CONTA.PolizaDetalle pd
            INNER JOIN @Detalle d
                ON d.PKIdDetalleSolicitudSalida = pd.FKIdReferencia
            WHERE pd.FKIdPoliza_CONTA = @PKIdPoliza
              AND pd.Activo = 1
              AND pd.FKIdTipoDetallePoliza_SIS IN (1, 2);
        END

        INSERT INTO CONTA.PolizaDetalle
        (
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
        SELECT
            @CuentaCargo,
            @PKIdPoliza,
            d.Descripcion,
            d.Importe,
            CAST(0 AS DECIMAL(20, 4)),
            d.PKIdDetalleSolicitudSalida,
            1,
            1,
            SYSDATETIME(),
            @IdUser
        FROM @Detalle d
        UNION ALL
        SELECT
            @CuentaAbono,
            @PKIdPoliza,
            d.Descripcion,
            CAST(0 AS DECIMAL(20, 4)),
            d.Importe,
            d.PKIdDetalleSolicitudSalida,
            2,
            1,
            SYSDATETIME(),
            @IdUser
        FROM @Detalle d;

        EXEC @ReturnCode = CONTA.SP_UPDATE_PolizaBalanceada
            @PKIdPoliza = @PKIdPoliza,
            @IdUser = @IdUser,
            @Error = @Error OUTPUT;

        IF @ReturnCode <> 0
        BEGIN
            SET @Error = COALESCE(@Error, N'No se pudo recalcular el balance de la poliza.');
            GOTO Fail;
        END

        UPDATE ALMA.SolicitudSalida
        SET
            FKIdPoliza_CONTA = @PKIdPoliza,
            FechaModificacion = SYSDATETIME(),
            UsuarioModificacion = @IdUser
        WHERE PKIdSolicitudSalida = @PKIdSolicitudSalida;

        COMMIT TRANSACTION;
        SET @StartedTransaction = 0;

        SET @Error = NULL;
        SET @Mensaje = CONCAT(N'Poliza de salida de almacen generada correctamente. Id: ', @PKIdPoliza);

        SELECT ResultJson =
        (
            SELECT
                N'success' AS Tipo,
                @Mensaje AS Mensaje,
                CONCAT(N'id:', @PKIdPoliza) AS Liga
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        RETURN 0;

Fail:
        IF @StartedTransaction = 1 AND @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT ResultJson =
        (
            SELECT
                N'error' AS Tipo,
                @Error AS Mensaje,
                NULL AS Liga
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        RETURN 1;
    END TRY
    BEGIN CATCH
        IF @StartedTransaction = 1 AND @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @Error = CONCAT(
            N'Error en ALMA.SP_CREATE_PolizaSalidaAlmacen. Linea ',
            ERROR_LINE(),
            N': ',
            ERROR_MESSAGE()
        );

        SELECT ResultJson =
        (
            SELECT
                N'error' AS Tipo,
                @Error AS Mensaje,
                NULL AS Liga
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        RETURN 1;
    END CATCH
END
GO
