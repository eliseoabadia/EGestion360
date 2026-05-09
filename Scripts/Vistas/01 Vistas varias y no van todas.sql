USE [GestionEmpresarial];
GO

-- =============================================
-- VISTAS PARA TABLAS CON FK (ALMA)
-- =============================================

-- 1. ALMA.Vw_GrupoBien (FK a ALMA.Familia)
IF OBJECT_ID('ALMA.Vw_GrupoBien', 'V') IS NOT NULL DROP VIEW ALMA.Vw_GrupoBien;
GO
CREATE VIEW ALMA.Vw_GrupoBien AS
SELECT 
    gb.PKIdGrupoBien,
    gb.FKIdFamilia_ALMA,
    gb.Descripcion,
    gb.Clave,
    gb.ClaveAN,
    gb.CABM_ACT,
    gb.CLAVE_CUCOP,
    gb.MEDIDA,
    gb.Activo,
    gb.FechaCreacion,
    gb.UsuarioCreacion,
    gb.FechaModificacion,
    gb.UsuarioModificacion,
    -- FK resuelta: Familia
    f.Descripcion AS FamiliaDescripcion,
    f.Clave AS FamiliaClave,
    CONCAT_WS(' / ', gb.ClaveAN, gb.CABM_ACT, gb.Descripcion) AS CatalogoCAMBS
FROM ALMA.GrupoBien gb
LEFT JOIN ALMA.Familia f ON gb.FKIdFamilia_ALMA = f.PKIdFamilia AND f.Activo = 1
WHERE gb.Activo = 1;
GO

-- 2. ALMA.Vw_TipoBien (múltiples FK: GrupoBien, Nivel, Partida, CuentaContable, Unidades, UnidadesEquivalente)
IF OBJECT_ID('ALMA.Vw_TipoBien', 'V') IS NOT NULL DROP VIEW ALMA.Vw_TipoBien;
GO
CREATE VIEW ALMA.Vw_TipoBien AS
SELECT 
    tb.PKIdTipoBien,
    tb.FKIdGrupoBien_ALMA,
    tb.FKIdNivel_ALMA,
    tb.FKIdPartida_CONTA,
    tb.FKIdCuentaContable_CONTA,
    tb.FKIdUnidades_ALMA,
    tb.FKIdLocalizacion_ALMA,
    tb.FKIdUnidades_Equivalente,
    tb.CodigoClave,
    tb.Descripcion AS TipoBienDescripcion,
    tb.DepreciacionAnual,
    tb.Consecutivo,
    tb.CABMS,
    tb.Identificador,
    tb.ExistenciaMinima,
    tb.ExistenciaMaxima,
    tb.TiempoVida,
    tb.Pk_IdTratadoInt,
    tb.Cuota,
    tb.ProveeduriaNac,
    tb.CatalogoBasico,
    tb.CUCOP_PLUS,
    tb.Cantidad_Equivalente,
    tb.Activo,
    tb.FechaCreacion,
    tb.UsuarioCreacion,
    tb.FechaModificacion,
    tb.UsuarioModificacion,
    -- FK resueltas
    gb.Descripcion AS GrupoBienDescripcion,
    gb.Clave AS GrupoBienClave,
    f.Descripcion AS FamiliaDescripcion,
    n.Descripcion AS NivelDescripcion,
    p.Clave AS PartidaClave,
    p.Descripcion AS PartidaDescripcion,
    cc.Desc_Coi AS CuentaDescripcion,
    u.Descripcion AS UnidadMedida,
    ue.Descripcion AS UnidadEquivalenteMedida
FROM ALMA.TipoBien tb
LEFT JOIN ALMA.GrupoBien gb ON tb.FKIdGrupoBien_ALMA = gb.PKIdGrupoBien AND gb.Activo = 1
LEFT JOIN ALMA.Familia f ON gb.FKIdFamilia_ALMA = f.PKIdFamilia AND f.Activo = 1
LEFT JOIN ALMA.Nivel n ON tb.FKIdNivel_ALMA = n.PKIdNivel AND n.Activo = 1
LEFT JOIN CONTA.Partida p ON tb.FKIdPartida_CONTA = p.PKIdPartida AND p.Activo = 1
LEFT JOIN CONTA.CuentaContable cc ON tb.FKIdCuentaContable_CONTA = cc.PKIdCuentaContable AND cc.Activo = 1
LEFT JOIN ALMA.Unidades u ON tb.FKIdUnidades_ALMA = u.PKIdUnidades AND u.Activo = 1
LEFT JOIN ALMA.Unidades ue ON tb.FKIdUnidades_Equivalente = ue.PKIdUnidades AND ue.Activo = 1
WHERE tb.Activo = 1;
GO

