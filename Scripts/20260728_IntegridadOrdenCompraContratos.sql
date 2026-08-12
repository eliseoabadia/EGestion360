/*
    Integridad de adjudicacion y contratos.

    Reglas:
      - Una compra ordinaria requiere tres cotizaciones completas.
      - La orden conserva la cotizacion adjudicada.
      - Requisicion, proveedor, cotizacion y detalles deben corresponder.
      - Compra directa conserva la excepcion y permite cotizacion nula.
      - Un compromiso ORCO por orden y un contrato PRES por autorizacion.
      - El contrato PRES usa proveedor cotizante y el total autorizado.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF COL_LENGTH('ORCO.OrdenCompra', 'FKIdCotizacion_ORCO') IS NULL
BEGIN
    ALTER TABLE ORCO.OrdenCompra ADD FKIdCotizacion_ORCO int NULL;
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE parent_object_id = OBJECT_ID(N'ORCO.OrdenCompra')
      AND name = N'FK_OrdenCompra_Cotizacion'
)
BEGIN
    ALTER TABLE ORCO.OrdenCompra WITH CHECK
        ADD CONSTRAINT FK_OrdenCompra_Cotizacion
        FOREIGN KEY (FKIdCotizacion_ORCO)
        REFERENCES ORCO.Cotizacion(PKIdCotizacion);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'ORCO.OrdenCompra')
      AND name = N'IX_OrdenCompra_Cotizacion'
)
BEGIN
    CREATE INDEX IX_OrdenCompra_Cotizacion
        ON ORCO.OrdenCompra(FKIdCotizacion_ORCO)
        WHERE Activo = 1;
END;
GO

/* Recupera la cotizacion cuando todos los detalles existentes apuntan a una sola. */
UPDATE oc
SET FKIdCotizacion_ORCO = x.FKIdCotizacion_ORCO
FROM ORCO.OrdenCompra oc
CROSS APPLY (
    SELECT MIN(cd.FKIdCotizacion_ORCO) FKIdCotizacion_ORCO,
           MAX(cd.FKIdCotizacion_ORCO) MaxCotizacion
    FROM ORCO.OrdenCompraDetalle od
    INNER JOIN ORCO.CotizacionDetalle cd
        ON cd.PKIdCotizacionDetalle = od.FKIdCotizacionDetalle_ORCO
       AND cd.Activo = 1
    WHERE od.FKIdOrdenCompra_ORCO = oc.PKIdOrdenCompra
      AND od.Activo = 1
) x
WHERE oc.FKIdCotizacion_ORCO IS NULL
  AND x.FKIdCotizacion_ORCO = x.MaxCotizacion;
GO

IF EXISTS (
    SELECT 1
    FROM ORCO.Contratos
    WHERE Activo = 1 AND FKIdOrdenCompra_ORCO IS NOT NULL
    GROUP BY FKIdOrdenCompra_ORCO
    HAVING COUNT(*) > 1
)
    THROW 51040, 'Existen compromisos ORCO activos duplicados por orden de compra.', 1;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'ORCO.Contratos')
      AND name = N'UX_Contratos_OrdenCompra_Activo'
)
BEGIN
    CREATE UNIQUE INDEX UX_Contratos_OrdenCompra_Activo
        ON ORCO.Contratos(FKIdOrdenCompra_ORCO)
        WHERE Activo = 1 AND FKIdOrdenCompra_ORCO IS NOT NULL;
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE parent_object_id = OBJECT_ID(N'ORCO.Contratos')
      AND name = N'FK_Contratos_OrdenCompra'
)
BEGIN
    ALTER TABLE ORCO.Contratos WITH CHECK
        ADD CONSTRAINT FK_Contratos_OrdenCompra
        FOREIGN KEY (FKIdOrdenCompra_ORCO)
        REFERENCES ORCO.OrdenCompra(PKIdOrdenCompra);
END;
GO

IF EXISTS (
    SELECT 1
    FROM PRES.Contrato
    WHERE Activo = 1
    GROUP BY FKIdAutorizacionSuficiencia_PRES
    HAVING COUNT(*) > 1
)
    THROW 51041, 'Existen contratos PRES activos duplicados por autorizacion de suficiencia.', 1;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'PRES.Contrato')
      AND name = N'UX_Contrato_Autorizacion_Activo'
)
BEGIN
    CREATE UNIQUE INDEX UX_Contrato_Autorizacion_Activo
        ON PRES.Contrato(FKIdAutorizacionSuficiencia_PRES)
        WHERE Activo = 1;
END;
GO

