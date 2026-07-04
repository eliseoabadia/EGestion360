SET NOCOUNT ON;

/*
    SIS.Empresa logo storage
    - DocumentStorage:Mode = FILESYSTEM -> Logo stores the file path or URL.
    - DocumentStorage:Mode = DATABASE   -> LogoEmpresa stores the binary content.
*/

IF COL_LENGTH(N'SIS.Empresa', N'LogoEmpresa') IS NULL
BEGIN
    ALTER TABLE SIS.Empresa
        ADD LogoEmpresa VARBINARY(MAX) NULL;
END;
GO

DECLARE @LogoDataType SYSNAME;

SELECT @LogoDataType = DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = N'SIS'
  AND TABLE_NAME = N'Empresa'
  AND COLUMN_NAME = N'Logo';

IF @LogoDataType IS NULL
BEGIN
    ALTER TABLE SIS.Empresa
        ADD Logo NVARCHAR(1024) NULL;
END
ELSE IF @LogoDataType IN (N'binary', N'varbinary', N'image')
BEGIN
    UPDATE SIS.Empresa
       SET LogoEmpresa = Logo
     WHERE LogoEmpresa IS NULL
       AND Logo IS NOT NULL;

    ALTER TABLE SIS.Empresa
        ALTER COLUMN Logo NVARCHAR(1024) NULL;

    UPDATE SIS.Empresa
       SET Logo = NULL
     WHERE LogoEmpresa IS NOT NULL;
END
ELSE IF @LogoDataType IN (N'char', N'varchar', N'nchar', N'nvarchar')
BEGIN
    ALTER TABLE SIS.Empresa
        ALTER COLUMN Logo NVARCHAR(1024) NULL;
END
ELSE
BEGIN
    DECLARE @Message NVARCHAR(4000) =
        CONCAT(N'El tipo actual de SIS.Empresa.Logo no es compatible: ', @LogoDataType);
    THROW 51000, @Message, 1;
END;

IF OBJECT_ID(N'SIS.Vw_EstadoEmpresa', N'V') IS NOT NULL
BEGIN
    EXEC sys.sp_refreshview N'SIS.Vw_EstadoEmpresa';
END;
