USE [GestionEmpresarial]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [ALMA].[Vw_Resguardo]
AS
SELECT
    r.PKIdResguardo,
    r.Folio,
    r.FKIdEmpresa_SIS,
    ISNULL(e.Nombre, N'') AS EmpresaNombre,
    r.FKIdArea_SIS,
    ISNULL(a.Clave, N'') AS AreaClave,
    ISNULL(a.Nombre, N'') AS AreaNombre,
    COALESCE(p.PKIdPersona, TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(r.Responsable)), N'')), 0) AS FKIdPersona_NOM,
    ISNULL(p.Clave, N'') AS PersonaClave,
    COALESCE(
        NULLIF(LTRIM(RTRIM(CONCAT(p.Nombre, N' ', p.Paterno, N' ', p.Materno))), N''),
        NULLIF(LTRIM(RTRIM(r.Responsable)), N''),
        N''
    ) AS PersonaNombre,
    ISNULL(r.Fecha, CONVERT(DATE, '19000101')) AS FechaResguardo,
    ISNULL(r.Observaciones, N'') AS Observaciones,
    COUNT(rd.PKIdResguardoDetalle) AS TotalBienes,
    ISNULL(SUM(ISNULL(b.ValorActual, 0)), 0) AS ValorActualResguardado,
    r.Activo,
    ISNULL(r.FechaCreacion, CONVERT(DATETIME, '19000101')) AS FechaCreacion,
    ISNULL(r.UsuarioCreacion, 0) AS UsuarioCreacion,
    r.FechaModificacion,
    r.UsuarioModificacion
FROM ALMA.Resguardo r
INNER JOIN SIS.Empresa e
    ON e.PKIdEmpresa = r.FKIdEmpresa_SIS
LEFT JOIN SIS.Area a
    ON a.PKIdArea = r.FKIdArea_SIS
OUTER APPLY
(
    SELECT TOP (1)
        p0.PKIdPersona,
        p0.Clave,
        p0.Nombre,
        p0.Paterno,
        p0.Materno
    FROM NOM.Persona p0
    WHERE p0.Activo = 1
      AND (
          p0.PKIdPersona = TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(r.Responsable)), N''))
          OR p0.Clave COLLATE DATABASE_DEFAULT = r.Responsable COLLATE DATABASE_DEFAULT
          OR LTRIM(RTRIM(CONCAT(p0.Nombre, N' ', p0.Paterno, N' ', p0.Materno))) COLLATE DATABASE_DEFAULT = r.Responsable COLLATE DATABASE_DEFAULT
      )
    ORDER BY
        CASE
            WHEN p0.PKIdPersona = TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(r.Responsable)), N'')) THEN 0
            WHEN p0.Clave COLLATE DATABASE_DEFAULT = r.Responsable COLLATE DATABASE_DEFAULT THEN 1
            ELSE 2
        END
) p
LEFT JOIN ALMA.ResguardoDetalle rd
    ON rd.FKIdResguardo_ALMA = r.PKIdResguardo
   AND rd.Activo = 1
LEFT JOIN ALMA.Bien b
    ON b.PKIdBien = rd.FKIdBien_ALMA
   AND b.Activo = 1
GROUP BY
    r.PKIdResguardo,
    r.Folio,
    r.FKIdEmpresa_SIS,
    e.Nombre,
    r.FKIdArea_SIS,
    a.Clave,
    a.Nombre,
    r.Responsable,
    p.PKIdPersona,
    p.Clave,
    p.Nombre,
    p.Paterno,
    p.Materno,
    r.Fecha,
    r.Observaciones,
    r.Activo,
    r.FechaCreacion,
    r.UsuarioCreacion,
    r.FechaModificacion,
    r.UsuarioModificacion
GO

