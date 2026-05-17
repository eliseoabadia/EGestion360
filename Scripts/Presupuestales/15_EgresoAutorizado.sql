USE [GestionEmpresarial];
GO

IF SCHEMA_ID('PRES') IS NULL
    EXEC('CREATE SCHEMA PRES');
GO

IF OBJECT_ID('PRES.EgresoAutorizado', 'U') IS NULL
BEGIN
    CREATE TABLE [PRES].[EgresoAutorizado]
    (
        [PKIdEgresoAutorizado] INT IDENTITY(1,1) NOT NULL,
        [FKIdEgresoProyectado_PRES] INT NULL,
        [FKIdPrograma_PRES] INT NOT NULL,
        [FKIdPartida_CONTA] INT NOT NULL,
        [FKIdArea_SIS] INT NOT NULL,
        [Descripcion] NVARCHAR(250) NULL,
        [Fecha] DATE NOT NULL,
        [FKIdPoliza_CONTA] INT NULL,
        [Enero] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoAutorizado_Enero] DEFAULT (0),
        [Febrero] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoAutorizado_Febrero] DEFAULT (0),
        [Marzo] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoAutorizado_Marzo] DEFAULT (0),
        [Abril] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoAutorizado_Abril] DEFAULT (0),
        [Mayo] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoAutorizado_Mayo] DEFAULT (0),
        [Junio] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoAutorizado_Junio] DEFAULT (0),
        [Julio] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoAutorizado_Julio] DEFAULT (0),
        [Agosto] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoAutorizado_Agosto] DEFAULT (0),
        [Septiembre] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoAutorizado_Septiembre] DEFAULT (0),
        [Octubre] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoAutorizado_Octubre] DEFAULT (0),
        [Noviembre] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoAutorizado_Noviembre] DEFAULT (0),
        [Diciembre] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoAutorizado_Diciembre] DEFAULT (0),
        [Total] AS (
            [Enero] + [Febrero] + [Marzo] + [Abril] + [Mayo] + [Junio] +
            [Julio] + [Agosto] + [Septiembre] + [Octubre] + [Noviembre] + [Diciembre]
        ),
        [FechaAutorizacion] DATETIME2 NULL,
        [UsuarioAutorizacion] INT NULL,
        [Activo] BIT NOT NULL CONSTRAINT [DF_EgresoAutorizado_Activo] DEFAULT (1),
        [FechaCreacion] DATETIME2 NULL CONSTRAINT [DF_EgresoAutorizado_FechaCreacion] DEFAULT (SYSDATETIME()),
        [UsuarioCreacion] INT NOT NULL,
        [FechaModificacion] DATETIME2 NULL,
        [UsuarioModificacion] INT NULL,
        CONSTRAINT [PK_EgresoAutorizado] PRIMARY KEY CLUSTERED ([PKIdEgresoAutorizado] ASC),
        CONSTRAINT [FK_EgresoAutorizado_EgresoProyectado] FOREIGN KEY ([FKIdEgresoProyectado_PRES]) REFERENCES [PRES].[EgresoProyectado]([PKIdEgresoProyectado]),
        CONSTRAINT [FK_EgresoAutorizado_Programa] FOREIGN KEY ([FKIdPrograma_PRES]) REFERENCES [PRES].[Programa]([PKIdPrograma]),
        CONSTRAINT [FK_EgresoAutorizado_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida]([PKIdPartida]),
        CONSTRAINT [FK_EgresoAutorizado_Area] FOREIGN KEY ([FKIdArea_SIS]) REFERENCES [SIS].[Area]([PKIdArea]),
        CONSTRAINT [FK_EgresoAutorizado_UsuarioAutorizacion] FOREIGN KEY ([UsuarioAutorizacion]) REFERENCES [SIS].[Usuario]([PkIdUsuario]),
        CONSTRAINT [FK_EgresoAutorizado_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario]([PkIdUsuario]),
        CONSTRAINT [FK_EgresoAutorizado_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario]([PkIdUsuario])
    );
