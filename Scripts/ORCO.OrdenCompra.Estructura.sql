USE [GestionEmpresarial];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF SCHEMA_ID(N'ORCO') IS NULL
    EXEC(N'CREATE SCHEMA ORCO');
GO

IF OBJECT_ID(N'ORCO.EstatusOrdenCompra', N'U') IS NULL
BEGIN
    CREATE TABLE ORCO.EstatusOrdenCompra
    (
        PK_IdEstatusOrdenCompra INT IDENTITY(1,1) NOT NULL,
        Descripcion NVARCHAR(50) NOT NULL,
        Color NVARCHAR(8) NOT NULL,
        CT_CreatedBy INT NOT NULL,
        CT_CreatedDate DATETIME NOT NULL,
        CT_ModifiedBy INT NULL,
        CT_ModifiedDate DATETIME NULL,
        CT_LIVE BIT NULL,
        CONSTRAINT PK_EstatusOrdenCompra PRIMARY KEY CLUSTERED (PK_IdEstatusOrdenCompra)
    );
END
GO

SET IDENTITY_INSERT ORCO.EstatusOrdenCompra ON;

MERGE ORCO.EstatusOrdenCompra AS target
USING
(
    VALUES
        (1, N'INICIAL', N'#FFD6D6', 1, CAST(GETDATE() AS DATETIME), NULL, NULL, 1),
        (2, N'POR SURTIR', N'#FFD6D6', 1, CAST(GETDATE() AS DATETIME), NULL, NULL, 1),
        (3, N'SURTIDO PARCIAL', N'#FFF8CC', 1, CAST(GETDATE() AS DATETIME), NULL, NULL, 1),
        (4, N'SURTIDO TOTAL', N'#DFF6DD', 1, CAST(GETDATE() AS DATETIME), NULL, NULL, 1),
        (5, N'CERRADO', N'#DFF6DD', 1, CAST(GETDATE() AS DATETIME), NULL, NULL, 1)
) AS source (PK_IdEstatusOrdenCompra, Descripcion, Color, CT_CreatedBy, CT_CreatedDate, CT_ModifiedBy, CT_ModifiedDate, CT_LIVE)
ON target.PK_IdEstatusOrdenCompra = source.PK_IdEstatusOrdenCompra
WHEN MATCHED THEN
    UPDATE SET
        Descripcion = source.Descripcion,
        Color = source.Color,
        CT_LIVE = source.CT_LIVE
WHEN NOT MATCHED THEN
    INSERT (PK_IdEstatusOrdenCompra, Descripcion, Color, CT_CreatedBy, CT_CreatedDate, CT_ModifiedBy, CT_ModifiedDate, CT_LIVE)
    VALUES (source.PK_IdEstatusOrdenCompra, source.Descripcion, source.Color, source.CT_CreatedBy, source.CT_CreatedDate, source.CT_ModifiedBy, source.CT_ModifiedDate, source.CT_LIVE);

SET IDENTITY_INSERT ORCO.EstatusOrdenCompra OFF;
GO

