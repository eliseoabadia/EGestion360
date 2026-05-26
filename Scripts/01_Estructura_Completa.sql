/*
Script de implementación para GestionEmpresarial

Una herramienta generó este código.
Los cambios realizados en este archivo podrían generar un comportamiento incorrecto y se perderán si
se vuelve a generar el código.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "GestionEmpresarial"
:setvar DefaultFilePrefix "GestionEmpresarial"
:setvar DefaultDataPath "C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\"
:setvar DefaultLogPath "C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\"

GO
:on error exit
GO
/*
Detectar el modo SQLCMD y deshabilitar la ejecución del script si no se admite el modo SQLCMD.
Para volver a habilitar el script después de habilitar el modo SQLCMD, ejecute lo siguiente:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'El modo SQLCMD debe estar habilitado para ejecutar correctamente este script.';
        SET NOEXEC ON;
    END


GO
USE [$(DatabaseName)];


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ANSI_NULLS OFF,
                ANSI_PADDING OFF,
                ANSI_WARNINGS OFF,
                ARITHABORT OFF,
                CONCAT_NULL_YIELDS_NULL OFF,
                NUMERIC_ROUNDABORT OFF,
                QUOTED_IDENTIFIER OFF,
                ANSI_NULL_DEFAULT OFF,
                CURSOR_DEFAULT GLOBAL,
                RECOVERY FULL,
                CURSOR_CLOSE_ON_COMMIT OFF,
                AUTO_CREATE_STATISTICS ON,
                AUTO_SHRINK OFF,
                AUTO_UPDATE_STATISTICS ON,
                RECURSIVE_TRIGGERS OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ALLOW_SNAPSHOT_ISOLATION OFF;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET READ_COMMITTED_SNAPSHOT OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET AUTO_UPDATE_STATISTICS_ASYNC OFF,
                PAGE_VERIFY CHECKSUM,
                DATE_CORRELATION_OPTIMIZATION OFF,
                DISABLE_BROKER,
                PARAMETERIZATION SIMPLE,
                SUPPLEMENTAL_LOGGING OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF IS_SRVROLEMEMBER(N'sysadmin') = 1
    BEGIN
        IF EXISTS (SELECT 1
                   FROM   [master].[dbo].[sysdatabases]
                   WHERE  [name] = N'$(DatabaseName)')
            BEGIN
                EXECUTE sp_executesql N'ALTER DATABASE [$(DatabaseName)]
    SET TRUSTWORTHY OFF,
        DB_CHAINING OFF 
    WITH ROLLBACK IMMEDIATE';
            END
    END
ELSE
    BEGIN
        PRINT N'No se puede modificar la configuración de la base de datos. Debe ser un administrador del sistema para poder aplicar esta configuración.';
    END


GO
IF IS_SRVROLEMEMBER(N'sysadmin') = 1
    BEGIN
        IF EXISTS (SELECT 1
                   FROM   [master].[dbo].[sysdatabases]
                   WHERE  [name] = N'$(DatabaseName)')
            BEGIN
                EXECUTE sp_executesql N'ALTER DATABASE [$(DatabaseName)]
    SET HONOR_BROKER_PRIORITY OFF 
    WITH ROLLBACK IMMEDIATE';
            END
    END
ELSE
    BEGIN
        PRINT N'No se puede modificar la configuración de la base de datos. Debe ser un administrador del sistema para poder aplicar esta configuración.';
    END


GO
ALTER DATABASE [$(DatabaseName)]
    SET TARGET_RECOVERY_TIME = 60 SECONDS 
    WITH ROLLBACK IMMEDIATE;


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET FILESTREAM(NON_TRANSACTED_ACCESS = OFF),
                CONTAINMENT = NONE 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET AUTO_CREATE_STATISTICS ON(INCREMENTAL = OFF),
                MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT = OFF,
                DELAYED_DURABILITY = DISABLED 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET QUERY_STORE (QUERY_CAPTURE_MODE = AUTO, OPERATION_MODE = READ_WRITE, DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_PLANS_PER_QUERY = 200, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), MAX_STORAGE_SIZE_MB = 1000) 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
        ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
        ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
        ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
        ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
        ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
        ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
        ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET TEMPORAL_HISTORY_RETENTION ON 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF fulltextserviceproperty(N'IsFulltextInstalled') = 1
    EXECUTE sp_fulltext_database 'enable';


GO
PRINT N'Creando Esquema [ALMA]...';


GO
CREATE SCHEMA [ALMA]
    AUTHORIZATION [dbo];


GO
PRINT N'Creando Esquema [CONTA]...';


GO
CREATE SCHEMA [CONTA]
    AUTHORIZATION [dbo];


GO
PRINT N'Creando Esquema [NOM]...';


GO
CREATE SCHEMA [NOM]
    AUTHORIZATION [dbo];


GO
PRINT N'Creando Esquema [ORCO]...';


GO
CREATE SCHEMA [ORCO]
    AUTHORIZATION [dbo];


GO
PRINT N'Creando Esquema [PRES]...';


GO
CREATE SCHEMA [PRES]
    AUTHORIZATION [dbo];


GO
PRINT N'Creando Esquema [SIS]...';


GO
CREATE SCHEMA [SIS]
    AUTHORIZATION [dbo];


GO
PRINT N'Creando Esquema [TES]...';


GO
CREATE SCHEMA [TES]
    AUTHORIZATION [dbo];


GO
PRINT N'Creando Tipo de datos definido por el usuario [dbo].[dmoney]...';


GO
CREATE TYPE [dbo].[dmoney]
    FROM DECIMAL (20, 4) NULL;


GO
PRINT N'Creando Tabla [ALMA].[EstadoBien]...';


GO
CREATE TABLE [ALMA].[EstadoBien] (
    [PKIdEstadoBien]         INT            IDENTITY (1, 1) NOT NULL,
    [DESCRIPCION_GENERAL]    NVARCHAR (150) NOT NULL,
    [DESCRIPCION_ESPECIFICA] NVARCHAR (200) NOT NULL,
    [DESCRIPCION_CORTA]      NVARCHAR (100) NOT NULL,
    [Activo]                 BIT            NOT NULL,
    [FechaCreacion]          DATETIME       NULL,
    [UsuarioCreacion]        INT            NOT NULL,
    [FechaModificacion]      DATETIME       NULL,
    [UsuarioModificacion]    INT            NULL,
    CONSTRAINT [PK_EstadoBien] PRIMARY KEY CLUSTERED ([PKIdEstadoBien] ASC)
);


GO
PRINT N'Creando Tabla [ALMA].[EstatusArticuloConteo]...';


GO
CREATE TABLE [ALMA].[EstatusArticuloConteo] (
    [PKIdEstatusArticulo] INT            IDENTITY (1, 1) NOT NULL,
    [Nombre]              NVARCHAR (30)  NOT NULL,
    [Descripcion]         NVARCHAR (100) NULL,
    [Orden]               INT            NOT NULL,
    [Color]               NVARCHAR (8)   NULL,
    [Icono]               NVARCHAR (30)  NULL,
    [BadgeTexto]          NVARCHAR (50)  NULL,
    [Activo]              BIT            NOT NULL,
    CONSTRAINT [PK_EstatusArticuloConteo] PRIMARY KEY CLUSTERED ([PKIdEstatusArticulo] ASC),
    CONSTRAINT [UQ_EstatusArticuloConteo_Nombre] UNIQUE NONCLUSTERED ([Nombre] ASC)
);


GO
PRINT N'Creando Tabla [ALMA].[TipoPatrimonio]...';


GO
CREATE TABLE [ALMA].[TipoPatrimonio] (
    [PKIdTipoPatrimonio]  INT           IDENTITY (1, 1) NOT NULL,
    [Descripcion]         NVARCHAR (50) NOT NULL,
    [Activo]              BIT           NOT NULL,
    [FechaCreacion]       DATETIME2 (7) NULL,
    [UsuarioCreacion]     INT           NOT NULL,
    [FechaModificacion]   DATETIME2 (7) NULL,
    [UsuarioModificacion] INT           NULL,
    CONSTRAINT [PK_TipoPatrimonio] PRIMARY KEY CLUSTERED ([PKIdTipoPatrimonio] ASC)
);


GO
PRINT N'Creando Tabla [ALMA].[Material]...';


GO
CREATE TABLE [ALMA].[Material] (
    [PKIdMaterial]        INT           IDENTITY (1, 1) NOT NULL,
    [Descripcion]         NVARCHAR (50) NOT NULL,
    [Activo]              BIT           NOT NULL,
    [FechaCreacion]       DATETIME      NULL,
    [UsuarioCreacion]     INT           NOT NULL,
    [FechaModificacion]   DATETIME      NULL,
    [UsuarioModificacion] INT           NULL,
    CONSTRAINT [PK_Material] PRIMARY KEY CLUSTERED ([PKIdMaterial] ASC)
);


GO
PRINT N'Creando Tabla [ALMA].[ConteoDetalleEscaneo]...';


GO
CREATE TABLE [ALMA].[ConteoDetalleEscaneo] (
    [PKIdDetalleEscaneo]  INT            IDENTITY (1, 1) NOT NULL,
    [FKIdConteo_ALMA]     INT            NOT NULL,
    [FKIdPersona_NOM]     INT            NOT NULL,
    [CodigoBarras]        NVARCHAR (100) NOT NULL,
    [FKIdTipoBien_ALMA]   INT            NOT NULL,
    [FKIdBien_ALMA]       INT            NULL,
    [FechaEscaneo]        DATETIME       NOT NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME       NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME       NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_ConteoDetalleEscaneo] PRIMARY KEY CLUSTERED ([PKIdDetalleEscaneo] ASC)
);


GO
PRINT N'Creando Tabla [ALMA].[Unidades]...';


GO
CREATE TABLE [ALMA].[Unidades] (
    [PKIdUnidades]        INT           IDENTITY (1, 1) NOT NULL,
    [Descripcion]         NVARCHAR (50) NOT NULL,
    [Activo]              BIT           NOT NULL,
    [FechaCreacion]       DATETIME2 (7) NULL,
    [UsuarioCreacion]     INT           NOT NULL,
    [FechaModificacion]   DATETIME2 (7) NULL,
    [UsuarioModificacion] INT           NULL,
    CONSTRAINT [PK_Unidades] PRIMARY KEY CLUSTERED ([PKIdUnidades] ASC)
);


GO
PRINT N'Creando Tabla [ALMA].[TipoBien]...';


GO
CREATE TABLE [ALMA].[TipoBien] (
    [PKIdTipoBien]             INT             IDENTITY (1, 1) NOT NULL,
    [FKIdGrupoBien_ALMA]       INT             NULL,
    [FKIdNivel_ALMA]           INT             NULL,
    [FKIdPartida_CONTA]        INT             NULL,
    [FKIdCuentaContable_CONTA] INT             NULL,
    [FKIdUnidades_ALMA]        INT             NULL,
    [FKIdLocalizacion_ALMA]    INT             NULL,
    [CodigoClave]              NVARCHAR (200)  NULL,
    [Descripcion]              NVARCHAR (1200) NULL,
    [DepreciacionAnual]        DECIMAL (18, 4) NULL,
    [Consecutivo]              INT             NULL,
    [CABMS]                    NVARCHAR (50)   NULL,
    [Identificador]            NVARCHAR (50)   NULL,
    [ExistenciaMinima]         DECIMAL (18, 4) NULL,
    [ExistenciaMaxima]         DECIMAL (18, 4) NULL,
    [TiempoVida]               INT             NULL,
    [Pk_IdTratadoInt]          INT             NULL,
    [Cuota]                    NUMERIC (8, 2)  NULL,
    [ProveeduriaNac]           BIT             NULL,
    [CatalogoBasico]           BIT             NULL,
    [CUCOP_PLUS]               VARCHAR (25)    NULL,
    [Activo]                   BIT             NOT NULL,
    [FechaCreacion]            DATETIME        NULL,
    [UsuarioCreacion]          INT             NOT NULL,
    [FechaModificacion]        DATETIME        NULL,
    [UsuarioModificacion]      INT             NULL,
    [FKIdUnidades_Equivalente] INT             NULL,
    [Cantidad_Equivalente]     INT             NULL,
    CONSTRAINT [PK_TipoBien] PRIMARY KEY CLUSTERED ([PKIdTipoBien] ASC)
);


GO
PRINT N'Creando Tabla [ALMA].[EstatusPeriodo]...';


GO
CREATE TABLE [ALMA].[EstatusPeriodo] (
    [PKIdEstatusPeriodo] INT            IDENTITY (1, 1) NOT NULL,
    [Nombre]             NVARCHAR (30)  NOT NULL,
    [Descripcion]        NVARCHAR (100) NULL,
    [Activo]             BIT            NOT NULL,
    CONSTRAINT [PK_EstatusPeriodo] PRIMARY KEY CLUSTERED ([PKIdEstatusPeriodo] ASC),
    CONSTRAINT [UQ_EstatusPeriodo_Nombre] UNIQUE NONCLUSTERED ([Nombre] ASC)
);


GO
PRINT N'Creando Tabla [ALMA].[TipoConteo]...';


GO
CREATE TABLE [ALMA].[TipoConteo] (
    [PKIdTipoConteo] INT            IDENTITY (1, 1) NOT NULL,
    [Nombre]         NVARCHAR (30)  NOT NULL,
    [Descripcion]    NVARCHAR (100) NULL,
    [Activo]         BIT            NOT NULL,
    CONSTRAINT [PK_TipoConteo] PRIMARY KEY CLUSTERED ([PKIdTipoConteo] ASC)
);


GO
PRINT N'Creando Tabla [ALMA].[TipoAdquisicion]...';


GO
CREATE TABLE [ALMA].[TipoAdquisicion] (
    [PKIdTipoAdq]         INT            IDENTITY (1, 1) NOT NULL,
    [Clave]               NVARCHAR (10)  NOT NULL,
    [Descripcion]         NVARCHAR (100) NOT NULL,
    [Descripmovto]        NVARCHAR (100) NOT NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_TipoAdquisicion] PRIMARY KEY CLUSTERED ([PKIdTipoAdq] ASC)
);


GO
PRINT N'Creando Tabla [ALMA].[Conteo]...';


GO
CREATE TABLE [ALMA].[Conteo] (
    [PKIdConteo]             INT             IDENTITY (1, 1) NOT NULL,
    [FKIdTipoBien_ALMA]      INT             NOT NULL,
    [CantidadInventario]     DECIMAL (18, 2) NOT NULL,
    [Descripcion]            NVARCHAR (MAX)  NOT NULL,
    [FechaInicio]            DATETIME        NOT NULL,
    [FechaFin]               DATETIME        NULL,
    [FKIdPeriodoConteo_ALMA] INT             NULL,
    [Activo]                 BIT             NOT NULL,
    [FechaCreacion]          DATETIME        NULL,
    [UsuarioCreacion]        INT             NOT NULL,
    [FechaModificacion]      DATETIME        NULL,
    [UsuarioModificacion]    INT             NULL,
    CONSTRAINT [PK_Conteo] PRIMARY KEY CLUSTERED ([PKIdConteo] ASC)
);


GO
PRINT N'Creando Tabla [ALMA].[Familia]...';


GO
CREATE TABLE [ALMA].[Familia] (
    [PKIdFamilia]         INT           IDENTITY (1, 1) NOT NULL,
    [Descripcion]         NVARCHAR (80) NOT NULL,
    [Clave]               NVARCHAR (50) NULL,
    [Activo]              BIT           NOT NULL,
    [FechaCreacion]       DATETIME2 (7) NULL,
    [UsuarioCreacion]     INT           NOT NULL,
    [FechaModificacion]   DATETIME2 (7) NULL,
    [UsuarioModificacion] INT           NULL,
    CONSTRAINT [PK_Familia] PRIMARY KEY CLUSTERED ([PKIdFamilia] ASC)
);


GO
PRINT N'Creando Tabla [ALMA].[Bien]...';


GO
CREATE TABLE [ALMA].[Bien] (
    [PKIdBien]                    INT             IDENTITY (1, 1) NOT NULL,
    [FKIdGrupoBien_ALMA]          INT             NULL,
    [FKIdTipoBien_ALMA]           INT             NOT NULL,
    [FKIdArea_SIS]                INT             NULL,
    [FKIdProveedor_SIS]           INT             NULL,
    [FKIdEstadoBien_ALMA]         INT             NULL,
    [FKIdTipoPatrimonio_ALMA]     INT             NULL,
    [FKIdMarca_ALMA]              INT             NULL,
    [FKIdMaterial_ALMA]           INT             NULL,
    [FKIdTipoAdq_ALMA]            INT             NULL,
    [FKIdPartida_CONTA]           INT             NULL,
    [FKIdDetalleOrdenCompra_ORCO] INT             NULL,
    [Clave]                       NVARCHAR (50)   NULL,
    [ClaveAnt]                    NVARCHAR (50)   NULL,
    [Descripcion]                 NVARCHAR (1000) NULL,
    [Modelo]                      NVARCHAR (50)   NULL,
    [Serie]                       NVARCHAR (1000) NULL,
    [Requisicion]                 NVARCHAR (25)   NULL,
    [Factura]                     NVARCHAR (50)   NULL,
    [Costo]                       [dbo].[dmoney]  NULL,
    [FechaAdq]                    DATETIME        NULL,
    [Referencia]                  NVARCHAR (50)   NULL,
    [Notas]                       NVARCHAR (250)  NULL,
    [Ubicacion]                   NVARCHAR (50)   NULL,
    [AAdquisicion]                NVARCHAR (2)    NULL,
    [Frente]                      INT             NULL,
    [Fondo]                       INT             NULL,
    [Altura]                      INT             NULL,
    [Diametro]                    INT             NULL,
    [VerificacionesDias]          INT             NOT NULL,
    [MantenimientoDias]           INT             NOT NULL,
    [Mantenimiento]               BIT             NOT NULL,
    [Calibracion]                 BIT             NOT NULL,
    [Rango]                       NVARCHAR (20)   NULL,
    [Resolucion]                  NVARCHAR (20)   NULL,
    [FechaUltInv]                 DATETIME        NULL,
    [FechaReqscn]                 DATETIME        NULL,
    [Estatus]                     NVARCHAR (1)    NULL,
    [Caracteristicas]             NVARCHAR (50)   NULL,
    [Resguardo]                   INT             NULL,
    [ResguardoAnterior]           INT             NULL,
    [RelId]                       INT             NULL,
    [ValorRescate]                [dbo].[dmoney]  NULL,
    [ValorActual]                 [dbo].[dmoney]  NULL,
    [Antiguedad]                  INT             NULL,
    [Progresivo]                  INT             NULL,
    [Consecutivo]                 INT             NULL,
    [ClaveHist]                   NVARCHAR (50)   NULL,
    [EstaResguardado]             BIT             NULL,
    [FechaResguardado]            DATETIME        NULL,
    [Localizado]                  BIT             NULL,
    [esContabilizado]             BIT             NULL,
    [Activo]                      BIT             NOT NULL,
    [FechaCreacion]               DATETIME        NULL,
    [UsuarioCreacion]             INT             NOT NULL,
    [FechaModificacion]           DATETIME        NULL,
    [UsuarioModificacion]         INT             NULL,
    CONSTRAINT [PK_Bien] PRIMARY KEY CLUSTERED ([PKIdBien] ASC)
);


GO
PRINT N'Creando Tabla [ALMA].[PeriodoConteo]...';


GO
CREATE TABLE [ALMA].[PeriodoConteo] (
    [PKIdPeriodoConteo]            INT            IDENTITY (1, 1) NOT NULL,
    [FKIdSucursal_SIS]             INT            NOT NULL,
    [FKIdTipoConteo_ALMA]          INT            NOT NULL,
    [FKIdEstatus_ALMA]             INT            NOT NULL,
    [CodigoPeriodo]                NVARCHAR (20)  NOT NULL,
    [Nombre]                       NVARCHAR (100) NOT NULL,
    [Descripcion]                  NVARCHAR (500) NULL,
    [FechaInicio]                  DATE           NOT NULL,
    [FechaFin]                     DATE           NULL,
    [FechaCierre]                  DATETIME       NULL,
    [MaximoConteosPorArticulo]     INT            NOT NULL,
    [RequiereAprobacionSupervisor] BIT            NOT NULL,
    [FKIdResponsable_SIS]          INT            NULL,
    [FKIdSupervisor_SIS]           INT            NULL,
    [TotalArticulos]               INT            NULL,
    [ArticulosConcluidos]          INT            NULL,
    [ArticulosConDiferencia]       INT            NULL,
    [Activo]                       BIT            NOT NULL,
    [FechaCreacion]                DATETIME       NULL,
    [UsuarioCreacion]              INT            NOT NULL,
    [FechaModificacion]            DATETIME       NULL,
    [UsuarioModificacion]          INT            NULL,
    CONSTRAINT [PK_PeriodoConteo] PRIMARY KEY CLUSTERED ([PKIdPeriodoConteo] ASC),
    CONSTRAINT [UQ_PeriodoConteo_Codigo] UNIQUE NONCLUSTERED ([FKIdSucursal_SIS] ASC, [CodigoPeriodo] ASC)
);


GO
PRINT N'Creando Tabla [ALMA].[GrupoBien]...';


GO
CREATE TABLE [ALMA].[GrupoBien] (
    [PKIdGrupoBien]       INT            IDENTITY (1, 1) NOT NULL,
    [FKIdFamilia_ALMA]    INT            NOT NULL,
    [Descripcion]         NVARCHAR (800) NULL,
    [Clave]               INT            NULL,
    [ClaveAN]             NVARCHAR (50)  NULL,
    [CABM_ACT]            NVARCHAR (50)  NULL,
    [CLAVE_CUCOP]         NVARCHAR (50)  NULL,
    [MEDIDA]              NVARCHAR (50)  NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_GrupoBien] PRIMARY KEY CLUSTERED ([PKIdGrupoBien] ASC)
);


GO
PRINT N'Creando Tabla [ALMA].[EstatusSolicitud]...';


GO
CREATE TABLE [ALMA].[EstatusSolicitud] (
    [PKIdEstatusSolicitud] INT            IDENTITY (1, 1) NOT NULL,
    [Descripcion]          NVARCHAR (150) NOT NULL,
    [Color]                NVARCHAR (8)   NULL,
    [Activo]               BIT            NOT NULL,
    [FechaCreacion]        DATETIME2 (7)  NULL,
    [UsuarioCreacion]      INT            NOT NULL,
    [FechaModificacion]    DATETIME2 (7)  NULL,
    [UsuarioModificacion]  INT            NULL,
    CONSTRAINT [PK_EstatusSolicitud] PRIMARY KEY CLUSTERED ([PKIdEstatusSolicitud] ASC)
);


GO
PRINT N'Creando Tabla [ALMA].[ConteoHist]...';


GO
CREATE TABLE [ALMA].[ConteoHist] (
    [PKIdConteoHist]      INT             IDENTITY (1, 1) NOT NULL,
    [PKIdConteo]          INT             NOT NULL,
    [FKIdTipoBien_ALMA]   INT             NOT NULL,
    [CantidadInventario]  DECIMAL (18, 2) NOT NULL,
    [Descripcion]         NVARCHAR (MAX)  NOT NULL,
    [FechaInicio]         DATETIME        NOT NULL,
    [FechaFin]            DATETIME        NULL,
    [PrimerConteo]        DECIMAL (18, 2) NOT NULL,
    [SegundoConteo]       DECIMAL (18, 2) NOT NULL,
    [TercerConteo]        DECIMAL (18, 2) NOT NULL,
    [Diferencias]         NVARCHAR (MAX)  NOT NULL,
    [Nivel]               INT             NOT NULL,
    [Activo]              BIT             NOT NULL,
    [FechaCreacion]       DATETIME        NULL,
    [UsuarioCreacion]     INT             NOT NULL,
    [FechaModificacion]   DATETIME        NULL,
    [UsuarioModificacion] INT             NULL,
    CONSTRAINT [PK_ConteoHist] PRIMARY KEY CLUSTERED ([PKIdConteoHist] ASC)
);


GO
PRINT N'Creando Tabla [ALMA].[Marca]...';


GO
CREATE TABLE [ALMA].[Marca] (
    [PKIdMarca]           INT           IDENTITY (1, 1) NOT NULL,
    [Descripcion]         NVARCHAR (50) NOT NULL,
    [Activo]              BIT           NOT NULL,
    [FechaCreacion]       DATETIME2 (7) NULL,
    [UsuarioCreacion]     INT           NOT NULL,
    [FechaModificacion]   DATETIME2 (7) NULL,
    [UsuarioModificacion] INT           NULL,
    CONSTRAINT [PK_Marca] PRIMARY KEY CLUSTERED ([PKIdMarca] ASC)
);


GO
PRINT N'Creando Tabla [ALMA].[Nivel]...';


GO
CREATE TABLE [ALMA].[Nivel] (
    [PKIdNivel]           INT           IDENTITY (1, 1) NOT NULL,
    [Nivel]               INT           NOT NULL,
    [Descripcion]         NVARCHAR (20) NOT NULL,
    [Activo]              BIT           NOT NULL,
    [FechaCreacion]       DATETIME      NULL,
    [UsuarioCreacion]     INT           NOT NULL,
    [FechaModificacion]   DATETIME      NULL,
    [UsuarioModificacion] INT           NULL,
    CONSTRAINT [PK_Nivel] PRIMARY KEY CLUSTERED ([PKIdNivel] ASC)
);


GO
PRINT N'Creando Tabla [ALMA].[ConteoDetalle]...';


GO
CREATE TABLE [ALMA].[ConteoDetalle] (
    [PKIdDetalleConteo]     INT             IDENTITY (1, 1) NOT NULL,
    [FKIdConteo_ALMA]       INT             NOT NULL,
    [FKIdNumeroConteo_ALMA] INT             NOT NULL,
    [FKIdPersona_NOM]       INT             NOT NULL,
    [Cantidad]              DECIMAL (18, 2) NOT NULL,
    [Fecha]                 DATETIME        NOT NULL,
    [Activo]                BIT             NOT NULL,
    [FechaCreacion]         DATETIME        NULL,
    [UsuarioCreacion]       INT             NOT NULL,
    [FechaModificacion]     DATETIME        NULL,
    [UsuarioModificacion]   INT             NULL,
    CONSTRAINT [PK_ConteoDetalle] PRIMARY KEY CLUSTERED ([PKIdDetalleConteo] ASC)
);


GO
PRINT N'Creando Tabla [ALMA].[MotivoES]...';


GO
CREATE TABLE [ALMA].[MotivoES] (
    [PKIdMotivoES]        INT           IDENTITY (1, 1) NOT NULL,
    [Descripcion]         NVARCHAR (50) NOT NULL,
    [AplicaEntrada]       BIT           NOT NULL,
    [AplicaSalida]        BIT           NOT NULL,
    [Activo]              BIT           NOT NULL,
    [FechaCreacion]       DATETIME2 (7) NULL,
    [UsuarioCreacion]     INT           NOT NULL,
    [FechaModificacion]   DATETIME2 (7) NULL,
    [UsuarioModificacion] INT           NULL,
    CONSTRAINT [PK_MotivoES] PRIMARY KEY CLUSTERED ([PKIdMotivoES] ASC)
);


GO
PRINT N'Creando Tabla [CONTA].[Concepto]...';


GO
CREATE TABLE [CONTA].[Concepto] (
    [PKIdConcepto]        INT            IDENTITY (1, 1) NOT NULL,
    [FKIdCapitulo_CONTA]  INT            NOT NULL,
    [Clave]               NVARCHAR (30)  NULL,
    [Descripcion]         NVARCHAR (120) NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME       NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME       NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_Concepto] PRIMARY KEY CLUSTERED ([PKIdConcepto] ASC)
);


GO
PRINT N'Creando Tabla [CONTA].[MatrizIngreso]...';


GO
CREATE TABLE [CONTA].[MatrizIngreso] (
    [Pk_IdMatrizIngreso]            INT           IDENTITY (1, 1) NOT NULL,
    [Fk_IdPrograma]                 INT           NULL,
    [Fk_IdOrigen]                   INT           NULL,
    [Fk_IdCuentaContableAutorizado] INT           NULL,
    [Fk_IdCuentaContablePorEjercer] INT           NULL,
    [Fk_IdCuentaContableModificado] INT           NULL,
    [Fk_IdCuentaContableDevengado]  INT           NULL,
    [Fk_IdCuentaContableRecaudado]  INT           NULL,
    [Fk_IdCuentaContableDeposito]   INT           NULL,
    [FK_IdAnio__SIS]                INT           NULL,
    [Activo]                        BIT           NOT NULL,
    [FechaCreacion]                 DATETIME2 (7) NULL,
    [UsuarioCreacion]               INT           NOT NULL,
    [FechaModificacion]             DATETIME2 (7) NULL,
    [UsuarioModificacion]           INT           NULL,
    CONSTRAINT [PK_MatrizIngreso] PRIMARY KEY CLUSTERED ([Pk_IdMatrizIngreso] ASC)
);


GO
PRINT N'Creando Tabla [CONTA].[Poliza]...';


GO
CREATE TABLE [CONTA].[Poliza] (
    [PKIdPoliza]              INT             IDENTITY (1, 1) NOT NULL,
    [FKIdAnio_SIS]            INT             NOT NULL,
    [FKIdMes_SIS]             INT             NOT NULL,
    [FKIdTipoPoliza_SIS]      INT             NOT NULL,
    [ClavePoliza]             NVARCHAR (10)   NOT NULL,
    [NombrePoliza]            NVARCHAR (1000) NOT NULL,
    [FechaPoliza]             DATETIME        NOT NULL,
    [EstaBalanceado]          BIT             NOT NULL,
    [Activo]                  BIT             NOT NULL,
    [FechaCreacion]           DATETIME2 (7)   NULL,
    [UsuarioCreacion]         INT             NOT NULL,
    [FechaModificacion]       DATETIME2 (7)   NULL,
    [UsuarioModificacion]     INT             NULL,
    [PermitirModificar]       BIT             NULL,
    [FKIdAccionAutorizar_SIS] INT             NULL,
    [Autorizado]              BIT             NULL,
    [FechaSolicitud]          DATETIME        NULL,
    [FechaAutorizacion]       DATETIME        NULL,
    CONSTRAINT [PK_Poliza] PRIMARY KEY CLUSTERED ([PKIdPoliza] ASC)
);


GO
PRINT N'Creando Tabla [CONTA].[MatrizConversion]...';


GO
CREATE TABLE [CONTA].[MatrizConversion] (
    [PKIdMatrizConversion]           INT           IDENTITY (1, 1) NOT NULL,
    [FKIdAnio_SIS]                   INT           NOT NULL,
    [FKIdPrograma_PRES]              INT           NOT NULL,
    [FKIdPartida_SIS]                INT           NOT NULL,
    [FKIdCuentaContableAprobado]     INT           NOT NULL,
    [FKIdCuentaContablePorEjercer]   INT           NOT NULL,
    [FKIdCuentaContableModificado]   INT           NOT NULL,
    [FKIdCuentaContableComprometido] INT           NOT NULL,
    [FKIdCuentaContableDevengado]    INT           NOT NULL,
    [FKIdCuentaContableEjercido]     INT           NOT NULL,
    [FKIdCuentaContablePagado]       INT           NOT NULL,
    [FKIdCuentaContableGasto]        INT           NOT NULL,
    [Activo]                         BIT           NOT NULL,
    [FechaCreacion]                  DATETIME2 (7) NULL,
    [UsuarioCreacion]                INT           NOT NULL,
    [FechaModificacion]              DATETIME2 (7) NULL,
    [UsuarioModificacion]            INT           NULL,
    CONSTRAINT [PK_MatrizConversion] PRIMARY KEY CLUSTERED ([PKIdMatrizConversion] ASC)
);


GO
PRINT N'Creando Tabla [CONTA].[Capitulo]...';


GO
CREATE TABLE [CONTA].[Capitulo] (
    [PKIdCapitulo]        INT            IDENTITY (1, 1) NOT NULL,
    [Clave]               NVARCHAR (30)  NULL,
    [Descripcion]         NVARCHAR (120) NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME       NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME       NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_Capitulo] PRIMARY KEY CLUSTERED ([PKIdCapitulo] ASC)
);


GO
PRINT N'Creando Tabla [CONTA].[PolizaDetalle]...';


GO
CREATE TABLE [CONTA].[PolizaDetalle] (
    [PKIdPolizaDetalle]         INT            IDENTITY (1, 1) NOT NULL,
    [FKIdCuentaContable_CONTA]  INT            NOT NULL,
    [FKIdPoliza_CONTA]          INT            NOT NULL,
    [Descripcion]               NVARCHAR (600) NULL,
    [ImporteDebe]               [dbo].[dmoney] NULL,
    [ImporteHaber]              [dbo].[dmoney] NULL,
    [FKIdReferencia]            INT            NULL,
    [FKIdTipoDetallePoliza_SIS] INT            NULL,
    [Activo]                    BIT            NOT NULL,
    [FechaCreacion]             DATETIME2 (7)  NULL,
    [UsuarioCreacion]           INT            NOT NULL,
    [FechaModificacion]         DATETIME2 (7)  NULL,
    [UsuarioModificacion]       INT            NULL,
    CONSTRAINT [PK_PolizaDetalle] PRIMARY KEY CLUSTERED ([PKIdPolizaDetalle] ASC)
);


GO
PRINT N'Creando Tabla [CONTA].[ConsecutivoPoliza]...';


GO
CREATE TABLE [CONTA].[ConsecutivoPoliza] (
    [PKIdConsecutivoPoliza] INT           IDENTITY (1, 1) NOT NULL,
    [FK_IdAnio__SIS]        INT           NOT NULL,
    [FK_IdMes__SIS]         INT           NOT NULL,
    [FK_IdTipoPoliza__SIS]  INT           NOT NULL,
    [UltimoValor]           INT           NOT NULL,
    [Activo]                BIT           NOT NULL,
    [FechaCreacion]         DATETIME2 (7) NULL,
    [UsuarioCreacion]       INT           NOT NULL,
    [FechaModificacion]     DATETIME2 (7) NULL,
    [UsuarioModificacion]   INT           NULL,
    CONSTRAINT [PK_ConsecutivoPoliza] PRIMARY KEY CLUSTERED ([PKIdConsecutivoPoliza] ASC),
    CONSTRAINT [UQ_ConsecutivoPoliza] UNIQUE NONCLUSTERED ([FK_IdAnio__SIS] ASC, [FK_IdMes__SIS] ASC, [FK_IdTipoPoliza__SIS] ASC)
);


GO
PRINT N'Creando Tabla [CONTA].[TipoCuenta]...';


GO
CREATE TABLE [CONTA].[TipoCuenta] (
    [PKIdTipoCuenta]      INT           IDENTITY (1, 1) NOT NULL,
    [Color]               NVARCHAR (5)  NOT NULL,
    [Descripcion]         NVARCHAR (25) NOT NULL,
    [Activo]              BIT           NOT NULL,
    [FechaCreacion]       DATETIME      NULL,
    [UsuarioCreacion]     INT           NOT NULL,
    [FechaModificacion]   DATETIME      NULL,
    [UsuarioModificacion] INT           NULL,
    CONSTRAINT [PK_TipoCuenta] PRIMARY KEY CLUSTERED ([PKIdTipoCuenta] ASC)
);


GO
PRINT N'Creando Tabla [CONTA].[CuentaContable]...';


GO
CREATE TABLE [CONTA].[CuentaContable] (
    [PKIdCuentaContable]   INT             IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]      INT             NOT NULL,
    [FKIdTipoCuenta_CONTA] INT             NOT NULL,
    [Cuenta]               NVARCHAR (5)    NOT NULL,
    [SubCuenta]            NVARCHAR (5)    NOT NULL,
    [SubSubCuenta]         NVARCHAR (5)    NOT NULL,
    [SubSubSubCuenta]      NVARCHAR (5)    NOT NULL,
    [SubSubSubSubCuenta]   NVARCHAR (5)    NOT NULL,
    [Saldo]                NUMERIC (18, 2) NOT NULL,
    [Descripcion]          VARCHAR (250)   NULL,
    [Activo]               BIT             NOT NULL,
    [FechaCreacion]        DATETIME        NULL,
    [UsuarioCreacion]      INT             NOT NULL,
    [FechaModificacion]    DATETIME        NULL,
    [UsuarioModificacion]  INT             NULL,
    [S5]                   NVARCHAR (5)    NULL,
    [S6]                   NVARCHAR (5)    NULL,
    [S7]                   NVARCHAR (5)    NULL,
    [ClaveOrd]             VARCHAR (50)    NULL,
    [Padre]                VARCHAR (10)    NULL,
    [Hijo]                 VARCHAR (20)    NULL,
    [NivelCuenta]          INT             NULL,
    [Cta_Coi]              NVARCHAR (20)   NULL,
    [Desc_Coi]             NVARCHAR (160)  NULL,
    [TipoCuenta]           NCHAR (1)       NULL,
    [S8]                   NVARCHAR (5)    NULL,
    [S9]                   NVARCHAR (5)    NULL,
    [S10]                  NVARCHAR (5)    NULL,
    [IsCuentaDetalle]      AS              (CASE WHEN [TipoCuenta] = 'D' THEN (1) ELSE (0) END),
    CONSTRAINT [PK_CuentaContable] PRIMARY KEY CLUSTERED ([PKIdCuentaContable] ASC)
);


GO
PRINT N'Creando Tabla [CONTA].[Partida]...';


GO
CREATE TABLE [CONTA].[Partida] (
    [PKIdPartida]         INT            IDENTITY (1, 1) NOT NULL,
    [FKIdConcepto_SIS]    INT            NULL,
    [Clave]               NVARCHAR (10)  NOT NULL,
    [Descripcion]         NVARCHAR (255) NOT NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME       NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME       NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_Partida] PRIMARY KEY CLUSTERED ([PKIdPartida] ASC)
);


GO
PRINT N'Creando Tabla [CONTA].[TipoDoctoPago]...';


GO
CREATE TABLE [CONTA].[TipoDoctoPago] (
    [PKIdTipoDoctoPago]   INT           IDENTITY (1, 1) NOT NULL,
    [Descripcion]         NVARCHAR (50) NOT NULL,
    [Activo]              BIT           NOT NULL,
    [FechaCreacion]       DATETIME2 (7) NULL,
    [UsuarioCreacion]     INT           NOT NULL,
    [FechaModificacion]   DATETIME2 (7) NULL,
    [UsuarioModificacion] INT           NULL,
    CONSTRAINT [PK_TipoDoctoPago] PRIMARY KEY CLUSTERED ([PKIdTipoDoctoPago] ASC)
);


GO
PRINT N'Creando Tabla [NOM].[Persona]...';


GO
CREATE TABLE [NOM].[Persona] (
    [PKIdPersona]              INT            IDENTITY (1, 1) NOT NULL,
    [Clave]                    NVARCHAR (15)  NOT NULL,
    [Iniciales]                NVARCHAR (3)   NULL,
    [Nombre]                   NVARCHAR (50)  NOT NULL,
    [Paterno]                  NVARCHAR (50)  NOT NULL,
    [Materno]                  NVARCHAR (50)  NOT NULL,
    [Sexo]                     NVARCHAR (10)  NULL,
    [FechaNacimiento]          DATETIME       NOT NULL,
    [ESTADO_CIVIL]             NVARCHAR (20)  NULL,
    [RFC]                      NVARCHAR (15)  NOT NULL,
    [Curp]                     NVARCHAR (18)  NOT NULL,
    [REG_IMSS]                 NVARCHAR (12)  NULL,
    [NoCartilla]               NVARCHAR (16)  NULL,
    [NoLicencia]               NVARCHAR (16)  NULL,
    [NoPasaporte]              NVARCHAR (16)  NULL,
    [NoCredencialElector]      NVARCHAR (32)  NULL,
    [Gafete]                   NVARCHAR (11)  NULL,
    [CORREO_ELECTRONICO]       NVARCHAR (250) NULL,
    [Telefono_particular]      NVARCHAR (15)  NULL,
    [Telefono_movil]           NVARCHAR (15)  NULL,
    [Calle]                    NVARCHAR (40)  NULL,
    [Num_exterior]             NVARCHAR (10)  NULL,
    [Num_interior]             NVARCHAR (10)  NULL,
    [Colonia]                  NVARCHAR (40)  NULL,
    [CP]                       NVARCHAR (6)   NULL,
    [Municipio]                NVARCHAR (20)  NULL,
    [Estado]                   NVARCHAR (30)  NULL,
    [Fecha_de_Inicio]          DATETIME       NOT NULL,
    [Fecha_Fin]                DATETIME       NULL,
    [TIPO_CONTRATACION]        NVARCHAR (50)  NULL,
    [PUESTO]                   NVARCHAR (100) NULL,
    [SUELDO_BASE]              FLOAT (53)     NULL,
    [COMPENSACION_GARANTIZADA] FLOAT (53)     NULL,
    [BANCO]                    NVARCHAR (100) NULL,
    [NUMERO_CUENTA]            NVARCHAR (25)  NULL,
    [CLABE]                    NVARCHAR (50)  NULL,
    [Activo]                   BIT            NOT NULL,
    [FechaCreacion]            DATETIME2 (7)  NULL,
    [UsuarioCreacion]          INT            NOT NULL,
    [FechaModificacion]        DATETIME2 (7)  NULL,
    [UsuarioModificacion]      INT            NULL,
    CONSTRAINT [PK_Persona] PRIMARY KEY CLUSTERED ([PKIdPersona] ASC)
);


GO
PRINT N'Creando Tabla [NOM].[PersonaArea]...';


GO
CREATE TABLE [NOM].[PersonaArea] (
    [PKIdPersonaArea]     INT      IDENTITY (1, 1) NOT NULL,
    [FKIdPersona_NOM]     INT      NOT NULL,
    [FKIdArea_SIS]        INT      NOT NULL,
    [IsAdscrito]          BIT      NOT NULL,
    [EsSolicitante]       BIT      NULL,
    [EsAutorizador]       BIT      NULL,
    [Activo]              BIT      NOT NULL,
    [FechaCreacion]       DATETIME NULL,
    [UsuarioCreacion]     INT      NOT NULL,
    [FechaModificacion]   DATETIME NULL,
    [UsuarioModificacion] INT      NULL,
    CONSTRAINT [PK_PersonaArea] PRIMARY KEY CLUSTERED ([PKIdPersonaArea] ASC)
);


GO
PRINT N'Creando Tabla [ORCO].[Articulo]...';


GO
CREATE TABLE [ORCO].[Articulo] (
    [PKIdArticulo]        INT            IDENTITY (1, 1) NOT NULL,
    [Clave]               NVARCHAR (20)  NOT NULL,
    [Descripcion]         NVARCHAR (250) NOT NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_Articulo] PRIMARY KEY CLUSTERED ([PKIdArticulo] ASC)
);


GO
PRINT N'Creando Tabla [ORCO].[RequisicionPartida]...';


GO
CREATE TABLE [ORCO].[RequisicionPartida] (
    [PKIdRequisicionPartida] INT            IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]        INT            NOT NULL,
    [FKIdRequisicion_ORCO]   INT            NOT NULL,
    [FKIdPartida_CONTA]      INT            NOT NULL,
    [Monto]                  [dbo].[dmoney] NULL,
    [Observaciones]          NVARCHAR (500) NULL,
    [Activo]                 BIT            NOT NULL,
    [FechaCreacion]          DATETIME2 (7)  NULL,
    [UsuarioCreacion]        INT            NOT NULL,
    [FechaModificacion]      DATETIME2 (7)  NULL,
    [UsuarioModificacion]    INT            NULL,
    CONSTRAINT [PK_RequisicionPartida] PRIMARY KEY CLUSTERED ([PKIdRequisicionPartida] ASC)
);


GO
PRINT N'Creando Tabla [ORCO].[PAAASPartida]...';


GO
CREATE TABLE [ORCO].[PAAASPartida] (
    [PKIdPAAASPartida]    INT             IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]     INT             NOT NULL,
    [FKIdPAAAS_ORCO]      INT             NOT NULL,
    [FKIdPartida_CONTA]   INT             NOT NULL,
    [Observaciones]       NVARCHAR (1000) NULL,
    [Activo]              BIT             NOT NULL,
    [FechaCreacion]       DATETIME2 (7)   NULL,
    [UsuarioCreacion]     INT             NOT NULL,
    [FechaModificacion]   DATETIME2 (7)   NULL,
    [UsuarioModificacion] INT             NULL,
    CONSTRAINT [PK_PAAASPartida] PRIMARY KEY CLUSTERED ([PKIdPAAASPartida] ASC)
);


GO
PRINT N'Creando Tabla [ORCO].[TipoContrato]...';


GO
CREATE TABLE [ORCO].[TipoContrato] (
    [PKIdTipoContrato]    INT           IDENTITY (1, 1) NOT NULL,
    [Descripcion]         NVARCHAR (25) NOT NULL,
    [Activo]              BIT           NOT NULL,
    [FechaCreacion]       DATETIME2 (7) NULL,
    [UsuarioCreacion]     INT           NOT NULL,
    [FechaModificacion]   DATETIME2 (7) NULL,
    [UsuarioModificacion] INT           NULL,
    CONSTRAINT [PK_TipoContrato] PRIMARY KEY CLUSTERED ([PKIdTipoContrato] ASC)
);


GO
PRINT N'Creando Tabla [ORCO].[EstudioMercadoDetalleCosto]...';


GO
CREATE TABLE [ORCO].[EstudioMercadoDetalleCosto] (
    [PKIdEstudioMercadoDetalleCosto] INT            IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]                INT            NOT NULL,
    [FKIdSolicitudCotizacion_ORCO]   INT            NOT NULL,
    [FKIdEstudioMercadoDetalle_ORCO] INT            NOT NULL,
    [PrecioUnitario]                 [dbo].[dmoney] NULL,
    [TiempoEntregaDias]              INT            NULL,
    [Condiciones]                    NVARCHAR (500) NULL,
    [FechaRespuesta]                 DATETIME       NULL,
    [Activo]                         BIT            NOT NULL,
    [FechaCreacion]                  DATETIME2 (7)  NULL,
    [UsuarioCreacion]                INT            NOT NULL,
    [FechaModificacion]              DATETIME2 (7)  NULL,
    [UsuarioModificacion]            INT            NULL,
    CONSTRAINT [PK_EstudioMercadoDetalleCosto] PRIMARY KEY CLUSTERED ([PKIdEstudioMercadoDetalleCosto] ASC)
);


GO
PRINT N'Creando Tabla [ORCO].[Requisicion]...';


GO
CREATE TABLE [ORCO].[Requisicion] (
    [PKIdRequisicion]               INT             IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]               INT             NOT NULL,
    [FKIdPersona_NOM]               INT             NOT NULL,
    [FKIdArea_SIS]                  INT             NOT NULL,
    [Descripcion]                   NVARCHAR (100)  NOT NULL,
    [Observaciones]                 NVARCHAR (1000) NULL,
    [FechaRequisicion]              DATETIME        NOT NULL,
    [Servicio]                      BIT             NOT NULL,
    [FL_FOTO]                       NVARCHAR (1000) NULL,
    [FKIdProyecto_ORCO]             INT             NULL,
    [FechaRequiereInicio]           DATETIME        NULL,
    [FechaRequiereFin]              DATETIME        NULL,
    [FKIdPrograma_PRES]             INT             NULL,
    [Importe]                       [dbo].[dmoney]  NULL,
    [FKIdJefeAlmacen_NOM]           INT             NULL,
    [FKIdSuficiencia_PRES]          INT             NULL,
    [FKIdSuperviso_NOM]             INT             NULL,
    [FKIdAutorizo_NOM]              INT             NULL,
    [FKIdPSolicita_NOM]             INT             NULL,
    [FKIdPJefeAlmacen_NOM]          INT             NULL,
    [FKIdPSuficiencia_NOM]          INT             NULL,
    [FKIdPSuperviso_NOM]            INT             NULL,
    [FKIdPAutorizo_NOM]             INT             NULL,
    [FKIdFuenteFinanciamiento_PRES] INT             NULL,
    [FKIdAnio_SIS]                  INT             NULL,
    [FKIdTipoGasto_PRES]            INT             NULL,
    [FKIdDigitoIdentificador_PRES]  INT             NULL,
    [FKIdDestinoGasto_PRES]         INT             NULL,
    [FKIdEgresoAutorizado_PRES]     INT             NULL,
    [Oficio]                        VARCHAR (120)   NULL,
    [FechaOficio]                   DATETIME        NULL,
    [CompraDirecta]                 BIT             NULL,
    [Activo]                        BIT             NOT NULL,
    [FechaCreacion]                 DATETIME2 (7)   NULL,
    [UsuarioCreacion]               INT             NOT NULL,
    [FechaModificacion]             DATETIME2 (7)   NULL,
    [UsuarioModificacion]           INT             NULL,
    CONSTRAINT [PK_Requisicion] PRIMARY KEY CLUSTERED ([PKIdRequisicion] ASC)
);


GO
PRINT N'Creando Tabla [ORCO].[PAAAS]...';


GO
CREATE TABLE [ORCO].[PAAAS] (
    [PKIdPAAAS]                     INT             IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]               INT             NOT NULL,
    [FKIdAnio_SIS]                  INT             NOT NULL,
    [FKIdArea_SIS]                  INT             NOT NULL,
    [FKIdPersona_NOM]               INT             NOT NULL,
    [Descripcion]                   NVARCHAR (100)  NOT NULL,
    [Observaciones]                 NVARCHAR (1000) NULL,
    [Fecha]                         DATETIME        NOT NULL,
    [FKIdProyecto_ORCO]             INT             NULL,
    [FKIdPrograma_PRES]             INT             NULL,
    [FKIdFuenteFinanciamiento_PRES] INT             NULL,
    [Activo]                        BIT             NOT NULL,
    [FechaCreacion]                 DATETIME2 (7)   NULL,
    [UsuarioCreacion]               INT             NOT NULL,
    [FechaModificacion]             DATETIME2 (7)   NULL,
    [UsuarioModificacion]           INT             NULL,
    CONSTRAINT [PK_PAAAS] PRIMARY KEY CLUSTERED ([PKIdPAAAS] ASC),
    CONSTRAINT [UQ_PAAAS_Area_Anio] UNIQUE NONCLUSTERED ([FKIdArea_SIS] ASC, [FKIdAnio_SIS] ASC)
);


GO
PRINT N'Creando Tabla [ORCO].[RequisicionDetalle]...';


GO
CREATE TABLE [ORCO].[RequisicionDetalle] (
    [PKIdRequisicionDetalle] INT            IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]        INT            NOT NULL,
    [FKIdRequisicion_ORCO]   INT            NOT NULL,
    [FKIdTipoBien_ALMA]      INT            NOT NULL,
    [FKIdUnidades_ALMA]      INT            NULL,
    [Cantidad]               NUMERIC (8, 2) NOT NULL,
    [Observaciones]          NVARCHAR (MAX) NOT NULL,
    [Activo]                 BIT            NOT NULL,
    [FechaCreacion]          DATETIME2 (7)  NULL,
    [UsuarioCreacion]        INT            NOT NULL,
    [FechaModificacion]      DATETIME2 (7)  NULL,
    [UsuarioModificacion]    INT            NULL,
    CONSTRAINT [PK_RequisicionDetalle] PRIMARY KEY CLUSTERED ([PKIdRequisicionDetalle] ASC)
);


GO
PRINT N'Creando Tabla [ORCO].[Cotizacion]...';


GO
CREATE TABLE [ORCO].[Cotizacion] (
    [PKIdCotizacion]              INT             IDENTITY (1, 1) NOT NULL,
    [FKIdRequisicion_ORCO]        INT             NOT NULL,
    [FKIdProveedor_SIS]           INT             NOT NULL,
    [FechaSolicitud]              DATETIME        NOT NULL,
    [FechaProveedorCotiza]        DATETIME        NULL,
    [FechaProveedorCompromiso]    DATETIME        NULL,
    [Comentarios]                 NVARCHAR (MAX)  NULL,
    [Servicio]                    BIT             NOT NULL,
    [FL_Documento]                NVARCHAR (1000) NULL,
    [Entrega]                     NVARCHAR (MAX)  NULL,
    [Vigencia]                    NVARCHAR (MAX)  NULL,
    [Condiciones]                 NVARCHAR (200)  NULL,
    [FKIdAnio_SIS]                INT             NULL,
    [FKIdContenedorCot_ORCO]      INT             NULL,
    [FKIdContenedorMultiCot_ORCO] INT             NULL,
    [Activo]                      BIT             NOT NULL,
    [FechaCreacion]               DATETIME2 (7)   NOT NULL,
    [UsuarioCreacion]             INT             NOT NULL,
    [FechaModificacion]           DATETIME2 (7)   NULL,
    [UsuarioModificacion]         INT             NULL,
    CONSTRAINT [PK_Cotizacion] PRIMARY KEY CLUSTERED ([PKIdCotizacion] ASC)
);


GO
PRINT N'Creando Índice [ORCO].[Cotizacion].[IX_Cotizacion_Proveedor]...';


GO
CREATE NONCLUSTERED INDEX [IX_Cotizacion_Proveedor]
    ON [ORCO].[Cotizacion]([FKIdProveedor_SIS] ASC);


GO
PRINT N'Creando Índice [ORCO].[Cotizacion].[IX_Cotizacion_Requisicion]...';


GO
CREATE NONCLUSTERED INDEX [IX_Cotizacion_Requisicion]
    ON [ORCO].[Cotizacion]([FKIdRequisicion_ORCO] ASC);


GO
PRINT N'Creando Tabla [ORCO].[EstudioMercado]...';


GO
CREATE TABLE [ORCO].[EstudioMercado] (
    [PKIdEstudioMercado]  INT            IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]     INT            NOT NULL,
    [FKIdAnio_SIS]        INT            NOT NULL,
    [Nombre]              VARCHAR (80)   NOT NULL,
    [Descripcion]         NVARCHAR (500) NULL,
    [FechaSolicitud]      DATETIME       NOT NULL,
    [FechaCierre]         DATETIME       NULL,
    [FKIdResponsable_NOM] INT            NOT NULL,
    [Estatus]             INT            NOT NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_EstudioMercado] PRIMARY KEY CLUSTERED ([PKIdEstudioMercado] ASC)
);


GO
PRINT N'Creando Tabla [ORCO].[ProcedimientoContratacion]...';


GO
CREATE TABLE [ORCO].[ProcedimientoContratacion] (
    [PKIdProcedimientoContratacion] INT           IDENTITY (1, 1) NOT NULL,
    [Descripcion]                   NVARCHAR (50) NOT NULL,
    [FundamentoJuridico]            TEXT          NOT NULL,
    [Activo]                        BIT           NOT NULL,
    [FechaCreacion]                 DATETIME2 (7) NULL,
    [UsuarioCreacion]               INT           NOT NULL,
    [FechaModificacion]             DATETIME2 (7) NULL,
    [UsuarioModificacion]           INT           NULL,
    CONSTRAINT [PK_ProcedimientoContratacion] PRIMARY KEY CLUSTERED ([PKIdProcedimientoContratacion] ASC)
);


GO
PRINT N'Creando Tabla [ORCO].[TipoGarantia]...';


GO
CREATE TABLE [ORCO].[TipoGarantia] (
    [PKIdTipoGarantia]    INT           IDENTITY (1, 1) NOT NULL,
    [Descripcion]         NVARCHAR (25) NOT NULL,
    [Activo]              BIT           NOT NULL,
    [FechaCreacion]       DATETIME2 (7) NULL,
    [UsuarioCreacion]     INT           NOT NULL,
    [FechaModificacion]   DATETIME2 (7) NULL,
    [UsuarioModificacion] INT           NULL,
    CONSTRAINT [PK_TipoGarantia] PRIMARY KEY CLUSTERED ([PKIdTipoGarantia] ASC)
);


GO
PRINT N'Creando Tabla [ORCO].[SolicitudCotizacion]...';


GO
CREATE TABLE [ORCO].[SolicitudCotizacion] (
    [PKIdSolicitudCotizacion] INT             IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]         INT             NOT NULL,
    [FKIdEstudioMercado_ORCO] INT             NOT NULL,
    [FKIdProveedor_SIS]       INT             NOT NULL,
    [FechaSolicitud]          DATETIME        NOT NULL,
    [FechaCompromisoEntrega]  DATETIME        NULL,
    [Comentarios]             TEXT            NULL,
    [FL_Documento]            NVARCHAR (1000) NULL,
    [Estatus]                 INT             NOT NULL,
    [Activo]                  BIT             NOT NULL,
    [FechaCreacion]           DATETIME2 (7)   NULL,
    [UsuarioCreacion]         INT             NOT NULL,
    [FechaModificacion]       DATETIME2 (7)   NULL,
    [UsuarioModificacion]     INT             NULL,
    CONSTRAINT [PK_SolicitudCotizacion] PRIMARY KEY CLUSTERED ([PKIdSolicitudCotizacion] ASC)
);


GO
PRINT N'Creando Tabla [ORCO].[CotizacionDetalle]...';


GO
CREATE TABLE [ORCO].[CotizacionDetalle] (
    [PKIdCotizacionDetalle]       INT            IDENTITY (1, 1) NOT NULL,
    [FKIdCotizacion_ORCO]         INT            NOT NULL,
    [FKIdRequisicionDetalle_ORCO] INT            NOT NULL,
    [PrecioUnitario]              [dbo].[dmoney] NULL,
    [Activo]                      BIT            NOT NULL,
    [FechaCreacion]               DATETIME2 (7)  NOT NULL,
    [UsuarioCreacion]             INT            NOT NULL,
    [FechaModificacion]           DATETIME2 (7)  NULL,
    [UsuarioModificacion]         INT            NULL,
    CONSTRAINT [PK_CotizacionDetalle] PRIMARY KEY CLUSTERED ([PKIdCotizacionDetalle] ASC)
);


GO
PRINT N'Creando Índice [ORCO].[CotizacionDetalle].[IX_CotizacionDetalle_Cotizacion]...';


GO
CREATE NONCLUSTERED INDEX [IX_CotizacionDetalle_Cotizacion]
    ON [ORCO].[CotizacionDetalle]([FKIdCotizacion_ORCO] ASC);


GO
PRINT N'Creando Índice [ORCO].[CotizacionDetalle].[IX_CotizacionDetalle_RequisicionDetalle]...';


GO
CREATE NONCLUSTERED INDEX [IX_CotizacionDetalle_RequisicionDetalle]
    ON [ORCO].[CotizacionDetalle]([FKIdRequisicionDetalle_ORCO] ASC);


GO
PRINT N'Creando Tabla [ORCO].[EstatusRequisicion]...';


GO
CREATE TABLE [ORCO].[EstatusRequisicion] (
    [PKIdEstatusRequisicion] INT           IDENTITY (1, 1) NOT NULL,
    [Descripcion]            NVARCHAR (50) NOT NULL,
    [Color]                  NVARCHAR (8)  NULL,
    [Orden]                  INT           NOT NULL,
    [Icono]                  NVARCHAR (50) NULL,
    [Activo]                 BIT           NOT NULL,
    [FechaCreacion]          DATETIME2 (7) NULL,
    [UsuarioCreacion]        INT           NOT NULL,
    [FechaModificacion]      DATETIME2 (7) NULL,
    [UsuarioModificacion]    INT           NULL,
    CONSTRAINT [PK_EstatusRequisicion] PRIMARY KEY CLUSTERED ([PKIdEstatusRequisicion] ASC)
);


GO
PRINT N'Creando Tabla [ORCO].[PAAASDetalle]...';


GO
CREATE TABLE [ORCO].[PAAASDetalle] (
    [PKIdPAAASDetalle]      INT            IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]       INT            NOT NULL,
    [FKIdPAAASPartida_ORCO] INT            NOT NULL,
    [FKIdTipoBien_ALMA]     INT            NOT NULL,
    [FKIdUnidades_ALMA]     INT            NULL,
    [Cantidad]              NUMERIC (8, 2) NOT NULL,
    [Observaciones]         NVARCHAR (MAX) NOT NULL,
    [LugarEntrega]          VARCHAR (200)  NULL,
    [Activo]                BIT            NOT NULL,
    [FechaCreacion]         DATETIME2 (7)  NULL,
    [UsuarioCreacion]       INT            NOT NULL,
    [FechaModificacion]     DATETIME2 (7)  NULL,
    [UsuarioModificacion]   INT            NULL,
    CONSTRAINT [PK_PAAASDetalle] PRIMARY KEY CLUSTERED ([PKIdPAAASDetalle] ASC)
);


GO
PRINT N'Creando Tabla [ORCO].[Proyecto]...';


GO
CREATE TABLE [ORCO].[Proyecto] (
    [PKIdProyecto]        INT            IDENTITY (1, 1) NOT NULL,
    [Descripcion]         NVARCHAR (MAX) NOT NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_Proyecto] PRIMARY KEY CLUSTERED ([PKIdProyecto] ASC)
);


GO
PRINT N'Creando Tabla [ORCO].[Fraccion]...';


GO
CREATE TABLE [ORCO].[Fraccion] (
    [PKIdFraccion]        INT            IDENTITY (1, 1) NOT NULL,
    [FKIdArticulo_ORCO]   INT            NOT NULL,
    [Clave]               NVARCHAR (20)  NOT NULL,
    [Descripcion]         NVARCHAR (250) NOT NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_Fraccion] PRIMARY KEY CLUSTERED ([PKIdFraccion] ASC)
);


GO
PRINT N'Creando Tabla [ORCO].[Modalidad]...';


GO
CREATE TABLE [ORCO].[Modalidad] (
    [PKIdModalidad]       INT           IDENTITY (1, 1) NOT NULL,
    [Descripcion]         NVARCHAR (30) NOT NULL,
    [Activo]              BIT           NOT NULL,
    [FechaCreacion]       DATETIME2 (7) NULL,
    [UsuarioCreacion]     INT           NOT NULL,
    [FechaModificacion]   DATETIME2 (7) NULL,
    [UsuarioModificacion] INT           NULL,
    CONSTRAINT [PK_Modalidad] PRIMARY KEY CLUSTERED ([PKIdModalidad] ASC)
);


GO
PRINT N'Creando Tabla [ORCO].[EstudioMercadoDetalle]...';


GO
CREATE TABLE [ORCO].[EstudioMercadoDetalle] (
    [PKIdEstudioMercadoDetalle] INT             IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]           INT             NOT NULL,
    [FKIdEstudioMercado_ORCO]   INT             NOT NULL,
    [FKIdPAAASDetalle_ORCO]     INT             NOT NULL,
    [FKIdTipoBien_ALMA]         INT             NOT NULL,
    [Cantidad]                  NUMERIC (8, 2)  NOT NULL,
    [Observaciones]             NVARCHAR (MAX)  NULL,
    [Activo]                    BIT             NOT NULL,
    [FechaCreacion]             DATETIME2 (7)   NULL,
    [UsuarioCreacion]           INT             NOT NULL,
    [FechaModificacion]         DATETIME2 (7)   NULL,
    [UsuarioModificacion]       INT             NULL,
    [FKIdProveedor_SIS]         INT             NULL,
    [CostoUnitario]             DECIMAL (20, 4) NULL,
    CONSTRAINT [PK_EstudioMercadoDetalle] PRIMARY KEY CLUSTERED ([PKIdEstudioMercadoDetalle] ASC)
);


GO
PRINT N'Creando Índice [ORCO].[EstudioMercadoDetalle].[IX_EstudioMercadoDetalle_Proveedor]...';


GO
CREATE NONCLUSTERED INDEX [IX_EstudioMercadoDetalle_Proveedor]
    ON [ORCO].[EstudioMercadoDetalle]([FKIdProveedor_SIS] ASC);


GO
PRINT N'Creando Tabla [ORCO].[TipoDocumento]...';


GO
CREATE TABLE [ORCO].[TipoDocumento] (
    [PKIdTipoDocumento]   INT           IDENTITY (1, 1) NOT NULL,
    [Descripcion]         NVARCHAR (25) NOT NULL,
    [Activo]              BIT           NOT NULL,
    [FechaCreacion]       DATETIME2 (7) NULL,
    [UsuarioCreacion]     INT           NOT NULL,
    [FechaModificacion]   DATETIME2 (7) NULL,
    [UsuarioModificacion] INT           NULL,
    CONSTRAINT [PK_TipoDocumento] PRIMARY KEY CLUSTERED ([PKIdTipoDocumento] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[TipoGasto]...';


GO
CREATE TABLE [PRES].[TipoGasto] (
    [PKIdTipoGasto]       INT            IDENTITY (1, 1) NOT NULL,
    [Clave]               INT            NOT NULL,
    [Descripcion]         NVARCHAR (200) NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_TipoGasto] PRIMARY KEY CLUSTERED ([PKIdTipoGasto] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[SubEje]...';


GO
CREATE TABLE [PRES].[SubEje] (
    [PKIdSubEje]          INT            IDENTITY (1, 1) NOT NULL,
    [FKIdEje_PRES]        INT            NOT NULL,
    [Clave]               NVARCHAR (2)   NOT NULL,
    [Descripcion]         NVARCHAR (200) NOT NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_SubEje] PRIMARY KEY CLUSTERED ([PKIdSubEje] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[SolicitudSuficiencia]...';


GO
CREATE TABLE [PRES].[SolicitudSuficiencia] (
    [PKIdSolicitudSuficiencia] INT             IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]          INT             NOT NULL,
    [FKIdRequisicion_ORCO]     INT             NOT NULL,
    [FechaSolicitud]           DATE            NOT NULL,
    [Justificacion]            NVARCHAR (1000) NULL,
    [GastoNoProgramable]       VARCHAR (3)     NULL,
    [IdGastoNoProgramable]     INT             NULL,
    [IdCompromisoNomina]       INT             NULL,
    [Estatus]                  INT             NOT NULL,
    [Activo]                   BIT             NOT NULL,
    [FechaCreacion]            DATETIME2 (7)   NULL,
    [UsuarioCreacion]          INT             NOT NULL,
    [FechaModificacion]        DATETIME2 (7)   NULL,
    [UsuarioModificacion]      INT             NULL,
    CONSTRAINT [PK_SolicitudSuficiencia] PRIMARY KEY CLUSTERED ([PKIdSolicitudSuficiencia] ASC)
);


GO
PRINT N'Creando Índice [PRES].[SolicitudSuficiencia].[IX_SolicitudSuficiencia_Estatus]...';


GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSuficiencia_Estatus]
    ON [PRES].[SolicitudSuficiencia]([Estatus] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Índice [PRES].[SolicitudSuficiencia].[IX_SolicitudSuficiencia_Requisicion]...';


GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSuficiencia_Requisicion]
    ON [PRES].[SolicitudSuficiencia]([FKIdRequisicion_ORCO] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Índice [PRES].[SolicitudSuficiencia].[IX_SolicitudSuficiencia_Fecha]...';


GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSuficiencia_Fecha]
    ON [PRES].[SolicitudSuficiencia]([FechaSolicitud] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Tabla [PRES].[PP]...';


GO
CREATE TABLE [PRES].[PP] (
    [PKIdPP]              INT            IDENTITY (1, 1) NOT NULL,
    [Clave]               NVARCHAR (4)   NOT NULL,
    [Descripcion]         NVARCHAR (150) NOT NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_PP] PRIMARY KEY CLUSTERED ([PKIdPP] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[Programa]...';


GO
CREATE TABLE [PRES].[Programa] (
    [PKIdPrograma]                   INT            IDENTITY (1, 1) NOT NULL,
    [Clave]                          NVARCHAR (50)  NOT NULL,
    [Descripcion]                    NVARCHAR (255) NOT NULL,
    [Activo]                         BIT            NOT NULL,
    [FechaCreacion]                  DATETIME2 (7)  NULL,
    [UsuarioCreacion]                INT            NOT NULL,
    [FechaModificacion]              DATETIME2 (7)  NULL,
    [UsuarioModificacion]            INT            NULL,
    [FKIdUR_PRES]                    INT            NOT NULL,
    [FKIdGF_PRES]                    INT            NOT NULL,
    [FKIdFN_PRES]                    INT            NOT NULL,
    [FKIdSF_PRES]                    INT            NOT NULL,
    [FKIdActividadInstitucional_SIS] INT            NOT NULL,
    [FKIdEje_PRES]                   INT            NULL,
    [FKIdVertienteGasto_PRES]        INT            NULL,
    [FKIdResultado_PRES]             INT            NULL,
    [FKIdSubresultado_PRES]          INT            NULL,
    [FKIdAnio_SIS]                   INT            NULL,
    [FKIdSector_PRES]                INT            NULL,
    [FKIdSubSector_PRES]             INT            NULL,
    [FKIdTipoRecurso_PRES]           INT            NULL,
    [FKIdFuenteFinanciamiento_PRES]  INT            NULL,
    [Objetivo]                       NVARCHAR (500) NULL,
    [FKIdSubEje_PRES]                INT            NULL,
    [FKIdSubSubEje_PRES]             INT            NULL,
    [FKIdFinalidad_PRES]             INT            NULL,
    [FKIdPP_PRES]                    INT            NULL,
    CONSTRAINT [PK_Programa] PRIMARY KEY CLUSTERED ([PKIdPrograma] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[DigitoIdentificador]...';


GO
CREATE TABLE [PRES].[DigitoIdentificador] (
    [PKIdDigitoIdentificador] INT            IDENTITY (1, 1) NOT NULL,
    [Clave]                   NVARCHAR (1)   NOT NULL,
    [Descripcion]             NVARCHAR (200) NOT NULL,
    [Activo]                  BIT            NOT NULL,
    [FechaCreacion]           DATETIME2 (7)  NULL,
    [UsuarioCreacion]         INT            NOT NULL,
    [FechaModificacion]       DATETIME2 (7)  NULL,
    [UsuarioModificacion]     INT            NULL,
    CONSTRAINT [PK_DigitoIdentificador] PRIMARY KEY CLUSTERED ([PKIdDigitoIdentificador] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[VertienteGasto]...';


GO
CREATE TABLE [PRES].[VertienteGasto] (
    [PKIdVertienteGasto]  INT            IDENTITY (1, 1) NOT NULL,
    [Clave]               NVARCHAR (2)   NOT NULL,
    [Descripcion]         NVARCHAR (200) NOT NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_VertienteGasto] PRIMARY KEY CLUSTERED ([PKIdVertienteGasto] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[EgresoAutorizado]...';


GO
CREATE TABLE [PRES].[EgresoAutorizado] (
    [PKIdEgresoAutorizado]          INT             IDENTITY (1, 1) NOT NULL,
    [FKIdPrograma_PRES]             INT             NOT NULL,
    [FKIdPartida_CONTA]             INT             NOT NULL,
    [FKIdArea_SIS]                  INT             NOT NULL,
    [Descripcion]                   NVARCHAR (250)  NULL,
    [Fecha]                         DATE            NOT NULL,
    [FKIdPoliza_CONTA]              INT             NULL,
    [Activo]                        BIT             NOT NULL,
    [FechaCreacion]                 DATETIME2 (7)   NULL,
    [UsuarioCreacion]               INT             NOT NULL,
    [FechaModificacion]             DATETIME2 (7)   NULL,
    [UsuarioModificacion]           INT             NULL,
    [FKIdEgresoProyectado_PRES]     INT             NULL,
    [Enero]                         DECIMAL (18, 2) NOT NULL,
    [Febrero]                       DECIMAL (18, 2) NOT NULL,
    [Marzo]                         DECIMAL (18, 2) NOT NULL,
    [Abril]                         DECIMAL (18, 2) NOT NULL,
    [Mayo]                          DECIMAL (18, 2) NOT NULL,
    [Junio]                         DECIMAL (18, 2) NOT NULL,
    [Julio]                         DECIMAL (18, 2) NOT NULL,
    [Agosto]                        DECIMAL (18, 2) NOT NULL,
    [Septiembre]                    DECIMAL (18, 2) NOT NULL,
    [Octubre]                       DECIMAL (18, 2) NOT NULL,
    [Noviembre]                     DECIMAL (18, 2) NOT NULL,
    [Diciembre]                     DECIMAL (18, 2) NOT NULL,
    [Total]                         AS              ((((((((((([Enero] + [Febrero]) + [Marzo]) + [Abril]) + [Mayo]) + [Junio]) + [Julio]) + [Agosto]) + [Septiembre]) + [Octubre]) + [Noviembre]) + [Diciembre]),
    [FechaAutorizacion]             DATETIME2 (7)   NULL,
    [UsuarioAutorizacion]           INT             NULL,
    [FKIdFuenteFinanciamiento_PRES] INT             NULL,
    [FKIdTipoGasto_PRES]            INT             NULL,
    [FKIdDigitoIdentificador_PRES]  INT             NULL,
    [FKIdDestinoGasto_PRES]         INT             NULL,
    [FKIdPY_PRES]                   INT             NULL,
    CONSTRAINT [PK_EgresoAutorizado] PRIMARY KEY CLUSTERED ([PKIdEgresoAutorizado] ASC)
);


GO
PRINT N'Creando Índice [PRES].[EgresoAutorizado].[UX_EgresoAutorizado_EgresoProyectado_Activo]...';


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_EgresoAutorizado_EgresoProyectado_Activo]
    ON [PRES].[EgresoAutorizado]([FKIdEgresoProyectado_PRES] ASC) WHERE ([FKIdEgresoProyectado_PRES] IS NOT NULL AND [Activo]=(1));


GO
PRINT N'Creando Tabla [PRES].[FN]...';


GO
CREATE TABLE [PRES].[FN] (
    [PKIdFN]              INT           IDENTITY (1, 1) NOT NULL,
    [FKIdGF_PRES]         INT           NOT NULL,
    [Clave]               INT           NOT NULL,
    [Descripcion]         NVARCHAR (50) NOT NULL,
    [Activo]              BIT           NOT NULL,
    [FechaCreacion]       DATETIME2 (7) NULL,
    [UsuarioCreacion]     INT           NOT NULL,
    [FechaModificacion]   DATETIME2 (7) NULL,
    [UsuarioModificacion] INT           NULL,
    CONSTRAINT [PK_FN] PRIMARY KEY CLUSTERED ([PKIdFN] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[SubSubEje]...';


GO
CREATE TABLE [PRES].[SubSubEje] (
    [PKIdSubSubEje]       INT            IDENTITY (1, 1) NOT NULL,
    [FKIdSubEje_PRES]     INT            NOT NULL,
    [Clave]               NVARCHAR (2)   NOT NULL,
    [Descripcion]         NVARCHAR (200) NOT NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_SubSubEje] PRIMARY KEY CLUSTERED ([PKIdSubSubEje] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[CLCDetalle]...';


GO
CREATE TABLE [PRES].[CLCDetalle] (
    [PKIdCLCDetalle]           INT            IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]          INT            NOT NULL,
    [FKIdCLC_PRES]             INT            NOT NULL,
    [FKIdContratoDetalle_PRES] INT            NOT NULL,
    [FKIdPartida_CONTA]        INT            NOT NULL,
    [Enero]                    [dbo].[dmoney] NULL,
    [Febrero]                  [dbo].[dmoney] NULL,
    [Marzo]                    [dbo].[dmoney] NULL,
    [Abril]                    [dbo].[dmoney] NULL,
    [Mayo]                     [dbo].[dmoney] NULL,
    [Junio]                    [dbo].[dmoney] NULL,
    [Julio]                    [dbo].[dmoney] NULL,
    [Agosto]                   [dbo].[dmoney] NULL,
    [Septiembre]               [dbo].[dmoney] NULL,
    [Octubre]                  [dbo].[dmoney] NULL,
    [Noviembre]                [dbo].[dmoney] NULL,
    [Diciembre]                [dbo].[dmoney] NULL,
    [Total]                    AS             (((((((((((isnull([Enero], (0)) + isnull([Febrero], (0))) + isnull([Marzo], (0))) + isnull([Abril], (0))) + isnull([Mayo], (0))) + isnull([Junio], (0))) + isnull([Julio], (0))) + isnull([Agosto], (0))) + isnull([Septiembre], (0))) + isnull([Octubre], (0))) + isnull([Noviembre], (0))) + isnull([Diciembre], (0))),
    [Observaciones]            NVARCHAR (500) NULL,
    [Activo]                   BIT            NOT NULL,
    [FechaCreacion]            DATETIME2 (7)  NULL,
    [UsuarioCreacion]          INT            NOT NULL,
    [FechaModificacion]        DATETIME2 (7)  NULL,
    [UsuarioModificacion]      INT            NULL,
    CONSTRAINT [PK_CLCDetalle] PRIMARY KEY CLUSTERED ([PKIdCLCDetalle] ASC)
);


GO
PRINT N'Creando Índice [PRES].[CLCDetalle].[IX_CLCDetalle_ContratoDetalle]...';


GO
CREATE NONCLUSTERED INDEX [IX_CLCDetalle_ContratoDetalle]
    ON [PRES].[CLCDetalle]([FKIdContratoDetalle_PRES] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Índice [PRES].[CLCDetalle].[IX_CLCDetalle_CLC]...';


GO
CREATE NONCLUSTERED INDEX [IX_CLCDetalle_CLC]
    ON [PRES].[CLCDetalle]([FKIdCLC_PRES] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Tabla [PRES].[Eje]...';


GO
CREATE TABLE [PRES].[Eje] (
    [PKIdEje]             INT            IDENTITY (1, 1) NOT NULL,
    [Clave]               NVARCHAR (1)   NOT NULL,
    [Descripcion]         NVARCHAR (200) NOT NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_Eje] PRIMARY KEY CLUSTERED ([PKIdEje] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[TipoRecurso]...';


GO
CREATE TABLE [PRES].[TipoRecurso] (
    [PKIdTipoRecurso]     INT            IDENTITY (1, 1) NOT NULL,
    [Clave]               NVARCHAR (1)   NOT NULL,
    [Descripcion]         NVARCHAR (200) NOT NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_TipoRecurso] PRIMARY KEY CLUSTERED ([PKIdTipoRecurso] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[ChequePartidas]...';


GO
CREATE TABLE [PRES].[ChequePartidas] (
    [PKIdChequePartida]   INT            IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]     INT            NOT NULL,
    [FKIdCheque_PRES]     INT            NOT NULL,
    [FKIdCLCDetalle_PRES] INT            NOT NULL,
    [FKIdPartida_CONTA]   INT            NOT NULL,
    [MontoPagado]         [dbo].[dmoney] NOT NULL,
    [Observaciones]       NVARCHAR (500) NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_ChequePartidas] PRIMARY KEY CLUSTERED ([PKIdChequePartida] ASC)
);


GO
PRINT N'Creando Índice [PRES].[ChequePartidas].[IX_ChequePartidas_Cheque]...';


GO
CREATE NONCLUSTERED INDEX [IX_ChequePartidas_Cheque]
    ON [PRES].[ChequePartidas]([FKIdCheque_PRES] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Índice [PRES].[ChequePartidas].[IX_ChequePartidas_CLCDetalle]...';


GO
CREATE NONCLUSTERED INDEX [IX_ChequePartidas_CLCDetalle]
    ON [PRES].[ChequePartidas]([FKIdCLCDetalle_PRES] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Tabla [PRES].[GrupoPresupuesto]...';


GO
CREATE TABLE [PRES].[GrupoPresupuesto] (
    [PKIdGrupoPresupuesto] INT           IDENTITY (1, 1) NOT NULL,
    [Clave]                INT           NOT NULL,
    [Descripcion]          NVARCHAR (50) NOT NULL,
    [Activo]               BIT           NOT NULL,
    [FechaCreacion]        DATETIME2 (7) NULL,
    [UsuarioCreacion]      INT           NOT NULL,
    [FechaModificacion]    DATETIME2 (7) NULL,
    [UsuarioModificacion]  INT           NULL,
    CONSTRAINT [PK_GrupoPresupuesto] PRIMARY KEY CLUSTERED ([PKIdGrupoPresupuesto] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[AutorizacionSuficienciaDetalle]...';


GO
CREATE TABLE [PRES].[AutorizacionSuficienciaDetalle] (
    [PKIdAutorizacionSuficienciaDetalle]   INT            IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]                      INT            NOT NULL,
    [FKIdAutorizacionSuficiencia_PRES]     INT            NOT NULL,
    [FKIdSolicitudSuficienciaDetalle_PRES] INT            NOT NULL,
    [FKIdPartida_CONTA]                    INT            NOT NULL,
    [Enero]                                [dbo].[dmoney] NULL,
    [Febrero]                              [dbo].[dmoney] NULL,
    [Marzo]                                [dbo].[dmoney] NULL,
    [Abril]                                [dbo].[dmoney] NULL,
    [Mayo]                                 [dbo].[dmoney] NULL,
    [Junio]                                [dbo].[dmoney] NULL,
    [Julio]                                [dbo].[dmoney] NULL,
    [Agosto]                               [dbo].[dmoney] NULL,
    [Septiembre]                           [dbo].[dmoney] NULL,
    [Octubre]                              [dbo].[dmoney] NULL,
    [Noviembre]                            [dbo].[dmoney] NULL,
    [Diciembre]                            [dbo].[dmoney] NULL,
    [Total]                                AS             (((((((((((isnull([Enero], (0)) + isnull([Febrero], (0))) + isnull([Marzo], (0))) + isnull([Abril], (0))) + isnull([Mayo], (0))) + isnull([Junio], (0))) + isnull([Julio], (0))) + isnull([Agosto], (0))) + isnull([Septiembre], (0))) + isnull([Octubre], (0))) + isnull([Noviembre], (0))) + isnull([Diciembre], (0))),
    [Observaciones]                        NVARCHAR (500) NULL,
    [Activo]                               BIT            NOT NULL,
    [FechaCreacion]                        DATETIME2 (7)  NULL,
    [UsuarioCreacion]                      INT            NOT NULL,
    [FechaModificacion]                    DATETIME2 (7)  NULL,
    [UsuarioModificacion]                  INT            NULL,
    CONSTRAINT [PK_AutorizacionSuficienciaDetalle] PRIMARY KEY CLUSTERED ([PKIdAutorizacionSuficienciaDetalle] ASC)
);


GO
PRINT N'Creando Índice [PRES].[AutorizacionSuficienciaDetalle].[IX_AutorizacionSuficienciaDetalle_SolicitudDetalle]...';


GO
CREATE NONCLUSTERED INDEX [IX_AutorizacionSuficienciaDetalle_SolicitudDetalle]
    ON [PRES].[AutorizacionSuficienciaDetalle]([FKIdSolicitudSuficienciaDetalle_PRES] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Índice [PRES].[AutorizacionSuficienciaDetalle].[IX_AutorizacionSuficienciaDetalle_Autorizacion]...';


GO
CREATE NONCLUSTERED INDEX [IX_AutorizacionSuficienciaDetalle_Autorizacion]
    ON [PRES].[AutorizacionSuficienciaDetalle]([FKIdAutorizacionSuficiencia_PRES] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Tabla [PRES].[SF]...';


GO
CREATE TABLE [PRES].[SF] (
    [PKIdSF]              INT           IDENTITY (1, 1) NOT NULL,
    [FKIdFN_PRES]         INT           NOT NULL,
    [Clave]               INT           NOT NULL,
    [Descripcion]         NVARCHAR (50) NOT NULL,
    [Activo]              BIT           NOT NULL,
    [FechaCreacion]       DATETIME2 (7) NULL,
    [UsuarioCreacion]     INT           NOT NULL,
    [FechaModificacion]   DATETIME2 (7) NULL,
    [UsuarioModificacion] INT           NULL,
    CONSTRAINT [PK_SF] PRIMARY KEY CLUSTERED ([PKIdSF] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[PY]...';


GO
CREATE TABLE [PRES].[PY] (
    [PKIdPY]                 INT            IDENTITY (1, 1) NOT NULL,
    [Clave]                  VARCHAR (15)   NULL,
    [Descripcion]            NVARCHAR (150) NOT NULL,
    [NombreProyecto]         NVARCHAR (500) NULL,
    [InicioProyecto]         DATE           NULL,
    [FinProyecto]            DATE           NULL,
    [Plurianual]             BIT            NULL,
    [TieneTICS]              BIT            NULL,
    [EsPAT]                  BIT            NULL,
    [AnexosTransversales]    BIT            NULL,
    [ProgramaPresupuestario] NVARCHAR (24)  NULL,
    [ProyectoInversion]      BIT            NULL,
    [RecursosAdicionales]    BIT            NULL,
    [Prioridad]              SMALLINT       NULL,
    [FuenteFinanciamiento]   NVARCHAR (500) NULL,
    [DescripcionProyecto]    NVARCHAR (500) NULL,
    [ResponsableProyecto]    NVARCHAR (128) NULL,
    [ObjetivoProyecto]       NVARCHAR (500) NULL,
    [LineaEstrategica]       NVARCHAR (500) NULL,
    [LineaAccionRegulatoria] NVARCHAR (500) NULL,
    [TemaAccionRegulatoria]  NVARCHAR (500) NULL,
    [FundamentoLegal]        NVARCHAR (500) NULL,
    [Justificacion]          NVARCHAR (500) NULL,
    [Beneficios]             NVARCHAR (500) NULL,
    [Indicador]              NVARCHAR (128) NULL,
    [Meta]                   NVARCHAR (128) NULL,
    [Activo]                 BIT            NOT NULL,
    [FechaCreacion]          DATETIME2 (7)  NULL,
    [UsuarioCreacion]        INT            NOT NULL,
    [FechaModificacion]      DATETIME2 (7)  NULL,
    [UsuarioModificacion]    INT            NULL,
    CONSTRAINT [PK_PY] PRIMARY KEY CLUSTERED ([PKIdPY] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[AutorizacionSuficiencia]...';


GO
CREATE TABLE [PRES].[AutorizacionSuficiencia] (
    [PKIdAutorizacionSuficiencia]   INT            IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]               INT            NOT NULL,
    [FKIdSolicitudSuficiencia_PRES] INT            NOT NULL,
    [FechaAutorizacion]             DATE           NOT NULL,
    [Justificacion]                 NVARCHAR (250) NOT NULL,
    [GastoNoProgramable]            VARCHAR (3)    NULL,
    [IdGastoNoProgramable]          INT            NULL,
    [IdCompromisoNomina]            INT            NULL,
    [AutorizadoPor_NOM]             INT            NOT NULL,
    [Observaciones]                 NVARCHAR (500) NULL,
    [Estatus]                       INT            NOT NULL,
    [Activo]                        BIT            NOT NULL,
    [FechaCreacion]                 DATETIME2 (7)  NULL,
    [UsuarioCreacion]               INT            NOT NULL,
    [FechaModificacion]             DATETIME2 (7)  NULL,
    [UsuarioModificacion]           INT            NULL,
    CONSTRAINT [PK_AutorizacionSuficiencia] PRIMARY KEY CLUSTERED ([PKIdAutorizacionSuficiencia] ASC)
);


GO
PRINT N'Creando Índice [PRES].[AutorizacionSuficiencia].[IX_AutorizacionSuficiencia_Estatus]...';


GO
CREATE NONCLUSTERED INDEX [IX_AutorizacionSuficiencia_Estatus]
    ON [PRES].[AutorizacionSuficiencia]([Estatus] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Índice [PRES].[AutorizacionSuficiencia].[IX_AutorizacionSuficiencia_Fecha]...';


GO
CREATE NONCLUSTERED INDEX [IX_AutorizacionSuficiencia_Fecha]
    ON [PRES].[AutorizacionSuficiencia]([FechaAutorizacion] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Índice [PRES].[AutorizacionSuficiencia].[IX_AutorizacionSuficiencia_Solicitud]...';


GO
CREATE NONCLUSTERED INDEX [IX_AutorizacionSuficiencia_Solicitud]
    ON [PRES].[AutorizacionSuficiencia]([FKIdSolicitudSuficiencia_PRES] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Tabla [PRES].[Subresultado]...';


GO
CREATE TABLE [PRES].[Subresultado] (
    [PKIdSubresultado]    INT            IDENTITY (1, 1) NOT NULL,
    [Clave]               NVARCHAR (2)   NOT NULL,
    [Descripcion]         NVARCHAR (200) NOT NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_Subresultado] PRIMARY KEY CLUSTERED ([PKIdSubresultado] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[Suficiencia]...';


GO
CREATE TABLE [PRES].[Suficiencia] (
    [PKIdSuficiencia]     INT           IDENTITY (1, 1) NOT NULL,
    [Descripcion]         NVARCHAR (50) NOT NULL,
    [Activo]              BIT           NOT NULL,
    [FechaCreacion]       DATETIME2 (7) NULL,
    [UsuarioCreacion]     INT           NOT NULL,
    [FechaModificacion]   DATETIME2 (7) NULL,
    [UsuarioModificacion] INT           NULL,
    CONSTRAINT [PK_Suficiencia] PRIMARY KEY CLUSTERED ([PKIdSuficiencia] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[UR]...';


GO
CREATE TABLE [PRES].[UR] (
    [PKIdUR]                    INT           IDENTITY (1, 1) NOT NULL,
    [FKIdGrupoPresupuesto_PRES] INT           NOT NULL,
    [Clave]                     NVARCHAR (10) NULL,
    [Descripcion]               NVARCHAR (50) NOT NULL,
    [Activo]                    BIT           NOT NULL,
    [FechaCreacion]             DATETIME2 (7) NULL,
    [UsuarioCreacion]           INT           NOT NULL,
    [FechaModificacion]         DATETIME2 (7) NULL,
    [UsuarioModificacion]       INT           NULL,
    CONSTRAINT [PK_UR] PRIMARY KEY CLUSTERED ([PKIdUR] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[Sector]...';


GO
CREATE TABLE [PRES].[Sector] (
    [PKIdSector]          INT            IDENTITY (1, 1) NOT NULL,
    [Clave]               NVARCHAR (2)   NOT NULL,
    [Descripcion]         NVARCHAR (200) NOT NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_Sector] PRIMARY KEY CLUSTERED ([PKIdSector] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[Contrato]...';


GO
CREATE TABLE [PRES].[Contrato] (
    [PKIdContrato]                     INT            IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]                  INT            NOT NULL,
    [FKIdAutorizacionSuficiencia_PRES] INT            NOT NULL,
    [FKIdProveedor_SIS]                INT            NOT NULL,
    [FKIdPoliza_CONTA]                 INT            NULL,
    [NumeroContrato]                   NVARCHAR (50)  NOT NULL,
    [Descripcion]                      NVARCHAR (500) NOT NULL,
    [FechaContrato]                    DATE           NOT NULL,
    [FechaInicioVigencia]              DATE           NULL,
    [FechaFinVigencia]                 DATE           NULL,
    [MontoTotal]                       [dbo].[dmoney] NOT NULL,
    [PlazoEjecucion]                   NVARCHAR (100) NULL,
    [Observaciones]                    NVARCHAR (MAX) NULL,
    [Estatus]                          INT            NOT NULL,
    [Activo]                           BIT            NOT NULL,
    [FechaCreacion]                    DATETIME2 (7)  NULL,
    [UsuarioCreacion]                  INT            NOT NULL,
    [FechaModificacion]                DATETIME2 (7)  NULL,
    [UsuarioModificacion]              INT            NULL,
    CONSTRAINT [PK_Contrato] PRIMARY KEY CLUSTERED ([PKIdContrato] ASC)
);


GO
PRINT N'Creando Índice [PRES].[Contrato].[IX_Contrato_Proveedor]...';


GO
CREATE NONCLUSTERED INDEX [IX_Contrato_Proveedor]
    ON [PRES].[Contrato]([FKIdProveedor_SIS] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Índice [PRES].[Contrato].[IX_Contrato_Autorizacion]...';


GO
CREATE NONCLUSTERED INDEX [IX_Contrato_Autorizacion]
    ON [PRES].[Contrato]([FKIdAutorizacionSuficiencia_PRES] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Índice [PRES].[Contrato].[IX_Contrato_Estatus]...';


GO
CREATE NONCLUSTERED INDEX [IX_Contrato_Estatus]
    ON [PRES].[Contrato]([Estatus] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Tabla [PRES].[SolicitudSuficienciaDetalle]...';


GO
CREATE TABLE [PRES].[SolicitudSuficienciaDetalle] (
    [PKIdSolicitudSuficienciaDetalle] INT            IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]                 INT            NOT NULL,
    [FKIdSolicitudSuficiencia_PRES]   INT            NOT NULL,
    [FKIdRequisicionDetalle_ORCO]     INT            NOT NULL,
    [FKIdPartida_CONTA]               INT            NOT NULL,
    [Enero]                           [dbo].[dmoney] NULL,
    [Febrero]                         [dbo].[dmoney] NULL,
    [Marzo]                           [dbo].[dmoney] NULL,
    [Abril]                           [dbo].[dmoney] NULL,
    [Mayo]                            [dbo].[dmoney] NULL,
    [Junio]                           [dbo].[dmoney] NULL,
    [Julio]                           [dbo].[dmoney] NULL,
    [Agosto]                          [dbo].[dmoney] NULL,
    [Septiembre]                      [dbo].[dmoney] NULL,
    [Octubre]                         [dbo].[dmoney] NULL,
    [Noviembre]                       [dbo].[dmoney] NULL,
    [Diciembre]                       [dbo].[dmoney] NULL,
    [Total]                           AS             (((((((((((isnull([Enero], (0)) + isnull([Febrero], (0))) + isnull([Marzo], (0))) + isnull([Abril], (0))) + isnull([Mayo], (0))) + isnull([Junio], (0))) + isnull([Julio], (0))) + isnull([Agosto], (0))) + isnull([Septiembre], (0))) + isnull([Octubre], (0))) + isnull([Noviembre], (0))) + isnull([Diciembre], (0))),
    [Observaciones]                   NVARCHAR (500) NULL,
    [Activo]                          BIT            NOT NULL,
    [FechaCreacion]                   DATETIME2 (7)  NULL,
    [UsuarioCreacion]                 INT            NOT NULL,
    [FechaModificacion]               DATETIME2 (7)  NULL,
    [UsuarioModificacion]             INT            NULL,
    CONSTRAINT [PK_SolicitudSuficienciaDetalle] PRIMARY KEY CLUSTERED ([PKIdSolicitudSuficienciaDetalle] ASC)
);


GO
PRINT N'Creando Índice [PRES].[SolicitudSuficienciaDetalle].[IX_SolicitudSuficienciaDetalle_RequisicionDetalle]...';


GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSuficienciaDetalle_RequisicionDetalle]
    ON [PRES].[SolicitudSuficienciaDetalle]([FKIdRequisicionDetalle_ORCO] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Índice [PRES].[SolicitudSuficienciaDetalle].[IX_SolicitudSuficienciaDetalle_Solicitud]...';


GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSuficienciaDetalle_Solicitud]
    ON [PRES].[SolicitudSuficienciaDetalle]([FKIdSolicitudSuficiencia_PRES] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Tabla [PRES].[Cheque]...';


GO
CREATE TABLE [PRES].[Cheque] (
    [PKIdCheque]             INT            IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]        INT            NOT NULL,
    [FKIdCLC_PRES]           INT            NOT NULL,
    [FKIdCuentaBancaria_TES] INT            NOT NULL,
    [FKIdPoliza_CONTA]       INT            NOT NULL,
    [FechaEmision]           DATE           NOT NULL,
    [NumeroCheque]           NVARCHAR (50)  NOT NULL,
    [Concepto]               NVARCHAR (150) NOT NULL,
    [ImporteTotal]           [dbo].[dmoney] NOT NULL,
    [Observaciones]          NVARCHAR (500) NULL,
    [Estatus]                INT            NOT NULL,
    [Activo]                 BIT            NOT NULL,
    [FechaCreacion]          DATETIME2 (7)  NULL,
    [UsuarioCreacion]        INT            NOT NULL,
    [FechaModificacion]      DATETIME2 (7)  NULL,
    [UsuarioModificacion]    INT            NULL,
    CONSTRAINT [PK_Cheque] PRIMARY KEY CLUSTERED ([PKIdCheque] ASC)
);


GO
PRINT N'Creando Índice [PRES].[Cheque].[IX_Cheque_CLC]...';


GO
CREATE NONCLUSTERED INDEX [IX_Cheque_CLC]
    ON [PRES].[Cheque]([FKIdCLC_PRES] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Índice [PRES].[Cheque].[IX_Cheque_Numero]...';


GO
CREATE NONCLUSTERED INDEX [IX_Cheque_Numero]
    ON [PRES].[Cheque]([NumeroCheque] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Tabla [PRES].[CLCFactura]...';


GO
CREATE TABLE [PRES].[CLCFactura] (
    [PKIdCLCFactura]          INT            IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]         INT            NOT NULL,
    [FKIdCLC_PRES]            INT            NOT NULL,
    [FKIdFactura_PRES]        INT            NOT NULL,
    [FKIdFacturaDetalle_PRES] INT            NOT NULL,
    [MontoAplicado]           [dbo].[dmoney] NOT NULL,
    [Observaciones]           NVARCHAR (500) NULL,
    [Activo]                  BIT            NOT NULL,
    [FechaCreacion]           DATETIME2 (7)  NULL,
    [UsuarioCreacion]         INT            NOT NULL,
    [FechaModificacion]       DATETIME2 (7)  NULL,
    [UsuarioModificacion]     INT            NULL,
    CONSTRAINT [PK_CLCFactura] PRIMARY KEY CLUSTERED ([PKIdCLCFactura] ASC)
);


GO
PRINT N'Creando Índice [PRES].[CLCFactura].[IX_CLCFactura_Factura]...';


GO
CREATE NONCLUSTERED INDEX [IX_CLCFactura_Factura]
    ON [PRES].[CLCFactura]([FKIdFactura_PRES] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Índice [PRES].[CLCFactura].[IX_CLCFactura_CLC]...';


GO
CREATE NONCLUSTERED INDEX [IX_CLCFactura_CLC]
    ON [PRES].[CLCFactura]([FKIdCLC_PRES] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Tabla [PRES].[EgresoProyectado]...';


GO
CREATE TABLE [PRES].[EgresoProyectado] (
    [PKIdEgresoProyectado]          INT             IDENTITY (1, 1) NOT NULL,
    [FKIdPrograma_PRES]             INT             NOT NULL,
    [FKIdPartida_CONTA]             INT             NOT NULL,
    [FKIdArea_SIS]                  INT             NOT NULL,
    [Descripcion]                   NVARCHAR (250)  NULL,
    [Fecha]                         DATE            NOT NULL,
    [Enero]                         DECIMAL (18, 2) NOT NULL,
    [Febrero]                       DECIMAL (18, 2) NOT NULL,
    [Marzo]                         DECIMAL (18, 2) NOT NULL,
    [Abril]                         DECIMAL (18, 2) NOT NULL,
    [Mayo]                          DECIMAL (18, 2) NOT NULL,
    [Junio]                         DECIMAL (18, 2) NOT NULL,
    [Julio]                         DECIMAL (18, 2) NOT NULL,
    [Agosto]                        DECIMAL (18, 2) NOT NULL,
    [Septiembre]                    DECIMAL (18, 2) NOT NULL,
    [Octubre]                       DECIMAL (18, 2) NOT NULL,
    [Noviembre]                     DECIMAL (18, 2) NOT NULL,
    [Diciembre]                     DECIMAL (18, 2) NOT NULL,
    [Total]                         AS              ((((((((((([Enero] + [Febrero]) + [Marzo]) + [Abril]) + [Mayo]) + [Junio]) + [Julio]) + [Agosto]) + [Septiembre]) + [Octubre]) + [Noviembre]) + [Diciembre]),
    [Activo]                        BIT             NOT NULL,
    [FechaCreacion]                 DATETIME2 (7)   NULL,
    [UsuarioCreacion]               INT             NOT NULL,
    [FechaModificacion]             DATETIME2 (7)   NULL,
    [UsuarioModificacion]           INT             NULL,
    [FKIdFuenteFinanciamiento_PRES] INT             NULL,
    [FKIdTipoGasto_PRES]            INT             NULL,
    [FKIdDigitoIdentificador_PRES]  INT             NULL,
    [FKIdDestinoGasto_PRES]         INT             NULL,
    [FKIdPY_PRES]                   INT             NULL,
    CONSTRAINT [PK_EgresoProyectado] PRIMARY KEY CLUSTERED ([PKIdEgresoProyectado] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[PG]...';


GO
CREATE TABLE [PRES].[PG] (
    [PKIdPG]              INT             IDENTITY (1, 1) NOT NULL,
    [Clave]               INT             NOT NULL,
    [Descripcion]         NVARCHAR (1000) NULL,
    [Activo]              BIT             NOT NULL,
    [FechaCreacion]       DATETIME2 (7)   NULL,
    [UsuarioCreacion]     INT             NOT NULL,
    [FechaModificacion]   DATETIME2 (7)   NULL,
    [UsuarioModificacion] INT             NULL,
    CONSTRAINT [PK_PG] PRIMARY KEY CLUSTERED ([PKIdPG] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[Origen]...';


GO
CREATE TABLE [PRES].[Origen] (
    [PKIdOrigen]          INT           IDENTITY (1, 1) NOT NULL,
    [Clave]               INT           NOT NULL,
    [Descripcion]         NVARCHAR (50) NOT NULL,
    [Activo]              BIT           NOT NULL,
    [FechaCreacion]       DATETIME2 (7) NULL,
    [UsuarioCreacion]     INT           NOT NULL,
    [FechaModificacion]   DATETIME2 (7) NULL,
    [UsuarioModificacion] INT           NULL,
    CONSTRAINT [PK_Origen] PRIMARY KEY CLUSTERED ([PKIdOrigen] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[Factura]...';


GO
CREATE TABLE [PRES].[Factura] (
    [PKIdFactura]         INT             IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]     INT             NOT NULL,
    [FKIdContrato_PRES]   INT             NOT NULL,
    [FKIdPoliza_CONTA]    INT             NOT NULL,
    [NumFactura]          NVARCHAR (250)  NOT NULL,
    [SerieFactura]        NVARCHAR (20)   NULL,
    [FechaEmision]        DATE            NOT NULL,
    [FechaRecepcion]      DATE            NULL,
    [Subtotal]            [dbo].[dmoney]  NULL,
    [IVA]                 [dbo].[dmoney]  NULL,
    [Retencion]           [dbo].[dmoney]  NULL,
    [Total]               [dbo].[dmoney]  NOT NULL,
    [UUID]                NVARCHAR (36)   NULL,
    [FL_Docto]            NVARCHAR (1000) NULL,
    [Observaciones]       NVARCHAR (MAX)  NULL,
    [Estatus]             INT             NOT NULL,
    [Activo]              BIT             NOT NULL,
    [FechaCreacion]       DATETIME2 (7)   NULL,
    [UsuarioCreacion]     INT             NOT NULL,
    [FechaModificacion]   DATETIME2 (7)   NULL,
    [UsuarioModificacion] INT             NULL,
    CONSTRAINT [PK_Factura] PRIMARY KEY CLUSTERED ([PKIdFactura] ASC)
);


GO
PRINT N'Creando Índice [PRES].[Factura].[IX_Factura_Contrato]...';


GO
CREATE NONCLUSTERED INDEX [IX_Factura_Contrato]
    ON [PRES].[Factura]([FKIdContrato_PRES] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Índice [PRES].[Factura].[IX_Factura_NumFactura]...';


GO
CREATE NONCLUSTERED INDEX [IX_Factura_NumFactura]
    ON [PRES].[Factura]([NumFactura] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Tabla [PRES].[Ramo]...';


GO
CREATE TABLE [PRES].[Ramo] (
    [PKIdRamo]            INT             IDENTITY (1, 1) NOT NULL,
    [Clave]               INT             NOT NULL,
    [Descripcion]         NVARCHAR (1000) NULL,
    [Activo]              BIT             NOT NULL,
    [FechaCreacion]       DATETIME2 (7)   NULL,
    [UsuarioCreacion]     INT             NOT NULL,
    [FechaModificacion]   DATETIME2 (7)   NULL,
    [UsuarioModificacion] INT             NULL,
    CONSTRAINT [PK_Ramo] PRIMARY KEY CLUSTERED ([PKIdRamo] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[FuenteFinanciamiento]...';


GO
CREATE TABLE [PRES].[FuenteFinanciamiento] (
    [PKIdFuenteFinanciamiento] INT            IDENTITY (1, 1) NOT NULL,
    [Clave]                    NVARCHAR (6)   NULL,
    [Descripcion]              NVARCHAR (200) NOT NULL,
    [FF]                       NVARCHAR (2)   NULL,
    [FG]                       NVARCHAR (1)   NULL,
    [FE]                       NVARCHAR (1)   NULL,
    [AD]                       NVARCHAR (1)   NULL,
    [ORI]                      NVARCHAR (1)   NULL,
    [Activo]                   BIT            NOT NULL,
    [FechaCreacion]            DATETIME2 (7)  NULL,
    [UsuarioCreacion]          INT            NOT NULL,
    [FechaModificacion]        DATETIME2 (7)  NULL,
    [UsuarioModificacion]      INT            NULL,
    CONSTRAINT [PK_FuenteFinanciamiento] PRIMARY KEY CLUSTERED ([PKIdFuenteFinanciamiento] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[FacturaDetalle]...';


GO
CREATE TABLE [PRES].[FacturaDetalle] (
    [PKIdFacturaDetalle]       INT            IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]          INT            NOT NULL,
    [FKIdFactura_PRES]         INT            NOT NULL,
    [FKIdContratoDetalle_PRES] INT            NOT NULL,
    [FKIdPartida_CONTA]        INT            NOT NULL,
    [MontoAplicado]            [dbo].[dmoney] NOT NULL,
    [Observaciones]            NVARCHAR (500) NULL,
    [Activo]                   BIT            NOT NULL,
    [FechaCreacion]            DATETIME2 (7)  NULL,
    [UsuarioCreacion]          INT            NOT NULL,
    [FechaModificacion]        DATETIME2 (7)  NULL,
    [UsuarioModificacion]      INT            NULL,
    CONSTRAINT [PK_FacturaDetalle] PRIMARY KEY CLUSTERED ([PKIdFacturaDetalle] ASC)
);


GO
PRINT N'Creando Índice [PRES].[FacturaDetalle].[IX_FacturaDetalle_ContratoDetalle]...';


GO
CREATE NONCLUSTERED INDEX [IX_FacturaDetalle_ContratoDetalle]
    ON [PRES].[FacturaDetalle]([FKIdContratoDetalle_PRES] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Índice [PRES].[FacturaDetalle].[IX_FacturaDetalle_Factura]...';


GO
CREATE NONCLUSTERED INDEX [IX_FacturaDetalle_Factura]
    ON [PRES].[FacturaDetalle]([FKIdFactura_PRES] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Tabla [PRES].[Resultado]...';


GO
CREATE TABLE [PRES].[Resultado] (
    [PKIdResultado]       INT            IDENTITY (1, 1) NOT NULL,
    [Clave]               NVARCHAR (2)   NOT NULL,
    [Descripcion]         NVARCHAR (200) NOT NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_Resultado] PRIMARY KEY CLUSTERED ([PKIdResultado] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[CLC]...';


GO
CREATE TABLE [PRES].[CLC] (
    [PKIdCLC]             INT            IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]     INT            NOT NULL,
    [FKIdContrato_PRES]   INT            NOT NULL,
    [FKIdPoliza_CONTA]    INT            NOT NULL,
    [NumCLC]              NVARCHAR (20)  NOT NULL,
    [FechaSolicitud]      DATE           NOT NULL,
    [FechaAutorizacion]   DATE           NULL,
    [ImporteTotal]        [dbo].[dmoney] NOT NULL,
    [Observaciones]       NVARCHAR (500) NULL,
    [Estatus]             INT            NOT NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_CLC] PRIMARY KEY CLUSTERED ([PKIdCLC] ASC)
);


GO
PRINT N'Creando Índice [PRES].[CLC].[IX_CLC_NumCLC]...';


GO
CREATE NONCLUSTERED INDEX [IX_CLC_NumCLC]
    ON [PRES].[CLC]([NumCLC] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Índice [PRES].[CLC].[IX_CLC_Contrato]...';


GO
CREATE NONCLUSTERED INDEX [IX_CLC_Contrato]
    ON [PRES].[CLC]([FKIdContrato_PRES] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Tabla [PRES].[GF]...';


GO
CREATE TABLE [PRES].[GF] (
    [PKIdGF]              INT           IDENTITY (1, 1) NOT NULL,
    [Clave]               INT           NOT NULL,
    [Descripcion]         NVARCHAR (30) NOT NULL,
    [Activo]              BIT           NOT NULL,
    [FechaCreacion]       DATETIME2 (7) NULL,
    [UsuarioCreacion]     INT           NOT NULL,
    [FechaModificacion]   DATETIME2 (7) NULL,
    [UsuarioModificacion] INT           NULL,
    CONSTRAINT [PK_GF] PRIMARY KEY CLUSTERED ([PKIdGF] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[Finalidad]...';


GO
CREATE TABLE [PRES].[Finalidad] (
    [PKIdFinalidad]       INT            IDENTITY (1, 1) NOT NULL,
    [Clave]               NVARCHAR (2)   NOT NULL,
    [Descripcion]         NVARCHAR (200) NOT NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_Finalidad] PRIMARY KEY CLUSTERED ([PKIdFinalidad] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[SubSector]...';


GO
CREATE TABLE [PRES].[SubSector] (
    [PKIdSubSector]       INT            IDENTITY (1, 1) NOT NULL,
    [Clave]               NVARCHAR (2)   NOT NULL,
    [Descripcion]         NVARCHAR (200) NOT NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_SubSector] PRIMARY KEY CLUSTERED ([PKIdSubSector] ASC)
);


GO
PRINT N'Creando Tabla [PRES].[ContratoDetalle]...';


GO
CREATE TABLE [PRES].[ContratoDetalle] (
    [PKIdContratoDetalle]                     INT            IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]                         INT            NOT NULL,
    [FKIdContrato_PRES]                       INT            NOT NULL,
    [FKIdAutorizacionSuficienciaDetalle_PRES] INT            NOT NULL,
    [FKIdPartida_CONTA]                       INT            NOT NULL,
    [Enero]                                   [dbo].[dmoney] NULL,
    [Febrero]                                 [dbo].[dmoney] NULL,
    [Marzo]                                   [dbo].[dmoney] NULL,
    [Abril]                                   [dbo].[dmoney] NULL,
    [Mayo]                                    [dbo].[dmoney] NULL,
    [Junio]                                   [dbo].[dmoney] NULL,
    [Julio]                                   [dbo].[dmoney] NULL,
    [Agosto]                                  [dbo].[dmoney] NULL,
    [Septiembre]                              [dbo].[dmoney] NULL,
    [Octubre]                                 [dbo].[dmoney] NULL,
    [Noviembre]                               [dbo].[dmoney] NULL,
    [Diciembre]                               [dbo].[dmoney] NULL,
    [Total]                                   AS             (((((((((((isnull([Enero], (0)) + isnull([Febrero], (0))) + isnull([Marzo], (0))) + isnull([Abril], (0))) + isnull([Mayo], (0))) + isnull([Junio], (0))) + isnull([Julio], (0))) + isnull([Agosto], (0))) + isnull([Septiembre], (0))) + isnull([Octubre], (0))) + isnull([Noviembre], (0))) + isnull([Diciembre], (0))),
    [Observaciones]                           NVARCHAR (500) NULL,
    [Activo]                                  BIT            NOT NULL,
    [FechaCreacion]                           DATETIME2 (7)  NULL,
    [UsuarioCreacion]                         INT            NOT NULL,
    [FechaModificacion]                       DATETIME2 (7)  NULL,
    [UsuarioModificacion]                     INT            NULL,
    CONSTRAINT [PK_ContratoDetalle] PRIMARY KEY CLUSTERED ([PKIdContratoDetalle] ASC)
);


GO
PRINT N'Creando Índice [PRES].[ContratoDetalle].[IX_ContratoDetalle_AutorizacionDetalle]...';


GO
CREATE NONCLUSTERED INDEX [IX_ContratoDetalle_AutorizacionDetalle]
    ON [PRES].[ContratoDetalle]([FKIdAutorizacionSuficienciaDetalle_PRES] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Índice [PRES].[ContratoDetalle].[IX_ContratoDetalle_Contrato]...';


GO
CREATE NONCLUSTERED INDEX [IX_ContratoDetalle_Contrato]
    ON [PRES].[ContratoDetalle]([FKIdContrato_PRES] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Tabla [PRES].[DestinoGasto]...';


GO
CREATE TABLE [PRES].[DestinoGasto] (
    [PKIdDestinoGasto]    INT            IDENTITY (1, 1) NOT NULL,
    [Clave]               NVARCHAR (2)   NOT NULL,
    [Descripcion]         NVARCHAR (250) NOT NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_DestinoGasto] PRIMARY KEY CLUSTERED ([PKIdDestinoGasto] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[Proveedor]...';


GO
CREATE TABLE [SIS].[Proveedor] (
    [PKIdProveedor]            INT            IDENTITY (1, 1) NOT NULL,
    [FkIdTipoProveedor_SIS]    INT            NULL,
    [FKIdEstatusProveedor_SIS] INT            NULL,
    [FKIdCuentaContable_SIS]   INT            NULL,
    [FKIdMunicipio_SIS]        INT            NOT NULL,
    [FKIdEstado_SIS]           INT            NOT NULL,
    [FKIdPais_SIS]             INT            NOT NULL,
    [FKIdResponsable_SIS]      INT            NULL,
    [FKIdAESector_SIS]         INT            NULL,
    [FKIdAEDivision_SIS]       INT            NULL,
    [FKIdAEGrupo_SIS]          INT            NULL,
    [FKIdAEClase_SIS]          INT            NULL,
    [Nombre]                   NVARCHAR (500) NOT NULL,
    [RFC]                      NVARCHAR (50)  NULL,
    [Colonia]                  NVARCHAR (50)  NULL,
    [CP]                       NVARCHAR (50)  NULL,
    [Ciudad]                   NVARCHAR (50)  NULL,
    [EMAIL]                    NVARCHAR (50)  NULL,
    [Clave]                    NVARCHAR (10)  NOT NULL,
    [Calle]                    NVARCHAR (50)  NULL,
    [Numero]                   NVARCHAR (10)  NULL,
    [FechaAlta]                DATETIME       NULL,
    [TelefonoInstitucional]    NVARCHAR (20)  NULL,
    [Notas]                    NVARCHAR (MAX) NULL,
    [PaginaWeb]                NVARCHAR (100) NULL,
    [NumeroInt]                NVARCHAR (10)  NULL,
    [CURP]                     NVARCHAR (18)  NULL,
    [Activo]                   BIT            NOT NULL,
    [FechaCreacion]            DATETIME       NULL,
    [UsuarioCreacion]          INT            NOT NULL,
    [FechaModificacion]        DATETIME       NULL,
    [UsuarioModificacion]      INT            NULL,
    CONSTRAINT [PK_Proveedor] PRIMARY KEY CLUSTERED ([PKIdProveedor] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[UsuarioDepartamento]...';


GO
CREATE TABLE [SIS].[UsuarioDepartamento] (
    [FKIdUsuario_SIS]      INT           NOT NULL,
    [FKIdDepartamento_SIS] INT           NOT NULL,
    [EsJefe]               BIT           NOT NULL,
    [FechaAsignacion]      DATETIME2 (7) NOT NULL,
    [FechaFinAsignacion]   DATETIME2 (7) NULL,
    [Activo]               BIT           NOT NULL,
    [FechaCreacion]        DATETIME2 (7) NULL,
    [UsuarioCreacion]      INT           NOT NULL,
    [FechaModificacion]    DATETIME2 (7) NULL,
    [UsuarioModificacion]  INT           NULL,
    CONSTRAINT [PK_UsuarioDepartamento] PRIMARY KEY CLUSTERED ([FKIdUsuario_SIS] ASC, [FKIdDepartamento_SIS] ASC, [FechaAsignacion] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[CatTipoSucursal]...';


GO
CREATE TABLE [SIS].[CatTipoSucursal] (
    [PKIdTipoSucursal] INT           IDENTITY (1, 1) NOT NULL,
    [Descripcion]      NVARCHAR (50) NOT NULL,
    [Activo]           BIT           NOT NULL,
    CONSTRAINT [PK_TipoSucursal] PRIMARY KEY CLUSTERED ([PKIdTipoSucursal] ASC),
    CONSTRAINT [UQ_TipoSucursal_Descripcion] UNIQUE NONCLUSTERED ([Descripcion] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[EmpresaEstado]...';


GO
CREATE TABLE [SIS].[EmpresaEstado] (
    [FKIdEmpresa_SIS]    INT  NOT NULL,
    [FKIdEstado_SIS]     INT  NOT NULL,
    [FechaApertura]      DATE NULL,
    [EsOficinaPrincipal] BIT  NOT NULL,
    [Activo]             BIT  NOT NULL,
    CONSTRAINT [PK_EmpresaEstado] PRIMARY KEY CLUSTERED ([FKIdEmpresa_SIS] ASC, [FKIdEstado_SIS] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[Menu]...';


GO
CREATE TABLE [SIS].[Menu] (
    [PKIdMenu]             INT            IDENTITY (1, 1) NOT NULL,
    [Nombre]               NVARCHAR (150) NOT NULL,
    [Tipo]                 INT            NOT NULL,
    [FKIdMenu_SIS]         INT            NULL,
    [LegacyName]           NVARCHAR (80)  NULL,
    [Ruta]                 NVARCHAR (200) NULL,
    [ImageUrl]             NVARCHAR (120) NULL,
    [Lenguaje]             CHAR (3)       NOT NULL,
    [Orden]                INT            NULL,
    [Activo]               BIT            NOT NULL,
    [CreatedByOperatorId]  INT            NULL,
    [CreatedDateTime]      DATETIME       NOT NULL,
    [ModifiedByOperatorId] INT            NULL,
    [ModifiedDateTime]     DATETIME       NULL,
    CONSTRAINT [CONSTRAINT_PK_Menu] PRIMARY KEY CLUSTERED ([PKIdMenu] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[Anio]...';


GO
CREATE TABLE [SIS].[Anio] (
    [PKIdAnio]            INT           IDENTITY (1, 1) NOT NULL,
    [Clave]               INT           NOT NULL,
    [Activo]              BIT           NOT NULL,
    [FechaCreacion]       DATETIME2 (7) NULL,
    [UsuarioCreacion]     INT           NOT NULL,
    [FechaModificacion]   DATETIME2 (7) NULL,
    [UsuarioModificacion] INT           NULL,
    CONSTRAINT [PK_Anio] PRIMARY KEY CLUSTERED ([PKIdAnio] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[Usuario]...';


GO
CREATE TABLE [SIS].[Usuario] (
    [PkIdUsuario]             INT            IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]         INT            NULL,
    [FKIdPersona_NOM]         INT            NULL,
    [AspNetUserId]            NVARCHAR (450) NOT NULL,
    [PayrollID]               NVARCHAR (20)  NOT NULL,
    [FKIdIdiomaPreferido_SIS] INT            NULL,
    [FKIdMonedaPreferida_SIS] INT            NULL,
    [EsAdministrador]         BIT            NOT NULL,
    [Activo]                  BIT            NOT NULL,
    [FechaCreacion]           DATETIME2 (7)  NULL,
    [UsuarioCreacion]         INT            NULL,
    [FechaModificacion]       DATETIME2 (7)  NULL,
    [UsuarioModificacion]     INT            NULL,
    CONSTRAINT [PK_Usuario] PRIMARY KEY CLUSTERED ([PkIdUsuario] ASC),
    CONSTRAINT [UQ_Usuario_AspNetUserId] UNIQUE NONCLUSTERED ([AspNetUserId] ASC),
    CONSTRAINT [UQ_Usuario_PayrollID] UNIQUE NONCLUSTERED ([PayrollID] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[PerfilUsuario]...';


GO
CREATE TABLE [SIS].[PerfilUsuario] (
    [FKIdUsuario_SIS]     INT             NOT NULL,
    [Fotografia]          VARBINARY (MAX) NULL,
    [ContentType]         NVARCHAR (50)   NULL,
    [FileName]            NVARCHAR (64)   NULL,
    [FileExtension]       NVARCHAR (8)    NULL,
    [Activo]              BIT             NOT NULL,
    [FechaCreacion]       DATETIME2 (7)   NULL,
    [UsuarioCreacion]     INT             NOT NULL,
    [FechaModificacion]   DATETIME2 (7)   NULL,
    [UsuarioModificacion] INT             NULL,
    PRIMARY KEY CLUSTERED ([FKIdUsuario_SIS] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[Municipios]...';


GO
CREATE TABLE [SIS].[Municipios] (
    [PKIdMunicipio]   INT           IDENTITY (1, 1) NOT NULL,
    [FKIdEstado_SIS]  INT           NOT NULL,
    [Nombre]          VARCHAR (100) NOT NULL,
    [CodigoMunicipio] VARCHAR (10)  NULL,
    [Activo]          BIT           NOT NULL,
    [FechaCreacion]   DATETIME2 (7) NULL,
    CONSTRAINT [PK_Municipios] PRIMARY KEY CLUSTERED ([PKIdMunicipio] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[TipoProveedor]...';


GO
CREATE TABLE [SIS].[TipoProveedor] (
    [PkIdTipoProveedor]   INT          IDENTITY (1, 1) NOT NULL,
    [Descripcion]         VARCHAR (80) NOT NULL,
    [Activo]              BIT          NOT NULL,
    [FechaCreacion]       DATETIME     NULL,
    [UsuarioCreacion]     INT          NOT NULL,
    [FechaModificacion]   DATETIME     NULL,
    [UsuarioModificacion] INT          NULL,
    CONSTRAINT [PK_TipoProveedor] PRIMARY KEY CLUSTERED ([PkIdTipoProveedor] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[ActividadInstitucional]...';


GO
CREATE TABLE [SIS].[ActividadInstitucional] (
    [PKIdActividadInstitucional] INT           IDENTITY (1, 1) NOT NULL,
    [Clave]                      NVARCHAR (3)  NOT NULL,
    [Descripcion]                NVARCHAR (64) NOT NULL,
    [Activo]                     BIT           NOT NULL,
    [FechaCreacion]              DATETIME2 (7) NULL,
    [UsuarioCreacion]            INT           NOT NULL,
    [FechaModificacion]          DATETIME2 (7) NULL,
    [UsuarioModificacion]        INT           NULL,
    CONSTRAINT [PK_ActividadInstitucional] PRIMARY KEY CLUSTERED ([PKIdActividadInstitucional] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[EstatusProveedor]...';


GO
CREATE TABLE [SIS].[EstatusProveedor] (
    [PKIdEstatusProveedor] INT            IDENTITY (1, 1) NOT NULL,
    [Descripcion]          NVARCHAR (150) NOT NULL,
    [Color]                NVARCHAR (8)   NULL,
    [Activo]               BIT            NOT NULL,
    [FechaCreacion]        DATETIME       NULL,
    [UsuarioCreacion]      INT            NOT NULL,
    [FechaModificacion]    DATETIME       NULL,
    [UsuarioModificacion]  INT            NULL,
    CONSTRAINT [PK_EstatusProveedor] PRIMARY KEY CLUSTERED ([PKIdEstatusProveedor] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[UsuarioSucursal]...';


GO
CREATE TABLE [SIS].[UsuarioSucursal] (
    [FKIdUsuario_SIS]     INT           NOT NULL,
    [FKIdSucursal_SIS]    INT           NOT NULL,
    [PuedeAcceder]        BIT           NOT NULL,
    [PuedeConfigurar]     BIT           NOT NULL,
    [PuedeOperar]         BIT           NOT NULL,
    [PuedeReportes]       BIT           NOT NULL,
    [EsGerente]           BIT           NOT NULL,
    [EsSupervisor]        BIT           NOT NULL,
    [FechaAsignacion]     DATETIME2 (7) NULL,
    [FechaFinAsignacion]  DATETIME2 (7) NULL,
    [Activo]              BIT           NOT NULL,
    [FechaCreacion]       DATETIME2 (7) NULL,
    [UsuarioCreacion]     INT           NOT NULL,
    [FechaModificacion]   DATETIME2 (7) NULL,
    [UsuarioModificacion] INT           NULL,
    CONSTRAINT [PK_UsuarioSucursal] PRIMARY KEY CLUSTERED ([FKIdUsuario_SIS] ASC, [FKIdSucursal_SIS] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[SystemParamValue]...';


GO
CREATE TABLE [SIS].[SystemParamValue] (
    [PKIdSystemParamValue]       INT            NOT NULL,
    [FKIdSystemParamCatalog_SIS] INT            NOT NULL,
    [Value]                      NVARCHAR (MAX) NOT NULL,
    [Descripcion]                VARCHAR (128)  NOT NULL,
    [Activo]                     BIT            NOT NULL,
    [FechaCreacion]              DATETIME2 (7)  NULL,
    [UsuarioCreacion]            INT            NOT NULL,
    [FechaModificacion]          DATETIME2 (7)  NULL,
    [UsuarioModificacion]        INT            NULL,
    CONSTRAINT [CONSTRAINT_PK_SystemParamValue] PRIMARY KEY CLUSTERED ([PKIdSystemParamValue] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[Capitulo]...';


GO
CREATE TABLE [SIS].[Capitulo] (
    [PKIdCapitulo]        INT            IDENTITY (1, 1) NOT NULL,
    [Clave]               NVARCHAR (30)  NULL,
    [Descripcion]         NVARCHAR (120) NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_Capitulo] PRIMARY KEY CLUSTERED ([PKIdCapitulo] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[Idioma]...';


GO
CREATE TABLE [SIS].[Idioma] (
    [PKIdIdioma]     INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]         NVARCHAR (50) NOT NULL,
    [CodigoISO639_1] CHAR (2)      NOT NULL,
    [NombreNativo]   NVARCHAR (50) NULL,
    [Activo]         BIT           NOT NULL,
    CONSTRAINT [PK_Idioma] PRIMARY KEY CLUSTERED ([PKIdIdioma] ASC),
    CONSTRAINT [UQ_Idioma_Codigo] UNIQUE NONCLUSTERED ([CodigoISO639_1] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[TipoPoliza]...';


GO
CREATE TABLE [SIS].[TipoPoliza] (
    [PKIdTipoPoliza]      INT           IDENTITY (1, 1) NOT NULL,
    [Descripcion]         NVARCHAR (25) NOT NULL,
    [Activo]              BIT           NOT NULL,
    [FechaCreacion]       DATETIME2 (7) NULL,
    [UsuarioCreacion]     INT           NOT NULL,
    [FechaModificacion]   DATETIME2 (7) NULL,
    [UsuarioModificacion] INT           NULL,
    CONSTRAINT [PK_TipoPoliza] PRIMARY KEY CLUSTERED ([PKIdTipoPoliza] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[OrigenLogMessage]...';


GO
CREATE TABLE [SIS].[OrigenLogMessage] (
    [PKIdOrigenLogMessage] INT           NOT NULL,
    [Descripcion]          NVARCHAR (50) NULL,
    [Activo]               BIT           NOT NULL,
    [FechaCreacion]        DATETIME2 (7) NULL,
    [UsuarioCreacion]      INT           NOT NULL,
    [FechaModificacion]    DATETIME2 (7) NULL,
    [UsuarioModificacion]  INT           NULL,
    CONSTRAINT [CONSTRAINT_PK_OrigenLogMessage] PRIMARY KEY CLUSTERED ([PKIdOrigenLogMessage] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[Estados]...';


GO
CREATE TABLE [SIS].[Estados] (
    [PKIdEstado]   INT          IDENTITY (1, 1) NOT NULL,
    [FKIdPais_SIS] INT          NOT NULL,
    [Nombre]       VARCHAR (64) NOT NULL,
    [CodigoEstado] VARCHAR (10) NULL,
    [Activo]       BIT          NOT NULL,
    CONSTRAINT [PK_Estados] PRIMARY KEY CLUSTERED ([PKIdEstado] ASC),
    CONSTRAINT [UQ_Estados_Pais_Nombre] UNIQUE NONCLUSTERED ([FKIdPais_SIS] ASC, [Nombre] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[SystemLog]...';


GO
CREATE TABLE [SIS].[SystemLog] (
    [PKIdSystemLog]            INT             IDENTITY (1, 1) NOT NULL,
    [FKIdOrigenLogMessage_SIS] INT             NOT NULL,
    [Date]                     DATETIME2 (7)   NULL,
    [Type]                     NVARCHAR (24)   NULL,
    [ProgName]                 NVARCHAR (256)  NULL,
    [EmployeeNo]               NVARCHAR (24)   NULL,
    [Category]                 NVARCHAR (24)   NULL,
    [IPClient]                 NVARCHAR (24)   NULL,
    [HostName]                 NVARCHAR (32)   NULL,
    [Thread]                   VARCHAR (255)   NULL,
    [Level]                    VARCHAR (20)    NULL,
    [Logger]                   VARCHAR (255)   NULL,
    [Message]                  VARCHAR (4000)  NULL,
    [Exception]                NVARCHAR (4000) NULL,
    [Context]                  NVARCHAR (10)   NULL,
    [MethodName]               NVARCHAR (200)  NULL,
    [Parameters]               NVARCHAR (4000) NULL,
    [ExecutionTime]            INT             NULL,
    CONSTRAINT [CONSTRAINT_PK_SystemLog] PRIMARY KEY CLUSTERED ([PKIdSystemLog] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[TipoDetallePoliza]...';


GO
CREATE TABLE [SIS].[TipoDetallePoliza] (
    [PkIdTipoDetallePoliza] INT           IDENTITY (1, 1) NOT NULL,
    [Descripcion]           NVARCHAR (25) NOT NULL,
    [Activo]                BIT           NOT NULL,
    [FechaCreacion]         DATETIME2 (7) NULL,
    [UsuarioCreacion]       INT           NOT NULL,
    [FechaModificacion]     DATETIME2 (7) NULL,
    [UsuarioModificacion]   INT           NULL,
    CONSTRAINT [PK_TipoDetallePoliza] PRIMARY KEY CLUSTERED ([PkIdTipoDetallePoliza] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[SystemParamCatalog]...';


GO
CREATE TABLE [SIS].[SystemParamCatalog] (
    [PKIdSystemParamCatalog] INT           NOT NULL,
    [Code]                   NVARCHAR (50) NOT NULL,
    [Name]                   VARCHAR (100) NOT NULL,
    [Activo]                 BIT           NOT NULL,
    [FechaCreacion]          DATETIME2 (7) NULL,
    [UsuarioCreacion]        INT           NOT NULL,
    [FechaModificacion]      DATETIME2 (7) NULL,
    [UsuarioModificacion]    INT           NULL,
    CONSTRAINT [CONSTRAINT_PK_SystemParamCatalog] PRIMARY KEY CLUSTERED ([PKIdSystemParamCatalog] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[Paises]...';


GO
CREATE TABLE [SIS].[Paises] (
    [PKIdPais]                INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]                  VARCHAR (64)  NOT NULL,
    [CodigoISO2]              CHAR (2)      NOT NULL,
    [CodigoISO3]              CHAR (3)      NOT NULL,
    [FKIdIdiomaPrincipal_SIS] INT           NULL,
    [FKIdMonedaPrincipal_SIS] INT           NULL,
    [Activo]                  BIT           NOT NULL,
    [FechaCreacion]           DATETIME2 (7) NULL,
    CONSTRAINT [PK_Paises] PRIMARY KEY CLUSTERED ([PKIdPais] ASC),
    CONSTRAINT [UQ_Paises_CodigoISO2] UNIQUE NONCLUSTERED ([CodigoISO2] ASC),
    CONSTRAINT [UQ_Paises_CodigoISO3] UNIQUE NONCLUSTERED ([CodigoISO3] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[MenuRole]...';


GO
CREATE TABLE [SIS].[MenuRole] (
    [FKIdMenu_SIS]         INT            NOT NULL,
    [RoleId]               NVARCHAR (128) NOT NULL,
    [Activo]               BIT            NOT NULL,
    [CreatedByOperatorId]  INT            NULL,
    [CreatedDateTime]      DATETIME       NOT NULL,
    [ModifiedByOperatorId] INT            NULL,
    [ModifiedDateTime]     DATETIME       NULL,
    CONSTRAINT [CONSTRAINT_PK_MenuRole] PRIMARY KEY CLUSTERED ([FKIdMenu_SIS] ASC, [RoleId] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[Banco]...';


GO
CREATE TABLE [SIS].[Banco] (
    [PKIdBanco]           INT            IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]     INT            NOT NULL,
    [Clave]               NVARCHAR (10)  NOT NULL,
    [Nombre]              NVARCHAR (200) NOT NULL,
    [NombreCorto]         NVARCHAR (50)  NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_Banco] PRIMARY KEY CLUSTERED ([PKIdBanco] ASC)
);


GO
PRINT N'Creando Índice [SIS].[Banco].[IX_Banco_Clave]...';


GO
CREATE NONCLUSTERED INDEX [IX_Banco_Clave]
    ON [SIS].[Banco]([Clave] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Índice [SIS].[Banco].[IX_Banco_Empresa]...';


GO
CREATE NONCLUSTERED INDEX [IX_Banco_Empresa]
    ON [SIS].[Banco]([FKIdEmpresa_SIS] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Tabla [SIS].[Empresa]...';


GO
CREATE TABLE [SIS].[Empresa] (
    [PKIdEmpresa]             INT             IDENTITY (1, 1) NOT NULL,
    [Nombre]                  NVARCHAR (128)  NOT NULL,
    [RFC]                     NVARCHAR (13)   NOT NULL,
    [RazonSocial]             NVARCHAR (255)  NULL,
    [Giro]                    NVARCHAR (100)  NULL,
    [FKIdMonedaBase_SIS]      INT             NOT NULL,
    [FKIdIdiomaPreferido_SIS] INT             NULL,
    [Logo]                    VARBINARY (MAX) NULL,
    [Activo]                  BIT             NOT NULL,
    [FechaCreacion]           DATETIME2 (7)   NULL,
    [UsuarioCreacion]         INT             NULL,
    [FechaModificacion]       DATETIME2 (7)   NULL,
    [UsuarioModificacion]     INT             NULL,
    CONSTRAINT [PK_Empresa] PRIMARY KEY CLUSTERED ([PKIdEmpresa] ASC),
    CONSTRAINT [UQ_Empresa_RFC] UNIQUE NONCLUSTERED ([RFC] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[Departamento]...';


GO
CREATE TABLE [SIS].[Departamento] (
    [PKIdDepartamento]    INT            IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]     INT            NOT NULL,
    [FKIdSucursal_SIS]    INT            NULL,
    [Nombre]              NVARCHAR (128) NOT NULL,
    [Descripcion]         NVARCHAR (255) NULL,
    [NivelJerarquico]     INT            NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_Departamento] PRIMARY KEY CLUSTERED ([PKIdDepartamento] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[Concepto]...';


GO
CREATE TABLE [SIS].[Concepto] (
    [PKIdConcepto]        INT            IDENTITY (1, 1) NOT NULL,
    [FKIdCapitulo_SIS]    INT            NOT NULL,
    [Clave]               NVARCHAR (30)  NULL,
    [Descripcion]         NVARCHAR (120) NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_Concepto] PRIMARY KEY CLUSTERED ([PKIdConcepto] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[Partida]...';


GO
CREATE TABLE [SIS].[Partida] (
    [PKIdPartida]         INT            IDENTITY (1, 1) NOT NULL,
    [FKIdConcepto_SIS]    INT            NULL,
    [Clave]               NVARCHAR (10)  NOT NULL,
    [Descripcion]         NVARCHAR (255) NOT NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_Partida] PRIMARY KEY CLUSTERED ([PKIdPartida] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[Area]...';


GO
CREATE TABLE [SIS].[Area] (
    [PKIdArea]            INT            IDENTITY (1, 1) NOT NULL,
    [FKIdArea_SIS]        INT            NULL,
    [FKIdAreaDocto_SIS]   INT            NULL,
    [Clave]               NVARCHAR (15)  NOT NULL,
    [Nombre]              NVARCHAR (200) NOT NULL,
    [UltimoInv]           DATETIME       NULL,
    [ZonaEconomica]       NVARCHAR (100) NULL,
    [Direccion]           NVARCHAR (64)  NULL,
    [Colonia]             NVARCHAR (64)  NULL,
    [CP]                  NVARCHAR (5)   NULL,
    [Telefono]            NVARCHAR (32)  NULL,
    [Aprovado]            BIT            NOT NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_Area] PRIMARY KEY CLUSTERED ([PKIdArea] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[TipoDoctoCLC]...';


GO
CREATE TABLE [SIS].[TipoDoctoCLC] (
    [PKIdTipoDoctoCLC]    INT           IDENTITY (1, 1) NOT NULL,
    [Clave]               NVARCHAR (50) NOT NULL,
    [Nombre]              NVARCHAR (50) NOT NULL,
    [TipoRecurso]         VARCHAR (1)   NULL,
    [Activo]              BIT           NOT NULL,
    [FechaCreacion]       DATETIME2 (7) NULL,
    [UsuarioCreacion]     INT           NOT NULL,
    [FechaModificacion]   DATETIME2 (7) NULL,
    [UsuarioModificacion] INT           NULL,
    CONSTRAINT [PK_TipoDoctoCLC] PRIMARY KEY CLUSTERED ([PKIdTipoDoctoCLC] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[Moneda]...';


GO
CREATE TABLE [SIS].[Moneda] (
    [PKIdMoneda]    INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]        NVARCHAR (50) NOT NULL,
    [CodigoISO4217] CHAR (3)      NOT NULL,
    [Simbolo]       NVARCHAR (5)  NOT NULL,
    [Decimales]     INT           NOT NULL,
    [Activo]        BIT           NOT NULL,
    CONSTRAINT [PK_Moneda] PRIMARY KEY CLUSTERED ([PKIdMoneda] ASC),
    CONSTRAINT [UQ_Moneda_Codigo] UNIQUE NONCLUSTERED ([CodigoISO4217] ASC)
);


GO
PRINT N'Creando Tabla [SIS].[Sucursal]...';


GO
CREATE TABLE [SIS].[Sucursal] (
    [PKIdSucursal]        INT            IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]     INT            NOT NULL,
    [FKIdEstado_SIS]      INT            NOT NULL,
    [Nombre]              NVARCHAR (128) NOT NULL,
    [CodigoSucursal]      NVARCHAR (20)  NOT NULL,
    [Alias]               NVARCHAR (50)  NULL,
    [FKIdTipoSucursal]    INT            NOT NULL,
    [FKIdMonedaLocal_SIS] INT            NULL,
    [Direccion]           NVARCHAR (256) NOT NULL,
    [Colonia]             NVARCHAR (100) NULL,
    [Ciudad]              NVARCHAR (100) NULL,
    [CodigoPostal]        NVARCHAR (10)  NULL,
    [TelefonoPrincipal]   NVARCHAR (20)  NULL,
    [TelefonoSecundario]  NVARCHAR (20)  NULL,
    [Email]               NVARCHAR (100) NULL,
    [HorarioApertura]     TIME (7)       NULL,
    [HorarioCierre]       TIME (7)       NULL,
    [EsMatriz]            BIT            NOT NULL,
    [EsActiva]            BIT            NOT NULL,
    [Latitud]             DECIMAL (9, 6) NULL,
    [Longitud]            DECIMAL (9, 6) NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_Sucursal] PRIMARY KEY CLUSTERED ([PKIdSucursal] ASC),
    CONSTRAINT [UQ_Sucursal_Codigo] UNIQUE NONCLUSTERED ([CodigoSucursal] ASC)
);


GO
PRINT N'Creando Tabla [TES].[TipoPagoSF]...';


GO
CREATE TABLE [TES].[TipoPagoSF] (
    [PKIdTipoPagoSF]      INT           IDENTITY (1, 1) NOT NULL,
    [Descripcion]         NVARCHAR (50) NOT NULL,
    [Activo]              BIT           NOT NULL,
    [FechaCreacion]       DATETIME2 (7) NULL,
    [UsuarioCreacion]     INT           NOT NULL,
    [FechaModificacion]   DATETIME2 (7) NULL,
    [UsuarioModificacion] INT           NULL,
    CONSTRAINT [PK_TipoPagoSF] PRIMARY KEY CLUSTERED ([PKIdTipoPagoSF] ASC)
);


GO
PRINT N'Creando Tabla [TES].[TipoInversion]...';


GO
CREATE TABLE [TES].[TipoInversion] (
    [PKIdTipoInversion]   INT           IDENTITY (1, 1) NOT NULL,
    [Descripcion]         NVARCHAR (50) NOT NULL,
    [Activo]              BIT           NOT NULL,
    [FechaCreacion]       DATETIME2 (7) NULL,
    [UsuarioCreacion]     INT           NOT NULL,
    [FechaModificacion]   DATETIME2 (7) NULL,
    [UsuarioModificacion] INT           NULL,
    CONSTRAINT [PK_TipoInversion] PRIMARY KEY CLUSTERED ([PKIdTipoInversion] ASC)
);


GO
PRINT N'Creando Tabla [TES].[TipoSolicitudCLC]...';


GO
CREATE TABLE [TES].[TipoSolicitudCLC] (
    [PKIdTipoSolicitudCLC] INT           IDENTITY (1, 1) NOT NULL,
    [Descripcion]          NVARCHAR (50) NOT NULL,
    [Activo]               BIT           NOT NULL,
    [FechaCreacion]        DATETIME2 (7) NULL,
    [UsuarioCreacion]      INT           NOT NULL,
    [FechaModificacion]    DATETIME2 (7) NULL,
    [UsuarioModificacion]  INT           NULL,
    CONSTRAINT [PK_TipoSolicitudCLC] PRIMARY KEY CLUSTERED ([PKIdTipoSolicitudCLC] ASC)
);


GO
PRINT N'Creando Tabla [TES].[TipoPago]...';


GO
CREATE TABLE [TES].[TipoPago] (
    [PKIdTipoPago]        INT           IDENTITY (1, 1) NOT NULL,
    [Descripcion]         NVARCHAR (50) NOT NULL,
    [Activo]              BIT           NOT NULL,
    [FechaCreacion]       DATETIME2 (7) NULL,
    [UsuarioCreacion]     INT           NOT NULL,
    [FechaModificacion]   DATETIME2 (7) NULL,
    [UsuarioModificacion] INT           NULL,
    CONSTRAINT [PK_TipoPago] PRIMARY KEY CLUSTERED ([PKIdTipoPago] ASC)
);


GO
PRINT N'Creando Tabla [TES].[TipoMoneda]...';


GO
CREATE TABLE [TES].[TipoMoneda] (
    [PKIdTipoMoneda]      INT           IDENTITY (1, 1) NOT NULL,
    [FKIdPais_SIS]        INT           NOT NULL,
    [Descripcion]         NVARCHAR (50) NOT NULL,
    [CodigoISO4217]       CHAR (3)      NULL,
    [Simbolo]             NVARCHAR (5)  NULL,
    [Decimales]           INT           NOT NULL,
    [Activo]              BIT           NOT NULL,
    [FechaCreacion]       DATETIME2 (7) NULL,
    [UsuarioCreacion]     INT           NOT NULL,
    [FechaModificacion]   DATETIME2 (7) NULL,
    [UsuarioModificacion] INT           NULL,
    CONSTRAINT [PK_TipoMoneda] PRIMARY KEY CLUSTERED ([PKIdTipoMoneda] ASC)
);


GO
PRINT N'Creando Tabla [TES].[TipoCambio]...';


GO
CREATE TABLE [TES].[TipoCambio] (
    [PKIdTipoCambio]      INT             IDENTITY (1, 1) NOT NULL,
    [FKIdTipoMoneda_TES]  INT             NOT NULL,
    [Cantidad]            DECIMAL (18, 2) NOT NULL,
    [Fecha]               DATETIME        NOT NULL,
    [Activo]              BIT             NOT NULL,
    [FechaCreacion]       DATETIME2 (7)   NULL,
    [UsuarioCreacion]     INT             NOT NULL,
    [FechaModificacion]   DATETIME2 (7)   NULL,
    [UsuarioModificacion] INT             NULL,
    CONSTRAINT [PK_TipoCambio] PRIMARY KEY CLUSTERED ([PKIdTipoCambio] ASC)
);


GO
PRINT N'Creando Tabla [TES].[CuentaBancaria]...';


GO
CREATE TABLE [TES].[CuentaBancaria] (
    [PKIdCuentaBancaria]  INT            IDENTITY (1, 1) NOT NULL,
    [FKIdEmpresa_SIS]     INT            NOT NULL,
    [FKIdBanco_SIS]       INT            NULL,
    [FKIdTipoMoneda_TES]  INT            NOT NULL,
    [NumeroCuenta]        NVARCHAR (50)  NOT NULL,
    [CLABE]               NVARCHAR (18)  NULL,
    [Titular]             NVARCHAR (200) NOT NULL,
    [SaldoInicial]        [dbo].[dmoney] NOT NULL,
    [SaldoActual]         [dbo].[dmoney] NOT NULL,
    [FechaApertura]       DATE           NULL,
    [Activo]              BIT            NOT NULL,
    [FechaCreacion]       DATETIME2 (7)  NULL,
    [UsuarioCreacion]     INT            NOT NULL,
    [FechaModificacion]   DATETIME2 (7)  NULL,
    [UsuarioModificacion] INT            NULL,
    CONSTRAINT [PK_CuentaBancaria] PRIMARY KEY CLUSTERED ([PKIdCuentaBancaria] ASC)
);


GO
PRINT N'Creando Índice [TES].[CuentaBancaria].[IX_CuentaBancaria_Empresa]...';


GO
CREATE NONCLUSTERED INDEX [IX_CuentaBancaria_Empresa]
    ON [TES].[CuentaBancaria]([FKIdEmpresa_SIS] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Índice [TES].[CuentaBancaria].[IX_CuentaBancaria_Banco]...';


GO
CREATE NONCLUSTERED INDEX [IX_CuentaBancaria_Banco]
    ON [TES].[CuentaBancaria]([FKIdBanco_SIS] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Índice [TES].[CuentaBancaria].[IX_CuentaBancaria_NumeroCuenta]...';


GO
CREATE NONCLUSTERED INDEX [IX_CuentaBancaria_NumeroCuenta]
    ON [TES].[CuentaBancaria]([NumeroCuenta] ASC) WHERE ([Activo]=(1));


GO
PRINT N'Creando Tabla [dbo].[AspNetClaims]...';


GO
CREATE TABLE [dbo].[AspNetClaims] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [ClaimTypeId] INT            NULL,
    [Name]        NVARCHAR (150) NOT NULL,
    [Group]       NVARCHAR (100) NULL,
    [RoleId]      NVARCHAR (128) NULL,
    [TokenFormat] NVARCHAR (50)  NULL,
    [Created]     DATETIME       NOT NULL,
    [SubGroup]    NVARCHAR (100) NULL,
    [Code]        NVARCHAR (10)  NULL,
    [Description] NVARCHAR (200) NULL,
    [Values]      VARCHAR (MAX)  NULL,
    [ReferenceId] INT            NOT NULL,
    CONSTRAINT [CONSTRAINT_PK_AspNetClaims] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[AspNetClaimTypes]...';


GO
CREATE TABLE [dbo].[AspNetClaimTypes] (
    [Id]      INT           IDENTITY (1, 1) NOT NULL,
    [Name]    NVARCHAR (50) NOT NULL,
    [Created] DATETIME      NOT NULL,
    CONSTRAINT [CONSTRAINT_PK_AspNetClaimTypes] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[AspNetClaimValues]...';


GO
CREATE TABLE [dbo].[AspNetClaimValues] (
    [Id]      INT            IDENTITY (1, 1) NOT NULL,
    [ClaimId] INT            NULL,
    [Value]   NVARCHAR (128) NOT NULL,
    [Created] DATETIME       NOT NULL,
    CONSTRAINT [CONSTRAINT_PK_AspNetClaimValues] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[AspNetRoles]...';


GO
CREATE TABLE [dbo].[AspNetRoles] (
    [Id]   NVARCHAR (128) NOT NULL,
    [Name] NVARCHAR (256) NOT NULL,
    [Code] NVARCHAR (10)  NULL,
    CONSTRAINT [CONSTRAINT_PK_AspNetRoles] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [CONSTRAINT_UX_AspNetRoles_Name] UNIQUE NONCLUSTERED ([Name] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[AspNetUserRoles]...';


GO
CREATE TABLE [dbo].[AspNetUserRoles] (
    [UserId]     NVARCHAR (128) NOT NULL,
    [RoleId]     NVARCHAR (128) NOT NULL,
    [ExpireDate] DATETIME       NULL,
    CONSTRAINT [CONSTRAINT_PK_AspNetUserRoles] PRIMARY KEY CLUSTERED ([UserId] ASC, [RoleId] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[AspNetUsers]...';


GO
CREATE TABLE [dbo].[AspNetUsers] (
    [Id]                   NVARCHAR (128) NOT NULL,
    [Email]                NVARCHAR (256) NULL,
    [EmailConfirmed]       BIT            NOT NULL,
    [PasswordHash]         NVARCHAR (MAX) NULL,
    [SecurityStamp]        NVARCHAR (MAX) NULL,
    [PhoneNumber]          NVARCHAR (MAX) NULL,
    [PhoneNumberConfirmed] BIT            NOT NULL,
    [TwoFactorEnabled]     BIT            NOT NULL,
    [LockoutEndDateUtc]    DATETIME       NULL,
    [LockoutEnabled]       BIT            NOT NULL,
    [AccessFailedCount]    INT            NOT NULL,
    [ReferenceId]          INT            NULL,
    [AccessNumber]         NVARCHAR (25)  NULL,
    [PkIdUsuario]          INT            NULL,
    CONSTRAINT [CONSTRAINT_PK_AspNetUsers] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_EstadoBien_Activo]...';


GO
ALTER TABLE [ALMA].[EstadoBien]
    ADD CONSTRAINT [DF_EstadoBien_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_EstadoBien_FechaCreacion]...';


GO
ALTER TABLE [ALMA].[EstadoBien]
    ADD CONSTRAINT [DF_EstadoBien_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_EstatusArticuloConteo_Activo]...';


GO
ALTER TABLE [ALMA].[EstatusArticuloConteo]
    ADD CONSTRAINT [DF_EstatusArticuloConteo_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_TipoPatrimonio_FechaCreacion]...';


GO
ALTER TABLE [ALMA].[TipoPatrimonio]
    ADD CONSTRAINT [DF_TipoPatrimonio_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_TipoPatrimonio_Activo]...';


GO
ALTER TABLE [ALMA].[TipoPatrimonio]
    ADD CONSTRAINT [DF_TipoPatrimonio_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_Material_Activo]...';


GO
ALTER TABLE [ALMA].[Material]
    ADD CONSTRAINT [DF_Material_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_Material_FechaCreacion]...';


GO
ALTER TABLE [ALMA].[Material]
    ADD CONSTRAINT [DF_Material_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_ConteoDetalleEscaneo_Activo]...';


GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo]
    ADD CONSTRAINT [DF_ConteoDetalleEscaneo_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_ConteoDetalleEscaneo_FechaEscaneo]...';


GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo]
    ADD CONSTRAINT [DF_ConteoDetalleEscaneo_FechaEscaneo] DEFAULT (sysdatetime()) FOR [FechaEscaneo];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_ConteoDetalleEscaneo_FechaCreacion]...';


GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo]
    ADD CONSTRAINT [DF_ConteoDetalleEscaneo_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_Unidades_Activo]...';


GO
ALTER TABLE [ALMA].[Unidades]
    ADD CONSTRAINT [DF_Unidades_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_Unidades_FechaCreacion]...';


GO
ALTER TABLE [ALMA].[Unidades]
    ADD CONSTRAINT [DF_Unidades_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_TipoBien_FechaCreacion]...';


GO
ALTER TABLE [ALMA].[TipoBien]
    ADD CONSTRAINT [DF_TipoBien_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_TipoBien_Activo]...';


GO
ALTER TABLE [ALMA].[TipoBien]
    ADD CONSTRAINT [DF_TipoBien_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_EstatusPeriodo_Activo]...';


GO
ALTER TABLE [ALMA].[EstatusPeriodo]
    ADD CONSTRAINT [DF_EstatusPeriodo_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_TipoConteo_Activo]...';


GO
ALTER TABLE [ALMA].[TipoConteo]
    ADD CONSTRAINT [DF_TipoConteo_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_TipoAdquisicion_FechaCreacion]...';


GO
ALTER TABLE [ALMA].[TipoAdquisicion]
    ADD CONSTRAINT [DF_TipoAdquisicion_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_TipoAdquisicion_Activo]...';


GO
ALTER TABLE [ALMA].[TipoAdquisicion]
    ADD CONSTRAINT [DF_TipoAdquisicion_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_Conteo_FechaCreacion]...';


GO
ALTER TABLE [ALMA].[Conteo]
    ADD CONSTRAINT [DF_Conteo_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_Conteo_Activo]...';


GO
ALTER TABLE [ALMA].[Conteo]
    ADD CONSTRAINT [DF_Conteo_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_Familia_FechaCreacion]...';


GO
ALTER TABLE [ALMA].[Familia]
    ADD CONSTRAINT [DF_Familia_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_Familia_Activo]...';


GO
ALTER TABLE [ALMA].[Familia]
    ADD CONSTRAINT [DF_Familia_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_Bien_FechaCreacion]...';


GO
ALTER TABLE [ALMA].[Bien]
    ADD CONSTRAINT [DF_Bien_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_Bien_Activo]...';


GO
ALTER TABLE [ALMA].[Bien]
    ADD CONSTRAINT [DF_Bien_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_PeriodoConteo_ReqAprobacion]...';


GO
ALTER TABLE [ALMA].[PeriodoConteo]
    ADD CONSTRAINT [DF_PeriodoConteo_ReqAprobacion] DEFAULT ((1)) FOR [RequiereAprobacionSupervisor];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_PeriodoConteo_Activo]...';


GO
ALTER TABLE [ALMA].[PeriodoConteo]
    ADD CONSTRAINT [DF_PeriodoConteo_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_PeriodoConteo_MaxConteos]...';


GO
ALTER TABLE [ALMA].[PeriodoConteo]
    ADD CONSTRAINT [DF_PeriodoConteo_MaxConteos] DEFAULT ((3)) FOR [MaximoConteosPorArticulo];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_PeriodoConteo_FechaCreacion]...';


GO
ALTER TABLE [ALMA].[PeriodoConteo]
    ADD CONSTRAINT [DF_PeriodoConteo_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_GrupoBien_FechaCreacion]...';


GO
ALTER TABLE [ALMA].[GrupoBien]
    ADD CONSTRAINT [DF_GrupoBien_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_GrupoBien_Activo]...';


GO
ALTER TABLE [ALMA].[GrupoBien]
    ADD CONSTRAINT [DF_GrupoBien_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_EstatusSolicitud_FechaCreacion]...';


GO
ALTER TABLE [ALMA].[EstatusSolicitud]
    ADD CONSTRAINT [DF_EstatusSolicitud_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_EstatusSolicitud_Activo]...';


GO
ALTER TABLE [ALMA].[EstatusSolicitud]
    ADD CONSTRAINT [DF_EstatusSolicitud_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_ConteoHist_FechaCreacion]...';


GO
ALTER TABLE [ALMA].[ConteoHist]
    ADD CONSTRAINT [DF_ConteoHist_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_ConteoHist_Activo]...';


GO
ALTER TABLE [ALMA].[ConteoHist]
    ADD CONSTRAINT [DF_ConteoHist_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_Marca_Activo]...';


GO
ALTER TABLE [ALMA].[Marca]
    ADD CONSTRAINT [DF_Marca_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_Marca_FechaCreacion]...';


GO
ALTER TABLE [ALMA].[Marca]
    ADD CONSTRAINT [DF_Marca_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_Nivel_FechaCreacion]...';


GO
ALTER TABLE [ALMA].[Nivel]
    ADD CONSTRAINT [DF_Nivel_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_Nivel_Activo]...';


GO
ALTER TABLE [ALMA].[Nivel]
    ADD CONSTRAINT [DF_Nivel_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_ConteoDetalle_FechaCreacion]...';


GO
ALTER TABLE [ALMA].[ConteoDetalle]
    ADD CONSTRAINT [DF_ConteoDetalle_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_ConteoDetalle_Activo]...';


GO
ALTER TABLE [ALMA].[ConteoDetalle]
    ADD CONSTRAINT [DF_ConteoDetalle_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_MotivoES_FechaCreacion]...';


GO
ALTER TABLE [ALMA].[MotivoES]
    ADD CONSTRAINT [DF_MotivoES_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ALMA].[DF_MotivoES_Activo]...';


GO
ALTER TABLE [ALMA].[MotivoES]
    ADD CONSTRAINT [DF_MotivoES_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [CONTA].[DF_Concepto_FechaCreacion]...';


GO
ALTER TABLE [CONTA].[Concepto]
    ADD CONSTRAINT [DF_Concepto_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [CONTA].[DF_Concepto_Activo]...';


GO
ALTER TABLE [CONTA].[Concepto]
    ADD CONSTRAINT [DF_Concepto_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [CONTA].[DF_MatrizIngreso_FechaCreacion]...';


GO
ALTER TABLE [CONTA].[MatrizIngreso]
    ADD CONSTRAINT [DF_MatrizIngreso_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [CONTA].[DF_MatrizIngreso_Activo]...';


GO
ALTER TABLE [CONTA].[MatrizIngreso]
    ADD CONSTRAINT [DF_MatrizIngreso_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [CONTA].[DF_Poliza_EstaBalanceado]...';


GO
ALTER TABLE [CONTA].[Poliza]
    ADD CONSTRAINT [DF_Poliza_EstaBalanceado] DEFAULT ((0)) FOR [EstaBalanceado];


GO
PRINT N'Creando Restricción DEFAULT [CONTA].[DF_Poliza_Activo]...';


GO
ALTER TABLE [CONTA].[Poliza]
    ADD CONSTRAINT [DF_Poliza_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [CONTA].[DF_Poliza_FechaCreacion]...';


GO
ALTER TABLE [CONTA].[Poliza]
    ADD CONSTRAINT [DF_Poliza_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [CONTA].[DF_MatrizConversion_FechaCreacion]...';


GO
ALTER TABLE [CONTA].[MatrizConversion]
    ADD CONSTRAINT [DF_MatrizConversion_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [CONTA].[DF_MatrizConversion_Activo]...';


GO
ALTER TABLE [CONTA].[MatrizConversion]
    ADD CONSTRAINT [DF_MatrizConversion_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [CONTA].[DF_Capitulo_FechaCreacion]...';


GO
ALTER TABLE [CONTA].[Capitulo]
    ADD CONSTRAINT [DF_Capitulo_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [CONTA].[DF_Capitulo_Activo]...';


GO
ALTER TABLE [CONTA].[Capitulo]
    ADD CONSTRAINT [DF_Capitulo_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [CONTA].[DF_PolizaDetalle_FechaCreacion]...';


GO
ALTER TABLE [CONTA].[PolizaDetalle]
    ADD CONSTRAINT [DF_PolizaDetalle_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [CONTA].[DF_PolizaDetalle_Activo]...';


GO
ALTER TABLE [CONTA].[PolizaDetalle]
    ADD CONSTRAINT [DF_PolizaDetalle_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [CONTA].[DF_ConsecutivoPoliza_Activo]...';


GO
ALTER TABLE [CONTA].[ConsecutivoPoliza]
    ADD CONSTRAINT [DF_ConsecutivoPoliza_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [CONTA].[DF_ConsecutivoPoliza_UltimoValor]...';


GO
ALTER TABLE [CONTA].[ConsecutivoPoliza]
    ADD CONSTRAINT [DF_ConsecutivoPoliza_UltimoValor] DEFAULT ((0)) FOR [UltimoValor];


GO
PRINT N'Creando Restricción DEFAULT [CONTA].[DF_ConsecutivoPoliza_FechaCreacion]...';


GO
ALTER TABLE [CONTA].[ConsecutivoPoliza]
    ADD CONSTRAINT [DF_ConsecutivoPoliza_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [CONTA].[DF_TipoCuenta_Activo]...';


GO
ALTER TABLE [CONTA].[TipoCuenta]
    ADD CONSTRAINT [DF_TipoCuenta_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [CONTA].[DF_TipoCuenta_FechaCreacion]...';


GO
ALTER TABLE [CONTA].[TipoCuenta]
    ADD CONSTRAINT [DF_TipoCuenta_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [CONTA].[DF_CuentaContable_Activo]...';


GO
ALTER TABLE [CONTA].[CuentaContable]
    ADD CONSTRAINT [DF_CuentaContable_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [CONTA].[DF_CuentaContable_FechaCreacion]...';


GO
ALTER TABLE [CONTA].[CuentaContable]
    ADD CONSTRAINT [DF_CuentaContable_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [CONTA].[DF_Partida_Activo]...';


GO
ALTER TABLE [CONTA].[Partida]
    ADD CONSTRAINT [DF_Partida_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [CONTA].[DF_Partida_FechaCreacion]...';


GO
ALTER TABLE [CONTA].[Partida]
    ADD CONSTRAINT [DF_Partida_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [CONTA].[DF_TipoDoctoPago_FechaCreacion]...';


GO
ALTER TABLE [CONTA].[TipoDoctoPago]
    ADD CONSTRAINT [DF_TipoDoctoPago_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [CONTA].[DF_TipoDoctoPago_Activo]...';


GO
ALTER TABLE [CONTA].[TipoDoctoPago]
    ADD CONSTRAINT [DF_TipoDoctoPago_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [NOM].[Persona]...';


GO
ALTER TABLE [NOM].[Persona]
    ADD DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [NOM].[Persona]...';


GO
ALTER TABLE [NOM].[Persona]
    ADD DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [NOM].[DF_PersonaArea_FechaCreacion]...';


GO
ALTER TABLE [NOM].[PersonaArea]
    ADD CONSTRAINT [DF_PersonaArea_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [NOM].[DF_PersonaArea_Activo]...';


GO
ALTER TABLE [NOM].[PersonaArea]
    ADD CONSTRAINT [DF_PersonaArea_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_Articulo_FechaCreacion]...';


GO
ALTER TABLE [ORCO].[Articulo]
    ADD CONSTRAINT [DF_Articulo_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_Articulo_Activo]...';


GO
ALTER TABLE [ORCO].[Articulo]
    ADD CONSTRAINT [DF_Articulo_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_RequisicionPartida_Activo]...';


GO
ALTER TABLE [ORCO].[RequisicionPartida]
    ADD CONSTRAINT [DF_RequisicionPartida_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_RequisicionPartida_FechaCreacion]...';


GO
ALTER TABLE [ORCO].[RequisicionPartida]
    ADD CONSTRAINT [DF_RequisicionPartida_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_PAAASPartida_Activo]...';


GO
ALTER TABLE [ORCO].[PAAASPartida]
    ADD CONSTRAINT [DF_PAAASPartida_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_PAAASPartida_FechaCreacion]...';


GO
ALTER TABLE [ORCO].[PAAASPartida]
    ADD CONSTRAINT [DF_PAAASPartida_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_TipoContrato_Activo]...';


GO
ALTER TABLE [ORCO].[TipoContrato]
    ADD CONSTRAINT [DF_TipoContrato_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_TipoContrato_FechaCreacion]...';


GO
ALTER TABLE [ORCO].[TipoContrato]
    ADD CONSTRAINT [DF_TipoContrato_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_EstudioMercadoDetalleCosto_Activo]...';


GO
ALTER TABLE [ORCO].[EstudioMercadoDetalleCosto]
    ADD CONSTRAINT [DF_EstudioMercadoDetalleCosto_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_EstudioMercadoDetalleCosto_FechaCreacion]...';


GO
ALTER TABLE [ORCO].[EstudioMercadoDetalleCosto]
    ADD CONSTRAINT [DF_EstudioMercadoDetalleCosto_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_Requisicion_Activo]...';


GO
ALTER TABLE [ORCO].[Requisicion]
    ADD CONSTRAINT [DF_Requisicion_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_Requisicion_FechaCreacion]...';


GO
ALTER TABLE [ORCO].[Requisicion]
    ADD CONSTRAINT [DF_Requisicion_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_PAAAS_Activo]...';


GO
ALTER TABLE [ORCO].[PAAAS]
    ADD CONSTRAINT [DF_PAAAS_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_PAAAS_FechaCreacion]...';


GO
ALTER TABLE [ORCO].[PAAAS]
    ADD CONSTRAINT [DF_PAAAS_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_RequisicionDetalle_Activo]...';


GO
ALTER TABLE [ORCO].[RequisicionDetalle]
    ADD CONSTRAINT [DF_RequisicionDetalle_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_RequisicionDetalle_FechaCreacion]...';


GO
ALTER TABLE [ORCO].[RequisicionDetalle]
    ADD CONSTRAINT [DF_RequisicionDetalle_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_Cotizacion_Activo]...';


GO
ALTER TABLE [ORCO].[Cotizacion]
    ADD CONSTRAINT [DF_Cotizacion_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_Cotizacion_FechaCreacion]...';


GO
ALTER TABLE [ORCO].[Cotizacion]
    ADD CONSTRAINT [DF_Cotizacion_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_Cotizacion_Servicio]...';


GO
ALTER TABLE [ORCO].[Cotizacion]
    ADD CONSTRAINT [DF_Cotizacion_Servicio] DEFAULT ((0)) FOR [Servicio];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_EstudioMercado_Estatus]...';


GO
ALTER TABLE [ORCO].[EstudioMercado]
    ADD CONSTRAINT [DF_EstudioMercado_Estatus] DEFAULT ((1)) FOR [Estatus];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_EstudioMercado_FechaCreacion]...';


GO
ALTER TABLE [ORCO].[EstudioMercado]
    ADD CONSTRAINT [DF_EstudioMercado_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_EstudioMercado_Activo]...';


GO
ALTER TABLE [ORCO].[EstudioMercado]
    ADD CONSTRAINT [DF_EstudioMercado_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_ProcedimientoContratacion_Activo]...';


GO
ALTER TABLE [ORCO].[ProcedimientoContratacion]
    ADD CONSTRAINT [DF_ProcedimientoContratacion_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_ProcedimientoContratacion_FechaCreacion]...';


GO
ALTER TABLE [ORCO].[ProcedimientoContratacion]
    ADD CONSTRAINT [DF_ProcedimientoContratacion_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_TipoGarantia_Activo]...';


GO
ALTER TABLE [ORCO].[TipoGarantia]
    ADD CONSTRAINT [DF_TipoGarantia_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_TipoGarantia_FechaCreacion]...';


GO
ALTER TABLE [ORCO].[TipoGarantia]
    ADD CONSTRAINT [DF_TipoGarantia_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_SolicitudCotizacion_FechaCreacion]...';


GO
ALTER TABLE [ORCO].[SolicitudCotizacion]
    ADD CONSTRAINT [DF_SolicitudCotizacion_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_SolicitudCotizacion_Activo]...';


GO
ALTER TABLE [ORCO].[SolicitudCotizacion]
    ADD CONSTRAINT [DF_SolicitudCotizacion_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_SolicitudCotizacion_Estatus]...';


GO
ALTER TABLE [ORCO].[SolicitudCotizacion]
    ADD CONSTRAINT [DF_SolicitudCotizacion_Estatus] DEFAULT ((1)) FOR [Estatus];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_CotizacionDetalle_FechaCreacion]...';


GO
ALTER TABLE [ORCO].[CotizacionDetalle]
    ADD CONSTRAINT [DF_CotizacionDetalle_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_CotizacionDetalle_Activo]...';


GO
ALTER TABLE [ORCO].[CotizacionDetalle]
    ADD CONSTRAINT [DF_CotizacionDetalle_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [ORCO].[EstatusRequisicion]...';


GO
ALTER TABLE [ORCO].[EstatusRequisicion]
    ADD DEFAULT ((0)) FOR [Orden];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_EstatusRequisicion_Activo]...';


GO
ALTER TABLE [ORCO].[EstatusRequisicion]
    ADD CONSTRAINT [DF_EstatusRequisicion_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_EstatusRequisicion_FechaCreacion]...';


GO
ALTER TABLE [ORCO].[EstatusRequisicion]
    ADD CONSTRAINT [DF_EstatusRequisicion_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_PAAASDetalle_Activo]...';


GO
ALTER TABLE [ORCO].[PAAASDetalle]
    ADD CONSTRAINT [DF_PAAASDetalle_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_PAAASDetalle_FechaCreacion]...';


GO
ALTER TABLE [ORCO].[PAAASDetalle]
    ADD CONSTRAINT [DF_PAAASDetalle_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_Proyecto_Activo]...';


GO
ALTER TABLE [ORCO].[Proyecto]
    ADD CONSTRAINT [DF_Proyecto_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_Proyecto_FechaCreacion]...';


GO
ALTER TABLE [ORCO].[Proyecto]
    ADD CONSTRAINT [DF_Proyecto_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_Fraccion_Activo]...';


GO
ALTER TABLE [ORCO].[Fraccion]
    ADD CONSTRAINT [DF_Fraccion_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_Fraccion_FechaCreacion]...';


GO
ALTER TABLE [ORCO].[Fraccion]
    ADD CONSTRAINT [DF_Fraccion_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_Modalidad_Activo]...';


GO
ALTER TABLE [ORCO].[Modalidad]
    ADD CONSTRAINT [DF_Modalidad_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_Modalidad_FechaCreacion]...';


GO
ALTER TABLE [ORCO].[Modalidad]
    ADD CONSTRAINT [DF_Modalidad_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_EstudioMercadoDetalle_Activo]...';


GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle]
    ADD CONSTRAINT [DF_EstudioMercadoDetalle_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_EstudioMercadoDetalle_FechaCreacion]...';


GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle]
    ADD CONSTRAINT [DF_EstudioMercadoDetalle_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_TipoDocumento_Activo]...';


GO
ALTER TABLE [ORCO].[TipoDocumento]
    ADD CONSTRAINT [DF_TipoDocumento_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [ORCO].[DF_TipoDocumento_FechaCreacion]...';


GO
ALTER TABLE [ORCO].[TipoDocumento]
    ADD CONSTRAINT [DF_TipoDocumento_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_TipoGasto_Activo]...';


GO
ALTER TABLE [PRES].[TipoGasto]
    ADD CONSTRAINT [DF_TipoGasto_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_TipoGasto_FechaCreacion]...';


GO
ALTER TABLE [PRES].[TipoGasto]
    ADD CONSTRAINT [DF_TipoGasto_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_SubEje_Activo]...';


GO
ALTER TABLE [PRES].[SubEje]
    ADD CONSTRAINT [DF_SubEje_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_SubEje_FechaCreacion]...';


GO
ALTER TABLE [PRES].[SubEje]
    ADD CONSTRAINT [DF_SubEje_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_SolicitudSuficiencia_FechaCreacion]...';


GO
ALTER TABLE [PRES].[SolicitudSuficiencia]
    ADD CONSTRAINT [DF_SolicitudSuficiencia_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_SolicitudSuficiencia_Activo]...';


GO
ALTER TABLE [PRES].[SolicitudSuficiencia]
    ADD CONSTRAINT [DF_SolicitudSuficiencia_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_SolicitudSuficiencia_Estatus]...';


GO
ALTER TABLE [PRES].[SolicitudSuficiencia]
    ADD CONSTRAINT [DF_SolicitudSuficiencia_Estatus] DEFAULT ((1)) FOR [Estatus];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_PP_Activo]...';


GO
ALTER TABLE [PRES].[PP]
    ADD CONSTRAINT [DF_PP_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_PP_FechaCreacion]...';


GO
ALTER TABLE [PRES].[PP]
    ADD CONSTRAINT [DF_PP_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Programa_FechaCreacion]...';


GO
ALTER TABLE [PRES].[Programa]
    ADD CONSTRAINT [DF_Programa_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Programa_Activo]...';


GO
ALTER TABLE [PRES].[Programa]
    ADD CONSTRAINT [DF_Programa_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_DigitoIdentificador_Activo]...';


GO
ALTER TABLE [PRES].[DigitoIdentificador]
    ADD CONSTRAINT [DF_DigitoIdentificador_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_DigitoIdentificador_FechaCreacion]...';


GO
ALTER TABLE [PRES].[DigitoIdentificador]
    ADD CONSTRAINT [DF_DigitoIdentificador_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_VertienteGasto_FechaCreacion]...';


GO
ALTER TABLE [PRES].[VertienteGasto]
    ADD CONSTRAINT [DF_VertienteGasto_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_VertienteGasto_Activo]...';


GO
ALTER TABLE [PRES].[VertienteGasto]
    ADD CONSTRAINT [DF_VertienteGasto_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoAutorizado_Mayo]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [DF_EgresoAutorizado_Mayo] DEFAULT ((0)) FOR [Mayo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoAutorizado_Junio]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [DF_EgresoAutorizado_Junio] DEFAULT ((0)) FOR [Junio];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoAutorizado_Marzo]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [DF_EgresoAutorizado_Marzo] DEFAULT ((0)) FOR [Marzo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoAutorizado_Septiembre]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [DF_EgresoAutorizado_Septiembre] DEFAULT ((0)) FOR [Septiembre];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoAutorizado_Activo]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [DF_EgresoAutorizado_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoAutorizado_Noviembre]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [DF_EgresoAutorizado_Noviembre] DEFAULT ((0)) FOR [Noviembre];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoAutorizado_Abril]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [DF_EgresoAutorizado_Abril] DEFAULT ((0)) FOR [Abril];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoAutorizado_Octubre]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [DF_EgresoAutorizado_Octubre] DEFAULT ((0)) FOR [Octubre];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoAutorizado_Enero]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [DF_EgresoAutorizado_Enero] DEFAULT ((0)) FOR [Enero];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoAutorizado_Agosto]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [DF_EgresoAutorizado_Agosto] DEFAULT ((0)) FOR [Agosto];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoAutorizado_Diciembre]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [DF_EgresoAutorizado_Diciembre] DEFAULT ((0)) FOR [Diciembre];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoAutorizado_FechaCreacion]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [DF_EgresoAutorizado_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoAutorizado_Julio]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [DF_EgresoAutorizado_Julio] DEFAULT ((0)) FOR [Julio];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoAutorizado_Febrero]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [DF_EgresoAutorizado_Febrero] DEFAULT ((0)) FOR [Febrero];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_FN_Activo]...';


GO
ALTER TABLE [PRES].[FN]
    ADD CONSTRAINT [DF_FN_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_FN_FechaCreacion]...';


GO
ALTER TABLE [PRES].[FN]
    ADD CONSTRAINT [DF_FN_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_SubSubEje_Activo]...';


GO
ALTER TABLE [PRES].[SubSubEje]
    ADD CONSTRAINT [DF_SubSubEje_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_SubSubEje_FechaCreacion]...';


GO
ALTER TABLE [PRES].[SubSubEje]
    ADD CONSTRAINT [DF_SubSubEje_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_CLCDetalle_Mar]...';


GO
ALTER TABLE [PRES].[CLCDetalle]
    ADD CONSTRAINT [DF_CLCDetalle_Mar] DEFAULT ((0)) FOR [Marzo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_CLCDetalle_Ago]...';


GO
ALTER TABLE [PRES].[CLCDetalle]
    ADD CONSTRAINT [DF_CLCDetalle_Ago] DEFAULT ((0)) FOR [Agosto];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_CLCDetalle_Ene]...';


GO
ALTER TABLE [PRES].[CLCDetalle]
    ADD CONSTRAINT [DF_CLCDetalle_Ene] DEFAULT ((0)) FOR [Enero];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_CLCDetalle_Nov]...';


GO
ALTER TABLE [PRES].[CLCDetalle]
    ADD CONSTRAINT [DF_CLCDetalle_Nov] DEFAULT ((0)) FOR [Noviembre];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_CLCDetalle_Dic]...';


GO
ALTER TABLE [PRES].[CLCDetalle]
    ADD CONSTRAINT [DF_CLCDetalle_Dic] DEFAULT ((0)) FOR [Diciembre];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_CLCDetalle_May]...';


GO
ALTER TABLE [PRES].[CLCDetalle]
    ADD CONSTRAINT [DF_CLCDetalle_May] DEFAULT ((0)) FOR [Mayo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_CLCDetalle_Sep]...';


GO
ALTER TABLE [PRES].[CLCDetalle]
    ADD CONSTRAINT [DF_CLCDetalle_Sep] DEFAULT ((0)) FOR [Septiembre];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_CLCDetalle_FechaCreacion]...';


GO
ALTER TABLE [PRES].[CLCDetalle]
    ADD CONSTRAINT [DF_CLCDetalle_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_CLCDetalle_Oct]...';


GO
ALTER TABLE [PRES].[CLCDetalle]
    ADD CONSTRAINT [DF_CLCDetalle_Oct] DEFAULT ((0)) FOR [Octubre];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_CLCDetalle_Feb]...';


GO
ALTER TABLE [PRES].[CLCDetalle]
    ADD CONSTRAINT [DF_CLCDetalle_Feb] DEFAULT ((0)) FOR [Febrero];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_CLCDetalle_Jun]...';


GO
ALTER TABLE [PRES].[CLCDetalle]
    ADD CONSTRAINT [DF_CLCDetalle_Jun] DEFAULT ((0)) FOR [Junio];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_CLCDetalle_Activo]...';


GO
ALTER TABLE [PRES].[CLCDetalle]
    ADD CONSTRAINT [DF_CLCDetalle_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_CLCDetalle_Jul]...';


GO
ALTER TABLE [PRES].[CLCDetalle]
    ADD CONSTRAINT [DF_CLCDetalle_Jul] DEFAULT ((0)) FOR [Julio];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_CLCDetalle_Abr]...';


GO
ALTER TABLE [PRES].[CLCDetalle]
    ADD CONSTRAINT [DF_CLCDetalle_Abr] DEFAULT ((0)) FOR [Abril];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Eje_Activo]...';


GO
ALTER TABLE [PRES].[Eje]
    ADD CONSTRAINT [DF_Eje_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Eje_FechaCreacion]...';


GO
ALTER TABLE [PRES].[Eje]
    ADD CONSTRAINT [DF_Eje_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_TipoRecurso_FechaCreacion]...';


GO
ALTER TABLE [PRES].[TipoRecurso]
    ADD CONSTRAINT [DF_TipoRecurso_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_TipoRecurso_Activo]...';


GO
ALTER TABLE [PRES].[TipoRecurso]
    ADD CONSTRAINT [DF_TipoRecurso_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_ChequePartidas_FechaCreacion]...';


GO
ALTER TABLE [PRES].[ChequePartidas]
    ADD CONSTRAINT [DF_ChequePartidas_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_ChequePartidas_Activo]...';


GO
ALTER TABLE [PRES].[ChequePartidas]
    ADD CONSTRAINT [DF_ChequePartidas_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_GrupoPresupuesto_FechaCreacion]...';


GO
ALTER TABLE [PRES].[GrupoPresupuesto]
    ADD CONSTRAINT [DF_GrupoPresupuesto_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_GrupoPresupuesto_Activo]...';


GO
ALTER TABLE [PRES].[GrupoPresupuesto]
    ADD CONSTRAINT [DF_GrupoPresupuesto_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_AutorizacionSuficienciaDetalle_FechaCreacion]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle]
    ADD CONSTRAINT [DF_AutorizacionSuficienciaDetalle_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_AutorizacionSuficienciaDetalle_Activo]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle]
    ADD CONSTRAINT [DF_AutorizacionSuficienciaDetalle_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_AutorizacionSuficienciaDetalle_Oct]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle]
    ADD CONSTRAINT [DF_AutorizacionSuficienciaDetalle_Oct] DEFAULT ((0)) FOR [Octubre];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_AutorizacionSuficienciaDetalle_Nov]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle]
    ADD CONSTRAINT [DF_AutorizacionSuficienciaDetalle_Nov] DEFAULT ((0)) FOR [Noviembre];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_AutorizacionSuficienciaDetalle_Abr]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle]
    ADD CONSTRAINT [DF_AutorizacionSuficienciaDetalle_Abr] DEFAULT ((0)) FOR [Abril];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_AutorizacionSuficienciaDetalle_Ago]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle]
    ADD CONSTRAINT [DF_AutorizacionSuficienciaDetalle_Ago] DEFAULT ((0)) FOR [Agosto];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_AutorizacionSuficienciaDetalle_Jun]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle]
    ADD CONSTRAINT [DF_AutorizacionSuficienciaDetalle_Jun] DEFAULT ((0)) FOR [Junio];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_AutorizacionSuficienciaDetalle_Sep]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle]
    ADD CONSTRAINT [DF_AutorizacionSuficienciaDetalle_Sep] DEFAULT ((0)) FOR [Septiembre];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_AutorizacionSuficienciaDetalle_Jul]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle]
    ADD CONSTRAINT [DF_AutorizacionSuficienciaDetalle_Jul] DEFAULT ((0)) FOR [Julio];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_AutorizacionSuficienciaDetalle_Mar]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle]
    ADD CONSTRAINT [DF_AutorizacionSuficienciaDetalle_Mar] DEFAULT ((0)) FOR [Marzo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_AutorizacionSuficienciaDetalle_Dic]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle]
    ADD CONSTRAINT [DF_AutorizacionSuficienciaDetalle_Dic] DEFAULT ((0)) FOR [Diciembre];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_AutorizacionSuficienciaDetalle_Feb]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle]
    ADD CONSTRAINT [DF_AutorizacionSuficienciaDetalle_Feb] DEFAULT ((0)) FOR [Febrero];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_AutorizacionSuficienciaDetalle_Ene]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle]
    ADD CONSTRAINT [DF_AutorizacionSuficienciaDetalle_Ene] DEFAULT ((0)) FOR [Enero];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_AutorizacionSuficienciaDetalle_May]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle]
    ADD CONSTRAINT [DF_AutorizacionSuficienciaDetalle_May] DEFAULT ((0)) FOR [Mayo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_SF_Activo]...';


GO
ALTER TABLE [PRES].[SF]
    ADD CONSTRAINT [DF_SF_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_SF_FechaCreacion]...';


GO
ALTER TABLE [PRES].[SF]
    ADD CONSTRAINT [DF_SF_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_PY_Activo]...';


GO
ALTER TABLE [PRES].[PY]
    ADD CONSTRAINT [DF_PY_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_PY_FechaCreacion]...';


GO
ALTER TABLE [PRES].[PY]
    ADD CONSTRAINT [DF_PY_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_AutorizacionSuficiencia_Activo]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficiencia]
    ADD CONSTRAINT [DF_AutorizacionSuficiencia_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_AutorizacionSuficiencia_Estatus]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficiencia]
    ADD CONSTRAINT [DF_AutorizacionSuficiencia_Estatus] DEFAULT ((1)) FOR [Estatus];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_AutorizacionSuficiencia_FechaCreacion]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficiencia]
    ADD CONSTRAINT [DF_AutorizacionSuficiencia_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Subresultado_FechaCreacion]...';


GO
ALTER TABLE [PRES].[Subresultado]
    ADD CONSTRAINT [DF_Subresultado_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Subresultado_Activo]...';


GO
ALTER TABLE [PRES].[Subresultado]
    ADD CONSTRAINT [DF_Subresultado_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Suficiencia_FechaCreacion]...';


GO
ALTER TABLE [PRES].[Suficiencia]
    ADD CONSTRAINT [DF_Suficiencia_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Suficiencia_Activo]...';


GO
ALTER TABLE [PRES].[Suficiencia]
    ADD CONSTRAINT [DF_Suficiencia_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_UR_FechaCreacion]...';


GO
ALTER TABLE [PRES].[UR]
    ADD CONSTRAINT [DF_UR_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_UR_Activo]...';


GO
ALTER TABLE [PRES].[UR]
    ADD CONSTRAINT [DF_UR_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Sector_FechaCreacion]...';


GO
ALTER TABLE [PRES].[Sector]
    ADD CONSTRAINT [DF_Sector_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Sector_Activo]...';


GO
ALTER TABLE [PRES].[Sector]
    ADD CONSTRAINT [DF_Sector_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Contrato_Estatus]...';


GO
ALTER TABLE [PRES].[Contrato]
    ADD CONSTRAINT [DF_Contrato_Estatus] DEFAULT ((1)) FOR [Estatus];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Contrato_Activo]...';


GO
ALTER TABLE [PRES].[Contrato]
    ADD CONSTRAINT [DF_Contrato_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Contrato_FechaCreacion]...';


GO
ALTER TABLE [PRES].[Contrato]
    ADD CONSTRAINT [DF_Contrato_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_SolicitudSuficienciaDetalle_Sep]...';


GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle]
    ADD CONSTRAINT [DF_SolicitudSuficienciaDetalle_Sep] DEFAULT ((0)) FOR [Septiembre];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_SolicitudSuficienciaDetalle_Jun]...';


GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle]
    ADD CONSTRAINT [DF_SolicitudSuficienciaDetalle_Jun] DEFAULT ((0)) FOR [Junio];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_SolicitudSuficienciaDetalle_Mar]...';


GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle]
    ADD CONSTRAINT [DF_SolicitudSuficienciaDetalle_Mar] DEFAULT ((0)) FOR [Marzo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_SolicitudSuficienciaDetalle_FechaCreacion]...';


GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle]
    ADD CONSTRAINT [DF_SolicitudSuficienciaDetalle_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_SolicitudSuficienciaDetalle_Jul]...';


GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle]
    ADD CONSTRAINT [DF_SolicitudSuficienciaDetalle_Jul] DEFAULT ((0)) FOR [Julio];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_SolicitudSuficienciaDetalle_Nov]...';


GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle]
    ADD CONSTRAINT [DF_SolicitudSuficienciaDetalle_Nov] DEFAULT ((0)) FOR [Noviembre];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_SolicitudSuficienciaDetalle_Oct]...';


GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle]
    ADD CONSTRAINT [DF_SolicitudSuficienciaDetalle_Oct] DEFAULT ((0)) FOR [Octubre];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_SolicitudSuficienciaDetalle_May]...';


GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle]
    ADD CONSTRAINT [DF_SolicitudSuficienciaDetalle_May] DEFAULT ((0)) FOR [Mayo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_SolicitudSuficienciaDetalle_Abr]...';


GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle]
    ADD CONSTRAINT [DF_SolicitudSuficienciaDetalle_Abr] DEFAULT ((0)) FOR [Abril];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_SolicitudSuficienciaDetalle_Ene]...';


GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle]
    ADD CONSTRAINT [DF_SolicitudSuficienciaDetalle_Ene] DEFAULT ((0)) FOR [Enero];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_SolicitudSuficienciaDetalle_Feb]...';


GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle]
    ADD CONSTRAINT [DF_SolicitudSuficienciaDetalle_Feb] DEFAULT ((0)) FOR [Febrero];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_SolicitudSuficienciaDetalle_Activo]...';


GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle]
    ADD CONSTRAINT [DF_SolicitudSuficienciaDetalle_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_SolicitudSuficienciaDetalle_Ago]...';


GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle]
    ADD CONSTRAINT [DF_SolicitudSuficienciaDetalle_Ago] DEFAULT ((0)) FOR [Agosto];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_SolicitudSuficienciaDetalle_Dic]...';


GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle]
    ADD CONSTRAINT [DF_SolicitudSuficienciaDetalle_Dic] DEFAULT ((0)) FOR [Diciembre];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Cheque_Estatus]...';


GO
ALTER TABLE [PRES].[Cheque]
    ADD CONSTRAINT [DF_Cheque_Estatus] DEFAULT ((1)) FOR [Estatus];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Cheque_Activo]...';


GO
ALTER TABLE [PRES].[Cheque]
    ADD CONSTRAINT [DF_Cheque_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Cheque_FechaCreacion]...';


GO
ALTER TABLE [PRES].[Cheque]
    ADD CONSTRAINT [DF_Cheque_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_CLCFactura_FechaCreacion]...';


GO
ALTER TABLE [PRES].[CLCFactura]
    ADD CONSTRAINT [DF_CLCFactura_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_CLCFactura_Activo]...';


GO
ALTER TABLE [PRES].[CLCFactura]
    ADD CONSTRAINT [DF_CLCFactura_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoProyectado_Octubre]...';


GO
ALTER TABLE [PRES].[EgresoProyectado]
    ADD CONSTRAINT [DF_EgresoProyectado_Octubre] DEFAULT ((0)) FOR [Octubre];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoProyectado_Septiembre]...';


GO
ALTER TABLE [PRES].[EgresoProyectado]
    ADD CONSTRAINT [DF_EgresoProyectado_Septiembre] DEFAULT ((0)) FOR [Septiembre];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoProyectado_Mayo]...';


GO
ALTER TABLE [PRES].[EgresoProyectado]
    ADD CONSTRAINT [DF_EgresoProyectado_Mayo] DEFAULT ((0)) FOR [Mayo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoProyectado_Marzo]...';


GO
ALTER TABLE [PRES].[EgresoProyectado]
    ADD CONSTRAINT [DF_EgresoProyectado_Marzo] DEFAULT ((0)) FOR [Marzo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoProyectado_Noviembre]...';


GO
ALTER TABLE [PRES].[EgresoProyectado]
    ADD CONSTRAINT [DF_EgresoProyectado_Noviembre] DEFAULT ((0)) FOR [Noviembre];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoProyectado_Abril]...';


GO
ALTER TABLE [PRES].[EgresoProyectado]
    ADD CONSTRAINT [DF_EgresoProyectado_Abril] DEFAULT ((0)) FOR [Abril];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoProyectado_Diciembre]...';


GO
ALTER TABLE [PRES].[EgresoProyectado]
    ADD CONSTRAINT [DF_EgresoProyectado_Diciembre] DEFAULT ((0)) FOR [Diciembre];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoProyectado_Enero]...';


GO
ALTER TABLE [PRES].[EgresoProyectado]
    ADD CONSTRAINT [DF_EgresoProyectado_Enero] DEFAULT ((0)) FOR [Enero];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoProyectado_Activo]...';


GO
ALTER TABLE [PRES].[EgresoProyectado]
    ADD CONSTRAINT [DF_EgresoProyectado_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoProyectado_Agosto]...';


GO
ALTER TABLE [PRES].[EgresoProyectado]
    ADD CONSTRAINT [DF_EgresoProyectado_Agosto] DEFAULT ((0)) FOR [Agosto];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoProyectado_Julio]...';


GO
ALTER TABLE [PRES].[EgresoProyectado]
    ADD CONSTRAINT [DF_EgresoProyectado_Julio] DEFAULT ((0)) FOR [Julio];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoProyectado_Junio]...';


GO
ALTER TABLE [PRES].[EgresoProyectado]
    ADD CONSTRAINT [DF_EgresoProyectado_Junio] DEFAULT ((0)) FOR [Junio];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoProyectado_Febrero]...';


GO
ALTER TABLE [PRES].[EgresoProyectado]
    ADD CONSTRAINT [DF_EgresoProyectado_Febrero] DEFAULT ((0)) FOR [Febrero];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_EgresoProyectado_FechaCreacion]...';


GO
ALTER TABLE [PRES].[EgresoProyectado]
    ADD CONSTRAINT [DF_EgresoProyectado_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_PG_Activo]...';


GO
ALTER TABLE [PRES].[PG]
    ADD CONSTRAINT [DF_PG_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_PG_FechaCreacion]...';


GO
ALTER TABLE [PRES].[PG]
    ADD CONSTRAINT [DF_PG_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Origen_FechaCreacion]...';


GO
ALTER TABLE [PRES].[Origen]
    ADD CONSTRAINT [DF_Origen_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Origen_Activo]...';


GO
ALTER TABLE [PRES].[Origen]
    ADD CONSTRAINT [DF_Origen_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Factura_FechaCreacion]...';


GO
ALTER TABLE [PRES].[Factura]
    ADD CONSTRAINT [DF_Factura_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Factura_Estatus]...';


GO
ALTER TABLE [PRES].[Factura]
    ADD CONSTRAINT [DF_Factura_Estatus] DEFAULT ((1)) FOR [Estatus];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Factura_Activo]...';


GO
ALTER TABLE [PRES].[Factura]
    ADD CONSTRAINT [DF_Factura_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Ramo_Activo]...';


GO
ALTER TABLE [PRES].[Ramo]
    ADD CONSTRAINT [DF_Ramo_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Ramo_FechaCreacion]...';


GO
ALTER TABLE [PRES].[Ramo]
    ADD CONSTRAINT [DF_Ramo_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_FuenteFinanciamiento_FechaCreacion]...';


GO
ALTER TABLE [PRES].[FuenteFinanciamiento]
    ADD CONSTRAINT [DF_FuenteFinanciamiento_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_FuenteFinanciamiento_Activo]...';


GO
ALTER TABLE [PRES].[FuenteFinanciamiento]
    ADD CONSTRAINT [DF_FuenteFinanciamiento_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_FacturaDetalle_Activo]...';


GO
ALTER TABLE [PRES].[FacturaDetalle]
    ADD CONSTRAINT [DF_FacturaDetalle_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_FacturaDetalle_FechaCreacion]...';


GO
ALTER TABLE [PRES].[FacturaDetalle]
    ADD CONSTRAINT [DF_FacturaDetalle_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Resultado_FechaCreacion]...';


GO
ALTER TABLE [PRES].[Resultado]
    ADD CONSTRAINT [DF_Resultado_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Resultado_Activo]...';


GO
ALTER TABLE [PRES].[Resultado]
    ADD CONSTRAINT [DF_Resultado_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_CLC_Activo]...';


GO
ALTER TABLE [PRES].[CLC]
    ADD CONSTRAINT [DF_CLC_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_CLC_FechaCreacion]...';


GO
ALTER TABLE [PRES].[CLC]
    ADD CONSTRAINT [DF_CLC_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_CLC_Estatus]...';


GO
ALTER TABLE [PRES].[CLC]
    ADD CONSTRAINT [DF_CLC_Estatus] DEFAULT ((1)) FOR [Estatus];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_GF_FechaCreacion]...';


GO
ALTER TABLE [PRES].[GF]
    ADD CONSTRAINT [DF_GF_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_GF_Activo]...';


GO
ALTER TABLE [PRES].[GF]
    ADD CONSTRAINT [DF_GF_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Finalidad_Activo]...';


GO
ALTER TABLE [PRES].[Finalidad]
    ADD CONSTRAINT [DF_Finalidad_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_Finalidad_FechaCreacion]...';


GO
ALTER TABLE [PRES].[Finalidad]
    ADD CONSTRAINT [DF_Finalidad_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_SubSector_FechaCreacion]...';


GO
ALTER TABLE [PRES].[SubSector]
    ADD CONSTRAINT [DF_SubSector_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_SubSector_Activo]...';


GO
ALTER TABLE [PRES].[SubSector]
    ADD CONSTRAINT [DF_SubSector_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_ContratoDetalle_FechaCreacion]...';


GO
ALTER TABLE [PRES].[ContratoDetalle]
    ADD CONSTRAINT [DF_ContratoDetalle_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_ContratoDetalle_Feb]...';


GO
ALTER TABLE [PRES].[ContratoDetalle]
    ADD CONSTRAINT [DF_ContratoDetalle_Feb] DEFAULT ((0)) FOR [Febrero];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_ContratoDetalle_Mar]...';


GO
ALTER TABLE [PRES].[ContratoDetalle]
    ADD CONSTRAINT [DF_ContratoDetalle_Mar] DEFAULT ((0)) FOR [Marzo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_ContratoDetalle_Abr]...';


GO
ALTER TABLE [PRES].[ContratoDetalle]
    ADD CONSTRAINT [DF_ContratoDetalle_Abr] DEFAULT ((0)) FOR [Abril];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_ContratoDetalle_Jul]...';


GO
ALTER TABLE [PRES].[ContratoDetalle]
    ADD CONSTRAINT [DF_ContratoDetalle_Jul] DEFAULT ((0)) FOR [Julio];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_ContratoDetalle_Jun]...';


GO
ALTER TABLE [PRES].[ContratoDetalle]
    ADD CONSTRAINT [DF_ContratoDetalle_Jun] DEFAULT ((0)) FOR [Junio];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_ContratoDetalle_Nov]...';


GO
ALTER TABLE [PRES].[ContratoDetalle]
    ADD CONSTRAINT [DF_ContratoDetalle_Nov] DEFAULT ((0)) FOR [Noviembre];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_ContratoDetalle_Ago]...';


GO
ALTER TABLE [PRES].[ContratoDetalle]
    ADD CONSTRAINT [DF_ContratoDetalle_Ago] DEFAULT ((0)) FOR [Agosto];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_ContratoDetalle_May]...';


GO
ALTER TABLE [PRES].[ContratoDetalle]
    ADD CONSTRAINT [DF_ContratoDetalle_May] DEFAULT ((0)) FOR [Mayo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_ContratoDetalle_Activo]...';


GO
ALTER TABLE [PRES].[ContratoDetalle]
    ADD CONSTRAINT [DF_ContratoDetalle_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_ContratoDetalle_Ene]...';


GO
ALTER TABLE [PRES].[ContratoDetalle]
    ADD CONSTRAINT [DF_ContratoDetalle_Ene] DEFAULT ((0)) FOR [Enero];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_ContratoDetalle_Sep]...';


GO
ALTER TABLE [PRES].[ContratoDetalle]
    ADD CONSTRAINT [DF_ContratoDetalle_Sep] DEFAULT ((0)) FOR [Septiembre];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_ContratoDetalle_Dic]...';


GO
ALTER TABLE [PRES].[ContratoDetalle]
    ADD CONSTRAINT [DF_ContratoDetalle_Dic] DEFAULT ((0)) FOR [Diciembre];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_ContratoDetalle_Oct]...';


GO
ALTER TABLE [PRES].[ContratoDetalle]
    ADD CONSTRAINT [DF_ContratoDetalle_Oct] DEFAULT ((0)) FOR [Octubre];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_DestinoGasto_FechaCreacion]...';


GO
ALTER TABLE [PRES].[DestinoGasto]
    ADD CONSTRAINT [DF_DestinoGasto_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [PRES].[DF_DestinoGasto_Activo]...';


GO
ALTER TABLE [PRES].[DestinoGasto]
    ADD CONSTRAINT [DF_DestinoGasto_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_Proveedor_Activo]...';


GO
ALTER TABLE [SIS].[Proveedor]
    ADD CONSTRAINT [DF_Proveedor_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_Proveedor_FechaCreacion]...';


GO
ALTER TABLE [SIS].[Proveedor]
    ADD CONSTRAINT [DF_Proveedor_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[UsuarioDepartamento]...';


GO
ALTER TABLE [SIS].[UsuarioDepartamento]
    ADD DEFAULT ((0)) FOR [EsJefe];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[UsuarioDepartamento]...';


GO
ALTER TABLE [SIS].[UsuarioDepartamento]
    ADD DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[UsuarioDepartamento]...';


GO
ALTER TABLE [SIS].[UsuarioDepartamento]
    ADD DEFAULT (sysdatetime()) FOR [FechaAsignacion];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[UsuarioDepartamento]...';


GO
ALTER TABLE [SIS].[UsuarioDepartamento]
    ADD DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[CatTipoSucursal]...';


GO
ALTER TABLE [SIS].[CatTipoSucursal]
    ADD DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[EmpresaEstado]...';


GO
ALTER TABLE [SIS].[EmpresaEstado]
    ADD DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[EmpresaEstado]...';


GO
ALTER TABLE [SIS].[EmpresaEstado]
    ADD DEFAULT ((0)) FOR [EsOficinaPrincipal];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[Menu]...';


GO
ALTER TABLE [SIS].[Menu]
    ADD DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[Menu]...';


GO
ALTER TABLE [SIS].[Menu]
    ADD DEFAULT (getdate()) FOR [CreatedDateTime];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_Anio_Activo]...';


GO
ALTER TABLE [SIS].[Anio]
    ADD CONSTRAINT [DF_Anio_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_Anio_FechaCreacion]...';


GO
ALTER TABLE [SIS].[Anio]
    ADD CONSTRAINT [DF_Anio_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[Usuario]...';


GO
ALTER TABLE [SIS].[Usuario]
    ADD DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[Usuario]...';


GO
ALTER TABLE [SIS].[Usuario]
    ADD DEFAULT ((0)) FOR [EsAdministrador];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[Usuario]...';


GO
ALTER TABLE [SIS].[Usuario]
    ADD DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[PerfilUsuario]...';


GO
ALTER TABLE [SIS].[PerfilUsuario]
    ADD DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[PerfilUsuario]...';


GO
ALTER TABLE [SIS].[PerfilUsuario]
    ADD DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[Municipios]...';


GO
ALTER TABLE [SIS].[Municipios]
    ADD DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[Municipios]...';


GO
ALTER TABLE [SIS].[Municipios]
    ADD DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_TipoProveedor_Activo]...';


GO
ALTER TABLE [SIS].[TipoProveedor]
    ADD CONSTRAINT [DF_TipoProveedor_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_TipoProveedor_FechaCreacion]...';


GO
ALTER TABLE [SIS].[TipoProveedor]
    ADD CONSTRAINT [DF_TipoProveedor_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_ActividadInstitucional_Activo]...';


GO
ALTER TABLE [SIS].[ActividadInstitucional]
    ADD CONSTRAINT [DF_ActividadInstitucional_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_ActividadInstitucional_FechaCreacion]...';


GO
ALTER TABLE [SIS].[ActividadInstitucional]
    ADD CONSTRAINT [DF_ActividadInstitucional_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_EstatusProveedor_Activo]...';


GO
ALTER TABLE [SIS].[EstatusProveedor]
    ADD CONSTRAINT [DF_EstatusProveedor_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_EstatusProveedor_FechaCreacion]...';


GO
ALTER TABLE [SIS].[EstatusProveedor]
    ADD CONSTRAINT [DF_EstatusProveedor_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[UsuarioSucursal]...';


GO
ALTER TABLE [SIS].[UsuarioSucursal]
    ADD DEFAULT ((1)) FOR [PuedeAcceder];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[UsuarioSucursal]...';


GO
ALTER TABLE [SIS].[UsuarioSucursal]
    ADD DEFAULT ((0)) FOR [EsSupervisor];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[UsuarioSucursal]...';


GO
ALTER TABLE [SIS].[UsuarioSucursal]
    ADD DEFAULT ((0)) FOR [PuedeConfigurar];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[UsuarioSucursal]...';


GO
ALTER TABLE [SIS].[UsuarioSucursal]
    ADD DEFAULT (sysdatetime()) FOR [FechaAsignacion];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[UsuarioSucursal]...';


GO
ALTER TABLE [SIS].[UsuarioSucursal]
    ADD DEFAULT ((1)) FOR [PuedeOperar];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[UsuarioSucursal]...';


GO
ALTER TABLE [SIS].[UsuarioSucursal]
    ADD DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[UsuarioSucursal]...';


GO
ALTER TABLE [SIS].[UsuarioSucursal]
    ADD DEFAULT ((0)) FOR [PuedeReportes];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[UsuarioSucursal]...';


GO
ALTER TABLE [SIS].[UsuarioSucursal]
    ADD DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[UsuarioSucursal]...';


GO
ALTER TABLE [SIS].[UsuarioSucursal]
    ADD DEFAULT ((0)) FOR [EsGerente];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[SystemParamValue]...';


GO
ALTER TABLE [SIS].[SystemParamValue]
    ADD DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[SystemParamValue]...';


GO
ALTER TABLE [SIS].[SystemParamValue]
    ADD DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_Capitulo_Activo]...';


GO
ALTER TABLE [SIS].[Capitulo]
    ADD CONSTRAINT [DF_Capitulo_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_Capitulo_FechaCreacion]...';


GO
ALTER TABLE [SIS].[Capitulo]
    ADD CONSTRAINT [DF_Capitulo_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[Idioma]...';


GO
ALTER TABLE [SIS].[Idioma]
    ADD DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_TipoPoliza_Activo]...';


GO
ALTER TABLE [SIS].[TipoPoliza]
    ADD CONSTRAINT [DF_TipoPoliza_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_TipoPoliza_FechaCreacion]...';


GO
ALTER TABLE [SIS].[TipoPoliza]
    ADD CONSTRAINT [DF_TipoPoliza_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[OrigenLogMessage]...';


GO
ALTER TABLE [SIS].[OrigenLogMessage]
    ADD DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[OrigenLogMessage]...';


GO
ALTER TABLE [SIS].[OrigenLogMessage]
    ADD DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[Estados]...';


GO
ALTER TABLE [SIS].[Estados]
    ADD DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[SystemLog]...';


GO
ALTER TABLE [SIS].[SystemLog]
    ADD DEFAULT (sysdatetime()) FOR [Date];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_TipoDetallePoliza_Activo]...';


GO
ALTER TABLE [SIS].[TipoDetallePoliza]
    ADD CONSTRAINT [DF_TipoDetallePoliza_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_TipoDetallePoliza_FechaCreacion]...';


GO
ALTER TABLE [SIS].[TipoDetallePoliza]
    ADD CONSTRAINT [DF_TipoDetallePoliza_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[SystemParamCatalog]...';


GO
ALTER TABLE [SIS].[SystemParamCatalog]
    ADD DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[SystemParamCatalog]...';


GO
ALTER TABLE [SIS].[SystemParamCatalog]
    ADD DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[Paises]...';


GO
ALTER TABLE [SIS].[Paises]
    ADD DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[Paises]...';


GO
ALTER TABLE [SIS].[Paises]
    ADD DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[MenuRole]...';


GO
ALTER TABLE [SIS].[MenuRole]
    ADD DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[MenuRole]...';


GO
ALTER TABLE [SIS].[MenuRole]
    ADD DEFAULT (getdate()) FOR [CreatedDateTime];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_Banco_Activo]...';


GO
ALTER TABLE [SIS].[Banco]
    ADD CONSTRAINT [DF_Banco_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_Banco_FechaCreacion]...';


GO
ALTER TABLE [SIS].[Banco]
    ADD CONSTRAINT [DF_Banco_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[Empresa]...';


GO
ALTER TABLE [SIS].[Empresa]
    ADD DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[Empresa]...';


GO
ALTER TABLE [SIS].[Empresa]
    ADD DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[Departamento]...';


GO
ALTER TABLE [SIS].[Departamento]
    ADD DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[Departamento]...';


GO
ALTER TABLE [SIS].[Departamento]
    ADD DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[Departamento]...';


GO
ALTER TABLE [SIS].[Departamento]
    ADD DEFAULT ((1)) FOR [NivelJerarquico];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_Concepto_Activo]...';


GO
ALTER TABLE [SIS].[Concepto]
    ADD CONSTRAINT [DF_Concepto_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_Concepto_FechaCreacion]...';


GO
ALTER TABLE [SIS].[Concepto]
    ADD CONSTRAINT [DF_Concepto_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_Partida_Activo]...';


GO
ALTER TABLE [SIS].[Partida]
    ADD CONSTRAINT [DF_Partida_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_Partida_FechaCreacion]...';


GO
ALTER TABLE [SIS].[Partida]
    ADD CONSTRAINT [DF_Partida_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_Area_Activo]...';


GO
ALTER TABLE [SIS].[Area]
    ADD CONSTRAINT [DF_Area_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_Area_Aprovado]...';


GO
ALTER TABLE [SIS].[Area]
    ADD CONSTRAINT [DF_Area_Aprovado] DEFAULT ((0)) FOR [Aprovado];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_Area_FechaCreacion]...';


GO
ALTER TABLE [SIS].[Area]
    ADD CONSTRAINT [DF_Area_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_TipoDoctoCLC_Activo]...';


GO
ALTER TABLE [SIS].[TipoDoctoCLC]
    ADD CONSTRAINT [DF_TipoDoctoCLC_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [SIS].[DF_TipoDoctoCLC_FechaCreacion]...';


GO
ALTER TABLE [SIS].[TipoDoctoCLC]
    ADD CONSTRAINT [DF_TipoDoctoCLC_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[Moneda]...';


GO
ALTER TABLE [SIS].[Moneda]
    ADD DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[Moneda]...';


GO
ALTER TABLE [SIS].[Moneda]
    ADD DEFAULT ((2)) FOR [Decimales];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[Sucursal]...';


GO
ALTER TABLE [SIS].[Sucursal]
    ADD DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[Sucursal]...';


GO
ALTER TABLE [SIS].[Sucursal]
    ADD DEFAULT ((2)) FOR [FKIdTipoSucursal];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[Sucursal]...';


GO
ALTER TABLE [SIS].[Sucursal]
    ADD DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[Sucursal]...';


GO
ALTER TABLE [SIS].[Sucursal]
    ADD DEFAULT ((0)) FOR [EsMatriz];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [SIS].[Sucursal]...';


GO
ALTER TABLE [SIS].[Sucursal]
    ADD DEFAULT ((1)) FOR [EsActiva];


GO
PRINT N'Creando Restricción DEFAULT [TES].[DF_TipoPagoSF_Activo]...';


GO
ALTER TABLE [TES].[TipoPagoSF]
    ADD CONSTRAINT [DF_TipoPagoSF_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [TES].[DF_TipoPagoSF_FechaCreacion]...';


GO
ALTER TABLE [TES].[TipoPagoSF]
    ADD CONSTRAINT [DF_TipoPagoSF_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [TES].[DF_TipoInversion_FechaCreacion]...';


GO
ALTER TABLE [TES].[TipoInversion]
    ADD CONSTRAINT [DF_TipoInversion_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [TES].[DF_TipoInversion_Activo]...';


GO
ALTER TABLE [TES].[TipoInversion]
    ADD CONSTRAINT [DF_TipoInversion_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [TES].[DF_TipoSolicitudCLC_FechaCreacion]...';


GO
ALTER TABLE [TES].[TipoSolicitudCLC]
    ADD CONSTRAINT [DF_TipoSolicitudCLC_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [TES].[DF_TipoSolicitudCLC_Activo]...';


GO
ALTER TABLE [TES].[TipoSolicitudCLC]
    ADD CONSTRAINT [DF_TipoSolicitudCLC_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [TES].[DF_TipoPago_Activo]...';


GO
ALTER TABLE [TES].[TipoPago]
    ADD CONSTRAINT [DF_TipoPago_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [TES].[DF_TipoPago_FechaCreacion]...';


GO
ALTER TABLE [TES].[TipoPago]
    ADD CONSTRAINT [DF_TipoPago_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [TES].[TipoMoneda]...';


GO
ALTER TABLE [TES].[TipoMoneda]
    ADD DEFAULT ((2)) FOR [Decimales];


GO
PRINT N'Creando Restricción DEFAULT [TES].[DF_TipoMoneda_Activo]...';


GO
ALTER TABLE [TES].[TipoMoneda]
    ADD CONSTRAINT [DF_TipoMoneda_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [TES].[DF_TipoMoneda_FechaCreacion]...';


GO
ALTER TABLE [TES].[TipoMoneda]
    ADD CONSTRAINT [DF_TipoMoneda_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [TES].[DF_TipoCambio_Activo]...';


GO
ALTER TABLE [TES].[TipoCambio]
    ADD CONSTRAINT [DF_TipoCambio_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [TES].[DF_TipoCambio_FechaCreacion]...';


GO
ALTER TABLE [TES].[TipoCambio]
    ADD CONSTRAINT [DF_TipoCambio_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [TES].[DF_CuentaBancaria_FechaCreacion]...';


GO
ALTER TABLE [TES].[CuentaBancaria]
    ADD CONSTRAINT [DF_CuentaBancaria_FechaCreacion] DEFAULT (sysdatetime()) FOR [FechaCreacion];


GO
PRINT N'Creando Restricción DEFAULT [TES].[DF_CuentaBancaria_SaldoActual]...';


GO
ALTER TABLE [TES].[CuentaBancaria]
    ADD CONSTRAINT [DF_CuentaBancaria_SaldoActual] DEFAULT ((0)) FOR [SaldoActual];


GO
PRINT N'Creando Restricción DEFAULT [TES].[DF_CuentaBancaria_SaldoInicial]...';


GO
ALTER TABLE [TES].[CuentaBancaria]
    ADD CONSTRAINT [DF_CuentaBancaria_SaldoInicial] DEFAULT ((0)) FOR [SaldoInicial];


GO
PRINT N'Creando Restricción DEFAULT [TES].[DF_CuentaBancaria_Activo]...';


GO
ALTER TABLE [TES].[CuentaBancaria]
    ADD CONSTRAINT [DF_CuentaBancaria_Activo] DEFAULT ((1)) FOR [Activo];


GO
PRINT N'Creando Restricción DEFAULT [dbo].[CONSTRAINT_DF_AspNetClaims_ReferenceId]...';


GO
ALTER TABLE [dbo].[AspNetClaims]
    ADD CONSTRAINT [CONSTRAINT_DF_AspNetClaims_ReferenceId] DEFAULT ((0)) FOR [ReferenceId];


GO
PRINT N'Creando Restricción DEFAULT [dbo].[CONSTRAINT_DF_AspNetClaimValues_Created]...';


GO
ALTER TABLE [dbo].[AspNetClaimValues]
    ADD CONSTRAINT [CONSTRAINT_DF_AspNetClaimValues_Created] DEFAULT (getdate()) FOR [Created];


GO
PRINT N'Creando Clave externa [ALMA].[FK_EstadoBien_UsuarioCreacion]...';


GO
ALTER TABLE [ALMA].[EstadoBien]
    ADD CONSTRAINT [FK_EstadoBien_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_EstadoBien_UsuarioModificacion]...';


GO
ALTER TABLE [ALMA].[EstadoBien]
    ADD CONSTRAINT [FK_EstadoBien_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_TipoPatrimonio_UsuarioModificacion]...';


GO
ALTER TABLE [ALMA].[TipoPatrimonio]
    ADD CONSTRAINT [FK_TipoPatrimonio_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_TipoPatrimonio_UsuarioCreacion]...';


GO
ALTER TABLE [ALMA].[TipoPatrimonio]
    ADD CONSTRAINT [FK_TipoPatrimonio_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_Material_UsuarioCreacion]...';


GO
ALTER TABLE [ALMA].[Material]
    ADD CONSTRAINT [FK_Material_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_Material_UsuarioModificacion]...';


GO
ALTER TABLE [ALMA].[Material]
    ADD CONSTRAINT [FK_Material_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_ConteoDetalleEscaneo_TipoBien]...';


GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo]
    ADD CONSTRAINT [FK_ConteoDetalleEscaneo_TipoBien] FOREIGN KEY ([FKIdTipoBien_ALMA]) REFERENCES [ALMA].[TipoBien] ([PKIdTipoBien]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_ConteoDetalleEscaneo_UsuarioModificacion]...';


GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo]
    ADD CONSTRAINT [FK_ConteoDetalleEscaneo_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_ConteoDetalleEscaneo_Persona]...';


GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo]
    ADD CONSTRAINT [FK_ConteoDetalleEscaneo_Persona] FOREIGN KEY ([FKIdPersona_NOM]) REFERENCES [NOM].[Persona] ([PKIdPersona]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_ConteoDetalleEscaneo_Conteo]...';


GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo]
    ADD CONSTRAINT [FK_ConteoDetalleEscaneo_Conteo] FOREIGN KEY ([FKIdConteo_ALMA]) REFERENCES [ALMA].[Conteo] ([PKIdConteo]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_ConteoDetalleEscaneo_UsuarioCreacion]...';


GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo]
    ADD CONSTRAINT [FK_ConteoDetalleEscaneo_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_Unidades_UsuarioCreacion]...';


GO
ALTER TABLE [ALMA].[Unidades]
    ADD CONSTRAINT [FK_Unidades_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_Unidades_UsuarioModificacion]...';


GO
ALTER TABLE [ALMA].[Unidades]
    ADD CONSTRAINT [FK_Unidades_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_TipoBien_GrupoBien]...';


GO
ALTER TABLE [ALMA].[TipoBien]
    ADD CONSTRAINT [FK_TipoBien_GrupoBien] FOREIGN KEY ([FKIdGrupoBien_ALMA]) REFERENCES [ALMA].[GrupoBien] ([PKIdGrupoBien]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_TipoBien_CuentaContable]...';


GO
ALTER TABLE [ALMA].[TipoBien]
    ADD CONSTRAINT [FK_TipoBien_CuentaContable] FOREIGN KEY ([FKIdCuentaContable_CONTA]) REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_TipoBien_UsuarioModificacion]...';


GO
ALTER TABLE [ALMA].[TipoBien]
    ADD CONSTRAINT [FK_TipoBien_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_TipoBien_UsuarioCreacion]...';


GO
ALTER TABLE [ALMA].[TipoBien]
    ADD CONSTRAINT [FK_TipoBien_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_TipoBien_UnidadesEquivalente]...';


GO
ALTER TABLE [ALMA].[TipoBien]
    ADD CONSTRAINT [FK_TipoBien_UnidadesEquivalente] FOREIGN KEY ([FKIdUnidades_Equivalente]) REFERENCES [ALMA].[Unidades] ([PKIdUnidades]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_TipoBien_Unidades]...';


GO
ALTER TABLE [ALMA].[TipoBien]
    ADD CONSTRAINT [FK_TipoBien_Unidades] FOREIGN KEY ([FKIdUnidades_ALMA]) REFERENCES [ALMA].[Unidades] ([PKIdUnidades]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_TipoBien_Partida]...';


GO
ALTER TABLE [ALMA].[TipoBien]
    ADD CONSTRAINT [FK_TipoBien_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_TipoBien_Nivel]...';


GO
ALTER TABLE [ALMA].[TipoBien]
    ADD CONSTRAINT [FK_TipoBien_Nivel] FOREIGN KEY ([FKIdNivel_ALMA]) REFERENCES [ALMA].[Nivel] ([PKIdNivel]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_TipoAdquisicion_UsuarioModificacion]...';


GO
ALTER TABLE [ALMA].[TipoAdquisicion]
    ADD CONSTRAINT [FK_TipoAdquisicion_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_TipoAdquisicion_UsuarioCreacion]...';


GO
ALTER TABLE [ALMA].[TipoAdquisicion]
    ADD CONSTRAINT [FK_TipoAdquisicion_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_Conteo_UsuarioCreacion]...';


GO
ALTER TABLE [ALMA].[Conteo]
    ADD CONSTRAINT [FK_Conteo_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_Conteo_TipoBien]...';


GO
ALTER TABLE [ALMA].[Conteo]
    ADD CONSTRAINT [FK_Conteo_TipoBien] FOREIGN KEY ([FKIdTipoBien_ALMA]) REFERENCES [ALMA].[TipoBien] ([PKIdTipoBien]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_Conteo_UsuarioModificacion]...';


GO
ALTER TABLE [ALMA].[Conteo]
    ADD CONSTRAINT [FK_Conteo_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_Conteo_PeriodoConteo]...';


GO
ALTER TABLE [ALMA].[Conteo]
    ADD CONSTRAINT [FK_Conteo_PeriodoConteo] FOREIGN KEY ([FKIdPeriodoConteo_ALMA]) REFERENCES [ALMA].[PeriodoConteo] ([PKIdPeriodoConteo]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_Familia_UsuarioModificacion]...';


GO
ALTER TABLE [ALMA].[Familia]
    ADD CONSTRAINT [FK_Familia_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_Familia_UsuarioCreacion]...';


GO
ALTER TABLE [ALMA].[Familia]
    ADD CONSTRAINT [FK_Familia_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_Bien_TipoPatrimonio]...';


GO
ALTER TABLE [ALMA].[Bien]
    ADD CONSTRAINT [FK_Bien_TipoPatrimonio] FOREIGN KEY ([FKIdTipoPatrimonio_ALMA]) REFERENCES [ALMA].[TipoPatrimonio] ([PKIdTipoPatrimonio]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_Bien_Material]...';


GO
ALTER TABLE [ALMA].[Bien]
    ADD CONSTRAINT [FK_Bien_Material] FOREIGN KEY ([FKIdMaterial_ALMA]) REFERENCES [ALMA].[Material] ([PKIdMaterial]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_Bien_Area]...';


GO
ALTER TABLE [ALMA].[Bien]
    ADD CONSTRAINT [FK_Bien_Area] FOREIGN KEY ([FKIdArea_SIS]) REFERENCES [SIS].[Area] ([PKIdArea]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_Bien_UsuarioModificacion]...';


GO
ALTER TABLE [ALMA].[Bien]
    ADD CONSTRAINT [FK_Bien_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_Bien_GrupoBien]...';


GO
ALTER TABLE [ALMA].[Bien]
    ADD CONSTRAINT [FK_Bien_GrupoBien] FOREIGN KEY ([FKIdGrupoBien_ALMA]) REFERENCES [ALMA].[GrupoBien] ([PKIdGrupoBien]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_Bien_Proveedor]...';


GO
ALTER TABLE [ALMA].[Bien]
    ADD CONSTRAINT [FK_Bien_Proveedor] FOREIGN KEY ([FKIdProveedor_SIS]) REFERENCES [SIS].[Proveedor] ([PKIdProveedor]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_Bien_TipoBien]...';


GO
ALTER TABLE [ALMA].[Bien]
    ADD CONSTRAINT [FK_Bien_TipoBien] FOREIGN KEY ([FKIdTipoBien_ALMA]) REFERENCES [ALMA].[TipoBien] ([PKIdTipoBien]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_Bien_UsuarioCreacion]...';


GO
ALTER TABLE [ALMA].[Bien]
    ADD CONSTRAINT [FK_Bien_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_Bien_Marca]...';


GO
ALTER TABLE [ALMA].[Bien]
    ADD CONSTRAINT [FK_Bien_Marca] FOREIGN KEY ([FKIdMarca_ALMA]) REFERENCES [ALMA].[Marca] ([PKIdMarca]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_Bien_EstadoBien]...';


GO
ALTER TABLE [ALMA].[Bien]
    ADD CONSTRAINT [FK_Bien_EstadoBien] FOREIGN KEY ([FKIdEstadoBien_ALMA]) REFERENCES [ALMA].[EstadoBien] ([PKIdEstadoBien]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_Bien_TipoAdquisicion]...';


GO
ALTER TABLE [ALMA].[Bien]
    ADD CONSTRAINT [FK_Bien_TipoAdquisicion] FOREIGN KEY ([FKIdTipoAdq_ALMA]) REFERENCES [ALMA].[TipoAdquisicion] ([PKIdTipoAdq]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_Bien_Partida]...';


GO
ALTER TABLE [ALMA].[Bien]
    ADD CONSTRAINT [FK_Bien_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_PeriodoConteo_Supervisor]...';


GO
ALTER TABLE [ALMA].[PeriodoConteo]
    ADD CONSTRAINT [FK_PeriodoConteo_Supervisor] FOREIGN KEY ([FKIdSupervisor_SIS]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_PeriodoConteo_Sucursal]...';


GO
ALTER TABLE [ALMA].[PeriodoConteo]
    ADD CONSTRAINT [FK_PeriodoConteo_Sucursal] FOREIGN KEY ([FKIdSucursal_SIS]) REFERENCES [SIS].[Sucursal] ([PKIdSucursal]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_PeriodoConteo_UsuarioModificacion]...';


GO
ALTER TABLE [ALMA].[PeriodoConteo]
    ADD CONSTRAINT [FK_PeriodoConteo_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_PeriodoConteo_Responsable]...';


GO
ALTER TABLE [ALMA].[PeriodoConteo]
    ADD CONSTRAINT [FK_PeriodoConteo_Responsable] FOREIGN KEY ([FKIdResponsable_SIS]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_PeriodoConteo_Estatus]...';


GO
ALTER TABLE [ALMA].[PeriodoConteo]
    ADD CONSTRAINT [FK_PeriodoConteo_Estatus] FOREIGN KEY ([FKIdEstatus_ALMA]) REFERENCES [ALMA].[EstatusPeriodo] ([PKIdEstatusPeriodo]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_PeriodoConteo_UsuarioCreacion]...';


GO
ALTER TABLE [ALMA].[PeriodoConteo]
    ADD CONSTRAINT [FK_PeriodoConteo_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_PeriodoConteo_TipoConteo]...';


GO
ALTER TABLE [ALMA].[PeriodoConteo]
    ADD CONSTRAINT [FK_PeriodoConteo_TipoConteo] FOREIGN KEY ([FKIdTipoConteo_ALMA]) REFERENCES [ALMA].[TipoConteo] ([PKIdTipoConteo]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_GrupoBien_UsuarioCreacion]...';


GO
ALTER TABLE [ALMA].[GrupoBien]
    ADD CONSTRAINT [FK_GrupoBien_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_GrupoBien_Familia]...';


GO
ALTER TABLE [ALMA].[GrupoBien]
    ADD CONSTRAINT [FK_GrupoBien_Familia] FOREIGN KEY ([FKIdFamilia_ALMA]) REFERENCES [ALMA].[Familia] ([PKIdFamilia]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_GrupoBien_UsuarioModificacion]...';


GO
ALTER TABLE [ALMA].[GrupoBien]
    ADD CONSTRAINT [FK_GrupoBien_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_EstatusSolicitud_UsuarioModificacion]...';


GO
ALTER TABLE [ALMA].[EstatusSolicitud]
    ADD CONSTRAINT [FK_EstatusSolicitud_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_EstatusSolicitud_UsuarioCreacion]...';


GO
ALTER TABLE [ALMA].[EstatusSolicitud]
    ADD CONSTRAINT [FK_EstatusSolicitud_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_Marca_UsuarioModificacion]...';


GO
ALTER TABLE [ALMA].[Marca]
    ADD CONSTRAINT [FK_Marca_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_Marca_UsuarioCreacion]...';


GO
ALTER TABLE [ALMA].[Marca]
    ADD CONSTRAINT [FK_Marca_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_Nivel_UsuarioCreacion]...';


GO
ALTER TABLE [ALMA].[Nivel]
    ADD CONSTRAINT [FK_Nivel_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_Nivel_UsuarioModificacion]...';


GO
ALTER TABLE [ALMA].[Nivel]
    ADD CONSTRAINT [FK_Nivel_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_ConteoDetalle_UsuarioModificacion]...';


GO
ALTER TABLE [ALMA].[ConteoDetalle]
    ADD CONSTRAINT [FK_ConteoDetalle_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_ConteoDetalle_Conteo]...';


GO
ALTER TABLE [ALMA].[ConteoDetalle]
    ADD CONSTRAINT [FK_ConteoDetalle_Conteo] FOREIGN KEY ([FKIdConteo_ALMA]) REFERENCES [ALMA].[Conteo] ([PKIdConteo]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_ConteoDetalle_UsuarioCreacion]...';


GO
ALTER TABLE [ALMA].[ConteoDetalle]
    ADD CONSTRAINT [FK_ConteoDetalle_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_ConteoDetalle_Persona]...';


GO
ALTER TABLE [ALMA].[ConteoDetalle]
    ADD CONSTRAINT [FK_ConteoDetalle_Persona] FOREIGN KEY ([FKIdPersona_NOM]) REFERENCES [NOM].[Persona] ([PKIdPersona]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_MotivoES_UsuarioModificacion]...';


GO
ALTER TABLE [ALMA].[MotivoES]
    ADD CONSTRAINT [FK_MotivoES_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ALMA].[FK_MotivoES_UsuarioCreacion]...';


GO
ALTER TABLE [ALMA].[MotivoES]
    ADD CONSTRAINT [FK_MotivoES_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_Concepto_UsuarioCreacion]...';


GO
ALTER TABLE [CONTA].[Concepto]
    ADD CONSTRAINT [FK_Concepto_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_Concepto_UsuarioModificacion]...';


GO
ALTER TABLE [CONTA].[Concepto]
    ADD CONSTRAINT [FK_Concepto_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_Concepto_Capitulo]...';


GO
ALTER TABLE [CONTA].[Concepto]
    ADD CONSTRAINT [FK_Concepto_Capitulo] FOREIGN KEY ([FKIdCapitulo_CONTA]) REFERENCES [CONTA].[Capitulo] ([PKIdCapitulo]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_MatrizIngreso_UsuarioCreacion]...';


GO
ALTER TABLE [CONTA].[MatrizIngreso]
    ADD CONSTRAINT [FK_MatrizIngreso_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_MatrizIngreso_CtaModificado]...';


GO
ALTER TABLE [CONTA].[MatrizIngreso]
    ADD CONSTRAINT [FK_MatrizIngreso_CtaModificado] FOREIGN KEY ([Fk_IdCuentaContableModificado]) REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_MatrizIngreso_CtaDevengado]...';


GO
ALTER TABLE [CONTA].[MatrizIngreso]
    ADD CONSTRAINT [FK_MatrizIngreso_CtaDevengado] FOREIGN KEY ([Fk_IdCuentaContableDevengado]) REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_MatrizIngreso_CtaAutorizado]...';


GO
ALTER TABLE [CONTA].[MatrizIngreso]
    ADD CONSTRAINT [FK_MatrizIngreso_CtaAutorizado] FOREIGN KEY ([Fk_IdCuentaContableAutorizado]) REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_MatrizIngreso_CtaRecaudado]...';


GO
ALTER TABLE [CONTA].[MatrizIngreso]
    ADD CONSTRAINT [FK_MatrizIngreso_CtaRecaudado] FOREIGN KEY ([Fk_IdCuentaContableRecaudado]) REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_MatrizIngreso_CtaPorEjercer]...';


GO
ALTER TABLE [CONTA].[MatrizIngreso]
    ADD CONSTRAINT [FK_MatrizIngreso_CtaPorEjercer] FOREIGN KEY ([Fk_IdCuentaContablePorEjercer]) REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_MatrizIngreso_Anio]...';


GO
ALTER TABLE [CONTA].[MatrizIngreso]
    ADD CONSTRAINT [FK_MatrizIngreso_Anio] FOREIGN KEY ([FK_IdAnio__SIS]) REFERENCES [SIS].[Anio] ([PKIdAnio]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_MatrizIngreso_Programa]...';


GO
ALTER TABLE [CONTA].[MatrizIngreso]
    ADD CONSTRAINT [FK_MatrizIngreso_Programa] FOREIGN KEY ([Fk_IdPrograma]) REFERENCES [PRES].[Programa] ([PKIdPrograma]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_MatrizIngreso_Origen]...';


GO
ALTER TABLE [CONTA].[MatrizIngreso]
    ADD CONSTRAINT [FK_MatrizIngreso_Origen] FOREIGN KEY ([Fk_IdOrigen]) REFERENCES [PRES].[Origen] ([PKIdOrigen]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_MatrizIngreso_UsuarioModificacion]...';


GO
ALTER TABLE [CONTA].[MatrizIngreso]
    ADD CONSTRAINT [FK_MatrizIngreso_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_MatrizIngreso_CtaDeposito]...';


GO
ALTER TABLE [CONTA].[MatrizIngreso]
    ADD CONSTRAINT [FK_MatrizIngreso_CtaDeposito] FOREIGN KEY ([Fk_IdCuentaContableDeposito]) REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_Poliza_TipoPoliza]...';


GO
ALTER TABLE [CONTA].[Poliza]
    ADD CONSTRAINT [FK_Poliza_TipoPoliza] FOREIGN KEY ([FKIdTipoPoliza_SIS]) REFERENCES [SIS].[TipoPoliza] ([PKIdTipoPoliza]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_Poliza_Anio]...';


GO
ALTER TABLE [CONTA].[Poliza]
    ADD CONSTRAINT [FK_Poliza_Anio] FOREIGN KEY ([FKIdAnio_SIS]) REFERENCES [SIS].[Anio] ([PKIdAnio]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_Poliza_UsuarioModificacion]...';


GO
ALTER TABLE [CONTA].[Poliza]
    ADD CONSTRAINT [FK_Poliza_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_Poliza_UsuarioCreacion]...';


GO
ALTER TABLE [CONTA].[Poliza]
    ADD CONSTRAINT [FK_Poliza_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_MatrizConversion_CtaAprobado]...';


GO
ALTER TABLE [CONTA].[MatrizConversion]
    ADD CONSTRAINT [FK_MatrizConversion_CtaAprobado] FOREIGN KEY ([FKIdCuentaContableAprobado]) REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_MatrizConversion_CtaDevengado]...';


GO
ALTER TABLE [CONTA].[MatrizConversion]
    ADD CONSTRAINT [FK_MatrizConversion_CtaDevengado] FOREIGN KEY ([FKIdCuentaContableDevengado]) REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_MatrizConversion_UsuarioModificacion]...';


GO
ALTER TABLE [CONTA].[MatrizConversion]
    ADD CONSTRAINT [FK_MatrizConversion_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_MatrizConversion_Partida]...';


GO
ALTER TABLE [CONTA].[MatrizConversion]
    ADD CONSTRAINT [FK_MatrizConversion_Partida] FOREIGN KEY ([FKIdPartida_SIS]) REFERENCES [SIS].[Partida] ([PKIdPartida]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_MatrizConversion_CtaGasto]...';


GO
ALTER TABLE [CONTA].[MatrizConversion]
    ADD CONSTRAINT [FK_MatrizConversion_CtaGasto] FOREIGN KEY ([FKIdCuentaContableGasto]) REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_MatrizConversion_CtaPagado]...';


GO
ALTER TABLE [CONTA].[MatrizConversion]
    ADD CONSTRAINT [FK_MatrizConversion_CtaPagado] FOREIGN KEY ([FKIdCuentaContablePagado]) REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_MatrizConversion_CtaComprometido]...';


GO
ALTER TABLE [CONTA].[MatrizConversion]
    ADD CONSTRAINT [FK_MatrizConversion_CtaComprometido] FOREIGN KEY ([FKIdCuentaContableComprometido]) REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_MatrizConversion_Anio]...';


GO
ALTER TABLE [CONTA].[MatrizConversion]
    ADD CONSTRAINT [FK_MatrizConversion_Anio] FOREIGN KEY ([FKIdAnio_SIS]) REFERENCES [SIS].[Anio] ([PKIdAnio]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_MatrizConversion_CtaEjercido]...';


GO
ALTER TABLE [CONTA].[MatrizConversion]
    ADD CONSTRAINT [FK_MatrizConversion_CtaEjercido] FOREIGN KEY ([FKIdCuentaContableEjercido]) REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_MatrizConversion_UsuarioCreacion]...';


GO
ALTER TABLE [CONTA].[MatrizConversion]
    ADD CONSTRAINT [FK_MatrizConversion_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_MatrizConversion_CtaPorEjercer]...';


GO
ALTER TABLE [CONTA].[MatrizConversion]
    ADD CONSTRAINT [FK_MatrizConversion_CtaPorEjercer] FOREIGN KEY ([FKIdCuentaContablePorEjercer]) REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_MatrizConversion_Programa]...';


GO
ALTER TABLE [CONTA].[MatrizConversion]
    ADD CONSTRAINT [FK_MatrizConversion_Programa] FOREIGN KEY ([FKIdPrograma_PRES]) REFERENCES [PRES].[Programa] ([PKIdPrograma]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_MatrizConversion_CtaModificado]...';


GO
ALTER TABLE [CONTA].[MatrizConversion]
    ADD CONSTRAINT [FK_MatrizConversion_CtaModificado] FOREIGN KEY ([FKIdCuentaContableModificado]) REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_Capitulo_UsuarioModificacion]...';


GO
ALTER TABLE [CONTA].[Capitulo]
    ADD CONSTRAINT [FK_Capitulo_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_Capitulo_UsuarioCreacion]...';


GO
ALTER TABLE [CONTA].[Capitulo]
    ADD CONSTRAINT [FK_Capitulo_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_PolizaDetalle_UsuarioModificacion]...';


GO
ALTER TABLE [CONTA].[PolizaDetalle]
    ADD CONSTRAINT [FK_PolizaDetalle_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_PolizaDetalle_UsuarioCreacion]...';


GO
ALTER TABLE [CONTA].[PolizaDetalle]
    ADD CONSTRAINT [FK_PolizaDetalle_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_PolizaDetalle_CuentaContable]...';


GO
ALTER TABLE [CONTA].[PolizaDetalle]
    ADD CONSTRAINT [FK_PolizaDetalle_CuentaContable] FOREIGN KEY ([FKIdCuentaContable_CONTA]) REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_PolizaDetalle_TipoDetallePoliza]...';


GO
ALTER TABLE [CONTA].[PolizaDetalle]
    ADD CONSTRAINT [FK_PolizaDetalle_TipoDetallePoliza] FOREIGN KEY ([FKIdTipoDetallePoliza_SIS]) REFERENCES [SIS].[TipoDetallePoliza] ([PkIdTipoDetallePoliza]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_PolizaDetalle_Poliza]...';


GO
ALTER TABLE [CONTA].[PolizaDetalle]
    ADD CONSTRAINT [FK_PolizaDetalle_Poliza] FOREIGN KEY ([FKIdPoliza_CONTA]) REFERENCES [CONTA].[Poliza] ([PKIdPoliza]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_ConsecutivoPoliza_TipoPoliza]...';


GO
ALTER TABLE [CONTA].[ConsecutivoPoliza]
    ADD CONSTRAINT [FK_ConsecutivoPoliza_TipoPoliza] FOREIGN KEY ([FK_IdTipoPoliza__SIS]) REFERENCES [SIS].[TipoPoliza] ([PKIdTipoPoliza]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_ConsecutivoPoliza_Anio]...';


GO
ALTER TABLE [CONTA].[ConsecutivoPoliza]
    ADD CONSTRAINT [FK_ConsecutivoPoliza_Anio] FOREIGN KEY ([FK_IdAnio__SIS]) REFERENCES [SIS].[Anio] ([PKIdAnio]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_TipoCuenta_UsuarioModificacion]...';


GO
ALTER TABLE [CONTA].[TipoCuenta]
    ADD CONSTRAINT [FK_TipoCuenta_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_TipoCuenta_UsuarioCreacion]...';


GO
ALTER TABLE [CONTA].[TipoCuenta]
    ADD CONSTRAINT [FK_TipoCuenta_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_CuentaContable_UsuarioModificacion]...';


GO
ALTER TABLE [CONTA].[CuentaContable]
    ADD CONSTRAINT [FK_CuentaContable_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_CuentaContable_TipoCuenta]...';


GO
ALTER TABLE [CONTA].[CuentaContable]
    ADD CONSTRAINT [FK_CuentaContable_TipoCuenta] FOREIGN KEY ([FKIdTipoCuenta_CONTA]) REFERENCES [CONTA].[TipoCuenta] ([PKIdTipoCuenta]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_CuentaContable_UsuarioCreacion]...';


GO
ALTER TABLE [CONTA].[CuentaContable]
    ADD CONSTRAINT [FK_CuentaContable_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_CuentaContable_Empresa]...';


GO
ALTER TABLE [CONTA].[CuentaContable]
    ADD CONSTRAINT [FK_CuentaContable_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_Partida_UsuarioCreacion]...';


GO
ALTER TABLE [CONTA].[Partida]
    ADD CONSTRAINT [FK_Partida_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_Partida_Concepto]...';


GO
ALTER TABLE [CONTA].[Partida]
    ADD CONSTRAINT [FK_Partida_Concepto] FOREIGN KEY ([FKIdConcepto_SIS]) REFERENCES [CONTA].[Concepto] ([PKIdConcepto]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_Partida_UsuarioModificacion]...';


GO
ALTER TABLE [CONTA].[Partida]
    ADD CONSTRAINT [FK_Partida_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_TipoDoctoPago_UsuarioModificacion]...';


GO
ALTER TABLE [CONTA].[TipoDoctoPago]
    ADD CONSTRAINT [FK_TipoDoctoPago_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [CONTA].[FK_TipoDoctoPago_UsuarioCreacion]...';


GO
ALTER TABLE [CONTA].[TipoDoctoPago]
    ADD CONSTRAINT [FK_TipoDoctoPago_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [NOM].[FK_Persona_UsuarioCreacion]...';


GO
ALTER TABLE [NOM].[Persona]
    ADD CONSTRAINT [FK_Persona_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [NOM].[FK_Persona_UsuarioModificacion]...';


GO
ALTER TABLE [NOM].[Persona]
    ADD CONSTRAINT [FK_Persona_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [NOM].[FK_PersonaArea_UsuarioModificacion]...';


GO
ALTER TABLE [NOM].[PersonaArea]
    ADD CONSTRAINT [FK_PersonaArea_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [NOM].[FK_PersonaArea_Area]...';


GO
ALTER TABLE [NOM].[PersonaArea]
    ADD CONSTRAINT [FK_PersonaArea_Area] FOREIGN KEY ([FKIdArea_SIS]) REFERENCES [SIS].[Area] ([PKIdArea]);


GO
PRINT N'Creando Clave externa [NOM].[FK_PersonaArea_UsuarioCreacion]...';


GO
ALTER TABLE [NOM].[PersonaArea]
    ADD CONSTRAINT [FK_PersonaArea_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [NOM].[FK_PersonaArea_Persona]...';


GO
ALTER TABLE [NOM].[PersonaArea]
    ADD CONSTRAINT [FK_PersonaArea_Persona] FOREIGN KEY ([FKIdPersona_NOM]) REFERENCES [NOM].[Persona] ([PKIdPersona]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Articulo_UsuarioModificacion]...';


GO
ALTER TABLE [ORCO].[Articulo]
    ADD CONSTRAINT [FK_Articulo_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Articulo_UsuarioCreacion]...';


GO
ALTER TABLE [ORCO].[Articulo]
    ADD CONSTRAINT [FK_Articulo_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_RequisicionPartida_Partida]...';


GO
ALTER TABLE [ORCO].[RequisicionPartida]
    ADD CONSTRAINT [FK_RequisicionPartida_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_RequisicionPartida_UsuarioCreacion]...';


GO
ALTER TABLE [ORCO].[RequisicionPartida]
    ADD CONSTRAINT [FK_RequisicionPartida_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_RequisicionPartida_Empresa]...';


GO
ALTER TABLE [ORCO].[RequisicionPartida]
    ADD CONSTRAINT [FK_RequisicionPartida_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_RequisicionPartida_Requisicion]...';


GO
ALTER TABLE [ORCO].[RequisicionPartida]
    ADD CONSTRAINT [FK_RequisicionPartida_Requisicion] FOREIGN KEY ([FKIdRequisicion_ORCO]) REFERENCES [ORCO].[Requisicion] ([PKIdRequisicion]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_RequisicionPartida_UsuarioModificacion]...';


GO
ALTER TABLE [ORCO].[RequisicionPartida]
    ADD CONSTRAINT [FK_RequisicionPartida_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_PAAASPartida_Partida]...';


GO
ALTER TABLE [ORCO].[PAAASPartida]
    ADD CONSTRAINT [FK_PAAASPartida_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_PAAASPartida_UsuarioCreacion]...';


GO
ALTER TABLE [ORCO].[PAAASPartida]
    ADD CONSTRAINT [FK_PAAASPartida_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_PAAASPartida_UsuarioModificacion]...';


GO
ALTER TABLE [ORCO].[PAAASPartida]
    ADD CONSTRAINT [FK_PAAASPartida_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_PAAASPartida_PAAAS]...';


GO
ALTER TABLE [ORCO].[PAAASPartida]
    ADD CONSTRAINT [FK_PAAASPartida_PAAAS] FOREIGN KEY ([FKIdPAAAS_ORCO]) REFERENCES [ORCO].[PAAAS] ([PKIdPAAAS]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_PAAASPartida_Empresa]...';


GO
ALTER TABLE [ORCO].[PAAASPartida]
    ADD CONSTRAINT [FK_PAAASPartida_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_TipoContrato_UsuarioModificacion]...';


GO
ALTER TABLE [ORCO].[TipoContrato]
    ADD CONSTRAINT [FK_TipoContrato_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_TipoContrato_UsuarioCreacion]...';


GO
ALTER TABLE [ORCO].[TipoContrato]
    ADD CONSTRAINT [FK_TipoContrato_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_EstudioMercadoDetalleCosto_UsuarioModificacion]...';


GO
ALTER TABLE [ORCO].[EstudioMercadoDetalleCosto]
    ADD CONSTRAINT [FK_EstudioMercadoDetalleCosto_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_EstudioMercadoDetalleCosto_SolicitudCotizacion]...';


GO
ALTER TABLE [ORCO].[EstudioMercadoDetalleCosto]
    ADD CONSTRAINT [FK_EstudioMercadoDetalleCosto_SolicitudCotizacion] FOREIGN KEY ([FKIdSolicitudCotizacion_ORCO]) REFERENCES [ORCO].[SolicitudCotizacion] ([PKIdSolicitudCotizacion]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_EstudioMercadoDetalleCosto_UsuarioCreacion]...';


GO
ALTER TABLE [ORCO].[EstudioMercadoDetalleCosto]
    ADD CONSTRAINT [FK_EstudioMercadoDetalleCosto_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_EstudioMercadoDetalleCosto_Empresa]...';


GO
ALTER TABLE [ORCO].[EstudioMercadoDetalleCosto]
    ADD CONSTRAINT [FK_EstudioMercadoDetalleCosto_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_EstudioMercadoDetalleCosto_EstudioMercadoDetalle]...';


GO
ALTER TABLE [ORCO].[EstudioMercadoDetalleCosto]
    ADD CONSTRAINT [FK_EstudioMercadoDetalleCosto_EstudioMercadoDetalle] FOREIGN KEY ([FKIdEstudioMercadoDetalle_ORCO]) REFERENCES [ORCO].[EstudioMercadoDetalle] ([PKIdEstudioMercadoDetalle]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Requisicion_EgresoAutorizado]...';


GO
ALTER TABLE [ORCO].[Requisicion]
    ADD CONSTRAINT [FK_Requisicion_EgresoAutorizado] FOREIGN KEY ([FKIdEgresoAutorizado_PRES]) REFERENCES [PRES].[EgresoAutorizado] ([PKIdEgresoAutorizado]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Requisicion_Suficiencia]...';


GO
ALTER TABLE [ORCO].[Requisicion]
    ADD CONSTRAINT [FK_Requisicion_Suficiencia] FOREIGN KEY ([FKIdSuficiencia_PRES]) REFERENCES [PRES].[Suficiencia] ([PKIdSuficiencia]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Requisicion_JefeAlmacen]...';


GO
ALTER TABLE [ORCO].[Requisicion]
    ADD CONSTRAINT [FK_Requisicion_JefeAlmacen] FOREIGN KEY ([FKIdJefeAlmacen_NOM]) REFERENCES [NOM].[Persona] ([PKIdPersona]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Requisicion_PSolicita]...';


GO
ALTER TABLE [ORCO].[Requisicion]
    ADD CONSTRAINT [FK_Requisicion_PSolicita] FOREIGN KEY ([FKIdPSolicita_NOM]) REFERENCES [NOM].[Persona] ([PKIdPersona]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Requisicion_PJefeAlmacen]...';


GO
ALTER TABLE [ORCO].[Requisicion]
    ADD CONSTRAINT [FK_Requisicion_PJefeAlmacen] FOREIGN KEY ([FKIdPJefeAlmacen_NOM]) REFERENCES [NOM].[Persona] ([PKIdPersona]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Requisicion_Area]...';


GO
ALTER TABLE [ORCO].[Requisicion]
    ADD CONSTRAINT [FK_Requisicion_Area] FOREIGN KEY ([FKIdArea_SIS]) REFERENCES [SIS].[Area] ([PKIdArea]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Requisicion_Empresa]...';


GO
ALTER TABLE [ORCO].[Requisicion]
    ADD CONSTRAINT [FK_Requisicion_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Requisicion_PAutorizo]...';


GO
ALTER TABLE [ORCO].[Requisicion]
    ADD CONSTRAINT [FK_Requisicion_PAutorizo] FOREIGN KEY ([FKIdPAutorizo_NOM]) REFERENCES [NOM].[Persona] ([PKIdPersona]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Requisicion_Programa]...';


GO
ALTER TABLE [ORCO].[Requisicion]
    ADD CONSTRAINT [FK_Requisicion_Programa] FOREIGN KEY ([FKIdPrograma_PRES]) REFERENCES [PRES].[Programa] ([PKIdPrograma]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Requisicion_PSuficiencia]...';


GO
ALTER TABLE [ORCO].[Requisicion]
    ADD CONSTRAINT [FK_Requisicion_PSuficiencia] FOREIGN KEY ([FKIdPSuficiencia_NOM]) REFERENCES [NOM].[Persona] ([PKIdPersona]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Requisicion_Autorizo]...';


GO
ALTER TABLE [ORCO].[Requisicion]
    ADD CONSTRAINT [FK_Requisicion_Autorizo] FOREIGN KEY ([FKIdAutorizo_NOM]) REFERENCES [NOM].[Persona] ([PKIdPersona]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Requisicion_UsuarioCreacion]...';


GO
ALTER TABLE [ORCO].[Requisicion]
    ADD CONSTRAINT [FK_Requisicion_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Requisicion_UsuarioModificacion]...';


GO
ALTER TABLE [ORCO].[Requisicion]
    ADD CONSTRAINT [FK_Requisicion_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Requisicion_Proyecto]...';


GO
ALTER TABLE [ORCO].[Requisicion]
    ADD CONSTRAINT [FK_Requisicion_Proyecto] FOREIGN KEY ([FKIdProyecto_ORCO]) REFERENCES [ORCO].[Proyecto] ([PKIdProyecto]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Requisicion_Persona]...';


GO
ALTER TABLE [ORCO].[Requisicion]
    ADD CONSTRAINT [FK_Requisicion_Persona] FOREIGN KEY ([FKIdPersona_NOM]) REFERENCES [NOM].[Persona] ([PKIdPersona]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Requisicion_DestinoGasto]...';


GO
ALTER TABLE [ORCO].[Requisicion]
    ADD CONSTRAINT [FK_Requisicion_DestinoGasto] FOREIGN KEY ([FKIdDestinoGasto_PRES]) REFERENCES [PRES].[DestinoGasto] ([PKIdDestinoGasto]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Requisicion_Superviso]...';


GO
ALTER TABLE [ORCO].[Requisicion]
    ADD CONSTRAINT [FK_Requisicion_Superviso] FOREIGN KEY ([FKIdSuperviso_NOM]) REFERENCES [NOM].[Persona] ([PKIdPersona]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Requisicion_DigitoIdentificador]...';


GO
ALTER TABLE [ORCO].[Requisicion]
    ADD CONSTRAINT [FK_Requisicion_DigitoIdentificador] FOREIGN KEY ([FKIdDigitoIdentificador_PRES]) REFERENCES [PRES].[DigitoIdentificador] ([PKIdDigitoIdentificador]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Requisicion_TipoGasto]...';


GO
ALTER TABLE [ORCO].[Requisicion]
    ADD CONSTRAINT [FK_Requisicion_TipoGasto] FOREIGN KEY ([FKIdTipoGasto_PRES]) REFERENCES [PRES].[TipoGasto] ([PKIdTipoGasto]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Requisicion_FuenteFinanciamiento]...';


GO
ALTER TABLE [ORCO].[Requisicion]
    ADD CONSTRAINT [FK_Requisicion_FuenteFinanciamiento] FOREIGN KEY ([FKIdFuenteFinanciamiento_PRES]) REFERENCES [PRES].[FuenteFinanciamiento] ([PKIdFuenteFinanciamiento]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Requisicion_PSuperviso]...';


GO
ALTER TABLE [ORCO].[Requisicion]
    ADD CONSTRAINT [FK_Requisicion_PSuperviso] FOREIGN KEY ([FKIdPSuperviso_NOM]) REFERENCES [NOM].[Persona] ([PKIdPersona]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Requisicion_Anio]...';


GO
ALTER TABLE [ORCO].[Requisicion]
    ADD CONSTRAINT [FK_Requisicion_Anio] FOREIGN KEY ([FKIdAnio_SIS]) REFERENCES [SIS].[Anio] ([PKIdAnio]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_PAAAS_Programa]...';


GO
ALTER TABLE [ORCO].[PAAAS]
    ADD CONSTRAINT [FK_PAAAS_Programa] FOREIGN KEY ([FKIdPrograma_PRES]) REFERENCES [PRES].[Programa] ([PKIdPrograma]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_PAAAS_Persona]...';


GO
ALTER TABLE [ORCO].[PAAAS]
    ADD CONSTRAINT [FK_PAAAS_Persona] FOREIGN KEY ([FKIdPersona_NOM]) REFERENCES [NOM].[Persona] ([PKIdPersona]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_PAAAS_UsuarioCreacion]...';


GO
ALTER TABLE [ORCO].[PAAAS]
    ADD CONSTRAINT [FK_PAAAS_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_PAAAS_Proyecto]...';


GO
ALTER TABLE [ORCO].[PAAAS]
    ADD CONSTRAINT [FK_PAAAS_Proyecto] FOREIGN KEY ([FKIdProyecto_ORCO]) REFERENCES [ORCO].[Proyecto] ([PKIdProyecto]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_PAAAS_Area]...';


GO
ALTER TABLE [ORCO].[PAAAS]
    ADD CONSTRAINT [FK_PAAAS_Area] FOREIGN KEY ([FKIdArea_SIS]) REFERENCES [SIS].[Area] ([PKIdArea]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_PAAAS_Anio]...';


GO
ALTER TABLE [ORCO].[PAAAS]
    ADD CONSTRAINT [FK_PAAAS_Anio] FOREIGN KEY ([FKIdAnio_SIS]) REFERENCES [SIS].[Anio] ([PKIdAnio]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_PAAAS_UsuarioModificacion]...';


GO
ALTER TABLE [ORCO].[PAAAS]
    ADD CONSTRAINT [FK_PAAAS_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_PAAAS_FuenteFinanciamiento]...';


GO
ALTER TABLE [ORCO].[PAAAS]
    ADD CONSTRAINT [FK_PAAAS_FuenteFinanciamiento] FOREIGN KEY ([FKIdFuenteFinanciamiento_PRES]) REFERENCES [PRES].[FuenteFinanciamiento] ([PKIdFuenteFinanciamiento]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_PAAAS_Empresa]...';


GO
ALTER TABLE [ORCO].[PAAAS]
    ADD CONSTRAINT [FK_PAAAS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_RequisicionDetalle_UsuarioModificacion]...';


GO
ALTER TABLE [ORCO].[RequisicionDetalle]
    ADD CONSTRAINT [FK_RequisicionDetalle_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_RequisicionDetalle_Empresa]...';


GO
ALTER TABLE [ORCO].[RequisicionDetalle]
    ADD CONSTRAINT [FK_RequisicionDetalle_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_RequisicionDetalle_Unidades]...';


GO
ALTER TABLE [ORCO].[RequisicionDetalle]
    ADD CONSTRAINT [FK_RequisicionDetalle_Unidades] FOREIGN KEY ([FKIdUnidades_ALMA]) REFERENCES [ALMA].[Unidades] ([PKIdUnidades]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_RequisicionDetalle_Requisicion]...';


GO
ALTER TABLE [ORCO].[RequisicionDetalle]
    ADD CONSTRAINT [FK_RequisicionDetalle_Requisicion] FOREIGN KEY ([FKIdRequisicion_ORCO]) REFERENCES [ORCO].[Requisicion] ([PKIdRequisicion]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_RequisicionDetalle_TipoBien]...';


GO
ALTER TABLE [ORCO].[RequisicionDetalle]
    ADD CONSTRAINT [FK_RequisicionDetalle_TipoBien] FOREIGN KEY ([FKIdTipoBien_ALMA]) REFERENCES [ALMA].[TipoBien] ([PKIdTipoBien]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_RequisicionDetalle_UsuarioCreacion]...';


GO
ALTER TABLE [ORCO].[RequisicionDetalle]
    ADD CONSTRAINT [FK_RequisicionDetalle_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Cotizacion_Anio]...';


GO
ALTER TABLE [ORCO].[Cotizacion]
    ADD CONSTRAINT [FK_Cotizacion_Anio] FOREIGN KEY ([FKIdAnio_SIS]) REFERENCES [SIS].[Anio] ([PKIdAnio]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Cotizacion_Proveedor]...';


GO
ALTER TABLE [ORCO].[Cotizacion]
    ADD CONSTRAINT [FK_Cotizacion_Proveedor] FOREIGN KEY ([FKIdProveedor_SIS]) REFERENCES [SIS].[Proveedor] ([PKIdProveedor]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Cotizacion_Requisicion]...';


GO
ALTER TABLE [ORCO].[Cotizacion]
    ADD CONSTRAINT [FK_Cotizacion_Requisicion] FOREIGN KEY ([FKIdRequisicion_ORCO]) REFERENCES [ORCO].[Requisicion] ([PKIdRequisicion]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Cotizacion_UsuarioCreacion]...';


GO
ALTER TABLE [ORCO].[Cotizacion]
    ADD CONSTRAINT [FK_Cotizacion_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Cotizacion_UsuarioModificacion]...';


GO
ALTER TABLE [ORCO].[Cotizacion]
    ADD CONSTRAINT [FK_Cotizacion_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_EstudioMercado_Anio]...';


GO
ALTER TABLE [ORCO].[EstudioMercado]
    ADD CONSTRAINT [FK_EstudioMercado_Anio] FOREIGN KEY ([FKIdAnio_SIS]) REFERENCES [SIS].[Anio] ([PKIdAnio]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_EstudioMercado_Empresa]...';


GO
ALTER TABLE [ORCO].[EstudioMercado]
    ADD CONSTRAINT [FK_EstudioMercado_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_EstudioMercado_UsuarioCreacion]...';


GO
ALTER TABLE [ORCO].[EstudioMercado]
    ADD CONSTRAINT [FK_EstudioMercado_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_EstudioMercado_Responsable]...';


GO
ALTER TABLE [ORCO].[EstudioMercado]
    ADD CONSTRAINT [FK_EstudioMercado_Responsable] FOREIGN KEY ([FKIdResponsable_NOM]) REFERENCES [NOM].[Persona] ([PKIdPersona]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_EstudioMercado_UsuarioModificacion]...';


GO
ALTER TABLE [ORCO].[EstudioMercado]
    ADD CONSTRAINT [FK_EstudioMercado_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_ProcedimientoContratacion_UsuarioModificacion]...';


GO
ALTER TABLE [ORCO].[ProcedimientoContratacion]
    ADD CONSTRAINT [FK_ProcedimientoContratacion_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_ProcedimientoContratacion_UsuarioCreacion]...';


GO
ALTER TABLE [ORCO].[ProcedimientoContratacion]
    ADD CONSTRAINT [FK_ProcedimientoContratacion_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_TipoGarantia_UsuarioModificacion]...';


GO
ALTER TABLE [ORCO].[TipoGarantia]
    ADD CONSTRAINT [FK_TipoGarantia_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_TipoGarantia_UsuarioCreacion]...';


GO
ALTER TABLE [ORCO].[TipoGarantia]
    ADD CONSTRAINT [FK_TipoGarantia_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_SolicitudCotizacion_Empresa]...';


GO
ALTER TABLE [ORCO].[SolicitudCotizacion]
    ADD CONSTRAINT [FK_SolicitudCotizacion_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_SolicitudCotizacion_EstudioMercado]...';


GO
ALTER TABLE [ORCO].[SolicitudCotizacion]
    ADD CONSTRAINT [FK_SolicitudCotizacion_EstudioMercado] FOREIGN KEY ([FKIdEstudioMercado_ORCO]) REFERENCES [ORCO].[EstudioMercado] ([PKIdEstudioMercado]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_SolicitudCotizacion_UsuarioCreacion]...';


GO
ALTER TABLE [ORCO].[SolicitudCotizacion]
    ADD CONSTRAINT [FK_SolicitudCotizacion_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_SolicitudCotizacion_UsuarioModificacion]...';


GO
ALTER TABLE [ORCO].[SolicitudCotizacion]
    ADD CONSTRAINT [FK_SolicitudCotizacion_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_SolicitudCotizacion_Proveedor]...';


GO
ALTER TABLE [ORCO].[SolicitudCotizacion]
    ADD CONSTRAINT [FK_SolicitudCotizacion_Proveedor] FOREIGN KEY ([FKIdProveedor_SIS]) REFERENCES [SIS].[Proveedor] ([PKIdProveedor]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_CotizacionDetalle_UsuarioCreacion]...';


GO
ALTER TABLE [ORCO].[CotizacionDetalle]
    ADD CONSTRAINT [FK_CotizacionDetalle_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_CotizacionDetalle_UsuarioModificacion]...';


GO
ALTER TABLE [ORCO].[CotizacionDetalle]
    ADD CONSTRAINT [FK_CotizacionDetalle_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_CotizacionDetalle_Cotizacion]...';


GO
ALTER TABLE [ORCO].[CotizacionDetalle]
    ADD CONSTRAINT [FK_CotizacionDetalle_Cotizacion] FOREIGN KEY ([FKIdCotizacion_ORCO]) REFERENCES [ORCO].[Cotizacion] ([PKIdCotizacion]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_CotizacionDetalle_RequisicionDetalle]...';


GO
ALTER TABLE [ORCO].[CotizacionDetalle]
    ADD CONSTRAINT [FK_CotizacionDetalle_RequisicionDetalle] FOREIGN KEY ([FKIdRequisicionDetalle_ORCO]) REFERENCES [ORCO].[RequisicionDetalle] ([PKIdRequisicionDetalle]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_EstatusRequisicion_UsuarioCreacion]...';


GO
ALTER TABLE [ORCO].[EstatusRequisicion]
    ADD CONSTRAINT [FK_EstatusRequisicion_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_EstatusRequisicion_UsuarioModificacion]...';


GO
ALTER TABLE [ORCO].[EstatusRequisicion]
    ADD CONSTRAINT [FK_EstatusRequisicion_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_PAAASDetalle_Unidades]...';


GO
ALTER TABLE [ORCO].[PAAASDetalle]
    ADD CONSTRAINT [FK_PAAASDetalle_Unidades] FOREIGN KEY ([FKIdUnidades_ALMA]) REFERENCES [ALMA].[Unidades] ([PKIdUnidades]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_PAAASDetalle_TipoBien]...';


GO
ALTER TABLE [ORCO].[PAAASDetalle]
    ADD CONSTRAINT [FK_PAAASDetalle_TipoBien] FOREIGN KEY ([FKIdTipoBien_ALMA]) REFERENCES [ALMA].[TipoBien] ([PKIdTipoBien]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_PAAASDetalle_UsuarioCreacion]...';


GO
ALTER TABLE [ORCO].[PAAASDetalle]
    ADD CONSTRAINT [FK_PAAASDetalle_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_PAAASDetalle_Empresa]...';


GO
ALTER TABLE [ORCO].[PAAASDetalle]
    ADD CONSTRAINT [FK_PAAASDetalle_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_PAAASDetalle_UsuarioModificacion]...';


GO
ALTER TABLE [ORCO].[PAAASDetalle]
    ADD CONSTRAINT [FK_PAAASDetalle_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_PAAASDetalle_PAAASPartida]...';


GO
ALTER TABLE [ORCO].[PAAASDetalle]
    ADD CONSTRAINT [FK_PAAASDetalle_PAAASPartida] FOREIGN KEY ([FKIdPAAASPartida_ORCO]) REFERENCES [ORCO].[PAAASPartida] ([PKIdPAAASPartida]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Proyecto_UsuarioCreacion]...';


GO
ALTER TABLE [ORCO].[Proyecto]
    ADD CONSTRAINT [FK_Proyecto_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Proyecto_UsuarioModificacion]...';


GO
ALTER TABLE [ORCO].[Proyecto]
    ADD CONSTRAINT [FK_Proyecto_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Fraccion_Articulo]...';


GO
ALTER TABLE [ORCO].[Fraccion]
    ADD CONSTRAINT [FK_Fraccion_Articulo] FOREIGN KEY ([FKIdArticulo_ORCO]) REFERENCES [ORCO].[Articulo] ([PKIdArticulo]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Fraccion_UsuarioModificacion]...';


GO
ALTER TABLE [ORCO].[Fraccion]
    ADD CONSTRAINT [FK_Fraccion_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Fraccion_UsuarioCreacion]...';


GO
ALTER TABLE [ORCO].[Fraccion]
    ADD CONSTRAINT [FK_Fraccion_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Modalidad_UsuarioCreacion]...';


GO
ALTER TABLE [ORCO].[Modalidad]
    ADD CONSTRAINT [FK_Modalidad_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_Modalidad_UsuarioModificacion]...';


GO
ALTER TABLE [ORCO].[Modalidad]
    ADD CONSTRAINT [FK_Modalidad_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_EstudioMercadoDetalle_Empresa]...';


GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle]
    ADD CONSTRAINT [FK_EstudioMercadoDetalle_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_EstudioMercadoDetalle_Proveedor]...';


GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle]
    ADD CONSTRAINT [FK_EstudioMercadoDetalle_Proveedor] FOREIGN KEY ([FKIdProveedor_SIS]) REFERENCES [SIS].[Proveedor] ([PKIdProveedor]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_EstudioMercadoDetalle_TipoBien]...';


GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle]
    ADD CONSTRAINT [FK_EstudioMercadoDetalle_TipoBien] FOREIGN KEY ([FKIdTipoBien_ALMA]) REFERENCES [ALMA].[TipoBien] ([PKIdTipoBien]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_EstudioMercadoDetalle_EstudioMercado]...';


GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle]
    ADD CONSTRAINT [FK_EstudioMercadoDetalle_EstudioMercado] FOREIGN KEY ([FKIdEstudioMercado_ORCO]) REFERENCES [ORCO].[EstudioMercado] ([PKIdEstudioMercado]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_EstudioMercadoDetalle_PAAASDetalle]...';


GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle]
    ADD CONSTRAINT [FK_EstudioMercadoDetalle_PAAASDetalle] FOREIGN KEY ([FKIdPAAASDetalle_ORCO]) REFERENCES [ORCO].[PAAASDetalle] ([PKIdPAAASDetalle]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_EstudioMercadoDetalle_UsuarioCreacion]...';


GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle]
    ADD CONSTRAINT [FK_EstudioMercadoDetalle_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_EstudioMercadoDetalle_UsuarioModificacion]...';


GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle]
    ADD CONSTRAINT [FK_EstudioMercadoDetalle_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_TipoDocumento_UsuarioModificacion]...';


GO
ALTER TABLE [ORCO].[TipoDocumento]
    ADD CONSTRAINT [FK_TipoDocumento_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [ORCO].[FK_TipoDocumento_UsuarioCreacion]...';


GO
ALTER TABLE [ORCO].[TipoDocumento]
    ADD CONSTRAINT [FK_TipoDocumento_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_TipoGasto_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[TipoGasto]
    ADD CONSTRAINT [FK_TipoGasto_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_TipoGasto_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[TipoGasto]
    ADD CONSTRAINT [FK_TipoGasto_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_SolicitudSuficiencia_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[SolicitudSuficiencia]
    ADD CONSTRAINT [FK_SolicitudSuficiencia_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_SolicitudSuficiencia_Empresa]...';


GO
ALTER TABLE [PRES].[SolicitudSuficiencia]
    ADD CONSTRAINT [FK_SolicitudSuficiencia_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [PRES].[FK_SolicitudSuficiencia_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[SolicitudSuficiencia]
    ADD CONSTRAINT [FK_SolicitudSuficiencia_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_SolicitudSuficiencia_Requisicion]...';


GO
ALTER TABLE [PRES].[SolicitudSuficiencia]
    ADD CONSTRAINT [FK_SolicitudSuficiencia_Requisicion] FOREIGN KEY ([FKIdRequisicion_ORCO]) REFERENCES [ORCO].[Requisicion] ([PKIdRequisicion]);


GO
PRINT N'Creando Clave externa [PRES].[FK_PP_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[PP]
    ADD CONSTRAINT [FK_PP_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_PP_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[PP]
    ADD CONSTRAINT [FK_PP_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Programa_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[Programa]
    ADD CONSTRAINT [FK_Programa_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Programa_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[Programa]
    ADD CONSTRAINT [FK_Programa_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_DigitoIdentificador_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[DigitoIdentificador]
    ADD CONSTRAINT [FK_DigitoIdentificador_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_DigitoIdentificador_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[DigitoIdentificador]
    ADD CONSTRAINT [FK_DigitoIdentificador_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_EgresoAutorizado_PY]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [FK_EgresoAutorizado_PY] FOREIGN KEY ([FKIdPY_PRES]) REFERENCES [PRES].[PY] ([PKIdPY]);


GO
PRINT N'Creando Clave externa [PRES].[FK_EgresoAutorizado_Area]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [FK_EgresoAutorizado_Area] FOREIGN KEY ([FKIdArea_SIS]) REFERENCES [SIS].[Area] ([PKIdArea]);


GO
PRINT N'Creando Clave externa [PRES].[FK_EgresoAutorizado_FuenteFinanciamiento]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [FK_EgresoAutorizado_FuenteFinanciamiento] FOREIGN KEY ([FKIdFuenteFinanciamiento_PRES]) REFERENCES [PRES].[FuenteFinanciamiento] ([PKIdFuenteFinanciamiento]);


GO
PRINT N'Creando Clave externa [PRES].[FK_EgresoAutorizado_Programa]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [FK_EgresoAutorizado_Programa] FOREIGN KEY ([FKIdPrograma_PRES]) REFERENCES [PRES].[Programa] ([PKIdPrograma]);


GO
PRINT N'Creando Clave externa [PRES].[FK_EgresoAutorizado_EgresoProyectado]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [FK_EgresoAutorizado_EgresoProyectado] FOREIGN KEY ([FKIdEgresoProyectado_PRES]) REFERENCES [PRES].[EgresoProyectado] ([PKIdEgresoProyectado]);


GO
PRINT N'Creando Clave externa [PRES].[FK_EgresoAutorizado_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [FK_EgresoAutorizado_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_EgresoAutorizado_DigitoIdentificador]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [FK_EgresoAutorizado_DigitoIdentificador] FOREIGN KEY ([FKIdDigitoIdentificador_PRES]) REFERENCES [PRES].[DigitoIdentificador] ([PKIdDigitoIdentificador]);


GO
PRINT N'Creando Clave externa [PRES].[FK_EgresoAutorizado_Poliza]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [FK_EgresoAutorizado_Poliza] FOREIGN KEY ([FKIdPoliza_CONTA]) REFERENCES [CONTA].[Poliza] ([PKIdPoliza]);


GO
PRINT N'Creando Clave externa [PRES].[FK_EgresoAutorizado_UsuarioAutorizacion]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [FK_EgresoAutorizado_UsuarioAutorizacion] FOREIGN KEY ([UsuarioAutorizacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_EgresoAutorizado_TipoGasto]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [FK_EgresoAutorizado_TipoGasto] FOREIGN KEY ([FKIdTipoGasto_PRES]) REFERENCES [PRES].[TipoGasto] ([PKIdTipoGasto]);


GO
PRINT N'Creando Clave externa [PRES].[FK_EgresoAutorizado_DestinoGasto]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [FK_EgresoAutorizado_DestinoGasto] FOREIGN KEY ([FKIdDestinoGasto_PRES]) REFERENCES [PRES].[DestinoGasto] ([PKIdDestinoGasto]);


GO
PRINT N'Creando Clave externa [PRES].[FK_EgresoAutorizado_Partida]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [FK_EgresoAutorizado_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida]);


GO
PRINT N'Creando Clave externa [PRES].[FK_EgresoAutorizado_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[EgresoAutorizado]
    ADD CONSTRAINT [FK_EgresoAutorizado_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_FN_GF]...';


GO
ALTER TABLE [PRES].[FN]
    ADD CONSTRAINT [FK_FN_GF] FOREIGN KEY ([FKIdGF_PRES]) REFERENCES [PRES].[GF] ([PKIdGF]);


GO
PRINT N'Creando Clave externa [PRES].[FK_FN_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[FN]
    ADD CONSTRAINT [FK_FN_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_FN_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[FN]
    ADD CONSTRAINT [FK_FN_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_CLCDetalle_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[CLCDetalle]
    ADD CONSTRAINT [FK_CLCDetalle_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_CLCDetalle_ContratoDetalle]...';


GO
ALTER TABLE [PRES].[CLCDetalle]
    ADD CONSTRAINT [FK_CLCDetalle_ContratoDetalle] FOREIGN KEY ([FKIdContratoDetalle_PRES]) REFERENCES [PRES].[ContratoDetalle] ([PKIdContratoDetalle]);


GO
PRINT N'Creando Clave externa [PRES].[FK_CLCDetalle_Empresa]...';


GO
ALTER TABLE [PRES].[CLCDetalle]
    ADD CONSTRAINT [FK_CLCDetalle_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [PRES].[FK_CLCDetalle_CLC]...';


GO
ALTER TABLE [PRES].[CLCDetalle]
    ADD CONSTRAINT [FK_CLCDetalle_CLC] FOREIGN KEY ([FKIdCLC_PRES]) REFERENCES [PRES].[CLC] ([PKIdCLC]);


GO
PRINT N'Creando Clave externa [PRES].[FK_CLCDetalle_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[CLCDetalle]
    ADD CONSTRAINT [FK_CLCDetalle_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_CLCDetalle_Partida]...';


GO
ALTER TABLE [PRES].[CLCDetalle]
    ADD CONSTRAINT [FK_CLCDetalle_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida]);


GO
PRINT N'Creando Clave externa [PRES].[FK_TipoRecurso_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[TipoRecurso]
    ADD CONSTRAINT [FK_TipoRecurso_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_TipoRecurso_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[TipoRecurso]
    ADD CONSTRAINT [FK_TipoRecurso_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_ChequePartidas_Partida]...';


GO
ALTER TABLE [PRES].[ChequePartidas]
    ADD CONSTRAINT [FK_ChequePartidas_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida]);


GO
PRINT N'Creando Clave externa [PRES].[FK_ChequePartidas_CLCDetalle]...';


GO
ALTER TABLE [PRES].[ChequePartidas]
    ADD CONSTRAINT [FK_ChequePartidas_CLCDetalle] FOREIGN KEY ([FKIdCLCDetalle_PRES]) REFERENCES [PRES].[CLCDetalle] ([PKIdCLCDetalle]);


GO
PRINT N'Creando Clave externa [PRES].[FK_ChequePartidas_Empresa]...';


GO
ALTER TABLE [PRES].[ChequePartidas]
    ADD CONSTRAINT [FK_ChequePartidas_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [PRES].[FK_ChequePartidas_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[ChequePartidas]
    ADD CONSTRAINT [FK_ChequePartidas_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_ChequePartidas_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[ChequePartidas]
    ADD CONSTRAINT [FK_ChequePartidas_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_ChequePartidas_Cheque]...';


GO
ALTER TABLE [PRES].[ChequePartidas]
    ADD CONSTRAINT [FK_ChequePartidas_Cheque] FOREIGN KEY ([FKIdCheque_PRES]) REFERENCES [PRES].[Cheque] ([PKIdCheque]);


GO
PRINT N'Creando Clave externa [PRES].[FK_AutorizacionSuficienciaDetalle_Empresa]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle]
    ADD CONSTRAINT [FK_AutorizacionSuficienciaDetalle_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [PRES].[FK_AutorizacionSuficienciaDetalle_Autorizacion]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle]
    ADD CONSTRAINT [FK_AutorizacionSuficienciaDetalle_Autorizacion] FOREIGN KEY ([FKIdAutorizacionSuficiencia_PRES]) REFERENCES [PRES].[AutorizacionSuficiencia] ([PKIdAutorizacionSuficiencia]);


GO
PRINT N'Creando Clave externa [PRES].[FK_AutorizacionSuficienciaDetalle_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle]
    ADD CONSTRAINT [FK_AutorizacionSuficienciaDetalle_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_AutorizacionSuficienciaDetalle_Partida]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle]
    ADD CONSTRAINT [FK_AutorizacionSuficienciaDetalle_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida]);


GO
PRINT N'Creando Clave externa [PRES].[FK_AutorizacionSuficienciaDetalle_SolicitudDetalle]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle]
    ADD CONSTRAINT [FK_AutorizacionSuficienciaDetalle_SolicitudDetalle] FOREIGN KEY ([FKIdSolicitudSuficienciaDetalle_PRES]) REFERENCES [PRES].[SolicitudSuficienciaDetalle] ([PKIdSolicitudSuficienciaDetalle]);


GO
PRINT N'Creando Clave externa [PRES].[FK_AutorizacionSuficienciaDetalle_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle]
    ADD CONSTRAINT [FK_AutorizacionSuficienciaDetalle_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_SF_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[SF]
    ADD CONSTRAINT [FK_SF_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_SF_FN]...';


GO
ALTER TABLE [PRES].[SF]
    ADD CONSTRAINT [FK_SF_FN] FOREIGN KEY ([FKIdFN_PRES]) REFERENCES [PRES].[FN] ([PKIdFN]);


GO
PRINT N'Creando Clave externa [PRES].[FK_SF_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[SF]
    ADD CONSTRAINT [FK_SF_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_PY_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[PY]
    ADD CONSTRAINT [FK_PY_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_PY_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[PY]
    ADD CONSTRAINT [FK_PY_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_AutorizacionSuficiencia_AutorizadoPor]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficiencia]
    ADD CONSTRAINT [FK_AutorizacionSuficiencia_AutorizadoPor] FOREIGN KEY ([AutorizadoPor_NOM]) REFERENCES [NOM].[Persona] ([PKIdPersona]);


GO
PRINT N'Creando Clave externa [PRES].[FK_AutorizacionSuficiencia_Solicitud]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficiencia]
    ADD CONSTRAINT [FK_AutorizacionSuficiencia_Solicitud] FOREIGN KEY ([FKIdSolicitudSuficiencia_PRES]) REFERENCES [PRES].[SolicitudSuficiencia] ([PKIdSolicitudSuficiencia]);


GO
PRINT N'Creando Clave externa [PRES].[FK_AutorizacionSuficiencia_Empresa]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficiencia]
    ADD CONSTRAINT [FK_AutorizacionSuficiencia_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [PRES].[FK_AutorizacionSuficiencia_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficiencia]
    ADD CONSTRAINT [FK_AutorizacionSuficiencia_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_AutorizacionSuficiencia_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[AutorizacionSuficiencia]
    ADD CONSTRAINT [FK_AutorizacionSuficiencia_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Suficiencia_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[Suficiencia]
    ADD CONSTRAINT [FK_Suficiencia_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Suficiencia_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[Suficiencia]
    ADD CONSTRAINT [FK_Suficiencia_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Sector_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[Sector]
    ADD CONSTRAINT [FK_Sector_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Sector_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[Sector]
    ADD CONSTRAINT [FK_Sector_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Contrato_AutorizacionSuficiencia]...';


GO
ALTER TABLE [PRES].[Contrato]
    ADD CONSTRAINT [FK_Contrato_AutorizacionSuficiencia] FOREIGN KEY ([FKIdAutorizacionSuficiencia_PRES]) REFERENCES [PRES].[AutorizacionSuficiencia] ([PKIdAutorizacionSuficiencia]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Contrato_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[Contrato]
    ADD CONSTRAINT [FK_Contrato_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Contrato_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[Contrato]
    ADD CONSTRAINT [FK_Contrato_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Contrato_Proveedor]...';


GO
ALTER TABLE [PRES].[Contrato]
    ADD CONSTRAINT [FK_Contrato_Proveedor] FOREIGN KEY ([FKIdProveedor_SIS]) REFERENCES [SIS].[Proveedor] ([PKIdProveedor]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Contrato_Empresa]...';


GO
ALTER TABLE [PRES].[Contrato]
    ADD CONSTRAINT [FK_Contrato_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Contrato_Poliza]...';


GO
ALTER TABLE [PRES].[Contrato]
    ADD CONSTRAINT [FK_Contrato_Poliza] FOREIGN KEY ([FKIdPoliza_CONTA]) REFERENCES [CONTA].[Poliza] ([PKIdPoliza]);


GO
PRINT N'Creando Clave externa [PRES].[FK_SolicitudSuficienciaDetalle_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle]
    ADD CONSTRAINT [FK_SolicitudSuficienciaDetalle_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_SolicitudSuficienciaDetalle_Partida]...';


GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle]
    ADD CONSTRAINT [FK_SolicitudSuficienciaDetalle_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida]);


GO
PRINT N'Creando Clave externa [PRES].[FK_SolicitudSuficienciaDetalle_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle]
    ADD CONSTRAINT [FK_SolicitudSuficienciaDetalle_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_SolicitudSuficienciaDetalle_RequisicionDetalle]...';


GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle]
    ADD CONSTRAINT [FK_SolicitudSuficienciaDetalle_RequisicionDetalle] FOREIGN KEY ([FKIdRequisicionDetalle_ORCO]) REFERENCES [ORCO].[RequisicionDetalle] ([PKIdRequisicionDetalle]);


GO
PRINT N'Creando Clave externa [PRES].[FK_SolicitudSuficienciaDetalle_Solicitud]...';


GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle]
    ADD CONSTRAINT [FK_SolicitudSuficienciaDetalle_Solicitud] FOREIGN KEY ([FKIdSolicitudSuficiencia_PRES]) REFERENCES [PRES].[SolicitudSuficiencia] ([PKIdSolicitudSuficiencia]);


GO
PRINT N'Creando Clave externa [PRES].[FK_SolicitudSuficienciaDetalle_Empresa]...';


GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle]
    ADD CONSTRAINT [FK_SolicitudSuficienciaDetalle_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Cheque_CuentaBancaria]...';


GO
ALTER TABLE [PRES].[Cheque]
    ADD CONSTRAINT [FK_Cheque_CuentaBancaria] FOREIGN KEY ([FKIdCuentaBancaria_TES]) REFERENCES [TES].[CuentaBancaria] ([PKIdCuentaBancaria]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Cheque_CLC]...';


GO
ALTER TABLE [PRES].[Cheque]
    ADD CONSTRAINT [FK_Cheque_CLC] FOREIGN KEY ([FKIdCLC_PRES]) REFERENCES [PRES].[CLC] ([PKIdCLC]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Cheque_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[Cheque]
    ADD CONSTRAINT [FK_Cheque_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Cheque_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[Cheque]
    ADD CONSTRAINT [FK_Cheque_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Cheque_Empresa]...';


GO
ALTER TABLE [PRES].[Cheque]
    ADD CONSTRAINT [FK_Cheque_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Cheque_Poliza]...';


GO
ALTER TABLE [PRES].[Cheque]
    ADD CONSTRAINT [FK_Cheque_Poliza] FOREIGN KEY ([FKIdPoliza_CONTA]) REFERENCES [CONTA].[Poliza] ([PKIdPoliza]);


GO
PRINT N'Creando Clave externa [PRES].[FK_CLCFactura_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[CLCFactura]
    ADD CONSTRAINT [FK_CLCFactura_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_CLCFactura_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[CLCFactura]
    ADD CONSTRAINT [FK_CLCFactura_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_CLCFactura_Factura]...';


GO
ALTER TABLE [PRES].[CLCFactura]
    ADD CONSTRAINT [FK_CLCFactura_Factura] FOREIGN KEY ([FKIdFactura_PRES]) REFERENCES [PRES].[Factura] ([PKIdFactura]);


GO
PRINT N'Creando Clave externa [PRES].[FK_CLCFactura_FacturaDetalle]...';


GO
ALTER TABLE [PRES].[CLCFactura]
    ADD CONSTRAINT [FK_CLCFactura_FacturaDetalle] FOREIGN KEY ([FKIdFacturaDetalle_PRES]) REFERENCES [PRES].[FacturaDetalle] ([PKIdFacturaDetalle]);


GO
PRINT N'Creando Clave externa [PRES].[FK_CLCFactura_Empresa]...';


GO
ALTER TABLE [PRES].[CLCFactura]
    ADD CONSTRAINT [FK_CLCFactura_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [PRES].[FK_CLCFactura_CLC]...';


GO
ALTER TABLE [PRES].[CLCFactura]
    ADD CONSTRAINT [FK_CLCFactura_CLC] FOREIGN KEY ([FKIdCLC_PRES]) REFERENCES [PRES].[CLC] ([PKIdCLC]);


GO
PRINT N'Creando Clave externa [PRES].[FK_EgresoProyectado_DigitoIdentificador]...';


GO
ALTER TABLE [PRES].[EgresoProyectado]
    ADD CONSTRAINT [FK_EgresoProyectado_DigitoIdentificador] FOREIGN KEY ([FKIdDigitoIdentificador_PRES]) REFERENCES [PRES].[DigitoIdentificador] ([PKIdDigitoIdentificador]);


GO
PRINT N'Creando Clave externa [PRES].[FK_EgresoProyectado_TipoGasto]...';


GO
ALTER TABLE [PRES].[EgresoProyectado]
    ADD CONSTRAINT [FK_EgresoProyectado_TipoGasto] FOREIGN KEY ([FKIdTipoGasto_PRES]) REFERENCES [PRES].[TipoGasto] ([PKIdTipoGasto]);


GO
PRINT N'Creando Clave externa [PRES].[FK_EgresoProyectado_DestinoGasto]...';


GO
ALTER TABLE [PRES].[EgresoProyectado]
    ADD CONSTRAINT [FK_EgresoProyectado_DestinoGasto] FOREIGN KEY ([FKIdDestinoGasto_PRES]) REFERENCES [PRES].[DestinoGasto] ([PKIdDestinoGasto]);


GO
PRINT N'Creando Clave externa [PRES].[FK_EgresoProyectado_Partida]...';


GO
ALTER TABLE [PRES].[EgresoProyectado]
    ADD CONSTRAINT [FK_EgresoProyectado_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida]);


GO
PRINT N'Creando Clave externa [PRES].[FK_EgresoProyectado_FuenteFinanciamiento]...';


GO
ALTER TABLE [PRES].[EgresoProyectado]
    ADD CONSTRAINT [FK_EgresoProyectado_FuenteFinanciamiento] FOREIGN KEY ([FKIdFuenteFinanciamiento_PRES]) REFERENCES [PRES].[FuenteFinanciamiento] ([PKIdFuenteFinanciamiento]);


GO
PRINT N'Creando Clave externa [PRES].[FK_EgresoProyectado_Area]...';


GO
ALTER TABLE [PRES].[EgresoProyectado]
    ADD CONSTRAINT [FK_EgresoProyectado_Area] FOREIGN KEY ([FKIdArea_SIS]) REFERENCES [SIS].[Area] ([PKIdArea]);


GO
PRINT N'Creando Clave externa [PRES].[FK_EgresoProyectado_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[EgresoProyectado]
    ADD CONSTRAINT [FK_EgresoProyectado_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_EgresoProyectado_PY]...';


GO
ALTER TABLE [PRES].[EgresoProyectado]
    ADD CONSTRAINT [FK_EgresoProyectado_PY] FOREIGN KEY ([FKIdPY_PRES]) REFERENCES [PRES].[PY] ([PKIdPY]);


GO
PRINT N'Creando Clave externa [PRES].[FK_EgresoProyectado_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[EgresoProyectado]
    ADD CONSTRAINT [FK_EgresoProyectado_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_EgresoProyectado_Programa]...';


GO
ALTER TABLE [PRES].[EgresoProyectado]
    ADD CONSTRAINT [FK_EgresoProyectado_Programa] FOREIGN KEY ([FKIdPrograma_PRES]) REFERENCES [PRES].[Programa] ([PKIdPrograma]);


GO
PRINT N'Creando Clave externa [PRES].[FK_PG_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[PG]
    ADD CONSTRAINT [FK_PG_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_PG_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[PG]
    ADD CONSTRAINT [FK_PG_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Origen_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[Origen]
    ADD CONSTRAINT [FK_Origen_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Origen_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[Origen]
    ADD CONSTRAINT [FK_Origen_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Factura_Contrato]...';


GO
ALTER TABLE [PRES].[Factura]
    ADD CONSTRAINT [FK_Factura_Contrato] FOREIGN KEY ([FKIdContrato_PRES]) REFERENCES [PRES].[Contrato] ([PKIdContrato]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Factura_Poliza]...';


GO
ALTER TABLE [PRES].[Factura]
    ADD CONSTRAINT [FK_Factura_Poliza] FOREIGN KEY ([FKIdPoliza_CONTA]) REFERENCES [CONTA].[Poliza] ([PKIdPoliza]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Factura_Empresa]...';


GO
ALTER TABLE [PRES].[Factura]
    ADD CONSTRAINT [FK_Factura_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Factura_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[Factura]
    ADD CONSTRAINT [FK_Factura_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Factura_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[Factura]
    ADD CONSTRAINT [FK_Factura_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Ramo_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[Ramo]
    ADD CONSTRAINT [FK_Ramo_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_Ramo_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[Ramo]
    ADD CONSTRAINT [FK_Ramo_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_FuenteFinanciamiento_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[FuenteFinanciamiento]
    ADD CONSTRAINT [FK_FuenteFinanciamiento_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_FuenteFinanciamiento_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[FuenteFinanciamiento]
    ADD CONSTRAINT [FK_FuenteFinanciamiento_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_FacturaDetalle_ContratoDetalle]...';


GO
ALTER TABLE [PRES].[FacturaDetalle]
    ADD CONSTRAINT [FK_FacturaDetalle_ContratoDetalle] FOREIGN KEY ([FKIdContratoDetalle_PRES]) REFERENCES [PRES].[ContratoDetalle] ([PKIdContratoDetalle]);


GO
PRINT N'Creando Clave externa [PRES].[FK_FacturaDetalle_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[FacturaDetalle]
    ADD CONSTRAINT [FK_FacturaDetalle_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_FacturaDetalle_Factura]...';


GO
ALTER TABLE [PRES].[FacturaDetalle]
    ADD CONSTRAINT [FK_FacturaDetalle_Factura] FOREIGN KEY ([FKIdFactura_PRES]) REFERENCES [PRES].[Factura] ([PKIdFactura]);


GO
PRINT N'Creando Clave externa [PRES].[FK_FacturaDetalle_Empresa]...';


GO
ALTER TABLE [PRES].[FacturaDetalle]
    ADD CONSTRAINT [FK_FacturaDetalle_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [PRES].[FK_FacturaDetalle_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[FacturaDetalle]
    ADD CONSTRAINT [FK_FacturaDetalle_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_FacturaDetalle_Partida]...';


GO
ALTER TABLE [PRES].[FacturaDetalle]
    ADD CONSTRAINT [FK_FacturaDetalle_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida]);


GO
PRINT N'Creando Clave externa [PRES].[FK_CLC_Poliza]...';


GO
ALTER TABLE [PRES].[CLC]
    ADD CONSTRAINT [FK_CLC_Poliza] FOREIGN KEY ([FKIdPoliza_CONTA]) REFERENCES [CONTA].[Poliza] ([PKIdPoliza]);


GO
PRINT N'Creando Clave externa [PRES].[FK_CLC_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[CLC]
    ADD CONSTRAINT [FK_CLC_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_CLC_Contrato]...';


GO
ALTER TABLE [PRES].[CLC]
    ADD CONSTRAINT [FK_CLC_Contrato] FOREIGN KEY ([FKIdContrato_PRES]) REFERENCES [PRES].[Contrato] ([PKIdContrato]);


GO
PRINT N'Creando Clave externa [PRES].[FK_CLC_Empresa]...';


GO
ALTER TABLE [PRES].[CLC]
    ADD CONSTRAINT [FK_CLC_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [PRES].[FK_CLC_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[CLC]
    ADD CONSTRAINT [FK_CLC_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_GF_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[GF]
    ADD CONSTRAINT [FK_GF_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_GF_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[GF]
    ADD CONSTRAINT [FK_GF_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_ContratoDetalle_AutorizacionDetalle]...';


GO
ALTER TABLE [PRES].[ContratoDetalle]
    ADD CONSTRAINT [FK_ContratoDetalle_AutorizacionDetalle] FOREIGN KEY ([FKIdAutorizacionSuficienciaDetalle_PRES]) REFERENCES [PRES].[AutorizacionSuficienciaDetalle] ([PKIdAutorizacionSuficienciaDetalle]);


GO
PRINT N'Creando Clave externa [PRES].[FK_ContratoDetalle_Contrato]...';


GO
ALTER TABLE [PRES].[ContratoDetalle]
    ADD CONSTRAINT [FK_ContratoDetalle_Contrato] FOREIGN KEY ([FKIdContrato_PRES]) REFERENCES [PRES].[Contrato] ([PKIdContrato]);


GO
PRINT N'Creando Clave externa [PRES].[FK_ContratoDetalle_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[ContratoDetalle]
    ADD CONSTRAINT [FK_ContratoDetalle_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_ContratoDetalle_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[ContratoDetalle]
    ADD CONSTRAINT [FK_ContratoDetalle_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_ContratoDetalle_Partida]...';


GO
ALTER TABLE [PRES].[ContratoDetalle]
    ADD CONSTRAINT [FK_ContratoDetalle_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida]);


GO
PRINT N'Creando Clave externa [PRES].[FK_ContratoDetalle_Empresa]...';


GO
ALTER TABLE [PRES].[ContratoDetalle]
    ADD CONSTRAINT [FK_ContratoDetalle_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [PRES].[FK_DestinoGasto_UsuarioCreacion]...';


GO
ALTER TABLE [PRES].[DestinoGasto]
    ADD CONSTRAINT [FK_DestinoGasto_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [PRES].[FK_DestinoGasto_UsuarioModificacion]...';


GO
ALTER TABLE [PRES].[DestinoGasto]
    ADD CONSTRAINT [FK_DestinoGasto_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Proveedor_EstatusProveedor]...';


GO
ALTER TABLE [SIS].[Proveedor]
    ADD CONSTRAINT [FK_Proveedor_EstatusProveedor] FOREIGN KEY ([FKIdEstatusProveedor_SIS]) REFERENCES [SIS].[EstatusProveedor] ([PKIdEstatusProveedor]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Proveedor_CuentaContable]...';


GO
ALTER TABLE [SIS].[Proveedor]
    ADD CONSTRAINT [FK_Proveedor_CuentaContable] FOREIGN KEY ([FKIdCuentaContable_SIS]) REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Proveedor_TipoProveedor]...';


GO
ALTER TABLE [SIS].[Proveedor]
    ADD CONSTRAINT [FK_Proveedor_TipoProveedor] FOREIGN KEY ([FkIdTipoProveedor_SIS]) REFERENCES [SIS].[TipoProveedor] ([PkIdTipoProveedor]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Proveedor_Municipio]...';


GO
ALTER TABLE [SIS].[Proveedor]
    ADD CONSTRAINT [FK_Proveedor_Municipio] FOREIGN KEY ([FKIdMunicipio_SIS]) REFERENCES [SIS].[Municipios] ([PKIdMunicipio]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Proveedor_Estado]...';


GO
ALTER TABLE [SIS].[Proveedor]
    ADD CONSTRAINT [FK_Proveedor_Estado] FOREIGN KEY ([FKIdEstado_SIS]) REFERENCES [SIS].[Estados] ([PKIdEstado]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Proveedor_Pais]...';


GO
ALTER TABLE [SIS].[Proveedor]
    ADD CONSTRAINT [FK_Proveedor_Pais] FOREIGN KEY ([FKIdPais_SIS]) REFERENCES [SIS].[Paises] ([PKIdPais]);


GO
PRINT N'Creando Clave externa [SIS].[FK_UsuarioDepartamento_UsuarioCreacion]...';


GO
ALTER TABLE [SIS].[UsuarioDepartamento]
    ADD CONSTRAINT [FK_UsuarioDepartamento_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_UsuarioDepartamento_Usuario]...';


GO
ALTER TABLE [SIS].[UsuarioDepartamento]
    ADD CONSTRAINT [FK_UsuarioDepartamento_Usuario] FOREIGN KEY ([FKIdUsuario_SIS]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_UsuarioDepartamento_UsuarioModificacion]...';


GO
ALTER TABLE [SIS].[UsuarioDepartamento]
    ADD CONSTRAINT [FK_UsuarioDepartamento_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_UsuarioDepartamento_Departamento]...';


GO
ALTER TABLE [SIS].[UsuarioDepartamento]
    ADD CONSTRAINT [FK_UsuarioDepartamento_Departamento] FOREIGN KEY ([FKIdDepartamento_SIS]) REFERENCES [SIS].[Departamento] ([PKIdDepartamento]);


GO
PRINT N'Creando Clave externa [SIS].[FK_EmpresaEstado_Empresa]...';


GO
ALTER TABLE [SIS].[EmpresaEstado]
    ADD CONSTRAINT [FK_EmpresaEstado_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [SIS].[FK_EmpresaEstado_Estado]...';


GO
ALTER TABLE [SIS].[EmpresaEstado]
    ADD CONSTRAINT [FK_EmpresaEstado_Estado] FOREIGN KEY ([FKIdEstado_SIS]) REFERENCES [SIS].[Estados] ([PKIdEstado]);


GO
PRINT N'Creando Clave externa [SIS].[CONSTRAINT_FK_Menu_Padre]...';


GO
ALTER TABLE [SIS].[Menu]
    ADD CONSTRAINT [CONSTRAINT_FK_Menu_Padre] FOREIGN KEY ([FKIdMenu_SIS]) REFERENCES [SIS].[Menu] ([PKIdMenu]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Anio_UsuarioCreacion]...';


GO
ALTER TABLE [SIS].[Anio]
    ADD CONSTRAINT [FK_Anio_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Anio_UsuarioModificacion]...';


GO
ALTER TABLE [SIS].[Anio]
    ADD CONSTRAINT [FK_Anio_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Usuario_UsuarioModificacion]...';


GO
ALTER TABLE [SIS].[Usuario]
    ADD CONSTRAINT [FK_Usuario_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Usuario_Empresa]...';


GO
ALTER TABLE [SIS].[Usuario]
    ADD CONSTRAINT [FK_Usuario_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Usuario_Moneda]...';


GO
ALTER TABLE [SIS].[Usuario]
    ADD CONSTRAINT [FK_Usuario_Moneda] FOREIGN KEY ([FKIdMonedaPreferida_SIS]) REFERENCES [SIS].[Moneda] ([PKIdMoneda]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Usuario_UsuarioCreacion]...';


GO
ALTER TABLE [SIS].[Usuario]
    ADD CONSTRAINT [FK_Usuario_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Usuario_Idioma]...';


GO
ALTER TABLE [SIS].[Usuario]
    ADD CONSTRAINT [FK_Usuario_Idioma] FOREIGN KEY ([FKIdIdiomaPreferido_SIS]) REFERENCES [SIS].[Idioma] ([PKIdIdioma]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Usuario_Persona]...';


GO
ALTER TABLE [SIS].[Usuario]
    ADD CONSTRAINT [FK_Usuario_Persona] FOREIGN KEY ([FKIdPersona_NOM]) REFERENCES [NOM].[Persona] ([PKIdPersona]);


GO
PRINT N'Creando Clave externa [SIS].[FK_PerfilUsuario_UsuarioCreacion]...';


GO
ALTER TABLE [SIS].[PerfilUsuario]
    ADD CONSTRAINT [FK_PerfilUsuario_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_PerfilUsuario_UsuarioModificacion]...';


GO
ALTER TABLE [SIS].[PerfilUsuario]
    ADD CONSTRAINT [FK_PerfilUsuario_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_PerfilUsuario_Usuario]...';


GO
ALTER TABLE [SIS].[PerfilUsuario]
    ADD CONSTRAINT [FK_PerfilUsuario_Usuario] FOREIGN KEY ([FKIdUsuario_SIS]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE CASCADE;


GO
PRINT N'Creando Clave externa [SIS].[FK_Municipios_Estados]...';


GO
ALTER TABLE [SIS].[Municipios]
    ADD CONSTRAINT [FK_Municipios_Estados] FOREIGN KEY ([FKIdEstado_SIS]) REFERENCES [SIS].[Estados] ([PKIdEstado]);


GO
PRINT N'Creando Clave externa [SIS].[FK_TipoProveedor_UsuarioCreacion]...';


GO
ALTER TABLE [SIS].[TipoProveedor]
    ADD CONSTRAINT [FK_TipoProveedor_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_TipoProveedor_UsuarioModificacion]...';


GO
ALTER TABLE [SIS].[TipoProveedor]
    ADD CONSTRAINT [FK_TipoProveedor_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_ActividadInstitucional_UsuarioCreacion]...';


GO
ALTER TABLE [SIS].[ActividadInstitucional]
    ADD CONSTRAINT [FK_ActividadInstitucional_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_ActividadInstitucional_UsuarioModificacion]...';


GO
ALTER TABLE [SIS].[ActividadInstitucional]
    ADD CONSTRAINT [FK_ActividadInstitucional_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_EstatusProveedor_UsuarioCreacion]...';


GO
ALTER TABLE [SIS].[EstatusProveedor]
    ADD CONSTRAINT [FK_EstatusProveedor_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_EstatusProveedor_UsuarioModificacion]...';


GO
ALTER TABLE [SIS].[EstatusProveedor]
    ADD CONSTRAINT [FK_EstatusProveedor_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_UsuarioSucursal_Usuario]...';


GO
ALTER TABLE [SIS].[UsuarioSucursal]
    ADD CONSTRAINT [FK_UsuarioSucursal_Usuario] FOREIGN KEY ([FKIdUsuario_SIS]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_UsuarioSucursal_UsuarioModificacion]...';


GO
ALTER TABLE [SIS].[UsuarioSucursal]
    ADD CONSTRAINT [FK_UsuarioSucursal_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_UsuarioSucursal_Sucursal]...';


GO
ALTER TABLE [SIS].[UsuarioSucursal]
    ADD CONSTRAINT [FK_UsuarioSucursal_Sucursal] FOREIGN KEY ([FKIdSucursal_SIS]) REFERENCES [SIS].[Sucursal] ([PKIdSucursal]);


GO
PRINT N'Creando Clave externa [SIS].[FK_UsuarioSucursal_UsuarioCreacion]...';


GO
ALTER TABLE [SIS].[UsuarioSucursal]
    ADD CONSTRAINT [FK_UsuarioSucursal_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_SystemParamValue_UsuarioModificacion]...';


GO
ALTER TABLE [SIS].[SystemParamValue]
    ADD CONSTRAINT [FK_SystemParamValue_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_SystemParamValue_UsuarioCreacion]...';


GO
ALTER TABLE [SIS].[SystemParamValue]
    ADD CONSTRAINT [FK_SystemParamValue_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[CONSTRAINT_FK_SystemParamCatalog_SystemParamValue]...';


GO
ALTER TABLE [SIS].[SystemParamValue]
    ADD CONSTRAINT [CONSTRAINT_FK_SystemParamCatalog_SystemParamValue] FOREIGN KEY ([FKIdSystemParamCatalog_SIS]) REFERENCES [SIS].[SystemParamCatalog] ([PKIdSystemParamCatalog]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Capitulo_UsuarioCreacion]...';


GO
ALTER TABLE [SIS].[Capitulo]
    ADD CONSTRAINT [FK_Capitulo_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Capitulo_UsuarioModificacion]...';


GO
ALTER TABLE [SIS].[Capitulo]
    ADD CONSTRAINT [FK_Capitulo_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_TipoPoliza_UsuarioModificacion]...';


GO
ALTER TABLE [SIS].[TipoPoliza]
    ADD CONSTRAINT [FK_TipoPoliza_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_TipoPoliza_UsuarioCreacion]...';


GO
ALTER TABLE [SIS].[TipoPoliza]
    ADD CONSTRAINT [FK_TipoPoliza_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_OrigenLogMessage_UsuarioCreacion]...';


GO
ALTER TABLE [SIS].[OrigenLogMessage]
    ADD CONSTRAINT [FK_OrigenLogMessage_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_OrigenLogMessage_UsuarioModificacion]...';


GO
ALTER TABLE [SIS].[OrigenLogMessage]
    ADD CONSTRAINT [FK_OrigenLogMessage_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Estados_Paises]...';


GO
ALTER TABLE [SIS].[Estados]
    ADD CONSTRAINT [FK_Estados_Paises] FOREIGN KEY ([FKIdPais_SIS]) REFERENCES [SIS].[Paises] ([PKIdPais]);


GO
PRINT N'Creando Clave externa [SIS].[CONSTRAINT_FK_SystemLog_OrigenLogMessage]...';


GO
ALTER TABLE [SIS].[SystemLog]
    ADD CONSTRAINT [CONSTRAINT_FK_SystemLog_OrigenLogMessage] FOREIGN KEY ([FKIdOrigenLogMessage_SIS]) REFERENCES [SIS].[OrigenLogMessage] ([PKIdOrigenLogMessage]);


GO
PRINT N'Creando Clave externa [SIS].[FK_TipoDetallePoliza_UsuarioModificacion]...';


GO
ALTER TABLE [SIS].[TipoDetallePoliza]
    ADD CONSTRAINT [FK_TipoDetallePoliza_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_TipoDetallePoliza_UsuarioCreacion]...';


GO
ALTER TABLE [SIS].[TipoDetallePoliza]
    ADD CONSTRAINT [FK_TipoDetallePoliza_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_SystemParamCatalog_UsuarioModificacion]...';


GO
ALTER TABLE [SIS].[SystemParamCatalog]
    ADD CONSTRAINT [FK_SystemParamCatalog_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_SystemParamCatalog_UsuarioCreacion]...';


GO
ALTER TABLE [SIS].[SystemParamCatalog]
    ADD CONSTRAINT [FK_SystemParamCatalog_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Paises_Idioma]...';


GO
ALTER TABLE [SIS].[Paises]
    ADD CONSTRAINT [FK_Paises_Idioma] FOREIGN KEY ([FKIdIdiomaPrincipal_SIS]) REFERENCES [SIS].[Idioma] ([PKIdIdioma]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Paises_Moneda]...';


GO
ALTER TABLE [SIS].[Paises]
    ADD CONSTRAINT [FK_Paises_Moneda] FOREIGN KEY ([FKIdMonedaPrincipal_SIS]) REFERENCES [SIS].[Moneda] ([PKIdMoneda]);


GO
PRINT N'Creando Clave externa [SIS].[CONSTRAINT_FK_MenuRole_Menu]...';


GO
ALTER TABLE [SIS].[MenuRole]
    ADD CONSTRAINT [CONSTRAINT_FK_MenuRole_Menu] FOREIGN KEY ([FKIdMenu_SIS]) REFERENCES [SIS].[Menu] ([PKIdMenu]);


GO
PRINT N'Creando Clave externa [SIS].[CONSTRAINT_FK_MenuRole_Role]...';


GO
ALTER TABLE [SIS].[MenuRole]
    ADD CONSTRAINT [CONSTRAINT_FK_MenuRole_Role] FOREIGN KEY ([RoleId]) REFERENCES [dbo].[AspNetRoles] ([Id]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Banco_UsuarioCreacion]...';


GO
ALTER TABLE [SIS].[Banco]
    ADD CONSTRAINT [FK_Banco_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Banco_UsuarioModificacion]...';


GO
ALTER TABLE [SIS].[Banco]
    ADD CONSTRAINT [FK_Banco_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Banco_Empresa]...';


GO
ALTER TABLE [SIS].[Banco]
    ADD CONSTRAINT [FK_Banco_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Empresa_UsuarioModificacion]...';


GO
ALTER TABLE [SIS].[Empresa]
    ADD CONSTRAINT [FK_Empresa_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Empresa_UsuarioCreacion]...';


GO
ALTER TABLE [SIS].[Empresa]
    ADD CONSTRAINT [FK_Empresa_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Departamento_UsuarioCreacion]...';


GO
ALTER TABLE [SIS].[Departamento]
    ADD CONSTRAINT [FK_Departamento_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Departamento_UsuarioModificacion]...';


GO
ALTER TABLE [SIS].[Departamento]
    ADD CONSTRAINT [FK_Departamento_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Departamento_Empresa]...';


GO
ALTER TABLE [SIS].[Departamento]
    ADD CONSTRAINT [FK_Departamento_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Departamento_Sucursal]...';


GO
ALTER TABLE [SIS].[Departamento]
    ADD CONSTRAINT [FK_Departamento_Sucursal] FOREIGN KEY ([FKIdSucursal_SIS]) REFERENCES [SIS].[Sucursal] ([PKIdSucursal]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Concepto_UsuarioCreacion]...';


GO
ALTER TABLE [SIS].[Concepto]
    ADD CONSTRAINT [FK_Concepto_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Concepto_UsuarioModificacion]...';


GO
ALTER TABLE [SIS].[Concepto]
    ADD CONSTRAINT [FK_Concepto_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Concepto_Capitulo]...';


GO
ALTER TABLE [SIS].[Concepto]
    ADD CONSTRAINT [FK_Concepto_Capitulo] FOREIGN KEY ([FKIdCapitulo_SIS]) REFERENCES [SIS].[Capitulo] ([PKIdCapitulo]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Partida_UsuarioCreacion]...';


GO
ALTER TABLE [SIS].[Partida]
    ADD CONSTRAINT [FK_Partida_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Partida_UsuarioModificacion]...';


GO
ALTER TABLE [SIS].[Partida]
    ADD CONSTRAINT [FK_Partida_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Partida_Concepto]...';


GO
ALTER TABLE [SIS].[Partida]
    ADD CONSTRAINT [FK_Partida_Concepto] FOREIGN KEY ([FKIdConcepto_SIS]) REFERENCES [SIS].[Concepto] ([PKIdConcepto]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Area_Padre]...';


GO
ALTER TABLE [SIS].[Area]
    ADD CONSTRAINT [FK_Area_Padre] FOREIGN KEY ([FKIdArea_SIS]) REFERENCES [SIS].[Area] ([PKIdArea]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Area_UsuarioCreacion]...';


GO
ALTER TABLE [SIS].[Area]
    ADD CONSTRAINT [FK_Area_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Area_UsuarioModificacion]...';


GO
ALTER TABLE [SIS].[Area]
    ADD CONSTRAINT [FK_Area_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_TipoDoctoCLC_UsuarioModificacion]...';


GO
ALTER TABLE [SIS].[TipoDoctoCLC]
    ADD CONSTRAINT [FK_TipoDoctoCLC_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_TipoDoctoCLC_UsuarioCreacion]...';


GO
ALTER TABLE [SIS].[TipoDoctoCLC]
    ADD CONSTRAINT [FK_TipoDoctoCLC_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Sucursal_UsuarioModificacion]...';


GO
ALTER TABLE [SIS].[Sucursal]
    ADD CONSTRAINT [FK_Sucursal_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Sucursal_Tipo]...';


GO
ALTER TABLE [SIS].[Sucursal]
    ADD CONSTRAINT [FK_Sucursal_Tipo] FOREIGN KEY ([FKIdTipoSucursal]) REFERENCES [SIS].[CatTipoSucursal] ([PKIdTipoSucursal]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Sucursal_Estado]...';


GO
ALTER TABLE [SIS].[Sucursal]
    ADD CONSTRAINT [FK_Sucursal_Estado] FOREIGN KEY ([FKIdEstado_SIS]) REFERENCES [SIS].[Estados] ([PKIdEstado]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Sucursal_UsuarioCreacion]...';


GO
ALTER TABLE [SIS].[Sucursal]
    ADD CONSTRAINT [FK_Sucursal_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Sucursal_Moneda]...';


GO
ALTER TABLE [SIS].[Sucursal]
    ADD CONSTRAINT [FK_Sucursal_Moneda] FOREIGN KEY ([FKIdMonedaLocal_SIS]) REFERENCES [SIS].[Moneda] ([PKIdMoneda]);


GO
PRINT N'Creando Clave externa [SIS].[FK_Sucursal_Empresa]...';


GO
ALTER TABLE [SIS].[Sucursal]
    ADD CONSTRAINT [FK_Sucursal_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [TES].[FK_TipoPagoSF_UsuarioCreacion]...';


GO
ALTER TABLE [TES].[TipoPagoSF]
    ADD CONSTRAINT [FK_TipoPagoSF_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [TES].[FK_TipoPagoSF_UsuarioModificacion]...';


GO
ALTER TABLE [TES].[TipoPagoSF]
    ADD CONSTRAINT [FK_TipoPagoSF_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [TES].[FK_TipoInversion_UsuarioModificacion]...';


GO
ALTER TABLE [TES].[TipoInversion]
    ADD CONSTRAINT [FK_TipoInversion_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [TES].[FK_TipoInversion_UsuarioCreacion]...';


GO
ALTER TABLE [TES].[TipoInversion]
    ADD CONSTRAINT [FK_TipoInversion_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [TES].[FK_TipoSolicitudCLC_UsuarioModificacion]...';


GO
ALTER TABLE [TES].[TipoSolicitudCLC]
    ADD CONSTRAINT [FK_TipoSolicitudCLC_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [TES].[FK_TipoSolicitudCLC_UsuarioCreacion]...';


GO
ALTER TABLE [TES].[TipoSolicitudCLC]
    ADD CONSTRAINT [FK_TipoSolicitudCLC_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [TES].[FK_TipoPago_UsuarioModificacion]...';


GO
ALTER TABLE [TES].[TipoPago]
    ADD CONSTRAINT [FK_TipoPago_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [TES].[FK_TipoPago_UsuarioCreacion]...';


GO
ALTER TABLE [TES].[TipoPago]
    ADD CONSTRAINT [FK_TipoPago_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [TES].[FK_TipoMoneda_Pais]...';


GO
ALTER TABLE [TES].[TipoMoneda]
    ADD CONSTRAINT [FK_TipoMoneda_Pais] FOREIGN KEY ([FKIdPais_SIS]) REFERENCES [SIS].[Paises] ([PKIdPais]);


GO
PRINT N'Creando Clave externa [TES].[FK_TipoMoneda_UsuarioModificacion]...';


GO
ALTER TABLE [TES].[TipoMoneda]
    ADD CONSTRAINT [FK_TipoMoneda_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [TES].[FK_TipoMoneda_UsuarioCreacion]...';


GO
ALTER TABLE [TES].[TipoMoneda]
    ADD CONSTRAINT [FK_TipoMoneda_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [TES].[FK_TipoCambio_UsuarioCreacion]...';


GO
ALTER TABLE [TES].[TipoCambio]
    ADD CONSTRAINT [FK_TipoCambio_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [TES].[FK_TipoCambio_TipoMoneda]...';


GO
ALTER TABLE [TES].[TipoCambio]
    ADD CONSTRAINT [FK_TipoCambio_TipoMoneda] FOREIGN KEY ([FKIdTipoMoneda_TES]) REFERENCES [TES].[TipoMoneda] ([PKIdTipoMoneda]);


GO
PRINT N'Creando Clave externa [TES].[FK_TipoCambio_UsuarioModificacion]...';


GO
ALTER TABLE [TES].[TipoCambio]
    ADD CONSTRAINT [FK_TipoCambio_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [TES].[FK_CuentaBancaria_TipoMoneda]...';


GO
ALTER TABLE [TES].[CuentaBancaria]
    ADD CONSTRAINT [FK_CuentaBancaria_TipoMoneda] FOREIGN KEY ([FKIdTipoMoneda_TES]) REFERENCES [TES].[TipoMoneda] ([PKIdTipoMoneda]);


GO
PRINT N'Creando Clave externa [TES].[FK_CuentaBancaria_Empresa]...';


GO
ALTER TABLE [TES].[CuentaBancaria]
    ADD CONSTRAINT [FK_CuentaBancaria_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]);


GO
PRINT N'Creando Clave externa [TES].[FK_CuentaBancaria_Banco]...';


GO
ALTER TABLE [TES].[CuentaBancaria]
    ADD CONSTRAINT [FK_CuentaBancaria_Banco] FOREIGN KEY ([FKIdBanco_SIS]) REFERENCES [SIS].[Banco] ([PKIdBanco]);


GO
PRINT N'Creando Clave externa [TES].[FK_CuentaBancaria_UsuarioModificacion]...';


GO
ALTER TABLE [TES].[CuentaBancaria]
    ADD CONSTRAINT [FK_CuentaBancaria_UsuarioModificacion] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [TES].[FK_CuentaBancaria_UsuarioCreacion]...';


GO
ALTER TABLE [TES].[CuentaBancaria]
    ADD CONSTRAINT [FK_CuentaBancaria_UsuarioCreacion] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Clave externa [dbo].[CONSTRAINT_FK_AspNetClaims_Role]...';


GO
ALTER TABLE [dbo].[AspNetClaims]
    ADD CONSTRAINT [CONSTRAINT_FK_AspNetClaims_Role] FOREIGN KEY ([RoleId]) REFERENCES [dbo].[AspNetRoles] ([Id]);


GO
PRINT N'Creando Clave externa [dbo].[CONSTRAINT_FK_AspNetClaims_ClaimType]...';


GO
ALTER TABLE [dbo].[AspNetClaims]
    ADD CONSTRAINT [CONSTRAINT_FK_AspNetClaims_ClaimType] FOREIGN KEY ([ClaimTypeId]) REFERENCES [dbo].[AspNetClaimTypes] ([Id]);


GO
PRINT N'Creando Clave externa [dbo].[CONSTRAINT_FK_AspNetClaimValues_Claim]...';


GO
ALTER TABLE [dbo].[AspNetClaimValues]
    ADD CONSTRAINT [CONSTRAINT_FK_AspNetClaimValues_Claim] FOREIGN KEY ([ClaimId]) REFERENCES [dbo].[AspNetClaims] ([Id]);


GO
PRINT N'Creando Clave externa [dbo].[CONSTRAINT_FK_AspNetUserRoles_User]...';


GO
ALTER TABLE [dbo].[AspNetUserRoles]
    ADD CONSTRAINT [CONSTRAINT_FK_AspNetUserRoles_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[AspNetUsers] ([Id]);


GO
PRINT N'Creando Clave externa [dbo].[CONSTRAINT_FK_AspNetUserRoles_Role]...';


GO
ALTER TABLE [dbo].[AspNetUserRoles]
    ADD CONSTRAINT [CONSTRAINT_FK_AspNetUserRoles_Role] FOREIGN KEY ([RoleId]) REFERENCES [dbo].[AspNetRoles] ([Id]);


GO
PRINT N'Creando Clave externa [dbo].[CONSTRAINT_FK_AspNetUsers_Usuario]...';


GO
ALTER TABLE [dbo].[AspNetUsers]
    ADD CONSTRAINT [CONSTRAINT_FK_AspNetUsers_Usuario] FOREIGN KEY ([PkIdUsuario]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]);


GO
PRINT N'Creando Restricción CHECK [ORCO].[CK_EstudioMercadoDetalle_CostoUnitario]...';


GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle]
    ADD CONSTRAINT [CK_EstudioMercadoDetalle_CostoUnitario] CHECK ([CostoUnitario] IS NULL OR [CostoUnitario]>=(0));


GO
PRINT N'Creando Vista [ALMA].[vw_Bien]...';


GO

CREATE   VIEW  [ALMA].[vw_Bien]
AS
SELECT 
    b.PKIdBien,
    b.Clave,
    b.ClaveAnt,
    b.Descripcion,
    b.Modelo,
    b.Serie,
    b.Costo,
    b.FechaAdq,
    b.Factura,
    b.Requisicion,
    b.Referencia,
    b.Notas,
    b.Ubicacion,
    b.AAdquisicion,
    b.Frente,
    b.Fondo,
    b.Altura,
    b.Diametro,
    b.VerificacionesDias,
    b.MantenimientoDias,
    b.Mantenimiento,
    b.Calibracion,
    b.Rango,
    b.Resolucion,
    b.FechaUltInv,
    b.FechaReqscn,
    b.Estatus,
    b.Caracteristicas,
    b.Resguardo,
    b.ResguardoAnterior,
    b.RelId,
    b.ValorRescate,
    b.ValorActual,
    b.Antiguedad,
    b.Progresivo,
    b.Consecutivo,
    b.ClaveHist,
    b.EstaResguardado,
    b.FechaResguardado,
    b.Localizado,
    b.esContabilizado,
    b.Activo,
    b.FechaCreacion,
    b.UsuarioCreacion,
    b.FechaModificacion,
    b.UsuarioModificacion,

    -- Informaci�n de GrupoBien
    gb.Descripcion AS GrupoBienDescripcion,
    gb.Clave AS GrupoBienClave,

    -- Informaci�n de TipoBien
    tb.CodigoClave AS TipoBienCodigoClave,
    tb.Descripcion AS TipoBienDescripcion,
    tb.CABMS AS TipoBienCABMS,
    tb.Identificador AS TipoBienIdentificador,
    tb.CUCOP_PLUS AS TipoBienCUCOP_PLUS,

    -- Informaci�n de �rea (SIS.Area)
    a.Nombre AS AreaNombre,
    a.Clave AS AreaClave,

    -- Informaci�n de Proveedor
    p.Nombre AS ProveedorNombre,
    p.RFC AS ProveedorRFC,
    p.Clave AS ProveedorClave,

    -- Informaci�n de EstadoBien
    eb.DESCRIPCION_GENERAL AS EstadoBienDescripcionGeneral,
    eb.DESCRIPCION_ESPECIFICA AS EstadoBienDescripcionEspecifica,
    eb.DESCRIPCION_CORTA AS EstadoBienDescripcionCorta,

    -- Informaci�n de TipoPatrimonio
    tp.Descripcion AS TipoPatrimonioDescripcion,

    -- Informaci�n de Marca
    m.Descripcion AS MarcaDescripcion,

    -- Informaci�n de Material
    mat.Descripcion AS MaterialDescripcion,

    -- Informaci�n de TipoAdquisicion
    ta.Clave AS TipoAdquisicionClave,
    ta.Descripcion AS TipoAdquisicionDescripcion,
    ta.Descripmovto AS TipoAdquisicionDescripcionMovto,

    -- Informaci�n de Partida (CONTA.Partida)
    part.Clave AS PartidaClave,
    part.Descripcion AS PartidaDescripcion

FROM ALMA.Bien b
LEFT JOIN ALMA.GrupoBien gb ON b.FKIdGrupoBien_ALMA = gb.PKIdGrupoBien
LEFT JOIN ALMA.TipoBien tb ON b.FKIdTipoBien_ALMA = tb.PKIdTipoBien
LEFT JOIN SIS.Area a ON b.FKIdArea_SIS = a.PKIdArea
LEFT JOIN SIS.Proveedor p ON b.FKIdProveedor_SIS = p.PKIdProveedor
LEFT JOIN ALMA.EstadoBien eb ON b.FKIdEstadoBien_ALMA = eb.PKIdEstadoBien
LEFT JOIN ALMA.TipoPatrimonio tp ON b.FKIdTipoPatrimonio_ALMA = tp.PKIdTipoPatrimonio
LEFT JOIN ALMA.Marca m ON b.FKIdMarca_ALMA = m.PKIdMarca
LEFT JOIN ALMA.Material mat ON b.FKIdMaterial_ALMA = mat.PKIdMaterial
LEFT JOIN ALMA.TipoAdquisicion ta ON b.FKIdTipoAdq_ALMA = ta.PKIdTipoAdq
LEFT JOIN CONTA.Partida part ON b.FKIdPartida_CONTA = part.PKIdPartida
GO
PRINT N'Creando Vista [ALMA].[VW_Existencias]...';


GO

CREATE   VIEW  [ALMA].[VW_Existencias]
AS

WITH Existencias AS
(
    SELECT
        TB.PKIdTipoBien,
        TB.FKIdPartida_CONTA,
        GB.CLAVE_CUCOP AS CUCOP,
        GB.CABM_ACT + ' / ' + GB.ClaveAN AS CABMS,
        TB.CodigoClave,
        TB.Descripcion,
        COUNT(B.PKIdBien) AS Existencias,
        AU.Descripcion AS Unidades,
        0 AS FK_IdAnio__SIS,
        CAST('' AS NVARCHAR(MAX)) AS Message,
        IIF(TB.Cantidad_Equivalente > 1, TB.FKIdUnidades_Equivalente, TB.FKIdUnidades_ALMA) AS FK_IdUnidades__ALMA,
        AVG(B.Costo) AS CostoUnitario,
        AVG(B.Costo) AS CostoPromedio
    FROM
        ALMA.TipoBien TB
        INNER JOIN ALMA.GrupoBien GB ON TB.FKIdGrupoBien_ALMA = GB.PKIdGrupoBien
        INNER JOIN ALMA.Unidades AU ON IIF(TB.Cantidad_Equivalente > 1, TB.FKIdUnidades_Equivalente, TB.FKIdUnidades_ALMA) = AU.PKIdUnidades
        LEFT JOIN ALMA.Bien B ON TB.PKIdTipoBien = B.FKIdTipoBien_ALMA AND B.Activo = 1
    WHERE
        TB.Activo = 1
        AND GB.Activo = 1
        AND AU.Activo = 1
    GROUP BY
        TB.PKIdTipoBien,
        TB.FKIdPartida_CONTA,
        GB.CLAVE_CUCOP,
        GB.CABM_ACT,
        GB.ClaveAN,
        TB.CodigoClave,
        TB.Descripcion,
        AU.Descripcion,
        IIF(TB.Cantidad_Equivalente > 1, TB.FKIdUnidades_Equivalente, TB.FKIdUnidades_ALMA)
)
SELECT
    E.PKIdTipoBien,
    E.FKIdPartida_CONTA,
    E.CUCOP,
    E.CABMS,
    E.CodigoClave,
    E.Descripcion,
    E.Existencias,
    E.Unidades,
    E.FK_IdAnio__SIS,
    CASE
        WHEN E.Existencias < TB.ExistenciaMinima THEN 'No alcanza el m�nimo de unidades'
        WHEN E.Existencias > TB.ExistenciaMaxima THEN 'Excede el M�ximo de Unidades'
        ELSE 'OK'
    END AS Message,
    E.FK_IdUnidades__ALMA,
    ISNULL(E.CostoUnitario, 0) AS CostoUnitario,
    ISNULL(E.CostoPromedio, 0) AS CostoPromedio
FROM
    Existencias E
    INNER JOIN ALMA.TipoBien TB ON E.PKIdTipoBien = TB.PKIdTipoBien
WHERE
    TB.Activo = 1
GO
PRINT N'Creando Vista [ALMA].[VW_ConteoDetalle]...';


GO

CREATE   VIEW  [ALMA].[VW_ConteoDetalle]
AS
SELECT
    -- Campos del encabezado (Conteo)
    C.[PKIdConteo],
    C.[FKIdTipoBien_ALMA],
    TB.[Descripcion]          AS [TipoBienDescripcion],
    C.[CantidadInventario]    AS [CantidadInventarioInicial],
    C.[Descripcion]           AS [ConteoDescripcion],
    C.[FechaInicio],
    C.[FechaFin],
    C.[Activo]                AS [ConteoActivo],
    C.[FechaCreacion]         AS [ConteoFechaCreacion],
    C.[UsuarioCreacion]       AS [ConteoUsuarioCreacion],
    C.[FechaModificacion]     AS [ConteoFechaModificacion],
    C.[UsuarioModificacion]   AS [ConteoUsuarioModificacion],

    -- Campos del detalle (ConteoDetalle)
    CD.[PKIdDetalleConteo],
    CD.[FKIdConteo_ALMA],
    CD.[FKIdNumeroConteo_ALMA],
    CD.[FKIdPersona_NOM],
    P.[Nombre]                AS [PersonaNombre],
    P.[Paterno]               AS [PersonaPaterno],
    P.[Materno]               AS [PersonaMaterno],
    CD.[Cantidad]             AS [CantidadContada],
    CD.[Fecha]                AS [FechaConteo],
    CD.[Activo]               AS [DetalleActivo],
    CD.[FechaCreacion]        AS [DetalleFechaCreacion],
    CD.[UsuarioCreacion]      AS [DetalleUsuarioCreacion],
    CD.[FechaModificacion]    AS [DetalleFechaModificacion],
    CD.[UsuarioModificacion]  AS [DetalleUsuarioModificacion]

FROM [ALMA].[Conteo] C
INNER JOIN [ALMA].[ConteoDetalle] CD
    ON C.[PKIdConteo] = CD.[FKIdConteo_ALMA]
LEFT JOIN [ALMA].[TipoBien] TB
    ON C.[FKIdTipoBien_ALMA] = TB.[PKIdTipoBien]
LEFT JOIN [NOM].[Persona] P
    ON CD.[FKIdPersona_NOM] = P.[PKIdPersona];
GO
PRINT N'Creando Vista [ALMA].[Vw_TipoBien]...';


GO

CREATE   VIEW  [ALMA].[Vw_TipoBien]
AS
SELECT 
    tb.PKIdTipoBien,
    tb.FKIdGrupoBien_ALMA,
    tb.FKIdNivel_ALMA,
    tb.FKIdPartida_CONTA,
    tb.FKIdCuentaContable_CONTA,
    tb.FKIdUnidades_ALMA,
    tb.FKIdLocalizacion_ALMA,
    tb.FKIdUnidades_Equivalente,
    tb.CodigoClave,
    CONCAT(tb.Descripcion, ' ', tb.CodigoClave) AS TipoBienDescripcion,
    tb.DepreciacionAnual,
    tb.Consecutivo,
    tb.CABMS,
    tb.Identificador,
    tb.ExistenciaMinima,
    tb.ExistenciaMaxima,
    tb.TiempoVida,
    tb.Pk_IdTratadoInt,
    tb.Cuota,
    tb.ProveeduriaNac,
    tb.CatalogoBasico,
    tb.CUCOP_PLUS,
    tb.Cantidad_Equivalente,
    tb.Activo,
    tb.FechaCreacion,
    tb.UsuarioCreacion,
    tb.FechaModificacion,
    tb.UsuarioModificacion,
    -- GrupoBien y Familia (activos)
    gb.Descripcion AS GrupoBienDescripcion,
    gb.Clave AS GrupoBienClave,
    gb.ClaveAN,
    gb.CABM_ACT,
    gb.CLAVE_CUCOP,
    gb.MEDIDA AS GrupoBienMedida,
    f.Descripcion AS FamiliaDescripcion,
    f.Clave AS FamiliaClave,
    -- Nivel (activo)
    n.Nivel,
    n.Descripcion AS NivelDescripcion,
    -- Partida (activo)
    p.Clave AS PartidaClave,
    p.Descripcion AS PartidaDescripcion,
    -- CuentaContable (activo)
    cc.Cta_Coi,
    cc.Desc_Coi AS CuentaDescripcion,
    cc.TipoCuenta,
    -- Unidades (activo)
    u.Descripcion AS UnidadMedida,
    -- Unidades Equivalente (activo)
    ue.Descripcion AS UnidadEquivalenteMedida
FROM ALMA.TipoBien tb
LEFT JOIN ALMA.GrupoBien gb ON tb.FKIdGrupoBien_ALMA = gb.PKIdGrupoBien AND gb.Activo = 1
LEFT JOIN ALMA.Familia f ON gb.FKIdFamilia_ALMA = f.PKIdFamilia AND f.Activo = 1
LEFT JOIN ALMA.Nivel n ON tb.FKIdNivel_ALMA = n.PKIdNivel AND n.Activo = 1
LEFT JOIN CONTA.Partida p ON tb.FKIdPartida_CONTA = p.PKIdPartida AND p.Activo = 1
LEFT JOIN CONTA.CuentaContable cc ON tb.FKIdCuentaContable_CONTA = cc.PKIdCuentaContable AND cc.Activo = 1
LEFT JOIN ALMA.Unidades u ON tb.FKIdUnidades_ALMA = u.PKIdUnidades AND u.Activo = 1
LEFT JOIN ALMA.Unidades ue ON tb.FKIdUnidades_Equivalente = ue.PKIdUnidades AND ue.Activo = 1
WHERE tb.Activo = 1;
GO
PRINT N'Creando Vista [ALMA].[Vw_GrupoBien]...';


GO

CREATE   VIEW  [ALMA].[Vw_GrupoBien] AS
SELECT 
    gb.PKIdGrupoBien,
    gb.FKIdFamilia_ALMA,
    gb.Descripcion,
    gb.Clave,
    gb.ClaveAN,
    gb.CABM_ACT,
    gb.CLAVE_CUCOP,
    gb.MEDIDA,
    gb.Activo,
    gb.FechaCreacion,
    gb.UsuarioCreacion,
    gb.FechaModificacion,
    gb.UsuarioModificacion,
    -- FK resuelta: Familia
    f.Descripcion AS FamiliaDescripcion,
    f.Clave AS FamiliaClave,
    CONCAT_WS(' / ', gb.ClaveAN, gb.CABM_ACT, gb.Descripcion) AS CatalogoCAMBS
FROM ALMA.GrupoBien gb
LEFT JOIN ALMA.Familia f ON gb.FKIdFamilia_ALMA = f.PKIdFamilia AND f.Activo = 1
WHERE gb.Activo = 1;
GO
PRINT N'Creando Vista [ALMA].[Vw_TipoBienConteo]...';


GO

CREATE   VIEW  [ALMA].[Vw_TipoBienConteo]
AS
SELECT 
    -- ========================
    -- Campos originales de la vista (se mantienen)
    -- ========================
    tb.PKIdTipoBien,
    tb.CodigoClave AS CodigoArticulo,
    tb.Descripcion AS DescripcionArticulo,
    tb.Activo,
    
    -- Unidades
    u.Descripcion AS UnidadMedida,
    ue.Descripcion AS UnidadEquivalente,
    tb.Cantidad_Equivalente,
    
    -- Clasificaci�n
    f.Descripcion AS Familia,
    gb.Descripcion AS GrupoBien,
    n.Descripcion AS Nivel,
    
    -- Partida y cuenta contable
    p.Clave AS PartidaClave,
    p.Descripcion AS PartidaDescripcion,
    cc.Cuenta + '.' + cc.SubCuenta + '.' + cc.SubSubCuenta + '.' + cc.SubSubSubCuenta + '.' + cc.SubSubSubSubCuenta AS CuentaCompleta,
    cc.Descripcion AS CuentaDescripcion,
    tc.Descripcion AS TipoCuenta,
    
    -- Par�metros del art�culo
    tb.ExistenciaMinima,
    tb.ExistenciaMaxima,
    tb.CABMS,
    tb.CUCOP_PLUS,
    tb.DepreciacionAnual,
    tb.TiempoVida,
    tb.ProveeduriaNac,
    tb.CatalogoBasico,
    
    -- Auditor�a
    tb.FechaCreacion,
    tb.UsuarioCreacion,
    tb.FechaModificacion,
    tb.UsuarioModificacion,

    -- ========================
    -- NUEVOS CAMPOS requeridos por el CRUD (solo los que no exist�an)
    -- ========================
    -- IDs de las relaciones (necesarios para combos y FK)
    tb.FKIdGrupoBien_ALMA AS FkIdGrupoBienSicop,
    tb.FKIdNivel_ALMA AS FkIdNivel,
    tb.FKIdPartida_CONTA AS FkIdPartidaSis,
    tb.FKIdCuentaContable_CONTA AS FkIdCuentaContable,
    tb.FKIdUnidades_ALMA AS FkIdUnidadesAlma,
    tb.FKIdUnidades_Equivalente AS FkIdUnidadesEquivalente,
    
    -- Otros campos �tiles que no estaban en la vista original
    tb.Consecutivo,
    tb.Identificador

FROM 
    ALMA.TipoBien tb
    INNER JOIN ALMA.GrupoBien gb ON tb.FKIdGrupoBien_ALMA = gb.PKIdGrupoBien
    INNER JOIN ALMA.Familia f ON gb.FKIdFamilia_ALMA = f.PKIdFamilia
    INNER JOIN ALMA.Nivel n ON tb.FKIdNivel_ALMA = n.PKIdNivel
    INNER JOIN CONTA.Partida p ON tb.FKIdPartida_CONTA = p.PKIdPartida
    LEFT JOIN CONTA.CuentaContable cc ON tb.FKIdCuentaContable_CONTA = cc.PKIdCuentaContable
    LEFT JOIN CONTA.TipoCuenta tc ON cc.FKIdTipoCuenta_CONTA = tc.PKIdTipoCuenta
    INNER JOIN ALMA.Unidades u ON tb.FKIdUnidades_ALMA = u.PKIdUnidades
    LEFT JOIN ALMA.Unidades ue ON tb.FKIdUnidades_Equivalente = ue.PKIdUnidades
WHERE 
    tb.Activo = 1;
GO
PRINT N'Creando Vista [ALMA].[VW_Conteo]...';


GO

CREATE   VIEW  [ALMA].[VW_Conteo]
AS
SELECT
    c.[PKIdConteo],
    c.[CantidadInventario],
    c.[Descripcion],
    c.[FechaInicio],
    c.[FechaFin],
    c.[Activo],
    c.[FechaCreacion],
    c.[UsuarioCreacion],
    c.[FechaModificacion],
    c.[UsuarioModificacion],

    -- Datos del periodo de conteo
    pc.[PKIdPeriodoConteo]          AS [IdPeriodoConteo],
    pc.[CodigoPeriodo]              AS [CodigoPeriodo],
    pc.[Nombre]                     AS [NombrePeriodo],
    pc.[FechaInicio]                AS [PeriodoFechaInicio],
    pc.[FechaFin]                   AS [PeriodoFechaFin],

    -- Tipo de conteo (a trav�s de PeriodoConteo)
    tc.[PKIdTipoConteo]             AS [IdTipoConteo],
    tc.[Nombre]                     AS [TipoConteo],
    tc.[Descripcion]                AS [DescripcionTipoConteo],

    -- Estatus del periodo
    ep.[PKIdEstatusPeriodo]         AS [IdEstatusPeriodo],
    ep.[Nombre]                     AS [EstatusPeriodo],
    ep.[Descripcion]                AS [DescripcionEstatusPeriodo],

    -- Tipo de bien
    tb.[PKIdTipoBien]               AS [IdTipoBien],
    tb.[CodigoClave]                AS [CodigoClaveTipoBien],
    tb.[Descripcion]                AS [DescripcionTipoBien],

    -- Grupo y familia
    gb.[PKIdGrupoBien]              AS [IdGrupoBien],
    gb.[Descripcion]                AS [GrupoBien],
    f.[PKIdFamilia]                 AS [IdFamilia],
    f.[Descripcion]                 AS [Familia],

    -- Unidad de medida
    u.[PKIdUnidades]                AS [IdUnidad],
    u.[Descripcion]                 AS [UnidadMedida],

    -- Usuarios (con datos de persona)
    uc.[PkIdUsuario]                AS [IdUsuarioCreacion],
    ISNULL(puc.[Nombre], '') + ' ' + ISNULL(puc.[Paterno], '') + ' ' + ISNULL(puc.[Materno], '') AS [NombreUsuarioCreacion],
    um.[PkIdUsuario]                AS [IdUsuarioModificacion],
    ISNULL(pum.[Nombre], '') + ' ' + ISNULL(pum.[Paterno], '') + ' ' + ISNULL(pum.[Materno], '') AS [NombreUsuarioModificacion],

    -- M�tricas desde ConteoDetalle
    ISNULL(COUNT(DISTINCT cd.[PKIdDetalleConteo]), 0)      AS [TotalLecturas],
    ISNULL(SUM(cd.[Cantidad]), 0)                          AS [TotalCantidadContada],
    ISNULL(COUNT(DISTINCT cd.[FKIdPersona_NOM]), 0)        AS [PersonasParticipantes],

    -- Estado del conteo individual
    CASE
        WHEN c.[FechaFin] IS NOT NULL AND c.[FechaFin] <= GETDATE() THEN 'Finalizado'
        WHEN c.[FechaInicio] <= GETDATE() AND (c.[FechaFin] IS NULL OR c.[FechaFin] > GETDATE()) THEN 'En Proceso'
        WHEN c.[FechaInicio] > GETDATE() THEN 'Programado'
        ELSE 'Indeterminado'
    END AS [EstadoConteo]

FROM [ALMA].[Conteo] c

INNER JOIN [ALMA].[PeriodoConteo] pc
    ON c.[FKIdPeriodoConteo_ALMA] = pc.[PKIdPeriodoConteo]

LEFT JOIN [ALMA].[TipoConteo] tc
    ON pc.[FKIdTipoConteo_ALMA] = tc.[PKIdTipoConteo]

LEFT JOIN [ALMA].[EstatusPeriodo] ep
    ON pc.[FKIdEstatus_ALMA] = ep.[PKIdEstatusPeriodo]

LEFT JOIN [ALMA].[TipoBien] tb
    ON c.[FKIdTipoBien_ALMA] = tb.[PKIdTipoBien]

LEFT JOIN [ALMA].[GrupoBien] gb
    ON tb.[FKIdGrupoBien_ALMA] = gb.[PKIdGrupoBien]

LEFT JOIN [ALMA].[Familia] f
    ON gb.[FKIdFamilia_ALMA] = f.[PKIdFamilia]

LEFT JOIN [ALMA].[Unidades] u
    ON tb.[FKIdUnidades_ALMA] = u.[PKIdUnidades]

LEFT JOIN [SIS].[Usuario] uc
    ON c.[UsuarioCreacion] = uc.[PkIdUsuario]

LEFT JOIN [SIS].[Usuario] um
    ON c.[UsuarioModificacion] = um.[PkIdUsuario]

LEFT JOIN [NOM].[Persona] puc
    ON uc.[FKIdPersona_NOM] = puc.[PKIdPersona]

LEFT JOIN [NOM].[Persona] pum
    ON um.[FKIdPersona_NOM] = pum.[PKIdPersona]

LEFT JOIN [ALMA].[ConteoDetalle] cd
    ON c.[PKIdConteo] = cd.[FKIdConteo_ALMA]
       AND cd.[Activo] = 1

WHERE c.[Activo] = 1

GROUP BY
    c.[PKIdConteo],
    c.[CantidadInventario],
    c.[Descripcion],
    c.[FechaInicio],
    c.[FechaFin],
    c.[Activo],
    c.[FechaCreacion],
    c.[UsuarioCreacion],
    c.[FechaModificacion],
    c.[UsuarioModificacion],
    pc.[PKIdPeriodoConteo],
    pc.[CodigoPeriodo],
    pc.[Nombre],
    pc.[FechaInicio],
    pc.[FechaFin],
    tc.[PKIdTipoConteo],
    tc.[Nombre],
    tc.[Descripcion],
    ep.[PKIdEstatusPeriodo],
    ep.[Nombre],
    ep.[Descripcion],
    tb.[PKIdTipoBien],
    tb.[CodigoClave],
    tb.[Descripcion],
    gb.[PKIdGrupoBien],
    gb.[Descripcion],
    f.[PKIdFamilia],
    f.[Descripcion],
    u.[PKIdUnidades],
    u.[Descripcion],
    uc.[PkIdUsuario],
    puc.[Nombre],
    puc.[Paterno],
    puc.[Materno],
    um.[PkIdUsuario],
    pum.[Nombre],
    pum.[Paterno],
    pum.[Materno];
GO
PRINT N'Creando Vista [ALMA].[VW_PeriodoConteo]...';


GO

CREATE   VIEW  [ALMA].[VW_PeriodoConteo]
AS
SELECT
    pc.[PKIdPeriodoConteo],
    pc.[CodigoPeriodo],
    pc.[Nombre],
    pc.[Descripcion],
    pc.[FechaInicio],
    pc.[FechaFin],
    pc.[FechaCierre],
    pc.[MaximoConteosPorArticulo],
    pc.[RequiereAprobacionSupervisor],
    pc.[TotalArticulos],
    pc.[ArticulosConcluidos],
    pc.[ArticulosConDiferencia],
    pc.[Activo],
    pc.[FechaCreacion],
    pc.[UsuarioCreacion],
    pc.[FechaModificacion],
    pc.[UsuarioModificacion],

    -- Sucursal
    s.[PKIdSucursal]            AS [IdSucursal],
    s.[Nombre]                  AS [Sucursal],

    -- Tipo de conteo
    tc.[PKIdTipoConteo]         AS [IdTipoConteo],
    tc.[Nombre]                 AS [TipoConteo],
    tc.[Descripcion]            AS [DescripcionTipoConteo],

    -- Estatus del periodo
    ep.[PKIdEstatusPeriodo]     AS [IdEstatusPeriodo],
    ep.[Nombre]                 AS [EstatusPeriodo],
    ep.[Descripcion]            AS [DescripcionEstatusPeriodo],

    -- Responsable
    r.[PkIdUsuario]             AS [IdResponsable],
    ISNULL(pr.[Nombre], '') + ' ' + ISNULL(pr.[Paterno], '') + ' ' + ISNULL(pr.[Materno], '') AS [Responsable],
    -- Supervisor
    sup.[PkIdUsuario]           AS [IdSupervisor],
    ISNULL(psup.[Nombre], '') + ' ' + ISNULL(psup.[Paterno], '') + ' ' + ISNULL(psup.[Materno], '') AS [Supervisor]

FROM [ALMA].[PeriodoConteo] pc
LEFT JOIN [SIS].[Sucursal] s
    ON pc.[FKIdSucursal_SIS] = s.[PKIdSucursal]
LEFT JOIN [ALMA].[TipoConteo] tc
    ON pc.[FKIdTipoConteo_ALMA] = tc.[PKIdTipoConteo]
LEFT JOIN [ALMA].[EstatusPeriodo] ep
    ON pc.[FKIdEstatus_ALMA] = ep.[PKIdEstatusPeriodo]
LEFT JOIN [SIS].[Usuario] r
    ON pc.[FKIdResponsable_SIS] = r.[PkIdUsuario]
LEFT JOIN [SIS].[Usuario] sup
    ON pc.[FKIdSupervisor_SIS] = sup.[PkIdUsuario]
LEFT JOIN [NOM].[Persona] pr
    ON r.[FKIdPersona_NOM] = pr.[PKIdPersona]
LEFT JOIN [NOM].[Persona] psup
    ON sup.[FKIdPersona_NOM] = psup.[PKIdPersona];
GO
PRINT N'Creando Vista [ALMA].[VW_ConteoDetalleEscaneo]...';


GO

CREATE   VIEW  [ALMA].[VW_ConteoDetalleEscaneo]
AS
SELECT
    cde.[PKIdDetalleEscaneo],
    cde.[FKIdConteo_ALMA],
    cde.[FKIdPersona_NOM],
    cde.[CodigoBarras],
    cde.[FKIdTipoBien_ALMA],
    cde.[FKIdBien_ALMA],
    cde.[FechaEscaneo],
    cde.[Activo],
    cde.[FechaCreacion],
    cde.[UsuarioCreacion],
    cde.[FechaModificacion],
    cde.[UsuarioModificacion],
    -- Informaci�n del Conteo
    c.[Descripcion]             AS [ConteoDescripcion],
    c.[FechaInicio]             AS [ConteoFechaInicio],
    c.[FechaFin]                AS [ConteoFechaFin],
    c.[CantidadInventario]      AS [ConteoCantidadInventario],
    -- Informaci�n del Tipo de Bien
    tb.[Descripcion]            AS [TipoBienDescripcion],
    tb.[CodigoClave]            AS [TipoBienCodigoClave],
    -- Informaci�n de la Persona que escane�
    p.[Nombre]                  AS [PersonaNombre],
    p.[Paterno]                 AS [PersonaPaterno],
    p.[Materno]                 AS [PersonaMaterno],
    p.[Clave]                   AS [PersonaClave],
    -- Informaci�n del Bien (si est� asociado)
    b.[Clave]                   AS [BienClave],
    b.[Serie]                   AS [BienSerie],
    b.[Modelo]                  AS [BienModelo],
    b.[Descripcion]             AS [BienDescripcion]
FROM [ALMA].[ConteoDetalleEscaneo] cde
INNER JOIN [ALMA].[Conteo] c ON cde.[FKIdConteo_ALMA] = c.[PKIdConteo]
INNER JOIN [ALMA].[TipoBien] tb ON cde.[FKIdTipoBien_ALMA] = tb.[PKIdTipoBien]
INNER JOIN [NOM].[Persona] p ON cde.[FKIdPersona_NOM] = p.[PKIdPersona]
LEFT JOIN [ALMA].[Bien] b ON cde.[FKIdBien_ALMA] = b.[PKIdBien];
GO
PRINT N'Creando Vista [CONTA].[Vw_Cuentas]...';


GO

CREATE   VIEW  [CONTA].[Vw_Cuentas]
AS
SELECT 
    cc.PKIdCuentaContable AS PkIdCuenta,
    cc.ClaveOrd,
    cc.NivelCuenta,
    cc.Descripcion,
    cc.Activo,
    cc.TipoCuenta,
    cc.Padre,
	cc.Hijo,
	cc.ClaveOrd + ' ' + cc.Descripcion  AS ClaveNombre,
	cc.Descripcion AS Nombre 
FROM CONTA.CuentaContable cc
WHERE Activo = 1
GO
PRINT N'Creando Vista [CONTA].[Vw_MatrizConversionColumnas]...';


GO

CREATE   VIEW  [CONTA].[Vw_MatrizConversionColumnas] AS
SELECT 
    -- Identificador de la matriz
    mc.PKIdMatrizConversion,
    -- Año
    a.Clave AS AnioClave,
    -- Programa (clave + descripci�n)
    p.Clave AS ProgramaClave,
    p.Descripcion AS ProgramaDescripcion,
    -- Partida (clave + descripci�n)
    pt.Clave AS PartidaClave,
    CONCAT(pt.Clave, ' ', pt.Descripcion) AS PartidaDescripcion,
    -- Cuenta Aprobado
    ctaA.ClaveNombre AS CuentaAprobado,
    -- Cuenta por Ejercer
    ctaPJ.ClaveNombre AS CuentaPorEjercer,
    -- Cuenta Modificado
    ctaM.ClaveNombre AS CuentaModificado,
    -- Cuenta Comprometido
    ctaC.ClaveNombre AS CuentaComprometido,
    -- Cuenta Devengado
    ctaD.ClaveNombre AS CuentaDevengado,
    -- Cuenta Ejercido
    ctaE.ClaveNombre AS CuentaEjercido,
    -- Cuenta Pagado
    ctaPag.ClaveNombre AS CuentaPagado,
    -- Cuenta Gasto
    ctaG.ClaveNombre AS CuentaGasto,
    -- Datos de auditor�a
    mc.Activo,
    mc.FechaCreacion,
    mc.UsuarioCreacion
FROM CONTA.MatrizConversion mc
INNER JOIN SIS.Anio a ON mc.FKIdAnio_SIS = a.PKIdAnio
INNER JOIN PRES.Programa p ON mc.FKIdPrograma_PRES = p.PKIdPrograma
INNER JOIN SIS.Partida pt ON mc.FKIdPartida_SIS = pt.PKIdPartida
LEFT JOIN CONTA.Vw_Cuentas ctaA ON mc.FKIdCuentaContableAprobado = ctaA.PkIdCuenta AND ctaA.ClaveOrd LIKE '8 2 1%' AND ctaA.NivelCuenta = 7
LEFT JOIN CONTA.Vw_Cuentas ctaPJ ON mc.FKIdCuentaContablePorEjercer = ctaPJ.PkIdCuenta AND ctaPJ.ClaveOrd LIKE '8 2 2%'
LEFT JOIN CONTA.Vw_Cuentas ctaM ON mc.FKIdCuentaContableModificado = ctaM.PkIdCuenta AND ctaM.ClaveOrd LIKE '8 2 3%'
LEFT JOIN CONTA.Vw_Cuentas ctaC ON mc.FKIdCuentaContableComprometido = ctaC.PkIdCuenta AND ctaC.ClaveOrd LIKE '8 2 4%'
LEFT JOIN CONTA.Vw_Cuentas ctaD ON mc.FKIdCuentaContableDevengado = ctaD.PkIdCuenta AND ctaD.ClaveOrd LIKE '8 2 5%'
LEFT JOIN CONTA.Vw_Cuentas ctaE ON mc.FKIdCuentaContableEjercido = ctaE.PkIdCuenta AND ctaE.ClaveOrd LIKE '8 2 6%'
LEFT JOIN CONTA.Vw_Cuentas ctaPag ON mc.FKIdCuentaContablePagado = ctaPag.PkIdCuenta AND ctaPag.ClaveOrd LIKE '8 2 7%'
LEFT JOIN CONTA.Vw_Cuentas ctaG ON mc.FKIdCuentaContableGasto = ctaG.PkIdCuenta AND ctaA.ClaveOrd LIKE '5%'
WHERE mc.Activo = 1
GO
PRINT N'Creando Vista [CONTA].[Vw_MatrizIngresoColumnas]...';


GO

CREATE   VIEW  [CONTA].[Vw_MatrizIngresoColumnas]
AS
SELECT 
    -- Identificador de la matriz
    mi.Pk_IdMatrizIngreso,
    -- A�o
    a.Clave AS AnioClave,
    -- Programa
    p.Clave AS ProgramaClave,
    p.Descripcion AS ProgramaDescripcion,
    -- Origen (fuente del ingreso)
    o.Clave AS OrigenClave,
    o.Descripcion AS OrigenDescripcion,
    -- Cuenta Autorizado
    ctaAut.ClaveNombre AS CuentaAutorizado,
    -- Cuenta por Ejercer
    ctaPJE.ClaveNombre AS CuentaPorEjercer,
    -- Cuenta Modificado
    ctaMod.ClaveNombre AS CuentaModificado,
    -- Cuenta Devengado
    ctaDev.ClaveNombre AS CuentaDevengado,
    -- Cuenta Recaudado
    ctaRec.ClaveNombre AS CuentaRecaudado,
    -- Cuenta Dep�sito
    ctaDep.ClaveNombre AS CuentaDeposito,
    -- Datos de auditor�a
    mi.Activo,
    mi.FechaCreacion,
    mi.UsuarioCreacion
FROM CONTA.MatrizIngreso mi
LEFT JOIN SIS.Anio a ON mi.FK_IdAnio__SIS = a.PKIdAnio
LEFT JOIN PRES.Programa p ON mi.Fk_IdPrograma = p.PKIdPrograma
LEFT JOIN PRES.Origen o ON mi.Fk_IdOrigen = o.PKIdOrigen
LEFT JOIN CONTA.Vw_Cuentas ctaAut ON mi.Fk_IdCuentaContableAutorizado = ctaAut.PkIdCuenta AND ctaAut.ClaveOrd LIKE '8 1%' AND ctaAut.NivelCuenta = 7
LEFT JOIN CONTA.Vw_Cuentas ctaPJE ON mi.Fk_IdCuentaContablePorEjercer = ctaPJE.PkIdCuenta AND ctaPJE.ClaveOrd LIKE '8 1%' AND ctaPJE.NivelCuenta = 7
LEFT JOIN CONTA.Vw_Cuentas ctaMod ON mi.Fk_IdCuentaContableModificado = ctaMod.PkIdCuenta AND ctaMod.ClaveOrd LIKE '8 1%' AND ctaMod.NivelCuenta = 7
LEFT JOIN CONTA.Vw_Cuentas ctaDev ON mi.Fk_IdCuentaContableDevengado = ctaDev.PkIdCuenta AND ctaDev.ClaveOrd LIKE '8 1%' AND ctaDev.NivelCuenta = 7
LEFT JOIN CONTA.Vw_Cuentas ctaRec ON mi.Fk_IdCuentaContableRecaudado = ctaRec.PkIdCuenta AND ctaRec.ClaveOrd LIKE '8 1%' AND ctaRec.NivelCuenta = 7
LEFT JOIN CONTA.Vw_Cuentas ctaDep ON mi.Fk_IdCuentaContableDeposito = ctaDep.PkIdCuenta AND ctaDep.ClaveOrd LIKE '1%' AND ctaDep.NivelCuenta = 7
WHERE mi.Activo = 1;
GO
PRINT N'Creando Vista [CONTA].[Vw_PolizaDetalle]...';


GO

CREATE   VIEW [CONTA].[Vw_PolizaDetalle]
AS
SELECT
    pd.PKIdPolizaDetalle,
    pd.FKIdPoliza_CONTA,
    p.ClavePoliza,
    p.NombrePoliza,
    p.FechaPoliza,
    p.FKIdAnio_SIS,
    a.Clave AS Anio,
    p.FKIdMes_SIS,
    CASE p.FKIdMes_SIS
        WHEN 1 THEN 'Enero'
        WHEN 2 THEN 'Febrero'
        WHEN 3 THEN 'Marzo'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Mayo'
        WHEN 6 THEN 'Junio'
        WHEN 7 THEN 'Julio'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Septiembre'
        WHEN 10 THEN 'Octubre'
        WHEN 11 THEN 'Noviembre'
        WHEN 12 THEN 'Diciembre'
    END AS Mes,
    pd.FKIdCuentaContable_CONTA,
    cc.ClaveOrd AS CuentaClave,
    cc.Descripcion AS CuentaDescripcion,
    CONCAT(cc.ClaveOrd, ' ', cc.Descripcion) AS CuentaClaveNombre,
    pd.FKIdTipoDetallePoliza_SIS,
    tdp.Descripcion AS TipoDetallePoliza,
    pd.Descripcion,
    pd.ImporteDebe,
    pd.ImporteHaber,
    pd.FKIdReferencia,
    pd.Activo,
    pd.FechaCreacion,
    pd.UsuarioCreacion,
    pd.FechaModificacion,
    pd.UsuarioModificacion
FROM CONTA.PolizaDetalle pd
INNER JOIN CONTA.Poliza p ON pd.FKIdPoliza_CONTA = p.PKIdPoliza
INNER JOIN SIS.Anio a ON p.FKIdAnio_SIS = a.PKIdAnio
INNER JOIN CONTA.CuentaContable cc ON pd.FKIdCuentaContable_CONTA = cc.PKIdCuentaContable
LEFT JOIN SIS.TipoDetallePoliza tdp ON pd.FKIdTipoDetallePoliza_SIS = tdp.PkIdTipoDetallePoliza
WHERE pd.Activo = 1
  AND p.Activo = 1;
GO
PRINT N'Creando Vista [CONTA].[Vw_Poliza]...';


GO

CREATE   VIEW [CONTA].[Vw_Poliza]
AS
SELECT
    p.PKIdPoliza,
    p.FKIdAnio_SIS,
    a.Clave AS Anio,
    p.FKIdMes_SIS,
    CASE p.FKIdMes_SIS
        WHEN 1 THEN 'Enero'
        WHEN 2 THEN 'Febrero'
        WHEN 3 THEN 'Marzo'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Mayo'
        WHEN 6 THEN 'Junio'
        WHEN 7 THEN 'Julio'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Septiembre'
        WHEN 10 THEN 'Octubre'
        WHEN 11 THEN 'Noviembre'
        WHEN 12 THEN 'Diciembre'
    END AS Mes,
    p.FKIdTipoPoliza_SIS,
    tp.Descripcion AS TipoPoliza,
    p.ClavePoliza,
    p.NombrePoliza,
    p.FechaPoliza,
    p.EstaBalanceado,
    ISNULL(COUNT(pd.PKIdPolizaDetalle), 0) AS TotalDetalles,
    ISNULL(SUM(pd.ImporteDebe), 0) AS TotalDebe,
    ISNULL(SUM(pd.ImporteHaber), 0) AS TotalHaber,
    ISNULL(SUM(pd.ImporteDebe), 0) - ISNULL(SUM(pd.ImporteHaber), 0) AS Diferencia,
    p.PermitirModificar,
    p.FKIdAccionAutorizar_SIS,
    p.Autorizado,
    p.FechaSolicitud,
    p.FechaAutorizacion,
    p.Activo,
    p.FechaCreacion,
    p.UsuarioCreacion,
    p.FechaModificacion,
    p.UsuarioModificacion
FROM CONTA.Poliza p
INNER JOIN SIS.Anio a ON p.FKIdAnio_SIS = a.PKIdAnio
INNER JOIN SIS.TipoPoliza tp ON p.FKIdTipoPoliza_SIS = tp.PKIdTipoPoliza
LEFT JOIN CONTA.PolizaDetalle pd ON p.PKIdPoliza = pd.FKIdPoliza_CONTA
    AND pd.Activo = 1
WHERE p.Activo = 1
GROUP BY
    p.PKIdPoliza,
    p.FKIdAnio_SIS,
    a.Clave,
    p.FKIdMes_SIS,
    p.FKIdTipoPoliza_SIS,
    tp.Descripcion,
    p.ClavePoliza,
    p.NombrePoliza,
    p.FechaPoliza,
    p.EstaBalanceado,
    p.PermitirModificar,
    p.FKIdAccionAutorizar_SIS,
    p.Autorizado,
    p.FechaSolicitud,
    p.FechaAutorizacion,
    p.Activo,
    p.FechaCreacion,
    p.UsuarioCreacion,
    p.FechaModificacion,
    p.UsuarioModificacion;
GO
PRINT N'Creando Vista [ORCO].[Vw_Requisicion]...';


GO

CREATE   VIEW  [ORCO].[Vw_Requisicion]
AS
SELECT
    r.PKIdRequisicion,
    r.FKIdEmpresa_SIS,
    r.FKIdPersona_NOM,
    r.FKIdArea_SIS,
    r.Descripcion,
    r.Observaciones,
    r.FechaRequisicion,
    r.Servicio,
    r.FL_FOTO,
    r.FKIdProyecto_ORCO,
    r.FechaRequiereInicio,
    r.FechaRequiereFin,
    r.FKIdPrograma_PRES,
    r.Importe,
    r.FKIdJefeAlmacen_NOM,
    r.FKIdSuficiencia_PRES,
    r.FKIdSuperviso_NOM,
    r.FKIdAutorizo_NOM,
    r.FKIdPSolicita_NOM,
    r.FKIdPJefeAlmacen_NOM,
    r.FKIdPSuficiencia_NOM,
    r.FKIdPSuperviso_NOM,
    r.FKIdPAutorizo_NOM,
    r.FKIdFuenteFinanciamiento_PRES,
    r.FKIdAnio_SIS,
    r.FKIdTipoGasto_PRES,
    r.FKIdDigitoIdentificador_PRES,
    r.FKIdDestinoGasto_PRES,
    r.FKIdEgresoAutorizado_PRES,
    r.Oficio,
    r.FechaOficio,
    r.CompraDirecta,
    r.Activo,
    r.FechaCreacion,
    r.UsuarioCreacion,
    r.FechaModificacion,
    r.UsuarioModificacion,
    emp.Nombre AS EmpresaNombre,
    emp.RFC AS EmpresaRFC,
    a.Clave AS AnioClave,
    area.Nombre AS AreaNombre,
    area.Clave AS AreaClave,
    per.Nombre AS SolicitanteNombre,
    per.Paterno AS SolicitantePaterno,
    per.Materno AS SolicitanteMaterno,
    CONCAT(per.Nombre, ' ', per.Paterno, ' ', COALESCE(per.Materno, '')) AS SolicitanteCompleto,
    proy.Descripcion AS ProyectoDescripcion,
    prog.Clave AS ProgramaClave,
    prog.Descripcion AS ProgramaDescripcion,
    ff.Clave AS FuenteFinanciamientoClave,
    ff.Descripcion AS FuenteFinanciamientoDescripcion,
    tg.Clave AS TipoGastoClave,
    tg.Descripcion AS TipoGastoDescripcion,
    di.Clave AS DigitoIdentificadorClave,
    di.Descripcion AS DigitoIdentificadorDescripcion,
    dg.Clave AS DestinoGastoClave,
    dg.Descripcion AS DestinoGastoDescripcion,
    suf.Descripcion AS SuficienciaDescripcion,
    ea.Descripcion AS EgresoAutorizadoDescripcion,
    ea.Fecha AS EgresoAutorizadoFecha,
    jefe.Nombre AS JefeAlmacenNombre,
    jefe.Paterno AS JefeAlmacenPaterno,
    jefe.Materno AS JefeAlmacenMaterno,
    CONCAT(jefe.Nombre, ' ', jefe.Paterno, ' ', COALESCE(jefe.Materno, '')) AS JefeAlmacenCompleto,
    superviso.Nombre AS SupervisoNombre,
    superviso.Paterno AS SupervisoPaterno,
    superviso.Materno AS SupervisoMaterno,
    CONCAT(superviso.Nombre, ' ', superviso.Paterno, ' ', COALESCE(superviso.Materno, '')) AS SupervisoCompleto,
    autorizo.Nombre AS AutorizoNombre,
    autorizo.Paterno AS AutorizoPaterno,
    autorizo.Materno AS AutorizoMaterno,
    CONCAT(autorizo.Nombre, ' ', autorizo.Paterno, ' ', COALESCE(autorizo.Materno, '')) AS AutorizoCompleto,
    psolicita.Nombre AS PSolicitaNombre,
    psolicita.Paterno AS PSolicitaPaterno,
    psolicita.Materno AS PSolicitaMaterno,
    CONCAT(psolicita.Nombre, ' ', psolicita.Paterno, ' ', COALESCE(psolicita.Materno, '')) AS PSolicitaCompleto,
    pjefe.Nombre AS PJefeAlmacenNombre,
    pjefe.Paterno AS PJefeAlmacenPaterno,
    pjefe.Materno AS PJefeAlmacenMaterno,
    CONCAT(pjefe.Nombre, ' ', pjefe.Paterno, ' ', COALESCE(pjefe.Materno, '')) AS PJefeAlmacenCompleto,
    psuf.Nombre AS PSuficienciaNombre,
    psuf.Paterno AS PSuficienciaPaterno,
    psuf.Materno AS PSuficienciaMaterno,
    CONCAT(psuf.Nombre, ' ', psuf.Paterno, ' ', COALESCE(psuf.Materno, '')) AS PSuficienciaCompleto,
    psuperviso.Nombre AS PSupervisoNombre,
    psuperviso.Paterno AS PSupervisoPaterno,
    psuperviso.Materno AS PSupervisoMaterno,
    CONCAT(psuperviso.Nombre, ' ', psuperviso.Paterno, ' ', COALESCE(psuperviso.Materno, '')) AS PSupervisoCompleto,
    pautorizo.Nombre AS PAutorizoNombre,
    pautorizo.Paterno AS PAutorizoPaterno,
    pautorizo.Materno AS PAutorizoMaterno,
    CONCAT(pautorizo.Nombre, ' ', pautorizo.Paterno, ' ', COALESCE(pautorizo.Materno, '')) AS PAutorizoCompleto,
    CONCAT('REQ ', r.PKIdRequisicion, ' - ', r.Descripcion) AS ClaveNombre
FROM ORCO.Requisicion r
LEFT JOIN SIS.Empresa emp ON r.FKIdEmpresa_SIS = emp.PKIdEmpresa AND emp.Activo = 1
LEFT JOIN SIS.Anio a ON r.FKIdAnio_SIS = a.PKIdAnio AND a.Activo = 1
LEFT JOIN SIS.Area area ON r.FKIdArea_SIS = area.PKIdArea AND area.Activo = 1
LEFT JOIN NOM.Persona per ON r.FKIdPersona_NOM = per.PKIdPersona AND per.Activo = 1
LEFT JOIN ORCO.Proyecto proy ON r.FKIdProyecto_ORCO = proy.PKIdProyecto AND proy.Activo = 1
LEFT JOIN PRES.Programa prog ON r.FKIdPrograma_PRES = prog.PKIdPrograma AND prog.Activo = 1
LEFT JOIN PRES.FuenteFinanciamiento ff ON r.FKIdFuenteFinanciamiento_PRES = ff.PKIdFuenteFinanciamiento AND ff.Activo = 1
LEFT JOIN PRES.TipoGasto tg ON r.FKIdTipoGasto_PRES = tg.PKIdTipoGasto AND tg.Activo = 1
LEFT JOIN PRES.DigitoIdentificador di ON r.FKIdDigitoIdentificador_PRES = di.PKIdDigitoIdentificador AND di.Activo = 1
LEFT JOIN PRES.DestinoGasto dg ON r.FKIdDestinoGasto_PRES = dg.PKIdDestinoGasto AND dg.Activo = 1
LEFT JOIN PRES.Suficiencia suf ON r.FKIdSuficiencia_PRES = suf.PKIdSuficiencia AND suf.Activo = 1
LEFT JOIN PRES.EgresoAutorizado ea ON r.FKIdEgresoAutorizado_PRES = ea.PKIdEgresoAutorizado AND ea.Activo = 1
LEFT JOIN NOM.Persona jefe ON r.FKIdJefeAlmacen_NOM = jefe.PKIdPersona AND jefe.Activo = 1
LEFT JOIN NOM.Persona superviso ON r.FKIdSuperviso_NOM = superviso.PKIdPersona AND superviso.Activo = 1
LEFT JOIN NOM.Persona autorizo ON r.FKIdAutorizo_NOM = autorizo.PKIdPersona AND autorizo.Activo = 1
LEFT JOIN NOM.Persona psolicita ON r.FKIdPSolicita_NOM = psolicita.PKIdPersona AND psolicita.Activo = 1
LEFT JOIN NOM.Persona pjefe ON r.FKIdPJefeAlmacen_NOM = pjefe.PKIdPersona AND pjefe.Activo = 1
LEFT JOIN NOM.Persona psuf ON r.FKIdPSuficiencia_NOM = psuf.PKIdPersona AND psuf.Activo = 1
LEFT JOIN NOM.Persona psuperviso ON r.FKIdPSuperviso_NOM = psuperviso.PKIdPersona AND psuperviso.Activo = 1
LEFT JOIN NOM.Persona pautorizo ON r.FKIdPAutorizo_NOM = pautorizo.PKIdPersona AND pautorizo.Activo = 1
WHERE r.Activo = 1;
GO
PRINT N'Creando Vista [ORCO].[Vw_Fraccion]...';


GO

CREATE   VIEW  [ORCO].[Vw_Fraccion] AS
SELECT 
    f.PKIdFraccion,
    f.FKIdArticulo_ORCO,
    f.Clave,
    f.Descripcion,
    f.Activo,
    f.FechaCreacion,
    f.UsuarioCreacion,
    f.FechaModificacion,
    f.UsuarioModificacion,
    a.Descripcion AS ArticuloDescripcion,
    a.Clave AS ArticuloClave,
    CONCAT(a.Clave, ' - ', a.Descripcion) AS ArticuloClaveNombre
FROM ORCO.Fraccion f
LEFT JOIN ORCO.Articulo a ON f.FKIdArticulo_ORCO = a.PKIdArticulo AND a.Activo = 1
WHERE f.Activo = 1;
GO
PRINT N'Creando Vista [ORCO].[Vw_CotizacionDetalle]...';


GO

CREATE   VIEW [ORCO].[Vw_CotizacionDetalle] AS
SELECT
    cd.PKIdCotizacionDetalle,
    cd.FKIdCotizacion_ORCO,
    c.FKIdRequisicion_ORCO,
    req.Descripcion AS RequisicionDescripcion,
    req.FechaRequisicion,
    c.FKIdProveedor_SIS,
    prov.Nombre AS ProveedorNombre,
    prov.Clave AS ProveedorClave,
    prov.RFC AS ProveedorRFC,
    cd.FKIdRequisicionDetalle_ORCO,
    rd.FKIdTipoBien_ALMA,
    tb.CodigoClave AS TipoBienClave,
    tb.Descripcion AS TipoBienDescripcion,
    rd.FKIdUnidades_ALMA,
    u.Descripcion AS UnidadMedida,
    rd.Cantidad,
    c.FechaSolicitud,
    c.FechaProveedorCotiza,
    c.FechaProveedorCompromiso,
    c.Comentarios,
    c.Servicio,
    c.FL_Documento,
    c.Entrega,
    c.Vigencia,
    c.Condiciones,
    cd.PrecioUnitario,
    CASE WHEN cd.PrecioUnitario IS NULL THEN NULL ELSE cd.PrecioUnitario * rd.Cantidad END AS Importe,
    c.FKIdAnio_SIS,
    c.FKIdContenedorCot_ORCO,
    c.FKIdContenedorMultiCot_ORCO,
    cd.Activo,
    cd.FechaCreacion,
    cd.UsuarioCreacion,
    cd.FechaModificacion,
    cd.UsuarioModificacion
FROM ORCO.CotizacionDetalle cd
INNER JOIN ORCO.Cotizacion c ON cd.FKIdCotizacion_ORCO = c.PKIdCotizacion AND c.Activo = 1
INNER JOIN ORCO.Requisicion req ON c.FKIdRequisicion_ORCO = req.PKIdRequisicion AND req.Activo = 1
INNER JOIN SIS.Proveedor prov ON c.FKIdProveedor_SIS = prov.PKIdProveedor AND prov.Activo = 1
INNER JOIN ORCO.RequisicionDetalle rd ON cd.FKIdRequisicionDetalle_ORCO = rd.PKIdRequisicionDetalle AND rd.Activo = 1
INNER JOIN ALMA.TipoBien tb ON rd.FKIdTipoBien_ALMA = tb.PKIdTipoBien AND tb.Activo = 1
LEFT JOIN ALMA.Unidades u ON rd.FKIdUnidades_ALMA = u.PKIdUnidades AND u.Activo = 1
WHERE cd.Activo = 1;
GO
PRINT N'Creando Vista [ORCO].[Vw_EstudioMercadoDetalle]...';


GO
--drop VIEW [ORCO].[VwEstudioMercadoDetalle]
CREATE   VIEW [ORCO].[Vw_EstudioMercadoDetalle] AS
SELECT
    emd.PKIdEstudioMercadoDetalle,
    emd.FKIdEmpresa_SIS,
    emd.FKIdEstudioMercado_ORCO,
    em.Nombre AS EstudioMercadoNombre,
    emd.FKIdPAAASDetalle_ORCO,
    emd.FKIdTipoBien_ALMA,
    tb.Descripcion AS TipoBienDescripcion,
    tb.CodigoClave AS TipoBienClave,
    emd.Cantidad,
    emd.Observaciones,
    emd.Activo,
    emd.FechaCreacion,
    emd.UsuarioCreacion,
    emd.FechaModificacion,
    emd.UsuarioModificacion
FROM ORCO.EstudioMercadoDetalle emd
LEFT JOIN ORCO.EstudioMercado em ON emd.FKIdEstudioMercado_ORCO = em.PKIdEstudioMercado AND em.Activo = 1
LEFT JOIN ALMA.TipoBien tb ON emd.FKIdTipoBien_ALMA = tb.PKIdTipoBien AND tb.Activo = 1
WHERE emd.Activo = 1;
GO
PRINT N'Creando Vista [ORCO].[Vw_EstudioMercado]...';


GO
--drop VIEW [ORCO].[VwEstudioMercado]
CREATE   VIEW [ORCO].[Vw_EstudioMercado] AS
SELECT
    em.PKIdEstudioMercado,
    em.FKIdEmpresa_SIS,
    em.FKIdAnio_SIS,
    a.Clave AS AnioClave,
    em.Nombre,
    em.Descripcion,
    em.FechaSolicitud,
    em.FechaCierre,
    em.FKIdResponsable_NOM,
    CONCAT(p.Nombre, ' ', p.Paterno, ' ', ISNULL(p.Materno, '')) AS ResponsableNombre,
    em.Estatus,
    em.Activo,
    em.FechaCreacion,
    em.UsuarioCreacion,
    em.FechaModificacion,
    em.UsuarioModificacion
FROM ORCO.EstudioMercado em
LEFT JOIN SIS.Anio a ON em.FKIdAnio_SIS = a.PKIdAnio AND a.Activo = 1
LEFT JOIN NOM.Persona p ON em.FKIdResponsable_NOM = p.PKIdPersona AND p.Activo = 1
WHERE em.Activo = 1;
GO
PRINT N'Creando Vista [ORCO].[Vw_PAAASPartida]...';


GO

CREATE   VIEW  [ORCO].[Vw_PAAASPartida]
AS
SELECT 
    pp.PKIdPAAASPartida,
    pp.FKIdEmpresa_SIS,
    pp.FKIdPAAAS_ORCO,
    pp.FKIdPartida_CONTA,
    pp.Observaciones,
    pp.Activo,
    pp.FechaCreacion,
    pp.UsuarioCreacion,
    pp.FechaModificacion,
    pp.UsuarioModificacion,
    -- Resoluci�n de claves for�neas
    part.Clave AS PartidaClave,
    part.Descripcion AS PartidaDescripcion,
    -- Datos del PAAAS padre
    paaas.Descripcion AS PAAASDescripcion,
    -- Columna para combos
    CONCAT(part.Clave, ' - ', part.Descripcion) AS ClaveNombre
FROM ORCO.PAAASPartida pp
LEFT JOIN CONTA.Partida part ON pp.FKIdPartida_CONTA = part.PKIdPartida AND part.Activo = 1
LEFT JOIN ORCO.PAAAS paaas ON pp.FKIdPAAAS_ORCO = paaas.PKIdPAAAS AND paaas.Activo = 1
WHERE pp.Activo = 1;
GO
PRINT N'Creando Vista [ORCO].[Vw_RequisicionDetalle]...';


GO

CREATE   VIEW  [ORCO].[Vw_RequisicionDetalle]
AS
SELECT
    rd.PKIdRequisicionDetalle,
    rd.FKIdEmpresa_SIS,
    rd.FKIdRequisicion_ORCO,
    rd.FKIdTipoBien_ALMA,
    rd.FKIdUnidades_ALMA,
    rd.Cantidad,
    rd.Observaciones,
    rd.Activo,
    rd.FechaCreacion,
    rd.UsuarioCreacion,
    rd.FechaModificacion,
    rd.UsuarioModificacion,
    emp.Nombre AS EmpresaNombre,
    req.Descripcion AS RequisicionDescripcion,
    req.FechaRequisicion,
    req.Servicio AS RequisicionServicio,
    tb.Descripcion AS TipoBienDescripcion,
    tb.CodigoClave AS TipoBienCodigoClave,
    tb.CABMS,
    tb.Identificador,
    tb.ExistenciaMinima,
    tb.ExistenciaMaxima,
    u.Descripcion AS UnidadMedida,
    CONCAT(tb.CodigoClave, ' - ', tb.Descripcion) AS BienClaveNombre
FROM ORCO.RequisicionDetalle rd
LEFT JOIN SIS.Empresa emp ON rd.FKIdEmpresa_SIS = emp.PKIdEmpresa AND emp.Activo = 1
LEFT JOIN ORCO.Requisicion req ON rd.FKIdRequisicion_ORCO = req.PKIdRequisicion AND req.Activo = 1
LEFT JOIN ALMA.TipoBien tb ON rd.FKIdTipoBien_ALMA = tb.PKIdTipoBien AND tb.Activo = 1
LEFT JOIN ALMA.Unidades u ON rd.FKIdUnidades_ALMA = u.PKIdUnidades AND u.Activo = 1
WHERE rd.Activo = 1;
GO
PRINT N'Creando Vista [ORCO].[Vw_PAAASDetalle]...';


GO

CREATE   VIEW  [ORCO].[Vw_PAAASDetalle]
AS
SELECT 
    dp.PKIdPAAASDetalle,
    dp.FKIdEmpresa_SIS,
    dp.FKIdPAAASPartida_ORCO,
    dp.FKIdTipoBien_ALMA,
    dp.FKIdUnidades_ALMA,
    dp.Cantidad,
    dp.Observaciones,
    dp.LugarEntrega,
    dp.Activo,
    dp.FechaCreacion,
    dp.UsuarioCreacion,
    dp.FechaModificacion,
    dp.UsuarioModificacion,
    -- Resoluci�n de claves for�neas
    tb.Descripcion AS TipoBienDescripcion,
    tb.CodigoClave AS TipoBienCodigoClave,
    tb.CABMS,
    tb.Identificador,
    tb.ExistenciaMinima,
    tb.ExistenciaMaxima,
    u.Descripcion AS UnidadMedida,
    -- Datos de la partida y PAAAS
    pp.FKIdPAAAS_ORCO,
    pp.FKIdPartida_CONTA,
    part.Clave AS PartidaClave,
    part.Descripcion AS PartidaDescripcion,
    -- Columna combinada para mostrar el bien
    CONCAT(tb.CodigoClave, ' - ', tb.Descripcion) AS BienClaveNombre
FROM ORCO.PAAASDetalle dp
LEFT JOIN ALMA.TipoBien tb ON dp.FKIdTipoBien_ALMA = tb.PKIdTipoBien AND tb.Activo = 1
LEFT JOIN ALMA.Unidades u ON dp.FKIdUnidades_ALMA = u.PKIdUnidades AND u.Activo = 1
LEFT JOIN ORCO.PAAASPartida pp ON dp.FKIdPAAASPartida_ORCO = pp.PKIdPAAASPartida AND pp.Activo = 1
LEFT JOIN CONTA.Partida part ON pp.FKIdPartida_CONTA = part.PKIdPartida AND part.Activo = 1
WHERE dp.Activo = 1;
GO
PRINT N'Creando Vista [ORCO].[VW_ReporteBienesProgramaAnual]...';


GO

CREATE   VIEW  [ORCO].[VW_ReporteBienesProgramaAnual] AS
WITH 
-- 1. Resumen de �reas solicitantes por bien
AreasPorBien AS (
    SELECT 
        dp.FKIdTipoBien_ALMA,
        COUNT(DISTINCT p.FKIdArea_SIS) AS TotalAreasSolicitantes
    FROM ORCO.PAAASDetalle dp
    INNER JOIN ORCO.PAAASPartida pp ON dp.FKIdPAAASPartida_ORCO = pp.PKIdPAAASPartida
    INNER JOIN ORCO.PAAAS p ON pp.FKIdPAAAS_ORCO = p.PKIdPAAAS
    WHERE dp.Activo = 1 AND pp.Activo = 1 AND p.Activo = 1
    GROUP BY dp.FKIdTipoBien_ALMA
),

-- 2. Cantidad total solicitada por bien
CantidadTotalPorBien AS (
    SELECT 
        FKIdTipoBien_ALMA,
        SUM(Cantidad) AS CantidadTotalSolicitada
    FROM ORCO.PAAASDetalle
    WHERE Activo = 1
    GROUP BY FKIdTipoBien_ALMA
),

-- 3. Resumen de cotizaciones por bien
CotizacionesPorBien AS (
    SELECT 
        emd.FKIdTipoBien_ALMA,
        COUNT(DISTINCT sc.FKIdProveedor_SIS) AS TotalProveedoresCotizaron,
        COUNT(cd.PKIdEstudioMercadoDetalleCosto) AS TotalCotizacionesRecibidas,
        MIN(cd.PrecioUnitario) AS PrecioMinimo,
        MAX(cd.PrecioUnitario) AS PrecioMaximo,
        AVG(CAST(cd.PrecioUnitario AS DECIMAL(20,4))) AS PrecioPromedio,
        MAX(cd.FechaRespuesta) AS UltimaCotizacion
    FROM ORCO.EstudioMercadoDetalle emd
    INNER JOIN ORCO.EstudioMercadoDetalleCosto cd ON emd.PKIdEstudioMercadoDetalle = cd.FKIdEstudioMercadoDetalle_ORCO
    INNER JOIN ORCO.SolicitudCotizacion sc ON cd.FKIdSolicitudCotizacion_ORCO = sc.PKIdSolicitudCotizacion
    WHERE emd.Activo = 1 AND cd.Activo = 1 AND sc.Activo = 1
    GROUP BY emd.FKIdTipoBien_ALMA
)

-- 4. Vista final consolidada
SELECT 
    tb.PKIdTipoBien,
    tb.Descripcion AS NombreBien,
    tb.CodigoClave AS ClaveBien,
    u.Descripcion AS UnidadMedida,
    
    -- Cantidad de �reas que lo solicitaron
    ISNULL(apb.TotalAreasSolicitantes, 0) AS TotalAreasSolicitantes,
    
    -- Cantidad total de bienes solicitada
    ISNULL(cb.CantidadTotalSolicitada, 0) AS CantidadTotalSolicitada,
    
    -- Estad�sticas de cotizaciones
    ISNULL(cpb.TotalProveedoresCotizaron, 0) AS ProveedoresQueCotizaron,
    ISNULL(cpb.TotalCotizacionesRecibidas, 0) AS TotalCotizacionesRecibidas,
    
    -- Precios
    cpb.PrecioMinimo,
    cpb.PrecioMaximo,
    cpb.PrecioPromedio,
    
    -- Fecha de �ltima actualizaci�n
    cpb.UltimaCotizacion,
    
    -- Fecha de �ltima modificaci�n del registro del bien
    tb.FechaModificacion AS UltimaActualizacionBien,
    
    -- Indicadores de estado
    CASE 
        WHEN cpb.TotalCotizacionesRecibidas > 0 THEN 'Cotizado'
        WHEN cb.CantidadTotalSolicitada > 0 THEN 'Solicitado sin cotizar'
        ELSE 'Sin actividad'
    END AS Estatus

FROM ALMA.TipoBien tb
LEFT JOIN ALMA.Unidades u ON tb.FKIdUnidades_ALMA = u.PKIdUnidades
LEFT JOIN AreasPorBien apb ON tb.PKIdTipoBien = apb.FKIdTipoBien_ALMA
LEFT JOIN CantidadTotalPorBien cb ON tb.PKIdTipoBien = cb.FKIdTipoBien_ALMA
LEFT JOIN CotizacionesPorBien cpb ON tb.PKIdTipoBien = cpb.FKIdTipoBien_ALMA
WHERE tb.Activo = 1;
GO
PRINT N'Creando Vista [ORCO].[Vw_DetalleRequisicion]...';


GO

CREATE   VIEW  [ORCO].[Vw_DetalleRequisicion]
AS
SELECT
    dr.PKIdDetalleRequisicion,
    dr.FKIdEmpresa_SIS,
    dr.FKIdRequisicion_ORCO,
    dr.FKIdTipoBien_ALMA,
    dr.FKIdUnidades_ALMA,
    dr.Cantidad,
    dr.Observaciones,
    dr.Activo,
    dr.FechaCreacion,
    dr.UsuarioCreacion,
    dr.FechaModificacion,
    dr.UsuarioModificacion,
    emp.Nombre AS EmpresaNombre,
    req.Descripcion AS RequisicionDescripcion,
    req.FechaRequisicion,
    req.Servicio AS RequisicionServicio,
    tb.Descripcion AS TipoBienDescripcion,
    tb.CodigoClave AS TipoBienCodigoClave,
    tb.CABMS,
    tb.Identificador,
    tb.ExistenciaMinima,
    tb.ExistenciaMaxima,
    u.Descripcion AS UnidadMedida,
    CONCAT(tb.CodigoClave, ' - ', tb.Descripcion) AS BienClaveNombre
FROM ORCO.DetalleRequisicion dr
LEFT JOIN SIS.Empresa emp ON dr.FKIdEmpresa_SIS = emp.PKIdEmpresa AND emp.Activo = 1
LEFT JOIN ORCO.Requisicion req ON dr.FKIdRequisicion_ORCO = req.PKIdRequisicion AND req.Activo = 1
LEFT JOIN ALMA.TipoBien tb ON dr.FKIdTipoBien_ALMA = tb.PKIdTipoBien AND tb.Activo = 1
LEFT JOIN ALMA.Unidades u ON dr.FKIdUnidades_ALMA = u.PKIdUnidades AND u.Activo = 1
WHERE dr.Activo = 1;
GO
PRINT N'Creando Vista [ORCO].[Vw_Cotizacion]...';


GO

CREATE   VIEW [ORCO].[Vw_Cotizacion] AS
SELECT
    c.PKIdCotizacion,
    c.FKIdRequisicion_ORCO,
    req.Descripcion AS RequisicionDescripcion,
    c.FKIdProveedor_SIS,
    prov.Nombre AS ProveedorNombre,
    prov.Clave AS ProveedorClave,
    prov.RFC AS ProveedorRFC,
    c.FechaSolicitud,
    c.FechaProveedorCotiza,
    c.FechaProveedorCompromiso,
    c.Comentarios,
    c.Servicio,
    c.FL_Documento,
    c.Entrega,
    c.Vigencia,
    c.Condiciones,
    c.FKIdAnio_SIS,
    ISNULL(resumen.TotalDetalles, 0) AS TotalDetalles,
    ISNULL(resumen.TotalCotizado, 0) AS TotalCotizado,
    c.Activo,
    c.FechaCreacion,
    c.UsuarioCreacion,
    c.FechaModificacion,
    c.UsuarioModificacion
FROM ORCO.Cotizacion c
INNER JOIN ORCO.Requisicion req ON c.FKIdRequisicion_ORCO = req.PKIdRequisicion AND req.Activo = 1
INNER JOIN SIS.Proveedor prov ON c.FKIdProveedor_SIS = prov.PKIdProveedor AND prov.Activo = 1
OUTER APPLY (
    SELECT
        COUNT(*) AS TotalDetalles,
        SUM(CASE WHEN cd.PrecioUnitario IS NULL THEN 0 ELSE cd.PrecioUnitario * rd.Cantidad END) AS TotalCotizado
    FROM ORCO.CotizacionDetalle cd
    INNER JOIN ORCO.RequisicionDetalle rd ON cd.FKIdRequisicionDetalle_ORCO = rd.PKIdRequisicionDetalle AND rd.Activo = 1
    WHERE cd.FKIdCotizacion_ORCO = c.PKIdCotizacion
      AND cd.Activo = 1
) resumen
WHERE c.Activo = 1;
GO
PRINT N'Creando Vista [ORCO].[Vw_RequisicionPartida]...';


GO

CREATE   VIEW  [ORCO].[Vw_RequisicionPartida]
AS
SELECT
    rp.PKIdRequisicionPartida,
    rp.FKIdEmpresa_SIS,
    rp.FKIdRequisicion_ORCO,
    rp.FKIdPartida_CONTA,
    rp.Monto,
    rp.Observaciones,
    rp.Activo,
    rp.FechaCreacion,
    rp.UsuarioCreacion,
    rp.FechaModificacion,
    rp.UsuarioModificacion,
    emp.Nombre AS EmpresaNombre,
    req.Descripcion AS RequisicionDescripcion,
    req.FechaRequisicion,
    req.Importe AS RequisicionImporte,
    part.Clave AS PartidaClave,
    part.Descripcion AS PartidaDescripcion,
    CONCAT(part.Clave, ' - ', part.Descripcion) AS ClaveNombre
FROM ORCO.RequisicionPartida rp
LEFT JOIN SIS.Empresa emp ON rp.FKIdEmpresa_SIS = emp.PKIdEmpresa AND emp.Activo = 1
LEFT JOIN ORCO.Requisicion req ON rp.FKIdRequisicion_ORCO = req.PKIdRequisicion AND req.Activo = 1
LEFT JOIN CONTA.Partida part ON rp.FKIdPartida_CONTA = part.PKIdPartida AND part.Activo = 1
WHERE rp.Activo = 1;
GO
PRINT N'Creando Vista [ORCO].[Vw_PAAAS]...';


GO

CREATE   VIEW  [ORCO].[Vw_PAAAS]
AS
SELECT 
    p.PKIdPAAAS,
    p.FKIdEmpresa_SIS,
    p.FKIdAnio_SIS,
    p.FKIdArea_SIS,
    p.FKIdPersona_NOM,
    p.Descripcion,
    p.Observaciones,
    p.Fecha,
    p.FKIdProyecto_ORCO,
    p.FKIdPrograma_PRES,
    p.FKIdFuenteFinanciamiento_PRES,
    p.Activo,
    p.FechaCreacion,
    p.UsuarioCreacion,
    p.FechaModificacion,
    p.UsuarioModificacion,
    -- Resoluci�n de claves for�neas
    a.Clave AS AnioClave,
    a.Clave AS AnioDescripcion,
    area.Nombre AS AreaNombre,
    area.Clave AS AreaClave,
    per.Nombre AS ResponsableNombre,
    per.Paterno AS ResponsablePaterno,
    per.Materno AS ResponsableMaterno,
    CONCAT(per.Nombre, ' ', per.Paterno, ' ', COALESCE(per.Materno, '')) AS ResponsableCompleto,
    proy.Descripcion AS ProyectoDescripcion,
    prog.Clave AS ProgramaClave,
    prog.Descripcion AS ProgramaDescripcion,
    ff.Descripcion AS FuenteFinanciamientoDescripcion,
    ff.Clave AS FuenteFinanciamientoClave,
    -- Columna adicional para combos
    CONCAT('PAAAS ', p.PKIdPAAAS, ' - ', area.Nombre, ' (', a.Clave, ')') AS ClaveNombre
FROM ORCO.PAAAS p
LEFT JOIN SIS.Anio a ON p.FKIdAnio_SIS = a.PKIdAnio
LEFT JOIN SIS.Area area ON p.FKIdArea_SIS = area.PKIdArea AND area.Activo = 1
LEFT JOIN NOM.Persona per ON p.FKIdPersona_NOM = per.PKIdPersona AND per.Activo = 1
LEFT JOIN ORCO.Proyecto proy ON p.FKIdProyecto_ORCO = proy.PKIdProyecto AND proy.Activo = 1
LEFT JOIN PRES.Programa prog ON p.FKIdPrograma_PRES = prog.PKIdPrograma AND prog.Activo = 1
LEFT JOIN PRES.FuenteFinanciamiento ff ON p.FKIdFuenteFinanciamiento_PRES = ff.PKIdFuenteFinanciamiento AND ff.Activo = 1
WHERE p.Activo = 1;
GO
PRINT N'Creando Vista [PRES].[Vw_FacturaDetalle]...';


GO

CREATE   VIEW [PRES].[Vw_FacturaDetalle] AS
SELECT
    fd.PKIdFacturaDetalle,
    fd.FKIdEmpresa_SIS,
    emp.Nombre AS EmpresaNombre,
    fd.FKIdFactura_PRES,
    f.NumFactura,
    fd.FKIdContratoDetalle_PRES,
    cd.FKIdContrato_PRES,
    c.NumeroContrato,
    fd.FKIdPartida_CONTA,
    part.Clave AS PartidaClave,
    part.Descripcion AS PartidaDescripcion,
    CONCAT(part.Clave, ' - ', part.Descripcion) AS PartidaClaveNombre,
    fd.MontoAplicado,
    fd.Observaciones,
    fd.Activo,
    fd.FechaCreacion,
    fd.UsuarioCreacion,
    fd.FechaModificacion,
    fd.UsuarioModificacion
FROM PRES.FacturaDetalle fd
INNER JOIN PRES.Factura f ON fd.FKIdFactura_PRES = f.PKIdFactura AND f.Activo = 1
INNER JOIN PRES.ContratoDetalle cd ON fd.FKIdContratoDetalle_PRES = cd.PKIdContratoDetalle AND cd.Activo = 1
INNER JOIN PRES.Contrato c ON cd.FKIdContrato_PRES = c.PKIdContrato AND c.Activo = 1
LEFT JOIN SIS.Empresa emp ON fd.FKIdEmpresa_SIS = emp.PKIdEmpresa AND emp.Activo = 1
LEFT JOIN CONTA.Partida part ON fd.FKIdPartida_CONTA = part.PKIdPartida AND part.Activo = 1
WHERE fd.Activo = 1;
GO
PRINT N'Creando Vista [PRES].[Vw_CLC]...';


GO

CREATE   VIEW [PRES].[Vw_CLC] AS
SELECT
    clc.PKIdCLC,
    clc.FKIdEmpresa_SIS,
    emp.Nombre AS EmpresaNombre,
    clc.FKIdContrato_PRES,
    c.NumeroContrato,
    c.FKIdProveedor_SIS,
    prov.Nombre AS ProveedorNombre,
    clc.FKIdPoliza_CONTA,
    pol.ClavePoliza,
    clc.NumCLC,
    clc.FechaSolicitud,
    clc.FechaAutorizacion,
    clc.ImporteTotal,
    clc.Observaciones,
    clc.Estatus,
    CASE clc.Estatus WHEN 1 THEN 'Borrador' WHEN 2 THEN 'Solicitada' WHEN 3 THEN 'Autorizada' WHEN 4 THEN 'Pagada' WHEN 5 THEN 'Cancelada' ELSE 'Sin definir' END AS EstatusDescripcion,
    clc.Activo,
    clc.FechaCreacion,
    clc.UsuarioCreacion,
    clc.FechaModificacion,
    clc.UsuarioModificacion
FROM PRES.CLC clc
INNER JOIN PRES.Contrato c ON clc.FKIdContrato_PRES = c.PKIdContrato AND c.Activo = 1
LEFT JOIN SIS.Empresa emp ON clc.FKIdEmpresa_SIS = emp.PKIdEmpresa AND emp.Activo = 1
LEFT JOIN SIS.Proveedor prov ON c.FKIdProveedor_SIS = prov.PKIdProveedor AND prov.Activo = 1
LEFT JOIN CONTA.Poliza pol ON clc.FKIdPoliza_CONTA = pol.PKIdPoliza AND pol.Activo = 1
WHERE clc.Activo = 1;
GO
PRINT N'Creando Vista [PRES].[Vw_SubFuncion]...';


GO

CREATE   VIEW  [PRES].[Vw_SubFuncion]
AS
SELECT 
    sf.PKIdSF,
    sf.Clave AS SubFuncionClave,
    sf.Descripcion AS SubFuncionDescripcion,
    sf.FKIdFN_PRES,
    sf.Activo,
    -- Datos de la Funci�n padre
    fn.Clave AS FuncionClave,
    fn.Descripcion AS FuncionDescripcion,
    -- Opcional: concatenaci�n �til para combos
    CAST(sf.Clave AS NVARCHAR(10)) + ' - ' + sf.Descripcion AS SubFuncionClaveNombre,
    CAST(fn.Clave AS NVARCHAR(10)) + ' - ' + fn.Descripcion AS FuncionClaveNombre
FROM PRES.SF sf
LEFT JOIN PRES.FN fn ON sf.FKIdFN_PRES = fn.PKIdFN AND fn.Activo = 1
WHERE sf.Activo = 1;
GO
PRINT N'Creando Vista [PRES].[Vw_Cheque]...';


GO

CREATE   VIEW [PRES].[Vw_Cheque] AS
SELECT
    ch.PKIdCheque,
    ch.FKIdEmpresa_SIS,
    emp.Nombre AS EmpresaNombre,
    ch.FKIdCLC_PRES,
    clc.NumCLC,
    clc.FKIdContrato_PRES,
    c.NumeroContrato,
    ch.FKIdCuentaBancaria_TES,
    ch.FKIdPoliza_CONTA,
    pol.ClavePoliza,
    ch.FechaEmision,
    ch.NumeroCheque,
    ch.Concepto,
    ch.ImporteTotal,
    ch.Observaciones,
    ch.Estatus,
    CASE ch.Estatus WHEN 1 THEN 'Registrado' WHEN 2 THEN 'Entregado' WHEN 3 THEN 'Cobrado' WHEN 4 THEN 'Cancelado' ELSE 'Sin definir' END AS EstatusDescripcion,
    ch.Activo,
    ch.FechaCreacion,
    ch.UsuarioCreacion,
    ch.FechaModificacion,
    ch.UsuarioModificacion
FROM PRES.Cheque ch
INNER JOIN PRES.CLC clc ON ch.FKIdCLC_PRES = clc.PKIdCLC AND clc.Activo = 1
INNER JOIN PRES.Contrato c ON clc.FKIdContrato_PRES = c.PKIdContrato AND c.Activo = 1
LEFT JOIN SIS.Empresa emp ON ch.FKIdEmpresa_SIS = emp.PKIdEmpresa AND emp.Activo = 1
LEFT JOIN CONTA.Poliza pol ON ch.FKIdPoliza_CONTA = pol.PKIdPoliza AND pol.Activo = 1
WHERE ch.Activo = 1;
GO
PRINT N'Creando Vista [PRES].[Vw_SolicitudSuficienciaDetalle]...';


GO

CREATE   VIEW [PRES].[Vw_SolicitudSuficienciaDetalle] AS
SELECT
    ssd.PKIdSolicitudSuficienciaDetalle,
    ssd.FKIdEmpresa_SIS,
    emp.Nombre AS EmpresaNombre,
    ssd.FKIdSolicitudSuficiencia_PRES,
    ss.FKIdRequisicion_ORCO,
    req.Descripcion AS RequisicionDescripcion,
    ss.FechaSolicitud,
    ss.Estatus AS SolicitudEstatus,
    ssd.FKIdRequisicionDetalle_ORCO,
    rd.FKIdTipoBien_ALMA,
    tb.CodigoClave AS TipoBienClave,
    tb.Descripcion AS TipoBienDescripcion,
    rd.FKIdUnidades_ALMA,
    u.Descripcion AS UnidadMedida,
    rd.Cantidad,
    ssd.FKIdPartida_CONTA,
    part.Clave AS PartidaClave,
    part.Descripcion AS PartidaDescripcion,
    CONCAT(part.Clave, ' - ', part.Descripcion) AS PartidaClaveNombre,
    ssd.Enero,
    ssd.Febrero,
    ssd.Marzo,
    ssd.Abril,
    ssd.Mayo,
    ssd.Junio,
    ssd.Julio,
    ssd.Agosto,
    ssd.Septiembre,
    ssd.Octubre,
    ssd.Noviembre,
    ssd.Diciembre,
    ssd.Total,
    ssd.Observaciones,
    ssd.Activo,
    ssd.FechaCreacion,
    ssd.UsuarioCreacion,
    ssd.FechaModificacion,
    ssd.UsuarioModificacion
FROM PRES.SolicitudSuficienciaDetalle ssd
INNER JOIN PRES.SolicitudSuficiencia ss ON ssd.FKIdSolicitudSuficiencia_PRES = ss.PKIdSolicitudSuficiencia AND ss.Activo = 1
LEFT JOIN SIS.Empresa emp ON ssd.FKIdEmpresa_SIS = emp.PKIdEmpresa AND emp.Activo = 1
LEFT JOIN ORCO.Requisicion req ON ss.FKIdRequisicion_ORCO = req.PKIdRequisicion AND req.Activo = 1
LEFT JOIN ORCO.RequisicionDetalle rd ON ssd.FKIdRequisicionDetalle_ORCO = rd.PKIdRequisicionDetalle AND rd.Activo = 1
LEFT JOIN ALMA.TipoBien tb ON rd.FKIdTipoBien_ALMA = tb.PKIdTipoBien AND tb.Activo = 1
LEFT JOIN ALMA.Unidades u ON rd.FKIdUnidades_ALMA = u.PKIdUnidades AND u.Activo = 1
LEFT JOIN CONTA.Partida part ON ssd.FKIdPartida_CONTA = part.PKIdPartida AND part.Activo = 1
WHERE ssd.Activo = 1;
GO
PRINT N'Creando Vista [PRES].[Vw_EgresoAutorizado]...';


GO

CREATE   VIEW [PRES].[Vw_EgresoAutorizado]
AS
SELECT
    ea.[PKIdEgresoAutorizado],
    ea.[FKIdEgresoProyectado_PRES],
    p.[FKIdAnio_SIS],
    anio.[Clave] AS [AnioClave],
    ea.[FKIdPrograma_PRES],
    p.[Clave] AS [ProgramaClave],
    p.[Descripcion] AS [ProgramaDescripcion],
    CONCAT(p.[Clave], ' - ', ISNULL(p.[Descripcion], '')) AS [ProgramaClaveNombre],
    ea.[FKIdPartida_CONTA],
    part.[Clave] AS [PartidaClave],
    part.[Descripcion] AS [PartidaDescripcion],
    CONCAT(part.[Clave], ' - ', ISNULL(part.[Descripcion], '')) AS [PartidaClaveNombre],
    ea.[FKIdArea_SIS],
    a.[Clave] AS [AreaClave],
    a.[Nombre] AS [AreaNombre],
    ea.[Descripcion],
    ea.[Fecha],
    ea.[FKIdPoliza_CONTA],
    ea.[FKIdFuenteFinanciamiento_PRES],
    ff.[Clave] AS [FuenteFinanciamientoClave],
    ff.[Descripcion] AS [FuenteFinanciamientoDescripcion],
    CASE WHEN ff.[PKIdFuenteFinanciamiento] IS NULL THEN NULL ELSE CONCAT(ff.[Clave], ' - ', ISNULL(ff.[Descripcion], '')) END AS [FuenteFinanciamientoClaveNombre],
    ea.[FKIdTipoGasto_PRES],
    tg.[Clave] AS [TipoGastoClave],
    tg.[Descripcion] AS [TipoGastoDescripcion],
    CASE WHEN tg.[PKIdTipoGasto] IS NULL THEN NULL ELSE CONCAT(tg.[Clave], ' - ', ISNULL(tg.[Descripcion], '')) END AS [TipoGastoClaveNombre],
    ea.[FKIdDigitoIdentificador_PRES],
    di.[Clave] AS [DigitoIdentificadorClave],
    di.[Descripcion] AS [DigitoIdentificadorDescripcion],
    CASE WHEN di.[PKIdDigitoIdentificador] IS NULL THEN NULL ELSE CONCAT(di.[Clave], ' - ', ISNULL(di.[Descripcion], '')) END AS [DigitoIdentificadorClaveNombre],
    ea.[FKIdDestinoGasto_PRES],
    dg.[Clave] AS [DestinoGastoClave],
    dg.[Descripcion] AS [DestinoGastoDescripcion],
    CASE WHEN dg.[PKIdDestinoGasto] IS NULL THEN NULL ELSE CONCAT(dg.[Clave], ' - ', ISNULL(dg.[Descripcion], '')) END AS [DestinoGastoClaveNombre],
    ea.[FKIdPY_PRES],
    py.[Clave] AS [PyClave],
    py.[Descripcion] AS [PyDescripcion],
    CASE WHEN py.[PKIdPY] IS NULL THEN NULL ELSE CONCAT(py.[Clave], ' - ', ISNULL(py.[Descripcion], '')) END AS [PyClaveNombre],
    ea.[Enero],
    ea.[Febrero],
    ea.[Marzo],
    ea.[Abril],
    ea.[Mayo],
    ea.[Junio],
    ea.[Julio],
    ea.[Agosto],
    ea.[Septiembre],
    ea.[Octubre],
    ea.[Noviembre],
    ea.[Diciembre],
    ea.[Total],
    ea.[FechaAutorizacion],
    ea.[UsuarioAutorizacion],
    ea.[Activo],
    ea.[FechaCreacion],
    ea.[UsuarioCreacion],
    ea.[FechaModificacion],
    ea.[UsuarioModificacion]
FROM [PRES].[EgresoAutorizado] ea
INNER JOIN [PRES].[Programa] p
    ON ea.[FKIdPrograma_PRES] = p.[PKIdPrograma]
   AND p.[Activo] = 1
LEFT JOIN [SIS].[Anio] anio
    ON p.[FKIdAnio_SIS] = anio.[PKIdAnio]
   AND anio.[Activo] = 1
LEFT JOIN [CONTA].[Partida] part
    ON ea.[FKIdPartida_CONTA] = part.[PKIdPartida]
   AND part.[Activo] = 1
LEFT JOIN [SIS].[Area] a
    ON ea.[FKIdArea_SIS] = a.[PKIdArea]
   AND a.[Activo] = 1
LEFT JOIN [PRES].[FuenteFinanciamiento] ff
    ON ea.[FKIdFuenteFinanciamiento_PRES] = ff.[PKIdFuenteFinanciamiento]
   AND ff.[Activo] = 1
LEFT JOIN [PRES].[TipoGasto] tg
    ON ea.[FKIdTipoGasto_PRES] = tg.[PKIdTipoGasto]
   AND tg.[Activo] = 1
LEFT JOIN [PRES].[DigitoIdentificador] di
    ON ea.[FKIdDigitoIdentificador_PRES] = di.[PKIdDigitoIdentificador]
   AND di.[Activo] = 1
LEFT JOIN [PRES].[DestinoGasto] dg
    ON ea.[FKIdDestinoGasto_PRES] = dg.[PKIdDestinoGasto]
   AND dg.[Activo] = 1
LEFT JOIN [PRES].[PY] py
    ON ea.[FKIdPY_PRES] = py.[PKIdPY]
   AND py.[Activo] = 1
WHERE ea.[Activo] = 1;
GO
PRINT N'Creando Vista [PRES].[Vw_CLCDetalle]...';


GO

CREATE   VIEW [PRES].[Vw_CLCDetalle] AS
SELECT
    cd.PKIdCLCDetalle,
    cd.FKIdEmpresa_SIS,
    emp.Nombre AS EmpresaNombre,
    cd.FKIdCLC_PRES,
    clc.NumCLC,
    cd.FKIdContratoDetalle_PRES,
    ctd.FKIdContrato_PRES,
    c.NumeroContrato,
    cd.FKIdPartida_CONTA,
    part.Clave AS PartidaClave,
    part.Descripcion AS PartidaDescripcion,
    CONCAT(part.Clave, ' - ', part.Descripcion) AS PartidaClaveNombre,
    cd.Enero, cd.Febrero, cd.Marzo, cd.Abril, cd.Mayo, cd.Junio,
    cd.Julio, cd.Agosto, cd.Septiembre, cd.Octubre, cd.Noviembre, cd.Diciembre,
    cd.Total,
    cd.Observaciones,
    cd.Activo,
    cd.FechaCreacion,
    cd.UsuarioCreacion,
    cd.FechaModificacion,
    cd.UsuarioModificacion
FROM PRES.CLCDetalle cd
INNER JOIN PRES.CLC clc ON cd.FKIdCLC_PRES = clc.PKIdCLC AND clc.Activo = 1
INNER JOIN PRES.ContratoDetalle ctd ON cd.FKIdContratoDetalle_PRES = ctd.PKIdContratoDetalle AND ctd.Activo = 1
INNER JOIN PRES.Contrato c ON ctd.FKIdContrato_PRES = c.PKIdContrato AND c.Activo = 1
LEFT JOIN SIS.Empresa emp ON cd.FKIdEmpresa_SIS = emp.PKIdEmpresa AND emp.Activo = 1
LEFT JOIN CONTA.Partida part ON cd.FKIdPartida_CONTA = part.PKIdPartida AND part.Activo = 1
WHERE cd.Activo = 1;
GO
PRINT N'Creando Vista [PRES].[Vw_Factura]...';


GO

CREATE   VIEW [PRES].[Vw_Factura] AS
SELECT
    f.PKIdFactura,
    f.FKIdEmpresa_SIS,
    emp.Nombre AS EmpresaNombre,
    f.FKIdContrato_PRES,
    c.NumeroContrato,
    c.FKIdProveedor_SIS,
    prov.Nombre AS ProveedorNombre,
    f.FKIdPoliza_CONTA,
    pol.ClavePoliza,
    f.NumFactura,
    f.SerieFactura,
    f.FechaEmision,
    f.FechaRecepcion,
    f.Subtotal,
    f.IVA,
    f.Retencion,
    f.Total,
    f.UUID,
    f.FL_Docto,
    f.Observaciones,
    f.Estatus,
    CASE f.Estatus WHEN 1 THEN 'Registrada' WHEN 2 THEN 'Validada' WHEN 3 THEN 'Devengada' WHEN 4 THEN 'Rechazada' ELSE 'Sin definir' END AS EstatusDescripcion,
    f.Activo,
    f.FechaCreacion,
    f.UsuarioCreacion,
    f.FechaModificacion,
    f.UsuarioModificacion
FROM PRES.Factura f
INNER JOIN PRES.Contrato c ON f.FKIdContrato_PRES = c.PKIdContrato AND c.Activo = 1
LEFT JOIN SIS.Empresa emp ON f.FKIdEmpresa_SIS = emp.PKIdEmpresa AND emp.Activo = 1
LEFT JOIN SIS.Proveedor prov ON c.FKIdProveedor_SIS = prov.PKIdProveedor AND prov.Activo = 1
LEFT JOIN CONTA.Poliza pol ON f.FKIdPoliza_CONTA = pol.PKIdPoliza AND pol.Activo = 1
WHERE f.Activo = 1;
GO
PRINT N'Creando Vista [PRES].[VwPrograma]...';


GO

CREATE   VIEW  [PRES].[VwPrograma]
AS
SELECT
    p.PKIdPrograma,
    p.Clave,
    p.Descripcion,
    p.Objetivo,
    CONCAT(p.Clave, ' - ', ISNULL(p.Descripcion, '')) AS ClaveNombre,

    p.FKIdUR_PRES,
    ur.Clave AS URClave,
    ur.Descripcion AS URDescripcion,
    CASE WHEN ur.PKIdUR IS NULL THEN NULL ELSE CONCAT(ur.Clave, ' - ', ur.Descripcion) END AS URClaveNombre,

    p.FKIdGF_PRES,
    gf.Clave AS GFClave,
    gf.Descripcion AS GFDescripcion,
    CASE WHEN gf.PKIdGF IS NULL THEN NULL ELSE CONCAT(gf.Clave, ' - ', gf.Descripcion) END AS GFClaveNombre,

    p.FKIdFN_PRES,
    fn.Clave AS FNClave,
    fn.Descripcion AS FNDescripcion,
    CASE WHEN fn.PKIdFN IS NULL THEN NULL ELSE CONCAT(fn.Clave, ' - ', fn.Descripcion) END AS FNClaveNombre,

    p.FKIdSF_PRES,
    sf.Clave AS SFClave,
    sf.Descripcion AS SFDescripcion,
    CASE WHEN sf.PKIdSF IS NULL THEN NULL ELSE CONCAT(sf.Clave, ' - ', sf.Descripcion) END AS SFClaveNombre,

    p.FKIdActividadInstitucional_SIS,
    ai.Clave AS ActividadInstitucionalClave,
    ai.Descripcion AS ActividadInstitucionalDescripcion,
    CASE WHEN ai.PKIdActividadInstitucional IS NULL THEN NULL ELSE CONCAT(ai.Clave, ' - ', ai.Descripcion) END AS ActividadInstitucionalClaveNombre,

    p.FKIdEje_PRES,
    eje.Clave AS EjeClave,
    eje.Descripcion AS EjeDescripcion,
    CASE WHEN eje.PKIdEje IS NULL THEN NULL ELSE CONCAT(eje.Clave, ' - ', eje.Descripcion) END AS EjeClaveNombre,

    p.FKIdSubEje_PRES,
    se.Clave AS SubEjeClave,
    se.Descripcion AS SubEjeDescripcion,
    CASE WHEN se.PKIdSubEje IS NULL THEN NULL ELSE CONCAT(se.Clave, ' - ', se.Descripcion) END AS SubEjeClaveNombre,

    p.FKIdSubSubEje_PRES,
    sse.Clave AS SubSubEjeClave,
    sse.Descripcion AS SubSubEjeDescripcion,
    CASE WHEN sse.PKIdSubSubEje IS NULL THEN NULL ELSE CONCAT(sse.Clave, ' - ', sse.Descripcion) END AS SubSubEjeClaveNombre,

    p.FKIdFinalidad_PRES,
    fin.Clave AS FinalidadClave,
    fin.Descripcion AS FinalidadDescripcion,
    CASE WHEN fin.PKIdFinalidad IS NULL THEN NULL ELSE CONCAT(fin.Clave, ' - ', fin.Descripcion) END AS FinalidadClaveNombre,

    p.FKIdVertienteGasto_PRES,
    vg.Clave AS VertienteGastoClave,
    vg.Descripcion AS VertienteGastoDescripcion,
    CASE WHEN vg.PKIdVertienteGasto IS NULL THEN NULL ELSE CONCAT(vg.Clave, ' - ', vg.Descripcion) END AS VertienteGastoClaveNombre,

    p.FKIdResultado_PRES,
    res.Clave AS ResultadoClave,
    res.Descripcion AS ResultadoDescripcion,
    CASE WHEN res.PKIdResultado IS NULL THEN NULL ELSE CONCAT(res.Clave, ' - ', res.Descripcion) END AS ResultadoClaveNombre,

    p.FKIdSubresultado_PRES,
    subres.Clave AS SubresultadoClave,
    subres.Descripcion AS SubresultadoDescripcion,
    CASE WHEN subres.PKIdSubresultado IS NULL THEN NULL ELSE CONCAT(subres.Clave, ' - ', subres.Descripcion) END AS SubresultadoClaveNombre,

    p.FKIdAnio_SIS,
    anio.Clave AS AnioClave,

    p.FKIdSector_PRES,
    sec.Clave AS SectorClave,
    sec.Descripcion AS SectorDescripcion,
    CASE WHEN sec.PKIdSector IS NULL THEN NULL ELSE CONCAT(sec.Clave, ' - ', sec.Descripcion) END AS SectorClaveNombre,

    p.FKIdSubSector_PRES,
    subsec.Clave AS SubSectorClave,
    subsec.Descripcion AS SubSectorDescripcion,
    CASE WHEN subsec.PKIdSubSector IS NULL THEN NULL ELSE CONCAT(subsec.Clave, ' - ', subsec.Descripcion) END AS SubSectorClaveNombre,

    p.FKIdTipoRecurso_PRES,
    tr.Clave AS TipoRecursoClave,
    tr.Descripcion AS TipoRecursoDescripcion,
    CASE WHEN tr.PKIdTipoRecurso IS NULL THEN NULL ELSE CONCAT(tr.Clave, ' - ', tr.Descripcion) END AS TipoRecursoClaveNombre,

    p.FKIdFuenteFinanciamiento_PRES,
    ff.Clave AS FuenteFinanciamientoClave,
    ff.Descripcion AS FuenteFinanciamientoDescripcion,
    ff.FF,
    ff.FG,
    ff.FE,
    ff.AD,
    ff.ORI,
    CASE WHEN ff.PKIdFuenteFinanciamiento IS NULL THEN NULL ELSE CONCAT(ff.Clave, ' - ', ff.Descripcion) END AS FuenteFinanciamientoClaveNombre,

    p.FKIdPP_PRES,
    pp.Clave AS PPClave,
    pp.Descripcion AS PPDescripcion,
    CASE WHEN pp.PKIdPP IS NULL THEN NULL ELSE CONCAT(pp.Clave, ' - ', pp.Descripcion) END AS PPClaveNombre,

    p.Activo,
    p.FechaCreacion,
    p.UsuarioCreacion,
    p.FechaModificacion,
    p.UsuarioModificacion
FROM PRES.Programa p
LEFT JOIN PRES.UR ur ON p.FKIdUR_PRES = ur.PKIdUR AND ur.Activo = 1
LEFT JOIN PRES.GF gf ON p.FKIdGF_PRES = gf.PKIdGF AND gf.Activo = 1
LEFT JOIN PRES.FN fn ON p.FKIdFN_PRES = fn.PKIdFN AND fn.Activo = 1
LEFT JOIN PRES.SF sf ON p.FKIdSF_PRES = sf.PKIdSF AND sf.Activo = 1
LEFT JOIN SIS.ActividadInstitucional ai ON p.FKIdActividadInstitucional_SIS = ai.PKIdActividadInstitucional AND ai.Activo = 1
LEFT JOIN PRES.Eje eje ON p.FKIdEje_PRES = eje.PKIdEje AND eje.Activo = 1
LEFT JOIN PRES.SubEje se ON p.FKIdSubEje_PRES = se.PKIdSubEje AND se.Activo = 1
LEFT JOIN PRES.SubSubEje sse ON p.FKIdSubSubEje_PRES = sse.PKIdSubSubEje AND sse.Activo = 1
LEFT JOIN PRES.Finalidad fin ON p.FKIdFinalidad_PRES = fin.PKIdFinalidad AND fin.Activo = 1
LEFT JOIN PRES.VertienteGasto vg ON p.FKIdVertienteGasto_PRES = vg.PKIdVertienteGasto AND vg.Activo = 1
LEFT JOIN PRES.Resultado res ON p.FKIdResultado_PRES = res.PKIdResultado AND res.Activo = 1
LEFT JOIN PRES.Subresultado subres ON p.FKIdSubresultado_PRES = subres.PKIdSubresultado AND subres.Activo = 1
LEFT JOIN SIS.Anio anio ON p.FKIdAnio_SIS = anio.PKIdAnio AND anio.Activo = 1
LEFT JOIN PRES.Sector sec ON p.FKIdSector_PRES = sec.PKIdSector AND sec.Activo = 1
LEFT JOIN PRES.SubSector subsec ON p.FKIdSubSector_PRES = subsec.PKIdSubSector AND subsec.Activo = 1
LEFT JOIN PRES.TipoRecurso tr ON p.FKIdTipoRecurso_PRES = tr.PKIdTipoRecurso AND tr.Activo = 1
LEFT JOIN PRES.FuenteFinanciamiento ff ON p.FKIdFuenteFinanciamiento_PRES = ff.PKIdFuenteFinanciamiento AND ff.Activo = 1
LEFT JOIN PRES.PP pp ON p.FKIdPP_PRES = pp.PKIdPP AND pp.Activo = 1
WHERE p.Activo = 1;
GO
PRINT N'Creando Vista [PRES].[Vw_SolicitudSuficiencia]...';


GO

CREATE   VIEW [PRES].[Vw_SolicitudSuficiencia] AS
SELECT
    ss.PKIdSolicitudSuficiencia,
    ss.FKIdEmpresa_SIS,
    emp.Nombre AS EmpresaNombre,
    ss.FKIdRequisicion_ORCO,
    req.Descripcion AS RequisicionDescripcion,
    req.FechaRequisicion,
    req.Importe AS RequisicionImporte,
    ss.FechaSolicitud,
    ss.Justificacion,
    ss.GastoNoProgramable,
    ss.IdGastoNoProgramable,
    ss.IdCompromisoNomina,
    ss.Estatus,
    CASE ss.Estatus
        WHEN 1 THEN 'Borrador'
        WHEN 2 THEN 'Enviada'
        WHEN 3 THEN 'Autorizada'
        WHEN 4 THEN 'Rechazada'
        ELSE 'Sin definir'
    END AS EstatusDescripcion,
    ss.Activo,
    ss.FechaCreacion,
    ss.UsuarioCreacion,
    ss.FechaModificacion,
    ss.UsuarioModificacion
FROM PRES.SolicitudSuficiencia ss
LEFT JOIN SIS.Empresa emp ON ss.FKIdEmpresa_SIS = emp.PKIdEmpresa AND emp.Activo = 1
LEFT JOIN ORCO.Requisicion req ON ss.FKIdRequisicion_ORCO = req.PKIdRequisicion AND req.Activo = 1
WHERE ss.Activo = 1;
GO
PRINT N'Creando Vista [PRES].[Vw_AutorizacionSuficienciaDetalle]...';


GO

CREATE   VIEW [PRES].[Vw_AutorizacionSuficienciaDetalle] AS
SELECT
    ausd.PKIdAutorizacionSuficienciaDetalle,
    ausd.FKIdEmpresa_SIS,
    emp.Nombre AS EmpresaNombre,
    ausd.FKIdAutorizacionSuficiencia_PRES,
    aus.FKIdSolicitudSuficiencia_PRES,
    ss.FKIdRequisicion_ORCO,
    req.Descripcion AS RequisicionDescripcion,
    aus.FechaAutorizacion,
    aus.Estatus AS AutorizacionEstatus,
    ausd.FKIdSolicitudSuficienciaDetalle_PRES,
    ssd.FKIdRequisicionDetalle_ORCO,
    rd.FKIdTipoBien_ALMA,
    tb.CodigoClave AS TipoBienClave,
    tb.Descripcion AS TipoBienDescripcion,
    rd.FKIdUnidades_ALMA,
    u.Descripcion AS UnidadMedida,
    rd.Cantidad,
    ausd.FKIdPartida_CONTA,
    part.Clave AS PartidaClave,
    part.Descripcion AS PartidaDescripcion,
    CONCAT(part.Clave, ' - ', part.Descripcion) AS PartidaClaveNombre,
    ausd.Enero,
    ausd.Febrero,
    ausd.Marzo,
    ausd.Abril,
    ausd.Mayo,
    ausd.Junio,
    ausd.Julio,
    ausd.Agosto,
    ausd.Septiembre,
    ausd.Octubre,
    ausd.Noviembre,
    ausd.Diciembre,
    ausd.Total,
    ausd.Observaciones,
    ausd.Activo,
    ausd.FechaCreacion,
    ausd.UsuarioCreacion,
    ausd.FechaModificacion,
    ausd.UsuarioModificacion
FROM PRES.AutorizacionSuficienciaDetalle ausd
INNER JOIN PRES.AutorizacionSuficiencia aus ON ausd.FKIdAutorizacionSuficiencia_PRES = aus.PKIdAutorizacionSuficiencia AND aus.Activo = 1
INNER JOIN PRES.SolicitudSuficiencia ss ON aus.FKIdSolicitudSuficiencia_PRES = ss.PKIdSolicitudSuficiencia AND ss.Activo = 1
LEFT JOIN SIS.Empresa emp ON ausd.FKIdEmpresa_SIS = emp.PKIdEmpresa AND emp.Activo = 1
LEFT JOIN ORCO.Requisicion req ON ss.FKIdRequisicion_ORCO = req.PKIdRequisicion AND req.Activo = 1
LEFT JOIN PRES.SolicitudSuficienciaDetalle ssd ON ausd.FKIdSolicitudSuficienciaDetalle_PRES = ssd.PKIdSolicitudSuficienciaDetalle AND ssd.Activo = 1
LEFT JOIN ORCO.RequisicionDetalle rd ON ssd.FKIdRequisicionDetalle_ORCO = rd.PKIdRequisicionDetalle AND rd.Activo = 1
LEFT JOIN ALMA.TipoBien tb ON rd.FKIdTipoBien_ALMA = tb.PKIdTipoBien AND tb.Activo = 1
LEFT JOIN ALMA.Unidades u ON rd.FKIdUnidades_ALMA = u.PKIdUnidades AND u.Activo = 1
LEFT JOIN CONTA.Partida part ON ausd.FKIdPartida_CONTA = part.PKIdPartida AND part.Activo = 1
WHERE ausd.Activo = 1;
GO
PRINT N'Creando Vista [PRES].[Vw_EgresoProyectado]...';


GO

CREATE   VIEW [PRES].[Vw_EgresoProyectado]
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
PRINT N'Creando Vista [PRES].[Vw_Contrato]...';


GO

CREATE   VIEW [PRES].[Vw_Contrato] AS
SELECT
    c.PKIdContrato,
    c.FKIdEmpresa_SIS,
    emp.Nombre AS EmpresaNombre,
    c.FKIdAutorizacionSuficiencia_PRES,
    aus.FKIdSolicitudSuficiencia_PRES,
    ss.FKIdRequisicion_ORCO,
    req.Descripcion AS RequisicionDescripcion,
    c.FKIdProveedor_SIS,
    prov.Clave AS ProveedorClave,
    prov.Nombre AS ProveedorNombre,
    prov.Rfc AS ProveedorRFC,
    c.FKIdPoliza_CONTA,
    pol.ClavePoliza,
    c.NumeroContrato,
    c.Descripcion,
    c.FechaContrato,
    c.FechaInicioVigencia,
    c.FechaFinVigencia,
    c.MontoTotal,
    c.PlazoEjecucion,
    c.Observaciones,
    c.Estatus,
    CASE c.Estatus WHEN 1 THEN 'Borrador' WHEN 2 THEN 'Vigente' WHEN 3 THEN 'Concluido' WHEN 4 THEN 'Cancelado' ELSE 'Sin definir' END AS EstatusDescripcion,
    c.Activo,
    c.FechaCreacion,
    c.UsuarioCreacion,
    c.FechaModificacion,
    c.UsuarioModificacion
FROM PRES.Contrato c
INNER JOIN PRES.AutorizacionSuficiencia aus ON c.FKIdAutorizacionSuficiencia_PRES = aus.PKIdAutorizacionSuficiencia AND aus.Activo = 1
LEFT JOIN PRES.SolicitudSuficiencia ss ON aus.FKIdSolicitudSuficiencia_PRES = ss.PKIdSolicitudSuficiencia AND ss.Activo = 1
LEFT JOIN ORCO.Requisicion req ON ss.FKIdRequisicion_ORCO = req.PKIdRequisicion AND req.Activo = 1
LEFT JOIN SIS.Empresa emp ON c.FKIdEmpresa_SIS = emp.PKIdEmpresa AND emp.Activo = 1
LEFT JOIN SIS.Proveedor prov ON c.FKIdProveedor_SIS = prov.PKIdProveedor AND prov.Activo = 1
LEFT JOIN CONTA.Poliza pol ON c.FKIdPoliza_CONTA = pol.PKIdPoliza AND pol.Activo = 1
WHERE c.Activo = 1;
GO
PRINT N'Creando Vista [PRES].[Vw_ContratoDetalle]...';


GO

CREATE   VIEW [PRES].[Vw_ContratoDetalle] AS
SELECT
    cd.PKIdContratoDetalle,
    cd.FKIdEmpresa_SIS,
    emp.Nombre AS EmpresaNombre,
    cd.FKIdContrato_PRES,
    c.NumeroContrato,
    c.FKIdProveedor_SIS,
    prov.Nombre AS ProveedorNombre,
    cd.FKIdAutorizacionSuficienciaDetalle_PRES,
    cd.FKIdPartida_CONTA,
    part.Clave AS PartidaClave,
    part.Descripcion AS PartidaDescripcion,
    CONCAT(part.Clave, ' - ', part.Descripcion) AS PartidaClaveNombre,
    cd.Enero, cd.Febrero, cd.Marzo, cd.Abril, cd.Mayo, cd.Junio,
    cd.Julio, cd.Agosto, cd.Septiembre, cd.Octubre, cd.Noviembre, cd.Diciembre,
    cd.Total,
    cd.Observaciones,
    cd.Activo,
    cd.FechaCreacion,
    cd.UsuarioCreacion,
    cd.FechaModificacion,
    cd.UsuarioModificacion
FROM PRES.ContratoDetalle cd
INNER JOIN PRES.Contrato c ON cd.FKIdContrato_PRES = c.PKIdContrato AND c.Activo = 1
LEFT JOIN SIS.Empresa emp ON cd.FKIdEmpresa_SIS = emp.PKIdEmpresa AND emp.Activo = 1
LEFT JOIN SIS.Proveedor prov ON c.FKIdProveedor_SIS = prov.PKIdProveedor AND prov.Activo = 1
LEFT JOIN CONTA.Partida part ON cd.FKIdPartida_CONTA = part.PKIdPartida AND part.Activo = 1
WHERE cd.Activo = 1;
GO
PRINT N'Creando Vista [PRES].[Vw_ChequePartidas]...';


GO

CREATE   VIEW [PRES].[Vw_ChequePartidas] AS
SELECT
    cp.PKIdChequePartida,
    cp.FKIdEmpresa_SIS,
    emp.Nombre AS EmpresaNombre,
    cp.FKIdCheque_PRES,
    ch.NumeroCheque,
    cp.FKIdCLCDetalle_PRES,
    clcd.FKIdCLC_PRES,
    clc.NumCLC,
    cp.FKIdPartida_CONTA,
    part.Clave AS PartidaClave,
    part.Descripcion AS PartidaDescripcion,
    CONCAT(part.Clave, ' - ', part.Descripcion) AS PartidaClaveNombre,
    cp.MontoPagado,
    cp.Observaciones,
    cp.Activo,
    cp.FechaCreacion,
    cp.UsuarioCreacion,
    cp.FechaModificacion,
    cp.UsuarioModificacion
FROM PRES.ChequePartidas cp
INNER JOIN PRES.Cheque ch ON cp.FKIdCheque_PRES = ch.PKIdCheque AND ch.Activo = 1
INNER JOIN PRES.CLCDetalle clcd ON cp.FKIdCLCDetalle_PRES = clcd.PKIdCLCDetalle AND clcd.Activo = 1
INNER JOIN PRES.CLC clc ON clcd.FKIdCLC_PRES = clc.PKIdCLC AND clc.Activo = 1
LEFT JOIN SIS.Empresa emp ON cp.FKIdEmpresa_SIS = emp.PKIdEmpresa AND emp.Activo = 1
LEFT JOIN CONTA.Partida part ON cp.FKIdPartida_CONTA = part.PKIdPartida AND part.Activo = 1
WHERE cp.Activo = 1;
GO
PRINT N'Creando Vista [PRES].[Vw_AutorizacionSuficiencia]...';


GO

CREATE   VIEW [PRES].[Vw_AutorizacionSuficiencia] AS
SELECT
    aus.PKIdAutorizacionSuficiencia,
    aus.FKIdEmpresa_SIS,
    emp.Nombre AS EmpresaNombre,
    aus.FKIdSolicitudSuficiencia_PRES,
    ss.FKIdRequisicion_ORCO,
    req.Descripcion AS RequisicionDescripcion,
    ss.FechaSolicitud,
    aus.FechaAutorizacion,
    aus.Justificacion,
    aus.GastoNoProgramable,
    aus.IdGastoNoProgramable,
    aus.IdCompromisoNomina,
    aus.AutorizadoPor_NOM,
    CONCAT(per.Nombre, ' ', per.Paterno, ' ', ISNULL(per.Materno, '')) AS AutorizadoPorNombre,
    aus.Observaciones,
    aus.Estatus,
    CASE aus.Estatus
        WHEN 1 THEN 'Borrador'
        WHEN 2 THEN 'Autorizada'
        WHEN 3 THEN 'Rechazada'
        ELSE 'Sin definir'
    END AS EstatusDescripcion,
    aus.Activo,
    aus.FechaCreacion,
    aus.UsuarioCreacion,
    aus.FechaModificacion,
    aus.UsuarioModificacion
FROM PRES.AutorizacionSuficiencia aus
INNER JOIN PRES.SolicitudSuficiencia ss ON aus.FKIdSolicitudSuficiencia_PRES = ss.PKIdSolicitudSuficiencia AND ss.Activo = 1
LEFT JOIN SIS.Empresa emp ON aus.FKIdEmpresa_SIS = emp.PKIdEmpresa AND emp.Activo = 1
LEFT JOIN ORCO.Requisicion req ON ss.FKIdRequisicion_ORCO = req.PKIdRequisicion AND req.Activo = 1
LEFT JOIN NOM.Persona per ON aus.AutorizadoPor_NOM = per.PKIdPersona AND per.Activo = 1
WHERE aus.Activo = 1;
GO
PRINT N'Creando Vista [PRES].[Vw_CLCFactura]...';


GO

CREATE   VIEW [PRES].[Vw_CLCFactura] AS
SELECT
    cf.PKIdCLCFactura,
    cf.FKIdEmpresa_SIS,
    emp.Nombre AS EmpresaNombre,
    cf.FKIdCLC_PRES,
    clc.NumCLC,
    cf.FKIdFactura_PRES,
    f.NumFactura,
    cf.FKIdFacturaDetalle_PRES,
    fd.FKIdPartida_CONTA,
    part.Clave AS PartidaClave,
    part.Descripcion AS PartidaDescripcion,
    cf.MontoAplicado,
    cf.Observaciones,
    cf.Activo,
    cf.FechaCreacion,
    cf.UsuarioCreacion,
    cf.FechaModificacion,
    cf.UsuarioModificacion
FROM PRES.CLCFactura cf
INNER JOIN PRES.CLC clc ON cf.FKIdCLC_PRES = clc.PKIdCLC AND clc.Activo = 1
INNER JOIN PRES.Factura f ON cf.FKIdFactura_PRES = f.PKIdFactura AND f.Activo = 1
INNER JOIN PRES.FacturaDetalle fd ON cf.FKIdFacturaDetalle_PRES = fd.PKIdFacturaDetalle AND fd.Activo = 1
LEFT JOIN SIS.Empresa emp ON cf.FKIdEmpresa_SIS = emp.PKIdEmpresa AND emp.Activo = 1
LEFT JOIN CONTA.Partida part ON fd.FKIdPartida_CONTA = part.PKIdPartida AND part.Activo = 1
WHERE cf.Activo = 1;
GO
PRINT N'Creando Vista [SIS].[VW_EstadoEmpresa]...';


GO

CREATE   VIEW  [SIS].[VW_EstadoEmpresa]
AS
SELECT 
    -- Campos de Empresa
    EM.PKIdEmpresa,
    EM.Nombre AS EmpresaNombre,
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

    -- Campos de Estado
    E.PKIdEstado,
    E.FKIdPais_SIS,
    E.Nombre AS EstadoNombre,
    E.CodigoEstado,
    E.Activo AS EstadoActivo,

    -- Campos de la relaci�n (EmpresaEstado)
    EE.FechaApertura,
    EE.EsOficinaPrincipal,
    EE.Activo AS RelacionActiva

FROM SIS.Empresa EM
INNER JOIN SIS.EmpresaEstado EE ON EM.PKIdEmpresa = EE.FKIdEmpresa_SIS
INNER JOIN SIS.Estados E ON EE.FKIdEstado_SIS = E.PKIdEstado
WHERE EM.Activo = 1
  AND E.Activo = 1
GO
PRINT N'Creando Vista [SIS].[Vw_Proveedor]...';


GO

CREATE   VIEW  [SIS].[Vw_Proveedor] AS
SELECT 
    prov.PKIdProveedor,
    prov.FkIdTipoProveedor_SIS,
    prov.FKIdEstatusProveedor_SIS,
    prov.FKIdCuentaContable_SIS,
    prov.FKIdMunicipio_SIS,
    prov.FKIdEstado_SIS,
    prov.FKIdPais_SIS,
    prov.Nombre,
    prov.RFC,
    prov.Clave,
    prov.Activo,
    prov.FechaCreacion,
    prov.UsuarioCreacion,
    prov.FechaModificacion,
    prov.UsuarioModificacion,
    tp.Descripcion AS TipoProveedorDesc,
    ep.Descripcion AS EstatusProveedorDesc,
    cc.Cta_Coi AS CuentaContableClave,
    m.Nombre AS MunicipioNombre,
    e.Nombre AS EstadoNombre,
    pa.Nombre AS PaisNombre
FROM SIS.Proveedor prov
LEFT JOIN SIS.TipoProveedor tp ON prov.FkIdTipoProveedor_SIS = tp.PkIdTipoProveedor AND tp.Activo = 1
LEFT JOIN SIS.EstatusProveedor ep ON prov.FKIdEstatusProveedor_SIS = ep.PKIdEstatusProveedor AND ep.Activo = 1
LEFT JOIN CONTA.CuentaContable cc ON prov.FKIdCuentaContable_SIS = cc.PKIdCuentaContable AND cc.Activo = 1
LEFT JOIN SIS.Municipios m ON prov.FKIdMunicipio_SIS = m.PKIdMunicipio AND m.Activo = 1
LEFT JOIN SIS.Estados e ON prov.FKIdEstado_SIS = e.PKIdEstado AND e.Activo = 1
LEFT JOIN SIS.Paises pa ON prov.FKIdPais_SIS = pa.PKIdPais AND pa.Activo = 1
WHERE prov.Activo = 1;
GO
PRINT N'Creando Vista [SIS].[VW_UsuarioPersonaArea]...';


GO

CREATE   VIEW  [SIS].[VW_UsuarioPersonaArea]
AS
SELECT 
    u.PkIdUsuario,
    u.AspNetUserId,
    p.Nombre AS UsuarioNombre,
    p.Paterno AS ApellidoPaterno,
    p.Materno AS ApellidoMaterno,
    p.CORREO_ELECTRONICO AS Email,
    u.Activo AS UsuarioActivo,
    u.FechaCreacion AS UsuarioFechaCreacion,
    -- Datos de Persona
    p.PKIdPersona,
    p.Clave AS PersonaClave,
    p.Nombre AS PersonaNombre,
    p.Paterno AS PersonaPaterno,
    p.Materno AS PersonaMaterno,
    p.RFC,
    p.Curp,
    p.CORREO_ELECTRONICO,
    p.Activo AS PersonaActivo,
    -- Datos de �rea (a trav�s de PersonaArea)
    pa.PKIdPersonaArea,
    pa.IsAdscrito,
    pa.EsSolicitante,
    pa.EsAutorizador,
    a.PKIdArea,
    a.Clave AS AreaClave,
    a.Nombre AS AreaNombre,
    a.Activo AS AreaActivo,
    a.FKIdArea_SIS AS AreaPadreId,
    -- Campo combinado �til para frontend
    CONCAT(p.Nombre, ' ', p.Paterno, ' (', ISNULL(a.Nombre, 'Sin area'), ')') AS UsuarioAreaDescripcion
FROM SIS.Usuario u
LEFT JOIN NOM.Persona p ON u.FKIdPersona_NOM = p.PKIdPersona AND p.Activo = 1
LEFT JOIN NOM.PersonaArea pa ON p.PKIdPersona = pa.FKIdPersona_NOM AND pa.Activo = 1
LEFT JOIN SIS.Area a ON pa.FKIdArea_SIS = a.PKIdArea AND a.Activo = 1
WHERE u.Activo = 1;
GO
PRINT N'Creando Vista [SIS].[VW_UsuarioEmpresa]...';


GO

CREATE   VIEW  [SIS].[VW_UsuarioEmpresa]
AS
WITH SucursalesResumen AS (
    -- Acceso directo por UsuarioSucursal
    SELECT 
        us.FKIdUsuario_SIS AS IdUsuario,
        STRING_AGG(s.Nombre, ', ') WITHIN GROUP (ORDER BY s.Nombre) AS SucursalesDirectas,
        COUNT(DISTINCT s.PKIdSucursal) AS TotalSucursalesDirectas,
        SUM(CASE WHEN us.EsGerente = 1 THEN 1 ELSE 0 END) AS TotalGerente,
        SUM(CASE WHEN us.EsSupervisor = 1 THEN 1 ELSE 0 END) AS TotalSupervisor,
        MAX(CASE WHEN s.EsMatriz = 1 THEN s.Nombre ELSE NULL END) AS SucursalMatriz
    FROM SIS.UsuarioSucursal us
    INNER JOIN SIS.Sucursal s ON us.FKIdSucursal_SIS = s.PKIdSucursal
    WHERE us.Activo = 1 AND s.Activo = 1 AND us.PuedeAcceder = 1
    GROUP BY us.FKIdUsuario_SIS
    
    UNION ALL
    
    -- Acceso por Departamento
    SELECT 
        ud.FKIdUsuario_SIS AS IdUsuario,
        STRING_AGG(s.Nombre, ', ') WITHIN GROUP (ORDER BY s.Nombre) AS SucursalesDirectas,
        COUNT(DISTINCT s.PKIdSucursal) AS TotalSucursalesDirectas,
        0 AS TotalGerente,
        0 AS TotalSupervisor,
        MAX(CASE WHEN s.EsMatriz = 1 THEN s.Nombre ELSE NULL END) AS SucursalMatriz
    FROM SIS.UsuarioDepartamento ud
    INNER JOIN SIS.Departamento d ON ud.FKIdDepartamento_SIS = d.PKIdDepartamento
    INNER JOIN SIS.Sucursal s ON d.FKIdSucursal_SIS = s.PKIdSucursal
    WHERE ud.Activo = 1 AND d.Activo = 1 AND s.Activo = 1
    GROUP BY ud.FKIdUsuario_SIS
),
SucursalesConsolidadas AS (
    SELECT 
        IdUsuario,
        STRING_AGG(SucursalesDirectas, ', ') AS ListaSucursales,
        SUM(TotalSucursalesDirectas) AS TotalSucursales,
        MAX(TotalGerente) AS EsGerente,
        MAX(TotalSupervisor) AS EsSupervisor,
        MAX(SucursalMatriz) AS SucursalMatrizAsignada
    FROM SucursalesResumen
    GROUP BY IdUsuario
)
SELECT 
    -- Datos del Usuario
    u.PkIdUsuario,
    u.AspNetUserId,
    u.FKIdEmpresa_SIS AS IdEmpresa,
    CONCAT(p.Nombre, ' ', p.Paterno, ' ', ISNULL(p.Materno, '')) AS NombreCompleto,
    p.Nombre,
    p.Paterno AS ApellidoPaterno,
    p.Materno AS ApellidoMaterno,
    p.Iniciales,
    u.PayrollID,
    p.CP AS CodigoPostal,
    p.Telefono_particular AS Telefono,
    p.Calle AS Direccion1,
    p.Colonia AS Direccion2,
    p.CORREO_ELECTRONICO AS Email,
    p.NoCredencialElector AS NumeroSocial,
    p.Gafete,
    p.Sexo AS SexoDescripcion,
    p.Sexo,
    p.Fecha_de_Inicio AS FechaIngreso,
    FORMAT(p.Fecha_de_Inicio, 'dd/MM/yyyy') AS FechaIngresoFormat,
    DATEDIFF(YEAR, p.Fecha_de_Inicio, GETDATE()) AS AntiguedadAnios,
    u.FKIdIdiomaPreferido_SIS AS IdIdiomaPreferido,
    i.Nombre AS IdiomaPreferido,
    u.FKIdMonedaPreferida_SIS AS IdMonedaPreferida,
    m.Nombre AS MonedaPreferida,
    m.Simbolo AS SimboloMoneda,
    u.EsAdministrador,
    u.Activo AS UsuarioActivo,
    u.FechaCreacion AS UsuarioFechaCreacion,
    FORMAT(u.FechaCreacion, 'dd/MM/yyyy HH:mm') AS UsuarioFechaCreacionFormat,
    u.UsuarioCreacion,
    u.FechaModificacion AS UsuarioFechaModificacion,
    u.UsuarioModificacion,
    
    -- Datos de Persona (NOM)
    p.PKIdPersona AS IdPersona,
    p.Clave AS ClavePersona,
    p.Nombre AS PersonaNombre,
    p.Paterno AS PersonaPaterno,
    p.Materno AS PersonaMaterno,
    CONCAT(p.Nombre, ' ', p.Paterno, ' ', ISNULL(p.Materno, '')) AS NombreCompletoPersona,
    p.RFC,
    p.Curp,
    p.CORREO_ELECTRONICO AS EmailPersona,
    p.Telefono_particular AS TelefonoParticular,
    p.Telefono_movil AS TelefonoMovil,
    p.Fecha_de_Inicio AS FechaInicioPersona,
    p.Fecha_Fin AS FechaFinPersona,
    FORMAT(p.FechaNacimiento, 'dd/MM/yyyy') AS FechaNacimientoFormat,
    p.Sexo AS SexoPersona,
    p.ESTADO_CIVIL AS EstadoCivil,
    p.Municipio,
    p.REG_IMSS,
    p.NoCartilla,
    p.NoLicencia,
    p.NoPasaporte,
    p.NoCredencialElector,
    p.Calle,
    p.Num_exterior,
    p.Num_interior,
    p.Colonia,
    p.CP AS CodigoPostalPersona,
    p.Estado,
    p.TIPO_CONTRATACION,
    p.PUESTO,
    p.SUELDO_BASE,
    p.COMPENSACION_GARANTIZADA,
    p.BANCO,
    p.NUMERO_CUENTA,
    p.CLABE,
    p.Activo AS PersonaActivo,
    
    -- Datos de Empresa
    e.PKIdEmpresa,
    e.Nombre AS NombreEmpresa,
    e.RFC AS RfcEmpresa,
    e.RazonSocial AS RazonSocialEmpresa,
    e.Giro AS GiroEmpresa,
    e.FKIdMonedaBase_SIS AS IdMonedaBaseEmpresa,
    mb.Nombre AS MonedaBaseEmpresa,
    mb.Simbolo AS SimboloMonedaBase,
    e.Activo AS EmpresaActiva,
    e.FechaCreacion AS EmpresaFechaCreacion,
    
    -- Resumen de Departamentos
    (
        SELECT STRING_AGG(d.Nombre, ', ') 
        FROM SIS.UsuarioDepartamento ud2
        INNER JOIN SIS.Departamento d ON ud2.FKIdDepartamento_SIS = d.PKIdDepartamento
        WHERE ud2.FKIdUsuario_SIS = u.PkIdUsuario AND ud2.Activo = 1 AND d.Activo = 1
    ) AS ListaDepartamentos,
    
    (
        SELECT COUNT(DISTINCT d2.PKIdDepartamento)
        FROM SIS.UsuarioDepartamento ud2
        INNER JOIN SIS.Departamento d2 ON ud2.FKIdDepartamento_SIS = d2.PKIdDepartamento
        WHERE ud2.FKIdUsuario_SIS = u.PkIdUsuario AND ud2.Activo = 1 AND d2.Activo = 1
    ) AS TotalDepartamentos,
    
    -- Indicadores de jefatura
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM SIS.UsuarioDepartamento ud3
            WHERE ud3.FKIdUsuario_SIS = u.PkIdUsuario AND ud3.EsJefe = 1 AND ud3.Activo = 1
        ) THEN 1 ELSE 0 
    END AS EsJefeAlgunDepartamento,
    
    (
        SELECT STRING_AGG(d4.Nombre, ', ')
        FROM SIS.UsuarioDepartamento ud4
        INNER JOIN SIS.Departamento d4 ON ud4.FKIdDepartamento_SIS = d4.PKIdDepartamento
        WHERE ud4.FKIdUsuario_SIS = u.PkIdUsuario AND ud4.EsJefe = 1 AND ud4.Activo = 1
    ) AS DepartamentosComoJefe,
    
    -- Resumen de Sucursales (consolidado)
    sc.ListaSucursales,
    ISNULL(sc.TotalSucursales, 0) AS TotalSucursales,
    sc.SucursalMatrizAsignada,
    
    -- Indicadores de rol
    CASE 
        WHEN u.EsAdministrador = 1 THEN 'Administrador Global'
        WHEN sc.EsGerente = 1 THEN 'Gerente de Sucursal'
        WHEN sc.EsSupervisor = 1 THEN 'Supervisor'
        WHEN EXISTS (
            SELECT 1 FROM SIS.UsuarioDepartamento ud5
            WHERE ud5.FKIdUsuario_SIS = u.PkIdUsuario AND ud5.EsJefe = 1 AND ud5.Activo = 1
        ) THEN 'Jefe de Departamento'
        ELSE 'Empleado'
    END AS RolPrincipal,
    
    -- Metadatos adicionales
    CASE 
        WHEN sc.TotalSucursales > 5 THEN 'Multi-sucursal'
        WHEN sc.TotalSucursales > 1 THEN 'Varias sucursales'
        WHEN sc.TotalSucursales = 1 THEN 'Una sucursal'
        ELSE 'Sin sucursal'
    END AS CoberturaSucursales,
    
    NULL AS UltimoAcceso,
    
    u.PayrollID AS NumeroEmpleado,
    ISNULL(UPPER(CONCAT(LEFT(p.Nombre, 1), LEFT(p.Paterno, 1))), '') AS InicialesNombre

FROM SIS.Usuario u

-- Relaci�n con Empresa
INNER JOIN SIS.Empresa e ON u.FKIdEmpresa_SIS = e.PKIdEmpresa

-- Moneda base de la empresa
LEFT JOIN SIS.Moneda mb ON e.FKIdMonedaBase_SIS = mb.PKIdMoneda

-- Preferencias de idioma y moneda
LEFT JOIN SIS.Idioma i ON u.FKIdIdiomaPreferido_SIS = i.PKIdIdioma
LEFT JOIN SIS.Moneda m ON u.FKIdMonedaPreferida_SIS = m.PKIdMoneda

-- Datos de Persona
LEFT JOIN NOM.Persona p ON u.FKIdPersona_NOM = p.PKIdPersona AND p.Activo = 1

-- Sucursales consolidadas
LEFT JOIN SucursalesConsolidadas sc ON u.PkIdUsuario = sc.IdUsuario

WHERE u.Activo = 1;
GO
PRINT N'Creando Vista [SIS].[Vw_UsuarioSucursal]...';


GO

CREATE   VIEW  [SIS].[Vw_UsuarioSucursal]
AS
SELECT 
    -- Datos del Usuario
    u.PkIdUsuario,
    u.AspNetUserId,
    u.FKIdEmpresa_SIS AS IdEmpresa,
    p.Nombre,
    p.Paterno AS ApellidoPaterno,
    p.Materno AS ApellidoMaterno,
    CONCAT(p.Nombre, ' ', p.Paterno, ' ', ISNULL(p.Materno, '')) AS NombreCompleto,
    p.Iniciales,
    ISNULL(UPPER(CONCAT(LEFT(p.Nombre, 1), LEFT(p.Paterno, 1))), '') AS InicialesNombre,
    u.PayrollID AS PayrollId,
    p.CP AS CodigoPostal,
    p.Telefono_particular AS Telefono,
    p.Calle AS Direccion1,
    p.Colonia AS Direccion2,
    p.CORREO_ELECTRONICO AS Email,
    p.NoCredencialElector AS NumeroSocial,
    p.Gafete,
    p.Sexo,
    p.Sexo AS SexoDescripcion,
    p.Fecha_de_Inicio AS FechaIngreso,
    FORMAT(p.Fecha_de_Inicio, 'dd/MM/yyyy') AS FechaIngresoFormat,
    DATEDIFF(YEAR, p.Fecha_de_Inicio, GETDATE()) AS AntiguedadAnios,
    
    -- Idioma preferido
    u.FKIdIdiomaPreferido_SIS AS IdIdiomaPreferido,
    i.Nombre AS IdiomaPreferido,
    
    -- Moneda preferida
    u.FKIdMonedaPreferida_SIS AS IdMonedaPreferida,
    m.Nombre AS MonedaPreferida,
    m.Simbolo AS SimboloMoneda,
    
    -- Datos de usuario
    u.EsAdministrador,
    u.Activo AS UsuarioActivo,
    
    -- Datos de la Empresa
    e.PKIdEmpresa AS PkidEmpresa,
    e.Nombre AS NombreEmpresa,
    e.RFC AS RfcEmpresa,
    e.RazonSocial AS RazonSocialEmpresa,
    e.Giro AS GiroEmpresa,
    e.FKIdMonedaBase_SIS AS IdMonedaBaseEmpresa,
    mb.Nombre AS MonedaBaseEmpresa,
    mb.Simbolo AS SimboloMonedaBase,
    e.FechaCreacion AS EmpresaFechaCreacion,
    
    -- Datos de la Sucursal asignada
    s.PKIdSucursal AS IdSucursal,
    s.Nombre AS NombreSucursal,
    s.CodigoSucursal,
    s.Direccion AS DireccionSucursal,
    s.EsMatriz,
    
    -- Permisos espec�ficos de la asignaci�n
    us.PuedeAcceder,
    us.PuedeConfigurar,
    us.PuedeOperar,
    us.PuedeReportes,
    us.EsGerente,
    us.EsSupervisor,
    us.Activo AS AsignacionActiva,
    
    -- Indicador de si es jefe en alg�n departamento de esta sucursal
    CASE 
        WHEN EXISTS (
            SELECT 1
            FROM SIS.UsuarioDepartamento ud
            INNER JOIN SIS.Departamento d ON ud.FKIdDepartamento_SIS = d.PKIdDepartamento
            WHERE ud.FKIdUsuario_SIS = u.PkIdUsuario
            AND d.FKIdSucursal_SIS = s.PKIdSucursal
            AND ud.EsJefe = 1
            AND ud.Activo = 1
            AND (ud.FechaFinAsignacion IS NULL OR ud.FechaFinAsignacion >= GETDATE())
        ) THEN 1 ELSE 0 
    END AS EsJefeEnSucursal,
    u.FechaCreacion,u.UsuarioCreacion,u.FechaModificacion,u.UsuarioModificacion,
    -- Datos de Persona (NOM)
    p.PKIdPersona AS IdPersona,
    p.Clave AS ClavePersona,
    p.Nombre AS PersonaNombre,
    p.Paterno AS PersonaPaterno,
    p.Materno AS PersonaMaterno,
    CONCAT(p.Nombre, ' ', p.Paterno, ' ', ISNULL(p.Materno, '')) AS NombreCompletoPersona,
    p.RFC,
    p.Curp,
    p.CORREO_ELECTRONICO AS EmailPersona,
    p.Telefono_particular AS TelefonoParticular,
    p.Telefono_movil AS TelefonoMovil,
    u.FKIdEmpresa_SIS AS IdEmpresaPersona
FROM SIS.Usuario u
INNER JOIN SIS.Empresa e ON u.FKIdEmpresa_SIS = e.PKIdEmpresa
LEFT JOIN SIS.Idioma i ON u.FKIdIdiomaPreferido_SIS = i.PKIdIdioma
LEFT JOIN SIS.Moneda m ON u.FKIdMonedaPreferida_SIS = m.PKIdMoneda
LEFT JOIN SIS.Moneda mb ON e.FKIdMonedaBase_SIS = mb.PKIdMoneda
INNER JOIN SIS.UsuarioSucursal us ON u.PkIdUsuario = us.FKIdUsuario_SIS
INNER JOIN SIS.Sucursal s ON us.FKIdSucursal_SIS = s.PKIdSucursal
-- Datos de Persona
LEFT JOIN NOM.Persona p ON u.FKIdPersona_NOM = p.PKIdPersona AND p.Activo = 1
WHERE us.Activo = 1 
  AND (us.FechaFinAsignacion IS NULL OR us.FechaFinAsignacion >= GETDATE())
  AND u.Activo = 1;
GO
PRINT N'Creando Vista [SIS].[vw_Menu]...';


GO

CREATE   VIEW  [SIS].[vw_Menu] AS
WITH MenuJerarquico AS (
    SELECT 
        m.PKIdMenu,
        m.Nombre,
        m.Tipo,
        -- Descripci�n del tipo
        CASE m.Tipo
            WHEN 1 THEN 'Contenedor (tiene submen�s)'
            WHEN 2 THEN 'Item final'
            ELSE 'Desconocido'
        END AS TipoDescripcion,
        m.FKIdMenu_SIS,
        -- Nombre del men� padre
        p.Nombre AS NombreMenuPadre,
        -- Tipo del men� padre
        p.Tipo AS TipoMenuPadre,
        CASE p.Tipo
            WHEN 1 THEN 'Contenedor'
            WHEN 2 THEN 'Item final'
            ELSE 'Desconocido'
        END AS TipoMenuPadreDescripcion,
        m.LegacyName,
        m.Ruta,
        m.ImageUrl,
        m.Lenguaje,
        m.Orden,
        m.Activo,
        -- Estado del men�
        CASE m.Activo
            WHEN 1 THEN 'Activo'
            ELSE 'Inactivo'
        END AS Estado,
        m.CreatedByOperatorId,
        m.CreatedDateTime,
        m.ModifiedByOperatorId,
        m.ModifiedDateTime,
        -- Nivel jer�rquico
        CASE 
            WHEN m.FKIdMenu_SIS IS NULL THEN 0
            ELSE 1
        END AS NivelJerarquico,
        -- Ruta completa del men� (para breadcrumbs)
        CASE 
            WHEN m.FKIdMenu_SIS IS NOT NULL AND p.Nombre IS NOT NULL 
                THEN p.Nombre + ' > ' + m.Nombre
            ELSE m.Nombre
        END AS RutaCompleta,
        -- Indicador si tiene submen�s (solo aplica para Tipo=1)
        CASE 
            WHEN m.Tipo = 1 AND EXISTS (SELECT 1 FROM SIS.Menu h WHERE h.FKIdMenu_SIS = m.PKIdMenu) 
            THEN 1 
            ELSE 0 
        END AS TieneSubmenus,
        -- Validaci�n de consistencia
        CASE 
            WHEN m.Tipo = 2 AND EXISTS (SELECT 1 FROM SIS.Menu h WHERE h.FKIdMenu_SIS = m.PKIdMenu) 
            THEN 'INCONSISTENCIA: Item final tiene submen�s'
            WHEN m.Tipo = 1 AND m.Ruta IS NOT NULL AND EXISTS (SELECT 1 FROM SIS.Menu h WHERE h.FKIdMenu_SIS = m.PKIdMenu) 
            THEN 'INCONSISTENCIA: Contenedor con ruta y submen�s'
            ELSE 'OK'
        END AS ValidacionEstructura
       
    FROM SIS.Menu m
    LEFT JOIN SIS.Menu p ON m.FKIdMenu_SIS = p.PKIdMenu
)
SELECT 
    PKIdMenu,
    Nombre,
    Tipo,
    TipoDescripcion,
    FKIdMenu_SIS,
    NombreMenuPadre,
    TipoMenuPadre,
    TipoMenuPadreDescripcion,
    LegacyName,
    Ruta,
    ImageUrl,
    Lenguaje,
    Orden,
    Activo,
    Estado,
    CreatedByOperatorId,
    CreatedDateTime,
    ModifiedByOperatorId,
    ModifiedDateTime,
    NivelJerarquico,
    RutaCompleta,
    TieneSubmenus,
    ValidacionEstructura
    
FROM MenuJerarquico m;
GO
PRINT N'Creando Vista [SIS].[Vw_Concepto]...';


GO

CREATE   VIEW  [SIS].[Vw_Concepto] AS
SELECT 
    c.PKIdConcepto,
    c.FKIdCapitulo_SIS,
    c.Clave,
    c.Descripcion,
    c.Activo,
    c.FechaCreacion,
    c.UsuarioCreacion,
    c.FechaModificacion,
    c.UsuarioModificacion,
    cap.Descripcion AS CapituloDescripcion,
    cap.Clave AS CapituloClave
FROM SIS.Concepto c
LEFT JOIN SIS.Capitulo cap ON c.FKIdCapitulo_SIS = cap.PKIdCapitulo AND cap.Activo = 1
WHERE c.Activo = 1;
GO
PRINT N'Creando Vista [SIS].[VW_EmpresaDepartamanto]...';


GO

CREATE   VIEW  [SIS].[VW_EmpresaDepartamanto]
AS
SELECT E.PKIdEmpresa,
	   E.Nombre AS EmpresaNombre,
	   E.RFC,
	   D.PKIdDepartamento,
	   D.Nombre AS DepartamentoNombre,
	   D.Activo AS DepartamentoActivo,
	   E.Activo AS EmpresaActivo,
      E.FechaCreacion,E.UsuarioCreacion,E.FechaModificacion,E.UsuarioModificacion
FROM [SIS].[Empresa] E WITH (NOLOCK)
INNER JOIN [SIS].[Departamento] D WITH (NOLOCK) ON E.PKIdEmpresa = D.FKIdEmpresa_SIS
WHERE E.Activo = 1 AND D.Activo = 1 ;
GO
PRINT N'Creando Vista [SIS].[VW_SucursalEmpresaEstado]...';


GO

CREATE   VIEW  [SIS].[VW_SucursalEmpresaEstado]
AS
SELECT 
    s.PKIdSucursal,
    s.FKIdEmpresa_SIS,
    s.FKIdEstado_SIS,
    s.Nombre,
    s.CodigoSucursal,
    s.Alias,
    s.FKIdTipoSucursal,
    s.FKIdMonedaLocal_SIS,
    s.Direccion,
    s.Colonia,
    s.Ciudad,
    s.CodigoPostal,
    s.TelefonoPrincipal,
    s.TelefonoSecundario,
    s.Email,
    s.HorarioApertura,
    s.HorarioCierre,
    s.EsMatriz,
    s.EsActiva,
    s.Latitud,
    s.Longitud,
    -- Informaci�n adicional de la empresa
    e.Nombre AS NombreEmpresa,
    e.RFC,
    -- Informaci�n del estado
    est.Nombre AS NombreEstado,
    est.CodigoEstado,
    p.Nombre AS NombrePais,
    E.Activo,
    E.FechaCreacion,E.UsuarioCreacion,E.FechaModificacion,E.UsuarioModificacion
FROM [SIS].Sucursal s WITH (NOLOCK)
INNER JOIN [SIS].Empresa e WITH (NOLOCK) 
    ON s.FKIdEmpresa_SIS = e.PKIdEmpresa 
    AND e.Activo = 1
INNER JOIN [SIS].Estados est WITH (NOLOCK) 
    ON s.FKIdEstado_SIS = est.PKIdEstado 
    AND est.Activo = 1
INNER JOIN [SIS].Paises p WITH (NOLOCK) 
    ON est.FKIdPais_SIS = p.PKIdPais 
    AND p.Activo = 1
WHERE s.Activo = 1;
GO
PRINT N'Creando Vista [SIS].[Vw_Area]...';


GO

CREATE   VIEW  [SIS].[Vw_Area] AS
SELECT 
    a.PKIdArea,
    a.FKIdArea_SIS,
    a.Clave,
    a.Nombre,
    a.UltimoInv,
    a.Activo,
    a.FechaCreacion,
    a.UsuarioCreacion,
    a.FechaModificacion,
    a.UsuarioModificacion,
    a_padre.Nombre AS AreaPadreNombre,
    a_padre.Clave AS AreaPadreClave
FROM SIS.Area a
LEFT JOIN SIS.Area a_padre ON a.FKIdArea_SIS = a_padre.PKIdArea AND a_padre.Activo = 1
WHERE a.Activo = 1;
GO
PRINT N'Creando Vista [TES].[Vw_TipoCambio]...';


GO

CREATE   VIEW  [TES].[Vw_TipoCambio] AS
SELECT 
    tc.PKIdTipoCambio,
    tc.FKIdTipoMoneda_TES,
    tc.Cantidad,
    tc.Fecha,
    tc.Activo,
    tc.FechaCreacion,
    tc.UsuarioCreacion,
    tc.FechaModificacion,
    tc.UsuarioModificacion,
    tm.Descripcion AS MonedaDescripcion,
    tm.CodigoISO4217 AS MonedaCodigo
FROM TES.TipoCambio tc
LEFT JOIN TES.TipoMoneda tm ON tc.FKIdTipoMoneda_TES = tm.PKIdTipoMoneda AND tm.Activo = 1
WHERE tc.Activo = 1;
GO
PRINT N'Creando Vista [PRES].[Vw_Programa]...';


GO

CREATE   VIEW  [PRES].[Vw_Programa]
AS
SELECT *
FROM [PRES].[VwPrograma];
GO
PRINT N'Creando Función [dbo].[STRING_SPLIT]...';


GO

---
--- CREATE FUNCTION: STRING_SPLIT
---


---
--- CREATE FUNCTION: STRING_SPLIT
---
CREATE   FUNCTION [dbo].[STRING_SPLIT]
(
	@stringToSplit VARCHAR(MAX)
)
RETURNS
@returnList TABLE ([Name] [nvarchar] (500))
AS
BEGIN

	 DECLARE @name NVARCHAR(255)
	 DECLARE @pos INT

	 WHILE CHARINDEX(',', @stringToSplit) > 0
	 BEGIN
		  SELECT @pos  = CHARINDEX(',', @stringToSplit)  
		  SELECT @name = SUBSTRING(@stringToSplit, 1, @pos-1)

		  INSERT INTO @returnList 
		  SELECT @name

		  SELECT @stringToSplit = SUBSTRING(@stringToSplit, @pos+1, LEN(@stringToSplit)-@pos)
	 END

	 INSERT INTO @returnList
	 SELECT @stringToSplit

	 RETURN
END
GO
PRINT N'Creando Procedimiento [ALMA].[SP_CargaInicialConteo]...';


GO

CREATE   PROCEDURE [ALMA].[SP_CargaInicialConteo]
    @P_Partida INT = NULL,
    @P_Periodo INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ResultJson NVARCHAR(MAX);
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE FROM [ALMA].[ConteoDetalle];
        DELETE FROM [ALMA].[Conteo];

        IF @P_Partida IS NULL
        BEGIN
            INSERT INTO [ALMA].[Conteo]
                ([FKIdTipoBien_ALMA]
                ,[CantidadInventario]
                ,[Descripcion]
                ,[FechaInicio]
                ,[Activo]
                ,[FechaCreacion]
                ,[UsuarioCreacion]
                ,FKIdPeriodoConteo_ALMA)
            SELECT
                CI.PKIdTipoBien,
                CI.Existencias,
                CI.Descripcion,
                GETDATE(),
                1,
                GETDATE(),
                1,
                @P_Periodo
            FROM
                [ALMA].[VW_Existencias] CI
                INNER JOIN [ALMA].[TipoBien] TB ON CI.PKIdTipoBien = TB.[PKIdTipoBien]
            WHERE
                TB.[FKIdPartida_CONTA] > 20000
                AND TB.[FKIdPartida_CONTA] < 30000
                AND TB.[Activo] = 1;
        END
        ELSE
        BEGIN
            IF @P_Partida <= 20000 OR @P_Partida >= 30000
            BEGIN
                SET @ResultJson = '{"tipo":"ERROR","mensaje":"Solo se permiten conteos del cap�tulo 20000. Partida no permitida: ' + CAST(@P_Partida AS NVARCHAR) + '","liga":""}';
                SELECT JSON_QUERY(@ResultJson) AS ResultJson;
                RETURN;
            END

            INSERT INTO [ALMA].[Conteo]
                ([FKIdTipoBien_ALMA]
                ,[CantidadInventario]
                ,[Descripcion]
                ,[FechaInicio]
                ,[Activo]
                ,[FechaCreacion]
                ,[UsuarioCreacion]
                ,FKIdPeriodoConteo_ALMA)
            SELECT
                CI.PKIdTipoBien,
                CI.Existencias,
                CI.Descripcion,
                GETDATE(),
                1,
                GETDATE(),
                1,
                @P_Periodo
            FROM
                [ALMA].[VW_Existencias] CI
                INNER JOIN [ALMA].[TipoBien] TB ON CI.PKIdTipoBien = TB.[PKIdTipoBien]
            WHERE
                TB.[FKIdPartida_CONTA] = @P_Partida
                AND TB.[Activo] = 1;
        END

        COMMIT TRANSACTION;

        SET @ResultJson = '{"tipo":"EXITO","mensaje":"Conteo generado correctamente","liga":""}';
        SELECT JSON_QUERY(@ResultJson) AS ResultJson;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        SET @ResultJson = '{"tipo":"ERROR","mensaje":"' + REPLACE(@ErrorMessage, '"', '\"') + '","liga":""}';
        SELECT JSON_QUERY(@ResultJson) AS ResultJson;

    END CATCH
END
GO
PRINT N'Creando Procedimiento [CONTA].[SP_CREATE_ClavePoliza]...';


GO

CREATE   PROCEDURE [CONTA].[SP_CREATE_ClavePoliza]
    @FK_IdAnio__SIS INT,
    @FK_IdMesConta__SIS INT,
    @FK_IdTipoPolizaConta__SIS INT,
    @CT_ModifiedBy INT,
    @ClavePoliza NVARCHAR(10) OUTPUT,
    @Error NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        -- Auto-registro: si no existe el consecutivo, lo crea
        IF NOT EXISTS (
            SELECT 1 FROM CONTA.ConsecutivoPoliza
            WHERE FK_IdAnio__SIS = @FK_IdAnio__SIS
              AND FK_IdMes__SIS = @FK_IdMesConta__SIS
              AND FK_IdTipoPoliza__SIS = @FK_IdTipoPolizaConta__SIS
        )
        BEGIN
            INSERT INTO CONTA.ConsecutivoPoliza (
                FK_IdAnio__SIS, FK_IdMes__SIS, FK_IdTipoPoliza__SIS,
                UltimoValor, Activo, FechaCreacion, UsuarioCreacion
            ) VALUES (
                @FK_IdAnio__SIS, @FK_IdMesConta__SIS, @FK_IdTipoPolizaConta__SIS,
                0, 1, GETDATE(), @CT_ModifiedBy
            );
        END

        SELECT @ClavePoliza = CONVERT(NVARCHAR, (CC.FK_IdMes__SIS + CC.UltimoValor + 1))
        FROM CONTA.ConsecutivoPoliza CC WITH (UPDLOCK, ROWLOCK)
        WHERE CC.FK_IdAnio__SIS = @FK_IdAnio__SIS
          AND CC.FK_IdMes__SIS = @FK_IdMesConta__SIS
          AND CC.FK_IdTipoPoliza__SIS = @FK_IdTipoPolizaConta__SIS;

        IF @ClavePoliza IS NULL
        BEGIN
            SET @Error = 'No se pudo generar la clave de p�liza';
            GOTO ERR_HANDLER;
        END

        UPDATE CP
        SET CP.UltimoValor = CP.UltimoValor + 1,
            CP.FechaModificacion = GETDATE(),
            CP.UsuarioModificacion = @CT_ModifiedBy
        FROM CONTA.ConsecutivoPoliza CP
        WHERE CP.FK_IdAnio__SIS = @FK_IdAnio__SIS
          AND CP.FK_IdMes__SIS = @FK_IdMesConta__SIS
          AND CP.FK_IdTipoPoliza__SIS = @FK_IdTipoPolizaConta__SIS;

        IF @@ERROR <> 0
        BEGIN
            SET @Error = CAST(@@ERROR AS NVARCHAR);
            GOTO ERR_HANDLER;
        END

        IF @@TRANCOUNT > 0 AND XACT_STATE() = 1
            COMMIT TRAN;
        RETURN 0;

        ERR_HANDLER:
        IF @@TRANCOUNT > 0
        BEGIN
            IF XACT_STATE() = 1
                ROLLBACK;
        END
        RETURN 1;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            IF XACT_STATE() = 1
                ROLLBACK;
        END
        SET @Error = CONCAT('Error: ', ERROR_MESSAGE(), ' Línea: ', ERROR_LINE());
        RETURN 1;
    END CATCH
END
GO
PRINT N'Creando Procedimiento [PRES].[spAutorizarEgresoProyectado]...';


GO

CREATE   PROCEDURE [PRES].[spAutorizarEgresoProyectado]
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
PRINT N'Creando Procedimiento [SIS].[spEliminarUsuarioSucursal]...';


GO

CREATE   PROCEDURE [SIS].[spEliminarUsuarioSucursal]
    @FkidUsuarioSis INT,
    @FkidSucursalSis INT,
    @UsuarioModificacion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1 FROM SIS.UsuarioSucursal 
            WHERE FkidUsuario_Sis = @FkidUsuarioSis 
            AND FkidSucursal_Sis = @FkidSucursalSis
        )
        BEGIN
            SELECT 
                0 AS Success,
                'No se encontr� la asignaci�n especificada' AS Message,
                'NOT_FOUND' AS Code;
            RETURN;
        END

        DELETE FROM SIS.UsuarioSucursal 
        WHERE FkidUsuario_Sis = @FkidUsuarioSis 
        AND FkidSucursal_Sis = @FkidSucursalSis;

        COMMIT TRANSACTION;

        SELECT 
            1 AS Success,
            'Asignaci�n eliminada correctamente' AS Message,
            'SUCCESS' AS Code;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        SELECT 
            0 AS Success,
            @ErrorMessage AS Message,
            'ERROR' AS Code;

    END CATCH
END
GO
PRINT N'Creando Procedimiento [SIS].[spNodeMenu]...';


GO
--exec [SIS].[spNodeMenu] @NoEmploye = 1, @Lenguaje = 'ESP'
CREATE   PROCEDURE [SIS].[spNodeMenu]
	@NoEmploye int, 
	@Lenguaje char(3)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	IF (@NoEmploye <= 0)
		set @NoEmploye = 1000
	;with cte as 
	(
		SELECT  [SM].[PKIdMenu],[SM].[Nombre],[SM].[Tipo],[SM].[FKIdMenu_SIS],[SM].[LegacyName],[SM].[Ruta],[SM].[ImageUrl],[SM].[Activo],[SM].[Lenguaje],[R].[UserId], [SM].[Orden]
		FROM SIS.Menu [SM] (NOLOCK)
			INNER JOIN SIS.MenuRole [RM] (NOLOCK) ON [RM].[FKIdMenu_SIS] = [SM].[PKIdMenu]
			INNER JOIN [dbo].[AspNetUserRoles] AS R (NOLOCK) ON R.RoleId = RM.RoleID
			INNER JOIN [dbo].[AspNetUsers] [ANU] (NOLOCK) ON [ANU].[Id] = [R].[UserId]
			INNER JOIN SIS.Usuario [EMP] (NOLOCK) ON [EMP].PkIdUsuario = [ANU].PkIdUsuario
		WHERE  [SM].[Activo] = 1 and [SM].FKIdMenu_SIS is null AND [EMP].PkIdUsuario = @NoEmploye
		union all
		SELECT  [SM].[PKIdMenu],[SM].[Nombre],[SM].[Tipo],[SM].[FKIdMenu_SIS],[SM].[LegacyName],[SM].[Ruta],[SM].[ImageUrl],[SM].[Activo],[SM].[Lenguaje],[R].[UserId], [SM].[Orden]
		FROM cte
		INNER JOIN SIS.Menu [SM] (NOLOCK) on SM.FKIdMenu_SIS = cte.PKIdMenu
		INNER JOIN SIS.MenuRole [RM] (NOLOCK) ON [RM].FKIdMenu_SIS = [SM].[PKIdMenu]
		INNER JOIN [dbo].[AspNetUserRoles] AS R (NOLOCK) ON R.RoleId = RM.RoleID
		INNER JOIN [dbo].[AspNetUsers] [ANU] (NOLOCK) ON [ANU].[Id] = [R].[UserId]
		INNER JOIN SIS.Usuario [EMP] (NOLOCK) ON [EMP].PkIdUsuario = [ANU].PkIdUsuario
		WHERE  [SM].[Activo] = 1 and [SM].FKIdMenu_SIS is not null AND [EMP].PkIdUsuario = @NoEmploye
	)    
	SELECT DISTINCT [SM].[PKIdMenu],[SM].[Nombre],[SM].[Tipo],
		[FKIdMenuSIS] = case when [SM].[FKIdMenu_SIS] IS NULL THEN 0 ELSE  [SM].[FKIdMenu_SIS] END,
		[SM].[LegacyName],[SM].[Ruta],[SM].[ImageUrl],[SM].[Activo],[SM].[Lenguaje],[SM].[UserId], [SM].[Orden] 
	FROM cte [SM]
	Order by [SM].[PKIdMenu] 
END
GO
PRINT N'Creando Procedimiento [SIS].[spGetClaimsByUser]...';


GO
--exec [SIS].[spGetClaimsByUser] @PkIdUser = 1, @EsParaLogin = 1
CREATE   PROCEDURE [SIS].[spGetClaimsByUser]
    @PkIdUser INT, 
    @EsParaLogin BIT = 0
AS
BEGIN
    ;WITH Claims AS (
        SELECT 
            ANC.[Group], 
            ANC.SubGroup, 
            ANC.[Values]
        FROM SIS.Usuario AS U WITH (NOLOCK)
        INNER JOIN dbo.AspNetUsers AS ANU WITH (NOLOCK) 
            ON U.PkIdUsuario = ANU.PkIdUsuario
        INNER JOIN dbo.AspNetUserRoles AS ANUR WITH (NOLOCK) 
            ON ANUR.UserId = ANU.Id
        INNER JOIN dbo.AspNetRoles AS R WITH (NOLOCK) 
            ON R.Id = ANUR.RoleId
        INNER JOIN dbo.AspNetClaims AS ANC WITH (NOLOCK) 
            ON ANC.RoleId = R.Id
        LEFT JOIN SIS.MenuRole AS MR WITH (NOLOCK) 
            ON MR.RoleId = R.Id
        LEFT JOIN SIS.Menu AS M WITH (NOLOCK) 
            ON M.PKIdMenu = MR.FKIdMenu_SIS
        WHERE 
            U.PkIdUsuario = @PkIdUser
            AND U.Activo = 1
            AND (@EsParaLogin = 0 OR M.Activo = 1)
    )
    SELECT
        [Group], SubGroup, [Values]
    FROM Claims
    GROUP BY [Group], SubGroup, [Values]
    ORDER BY [Group], SubGroup, [Values];
END
GO
PRINT N'Creando Procedimiento [SIS].[LoginInformationEmployee]...';


GO
--EXEC [SIS].[LoginInformationEmployee] @PayrollID = 'ADMIN001'
CREATE   PROCEDURE [SIS].[LoginInformationEmployee](
	@PayrollID NVARCHAR(60)
)
AS BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	SELECT e.PkIdUsuario
    , iif(e.FKIdPersona_NOM IS NULL,0,e.FKIdPersona_NOM) FKIdPersonaNOM
    , e.PayrollID
    , iif(p.Gafete is null,e.PayrollID,p.Gafete) Gafete
    , ANU.PasswordHash
    , rol.Name
    , iif(p.CORREO_ELECTRONICO IS NULL ,'ADMIN@eg.COM',p.CORREO_ELECTRONICO) AS Email
    , NombreUsuario = IIF(p.Nombre IS NULL,'Admin',CONCAT(p.Nombre, ' ', p.Paterno, ' ', p.Materno))
	FROM SIS.Usuario AS e WITH (NOLOCK)
	LEFT JOIN NOM.Persona p ON e.FKIdPersona_NOM = p.PKIdPersona
	INNER JOIN dbo.AspNetUsers AS ANU WITH (NOLOCK) ON ANU.PkIdUsuario = e.PkIdUsuario
	INNER JOIN [dbo].[AspNetUserRoles] AS UR WITH (NOLOCK) ON UR.UserId = ANU.Id
	INNER JOIN AspNetRoles AS rol WITH (NOLOCK) ON UR.RoleId = rol.Id
	WHERE e.PayrollID = @PayrollID AND e.Activo = 1
END;
GO
PRINT N'Creando Procedimiento [SIS].[WriteSystemLog]...';


GO

CREATE   PROCEDURE [SIS].[WriteSystemLog] (
	@FK_IdOrigenLogMessage__SIS  nvarchar(24) = NULL
	,@Date nvarchar(24) = NULL 
	,@_Type nvarchar(24) = NULL
	,@ProgName nvarchar(256) = NULL
	,@EmployeeNo nvarchar(24) = NULL
	,@Category nvarchar(24) = NULL
	,@IPClient nvarchar(24) = NULL
	,@HostName nvarchar(32) = NULL
	,@Thread nvarchar(255) = NULL 
	,@Level nvarchar(20) =NULL 
	,@Logger nvarchar(255) =NULL 
	,@Message nvarchar(4000)= NULL
	,@Exception nvarchar(4000) = null
	,@Context nvarchar(10)  =null
	,@MethodName nvarchar(200)  =null
	,@Parameters nvarchar(4000) = null
	,@ExecutionTime nvarchar(32) = null
)
AS
BEGIN
	IF ISNULL(@Logger,'') = 'Microsoft.EntityFrameworkCore.Database.Command'
		return;

	IF EXISTS(SELECT 1
				FROM  SIS.SystemParamCatalog AS c 
					INNER JOIN SIS.SystemParamValue AS t ON c.PKIdSystemParamCatalog = t.FKIdSystemParamCatalog_SIS
				WHERE c.Code = 'SISTEMA'
					AND t.PKIdSystemParamValue = 1
					AND C.Activo = 1
					AND t.Activo = 1
					AND CAST(T.Value  AS INT) = 1)
	BEGIN 

		if @Exception     = '' set @Exception = null;
        if @Context       = '(null)' set @Context = null;
        if @MethodName    = '(null)' set @MethodName = null;
        if @Parameters    = '(null)' set @Parameters = null;        
        if @ExecutionTime = '(null)' set @ExecutionTime = null;

		if (@Date = '' Or @Date = '(null)' Or @Date is null) set @Date = GETDATE();
		
        DECLARE @ETInt int;
		set @ETInt  = IIF(@ExecutionTime IS NULL,0,convert(int, @ExecutionTime));

		INSERT INTO SIS.SystemLog (
				 [FKIdOrigenLogMessage_SIS]
				,[Date]
				,[Type]
				,[ProgName]
				,[EmployeeNo]
				,[Category]
				,[IPClient]
				,[HostName]
				,[Thread]
				,[Level]
				,[Logger]
				,[Message]
				,[Exception]
				,[Context]
				,[MethodName]
				,[Parameters]
			)
		values(  IIF(@FK_IdOrigenLogMessage__SIS IS NULL, 1, @FK_IdOrigenLogMessage__SIS)
				,@Date
				,@_Type
				,@ProgName 
				,@EmployeeNo 
				,@Category 
				,@IPClient 
				,@HostName 
				,@Thread 
				,@Level  
				,@Logger  
				,@Message 
				,@Exception 
				,@Context 
				,@MethodName 
				,@Parameters 
			)
	END
END
GO
PRINT N'Creando Procedimiento [dbo].[sp_RegistrarEntidad]...';


GO

CREATE   PROCEDURE [dbo].[sp_RegistrarEntidad]
    @Grupo          NVARCHAR(100),
    @SubGrupo       NVARCHAR(100),
    @NombreMenu     NVARCHAR(150),
    @Ruta           NVARCHAR(200),
    @MenuPadreNombre NVARCHAR(150) = NULL,
    @Icono          NVARCHAR(120) = NULL,
    @Orden          INT = 0,
    @Descripcion    NVARCHAR(200) = NULL,
    @Codigo         NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdMenu INT;
    DECLARE @IdMenuPadre INT = NULL;
    DECLARE @PermisosAdmin    NVARCHAR(100) = 'view,view-menu,delete,new,update,CanExportToExcel';
    DECLARE @PermisosSoporte  NVARCHAR(100) = 'view,view-menu';
    DECLARE @PermisosConfig   NVARCHAR(100) = 'view,view-menu,delete,new,update';

    IF @MenuPadreNombre IS NOT NULL
    BEGIN
        SELECT @IdMenuPadre = PKIdMenu
        FROM SIS.Menu
        WHERE Nombre = @MenuPadreNombre AND Activo = 1;
        
        IF @IdMenuPadre IS NULL
        BEGIN
            PRINT 'Advertencia: No se encontr� el men� padre "' + @MenuPadreNombre + '". Se registrar� como ra�z.';
        END
    END

    IF @Codigo IS NULL
        SET @Codigo = UPPER(LEFT(@Grupo, 2) + LEFT(@SubGrupo, 2) + '001');

    IF NOT EXISTS (SELECT 1 FROM SIS.Menu WHERE Nombre = @NombreMenu AND Ruta = @Ruta AND Activo = 1)
    BEGIN
        INSERT INTO SIS.Menu (
            Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta,
            ImageUrl, Lenguaje, Orden, Activo, CreatedDateTime
        ) VALUES (
            @NombreMenu, 2, @IdMenuPadre, @NombreMenu, @Ruta,
            @Icono, 'ESP', @Orden, 1, GETDATE()
        );
        SET @IdMenu = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        SELECT @IdMenu = PKIdMenu FROM SIS.Menu WHERE Nombre = @NombreMenu AND Ruta = @Ruta AND Activo = 1;
    END

    DECLARE @Roles TABLE (Code NVARCHAR(10), Permisos NVARCHAR(100));
    INSERT INTO @Roles VALUES ('10000', @PermisosAdmin), ('20000', @PermisosSoporte), ('30000', @PermisosConfig);

    DECLARE @CodeRole NVARCHAR(10), @PermisosRole NVARCHAR(100), @RoleId NVARCHAR(128);

    DECLARE role_cursor CURSOR FOR
        SELECT r.Code, rp.Permisos
        FROM AspNetRoles r
        INNER JOIN @Roles rp ON r.Code = rp.Code;

    OPEN role_cursor;
    FETCH NEXT FROM role_cursor INTO @CodeRole, @PermisosRole;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @RoleId = (SELECT Id FROM AspNetRoles WHERE Code = @CodeRole);

        IF NOT EXISTS (
            SELECT 1 FROM AspNetClaims
            WHERE RoleId = @RoleId AND [Group] = @Grupo AND SubGroup = @SubGrupo
        )
        BEGIN
            INSERT INTO AspNetClaims (
                ClaimTypeId, Name, [Group], RoleId, TokenFormat, Created,
                SubGroup, Code, [Description], [Values], ReferenceId
            )
            VALUES (
                2, @Grupo, @Grupo, @RoleId, 'app://{0}/{1}', GETDATE(),
                @SubGrupo, @Codigo, @Descripcion, @PermisosRole,
                ISNULL((SELECT TOP 1 Id FROM AspNetClaims WHERE [Group] = @Grupo AND SubGroup = @SubGrupo), 0)
            );
        END
        ELSE
        BEGIN
            DECLARE @CurrentValues NVARCHAR(MAX);
            SELECT @CurrentValues = [Values] FROM AspNetClaims
            WHERE RoleId = @RoleId AND [Group] = @Grupo AND SubGroup = @SubGrupo;

            SET @PermisosRole = (
                SELECT STRING_AGG(value, ',') WITHIN GROUP (ORDER BY value)
                FROM (
                    SELECT DISTINCT value FROM STRING_SPLIT(@CurrentValues, ',')
                    UNION
                    SELECT DISTINCT value FROM STRING_SPLIT(@PermisosRole, ',')
                ) AS t
            );

            UPDATE AspNetClaims
            SET [Values] = @PermisosRole,
                [Description] = ISNULL(@Descripcion, [Description])
            WHERE RoleId = @RoleId AND [Group] = @Grupo AND SubGroup = @SubGrupo;
        END

        DECLARE @ClaimId INT;
        SELECT @ClaimId = Id FROM AspNetClaims
        WHERE RoleId = @RoleId AND [Group] = @Grupo AND SubGroup = @SubGrupo;

        INSERT INTO AspNetClaimValues (ClaimId, Value, Created)
        SELECT @ClaimId, TRIM(value), GETDATE()
        FROM STRING_SPLIT(@PermisosRole, ',')
        WHERE NOT EXISTS (
            SELECT 1 FROM AspNetClaimValues
            WHERE ClaimId = @ClaimId AND Value = TRIM(value)
        );

        IF EXISTS (SELECT 1 FROM STRING_SPLIT(@PermisosRole, ',') WHERE value = 'view-menu')
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM SIS.MenuRole WHERE FKIdMenu_SIS = @IdMenu AND RoleId = @RoleId)
            BEGIN
                INSERT INTO SIS.MenuRole (FKIdMenu_SIS, RoleId, Activo, CreatedDateTime)
                VALUES (@IdMenu, @RoleId, 1, GETDATE());
            END
        END
        ELSE
        BEGIN
            DELETE FROM SIS.MenuRole WHERE FKIdMenu_SIS = @IdMenu AND RoleId = @RoleId;
        END

        FETCH NEXT FROM role_cursor INTO @CodeRole, @PermisosRole;
    END

    CLOSE role_cursor;
    DEALLOCATE role_cursor;

    PRINT 'Entidad "' + @Grupo + '/' + @SubGrupo + '" registrada correctamente.';
END
GO
PRINT N'Creando Procedimiento [dbo].[spConfiguracionDeRolYClaims]...';


GO

CREATE   PROCEDURE [dbo].[spConfiguracionDeRolYClaims]
	@group NVARCHAR(100),
	@subgroup NVARCHAR(100),
	@code NVARCHAR(10),
	@values NVARCHAR(max),
	@description NVARCHAR(200) = NULL,
	@rolName NVARCHAR(256) = NULL
AS
BEGIN
	
	SET NOCOUNT ON;

    DECLARE @IdRole NVARCHAR(128),
	        @value NVARCHAR(max),
	        @claims NVARCHAr(max),
			@IdReference INT,
			@Cod NVARCHAR(10),
			@IdClaim INT,
			@errorMassage1 NVARCHAR(200),
			@errorMassage2 NVARCHAR(200);

	IF EXISTS(SELECT 1 FROM AspNetRoles WHERE Code = @code)
	BEGIN
    
		SET @IdRole = (SELECT Id FROM AspNetRoles WHERE Code = @code)
		SET @Cod = (SELECT TOP 1 Code FROM AspNetClaims WHERE [Group] = @group)
		SET @IdReference = (SELECT TOP 1 Id FROM AspNetClaims WHERE [Group] = @group AND [SubGroup] = @subgroup)
	
		IF EXISTS(SELECT 1 FROM AspNetClaims WHERE RoleId = @IdRole and [Group] = @group)
		BEGIN

			IF EXISTS(SELECT 1 FROM AspNetClaims WHERE RoleId = @IdRole AND [Group] = @group AND [SubGroup] = @subgroup)
			BEGIN
			
				SET @claims = (SELECT [Values] FROM AspNetClaims WHERE RoleId = @IdRole AND [Group] = @group AND [SubGroup] = @subgroup);

				IF EXISTS(SELECT 1 FROM [dbo].[STRING_SPLIT](@claims) WHERE Name = @values)
				BEGIN
					SET @errorMassage1 = 'El Claim ' + @values + ' ya Existe';
				END
				ELSE
				BEGIN
			    
					UPDATE AspNetClaims SET [Values] = @claims + ',' + @values
					WHERE RoleId = @IdRole AND [Group] = @group AND [SubGroup] = @subgroup

				END
			END
			ELSE
			BEGIN
		    
				IF @Description IS NULL
				BEGIN
					SET @Description=(SELECT TOP 1 Description FROM AspNetClaims WHERE [Group] = @group AND [SubGroup] = @subgroup)
				END

				INSERT INTO AspNetClaims(ClaimTypeId,Name,[Group],RoleId,TokenFormat,Created,SubGroup,Code,[Description],[Values],ReferenceId)
				VALUES(2,@group,@group,@IdRole,'app://{0}/{1}',GETDATE(),@subgroup,@Cod,@Description,@values,@IdReference)
				
			END

		END
		ELSE
		BEGIN

			IF @Description IS NULL
			BEGIN
				SET @Description=(SELECT TOP 1 Description FROM AspNetClaims WHERE [Group] = @group AND [SubGroup] = @subgroup)
			END
	    
			INSERT INTO AspNetClaims(ClaimTypeId,Name,[Group],RoleId,TokenFormat,Created,SubGroup,Code,[Description],[Values],ReferenceId)
			VALUES(2,@group,@group,@IdRole,'app://{0}/{1}',GETDATE(),@subgroup,@Cod,@Description,@values,@IdReference)

		END

	END
	ELSE
	BEGIN
        
		IF @rolName IS NOT NULL
		BEGIN
			SET @IdRole = NEWID();
			SET @Cod = (SELECT TOP 1 Code FROM AspNetClaims WHERE [Group] = @group)
			SET @IdReference = (SELECT TOP 1 Id FROM AspNetClaims WHERE [Group] = @group)

			INSERT INTO AspNetRoles
			VALUES(@IdRole,@rolName,@code)

			INSERT INTO AspNetClaims(ClaimTypeId,Name,[Group],RoleId,TokenFormat,Created,SubGroup,Code,[Description],[Values],ReferenceId)
			VALUES(2,@group,@group,@IdRole,'app://{0}/{1}',GETDATE(),@subgroup,@Cod,@Description,@values,@IdReference)
		
		END
		ELSE
		BEGIN
		    SET @errorMassage1 = 'Para agregar un rol se necesita el nombre que se le asignara';
		END

	END

	IF @errorMassage1 <> 'Success'
	BEGIN
		SELECT @errorMassage1 AS AspNetClaims;
	END
	
	SET @IdClaim = (SELECT MAX(Id) FROM AspNetClaims WHERE RoleId = @IdRole AND [Group] = @group AND [SubGroup] = @subgroup);

	IF @IdClaim IS NULL
	BEGIN
	    SET @errorMassage2 = 'Revisar parametros de entrada';
	END
	ELSE
	BEGIN
	    
		IF EXISTS(SELECT 1 FROM AspNetClaimValues WHERE ClaimId = @IdClaim AND Value = @Values)
		BEGIN
	    
			SET @errorMassage2 = 'El valor ya se encuentra registrado';

		END
		ELSE
		BEGIN
	    
			INSERT INTO AspNetClaimValues(ClaimId,Value,Created)
			VALUES(@IdClaim,@values,GETDATE())
		
		END

	END

	IF @errorMassage2 <> 'Success'
	BEGIN
		SELECT @errorMassage2 AS AspNetClaimValues;
	END
END
GO
PRINT N'Creando Procedimiento [ALMA].[SP_MantenimientoTipoBien]...';


GO

CREATE   PROCEDURE [ALMA].[SP_MantenimientoTipoBien] (
    @Action INT,
    @PKIdTipoBien INT = NULL,
    @FKIdGrupoBien_ALMA INT = NULL,
    @FKIdNivel_ALMA INT = NULL,
    @FKIdPartida_CONTA INT = NULL,
    @FKIdCuentaContable_CONTA INT = NULL,
    @FKIdUnidades_ALMA INT = NULL,
    @FKIdLocalizacion_ALMA INT = NULL,
    @FKIdUnidades_Equivalente INT = NULL,
    @CodigoClave NVARCHAR(200) = NULL,
    @Descripcion NVARCHAR(1200) = NULL,
    @DepreciacionAnual DECIMAL(18,4) = NULL,
    @Consecutivo INT = NULL,
    @CABMS NVARCHAR(50) = NULL,
    @Identificador NVARCHAR(50) = NULL,
    @ExistenciaMinima DECIMAL(18,4) = NULL,
    @ExistenciaMaxima DECIMAL(18,4) = NULL,
    @TiempoVida INT = NULL,
    @Pk_IdTratadoInt INT = NULL,
    @Cuota NUMERIC(8,2) = NULL,
    @ProveeduriaNac BIT = NULL,
    @CatalogoBasico BIT = NULL,
    @CUCOP_PLUS VARCHAR(25) = NULL,
    @Cantidad_Equivalente INT = NULL,
    @IdUser INT = NULL,
    @Id INT = NULL OUTPUT
)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(100);
    DECLARE @message NVARCHAR(4000);
    DECLARE @Parameters NVARCHAR(4000) = '';
    DECLARE @errorMessage NVARCHAR(MAX);
    DECLARE @today DATETIME2 = SYSDATETIME();

    SET @message = CONCAT('Iniciando el SP [ALMA].[SP_MantenimientoTipoBien]', ' @PKIdTipoBien ', @PKIdTipoBien);
    SET @Parameters = CONCAT(
        'Action=', ISNULL(CONVERT(NVARCHAR(30), @Action), 'NULL'),
        ', PKIdTipoBien=', ISNULL(CONVERT(NVARCHAR(30), @PKIdTipoBien), 'NULL'),
        ', FKIdGrupoBien_ALMA=', ISNULL(CONVERT(NVARCHAR(30), @FKIdGrupoBien_ALMA), 'NULL'),
        ', FKIdNivel_ALMA=', ISNULL(CONVERT(NVARCHAR(30), @FKIdNivel_ALMA), 'NULL'),
        ', FKIdPartida_CONTA=', ISNULL(CONVERT(NVARCHAR(30), @FKIdPartida_CONTA), 'NULL'),
        ', FKIdCuentaContable_CONTA=', ISNULL(CONVERT(NVARCHAR(30), @FKIdCuentaContable_CONTA), 'NULL'),
        ', FKIdUnidades_ALMA=', ISNULL(CONVERT(NVARCHAR(30), @FKIdUnidades_ALMA), 'NULL'),
        ', CodigoClave=', ISNULL(@CodigoClave, 'NULL'),
        ', Descripcion=', ISNULL(LEFT(@Descripcion, 300), 'NULL'),
        ', Consecutivo=', ISNULL(CONVERT(NVARCHAR(30), @Consecutivo), 'NULL'),
        ', CABMS=', ISNULL(@CABMS, 'NULL'),
        ', IdUser=', ISNULL(CONVERT(NVARCHAR(30), @IdUser), 'NULL')
    );
    EXEC [SIS].[WriteSystemLog]
        @FK_IdOrigenLogMessage__SIS = 1,
        @Date = @today,
        @_Type = 1,
        @ProgName = 'ALMA.SP_MantenimientoTipoBien',
        @EmployeeNo = @IdUser,
        @Category = NULL,
        @IPClient = NULL,
        @HostName = NULL,
        @Thread = NULL,
        @Level = 'INFO',
        @Logger = NULL,
        @Message = @message,
        @Exception = NULL,
        @Context = NULL,
        @MethodName = 'ALMA.SP_MantenimientoTipoBien',
        @Parameters = @Parameters,
        @ExecutionTime = '0';

    SET @message = '';

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            DECLARE @FKIdPartidaCalculada INT = @FKIdPartida_CONTA;
            DECLARE @CABMSCalculada VARCHAR(50) = @CABMS;

            INSERT INTO ALMA.TipoBien (
                FKIdGrupoBien_ALMA, FKIdNivel_ALMA,
                FKIdPartida_CONTA, FKIdCuentaContable_CONTA,
                FKIdUnidades_ALMA, FKIdLocalizacion_ALMA,
                FKIdUnidades_Equivalente,
                CodigoClave, Descripcion,
                DepreciacionAnual, Consecutivo, CABMS,
                Identificador, ExistenciaMinima, ExistenciaMaxima,
                TiempoVida, Pk_IdTratadoInt, Cuota,
                ProveeduriaNac, CatalogoBasico, CUCOP_PLUS,
                Cantidad_Equivalente,
                Activo, FechaCreacion, UsuarioCreacion
            )
            VALUES (
                @FKIdGrupoBien_ALMA, @FKIdNivel_ALMA,
                @FKIdPartidaCalculada, @FKIdCuentaContable_CONTA,
                @FKIdUnidades_ALMA, @FKIdLocalizacion_ALMA,
                @FKIdUnidades_Equivalente,
                @CodigoClave, @Descripcion,
                @DepreciacionAnual, @Consecutivo, @CABMSCalculada,
                @Identificador, @ExistenciaMinima, @ExistenciaMaxima,
                @TiempoVida, @Pk_IdTratadoInt, @Cuota,
                @ProveeduriaNac, @CatalogoBasico, @CUCOP_PLUS,
                @Cantidad_Equivalente,
                1, @today, @IdUser
            );

            SET @Id = SCOPE_IDENTITY();
            SET @tipo = 'OK';
            SET @message = 'Tipo de bien creado correctamente.';
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdTipoBien IS NULL OR NOT EXISTS (SELECT 1 FROM ALMA.TipoBien WHERE PKIdTipoBien = @PKIdTipoBien AND Activo = 1)
            BEGIN
                SET @tipo = 'ERROR';
                SET @message = 'Tipo de bien no encontrado';
                GOTO ERR_HANDLER;
            END

            UPDATE ALMA.TipoBien
            SET
                FKIdGrupoBien_ALMA = ISNULL(@FKIdGrupoBien_ALMA, FKIdGrupoBien_ALMA),
                FKIdNivel_ALMA = ISNULL(@FKIdNivel_ALMA, FKIdNivel_ALMA),
                FKIdPartida_CONTA = ISNULL(@FKIdPartida_CONTA, FKIdPartida_CONTA),
                FKIdCuentaContable_CONTA = ISNULL(@FKIdCuentaContable_CONTA, FKIdCuentaContable_CONTA),
                FKIdUnidades_ALMA = ISNULL(@FKIdUnidades_ALMA, FKIdUnidades_ALMA),
                FKIdLocalizacion_ALMA = ISNULL(@FKIdLocalizacion_ALMA, FKIdLocalizacion_ALMA),
                FKIdUnidades_Equivalente = ISNULL(@FKIdUnidades_Equivalente, FKIdUnidades_Equivalente),
                CodigoClave = ISNULL(@CodigoClave, CodigoClave),
                Descripcion = ISNULL(@Descripcion, Descripcion),
                DepreciacionAnual = ISNULL(@DepreciacionAnual, DepreciacionAnual),
                Consecutivo = ISNULL(@Consecutivo, Consecutivo),
                CABMS = ISNULL(@CABMS, CABMS),
                Identificador = ISNULL(@Identificador, Identificador),
                ExistenciaMinima = ISNULL(@ExistenciaMinima, ExistenciaMinima),
                ExistenciaMaxima = ISNULL(@ExistenciaMaxima, ExistenciaMaxima),
                TiempoVida = ISNULL(@TiempoVida, TiempoVida),
                Pk_IdTratadoInt = ISNULL(@Pk_IdTratadoInt, Pk_IdTratadoInt),
                Cuota = ISNULL(@Cuota, Cuota),
                ProveeduriaNac = ISNULL(@ProveeduriaNac, ProveeduriaNac),
                CatalogoBasico = ISNULL(@CatalogoBasico, CatalogoBasico),
                CUCOP_PLUS = ISNULL(@CUCOP_PLUS, CUCOP_PLUS),
                Cantidad_Equivalente = ISNULL(@Cantidad_Equivalente, Cantidad_Equivalente),
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdTipoBien = @PKIdTipoBien;

            SET @Id = @PKIdTipoBien;
            SET @tipo = 'OK';
            SET @message = 'Tipo de bien actualizado correctamente.';
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdTipoBien IS NULL OR NOT EXISTS (SELECT 1 FROM ALMA.TipoBien WHERE PKIdTipoBien = @PKIdTipoBien AND Activo = 1)
            BEGIN
                SET @tipo = 'ERROR';
                SET @message = 'Tipo de bien no encontrado';
                GOTO ERR_HANDLER;
            END

            UPDATE ALMA.TipoBien
            SET
                Activo = 0,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdTipoBien = @PKIdTipoBien;

            SET @Id = @PKIdTipoBien;
            SET @tipo = 'OK';
            SET @message = 'Tipo de bien eliminado correctamente.';
        END
        ELSE IF @Action = 4
        BEGIN
            SELECT
                tb.PKIdTipoBien,
                tb.FKIdGrupoBien_ALMA,
                gb.Descripcion AS GrupoBien,
                tb.FKIdNivel_ALMA,
                tb.FKIdPartida_CONTA,
                p.Clave AS PartidaClave,
                p.Descripcion AS PartidaDescripcion,
                tb.FKIdCuentaContable_CONTA,
                tb.FKIdUnidades_ALMA,
                u.Descripcion AS UnidadMedida,
                tb.FKIdLocalizacion_ALMA,
                tb.FKIdUnidades_Equivalente,
                tb.CodigoClave,
                tb.Descripcion,
                tb.DepreciacionAnual,
                tb.Consecutivo,
                tb.CABMS,
                tb.Identificador,
                tb.ExistenciaMinima,
                tb.ExistenciaMaxima,
                tb.TiempoVida,
                tb.Pk_IdTratadoInt,
                tb.Cuota,
                tb.ProveeduriaNac,
                tb.CatalogoBasico,
                tb.CUCOP_PLUS,
                tb.Cantidad_Equivalente,
                tb.Activo,
                tb.FechaCreacion,
                tb.UsuarioCreacion,
                tb.FechaModificacion,
                tb.UsuarioModificacion
            FROM ALMA.TipoBien tb
            LEFT JOIN ALMA.GrupoBien gb ON tb.FKIdGrupoBien_ALMA = gb.PKIdGrupoBien
            LEFT JOIN CONTA.Partida p ON tb.FKIdPartida_CONTA = p.PKIdPartida
            LEFT JOIN ALMA.Unidades u ON tb.FKIdUnidades_ALMA = u.PKIdUnidades
            WHERE tb.PKIdTipoBien = @PKIdTipoBien;

            SET @tipo = 'OK';
            GOTO FINISH;
        END
        ELSE
        BEGIN
            SET @tipo = 'ERROR';
            SET @message = 'Acci�n no v�lida. Use 1=Insert, 2=Update, 3=Delete, 4=GetById';
            GOTO ERR_HANDLER;
        END

        FINISH:
        IF @@TRANCOUNT > 0 AND XACT_STATE() = 1
            COMMIT TRANSACTION;

        SELECT JSON_QUERY(
            CONCAT('{"tipo":"', @tipo, '","mensaje":"', @message, '","liga":"idTipoBien:', ISNULL(CAST(@Id AS NVARCHAR), ''), '"}')
        ) AS ResultJson;

        RETURN 0;

        ERR_HANDLER:
        IF @@TRANCOUNT > 0
        BEGIN
            IF XACT_STATE() = 1
                ROLLBACK TRANSACTION;
            ELSE IF XACT_STATE() = -1
                ROLLBACK TRANSACTION;
        END

        SELECT @errorMessage = CONCAT(
            ISNULL(PROGRAM_NAME(), ''), CHAR(10),
            'Error: ', ERROR_MESSAGE(), CHAR(10),
            'Línea: ', ERROR_LINE()
        );

        SELECT JSON_QUERY(
            CONCAT('{"tipo":"ERROR","mensaje":"', @errorMessage, '","liga":""}')
        ) AS ResultJson;

        RETURN -1;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            IF XACT_STATE() = 1
                ROLLBACK TRANSACTION;
            ELSE IF XACT_STATE() = -1
                ROLLBACK TRANSACTION;
        END

        SELECT @errorMessage = CONCAT(
            ISNULL(PROGRAM_NAME(), ''), CHAR(10),
            'Error: ', ERROR_MESSAGE(), CHAR(10),
            'Línea: ', ERROR_LINE()
        );

        SELECT JSON_QUERY(
            CONCAT('{"tipo":"ERROR","mensaje":"', @errorMessage, '","liga":""}')
        ) AS ResultJson;

        RETURN -1;
    END CATCH
END;
GO
PRINT N'Creando Procedimiento [CONTA].[SP_MantenimientoPoliza]...';


GO

CREATE   PROCEDURE [CONTA].[SP_MantenimientoPoliza] (
    @Action INT,
    @PKIdPoliza INT = NULL,
    @FKIdAnio_SIS INT = NULL,
    @FKIdMes_SIS INT = NULL,
    @FKIdTipoPoliza_SIS INT = NULL,
    @NombrePoliza NVARCHAR(1000) = NULL,
    @FechaPoliza DATETIME = NULL,
    @EstaBalanceado BIT = NULL,
    @PermitirModificar BIT = NULL,
    @FKIdAccionAutorizar_SIS INT = NULL,
    @Autorizado BIT = NULL,
    @FechaSolicitud DATETIME = NULL,
    @FechaAutorizacion DATETIME = NULL,
    @IdUser INT = NULL,
    @Id INT = NULL OUTPUT
)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(100);
    DECLARE @message NVARCHAR(4000);
    DECLARE @Parameters NVARCHAR(4000) = '';
    DECLARE @errorMessage NVARCHAR(MAX);
    DECLARE @today DATETIME2 = SYSDATETIME();

    SET @message = CONCAT('Iniciando el SP [CONTA].[SP_MantenimientoPoliza]', ' @PKIdPoliza ', @PKIdPoliza);
    SET @Parameters = CONCAT(
        'Action=', ISNULL(CONVERT(NVARCHAR(30), @Action), 'NULL'),
        ', PKIdPoliza=', ISNULL(CONVERT(NVARCHAR(30), @PKIdPoliza), 'NULL'),
        ', FKIdAnio_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdAnio_SIS), 'NULL'),
        ', FKIdMes_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdMes_SIS), 'NULL'),
        ', FKIdTipoPoliza_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdTipoPoliza_SIS), 'NULL'),
        ', NombrePoliza=', ISNULL(LEFT(@NombrePoliza, 300), 'NULL'),
        ', FechaPoliza=', ISNULL(CONVERT(NVARCHAR(30), @FechaPoliza, 126), 'NULL'),
        ', EstaBalanceado=', ISNULL(CONVERT(NVARCHAR(30), @EstaBalanceado), 'NULL'),
        ', PermitirModificar=', ISNULL(CONVERT(NVARCHAR(30), @PermitirModificar), 'NULL'),
        ', Autorizado=', ISNULL(CONVERT(NVARCHAR(30), @Autorizado), 'NULL'),
        ', FechaSolicitud=', ISNULL(CONVERT(NVARCHAR(30), @FechaSolicitud, 126), 'NULL'),
        ', FechaAutorizacion=', ISNULL(CONVERT(NVARCHAR(30), @FechaAutorizacion, 126), 'NULL'),
        ', IdUser=', ISNULL(CONVERT(NVARCHAR(30), @IdUser), 'NULL')
    );
    EXEC [SIS].[WriteSystemLog]
        @FK_IdOrigenLogMessage__SIS = 1,
        @Date = @today,
        @_Type = 1,
        @ProgName = 'CONTA.SP_MantenimientoPoliza',
        @EmployeeNo = @IdUser,
        @Category = NULL,
        @IPClient = NULL,
        @HostName = NULL,
        @Thread = NULL,
        @Level = 'INFO',
        @Logger = NULL,
        @Message = @message,
        @Exception = NULL,
        @Context = NULL,
        @MethodName = 'CONTA.SP_MantenimientoPoliza',
        @Parameters = @Parameters,
        @ExecutionTime = '0';

    SET @message = '';

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            DECLARE @ClavePoliza NVARCHAR(10);
            DECLARE @ErrMsg NVARCHAR(MAX);

            EXEC [CONTA].[SP_CREATE_ClavePoliza]
                @FK_IdAnio__SIS = @FKIdAnio_SIS,
                @FK_IdMesConta__SIS = @FKIdMes_SIS,
                @FK_IdTipoPolizaConta__SIS = @FKIdTipoPoliza_SIS,
                @CT_ModifiedBy = @IdUser,
                @ClavePoliza = @ClavePoliza OUTPUT,
                @Error = @ErrMsg OUTPUT;

            IF @ClavePoliza IS NULL OR @ClavePoliza = ''
            BEGIN
                SET @message = ISNULL(@ErrMsg, 'Error al generar clave de p�liza');
                SET @tipo = 'ERROR';
                GOTO ERR_HANDLER;
            END

            INSERT INTO CONTA.Poliza (
                FKIdAnio_SIS,
                FKIdMes_SIS,
                FKIdTipoPoliza_SIS,
                ClavePoliza,
                NombrePoliza,
                FechaPoliza,
                EstaBalanceado,
                PermitirModificar,
                FKIdAccionAutorizar_SIS,
                Autorizado,
                FechaSolicitud,
                FechaAutorizacion,
                Activo,
                FechaCreacion,
                UsuarioCreacion
            )
            VALUES (
                @FKIdAnio_SIS,
                @FKIdMes_SIS,
                @FKIdTipoPoliza_SIS,
                @ClavePoliza,
                @NombrePoliza,
                @FechaPoliza,
                ISNULL(@EstaBalanceado, 0),
                @PermitirModificar,
                @FKIdAccionAutorizar_SIS,
                @Autorizado,
                @FechaSolicitud,
                @FechaAutorizacion,
                1,
                @today,
                @IdUser
            );

            SET @Id = SCOPE_IDENTITY();
            SET @tipo = 'OK';
            SET @message = CONCAT('P�liza creada correctamente. Clave: ', @ClavePoliza);
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdPoliza IS NULL OR NOT EXISTS (SELECT 1 FROM CONTA.Poliza WHERE PKIdPoliza = @PKIdPoliza AND Activo = 1)
            BEGIN
                SET @tipo = 'ERROR';
                SET @message = 'P�liza no encontrada';
                GOTO ERR_HANDLER;
            END

            UPDATE CONTA.Poliza
            SET
                FKIdAnio_SIS = ISNULL(@FKIdAnio_SIS, FKIdAnio_SIS),
                FKIdMes_SIS = ISNULL(@FKIdMes_SIS, FKIdMes_SIS),
                FKIdTipoPoliza_SIS = ISNULL(@FKIdTipoPoliza_SIS, FKIdTipoPoliza_SIS),
                NombrePoliza = ISNULL(@NombrePoliza, NombrePoliza),
                FechaPoliza = ISNULL(@FechaPoliza, FechaPoliza),
                EstaBalanceado = ISNULL(@EstaBalanceado, EstaBalanceado),
                PermitirModificar = ISNULL(@PermitirModificar, PermitirModificar),
                FKIdAccionAutorizar_SIS = ISNULL(@FKIdAccionAutorizar_SIS, FKIdAccionAutorizar_SIS),
                Autorizado = ISNULL(@Autorizado, Autorizado),
                FechaSolicitud = ISNULL(@FechaSolicitud, FechaSolicitud),
                FechaAutorizacion = ISNULL(@FechaAutorizacion, FechaAutorizacion),
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdPoliza = @PKIdPoliza;

            SET @Id = @PKIdPoliza;
            SET @tipo = 'OK';
            SET @message = 'P�liza actualizada correctamente.';
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdPoliza IS NULL OR NOT EXISTS (SELECT 1 FROM CONTA.Poliza WHERE PKIdPoliza = @PKIdPoliza AND Activo = 1)
            BEGIN
                SET @tipo = 'ERROR';
                SET @message = 'P�liza no encontrada';
                GOTO ERR_HANDLER;
            END

            UPDATE CONTA.Poliza
            SET
                Activo = 0,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdPoliza = @PKIdPoliza;

            SET @Id = @PKIdPoliza;
            SET @tipo = 'OK';
            SET @message = 'P�liza eliminada correctamente.';
        END
        ELSE IF @Action = 4
        BEGIN
            SELECT
                p.PKIdPoliza,
                p.FKIdAnio_SIS,
                a.Clave AS AnioClave,
                p.FKIdMes_SIS,
                p.FKIdTipoPoliza_SIS,
                tp.Descripcion AS TipoPoliza,
                p.ClavePoliza,
                p.NombrePoliza,
                p.FechaPoliza,
                p.EstaBalanceado,
                p.PermitirModificar,
                p.FKIdAccionAutorizar_SIS,
                p.Autorizado,
                p.FechaSolicitud,
                p.FechaAutorizacion,
                p.Activo,
                p.FechaCreacion,
                p.UsuarioCreacion,
                p.FechaModificacion,
                p.UsuarioModificacion
            FROM CONTA.Poliza p
            LEFT JOIN SIS.Anio a ON p.FKIdAnio_SIS = a.PKIdAnio
            LEFT JOIN SIS.TipoPoliza tp ON p.FKIdTipoPoliza_SIS = tp.PKIdTipoPoliza
            WHERE p.PKIdPoliza = @PKIdPoliza;

            SET @tipo = 'OK';
            GOTO FINISH;
        END
        ELSE
        BEGIN
            SET @tipo = 'ERROR';
            SET @message = 'Acci�n no v�lida. Use 1=Insert, 2=Update, 3=Delete, 4=GetById';
            GOTO ERR_HANDLER;
        END

        FINISH:
        IF @@TRANCOUNT > 0 AND XACT_STATE() = 1
            COMMIT TRANSACTION;

        SELECT JSON_QUERY(
            CONCAT('{"tipo":"', @tipo, '","mensaje":"', @message, '","liga":"idPoliza:', ISNULL(CAST(@Id AS NVARCHAR), ''), '"}')
        ) AS ResultJson;

        RETURN 0;

        ERR_HANDLER:
        IF @@TRANCOUNT > 0
        BEGIN
            IF XACT_STATE() = 1
                ROLLBACK TRANSACTION;
            ELSE IF XACT_STATE() = -1
                ROLLBACK TRANSACTION;
        END

        SELECT @errorMessage = CONCAT(
            ISNULL(PROGRAM_NAME(), ''), CHAR(10),
            'Error: ', ERROR_MESSAGE(), CHAR(10),
            'Línea: ', ERROR_LINE()
        );

        SELECT JSON_QUERY(
            CONCAT('{"tipo":"ERROR","mensaje":"', @errorMessage, '","liga":""}')
        ) AS ResultJson;

        RETURN -1;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            IF XACT_STATE() = 1
                ROLLBACK TRANSACTION;
            ELSE IF XACT_STATE() = -1
                ROLLBACK TRANSACTION;
        END

        SELECT @errorMessage = CONCAT(
            ISNULL(PROGRAM_NAME(), ''), CHAR(10),
            'Error: ', ERROR_MESSAGE(), CHAR(10),
            'Línea: ', ERROR_LINE()
        );

        SELECT JSON_QUERY(
            CONCAT('{"tipo":"ERROR","mensaje":"', @errorMessage, '","liga":""}')
        ) AS ResultJson;

        RETURN -1;
    END CATCH
END
GO
PRINT N'Creando Procedimiento [ORCO].[SP_MantenimientoRequisicion]...';


GO

CREATE   PROCEDURE [ORCO].[SP_MantenimientoRequisicion] (
    @Action INT,
    @PKIdRequisicion INT = NULL,
    @PKIdRequisicionDetalle INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdPersona_NOM INT = NULL,
    @FKIdArea_SIS INT = NULL,
    @Descripcion NVARCHAR(100) = NULL,
    @Observaciones NVARCHAR(1000) = NULL,
    @FechaRequisicion DATETIME = NULL,
    @Servicio BIT = NULL,
    @FL_FOTO NVARCHAR(1000) = NULL,
    @FKIdProyecto_ORCO INT = NULL,
    @FechaRequiereInicio DATETIME = NULL,
    @FechaRequiereFin DATETIME = NULL,
    @FKIdPrograma_PRES INT = NULL,
    @Importe DECIMAL(20,4) = NULL,
    @FKIdJefeAlmacen_NOM INT = NULL,
    @FKIdSuficiencia_PRES INT = NULL,
    @FKIdSuperviso_NOM INT = NULL,
    @FKIdAutorizo_NOM INT = NULL,
    @FKIdPSolicita_NOM INT = NULL,
    @FKIdPJefeAlmacen_NOM INT = NULL,
    @FKIdPSuficiencia_NOM INT = NULL,
    @FKIdPSuperviso_NOM INT = NULL,
    @FKIdPAutorizo_NOM INT = NULL,
    @FKIdFuenteFinanciamiento_PRES INT = NULL,
    @FKIdAnio_SIS INT = NULL,
    @FKIdTipoGasto_PRES INT = NULL,
    @FKIdDigitoIdentificador_PRES INT = NULL,
    @FKIdDestinoGasto_PRES INT = NULL,
    @FKIdEgresoAutorizado_PRES INT = NULL,
    @Oficio VARCHAR(120) = NULL,
    @FechaOficio DATETIME = NULL,
    @CompraDirecta BIT = NULL,
    @FKIdTipoBien_ALMA INT = NULL,
    @FKIdUnidades_ALMA INT = NULL,
    @Cantidad NUMERIC(8,2) = NULL,
    @IdUser INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(20) = 'OK', @message NVARCHAR(4000) = '', @Parameters NVARCHAR(4000) = '', @liga NVARCHAR(100) = '', @today DATETIME2 = SYSDATETIME(), @Id INT;

    SET @message = CONCAT('Iniciando el SP [ORCO].[SP_MantenimientoRequisicion]', ' @PKIdRequisicion ', @PKIdRequisicion);
    SET @Parameters = CONCAT(
        'Action=', ISNULL(CONVERT(NVARCHAR(30), @Action), 'NULL'),
        ', PKIdRequisicion=', ISNULL(CONVERT(NVARCHAR(30), @PKIdRequisicion), 'NULL'),
        ', PKIdRequisicionDetalle=', ISNULL(CONVERT(NVARCHAR(30), @PKIdRequisicionDetalle), 'NULL'),
        ', FKIdEmpresa_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdEmpresa_SIS), 'NULL'),
        ', FKIdPersona_NOM=', ISNULL(CONVERT(NVARCHAR(30), @FKIdPersona_NOM), 'NULL'),
        ', FKIdArea_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdArea_SIS), 'NULL'),
        ', Descripcion=', ISNULL(LEFT(@Descripcion, 300), 'NULL'),
        ', FechaRequisicion=', ISNULL(CONVERT(NVARCHAR(30), @FechaRequisicion, 126), 'NULL'),
        ', Servicio=', ISNULL(CONVERT(NVARCHAR(30), @Servicio), 'NULL'),
        ', FKIdProyecto_ORCO=', ISNULL(CONVERT(NVARCHAR(30), @FKIdProyecto_ORCO), 'NULL'),
        ', FKIdPrograma_PRES=', ISNULL(CONVERT(NVARCHAR(30), @FKIdPrograma_PRES), 'NULL'),
        ', Importe=', ISNULL(CONVERT(NVARCHAR(30), @Importe), 'NULL'),
        ', FKIdFuenteFinanciamiento_PRES=', ISNULL(CONVERT(NVARCHAR(30), @FKIdFuenteFinanciamiento_PRES), 'NULL'),
        ', FKIdAnio_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdAnio_SIS), 'NULL'),
        ', Oficio=', ISNULL(@Oficio, 'NULL'),
        ', FechaOficio=', ISNULL(CONVERT(NVARCHAR(30), @FechaOficio, 126), 'NULL'),
        ', CompraDirecta=', ISNULL(CONVERT(NVARCHAR(30), @CompraDirecta), 'NULL'),
        ', FKIdTipoBien_ALMA=', ISNULL(CONVERT(NVARCHAR(30), @FKIdTipoBien_ALMA), 'NULL'),
        ', FKIdUnidades_ALMA=', ISNULL(CONVERT(NVARCHAR(30), @FKIdUnidades_ALMA), 'NULL'),
        ', Cantidad=', ISNULL(CONVERT(NVARCHAR(30), @Cantidad), 'NULL'),
        ', IdUser=', ISNULL(CONVERT(NVARCHAR(30), @IdUser), 'NULL')
    );
    EXEC [SIS].[WriteSystemLog]
        @FK_IdOrigenLogMessage__SIS = 1,
        @Date = @today,
        @_Type = 1,
        @ProgName = 'ORCO.SP_MantenimientoRequisicion',
        @EmployeeNo = @IdUser,
        @Category = NULL,
        @IPClient = NULL,
        @HostName = NULL,
        @Thread = NULL,
        @Level = 'INFO',
        @Logger = NULL,
        @Message = @message,
        @Exception = NULL,
        @Context = NULL,
        @MethodName = 'ORCO.SP_MantenimientoRequisicion',
        @Parameters = @Parameters,
        @ExecutionTime = '0';

    SET @message = '';

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action IN (2, 3, 4, 5, 6) AND @PKIdRequisicion IS NOT NULL
           AND EXISTS (SELECT 1 FROM ORCO.Cotizacion WHERE FKIdRequisicion_ORCO = @PKIdRequisicion AND Activo = 1)
            THROW 51000, 'La requisicion ya esta vinculada a una cotizacion activa. Liberala para poder modificarla.', 1;

        IF @Action = 1
        BEGIN
            INSERT INTO ORCO.Requisicion (
                FKIdEmpresa_SIS, FKIdPersona_NOM, FKIdArea_SIS, Descripcion, Observaciones, FechaRequisicion,
                Servicio, FL_FOTO, FKIdProyecto_ORCO, FechaRequiereInicio, FechaRequiereFin, FKIdPrograma_PRES,
                Importe, FKIdJefeAlmacen_NOM, FKIdSuficiencia_PRES, FKIdSuperviso_NOM, FKIdAutorizo_NOM,
                FKIdPSolicita_NOM, FKIdPJefeAlmacen_NOM, FKIdPSuficiencia_NOM, FKIdPSuperviso_NOM, FKIdPAutorizo_NOM,
                FKIdFuenteFinanciamiento_PRES, FKIdAnio_SIS, FKIdTipoGasto_PRES, FKIdDigitoIdentificador_PRES,
                FKIdDestinoGasto_PRES, FKIdEgresoAutorizado_PRES, Oficio, FechaOficio, CompraDirecta,
                Activo, FechaCreacion, UsuarioCreacion
            )
            VALUES (
                @FKIdEmpresa_SIS, @FKIdPersona_NOM, @FKIdArea_SIS, @Descripcion, @Observaciones, ISNULL(@FechaRequisicion, GETDATE()),
                ISNULL(@Servicio, 0), @FL_FOTO, @FKIdProyecto_ORCO, @FechaRequiereInicio, @FechaRequiereFin, @FKIdPrograma_PRES,
                @Importe, @FKIdJefeAlmacen_NOM, @FKIdSuficiencia_PRES, @FKIdSuperviso_NOM, @FKIdAutorizo_NOM,
                @FKIdPSolicita_NOM, @FKIdPJefeAlmacen_NOM, @FKIdPSuficiencia_NOM, @FKIdPSuperviso_NOM, @FKIdPAutorizo_NOM,
                @FKIdFuenteFinanciamiento_PRES, @FKIdAnio_SIS, @FKIdTipoGasto_PRES, @FKIdDigitoIdentificador_PRES,
                @FKIdDestinoGasto_PRES, @FKIdEgresoAutorizado_PRES, @Oficio, @FechaOficio, @CompraDirecta,
                1, @today, @IdUser
            );
            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Requisicion creada correctamente.';
            SET @liga = CONCAT('idRequisicion:', @Id);
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdRequisicion IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.Requisicion WHERE PKIdRequisicion = @PKIdRequisicion AND Activo = 1)
                THROW 51000, 'Requisicion no encontrada.', 1;

            UPDATE ORCO.Requisicion
            SET FKIdEmpresa_SIS = @FKIdEmpresa_SIS,
                FKIdPersona_NOM = @FKIdPersona_NOM,
                FKIdArea_SIS = @FKIdArea_SIS,
                Descripcion = @Descripcion,
                Observaciones = @Observaciones,
                FechaRequisicion = ISNULL(@FechaRequisicion, FechaRequisicion),
                Servicio = ISNULL(@Servicio, Servicio),
                FL_FOTO = @FL_FOTO,
                FKIdProyecto_ORCO = @FKIdProyecto_ORCO,
                FechaRequiereInicio = @FechaRequiereInicio,
                FechaRequiereFin = @FechaRequiereFin,
                FKIdPrograma_PRES = @FKIdPrograma_PRES,
                Importe = @Importe,
                FKIdJefeAlmacen_NOM = @FKIdJefeAlmacen_NOM,
                FKIdSuficiencia_PRES = @FKIdSuficiencia_PRES,
                FKIdSuperviso_NOM = @FKIdSuperviso_NOM,
                FKIdAutorizo_NOM = @FKIdAutorizo_NOM,
                FKIdPSolicita_NOM = @FKIdPSolicita_NOM,
                FKIdPJefeAlmacen_NOM = @FKIdPJefeAlmacen_NOM,
                FKIdPSuficiencia_NOM = @FKIdPSuficiencia_NOM,
                FKIdPSuperviso_NOM = @FKIdPSuperviso_NOM,
                FKIdPAutorizo_NOM = @FKIdPAutorizo_NOM,
                FKIdFuenteFinanciamiento_PRES = @FKIdFuenteFinanciamiento_PRES,
                FKIdAnio_SIS = @FKIdAnio_SIS,
                FKIdTipoGasto_PRES = @FKIdTipoGasto_PRES,
                FKIdDigitoIdentificador_PRES = @FKIdDigitoIdentificador_PRES,
                FKIdDestinoGasto_PRES = @FKIdDestinoGasto_PRES,
                FKIdEgresoAutorizado_PRES = @FKIdEgresoAutorizado_PRES,
                Oficio = @Oficio,
                FechaOficio = @FechaOficio,
                CompraDirecta = @CompraDirecta,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdRequisicion = @PKIdRequisicion;

            SET @Id = @PKIdRequisicion;
            SET @message = 'Requisicion actualizada correctamente.';
            SET @liga = CONCAT('idRequisicion:', @Id);
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdRequisicion IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.Requisicion WHERE PKIdRequisicion = @PKIdRequisicion AND Activo = 1)
                THROW 51000, 'Requisicion no encontrada.', 1;

            UPDATE ORCO.RequisicionDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE FKIdRequisicion_ORCO = @PKIdRequisicion AND Activo = 1;
            UPDATE ORCO.RequisicionPartida SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE FKIdRequisicion_ORCO = @PKIdRequisicion AND Activo = 1;
            UPDATE ORCO.Requisicion SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdRequisicion = @PKIdRequisicion;

            SET @Id = @PKIdRequisicion;
            SET @message = 'Requisicion eliminada correctamente.';
            SET @liga = CONCAT('idRequisicion:', @Id);
        END
        ELSE IF @Action IN (4, 5)
        BEGIN
            IF @PKIdRequisicion IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.Requisicion WHERE PKIdRequisicion = @PKIdRequisicion AND Activo = 1)
                THROW 51000, 'Requisicion no encontrada.', 1;

            IF ISNULL(@Cantidad, 0) <= 0
                THROW 51000, 'La cantidad debe ser mayor a cero.', 1;

            IF EXISTS (
                SELECT 1 FROM ORCO.RequisicionDetalle
                WHERE FKIdRequisicion_ORCO = @PKIdRequisicion
                  AND FKIdTipoBien_ALMA = @FKIdTipoBien_ALMA
                  AND Activo = 1
                  AND (@Action = 4 OR PKIdRequisicionDetalle <> @PKIdRequisicionDetalle)
            )
                THROW 51000, 'Ya existe un renglon activo con el mismo bien en esta requisicion.', 1;

            IF @Action = 4
            BEGIN
                INSERT INTO ORCO.RequisicionDetalle (
                    FKIdEmpresa_SIS, FKIdRequisicion_ORCO, FKIdTipoBien_ALMA, FKIdUnidades_ALMA,
                    Cantidad, Observaciones, Activo, FechaCreacion, UsuarioCreacion
                )
                SELECT r.FKIdEmpresa_SIS, r.PKIdRequisicion, @FKIdTipoBien_ALMA, ISNULL(@FKIdUnidades_ALMA, tb.FKIdUnidades_ALMA),
                       @Cantidad, ISNULL(@Observaciones, ''), 1, @today, @IdUser
                FROM ORCO.Requisicion r
                INNER JOIN ALMA.TipoBien tb ON tb.PKIdTipoBien = @FKIdTipoBien_ALMA AND tb.Activo = 1
                WHERE r.PKIdRequisicion = @PKIdRequisicion;

                SET @Id = SCOPE_IDENTITY();
                SET @message = 'Detalle de requisicion creado correctamente.';
            END
            ELSE
            BEGIN
                IF @PKIdRequisicionDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.RequisicionDetalle WHERE PKIdRequisicionDetalle = @PKIdRequisicionDetalle AND Activo = 1)
                    THROW 51000, 'Detalle de requisicion no encontrado.', 1;

                UPDATE rd
                SET FKIdTipoBien_ALMA = @FKIdTipoBien_ALMA,
                    FKIdUnidades_ALMA = ISNULL(@FKIdUnidades_ALMA, tb.FKIdUnidades_ALMA),
                    Cantidad = @Cantidad,
                    Observaciones = ISNULL(@Observaciones, ''),
                    FechaModificacion = @today,
                    UsuarioModificacion = @IdUser
                FROM ORCO.RequisicionDetalle rd
                INNER JOIN ALMA.TipoBien tb ON tb.PKIdTipoBien = @FKIdTipoBien_ALMA AND tb.Activo = 1
                WHERE rd.PKIdRequisicionDetalle = @PKIdRequisicionDetalle;

                SET @Id = @PKIdRequisicionDetalle;
                SET @message = 'Detalle de requisicion actualizado correctamente.';
            END
            SET @liga = CONCAT('idRequisicionDetalle:', @Id);
        END
        ELSE IF @Action = 6
        BEGIN
            IF @PKIdRequisicionDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.RequisicionDetalle WHERE PKIdRequisicionDetalle = @PKIdRequisicionDetalle AND Activo = 1)
                THROW 51000, 'Detalle de requisicion no encontrado.', 1;

            UPDATE ORCO.RequisicionDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdRequisicionDetalle = @PKIdRequisicionDetalle;
            SET @Id = @PKIdRequisicionDetalle;
            SET @message = 'Detalle de requisicion eliminado correctamente.';
            SET @liga = CONCAT('idRequisicionDetalle:', @Id);
        END
        ELSE
            THROW 51000, 'Accion no valida para requisicion.', 1;

        COMMIT TRANSACTION;
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, @liga AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @tipo = 'ERROR';
        SET @message = CONCAT(ISNULL(PROGRAM_NAME(), ''), CHAR(10), 'Error: ', ERROR_MESSAGE(), CHAR(10), 'Linea: ', ERROR_LINE());
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, '' AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN -1;
    END CATCH
END
GO
PRINT N'Creando Procedimiento [ORCO].[SP_MantenimientoPAAAS]...';


GO

CREATE   PROCEDURE [ORCO].[SP_MantenimientoPAAAS] (
    @Action INT,
    @PKIdPAAAS INT = NULL,
    @PKIdPAAASPartida INT = NULL,
    @PKIdPAAASDetalle INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdAnio_SIS INT = NULL,
    @FKIdArea_SIS INT = NULL,
    @FKIdPersona_NOM INT = NULL,
    @Descripcion NVARCHAR(100) = NULL,
    @Observaciones NVARCHAR(MAX) = NULL,
    @Fecha DATETIME = NULL,
    @FKIdProyecto_ORCO INT = NULL,
    @FKIdPrograma_PRES INT = NULL,
    @FKIdFuenteFinanciamiento_PRES INT = NULL,
    @FKIdPartida_CONTA INT = NULL,
    @FKIdTipoBien_ALMA INT = NULL,
    @FKIdUnidades_ALMA INT = NULL,
    @Cantidad NUMERIC(8,2) = NULL,
    @LugarEntrega VARCHAR(200) = NULL,
    @IdUser INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(20) = 'OK';
    DECLARE @message NVARCHAR(4000) = '';
    DECLARE @Parameters NVARCHAR(4000) = '';
    DECLARE @liga NVARCHAR(100) = '';
    DECLARE @today DATETIME2 = SYSDATETIME();
    DECLARE @Id INT = NULL;

    SET @message = CONCAT('Iniciando el SP [ORCO].[SP_MantenimientoPAAAS]', ' @PKIdPAAAS ', @PKIdPAAAS);
    SET @Parameters = CONCAT(
        'Action=', ISNULL(CONVERT(NVARCHAR(30), @Action), 'NULL'),
        ', PKIdPAAAS=', ISNULL(CONVERT(NVARCHAR(30), @PKIdPAAAS), 'NULL'),
        ', PKIdPAAASPartida=', ISNULL(CONVERT(NVARCHAR(30), @PKIdPAAASPartida), 'NULL'),
        ', PKIdPAAASDetalle=', ISNULL(CONVERT(NVARCHAR(30), @PKIdPAAASDetalle), 'NULL'),
        ', FKIdEmpresa_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdEmpresa_SIS), 'NULL'),
        ', FKIdAnio_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdAnio_SIS), 'NULL'),
        ', FKIdArea_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdArea_SIS), 'NULL'),
        ', FKIdPersona_NOM=', ISNULL(CONVERT(NVARCHAR(30), @FKIdPersona_NOM), 'NULL'),
        ', Descripcion=', ISNULL(LEFT(@Descripcion, 300), 'NULL'),
        ', Fecha=', ISNULL(CONVERT(NVARCHAR(30), @Fecha, 126), 'NULL'),
        ', FKIdPartida_CONTA=', ISNULL(CONVERT(NVARCHAR(30), @FKIdPartida_CONTA), 'NULL'),
        ', FKIdTipoBien_ALMA=', ISNULL(CONVERT(NVARCHAR(30), @FKIdTipoBien_ALMA), 'NULL'),
        ', Cantidad=', ISNULL(CONVERT(NVARCHAR(30), @Cantidad), 'NULL'),
        ', IdUser=', ISNULL(CONVERT(NVARCHAR(30), @IdUser), 'NULL')
    );
    EXEC [SIS].[WriteSystemLog]
        @FK_IdOrigenLogMessage__SIS = 1,
        @Date = @today,
        @_Type = 1,
        @ProgName = 'ORCO.SP_MantenimientoPAAAS',
        @EmployeeNo = @IdUser,
        @Category = NULL,
        @IPClient = NULL,
        @HostName = NULL,
        @Thread = NULL,
        @Level = 'INFO',
        @Logger = NULL,
        @Message = @message,
        @Exception = NULL,
        @Context = NULL,
        @MethodName = 'ORCO.SP_MantenimientoPAAAS',
        @Parameters = @Parameters,
        @ExecutionTime = '0';

    SET @message = '';

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            IF EXISTS (SELECT 1 FROM ORCO.PAAAS WHERE FKIdArea_SIS = @FKIdArea_SIS AND FKIdAnio_SIS = @FKIdAnio_SIS AND Activo = 1)
                THROW 51000, 'Ya existe un programa anual activo para el mismo anio y area.', 1;

            INSERT INTO ORCO.PAAAS (
                FKIdEmpresa_SIS, FKIdAnio_SIS, FKIdArea_SIS, FKIdPersona_NOM,
                Descripcion, Observaciones, Fecha, FKIdProyecto_ORCO,
                FKIdPrograma_PRES, FKIdFuenteFinanciamiento_PRES,
                Activo, FechaCreacion, UsuarioCreacion
            )
            VALUES (
                @FKIdEmpresa_SIS, @FKIdAnio_SIS, @FKIdArea_SIS, @FKIdPersona_NOM,
                @Descripcion, @Observaciones, ISNULL(@Fecha, GETDATE()), @FKIdProyecto_ORCO,
                @FKIdPrograma_PRES, @FKIdFuenteFinanciamiento_PRES,
                1, @today, @IdUser
            );

            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Programa anual creado correctamente.';
            SET @liga = CONCAT('idPAAAS:', @Id);
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdPAAAS IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.PAAAS WHERE PKIdPAAAS = @PKIdPAAAS AND Activo = 1)
                THROW 51000, 'Programa anual no encontrado.', 1;

            IF EXISTS (SELECT 1 FROM ORCO.PAAAS WHERE FKIdArea_SIS = @FKIdArea_SIS AND FKIdAnio_SIS = @FKIdAnio_SIS AND PKIdPAAAS <> @PKIdPAAAS AND Activo = 1)
                THROW 51000, 'Ya existe otro programa anual activo para el mismo anio y area.', 1;

            UPDATE ORCO.PAAAS
            SET FKIdEmpresa_SIS = @FKIdEmpresa_SIS,
                FKIdAnio_SIS = @FKIdAnio_SIS,
                FKIdArea_SIS = @FKIdArea_SIS,
                FKIdPersona_NOM = @FKIdPersona_NOM,
                Descripcion = @Descripcion,
                Observaciones = @Observaciones,
                Fecha = ISNULL(@Fecha, Fecha),
                FKIdProyecto_ORCO = @FKIdProyecto_ORCO,
                FKIdPrograma_PRES = @FKIdPrograma_PRES,
                FKIdFuenteFinanciamiento_PRES = @FKIdFuenteFinanciamiento_PRES,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdPAAAS = @PKIdPAAAS;

            SET @Id = @PKIdPAAAS;
            SET @message = 'Programa anual actualizado correctamente.';
            SET @liga = CONCAT('idPAAAS:', @Id);
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdPAAAS IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.PAAAS WHERE PKIdPAAAS = @PKIdPAAAS AND Activo = 1)
                THROW 51000, 'Programa anual no encontrado.', 1;

            UPDATE d SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser
            FROM ORCO.PAAASDetalle d
            INNER JOIN ORCO.PAAASPartida p ON d.FKIdPAAASPartida_ORCO = p.PKIdPAAASPartida
            WHERE p.FKIdPAAAS_ORCO = @PKIdPAAAS AND d.Activo = 1;

            UPDATE ORCO.PAAASPartida
            SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser
            WHERE FKIdPAAAS_ORCO = @PKIdPAAAS AND Activo = 1;

            UPDATE ORCO.PAAAS
            SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser
            WHERE PKIdPAAAS = @PKIdPAAAS;

            SET @Id = @PKIdPAAAS;
            SET @message = 'Programa anual eliminado correctamente.';
            SET @liga = CONCAT('idPAAAS:', @Id);
        END
        ELSE IF @Action = 5
        BEGIN
            IF @PKIdPAAAS IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.PAAAS WHERE PKIdPAAAS = @PKIdPAAAS AND Activo = 1)
                THROW 51000, 'PAAAS no encontrado.', 1;

            IF EXISTS (SELECT 1 FROM ORCO.PAAASPartida WHERE FKIdPAAAS_ORCO = @PKIdPAAAS AND FKIdPartida_CONTA = @FKIdPartida_CONTA AND Activo = 1)
                THROW 51000, 'La partida ya esta agregada en este PAAAS.', 1;

            INSERT INTO ORCO.PAAASPartida (FKIdEmpresa_SIS, FKIdPAAAS_ORCO, FKIdPartida_CONTA, Observaciones, Activo, FechaCreacion, UsuarioCreacion)
            SELECT ISNULL(@FKIdEmpresa_SIS, FKIdEmpresa_SIS), PKIdPAAAS, @FKIdPartida_CONTA, @Observaciones, 1, @today, @IdUser
            FROM ORCO.PAAAS
            WHERE PKIdPAAAS = @PKIdPAAAS;

            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Partida creada correctamente.';
            SET @liga = CONCAT('idPAAASPartida:', @Id);
        END
        ELSE IF @Action = 6
        BEGIN
            IF @PKIdPAAASPartida IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.PAAASPartida WHERE PKIdPAAASPartida = @PKIdPAAASPartida AND Activo = 1)
                THROW 51000, 'Partida no encontrada.', 1;

            UPDATE ORCO.PAAASDetalle
            SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser
            WHERE FKIdPAAASPartida_ORCO = @PKIdPAAASPartida AND Activo = 1;

            UPDATE ORCO.PAAASPartida
            SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser
            WHERE PKIdPAAASPartida = @PKIdPAAASPartida;

            SET @Id = @PKIdPAAASPartida;
            SET @message = 'Partida eliminada correctamente.';
            SET @liga = CONCAT('idPAAASPartida:', @Id);
        END
        ELSE IF @Action IN (7, 8)
        BEGIN
            DECLARE @PartidaConta INT, @EmpresaPartida INT, @UnidadTipoBien INT, @TipoPartida INT;

            IF @Action = 8 AND (@PKIdPAAASDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.PAAASDetalle WHERE PKIdPAAASDetalle = @PKIdPAAASDetalle AND Activo = 1))
                THROW 51000, 'Detalle no encontrado.', 1;

            SELECT @PartidaConta = pp.FKIdPartida_CONTA, @EmpresaPartida = pp.FKIdEmpresa_SIS
            FROM ORCO.PAAASPartida pp
            WHERE pp.PKIdPAAASPartida = @PKIdPAAASPartida AND pp.Activo = 1;

            IF @PartidaConta IS NULL
                THROW 51000, 'Partida no encontrada.', 1;

            SELECT @UnidadTipoBien = FKIdUnidades_ALMA, @TipoPartida = FKIdPartida_CONTA
            FROM ALMA.TipoBien
            WHERE PKIdTipoBien = @FKIdTipoBien_ALMA AND Activo = 1;

            IF @TipoPartida IS NULL
                THROW 51000, 'Tipo de bien no encontrado.', 1;

            IF @TipoPartida <> @PartidaConta
                THROW 51000, 'El tipo de bien no pertenece a la partida seleccionada.', 1;

            IF ISNULL(@Cantidad, 0) <= 0
                THROW 51000, 'La cantidad debe ser mayor a cero.', 1;

            IF @Action = 7
            BEGIN
                INSERT INTO ORCO.PAAASDetalle (
                    FKIdEmpresa_SIS, FKIdPAAASPartida_ORCO, FKIdTipoBien_ALMA, FKIdUnidades_ALMA,
                    Cantidad, Observaciones, LugarEntrega, Activo, FechaCreacion, UsuarioCreacion
                )
                VALUES (
                    ISNULL(@FKIdEmpresa_SIS, @EmpresaPartida), @PKIdPAAASPartida, @FKIdTipoBien_ALMA, ISNULL(@FKIdUnidades_ALMA, @UnidadTipoBien),
                    @Cantidad, ISNULL(@Observaciones, ''), ISNULL(@LugarEntrega, ''), 1, @today, @IdUser
                );

                SET @Id = SCOPE_IDENTITY();
                SET @message = 'Tipo de bien agregado correctamente.';
            END
            ELSE
            BEGIN
                UPDATE ORCO.PAAASDetalle
                SET FKIdEmpresa_SIS = ISNULL(@FKIdEmpresa_SIS, @EmpresaPartida),
                    FKIdPAAASPartida_ORCO = @PKIdPAAASPartida,
                    FKIdTipoBien_ALMA = @FKIdTipoBien_ALMA,
                    FKIdUnidades_ALMA = ISNULL(@FKIdUnidades_ALMA, @UnidadTipoBien),
                    Cantidad = @Cantidad,
                    Observaciones = ISNULL(@Observaciones, ''),
                    LugarEntrega = ISNULL(@LugarEntrega, ''),
                    FechaModificacion = @today,
                    UsuarioModificacion = @IdUser
                WHERE PKIdPAAASDetalle = @PKIdPAAASDetalle;

                SET @Id = @PKIdPAAASDetalle;
                SET @message = 'Tipo de bien actualizado correctamente.';
            END

            SET @liga = CONCAT('idPAAASDetalle:', @Id);
        END
        ELSE IF @Action = 9
        BEGIN
            IF @PKIdPAAASDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.PAAASDetalle WHERE PKIdPAAASDetalle = @PKIdPAAASDetalle AND Activo = 1)
                THROW 51000, 'Detalle no encontrado.', 1;

            UPDATE ORCO.PAAASDetalle
            SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser
            WHERE PKIdPAAASDetalle = @PKIdPAAASDetalle;

            SET @Id = @PKIdPAAASDetalle;
            SET @message = 'Tipo de bien eliminado correctamente.';
            SET @liga = CONCAT('idPAAASDetalle:', @Id);
        END
        ELSE
            THROW 51000, 'Accion no valida para PAAAS.', 1;

        COMMIT TRANSACTION;

        SELECT (SELECT @tipo AS tipo, @message AS mensaje, @liga AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @tipo = 'ERROR';
        SET @message = CONCAT(ISNULL(PROGRAM_NAME(), ''), CHAR(10), 'Error: ', ERROR_MESSAGE(), CHAR(10), 'Linea: ', ERROR_LINE());
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, '' AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN -1;
    END CATCH
END
GO
PRINT N'Creando Procedimiento [ORCO].[SP_MantenimientoCotizacion]...';


GO

CREATE   PROCEDURE [ORCO].[SP_MantenimientoCotizacion] (
    @Action INT,
    @PKIdCotizacion INT = NULL,
    @FKIdRequisicion_ORCO INT = NULL,
    @FKIdProveedor_SIS INT = NULL,
    @FechaSolicitud DATETIME = NULL,
    @FechaProveedorCotiza DATETIME = NULL,
    @FechaProveedorCompromiso DATETIME = NULL,
    @Comentarios NVARCHAR(MAX) = NULL,
    @Servicio BIT = NULL,
    @FL_Documento NVARCHAR(1000) = NULL,
    @Entrega NVARCHAR(MAX) = NULL,
    @Vigencia NVARCHAR(MAX) = NULL,
    @Condiciones NVARCHAR(200) = NULL,
    @FKIdAnio_SIS INT = NULL,
    @FKIdContenedorCot_ORCO INT = NULL,
    @FKIdContenedorMultiCot_ORCO INT = NULL,
    @ItemsJson NVARCHAR(MAX) = NULL,
    @IdUser INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(20) = 'OK', @message NVARCHAR(4000) = '', @Parameters NVARCHAR(4000) = '', @liga NVARCHAR(100) = '', @today DATETIME2 = SYSDATETIME(), @Id INT;
    DECLARE @Seeded INT = 0;

    SET @message = CONCAT('Iniciando el SP [ORCO].[SP_MantenimientoCotizacion]', ' @PKIdCotizacion ', @PKIdCotizacion);
    SET @Parameters = CONCAT(
        'Action=', ISNULL(CONVERT(NVARCHAR(30), @Action), 'NULL'),
        ', PKIdCotizacion=', ISNULL(CONVERT(NVARCHAR(30), @PKIdCotizacion), 'NULL'),
        ', FKIdRequisicion_ORCO=', ISNULL(CONVERT(NVARCHAR(30), @FKIdRequisicion_ORCO), 'NULL'),
        ', FKIdProveedor_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdProveedor_SIS), 'NULL'),
        ', FechaSolicitud=', ISNULL(CONVERT(NVARCHAR(30), @FechaSolicitud, 126), 'NULL'),
        ', FechaProveedorCotiza=', ISNULL(CONVERT(NVARCHAR(30), @FechaProveedorCotiza, 126), 'NULL'),
        ', FechaProveedorCompromiso=', ISNULL(CONVERT(NVARCHAR(30), @FechaProveedorCompromiso, 126), 'NULL'),
        ', Servicio=', ISNULL(CONVERT(NVARCHAR(30), @Servicio), 'NULL'),
        ', FKIdAnio_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdAnio_SIS), 'NULL'),
        ', FKIdContenedorCot_ORCO=', ISNULL(CONVERT(NVARCHAR(30), @FKIdContenedorCot_ORCO), 'NULL'),
        ', FKIdContenedorMultiCot_ORCO=', ISNULL(CONVERT(NVARCHAR(30), @FKIdContenedorMultiCot_ORCO), 'NULL'),
        ', IdUser=', ISNULL(CONVERT(NVARCHAR(30), @IdUser), 'NULL')
    );
    EXEC [SIS].[WriteSystemLog]
        @FK_IdOrigenLogMessage__SIS = 1,
        @Date = @today,
        @_Type = 1,
        @ProgName = 'ORCO.SP_MantenimientoCotizacion',
        @EmployeeNo = @IdUser,
        @Category = NULL,
        @IPClient = NULL,
        @HostName = NULL,
        @Thread = NULL,
        @Level = 'INFO',
        @Logger = NULL,
        @Message = @message,
        @Exception = NULL,
        @Context = NULL,
        @MethodName = 'ORCO.SP_MantenimientoCotizacion',
        @Parameters = @Parameters,
        @ExecutionTime = '0';

    SET @message = '';

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM ORCO.Requisicion WHERE PKIdRequisicion = @FKIdRequisicion_ORCO AND Activo = 1)
                THROW 51000, 'La requisicion no existe o esta inactiva.', 1;
            IF NOT EXISTS (SELECT 1 FROM SIS.Proveedor WHERE PKIdProveedor = @FKIdProveedor_SIS AND Activo = 1)
                THROW 51000, 'El proveedor no existe o esta inactivo.', 1;
            IF NOT EXISTS (SELECT 1 FROM ORCO.RequisicionDetalle WHERE FKIdRequisicion_ORCO = @FKIdRequisicion_ORCO AND Activo = 1)
                THROW 51000, 'La requisicion debe tener al menos un bien para generar una cotizacion.', 1;

            INSERT INTO ORCO.Cotizacion (
                FKIdRequisicion_ORCO, FKIdProveedor_SIS, FechaSolicitud, FechaProveedorCotiza, FechaProveedorCompromiso,
                Comentarios, Servicio, FL_Documento, Entrega, Vigencia, Condiciones, FKIdAnio_SIS,
                FKIdContenedorCot_ORCO, FKIdContenedorMultiCot_ORCO, Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT @FKIdRequisicion_ORCO, @FKIdProveedor_SIS, ISNULL(@FechaSolicitud, GETDATE()), @FechaProveedorCotiza, @FechaProveedorCompromiso,
                   ISNULL(@Comentarios, ''), r.Servicio, ISNULL(@FL_Documento, ''), ISNULL(@Entrega, ''), ISNULL(@Vigencia, ''), ISNULL(@Condiciones, ''),
                   ISNULL(@FKIdAnio_SIS, r.FKIdAnio_SIS), @FKIdContenedorCot_ORCO, @FKIdContenedorMultiCot_ORCO, 1, @today, @IdUser
            FROM ORCO.Requisicion r
            WHERE r.PKIdRequisicion = @FKIdRequisicion_ORCO;

            SET @Id = SCOPE_IDENTITY();

            INSERT INTO ORCO.CotizacionDetalle (FKIdCotizacion_ORCO, FKIdRequisicionDetalle_ORCO, PrecioUnitario, Activo, FechaCreacion, UsuarioCreacion)
            SELECT @Id, rd.PKIdRequisicionDetalle, NULL, 1, @today, @IdUser
            FROM ORCO.RequisicionDetalle rd
            WHERE rd.FKIdRequisicion_ORCO = @FKIdRequisicion_ORCO
              AND rd.Activo = 1;

            SET @Seeded = @@ROWCOUNT;
            SET @message = CONCAT('Cotizacion creada correctamente con ', @Seeded, ' bienes cargados desde la requisicion.');
            SET @liga = CONCAT('idCotizacion:', @Id);
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdCotizacion IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.Cotizacion WHERE PKIdCotizacion = @PKIdCotizacion AND Activo = 1)
                THROW 51000, 'Cotizacion no encontrada.', 1;
            IF NOT EXISTS (SELECT 1 FROM SIS.Proveedor WHERE PKIdProveedor = @FKIdProveedor_SIS AND Activo = 1)
                THROW 51000, 'El proveedor no existe o esta inactivo.', 1;

            UPDATE ORCO.Cotizacion
            SET FKIdRequisicion_ORCO = @FKIdRequisicion_ORCO,
                FKIdProveedor_SIS = @FKIdProveedor_SIS,
                FechaSolicitud = ISNULL(@FechaSolicitud, FechaSolicitud),
                FechaProveedorCotiza = @FechaProveedorCotiza,
                FechaProveedorCompromiso = @FechaProveedorCompromiso,
                Comentarios = ISNULL(@Comentarios, ''),
                Servicio = ISNULL(@Servicio, Servicio),
                FL_Documento = ISNULL(@FL_Documento, ''),
                Entrega = ISNULL(@Entrega, ''),
                Vigencia = ISNULL(@Vigencia, ''),
                Condiciones = ISNULL(@Condiciones, ''),
                FKIdAnio_SIS = @FKIdAnio_SIS,
                FKIdContenedorCot_ORCO = @FKIdContenedorCot_ORCO,
                FKIdContenedorMultiCot_ORCO = @FKIdContenedorMultiCot_ORCO,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdCotizacion = @PKIdCotizacion;

            SET @Id = @PKIdCotizacion;
            SET @message = 'Cotizacion actualizada correctamente.';
            SET @liga = CONCAT('idCotizacion:', @Id);
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdCotizacion IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.Cotizacion WHERE PKIdCotizacion = @PKIdCotizacion AND Activo = 1)
                THROW 51000, 'Cotizacion no encontrada.', 1;

            UPDATE ORCO.CotizacionDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE FKIdCotizacion_ORCO = @PKIdCotizacion AND Activo = 1;
            UPDATE ORCO.Cotizacion SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdCotizacion = @PKIdCotizacion;

            SET @Id = @PKIdCotizacion;
            SET @message = 'Cotizacion eliminada correctamente.';
            SET @liga = CONCAT('idCotizacion:', @Id);
        END
        ELSE IF @Action = 4
        BEGIN
            IF @PKIdCotizacion IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.Cotizacion WHERE PKIdCotizacion = @PKIdCotizacion AND Activo = 1)
                THROW 51000, 'Cotizacion no encontrada.', 1;
            IF ISJSON(@ItemsJson) <> 1
                THROW 51000, 'No hay bienes cotizados para guardar.', 1;
            IF EXISTS (SELECT 1 FROM OPENJSON(@ItemsJson) WITH (PrecioUnitario DECIMAL(20,4) '$.PrecioUnitario') WHERE PrecioUnitario <= 0)
                THROW 51000, 'Los precios capturados deben ser mayores a cero.', 1;

            DECLARE @Items TABLE (PKIdCotizacionDetalle INT PRIMARY KEY, PrecioUnitario DECIMAL(20,4) NULL);
            INSERT INTO @Items (PKIdCotizacionDetalle, PrecioUnitario)
            SELECT PKIdCotizacionDetalle, PrecioUnitario
            FROM OPENJSON(@ItemsJson)
            WITH (PKIdCotizacionDetalle INT '$.PkidCotizacionDetalle', PrecioUnitario DECIMAL(20,4) '$.PrecioUnitario')
            WHERE PKIdCotizacionDetalle > 0;

            IF NOT EXISTS (SELECT 1 FROM @Items)
                THROW 51000, 'No hay bienes cotizados para guardar.', 1;
            IF EXISTS (
                SELECT 1 FROM @Items i
                WHERE NOT EXISTS (
                    SELECT 1 FROM ORCO.CotizacionDetalle cd
                    WHERE cd.PKIdCotizacionDetalle = i.PKIdCotizacionDetalle
                      AND cd.FKIdCotizacion_ORCO = @PKIdCotizacion
                      AND cd.Activo = 1
                )
            )
                THROW 51000, 'Uno o mas bienes no pertenecen a la cotizacion seleccionada.', 1;

            UPDATE cd
            SET PrecioUnitario = i.PrecioUnitario,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            FROM ORCO.CotizacionDetalle cd
            INNER JOIN @Items i ON cd.PKIdCotizacionDetalle = i.PKIdCotizacionDetalle;

            IF EXISTS (SELECT 1 FROM @Items WHERE PrecioUnitario IS NOT NULL)
            BEGIN
                UPDATE ORCO.Cotizacion
                SET FechaProveedorCotiza = ISNULL(FechaProveedorCotiza, CONVERT(DATE, GETDATE())),
                    FechaModificacion = @today,
                    UsuarioModificacion = @IdUser
                WHERE PKIdCotizacion = @PKIdCotizacion;
            END

            SET @Id = @PKIdCotizacion;
            SET @message = 'Montos cotizados guardados correctamente.';
            SET @liga = CONCAT('idCotizacion:', @Id);
        END
        ELSE IF @Action = 5
        BEGIN
            IF @PKIdCotizacion IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.Cotizacion WHERE PKIdCotizacion = @PKIdCotizacion AND Activo = 1)
                THROW 51000, 'Cotizacion no encontrada.', 1;

            INSERT INTO ORCO.CotizacionDetalle (FKIdCotizacion_ORCO, FKIdRequisicionDetalle_ORCO, PrecioUnitario, Activo, FechaCreacion, UsuarioCreacion)
            SELECT c.PKIdCotizacion, rd.PKIdRequisicionDetalle, NULL, 1, @today, @IdUser
            FROM ORCO.Cotizacion c
            INNER JOIN ORCO.RequisicionDetalle rd ON rd.FKIdRequisicion_ORCO = c.FKIdRequisicion_ORCO AND rd.Activo = 1
            WHERE c.PKIdCotizacion = @PKIdCotizacion
              AND NOT EXISTS (
                  SELECT 1 FROM ORCO.CotizacionDetalle cd
                  WHERE cd.FKIdCotizacion_ORCO = c.PKIdCotizacion
                    AND cd.FKIdRequisicionDetalle_ORCO = rd.PKIdRequisicionDetalle
                    AND cd.Activo = 1
              );

            SET @Seeded = @@ROWCOUNT;
            SET @Id = @PKIdCotizacion;
            SET @message = CONCAT('Detalles de cotizacion sincronizados: ', @Seeded, '.');
            SET @liga = CONCAT('idCotizacion:', @Id);
        END
        ELSE
            THROW 51000, 'Accion no valida para cotizacion.', 1;

        COMMIT TRANSACTION;
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, @liga AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @tipo = 'ERROR';
        SET @message = CONCAT(ISNULL(PROGRAM_NAME(), ''), CHAR(10), 'Error: ', ERROR_MESSAGE(), CHAR(10), 'Linea: ', ERROR_LINE());
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, '' AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN -1;
    END CATCH
END
GO
PRINT N'Creando Procedimiento [ORCO].[SP_MantenimientoEstudioMercado]...';


GO

CREATE   PROCEDURE [ORCO].[SP_MantenimientoEstudioMercado] (
    @Action INT,
    @PKIdEstudioMercado INT = NULL,
    @PKIdEstudioMercadoDetalle INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdAnio_SIS INT = NULL,
    @Nombre VARCHAR(80) = NULL,
    @Descripcion NVARCHAR(500) = NULL,
    @FechaSolicitud DATETIME = NULL,
    @FechaCierre DATETIME = NULL,
    @FKIdResponsable_NOM INT = NULL,
    @Estatus INT = NULL,
    @FKIdPAAASDetalle_ORCO INT = NULL,
    @FKIdTipoBien_ALMA INT = NULL,
    @Cantidad NUMERIC(8,2) = NULL,
    @Observaciones NVARCHAR(MAX) = NULL,
    @FKIdProveedor_SIS INT = NULL,
    @CostoUnitario DECIMAL(20,4) = NULL,
    @FechaCompromisoEntrega DATETIME = NULL,
    @Comentarios NVARCHAR(MAX) = NULL,
    @ItemsJson NVARCHAR(MAX) = NULL,
    @ProveedorIdsJson NVARCHAR(MAX) = NULL,
    @IdUser INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(20) = 'OK', @message NVARCHAR(4000) = '', @Parameters NVARCHAR(4000) = '', @liga NVARCHAR(100) = '', @today DATETIME2 = SYSDATETIME(), @Id INT;

    SET @message = CONCAT('Iniciando el SP [ORCO].[SP_MantenimientoEstudioMercado]', ' @PKIdEstudioMercado ', @PKIdEstudioMercado);
    SET @Parameters = CONCAT(
        'Action=', ISNULL(CONVERT(NVARCHAR(30), @Action), 'NULL'),
        ', PKIdEstudioMercado=', ISNULL(CONVERT(NVARCHAR(30), @PKIdEstudioMercado), 'NULL'),
        ', PKIdEstudioMercadoDetalle=', ISNULL(CONVERT(NVARCHAR(30), @PKIdEstudioMercadoDetalle), 'NULL'),
        ', FKIdEmpresa_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdEmpresa_SIS), 'NULL'),
        ', FKIdAnio_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdAnio_SIS), 'NULL'),
        ', Nombre=', ISNULL(LEFT(@Nombre, 300), 'NULL'),
        ', FechaSolicitud=', ISNULL(CONVERT(NVARCHAR(30), @FechaSolicitud, 126), 'NULL'),
        ', FechaCierre=', ISNULL(CONVERT(NVARCHAR(30), @FechaCierre, 126), 'NULL'),
        ', FKIdResponsable_NOM=', ISNULL(CONVERT(NVARCHAR(30), @FKIdResponsable_NOM), 'NULL'),
        ', Estatus=', ISNULL(CONVERT(NVARCHAR(30), @Estatus), 'NULL'),
        ', FKIdPAAASDetalle_ORCO=', ISNULL(CONVERT(NVARCHAR(30), @FKIdPAAASDetalle_ORCO), 'NULL'),
        ', FKIdTipoBien_ALMA=', ISNULL(CONVERT(NVARCHAR(30), @FKIdTipoBien_ALMA), 'NULL'),
        ', Cantidad=', ISNULL(CONVERT(NVARCHAR(30), @Cantidad), 'NULL'),
        ', FKIdProveedor_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdProveedor_SIS), 'NULL'),
        ', CostoUnitario=', ISNULL(CONVERT(NVARCHAR(30), @CostoUnitario), 'NULL'),
        ', FechaCompromisoEntrega=', ISNULL(CONVERT(NVARCHAR(30), @FechaCompromisoEntrega, 126), 'NULL'),
        ', IdUser=', ISNULL(CONVERT(NVARCHAR(30), @IdUser), 'NULL')
    );
    EXEC [SIS].[WriteSystemLog]
        @FK_IdOrigenLogMessage__SIS = 1,
        @Date = @today,
        @_Type = 1,
        @ProgName = 'ORCO.SP_MantenimientoEstudioMercado',
        @EmployeeNo = @IdUser,
        @Category = NULL,
        @IPClient = NULL,
        @HostName = NULL,
        @Thread = NULL,
        @Level = 'INFO',
        @Logger = NULL,
        @Message = @message,
        @Exception = NULL,
        @Context = NULL,
        @MethodName = 'ORCO.SP_MantenimientoEstudioMercado',
        @Parameters = @Parameters,
        @ExecutionTime = '0';

    SET @message = '';

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            IF ISNULL(@FKIdEmpresa_SIS, 0) <= 0 OR ISNULL(@FKIdAnio_SIS, 0) <= 0 OR ISNULL(@FKIdResponsable_NOM, 0) <= 0 OR NULLIF(LTRIM(RTRIM(@Nombre)), '') IS NULL
                THROW 51000, 'Debe capturar empresa, anio, responsable y nombre del estudio.', 1;
            IF @FechaCierre IS NOT NULL AND @FechaCierre < ISNULL(@FechaSolicitud, CONVERT(DATE, GETDATE()))
                THROW 51000, 'La fecha de cierre no puede ser anterior a la solicitud.', 1;

            INSERT INTO ORCO.EstudioMercado (
                FKIdEmpresa_SIS, FKIdAnio_SIS, Nombre, Descripcion, FechaSolicitud, FechaCierre,
                FKIdResponsable_NOM, Estatus, Activo, FechaCreacion, UsuarioCreacion
            )
            VALUES (
                @FKIdEmpresa_SIS, @FKIdAnio_SIS, LTRIM(RTRIM(@Nombre)), @Descripcion, ISNULL(@FechaSolicitud, CONVERT(DATE, GETDATE())),
                @FechaCierre, @FKIdResponsable_NOM, ISNULL(NULLIF(@Estatus, 0), 1), 1, @today, @IdUser
            );

            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Estudio de mercado creado correctamente.';
            SET @liga = CONCAT('idEstudioMercado:', @Id);
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdEstudioMercado IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.EstudioMercado WHERE PKIdEstudioMercado = @PKIdEstudioMercado AND Activo = 1)
                THROW 51000, 'Estudio de mercado no encontrado.', 1;
            IF @FechaCierre IS NOT NULL AND @FechaCierre < ISNULL(@FechaSolicitud, CONVERT(DATE, GETDATE()))
                THROW 51000, 'La fecha de cierre no puede ser anterior a la solicitud.', 1;

            UPDATE ORCO.EstudioMercado
            SET FKIdEmpresa_SIS = @FKIdEmpresa_SIS,
                FKIdAnio_SIS = @FKIdAnio_SIS,
                Nombre = LTRIM(RTRIM(@Nombre)),
                Descripcion = @Descripcion,
                FechaSolicitud = ISNULL(@FechaSolicitud, FechaSolicitud),
                FechaCierre = @FechaCierre,
                FKIdResponsable_NOM = @FKIdResponsable_NOM,
                Estatus = ISNULL(NULLIF(@Estatus, 0), Estatus),
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdEstudioMercado = @PKIdEstudioMercado;

            SET @Id = @PKIdEstudioMercado;
            SET @message = 'Estudio de mercado actualizado correctamente.';
            SET @liga = CONCAT('idEstudioMercado:', @Id);
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdEstudioMercado IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.EstudioMercado WHERE PKIdEstudioMercado = @PKIdEstudioMercado AND Activo = 1)
                THROW 51000, 'Estudio de mercado no encontrado.', 1;

            UPDATE c
            SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser
            FROM ORCO.EstudioMercadoDetalleCosto c
            INNER JOIN ORCO.SolicitudCotizacion sc ON c.FKIdSolicitudCotizacion_ORCO = sc.PKIdSolicitudCotizacion
            WHERE sc.FKIdEstudioMercado_ORCO = @PKIdEstudioMercado AND c.Activo = 1;

            UPDATE ORCO.SolicitudCotizacion SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE FKIdEstudioMercado_ORCO = @PKIdEstudioMercado AND Activo = 1;
            UPDATE ORCO.EstudioMercadoDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE FKIdEstudioMercado_ORCO = @PKIdEstudioMercado AND Activo = 1;
            UPDATE ORCO.EstudioMercado SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdEstudioMercado = @PKIdEstudioMercado;

            SET @Id = @PKIdEstudioMercado;
            SET @message = 'Estudio de mercado eliminado correctamente.';
            SET @liga = CONCAT('idEstudioMercado:', @Id);
        END
        ELSE IF @Action IN (4, 5)
        BEGIN
            DECLARE @EstudioEmpresa INT, @EstudioAnio INT, @PaaasEmpresa INT, @PaaasAnio INT, @PaaasTipoBien INT, @PaaasCantidad NUMERIC(8,2), @PaaasObs NVARCHAR(MAX);

            SELECT @EstudioEmpresa = FKIdEmpresa_SIS, @EstudioAnio = FKIdAnio_SIS
            FROM ORCO.EstudioMercado
            WHERE PKIdEstudioMercado = @PKIdEstudioMercado AND Activo = 1;

            IF @EstudioEmpresa IS NULL
                THROW 51000, 'El estudio de mercado no existe o esta inactivo.', 1;

            SELECT @PaaasEmpresa = d.FKIdEmpresa_SIS,
                   @PaaasTipoBien = d.FKIdTipoBien_ALMA,
                   @PaaasCantidad = d.Cantidad,
                   @PaaasObs = d.Observaciones,
                   @PaaasAnio = p.FKIdAnio_SIS
            FROM ORCO.PAAASDetalle d
            INNER JOIN ORCO.PAAASPartida pp ON d.FKIdPAAASPartida_ORCO = pp.PKIdPAAASPartida AND pp.Activo = 1
            INNER JOIN ORCO.PAAAS p ON pp.FKIdPAAAS_ORCO = p.PKIdPAAAS AND p.Activo = 1
            WHERE d.PKIdPAAASDetalle = @FKIdPAAASDetalle_ORCO AND d.Activo = 1;

            IF @PaaasEmpresa IS NULL
                THROW 51000, 'El bien del PAAAS no existe o esta inactivo.', 1;
            IF @PaaasEmpresa <> @EstudioEmpresa
                THROW 51000, 'Los bienes seleccionados no pertenecen a la empresa del estudio.', 1;
            IF @PaaasAnio <> @EstudioAnio
                THROW 51000, 'Los bienes seleccionados no pertenecen al anio presupuestal del estudio.', 1;
            IF @CostoUnitario IS NOT NULL AND @CostoUnitario <= 0
                THROW 51000, 'El costo unitario debe ser mayor a cero.', 1;
            IF @FKIdProveedor_SIS IS NOT NULL AND NOT EXISTS (SELECT 1 FROM SIS.Proveedor WHERE PKIdProveedor = @FKIdProveedor_SIS AND Activo = 1)
                THROW 51000, 'El proveedor seleccionado no existe o esta inactivo.', 1;

            IF @Action = 4 AND @FKIdProveedor_SIS IS NOT NULL AND EXISTS (
                SELECT 1 FROM ORCO.EstudioMercadoDetalle
                WHERE FKIdEstudioMercado_ORCO = @PKIdEstudioMercado
                  AND FKIdTipoBien_ALMA = @PaaasTipoBien
                  AND FKIdProveedor_SIS = @FKIdProveedor_SIS
                  AND Activo = 1
            )
                THROW 51000, 'Ya existe un precio de mercado para este tipo de bien con el mismo proveedor.', 1;

            IF @Action = 4
            BEGIN
                INSERT INTO ORCO.EstudioMercadoDetalle (
                    FKIdEmpresa_SIS, FKIdEstudioMercado_ORCO, FKIdPAAASDetalle_ORCO, FKIdTipoBien_ALMA,
                    Cantidad, Observaciones, FKIdProveedor_SIS, CostoUnitario, Activo, FechaCreacion, UsuarioCreacion
                )
                VALUES (
                    @EstudioEmpresa, @PKIdEstudioMercado, @FKIdPAAASDetalle_ORCO, @PaaasTipoBien,
                    ISNULL(NULLIF(@Cantidad, 0), @PaaasCantidad), COALESCE(NULLIF(LTRIM(RTRIM(@Observaciones)), ''), @PaaasObs),
                    @FKIdProveedor_SIS, @CostoUnitario, 1, @today, @IdUser
                );
                SET @Id = SCOPE_IDENTITY();
                SET @message = 'Detalle de estudio de mercado creado correctamente.';
            END
            ELSE
            BEGIN
                IF @PKIdEstudioMercadoDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.EstudioMercadoDetalle WHERE PKIdEstudioMercadoDetalle = @PKIdEstudioMercadoDetalle AND Activo = 1)
                    THROW 51000, 'Detalle de estudio de mercado no encontrado.', 1;

                UPDATE ORCO.EstudioMercadoDetalle
                SET FKIdPAAASDetalle_ORCO = @FKIdPAAASDetalle_ORCO,
                    FKIdTipoBien_ALMA = @PaaasTipoBien,
                    Cantidad = ISNULL(NULLIF(@Cantidad, 0), @PaaasCantidad),
                    Observaciones = COALESCE(NULLIF(LTRIM(RTRIM(@Observaciones)), ''), @PaaasObs),
                    FKIdProveedor_SIS = @FKIdProveedor_SIS,
                    CostoUnitario = @CostoUnitario,
                    FechaModificacion = @today,
                    UsuarioModificacion = @IdUser
                WHERE PKIdEstudioMercadoDetalle = @PKIdEstudioMercadoDetalle;

                SET @Id = @PKIdEstudioMercadoDetalle;
                SET @message = 'Detalle de estudio de mercado actualizado correctamente.';
            END
            SET @liga = CONCAT('idEstudioMercadoDetalle:', @Id);
        END
        ELSE IF @Action = 6
        BEGIN
            IF @PKIdEstudioMercadoDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.EstudioMercadoDetalle WHERE PKIdEstudioMercadoDetalle = @PKIdEstudioMercadoDetalle AND Activo = 1)
                THROW 51000, 'Detalle de estudio de mercado no encontrado.', 1;
            UPDATE ORCO.EstudioMercadoDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdEstudioMercadoDetalle = @PKIdEstudioMercadoDetalle;
            SET @Id = @PKIdEstudioMercadoDetalle;
            SET @message = 'Detalle de estudio de mercado eliminado correctamente.';
            SET @liga = CONCAT('idEstudioMercadoDetalle:', @Id);
        END
        ELSE IF @Action = 10
        BEGIN
            IF ISJSON(@ItemsJson) <> 1
                THROW 51000, 'Debe seleccionar al menos un detalle PAAAS.', 1;
            IF NOT EXISTS (SELECT 1 FROM ORCO.EstudioMercado WHERE PKIdEstudioMercado = @PKIdEstudioMercado AND Activo = 1)
                THROW 51000, 'El estudio de mercado no existe o esta inactivo.', 1;

            DECLARE @Batch TABLE (FKIdPAAASDetalle_ORCO INT, FKIdProveedor_SIS INT, CostoUnitario DECIMAL(20,4), Observaciones NVARCHAR(MAX));
            INSERT INTO @Batch
            SELECT FKIdPAAASDetalle_ORCO, FKIdProveedor_SIS, CostoUnitario, Observaciones
            FROM OPENJSON(@ItemsJson)
            WITH (
                FKIdPAAASDetalle_ORCO INT '$.FkidPaaasdetalleOrco',
                FKIdProveedor_SIS INT '$.FkidProveedorSis',
                CostoUnitario DECIMAL(20,4) '$.CostoUnitario',
                Observaciones NVARCHAR(MAX) '$.Observaciones'
            )
            WHERE FKIdPAAASDetalle_ORCO > 0;

            IF NOT EXISTS (SELECT 1 FROM @Batch)
                THROW 51000, 'Debe seleccionar al menos un detalle PAAAS.', 1;
            IF EXISTS (SELECT 1 FROM @Batch WHERE ISNULL(FKIdProveedor_SIS, 0) <= 0)
                THROW 51000, 'Debe seleccionar proveedor para todos los detalles.', 1;
            IF EXISTS (SELECT 1 FROM @Batch WHERE ISNULL(CostoUnitario, 0) <= 0)
                THROW 51000, 'Todos los costos unitarios deben ser mayores a cero.', 1;
            IF EXISTS (SELECT 1 FROM @Batch b WHERE NOT EXISTS (SELECT 1 FROM SIS.Proveedor p WHERE p.PKIdProveedor = b.FKIdProveedor_SIS AND p.Activo = 1))
                THROW 51000, 'Uno o mas proveedores no existen o estan inactivos.', 1;

            INSERT INTO ORCO.EstudioMercadoDetalle (
                FKIdEmpresa_SIS, FKIdEstudioMercado_ORCO, FKIdPAAASDetalle_ORCO, FKIdTipoBien_ALMA,
                Cantidad, Observaciones, FKIdProveedor_SIS, CostoUnitario, Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT em.FKIdEmpresa_SIS, em.PKIdEstudioMercado, pd.PKIdPAAASDetalle, pd.FKIdTipoBien_ALMA,
                   pd.Cantidad, COALESCE(NULLIF(LTRIM(RTRIM(b.Observaciones)), ''), pd.Observaciones),
                   b.FKIdProveedor_SIS, b.CostoUnitario, 1, @today, @IdUser
            FROM @Batch b
            INNER JOIN ORCO.PAAASDetalle pd ON pd.PKIdPAAASDetalle = b.FKIdPAAASDetalle_ORCO AND pd.Activo = 1
            INNER JOIN ORCO.PAAASPartida pp ON pd.FKIdPAAASPartida_ORCO = pp.PKIdPAAASPartida AND pp.Activo = 1
            INNER JOIN ORCO.PAAAS p ON pp.FKIdPAAAS_ORCO = p.PKIdPAAAS AND p.Activo = 1
            INNER JOIN ORCO.EstudioMercado em ON em.PKIdEstudioMercado = @PKIdEstudioMercado AND em.Activo = 1
            WHERE pd.FKIdEmpresa_SIS = em.FKIdEmpresa_SIS
              AND p.FKIdAnio_SIS = em.FKIdAnio_SIS
              AND NOT EXISTS (
                  SELECT 1 FROM ORCO.EstudioMercadoDetalle ed
                  WHERE ed.FKIdEstudioMercado_ORCO = em.PKIdEstudioMercado
                    AND ed.FKIdTipoBien_ALMA = pd.FKIdTipoBien_ALMA
                    AND ed.FKIdProveedor_SIS = b.FKIdProveedor_SIS
                    AND ed.Activo = 1
              );

            SET @message = 'Detalles de estudio de mercado creados correctamente.';
            SET @liga = CONCAT('idEstudioMercado:', @PKIdEstudioMercado);
        END
        ELSE IF @Action = 20
        BEGIN
            IF ISJSON(@ItemsJson) <> 1 OR ISJSON(@ProveedorIdsJson) <> 1
                THROW 51000, 'Debe seleccionar bienes y proveedores para cotizar.', 1;

            DECLARE @CotItems TABLE (FKIdPAAASDetalle_ORCO INT PRIMARY KEY, Observaciones NVARCHAR(MAX));
            DECLARE @Proveedores TABLE (FKIdProveedor_SIS INT PRIMARY KEY);

            INSERT INTO @CotItems
            SELECT FKIdPAAASDetalle_ORCO, MAX(Observaciones)
            FROM OPENJSON(@ItemsJson)
            WITH (FKIdPAAASDetalle_ORCO INT '$.FkidPaaasdetalleOrco', Observaciones NVARCHAR(MAX) '$.Observaciones')
            WHERE FKIdPAAASDetalle_ORCO > 0
            GROUP BY FKIdPAAASDetalle_ORCO;

            INSERT INTO @Proveedores
            SELECT DISTINCT TRY_CONVERT(INT, value)
            FROM OPENJSON(@ProveedorIdsJson)
            WHERE TRY_CONVERT(INT, value) > 0;

            IF NOT EXISTS (SELECT 1 FROM @CotItems)
                THROW 51000, 'Debe seleccionar al menos un bien del PAAAS.', 1;
            IF NOT EXISTS (SELECT 1 FROM @Proveedores)
                THROW 51000, 'Debe seleccionar al menos un proveedor para cotizar.', 1;
            IF EXISTS (SELECT 1 FROM @Proveedores p WHERE NOT EXISTS (SELECT 1 FROM SIS.Proveedor pr WHERE pr.PKIdProveedor = p.FKIdProveedor_SIS AND pr.Activo = 1))
                THROW 51000, 'Uno o mas proveedores no existen o estan inactivos.', 1;

            DECLARE @DetalleByPaaas TABLE (FKIdPAAASDetalle_ORCO INT PRIMARY KEY, PKIdEstudioMercadoDetalle INT);

            INSERT INTO @DetalleByPaaas
            SELECT ed.FKIdPAAASDetalle_ORCO, ed.PKIdEstudioMercadoDetalle
            FROM ORCO.EstudioMercadoDetalle ed
            INNER JOIN @CotItems i ON ed.FKIdPAAASDetalle_ORCO = i.FKIdPAAASDetalle_ORCO
            WHERE ed.FKIdEstudioMercado_ORCO = @PKIdEstudioMercado AND ed.Activo = 1;

            INSERT INTO ORCO.EstudioMercadoDetalle (
                FKIdEmpresa_SIS, FKIdEstudioMercado_ORCO, FKIdPAAASDetalle_ORCO, FKIdTipoBien_ALMA,
                Cantidad, Observaciones, Activo, FechaCreacion, UsuarioCreacion
            )
            OUTPUT inserted.FKIdPAAASDetalle_ORCO, inserted.PKIdEstudioMercadoDetalle INTO @DetalleByPaaas
            SELECT em.FKIdEmpresa_SIS, em.PKIdEstudioMercado, pd.PKIdPAAASDetalle, pd.FKIdTipoBien_ALMA,
                   pd.Cantidad, COALESCE(NULLIF(LTRIM(RTRIM(i.Observaciones)), ''), pd.Observaciones),
                   1, @today, @IdUser
            FROM @CotItems i
            INNER JOIN ORCO.PAAASDetalle pd ON pd.PKIdPAAASDetalle = i.FKIdPAAASDetalle_ORCO AND pd.Activo = 1
            INNER JOIN ORCO.PAAASPartida pp ON pd.FKIdPAAASPartida_ORCO = pp.PKIdPAAASPartida AND pp.Activo = 1
            INNER JOIN ORCO.PAAAS p ON pp.FKIdPAAAS_ORCO = p.PKIdPAAAS AND p.Activo = 1
            INNER JOIN ORCO.EstudioMercado em ON em.PKIdEstudioMercado = @PKIdEstudioMercado AND em.Activo = 1
            WHERE pd.FKIdEmpresa_SIS = em.FKIdEmpresa_SIS
              AND p.FKIdAnio_SIS = em.FKIdAnio_SIS
              AND NOT EXISTS (SELECT 1 FROM @DetalleByPaaas d WHERE d.FKIdPAAASDetalle_ORCO = pd.PKIdPAAASDetalle);

            DECLARE @SolicitudByProveedor TABLE (FKIdProveedor_SIS INT PRIMARY KEY, PKIdSolicitudCotizacion INT);

            INSERT INTO @SolicitudByProveedor
            SELECT sc.FKIdProveedor_SIS, sc.PKIdSolicitudCotizacion
            FROM ORCO.SolicitudCotizacion sc
            INNER JOIN @Proveedores p ON sc.FKIdProveedor_SIS = p.FKIdProveedor_SIS
            WHERE sc.FKIdEstudioMercado_ORCO = @PKIdEstudioMercado AND sc.Activo = 1;

            INSERT INTO ORCO.SolicitudCotizacion (
                FKIdEmpresa_SIS, FKIdEstudioMercado_ORCO, FKIdProveedor_SIS, FechaSolicitud,
                FechaCompromisoEntrega, Comentarios, Estatus, Activo, FechaCreacion, UsuarioCreacion
            )
            OUTPUT inserted.FKIdProveedor_SIS, inserted.PKIdSolicitudCotizacion INTO @SolicitudByProveedor
            SELECT em.FKIdEmpresa_SIS, em.PKIdEstudioMercado, p.FKIdProveedor_SIS, @today,
                   @FechaCompromisoEntrega, NULLIF(LTRIM(RTRIM(@Comentarios)), ''), 1, 1, @today, @IdUser
            FROM @Proveedores p
            CROSS JOIN ORCO.EstudioMercado em
            WHERE em.PKIdEstudioMercado = @PKIdEstudioMercado
              AND em.Activo = 1
              AND NOT EXISTS (SELECT 1 FROM @SolicitudByProveedor s WHERE s.FKIdProveedor_SIS = p.FKIdProveedor_SIS);

            INSERT INTO ORCO.EstudioMercadoDetalleCosto (
                FKIdEmpresa_SIS, FKIdSolicitudCotizacion_ORCO, FKIdEstudioMercadoDetalle_ORCO,
                Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT em.FKIdEmpresa_SIS, s.PKIdSolicitudCotizacion, d.PKIdEstudioMercadoDetalle,
                   1, @today, @IdUser
            FROM @SolicitudByProveedor s
            CROSS JOIN @DetalleByPaaas d
            INNER JOIN ORCO.EstudioMercado em ON em.PKIdEstudioMercado = @PKIdEstudioMercado
            WHERE NOT EXISTS (
                SELECT 1 FROM ORCO.EstudioMercadoDetalleCosto c
                WHERE c.FKIdSolicitudCotizacion_ORCO = s.PKIdSolicitudCotizacion
                  AND c.FKIdEstudioMercadoDetalle_ORCO = d.PKIdEstudioMercadoDetalle
                  AND c.Activo = 1
            );

            SET @message = 'Solicitudes de cotizacion generadas correctamente.';
            SET @liga = CONCAT('idEstudioMercado:', @PKIdEstudioMercado);
        END
        ELSE IF @Action = 30
        BEGIN
            IF ISJSON(@ItemsJson) <> 1
                THROW 51000, 'No hay cotizaciones para guardar.', 1;

            DECLARE @Recepcion TABLE (PKIdEstudioMercadoDetalleCosto INT PRIMARY KEY, PrecioUnitario DECIMAL(20,4) NULL, TiempoEntregaDias INT NULL, Condiciones NVARCHAR(500) NULL);
            INSERT INTO @Recepcion
            SELECT PKIdEstudioMercadoDetalleCosto, PrecioUnitario, TiempoEntregaDias, Condiciones
            FROM OPENJSON(@ItemsJson)
            WITH (
                PKIdEstudioMercadoDetalleCosto INT '$.PkidEstudioMercadoDetalleCosto',
                PrecioUnitario DECIMAL(20,4) '$.PrecioUnitario',
                TiempoEntregaDias INT '$.TiempoEntregaDias',
                Condiciones NVARCHAR(500) '$.Condiciones'
            )
            WHERE PKIdEstudioMercadoDetalleCosto > 0;

            IF NOT EXISTS (SELECT 1 FROM @Recepcion)
                THROW 51000, 'No hay cotizaciones para guardar.', 1;
            IF EXISTS (SELECT 1 FROM @Recepcion WHERE PrecioUnitario <= 0)
                THROW 51000, 'Los precios capturados deben ser mayores a cero.', 1;
            IF EXISTS (SELECT 1 FROM @Recepcion WHERE TiempoEntregaDias < 0)
                THROW 51000, 'El tiempo de entrega no puede ser negativo.', 1;
            IF EXISTS (
                SELECT 1 FROM @Recepcion r
                WHERE NOT EXISTS (
                    SELECT 1
                    FROM ORCO.EstudioMercadoDetalleCosto c
                    INNER JOIN ORCO.SolicitudCotizacion sc ON c.FKIdSolicitudCotizacion_ORCO = sc.PKIdSolicitudCotizacion
                    WHERE c.PKIdEstudioMercadoDetalleCosto = r.PKIdEstudioMercadoDetalleCosto
                      AND c.Activo = 1
                      AND sc.Activo = 1
                      AND sc.FKIdEstudioMercado_ORCO = @PKIdEstudioMercado
                )
            )
                THROW 51000, 'Una o mas cotizaciones no existen o no pertenecen al estudio seleccionado.', 1;

            UPDATE c
            SET PrecioUnitario = r.PrecioUnitario,
                TiempoEntregaDias = CASE WHEN r.PrecioUnitario IS NOT NULL THEN r.TiempoEntregaDias ELSE NULL END,
                Condiciones = CASE WHEN r.PrecioUnitario IS NOT NULL THEN NULLIF(LTRIM(RTRIM(r.Condiciones)), '') ELSE NULL END,
                FechaRespuesta = CASE WHEN r.PrecioUnitario IS NOT NULL THEN ISNULL(c.FechaRespuesta, @today) ELSE NULL END,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            FROM ORCO.EstudioMercadoDetalleCosto c
            INNER JOIN @Recepcion r ON c.PKIdEstudioMercadoDetalleCosto = r.PKIdEstudioMercadoDetalleCosto;

            ;WITH Conteos AS (
                SELECT sc.PKIdSolicitudCotizacion,
                       COUNT(c.PKIdEstudioMercadoDetalleCosto) AS Total,
                       SUM(CASE WHEN c.PrecioUnitario IS NOT NULL THEN 1 ELSE 0 END) AS Recibidas
                FROM ORCO.SolicitudCotizacion sc
                INNER JOIN ORCO.EstudioMercadoDetalleCosto c ON sc.PKIdSolicitudCotizacion = c.FKIdSolicitudCotizacion_ORCO AND c.Activo = 1
                WHERE sc.FKIdEstudioMercado_ORCO = @PKIdEstudioMercado AND sc.Activo = 1
                GROUP BY sc.PKIdSolicitudCotizacion
            )
            UPDATE sc
            SET Estatus = CASE WHEN c.Recibidas = 0 THEN 1 WHEN c.Recibidas < c.Total THEN 2 ELSE 3 END,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            FROM ORCO.SolicitudCotizacion sc
            INNER JOIN Conteos c ON sc.PKIdSolicitudCotizacion = c.PKIdSolicitudCotizacion;

            SET @message = 'Cotizaciones guardadas correctamente.';
            SET @liga = CONCAT('idEstudioMercado:', @PKIdEstudioMercado);
        END
        ELSE
            THROW 51000, 'Accion no valida para estudio de mercado.', 1;

        COMMIT TRANSACTION;
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, @liga AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @tipo = 'ERROR';
        SET @message = CONCAT(ISNULL(PROGRAM_NAME(), ''), CHAR(10), 'Error: ', ERROR_MESSAGE(), CHAR(10), 'Linea: ', ERROR_LINE());
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, '' AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN -1;
    END CATCH
END
GO
PRINT N'Creando Procedimiento [PRES].[SP_MantenimientoSolicitudSuficiencia]...';


GO

CREATE   PROCEDURE [PRES].[SP_MantenimientoSolicitudSuficiencia] (
    @Action INT,
    @PKIdSolicitudSuficiencia INT = NULL,
    @FKIdRequisicion_ORCO INT = NULL,
    @FechaSolicitud DATE = NULL,
    @Justificacion NVARCHAR(1000) = NULL,
    @GastoNoProgramable VARCHAR(3) = NULL,
    @IdGastoNoProgramable INT = NULL,
    @IdCompromisoNomina INT = NULL,
    @Estatus INT = NULL,
    @PorcentajeAjuste DECIMAL(10,4) = 0,
    @IdUser INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(20) = 'OK', @message NVARCHAR(4000) = '' , @Parameters NVARCHAR(4000) = '', @liga NVARCHAR(100) = '', @today DATETIME2 = SYSDATETIME(), @Id INT;

    SET @message = CONCAT('Iniciando el SP [PRES].[SP_MantenimientoSolicitudSuficiencia]', ' @Estatus ' ,@Estatus)
    SET @Parameters = CONCAT('Action=', @Action, ', PKIdSolicitudSuficiencia=', @PKIdSolicitudSuficiencia, ', FKIdRequisicion_ORCO=', @FKIdRequisicion_ORCO, ', FechaSolicitud=', ISNULL(CONVERT(NVARCHAR(30), @FechaSolicitud, 126), 'NULL'), ', Justificacion=', ISNULL(@Justificacion, 'NULL'), ', GastoNoProgramable=', ISNULL(@GastoNoProgramable, 'NULL'), ', IdGastoNoProgramable=', ISNULL(CONVERT(NVARCHAR(30), @IdGastoNoProgramable), 'NULL'), ', IdCompromisoNomina=', ISNULL(CONVERT(NVARCHAR(30), @IdCompromisoNomina), 'NULL'), ', Estatus=', ISNULL(CONVERT(NVARCHAR(30), @Estatus), 'NULL'), ', PorcentajeAjuste=', CONVERT(NVARCHAR(30), @PorcentajeAjuste))
    EXEC [SIS].[WriteSystemLog] 
	    @FK_IdOrigenLogMessage__SIS  = 1
	    ,@Date = @today
	    ,@_Type = 1
	    ,@ProgName = 'PRES.SP_MantenimientoSolicitudSuficiencia'
	    ,@EmployeeNo = @IdUser
	    ,@Category  = NULL
	    ,@IPClient  = NULL
	    ,@HostName  = NULL
	    ,@Thread    = NULL 
	    ,@Level = 'INFO' 
	    ,@Logger  =NULL 
	    ,@Message = @message
	    ,@Exception  = null
	    ,@Context   = null
	    ,@MethodName = 'PRES.SP_MantenimientoSolicitudSuficiencia'
	    ,@Parameters = @Parameters
        ,@ExecutionTime = '0'


        SET @message = ''
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action IN (1, 2, 10) AND NOT EXISTS (SELECT 1 FROM ORCO.Requisicion WHERE PKIdRequisicion = @FKIdRequisicion_ORCO AND Activo = 1)
            THROW 51000, 'La requisicion no existe o esta inactiva.', 1;

        IF @Action = 1
        BEGIN
            INSERT INTO PRES.SolicitudSuficiencia (
                FKIdEmpresa_SIS, FKIdRequisicion_ORCO, FechaSolicitud, Justificacion,
                GastoNoProgramable, IdGastoNoProgramable, IdCompromisoNomina, Estatus,
                Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT FKIdEmpresa_SIS, PKIdRequisicion, ISNULL(@FechaSolicitud, CONVERT(DATE, GETDATE())), ISNULL(@Justificacion, ''),
                   @GastoNoProgramable, @IdGastoNoProgramable, @IdCompromisoNomina, ISNULL(NULLIF(@Estatus, 0), 1),
                   1, @today, @IdUser
            FROM ORCO.Requisicion
            WHERE PKIdRequisicion = @FKIdRequisicion_ORCO;

            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Solicitud de suficiencia creada correctamente.';
            SET @liga = CONCAT('idSolicitudSuficiencia:', @Id);
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdSolicitudSuficiencia IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.SolicitudSuficiencia WHERE PKIdSolicitudSuficiencia = @PKIdSolicitudSuficiencia AND Activo = 1)
                THROW 51000, 'Solicitud de suficiencia no encontrada.', 1;

            UPDATE ss
            SET FKIdEmpresa_SIS = r.FKIdEmpresa_SIS,
                FKIdRequisicion_ORCO = @FKIdRequisicion_ORCO,
                FechaSolicitud = ISNULL(@FechaSolicitud, ss.FechaSolicitud),
                Justificacion = ISNULL(@Justificacion, ''),
                GastoNoProgramable = @GastoNoProgramable,
                IdGastoNoProgramable = @IdGastoNoProgramable,
                IdCompromisoNomina = @IdCompromisoNomina,
                Estatus = ISNULL(NULLIF(@Estatus, 0), ss.Estatus),
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            FROM PRES.SolicitudSuficiencia ss
            INNER JOIN ORCO.Requisicion r ON r.PKIdRequisicion = @FKIdRequisicion_ORCO
            WHERE ss.PKIdSolicitudSuficiencia = @PKIdSolicitudSuficiencia;

            SET @Id = @PKIdSolicitudSuficiencia;
            SET @message = 'Solicitud de suficiencia actualizada correctamente.';
            SET @liga = CONCAT('idSolicitudSuficiencia:', @Id);
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdSolicitudSuficiencia IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.SolicitudSuficiencia WHERE PKIdSolicitudSuficiencia = @PKIdSolicitudSuficiencia AND Activo = 1)
                THROW 51000, 'Solicitud de suficiencia no encontrada.', 1;

            UPDATE PRES.SolicitudSuficienciaDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE FKIdSolicitudSuficiencia_PRES = @PKIdSolicitudSuficiencia AND Activo = 1;
            UPDATE PRES.SolicitudSuficiencia SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdSolicitudSuficiencia = @PKIdSolicitudSuficiencia;

            SET @Id = @PKIdSolicitudSuficiencia;
            SET @message = 'Solicitud de suficiencia eliminada correctamente.';
            SET @liga = CONCAT('idSolicitudSuficiencia:', @Id);
        END
        ELSE IF @Action = 10
        BEGIN
            IF @PorcentajeAjuste < 0
                THROW 51000, 'El porcentaje de ajuste no puede ser negativo.', 1;
            IF EXISTS (SELECT 1 FROM PRES.SolicitudSuficiencia WHERE FKIdRequisicion_ORCO = @FKIdRequisicion_ORCO AND Activo = 1)
                THROW 51000, 'Ya existe una solicitud de suficiencia activa para esta requisicion.', 1;
            IF NOT EXISTS (SELECT 1 FROM ORCO.RequisicionDetalle WHERE FKIdRequisicion_ORCO = @FKIdRequisicion_ORCO AND Activo = 1)
                THROW 51000, 'La requisicion debe tener al menos un bien para generar la solicitud.', 1;
            IF EXISTS (
                SELECT 1
                FROM ORCO.RequisicionDetalle rd
                INNER JOIN ALMA.TipoBien tb ON rd.FKIdTipoBien_ALMA = tb.PKIdTipoBien
                WHERE rd.FKIdRequisicion_ORCO = @FKIdRequisicion_ORCO
                  AND rd.Activo = 1
                  AND ISNULL(tb.FKIdPartida_CONTA, 0) <= 0
            )
                THROW 51000, 'Hay bienes sin partida presupuestal configurada.', 1;
            IF EXISTS (SELECT 1 FROM ORCO.RequisicionDetalle WHERE FKIdRequisicion_ORCO = @FKIdRequisicion_ORCO AND Activo = 1 AND Cantidad <= 0)
                THROW 51000, 'Todos los bienes de la requisicion deben tener cantidad mayor a cero.', 1;
            IF EXISTS (
                SELECT 1
                FROM ORCO.RequisicionDetalle rd
                WHERE rd.FKIdRequisicion_ORCO = @FKIdRequisicion_ORCO
                  AND rd.Activo = 1
                  AND NOT EXISTS (
                      SELECT 1
                      FROM ORCO.CotizacionDetalle cd
                      INNER JOIN ORCO.Cotizacion c ON cd.FKIdCotizacion_ORCO = c.PKIdCotizacion
                      WHERE c.FKIdRequisicion_ORCO = @FKIdRequisicion_ORCO
                        AND c.Activo = 1
                        AND cd.Activo = 1
                        AND cd.FKIdRequisicionDetalle_ORCO = rd.PKIdRequisicionDetalle
                        AND cd.PrecioUnitario > 0
                  )
            )
                THROW 51000, 'Todos los bienes deben tener al menos un monto cotizado.', 1;

            INSERT INTO PRES.SolicitudSuficiencia (
                FKIdEmpresa_SIS, FKIdRequisicion_ORCO, FechaSolicitud, Justificacion,
                GastoNoProgramable, IdGastoNoProgramable, IdCompromisoNomina, Estatus,
                Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT FKIdEmpresa_SIS, PKIdRequisicion, ISNULL(@FechaSolicitud, CONVERT(DATE, GETDATE())), ISNULL(@Justificacion, ''),
                   @GastoNoProgramable, @IdGastoNoProgramable, @IdCompromisoNomina, 1, 1, @today, @IdUser
            FROM ORCO.Requisicion
            WHERE PKIdRequisicion = @FKIdRequisicion_ORCO;

            SET @Id = SCOPE_IDENTITY();

            ;WITH Cotizaciones AS (
                SELECT
                    rd.PKIdRequisicionDetalle,
                    r.FKIdEmpresa_SIS,
                    r.FechaRequisicion,
                    tb.FKIdPartida_CONTA,
                    rd.Cantidad,
                    AVG(CAST(cd.PrecioUnitario * rd.Cantidad AS DECIMAL(20,4))) AS PromedioImporte,
                    COUNT(*) AS Cotizaciones
                FROM ORCO.Requisicion r
                INNER JOIN ORCO.RequisicionDetalle rd ON r.PKIdRequisicion = rd.FKIdRequisicion_ORCO AND rd.Activo = 1
                INNER JOIN ALMA.TipoBien tb ON rd.FKIdTipoBien_ALMA = tb.PKIdTipoBien AND tb.Activo = 1
                INNER JOIN ORCO.Cotizacion c ON r.PKIdRequisicion = c.FKIdRequisicion_ORCO AND c.Activo = 1
                INNER JOIN ORCO.CotizacionDetalle cd ON c.PKIdCotizacion = cd.FKIdCotizacion_ORCO AND cd.FKIdRequisicionDetalle_ORCO = rd.PKIdRequisicionDetalle AND cd.Activo = 1 AND cd.PrecioUnitario > 0
                WHERE r.PKIdRequisicion = @FKIdRequisicion_ORCO
                GROUP BY rd.PKIdRequisicionDetalle, r.FKIdEmpresa_SIS, r.FechaRequisicion, tb.FKIdPartida_CONTA, rd.Cantidad
            ),
            Importes AS (
                SELECT *,
                    ROUND(PromedioImporte * (1 + (@PorcentajeAjuste / 100.0)), 4) AS ImporteAjustado,
                    MONTH(FechaRequisicion) AS Mes
                FROM Cotizaciones
            )
            INSERT INTO PRES.SolicitudSuficienciaDetalle (
                FKIdEmpresa_SIS, FKIdSolicitudSuficiencia_PRES, FKIdRequisicionDetalle_ORCO, FKIdPartida_CONTA,
                Enero, Febrero, Marzo, Abril, Mayo, Junio, Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre,
                Observaciones, Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT FKIdEmpresa_SIS, @Id, PKIdRequisicionDetalle, FKIdPartida_CONTA,
                   CASE WHEN Mes = 1 THEN ImporteAjustado ELSE 0 END,
                   CASE WHEN Mes = 2 THEN ImporteAjustado ELSE 0 END,
                   CASE WHEN Mes = 3 THEN ImporteAjustado ELSE 0 END,
                   CASE WHEN Mes = 4 THEN ImporteAjustado ELSE 0 END,
                   CASE WHEN Mes = 5 THEN ImporteAjustado ELSE 0 END,
                   CASE WHEN Mes = 6 THEN ImporteAjustado ELSE 0 END,
                   CASE WHEN Mes = 7 THEN ImporteAjustado ELSE 0 END,
                   CASE WHEN Mes = 8 THEN ImporteAjustado ELSE 0 END,
                   CASE WHEN Mes = 9 THEN ImporteAjustado ELSE 0 END,
                   CASE WHEN Mes = 10 THEN ImporteAjustado ELSE 0 END,
                   CASE WHEN Mes = 11 THEN ImporteAjustado ELSE 0 END,
                   CASE WHEN Mes = 12 THEN ImporteAjustado ELSE 0 END,
                   CASE WHEN @PorcentajeAjuste = 0
                        THEN CONCAT('Promedio de ', Cotizaciones, ' cotizacion(es).')
                        ELSE CONCAT('Promedio de ', Cotizaciones, ' cotizacion(es) mas ', CONVERT(VARCHAR(32), CAST(@PorcentajeAjuste AS DECIMAL(10,2))), '% de ajuste.')
                   END,
                   1, @today, @IdUser
            FROM Importes;

            SET @message = 'Solicitud de suficiencia generada correctamente desde la requisicion.';
            SET @liga = CONCAT('idSolicitudSuficiencia:', @Id);
        END
        ELSE
            THROW 51000, 'Accion no valida para solicitud de suficiencia.', 1;

        COMMIT TRANSACTION;
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, @liga AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @tipo = 'ERROR';
        SET @message = CONCAT(ISNULL(PROGRAM_NAME(), ''), CHAR(10), 'Error: ', ERROR_MESSAGE(), CHAR(10), 'Linea: ', ERROR_LINE());
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, '' AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN -1;
    END CATCH
END
GO
PRINT N'Creando Procedimiento [PRES].[SP_MantenimientoContrato]...';


GO

CREATE   PROCEDURE [PRES].[SP_MantenimientoContrato] (
    @Action INT,
    @PKIdContrato INT = NULL,
    @PKIdContratoDetalle INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdAutorizacionSuficiencia_PRES INT = NULL,
    @FKIdProveedor_SIS INT = NULL,
    @FKIdPoliza_CONTA INT = NULL,
    @NumeroContrato NVARCHAR(50) = NULL,
    @Descripcion NVARCHAR(500) = NULL,
    @FechaContrato DATE = NULL,
    @FechaInicioVigencia DATE = NULL,
    @FechaFinVigencia DATE = NULL,
    @MontoTotal DECIMAL(20,4) = NULL,
    @PlazoEjecucion NVARCHAR(100) = NULL,
    @Observaciones NVARCHAR(MAX) = NULL,
    @Estatus INT = NULL,
    @FKIdAutorizacionSuficienciaDetalle_PRES INT = NULL,
    @FKIdPartida_CONTA INT = NULL,
    @Enero DECIMAL(20,4) = NULL,
    @Febrero DECIMAL(20,4) = NULL,
    @Marzo DECIMAL(20,4) = NULL,
    @Abril DECIMAL(20,4) = NULL,
    @Mayo DECIMAL(20,4) = NULL,
    @Junio DECIMAL(20,4) = NULL,
    @Julio DECIMAL(20,4) = NULL,
    @Agosto DECIMAL(20,4) = NULL,
    @Septiembre DECIMAL(20,4) = NULL,
    @Octubre DECIMAL(20,4) = NULL,
    @Noviembre DECIMAL(20,4) = NULL,
    @Diciembre DECIMAL(20,4) = NULL,
    @IdUser INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(20) = 'OK', @message NVARCHAR(4000) = '', @Parameters NVARCHAR(4000) = '', @liga NVARCHAR(100) = '', @today DATETIME2 = SYSDATETIME(), @Id INT;

    SET @message = CONCAT('Iniciando el SP [PRES].[SP_MantenimientoContrato]', ' @PKIdContrato ', @PKIdContrato);
    SET @Parameters = CONCAT('Action=', @Action, ', PKIdContrato=', ISNULL(CONVERT(NVARCHAR(30), @PKIdContrato), 'NULL'), ', PKIdContratoDetalle=', ISNULL(CONVERT(NVARCHAR(30), @PKIdContratoDetalle), 'NULL'), ', NumeroContrato=', ISNULL(@NumeroContrato, 'NULL'), ', IdUser=', ISNULL(CONVERT(NVARCHAR(30), @IdUser), 'NULL'));
    EXEC [SIS].[WriteSystemLog] @FK_IdOrigenLogMessage__SIS = 1, @Date = @today, @_Type = 1, @ProgName = 'PRES.SP_MantenimientoContrato', @EmployeeNo = @IdUser, @Category = NULL, @IPClient = NULL, @HostName = NULL, @Thread = NULL, @Level = 'INFO', @Logger = NULL, @Message = @message, @Exception = NULL, @Context = NULL, @MethodName = 'PRES.SP_MantenimientoContrato', @Parameters = @Parameters, @ExecutionTime = '0';
    SET @message = '';

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            IF @FechaFinVigencia IS NOT NULL AND @FechaInicioVigencia IS NOT NULL AND @FechaFinVigencia < @FechaInicioVigencia
                THROW 51000, 'La fecha fin de vigencia no puede ser anterior al inicio.', 1;

            INSERT INTO PRES.Contrato (
                FKIdEmpresa_SIS, FKIdAutorizacionSuficiencia_PRES, FKIdProveedor_SIS, FKIdPoliza_CONTA,
                NumeroContrato, Descripcion, FechaContrato, FechaInicioVigencia, FechaFinVigencia,
                MontoTotal, PlazoEjecucion, Observaciones, Estatus, Activo, FechaCreacion, UsuarioCreacion
            )
            VALUES (
                @FKIdEmpresa_SIS, @FKIdAutorizacionSuficiencia_PRES, @FKIdProveedor_SIS, @FKIdPoliza_CONTA,
                @NumeroContrato, @Descripcion, ISNULL(@FechaContrato, CONVERT(DATE, GETDATE())), @FechaInicioVigencia, @FechaFinVigencia,
                ISNULL(@MontoTotal, 0), @PlazoEjecucion, @Observaciones, ISNULL(NULLIF(@Estatus, 0), 1), 1, @today, @IdUser
            );
            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Contrato creado correctamente.';
            SET @liga = CONCAT('idContrato:', @Id);
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdContrato IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.Contrato WHERE PKIdContrato = @PKIdContrato AND Activo = 1)
                THROW 51000, 'Contrato no encontrado.', 1;
            IF @FechaFinVigencia IS NOT NULL AND @FechaInicioVigencia IS NOT NULL AND @FechaFinVigencia < @FechaInicioVigencia
                THROW 51000, 'La fecha fin de vigencia no puede ser anterior al inicio.', 1;

            UPDATE PRES.Contrato
            SET FKIdEmpresa_SIS = @FKIdEmpresa_SIS,
                FKIdAutorizacionSuficiencia_PRES = @FKIdAutorizacionSuficiencia_PRES,
                FKIdProveedor_SIS = @FKIdProveedor_SIS,
                FKIdPoliza_CONTA = @FKIdPoliza_CONTA,
                NumeroContrato = @NumeroContrato,
                Descripcion = @Descripcion,
                FechaContrato = ISNULL(@FechaContrato, FechaContrato),
                FechaInicioVigencia = @FechaInicioVigencia,
                FechaFinVigencia = @FechaFinVigencia,
                MontoTotal = ISNULL(@MontoTotal, 0),
                PlazoEjecucion = @PlazoEjecucion,
                Observaciones = @Observaciones,
                Estatus = ISNULL(NULLIF(@Estatus, 0), Estatus),
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdContrato = @PKIdContrato;
            SET @Id = @PKIdContrato;
            SET @message = 'Contrato actualizado correctamente.';
            SET @liga = CONCAT('idContrato:', @Id);
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdContrato IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.Contrato WHERE PKIdContrato = @PKIdContrato AND Activo = 1)
                THROW 51000, 'Contrato no encontrado.', 1;
            UPDATE PRES.ContratoDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE FKIdContrato_PRES = @PKIdContrato AND Activo = 1;
            UPDATE PRES.Contrato SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdContrato = @PKIdContrato;
            SET @Id = @PKIdContrato;
            SET @message = 'Contrato eliminado correctamente.';
            SET @liga = CONCAT('idContrato:', @Id);
        END
        ELSE IF @Action = 4
        BEGIN
            SELECT * FROM PRES.Vw_Contrato WHERE PKIdContrato = @PKIdContrato;
            SET @message = 'Contrato consultado correctamente.';
            SET @liga = CONCAT('idContrato:', @PKIdContrato);
        END
        ELSE IF @Action = 5
        BEGIN
            IF @PKIdContrato IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.Contrato WHERE PKIdContrato = @PKIdContrato AND Activo = 1)
                THROW 51000, 'Contrato no encontrado.', 1;

            INSERT INTO PRES.ContratoDetalle (
                FKIdEmpresa_SIS, FKIdContrato_PRES, FKIdAutorizacionSuficienciaDetalle_PRES, FKIdPartida_CONTA,
                Enero, Febrero, Marzo, Abril, Mayo, Junio, Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre,
                Observaciones, Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT ISNULL(@FKIdEmpresa_SIS, c.FKIdEmpresa_SIS), @PKIdContrato, @FKIdAutorizacionSuficienciaDetalle_PRES, @FKIdPartida_CONTA,
                   ISNULL(@Enero,0), ISNULL(@Febrero,0), ISNULL(@Marzo,0), ISNULL(@Abril,0), ISNULL(@Mayo,0), ISNULL(@Junio,0),
                   ISNULL(@Julio,0), ISNULL(@Agosto,0), ISNULL(@Septiembre,0), ISNULL(@Octubre,0), ISNULL(@Noviembre,0), ISNULL(@Diciembre,0),
                   @Observaciones, 1, @today, @IdUser
            FROM PRES.Contrato c
            WHERE c.PKIdContrato = @PKIdContrato;
            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Detalle de contrato creado correctamente.';
            SET @liga = CONCAT('idContratoDetalle:', @Id);
        END
        ELSE IF @Action = 6
        BEGIN
            IF @PKIdContratoDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.ContratoDetalle WHERE PKIdContratoDetalle = @PKIdContratoDetalle AND Activo = 1)
                THROW 51000, 'Detalle de contrato no encontrado.', 1;

            UPDATE PRES.ContratoDetalle
            SET FKIdAutorizacionSuficienciaDetalle_PRES = @FKIdAutorizacionSuficienciaDetalle_PRES,
                FKIdPartida_CONTA = @FKIdPartida_CONTA,
                Enero = ISNULL(@Enero,0), Febrero = ISNULL(@Febrero,0), Marzo = ISNULL(@Marzo,0), Abril = ISNULL(@Abril,0),
                Mayo = ISNULL(@Mayo,0), Junio = ISNULL(@Junio,0), Julio = ISNULL(@Julio,0), Agosto = ISNULL(@Agosto,0),
                Septiembre = ISNULL(@Septiembre,0), Octubre = ISNULL(@Octubre,0), Noviembre = ISNULL(@Noviembre,0), Diciembre = ISNULL(@Diciembre,0),
                Observaciones = @Observaciones,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdContratoDetalle = @PKIdContratoDetalle;
            SET @Id = @PKIdContratoDetalle;
            SET @message = 'Detalle de contrato actualizado correctamente.';
            SET @liga = CONCAT('idContratoDetalle:', @Id);
        END
        ELSE IF @Action = 7
        BEGIN
            IF @PKIdContratoDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.ContratoDetalle WHERE PKIdContratoDetalle = @PKIdContratoDetalle AND Activo = 1)
                THROW 51000, 'Detalle de contrato no encontrado.', 1;
            UPDATE PRES.ContratoDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdContratoDetalle = @PKIdContratoDetalle;
            SET @Id = @PKIdContratoDetalle;
            SET @message = 'Detalle de contrato eliminado correctamente.';
            SET @liga = CONCAT('idContratoDetalle:', @Id);
        END
        ELSE IF @Action = 8
        BEGIN
            SELECT * FROM PRES.Vw_ContratoDetalle WHERE PKIdContratoDetalle = @PKIdContratoDetalle;
            SET @message = 'Detalle de contrato consultado correctamente.';
            SET @liga = CONCAT('idContratoDetalle:', @PKIdContratoDetalle);
        END
        ELSE
            THROW 51000, 'Accion no valida para contrato.', 1;

        COMMIT TRANSACTION;
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, @liga AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @tipo = 'ERROR';
        SET @message = CONCAT(ISNULL(PROGRAM_NAME(), ''), CHAR(10), 'Error: ', ERROR_MESSAGE(), CHAR(10), 'Linea: ', ERROR_LINE());
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, '' AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN -1;
    END CATCH
END
GO
PRINT N'Creando Procedimiento [PRES].[SP_MantenimientoAutorizacionSuficiencia]...';


GO

CREATE   PROCEDURE [PRES].[SP_MantenimientoAutorizacionSuficiencia] (
    @Action INT,
    @PKIdAutorizacionSuficiencia INT = NULL,
    @PKIdAutorizacionSuficienciaDetalle INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdSolicitudSuficiencia_PRES INT = NULL,
    @FechaAutorizacion DATE = NULL,
    @Justificacion NVARCHAR(1000) = NULL,
    @GastoNoProgramable VARCHAR(3) = NULL,
    @IdGastoNoProgramable INT = NULL,
    @IdCompromisoNomina INT = NULL,
    @AutorizadoPor_NOM INT = NULL,
    @Observaciones NVARCHAR(MAX) = NULL,
    @Estatus INT = NULL,
    @FKIdSolicitudSuficienciaDetalle_PRES INT = NULL,
    @FKIdPartida_CONTA INT = NULL,
    @Enero DECIMAL(20,4) = NULL,
    @Febrero DECIMAL(20,4) = NULL,
    @Marzo DECIMAL(20,4) = NULL,
    @Abril DECIMAL(20,4) = NULL,
    @Mayo DECIMAL(20,4) = NULL,
    @Junio DECIMAL(20,4) = NULL,
    @Julio DECIMAL(20,4) = NULL,
    @Agosto DECIMAL(20,4) = NULL,
    @Septiembre DECIMAL(20,4) = NULL,
    @Octubre DECIMAL(20,4) = NULL,
    @Noviembre DECIMAL(20,4) = NULL,
    @Diciembre DECIMAL(20,4) = NULL,
    @IdUser INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(20) = 'OK', @message NVARCHAR(4000) = '', @Parameters NVARCHAR(4000) = '', @liga NVARCHAR(100) = '', @today DATETIME2 = SYSDATETIME(), @Id INT;

    SET @message = CONCAT('Iniciando el SP [PRES].[SP_MantenimientoAutorizacionSuficiencia]', ' @Estatus ', @Estatus);
    SET @Parameters = CONCAT(
        'Action=', @Action,
        ', PKIdAutorizacionSuficiencia=', ISNULL(CONVERT(NVARCHAR(30), @PKIdAutorizacionSuficiencia), 'NULL'),
        ', PKIdAutorizacionSuficienciaDetalle=', ISNULL(CONVERT(NVARCHAR(30), @PKIdAutorizacionSuficienciaDetalle), 'NULL'),
        ', FKIdSolicitudSuficiencia_PRES=', ISNULL(CONVERT(NVARCHAR(30), @FKIdSolicitudSuficiencia_PRES), 'NULL'),
        ', FechaAutorizacion=', ISNULL(CONVERT(NVARCHAR(30), @FechaAutorizacion, 126), 'NULL'),
        ', AutorizadoPor_NOM=', ISNULL(CONVERT(NVARCHAR(30), @AutorizadoPor_NOM), 'NULL'),
        ', Estatus=', ISNULL(CONVERT(NVARCHAR(30), @Estatus), 'NULL')
    );
    EXEC [SIS].[WriteSystemLog]
        @FK_IdOrigenLogMessage__SIS = 1,
        @Date = @today,
        @_Type = 1,
        @ProgName = 'PRES.SP_MantenimientoAutorizacionSuficiencia',
        @EmployeeNo = @IdUser,
        @Category = NULL,
        @IPClient = NULL,
        @HostName = NULL,
        @Thread = NULL,
        @Level = 'INFO',
        @Logger = NULL,
        @Message = @message,
        @Exception = NULL,
        @Context = NULL,
        @MethodName = 'PRES.SP_MantenimientoAutorizacionSuficiencia',
        @Parameters = @Parameters,
        @ExecutionTime = '0';
    SET @message = '';

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action IN (1, 2, 10)
        BEGIN
            IF @FKIdSolicitudSuficiencia_PRES IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.SolicitudSuficiencia WHERE PKIdSolicitudSuficiencia = @FKIdSolicitudSuficiencia_PRES AND Activo = 1)
                THROW 51000, 'Solicitud de suficiencia no encontrada.', 1;
            IF @AutorizadoPor_NOM IS NULL OR NOT EXISTS (SELECT 1 FROM NOM.Persona WHERE PKIdPersona = @AutorizadoPor_NOM AND Activo = 1)
                THROW 51000, 'La persona autorizadora no existe o esta inactiva.', 1;
        END

        IF @Action = 1
        BEGIN
            INSERT INTO PRES.AutorizacionSuficiencia (
                FKIdEmpresa_SIS, FKIdSolicitudSuficiencia_PRES, FechaAutorizacion, Justificacion,
                GastoNoProgramable, IdGastoNoProgramable, IdCompromisoNomina, AutorizadoPor_NOM,
                Observaciones, Estatus, Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT ISNULL(@FKIdEmpresa_SIS, ss.FKIdEmpresa_SIS), ss.PKIdSolicitudSuficiencia, ISNULL(@FechaAutorizacion, CONVERT(DATE, GETDATE())),
                   ISNULL(@Justificacion, ss.Justificacion), ISNULL(@GastoNoProgramable, ss.GastoNoProgramable),
                   ISNULL(@IdGastoNoProgramable, ss.IdGastoNoProgramable), ISNULL(@IdCompromisoNomina, ss.IdCompromisoNomina),
                   @AutorizadoPor_NOM, @Observaciones, ISNULL(NULLIF(@Estatus, 0), 1), 1, @today, @IdUser
            FROM PRES.SolicitudSuficiencia ss
            WHERE ss.PKIdSolicitudSuficiencia = @FKIdSolicitudSuficiencia_PRES;

            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Autorizacion de suficiencia creada correctamente.';
            SET @liga = CONCAT('idAutorizacionSuficiencia:', @Id);
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdAutorizacionSuficiencia IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.AutorizacionSuficiencia WHERE PKIdAutorizacionSuficiencia = @PKIdAutorizacionSuficiencia AND Activo = 1)
                THROW 51000, 'Autorizacion de suficiencia no encontrada.', 1;

            UPDATE aus
            SET FKIdEmpresa_SIS = ISNULL(@FKIdEmpresa_SIS, ss.FKIdEmpresa_SIS),
                FKIdSolicitudSuficiencia_PRES = @FKIdSolicitudSuficiencia_PRES,
                FechaAutorizacion = ISNULL(@FechaAutorizacion, aus.FechaAutorizacion),
                Justificacion = ISNULL(@Justificacion, ss.Justificacion),
                GastoNoProgramable = ISNULL(@GastoNoProgramable, ss.GastoNoProgramable),
                IdGastoNoProgramable = ISNULL(@IdGastoNoProgramable, ss.IdGastoNoProgramable),
                IdCompromisoNomina = ISNULL(@IdCompromisoNomina, ss.IdCompromisoNomina),
                AutorizadoPor_NOM = @AutorizadoPor_NOM,
                Observaciones = @Observaciones,
                Estatus = ISNULL(NULLIF(@Estatus, 0), aus.Estatus),
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            FROM PRES.AutorizacionSuficiencia aus
            INNER JOIN PRES.SolicitudSuficiencia ss ON ss.PKIdSolicitudSuficiencia = @FKIdSolicitudSuficiencia_PRES
            WHERE aus.PKIdAutorizacionSuficiencia = @PKIdAutorizacionSuficiencia;

            SET @Id = @PKIdAutorizacionSuficiencia;
            SET @message = 'Autorizacion de suficiencia actualizada correctamente.';
            SET @liga = CONCAT('idAutorizacionSuficiencia:', @Id);
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdAutorizacionSuficiencia IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.AutorizacionSuficiencia WHERE PKIdAutorizacionSuficiencia = @PKIdAutorizacionSuficiencia AND Activo = 1)
                THROW 51000, 'Autorizacion de suficiencia no encontrada.', 1;
            IF EXISTS (SELECT 1 FROM PRES.Contrato WHERE FKIdAutorizacionSuficiencia_PRES = @PKIdAutorizacionSuficiencia AND Activo = 1)
                THROW 51000, 'No se puede eliminar la autorizacion porque ya tiene contrato activo.', 1;

            UPDATE PRES.AutorizacionSuficienciaDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE FKIdAutorizacionSuficiencia_PRES = @PKIdAutorizacionSuficiencia AND Activo = 1;
            UPDATE PRES.AutorizacionSuficiencia SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdAutorizacionSuficiencia = @PKIdAutorizacionSuficiencia;

            SET @Id = @PKIdAutorizacionSuficiencia;
            SET @message = 'Autorizacion de suficiencia eliminada correctamente.';
            SET @liga = CONCAT('idAutorizacionSuficiencia:', @Id);
        END
        ELSE IF @Action = 4
        BEGIN
            SELECT * FROM PRES.Vw_AutorizacionSuficiencia WHERE PKIdAutorizacionSuficiencia = @PKIdAutorizacionSuficiencia;
            SET @message = 'Autorizacion de suficiencia consultada correctamente.';
            SET @liga = CONCAT('idAutorizacionSuficiencia:', @PKIdAutorizacionSuficiencia);
        END
        ELSE IF @Action = 5
        BEGIN
            IF @PKIdAutorizacionSuficiencia IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.AutorizacionSuficiencia WHERE PKIdAutorizacionSuficiencia = @PKIdAutorizacionSuficiencia AND Activo = 1)
                THROW 51000, 'Autorizacion de suficiencia no encontrada.', 1;
            IF @FKIdSolicitudSuficienciaDetalle_PRES IS NULL OR NOT EXISTS (
                SELECT 1
                FROM PRES.SolicitudSuficienciaDetalle ssd
                INNER JOIN PRES.AutorizacionSuficiencia aus ON aus.PKIdAutorizacionSuficiencia = @PKIdAutorizacionSuficiencia
                WHERE ssd.PKIdSolicitudSuficienciaDetalle = @FKIdSolicitudSuficienciaDetalle_PRES
                  AND ssd.FKIdSolicitudSuficiencia_PRES = aus.FKIdSolicitudSuficiencia_PRES
                  AND ssd.Activo = 1
            )
                THROW 51000, 'Detalle de solicitud de suficiencia no encontrado o no pertenece a la autorizacion.', 1;

            INSERT INTO PRES.AutorizacionSuficienciaDetalle (
                FKIdEmpresa_SIS, FKIdAutorizacionSuficiencia_PRES, FKIdSolicitudSuficienciaDetalle_PRES, FKIdPartida_CONTA,
                Enero, Febrero, Marzo, Abril, Mayo, Junio, Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre,
                Observaciones, Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT ISNULL(@FKIdEmpresa_SIS, aus.FKIdEmpresa_SIS), @PKIdAutorizacionSuficiencia, @FKIdSolicitudSuficienciaDetalle_PRES, @FKIdPartida_CONTA,
                   ISNULL(@Enero, 0), ISNULL(@Febrero, 0), ISNULL(@Marzo, 0), ISNULL(@Abril, 0), ISNULL(@Mayo, 0), ISNULL(@Junio, 0),
                   ISNULL(@Julio, 0), ISNULL(@Agosto, 0), ISNULL(@Septiembre, 0), ISNULL(@Octubre, 0), ISNULL(@Noviembre, 0), ISNULL(@Diciembre, 0),
                   @Observaciones, 1, @today, @IdUser
            FROM PRES.AutorizacionSuficiencia aus
            WHERE aus.PKIdAutorizacionSuficiencia = @PKIdAutorizacionSuficiencia;

            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Detalle de autorizacion de suficiencia creado correctamente.';
            SET @liga = CONCAT('idAutorizacionSuficienciaDetalle:', @Id);
        END
        ELSE IF @Action = 6
        BEGIN
            IF @PKIdAutorizacionSuficienciaDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.AutorizacionSuficienciaDetalle WHERE PKIdAutorizacionSuficienciaDetalle = @PKIdAutorizacionSuficienciaDetalle AND Activo = 1)
                THROW 51000, 'Detalle de autorizacion de suficiencia no encontrado.', 1;
            IF EXISTS (SELECT 1 FROM PRES.ContratoDetalle WHERE FKIdAutorizacionSuficienciaDetalle_PRES = @PKIdAutorizacionSuficienciaDetalle AND Activo = 1)
                THROW 51000, 'No se puede modificar el detalle porque ya esta ligado a un contrato.', 1;

            UPDATE PRES.AutorizacionSuficienciaDetalle
            SET FKIdSolicitudSuficienciaDetalle_PRES = @FKIdSolicitudSuficienciaDetalle_PRES,
                FKIdPartida_CONTA = @FKIdPartida_CONTA,
                Enero = ISNULL(@Enero, 0), Febrero = ISNULL(@Febrero, 0), Marzo = ISNULL(@Marzo, 0), Abril = ISNULL(@Abril, 0),
                Mayo = ISNULL(@Mayo, 0), Junio = ISNULL(@Junio, 0), Julio = ISNULL(@Julio, 0), Agosto = ISNULL(@Agosto, 0),
                Septiembre = ISNULL(@Septiembre, 0), Octubre = ISNULL(@Octubre, 0), Noviembre = ISNULL(@Noviembre, 0), Diciembre = ISNULL(@Diciembre, 0),
                Observaciones = @Observaciones,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdAutorizacionSuficienciaDetalle = @PKIdAutorizacionSuficienciaDetalle;

            SET @Id = @PKIdAutorizacionSuficienciaDetalle;
            SET @message = 'Detalle de autorizacion de suficiencia actualizado correctamente.';
            SET @liga = CONCAT('idAutorizacionSuficienciaDetalle:', @Id);
        END
        ELSE IF @Action = 7
        BEGIN
            IF @PKIdAutorizacionSuficienciaDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.AutorizacionSuficienciaDetalle WHERE PKIdAutorizacionSuficienciaDetalle = @PKIdAutorizacionSuficienciaDetalle AND Activo = 1)
                THROW 51000, 'Detalle de autorizacion de suficiencia no encontrado.', 1;
            IF EXISTS (SELECT 1 FROM PRES.ContratoDetalle WHERE FKIdAutorizacionSuficienciaDetalle_PRES = @PKIdAutorizacionSuficienciaDetalle AND Activo = 1)
                THROW 51000, 'No se puede eliminar el detalle porque ya esta ligado a un contrato.', 1;

            UPDATE PRES.AutorizacionSuficienciaDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdAutorizacionSuficienciaDetalle = @PKIdAutorizacionSuficienciaDetalle;
            SET @Id = @PKIdAutorizacionSuficienciaDetalle;
            SET @message = 'Detalle de autorizacion de suficiencia eliminado correctamente.';
            SET @liga = CONCAT('idAutorizacionSuficienciaDetalle:', @Id);
        END
        ELSE IF @Action = 8
        BEGIN
            SELECT * FROM PRES.Vw_AutorizacionSuficienciaDetalle WHERE PKIdAutorizacionSuficienciaDetalle = @PKIdAutorizacionSuficienciaDetalle;
            SET @message = 'Detalle de autorizacion de suficiencia consultado correctamente.';
            SET @liga = CONCAT('idAutorizacionSuficienciaDetalle:', @PKIdAutorizacionSuficienciaDetalle);
        END
        ELSE IF @Action = 10
        BEGIN
            IF EXISTS (SELECT 1 FROM PRES.AutorizacionSuficiencia WHERE FKIdSolicitudSuficiencia_PRES = @FKIdSolicitudSuficiencia_PRES AND Activo = 1)
                THROW 51000, 'Ya existe una autorizacion de suficiencia activa para esta solicitud.', 1;
            IF NOT EXISTS (SELECT 1 FROM PRES.SolicitudSuficienciaDetalle WHERE FKIdSolicitudSuficiencia_PRES = @FKIdSolicitudSuficiencia_PRES AND Activo = 1)
                THROW 51000, 'La solicitud no tiene detalle para autorizar.', 1;

            INSERT INTO PRES.AutorizacionSuficiencia (
                FKIdEmpresa_SIS, FKIdSolicitudSuficiencia_PRES, FechaAutorizacion, Justificacion,
                GastoNoProgramable, IdGastoNoProgramable, IdCompromisoNomina, AutorizadoPor_NOM,
                Observaciones, Estatus, Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT ISNULL(@FKIdEmpresa_SIS, ss.FKIdEmpresa_SIS), ss.PKIdSolicitudSuficiencia, ISNULL(@FechaAutorizacion, CONVERT(DATE, GETDATE())),
                   ISNULL(@Justificacion, ss.Justificacion), ISNULL(@GastoNoProgramable, ss.GastoNoProgramable),
                   ISNULL(@IdGastoNoProgramable, ss.IdGastoNoProgramable), ISNULL(@IdCompromisoNomina, ss.IdCompromisoNomina),
                   @AutorizadoPor_NOM, ISNULL(@Observaciones, CONCAT('Autorizada desde solicitud ', ss.PKIdSolicitudSuficiencia)),
                   ISNULL(NULLIF(@Estatus, 0), 2), 1, @today, @IdUser
            FROM PRES.SolicitudSuficiencia ss
            WHERE ss.PKIdSolicitudSuficiencia = @FKIdSolicitudSuficiencia_PRES;

            SET @Id = SCOPE_IDENTITY();

            INSERT INTO PRES.AutorizacionSuficienciaDetalle (
                FKIdEmpresa_SIS, FKIdAutorizacionSuficiencia_PRES, FKIdSolicitudSuficienciaDetalle_PRES, FKIdPartida_CONTA,
                Enero, Febrero, Marzo, Abril, Mayo, Junio, Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre,
                Observaciones, Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT ssd.FKIdEmpresa_SIS, @Id, ssd.PKIdSolicitudSuficienciaDetalle, ssd.FKIdPartida_CONTA,
                   ISNULL(ssd.Enero, 0), ISNULL(ssd.Febrero, 0), ISNULL(ssd.Marzo, 0), ISNULL(ssd.Abril, 0),
                   ISNULL(ssd.Mayo, 0), ISNULL(ssd.Junio, 0), ISNULL(ssd.Julio, 0), ISNULL(ssd.Agosto, 0),
                   ISNULL(ssd.Septiembre, 0), ISNULL(ssd.Octubre, 0), ISNULL(ssd.Noviembre, 0), ISNULL(ssd.Diciembre, 0),
                   ssd.Observaciones, 1, @today, @IdUser
            FROM PRES.SolicitudSuficienciaDetalle ssd
            WHERE ssd.FKIdSolicitudSuficiencia_PRES = @FKIdSolicitudSuficiencia_PRES
              AND ssd.Activo = 1;

            UPDATE PRES.SolicitudSuficiencia
            SET Estatus = 3,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdSolicitudSuficiencia = @FKIdSolicitudSuficiencia_PRES;

            SET @message = 'Autorizacion de suficiencia generada correctamente desde solicitud.';
            SET @liga = CONCAT('idAutorizacionSuficiencia:', @Id);
        END
        ELSE
            THROW 51000, 'Accion no valida para autorizacion de suficiencia.', 1;

        COMMIT TRANSACTION;
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, @liga AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @tipo = 'ERROR';
        SET @message = CONCAT(ISNULL(PROGRAM_NAME(), ''), CHAR(10), 'Error: ', ERROR_MESSAGE(), CHAR(10), 'Linea: ', ERROR_LINE());
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, '' AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN -1;
    END CATCH
END
GO
PRINT N'Creando Procedimiento [PRES].[SP_MantenimientoCheque]...';


GO

CREATE   PROCEDURE [PRES].[SP_MantenimientoCheque] (
    @Action INT,
    @PKIdCheque INT = NULL,
    @PKIdChequePartida INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdCLC_PRES INT = NULL,
    @FKIdCuentaBancaria_TES INT = NULL,
    @FKIdPoliza_CONTA INT = NULL,
    @FechaEmision DATE = NULL,
    @NumeroCheque NVARCHAR(50) = NULL,
    @Concepto NVARCHAR(150) = NULL,
    @ImporteTotal DECIMAL(20,4) = NULL,
    @Observaciones NVARCHAR(500) = NULL,
    @Estatus INT = NULL,
    @FKIdCLCDetalle_PRES INT = NULL,
    @FKIdPartida_CONTA INT = NULL,
    @MontoPagado DECIMAL(20,4) = NULL,
    @IdUser INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(20) = 'OK', @message NVARCHAR(4000) = '', @Parameters NVARCHAR(4000) = '', @liga NVARCHAR(100) = '', @today DATETIME2 = SYSDATETIME(), @Id INT;

    SET @message = CONCAT('Iniciando el SP [PRES].[SP_MantenimientoCheque]', ' @PKIdCheque ', @PKIdCheque);
    SET @Parameters = CONCAT('Action=', @Action, ', PKIdCheque=', ISNULL(CONVERT(NVARCHAR(30), @PKIdCheque), 'NULL'), ', PKIdChequePartida=', ISNULL(CONVERT(NVARCHAR(30), @PKIdChequePartida), 'NULL'), ', NumeroCheque=', ISNULL(@NumeroCheque, 'NULL'), ', IdUser=', ISNULL(CONVERT(NVARCHAR(30), @IdUser), 'NULL'));
    EXEC [SIS].[WriteSystemLog] @FK_IdOrigenLogMessage__SIS = 1, @Date = @today, @_Type = 1, @ProgName = 'PRES.SP_MantenimientoCheque', @EmployeeNo = @IdUser, @Category = NULL, @IPClient = NULL, @HostName = NULL, @Thread = NULL, @Level = 'INFO', @Logger = NULL, @Message = @message, @Exception = NULL, @Context = NULL, @MethodName = 'PRES.SP_MantenimientoCheque', @Parameters = @Parameters, @ExecutionTime = '0';
    SET @message = '';

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            INSERT INTO PRES.Cheque (
                FKIdEmpresa_SIS, FKIdCLC_PRES, FKIdCuentaBancaria_TES, FKIdPoliza_CONTA,
                FechaEmision, NumeroCheque, Concepto, ImporteTotal, Observaciones, Estatus,
                Activo, FechaCreacion, UsuarioCreacion
            )
            VALUES (
                @FKIdEmpresa_SIS, @FKIdCLC_PRES, @FKIdCuentaBancaria_TES, @FKIdPoliza_CONTA,
                ISNULL(@FechaEmision, CONVERT(DATE, GETDATE())), @NumeroCheque, @Concepto, ISNULL(@ImporteTotal, 0),
                @Observaciones, ISNULL(NULLIF(@Estatus, 0), 1), 1, @today, @IdUser
            );
            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Cheque creado correctamente.';
            SET @liga = CONCAT('idCheque:', @Id);
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdCheque IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.Cheque WHERE PKIdCheque = @PKIdCheque AND Activo = 1)
                THROW 51000, 'Cheque no encontrado.', 1;

            UPDATE PRES.Cheque
            SET FKIdEmpresa_SIS = @FKIdEmpresa_SIS,
                FKIdCLC_PRES = @FKIdCLC_PRES,
                FKIdCuentaBancaria_TES = @FKIdCuentaBancaria_TES,
                FKIdPoliza_CONTA = @FKIdPoliza_CONTA,
                FechaEmision = ISNULL(@FechaEmision, FechaEmision),
                NumeroCheque = @NumeroCheque,
                Concepto = @Concepto,
                ImporteTotal = ISNULL(@ImporteTotal, 0),
                Observaciones = @Observaciones,
                Estatus = ISNULL(NULLIF(@Estatus, 0), Estatus),
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdCheque = @PKIdCheque;
            SET @Id = @PKIdCheque;
            SET @message = 'Cheque actualizado correctamente.';
            SET @liga = CONCAT('idCheque:', @Id);
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdCheque IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.Cheque WHERE PKIdCheque = @PKIdCheque AND Activo = 1)
                THROW 51000, 'Cheque no encontrado.', 1;
            UPDATE PRES.ChequePartidas SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE FKIdCheque_PRES = @PKIdCheque AND Activo = 1;
            UPDATE PRES.Cheque SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdCheque = @PKIdCheque;
            SET @Id = @PKIdCheque;
            SET @message = 'Cheque eliminado correctamente.';
            SET @liga = CONCAT('idCheque:', @Id);
        END
        ELSE IF @Action = 4
        BEGIN
            SELECT * FROM PRES.Vw_Cheque WHERE PKIdCheque = @PKIdCheque;
            SET @message = 'Cheque consultado correctamente.';
            SET @liga = CONCAT('idCheque:', @PKIdCheque);
        END
        ELSE IF @Action = 5
        BEGIN
            IF @PKIdCheque IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.Cheque WHERE PKIdCheque = @PKIdCheque AND Activo = 1)
                THROW 51000, 'Cheque no encontrado.', 1;
            IF @FKIdCLCDetalle_PRES IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.CLCDetalle WHERE PKIdCLCDetalle = @FKIdCLCDetalle_PRES AND Activo = 1)
                THROW 51000, 'Detalle de CLC no encontrado.', 1;
            IF ISNULL(@MontoPagado, 0) <= 0
                THROW 51000, 'El monto pagado debe ser mayor a cero.', 1;

            INSERT INTO PRES.ChequePartidas (
                FKIdEmpresa_SIS, FKIdCheque_PRES, FKIdCLCDetalle_PRES, FKIdPartida_CONTA,
                MontoPagado, Observaciones, Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT ISNULL(@FKIdEmpresa_SIS, ch.FKIdEmpresa_SIS), @PKIdCheque, @FKIdCLCDetalle_PRES,
                   ISNULL(@FKIdPartida_CONTA, cd.FKIdPartida_CONTA), @MontoPagado, @Observaciones, 1, @today, @IdUser
            FROM PRES.Cheque ch
            INNER JOIN PRES.CLCDetalle cd ON cd.PKIdCLCDetalle = @FKIdCLCDetalle_PRES
            WHERE ch.PKIdCheque = @PKIdCheque;
            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Partida de cheque creada correctamente.';
            SET @liga = CONCAT('idChequePartida:', @Id);
        END
        ELSE IF @Action = 6
        BEGIN
            IF @PKIdChequePartida IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.ChequePartidas WHERE PKIdChequePartida = @PKIdChequePartida AND Activo = 1)
                THROW 51000, 'Partida de cheque no encontrada.', 1;
            IF ISNULL(@MontoPagado, 0) <= 0
                THROW 51000, 'El monto pagado debe ser mayor a cero.', 1;

            UPDATE cp
            SET FKIdCLCDetalle_PRES = @FKIdCLCDetalle_PRES,
                FKIdPartida_CONTA = ISNULL(@FKIdPartida_CONTA, cd.FKIdPartida_CONTA),
                MontoPagado = @MontoPagado,
                Observaciones = @Observaciones,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            FROM PRES.ChequePartidas cp
            INNER JOIN PRES.CLCDetalle cd ON cd.PKIdCLCDetalle = @FKIdCLCDetalle_PRES AND cd.Activo = 1
            WHERE cp.PKIdChequePartida = @PKIdChequePartida;
            SET @Id = @PKIdChequePartida;
            SET @message = 'Partida de cheque actualizada correctamente.';
            SET @liga = CONCAT('idChequePartida:', @Id);
        END
        ELSE IF @Action = 7
        BEGIN
            IF @PKIdChequePartida IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.ChequePartidas WHERE PKIdChequePartida = @PKIdChequePartida AND Activo = 1)
                THROW 51000, 'Partida de cheque no encontrada.', 1;
            UPDATE PRES.ChequePartidas SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdChequePartida = @PKIdChequePartida;
            SET @Id = @PKIdChequePartida;
            SET @message = 'Partida de cheque eliminada correctamente.';
            SET @liga = CONCAT('idChequePartida:', @Id);
        END
        ELSE IF @Action = 8
        BEGIN
            SELECT * FROM PRES.Vw_ChequePartidas WHERE PKIdChequePartida = @PKIdChequePartida;
            SET @message = 'Partida de cheque consultada correctamente.';
            SET @liga = CONCAT('idChequePartida:', @PKIdChequePartida);
        END
        ELSE
            THROW 51000, 'Accion no valida para cheque.', 1;

        COMMIT TRANSACTION;
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, @liga AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @tipo = 'ERROR';
        SET @message = CONCAT(ISNULL(PROGRAM_NAME(), ''), CHAR(10), 'Error: ', ERROR_MESSAGE(), CHAR(10), 'Linea: ', ERROR_LINE());
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, '' AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN -1;
    END CATCH
END
GO
PRINT N'Creando Procedimiento [PRES].[SP_MantenimientoCLC]...';


GO

CREATE   PROCEDURE [PRES].[SP_MantenimientoCLC] (
    @Action INT,
    @PKIdCLC INT = NULL,
    @PKIdCLCDetalle INT = NULL,
    @PKIdCLCFactura INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdContrato_PRES INT = NULL,
    @FKIdPoliza_CONTA INT = NULL,
    @NumCLC NVARCHAR(20) = NULL,
    @FechaSolicitud DATE = NULL,
    @FechaAutorizacion DATE = NULL,
    @ImporteTotal DECIMAL(20,4) = NULL,
    @Observaciones NVARCHAR(500) = NULL,
    @Estatus INT = NULL,
    @FKIdContratoDetalle_PRES INT = NULL,
    @FKIdPartida_CONTA INT = NULL,
    @Enero DECIMAL(20,4) = NULL,
    @Febrero DECIMAL(20,4) = NULL,
    @Marzo DECIMAL(20,4) = NULL,
    @Abril DECIMAL(20,4) = NULL,
    @Mayo DECIMAL(20,4) = NULL,
    @Junio DECIMAL(20,4) = NULL,
    @Julio DECIMAL(20,4) = NULL,
    @Agosto DECIMAL(20,4) = NULL,
    @Septiembre DECIMAL(20,4) = NULL,
    @Octubre DECIMAL(20,4) = NULL,
    @Noviembre DECIMAL(20,4) = NULL,
    @Diciembre DECIMAL(20,4) = NULL,
    @FKIdFactura_PRES INT = NULL,
    @FKIdFacturaDetalle_PRES INT = NULL,
    @MontoAplicado DECIMAL(20,4) = NULL,
    @IdUser INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(20) = 'OK', @message NVARCHAR(4000) = '', @Parameters NVARCHAR(4000) = '', @liga NVARCHAR(100) = '', @today DATETIME2 = SYSDATETIME(), @Id INT;

    SET @message = CONCAT('Iniciando el SP [PRES].[SP_MantenimientoCLC]', ' @PKIdCLC ', @PKIdCLC);
    SET @Parameters = CONCAT('Action=', @Action, ', PKIdCLC=', ISNULL(CONVERT(NVARCHAR(30), @PKIdCLC), 'NULL'), ', PKIdCLCDetalle=', ISNULL(CONVERT(NVARCHAR(30), @PKIdCLCDetalle), 'NULL'), ', PKIdCLCFactura=', ISNULL(CONVERT(NVARCHAR(30), @PKIdCLCFactura), 'NULL'), ', NumCLC=', ISNULL(@NumCLC, 'NULL'), ', IdUser=', ISNULL(CONVERT(NVARCHAR(30), @IdUser), 'NULL'));
    EXEC [SIS].[WriteSystemLog] @FK_IdOrigenLogMessage__SIS = 1, @Date = @today, @_Type = 1, @ProgName = 'PRES.SP_MantenimientoCLC', @EmployeeNo = @IdUser, @Category = NULL, @IPClient = NULL, @HostName = NULL, @Thread = NULL, @Level = 'INFO', @Logger = NULL, @Message = @message, @Exception = NULL, @Context = NULL, @MethodName = 'PRES.SP_MantenimientoCLC', @Parameters = @Parameters, @ExecutionTime = '0';
    SET @message = '';

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            INSERT INTO PRES.CLC (
                FKIdEmpresa_SIS, FKIdContrato_PRES, FKIdPoliza_CONTA, NumCLC, FechaSolicitud,
                FechaAutorizacion, ImporteTotal, Observaciones, Estatus, Activo, FechaCreacion, UsuarioCreacion
            )
            VALUES (
                @FKIdEmpresa_SIS, @FKIdContrato_PRES, @FKIdPoliza_CONTA, @NumCLC, ISNULL(@FechaSolicitud, CONVERT(DATE, GETDATE())),
                @FechaAutorizacion, ISNULL(@ImporteTotal, 0), @Observaciones, ISNULL(NULLIF(@Estatus, 0), 1), 1, @today, @IdUser
            );
            SET @Id = SCOPE_IDENTITY();
            SET @message = 'CLC creada correctamente.';
            SET @liga = CONCAT('idCLC:', @Id);
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdCLC IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.CLC WHERE PKIdCLC = @PKIdCLC AND Activo = 1)
                THROW 51000, 'CLC no encontrada.', 1;

            UPDATE PRES.CLC
            SET FKIdEmpresa_SIS = @FKIdEmpresa_SIS,
                FKIdContrato_PRES = @FKIdContrato_PRES,
                FKIdPoliza_CONTA = @FKIdPoliza_CONTA,
                NumCLC = @NumCLC,
                FechaSolicitud = ISNULL(@FechaSolicitud, FechaSolicitud),
                FechaAutorizacion = @FechaAutorizacion,
                ImporteTotal = ISNULL(@ImporteTotal, 0),
                Observaciones = @Observaciones,
                Estatus = ISNULL(NULLIF(@Estatus, 0), Estatus),
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdCLC = @PKIdCLC;
            SET @Id = @PKIdCLC;
            SET @message = 'CLC actualizada correctamente.';
            SET @liga = CONCAT('idCLC:', @Id);
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdCLC IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.CLC WHERE PKIdCLC = @PKIdCLC AND Activo = 1)
                THROW 51000, 'CLC no encontrada.', 1;
            UPDATE PRES.CLCFactura SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE FKIdCLC_PRES = @PKIdCLC AND Activo = 1;
            UPDATE PRES.CLCDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE FKIdCLC_PRES = @PKIdCLC AND Activo = 1;
            UPDATE PRES.CLC SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdCLC = @PKIdCLC;
            SET @Id = @PKIdCLC;
            SET @message = 'CLC eliminada correctamente.';
            SET @liga = CONCAT('idCLC:', @Id);
        END
        ELSE IF @Action = 4
        BEGIN
            SELECT * FROM PRES.Vw_CLC WHERE PKIdCLC = @PKIdCLC;
            SET @message = 'CLC consultada correctamente.';
            SET @liga = CONCAT('idCLC:', @PKIdCLC);
        END
        ELSE IF @Action = 5
        BEGIN
            IF @PKIdCLC IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.CLC WHERE PKIdCLC = @PKIdCLC AND Activo = 1)
                THROW 51000, 'CLC no encontrada.', 1;
            IF @FKIdContratoDetalle_PRES IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.ContratoDetalle WHERE PKIdContratoDetalle = @FKIdContratoDetalle_PRES AND Activo = 1)
                THROW 51000, 'Detalle de contrato no encontrado.', 1;

            INSERT INTO PRES.CLCDetalle (
                FKIdEmpresa_SIS, FKIdCLC_PRES, FKIdContratoDetalle_PRES, FKIdPartida_CONTA,
                Enero, Febrero, Marzo, Abril, Mayo, Junio, Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre,
                Observaciones, Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT ISNULL(@FKIdEmpresa_SIS, clc.FKIdEmpresa_SIS), @PKIdCLC, @FKIdContratoDetalle_PRES,
                   ISNULL(@FKIdPartida_CONTA, cd.FKIdPartida_CONTA), ISNULL(@Enero,0), ISNULL(@Febrero,0), ISNULL(@Marzo,0),
                   ISNULL(@Abril,0), ISNULL(@Mayo,0), ISNULL(@Junio,0), ISNULL(@Julio,0), ISNULL(@Agosto,0),
                   ISNULL(@Septiembre,0), ISNULL(@Octubre,0), ISNULL(@Noviembre,0), ISNULL(@Diciembre,0),
                   @Observaciones, 1, @today, @IdUser
            FROM PRES.CLC clc
            INNER JOIN PRES.ContratoDetalle cd ON cd.PKIdContratoDetalle = @FKIdContratoDetalle_PRES
            WHERE clc.PKIdCLC = @PKIdCLC;
            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Detalle de CLC creado correctamente.';
            SET @liga = CONCAT('idCLCDetalle:', @Id);
        END
        ELSE IF @Action = 6
        BEGIN
            IF @PKIdCLCDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.CLCDetalle WHERE PKIdCLCDetalle = @PKIdCLCDetalle AND Activo = 1)
                THROW 51000, 'Detalle de CLC no encontrado.', 1;

            UPDATE cd
            SET FKIdContratoDetalle_PRES = @FKIdContratoDetalle_PRES,
                FKIdPartida_CONTA = ISNULL(@FKIdPartida_CONTA, ctd.FKIdPartida_CONTA),
                Enero = ISNULL(@Enero,0), Febrero = ISNULL(@Febrero,0), Marzo = ISNULL(@Marzo,0), Abril = ISNULL(@Abril,0),
                Mayo = ISNULL(@Mayo,0), Junio = ISNULL(@Junio,0), Julio = ISNULL(@Julio,0), Agosto = ISNULL(@Agosto,0),
                Septiembre = ISNULL(@Septiembre,0), Octubre = ISNULL(@Octubre,0), Noviembre = ISNULL(@Noviembre,0), Diciembre = ISNULL(@Diciembre,0),
                Observaciones = @Observaciones,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            FROM PRES.CLCDetalle cd
            INNER JOIN PRES.ContratoDetalle ctd ON ctd.PKIdContratoDetalle = @FKIdContratoDetalle_PRES AND ctd.Activo = 1
            WHERE cd.PKIdCLCDetalle = @PKIdCLCDetalle;
            SET @Id = @PKIdCLCDetalle;
            SET @message = 'Detalle de CLC actualizado correctamente.';
            SET @liga = CONCAT('idCLCDetalle:', @Id);
        END
        ELSE IF @Action = 7
        BEGIN
            IF @PKIdCLCDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.CLCDetalle WHERE PKIdCLCDetalle = @PKIdCLCDetalle AND Activo = 1)
                THROW 51000, 'Detalle de CLC no encontrado.', 1;
            UPDATE PRES.CLCDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdCLCDetalle = @PKIdCLCDetalle;
            SET @Id = @PKIdCLCDetalle;
            SET @message = 'Detalle de CLC eliminado correctamente.';
            SET @liga = CONCAT('idCLCDetalle:', @Id);
        END
        ELSE IF @Action = 8
        BEGIN
            SELECT * FROM PRES.Vw_CLCDetalle WHERE PKIdCLCDetalle = @PKIdCLCDetalle;
            SET @message = 'Detalle de CLC consultado correctamente.';
            SET @liga = CONCAT('idCLCDetalle:', @PKIdCLCDetalle);
        END
        ELSE IF @Action = 9
        BEGIN
            IF @PKIdCLC IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.CLC WHERE PKIdCLC = @PKIdCLC AND Activo = 1)
                THROW 51000, 'CLC no encontrada.', 1;
            IF @FKIdFacturaDetalle_PRES IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.FacturaDetalle WHERE PKIdFacturaDetalle = @FKIdFacturaDetalle_PRES AND Activo = 1)
                THROW 51000, 'Detalle de factura no encontrado.', 1;
            IF ISNULL(@MontoAplicado, 0) <= 0
                THROW 51000, 'El monto aplicado debe ser mayor a cero.', 1;

            INSERT INTO PRES.CLCFactura (
                FKIdEmpresa_SIS, FKIdCLC_PRES, FKIdFactura_PRES, FKIdFacturaDetalle_PRES,
                MontoAplicado, Observaciones, Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT ISNULL(@FKIdEmpresa_SIS, clc.FKIdEmpresa_SIS), @PKIdCLC, ISNULL(@FKIdFactura_PRES, fd.FKIdFactura_PRES),
                   @FKIdFacturaDetalle_PRES, @MontoAplicado, @Observaciones, 1, @today, @IdUser
            FROM PRES.CLC clc
            INNER JOIN PRES.FacturaDetalle fd ON fd.PKIdFacturaDetalle = @FKIdFacturaDetalle_PRES
            WHERE clc.PKIdCLC = @PKIdCLC;
            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Factura de CLC creada correctamente.';
            SET @liga = CONCAT('idCLCFactura:', @Id);
        END
        ELSE IF @Action = 10
        BEGIN
            IF @PKIdCLCFactura IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.CLCFactura WHERE PKIdCLCFactura = @PKIdCLCFactura AND Activo = 1)
                THROW 51000, 'Factura de CLC no encontrada.', 1;
            IF ISNULL(@MontoAplicado, 0) <= 0
                THROW 51000, 'El monto aplicado debe ser mayor a cero.', 1;

            UPDATE cf
            SET FKIdFactura_PRES = ISNULL(@FKIdFactura_PRES, fd.FKIdFactura_PRES),
                FKIdFacturaDetalle_PRES = @FKIdFacturaDetalle_PRES,
                MontoAplicado = @MontoAplicado,
                Observaciones = @Observaciones,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            FROM PRES.CLCFactura cf
            INNER JOIN PRES.FacturaDetalle fd ON fd.PKIdFacturaDetalle = @FKIdFacturaDetalle_PRES AND fd.Activo = 1
            WHERE cf.PKIdCLCFactura = @PKIdCLCFactura;
            SET @Id = @PKIdCLCFactura;
            SET @message = 'Factura de CLC actualizada correctamente.';
            SET @liga = CONCAT('idCLCFactura:', @Id);
        END
        ELSE IF @Action = 11
        BEGIN
            IF @PKIdCLCFactura IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.CLCFactura WHERE PKIdCLCFactura = @PKIdCLCFactura AND Activo = 1)
                THROW 51000, 'Factura de CLC no encontrada.', 1;
            UPDATE PRES.CLCFactura SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdCLCFactura = @PKIdCLCFactura;
            SET @Id = @PKIdCLCFactura;
            SET @message = 'Factura de CLC eliminada correctamente.';
            SET @liga = CONCAT('idCLCFactura:', @Id);
        END
        ELSE IF @Action = 12
        BEGIN
            SELECT * FROM PRES.Vw_CLCFactura WHERE PKIdCLCFactura = @PKIdCLCFactura;
            SET @message = 'Factura de CLC consultada correctamente.';
            SET @liga = CONCAT('idCLCFactura:', @PKIdCLCFactura);
        END
        ELSE
            THROW 51000, 'Accion no valida para CLC.', 1;

        COMMIT TRANSACTION;
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, @liga AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @tipo = 'ERROR';
        SET @message = CONCAT(ISNULL(PROGRAM_NAME(), ''), CHAR(10), 'Error: ', ERROR_MESSAGE(), CHAR(10), 'Linea: ', ERROR_LINE());
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, '' AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN -1;
    END CATCH
END
GO
PRINT N'Creando Procedimiento [PRES].[SP_MantenimientoFactura]...';


GO

CREATE   PROCEDURE [PRES].[SP_MantenimientoFactura] (
    @Action INT,
    @PKIdFactura INT = NULL,
    @PKIdFacturaDetalle INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdContrato_PRES INT = NULL,
    @FKIdPoliza_CONTA INT = NULL,
    @NumFactura NVARCHAR(250) = NULL,
    @SerieFactura NVARCHAR(20) = NULL,
    @FechaEmision DATE = NULL,
    @FechaRecepcion DATE = NULL,
    @Subtotal DECIMAL(20,4) = NULL,
    @IVA DECIMAL(20,4) = NULL,
    @Retencion DECIMAL(20,4) = NULL,
    @Total DECIMAL(20,4) = NULL,
    @UUID NVARCHAR(36) = NULL,
    @FL_Docto NVARCHAR(1000) = NULL,
    @Observaciones NVARCHAR(MAX) = NULL,
    @Estatus INT = NULL,
    @FKIdContratoDetalle_PRES INT = NULL,
    @FKIdPartida_CONTA INT = NULL,
    @MontoAplicado DECIMAL(20,4) = NULL,
    @IdUser INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(20) = 'OK', @message NVARCHAR(4000) = '', @Parameters NVARCHAR(4000) = '', @liga NVARCHAR(100) = '', @today DATETIME2 = SYSDATETIME(), @Id INT;

    SET @message = CONCAT('Iniciando el SP [PRES].[SP_MantenimientoFactura]', ' @PKIdFactura ', @PKIdFactura);
    SET @Parameters = CONCAT('Action=', @Action, ', PKIdFactura=', ISNULL(CONVERT(NVARCHAR(30), @PKIdFactura), 'NULL'), ', PKIdFacturaDetalle=', ISNULL(CONVERT(NVARCHAR(30), @PKIdFacturaDetalle), 'NULL'), ', NumFactura=', ISNULL(@NumFactura, 'NULL'), ', Total=', ISNULL(CONVERT(NVARCHAR(30), @Total), 'NULL'), ', IdUser=', ISNULL(CONVERT(NVARCHAR(30), @IdUser), 'NULL'));
    EXEC [SIS].[WriteSystemLog] @FK_IdOrigenLogMessage__SIS = 1, @Date = @today, @_Type = 1, @ProgName = 'PRES.SP_MantenimientoFactura', @EmployeeNo = @IdUser, @Category = NULL, @IPClient = NULL, @HostName = NULL, @Thread = NULL, @Level = 'INFO', @Logger = NULL, @Message = @message, @Exception = NULL, @Context = NULL, @MethodName = 'PRES.SP_MantenimientoFactura', @Parameters = @Parameters, @ExecutionTime = '0';
    SET @message = '';

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            IF @Total IS NULL
                SET @Total = ISNULL(@Subtotal, 0) + ISNULL(@IVA, 0) - ISNULL(@Retencion, 0);

            INSERT INTO PRES.Factura (
                FKIdEmpresa_SIS, FKIdContrato_PRES, FKIdPoliza_CONTA, NumFactura, SerieFactura,
                FechaEmision, FechaRecepcion, Subtotal, IVA, Retencion, Total, UUID, FL_Docto,
                Observaciones, Estatus, Activo, FechaCreacion, UsuarioCreacion
            )
            VALUES (
                @FKIdEmpresa_SIS, @FKIdContrato_PRES, @FKIdPoliza_CONTA, @NumFactura, @SerieFactura,
                ISNULL(@FechaEmision, CONVERT(DATE, GETDATE())), @FechaRecepcion, ISNULL(@Subtotal, 0),
                ISNULL(@IVA, 0), ISNULL(@Retencion, 0), @Total, @UUID, @FL_Docto,
                @Observaciones, ISNULL(NULLIF(@Estatus, 0), 1), 1, @today, @IdUser
            );
            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Factura creada correctamente.';
            SET @liga = CONCAT('idFactura:', @Id);
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdFactura IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.Factura WHERE PKIdFactura = @PKIdFactura AND Activo = 1)
                THROW 51000, 'Factura no encontrada.', 1;
            IF @Total IS NULL
                SET @Total = ISNULL(@Subtotal, 0) + ISNULL(@IVA, 0) - ISNULL(@Retencion, 0);

            UPDATE PRES.Factura
            SET FKIdEmpresa_SIS = @FKIdEmpresa_SIS,
                FKIdContrato_PRES = @FKIdContrato_PRES,
                FKIdPoliza_CONTA = @FKIdPoliza_CONTA,
                NumFactura = @NumFactura,
                SerieFactura = @SerieFactura,
                FechaEmision = ISNULL(@FechaEmision, FechaEmision),
                FechaRecepcion = @FechaRecepcion,
                Subtotal = ISNULL(@Subtotal, 0),
                IVA = ISNULL(@IVA, 0),
                Retencion = ISNULL(@Retencion, 0),
                Total = @Total,
                UUID = @UUID,
                FL_Docto = @FL_Docto,
                Observaciones = @Observaciones,
                Estatus = ISNULL(NULLIF(@Estatus, 0), Estatus),
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdFactura = @PKIdFactura;
            SET @Id = @PKIdFactura;
            SET @message = 'Factura actualizada correctamente.';
            SET @liga = CONCAT('idFactura:', @Id);
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdFactura IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.Factura WHERE PKIdFactura = @PKIdFactura AND Activo = 1)
                THROW 51000, 'Factura no encontrada.', 1;
            UPDATE PRES.FacturaDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE FKIdFactura_PRES = @PKIdFactura AND Activo = 1;
            UPDATE PRES.Factura SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdFactura = @PKIdFactura;
            SET @Id = @PKIdFactura;
            SET @message = 'Factura eliminada correctamente.';
            SET @liga = CONCAT('idFactura:', @Id);
        END
        ELSE IF @Action = 4
        BEGIN
            SELECT * FROM PRES.Vw_Factura WHERE PKIdFactura = @PKIdFactura;
            SET @message = 'Factura consultada correctamente.';
            SET @liga = CONCAT('idFactura:', @PKIdFactura);
        END
        ELSE IF @Action = 5
        BEGIN
            IF @PKIdFactura IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.Factura WHERE PKIdFactura = @PKIdFactura AND Activo = 1)
                THROW 51000, 'Factura no encontrada.', 1;
            IF @FKIdContratoDetalle_PRES IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.ContratoDetalle WHERE PKIdContratoDetalle = @FKIdContratoDetalle_PRES AND Activo = 1)
                THROW 51000, 'Detalle de contrato no encontrado.', 1;
            IF ISNULL(@MontoAplicado, 0) <= 0
                THROW 51000, 'El monto aplicado debe ser mayor a cero.', 1;

            INSERT INTO PRES.FacturaDetalle (
                FKIdEmpresa_SIS, FKIdFactura_PRES, FKIdContratoDetalle_PRES, FKIdPartida_CONTA,
                MontoAplicado, Observaciones, Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT ISNULL(@FKIdEmpresa_SIS, f.FKIdEmpresa_SIS), @PKIdFactura, @FKIdContratoDetalle_PRES,
                   ISNULL(@FKIdPartida_CONTA, cd.FKIdPartida_CONTA), @MontoAplicado, @Observaciones, 1, @today, @IdUser
            FROM PRES.Factura f
            INNER JOIN PRES.ContratoDetalle cd ON cd.PKIdContratoDetalle = @FKIdContratoDetalle_PRES
            WHERE f.PKIdFactura = @PKIdFactura;
            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Detalle de factura creado correctamente.';
            SET @liga = CONCAT('idFacturaDetalle:', @Id);
        END
        ELSE IF @Action = 6
        BEGIN
            IF @PKIdFacturaDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.FacturaDetalle WHERE PKIdFacturaDetalle = @PKIdFacturaDetalle AND Activo = 1)
                THROW 51000, 'Detalle de factura no encontrado.', 1;
            IF ISNULL(@MontoAplicado, 0) <= 0
                THROW 51000, 'El monto aplicado debe ser mayor a cero.', 1;

            UPDATE fd
            SET FKIdContratoDetalle_PRES = @FKIdContratoDetalle_PRES,
                FKIdPartida_CONTA = ISNULL(@FKIdPartida_CONTA, cd.FKIdPartida_CONTA),
                MontoAplicado = @MontoAplicado,
                Observaciones = @Observaciones,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            FROM PRES.FacturaDetalle fd
            INNER JOIN PRES.ContratoDetalle cd ON cd.PKIdContratoDetalle = @FKIdContratoDetalle_PRES AND cd.Activo = 1
            WHERE fd.PKIdFacturaDetalle = @PKIdFacturaDetalle;
            SET @Id = @PKIdFacturaDetalle;
            SET @message = 'Detalle de factura actualizado correctamente.';
            SET @liga = CONCAT('idFacturaDetalle:', @Id);
        END
        ELSE IF @Action = 7
        BEGIN
            IF @PKIdFacturaDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.FacturaDetalle WHERE PKIdFacturaDetalle = @PKIdFacturaDetalle AND Activo = 1)
                THROW 51000, 'Detalle de factura no encontrado.', 1;
            UPDATE PRES.FacturaDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdFacturaDetalle = @PKIdFacturaDetalle;
            SET @Id = @PKIdFacturaDetalle;
            SET @message = 'Detalle de factura eliminado correctamente.';
            SET @liga = CONCAT('idFacturaDetalle:', @Id);
        END
        ELSE IF @Action = 8
        BEGIN
            SELECT * FROM PRES.Vw_FacturaDetalle WHERE PKIdFacturaDetalle = @PKIdFacturaDetalle;
            SET @message = 'Detalle de factura consultado correctamente.';
            SET @liga = CONCAT('idFacturaDetalle:', @PKIdFacturaDetalle);
        END
        ELSE
            THROW 51000, 'Accion no valida para factura.', 1;

        COMMIT TRANSACTION;
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, @liga AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @tipo = 'ERROR';
        SET @message = CONCAT(ISNULL(PROGRAM_NAME(), ''), CHAR(10), 'Error: ', ERROR_MESSAGE(), CHAR(10), 'Linea: ', ERROR_LINE());
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, '' AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN -1;
    END CATCH
END
GO
DECLARE @VarDecimalSupported AS BIT;

SELECT @VarDecimalSupported = 0;

IF ((ServerProperty(N'EngineEdition') = 3)
    AND (((@@microsoftversion / power(2, 24) = 9)
          AND (@@microsoftversion & 0xffff >= 3024))
         OR ((@@microsoftversion / power(2, 24) = 10)
             AND (@@microsoftversion & 0xffff >= 1600))))
    SELECT @VarDecimalSupported = 1;

IF (@VarDecimalSupported > 0)
    BEGIN
        EXECUTE sp_db_vardecimal_storage_format N'$(DatabaseName)', 'ON';
    END


GO
PRINT N'Actualización completada.';


GO