-- =============================================
-- VISTAS PARA TABLAS CON FK (ORCO)
-- =============================================

-- 3. ORCO.Vw_Fraccion (FK a ORCO.Articulo)
IF OBJECT_ID('ORCO.Vw_Fraccion', 'V') IS NOT NULL DROP VIEW ORCO.Vw_Fraccion;
GO
CREATE VIEW ORCO.Vw_Fraccion AS
SELECT 
    f.PKIdFraccion,
    f.FKIdArticulo_ORCO,
    f.Clave,
    f.Descripcion,
    f.Activo,
    f.FechaCreacion,
    f.UsuarioCreacion,
    f.FechaModificacion,
    f.UsuarioModificacion,
    a.Descripcion AS ArticuloDescripcion,
    a.Clave AS ArticuloClave,
    CONCAT(a.Clave, ' - ', a.Descripcion) AS ArticuloClaveNombre
FROM ORCO.Fraccion f
LEFT JOIN ORCO.Articulo a ON f.FKIdArticulo_ORCO = a.PKIdArticulo AND a.Activo = 1
WHERE f.Activo = 1;
GO

-- 4. ORCO.Vw_Requisicion (múltiples FK: Ejemplo simplificado con las principales)
IF OBJECT_ID('ORCO.Vw_Requisicion', 'V') IS NOT NULL DROP VIEW ORCO.Vw_Requisicion;
GO
CREATE VIEW ORCO.Vw_Requisicion AS
SELECT 
    r.PKIdRequisicion,
    r.FKIdEmpresa_SIS,
    r.FKIdPersona_NOM,
    r.FKIdArea_SIS,
    r.Descripcion,
    r.Observaciones,
    r.FechaRequisicion,
    r.Servicio,
    r.FKIdProyecto_ORCO,
    r.FKIdPrograma_PRES,
    r.Importe,
    r.FKIdSuficiencia_PRES,
    r.FKIdFuenteFinanciamiento_PRES,
    r.Activo,
    r.FechaCreacion,
    r.UsuarioCreacion,
    r.FechaModificacion,
    r.UsuarioModificacion,
    -- FKs resueltas (simplificado; agregar según necesidades)
    p.Nombre AS PersonaNombre,
    a.Nombre AS AreaNombre,
    prog.Clave AS ProgramaClave
FROM ORCO.Requisicion r
LEFT JOIN NOM.Persona p ON r.FKIdPersona_NOM = p.PKIdPersona AND p.Activo = 1
LEFT JOIN SIS.Area a ON r.FKIdArea_SIS = a.PKIdArea AND a.Activo = 1
LEFT JOIN PRES.Programa prog ON r.FKIdPrograma_PRES = prog.PKIdPrograma AND prog.Activo = 1
WHERE r.Activo = 1;
GO

-- =============================================
-- VISTAS PARA TABLAS CON FK (PRES)
-- =============================================

-- 5. PRES.Vw_Programa (múltiples FK: UR, GF, FN, SF, ActividadInstitucional, etc.)
IF OBJECT_ID('PRES.Vw_Programa', 'V') IS NOT NULL DROP VIEW PRES.Vw_Programa;
GO
CREATE VIEW PRES.Vw_Programa AS
SELECT 
    p.PKIdPrograma,
    p.FKIdUR_PRES,
    p.FKIdGF_PRES,
    p.FKIdFN_PRES,
    p.FKIdSF_PRES,
    p.FKIdActividadInstitucional_SIS,
    p.Clave,
    p.Descripcion,
    p.Activo,
    p.FechaCreacion,
    p.UsuarioCreacion,
    p.FechaModificacion,
    p.UsuarioModificacion,
    ur.Descripcion AS URDescripcion,
    gf.Descripcion AS GFDescripcion,
    fn.Descripcion AS FNDescripcion,
    sf.Descripcion AS SFDescripcion,
    ai.Descripcion AS ActividadInstitucionalDescripcion
