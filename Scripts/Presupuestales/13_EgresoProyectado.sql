USE [GestionEmpresarial];
GO

IF SCHEMA_ID('PRES') IS NULL
    EXEC('CREATE SCHEMA PRES');
GO

IF OBJECT_ID('PRES.EgresoProyectado', 'U') IS NULL
BEGIN
    CREATE TABLE [PRES].[EgresoProyectado]
    (
        [PKIdEgresoProyectado] INT IDENTITY(1,1) NOT NULL,
        [FKIdPrograma_PRES] INT NOT NULL,
        [FKIdPartida_CONTA] INT NOT NULL,
        [FKIdArea_SIS] INT NOT NULL,
        [Descripcion] NVARCHAR(250) NULL,
        [Fecha] DATE NOT NULL,
        [FKIdFuenteFinanciamiento_PRES] INT NULL,
        [FKIdTipoGasto_PRES] INT NULL,
        [FKIdDigitoIdentificador_PRES] INT NULL,
        [FKIdDestinoGasto_PRES] INT NULL,
        [FKIdPY_PRES] INT NULL,
        [Enero] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoProyectado_Enero] DEFAULT (0),
        [Febrero] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoProyectado_Febrero] DEFAULT (0),
        [Marzo] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoProyectado_Marzo] DEFAULT (0),
        [Abril] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoProyectado_Abril] DEFAULT (0),
        [Mayo] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoProyectado_Mayo] DEFAULT (0),
        [Junio] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoProyectado_Junio] DEFAULT (0),
        [Julio] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoProyectado_Julio] DEFAULT (0),
        [Agosto] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoProyectado_Agosto] DEFAULT (0),
        [Septiembre] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoProyectado_Septiembre] DEFAULT (0),
        [Octubre] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoProyectado_Octubre] DEFAULT (0),
        [Noviembre] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoProyectado_Noviembre] DEFAULT (0),
        [Diciembre] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoProyectado_Diciembre] DEFAULT (0),
        [Total] AS (
            [Enero] + [Febrero] + [Marzo] + [Abril] + [Mayo] + [Junio] +
            [Julio] + [Agosto] + [Septiembre] + [Octubre] + [Noviembre] + [Diciembre]
        ),
        [Activo] BIT NOT NULL CONSTRAINT [DF_EgresoProyectado_Activo] DEFAULT (1),
        [FechaCreacion] DATETIME2 NULL CONSTRAINT [DF_EgresoProyectado_FechaCreacion] DEFAULT (SYSDATETIME()),
        [UsuarioCreacion] INT NOT NULL,
        [FechaModificacion] DATETIME2 NULL,
        [UsuarioModificacion] INT NULL,
        CONSTRAINT [PK_EgresoProyectado] PRIMARY KEY CLUSTERED ([PKIdEgresoProyectado] ASC),
        CONSTRAINT [FK_EgresoProyectado_Programa] FOREIGN KEY ([FKIdPrograma_PRES]) REFERENCES [PRES].[Programa]([PKIdPrograma]),
        CONSTRAINT [FK_EgresoProyectado_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida]([PKIdPartida]),
        CONSTRAINT [FK_EgresoProyectado_Area] FOREIGN KEY ([FKIdArea_SIS]) REFERENCES [SIS].[Area]([PKIdArea]),
        CONSTRAINT [FK_EgresoProyectado_FuenteFinanciamiento] FOREIGN KEY ([FKIdFuenteFinanciamiento_PRES]) REFERENCES [PRES].[FuenteFinanciamiento]([PKIdFuenteFinanciamiento]),
        CONSTRAINT [FK_EgresoProyectado_TipoGasto] FOREIGN KEY ([FKIdTipoGasto_PRES]) REFERENCES [PRES].[TipoGasto]([PKIdTipoGasto]),
        CONSTRAINT [FK_EgresoProyectado_DigitoIdentificador] FOREIGN KEY ([FKIdDigitoIdentificador_PRES]) REFERENCES [PRES].[DigitoIdentificador]([PKIdDigitoIdentificador]),
        CONSTRAINT [FK_EgresoProyectado_DestinoGasto] FOREIGN KEY ([FKIdDestinoGasto_PRES]) REFERENCES [PRES].[DestinoGasto]([PKIdDestinoGasto]),
        CONSTRAINT [FK_EgresoProyectado_PY] FOREIGN KEY ([FKIdPY_PRES]) REFERENCES [PRES].[PY]([PKIdPY]),
        CONSTRAINT [FK_EgresoProyectado_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario]([PkIdUsuario]),
        CONSTRAINT [FK_EgresoProyectado_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario]([PkIdUsuario])
    );