CREATE OR ALTER VIEW ORCO.Vw_OrdenCompra
AS
SELECT
    oc.PKIdOrdenCompra,
    oc.FKIdEmpresa_SIS,
    e.Nombre AS EmpresaNombre,
    oc.FKIdRequisicion_ORCO,
    r.Descripcion AS RequisicionDescripcion,
    r.FechaRequisicion,
    oc.FKIdCotizacion_ORCO,
    CASE WHEN oc.FKIdCotizacion_ORCO IS NULL
         THEN NULL
         ELSE CONCAT('COT-', oc.FKIdCotizacion_ORCO, ' | ', ISNULL(p.Nombre, ''))
    END AS CotizacionDescripcion,
    oc.FKIdProveedor_SIS,
    p.Nombre AS ProveedorNombre,
    p.Clave AS ProveedorClave,
    p.RFC AS ProveedorRFC,
    oc.FKIdPoliza_CONTA,
    po.ClavePoliza,
    oc.FKIdEstatusOrdenCompra_ORCO,
    es.Descripcion AS EstatusDescripcion,
    es.Color AS EstatusColor,
    oc.NumeroOrdenCompra,
    oc.Descripcion,
    oc.FechaOrdenCompra,
    oc.FechaRequerida,
    oc.FechaEntrega,
    oc.FechaVigencia,
    oc.FechaCancelacion,
    oc.MotivoCancelacion,
    oc.Subtotal,
    oc.Iva,
    oc.Total,
    oc.MonedaId,
    m.Nombre AS MonedaNombre,
    m.Simbolo AS MonedaSimbolo,
    oc.TipoCambio,
    oc.Observaciones,
    oc.CompraDirecta,
    oc.FL_Documento,
    oc.Activo,
    oc.FechaCreacion,
    oc.UsuarioCreacion,
    oc.FechaModificacion,
    oc.UsuarioModificacion,
    CONCAT(oc.NumeroOrdenCompra, ' - ', ISNULL(p.Nombre, '')) AS ClaveNombre
FROM ORCO.OrdenCompra oc
LEFT JOIN SIS.Empresa e
    ON oc.FKIdEmpresa_SIS = e.PKIdEmpresa AND e.Activo = 1
LEFT JOIN ORCO.Requisicion r
    ON oc.FKIdRequisicion_ORCO = r.PKIdRequisicion AND r.Activo = 1
LEFT JOIN ORCO.Cotizacion c
    ON oc.FKIdCotizacion_ORCO = c.PKIdCotizacion AND c.Activo = 1
LEFT JOIN SIS.Proveedor p
    ON oc.FKIdProveedor_SIS = p.PKIdProveedor AND p.Activo = 1
LEFT JOIN CONTA.Poliza po
    ON oc.FKIdPoliza_CONTA = po.PKIdPoliza AND po.Activo = 1
LEFT JOIN ORCO.EstatusOrdenCompra es
    ON oc.FKIdEstatusOrdenCompra_ORCO = es.PK_IdEstatusOrdenCompra AND es.CT_LIVE = 1
LEFT JOIN SIS.Moneda m
    ON oc.MonedaId = m.PKIdMoneda AND m.Activo = 1
WHERE oc.Activo = 1;
GO

