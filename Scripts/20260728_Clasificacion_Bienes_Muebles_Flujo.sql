SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

CREATE OR ALTER VIEW [ORCO].[Vw_OrdenCompraFromClasificacionBien]
AS
WITH Detalle AS
(
    SELECT
        D.FKIdOrdenCompra_ORCO,
        SUM(D.CantidadSolicitada) AS Solicitado,
        SUM(D.CantidadRecibida) AS Recibido,
        SUM(D.CantidadSolicitada - D.CantidadRecibida) AS Faltante,
        SUM(D.PrecioUnitario) AS PrecioUnitario,
        SUM(ISNULL(D.TotalDetalle, ISNULL(D.Importe, 0))) AS Total
    FROM ORCO.OrdenCompraDetalle D
    WHERE D.Activo = 1
    GROUP BY D.FKIdOrdenCompra_ORCO
)
SELECT
    OC.PKIdOrdenCompra,
    OC.FKIdEmpresa_SIS,
    R.FKIdAnio_SIS,
    R.Descripcion AS Requisicion,
    P.Nombre AS Proveedor,
    OC.Descripcion AS Justificacion,
    OC.FechaOrdenCompra,
    OC.FechaVigencia,
    D.Solicitado,
    D.Recibido,
    D.Faltante,
    CASE
        WHEN ISNULL(D.Recibido, 0) = 0 THEN 'POR SURTIR'
        WHEN D.Solicitado = D.Recibido THEN 'SURTIDO TOTAL'
        WHEN D.Solicitado > D.Recibido THEN 'SURTIDO PARCIAL'
        ELSE 'CERRADO'
    END AS Estado,
    OC.NumeroOrdenCompra AS Numero,
    OC.FKIdCotizacion_ORCO,
    OC.FKIdEstatusOrdenCompra_ORCO,
    CONVERT(int, CASE WHEN EXISTS
    (
        SELECT 1
        FROM ORCO.OrdenCompraDetalle OD
        INNER JOIN ALMA.Bien B ON B.FKIdDetalleOrdenCompra_ORCO = OD.PKIdOrdenCompraDetalle
        WHERE OD.FKIdOrdenCompra_ORCO = OC.PKIdOrdenCompra
          AND OD.Activo = 1 AND B.Activo = 1
    ) THEN 1 ELSE 0 END) AS Color,
    D.PrecioUnitario,
    D.Total
FROM ORCO.OrdenCompra OC
INNER JOIN ORCO.Requisicion R ON R.PKIdRequisicion = OC.FKIdRequisicion_ORCO AND R.Activo = 1
INNER JOIN SIS.Proveedor P ON P.PKIdProveedor = OC.FKIdProveedor_SIS AND P.Activo = 1
INNER JOIN Detalle D ON D.FKIdOrdenCompra_ORCO = OC.PKIdOrdenCompra
INNER JOIN PRES.EgresoAutorizado EA ON EA.PKIdEgresoAutorizado = R.FKIdEgresoAutorizado_PRES AND EA.Activo = 1
INNER JOIN CONTA.Partida PA ON PA.PKIdPartida = EA.FKIdPartida_CONTA AND PA.Activo = 1
WHERE OC.Activo = 1
  AND PA.Clave LIKE '5%';
GO

CREATE OR ALTER PROCEDURE [ALMA].[SPR_Entrada]
    @PKIdOrdenCompra int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        OC.NumeroOrdenCompra,
        OC.FechaOrdenCompra,
        R.Descripcion AS Requisicion,
        P.Nombre AS Proveedor,
        TB.Descripcion AS TipoBien,
        D.CantidadRecibida,
        ISNULL(D.TotalDetalle, ISNULL(D.Importe, 0)) AS Importe
    FROM ORCO.OrdenCompra OC
    INNER JOIN ORCO.Requisicion R ON R.PKIdRequisicion = OC.FKIdRequisicion_ORCO
    INNER JOIN SIS.Proveedor P ON P.PKIdProveedor = OC.FKIdProveedor_SIS
    INNER JOIN ORCO.OrdenCompraDetalle D ON D.FKIdOrdenCompra_ORCO = OC.PKIdOrdenCompra AND D.Activo = 1
    INNER JOIN ALMA.TipoBien TB ON TB.PKIdTipoBien = D.FKIdTipoBien_ALMA
    WHERE OC.PKIdOrdenCompra = @PKIdOrdenCompra AND OC.Activo = 1;
END;
GO

CREATE OR ALTER PROCEDURE [ORCO].[SPR_Entrada_A]
    @PKIdOrdenCompra int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        B.Clave,
        B.Descripcion,
        ISNULL(M.Descripcion, '') AS Marca,
        B.Modelo,
        B.Serie,
        B.Factura,
        B.ValorActual
    FROM ORCO.OrdenCompraDetalle D
    INNER JOIN ALMA.Bien B ON B.FKIdDetalleOrdenCompra_ORCO = D.PKIdOrdenCompraDetalle AND B.Activo = 1
    LEFT JOIN ALMA.Marca M ON M.PKIdMarca = B.FKIdMarca_ALMA
    WHERE D.FKIdOrdenCompra_ORCO = @PKIdOrdenCompra AND D.Activo = 1
    ORDER BY B.Clave;
END;
GO

-- Auditoria previa a agregar integridad referencial. No elimina ni reasigna datos automaticamente.
SELECT B.PKIdBien, B.FKIdDetalleOrdenCompra_ORCO
FROM ALMA.Bien B
LEFT JOIN ORCO.OrdenCompraDetalle D ON D.PKIdOrdenCompraDetalle = B.FKIdDetalleOrdenCompra_ORCO
WHERE B.Activo = 1
  AND B.FKIdDetalleOrdenCompra_ORCO IS NOT NULL
  AND D.PKIdOrdenCompraDetalle IS NULL;
GO
