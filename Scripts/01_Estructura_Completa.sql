USE [GestionEmpresarial]
GO
/****** Objeto: Schema [ALMA] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
CREATE SCHEMA [ALMA]
GO
/****** Objeto: Schema [CONTA] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
CREATE SCHEMA [CONTA]
GO
/****** Objeto: Schema [NOM] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
CREATE SCHEMA [NOM]
GO
/****** Objeto: Schema [ORCO] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
CREATE SCHEMA [ORCO]
GO
/****** Objeto: Schema [PRES] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
CREATE SCHEMA [PRES]
GO
/****** Objeto: Schema [SIS] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
CREATE SCHEMA [SIS]
GO
/****** Objeto: Schema [TES] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
CREATE SCHEMA [TES]
GO
/****** Objeto: UserDefinedDataType [dbo].[dmoney] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
CREATE TYPE [dbo].[dmoney] FROM [decimal](20, 4) NULL
GO
/****** Objeto: UserDefinedFunction [dbo].[STRING_SPLIT] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Objeto: Table [ALMA].[Bien] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMA].[Bien](
	[PKIdBien] [int] IDENTITY(1,1) NOT NULL,
	[FKIdGrupoBien_ALMA] [int] NULL,
	[FKIdTipoBien_ALMA] [int] NOT NULL,
	[FKIdArea_SIS] [int] NULL,
	[FKIdProveedor_SIS] [int] NULL,
	[FKIdEstadoBien_ALMA] [int] NULL,
	[FKIdTipoPatrimonio_ALMA] [int] NULL,
	[FKIdMarca_ALMA] [int] NULL,
	[FKIdMaterial_ALMA] [int] NULL,
	[FKIdTipoAdq_ALMA] [int] NULL,
	[FKIdPartida_CONTA] [int] NULL,
	[FKIdDetalleOrdenCompra_ORCO] [int] NULL,
	[Clave] [nvarchar](50) NULL,
	[ClaveAnt] [nvarchar](50) NULL,
	[Descripcion] [nvarchar](1000) NULL,
	[Modelo] [nvarchar](50) NULL,
	[Serie] [nvarchar](1000) NULL,
	[Requisicion] [nvarchar](25) NULL,
	[Factura] [nvarchar](50) NULL,
	[Costo] [dbo].[dmoney] NULL,
	[FechaAdq] [datetime] NULL,
	[Referencia] [nvarchar](50) NULL,
	[Notas] [nvarchar](250) NULL,
	[Ubicacion] [nvarchar](50) NULL,
	[AAdquisicion] [nvarchar](2) NULL,
	[Frente] [int] NULL,
	[Fondo] [int] NULL,
	[Altura] [int] NULL,
	[Diametro] [int] NULL,
	[VerificacionesDias] [int] NOT NULL,
	[MantenimientoDias] [int] NOT NULL,
	[Mantenimiento] [bit] NOT NULL,
	[Calibracion] [bit] NOT NULL,
	[Rango] [nvarchar](20) NULL,
	[Resolucion] [nvarchar](20) NULL,
	[FechaUltInv] [datetime] NULL,
	[FechaReqscn] [datetime] NULL,
	[Estatus] [nvarchar](1) NULL,
	[Caracteristicas] [nvarchar](50) NULL,
	[Resguardo] [int] NULL,
	[ResguardoAnterior] [int] NULL,
	[RelId] [int] NULL,
	[ValorRescate] [dbo].[dmoney] NULL,
	[ValorActual] [dbo].[dmoney] NULL,
	[Antiguedad] [int] NULL,
	[Progresivo] [int] NULL,
	[Consecutivo] [int] NULL,
	[ClaveHist] [nvarchar](50) NULL,
	[EstaResguardado] [bit] NULL,
	[FechaResguardado] [datetime] NULL,
	[Localizado] [bit] NULL,
	[esContabilizado] [bit] NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime] NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Bien] PRIMARY KEY CLUSTERED 
(
	[PKIdBien] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ALMA].[Conteo] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMA].[Conteo](
	[PKIdConteo] [int] IDENTITY(1,1) NOT NULL,
	[FKIdTipoBien_ALMA] [int] NOT NULL,
	[CantidadInventario] [decimal](18, 2) NOT NULL,
	[Descripcion] [nvarchar](max) NOT NULL,
	[FechaInicio] [datetime] NOT NULL,
	[FechaFin] [datetime] NULL,
	[FKIdPeriodoConteo_ALMA] [int] NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime] NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Conteo] PRIMARY KEY CLUSTERED 
(
	[PKIdConteo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Objeto: Table [ALMA].[ConteoDetalle] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMA].[ConteoDetalle](
	[PKIdDetalleConteo] [int] IDENTITY(1,1) NOT NULL,
	[FKIdConteo_ALMA] [int] NOT NULL,
	[FKIdNumeroConteo_ALMA] [int] NOT NULL,
	[FKIdPersona_NOM] [int] NOT NULL,
	[Cantidad] [decimal](18, 2) NOT NULL,
	[Fecha] [datetime] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime] NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_ConteoDetalle] PRIMARY KEY CLUSTERED 
(
	[PKIdDetalleConteo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ALMA].[ConteoDetalleEscaneo] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMA].[ConteoDetalleEscaneo](
	[PKIdDetalleEscaneo] [int] IDENTITY(1,1) NOT NULL,
	[FKIdConteo_ALMA] [int] NOT NULL,
	[FKIdPersona_NOM] [int] NOT NULL,
	[CodigoBarras] [nvarchar](100) NOT NULL,
	[FKIdTipoBien_ALMA] [int] NOT NULL,
	[FKIdBien_ALMA] [int] NULL,
	[FechaEscaneo] [datetime] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime] NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_ConteoDetalleEscaneo] PRIMARY KEY CLUSTERED 
(
	[PKIdDetalleEscaneo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ALMA].[ConteoHist] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMA].[ConteoHist](
	[PKIdConteoHist] [int] IDENTITY(1,1) NOT NULL,
	[PKIdConteo] [int] NOT NULL,
	[FKIdTipoBien_ALMA] [int] NOT NULL,
	[CantidadInventario] [decimal](18, 2) NOT NULL,
	[Descripcion] [nvarchar](max) NOT NULL,
	[FechaInicio] [datetime] NOT NULL,
	[FechaFin] [datetime] NULL,
	[PrimerConteo] [decimal](18, 2) NOT NULL,
	[SegundoConteo] [decimal](18, 2) NOT NULL,
	[TercerConteo] [decimal](18, 2) NOT NULL,
	[Diferencias] [nvarchar](max) NOT NULL,
	[Nivel] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime] NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_ConteoHist] PRIMARY KEY CLUSTERED 
(
	[PKIdConteoHist] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Objeto: Table [ALMA].[EstadoBien] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMA].[EstadoBien](
	[PKIdEstadoBien] [int] IDENTITY(1,1) NOT NULL,
	[DESCRIPCION_GENERAL] [nvarchar](150) NOT NULL,
	[DESCRIPCION_ESPECIFICA] [nvarchar](200) NOT NULL,
	[DESCRIPCION_CORTA] [nvarchar](100) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime] NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_EstadoBien] PRIMARY KEY CLUSTERED 
(
	[PKIdEstadoBien] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ALMA].[EstatusArticuloConteo] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMA].[EstatusArticuloConteo](
	[PKIdEstatusArticulo] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](30) NOT NULL,
	[Descripcion] [nvarchar](100) NULL,
	[Orden] [int] NOT NULL,
	[Color] [nvarchar](8) NULL,
	[Icono] [nvarchar](30) NULL,
	[BadgeTexto] [nvarchar](50) NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_EstatusArticuloConteo] PRIMARY KEY CLUSTERED 
(
	[PKIdEstatusArticulo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_EstatusArticuloConteo_Nombre] UNIQUE NONCLUSTERED 
(
	[Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ALMA].[EstatusPeriodo] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMA].[EstatusPeriodo](
	[PKIdEstatusPeriodo] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](30) NOT NULL,
	[Descripcion] [nvarchar](100) NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_EstatusPeriodo] PRIMARY KEY CLUSTERED 
(
	[PKIdEstatusPeriodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_EstatusPeriodo_Nombre] UNIQUE NONCLUSTERED 
(
	[Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ALMA].[EstatusSolicitud] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMA].[EstatusSolicitud](
	[PKIdEstatusSolicitud] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](150) NOT NULL,
	[Color] [nvarchar](8) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_EstatusSolicitud] PRIMARY KEY CLUSTERED 
(
	[PKIdEstatusSolicitud] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ALMA].[Familia] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMA].[Familia](
	[PKIdFamilia] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](80) NOT NULL,
	[Clave] [nvarchar](50) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Familia] PRIMARY KEY CLUSTERED 
(
	[PKIdFamilia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ALMA].[GrupoBien] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMA].[GrupoBien](
	[PKIdGrupoBien] [int] IDENTITY(1,1) NOT NULL,
	[FKIdFamilia_ALMA] [int] NOT NULL,
	[Descripcion] [nvarchar](800) NULL,
	[Clave] [int] NULL,
	[ClaveAN] [nvarchar](50) NULL,
	[CABM_ACT] [nvarchar](50) NULL,
	[CLAVE_CUCOP] [nvarchar](50) NULL,
	[MEDIDA] [nvarchar](50) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_GrupoBien] PRIMARY KEY CLUSTERED 
(
	[PKIdGrupoBien] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ALMA].[Marca] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMA].[Marca](
	[PKIdMarca] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](50) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Marca] PRIMARY KEY CLUSTERED 
(
	[PKIdMarca] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ALMA].[Material] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMA].[Material](
	[PKIdMaterial] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](50) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime] NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Material] PRIMARY KEY CLUSTERED 
(
	[PKIdMaterial] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ALMA].[MotivoES] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMA].[MotivoES](
	[PKIdMotivoES] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](50) NOT NULL,
	[AplicaEntrada] [bit] NOT NULL,
	[AplicaSalida] [bit] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_MotivoES] PRIMARY KEY CLUSTERED 
(
	[PKIdMotivoES] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ALMA].[Nivel] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMA].[Nivel](
	[PKIdNivel] [int] IDENTITY(1,1) NOT NULL,
	[Nivel] [int] NOT NULL,
	[Descripcion] [nvarchar](20) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime] NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Nivel] PRIMARY KEY CLUSTERED 
(
	[PKIdNivel] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ALMA].[PeriodoConteo] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMA].[PeriodoConteo](
	[PKIdPeriodoConteo] [int] IDENTITY(1,1) NOT NULL,
	[FKIdSucursal_SIS] [int] NOT NULL,
	[FKIdTipoConteo_ALMA] [int] NOT NULL,
	[FKIdEstatus_ALMA] [int] NOT NULL,
	[CodigoPeriodo] [nvarchar](20) NOT NULL,
	[Nombre] [nvarchar](100) NOT NULL,
	[Descripcion] [nvarchar](500) NULL,
	[FechaInicio] [date] NOT NULL,
	[FechaFin] [date] NULL,
	[FechaCierre] [datetime] NULL,
	[MaximoConteosPorArticulo] [int] NOT NULL,
	[RequiereAprobacionSupervisor] [bit] NOT NULL,
	[FKIdResponsable_SIS] [int] NULL,
	[FKIdSupervisor_SIS] [int] NULL,
	[TotalArticulos] [int] NULL,
	[ArticulosConcluidos] [int] NULL,
	[ArticulosConDiferencia] [int] NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime] NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_PeriodoConteo] PRIMARY KEY CLUSTERED 
(
	[PKIdPeriodoConteo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_PeriodoConteo_Codigo] UNIQUE NONCLUSTERED 
(
	[FKIdSucursal_SIS] ASC,
	[CodigoPeriodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ALMA].[TipoAdquisicion] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMA].[TipoAdquisicion](
	[PKIdTipoAdq] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [nvarchar](10) NOT NULL,
	[Descripcion] [nvarchar](100) NOT NULL,
	[Descripmovto] [nvarchar](100) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_TipoAdquisicion] PRIMARY KEY CLUSTERED 
(
	[PKIdTipoAdq] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ALMA].[TipoBien] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMA].[TipoBien](
	[PKIdTipoBien] [int] IDENTITY(1,1) NOT NULL,
	[FKIdGrupoBien_ALMA] [int] NULL,
	[FKIdNivel_ALMA] [int] NULL,
	[FKIdPartida_CONTA] [int] NULL,
	[FKIdCuentaContable_CONTA] [int] NULL,
	[FKIdUnidades_ALMA] [int] NULL,
	[FKIdLocalizacion_ALMA] [int] NULL,
	[CodigoClave] [nvarchar](200) NULL,
	[Descripcion] [nvarchar](1200) NULL,
	[DepreciacionAnual] [decimal](18, 4) NULL,
	[Consecutivo] [int] NULL,
	[CABMS] [nvarchar](50) NULL,
	[Identificador] [nvarchar](50) NULL,
	[ExistenciaMinima] [decimal](18, 4) NULL,
	[ExistenciaMaxima] [decimal](18, 4) NULL,
	[TiempoVida] [int] NULL,
	[Pk_IdTratadoInt] [int] NULL,
	[Cuota] [numeric](8, 2) NULL,
	[ProveeduriaNac] [bit] NULL,
	[CatalogoBasico] [bit] NULL,
	[CUCOP_PLUS] [varchar](25) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime] NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[UsuarioModificacion] [int] NULL,
	[FKIdUnidades_Equivalente] [int] NULL,
	[Cantidad_Equivalente] [int] NULL,
 CONSTRAINT [PK_TipoBien] PRIMARY KEY CLUSTERED 
(
	[PKIdTipoBien] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ALMA].[TipoConteo] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMA].[TipoConteo](
	[PKIdTipoConteo] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](30) NOT NULL,
	[Descripcion] [nvarchar](100) NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_TipoConteo] PRIMARY KEY CLUSTERED 
(
	[PKIdTipoConteo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ALMA].[TipoPatrimonio] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMA].[TipoPatrimonio](
	[PKIdTipoPatrimonio] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](50) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_TipoPatrimonio] PRIMARY KEY CLUSTERED 
(
	[PKIdTipoPatrimonio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ALMA].[Unidades] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMA].[Unidades](
	[PKIdUnidades] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](50) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Unidades] PRIMARY KEY CLUSTERED 
(
	[PKIdUnidades] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [CONTA].[Capitulo] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CONTA].[Capitulo](
	[PKIdCapitulo] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [nvarchar](30) NULL,
	[Descripcion] [nvarchar](120) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime] NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Capitulo] PRIMARY KEY CLUSTERED 
(
	[PKIdCapitulo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [CONTA].[Concepto] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CONTA].[Concepto](
	[PKIdConcepto] [int] IDENTITY(1,1) NOT NULL,
	[FKIdCapitulo_CONTA] [int] NOT NULL,
	[Clave] [nvarchar](30) NULL,
	[Descripcion] [nvarchar](120) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime] NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Concepto] PRIMARY KEY CLUSTERED 
(
	[PKIdConcepto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [CONTA].[ConsecutivoPoliza] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CONTA].[ConsecutivoPoliza](
	[PKIdConsecutivoPoliza] [int] IDENTITY(1,1) NOT NULL,
	[FK_IdAnio__SIS] [int] NOT NULL,
	[FK_IdMes__SIS] [int] NOT NULL,
	[FK_IdTipoPoliza__SIS] [int] NOT NULL,
	[UltimoValor] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_ConsecutivoPoliza] PRIMARY KEY CLUSTERED 
(
	[PKIdConsecutivoPoliza] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_ConsecutivoPoliza] UNIQUE NONCLUSTERED 
(
	[FK_IdAnio__SIS] ASC,
	[FK_IdMes__SIS] ASC,
	[FK_IdTipoPoliza__SIS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [CONTA].[CuentaContable] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CONTA].[CuentaContable](
	[PKIdCuentaContable] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdTipoCuenta_CONTA] [int] NOT NULL,
	[Cuenta] [nvarchar](5) NOT NULL,
	[SubCuenta] [nvarchar](5) NOT NULL,
	[SubSubCuenta] [nvarchar](5) NOT NULL,
	[SubSubSubCuenta] [nvarchar](5) NOT NULL,
	[SubSubSubSubCuenta] [nvarchar](5) NOT NULL,
	[Saldo] [numeric](18, 2) NOT NULL,
	[Descripcion] [varchar](250) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime] NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[UsuarioModificacion] [int] NULL,
	[S5] [nvarchar](5) NULL,
	[S6] [nvarchar](5) NULL,
	[S7] [nvarchar](5) NULL,
	[ClaveOrd] [varchar](50) NULL,
	[Padre] [varchar](10) NULL,
	[Hijo] [varchar](20) NULL,
	[NivelCuenta] [int] NULL,
	[Cta_Coi] [nvarchar](20) NULL,
	[Desc_Coi] [nvarchar](160) NULL,
	[TipoCuenta] [nchar](1) NULL,
	[S8] [nvarchar](5) NULL,
	[S9] [nvarchar](5) NULL,
	[S10] [nvarchar](5) NULL,
	[IsCuentaDetalle]  AS (case when [TipoCuenta]='D' then (1) else (0) end),
 CONSTRAINT [PK_CuentaContable] PRIMARY KEY CLUSTERED 
(
	[PKIdCuentaContable] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [CONTA].[MatrizConversion] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CONTA].[MatrizConversion](
	[PKIdMatrizConversion] [int] IDENTITY(1,1) NOT NULL,
	[FKIdAnio_SIS] [int] NOT NULL,
	[FKIdPrograma_PRES] [int] NOT NULL,
	[FKIdPartida_SIS] [int] NOT NULL,
	[FKIdCuentaContableAprobado] [int] NOT NULL,
	[FKIdCuentaContablePorEjercer] [int] NOT NULL,
	[FKIdCuentaContableModificado] [int] NOT NULL,
	[FKIdCuentaContableComprometido] [int] NOT NULL,
	[FKIdCuentaContableDevengado] [int] NOT NULL,
	[FKIdCuentaContableEjercido] [int] NOT NULL,
	[FKIdCuentaContablePagado] [int] NOT NULL,
	[FKIdCuentaContableGasto] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_MatrizConversion] PRIMARY KEY CLUSTERED 
(
	[PKIdMatrizConversion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [CONTA].[MatrizIngreso] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CONTA].[MatrizIngreso](
	[Pk_IdMatrizIngreso] [int] IDENTITY(1,1) NOT NULL,
	[Fk_IdPrograma] [int] NULL,
	[Fk_IdOrigen] [int] NULL,
	[Fk_IdCuentaContableAutorizado] [int] NULL,
	[Fk_IdCuentaContablePorEjercer] [int] NULL,
	[Fk_IdCuentaContableModificado] [int] NULL,
	[Fk_IdCuentaContableDevengado] [int] NULL,
	[Fk_IdCuentaContableRecaudado] [int] NULL,
	[Fk_IdCuentaContableDeposito] [int] NULL,
	[FK_IdAnio__SIS] [int] NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_MatrizIngreso] PRIMARY KEY CLUSTERED 
(
	[Pk_IdMatrizIngreso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [CONTA].[Partida] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CONTA].[Partida](
	[PKIdPartida] [int] IDENTITY(1,1) NOT NULL,
	[FKIdConcepto_SIS] [int] NULL,
	[Clave] [nvarchar](10) NOT NULL,
	[Descripcion] [nvarchar](255) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime] NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Partida] PRIMARY KEY CLUSTERED 
(
	[PKIdPartida] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [CONTA].[Poliza] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CONTA].[Poliza](
	[PKIdPoliza] [int] IDENTITY(1,1) NOT NULL,
	[FKIdAnio_SIS] [int] NOT NULL,
	[FKIdMes_SIS] [int] NOT NULL,
	[FKIdTipoPoliza_SIS] [int] NOT NULL,
	[ClavePoliza] [nvarchar](10) NOT NULL,
	[NombrePoliza] [nvarchar](1000) NOT NULL,
	[FechaPoliza] [datetime] NOT NULL,
	[EstaBalanceado] [bit] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
	[PermitirModificar] [bit] NULL,
	[FKIdAccionAutorizar_SIS] [int] NULL,
	[Autorizado] [bit] NULL,
	[FechaSolicitud] [datetime] NULL,
	[FechaAutorizacion] [datetime] NULL,
 CONSTRAINT [PK_Poliza] PRIMARY KEY CLUSTERED 
(
	[PKIdPoliza] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [CONTA].[PolizaDetalle] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CONTA].[PolizaDetalle](
	[PKIdPolizaDetalle] [int] IDENTITY(1,1) NOT NULL,
	[FKIdCuentaContable_CONTA] [int] NOT NULL,
	[FKIdPoliza_CONTA] [int] NOT NULL,
	[Descripcion] [nvarchar](600) NULL,
	[ImporteDebe] [dbo].[dmoney] NULL,
	[ImporteHaber] [dbo].[dmoney] NULL,
	[FKIdReferencia] [int] NULL,
	[FKIdTipoDetallePoliza_SIS] [int] NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_PolizaDetalle] PRIMARY KEY CLUSTERED 
(
	[PKIdPolizaDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [CONTA].[TipoCuenta] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CONTA].[TipoCuenta](
	[PKIdTipoCuenta] [int] IDENTITY(1,1) NOT NULL,
	[Color] [nvarchar](5) NOT NULL,
	[Descripcion] [nvarchar](25) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime] NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_TipoCuenta] PRIMARY KEY CLUSTERED 
(
	[PKIdTipoCuenta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [CONTA].[TipoDoctoPago] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CONTA].[TipoDoctoPago](
	[PKIdTipoDoctoPago] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](50) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_TipoDoctoPago] PRIMARY KEY CLUSTERED 
(
	[PKIdTipoDoctoPago] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[AspNetClaims] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetClaims](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ClaimTypeId] [int] NULL,
	[Name] [nvarchar](150) NOT NULL,
	[Group] [nvarchar](100) NULL,
	[RoleId] [nvarchar](128) NULL,
	[TokenFormat] [nvarchar](50) NULL,
	[Created] [datetime] NOT NULL,
	[SubGroup] [nvarchar](100) NULL,
	[Code] [nvarchar](10) NULL,
	[Description] [nvarchar](200) NULL,
	[Values] [varchar](max) NULL,
	[ReferenceId] [int] NOT NULL,
 CONSTRAINT [CONSTRAINT_PK_AspNetClaims] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[AspNetClaimTypes] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetClaimTypes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Created] [datetime] NOT NULL,
 CONSTRAINT [CONSTRAINT_PK_AspNetClaimTypes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[AspNetClaimValues] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetClaimValues](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ClaimId] [int] NULL,
	[Value] [nvarchar](128) NOT NULL,
	[Created] [datetime] NOT NULL,
 CONSTRAINT [CONSTRAINT_PK_AspNetClaimValues] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[AspNetRoles] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetRoles](
	[Id] [nvarchar](128) NOT NULL,
	[Name] [nvarchar](256) NOT NULL,
	[Code] [nvarchar](10) NULL,
 CONSTRAINT [CONSTRAINT_PK_AspNetRoles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [CONSTRAINT_UX_AspNetRoles_Name] UNIQUE NONCLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[AspNetUserRoles] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserRoles](
	[UserId] [nvarchar](128) NOT NULL,
	[RoleId] [nvarchar](128) NOT NULL,
	[ExpireDate] [datetime] NULL,
 CONSTRAINT [CONSTRAINT_PK_AspNetUserRoles] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[AspNetUsers] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUsers](
	[Id] [nvarchar](128) NOT NULL,
	[Email] [nvarchar](256) NULL,
	[EmailConfirmed] [bit] NOT NULL,
	[PasswordHash] [nvarchar](max) NULL,
	[SecurityStamp] [nvarchar](max) NULL,
	[PhoneNumber] [nvarchar](max) NULL,
	[PhoneNumberConfirmed] [bit] NOT NULL,
	[TwoFactorEnabled] [bit] NOT NULL,
	[LockoutEndDateUtc] [datetime] NULL,
	[LockoutEnabled] [bit] NOT NULL,
	[AccessFailedCount] [int] NOT NULL,
	[ReferenceId] [int] NULL,
	[AccessNumber] [nvarchar](25) NULL,
	[PkIdUsuario] [int] NULL,
 CONSTRAINT [CONSTRAINT_PK_AspNetUsers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Objeto: Table [NOM].[Persona] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [NOM].[Persona](
	[PKIdPersona] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [nvarchar](15) NOT NULL,
	[Iniciales] [nvarchar](3) NULL,
	[Nombre] [nvarchar](50) NOT NULL,
	[Paterno] [nvarchar](50) NOT NULL,
	[Materno] [nvarchar](50) NOT NULL,
	[Sexo] [nvarchar](10) NULL,
	[FechaNacimiento] [datetime] NOT NULL,
	[ESTADO_CIVIL] [nvarchar](20) NULL,
	[RFC] [nvarchar](15) NOT NULL,
	[Curp] [nvarchar](18) NOT NULL,
	[REG_IMSS] [nvarchar](12) NULL,
	[NoCartilla] [nvarchar](16) NULL,
	[NoLicencia] [nvarchar](16) NULL,
	[NoPasaporte] [nvarchar](16) NULL,
	[NoCredencialElector] [nvarchar](32) NULL,
	[Gafete] [nvarchar](11) NULL,
	[CORREO_ELECTRONICO] [nvarchar](250) NULL,
	[Telefono_particular] [nvarchar](15) NULL,
	[Telefono_movil] [nvarchar](15) NULL,
	[Calle] [nvarchar](40) NULL,
	[Num_exterior] [nvarchar](10) NULL,
	[Num_interior] [nvarchar](10) NULL,
	[Colonia] [nvarchar](40) NULL,
	[CP] [nvarchar](6) NULL,
	[Municipio] [nvarchar](20) NULL,
	[Estado] [nvarchar](30) NULL,
	[Fecha_de_Inicio] [datetime] NOT NULL,
	[Fecha_Fin] [datetime] NULL,
	[TIPO_CONTRATACION] [nvarchar](50) NULL,
	[PUESTO] [nvarchar](100) NULL,
	[SUELDO_BASE] [float] NULL,
	[COMPENSACION_GARANTIZADA] [float] NULL,
	[BANCO] [nvarchar](100) NULL,
	[NUMERO_CUENTA] [nvarchar](25) NULL,
	[CLABE] [nvarchar](50) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Persona] PRIMARY KEY CLUSTERED 
(
	[PKIdPersona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [NOM].[PersonaArea] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [NOM].[PersonaArea](
	[PKIdPersonaArea] [int] IDENTITY(1,1) NOT NULL,
	[FKIdPersona_NOM] [int] NOT NULL,
	[FKIdArea_SIS] [int] NOT NULL,
	[IsAdscrito] [bit] NOT NULL,
	[EsSolicitante] [bit] NULL,
	[EsAutorizador] [bit] NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime] NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_PersonaArea] PRIMARY KEY CLUSTERED 
(
	[PKIdPersonaArea] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ORCO].[Articulo] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ORCO].[Articulo](
	[PKIdArticulo] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [nvarchar](20) NOT NULL,
	[Descripcion] [nvarchar](250) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Articulo] PRIMARY KEY CLUSTERED 
(
	[PKIdArticulo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ORCO].[Cotizacion] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ORCO].[Cotizacion](
	[PKIdCotizacion] [int] IDENTITY(1,1) NOT NULL,
	[FKIdRequisicion_ORCO] [int] NOT NULL,
	[FKIdProveedor_SIS] [int] NOT NULL,
	[FechaSolicitud] [datetime] NOT NULL,
	[FechaProveedorCotiza] [datetime] NULL,
	[FechaProveedorCompromiso] [datetime] NULL,
	[Comentarios] [nvarchar](max) NULL,
	[Servicio] [bit] NOT NULL,
	[FL_Documento] [nvarchar](1000) NULL,
	[Entrega] [nvarchar](max) NULL,
	[Vigencia] [nvarchar](max) NULL,
	[Condiciones] [nvarchar](200) NULL,
	[FKIdAnio_SIS] [int] NULL,
	[FKIdContenedorCot_ORCO] [int] NULL,
	[FKIdContenedorMultiCot_ORCO] [int] NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NOT NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Cotizacion] PRIMARY KEY CLUSTERED 
(
	[PKIdCotizacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Objeto: Table [ORCO].[CotizacionDetalle] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ORCO].[CotizacionDetalle](
	[PKIdCotizacionDetalle] [int] IDENTITY(1,1) NOT NULL,
	[FKIdCotizacion_ORCO] [int] NOT NULL,
	[FKIdRequisicionDetalle_ORCO] [int] NOT NULL,
	[PrecioUnitario] [dbo].[dmoney] NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NOT NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_CotizacionDetalle] PRIMARY KEY CLUSTERED 
(
	[PKIdCotizacionDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ORCO].[EstatusRequisicion] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ORCO].[EstatusRequisicion](
	[PKIdEstatusRequisicion] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](50) NOT NULL,
	[Color] [nvarchar](8) NULL,
	[Orden] [int] NOT NULL,
	[Icono] [nvarchar](50) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_EstatusRequisicion] PRIMARY KEY CLUSTERED 
(
	[PKIdEstatusRequisicion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ORCO].[EstudioMercado] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ORCO].[EstudioMercado](
	[PKIdEstudioMercado] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdAnio_SIS] [int] NOT NULL,
	[Nombre] [varchar](80) NOT NULL,
	[Descripcion] [nvarchar](500) NULL,
	[FechaSolicitud] [datetime] NOT NULL,
	[FechaCierre] [datetime] NULL,
	[FKIdResponsable_NOM] [int] NOT NULL,
	[Estatus] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_EstudioMercado] PRIMARY KEY CLUSTERED 
(
	[PKIdEstudioMercado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ORCO].[EstudioMercadoDetalle] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ORCO].[EstudioMercadoDetalle](
	[PKIdEstudioMercadoDetalle] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdEstudioMercado_ORCO] [int] NOT NULL,
	[FKIdPAAASDetalle_ORCO] [int] NOT NULL,
	[FKIdTipoBien_ALMA] [int] NOT NULL,
	[Cantidad] [numeric](8, 2) NOT NULL,
	[Observaciones] [nvarchar](max) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
	[FKIdProveedor_SIS] [int] NULL,
	[CostoUnitario] [decimal](20, 4) NULL,
 CONSTRAINT [PK_EstudioMercadoDetalle] PRIMARY KEY CLUSTERED 
(
	[PKIdEstudioMercadoDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Objeto: Table [ORCO].[EstudioMercadoDetalleCosto] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ORCO].[EstudioMercadoDetalleCosto](
	[PKIdEstudioMercadoDetalleCosto] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdSolicitudCotizacion_ORCO] [int] NOT NULL,
	[FKIdEstudioMercadoDetalle_ORCO] [int] NOT NULL,
	[PrecioUnitario] [dbo].[dmoney] NULL,
	[TiempoEntregaDias] [int] NULL,
	[Condiciones] [nvarchar](500) NULL,
	[FechaRespuesta] [datetime] NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_EstudioMercadoDetalleCosto] PRIMARY KEY CLUSTERED 
(
	[PKIdEstudioMercadoDetalleCosto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ORCO].[Fraccion] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ORCO].[Fraccion](
	[PKIdFraccion] [int] IDENTITY(1,1) NOT NULL,
	[FKIdArticulo_ORCO] [int] NOT NULL,
	[Clave] [nvarchar](20) NOT NULL,
	[Descripcion] [nvarchar](250) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Fraccion] PRIMARY KEY CLUSTERED 
(
	[PKIdFraccion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ORCO].[Modalidad] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ORCO].[Modalidad](
	[PKIdModalidad] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](30) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Modalidad] PRIMARY KEY CLUSTERED 
(
	[PKIdModalidad] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ORCO].[PAAAS] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ORCO].[PAAAS](
	[PKIdPAAAS] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdAnio_SIS] [int] NOT NULL,
	[FKIdArea_SIS] [int] NOT NULL,
	[FKIdPersona_NOM] [int] NOT NULL,
	[Descripcion] [nvarchar](100) NOT NULL,
	[Observaciones] [nvarchar](1000) NULL,
	[Fecha] [datetime] NOT NULL,
	[FKIdProyecto_ORCO] [int] NULL,
	[FKIdPrograma_PRES] [int] NULL,
	[FKIdFuenteFinanciamiento_PRES] [int] NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_PAAAS] PRIMARY KEY CLUSTERED 
(
	[PKIdPAAAS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_PAAAS_Area_Anio] UNIQUE NONCLUSTERED 
(
	[FKIdArea_SIS] ASC,
	[FKIdAnio_SIS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ORCO].[PAAASDetalle] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ORCO].[PAAASDetalle](
	[PKIdPAAASDetalle] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdPAAASPartida_ORCO] [int] NOT NULL,
	[FKIdTipoBien_ALMA] [int] NOT NULL,
	[FKIdUnidades_ALMA] [int] NULL,
	[Cantidad] [numeric](8, 2) NOT NULL,
	[Observaciones] [nvarchar](max) NOT NULL,
	[LugarEntrega] [varchar](200) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_PAAASDetalle] PRIMARY KEY CLUSTERED 
(
	[PKIdPAAASDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Objeto: Table [ORCO].[PAAASPartida] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ORCO].[PAAASPartida](
	[PKIdPAAASPartida] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdPAAAS_ORCO] [int] NOT NULL,
	[FKIdPartida_CONTA] [int] NOT NULL,
	[Observaciones] [nvarchar](1000) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_PAAASPartida] PRIMARY KEY CLUSTERED 
(
	[PKIdPAAASPartida] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ORCO].[ProcedimientoContratacion] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ORCO].[ProcedimientoContratacion](
	[PKIdProcedimientoContratacion] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](50) NOT NULL,
	[FundamentoJuridico] [text] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_ProcedimientoContratacion] PRIMARY KEY CLUSTERED 
(
	[PKIdProcedimientoContratacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Objeto: Table [ORCO].[Proyecto] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ORCO].[Proyecto](
	[PKIdProyecto] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](max) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Proyecto] PRIMARY KEY CLUSTERED 
(
	[PKIdProyecto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Objeto: Table [ORCO].[Requisicion] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ORCO].[Requisicion](
	[PKIdRequisicion] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdPersona_NOM] [int] NOT NULL,
	[FKIdArea_SIS] [int] NOT NULL,
	[Descripcion] [nvarchar](100) NOT NULL,
	[Observaciones] [nvarchar](1000) NULL,
	[FechaRequisicion] [datetime] NOT NULL,
	[Servicio] [bit] NOT NULL,
	[FL_FOTO] [nvarchar](1000) NULL,
	[FKIdProyecto_ORCO] [int] NULL,
	[FechaRequiereInicio] [datetime] NULL,
	[FechaRequiereFin] [datetime] NULL,
	[FKIdPrograma_PRES] [int] NULL,
	[Importe] [dbo].[dmoney] NULL,
	[FKIdJefeAlmacen_NOM] [int] NULL,
	[FKIdSuficiencia_PRES] [int] NULL,
	[FKIdSuperviso_NOM] [int] NULL,
	[FKIdAutorizo_NOM] [int] NULL,
	[FKIdPSolicita_NOM] [int] NULL,
	[FKIdPJefeAlmacen_NOM] [int] NULL,
	[FKIdPSuficiencia_NOM] [int] NULL,
	[FKIdPSuperviso_NOM] [int] NULL,
	[FKIdPAutorizo_NOM] [int] NULL,
	[FKIdFuenteFinanciamiento_PRES] [int] NULL,
	[FKIdAnio_SIS] [int] NULL,
	[FKIdTipoGasto_PRES] [int] NULL,
	[FKIdDigitoIdentificador_PRES] [int] NULL,
	[FKIdDestinoGasto_PRES] [int] NULL,
	[FKIdEgresoAutorizado_PRES] [int] NULL,
	[Oficio] [varchar](120) NULL,
	[FechaOficio] [datetime] NULL,
	[CompraDirecta] [bit] NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Requisicion] PRIMARY KEY CLUSTERED 
(
	[PKIdRequisicion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ORCO].[RequisicionDetalle] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ORCO].[RequisicionDetalle](
	[PKIdRequisicionDetalle] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdRequisicion_ORCO] [int] NOT NULL,
	[FKIdTipoBien_ALMA] [int] NOT NULL,
	[FKIdUnidades_ALMA] [int] NULL,
	[Cantidad] [numeric](8, 2) NOT NULL,
	[Observaciones] [nvarchar](max) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_RequisicionDetalle] PRIMARY KEY CLUSTERED 
(
	[PKIdRequisicionDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Objeto: Table [ORCO].[RequisicionPartida] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ORCO].[RequisicionPartida](
	[PKIdRequisicionPartida] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdRequisicion_ORCO] [int] NOT NULL,
	[FKIdPartida_CONTA] [int] NOT NULL,
	[Monto] [dbo].[dmoney] NULL,
	[Observaciones] [nvarchar](500) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_RequisicionPartida] PRIMARY KEY CLUSTERED 
(
	[PKIdRequisicionPartida] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ORCO].[SolicitudCotizacion] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ORCO].[SolicitudCotizacion](
	[PKIdSolicitudCotizacion] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdEstudioMercado_ORCO] [int] NOT NULL,
	[FKIdProveedor_SIS] [int] NOT NULL,
	[FechaSolicitud] [datetime] NOT NULL,
	[FechaCompromisoEntrega] [datetime] NULL,
	[Comentarios] [text] NULL,
	[FL_Documento] [nvarchar](1000) NULL,
	[Estatus] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_SolicitudCotizacion] PRIMARY KEY CLUSTERED 
(
	[PKIdSolicitudCotizacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Objeto: Table [ORCO].[TipoContrato] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ORCO].[TipoContrato](
	[PKIdTipoContrato] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](25) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_TipoContrato] PRIMARY KEY CLUSTERED 
(
	[PKIdTipoContrato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ORCO].[TipoDocumento] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ORCO].[TipoDocumento](
	[PKIdTipoDocumento] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](25) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_TipoDocumento] PRIMARY KEY CLUSTERED 
(
	[PKIdTipoDocumento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [ORCO].[TipoGarantia] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ORCO].[TipoGarantia](
	[PKIdTipoGarantia] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](25) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_TipoGarantia] PRIMARY KEY CLUSTERED 
(
	[PKIdTipoGarantia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[AutorizacionSuficiencia] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[AutorizacionSuficiencia](
	[PKIdAutorizacionSuficiencia] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdSolicitudSuficiencia_PRES] [int] NOT NULL,
	[FechaAutorizacion] [date] NOT NULL,
	[Justificacion] [nvarchar](250) NOT NULL,
	[GastoNoProgramable] [varchar](3) NULL,
	[IdGastoNoProgramable] [int] NULL,
	[IdCompromisoNomina] [int] NULL,
	[AutorizadoPor_NOM] [int] NOT NULL,
	[Observaciones] [nvarchar](500) NULL,
	[Estatus] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_AutorizacionSuficiencia] PRIMARY KEY CLUSTERED 
(
	[PKIdAutorizacionSuficiencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[AutorizacionSuficienciaDetalle] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[AutorizacionSuficienciaDetalle](
	[PKIdAutorizacionSuficienciaDetalle] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdAutorizacionSuficiencia_PRES] [int] NOT NULL,
	[FKIdSolicitudSuficienciaDetalle_PRES] [int] NOT NULL,
	[FKIdPartida_CONTA] [int] NOT NULL,
	[Enero] [dbo].[dmoney] NULL,
	[Febrero] [dbo].[dmoney] NULL,
	[Marzo] [dbo].[dmoney] NULL,
	[Abril] [dbo].[dmoney] NULL,
	[Mayo] [dbo].[dmoney] NULL,
	[Junio] [dbo].[dmoney] NULL,
	[Julio] [dbo].[dmoney] NULL,
	[Agosto] [dbo].[dmoney] NULL,
	[Septiembre] [dbo].[dmoney] NULL,
	[Octubre] [dbo].[dmoney] NULL,
	[Noviembre] [dbo].[dmoney] NULL,
	[Diciembre] [dbo].[dmoney] NULL,
	[Total]  AS (((((((((((isnull([Enero],(0))+isnull([Febrero],(0)))+isnull([Marzo],(0)))+isnull([Abril],(0)))+isnull([Mayo],(0)))+isnull([Junio],(0)))+isnull([Julio],(0)))+isnull([Agosto],(0)))+isnull([Septiembre],(0)))+isnull([Octubre],(0)))+isnull([Noviembre],(0)))+isnull([Diciembre],(0))),
	[Observaciones] [nvarchar](500) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_AutorizacionSuficienciaDetalle] PRIMARY KEY CLUSTERED 
(
	[PKIdAutorizacionSuficienciaDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[Cheque] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[Cheque](
	[PKIdCheque] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdCLC_PRES] [int] NOT NULL,
	[FKIdCuentaBancaria_TES] [int] NOT NULL,
	[FKIdPoliza_CONTA] [int] NOT NULL,
	[FechaEmision] [date] NOT NULL,
	[NumeroCheque] [nvarchar](50) NOT NULL,
	[Concepto] [nvarchar](150) NOT NULL,
	[ImporteTotal] [dbo].[dmoney] NOT NULL,
	[Observaciones] [nvarchar](500) NULL,
	[Estatus] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Cheque] PRIMARY KEY CLUSTERED 
(
	[PKIdCheque] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[ChequePartidas] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[ChequePartidas](
	[PKIdChequePartida] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdCheque_PRES] [int] NOT NULL,
	[FKIdCLCDetalle_PRES] [int] NOT NULL,
	[FKIdPartida_CONTA] [int] NOT NULL,
	[MontoPagado] [dbo].[dmoney] NOT NULL,
	[Observaciones] [nvarchar](500) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_ChequePartidas] PRIMARY KEY CLUSTERED 
(
	[PKIdChequePartida] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[CLC] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[CLC](
	[PKIdCLC] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdContrato_PRES] [int] NOT NULL,
	[FKIdPoliza_CONTA] [int] NOT NULL,
	[NumCLC] [nvarchar](20) NOT NULL,
	[FechaSolicitud] [date] NOT NULL,
	[FechaAutorizacion] [date] NULL,
	[ImporteTotal] [dbo].[dmoney] NOT NULL,
	[Observaciones] [nvarchar](500) NULL,
	[Estatus] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_CLC] PRIMARY KEY CLUSTERED 
(
	[PKIdCLC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[CLCDetalle] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[CLCDetalle](
	[PKIdCLCDetalle] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdCLC_PRES] [int] NOT NULL,
	[FKIdContratoDetalle_PRES] [int] NOT NULL,
	[FKIdPartida_CONTA] [int] NOT NULL,
	[Enero] [dbo].[dmoney] NULL,
	[Febrero] [dbo].[dmoney] NULL,
	[Marzo] [dbo].[dmoney] NULL,
	[Abril] [dbo].[dmoney] NULL,
	[Mayo] [dbo].[dmoney] NULL,
	[Junio] [dbo].[dmoney] NULL,
	[Julio] [dbo].[dmoney] NULL,
	[Agosto] [dbo].[dmoney] NULL,
	[Septiembre] [dbo].[dmoney] NULL,
	[Octubre] [dbo].[dmoney] NULL,
	[Noviembre] [dbo].[dmoney] NULL,
	[Diciembre] [dbo].[dmoney] NULL,
	[Total]  AS (((((((((((isnull([Enero],(0))+isnull([Febrero],(0)))+isnull([Marzo],(0)))+isnull([Abril],(0)))+isnull([Mayo],(0)))+isnull([Junio],(0)))+isnull([Julio],(0)))+isnull([Agosto],(0)))+isnull([Septiembre],(0)))+isnull([Octubre],(0)))+isnull([Noviembre],(0)))+isnull([Diciembre],(0))),
	[Observaciones] [nvarchar](500) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_CLCDetalle] PRIMARY KEY CLUSTERED 
(
	[PKIdCLCDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[CLCFactura] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[CLCFactura](
	[PKIdCLCFactura] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdCLC_PRES] [int] NOT NULL,
	[FKIdFactura_PRES] [int] NOT NULL,
	[FKIdFacturaDetalle_PRES] [int] NOT NULL,
	[MontoAplicado] [dbo].[dmoney] NOT NULL,
	[Observaciones] [nvarchar](500) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_CLCFactura] PRIMARY KEY CLUSTERED 
(
	[PKIdCLCFactura] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[Contrato] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[Contrato](
	[PKIdContrato] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdAutorizacionSuficiencia_PRES] [int] NOT NULL,
	[FKIdProveedor_SIS] [int] NOT NULL,
	[FKIdPoliza_CONTA] [int] NULL,
	[NumeroContrato] [nvarchar](50) NOT NULL,
	[Descripcion] [nvarchar](500) NOT NULL,
	[FechaContrato] [date] NOT NULL,
	[FechaInicioVigencia] [date] NULL,
	[FechaFinVigencia] [date] NULL,
	[MontoTotal] [dbo].[dmoney] NOT NULL,
	[PlazoEjecucion] [nvarchar](100) NULL,
	[Observaciones] [nvarchar](max) NULL,
	[Estatus] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Contrato] PRIMARY KEY CLUSTERED 
(
	[PKIdContrato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[ContratoDetalle] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[ContratoDetalle](
	[PKIdContratoDetalle] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdContrato_PRES] [int] NOT NULL,
	[FKIdAutorizacionSuficienciaDetalle_PRES] [int] NOT NULL,
	[FKIdPartida_CONTA] [int] NOT NULL,
	[Enero] [dbo].[dmoney] NULL,
	[Febrero] [dbo].[dmoney] NULL,
	[Marzo] [dbo].[dmoney] NULL,
	[Abril] [dbo].[dmoney] NULL,
	[Mayo] [dbo].[dmoney] NULL,
	[Junio] [dbo].[dmoney] NULL,
	[Julio] [dbo].[dmoney] NULL,
	[Agosto] [dbo].[dmoney] NULL,
	[Septiembre] [dbo].[dmoney] NULL,
	[Octubre] [dbo].[dmoney] NULL,
	[Noviembre] [dbo].[dmoney] NULL,
	[Diciembre] [dbo].[dmoney] NULL,
	[Total]  AS (((((((((((isnull([Enero],(0))+isnull([Febrero],(0)))+isnull([Marzo],(0)))+isnull([Abril],(0)))+isnull([Mayo],(0)))+isnull([Junio],(0)))+isnull([Julio],(0)))+isnull([Agosto],(0)))+isnull([Septiembre],(0)))+isnull([Octubre],(0)))+isnull([Noviembre],(0)))+isnull([Diciembre],(0))),
	[Observaciones] [nvarchar](500) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_ContratoDetalle] PRIMARY KEY CLUSTERED 
(
	[PKIdContratoDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[DestinoGasto] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[DestinoGasto](
	[PKIdDestinoGasto] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [nvarchar](2) NOT NULL,
	[Descripcion] [nvarchar](250) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_DestinoGasto] PRIMARY KEY CLUSTERED 
(
	[PKIdDestinoGasto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[DigitoIdentificador] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[DigitoIdentificador](
	[PKIdDigitoIdentificador] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [nvarchar](1) NOT NULL,
	[Descripcion] [nvarchar](200) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_DigitoIdentificador] PRIMARY KEY CLUSTERED 
(
	[PKIdDigitoIdentificador] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[EgresoAutorizado] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[EgresoAutorizado](
	[PKIdEgresoAutorizado] [int] IDENTITY(1,1) NOT NULL,
	[FKIdPrograma_PRES] [int] NOT NULL,
	[FKIdPartida_CONTA] [int] NOT NULL,
	[FKIdArea_SIS] [int] NOT NULL,
	[Descripcion] [nvarchar](250) NULL,
	[Fecha] [date] NOT NULL,
	[FKIdPoliza_CONTA] [int] NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
	[FKIdEgresoProyectado_PRES] [int] NULL,
	[Enero] [decimal](18, 2) NOT NULL,
	[Febrero] [decimal](18, 2) NOT NULL,
	[Marzo] [decimal](18, 2) NOT NULL,
	[Abril] [decimal](18, 2) NOT NULL,
	[Mayo] [decimal](18, 2) NOT NULL,
	[Junio] [decimal](18, 2) NOT NULL,
	[Julio] [decimal](18, 2) NOT NULL,
	[Agosto] [decimal](18, 2) NOT NULL,
	[Septiembre] [decimal](18, 2) NOT NULL,
	[Octubre] [decimal](18, 2) NOT NULL,
	[Noviembre] [decimal](18, 2) NOT NULL,
	[Diciembre] [decimal](18, 2) NOT NULL,
	[Total]  AS ((((((((((([Enero]+[Febrero])+[Marzo])+[Abril])+[Mayo])+[Junio])+[Julio])+[Agosto])+[Septiembre])+[Octubre])+[Noviembre])+[Diciembre]),
	[FechaAutorizacion] [datetime2](7) NULL,
	[UsuarioAutorizacion] [int] NULL,
	[FKIdFuenteFinanciamiento_PRES] [int] NULL,
	[FKIdTipoGasto_PRES] [int] NULL,
	[FKIdDigitoIdentificador_PRES] [int] NULL,
	[FKIdDestinoGasto_PRES] [int] NULL,
	[FKIdPY_PRES] [int] NULL,
 CONSTRAINT [PK_EgresoAutorizado] PRIMARY KEY CLUSTERED 
(
	[PKIdEgresoAutorizado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[EgresoProyectado] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[EgresoProyectado](
	[PKIdEgresoProyectado] [int] IDENTITY(1,1) NOT NULL,
	[FKIdPrograma_PRES] [int] NOT NULL,
	[FKIdPartida_CONTA] [int] NOT NULL,
	[FKIdArea_SIS] [int] NOT NULL,
	[Descripcion] [nvarchar](250) NULL,
	[Fecha] [date] NOT NULL,
	[Enero] [decimal](18, 2) NOT NULL,
	[Febrero] [decimal](18, 2) NOT NULL,
	[Marzo] [decimal](18, 2) NOT NULL,
	[Abril] [decimal](18, 2) NOT NULL,
	[Mayo] [decimal](18, 2) NOT NULL,
	[Junio] [decimal](18, 2) NOT NULL,
	[Julio] [decimal](18, 2) NOT NULL,
	[Agosto] [decimal](18, 2) NOT NULL,
	[Septiembre] [decimal](18, 2) NOT NULL,
	[Octubre] [decimal](18, 2) NOT NULL,
	[Noviembre] [decimal](18, 2) NOT NULL,
	[Diciembre] [decimal](18, 2) NOT NULL,
	[Total]  AS ((((((((((([Enero]+[Febrero])+[Marzo])+[Abril])+[Mayo])+[Junio])+[Julio])+[Agosto])+[Septiembre])+[Octubre])+[Noviembre])+[Diciembre]),
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
	[FKIdFuenteFinanciamiento_PRES] [int] NULL,
	[FKIdTipoGasto_PRES] [int] NULL,
	[FKIdDigitoIdentificador_PRES] [int] NULL,
	[FKIdDestinoGasto_PRES] [int] NULL,
	[FKIdPY_PRES] [int] NULL,
 CONSTRAINT [PK_EgresoProyectado] PRIMARY KEY CLUSTERED 
(
	[PKIdEgresoProyectado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[Eje] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[Eje](
	[PKIdEje] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [nvarchar](1) NOT NULL,
	[Descripcion] [nvarchar](200) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Eje] PRIMARY KEY CLUSTERED 
(
	[PKIdEje] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[Factura] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[Factura](
	[PKIdFactura] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdContrato_PRES] [int] NOT NULL,
	[FKIdPoliza_CONTA] [int] NOT NULL,
	[NumFactura] [nvarchar](250) NOT NULL,
	[SerieFactura] [nvarchar](20) NULL,
	[FechaEmision] [date] NOT NULL,
	[FechaRecepcion] [date] NULL,
	[Subtotal] [dbo].[dmoney] NULL,
	[IVA] [dbo].[dmoney] NULL,
	[Retencion] [dbo].[dmoney] NULL,
	[Total] [dbo].[dmoney] NOT NULL,
	[UUID] [nvarchar](36) NULL,
	[FL_Docto] [nvarchar](1000) NULL,
	[Observaciones] [nvarchar](max) NULL,
	[Estatus] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Factura] PRIMARY KEY CLUSTERED 
(
	[PKIdFactura] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[FacturaDetalle] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[FacturaDetalle](
	[PKIdFacturaDetalle] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdFactura_PRES] [int] NOT NULL,
	[FKIdContratoDetalle_PRES] [int] NOT NULL,
	[FKIdPartida_CONTA] [int] NOT NULL,
	[MontoAplicado] [dbo].[dmoney] NOT NULL,
	[Observaciones] [nvarchar](500) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_FacturaDetalle] PRIMARY KEY CLUSTERED 
(
	[PKIdFacturaDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[Finalidad] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[Finalidad](
	[PKIdFinalidad] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [nvarchar](2) NOT NULL,
	[Descripcion] [nvarchar](200) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Finalidad] PRIMARY KEY CLUSTERED 
(
	[PKIdFinalidad] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[FN] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[FN](
	[PKIdFN] [int] IDENTITY(1,1) NOT NULL,
	[FKIdGF_PRES] [int] NOT NULL,
	[Clave] [int] NOT NULL,
	[Descripcion] [nvarchar](50) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_FN] PRIMARY KEY CLUSTERED 
(
	[PKIdFN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[FuenteFinanciamiento] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[FuenteFinanciamiento](
	[PKIdFuenteFinanciamiento] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [nvarchar](6) NULL,
	[Descripcion] [nvarchar](200) NOT NULL,
	[FF] [nvarchar](2) NULL,
	[FG] [nvarchar](1) NULL,
	[FE] [nvarchar](1) NULL,
	[AD] [nvarchar](1) NULL,
	[ORI] [nvarchar](1) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_FuenteFinanciamiento] PRIMARY KEY CLUSTERED 
(
	[PKIdFuenteFinanciamiento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[GF] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[GF](
	[PKIdGF] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [int] NOT NULL,
	[Descripcion] [nvarchar](30) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_GF] PRIMARY KEY CLUSTERED 
(
	[PKIdGF] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[GrupoPresupuesto] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[GrupoPresupuesto](
	[PKIdGrupoPresupuesto] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [int] NOT NULL,
	[Descripcion] [nvarchar](50) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_GrupoPresupuesto] PRIMARY KEY CLUSTERED 
(
	[PKIdGrupoPresupuesto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[Origen] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[Origen](
	[PKIdOrigen] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [int] NOT NULL,
	[Descripcion] [nvarchar](50) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Origen] PRIMARY KEY CLUSTERED 
(
	[PKIdOrigen] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[PG] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[PG](
	[PKIdPG] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [int] NOT NULL,
	[Descripcion] [nvarchar](1000) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_PG] PRIMARY KEY CLUSTERED 
(
	[PKIdPG] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[PP] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[PP](
	[PKIdPP] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [nvarchar](4) NOT NULL,
	[Descripcion] [nvarchar](150) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_PP] PRIMARY KEY CLUSTERED 
(
	[PKIdPP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[Programa] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[Programa](
	[PKIdPrograma] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [nvarchar](50) NOT NULL,
	[Descripcion] [nvarchar](255) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
	[FKIdUR_PRES] [int] NOT NULL,
	[FKIdGF_PRES] [int] NOT NULL,
	[FKIdFN_PRES] [int] NOT NULL,
	[FKIdSF_PRES] [int] NOT NULL,
	[FKIdActividadInstitucional_SIS] [int] NOT NULL,
	[FKIdEje_PRES] [int] NULL,
	[FKIdVertienteGasto_PRES] [int] NULL,
	[FKIdResultado_PRES] [int] NULL,
	[FKIdSubresultado_PRES] [int] NULL,
	[FKIdAnio_SIS] [int] NULL,
	[FKIdSector_PRES] [int] NULL,
	[FKIdSubSector_PRES] [int] NULL,
	[FKIdTipoRecurso_PRES] [int] NULL,
	[FKIdFuenteFinanciamiento_PRES] [int] NULL,
	[Objetivo] [nvarchar](500) NULL,
	[FKIdSubEje_PRES] [int] NULL,
	[FKIdSubSubEje_PRES] [int] NULL,
	[FKIdFinalidad_PRES] [int] NULL,
	[FKIdPP_PRES] [int] NULL,
 CONSTRAINT [PK_Programa] PRIMARY KEY CLUSTERED 
(
	[PKIdPrograma] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[PY] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[PY](
	[PKIdPY] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [varchar](15) NULL,
	[Descripcion] [nvarchar](150) NOT NULL,
	[NombreProyecto] [nvarchar](500) NULL,
	[InicioProyecto] [date] NULL,
	[FinProyecto] [date] NULL,
	[Plurianual] [bit] NULL,
	[TieneTICS] [bit] NULL,
	[EsPAT] [bit] NULL,
	[AnexosTransversales] [bit] NULL,
	[ProgramaPresupuestario] [nvarchar](24) NULL,
	[ProyectoInversion] [bit] NULL,
	[RecursosAdicionales] [bit] NULL,
	[Prioridad] [smallint] NULL,
	[FuenteFinanciamiento] [nvarchar](500) NULL,
	[DescripcionProyecto] [nvarchar](500) NULL,
	[ResponsableProyecto] [nvarchar](128) NULL,
	[ObjetivoProyecto] [nvarchar](500) NULL,
	[LineaEstrategica] [nvarchar](500) NULL,
	[LineaAccionRegulatoria] [nvarchar](500) NULL,
	[TemaAccionRegulatoria] [nvarchar](500) NULL,
	[FundamentoLegal] [nvarchar](500) NULL,
	[Justificacion] [nvarchar](500) NULL,
	[Beneficios] [nvarchar](500) NULL,
	[Indicador] [nvarchar](128) NULL,
	[Meta] [nvarchar](128) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_PY] PRIMARY KEY CLUSTERED 
(
	[PKIdPY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[Ramo] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[Ramo](
	[PKIdRamo] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [int] NOT NULL,
	[Descripcion] [nvarchar](1000) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Ramo] PRIMARY KEY CLUSTERED 
(
	[PKIdRamo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[Resultado] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[Resultado](
	[PKIdResultado] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [nvarchar](2) NOT NULL,
	[Descripcion] [nvarchar](200) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Resultado] PRIMARY KEY CLUSTERED 
(
	[PKIdResultado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[Sector] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[Sector](
	[PKIdSector] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [nvarchar](2) NOT NULL,
	[Descripcion] [nvarchar](200) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Sector] PRIMARY KEY CLUSTERED 
(
	[PKIdSector] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[SF] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[SF](
	[PKIdSF] [int] IDENTITY(1,1) NOT NULL,
	[FKIdFN_PRES] [int] NOT NULL,
	[Clave] [int] NOT NULL,
	[Descripcion] [nvarchar](50) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_SF] PRIMARY KEY CLUSTERED 
(
	[PKIdSF] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[SolicitudSuficiencia] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[SolicitudSuficiencia](
	[PKIdSolicitudSuficiencia] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdRequisicion_ORCO] [int] NOT NULL,
	[FechaSolicitud] [date] NOT NULL,
	[Justificacion] [nvarchar](1000) NULL,
	[GastoNoProgramable] [varchar](3) NULL,
	[IdGastoNoProgramable] [int] NULL,
	[IdCompromisoNomina] [int] NULL,
	[Estatus] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_SolicitudSuficiencia] PRIMARY KEY CLUSTERED 
(
	[PKIdSolicitudSuficiencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[SolicitudSuficienciaDetalle] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[SolicitudSuficienciaDetalle](
	[PKIdSolicitudSuficienciaDetalle] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdSolicitudSuficiencia_PRES] [int] NOT NULL,
	[FKIdRequisicionDetalle_ORCO] [int] NOT NULL,
	[FKIdPartida_CONTA] [int] NOT NULL,
	[Enero] [dbo].[dmoney] NULL,
	[Febrero] [dbo].[dmoney] NULL,
	[Marzo] [dbo].[dmoney] NULL,
	[Abril] [dbo].[dmoney] NULL,
	[Mayo] [dbo].[dmoney] NULL,
	[Junio] [dbo].[dmoney] NULL,
	[Julio] [dbo].[dmoney] NULL,
	[Agosto] [dbo].[dmoney] NULL,
	[Septiembre] [dbo].[dmoney] NULL,
	[Octubre] [dbo].[dmoney] NULL,
	[Noviembre] [dbo].[dmoney] NULL,
	[Diciembre] [dbo].[dmoney] NULL,
	[Total]  AS (((((((((((isnull([Enero],(0))+isnull([Febrero],(0)))+isnull([Marzo],(0)))+isnull([Abril],(0)))+isnull([Mayo],(0)))+isnull([Junio],(0)))+isnull([Julio],(0)))+isnull([Agosto],(0)))+isnull([Septiembre],(0)))+isnull([Octubre],(0)))+isnull([Noviembre],(0)))+isnull([Diciembre],(0))),
	[Observaciones] [nvarchar](500) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_SolicitudSuficienciaDetalle] PRIMARY KEY CLUSTERED 
(
	[PKIdSolicitudSuficienciaDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[SubEje] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[SubEje](
	[PKIdSubEje] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEje_PRES] [int] NOT NULL,
	[Clave] [nvarchar](2) NOT NULL,
	[Descripcion] [nvarchar](200) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_SubEje] PRIMARY KEY CLUSTERED 
(
	[PKIdSubEje] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[Subresultado] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[Subresultado](
	[PKIdSubresultado] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [nvarchar](2) NOT NULL,
	[Descripcion] [nvarchar](200) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Subresultado] PRIMARY KEY CLUSTERED 
(
	[PKIdSubresultado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[SubSector] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[SubSector](
	[PKIdSubSector] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [nvarchar](2) NOT NULL,
	[Descripcion] [nvarchar](200) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_SubSector] PRIMARY KEY CLUSTERED 
(
	[PKIdSubSector] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[SubSubEje] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[SubSubEje](
	[PKIdSubSubEje] [int] IDENTITY(1,1) NOT NULL,
	[FKIdSubEje_PRES] [int] NOT NULL,
	[Clave] [nvarchar](2) NOT NULL,
	[Descripcion] [nvarchar](200) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_SubSubEje] PRIMARY KEY CLUSTERED 
(
	[PKIdSubSubEje] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[Suficiencia] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[Suficiencia](
	[PKIdSuficiencia] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](50) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Suficiencia] PRIMARY KEY CLUSTERED 
(
	[PKIdSuficiencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[TipoGasto] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[TipoGasto](
	[PKIdTipoGasto] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [int] NOT NULL,
	[Descripcion] [nvarchar](200) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_TipoGasto] PRIMARY KEY CLUSTERED 
(
	[PKIdTipoGasto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[TipoRecurso] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[TipoRecurso](
	[PKIdTipoRecurso] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [nvarchar](1) NOT NULL,
	[Descripcion] [nvarchar](200) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_TipoRecurso] PRIMARY KEY CLUSTERED 
(
	[PKIdTipoRecurso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[UR] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[UR](
	[PKIdUR] [int] IDENTITY(1,1) NOT NULL,
	[FKIdGrupoPresupuesto_PRES] [int] NOT NULL,
	[Clave] [nvarchar](10) NULL,
	[Descripcion] [nvarchar](50) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_UR] PRIMARY KEY CLUSTERED 
(
	[PKIdUR] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [PRES].[VertienteGasto] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PRES].[VertienteGasto](
	[PKIdVertienteGasto] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [nvarchar](2) NOT NULL,
	[Descripcion] [nvarchar](200) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_VertienteGasto] PRIMARY KEY CLUSTERED 
(
	[PKIdVertienteGasto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[ActividadInstitucional] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[ActividadInstitucional](
	[PKIdActividadInstitucional] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [nvarchar](3) NOT NULL,
	[Descripcion] [nvarchar](64) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_ActividadInstitucional] PRIMARY KEY CLUSTERED 
(
	[PKIdActividadInstitucional] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[Anio] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[Anio](
	[PKIdAnio] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Anio] PRIMARY KEY CLUSTERED 
(
	[PKIdAnio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[Area] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[Area](
	[PKIdArea] [int] IDENTITY(1,1) NOT NULL,
	[FKIdArea_SIS] [int] NULL,
	[FKIdAreaDocto_SIS] [int] NULL,
	[Clave] [nvarchar](15) NOT NULL,
	[Nombre] [nvarchar](200) NOT NULL,
	[UltimoInv] [datetime] NULL,
	[ZonaEconomica] [nvarchar](100) NULL,
	[Direccion] [nvarchar](64) NULL,
	[Colonia] [nvarchar](64) NULL,
	[CP] [nvarchar](5) NULL,
	[Telefono] [nvarchar](32) NULL,
	[Aprovado] [bit] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Area] PRIMARY KEY CLUSTERED 
(
	[PKIdArea] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[Capitulo] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[Capitulo](
	[PKIdCapitulo] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [nvarchar](30) NULL,
	[Descripcion] [nvarchar](120) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Capitulo] PRIMARY KEY CLUSTERED 
(
	[PKIdCapitulo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[CatTipoSucursal] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[CatTipoSucursal](
	[PKIdTipoSucursal] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](50) NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_TipoSucursal] PRIMARY KEY CLUSTERED 
(
	[PKIdTipoSucursal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_TipoSucursal_Descripcion] UNIQUE NONCLUSTERED 
(
	[Descripcion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[Concepto] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[Concepto](
	[PKIdConcepto] [int] IDENTITY(1,1) NOT NULL,
	[FKIdCapitulo_SIS] [int] NOT NULL,
	[Clave] [nvarchar](30) NULL,
	[Descripcion] [nvarchar](120) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Concepto] PRIMARY KEY CLUSTERED 
(
	[PKIdConcepto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[Departamento] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[Departamento](
	[PKIdDepartamento] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdSucursal_SIS] [int] NULL,
	[Nombre] [nvarchar](128) NOT NULL,
	[NombreCorto] [nvarchar](64) NULL,
	[Descripcion] [nvarchar](255) NULL,
	[NivelJerarquico] [int] NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Departamento] PRIMARY KEY CLUSTERED 
(
	[PKIdDepartamento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[Empresa] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[Empresa](
	[PKIdEmpresa] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](128) NOT NULL,
	[NombreCorto] [nvarchar](64) NULL,
	[RFC] [nvarchar](13) NOT NULL,
	[RazonSocial] [nvarchar](255) NULL,
	[Giro] [nvarchar](100) NULL,
	[FKIdMonedaBase_SIS] [int] NOT NULL,
	[FKIdIdiomaPreferido_SIS] [int] NULL,
	[Logo] [nvarchar](1024) NULL,
	[LogoEmpresa] [varbinary](max) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
	[RegIMSS] [nvarchar](25) NULL,
	[RegInfonavit] [nvarchar](25) NULL,
	[CedEmpadronam] [nvarchar](25) NULL,
	[NoFonacot] [nvarchar](25) NULL,
	[UsAdmin] [nvarchar](100) NULL,
	[EmailAdmin] [nvarchar](100) NULL,
	[FKIdPeriodoPago_SIS] [int] NULL,
	[PrimaRiesgoIMSS] [decimal](18, 4) NULL,
	[UsaSueldoTabular] [bit] NOT NULL CONSTRAINT [DF_SIS_Empresa_UsaSueldoTabular] DEFAULT ((0)),
	[FKIdTipoPago_NOM] [int] NULL, CONSTRAINT [PK_Empresa] PRIMARY KEY CLUSTERED 
(
	[PKIdEmpresa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Empresa_RFC] UNIQUE NONCLUSTERED 
(
	[RFC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[EmpresaEstado] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[EmpresaEstado](
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdEstado_SIS] [int] NOT NULL,
	[FechaApertura] [date] NULL,
	[EsOficinaPrincipal] [bit] NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_EmpresaEstado] PRIMARY KEY CLUSTERED 
(
	[FKIdEmpresa_SIS] ASC,
	[FKIdEstado_SIS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[Estados] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[Estados](
	[PKIdEstado] [int] IDENTITY(1,1) NOT NULL,
	[FKIdPais_SIS] [int] NOT NULL,
	[Nombre] [varchar](64) NOT NULL,
	[CodigoEstado] [varchar](10) NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_Estados] PRIMARY KEY CLUSTERED 
(
	[PKIdEstado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Estados_Pais_Nombre] UNIQUE NONCLUSTERED 
(
	[FKIdPais_SIS] ASC,
	[Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[EstatusProveedor] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[EstatusProveedor](
	[PKIdEstatusProveedor] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](150) NOT NULL,
	[Color] [nvarchar](8) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime] NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_EstatusProveedor] PRIMARY KEY CLUSTERED 
(
	[PKIdEstatusProveedor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[Idioma] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[Idioma](
	[PKIdIdioma] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](50) NOT NULL,
	[CodigoISO639_1] [char](2) NOT NULL,
	[NombreNativo] [nvarchar](50) NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_Idioma] PRIMARY KEY CLUSTERED 
(
	[PKIdIdioma] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Idioma_Codigo] UNIQUE NONCLUSTERED 
(
	[CodigoISO639_1] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[Menu] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[Menu](
	[PKIdMenu] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](150) NOT NULL,
	[Tipo] [int] NOT NULL,
	[FKIdMenu_SIS] [int] NULL,
	[LegacyName] [nvarchar](80) NULL,
	[Ruta] [nvarchar](200) NULL,
	[ImageUrl] [nvarchar](120) NULL,
	[Lenguaje] [char](3) NOT NULL,
	[Orden] [int] NULL,
	[Activo] [bit] NOT NULL,
	[CreatedByOperatorId] [int] NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[ModifiedByOperatorId] [int] NULL,
	[ModifiedDateTime] [datetime] NULL,
 CONSTRAINT [CONSTRAINT_PK_Menu] PRIMARY KEY CLUSTERED 
(
	[PKIdMenu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[MenuRole] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[MenuRole](
	[FKIdMenu_SIS] [int] NOT NULL,
	[RoleId] [nvarchar](128) NOT NULL,
	[Activo] [bit] NOT NULL,
	[CreatedByOperatorId] [int] NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[ModifiedByOperatorId] [int] NULL,
	[ModifiedDateTime] [datetime] NULL,
 CONSTRAINT [CONSTRAINT_PK_MenuRole] PRIMARY KEY CLUSTERED 
(
	[FKIdMenu_SIS] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[Moneda] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[Moneda](
	[PKIdMoneda] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](50) NOT NULL,
	[CodigoISO4217] [char](3) NOT NULL,
	[Simbolo] [nvarchar](5) NOT NULL,
	[Decimales] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_Moneda] PRIMARY KEY CLUSTERED 
(
	[PKIdMoneda] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Moneda_Codigo] UNIQUE NONCLUSTERED 
(
	[CodigoISO4217] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[Municipios] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[Municipios](
	[PKIdMunicipio] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEstado_SIS] [int] NOT NULL,
	[Nombre] [varchar](100) NOT NULL,
	[CodigoMunicipio] [varchar](10) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
 CONSTRAINT [PK_Municipios] PRIMARY KEY CLUSTERED 
(
	[PKIdMunicipio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[OrigenLogMessage] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[OrigenLogMessage](
	[PKIdOrigenLogMessage] [int] NOT NULL,
	[Descripcion] [nvarchar](50) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [CONSTRAINT_PK_OrigenLogMessage] PRIMARY KEY CLUSTERED 
(
	[PKIdOrigenLogMessage] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[Paises] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[Paises](
	[PKIdPais] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](64) NOT NULL,
	[CodigoISO2] [char](2) NOT NULL,
	[CodigoISO3] [char](3) NOT NULL,
	[FKIdIdiomaPrincipal_SIS] [int] NULL,
	[FKIdMonedaPrincipal_SIS] [int] NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
 CONSTRAINT [PK_Paises] PRIMARY KEY CLUSTERED 
(
	[PKIdPais] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Paises_CodigoISO2] UNIQUE NONCLUSTERED 
(
	[CodigoISO2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Paises_CodigoISO3] UNIQUE NONCLUSTERED 
(
	[CodigoISO3] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[Partida] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[Partida](
	[PKIdPartida] [int] IDENTITY(1,1) NOT NULL,
	[FKIdConcepto_SIS] [int] NULL,
	[Clave] [nvarchar](10) NOT NULL,
	[Descripcion] [nvarchar](255) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Partida] PRIMARY KEY CLUSTERED 
(
	[PKIdPartida] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[PerfilUsuario] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[PerfilUsuario](
	[FKIdUsuario_SIS] [int] NOT NULL,
	[Fotografia] [varbinary](max) NULL,
	[ContentType] [nvarchar](50) NULL,
	[FileName] [nvarchar](64) NULL,
	[FileExtension] [nvarchar](8) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[FKIdUsuario_SIS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[Proveedor] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[Proveedor](
	[PKIdProveedor] [int] IDENTITY(1,1) NOT NULL,
	[FkIdTipoProveedor_SIS] [int] NULL,
	[FKIdEstatusProveedor_SIS] [int] NULL,
	[FKIdCuentaContable_SIS] [int] NULL,
	[FKIdMunicipio_SIS] [int] NOT NULL,
	[FKIdEstado_SIS] [int] NOT NULL,
	[FKIdPais_SIS] [int] NOT NULL,
	[FKIdResponsable_SIS] [int] NULL,
	[FKIdAESector_SIS] [int] NULL,
	[FKIdAEDivision_SIS] [int] NULL,
	[FKIdAEGrupo_SIS] [int] NULL,
	[FKIdAEClase_SIS] [int] NULL,
	[Nombre] [nvarchar](500) NOT NULL,
	[RFC] [nvarchar](50) NULL,
	[Colonia] [nvarchar](50) NULL,
	[CP] [nvarchar](50) NULL,
	[Ciudad] [nvarchar](50) NULL,
	[EMAIL] [nvarchar](50) NULL,
	[Clave] [nvarchar](10) NOT NULL,
	[Calle] [nvarchar](50) NULL,
	[Numero] [nvarchar](10) NULL,
	[FechaAlta] [datetime] NULL,
	[TelefonoInstitucional] [nvarchar](20) NULL,
	[Notas] [nvarchar](max) NULL,
	[PaginaWeb] [nvarchar](100) NULL,
	[NumeroInt] [nvarchar](10) NULL,
	[CURP] [nvarchar](18) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime] NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Proveedor] PRIMARY KEY CLUSTERED 
(
	[PKIdProveedor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[Sucursal] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[Sucursal](
	[PKIdSucursal] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdEstado_SIS] [int] NOT NULL,
	[Nombre] [nvarchar](128) NOT NULL,
	[NombreCorto] [nvarchar](64) NULL,
	[CodigoSucursal] [nvarchar](20) NOT NULL,
	[Alias] [nvarchar](50) NULL,
	[FKIdTipoSucursal] [int] NOT NULL,
	[FKIdMonedaLocal_SIS] [int] NULL,
	[Direccion] [nvarchar](256) NOT NULL,
	[Colonia] [nvarchar](100) NULL,
	[Ciudad] [nvarchar](100) NULL,
	[CodigoPostal] [nvarchar](10) NULL,
	[TelefonoPrincipal] [nvarchar](20) NULL,
	[TelefonoSecundario] [nvarchar](20) NULL,
	[Email] [nvarchar](100) NULL,
	[HorarioApertura] [time](7) NULL,
	[HorarioCierre] [time](7) NULL,
	[EsMatriz] [bit] NOT NULL,
	[EsActiva] [bit] NOT NULL,
	[Latitud] [decimal](9, 6) NULL,
	[Longitud] [decimal](9, 6) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Sucursal] PRIMARY KEY CLUSTERED 
(
	[PKIdSucursal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Sucursal_Codigo] UNIQUE NONCLUSTERED 
(
	[CodigoSucursal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[SystemLog] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[SystemLog](
	[PKIdSystemLog] [int] IDENTITY(1,1) NOT NULL,
	[FKIdOrigenLogMessage_SIS] [int] NOT NULL,
	[Date] [datetime2](7) NULL,
	[Type] [nvarchar](24) NULL,
	[ProgName] [nvarchar](256) NULL,
	[EmployeeNo] [nvarchar](24) NULL,
	[Category] [nvarchar](24) NULL,
	[IPClient] [nvarchar](24) NULL,
	[HostName] [nvarchar](32) NULL,
	[Thread] [varchar](255) NULL,
	[Level] [varchar](20) NULL,
	[Logger] [varchar](255) NULL,
	[Message] [varchar](4000) NULL,
	[Exception] [nvarchar](4000) NULL,
	[Context] [nvarchar](10) NULL,
	[MethodName] [nvarchar](200) NULL,
	[Parameters] [nvarchar](4000) NULL,
	[ExecutionTime] [int] NULL,
 CONSTRAINT [CONSTRAINT_PK_SystemLog] PRIMARY KEY CLUSTERED 
(
	[PKIdSystemLog] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[SystemParamCatalog] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[SystemParamCatalog](
	[PKIdSystemParamCatalog] [int] NOT NULL,
	[Code] [nvarchar](50) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [CONSTRAINT_PK_SystemParamCatalog] PRIMARY KEY CLUSTERED 
(
	[PKIdSystemParamCatalog] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[SystemParamValue] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[SystemParamValue](
	[PKIdSystemParamValue] [int] NOT NULL,
	[FKIdSystemParamCatalog_SIS] [int] NOT NULL,
	[Value] [nvarchar](max) NOT NULL,
	[Descripcion] [varchar](128) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [CONSTRAINT_PK_SystemParamValue] PRIMARY KEY CLUSTERED 
(
	[PKIdSystemParamValue] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[TipoDetallePoliza] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[TipoDetallePoliza](
	[PkIdTipoDetallePoliza] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](25) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_TipoDetallePoliza] PRIMARY KEY CLUSTERED 
(
	[PkIdTipoDetallePoliza] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[TipoDoctoCLC] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[TipoDoctoCLC](
	[PKIdTipoDoctoCLC] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [nvarchar](50) NOT NULL,
	[Nombre] [nvarchar](50) NOT NULL,
	[TipoRecurso] [varchar](1) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_TipoDoctoCLC] PRIMARY KEY CLUSTERED 
(
	[PKIdTipoDoctoCLC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[TipoPoliza] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[TipoPoliza](
	[PKIdTipoPoliza] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](25) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_TipoPoliza] PRIMARY KEY CLUSTERED 
(
	[PKIdTipoPoliza] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[TipoProveedor] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[TipoProveedor](
	[PkIdTipoProveedor] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](80) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime] NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_TipoProveedor] PRIMARY KEY CLUSTERED 
(
	[PkIdTipoProveedor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[Usuario] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[Usuario](
	[PkIdUsuario] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NULL,
	[FKIdPersona_NOM] [int] NULL,
	[AspNetUserId] [nvarchar](450) NOT NULL,
	[PayrollID] [nvarchar](20) NOT NULL,
	[FKIdIdiomaPreferido_SIS] [int] NULL,
	[FKIdMonedaPreferida_SIS] [int] NULL,
	[EsAdministrador] [bit] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Usuario] PRIMARY KEY CLUSTERED 
(
	[PkIdUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Usuario_AspNetUserId] UNIQUE NONCLUSTERED 
(
	[AspNetUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Usuario_PayrollID] UNIQUE NONCLUSTERED 
(
	[PayrollID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[UsuarioDepartamento] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[UsuarioDepartamento](
	[FKIdUsuario_SIS] [int] NOT NULL,
	[FKIdDepartamento_SIS] [int] NOT NULL,
	[EsJefe] [bit] NOT NULL,
	[FechaAsignacion] [datetime2](7) NOT NULL,
	[FechaFinAsignacion] [datetime2](7) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_UsuarioDepartamento] PRIMARY KEY CLUSTERED 
(
	[FKIdUsuario_SIS] ASC,
	[FKIdDepartamento_SIS] ASC,
	[FechaAsignacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [SIS].[UsuarioSucursal] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SIS].[UsuarioSucursal](
	[FKIdUsuario_SIS] [int] NOT NULL,
	[FKIdSucursal_SIS] [int] NOT NULL,
	[PuedeAcceder] [bit] NOT NULL,
	[PuedeConfigurar] [bit] NOT NULL,
	[PuedeOperar] [bit] NOT NULL,
	[PuedeReportes] [bit] NOT NULL,
	[EsGerente] [bit] NOT NULL,
	[EsSupervisor] [bit] NOT NULL,
	[FechaAsignacion] [datetime2](7) NULL,
	[FechaFinAsignacion] [datetime2](7) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_UsuarioSucursal] PRIMARY KEY CLUSTERED 
(
	[FKIdUsuario_SIS] ASC,
	[FKIdSucursal_SIS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [TES].[Banco] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TES].[Banco](
	[PKIdBanco] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[Clave] [nvarchar](10) NOT NULL,
	[Nombre] [nvarchar](200) NOT NULL,
	[NombreCorto] [nvarchar](50) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Banco] PRIMARY KEY CLUSTERED 
(
	[PKIdBanco] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [TES].[CuentaBancaria] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TES].[CuentaBancaria](
	[PKIdCuentaBancaria] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdBanco_TES] [int] NULL,
	[FKIdCuentaContable_SIS] [int] NULL,
	[FKIdTipoMoneda_TES] [int] NOT NULL,
	[NumeroCuenta] [nvarchar](50) NOT NULL,
	[CLABE] [nvarchar](18) NULL,
	[Titular] [nvarchar](200) NOT NULL,
	[SaldoInicial] [dbo].[dmoney] NOT NULL,
	[SaldoActual] [dbo].[dmoney] NOT NULL,
	[FechaApertura] [date] NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_CuentaBancaria] PRIMARY KEY CLUSTERED 
(
	[PKIdCuentaBancaria] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [TES].[Instrumento] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TES].[Instrumento](
	[PKIdInstrumento] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[FKIdTipoInversion_TES] [int] NOT NULL,
	[FKIdIntermediarioFinanciero_TES] [int] NOT NULL,
	[FKIdTipoPlazo_TES] [int] NULL,
	[FKIdTipoMoneda_TES] [int] NOT NULL,
	[Nombre] [nvarchar](200) NOT NULL,
	[TasaInteres] [decimal](10, 4) NULL,
	[PlazoOriginal] [int] NULL,
	[FechaEmision] [date] NULL,
	[FechaVencimiento] [date] NULL,
	[MontoMinimo] [dbo].[dmoney] NULL,
	[Observaciones] [nvarchar](max) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Instrumento] PRIMARY KEY CLUSTERED 
(
	[PKIdInstrumento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Objeto: Table [TES].[Interes] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TES].[Interes](
	[PKIdInteres] [int] IDENTITY(1,1) NOT NULL,
	[FKIdInversion] [int] NOT NULL,
	[Monto] [dbo].[dmoney] NOT NULL,
	[FechaGeneracion] [date] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Interes] PRIMARY KEY CLUSTERED 
(
	[PKIdInteres] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [TES].[IntermediarioFinanciero] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TES].[IntermediarioFinanciero](
	[PKIdIntermediarioFinanciero] [int] IDENTITY(1,1) NOT NULL,
	[FKIdEmpresa_SIS] [int] NOT NULL,
	[Clave] [nvarchar](10) NOT NULL,
	[Nombre] [nvarchar](200) NOT NULL,
	[RazonSocial] [nvarchar](200) NULL,
	[RFC] [nvarchar](15) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_IntermediarioFinanciero] PRIMARY KEY CLUSTERED 
(
	[PKIdIntermediarioFinanciero] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [TES].[Inversion] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TES].[Inversion](
	[PKIdInversion] [int] IDENTITY(1,1) NOT NULL,
	[FKIdInstrumento] [int] NOT NULL,
	[FKIdCuentaBancaria] [int] NOT NULL,
	[Monto] [dbo].[dmoney] NOT NULL,
	[FechaInversion] [date] NOT NULL,
	[FechaVencimiento] [date] NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Inversion] PRIMARY KEY CLUSTERED 
(
	[PKIdInversion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [TES].[Retiro] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TES].[Retiro](
	[PKIdRetiro] [int] IDENTITY(1,1) NOT NULL,
	[FKIdInversion] [int] NOT NULL,
	[FKIdTipoRetiro_TES] [int] NULL,
	[Monto] [dbo].[dmoney] NOT NULL,
	[FechaRetiro] [date] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_Retiro] PRIMARY KEY CLUSTERED 
(
	[PKIdRetiro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [TES].[TipoCambio] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TES].[TipoCambio](
	[PKIdTipoCambio] [int] IDENTITY(1,1) NOT NULL,
	[FKIdTipoMoneda_TES] [int] NOT NULL,
	[Cantidad] [decimal](18, 2) NOT NULL,
	[Fecha] [datetime] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_TipoCambio] PRIMARY KEY CLUSTERED 
(
	[PKIdTipoCambio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [TES].[TipoDoctoCLC] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TES].[TipoDoctoCLC](
	[PKIdTipoDoctoCLC] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [nvarchar](50) NOT NULL,
	[Nombre] [nvarchar](50) NOT NULL,
	[TipoRecurso] [varchar](1) NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_TipoDoctoCLC] PRIMARY KEY CLUSTERED 
(
	[PKIdTipoDoctoCLC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [TES].[TipoInversion] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TES].[TipoInversion](
	[PKIdTipoInversion] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](50) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_TipoInversion] PRIMARY KEY CLUSTERED 
(
	[PKIdTipoInversion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [TES].[TipoMoneda] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TES].[TipoMoneda](
	[PKIdTipoMoneda] [int] IDENTITY(1,1) NOT NULL,
	[FKIdPais_SIS] [int] NOT NULL,
	[Descripcion] [nvarchar](50) NOT NULL,
	[CodigoISO4217] [char](3) NULL,
	[Simbolo] [nvarchar](5) NULL,
	[Decimales] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_TipoMoneda] PRIMARY KEY CLUSTERED 
(
	[PKIdTipoMoneda] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [TES].[TipoPago] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TES].[TipoPago](
	[PKIdTipoPago] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](50) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_TipoPago] PRIMARY KEY CLUSTERED 
(
	[PKIdTipoPago] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [TES].[TipoPagoSF] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TES].[TipoPagoSF](
	[PKIdTipoPagoSF] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](50) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_TipoPagoSF] PRIMARY KEY CLUSTERED 
(
	[PKIdTipoPagoSF] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [TES].[TipoPlazo] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TES].[TipoPlazo](
	[PKIdTipoPlazo] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](100) NOT NULL,
	[Dias] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_TipoPlazo] PRIMARY KEY CLUSTERED 
(
	[PKIdTipoPlazo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [TES].[TipoRetiro] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TES].[TipoRetiro](
	[PKIdTipoRetiro] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](100) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_TipoRetiro] PRIMARY KEY CLUSTERED 
(
	[PKIdTipoRetiro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [TES].[TipoSolicitudCLC] Fecha de script: 26/05/2026 09:49:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TES].[TipoSolicitudCLC](
	[PKIdTipoSolicitudCLC] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](50) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NULL,
	[UsuarioCreacion] [int] NOT NULL,
	[FechaModificacion] [datetime2](7) NULL,
	[UsuarioModificacion] [int] NULL,
 CONSTRAINT [PK_TipoSolicitudCLC] PRIMARY KEY CLUSTERED 
(
	[PKIdTipoSolicitudCLC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ALMA].[Bien] ADD  CONSTRAINT [DF_Bien_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ALMA].[Bien] ADD  CONSTRAINT [DF_Bien_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ALMA].[Conteo] ADD  CONSTRAINT [DF_Conteo_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ALMA].[Conteo] ADD  CONSTRAINT [DF_Conteo_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ALMA].[ConteoDetalle] ADD  CONSTRAINT [DF_ConteoDetalle_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ALMA].[ConteoDetalle] ADD  CONSTRAINT [DF_ConteoDetalle_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo] ADD  CONSTRAINT [DF_ConteoDetalleEscaneo_FechaEscaneo]  DEFAULT (sysdatetime()) FOR [FechaEscaneo]
GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo] ADD  CONSTRAINT [DF_ConteoDetalleEscaneo_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo] ADD  CONSTRAINT [DF_ConteoDetalleEscaneo_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ALMA].[ConteoHist] ADD  CONSTRAINT [DF_ConteoHist_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ALMA].[ConteoHist] ADD  CONSTRAINT [DF_ConteoHist_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ALMA].[EstadoBien] ADD  CONSTRAINT [DF_EstadoBien_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ALMA].[EstadoBien] ADD  CONSTRAINT [DF_EstadoBien_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ALMA].[EstatusArticuloConteo] ADD  CONSTRAINT [DF_EstatusArticuloConteo_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ALMA].[EstatusPeriodo] ADD  CONSTRAINT [DF_EstatusPeriodo_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ALMA].[EstatusSolicitud] ADD  CONSTRAINT [DF_EstatusSolicitud_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ALMA].[EstatusSolicitud] ADD  CONSTRAINT [DF_EstatusSolicitud_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ALMA].[Familia] ADD  CONSTRAINT [DF_Familia_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ALMA].[Familia] ADD  CONSTRAINT [DF_Familia_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ALMA].[GrupoBien] ADD  CONSTRAINT [DF_GrupoBien_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ALMA].[GrupoBien] ADD  CONSTRAINT [DF_GrupoBien_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ALMA].[Marca] ADD  CONSTRAINT [DF_Marca_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ALMA].[Marca] ADD  CONSTRAINT [DF_Marca_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ALMA].[Material] ADD  CONSTRAINT [DF_Material_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ALMA].[Material] ADD  CONSTRAINT [DF_Material_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ALMA].[MotivoES] ADD  CONSTRAINT [DF_MotivoES_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ALMA].[MotivoES] ADD  CONSTRAINT [DF_MotivoES_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ALMA].[Nivel] ADD  CONSTRAINT [DF_Nivel_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ALMA].[Nivel] ADD  CONSTRAINT [DF_Nivel_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ALMA].[PeriodoConteo] ADD  CONSTRAINT [DF_PeriodoConteo_MaxConteos]  DEFAULT ((3)) FOR [MaximoConteosPorArticulo]
GO
ALTER TABLE [ALMA].[PeriodoConteo] ADD  CONSTRAINT [DF_PeriodoConteo_ReqAprobacion]  DEFAULT ((1)) FOR [RequiereAprobacionSupervisor]
GO
ALTER TABLE [ALMA].[PeriodoConteo] ADD  CONSTRAINT [DF_PeriodoConteo_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ALMA].[PeriodoConteo] ADD  CONSTRAINT [DF_PeriodoConteo_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ALMA].[TipoAdquisicion] ADD  CONSTRAINT [DF_TipoAdquisicion_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ALMA].[TipoAdquisicion] ADD  CONSTRAINT [DF_TipoAdquisicion_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ALMA].[TipoBien] ADD  CONSTRAINT [DF_TipoBien_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ALMA].[TipoBien] ADD  CONSTRAINT [DF_TipoBien_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ALMA].[TipoConteo] ADD  CONSTRAINT [DF_TipoConteo_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ALMA].[TipoPatrimonio] ADD  CONSTRAINT [DF_TipoPatrimonio_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ALMA].[TipoPatrimonio] ADD  CONSTRAINT [DF_TipoPatrimonio_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ALMA].[Unidades] ADD  CONSTRAINT [DF_Unidades_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ALMA].[Unidades] ADD  CONSTRAINT [DF_Unidades_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [CONTA].[Capitulo] ADD  CONSTRAINT [DF_Capitulo_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [CONTA].[Capitulo] ADD  CONSTRAINT [DF_Capitulo_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [CONTA].[Concepto] ADD  CONSTRAINT [DF_Concepto_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [CONTA].[Concepto] ADD  CONSTRAINT [DF_Concepto_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [CONTA].[ConsecutivoPoliza] ADD  CONSTRAINT [DF_ConsecutivoPoliza_UltimoValor]  DEFAULT ((0)) FOR [UltimoValor]
GO
ALTER TABLE [CONTA].[ConsecutivoPoliza] ADD  CONSTRAINT [DF_ConsecutivoPoliza_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [CONTA].[ConsecutivoPoliza] ADD  CONSTRAINT [DF_ConsecutivoPoliza_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [CONTA].[CuentaContable] ADD  CONSTRAINT [DF_CuentaContable_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [CONTA].[CuentaContable] ADD  CONSTRAINT [DF_CuentaContable_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [CONTA].[MatrizConversion] ADD  CONSTRAINT [DF_MatrizConversion_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [CONTA].[MatrizConversion] ADD  CONSTRAINT [DF_MatrizConversion_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [CONTA].[MatrizIngreso] ADD  CONSTRAINT [DF_MatrizIngreso_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [CONTA].[MatrizIngreso] ADD  CONSTRAINT [DF_MatrizIngreso_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [CONTA].[Partida] ADD  CONSTRAINT [DF_Partida_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [CONTA].[Partida] ADD  CONSTRAINT [DF_Partida_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [CONTA].[Poliza] ADD  CONSTRAINT [DF_Poliza_EstaBalanceado]  DEFAULT ((0)) FOR [EstaBalanceado]
GO
ALTER TABLE [CONTA].[Poliza] ADD  CONSTRAINT [DF_Poliza_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [CONTA].[Poliza] ADD  CONSTRAINT [DF_Poliza_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [CONTA].[PolizaDetalle] ADD  CONSTRAINT [DF_PolizaDetalle_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [CONTA].[PolizaDetalle] ADD  CONSTRAINT [DF_PolizaDetalle_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [CONTA].[TipoCuenta] ADD  CONSTRAINT [DF_TipoCuenta_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [CONTA].[TipoCuenta] ADD  CONSTRAINT [DF_TipoCuenta_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [CONTA].[TipoDoctoPago] ADD  CONSTRAINT [DF_TipoDoctoPago_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [CONTA].[TipoDoctoPago] ADD  CONSTRAINT [DF_TipoDoctoPago_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [dbo].[AspNetClaims] ADD  CONSTRAINT [CONSTRAINT_DF_AspNetClaims_ReferenceId]  DEFAULT ((0)) FOR [ReferenceId]
GO
ALTER TABLE [dbo].[AspNetClaimValues] ADD  CONSTRAINT [CONSTRAINT_DF_AspNetClaimValues_Created]  DEFAULT (getdate()) FOR [Created]
GO
ALTER TABLE [NOM].[Persona] ADD  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [NOM].[Persona] ADD  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [NOM].[PersonaArea] ADD  CONSTRAINT [DF_PersonaArea_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [NOM].[PersonaArea] ADD  CONSTRAINT [DF_PersonaArea_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ORCO].[Articulo] ADD  CONSTRAINT [DF_Articulo_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ORCO].[Articulo] ADD  CONSTRAINT [DF_Articulo_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ORCO].[Cotizacion] ADD  CONSTRAINT [DF_Cotizacion_Servicio]  DEFAULT ((0)) FOR [Servicio]
GO
ALTER TABLE [ORCO].[Cotizacion] ADD  CONSTRAINT [DF_Cotizacion_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ORCO].[Cotizacion] ADD  CONSTRAINT [DF_Cotizacion_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ORCO].[CotizacionDetalle] ADD  CONSTRAINT [DF_CotizacionDetalle_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ORCO].[CotizacionDetalle] ADD  CONSTRAINT [DF_CotizacionDetalle_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ORCO].[EstatusRequisicion] ADD  DEFAULT ((0)) FOR [Orden]
GO
ALTER TABLE [ORCO].[EstatusRequisicion] ADD  CONSTRAINT [DF_EstatusRequisicion_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ORCO].[EstatusRequisicion] ADD  CONSTRAINT [DF_EstatusRequisicion_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ORCO].[EstudioMercado] ADD  CONSTRAINT [DF_EstudioMercado_Estatus]  DEFAULT ((1)) FOR [Estatus]
GO
ALTER TABLE [ORCO].[EstudioMercado] ADD  CONSTRAINT [DF_EstudioMercado_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ORCO].[EstudioMercado] ADD  CONSTRAINT [DF_EstudioMercado_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle] ADD  CONSTRAINT [DF_EstudioMercadoDetalle_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle] ADD  CONSTRAINT [DF_EstudioMercadoDetalle_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalleCosto] ADD  CONSTRAINT [DF_EstudioMercadoDetalleCosto_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalleCosto] ADD  CONSTRAINT [DF_EstudioMercadoDetalleCosto_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ORCO].[Fraccion] ADD  CONSTRAINT [DF_Fraccion_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ORCO].[Fraccion] ADD  CONSTRAINT [DF_Fraccion_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ORCO].[Modalidad] ADD  CONSTRAINT [DF_Modalidad_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ORCO].[Modalidad] ADD  CONSTRAINT [DF_Modalidad_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ORCO].[PAAAS] ADD  CONSTRAINT [DF_PAAAS_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ORCO].[PAAAS] ADD  CONSTRAINT [DF_PAAAS_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ORCO].[PAAASDetalle] ADD  CONSTRAINT [DF_PAAASDetalle_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ORCO].[PAAASDetalle] ADD  CONSTRAINT [DF_PAAASDetalle_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ORCO].[PAAASPartida] ADD  CONSTRAINT [DF_PAAASPartida_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ORCO].[PAAASPartida] ADD  CONSTRAINT [DF_PAAASPartida_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ORCO].[ProcedimientoContratacion] ADD  CONSTRAINT [DF_ProcedimientoContratacion_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ORCO].[ProcedimientoContratacion] ADD  CONSTRAINT [DF_ProcedimientoContratacion_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ORCO].[Proyecto] ADD  CONSTRAINT [DF_Proyecto_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ORCO].[Proyecto] ADD  CONSTRAINT [DF_Proyecto_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ORCO].[Requisicion] ADD  CONSTRAINT [DF_Requisicion_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ORCO].[Requisicion] ADD  CONSTRAINT [DF_Requisicion_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ORCO].[RequisicionDetalle] ADD  CONSTRAINT [DF_RequisicionDetalle_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ORCO].[RequisicionDetalle] ADD  CONSTRAINT [DF_RequisicionDetalle_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ORCO].[RequisicionPartida] ADD  CONSTRAINT [DF_RequisicionPartida_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ORCO].[RequisicionPartida] ADD  CONSTRAINT [DF_RequisicionPartida_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ORCO].[SolicitudCotizacion] ADD  CONSTRAINT [DF_SolicitudCotizacion_Estatus]  DEFAULT ((1)) FOR [Estatus]
GO
ALTER TABLE [ORCO].[SolicitudCotizacion] ADD  CONSTRAINT [DF_SolicitudCotizacion_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ORCO].[SolicitudCotizacion] ADD  CONSTRAINT [DF_SolicitudCotizacion_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ORCO].[TipoContrato] ADD  CONSTRAINT [DF_TipoContrato_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ORCO].[TipoContrato] ADD  CONSTRAINT [DF_TipoContrato_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ORCO].[TipoDocumento] ADD  CONSTRAINT [DF_TipoDocumento_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ORCO].[TipoDocumento] ADD  CONSTRAINT [DF_TipoDocumento_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ORCO].[TipoGarantia] ADD  CONSTRAINT [DF_TipoGarantia_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [ORCO].[TipoGarantia] ADD  CONSTRAINT [DF_TipoGarantia_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[AutorizacionSuficiencia] ADD  CONSTRAINT [DF_AutorizacionSuficiencia_Estatus]  DEFAULT ((1)) FOR [Estatus]
GO
ALTER TABLE [PRES].[AutorizacionSuficiencia] ADD  CONSTRAINT [DF_AutorizacionSuficiencia_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[AutorizacionSuficiencia] ADD  CONSTRAINT [DF_AutorizacionSuficiencia_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle] ADD  CONSTRAINT [DF_AutorizacionSuficienciaDetalle_Ene]  DEFAULT ((0)) FOR [Enero]
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle] ADD  CONSTRAINT [DF_AutorizacionSuficienciaDetalle_Feb]  DEFAULT ((0)) FOR [Febrero]
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle] ADD  CONSTRAINT [DF_AutorizacionSuficienciaDetalle_Mar]  DEFAULT ((0)) FOR [Marzo]
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle] ADD  CONSTRAINT [DF_AutorizacionSuficienciaDetalle_Abr]  DEFAULT ((0)) FOR [Abril]
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle] ADD  CONSTRAINT [DF_AutorizacionSuficienciaDetalle_May]  DEFAULT ((0)) FOR [Mayo]
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle] ADD  CONSTRAINT [DF_AutorizacionSuficienciaDetalle_Jun]  DEFAULT ((0)) FOR [Junio]
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle] ADD  CONSTRAINT [DF_AutorizacionSuficienciaDetalle_Jul]  DEFAULT ((0)) FOR [Julio]
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle] ADD  CONSTRAINT [DF_AutorizacionSuficienciaDetalle_Ago]  DEFAULT ((0)) FOR [Agosto]
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle] ADD  CONSTRAINT [DF_AutorizacionSuficienciaDetalle_Sep]  DEFAULT ((0)) FOR [Septiembre]
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle] ADD  CONSTRAINT [DF_AutorizacionSuficienciaDetalle_Oct]  DEFAULT ((0)) FOR [Octubre]
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle] ADD  CONSTRAINT [DF_AutorizacionSuficienciaDetalle_Nov]  DEFAULT ((0)) FOR [Noviembre]
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle] ADD  CONSTRAINT [DF_AutorizacionSuficienciaDetalle_Dic]  DEFAULT ((0)) FOR [Diciembre]
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle] ADD  CONSTRAINT [DF_AutorizacionSuficienciaDetalle_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle] ADD  CONSTRAINT [DF_AutorizacionSuficienciaDetalle_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[Cheque] ADD  CONSTRAINT [DF_Cheque_Estatus]  DEFAULT ((1)) FOR [Estatus]
GO
ALTER TABLE [PRES].[Cheque] ADD  CONSTRAINT [DF_Cheque_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[Cheque] ADD  CONSTRAINT [DF_Cheque_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[ChequePartidas] ADD  CONSTRAINT [DF_ChequePartidas_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[ChequePartidas] ADD  CONSTRAINT [DF_ChequePartidas_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[CLC] ADD  CONSTRAINT [DF_CLC_Estatus]  DEFAULT ((1)) FOR [Estatus]
GO
ALTER TABLE [PRES].[CLC] ADD  CONSTRAINT [DF_CLC_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[CLC] ADD  CONSTRAINT [DF_CLC_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[CLCDetalle] ADD  CONSTRAINT [DF_CLCDetalle_Ene]  DEFAULT ((0)) FOR [Enero]
GO
ALTER TABLE [PRES].[CLCDetalle] ADD  CONSTRAINT [DF_CLCDetalle_Feb]  DEFAULT ((0)) FOR [Febrero]
GO
ALTER TABLE [PRES].[CLCDetalle] ADD  CONSTRAINT [DF_CLCDetalle_Mar]  DEFAULT ((0)) FOR [Marzo]
GO
ALTER TABLE [PRES].[CLCDetalle] ADD  CONSTRAINT [DF_CLCDetalle_Abr]  DEFAULT ((0)) FOR [Abril]
GO
ALTER TABLE [PRES].[CLCDetalle] ADD  CONSTRAINT [DF_CLCDetalle_May]  DEFAULT ((0)) FOR [Mayo]
GO
ALTER TABLE [PRES].[CLCDetalle] ADD  CONSTRAINT [DF_CLCDetalle_Jun]  DEFAULT ((0)) FOR [Junio]
GO
ALTER TABLE [PRES].[CLCDetalle] ADD  CONSTRAINT [DF_CLCDetalle_Jul]  DEFAULT ((0)) FOR [Julio]
GO
ALTER TABLE [PRES].[CLCDetalle] ADD  CONSTRAINT [DF_CLCDetalle_Ago]  DEFAULT ((0)) FOR [Agosto]
GO
ALTER TABLE [PRES].[CLCDetalle] ADD  CONSTRAINT [DF_CLCDetalle_Sep]  DEFAULT ((0)) FOR [Septiembre]
GO
ALTER TABLE [PRES].[CLCDetalle] ADD  CONSTRAINT [DF_CLCDetalle_Oct]  DEFAULT ((0)) FOR [Octubre]
GO
ALTER TABLE [PRES].[CLCDetalle] ADD  CONSTRAINT [DF_CLCDetalle_Nov]  DEFAULT ((0)) FOR [Noviembre]
GO
ALTER TABLE [PRES].[CLCDetalle] ADD  CONSTRAINT [DF_CLCDetalle_Dic]  DEFAULT ((0)) FOR [Diciembre]
GO
ALTER TABLE [PRES].[CLCDetalle] ADD  CONSTRAINT [DF_CLCDetalle_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[CLCDetalle] ADD  CONSTRAINT [DF_CLCDetalle_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[CLCFactura] ADD  CONSTRAINT [DF_CLCFactura_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[CLCFactura] ADD  CONSTRAINT [DF_CLCFactura_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[Contrato] ADD  CONSTRAINT [DF_Contrato_Estatus]  DEFAULT ((1)) FOR [Estatus]
GO
ALTER TABLE [PRES].[Contrato] ADD  CONSTRAINT [DF_Contrato_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[Contrato] ADD  CONSTRAINT [DF_Contrato_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[ContratoDetalle] ADD  CONSTRAINT [DF_ContratoDetalle_Ene]  DEFAULT ((0)) FOR [Enero]
GO
ALTER TABLE [PRES].[ContratoDetalle] ADD  CONSTRAINT [DF_ContratoDetalle_Feb]  DEFAULT ((0)) FOR [Febrero]
GO
ALTER TABLE [PRES].[ContratoDetalle] ADD  CONSTRAINT [DF_ContratoDetalle_Mar]  DEFAULT ((0)) FOR [Marzo]
GO
ALTER TABLE [PRES].[ContratoDetalle] ADD  CONSTRAINT [DF_ContratoDetalle_Abr]  DEFAULT ((0)) FOR [Abril]
GO
ALTER TABLE [PRES].[ContratoDetalle] ADD  CONSTRAINT [DF_ContratoDetalle_May]  DEFAULT ((0)) FOR [Mayo]
GO
ALTER TABLE [PRES].[ContratoDetalle] ADD  CONSTRAINT [DF_ContratoDetalle_Jun]  DEFAULT ((0)) FOR [Junio]
GO
ALTER TABLE [PRES].[ContratoDetalle] ADD  CONSTRAINT [DF_ContratoDetalle_Jul]  DEFAULT ((0)) FOR [Julio]
GO
ALTER TABLE [PRES].[ContratoDetalle] ADD  CONSTRAINT [DF_ContratoDetalle_Ago]  DEFAULT ((0)) FOR [Agosto]
GO
ALTER TABLE [PRES].[ContratoDetalle] ADD  CONSTRAINT [DF_ContratoDetalle_Sep]  DEFAULT ((0)) FOR [Septiembre]
GO
ALTER TABLE [PRES].[ContratoDetalle] ADD  CONSTRAINT [DF_ContratoDetalle_Oct]  DEFAULT ((0)) FOR [Octubre]
GO
ALTER TABLE [PRES].[ContratoDetalle] ADD  CONSTRAINT [DF_ContratoDetalle_Nov]  DEFAULT ((0)) FOR [Noviembre]
GO
ALTER TABLE [PRES].[ContratoDetalle] ADD  CONSTRAINT [DF_ContratoDetalle_Dic]  DEFAULT ((0)) FOR [Diciembre]
GO
ALTER TABLE [PRES].[ContratoDetalle] ADD  CONSTRAINT [DF_ContratoDetalle_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[ContratoDetalle] ADD  CONSTRAINT [DF_ContratoDetalle_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[DestinoGasto] ADD  CONSTRAINT [DF_DestinoGasto_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[DestinoGasto] ADD  CONSTRAINT [DF_DestinoGasto_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[DigitoIdentificador] ADD  CONSTRAINT [DF_DigitoIdentificador_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[DigitoIdentificador] ADD  CONSTRAINT [DF_DigitoIdentificador_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[EgresoAutorizado] ADD  CONSTRAINT [DF_EgresoAutorizado_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[EgresoAutorizado] ADD  CONSTRAINT [DF_EgresoAutorizado_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[EgresoAutorizado] ADD  CONSTRAINT [DF_EgresoAutorizado_Enero]  DEFAULT ((0)) FOR [Enero]
GO
ALTER TABLE [PRES].[EgresoAutorizado] ADD  CONSTRAINT [DF_EgresoAutorizado_Febrero]  DEFAULT ((0)) FOR [Febrero]
GO
ALTER TABLE [PRES].[EgresoAutorizado] ADD  CONSTRAINT [DF_EgresoAutorizado_Marzo]  DEFAULT ((0)) FOR [Marzo]
GO
ALTER TABLE [PRES].[EgresoAutorizado] ADD  CONSTRAINT [DF_EgresoAutorizado_Abril]  DEFAULT ((0)) FOR [Abril]
GO
ALTER TABLE [PRES].[EgresoAutorizado] ADD  CONSTRAINT [DF_EgresoAutorizado_Mayo]  DEFAULT ((0)) FOR [Mayo]
GO
ALTER TABLE [PRES].[EgresoAutorizado] ADD  CONSTRAINT [DF_EgresoAutorizado_Junio]  DEFAULT ((0)) FOR [Junio]
GO
ALTER TABLE [PRES].[EgresoAutorizado] ADD  CONSTRAINT [DF_EgresoAutorizado_Julio]  DEFAULT ((0)) FOR [Julio]
GO
ALTER TABLE [PRES].[EgresoAutorizado] ADD  CONSTRAINT [DF_EgresoAutorizado_Agosto]  DEFAULT ((0)) FOR [Agosto]
GO
ALTER TABLE [PRES].[EgresoAutorizado] ADD  CONSTRAINT [DF_EgresoAutorizado_Septiembre]  DEFAULT ((0)) FOR [Septiembre]
GO
ALTER TABLE [PRES].[EgresoAutorizado] ADD  CONSTRAINT [DF_EgresoAutorizado_Octubre]  DEFAULT ((0)) FOR [Octubre]
GO
ALTER TABLE [PRES].[EgresoAutorizado] ADD  CONSTRAINT [DF_EgresoAutorizado_Noviembre]  DEFAULT ((0)) FOR [Noviembre]
GO
ALTER TABLE [PRES].[EgresoAutorizado] ADD  CONSTRAINT [DF_EgresoAutorizado_Diciembre]  DEFAULT ((0)) FOR [Diciembre]
GO
ALTER TABLE [PRES].[EgresoProyectado] ADD  CONSTRAINT [DF_EgresoProyectado_Enero]  DEFAULT ((0)) FOR [Enero]
GO
ALTER TABLE [PRES].[EgresoProyectado] ADD  CONSTRAINT [DF_EgresoProyectado_Febrero]  DEFAULT ((0)) FOR [Febrero]
GO
ALTER TABLE [PRES].[EgresoProyectado] ADD  CONSTRAINT [DF_EgresoProyectado_Marzo]  DEFAULT ((0)) FOR [Marzo]
GO
ALTER TABLE [PRES].[EgresoProyectado] ADD  CONSTRAINT [DF_EgresoProyectado_Abril]  DEFAULT ((0)) FOR [Abril]
GO
ALTER TABLE [PRES].[EgresoProyectado] ADD  CONSTRAINT [DF_EgresoProyectado_Mayo]  DEFAULT ((0)) FOR [Mayo]
GO
ALTER TABLE [PRES].[EgresoProyectado] ADD  CONSTRAINT [DF_EgresoProyectado_Junio]  DEFAULT ((0)) FOR [Junio]
GO
ALTER TABLE [PRES].[EgresoProyectado] ADD  CONSTRAINT [DF_EgresoProyectado_Julio]  DEFAULT ((0)) FOR [Julio]
GO
ALTER TABLE [PRES].[EgresoProyectado] ADD  CONSTRAINT [DF_EgresoProyectado_Agosto]  DEFAULT ((0)) FOR [Agosto]
GO
ALTER TABLE [PRES].[EgresoProyectado] ADD  CONSTRAINT [DF_EgresoProyectado_Septiembre]  DEFAULT ((0)) FOR [Septiembre]
GO
ALTER TABLE [PRES].[EgresoProyectado] ADD  CONSTRAINT [DF_EgresoProyectado_Octubre]  DEFAULT ((0)) FOR [Octubre]
GO
ALTER TABLE [PRES].[EgresoProyectado] ADD  CONSTRAINT [DF_EgresoProyectado_Noviembre]  DEFAULT ((0)) FOR [Noviembre]
GO
ALTER TABLE [PRES].[EgresoProyectado] ADD  CONSTRAINT [DF_EgresoProyectado_Diciembre]  DEFAULT ((0)) FOR [Diciembre]
GO
ALTER TABLE [PRES].[EgresoProyectado] ADD  CONSTRAINT [DF_EgresoProyectado_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[EgresoProyectado] ADD  CONSTRAINT [DF_EgresoProyectado_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[Eje] ADD  CONSTRAINT [DF_Eje_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[Eje] ADD  CONSTRAINT [DF_Eje_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[Factura] ADD  CONSTRAINT [DF_Factura_Estatus]  DEFAULT ((1)) FOR [Estatus]
GO
ALTER TABLE [PRES].[Factura] ADD  CONSTRAINT [DF_Factura_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[Factura] ADD  CONSTRAINT [DF_Factura_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[FacturaDetalle] ADD  CONSTRAINT [DF_FacturaDetalle_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[FacturaDetalle] ADD  CONSTRAINT [DF_FacturaDetalle_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[Finalidad] ADD  CONSTRAINT [DF_Finalidad_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[Finalidad] ADD  CONSTRAINT [DF_Finalidad_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[FN] ADD  CONSTRAINT [DF_FN_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[FN] ADD  CONSTRAINT [DF_FN_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[FuenteFinanciamiento] ADD  CONSTRAINT [DF_FuenteFinanciamiento_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[FuenteFinanciamiento] ADD  CONSTRAINT [DF_FuenteFinanciamiento_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[GF] ADD  CONSTRAINT [DF_GF_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[GF] ADD  CONSTRAINT [DF_GF_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[GrupoPresupuesto] ADD  CONSTRAINT [DF_GrupoPresupuesto_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[GrupoPresupuesto] ADD  CONSTRAINT [DF_GrupoPresupuesto_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[Origen] ADD  CONSTRAINT [DF_Origen_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[Origen] ADD  CONSTRAINT [DF_Origen_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[PG] ADD  CONSTRAINT [DF_PG_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[PG] ADD  CONSTRAINT [DF_PG_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[PP] ADD  CONSTRAINT [DF_PP_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[PP] ADD  CONSTRAINT [DF_PP_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[Programa] ADD  CONSTRAINT [DF_Programa_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[Programa] ADD  CONSTRAINT [DF_Programa_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[PY] ADD  CONSTRAINT [DF_PY_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[PY] ADD  CONSTRAINT [DF_PY_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[Ramo] ADD  CONSTRAINT [DF_Ramo_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[Ramo] ADD  CONSTRAINT [DF_Ramo_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[Resultado] ADD  CONSTRAINT [DF_Resultado_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[Resultado] ADD  CONSTRAINT [DF_Resultado_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[Sector] ADD  CONSTRAINT [DF_Sector_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[Sector] ADD  CONSTRAINT [DF_Sector_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[SF] ADD  CONSTRAINT [DF_SF_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[SF] ADD  CONSTRAINT [DF_SF_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[SolicitudSuficiencia] ADD  CONSTRAINT [DF_SolicitudSuficiencia_Estatus]  DEFAULT ((1)) FOR [Estatus]
GO
ALTER TABLE [PRES].[SolicitudSuficiencia] ADD  CONSTRAINT [DF_SolicitudSuficiencia_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[SolicitudSuficiencia] ADD  CONSTRAINT [DF_SolicitudSuficiencia_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle] ADD  CONSTRAINT [DF_SolicitudSuficienciaDetalle_Ene]  DEFAULT ((0)) FOR [Enero]
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle] ADD  CONSTRAINT [DF_SolicitudSuficienciaDetalle_Feb]  DEFAULT ((0)) FOR [Febrero]
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle] ADD  CONSTRAINT [DF_SolicitudSuficienciaDetalle_Mar]  DEFAULT ((0)) FOR [Marzo]
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle] ADD  CONSTRAINT [DF_SolicitudSuficienciaDetalle_Abr]  DEFAULT ((0)) FOR [Abril]
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle] ADD  CONSTRAINT [DF_SolicitudSuficienciaDetalle_May]  DEFAULT ((0)) FOR [Mayo]
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle] ADD  CONSTRAINT [DF_SolicitudSuficienciaDetalle_Jun]  DEFAULT ((0)) FOR [Junio]
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle] ADD  CONSTRAINT [DF_SolicitudSuficienciaDetalle_Jul]  DEFAULT ((0)) FOR [Julio]
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle] ADD  CONSTRAINT [DF_SolicitudSuficienciaDetalle_Ago]  DEFAULT ((0)) FOR [Agosto]
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle] ADD  CONSTRAINT [DF_SolicitudSuficienciaDetalle_Sep]  DEFAULT ((0)) FOR [Septiembre]
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle] ADD  CONSTRAINT [DF_SolicitudSuficienciaDetalle_Oct]  DEFAULT ((0)) FOR [Octubre]
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle] ADD  CONSTRAINT [DF_SolicitudSuficienciaDetalle_Nov]  DEFAULT ((0)) FOR [Noviembre]
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle] ADD  CONSTRAINT [DF_SolicitudSuficienciaDetalle_Dic]  DEFAULT ((0)) FOR [Diciembre]
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle] ADD  CONSTRAINT [DF_SolicitudSuficienciaDetalle_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle] ADD  CONSTRAINT [DF_SolicitudSuficienciaDetalle_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[SubEje] ADD  CONSTRAINT [DF_SubEje_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[SubEje] ADD  CONSTRAINT [DF_SubEje_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[Subresultado] ADD  CONSTRAINT [DF_Subresultado_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[Subresultado] ADD  CONSTRAINT [DF_Subresultado_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[SubSector] ADD  CONSTRAINT [DF_SubSector_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[SubSector] ADD  CONSTRAINT [DF_SubSector_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[SubSubEje] ADD  CONSTRAINT [DF_SubSubEje_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[SubSubEje] ADD  CONSTRAINT [DF_SubSubEje_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[Suficiencia] ADD  CONSTRAINT [DF_Suficiencia_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[Suficiencia] ADD  CONSTRAINT [DF_Suficiencia_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[TipoGasto] ADD  CONSTRAINT [DF_TipoGasto_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[TipoGasto] ADD  CONSTRAINT [DF_TipoGasto_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[TipoRecurso] ADD  CONSTRAINT [DF_TipoRecurso_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[TipoRecurso] ADD  CONSTRAINT [DF_TipoRecurso_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[UR] ADD  CONSTRAINT [DF_UR_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[UR] ADD  CONSTRAINT [DF_UR_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [PRES].[VertienteGasto] ADD  CONSTRAINT [DF_VertienteGasto_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [PRES].[VertienteGasto] ADD  CONSTRAINT [DF_VertienteGasto_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [SIS].[ActividadInstitucional] ADD  CONSTRAINT [DF_ActividadInstitucional_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[ActividadInstitucional] ADD  CONSTRAINT [DF_ActividadInstitucional_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [SIS].[Anio] ADD  CONSTRAINT [DF_Anio_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[Anio] ADD  CONSTRAINT [DF_Anio_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [SIS].[Area] ADD  CONSTRAINT [DF_Area_Aprovado]  DEFAULT ((0)) FOR [Aprovado]
GO
ALTER TABLE [SIS].[Area] ADD  CONSTRAINT [DF_Area_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[Area] ADD  CONSTRAINT [DF_Area_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [SIS].[Capitulo] ADD  CONSTRAINT [DF_Capitulo_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[Capitulo] ADD  CONSTRAINT [DF_Capitulo_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [SIS].[CatTipoSucursal] ADD  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[Concepto] ADD  CONSTRAINT [DF_Concepto_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[Concepto] ADD  CONSTRAINT [DF_Concepto_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [SIS].[Departamento] ADD  DEFAULT ((1)) FOR [NivelJerarquico]
GO
ALTER TABLE [SIS].[Departamento] ADD  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[Departamento] ADD  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [SIS].[Empresa] ADD  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[Empresa] ADD  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [SIS].[EmpresaEstado] ADD  DEFAULT ((0)) FOR [EsOficinaPrincipal]
GO
ALTER TABLE [SIS].[EmpresaEstado] ADD  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[Estados] ADD  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[EstatusProveedor] ADD  CONSTRAINT [DF_EstatusProveedor_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[EstatusProveedor] ADD  CONSTRAINT [DF_EstatusProveedor_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [SIS].[Idioma] ADD  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[Menu] ADD  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[Menu] ADD  DEFAULT (getdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [SIS].[MenuRole] ADD  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[MenuRole] ADD  DEFAULT (getdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [SIS].[Moneda] ADD  DEFAULT ((2)) FOR [Decimales]
GO
ALTER TABLE [SIS].[Moneda] ADD  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[Municipios] ADD  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[Municipios] ADD  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [SIS].[OrigenLogMessage] ADD  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[OrigenLogMessage] ADD  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [SIS].[Paises] ADD  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[Paises] ADD  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [SIS].[Partida] ADD  CONSTRAINT [DF_Partida_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[Partida] ADD  CONSTRAINT [DF_Partida_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [SIS].[PerfilUsuario] ADD  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[PerfilUsuario] ADD  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [SIS].[Proveedor] ADD  CONSTRAINT [DF_Proveedor_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[Proveedor] ADD  CONSTRAINT [DF_Proveedor_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [SIS].[Sucursal] ADD  DEFAULT ((2)) FOR [FKIdTipoSucursal]
GO
ALTER TABLE [SIS].[Sucursal] ADD  DEFAULT ((0)) FOR [EsMatriz]
GO
ALTER TABLE [SIS].[Sucursal] ADD  DEFAULT ((1)) FOR [EsActiva]
GO
ALTER TABLE [SIS].[Sucursal] ADD  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[Sucursal] ADD  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [SIS].[SystemLog] ADD  DEFAULT (sysdatetime()) FOR [Date]
GO
ALTER TABLE [SIS].[SystemParamCatalog] ADD  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[SystemParamCatalog] ADD  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [SIS].[SystemParamValue] ADD  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[SystemParamValue] ADD  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [SIS].[TipoDetallePoliza] ADD  CONSTRAINT [DF_TipoDetallePoliza_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[TipoDetallePoliza] ADD  CONSTRAINT [DF_TipoDetallePoliza_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [SIS].[TipoDoctoCLC] ADD  CONSTRAINT [DF_TipoDoctoCLC_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[TipoDoctoCLC] ADD  CONSTRAINT [DF_TipoDoctoCLC_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [SIS].[TipoPoliza] ADD  CONSTRAINT [DF_TipoPoliza_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[TipoPoliza] ADD  CONSTRAINT [DF_TipoPoliza_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [SIS].[TipoProveedor] ADD  CONSTRAINT [DF_TipoProveedor_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[TipoProveedor] ADD  CONSTRAINT [DF_TipoProveedor_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [SIS].[Usuario] ADD  DEFAULT ((0)) FOR [EsAdministrador]
GO
ALTER TABLE [SIS].[Usuario] ADD  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[Usuario] ADD  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [SIS].[UsuarioDepartamento] ADD  DEFAULT ((0)) FOR [EsJefe]
GO
ALTER TABLE [SIS].[UsuarioDepartamento] ADD  DEFAULT (sysdatetime()) FOR [FechaAsignacion]
GO
ALTER TABLE [SIS].[UsuarioDepartamento] ADD  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[UsuarioDepartamento] ADD  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [SIS].[UsuarioSucursal] ADD  DEFAULT ((1)) FOR [PuedeAcceder]
GO
ALTER TABLE [SIS].[UsuarioSucursal] ADD  DEFAULT ((0)) FOR [PuedeConfigurar]
GO
ALTER TABLE [SIS].[UsuarioSucursal] ADD  DEFAULT ((1)) FOR [PuedeOperar]
GO
ALTER TABLE [SIS].[UsuarioSucursal] ADD  DEFAULT ((0)) FOR [PuedeReportes]
GO
ALTER TABLE [SIS].[UsuarioSucursal] ADD  DEFAULT ((0)) FOR [EsGerente]
GO
ALTER TABLE [SIS].[UsuarioSucursal] ADD  DEFAULT ((0)) FOR [EsSupervisor]
GO
ALTER TABLE [SIS].[UsuarioSucursal] ADD  DEFAULT (sysdatetime()) FOR [FechaAsignacion]
GO
ALTER TABLE [SIS].[UsuarioSucursal] ADD  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [SIS].[UsuarioSucursal] ADD  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [TES].[Banco] ADD  CONSTRAINT [DF_Banco_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [TES].[Banco] ADD  CONSTRAINT [DF_Banco_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [TES].[CuentaBancaria] ADD  CONSTRAINT [DF_CuentaBancaria_SaldoInicial]  DEFAULT ((0)) FOR [SaldoInicial]
GO
ALTER TABLE [TES].[CuentaBancaria] ADD  CONSTRAINT [DF_CuentaBancaria_SaldoActual]  DEFAULT ((0)) FOR [SaldoActual]
GO
ALTER TABLE [TES].[CuentaBancaria] ADD  CONSTRAINT [DF_CuentaBancaria_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [TES].[CuentaBancaria] ADD  CONSTRAINT [DF_CuentaBancaria_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [TES].[Instrumento] ADD  CONSTRAINT [DF_Instrumento_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [TES].[Instrumento] ADD  CONSTRAINT [DF_Instrumento_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [TES].[Interes] ADD  CONSTRAINT [DF_Interes_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [TES].[Interes] ADD  CONSTRAINT [DF_Interes_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [TES].[IntermediarioFinanciero] ADD  CONSTRAINT [DF_IntermediarioFinanciero_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [TES].[IntermediarioFinanciero] ADD  CONSTRAINT [DF_IntermediarioFinanciero_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [TES].[Inversion] ADD  CONSTRAINT [DF_Inversion_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [TES].[Inversion] ADD  CONSTRAINT [DF_Inversion_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [TES].[Retiro] ADD  CONSTRAINT [DF_Retiro_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [TES].[Retiro] ADD  CONSTRAINT [DF_Retiro_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [TES].[TipoCambio] ADD  CONSTRAINT [DF_TipoCambio_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [TES].[TipoCambio] ADD  CONSTRAINT [DF_TipoCambio_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [TES].[TipoDoctoCLC] ADD  CONSTRAINT [DF_TipoDoctoCLC_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [TES].[TipoDoctoCLC] ADD  CONSTRAINT [DF_TipoDoctoCLC_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [TES].[TipoInversion] ADD  CONSTRAINT [DF_TipoInversion_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [TES].[TipoInversion] ADD  CONSTRAINT [DF_TipoInversion_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [TES].[TipoMoneda] ADD  DEFAULT ((2)) FOR [Decimales]
GO
ALTER TABLE [TES].[TipoMoneda] ADD  CONSTRAINT [DF_TipoMoneda_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [TES].[TipoMoneda] ADD  CONSTRAINT [DF_TipoMoneda_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [TES].[TipoPago] ADD  CONSTRAINT [DF_TipoPago_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [TES].[TipoPago] ADD  CONSTRAINT [DF_TipoPago_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [TES].[TipoPagoSF] ADD  CONSTRAINT [DF_TipoPagoSF_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [TES].[TipoPagoSF] ADD  CONSTRAINT [DF_TipoPagoSF_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [TES].[TipoPlazo] ADD  CONSTRAINT [DF_TipoPlazo_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [TES].[TipoPlazo] ADD  CONSTRAINT [DF_TipoPlazo_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [TES].[TipoRetiro] ADD  CONSTRAINT [DF_TipoRetiro_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [TES].[TipoRetiro] ADD  CONSTRAINT [DF_TipoRetiro_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [TES].[TipoSolicitudCLC] ADD  CONSTRAINT [DF_TipoSolicitudCLC_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [TES].[TipoSolicitudCLC] ADD  CONSTRAINT [DF_TipoSolicitudCLC_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [ALMA].[Bien]  WITH CHECK ADD  CONSTRAINT [FK_Bien_Area] FOREIGN KEY([FKIdArea_SIS])
REFERENCES [SIS].[Area] ([PKIdArea])
GO
ALTER TABLE [ALMA].[Bien] CHECK CONSTRAINT [FK_Bien_Area]
GO
ALTER TABLE [ALMA].[Bien]  WITH CHECK ADD  CONSTRAINT [FK_Bien_EstadoBien] FOREIGN KEY([FKIdEstadoBien_ALMA])
REFERENCES [ALMA].[EstadoBien] ([PKIdEstadoBien])
GO
ALTER TABLE [ALMA].[Bien] CHECK CONSTRAINT [FK_Bien_EstadoBien]
GO
ALTER TABLE [ALMA].[Bien]  WITH CHECK ADD  CONSTRAINT [FK_Bien_GrupoBien] FOREIGN KEY([FKIdGrupoBien_ALMA])
REFERENCES [ALMA].[GrupoBien] ([PKIdGrupoBien])
GO
ALTER TABLE [ALMA].[Bien] CHECK CONSTRAINT [FK_Bien_GrupoBien]
GO
ALTER TABLE [ALMA].[Bien]  WITH CHECK ADD  CONSTRAINT [FK_Bien_Marca] FOREIGN KEY([FKIdMarca_ALMA])
REFERENCES [ALMA].[Marca] ([PKIdMarca])
GO
ALTER TABLE [ALMA].[Bien] CHECK CONSTRAINT [FK_Bien_Marca]
GO
ALTER TABLE [ALMA].[Bien]  WITH CHECK ADD  CONSTRAINT [FK_Bien_Material] FOREIGN KEY([FKIdMaterial_ALMA])
REFERENCES [ALMA].[Material] ([PKIdMaterial])
GO
ALTER TABLE [ALMA].[Bien] CHECK CONSTRAINT [FK_Bien_Material]
GO
ALTER TABLE [ALMA].[Bien]  WITH CHECK ADD  CONSTRAINT [FK_Bien_Partida] FOREIGN KEY([FKIdPartida_CONTA])
REFERENCES [CONTA].[Partida] ([PKIdPartida])
GO
ALTER TABLE [ALMA].[Bien] CHECK CONSTRAINT [FK_Bien_Partida]
GO
ALTER TABLE [ALMA].[Bien]  WITH CHECK ADD  CONSTRAINT [FK_Bien_Proveedor] FOREIGN KEY([FKIdProveedor_SIS])
REFERENCES [SIS].[Proveedor] ([PKIdProveedor])
GO
ALTER TABLE [ALMA].[Bien] CHECK CONSTRAINT [FK_Bien_Proveedor]
GO
ALTER TABLE [ALMA].[Bien]  WITH CHECK ADD  CONSTRAINT [FK_Bien_TipoAdquisicion] FOREIGN KEY([FKIdTipoAdq_ALMA])
REFERENCES [ALMA].[TipoAdquisicion] ([PKIdTipoAdq])
GO
ALTER TABLE [ALMA].[Bien] CHECK CONSTRAINT [FK_Bien_TipoAdquisicion]
GO
ALTER TABLE [ALMA].[Bien]  WITH CHECK ADD  CONSTRAINT [FK_Bien_TipoBien] FOREIGN KEY([FKIdTipoBien_ALMA])
REFERENCES [ALMA].[TipoBien] ([PKIdTipoBien])
GO
ALTER TABLE [ALMA].[Bien] CHECK CONSTRAINT [FK_Bien_TipoBien]
GO
ALTER TABLE [ALMA].[Bien]  WITH CHECK ADD  CONSTRAINT [FK_Bien_TipoPatrimonio] FOREIGN KEY([FKIdTipoPatrimonio_ALMA])
REFERENCES [ALMA].[TipoPatrimonio] ([PKIdTipoPatrimonio])
GO
ALTER TABLE [ALMA].[Bien] CHECK CONSTRAINT [FK_Bien_TipoPatrimonio]
GO
ALTER TABLE [ALMA].[Bien]  WITH CHECK ADD  CONSTRAINT [FK_Bien_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[Bien] CHECK CONSTRAINT [FK_Bien_UsuarioCreacion]
GO
ALTER TABLE [ALMA].[Bien]  WITH CHECK ADD  CONSTRAINT [FK_Bien_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[Bien] CHECK CONSTRAINT [FK_Bien_UsuarioModificacion]
GO
ALTER TABLE [ALMA].[Conteo]  WITH CHECK ADD  CONSTRAINT [FK_Conteo_PeriodoConteo] FOREIGN KEY([FKIdPeriodoConteo_ALMA])
REFERENCES [ALMA].[PeriodoConteo] ([PKIdPeriodoConteo])
GO
ALTER TABLE [ALMA].[Conteo] CHECK CONSTRAINT [FK_Conteo_PeriodoConteo]
GO
ALTER TABLE [ALMA].[Conteo]  WITH CHECK ADD  CONSTRAINT [FK_Conteo_TipoBien] FOREIGN KEY([FKIdTipoBien_ALMA])
REFERENCES [ALMA].[TipoBien] ([PKIdTipoBien])
GO
ALTER TABLE [ALMA].[Conteo] CHECK CONSTRAINT [FK_Conteo_TipoBien]
GO
ALTER TABLE [ALMA].[Conteo]  WITH CHECK ADD  CONSTRAINT [FK_Conteo_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[Conteo] CHECK CONSTRAINT [FK_Conteo_UsuarioCreacion]
GO
ALTER TABLE [ALMA].[Conteo]  WITH CHECK ADD  CONSTRAINT [FK_Conteo_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[Conteo] CHECK CONSTRAINT [FK_Conteo_UsuarioModificacion]
GO
ALTER TABLE [ALMA].[ConteoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_ConteoDetalle_Conteo] FOREIGN KEY([FKIdConteo_ALMA])
REFERENCES [ALMA].[Conteo] ([PKIdConteo])
GO
ALTER TABLE [ALMA].[ConteoDetalle] CHECK CONSTRAINT [FK_ConteoDetalle_Conteo]
GO
ALTER TABLE [ALMA].[ConteoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_ConteoDetalle_Persona] FOREIGN KEY([FKIdPersona_NOM])
REFERENCES [NOM].[Persona] ([PKIdPersona])
GO
ALTER TABLE [ALMA].[ConteoDetalle] CHECK CONSTRAINT [FK_ConteoDetalle_Persona]
GO
ALTER TABLE [ALMA].[ConteoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_ConteoDetalle_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[ConteoDetalle] CHECK CONSTRAINT [FK_ConteoDetalle_UsuarioCreacion]
GO
ALTER TABLE [ALMA].[ConteoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_ConteoDetalle_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[ConteoDetalle] CHECK CONSTRAINT [FK_ConteoDetalle_UsuarioModificacion]
GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo]  WITH CHECK ADD  CONSTRAINT [FK_ConteoDetalleEscaneo_Conteo] FOREIGN KEY([FKIdConteo_ALMA])
REFERENCES [ALMA].[Conteo] ([PKIdConteo])
GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo] CHECK CONSTRAINT [FK_ConteoDetalleEscaneo_Conteo]
GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo]  WITH CHECK ADD  CONSTRAINT [FK_ConteoDetalleEscaneo_Persona] FOREIGN KEY([FKIdPersona_NOM])
REFERENCES [NOM].[Persona] ([PKIdPersona])
GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo] CHECK CONSTRAINT [FK_ConteoDetalleEscaneo_Persona]
GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo]  WITH CHECK ADD  CONSTRAINT [FK_ConteoDetalleEscaneo_TipoBien] FOREIGN KEY([FKIdTipoBien_ALMA])
REFERENCES [ALMA].[TipoBien] ([PKIdTipoBien])
GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo] CHECK CONSTRAINT [FK_ConteoDetalleEscaneo_TipoBien]
GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo]  WITH CHECK ADD  CONSTRAINT [FK_ConteoDetalleEscaneo_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo] CHECK CONSTRAINT [FK_ConteoDetalleEscaneo_UsuarioCreacion]
GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo]  WITH CHECK ADD  CONSTRAINT [FK_ConteoDetalleEscaneo_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo] CHECK CONSTRAINT [FK_ConteoDetalleEscaneo_UsuarioModificacion]
GO
ALTER TABLE [ALMA].[EstadoBien]  WITH CHECK ADD  CONSTRAINT [FK_EstadoBien_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[EstadoBien] CHECK CONSTRAINT [FK_EstadoBien_UsuarioCreacion]
GO
ALTER TABLE [ALMA].[EstadoBien]  WITH CHECK ADD  CONSTRAINT [FK_EstadoBien_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[EstadoBien] CHECK CONSTRAINT [FK_EstadoBien_UsuarioModificacion]
GO
ALTER TABLE [ALMA].[EstatusSolicitud]  WITH CHECK ADD  CONSTRAINT [FK_EstatusSolicitud_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[EstatusSolicitud] CHECK CONSTRAINT [FK_EstatusSolicitud_UsuarioCreacion]
GO
ALTER TABLE [ALMA].[EstatusSolicitud]  WITH CHECK ADD  CONSTRAINT [FK_EstatusSolicitud_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[EstatusSolicitud] CHECK CONSTRAINT [FK_EstatusSolicitud_UsuarioModificacion]
GO
ALTER TABLE [ALMA].[Familia]  WITH CHECK ADD  CONSTRAINT [FK_Familia_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[Familia] CHECK CONSTRAINT [FK_Familia_UsuarioCreacion]
GO
ALTER TABLE [ALMA].[Familia]  WITH CHECK ADD  CONSTRAINT [FK_Familia_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[Familia] CHECK CONSTRAINT [FK_Familia_UsuarioModificacion]
GO
ALTER TABLE [ALMA].[GrupoBien]  WITH CHECK ADD  CONSTRAINT [FK_GrupoBien_Familia] FOREIGN KEY([FKIdFamilia_ALMA])
REFERENCES [ALMA].[Familia] ([PKIdFamilia])
GO
ALTER TABLE [ALMA].[GrupoBien] CHECK CONSTRAINT [FK_GrupoBien_Familia]
GO
ALTER TABLE [ALMA].[GrupoBien]  WITH CHECK ADD  CONSTRAINT [FK_GrupoBien_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[GrupoBien] CHECK CONSTRAINT [FK_GrupoBien_UsuarioCreacion]
GO
ALTER TABLE [ALMA].[GrupoBien]  WITH CHECK ADD  CONSTRAINT [FK_GrupoBien_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[GrupoBien] CHECK CONSTRAINT [FK_GrupoBien_UsuarioModificacion]
GO
ALTER TABLE [ALMA].[Marca]  WITH CHECK ADD  CONSTRAINT [FK_Marca_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[Marca] CHECK CONSTRAINT [FK_Marca_UsuarioCreacion]
GO
ALTER TABLE [ALMA].[Marca]  WITH CHECK ADD  CONSTRAINT [FK_Marca_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[Marca] CHECK CONSTRAINT [FK_Marca_UsuarioModificacion]
GO
ALTER TABLE [ALMA].[Material]  WITH CHECK ADD  CONSTRAINT [FK_Material_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[Material] CHECK CONSTRAINT [FK_Material_UsuarioCreacion]
GO
ALTER TABLE [ALMA].[Material]  WITH CHECK ADD  CONSTRAINT [FK_Material_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[Material] CHECK CONSTRAINT [FK_Material_UsuarioModificacion]
GO
ALTER TABLE [ALMA].[MotivoES]  WITH CHECK ADD  CONSTRAINT [FK_MotivoES_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[MotivoES] CHECK CONSTRAINT [FK_MotivoES_UsuarioCreacion]
GO
ALTER TABLE [ALMA].[MotivoES]  WITH CHECK ADD  CONSTRAINT [FK_MotivoES_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[MotivoES] CHECK CONSTRAINT [FK_MotivoES_UsuarioModificacion]
GO
ALTER TABLE [ALMA].[Nivel]  WITH CHECK ADD  CONSTRAINT [FK_Nivel_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[Nivel] CHECK CONSTRAINT [FK_Nivel_UsuarioCreacion]
GO
ALTER TABLE [ALMA].[Nivel]  WITH CHECK ADD  CONSTRAINT [FK_Nivel_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[Nivel] CHECK CONSTRAINT [FK_Nivel_UsuarioModificacion]
GO
ALTER TABLE [ALMA].[PeriodoConteo]  WITH CHECK ADD  CONSTRAINT [FK_PeriodoConteo_Estatus] FOREIGN KEY([FKIdEstatus_ALMA])
REFERENCES [ALMA].[EstatusPeriodo] ([PKIdEstatusPeriodo])
GO
ALTER TABLE [ALMA].[PeriodoConteo] CHECK CONSTRAINT [FK_PeriodoConteo_Estatus]
GO
ALTER TABLE [ALMA].[PeriodoConteo]  WITH CHECK ADD  CONSTRAINT [FK_PeriodoConteo_Responsable] FOREIGN KEY([FKIdResponsable_SIS])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[PeriodoConteo] CHECK CONSTRAINT [FK_PeriodoConteo_Responsable]
GO
ALTER TABLE [ALMA].[PeriodoConteo]  WITH CHECK ADD  CONSTRAINT [FK_PeriodoConteo_Sucursal] FOREIGN KEY([FKIdSucursal_SIS])
REFERENCES [SIS].[Sucursal] ([PKIdSucursal])
GO
ALTER TABLE [ALMA].[PeriodoConteo] CHECK CONSTRAINT [FK_PeriodoConteo_Sucursal]
GO
ALTER TABLE [ALMA].[PeriodoConteo]  WITH CHECK ADD  CONSTRAINT [FK_PeriodoConteo_Supervisor] FOREIGN KEY([FKIdSupervisor_SIS])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[PeriodoConteo] CHECK CONSTRAINT [FK_PeriodoConteo_Supervisor]
GO
ALTER TABLE [ALMA].[PeriodoConteo]  WITH CHECK ADD  CONSTRAINT [FK_PeriodoConteo_TipoConteo] FOREIGN KEY([FKIdTipoConteo_ALMA])
REFERENCES [ALMA].[TipoConteo] ([PKIdTipoConteo])
GO
ALTER TABLE [ALMA].[PeriodoConteo] CHECK CONSTRAINT [FK_PeriodoConteo_TipoConteo]
GO
ALTER TABLE [ALMA].[PeriodoConteo]  WITH CHECK ADD  CONSTRAINT [FK_PeriodoConteo_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[PeriodoConteo] CHECK CONSTRAINT [FK_PeriodoConteo_UsuarioCreacion]
GO
ALTER TABLE [ALMA].[PeriodoConteo]  WITH CHECK ADD  CONSTRAINT [FK_PeriodoConteo_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[PeriodoConteo] CHECK CONSTRAINT [FK_PeriodoConteo_UsuarioModificacion]
GO
ALTER TABLE [ALMA].[TipoAdquisicion]  WITH CHECK ADD  CONSTRAINT [FK_TipoAdquisicion_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[TipoAdquisicion] CHECK CONSTRAINT [FK_TipoAdquisicion_UsuarioCreacion]
GO
ALTER TABLE [ALMA].[TipoAdquisicion]  WITH CHECK ADD  CONSTRAINT [FK_TipoAdquisicion_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[TipoAdquisicion] CHECK CONSTRAINT [FK_TipoAdquisicion_UsuarioModificacion]
GO
ALTER TABLE [ALMA].[TipoBien]  WITH CHECK ADD  CONSTRAINT [FK_TipoBien_CuentaContable] FOREIGN KEY([FKIdCuentaContable_CONTA])
REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable])
GO
ALTER TABLE [ALMA].[TipoBien] CHECK CONSTRAINT [FK_TipoBien_CuentaContable]
GO
ALTER TABLE [ALMA].[TipoBien]  WITH CHECK ADD  CONSTRAINT [FK_TipoBien_GrupoBien] FOREIGN KEY([FKIdGrupoBien_ALMA])
REFERENCES [ALMA].[GrupoBien] ([PKIdGrupoBien])
GO
ALTER TABLE [ALMA].[TipoBien] CHECK CONSTRAINT [FK_TipoBien_GrupoBien]
GO
ALTER TABLE [ALMA].[TipoBien]  WITH CHECK ADD  CONSTRAINT [FK_TipoBien_Nivel] FOREIGN KEY([FKIdNivel_ALMA])
REFERENCES [ALMA].[Nivel] ([PKIdNivel])
GO
ALTER TABLE [ALMA].[TipoBien] CHECK CONSTRAINT [FK_TipoBien_Nivel]
GO
ALTER TABLE [ALMA].[TipoBien]  WITH CHECK ADD  CONSTRAINT [FK_TipoBien_Partida] FOREIGN KEY([FKIdPartida_CONTA])
REFERENCES [CONTA].[Partida] ([PKIdPartida])
GO
ALTER TABLE [ALMA].[TipoBien] CHECK CONSTRAINT [FK_TipoBien_Partida]
GO
ALTER TABLE [ALMA].[TipoBien]  WITH CHECK ADD  CONSTRAINT [FK_TipoBien_Unidades] FOREIGN KEY([FKIdUnidades_ALMA])
REFERENCES [ALMA].[Unidades] ([PKIdUnidades])
GO
ALTER TABLE [ALMA].[TipoBien] CHECK CONSTRAINT [FK_TipoBien_Unidades]
GO
ALTER TABLE [ALMA].[TipoBien]  WITH CHECK ADD  CONSTRAINT [FK_TipoBien_UnidadesEquivalente] FOREIGN KEY([FKIdUnidades_Equivalente])
REFERENCES [ALMA].[Unidades] ([PKIdUnidades])
GO
ALTER TABLE [ALMA].[TipoBien] CHECK CONSTRAINT [FK_TipoBien_UnidadesEquivalente]
GO
ALTER TABLE [ALMA].[TipoBien]  WITH CHECK ADD  CONSTRAINT [FK_TipoBien_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[TipoBien] CHECK CONSTRAINT [FK_TipoBien_UsuarioCreacion]
GO
ALTER TABLE [ALMA].[TipoBien]  WITH CHECK ADD  CONSTRAINT [FK_TipoBien_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[TipoBien] CHECK CONSTRAINT [FK_TipoBien_UsuarioModificacion]
GO
ALTER TABLE [ALMA].[TipoPatrimonio]  WITH CHECK ADD  CONSTRAINT [FK_TipoPatrimonio_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[TipoPatrimonio] CHECK CONSTRAINT [FK_TipoPatrimonio_UsuarioCreacion]
GO
ALTER TABLE [ALMA].[TipoPatrimonio]  WITH CHECK ADD  CONSTRAINT [FK_TipoPatrimonio_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[TipoPatrimonio] CHECK CONSTRAINT [FK_TipoPatrimonio_UsuarioModificacion]
GO
ALTER TABLE [ALMA].[Unidades]  WITH CHECK ADD  CONSTRAINT [FK_Unidades_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[Unidades] CHECK CONSTRAINT [FK_Unidades_UsuarioCreacion]
GO
ALTER TABLE [ALMA].[Unidades]  WITH CHECK ADD  CONSTRAINT [FK_Unidades_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ALMA].[Unidades] CHECK CONSTRAINT [FK_Unidades_UsuarioModificacion]
GO
ALTER TABLE [CONTA].[Capitulo]  WITH CHECK ADD  CONSTRAINT [FK_Capitulo_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [CONTA].[Capitulo] CHECK CONSTRAINT [FK_Capitulo_UsuarioCreacion]
GO
ALTER TABLE [CONTA].[Capitulo]  WITH CHECK ADD  CONSTRAINT [FK_Capitulo_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [CONTA].[Capitulo] CHECK CONSTRAINT [FK_Capitulo_UsuarioModificacion]
GO
ALTER TABLE [CONTA].[Concepto]  WITH CHECK ADD  CONSTRAINT [FK_Concepto_Capitulo] FOREIGN KEY([FKIdCapitulo_CONTA])
REFERENCES [CONTA].[Capitulo] ([PKIdCapitulo])
GO
ALTER TABLE [CONTA].[Concepto] CHECK CONSTRAINT [FK_Concepto_Capitulo]
GO
ALTER TABLE [CONTA].[Concepto]  WITH CHECK ADD  CONSTRAINT [FK_Concepto_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [CONTA].[Concepto] CHECK CONSTRAINT [FK_Concepto_UsuarioCreacion]
GO
ALTER TABLE [CONTA].[Concepto]  WITH CHECK ADD  CONSTRAINT [FK_Concepto_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [CONTA].[Concepto] CHECK CONSTRAINT [FK_Concepto_UsuarioModificacion]
GO
ALTER TABLE [CONTA].[ConsecutivoPoliza]  WITH CHECK ADD  CONSTRAINT [FK_ConsecutivoPoliza_Anio] FOREIGN KEY([FK_IdAnio__SIS])
REFERENCES [SIS].[Anio] ([PKIdAnio])
GO
ALTER TABLE [CONTA].[ConsecutivoPoliza] CHECK CONSTRAINT [FK_ConsecutivoPoliza_Anio]
GO
ALTER TABLE [CONTA].[ConsecutivoPoliza]  WITH CHECK ADD  CONSTRAINT [FK_ConsecutivoPoliza_TipoPoliza] FOREIGN KEY([FK_IdTipoPoliza__SIS])
REFERENCES [SIS].[TipoPoliza] ([PKIdTipoPoliza])
GO
ALTER TABLE [CONTA].[ConsecutivoPoliza] CHECK CONSTRAINT [FK_ConsecutivoPoliza_TipoPoliza]
GO
ALTER TABLE [CONTA].[CuentaContable]  WITH CHECK ADD  CONSTRAINT [FK_CuentaContable_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [CONTA].[CuentaContable] CHECK CONSTRAINT [FK_CuentaContable_Empresa]
GO
ALTER TABLE [CONTA].[CuentaContable]  WITH CHECK ADD  CONSTRAINT [FK_CuentaContable_TipoCuenta] FOREIGN KEY([FKIdTipoCuenta_CONTA])
REFERENCES [CONTA].[TipoCuenta] ([PKIdTipoCuenta])
GO
ALTER TABLE [CONTA].[CuentaContable] CHECK CONSTRAINT [FK_CuentaContable_TipoCuenta]
GO
ALTER TABLE [CONTA].[CuentaContable]  WITH CHECK ADD  CONSTRAINT [FK_CuentaContable_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [CONTA].[CuentaContable] CHECK CONSTRAINT [FK_CuentaContable_UsuarioCreacion]
GO
ALTER TABLE [CONTA].[CuentaContable]  WITH CHECK ADD  CONSTRAINT [FK_CuentaContable_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [CONTA].[CuentaContable] CHECK CONSTRAINT [FK_CuentaContable_UsuarioModificacion]
GO
ALTER TABLE [CONTA].[MatrizConversion]  WITH CHECK ADD  CONSTRAINT [FK_MatrizConversion_Anio] FOREIGN KEY([FKIdAnio_SIS])
REFERENCES [SIS].[Anio] ([PKIdAnio])
GO
ALTER TABLE [CONTA].[MatrizConversion] CHECK CONSTRAINT [FK_MatrizConversion_Anio]
GO
ALTER TABLE [CONTA].[MatrizConversion]  WITH CHECK ADD  CONSTRAINT [FK_MatrizConversion_CtaAprobado] FOREIGN KEY([FKIdCuentaContableAprobado])
REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable])
GO
ALTER TABLE [CONTA].[MatrizConversion] CHECK CONSTRAINT [FK_MatrizConversion_CtaAprobado]
GO
ALTER TABLE [CONTA].[MatrizConversion]  WITH CHECK ADD  CONSTRAINT [FK_MatrizConversion_CtaComprometido] FOREIGN KEY([FKIdCuentaContableComprometido])
REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable])
GO
ALTER TABLE [CONTA].[MatrizConversion] CHECK CONSTRAINT [FK_MatrizConversion_CtaComprometido]
GO
ALTER TABLE [CONTA].[MatrizConversion]  WITH CHECK ADD  CONSTRAINT [FK_MatrizConversion_CtaDevengado] FOREIGN KEY([FKIdCuentaContableDevengado])
REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable])
GO
ALTER TABLE [CONTA].[MatrizConversion] CHECK CONSTRAINT [FK_MatrizConversion_CtaDevengado]
GO
ALTER TABLE [CONTA].[MatrizConversion]  WITH CHECK ADD  CONSTRAINT [FK_MatrizConversion_CtaEjercido] FOREIGN KEY([FKIdCuentaContableEjercido])
REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable])
GO
ALTER TABLE [CONTA].[MatrizConversion] CHECK CONSTRAINT [FK_MatrizConversion_CtaEjercido]
GO
ALTER TABLE [CONTA].[MatrizConversion]  WITH CHECK ADD  CONSTRAINT [FK_MatrizConversion_CtaGasto] FOREIGN KEY([FKIdCuentaContableGasto])
REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable])
GO
ALTER TABLE [CONTA].[MatrizConversion] CHECK CONSTRAINT [FK_MatrizConversion_CtaGasto]
GO
ALTER TABLE [CONTA].[MatrizConversion]  WITH CHECK ADD  CONSTRAINT [FK_MatrizConversion_CtaModificado] FOREIGN KEY([FKIdCuentaContableModificado])
REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable])
GO
ALTER TABLE [CONTA].[MatrizConversion] CHECK CONSTRAINT [FK_MatrizConversion_CtaModificado]
GO
ALTER TABLE [CONTA].[MatrizConversion]  WITH CHECK ADD  CONSTRAINT [FK_MatrizConversion_CtaPagado] FOREIGN KEY([FKIdCuentaContablePagado])
REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable])
GO
ALTER TABLE [CONTA].[MatrizConversion] CHECK CONSTRAINT [FK_MatrizConversion_CtaPagado]
GO
ALTER TABLE [CONTA].[MatrizConversion]  WITH CHECK ADD  CONSTRAINT [FK_MatrizConversion_CtaPorEjercer] FOREIGN KEY([FKIdCuentaContablePorEjercer])
REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable])
GO
ALTER TABLE [CONTA].[MatrizConversion] CHECK CONSTRAINT [FK_MatrizConversion_CtaPorEjercer]
GO
ALTER TABLE [CONTA].[MatrizConversion]  WITH CHECK ADD  CONSTRAINT [FK_MatrizConversion_Partida] FOREIGN KEY([FKIdPartida_SIS])
REFERENCES [SIS].[Partida] ([PKIdPartida])
GO
ALTER TABLE [CONTA].[MatrizConversion] CHECK CONSTRAINT [FK_MatrizConversion_Partida]
GO
ALTER TABLE [CONTA].[MatrizConversion]  WITH CHECK ADD  CONSTRAINT [FK_MatrizConversion_Programa] FOREIGN KEY([FKIdPrograma_PRES])
REFERENCES [PRES].[Programa] ([PKIdPrograma])
GO
ALTER TABLE [CONTA].[MatrizConversion] CHECK CONSTRAINT [FK_MatrizConversion_Programa]
GO
ALTER TABLE [CONTA].[MatrizConversion]  WITH CHECK ADD  CONSTRAINT [FK_MatrizConversion_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [CONTA].[MatrizConversion] CHECK CONSTRAINT [FK_MatrizConversion_UsuarioCreacion]
GO
ALTER TABLE [CONTA].[MatrizConversion]  WITH CHECK ADD  CONSTRAINT [FK_MatrizConversion_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [CONTA].[MatrizConversion] CHECK CONSTRAINT [FK_MatrizConversion_UsuarioModificacion]
GO
ALTER TABLE [CONTA].[MatrizIngreso]  WITH CHECK ADD  CONSTRAINT [FK_MatrizIngreso_Anio] FOREIGN KEY([FK_IdAnio__SIS])
REFERENCES [SIS].[Anio] ([PKIdAnio])
GO
ALTER TABLE [CONTA].[MatrizIngreso] CHECK CONSTRAINT [FK_MatrizIngreso_Anio]
GO
ALTER TABLE [CONTA].[MatrizIngreso]  WITH CHECK ADD  CONSTRAINT [FK_MatrizIngreso_CtaAutorizado] FOREIGN KEY([Fk_IdCuentaContableAutorizado])
REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable])
GO
ALTER TABLE [CONTA].[MatrizIngreso] CHECK CONSTRAINT [FK_MatrizIngreso_CtaAutorizado]
GO
ALTER TABLE [CONTA].[MatrizIngreso]  WITH CHECK ADD  CONSTRAINT [FK_MatrizIngreso_CtaDeposito] FOREIGN KEY([Fk_IdCuentaContableDeposito])
REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable])
GO
ALTER TABLE [CONTA].[MatrizIngreso] CHECK CONSTRAINT [FK_MatrizIngreso_CtaDeposito]
GO
ALTER TABLE [CONTA].[MatrizIngreso]  WITH CHECK ADD  CONSTRAINT [FK_MatrizIngreso_CtaDevengado] FOREIGN KEY([Fk_IdCuentaContableDevengado])
REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable])
GO
ALTER TABLE [CONTA].[MatrizIngreso] CHECK CONSTRAINT [FK_MatrizIngreso_CtaDevengado]
GO
ALTER TABLE [CONTA].[MatrizIngreso]  WITH CHECK ADD  CONSTRAINT [FK_MatrizIngreso_CtaModificado] FOREIGN KEY([Fk_IdCuentaContableModificado])
REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable])
GO
ALTER TABLE [CONTA].[MatrizIngreso] CHECK CONSTRAINT [FK_MatrizIngreso_CtaModificado]
GO
ALTER TABLE [CONTA].[MatrizIngreso]  WITH CHECK ADD  CONSTRAINT [FK_MatrizIngreso_CtaPorEjercer] FOREIGN KEY([Fk_IdCuentaContablePorEjercer])
REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable])
GO
ALTER TABLE [CONTA].[MatrizIngreso] CHECK CONSTRAINT [FK_MatrizIngreso_CtaPorEjercer]
GO
ALTER TABLE [CONTA].[MatrizIngreso]  WITH CHECK ADD  CONSTRAINT [FK_MatrizIngreso_CtaRecaudado] FOREIGN KEY([Fk_IdCuentaContableRecaudado])
REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable])
GO
ALTER TABLE [CONTA].[MatrizIngreso] CHECK CONSTRAINT [FK_MatrizIngreso_CtaRecaudado]
GO
ALTER TABLE [CONTA].[MatrizIngreso]  WITH CHECK ADD  CONSTRAINT [FK_MatrizIngreso_Origen] FOREIGN KEY([Fk_IdOrigen])
REFERENCES [PRES].[Origen] ([PKIdOrigen])
GO
ALTER TABLE [CONTA].[MatrizIngreso] CHECK CONSTRAINT [FK_MatrizIngreso_Origen]
GO
ALTER TABLE [CONTA].[MatrizIngreso]  WITH CHECK ADD  CONSTRAINT [FK_MatrizIngreso_Programa] FOREIGN KEY([Fk_IdPrograma])
REFERENCES [PRES].[Programa] ([PKIdPrograma])
GO
ALTER TABLE [CONTA].[MatrizIngreso] CHECK CONSTRAINT [FK_MatrizIngreso_Programa]
GO
ALTER TABLE [CONTA].[MatrizIngreso]  WITH CHECK ADD  CONSTRAINT [FK_MatrizIngreso_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [CONTA].[MatrizIngreso] CHECK CONSTRAINT [FK_MatrizIngreso_UsuarioCreacion]
GO
ALTER TABLE [CONTA].[MatrizIngreso]  WITH CHECK ADD  CONSTRAINT [FK_MatrizIngreso_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [CONTA].[MatrizIngreso] CHECK CONSTRAINT [FK_MatrizIngreso_UsuarioModificacion]
GO
ALTER TABLE [CONTA].[Partida]  WITH CHECK ADD  CONSTRAINT [FK_Partida_Concepto] FOREIGN KEY([FKIdConcepto_SIS])
REFERENCES [CONTA].[Concepto] ([PKIdConcepto])
GO
ALTER TABLE [CONTA].[Partida] CHECK CONSTRAINT [FK_Partida_Concepto]
GO
ALTER TABLE [CONTA].[Partida]  WITH CHECK ADD  CONSTRAINT [FK_Partida_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [CONTA].[Partida] CHECK CONSTRAINT [FK_Partida_UsuarioCreacion]
GO
ALTER TABLE [CONTA].[Partida]  WITH CHECK ADD  CONSTRAINT [FK_Partida_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [CONTA].[Partida] CHECK CONSTRAINT [FK_Partida_UsuarioModificacion]
GO
ALTER TABLE [CONTA].[Poliza]  WITH CHECK ADD  CONSTRAINT [FK_Poliza_Anio] FOREIGN KEY([FKIdAnio_SIS])
REFERENCES [SIS].[Anio] ([PKIdAnio])
GO
ALTER TABLE [CONTA].[Poliza] CHECK CONSTRAINT [FK_Poliza_Anio]
GO
ALTER TABLE [CONTA].[Poliza]  WITH CHECK ADD  CONSTRAINT [FK_Poliza_TipoPoliza] FOREIGN KEY([FKIdTipoPoliza_SIS])
REFERENCES [SIS].[TipoPoliza] ([PKIdTipoPoliza])
GO
ALTER TABLE [CONTA].[Poliza] CHECK CONSTRAINT [FK_Poliza_TipoPoliza]
GO
ALTER TABLE [CONTA].[Poliza]  WITH CHECK ADD  CONSTRAINT [FK_Poliza_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [CONTA].[Poliza] CHECK CONSTRAINT [FK_Poliza_UsuarioCreacion]
GO
ALTER TABLE [CONTA].[Poliza]  WITH CHECK ADD  CONSTRAINT [FK_Poliza_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [CONTA].[Poliza] CHECK CONSTRAINT [FK_Poliza_UsuarioModificacion]
GO
ALTER TABLE [CONTA].[PolizaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_PolizaDetalle_CuentaContable] FOREIGN KEY([FKIdCuentaContable_CONTA])
REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable])
GO
ALTER TABLE [CONTA].[PolizaDetalle] CHECK CONSTRAINT [FK_PolizaDetalle_CuentaContable]
GO
ALTER TABLE [CONTA].[PolizaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_PolizaDetalle_Poliza] FOREIGN KEY([FKIdPoliza_CONTA])
REFERENCES [CONTA].[Poliza] ([PKIdPoliza])
GO
ALTER TABLE [CONTA].[PolizaDetalle] CHECK CONSTRAINT [FK_PolizaDetalle_Poliza]
GO
ALTER TABLE [CONTA].[PolizaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_PolizaDetalle_TipoDetallePoliza] FOREIGN KEY([FKIdTipoDetallePoliza_SIS])
REFERENCES [SIS].[TipoDetallePoliza] ([PkIdTipoDetallePoliza])
GO
ALTER TABLE [CONTA].[PolizaDetalle] CHECK CONSTRAINT [FK_PolizaDetalle_TipoDetallePoliza]
GO
ALTER TABLE [CONTA].[PolizaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_PolizaDetalle_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [CONTA].[PolizaDetalle] CHECK CONSTRAINT [FK_PolizaDetalle_UsuarioCreacion]
GO
ALTER TABLE [CONTA].[PolizaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_PolizaDetalle_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [CONTA].[PolizaDetalle] CHECK CONSTRAINT [FK_PolizaDetalle_UsuarioModificacion]
GO
ALTER TABLE [CONTA].[TipoCuenta]  WITH CHECK ADD  CONSTRAINT [FK_TipoCuenta_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [CONTA].[TipoCuenta] CHECK CONSTRAINT [FK_TipoCuenta_UsuarioCreacion]
GO
ALTER TABLE [CONTA].[TipoCuenta]  WITH CHECK ADD  CONSTRAINT [FK_TipoCuenta_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [CONTA].[TipoCuenta] CHECK CONSTRAINT [FK_TipoCuenta_UsuarioModificacion]
GO
ALTER TABLE [CONTA].[TipoDoctoPago]  WITH CHECK ADD  CONSTRAINT [FK_TipoDoctoPago_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [CONTA].[TipoDoctoPago] CHECK CONSTRAINT [FK_TipoDoctoPago_UsuarioCreacion]
GO
ALTER TABLE [CONTA].[TipoDoctoPago]  WITH CHECK ADD  CONSTRAINT [FK_TipoDoctoPago_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [CONTA].[TipoDoctoPago] CHECK CONSTRAINT [FK_TipoDoctoPago_UsuarioModificacion]
GO
ALTER TABLE [dbo].[AspNetClaims]  WITH CHECK ADD  CONSTRAINT [CONSTRAINT_FK_AspNetClaims_ClaimType] FOREIGN KEY([ClaimTypeId])
REFERENCES [dbo].[AspNetClaimTypes] ([Id])
GO
ALTER TABLE [dbo].[AspNetClaims] CHECK CONSTRAINT [CONSTRAINT_FK_AspNetClaims_ClaimType]
GO
ALTER TABLE [dbo].[AspNetClaims]  WITH CHECK ADD  CONSTRAINT [CONSTRAINT_FK_AspNetClaims_Role] FOREIGN KEY([RoleId])
REFERENCES [dbo].[AspNetRoles] ([Id])
GO
ALTER TABLE [dbo].[AspNetClaims] CHECK CONSTRAINT [CONSTRAINT_FK_AspNetClaims_Role]
GO
ALTER TABLE [dbo].[AspNetClaimValues]  WITH CHECK ADD  CONSTRAINT [CONSTRAINT_FK_AspNetClaimValues_Claim] FOREIGN KEY([ClaimId])
REFERENCES [dbo].[AspNetClaims] ([Id])
GO
ALTER TABLE [dbo].[AspNetClaimValues] CHECK CONSTRAINT [CONSTRAINT_FK_AspNetClaimValues_Claim]
GO
ALTER TABLE [dbo].[AspNetUserRoles]  WITH CHECK ADD  CONSTRAINT [CONSTRAINT_FK_AspNetUserRoles_Role] FOREIGN KEY([RoleId])
REFERENCES [dbo].[AspNetRoles] ([Id])
GO
ALTER TABLE [dbo].[AspNetUserRoles] CHECK CONSTRAINT [CONSTRAINT_FK_AspNetUserRoles_Role]
GO
ALTER TABLE [dbo].[AspNetUserRoles]  WITH CHECK ADD  CONSTRAINT [CONSTRAINT_FK_AspNetUserRoles_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[AspNetUserRoles] CHECK CONSTRAINT [CONSTRAINT_FK_AspNetUserRoles_User]
GO
ALTER TABLE [dbo].[AspNetUsers]  WITH CHECK ADD  CONSTRAINT [CONSTRAINT_FK_AspNetUsers_Usuario] FOREIGN KEY([PkIdUsuario])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [dbo].[AspNetUsers] CHECK CONSTRAINT [CONSTRAINT_FK_AspNetUsers_Usuario]
GO
ALTER TABLE [NOM].[Persona]  WITH CHECK ADD  CONSTRAINT [FK_Persona_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [NOM].[Persona] CHECK CONSTRAINT [FK_Persona_UsuarioCreacion]
GO
ALTER TABLE [NOM].[Persona]  WITH CHECK ADD  CONSTRAINT [FK_Persona_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [NOM].[Persona] CHECK CONSTRAINT [FK_Persona_UsuarioModificacion]
GO
ALTER TABLE [NOM].[PersonaArea]  WITH CHECK ADD  CONSTRAINT [FK_PersonaArea_Area] FOREIGN KEY([FKIdArea_SIS])
REFERENCES [SIS].[Area] ([PKIdArea])
GO
ALTER TABLE [NOM].[PersonaArea] CHECK CONSTRAINT [FK_PersonaArea_Area]
GO
ALTER TABLE [NOM].[PersonaArea]  WITH CHECK ADD  CONSTRAINT [FK_PersonaArea_Persona] FOREIGN KEY([FKIdPersona_NOM])
REFERENCES [NOM].[Persona] ([PKIdPersona])
GO
ALTER TABLE [NOM].[PersonaArea] CHECK CONSTRAINT [FK_PersonaArea_Persona]
GO
ALTER TABLE [NOM].[PersonaArea]  WITH CHECK ADD  CONSTRAINT [FK_PersonaArea_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [NOM].[PersonaArea] CHECK CONSTRAINT [FK_PersonaArea_UsuarioCreacion]
GO
ALTER TABLE [NOM].[PersonaArea]  WITH CHECK ADD  CONSTRAINT [FK_PersonaArea_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [NOM].[PersonaArea] CHECK CONSTRAINT [FK_PersonaArea_UsuarioModificacion]
GO
ALTER TABLE [ORCO].[Articulo]  WITH CHECK ADD  CONSTRAINT [FK_Articulo_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[Articulo] CHECK CONSTRAINT [FK_Articulo_UsuarioCreacion]
GO
ALTER TABLE [ORCO].[Articulo]  WITH CHECK ADD  CONSTRAINT [FK_Articulo_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[Articulo] CHECK CONSTRAINT [FK_Articulo_UsuarioModificacion]
GO
ALTER TABLE [ORCO].[Cotizacion]  WITH CHECK ADD  CONSTRAINT [FK_Cotizacion_Anio] FOREIGN KEY([FKIdAnio_SIS])
REFERENCES [SIS].[Anio] ([PKIdAnio])
GO
ALTER TABLE [ORCO].[Cotizacion] CHECK CONSTRAINT [FK_Cotizacion_Anio]
GO
ALTER TABLE [ORCO].[Cotizacion]  WITH CHECK ADD  CONSTRAINT [FK_Cotizacion_Proveedor] FOREIGN KEY([FKIdProveedor_SIS])
REFERENCES [SIS].[Proveedor] ([PKIdProveedor])
GO
ALTER TABLE [ORCO].[Cotizacion] CHECK CONSTRAINT [FK_Cotizacion_Proveedor]
GO
ALTER TABLE [ORCO].[Cotizacion]  WITH CHECK ADD  CONSTRAINT [FK_Cotizacion_Requisicion] FOREIGN KEY([FKIdRequisicion_ORCO])
REFERENCES [ORCO].[Requisicion] ([PKIdRequisicion])
GO
ALTER TABLE [ORCO].[Cotizacion] CHECK CONSTRAINT [FK_Cotizacion_Requisicion]
GO
ALTER TABLE [ORCO].[Cotizacion]  WITH CHECK ADD  CONSTRAINT [FK_Cotizacion_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[Cotizacion] CHECK CONSTRAINT [FK_Cotizacion_UsuarioCreacion]
GO
ALTER TABLE [ORCO].[Cotizacion]  WITH CHECK ADD  CONSTRAINT [FK_Cotizacion_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[Cotizacion] CHECK CONSTRAINT [FK_Cotizacion_UsuarioModificacion]
GO
ALTER TABLE [ORCO].[CotizacionDetalle]  WITH CHECK ADD  CONSTRAINT [FK_CotizacionDetalle_Cotizacion] FOREIGN KEY([FKIdCotizacion_ORCO])
REFERENCES [ORCO].[Cotizacion] ([PKIdCotizacion])
GO
ALTER TABLE [ORCO].[CotizacionDetalle] CHECK CONSTRAINT [FK_CotizacionDetalle_Cotizacion]
GO
ALTER TABLE [ORCO].[CotizacionDetalle]  WITH CHECK ADD  CONSTRAINT [FK_CotizacionDetalle_RequisicionDetalle] FOREIGN KEY([FKIdRequisicionDetalle_ORCO])
REFERENCES [ORCO].[RequisicionDetalle] ([PKIdRequisicionDetalle])
GO
ALTER TABLE [ORCO].[CotizacionDetalle] CHECK CONSTRAINT [FK_CotizacionDetalle_RequisicionDetalle]
GO
ALTER TABLE [ORCO].[CotizacionDetalle]  WITH CHECK ADD  CONSTRAINT [FK_CotizacionDetalle_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[CotizacionDetalle] CHECK CONSTRAINT [FK_CotizacionDetalle_UsuarioCreacion]
GO
ALTER TABLE [ORCO].[CotizacionDetalle]  WITH CHECK ADD  CONSTRAINT [FK_CotizacionDetalle_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[CotizacionDetalle] CHECK CONSTRAINT [FK_CotizacionDetalle_UsuarioModificacion]
GO
ALTER TABLE [ORCO].[EstatusRequisicion]  WITH CHECK ADD  CONSTRAINT [FK_EstatusRequisicion_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[EstatusRequisicion] CHECK CONSTRAINT [FK_EstatusRequisicion_UsuarioCreacion]
GO
ALTER TABLE [ORCO].[EstatusRequisicion]  WITH CHECK ADD  CONSTRAINT [FK_EstatusRequisicion_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[EstatusRequisicion] CHECK CONSTRAINT [FK_EstatusRequisicion_UsuarioModificacion]
GO
ALTER TABLE [ORCO].[EstudioMercado]  WITH CHECK ADD  CONSTRAINT [FK_EstudioMercado_Anio] FOREIGN KEY([FKIdAnio_SIS])
REFERENCES [SIS].[Anio] ([PKIdAnio])
GO
ALTER TABLE [ORCO].[EstudioMercado] CHECK CONSTRAINT [FK_EstudioMercado_Anio]
GO
ALTER TABLE [ORCO].[EstudioMercado]  WITH CHECK ADD  CONSTRAINT [FK_EstudioMercado_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [ORCO].[EstudioMercado] CHECK CONSTRAINT [FK_EstudioMercado_Empresa]
GO
ALTER TABLE [ORCO].[EstudioMercado]  WITH CHECK ADD  CONSTRAINT [FK_EstudioMercado_Responsable] FOREIGN KEY([FKIdResponsable_NOM])
REFERENCES [NOM].[Persona] ([PKIdPersona])
GO
ALTER TABLE [ORCO].[EstudioMercado] CHECK CONSTRAINT [FK_EstudioMercado_Responsable]
GO
ALTER TABLE [ORCO].[EstudioMercado]  WITH CHECK ADD  CONSTRAINT [FK_EstudioMercado_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[EstudioMercado] CHECK CONSTRAINT [FK_EstudioMercado_UsuarioCreacion]
GO
ALTER TABLE [ORCO].[EstudioMercado]  WITH CHECK ADD  CONSTRAINT [FK_EstudioMercado_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[EstudioMercado] CHECK CONSTRAINT [FK_EstudioMercado_UsuarioModificacion]
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_EstudioMercadoDetalle_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle] CHECK CONSTRAINT [FK_EstudioMercadoDetalle_Empresa]
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_EstudioMercadoDetalle_EstudioMercado] FOREIGN KEY([FKIdEstudioMercado_ORCO])
REFERENCES [ORCO].[EstudioMercado] ([PKIdEstudioMercado])
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle] CHECK CONSTRAINT [FK_EstudioMercadoDetalle_EstudioMercado]
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_EstudioMercadoDetalle_PAAASDetalle] FOREIGN KEY([FKIdPAAASDetalle_ORCO])
REFERENCES [ORCO].[PAAASDetalle] ([PKIdPAAASDetalle])
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle] CHECK CONSTRAINT [FK_EstudioMercadoDetalle_PAAASDetalle]
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_EstudioMercadoDetalle_Proveedor] FOREIGN KEY([FKIdProveedor_SIS])
REFERENCES [SIS].[Proveedor] ([PKIdProveedor])
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle] CHECK CONSTRAINT [FK_EstudioMercadoDetalle_Proveedor]
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_EstudioMercadoDetalle_TipoBien] FOREIGN KEY([FKIdTipoBien_ALMA])
REFERENCES [ALMA].[TipoBien] ([PKIdTipoBien])
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle] CHECK CONSTRAINT [FK_EstudioMercadoDetalle_TipoBien]
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_EstudioMercadoDetalle_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle] CHECK CONSTRAINT [FK_EstudioMercadoDetalle_UsuarioCreacion]
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_EstudioMercadoDetalle_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle] CHECK CONSTRAINT [FK_EstudioMercadoDetalle_UsuarioModificacion]
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalleCosto]  WITH CHECK ADD  CONSTRAINT [FK_EstudioMercadoDetalleCosto_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalleCosto] CHECK CONSTRAINT [FK_EstudioMercadoDetalleCosto_Empresa]
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalleCosto]  WITH CHECK ADD  CONSTRAINT [FK_EstudioMercadoDetalleCosto_EstudioMercadoDetalle] FOREIGN KEY([FKIdEstudioMercadoDetalle_ORCO])
REFERENCES [ORCO].[EstudioMercadoDetalle] ([PKIdEstudioMercadoDetalle])
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalleCosto] CHECK CONSTRAINT [FK_EstudioMercadoDetalleCosto_EstudioMercadoDetalle]
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalleCosto]  WITH CHECK ADD  CONSTRAINT [FK_EstudioMercadoDetalleCosto_SolicitudCotizacion] FOREIGN KEY([FKIdSolicitudCotizacion_ORCO])
REFERENCES [ORCO].[SolicitudCotizacion] ([PKIdSolicitudCotizacion])
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalleCosto] CHECK CONSTRAINT [FK_EstudioMercadoDetalleCosto_SolicitudCotizacion]
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalleCosto]  WITH CHECK ADD  CONSTRAINT [FK_EstudioMercadoDetalleCosto_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalleCosto] CHECK CONSTRAINT [FK_EstudioMercadoDetalleCosto_UsuarioCreacion]
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalleCosto]  WITH CHECK ADD  CONSTRAINT [FK_EstudioMercadoDetalleCosto_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalleCosto] CHECK CONSTRAINT [FK_EstudioMercadoDetalleCosto_UsuarioModificacion]
GO
ALTER TABLE [ORCO].[Fraccion]  WITH CHECK ADD  CONSTRAINT [FK_Fraccion_Articulo] FOREIGN KEY([FKIdArticulo_ORCO])
REFERENCES [ORCO].[Articulo] ([PKIdArticulo])
GO
ALTER TABLE [ORCO].[Fraccion] CHECK CONSTRAINT [FK_Fraccion_Articulo]
GO
ALTER TABLE [ORCO].[Fraccion]  WITH CHECK ADD  CONSTRAINT [FK_Fraccion_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[Fraccion] CHECK CONSTRAINT [FK_Fraccion_UsuarioCreacion]
GO
ALTER TABLE [ORCO].[Fraccion]  WITH CHECK ADD  CONSTRAINT [FK_Fraccion_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[Fraccion] CHECK CONSTRAINT [FK_Fraccion_UsuarioModificacion]
GO
ALTER TABLE [ORCO].[Modalidad]  WITH CHECK ADD  CONSTRAINT [FK_Modalidad_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[Modalidad] CHECK CONSTRAINT [FK_Modalidad_UsuarioCreacion]
GO
ALTER TABLE [ORCO].[Modalidad]  WITH CHECK ADD  CONSTRAINT [FK_Modalidad_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[Modalidad] CHECK CONSTRAINT [FK_Modalidad_UsuarioModificacion]
GO
ALTER TABLE [ORCO].[PAAAS]  WITH CHECK ADD  CONSTRAINT [FK_PAAAS_Anio] FOREIGN KEY([FKIdAnio_SIS])
REFERENCES [SIS].[Anio] ([PKIdAnio])
GO
ALTER TABLE [ORCO].[PAAAS] CHECK CONSTRAINT [FK_PAAAS_Anio]
GO
ALTER TABLE [ORCO].[PAAAS]  WITH CHECK ADD  CONSTRAINT [FK_PAAAS_Area] FOREIGN KEY([FKIdArea_SIS])
REFERENCES [SIS].[Area] ([PKIdArea])
GO
ALTER TABLE [ORCO].[PAAAS] CHECK CONSTRAINT [FK_PAAAS_Area]
GO
ALTER TABLE [ORCO].[PAAAS]  WITH CHECK ADD  CONSTRAINT [FK_PAAAS_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [ORCO].[PAAAS] CHECK CONSTRAINT [FK_PAAAS_Empresa]
GO
ALTER TABLE [ORCO].[PAAAS]  WITH CHECK ADD  CONSTRAINT [FK_PAAAS_FuenteFinanciamiento] FOREIGN KEY([FKIdFuenteFinanciamiento_PRES])
REFERENCES [PRES].[FuenteFinanciamiento] ([PKIdFuenteFinanciamiento])
GO
ALTER TABLE [ORCO].[PAAAS] CHECK CONSTRAINT [FK_PAAAS_FuenteFinanciamiento]
GO
ALTER TABLE [ORCO].[PAAAS]  WITH CHECK ADD  CONSTRAINT [FK_PAAAS_Persona] FOREIGN KEY([FKIdPersona_NOM])
REFERENCES [NOM].[Persona] ([PKIdPersona])
GO
ALTER TABLE [ORCO].[PAAAS] CHECK CONSTRAINT [FK_PAAAS_Persona]
GO
ALTER TABLE [ORCO].[PAAAS]  WITH CHECK ADD  CONSTRAINT [FK_PAAAS_Programa] FOREIGN KEY([FKIdPrograma_PRES])
REFERENCES [PRES].[Programa] ([PKIdPrograma])
GO
ALTER TABLE [ORCO].[PAAAS] CHECK CONSTRAINT [FK_PAAAS_Programa]
GO
ALTER TABLE [ORCO].[PAAAS]  WITH CHECK ADD  CONSTRAINT [FK_PAAAS_Proyecto] FOREIGN KEY([FKIdProyecto_ORCO])
REFERENCES [ORCO].[Proyecto] ([PKIdProyecto])
GO
ALTER TABLE [ORCO].[PAAAS] CHECK CONSTRAINT [FK_PAAAS_Proyecto]
GO
ALTER TABLE [ORCO].[PAAAS]  WITH CHECK ADD  CONSTRAINT [FK_PAAAS_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[PAAAS] CHECK CONSTRAINT [FK_PAAAS_UsuarioCreacion]
GO
ALTER TABLE [ORCO].[PAAAS]  WITH CHECK ADD  CONSTRAINT [FK_PAAAS_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[PAAAS] CHECK CONSTRAINT [FK_PAAAS_UsuarioModificacion]
GO
ALTER TABLE [ORCO].[PAAASDetalle]  WITH CHECK ADD  CONSTRAINT [FK_PAAASDetalle_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [ORCO].[PAAASDetalle] CHECK CONSTRAINT [FK_PAAASDetalle_Empresa]
GO
ALTER TABLE [ORCO].[PAAASDetalle]  WITH CHECK ADD  CONSTRAINT [FK_PAAASDetalle_PAAASPartida] FOREIGN KEY([FKIdPAAASPartida_ORCO])
REFERENCES [ORCO].[PAAASPartida] ([PKIdPAAASPartida])
GO
ALTER TABLE [ORCO].[PAAASDetalle] CHECK CONSTRAINT [FK_PAAASDetalle_PAAASPartida]
GO
ALTER TABLE [ORCO].[PAAASDetalle]  WITH CHECK ADD  CONSTRAINT [FK_PAAASDetalle_TipoBien] FOREIGN KEY([FKIdTipoBien_ALMA])
REFERENCES [ALMA].[TipoBien] ([PKIdTipoBien])
GO
ALTER TABLE [ORCO].[PAAASDetalle] CHECK CONSTRAINT [FK_PAAASDetalle_TipoBien]
GO
ALTER TABLE [ORCO].[PAAASDetalle]  WITH CHECK ADD  CONSTRAINT [FK_PAAASDetalle_Unidades] FOREIGN KEY([FKIdUnidades_ALMA])
REFERENCES [ALMA].[Unidades] ([PKIdUnidades])
GO
ALTER TABLE [ORCO].[PAAASDetalle] CHECK CONSTRAINT [FK_PAAASDetalle_Unidades]
GO
ALTER TABLE [ORCO].[PAAASDetalle]  WITH CHECK ADD  CONSTRAINT [FK_PAAASDetalle_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[PAAASDetalle] CHECK CONSTRAINT [FK_PAAASDetalle_UsuarioCreacion]
GO
ALTER TABLE [ORCO].[PAAASDetalle]  WITH CHECK ADD  CONSTRAINT [FK_PAAASDetalle_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[PAAASDetalle] CHECK CONSTRAINT [FK_PAAASDetalle_UsuarioModificacion]
GO
ALTER TABLE [ORCO].[PAAASPartida]  WITH CHECK ADD  CONSTRAINT [FK_PAAASPartida_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [ORCO].[PAAASPartida] CHECK CONSTRAINT [FK_PAAASPartida_Empresa]
GO
ALTER TABLE [ORCO].[PAAASPartida]  WITH CHECK ADD  CONSTRAINT [FK_PAAASPartida_PAAAS] FOREIGN KEY([FKIdPAAAS_ORCO])
REFERENCES [ORCO].[PAAAS] ([PKIdPAAAS])
GO
ALTER TABLE [ORCO].[PAAASPartida] CHECK CONSTRAINT [FK_PAAASPartida_PAAAS]
GO
ALTER TABLE [ORCO].[PAAASPartida]  WITH CHECK ADD  CONSTRAINT [FK_PAAASPartida_Partida] FOREIGN KEY([FKIdPartida_CONTA])
REFERENCES [CONTA].[Partida] ([PKIdPartida])
GO
ALTER TABLE [ORCO].[PAAASPartida] CHECK CONSTRAINT [FK_PAAASPartida_Partida]
GO
ALTER TABLE [ORCO].[PAAASPartida]  WITH CHECK ADD  CONSTRAINT [FK_PAAASPartida_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[PAAASPartida] CHECK CONSTRAINT [FK_PAAASPartida_UsuarioCreacion]
GO
ALTER TABLE [ORCO].[PAAASPartida]  WITH CHECK ADD  CONSTRAINT [FK_PAAASPartida_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[PAAASPartida] CHECK CONSTRAINT [FK_PAAASPartida_UsuarioModificacion]
GO
ALTER TABLE [ORCO].[ProcedimientoContratacion]  WITH CHECK ADD  CONSTRAINT [FK_ProcedimientoContratacion_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[ProcedimientoContratacion] CHECK CONSTRAINT [FK_ProcedimientoContratacion_UsuarioCreacion]
GO
ALTER TABLE [ORCO].[ProcedimientoContratacion]  WITH CHECK ADD  CONSTRAINT [FK_ProcedimientoContratacion_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[ProcedimientoContratacion] CHECK CONSTRAINT [FK_ProcedimientoContratacion_UsuarioModificacion]
GO
ALTER TABLE [ORCO].[Proyecto]  WITH CHECK ADD  CONSTRAINT [FK_Proyecto_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[Proyecto] CHECK CONSTRAINT [FK_Proyecto_UsuarioCreacion]
GO
ALTER TABLE [ORCO].[Proyecto]  WITH CHECK ADD  CONSTRAINT [FK_Proyecto_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[Proyecto] CHECK CONSTRAINT [FK_Proyecto_UsuarioModificacion]
GO
ALTER TABLE [ORCO].[Requisicion]  WITH CHECK ADD  CONSTRAINT [FK_Requisicion_Anio] FOREIGN KEY([FKIdAnio_SIS])
REFERENCES [SIS].[Anio] ([PKIdAnio])
GO
ALTER TABLE [ORCO].[Requisicion] CHECK CONSTRAINT [FK_Requisicion_Anio]
GO
ALTER TABLE [ORCO].[Requisicion]  WITH CHECK ADD  CONSTRAINT [FK_Requisicion_Area] FOREIGN KEY([FKIdArea_SIS])
REFERENCES [SIS].[Area] ([PKIdArea])
GO
ALTER TABLE [ORCO].[Requisicion] CHECK CONSTRAINT [FK_Requisicion_Area]
GO
ALTER TABLE [ORCO].[Requisicion]  WITH CHECK ADD  CONSTRAINT [FK_Requisicion_Autorizo] FOREIGN KEY([FKIdAutorizo_NOM])
REFERENCES [NOM].[Persona] ([PKIdPersona])
GO
ALTER TABLE [ORCO].[Requisicion] CHECK CONSTRAINT [FK_Requisicion_Autorizo]
GO
ALTER TABLE [ORCO].[Requisicion]  WITH CHECK ADD  CONSTRAINT [FK_Requisicion_DestinoGasto] FOREIGN KEY([FKIdDestinoGasto_PRES])
REFERENCES [PRES].[DestinoGasto] ([PKIdDestinoGasto])
GO
ALTER TABLE [ORCO].[Requisicion] CHECK CONSTRAINT [FK_Requisicion_DestinoGasto]
GO
ALTER TABLE [ORCO].[Requisicion]  WITH CHECK ADD  CONSTRAINT [FK_Requisicion_DigitoIdentificador] FOREIGN KEY([FKIdDigitoIdentificador_PRES])
REFERENCES [PRES].[DigitoIdentificador] ([PKIdDigitoIdentificador])
GO
ALTER TABLE [ORCO].[Requisicion] CHECK CONSTRAINT [FK_Requisicion_DigitoIdentificador]
GO
ALTER TABLE [ORCO].[Requisicion]  WITH CHECK ADD  CONSTRAINT [FK_Requisicion_EgresoAutorizado] FOREIGN KEY([FKIdEgresoAutorizado_PRES])
REFERENCES [PRES].[EgresoAutorizado] ([PKIdEgresoAutorizado])
GO
ALTER TABLE [ORCO].[Requisicion] CHECK CONSTRAINT [FK_Requisicion_EgresoAutorizado]
GO
ALTER TABLE [ORCO].[Requisicion]  WITH CHECK ADD  CONSTRAINT [FK_Requisicion_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [ORCO].[Requisicion] CHECK CONSTRAINT [FK_Requisicion_Empresa]
GO
ALTER TABLE [ORCO].[Requisicion]  WITH CHECK ADD  CONSTRAINT [FK_Requisicion_FuenteFinanciamiento] FOREIGN KEY([FKIdFuenteFinanciamiento_PRES])
REFERENCES [PRES].[FuenteFinanciamiento] ([PKIdFuenteFinanciamiento])
GO
ALTER TABLE [ORCO].[Requisicion] CHECK CONSTRAINT [FK_Requisicion_FuenteFinanciamiento]
GO
ALTER TABLE [ORCO].[Requisicion]  WITH CHECK ADD  CONSTRAINT [FK_Requisicion_JefeAlmacen] FOREIGN KEY([FKIdJefeAlmacen_NOM])
REFERENCES [NOM].[Persona] ([PKIdPersona])
GO
ALTER TABLE [ORCO].[Requisicion] CHECK CONSTRAINT [FK_Requisicion_JefeAlmacen]
GO
ALTER TABLE [ORCO].[Requisicion]  WITH CHECK ADD  CONSTRAINT [FK_Requisicion_PAutorizo] FOREIGN KEY([FKIdPAutorizo_NOM])
REFERENCES [NOM].[Persona] ([PKIdPersona])
GO
ALTER TABLE [ORCO].[Requisicion] CHECK CONSTRAINT [FK_Requisicion_PAutorizo]
GO
ALTER TABLE [ORCO].[Requisicion]  WITH CHECK ADD  CONSTRAINT [FK_Requisicion_Persona] FOREIGN KEY([FKIdPersona_NOM])
REFERENCES [NOM].[Persona] ([PKIdPersona])
GO
ALTER TABLE [ORCO].[Requisicion] CHECK CONSTRAINT [FK_Requisicion_Persona]
GO
ALTER TABLE [ORCO].[Requisicion]  WITH CHECK ADD  CONSTRAINT [FK_Requisicion_PJefeAlmacen] FOREIGN KEY([FKIdPJefeAlmacen_NOM])
REFERENCES [NOM].[Persona] ([PKIdPersona])
GO
ALTER TABLE [ORCO].[Requisicion] CHECK CONSTRAINT [FK_Requisicion_PJefeAlmacen]
GO
ALTER TABLE [ORCO].[Requisicion]  WITH CHECK ADD  CONSTRAINT [FK_Requisicion_Programa] FOREIGN KEY([FKIdPrograma_PRES])
REFERENCES [PRES].[Programa] ([PKIdPrograma])
GO
ALTER TABLE [ORCO].[Requisicion] CHECK CONSTRAINT [FK_Requisicion_Programa]
GO
ALTER TABLE [ORCO].[Requisicion]  WITH CHECK ADD  CONSTRAINT [FK_Requisicion_Proyecto] FOREIGN KEY([FKIdProyecto_ORCO])
REFERENCES [ORCO].[Proyecto] ([PKIdProyecto])
GO
ALTER TABLE [ORCO].[Requisicion] CHECK CONSTRAINT [FK_Requisicion_Proyecto]
GO
ALTER TABLE [ORCO].[Requisicion]  WITH CHECK ADD  CONSTRAINT [FK_Requisicion_PSolicita] FOREIGN KEY([FKIdPSolicita_NOM])
REFERENCES [NOM].[Persona] ([PKIdPersona])
GO
ALTER TABLE [ORCO].[Requisicion] CHECK CONSTRAINT [FK_Requisicion_PSolicita]
GO
ALTER TABLE [ORCO].[Requisicion]  WITH CHECK ADD  CONSTRAINT [FK_Requisicion_PSuficiencia] FOREIGN KEY([FKIdPSuficiencia_NOM])
REFERENCES [NOM].[Persona] ([PKIdPersona])
GO
ALTER TABLE [ORCO].[Requisicion] CHECK CONSTRAINT [FK_Requisicion_PSuficiencia]
GO
ALTER TABLE [ORCO].[Requisicion]  WITH CHECK ADD  CONSTRAINT [FK_Requisicion_PSuperviso] FOREIGN KEY([FKIdPSuperviso_NOM])
REFERENCES [NOM].[Persona] ([PKIdPersona])
GO
ALTER TABLE [ORCO].[Requisicion] CHECK CONSTRAINT [FK_Requisicion_PSuperviso]
GO
ALTER TABLE [ORCO].[Requisicion]  WITH CHECK ADD  CONSTRAINT [FK_Requisicion_Suficiencia] FOREIGN KEY([FKIdSuficiencia_PRES])
REFERENCES [PRES].[Suficiencia] ([PKIdSuficiencia])
GO
ALTER TABLE [ORCO].[Requisicion] CHECK CONSTRAINT [FK_Requisicion_Suficiencia]
GO
ALTER TABLE [ORCO].[Requisicion]  WITH CHECK ADD  CONSTRAINT [FK_Requisicion_Superviso] FOREIGN KEY([FKIdSuperviso_NOM])
REFERENCES [NOM].[Persona] ([PKIdPersona])
GO
ALTER TABLE [ORCO].[Requisicion] CHECK CONSTRAINT [FK_Requisicion_Superviso]
GO
ALTER TABLE [ORCO].[Requisicion]  WITH CHECK ADD  CONSTRAINT [FK_Requisicion_TipoGasto] FOREIGN KEY([FKIdTipoGasto_PRES])
REFERENCES [PRES].[TipoGasto] ([PKIdTipoGasto])
GO
ALTER TABLE [ORCO].[Requisicion] CHECK CONSTRAINT [FK_Requisicion_TipoGasto]
GO
ALTER TABLE [ORCO].[Requisicion]  WITH CHECK ADD  CONSTRAINT [FK_Requisicion_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[Requisicion] CHECK CONSTRAINT [FK_Requisicion_UsuarioCreacion]
GO
ALTER TABLE [ORCO].[Requisicion]  WITH CHECK ADD  CONSTRAINT [FK_Requisicion_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[Requisicion] CHECK CONSTRAINT [FK_Requisicion_UsuarioModificacion]
GO
ALTER TABLE [ORCO].[RequisicionDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RequisicionDetalle_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [ORCO].[RequisicionDetalle] CHECK CONSTRAINT [FK_RequisicionDetalle_Empresa]
GO
ALTER TABLE [ORCO].[RequisicionDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RequisicionDetalle_Requisicion] FOREIGN KEY([FKIdRequisicion_ORCO])
REFERENCES [ORCO].[Requisicion] ([PKIdRequisicion])
GO
ALTER TABLE [ORCO].[RequisicionDetalle] CHECK CONSTRAINT [FK_RequisicionDetalle_Requisicion]
GO
ALTER TABLE [ORCO].[RequisicionDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RequisicionDetalle_TipoBien] FOREIGN KEY([FKIdTipoBien_ALMA])
REFERENCES [ALMA].[TipoBien] ([PKIdTipoBien])
GO
ALTER TABLE [ORCO].[RequisicionDetalle] CHECK CONSTRAINT [FK_RequisicionDetalle_TipoBien]
GO
ALTER TABLE [ORCO].[RequisicionDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RequisicionDetalle_Unidades] FOREIGN KEY([FKIdUnidades_ALMA])
REFERENCES [ALMA].[Unidades] ([PKIdUnidades])
GO
ALTER TABLE [ORCO].[RequisicionDetalle] CHECK CONSTRAINT [FK_RequisicionDetalle_Unidades]
GO
ALTER TABLE [ORCO].[RequisicionDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RequisicionDetalle_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[RequisicionDetalle] CHECK CONSTRAINT [FK_RequisicionDetalle_UsuarioCreacion]
GO
ALTER TABLE [ORCO].[RequisicionDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RequisicionDetalle_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[RequisicionDetalle] CHECK CONSTRAINT [FK_RequisicionDetalle_UsuarioModificacion]
GO
ALTER TABLE [ORCO].[RequisicionPartida]  WITH CHECK ADD  CONSTRAINT [FK_RequisicionPartida_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [ORCO].[RequisicionPartida] CHECK CONSTRAINT [FK_RequisicionPartida_Empresa]
GO
ALTER TABLE [ORCO].[RequisicionPartida]  WITH CHECK ADD  CONSTRAINT [FK_RequisicionPartida_Partida] FOREIGN KEY([FKIdPartida_CONTA])
REFERENCES [CONTA].[Partida] ([PKIdPartida])
GO
ALTER TABLE [ORCO].[RequisicionPartida] CHECK CONSTRAINT [FK_RequisicionPartida_Partida]
GO
ALTER TABLE [ORCO].[RequisicionPartida]  WITH CHECK ADD  CONSTRAINT [FK_RequisicionPartida_Requisicion] FOREIGN KEY([FKIdRequisicion_ORCO])
REFERENCES [ORCO].[Requisicion] ([PKIdRequisicion])
GO
ALTER TABLE [ORCO].[RequisicionPartida] CHECK CONSTRAINT [FK_RequisicionPartida_Requisicion]
GO
ALTER TABLE [ORCO].[RequisicionPartida]  WITH CHECK ADD  CONSTRAINT [FK_RequisicionPartida_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[RequisicionPartida] CHECK CONSTRAINT [FK_RequisicionPartida_UsuarioCreacion]
GO
ALTER TABLE [ORCO].[RequisicionPartida]  WITH CHECK ADD  CONSTRAINT [FK_RequisicionPartida_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[RequisicionPartida] CHECK CONSTRAINT [FK_RequisicionPartida_UsuarioModificacion]
GO
ALTER TABLE [ORCO].[SolicitudCotizacion]  WITH CHECK ADD  CONSTRAINT [FK_SolicitudCotizacion_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [ORCO].[SolicitudCotizacion] CHECK CONSTRAINT [FK_SolicitudCotizacion_Empresa]
GO
ALTER TABLE [ORCO].[SolicitudCotizacion]  WITH CHECK ADD  CONSTRAINT [FK_SolicitudCotizacion_EstudioMercado] FOREIGN KEY([FKIdEstudioMercado_ORCO])
REFERENCES [ORCO].[EstudioMercado] ([PKIdEstudioMercado])
GO
ALTER TABLE [ORCO].[SolicitudCotizacion] CHECK CONSTRAINT [FK_SolicitudCotizacion_EstudioMercado]
GO
ALTER TABLE [ORCO].[SolicitudCotizacion]  WITH CHECK ADD  CONSTRAINT [FK_SolicitudCotizacion_Proveedor] FOREIGN KEY([FKIdProveedor_SIS])
REFERENCES [SIS].[Proveedor] ([PKIdProveedor])
GO
ALTER TABLE [ORCO].[SolicitudCotizacion] CHECK CONSTRAINT [FK_SolicitudCotizacion_Proveedor]
GO
ALTER TABLE [ORCO].[SolicitudCotizacion]  WITH CHECK ADD  CONSTRAINT [FK_SolicitudCotizacion_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[SolicitudCotizacion] CHECK CONSTRAINT [FK_SolicitudCotizacion_UsuarioCreacion]
GO
ALTER TABLE [ORCO].[SolicitudCotizacion]  WITH CHECK ADD  CONSTRAINT [FK_SolicitudCotizacion_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[SolicitudCotizacion] CHECK CONSTRAINT [FK_SolicitudCotizacion_UsuarioModificacion]
GO
ALTER TABLE [ORCO].[TipoContrato]  WITH CHECK ADD  CONSTRAINT [FK_TipoContrato_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[TipoContrato] CHECK CONSTRAINT [FK_TipoContrato_UsuarioCreacion]
GO
ALTER TABLE [ORCO].[TipoContrato]  WITH CHECK ADD  CONSTRAINT [FK_TipoContrato_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[TipoContrato] CHECK CONSTRAINT [FK_TipoContrato_UsuarioModificacion]
GO
ALTER TABLE [ORCO].[TipoDocumento]  WITH CHECK ADD  CONSTRAINT [FK_TipoDocumento_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[TipoDocumento] CHECK CONSTRAINT [FK_TipoDocumento_UsuarioCreacion]
GO
ALTER TABLE [ORCO].[TipoDocumento]  WITH CHECK ADD  CONSTRAINT [FK_TipoDocumento_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[TipoDocumento] CHECK CONSTRAINT [FK_TipoDocumento_UsuarioModificacion]
GO
ALTER TABLE [ORCO].[TipoGarantia]  WITH CHECK ADD  CONSTRAINT [FK_TipoGarantia_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[TipoGarantia] CHECK CONSTRAINT [FK_TipoGarantia_UsuarioCreacion]
GO
ALTER TABLE [ORCO].[TipoGarantia]  WITH CHECK ADD  CONSTRAINT [FK_TipoGarantia_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [ORCO].[TipoGarantia] CHECK CONSTRAINT [FK_TipoGarantia_UsuarioModificacion]
GO
ALTER TABLE [PRES].[AutorizacionSuficiencia]  WITH CHECK ADD  CONSTRAINT [FK_AutorizacionSuficiencia_AutorizadoPor] FOREIGN KEY([AutorizadoPor_NOM])
REFERENCES [NOM].[Persona] ([PKIdPersona])
GO
ALTER TABLE [PRES].[AutorizacionSuficiencia] CHECK CONSTRAINT [FK_AutorizacionSuficiencia_AutorizadoPor]
GO
ALTER TABLE [PRES].[AutorizacionSuficiencia]  WITH CHECK ADD  CONSTRAINT [FK_AutorizacionSuficiencia_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [PRES].[AutorizacionSuficiencia] CHECK CONSTRAINT [FK_AutorizacionSuficiencia_Empresa]
GO
ALTER TABLE [PRES].[AutorizacionSuficiencia]  WITH CHECK ADD  CONSTRAINT [FK_AutorizacionSuficiencia_Solicitud] FOREIGN KEY([FKIdSolicitudSuficiencia_PRES])
REFERENCES [PRES].[SolicitudSuficiencia] ([PKIdSolicitudSuficiencia])
GO
ALTER TABLE [PRES].[AutorizacionSuficiencia] CHECK CONSTRAINT [FK_AutorizacionSuficiencia_Solicitud]
GO
ALTER TABLE [PRES].[AutorizacionSuficiencia]  WITH CHECK ADD  CONSTRAINT [FK_AutorizacionSuficiencia_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[AutorizacionSuficiencia] CHECK CONSTRAINT [FK_AutorizacionSuficiencia_UsuarioCreacion]
GO
ALTER TABLE [PRES].[AutorizacionSuficiencia]  WITH CHECK ADD  CONSTRAINT [FK_AutorizacionSuficiencia_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[AutorizacionSuficiencia] CHECK CONSTRAINT [FK_AutorizacionSuficiencia_UsuarioModificacion]
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_AutorizacionSuficienciaDetalle_Autorizacion] FOREIGN KEY([FKIdAutorizacionSuficiencia_PRES])
REFERENCES [PRES].[AutorizacionSuficiencia] ([PKIdAutorizacionSuficiencia])
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle] CHECK CONSTRAINT [FK_AutorizacionSuficienciaDetalle_Autorizacion]
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_AutorizacionSuficienciaDetalle_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle] CHECK CONSTRAINT [FK_AutorizacionSuficienciaDetalle_Empresa]
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_AutorizacionSuficienciaDetalle_Partida] FOREIGN KEY([FKIdPartida_CONTA])
REFERENCES [CONTA].[Partida] ([PKIdPartida])
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle] CHECK CONSTRAINT [FK_AutorizacionSuficienciaDetalle_Partida]
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_AutorizacionSuficienciaDetalle_SolicitudDetalle] FOREIGN KEY([FKIdSolicitudSuficienciaDetalle_PRES])
REFERENCES [PRES].[SolicitudSuficienciaDetalle] ([PKIdSolicitudSuficienciaDetalle])
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle] CHECK CONSTRAINT [FK_AutorizacionSuficienciaDetalle_SolicitudDetalle]
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_AutorizacionSuficienciaDetalle_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle] CHECK CONSTRAINT [FK_AutorizacionSuficienciaDetalle_UsuarioCreacion]
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_AutorizacionSuficienciaDetalle_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle] CHECK CONSTRAINT [FK_AutorizacionSuficienciaDetalle_UsuarioModificacion]
GO
ALTER TABLE [PRES].[Cheque]  WITH CHECK ADD  CONSTRAINT [FK_Cheque_CLC] FOREIGN KEY([FKIdCLC_PRES])
REFERENCES [PRES].[CLC] ([PKIdCLC])
GO
ALTER TABLE [PRES].[Cheque] CHECK CONSTRAINT [FK_Cheque_CLC]
GO
ALTER TABLE [PRES].[Cheque]  WITH CHECK ADD  CONSTRAINT [FK_Cheque_CuentaBancaria] FOREIGN KEY([FKIdCuentaBancaria_TES])
REFERENCES [TES].[CuentaBancaria] ([PKIdCuentaBancaria])
GO
ALTER TABLE [PRES].[Cheque] CHECK CONSTRAINT [FK_Cheque_CuentaBancaria]
GO
ALTER TABLE [PRES].[Cheque]  WITH CHECK ADD  CONSTRAINT [FK_Cheque_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [PRES].[Cheque] CHECK CONSTRAINT [FK_Cheque_Empresa]
GO
ALTER TABLE [PRES].[Cheque]  WITH CHECK ADD  CONSTRAINT [FK_Cheque_Poliza] FOREIGN KEY([FKIdPoliza_CONTA])
REFERENCES [CONTA].[Poliza] ([PKIdPoliza])
GO
ALTER TABLE [PRES].[Cheque] CHECK CONSTRAINT [FK_Cheque_Poliza]
GO
ALTER TABLE [PRES].[Cheque]  WITH CHECK ADD  CONSTRAINT [FK_Cheque_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[Cheque] CHECK CONSTRAINT [FK_Cheque_UsuarioCreacion]
GO
ALTER TABLE [PRES].[Cheque]  WITH CHECK ADD  CONSTRAINT [FK_Cheque_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[Cheque] CHECK CONSTRAINT [FK_Cheque_UsuarioModificacion]
GO
ALTER TABLE [PRES].[ChequePartidas]  WITH CHECK ADD  CONSTRAINT [FK_ChequePartidas_Cheque] FOREIGN KEY([FKIdCheque_PRES])
REFERENCES [PRES].[Cheque] ([PKIdCheque])
GO
ALTER TABLE [PRES].[ChequePartidas] CHECK CONSTRAINT [FK_ChequePartidas_Cheque]
GO
ALTER TABLE [PRES].[ChequePartidas]  WITH CHECK ADD  CONSTRAINT [FK_ChequePartidas_CLCDetalle] FOREIGN KEY([FKIdCLCDetalle_PRES])
REFERENCES [PRES].[CLCDetalle] ([PKIdCLCDetalle])
GO
ALTER TABLE [PRES].[ChequePartidas] CHECK CONSTRAINT [FK_ChequePartidas_CLCDetalle]
GO
ALTER TABLE [PRES].[ChequePartidas]  WITH CHECK ADD  CONSTRAINT [FK_ChequePartidas_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [PRES].[ChequePartidas] CHECK CONSTRAINT [FK_ChequePartidas_Empresa]
GO
ALTER TABLE [PRES].[ChequePartidas]  WITH CHECK ADD  CONSTRAINT [FK_ChequePartidas_Partida] FOREIGN KEY([FKIdPartida_CONTA])
REFERENCES [CONTA].[Partida] ([PKIdPartida])
GO
ALTER TABLE [PRES].[ChequePartidas] CHECK CONSTRAINT [FK_ChequePartidas_Partida]
GO
ALTER TABLE [PRES].[ChequePartidas]  WITH CHECK ADD  CONSTRAINT [FK_ChequePartidas_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[ChequePartidas] CHECK CONSTRAINT [FK_ChequePartidas_UsuarioCreacion]
GO
ALTER TABLE [PRES].[ChequePartidas]  WITH CHECK ADD  CONSTRAINT [FK_ChequePartidas_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[ChequePartidas] CHECK CONSTRAINT [FK_ChequePartidas_UsuarioModificacion]
GO
ALTER TABLE [PRES].[CLC]  WITH CHECK ADD  CONSTRAINT [FK_CLC_Contrato] FOREIGN KEY([FKIdContrato_PRES])
REFERENCES [PRES].[Contrato] ([PKIdContrato])
GO
ALTER TABLE [PRES].[CLC] CHECK CONSTRAINT [FK_CLC_Contrato]
GO
ALTER TABLE [PRES].[CLC]  WITH CHECK ADD  CONSTRAINT [FK_CLC_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [PRES].[CLC] CHECK CONSTRAINT [FK_CLC_Empresa]
GO
ALTER TABLE [PRES].[CLC]  WITH CHECK ADD  CONSTRAINT [FK_CLC_Poliza] FOREIGN KEY([FKIdPoliza_CONTA])
REFERENCES [CONTA].[Poliza] ([PKIdPoliza])
GO
ALTER TABLE [PRES].[CLC] CHECK CONSTRAINT [FK_CLC_Poliza]
GO
ALTER TABLE [PRES].[CLC]  WITH CHECK ADD  CONSTRAINT [FK_CLC_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[CLC] CHECK CONSTRAINT [FK_CLC_UsuarioCreacion]
GO
ALTER TABLE [PRES].[CLC]  WITH CHECK ADD  CONSTRAINT [FK_CLC_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[CLC] CHECK CONSTRAINT [FK_CLC_UsuarioModificacion]
GO
ALTER TABLE [PRES].[CLCDetalle]  WITH CHECK ADD  CONSTRAINT [FK_CLCDetalle_CLC] FOREIGN KEY([FKIdCLC_PRES])
REFERENCES [PRES].[CLC] ([PKIdCLC])
GO
ALTER TABLE [PRES].[CLCDetalle] CHECK CONSTRAINT [FK_CLCDetalle_CLC]
GO
ALTER TABLE [PRES].[CLCDetalle]  WITH CHECK ADD  CONSTRAINT [FK_CLCDetalle_ContratoDetalle] FOREIGN KEY([FKIdContratoDetalle_PRES])
REFERENCES [PRES].[ContratoDetalle] ([PKIdContratoDetalle])
GO
ALTER TABLE [PRES].[CLCDetalle] CHECK CONSTRAINT [FK_CLCDetalle_ContratoDetalle]
GO
ALTER TABLE [PRES].[CLCDetalle]  WITH CHECK ADD  CONSTRAINT [FK_CLCDetalle_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [PRES].[CLCDetalle] CHECK CONSTRAINT [FK_CLCDetalle_Empresa]
GO
ALTER TABLE [PRES].[CLCDetalle]  WITH CHECK ADD  CONSTRAINT [FK_CLCDetalle_Partida] FOREIGN KEY([FKIdPartida_CONTA])
REFERENCES [CONTA].[Partida] ([PKIdPartida])
GO
ALTER TABLE [PRES].[CLCDetalle] CHECK CONSTRAINT [FK_CLCDetalle_Partida]
GO
ALTER TABLE [PRES].[CLCDetalle]  WITH CHECK ADD  CONSTRAINT [FK_CLCDetalle_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[CLCDetalle] CHECK CONSTRAINT [FK_CLCDetalle_UsuarioCreacion]
GO
ALTER TABLE [PRES].[CLCDetalle]  WITH CHECK ADD  CONSTRAINT [FK_CLCDetalle_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[CLCDetalle] CHECK CONSTRAINT [FK_CLCDetalle_UsuarioModificacion]
GO
ALTER TABLE [PRES].[CLCFactura]  WITH CHECK ADD  CONSTRAINT [FK_CLCFactura_CLC] FOREIGN KEY([FKIdCLC_PRES])
REFERENCES [PRES].[CLC] ([PKIdCLC])
GO
ALTER TABLE [PRES].[CLCFactura] CHECK CONSTRAINT [FK_CLCFactura_CLC]
GO
ALTER TABLE [PRES].[CLCFactura]  WITH CHECK ADD  CONSTRAINT [FK_CLCFactura_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [PRES].[CLCFactura] CHECK CONSTRAINT [FK_CLCFactura_Empresa]
GO
ALTER TABLE [PRES].[CLCFactura]  WITH CHECK ADD  CONSTRAINT [FK_CLCFactura_Factura] FOREIGN KEY([FKIdFactura_PRES])
REFERENCES [PRES].[Factura] ([PKIdFactura])
GO
ALTER TABLE [PRES].[CLCFactura] CHECK CONSTRAINT [FK_CLCFactura_Factura]
GO
ALTER TABLE [PRES].[CLCFactura]  WITH CHECK ADD  CONSTRAINT [FK_CLCFactura_FacturaDetalle] FOREIGN KEY([FKIdFacturaDetalle_PRES])
REFERENCES [PRES].[FacturaDetalle] ([PKIdFacturaDetalle])
GO
ALTER TABLE [PRES].[CLCFactura] CHECK CONSTRAINT [FK_CLCFactura_FacturaDetalle]
GO
ALTER TABLE [PRES].[CLCFactura]  WITH CHECK ADD  CONSTRAINT [FK_CLCFactura_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[CLCFactura] CHECK CONSTRAINT [FK_CLCFactura_UsuarioCreacion]
GO
ALTER TABLE [PRES].[CLCFactura]  WITH CHECK ADD  CONSTRAINT [FK_CLCFactura_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[CLCFactura] CHECK CONSTRAINT [FK_CLCFactura_UsuarioModificacion]
GO
ALTER TABLE [PRES].[Contrato]  WITH CHECK ADD  CONSTRAINT [FK_Contrato_AutorizacionSuficiencia] FOREIGN KEY([FKIdAutorizacionSuficiencia_PRES])
REFERENCES [PRES].[AutorizacionSuficiencia] ([PKIdAutorizacionSuficiencia])
GO
ALTER TABLE [PRES].[Contrato] CHECK CONSTRAINT [FK_Contrato_AutorizacionSuficiencia]
GO
ALTER TABLE [PRES].[Contrato]  WITH CHECK ADD  CONSTRAINT [FK_Contrato_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [PRES].[Contrato] CHECK CONSTRAINT [FK_Contrato_Empresa]
GO
ALTER TABLE [PRES].[Contrato]  WITH CHECK ADD  CONSTRAINT [FK_Contrato_Poliza] FOREIGN KEY([FKIdPoliza_CONTA])
REFERENCES [CONTA].[Poliza] ([PKIdPoliza])
GO
ALTER TABLE [PRES].[Contrato] CHECK CONSTRAINT [FK_Contrato_Poliza]
GO
ALTER TABLE [PRES].[Contrato]  WITH CHECK ADD  CONSTRAINT [FK_Contrato_Proveedor] FOREIGN KEY([FKIdProveedor_SIS])
REFERENCES [SIS].[Proveedor] ([PKIdProveedor])
GO
ALTER TABLE [PRES].[Contrato] CHECK CONSTRAINT [FK_Contrato_Proveedor]
GO
ALTER TABLE [PRES].[Contrato]  WITH CHECK ADD  CONSTRAINT [FK_Contrato_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[Contrato] CHECK CONSTRAINT [FK_Contrato_UsuarioCreacion]
GO
ALTER TABLE [PRES].[Contrato]  WITH CHECK ADD  CONSTRAINT [FK_Contrato_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[Contrato] CHECK CONSTRAINT [FK_Contrato_UsuarioModificacion]
GO
ALTER TABLE [PRES].[ContratoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_ContratoDetalle_AutorizacionDetalle] FOREIGN KEY([FKIdAutorizacionSuficienciaDetalle_PRES])
REFERENCES [PRES].[AutorizacionSuficienciaDetalle] ([PKIdAutorizacionSuficienciaDetalle])
GO
ALTER TABLE [PRES].[ContratoDetalle] CHECK CONSTRAINT [FK_ContratoDetalle_AutorizacionDetalle]
GO
ALTER TABLE [PRES].[ContratoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_ContratoDetalle_Contrato] FOREIGN KEY([FKIdContrato_PRES])
REFERENCES [PRES].[Contrato] ([PKIdContrato])
GO
ALTER TABLE [PRES].[ContratoDetalle] CHECK CONSTRAINT [FK_ContratoDetalle_Contrato]
GO
ALTER TABLE [PRES].[ContratoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_ContratoDetalle_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [PRES].[ContratoDetalle] CHECK CONSTRAINT [FK_ContratoDetalle_Empresa]
GO
ALTER TABLE [PRES].[ContratoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_ContratoDetalle_Partida] FOREIGN KEY([FKIdPartida_CONTA])
REFERENCES [CONTA].[Partida] ([PKIdPartida])
GO
ALTER TABLE [PRES].[ContratoDetalle] CHECK CONSTRAINT [FK_ContratoDetalle_Partida]
GO
ALTER TABLE [PRES].[ContratoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_ContratoDetalle_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[ContratoDetalle] CHECK CONSTRAINT [FK_ContratoDetalle_UsuarioCreacion]
GO
ALTER TABLE [PRES].[ContratoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_ContratoDetalle_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[ContratoDetalle] CHECK CONSTRAINT [FK_ContratoDetalle_UsuarioModificacion]
GO
ALTER TABLE [PRES].[DestinoGasto]  WITH CHECK ADD  CONSTRAINT [FK_DestinoGasto_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[DestinoGasto] CHECK CONSTRAINT [FK_DestinoGasto_UsuarioCreacion]
GO
ALTER TABLE [PRES].[DestinoGasto]  WITH CHECK ADD  CONSTRAINT [FK_DestinoGasto_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[DestinoGasto] CHECK CONSTRAINT [FK_DestinoGasto_UsuarioModificacion]
GO
ALTER TABLE [PRES].[DigitoIdentificador]  WITH CHECK ADD  CONSTRAINT [FK_DigitoIdentificador_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[DigitoIdentificador] CHECK CONSTRAINT [FK_DigitoIdentificador_UsuarioCreacion]
GO
ALTER TABLE [PRES].[DigitoIdentificador]  WITH CHECK ADD  CONSTRAINT [FK_DigitoIdentificador_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[DigitoIdentificador] CHECK CONSTRAINT [FK_DigitoIdentificador_UsuarioModificacion]
GO
ALTER TABLE [PRES].[EgresoAutorizado]  WITH CHECK ADD  CONSTRAINT [FK_EgresoAutorizado_Area] FOREIGN KEY([FKIdArea_SIS])
REFERENCES [SIS].[Area] ([PKIdArea])
GO
ALTER TABLE [PRES].[EgresoAutorizado] CHECK CONSTRAINT [FK_EgresoAutorizado_Area]
GO
ALTER TABLE [PRES].[EgresoAutorizado]  WITH NOCHECK ADD  CONSTRAINT [FK_EgresoAutorizado_DestinoGasto] FOREIGN KEY([FKIdDestinoGasto_PRES])
REFERENCES [PRES].[DestinoGasto] ([PKIdDestinoGasto])
GO
ALTER TABLE [PRES].[EgresoAutorizado] CHECK CONSTRAINT [FK_EgresoAutorizado_DestinoGasto]
GO
ALTER TABLE [PRES].[EgresoAutorizado]  WITH NOCHECK ADD  CONSTRAINT [FK_EgresoAutorizado_DigitoIdentificador] FOREIGN KEY([FKIdDigitoIdentificador_PRES])
REFERENCES [PRES].[DigitoIdentificador] ([PKIdDigitoIdentificador])
GO
ALTER TABLE [PRES].[EgresoAutorizado] CHECK CONSTRAINT [FK_EgresoAutorizado_DigitoIdentificador]
GO
ALTER TABLE [PRES].[EgresoAutorizado]  WITH CHECK ADD  CONSTRAINT [FK_EgresoAutorizado_EgresoProyectado] FOREIGN KEY([FKIdEgresoProyectado_PRES])
REFERENCES [PRES].[EgresoProyectado] ([PKIdEgresoProyectado])
GO
ALTER TABLE [PRES].[EgresoAutorizado] CHECK CONSTRAINT [FK_EgresoAutorizado_EgresoProyectado]
GO
ALTER TABLE [PRES].[EgresoAutorizado]  WITH NOCHECK ADD  CONSTRAINT [FK_EgresoAutorizado_FuenteFinanciamiento] FOREIGN KEY([FKIdFuenteFinanciamiento_PRES])
REFERENCES [PRES].[FuenteFinanciamiento] ([PKIdFuenteFinanciamiento])
GO
ALTER TABLE [PRES].[EgresoAutorizado] CHECK CONSTRAINT [FK_EgresoAutorizado_FuenteFinanciamiento]
GO
ALTER TABLE [PRES].[EgresoAutorizado]  WITH CHECK ADD  CONSTRAINT [FK_EgresoAutorizado_Partida] FOREIGN KEY([FKIdPartida_CONTA])
REFERENCES [CONTA].[Partida] ([PKIdPartida])
GO
ALTER TABLE [PRES].[EgresoAutorizado] CHECK CONSTRAINT [FK_EgresoAutorizado_Partida]
GO
ALTER TABLE [PRES].[EgresoAutorizado]  WITH CHECK ADD  CONSTRAINT [FK_EgresoAutorizado_Poliza] FOREIGN KEY([FKIdPoliza_CONTA])
REFERENCES [CONTA].[Poliza] ([PKIdPoliza])
GO
ALTER TABLE [PRES].[EgresoAutorizado] CHECK CONSTRAINT [FK_EgresoAutorizado_Poliza]
GO
ALTER TABLE [PRES].[EgresoAutorizado]  WITH CHECK ADD  CONSTRAINT [FK_EgresoAutorizado_Programa] FOREIGN KEY([FKIdPrograma_PRES])
REFERENCES [PRES].[Programa] ([PKIdPrograma])
GO
ALTER TABLE [PRES].[EgresoAutorizado] CHECK CONSTRAINT [FK_EgresoAutorizado_Programa]
GO
ALTER TABLE [PRES].[EgresoAutorizado]  WITH NOCHECK ADD  CONSTRAINT [FK_EgresoAutorizado_PY] FOREIGN KEY([FKIdPY_PRES])
REFERENCES [PRES].[PY] ([PKIdPY])
GO
ALTER TABLE [PRES].[EgresoAutorizado] CHECK CONSTRAINT [FK_EgresoAutorizado_PY]
GO
ALTER TABLE [PRES].[EgresoAutorizado]  WITH NOCHECK ADD  CONSTRAINT [FK_EgresoAutorizado_TipoGasto] FOREIGN KEY([FKIdTipoGasto_PRES])
REFERENCES [PRES].[TipoGasto] ([PKIdTipoGasto])
GO
ALTER TABLE [PRES].[EgresoAutorizado] CHECK CONSTRAINT [FK_EgresoAutorizado_TipoGasto]
GO
ALTER TABLE [PRES].[EgresoAutorizado]  WITH CHECK ADD  CONSTRAINT [FK_EgresoAutorizado_UsuarioAutorizacion] FOREIGN KEY([UsuarioAutorizacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[EgresoAutorizado] CHECK CONSTRAINT [FK_EgresoAutorizado_UsuarioAutorizacion]
GO
ALTER TABLE [PRES].[EgresoAutorizado]  WITH CHECK ADD  CONSTRAINT [FK_EgresoAutorizado_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[EgresoAutorizado] CHECK CONSTRAINT [FK_EgresoAutorizado_UsuarioCreacion]
GO
ALTER TABLE [PRES].[EgresoAutorizado]  WITH CHECK ADD  CONSTRAINT [FK_EgresoAutorizado_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[EgresoAutorizado] CHECK CONSTRAINT [FK_EgresoAutorizado_UsuarioModificacion]
GO
ALTER TABLE [PRES].[EgresoProyectado]  WITH CHECK ADD  CONSTRAINT [FK_EgresoProyectado_Area] FOREIGN KEY([FKIdArea_SIS])
REFERENCES [SIS].[Area] ([PKIdArea])
GO
ALTER TABLE [PRES].[EgresoProyectado] CHECK CONSTRAINT [FK_EgresoProyectado_Area]
GO
ALTER TABLE [PRES].[EgresoProyectado]  WITH NOCHECK ADD  CONSTRAINT [FK_EgresoProyectado_DestinoGasto] FOREIGN KEY([FKIdDestinoGasto_PRES])
REFERENCES [PRES].[DestinoGasto] ([PKIdDestinoGasto])
GO
ALTER TABLE [PRES].[EgresoProyectado] CHECK CONSTRAINT [FK_EgresoProyectado_DestinoGasto]
GO
ALTER TABLE [PRES].[EgresoProyectado]  WITH NOCHECK ADD  CONSTRAINT [FK_EgresoProyectado_DigitoIdentificador] FOREIGN KEY([FKIdDigitoIdentificador_PRES])
REFERENCES [PRES].[DigitoIdentificador] ([PKIdDigitoIdentificador])
GO
ALTER TABLE [PRES].[EgresoProyectado] CHECK CONSTRAINT [FK_EgresoProyectado_DigitoIdentificador]
GO
ALTER TABLE [PRES].[EgresoProyectado]  WITH NOCHECK ADD  CONSTRAINT [FK_EgresoProyectado_FuenteFinanciamiento] FOREIGN KEY([FKIdFuenteFinanciamiento_PRES])
REFERENCES [PRES].[FuenteFinanciamiento] ([PKIdFuenteFinanciamiento])
GO
ALTER TABLE [PRES].[EgresoProyectado] CHECK CONSTRAINT [FK_EgresoProyectado_FuenteFinanciamiento]
GO
ALTER TABLE [PRES].[EgresoProyectado]  WITH CHECK ADD  CONSTRAINT [FK_EgresoProyectado_Partida] FOREIGN KEY([FKIdPartida_CONTA])
REFERENCES [CONTA].[Partida] ([PKIdPartida])
GO
ALTER TABLE [PRES].[EgresoProyectado] CHECK CONSTRAINT [FK_EgresoProyectado_Partida]
GO
ALTER TABLE [PRES].[EgresoProyectado]  WITH CHECK ADD  CONSTRAINT [FK_EgresoProyectado_Programa] FOREIGN KEY([FKIdPrograma_PRES])
REFERENCES [PRES].[Programa] ([PKIdPrograma])
GO
ALTER TABLE [PRES].[EgresoProyectado] CHECK CONSTRAINT [FK_EgresoProyectado_Programa]
GO
ALTER TABLE [PRES].[EgresoProyectado]  WITH NOCHECK ADD  CONSTRAINT [FK_EgresoProyectado_PY] FOREIGN KEY([FKIdPY_PRES])
REFERENCES [PRES].[PY] ([PKIdPY])
GO
ALTER TABLE [PRES].[EgresoProyectado] CHECK CONSTRAINT [FK_EgresoProyectado_PY]
GO
ALTER TABLE [PRES].[EgresoProyectado]  WITH NOCHECK ADD  CONSTRAINT [FK_EgresoProyectado_TipoGasto] FOREIGN KEY([FKIdTipoGasto_PRES])
REFERENCES [PRES].[TipoGasto] ([PKIdTipoGasto])
GO
ALTER TABLE [PRES].[EgresoProyectado] CHECK CONSTRAINT [FK_EgresoProyectado_TipoGasto]
GO
ALTER TABLE [PRES].[EgresoProyectado]  WITH CHECK ADD  CONSTRAINT [FK_EgresoProyectado_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[EgresoProyectado] CHECK CONSTRAINT [FK_EgresoProyectado_UsuarioCreacion]
GO
ALTER TABLE [PRES].[EgresoProyectado]  WITH CHECK ADD  CONSTRAINT [FK_EgresoProyectado_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[EgresoProyectado] CHECK CONSTRAINT [FK_EgresoProyectado_UsuarioModificacion]
GO
ALTER TABLE [PRES].[Factura]  WITH CHECK ADD  CONSTRAINT [FK_Factura_Contrato] FOREIGN KEY([FKIdContrato_PRES])
REFERENCES [PRES].[Contrato] ([PKIdContrato])
GO
ALTER TABLE [PRES].[Factura] CHECK CONSTRAINT [FK_Factura_Contrato]
GO
ALTER TABLE [PRES].[Factura]  WITH CHECK ADD  CONSTRAINT [FK_Factura_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [PRES].[Factura] CHECK CONSTRAINT [FK_Factura_Empresa]
GO
ALTER TABLE [PRES].[Factura]  WITH CHECK ADD  CONSTRAINT [FK_Factura_Poliza] FOREIGN KEY([FKIdPoliza_CONTA])
REFERENCES [CONTA].[Poliza] ([PKIdPoliza])
GO
ALTER TABLE [PRES].[Factura] CHECK CONSTRAINT [FK_Factura_Poliza]
GO
ALTER TABLE [PRES].[Factura]  WITH CHECK ADD  CONSTRAINT [FK_Factura_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[Factura] CHECK CONSTRAINT [FK_Factura_UsuarioCreacion]
GO
ALTER TABLE [PRES].[Factura]  WITH CHECK ADD  CONSTRAINT [FK_Factura_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[Factura] CHECK CONSTRAINT [FK_Factura_UsuarioModificacion]
GO
ALTER TABLE [PRES].[FacturaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_FacturaDetalle_ContratoDetalle] FOREIGN KEY([FKIdContratoDetalle_PRES])
REFERENCES [PRES].[ContratoDetalle] ([PKIdContratoDetalle])
GO
ALTER TABLE [PRES].[FacturaDetalle] CHECK CONSTRAINT [FK_FacturaDetalle_ContratoDetalle]
GO
ALTER TABLE [PRES].[FacturaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_FacturaDetalle_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [PRES].[FacturaDetalle] CHECK CONSTRAINT [FK_FacturaDetalle_Empresa]
GO
ALTER TABLE [PRES].[FacturaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_FacturaDetalle_Factura] FOREIGN KEY([FKIdFactura_PRES])
REFERENCES [PRES].[Factura] ([PKIdFactura])
GO
ALTER TABLE [PRES].[FacturaDetalle] CHECK CONSTRAINT [FK_FacturaDetalle_Factura]
GO
ALTER TABLE [PRES].[FacturaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_FacturaDetalle_Partida] FOREIGN KEY([FKIdPartida_CONTA])
REFERENCES [CONTA].[Partida] ([PKIdPartida])
GO
ALTER TABLE [PRES].[FacturaDetalle] CHECK CONSTRAINT [FK_FacturaDetalle_Partida]
GO
ALTER TABLE [PRES].[FacturaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_FacturaDetalle_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[FacturaDetalle] CHECK CONSTRAINT [FK_FacturaDetalle_UsuarioCreacion]
GO
ALTER TABLE [PRES].[FacturaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_FacturaDetalle_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[FacturaDetalle] CHECK CONSTRAINT [FK_FacturaDetalle_UsuarioModificacion]
GO
ALTER TABLE [PRES].[FN]  WITH CHECK ADD  CONSTRAINT [FK_FN_GF] FOREIGN KEY([FKIdGF_PRES])
REFERENCES [PRES].[GF] ([PKIdGF])
GO
ALTER TABLE [PRES].[FN] CHECK CONSTRAINT [FK_FN_GF]
GO
ALTER TABLE [PRES].[FN]  WITH CHECK ADD  CONSTRAINT [FK_FN_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[FN] CHECK CONSTRAINT [FK_FN_UsuarioCreacion]
GO
ALTER TABLE [PRES].[FN]  WITH CHECK ADD  CONSTRAINT [FK_FN_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[FN] CHECK CONSTRAINT [FK_FN_UsuarioModificacion]
GO
ALTER TABLE [PRES].[FuenteFinanciamiento]  WITH CHECK ADD  CONSTRAINT [FK_FuenteFinanciamiento_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[FuenteFinanciamiento] CHECK CONSTRAINT [FK_FuenteFinanciamiento_UsuarioCreacion]
GO
ALTER TABLE [PRES].[FuenteFinanciamiento]  WITH CHECK ADD  CONSTRAINT [FK_FuenteFinanciamiento_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[FuenteFinanciamiento] CHECK CONSTRAINT [FK_FuenteFinanciamiento_UsuarioModificacion]
GO
ALTER TABLE [PRES].[GF]  WITH CHECK ADD  CONSTRAINT [FK_GF_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[GF] CHECK CONSTRAINT [FK_GF_UsuarioCreacion]
GO
ALTER TABLE [PRES].[GF]  WITH CHECK ADD  CONSTRAINT [FK_GF_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[GF] CHECK CONSTRAINT [FK_GF_UsuarioModificacion]
GO
ALTER TABLE [PRES].[Origen]  WITH CHECK ADD  CONSTRAINT [FK_Origen_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[Origen] CHECK CONSTRAINT [FK_Origen_UsuarioCreacion]
GO
ALTER TABLE [PRES].[Origen]  WITH CHECK ADD  CONSTRAINT [FK_Origen_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[Origen] CHECK CONSTRAINT [FK_Origen_UsuarioModificacion]
GO
ALTER TABLE [PRES].[PG]  WITH CHECK ADD  CONSTRAINT [FK_PG_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[PG] CHECK CONSTRAINT [FK_PG_UsuarioCreacion]
GO
ALTER TABLE [PRES].[PG]  WITH CHECK ADD  CONSTRAINT [FK_PG_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[PG] CHECK CONSTRAINT [FK_PG_UsuarioModificacion]
GO
ALTER TABLE [PRES].[PP]  WITH CHECK ADD  CONSTRAINT [FK_PP_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[PP] CHECK CONSTRAINT [FK_PP_UsuarioCreacion]
GO
ALTER TABLE [PRES].[PP]  WITH CHECK ADD  CONSTRAINT [FK_PP_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[PP] CHECK CONSTRAINT [FK_PP_UsuarioModificacion]
GO
ALTER TABLE [PRES].[Programa]  WITH CHECK ADD  CONSTRAINT [FK_Programa_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[Programa] CHECK CONSTRAINT [FK_Programa_UsuarioCreacion]
GO
ALTER TABLE [PRES].[Programa]  WITH CHECK ADD  CONSTRAINT [FK_Programa_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[Programa] CHECK CONSTRAINT [FK_Programa_UsuarioModificacion]
GO
ALTER TABLE [PRES].[PY]  WITH CHECK ADD  CONSTRAINT [FK_PY_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[PY] CHECK CONSTRAINT [FK_PY_UsuarioCreacion]
GO
ALTER TABLE [PRES].[PY]  WITH CHECK ADD  CONSTRAINT [FK_PY_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[PY] CHECK CONSTRAINT [FK_PY_UsuarioModificacion]
GO
ALTER TABLE [PRES].[Ramo]  WITH CHECK ADD  CONSTRAINT [FK_Ramo_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[Ramo] CHECK CONSTRAINT [FK_Ramo_UsuarioCreacion]
GO
ALTER TABLE [PRES].[Ramo]  WITH CHECK ADD  CONSTRAINT [FK_Ramo_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[Ramo] CHECK CONSTRAINT [FK_Ramo_UsuarioModificacion]
GO
ALTER TABLE [PRES].[Sector]  WITH CHECK ADD  CONSTRAINT [FK_Sector_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[Sector] CHECK CONSTRAINT [FK_Sector_UsuarioCreacion]
GO
ALTER TABLE [PRES].[Sector]  WITH CHECK ADD  CONSTRAINT [FK_Sector_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[Sector] CHECK CONSTRAINT [FK_Sector_UsuarioModificacion]
GO
ALTER TABLE [PRES].[SF]  WITH CHECK ADD  CONSTRAINT [FK_SF_FN] FOREIGN KEY([FKIdFN_PRES])
REFERENCES [PRES].[FN] ([PKIdFN])
GO
ALTER TABLE [PRES].[SF] CHECK CONSTRAINT [FK_SF_FN]
GO
ALTER TABLE [PRES].[SF]  WITH CHECK ADD  CONSTRAINT [FK_SF_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[SF] CHECK CONSTRAINT [FK_SF_UsuarioCreacion]
GO
ALTER TABLE [PRES].[SF]  WITH CHECK ADD  CONSTRAINT [FK_SF_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[SF] CHECK CONSTRAINT [FK_SF_UsuarioModificacion]
GO
ALTER TABLE [PRES].[SolicitudSuficiencia]  WITH CHECK ADD  CONSTRAINT [FK_SolicitudSuficiencia_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [PRES].[SolicitudSuficiencia] CHECK CONSTRAINT [FK_SolicitudSuficiencia_Empresa]
GO
ALTER TABLE [PRES].[SolicitudSuficiencia]  WITH CHECK ADD  CONSTRAINT [FK_SolicitudSuficiencia_Requisicion] FOREIGN KEY([FKIdRequisicion_ORCO])
REFERENCES [ORCO].[Requisicion] ([PKIdRequisicion])
GO
ALTER TABLE [PRES].[SolicitudSuficiencia] CHECK CONSTRAINT [FK_SolicitudSuficiencia_Requisicion]
GO
ALTER TABLE [PRES].[SolicitudSuficiencia]  WITH CHECK ADD  CONSTRAINT [FK_SolicitudSuficiencia_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[SolicitudSuficiencia] CHECK CONSTRAINT [FK_SolicitudSuficiencia_UsuarioCreacion]
GO
ALTER TABLE [PRES].[SolicitudSuficiencia]  WITH CHECK ADD  CONSTRAINT [FK_SolicitudSuficiencia_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[SolicitudSuficiencia] CHECK CONSTRAINT [FK_SolicitudSuficiencia_UsuarioModificacion]
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_SolicitudSuficienciaDetalle_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle] CHECK CONSTRAINT [FK_SolicitudSuficienciaDetalle_Empresa]
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_SolicitudSuficienciaDetalle_Partida] FOREIGN KEY([FKIdPartida_CONTA])
REFERENCES [CONTA].[Partida] ([PKIdPartida])
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle] CHECK CONSTRAINT [FK_SolicitudSuficienciaDetalle_Partida]
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_SolicitudSuficienciaDetalle_RequisicionDetalle] FOREIGN KEY([FKIdRequisicionDetalle_ORCO])
REFERENCES [ORCO].[RequisicionDetalle] ([PKIdRequisicionDetalle])
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle] CHECK CONSTRAINT [FK_SolicitudSuficienciaDetalle_RequisicionDetalle]
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_SolicitudSuficienciaDetalle_Solicitud] FOREIGN KEY([FKIdSolicitudSuficiencia_PRES])
REFERENCES [PRES].[SolicitudSuficiencia] ([PKIdSolicitudSuficiencia])
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle] CHECK CONSTRAINT [FK_SolicitudSuficienciaDetalle_Solicitud]
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_SolicitudSuficienciaDetalle_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle] CHECK CONSTRAINT [FK_SolicitudSuficienciaDetalle_UsuarioCreacion]
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_SolicitudSuficienciaDetalle_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle] CHECK CONSTRAINT [FK_SolicitudSuficienciaDetalle_UsuarioModificacion]
GO
ALTER TABLE [PRES].[Suficiencia]  WITH CHECK ADD  CONSTRAINT [FK_Suficiencia_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[Suficiencia] CHECK CONSTRAINT [FK_Suficiencia_UsuarioCreacion]
GO
ALTER TABLE [PRES].[Suficiencia]  WITH CHECK ADD  CONSTRAINT [FK_Suficiencia_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[Suficiencia] CHECK CONSTRAINT [FK_Suficiencia_UsuarioModificacion]
GO
ALTER TABLE [PRES].[TipoGasto]  WITH CHECK ADD  CONSTRAINT [FK_TipoGasto_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[TipoGasto] CHECK CONSTRAINT [FK_TipoGasto_UsuarioCreacion]
GO
ALTER TABLE [PRES].[TipoGasto]  WITH CHECK ADD  CONSTRAINT [FK_TipoGasto_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[TipoGasto] CHECK CONSTRAINT [FK_TipoGasto_UsuarioModificacion]
GO
ALTER TABLE [PRES].[TipoRecurso]  WITH CHECK ADD  CONSTRAINT [FK_TipoRecurso_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[TipoRecurso] CHECK CONSTRAINT [FK_TipoRecurso_UsuarioCreacion]
GO
ALTER TABLE [PRES].[TipoRecurso]  WITH CHECK ADD  CONSTRAINT [FK_TipoRecurso_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [PRES].[TipoRecurso] CHECK CONSTRAINT [FK_TipoRecurso_UsuarioModificacion]
GO
ALTER TABLE [SIS].[ActividadInstitucional]  WITH CHECK ADD  CONSTRAINT [FK_ActividadInstitucional_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[ActividadInstitucional] CHECK CONSTRAINT [FK_ActividadInstitucional_UsuarioCreacion]
GO
ALTER TABLE [SIS].[ActividadInstitucional]  WITH CHECK ADD  CONSTRAINT [FK_ActividadInstitucional_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[ActividadInstitucional] CHECK CONSTRAINT [FK_ActividadInstitucional_UsuarioModificacion]
GO
ALTER TABLE [SIS].[Anio]  WITH CHECK ADD  CONSTRAINT [FK_Anio_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[Anio] CHECK CONSTRAINT [FK_Anio_UsuarioCreacion]
GO
ALTER TABLE [SIS].[Anio]  WITH CHECK ADD  CONSTRAINT [FK_Anio_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[Anio] CHECK CONSTRAINT [FK_Anio_UsuarioModificacion]
GO
ALTER TABLE [SIS].[Area]  WITH CHECK ADD  CONSTRAINT [FK_Area_Padre] FOREIGN KEY([FKIdArea_SIS])
REFERENCES [SIS].[Area] ([PKIdArea])
GO
ALTER TABLE [SIS].[Area] CHECK CONSTRAINT [FK_Area_Padre]
GO
ALTER TABLE [SIS].[Area]  WITH CHECK ADD  CONSTRAINT [FK_Area_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[Area] CHECK CONSTRAINT [FK_Area_UsuarioCreacion]
GO
ALTER TABLE [SIS].[Area]  WITH CHECK ADD  CONSTRAINT [FK_Area_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[Area] CHECK CONSTRAINT [FK_Area_UsuarioModificacion]
GO
ALTER TABLE [SIS].[Capitulo]  WITH CHECK ADD  CONSTRAINT [FK_Capitulo_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[Capitulo] CHECK CONSTRAINT [FK_Capitulo_UsuarioCreacion]
GO
ALTER TABLE [SIS].[Capitulo]  WITH CHECK ADD  CONSTRAINT [FK_Capitulo_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[Capitulo] CHECK CONSTRAINT [FK_Capitulo_UsuarioModificacion]
GO
ALTER TABLE [SIS].[Concepto]  WITH CHECK ADD  CONSTRAINT [FK_Concepto_Capitulo] FOREIGN KEY([FKIdCapitulo_SIS])
REFERENCES [SIS].[Capitulo] ([PKIdCapitulo])
GO
ALTER TABLE [SIS].[Concepto] CHECK CONSTRAINT [FK_Concepto_Capitulo]
GO
ALTER TABLE [SIS].[Concepto]  WITH CHECK ADD  CONSTRAINT [FK_Concepto_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[Concepto] CHECK CONSTRAINT [FK_Concepto_UsuarioCreacion]
GO
ALTER TABLE [SIS].[Concepto]  WITH CHECK ADD  CONSTRAINT [FK_Concepto_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[Concepto] CHECK CONSTRAINT [FK_Concepto_UsuarioModificacion]
GO
ALTER TABLE [SIS].[Departamento]  WITH CHECK ADD  CONSTRAINT [FK_Departamento_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [SIS].[Departamento] CHECK CONSTRAINT [FK_Departamento_Empresa]
GO
ALTER TABLE [SIS].[Departamento]  WITH CHECK ADD  CONSTRAINT [FK_Departamento_Sucursal] FOREIGN KEY([FKIdSucursal_SIS])
REFERENCES [SIS].[Sucursal] ([PKIdSucursal])
GO
ALTER TABLE [SIS].[Departamento] CHECK CONSTRAINT [FK_Departamento_Sucursal]
GO
ALTER TABLE [SIS].[Departamento]  WITH CHECK ADD  CONSTRAINT [FK_Departamento_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[Departamento] CHECK CONSTRAINT [FK_Departamento_UsuarioCreacion]
GO
ALTER TABLE [SIS].[Departamento]  WITH CHECK ADD  CONSTRAINT [FK_Departamento_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[Departamento] CHECK CONSTRAINT [FK_Departamento_UsuarioModificacion]
GO
ALTER TABLE [SIS].[Empresa]  WITH CHECK ADD  CONSTRAINT [FK_Empresa_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[Empresa] CHECK CONSTRAINT [FK_Empresa_UsuarioCreacion]
GO
ALTER TABLE [SIS].[Empresa]  WITH CHECK ADD  CONSTRAINT [FK_Empresa_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[Empresa] CHECK CONSTRAINT [FK_Empresa_UsuarioModificacion]
GO
ALTER TABLE [SIS].[EmpresaEstado]  WITH CHECK ADD  CONSTRAINT [FK_EmpresaEstado_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [SIS].[EmpresaEstado] CHECK CONSTRAINT [FK_EmpresaEstado_Empresa]
GO
ALTER TABLE [SIS].[EmpresaEstado]  WITH CHECK ADD  CONSTRAINT [FK_EmpresaEstado_Estado] FOREIGN KEY([FKIdEstado_SIS])
REFERENCES [SIS].[Estados] ([PKIdEstado])
GO
ALTER TABLE [SIS].[EmpresaEstado] CHECK CONSTRAINT [FK_EmpresaEstado_Estado]
GO
ALTER TABLE [SIS].[Estados]  WITH CHECK ADD  CONSTRAINT [FK_Estados_Paises] FOREIGN KEY([FKIdPais_SIS])
REFERENCES [SIS].[Paises] ([PKIdPais])
GO
ALTER TABLE [SIS].[Estados] CHECK CONSTRAINT [FK_Estados_Paises]
GO
ALTER TABLE [SIS].[EstatusProveedor]  WITH CHECK ADD  CONSTRAINT [FK_EstatusProveedor_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[EstatusProveedor] CHECK CONSTRAINT [FK_EstatusProveedor_UsuarioCreacion]
GO
ALTER TABLE [SIS].[EstatusProveedor]  WITH CHECK ADD  CONSTRAINT [FK_EstatusProveedor_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[EstatusProveedor] CHECK CONSTRAINT [FK_EstatusProveedor_UsuarioModificacion]
GO
ALTER TABLE [SIS].[Menu]  WITH CHECK ADD  CONSTRAINT [CONSTRAINT_FK_Menu_Padre] FOREIGN KEY([FKIdMenu_SIS])
REFERENCES [SIS].[Menu] ([PKIdMenu])
GO
ALTER TABLE [SIS].[Menu] CHECK CONSTRAINT [CONSTRAINT_FK_Menu_Padre]
GO
ALTER TABLE [SIS].[MenuRole]  WITH CHECK ADD  CONSTRAINT [CONSTRAINT_FK_MenuRole_Menu] FOREIGN KEY([FKIdMenu_SIS])
REFERENCES [SIS].[Menu] ([PKIdMenu])
GO
ALTER TABLE [SIS].[MenuRole] CHECK CONSTRAINT [CONSTRAINT_FK_MenuRole_Menu]
GO
ALTER TABLE [SIS].[MenuRole]  WITH CHECK ADD  CONSTRAINT [CONSTRAINT_FK_MenuRole_Role] FOREIGN KEY([RoleId])
REFERENCES [dbo].[AspNetRoles] ([Id])
GO
ALTER TABLE [SIS].[MenuRole] CHECK CONSTRAINT [CONSTRAINT_FK_MenuRole_Role]
GO
ALTER TABLE [SIS].[Municipios]  WITH CHECK ADD  CONSTRAINT [FK_Municipios_Estados] FOREIGN KEY([FKIdEstado_SIS])
REFERENCES [SIS].[Estados] ([PKIdEstado])
GO
ALTER TABLE [SIS].[Municipios] CHECK CONSTRAINT [FK_Municipios_Estados]
GO
ALTER TABLE [SIS].[OrigenLogMessage]  WITH CHECK ADD  CONSTRAINT [FK_OrigenLogMessage_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[OrigenLogMessage] CHECK CONSTRAINT [FK_OrigenLogMessage_UsuarioCreacion]
GO
ALTER TABLE [SIS].[OrigenLogMessage]  WITH CHECK ADD  CONSTRAINT [FK_OrigenLogMessage_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[OrigenLogMessage] CHECK CONSTRAINT [FK_OrigenLogMessage_UsuarioModificacion]
GO
ALTER TABLE [SIS].[Paises]  WITH CHECK ADD  CONSTRAINT [FK_Paises_Idioma] FOREIGN KEY([FKIdIdiomaPrincipal_SIS])
REFERENCES [SIS].[Idioma] ([PKIdIdioma])
GO
ALTER TABLE [SIS].[Paises] CHECK CONSTRAINT [FK_Paises_Idioma]
GO
ALTER TABLE [SIS].[Paises]  WITH CHECK ADD  CONSTRAINT [FK_Paises_Moneda] FOREIGN KEY([FKIdMonedaPrincipal_SIS])
REFERENCES [SIS].[Moneda] ([PKIdMoneda])
GO
ALTER TABLE [SIS].[Paises] CHECK CONSTRAINT [FK_Paises_Moneda]
GO
ALTER TABLE [SIS].[Partida]  WITH CHECK ADD  CONSTRAINT [FK_Partida_Concepto] FOREIGN KEY([FKIdConcepto_SIS])
REFERENCES [SIS].[Concepto] ([PKIdConcepto])
GO
ALTER TABLE [SIS].[Partida] CHECK CONSTRAINT [FK_Partida_Concepto]
GO
ALTER TABLE [SIS].[Partida]  WITH CHECK ADD  CONSTRAINT [FK_Partida_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[Partida] CHECK CONSTRAINT [FK_Partida_UsuarioCreacion]
GO
ALTER TABLE [SIS].[Partida]  WITH CHECK ADD  CONSTRAINT [FK_Partida_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[Partida] CHECK CONSTRAINT [FK_Partida_UsuarioModificacion]
GO
ALTER TABLE [SIS].[PerfilUsuario]  WITH CHECK ADD  CONSTRAINT [FK_PerfilUsuario_Usuario] FOREIGN KEY([FKIdUsuario_SIS])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
ON DELETE CASCADE
GO
ALTER TABLE [SIS].[PerfilUsuario] CHECK CONSTRAINT [FK_PerfilUsuario_Usuario]
GO
ALTER TABLE [SIS].[PerfilUsuario]  WITH CHECK ADD  CONSTRAINT [FK_PerfilUsuario_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[PerfilUsuario] CHECK CONSTRAINT [FK_PerfilUsuario_UsuarioCreacion]
GO
ALTER TABLE [SIS].[PerfilUsuario]  WITH CHECK ADD  CONSTRAINT [FK_PerfilUsuario_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[PerfilUsuario] CHECK CONSTRAINT [FK_PerfilUsuario_UsuarioModificacion]
GO
ALTER TABLE [SIS].[Proveedor]  WITH CHECK ADD  CONSTRAINT [FK_Proveedor_CuentaContable] FOREIGN KEY([FKIdCuentaContable_SIS])
REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable])
GO
ALTER TABLE [SIS].[Proveedor] CHECK CONSTRAINT [FK_Proveedor_CuentaContable]
GO
ALTER TABLE [SIS].[Proveedor]  WITH CHECK ADD  CONSTRAINT [FK_Proveedor_Estado] FOREIGN KEY([FKIdEstado_SIS])
REFERENCES [SIS].[Estados] ([PKIdEstado])
GO
ALTER TABLE [SIS].[Proveedor] CHECK CONSTRAINT [FK_Proveedor_Estado]
GO
ALTER TABLE [SIS].[Proveedor]  WITH CHECK ADD  CONSTRAINT [FK_Proveedor_EstatusProveedor] FOREIGN KEY([FKIdEstatusProveedor_SIS])
REFERENCES [SIS].[EstatusProveedor] ([PKIdEstatusProveedor])
GO
ALTER TABLE [SIS].[Proveedor] CHECK CONSTRAINT [FK_Proveedor_EstatusProveedor]
GO
ALTER TABLE [SIS].[Proveedor]  WITH CHECK ADD  CONSTRAINT [FK_Proveedor_Municipio] FOREIGN KEY([FKIdMunicipio_SIS])
REFERENCES [SIS].[Municipios] ([PKIdMunicipio])
GO
ALTER TABLE [SIS].[Proveedor] CHECK CONSTRAINT [FK_Proveedor_Municipio]
GO
ALTER TABLE [SIS].[Proveedor]  WITH CHECK ADD  CONSTRAINT [FK_Proveedor_Pais] FOREIGN KEY([FKIdPais_SIS])
REFERENCES [SIS].[Paises] ([PKIdPais])
GO
ALTER TABLE [SIS].[Proveedor] CHECK CONSTRAINT [FK_Proveedor_Pais]
GO
ALTER TABLE [SIS].[Proveedor]  WITH CHECK ADD  CONSTRAINT [FK_Proveedor_TipoProveedor] FOREIGN KEY([FkIdTipoProveedor_SIS])
REFERENCES [SIS].[TipoProveedor] ([PkIdTipoProveedor])
GO
ALTER TABLE [SIS].[Proveedor] CHECK CONSTRAINT [FK_Proveedor_TipoProveedor]
GO
ALTER TABLE [SIS].[Sucursal]  WITH CHECK ADD  CONSTRAINT [FK_Sucursal_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [SIS].[Sucursal] CHECK CONSTRAINT [FK_Sucursal_Empresa]
GO
ALTER TABLE [SIS].[Sucursal]  WITH CHECK ADD  CONSTRAINT [FK_Sucursal_Estado] FOREIGN KEY([FKIdEstado_SIS])
REFERENCES [SIS].[Estados] ([PKIdEstado])
GO
ALTER TABLE [SIS].[Sucursal] CHECK CONSTRAINT [FK_Sucursal_Estado]
GO
ALTER TABLE [SIS].[Sucursal]  WITH CHECK ADD  CONSTRAINT [FK_Sucursal_Moneda] FOREIGN KEY([FKIdMonedaLocal_SIS])
REFERENCES [SIS].[Moneda] ([PKIdMoneda])
GO
ALTER TABLE [SIS].[Sucursal] CHECK CONSTRAINT [FK_Sucursal_Moneda]
GO
ALTER TABLE [SIS].[Sucursal]  WITH CHECK ADD  CONSTRAINT [FK_Sucursal_Tipo] FOREIGN KEY([FKIdTipoSucursal])
REFERENCES [SIS].[CatTipoSucursal] ([PKIdTipoSucursal])
GO
ALTER TABLE [SIS].[Sucursal] CHECK CONSTRAINT [FK_Sucursal_Tipo]
GO
ALTER TABLE [SIS].[Sucursal]  WITH CHECK ADD  CONSTRAINT [FK_Sucursal_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[Sucursal] CHECK CONSTRAINT [FK_Sucursal_UsuarioCreacion]
GO
ALTER TABLE [SIS].[Sucursal]  WITH CHECK ADD  CONSTRAINT [FK_Sucursal_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[Sucursal] CHECK CONSTRAINT [FK_Sucursal_UsuarioModificacion]
GO
ALTER TABLE [SIS].[SystemLog]  WITH CHECK ADD  CONSTRAINT [CONSTRAINT_FK_SystemLog_OrigenLogMessage] FOREIGN KEY([FKIdOrigenLogMessage_SIS])
REFERENCES [SIS].[OrigenLogMessage] ([PKIdOrigenLogMessage])
GO
ALTER TABLE [SIS].[SystemLog] CHECK CONSTRAINT [CONSTRAINT_FK_SystemLog_OrigenLogMessage]
GO
ALTER TABLE [SIS].[SystemParamCatalog]  WITH CHECK ADD  CONSTRAINT [FK_SystemParamCatalog_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[SystemParamCatalog] CHECK CONSTRAINT [FK_SystemParamCatalog_UsuarioCreacion]
GO
ALTER TABLE [SIS].[SystemParamCatalog]  WITH CHECK ADD  CONSTRAINT [FK_SystemParamCatalog_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[SystemParamCatalog] CHECK CONSTRAINT [FK_SystemParamCatalog_UsuarioModificacion]
GO
ALTER TABLE [SIS].[SystemParamValue]  WITH CHECK ADD  CONSTRAINT [CONSTRAINT_FK_SystemParamCatalog_SystemParamValue] FOREIGN KEY([FKIdSystemParamCatalog_SIS])
REFERENCES [SIS].[SystemParamCatalog] ([PKIdSystemParamCatalog])
GO
ALTER TABLE [SIS].[SystemParamValue] CHECK CONSTRAINT [CONSTRAINT_FK_SystemParamCatalog_SystemParamValue]
GO
ALTER TABLE [SIS].[SystemParamValue]  WITH CHECK ADD  CONSTRAINT [FK_SystemParamValue_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[SystemParamValue] CHECK CONSTRAINT [FK_SystemParamValue_UsuarioCreacion]
GO
ALTER TABLE [SIS].[SystemParamValue]  WITH CHECK ADD  CONSTRAINT [FK_SystemParamValue_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[SystemParamValue] CHECK CONSTRAINT [FK_SystemParamValue_UsuarioModificacion]
GO
ALTER TABLE [SIS].[TipoDetallePoliza]  WITH CHECK ADD  CONSTRAINT [FK_TipoDetallePoliza_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[TipoDetallePoliza] CHECK CONSTRAINT [FK_TipoDetallePoliza_UsuarioCreacion]
GO
ALTER TABLE [SIS].[TipoDetallePoliza]  WITH CHECK ADD  CONSTRAINT [FK_TipoDetallePoliza_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[TipoDetallePoliza] CHECK CONSTRAINT [FK_TipoDetallePoliza_UsuarioModificacion]
GO
ALTER TABLE [SIS].[TipoDoctoCLC]  WITH CHECK ADD  CONSTRAINT [FK_TipoDoctoCLC_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[TipoDoctoCLC] CHECK CONSTRAINT [FK_TipoDoctoCLC_UsuarioCreacion]
GO
ALTER TABLE [SIS].[TipoDoctoCLC]  WITH CHECK ADD  CONSTRAINT [FK_TipoDoctoCLC_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[TipoDoctoCLC] CHECK CONSTRAINT [FK_TipoDoctoCLC_UsuarioModificacion]
GO
ALTER TABLE [SIS].[TipoPoliza]  WITH CHECK ADD  CONSTRAINT [FK_TipoPoliza_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[TipoPoliza] CHECK CONSTRAINT [FK_TipoPoliza_UsuarioCreacion]
GO
ALTER TABLE [SIS].[TipoPoliza]  WITH CHECK ADD  CONSTRAINT [FK_TipoPoliza_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[TipoPoliza] CHECK CONSTRAINT [FK_TipoPoliza_UsuarioModificacion]
GO
ALTER TABLE [SIS].[TipoProveedor]  WITH CHECK ADD  CONSTRAINT [FK_TipoProveedor_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[TipoProveedor] CHECK CONSTRAINT [FK_TipoProveedor_UsuarioCreacion]
GO
ALTER TABLE [SIS].[TipoProveedor]  WITH CHECK ADD  CONSTRAINT [FK_TipoProveedor_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[TipoProveedor] CHECK CONSTRAINT [FK_TipoProveedor_UsuarioModificacion]
GO
ALTER TABLE [SIS].[Usuario]  WITH CHECK ADD  CONSTRAINT [FK_Usuario_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [SIS].[Usuario] CHECK CONSTRAINT [FK_Usuario_Empresa]
GO
ALTER TABLE [SIS].[Usuario]  WITH CHECK ADD  CONSTRAINT [FK_Usuario_Idioma] FOREIGN KEY([FKIdIdiomaPreferido_SIS])
REFERENCES [SIS].[Idioma] ([PKIdIdioma])
GO
ALTER TABLE [SIS].[Usuario] CHECK CONSTRAINT [FK_Usuario_Idioma]
GO
ALTER TABLE [SIS].[Usuario]  WITH CHECK ADD  CONSTRAINT [FK_Usuario_Moneda] FOREIGN KEY([FKIdMonedaPreferida_SIS])
REFERENCES [SIS].[Moneda] ([PKIdMoneda])
GO
ALTER TABLE [SIS].[Usuario] CHECK CONSTRAINT [FK_Usuario_Moneda]
GO
ALTER TABLE [SIS].[Usuario]  WITH CHECK ADD  CONSTRAINT [FK_Usuario_Persona] FOREIGN KEY([FKIdPersona_NOM])
REFERENCES [NOM].[Persona] ([PKIdPersona])
GO
ALTER TABLE [SIS].[Usuario] CHECK CONSTRAINT [FK_Usuario_Persona]
GO
ALTER TABLE [SIS].[Usuario]  WITH CHECK ADD  CONSTRAINT [FK_Usuario_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[Usuario] CHECK CONSTRAINT [FK_Usuario_UsuarioCreacion]
GO
ALTER TABLE [SIS].[Usuario]  WITH CHECK ADD  CONSTRAINT [FK_Usuario_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[Usuario] CHECK CONSTRAINT [FK_Usuario_UsuarioModificacion]
GO
ALTER TABLE [SIS].[UsuarioDepartamento]  WITH CHECK ADD  CONSTRAINT [FK_UsuarioDepartamento_Departamento] FOREIGN KEY([FKIdDepartamento_SIS])
REFERENCES [SIS].[Departamento] ([PKIdDepartamento])
GO
ALTER TABLE [SIS].[UsuarioDepartamento] CHECK CONSTRAINT [FK_UsuarioDepartamento_Departamento]
GO
ALTER TABLE [SIS].[UsuarioDepartamento]  WITH CHECK ADD  CONSTRAINT [FK_UsuarioDepartamento_Usuario] FOREIGN KEY([FKIdUsuario_SIS])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[UsuarioDepartamento] CHECK CONSTRAINT [FK_UsuarioDepartamento_Usuario]
GO
ALTER TABLE [SIS].[UsuarioDepartamento]  WITH CHECK ADD  CONSTRAINT [FK_UsuarioDepartamento_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[UsuarioDepartamento] CHECK CONSTRAINT [FK_UsuarioDepartamento_UsuarioCreacion]
GO
ALTER TABLE [SIS].[UsuarioDepartamento]  WITH CHECK ADD  CONSTRAINT [FK_UsuarioDepartamento_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[UsuarioDepartamento] CHECK CONSTRAINT [FK_UsuarioDepartamento_UsuarioModificacion]
GO
ALTER TABLE [SIS].[UsuarioSucursal]  WITH CHECK ADD  CONSTRAINT [FK_UsuarioSucursal_Sucursal] FOREIGN KEY([FKIdSucursal_SIS])
REFERENCES [SIS].[Sucursal] ([PKIdSucursal])
GO
ALTER TABLE [SIS].[UsuarioSucursal] CHECK CONSTRAINT [FK_UsuarioSucursal_Sucursal]
GO
ALTER TABLE [SIS].[UsuarioSucursal]  WITH CHECK ADD  CONSTRAINT [FK_UsuarioSucursal_Usuario] FOREIGN KEY([FKIdUsuario_SIS])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[UsuarioSucursal] CHECK CONSTRAINT [FK_UsuarioSucursal_Usuario]
GO
ALTER TABLE [SIS].[UsuarioSucursal]  WITH CHECK ADD  CONSTRAINT [FK_UsuarioSucursal_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[UsuarioSucursal] CHECK CONSTRAINT [FK_UsuarioSucursal_UsuarioCreacion]
GO
ALTER TABLE [SIS].[UsuarioSucursal]  WITH CHECK ADD  CONSTRAINT [FK_UsuarioSucursal_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [SIS].[UsuarioSucursal] CHECK CONSTRAINT [FK_UsuarioSucursal_UsuarioModificacion]
GO
ALTER TABLE [TES].[Banco]  WITH CHECK ADD  CONSTRAINT [FK_Banco_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [TES].[Banco] CHECK CONSTRAINT [FK_Banco_Empresa]
GO
ALTER TABLE [TES].[Banco]  WITH CHECK ADD  CONSTRAINT [FK_Banco_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[Banco] CHECK CONSTRAINT [FK_Banco_UsuarioCreacion]
GO
ALTER TABLE [TES].[Banco]  WITH CHECK ADD  CONSTRAINT [FK_Banco_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[Banco] CHECK CONSTRAINT [FK_Banco_UsuarioModificacion]
GO
ALTER TABLE [TES].[CuentaBancaria]  WITH CHECK ADD  CONSTRAINT [FK_CuentaBancaria_Banco] FOREIGN KEY([FKIdBanco_TES])
REFERENCES [TES].[Banco] ([PKIdBanco])
GO
ALTER TABLE [TES].[CuentaBancaria] CHECK CONSTRAINT [FK_CuentaBancaria_Banco]
GO
ALTER TABLE [TES].[CuentaBancaria]  WITH CHECK ADD  CONSTRAINT [FK_CuentaBancaria_CuentaContable] FOREIGN KEY([FKIdCuentaContable_SIS])
REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable])
GO
ALTER TABLE [TES].[CuentaBancaria] CHECK CONSTRAINT [FK_CuentaBancaria_CuentaContable]
GO
ALTER TABLE [TES].[CuentaBancaria]  WITH CHECK ADD  CONSTRAINT [FK_CuentaBancaria_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [TES].[CuentaBancaria] CHECK CONSTRAINT [FK_CuentaBancaria_Empresa]
GO
ALTER TABLE [TES].[CuentaBancaria]  WITH CHECK ADD  CONSTRAINT [FK_CuentaBancaria_TipoMoneda] FOREIGN KEY([FKIdTipoMoneda_TES])
REFERENCES [TES].[TipoMoneda] ([PKIdTipoMoneda])
GO
ALTER TABLE [TES].[CuentaBancaria] CHECK CONSTRAINT [FK_CuentaBancaria_TipoMoneda]
GO
ALTER TABLE [TES].[CuentaBancaria]  WITH CHECK ADD  CONSTRAINT [FK_CuentaBancaria_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[CuentaBancaria] CHECK CONSTRAINT [FK_CuentaBancaria_UsuarioCreacion]
GO
ALTER TABLE [TES].[CuentaBancaria]  WITH CHECK ADD  CONSTRAINT [FK_CuentaBancaria_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[CuentaBancaria] CHECK CONSTRAINT [FK_CuentaBancaria_UsuarioModificacion]
GO
ALTER TABLE [TES].[Instrumento]  WITH CHECK ADD  CONSTRAINT [FK_Instrumento_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [TES].[Instrumento] CHECK CONSTRAINT [FK_Instrumento_Empresa]
GO
ALTER TABLE [TES].[Instrumento]  WITH CHECK ADD  CONSTRAINT [FK_Instrumento_Intermediario] FOREIGN KEY([FKIdIntermediarioFinanciero_TES])
REFERENCES [TES].[IntermediarioFinanciero] ([PKIdIntermediarioFinanciero])
GO
ALTER TABLE [TES].[Instrumento] CHECK CONSTRAINT [FK_Instrumento_Intermediario]
GO
ALTER TABLE [TES].[Instrumento]  WITH CHECK ADD  CONSTRAINT [FK_Instrumento_TipoInversion] FOREIGN KEY([FKIdTipoInversion_TES])
REFERENCES [TES].[TipoInversion] ([PKIdTipoInversion])
GO
ALTER TABLE [TES].[Instrumento] CHECK CONSTRAINT [FK_Instrumento_TipoInversion]
GO
ALTER TABLE [TES].[Instrumento]  WITH CHECK ADD  CONSTRAINT [FK_Instrumento_TipoMoneda] FOREIGN KEY([FKIdTipoMoneda_TES])
REFERENCES [TES].[TipoMoneda] ([PKIdTipoMoneda])
GO
ALTER TABLE [TES].[Instrumento] CHECK CONSTRAINT [FK_Instrumento_TipoMoneda]
GO
ALTER TABLE [TES].[Instrumento]  WITH CHECK ADD  CONSTRAINT [FK_Instrumento_TipoPlazo] FOREIGN KEY([FKIdTipoPlazo_TES])
REFERENCES [TES].[TipoPlazo] ([PKIdTipoPlazo])
GO
ALTER TABLE [TES].[Instrumento] CHECK CONSTRAINT [FK_Instrumento_TipoPlazo]
GO
ALTER TABLE [TES].[Instrumento]  WITH CHECK ADD  CONSTRAINT [FK_Instrumento_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[Instrumento] CHECK CONSTRAINT [FK_Instrumento_UsuarioCreacion]
GO
ALTER TABLE [TES].[Instrumento]  WITH CHECK ADD  CONSTRAINT [FK_Instrumento_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[Instrumento] CHECK CONSTRAINT [FK_Instrumento_UsuarioModificacion]
GO
ALTER TABLE [TES].[Interes]  WITH CHECK ADD  CONSTRAINT [FK_Interes_Inversion] FOREIGN KEY([FKIdInversion])
REFERENCES [TES].[Inversion] ([PKIdInversion])
GO
ALTER TABLE [TES].[Interes] CHECK CONSTRAINT [FK_Interes_Inversion]
GO
ALTER TABLE [TES].[Interes]  WITH CHECK ADD  CONSTRAINT [FK_Interes_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[Interes] CHECK CONSTRAINT [FK_Interes_UsuarioCreacion]
GO
ALTER TABLE [TES].[Interes]  WITH CHECK ADD  CONSTRAINT [FK_Interes_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[Interes] CHECK CONSTRAINT [FK_Interes_UsuarioModificacion]
GO
ALTER TABLE [TES].[IntermediarioFinanciero]  WITH CHECK ADD  CONSTRAINT [FK_IntermediarioFinanciero_Empresa] FOREIGN KEY([FKIdEmpresa_SIS])
REFERENCES [SIS].[Empresa] ([PKIdEmpresa])
GO
ALTER TABLE [TES].[IntermediarioFinanciero] CHECK CONSTRAINT [FK_IntermediarioFinanciero_Empresa]
GO
ALTER TABLE [TES].[IntermediarioFinanciero]  WITH CHECK ADD  CONSTRAINT [FK_IntermediarioFinanciero_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[IntermediarioFinanciero] CHECK CONSTRAINT [FK_IntermediarioFinanciero_UsuarioCreacion]
GO
ALTER TABLE [TES].[IntermediarioFinanciero]  WITH CHECK ADD  CONSTRAINT [FK_IntermediarioFinanciero_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[IntermediarioFinanciero] CHECK CONSTRAINT [FK_IntermediarioFinanciero_UsuarioModificacion]
GO
ALTER TABLE [TES].[Inversion]  WITH CHECK ADD  CONSTRAINT [FK_Inversion_CuentaBancaria] FOREIGN KEY([FKIdCuentaBancaria])
REFERENCES [TES].[CuentaBancaria] ([PKIdCuentaBancaria])
GO
ALTER TABLE [TES].[Inversion] CHECK CONSTRAINT [FK_Inversion_CuentaBancaria]
GO
ALTER TABLE [TES].[Inversion]  WITH CHECK ADD  CONSTRAINT [FK_Inversion_Instrumento] FOREIGN KEY([FKIdInstrumento])
REFERENCES [TES].[Instrumento] ([PKIdInstrumento])
GO
ALTER TABLE [TES].[Inversion] CHECK CONSTRAINT [FK_Inversion_Instrumento]
GO
ALTER TABLE [TES].[Inversion]  WITH CHECK ADD  CONSTRAINT [FK_Inversion_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[Inversion] CHECK CONSTRAINT [FK_Inversion_UsuarioCreacion]
GO
ALTER TABLE [TES].[Inversion]  WITH CHECK ADD  CONSTRAINT [FK_Inversion_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[Inversion] CHECK CONSTRAINT [FK_Inversion_UsuarioModificacion]
GO
ALTER TABLE [TES].[Retiro]  WITH CHECK ADD  CONSTRAINT [FK_Retiro_Inversion] FOREIGN KEY([FKIdInversion])
REFERENCES [TES].[Inversion] ([PKIdInversion])
GO
ALTER TABLE [TES].[Retiro] CHECK CONSTRAINT [FK_Retiro_Inversion]
GO
ALTER TABLE [TES].[Retiro]  WITH CHECK ADD  CONSTRAINT [FK_Retiro_TipoRetiro] FOREIGN KEY([FKIdTipoRetiro_TES])
REFERENCES [TES].[TipoRetiro] ([PKIdTipoRetiro])
GO
ALTER TABLE [TES].[Retiro] CHECK CONSTRAINT [FK_Retiro_TipoRetiro]
GO
ALTER TABLE [TES].[Retiro]  WITH CHECK ADD  CONSTRAINT [FK_Retiro_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[Retiro] CHECK CONSTRAINT [FK_Retiro_UsuarioCreacion]
GO
ALTER TABLE [TES].[Retiro]  WITH CHECK ADD  CONSTRAINT [FK_Retiro_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[Retiro] CHECK CONSTRAINT [FK_Retiro_UsuarioModificacion]
GO
ALTER TABLE [TES].[TipoCambio]  WITH CHECK ADD  CONSTRAINT [FK_TipoCambio_TipoMoneda] FOREIGN KEY([FKIdTipoMoneda_TES])
REFERENCES [TES].[TipoMoneda] ([PKIdTipoMoneda])
GO
ALTER TABLE [TES].[TipoCambio] CHECK CONSTRAINT [FK_TipoCambio_TipoMoneda]
GO
ALTER TABLE [TES].[TipoCambio]  WITH CHECK ADD  CONSTRAINT [FK_TipoCambio_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[TipoCambio] CHECK CONSTRAINT [FK_TipoCambio_UsuarioCreacion]
GO
ALTER TABLE [TES].[TipoCambio]  WITH CHECK ADD  CONSTRAINT [FK_TipoCambio_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[TipoCambio] CHECK CONSTRAINT [FK_TipoCambio_UsuarioModificacion]
GO
ALTER TABLE [TES].[TipoDoctoCLC]  WITH CHECK ADD  CONSTRAINT [FK_TipoDoctoCLC_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[TipoDoctoCLC] CHECK CONSTRAINT [FK_TipoDoctoCLC_UsuarioCreacion]
GO
ALTER TABLE [TES].[TipoDoctoCLC]  WITH CHECK ADD  CONSTRAINT [FK_TipoDoctoCLC_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[TipoDoctoCLC] CHECK CONSTRAINT [FK_TipoDoctoCLC_UsuarioModificacion]
GO
ALTER TABLE [TES].[TipoInversion]  WITH CHECK ADD  CONSTRAINT [FK_TipoInversion_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[TipoInversion] CHECK CONSTRAINT [FK_TipoInversion_UsuarioCreacion]
GO
ALTER TABLE [TES].[TipoInversion]  WITH CHECK ADD  CONSTRAINT [FK_TipoInversion_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[TipoInversion] CHECK CONSTRAINT [FK_TipoInversion_UsuarioModificacion]
GO
ALTER TABLE [TES].[TipoMoneda]  WITH CHECK ADD  CONSTRAINT [FK_TipoMoneda_Pais] FOREIGN KEY([FKIdPais_SIS])
REFERENCES [SIS].[Paises] ([PKIdPais])
GO
ALTER TABLE [TES].[TipoMoneda] CHECK CONSTRAINT [FK_TipoMoneda_Pais]
GO
ALTER TABLE [TES].[TipoMoneda]  WITH CHECK ADD  CONSTRAINT [FK_TipoMoneda_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[TipoMoneda] CHECK CONSTRAINT [FK_TipoMoneda_UsuarioCreacion]
GO
ALTER TABLE [TES].[TipoMoneda]  WITH CHECK ADD  CONSTRAINT [FK_TipoMoneda_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[TipoMoneda] CHECK CONSTRAINT [FK_TipoMoneda_UsuarioModificacion]
GO
ALTER TABLE [TES].[TipoPago]  WITH CHECK ADD  CONSTRAINT [FK_TipoPago_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[TipoPago] CHECK CONSTRAINT [FK_TipoPago_UsuarioCreacion]
GO
ALTER TABLE [TES].[TipoPago]  WITH CHECK ADD  CONSTRAINT [FK_TipoPago_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[TipoPago] CHECK CONSTRAINT [FK_TipoPago_UsuarioModificacion]
GO
ALTER TABLE [TES].[TipoPagoSF]  WITH CHECK ADD  CONSTRAINT [FK_TipoPagoSF_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[TipoPagoSF] CHECK CONSTRAINT [FK_TipoPagoSF_UsuarioCreacion]
GO
ALTER TABLE [TES].[TipoPagoSF]  WITH CHECK ADD  CONSTRAINT [FK_TipoPagoSF_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[TipoPagoSF] CHECK CONSTRAINT [FK_TipoPagoSF_UsuarioModificacion]
GO
ALTER TABLE [TES].[TipoPlazo]  WITH CHECK ADD  CONSTRAINT [FK_TipoPlazo_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[TipoPlazo] CHECK CONSTRAINT [FK_TipoPlazo_UsuarioCreacion]
GO
ALTER TABLE [TES].[TipoPlazo]  WITH CHECK ADD  CONSTRAINT [FK_TipoPlazo_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[TipoPlazo] CHECK CONSTRAINT [FK_TipoPlazo_UsuarioModificacion]
GO
ALTER TABLE [TES].[TipoRetiro]  WITH CHECK ADD  CONSTRAINT [FK_TipoRetiro_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[TipoRetiro] CHECK CONSTRAINT [FK_TipoRetiro_UsuarioCreacion]
GO
ALTER TABLE [TES].[TipoRetiro]  WITH CHECK ADD  CONSTRAINT [FK_TipoRetiro_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[TipoRetiro] CHECK CONSTRAINT [FK_TipoRetiro_UsuarioModificacion]
GO
ALTER TABLE [TES].[TipoSolicitudCLC]  WITH CHECK ADD  CONSTRAINT [FK_TipoSolicitudCLC_UsuarioCreacion] FOREIGN KEY([UsuarioCreacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[TipoSolicitudCLC] CHECK CONSTRAINT [FK_TipoSolicitudCLC_UsuarioCreacion]
GO
ALTER TABLE [TES].[TipoSolicitudCLC]  WITH CHECK ADD  CONSTRAINT [FK_TipoSolicitudCLC_UsuarioModificacion] FOREIGN KEY([UsuarioModificacion])
REFERENCES [SIS].[Usuario] ([PkIdUsuario])
GO
ALTER TABLE [TES].[TipoSolicitudCLC] CHECK CONSTRAINT [FK_TipoSolicitudCLC_UsuarioModificacion]
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle]  WITH CHECK ADD  CONSTRAINT [CK_EstudioMercadoDetalle_CostoUnitario] CHECK  (([CostoUnitario] IS NULL OR [CostoUnitario]>=(0)))
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle] CHECK CONSTRAINT [CK_EstudioMercadoDetalle_CostoUnitario]
GO
