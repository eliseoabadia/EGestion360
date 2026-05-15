USE [GestionEmpresarial];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [PRES].[VwPrograma]
AS
SELECT
    p.PKIdPrograma,
    p.Clave,
    p.Descripcion,
    p.Objetivo,
    CONCAT(p.Clave, ' - ', ISNULL(p.Descripcion, '')) AS ClaveNombre,

    p.FKIdUR_PRES,
    ur.Clave AS URClave,
    ur.Descripcion AS URDescripcion,
    CASE WHEN ur.PKIdUR IS NULL THEN NULL ELSE CONCAT(ur.Clave, ' - ', ur.Descripcion) END AS URClaveNombre,

    p.FKIdGF_PRES,
    gf.Clave AS GFClave,
    gf.Descripcion AS GFDescripcion,
    CASE WHEN gf.PKIdGF IS NULL THEN NULL ELSE CONCAT(gf.Clave, ' - ', gf.Descripcion) END AS GFClaveNombre,

    p.FKIdFN_PRES,
    fn.Clave AS FNClave,
    fn.Descripcion AS FNDescripcion,
    CASE WHEN fn.PKIdFN IS NULL THEN NULL ELSE CONCAT(fn.Clave, ' - ', fn.Descripcion) END AS FNClaveNombre,

    p.FKIdSF_PRES,
    sf.Clave AS SFClave,
    sf.Descripcion AS SFDescripcion,
    CASE WHEN sf.PKIdSF IS NULL THEN NULL ELSE CONCAT(sf.Clave, ' - ', sf.Descripcion) END AS SFClaveNombre,

    p.FKIdActividadInstitucional_SIS,
    ai.Clave AS ActividadInstitucionalClave,
    ai.Descripcion AS ActividadInstitucionalDescripcion,
    CASE WHEN ai.PKIdActividadInstitucional IS NULL THEN NULL ELSE CONCAT(ai.Clave, ' - ', ai.Descripcion) END AS ActividadInstitucionalClaveNombre,

    p.FKIdEje_PRES,
    eje.Clave AS EjeClave,
    eje.Descripcion AS EjeDescripcion,
    CASE WHEN eje.PKIdEje IS NULL THEN NULL ELSE CONCAT(eje.Clave, ' - ', eje.Descripcion) END AS EjeClaveNombre,

    p.FKIdSubEje_PRES,
    se.Clave AS SubEjeClave,
    se.Descripcion AS SubEjeDescripcion,
    CASE WHEN se.PKIdSubEje IS NULL THEN NULL ELSE CONCAT(se.Clave, ' - ', se.Descripcion) END AS SubEjeClaveNombre,

    p.FKIdSubSubEje_PRES,
    sse.Clave AS SubSubEjeClave,
    sse.Descripcion AS SubSubEjeDescripcion,
    CASE WHEN sse.PKIdSubSubEje IS NULL THEN NULL ELSE CONCAT(sse.Clave, ' - ', sse.Descripcion) END AS SubSubEjeClaveNombre,

    p.FKIdFinalidad_PRES,
    fin.Clave AS FinalidadClave,
    fin.Descripcion AS FinalidadDescripcion,
    CASE WHEN fin.PKIdFinalidad IS NULL THEN NULL ELSE CONCAT(fin.Clave, ' - ', fin.Descripcion) END AS FinalidadClaveNombre,

    p.FKIdVertienteGasto_PRES,
    vg.Clave AS VertienteGastoClave,
    vg.Descripcion AS VertienteGastoDescripcion,
    CASE WHEN vg.PKIdVertienteGasto IS NULL THEN NULL ELSE CONCAT(vg.Clave, ' - ', vg.Descripcion) END AS VertienteGastoClaveNombre,

    p.FKIdResultado_PRES,
    res.Clave AS ResultadoClave,
    res.Descripcion AS ResultadoDescripcion,
    CASE WHEN res.PKIdResultado IS NULL THEN NULL ELSE CONCAT(res.Clave, ' - ', res.Descripcion) END AS ResultadoClaveNombre,

    p.FKIdSubresultado_PRES,
    subres.Clave AS SubresultadoClave,
    subres.Descripcion AS SubresultadoDescripcion,
    CASE WHEN subres.PKIdSubresultado IS NULL THEN NULL ELSE CONCAT(subres.Clave, ' - ', subres.Descripcion) END AS SubresultadoClaveNombre,

    p.FKIdAnio_SIS,
    anio.Clave AS AnioClave,

    p.FKIdSector_PRES,
    sec.Clave AS SectorClave,
    sec.Descripcion AS SectorDescripcion,
    CASE WHEN sec.PKIdSector IS NULL THEN NULL ELSE CONCAT(sec.Clave, ' - ', sec.Descripcion) END AS SectorClaveNombre,

    p.FKIdSubSector_PRES,
    subsec.Clave AS SubSectorClave,
    subsec.Descripcion AS SubSectorDescripcion,
    CASE WHEN subsec.PKIdSubSector IS NULL THEN NULL ELSE CONCAT(subsec.Clave, ' - ', subsec.Descripcion) END AS SubSectorClaveNombre,

    p.FKIdTipoRecurso_PRES,
    tr.Clave AS TipoRecursoClave,
    tr.Descripcion AS TipoRecursoDescripcion,
    CASE WHEN tr.PKIdTipoRecurso IS NULL THEN NULL ELSE CONCAT(tr.Clave, ' - ', tr.Descripcion) END AS TipoRecursoClaveNombre,

    p.FKIdFuenteFinanciamiento_PRES,
    ff.Clave AS FuenteFinanciamientoClave,
    ff.Descripcion AS FuenteFinanciamientoDescripcion,
    ff.FF,
    ff.FG,
    ff.FE,
    ff.AD,
    ff.ORI,
    CASE WHEN ff.PKIdFuenteFinanciamiento IS NULL THEN NULL ELSE CONCAT(ff.Clave, ' - ', ff.Descripcion) END AS FuenteFinanciamientoClaveNombre,

    p.FKIdPP_PRES,
    pp.Clave AS PPClave,
    pp.Descripcion AS PPDescripcion,
    CASE WHEN pp.PKIdPP IS NULL THEN NULL ELSE CONCAT(pp.Clave, ' - ', pp.Descripcion) END AS PPClaveNombre,

    p.Activo,
    p.FechaCreacion,
    p.UsuarioCreacion,
    p.FechaModificacion,
    p.UsuarioModificacion