CREATE OR ALTER PROCEDURE ORCO.SP_MantenimientoOrdenCompra
    @Action int,
    @PKIdOrdenCompra int = NULL,
    @FKIdEmpresa_SIS int = NULL,
    @FKIdRequisicion_ORCO int = NULL,
    @FKIdCotizacion_ORCO int = NULL,
    @FKIdProveedor_SIS int = NULL,
    @FKIdPoliza_CONTA int = NULL,
    @FKIdEstatusOrdenCompra_ORCO int = NULL,
    @NumeroOrdenCompra nvarchar(50) = NULL,
    @Descripcion nvarchar(500) = NULL,
    @FechaOrdenCompra date = NULL,
    @FechaRequerida date = NULL,
    @FechaEntrega date = NULL,
    @FechaVigencia date = NULL,
    @FechaCancelacion date = NULL,
    @MotivoCancelacion nvarchar(max) = NULL,
    @Subtotal decimal(20,4) = NULL,
    @Iva decimal(20,4) = NULL,
    @Total decimal(20,4) = NULL,
    @MonedaId int = NULL,
    @TipoCambio decimal(20,6) = NULL,
    @Observaciones nvarchar(max) = NULL,
    @CompraDirecta bit = NULL,
    @FL_Documento nvarchar(1000) = NULL,
    @IdUser int = NULL,
    @IdAnio int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Tipo nvarchar(20) = N'OK';
    DECLARE @Mensaje nvarchar(1000);
    DECLARE @Liga nvarchar(100);

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action IN (1,2)
        BEGIN
            IF @FechaOrdenCompra IS NULL
                THROW 51000, N'La fecha de la orden de compra es obligatoria.', 1;

            DECLARE @FechaRequisicion date;
            SELECT @FechaRequisicion = FechaRequisicion
            FROM ORCO.Requisicion
            WHERE PKIdRequisicion = @FKIdRequisicion_ORCO AND Activo = 1;

            IF @FechaRequisicion IS NULL
                THROW 51000, N'La requisicion no existe o esta inactiva.', 1;
            IF @FechaOrdenCompra < @FechaRequisicion
                THROW 51000, N'La fecha de la orden debe ser igual o mayor a la requisicion.', 1;
        END;

        IF @Action = 1
        BEGIN
            IF NULLIF(LTRIM(RTRIM(@NumeroOrdenCompra)), N'') IS NULL
            BEGIN
                DECLARE @Anio int = ISNULL(@IdAnio, YEAR(@FechaOrdenCompra));
                DECLARE @Consecutivo int;
                SELECT @Consecutivo = ISNULL(MAX(TRY_CONVERT(int, RIGHT(NumeroOrdenCompra,4))),0) + 1
                FROM ORCO.OrdenCompra WITH (UPDLOCK, HOLDLOCK)
                WHERE NumeroOrdenCompra LIKE CONCAT(N'OC-', @Anio, N'-%');
                SET @NumeroOrdenCompra = CONCAT(N'OC-', @Anio, N'-', RIGHT(CONCAT(N'0000', @Consecutivo),4));
            END;

            INSERT ORCO.OrdenCompra (
                FKIdEmpresa_SIS, FKIdRequisicion_ORCO, FKIdCotizacion_ORCO,
                FKIdProveedor_SIS, FKIdPoliza_CONTA, FKIdEstatusOrdenCompra_ORCO,
                NumeroOrdenCompra, Descripcion, FechaOrdenCompra, FechaRequerida,
                FechaEntrega, FechaVigencia, FechaCancelacion, MotivoCancelacion,
                Subtotal, Iva, Total, MonedaId, TipoCambio, Observaciones,
                CompraDirecta, FL_Documento, Activo, FechaCreacion, UsuarioCreacion
            )
            VALUES (
                @FKIdEmpresa_SIS, @FKIdRequisicion_ORCO, @FKIdCotizacion_ORCO,
                @FKIdProveedor_SIS, @FKIdPoliza_CONTA, @FKIdEstatusOrdenCompra_ORCO,
                @NumeroOrdenCompra, @Descripcion, @FechaOrdenCompra, @FechaRequerida,
                @FechaEntrega, @FechaVigencia, @FechaCancelacion, @MotivoCancelacion,
                ISNULL(@Subtotal,0), ISNULL(@Iva,0), ISNULL(@Total,0), @MonedaId,
                ISNULL(@TipoCambio,1), @Observaciones, ISNULL(@CompraDirecta,0),
                @FL_Documento, 1, SYSDATETIME(), @IdUser
            );
            SET @PKIdOrdenCompra = SCOPE_IDENTITY();
            SET @Mensaje = N'Orden de compra registrada correctamente.';
        END
        ELSE IF @Action = 2
        BEGIN
            UPDATE ORCO.OrdenCompra
            SET FKIdEmpresa_SIS = @FKIdEmpresa_SIS,
                FKIdRequisicion_ORCO = @FKIdRequisicion_ORCO,
                FKIdCotizacion_ORCO = @FKIdCotizacion_ORCO,
                FKIdProveedor_SIS = @FKIdProveedor_SIS,
                FKIdPoliza_CONTA = @FKIdPoliza_CONTA,
                FKIdEstatusOrdenCompra_ORCO = @FKIdEstatusOrdenCompra_ORCO,
                NumeroOrdenCompra = COALESCE(NULLIF(LTRIM(RTRIM(@NumeroOrdenCompra)),''),NumeroOrdenCompra),
                Descripcion = @Descripcion,
                FechaOrdenCompra = @FechaOrdenCompra,
                FechaRequerida = @FechaRequerida,
                FechaEntrega = @FechaEntrega,
                FechaVigencia = @FechaVigencia,
                FechaCancelacion = @FechaCancelacion,
                MotivoCancelacion = @MotivoCancelacion,
                Subtotal = ISNULL(@Subtotal,Subtotal),
                Iva = ISNULL(@Iva,Iva),
                Total = ISNULL(@Total,Total),
                MonedaId = @MonedaId,
                TipoCambio = ISNULL(@TipoCambio,TipoCambio),
                Observaciones = @Observaciones,
                CompraDirecta = ISNULL(@CompraDirecta,CompraDirecta),
                FL_Documento = @FL_Documento,
                FechaModificacion = SYSDATETIME(),
                UsuarioModificacion = @IdUser
            WHERE PKIdOrdenCompra = @PKIdOrdenCompra AND Activo = 1;
            IF @@ROWCOUNT = 0 THROW 51000, N'La orden no existe o esta inactiva.', 1;
            SET @Mensaje = N'Orden de compra actualizada correctamente.';
        END
        ELSE IF @Action = 3
        BEGIN
            UPDATE ORCO.OrdenCompraDetalle
            SET Activo = 0, FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
            WHERE FKIdOrdenCompra_ORCO = @PKIdOrdenCompra AND Activo = 1;
            UPDATE ORCO.OrdenCompraPartida
            SET Activo = 0, FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
            WHERE FKIdOrdenCompra_ORCO = @PKIdOrdenCompra AND Activo = 1;
            UPDATE ORCO.OrdenCompra
            SET Activo = 0, FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
            WHERE PKIdOrdenCompra = @PKIdOrdenCompra AND Activo = 1;
            SET @Mensaje = N'Orden de compra eliminada correctamente.';
        END
        ELSE
            THROW 51000, N'Accion no valida.', 1;

        COMMIT TRANSACTION;
        SET @Liga = CONCAT(N'idOrdenCompra:', ISNULL(@PKIdOrdenCompra,0));
        SELECT ResultJson = (
            SELECT @Tipo Tipo, @Mensaje Mensaje, @Liga Liga
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        IF ERROR_NUMBER() <> 51000 THROW;
        SELECT ResultJson = (
            SELECT N'ERROR' Tipo, ERROR_MESSAGE() Mensaje,
                   CONCAT(N'idOrdenCompra:',ISNULL(@PKIdOrdenCompra,0)) Liga
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
    END CATCH
END;
GO

CREATE OR ALTER TRIGGER ORCO.TR_OrdenCompra_ValidarAdjudicacion
ON ORCO.OrdenCompra
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN deleted d ON d.PKIdOrdenCompra = i.PKIdOrdenCompra
        WHERE COALESCE(TRY_CONVERT(int, SESSION_CONTEXT(N'EG_ALLOW_ORDER_REVERSAL')), 0) <> 1
          AND d.FKIdEstatusOrdenCompra_ORCO > 1
          AND (
              i.Activo <> d.Activo OR
              i.FKIdEstatusOrdenCompra_ORCO < d.FKIdEstatusOrdenCompra_ORCO OR
              i.FKIdEmpresa_SIS <> d.FKIdEmpresa_SIS OR
              i.FKIdRequisicion_ORCO <> d.FKIdRequisicion_ORCO OR
              i.FKIdProveedor_SIS <> d.FKIdProveedor_SIS OR
              ISNULL(i.FKIdCotizacion_ORCO,0) <> ISNULL(d.FKIdCotizacion_ORCO,0) OR
              i.NumeroOrdenCompra <> d.NumeroOrdenCompra OR
              ISNULL(i.Descripcion,'') <> ISNULL(d.Descripcion,'') OR
              i.FechaOrdenCompra <> d.FechaOrdenCompra OR
              i.CompraDirecta <> d.CompraDirecta
          )
    )
        THROW 51041, 'La orden autorizada no admite cambios ni regresion de estatus.', 1;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        LEFT JOIN ORCO.Requisicion r
            ON r.PKIdRequisicion = i.FKIdRequisicion_ORCO AND r.Activo = 1
        LEFT JOIN ORCO.Cotizacion c
            ON c.PKIdCotizacion = i.FKIdCotizacion_ORCO AND c.Activo = 1
        WHERE i.Activo = 1
          AND (
              r.PKIdRequisicion IS NULL OR
              i.FKIdEmpresa_SIS <> r.FKIdEmpresa_SIS OR
              i.CompraDirecta <> r.CompraDirecta OR
              (r.CompraDirecta = 0 AND c.PKIdCotizacion IS NULL) OR
              (c.PKIdCotizacion IS NOT NULL AND (
                  c.FKIdRequisicion_ORCO <> i.FKIdRequisicion_ORCO OR
                  c.FKIdProveedor_SIS <> i.FKIdProveedor_SIS
              ))
          )
    )
        THROW 51042, 'Orden, requisicion, compra directa, cotizacion y proveedor no corresponden.', 1;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN ORCO.Requisicion r
            ON r.PKIdRequisicion = i.FKIdRequisicion_ORCO AND r.Activo = 1
        WHERE i.Activo = 1
          AND r.CompraDirecta = 0
          AND (
              SELECT COUNT(DISTINCT q.FKIdProveedor_SIS)
              FROM ORCO.Cotizacion q
              WHERE q.FKIdRequisicion_ORCO = r.PKIdRequisicion
                AND q.Activo = 1
                AND NOT EXISTS (
                    SELECT 1
                    FROM ORCO.RequisicionDetalle rd
                    WHERE rd.FKIdRequisicion_ORCO = r.PKIdRequisicion
                      AND rd.Activo = 1
                      AND NOT EXISTS (
                          SELECT 1
                          FROM ORCO.CotizacionDetalle qd
                          WHERE qd.FKIdCotizacion_ORCO = q.PKIdCotizacion
                            AND qd.FKIdRequisicionDetalle_ORCO = rd.PKIdRequisicionDetalle
                            AND qd.Activo = 1
                            AND qd.PrecioUnitario > 0
                      )
                )
          ) < 3
    )
        THROW 51043, 'La compra ordinaria requiere tres cotizaciones completas de proveedores distintos.', 1;
