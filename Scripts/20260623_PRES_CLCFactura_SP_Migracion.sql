USE [BD_PRESUPUESTO]
GO

/*
    PRES.CLCFactura como CLCFactura de ingresos.

    No usa PRES.SP_MantenimientoCLC, porque ese mantenimiento pertenece
    al flujo de egresos / cuentas por pagar.

    Acciones:
      1 = Crear CLCFactura de ingreso
      2 = Actualizar CLCFactura de ingreso
      3 = Eliminar CLCFactura de ingreso
      4 = Consultar CLCFactura de ingreso
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF COL_LENGTH(N'PRES.CLCFactura', N'FKIdIngresoAutorizado_PRES') IS NULL
BEGIN
    ALTER TABLE PRES.CLCFactura
    ADD FKIdIngresoAutorizado_PRES INT NULL;
END
GO

IF COL_LENGTH(N'PRES.CLCFactura', N'Fecha') IS NULL
BEGIN
    ALTER TABLE PRES.CLCFactura
    ADD Fecha DATE NULL;
END
GO

IF OBJECT_ID(N'PRES.FK_CLCFactura_IngresoAutorizado', N'F') IS NULL
   AND COL_LENGTH(N'PRES.CLCFactura', N'FKIdIngresoAutorizado_PRES') IS NOT NULL
   AND OBJECT_ID(N'PRES.IngresoAutorizado', N'U') IS NOT NULL
BEGIN
    ALTER TABLE PRES.CLCFactura WITH CHECK
    ADD CONSTRAINT FK_CLCFactura_IngresoAutorizado
        FOREIGN KEY (FKIdIngresoAutorizado_PRES)
        REFERENCES PRES.IngresoAutorizado (PKIdIngresoAutorizado);
END
GO

CREATE OR ALTER PROCEDURE [PRES].[sp_MantenimientoIngresoCLCFactura]
(
    @Action INT,
    @PKIdCLCFactura INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdCLC_PRES INT = NULL,
    @FKIdFactura_PRES INT = NULL,
    @FKIdFacturaDetalle_PRES INT = NULL,
    @FKIdIngresoAutorizado_PRES INT = NULL,
    @Fecha DATE = NULL,
    @MontoAplicado DECIMAL(20, 4) = NULL,
    @Observaciones NVARCHAR(500) = NULL,
    @IdUser INT = NULL,
    @Id INT = NULL OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @tipo NVARCHAR(20) = N'OK',
        @message NVARCHAR(4000) = N'',
        @liga NVARCHAR(100) = N'',
        @today DATETIME2(7) = SYSDATETIME(),
        @Mes INT,
        @Disponible DECIMAL(20, 4) = 0,
        @ImporteActual DECIMAL(20, 4) = 0,
        @FKIdFacturaDetalleFactura_PRES INT,
        @FechaActual DATE,
        @IngresoActual INT;

    BEGIN TRY
        IF @Action NOT IN (1, 2, 3, 4)
            THROW 51000, 'Accion no valida para CLCFactura de ingresos.', 1;

        IF @Action IN (1, 2)
        BEGIN
            IF @FKIdCLC_PRES IS NULL
                THROW 51000, 'La CLC es requerida.', 1;

            IF @FKIdFacturaDetalle_PRES IS NULL
                THROW 51000, 'El detalle de factura es requerido.', 1;

            IF @FKIdIngresoAutorizado_PRES IS NULL
                THROW 51000, 'El ingreso autorizado es requerido.', 1;

            IF @Fecha IS NULL
                THROW 51000, 'La fecha es requerida para afectar el mes del ingreso.', 1;

            IF ISNULL(@MontoAplicado, 0) <= 0
                THROW 51000, 'El monto aplicado debe ser mayor a cero.', 1;

            IF NOT EXISTS (SELECT 1 FROM PRES.CLC WHERE PKIdCLC = @FKIdCLC_PRES AND Activo = 1)
                THROW 51000, 'CLC no encontrada.', 1;

            IF NOT EXISTS (
                SELECT 1
                FROM PRES.IngresoAutorizado
                WHERE PKIdIngresoAutorizado = @FKIdIngresoAutorizado_PRES
                  AND Activo = 1
                  AND FechaAutorizacion IS NOT NULL
            )
                THROW 51000, 'Ingreso autorizado no encontrado o no autorizado.', 1;

            SELECT @FKIdFacturaDetalleFactura_PRES = fd.FKIdFactura_PRES
            FROM PRES.FacturaDetalle fd
            WHERE fd.PKIdFacturaDetalle = @FKIdFacturaDetalle_PRES
              AND fd.Activo = 1;

            IF @FKIdFacturaDetalleFactura_PRES IS NULL
                THROW 51000, 'Detalle de factura no encontrado.', 1;

            SET @FKIdFactura_PRES = ISNULL(@FKIdFactura_PRES, @FKIdFacturaDetalleFactura_PRES);
            SET @Mes = MONTH(@Fecha);

            IF @Action = 2
            BEGIN
                SELECT
                    @ImporteActual = CASE
                        WHEN cf.FKIdIngresoAutorizado_PRES = @FKIdIngresoAutorizado_PRES
                         AND MONTH(ISNULL(cf.Fecha, CONVERT(DATE, cf.FechaCreacion))) = @Mes
                        THEN cf.MontoAplicado
                        ELSE 0
                    END,
                    @FechaActual = cf.Fecha,
                    @IngresoActual = cf.FKIdIngresoAutorizado_PRES
                FROM PRES.CLCFactura cf
                WHERE cf.PKIdCLCFactura = @PKIdCLCFactura
                  AND cf.Activo = 1;

                IF @IngresoActual IS NULL
                    THROW 51000, 'CLCFactura de ingreso no encontrada.', 1;
            END

            SELECT @Disponible = CASE @Mes
                WHEN 1 THEN ISNULL(Ene, 0)
                WHEN 2 THEN ISNULL(Feb, 0)
                WHEN 3 THEN ISNULL(Mar, 0)
                WHEN 4 THEN ISNULL(Abr, 0)
                WHEN 5 THEN ISNULL(May, 0)
                WHEN 6 THEN ISNULL(Jun, 0)
                WHEN 7 THEN ISNULL(Jul, 0)
                WHEN 8 THEN ISNULL(Ago, 0)
                WHEN 9 THEN ISNULL(Sep, 0)
                WHEN 10 THEN ISNULL(Oct, 0)
                WHEN 11 THEN ISNULL(Nov, 0)
                WHEN 12 THEN ISNULL(Dic, 0)
                ELSE 0
            END
            FROM PRES.VW_IngreXEjer
            WHERE Pk_IdIngresoAutorizado = @FKIdIngresoAutorizado_PRES;

            IF @Disponible IS NULL
                THROW 51000, 'No se encontro disponibilidad para el ingreso autorizado.', 1;

            IF @MontoAplicado > (@Disponible + @ImporteActual)
                THROW 51000, 'El monto aplicado excede la disponibilidad del ingreso en el mes seleccionado.', 1;
        END

        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            INSERT INTO PRES.CLCFactura
            (
                FKIdEmpresa_SIS,
                FKIdCLC_PRES,
                FKIdFactura_PRES,
                FKIdFacturaDetalle_PRES,
                FKIdIngresoAutorizado_PRES,
                Fecha,
                MontoAplicado,
                Observaciones,
                Activo,
                FechaCreacion,
                UsuarioCreacion
            )
            SELECT
                ISNULL(@FKIdEmpresa_SIS, clc.FKIdEmpresa_SIS),
                @FKIdCLC_PRES,
                @FKIdFactura_PRES,
                @FKIdFacturaDetalle_PRES,
                @FKIdIngresoAutorizado_PRES,
                @Fecha,
                @MontoAplicado,
                @Observaciones,
                1,
                @today,
                @IdUser
            FROM PRES.CLC clc
            WHERE clc.PKIdCLC = @FKIdCLC_PRES;

            SET @Id = SCOPE_IDENTITY();
            SET @message = N'CLCFactura de ingreso creada correctamente.';
            SET @liga = CONCAT(N'idCLCFactura:', @Id);
        END
        ELSE IF @Action = 2
        BEGIN
            UPDATE cf
            SET FKIdEmpresa_SIS = ISNULL(@FKIdEmpresa_SIS, cf.FKIdEmpresa_SIS),
                FKIdCLC_PRES = @FKIdCLC_PRES,
                FKIdFactura_PRES = @FKIdFactura_PRES,
                FKIdFacturaDetalle_PRES = @FKIdFacturaDetalle_PRES,
                FKIdIngresoAutorizado_PRES = @FKIdIngresoAutorizado_PRES,
                Fecha = @Fecha,
                MontoAplicado = @MontoAplicado,
                Observaciones = @Observaciones,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            FROM PRES.CLCFactura cf
            WHERE cf.PKIdCLCFactura = @PKIdCLCFactura
              AND cf.Activo = 1;

            SET @Id = @PKIdCLCFactura;
            SET @message = N'CLCFactura de ingreso actualizada correctamente.';
            SET @liga = CONCAT(N'idCLCFactura:', @Id);
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdCLCFactura IS NULL
               OR NOT EXISTS (SELECT 1 FROM PRES.CLCFactura WHERE PKIdCLCFactura = @PKIdCLCFactura AND Activo = 1)
                THROW 51000, 'CLCFactura de ingreso no encontrada.', 1;

            UPDATE PRES.CLCFactura
            SET Activo = 0,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdCLCFactura = @PKIdCLCFactura;

            SET @Id = @PKIdCLCFactura;
            SET @message = N'CLCFactura de ingreso eliminada correctamente.';
            SET @liga = CONCAT(N'idCLCFactura:', @Id);
        END
        ELSE IF @Action = 4
        BEGIN
            SELECT
                cf.PKIdCLCFactura,
                cf.FKIdEmpresa_SIS,
                emp.Nombre AS EmpresaNombre,
                cf.FKIdCLC_PRES,
                clc.NumCLC,
                cf.FKIdFactura_PRES,
                f.NumFactura,
                cf.FKIdFacturaDetalle_PRES,
                fd.FKIdPartida_CONTA,
                part.Clave AS PartidaClave,
                part.Descripcion AS PartidaDescripcion,
                cf.FKIdIngresoAutorizado_PRES,
                ing.Descripcion AS IngresoAutorizadoDescripcion,
                cf.Fecha,
                cf.MontoAplicado,
                cf.Observaciones,
                cf.Activo,
                cf.FechaCreacion,
                cf.UsuarioCreacion,
                cf.FechaModificacion,
                cf.UsuarioModificacion
            FROM PRES.CLCFactura cf
            INNER JOIN PRES.CLC clc
                ON cf.FKIdCLC_PRES = clc.PKIdCLC
            INNER JOIN PRES.Factura f
                ON cf.FKIdFactura_PRES = f.PKIdFactura
            INNER JOIN PRES.FacturaDetalle fd
                ON cf.FKIdFacturaDetalle_PRES = fd.PKIdFacturaDetalle
            LEFT JOIN SIS.Empresa emp
                ON cf.FKIdEmpresa_SIS = emp.PKIdEmpresa
            LEFT JOIN CONTA.Partida part
                ON fd.FKIdPartida_CONTA = part.PKIdPartida
            LEFT JOIN PRES.IngresoAutorizado ing
                ON cf.FKIdIngresoAutorizado_PRES = ing.PKIdIngresoAutorizado
            WHERE cf.PKIdCLCFactura = @PKIdCLCFactura
              AND cf.Activo = 1;

            SET @Id = @PKIdCLCFactura;
            SET @message = N'CLCFactura de ingreso consultada correctamente.';
            SET @liga = CONCAT(N'idCLCFactura:', @Id);
        END

        COMMIT TRANSACTION;

        SELECT (
            SELECT @tipo AS tipo, @message AS mensaje, @liga AS liga
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) AS ResultJson;

        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @tipo = N'ERROR';
        SET @message = CONCAT(ISNULL(PROGRAM_NAME(), N''), CHAR(10), N'Error: ', ERROR_MESSAGE(), CHAR(10), N'Linea: ', ERROR_LINE());

        SELECT (
            SELECT @tipo AS tipo, @message AS mensaje, N'' AS liga
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) AS ResultJson;

        RETURN -1;
    END CATCH
END
GO
