SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;

EXEC(N'
ALTER VIEW [PRES].[Vw_AutorizacionSuficiencia] AS
SELECT
    aus.PKIdAutorizacionSuficiencia,
    aus.FKIdEmpresa_SIS,
    emp.Nombre AS EmpresaNombre,
    aus.FKIdSolicitudSuficiencia_PRES,
    ss.FKIdRequisicion_ORCO,
    req.FKIdAnio_SIS,
    req.Descripcion AS RequisicionDescripcion,
    ss.FechaSolicitud,
    aus.FechaAutorizacion,
    aus.Justificacion,
    aus.GastoNoProgramable,
    aus.IdGastoNoProgramable,
    aus.IdCompromisoNomina,
    aus.AutorizadoPor_NOM,
    CONCAT(per.Nombre, '' '', per.Paterno, '' '', ISNULL(per.Materno, '''')) AS AutorizadoPorNombre,
    aus.Observaciones,
    aus.Estatus,
    CASE aus.Estatus WHEN 1 THEN ''Borrador'' WHEN 2 THEN ''Autorizada'' WHEN 3 THEN ''Rechazada'' ELSE ''Sin definir'' END AS EstatusDescripcion,
    aus.Activo,
    aus.FechaCreacion,
    aus.UsuarioCreacion,
    aus.FechaModificacion,
    aus.UsuarioModificacion
FROM PRES.AutorizacionSuficiencia aus
INNER JOIN PRES.SolicitudSuficiencia ss ON aus.FKIdSolicitudSuficiencia_PRES = ss.PKIdSolicitudSuficiencia AND ss.Activo = 1
LEFT JOIN SIS.Empresa emp ON aus.FKIdEmpresa_SIS = emp.PKIdEmpresa AND emp.Activo = 1
LEFT JOIN ORCO.Requisicion req ON ss.FKIdRequisicion_ORCO = req.PKIdRequisicion AND req.Activo = 1
LEFT JOIN NOM.Persona per ON aus.AutorizadoPor_NOM = per.PKIdPersona AND per.Activo = 1
WHERE aus.Activo = 1;
');

EXEC(N'
ALTER VIEW [PRES].[Vw_Contrato] AS
SELECT
    c.PKIdContrato,
    c.FKIdEmpresa_SIS,
    emp.Nombre AS EmpresaNombre,
    c.FKIdAutorizacionSuficiencia_PRES,
    aus.FKIdSolicitudSuficiencia_PRES,
    ss.FKIdRequisicion_ORCO,
    req.FKIdAnio_SIS,
    req.Descripcion AS RequisicionDescripcion,
    c.FKIdProveedor_SIS,
    prov.Clave AS ProveedorClave,
    prov.Nombre AS ProveedorNombre,
    prov.Rfc AS ProveedorRFC,
    c.FKIdPoliza_CONTA,
    pol.ClavePoliza,
    c.NumeroContrato,
    c.Descripcion,
    c.FechaContrato,
    c.FechaInicioVigencia,
    c.FechaFinVigencia,
    c.MontoTotal,
    c.PlazoEjecucion,
    c.Observaciones,
    c.Estatus,
    CASE c.Estatus WHEN 1 THEN ''Borrador'' WHEN 2 THEN ''Vigente'' WHEN 3 THEN ''Concluido'' WHEN 4 THEN ''Cancelado'' ELSE ''Sin definir'' END AS EstatusDescripcion,
    c.Activo,
    c.FechaCreacion,
    c.UsuarioCreacion,
    c.FechaModificacion,
    c.UsuarioModificacion
FROM PRES.Contrato c
INNER JOIN PRES.AutorizacionSuficiencia aus ON c.FKIdAutorizacionSuficiencia_PRES = aus.PKIdAutorizacionSuficiencia AND aus.Activo = 1
LEFT JOIN PRES.SolicitudSuficiencia ss ON aus.FKIdSolicitudSuficiencia_PRES = ss.PKIdSolicitudSuficiencia AND ss.Activo = 1
LEFT JOIN ORCO.Requisicion req ON ss.FKIdRequisicion_ORCO = req.PKIdRequisicion AND req.Activo = 1
LEFT JOIN SIS.Empresa emp ON c.FKIdEmpresa_SIS = emp.PKIdEmpresa AND emp.Activo = 1
LEFT JOIN SIS.Proveedor prov ON c.FKIdProveedor_SIS = prov.PKIdProveedor AND prov.Activo = 1
LEFT JOIN CONTA.Poliza pol ON c.FKIdPoliza_CONTA = pol.PKIdPoliza AND pol.Activo = 1
WHERE c.Activo = 1;
');

EXEC(N'
ALTER VIEW [PRES].[VW_EgreCompNoDev] AS
WITH ContratoCalendario AS
(
    SELECT cd.FKIdContrato_PRES,
        SUM(ISNULL(cd.Enero,0)) Ene, SUM(ISNULL(cd.Febrero,0)) Feb,
        SUM(ISNULL(cd.Marzo,0)) Mar, SUM(ISNULL(cd.Abril,0)) Abr,
        SUM(ISNULL(cd.Mayo,0)) May, SUM(ISNULL(cd.Junio,0)) Jun,
        SUM(ISNULL(cd.Julio,0)) Jul, SUM(ISNULL(cd.Agosto,0)) Ago,
        SUM(ISNULL(cd.Septiembre,0)) Sep, SUM(ISNULL(cd.Octubre,0)) Oct,
        SUM(ISNULL(cd.Noviembre,0)) Nov, SUM(ISNULL(cd.Diciembre,0)) Dic,
        SUM(ISNULL(cd.Total,0)) TotalContratado
    FROM PRES.ContratoDetalle cd
    WHERE cd.Activo = 1
    GROUP BY cd.FKIdContrato_PRES
),
FacturaAplicada AS
(
    SELECT cd.FKIdContrato_PRES,
        SUM(CASE WHEN MONTH(f.FechaEmision)=1 THEN fd.MontoAplicado ELSE 0 END) Ene,
        SUM(CASE WHEN MONTH(f.FechaEmision)=2 THEN fd.MontoAplicado ELSE 0 END) Feb,
        SUM(CASE WHEN MONTH(f.FechaEmision)=3 THEN fd.MontoAplicado ELSE 0 END) Mar,
        SUM(CASE WHEN MONTH(f.FechaEmision)=4 THEN fd.MontoAplicado ELSE 0 END) Abr,
        SUM(CASE WHEN MONTH(f.FechaEmision)=5 THEN fd.MontoAplicado ELSE 0 END) May,
        SUM(CASE WHEN MONTH(f.FechaEmision)=6 THEN fd.MontoAplicado ELSE 0 END) Jun,
        SUM(CASE WHEN MONTH(f.FechaEmision)=7 THEN fd.MontoAplicado ELSE 0 END) Jul,
        SUM(CASE WHEN MONTH(f.FechaEmision)=8 THEN fd.MontoAplicado ELSE 0 END) Ago,
        SUM(CASE WHEN MONTH(f.FechaEmision)=9 THEN fd.MontoAplicado ELSE 0 END) Sep,
        SUM(CASE WHEN MONTH(f.FechaEmision)=10 THEN fd.MontoAplicado ELSE 0 END) Oct,
        SUM(CASE WHEN MONTH(f.FechaEmision)=11 THEN fd.MontoAplicado ELSE 0 END) Nov,
        SUM(CASE WHEN MONTH(f.FechaEmision)=12 THEN fd.MontoAplicado ELSE 0 END) Dic,
        SUM(ISNULL(fd.MontoAplicado,0)) TotalDevengado
    FROM PRES.FacturaDetalle fd
    INNER JOIN PRES.Factura f ON f.PKIdFactura=fd.FKIdFactura_PRES AND f.Activo=1
    INNER JOIN PRES.ContratoDetalle cd ON cd.PKIdContratoDetalle=fd.FKIdContratoDetalle_PRES AND cd.Activo=1
    WHERE fd.Activo=1
    GROUP BY cd.FKIdContrato_PRES
)
SELECT c.PKIdContrato, c.FKIdEmpresa_SIS, c.FKIdAutorizacionSuficiencia_PRES,
    ss.FKIdRequisicion_ORCO, req.Descripcion RequisicionDescripcion,
    c.FKIdPoliza_CONTA, pol.ClavePoliza,
    c.FKIdProveedor_SIS, prov.Clave ProveedorClave, prov.Nombre ProveedorNombre, prov.Rfc ProveedorRFC,
    req.FKIdAnio_SIS, anio.Clave AnioClave,
    ea.PKIdEgresoAutorizado FKIdEgresoAutorizado_PRES,
    p.PKIdPrograma FKIdPrograma_PRES, p.Clave ProgramaClave, p.Descripcion ProgramaDescripcion,
    ea.FKIdFuenteFinanciamiento_PRES,
    c.NumeroContrato, c.Descripcion, c.FechaContrato, c.FechaInicioVigencia, c.FechaFinVigencia,
    c.MontoTotal, c.PlazoEjecucion, c.Observaciones, c.Estatus,
    ISNULL(cc.Ene,0)-ISNULL(fa.Ene,0) Ene, ISNULL(cc.Feb,0)-ISNULL(fa.Feb,0) Feb,
    ISNULL(cc.Mar,0)-ISNULL(fa.Mar,0) Mar, ISNULL(cc.Abr,0)-ISNULL(fa.Abr,0) Abr,
    ISNULL(cc.May,0)-ISNULL(fa.May,0) May, ISNULL(cc.Jun,0)-ISNULL(fa.Jun,0) Jun,
    ISNULL(cc.Jul,0)-ISNULL(fa.Jul,0) Jul, ISNULL(cc.Ago,0)-ISNULL(fa.Ago,0) Ago,
    ISNULL(cc.Sep,0)-ISNULL(fa.Sep,0) Sep, ISNULL(cc.Oct,0)-ISNULL(fa.Oct,0) Oct,
    ISNULL(cc.Nov,0)-ISNULL(fa.Nov,0) Nov, ISNULL(cc.Dic,0)-ISNULL(fa.Dic,0) Dic,
    ISNULL(cc.TotalContratado,0) TotalContratado, ISNULL(fa.TotalDevengado,0) TotalDevengado,
    ISNULL(cc.TotalContratado,0)-ISNULL(fa.TotalDevengado,0) Total,
    CAST('''' AS varchar(max)) Message
FROM PRES.Contrato c
INNER JOIN PRES.AutorizacionSuficiencia aut ON aut.PKIdAutorizacionSuficiencia=c.FKIdAutorizacionSuficiencia_PRES AND aut.Activo=1
INNER JOIN PRES.SolicitudSuficiencia ss ON ss.PKIdSolicitudSuficiencia=aut.FKIdSolicitudSuficiencia_PRES AND ss.Activo=1
INNER JOIN ORCO.Requisicion req ON req.PKIdRequisicion=ss.FKIdRequisicion_ORCO AND req.Activo=1
INNER JOIN PRES.EgresoAutorizado ea ON ea.PKIdEgresoAutorizado=req.FKIdEgresoAutorizado_PRES AND ea.Activo=1
INNER JOIN PRES.Programa p ON p.PKIdPrograma=ea.FKIdPrograma_PRES AND p.Activo=1
LEFT JOIN SIS.Anio anio ON anio.PKIdAnio=req.FKIdAnio_SIS
LEFT JOIN SIS.Proveedor prov ON prov.PKIdProveedor=c.FKIdProveedor_SIS
LEFT JOIN CONTA.Poliza pol ON pol.PKIdPoliza=c.FKIdPoliza_CONTA
LEFT JOIN ContratoCalendario cc ON cc.FKIdContrato_PRES=c.PKIdContrato
LEFT JOIN FacturaAplicada fa ON fa.FKIdContrato_PRES=c.PKIdContrato
WHERE ea.FKIdFuenteFinanciamiento_PRES <> 6 AND c.Activo=1;
');

COMMIT TRANSACTION;