FROM PRES.Programa p
LEFT JOIN PRES.UR ur ON p.FKIdUR_PRES = ur.PKIdUR AND ur.Activo = 1
LEFT JOIN PRES.GF gf ON p.FKIdGF_PRES = gf.PKIdGF AND gf.Activo = 1
LEFT JOIN PRES.FN fn ON p.FKIdFN_PRES = fn.PKIdFN AND fn.Activo = 1
LEFT JOIN PRES.SF sf ON p.FKIdSF_PRES = sf.PKIdSF AND sf.Activo = 1
LEFT JOIN SIS.ActividadInstitucional ai ON p.FKIdActividadInstitucional_SIS = ai.PKIdActividadInstitucional AND ai.Activo = 1
WHERE p.Activo = 1;
GO

-- 6. PRES.Vw_FN (FK a PRES.GF)
IF OBJECT_ID('PRES.Vw_FN', 'V') IS NOT NULL DROP VIEW PRES.Vw_FN;
GO
CREATE VIEW PRES.Vw_FN AS
SELECT 
    fn.PKIdFN,
    fn.FKIdGF_PRES,
    fn.Clave,
    fn.Descripcion,
    fn.Activo,
    fn.FechaCreacion,
    fn.UsuarioCreacion,
    fn.FechaModificacion,
    fn.UsuarioModificacion,
    gf.Descripcion AS GFDescripcion,
    gf.Clave AS GFClave
FROM PRES.FN fn
LEFT JOIN PRES.GF gf ON fn.FKIdGF_PRES = gf.PKIdGF AND gf.Activo = 1
WHERE fn.Activo = 1;
GO

-- 7. PRES.Vw_SF (FK a PRES.FN)
IF OBJECT_ID('PRES.Vw_SF', 'V') IS NOT NULL DROP VIEW PRES.Vw_SF;
GO
CREATE VIEW PRES.Vw_SF AS
SELECT 
    sf.PKIdSF,
    sf.FKIdFN_PRES,
    sf.Clave,
    sf.Descripcion,
    sf.Activo,
    sf.FechaCreacion,
    sf.UsuarioCreacion,
    sf.FechaModificacion,
    sf.UsuarioModificacion,
    fn.Descripcion AS FNDescripcion,
    fn.Clave AS FNClave
FROM PRES.SF sf
LEFT JOIN PRES.FN fn ON sf.FKIdFN_PRES = fn.PKIdFN AND fn.Activo = 1
WHERE sf.Activo = 1;
GO

-- 8. PRES.Vw_SubEje (FK a PRES.Eje)
IF OBJECT_ID('PRES.Vw_SubEje', 'V') IS NOT NULL DROP VIEW PRES.Vw_SubEje;
GO
CREATE VIEW PRES.Vw_SubEje AS
SELECT 
    se.PKIdSubEje,
    se.FKIdEje_PRES,
    se.Clave,
    se.Descripcion,
    se.Activo,
    se.FechaCreacion,
    se.UsuarioCreacion,
    se.FechaModificacion,
    se.UsuarioModificacion,
    e.Descripcion AS EjeDescripcion,
    e.Clave AS EjeClave
FROM PRES.SubEje se
LEFT JOIN PRES.Eje e ON se.FKIdEje_PRES = e.PKIdEje AND e.Activo = 1
WHERE se.Activo = 1;
GO

-- 9. PRES.Vw_SubSubEje (FK a PRES.SubEje)
IF OBJECT_ID('PRES.Vw_SubSubEje', 'V') IS NOT NULL DROP VIEW PRES.Vw_SubSubEje;
GO
CREATE VIEW PRES.Vw_SubSubEje AS
SELECT 
    sse.PKIdSubSubEje,
    sse.FKIdSubEje_PRES,
    sse.Clave,
    sse.Descripcion,
    sse.Activo,
    sse.FechaCreacion,
    sse.UsuarioCreacion,
    sse.FechaModificacion,
    sse.UsuarioModificacion,
    se.Descripcion AS SubEjeDescripcion,
    se.Clave AS SubEjeClave
FROM PRES.SubSubEje sse
LEFT JOIN PRES.SubEje se ON sse.FKIdSubEje_PRES = se.PKIdSubEje AND se.Activo = 1
WHERE sse.Activo = 1;
GO