END;
GO

CREATE OR ALTER TRIGGER ORCO.TR_OrdenCompraDetalle_ValidarAdjudicacion
ON ORCO.OrdenCompraDetalle
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        LEFT JOIN ORCO.OrdenCompra oc
            ON oc.PKIdOrdenCompra = i.FKIdOrdenCompra_ORCO AND oc.Activo = 1
        LEFT JOIN ORCO.RequisicionDetalle rd
            ON rd.PKIdRequisicionDetalle = i.FKIdRequisicionDetalle_ORCO AND rd.Activo = 1
        LEFT JOIN ORCO.CotizacionDetalle cd
            ON cd.PKIdCotizacionDetalle = i.FKIdCotizacionDetalle_ORCO AND cd.Activo = 1
        LEFT JOIN ORCO.Cotizacion c
            ON c.PKIdCotizacion = cd.FKIdCotizacion_ORCO AND c.Activo = 1
        WHERE i.Activo = 1
          AND (
              oc.PKIdOrdenCompra IS NULL OR
              rd.PKIdRequisicionDetalle IS NULL OR
              rd.FKIdRequisicion_ORCO <> oc.FKIdRequisicion_ORCO OR
              rd.FKIdEmpresa_SIS <> oc.FKIdEmpresa_SIS OR
              (oc.CompraDirecta = 0 AND (
                  cd.PKIdCotizacionDetalle IS NULL OR
                  cd.FKIdCotizacion_ORCO <> oc.FKIdCotizacion_ORCO
              )) OR
              (cd.PKIdCotizacionDetalle IS NOT NULL AND (
                  cd.FKIdRequisicionDetalle_ORCO <> rd.PKIdRequisicionDetalle OR
                  c.FKIdRequisicion_ORCO <> oc.FKIdRequisicion_ORCO OR
                  c.FKIdProveedor_SIS <> oc.FKIdProveedor_SIS OR
                  i.PrecioUnitario > cd.PrecioUnitario
              ))
          )
    )
        THROW 51044, 'El detalle no corresponde a la requisicion, proveedor o cotizacion adjudicada.', 1;