END;
GO

IF COL_LENGTH('PRES.EgresoProyectado', 'FKIdFuenteFinanciamiento_PRES') IS NULL
    ALTER TABLE [PRES].[EgresoProyectado] ADD [FKIdFuenteFinanciamiento_PRES] INT NULL;
IF COL_LENGTH('PRES.EgresoProyectado', 'FKIdTipoGasto_PRES') IS NULL
    ALTER TABLE [PRES].[EgresoProyectado] ADD [FKIdTipoGasto_PRES] INT NULL;
IF COL_LENGTH('PRES.EgresoProyectado', 'FKIdDigitoIdentificador_PRES') IS NULL
    ALTER TABLE [PRES].[EgresoProyectado] ADD [FKIdDigitoIdentificador_PRES] INT NULL;
IF COL_LENGTH('PRES.EgresoProyectado', 'FKIdDestinoGasto_PRES') IS NULL
    ALTER TABLE [PRES].[EgresoProyectado] ADD [FKIdDestinoGasto_PRES] INT NULL;
IF COL_LENGTH('PRES.EgresoProyectado', 'FKIdPY_PRES') IS NULL
    ALTER TABLE [PRES].[EgresoProyectado] ADD [FKIdPY_PRES] INT NULL;
GO

IF OBJECT_ID('PRES.FK_EgresoProyectado_FuenteFinanciamiento', 'F') IS NULL
   AND OBJECT_ID('PRES.FuenteFinanciamiento', 'U') IS NOT NULL
    ALTER TABLE [PRES].[EgresoProyectado] WITH NOCHECK ADD CONSTRAINT [FK_EgresoProyectado_FuenteFinanciamiento]
        FOREIGN KEY ([FKIdFuenteFinanciamiento_PRES]) REFERENCES [PRES].[FuenteFinanciamiento]([PKIdFuenteFinanciamiento]);
GO

IF OBJECT_ID('PRES.FK_EgresoProyectado_TipoGasto', 'F') IS NULL
   AND OBJECT_ID('PRES.TipoGasto', 'U') IS NOT NULL
    ALTER TABLE [PRES].[EgresoProyectado] WITH NOCHECK ADD CONSTRAINT [FK_EgresoProyectado_TipoGasto]
        FOREIGN KEY ([FKIdTipoGasto_PRES]) REFERENCES [PRES].[TipoGasto]([PKIdTipoGasto]);
GO

IF OBJECT_ID('PRES.FK_EgresoProyectado_DigitoIdentificador', 'F') IS NULL
   AND OBJECT_ID('PRES.DigitoIdentificador', 'U') IS NOT NULL
    ALTER TABLE [PRES].[EgresoProyectado] WITH NOCHECK ADD CONSTRAINT [FK_EgresoProyectado_DigitoIdentificador]
        FOREIGN KEY ([FKIdDigitoIdentificador_PRES]) REFERENCES [PRES].[DigitoIdentificador]([PKIdDigitoIdentificador]);
GO

IF OBJECT_ID('PRES.FK_EgresoProyectado_DestinoGasto', 'F') IS NULL
   AND OBJECT_ID('PRES.DestinoGasto', 'U') IS NOT NULL
    ALTER TABLE [PRES].[EgresoProyectado] WITH NOCHECK ADD CONSTRAINT [FK_EgresoProyectado_DestinoGasto]
        FOREIGN KEY ([FKIdDestinoGasto_PRES]) REFERENCES [PRES].[DestinoGasto]([PKIdDestinoGasto]);
GO

IF OBJECT_ID('PRES.FK_EgresoProyectado_PY', 'F') IS NULL
   AND OBJECT_ID('PRES.PY', 'U') IS NOT NULL
    ALTER TABLE [PRES].[EgresoProyectado] WITH NOCHECK ADD CONSTRAINT [FK_EgresoProyectado_PY]
        FOREIGN KEY ([FKIdPY_PRES]) REFERENCES [PRES].[PY]([PKIdPY]);
GO
