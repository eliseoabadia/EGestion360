USE [GestionEmpresarial];
GO

-- =============================================
-- VISTA 1: ORCO.Vw_PAAAS (Cabecera del PAAAS)
-- =============================================
IF OBJECT_ID('ORCO.Vw_PAAAS', 'V') IS NOT NULL DROP VIEW ORCO.Vw_PAAAS;
GO

CREATE VIEW ORCO.Vw_PAAAS
AS
SELECT 
    p.PKIdPAAAS,
    p.FKIdEmpresa_SIS,
    p.FKIdAnio_SIS,
    p.FKIdArea_SIS,
    p.FKIdPersona_NOM,
    p.Descripcion,
    p.Observaciones,
    p.Fecha,
    p.FKIdProyecto_ORCO,
    p.FKIdPrograma_PRES,
    p.FKIdFuenteFinanciamiento_PRES,
    p.Activo,
    p.FechaCreacion,
    p.UsuarioCreacion,
    p.FechaModificacion,
    p.UsuarioModificacion,
    -- Resolución de claves foráneas
    a.Clave AS AnioClave,
    a.Clave AS AnioDescripcion,
    area.Nombre AS AreaNombre,
    area.Clave AS AreaClave,
    per.Nombre AS ResponsableNombre,
    per.Paterno AS ResponsablePaterno,
    per.Materno AS ResponsableMaterno,
    CONCAT(per.Nombre, ' ', per.Paterno, ' ', COALESCE(per.Materno, '')) AS ResponsableCompleto,
    proy.Descripcion AS ProyectoDescripcion,
    prog.Clave AS ProgramaClave,
    prog.Descripcion AS ProgramaDescripcion,
    ff.Descripcion AS FuenteFinanciamientoDescripcion,
    ff.Clave AS FuenteFinanciamientoClave,
    -- Columna adicional para combos
    CONCAT('PAAAS ', p.PKIdPAAAS, ' - ', area.Nombre, ' (', a.Clave, ')') AS ClaveNombre
FROM ORCO.PAAAS p
LEFT JOIN SIS.Anio a ON p.FKIdAnio_SIS = a.PKIdAnio
LEFT JOIN SIS.Area area ON p.FKIdArea_SIS = area.PKIdArea AND area.Activo = 1
LEFT JOIN NOM.Persona per ON p.FKIdPersona_NOM = per.PKIdPersona AND per.Activo = 1
LEFT JOIN ORCO.Proyecto proy ON p.FKIdProyecto_ORCO = proy.PKIdProyecto AND proy.Activo = 1
LEFT JOIN PRES.Programa prog ON p.FKIdPrograma_PRES = prog.PKIdPrograma AND prog.Activo = 1
LEFT JOIN PRES.FuenteFinanciamiento ff ON p.FKIdFuenteFinanciamiento_PRES = ff.PKIdFuenteFinanciamiento AND ff.Activo = 1
WHERE p.Activo = 1;
GO

--GRANT SELECT ON ORCO.Vw_PAAAS TO PUBLIC;
--GO

-- =============================================
-- VISTA 2: ORCO.Vw_PAAASPartida (Partidas por PAAAS)
-- =============================================
IF OBJECT_ID('ORCO.Vw_PAAASPartida', 'V') IS NOT NULL DROP VIEW ORCO.Vw_PAAASPartida;
GO

CREATE VIEW ORCO.Vw_PAAASPartida
AS
SELECT 
    pp.PKIdPAAASPartida,
    pp.FKIdEmpresa_SIS,
    pp.FKIdPAAAS_ORCO,
    pp.FKIdPartida_CONTA,
    pp.Observaciones,
    pp.Activo,
    pp.FechaCreacion,
    pp.UsuarioCreacion,
    pp.FechaModificacion,
    pp.UsuarioModificacion,
    -- Resolución de claves foráneas
    part.Clave AS PartidaClave,
    part.Descripcion AS PartidaDescripcion,
    -- Datos del PAAAS padre
    paaas.Descripcion AS PAAASDescripcion,
    -- Columna para combos
    CONCAT(part.Clave, ' - ', part.Descripcion) AS ClaveNombre
FROM ORCO.PAAASPartida pp
LEFT JOIN CONTA.Partida part ON pp.FKIdPartida_CONTA = part.PKIdPartida AND part.Activo = 1
LEFT JOIN ORCO.PAAAS paaas ON pp.FKIdPAAAS_ORCO = paaas.PKIdPAAAS AND paaas.Activo = 1
WHERE pp.Activo = 1;
GO

--GRANT SELECT ON ORCO.Vw_PAAASPartida TO PUBLIC;
--GO

-- =============================================
-- VISTA 3: ORCO.Vw_PAAASDetalle (Bienes por partida/detalle)
-- =============================================
IF OBJECT_ID('ORCO.Vw_PAAASDetalle', 'V') IS NOT NULL DROP VIEW ORCO.Vw_PAAASDetalle;
GO

CREATE VIEW ORCO.Vw_PAAASDetalle
AS
SELECT 
    dp.PKIdPAAASDetalle,
    dp.FKIdEmpresa_SIS,
    dp.FKIdPAAASPartida_ORCO,
    dp.FKIdTipoBien_ALMA,
    dp.FKIdUnidades_ALMA,
    dp.Cantidad,
    dp.Observaciones,
    dp.LugarEntrega,
    dp.Activo,
    dp.FechaCreacion,
    dp.UsuarioCreacion,
    dp.FechaModificacion,
    dp.UsuarioModificacion,
    -- Resolución de claves foráneas
    tb.Descripcion AS TipoBienDescripcion,
    tb.CodigoClave AS TipoBienCodigoClave,
    tb.CABMS,
    tb.Identificador,
    tb.ExistenciaMinima,
    tb.ExistenciaMaxima,
    u.Descripcion AS UnidadMedida,
    -- Datos de la partida y PAAAS
    pp.FKIdPAAAS_ORCO,
    pp.FKIdPartida_CONTA,
    part.Clave AS PartidaClave,
    part.Descripcion AS PartidaDescripcion,
    -- Columna combinada para mostrar el bien
    CONCAT(tb.CodigoClave, ' - ', tb.Descripcion) AS BienClaveNombre
FROM ORCO.PAAASDetalle dp
LEFT JOIN ALMA.TipoBien tb ON dp.FKIdTipoBien_ALMA = tb.PKIdTipoBien AND tb.Activo = 1
LEFT JOIN ALMA.Unidades u ON dp.FKIdUnidades_ALMA = u.PKIdUnidades AND u.Activo = 1
LEFT JOIN ORCO.PAAASPartida pp ON dp.FKIdPAAASPartida_ORCO = pp.PKIdPAAASPartida AND pp.Activo = 1
LEFT JOIN CONTA.Partida part ON pp.FKIdPartida_CONTA = part.PKIdPartida AND part.Activo = 1
WHERE dp.Activo = 1;
GO

--GRANT SELECT ON ORCO.Vw_PAAASDetalle TO PUBLIC;
--GO