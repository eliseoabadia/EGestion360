USE [GestionEmpresarial];
GO

IF SCHEMA_ID(N'ORCO') IS NULL
    EXEC(N'CREATE SCHEMA ORCO');
GO

CREATE OR ALTER VIEW [ORCO].[Vw_OrdenCompraFromClasificacionBien]
AS
    SELECT
        OrCo.PKIdOrdenCompra,
        OrCo.FKIdEmpresa_SIS,
        Req.Descripcion AS Requisicion,
        Pr.Nombre AS Proveedor,
        OrCo.Descripcion AS Justificacion,
        OrCo.FechaOrdenCompra,
        OrCo.FechaVigencia,
        SUM(Q.CantidadSolicitada) AS Solicitado,
        SUM(Q.CantidadRecibida) AS Recibido,
        SUM(Q.CantidadPendiente) AS Faltante,
        CASE
            WHEN SUM(Q.CantidadRecibida) IS NULL THEN 'POR SURTIR'
            WHEN SUM(Q.CantidadSolicitada) = ISNULL(SUM(Q.CantidadRecibida), 0) THEN 'SURTIDO TOTAL'
            WHEN SUM(Q.CantidadSolicitada) > ISNULL(SUM(Q.CantidadRecibida), 0) THEN 'SURTIDO PARCIAL'
            WHEN SUM(Q.CantidadSolicitada) < ISNULL(SUM(Q.CantidadRecibida), 0) THEN 'CERRADO'
        END AS Estado,
        OrCo.NumeroOrdenCompra AS Numero,
        MIN(CD.FKIdCotizacion_ORCO) AS FKIdCotizacion_ORCO,
        OrCo.FKIdEstatusOrdenCompra_ORCO,
        ISNULL((
            SELECT TOP (1) 1
            FROM ALMA.Bien B WITH (NOLOCK)
            INNER JOIN ORCO.OrdenCompraDetalle _DOC WITH (NOLOCK)
                ON B.FKIdDetalleOrdenCompra_ORCO = _DOC.PKIdOrdenCompraDetalle
            WHERE _DOC.FKIdOrdenCompra_ORCO = OrCo.PKIdOrdenCompra
              AND _DOC.Activo = 1
              AND B.Activo = 1
        ), 0) AS Color,
        SUM(Q.PrecioUnitario) AS PrecioUnitario,
        SUM(Q.Importe) AS Total
    FROM ORCO.OrdenCompra AS OrCo
    INNER JOIN ORCO.Requisicion AS Req
        ON OrCo.FKIdRequisicion_ORCO = Req.PKIdRequisicion
       AND Req.Activo = 1
    INNER JOIN SIS.Proveedor AS Pr
        ON OrCo.FKIdProveedor_SIS = Pr.PKIdProveedor
       AND Pr.Activo = 1
    LEFT JOIN ORCO.Vw_OrdenCompraDetalle AS Q
        ON OrCo.PKIdOrdenCompra = Q.FKIdOrdenCompra_ORCO
    LEFT JOIN ORCO.OrdenCompraDetalle AS DOC
        ON OrCo.PKIdOrdenCompra = DOC.FKIdOrdenCompra_ORCO
       AND DOC.Activo = 1
    LEFT JOIN ORCO.CotizacionDetalle AS CD
        ON DOC.FKIdCotizacionDetalle_ORCO = CD.PKIdCotizacionDetalle
       AND CD.Activo = 1
    INNER JOIN PRES.EgresoAutorizado AS EA
        ON Req.FKIdEgresoAutorizado_PRES = EA.PKIdEgresoAutorizado
       AND EA.Activo = 1
    WHERE OrCo.Activo = 1
      AND EA.FKIdPartida_CONTA > 50000
      AND EA.FKIdPartida_CONTA < 60000
    GROUP BY
        OrCo.PKIdOrdenCompra,
        OrCo.FKIdEmpresa_SIS,
        OrCo.Descripcion,
        OrCo.FechaVigencia,
        Req.Descripcion,
        Pr.Nombre,
        OrCo.FechaOrdenCompra,
        OrCo.NumeroOrdenCompra,
        OrCo.FKIdEstatusOrdenCompra_ORCO,
        EA.FKIdPartida_CONTA;
GO

EXEC spConfiguracionDeRolYClaims
    'Patrimonio',
    'Clasificacion_Bienes_Muebles',
    '10000',
    'view,view-menu,delete,new,update,CanExportToExcel';
GO

SET IDENTITY_INSERT SIS.Menu ON;
GO

MERGE SIS.Menu AS TARGET
USING (
    SELECT
        401 AS PKIdMenu,
        N'Clasificacion de Bienes Muebles' AS Nombre,
        2 AS Tipo,
        5 AS FKIdMenu_SIS,
        N'Clasificacion_Bienes_Muebles' AS LegacyName,
        N'/Patrimonio/Clasificacion_Bienes_Muebles' AS Ruta,
        N'FaFolder' AS ImageUrl,
        1 AS Activo,
        N'ESP' AS Lenguaje,
        2 AS Orden,
        1 AS CreatedByOperatorId,
        GETDATE() AS CreatedDateTime
) AS SOURCE
ON TARGET.PKIdMenu = SOURCE.PKIdMenu
WHEN MATCHED THEN
    UPDATE SET
        TARGET.Nombre = SOURCE.Nombre,
        TARGET.Tipo = SOURCE.Tipo,
        TARGET.FKIdMenu_SIS = SOURCE.FKIdMenu_SIS,
        TARGET.LegacyName = SOURCE.LegacyName,
        TARGET.Ruta = SOURCE.Ruta,
        TARGET.ImageUrl = SOURCE.ImageUrl,
        TARGET.Activo = SOURCE.Activo,
        TARGET.Lenguaje = SOURCE.Lenguaje,
        TARGET.Orden = SOURCE.Orden,
        TARGET.ModifiedByOperatorId = 1,
        TARGET.ModifiedDateTime = GETDATE()
WHEN NOT MATCHED BY TARGET THEN
    INSERT
    (
        PKIdMenu,
        Nombre,
        Tipo,
        FKIdMenu_SIS,
        LegacyName,
        Ruta,
        ImageUrl,
        Activo,
        Lenguaje,
        Orden,
        CreatedByOperatorId,
        CreatedDateTime
    )
    VALUES
    (
        SOURCE.PKIdMenu,
        SOURCE.Nombre,
        SOURCE.Tipo,
        SOURCE.FKIdMenu_SIS,
        SOURCE.LegacyName,
        SOURCE.Ruta,
        SOURCE.ImageUrl,
        SOURCE.Activo,
        SOURCE.Lenguaje,
        SOURCE.Orden,
        SOURCE.CreatedByOperatorId,
        SOURCE.CreatedDateTime
    );
GO

SET IDENTITY_INSERT SIS.Menu OFF;
GO