IF OBJECT_ID(N'ORCO.OrdenCompra', N'U') IS NULL
BEGIN
    CREATE TABLE ORCO.OrdenCompra
    (
        PKIdOrdenCompra INT IDENTITY(1,1) NOT NULL,
        FKIdEmpresa_SIS INT NOT NULL,
        FKIdRequisicion_ORCO INT NOT NULL,
        FKIdProveedor_SIS INT NOT NULL,
        FKIdPoliza_CONTA INT NULL,
        FKIdEstatusOrdenCompra_ORCO INT NOT NULL,
        NumeroOrdenCompra NVARCHAR(50) NOT NULL,
        Descripcion NVARCHAR(500) NULL,
        FechaOrdenCompra DATE NOT NULL,
        FechaRequerida DATE NULL,
        FechaEntrega DATE NULL,
        FechaVigencia DATE NULL,
        FechaCancelacion DATE NULL,
        MotivoCancelacion NVARCHAR(MAX) NULL,
        Subtotal DECIMAL(20,4) NOT NULL CONSTRAINT DF_OrdenCompra_Subtotal DEFAULT 0,
        Iva DECIMAL(20,4) NOT NULL CONSTRAINT DF_OrdenCompra_Iva DEFAULT 0,
        Total DECIMAL(20,4) NOT NULL CONSTRAINT DF_OrdenCompra_Total DEFAULT 0,
        MonedaId INT NULL,
        TipoCambio DECIMAL(18,6) NULL,
        Observaciones NVARCHAR(MAX) NULL,
        CompraDirecta BIT NOT NULL CONSTRAINT DF_OrdenCompra_CompraDirecta DEFAULT 0,
        FL_Documento NVARCHAR(1000) NULL,
        Activo BIT NOT NULL CONSTRAINT DF_OrdenCompra_Activo DEFAULT 1,
        FechaCreacion DATETIME2(7) NOT NULL CONSTRAINT DF_OrdenCompra_FechaCreacion DEFAULT SYSDATETIME(),
        UsuarioCreacion INT NOT NULL,
        FechaModificacion DATETIME2(7) NULL,
        UsuarioModificacion INT NULL,
        CONSTRAINT PK_OrdenCompra PRIMARY KEY CLUSTERED (PKIdOrdenCompra),
        CONSTRAINT FK_OrdenCompra_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
        CONSTRAINT FK_OrdenCompra_Requisicion FOREIGN KEY (FKIdRequisicion_ORCO) REFERENCES ORCO.Requisicion(PKIdRequisicion),
        CONSTRAINT FK_OrdenCompra_Proveedor FOREIGN KEY (FKIdProveedor_SIS) REFERENCES SIS.Proveedor(PKIdProveedor),
        CONSTRAINT FK_OrdenCompra_Poliza FOREIGN KEY (FKIdPoliza_CONTA) REFERENCES CONTA.Poliza(PKIdPoliza),
        CONSTRAINT FK_OrdenCompra_Estatus FOREIGN KEY (FKIdEstatusOrdenCompra_ORCO) REFERENCES ORCO.EstatusOrdenCompra(PK_IdEstatusOrdenCompra),
        CONSTRAINT UQ_OrdenCompra_Numero UNIQUE (NumeroOrdenCompra)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OrdenCompra_Estatus' AND object_id = OBJECT_ID(N'ORCO.OrdenCompra'))
    CREATE INDEX IX_OrdenCompra_Estatus ON ORCO.OrdenCompra (FKIdEstatusOrdenCompra_ORCO) WHERE Activo = 1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OrdenCompra_Proveedor' AND object_id = OBJECT_ID(N'ORCO.OrdenCompra'))
    CREATE INDEX IX_OrdenCompra_Proveedor ON ORCO.OrdenCompra (FKIdProveedor_SIS) WHERE Activo = 1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OrdenCompra_Fecha' AND object_id = OBJECT_ID(N'ORCO.OrdenCompra'))
    CREATE INDEX IX_OrdenCompra_Fecha ON ORCO.OrdenCompra (FechaOrdenCompra) WHERE Activo = 1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OrdenCompra_Requisicion' AND object_id = OBJECT_ID(N'ORCO.OrdenCompra'))
    CREATE INDEX IX_OrdenCompra_Requisicion ON ORCO.OrdenCompra (FKIdRequisicion_ORCO) WHERE Activo = 1;
GO

IF OBJECT_ID(N'ORCO.OrdenCompraDetalle', N'U') IS NULL
BEGIN
    CREATE TABLE ORCO.OrdenCompraDetalle
    (
        PKIdOrdenCompraDetalle INT IDENTITY(1,1) NOT NULL,
        FKIdOrdenCompra_ORCO INT NOT NULL,
        FKIdRequisicionDetalle_ORCO INT NULL,
        FKIdCotizacionDetalle_ORCO INT NULL,
        FKIdTipoBien_ALMA INT NOT NULL,
        FKIdUnidades_ALMA INT NOT NULL,
        CantidadSolicitada DECIMAL(18,4) NOT NULL,
        CantidadRecibida DECIMAL(18,4) NOT NULL CONSTRAINT DF_OrdenCompraDetalle_CantidadRecibida DEFAULT 0,
        CantidadPendiente AS (CantidadSolicitada - CantidadRecibida),
        PrecioUnitario DECIMAL(20,4) NOT NULL,
        Importe AS (CantidadSolicitada * PrecioUnitario),
        Iva DECIMAL(20,4) NOT NULL CONSTRAINT DF_OrdenCompraDetalle_Iva DEFAULT 0,
        TotalDetalle AS ((CantidadSolicitada * PrecioUnitario) + Iva),
        Observaciones NVARCHAR(MAX) NULL,
        Activo BIT NOT NULL CONSTRAINT DF_OrdenCompraDetalle_Activo DEFAULT 1,
        FechaCreacion DATETIME2(7) NOT NULL CONSTRAINT DF_OrdenCompraDetalle_FechaCreacion DEFAULT SYSDATETIME(),
        UsuarioCreacion INT NOT NULL,
        FechaModificacion DATETIME2(7) NULL,
        UsuarioModificacion INT NULL,
        CONSTRAINT PK_OrdenCompraDetalle PRIMARY KEY CLUSTERED (PKIdOrdenCompraDetalle),
        CONSTRAINT FK_OrdenCompraDetalle_OrdenCompra FOREIGN KEY (FKIdOrdenCompra_ORCO) REFERENCES ORCO.OrdenCompra(PKIdOrdenCompra),
        CONSTRAINT FK_OrdenCompraDetalle_RequisicionDetalle FOREIGN KEY (FKIdRequisicionDetalle_ORCO) REFERENCES ORCO.RequisicionDetalle(PKIdRequisicionDetalle),
        CONSTRAINT FK_OrdenCompraDetalle_CotizacionDetalle FOREIGN KEY (FKIdCotizacionDetalle_ORCO) REFERENCES ORCO.CotizacionDetalle(PKIdCotizacionDetalle),
        CONSTRAINT FK_OrdenCompraDetalle_TipoBien FOREIGN KEY (FKIdTipoBien_ALMA) REFERENCES ALMA.TipoBien(PKIdTipoBien),
        CONSTRAINT FK_OrdenCompraDetalle_Unidades FOREIGN KEY (FKIdUnidades_ALMA) REFERENCES ALMA.Unidades(PKIdUnidades)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OrdenCompraDetalle_Orden' AND object_id = OBJECT_ID(N'ORCO.OrdenCompraDetalle'))
    CREATE INDEX IX_OrdenCompraDetalle_Orden ON ORCO.OrdenCompraDetalle (FKIdOrdenCompra_ORCO) WHERE Activo = 1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OrdenCompraDetalle_TipoBien' AND object_id = OBJECT_ID(N'ORCO.OrdenCompraDetalle'))
    CREATE INDEX IX_OrdenCompraDetalle_TipoBien ON ORCO.OrdenCompraDetalle (FKIdTipoBien_ALMA) WHERE Activo = 1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OrdenCompraDetalle_RequisicionDet' AND object_id = OBJECT_ID(N'ORCO.OrdenCompraDetalle'))
    CREATE INDEX IX_OrdenCompraDetalle_RequisicionDet ON ORCO.OrdenCompraDetalle (FKIdRequisicionDetalle_ORCO) WHERE Activo = 1;
GO

IF OBJECT_ID(N'ORCO.OrdenCompraPartida', N'U') IS NULL
BEGIN
    CREATE TABLE ORCO.OrdenCompraPartida
    (
        PKIdOrdenCompraPartida INT IDENTITY(1,1) NOT NULL,
        FKIdOrdenCompra_ORCO INT NOT NULL,
        FKIdPartida_CONTA INT NOT NULL,
        FKIdFuenteFinanciamiento_PRES INT NULL,
        Importe DECIMAL(20,4) NOT NULL,
        Observaciones NVARCHAR(MAX) NULL,
        Activo BIT NOT NULL CONSTRAINT DF_OrdenCompraPartida_Activo DEFAULT 1,
        FechaCreacion DATETIME2(7) NOT NULL CONSTRAINT DF_OrdenCompraPartida_FechaCreacion DEFAULT SYSDATETIME(),
        UsuarioCreacion INT NOT NULL,
        FechaModificacion DATETIME2(7) NULL,
        UsuarioModificacion INT NULL,
        CONSTRAINT PK_OrdenCompraPartida PRIMARY KEY CLUSTERED (PKIdOrdenCompraPartida),
        CONSTRAINT FK_OrdenCompraPartida_OrdenCompra FOREIGN KEY (FKIdOrdenCompra_ORCO) REFERENCES ORCO.OrdenCompra(PKIdOrdenCompra),
        CONSTRAINT FK_OrdenCompraPartida_Partida FOREIGN KEY (FKIdPartida_CONTA) REFERENCES CONTA.Partida(PKIdPartida),
        CONSTRAINT FK_OrdenCompraPartida_Fuente FOREIGN KEY (FKIdFuenteFinanciamiento_PRES) REFERENCES PRES.FuenteFinanciamiento(PKIdFuenteFinanciamiento)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OrdenCompraPartida_Orden' AND object_id = OBJECT_ID(N'ORCO.OrdenCompraPartida'))
    CREATE INDEX IX_OrdenCompraPartida_Orden ON ORCO.OrdenCompraPartida (FKIdOrdenCompra_ORCO) WHERE Activo = 1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OrdenCompraPartida_Partida' AND object_id = OBJECT_ID(N'ORCO.OrdenCompraPartida'))
    CREATE INDEX IX_OrdenCompraPartida_Partida ON ORCO.OrdenCompraPartida (FKIdPartida_CONTA) WHERE Activo = 1;
GO

CREATE OR ALTER PROCEDURE [ORCO].[SP_MantenimientoOrdenCompra]
    @Action INT,
    @PKIdOrdenCompra INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdRequisicion_ORCO INT = NULL,
    @FKIdProveedor_SIS INT = NULL,
    @FKIdPoliza_CONTA INT = NULL,
    @FKIdEstatusOrdenCompra_ORCO INT = NULL,
    @NumeroOrdenCompra NVARCHAR(50) = NULL,
    @Descripcion NVARCHAR(500) = NULL,
    @FechaOrdenCompra DATE = NULL,
    @FechaRequerida DATE = NULL,
    @FechaEntrega DATE = NULL,
    @FechaVigencia DATE = NULL,
    @FechaCancelacion DATE = NULL,
    @MotivoCancelacion NVARCHAR(MAX) = NULL,
    @Subtotal DECIMAL(20,4) = NULL,
    @Iva DECIMAL(20,4) = NULL,
    @Total DECIMAL(20,4) = NULL,
    @MonedaId INT = NULL,
    @TipoCambio DECIMAL(20,6) = NULL,
    @Observaciones NVARCHAR(MAX) = NULL,
    @CompraDirecta BIT = NULL,
    @FL_Documento NVARCHAR(1000) = NULL,
    @IdUser INT = NULL,
    @IdAnio INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Tipo NVARCHAR(20) = N'OK';
    DECLARE @Mensaje NVARCHAR(1000) = N'Operacion realizada correctamente.';
    DECLARE @Liga NVARCHAR(100) = N'idOrdenCompra:0';

    BEGIN TRY
        BEGIN TRAN;

        IF @Action = 1
        BEGIN
            IF @FechaOrdenCompra IS NULL
                THROW 51000, N'La fecha de la orden de compra es obligatoria.', 1;

            IF @FKIdRequisicion_ORCO IS NOT NULL
            BEGIN
                DECLARE @FechaRequisicion DATE;

                SELECT @FechaRequisicion = r.FechaRequisicion
                FROM ORCO.Requisicion r
                WHERE r.PKIdRequisicion = @FKIdRequisicion_ORCO
                  AND r.Activo = 1;

                IF @FechaRequisicion IS NOT NULL AND @FechaOrdenCompra < @FechaRequisicion
                    THROW 51000, N'La fecha de la orden de compra debe ser igual o mayor a la fecha de requisicion.', 1;
            END;

            IF NULLIF(LTRIM(RTRIM(@NumeroOrdenCompra)), N'') IS NULL
            BEGIN
                DECLARE @Anio INT = ISNULL(@IdAnio, YEAR(@FechaOrdenCompra));
                DECLARE @Consecutivo INT;

                SELECT @Consecutivo = ISNULL(MAX(TRY_CONVERT(INT, RIGHT(NumeroOrdenCompra, 4))), 0) + 1
                FROM ORCO.OrdenCompra
                WHERE NumeroOrdenCompra LIKE CONCAT(N'OC-', @Anio, N'-%');

                SET @NumeroOrdenCompra = CONCAT(N'OC-', @Anio, N'-', RIGHT(CONCAT(N'0000', @Consecutivo), 4));
            END;

            INSERT INTO ORCO.OrdenCompra
            (
                FKIdEmpresa_SIS,
                FKIdRequisicion_ORCO,
                FKIdProveedor_SIS,
                FKIdPoliza_CONTA,
                FKIdEstatusOrdenCompra_ORCO,
                NumeroOrdenCompra,
                Descripcion,
                FechaOrdenCompra,
                FechaRequerida,
                FechaEntrega,
                FechaVigencia,
                FechaCancelacion,
                MotivoCancelacion,
                Subtotal,
                Iva,
                Total,
                MonedaId,
                TipoCambio,
                Observaciones,
                CompraDirecta,
                FL_Documento,
                Activo,
                FechaCreacion,
                UsuarioCreacion
            )
            VALUES
            (
                @FKIdEmpresa_SIS,
                @FKIdRequisicion_ORCO,
                @FKIdProveedor_SIS,
                @FKIdPoliza_CONTA,
                @FKIdEstatusOrdenCompra_ORCO,
                @NumeroOrdenCompra,
                @Descripcion,
                @FechaOrdenCompra,
                @FechaRequerida,
                @FechaEntrega,
                @FechaVigencia,
                @FechaCancelacion,
                @MotivoCancelacion,
                ISNULL(@Subtotal, 0),
                ISNULL(@Iva, 0),
                ISNULL(@Total, 0),
                @MonedaId,
                ISNULL(@TipoCambio, 1),
                @Observaciones,
                ISNULL(@CompraDirecta, 0),
                @FL_Documento,
                1,
                GETDATE(),
                @IdUser
            );

            SET @PKIdOrdenCompra = CONVERT(INT, SCOPE_IDENTITY());
            SET @Mensaje = N'Orden de compra registrada correctamente.';
        END
        ELSE IF @Action = 2
        BEGIN
            IF NOT EXISTS (
                SELECT 1
                FROM ORCO.OrdenCompra
                WHERE PKIdOrdenCompra = @PKIdOrdenCompra
                  AND Activo = 1
            )
                THROW 51000, N'La orden de compra no existe o esta inactiva.', 1;

            IF @FKIdRequisicion_ORCO IS NOT NULL AND @FechaOrdenCompra IS NOT NULL
            BEGIN
                SELECT @FechaRequisicion = r.FechaRequisicion
                FROM ORCO.Requisicion r
                WHERE r.PKIdRequisicion = @FKIdRequisicion_ORCO
                  AND r.Activo = 1;

                IF @FechaRequisicion IS NOT NULL AND @FechaOrdenCompra < @FechaRequisicion
                    THROW 51000, N'La fecha de la orden de compra debe ser igual o mayor a la fecha de requisicion.', 1;
            END;

            UPDATE ORCO.OrdenCompra
            SET
                FKIdEmpresa_SIS = @FKIdEmpresa_SIS,
                FKIdRequisicion_ORCO = @FKIdRequisicion_ORCO,
                FKIdProveedor_SIS = @FKIdProveedor_SIS,
                FKIdPoliza_CONTA = @FKIdPoliza_CONTA,
                FKIdEstatusOrdenCompra_ORCO = @FKIdEstatusOrdenCompra_ORCO,
                NumeroOrdenCompra = COALESCE(NULLIF(LTRIM(RTRIM(@NumeroOrdenCompra)), N''), NumeroOrdenCompra),
                Descripcion = @Descripcion,
                FechaOrdenCompra = @FechaOrdenCompra,
                FechaRequerida = @FechaRequerida,
                FechaEntrega = @FechaEntrega,
                FechaVigencia = @FechaVigencia,
                FechaCancelacion = @FechaCancelacion,
                MotivoCancelacion = @MotivoCancelacion,
                Subtotal = ISNULL(@Subtotal, Subtotal),
                Iva = ISNULL(@Iva, Iva),
                Total = ISNULL(@Total, Total),
                MonedaId = @MonedaId,
                TipoCambio = ISNULL(@TipoCambio, TipoCambio),
                Observaciones = @Observaciones,
                CompraDirecta = ISNULL(@CompraDirecta, CompraDirecta),
                FL_Documento = @FL_Documento,
                FechaModificacion = GETDATE(),
                UsuarioModificacion = @IdUser
            WHERE PKIdOrdenCompra = @PKIdOrdenCompra;

            SET @Mensaje = N'Orden de compra actualizada correctamente.';
        END
        ELSE IF @Action = 3
        BEGIN
            UPDATE ORCO.OrdenCompraDetalle
            SET Activo = 0,
                FechaModificacion = GETDATE(),
                UsuarioModificacion = @IdUser
            WHERE FKIdOrdenCompra_ORCO = @PKIdOrdenCompra;

            UPDATE ORCO.OrdenCompraPartida
            SET Activo = 0,
                FechaModificacion = GETDATE(),
                UsuarioModificacion = @IdUser
            WHERE FKIdOrdenCompra_ORCO = @PKIdOrdenCompra;

            UPDATE ORCO.OrdenCompra
            SET Activo = 0,
                FechaModificacion = GETDATE(),
                UsuarioModificacion = @IdUser
            WHERE PKIdOrdenCompra = @PKIdOrdenCompra;

            SET @Mensaje = N'Orden de compra eliminada correctamente.';
        END
        ELSE
            THROW 51000, N'Accion no valida.', 1;

        COMMIT;

        SET @Liga = CONCAT(N'idOrdenCompra:', ISNULL(@PKIdOrdenCompra, 0));

        SELECT ResultJson = (
            SELECT @Tipo AS Tipo, @Mensaje AS Mensaje, @Liga AS Liga
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;

        IF ERROR_NUMBER() <> 51000
            THROW;

        SELECT ResultJson = (
            SELECT
                N'ERROR' AS Tipo,
                ERROR_MESSAGE() AS Mensaje,
                CONCAT(N'idOrdenCompra:', ISNULL(@PKIdOrdenCompra, 0)) AS Liga
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE [ORCO].[SP_MantenimientoOrdenCompraDetalle]
    @Action INT,
    @PKIdOrdenCompraDetalle INT = NULL,
    @FKIdOrdenCompra_ORCO INT = NULL,
    @FKIdRequisicionDetalle_ORCO INT = NULL,
    @FKIdCotizacionDetalle_ORCO INT = NULL,
    @FKIdTipoBien_ALMA INT = NULL,
    @FKIdUnidades_ALMA INT = NULL,
    @CantidadSolicitada DECIMAL(18,4) = NULL,
    @CantidadRecibida DECIMAL(18,4) = NULL,
    @PrecioUnitario DECIMAL(20,4) = NULL,
    @Iva DECIMAL(20,4) = NULL,
    @Observaciones NVARCHAR(MAX) = NULL,
    @IdUser INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        IF @Action IN (1, 2)
        BEGIN
            IF NOT EXISTS (
                SELECT 1
                FROM ORCO.OrdenCompra
                WHERE PKIdOrdenCompra = @FKIdOrdenCompra_ORCO
                  AND Activo = 1
            )
                THROW 51000, N'La orden de compra no existe o esta inactiva.', 1;

            IF @FKIdRequisicionDetalle_ORCO IS NOT NULL
            BEGIN
                DECLARE @CantidadRequisicion DECIMAL(18,4);
                DECLARE @CantidadYaOrdenada DECIMAL(18,4);

                SELECT @CantidadRequisicion = rd.Cantidad
                FROM ORCO.RequisicionDetalle rd
                WHERE rd.PKIdRequisicionDetalle = @FKIdRequisicionDetalle_ORCO
                  AND rd.Activo = 1;

                SELECT @CantidadYaOrdenada = ISNULL(SUM(od.CantidadSolicitada), 0)
                FROM ORCO.OrdenCompraDetalle od
                WHERE od.FKIdRequisicionDetalle_ORCO = @FKIdRequisicionDetalle_ORCO
                  AND od.Activo = 1
                  AND od.PKIdOrdenCompraDetalle <> ISNULL(@PKIdOrdenCompraDetalle, 0);

                IF @CantidadRequisicion IS NOT NULL
                   AND ISNULL(@CantidadSolicitada, 0) + ISNULL(@CantidadYaOrdenada, 0) > @CantidadRequisicion
                    THROW 51000, N'No se puede guardar la orden de compra. Excede la cantidad de la requisicion.', 1;
            END;

            SET @CantidadSolicitada = ISNULL(@CantidadSolicitada, 0);
            SET @CantidadRecibida = ISNULL(@CantidadRecibida, 0);
            SET @PrecioUnitario = ISNULL(@PrecioUnitario, 0);
            SET @Iva = ISNULL(@Iva, 0);
        END;

        IF @Action = 1
        BEGIN
            INSERT INTO ORCO.OrdenCompraDetalle
            (
                FKIdOrdenCompra_ORCO,
                FKIdRequisicionDetalle_ORCO,
                FKIdCotizacionDetalle_ORCO,
                FKIdTipoBien_ALMA,
                FKIdUnidades_ALMA,
                CantidadSolicitada,
                CantidadRecibida,
                PrecioUnitario,
                Iva,
                Observaciones,
                Activo,
                FechaCreacion,
                UsuarioCreacion
            )
            VALUES
            (
                @FKIdOrdenCompra_ORCO,
                @FKIdRequisicionDetalle_ORCO,
                @FKIdCotizacionDetalle_ORCO,
                @FKIdTipoBien_ALMA,
                @FKIdUnidades_ALMA,
                @CantidadSolicitada,
                @CantidadRecibida,
                @PrecioUnitario,
                @Iva,
                @Observaciones,
                1,
                GETDATE(),
                @IdUser
            );

            SET @PKIdOrdenCompraDetalle = CONVERT(INT, SCOPE_IDENTITY());
        END
        ELSE IF @Action = 2
        BEGIN
            UPDATE ORCO.OrdenCompraDetalle
            SET
                FKIdOrdenCompra_ORCO = @FKIdOrdenCompra_ORCO,
                FKIdRequisicionDetalle_ORCO = @FKIdRequisicionDetalle_ORCO,
                FKIdCotizacionDetalle_ORCO = @FKIdCotizacionDetalle_ORCO,
                FKIdTipoBien_ALMA = @FKIdTipoBien_ALMA,
                FKIdUnidades_ALMA = @FKIdUnidades_ALMA,
                CantidadSolicitada = @CantidadSolicitada,
                CantidadRecibida = @CantidadRecibida,
                PrecioUnitario = @PrecioUnitario,
                Iva = @Iva,
                Observaciones = @Observaciones,
                FechaModificacion = GETDATE(),
                UsuarioModificacion = @IdUser
            WHERE PKIdOrdenCompraDetalle = @PKIdOrdenCompraDetalle
              AND Activo = 1;
        END
        ELSE IF @Action = 3
        BEGIN
            SELECT @FKIdOrdenCompra_ORCO = FKIdOrdenCompra_ORCO
            FROM ORCO.OrdenCompraDetalle
            WHERE PKIdOrdenCompraDetalle = @PKIdOrdenCompraDetalle;

            UPDATE ORCO.OrdenCompraDetalle
            SET Activo = 0,
                FechaModificacion = GETDATE(),
                UsuarioModificacion = @IdUser
            WHERE PKIdOrdenCompraDetalle = @PKIdOrdenCompraDetalle;
        END
        ELSE
            THROW 51000, N'Accion no valida.', 1;

        UPDATE oc
        SET
            Subtotal = ISNULL(t.Subtotal, 0),
            Iva = ISNULL(t.Iva, 0),
            Total = ISNULL(t.Total, 0),
            FechaModificacion = GETDATE(),
            UsuarioModificacion = @IdUser
        FROM ORCO.OrdenCompra oc
        OUTER APPLY
        (
            SELECT
                SUM(od.Importe) AS Subtotal,
                SUM(od.Iva) AS Iva,
                SUM(od.TotalDetalle) AS Total
            FROM ORCO.OrdenCompraDetalle od
            WHERE od.FKIdOrdenCompra_ORCO = oc.PKIdOrdenCompra
              AND od.Activo = 1
        ) t
        WHERE oc.PKIdOrdenCompra = @FKIdOrdenCompra_ORCO;

        COMMIT;

        SELECT ResultJson = (
            SELECT
                N'OK' AS Tipo,
                N'Detalle de orden de compra guardado correctamente.' AS Mensaje,
                CONCAT(N'idOrdenCompraDetalle:', ISNULL(@PKIdOrdenCompraDetalle, 0)) AS Liga
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;

        IF ERROR_NUMBER() <> 51000
            THROW;

        SELECT ResultJson = (
            SELECT
                N'ERROR' AS Tipo,
                ERROR_MESSAGE() AS Mensaje,
                CONCAT(N'idOrdenCompraDetalle:', ISNULL(@PKIdOrdenCompraDetalle, 0)) AS Liga
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE [ORCO].[SP_MantenimientoOrdenCompraPartida]
    @Action INT,
    @PKIdOrdenCompraPartida INT = NULL,
    @FKIdOrdenCompra_ORCO INT = NULL,
    @FKIdPartida_CONTA INT = NULL,
    @FKIdFuenteFinanciamiento_PRES INT = NULL,
    @Importe DECIMAL(20,4) = NULL,
    @Observaciones NVARCHAR(MAX) = NULL,
    @IdUser INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        IF @Action IN (1, 2)
        BEGIN
            IF NOT EXISTS (
                SELECT 1
                FROM ORCO.OrdenCompra
                WHERE PKIdOrdenCompra = @FKIdOrdenCompra_ORCO
                  AND Activo = 1
            )
                THROW 51000, N'La orden de compra no existe o esta inactiva.', 1;

            IF ISNULL(@Importe, 0) < 0
                THROW 51000, N'El importe de la partida no puede ser negativo.', 1;

            DECLARE @TotalOrden DECIMAL(20,4);
            DECLARE @TotalPartidas DECIMAL(20,4);

            SELECT @TotalOrden = ISNULL(Total, 0)
            FROM ORCO.OrdenCompra
            WHERE PKIdOrdenCompra = @FKIdOrdenCompra_ORCO;

            SELECT @TotalPartidas = ISNULL(SUM(Importe), 0)
            FROM ORCO.OrdenCompraPartida
            WHERE FKIdOrdenCompra_ORCO = @FKIdOrdenCompra_ORCO
              AND Activo = 1
              AND PKIdOrdenCompraPartida <> ISNULL(@PKIdOrdenCompraPartida, 0);

            IF @TotalOrden > 0 AND @TotalPartidas + ISNULL(@Importe, 0) > @TotalOrden
                THROW 51000, N'El importe de las partidas excede el total de la orden de compra.', 1;
        END;

        IF @Action = 1
        BEGIN
            INSERT INTO ORCO.OrdenCompraPartida
            (
                FKIdOrdenCompra_ORCO,
                FKIdPartida_CONTA,
                FKIdFuenteFinanciamiento_PRES,
                Importe,
                Observaciones,
                Activo,
                FechaCreacion,
                UsuarioCreacion
            )
            VALUES
            (
                @FKIdOrdenCompra_ORCO,
                @FKIdPartida_CONTA,
                @FKIdFuenteFinanciamiento_PRES,
                ISNULL(@Importe, 0),
                @Observaciones,
                1,
                GETDATE(),
                @IdUser
            );

            SET @PKIdOrdenCompraPartida = CONVERT(INT, SCOPE_IDENTITY());
        END
        ELSE IF @Action = 2
        BEGIN
            UPDATE ORCO.OrdenCompraPartida
            SET
                FKIdOrdenCompra_ORCO = @FKIdOrdenCompra_ORCO,
                FKIdPartida_CONTA = @FKIdPartida_CONTA,
                FKIdFuenteFinanciamiento_PRES = @FKIdFuenteFinanciamiento_PRES,
                Importe = ISNULL(@Importe, 0),
                Observaciones = @Observaciones,
                FechaModificacion = GETDATE(),
                UsuarioModificacion = @IdUser
            WHERE PKIdOrdenCompraPartida = @PKIdOrdenCompraPartida
              AND Activo = 1;
        END
        ELSE IF @Action = 3
        BEGIN
            UPDATE ORCO.OrdenCompraPartida
            SET Activo = 0,
                FechaModificacion = GETDATE(),
                UsuarioModificacion = @IdUser
            WHERE PKIdOrdenCompraPartida = @PKIdOrdenCompraPartida;
        END
        ELSE
            THROW 51000, N'Accion no valida.', 1;

        COMMIT;

        SELECT ResultJson = (
            SELECT
                N'OK' AS Tipo,
                N'Partida de orden de compra guardada correctamente.' AS Mensaje,
                CONCAT(N'idOrdenCompraPartida:', ISNULL(@PKIdOrdenCompraPartida, 0)) AS Liga
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;

        IF ERROR_NUMBER() <> 51000
            THROW;

        SELECT ResultJson = (
            SELECT
                N'ERROR' AS Tipo,
                ERROR_MESSAGE() AS Mensaje,
                CONCAT(N'idOrdenCompraPartida:', ISNULL(@PKIdOrdenCompraPartida, 0)) AS Liga
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
    END CATCH
END;
GO