END;
GO

CREATE OR ALTER TRIGGER ORCO.TR_Contratos_ValidarOrden
ON ORCO.Contratos
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN deleted d ON d.PKIdContrato = i.PKIdContrato
        WHERE d.FKIdEstatusContrato_ORCO > 1
          AND (
              i.Activo <> d.Activo OR
              i.FKIdEstatusContrato_ORCO < d.FKIdEstatusContrato_ORCO OR
              ISNULL(i.FKIdOrdenCompra_ORCO,0) <> ISNULL(d.FKIdOrdenCompra_ORCO,0) OR
              i.FKIdEmpresa_SIS <> d.FKIdEmpresa_SIS OR
              i.Numero <> d.Numero OR
              i.Descripcion <> d.Descripcion OR
              i.FechaContrato <> d.FechaContrato OR
              i.MontoMaximo <> d.MontoMaximo OR
              ISNULL(i.MontoMinimo,0) <> ISNULL(d.MontoMinimo,0) OR
              ISNULL(i.Penalizacion,'') <> ISNULL(d.Penalizacion,'')
          )
    )
        THROW 51043, 'El compromiso autorizado no admite cambios ni regresion de estatus.', 1;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        LEFT JOIN ORCO.OrdenCompra oc
            ON oc.PKIdOrdenCompra = i.FKIdOrdenCompra_ORCO AND oc.Activo = 1
        LEFT JOIN ORCO.Fraccion f
            ON f.PKIdFraccion = i.FKIdFraccion_ORCO AND f.Activo = 1
        WHERE i.Activo = 1
          AND (
              oc.PKIdOrdenCompra IS NULL OR
              oc.FKIdEmpresa_SIS <> i.FKIdEmpresa_SIS OR
              oc.FKIdEstatusOrdenCompra_ORCO <= 1 OR
              i.MontoMaximo <= 0 OR
              i.MontoMaximo > oc.Total OR
              ISNULL(i.MontoMinimo,i.MontoMaximo) > i.MontoMaximo OR
              (i.FKIdFraccion_ORCO IS NOT NULL AND (
                  f.PKIdFraccion IS NULL OR f.FKIdArticulo_ORCO <> i.FKIdArticulo_ORCO
              ))
          )
    )
        THROW 51045, 'El contrato juridico no corresponde a la orden, empresa, monto o fundamento legal.', 1;
END;
GO

