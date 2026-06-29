USE [GestionEmpresarial]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [ALMA].[SP_MantenimientoBien]
    @Action INT,
    @PKIdBien INT = NULL,
    @FKIdGrupoBien_ALMA INT = NULL,
    @FKIdTipoBien_ALMA INT = NULL,
    @FKIdArea_SIS INT = NULL,
    @FKIdProveedor_SIS INT = NULL,
    @FKIdEstadoBien_ALMA INT = NULL,
    @FKIdTipoPatrimonio_ALMA INT = NULL,
    @FKIdMarca_ALMA INT = NULL,
    @FKIdMaterial_ALMA INT = NULL,
    @FKIdTipoAdq_ALMA INT = NULL,
    @FKIdPartida_CONTA INT = NULL,
    @FKIdDetalleOrdenCompra_ORCO INT = NULL,
    @Clave NVARCHAR(50) = NULL,
    @ClaveAnt NVARCHAR(50) = NULL,
    @Descripcion NVARCHAR(1000) = NULL,
    @Modelo NVARCHAR(50) = NULL,
    @Serie NVARCHAR(1000) = NULL,
    @Requisicion NVARCHAR(25) = NULL,
    @Factura NVARCHAR(50) = NULL,
    @Costo DECIMAL(20,4) = NULL,
    @ValorActual DECIMAL(20,4) = NULL,
    @FechaAdq DATETIME = NULL,
    @Referencia NVARCHAR(50) = NULL,
    @Notas NVARCHAR(250) = NULL,
    @Ubicacion NVARCHAR(50) = NULL,
    @AAdquisicion NVARCHAR(2) = NULL,
    @Frente INT = NULL,
    @Fondo INT = NULL,
    @Altura INT = NULL,
    @Diametro INT = NULL,
    @VerificacionesDias INT = NULL,
    @MantenimientoDias INT = NULL,
    @Mantenimiento BIT = NULL,
    @Calibracion BIT = NULL,
    @Rango NVARCHAR(20) = NULL,
    @Resolucion NVARCHAR(20) = NULL,
    @FechaUltInv DATETIME = NULL,
    @FechaReqscn DATETIME = NULL,
    @Estatus NVARCHAR(1) = NULL,
    @Caracteristicas NVARCHAR(50) = NULL,
    @Resguardo INT = NULL,
    @ValorRescate DECIMAL(20,4) = NULL,
    @Localizado BIT = NULL,
    @EsContabilizado BIT = NULL,
    @LiberarResguardo BIT = 0,
    @PropagarOrdenCompra BIT = 1,
    @IdBaja INT = NULL,
    @IdUser INT = NULL,
    @Id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Tipo NVARCHAR(20) = N'OK';
    DECLARE @Mensaje NVARCHAR(1000) = N'Operacion realizada correctamente.';
    DECLARE @Liga NVARCHAR(100);
    DECLARE @Today DATETIME = GETDATE();
    DECLARE @ResguardoObjetivo INT = @Resguardo;
    DECLARE @AreaResguardo INT = NULL;

    BEGIN TRY
        IF @Action NOT IN (1, 2, 3)
            THROW 53000, N'Accion no valida para mantenimiento de bienes.', 1;

        IF @IdUser IS NULL
            THROW 53001, N'El usuario es obligatorio.', 1;

        IF @Action IN (1, 2) AND @ValorActual IS NOT NULL AND @ValorActual <= 0
            THROW 53002, N'El valor factura debe ser mayor a cero.', 1;

        IF @Action = 1
        BEGIN
            IF @FKIdTipoBien_ALMA IS NULL
                THROW 53003, N'El tipo de bien es obligatorio.', 1;

            IF NOT EXISTS (SELECT 1 FROM ALMA.TipoBien WHERE PKIdTipoBien = @FKIdTipoBien_ALMA AND Activo = 1)
                THROW 53004, N'El tipo de bien no existe o esta inactivo.', 1;

            IF @ValorActual IS NULL OR @ValorActual <= 0
                THROW 53005, N'El valor factura debe ser mayor a cero.', 1;
        END;

        IF @ResguardoObjetivo IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM ALMA.Resguardo WHERE PKIdResguardo = @ResguardoObjetivo AND Activo = 1)
                THROW 53006, N'El resguardo indicado no existe o esta inactivo.', 1;

            SELECT @AreaResguardo = FKIdArea_SIS
            FROM ALMA.Resguardo
            WHERE PKIdResguardo = @ResguardoObjetivo;
        END;

        BEGIN TRAN;

        IF @Action = 1
        BEGIN
            DECLARE @Consecutivo INT;
            DECLARE @CodigoClave NVARCHAR(50);

            SELECT @Consecutivo = ISNULL(MAX(TRY_CONVERT(INT, ClaveAnt)), 0) + 1
            FROM ALMA.Bien WITH (UPDLOCK, HOLDLOCK)
            WHERE Activo = 1;

            SELECT @CodigoClave = ISNULL(NULLIF(LTRIM(RTRIM(CodigoClave)), N''), N'SINCLAVE')
            FROM ALMA.TipoBien
            WHERE PKIdTipoBien = @FKIdTipoBien_ALMA;

            SET @ClaveAnt = COALESCE(NULLIF(LTRIM(RTRIM(@ClaveAnt)), N''), RIGHT(CONCAT(N'00000', @Consecutivo), 5));
            SET @Clave = COALESCE(NULLIF(LTRIM(RTRIM(@Clave)), N''), CONCAT(N'43-', @CodigoClave, N'-', @ClaveAnt));

            INSERT INTO ALMA.Bien
            (
                FKIdGrupoBien_ALMA, FKIdTipoBien_ALMA, FKIdArea_SIS, FKIdProveedor_SIS,
                FKIdEstadoBien_ALMA, FKIdTipoPatrimonio_ALMA, FKIdMarca_ALMA, FKIdMaterial_ALMA,
                FKIdTipoAdq_ALMA, FKIdPartida_CONTA, FKIdDetalleOrdenCompra_ORCO,
                Clave, ClaveAnt, Consecutivo, Descripcion, Modelo, Serie, Requisicion, Factura,
                Costo, ValorActual, FechaAdq, Referencia, Notas, Ubicacion, AAdquisicion,
                Frente, Fondo, Altura, Diametro, VerificacionesDias, MantenimientoDias,
                Mantenimiento, Calibracion, Rango, Resolucion, FechaUltInv, FechaReqscn,
                Estatus, Caracteristicas, Resguardo, ValorRescate, EstaResguardado,
                FechaResguardado, Localizado, esContabilizado, Activo, FechaCreacion, UsuarioCreacion
            )
            VALUES
            (
                @FKIdGrupoBien_ALMA, @FKIdTipoBien_ALMA, COALESCE(@FKIdArea_SIS, @AreaResguardo), @FKIdProveedor_SIS,
                @FKIdEstadoBien_ALMA, @FKIdTipoPatrimonio_ALMA, @FKIdMarca_ALMA, @FKIdMaterial_ALMA,
                @FKIdTipoAdq_ALMA, @FKIdPartida_CONTA, @FKIdDetalleOrdenCompra_ORCO,
                @Clave, @ClaveAnt, @Consecutivo, @Descripcion, @Modelo, @Serie, @Requisicion, @Factura,
                COALESCE(@Costo, @ValorActual), @ValorActual, @FechaAdq, @Referencia, @Notas, @Ubicacion, @AAdquisicion,
                @Frente, @Fondo, @Altura, @Diametro, ISNULL(@VerificacionesDias, 0), ISNULL(@MantenimientoDias, 0),
                ISNULL(@Mantenimiento, 0), ISNULL(@Calibracion, 0), @Rango, @Resolucion, @FechaUltInv, @FechaReqscn,
                @Estatus, @Caracteristicas, @ResguardoObjetivo, @ValorRescate,
                CASE WHEN @ResguardoObjetivo IS NULL THEN ISNULL(@Localizado, 0) ELSE 1 END,
                CASE WHEN @ResguardoObjetivo IS NULL THEN NULL ELSE @Today END,
                ISNULL(@Localizado, 1), ISNULL(@EsContabilizado, 0), 1, @Today, @IdUser
            );

            SET @PKIdBien = CONVERT(INT, SCOPE_IDENTITY());
            SET @Id = @PKIdBien;

            IF @ResguardoObjetivo IS NOT NULL
            BEGIN
                INSERT INTO ALMA.ResguardoDetalle
                (
                    FKIdResguardo_ALMA, FKIdBien_ALMA, ImprimeEtiqueta,
                    FKIdEstadoBien_ALMA, Observaciones, Activo, FechaCreacion, UsuarioCreacion
                )
                VALUES
                (
                    @ResguardoObjetivo, @PKIdBien, 1,
                    @FKIdEstadoBien_ALMA, N'Asignacion inicial desde alta de bien.', 1, @Today, @IdUser
                );

                INSERT INTO ALMA.ResguardoMovimiento
                (
                    FKIdResguardoDetalle_ALMA, FKIdBien_ALMA, FKIdResguardoDestino_ALMA,
                    TipoMovimiento, Observaciones, Activo, FechaCreacion, UsuarioCreacion
                )
                VALUES
                (
                    CONVERT(INT, SCOPE_IDENTITY()), @PKIdBien, @ResguardoObjetivo,
                    N'ASIGNACION', N'Asignacion inicial desde alta de bien.', 1, @Today, @IdUser
                );
            END;

            SET @Mensaje = N'Bien registrado correctamente.';
        END
        ELSE IF @Action = 2
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM ALMA.Bien WHERE PKIdBien = @PKIdBien AND Activo = 1)
                THROW 53007, N'El bien no existe o esta inactivo.', 1;

            UPDATE ALMA.Bien
            SET
                FKIdGrupoBien_ALMA = @FKIdGrupoBien_ALMA,
                FKIdTipoBien_ALMA = ISNULL(@FKIdTipoBien_ALMA, FKIdTipoBien_ALMA),
                FKIdArea_SIS = COALESCE(@FKIdArea_SIS, @AreaResguardo, FKIdArea_SIS),
                FKIdProveedor_SIS = @FKIdProveedor_SIS,
                FKIdEstadoBien_ALMA = @FKIdEstadoBien_ALMA,
                FKIdTipoPatrimonio_ALMA = @FKIdTipoPatrimonio_ALMA,
                FKIdMarca_ALMA = @FKIdMarca_ALMA,
                FKIdMaterial_ALMA = @FKIdMaterial_ALMA,
                FKIdTipoAdq_ALMA = @FKIdTipoAdq_ALMA,
                FKIdPartida_CONTA = @FKIdPartida_CONTA,
                FKIdDetalleOrdenCompra_ORCO = @FKIdDetalleOrdenCompra_ORCO,
                Clave = COALESCE(NULLIF(LTRIM(RTRIM(@Clave)), N''), Clave),
                Descripcion = @Descripcion,
                Modelo = @Modelo,
                Serie = @Serie,
                Requisicion = @Requisicion,
                Factura = @Factura,
                Costo = COALESCE(@Costo, @ValorActual, Costo),
                ValorActual = COALESCE(@ValorActual, ValorActual),
                FechaAdq = @FechaAdq,
                Referencia = @Referencia,
                Notas = @Notas,
                Ubicacion = @Ubicacion,
                AAdquisicion = @AAdquisicion,
                Frente = @Frente,
                Fondo = @Fondo,
                Altura = @Altura,
                Diametro = @Diametro,
                VerificacionesDias = ISNULL(@VerificacionesDias, VerificacionesDias),
                MantenimientoDias = ISNULL(@MantenimientoDias, MantenimientoDias),
                Mantenimiento = ISNULL(@Mantenimiento, Mantenimiento),
                Calibracion = ISNULL(@Calibracion, Calibracion),
                Rango = @Rango,
                Resolucion = @Resolucion,
                FechaUltInv = @FechaUltInv,
                FechaReqscn = @FechaReqscn,
                Estatus = @Estatus,
                Caracteristicas = @Caracteristicas,
                ValorRescate = @ValorRescate,
                Localizado = ISNULL(@Localizado, Localizado),
                esContabilizado = ISNULL(@EsContabilizado, esContabilizado),
                FechaModificacion = @Today,
                UsuarioModificacion = @IdUser
            WHERE PKIdBien = @PKIdBien;

            IF @PropagarOrdenCompra = 1
            BEGIN
                DECLARE @DetalleOC INT;

                SELECT @DetalleOC = FKIdDetalleOrdenCompra_ORCO
                FROM ALMA.Bien
                WHERE PKIdBien = @PKIdBien;

                IF @DetalleOC IS NOT NULL
                BEGIN
                    UPDATE ALMA.Bien
                    SET FKIdMarca_ALMA = @FKIdMarca_ALMA,
                        Modelo = @Modelo,
                        Factura = @Factura,
                        ValorActual = COALESCE(@ValorActual, ValorActual),
                        Costo = COALESCE(@Costo, @ValorActual, Costo),
                        FechaModificacion = @Today,
                        UsuarioModificacion = @IdUser
                    WHERE FKIdDetalleOrdenCompra_ORCO = @DetalleOC
                      AND PKIdBien <> @PKIdBien
                      AND Activo = 1;
                END;
            END;

            SET @Id = @PKIdBien;
            SET @Mensaje = N'Bien actualizado correctamente.';
        END
        ELSE IF @Action = 3
        BEGIN
            SET @PKIdBien = COALESCE(@PKIdBien, @IdBaja);

            IF NOT EXISTS (SELECT 1 FROM ALMA.Bien WHERE PKIdBien = @PKIdBien AND Activo = 1)
                THROW 53008, N'El bien no existe o ya esta inactivo.', 1;

            DECLARE @DetalleResguardoActivo INT;
            DECLARE @ResguardoActivo INT;

            SELECT TOP 1
                @DetalleResguardoActivo = PKIdResguardoDetalle,
                @ResguardoActivo = FKIdResguardo_ALMA
            FROM ALMA.ResguardoDetalle
            WHERE FKIdBien_ALMA = @PKIdBien
              AND Activo = 1;

            IF @DetalleResguardoActivo IS NOT NULL
            BEGIN
                UPDATE ALMA.ResguardoDetalle
                SET Activo = 0,
                    FechaLiberacion = @Today,
                    FechaModificacion = @Today,
                    UsuarioModificacion = @IdUser
                WHERE PKIdResguardoDetalle = @DetalleResguardoActivo;

                INSERT INTO ALMA.ResguardoMovimiento
                (
                    FKIdResguardoDetalle_ALMA, FKIdBien_ALMA, FKIdResguardoOrigen_ALMA,
                    TipoMovimiento, Observaciones, Activo, FechaCreacion, UsuarioCreacion
                )
                VALUES
                (
                    @DetalleResguardoActivo, @PKIdBien, @ResguardoActivo,
                    N'BAJA', N'Liberacion automatica por baja logica del bien.', 1, @Today, @IdUser
                );
            END;

            UPDATE ALMA.Bien
            SET Activo = 0,
                ResguardoAnterior = Resguardo,
                Resguardo = NULL,
                EstaResguardado = 0,
                FechaResguardado = NULL,
                FechaModificacion = @Today,
                UsuarioModificacion = @IdUser
            WHERE PKIdBien = @PKIdBien;

            SET @Id = @PKIdBien;
            SET @Mensaje = N'Bien eliminado correctamente.';
        END;

        COMMIT;

        SET @Liga = CONCAT(N'idBien:', ISNULL(@Id, @PKIdBien));

        SELECT ResultJson = (
            SELECT @Tipo AS Tipo, @Mensaje AS Mensaje, @Liga AS Liga
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;

        SELECT ResultJson = (
            SELECT
                N'ERROR' AS Tipo,
                ERROR_MESSAGE() AS Mensaje,
                CONCAT(N'idBien:', ISNULL(@PKIdBien, 0)) AS Liga
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
    END CATCH
END
GO