END;
GO

IF COL_LENGTH('PRES.EgresoAutorizado', 'FKIdEgresoProyectado_PRES') IS NULL
    ALTER TABLE [PRES].[EgresoAutorizado] ADD [FKIdEgresoProyectado_PRES] INT NULL;
GO

IF COL_LENGTH('PRES.EgresoAutorizado', 'Enero') IS NULL
    ALTER TABLE [PRES].[EgresoAutorizado] ADD [Enero] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoAutorizado_Enero] DEFAULT (0);
IF COL_LENGTH('PRES.EgresoAutorizado', 'Febrero') IS NULL
    ALTER TABLE [PRES].[EgresoAutorizado] ADD [Febrero] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoAutorizado_Febrero] DEFAULT (0);
IF COL_LENGTH('PRES.EgresoAutorizado', 'Marzo') IS NULL
    ALTER TABLE [PRES].[EgresoAutorizado] ADD [Marzo] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoAutorizado_Marzo] DEFAULT (0);
IF COL_LENGTH('PRES.EgresoAutorizado', 'Abril') IS NULL
    ALTER TABLE [PRES].[EgresoAutorizado] ADD [Abril] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoAutorizado_Abril] DEFAULT (0);
IF COL_LENGTH('PRES.EgresoAutorizado', 'Mayo') IS NULL
    ALTER TABLE [PRES].[EgresoAutorizado] ADD [Mayo] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoAutorizado_Mayo] DEFAULT (0);
IF COL_LENGTH('PRES.EgresoAutorizado', 'Junio') IS NULL
    ALTER TABLE [PRES].[EgresoAutorizado] ADD [Junio] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoAutorizado_Junio] DEFAULT (0);
IF COL_LENGTH('PRES.EgresoAutorizado', 'Julio') IS NULL
    ALTER TABLE [PRES].[EgresoAutorizado] ADD [Julio] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoAutorizado_Julio] DEFAULT (0);
IF COL_LENGTH('PRES.EgresoAutorizado', 'Agosto') IS NULL
    ALTER TABLE [PRES].[EgresoAutorizado] ADD [Agosto] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoAutorizado_Agosto] DEFAULT (0);
IF COL_LENGTH('PRES.EgresoAutorizado', 'Septiembre') IS NULL
    ALTER TABLE [PRES].[EgresoAutorizado] ADD [Septiembre] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoAutorizado_Septiembre] DEFAULT (0);
IF COL_LENGTH('PRES.EgresoAutorizado', 'Octubre') IS NULL
    ALTER TABLE [PRES].[EgresoAutorizado] ADD [Octubre] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoAutorizado_Octubre] DEFAULT (0);
IF COL_LENGTH('PRES.EgresoAutorizado', 'Noviembre') IS NULL
    ALTER TABLE [PRES].[EgresoAutorizado] ADD [Noviembre] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoAutorizado_Noviembre] DEFAULT (0);
IF COL_LENGTH('PRES.EgresoAutorizado', 'Diciembre') IS NULL
    ALTER TABLE [PRES].[EgresoAutorizado] ADD [Diciembre] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_EgresoAutorizado_Diciembre] DEFAULT (0);
GO

IF COL_LENGTH('PRES.EgresoAutorizado', 'Total') IS NULL
    ALTER TABLE [PRES].[EgresoAutorizado] ADD [Total] AS (
        [Enero] + [Febrero] + [Marzo] + [Abril] + [Mayo] + [Junio] +
        [Julio] + [Agosto] + [Septiembre] + [Octubre] + [Noviembre] + [Diciembre]
    );
GO

IF COL_LENGTH('PRES.EgresoAutorizado', 'FechaAutorizacion') IS NULL
    ALTER TABLE [PRES].[EgresoAutorizado] ADD [FechaAutorizacion] DATETIME2 NULL;
IF COL_LENGTH('PRES.EgresoAutorizado', 'UsuarioAutorizacion') IS NULL
    ALTER TABLE [PRES].[EgresoAutorizado] ADD [UsuarioAutorizacion] INT NULL;