-- 10. PRES.Vw_UR (FK a PRES.GrupoPresupuesto)
IF OBJECT_ID('PRES.Vw_UR', 'V') IS NOT NULL DROP VIEW PRES.Vw_UR;
GO
CREATE VIEW PRES.Vw_UR AS
SELECT 
    ur.PKIdUR,
    ur.FKIdGrupoPresupuesto_PRES,
    ur.Clave,
    ur.Descripcion,
    ur.Activo,
    ur.FechaCreacion,
    ur.UsuarioCreacion,
    ur.FechaModificacion,
    ur.UsuarioModificacion,
    gp.Descripcion AS GrupoPresupuestoDescripcion
FROM PRES.UR ur
LEFT JOIN PRES.GrupoPresupuesto gp ON ur.FKIdGrupoPresupuesto_PRES = gp.PKIdGrupoPresupuesto AND gp.Activo = 1
WHERE ur.Activo = 1;
GO

-- =============================================
-- VISTAS PARA TABLAS CON FK (CONTA)
-- =============================================

-- 11. CONTA.Vw_MatrizConversion (múltiples FK: Anio, Programa, Partida, CuentaContable...)
IF OBJECT_ID('CONTA.Vw_MatrizConversion', 'V') IS NOT NULL DROP VIEW CONTA.Vw_MatrizConversion;
GO
CREATE VIEW CONTA.Vw_MatrizConversion AS
SELECT 
    mc.PKIdMatrizConversion,
    mc.FKIdAnio_SIS,
    mc.FKIdPrograma_PRES,
    mc.FKIdPartida_SIS,
    mc.FKIdCuentaContableAprobado,
    mc.FKIdCuentaContablePorEjercer,
    mc.FKIdCuentaContableModificado,
    mc.FKIdCuentaContableComprometido,
    mc.FKIdCuentaContableDevengado,
    mc.FKIdCuentaContableEjercido,
    mc.FKIdCuentaContablePagado,
    mc.FKIdCuentaContableGasto,
    mc.Activo,
    mc.FechaCreacion,
    mc.UsuarioCreacion,
    mc.FechaModificacion,
    mc.UsuarioModificacion,
    a.Clave AS AnioClave,
    p.Clave AS ProgramaClave,
    p.Descripcion AS ProgramaDescripcion,
    pt.Clave AS PartidaClave,
    pt.Descripcion AS PartidaDescripcion,
    -- Puedes agregar más resoluciones de cuentas si es necesario
    ctaA.ClaveNombre AS CuentaAprobadoNombre
FROM CONTA.MatrizConversion mc
LEFT JOIN SIS.Anio a ON mc.FKIdAnio_SIS = a.PKIdAnio
LEFT JOIN PRES.Programa p ON mc.FKIdPrograma_PRES = p.PKIdPrograma AND p.Activo = 1
LEFT JOIN SIS.Partida pt ON mc.FKIdPartida_SIS = pt.PKIdPartida AND pt.Activo = 1
LEFT JOIN CONTA.Vw_Cuentas ctaA ON mc.FKIdCuentaContableAprobado = ctaA.PkIdCuenta
WHERE mc.Activo = 1;
GO

-- =============================================
-- VISTAS PARA TABLAS CON FK (SIS)
-- =============================================

-- 12. SIS.Vw_Area (FK recursiva a SIS.Area)
IF OBJECT_ID('SIS.Vw_Area', 'V') IS NOT NULL DROP VIEW SIS.Vw_Area;
GO
CREATE VIEW SIS.Vw_Area AS
SELECT 
    a.PKIdArea,
    a.FKIdArea_SIS,
    a.Clave,
    a.Nombre,
    a.UltimoInv,
    a.Activo,
    a.FechaCreacion,
    a.UsuarioCreacion,
    a.FechaModificacion,
    a.UsuarioModificacion,
    a_padre.Nombre AS AreaPadreNombre,
    a_padre.Clave AS AreaPadreClave
FROM SIS.Area a
LEFT JOIN SIS.Area a_padre ON a.FKIdArea_SIS = a_padre.PKIdArea AND a_padre.Activo = 1
WHERE a.Activo = 1;
GO

-- 13. SIS.Vw_Concepto (FK a SIS.Capitulo)
IF OBJECT_ID('SIS.Vw_Concepto', 'V') IS NOT NULL DROP VIEW SIS.Vw_Concepto;
GO
CREATE VIEW SIS.Vw_Concepto AS
SELECT 
    c.PKIdConcepto,
    c.FKIdCapitulo_SIS,
    c.Clave,
    c.Descripcion,
    c.Activo,
    c.FechaCreacion,
    c.UsuarioCreacion,
    c.FechaModificacion,
    c.UsuarioModificacion,
    cap.Descripcion AS CapituloDescripcion,
    cap.Clave AS CapituloClave
