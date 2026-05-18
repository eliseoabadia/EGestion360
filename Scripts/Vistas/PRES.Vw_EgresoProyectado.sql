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
    ep.[FKIdFuenteFinanciamiento_PRES],
    ff.[Clave] AS [FuenteFinanciamientoClave],
    ff.[Descripcion] AS [FuenteFinanciamientoDescripcion],
    CASE WHEN ff.[PKIdFuenteFinanciamiento] IS NULL THEN NULL ELSE CONCAT(ff.[Clave], ' - ', ISNULL(ff.[Descripcion], '')) END AS [FuenteFinanciamientoClaveNombre],
    ep.[FKIdTipoGasto_PRES],
    tg.[Clave] AS [TipoGastoClave],
    tg.[Descripcion] AS [TipoGastoDescripcion],
    CASE WHEN tg.[PKIdTipoGasto] IS NULL THEN NULL ELSE CONCAT(tg.[Clave], ' - ', ISNULL(tg.[Descripcion], '')) END AS [TipoGastoClaveNombre],
    ep.[FKIdDigitoIdentificador_PRES],
    di.[Clave] AS [DigitoIdentificadorClave],
    di.[Descripcion] AS [DigitoIdentificadorDescripcion],
    CASE WHEN di.[PKIdDigitoIdentificador] IS NULL THEN NULL ELSE CONCAT(di.[Clave], ' - ', ISNULL(di.[Descripcion], '')) END AS [DigitoIdentificadorClaveNombre],
    ep.[FKIdDestinoGasto_PRES],
    dg.[Clave] AS [DestinoGastoClave],
    dg.[Descripcion] AS [DestinoGastoDescripcion],
    CASE WHEN dg.[PKIdDestinoGasto] IS NULL THEN NULL ELSE CONCAT(dg.[Clave], ' - ', ISNULL(dg.[Descripcion], '')) END AS [DestinoGastoClaveNombre],
    ep.[FKIdPY_PRES],
    py.[Clave] AS [PyClave],
    py.[Descripcion] AS [PyDescripcion],
    CASE WHEN py.[PKIdPY] IS NULL THEN NULL ELSE CONCAT(py.[Clave], ' - ', ISNULL(py.[Descripcion], '')) END AS [PyClaveNombre],
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
   AND p.[Activo] = 1
LEFT JOIN [SIS].[Anio] anio
    ON p.[FKIdAnio_SIS] = anio.[PKIdAnio]
   AND anio.[Activo] = 1
LEFT JOIN [CONTA].[Partida] part
    ON ep.[FKIdPartida_CONTA] = part.[PKIdPartida]
   AND part.[Activo] = 1
LEFT JOIN [SIS].[Area] a
    ON ep.[FKIdArea_SIS] = a.[PKIdArea]
   AND a.[Activo] = 1
LEFT JOIN [PRES].[FuenteFinanciamiento] ff
    ON ep.[FKIdFuenteFinanciamiento_PRES] = ff.[PKIdFuenteFinanciamiento]
   AND ff.[Activo] = 1
LEFT JOIN [PRES].[TipoGasto] tg
    ON ep.[FKIdTipoGasto_PRES] = tg.[PKIdTipoGasto]
   AND tg.[Activo] = 1
LEFT JOIN [PRES].[DigitoIdentificador] di
    ON ep.[FKIdDigitoIdentificador_PRES] = di.[PKIdDigitoIdentificador]
   AND di.[Activo] = 1
LEFT JOIN [PRES].[DestinoGasto] dg
    ON ep.[FKIdDestinoGasto_PRES] = dg.[PKIdDestinoGasto]
   AND dg.[Activo] = 1
LEFT JOIN [PRES].[PY] py
    ON ep.[FKIdPY_PRES] = py.[PKIdPY]
   AND py.[Activo] = 1
LEFT JOIN [PRES].[EgresoAutorizado] ea
    ON ea.[FKIdEgresoProyectado_PRES] = ep.[PKIdEgresoProyectado]
   AND ea.[Activo] = 1
WHERE ep.[Activo] = 1;
GO
