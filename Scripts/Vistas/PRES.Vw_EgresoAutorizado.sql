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
    ea.[FKIdFuenteFinanciamiento_PRES],
    ff.[Clave] AS [FuenteFinanciamientoClave],
    ff.[Descripcion] AS [FuenteFinanciamientoDescripcion],
    CASE WHEN ff.[PKIdFuenteFinanciamiento] IS NULL THEN NULL ELSE CONCAT(ff.[Clave], ' - ', ISNULL(ff.[Descripcion], '')) END AS [FuenteFinanciamientoClaveNombre],
    ea.[FKIdTipoGasto_PRES],
    tg.[Clave] AS [TipoGastoClave],
    tg.[Descripcion] AS [TipoGastoDescripcion],
    CASE WHEN tg.[PKIdTipoGasto] IS NULL THEN NULL ELSE CONCAT(tg.[Clave], ' - ', ISNULL(tg.[Descripcion], '')) END AS [TipoGastoClaveNombre],
    ea.[FKIdDigitoIdentificador_PRES],
    di.[Clave] AS [DigitoIdentificadorClave],
    di.[Descripcion] AS [DigitoIdentificadorDescripcion],
    CASE WHEN di.[PKIdDigitoIdentificador] IS NULL THEN NULL ELSE CONCAT(di.[Clave], ' - ', ISNULL(di.[Descripcion], '')) END AS [DigitoIdentificadorClaveNombre],
    ea.[FKIdDestinoGasto_PRES],
    dg.[Clave] AS [DestinoGastoClave],
    dg.[Descripcion] AS [DestinoGastoDescripcion],
    CASE WHEN dg.[PKIdDestinoGasto] IS NULL THEN NULL ELSE CONCAT(dg.[Clave], ' - ', ISNULL(dg.[Descripcion], '')) END AS [DestinoGastoClaveNombre],
    ea.[FKIdPY_PRES],
    py.[Clave] AS [PyClave],
    py.[Descripcion] AS [PyDescripcion],
    CASE WHEN py.[PKIdPY] IS NULL THEN NULL ELSE CONCAT(py.[Clave], ' - ', ISNULL(py.[Descripcion], '')) END AS [PyClaveNombre],
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
   AND p.[Activo] = 1
LEFT JOIN [SIS].[Anio] anio
    ON p.[FKIdAnio_SIS] = anio.[PKIdAnio]
   AND anio.[Activo] = 1
LEFT JOIN [CONTA].[Partida] part
    ON ea.[FKIdPartida_CONTA] = part.[PKIdPartida]
   AND part.[Activo] = 1
LEFT JOIN [SIS].[Area] a
    ON ea.[FKIdArea_SIS] = a.[PKIdArea]
   AND a.[Activo] = 1
LEFT JOIN [PRES].[FuenteFinanciamiento] ff
    ON ea.[FKIdFuenteFinanciamiento_PRES] = ff.[PKIdFuenteFinanciamiento]
   AND ff.[Activo] = 1
LEFT JOIN [PRES].[TipoGasto] tg
    ON ea.[FKIdTipoGasto_PRES] = tg.[PKIdTipoGasto]
   AND tg.[Activo] = 1
LEFT JOIN [PRES].[DigitoIdentificador] di
    ON ea.[FKIdDigitoIdentificador_PRES] = di.[PKIdDigitoIdentificador]
   AND di.[Activo] = 1
LEFT JOIN [PRES].[DestinoGasto] dg
    ON ea.[FKIdDestinoGasto_PRES] = dg.[PKIdDestinoGasto]
   AND dg.[Activo] = 1
LEFT JOIN [PRES].[PY] py
    ON ea.[FKIdPY_PRES] = py.[PKIdPY]
   AND py.[Activo] = 1
WHERE ea.[Activo] = 1;
GO
