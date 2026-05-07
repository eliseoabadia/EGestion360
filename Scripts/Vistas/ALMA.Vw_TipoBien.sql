USE [GestionEmpresarial];
GO

IF OBJECT_ID('ALMA.Vw_TipoBien', 'V') IS NOT NULL DROP VIEW ALMA.Vw_TipoBien;
GO

CREATE VIEW ALMA.Vw_TipoBien
AS
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
    -- GrupoBien y Familia (activos)
    gb.Descripcion AS GrupoBienDescripcion,
    gb.Clave AS GrupoBienClave,
    gb.ClaveAN,
    gb.CABM_ACT,
    gb.CLAVE_CUCOP,
    gb.MEDIDA AS GrupoBienMedida,
    f.Descripcion AS FamiliaDescripcion,
    f.Clave AS FamiliaClave,
    -- Nivel (activo)
    n.Nivel,
    n.Descripcion AS NivelDescripcion,
    -- Partida (activo)
    p.Clave AS PartidaClave,
    p.Descripcion AS PartidaDescripcion,
    -- CuentaContable (activo)
    cc.Cta_Coi,
    cc.Desc_Coi AS CuentaDescripcion,
    cc.TipoCuenta,
    -- Unidades (activo)
    u.Descripcion AS UnidadMedida,
    -- Unidades Equivalente (activo)
    ue.Descripcion AS UnidadEquivalenteMedida--,
    -- Localizacion (activo)
    --l.Clave AS LocalizacionClave,
    --l.Descripcion AS LocalizacionDescripcion
FROM ALMA.TipoBien tb
LEFT JOIN ALMA.GrupoBien gb ON tb.FKIdGrupoBien_ALMA = gb.PKIdGrupoBien AND gb.Activo = 1
LEFT JOIN ALMA.Familia f ON gb.FKIdFamilia_ALMA = f.PKIdFamilia AND f.Activo = 1
LEFT JOIN ALMA.Nivel n ON tb.FKIdNivel_ALMA = n.PKIdNivel AND n.Activo = 1
LEFT JOIN CONTA.Partida p ON tb.FKIdPartida_CONTA = p.PKIdPartida AND p.Activo = 1
LEFT JOIN CONTA.CuentaContable cc ON tb.FKIdCuentaContable_CONTA = cc.PKIdCuentaContable AND cc.Activo = 1
LEFT JOIN ALMA.Unidades u ON tb.FKIdUnidades_ALMA = u.PKIdUnidades AND u.Activo = 1
LEFT JOIN ALMA.Unidades ue ON tb.FKIdUnidades_Equivalente = ue.PKIdUnidades AND ue.Activo = 1
--LEFT JOIN ALMA.Localizacion l ON tb.FKIdLocalizacion_ALMA = l.PKIdLocalizacion AND l.Activo = 1
WHERE tb.Activo = 1;
GO

--GRANT SELECT ON ALMA.Vw_TipoBien TO PUBLIC;
--GO