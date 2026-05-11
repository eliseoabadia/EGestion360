USE [GestionEmpresarial]
GO

/****** Objeto: View [SIS].[VW_UsuarioPersonaArea] Fecha de script: 10/05/2026 07:17:31 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [SIS].[VW_UsuarioPersonaArea]
AS
SELECT 
    u.PkIdUsuario
    ,u.AspNetUserId
    ,u.Nombre AS UsuarioNombre
    ,u.ApellidoPaterno
    ,u.ApellidoMaterno
    ,u.Email
    ,u.Activo AS UsuarioActivo
    ,u.FechaCreacion AS UsuarioFechaCreacion
    -- Datos de Persona
    ,p.PKIdPersona
    ,p.Clave AS PersonaClave
    ,p.Nombre AS PersonaNombre
    ,p.Paterno AS PersonaPaterno
    ,p.Materno AS PersonaMaterno
    ,p.RFC
    ,p.Curp
    ,p.CORREO_ELECTRONICO
    ,p.Activo AS PersonaActivo
    -- Datos de Área (a través de PersonaArea)
    ,pa.PKIdPersonaArea
    ,pa.IsAdscrito
    ,pa.EsSolicitante
    ,pa.EsAutorizador
    ,a.PKIdArea
    ,a.Clave AS AreaClave
    ,a.Nombre AS AreaNombre
    ,a.Activo AS AreaActivo
    ,a.FKIdArea_SIS AS AreaPadreId
    -- Campo combinado útil para frontend
    ,CONCAT(u.Nombre, ' ', u.ApellidoPaterno, ' (', ISNULL(a.Nombre, 'Sin área'), ')') AS UsuarioAreaDescripcion
FROM SIS.Usuario u
LEFT JOIN NOM.Persona p ON u.FKIdPersona_NOM = p.PKIdPersona AND p.Activo = 1
LEFT JOIN NOM.PersonaArea pa ON p.PKIdPersona = pa.FKIdPersona_NOM AND pa.Activo = 1
LEFT JOIN SIS.Area a ON pa.FKIdArea_SIS = a.PKIdArea AND a.Activo = 1
WHERE u.Activo = 1;
GO