CREATE OR ALTER TRIGGER PRES.TR_Contrato_ValidarFlujo
ON PRES.Contrato
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN deleted d ON d.PKIdContrato = i.PKIdContrato
        WHERE d.Estatus > 1
          AND COALESCE(TRY_CONVERT(int, SESSION_CONTEXT(N'EG_ALLOW_CONTRACT_REVERSAL')), 0) <> 1
          AND (
              i.Activo <> d.Activo OR
              i.Estatus < d.Estatus OR
              i.FKIdEmpresa_SIS <> d.FKIdEmpresa_SIS OR
              i.FKIdAutorizacionSuficiencia_PRES <> d.FKIdAutorizacionSuficiencia_PRES OR
              i.FKIdProveedor_SIS <> d.FKIdProveedor_SIS OR
              i.NumeroContrato <> d.NumeroContrato OR
              i.Descripcion <> d.Descripcion OR
              i.FechaContrato <> d.FechaContrato OR
              ISNULL(i.FechaInicioVigencia,'19000101') <> ISNULL(d.FechaInicioVigencia,'19000101') OR
              ISNULL(i.FechaFinVigencia,'19000101') <> ISNULL(d.FechaFinVigencia,'19000101') OR
              i.MontoTotal <> d.MontoTotal OR
              ISNULL(i.PlazoEjecucion,'') <> ISNULL(d.PlazoEjecucion,'')
          )
    )
        THROW 51046, 'El contrato autorizado no admite cambios ni eliminacion.', 1;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        LEFT JOIN PRES.AutorizacionSuficiencia a
            ON a.PKIdAutorizacionSuficiencia = i.FKIdAutorizacionSuficiencia_PRES
           AND a.Activo = 1 AND a.Estatus >= 2
        LEFT JOIN PRES.SolicitudSuficiencia s
            ON s.PKIdSolicitudSuficiencia = a.FKIdSolicitudSuficiencia_PRES
           AND s.Activo = 1
        LEFT JOIN ORCO.Requisicion r
            ON r.PKIdRequisicion = s.FKIdRequisicion_ORCO AND r.Activo = 1
        WHERE i.Activo = 1
          AND (
              a.PKIdAutorizacionSuficiencia IS NULL OR
              s.PKIdSolicitudSuficiencia IS NULL OR
              r.PKIdRequisicion IS NULL OR
              i.FKIdEmpresa_SIS <> a.FKIdEmpresa_SIS OR
              i.FechaContrato < a.FechaAutorizacion OR
              ABS(i.MontoTotal - ISNULL((
                  SELECT SUM(ISNULL(ad.Total,
                      ISNULL(ad.Enero,0)+ISNULL(ad.Febrero,0)+ISNULL(ad.Marzo,0)+
                      ISNULL(ad.Abril,0)+ISNULL(ad.Mayo,0)+ISNULL(ad.Junio,0)+
                      ISNULL(ad.Julio,0)+ISNULL(ad.Agosto,0)+ISNULL(ad.Septiembre,0)+
                      ISNULL(ad.Octubre,0)+ISNULL(ad.Noviembre,0)+ISNULL(ad.Diciembre,0)))
                  FROM PRES.AutorizacionSuficienciaDetalle ad
                  WHERE ad.FKIdAutorizacionSuficiencia_PRES = a.PKIdAutorizacionSuficiencia
                    AND ad.Activo = 1
              ),0)) > 0.01 OR
              (r.CompraDirecta = 0 AND NOT EXISTS (
                  SELECT 1
                  FROM ORCO.Cotizacion c
                  WHERE c.FKIdRequisicion_ORCO = r.PKIdRequisicion
                    AND c.FKIdProveedor_SIS = i.FKIdProveedor_SIS
                    AND c.Activo = 1
                    AND NOT EXISTS (
                        SELECT 1
                        FROM ORCO.RequisicionDetalle rd
                        WHERE rd.FKIdRequisicion_ORCO = r.PKIdRequisicion
                          AND rd.Activo = 1
                          AND NOT EXISTS (
                              SELECT 1
                              FROM ORCO.CotizacionDetalle cd
                              WHERE cd.FKIdCotizacion_ORCO = c.PKIdCotizacion
                                AND cd.FKIdRequisicionDetalle_ORCO = rd.PKIdRequisicionDetalle
                                AND cd.Activo = 1
                                AND cd.PrecioUnitario > 0
                          )
                    )
              ))
          )
    )
        THROW 51047, 'Contrato, autorizacion, proveedor cotizante, fecha o importe no corresponden.', 1;
END;
GO

CREATE OR ALTER TRIGGER PRES.TR_ContratoDetalle_HeredarPartida
ON PRES.ContratoDetalle
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        LEFT JOIN PRES.Contrato c
            ON c.PKIdContrato = i.FKIdContrato_PRES AND c.Activo = 1
        LEFT JOIN PRES.AutorizacionSuficienciaDetalle ad
            ON ad.PKIdAutorizacionSuficienciaDetalle = i.FKIdAutorizacionSuficienciaDetalle_PRES
           AND ad.Activo = 1
        WHERE c.PKIdContrato IS NULL
           OR ad.PKIdAutorizacionSuficienciaDetalle IS NULL
           OR ad.FKIdAutorizacionSuficiencia_PRES <> c.FKIdAutorizacionSuficiencia_PRES
           OR i.FKIdEmpresa_SIS <> c.FKIdEmpresa_SIS
           OR (
               ISNULL(i.Total,
                   ISNULL(i.Enero,0)+ISNULL(i.Febrero,0)+ISNULL(i.Marzo,0)+
                   ISNULL(i.Abril,0)+ISNULL(i.Mayo,0)+ISNULL(i.Junio,0)+
                   ISNULL(i.Julio,0)+ISNULL(i.Agosto,0)+ISNULL(i.Septiembre,0)+
                   ISNULL(i.Octubre,0)+ISNULL(i.Noviembre,0)+ISNULL(i.Diciembre,0)
               ) > ISNULL(ad.Total,
                   ISNULL(ad.Enero,0)+ISNULL(ad.Febrero,0)+ISNULL(ad.Marzo,0)+
                   ISNULL(ad.Abril,0)+ISNULL(ad.Mayo,0)+ISNULL(ad.Junio,0)+
                   ISNULL(ad.Julio,0)+ISNULL(ad.Agosto,0)+ISNULL(ad.Septiembre,0)+
                   ISNULL(ad.Octubre,0)+ISNULL(ad.Noviembre,0)+ISNULL(ad.Diciembre,0)
               )
           )
    )
        THROW 51011, 'El detalle no pertenece a la autorizacion o excede su importe.', 1;

    UPDATE cd
    SET FKIdPartida_CONTA = ad.FKIdPartida_CONTA
    FROM PRES.ContratoDetalle cd
    INNER JOIN inserted i
        ON i.PKIdContratoDetalle = cd.PKIdContratoDetalle
    INNER JOIN PRES.AutorizacionSuficienciaDetalle ad
        ON ad.PKIdAutorizacionSuficienciaDetalle = i.FKIdAutorizacionSuficienciaDetalle_PRES;
