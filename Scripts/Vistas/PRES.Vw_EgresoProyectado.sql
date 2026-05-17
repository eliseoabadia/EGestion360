USE [GestionEmpresarial];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER VIEW [PRES].[Vw_EgresoProyectado]
AS
SELECT
    ep.[PKIdEgresoProyectado],
    ea.[PKIdEgresoAutorizado],
    CAST(CASE WHEN ea.[PKIdEgresoAutorizado] IS NULL THEN 0 ELSE 1 END AS BIT) AS [EstaAutorizado],
    ea.[FechaAutorizacion],
    p.[FKIdAnio_SIS],
    anio.[Clave] AS [AnioClave],
    ep.[FKIdPrograma_PRES],
    p.[Clave] AS [ProgramaClave],
    p.[Descripcion] AS [ProgramaDescripcion],
    CONCAT(p.[Clave], ' - ', ISNULL(p.[Descripcion], '')) AS [ProgramaClaveNombre],
    ep.[FKIdPartida_CONTA],
    part.[Clave] AS [PartidaClave],
    part.[Descripcion] AS [PartidaDescripcion],
    CONCAT(part.[Clave], ' - ', ISNULL(part.[Descripcion], '')) AS [PartidaClaveNombre],
    ep.[FKIdArea_SIS],
    a.[Clave] AS [AreaClave],
    a.[Nombre] AS [AreaNombre],
    ep.[Descripcion],
    ep.[Fecha],
    ep.[Enero],
    ep.[Febrero],
    ep.[Marzo],
    ep.[Abril],
    ep.[Mayo],
    ep.[Junio],
    ep.[Julio],
    ep.[Agosto],
    ep.[Septiembre],
    ep.[Octubre],
    ep.[Noviembre],
    ep.[Diciembre],
    ep.[Total],
    ep.[Activo],
    ep.[FechaCreacion],
    ep.[UsuarioCreacion],
    ep.[FechaModificacion],
    ep.[UsuarioModificacion]
FROM [PRES].[EgresoProyectado] ep
INNER JOIN [PRES].[Programa] p
    ON ep.[FKIdPrograma_PRES] = p.[PKIdPrograma]
LEFT JOIN [SIS].[Anio] anio
    ON p.[FKIdAnio_SIS] = anio.[PKIdAnio]
LEFT JOIN [CONTA].[Partida] part
    ON ep.[FKIdPartida_CONTA] = part.[PKIdPartida]
LEFT JOIN [SIS].[Area] a
    ON ep.[FKIdArea_SIS] = a.[PKIdArea]
LEFT JOIN [PRES].[EgresoAutorizado] ea
    ON ea.[FKIdEgresoProyectado_PRES] = ep.[PKIdEgresoProyectado]
   AND ea.[Activo] = 1
WHERE ep.[Activo] = 1;
GO