FROM SIS.Concepto c
LEFT JOIN SIS.Capitulo cap ON c.FKIdCapitulo_SIS = cap.PKIdCapitulo AND cap.Activo = 1
WHERE c.Activo = 1;
GO

-- 14. SIS.Vw_Partida (FK a SIS.Concepto)
IF OBJECT_ID('SIS.Vw_Partida', 'V') IS NOT NULL DROP VIEW SIS.Vw_Partida;
GO
CREATE VIEW SIS.Vw_Partida AS
SELECT 
    p.PKIdPartida,
    p.FKIdConcepto_SIS,
    p.Clave,
    p.Descripcion,
    p.Activo,
    p.FechaCreacion,
    p.UsuarioCreacion,
    p.FechaModificacion,
    p.UsuarioModificacion,
    c.Descripcion AS ConceptoDescripcion,
    c.Clave AS ConceptoClave
FROM SIS.Partida p
LEFT JOIN SIS.Concepto c ON p.FKIdConcepto_SIS = c.PKIdConcepto AND c.Activo = 1
WHERE p.Activo = 1;
GO

-- 15. SIS.Vw_UsuarioSucursal (FK a SIS.Usuario y SIS.Sucursal)
IF OBJECT_ID('SIS.Vw_UsuarioSucursal', 'V') IS NOT NULL DROP VIEW SIS.Vw_UsuarioSucursal;
GO
CREATE VIEW SIS.Vw_UsuarioSucursal AS
SELECT 
    us.FKIdUsuario_SIS,
    us.FKIdSucursal_SIS,
    us.PuedeAcceder,
    us.PuedeConfigurar,
    us.PuedeOperar,
    us.PuedeReportes,
    us.EsGerente,
    us.EsSupervisor,
    us.Activo,
    us.FechaCreacion,
    us.UsuarioCreacion,
    us.FechaModificacion,
    us.UsuarioModificacion,
    u.Nombre AS UsuarioNombre,
    s.Nombre AS SucursalNombre
FROM SIS.UsuarioSucursal us
LEFT JOIN SIS.Usuario u ON us.FKIdUsuario_SIS = u.PkIdUsuario AND u.Activo = 1
LEFT JOIN SIS.Sucursal s ON us.FKIdSucursal_SIS = s.PKIdSucursal AND s.Activo = 1
WHERE us.Activo = 1;
GO

-- 16. SIS.Vw_Proveedor (múltiples FK: TipoProveedor, EstatusProveedor, CuentaContable, Municipio, Estado, Pais)
IF OBJECT_ID('SIS.Vw_Proveedor', 'V') IS NOT NULL DROP VIEW SIS.Vw_Proveedor;
GO
CREATE VIEW SIS.Vw_Proveedor AS
SELECT 
    prov.PKIdProveedor,
    prov.FkIdTipoProveedor_SIS,
    prov.FKIdEstatusProveedor_SIS,
    prov.FKIdCuentaContable_SIS,
    prov.FKIdMunicipio_SIS,
    prov.FKIdEstado_SIS,
    prov.FKIdPais_SIS,
    prov.Nombre,
    prov.RFC,
    prov.Clave,
    prov.Activo,
    prov.FechaCreacion,
    prov.UsuarioCreacion,
    prov.FechaModificacion,
    prov.UsuarioModificacion,
    tp.Descripcion AS TipoProveedorDesc,
    ep.Descripcion AS EstatusProveedorDesc,
    cc.Cta_Coi AS CuentaContableClave,
    m.Nombre AS MunicipioNombre,
    e.Nombre AS EstadoNombre,
    pa.Nombre AS PaisNombre
FROM SIS.Proveedor prov
LEFT JOIN SIS.TipoProveedor tp ON prov.FkIdTipoProveedor_SIS = tp.PkIdTipoProveedor AND tp.Activo = 1
LEFT JOIN SIS.EstatusProveedor ep ON prov.FKIdEstatusProveedor_SIS = ep.PKIdEstatusProveedor AND ep.Activo = 1
LEFT JOIN CONTA.CuentaContable cc ON prov.FKIdCuentaContable_SIS = cc.PKIdCuentaContable AND cc.Activo = 1
LEFT JOIN SIS.Municipios m ON prov.FKIdMunicipio_SIS = m.PKIdMunicipio AND m.Activo = 1
LEFT JOIN SIS.Estados e ON prov.FKIdEstado_SIS = e.PKIdEstado AND e.Activo = 1
LEFT JOIN SIS.Paises pa ON prov.FKIdPais_SIS = pa.PKIdPais AND pa.Activo = 1
WHERE prov.Activo = 1;
GO