END;
GO

/* Penalizacion es una clausula de texto en el legado, no un porcentaje numerico. */
CREATE OR ALTER PROCEDURE ORCO.SP_MantenimientoContratos
    @Action INT,
    @PKIdContrato INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdOrdenCompra_ORCO INT = NULL,
    @FKIdTipoContrato_ORCO INT = NULL,
    @FKIdTipoDocumento_ORCO INT = NULL,
    @FKIdArea_SIS INT = NULL,
    @FKIdTipoGarantia_ORCO INT = NULL,
    @FKIdProcedimientoContratacion_ORCO INT = NULL,
    @FKIdFundamentoJuridico_ORCO INT = NULL,
    @FundamentoJuridico NVARCHAR(MAX) = NULL,
    @Numero NVARCHAR(50) = NULL,
    @Descripcion NVARCHAR(MAX) = NULL,
    @FechaContrato DATE = NULL,
    @FechaRecepcion DATE = NULL,
    @FechaFirmaContrato DATE = NULL,
    @FechaVigenciaInicio DATE = NULL,
    @FechaVigenciaFin DATE = NULL,
    @FKIdModalidad_ORCO INT = NULL,
    @MontoMaximo DECIMAL(18,4) = NULL,
    @MontoMinimo DECIMAL(18,4) = NULL,
    @Penalizacion NVARCHAR(100) = NULL,
    @PlazoEjecucion NVARCHAR(250) = NULL,
    @FL_Archivo NVARCHAR(250) = NULL,
    @Justificacion NVARCHAR(MAX) = NULL,
    @FKIdArticulo_ORCO INT = NULL,
    @FKIdFraccion_ORCO INT = NULL,
    @SesionSubcomite NVARCHAR(150) = NULL,
    @IsSesionExtraordinaria BIT = NULL,
    @FechaSesionSubcomite DATE = NULL,
    @FKIdEstatusContrato_ORCO INT = NULL,
    @IdUser INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 1
    BEGIN
        INSERT ORCO.Contratos (
            FKIdEmpresa_SIS, FKIdOrdenCompra_ORCO, FKIdTipoContrato_ORCO,
            FKIdTipoDocumento_ORCO, FKIdArea_SIS, FKIdTipoGarantia_ORCO,
            FKIdProcedimientoContratacion_ORCO, FKIdFundamentoJuridico_ORCO,
            FundamentoJuridico, Numero, Descripcion, FechaContrato,
            FechaRecepcion, FechaFirmaContrato, FechaVigenciaInicio,
            FechaVigenciaFin, FKIdModalidad_ORCO, MontoMaximo, MontoMinimo,
            Penalizacion, PlazoEjecucion, FL_Archivo, Justificacion,
            FKIdArticulo_ORCO, FKIdFraccion_ORCO, SesionSubcomite,
            IsSesionExtraordinaria, FechaSesionSubcomite,
            FKIdEstatusContrato_ORCO, UsuarioCreacion
        )
        VALUES (
            @FKIdEmpresa_SIS, @FKIdOrdenCompra_ORCO, @FKIdTipoContrato_ORCO,
            @FKIdTipoDocumento_ORCO, @FKIdArea_SIS, @FKIdTipoGarantia_ORCO,
            @FKIdProcedimientoContratacion_ORCO, @FKIdFundamentoJuridico_ORCO,
            @FundamentoJuridico, ISNULL(@Numero, N''), @Descripcion,
            ISNULL(@FechaContrato, CONVERT(date, GETDATE())), @FechaRecepcion,
            @FechaFirmaContrato, @FechaVigenciaInicio, @FechaVigenciaFin,
            @FKIdModalidad_ORCO, ISNULL(@MontoMaximo, 0),
            ISNULL(@MontoMinimo, 0), @Penalizacion, @PlazoEjecucion,
            @FL_Archivo, @Justificacion, @FKIdArticulo_ORCO,
            @FKIdFraccion_ORCO, @SesionSubcomite,
            ISNULL(@IsSesionExtraordinaria, 0), @FechaSesionSubcomite,
            ISNULL(@FKIdEstatusContrato_ORCO, 1), @IdUser
        );

        SELECT 1 Tipo, N'Registro de compromiso creado correctamente.' Mensaje,
               SCOPE_IDENTITY() Id, NULL Liga;
        RETURN;
    END;

    IF @Action = 2
    BEGIN
        UPDATE ORCO.Contratos
        SET FKIdEmpresa_SIS = ISNULL(@FKIdEmpresa_SIS, FKIdEmpresa_SIS),
            FKIdOrdenCompra_ORCO = @FKIdOrdenCompra_ORCO,
            FKIdTipoContrato_ORCO = @FKIdTipoContrato_ORCO,
            FKIdTipoDocumento_ORCO = @FKIdTipoDocumento_ORCO,
            FKIdArea_SIS = @FKIdArea_SIS,
            FKIdTipoGarantia_ORCO = @FKIdTipoGarantia_ORCO,
            FKIdProcedimientoContratacion_ORCO = @FKIdProcedimientoContratacion_ORCO,
            FKIdFundamentoJuridico_ORCO = @FKIdFundamentoJuridico_ORCO,
            FundamentoJuridico = @FundamentoJuridico,
            Numero = ISNULL(@Numero, N''),
            Descripcion = @Descripcion,
            FechaContrato = ISNULL(@FechaContrato, FechaContrato),
            FechaRecepcion = @FechaRecepcion,
            FechaFirmaContrato = @FechaFirmaContrato,
            FechaVigenciaInicio = @FechaVigenciaInicio,
            FechaVigenciaFin = @FechaVigenciaFin,
            FKIdModalidad_ORCO = @FKIdModalidad_ORCO,
            MontoMaximo = ISNULL(@MontoMaximo, 0),
            MontoMinimo = ISNULL(@MontoMinimo, 0),
            Penalizacion = @Penalizacion,
            PlazoEjecucion = @PlazoEjecucion,
            FL_Archivo = @FL_Archivo,
            Justificacion = @Justificacion,
            FKIdArticulo_ORCO = @FKIdArticulo_ORCO,
            FKIdFraccion_ORCO = @FKIdFraccion_ORCO,
            SesionSubcomite = @SesionSubcomite,
            IsSesionExtraordinaria = ISNULL(@IsSesionExtraordinaria, 0),
            FechaSesionSubcomite = @FechaSesionSubcomite,
            FKIdEstatusContrato_ORCO =
                ISNULL(@FKIdEstatusContrato_ORCO, FKIdEstatusContrato_ORCO),
            FechaModificacion = SYSDATETIME(),
            UsuarioModificacion = @IdUser
        WHERE PKIdContrato = @PKIdContrato;

        SELECT 1 Tipo, N'Registro de compromiso actualizado correctamente.' Mensaje,
               @PKIdContrato Id, NULL Liga;
        RETURN;
    END;

    IF @Action = 3
    BEGIN
        UPDATE ORCO.Contratos
        SET Activo = 0,
            FechaModificacion = SYSDATETIME(),
            UsuarioModificacion = @IdUser
        WHERE PKIdContrato = @PKIdContrato;

        SELECT 1 Tipo, N'Registro de compromiso eliminado correctamente.' Mensaje,
               @PKIdContrato Id, NULL Liga;
    END;
