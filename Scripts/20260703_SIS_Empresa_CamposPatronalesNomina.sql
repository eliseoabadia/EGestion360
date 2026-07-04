SET NOCOUNT ON;

IF COL_LENGTH(N'SIS.Empresa', N'RegIMSS') IS NULL
    ALTER TABLE SIS.Empresa ADD RegIMSS NVARCHAR(25) NULL;
IF COL_LENGTH(N'SIS.Empresa', N'RegInfonavit') IS NULL
    ALTER TABLE SIS.Empresa ADD RegInfonavit NVARCHAR(25) NULL;
IF COL_LENGTH(N'SIS.Empresa', N'CedEmpadronam') IS NULL
    ALTER TABLE SIS.Empresa ADD CedEmpadronam NVARCHAR(25) NULL;
IF COL_LENGTH(N'SIS.Empresa', N'NoFonacot') IS NULL
    ALTER TABLE SIS.Empresa ADD NoFonacot NVARCHAR(25) NULL;
IF COL_LENGTH(N'SIS.Empresa', N'UsAdmin') IS NULL
    ALTER TABLE SIS.Empresa ADD UsAdmin NVARCHAR(100) NULL;
IF COL_LENGTH(N'SIS.Empresa', N'EmailAdmin') IS NULL
    ALTER TABLE SIS.Empresa ADD EmailAdmin NVARCHAR(100) NULL;
IF COL_LENGTH(N'SIS.Empresa', N'FKIdPeriodoPago_SIS') IS NULL
    ALTER TABLE SIS.Empresa ADD FKIdPeriodoPago_SIS INT NULL;
IF COL_LENGTH(N'SIS.Empresa', N'PrimaRiesgoIMSS') IS NULL
    ALTER TABLE SIS.Empresa ADD PrimaRiesgoIMSS DECIMAL(18, 4) NULL;
IF COL_LENGTH(N'SIS.Empresa', N'UsaSueldoTabular') IS NULL
    ALTER TABLE SIS.Empresa ADD UsaSueldoTabular BIT NOT NULL
        CONSTRAINT DF_SIS_Empresa_UsaSueldoTabular DEFAULT (0) WITH VALUES;
IF COL_LENGTH(N'SIS.Empresa', N'FKIdTipoPago_NOM') IS NULL
    ALTER TABLE SIS.Empresa ADD FKIdTipoPago_NOM INT NULL;
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
    EM.RegIMSS,
    EM.RegInfonavit,
    EM.CedEmpadronam,
    EM.NoFonacot,
    EM.UsAdmin,
    EM.EmailAdmin,
    EM.FKIdPeriodoPago_SIS,
    EM.PrimaRiesgoIMSS,
    EM.UsaSueldoTabular,
    EM.FKIdTipoPago_NOM,
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
