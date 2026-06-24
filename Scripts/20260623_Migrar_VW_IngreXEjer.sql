USE [BD_PRESUPUESTO]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************************
Description : Migracion de PRES.VW_IngreXEjer a estructura nueva de ingresos.
Notas       :
              - PRES.AdecuacionIngresos se reemplaza por PRES.IngreAdecuacion /
                PRES.IngreAdecuacionDetalle.
              - En ingresos, FKIdTipoMovimiento_PRES = 3 aumenta y = 4 reduce.
              - PRES.CLCFactura ya no trae importes por mes; se distribuye MontoAplicado
                al mes de Fecha, usando FechaCreacion como respaldo cuando Fecha sea NULL.
              - La vista conserva el contrato/nombres de columnas de la vista anterior.
******************************************************************************************/
CREATE OR ALTER VIEW [PRES].[VW_IngreXEjer]
AS
WITH AdecuacionesAutorizadas AS
(
    SELECT
        det.FKIdIngresoAutorizado_PRES,
        SUM(CASE det.FKIdTipoMovimiento_PRES WHEN 3 THEN det.Enero      WHEN 4 THEN -det.Enero      ELSE 0 END) AS Ene,
        SUM(CASE det.FKIdTipoMovimiento_PRES WHEN 3 THEN det.Febrero    WHEN 4 THEN -det.Febrero    ELSE 0 END) AS Feb,
        SUM(CASE det.FKIdTipoMovimiento_PRES WHEN 3 THEN det.Marzo      WHEN 4 THEN -det.Marzo      ELSE 0 END) AS Mar,
        SUM(CASE det.FKIdTipoMovimiento_PRES WHEN 3 THEN det.Abril      WHEN 4 THEN -det.Abril      ELSE 0 END) AS Abr,
        SUM(CASE det.FKIdTipoMovimiento_PRES WHEN 3 THEN det.Mayo       WHEN 4 THEN -det.Mayo       ELSE 0 END) AS May,
        SUM(CASE det.FKIdTipoMovimiento_PRES WHEN 3 THEN det.Junio      WHEN 4 THEN -det.Junio      ELSE 0 END) AS Jun,
        SUM(CASE det.FKIdTipoMovimiento_PRES WHEN 3 THEN det.Julio      WHEN 4 THEN -det.Julio      ELSE 0 END) AS Jul,
        SUM(CASE det.FKIdTipoMovimiento_PRES WHEN 3 THEN det.Agosto     WHEN 4 THEN -det.Agosto     ELSE 0 END) AS Ago,
        SUM(CASE det.FKIdTipoMovimiento_PRES WHEN 3 THEN det.Septiembre WHEN 4 THEN -det.Septiembre ELSE 0 END) AS Sep,
        SUM(CASE det.FKIdTipoMovimiento_PRES WHEN 3 THEN det.Octubre    WHEN 4 THEN -det.Octubre    ELSE 0 END) AS Oct,
        SUM(CASE det.FKIdTipoMovimiento_PRES WHEN 3 THEN det.Noviembre  WHEN 4 THEN -det.Noviembre  ELSE 0 END) AS Nov,
        SUM(CASE det.FKIdTipoMovimiento_PRES WHEN 3 THEN det.Diciembre  WHEN 4 THEN -det.Diciembre  ELSE 0 END) AS Dic,
        SUM(CASE det.FKIdTipoMovimiento_PRES WHEN 3 THEN ISNULL(det.Total, 0) WHEN 4 THEN -ISNULL(det.Total, 0) ELSE 0 END) AS Total
    FROM PRES.IngreAdecuacionDetalle det
    INNER JOIN PRES.IngreAdecuacion enc
        ON enc.PKIdIngreAdecuacion = det.FKIdIngreAdecuacion_PRES
       AND enc.Activo = 1
       AND enc.Autorizado = 1
    WHERE det.Activo = 1
      AND det.FKIdTipoMovimiento_PRES IN (3, 4)
    GROUP BY det.FKIdIngresoAutorizado_PRES
),
ClcFacturasAplicadas AS
(
    SELECT
        pc.FKIdIngresoAutorizado_PRES,
        SUM(CASE WHEN MONTH(ISNULL(pc.Fecha, CONVERT(date, pc.FechaCreacion))) = 1  THEN pc.MontoAplicado ELSE 0 END) AS Ene,
        SUM(CASE WHEN MONTH(ISNULL(pc.Fecha, CONVERT(date, pc.FechaCreacion))) = 2  THEN pc.MontoAplicado ELSE 0 END) AS Feb,
        SUM(CASE WHEN MONTH(ISNULL(pc.Fecha, CONVERT(date, pc.FechaCreacion))) = 3  THEN pc.MontoAplicado ELSE 0 END) AS Mar,
        SUM(CASE WHEN MONTH(ISNULL(pc.Fecha, CONVERT(date, pc.FechaCreacion))) = 4  THEN pc.MontoAplicado ELSE 0 END) AS Abr,
        SUM(CASE WHEN MONTH(ISNULL(pc.Fecha, CONVERT(date, pc.FechaCreacion))) = 5  THEN pc.MontoAplicado ELSE 0 END) AS May,
        SUM(CASE WHEN MONTH(ISNULL(pc.Fecha, CONVERT(date, pc.FechaCreacion))) = 6  THEN pc.MontoAplicado ELSE 0 END) AS Jun,
        SUM(CASE WHEN MONTH(ISNULL(pc.Fecha, CONVERT(date, pc.FechaCreacion))) = 7  THEN pc.MontoAplicado ELSE 0 END) AS Jul,
        SUM(CASE WHEN MONTH(ISNULL(pc.Fecha, CONVERT(date, pc.FechaCreacion))) = 8  THEN pc.MontoAplicado ELSE 0 END) AS Ago,
        SUM(CASE WHEN MONTH(ISNULL(pc.Fecha, CONVERT(date, pc.FechaCreacion))) = 9  THEN pc.MontoAplicado ELSE 0 END) AS Sep,
        SUM(CASE WHEN MONTH(ISNULL(pc.Fecha, CONVERT(date, pc.FechaCreacion))) = 10 THEN pc.MontoAplicado ELSE 0 END) AS Oct,
        SUM(CASE WHEN MONTH(ISNULL(pc.Fecha, CONVERT(date, pc.FechaCreacion))) = 11 THEN pc.MontoAplicado ELSE 0 END) AS Nov,
        SUM(CASE WHEN MONTH(ISNULL(pc.Fecha, CONVERT(date, pc.FechaCreacion))) = 12 THEN pc.MontoAplicado ELSE 0 END) AS Dic,
        SUM(pc.MontoAplicado) AS Total
    FROM PRES.CLCFactura pc
    WHERE pc.Activo = 1
      AND pc.FKIdIngresoAutorizado_PRES IS NOT NULL
    GROUP BY pc.FKIdIngresoAutorizado_PRES
)
SELECT
    pia.PKIdIngresoAutorizado AS Pk_IdIngresoAutorizado,
    pia.AreaFuncional AS AreaFuncional,
    pia.Origen AS Origen,
    pia.FKIdAnio_SIS AS Fk_IdAnio__SIS,
    pia.FKIdPrograma_PRES AS Fk_IdPrograma__PRES,
    pia.FKIdOrigen_PRES AS Fk_IdOrigen__PRES,
    pia.Descripcion AS Descripcion,
    ISNULL(pia.Enero, 0)      + ISNULL(aj.Ene, 0) - ISNULL(clc.Ene, 0) AS Ene,
    ISNULL(pia.Febrero, 0)    + ISNULL(aj.Feb, 0) - ISNULL(clc.Feb, 0) AS Feb,
    ISNULL(pia.Marzo, 0)      + ISNULL(aj.Mar, 0) - ISNULL(clc.Mar, 0) AS Mar,
    ISNULL(pia.Abril, 0)      + ISNULL(aj.Abr, 0) - ISNULL(clc.Abr, 0) AS Abr,
    ISNULL(pia.Mayo, 0)       + ISNULL(aj.May, 0) - ISNULL(clc.May, 0) AS May,
    ISNULL(pia.Junio, 0)      + ISNULL(aj.Jun, 0) - ISNULL(clc.Jun, 0) AS Jun,
    ISNULL(pia.Julio, 0)      + ISNULL(aj.Jul, 0) - ISNULL(clc.Jul, 0) AS Jul,
    ISNULL(pia.Agosto, 0)     + ISNULL(aj.Ago, 0) - ISNULL(clc.Ago, 0) AS Ago,
    ISNULL(pia.Septiembre, 0) + ISNULL(aj.Sep, 0) - ISNULL(clc.Sep, 0) AS Sep,
    ISNULL(pia.Octubre, 0)    + ISNULL(aj.Oct, 0) - ISNULL(clc.Oct, 0) AS Oct,
    ISNULL(pia.Noviembre, 0)  + ISNULL(aj.Nov, 0) - ISNULL(clc.Nov, 0) AS Nov,
    ISNULL(pia.Diciembre, 0)  + ISNULL(aj.Dic, 0) - ISNULL(clc.Dic, 0) AS Dic,
    ISNULL(pia.Total, 0)      + ISNULL(aj.Total, 0) - ISNULL(clc.Total, 0) AS Total,
    CAST('' AS varchar(max)) AS [Message]
FROM PRES.Vw_IngresoAutorizado pia
LEFT JOIN AdecuacionesAutorizadas aj
    ON aj.FKIdIngresoAutorizado_PRES = pia.PKIdIngresoAutorizado
LEFT JOIN ClcFacturasAplicadas clc
    ON clc.FKIdIngresoAutorizado_PRES = pia.PKIdIngresoAutorizado
WHERE pia.Activo = 1
  AND pia.FechaAutorizacion IS NOT NULL;
GO
