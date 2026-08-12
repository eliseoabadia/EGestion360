/* Permite que el regreso íntegro desde cheque cierre un contrato vigente de forma controlada. */
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;
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

DECLARE @Definicion nvarchar(max) = OBJECT_DEFINITION(OBJECT_ID(N'PRES.SP_RegresarChequeASolicitudSuficiencia'));

IF @Definicion IS NULL
    THROW 51048, N'No existe PRES.SP_RegresarChequeASolicitudSuficiencia.', 1;

IF CHARINDEX(N'EG_ALLOW_CONTRACT_REVERSAL', @Definicion) = 0
BEGIN
    SET @Definicion = REPLACE(
        @Definicion,
        N'        UPDATE PRES.ContratoDetalle',
        N'        EXEC sys.sp_set_session_context @key = N''EG_ALLOW_CONTRACT_REVERSAL'', @value = 1;' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
        N'        UPDATE PRES.ContratoDetalle'
    );
    SET @Definicion = REPLACE(
        @Definicion,
        N'        UPDATE PRES.AutorizacionSuficienciaDetalle',
        N'        EXEC sys.sp_set_session_context @key = N''EG_ALLOW_CONTRACT_REVERSAL'', @value = NULL;' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
        N'        UPDATE PRES.AutorizacionSuficienciaDetalle'
    );
    SET @Definicion = REPLACE(
        @Definicion,
        N'        EXEC sys.sp_set_session_context @key = N''EG_ALLOW_ORDER_REVERSAL'', @value = NULL;' + CHAR(13) + CHAR(10) +
        N'        IF CURSOR_STATUS',
        N'        EXEC sys.sp_set_session_context @key = N''EG_ALLOW_ORDER_REVERSAL'', @value = NULL;' + CHAR(13) + CHAR(10) +
        N'        EXEC sys.sp_set_session_context @key = N''EG_ALLOW_CONTRACT_REVERSAL'', @value = NULL;' + CHAR(13) + CHAR(10) +
        N'        IF CURSOR_STATUS'
    );
    SET @Definicion = REPLACE(@Definicion, N'CREATE   PROCEDURE', N'ALTER PROCEDURE');
    SET @Definicion = REPLACE(@Definicion, N'CREATE PROCEDURE', N'ALTER PROCEDURE');
    SET @Definicion = REPLACE(@Definicion, N'CREATE OR ALTER PROCEDURE', N'ALTER PROCEDURE');
    EXEC sys.sp_executesql @Definicion;
END;
GO

IF CHARINDEX(N'EG_ALLOW_CONTRACT_REVERSAL', OBJECT_DEFINITION(OBJECT_ID(N'PRES.SP_RegresarChequeASolicitudSuficiencia'))) = 0
    THROW 51049, N'No fue posible actualizar el procedimiento de reversa de cheque.', 1;
GO

/* Conserva las opciones SET correctas al recompilar una definición dinámica. */
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
DECLARE @Procedimiento nvarchar(max) = OBJECT_DEFINITION(OBJECT_ID(N'PRES.SP_RegresarChequeASolicitudSuficiencia'));

IF @Procedimiento IS NULL
    THROW 51050, N'No existe PRES.SP_RegresarChequeASolicitudSuficiencia para recompilar.', 1;

SET @Procedimiento = REPLACE(@Procedimiento, N'CREATE   PROCEDURE', N'ALTER PROCEDURE');
SET @Procedimiento = REPLACE(@Procedimiento, N'CREATE PROCEDURE', N'ALTER PROCEDURE');
SET @Procedimiento = REPLACE(@Procedimiento, N'CREATE OR ALTER PROCEDURE', N'ALTER PROCEDURE');
EXEC sys.sp_executesql @Procedimiento;
GO
