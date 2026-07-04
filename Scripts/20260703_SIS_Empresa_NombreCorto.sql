SET NOCOUNT ON;

IF COL_LENGTH(N'SIS.Empresa', N'NombreCorto') IS NULL
BEGIN
    ALTER TABLE SIS.Empresa
        ADD NombreCorto NVARCHAR(64) NULL;
END;
GO

UPDATE SIS.Empresa
   SET NombreCorto = LEFT(NULLIF(LTRIM(RTRIM(Nombre)), N''), 64)
 WHERE NULLIF(LTRIM(RTRIM(NombreCorto)), N'') IS NULL;
GO

CREATE OR ALTER VIEW [SIS].[Vw_EstadoEmpresa]
AS
SELECT 
    EM.PKIdEmpresa,
    EM.Nombre AS EmpresaNombre,
    EM.NombreCorto,
    EM.RFC,
    EM.RazonSocial,
    EM.Giro,
    EM.FKIdMonedaBase_SIS,
    EM.FKIdIdiomaPreferido_SIS,
    EM.Logo,
    EM.Activo AS EmpresaActivo,
    EM.FechaCreacion AS EmpresaFechaCreacion,
    EM.UsuarioCreacion AS EmpresaUsuarioCreacion,
    EM.FechaModificacion AS EmpresaFechaModificacion,
    EM.UsuarioModificacion AS EmpresaUsuarioModificacion,
    E.PKIdEstado,
    E.FKIdPais_SIS,
    E.Nombre AS EstadoNombre,
    E.CodigoEstado,
    E.Activo AS EstadoActivo,
    EE.FechaApertura,
    EE.EsOficinaPrincipal,
    EE.Activo AS RelacionActiva
FROM SIS.Empresa EM
INNER JOIN SIS.EmpresaEstado EE ON EM.PKIdEmpresa = EE.FKIdEmpresa_SIS
INNER JOIN SIS.Estados E ON EE.FKIdEstado_SIS = E.PKIdEstado
WHERE EM.Activo = 1
  AND E.Activo = 1;
GO