GO

IF OBJECT_ID('PRES.FK_EgresoAutorizado_EgresoProyectado', 'F') IS NULL
    ALTER TABLE [PRES].[EgresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EgresoAutorizado_EgresoProyectado]
        FOREIGN KEY ([FKIdEgresoProyectado_PRES]) REFERENCES [PRES].[EgresoProyectado]([PKIdEgresoProyectado]);
GO

IF OBJECT_ID('PRES.FK_EgresoAutorizado_UsuarioAutorizacion', 'F') IS NULL
    ALTER TABLE [PRES].[EgresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EgresoAutorizado_UsuarioAutorizacion]
        FOREIGN KEY ([UsuarioAutorizacion]) REFERENCES [SIS].[Usuario]([PkIdUsuario]);
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_EgresoAutorizado_EgresoProyectado_Activo'
      AND object_id = OBJECT_ID('PRES.EgresoAutorizado')
)
BEGIN
    CREATE UNIQUE INDEX [UX_EgresoAutorizado_EgresoProyectado_Activo]
        ON [PRES].[EgresoAutorizado]([FKIdEgresoProyectado_PRES])
        WHERE [FKIdEgresoProyectado_PRES] IS NOT NULL AND [Activo] = 1;
END;
GO

CREATE OR ALTER PROCEDURE [PRES].[spAutorizarEgresoProyectado]
    @PKIdEgresoProyectado INT,
    @UsuarioAutorizacion INT,
    @FKIdPoliza_CONTA INT = NULL,
    @Descripcion NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM [PRES].[EgresoProyectado]
        WHERE [PKIdEgresoProyectado] = @PKIdEgresoProyectado
          AND [Activo] = 1
    )
    BEGIN
        RAISERROR('El egreso proyectado no existe o no esta activo.', 16, 1);
        RETURN;
    END;

    IF EXISTS (
        SELECT 1
        FROM [PRES].[EgresoAutorizado]
        WHERE [FKIdEgresoProyectado_PRES] = @PKIdEgresoProyectado
          AND [Activo] = 1
    )
    BEGIN
        SELECT [PKIdEgresoAutorizado]
        FROM [PRES].[EgresoAutorizado]
        WHERE [FKIdEgresoProyectado_PRES] = @PKIdEgresoProyectado
          AND [Activo] = 1;
        RETURN;
    END;

    INSERT INTO [PRES].[EgresoAutorizado]
    (
        [FKIdEgresoProyectado_PRES],
        [FKIdPrograma_PRES],
        [FKIdPartida_CONTA],
        [FKIdArea_SIS],
        [Descripcion],
        [Fecha],
        [FKIdPoliza_CONTA],
        [Enero],
        [Febrero],
        [Marzo],
        [Abril],
        [Mayo],
        [Junio],
        [Julio],
        [Agosto],
        [Septiembre],
        [Octubre],
        [Noviembre],
        [Diciembre],
        [FechaAutorizacion],
        [UsuarioAutorizacion],
        [Activo],
        [FechaCreacion],
        [UsuarioCreacion]
    )
    SELECT
        ep.[PKIdEgresoProyectado],
        ep.[FKIdPrograma_PRES],
        ep.[FKIdPartida_CONTA],
        ep.[FKIdArea_SIS],
        COALESCE(@Descripcion, ep.[Descripcion]),
        CAST(SYSDATETIME() AS DATE),
        @FKIdPoliza_CONTA,
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
        SYSDATETIME(),
        @UsuarioAutorizacion,
        1,
        SYSDATETIME(),
        @UsuarioAutorizacion
    FROM [PRES].[EgresoProyectado] ep
    WHERE ep.[PKIdEgresoProyectado] = @PKIdEgresoProyectado
      AND ep.[Activo] = 1;

    SELECT CONVERT(INT, SCOPE_IDENTITY()) AS [PKIdEgresoAutorizado];
END;
GO