FROM PRES.Programa p
LEFT JOIN PRES.UR ur ON p.FKIdUR_PRES = ur.PKIdUR AND ur.Activo = 1
LEFT JOIN PRES.GF gf ON p.FKIdGF_PRES = gf.PKIdGF AND gf.Activo = 1
LEFT JOIN PRES.FN fn ON p.FKIdFN_PRES = fn.PKIdFN AND fn.Activo = 1
LEFT JOIN PRES.SF sf ON p.FKIdSF_PRES = sf.PKIdSF AND sf.Activo = 1
LEFT JOIN SIS.ActividadInstitucional ai ON p.FKIdActividadInstitucional_SIS = ai.PKIdActividadInstitucional AND ai.Activo = 1
LEFT JOIN PRES.Eje eje ON p.FKIdEje_PRES = eje.PKIdEje AND eje.Activo = 1
LEFT JOIN PRES.SubEje se ON p.FKIdSubEje_PRES = se.PKIdSubEje AND se.Activo = 1
LEFT JOIN PRES.SubSubEje sse ON p.FKIdSubSubEje_PRES = sse.PKIdSubSubEje AND sse.Activo = 1
LEFT JOIN PRES.Finalidad fin ON p.FKIdFinalidad_PRES = fin.PKIdFinalidad AND fin.Activo = 1
LEFT JOIN PRES.VertienteGasto vg ON p.FKIdVertienteGasto_PRES = vg.PKIdVertienteGasto AND vg.Activo = 1
LEFT JOIN PRES.Resultado res ON p.FKIdResultado_PRES = res.PKIdResultado AND res.Activo = 1
LEFT JOIN PRES.Subresultado subres ON p.FKIdSubresultado_PRES = subres.PKIdSubresultado AND subres.Activo = 1
LEFT JOIN SIS.Anio anio ON p.FKIdAnio_SIS = anio.PKIdAnio AND anio.Activo = 1
LEFT JOIN PRES.Sector sec ON p.FKIdSector_PRES = sec.PKIdSector AND sec.Activo = 1
LEFT JOIN PRES.SubSector subsec ON p.FKIdSubSector_PRES = subsec.PKIdSubSector AND subsec.Activo = 1
LEFT JOIN PRES.TipoRecurso tr ON p.FKIdTipoRecurso_PRES = tr.PKIdTipoRecurso AND tr.Activo = 1
LEFT JOIN PRES.FuenteFinanciamiento ff ON p.FKIdFuenteFinanciamiento_PRES = ff.PKIdFuenteFinanciamiento AND ff.Activo = 1
LEFT JOIN PRES.PP pp ON p.FKIdPP_PRES = pp.PKIdPP AND pp.Activo = 1
WHERE p.Activo = 1;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [PRES].[Vw_Programa]
AS
SELECT *
FROM [PRES].[VwPrograma];
GO
