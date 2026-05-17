USE [GestionEmpresarial];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER VIEW [PRES].[Vw_EgresoAutorizado]
AS
SELECT
    ea.[PKIdEgresoAutorizado],
    ea.[FKIdEgresoProyectado_PRES],
    p.[FKIdAnio_SIS],
    anio.[Clave] AS [AnioClave],
    ea.[FKIdPrograma_PRES],
    p.[Clave] AS [ProgramaClave],
    p.[Descripcion] AS [ProgramaDescripcion],
    CONCAT(p.[Clave], ' - ', ISNULL(p.[Descripcion], '')) AS [ProgramaClaveNombre],
    ea.[FKIdPartida_CONTA],
    part.[Clave] AS [PartidaClave],
    part.[Descripcion] AS [PartidaDescripcion],
    CONCAT(part.[Clave], ' - ', ISNULL(part.[Descripcion], '')) AS [PartidaClaveNombre],
    ea.[FKIdArea_SIS],
    a.[Clave] AS [AreaClave],
    a.[Nombre] AS [AreaNombre],
    ea.[Descripcion],
    ea.[Fecha],
    ea.[FKIdPoliza_CONTA],
    ea.[Enero],
    ea.[Febrero],
    ea.[Marzo],
    ea.[Abril],
    ea.[Mayo],
    ea.[Junio],
    ea.[Julio],
    ea.[Agosto],
    ea.[Septiembre],
    ea.[Octubre],
    ea.[Noviembre],
    ea.[Diciembre],
    ea.[Total],
    ea.[FechaAutorizacion],
    ea.[UsuarioAutorizacion],
    ea.[Activo],
    ea.[FechaCreacion],
    ea.[UsuarioCreacion],
    ea.[FechaModificacion],
    ea.[UsuarioModificacion]
FROM [PRES].[EgresoAutorizado] ea
INNER JOIN [PRES].[Programa] p
    ON ea.[FKIdPrograma_PRES] = p.[PKIdPrograma]
LEFT JOIN [SIS].[Anio] anio
    ON p.[FKIdAnio_SIS] = anio.[PKIdAnio]
LEFT JOIN [CONTA].[Partida] part
    ON ea.[FKIdPartida_CONTA] = part.[PKIdPartida]
LEFT JOIN [SIS].[Area] a
    ON ea.[FKIdArea_SIS] = a.[PKIdArea]
WHERE ea.[Activo] = 1;
GO
