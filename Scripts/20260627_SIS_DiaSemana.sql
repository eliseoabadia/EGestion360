USE [GestionEmpresarial];
GO

SET QUOTED_IDENTIFIER ON;
GO

IF SCHEMA_ID(N'SIS') IS NULL
BEGIN
    EXEC(N'CREATE SCHEMA SIS');
END
GO

IF OBJECT_ID(N'SIS.DiaSemana', N'U') IS NULL
BEGIN
    CREATE TABLE SIS.DiaSemana
    (
        PKIdDiaSemana INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_SIS_DiaSemana PRIMARY KEY,
        LegacyId INT NULL,
        Descripcion NVARCHAR(50) NOT NULL,
        UsuarioCreacion INT NULL,
        FechaCreacion DATETIME2(6) NULL,
        UsuarioModificacion INT NULL,
        FechaModificacion DATETIME2(6) NULL,
        Activo BIT NOT NULL CONSTRAINT DF_SIS_DiaSemana_Activo DEFAULT (1)
    );
END;
GO

IF COL_LENGTH(N'SIS.DiaSemana', N'LegacyId') IS NULL
BEGIN
    ALTER TABLE SIS.DiaSemana ADD LegacyId INT NULL;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_SIS_DiaSemana_LegacyId' AND object_id = OBJECT_ID(N'SIS.DiaSemana'))
BEGIN
    CREATE UNIQUE INDEX UX_SIS_DiaSemana_LegacyId
        ON SIS.DiaSemana (LegacyId)
        WHERE LegacyId IS NOT NULL;
END;
GO

DECLARE @Now DATETIME2(6) = SYSDATETIME();

SET IDENTITY_INSERT SIS.DiaSemana ON;

MERGE SIS.DiaSemana AS TARGET
USING
(
    SELECT
        Pk_IdDiaSemana AS PKIdDiaSemana,
        Pk_IdDiaSemana AS LegacyId,
        COALESCE(Descripcion, N'') AS Descripcion,
        CT_CreatedBy AS UsuarioCreacion,
        COALESCE(CT_CreatedDate, @Now) AS FechaCreacion,
        CT_ModifiedBy AS UsuarioModificacion,
        CT_ModifiedDate AS FechaModificacion,
        COALESCE(CT_LIVE, 1) AS Activo
    FROM [BD_GRP_INVEA].dbo.SIS_DiaSemana
) AS SOURCE
ON TARGET.LegacyId = SOURCE.LegacyId
WHEN MATCHED THEN
    UPDATE SET
        TARGET.Descripcion = SOURCE.Descripcion,
        TARGET.UsuarioCreacion = COALESCE(TARGET.UsuarioCreacion, SOURCE.UsuarioCreacion),
        TARGET.FechaCreacion = COALESCE(TARGET.FechaCreacion, SOURCE.FechaCreacion),
        TARGET.UsuarioModificacion = SOURCE.UsuarioModificacion,
        TARGET.FechaModificacion = SOURCE.FechaModificacion,
        TARGET.Activo = SOURCE.Activo
WHEN NOT MATCHED BY TARGET THEN
    INSERT
    (
        PKIdDiaSemana,
        LegacyId,
        Descripcion,
        UsuarioCreacion,
        FechaCreacion,
        UsuarioModificacion,
        FechaModificacion,
        Activo
    )
    VALUES
    (
        SOURCE.PKIdDiaSemana,
        SOURCE.LegacyId,
        SOURCE.Descripcion,
        SOURCE.UsuarioCreacion,
        SOURCE.FechaCreacion,
        SOURCE.UsuarioModificacion,
        SOURCE.FechaModificacion,
        SOURCE.Activo
    );

SET IDENTITY_INSERT SIS.DiaSemana OFF;

DELETE FROM NOM.CatalogoSimple
WHERE Catalogo = N'Dia_Semana'
  AND LegacyTable = N'SIS_DiaSemana';

IF OBJECT_ID(N'NOM.Vw_DiaSemana', N'V') IS NOT NULL
BEGIN
    DROP VIEW NOM.Vw_DiaSemana;
END;

SELECT COUNT(1) AS TotalDiaSemana
FROM SIS.DiaSemana;
GO