END;
GO

/* Reemplaza la regla previa de una cotizacion por tres, excepto compra directa. */
CREATE OR ALTER TRIGGER PRES.TR_SolicitudSuficiencia_ValidarRequisicion
ON PRES.SolicitudSuficiencia
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        LEFT JOIN ORCO.Requisicion r
            ON r.PKIdRequisicion = i.FKIdRequisicion_ORCO AND r.Activo = 1
        WHERE i.Activo = 1
          AND (
              r.PKIdRequisicion IS NULL OR
              i.FKIdEmpresa_SIS <> r.FKIdEmpresa_SIS OR
              (
                  r.CompraDirecta = 0 AND
                  (
                      SELECT COUNT(DISTINCT c.FKIdProveedor_SIS)
                      FROM ORCO.Cotizacion c
                      WHERE c.FKIdRequisicion_ORCO = r.PKIdRequisicion
                        AND c.Activo = 1
                        AND NOT EXISTS (
                            SELECT 1
                            FROM ORCO.RequisicionDetalle rd
                            WHERE rd.FKIdRequisicion_ORCO = r.PKIdRequisicion
                              AND rd.Activo = 1
                              AND NOT EXISTS (
                                  SELECT 1
                                  FROM ORCO.CotizacionDetalle cd
                                  WHERE cd.FKIdCotizacion_ORCO = c.PKIdCotizacion
                                    AND cd.FKIdRequisicionDetalle_ORCO = rd.PKIdRequisicionDetalle
                                    AND cd.Activo = 1
                                    AND cd.PrecioUnitario > 0
                              )
                        )
                  ) < 3
              )
          )
    )
        THROW 51008, 'La suficiencia requiere tres cotizaciones completas de proveedores distintos o compra directa autorizada.', 1;
END;
GO
