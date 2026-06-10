USE [GestionEmpresarial];
GO

IF SCHEMA_ID(N'ORCO') IS NULL
    EXEC(N'CREATE SCHEMA ORCO');
GO

CREATE OR ALTER VIEW ORCO.Vw_OrdenCompra AS
SELECT
    oc.PKIdOrdenCompra,
    oc.FKIdEmpresa_SIS,
    e.Nombre AS EmpresaNombre,
    oc.FKIdRequisicion_ORCO,
    r.Descripcion AS RequisicionDescripcion,
    r.FechaRequisicion,
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
LEFT JOIN SIS.Empresa e ON oc.FKIdEmpresa_SIS = e.PKIdEmpresa AND e.Activo = 1
LEFT JOIN ORCO.Requisicion r ON oc.FKIdRequisicion_ORCO = r.PKIdRequisicion AND r.Activo = 1
LEFT JOIN SIS.Proveedor p ON oc.FKIdProveedor_SIS = p.PKIdProveedor AND p.Activo = 1
LEFT JOIN CONTA.Poliza po ON oc.FKIdPoliza_CONTA = po.PKIdPoliza AND po.Activo = 1
LEFT JOIN ORCO.EstatusOrdenCompra es ON oc.FKIdEstatusOrdenCompra_ORCO = es.PK_IdEstatusOrdenCompra AND es.CT_LIVE = 1
LEFT JOIN SIS.Moneda m ON oc.MonedaId = m.PKIdMoneda AND m.Activo = 1
WHERE oc.Activo = 1;
GO

CREATE OR ALTER VIEW ORCO.Vw_OrdenCompraDetalle AS
SELECT
    od.PKIdOrdenCompraDetalle,
    od.FKIdOrdenCompra_ORCO,
    oc.NumeroOrdenCompra,
    od.FKIdRequisicionDetalle_ORCO,
    rd.FKIdRequisicion_ORCO AS IdRequisicion,
    od.FKIdCotizacionDetalle_ORCO,
    od.FKIdTipoBien_ALMA,
    tb.CodigoClave AS TipoBienCodigoClave,
    tb.Descripcion AS TipoBienDescripcion,
    tb.CABMS,
    tb.Identificador,
    od.FKIdUnidades_ALMA,
    u.Descripcion AS UnidadMedida,
    od.CantidadSolicitada,
    od.CantidadRecibida,
    od.CantidadPendiente,
    od.PrecioUnitario,
    od.Importe,
    od.Iva,
    od.TotalDetalle,
    od.Observaciones,
    od.Activo,
    od.FechaCreacion,
    od.UsuarioCreacion,
    od.FechaModificacion,
    od.UsuarioModificacion,
    CONCAT(tb.CodigoClave, ' - ', tb.Descripcion) AS BienClaveNombre
FROM ORCO.OrdenCompraDetalle od
INNER JOIN ORCO.OrdenCompra oc ON od.FKIdOrdenCompra_ORCO = oc.PKIdOrdenCompra AND oc.Activo = 1
LEFT JOIN ORCO.RequisicionDetalle rd ON od.FKIdRequisicionDetalle_ORCO = rd.PKIdRequisicionDetalle AND rd.Activo = 1
LEFT JOIN ORCO.CotizacionDetalle cd ON od.FKIdCotizacionDetalle_ORCO = cd.PKIdCotizacionDetalle AND cd.Activo = 1
LEFT JOIN ALMA.TipoBien tb ON od.FKIdTipoBien_ALMA = tb.PKIdTipoBien AND tb.Activo = 1
LEFT JOIN ALMA.Unidades u ON od.FKIdUnidades_ALMA = u.PKIdUnidades AND u.Activo = 1
WHERE od.Activo = 1;
GO

CREATE OR ALTER VIEW ORCO.Vw_OrdenCompraPartida AS
SELECT
    op.PKIdOrdenCompraPartida,
    op.FKIdOrdenCompra_ORCO,
    oc.NumeroOrdenCompra,
    op.FKIdPartida_CONTA,
    p.Clave AS PartidaClave,
    p.Descripcion AS PartidaDescripcion,
    CONCAT(p.Clave, ' - ', p.Descripcion) AS PartidaClaveNombre,
    op.FKIdFuenteFinanciamiento_PRES,
    ff.Clave AS FuenteFinanciamientoClave,
    ff.Descripcion AS FuenteFinanciamientoDescripcion,
    op.Importe,
    op.Observaciones,
    op.Activo,
    op.FechaCreacion,
    op.UsuarioCreacion,
    op.FechaModificacion,
    op.UsuarioModificacion
FROM ORCO.OrdenCompraPartida op
INNER JOIN ORCO.OrdenCompra oc ON op.FKIdOrdenCompra_ORCO = oc.PKIdOrdenCompra AND oc.Activo = 1
LEFT JOIN CONTA.Partida p ON op.FKIdPartida_CONTA = p.PKIdPartida AND p.Activo = 1
LEFT JOIN PRES.FuenteFinanciamiento ff ON op.FKIdFuenteFinanciamiento_PRES = ff.PKIdFuenteFinanciamiento AND ff.Activo = 1
WHERE op.Activo = 1;
GO
