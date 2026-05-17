USE [GestionEmpresarial];
GO

IF SCHEMA_ID('PRES') IS NULL
    EXEC('CREATE SCHEMA PRES');
GO

IF OBJECT_ID('PRES.FuenteFinanciamiento', 'U') IS NULL
BEGIN
    CREATE TABLE [PRES].[FuenteFinanciamiento]
    (
        [PKIdFuenteFinanciamiento] INT IDENTITY(1,1) NOT NULL,
        [Clave] NVARCHAR(6) NULL,
        [Descripcion] NVARCHAR(200) NOT NULL,
        [FF] NVARCHAR(2) NULL,
        [FG] NVARCHAR(1) NULL,
        [FE] NVARCHAR(1) NULL,
        [AD] NVARCHAR(1) NULL,
        [ORI] NVARCHAR(1) NULL,
        [Activo] BIT NOT NULL CONSTRAINT [DF_FuenteFinanciamiento_Activo] DEFAULT (1),
        [FechaCreacion] DATETIME2 NULL CONSTRAINT [DF_FuenteFinanciamiento_FechaCreacion] DEFAULT (SYSDATETIME()),
        [UsuarioCreacion] INT NOT NULL,
        [FechaModificacion] DATETIME2 NULL,
        [UsuarioModificacion] INT NULL,
        CONSTRAINT [PK_FuenteFinanciamiento] PRIMARY KEY CLUSTERED ([PKIdFuenteFinanciamiento] ASC)
    );
END;
GO

IF OBJECT_ID('PRES.FuenteFinanciamiento', 'U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FuenteFinanciamiento_Anio')
        ALTER TABLE [PRES].[FuenteFinanciamiento] DROP CONSTRAINT [FK_FuenteFinanciamiento_Anio];

    IF COL_LENGTH('PRES.FuenteFinanciamiento', 'FKIdAnio_SIS') IS NOT NULL
        ALTER TABLE [PRES].[FuenteFinanciamiento] DROP COLUMN [FKIdAnio_SIS];
END;
GO

IF OBJECT_ID('SIS.Usuario', 'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FuenteFinanciamiento_UsuarioCreacion')
BEGIN
    ALTER TABLE [PRES].[FuenteFinanciamiento]
    ADD CONSTRAINT [FK_FuenteFinanciamiento_UsuarioCreacion]
        FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario]([PkIdUsuario]);
END;
GO

IF OBJECT_ID('SIS.Usuario', 'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FuenteFinanciamiento_UsuarioModificacion')
BEGIN
    ALTER TABLE [PRES].[FuenteFinanciamiento]
    ADD CONSTRAINT [FK_FuenteFinanciamiento_UsuarioModificacion]
        FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario]([PkIdUsuario]);
END;
GO
