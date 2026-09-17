SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF SCHEMA_ID(N'LIC') IS NULL
        EXEC(N'CREATE SCHEMA [LIC] AUTHORIZATION [dbo]');

    IF OBJECT_ID(N'[LIC].[Modulo]', N'U') IS NOT NULL
       AND (COL_LENGTH(N'LIC.Modulo', N'CodigoModulo') IS NULL
            OR COL_LENGTH(N'LIC.Modulo', N'ActivoCatalogo') IS NULL)
        THROW 51000, 'LIC.Modulo existe con una estructura incompatible.', 1;

    IF OBJECT_ID(N'[LIC].[Modulo]', N'U') IS NULL
    BEGIN
        CREATE TABLE [LIC].[Modulo]
        (
            [CodigoModulo] VARCHAR(32) NOT NULL,
            [Nombre] NVARCHAR(80) NOT NULL,
            [Grupo] VARCHAR(16) NOT NULL,
            [Orden] SMALLINT NOT NULL,
            [ActivoCatalogo] BIT NOT NULL CONSTRAINT [DF_LIC_Modulo_ActivoCatalogo] DEFAULT (1),
            [CreadoUtc] DATETIME2(3) NOT NULL CONSTRAINT [DF_LIC_Modulo_CreadoUtc] DEFAULT (SYSUTCDATETIME()),
            [RowVersion] ROWVERSION NOT NULL,
            CONSTRAINT [PK_LIC_Modulo] PRIMARY KEY ([CodigoModulo]),
            CONSTRAINT [UQ_LIC_Modulo_Orden] UNIQUE ([Orden]),
            CONSTRAINT [CK_LIC_Modulo_Grupo] CHECK ([Grupo] IN ('GRP', 'INDEPENDIENTE'))
        );
    END;

    IF OBJECT_ID(N'[LIC].[EstadoInstalacion]', N'U') IS NOT NULL
       AND (COL_LENGTH(N'LIC.EstadoInstalacion', N'InstalacionId') IS NULL
            OR COL_LENGTH(N'LIC.EstadoInstalacion', N'SelloProtegidoMaquina') IS NULL)
        THROW 51001, 'LIC.EstadoInstalacion existe con una estructura incompatible.', 1;

    IF OBJECT_ID(N'[LIC].[EstadoInstalacion]', N'U') IS NULL
    BEGIN
        CREATE TABLE [LIC].[EstadoInstalacion]
        (
            [PkidEstado] TINYINT NOT NULL,
            [InstalacionId] UNIQUEIDENTIFIER NOT NULL,
            [HuellaInstalacion] CHAR(64) NOT NULL,
            [SerialMinimoAceptado] BIGINT NOT NULL CONSTRAINT [DF_LIC_EstadoInstalacion_Serial] DEFAULT (0),
            [UltimaHoraConfiableUtc] DATETIME2(3) NOT NULL,
            [EstadoReloj] VARCHAR(16) NOT NULL CONSTRAINT [DF_LIC_EstadoInstalacion_Reloj] DEFAULT ('VALIDO'),
            [SelloProtegidoMaquina] NVARCHAR(MAX) NOT NULL,
            [CreadoUtc] DATETIME2(3) NOT NULL CONSTRAINT [DF_LIC_EstadoInstalacion_CreadoUtc] DEFAULT (SYSUTCDATETIME()),
            [ModificadoUtc] DATETIME2(3) NOT NULL CONSTRAINT [DF_LIC_EstadoInstalacion_ModificadoUtc] DEFAULT (SYSUTCDATETIME()),
            [RowVersion] ROWVERSION NOT NULL,
            CONSTRAINT [PK_LIC_EstadoInstalacion] PRIMARY KEY ([PkidEstado]),
            CONSTRAINT [CK_LIC_EstadoInstalacion_UnicaFila] CHECK ([PkidEstado] = 1),
            CONSTRAINT [CK_LIC_EstadoInstalacion_Serial] CHECK ([SerialMinimoAceptado] >= 0),
            CONSTRAINT [CK_LIC_EstadoInstalacion_Reloj] CHECK ([EstadoReloj] IN ('VALIDO', 'SOSPECHOSO')),
            CONSTRAINT [UQ_LIC_EstadoInstalacion_Id] UNIQUE ([InstalacionId]),
            CONSTRAINT [UQ_LIC_EstadoInstalacion_Huella] UNIQUE ([HuellaInstalacion])
        );
    END;

    IF OBJECT_ID(N'[LIC].[LicenciaImportada]', N'U') IS NOT NULL
       AND (COL_LENGTH(N'LIC.LicenciaImportada', N'SobreFirmado') IS NULL
            OR COL_LENGTH(N'LIC.LicenciaImportada', N'Serial') IS NULL)
        THROW 51002, 'LIC.LicenciaImportada existe con una estructura incompatible.', 1;

    IF OBJECT_ID(N'[LIC].[LicenciaImportada]', N'U') IS NULL
    BEGIN
        CREATE TABLE [LIC].[LicenciaImportada]
        (
            [PkidLicenciaImportada] BIGINT IDENTITY(1,1) NOT NULL,
            [LicenciaId] UNIQUEIDENTIFIER NOT NULL,
            [InstalacionId] UNIQUEIDENTIFIER NOT NULL,
            [Serial] BIGINT NOT NULL,
            [VersionFormato] SMALLINT NOT NULL,
            [KeyId] VARCHAR(32) NOT NULL,
            [SobreFirmado] NVARCHAR(MAX) NOT NULL,
            [HuellaSobre] BINARY(32) NOT NULL,
            [EmitidaUtc] DATETIME2(3) NOT NULL,
            [Resultado] VARCHAR(16) NOT NULL,
            [ImportadaPor] INT NOT NULL,
            [ImportadaUtc] DATETIME2(3) NOT NULL CONSTRAINT [DF_LIC_LicenciaImportada_ImportadaUtc] DEFAULT (SYSUTCDATETIME()),
            [RowVersion] ROWVERSION NOT NULL,
            CONSTRAINT [PK_LIC_LicenciaImportada] PRIMARY KEY ([PkidLicenciaImportada]),
            CONSTRAINT [UQ_LIC_LicenciaImportada_LicenciaId] UNIQUE ([LicenciaId]),
            CONSTRAINT [UQ_LIC_LicenciaImportada_InstalacionSerial] UNIQUE ([InstalacionId], [Serial]),
            CONSTRAINT [UQ_LIC_LicenciaImportada_Huella] UNIQUE ([HuellaSobre]),
            CONSTRAINT [CK_LIC_LicenciaImportada_Serial] CHECK ([Serial] > 0),
            CONSTRAINT [CK_LIC_LicenciaImportada_Resultado] CHECK ([Resultado] IN ('ACEPTADA', 'SUSTITUIDA'))
        );
    END;

    IF OBJECT_ID(N'[LIC].[LicenciaModulo]', N'U') IS NOT NULL
       AND (COL_LENGTH(N'LIC.LicenciaModulo', N'CodigoModulo') IS NULL
            OR COL_LENGTH(N'LIC.LicenciaModulo', N'FinUtc') IS NULL)
        THROW 51003, 'LIC.LicenciaModulo existe con una estructura incompatible.', 1;

    IF OBJECT_ID(N'[LIC].[LicenciaModulo]', N'U') IS NULL
    BEGIN
        CREATE TABLE [LIC].[LicenciaModulo]
        (
            [PkidLicenciaModulo] BIGINT IDENTITY(1,1) NOT NULL,
            [FkidLicenciaImportada] BIGINT NOT NULL,
            [CodigoModulo] VARCHAR(32) NOT NULL,
            [InicioUtc] DATETIME2(3) NOT NULL,
            [FinUtc] DATETIME2(3) NULL,
            [CreadoUtc] DATETIME2(3) NOT NULL CONSTRAINT [DF_LIC_LicenciaModulo_CreadoUtc] DEFAULT (SYSUTCDATETIME()),
            CONSTRAINT [PK_LIC_LicenciaModulo] PRIMARY KEY ([PkidLicenciaModulo]),
            CONSTRAINT [FK_LIC_LicenciaModulo_Licencia] FOREIGN KEY ([FkidLicenciaImportada])
                REFERENCES [LIC].[LicenciaImportada] ([PkidLicenciaImportada]),
            CONSTRAINT [FK_LIC_LicenciaModulo_Modulo] FOREIGN KEY ([CodigoModulo])
                REFERENCES [LIC].[Modulo] ([CodigoModulo]),
            CONSTRAINT [UQ_LIC_LicenciaModulo_LicenciaModulo] UNIQUE ([FkidLicenciaImportada], [CodigoModulo]),
            CONSTRAINT [CK_LIC_LicenciaModulo_Fechas] CHECK ([FinUtc] IS NULL OR [FinUtc] > [InicioUtc])
        );
    END;

    IF OBJECT_ID(N'[LIC].[ConfiguracionModulo]', N'U') IS NOT NULL
       AND (COL_LENGTH(N'LIC.ConfiguracionModulo', N'ActivoOperativo') IS NULL
            OR COL_LENGTH(N'LIC.ConfiguracionModulo', N'RowVersion') IS NULL)
        THROW 51004, 'LIC.ConfiguracionModulo existe con una estructura incompatible.', 1;

    IF OBJECT_ID(N'[LIC].[ConfiguracionModulo]', N'U') IS NULL
    BEGIN
        CREATE TABLE [LIC].[ConfiguracionModulo]
        (
            [CodigoModulo] VARCHAR(32) NOT NULL,
            [ActivoOperativo] BIT NOT NULL CONSTRAINT [DF_LIC_ConfiguracionModulo_Activo] DEFAULT (0),
            [Motivo] NVARCHAR(300) NULL,
            [ActualizadoPor] INT NULL,
            [ActualizadoUtc] DATETIME2(3) NOT NULL CONSTRAINT [DF_LIC_ConfiguracionModulo_ActualizadoUtc] DEFAULT (SYSUTCDATETIME()),
            [RowVersion] ROWVERSION NOT NULL,
            CONSTRAINT [PK_LIC_ConfiguracionModulo] PRIMARY KEY ([CodigoModulo]),
            CONSTRAINT [FK_LIC_ConfiguracionModulo_Modulo] FOREIGN KEY ([CodigoModulo])
                REFERENCES [LIC].[Modulo] ([CodigoModulo])
        );
    END;

    IF OBJECT_ID(N'[LIC].[EventoLicencia]', N'U') IS NOT NULL
       AND (COL_LENGTH(N'LIC.EventoLicencia', N'Tipo') IS NULL
            OR COL_LENGTH(N'LIC.EventoLicencia', N'OcurridoUtc') IS NULL)
        THROW 51005, 'LIC.EventoLicencia existe con una estructura incompatible.', 1;

    IF OBJECT_ID(N'[LIC].[EventoLicencia]', N'U') IS NULL
    BEGIN
        CREATE TABLE [LIC].[EventoLicencia]
        (
            [PkidEventoLicencia] BIGINT IDENTITY(1,1) NOT NULL,
            [FkidLicenciaImportada] BIGINT NULL,
            [Tipo] VARCHAR(32) NOT NULL,
            [CodigoModulo] VARCHAR(32) NULL,
            [DetalleSeguro] NVARCHAR(500) NULL,
            [Actor] NVARCHAR(128) NULL,
            [OcurridoUtc] DATETIME2(3) NOT NULL CONSTRAINT [DF_LIC_EventoLicencia_OcurridoUtc] DEFAULT (SYSUTCDATETIME()),
            [Origen] VARCHAR(16) NOT NULL,
            CONSTRAINT [PK_LIC_EventoLicencia] PRIMARY KEY ([PkidEventoLicencia]),
            CONSTRAINT [FK_LIC_EventoLicencia_Licencia] FOREIGN KEY ([FkidLicenciaImportada])
                REFERENCES [LIC].[LicenciaImportada] ([PkidLicenciaImportada]),
            CONSTRAINT [FK_LIC_EventoLicencia_Modulo] FOREIGN KEY ([CodigoModulo])
                REFERENCES [LIC].[Modulo] ([CodigoModulo]),
            CONSTRAINT [CK_LIC_EventoLicencia_Origen] CHECK ([Origen] IN ('WEB', 'API', 'HOSTED_SERVICE', 'SOPORTE'))
        );
    END;

    UPDATE target
       SET [Nombre] = source.[Nombre],
           [Grupo] = source.[Grupo],
           [Orden] = source.[Orden],
           [ActivoCatalogo] = 1
    FROM [LIC].[Modulo] target
    INNER JOIN
    (
        VALUES
            ('GRP.ADMIN', N'Administración', 'GRP', 10),
            ('GRP.ADQ', N'Adquisiciones', 'GRP', 20),
            ('GRP.ALMA', N'Almacén', 'GRP', 30),
            ('GRP.CONTA', N'Contabilidad', 'GRP', 40),
            ('GRP.PATRI', N'Patrimonio', 'GRP', 50),
            ('GRP.PRES', N'Presupuesto', 'GRP', 60),
            ('NOM', N'Nómina', 'INDEPENDIENTE', 70),
            ('PBR', N'PBR', 'INDEPENDIENTE', 80)
    ) source([CodigoModulo], [Nombre], [Grupo], [Orden])
      ON source.[CodigoModulo] = target.[CodigoModulo];

    INSERT INTO [LIC].[Modulo] ([CodigoModulo], [Nombre], [Grupo], [Orden], [ActivoCatalogo])
    SELECT source.[CodigoModulo], source.[Nombre], source.[Grupo], source.[Orden], 1
    FROM
    (
        VALUES
            ('GRP.ADMIN', N'Administración', 'GRP', 10),
            ('GRP.ADQ', N'Adquisiciones', 'GRP', 20),
            ('GRP.ALMA', N'Almacén', 'GRP', 30),
            ('GRP.CONTA', N'Contabilidad', 'GRP', 40),
            ('GRP.PATRI', N'Patrimonio', 'GRP', 50),
            ('GRP.PRES', N'Presupuesto', 'GRP', 60),
            ('NOM', N'Nómina', 'INDEPENDIENTE', 70),
            ('PBR', N'PBR', 'INDEPENDIENTE', 80)
    ) source([CodigoModulo], [Nombre], [Grupo], [Orden])
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM [LIC].[Modulo] currentModule
        WHERE currentModule.[CodigoModulo] = source.[CodigoModulo]
    );

    INSERT INTO [LIC].[ConfiguracionModulo] ([CodigoModulo], [ActivoOperativo])
    SELECT module.[CodigoModulo], 0
    FROM [LIC].[Modulo] module
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM [LIC].[ConfiguracionModulo] configuration
        WHERE configuration.[CodigoModulo] = module.[CodigoModulo]
    );

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