CREATE OR ALTER VIEW [ALMA].[Vw_ResguardoDetalle]
AS
SELECT
    rd.PKIdResguardoDetalle,
    rd.FKIdResguardo_ALMA,
    ISNULL(r.Folio, N'') AS Folio,
    r.FKIdEmpresa_SIS,
    r.FKIdArea_SIS,
    ISNULL(a.Nombre, N'') AS AreaNombre,
    COALESCE(p.PKIdPersona, TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(r.Responsable)), N'')), 0) AS FKIdPersona_NOM,
    COALESCE(
        NULLIF(LTRIM(RTRIM(CONCAT(p.Nombre, N' ', p.Paterno, N' ', p.Materno))), N''),
        NULLIF(LTRIM(RTRIM(r.Responsable)), N''),
        N''
    ) AS PersonaNombre,
    rd.FKIdBien_ALMA,
    ISNULL(b.Clave, N'') AS BienClave,
    ISNULL(b.ClaveAnt, N'') AS BienClaveAnterior,
    ISNULL(b.Descripcion, N'') AS BienDescripcion,
    ISNULL(b.Modelo, N'') AS Modelo,
    ISNULL(b.Serie, N'') AS Serie,
    ISNULL(b.Factura, N'') AS Factura,
    b.Costo,
    b.ValorActual,
    b.FKIdTipoBien_ALMA,
    ISNULL(tb.CodigoClave, N'') AS TipoBienCodigoClave,
    ISNULL(tb.Descripcion, N'') AS TipoBienDescripcion,
    ISNULL(b.Consecutivo, 0) AS Consecutivo,
    ISNULL(rd.FechaAsignacion, ISNULL(rd.FechaCreacion, CONVERT(DATETIME, '19000101'))) AS FechaAsignacion,
    rd.FechaLiberacion,
    rd.ImprimeEtiqueta,
    rd.FKIdEstadoBien_ALMA,
    ISNULL(eb.DESCRIPCION_CORTA, N'') AS EstadoBienDescripcion,
    ISNULL(rd.Observaciones, N'') AS Observaciones,
    rd.Activo,
    ISNULL(rd.FechaCreacion, CONVERT(DATETIME, '19000101')) AS FechaCreacion,
    ISNULL(rd.UsuarioCreacion, 0) AS UsuarioCreacion,
    rd.FechaModificacion,
    rd.UsuarioModificacion
FROM ALMA.ResguardoDetalle rd
INNER JOIN ALMA.Resguardo r
    ON r.PKIdResguardo = rd.FKIdResguardo_ALMA
INNER JOIN ALMA.Bien b
    ON b.PKIdBien = rd.FKIdBien_ALMA
LEFT JOIN SIS.Area a
    ON a.PKIdArea = r.FKIdArea_SIS
OUTER APPLY
(
    SELECT TOP (1)
        p0.PKIdPersona,
        p0.Clave,
        p0.Nombre,
        p0.Paterno,
        p0.Materno
    FROM NOM.Persona p0
    WHERE p0.Activo = 1
      AND (
          p0.PKIdPersona = TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(r.Responsable)), N''))
          OR p0.Clave COLLATE DATABASE_DEFAULT = r.Responsable COLLATE DATABASE_DEFAULT
          OR LTRIM(RTRIM(CONCAT(p0.Nombre, N' ', p0.Paterno, N' ', p0.Materno))) COLLATE DATABASE_DEFAULT = r.Responsable COLLATE DATABASE_DEFAULT
      )
    ORDER BY
        CASE
            WHEN p0.PKIdPersona = TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(r.Responsable)), N'')) THEN 0
            WHEN p0.Clave COLLATE DATABASE_DEFAULT = r.Responsable COLLATE DATABASE_DEFAULT THEN 1
            ELSE 2
        END
) p
LEFT JOIN ALMA.TipoBien tb
    ON tb.PKIdTipoBien = b.FKIdTipoBien_ALMA
LEFT JOIN ALMA.EstadoBien eb
    ON eb.PKIdEstadoBien = rd.FKIdEstadoBien_ALMA
GO
