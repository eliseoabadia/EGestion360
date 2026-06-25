USE [BD_PRESUPUESTO]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************************
Description : PRES.VW_CLCFactura_Importe sobre la estructura nueva.
Notas       :
              - PRES.CLCFactura ya no contiene los datos fiscales de la factura.
              - Los datos de factura se toman desde PRES.Factura.
              - Los importes aplicados se toman desde PRES.CLCFactura.MontoAplicado.
              - Los meses se calculan con PRES.CLCFactura.Fecha y, si viene NULL,
                se usa FechaCreacion como respaldo.
******************************************************************************************/
CREATE OR ALTER VIEW [PRES].[VW_CLCFactura_Importe]
AS
WITH CLCFacturaAplicada AS
(
    SELECT
        cf.FKIdFactura_PRES,
        SUM(CASE WHEN MONTH(ISNULL(cf.Fecha, CONVERT(date, cf.FechaCreacion))) = 1  THEN cf.MontoAplicado ELSE 0 END) AS Ene,
        SUM(CASE WHEN MONTH(ISNULL(cf.Fecha, CONVERT(date, cf.FechaCreacion))) = 2  THEN cf.MontoAplicado ELSE 0 END) AS Feb,
        SUM(CASE WHEN MONTH(ISNULL(cf.Fecha, CONVERT(date, cf.FechaCreacion))) = 3  THEN cf.MontoAplicado ELSE 0 END) AS Mar,
        SUM(CASE WHEN MONTH(ISNULL(cf.Fecha, CONVERT(date, cf.FechaCreacion))) = 4  THEN cf.MontoAplicado ELSE 0 END) AS Abr,
        SUM(CASE WHEN MONTH(ISNULL(cf.Fecha, CONVERT(date, cf.FechaCreacion))) = 5  THEN cf.MontoAplicado ELSE 0 END) AS May,
        SUM(CASE WHEN MONTH(ISNULL(cf.Fecha, CONVERT(date, cf.FechaCreacion))) = 6  THEN cf.MontoAplicado ELSE 0 END) AS Jun,
        SUM(CASE WHEN MONTH(ISNULL(cf.Fecha, CONVERT(date, cf.FechaCreacion))) = 7  THEN cf.MontoAplicado ELSE 0 END) AS Jul,
        SUM(CASE WHEN MONTH(ISNULL(cf.Fecha, CONVERT(date, cf.FechaCreacion))) = 8  THEN cf.MontoAplicado ELSE 0 END) AS Ago,
        SUM(CASE WHEN MONTH(ISNULL(cf.Fecha, CONVERT(date, cf.FechaCreacion))) = 9  THEN cf.MontoAplicado ELSE 0 END) AS Sep,
        SUM(CASE WHEN MONTH(ISNULL(cf.Fecha, CONVERT(date, cf.FechaCreacion))) = 10 THEN cf.MontoAplicado ELSE 0 END) AS Oct,
        SUM(CASE WHEN MONTH(ISNULL(cf.Fecha, CONVERT(date, cf.FechaCreacion))) = 11 THEN cf.MontoAplicado ELSE 0 END) AS Nov,
        SUM(CASE WHEN MONTH(ISNULL(cf.Fecha, CONVERT(date, cf.FechaCreacion))) = 12 THEN cf.MontoAplicado ELSE 0 END) AS Dic,
        SUM(cf.MontoAplicado) AS DevengadoEgresos
    FROM PRES.CLCFactura cf
    INNER JOIN PRES.CLC clc
        ON clc.PKIdCLC = cf.FKIdCLC_PRES
       AND clc.Activo = 1
    WHERE cf.Activo = 1
    GROUP BY cf.FKIdFactura_PRES
)
SELECT
    f.PKIdFactura,
    f.FKIdEmpresa_SIS,
    emp.Nombre AS EmpresaNombre,
    f.FKIdContrato_PRES,
    c.NumeroContrato,
    c.FKIdProveedor_SIS,
    prov.RFC,
    prov.Nombre AS Nombre,
    f.FKIdPoliza_CONTA,
    pol.ClavePoliza,
    f.NumFactura,
    f.SerieFactura,
    f.FechaEmision AS Fecha,
    f.FechaRecepcion,
    f.Subtotal,
    f.IVA,
    f.Retencion,
    f.Total AS Importe,
    f.UUID,
    f.FL_Docto AS FLDocto,
    f.Observaciones AS Concepto,
    f.Estatus,
    CASE f.Estatus
        WHEN 1 THEN 'Registrada'
        WHEN 2 THEN 'Validada'
        WHEN 3 THEN 'Devengada'
        WHEN 4 THEN 'Rechazada'
        ELSE 'Sin definir'
    END AS EstatusDescripcion,
    ISNULL(ap.Ene, 0) AS Ene,
    ISNULL(ap.Feb, 0) AS Feb,
    ISNULL(ap.Mar, 0) AS Mar,
    ISNULL(ap.Abr, 0) AS Abr,
    ISNULL(ap.May, 0) AS May,
    ISNULL(ap.Jun, 0) AS Jun,
    ISNULL(ap.Jul, 0) AS Jul,
    ISNULL(ap.Ago, 0) AS Ago,
    ISNULL(ap.Sep, 0) AS Sep,
    ISNULL(ap.Oct, 0) AS Oct,
    ISNULL(ap.Nov, 0) AS Nov,
    ISNULL(ap.Dic, 0) AS Dic,
    f.Total AS DevengadoIngresos,
    ISNULL(ap.DevengadoEgresos, 0) AS DevengadoEgresos,
    f.Total - ISNULL(ap.DevengadoEgresos, 0) AS SaldoCLC,
    f.Activo,
    f.FechaCreacion,
    f.UsuarioCreacion,
    f.FechaModificacion,
    f.UsuarioModificacion
FROM PRES.Factura f
INNER JOIN PRES.Contrato c
    ON c.PKIdContrato = f.FKIdContrato_PRES
   AND c.Activo = 1
LEFT JOIN CLCFacturaAplicada ap
    ON ap.FKIdFactura_PRES = f.PKIdFactura
LEFT JOIN SIS.Empresa emp
    ON emp.PKIdEmpresa = f.FKIdEmpresa_SIS
   AND emp.Activo = 1
LEFT JOIN SIS.Proveedor prov
    ON prov.PKIdProveedor = c.FKIdProveedor_SIS
   AND prov.Activo = 1
LEFT JOIN CONTA.Poliza pol
    ON pol.PKIdPoliza = f.FKIdPoliza_CONTA
   AND pol.Activo = 1
WHERE f.Activo = 1;
GO