-- =============================================
-- VISTAS PARA TABLAS CON FK (TES)
-- =============================================

-- 17. TES.Vw_TipoCambio (FK a TES.TipoMoneda)
IF OBJECT_ID('TES.Vw_TipoCambio', 'V') IS NOT NULL DROP VIEW TES.Vw_TipoCambio;
GO
CREATE VIEW TES.Vw_TipoCambio AS
SELECT 
    tc.PKIdTipoCambio,
    tc.FKIdTipoMoneda_TES,
    tc.Cantidad,
    tc.Fecha,
    tc.Activo,
    tc.FechaCreacion,
    tc.UsuarioCreacion,
    tc.FechaModificacion,
    tc.UsuarioModificacion,
    tm.Descripcion AS MonedaDescripcion,
    tm.CodigoISO4217 AS MonedaCodigo
FROM TES.TipoCambio tc
LEFT JOIN TES.TipoMoneda tm ON tc.FKIdTipoMoneda_TES = tm.PKIdTipoMoneda AND tm.Activo = 1
WHERE tc.Activo = 1;
GO

-- =============================================
-- Vista: TES.Vw_TipoMoneda
-- Descripción: Lista las monedas con los datos del país asociado (FK a SIS.Paises).
-- Incluye campos de control (Activo, FechaCreacion, UsuarioCreacion, etc.)
-- =============================================
IF OBJECT_ID('TES.Vw_TipoMoneda', 'V') IS NOT NULL DROP VIEW TES.Vw_TipoMoneda;
GO

CREATE VIEW TES.Vw_TipoMoneda
AS
SELECT 
    tm.PKIdTipoMoneda,
    tm.FKIdPais_SIS,
    tm.Descripcion,
    tm.CodigoISO4217,
    tm.Simbolo,
    tm.Decimales,
    tm.Activo,
    tm.FechaCreacion,
    tm.UsuarioCreacion,
    tm.FechaModificacion,
    tm.UsuarioModificacion,
    -- FK resuelta: datos del país
    p.Nombre AS PaisNombre,
    p.CodigoISO2 AS PaisCodigoISO2,
    p.CodigoISO3 AS PaisCodigoISO3,
    -- Campo auxiliar para display en combos
    CONCAT(tm.Descripcion, ' (', tm.CodigoISO4217, ')') AS ClaveNombre
FROM TES.TipoMoneda tm
LEFT JOIN SIS.Paises p ON tm.FKIdPais_SIS = p.PKIdPais AND p.Activo = 1
WHERE tm.Activo = 1;
GO

---- =============================================
---- OTORGAR PERMISOS DE LECTURA (ajustar según seguridad)
---- =============================================
--GRANT SELECT ON ALMA.Vw_GrupoBien TO PUBLIC;
--GRANT SELECT ON ALMA.Vw_TipoBien TO PUBLIC;
--GRANT SELECT ON ORCO.Vw_Fraccion TO PUBLIC;
--GRANT SELECT ON ORCO.Vw_Requisicion TO PUBLIC;
--GRANT SELECT ON PRES.Vw_Programa TO PUBLIC;
--GRANT SELECT ON PRES.Vw_FN TO PUBLIC;
--GRANT SELECT ON PRES.Vw_SF TO PUBLIC;
--GRANT SELECT ON PRES.Vw_SubEje TO PUBLIC;
--GRANT SELECT ON PRES.Vw_SubSubEje TO PUBLIC;
--GRANT SELECT ON PRES.Vw_UR TO PUBLIC;
--GRANT SELECT ON CONTA.Vw_MatrizConversion TO PUBLIC;
--GRANT SELECT ON SIS.Vw_Area TO PUBLIC;
--GRANT SELECT ON SIS.Vw_Concepto TO PUBLIC;
--GRANT SELECT ON SIS.Vw_Partida TO PUBLIC;
--GRANT SELECT ON SIS.Vw_UsuarioSucursal TO PUBLIC;
--GRANT SELECT ON SIS.Vw_Proveedor TO PUBLIC;
--GRANT SELECT ON TES.Vw_TipoCambio TO PUBLIC;
--GO