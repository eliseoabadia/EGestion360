CREATE SCHEMA [ALMA];
GO
CREATE SCHEMA [CAJA];
GO
CREATE SCHEMA [CONTA];
GO
CREATE SCHEMA [CTL];
GO
CREATE SCHEMA [CUM];
GO
CREATE SCHEMA [DOC];
GO
CREATE SCHEMA [FIS];
GO
CREATE SCHEMA [NOM];
GO
CREATE SCHEMA [ORCO];
GO
CREATE SCHEMA [PAG];
GO
CREATE SCHEMA [PAT];
GO
CREATE SCHEMA [PBR];
GO
CREATE SCHEMA [PRES];
GO
CREATE SCHEMA [SIS];
GO
CREATE SCHEMA [TES];
GO
CREATE SCHEMA [VIA];
GO
CREATE SCHEMA [WF];
GO
CREATE TABLE [ALMA].[Almacen] (
 [PKIdAlmacen] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdArea_SIS] int NULL,
 [FKIdTipoBien_ALMA] int NOT NULL,
 [FKIdUnidades_ALMA] int NULL,
 [FKIdMotivoES_ALMA] int NULL,
 [FKIdDetalleOrdenCompra_ORCO] int NULL,
 [Clave] nvarchar(30) COLLATE Modern_Spanish_CI_AS NULL,
 [Cantidad] decimal(20,4) NOT NULL DEFAULT ((0)),
 [CostoUnitario] decimal(20,4) NULL,
 [Costo] decimal(20,4) NULL,
 [Factura] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [Remision] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [Lote] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [FechaEntrada] date NOT NULL DEFAULT (CONVERT([date],getdate())),
 [FechaCaducidad] date NULL,
 [AplicaAlmacen] bit NOT NULL DEFAULT ((1)),
 [InventarioCerrado] bit NOT NULL DEFAULT ((0)),
 [EsContabilizado] bit NOT NULL DEFAULT ((0)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(0) NULL,
 [UsuarioModificacion] int NULL,
 [FKIdAnio_SIS] int NULL,
 [IdPartidaStock] bigint NULL,
 CONSTRAINT [PK_Almacen] PRIMARY KEY CLUSTERED ([PKIdAlmacen] ASC)
);
GO
CREATE TABLE [ALMA].[AlmacenCatalogo] (
 [IdAlmacenCatalogo] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdSucursal] int NOT NULL,
 [Codigo] nvarchar(30) NOT NULL,
 [Nombre] nvarchar(150) NOT NULL,
 [Tipo] varchar(12) NOT NULL,
 [Activo] bit NOT NULL DEFAULT 1,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_ALMA_AlmacenCatalogo_IdAlmacenCatalogo] PRIMARY KEY CLUSTERED ([IdAlmacenCatalogo] ASC)
);
GO
CREATE TABLE [ALMA].[Bajas] (
 [PKIdBaja] int IDENTITY(1,1) NOT NULL,
 [Folio] nvarchar(30) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdArea_SIS] int NULL,
 [FKIdBien_ALMA] int NOT NULL,
 [FKIdTipoBaja_ALMA] int NOT NULL,
 [FKIdEstatusBaja_ALMA] int NOT NULL,
 [FKIdEstadoBienAnterior_ALMA] int NULL,
 [FKIdEstadoBienDestino_ALMA] int NULL,
 [FechaSolicitud] date NOT NULL DEFAULT (CONVERT([date],getdate())),
 [FechaBaja] date NULL,
 [Referencia] nvarchar(200) COLLATE Modern_Spanish_CI_AS NULL,
 [FechaReferencia] date NULL,
 [Destinatario] nvarchar(250) COLLATE Modern_Spanish_CI_AS NULL,
 [Recibo] nvarchar(100) COLLATE Modern_Spanish_CI_AS NULL,
 [Cantidad] decimal(20,4) NULL DEFAULT ((1)),
 [Motivo] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Dictamen] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [Observaciones] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [FKIdPoliza_CONTA] int NULL,
 [SolicitadoPor_Responsable] bigint NULL,
 [AutorizadoPor_Responsable] bigint NULL,
 [FechaAutorizacion] datetime2(0) NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(0) NULL,
 [UsuarioModificacion] int NULL,
 [FKIdAnio_SIS] int NULL,
 [IdOperacion] bigint NOT NULL,
 CONSTRAINT [PK_Bajas] PRIMARY KEY CLUSTERED ([PKIdBaja] ASC)
);
GO
CREATE TABLE [ALMA].[Bien] (
 [PKIdBien] int IDENTITY(1,1) NOT NULL,
 [FKIdGrupoBien_ALMA] int NULL,
 [FKIdTipoBien_ALMA] int NOT NULL,
 [FKIdArea_SIS] int NULL,
 [FKIdProveedor_SIS] int NULL,
 [FKIdEstadoBien_ALMA] int NULL,
 [FKIdTipoPatrimonio_ALMA] int NULL,
 [FKIdMarca_ALMA] int NULL,
 [FKIdMaterial_ALMA] int NULL,
 [FKIdTipoAdq_ALMA] int NULL,
 [FKIdPartida_CONTA] int NULL,
 [FKIdDetalleOrdenCompra_ORCO] int NULL,
 [Clave] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [ClaveAnt] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [Descripcion] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [Modelo] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [Serie] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [Requisicion] nvarchar(25) COLLATE Modern_Spanish_CI_AS NULL,
 [Factura] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [Costo] decimal(20,4) NULL,
 [FechaAdq] datetime NULL,
 [Referencia] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [Notas] nvarchar(250) COLLATE Modern_Spanish_CI_AS NULL,
 [Ubicacion] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [AAdquisicion] nvarchar(2) COLLATE Modern_Spanish_CI_AS NULL,
 [Frente] int NULL,
 [Fondo] int NULL,
 [Altura] int NULL,
 [Diametro] int NULL,
 [VerificacionesDias] int NOT NULL,
 [MantenimientoDias] int NOT NULL,
 [Mantenimiento] bit NOT NULL,
 [Calibracion] bit NOT NULL,
 [Rango] nvarchar(20) COLLATE Modern_Spanish_CI_AS NULL,
 [Resolucion] nvarchar(20) COLLATE Modern_Spanish_CI_AS NULL,
 [FechaUltInv] datetime NULL,
 [FechaReqscn] datetime NULL,
 [Estatus] nvarchar(1) COLLATE Modern_Spanish_CI_AS NULL,
 [Caracteristicas] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [Resguardo] int NULL,
 [ResguardoAnterior] int NULL,
 [RelId] int NULL,
 [ValorRescate] decimal(20,4) NULL,
 [ValorActual] decimal(20,4) NULL,
 [Antiguedad] int NULL,
 [Progresivo] int NULL,
 [Consecutivo] int NULL,
 [ClaveHist] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [EstaResguardado] bit NULL,
 [FechaResguardado] datetime NULL,
 [Localizado] bit NULL,
 [esContabilizado] bit NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime NULL,
 [UsuarioModificacion] int NULL,
 [FKIdEmpresa_SIS] int NOT NULL DEFAULT (CONVERT([int],session_context(N'EmpresaId'))),
 [IdUbicacionPatrimonial] bigint NULL,
 [IdUbicacionAlmacen] bigint NULL,
 CONSTRAINT [PK_Bien] PRIMARY KEY CLUSTERED ([PKIdBien] ASC)
);
GO
CREATE TABLE [ALMA].[CalendarioInventario] (
 [PKIdCalendarioInventario] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdArea_SIS] int NULL,
 [Anio] int NOT NULL,
 [Folio] nvarchar(30) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(300) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FechaInicio] date NOT NULL,
 [FechaFin] date NOT NULL,
 [Observaciones] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(0) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_CalendarioInventario] PRIMARY KEY CLUSTERED ([PKIdCalendarioInventario] ASC)
);
GO
CREATE TABLE [ALMA].[CierreInventario] (
 [PKIdCierreInventario] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdAnio_SIS] int NOT NULL,
 [FKIdTipoBien_ALMA] int NOT NULL,
 [FKIdUnidades_ALMA] int NULL,
 [Mes] tinyint NOT NULL,
 [Existencias] decimal(20,4) NOT NULL DEFAULT ((0)),
 [CostoExistencias] decimal(20,4) NULL,
 [CostoPromedio] decimal(20,4) NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL DEFAULT ((1)),
 [FechaModificacion] datetime2(0) NULL,
 [UsuarioModificacion] int NULL,
 [IdPartidaStock] bigint NOT NULL,
 CONSTRAINT [PK_CierreInventario] PRIMARY KEY CLUSTERED ([PKIdCierreInventario] ASC)
);
GO
CREATE TABLE [ALMA].[Conteo] (
 [PKIdConteo] int IDENTITY(1,1) NOT NULL,
 [FKIdTipoBien_ALMA] int NOT NULL,
 [CantidadInventario] decimal(20,4) NOT NULL,
 [Descripcion] nvarchar(max) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FechaInicio] datetime NOT NULL,
 [FechaFin] datetime NULL,
 [FKIdPeriodoConteo_ALMA] int NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime NULL,
 [UsuarioModificacion] int NULL,
 [IdEmpresa] int NOT NULL,
 [IdPartidaStock] bigint NOT NULL,
 [IdMovimientoAjuste] bigint NULL,
 [IdAlmacen] bigint NOT NULL,
 CONSTRAINT [PK_Conteo] PRIMARY KEY CLUSTERED ([PKIdConteo] ASC)
);
GO
CREATE TABLE [ALMA].[ConteoDetalle] (
 [PKIdDetalleConteo] int IDENTITY(1,1) NOT NULL,
 [FKIdConteo_ALMA] int NOT NULL,
 [FKIdNumeroConteo_ALMA] int NOT NULL,
 [FKIdPersona_Responsable] bigint NOT NULL,
 [Cantidad] decimal(20,4) NOT NULL,
 [Fecha] datetime NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime NULL,
 [UsuarioModificacion] int NULL,
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK_ConteoDetalle] PRIMARY KEY CLUSTERED ([PKIdDetalleConteo] ASC)
);
GO
CREATE TABLE [ALMA].[ConteoDetalleEscaneo] (
 [PKIdDetalleEscaneo] int IDENTITY(1,1) NOT NULL,
 [FKIdConteo_ALMA] int NOT NULL,
 [FKIdPersona_Responsable] bigint NOT NULL,
 [CodigoBarras] nvarchar(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FKIdTipoBien_ALMA] int NOT NULL,
 [FKIdBien_ALMA] int NULL,
 [FechaEscaneo] datetime NOT NULL DEFAULT (sysdatetime()),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime NULL,
 [UsuarioModificacion] int NULL,
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK_ConteoDetalleEscaneo] PRIMARY KEY CLUSTERED ([PKIdDetalleEscaneo] ASC)
);
GO
CREATE TABLE [ALMA].[ConteoHist] (
 [PKIdConteoHist] int IDENTITY(1,1) NOT NULL,
 [PKIdConteo] int NOT NULL,
 [FKIdTipoBien_ALMA] int NOT NULL,
 [CantidadInventario] decimal(18,2) NOT NULL,
 [Descripcion] nvarchar(max) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FechaInicio] datetime NOT NULL,
 [FechaFin] datetime NULL,
 [PrimerConteo] decimal(18,2) NOT NULL,
 [SegundoConteo] decimal(18,2) NOT NULL,
 [TercerConteo] decimal(18,2) NOT NULL,
 [Diferencias] nvarchar(max) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Nivel] int NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_ConteoHist] PRIMARY KEY CLUSTERED ([PKIdConteoHist] ASC)
);
GO
CREATE TABLE [ALMA].[DetalleSolicitudSalida] (
 [PKIdDetalleSolicitudSalida] int IDENTITY(1,1) NOT NULL,
 [FKIdSolicitudSalida_ALMA] int NOT NULL,
 [FKIdAlmacen_ALMA] int NULL,
 [FKIdTipoBien_ALMA] int NOT NULL,
 [FKIdUnidades_ALMA] int NULL,
 [CantidadSolicitada] decimal(20,4) NOT NULL,
 [CantidadAutorizada] decimal(20,4) NULL,
 [CantidadEntregada] decimal(20,4) NULL,
 [CantidadPendiente] decimal(20,4) NOT NULL DEFAULT ((0)),
 [Observaciones] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(0) NULL,
 [UsuarioModificacion] int NULL,
 [IdAlmacen] bigint NOT NULL,
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK_DetalleSolicitudSalida] PRIMARY KEY CLUSTERED ([PKIdDetalleSolicitudSalida] ASC)
);
GO
CREATE TABLE [ALMA].[EstadoBien] (
 [PKIdEstadoBien] int IDENTITY(1,1) NOT NULL,
 [DESCRIPCION_GENERAL] nvarchar(150) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [DESCRIPCION_ESPECIFICA] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [DESCRIPCION_CORTA] nvarchar(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_EstadoBien] PRIMARY KEY CLUSTERED ([PKIdEstadoBien] ASC)
);
GO
CREATE TABLE [ALMA].[EstatusArticuloConteo] (
 [PKIdEstatusArticulo] int IDENTITY(1,1) NOT NULL,
 [Nombre] nvarchar(30) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(100) COLLATE Modern_Spanish_CI_AS NULL,
 [Orden] int NOT NULL,
 [Color] nvarchar(8) COLLATE Modern_Spanish_CI_AS NULL,
 [Icono] nvarchar(30) COLLATE Modern_Spanish_CI_AS NULL,
 [BadgeTexto] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 CONSTRAINT [PK_EstatusArticuloConteo] PRIMARY KEY CLUSTERED ([PKIdEstatusArticulo] ASC)
);
GO
CREATE TABLE [ALMA].[EstatusBaja] (
 [PKIdEstatusBaja] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(80) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Color] nvarchar(20) COLLATE Modern_Spanish_CI_AS NULL,
 [Orden] int NOT NULL DEFAULT ((0)),
 [EsFinal] bit NOT NULL DEFAULT ((0)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(0) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_EstatusBaja] PRIMARY KEY CLUSTERED ([PKIdEstatusBaja] ASC)
);
GO
CREATE TABLE [ALMA].[EstatusInventario] (
 [PKIdEstatusInventario] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(80) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Color] nvarchar(20) COLLATE Modern_Spanish_CI_AS NULL,
 [Orden] int NOT NULL DEFAULT ((0)),
 [EsFinal] bit NOT NULL DEFAULT ((0)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(0) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_EstatusInventario] PRIMARY KEY CLUSTERED ([PKIdEstatusInventario] ASC)
);
GO
CREATE TABLE [ALMA].[EstatusPeriodo] (
 [PKIdEstatusPeriodo] int IDENTITY(1,1) NOT NULL,
 [Nombre] nvarchar(30) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(100) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 CONSTRAINT [PK_EstatusPeriodo] PRIMARY KEY CLUSTERED ([PKIdEstatusPeriodo] ASC)
);
GO
CREATE TABLE [ALMA].[EstatusSolicitud] (
 [PKIdEstatusSolicitud] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(150) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Color] nvarchar(8) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_EstatusSolicitud] PRIMARY KEY CLUSTERED ([PKIdEstatusSolicitud] ASC)
);
GO
CREATE TABLE [ALMA].[EstatusSolicitudSalida] (
 [PKIdEstatusSolicitudSalida] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(80) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Color] nvarchar(20) COLLATE Modern_Spanish_CI_AS NULL,
 [Orden] int NOT NULL DEFAULT ((0)),
 [EsFinal] bit NOT NULL DEFAULT ((0)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(0) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_EstatusSolicitudSalida] PRIMARY KEY CLUSTERED ([PKIdEstatusSolicitudSalida] ASC)
);
GO
CREATE TABLE [ALMA].[Familia] (
 [PKIdFamilia] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(80) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Clave] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Familia] PRIMARY KEY CLUSTERED ([PKIdFamilia] ASC)
);
GO
CREATE TABLE [ALMA].[GrupoBien] (
 [PKIdGrupoBien] int IDENTITY(1,1) NOT NULL,
 [FKIdFamilia_ALMA] int NOT NULL,
 [Descripcion] nvarchar(800) COLLATE Modern_Spanish_CI_AS NULL,
 [Clave] int NULL,
 [ClaveAN] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [CABM_ACT] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [CLAVE_CUCOP] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [MEDIDA] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_GrupoBien] PRIMARY KEY CLUSTERED ([PKIdGrupoBien] ASC)
);
GO
CREATE TABLE [ALMA].[Inventario] (
 [PKIdInventario] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdCalendarioInventario_ALMA] int NULL,
 [FKIdArea_SIS] int NULL,
 [FKIdEstatusInventario_ALMA] int NOT NULL,
 [Folio] nvarchar(30) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FechaInventario] date NOT NULL,
 [Responsable] nvarchar(250) COLLATE Modern_Spanish_CI_AS NULL,
 [Observaciones] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [TotalBienes] int NOT NULL DEFAULT ((0)),
 [TotalLocalizados] int NOT NULL DEFAULT ((0)),
 [TotalDiferencias] int NOT NULL DEFAULT ((0)),
 [Autorizado] bit NOT NULL DEFAULT ((0)),
 [FechaAutorizacion] datetime2(0) NULL,
 [UsuarioAutorizacion] int NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(0) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Inventario] PRIMARY KEY CLUSTERED ([PKIdInventario] ASC)
);
GO
CREATE TABLE [ALMA].[InventarioDetalle] (
 [PKIdInventarioDetalle] int IDENTITY(1,1) NOT NULL,
 [FKIdInventario_ALMA] int NOT NULL,
 [FKIdBien_ALMA] int NOT NULL,
 [ClaveBien] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [DescripcionBien] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [Serie] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [UbicacionSistema] nvarchar(250) COLLATE Modern_Spanish_CI_AS NULL,
 [UbicacionFisica] nvarchar(250) COLLATE Modern_Spanish_CI_AS NULL,
 [Localizado] bit NOT NULL DEFAULT ((0)),
 [TieneDiferencia] bit NOT NULL DEFAULT ((0)),
 [Observaciones] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(0) NULL,
 [UsuarioModificacion] int NULL,
 [IdEmpresa] int NOT NULL,
 [IdUbicacionPatrimonial] bigint NULL,
 [IdUbicacionAlmacen] bigint NULL,
 CONSTRAINT [PK_InventarioDetalle] PRIMARY KEY CLUSTERED ([PKIdInventarioDetalle] ASC)
);
GO
CREATE TABLE [ALMA].[Lote] (
 [IdLote] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdTipoBien] int NOT NULL,
 [Numero] nvarchar(80) NOT NULL,
 [Caducidad] date NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_ALMA_Lote_IdLote] PRIMARY KEY CLUSTERED ([IdLote] ASC)
);
GO
CREATE TABLE [ALMA].[Marca] (
 [PKIdMarca] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Marca] PRIMARY KEY CLUSTERED ([PKIdMarca] ASC)
);
GO
CREATE TABLE [ALMA].[Material] (
 [PKIdMaterial] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Material] PRIMARY KEY CLUSTERED ([PKIdMaterial] ASC)
);
GO
CREATE TABLE [ALMA].[MotivoES] (
 [PKIdMotivoES] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [AplicaEntrada] bit NOT NULL,
 [AplicaSalida] bit NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_MotivoES] PRIMARY KEY CLUSTERED ([PKIdMotivoES] ASC)
);
GO
CREATE TABLE [ALMA].[MovimientoInventario] (
 [IdMovimientoInventario] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdOperacion] bigint NOT NULL,
 [Tipo] varchar(20) NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [ClaveOperacion] uniqueidentifier NOT NULL,
 [AplicadoUtc] datetime2(7) NULL,
 [IdUsuarioAplicacion] int NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 [IdMovimientoReversa] bigint NULL,
 CONSTRAINT [UX_ALMA_MovimientoInventario_IdMovimientoInventario] PRIMARY KEY CLUSTERED ([IdMovimientoInventario] ASC)
);
GO
CREATE TABLE [ALMA].[MovimientoInventarioDetalle] (
 [IdMovimientoInventarioDetalle] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdMovimiento] bigint NOT NULL,
 [IdPartidaStock] bigint NOT NULL,
 [IdDetalleSolicitudSalida] int NULL,
 [IdTransferenciaDetalle] bigint NULL,
 [Cantidad] decimal(20,4) NOT NULL,
 [CostoUnitario] decimal(20,4) NOT NULL,
 [ImporteValoracion] decimal(20,4) NOT NULL,
 [IdEntradaLegada] int NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 [IdRecepcionDetalle] bigint NULL,
 [IdAlmacen] bigint NOT NULL,
 [IdTipoBien] int NOT NULL,
 CONSTRAINT [UX_ALMA_MovimientoInventarioDetalle_IdMovimientoInventarioDetalle] PRIMARY KEY CLUSTERED ([IdMovimientoInventarioDetalle] ASC)
);
GO
CREATE TABLE [ALMA].[Nivel] (
 [PKIdNivel] int IDENTITY(1,1) NOT NULL,
 [Nivel] int NOT NULL,
 [Descripcion] nvarchar(20) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Nivel] PRIMARY KEY CLUSTERED ([PKIdNivel] ASC)
);
GO
CREATE TABLE [ALMA].[PartidaStock] (
 [IdPartidaStock] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdAlmacen] bigint NOT NULL,
 [IdProductoAlmacen] bigint NOT NULL,
 [IdTipoBien] int NOT NULL,
 [IdUbicacion] bigint NOT NULL,
 [IdLote] bigint NULL,
 [Condicion] varchar(20) NOT NULL,
 [Activo] bit NOT NULL DEFAULT 1,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_ALMA_PartidaStock_IdPartidaStock] PRIMARY KEY CLUSTERED ([IdPartidaStock] ASC)
);
GO
CREATE TABLE [ALMA].[PeriodoConteo] (
 [PKIdPeriodoConteo] int IDENTITY(1,1) NOT NULL,
 [FKIdSucursal_SIS] int NOT NULL,
 [FKIdTipoConteo_ALMA] int NOT NULL,
 [FKIdEstatus_ALMA] int NOT NULL,
 [CodigoPeriodo] nvarchar(20) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Nombre] nvarchar(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [FechaInicio] date NOT NULL,
 [FechaFin] date NULL,
 [FechaCierre] datetime NULL,
 [MaximoConteosPorArticulo] int NOT NULL DEFAULT ((3)),
 [RequiereAprobacionSupervisor] bit NOT NULL DEFAULT ((1)),
 [FKIdResponsable_SIS] int NULL,
 [FKIdSupervisor_SIS] int NULL,
 [TotalArticulos] int NULL,
 [ArticulosConcluidos] int NULL,
 [ArticulosConDiferencia] int NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime NULL,
 [UsuarioModificacion] int NULL,
 [IdEmpresa] int NOT NULL,
 [IdAlmacen] bigint NOT NULL,
 CONSTRAINT [PK_PeriodoConteo] PRIMARY KEY CLUSTERED ([PKIdPeriodoConteo] ASC)
);
GO
CREATE TABLE [ALMA].[PlanConteoCiclico] (
 [PKIdPlanConteoCiclico] int IDENTITY(1,1) NOT NULL,
 [FKIdTipoBien_ALMA] int NOT NULL,
 [FKIdArea_SIS] int NULL,
 [ClasificacionABC] char(1) COLLATE Modern_Spanish_CI_AS NOT NULL DEFAULT ('C'),
 [FrecuenciaDias] int NOT NULL DEFAULT ((180)),
 [UltimaFechaConteo] date NULL,
 [ProximaFechaConteo] date NOT NULL,
 [ExistenciaActual] decimal(18,4) NOT NULL DEFAULT ((0)),
 [ExistenciaMinima] decimal(18,4) NULL,
 [ValorInventario] decimal(18,4) NOT NULL DEFAULT ((0)),
 [GenerarPorUmbral] bit NOT NULL DEFAULT ((1)),
 [RequiereConteoPorUmbral] bit NOT NULL DEFAULT ((0)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [FrecuenciaPersonalizada] bit NOT NULL DEFAULT ((0)),
 [IdEmpresa] int NOT NULL,
 [IdProductoAlmacen] bigint NOT NULL,
 CONSTRAINT [PK_PlanConteoCiclico] PRIMARY KEY CLUSTERED ([PKIdPlanConteoCiclico] ASC)
);
GO
CREATE TABLE [ALMA].[ProductoAlmacen] (
 [IdProductoAlmacen] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdAlmacen] bigint NOT NULL,
 [IdTipoBien] int NOT NULL,
 [Minimo] decimal(20,4) NOT NULL DEFAULT 0,
 [Maximo] decimal(20,4) NULL,
 [PuntoReposicion] decimal(20,4) NOT NULL DEFAULT 0,
 [Activo] bit NOT NULL DEFAULT 1,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_ALMA_ProductoAlmacen_IdProductoAlmacen] PRIMARY KEY CLUSTERED ([IdProductoAlmacen] ASC)
);
GO
CREATE TABLE [ALMA].[ReservaStock] (
 [IdReservaStock] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdPartidaStock] bigint NOT NULL,
 [IdDetalleSolicitudSalida] int NOT NULL,
 [Cantidad] decimal(20,4) NOT NULL,
 [Vencimiento] datetime2(7) NULL,
 [Estado] varchar(16) NOT NULL,
 [ClaveOperacion] uniqueidentifier NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 [IdAlmacen] bigint NOT NULL,
 [IdTipoBien] int NOT NULL,
 CONSTRAINT [UX_ALMA_ReservaStock_IdReservaStock] PRIMARY KEY CLUSTERED ([IdReservaStock] ASC)
);
GO
CREATE TABLE [ALMA].[Resguardo] (
 [PKIdResguardo] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdArea_SIS] int NULL,
 [Responsable] nvarchar(250) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Folio] nvarchar(30) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Fecha] date NOT NULL DEFAULT (CONVERT([date],getdate())),
 [Observaciones] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(0) NULL,
 [UsuarioModificacion] int NULL,
 [IdResponsableOperativo] bigint NOT NULL,
 [IdOperacion] bigint NOT NULL,
 CONSTRAINT [PK_Resguardo] PRIMARY KEY CLUSTERED ([PKIdResguardo] ASC)
);
GO
CREATE TABLE [ALMA].[ResguardoDetalle] (
 [PKIdResguardoDetalle] int IDENTITY(1,1) NOT NULL,
 [FKIdResguardo_ALMA] int NOT NULL,
 [FKIdBien_ALMA] int NOT NULL,
 [FKIdEstadoBien_ALMA] int NULL,
 [FechaAsignacion] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [FechaLiberacion] datetime2(0) NULL,
 [ImprimeEtiqueta] bit NOT NULL DEFAULT ((1)),
 [Observaciones] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(0) NULL,
 [UsuarioModificacion] int NULL,
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK_ResguardoDetalle] PRIMARY KEY CLUSTERED ([PKIdResguardoDetalle] ASC)
);
GO
CREATE TABLE [ALMA].[ResguardoMovimiento] (
 [PKIdResguardoMovimiento] int IDENTITY(1,1) NOT NULL,
 [FKIdResguardoDetalle_ALMA] int NULL,
 [FKIdBien_ALMA] int NOT NULL,
 [FKIdResguardoOrigen_ALMA] int NULL,
 [FKIdResguardoDestino_ALMA] int NULL,
 [TipoMovimiento] nvarchar(30) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FechaMovimiento] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [Observaciones] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(0) NULL,
 [UsuarioModificacion] int NULL,
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK_ResguardoMovimiento] PRIMARY KEY CLUSTERED ([PKIdResguardoMovimiento] ASC)
);
GO
CREATE TABLE [ALMA].[SolicitudSalida] (
 [PKIdSolicitudSalida] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdAreaSolicita_SIS] int NULL,
 [FKIdAreaEntrega_SIS] int NULL,
 [FKIdEstatusSolicitudSalida_ALMA] int NOT NULL,
 [Folio] nvarchar(30) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FechaSolicitud] date NOT NULL DEFAULT (CONVERT([date],getdate())),
 [FechaRequerida] date NULL,
 [Solicitante] nvarchar(250) COLLATE Modern_Spanish_CI_AS NULL,
 [Justificacion] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [Observaciones] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [Autorizado] bit NOT NULL DEFAULT ((0)),
 [FechaAutorizacion] datetime2(0) NULL,
 [UsuarioAutorizacion] int NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(0) NULL,
 [UsuarioModificacion] int NULL,
 [FKIdPoliza_CONTA] int NULL,
 [FKIdAnio_SIS] int NULL,
 [IdAlmacen] bigint NOT NULL,
 [IdOperacion] bigint NOT NULL,
 CONSTRAINT [PK_SolicitudSalida] PRIMARY KEY CLUSTERED ([PKIdSolicitudSalida] ASC)
);
GO
CREATE TABLE [ALMA].[TipoAdquisicion] (
 [PKIdTipoAdq] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(10) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripmovto] nvarchar(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_TipoAdquisicion] PRIMARY KEY CLUSTERED ([PKIdTipoAdq] ASC)
);
GO
CREATE TABLE [ALMA].[TipoBaja] (
 [PKIdTipoBaja] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(20) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(150) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FKIdEstadoBienDestino_ALMA] int NULL,
 [RequiereAutorizacion] bit NOT NULL DEFAULT ((1)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(0) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_TipoBaja] PRIMARY KEY CLUSTERED ([PKIdTipoBaja] ASC)
);
GO
CREATE TABLE [ALMA].[TipoBien] (
 [PKIdTipoBien] int IDENTITY(1,1) NOT NULL,
 [FKIdGrupoBien_ALMA] int NULL,
 [FKIdNivel_ALMA] int NULL,
 [FKIdPartida_CONTA] int NULL,
 [FKIdCuentaContable_CONTA] int NULL,
 [FKIdUnidades_ALMA] int NULL,
 [FKIdLocalizacion_ALMA] int NULL,
 [CodigoClave] nvarchar(200) COLLATE Modern_Spanish_CI_AS NULL,
 [Descripcion] nvarchar(1200) COLLATE Modern_Spanish_CI_AS NULL,
 [DepreciacionAnual] decimal(18,4) NULL,
 [Consecutivo] int NULL,
 [CABMS] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [Identificador] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [ExistenciaMinima] decimal(18,4) NULL,
 [ExistenciaMaxima] decimal(18,4) NULL,
 [TiempoVida] int NULL,
 [Pk_IdTratadoInt] int NULL,
 [Cuota] numeric(8,2) NULL,
 [ProveeduriaNac] bit NULL,
 [CatalogoBasico] bit NULL,
 [CUCOP_PLUS] varchar(25) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime NULL,
 [UsuarioModificacion] int NULL,
 [FKIdUnidades_Equivalente] int NULL,
 [Cantidad_Equivalente] int NULL,
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK_TipoBien] PRIMARY KEY CLUSTERED ([PKIdTipoBien] ASC)
);
GO
CREATE TABLE [ALMA].[TipoConteo] (
 [PKIdTipoConteo] int IDENTITY(1,1) NOT NULL,
 [Nombre] nvarchar(30) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(100) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 CONSTRAINT [PK_TipoConteo] PRIMARY KEY CLUSTERED ([PKIdTipoConteo] ASC)
);
GO
CREATE TABLE [ALMA].[TipoPatrimonio] (
 [PKIdTipoPatrimonio] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_TipoPatrimonio] PRIMARY KEY CLUSTERED ([PKIdTipoPatrimonio] ASC)
);
GO
CREATE TABLE [ALMA].[Transferencia] (
 [IdTransferencia] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdAlmacenOrigen] bigint NOT NULL,
 [IdAlmacenDestino] bigint NOT NULL,
 [IdAlmacenTransito] bigint NOT NULL,
 [IdOperacion] bigint NOT NULL,
 [Folio] nvarchar(60) NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_ALMA_Transferencia_IdTransferencia] PRIMARY KEY CLUSTERED ([IdTransferencia] ASC)
);
GO
CREATE TABLE [ALMA].[TransferenciaDetalle] (
 [IdTransferenciaDetalle] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdTransferencia] bigint NOT NULL,
 [IdTipoBien] int NOT NULL,
 [CantidadSolicitada] decimal(20,4) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_ALMA_TransferenciaDetalle_IdTransferenciaDetalle] PRIMARY KEY CLUSTERED ([IdTransferenciaDetalle] ASC)
);
GO
CREATE TABLE [ALMA].[UbicacionAlmacen] (
 [IdUbicacionAlmacen] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdAlmacen] bigint NOT NULL,
 [Codigo] nvarchar(40) NOT NULL,
 [Zona] nvarchar(40) NULL,
 [Pasillo] nvarchar(40) NULL,
 [Anaquel] nvarchar(40) NULL,
 [Activo] bit NOT NULL DEFAULT 1,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_ALMA_UbicacionAlmacen_IdUbicacionAlmacen] PRIMARY KEY CLUSTERED ([IdUbicacionAlmacen] ASC)
);
GO
CREATE TABLE [ALMA].[Unidades] (
 [PKIdUnidades] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Unidades] PRIMARY KEY CLUSTERED ([PKIdUnidades] ASC)
);
GO
CREATE TABLE [ALMA].[UsuarioAlmacen] (
 [IdUsuarioAlmacen] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdUsuario] int NOT NULL,
 [IdAlmacen] bigint NOT NULL,
 [PuedeConsultar] bit NOT NULL DEFAULT 1,
 [PuedeOperar] bit NOT NULL DEFAULT 0,
 [PuedeAutorizar] bit NOT NULL DEFAULT 0,
 [Activo] bit NOT NULL DEFAULT 1,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_ALMA_UsuarioAlmacen_IdUsuarioAlmacen] PRIMARY KEY CLUSTERED ([IdUsuarioAlmacen] ASC)
);
GO
CREATE TABLE [CAJA].[ArqueoCaja] (
 [IdArqueoCaja] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdFondo] bigint NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [SaldoTeorico] decimal(20,4) NOT NULL,
 [SaldoFisico] decimal(20,4) NOT NULL,
 [IdResponsable] bigint NOT NULL,
 [Observaciones] nvarchar(600) NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_CAJA_ArqueoCaja_IdArqueoCaja] PRIMARY KEY CLUSTERED ([IdArqueoCaja] ASC)
);
GO
CREATE TABLE [CAJA].[ArqueoDetalle] (
 [IdArqueoDetalle] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdArqueo] bigint NOT NULL,
 [Denominacion] decimal(20,4) NOT NULL,
 [Cantidad] int NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_CAJA_ArqueoDetalle_IdArqueoDetalle] PRIMARY KEY CLUSTERED ([IdArqueoDetalle] ASC)
);
GO
CREATE TABLE [CAJA].[ComprobacionCaja] (
 [IdComprobacionCaja] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdVale] bigint NOT NULL,
 [IdComprobanteGasto] bigint NOT NULL,
 [ImporteAceptado] decimal(20,4) NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_CAJA_ComprobacionCaja_IdComprobacionCaja] PRIMARY KEY CLUSTERED ([IdComprobacionCaja] ASC)
);
GO
CREATE TABLE [CAJA].[FondoCaja] (
 [IdFondoCaja] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdResponsable] bigint NOT NULL,
 [IdCentroCosto] bigint NOT NULL,
 [Codigo] nvarchar(30) NOT NULL,
 [IdMoneda] int NOT NULL,
 [MontoAutorizado] decimal(20,4) NOT NULL,
 [Activo] bit NOT NULL DEFAULT 1,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_CAJA_FondoCaja_IdFondoCaja] PRIMARY KEY CLUSTERED ([IdFondoCaja] ASC)
);
GO
CREATE TABLE [CAJA].[MovimientoFondo] (
 [IdMovimientoFondo] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdFondo] bigint NOT NULL,
 [IdOperacion] bigint NOT NULL,
 [IdVale] bigint NULL,
 [Tipo] varchar(20) NOT NULL,
 [Importe] decimal(20,4) NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [ClaveOperacion] uniqueidentifier NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 [IdMovimientoReversa] bigint NULL,
 [IdReposicion] bigint NULL,
 CONSTRAINT [UX_CAJA_MovimientoFondo_IdMovimientoFondo] PRIMARY KEY CLUSTERED ([IdMovimientoFondo] ASC)
);
GO
CREATE TABLE [CAJA].[ReposicionCaja] (
 [IdReposicionCaja] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdFondo] bigint NOT NULL,
 [IdOperacion] bigint NOT NULL,
 [Importe] decimal(20,4) NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_CAJA_ReposicionCaja_IdReposicionCaja] PRIMARY KEY CLUSTERED ([IdReposicionCaja] ASC)
);
GO
CREATE TABLE [CAJA].[ReposicionDetalle] (
 [IdReposicionDetalle] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdReposicion] bigint NOT NULL,
 [IdComprobacionCaja] bigint NOT NULL,
 [Importe] decimal(20,4) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_CAJA_ReposicionDetalle_IdReposicionDetalle] PRIMARY KEY CLUSTERED ([IdReposicionDetalle] ASC)
);
GO
CREATE TABLE [CAJA].[ValeCaja] (
 [IdValeCaja] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdFondo] bigint NOT NULL,
 [IdOperacion] bigint NOT NULL,
 [Importe] decimal(20,4) NOT NULL,
 [Fecha] date NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [Concepto] nvarchar(500) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_CAJA_ValeCaja_IdValeCaja] PRIMARY KEY CLUSTERED ([IdValeCaja] ASC)
);
GO
CREATE TABLE [CONTA].[Capitulo] (
 [PKIdCapitulo] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(30) COLLATE Modern_Spanish_CI_AS NULL,
 [Descripcion] nvarchar(120) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Capitulo] PRIMARY KEY CLUSTERED ([PKIdCapitulo] ASC)
);
GO
CREATE TABLE [CONTA].[Concepto] (
 [PKIdConcepto] int IDENTITY(1,1) NOT NULL,
 [FKIdCapitulo_CONTA] int NOT NULL,
 [Clave] nvarchar(30) COLLATE Modern_Spanish_CI_AS NULL,
 [Descripcion] nvarchar(120) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Concepto] PRIMARY KEY CLUSTERED ([PKIdConcepto] ASC)
);
GO
CREATE TABLE [CONTA].[ConsecutivoPoliza] (
 [PKIdConsecutivoPoliza] int IDENTITY(1,1) NOT NULL,
 [FK_IdAnio__SIS] int NOT NULL,
 [FK_IdMes__SIS] int NOT NULL,
 [FK_IdTipoPoliza__SIS] int NOT NULL,
 [UltimoValor] int NOT NULL DEFAULT ((0)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_ConsecutivoPoliza] PRIMARY KEY CLUSTERED ([PKIdConsecutivoPoliza] ASC)
);
GO
CREATE TABLE [CONTA].[CuentaContable] (
 [PKIdCuentaContable] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdTipoCuenta_CONTA] int NOT NULL,
 [Cuenta] nvarchar(5) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [SubCuenta] nvarchar(5) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [SubSubCuenta] nvarchar(5) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [SubSubSubCuenta] nvarchar(5) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [SubSubSubSubCuenta] nvarchar(5) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Saldo] numeric(18,2) NOT NULL,
 [Descripcion] varchar(250) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime NULL,
 [UsuarioModificacion] int NULL,
 [S5] nvarchar(5) COLLATE Modern_Spanish_CI_AS NULL,
 [S6] nvarchar(5) COLLATE Modern_Spanish_CI_AS NULL,
 [S7] nvarchar(5) COLLATE Modern_Spanish_CI_AS NULL,
 [ClaveOrd] varchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [Padre] varchar(10) COLLATE Modern_Spanish_CI_AS NULL,
 [Hijo] varchar(20) COLLATE Modern_Spanish_CI_AS NULL,
 [NivelCuenta] int NULL,
 [Cta_Coi] nvarchar(20) COLLATE Modern_Spanish_CI_AS NULL,
 [Desc_Coi] nvarchar(160) COLLATE Modern_Spanish_CI_AS NULL,
 [TipoCuenta] nchar(1) COLLATE Modern_Spanish_CI_AS NULL,
 [S8] nvarchar(5) COLLATE Modern_Spanish_CI_AS NULL,
 [S9] nvarchar(5) COLLATE Modern_Spanish_CI_AS NULL,
 [S10] nvarchar(5) COLLATE Modern_Spanish_CI_AS NULL,
 [IsCuentaDetalle] AS (case when [TipoCuenta]='D' then (1) else (0) end),
 [ClaveOrdNormalizada] AS (replace([ClaveOrd],N' ',N'')) PERSISTED,
 CONSTRAINT [PK_CuentaContable] PRIMARY KEY CLUSTERED ([PKIdCuentaContable] ASC)
);
GO
CREATE TABLE [CONTA].[CuentaEspecial] (
 [PKIdCuentaEspecial] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(120) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FKIdCuentaContable_CONTA] int NOT NULL,
 [Descripcion] nvarchar(300) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL DEFAULT ((1)),
 [FechaModificacion] datetime2(0) NULL,
 [UsuarioModificacion] int NULL,
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK_CuentaEspecial] PRIMARY KEY CLUSTERED ([PKIdCuentaEspecial] ASC)
);
GO
CREATE TABLE [CONTA].[Hist_SaldoMensual] (
 [PKIdHistSaldoMensual] int IDENTITY(1,1) NOT NULL,
 [FKIdCuenta] int NULL,
 [FKIdAnio_SIS] int NULL,
 [FKIdMes_SIS] int NULL,
 [Anio] int NULL,
 [Mes] varchar(25) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Cuentastr] varchar(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [NombreCta] varchar(500) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Cuentastr_Esp] varchar(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [NombreCta_Esp] varchar(500) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [SaldoInicial] decimal(18,0) NULL,
 [Cargos] decimal(18,0) NULL,
 [Abonos] decimal(18,0) NULL,
 [SaldoFinal] decimal(18,0) NULL,
 [FechaCreacion] datetime2(7) NULL,
 [nivel] int NULL,
 CONSTRAINT [PK_HistSaldoMensual] PRIMARY KEY CLUSTERED ([PKIdHistSaldoMensual] ASC)
);
GO
CREATE TABLE [CONTA].[MatrizConversion] (
 [PKIdMatrizConversion] int IDENTITY(1,1) NOT NULL,
 [FKIdAnio_SIS] int NOT NULL,
 [FKIdPrograma_PRES] int NOT NULL,
 [FKIdPartida_SIS] int NOT NULL,
 [FKIdCuentaContableAprobado] int NOT NULL,
 [FKIdCuentaContablePorEjercer] int NOT NULL,
 [FKIdCuentaContableModificado] int NOT NULL,
 [FKIdCuentaContableComprometido] int NOT NULL,
 [FKIdCuentaContableDevengado] int NOT NULL,
 [FKIdCuentaContableEjercido] int NOT NULL,
 [FKIdCuentaContablePagado] int NOT NULL,
 [FKIdCuentaContableGasto] int NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [FKIdTipoGasto_PRES] int NOT NULL,
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK_MatrizConversion] PRIMARY KEY CLUSTERED ([PKIdMatrizConversion] ASC)
);
GO
CREATE TABLE [CONTA].[MatrizIngreso] (
 [Pk_IdMatrizIngreso] int IDENTITY(1,1) NOT NULL,
 [Fk_IdPrograma] int NULL,
 [Fk_IdOrigen] int NULL,
 [Fk_IdCuentaContableAutorizado] int NULL,
 [Fk_IdCuentaContablePorEjercer] int NULL,
 [Fk_IdCuentaContableModificado] int NULL,
 [Fk_IdCuentaContableDevengado] int NULL,
 [Fk_IdCuentaContableRecaudado] int NULL,
 [Fk_IdCuentaContableDeposito] int NULL,
 [FK_IdAnio__SIS] int NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK_MatrizIngreso] PRIMARY KEY CLUSTERED ([Pk_IdMatrizIngreso] ASC)
);
GO
CREATE TABLE [CONTA].[MesActual] (
 [PKIdMesActual] int IDENTITY(1,1) NOT NULL,
 [FKIdAnio_SIS] int NOT NULL,
 [FKIdMes_SIS] int NOT NULL,
 [Actual] tinyint NOT NULL,
 [UsuarioCreacion] int NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioModificacion] int NULL,
 [FechaModificacion] datetime2(7) NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 CONSTRAINT [PK_MesActual] PRIMARY KEY CLUSTERED ([PKIdMesActual] ASC)
);
GO
CREATE TABLE [CONTA].[Partida] (
 [PKIdPartida] int IDENTITY(1,1) NOT NULL,
 [FKIdConcepto_SIS] int NULL,
 [Clave] nvarchar(10) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(255) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Partida] PRIMARY KEY CLUSTERED ([PKIdPartida] ASC)
);
GO
CREATE TABLE [CONTA].[Poliza] (
 [PKIdPoliza] int IDENTITY(1,1) NOT NULL,
 [FKIdAnio_SIS] int NOT NULL,
 [FKIdMes_SIS] int NOT NULL,
 [FKIdTipoPoliza_SIS] int NOT NULL,
 [ClavePoliza] nvarchar(30) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [NombrePoliza] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FechaPoliza] datetime NOT NULL,
 [EstaBalanceado] bit NOT NULL DEFAULT ((0)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [PermitirModificar] bit NULL,
 [FKIdAccionAutorizar_SIS] int NULL,
 [Autorizado] bit NULL,
 [FechaSolicitud] datetime NULL,
 [FechaAutorizacion] datetime NULL,
 [RowVersion] rowversion NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdOperacion] bigint NULL,
 [IdPolizaReversa] int NULL,
 CONSTRAINT [PK_Poliza] PRIMARY KEY CLUSTERED ([PKIdPoliza] ASC)
);
GO
CREATE TABLE [CONTA].[PolizaDetalle] (
 [PKIdPolizaDetalle] int IDENTITY(1,1) NOT NULL,
 [FKIdCuentaContable_CONTA] int NOT NULL,
 [FKIdPoliza_CONTA] int NOT NULL,
 [Descripcion] nvarchar(600) COLLATE Modern_Spanish_CI_AS NULL,
 [ImporteDebe] decimal(20,4) NULL,
 [ImporteHaber] decimal(20,4) NULL,
 [FKIdReferencia] int NULL,
 [FKIdTipoDetallePoliza_SIS] int NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK_PolizaDetalle] PRIMARY KEY CLUSTERED ([PKIdPolizaDetalle] ASC)
);
GO
CREATE TABLE [CONTA].[SaldoMensual] (
 [PKIdSaldoMensual] int IDENTITY(1,1) NOT NULL,
 [FKIdAnio_SIS] int NOT NULL,
 [FKIdMes_SIS] int NOT NULL,
 [FKIdCuentaContable] int NOT NULL,
 [SaldoInicial] decimal(20,2) NULL,
 [Cargos] decimal(20,2) NULL,
 [Abonos] decimal(20,2) NULL,
 [SaldoFinal] decimal(20,2) NULL,
 [UsuarioCreacion] int NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioModificacion] int NULL,
 [FechaModificacion] datetime2(7) NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 CONSTRAINT [PK_SaldoMensual] PRIMARY KEY CLUSTERED ([PKIdSaldoMensual] ASC)
);
GO
CREATE TABLE [CONTA].[TipoCuenta] (
 [PKIdTipoCuenta] int IDENTITY(1,1) NOT NULL,
 [Color] nvarchar(5) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(25) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_TipoCuenta] PRIMARY KEY CLUSTERED ([PKIdTipoCuenta] ASC)
);
GO
CREATE TABLE [CONTA].[TipoDoctoPago] (
 [PKIdTipoDoctoPago] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_TipoDoctoPago] PRIMARY KEY CLUSTERED ([PKIdTipoDoctoPago] ASC)
);
GO
CREATE TABLE [CTL].[CasoRiesgo] (
 [IdCasoRiesgo] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdRegla] bigint NOT NULL,
 [IdOperacion] bigint NOT NULL,
 [IdDocumentoEvidencia] bigint NULL,
 [Descripcion] nvarchar(1500) NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [AbiertoUtc] datetime2(7) NOT NULL,
 [CerradoUtc] datetime2(7) NULL,
 [IdResponsable] bigint NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_CTL_CasoRiesgo_IdCasoRiesgo] PRIMARY KEY CLUSTERED ([IdCasoRiesgo] ASC)
);
GO
CREATE TABLE [CTL].[ReglaRiesgo] (
 [IdReglaRiesgo] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [Codigo] nvarchar(40) NOT NULL,
 [Version] int NOT NULL,
 [Escenario] nvarchar(300) NOT NULL,
 [ParametrosJson] nvarchar(max) NOT NULL,
 [Desde] date NOT NULL,
 [Hasta] date NULL,
 [Activo] bit NOT NULL DEFAULT 1,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_CTL_ReglaRiesgo_IdReglaRiesgo] PRIMARY KEY CLUSTERED ([IdReglaRiesgo] ASC)
);
GO
CREATE TABLE [CTL].[ReglaSegregacion] (
 [IdReglaSegregacion] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [Codigo] nvarchar(40) NOT NULL,
 [AccionA] nvarchar(120) NOT NULL,
 [AccionB] nvarchar(120) NOT NULL,
 [Desde] date NOT NULL,
 [Hasta] date NULL,
 [Activo] bit NOT NULL DEFAULT 1,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_CTL_ReglaSegregacion_IdReglaSegregacion] PRIMARY KEY CLUSTERED ([IdReglaSegregacion] ASC)
);
GO
CREATE TABLE [CUM].[CatalogoObligacion] (
 [IdCatalogoObligacion] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [Codigo] nvarchar(40) NOT NULL,
 [Nombre] nvarchar(200) NOT NULL,
 [Tipo] varchar(30) NOT NULL,
 [Jurisdiccion] nvarchar(150) NOT NULL,
 [Periodicidad] varchar(30) NOT NULL,
 [Activo] bit NOT NULL DEFAULT 1,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_CUM_CatalogoObligacion_IdCatalogoObligacion] PRIMARY KEY CLUSTERED ([IdCatalogoObligacion] ASC)
);
GO
CREATE TABLE [CUM].[EvidenciaCumplimiento] (
 [IdEvidenciaCumplimiento] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdVencimiento] bigint NOT NULL,
 [IdDocumento] bigint NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [EstadoValidacion] varchar(20) NOT NULL,
 [IdResponsable] bigint NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_CUM_EvidenciaCumplimiento_IdEvidenciaCumplimiento] PRIMARY KEY CLUSTERED ([IdEvidenciaCumplimiento] ASC)
);
GO
CREATE TABLE [CUM].[ObligacionEmpresa] (
 [IdObligacionEmpresa] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdCatalogo] bigint NOT NULL,
 [IdResponsable] bigint NOT NULL,
 [IdSucursal] int NULL,
 [Desde] date NOT NULL,
 [Hasta] date NULL,
 [Activo] bit NOT NULL DEFAULT 1,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_CUM_ObligacionEmpresa_IdObligacionEmpresa] PRIMARY KEY CLUSTERED ([IdObligacionEmpresa] ASC)
);
GO
CREATE TABLE [CUM].[VencimientoObligacion] (
 [IdVencimientoObligacion] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdObligacion] bigint NOT NULL,
 [Periodo] nvarchar(30) NOT NULL,
 [FechaLimite] datetime2(7) NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [IdOperacion] bigint NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_CUM_VencimientoObligacion_IdVencimientoObligacion] PRIMARY KEY CLUSTERED ([IdVencimientoObligacion] ASC)
);
GO
CREATE TABLE [DOC].[CampoExtraido] (
 [IdCampoExtraido] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdExtraccion] bigint NOT NULL,
 [Nombre] nvarchar(100) NOT NULL,
 [ValorDetectado] nvarchar(max) NULL,
 [Confianza] decimal(9,6) NULL,
 [ValorCorregido] nvarchar(max) NULL,
 [Validado] bit NOT NULL DEFAULT 0,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_DOC_CampoExtraido_IdCampoExtraido] PRIMARY KEY CLUSTERED ([IdCampoExtraido] ASC)
);
GO
CREATE TABLE [DOC].[ExtraccionDocumento] (
 [IdExtraccionDocumento] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdDocumento] bigint NOT NULL,
 [Motor] nvarchar(100) NOT NULL,
 [VersionMotor] nvarchar(60) NOT NULL,
 [EstadoRevision] varchar(20) NOT NULL,
 [IdUsuarioRevision] int NULL,
 [FechaRevision] datetime2(7) NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_DOC_ExtraccionDocumento_IdExtraccionDocumento] PRIMARY KEY CLUSTERED ([IdExtraccionDocumento] ASC)
);
GO
CREATE TABLE [DOC].[OperacionDocumento] (
 [IdOperacionDocumento] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdOperacion] bigint NOT NULL,
 [IdDocumento] bigint NOT NULL,
 [Rol] varchar(40) NOT NULL,
 [Clasificacion] varchar(30) NOT NULL,
 [VigenteDesde] datetime2(7) NOT NULL,
 [VigenteHasta] datetime2(7) NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_DOC_OperacionDocumento_IdOperacionDocumento] PRIMARY KEY CLUSTERED ([IdOperacionDocumento] ASC)
);
GO
CREATE TABLE [FIS].[ActualizacionRecargo] (
 [IdActualizacionRecargo] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdDeterminacion] bigint NOT NULL,
 [Periodo] nvarchar(30) NOT NULL,
 [ParametrosJson] nvarchar(max) NOT NULL,
 [Actualizacion] decimal(20,4) NOT NULL,
 [Recargo] decimal(20,4) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_ActualizacionRecargo_IdActualizacionRecargo] PRIMARY KEY CLUSTERED ([IdActualizacionRecargo] ASC)
);
GO
CREATE TABLE [FIS].[AuditoriaFiscal] (
 [IdAuditoriaFiscal] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [Autoridad] nvarchar(200) NOT NULL,
 [Periodo] nvarchar(100) NOT NULL,
 [Expediente] nvarchar(100) NOT NULL,
 [FechaInicio] date NOT NULL,
 [FechaFin] date NULL,
 [Estado] varchar(20) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_AuditoriaFiscal_IdAuditoriaFiscal] PRIMARY KEY CLUSTERED ([IdAuditoriaFiscal] ASC)
);
GO
CREATE TABLE [FIS].[Cfdi] (
 [IdCfdi] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [UUID] uniqueidentifier NOT NULL,
 [Tipo] char(1) NOT NULL,
 [RFCEmisor] varchar(13) NOT NULL,
 [RFCReceptor] varchar(13) NOT NULL,
 [FechaEmision] datetime2(7) NOT NULL,
 [IdMoneda] int NOT NULL,
 [Subtotal] decimal(20,4) NOT NULL,
 [Total] decimal(20,4) NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [IdDocumentoXml] bigint NOT NULL,
 [IdDocumentoPdf] bigint NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_Cfdi_IdCfdi] PRIMARY KEY CLUSTERED ([IdCfdi] ASC)
);
GO
CREATE TABLE [FIS].[CfdiConcepto] (
 [IdCfdiConcepto] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdCfdi] bigint NOT NULL,
 [Renglon] int NOT NULL,
 [ClaveProductoServicio] varchar(12) NOT NULL,
 [ClaveUnidad] varchar(10) NOT NULL,
 [Descripcion] nvarchar(1000) NOT NULL,
 [Cantidad] decimal(20,4) NOT NULL,
 [ValorUnitario] decimal(20,4) NOT NULL,
 [Importe] decimal(20,4) NOT NULL,
 [Descuento] decimal(20,4) NOT NULL DEFAULT 0,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_CfdiConcepto_IdCfdiConcepto] PRIMARY KEY CLUSTERED ([IdCfdiConcepto] ASC)
);
GO
CREATE TABLE [FIS].[CfdiImpuesto] (
 [IdCfdiImpuesto] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdCfdiConcepto] bigint NOT NULL,
 [CodigoImpuesto] varchar(3) NOT NULL,
 [Tipo] varchar(12) NOT NULL,
 [TipoFactor] varchar(10) NOT NULL,
 [Base] decimal(20,4) NOT NULL,
 [TasaOCuota] decimal(18,6) NULL,
 [Importe] decimal(20,4) NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_CfdiImpuesto_IdCfdiImpuesto] PRIMARY KEY CLUSTERED ([IdCfdiImpuesto] ASC)
);
GO
CREATE TABLE [FIS].[ComprobanteGasto] (
 [IdComprobanteGasto] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdDocumento] bigint NOT NULL,
 [IdCfdi] bigint NULL,
 [Fecha] date NOT NULL,
 [IdMoneda] int NOT NULL,
 [Total] decimal(20,4) NOT NULL,
 [Concepto] nvarchar(500) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_ComprobanteGasto_IdComprobanteGasto] PRIMARY KEY CLUSTERED ([IdComprobanteGasto] ASC)
);
GO
CREATE TABLE [FIS].[Declaracion] (
 [IdDeclaracion] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdVencimiento] bigint NOT NULL,
 [Tipo] varchar(40) NOT NULL,
 [Ejercicio] smallint NOT NULL,
 [Periodo] nvarchar(30) NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_Declaracion_IdDeclaracion] PRIMARY KEY CLUSTERED ([IdDeclaracion] ASC)
);
GO
CREATE TABLE [FIS].[DeclaracionCfdi] (
 [IdDeclaracionCfdi] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdDeclaracionVersion] bigint NOT NULL,
 [IdCfdi] bigint NOT NULL,
 [Importe] decimal(20,4) NOT NULL,
 [Criterio] nvarchar(500) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_DeclaracionCfdi_IdDeclaracionCfdi] PRIMARY KEY CLUSTERED ([IdDeclaracionCfdi] ASC)
);
GO
CREATE TABLE [FIS].[DeclaracionVersion] (
 [IdDeclaracionVersion] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdDeclaracion] bigint NOT NULL,
 [Version] int NOT NULL,
 [Complementaria] bit NOT NULL DEFAULT 0,
 [Fecha] datetime2(7) NOT NULL,
 [IdDocumentoAcuse] bigint NULL,
 [IdUsuarioValidacion] int NULL,
 [ValidadaUtc] datetime2(7) NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_DeclaracionVersion_IdDeclaracionVersion] PRIMARY KEY CLUSTERED ([IdDeclaracionVersion] ASC)
);
GO
CREATE TABLE [FIS].[DeterminacionImpuesto] (
 [IdDeterminacionImpuesto] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdDeclaracionVersion] bigint NOT NULL,
 [IdReglaFiscalVersion] bigint NOT NULL,
 [Base] decimal(20,4) NOT NULL,
 [ImporteImpuesto] decimal(20,4) NOT NULL,
 [ResultadoJson] nvarchar(max) NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_DeterminacionImpuesto_IdDeterminacionImpuesto] PRIMARY KEY CLUSTERED ([IdDeterminacionImpuesto] ASC)
);
GO
CREATE TABLE [FIS].[EventoCfdi] (
 [IdEventoCfdi] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdCfdi] bigint NOT NULL,
 [Tipo] varchar(30) NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [IdDocumentoAcuse] bigint NULL,
 [ClaveOperacion] uniqueidentifier NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_EventoCfdi_IdEventoCfdi] PRIMARY KEY CLUSTERED ([IdEventoCfdi] ASC)
);
GO
CREATE TABLE [FIS].[ObservacionFiscal] (
 [IdObservacionFiscal] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdAuditoria] bigint NOT NULL,
 [Descripcion] nvarchar(1500) NOT NULL,
 [Vencimiento] date NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [IdDocumentoEvidencia] bigint NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_ObservacionFiscal_IdObservacionFiscal] PRIMARY KEY CLUSTERED ([IdObservacionFiscal] ASC)
);
GO
CREATE TABLE [FIS].[ReglaFiscalVersion] (
 [IdReglaFiscalVersion] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [Impuesto] varchar(40) NOT NULL,
 [Version] int NOT NULL,
 [ParametrosJson] nvarchar(max) NOT NULL,
 [Fuente] nvarchar(1000) NOT NULL,
 [Desde] date NOT NULL,
 [Hasta] date NULL,
 [IdUsuarioAprobacion] int NULL,
 [AprobadaUtc] datetime2(7) NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_ReglaFiscalVersion_IdReglaFiscalVersion] PRIMARY KEY CLUSTERED ([IdReglaFiscalVersion] ASC)
);
GO
CREATE TABLE [FIS].[SancionFiscal] (
 [IdSancionFiscal] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdObservacion] bigint NOT NULL,
 [Concepto] nvarchar(500) NOT NULL,
 [Importe] decimal(20,4) NOT NULL,
 [Vencimiento] date NOT NULL,
 [IdMoneda] int NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_SancionFiscal_IdSancionFiscal] PRIMARY KEY CLUSTERED ([IdSancionFiscal] ASC)
);
GO
CREATE TABLE [FIS].[ValidacionCfdi] (
 [IdValidacionCfdi] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdCfdi] bigint NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [Fuente] nvarchar(150) NOT NULL,
 [Resultado] nvarchar(500) NOT NULL,
 [IdDocumentoEvidencia] bigint NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_FIS_ValidacionCfdi_IdValidacionCfdi] PRIMARY KEY CLUSTERED ([IdValidacionCfdi] ASC)
);
GO
CREATE TABLE [NOM].[Persona] (
 [PKIdPersona] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(30) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Iniciales] nvarchar(6) COLLATE Modern_Spanish_CI_AS NULL,
 [Nombre] nvarchar(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Paterno] nvarchar(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Materno] nvarchar(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Sexo] nvarchar(20) COLLATE Modern_Spanish_CI_AS NULL,
 [FechaNacimiento] datetime NOT NULL,
 [ESTADO_CIVIL] nvarchar(40) COLLATE Modern_Spanish_CI_AS NULL,
 [RFC] nvarchar(30) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Curp] nvarchar(36) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [REG_IMSS] nvarchar(24) COLLATE Modern_Spanish_CI_AS NULL,
 [NoCartilla] nvarchar(32) COLLATE Modern_Spanish_CI_AS NULL,
 [NoLicencia] nvarchar(32) COLLATE Modern_Spanish_CI_AS NULL,
 [NoPasaporte] nvarchar(32) COLLATE Modern_Spanish_CI_AS NULL,
 [NoCredencialElector] nvarchar(64) COLLATE Modern_Spanish_CI_AS NULL,
 [Gafete] nvarchar(22) COLLATE Modern_Spanish_CI_AS NULL,
 [CORREO_ELECTRONICO] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [Telefono_particular] nvarchar(30) COLLATE Modern_Spanish_CI_AS NULL,
 [Telefono_movil] nvarchar(30) COLLATE Modern_Spanish_CI_AS NULL,
 [Calle] nvarchar(80) COLLATE Modern_Spanish_CI_AS NULL,
 [Num_exterior] nvarchar(20) COLLATE Modern_Spanish_CI_AS NULL,
 [Num_interior] nvarchar(20) COLLATE Modern_Spanish_CI_AS NULL,
 [Colonia] nvarchar(80) COLLATE Modern_Spanish_CI_AS NULL,
 [CP] nvarchar(12) COLLATE Modern_Spanish_CI_AS NULL,
 [Municipio] nvarchar(40) COLLATE Modern_Spanish_CI_AS NULL,
 [Estado] nvarchar(60) COLLATE Modern_Spanish_CI_AS NULL,
 [Fecha_de_Inicio] datetime NOT NULL,
 [Fecha_Fin] datetime NULL,
 [TIPO_CONTRATACION] nvarchar(100) COLLATE Modern_Spanish_CI_AS NULL,
 [PUESTO] nvarchar(200) COLLATE Modern_Spanish_CI_AS NULL,
 [SUELDO_BASE] float NULL,
 [COMPENSACION_GARANTIZADA] float NULL,
 [BANCO] nvarchar(200) COLLATE Modern_Spanish_CI_AS NULL,
 [NUMERO_CUENTA] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [CLABE] nvarchar(100) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [FKIdEmpresa_SIS] int NULL,
 CONSTRAINT [PK__Persona__5A5C9A1C303374D6] PRIMARY KEY CLUSTERED ([PKIdPersona] ASC)
);
GO
CREATE TABLE [NOM].[PersonaArea] (
 [PKIdPersonaArea] int IDENTITY(1,1) NOT NULL,
 [FKIdPersona_NOM] int NOT NULL,
 [FKIdArea_SIS] int NOT NULL,
 [IsAdscrito] bit NOT NULL,
 [EsSolicitante] bit NULL,
 [EsAutorizador] bit NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK__PersonaA__78C2DB89020D96DF] PRIMARY KEY CLUSTERED ([PKIdPersonaArea] ASC)
);
GO
CREATE TABLE [ORCO].[Articulo] (
 [PKIdArticulo] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(20) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(250) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Articulo] PRIMARY KEY CLUSTERED ([PKIdArticulo] ASC)
);
GO
CREATE TABLE [ORCO].[Contratos] (
 [PKIdContrato] int IDENTITY(1,1) NOT NULL,
 [FKIdOrdenCompra_ORCO] int NULL,
 [FKIdTipoContrato_ORCO] int NOT NULL,
 [FKIdTipoDocumento_ORCO] int NOT NULL,
 [FKIdArea_SIS] int NOT NULL,
 [FKIdTipoGarantia_ORCO] int NOT NULL,
 [FKIdProcedimientoContratacion_ORCO] int NOT NULL,
 [FKIdFundamentoJuridico_ORCO] int NULL,
 [FundamentoJuridico] nvarchar(max) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Numero] nvarchar(20) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(max) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FechaContrato] datetime NOT NULL,
 [FechaRecepcion] datetime NOT NULL,
 [FechaFirmaContrato] datetime NULL,
 [FechaVigenciaInicio] datetime NULL,
 [FechaVigenciaFin] datetime NULL,
 [FKIdModalidad_ORCO] int NOT NULL,
 [MontoMaximo] decimal(20,4) NOT NULL,
 [MontoMinimo] decimal(20,4) NULL,
 [Penalizacion] nvarchar(100) COLLATE Modern_Spanish_CI_AS NULL,
 [PlazoEjecucion] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FL_Archivo] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [Justificacion] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [FKIdArticulo_ORCO] int NULL,
 [FKIdFraccion_ORCO] int NULL,
 [SesionSubcomite] nvarchar(80) COLLATE Modern_Spanish_CI_AS NULL,
 [IsSesionExtraordinaria] bit NULL,
 [FechaSesionSubcomite] datetime NULL,
 [FKIdEstatusContrato_ORCO] int NOT NULL DEFAULT ((1)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL DEFAULT ((1)),
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [FKIdEmpresa_SIS] int NOT NULL DEFAULT ((1)),
 CONSTRAINT [PK_Contratos] PRIMARY KEY CLUSTERED ([PKIdContrato] ASC)
);
GO
CREATE TABLE [ORCO].[Cotizacion] (
 [PKIdCotizacion] int IDENTITY(1,1) NOT NULL,
 [FKIdRequisicion_ORCO] int NOT NULL,
 [FKIdProveedor_SIS] int NOT NULL,
 [FechaSolicitud] datetime NOT NULL,
 [FechaProveedorCotiza] datetime NULL,
 [FechaProveedorCompromiso] datetime NULL,
 [Comentarios] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [Servicio] bit NOT NULL DEFAULT ((0)),
 [FL_Documento] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [Entrega] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [Vigencia] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [Condiciones] nvarchar(200) COLLATE Modern_Spanish_CI_AS NULL,
 [FKIdAnio_SIS] int NULL,
 [FKIdContenedorCot_ORCO] int NULL,
 [FKIdContenedorMultiCot_ORCO] int NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK_Cotizacion] PRIMARY KEY CLUSTERED ([PKIdCotizacion] ASC)
);
GO
CREATE TABLE [ORCO].[CotizacionDetalle] (
 [PKIdCotizacionDetalle] int IDENTITY(1,1) NOT NULL,
 [FKIdCotizacion_ORCO] int NOT NULL,
 [FKIdRequisicionDetalle_ORCO] int NOT NULL,
 [PrecioUnitario] decimal(20,4) NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK_CotizacionDetalle] PRIMARY KEY CLUSTERED ([PKIdCotizacionDetalle] ASC)
);
GO
CREATE TABLE [ORCO].[CriterioEvaluacion] (
 [IdCriterioEvaluacion] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [Codigo] nvarchar(30) NOT NULL,
 [Version] int NOT NULL,
 [Nombre] nvarchar(180) NOT NULL,
 [Peso] decimal(9,6) NOT NULL,
 [Desde] date NOT NULL,
 [Hasta] date NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_ORCO_CriterioEvaluacion_IdCriterioEvaluacion] PRIMARY KEY CLUSTERED ([IdCriterioEvaluacion] ASC)
);
GO
CREATE TABLE [ORCO].[CuentaProveedor] (
 [IdCuentaProveedor] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdProveedorEmpresa] bigint NOT NULL,
 [IdBanco] int NOT NULL,
 [CLABE] char(18) NOT NULL,
 [Titular] nvarchar(200) NOT NULL,
 [EstadoValidacion] varchar(20) NOT NULL,
 [ValidadaUtc] datetime2(7) NULL,
 [IdUsuarioValidacion] int NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_ORCO_CuentaProveedor_IdCuentaProveedor] PRIMARY KEY CLUSTERED ([IdCuentaProveedor] ASC)
);
GO
CREATE TABLE [ORCO].[DestinoOrdenCompra] (
 [IdDestinoOrdenCompra] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdOrdenCompraDetalle] int NOT NULL,
 [IdAlmacen] bigint NULL,
 [IdCentroCosto] bigint NULL,
 [Cantidad] decimal(18,4) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_ORCO_DestinoOrdenCompra_IdDestinoOrdenCompra] PRIMARY KEY CLUSTERED ([IdDestinoOrdenCompra] ASC)
);
GO
CREATE TABLE [ORCO].[EstatusContrato] (
 [PKIdEstatusContrato] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Color] nvarchar(8) COLLATE Modern_Spanish_CI_AS NULL,
 [Orden] int NOT NULL DEFAULT ((0)),
 [Icono] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL DEFAULT ((1)),
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_EstatusContrato] PRIMARY KEY CLUSTERED ([PKIdEstatusContrato] ASC)
);
GO
CREATE TABLE [ORCO].[EstatusOrdenCompra] (
 [PK_IdEstatusOrdenCompra] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Color] nvarchar(8) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [CT_CreatedBy] int NOT NULL,
 [CT_CreatedDate] datetime NOT NULL,
 [CT_ModifiedBy] int NULL,
 [CT_ModifiedDate] datetime NULL,
 [CT_LIVE] bit NULL,
 CONSTRAINT [PK_EstatusOrdenCompra] PRIMARY KEY CLUSTERED ([PK_IdEstatusOrdenCompra] ASC)
);
GO
CREATE TABLE [ORCO].[EstatusRequisicion] (
 [PKIdEstatusRequisicion] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Color] nvarchar(8) COLLATE Modern_Spanish_CI_AS NULL,
 [Orden] int NOT NULL DEFAULT ((0)),
 [Icono] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_EstatusRequisicion] PRIMARY KEY CLUSTERED ([PKIdEstatusRequisicion] ASC)
);
GO
CREATE TABLE [ORCO].[EstudioMercado] (
 [PKIdEstudioMercado] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdAnio_SIS] int NOT NULL,
 [Nombre] varchar(80) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [FechaSolicitud] datetime NOT NULL,
 [FechaCierre] datetime NULL,
 [FKIdResponsable_Responsable] bigint NOT NULL,
 [Estatus] int NOT NULL DEFAULT ((1)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_EstudioMercado] PRIMARY KEY CLUSTERED ([PKIdEstudioMercado] ASC)
);
GO
CREATE TABLE [ORCO].[EstudioMercadoDetalle] (
 [PKIdEstudioMercadoDetalle] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdEstudioMercado_ORCO] int NOT NULL,
 [FKIdPAAASDetalle_ORCO] int NOT NULL,
 [FKIdTipoBien_ALMA] int NOT NULL,
 [Cantidad] numeric(8,2) NOT NULL,
 [Observaciones] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [FKIdProveedor_SIS] int NULL,
 [CostoUnitario] decimal(20,4) NULL,
 CONSTRAINT [PK_EstudioMercadoDetalle] PRIMARY KEY CLUSTERED ([PKIdEstudioMercadoDetalle] ASC)
);
GO
CREATE TABLE [ORCO].[EstudioMercadoDetalleCosto] (
 [PKIdEstudioMercadoDetalleCosto] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdSolicitudCotizacion_ORCO] int NOT NULL,
 [FKIdEstudioMercadoDetalle_ORCO] int NOT NULL,
 [PrecioUnitario] decimal(20,4) NULL,
 [TiempoEntregaDias] int NULL,
 [Condiciones] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [FechaRespuesta] datetime NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_EstudioMercadoDetalleCosto] PRIMARY KEY CLUSTERED ([PKIdEstudioMercadoDetalleCosto] ASC)
);
GO
CREATE TABLE [ORCO].[EvaluacionFiscalProveedor] (
 [IdEvaluacionFiscalProveedor] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdProveedorEmpresa] bigint NOT NULL,
 [TipoConsulta] varchar(30) NOT NULL,
 [RFC] varchar(13) NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [Resultado] nvarchar(250) NOT NULL,
 [IdDocumentoEvidencia] bigint NULL,
 [Fuente] nvarchar(200) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_ORCO_EvaluacionFiscalProveedor_IdEvaluacionFiscalProveedor] PRIMARY KEY CLUSTERED ([IdEvaluacionFiscalProveedor] ASC)
);
GO
CREATE TABLE [ORCO].[EvaluacionOferta] (
 [IdEvaluacionOferta] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdCotizacionDetalle] int NOT NULL,
 [IdCriterio] bigint NOT NULL,
 [Puntuacion] decimal(9,4) NOT NULL,
 [IdDocumentoEvidencia] bigint NULL,
 [IdUsuarioEvaluacion] int NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_ORCO_EvaluacionOferta_IdEvaluacionOferta] PRIMARY KEY CLUSTERED ([IdEvaluacionOferta] ASC)
);
GO
CREATE TABLE [ORCO].[ExpedienteContratacionControl] (
 [PKIdExpedienteContratacionControl] bigint IDENTITY(1,1) NOT NULL,
 [TipoDocumento] nvarchar(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FolioProcedimiento] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [InvestigacionMercado] bit NOT NULL,
 [NumeroCotizaciones] smallint NOT NULL DEFAULT ((0)),
 [ValidacionNoFraccionamiento] bit NOT NULL,
 [ValidacionConflicto] bit NOT NULL,
 [ValidacionSanciones] bit NOT NULL,
 [ValidacionFiscal] bit NOT NULL,
 [Evidencia] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [HuellaEvidencia] varchar(64) COLLATE Modern_Spanish_CI_AS NULL,
 [FechaControl] datetime2(7) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioControl] int NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 CONSTRAINT [PK_ExpedienteContratacionControl] PRIMARY KEY CLUSTERED ([PKIdExpedienteContratacionControl] ASC)
);
GO
CREATE TABLE [ORCO].[Fraccion] (
 [PKIdFraccion] int IDENTITY(1,1) NOT NULL,
 [FKIdArticulo_ORCO] int NOT NULL,
 [Clave] nvarchar(20) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(250) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Fraccion] PRIMARY KEY CLUSTERED ([PKIdFraccion] ASC)
);
GO
CREATE TABLE [ORCO].[FundamentoJuridico] (
 [PKIdFundamentoJuridico] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL DEFAULT ((1)),
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_FundamentoJuridico] PRIMARY KEY CLUSTERED ([PKIdFundamentoJuridico] ASC)
);
GO
CREATE TABLE [ORCO].[FundamentoProcedimiento] (
 [PKIdFundamentoProcedimiento] bigint IDENTITY(1,1) NOT NULL,
 [FKIdProcedimientoContratacion_ORCO] int NOT NULL,
 [FKIdNormaJuridicaVersion_SIS] int NOT NULL,
 [Articulo] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Fraccion] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [Fundamento] nvarchar(2000) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Motivacion] nvarchar(4000) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [EsExcepcion] bit NOT NULL DEFAULT ((0)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 CONSTRAINT [PK_FundamentoProcedimiento] PRIMARY KEY CLUSTERED ([PKIdFundamentoProcedimiento] ASC)
);
GO
CREATE TABLE [ORCO].[Modalidad] (
 [PKIdModalidad] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(30) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Modalidad] PRIMARY KEY CLUSTERED ([PKIdModalidad] ASC)
);
GO
CREATE TABLE [ORCO].[OrdenCompra] (
 [PKIdOrdenCompra] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdRequisicion_ORCO] int NOT NULL,
 [FKIdProveedor_SIS] int NOT NULL,
 [FKIdPoliza_CONTA] int NULL,
 [FKIdEstatusOrdenCompra_ORCO] int NOT NULL,
 [NumeroOrdenCompra] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [FechaOrdenCompra] date NOT NULL,
 [FechaRequerida] date NULL,
 [FechaEntrega] date NULL,
 [FechaVigencia] date NULL,
 [FechaCancelacion] date NULL,
 [MotivoCancelacion] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [Subtotal] decimal(20,4) NOT NULL DEFAULT ((0)),
 [Iva] decimal(20,4) NOT NULL DEFAULT ((0)),
 [Total] decimal(20,4) NOT NULL DEFAULT ((0)),
 [MonedaId] int NULL,
 [TipoCambio] decimal(18,6) NULL,
 [Observaciones] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [CompraDirecta] bit NOT NULL DEFAULT ((0)),
 [FL_Documento] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [RowVersion] rowversion NOT NULL,
 [FKIdCotizacion_ORCO] int NULL,
 [IdOperacion] bigint NOT NULL,
 CONSTRAINT [PK_OrdenCompra] PRIMARY KEY CLUSTERED ([PKIdOrdenCompra] ASC)
);
GO
CREATE TABLE [ORCO].[OrdenCompraDetalle] (
 [PKIdOrdenCompraDetalle] int IDENTITY(1,1) NOT NULL,
 [FKIdOrdenCompra_ORCO] int NOT NULL,
 [FKIdRequisicionDetalle_ORCO] int NULL,
 [FKIdCotizacionDetalle_ORCO] int NULL,
 [FKIdTipoBien_ALMA] int NOT NULL,
 [FKIdUnidades_ALMA] int NOT NULL,
 [CantidadSolicitada] decimal(18,4) NOT NULL,
 [CantidadRecibida] decimal(18,4) NOT NULL DEFAULT ((0)),
 [CantidadPendiente] AS ([CantidadSolicitada]-[CantidadRecibida]),
 [PrecioUnitario] decimal(20,4) NOT NULL,
 [Importe] AS ([CantidadSolicitada]*[PrecioUnitario]),
 [Iva] decimal(20,4) NOT NULL DEFAULT ((0)),
 [TotalDetalle] AS ([CantidadSolicitada]*[PrecioUnitario]+[Iva]),
 [Observaciones] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK_OrdenCompraDetalle] PRIMARY KEY CLUSTERED ([PKIdOrdenCompraDetalle] ASC)
);
GO
CREATE TABLE [ORCO].[OrdenCompraPartida] (
 [PKIdOrdenCompraPartida] int IDENTITY(1,1) NOT NULL,
 [FKIdOrdenCompra_ORCO] int NOT NULL,
 [FKIdPartida_CONTA] int NOT NULL,
 [FKIdFuenteFinanciamiento_PRES] int NULL,
 [Importe] decimal(20,4) NOT NULL,
 [Observaciones] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK_OrdenCompraPartida] PRIMARY KEY CLUSTERED ([PKIdOrdenCompraPartida] ASC)
);
GO
CREATE TABLE [ORCO].[PAAAS] (
 [PKIdPAAAS] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdAnio_SIS] int NOT NULL,
 [FKIdArea_SIS] int NOT NULL,
 [FKIdPersona_Responsable] bigint NOT NULL,
 [Descripcion] nvarchar(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Observaciones] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [Fecha] datetime NOT NULL,
 [FKIdProyecto_ORCO] int NULL,
 [FKIdPrograma_PRES] int NULL,
 [FKIdFuenteFinanciamiento_PRES] int NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_PAAAS] PRIMARY KEY CLUSTERED ([PKIdPAAAS] ASC)
);
GO
CREATE TABLE [ORCO].[PAAASDetalle] (
 [PKIdPAAASDetalle] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdPAAASPartida_ORCO] int NOT NULL,
 [FKIdTipoBien_ALMA] int NOT NULL,
 [FKIdUnidades_ALMA] int NULL,
 [Cantidad] numeric(8,2) NOT NULL,
 [Observaciones] nvarchar(max) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [LugarEntrega] varchar(200) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [FKIdMes_SIS] int NULL,
 CONSTRAINT [PK_PAAASDetalle] PRIMARY KEY CLUSTERED ([PKIdPAAASDetalle] ASC)
);
GO
CREATE TABLE [ORCO].[PAAASPartida] (
 [PKIdPAAASPartida] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdPAAAS_ORCO] int NOT NULL,
 [FKIdPartida_CONTA] int NOT NULL,
 [Observaciones] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_PAAASPartida] PRIMARY KEY CLUSTERED ([PKIdPAAASPartida] ASC)
);
GO
CREATE TABLE [ORCO].[ProcedimientoContratacion] (
 [PKIdProcedimientoContratacion] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FundamentoJuridico] text COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_ProcedimientoContratacion] PRIMARY KEY CLUSTERED ([PKIdProcedimientoContratacion] ASC)
);
GO
CREATE TABLE [ORCO].[ProveedorCumplimiento] (
 [PKIdProveedorCumplimiento] bigint IDENTITY(1,1) NOT NULL,
 [FKIdProveedor_ORCO] int NOT NULL,
 [FechaVerificacion] datetime2(7) NOT NULL,
 [VigenteHasta] datetime2(7) NULL,
 [CumplimientoFiscal] bit NOT NULL,
 [Inhabilitado] bit NOT NULL,
 [ConflictoInteres] bit NOT NULL,
 [DeclaracionIntegridad] bit NOT NULL,
 [FuenteConsulta] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FolioEvidencia] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [HuellaEvidencia] varchar(64) COLLATE Modern_Spanish_CI_AS NULL,
 [Observaciones] nvarchar(2000) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [UsuarioCreacion] int NOT NULL,
 CONSTRAINT [PK_ProveedorCumplimiento] PRIMARY KEY CLUSTERED ([PKIdProveedorCumplimiento] ASC)
);
GO
CREATE TABLE [ORCO].[Proyecto] (
 [PKIdProyecto] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(max) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Proyecto] PRIMARY KEY CLUSTERED ([PKIdProyecto] ASC)
);
GO
CREATE TABLE [ORCO].[Recepcion] (
 [IdRecepcion] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdOperacion] bigint NOT NULL,
 [Folio] nvarchar(60) NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [IdResponsable] bigint NOT NULL,
 [Estado] varchar(16) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_ORCO_Recepcion_IdRecepcion] PRIMARY KEY CLUSTERED ([IdRecepcion] ASC)
);
GO
CREATE TABLE [ORCO].[RecepcionDetalle] (
 [IdRecepcionDetalle] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdRecepcion] bigint NOT NULL,
 [IdDestinoOrdenCompra] bigint NOT NULL,
 [CantidadAceptada] decimal(18,4) NOT NULL,
 [CantidadRechazada] decimal(18,4) NOT NULL DEFAULT 0,
 [Tipo] varchar(10) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_ORCO_RecepcionDetalle_IdRecepcionDetalle] PRIMARY KEY CLUSTERED ([IdRecepcionDetalle] ASC)
);
GO
CREATE TABLE [ORCO].[Requisicion] (
 [PKIdRequisicion] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdPersona_Responsable] bigint NOT NULL,
 [FKIdArea_SIS] int NOT NULL,
 [Descripcion] nvarchar(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Observaciones] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [FechaRequisicion] datetime NOT NULL,
 [Servicio] bit NOT NULL,
 [FL_FOTO] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [FKIdProyecto_ORCO] int NULL,
 [FechaRequiereInicio] datetime NULL,
 [FechaRequiereFin] datetime NULL,
 [FKIdPrograma_PRES] int NULL,
 [Importe] decimal(20,4) NULL,
 [FKIdJefeAlmacen_Responsable] bigint NULL,
 [FKIdSuficiencia_PRES] int NULL,
 [FKIdSuperviso_Responsable] bigint NULL,
 [FKIdAutorizo_Responsable] bigint NULL,
 [FKIdPSolicita_Responsable] bigint NULL,
 [FKIdPJefeAlmacen_Responsable] bigint NULL,
 [FKIdPSuficiencia_Responsable] bigint NULL,
 [FKIdPSuperviso_Responsable] bigint NULL,
 [FKIdPAutorizo_Responsable] bigint NULL,
 [FKIdFuenteFinanciamiento_PRES] int NULL,
 [FKIdAnio_SIS] int NULL,
 [FKIdTipoGasto_PRES] int NULL,
 [FKIdDigitoIdentificador_PRES] int NULL,
 [FKIdDestinoGasto_PRES] int NULL,
 [FKIdEgresoAutorizado_PRES] int NULL,
 [Oficio] varchar(120) COLLATE Modern_Spanish_CI_AS NULL,
 [FechaOficio] datetime NULL,
 [CompraDirecta] bit NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [RowVersion] rowversion NOT NULL,
 [IdCentroCosto] bigint NOT NULL,
 [Prioridad] tinyint NOT NULL DEFAULT 2,
 [IdOperacion] bigint NOT NULL,
 CONSTRAINT [PK_Requisicion] PRIMARY KEY CLUSTERED ([PKIdRequisicion] ASC)
);
GO
CREATE TABLE [ORCO].[RequisicionDetalle] (
 [PKIdRequisicionDetalle] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdRequisicion_ORCO] int NOT NULL,
 [FKIdTipoBien_ALMA] int NOT NULL,
 [FKIdUnidades_ALMA] int NULL,
 [Cantidad] numeric(8,2) NOT NULL,
 [Observaciones] nvarchar(max) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_RequisicionDetalle] PRIMARY KEY CLUSTERED ([PKIdRequisicionDetalle] ASC)
);
GO
CREATE TABLE [ORCO].[RequisicionPartida] (
 [PKIdRequisicionPartida] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdRequisicion_ORCO] int NOT NULL,
 [FKIdPartida_CONTA] int NOT NULL,
 [Monto] decimal(20,4) NULL,
 [Observaciones] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [FKIdEgresoAutorizado_PRES] int NULL,
 CONSTRAINT [PK_RequisicionPartida] PRIMARY KEY CLUSTERED ([PKIdRequisicionPartida] ASC)
);
GO
CREATE TABLE [ORCO].[SolicitudCotizacion] (
 [PKIdSolicitudCotizacion] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdEstudioMercado_ORCO] int NOT NULL,
 [FKIdProveedor_SIS] int NOT NULL,
 [FechaSolicitud] datetime NOT NULL,
 [FechaCompromisoEntrega] datetime NULL,
 [Comentarios] text COLLATE Modern_Spanish_CI_AS NULL,
 [FL_Documento] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [Estatus] int NOT NULL DEFAULT ((1)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_SolicitudCotizacion] PRIMARY KEY CLUSTERED ([PKIdSolicitudCotizacion] ASC)
);
GO
CREATE TABLE [ORCO].[TipoContrato] (
 [PKIdTipoContrato] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(25) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_TipoContrato] PRIMARY KEY CLUSTERED ([PKIdTipoContrato] ASC)
);
GO
CREATE TABLE [ORCO].[TipoDocumento] (
 [PKIdTipoDocumento] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(25) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_TipoDocumento] PRIMARY KEY CLUSTERED ([PKIdTipoDocumento] ASC)
);
GO
CREATE TABLE [ORCO].[TipoGarantia] (
 [PKIdTipoGarantia] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(25) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_TipoGarantia] PRIMARY KEY CLUSTERED ([PKIdTipoGarantia] ASC)
);
GO
CREATE TABLE [PAG].[AplicacionNotaCredito] (
 [IdAplicacionNotaCredito] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdNotaCredito] bigint NOT NULL,
 [IdFactura] int NOT NULL,
 [Importe] decimal(20,4) NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [ClaveOperacion] uniqueidentifier NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 [IdAplicacionReversa] bigint NULL,
 CONSTRAINT [UX_PAG_AplicacionNotaCredito_IdAplicacionNotaCredito] PRIMARY KEY CLUSTERED ([IdAplicacionNotaCredito] ASC)
);
GO
CREATE TABLE [PAG].[AplicacionPago] (
 [IdAplicacionPago] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdPago] bigint NOT NULL,
 [IdCompromiso] bigint NOT NULL,
 [IdMoneda] int NOT NULL,
 [Importe] decimal(20,4) NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [ClaveOperacion] uniqueidentifier NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 [IdAplicacionReversa] bigint NULL,
 CONSTRAINT [UX_PAG_AplicacionPago_IdAplicacionPago] PRIMARY KEY CLUSTERED ([IdAplicacionPago] ASC)
);
GO
CREATE TABLE [PAG].[CompromisoPago] (
 [IdCompromisoPago] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdOperacion] bigint NOT NULL,
 [IdProveedorEmpresa] bigint NULL,
 [IdResponsable] bigint NULL,
 [BeneficiarioNombre] nvarchar(200) NOT NULL,
 [IdMoneda] int NOT NULL,
 [Importe] decimal(20,4) NOT NULL,
 [Vencimiento] date NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [IdFactura] int NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 [IdReposicionCaja] bigint NULL,
 [IdAnticipoViatico] bigint NULL,
 [IdVencimientoObligacion] bigint NULL,
 [IdSancionFiscal] bigint NULL,
 CONSTRAINT [UX_PAG_CompromisoPago_IdCompromisoPago] PRIMARY KEY CLUSTERED ([IdCompromisoPago] ASC)
);
GO
CREATE TABLE [PAG].[FacturaRecepcion] (
 [IdFacturaRecepcion] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdFacturaDetalle] int NOT NULL,
 [IdRecepcionDetalle] bigint NOT NULL,
 [Cantidad] decimal(20,4) NOT NULL,
 [ImporteConciliado] decimal(20,4) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_PAG_FacturaRecepcion_IdFacturaRecepcion] PRIMARY KEY CLUSTERED ([IdFacturaRecepcion] ASC)
);
GO
CREATE TABLE [PAG].[NotaCredito] (
 [IdNotaCredito] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdProveedorEmpresa] bigint NOT NULL,
 [IdCfdi] bigint NOT NULL,
 [IdMoneda] int NOT NULL,
 [Fecha] date NOT NULL,
 [Importe] decimal(20,4) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_PAG_NotaCredito_IdNotaCredito] PRIMARY KEY CLUSTERED ([IdNotaCredito] ASC)
);
GO
CREATE TABLE [PAG].[Pago] (
 [IdPago] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdOperacion] bigint NOT NULL,
 [IdCuentaBancaria] int NOT NULL,
 [IdMoneda] int NOT NULL,
 [IdProveedorEmpresa] bigint NULL,
 [IdResponsable] bigint NULL,
 [BeneficiarioNombre] nvarchar(200) NOT NULL,
 [Importe] decimal(20,4) NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [ClaveOperacion] uniqueidentifier NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_PAG_Pago_IdPago] PRIMARY KEY CLUSTERED ([IdPago] ASC)
);
GO
CREATE TABLE [PAG].[PagoPoliza] (
 [IdPagoPoliza] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdPago] bigint NOT NULL,
 [IdPoliza] int NOT NULL,
 [Tipo] varchar(20) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_PAG_PagoPoliza_IdPagoPoliza] PRIMARY KEY CLUSTERED ([IdPagoPoliza] ASC)
);
GO
CREATE TABLE [PAG].[ProgramacionPago] (
 [IdProgramacionPago] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdCompromiso] bigint NOT NULL,
 [Version] int NOT NULL,
 [FechaPrevista] date NOT NULL,
 [Prioridad] tinyint NOT NULL,
 [Motivo] nvarchar(500) NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_PAG_ProgramacionPago_IdProgramacionPago] PRIMARY KEY CLUSTERED ([IdProgramacionPago] ASC)
);
GO
CREATE TABLE [PAT].[DepreciacionBienPeriodo] (
 [IdDepreciacionBienPeriodo] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdBien] int NOT NULL,
 [IdPoliticaVersion] bigint NOT NULL,
 [IdPoliza] int NULL,
 [Ejercicio] smallint NOT NULL,
 [Mes] tinyint NOT NULL,
 [Base] decimal(20,4) NOT NULL,
 [Importe] decimal(20,4) NOT NULL,
 [Estado] varchar(16) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_PAT_DepreciacionBienPeriodo_IdDepreciacionBienPeriodo] PRIMARY KEY CLUSTERED ([IdDepreciacionBienPeriodo] ASC)
);
GO
CREATE TABLE [PAT].[HistorialUbicacionBien] (
 [IdHistorialUbicacionBien] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdBien] int NOT NULL,
 [IdUbicacionPatrimonial] bigint NULL,
 [IdUbicacionAlmacen] bigint NULL,
 [IdOperacion] bigint NOT NULL,
 [Desde] datetime2(7) NOT NULL,
 [Hasta] datetime2(7) NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_PAT_HistorialUbicacionBien_IdHistorialUbicacionBien] PRIMARY KEY CLUSTERED ([IdHistorialUbicacionBien] ASC)
);
GO
CREATE TABLE [PAT].[IdentificadorBien] (
 [IdIdentificadorBien] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdBien] int NOT NULL,
 [Tipo] varchar(10) NOT NULL,
 [Codigo] nvarchar(180) NOT NULL,
 [Desde] datetime2(7) NOT NULL,
 [Hasta] datetime2(7) NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_PAT_IdentificadorBien_IdIdentificadorBien] PRIMARY KEY CLUSTERED ([IdIdentificadorBien] ASC)
);
GO
CREATE TABLE [PAT].[InmuebleDetalle] (
 [IdInmuebleDetalle] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdBien] int NOT NULL,
 [ClaveCatastral] nvarchar(80) NULL,
 [Superficie] decimal(20,4) NULL,
 [Domicilio] nvarchar(500) NOT NULL,
 [DocumentoPropiedad] bigint NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_PAT_InmuebleDetalle_IdInmuebleDetalle] PRIMARY KEY CLUSTERED ([IdInmuebleDetalle] ASC)
);
GO
CREATE TABLE [PAT].[PoliticaDepreciacionVersion] (
 [IdPoliticaDepreciacionVersion] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [Codigo] nvarchar(40) NOT NULL,
 [Version] int NOT NULL,
 [Metodo] varchar(30) NOT NULL,
 [VidaUtilMeses] int NOT NULL,
 [PorcentajeResidual] decimal(9,6) NOT NULL,
 [Desde] date NOT NULL,
 [Hasta] date NULL,
 [IdUsuarioAprobacion] int NULL,
 [AprobadaUtc] datetime2(7) NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_PAT_PoliticaDepreciacionVersion_IdPoliticaDepreciacionVersion] PRIMARY KEY CLUSTERED ([IdPoliticaDepreciacionVersion] ASC)
);
GO
CREATE TABLE [PAT].[UbicacionPatrimonial] (
 [IdUbicacionPatrimonial] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdSucursal] int NOT NULL,
 [Codigo] nvarchar(40) NOT NULL,
 [Edificio] nvarchar(100) NULL,
 [Planta] nvarchar(50) NULL,
 [Espacio] nvarchar(100) NOT NULL,
 [Activo] bit NOT NULL DEFAULT 1,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_PAT_UbicacionPatrimonial_IdUbicacionPatrimonial] PRIMARY KEY CLUSTERED ([IdUbicacionPatrimonial] ASC)
);
GO
CREATE TABLE [PBR].[AuditoriaCambio] (
 [PKIdAuditoria] int IDENTITY(1,1) NOT NULL,
 [Entidad] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [EntidadId] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Accion] nvarchar(20) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FKIdUsuario_PBR] int NULL,
 [Cambios] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [Ip] nvarchar(100) COLLATE Modern_Spanish_CI_AS NULL,
 [FechaCreacion] datetime2(7) NOT NULL DEFAULT (getdate()),
 [IdEmpresa] int NOT NULL,
 [IdOperacion] bigint NULL,
 CONSTRAINT [PK_PBR_AuditoriaCambio] PRIMARY KEY CLUSTERED ([PKIdAuditoria] ASC)
);
GO
CREATE TABLE [PBR].[WorkflowEstado] (
 [PKIdWorkflowEstado] int IDENTITY(1,1) NOT NULL,
 [FKIdWorkflowTemplate_PBR] int NOT NULL,
 [Codigo] nvarchar(30) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Nombre] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Orden] int NOT NULL,
 [EsInicial] bit NOT NULL DEFAULT ((0)),
 [EsFinal] bit NOT NULL DEFAULT ((0)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK_PBR_WorkflowEstado] PRIMARY KEY CLUSTERED ([PKIdWorkflowEstado] ASC)
);
GO
CREATE TABLE [PBR].[WorkflowTemplate] (
 [PKIdWorkflowTemplate] int IDENTITY(1,1) NOT NULL,
 [Codigo] nvarchar(30) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Nombre] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NOT NULL DEFAULT (getdate()),
 [IdEmpresa] int NOT NULL,
 [Version] int NOT NULL DEFAULT 1,
 [VigenciaDesde] date NOT NULL,
 [VigenciaHasta] date NULL,
 CONSTRAINT [PK_PBR_WorkflowTemplate] PRIMARY KEY CLUSTERED ([PKIdWorkflowTemplate] ASC)
);
GO
CREATE TABLE [PBR].[WorkflowTransicion] (
 [PKIdWorkflowTransicion] int IDENTITY(1,1) NOT NULL,
 [FKIdWorkflowTemplate_PBR] int NOT NULL,
 [FKIdEstadoOrigen_PBR] int NOT NULL,
 [FKIdEstadoDestino_PBR] int NOT NULL,
 [Nombre] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [RolesPermitidos] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [RequiereFirma] bit NOT NULL DEFAULT ((0)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK_PBR_WorkflowTransicion] PRIMARY KEY CLUSTERED ([PKIdWorkflowTransicion] ASC)
);
GO
CREATE TABLE [PRES].[AccionAdecuacionMaster] (
 [PKIdAccionAdecuacionMaster] int IDENTITY(1,1) NOT NULL,
 [Accion] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Comentario] nvarchar(250) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL DEFAULT ((1)),
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_AccionAdecuacionMaster] PRIMARY KEY CLUSTERED ([PKIdAccionAdecuacionMaster] ASC)
);
GO
CREATE TABLE [PRES].[AutorizacionSuficiencia] (
 [PKIdAutorizacionSuficiencia] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdSolicitudSuficiencia_PRES] int NOT NULL,
 [FechaAutorizacion] date NOT NULL,
 [Justificacion] nvarchar(250) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [GastoNoProgramable] varchar(3) COLLATE Modern_Spanish_CI_AS NULL,
 [IdGastoNoProgramable] int NULL,
 [IdCompromisoNomina] int NULL,
 [AutorizadoPor_Responsable] bigint NOT NULL,
 [Observaciones] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [Estatus] int NOT NULL DEFAULT ((1)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_AutorizacionSuficiencia] PRIMARY KEY CLUSTERED ([PKIdAutorizacionSuficiencia] ASC)
);
GO
CREATE TABLE [PRES].[AutorizacionSuficienciaDetalle] (
 [PKIdAutorizacionSuficienciaDetalle] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdAutorizacionSuficiencia_PRES] int NOT NULL,
 [FKIdSolicitudSuficienciaDetalle_PRES] int NOT NULL,
 [FKIdPartida_CONTA] int NOT NULL,
 [Enero] decimal(20,4) NULL DEFAULT ((0)),
 [Febrero] decimal(20,4) NULL DEFAULT ((0)),
 [Marzo] decimal(20,4) NULL DEFAULT ((0)),
 [Abril] decimal(20,4) NULL DEFAULT ((0)),
 [Mayo] decimal(20,4) NULL DEFAULT ((0)),
 [Junio] decimal(20,4) NULL DEFAULT ((0)),
 [Julio] decimal(20,4) NULL DEFAULT ((0)),
 [Agosto] decimal(20,4) NULL DEFAULT ((0)),
 [Septiembre] decimal(20,4) NULL DEFAULT ((0)),
 [Octubre] decimal(20,4) NULL DEFAULT ((0)),
 [Noviembre] decimal(20,4) NULL DEFAULT ((0)),
 [Diciembre] decimal(20,4) NULL DEFAULT ((0)),
 [Total] AS (((((((((((isnull([Enero],(0))+isnull([Febrero],(0)))+isnull([Marzo],(0)))+isnull([Abril],(0)))+isnull([Mayo],(0)))+isnull([Junio],(0)))+isnull([Julio],(0)))+isnull([Agosto],(0)))+isnull([Septiembre],(0)))+isnull([Octubre],(0)))+isnull([Noviembre],(0)))+isnull([Diciembre],(0))),
 [Observaciones] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_AutorizacionSuficienciaDetalle] PRIMARY KEY CLUSTERED ([PKIdAutorizacionSuficienciaDetalle] ASC)
);
GO
CREATE TABLE [PRES].[CLC] (
 [PKIdCLC] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdContrato_PRES] int NOT NULL,
 [FKIdPoliza_CONTA] int NOT NULL,
 [NumCLC] nvarchar(20) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FechaSolicitud] date NOT NULL,
 [FechaAutorizacion] date NULL,
 [ImporteTotal] decimal(20,4) NOT NULL,
 [Observaciones] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [Estatus] int NOT NULL DEFAULT ((1)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [IdOperacion] bigint NOT NULL,
 CONSTRAINT [PK_CLC] PRIMARY KEY CLUSTERED ([PKIdCLC] ASC)
);
GO
CREATE TABLE [PRES].[CLCDetalle] (
 [PKIdCLCDetalle] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdCLC_PRES] int NOT NULL,
 [FKIdContratoDetalle_PRES] int NOT NULL,
 [FKIdPartida_CONTA] int NOT NULL,
 [Enero] decimal(20,4) NULL DEFAULT ((0)),
 [Febrero] decimal(20,4) NULL DEFAULT ((0)),
 [Marzo] decimal(20,4) NULL DEFAULT ((0)),
 [Abril] decimal(20,4) NULL DEFAULT ((0)),
 [Mayo] decimal(20,4) NULL DEFAULT ((0)),
 [Junio] decimal(20,4) NULL DEFAULT ((0)),
 [Julio] decimal(20,4) NULL DEFAULT ((0)),
 [Agosto] decimal(20,4) NULL DEFAULT ((0)),
 [Septiembre] decimal(20,4) NULL DEFAULT ((0)),
 [Octubre] decimal(20,4) NULL DEFAULT ((0)),
 [Noviembre] decimal(20,4) NULL DEFAULT ((0)),
 [Diciembre] decimal(20,4) NULL DEFAULT ((0)),
 [Total] AS (((((((((((isnull([Enero],(0))+isnull([Febrero],(0)))+isnull([Marzo],(0)))+isnull([Abril],(0)))+isnull([Mayo],(0)))+isnull([Junio],(0)))+isnull([Julio],(0)))+isnull([Agosto],(0)))+isnull([Septiembre],(0)))+isnull([Octubre],(0)))+isnull([Noviembre],(0)))+isnull([Diciembre],(0))),
 [Observaciones] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_CLCDetalle] PRIMARY KEY CLUSTERED ([PKIdCLCDetalle] ASC)
);
GO
CREATE TABLE [PRES].[CLCFactura] (
 [PKIdCLCFactura] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdCLC_PRES] int NOT NULL,
 [FKIdFactura_PRES] int NOT NULL,
 [FKIdFacturaDetalle_PRES] int NOT NULL,
 [MontoAplicado] decimal(20,4) NOT NULL,
 [Observaciones] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [FKIdIngresoAutorizado_PRES] int NULL,
 [Fecha] date NULL,
 CONSTRAINT [PK_CLCFactura] PRIMARY KEY CLUSTERED ([PKIdCLCFactura] ASC)
);
GO
CREATE TABLE [PRES].[Cheque] (
 [PKIdCheque] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdCLC_PRES] int NULL,
 [FKIdCuentaBancaria_TES] int NOT NULL,
 [FKIdPoliza_CONTA] int NULL,
 [FechaEmision] date NOT NULL,
 [NumeroCheque] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Concepto] nvarchar(150) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [ImporteTotal] decimal(20,4) NOT NULL,
 [Observaciones] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [Estatus] int NOT NULL DEFAULT ((1)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [RowVersion] rowversion NOT NULL,
 [IdPago] bigint NULL,
 CONSTRAINT [PK_Cheque] PRIMARY KEY CLUSTERED ([PKIdCheque] ASC)
);
GO
CREATE TABLE [PRES].[ChequePartidas] (
 [PKIdChequePartida] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdCheque_PRES] int NOT NULL,
 [FKIdCLCDetalle_PRES] int NOT NULL,
 [FKIdPartida_CONTA] int NOT NULL,
 [MontoPagado] decimal(20,4) NOT NULL,
 [Observaciones] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_ChequePartidas] PRIMARY KEY CLUSTERED ([PKIdChequePartida] ASC)
);
GO
CREATE TABLE [PRES].[Contrato] (
 [PKIdContrato] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdAutorizacionSuficiencia_PRES] int NOT NULL,
 [FKIdProveedor_SIS] int NOT NULL,
 [FKIdPoliza_CONTA] int NULL,
 [NumeroContrato] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(500) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FechaContrato] date NOT NULL,
 [FechaInicioVigencia] date NULL,
 [FechaFinVigencia] date NULL,
 [MontoTotal] decimal(20,4) NOT NULL,
 [PlazoEjecucion] nvarchar(100) COLLATE Modern_Spanish_CI_AS NULL,
 [Observaciones] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [Estatus] int NOT NULL DEFAULT ((1)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Contrato] PRIMARY KEY CLUSTERED ([PKIdContrato] ASC)
);
GO
CREATE TABLE [PRES].[ContratoDetalle] (
 [PKIdContratoDetalle] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdContrato_PRES] int NOT NULL,
 [FKIdAutorizacionSuficienciaDetalle_PRES] int NOT NULL,
 [FKIdPartida_CONTA] int NOT NULL,
 [Enero] decimal(20,4) NULL DEFAULT ((0)),
 [Febrero] decimal(20,4) NULL DEFAULT ((0)),
 [Marzo] decimal(20,4) NULL DEFAULT ((0)),
 [Abril] decimal(20,4) NULL DEFAULT ((0)),
 [Mayo] decimal(20,4) NULL DEFAULT ((0)),
 [Junio] decimal(20,4) NULL DEFAULT ((0)),
 [Julio] decimal(20,4) NULL DEFAULT ((0)),
 [Agosto] decimal(20,4) NULL DEFAULT ((0)),
 [Septiembre] decimal(20,4) NULL DEFAULT ((0)),
 [Octubre] decimal(20,4) NULL DEFAULT ((0)),
 [Noviembre] decimal(20,4) NULL DEFAULT ((0)),
 [Diciembre] decimal(20,4) NULL DEFAULT ((0)),
 [Total] AS (((((((((((isnull([Enero],(0))+isnull([Febrero],(0)))+isnull([Marzo],(0)))+isnull([Abril],(0)))+isnull([Mayo],(0)))+isnull([Junio],(0)))+isnull([Julio],(0)))+isnull([Agosto],(0)))+isnull([Septiembre],(0)))+isnull([Octubre],(0)))+isnull([Noviembre],(0)))+isnull([Diciembre],(0))),
 [Observaciones] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_ContratoDetalle] PRIMARY KEY CLUSTERED ([PKIdContratoDetalle] ASC)
);
GO
CREATE TABLE [PRES].[Deposito] (
 [PKIdDeposito] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdIngresoAutorizado_PRES] int NULL,
 [FKIdTipoDoctoPago_CONTA] int NOT NULL,
 [Importe] decimal(18,2) NOT NULL,
 [NumeroReferencia] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [ConceptoCheque] nvarchar(150) COLLATE Modern_Spanish_CI_AS NULL,
 [FechaEmision] date NOT NULL,
 [NombreAportante] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [FKIdCuentaCargo_CONTA] int NOT NULL,
 [FKIdCuentaAbono_CONTA] int NOT NULL,
 [FKIdCLCFactura_PRES] int NULL,
 [FKIdPoliza_CONTA] int NOT NULL,
 [Enero] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Febrero] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Marzo] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Abril] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Mayo] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Junio] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Julio] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Agosto] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Septiembre] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Octubre] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Noviembre] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Diciembre] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Total] AS (((((((((((isnull([Enero],(0))+isnull([Febrero],(0)))+isnull([Marzo],(0)))+isnull([Abril],(0)))+isnull([Mayo],(0)))+isnull([Junio],(0)))+isnull([Julio],(0)))+isnull([Agosto],(0)))+isnull([Septiembre],(0)))+isnull([Octubre],(0)))+isnull([Noviembre],(0)))+isnull([Diciembre],(0))),
 [Observaciones] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Deposito] PRIMARY KEY CLUSTERED ([PKIdDeposito] ASC)
);
GO
CREATE TABLE [PRES].[DestinoGasto] (
 [PKIdDestinoGasto] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(2) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(250) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_DestinoGasto] PRIMARY KEY CLUSTERED ([PKIdDestinoGasto] ASC)
);
GO
CREATE TABLE [PRES].[DigitoIdentificador] (
 [PKIdDigitoIdentificador] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(1) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_DigitoIdentificador] PRIMARY KEY CLUSTERED ([PKIdDigitoIdentificador] ASC)
);
GO
CREATE TABLE [PRES].[EgreAdecuacion] (
 [PKIdEgreAdecuacion] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FKIdTipoAdecuacion_PRES] int NOT NULL,
 [FKIdEstatusAdecuacion_PRES] int NOT NULL,
 [Justificacion] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [Fecha] date NOT NULL,
 [FKIdPoliza_CONTA] int NULL,
 [FKIdAnio_SIS] int NOT NULL,
 [Autorizado] bit NULL,
 [FKIdAccionAdecuacionMaster_PRES] int NULL,
 [FechaSolicitud] datetime2(7) NULL,
 [FechaAutorizacion] datetime2(7) NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL DEFAULT ((1)),
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [IdOperacion] bigint NOT NULL,
 CONSTRAINT [PK_EgreAdecuacion] PRIMARY KEY CLUSTERED ([PKIdEgreAdecuacion] ASC)
);
GO
CREATE TABLE [PRES].[EgreAdecuacionDetalle] (
 [PKIdEgreAdecuacionDetalle] int IDENTITY(1,1) NOT NULL,
 [FKIdEgresoAutorizado_PRES] int NULL,
 [Justificacion] nvarchar(250) COLLATE Modern_Spanish_CI_AS NULL,
 [Fecha] date NOT NULL,
 [FKIdEgreAdecuacion_PRES] int NOT NULL,
 [FKIdTipoMovimiento_PRES] int NOT NULL,
 [Enero] decimal(20,4) NULL DEFAULT ((0)),
 [Febrero] decimal(20,4) NULL DEFAULT ((0)),
 [Marzo] decimal(20,4) NULL DEFAULT ((0)),
 [Abril] decimal(20,4) NULL DEFAULT ((0)),
 [Mayo] decimal(20,4) NULL DEFAULT ((0)),
 [Junio] decimal(20,4) NULL DEFAULT ((0)),
 [Julio] decimal(20,4) NULL DEFAULT ((0)),
 [Agosto] decimal(20,4) NULL DEFAULT ((0)),
 [Septiembre] decimal(20,4) NULL DEFAULT ((0)),
 [Octubre] decimal(20,4) NULL DEFAULT ((0)),
 [Noviembre] decimal(20,4) NULL DEFAULT ((0)),
 [Diciembre] decimal(20,4) NULL DEFAULT ((0)),
 [Total] AS (((((((((((isnull([Enero],(0))+isnull([Febrero],(0)))+isnull([Marzo],(0)))+isnull([Abril],(0)))+isnull([Mayo],(0)))+isnull([Junio],(0)))+isnull([Julio],(0)))+isnull([Agosto],(0)))+isnull([Septiembre],(0)))+isnull([Octubre],(0)))+isnull([Noviembre],(0)))+isnull([Diciembre],(0))),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL DEFAULT ((1)),
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK_EgreAdecuacionDetalle] PRIMARY KEY CLUSTERED ([PKIdEgreAdecuacionDetalle] ASC)
);
GO
CREATE TABLE [PRES].[EgresoAutorizado] (
 [PKIdEgresoAutorizado] int IDENTITY(1,1) NOT NULL,
 [FKIdPrograma_PRES] int NOT NULL,
 [FKIdPartida_CONTA] int NOT NULL,
 [FKIdArea_SIS] int NOT NULL,
 [Descripcion] nvarchar(250) COLLATE Modern_Spanish_CI_AS NULL,
 [Fecha] date NOT NULL,
 [FKIdPoliza_CONTA] int NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [FKIdEgresoProyectado_PRES] int NULL,
 [Enero] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Febrero] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Marzo] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Abril] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Mayo] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Junio] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Julio] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Agosto] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Septiembre] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Octubre] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Noviembre] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Diciembre] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Total] AS ((((((((((([Enero]+[Febrero])+[Marzo])+[Abril])+[Mayo])+[Junio])+[Julio])+[Agosto])+[Septiembre])+[Octubre])+[Noviembre])+[Diciembre]),
 [FechaAutorizacion] datetime2(7) NULL,
 [UsuarioAutorizacion] int NULL,
 [FKIdFuenteFinanciamiento_PRES] int NULL,
 [FKIdTipoGasto_PRES] int NULL,
 [FKIdDigitoIdentificador_PRES] int NULL,
 [FKIdDestinoGasto_PRES] int NULL,
 [FKIdPY_PRES] int NULL,
 [RowVersion] rowversion NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [IdPresupuestoVersion] bigint NOT NULL,
 [IdCentroCosto] bigint NOT NULL,
 [IdOperacion] bigint NOT NULL,
 CONSTRAINT [PK_EgresoAutorizado] PRIMARY KEY CLUSTERED ([PKIdEgresoAutorizado] ASC)
);
GO
CREATE TABLE [PRES].[EgresoProyectado] (
 [PKIdEgresoProyectado] int IDENTITY(1,1) NOT NULL,
 [FKIdPrograma_PRES] int NOT NULL,
 [FKIdPartida_CONTA] int NOT NULL,
 [FKIdArea_SIS] int NOT NULL,
 [Descripcion] nvarchar(250) COLLATE Modern_Spanish_CI_AS NULL,
 [Fecha] date NOT NULL,
 [Enero] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Febrero] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Marzo] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Abril] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Mayo] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Junio] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Julio] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Agosto] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Septiembre] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Octubre] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Noviembre] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Diciembre] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Total] AS ((((((((((([Enero]+[Febrero])+[Marzo])+[Abril])+[Mayo])+[Junio])+[Julio])+[Agosto])+[Septiembre])+[Octubre])+[Noviembre])+[Diciembre]),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [FKIdFuenteFinanciamiento_PRES] int NULL,
 [FKIdTipoGasto_PRES] int NULL,
 [FKIdDigitoIdentificador_PRES] int NULL,
 [FKIdDestinoGasto_PRES] int NULL,
 [FKIdPY_PRES] int NULL,
 [RowVersion] rowversion NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [IdPresupuestoVersion] bigint NOT NULL,
 [IdCentroCosto] bigint NOT NULL,
 CONSTRAINT [PK_EgresoProyectado] PRIMARY KEY CLUSTERED ([PKIdEgresoProyectado] ASC)
);
GO
CREATE TABLE [PRES].[Eje] (
 [PKIdEje] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(1) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Eje] PRIMARY KEY CLUSTERED ([PKIdEje] ASC)
);
GO
CREATE TABLE [PRES].[EstatusAdecuacion] (
 [PKIdEstatusAdecuacion] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Color] nvarchar(8) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL DEFAULT ((1)),
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_EstatusAdecuacion] PRIMARY KEY CLUSTERED ([PKIdEstatusAdecuacion] ASC)
);
GO
CREATE TABLE [PRES].[FN] (
 [PKIdFN] int IDENTITY(1,1) NOT NULL,
 [FKIdGF_PRES] int NOT NULL,
 [Clave] int NOT NULL,
 [Descripcion] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_FN] PRIMARY KEY CLUSTERED ([PKIdFN] ASC)
);
GO
CREATE TABLE [PRES].[Factura] (
 [PKIdFactura] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdContrato_PRES] int NULL,
 [FKIdPoliza_CONTA] int NULL,
 [NumFactura] nvarchar(250) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [SerieFactura] nvarchar(20) COLLATE Modern_Spanish_CI_AS NULL,
 [FechaEmision] date NOT NULL,
 [FechaRecepcion] date NULL,
 [Subtotal] decimal(20,4) NULL,
 [IVA] decimal(20,4) NULL,
 [Retencion] decimal(20,4) NULL,
 [Total] decimal(20,4) NOT NULL,
 [UUID] nvarchar(36) COLLATE Modern_Spanish_CI_AS NULL,
 [FL_Docto] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [Observaciones] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [Estatus] int NOT NULL DEFAULT ((1)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [RowVersion] rowversion NOT NULL,
 [IdProveedorEmpresa] bigint NOT NULL,
 [IdCfdi] bigint NULL,
 [Vencimiento] date NOT NULL,
 [IdMoneda] int NOT NULL,
 [IdOperacion] bigint NOT NULL,
 CONSTRAINT [PK_Factura] PRIMARY KEY CLUSTERED ([PKIdFactura] ASC)
);
GO
CREATE TABLE [PRES].[FacturaDetalle] (
 [PKIdFacturaDetalle] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdFactura_PRES] int NOT NULL,
 [FKIdContratoDetalle_PRES] int NULL,
 [FKIdPartida_CONTA] int NOT NULL,
 [MontoAplicado] decimal(20,4) NOT NULL,
 [Observaciones] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_FacturaDetalle] PRIMARY KEY CLUSTERED ([PKIdFacturaDetalle] ASC)
);
GO
CREATE TABLE [PRES].[Finalidad] (
 [PKIdFinalidad] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(2) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Finalidad] PRIMARY KEY CLUSTERED ([PKIdFinalidad] ASC)
);
GO
CREATE TABLE [PRES].[FuenteFinanciamiento] (
 [PKIdFuenteFinanciamiento] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(6) COLLATE Modern_Spanish_CI_AS NULL,
 [Descripcion] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FF] nvarchar(2) COLLATE Modern_Spanish_CI_AS NULL,
 [FG] nvarchar(1) COLLATE Modern_Spanish_CI_AS NULL,
 [FE] nvarchar(1) COLLATE Modern_Spanish_CI_AS NULL,
 [AD] nvarchar(1) COLLATE Modern_Spanish_CI_AS NULL,
 [ORI] nvarchar(1) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_FuenteFinanciamiento] PRIMARY KEY CLUSTERED ([PKIdFuenteFinanciamiento] ASC)
);
GO
CREATE TABLE [PRES].[GF] (
 [PKIdGF] int IDENTITY(1,1) NOT NULL,
 [Clave] int NOT NULL,
 [Descripcion] nvarchar(30) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_GF] PRIMARY KEY CLUSTERED ([PKIdGF] ASC)
);
GO
CREATE TABLE [PRES].[GrupoPresupuesto] (
 [PKIdGrupoPresupuesto] int IDENTITY(1,1) NOT NULL,
 [Clave] int NOT NULL,
 [Descripcion] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_GrupoPresupuesto] PRIMARY KEY CLUSTERED ([PKIdGrupoPresupuesto] ASC)
);
GO
CREATE TABLE [PRES].[IngreAdecuacion] (
 [PKIdIngreAdecuacion] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FKIdTipoAdecuacion_PRES] int NOT NULL,
 [FKIdEstatusAdecuacion_PRES] int NOT NULL,
 [Justificacion] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [Fecha] date NOT NULL,
 [FKIdPoliza_CONTA] int NULL,
 [FKIdAnio_SIS] int NOT NULL,
 [Autorizado] bit NOT NULL DEFAULT ((0)),
 [FKIdAccionAdecuacionMaster_PRES] int NULL,
 [FechaSolicitud] datetime2(7) NULL,
 [FechaAutorizacion] datetime2(7) NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK_IngreAdecuacion] PRIMARY KEY CLUSTERED ([PKIdIngreAdecuacion] ASC)
);
GO
CREATE TABLE [PRES].[IngreAdecuacionDetalle] (
 [PKIdIngreAdecuacionDetalle] int IDENTITY(1,1) NOT NULL,
 [FKIdIngresoAutorizado_PRES] int NOT NULL,
 [Justificacion] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [Fecha] date NOT NULL,
 [FKIdIngreAdecuacion_PRES] int NOT NULL,
 [FKIdTipoMovimiento_PRES] int NOT NULL,
 [Enero] decimal(20,4) NOT NULL DEFAULT ((0)),
 [Febrero] decimal(20,4) NOT NULL DEFAULT ((0)),
 [Marzo] decimal(20,4) NOT NULL DEFAULT ((0)),
 [Abril] decimal(20,4) NOT NULL DEFAULT ((0)),
 [Mayo] decimal(20,4) NOT NULL DEFAULT ((0)),
 [Junio] decimal(20,4) NOT NULL DEFAULT ((0)),
 [Julio] decimal(20,4) NOT NULL DEFAULT ((0)),
 [Agosto] decimal(20,4) NOT NULL DEFAULT ((0)),
 [Septiembre] decimal(20,4) NOT NULL DEFAULT ((0)),
 [Octubre] decimal(20,4) NOT NULL DEFAULT ((0)),
 [Noviembre] decimal(20,4) NOT NULL DEFAULT ((0)),
 [Diciembre] decimal(20,4) NOT NULL DEFAULT ((0)),
 [Total] AS (((((((((((isnull([Enero],(0))+isnull([Febrero],(0)))+isnull([Marzo],(0)))+isnull([Abril],(0)))+isnull([Mayo],(0)))+isnull([Junio],(0)))+isnull([Julio],(0)))+isnull([Agosto],(0)))+isnull([Septiembre],(0)))+isnull([Octubre],(0)))+isnull([Noviembre],(0)))+isnull([Diciembre],(0))) PERSISTED,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK_IngreAdecuacionDetalle] PRIMARY KEY CLUSTERED ([PKIdIngreAdecuacionDetalle] ASC)
);
GO
CREATE TABLE [PRES].[IngresoAutorizado] (
 [PKIdIngresoAutorizado] int IDENTITY(1,1) NOT NULL,
 [FKIdPrograma_PRES] int NOT NULL,
 [FKIdOrigen_PRES] int NOT NULL,
 [Descripcion] nvarchar(250) COLLATE Modern_Spanish_CI_AS NULL,
 [Fecha] date NOT NULL,
 [FKIdPoliza_CONTA] int NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [Enero] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Febrero] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Marzo] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Abril] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Mayo] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Junio] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Julio] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Agosto] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Septiembre] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Octubre] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Noviembre] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Diciembre] decimal(18,2) NOT NULL DEFAULT ((0)),
 [Total] AS ((((((((((([Enero]+[Febrero])+[Marzo])+[Abril])+[Mayo])+[Junio])+[Julio])+[Agosto])+[Septiembre])+[Octubre])+[Noviembre])+[Diciembre]),
 [FechaAutorizacion] datetime2(7) NULL,
 [UsuarioAutorizacion] int NULL,
 [FKIdFuenteFinanciamiento_PRES] int NULL,
 [FKIdTipoGasto_PRES] int NULL,
 [FKIdDigitoIdentificador_PRES] int NULL,
 [FKIdDestinoGasto_PRES] int NULL,
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK_IngresoAutorizado] PRIMARY KEY CLUSTERED ([PKIdIngresoAutorizado] ASC)
);
GO
CREATE TABLE [PRES].[Origen] (
 [PKIdOrigen] int IDENTITY(1,1) NOT NULL,
 [Clave] int NOT NULL,
 [Descripcion] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Origen] PRIMARY KEY CLUSTERED ([PKIdOrigen] ASC)
);
GO
CREATE TABLE [PRES].[PG] (
 [PKIdPG] int IDENTITY(1,1) NOT NULL,
 [Clave] int NOT NULL,
 [Descripcion] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_PG] PRIMARY KEY CLUSTERED ([PKIdPG] ASC)
);
GO
CREATE TABLE [PRES].[PP] (
 [PKIdPP] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(4) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(150) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_PP] PRIMARY KEY CLUSTERED ([PKIdPP] ASC)
);
GO
CREATE TABLE [PRES].[PY] (
 [PKIdPY] int IDENTITY(1,1) NOT NULL,
 [Clave] varchar(15) COLLATE Modern_Spanish_CI_AS NULL,
 [Descripcion] nvarchar(150) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [NombreProyecto] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [InicioProyecto] date NULL,
 [FinProyecto] date NULL,
 [Plurianual] bit NULL,
 [TieneTICS] bit NULL,
 [EsPAT] bit NULL,
 [AnexosTransversales] bit NULL,
 [ProgramaPresupuestario] nvarchar(24) COLLATE Modern_Spanish_CI_AS NULL,
 [ProyectoInversion] bit NULL,
 [RecursosAdicionales] bit NULL,
 [Prioridad] smallint NULL,
 [FuenteFinanciamiento] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [DescripcionProyecto] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [ResponsableProyecto] nvarchar(128) COLLATE Modern_Spanish_CI_AS NULL,
 [ObjetivoProyecto] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [LineaEstrategica] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [LineaAccionRegulatoria] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [TemaAccionRegulatoria] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [FundamentoLegal] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [Justificacion] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [Beneficios] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [Indicador] nvarchar(128) COLLATE Modern_Spanish_CI_AS NULL,
 [Meta] nvarchar(128) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_PY] PRIMARY KEY CLUSTERED ([PKIdPY] ASC)
);
GO
CREATE TABLE [PRES].[PresupuestoVersion] (
 [IdPresupuestoVersion] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdAnio] int NOT NULL,
 [Version] int NOT NULL,
 [Estado] varchar(16) NOT NULL,
 [IdUsuarioAprobacion] int NULL,
 [FechaAprobacion] datetime2(7) NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_PRES_PresupuestoVersion_IdPresupuestoVersion] PRIMARY KEY CLUSTERED ([IdPresupuestoVersion] ASC)
);
GO
CREATE TABLE [PRES].[Programa] (
 [PKIdPrograma] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(255) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [FKIdUR_PRES] int NOT NULL,
 [FKIdGF_PRES] int NOT NULL,
 [FKIdFN_PRES] int NOT NULL,
 [FKIdSF_PRES] int NOT NULL,
 [FKIdActividadInstitucional_SIS] int NOT NULL,
 [FKIdEje_PRES] int NULL,
 [FKIdVertienteGasto_PRES] int NULL,
 [FKIdResultado_PRES] int NULL,
 [FKIdSubresultado_PRES] int NULL,
 [FKIdAnio_SIS] int NULL,
 [FKIdSector_PRES] int NULL,
 [FKIdSubSector_PRES] int NULL,
 [FKIdTipoRecurso_PRES] int NULL,
 [FKIdFuenteFinanciamiento_PRES] int NULL,
 [Objetivo] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [FKIdSubEje_PRES] int NULL,
 [FKIdSubSubEje_PRES] int NULL,
 [FKIdFinalidad_PRES] int NULL,
 [FKIdPP_PRES] int NULL,
 CONSTRAINT [PK_Programa] PRIMARY KEY CLUSTERED ([PKIdPrograma] ASC)
);
GO
CREATE TABLE [PRES].[Ramo] (
 [PKIdRamo] int IDENTITY(1,1) NOT NULL,
 [Clave] int NOT NULL,
 [Descripcion] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Ramo] PRIMARY KEY CLUSTERED ([PKIdRamo] ASC)
);
GO
CREATE TABLE [PRES].[RegresoChequeSuficiencia] (
 [PKIdRegresoChequeSuficiencia] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdCheque_PRES] int NOT NULL,
 [FKIdSolicitudSuficiencia_PRES] int NOT NULL,
 [Motivo] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FechaRegreso] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FKIdRequisicion_ORCO] int NULL,
 [FKIdOrdenCompra_ORCO] int NULL,
 [FKIdCotizacion_ORCO] int NULL,
 CONSTRAINT [PK_RegresoChequeSuficiencia] PRIMARY KEY CLUSTERED ([PKIdRegresoChequeSuficiencia] ASC)
);
GO
CREATE TABLE [PRES].[RegresoChequeSuficienciaPoliza] (
 [PKIdRegresoChequeSuficienciaPoliza] int IDENTITY(1,1) NOT NULL,
 [FKIdRegresoChequeSuficiencia_PRES] int NOT NULL,
 [FKIdPolizaOriginal_CONTA] int NOT NULL,
 [FKIdPolizaReversion_CONTA] int NOT NULL,
 [Etapas] nvarchar(250) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK_RegresoChequeSuficienciaPoliza] PRIMARY KEY CLUSTERED ([PKIdRegresoChequeSuficienciaPoliza] ASC)
);
GO
CREATE TABLE [PRES].[ReservaPresupuestal] (
 [IdReservaPresupuestal] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdEgresoAutorizado] int NOT NULL,
 [IdOperacion] bigint NOT NULL,
 [Mes] tinyint NOT NULL,
 [Importe] decimal(18,2) NOT NULL,
 [Estado] varchar(16) NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [FechaLiberacion] datetime2(7) NULL,
 [ClaveOperacion] uniqueidentifier NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_PRES_ReservaPresupuestal_IdReservaPresupuestal] PRIMARY KEY CLUSTERED ([IdReservaPresupuestal] ASC)
);
GO
CREATE TABLE [PRES].[Resultado] (
 [PKIdResultado] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(2) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Resultado] PRIMARY KEY CLUSTERED ([PKIdResultado] ASC)
);
GO
CREATE TABLE [PRES].[SF] (
 [PKIdSF] int IDENTITY(1,1) NOT NULL,
 [FKIdFN_PRES] int NOT NULL,
 [Clave] int NOT NULL,
 [Descripcion] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_SF] PRIMARY KEY CLUSTERED ([PKIdSF] ASC)
);
GO
CREATE TABLE [PRES].[Sector] (
 [PKIdSector] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(2) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Sector] PRIMARY KEY CLUSTERED ([PKIdSector] ASC)
);
GO
CREATE TABLE [PRES].[SolicitudSuficiencia] (
 [PKIdSolicitudSuficiencia] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdRequisicion_ORCO] int NOT NULL,
 [FechaSolicitud] date NOT NULL,
 [Justificacion] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [GastoNoProgramable] varchar(3) COLLATE Modern_Spanish_CI_AS NULL,
 [IdGastoNoProgramable] int NULL,
 [IdCompromisoNomina] int NULL,
 [Estatus] int NOT NULL DEFAULT ((1)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_SolicitudSuficiencia] PRIMARY KEY CLUSTERED ([PKIdSolicitudSuficiencia] ASC)
);
GO
CREATE TABLE [PRES].[SolicitudSuficienciaDetalle] (
 [PKIdSolicitudSuficienciaDetalle] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdSolicitudSuficiencia_PRES] int NOT NULL,
 [FKIdRequisicionDetalle_ORCO] int NOT NULL,
 [FKIdPartida_CONTA] int NOT NULL,
 [Enero] decimal(20,4) NULL DEFAULT ((0)),
 [Febrero] decimal(20,4) NULL DEFAULT ((0)),
 [Marzo] decimal(20,4) NULL DEFAULT ((0)),
 [Abril] decimal(20,4) NULL DEFAULT ((0)),
 [Mayo] decimal(20,4) NULL DEFAULT ((0)),
 [Junio] decimal(20,4) NULL DEFAULT ((0)),
 [Julio] decimal(20,4) NULL DEFAULT ((0)),
 [Agosto] decimal(20,4) NULL DEFAULT ((0)),
 [Septiembre] decimal(20,4) NULL DEFAULT ((0)),
 [Octubre] decimal(20,4) NULL DEFAULT ((0)),
 [Noviembre] decimal(20,4) NULL DEFAULT ((0)),
 [Diciembre] decimal(20,4) NULL DEFAULT ((0)),
 [Total] AS (((((((((((isnull([Enero],(0))+isnull([Febrero],(0)))+isnull([Marzo],(0)))+isnull([Abril],(0)))+isnull([Mayo],(0)))+isnull([Junio],(0)))+isnull([Julio],(0)))+isnull([Agosto],(0)))+isnull([Septiembre],(0)))+isnull([Octubre],(0)))+isnull([Noviembre],(0)))+isnull([Diciembre],(0))),
 [Observaciones] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_SolicitudSuficienciaDetalle] PRIMARY KEY CLUSTERED ([PKIdSolicitudSuficienciaDetalle] ASC)
);
GO
CREATE TABLE [PRES].[SubEje] (
 [PKIdSubEje] int IDENTITY(1,1) NOT NULL,
 [FKIdEje_PRES] int NOT NULL,
 [Clave] nvarchar(2) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_SubEje] PRIMARY KEY CLUSTERED ([PKIdSubEje] ASC)
);
GO
CREATE TABLE [PRES].[SubSector] (
 [PKIdSubSector] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(2) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_SubSector] PRIMARY KEY CLUSTERED ([PKIdSubSector] ASC)
);
GO
CREATE TABLE [PRES].[SubSubEje] (
 [PKIdSubSubEje] int IDENTITY(1,1) NOT NULL,
 [FKIdSubEje_PRES] int NOT NULL,
 [Clave] nvarchar(2) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_SubSubEje] PRIMARY KEY CLUSTERED ([PKIdSubSubEje] ASC)
);
GO
CREATE TABLE [PRES].[Subresultado] (
 [PKIdSubresultado] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(2) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Subresultado] PRIMARY KEY CLUSTERED ([PKIdSubresultado] ASC)
);
GO
CREATE TABLE [PRES].[Suficiencia] (
 [PKIdSuficiencia] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Suficiencia] PRIMARY KEY CLUSTERED ([PKIdSuficiencia] ASC)
);
GO
CREATE TABLE [PRES].[TipoAdecuacion] (
 [PKIdTipoAdecuacion] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL DEFAULT ((1)),
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_TipoAdecuacion] PRIMARY KEY CLUSTERED ([PKIdTipoAdecuacion] ASC)
);
GO
CREATE TABLE [PRES].[TipoGasto] (
 [PKIdTipoGasto] int IDENTITY(1,1) NOT NULL,
 [Clave] int NOT NULL,
 [Descripcion] nvarchar(200) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_TipoGasto] PRIMARY KEY CLUSTERED ([PKIdTipoGasto] ASC)
);
GO
CREATE TABLE [PRES].[TipoMovimiento] (
 [PKIdTipoMovimiento] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL DEFAULT ((1)),
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_TipoMovimiento] PRIMARY KEY CLUSTERED ([PKIdTipoMovimiento] ASC)
);
GO
CREATE TABLE [PRES].[TipoRecurso] (
 [PKIdTipoRecurso] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(1) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_TipoRecurso] PRIMARY KEY CLUSTERED ([PKIdTipoRecurso] ASC)
);
GO
CREATE TABLE [PRES].[UR] (
 [PKIdUR] int IDENTITY(1,1) NOT NULL,
 [FKIdGrupoPresupuesto_PRES] int NOT NULL,
 [Clave] nvarchar(10) COLLATE Modern_Spanish_CI_AS NULL,
 [Descripcion] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_UR] PRIMARY KEY CLUSTERED ([PKIdUR] ASC)
);
GO
CREATE TABLE [PRES].[VertienteGasto] (
 [PKIdVertienteGasto] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(2) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_VertienteGasto] PRIMARY KEY CLUSTERED ([PKIdVertienteGasto] ASC)
);
GO
CREATE TABLE [SIS].[AccionAutorizar] (
 [PkIdAccionAutorizar] int NOT NULL,
 [Accion] nvarchar(150) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Comentario] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [UsuarioCreacion] int NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioModificacion] int NULL,
 [FechaModificacion] datetime2(7) NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 CONSTRAINT [PK_AccionAutorizar] PRIMARY KEY CLUSTERED ([PkIdAccionAutorizar] ASC)
);
GO
CREATE TABLE [SIS].[ActividadInstitucional] (
 [PKIdActividadInstitucional] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(3) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(64) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_ActividadInstitucional] PRIMARY KEY CLUSTERED ([PKIdActividadInstitucional] ASC)
);
GO
CREATE TABLE [SIS].[Anio] (
 [PKIdAnio] int IDENTITY(1,1) NOT NULL,
 [Clave] int NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Anio] PRIMARY KEY CLUSTERED ([PKIdAnio] ASC)
);
GO
CREATE TABLE [SIS].[Area] (
 [PKIdArea] int IDENTITY(1,1) NOT NULL,
 [FKIdArea_SIS] int NULL,
 [FKIdAreaDocto_SIS] int NULL,
 [Clave] nvarchar(30) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Nombre] nvarchar(400) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [UltimoInv] datetime NULL,
 [ZonaEconomica] nvarchar(200) COLLATE Modern_Spanish_CI_AS NULL,
 [Direccion] nvarchar(128) COLLATE Modern_Spanish_CI_AS NULL,
 [Colonia] nvarchar(128) COLLATE Modern_Spanish_CI_AS NULL,
 [CP] nvarchar(10) COLLATE Modern_Spanish_CI_AS NULL,
 [Telefono] nvarchar(64) COLLATE Modern_Spanish_CI_AS NULL,
 [Aprovado] bit NOT NULL DEFAULT ((0)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK__Area__2F3CDBC036144DEB] PRIMARY KEY CLUSTERED ([PKIdArea] ASC)
);
GO
CREATE TABLE [SIS].[Capitulo] (
 [PKIdCapitulo] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(30) COLLATE Modern_Spanish_CI_AS NULL,
 [Descripcion] nvarchar(120) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Capitulo] PRIMARY KEY CLUSTERED ([PKIdCapitulo] ASC)
);
GO
CREATE TABLE [SIS].[CatTipoSucursal] (
 [PKIdTipoSucursal] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 CONSTRAINT [PK__CatTipoS__C73B8E29D29DC34F] PRIMARY KEY CLUSTERED ([PKIdTipoSucursal] ASC)
);
GO
CREATE TABLE [SIS].[CentroCosto] (
 [IdCentroCosto] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdSucursal] int NOT NULL,
 [Codigo] nvarchar(30) NOT NULL,
 [Nombre] nvarchar(200) NOT NULL,
 [VigenciaDesde] date NOT NULL,
 [VigenciaHasta] date NULL,
 [Activo] bit NOT NULL DEFAULT 1,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_SIS_CentroCosto_IdCentroCosto] PRIMARY KEY CLUSTERED ([IdCentroCosto] ASC)
);
GO
CREATE TABLE [SIS].[Concepto] (
 [PKIdConcepto] int IDENTITY(1,1) NOT NULL,
 [FKIdCapitulo_SIS] int NOT NULL,
 [Clave] nvarchar(30) COLLATE Modern_Spanish_CI_AS NULL,
 [Descripcion] nvarchar(120) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Concepto] PRIMARY KEY CLUSTERED ([PKIdConcepto] ASC)
);
GO
CREATE TABLE [SIS].[Corporativo] (
 [IdCorporativo] bigint IDENTITY(1,1) NOT NULL,
 [Codigo] nvarchar(30) NOT NULL,
 [Nombre] nvarchar(200) NOT NULL,
 [Activo] bit NOT NULL DEFAULT 1,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_SIS_Corporativo_IdCorporativo] PRIMARY KEY CLUSTERED ([IdCorporativo] ASC)
);
GO
CREATE TABLE [SIS].[Departamento] (
 [PKIdDepartamento] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdSucursal_SIS] int NULL,
 [Nombre] nvarchar(256) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(510) COLLATE Modern_Spanish_CI_AS NULL,
 [NivelJerarquico] int NULL DEFAULT ((1)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK__Departam__DC5984165D463946] PRIMARY KEY CLUSTERED ([PKIdDepartamento] ASC)
);
GO
CREATE TABLE [SIS].[Documento] (
 [PkidDocumento] bigint IDENTITY(1,1) NOT NULL,
 [Modulo] nvarchar(120) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [SubModulo] nvarchar(120) COLLATE Modern_Spanish_CI_AS NULL,
 [Controlador] nvarchar(160) COLLATE Modern_Spanish_CI_AS NULL,
 [Servicio] nvarchar(160) COLLATE Modern_Spanish_CI_AS NULL,
 [EntidadId] bigint NOT NULL,
 [FkidEmpresaSis] int NOT NULL,
 [Titulo] nvarchar(250) COLLATE Modern_Spanish_CI_AS NULL,
 [Descripcion] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [NombreOriginal] nvarchar(260) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [NombreAlmacenado] nvarchar(260) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Extension] nvarchar(16) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [TipoMime] nvarchar(120) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [TamanoBytes] bigint NOT NULL,
 [ModoAlmacenamiento] nvarchar(20) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [ContenidoArchivo] varbinary(max) NULL,
 [RutaRelativa] nvarchar(700) COLLATE Modern_Spanish_CI_AS NULL,
 [HashSha256] varbinary(32) NULL,
 [VersionDocumento] int NOT NULL DEFAULT ((1)),
 [EsImagen] bit NOT NULL DEFAULT ((0)),
 [EsPdf] bit NOT NULL DEFAULT ((0)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [CT_CreatedBy] int NOT NULL,
 [CT_CreatedDate] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [CT_ModifiedBy] int NULL,
 [CT_ModifiedDate] datetime2(0) NULL,
 [RowVersion] rowversion NOT NULL,
 CONSTRAINT [PK__Document__F6FE159DD4142EAC] PRIMARY KEY CLUSTERED ([PkidDocumento] ASC)
);
GO
CREATE TABLE [SIS].[DocumentoAnotacion] (
 [PkidDocumentoAnotacion] bigint IDENTITY(1,1) NOT NULL,
 [FkidDocumento] bigint NOT NULL,
 [FkidDocumentoTipoAnotacion] int NOT NULL,
 [Comentario] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [TextoSeleccionado] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [Pagina] int NULL,
 [PosicionX] decimal(9,6) NULL,
 [PosicionY] decimal(9,6) NULL,
 [Ancho] decimal(9,6) NULL,
 [Alto] decimal(9,6) NULL,
 [Color] nvarchar(20) COLLATE Modern_Spanish_CI_AS NOT NULL DEFAULT (N'#FFE066'),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [CT_CreatedBy] int NOT NULL,
 [CT_CreatedDate] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [CT_ModifiedBy] int NULL,
 [CT_ModifiedDate] datetime2(0) NULL,
 [RowVersion] rowversion NOT NULL,
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK__Document__3F4C0AC06E908D55] PRIMARY KEY CLUSTERED ([PkidDocumentoAnotacion] ASC)
);
GO
CREATE TABLE [SIS].[DocumentoEvento] (
 [PkidDocumentoEvento] bigint IDENTITY(1,1) NOT NULL,
 [FkidDocumento] bigint NOT NULL,
 [Evento] nvarchar(40) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Comentario] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [CT_CreatedBy] int NOT NULL,
 [CT_CreatedDate] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK__Document__CCABDED747D5EFD1] PRIMARY KEY CLUSTERED ([PkidDocumentoEvento] ASC)
);
GO
CREATE TABLE [SIS].[DocumentoExtensionPermitida] (
 [PkidDocumentoExtensionPermitida] int IDENTITY(1,1) NOT NULL,
 [Extension] nvarchar(16) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [TipoMime] nvarchar(120) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [EsImagen] bit NOT NULL DEFAULT ((0)),
 [EsPdf] bit NOT NULL DEFAULT ((0)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [CT_CreatedBy] int NULL,
 [CT_CreatedDate] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 CONSTRAINT [PK__Document__93C2CD58C16F4811] PRIMARY KEY CLUSTERED ([PkidDocumentoExtensionPermitida] ASC)
);
GO
CREATE TABLE [SIS].[DocumentoTipoAnotacion] (
 [PkidDocumentoTipoAnotacion] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(30) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(120) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [CT_CreatedBy] int NULL,
 [CT_CreatedDate] datetime2(0) NOT NULL DEFAULT (sysdatetime()),
 CONSTRAINT [PK__Document__D28FD9AAED98051C] PRIMARY KEY CLUSTERED ([PkidDocumentoTipoAnotacion] ASC)
);
GO
CREATE TABLE [SIS].[Empresa] (
 [PKIdEmpresa] int IDENTITY(1,1) NOT NULL,
 [Nombre] nvarchar(256) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [RFC] nvarchar(26) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [RazonSocial] nvarchar(510) COLLATE Modern_Spanish_CI_AS NULL,
 [Giro] nvarchar(200) COLLATE Modern_Spanish_CI_AS NULL,
 [FKIdMonedaBase_SIS] int NOT NULL,
 [FKIdIdiomaPreferido_SIS] int NULL,
 [Logo] nvarchar(2048) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [RegIMSS] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [RegInfonavit] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [CedEmpadronam] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [NoFonacot] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [UsAdmin] nvarchar(200) COLLATE Modern_Spanish_CI_AS NULL,
 [EmailAdmin] nvarchar(200) COLLATE Modern_Spanish_CI_AS NULL,
 [FKIdPeriodoPago_SIS] int NULL,
 [PrimaRiesgoIMSS] decimal(18,4) NULL,
 [UsaSueldoTabular] bit NOT NULL DEFAULT ((0)),
 [FKIdTipoPago_NOM] int NULL,
 [LogoEmpresa] varbinary(max) NULL,
 [NombreCorto] nvarchar(128) COLLATE Modern_Spanish_CI_AS NULL,
 [IdCorporativo] bigint NULL,
 CONSTRAINT [PK__Empresa__4FC08D3F0F80A285] PRIMARY KEY CLUSTERED ([PKIdEmpresa] ASC)
);
GO
CREATE TABLE [SIS].[EmpresaEstado] (
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdEstado_SIS] int NOT NULL,
 [FechaApertura] date NULL,
 [EsOficinaPrincipal] bit NOT NULL DEFAULT ((0)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 CONSTRAINT [PK__EmpresaE__41C643F4C6E8BCCC] PRIMARY KEY CLUSTERED ([FKIdEmpresa_SIS] ASC, [FKIdEstado_SIS] ASC)
);
GO
CREATE TABLE [SIS].[EnvioWorkflow] (
 [PKIdEnvioWorkflow] bigint IDENTITY(1,1) NOT NULL,
 [Proceso] varchar(60) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [EntidadId] bigint NOT NULL,
 [Estado] varchar(20) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [EstadoAnterior] varchar(20) COLLATE Modern_Spanish_CI_AS NULL,
 [TokenOperacion] uniqueidentifier NULL,
 [FechaEnvio] datetime2(7) NULL,
 [FechaRechazo] datetime2(7) NULL,
 [UsuarioEnvio] int NULL,
 [UsuarioRechazo] int NULL,
 [MotivoRechazo] nvarchar(500) COLLATE Modern_Spanish_CI_AS NULL,
 [FechaActualizacion] datetime2(7) NOT NULL DEFAULT (sysdatetime()),
 [IdEmpresa] int NOT NULL,
 [IdOperacion] bigint NOT NULL,
 [IdTemplate] int NOT NULL,
 CONSTRAINT [PK_SIS_EnvioWorkflow] PRIMARY KEY CLUSTERED ([PKIdEnvioWorkflow] ASC)
);
GO
CREATE TABLE [SIS].[Estados] (
 [PKIdEstado] int IDENTITY(1,1) NOT NULL,
 [FKIdPais_SIS] int NOT NULL,
 [Nombre] varchar(64) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [CodigoEstado] varchar(10) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 CONSTRAINT [PK__Estados__81974D7F52AC2C3D] PRIMARY KEY CLUSTERED ([PKIdEstado] ASC)
);
GO
CREATE TABLE [SIS].[EstatusProveedor] (
 [PKIdEstatusProveedor] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(150) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Color] nvarchar(8) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_EstatusProveedor] PRIMARY KEY CLUSTERED ([PKIdEstatusProveedor] ASC)
);
GO
CREATE TABLE [SIS].[Idioma] (
 [PKIdIdioma] int IDENTITY(1,1) NOT NULL,
 [Nombre] nvarchar(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [CodigoISO639_1] char(2) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [NombreNativo] nvarchar(100) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 CONSTRAINT [PK__Idioma__7CECE8635DB32E47] PRIMARY KEY CLUSTERED ([PKIdIdioma] ASC)
);
GO
CREATE TABLE [SIS].[Menu] (
 [PKIdMenu] int IDENTITY(1,1) NOT NULL,
 [Nombre] nvarchar(300) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Tipo] int NOT NULL,
 [FKIdMenu_SIS] int NULL,
 [LegacyName] nvarchar(160) COLLATE Modern_Spanish_CI_AS NULL,
 [Ruta] nvarchar(400) COLLATE Modern_Spanish_CI_AS NULL,
 [ImageUrl] nvarchar(240) COLLATE Modern_Spanish_CI_AS NULL,
 [Lenguaje] char(3) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Orden] int NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [CreatedByOperatorId] int NULL,
 [CreatedDateTime] datetime NOT NULL DEFAULT (getdate()),
 [ModifiedByOperatorId] int NULL,
 [ModifiedDateTime] datetime NULL,
 CONSTRAINT [PK__Menu__A6E54E14DC359E56] PRIMARY KEY CLUSTERED ([PKIdMenu] ASC)
);
GO
CREATE TABLE [SIS].[MenuRole] (
 [FKIdMenu_SIS] int NOT NULL,
 [RoleId] nvarchar(256) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [CreatedByOperatorId] int NULL,
 [CreatedDateTime] datetime NOT NULL DEFAULT (getdate()),
 [ModifiedByOperatorId] int NULL,
 [ModifiedDateTime] datetime NULL,
 CONSTRAINT [PK__MenuRole__2870F8FEAEED24E6] PRIMARY KEY CLUSTERED ([FKIdMenu_SIS] ASC, [RoleId] ASC)
);
GO
CREATE TABLE [SIS].[Moneda] (
 [PKIdMoneda] int IDENTITY(1,1) NOT NULL,
 [Nombre] nvarchar(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [CodigoISO4217] char(3) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Simbolo] nvarchar(10) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Decimales] int NOT NULL DEFAULT ((2)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 CONSTRAINT [PK__Moneda__88EE527948D4B250] PRIMARY KEY CLUSTERED ([PKIdMoneda] ASC)
);
GO
CREATE TABLE [SIS].[Municipios] (
 [PKIdMunicipio] int IDENTITY(1,1) NOT NULL,
 [FKIdEstado_SIS] int NOT NULL,
 [Nombre] varchar(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [CodigoMunicipio] varchar(10) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 CONSTRAINT [PK_Municipios] PRIMARY KEY CLUSTERED ([PKIdMunicipio] ASC)
);
GO
CREATE TABLE [SIS].[NormaJuridica] (
 [PKIdNormaJuridica] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(30) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Nombre] nvarchar(500) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Jurisdiccion] nvarchar(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Ambito] nvarchar(30) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [OrigenRecurso] nvarchar(30) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 CONSTRAINT [PK_NormaJuridica] PRIMARY KEY CLUSTERED ([PKIdNormaJuridica] ASC)
);
GO
CREATE TABLE [SIS].[NormaJuridicaVersion] (
 [PKIdNormaJuridicaVersion] int IDENTITY(1,1) NOT NULL,
 [FKIdNormaJuridica_SIS] int NOT NULL,
 [IdentificadorVersion] nvarchar(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Publicacion] date NOT NULL,
 [VigenciaDesde] date NOT NULL,
 [VigenciaHasta] date NULL,
 [UrlFuenteOficial] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [HuellaDocumento] varchar(64) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NOT NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 CONSTRAINT [PK_NormaJuridicaVersion] PRIMARY KEY CLUSTERED ([PKIdNormaJuridicaVersion] ASC)
);
GO
CREATE TABLE [SIS].[Notificacion] (
 [Pk_IdNotificacion] bigint IDENTITY(1,1) NOT NULL,
 [Fk_IdNotificacionTipo] int NOT NULL,
 [Fk_IdUsuarioOrigen] int NULL,
 [Modulo] nvarchar(120) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [SubModulo] nvarchar(120) COLLATE Modern_Spanish_CI_AS NULL,
 [Evento] nvarchar(120) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Entidad] nvarchar(150) COLLATE Modern_Spanish_CI_AS NULL,
 [Fk_IdEntidad] bigint NULL,
 [Titulo] nvarchar(250) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Mensaje] nvarchar(max) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Url] nvarchar(1000) COLLATE Modern_Spanish_CI_AS NULL,
 [JsonData] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [CT_CreatedBy] int NULL,
 [CT_CreatedDate] datetime2(0) NOT NULL DEFAULT (getdate()),
 [CT_ModifiedBy] int NULL,
 [CT_ModifiedDate] datetime2(0) NULL,
 [CT_LIVE] bit NOT NULL DEFAULT ((1)),
 [IdEmpresa] int NOT NULL,
 [IdEventoPendiente] bigint NULL,
 [IdRegla] int NULL,
 CONSTRAINT [PK__Notifica__C4DE1487A33A9F52] PRIMARY KEY CLUSTERED ([Pk_IdNotificacion] ASC)
);
GO
CREATE TABLE [SIS].[NotificacionDestino] (
 [Pk_IdNotificacionDestino] bigint IDENTITY(1,1) NOT NULL,
 [Fk_IdNotificacion] bigint NOT NULL,
 [Fk_IdUsuarioDestino] int NOT NULL,
 [Fk_IdNotificacionEstado] int NOT NULL DEFAULT ((1)),
 [FechaLeido] datetime2(0) NULL,
 [FechaAtendido] datetime2(0) NULL,
 [CT_CreatedBy] int NULL,
 [CT_CreatedDate] datetime2(0) NOT NULL DEFAULT (getdate()),
 [CT_ModifiedBy] int NULL,
 [CT_ModifiedDate] datetime2(0) NULL,
 [CT_LIVE] bit NOT NULL DEFAULT ((1)),
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK__Notifica__3741935BF94B83DF] PRIMARY KEY CLUSTERED ([Pk_IdNotificacionDestino] ASC)
);
GO
CREATE TABLE [SIS].[NotificacionEstado] (
 [Pk_IdNotificacionEstado] int NOT NULL,
 [Descripcion] nvarchar(80) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 CONSTRAINT [PK__Notifica__90095BB311E5894C] PRIMARY KEY CLUSTERED ([Pk_IdNotificacionEstado] ASC)
);
GO
CREATE TABLE [SIS].[NotificacionRegla] (
 [Pk_IdNotificacionRegla] int IDENTITY(1,1) NOT NULL,
 [Modulo] nvarchar(120) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [SubModulo] nvarchar(120) COLLATE Modern_Spanish_CI_AS NULL,
 [Evento] nvarchar(120) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [TipoDestino] nvarchar(40) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [ClaveDestino] nvarchar(150) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [CT_CreatedBy] int NULL,
 [CT_CreatedDate] datetime2(0) NOT NULL DEFAULT (getdate()),
 [CT_ModifiedBy] int NULL,
 [CT_ModifiedDate] datetime2(0) NULL,
 [CT_LIVE] bit NOT NULL DEFAULT ((1)),
 [IdEmpresa] int NOT NULL,
 CONSTRAINT [PK__Notifica__C28A7778191B7192] PRIMARY KEY CLUSTERED ([Pk_IdNotificacionRegla] ASC)
);
GO
CREATE TABLE [SIS].[NotificacionTipo] (
 [Pk_IdNotificacionTipo] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(80) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(250) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 CONSTRAINT [PK__Notifica__81A1FC0ECA91077B] PRIMARY KEY CLUSTERED ([Pk_IdNotificacionTipo] ASC)
);
GO
CREATE TABLE [SIS].[OperacionNegocio] (
 [IdOperacionNegocio] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [Proceso] varchar(40) NOT NULL,
 [Folio] nvarchar(60) NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [ClaveOperacion] uniqueidentifier NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_SIS_OperacionNegocio_IdOperacionNegocio] PRIMARY KEY CLUSTERED ([IdOperacionNegocio] ASC)
);
GO
CREATE TABLE [SIS].[Paises] (
 [PKIdPais] int IDENTITY(1,1) NOT NULL,
 [Nombre] varchar(64) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [CodigoISO2] char(2) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [CodigoISO3] char(3) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FKIdIdiomaPrincipal_SIS] int NULL,
 [FKIdMonedaPrincipal_SIS] int NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 CONSTRAINT [PK__Paises__F1E0AD5FE12A57E9] PRIMARY KEY CLUSTERED ([PKIdPais] ASC)
);
GO
CREATE TABLE [SIS].[Partida] (
 [PKIdPartida] int IDENTITY(1,1) NOT NULL,
 [FKIdConcepto_SIS] int NULL,
 [Clave] nvarchar(10) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(255) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Partida] PRIMARY KEY CLUSTERED ([PKIdPartida] ASC)
);
GO
CREATE TABLE [SIS].[PerfilUsuario] (
 [FKIdUsuario_SIS] int NOT NULL,
 [Fotografia] varbinary(max) NULL,
 [ContentType] nvarchar(100) COLLATE Modern_Spanish_CI_AS NULL,
 [FileName] nvarchar(128) COLLATE Modern_Spanish_CI_AS NULL,
 [FileExtension] nvarchar(16) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK__PerfilUs__98F09D6BB7843736] PRIMARY KEY CLUSTERED ([FKIdUsuario_SIS] ASC)
);
GO
CREATE TABLE [SIS].[Permiso] (
 [PKIdPermiso] int IDENTITY(1,1) NOT NULL,
 [Clave] nvarchar(160) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Modulo] nvarchar(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Recurso] nvarchar(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Accion] nvarchar(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Nombre] nvarchar(160) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Descripcion] nvarchar(300) COLLATE Modern_Spanish_CI_AS NULL,
 [FKIdMenu_SIS] int NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [CreatedByOperatorId] int NULL,
 [CreatedDateTime] datetime2(7) NOT NULL DEFAULT (sysdatetime()),
 [ModifiedByOperatorId] int NULL,
 [ModifiedDateTime] datetime2(7) NULL,
 CONSTRAINT [PK_Permiso] PRIMARY KEY CLUSTERED ([PKIdPermiso] ASC)
);
GO
CREATE TABLE [SIS].[Proveedor] (
 [PKIdProveedor] int IDENTITY(1,1) NOT NULL,
 [FkIdTipoProveedor_SIS] int NULL,
 [FKIdEstatusProveedor_SIS] int NULL,
 [FKIdMunicipio_SIS] int NOT NULL,
 [FKIdEstado_SIS] int NOT NULL,
 [FKIdPais_SIS] int NOT NULL,
 [FKIdResponsable_SIS] int NULL,
 [FKIdAESector_SIS] int NULL,
 [FKIdAEDivision_SIS] int NULL,
 [FKIdAEGrupo_SIS] int NULL,
 [FKIdAEClase_SIS] int NULL,
 [Nombre] nvarchar(500) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [RFC] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [Colonia] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [CP] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [Ciudad] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [EMAIL] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [Clave] nvarchar(10) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Calle] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [Numero] nvarchar(10) COLLATE Modern_Spanish_CI_AS NULL,
 [FechaAlta] datetime NULL,
 [TelefonoInstitucional] nvarchar(20) COLLATE Modern_Spanish_CI_AS NULL,
 [Notas] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [PaginaWeb] nvarchar(100) COLLATE Modern_Spanish_CI_AS NULL,
 [NumeroInt] nvarchar(10) COLLATE Modern_Spanish_CI_AS NULL,
 [CURP] nvarchar(18) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Proveedor] PRIMARY KEY CLUSTERED ([PKIdProveedor] ASC)
);
GO
CREATE TABLE [SIS].[ProveedorEmpresa] (
 [IdProveedorEmpresa] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdProveedor] int NOT NULL,
 [Condiciones] nvarchar(600) NULL,
 [DiasCredito] int NOT NULL DEFAULT 0,
 [Estatus] varchar(16) NOT NULL,
 [Activo] bit NOT NULL DEFAULT 1,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 [IdCuentaContable] int NULL,
 CONSTRAINT [UX_SIS_ProveedorEmpresa_IdProveedorEmpresa] PRIMARY KEY CLUSTERED ([IdProveedorEmpresa] ASC)
);
GO
CREATE TABLE [SIS].[ResponsableOperativo] (
 [IdResponsableOperativo] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdUsuario] int NULL,
 [Codigo] nvarchar(30) NOT NULL,
 [Nombre] nvarchar(200) NOT NULL,
 [Correo] nvarchar(254) NULL,
 [Telefono] nvarchar(40) NULL,
 [Activo] bit NOT NULL DEFAULT 1,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_SIS_ResponsableOperativo_IdResponsableOperativo] PRIMARY KEY CLUSTERED ([IdResponsableOperativo] ASC)
);
GO
CREATE TABLE [SIS].[RolPermiso] (
 [RoleId] nvarchar(256) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FKIdPermiso_SIS] int NOT NULL,
 [CreatedByOperatorId] int NULL,
 [CreatedDateTime] datetime2(7) NOT NULL DEFAULT (sysdatetime()),
 CONSTRAINT [PK_RolPermiso] PRIMARY KEY CLUSTERED ([RoleId] ASC, [FKIdPermiso_SIS] ASC)
);
GO
CREATE TABLE [SIS].[Sucursal] (
 [PKIdSucursal] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdEstado_SIS] int NOT NULL,
 [Nombre] nvarchar(256) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [CodigoSucursal] nvarchar(40) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Alias] nvarchar(100) COLLATE Modern_Spanish_CI_AS NULL,
 [FKIdTipoSucursal] int NOT NULL DEFAULT ((1)),
 [FKIdMonedaLocal_SIS] int NULL,
 [Direccion] nvarchar(512) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Colonia] nvarchar(200) COLLATE Modern_Spanish_CI_AS NULL,
 [Ciudad] nvarchar(200) COLLATE Modern_Spanish_CI_AS NULL,
 [CodigoPostal] nvarchar(20) COLLATE Modern_Spanish_CI_AS NULL,
 [TelefonoPrincipal] nvarchar(40) COLLATE Modern_Spanish_CI_AS NULL,
 [TelefonoSecundario] nvarchar(40) COLLATE Modern_Spanish_CI_AS NULL,
 [Email] nvarchar(200) COLLATE Modern_Spanish_CI_AS NULL,
 [HorarioApertura] time(7) NULL,
 [HorarioCierre] time(7) NULL,
 [EsMatriz] bit NOT NULL DEFAULT ((0)),
 [EsActiva] bit NOT NULL DEFAULT ((1)),
 [Latitud] decimal(9,6) NULL,
 [Longitud] decimal(9,6) NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK__Sucursal__FDFE5D25C7F8AF74] PRIMARY KEY CLUSTERED ([PKIdSucursal] ASC)
);
GO
CREATE TABLE [SIS].[TipoDetallePoliza] (
 [PkIdTipoDetallePoliza] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(25) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_TipoDetallePoliza] PRIMARY KEY CLUSTERED ([PkIdTipoDetallePoliza] ASC)
);
GO
CREATE TABLE [SIS].[TipoPoliza] (
 [PKIdTipoPoliza] int IDENTITY(1,1) NOT NULL,
 [Descripcion] nvarchar(25) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_TipoPoliza] PRIMARY KEY CLUSTERED ([PKIdTipoPoliza] ASC)
);
GO
CREATE TABLE [SIS].[TipoProveedor] (
 [PkIdTipoProveedor] int IDENTITY(1,1) NOT NULL,
 [Descripcion] varchar(80) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_TipoProveedor] PRIMARY KEY CLUSTERED ([PkIdTipoProveedor] ASC)
);
GO
CREATE TABLE [SIS].[Usuario] (
 [PkIdUsuario] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NULL,
 [FKIdPersona_NOM] int NULL,
 [AspNetUserId] nvarchar(450) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [PayrollID] nvarchar(40) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [FKIdIdiomaPreferido_SIS] int NULL,
 [FKIdMonedaPreferida_SIS] int NULL,
 [EsAdministrador] bit NOT NULL DEFAULT ((0)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK__Usuario__FD4E229D67D257BD] PRIMARY KEY CLUSTERED ([PkIdUsuario] ASC)
);
GO
CREATE TABLE [SIS].[UsuarioDepartamento] (
 [FKIdUsuario_SIS] int NOT NULL,
 [FKIdDepartamento_SIS] int NOT NULL,
 [EsJefe] bit NOT NULL DEFAULT ((0)),
 [FechaAsignacion] datetime2(7) NOT NULL DEFAULT (sysdatetime()),
 [FechaFinAsignacion] datetime2(7) NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK__UsuarioD__EE77B557890FAF55] PRIMARY KEY CLUSTERED ([FKIdUsuario_SIS] ASC, [FKIdDepartamento_SIS] ASC)
);
GO
CREATE TABLE [SIS].[UsuarioSucursal] (
 [FKIdUsuario_SIS] int NOT NULL,
 [FKIdSucursal_SIS] int NOT NULL,
 [PuedeAcceder] bit NOT NULL DEFAULT ((1)),
 [PuedeConfigurar] bit NOT NULL DEFAULT ((0)),
 [PuedeOperar] bit NOT NULL DEFAULT ((1)),
 [PuedeReportes] bit NOT NULL DEFAULT ((0)),
 [EsGerente] bit NOT NULL DEFAULT ((0)),
 [EsSupervisor] bit NOT NULL DEFAULT ((0)),
 [FechaAsignacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [FechaFinAsignacion] datetime2(7) NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK__UsuarioS__CB859D2AA02A2091] PRIMARY KEY CLUSTERED ([FKIdUsuario_SIS] ASC, [FKIdSucursal_SIS] ASC)
);
GO
CREATE TABLE [TES].[Banco] (
 [PKIdBanco] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [Clave] nvarchar(10) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Nombre] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [NombreCorto] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_Banco] PRIMARY KEY CLUSTERED ([PKIdBanco] ASC)
);
GO
CREATE TABLE [TES].[ConciliacionDetalle] (
 [IdConciliacionDetalle] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdMovimientoBancario] bigint NOT NULL,
 [IdPago] bigint NOT NULL,
 [Importe] decimal(20,4) NOT NULL,
 [Estado] varchar(16) NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_TES_ConciliacionDetalle_IdConciliacionDetalle] PRIMARY KEY CLUSTERED ([IdConciliacionDetalle] ASC)
);
GO
CREATE TABLE [TES].[ConexionBancaria] (
 [IdConexionBancaria] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdCuentaBancaria] int NOT NULL,
 [Convenio] nvarchar(100) NOT NULL,
 [Ambiente] varchar(12) NOT NULL,
 [ReferenciaSecreto] nvarchar(500) NOT NULL,
 [Activo] bit NOT NULL DEFAULT 1,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_TES_ConexionBancaria_IdConexionBancaria] PRIMARY KEY CLUSTERED ([IdConexionBancaria] ASC)
);
GO
CREATE TABLE [TES].[CuentaBancaria] (
 [PKIdCuentaBancaria] int IDENTITY(1,1) NOT NULL,
 [FKIdEmpresa_SIS] int NOT NULL,
 [FKIdBanco_TES] int NULL,
 [FKIdCuentaContable_SIS] int NULL,
 [FKIdTipoMoneda_TES] int NOT NULL,
 [NumeroCuenta] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [CLABE] nvarchar(18) COLLATE Modern_Spanish_CI_AS NULL,
 [Titular] nvarchar(200) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [SaldoInicial] decimal(20,4) NOT NULL DEFAULT ((0)),
 [SaldoActual] decimal(20,4) NOT NULL DEFAULT ((0)),
 [FechaApertura] date NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 [IdMoneda] int NOT NULL,
 CONSTRAINT [PK_CuentaBancaria] PRIMARY KEY CLUSTERED ([PKIdCuentaBancaria] ASC)
);
GO
CREATE TABLE [TES].[EventoCheque] (
 [IdEventoCheque] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdCheque] int NOT NULL,
 [Tipo] varchar(16) NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [IdDocumentoAcuse] bigint NULL,
 [Observaciones] nvarchar(500) NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_TES_EventoCheque_IdEventoCheque] PRIMARY KEY CLUSTERED ([IdEventoCheque] ASC)
);
GO
CREATE TABLE [TES].[IntentoEnvioBancario] (
 [IdIntentoEnvioBancario] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdOperacionBancaria] bigint NOT NULL,
 [NumeroIntento] int NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [CodigoRespuesta] nvarchar(60) NULL,
 [Respuesta] nvarchar(1500) NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_TES_IntentoEnvioBancario_IdIntentoEnvioBancario] PRIMARY KEY CLUSTERED ([IdIntentoEnvioBancario] ASC)
);
GO
CREATE TABLE [TES].[LoteDispersion] (
 [IdLoteDispersion] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdOperacion] bigint NOT NULL,
 [IdCuentaBancaria] int NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [TotalControl] decimal(20,4) NOT NULL,
 [NumeroOperaciones] int NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_TES_LoteDispersion_IdLoteDispersion] PRIMARY KEY CLUSTERED ([IdLoteDispersion] ASC)
);
GO
CREATE TABLE [TES].[MovimientoBancario] (
 [IdMovimientoBancario] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdCuentaBancaria] int NOT NULL,
 [ReferenciaExterna] nvarchar(150) NOT NULL,
 [FechaValor] date NOT NULL,
 [FechaOperacion] datetime2(7) NOT NULL,
 [IdMoneda] int NOT NULL,
 [Importe] decimal(20,4) NOT NULL,
 [Concepto] nvarchar(500) NULL,
 [IdDocumentoEstadoCuenta] bigint NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_TES_MovimientoBancario_IdMovimientoBancario] PRIMARY KEY CLUSTERED ([IdMovimientoBancario] ASC)
);
GO
CREATE TABLE [TES].[OperacionBancaria] (
 [IdOperacionBancaria] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdPago] bigint NOT NULL,
 [IdConexion] bigint NOT NULL,
 [IdLoteDispersion] bigint NULL,
 [ClaveIdempotencia] uniqueidentifier NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [ReferenciaBanco] nvarchar(150) NULL,
 [IdDocumentoAcuse] bigint NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_TES_OperacionBancaria_IdOperacionBancaria] PRIMARY KEY CLUSTERED ([IdOperacionBancaria] ASC)
);
GO
CREATE TABLE [TES].[PrevisionTesoreria] (
 [IdPrevisionTesoreria] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [Fecha] date NOT NULL,
 [IdMoneda] int NOT NULL,
 [Escenario] nvarchar(60) NOT NULL,
 [Sentido] varchar(8) NOT NULL,
 [Importe] decimal(20,4) NOT NULL,
 [IdOperacion] bigint NULL,
 [Concepto] nvarchar(500) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_TES_PrevisionTesoreria_IdPrevisionTesoreria] PRIMARY KEY CLUSTERED ([IdPrevisionTesoreria] ASC)
);
GO
CREATE TABLE [TES].[TipoCambio] (
 [PKIdTipoCambio] int IDENTITY(1,1) NOT NULL,
 [FKIdTipoMoneda_TES] int NOT NULL,
 [Cantidad] decimal(18,2) NOT NULL,
 [Fecha] datetime NOT NULL,
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_TipoCambio] PRIMARY KEY CLUSTERED ([PKIdTipoCambio] ASC)
);
GO
CREATE TABLE [TES].[TipoMoneda] (
 [PKIdTipoMoneda] int IDENTITY(1,1) NOT NULL,
 [FKIdPais_SIS] int NOT NULL,
 [Descripcion] nvarchar(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [CodigoISO4217] char(3) COLLATE Modern_Spanish_CI_AS NULL,
 [Simbolo] nvarchar(5) COLLATE Modern_Spanish_CI_AS NULL,
 [Decimales] int NOT NULL DEFAULT ((2)),
 [Activo] bit NOT NULL DEFAULT ((1)),
 [FechaCreacion] datetime2(7) NULL DEFAULT (sysdatetime()),
 [UsuarioCreacion] int NOT NULL,
 [FechaModificacion] datetime2(7) NULL,
 [UsuarioModificacion] int NULL,
 CONSTRAINT [PK_TipoMoneda] PRIMARY KEY CLUSTERED ([PKIdTipoMoneda] ASC)
);
GO
CREATE TABLE [VIA].[AnticipoViatico] (
 [IdAnticipoViatico] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdSolicitud] bigint NOT NULL,
 [Importe] decimal(20,4) NOT NULL,
 [Fecha] date NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_VIA_AnticipoViatico_IdAnticipoViatico] PRIMARY KEY CLUSTERED ([IdAnticipoViatico] ASC)
);
GO
CREATE TABLE [VIA].[ComprobacionViatico] (
 [IdComprobacionViatico] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdSolicitud] bigint NOT NULL,
 [IdComprobanteGasto] bigint NOT NULL,
 [ImporteAceptado] decimal(20,4) NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_VIA_ComprobacionViatico_IdComprobacionViatico] PRIMARY KEY CLUSTERED ([IdComprobacionViatico] ASC)
);
GO
CREATE TABLE [VIA].[ReintegroViatico] (
 [IdReintegroViatico] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdSolicitud] bigint NOT NULL,
 [IdMovimientoBancario] bigint NULL,
 [Importe] decimal(20,4) NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [IdDocumentoEvidencia] bigint NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_VIA_ReintegroViatico_IdReintegroViatico] PRIMARY KEY CLUSTERED ([IdReintegroViatico] ASC)
);
GO
CREATE TABLE [VIA].[SolicitudViatico] (
 [IdSolicitudViatico] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdOperacion] bigint NOT NULL,
 [IdResponsable] bigint NOT NULL,
 [IdCentroCosto] bigint NOT NULL,
 [IdMoneda] int NOT NULL,
 [Comision] nvarchar(800) NOT NULL,
 [Destino] nvarchar(300) NOT NULL,
 [FechaInicio] date NOT NULL,
 [FechaFin] date NOT NULL,
 [Estado] varchar(20) NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_VIA_SolicitudViatico_IdSolicitudViatico] PRIMARY KEY CLUSTERED ([IdSolicitudViatico] ASC)
);
GO
CREATE TABLE [WF].[CalendarioAtencion] (
 [IdCalendarioAtencion] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [Codigo] nvarchar(30) NOT NULL,
 [ZonaHoraria] nvarchar(100) NOT NULL,
 [HorarioJson] nvarchar(max) NOT NULL,
 [ExcepcionesJson] nvarchar(max) NULL,
 [Activo] bit NOT NULL DEFAULT 1,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_WF_CalendarioAtencion_IdCalendarioAtencion] PRIMARY KEY CLUSTERED ([IdCalendarioAtencion] ASC)
);
GO
CREATE TABLE [WF].[DecisionAutorizacion] (
 [IdDecisionAutorizacion] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdEnvio] bigint NOT NULL,
 [IdRegla] bigint NOT NULL,
 [IdUsuario] int NOT NULL,
 [Decision] varchar(16) NOT NULL,
 [Fecha] datetime2(7) NOT NULL,
 [Motivo] nvarchar(1000) NULL,
 [ClaveOperacion] uniqueidentifier NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_WF_DecisionAutorizacion_IdDecisionAutorizacion] PRIMARY KEY CLUSTERED ([IdDecisionAutorizacion] ASC)
);
GO
CREATE TABLE [WF].[EventoPendiente] (
 [IdEventoPendiente] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdOperacion] bigint NOT NULL,
 [Tipo] varchar(60) NOT NULL,
 [FechaPrevista] datetime2(7) NOT NULL,
 [Estado] varchar(16) NOT NULL,
 [ClaveOperacion] uniqueidentifier NOT NULL,
 [Intentos] int NOT NULL DEFAULT 0,
 [UltimoError] nvarchar(1000) NULL,
 [DatosJson] nvarchar(max) NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_WF_EventoPendiente_IdEventoPendiente] PRIMARY KEY CLUSTERED ([IdEventoPendiente] ASC)
);
GO
CREATE TABLE [WF].[PlazoOperacion] (
 [IdPlazoOperacion] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdEnvio] bigint NOT NULL,
 [IdPoliticaSLA] bigint NOT NULL,
 [Inicio] datetime2(7) NOT NULL,
 [Limite] datetime2(7) NOT NULL,
 [MinutosPausa] int NOT NULL DEFAULT 0,
 [Cierre] datetime2(7) NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_WF_PlazoOperacion_IdPlazoOperacion] PRIMARY KEY CLUSTERED ([IdPlazoOperacion] ASC)
);
GO
CREATE TABLE [WF].[PoliticaSLA] (
 [IdPoliticaSLA] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdTemplate] int NOT NULL,
 [IdCalendario] bigint NOT NULL,
 [Etapa] nvarchar(60) NOT NULL,
 [PlazoMinutos] int NOT NULL,
 [EscalamientoJson] nvarchar(max) NULL,
 [Version] int NOT NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_WF_PoliticaSLA_IdPoliticaSLA] PRIMARY KEY CLUSTERED ([IdPoliticaSLA] ASC)
);
GO
CREATE TABLE [WF].[ReglaAutorizacion] (
 [IdReglaAutorizacion] bigint IDENTITY(1,1) NOT NULL,
 [IdEmpresa] int NOT NULL,
 [IdTemplate] int NOT NULL,
 [IdSucursal] int NULL,
 [RoleId] nvarchar(256) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Nivel] int NOT NULL,
 [Version] int NOT NULL,
 [MontoDesde] decimal(20,4) NOT NULL,
 [MontoHasta] decimal(20,4) NULL,
 [Desde] date NOT NULL,
 [Hasta] date NULL,
 [CreadoUtc] datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
 [VersionFila] rowversion NOT NULL,
 CONSTRAINT [UX_WF_ReglaAutorizacion_IdReglaAutorizacion] PRIMARY KEY CLUSTERED ([IdReglaAutorizacion] ASC)
);
GO
CREATE TABLE [dbo].[AspNetClaimTypes] (
 [Id] int IDENTITY(1,1) NOT NULL,
 [Name] nvarchar(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Created] datetime NOT NULL,
 CONSTRAINT [PK__AspNetCl__3214EC07DDCF27C6] PRIMARY KEY CLUSTERED ([Id] ASC)
);
GO
CREATE TABLE [dbo].[AspNetClaimValues] (
 [Id] int IDENTITY(1,1) NOT NULL,
 [ClaimId] int NULL,
 [Value] nvarchar(256) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Created] datetime NOT NULL DEFAULT (getdate()),
 CONSTRAINT [PK__AspNetCl__3214EC07AB4FD7A5] PRIMARY KEY CLUSTERED ([Id] ASC)
);
GO
CREATE TABLE [dbo].[AspNetClaims] (
 [Id] int IDENTITY(1,1) NOT NULL,
 [ClaimTypeId] int NULL,
 [Name] nvarchar(150) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Group] nvarchar(100) COLLATE Modern_Spanish_CI_AS NULL,
 [RoleId] nvarchar(256) COLLATE Modern_Spanish_CI_AS NULL,
 [TokenFormat] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [Created] datetime NOT NULL,
 [SubGroup] nvarchar(100) COLLATE Modern_Spanish_CI_AS NULL,
 [Code] nvarchar(64) COLLATE Modern_Spanish_CI_AS NULL,
 [Description] nvarchar(200) COLLATE Modern_Spanish_CI_AS NULL,
 [Values] varchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [ReferenceId] int NOT NULL DEFAULT ((0)),
 CONSTRAINT [PK__AspNetCl__3214EC07D9EAC826] PRIMARY KEY CLUSTERED ([Id] ASC)
);
GO
CREATE TABLE [dbo].[AspNetRoles] (
 [Id] nvarchar(256) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Name] nvarchar(512) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Code] nvarchar(20) COLLATE Modern_Spanish_CI_AS NULL,
 CONSTRAINT [PK__AspNetRo__3214EC07F059B64E] PRIMARY KEY CLUSTERED ([Id] ASC)
);
GO
CREATE TABLE [dbo].[AspNetUserRoles] (
 [UserId] nvarchar(256) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [RoleId] nvarchar(256) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [ExpireDate] datetime NULL,
 CONSTRAINT [PK__AspNetUs__AF2760ADED8371E2] PRIMARY KEY CLUSTERED ([UserId] ASC, [RoleId] ASC)
);
GO
CREATE TABLE [dbo].[AspNetUsers] (
 [Id] nvarchar(256) COLLATE Modern_Spanish_CI_AS NOT NULL,
 [Email] nvarchar(512) COLLATE Modern_Spanish_CI_AS NULL,
 [EmailConfirmed] bit NOT NULL,
 [PasswordHash] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [SecurityStamp] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [PhoneNumber] nvarchar(max) COLLATE Modern_Spanish_CI_AS NULL,
 [PhoneNumberConfirmed] bit NOT NULL,
 [TwoFactorEnabled] bit NOT NULL,
 [LockoutEndDateUtc] datetime NULL,
 [LockoutEnabled] bit NOT NULL,
 [AccessFailedCount] int NOT NULL,
 [ReferenceId] int NULL,
 [AccessNumber] nvarchar(50) COLLATE Modern_Spanish_CI_AS NULL,
 [PkIdUsuario] int NULL,
 CONSTRAINT [PK__AspNetUs__3214EC075749A220] PRIMARY KEY CLUSTERED ([Id] ASC)
);
GO
CREATE NONCLUSTERED INDEX [IX_Almacen_Activo_552389037] ON [ALMA].[Almacen] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Almacen_Clave_552389037] ON [ALMA].[Almacen] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Almacen_FKIdArea_SIS_552389037] ON [ALMA].[Almacen] ([FKIdArea_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Almacen_FKIdEmpresa_SIS_552389037] ON [ALMA].[Almacen] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Almacen_FKIdMotivoES_ALMA_552389037] ON [ALMA].[Almacen] ([FKIdMotivoES_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Almacen_FKIdTipoBien_ALMA_552389037] ON [ALMA].[Almacen] ([FKIdTipoBien_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Almacen_FKIdAnio_SIS] ON [ALMA].[Almacen] ([FKIdAnio_SIS] ASC, [FKIdEmpresa_SIS] ASC, [Activo] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_Almacen_FKIdEmpresa_SIS_PKIdAlmacen] ON [ALMA].[Almacen] ([FKIdEmpresa_SIS] ASC, [PKIdAlmacen] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_AlmacenCatalogo_IdEmpresa_Codigo] ON [ALMA].[AlmacenCatalogo] ([IdEmpresa] ASC, [Codigo] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_AlmacenCatalogo_IdEmpresa_IdAlmacenCatalogo] ON [ALMA].[AlmacenCatalogo] ([IdEmpresa] ASC, [IdAlmacenCatalogo] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_AlmacenCatalogo_IdEmpresa_IdAlmacenCatalogo_IdSucursal] ON [ALMA].[AlmacenCatalogo] ([IdEmpresa] ASC, [IdAlmacenCatalogo] ASC, [IdSucursal] ASC);
GO
ALTER TABLE [ALMA].[AlmacenCatalogo] ADD CONSTRAINT [CK_EXUX_ALMA_AlmacenCatalogo_1] CHECK (Tipo IN ('FISICO','TRANSITO'));
GO
CREATE NONCLUSTERED INDEX [IX_Bajas_Activo_1355867897] ON [ALMA].[Bajas] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Bajas_FechaAutorizacion_1355867897] ON [ALMA].[Bajas] ([FechaAutorizacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Bajas_FechaSolicitud_1355867897] ON [ALMA].[Bajas] ([FechaSolicitud] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Bajas_FKIdArea_SIS_1355867897] ON [ALMA].[Bajas] ([FKIdArea_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Bajas_FKIdBien_ALMA_1355867897] ON [ALMA].[Bajas] ([FKIdBien_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Bajas_FKIdEmpresa_SIS_1355867897] ON [ALMA].[Bajas] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Bajas_FKIdEstadoBienAnterior_ALMA_1355867897] ON [ALMA].[Bajas] ([FKIdEstadoBienAnterior_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Bajas_FKIdEstadoBienDestino_ALMA_1355867897] ON [ALMA].[Bajas] ([FKIdEstadoBienDestino_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Bajas_FKIdEstatusBaja_ALMA_1355867897] ON [ALMA].[Bajas] ([FKIdEstatusBaja_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Bajas_FKIdPoliza_CONTA_1355867897] ON [ALMA].[Bajas] ([FKIdPoliza_CONTA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Bajas_FKIdTipoBaja_ALMA_1355867897] ON [ALMA].[Bajas] ([FKIdTipoBaja_ALMA] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Bajas_BienActivo] ON [ALMA].[Bajas] ([FKIdBien_ALMA] ASC) WHERE ([Activo]=(1));
GO
CREATE NONCLUSTERED INDEX [IX_Bajas_FKIdAnio_SIS] ON [ALMA].[Bajas] ([FKIdAnio_SIS] ASC, [FKIdEmpresa_SIS] ASC, [Activo] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_Bajas_IdOperacion] ON [ALMA].[Bajas] ([IdOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_Bajas_FKIdEmpresa_SIS_Folio] ON [ALMA].[Bajas] ([FKIdEmpresa_SIS] ASC, [Folio] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Bien_Activo_917578307] ON [ALMA].[Bien] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Bien_Clave_917578307] ON [ALMA].[Bien] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Bien_FKIdArea_SIS_917578307] ON [ALMA].[Bien] ([FKIdArea_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Bien_FKIdEstadoBien_ALMA_917578307] ON [ALMA].[Bien] ([FKIdEstadoBien_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Bien_FKIdGrupoBien_ALMA_917578307] ON [ALMA].[Bien] ([FKIdGrupoBien_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Bien_FKIdMarca_ALMA_917578307] ON [ALMA].[Bien] ([FKIdMarca_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Bien_FKIdMaterial_ALMA_917578307] ON [ALMA].[Bien] ([FKIdMaterial_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Bien_FKIdPartida_CONTA_917578307] ON [ALMA].[Bien] ([FKIdPartida_CONTA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Bien_FKIdProveedor_SIS_917578307] ON [ALMA].[Bien] ([FKIdProveedor_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Bien_FKIdTipoAdq_ALMA_917578307] ON [ALMA].[Bien] ([FKIdTipoAdq_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Bien_FKIdTipoBien_ALMA_917578307] ON [ALMA].[Bien] ([FKIdTipoBien_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Bien_FKIdTipoPatrimonio_ALMA_917578307] ON [ALMA].[Bien] ([FKIdTipoPatrimonio_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Bien_UsuarioCreacion_917578307] ON [ALMA].[Bien] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Bien_UsuarioModificacion_917578307] ON [ALMA].[Bien] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Bien_FKIdEmpresa_SIS] ON [ALMA].[Bien] ([FKIdEmpresa_SIS] ASC, [Activo] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_Bien_FKIdEmpresa_SIS_PKIdBien] ON [ALMA].[Bien] ([FKIdEmpresa_SIS] ASC, [PKIdBien] ASC);
GO
ALTER TABLE [ALMA].[Bien] ADD CONSTRAINT [CK_EXUX_ALMA_Bien_DestinoExclusivo] CHECK (IdUbicacionPatrimonial IS NULL OR IdUbicacionAlmacen IS NULL);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CalendarioInventario_Folio] ON [ALMA].[CalendarioInventario] ([Folio] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CalendarioInventario_Activo_104387441] ON [ALMA].[CalendarioInventario] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CalendarioInventario_FKIdArea_SIS_104387441] ON [ALMA].[CalendarioInventario] ([FKIdArea_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CalendarioInventario_FKIdEmpresa_SIS_104387441] ON [ALMA].[CalendarioInventario] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CalendarioInventario_ContextoPeriodo] ON [ALMA].[CalendarioInventario] ([FKIdEmpresa_SIS] ASC, [Anio] ASC, [FKIdArea_SIS] ASC, [FechaInicio] ASC, [FechaFin] ASC) WHERE ([Activo]=(1));
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_CalendarioInventario_FKIdEmpresa_SIS_PKIdCalendarioInventario] ON [ALMA].[CalendarioInventario] ([FKIdEmpresa_SIS] ASC, [PKIdCalendarioInventario] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_CierreInventario_IdPartidaStock_FKIdAnio_SIS_Mes] ON [ALMA].[CierreInventario] ([IdPartidaStock] ASC, [FKIdAnio_SIS] ASC, [Mes] ASC);
GO
ALTER TABLE [ALMA].[CierreInventario] ADD CONSTRAINT [CK_CierreInventario_Mes] CHECK (([Mes]>=(1) AND [Mes]<=(12)));
GO
CREATE NONCLUSTERED INDEX [IX_Conteo_Activo_949578421] ON [ALMA].[Conteo] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Conteo_FKIdPeriodoConteo_ALMA_949578421] ON [ALMA].[Conteo] ([FKIdPeriodoConteo_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Conteo_FKIdTipoBien_ALMA_949578421] ON [ALMA].[Conteo] ([FKIdTipoBien_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Conteo_UsuarioCreacion_949578421] ON [ALMA].[Conteo] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Conteo_UsuarioModificacion_949578421] ON [ALMA].[Conteo] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_Conteo_IdEmpresa_PKIdConteo] ON [ALMA].[Conteo] ([IdEmpresa] ASC, [PKIdConteo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ConteoDetalle_Activo_981578535] ON [ALMA].[ConteoDetalle] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ConteoDetalle_Fecha_981578535] ON [ALMA].[ConteoDetalle] ([Fecha] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ConteoDetalle_FKIdConteo_ALMA_981578535] ON [ALMA].[ConteoDetalle] ([FKIdConteo_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ConteoDetalle_FKIdPersona_NOM_981578535] ON [ALMA].[ConteoDetalle] ([FKIdPersona_Responsable] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ConteoDetalle_UsuarioCreacion_981578535] ON [ALMA].[ConteoDetalle] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ConteoDetalle_UsuarioModificacion_981578535] ON [ALMA].[ConteoDetalle] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ConteoDetalleEscaneo_Activo_1013578649] ON [ALMA].[ConteoDetalleEscaneo] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ConteoDetalleEscaneo_FKIdConteo_ALMA_1013578649] ON [ALMA].[ConteoDetalleEscaneo] ([FKIdConteo_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ConteoDetalleEscaneo_FKIdPersona_NOM_1013578649] ON [ALMA].[ConteoDetalleEscaneo] ([FKIdPersona_Responsable] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ConteoDetalleEscaneo_FKIdTipoBien_ALMA_1013578649] ON [ALMA].[ConteoDetalleEscaneo] ([FKIdTipoBien_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ConteoDetalleEscaneo_UsuarioCreacion_1013578649] ON [ALMA].[ConteoDetalleEscaneo] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ConteoDetalleEscaneo_UsuarioModificacion_1013578649] ON [ALMA].[ConteoDetalleEscaneo] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ConteoHist_Activo_1045578763] ON [ALMA].[ConteoHist] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_DetalleSolicitudSalida_Activo_936390405] ON [ALMA].[DetalleSolicitudSalida] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_DetalleSolicitudSalida_FKIdAlmacen_ALMA_936390405] ON [ALMA].[DetalleSolicitudSalida] ([FKIdAlmacen_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_DetalleSolicitudSalida_FKIdSolicitudSalida_ALMA_936390405] ON [ALMA].[DetalleSolicitudSalida] ([FKIdSolicitudSalida_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_DetalleSolicitudSalida_FKIdTipoBien_ALMA_936390405] ON [ALMA].[DetalleSolicitudSalida] ([FKIdTipoBien_ALMA] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_DetalleSolicitudSalida_IdEmpresa_PKIdDetalleSolicitudSalida] ON [ALMA].[DetalleSolicitudSalida] ([IdEmpresa] ASC, [PKIdDetalleSolicitudSalida] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_DetalleSolicitudSalida_IdEmpresa_PKIdDetalleSolicitudSalida_IdAlmacen_FKIdTipoBien_ALMA] ON [ALMA].[DetalleSolicitudSalida] ([IdEmpresa] ASC, [PKIdDetalleSolicitudSalida] ASC, [IdAlmacen] ASC, [FKIdTipoBien_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstadoBien_Activo_1077578877] ON [ALMA].[EstadoBien] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstadoBien_UsuarioCreacion_1077578877] ON [ALMA].[EstadoBien] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstadoBien_UsuarioModificacion_1077578877] ON [ALMA].[EstadoBien] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_EstatusArticuloConteo_Nombre] ON [ALMA].[EstatusArticuloConteo] ([Nombre] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstatusArticuloConteo_Activo_1109578991] ON [ALMA].[EstatusArticuloConteo] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstatusBaja_Activo_1147867156] ON [ALMA].[EstatusBaja] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstatusInventario_Activo_2059870405] ON [ALMA].[EstatusInventario] ([Activo] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_EstatusPeriodo_Nombre] ON [ALMA].[EstatusPeriodo] ([Nombre] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstatusPeriodo_Activo_1157579162] ON [ALMA].[EstatusPeriodo] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstatusSolicitud_Activo_1205579333] ON [ALMA].[EstatusSolicitud] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstatusSolicitud_UsuarioCreacion_1205579333] ON [ALMA].[EstatusSolicitud] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstatusSolicitud_UsuarioModificacion_1205579333] ON [ALMA].[EstatusSolicitud] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstatusSolicitudSalida_Activo_8387099] ON [ALMA].[EstatusSolicitudSalida] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Familia_Activo_1237579447] ON [ALMA].[Familia] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Familia_Clave_1237579447] ON [ALMA].[Familia] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Familia_UsuarioCreacion_1237579447] ON [ALMA].[Familia] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Familia_UsuarioModificacion_1237579447] ON [ALMA].[Familia] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_GrupoBien_Activo_1269579561] ON [ALMA].[GrupoBien] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_GrupoBien_Clave_1269579561] ON [ALMA].[GrupoBien] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_GrupoBien_FKIdFamilia_ALMA_1269579561] ON [ALMA].[GrupoBien] ([FKIdFamilia_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_GrupoBien_UsuarioCreacion_1269579561] ON [ALMA].[GrupoBien] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_GrupoBien_UsuarioModificacion_1269579561] ON [ALMA].[GrupoBien] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Inventario_Folio] ON [ALMA].[Inventario] ([Folio] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Inventario_Activo_216387840] ON [ALMA].[Inventario] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Inventario_FechaAutorizacion_216387840] ON [ALMA].[Inventario] ([FechaAutorizacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Inventario_FKIdArea_SIS_216387840] ON [ALMA].[Inventario] ([FKIdArea_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Inventario_FKIdCalendarioInventario_ALMA_216387840] ON [ALMA].[Inventario] ([FKIdCalendarioInventario_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Inventario_FKIdEmpresa_SIS_216387840] ON [ALMA].[Inventario] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Inventario_FKIdEstatusInventario_ALMA_216387840] ON [ALMA].[Inventario] ([FKIdEstatusInventario_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Inventario_ContextoCalendario] ON [ALMA].[Inventario] ([FKIdEmpresa_SIS] ASC, [FKIdCalendarioInventario_ALMA] ASC, [FKIdArea_SIS] ASC) WHERE ([Activo]=(1));
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_Inventario_FKIdEmpresa_SIS_PKIdInventario] ON [ALMA].[Inventario] ([FKIdEmpresa_SIS] ASC, [PKIdInventario] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_InventarioDetalle_Activo_424388581] ON [ALMA].[InventarioDetalle] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_InventarioDetalle_FKIdBien_ALMA_424388581] ON [ALMA].[InventarioDetalle] ([FKIdBien_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_InventarioDetalle_FKIdInventario_ALMA_424388581] ON [ALMA].[InventarioDetalle] ([FKIdInventario_ALMA] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_InventarioDetalle_InventarioBienActivo] ON [ALMA].[InventarioDetalle] ([FKIdInventario_ALMA] ASC, [FKIdBien_ALMA] ASC) WHERE ([Activo]=(1));
GO
ALTER TABLE [ALMA].[InventarioDetalle] ADD CONSTRAINT [CK_EXUX_ALMA_InventarioDetalle_DestinoExclusivo] CHECK (IdUbicacionPatrimonial IS NULL OR IdUbicacionAlmacen IS NULL);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_Lote_IdEmpresa_IdTipoBien_Numero] ON [ALMA].[Lote] ([IdEmpresa] ASC, [IdTipoBien] ASC, [Numero] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_Lote_IdEmpresa_IdLote] ON [ALMA].[Lote] ([IdEmpresa] ASC, [IdLote] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_Lote_IdEmpresa_IdLote_IdTipoBien] ON [ALMA].[Lote] ([IdEmpresa] ASC, [IdLote] ASC, [IdTipoBien] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Marca_Activo_1301579675] ON [ALMA].[Marca] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Marca_UsuarioCreacion_1301579675] ON [ALMA].[Marca] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Marca_UsuarioModificacion_1301579675] ON [ALMA].[Marca] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Material_Activo_1333579789] ON [ALMA].[Material] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Material_UsuarioCreacion_1333579789] ON [ALMA].[Material] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Material_UsuarioModificacion_1333579789] ON [ALMA].[Material] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MotivoES_Activo_1365579903] ON [ALMA].[MotivoES] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MotivoES_UsuarioCreacion_1365579903] ON [ALMA].[MotivoES] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MotivoES_UsuarioModificacion_1365579903] ON [ALMA].[MotivoES] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_MovimientoInventario_IdEmpresa_ClaveOperacion] ON [ALMA].[MovimientoInventario] ([IdEmpresa] ASC, [ClaveOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_MovimientoInventario_IdOperacion] ON [ALMA].[MovimientoInventario] ([IdOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_MovimientoInventario_IdMovimientoReversa] ON [ALMA].[MovimientoInventario] ([IdMovimientoReversa] ASC) WHERE [IdMovimientoReversa] IS NOT NULL;
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_MovimientoInventario_IdEmpresa_IdMovimientoInventario] ON [ALMA].[MovimientoInventario] ([IdEmpresa] ASC, [IdMovimientoInventario] ASC);
GO
ALTER TABLE [ALMA].[MovimientoInventario] ADD CONSTRAINT [CK_EXUX_ALMA_MovimientoInventario_1] CHECK (Tipo IN ('ENTRADA','SALIDA','AJUSTE','TRANSFERENCIA','SALDO_INICIAL','REVERSA'));
GO
ALTER TABLE [ALMA].[MovimientoInventario] ADD CONSTRAINT [CK_EXUX_ALMA_MovimientoInventario_2] CHECK (Estado IN ('BORRADOR','APLICADO','CANCELADO'));
GO
ALTER TABLE [ALMA].[MovimientoInventario] ADD CONSTRAINT [CK_EXUX_ALMA_MovimientoInventario_3] CHECK ((Estado='APLICADO' AND AplicadoUtc IS NOT NULL AND IdUsuarioAplicacion IS NOT NULL) OR (Estado<>'APLICADO' AND AplicadoUtc IS NULL AND IdUsuarioAplicacion IS NULL));
GO
ALTER TABLE [ALMA].[MovimientoInventario] ADD CONSTRAINT [CK_EXUX_ALMA_MovimientoInventario_Reversa] CHECK ((Tipo='REVERSA' AND IdMovimientoReversa IS NOT NULL AND IdMovimientoReversa<>IdMovimientoInventario) OR (Tipo<>'REVERSA' AND IdMovimientoReversa IS NULL));
GO
CREATE NONCLUSTERED INDEX [IX_ALMA_MovimientoInventarioDetalle_IdPartidaStock_IdMovimiento] ON [ALMA].[MovimientoInventarioDetalle] ([IdPartidaStock] ASC, [IdMovimiento] ASC);
GO
ALTER TABLE [ALMA].[MovimientoInventarioDetalle] ADD CONSTRAINT [CK_EXUX_ALMA_MovimientoInventarioDetalle_1] CHECK (Cantidad <> 0 AND CostoUnitario >= 0);
GO
CREATE NONCLUSTERED INDEX [IX_Nivel_Activo_1397580017] ON [ALMA].[Nivel] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Nivel_UsuarioCreacion_1397580017] ON [ALMA].[Nivel] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Nivel_UsuarioModificacion_1397580017] ON [ALMA].[Nivel] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_PartidaStock_IdProductoAlmacen_IdUbicacion_IdLote_Condicion] ON [ALMA].[PartidaStock] ([IdProductoAlmacen] ASC, [IdUbicacion] ASC, [IdLote] ASC, [Condicion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_PartidaStock_IdEmpresa_IdPartidaStock] ON [ALMA].[PartidaStock] ([IdEmpresa] ASC, [IdPartidaStock] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_PartidaStock_IdEmpresa_IdPartidaStock_IdTipoBien] ON [ALMA].[PartidaStock] ([IdEmpresa] ASC, [IdPartidaStock] ASC, [IdTipoBien] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_PartidaStock_IdEmpresa_IdPartidaStock_IdAlmacen_IdTipoBien] ON [ALMA].[PartidaStock] ([IdEmpresa] ASC, [IdPartidaStock] ASC, [IdAlmacen] ASC, [IdTipoBien] ASC);
GO
ALTER TABLE [ALMA].[PartidaStock] ADD CONSTRAINT [CK_EXUX_ALMA_PartidaStock_1] CHECK (Condicion IN ('DISPONIBLE','CUARENTENA','DANADO','BLOQUEADO'));
GO
CREATE NONCLUSTERED INDEX [IX_PeriodoConteo_Activo_1429580131] ON [ALMA].[PeriodoConteo] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PeriodoConteo_FKIdEstatus_ALMA_1429580131] ON [ALMA].[PeriodoConteo] ([FKIdEstatus_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PeriodoConteo_FKIdResponsable_SIS_1429580131] ON [ALMA].[PeriodoConteo] ([FKIdResponsable_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PeriodoConteo_FKIdSucursal_SIS_1429580131] ON [ALMA].[PeriodoConteo] ([FKIdSucursal_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PeriodoConteo_FKIdSupervisor_SIS_1429580131] ON [ALMA].[PeriodoConteo] ([FKIdSupervisor_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PeriodoConteo_FKIdTipoConteo_ALMA_1429580131] ON [ALMA].[PeriodoConteo] ([FKIdTipoConteo_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PeriodoConteo_UsuarioCreacion_1429580131] ON [ALMA].[PeriodoConteo] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PeriodoConteo_UsuarioModificacion_1429580131] ON [ALMA].[PeriodoConteo] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_PeriodoConteo_IdAlmacen_CodigoPeriodo] ON [ALMA].[PeriodoConteo] ([IdAlmacen] ASC, [CodigoPeriodo] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_PeriodoConteo_IdEmpresa_PKIdPeriodoConteo_IdAlmacen] ON [ALMA].[PeriodoConteo] ([IdEmpresa] ASC, [PKIdPeriodoConteo] ASC, [IdAlmacen] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_PeriodoConteo_IdEmpresa_PKIdPeriodoConteo] ON [ALMA].[PeriodoConteo] ([IdEmpresa] ASC, [PKIdPeriodoConteo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PlanConteoCiclico_ProximaFecha] ON [ALMA].[PlanConteoCiclico] ([Activo] ASC, [ProximaFechaConteo] ASC, [ClasificacionABC] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_PlanConteoCiclico_IdProductoAlmacen] ON [ALMA].[PlanConteoCiclico] ([IdProductoAlmacen] ASC);
GO
ALTER TABLE [ALMA].[PlanConteoCiclico] ADD CONSTRAINT [CK_PlanConteoCiclico_Clasificacion] CHECK (([ClasificacionABC]='C' OR [ClasificacionABC]='B' OR [ClasificacionABC]='A'));
GO
ALTER TABLE [ALMA].[PlanConteoCiclico] ADD CONSTRAINT [CK_PlanConteoCiclico_Frecuencia] CHECK (([FrecuenciaDias]>=(1) AND [FrecuenciaDias]<=(3650)));
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_ProductoAlmacen_IdAlmacen_IdTipoBien] ON [ALMA].[ProductoAlmacen] ([IdAlmacen] ASC, [IdTipoBien] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_ProductoAlmacen_IdEmpresa_IdProductoAlmacen] ON [ALMA].[ProductoAlmacen] ([IdEmpresa] ASC, [IdProductoAlmacen] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_ProductoAlmacen_IdEmpresa_IdProductoAlmacen_IdAlmacen_IdTipoBien] ON [ALMA].[ProductoAlmacen] ([IdEmpresa] ASC, [IdProductoAlmacen] ASC, [IdAlmacen] ASC, [IdTipoBien] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_ProductoAlmacen_IdEmpresa_IdProductoAlmacen_IdTipoBien] ON [ALMA].[ProductoAlmacen] ([IdEmpresa] ASC, [IdProductoAlmacen] ASC, [IdTipoBien] ASC);
GO
ALTER TABLE [ALMA].[ProductoAlmacen] ADD CONSTRAINT [CK_EXUX_ALMA_ProductoAlmacen_1] CHECK (Minimo >= 0 AND PuntoReposicion >= 0 AND (Maximo IS NULL OR Maximo >= Minimo));
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_ReservaStock_IdEmpresa_ClaveOperacion] ON [ALMA].[ReservaStock] ([IdEmpresa] ASC, [ClaveOperacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ALMA_ReservaStock_IdPartidaStock_Estado] ON [ALMA].[ReservaStock] ([IdPartidaStock] ASC, [Estado] ASC);
GO
ALTER TABLE [ALMA].[ReservaStock] ADD CONSTRAINT [CK_EXUX_ALMA_ReservaStock_1] CHECK (Cantidad > 0);
GO
ALTER TABLE [ALMA].[ReservaStock] ADD CONSTRAINT [CK_EXUX_ALMA_ReservaStock_2] CHECK (Estado IN ('ACTIVA','CONSUMIDA','LIBERADA','VENCIDA'));
GO
CREATE NONCLUSTERED INDEX [IX_Resguardo_Activo_1240391488] ON [ALMA].[Resguardo] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Resguardo_Fecha_1240391488] ON [ALMA].[Resguardo] ([Fecha] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Resguardo_FKIdArea_SIS_1240391488] ON [ALMA].[Resguardo] ([FKIdArea_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Resguardo_FKIdEmpresa_SIS_1240391488] ON [ALMA].[Resguardo] ([FKIdEmpresa_SIS] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_Resguardo_IdOperacion] ON [ALMA].[Resguardo] ([IdOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_Resguardo_FKIdEmpresa_SIS_Folio] ON [ALMA].[Resguardo] ([FKIdEmpresa_SIS] ASC, [Folio] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_Resguardo_FKIdEmpresa_SIS_PKIdResguardo] ON [ALMA].[Resguardo] ([FKIdEmpresa_SIS] ASC, [PKIdResguardo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ResguardoDetalle_Activo_1368391944] ON [ALMA].[ResguardoDetalle] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ResguardoDetalle_FKIdBien_ALMA_1368391944] ON [ALMA].[ResguardoDetalle] ([FKIdBien_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ResguardoDetalle_FKIdEstadoBien_ALMA_1368391944] ON [ALMA].[ResguardoDetalle] ([FKIdEstadoBien_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ResguardoDetalle_FKIdResguardo_ALMA_1368391944] ON [ALMA].[ResguardoDetalle] ([FKIdResguardo_ALMA] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ResguardoDetalle_BienActivo] ON [ALMA].[ResguardoDetalle] ([FKIdBien_ALMA] ASC) WHERE ([Activo]=(1));
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_ResguardoDetalle_IdEmpresa_PKIdResguardoDetalle] ON [ALMA].[ResguardoDetalle] ([IdEmpresa] ASC, [PKIdResguardoDetalle] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ResguardoMovimiento_Activo_1512392457] ON [ALMA].[ResguardoMovimiento] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ResguardoMovimiento_FKIdBien_ALMA_1512392457] ON [ALMA].[ResguardoMovimiento] ([FKIdBien_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ResguardoMovimiento_FKIdResguardoDestino_ALMA_1512392457] ON [ALMA].[ResguardoMovimiento] ([FKIdResguardoDestino_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ResguardoMovimiento_FKIdResguardoDetalle_ALMA_1512392457] ON [ALMA].[ResguardoMovimiento] ([FKIdResguardoDetalle_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ResguardoMovimiento_FKIdResguardoOrigen_ALMA_1512392457] ON [ALMA].[ResguardoMovimiento] ([FKIdResguardoOrigen_ALMA] ASC);
GO
ALTER TABLE [ALMA].[ResguardoMovimiento] ADD CONSTRAINT [CK_ResguardoMovimiento_Tipo] CHECK (([TipoMovimiento]=N'BAJA' OR [TipoMovimiento]=N'DEVOLUCION' OR [TipoMovimiento]=N'TRASPASO' OR [TipoMovimiento]=N'ASIGNACION'));
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_SolicitudSalida_EmpresaAnioFolio] ON [ALMA].[SolicitudSalida] ([FKIdEmpresa_SIS] ASC, [FKIdAnio_SIS] ASC, [Folio] ASC) WHERE ([FKIdAnio_SIS] IS NOT NULL);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSalida_Activo_760389778] ON [ALMA].[SolicitudSalida] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSalida_FechaAutorizacion_760389778] ON [ALMA].[SolicitudSalida] ([FechaAutorizacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSalida_FechaSolicitud_760389778] ON [ALMA].[SolicitudSalida] ([FechaSolicitud] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSalida_FKIdAreaEntrega_SIS_760389778] ON [ALMA].[SolicitudSalida] ([FKIdAreaEntrega_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSalida_FKIdAreaSolicita_SIS_760389778] ON [ALMA].[SolicitudSalida] ([FKIdAreaSolicita_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSalida_FKIdEmpresa_SIS_760389778] ON [ALMA].[SolicitudSalida] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSalida_FKIdEstatusSolicitudSalida_ALMA_760389778] ON [ALMA].[SolicitudSalida] ([FKIdEstatusSolicitudSalida_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSalida_FKIdPoliza_CONTA_760389778] ON [ALMA].[SolicitudSalida] ([FKIdPoliza_CONTA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSalida_FKIdAnio_SIS] ON [ALMA].[SolicitudSalida] ([FKIdAnio_SIS] ASC, [FKIdEmpresa_SIS] ASC, [Activo] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_SolicitudSalida_IdOperacion] ON [ALMA].[SolicitudSalida] ([IdOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_SolicitudSalida_FKIdEmpresa_SIS_PKIdSolicitudSalida_IdAlmacen] ON [ALMA].[SolicitudSalida] ([FKIdEmpresa_SIS] ASC, [PKIdSolicitudSalida] ASC, [IdAlmacen] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_SolicitudSalida_FKIdEmpresa_SIS_PKIdSolicitudSalida] ON [ALMA].[SolicitudSalida] ([FKIdEmpresa_SIS] ASC, [PKIdSolicitudSalida] ASC);
GO
ALTER TABLE [ALMA].[SolicitudSalida] ADD CONSTRAINT [CK_SolicitudSalida_Fechas] CHECK (([FechaRequerida] IS NULL OR [FechaRequerida]>=[FechaSolicitud]));
GO
CREATE NONCLUSTERED INDEX [IX_TipoAdquisicion_Activo_1477580302] ON [ALMA].[TipoAdquisicion] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoAdquisicion_Clave_1477580302] ON [ALMA].[TipoAdquisicion] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoAdquisicion_UsuarioCreacion_1477580302] ON [ALMA].[TipoAdquisicion] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoAdquisicion_UsuarioModificacion_1477580302] ON [ALMA].[TipoAdquisicion] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_TipoBaja_Clave] ON [ALMA].[TipoBaja] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoBaja_Activo_1243867498] ON [ALMA].[TipoBaja] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoBaja_Clave_1243867498] ON [ALMA].[TipoBaja] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoBaja_FKIdEstadoBienDestino_ALMA_1243867498] ON [ALMA].[TipoBaja] ([FKIdEstadoBienDestino_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoBien_Activo_1509580416] ON [ALMA].[TipoBien] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoBien_FKIdCuentaContable_CONTA_1509580416] ON [ALMA].[TipoBien] ([FKIdCuentaContable_CONTA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoBien_FKIdGrupoBien_ALMA_1509580416] ON [ALMA].[TipoBien] ([FKIdGrupoBien_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoBien_FKIdNivel_ALMA_1509580416] ON [ALMA].[TipoBien] ([FKIdNivel_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoBien_FKIdPartida_CONTA_1509580416] ON [ALMA].[TipoBien] ([FKIdPartida_CONTA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoBien_FKIdUnidades_ALMA_1509580416] ON [ALMA].[TipoBien] ([FKIdUnidades_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoBien_FKIdUnidades_Equivalente_1509580416] ON [ALMA].[TipoBien] ([FKIdUnidades_Equivalente] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoBien_UsuarioCreacion_1509580416] ON [ALMA].[TipoBien] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoBien_UsuarioModificacion_1509580416] ON [ALMA].[TipoBien] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_TipoBien_IdEmpresa_PKIdTipoBien] ON [ALMA].[TipoBien] ([IdEmpresa] ASC, [PKIdTipoBien] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoConteo_Activo_1541580530] ON [ALMA].[TipoConteo] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoPatrimonio_Activo_1573580644] ON [ALMA].[TipoPatrimonio] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoPatrimonio_UsuarioCreacion_1573580644] ON [ALMA].[TipoPatrimonio] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoPatrimonio_UsuarioModificacion_1573580644] ON [ALMA].[TipoPatrimonio] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_Transferencia_IdEmpresa_Folio] ON [ALMA].[Transferencia] ([IdEmpresa] ASC, [Folio] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_Transferencia_IdOperacion] ON [ALMA].[Transferencia] ([IdOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_Transferencia_IdEmpresa_IdTransferencia] ON [ALMA].[Transferencia] ([IdEmpresa] ASC, [IdTransferencia] ASC);
GO
ALTER TABLE [ALMA].[Transferencia] ADD CONSTRAINT [CK_EXUX_ALMA_Transferencia_1] CHECK (IdAlmacenOrigen <> IdAlmacenDestino AND IdAlmacenTransito <> IdAlmacenOrigen AND IdAlmacenTransito <> IdAlmacenDestino);
GO
ALTER TABLE [ALMA].[Transferencia] ADD CONSTRAINT [CK_EXUX_ALMA_Transferencia_2] CHECK (Estado IN ('BORRADOR','AUTORIZADA','EN_TRANSITO','PARCIAL','RECIBIDA','CANCELADA'));
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_TransferenciaDetalle_IdEmpresa_IdTransferenciaDetalle] ON [ALMA].[TransferenciaDetalle] ([IdEmpresa] ASC, [IdTransferenciaDetalle] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_TransferenciaDetalle_IdEmpresa_IdTransferenciaDetalle_IdTipoBien] ON [ALMA].[TransferenciaDetalle] ([IdEmpresa] ASC, [IdTransferenciaDetalle] ASC, [IdTipoBien] ASC);
GO
ALTER TABLE [ALMA].[TransferenciaDetalle] ADD CONSTRAINT [CK_EXUX_ALMA_TransferenciaDetalle_1] CHECK (CantidadSolicitada > 0);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_UbicacionAlmacen_IdAlmacen_Codigo] ON [ALMA].[UbicacionAlmacen] ([IdAlmacen] ASC, [Codigo] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_UbicacionAlmacen_IdEmpresa_IdUbicacionAlmacen] ON [ALMA].[UbicacionAlmacen] ([IdEmpresa] ASC, [IdUbicacionAlmacen] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_UbicacionAlmacen_IdEmpresa_IdUbicacionAlmacen_IdAlmacen] ON [ALMA].[UbicacionAlmacen] ([IdEmpresa] ASC, [IdUbicacionAlmacen] ASC, [IdAlmacen] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Unidades_Activo_1605580758] ON [ALMA].[Unidades] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Unidades_UsuarioCreacion_1605580758] ON [ALMA].[Unidades] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Unidades_UsuarioModificacion_1605580758] ON [ALMA].[Unidades] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ALMA_UsuarioAlmacen_IdUsuario_IdAlmacen] ON [ALMA].[UsuarioAlmacen] ([IdUsuario] ASC, [IdAlmacen] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_ArqueoCaja_IdEmpresa_IdArqueoCaja] ON [CAJA].[ArqueoCaja] ([IdEmpresa] ASC, [IdArqueoCaja] ASC);
GO
ALTER TABLE [CAJA].[ArqueoCaja] ADD CONSTRAINT [CK_EXUX_CAJA_ArqueoCaja_1] CHECK (SaldoFisico >= 0);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_ArqueoDetalle_IdArqueo_Denominacion] ON [CAJA].[ArqueoDetalle] ([IdArqueo] ASC, [Denominacion] ASC);
GO
ALTER TABLE [CAJA].[ArqueoDetalle] ADD CONSTRAINT [CK_EXUX_CAJA_ArqueoDetalle_1] CHECK (Denominacion > 0 AND Cantidad >= 0);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_ComprobacionCaja_IdVale_IdComprobanteGasto] ON [CAJA].[ComprobacionCaja] ([IdVale] ASC, [IdComprobanteGasto] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_ComprobacionCaja_IdEmpresa_IdComprobacionCaja] ON [CAJA].[ComprobacionCaja] ([IdEmpresa] ASC, [IdComprobacionCaja] ASC);
GO
ALTER TABLE [CAJA].[ComprobacionCaja] ADD CONSTRAINT [CK_EXUX_CAJA_ComprobacionCaja_1] CHECK (ImporteAceptado > 0);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_FondoCaja_IdEmpresa_Codigo] ON [CAJA].[FondoCaja] ([IdEmpresa] ASC, [Codigo] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_FondoCaja_IdEmpresa_IdFondoCaja] ON [CAJA].[FondoCaja] ([IdEmpresa] ASC, [IdFondoCaja] ASC);
GO
ALTER TABLE [CAJA].[FondoCaja] ADD CONSTRAINT [CK_EXUX_CAJA_FondoCaja_1] CHECK (MontoAutorizado > 0);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_MovimientoFondo_IdEmpresa_ClaveOperacion] ON [CAJA].[MovimientoFondo] ([IdEmpresa] ASC, [ClaveOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_MovimientoFondo_IdMovimientoReversa] ON [CAJA].[MovimientoFondo] ([IdMovimientoReversa] ASC) WHERE [IdMovimientoReversa] IS NOT NULL;
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_MovimientoFondo_IdEmpresa_IdMovimientoFondo] ON [CAJA].[MovimientoFondo] ([IdEmpresa] ASC, [IdMovimientoFondo] ASC);
GO
ALTER TABLE [CAJA].[MovimientoFondo] ADD CONSTRAINT [CK_EXUX_CAJA_MovimientoFondo_1] CHECK (Importe <> 0);
GO
ALTER TABLE [CAJA].[MovimientoFondo] ADD CONSTRAINT [CK_EXUX_CAJA_MovimientoFondo_2] CHECK (Tipo IN ('APERTURA','GASTO','REPOSICION','REINTEGRO','REVERSA'));
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_ReposicionCaja_IdOperacion] ON [CAJA].[ReposicionCaja] ([IdOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_ReposicionCaja_IdEmpresa_IdReposicionCaja] ON [CAJA].[ReposicionCaja] ([IdEmpresa] ASC, [IdReposicionCaja] ASC);
GO
ALTER TABLE [CAJA].[ReposicionCaja] ADD CONSTRAINT [CK_EXUX_CAJA_ReposicionCaja_1] CHECK (Importe > 0);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_ReposicionDetalle_IdComprobacionCaja] ON [CAJA].[ReposicionDetalle] ([IdComprobacionCaja] ASC);
GO
ALTER TABLE [CAJA].[ReposicionDetalle] ADD CONSTRAINT [CK_EXUX_CAJA_ReposicionDetalle_1] CHECK (Importe > 0);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_ValeCaja_IdOperacion] ON [CAJA].[ValeCaja] ([IdOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CAJA_ValeCaja_IdEmpresa_IdValeCaja] ON [CAJA].[ValeCaja] ([IdEmpresa] ASC, [IdValeCaja] ASC);
GO
ALTER TABLE [CAJA].[ValeCaja] ADD CONSTRAINT [CK_EXUX_CAJA_ValeCaja_1] CHECK (Importe > 0);
GO
CREATE NONCLUSTERED INDEX [IX_Capitulo_Activo_1637580872] ON [CONTA].[Capitulo] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Capitulo_Clave_1637580872] ON [CONTA].[Capitulo] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Capitulo_UsuarioCreacion_1637580872] ON [CONTA].[Capitulo] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Capitulo_UsuarioModificacion_1637580872] ON [CONTA].[Capitulo] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Concepto_Activo_1669580986] ON [CONTA].[Concepto] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Concepto_Clave_1669580986] ON [CONTA].[Concepto] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Concepto_FKIdCapitulo_CONTA_1669580986] ON [CONTA].[Concepto] ([FKIdCapitulo_CONTA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Concepto_UsuarioCreacion_1669580986] ON [CONTA].[Concepto] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Concepto_UsuarioModificacion_1669580986] ON [CONTA].[Concepto] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_ConsecutivoPoliza] ON [CONTA].[ConsecutivoPoliza] ([FK_IdAnio__SIS] ASC, [FK_IdMes__SIS] ASC, [FK_IdTipoPoliza__SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ConsecutivoPoliza_Activo_1701581100] ON [CONTA].[ConsecutivoPoliza] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ConsecutivoPoliza_FK_IdAnio__SIS_1701581100] ON [CONTA].[ConsecutivoPoliza] ([FK_IdAnio__SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ConsecutivoPoliza_FK_IdTipoPoliza__SIS_1701581100] ON [CONTA].[ConsecutivoPoliza] ([FK_IdTipoPoliza__SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CuentaContable_Activo_1749581271] ON [CONTA].[CuentaContable] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CuentaContable_FKIdEmpresa_SIS_1749581271] ON [CONTA].[CuentaContable] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CuentaContable_FKIdTipoCuenta_CONTA_1749581271] ON [CONTA].[CuentaContable] ([FKIdTipoCuenta_CONTA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CuentaContable_UsuarioCreacion_1749581271] ON [CONTA].[CuentaContable] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CuentaContable_UsuarioModificacion_1749581271] ON [CONTA].[CuentaContable] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CuentaContable_ClaveOrdNormalizada_Detalle] ON [CONTA].[CuentaContable] ([ClaveOrdNormalizada] ASC, [IsCuentaDetalle] ASC) INCLUDE ([PKIdCuentaContable], [Descripcion]) WHERE ([Activo]=(1));
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CONTA_CuentaContable_FKIdEmpresa_SIS_PKIdCuentaContable] ON [CONTA].[CuentaContable] ([FKIdEmpresa_SIS] ASC, [PKIdCuentaContable] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CuentaEspecial_Clave] ON [CONTA].[CuentaEspecial] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CuentaEspecial_Activo_1035866757] ON [CONTA].[CuentaEspecial] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CuentaEspecial_Clave_1035866757] ON [CONTA].[CuentaEspecial] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CuentaEspecial_FKIdCuentaContable_CONTA_1035866757] ON [CONTA].[CuentaEspecial] ([FKIdCuentaContable_CONTA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MatrizConversion_Activo_1781581385] ON [CONTA].[MatrizConversion] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MatrizConversion_FKIdAnio_SIS_1781581385] ON [CONTA].[MatrizConversion] ([FKIdAnio_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MatrizConversion_FKIdCuentaContableAprobado_1781581385] ON [CONTA].[MatrizConversion] ([FKIdCuentaContableAprobado] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MatrizConversion_FKIdCuentaContableComprometido_1781581385] ON [CONTA].[MatrizConversion] ([FKIdCuentaContableComprometido] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MatrizConversion_FKIdCuentaContableDevengado_1781581385] ON [CONTA].[MatrizConversion] ([FKIdCuentaContableDevengado] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MatrizConversion_FKIdCuentaContableEjercido_1781581385] ON [CONTA].[MatrizConversion] ([FKIdCuentaContableEjercido] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MatrizConversion_FKIdCuentaContableGasto_1781581385] ON [CONTA].[MatrizConversion] ([FKIdCuentaContableGasto] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MatrizConversion_FKIdCuentaContableModificado_1781581385] ON [CONTA].[MatrizConversion] ([FKIdCuentaContableModificado] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MatrizConversion_FKIdCuentaContablePagado_1781581385] ON [CONTA].[MatrizConversion] ([FKIdCuentaContablePagado] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MatrizConversion_FKIdCuentaContablePorEjercer_1781581385] ON [CONTA].[MatrizConversion] ([FKIdCuentaContablePorEjercer] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MatrizConversion_FKIdPartida_SIS_1781581385] ON [CONTA].[MatrizConversion] ([FKIdPartida_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MatrizConversion_FKIdPrograma_PRES_1781581385] ON [CONTA].[MatrizConversion] ([FKIdPrograma_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MatrizConversion_UsuarioCreacion_1781581385] ON [CONTA].[MatrizConversion] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MatrizConversion_UsuarioModificacion_1781581385] ON [CONTA].[MatrizConversion] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MatrizConversion_Clasificacion_Activa] ON [CONTA].[MatrizConversion] ([FKIdAnio_SIS] ASC, [FKIdPrograma_PRES] ASC, [FKIdPartida_SIS] ASC, [FKIdTipoGasto_PRES] ASC) WHERE ([Activo]=(1));
GO
CREATE NONCLUSTERED INDEX [IX_MatrizConversion_FKIdTipoGasto_PRES] ON [CONTA].[MatrizConversion] ([FKIdTipoGasto_PRES] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_MatrizConversion_Clasificacion_Activa] ON [CONTA].[MatrizConversion] ([FKIdAnio_SIS] ASC, [FKIdPrograma_PRES] ASC, [FKIdPartida_SIS] ASC, [FKIdTipoGasto_PRES] ASC) WHERE ([Activo]=(1));
GO
CREATE NONCLUSTERED INDEX [IX_MatrizIngreso_Activo_1813581499] ON [CONTA].[MatrizIngreso] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MatrizIngreso_FK_IdAnio__SIS_1813581499] ON [CONTA].[MatrizIngreso] ([FK_IdAnio__SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MatrizIngreso_Fk_IdCuentaContableAutorizado_1813581499] ON [CONTA].[MatrizIngreso] ([Fk_IdCuentaContableAutorizado] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MatrizIngreso_Fk_IdCuentaContableDeposito_1813581499] ON [CONTA].[MatrizIngreso] ([Fk_IdCuentaContableDeposito] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MatrizIngreso_Fk_IdCuentaContableDevengado_1813581499] ON [CONTA].[MatrizIngreso] ([Fk_IdCuentaContableDevengado] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MatrizIngreso_Fk_IdCuentaContableModificado_1813581499] ON [CONTA].[MatrizIngreso] ([Fk_IdCuentaContableModificado] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MatrizIngreso_Fk_IdCuentaContablePorEjercer_1813581499] ON [CONTA].[MatrizIngreso] ([Fk_IdCuentaContablePorEjercer] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MatrizIngreso_Fk_IdCuentaContableRecaudado_1813581499] ON [CONTA].[MatrizIngreso] ([Fk_IdCuentaContableRecaudado] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MatrizIngreso_Fk_IdOrigen_1813581499] ON [CONTA].[MatrizIngreso] ([Fk_IdOrigen] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MatrizIngreso_Fk_IdPrograma_1813581499] ON [CONTA].[MatrizIngreso] ([Fk_IdPrograma] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MatrizIngreso_UsuarioCreacion_1813581499] ON [CONTA].[MatrizIngreso] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_MatrizIngreso_UsuarioModificacion_1813581499] ON [CONTA].[MatrizIngreso] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Partida_Activo_1845581613] ON [CONTA].[Partida] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Partida_Clave_1845581613] ON [CONTA].[Partida] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Partida_FKIdConcepto_SIS_1845581613] ON [CONTA].[Partida] ([FKIdConcepto_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Partida_UsuarioCreacion_1845581613] ON [CONTA].[Partida] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Partida_UsuarioModificacion_1845581613] ON [CONTA].[Partida] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Poliza_Activo_1877581727] ON [CONTA].[Poliza] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Poliza_FechaAutorizacion_1877581727] ON [CONTA].[Poliza] ([FechaAutorizacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Poliza_FechaSolicitud_1877581727] ON [CONTA].[Poliza] ([FechaSolicitud] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Poliza_FKIdAnio_SIS_1877581727] ON [CONTA].[Poliza] ([FKIdAnio_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Poliza_FKIdTipoPoliza_SIS_1877581727] ON [CONTA].[Poliza] ([FKIdTipoPoliza_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Poliza_UsuarioCreacion_1877581727] ON [CONTA].[Poliza] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Poliza_UsuarioModificacion_1877581727] ON [CONTA].[Poliza] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CONTA_Poliza_IdPolizaReversa] ON [CONTA].[Poliza] ([IdPolizaReversa] ASC) WHERE [IdPolizaReversa] IS NOT NULL;
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CONTA_Poliza_IdEmpresa_FKIdAnio_SIS_FKIdTipoPoliza_SIS_ClavePoliza] ON [CONTA].[Poliza] ([IdEmpresa] ASC, [FKIdAnio_SIS] ASC, [FKIdTipoPoliza_SIS] ASC, [ClavePoliza] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CONTA_Poliza_IdEmpresa_PKIdPoliza] ON [CONTA].[Poliza] ([IdEmpresa] ASC, [PKIdPoliza] ASC);
GO
ALTER TABLE [CONTA].[Poliza] ADD CONSTRAINT [CK_EXUX_CONTA_Poliza_NoAutorreversa] CHECK (IdPolizaReversa IS NULL OR IdPolizaReversa <> PKIdPoliza);
GO
CREATE NONCLUSTERED INDEX [IX_PolizaDetalle_Activo_1909581841] ON [CONTA].[PolizaDetalle] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PolizaDetalle_FKIdCuentaContable_CONTA_1909581841] ON [CONTA].[PolizaDetalle] ([FKIdCuentaContable_CONTA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PolizaDetalle_FKIdPoliza_CONTA_1909581841] ON [CONTA].[PolizaDetalle] ([FKIdPoliza_CONTA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PolizaDetalle_FKIdTipoDetallePoliza_SIS_1909581841] ON [CONTA].[PolizaDetalle] ([FKIdTipoDetallePoliza_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PolizaDetalle_UsuarioCreacion_1909581841] ON [CONTA].[PolizaDetalle] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PolizaDetalle_UsuarioModificacion_1909581841] ON [CONTA].[PolizaDetalle] ([UsuarioModificacion] ASC);
GO
ALTER TABLE [CONTA].[PolizaDetalle] ADD CONSTRAINT [CK_EXUX_CONTA_PolizaDetalle_DebeHaber] CHECK (ISNULL(ImporteDebe,0) >= 0 AND ISNULL(ImporteHaber,0) >= 0 AND NOT (ISNULL(ImporteDebe,0)>0 AND ISNULL(ImporteHaber,0)>0));
GO
CREATE NONCLUSTERED INDEX [IX_TipoCuenta_Activo_1941581955] ON [CONTA].[TipoCuenta] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoCuenta_UsuarioCreacion_1941581955] ON [CONTA].[TipoCuenta] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoCuenta_UsuarioModificacion_1941581955] ON [CONTA].[TipoCuenta] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoDoctoPago_Activo_1973582069] ON [CONTA].[TipoDoctoPago] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoDoctoPago_UsuarioCreacion_1973582069] ON [CONTA].[TipoDoctoPago] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoDoctoPago_UsuarioModificacion_1973582069] ON [CONTA].[TipoDoctoPago] ([UsuarioModificacion] ASC);
GO
ALTER TABLE [CTL].[CasoRiesgo] ADD CONSTRAINT [CK_EXUX_CTL_CasoRiesgo_1] CHECK (CerradoUtc IS NULL OR CerradoUtc >= AbiertoUtc);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CTL_ReglaRiesgo_IdEmpresa_Codigo_Version] ON [CTL].[ReglaRiesgo] ([IdEmpresa] ASC, [Codigo] ASC, [Version] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CTL_ReglaRiesgo_IdEmpresa_IdReglaRiesgo] ON [CTL].[ReglaRiesgo] ([IdEmpresa] ASC, [IdReglaRiesgo] ASC);
GO
ALTER TABLE [CTL].[ReglaRiesgo] ADD CONSTRAINT [CK_EXUX_CTL_ReglaRiesgo_1] CHECK (Version > 0 AND ISJSON(ParametrosJson)=1);
GO
ALTER TABLE [CTL].[ReglaRiesgo] ADD CONSTRAINT [CK_EXUX_CTL_ReglaRiesgo_2] CHECK (Hasta IS NULL OR Hasta >= Desde);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CTL_ReglaSegregacion_IdEmpresa_Codigo] ON [CTL].[ReglaSegregacion] ([IdEmpresa] ASC, [Codigo] ASC);
GO
ALTER TABLE [CTL].[ReglaSegregacion] ADD CONSTRAINT [CK_EXUX_CTL_ReglaSegregacion_1] CHECK (AccionA <> AccionB);
GO
ALTER TABLE [CTL].[ReglaSegregacion] ADD CONSTRAINT [CK_EXUX_CTL_ReglaSegregacion_2] CHECK (Hasta IS NULL OR Hasta >= Desde);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CUM_CatalogoObligacion_IdEmpresa_Codigo] ON [CUM].[CatalogoObligacion] ([IdEmpresa] ASC, [Codigo] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CUM_CatalogoObligacion_IdEmpresa_IdCatalogoObligacion] ON [CUM].[CatalogoObligacion] ([IdEmpresa] ASC, [IdCatalogoObligacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CUM_EvidenciaCumplimiento_IdVencimiento_IdDocumento] ON [CUM].[EvidenciaCumplimiento] ([IdVencimiento] ASC, [IdDocumento] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CUM_ObligacionEmpresa_IdEmpresa_IdCatalogo_IdSucursal_Desde] ON [CUM].[ObligacionEmpresa] ([IdEmpresa] ASC, [IdCatalogo] ASC, [IdSucursal] ASC, [Desde] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CUM_ObligacionEmpresa_IdEmpresa_IdObligacionEmpresa] ON [CUM].[ObligacionEmpresa] ([IdEmpresa] ASC, [IdObligacionEmpresa] ASC);
GO
ALTER TABLE [CUM].[ObligacionEmpresa] ADD CONSTRAINT [CK_EXUX_CUM_ObligacionEmpresa_1] CHECK (Hasta IS NULL OR Hasta >= Desde);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CUM_VencimientoObligacion_IdObligacion_Periodo] ON [CUM].[VencimientoObligacion] ([IdObligacion] ASC, [Periodo] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CUM_VencimientoObligacion_IdOperacion] ON [CUM].[VencimientoObligacion] ([IdOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CUM_VencimientoObligacion_IdEmpresa_IdVencimientoObligacion] ON [CUM].[VencimientoObligacion] ([IdEmpresa] ASC, [IdVencimientoObligacion] ASC);
GO
ALTER TABLE [DOC].[CampoExtraido] ADD CONSTRAINT [CK_EXUX_DOC_CampoExtraido_1] CHECK (Confianza IS NULL OR Confianza BETWEEN 0 AND 1);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_DOC_ExtraccionDocumento_IdEmpresa_IdExtraccionDocumento] ON [DOC].[ExtraccionDocumento] ([IdEmpresa] ASC, [IdExtraccionDocumento] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_DOC_OperacionDocumento_IdOperacion_IdDocumento_Rol] ON [DOC].[OperacionDocumento] ([IdOperacion] ASC, [IdDocumento] ASC, [Rol] ASC);
GO
ALTER TABLE [DOC].[OperacionDocumento] ADD CONSTRAINT [CK_EXUX_DOC_OperacionDocumento_1] CHECK (VigenteHasta IS NULL OR VigenteHasta >= VigenteDesde);
GO
ALTER TABLE [FIS].[ActualizacionRecargo] ADD CONSTRAINT [CK_EXUX_FIS_ActualizacionRecargo_1] CHECK (ISJSON(ParametrosJson)=1 AND Actualizacion >= 0 AND Recargo >= 0);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_AuditoriaFiscal_IdEmpresa_Autoridad_Expediente] ON [FIS].[AuditoriaFiscal] ([IdEmpresa] ASC, [Autoridad] ASC, [Expediente] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_AuditoriaFiscal_IdEmpresa_IdAuditoriaFiscal] ON [FIS].[AuditoriaFiscal] ([IdEmpresa] ASC, [IdAuditoriaFiscal] ASC);
GO
ALTER TABLE [FIS].[AuditoriaFiscal] ADD CONSTRAINT [CK_EXUX_FIS_AuditoriaFiscal_1] CHECK (FechaFin IS NULL OR FechaFin >= FechaInicio);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_Cfdi_IdEmpresa_UUID] ON [FIS].[Cfdi] ([IdEmpresa] ASC, [UUID] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_Cfdi_IdEmpresa_IdCfdi] ON [FIS].[Cfdi] ([IdEmpresa] ASC, [IdCfdi] ASC);
GO
ALTER TABLE [FIS].[Cfdi] ADD CONSTRAINT [CK_EXUX_FIS_Cfdi_1] CHECK (Tipo IN ('I','E','T','N','P'));
GO
ALTER TABLE [FIS].[Cfdi] ADD CONSTRAINT [CK_EXUX_FIS_Cfdi_2] CHECK (Total >= 0);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_CfdiConcepto_IdCfdi_Renglon] ON [FIS].[CfdiConcepto] ([IdCfdi] ASC, [Renglon] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_CfdiConcepto_IdEmpresa_IdCfdiConcepto] ON [FIS].[CfdiConcepto] ([IdEmpresa] ASC, [IdCfdiConcepto] ASC);
GO
ALTER TABLE [FIS].[CfdiConcepto] ADD CONSTRAINT [CK_EXUX_FIS_CfdiConcepto_1] CHECK (Renglon > 0 AND Cantidad > 0 AND ValorUnitario >= 0 AND Importe >= 0 AND Descuento >= 0);
GO
ALTER TABLE [FIS].[CfdiImpuesto] ADD CONSTRAINT [CK_EXUX_FIS_CfdiImpuesto_1] CHECK (Tipo IN ('TRASLADO','RETENCION'));
GO
ALTER TABLE [FIS].[CfdiImpuesto] ADD CONSTRAINT [CK_EXUX_FIS_CfdiImpuesto_2] CHECK (Base >= 0);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_ComprobanteGasto_IdDocumento] ON [FIS].[ComprobanteGasto] ([IdDocumento] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_ComprobanteGasto_IdCfdi] ON [FIS].[ComprobanteGasto] ([IdCfdi] ASC) WHERE [IdCfdi] IS NOT NULL;
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_ComprobanteGasto_IdEmpresa_IdComprobanteGasto] ON [FIS].[ComprobanteGasto] ([IdEmpresa] ASC, [IdComprobanteGasto] ASC);
GO
ALTER TABLE [FIS].[ComprobanteGasto] ADD CONSTRAINT [CK_EXUX_FIS_ComprobanteGasto_1] CHECK (Total > 0);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_Declaracion_IdVencimiento_Tipo] ON [FIS].[Declaracion] ([IdVencimiento] ASC, [Tipo] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_Declaracion_IdEmpresa_IdDeclaracion] ON [FIS].[Declaracion] ([IdEmpresa] ASC, [IdDeclaracion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_DeclaracionCfdi_IdDeclaracionVersion_IdCfdi] ON [FIS].[DeclaracionCfdi] ([IdDeclaracionVersion] ASC, [IdCfdi] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_DeclaracionVersion_IdDeclaracion_Version] ON [FIS].[DeclaracionVersion] ([IdDeclaracion] ASC, [Version] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_DeclaracionVersion_IdEmpresa_IdDeclaracionVersion] ON [FIS].[DeclaracionVersion] ([IdEmpresa] ASC, [IdDeclaracionVersion] ASC);
GO
ALTER TABLE [FIS].[DeclaracionVersion] ADD CONSTRAINT [CK_EXUX_FIS_DeclaracionVersion_1] CHECK (Version > 0);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_DeterminacionImpuesto_IdDeclaracionVersion_IdReglaFiscalVersion] ON [FIS].[DeterminacionImpuesto] ([IdDeclaracionVersion] ASC, [IdReglaFiscalVersion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_DeterminacionImpuesto_IdEmpresa_IdDeterminacionImpuesto] ON [FIS].[DeterminacionImpuesto] ([IdEmpresa] ASC, [IdDeterminacionImpuesto] ASC);
GO
ALTER TABLE [FIS].[DeterminacionImpuesto] ADD CONSTRAINT [CK_EXUX_FIS_DeterminacionImpuesto_1] CHECK (ResultadoJson IS NULL OR ISJSON(ResultadoJson)=1);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_EventoCfdi_IdEmpresa_ClaveOperacion] ON [FIS].[EventoCfdi] ([IdEmpresa] ASC, [ClaveOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_ObservacionFiscal_IdEmpresa_IdObservacionFiscal] ON [FIS].[ObservacionFiscal] ([IdEmpresa] ASC, [IdObservacionFiscal] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_ReglaFiscalVersion_IdEmpresa_Impuesto_Version] ON [FIS].[ReglaFiscalVersion] ([IdEmpresa] ASC, [Impuesto] ASC, [Version] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_ReglaFiscalVersion_IdEmpresa_IdReglaFiscalVersion] ON [FIS].[ReglaFiscalVersion] ([IdEmpresa] ASC, [IdReglaFiscalVersion] ASC);
GO
ALTER TABLE [FIS].[ReglaFiscalVersion] ADD CONSTRAINT [CK_EXUX_FIS_ReglaFiscalVersion_1] CHECK (Version > 0 AND ISJSON(ParametrosJson)=1);
GO
ALTER TABLE [FIS].[ReglaFiscalVersion] ADD CONSTRAINT [CK_EXUX_FIS_ReglaFiscalVersion_2] CHECK (Hasta IS NULL OR Hasta >= Desde);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_FIS_SancionFiscal_IdEmpresa_IdSancionFiscal] ON [FIS].[SancionFiscal] ([IdEmpresa] ASC, [IdSancionFiscal] ASC);
GO
ALTER TABLE [FIS].[SancionFiscal] ADD CONSTRAINT [CK_EXUX_FIS_SancionFiscal_1] CHECK (Importe >= 0);
GO
CREATE NONCLUSTERED INDEX [IX_Articulo_Activo_130099504] ON [ORCO].[Articulo] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Articulo_Clave_130099504] ON [ORCO].[Articulo] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Articulo_UsuarioCreacion_130099504] ON [ORCO].[Articulo] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Articulo_UsuarioModificacion_130099504] ON [ORCO].[Articulo] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Contratos_Activo] ON [ORCO].[Contratos] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Contratos_Numero] ON [ORCO].[Contratos] ([Numero] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Contratos_OrdenCompra_Activo] ON [ORCO].[Contratos] ([FKIdOrdenCompra_ORCO] ASC) WHERE ([Activo]=(1) AND [FKIdOrdenCompra_ORCO] IS NOT NULL);
GO
CREATE NONCLUSTERED INDEX [IX_Cotizacion_Activo_162099618] ON [ORCO].[Cotizacion] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Cotizacion_FechaSolicitud_162099618] ON [ORCO].[Cotizacion] ([FechaSolicitud] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Cotizacion_FKIdAnio_SIS_162099618] ON [ORCO].[Cotizacion] ([FKIdAnio_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Cotizacion_FKIdProveedor_SIS_162099618] ON [ORCO].[Cotizacion] ([FKIdProveedor_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Cotizacion_FKIdRequisicion_ORCO_162099618] ON [ORCO].[Cotizacion] ([FKIdRequisicion_ORCO] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Cotizacion_UsuarioCreacion_162099618] ON [ORCO].[Cotizacion] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Cotizacion_UsuarioModificacion_162099618] ON [ORCO].[Cotizacion] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ORCO_Cotizacion_IdEmpresa_PKIdCotizacion] ON [ORCO].[Cotizacion] ([IdEmpresa] ASC, [PKIdCotizacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CotizacionDetalle_Activo_194099732] ON [ORCO].[CotizacionDetalle] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CotizacionDetalle_FKIdCotizacion_ORCO_194099732] ON [ORCO].[CotizacionDetalle] ([FKIdCotizacion_ORCO] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CotizacionDetalle_FKIdRequisicionDetalle_ORCO_194099732] ON [ORCO].[CotizacionDetalle] ([FKIdRequisicionDetalle_ORCO] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CotizacionDetalle_UsuarioCreacion_194099732] ON [ORCO].[CotizacionDetalle] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CotizacionDetalle_UsuarioModificacion_194099732] ON [ORCO].[CotizacionDetalle] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ORCO_CotizacionDetalle_IdEmpresa_PKIdCotizacionDetalle] ON [ORCO].[CotizacionDetalle] ([IdEmpresa] ASC, [PKIdCotizacionDetalle] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ORCO_CriterioEvaluacion_IdEmpresa_Codigo_Version] ON [ORCO].[CriterioEvaluacion] ([IdEmpresa] ASC, [Codigo] ASC, [Version] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ORCO_CriterioEvaluacion_IdEmpresa_IdCriterioEvaluacion] ON [ORCO].[CriterioEvaluacion] ([IdEmpresa] ASC, [IdCriterioEvaluacion] ASC);
GO
ALTER TABLE [ORCO].[CriterioEvaluacion] ADD CONSTRAINT [CK_EXUX_ORCO_CriterioEvaluacion_1] CHECK (Peso BETWEEN 0 AND 1 AND Version > 0);
GO
ALTER TABLE [ORCO].[CriterioEvaluacion] ADD CONSTRAINT [CK_EXUX_ORCO_CriterioEvaluacion_2] CHECK (Hasta IS NULL OR Hasta >= Desde);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ORCO_CuentaProveedor_IdProveedorEmpresa_CLABE] ON [ORCO].[CuentaProveedor] ([IdProveedorEmpresa] ASC, [CLABE] ASC);
GO
ALTER TABLE [ORCO].[CuentaProveedor] ADD CONSTRAINT [CK_EXUX_ORCO_CuentaProveedor_1] CHECK (CLABE NOT LIKE '%[^0-9]%');
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ORCO_DestinoOrdenCompra_IdEmpresa_IdDestinoOrdenCompra] ON [ORCO].[DestinoOrdenCompra] ([IdEmpresa] ASC, [IdDestinoOrdenCompra] ASC);
GO
ALTER TABLE [ORCO].[DestinoOrdenCompra] ADD CONSTRAINT [CK_EXUX_ORCO_DestinoOrdenCompra_1] CHECK (Cantidad > 0);
GO
ALTER TABLE [ORCO].[DestinoOrdenCompra] ADD CONSTRAINT [CK_EXUX_ORCO_DestinoOrdenCompra_2] CHECK ((IdAlmacen IS NOT NULL AND IdCentroCosto IS NULL) OR (IdAlmacen IS NULL AND IdCentroCosto IS NOT NULL));
GO
CREATE NONCLUSTERED INDEX [IX_EstatusRequisicion_Activo_226099846] ON [ORCO].[EstatusRequisicion] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstatusRequisicion_UsuarioCreacion_226099846] ON [ORCO].[EstatusRequisicion] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstatusRequisicion_UsuarioModificacion_226099846] ON [ORCO].[EstatusRequisicion] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstudioMercado_Activo_258099960] ON [ORCO].[EstudioMercado] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstudioMercado_FechaSolicitud_258099960] ON [ORCO].[EstudioMercado] ([FechaSolicitud] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstudioMercado_FKIdAnio_SIS_258099960] ON [ORCO].[EstudioMercado] ([FKIdAnio_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstudioMercado_FKIdEmpresa_SIS_258099960] ON [ORCO].[EstudioMercado] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstudioMercado_FKIdResponsable_NOM_258099960] ON [ORCO].[EstudioMercado] ([FKIdResponsable_Responsable] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstudioMercado_UsuarioCreacion_258099960] ON [ORCO].[EstudioMercado] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstudioMercado_UsuarioModificacion_258099960] ON [ORCO].[EstudioMercado] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ORCO_EstudioMercado_FKIdEmpresa_SIS_PKIdEstudioMercado] ON [ORCO].[EstudioMercado] ([FKIdEmpresa_SIS] ASC, [PKIdEstudioMercado] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstudioMercadoDetalle_Activo_290100074] ON [ORCO].[EstudioMercadoDetalle] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstudioMercadoDetalle_FKIdEmpresa_SIS_290100074] ON [ORCO].[EstudioMercadoDetalle] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstudioMercadoDetalle_FKIdEstudioMercado_ORCO_290100074] ON [ORCO].[EstudioMercadoDetalle] ([FKIdEstudioMercado_ORCO] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstudioMercadoDetalle_FKIdPAAASDetalle_ORCO_290100074] ON [ORCO].[EstudioMercadoDetalle] ([FKIdPAAASDetalle_ORCO] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstudioMercadoDetalle_FKIdProveedor_SIS_290100074] ON [ORCO].[EstudioMercadoDetalle] ([FKIdProveedor_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstudioMercadoDetalle_FKIdTipoBien_ALMA_290100074] ON [ORCO].[EstudioMercadoDetalle] ([FKIdTipoBien_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstudioMercadoDetalle_UsuarioCreacion_290100074] ON [ORCO].[EstudioMercadoDetalle] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstudioMercadoDetalle_UsuarioModificacion_290100074] ON [ORCO].[EstudioMercadoDetalle] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ORCO_EstudioMercadoDetalle_FKIdEmpresa_SIS_PKIdEstudioMercadoDetalle] ON [ORCO].[EstudioMercadoDetalle] ([FKIdEmpresa_SIS] ASC, [PKIdEstudioMercadoDetalle] ASC);
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle] ADD CONSTRAINT [CK_EstudioMercadoDetalle_CostoUnitario] CHECK (([CostoUnitario] IS NULL OR [CostoUnitario]>=(0)));
GO
CREATE NONCLUSTERED INDEX [IX_EstudioMercadoDetalleCosto_Activo_322100188] ON [ORCO].[EstudioMercadoDetalleCosto] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstudioMercadoDetalleCosto_FKIdEmpresa_SIS_322100188] ON [ORCO].[EstudioMercadoDetalleCosto] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstudioMercadoDetalleCosto_FKIdEstudioMercadoDetalle_ORCO_322100188] ON [ORCO].[EstudioMercadoDetalleCosto] ([FKIdEstudioMercadoDetalle_ORCO] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstudioMercadoDetalleCosto_FKIdSolicitudCotizacion_ORCO_322100188] ON [ORCO].[EstudioMercadoDetalleCosto] ([FKIdSolicitudCotizacion_ORCO] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstudioMercadoDetalleCosto_UsuarioCreacion_322100188] ON [ORCO].[EstudioMercadoDetalleCosto] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstudioMercadoDetalleCosto_UsuarioModificacion_322100188] ON [ORCO].[EstudioMercadoDetalleCosto] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ORCO_EvaluacionOferta_IdCotizacionDetalle_IdCriterio] ON [ORCO].[EvaluacionOferta] ([IdCotizacionDetalle] ASC, [IdCriterio] ASC);
GO
ALTER TABLE [ORCO].[EvaluacionOferta] ADD CONSTRAINT [CK_EXUX_ORCO_EvaluacionOferta_1] CHECK (Puntuacion >= 0);
GO
ALTER TABLE [ORCO].[ExpedienteContratacionControl] ADD CONSTRAINT [CK_Expediente_Cotizaciones] CHECK (([NumeroCotizaciones]>=(0)));
GO
CREATE NONCLUSTERED INDEX [IX_Fraccion_Activo_354100302] ON [ORCO].[Fraccion] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Fraccion_Clave_354100302] ON [ORCO].[Fraccion] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Fraccion_FKIdArticulo_ORCO_354100302] ON [ORCO].[Fraccion] ([FKIdArticulo_ORCO] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Fraccion_UsuarioCreacion_354100302] ON [ORCO].[Fraccion] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Fraccion_UsuarioModificacion_354100302] ON [ORCO].[Fraccion] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Modalidad_Activo_386100416] ON [ORCO].[Modalidad] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Modalidad_UsuarioCreacion_386100416] ON [ORCO].[Modalidad] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Modalidad_UsuarioModificacion_386100416] ON [ORCO].[Modalidad] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_OrdenCompra_Activo_2120394623] ON [ORCO].[OrdenCompra] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_OrdenCompra_Estatus] ON [ORCO].[OrdenCompra] ([FKIdEstatusOrdenCompra_ORCO] ASC) WHERE ([Activo]=(1));
GO
CREATE NONCLUSTERED INDEX [IX_OrdenCompra_Fecha] ON [ORCO].[OrdenCompra] ([FechaOrdenCompra] ASC) WHERE ([Activo]=(1));
GO
CREATE NONCLUSTERED INDEX [IX_OrdenCompra_FKIdEmpresa_SIS_2120394623] ON [ORCO].[OrdenCompra] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_OrdenCompra_FKIdPoliza_CONTA_2120394623] ON [ORCO].[OrdenCompra] ([FKIdPoliza_CONTA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_OrdenCompra_Proveedor] ON [ORCO].[OrdenCompra] ([FKIdProveedor_SIS] ASC) WHERE ([Activo]=(1));
GO
CREATE NONCLUSTERED INDEX [IX_OrdenCompra_Requisicion] ON [ORCO].[OrdenCompra] ([FKIdRequisicion_ORCO] ASC) WHERE ([Activo]=(1));
GO
CREATE NONCLUSTERED INDEX [IX_OrdenCompra_Cotizacion] ON [ORCO].[OrdenCompra] ([FKIdCotizacion_ORCO] ASC) WHERE ([Activo]=(1));
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ORCO_OrdenCompra_IdOperacion] ON [ORCO].[OrdenCompra] ([IdOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ORCO_OrdenCompra_FKIdEmpresa_SIS_NumeroOrdenCompra] ON [ORCO].[OrdenCompra] ([FKIdEmpresa_SIS] ASC, [NumeroOrdenCompra] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ORCO_OrdenCompra_FKIdEmpresa_SIS_PKIdOrdenCompra] ON [ORCO].[OrdenCompra] ([FKIdEmpresa_SIS] ASC, [PKIdOrdenCompra] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_OrdenCompraDetalle_Activo_196911773] ON [ORCO].[OrdenCompraDetalle] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_OrdenCompraDetalle_FKIdCotizacionDetalle_ORCO_196911773] ON [ORCO].[OrdenCompraDetalle] ([FKIdCotizacionDetalle_ORCO] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_OrdenCompraDetalle_FKIdUnidades_ALMA_196911773] ON [ORCO].[OrdenCompraDetalle] ([FKIdUnidades_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_OrdenCompraDetalle_Orden] ON [ORCO].[OrdenCompraDetalle] ([FKIdOrdenCompra_ORCO] ASC) WHERE ([Activo]=(1));
GO
CREATE NONCLUSTERED INDEX [IX_OrdenCompraDetalle_RequisicionDet] ON [ORCO].[OrdenCompraDetalle] ([FKIdRequisicionDetalle_ORCO] ASC) WHERE ([Activo]=(1));
GO
CREATE NONCLUSTERED INDEX [IX_OrdenCompraDetalle_TipoBien] ON [ORCO].[OrdenCompraDetalle] ([FKIdTipoBien_ALMA] ASC) WHERE ([Activo]=(1));
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ORCO_OrdenCompraDetalle_IdEmpresa_PKIdOrdenCompraDetalle] ON [ORCO].[OrdenCompraDetalle] ([IdEmpresa] ASC, [PKIdOrdenCompraDetalle] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_OrdenCompraPartida_Activo_372912400] ON [ORCO].[OrdenCompraPartida] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_OrdenCompraPartida_FKIdFuenteFinanciamiento_PRES_372912400] ON [ORCO].[OrdenCompraPartida] ([FKIdFuenteFinanciamiento_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_OrdenCompraPartida_Orden] ON [ORCO].[OrdenCompraPartida] ([FKIdOrdenCompra_ORCO] ASC) WHERE ([Activo]=(1));
GO
CREATE NONCLUSTERED INDEX [IX_OrdenCompraPartida_Partida] ON [ORCO].[OrdenCompraPartida] ([FKIdPartida_CONTA] ASC) WHERE ([Activo]=(1));
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_PAAAS_Empresa_Area_Anio] ON [ORCO].[PAAAS] ([FKIdEmpresa_SIS] ASC, [FKIdArea_SIS] ASC, [FKIdAnio_SIS] ASC) WHERE ([Activo]=(1));
GO
CREATE NONCLUSTERED INDEX [IX_PAAAS_Activo_418100530] ON [ORCO].[PAAAS] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PAAAS_Fecha_418100530] ON [ORCO].[PAAAS] ([Fecha] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PAAAS_FKIdAnio_SIS_418100530] ON [ORCO].[PAAAS] ([FKIdAnio_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PAAAS_FKIdArea_SIS_418100530] ON [ORCO].[PAAAS] ([FKIdArea_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PAAAS_FKIdEmpresa_SIS_418100530] ON [ORCO].[PAAAS] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PAAAS_FKIdFuenteFinanciamiento_PRES_418100530] ON [ORCO].[PAAAS] ([FKIdFuenteFinanciamiento_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PAAAS_FKIdPersona_NOM_418100530] ON [ORCO].[PAAAS] ([FKIdPersona_Responsable] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PAAAS_FKIdPrograma_PRES_418100530] ON [ORCO].[PAAAS] ([FKIdPrograma_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PAAAS_FKIdProyecto_ORCO_418100530] ON [ORCO].[PAAAS] ([FKIdProyecto_ORCO] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PAAAS_UsuarioCreacion_418100530] ON [ORCO].[PAAAS] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PAAAS_UsuarioModificacion_418100530] ON [ORCO].[PAAAS] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ORCO_PAAAS_FKIdEmpresa_SIS_PKIdPAAAS] ON [ORCO].[PAAAS] ([FKIdEmpresa_SIS] ASC, [PKIdPAAAS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PAAASDetalle_Activo_466100701] ON [ORCO].[PAAASDetalle] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PAAASDetalle_FKIdEmpresa_SIS_466100701] ON [ORCO].[PAAASDetalle] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PAAASDetalle_FKIdPAAASPartida_ORCO_466100701] ON [ORCO].[PAAASDetalle] ([FKIdPAAASPartida_ORCO] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PAAASDetalle_FKIdTipoBien_ALMA_466100701] ON [ORCO].[PAAASDetalle] ([FKIdTipoBien_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PAAASDetalle_FKIdUnidades_ALMA_466100701] ON [ORCO].[PAAASDetalle] ([FKIdUnidades_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PAAASDetalle_UsuarioCreacion_466100701] ON [ORCO].[PAAASDetalle] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PAAASDetalle_UsuarioModificacion_466100701] ON [ORCO].[PAAASDetalle] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ORCO_PAAASDetalle_FKIdEmpresa_SIS_PKIdPAAASDetalle] ON [ORCO].[PAAASDetalle] ([FKIdEmpresa_SIS] ASC, [PKIdPAAASDetalle] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PAAASPartida_Activo_498100815] ON [ORCO].[PAAASPartida] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PAAASPartida_FKIdEmpresa_SIS_498100815] ON [ORCO].[PAAASPartida] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PAAASPartida_FKIdPAAAS_ORCO_498100815] ON [ORCO].[PAAASPartida] ([FKIdPAAAS_ORCO] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PAAASPartida_FKIdPartida_CONTA_498100815] ON [ORCO].[PAAASPartida] ([FKIdPartida_CONTA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PAAASPartida_UsuarioCreacion_498100815] ON [ORCO].[PAAASPartida] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PAAASPartida_UsuarioModificacion_498100815] ON [ORCO].[PAAASPartida] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ORCO_PAAASPartida_FKIdEmpresa_SIS_PKIdPAAASPartida] ON [ORCO].[PAAASPartida] ([FKIdEmpresa_SIS] ASC, [PKIdPAAASPartida] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ProcedimientoContratacion_Activo_530100929] ON [ORCO].[ProcedimientoContratacion] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ProcedimientoContratacion_UsuarioCreacion_530100929] ON [ORCO].[ProcedimientoContratacion] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ProcedimientoContratacion_UsuarioModificacion_530100929] ON [ORCO].[ProcedimientoContratacion] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ProveedorCumplimiento_ProveedorFecha] ON [ORCO].[ProveedorCumplimiento] ([FKIdProveedor_ORCO] ASC, [FechaVerificacion] DESC);
GO
ALTER TABLE [ORCO].[ProveedorCumplimiento] ADD CONSTRAINT [CK_ProveedorCumplimiento_Vigencia] CHECK (([VigenteHasta] IS NULL OR [VigenteHasta]>=[FechaVerificacion]));
GO
CREATE NONCLUSTERED INDEX [IX_Proyecto_Activo_562101043] ON [ORCO].[Proyecto] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Proyecto_UsuarioCreacion_562101043] ON [ORCO].[Proyecto] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Proyecto_UsuarioModificacion_562101043] ON [ORCO].[Proyecto] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ORCO_Recepcion_IdEmpresa_Folio] ON [ORCO].[Recepcion] ([IdEmpresa] ASC, [Folio] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ORCO_Recepcion_IdOperacion] ON [ORCO].[Recepcion] ([IdOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ORCO_Recepcion_IdEmpresa_IdRecepcion] ON [ORCO].[Recepcion] ([IdEmpresa] ASC, [IdRecepcion] ASC);
GO
ALTER TABLE [ORCO].[Recepcion] ADD CONSTRAINT [CK_EXUX_ORCO_Recepcion_1] CHECK (Estado IN ('BORRADOR','ACEPTADA','RECHAZADA','CANCELADA'));
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ORCO_RecepcionDetalle_IdEmpresa_IdRecepcionDetalle] ON [ORCO].[RecepcionDetalle] ([IdEmpresa] ASC, [IdRecepcionDetalle] ASC);
GO
ALTER TABLE [ORCO].[RecepcionDetalle] ADD CONSTRAINT [CK_EXUX_ORCO_RecepcionDetalle_1] CHECK (CantidadAceptada >= 0 AND CantidadRechazada >= 0 AND CantidadAceptada + CantidadRechazada > 0);
GO
ALTER TABLE [ORCO].[RecepcionDetalle] ADD CONSTRAINT [CK_EXUX_ORCO_RecepcionDetalle_2] CHECK (Tipo IN ('BIEN','SERVICIO'));
GO
CREATE NONCLUSTERED INDEX [IX_Requisicion_Activo_594101157] ON [ORCO].[Requisicion] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Requisicion_FKIdAnio_SIS_594101157] ON [ORCO].[Requisicion] ([FKIdAnio_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Requisicion_FKIdArea_SIS_594101157] ON [ORCO].[Requisicion] ([FKIdArea_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Requisicion_FKIdAutorizo_NOM_594101157] ON [ORCO].[Requisicion] ([FKIdAutorizo_Responsable] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Requisicion_FKIdDestinoGasto_PRES_594101157] ON [ORCO].[Requisicion] ([FKIdDestinoGasto_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Requisicion_FKIdDigitoIdentificador_PRES_594101157] ON [ORCO].[Requisicion] ([FKIdDigitoIdentificador_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Requisicion_FKIdEgresoAutorizado_PRES_594101157] ON [ORCO].[Requisicion] ([FKIdEgresoAutorizado_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Requisicion_FKIdEmpresa_SIS_594101157] ON [ORCO].[Requisicion] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Requisicion_FKIdFuenteFinanciamiento_PRES_594101157] ON [ORCO].[Requisicion] ([FKIdFuenteFinanciamiento_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Requisicion_FKIdJefeAlmacen_NOM_594101157] ON [ORCO].[Requisicion] ([FKIdJefeAlmacen_Responsable] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Requisicion_FKIdPAutorizo_NOM_594101157] ON [ORCO].[Requisicion] ([FKIdPAutorizo_Responsable] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Requisicion_FKIdPersona_NOM_594101157] ON [ORCO].[Requisicion] ([FKIdPersona_Responsable] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Requisicion_FKIdPJefeAlmacen_NOM_594101157] ON [ORCO].[Requisicion] ([FKIdPJefeAlmacen_Responsable] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Requisicion_FKIdPrograma_PRES_594101157] ON [ORCO].[Requisicion] ([FKIdPrograma_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Requisicion_FKIdProyecto_ORCO_594101157] ON [ORCO].[Requisicion] ([FKIdProyecto_ORCO] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Requisicion_FKIdPSolicita_NOM_594101157] ON [ORCO].[Requisicion] ([FKIdPSolicita_Responsable] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Requisicion_FKIdPSuficiencia_NOM_594101157] ON [ORCO].[Requisicion] ([FKIdPSuficiencia_Responsable] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Requisicion_FKIdPSuperviso_NOM_594101157] ON [ORCO].[Requisicion] ([FKIdPSuperviso_Responsable] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Requisicion_FKIdSuficiencia_PRES_594101157] ON [ORCO].[Requisicion] ([FKIdSuficiencia_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Requisicion_FKIdSuperviso_NOM_594101157] ON [ORCO].[Requisicion] ([FKIdSuperviso_Responsable] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Requisicion_FKIdTipoGasto_PRES_594101157] ON [ORCO].[Requisicion] ([FKIdTipoGasto_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Requisicion_UsuarioCreacion_594101157] ON [ORCO].[Requisicion] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Requisicion_UsuarioModificacion_594101157] ON [ORCO].[Requisicion] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ORCO_Requisicion_IdOperacion] ON [ORCO].[Requisicion] ([IdOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ORCO_Requisicion_FKIdEmpresa_SIS_PKIdRequisicion] ON [ORCO].[Requisicion] ([FKIdEmpresa_SIS] ASC, [PKIdRequisicion] ASC);
GO
ALTER TABLE [ORCO].[Requisicion] ADD CONSTRAINT [CK_EXUX_ORCO_Requisicion_Prioridad] CHECK (Prioridad BETWEEN 1 AND 5);
GO
CREATE NONCLUSTERED INDEX [IX_RequisicionDetalle_Activo_626101271] ON [ORCO].[RequisicionDetalle] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_RequisicionDetalle_FKIdEmpresa_SIS_626101271] ON [ORCO].[RequisicionDetalle] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_RequisicionDetalle_FKIdRequisicion_ORCO_626101271] ON [ORCO].[RequisicionDetalle] ([FKIdRequisicion_ORCO] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_RequisicionDetalle_FKIdTipoBien_ALMA_626101271] ON [ORCO].[RequisicionDetalle] ([FKIdTipoBien_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_RequisicionDetalle_FKIdUnidades_ALMA_626101271] ON [ORCO].[RequisicionDetalle] ([FKIdUnidades_ALMA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_RequisicionDetalle_UsuarioCreacion_626101271] ON [ORCO].[RequisicionDetalle] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_RequisicionDetalle_UsuarioModificacion_626101271] ON [ORCO].[RequisicionDetalle] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ORCO_RequisicionDetalle_FKIdEmpresa_SIS_PKIdRequisicionDetalle] ON [ORCO].[RequisicionDetalle] ([FKIdEmpresa_SIS] ASC, [PKIdRequisicionDetalle] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_RequisicionPartida_Activo_658101385] ON [ORCO].[RequisicionPartida] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_RequisicionPartida_FKIdEmpresa_SIS_658101385] ON [ORCO].[RequisicionPartida] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_RequisicionPartida_FKIdPartida_CONTA_658101385] ON [ORCO].[RequisicionPartida] ([FKIdPartida_CONTA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_RequisicionPartida_FKIdRequisicion_ORCO_658101385] ON [ORCO].[RequisicionPartida] ([FKIdRequisicion_ORCO] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_RequisicionPartida_UsuarioCreacion_658101385] ON [ORCO].[RequisicionPartida] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_RequisicionPartida_UsuarioModificacion_658101385] ON [ORCO].[RequisicionPartida] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_RequisicionPartida_EgresoAutorizado] ON [ORCO].[RequisicionPartida] ([FKIdEgresoAutorizado_PRES] ASC) INCLUDE ([FKIdRequisicion_ORCO], [FKIdPartida_CONTA], [Monto], [Activo]);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_RequisicionPartida_Activa] ON [ORCO].[RequisicionPartida] ([FKIdRequisicion_ORCO] ASC, [FKIdPartida_CONTA] ASC) WHERE ([Activo]=(1));
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudCotizacion_Activo_690101499] ON [ORCO].[SolicitudCotizacion] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudCotizacion_FechaSolicitud_690101499] ON [ORCO].[SolicitudCotizacion] ([FechaSolicitud] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudCotizacion_FKIdEmpresa_SIS_690101499] ON [ORCO].[SolicitudCotizacion] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudCotizacion_FKIdEstudioMercado_ORCO_690101499] ON [ORCO].[SolicitudCotizacion] ([FKIdEstudioMercado_ORCO] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudCotizacion_FKIdProveedor_SIS_690101499] ON [ORCO].[SolicitudCotizacion] ([FKIdProveedor_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudCotizacion_UsuarioCreacion_690101499] ON [ORCO].[SolicitudCotizacion] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudCotizacion_UsuarioModificacion_690101499] ON [ORCO].[SolicitudCotizacion] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ORCO_SolicitudCotizacion_FKIdEmpresa_SIS_PKIdSolicitudCotizacion] ON [ORCO].[SolicitudCotizacion] ([FKIdEmpresa_SIS] ASC, [PKIdSolicitudCotizacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoContrato_Activo_722101613] ON [ORCO].[TipoContrato] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoContrato_UsuarioCreacion_722101613] ON [ORCO].[TipoContrato] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoContrato_UsuarioModificacion_722101613] ON [ORCO].[TipoContrato] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoDocumento_Activo_754101727] ON [ORCO].[TipoDocumento] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoDocumento_UsuarioCreacion_754101727] ON [ORCO].[TipoDocumento] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoDocumento_UsuarioModificacion_754101727] ON [ORCO].[TipoDocumento] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoGarantia_Activo_786101841] ON [ORCO].[TipoGarantia] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoGarantia_UsuarioCreacion_786101841] ON [ORCO].[TipoGarantia] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoGarantia_UsuarioModificacion_786101841] ON [ORCO].[TipoGarantia] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PAG_AplicacionNotaCredito_IdEmpresa_ClaveOperacion] ON [PAG].[AplicacionNotaCredito] ([IdEmpresa] ASC, [ClaveOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PAG_AplicacionNotaCredito_IdAplicacionReversa] ON [PAG].[AplicacionNotaCredito] ([IdAplicacionReversa] ASC) WHERE [IdAplicacionReversa] IS NOT NULL;
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PAG_AplicacionNotaCredito_IdEmpresa_IdAplicacionNotaCredito] ON [PAG].[AplicacionNotaCredito] ([IdEmpresa] ASC, [IdAplicacionNotaCredito] ASC);
GO
ALTER TABLE [PAG].[AplicacionNotaCredito] ADD CONSTRAINT [CK_EXUX_PAG_AplicacionNotaCredito_1] CHECK (Importe <> 0);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PAG_AplicacionPago_IdEmpresa_ClaveOperacion] ON [PAG].[AplicacionPago] ([IdEmpresa] ASC, [ClaveOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PAG_AplicacionPago_IdAplicacionReversa] ON [PAG].[AplicacionPago] ([IdAplicacionReversa] ASC) WHERE [IdAplicacionReversa] IS NOT NULL;
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PAG_AplicacionPago_IdEmpresa_IdAplicacionPago] ON [PAG].[AplicacionPago] ([IdEmpresa] ASC, [IdAplicacionPago] ASC);
GO
ALTER TABLE [PAG].[AplicacionPago] ADD CONSTRAINT [CK_EXUX_PAG_AplicacionPago_1] CHECK (Importe <> 0);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PAG_CompromisoPago_IdOperacion] ON [PAG].[CompromisoPago] ([IdOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PAG_CompromisoPago_IdEmpresa_IdCompromisoPago] ON [PAG].[CompromisoPago] ([IdEmpresa] ASC, [IdCompromisoPago] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PAG_CompromisoPago_IdEmpresa_IdCompromisoPago_IdMoneda] ON [PAG].[CompromisoPago] ([IdEmpresa] ASC, [IdCompromisoPago] ASC, [IdMoneda] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PAG_CompromisoPago_IdEmpresa_Estado_Vencimiento] ON [PAG].[CompromisoPago] ([IdEmpresa] ASC, [Estado] ASC, [Vencimiento] ASC);
GO
ALTER TABLE [PAG].[CompromisoPago] ADD CONSTRAINT [CK_EXUX_PAG_CompromisoPago_1] CHECK (Importe > 0);
GO
ALTER TABLE [PAG].[CompromisoPago] ADD CONSTRAINT [CK_EXUX_PAG_CompromisoPago_2] CHECK (IdProveedorEmpresa IS NULL OR IdResponsable IS NULL);
GO
ALTER TABLE [PAG].[CompromisoPago] ADD CONSTRAINT [CK_EXUX_PAG_CompromisoPago_3] CHECK (Estado IN ('PENDIENTE','AUTORIZADO','PARCIAL','PAGADO','CANCELADO'));
GO
ALTER TABLE [PAG].[CompromisoPago] ADD CONSTRAINT [CK_EXUX_PAG_CompromisoPago_OrigenUnico] CHECK ((CASE WHEN IdFactura IS NULL THEN 0 ELSE 1 END + CASE WHEN IdReposicionCaja IS NULL THEN 0 ELSE 1 END + CASE WHEN IdAnticipoViatico IS NULL THEN 0 ELSE 1 END + CASE WHEN IdVencimientoObligacion IS NULL THEN 0 ELSE 1 END + CASE WHEN IdSancionFiscal IS NULL THEN 0 ELSE 1 END) = 1);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PAG_FacturaRecepcion_IdFacturaDetalle_IdRecepcionDetalle] ON [PAG].[FacturaRecepcion] ([IdFacturaDetalle] ASC, [IdRecepcionDetalle] ASC);
GO
ALTER TABLE [PAG].[FacturaRecepcion] ADD CONSTRAINT [CK_EXUX_PAG_FacturaRecepcion_1] CHECK (Cantidad > 0 AND ImporteConciliado >= 0);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PAG_NotaCredito_IdCfdi] ON [PAG].[NotaCredito] ([IdCfdi] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PAG_NotaCredito_IdEmpresa_IdNotaCredito] ON [PAG].[NotaCredito] ([IdEmpresa] ASC, [IdNotaCredito] ASC);
GO
ALTER TABLE [PAG].[NotaCredito] ADD CONSTRAINT [CK_EXUX_PAG_NotaCredito_1] CHECK (Importe > 0);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PAG_Pago_IdEmpresa_ClaveOperacion] ON [PAG].[Pago] ([IdEmpresa] ASC, [ClaveOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PAG_Pago_IdOperacion] ON [PAG].[Pago] ([IdOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PAG_Pago_IdEmpresa_IdPago] ON [PAG].[Pago] ([IdEmpresa] ASC, [IdPago] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PAG_Pago_IdEmpresa_IdPago_IdMoneda] ON [PAG].[Pago] ([IdEmpresa] ASC, [IdPago] ASC, [IdMoneda] ASC);
GO
ALTER TABLE [PAG].[Pago] ADD CONSTRAINT [CK_EXUX_PAG_Pago_1] CHECK (Importe > 0);
GO
ALTER TABLE [PAG].[Pago] ADD CONSTRAINT [CK_EXUX_PAG_Pago_2] CHECK (IdProveedorEmpresa IS NULL OR IdResponsable IS NULL);
GO
ALTER TABLE [PAG].[Pago] ADD CONSTRAINT [CK_EXUX_PAG_Pago_3] CHECK (Estado IN ('BORRADOR','AUTORIZADO','ENVIADO','CONFIRMADO','RECHAZADO','CANCELADO'));
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PAG_PagoPoliza_IdPago_IdPoliza] ON [PAG].[PagoPoliza] ([IdPago] ASC, [IdPoliza] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PAG_ProgramacionPago_IdCompromiso_Version] ON [PAG].[ProgramacionPago] ([IdCompromiso] ASC, [Version] ASC);
GO
ALTER TABLE [PAG].[ProgramacionPago] ADD CONSTRAINT [CK_EXUX_PAG_ProgramacionPago_1] CHECK (Version > 0 AND Prioridad BETWEEN 1 AND 5);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PAT_DepreciacionBienPeriodo_IdBien_Ejercicio_Mes] ON [PAT].[DepreciacionBienPeriodo] ([IdBien] ASC, [Ejercicio] ASC, [Mes] ASC);
GO
ALTER TABLE [PAT].[DepreciacionBienPeriodo] ADD CONSTRAINT [CK_EXUX_PAT_DepreciacionBienPeriodo_1] CHECK (Mes BETWEEN 1 AND 12 AND Base >= 0 AND Importe >= 0);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PAT_HistorialUbicacionBien_IdBien] ON [PAT].[HistorialUbicacionBien] ([IdBien] ASC) WHERE [Hasta] IS NULL;
GO
ALTER TABLE [PAT].[HistorialUbicacionBien] ADD CONSTRAINT [CK_EXUX_PAT_HistorialUbicacionBien_1] CHECK ((IdUbicacionPatrimonial IS NOT NULL AND IdUbicacionAlmacen IS NULL) OR (IdUbicacionPatrimonial IS NULL AND IdUbicacionAlmacen IS NOT NULL));
GO
ALTER TABLE [PAT].[HistorialUbicacionBien] ADD CONSTRAINT [CK_EXUX_PAT_HistorialUbicacionBien_2] CHECK (Hasta IS NULL OR Hasta > Desde);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PAT_IdentificadorBien_IdEmpresa_Tipo_Codigo] ON [PAT].[IdentificadorBien] ([IdEmpresa] ASC, [Tipo] ASC, [Codigo] ASC);
GO
ALTER TABLE [PAT].[IdentificadorBien] ADD CONSTRAINT [CK_EXUX_PAT_IdentificadorBien_1] CHECK (Tipo IN ('QR','BARRAS','RFID'));
GO
ALTER TABLE [PAT].[IdentificadorBien] ADD CONSTRAINT [CK_EXUX_PAT_IdentificadorBien_2] CHECK (Hasta IS NULL OR Hasta >= Desde);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PAT_InmuebleDetalle_IdBien] ON [PAT].[InmuebleDetalle] ([IdBien] ASC);
GO
ALTER TABLE [PAT].[InmuebleDetalle] ADD CONSTRAINT [CK_EXUX_PAT_InmuebleDetalle_1] CHECK (Superficie IS NULL OR Superficie > 0);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PAT_PoliticaDepreciacionVersion_IdEmpresa_Codigo_Version] ON [PAT].[PoliticaDepreciacionVersion] ([IdEmpresa] ASC, [Codigo] ASC, [Version] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PAT_PoliticaDepreciacionVersion_IdEmpresa_IdPoliticaDepreciacionVersion] ON [PAT].[PoliticaDepreciacionVersion] ([IdEmpresa] ASC, [IdPoliticaDepreciacionVersion] ASC);
GO
ALTER TABLE [PAT].[PoliticaDepreciacionVersion] ADD CONSTRAINT [CK_EXUX_PAT_PoliticaDepreciacionVersion_1] CHECK (Version > 0 AND VidaUtilMeses > 0 AND PorcentajeResidual BETWEEN 0 AND 1);
GO
ALTER TABLE [PAT].[PoliticaDepreciacionVersion] ADD CONSTRAINT [CK_EXUX_PAT_PoliticaDepreciacionVersion_2] CHECK (Hasta IS NULL OR Hasta >= Desde);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PAT_UbicacionPatrimonial_IdEmpresa_IdSucursal_Codigo] ON [PAT].[UbicacionPatrimonial] ([IdEmpresa] ASC, [IdSucursal] ASC, [Codigo] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PAT_UbicacionPatrimonial_IdEmpresa_IdUbicacionPatrimonial] ON [PAT].[UbicacionPatrimonial] ([IdEmpresa] ASC, [IdUbicacionPatrimonial] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PBR_AuditoriaCambio_IdEmpresa_IdOperacion_FechaCreacion] ON [PBR].[AuditoriaCambio] ([IdEmpresa] ASC, [IdOperacion] ASC, [FechaCreacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PBR_WorkflowEstado_IdEmpresa_PKIdWorkflowEstado] ON [PBR].[WorkflowEstado] ([IdEmpresa] ASC, [PKIdWorkflowEstado] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PBR_WorkflowEstado_IdEmpresa_FKIdWorkflowTemplate_PBR_PKIdWorkflowEstado] ON [PBR].[WorkflowEstado] ([IdEmpresa] ASC, [FKIdWorkflowTemplate_PBR] ASC, [PKIdWorkflowEstado] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PBR_WorkflowTemplate_IdEmpresa_PKIdWorkflowTemplate] ON [PBR].[WorkflowTemplate] ([IdEmpresa] ASC, [PKIdWorkflowTemplate] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_AccionAdecuacionMaster_Activo_1650820943] ON [PRES].[AccionAdecuacionMaster] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_AutorizacionSuficiencia_Activo_818101955] ON [PRES].[AutorizacionSuficiencia] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_AutorizacionSuficiencia_AutorizadoPor_NOM_818101955] ON [PRES].[AutorizacionSuficiencia] ([AutorizadoPor_Responsable] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_AutorizacionSuficiencia_FechaAutorizacion_818101955] ON [PRES].[AutorizacionSuficiencia] ([FechaAutorizacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_AutorizacionSuficiencia_FKIdEmpresa_SIS_818101955] ON [PRES].[AutorizacionSuficiencia] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_AutorizacionSuficiencia_FKIdSolicitudSuficiencia_PRES_818101955] ON [PRES].[AutorizacionSuficiencia] ([FKIdSolicitudSuficiencia_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_AutorizacionSuficiencia_UsuarioCreacion_818101955] ON [PRES].[AutorizacionSuficiencia] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_AutorizacionSuficiencia_UsuarioModificacion_818101955] ON [PRES].[AutorizacionSuficiencia] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PRES_AutorizacionSuficiencia_FKIdEmpresa_SIS_PKIdAutorizacionSuficiencia] ON [PRES].[AutorizacionSuficiencia] ([FKIdEmpresa_SIS] ASC, [PKIdAutorizacionSuficiencia] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_AutorizacionSuficienciaDetalle_Activo_850102069] ON [PRES].[AutorizacionSuficienciaDetalle] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_AutorizacionSuficienciaDetalle_FKIdAutorizacionSuficiencia_PRES_850102069] ON [PRES].[AutorizacionSuficienciaDetalle] ([FKIdAutorizacionSuficiencia_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_AutorizacionSuficienciaDetalle_FKIdEmpresa_SIS_850102069] ON [PRES].[AutorizacionSuficienciaDetalle] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_AutorizacionSuficienciaDetalle_FKIdPartida_CONTA_850102069] ON [PRES].[AutorizacionSuficienciaDetalle] ([FKIdPartida_CONTA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_AutorizacionSuficienciaDetalle_FKIdSolicitudSuficienciaDetalle_PRES_850102069] ON [PRES].[AutorizacionSuficienciaDetalle] ([FKIdSolicitudSuficienciaDetalle_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_AutorizacionSuficienciaDetalle_UsuarioCreacion_850102069] ON [PRES].[AutorizacionSuficienciaDetalle] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_AutorizacionSuficienciaDetalle_UsuarioModificacion_850102069] ON [PRES].[AutorizacionSuficienciaDetalle] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PRES_AutorizacionSuficienciaDetalle_FKIdEmpresa_SIS_PKIdAutorizacionSuficienciaDetalle] ON [PRES].[AutorizacionSuficienciaDetalle] ([FKIdEmpresa_SIS] ASC, [PKIdAutorizacionSuficienciaDetalle] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CLC_Activo_946102411] ON [PRES].[CLC] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CLC_FechaAutorizacion_946102411] ON [PRES].[CLC] ([FechaAutorizacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CLC_FechaSolicitud_946102411] ON [PRES].[CLC] ([FechaSolicitud] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CLC_FKIdContrato_PRES_946102411] ON [PRES].[CLC] ([FKIdContrato_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CLC_FKIdEmpresa_SIS_946102411] ON [PRES].[CLC] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CLC_FKIdPoliza_CONTA_946102411] ON [PRES].[CLC] ([FKIdPoliza_CONTA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CLC_UsuarioCreacion_946102411] ON [PRES].[CLC] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CLC_UsuarioModificacion_946102411] ON [PRES].[CLC] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PRES_CLC_IdOperacion] ON [PRES].[CLC] ([IdOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PRES_CLC_FKIdEmpresa_SIS_PKIdCLC] ON [PRES].[CLC] ([FKIdEmpresa_SIS] ASC, [PKIdCLC] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CLCDetalle_Activo_978102525] ON [PRES].[CLCDetalle] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CLCDetalle_FKIdCLC_PRES_978102525] ON [PRES].[CLCDetalle] ([FKIdCLC_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CLCDetalle_FKIdContratoDetalle_PRES_978102525] ON [PRES].[CLCDetalle] ([FKIdContratoDetalle_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CLCDetalle_FKIdEmpresa_SIS_978102525] ON [PRES].[CLCDetalle] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CLCDetalle_FKIdPartida_CONTA_978102525] ON [PRES].[CLCDetalle] ([FKIdPartida_CONTA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CLCDetalle_UsuarioCreacion_978102525] ON [PRES].[CLCDetalle] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CLCDetalle_UsuarioModificacion_978102525] ON [PRES].[CLCDetalle] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PRES_CLCDetalle_FKIdEmpresa_SIS_PKIdCLCDetalle] ON [PRES].[CLCDetalle] ([FKIdEmpresa_SIS] ASC, [PKIdCLCDetalle] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CLCFactura_Activo_1010102639] ON [PRES].[CLCFactura] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CLCFactura_FKIdCLC_PRES_1010102639] ON [PRES].[CLCFactura] ([FKIdCLC_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CLCFactura_FKIdEmpresa_SIS_1010102639] ON [PRES].[CLCFactura] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CLCFactura_FKIdFactura_PRES_1010102639] ON [PRES].[CLCFactura] ([FKIdFactura_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CLCFactura_FKIdFacturaDetalle_PRES_1010102639] ON [PRES].[CLCFactura] ([FKIdFacturaDetalle_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CLCFactura_UsuarioCreacion_1010102639] ON [PRES].[CLCFactura] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CLCFactura_UsuarioModificacion_1010102639] ON [PRES].[CLCFactura] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Cheque_Activo_882102183] ON [PRES].[Cheque] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Cheque_FKIdCLC_PRES_882102183] ON [PRES].[Cheque] ([FKIdCLC_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Cheque_FKIdCuentaBancaria_TES_882102183] ON [PRES].[Cheque] ([FKIdCuentaBancaria_TES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Cheque_FKIdEmpresa_SIS_882102183] ON [PRES].[Cheque] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Cheque_FKIdPoliza_CONTA_882102183] ON [PRES].[Cheque] ([FKIdPoliza_CONTA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Cheque_UsuarioCreacion_882102183] ON [PRES].[Cheque] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Cheque_UsuarioModificacion_882102183] ON [PRES].[Cheque] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Cheque_Entidad_Cuenta_Numero] ON [PRES].[Cheque] ([FKIdEmpresa_SIS] ASC, [FKIdCuentaBancaria_TES] ASC, [NumeroCheque] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PRES_Cheque_IdPago] ON [PRES].[Cheque] ([IdPago] ASC) WHERE [IdPago] IS NOT NULL;
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PRES_Cheque_FKIdEmpresa_SIS_PKIdCheque] ON [PRES].[Cheque] ([FKIdEmpresa_SIS] ASC, [PKIdCheque] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ChequePartidas_Activo_914102297] ON [PRES].[ChequePartidas] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ChequePartidas_FKIdCheque_PRES_914102297] ON [PRES].[ChequePartidas] ([FKIdCheque_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ChequePartidas_FKIdCLCDetalle_PRES_914102297] ON [PRES].[ChequePartidas] ([FKIdCLCDetalle_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ChequePartidas_FKIdEmpresa_SIS_914102297] ON [PRES].[ChequePartidas] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ChequePartidas_FKIdPartida_CONTA_914102297] ON [PRES].[ChequePartidas] ([FKIdPartida_CONTA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ChequePartidas_UsuarioCreacion_914102297] ON [PRES].[ChequePartidas] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ChequePartidas_UsuarioModificacion_914102297] ON [PRES].[ChequePartidas] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Contrato_Activo_1042102753] ON [PRES].[Contrato] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Contrato_FKIdAutorizacionSuficiencia_PRES_1042102753] ON [PRES].[Contrato] ([FKIdAutorizacionSuficiencia_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Contrato_FKIdEmpresa_SIS_1042102753] ON [PRES].[Contrato] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Contrato_FKIdPoliza_CONTA_1042102753] ON [PRES].[Contrato] ([FKIdPoliza_CONTA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Contrato_FKIdProveedor_SIS_1042102753] ON [PRES].[Contrato] ([FKIdProveedor_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Contrato_UsuarioCreacion_1042102753] ON [PRES].[Contrato] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Contrato_UsuarioModificacion_1042102753] ON [PRES].[Contrato] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Contrato_Autorizacion_Activo] ON [PRES].[Contrato] ([FKIdAutorizacionSuficiencia_PRES] ASC) WHERE ([Activo]=(1));
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PRES_Contrato_FKIdEmpresa_SIS_PKIdContrato] ON [PRES].[Contrato] ([FKIdEmpresa_SIS] ASC, [PKIdContrato] ASC);
GO
ALTER TABLE [PRES].[Contrato] ADD CONSTRAINT [CK_Contrato_Fechas] CHECK (([FechaInicioVigencia] IS NULL OR [FechaFinVigencia] IS NULL OR [FechaInicioVigencia]<=[FechaFinVigencia]));
GO
CREATE NONCLUSTERED INDEX [IX_ContratoDetalle_Activo_1074102867] ON [PRES].[ContratoDetalle] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ContratoDetalle_FKIdAutorizacionSuficienciaDetalle_PRES_1074102867] ON [PRES].[ContratoDetalle] ([FKIdAutorizacionSuficienciaDetalle_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ContratoDetalle_FKIdContrato_PRES_1074102867] ON [PRES].[ContratoDetalle] ([FKIdContrato_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ContratoDetalle_FKIdEmpresa_SIS_1074102867] ON [PRES].[ContratoDetalle] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ContratoDetalle_FKIdPartida_CONTA_1074102867] ON [PRES].[ContratoDetalle] ([FKIdPartida_CONTA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ContratoDetalle_UsuarioCreacion_1074102867] ON [PRES].[ContratoDetalle] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ContratoDetalle_UsuarioModificacion_1074102867] ON [PRES].[ContratoDetalle] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PRES_ContratoDetalle_FKIdEmpresa_SIS_PKIdContratoDetalle] ON [PRES].[ContratoDetalle] ([FKIdEmpresa_SIS] ASC, [PKIdContratoDetalle] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Deposito_CLCFactura_Activo] ON [PRES].[Deposito] ([FKIdCLCFactura_PRES] ASC) WHERE ([Activo]=(1) AND [FKIdCLCFactura_PRES] IS NOT NULL);
GO
CREATE NONCLUSTERED INDEX [IX_DestinoGasto_Activo_1106102981] ON [PRES].[DestinoGasto] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_DestinoGasto_Clave_1106102981] ON [PRES].[DestinoGasto] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_DestinoGasto_UsuarioCreacion_1106102981] ON [PRES].[DestinoGasto] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_DestinoGasto_UsuarioModificacion_1106102981] ON [PRES].[DestinoGasto] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_DigitoIdentificador_Activo_1138103095] ON [PRES].[DigitoIdentificador] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_DigitoIdentificador_Clave_1138103095] ON [PRES].[DigitoIdentificador] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_DigitoIdentificador_UsuarioCreacion_1138103095] ON [PRES].[DigitoIdentificador] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_DigitoIdentificador_UsuarioModificacion_1138103095] ON [PRES].[DigitoIdentificador] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgreAdecuacion_Activo_Autorizado] ON [PRES].[EgreAdecuacion] ([Activo] ASC, [Autorizado] ASC, [FKIdAnio_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgreAdecuacion_Clave_175339689] ON [PRES].[EgreAdecuacion] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgreAdecuacion_Fecha_175339689] ON [PRES].[EgreAdecuacion] ([Fecha] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgreAdecuacion_FechaAutorizacion_175339689] ON [PRES].[EgreAdecuacion] ([FechaAutorizacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgreAdecuacion_FechaSolicitud_175339689] ON [PRES].[EgreAdecuacion] ([FechaSolicitud] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgreAdecuacion_FKIdAccionAdecuacionMaster_PRES_175339689] ON [PRES].[EgreAdecuacion] ([FKIdAccionAdecuacionMaster_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgreAdecuacion_FKIdEstatusAdecuacion_PRES_175339689] ON [PRES].[EgreAdecuacion] ([FKIdEstatusAdecuacion_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgreAdecuacion_FKIdTipoAdecuacion_PRES_175339689] ON [PRES].[EgreAdecuacion] ([FKIdTipoAdecuacion_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgreAdecuacion_Contexto] ON [PRES].[EgreAdecuacion] ([FKIdEmpresa_SIS] ASC, [FKIdAnio_SIS] ASC, [Activo] ASC, [FKIdAccionAdecuacionMaster_PRES] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PRES_EgreAdecuacion_IdOperacion] ON [PRES].[EgreAdecuacion] ([IdOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PRES_EgreAdecuacion_FKIdEmpresa_SIS_PKIdEgreAdecuacion] ON [PRES].[EgreAdecuacion] ([FKIdEmpresa_SIS] ASC, [PKIdEgreAdecuacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgreAdecuacionDetalle_Disponible] ON [PRES].[EgreAdecuacionDetalle] ([Activo] ASC, [FKIdEgresoAutorizado_PRES] ASC, [FKIdEgreAdecuacion_PRES] ASC) INCLUDE ([Enero], [Febrero], [Marzo], [Abril], [Mayo], [Junio], [Julio], [Agosto], [Septiembre], [Octubre], [Noviembre], [Diciembre]);
GO
CREATE NONCLUSTERED INDEX [IX_EgreAdecuacionDetalle_Fecha_255339974] ON [PRES].[EgreAdecuacionDetalle] ([Fecha] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgreAdecuacionDetalle_FKIdTipoMovimiento_PRES_255339974] ON [PRES].[EgreAdecuacionDetalle] ([FKIdTipoMovimiento_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoAutorizado_Activo_1170103209] ON [PRES].[EgresoAutorizado] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoAutorizado_Fecha_1170103209] ON [PRES].[EgresoAutorizado] ([Fecha] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoAutorizado_FechaAutorizacion_1170103209] ON [PRES].[EgresoAutorizado] ([FechaAutorizacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoAutorizado_FKIdArea_SIS_1170103209] ON [PRES].[EgresoAutorizado] ([FKIdArea_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoAutorizado_FKIdDestinoGasto_PRES_1170103209] ON [PRES].[EgresoAutorizado] ([FKIdDestinoGasto_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoAutorizado_FKIdDigitoIdentificador_PRES_1170103209] ON [PRES].[EgresoAutorizado] ([FKIdDigitoIdentificador_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoAutorizado_FKIdEgresoProyectado_PRES_1170103209] ON [PRES].[EgresoAutorizado] ([FKIdEgresoProyectado_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoAutorizado_FKIdFuenteFinanciamiento_PRES_1170103209] ON [PRES].[EgresoAutorizado] ([FKIdFuenteFinanciamiento_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoAutorizado_FKIdPartida_CONTA_1170103209] ON [PRES].[EgresoAutorizado] ([FKIdPartida_CONTA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoAutorizado_FKIdPoliza_CONTA_1170103209] ON [PRES].[EgresoAutorizado] ([FKIdPoliza_CONTA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoAutorizado_FKIdPrograma_PRES_1170103209] ON [PRES].[EgresoAutorizado] ([FKIdPrograma_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoAutorizado_FKIdPY_PRES_1170103209] ON [PRES].[EgresoAutorizado] ([FKIdPY_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoAutorizado_FKIdTipoGasto_PRES_1170103209] ON [PRES].[EgresoAutorizado] ([FKIdTipoGasto_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoAutorizado_UsuarioAutorizacion_1170103209] ON [PRES].[EgresoAutorizado] ([UsuarioAutorizacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoAutorizado_UsuarioCreacion_1170103209] ON [PRES].[EgresoAutorizado] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoAutorizado_UsuarioModificacion_1170103209] ON [PRES].[EgresoAutorizado] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoAutorizado_FKIdEmpresa_SIS] ON [PRES].[EgresoAutorizado] ([FKIdEmpresa_SIS] ASC, [Activo] ASC, [Fecha] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PRES_EgresoAutorizado_IdOperacion] ON [PRES].[EgresoAutorizado] ([IdOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PRES_EgresoAutorizado_FKIdEmpresa_SIS_PKIdEgresoAutorizado] ON [PRES].[EgresoAutorizado] ([FKIdEmpresa_SIS] ASC, [PKIdEgresoAutorizado] ASC);
GO
ALTER TABLE [PRES].[EgresoAutorizado] ADD CONSTRAINT [CK_EgresoAutorizado_Monto] CHECK (([Enero]>=(0) AND [Febrero]>=(0) AND [Marzo]>=(0) AND [Abril]>=(0) AND [Mayo]>=(0) AND [Junio]>=(0) AND [Julio]>=(0) AND [Agosto]>=(0) AND [Septiembre]>=(0) AND [Octubre]>=(0) AND [Noviembre]>=(0) AND [Diciembre]>=(0)));
GO
CREATE NONCLUSTERED INDEX [IX_EgresoProyectado_Activo_1202103323] ON [PRES].[EgresoProyectado] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoProyectado_Fecha_1202103323] ON [PRES].[EgresoProyectado] ([Fecha] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoProyectado_FKIdArea_SIS_1202103323] ON [PRES].[EgresoProyectado] ([FKIdArea_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoProyectado_FKIdDestinoGasto_PRES_1202103323] ON [PRES].[EgresoProyectado] ([FKIdDestinoGasto_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoProyectado_FKIdDigitoIdentificador_PRES_1202103323] ON [PRES].[EgresoProyectado] ([FKIdDigitoIdentificador_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoProyectado_FKIdFuenteFinanciamiento_PRES_1202103323] ON [PRES].[EgresoProyectado] ([FKIdFuenteFinanciamiento_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoProyectado_FKIdPartida_CONTA_1202103323] ON [PRES].[EgresoProyectado] ([FKIdPartida_CONTA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoProyectado_FKIdPrograma_PRES_1202103323] ON [PRES].[EgresoProyectado] ([FKIdPrograma_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoProyectado_FKIdPY_PRES_1202103323] ON [PRES].[EgresoProyectado] ([FKIdPY_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoProyectado_FKIdTipoGasto_PRES_1202103323] ON [PRES].[EgresoProyectado] ([FKIdTipoGasto_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoProyectado_UsuarioCreacion_1202103323] ON [PRES].[EgresoProyectado] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoProyectado_UsuarioModificacion_1202103323] ON [PRES].[EgresoProyectado] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EgresoProyectado_FKIdEmpresa_SIS] ON [PRES].[EgresoProyectado] ([FKIdEmpresa_SIS] ASC, [Activo] ASC, [Fecha] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PRES_EgresoProyectado_FKIdEmpresa_SIS_PKIdEgresoProyectado] ON [PRES].[EgresoProyectado] ([FKIdEmpresa_SIS] ASC, [PKIdEgresoProyectado] ASC);
GO
ALTER TABLE [PRES].[EgresoProyectado] ADD CONSTRAINT [CK_EgresoProyectado_Monto] CHECK (([Enero]>=(0) AND [Febrero]>=(0) AND [Marzo]>=(0) AND [Abril]>=(0) AND [Mayo]>=(0) AND [Junio]>=(0) AND [Julio]>=(0) AND [Agosto]>=(0) AND [Septiembre]>=(0) AND [Octubre]>=(0) AND [Noviembre]>=(0) AND [Diciembre]>=(0)));
GO
CREATE NONCLUSTERED INDEX [IX_Eje_Activo_1234103437] ON [PRES].[Eje] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Eje_Clave_1234103437] ON [PRES].[Eje] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstatusAdecuacion_Activo_1570820658] ON [PRES].[EstatusAdecuacion] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_FN_Activo_1362103893] ON [PRES].[FN] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_FN_Clave_1362103893] ON [PRES].[FN] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_FN_FKIdGF_PRES_1362103893] ON [PRES].[FN] ([FKIdGF_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_FN_UsuarioCreacion_1362103893] ON [PRES].[FN] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_FN_UsuarioModificacion_1362103893] ON [PRES].[FN] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Factura_Activo_1266103551] ON [PRES].[Factura] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Factura_FKIdContrato_PRES_1266103551] ON [PRES].[Factura] ([FKIdContrato_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Factura_FKIdEmpresa_SIS_1266103551] ON [PRES].[Factura] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Factura_FKIdPoliza_CONTA_1266103551] ON [PRES].[Factura] ([FKIdPoliza_CONTA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Factura_UsuarioCreacion_1266103551] ON [PRES].[Factura] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Factura_UsuarioModificacion_1266103551] ON [PRES].[Factura] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Factura_Entidad_UUID] ON [PRES].[Factura] ([FKIdEmpresa_SIS] ASC, [UUID] ASC) WHERE ([UUID] IS NOT NULL);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PRES_Factura_IdCfdi] ON [PRES].[Factura] ([IdCfdi] ASC) WHERE [IdCfdi] IS NOT NULL;
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PRES_Factura_IdOperacion] ON [PRES].[Factura] ([IdOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PRES_Factura_FKIdEmpresa_SIS_PKIdFactura] ON [PRES].[Factura] ([FKIdEmpresa_SIS] ASC, [PKIdFactura] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_FacturaDetalle_Activo_1298103665] ON [PRES].[FacturaDetalle] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_FacturaDetalle_FKIdContratoDetalle_PRES_1298103665] ON [PRES].[FacturaDetalle] ([FKIdContratoDetalle_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_FacturaDetalle_FKIdEmpresa_SIS_1298103665] ON [PRES].[FacturaDetalle] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_FacturaDetalle_FKIdFactura_PRES_1298103665] ON [PRES].[FacturaDetalle] ([FKIdFactura_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_FacturaDetalle_FKIdPartida_CONTA_1298103665] ON [PRES].[FacturaDetalle] ([FKIdPartida_CONTA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_FacturaDetalle_UsuarioCreacion_1298103665] ON [PRES].[FacturaDetalle] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_FacturaDetalle_UsuarioModificacion_1298103665] ON [PRES].[FacturaDetalle] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PRES_FacturaDetalle_FKIdEmpresa_SIS_PKIdFacturaDetalle] ON [PRES].[FacturaDetalle] ([FKIdEmpresa_SIS] ASC, [PKIdFacturaDetalle] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Finalidad_Activo_1330103779] ON [PRES].[Finalidad] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Finalidad_Clave_1330103779] ON [PRES].[Finalidad] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_FuenteFinanciamiento_Activo_1394104007] ON [PRES].[FuenteFinanciamiento] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_FuenteFinanciamiento_Clave_1394104007] ON [PRES].[FuenteFinanciamiento] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_FuenteFinanciamiento_UsuarioCreacion_1394104007] ON [PRES].[FuenteFinanciamiento] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_FuenteFinanciamiento_UsuarioModificacion_1394104007] ON [PRES].[FuenteFinanciamiento] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_GF_Activo_1426104121] ON [PRES].[GF] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_GF_Clave_1426104121] ON [PRES].[GF] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_GF_UsuarioCreacion_1426104121] ON [PRES].[GF] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_GF_UsuarioModificacion_1426104121] ON [PRES].[GF] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_GrupoPresupuesto_Activo_1458104235] ON [PRES].[GrupoPresupuesto] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_GrupoPresupuesto_Clave_1458104235] ON [PRES].[GrupoPresupuesto] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_IngreAdecuacion_Activo_Autorizado] ON [PRES].[IngreAdecuacion] ([Activo] ASC, [Autorizado] ASC, [FKIdAnio_SIS] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_IngreAdecuacion_Clave_Activo] ON [PRES].[IngreAdecuacion] ([Clave] ASC) WHERE ([Activo]=(1));
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PRES_IngreAdecuacion_IdEmpresa_PKIdIngreAdecuacion] ON [PRES].[IngreAdecuacion] ([IdEmpresa] ASC, [PKIdIngreAdecuacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_IngreAdecuacionDetalle_Disponible] ON [PRES].[IngreAdecuacionDetalle] ([Activo] ASC, [FKIdIngresoAutorizado_PRES] ASC, [FKIdIngreAdecuacion_PRES] ASC) INCLUDE ([Enero], [Febrero], [Marzo], [Abril], [Mayo], [Junio], [Julio], [Agosto], [Septiembre], [Octubre], [Noviembre], [Diciembre]);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_IngreAdecuacionDetalle_Recurso_Movimiento_Activo] ON [PRES].[IngreAdecuacionDetalle] ([FKIdIngreAdecuacion_PRES] ASC, [FKIdIngresoAutorizado_PRES] ASC, [FKIdTipoMovimiento_PRES] ASC) WHERE ([Activo]=(1));
GO
ALTER TABLE [PRES].[IngreAdecuacionDetalle] ADD CONSTRAINT [CK_IngreAdecuacionDetalle_TipoMovimiento] CHECK (([FKIdTipoMovimiento_PRES]=(4) OR [FKIdTipoMovimiento_PRES]=(3)));
GO
ALTER TABLE [PRES].[IngreAdecuacionDetalle] ADD CONSTRAINT [CK_IngreAdecuacionDetalle_Signo] CHECK (([FKIdTipoMovimiento_PRES]=(3) AND [Enero]>=(0) AND [Febrero]>=(0) AND [Marzo]>=(0) AND [Abril]>=(0) AND [Mayo]>=(0) AND [Junio]>=(0) AND [Julio]>=(0) AND [Agosto]>=(0) AND [Septiembre]>=(0) AND [Octubre]>=(0) AND [Noviembre]>=(0) AND [Diciembre]>=(0) OR [FKIdTipoMovimiento_PRES]=(4) AND [Enero]<=(0) AND [Febrero]<=(0) AND [Marzo]<=(0) AND [Abril]<=(0) AND [Mayo]<=(0) AND [Junio]<=(0) AND [Julio]<=(0) AND [Agosto]<=(0) AND [Septiembre]<=(0) AND [Octubre]<=(0) AND [Noviembre]<=(0) AND [Diciembre]<=(0)));
GO
CREATE NONCLUSTERED INDEX [IX_IngresoAutorizado_Vw_IngresoAutorizado] ON [PRES].[IngresoAutorizado] ([Activo] ASC, [FKIdPrograma_PRES] ASC) INCLUDE ([FKIdOrigen_PRES], [FKIdFuenteFinanciamiento_PRES], [FKIdTipoGasto_PRES], [FKIdDigitoIdentificador_PRES], [FKIdDestinoGasto_PRES], [FKIdPoliza_CONTA], [Fecha], [Enero], [Febrero], [Marzo], [Abril], [Mayo], [Junio], [Julio], [Agosto], [Septiembre], [Octubre], [Noviembre], [Diciembre]);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PRES_IngresoAutorizado_IdEmpresa_PKIdIngresoAutorizado] ON [PRES].[IngresoAutorizado] ([IdEmpresa] ASC, [PKIdIngresoAutorizado] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Origen_Activo_1490104349] ON [PRES].[Origen] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Origen_Clave_1490104349] ON [PRES].[Origen] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Origen_UsuarioCreacion_1490104349] ON [PRES].[Origen] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Origen_UsuarioModificacion_1490104349] ON [PRES].[Origen] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PG_Activo_1522104463] ON [PRES].[PG] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PG_Clave_1522104463] ON [PRES].[PG] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PG_UsuarioCreacion_1522104463] ON [PRES].[PG] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PG_UsuarioModificacion_1522104463] ON [PRES].[PG] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PP_Activo_1554104577] ON [PRES].[PP] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PP_Clave_1554104577] ON [PRES].[PP] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PP_UsuarioCreacion_1554104577] ON [PRES].[PP] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PP_UsuarioModificacion_1554104577] ON [PRES].[PP] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PY_Activo_1618104805] ON [PRES].[PY] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PY_Clave_1618104805] ON [PRES].[PY] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PY_UsuarioCreacion_1618104805] ON [PRES].[PY] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PY_UsuarioModificacion_1618104805] ON [PRES].[PY] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PRES_PresupuestoVersion_IdEmpresa_IdAnio_Version] ON [PRES].[PresupuestoVersion] ([IdEmpresa] ASC, [IdAnio] ASC, [Version] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PRES_PresupuestoVersion_IdEmpresa_IdPresupuestoVersion] ON [PRES].[PresupuestoVersion] ([IdEmpresa] ASC, [IdPresupuestoVersion] ASC);
GO
ALTER TABLE [PRES].[PresupuestoVersion] ADD CONSTRAINT [CK_EXUX_PRES_PresupuestoVersion_1] CHECK (Version > 0);
GO
ALTER TABLE [PRES].[PresupuestoVersion] ADD CONSTRAINT [CK_EXUX_PRES_PresupuestoVersion_2] CHECK (Estado IN ('BORRADOR','APROBADO','CERRADO','CANCELADO'));
GO
CREATE NONCLUSTERED INDEX [IX_Programa_Activo_1586104691] ON [PRES].[Programa] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Programa_Clave_1586104691] ON [PRES].[Programa] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Programa_UsuarioCreacion_1586104691] ON [PRES].[Programa] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Programa_UsuarioModificacion_1586104691] ON [PRES].[Programa] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Ramo_Activo_1650104919] ON [PRES].[Ramo] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Ramo_Clave_1650104919] ON [PRES].[Ramo] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Ramo_UsuarioCreacion_1650104919] ON [PRES].[Ramo] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Ramo_UsuarioModificacion_1650104919] ON [PRES].[Ramo] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_RegresoChequeSuficiencia_Cheque] ON [PRES].[RegresoChequeSuficiencia] ([FKIdCheque_PRES] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PRES_RegresoChequeSuficiencia_FKIdEmpresa_SIS_PKIdRegresoChequeSuficiencia] ON [PRES].[RegresoChequeSuficiencia] ([FKIdEmpresa_SIS] ASC, [PKIdRegresoChequeSuficiencia] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_RegresoChequeSuficienciaPoliza_Reversion] ON [PRES].[RegresoChequeSuficienciaPoliza] ([FKIdPolizaReversion_CONTA] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_RegresoChequeSuficienciaPoliza_Original] ON [PRES].[RegresoChequeSuficienciaPoliza] ([FKIdRegresoChequeSuficiencia_PRES] ASC, [FKIdPolizaOriginal_CONTA] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PRES_ReservaPresupuestal_IdEmpresa_ClaveOperacion] ON [PRES].[ReservaPresupuestal] ([IdEmpresa] ASC, [ClaveOperacion] ASC);
GO
ALTER TABLE [PRES].[ReservaPresupuestal] ADD CONSTRAINT [CK_EXUX_PRES_ReservaPresupuestal_1] CHECK (Importe > 0 AND Mes BETWEEN 1 AND 12);
GO
ALTER TABLE [PRES].[ReservaPresupuestal] ADD CONSTRAINT [CK_EXUX_PRES_ReservaPresupuestal_2] CHECK (Estado IN ('RESERVADA','COMPROMETIDA','LIBERADA','CANCELADA'));
GO
CREATE NONCLUSTERED INDEX [IX_Resultado_Activo_1682105033] ON [PRES].[Resultado] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Resultado_Clave_1682105033] ON [PRES].[Resultado] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SF_Activo_1746105261] ON [PRES].[SF] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SF_Clave_1746105261] ON [PRES].[SF] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SF_FKIdFN_PRES_1746105261] ON [PRES].[SF] ([FKIdFN_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SF_UsuarioCreacion_1746105261] ON [PRES].[SF] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SF_UsuarioModificacion_1746105261] ON [PRES].[SF] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Sector_Activo_1714105147] ON [PRES].[Sector] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Sector_Clave_1714105147] ON [PRES].[Sector] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Sector_UsuarioCreacion_1714105147] ON [PRES].[Sector] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Sector_UsuarioModificacion_1714105147] ON [PRES].[Sector] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSuficiencia_Activo_1778105375] ON [PRES].[SolicitudSuficiencia] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSuficiencia_FechaSolicitud_1778105375] ON [PRES].[SolicitudSuficiencia] ([FechaSolicitud] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSuficiencia_FKIdEmpresa_SIS_1778105375] ON [PRES].[SolicitudSuficiencia] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSuficiencia_FKIdRequisicion_ORCO_1778105375] ON [PRES].[SolicitudSuficiencia] ([FKIdRequisicion_ORCO] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSuficiencia_UsuarioCreacion_1778105375] ON [PRES].[SolicitudSuficiencia] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSuficiencia_UsuarioModificacion_1778105375] ON [PRES].[SolicitudSuficiencia] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PRES_SolicitudSuficiencia_FKIdEmpresa_SIS_PKIdSolicitudSuficiencia] ON [PRES].[SolicitudSuficiencia] ([FKIdEmpresa_SIS] ASC, [PKIdSolicitudSuficiencia] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSuficienciaDetalle_Activo_1810105489] ON [PRES].[SolicitudSuficienciaDetalle] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSuficienciaDetalle_FKIdEmpresa_SIS_1810105489] ON [PRES].[SolicitudSuficienciaDetalle] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSuficienciaDetalle_FKIdPartida_CONTA_1810105489] ON [PRES].[SolicitudSuficienciaDetalle] ([FKIdPartida_CONTA] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSuficienciaDetalle_FKIdRequisicionDetalle_ORCO_1810105489] ON [PRES].[SolicitudSuficienciaDetalle] ([FKIdRequisicionDetalle_ORCO] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSuficienciaDetalle_FKIdSolicitudSuficiencia_PRES_1810105489] ON [PRES].[SolicitudSuficienciaDetalle] ([FKIdSolicitudSuficiencia_PRES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSuficienciaDetalle_UsuarioCreacion_1810105489] ON [PRES].[SolicitudSuficienciaDetalle] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SolicitudSuficienciaDetalle_UsuarioModificacion_1810105489] ON [PRES].[SolicitudSuficienciaDetalle] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PRES_SolicitudSuficienciaDetalle_FKIdEmpresa_SIS_PKIdSolicitudSuficienciaDetalle] ON [PRES].[SolicitudSuficienciaDetalle] ([FKIdEmpresa_SIS] ASC, [PKIdSolicitudSuficienciaDetalle] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SubEje_Activo_1842105603] ON [PRES].[SubEje] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SubEje_Clave_1842105603] ON [PRES].[SubEje] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SubSector_Activo_1906105831] ON [PRES].[SubSector] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SubSector_Clave_1906105831] ON [PRES].[SubSector] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SubSubEje_Activo_1938105945] ON [PRES].[SubSubEje] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_SubSubEje_Clave_1938105945] ON [PRES].[SubSubEje] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Subresultado_Activo_1874105717] ON [PRES].[Subresultado] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Subresultado_Clave_1874105717] ON [PRES].[Subresultado] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Suficiencia_Activo_1970106059] ON [PRES].[Suficiencia] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Suficiencia_UsuarioCreacion_1970106059] ON [PRES].[Suficiencia] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Suficiencia_UsuarioModificacion_1970106059] ON [PRES].[Suficiencia] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoAdecuacion_Activo_1490820373] ON [PRES].[TipoAdecuacion] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoGasto_Activo_2002106173] ON [PRES].[TipoGasto] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoGasto_Clave_2002106173] ON [PRES].[TipoGasto] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoGasto_UsuarioCreacion_2002106173] ON [PRES].[TipoGasto] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoGasto_UsuarioModificacion_2002106173] ON [PRES].[TipoGasto] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoMovimiento_Activo_1730821228] ON [PRES].[TipoMovimiento] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoRecurso_Activo_2034106287] ON [PRES].[TipoRecurso] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoRecurso_Clave_2034106287] ON [PRES].[TipoRecurso] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoRecurso_UsuarioCreacion_2034106287] ON [PRES].[TipoRecurso] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoRecurso_UsuarioModificacion_2034106287] ON [PRES].[TipoRecurso] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_UR_Activo_2066106401] ON [PRES].[UR] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_UR_Clave_2066106401] ON [PRES].[UR] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_VertienteGasto_Activo_2098106515] ON [PRES].[VertienteGasto] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_VertienteGasto_Clave_2098106515] ON [PRES].[VertienteGasto] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ActividadInstitucional_Activo_2130106629] ON [SIS].[ActividadInstitucional] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ActividadInstitucional_Clave_2130106629] ON [SIS].[ActividadInstitucional] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ActividadInstitucional_UsuarioCreacion_2130106629] ON [SIS].[ActividadInstitucional] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_ActividadInstitucional_UsuarioModificacion_2130106629] ON [SIS].[ActividadInstitucional] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Anio_Activo_14623095] ON [SIS].[Anio] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Anio_Clave_14623095] ON [SIS].[Anio] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Anio_UsuarioCreacion_14623095] ON [SIS].[Anio] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Anio_UsuarioModificacion_14623095] ON [SIS].[Anio] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Capitulo_Activo_78623323] ON [SIS].[Capitulo] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Capitulo_Clave_78623323] ON [SIS].[Capitulo] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Capitulo_UsuarioCreacion_78623323] ON [SIS].[Capitulo] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Capitulo_UsuarioModificacion_78623323] ON [SIS].[Capitulo] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_SIS_CentroCosto_IdEmpresa_Codigo] ON [SIS].[CentroCosto] ([IdEmpresa] ASC, [Codigo] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_SIS_CentroCosto_IdEmpresa_IdCentroCosto] ON [SIS].[CentroCosto] ([IdEmpresa] ASC, [IdCentroCosto] ASC);
GO
ALTER TABLE [SIS].[CentroCosto] ADD CONSTRAINT [CK_EXUX_SIS_CentroCosto_1] CHECK (VigenciaHasta IS NULL OR VigenciaHasta >= VigenciaDesde);
GO
CREATE NONCLUSTERED INDEX [IX_Concepto_Activo_158623608] ON [SIS].[Concepto] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Concepto_Clave_158623608] ON [SIS].[Concepto] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Concepto_FKIdCapitulo_SIS_158623608] ON [SIS].[Concepto] ([FKIdCapitulo_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Concepto_UsuarioCreacion_158623608] ON [SIS].[Concepto] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Concepto_UsuarioModificacion_158623608] ON [SIS].[Concepto] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_SIS_Corporativo_Codigo] ON [SIS].[Corporativo] ([Codigo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Documento_Entidad] ON [SIS].[Documento] ([Modulo] ASC, [SubModulo] ASC, [Controlador] ASC, [Servicio] ASC, [EntidadId] ASC, [FkidEmpresaSis] ASC, [Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Documento_Fecha] ON [SIS].[Documento] ([CT_CreatedDate] DESC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_SIS_Documento_FkidEmpresaSis_PkidDocumento] ON [SIS].[Documento] ([FkidEmpresaSis] ASC, [PkidDocumento] ASC);
GO
ALTER TABLE [SIS].[Documento] ADD CONSTRAINT [CK_Documento_ModoAlmacenamiento] CHECK (([ModoAlmacenamiento]=N'FILESYSTEM' OR [ModoAlmacenamiento]=N'DATABASE'));
GO
ALTER TABLE [SIS].[Documento] ADD CONSTRAINT [CK_Documento_Storage] CHECK (([ModoAlmacenamiento]=N'DATABASE' AND [ContenidoArchivo] IS NOT NULL OR [ModoAlmacenamiento]=N'FILESYSTEM' AND [RutaRelativa] IS NOT NULL));
GO
CREATE NONCLUSTERED INDEX [IX_DocumentoAnotacion_Documento] ON [SIS].[DocumentoAnotacion] ([FkidDocumento] ASC, [Activo] ASC, [CT_CreatedDate] DESC);
GO
CREATE NONCLUSTERED INDEX [IX_DocumentoAnotacion_FkidDocumentoTipoAnotacion_43863223] ON [SIS].[DocumentoAnotacion] ([FkidDocumentoTipoAnotacion] ASC);
GO
ALTER TABLE [SIS].[DocumentoAnotacion] ADD CONSTRAINT [CK_DocumentoAnotacion_Coordenadas] CHECK ((([PosicionX] IS NULL OR [PosicionX]>=(0) AND [PosicionX]<=(1)) AND ([PosicionY] IS NULL OR [PosicionY]>=(0) AND [PosicionY]<=(1)) AND ([Ancho] IS NULL OR [Ancho]>=(0) AND [Ancho]<=(1)) AND ([Alto] IS NULL OR [Alto]>=(0) AND [Alto]<=(1))));
GO
CREATE NONCLUSTERED INDEX [IX_DocumentoEvento_Documento] ON [SIS].[DocumentoEvento] ([FkidDocumento] ASC, [CT_CreatedDate] DESC);
GO
CREATE NONCLUSTERED INDEX [IX_DocumentoExtensionPermitida_Activo_1823345560] ON [SIS].[DocumentoExtensionPermitida] ([Activo] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_DocumentoExtensionPermitida_Extension] ON [SIS].[DocumentoExtensionPermitida] ([Extension] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_DocumentoTipoAnotacion_Activo_2127346643] ON [SIS].[DocumentoTipoAnotacion] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_DocumentoTipoAnotacion_Clave_2127346643] ON [SIS].[DocumentoTipoAnotacion] ([Clave] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_DocumentoTipoAnotacion_Clave] ON [SIS].[DocumentoTipoAnotacion] ([Clave] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ__Empresa__CAFFA85E663C2C42] ON [SIS].[Empresa] ([RFC] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_SIS_EnvioWorkflow_ProcesoEntidad] ON [SIS].[EnvioWorkflow] ([Proceso] ASC, [EntidadId] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_SIS_EnvioWorkflow_IdEmpresa_PKIdEnvioWorkflow] ON [SIS].[EnvioWorkflow] ([IdEmpresa] ASC, [PKIdEnvioWorkflow] ASC);
GO
ALTER TABLE [SIS].[EnvioWorkflow] ADD CONSTRAINT [CK_SIS_EnvioWorkflow_Estado] CHECK (([Estado]='RECHAZADO' OR [Estado]='ENVIADO' OR [Estado]='PROCESANDO' OR [Estado]='PENDIENTE'));
GO
CREATE NONCLUSTERED INDEX [IX_EstatusProveedor_Activo_350624292] ON [SIS].[EstatusProveedor] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstatusProveedor_UsuarioCreacion_350624292] ON [SIS].[EstatusProveedor] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_EstatusProveedor_UsuarioModificacion_350624292] ON [SIS].[EstatusProveedor] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ__Idioma__ECB652D01CB5D7D4] ON [SIS].[Idioma] ([CodigoISO639_1] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ__Moneda__4000C912ECD74D5E] ON [SIS].[Moneda] ([CodigoISO4217] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Municipios_Activo_542624976] ON [SIS].[Municipios] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Municipios_FKIdEstado_SIS_542624976] ON [SIS].[Municipios] ([FKIdEstado_SIS] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_NormaJuridica] ON [SIS].[NormaJuridica] ([Clave] ASC, [Jurisdiccion] ASC, [OrigenRecurso] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_NormaJuridicaVersion] ON [SIS].[NormaJuridicaVersion] ([FKIdNormaJuridica_SIS] ASC, [IdentificadorVersion] ASC);
GO
ALTER TABLE [SIS].[NormaJuridicaVersion] ADD CONSTRAINT [CK_NormaJuridicaVersion_Vigencia] CHECK (([VigenciaHasta] IS NULL OR [VigenciaHasta]>=[VigenciaDesde]));
GO
CREATE NONCLUSTERED INDEX [IX_Notificacion_Fk_IdNotificacionTipo_1055342824] ON [SIS].[Notificacion] ([Fk_IdNotificacionTipo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Notificacion_ModuloEvento] ON [SIS].[Notificacion] ([Modulo] ASC, [SubModulo] ASC, [Evento] ASC, [Fk_IdEntidad] ASC) INCLUDE ([Titulo], [CT_CreatedDate]);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_SIS_Notificacion_IdEmpresa_Pk_IdNotificacion] ON [SIS].[Notificacion] ([IdEmpresa] ASC, [Pk_IdNotificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_NotificacionDestino_Notificacion] ON [SIS].[NotificacionDestino] ([Fk_IdNotificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_NotificacionDestino_UsuarioEstado] ON [SIS].[NotificacionDestino] ([Fk_IdUsuarioDestino] ASC, [Fk_IdNotificacionEstado] ASC, [CT_LIVE] ASC) INCLUDE ([Fk_IdNotificacion], [FechaLeido], [FechaAtendido]);
GO
CREATE NONCLUSTERED INDEX [IX_NotificacionEstado_Activo_1007342653] ON [SIS].[NotificacionEstado] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_NotificacionRegla_Activo_1247343508] ON [SIS].[NotificacionRegla] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_NotificacionRegla_Evento] ON [SIS].[NotificacionRegla] ([Modulo] ASC, [SubModulo] ASC, [Evento] ASC, [TipoDestino] ASC, [ClaveDestino] ASC) WHERE ([CT_LIVE]=(1) AND [Activo]=(1));
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_SIS_NotificacionRegla_IdEmpresa_Pk_IdNotificacionRegla] ON [SIS].[NotificacionRegla] ([IdEmpresa] ASC, [Pk_IdNotificacionRegla] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ__Notifica__E8181E1184A89DCD] ON [SIS].[NotificacionTipo] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_NotificacionTipo_Activo_943342425] ON [SIS].[NotificacionTipo] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_NotificacionTipo_Clave_943342425] ON [SIS].[NotificacionTipo] ([Clave] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_SIS_OperacionNegocio_IdEmpresa_ClaveOperacion] ON [SIS].[OperacionNegocio] ([IdEmpresa] ASC, [ClaveOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_SIS_OperacionNegocio_IdEmpresa_Proceso_Folio] ON [SIS].[OperacionNegocio] ([IdEmpresa] ASC, [Proceso] ASC, [Folio] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_SIS_OperacionNegocio_IdEmpresa_IdOperacionNegocio] ON [SIS].[OperacionNegocio] ([IdEmpresa] ASC, [IdOperacionNegocio] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ__Paises__BE942985E10D0F28] ON [SIS].[Paises] ([CodigoISO2] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Partida_Activo_670625432] ON [SIS].[Partida] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Partida_Clave_670625432] ON [SIS].[Partida] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Partida_FKIdConcepto_SIS_670625432] ON [SIS].[Partida] ([FKIdConcepto_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Partida_UsuarioCreacion_670625432] ON [SIS].[Partida] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Partida_UsuarioModificacion_670625432] ON [SIS].[Partida] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Permiso_ModuloRecursoAccion] ON [SIS].[Permiso] ([Modulo] ASC, [Recurso] ASC, [Accion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Permiso_Clave] ON [SIS].[Permiso] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Proveedor_Activo_734625660] ON [SIS].[Proveedor] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Proveedor_Clave_734625660] ON [SIS].[Proveedor] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Proveedor_FKIdEstado_SIS_734625660] ON [SIS].[Proveedor] ([FKIdEstado_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Proveedor_FKIdEstatusProveedor_SIS_734625660] ON [SIS].[Proveedor] ([FKIdEstatusProveedor_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Proveedor_FKIdMunicipio_SIS_734625660] ON [SIS].[Proveedor] ([FKIdMunicipio_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Proveedor_FKIdPais_SIS_734625660] ON [SIS].[Proveedor] ([FKIdPais_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Proveedor_FkIdTipoProveedor_SIS_734625660] ON [SIS].[Proveedor] ([FkIdTipoProveedor_SIS] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_SIS_ProveedorEmpresa_IdEmpresa_IdProveedor] ON [SIS].[ProveedorEmpresa] ([IdEmpresa] ASC, [IdProveedor] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_SIS_ProveedorEmpresa_IdEmpresa_IdProveedorEmpresa] ON [SIS].[ProveedorEmpresa] ([IdEmpresa] ASC, [IdProveedorEmpresa] ASC);
GO
ALTER TABLE [SIS].[ProveedorEmpresa] ADD CONSTRAINT [CK_EXUX_SIS_ProveedorEmpresa_1] CHECK (DiasCredito >= 0);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_SIS_ResponsableOperativo_IdEmpresa_Codigo] ON [SIS].[ResponsableOperativo] ([IdEmpresa] ASC, [Codigo] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_SIS_ResponsableOperativo_IdUsuario] ON [SIS].[ResponsableOperativo] ([IdUsuario] ASC) WHERE [IdUsuario] IS NOT NULL;
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_SIS_ResponsableOperativo_IdEmpresa_IdResponsableOperativo] ON [SIS].[ResponsableOperativo] ([IdEmpresa] ASC, [IdResponsableOperativo] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ__Sucursal__E9A9A10298A8781E] ON [SIS].[Sucursal] ([CodigoSucursal] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_SIS_Sucursal_FKIdEmpresa_SIS_PKIdSucursal] ON [SIS].[Sucursal] ([FKIdEmpresa_SIS] ASC, [PKIdSucursal] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoDetallePoliza_Activo_910626287] ON [SIS].[TipoDetallePoliza] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoDetallePoliza_UsuarioCreacion_910626287] ON [SIS].[TipoDetallePoliza] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoDetallePoliza_UsuarioModificacion_910626287] ON [SIS].[TipoDetallePoliza] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoPoliza_Activo_974626515] ON [SIS].[TipoPoliza] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoPoliza_UsuarioCreacion_974626515] ON [SIS].[TipoPoliza] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoPoliza_UsuarioModificacion_974626515] ON [SIS].[TipoPoliza] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoProveedor_Activo_1006626629] ON [SIS].[TipoProveedor] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoProveedor_UsuarioCreacion_1006626629] ON [SIS].[TipoProveedor] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoProveedor_UsuarioModificacion_1006626629] ON [SIS].[TipoProveedor] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ__Usuario__99DFC6930FE20BC3] ON [SIS].[Usuario] ([PayrollID] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ__Usuario__F42021A6BEB59236] ON [SIS].[Usuario] ([AspNetUserId] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_SIS_Usuario_FKIdEmpresa_SIS_PkIdUsuario] ON [SIS].[Usuario] ([FKIdEmpresa_SIS] ASC, [PkIdUsuario] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Banco_Activo_1166627199] ON [TES].[Banco] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Banco_Clave_1166627199] ON [TES].[Banco] ([Clave] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Banco_FKIdEmpresa_SIS_1166627199] ON [TES].[Banco] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Banco_UsuarioCreacion_1166627199] ON [TES].[Banco] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Banco_UsuarioModificacion_1166627199] ON [TES].[Banco] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_TES_Banco_FKIdEmpresa_SIS_PKIdBanco] ON [TES].[Banco] ([FKIdEmpresa_SIS] ASC, [PKIdBanco] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_TES_ConciliacionDetalle_IdMovimientoBancario_IdPago] ON [TES].[ConciliacionDetalle] ([IdMovimientoBancario] ASC, [IdPago] ASC);
GO
ALTER TABLE [TES].[ConciliacionDetalle] ADD CONSTRAINT [CK_EXUX_TES_ConciliacionDetalle_1] CHECK (Importe > 0);
GO
ALTER TABLE [TES].[ConciliacionDetalle] ADD CONSTRAINT [CK_EXUX_TES_ConciliacionDetalle_2] CHECK (Estado IN ('PROPUESTA','CONCILIADA','REVERSADA'));
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_TES_ConexionBancaria_IdCuentaBancaria_Ambiente] ON [TES].[ConexionBancaria] ([IdCuentaBancaria] ASC, [Ambiente] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_TES_ConexionBancaria_IdEmpresa_IdConexionBancaria] ON [TES].[ConexionBancaria] ([IdEmpresa] ASC, [IdConexionBancaria] ASC);
GO
ALTER TABLE [TES].[ConexionBancaria] ADD CONSTRAINT [CK_EXUX_TES_ConexionBancaria_1] CHECK (Ambiente IN ('PRUEBAS','PRODUCCION'));
GO
CREATE NONCLUSTERED INDEX [IX_CuentaBancaria_Activo_1198627313] ON [TES].[CuentaBancaria] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CuentaBancaria_FKIdBanco_TES_1198627313] ON [TES].[CuentaBancaria] ([FKIdBanco_TES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CuentaBancaria_FKIdCuentaContable_SIS_1198627313] ON [TES].[CuentaBancaria] ([FKIdCuentaContable_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CuentaBancaria_FKIdEmpresa_SIS_1198627313] ON [TES].[CuentaBancaria] ([FKIdEmpresa_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CuentaBancaria_FKIdTipoMoneda_TES_1198627313] ON [TES].[CuentaBancaria] ([FKIdTipoMoneda_TES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CuentaBancaria_UsuarioCreacion_1198627313] ON [TES].[CuentaBancaria] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CuentaBancaria_UsuarioModificacion_1198627313] ON [TES].[CuentaBancaria] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_TES_CuentaBancaria_FKIdEmpresa_SIS_PKIdCuentaBancaria] ON [TES].[CuentaBancaria] ([FKIdEmpresa_SIS] ASC, [PKIdCuentaBancaria] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_TES_CuentaBancaria_FKIdEmpresa_SIS_PKIdCuentaBancaria_IdMoneda] ON [TES].[CuentaBancaria] ([FKIdEmpresa_SIS] ASC, [PKIdCuentaBancaria] ASC, [IdMoneda] ASC);
GO
ALTER TABLE [TES].[EventoCheque] ADD CONSTRAINT [CK_EXUX_TES_EventoCheque_1] CHECK (Tipo IN ('ENTREGA','CANCELACION','COBRO','DEVOLUCION'));
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_TES_IntentoEnvioBancario_IdOperacionBancaria_NumeroIntento] ON [TES].[IntentoEnvioBancario] ([IdOperacionBancaria] ASC, [NumeroIntento] ASC);
GO
ALTER TABLE [TES].[IntentoEnvioBancario] ADD CONSTRAINT [CK_EXUX_TES_IntentoEnvioBancario_1] CHECK (NumeroIntento > 0);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_TES_LoteDispersion_IdOperacion] ON [TES].[LoteDispersion] ([IdOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_TES_LoteDispersion_IdEmpresa_IdLoteDispersion] ON [TES].[LoteDispersion] ([IdEmpresa] ASC, [IdLoteDispersion] ASC);
GO
ALTER TABLE [TES].[LoteDispersion] ADD CONSTRAINT [CK_EXUX_TES_LoteDispersion_1] CHECK (TotalControl >= 0 AND NumeroOperaciones >= 0);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_TES_MovimientoBancario_IdCuentaBancaria_ReferenciaExterna] ON [TES].[MovimientoBancario] ([IdCuentaBancaria] ASC, [ReferenciaExterna] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_TES_MovimientoBancario_IdEmpresa_IdMovimientoBancario] ON [TES].[MovimientoBancario] ([IdEmpresa] ASC, [IdMovimientoBancario] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TES_MovimientoBancario_IdCuentaBancaria_FechaValor] ON [TES].[MovimientoBancario] ([IdCuentaBancaria] ASC, [FechaValor] ASC);
GO
ALTER TABLE [TES].[MovimientoBancario] ADD CONSTRAINT [CK_EXUX_TES_MovimientoBancario_1] CHECK (Importe <> 0);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_TES_OperacionBancaria_IdPago] ON [TES].[OperacionBancaria] ([IdPago] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_TES_OperacionBancaria_IdEmpresa_ClaveIdempotencia] ON [TES].[OperacionBancaria] ([IdEmpresa] ASC, [ClaveIdempotencia] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_TES_OperacionBancaria_IdEmpresa_IdOperacionBancaria] ON [TES].[OperacionBancaria] ([IdEmpresa] ASC, [IdOperacionBancaria] ASC);
GO
ALTER TABLE [TES].[PrevisionTesoreria] ADD CONSTRAINT [CK_EXUX_TES_PrevisionTesoreria_1] CHECK (Sentido IN ('ENTRADA','SALIDA'));
GO
ALTER TABLE [TES].[PrevisionTesoreria] ADD CONSTRAINT [CK_EXUX_TES_PrevisionTesoreria_2] CHECK (Importe >= 0);
GO
CREATE NONCLUSTERED INDEX [IX_TipoCambio_Activo_1390627997] ON [TES].[TipoCambio] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoCambio_Fecha_1390627997] ON [TES].[TipoCambio] ([Fecha] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoCambio_FKIdTipoMoneda_TES_1390627997] ON [TES].[TipoCambio] ([FKIdTipoMoneda_TES] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoCambio_UsuarioCreacion_1390627997] ON [TES].[TipoCambio] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoCambio_UsuarioModificacion_1390627997] ON [TES].[TipoCambio] ([UsuarioModificacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoMoneda_Activo_1486628339] ON [TES].[TipoMoneda] ([Activo] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoMoneda_FKIdPais_SIS_1486628339] ON [TES].[TipoMoneda] ([FKIdPais_SIS] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoMoneda_UsuarioCreacion_1486628339] ON [TES].[TipoMoneda] ([UsuarioCreacion] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_TipoMoneda_UsuarioModificacion_1486628339] ON [TES].[TipoMoneda] ([UsuarioModificacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_VIA_AnticipoViatico_IdEmpresa_IdAnticipoViatico] ON [VIA].[AnticipoViatico] ([IdEmpresa] ASC, [IdAnticipoViatico] ASC);
GO
ALTER TABLE [VIA].[AnticipoViatico] ADD CONSTRAINT [CK_EXUX_VIA_AnticipoViatico_1] CHECK (Importe > 0);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_VIA_ComprobacionViatico_IdSolicitud_IdComprobanteGasto] ON [VIA].[ComprobacionViatico] ([IdSolicitud] ASC, [IdComprobanteGasto] ASC);
GO
ALTER TABLE [VIA].[ComprobacionViatico] ADD CONSTRAINT [CK_EXUX_VIA_ComprobacionViatico_1] CHECK (ImporteAceptado > 0);
GO
ALTER TABLE [VIA].[ReintegroViatico] ADD CONSTRAINT [CK_EXUX_VIA_ReintegroViatico_1] CHECK (Importe > 0);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_VIA_SolicitudViatico_IdOperacion] ON [VIA].[SolicitudViatico] ([IdOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_VIA_SolicitudViatico_IdEmpresa_IdSolicitudViatico] ON [VIA].[SolicitudViatico] ([IdEmpresa] ASC, [IdSolicitudViatico] ASC);
GO
ALTER TABLE [VIA].[SolicitudViatico] ADD CONSTRAINT [CK_EXUX_VIA_SolicitudViatico_1] CHECK (FechaFin >= FechaInicio);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_WF_CalendarioAtencion_IdEmpresa_Codigo] ON [WF].[CalendarioAtencion] ([IdEmpresa] ASC, [Codigo] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_WF_CalendarioAtencion_IdEmpresa_IdCalendarioAtencion] ON [WF].[CalendarioAtencion] ([IdEmpresa] ASC, [IdCalendarioAtencion] ASC);
GO
ALTER TABLE [WF].[CalendarioAtencion] ADD CONSTRAINT [CK_EXUX_WF_CalendarioAtencion_1] CHECK (ISJSON(HorarioJson)=1);
GO
ALTER TABLE [WF].[CalendarioAtencion] ADD CONSTRAINT [CK_EXUX_WF_CalendarioAtencion_2] CHECK (ExcepcionesJson IS NULL OR ISJSON(ExcepcionesJson)=1);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_WF_DecisionAutorizacion_IdEmpresa_ClaveOperacion] ON [WF].[DecisionAutorizacion] ([IdEmpresa] ASC, [ClaveOperacion] ASC);
GO
ALTER TABLE [WF].[DecisionAutorizacion] ADD CONSTRAINT [CK_EXUX_WF_DecisionAutorizacion_1] CHECK (Decision IN ('AUTORIZAR','RECHAZAR','DEVOLVER'));
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_WF_EventoPendiente_IdEmpresa_ClaveOperacion] ON [WF].[EventoPendiente] ([IdEmpresa] ASC, [ClaveOperacion] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_WF_EventoPendiente_IdEmpresa_IdEventoPendiente] ON [WF].[EventoPendiente] ([IdEmpresa] ASC, [IdEventoPendiente] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_WF_EventoPendiente_Estado_FechaPrevista] ON [WF].[EventoPendiente] ([Estado] ASC, [FechaPrevista] ASC);
GO
ALTER TABLE [WF].[EventoPendiente] ADD CONSTRAINT [CK_EXUX_WF_EventoPendiente_1] CHECK (Intentos >= 0);
GO
ALTER TABLE [WF].[EventoPendiente] ADD CONSTRAINT [CK_EXUX_WF_EventoPendiente_2] CHECK (DatosJson IS NULL OR ISJSON(DatosJson)=1);
GO
ALTER TABLE [WF].[EventoPendiente] ADD CONSTRAINT [CK_EXUX_WF_EventoPendiente_3] CHECK (Estado IN ('PENDIENTE','PROCESANDO','ENVIADO','ERROR','CANCELADO'));
GO
ALTER TABLE [WF].[PlazoOperacion] ADD CONSTRAINT [CK_EXUX_WF_PlazoOperacion_1] CHECK (Limite >= Inicio AND MinutosPausa >= 0 AND (Cierre IS NULL OR Cierre >= Inicio));
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_WF_PoliticaSLA_IdTemplate_Etapa_Version] ON [WF].[PoliticaSLA] ([IdTemplate] ASC, [Etapa] ASC, [Version] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_WF_PoliticaSLA_IdEmpresa_IdPoliticaSLA] ON [WF].[PoliticaSLA] ([IdEmpresa] ASC, [IdPoliticaSLA] ASC);
GO
ALTER TABLE [WF].[PoliticaSLA] ADD CONSTRAINT [CK_EXUX_WF_PoliticaSLA_1] CHECK (PlazoMinutos > 0 AND Version > 0);
GO
ALTER TABLE [WF].[PoliticaSLA] ADD CONSTRAINT [CK_EXUX_WF_PoliticaSLA_2] CHECK (EscalamientoJson IS NULL OR ISJSON(EscalamientoJson)=1);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_WF_ReglaAutorizacion_IdEmpresa_IdReglaAutorizacion] ON [WF].[ReglaAutorizacion] ([IdEmpresa] ASC, [IdReglaAutorizacion] ASC);
GO
ALTER TABLE [WF].[ReglaAutorizacion] ADD CONSTRAINT [CK_EXUX_WF_ReglaAutorizacion_1] CHECK (Nivel > 0 AND Version > 0 AND MontoDesde >= 0 AND (MontoHasta IS NULL OR MontoHasta >= MontoDesde));
GO
ALTER TABLE [WF].[ReglaAutorizacion] ADD CONSTRAINT [CK_EXUX_WF_ReglaAutorizacion_2] CHECK (Hasta IS NULL OR Hasta >= Desde);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ__AspNetUs__FD4E229C3E809C83] ON [dbo].[AspNetUsers] ([PkIdUsuario] ASC);
GO
ALTER TABLE [SIS].[ResponsableOperativo] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_ResponsableOperativo_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[ResponsableOperativo] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_ResponsableOperativo_IdEmpresa_IdUsuario_Usuario] FOREIGN KEY ([IdEmpresa], [IdUsuario]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[CentroCosto] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_CentroCosto_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[CentroCosto] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_CentroCosto_IdEmpresa_IdSucursal_Sucursal] FOREIGN KEY ([IdEmpresa], [IdSucursal]) REFERENCES [SIS].[Sucursal] ([FKIdEmpresa_SIS], [PKIdSucursal]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[OperacionNegocio] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_OperacionNegocio_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[Empresa] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_Empresa_IdCorporativo_Corporativo] FOREIGN KEY ([IdCorporativo]) REFERENCES [SIS].[Corporativo] ([IdCorporativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[Poliza] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_Poliza_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Conteo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Conteo_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ConteoDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ConteoDetalle_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ConteoDetalleEscaneo_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[PlanConteoCiclico] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_PlanConteoCiclico_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[PeriodoConteo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_PeriodoConteo_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ResguardoDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ResguardoDetalle_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ResguardoMovimiento] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ResguardoMovimiento_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[InventarioDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_InventarioDetalle_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[OrdenCompraDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_OrdenCompraDetalle_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[CotizacionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_CotizacionDetalle_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PBR].[WorkflowTemplate] WITH CHECK ADD CONSTRAINT [FK_EXUX_PBR_WorkflowTemplate_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PBR].[WorkflowEstado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PBR_WorkflowEstado_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PBR].[WorkflowTransicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_PBR_WorkflowTransicion_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PBR].[AuditoriaCambio] WITH CHECK ADD CONSTRAINT [FK_EXUX_PBR_AuditoriaCambio_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[EnvioWorkflow] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_EnvioWorkflow_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[Notificacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_Notificacion_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[NotificacionRegla] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_NotificacionRegla_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bajas] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bajas_FKIdEmpresa_SIS_SolicitadoPor_Responsable_ResponsableOperativo] FOREIGN KEY ([FKIdEmpresa_SIS], [SolicitadoPor_Responsable]) REFERENCES [SIS].[ResponsableOperativo] ([IdEmpresa], [IdResponsableOperativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bajas] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bajas_FKIdEmpresa_SIS_AutorizadoPor_Responsable_ResponsableOperativo] FOREIGN KEY ([FKIdEmpresa_SIS], [AutorizadoPor_Responsable]) REFERENCES [SIS].[ResponsableOperativo] ([IdEmpresa], [IdResponsableOperativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[AlmacenCatalogo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_AlmacenCatalogo_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[AlmacenCatalogo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_AlmacenCatalogo_IdEmpresa_IdSucursal_Sucursal] FOREIGN KEY ([IdEmpresa], [IdSucursal]) REFERENCES [SIS].[Sucursal] ([FKIdEmpresa_SIS], [PKIdSucursal]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[UsuarioAlmacen] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_UsuarioAlmacen_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[UsuarioAlmacen] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_UsuarioAlmacen_IdEmpresa_IdUsuario_Usuario] FOREIGN KEY ([IdEmpresa], [IdUsuario]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[UsuarioAlmacen] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_UsuarioAlmacen_IdEmpresa_IdAlmacen_AlmacenCatalogo] FOREIGN KEY ([IdEmpresa], [IdAlmacen]) REFERENCES [ALMA].[AlmacenCatalogo] ([IdEmpresa], [IdAlmacenCatalogo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ProductoAlmacen] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ProductoAlmacen_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ProductoAlmacen] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ProductoAlmacen_IdEmpresa_IdAlmacen_AlmacenCatalogo] FOREIGN KEY ([IdEmpresa], [IdAlmacen]) REFERENCES [ALMA].[AlmacenCatalogo] ([IdEmpresa], [IdAlmacenCatalogo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ProductoAlmacen] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ProductoAlmacen_IdEmpresa_IdTipoBien_TipoBien] FOREIGN KEY ([IdEmpresa], [IdTipoBien]) REFERENCES [ALMA].[TipoBien] ([IdEmpresa], [PKIdTipoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[UbicacionAlmacen] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_UbicacionAlmacen_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[UbicacionAlmacen] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_UbicacionAlmacen_IdEmpresa_IdAlmacen_AlmacenCatalogo] FOREIGN KEY ([IdEmpresa], [IdAlmacen]) REFERENCES [ALMA].[AlmacenCatalogo] ([IdEmpresa], [IdAlmacenCatalogo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Lote] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Lote_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Lote] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Lote_IdEmpresa_IdTipoBien_TipoBien] FOREIGN KEY ([IdEmpresa], [IdTipoBien]) REFERENCES [ALMA].[TipoBien] ([IdEmpresa], [PKIdTipoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[PartidaStock] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_PartidaStock_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[PartidaStock] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_PartidaStock_IdEmpresa_IdAlmacen_AlmacenCatalogo] FOREIGN KEY ([IdEmpresa], [IdAlmacen]) REFERENCES [ALMA].[AlmacenCatalogo] ([IdEmpresa], [IdAlmacenCatalogo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[PartidaStock] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_PartidaStock_IdEmpresa_IdProductoAlmacen_ProductoAlmacen] FOREIGN KEY ([IdEmpresa], [IdProductoAlmacen]) REFERENCES [ALMA].[ProductoAlmacen] ([IdEmpresa], [IdProductoAlmacen]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[PartidaStock] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_PartidaStock_IdEmpresa_IdTipoBien_TipoBien] FOREIGN KEY ([IdEmpresa], [IdTipoBien]) REFERENCES [ALMA].[TipoBien] ([IdEmpresa], [PKIdTipoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[PartidaStock] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_PartidaStock_IdEmpresa_IdUbicacion_UbicacionAlmacen] FOREIGN KEY ([IdEmpresa], [IdUbicacion]) REFERENCES [ALMA].[UbicacionAlmacen] ([IdEmpresa], [IdUbicacionAlmacen]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[PartidaStock] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_PartidaStock_IdEmpresa_IdLote_Lote] FOREIGN KEY ([IdEmpresa], [IdLote]) REFERENCES [ALMA].[Lote] ([IdEmpresa], [IdLote]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Transferencia] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Transferencia_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Transferencia] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Transferencia_IdEmpresa_IdAlmacenOrigen_AlmacenCatalogo] FOREIGN KEY ([IdEmpresa], [IdAlmacenOrigen]) REFERENCES [ALMA].[AlmacenCatalogo] ([IdEmpresa], [IdAlmacenCatalogo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Transferencia] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Transferencia_IdEmpresa_IdAlmacenDestino_AlmacenCatalogo] FOREIGN KEY ([IdEmpresa], [IdAlmacenDestino]) REFERENCES [ALMA].[AlmacenCatalogo] ([IdEmpresa], [IdAlmacenCatalogo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Transferencia] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Transferencia_IdEmpresa_IdAlmacenTransito_AlmacenCatalogo] FOREIGN KEY ([IdEmpresa], [IdAlmacenTransito]) REFERENCES [ALMA].[AlmacenCatalogo] ([IdEmpresa], [IdAlmacenCatalogo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Transferencia] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Transferencia_IdEmpresa_IdOperacion_OperacionNegocio] FOREIGN KEY ([IdEmpresa], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[TransferenciaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_TransferenciaDetalle_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[TransferenciaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_TransferenciaDetalle_IdEmpresa_IdTransferencia_Transferencia] FOREIGN KEY ([IdEmpresa], [IdTransferencia]) REFERENCES [ALMA].[Transferencia] ([IdEmpresa], [IdTransferencia]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[TransferenciaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_TransferenciaDetalle_IdEmpresa_IdTipoBien_TipoBien] FOREIGN KEY ([IdEmpresa], [IdTipoBien]) REFERENCES [ALMA].[TipoBien] ([IdEmpresa], [PKIdTipoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[MovimientoInventario] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_MovimientoInventario_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[MovimientoInventario] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_MovimientoInventario_IdEmpresa_IdOperacion_OperacionNegocio] FOREIGN KEY ([IdEmpresa], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[MovimientoInventario] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_MovimientoInventario_IdEmpresa_IdUsuarioAplicacion_Usuario] FOREIGN KEY ([IdEmpresa], [IdUsuarioAplicacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[MovimientoInventario] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_MovimientoInventario_IdEmpresa_IdMovimientoReversa_MovimientoInventario] FOREIGN KEY ([IdEmpresa], [IdMovimientoReversa]) REFERENCES [ALMA].[MovimientoInventario] ([IdEmpresa], [IdMovimientoInventario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[MovimientoInventarioDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_MovimientoInventarioDetalle_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[MovimientoInventarioDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_MovimientoInventarioDetalle_IdEmpresa_IdMovimiento_MovimientoInventario] FOREIGN KEY ([IdEmpresa], [IdMovimiento]) REFERENCES [ALMA].[MovimientoInventario] ([IdEmpresa], [IdMovimientoInventario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[MovimientoInventarioDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_MovimientoInventarioDetalle_IdEmpresa_IdPartidaStock_PartidaStock] FOREIGN KEY ([IdEmpresa], [IdPartidaStock]) REFERENCES [ALMA].[PartidaStock] ([IdEmpresa], [IdPartidaStock]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[MovimientoInventarioDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_MovimientoInventarioDetalle_IdEmpresa_IdDetalleSolicitudSalida_DetalleSolicitudSalida] FOREIGN KEY ([IdEmpresa], [IdDetalleSolicitudSalida]) REFERENCES [ALMA].[DetalleSolicitudSalida] ([IdEmpresa], [PKIdDetalleSolicitudSalida]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[MovimientoInventarioDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_MovimientoInventarioDetalle_IdEmpresa_IdTransferenciaDetalle_TransferenciaDetalle] FOREIGN KEY ([IdEmpresa], [IdTransferenciaDetalle]) REFERENCES [ALMA].[TransferenciaDetalle] ([IdEmpresa], [IdTransferenciaDetalle]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[MovimientoInventarioDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_MovimientoInventarioDetalle_IdEmpresa_IdEntradaLegada_Almacen] FOREIGN KEY ([IdEmpresa], [IdEntradaLegada]) REFERENCES [ALMA].[Almacen] ([FKIdEmpresa_SIS], [PKIdAlmacen]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ReservaStock] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ReservaStock_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ReservaStock] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ReservaStock_IdEmpresa_IdPartidaStock_PartidaStock] FOREIGN KEY ([IdEmpresa], [IdPartidaStock]) REFERENCES [ALMA].[PartidaStock] ([IdEmpresa], [IdPartidaStock]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ReservaStock] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ReservaStock_IdEmpresa_IdDetalleSolicitudSalida_DetalleSolicitudSalida] FOREIGN KEY ([IdEmpresa], [IdDetalleSolicitudSalida]) REFERENCES [ALMA].[DetalleSolicitudSalida] ([IdEmpresa], [PKIdDetalleSolicitudSalida]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[SolicitudSalida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_SolicitudSalida_FKIdEmpresa_SIS_IdAlmacen_AlmacenCatalogo] FOREIGN KEY ([FKIdEmpresa_SIS], [IdAlmacen]) REFERENCES [ALMA].[AlmacenCatalogo] ([IdEmpresa], [IdAlmacenCatalogo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[PeriodoConteo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_PeriodoConteo_IdEmpresa_IdAlmacen_AlmacenCatalogo] FOREIGN KEY ([IdEmpresa], [IdAlmacen]) REFERENCES [ALMA].[AlmacenCatalogo] ([IdEmpresa], [IdAlmacenCatalogo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Conteo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Conteo_IdEmpresa_IdPartidaStock_PartidaStock] FOREIGN KEY ([IdEmpresa], [IdPartidaStock]) REFERENCES [ALMA].[PartidaStock] ([IdEmpresa], [IdPartidaStock]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[PlanConteoCiclico] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_PlanConteoCiclico_IdEmpresa_IdProductoAlmacen_ProductoAlmacen] FOREIGN KEY ([IdEmpresa], [IdProductoAlmacen]) REFERENCES [ALMA].[ProductoAlmacen] ([IdEmpresa], [IdProductoAlmacen]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[CierreInventario] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_CierreInventario_FKIdEmpresa_SIS_IdPartidaStock_PartidaStock] FOREIGN KEY ([FKIdEmpresa_SIS], [IdPartidaStock]) REFERENCES [ALMA].[PartidaStock] ([IdEmpresa], [IdPartidaStock]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Almacen] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Almacen_FKIdEmpresa_SIS_IdPartidaStock_PartidaStock] FOREIGN KEY ([FKIdEmpresa_SIS], [IdPartidaStock]) REFERENCES [ALMA].[PartidaStock] ([IdEmpresa], [IdPartidaStock]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[DetalleSolicitudSalida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_DetalleSolicitudSalida_IdEmpresa_IdAlmacen_AlmacenCatalogo] FOREIGN KEY ([IdEmpresa], [IdAlmacen]) REFERENCES [ALMA].[AlmacenCatalogo] ([IdEmpresa], [IdAlmacenCatalogo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Conteo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Conteo_IdEmpresa_IdMovimientoAjuste_MovimientoInventario] FOREIGN KEY ([IdEmpresa], [IdMovimientoAjuste]) REFERENCES [ALMA].[MovimientoInventario] ([IdEmpresa], [IdMovimientoInventario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAT].[UbicacionPatrimonial] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAT_UbicacionPatrimonial_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAT].[UbicacionPatrimonial] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAT_UbicacionPatrimonial_IdEmpresa_IdSucursal_Sucursal] FOREIGN KEY ([IdEmpresa], [IdSucursal]) REFERENCES [SIS].[Sucursal] ([FKIdEmpresa_SIS], [PKIdSucursal]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAT].[HistorialUbicacionBien] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAT_HistorialUbicacionBien_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAT].[HistorialUbicacionBien] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAT_HistorialUbicacionBien_IdEmpresa_IdBien_Bien] FOREIGN KEY ([IdEmpresa], [IdBien]) REFERENCES [ALMA].[Bien] ([FKIdEmpresa_SIS], [PKIdBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAT].[HistorialUbicacionBien] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAT_HistorialUbicacionBien_IdEmpresa_IdUbicacionPatrimonial_UbicacionPatrimonial] FOREIGN KEY ([IdEmpresa], [IdUbicacionPatrimonial]) REFERENCES [PAT].[UbicacionPatrimonial] ([IdEmpresa], [IdUbicacionPatrimonial]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAT].[HistorialUbicacionBien] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAT_HistorialUbicacionBien_IdEmpresa_IdUbicacionAlmacen_UbicacionAlmacen] FOREIGN KEY ([IdEmpresa], [IdUbicacionAlmacen]) REFERENCES [ALMA].[UbicacionAlmacen] ([IdEmpresa], [IdUbicacionAlmacen]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAT].[HistorialUbicacionBien] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAT_HistorialUbicacionBien_IdEmpresa_IdOperacion_OperacionNegocio] FOREIGN KEY ([IdEmpresa], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAT].[IdentificadorBien] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAT_IdentificadorBien_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAT].[IdentificadorBien] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAT_IdentificadorBien_IdEmpresa_IdBien_Bien] FOREIGN KEY ([IdEmpresa], [IdBien]) REFERENCES [ALMA].[Bien] ([FKIdEmpresa_SIS], [PKIdBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAT].[InmuebleDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAT_InmuebleDetalle_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAT].[InmuebleDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAT_InmuebleDetalle_IdEmpresa_IdBien_Bien] FOREIGN KEY ([IdEmpresa], [IdBien]) REFERENCES [ALMA].[Bien] ([FKIdEmpresa_SIS], [PKIdBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAT].[InmuebleDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAT_InmuebleDetalle_IdEmpresa_DocumentoPropiedad_Documento] FOREIGN KEY ([IdEmpresa], [DocumentoPropiedad]) REFERENCES [SIS].[Documento] ([FkidEmpresaSis], [PkidDocumento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAT].[PoliticaDepreciacionVersion] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAT_PoliticaDepreciacionVersion_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAT].[PoliticaDepreciacionVersion] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAT_PoliticaDepreciacionVersion_IdEmpresa_IdUsuarioAprobacion_Usuario] FOREIGN KEY ([IdEmpresa], [IdUsuarioAprobacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAT].[DepreciacionBienPeriodo] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAT_DepreciacionBienPeriodo_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAT].[DepreciacionBienPeriodo] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAT_DepreciacionBienPeriodo_IdEmpresa_IdBien_Bien] FOREIGN KEY ([IdEmpresa], [IdBien]) REFERENCES [ALMA].[Bien] ([FKIdEmpresa_SIS], [PKIdBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAT].[DepreciacionBienPeriodo] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAT_DepreciacionBienPeriodo_IdEmpresa_IdPoliticaVersion_PoliticaDepreciacionVersion] FOREIGN KEY ([IdEmpresa], [IdPoliticaVersion]) REFERENCES [PAT].[PoliticaDepreciacionVersion] ([IdEmpresa], [IdPoliticaDepreciacionVersion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAT].[DepreciacionBienPeriodo] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAT_DepreciacionBienPeriodo_IdEmpresa_IdPoliza_Poliza] FOREIGN KEY ([IdEmpresa], [IdPoliza]) REFERENCES [CONTA].[Poliza] ([IdEmpresa], [PKIdPoliza]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Resguardo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Resguardo_FKIdEmpresa_SIS_IdResponsableOperativo_ResponsableOperativo] FOREIGN KEY ([FKIdEmpresa_SIS], [IdResponsableOperativo]) REFERENCES [SIS].[ResponsableOperativo] ([IdEmpresa], [IdResponsableOperativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bien_FKIdEmpresa_SIS_IdUbicacionPatrimonial_UbicacionPatrimonial] FOREIGN KEY ([FKIdEmpresa_SIS], [IdUbicacionPatrimonial]) REFERENCES [PAT].[UbicacionPatrimonial] ([IdEmpresa], [IdUbicacionPatrimonial]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bien_FKIdEmpresa_SIS_IdUbicacionAlmacen_UbicacionAlmacen] FOREIGN KEY ([FKIdEmpresa_SIS], [IdUbicacionAlmacen]) REFERENCES [ALMA].[UbicacionAlmacen] ([IdEmpresa], [IdUbicacionAlmacen]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[InventarioDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_InventarioDetalle_IdEmpresa_IdUbicacionPatrimonial_UbicacionPatrimonial] FOREIGN KEY ([IdEmpresa], [IdUbicacionPatrimonial]) REFERENCES [PAT].[UbicacionPatrimonial] ([IdEmpresa], [IdUbicacionPatrimonial]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[InventarioDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_InventarioDetalle_IdEmpresa_IdUbicacionAlmacen_UbicacionAlmacen] FOREIGN KEY ([IdEmpresa], [IdUbicacionAlmacen]) REFERENCES [ALMA].[UbicacionAlmacen] ([IdEmpresa], [IdUbicacionAlmacen]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[PresupuestoVersion] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_PresupuestoVersion_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[PresupuestoVersion] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_PresupuestoVersion_IdAnio_Anio] FOREIGN KEY ([IdAnio]) REFERENCES [SIS].[Anio] ([PKIdAnio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[PresupuestoVersion] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_PresupuestoVersion_IdEmpresa_IdUsuarioAprobacion_Usuario] FOREIGN KEY ([IdEmpresa], [IdUsuarioAprobacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[ReservaPresupuestal] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_ReservaPresupuestal_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[ReservaPresupuestal] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_ReservaPresupuestal_IdEmpresa_IdEgresoAutorizado_EgresoAutorizado] FOREIGN KEY ([IdEmpresa], [IdEgresoAutorizado]) REFERENCES [PRES].[EgresoAutorizado] ([FKIdEmpresa_SIS], [PKIdEgresoAutorizado]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[ReservaPresupuestal] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_ReservaPresupuestal_IdEmpresa_IdOperacion_OperacionNegocio] FOREIGN KEY ([IdEmpresa], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoProyectado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoProyectado_FKIdEmpresa_SIS_IdPresupuestoVersion_PresupuestoVersion] FOREIGN KEY ([FKIdEmpresa_SIS], [IdPresupuestoVersion]) REFERENCES [PRES].[PresupuestoVersion] ([IdEmpresa], [IdPresupuestoVersion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoProyectado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoProyectado_FKIdEmpresa_SIS_IdCentroCosto_CentroCosto] FOREIGN KEY ([FKIdEmpresa_SIS], [IdCentroCosto]) REFERENCES [SIS].[CentroCosto] ([IdEmpresa], [IdCentroCosto]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoAutorizado_FKIdEmpresa_SIS_IdPresupuestoVersion_PresupuestoVersion] FOREIGN KEY ([FKIdEmpresa_SIS], [IdPresupuestoVersion]) REFERENCES [PRES].[PresupuestoVersion] ([IdEmpresa], [IdPresupuestoVersion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoAutorizado_FKIdEmpresa_SIS_IdCentroCosto_CentroCosto] FOREIGN KEY ([FKIdEmpresa_SIS], [IdCentroCosto]) REFERENCES [SIS].[CentroCosto] ([IdEmpresa], [IdCentroCosto]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[CriterioEvaluacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_CriterioEvaluacion_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EvaluacionOferta] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EvaluacionOferta_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EvaluacionOferta] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EvaluacionOferta_IdEmpresa_IdCotizacionDetalle_CotizacionDetalle] FOREIGN KEY ([IdEmpresa], [IdCotizacionDetalle]) REFERENCES [ORCO].[CotizacionDetalle] ([IdEmpresa], [PKIdCotizacionDetalle]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EvaluacionOferta] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EvaluacionOferta_IdEmpresa_IdCriterio_CriterioEvaluacion] FOREIGN KEY ([IdEmpresa], [IdCriterio]) REFERENCES [ORCO].[CriterioEvaluacion] ([IdEmpresa], [IdCriterioEvaluacion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EvaluacionOferta] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EvaluacionOferta_IdEmpresa_IdDocumentoEvidencia_Documento] FOREIGN KEY ([IdEmpresa], [IdDocumentoEvidencia]) REFERENCES [SIS].[Documento] ([FkidEmpresaSis], [PkidDocumento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EvaluacionOferta] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EvaluacionOferta_IdEmpresa_IdUsuarioEvaluacion_Usuario] FOREIGN KEY ([IdEmpresa], [IdUsuarioEvaluacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[DestinoOrdenCompra] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_DestinoOrdenCompra_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[DestinoOrdenCompra] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_DestinoOrdenCompra_IdEmpresa_IdOrdenCompraDetalle_OrdenCompraDetalle] FOREIGN KEY ([IdEmpresa], [IdOrdenCompraDetalle]) REFERENCES [ORCO].[OrdenCompraDetalle] ([IdEmpresa], [PKIdOrdenCompraDetalle]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[DestinoOrdenCompra] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_DestinoOrdenCompra_IdEmpresa_IdAlmacen_AlmacenCatalogo] FOREIGN KEY ([IdEmpresa], [IdAlmacen]) REFERENCES [ALMA].[AlmacenCatalogo] ([IdEmpresa], [IdAlmacenCatalogo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[DestinoOrdenCompra] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_DestinoOrdenCompra_IdEmpresa_IdCentroCosto_CentroCosto] FOREIGN KEY ([IdEmpresa], [IdCentroCosto]) REFERENCES [SIS].[CentroCosto] ([IdEmpresa], [IdCentroCosto]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Recepcion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Recepcion_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Recepcion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Recepcion_IdEmpresa_IdOperacion_OperacionNegocio] FOREIGN KEY ([IdEmpresa], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Recepcion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Recepcion_IdEmpresa_IdResponsable_ResponsableOperativo] FOREIGN KEY ([IdEmpresa], [IdResponsable]) REFERENCES [SIS].[ResponsableOperativo] ([IdEmpresa], [IdResponsableOperativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[RecepcionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_RecepcionDetalle_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[RecepcionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_RecepcionDetalle_IdEmpresa_IdRecepcion_Recepcion] FOREIGN KEY ([IdEmpresa], [IdRecepcion]) REFERENCES [ORCO].[Recepcion] ([IdEmpresa], [IdRecepcion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[RecepcionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_RecepcionDetalle_IdEmpresa_IdDestinoOrdenCompra_DestinoOrdenCompra] FOREIGN KEY ([IdEmpresa], [IdDestinoOrdenCompra]) REFERENCES [ORCO].[DestinoOrdenCompra] ([IdEmpresa], [IdDestinoOrdenCompra]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[ProveedorEmpresa] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_ProveedorEmpresa_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[ProveedorEmpresa] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_ProveedorEmpresa_IdProveedor_Proveedor] FOREIGN KEY ([IdProveedor]) REFERENCES [SIS].[Proveedor] ([PKIdProveedor]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[CuentaProveedor] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_CuentaProveedor_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[CuentaProveedor] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_CuentaProveedor_IdEmpresa_IdProveedorEmpresa_ProveedorEmpresa] FOREIGN KEY ([IdEmpresa], [IdProveedorEmpresa]) REFERENCES [SIS].[ProveedorEmpresa] ([IdEmpresa], [IdProveedorEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[CuentaProveedor] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_CuentaProveedor_IdEmpresa_IdBanco_Banco] FOREIGN KEY ([IdEmpresa], [IdBanco]) REFERENCES [TES].[Banco] ([FKIdEmpresa_SIS], [PKIdBanco]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[CuentaProveedor] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_CuentaProveedor_IdEmpresa_IdUsuarioValidacion_Usuario] FOREIGN KEY ([IdEmpresa], [IdUsuarioValidacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EvaluacionFiscalProveedor] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EvaluacionFiscalProveedor_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EvaluacionFiscalProveedor] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EvaluacionFiscalProveedor_IdEmpresa_IdProveedorEmpresa_ProveedorEmpresa] FOREIGN KEY ([IdEmpresa], [IdProveedorEmpresa]) REFERENCES [SIS].[ProveedorEmpresa] ([IdEmpresa], [IdProveedorEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EvaluacionFiscalProveedor] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EvaluacionFiscalProveedor_IdEmpresa_IdDocumentoEvidencia_Documento] FOREIGN KEY ([IdEmpresa], [IdDocumentoEvidencia]) REFERENCES [SIS].[Documento] ([FkidEmpresaSis], [PkidDocumento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Requisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Requisicion_FKIdEmpresa_SIS_IdCentroCosto_CentroCosto] FOREIGN KEY ([FKIdEmpresa_SIS], [IdCentroCosto]) REFERENCES [SIS].[CentroCosto] ([IdEmpresa], [IdCentroCosto]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[MovimientoInventarioDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_MovimientoInventarioDetalle_IdEmpresa_IdRecepcionDetalle_RecepcionDetalle] FOREIGN KEY ([IdEmpresa], [IdRecepcionDetalle]) REFERENCES [ORCO].[RecepcionDetalle] ([IdEmpresa], [IdRecepcionDetalle]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[FacturaRecepcion] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_FacturaRecepcion_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[FacturaRecepcion] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_FacturaRecepcion_IdEmpresa_IdFacturaDetalle_FacturaDetalle] FOREIGN KEY ([IdEmpresa], [IdFacturaDetalle]) REFERENCES [PRES].[FacturaDetalle] ([FKIdEmpresa_SIS], [PKIdFacturaDetalle]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[FacturaRecepcion] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_FacturaRecepcion_IdEmpresa_IdRecepcionDetalle_RecepcionDetalle] FOREIGN KEY ([IdEmpresa], [IdRecepcionDetalle]) REFERENCES [ORCO].[RecepcionDetalle] ([IdEmpresa], [IdRecepcionDetalle]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[Cfdi] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_Cfdi_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[Cfdi] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_Cfdi_IdMoneda_Moneda] FOREIGN KEY ([IdMoneda]) REFERENCES [SIS].[Moneda] ([PKIdMoneda]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[Cfdi] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_Cfdi_IdEmpresa_IdDocumentoXml_Documento] FOREIGN KEY ([IdEmpresa], [IdDocumentoXml]) REFERENCES [SIS].[Documento] ([FkidEmpresaSis], [PkidDocumento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[Cfdi] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_Cfdi_IdEmpresa_IdDocumentoPdf_Documento] FOREIGN KEY ([IdEmpresa], [IdDocumentoPdf]) REFERENCES [SIS].[Documento] ([FkidEmpresaSis], [PkidDocumento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[CfdiConcepto] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_CfdiConcepto_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[CfdiConcepto] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_CfdiConcepto_IdEmpresa_IdCfdi_Cfdi] FOREIGN KEY ([IdEmpresa], [IdCfdi]) REFERENCES [FIS].[Cfdi] ([IdEmpresa], [IdCfdi]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[CfdiImpuesto] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_CfdiImpuesto_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[CfdiImpuesto] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_CfdiImpuesto_IdEmpresa_IdCfdiConcepto_CfdiConcepto] FOREIGN KEY ([IdEmpresa], [IdCfdiConcepto]) REFERENCES [FIS].[CfdiConcepto] ([IdEmpresa], [IdCfdiConcepto]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[ValidacionCfdi] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_ValidacionCfdi_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[ValidacionCfdi] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_ValidacionCfdi_IdEmpresa_IdCfdi_Cfdi] FOREIGN KEY ([IdEmpresa], [IdCfdi]) REFERENCES [FIS].[Cfdi] ([IdEmpresa], [IdCfdi]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[ValidacionCfdi] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_ValidacionCfdi_IdEmpresa_IdDocumentoEvidencia_Documento] FOREIGN KEY ([IdEmpresa], [IdDocumentoEvidencia]) REFERENCES [SIS].[Documento] ([FkidEmpresaSis], [PkidDocumento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[EventoCfdi] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_EventoCfdi_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[EventoCfdi] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_EventoCfdi_IdEmpresa_IdCfdi_Cfdi] FOREIGN KEY ([IdEmpresa], [IdCfdi]) REFERENCES [FIS].[Cfdi] ([IdEmpresa], [IdCfdi]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[EventoCfdi] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_EventoCfdi_IdEmpresa_IdDocumentoAcuse_Documento] FOREIGN KEY ([IdEmpresa], [IdDocumentoAcuse]) REFERENCES [SIS].[Documento] ([FkidEmpresaSis], [PkidDocumento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[ComprobanteGasto] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_ComprobanteGasto_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[ComprobanteGasto] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_ComprobanteGasto_IdEmpresa_IdDocumento_Documento] FOREIGN KEY ([IdEmpresa], [IdDocumento]) REFERENCES [SIS].[Documento] ([FkidEmpresaSis], [PkidDocumento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[ComprobanteGasto] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_ComprobanteGasto_IdEmpresa_IdCfdi_Cfdi] FOREIGN KEY ([IdEmpresa], [IdCfdi]) REFERENCES [FIS].[Cfdi] ([IdEmpresa], [IdCfdi]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[ComprobanteGasto] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_ComprobanteGasto_IdMoneda_Moneda] FOREIGN KEY ([IdMoneda]) REFERENCES [SIS].[Moneda] ([PKIdMoneda]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[CompromisoPago] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_CompromisoPago_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[CompromisoPago] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_CompromisoPago_IdEmpresa_IdOperacion_OperacionNegocio] FOREIGN KEY ([IdEmpresa], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[CompromisoPago] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_CompromisoPago_IdEmpresa_IdProveedorEmpresa_ProveedorEmpresa] FOREIGN KEY ([IdEmpresa], [IdProveedorEmpresa]) REFERENCES [SIS].[ProveedorEmpresa] ([IdEmpresa], [IdProveedorEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[CompromisoPago] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_CompromisoPago_IdEmpresa_IdResponsable_ResponsableOperativo] FOREIGN KEY ([IdEmpresa], [IdResponsable]) REFERENCES [SIS].[ResponsableOperativo] ([IdEmpresa], [IdResponsableOperativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[CompromisoPago] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_CompromisoPago_IdMoneda_Moneda] FOREIGN KEY ([IdMoneda]) REFERENCES [SIS].[Moneda] ([PKIdMoneda]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[CompromisoPago] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_CompromisoPago_IdEmpresa_IdFactura_Factura] FOREIGN KEY ([IdEmpresa], [IdFactura]) REFERENCES [PRES].[Factura] ([FKIdEmpresa_SIS], [PKIdFactura]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[NotaCredito] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_NotaCredito_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[NotaCredito] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_NotaCredito_IdEmpresa_IdProveedorEmpresa_ProveedorEmpresa] FOREIGN KEY ([IdEmpresa], [IdProveedorEmpresa]) REFERENCES [SIS].[ProveedorEmpresa] ([IdEmpresa], [IdProveedorEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[NotaCredito] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_NotaCredito_IdEmpresa_IdCfdi_Cfdi] FOREIGN KEY ([IdEmpresa], [IdCfdi]) REFERENCES [FIS].[Cfdi] ([IdEmpresa], [IdCfdi]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[NotaCredito] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_NotaCredito_IdMoneda_Moneda] FOREIGN KEY ([IdMoneda]) REFERENCES [SIS].[Moneda] ([PKIdMoneda]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[AplicacionNotaCredito] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_AplicacionNotaCredito_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[AplicacionNotaCredito] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_AplicacionNotaCredito_IdEmpresa_IdNotaCredito_NotaCredito] FOREIGN KEY ([IdEmpresa], [IdNotaCredito]) REFERENCES [PAG].[NotaCredito] ([IdEmpresa], [IdNotaCredito]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[AplicacionNotaCredito] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_AplicacionNotaCredito_IdEmpresa_IdFactura_Factura] FOREIGN KEY ([IdEmpresa], [IdFactura]) REFERENCES [PRES].[Factura] ([FKIdEmpresa_SIS], [PKIdFactura]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[AplicacionNotaCredito] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_AplicacionNotaCredito_IdEmpresa_IdAplicacionReversa_AplicacionNotaCredito] FOREIGN KEY ([IdEmpresa], [IdAplicacionReversa]) REFERENCES [PAG].[AplicacionNotaCredito] ([IdEmpresa], [IdAplicacionNotaCredito]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[ProgramacionPago] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_ProgramacionPago_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[ProgramacionPago] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_ProgramacionPago_IdEmpresa_IdCompromiso_CompromisoPago] FOREIGN KEY ([IdEmpresa], [IdCompromiso]) REFERENCES [PAG].[CompromisoPago] ([IdEmpresa], [IdCompromisoPago]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[Pago] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_Pago_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[Pago] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_Pago_IdEmpresa_IdOperacion_OperacionNegocio] FOREIGN KEY ([IdEmpresa], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[Pago] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_Pago_IdEmpresa_IdCuentaBancaria_CuentaBancaria] FOREIGN KEY ([IdEmpresa], [IdCuentaBancaria]) REFERENCES [TES].[CuentaBancaria] ([FKIdEmpresa_SIS], [PKIdCuentaBancaria]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[Pago] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_Pago_IdMoneda_Moneda] FOREIGN KEY ([IdMoneda]) REFERENCES [SIS].[Moneda] ([PKIdMoneda]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[Pago] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_Pago_IdEmpresa_IdProveedorEmpresa_ProveedorEmpresa] FOREIGN KEY ([IdEmpresa], [IdProveedorEmpresa]) REFERENCES [SIS].[ProveedorEmpresa] ([IdEmpresa], [IdProveedorEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[Pago] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_Pago_IdEmpresa_IdResponsable_ResponsableOperativo] FOREIGN KEY ([IdEmpresa], [IdResponsable]) REFERENCES [SIS].[ResponsableOperativo] ([IdEmpresa], [IdResponsableOperativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[AplicacionPago] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_AplicacionPago_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[AplicacionPago] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_AplicacionPago_IdEmpresa_IdPago_Pago] FOREIGN KEY ([IdEmpresa], [IdPago]) REFERENCES [PAG].[Pago] ([IdEmpresa], [IdPago]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[AplicacionPago] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_AplicacionPago_IdEmpresa_IdCompromiso_CompromisoPago] FOREIGN KEY ([IdEmpresa], [IdCompromiso]) REFERENCES [PAG].[CompromisoPago] ([IdEmpresa], [IdCompromisoPago]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[AplicacionPago] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_AplicacionPago_IdMoneda_Moneda] FOREIGN KEY ([IdMoneda]) REFERENCES [SIS].[Moneda] ([PKIdMoneda]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[AplicacionPago] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_AplicacionPago_IdEmpresa_IdAplicacionReversa_AplicacionPago] FOREIGN KEY ([IdEmpresa], [IdAplicacionReversa]) REFERENCES [PAG].[AplicacionPago] ([IdEmpresa], [IdAplicacionPago]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[PagoPoliza] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_PagoPoliza_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[PagoPoliza] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_PagoPoliza_IdEmpresa_IdPago_Pago] FOREIGN KEY ([IdEmpresa], [IdPago]) REFERENCES [PAG].[Pago] ([IdEmpresa], [IdPago]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[PagoPoliza] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_PagoPoliza_IdEmpresa_IdPoliza_Poliza] FOREIGN KEY ([IdEmpresa], [IdPoliza]) REFERENCES [CONTA].[Poliza] ([IdEmpresa], [PKIdPoliza]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[EventoCheque] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_EventoCheque_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[EventoCheque] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_EventoCheque_IdEmpresa_IdCheque_Cheque] FOREIGN KEY ([IdEmpresa], [IdCheque]) REFERENCES [PRES].[Cheque] ([FKIdEmpresa_SIS], [PKIdCheque]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[EventoCheque] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_EventoCheque_IdEmpresa_IdDocumentoAcuse_Documento] FOREIGN KEY ([IdEmpresa], [IdDocumentoAcuse]) REFERENCES [SIS].[Documento] ([FkidEmpresaSis], [PkidDocumento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Cheque] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Cheque_FKIdEmpresa_SIS_IdPago_Pago] FOREIGN KEY ([FKIdEmpresa_SIS], [IdPago]) REFERENCES [PAG].[Pago] ([IdEmpresa], [IdPago]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Factura] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Factura_FKIdEmpresa_SIS_IdProveedorEmpresa_ProveedorEmpresa] FOREIGN KEY ([FKIdEmpresa_SIS], [IdProveedorEmpresa]) REFERENCES [SIS].[ProveedorEmpresa] ([IdEmpresa], [IdProveedorEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Factura] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Factura_FKIdEmpresa_SIS_IdCfdi_Cfdi] FOREIGN KEY ([FKIdEmpresa_SIS], [IdCfdi]) REFERENCES [FIS].[Cfdi] ([IdEmpresa], [IdCfdi]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Factura] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Factura_IdMoneda_Moneda] FOREIGN KEY ([IdMoneda]) REFERENCES [SIS].[Moneda] ([PKIdMoneda]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[ConexionBancaria] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_ConexionBancaria_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[ConexionBancaria] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_ConexionBancaria_IdEmpresa_IdCuentaBancaria_CuentaBancaria] FOREIGN KEY ([IdEmpresa], [IdCuentaBancaria]) REFERENCES [TES].[CuentaBancaria] ([FKIdEmpresa_SIS], [PKIdCuentaBancaria]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[LoteDispersion] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_LoteDispersion_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[LoteDispersion] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_LoteDispersion_IdEmpresa_IdOperacion_OperacionNegocio] FOREIGN KEY ([IdEmpresa], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[LoteDispersion] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_LoteDispersion_IdEmpresa_IdCuentaBancaria_CuentaBancaria] FOREIGN KEY ([IdEmpresa], [IdCuentaBancaria]) REFERENCES [TES].[CuentaBancaria] ([FKIdEmpresa_SIS], [PKIdCuentaBancaria]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[OperacionBancaria] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_OperacionBancaria_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[OperacionBancaria] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_OperacionBancaria_IdEmpresa_IdPago_Pago] FOREIGN KEY ([IdEmpresa], [IdPago]) REFERENCES [PAG].[Pago] ([IdEmpresa], [IdPago]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[OperacionBancaria] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_OperacionBancaria_IdEmpresa_IdConexion_ConexionBancaria] FOREIGN KEY ([IdEmpresa], [IdConexion]) REFERENCES [TES].[ConexionBancaria] ([IdEmpresa], [IdConexionBancaria]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[OperacionBancaria] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_OperacionBancaria_IdEmpresa_IdLoteDispersion_LoteDispersion] FOREIGN KEY ([IdEmpresa], [IdLoteDispersion]) REFERENCES [TES].[LoteDispersion] ([IdEmpresa], [IdLoteDispersion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[OperacionBancaria] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_OperacionBancaria_IdEmpresa_IdDocumentoAcuse_Documento] FOREIGN KEY ([IdEmpresa], [IdDocumentoAcuse]) REFERENCES [SIS].[Documento] ([FkidEmpresaSis], [PkidDocumento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[IntentoEnvioBancario] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_IntentoEnvioBancario_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[IntentoEnvioBancario] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_IntentoEnvioBancario_IdEmpresa_IdOperacionBancaria_OperacionBancaria] FOREIGN KEY ([IdEmpresa], [IdOperacionBancaria]) REFERENCES [TES].[OperacionBancaria] ([IdEmpresa], [IdOperacionBancaria]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[MovimientoBancario] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_MovimientoBancario_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[MovimientoBancario] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_MovimientoBancario_IdEmpresa_IdCuentaBancaria_CuentaBancaria] FOREIGN KEY ([IdEmpresa], [IdCuentaBancaria]) REFERENCES [TES].[CuentaBancaria] ([FKIdEmpresa_SIS], [PKIdCuentaBancaria]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[MovimientoBancario] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_MovimientoBancario_IdMoneda_Moneda] FOREIGN KEY ([IdMoneda]) REFERENCES [SIS].[Moneda] ([PKIdMoneda]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[MovimientoBancario] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_MovimientoBancario_IdEmpresa_IdDocumentoEstadoCuenta_Documento] FOREIGN KEY ([IdEmpresa], [IdDocumentoEstadoCuenta]) REFERENCES [SIS].[Documento] ([FkidEmpresaSis], [PkidDocumento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[ConciliacionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_ConciliacionDetalle_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[ConciliacionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_ConciliacionDetalle_IdEmpresa_IdMovimientoBancario_MovimientoBancario] FOREIGN KEY ([IdEmpresa], [IdMovimientoBancario]) REFERENCES [TES].[MovimientoBancario] ([IdEmpresa], [IdMovimientoBancario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[ConciliacionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_ConciliacionDetalle_IdEmpresa_IdPago_Pago] FOREIGN KEY ([IdEmpresa], [IdPago]) REFERENCES [PAG].[Pago] ([IdEmpresa], [IdPago]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[PrevisionTesoreria] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_PrevisionTesoreria_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[PrevisionTesoreria] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_PrevisionTesoreria_IdMoneda_Moneda] FOREIGN KEY ([IdMoneda]) REFERENCES [SIS].[Moneda] ([PKIdMoneda]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[PrevisionTesoreria] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_PrevisionTesoreria_IdEmpresa_IdOperacion_OperacionNegocio] FOREIGN KEY ([IdEmpresa], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[FondoCaja] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_FondoCaja_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[FondoCaja] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_FondoCaja_IdEmpresa_IdResponsable_ResponsableOperativo] FOREIGN KEY ([IdEmpresa], [IdResponsable]) REFERENCES [SIS].[ResponsableOperativo] ([IdEmpresa], [IdResponsableOperativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[FondoCaja] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_FondoCaja_IdEmpresa_IdCentroCosto_CentroCosto] FOREIGN KEY ([IdEmpresa], [IdCentroCosto]) REFERENCES [SIS].[CentroCosto] ([IdEmpresa], [IdCentroCosto]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[FondoCaja] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_FondoCaja_IdMoneda_Moneda] FOREIGN KEY ([IdMoneda]) REFERENCES [SIS].[Moneda] ([PKIdMoneda]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[ValeCaja] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_ValeCaja_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[ValeCaja] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_ValeCaja_IdEmpresa_IdFondo_FondoCaja] FOREIGN KEY ([IdEmpresa], [IdFondo]) REFERENCES [CAJA].[FondoCaja] ([IdEmpresa], [IdFondoCaja]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[ValeCaja] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_ValeCaja_IdEmpresa_IdOperacion_OperacionNegocio] FOREIGN KEY ([IdEmpresa], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[MovimientoFondo] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_MovimientoFondo_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[MovimientoFondo] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_MovimientoFondo_IdEmpresa_IdFondo_FondoCaja] FOREIGN KEY ([IdEmpresa], [IdFondo]) REFERENCES [CAJA].[FondoCaja] ([IdEmpresa], [IdFondoCaja]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[MovimientoFondo] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_MovimientoFondo_IdEmpresa_IdOperacion_OperacionNegocio] FOREIGN KEY ([IdEmpresa], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[MovimientoFondo] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_MovimientoFondo_IdEmpresa_IdVale_ValeCaja] FOREIGN KEY ([IdEmpresa], [IdVale]) REFERENCES [CAJA].[ValeCaja] ([IdEmpresa], [IdValeCaja]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[MovimientoFondo] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_MovimientoFondo_IdEmpresa_IdMovimientoReversa_MovimientoFondo] FOREIGN KEY ([IdEmpresa], [IdMovimientoReversa]) REFERENCES [CAJA].[MovimientoFondo] ([IdEmpresa], [IdMovimientoFondo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[ArqueoCaja] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_ArqueoCaja_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[ArqueoCaja] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_ArqueoCaja_IdEmpresa_IdFondo_FondoCaja] FOREIGN KEY ([IdEmpresa], [IdFondo]) REFERENCES [CAJA].[FondoCaja] ([IdEmpresa], [IdFondoCaja]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[ArqueoCaja] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_ArqueoCaja_IdEmpresa_IdResponsable_ResponsableOperativo] FOREIGN KEY ([IdEmpresa], [IdResponsable]) REFERENCES [SIS].[ResponsableOperativo] ([IdEmpresa], [IdResponsableOperativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[ArqueoDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_ArqueoDetalle_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[ArqueoDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_ArqueoDetalle_IdEmpresa_IdArqueo_ArqueoCaja] FOREIGN KEY ([IdEmpresa], [IdArqueo]) REFERENCES [CAJA].[ArqueoCaja] ([IdEmpresa], [IdArqueoCaja]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[ComprobacionCaja] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_ComprobacionCaja_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[ComprobacionCaja] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_ComprobacionCaja_IdEmpresa_IdVale_ValeCaja] FOREIGN KEY ([IdEmpresa], [IdVale]) REFERENCES [CAJA].[ValeCaja] ([IdEmpresa], [IdValeCaja]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[ComprobacionCaja] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_ComprobacionCaja_IdEmpresa_IdComprobanteGasto_ComprobanteGasto] FOREIGN KEY ([IdEmpresa], [IdComprobanteGasto]) REFERENCES [FIS].[ComprobanteGasto] ([IdEmpresa], [IdComprobanteGasto]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[ReposicionCaja] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_ReposicionCaja_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[ReposicionCaja] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_ReposicionCaja_IdEmpresa_IdFondo_FondoCaja] FOREIGN KEY ([IdEmpresa], [IdFondo]) REFERENCES [CAJA].[FondoCaja] ([IdEmpresa], [IdFondoCaja]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[ReposicionCaja] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_ReposicionCaja_IdEmpresa_IdOperacion_OperacionNegocio] FOREIGN KEY ([IdEmpresa], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[ReposicionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_ReposicionDetalle_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[ReposicionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_ReposicionDetalle_IdEmpresa_IdReposicion_ReposicionCaja] FOREIGN KEY ([IdEmpresa], [IdReposicion]) REFERENCES [CAJA].[ReposicionCaja] ([IdEmpresa], [IdReposicionCaja]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[ReposicionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_ReposicionDetalle_IdEmpresa_IdComprobacionCaja_ComprobacionCaja] FOREIGN KEY ([IdEmpresa], [IdComprobacionCaja]) REFERENCES [CAJA].[ComprobacionCaja] ([IdEmpresa], [IdComprobacionCaja]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[CompromisoPago] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_CompromisoPago_IdEmpresa_IdReposicionCaja_ReposicionCaja] FOREIGN KEY ([IdEmpresa], [IdReposicionCaja]) REFERENCES [CAJA].[ReposicionCaja] ([IdEmpresa], [IdReposicionCaja]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CAJA].[MovimientoFondo] WITH CHECK ADD CONSTRAINT [FK_EXUX_CAJA_MovimientoFondo_IdEmpresa_IdReposicion_ReposicionCaja] FOREIGN KEY ([IdEmpresa], [IdReposicion]) REFERENCES [CAJA].[ReposicionCaja] ([IdEmpresa], [IdReposicionCaja]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [VIA].[SolicitudViatico] WITH CHECK ADD CONSTRAINT [FK_EXUX_VIA_SolicitudViatico_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [VIA].[SolicitudViatico] WITH CHECK ADD CONSTRAINT [FK_EXUX_VIA_SolicitudViatico_IdEmpresa_IdOperacion_OperacionNegocio] FOREIGN KEY ([IdEmpresa], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [VIA].[SolicitudViatico] WITH CHECK ADD CONSTRAINT [FK_EXUX_VIA_SolicitudViatico_IdEmpresa_IdResponsable_ResponsableOperativo] FOREIGN KEY ([IdEmpresa], [IdResponsable]) REFERENCES [SIS].[ResponsableOperativo] ([IdEmpresa], [IdResponsableOperativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [VIA].[SolicitudViatico] WITH CHECK ADD CONSTRAINT [FK_EXUX_VIA_SolicitudViatico_IdEmpresa_IdCentroCosto_CentroCosto] FOREIGN KEY ([IdEmpresa], [IdCentroCosto]) REFERENCES [SIS].[CentroCosto] ([IdEmpresa], [IdCentroCosto]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [VIA].[SolicitudViatico] WITH CHECK ADD CONSTRAINT [FK_EXUX_VIA_SolicitudViatico_IdMoneda_Moneda] FOREIGN KEY ([IdMoneda]) REFERENCES [SIS].[Moneda] ([PKIdMoneda]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [VIA].[AnticipoViatico] WITH CHECK ADD CONSTRAINT [FK_EXUX_VIA_AnticipoViatico_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [VIA].[AnticipoViatico] WITH CHECK ADD CONSTRAINT [FK_EXUX_VIA_AnticipoViatico_IdEmpresa_IdSolicitud_SolicitudViatico] FOREIGN KEY ([IdEmpresa], [IdSolicitud]) REFERENCES [VIA].[SolicitudViatico] ([IdEmpresa], [IdSolicitudViatico]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [VIA].[ComprobacionViatico] WITH CHECK ADD CONSTRAINT [FK_EXUX_VIA_ComprobacionViatico_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [VIA].[ComprobacionViatico] WITH CHECK ADD CONSTRAINT [FK_EXUX_VIA_ComprobacionViatico_IdEmpresa_IdSolicitud_SolicitudViatico] FOREIGN KEY ([IdEmpresa], [IdSolicitud]) REFERENCES [VIA].[SolicitudViatico] ([IdEmpresa], [IdSolicitudViatico]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [VIA].[ComprobacionViatico] WITH CHECK ADD CONSTRAINT [FK_EXUX_VIA_ComprobacionViatico_IdEmpresa_IdComprobanteGasto_ComprobanteGasto] FOREIGN KEY ([IdEmpresa], [IdComprobanteGasto]) REFERENCES [FIS].[ComprobanteGasto] ([IdEmpresa], [IdComprobanteGasto]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [VIA].[ReintegroViatico] WITH CHECK ADD CONSTRAINT [FK_EXUX_VIA_ReintegroViatico_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [VIA].[ReintegroViatico] WITH CHECK ADD CONSTRAINT [FK_EXUX_VIA_ReintegroViatico_IdEmpresa_IdSolicitud_SolicitudViatico] FOREIGN KEY ([IdEmpresa], [IdSolicitud]) REFERENCES [VIA].[SolicitudViatico] ([IdEmpresa], [IdSolicitudViatico]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [VIA].[ReintegroViatico] WITH CHECK ADD CONSTRAINT [FK_EXUX_VIA_ReintegroViatico_IdEmpresa_IdMovimientoBancario_MovimientoBancario] FOREIGN KEY ([IdEmpresa], [IdMovimientoBancario]) REFERENCES [TES].[MovimientoBancario] ([IdEmpresa], [IdMovimientoBancario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [VIA].[ReintegroViatico] WITH CHECK ADD CONSTRAINT [FK_EXUX_VIA_ReintegroViatico_IdEmpresa_IdDocumentoEvidencia_Documento] FOREIGN KEY ([IdEmpresa], [IdDocumentoEvidencia]) REFERENCES [SIS].[Documento] ([FkidEmpresaSis], [PkidDocumento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[CompromisoPago] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_CompromisoPago_IdEmpresa_IdAnticipoViatico_AnticipoViatico] FOREIGN KEY ([IdEmpresa], [IdAnticipoViatico]) REFERENCES [VIA].[AnticipoViatico] ([IdEmpresa], [IdAnticipoViatico]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CUM].[CatalogoObligacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_CUM_CatalogoObligacion_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CUM].[ObligacionEmpresa] WITH CHECK ADD CONSTRAINT [FK_EXUX_CUM_ObligacionEmpresa_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CUM].[ObligacionEmpresa] WITH CHECK ADD CONSTRAINT [FK_EXUX_CUM_ObligacionEmpresa_IdEmpresa_IdCatalogo_CatalogoObligacion] FOREIGN KEY ([IdEmpresa], [IdCatalogo]) REFERENCES [CUM].[CatalogoObligacion] ([IdEmpresa], [IdCatalogoObligacion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CUM].[ObligacionEmpresa] WITH CHECK ADD CONSTRAINT [FK_EXUX_CUM_ObligacionEmpresa_IdEmpresa_IdResponsable_ResponsableOperativo] FOREIGN KEY ([IdEmpresa], [IdResponsable]) REFERENCES [SIS].[ResponsableOperativo] ([IdEmpresa], [IdResponsableOperativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CUM].[ObligacionEmpresa] WITH CHECK ADD CONSTRAINT [FK_EXUX_CUM_ObligacionEmpresa_IdEmpresa_IdSucursal_Sucursal] FOREIGN KEY ([IdEmpresa], [IdSucursal]) REFERENCES [SIS].[Sucursal] ([FKIdEmpresa_SIS], [PKIdSucursal]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CUM].[VencimientoObligacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_CUM_VencimientoObligacion_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CUM].[VencimientoObligacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_CUM_VencimientoObligacion_IdEmpresa_IdObligacion_ObligacionEmpresa] FOREIGN KEY ([IdEmpresa], [IdObligacion]) REFERENCES [CUM].[ObligacionEmpresa] ([IdEmpresa], [IdObligacionEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CUM].[VencimientoObligacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_CUM_VencimientoObligacion_IdEmpresa_IdOperacion_OperacionNegocio] FOREIGN KEY ([IdEmpresa], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CUM].[EvidenciaCumplimiento] WITH CHECK ADD CONSTRAINT [FK_EXUX_CUM_EvidenciaCumplimiento_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CUM].[EvidenciaCumplimiento] WITH CHECK ADD CONSTRAINT [FK_EXUX_CUM_EvidenciaCumplimiento_IdEmpresa_IdVencimiento_VencimientoObligacion] FOREIGN KEY ([IdEmpresa], [IdVencimiento]) REFERENCES [CUM].[VencimientoObligacion] ([IdEmpresa], [IdVencimientoObligacion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CUM].[EvidenciaCumplimiento] WITH CHECK ADD CONSTRAINT [FK_EXUX_CUM_EvidenciaCumplimiento_IdEmpresa_IdDocumento_Documento] FOREIGN KEY ([IdEmpresa], [IdDocumento]) REFERENCES [SIS].[Documento] ([FkidEmpresaSis], [PkidDocumento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CUM].[EvidenciaCumplimiento] WITH CHECK ADD CONSTRAINT [FK_EXUX_CUM_EvidenciaCumplimiento_IdEmpresa_IdResponsable_ResponsableOperativo] FOREIGN KEY ([IdEmpresa], [IdResponsable]) REFERENCES [SIS].[ResponsableOperativo] ([IdEmpresa], [IdResponsableOperativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[CompromisoPago] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_CompromisoPago_IdEmpresa_IdVencimientoObligacion_VencimientoObligacion] FOREIGN KEY ([IdEmpresa], [IdVencimientoObligacion]) REFERENCES [CUM].[VencimientoObligacion] ([IdEmpresa], [IdVencimientoObligacion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[Declaracion] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_Declaracion_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[Declaracion] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_Declaracion_IdEmpresa_IdVencimiento_VencimientoObligacion] FOREIGN KEY ([IdEmpresa], [IdVencimiento]) REFERENCES [CUM].[VencimientoObligacion] ([IdEmpresa], [IdVencimientoObligacion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[DeclaracionVersion] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_DeclaracionVersion_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[DeclaracionVersion] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_DeclaracionVersion_IdEmpresa_IdDeclaracion_Declaracion] FOREIGN KEY ([IdEmpresa], [IdDeclaracion]) REFERENCES [FIS].[Declaracion] ([IdEmpresa], [IdDeclaracion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[DeclaracionVersion] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_DeclaracionVersion_IdEmpresa_IdDocumentoAcuse_Documento] FOREIGN KEY ([IdEmpresa], [IdDocumentoAcuse]) REFERENCES [SIS].[Documento] ([FkidEmpresaSis], [PkidDocumento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[DeclaracionVersion] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_DeclaracionVersion_IdEmpresa_IdUsuarioValidacion_Usuario] FOREIGN KEY ([IdEmpresa], [IdUsuarioValidacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[ReglaFiscalVersion] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_ReglaFiscalVersion_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[ReglaFiscalVersion] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_ReglaFiscalVersion_IdEmpresa_IdUsuarioAprobacion_Usuario] FOREIGN KEY ([IdEmpresa], [IdUsuarioAprobacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[DeterminacionImpuesto] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_DeterminacionImpuesto_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[DeterminacionImpuesto] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_DeterminacionImpuesto_IdEmpresa_IdDeclaracionVersion_DeclaracionVersion] FOREIGN KEY ([IdEmpresa], [IdDeclaracionVersion]) REFERENCES [FIS].[DeclaracionVersion] ([IdEmpresa], [IdDeclaracionVersion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[DeterminacionImpuesto] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_DeterminacionImpuesto_IdEmpresa_IdReglaFiscalVersion_ReglaFiscalVersion] FOREIGN KEY ([IdEmpresa], [IdReglaFiscalVersion]) REFERENCES [FIS].[ReglaFiscalVersion] ([IdEmpresa], [IdReglaFiscalVersion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[ActualizacionRecargo] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_ActualizacionRecargo_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[ActualizacionRecargo] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_ActualizacionRecargo_IdEmpresa_IdDeterminacion_DeterminacionImpuesto] FOREIGN KEY ([IdEmpresa], [IdDeterminacion]) REFERENCES [FIS].[DeterminacionImpuesto] ([IdEmpresa], [IdDeterminacionImpuesto]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[DeclaracionCfdi] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_DeclaracionCfdi_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[DeclaracionCfdi] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_DeclaracionCfdi_IdEmpresa_IdDeclaracionVersion_DeclaracionVersion] FOREIGN KEY ([IdEmpresa], [IdDeclaracionVersion]) REFERENCES [FIS].[DeclaracionVersion] ([IdEmpresa], [IdDeclaracionVersion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[DeclaracionCfdi] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_DeclaracionCfdi_IdEmpresa_IdCfdi_Cfdi] FOREIGN KEY ([IdEmpresa], [IdCfdi]) REFERENCES [FIS].[Cfdi] ([IdEmpresa], [IdCfdi]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[AuditoriaFiscal] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_AuditoriaFiscal_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[ObservacionFiscal] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_ObservacionFiscal_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[ObservacionFiscal] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_ObservacionFiscal_IdEmpresa_IdAuditoria_AuditoriaFiscal] FOREIGN KEY ([IdEmpresa], [IdAuditoria]) REFERENCES [FIS].[AuditoriaFiscal] ([IdEmpresa], [IdAuditoriaFiscal]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[ObservacionFiscal] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_ObservacionFiscal_IdEmpresa_IdDocumentoEvidencia_Documento] FOREIGN KEY ([IdEmpresa], [IdDocumentoEvidencia]) REFERENCES [SIS].[Documento] ([FkidEmpresaSis], [PkidDocumento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[SancionFiscal] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_SancionFiscal_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[SancionFiscal] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_SancionFiscal_IdEmpresa_IdObservacion_ObservacionFiscal] FOREIGN KEY ([IdEmpresa], [IdObservacion]) REFERENCES [FIS].[ObservacionFiscal] ([IdEmpresa], [IdObservacionFiscal]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [FIS].[SancionFiscal] WITH CHECK ADD CONSTRAINT [FK_EXUX_FIS_SancionFiscal_IdMoneda_Moneda] FOREIGN KEY ([IdMoneda]) REFERENCES [SIS].[Moneda] ([PKIdMoneda]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[CompromisoPago] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_CompromisoPago_IdEmpresa_IdSancionFiscal_SancionFiscal] FOREIGN KEY ([IdEmpresa], [IdSancionFiscal]) REFERENCES [FIS].[SancionFiscal] ([IdEmpresa], [IdSancionFiscal]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [WF].[ReglaAutorizacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_WF_ReglaAutorizacion_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [WF].[ReglaAutorizacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_WF_ReglaAutorizacion_IdEmpresa_IdTemplate_WorkflowTemplate] FOREIGN KEY ([IdEmpresa], [IdTemplate]) REFERENCES [PBR].[WorkflowTemplate] ([IdEmpresa], [PKIdWorkflowTemplate]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [WF].[ReglaAutorizacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_WF_ReglaAutorizacion_IdEmpresa_IdSucursal_Sucursal] FOREIGN KEY ([IdEmpresa], [IdSucursal]) REFERENCES [SIS].[Sucursal] ([FKIdEmpresa_SIS], [PKIdSucursal]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [WF].[ReglaAutorizacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_WF_ReglaAutorizacion_RoleId_AspNetRoles] FOREIGN KEY ([RoleId]) REFERENCES [dbo].[AspNetRoles] ([Id]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [WF].[DecisionAutorizacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_WF_DecisionAutorizacion_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [WF].[DecisionAutorizacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_WF_DecisionAutorizacion_IdEmpresa_IdEnvio_EnvioWorkflow] FOREIGN KEY ([IdEmpresa], [IdEnvio]) REFERENCES [SIS].[EnvioWorkflow] ([IdEmpresa], [PKIdEnvioWorkflow]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [WF].[DecisionAutorizacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_WF_DecisionAutorizacion_IdEmpresa_IdRegla_ReglaAutorizacion] FOREIGN KEY ([IdEmpresa], [IdRegla]) REFERENCES [WF].[ReglaAutorizacion] ([IdEmpresa], [IdReglaAutorizacion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [WF].[DecisionAutorizacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_WF_DecisionAutorizacion_IdEmpresa_IdUsuario_Usuario] FOREIGN KEY ([IdEmpresa], [IdUsuario]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [WF].[CalendarioAtencion] WITH CHECK ADD CONSTRAINT [FK_EXUX_WF_CalendarioAtencion_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [WF].[PoliticaSLA] WITH CHECK ADD CONSTRAINT [FK_EXUX_WF_PoliticaSLA_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [WF].[PoliticaSLA] WITH CHECK ADD CONSTRAINT [FK_EXUX_WF_PoliticaSLA_IdEmpresa_IdTemplate_WorkflowTemplate] FOREIGN KEY ([IdEmpresa], [IdTemplate]) REFERENCES [PBR].[WorkflowTemplate] ([IdEmpresa], [PKIdWorkflowTemplate]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [WF].[PoliticaSLA] WITH CHECK ADD CONSTRAINT [FK_EXUX_WF_PoliticaSLA_IdEmpresa_IdCalendario_CalendarioAtencion] FOREIGN KEY ([IdEmpresa], [IdCalendario]) REFERENCES [WF].[CalendarioAtencion] ([IdEmpresa], [IdCalendarioAtencion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [WF].[PlazoOperacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_WF_PlazoOperacion_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [WF].[PlazoOperacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_WF_PlazoOperacion_IdEmpresa_IdEnvio_EnvioWorkflow] FOREIGN KEY ([IdEmpresa], [IdEnvio]) REFERENCES [SIS].[EnvioWorkflow] ([IdEmpresa], [PKIdEnvioWorkflow]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [WF].[PlazoOperacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_WF_PlazoOperacion_IdEmpresa_IdPoliticaSLA_PoliticaSLA] FOREIGN KEY ([IdEmpresa], [IdPoliticaSLA]) REFERENCES [WF].[PoliticaSLA] ([IdEmpresa], [IdPoliticaSLA]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [WF].[EventoPendiente] WITH CHECK ADD CONSTRAINT [FK_EXUX_WF_EventoPendiente_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [WF].[EventoPendiente] WITH CHECK ADD CONSTRAINT [FK_EXUX_WF_EventoPendiente_IdEmpresa_IdOperacion_OperacionNegocio] FOREIGN KEY ([IdEmpresa], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[EnvioWorkflow] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_EnvioWorkflow_IdEmpresa_IdOperacion_OperacionNegocio] FOREIGN KEY ([IdEmpresa], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[EnvioWorkflow] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_EnvioWorkflow_IdEmpresa_IdTemplate_WorkflowTemplate] FOREIGN KEY ([IdEmpresa], [IdTemplate]) REFERENCES [PBR].[WorkflowTemplate] ([IdEmpresa], [PKIdWorkflowTemplate]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[Notificacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_Notificacion_IdEmpresa_IdEventoPendiente_EventoPendiente] FOREIGN KEY ([IdEmpresa], [IdEventoPendiente]) REFERENCES [WF].[EventoPendiente] ([IdEmpresa], [IdEventoPendiente]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[Notificacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_Notificacion_IdEmpresa_IdRegla_NotificacionRegla] FOREIGN KEY ([IdEmpresa], [IdRegla]) REFERENCES [SIS].[NotificacionRegla] ([IdEmpresa], [Pk_IdNotificacionRegla]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [DOC].[OperacionDocumento] WITH CHECK ADD CONSTRAINT [FK_EXUX_DOC_OperacionDocumento_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [DOC].[OperacionDocumento] WITH CHECK ADD CONSTRAINT [FK_EXUX_DOC_OperacionDocumento_IdEmpresa_IdOperacion_OperacionNegocio] FOREIGN KEY ([IdEmpresa], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [DOC].[OperacionDocumento] WITH CHECK ADD CONSTRAINT [FK_EXUX_DOC_OperacionDocumento_IdEmpresa_IdDocumento_Documento] FOREIGN KEY ([IdEmpresa], [IdDocumento]) REFERENCES [SIS].[Documento] ([FkidEmpresaSis], [PkidDocumento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [DOC].[ExtraccionDocumento] WITH CHECK ADD CONSTRAINT [FK_EXUX_DOC_ExtraccionDocumento_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [DOC].[ExtraccionDocumento] WITH CHECK ADD CONSTRAINT [FK_EXUX_DOC_ExtraccionDocumento_IdEmpresa_IdDocumento_Documento] FOREIGN KEY ([IdEmpresa], [IdDocumento]) REFERENCES [SIS].[Documento] ([FkidEmpresaSis], [PkidDocumento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [DOC].[ExtraccionDocumento] WITH CHECK ADD CONSTRAINT [FK_EXUX_DOC_ExtraccionDocumento_IdEmpresa_IdUsuarioRevision_Usuario] FOREIGN KEY ([IdEmpresa], [IdUsuarioRevision]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [DOC].[CampoExtraido] WITH CHECK ADD CONSTRAINT [FK_EXUX_DOC_CampoExtraido_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [DOC].[CampoExtraido] WITH CHECK ADD CONSTRAINT [FK_EXUX_DOC_CampoExtraido_IdEmpresa_IdExtraccion_ExtraccionDocumento] FOREIGN KEY ([IdEmpresa], [IdExtraccion]) REFERENCES [DOC].[ExtraccionDocumento] ([IdEmpresa], [IdExtraccionDocumento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CTL].[ReglaRiesgo] WITH CHECK ADD CONSTRAINT [FK_EXUX_CTL_ReglaRiesgo_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CTL].[CasoRiesgo] WITH CHECK ADD CONSTRAINT [FK_EXUX_CTL_CasoRiesgo_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CTL].[CasoRiesgo] WITH CHECK ADD CONSTRAINT [FK_EXUX_CTL_CasoRiesgo_IdEmpresa_IdRegla_ReglaRiesgo] FOREIGN KEY ([IdEmpresa], [IdRegla]) REFERENCES [CTL].[ReglaRiesgo] ([IdEmpresa], [IdReglaRiesgo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CTL].[CasoRiesgo] WITH CHECK ADD CONSTRAINT [FK_EXUX_CTL_CasoRiesgo_IdEmpresa_IdOperacion_OperacionNegocio] FOREIGN KEY ([IdEmpresa], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CTL].[CasoRiesgo] WITH CHECK ADD CONSTRAINT [FK_EXUX_CTL_CasoRiesgo_IdEmpresa_IdDocumentoEvidencia_Documento] FOREIGN KEY ([IdEmpresa], [IdDocumentoEvidencia]) REFERENCES [SIS].[Documento] ([FkidEmpresaSis], [PkidDocumento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CTL].[CasoRiesgo] WITH CHECK ADD CONSTRAINT [FK_EXUX_CTL_CasoRiesgo_IdEmpresa_IdResponsable_ResponsableOperativo] FOREIGN KEY ([IdEmpresa], [IdResponsable]) REFERENCES [SIS].[ResponsableOperativo] ([IdEmpresa], [IdResponsableOperativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CTL].[ReglaSegregacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_CTL_ReglaSegregacion_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PBR].[AuditoriaCambio] WITH CHECK ADD CONSTRAINT [FK_EXUX_PBR_AuditoriaCambio_IdEmpresa_IdOperacion_OperacionNegocio] FOREIGN KEY ([IdEmpresa], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[Poliza] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_Poliza_IdEmpresa_IdOperacion_OperacionNegocio] FOREIGN KEY ([IdEmpresa], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[Poliza] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_Poliza_IdEmpresa_IdPolizaReversa_Poliza] FOREIGN KEY ([IdEmpresa], [IdPolizaReversa]) REFERENCES [CONTA].[Poliza] ([IdEmpresa], [PKIdPoliza]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Requisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Requisicion_FKIdEmpresa_SIS_IdOperacion_OperacionNegocio] FOREIGN KEY ([FKIdEmpresa_SIS], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[OrdenCompra] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_OrdenCompra_FKIdEmpresa_SIS_IdOperacion_OperacionNegocio] FOREIGN KEY ([FKIdEmpresa_SIS], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoAutorizado_FKIdEmpresa_SIS_IdOperacion_OperacionNegocio] FOREIGN KEY ([FKIdEmpresa_SIS], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgreAdecuacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgreAdecuacion_FKIdEmpresa_SIS_IdOperacion_OperacionNegocio] FOREIGN KEY ([FKIdEmpresa_SIS], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[CLC] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_CLC_FKIdEmpresa_SIS_IdOperacion_OperacionNegocio] FOREIGN KEY ([FKIdEmpresa_SIS], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Factura] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Factura_FKIdEmpresa_SIS_IdOperacion_OperacionNegocio] FOREIGN KEY ([FKIdEmpresa_SIS], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[SolicitudSalida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_SolicitudSalida_FKIdEmpresa_SIS_IdOperacion_OperacionNegocio] FOREIGN KEY ([FKIdEmpresa_SIS], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bajas] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bajas_FKIdEmpresa_SIS_IdOperacion_OperacionNegocio] FOREIGN KEY ([FKIdEmpresa_SIS], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Resguardo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Resguardo_FKIdEmpresa_SIS_IdOperacion_OperacionNegocio] FOREIGN KEY ([FKIdEmpresa_SIS], [IdOperacion]) REFERENCES [SIS].[OperacionNegocio] ([IdEmpresa], [IdOperacionNegocio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[ProveedorEmpresa] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_ProveedorEmpresa_IdEmpresa_IdCuentaContable_CuentaContable] FOREIGN KEY ([IdEmpresa], [IdCuentaContable]) REFERENCES [CONTA].[CuentaContable] ([FKIdEmpresa_SIS], [PKIdCuentaContable]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[CuentaBancaria] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_CuentaBancaria_IdMoneda_Moneda] FOREIGN KEY ([IdMoneda]) REFERENCES [SIS].[Moneda] ([PKIdMoneda]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[DetalleSolicitudSalida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_DetalleSolicitudSalida_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[TipoBien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_TipoBien_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[CuentaEspecial] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_CuentaEspecial_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizConversion] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizConversion_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizIngreso] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizIngreso_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[PolizaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_PolizaDetalle_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Cotizacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Cotizacion_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[OrdenCompraPartida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_OrdenCompraPartida_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgreAdecuacionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgreAdecuacionDetalle_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[IngreAdecuacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_IngreAdecuacion_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[IngreAdecuacionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_IngreAdecuacionDetalle_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[IngresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_IngresoAutorizado_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[RegresoChequeSuficienciaPoliza] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_RegresoChequeSuficienciaPoliza_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[DocumentoAnotacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_DocumentoAnotacion_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[DocumentoEvento] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_DocumentoEvento_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[NotificacionDestino] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_NotificacionDestino_IdEmpresa_Empresa] FOREIGN KEY ([IdEmpresa]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[PartidaStock] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_PartidaStock_IdEmpresa_IdProductoAlmacen_IdAlmacen_IdTipoBien_ProductoAlmacen] FOREIGN KEY ([IdEmpresa], [IdProductoAlmacen], [IdAlmacen], [IdTipoBien]) REFERENCES [ALMA].[ProductoAlmacen] ([IdEmpresa], [IdProductoAlmacen], [IdAlmacen], [IdTipoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[PartidaStock] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_PartidaStock_IdEmpresa_IdUbicacion_IdAlmacen_UbicacionAlmacen] FOREIGN KEY ([IdEmpresa], [IdUbicacion], [IdAlmacen]) REFERENCES [ALMA].[UbicacionAlmacen] ([IdEmpresa], [IdUbicacionAlmacen], [IdAlmacen]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[PartidaStock] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_PartidaStock_IdEmpresa_IdLote_IdTipoBien_Lote] FOREIGN KEY ([IdEmpresa], [IdLote], [IdTipoBien]) REFERENCES [ALMA].[Lote] ([IdEmpresa], [IdLote], [IdTipoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[PlanConteoCiclico] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_PlanConteoCiclico_IdEmpresa_IdProductoAlmacen_FKIdTipoBien_ALMA_ProductoAlmacen] FOREIGN KEY ([IdEmpresa], [IdProductoAlmacen], [FKIdTipoBien_ALMA]) REFERENCES [ALMA].[ProductoAlmacen] ([IdEmpresa], [IdProductoAlmacen], [IdTipoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[CierreInventario] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_CierreInventario_FKIdEmpresa_SIS_IdPartidaStock_FKIdTipoBien_ALMA_PartidaStock] FOREIGN KEY ([FKIdEmpresa_SIS], [IdPartidaStock], [FKIdTipoBien_ALMA]) REFERENCES [ALMA].[PartidaStock] ([IdEmpresa], [IdPartidaStock], [IdTipoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Conteo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Conteo_IdEmpresa_IdAlmacen_AlmacenCatalogo] FOREIGN KEY ([IdEmpresa], [IdAlmacen]) REFERENCES [ALMA].[AlmacenCatalogo] ([IdEmpresa], [IdAlmacenCatalogo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Conteo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Conteo_IdEmpresa_IdPartidaStock_IdAlmacen_FKIdTipoBien_ALMA_PartidaStock] FOREIGN KEY ([IdEmpresa], [IdPartidaStock], [IdAlmacen], [FKIdTipoBien_ALMA]) REFERENCES [ALMA].[PartidaStock] ([IdEmpresa], [IdPartidaStock], [IdAlmacen], [IdTipoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Conteo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Conteo_IdEmpresa_FKIdPeriodoConteo_ALMA_IdAlmacen_PeriodoConteo] FOREIGN KEY ([IdEmpresa], [FKIdPeriodoConteo_ALMA], [IdAlmacen]) REFERENCES [ALMA].[PeriodoConteo] ([IdEmpresa], [PKIdPeriodoConteo], [IdAlmacen]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[PeriodoConteo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_PeriodoConteo_IdEmpresa_IdAlmacen_FKIdSucursal_SIS_AlmacenCatalogo] FOREIGN KEY ([IdEmpresa], [IdAlmacen], [FKIdSucursal_SIS]) REFERENCES [ALMA].[AlmacenCatalogo] ([IdEmpresa], [IdAlmacenCatalogo], [IdSucursal]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ReservaStock] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ReservaStock_IdEmpresa_IdAlmacen_AlmacenCatalogo] FOREIGN KEY ([IdEmpresa], [IdAlmacen]) REFERENCES [ALMA].[AlmacenCatalogo] ([IdEmpresa], [IdAlmacenCatalogo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ReservaStock] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ReservaStock_IdEmpresa_IdTipoBien_TipoBien] FOREIGN KEY ([IdEmpresa], [IdTipoBien]) REFERENCES [ALMA].[TipoBien] ([IdEmpresa], [PKIdTipoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ReservaStock] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ReservaStock_IdEmpresa_IdPartidaStock_IdAlmacen_IdTipoBien_PartidaStock] FOREIGN KEY ([IdEmpresa], [IdPartidaStock], [IdAlmacen], [IdTipoBien]) REFERENCES [ALMA].[PartidaStock] ([IdEmpresa], [IdPartidaStock], [IdAlmacen], [IdTipoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[MovimientoInventarioDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_MovimientoInventarioDetalle_IdEmpresa_IdAlmacen_AlmacenCatalogo] FOREIGN KEY ([IdEmpresa], [IdAlmacen]) REFERENCES [ALMA].[AlmacenCatalogo] ([IdEmpresa], [IdAlmacenCatalogo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[MovimientoInventarioDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_MovimientoInventarioDetalle_IdEmpresa_IdTipoBien_TipoBien] FOREIGN KEY ([IdEmpresa], [IdTipoBien]) REFERENCES [ALMA].[TipoBien] ([IdEmpresa], [PKIdTipoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[MovimientoInventarioDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_MovimientoInventarioDetalle_IdEmpresa_IdPartidaStock_IdAlmacen_IdTipoBien_PartidaStock] FOREIGN KEY ([IdEmpresa], [IdPartidaStock], [IdAlmacen], [IdTipoBien]) REFERENCES [ALMA].[PartidaStock] ([IdEmpresa], [IdPartidaStock], [IdAlmacen], [IdTipoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ReservaStock] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ReservaStock_IdEmpresa_IdDetalleSolicitudSalida_IdAlmacen_IdTipoBien_DetalleSolicitudSalida] FOREIGN KEY ([IdEmpresa], [IdDetalleSolicitudSalida], [IdAlmacen], [IdTipoBien]) REFERENCES [ALMA].[DetalleSolicitudSalida] ([IdEmpresa], [PKIdDetalleSolicitudSalida], [IdAlmacen], [FKIdTipoBien_ALMA]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[DetalleSolicitudSalida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_DetalleSolicitudSalida_IdEmpresa_FKIdSolicitudSalida_ALMA_IdAlmacen_SolicitudSalida] FOREIGN KEY ([IdEmpresa], [FKIdSolicitudSalida_ALMA], [IdAlmacen]) REFERENCES [ALMA].[SolicitudSalida] ([FKIdEmpresa_SIS], [PKIdSolicitudSalida], [IdAlmacen]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[MovimientoInventarioDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_MovimientoInventarioDetalle_IdEmpresa_IdDetalleSolicitudSalida_IdAlmacen_IdTipoBien_DetalleSolicitudSalida] FOREIGN KEY ([IdEmpresa], [IdDetalleSolicitudSalida], [IdAlmacen], [IdTipoBien]) REFERENCES [ALMA].[DetalleSolicitudSalida] ([IdEmpresa], [PKIdDetalleSolicitudSalida], [IdAlmacen], [FKIdTipoBien_ALMA]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[MovimientoInventarioDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_MovimientoInventarioDetalle_IdEmpresa_IdTransferenciaDetalle_IdTipoBien_TransferenciaDetalle] FOREIGN KEY ([IdEmpresa], [IdTransferenciaDetalle], [IdTipoBien]) REFERENCES [ALMA].[TransferenciaDetalle] ([IdEmpresa], [IdTransferenciaDetalle], [IdTipoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PBR].[WorkflowEstado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PBR_WorkflowEstado_IdEmpresa_FKIdWorkflowTemplate_PBR_WorkflowTemplate] FOREIGN KEY ([IdEmpresa], [FKIdWorkflowTemplate_PBR]) REFERENCES [PBR].[WorkflowTemplate] ([IdEmpresa], [PKIdWorkflowTemplate]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PBR].[WorkflowTransicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_PBR_WorkflowTransicion_IdEmpresa_FKIdWorkflowTemplate_PBR_WorkflowTemplate] FOREIGN KEY ([IdEmpresa], [FKIdWorkflowTemplate_PBR]) REFERENCES [PBR].[WorkflowTemplate] ([IdEmpresa], [PKIdWorkflowTemplate]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PBR].[WorkflowTransicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_PBR_WorkflowTransicion_IdEmpresa_FKIdEstadoOrigen_PBR_WorkflowEstado] FOREIGN KEY ([IdEmpresa], [FKIdEstadoOrigen_PBR]) REFERENCES [PBR].[WorkflowEstado] ([IdEmpresa], [PKIdWorkflowEstado]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PBR].[WorkflowTransicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_PBR_WorkflowTransicion_IdEmpresa_FKIdEstadoDestino_PBR_WorkflowEstado] FOREIGN KEY ([IdEmpresa], [FKIdEstadoDestino_PBR]) REFERENCES [PBR].[WorkflowEstado] ([IdEmpresa], [PKIdWorkflowEstado]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PBR].[AuditoriaCambio] WITH CHECK ADD CONSTRAINT [FK_EXUX_PBR_AuditoriaCambio_IdEmpresa_FKIdUsuario_PBR_Usuario] FOREIGN KEY ([IdEmpresa], [FKIdUsuario_PBR]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PBR].[WorkflowTransicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_PBR_WorkflowTransicion_IdEmpresa_FKIdWorkflowTemplate_PBR_FKIdEstadoOrigen_PBR_WorkflowEstado] FOREIGN KEY ([IdEmpresa], [FKIdWorkflowTemplate_PBR], [FKIdEstadoOrigen_PBR]) REFERENCES [PBR].[WorkflowEstado] ([IdEmpresa], [FKIdWorkflowTemplate_PBR], [PKIdWorkflowEstado]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PBR].[WorkflowTransicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_PBR_WorkflowTransicion_IdEmpresa_FKIdWorkflowTemplate_PBR_FKIdEstadoDestino_PBR_WorkflowEstado] FOREIGN KEY ([IdEmpresa], [FKIdWorkflowTemplate_PBR], [FKIdEstadoDestino_PBR]) REFERENCES [PBR].[WorkflowEstado] ([IdEmpresa], [FKIdWorkflowTemplate_PBR], [PKIdWorkflowEstado]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EstudioMercadoDetalle_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[PAAASPartida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_PAAASPartida_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[RequisicionPartida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_RequisicionPartida_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[FacturaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_FacturaDetalle_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[CalendarioInventario] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_CalendarioInventario_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[ChequePartidas] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_ChequePartidas_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Contrato] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Contrato_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[Banco] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_Banco_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[PAAAS] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_PAAAS_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Almacen] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Almacen_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgreAdecuacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgreAdecuacion_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[CLC] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_CLC_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[SolicitudSalida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_SolicitudSalida_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_SolicitudSuficienciaDetalle_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Cheque] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Cheque_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[RequisicionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_RequisicionDetalle_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Inventario] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Inventario_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Requisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Requisicion_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[CuentaContable] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_CuentaContable_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[Documento] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_Documento_FkidEmpresaSis_Empresa] FOREIGN KEY ([FkidEmpresaSis]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[CuentaBancaria] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_CuentaBancaria_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[AutorizacionSuficiencia] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_AutorizacionSuficiencia_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[PAAASDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_PAAASDetalle_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[OrdenCompra] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_OrdenCompra_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bajas] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bajas_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Resguardo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Resguardo_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EstudioMercado] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EstudioMercado_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[ContratoDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_ContratoDetalle_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[RegresoChequeSuficiencia] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_RegresoChequeSuficiencia_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[CLCDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_CLCDetalle_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[SolicitudCotizacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_SolicitudCotizacion_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Contratos] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Contratos_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bien_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Deposito] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Deposito_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoAutorizado_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Factura] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Factura_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_AutorizacionSuficienciaDetalle_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[CierreInventario] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_CierreInventario_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalleCosto] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EstudioMercadoDetalleCosto_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[SolicitudSuficiencia] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_SolicitudSuficiencia_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[CLCFactura] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_CLCFactura_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoProyectado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoProyectado_FKIdEmpresa_SIS_Empresa] FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[AplicacionPago] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_AplicacionPago_IdEmpresa_IdPago_IdMoneda_Pago] FOREIGN KEY ([IdEmpresa], [IdPago], [IdMoneda]) REFERENCES [PAG].[Pago] ([IdEmpresa], [IdPago], [IdMoneda]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[AplicacionPago] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_AplicacionPago_IdEmpresa_IdCompromiso_IdMoneda_CompromisoPago] FOREIGN KEY ([IdEmpresa], [IdCompromiso], [IdMoneda]) REFERENCES [PAG].[CompromisoPago] ([IdEmpresa], [IdCompromisoPago], [IdMoneda]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PAG].[Pago] WITH CHECK ADD CONSTRAINT [FK_EXUX_PAG_Pago_IdEmpresa_IdCuentaBancaria_IdMoneda_CuentaBancaria] FOREIGN KEY ([IdEmpresa], [IdCuentaBancaria], [IdMoneda]) REFERENCES [TES].[CuentaBancaria] ([FKIdEmpresa_SIS], [PKIdCuentaBancaria], [IdMoneda]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[MovimientoBancario] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_MovimientoBancario_IdEmpresa_IdCuentaBancaria_IdMoneda_CuentaBancaria] FOREIGN KEY ([IdEmpresa], [IdCuentaBancaria], [IdMoneda]) REFERENCES [TES].[CuentaBancaria] ([FKIdEmpresa_SIS], [PKIdCuentaBancaria], [IdMoneda]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[OrdenCompraDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_OrdenCompraDetalle_IdEmpresa_FKIdCotizacionDetalle_ORCO_CotizacionDetalle] FOREIGN KEY ([IdEmpresa], [FKIdCotizacionDetalle_ORCO]) REFERENCES [ORCO].[CotizacionDetalle] ([IdEmpresa], [PKIdCotizacionDetalle]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[OrdenCompraDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_OrdenCompraDetalle_IdEmpresa_FKIdOrdenCompra_ORCO_OrdenCompra] FOREIGN KEY ([IdEmpresa], [FKIdOrdenCompra_ORCO]) REFERENCES [ORCO].[OrdenCompra] ([FKIdEmpresa_SIS], [PKIdOrdenCompra]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[OrdenCompraDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_OrdenCompraDetalle_IdEmpresa_FKIdRequisicionDetalle_ORCO_RequisicionDetalle] FOREIGN KEY ([IdEmpresa], [FKIdRequisicionDetalle_ORCO]) REFERENCES [ORCO].[RequisicionDetalle] ([FKIdEmpresa_SIS], [PKIdRequisicionDetalle]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[OrdenCompraDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_OrdenCompraDetalle_IdEmpresa_FKIdTipoBien_ALMA_TipoBien] FOREIGN KEY ([IdEmpresa], [FKIdTipoBien_ALMA]) REFERENCES [ALMA].[TipoBien] ([IdEmpresa], [PKIdTipoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[OrdenCompraDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_OrdenCompraDetalle_FKIdUnidades_ALMA_Unidades] FOREIGN KEY ([FKIdUnidades_ALMA]) REFERENCES [ALMA].[Unidades] ([PKIdUnidades]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[Poliza] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_Poliza_FKIdAnio_SIS_Anio] FOREIGN KEY ([FKIdAnio_SIS]) REFERENCES [SIS].[Anio] ([PKIdAnio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[Poliza] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_Poliza_FKIdTipoPoliza_SIS_TipoPoliza] FOREIGN KEY ([FKIdTipoPoliza_SIS]) REFERENCES [SIS].[TipoPoliza] ([PKIdTipoPoliza]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[Poliza] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_Poliza_IdEmpresa_UsuarioCreacion_Usuario] FOREIGN KEY ([IdEmpresa], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[Poliza] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_Poliza_IdEmpresa_UsuarioModificacion_Usuario] FOREIGN KEY ([IdEmpresa], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EstudioMercadoDetalle_FKIdEmpresa_SIS_FKIdEstudioMercado_ORCO_EstudioMercado] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdEstudioMercado_ORCO]) REFERENCES [ORCO].[EstudioMercado] ([FKIdEmpresa_SIS], [PKIdEstudioMercado]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EstudioMercadoDetalle_FKIdEmpresa_SIS_FKIdPAAASDetalle_ORCO_PAAASDetalle] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdPAAASDetalle_ORCO]) REFERENCES [ORCO].[PAAASDetalle] ([FKIdEmpresa_SIS], [PKIdPAAASDetalle]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EstudioMercadoDetalle_FKIdProveedor_SIS_Proveedor] FOREIGN KEY ([FKIdProveedor_SIS]) REFERENCES [SIS].[Proveedor] ([PKIdProveedor]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EstudioMercadoDetalle_FKIdEmpresa_SIS_FKIdTipoBien_ALMA_TipoBien] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdTipoBien_ALMA]) REFERENCES [ALMA].[TipoBien] ([IdEmpresa], [PKIdTipoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EstudioMercadoDetalle_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EstudioMercadoDetalle_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[GrupoBien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_GrupoBien_FKIdFamilia_ALMA_Familia] FOREIGN KEY ([FKIdFamilia_ALMA]) REFERENCES [ALMA].[Familia] ([PKIdFamilia]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[GrupoBien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_GrupoBien_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[GrupoBien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_GrupoBien_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[PAAASPartida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_PAAASPartida_FKIdEmpresa_SIS_FKIdPAAAS_ORCO_PAAAS] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdPAAAS_ORCO]) REFERENCES [ORCO].[PAAAS] ([FKIdEmpresa_SIS], [PKIdPAAAS]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[PAAASPartida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_PAAASPartida_FKIdPartida_CONTA_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[PAAASPartida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_PAAASPartida_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[PAAASPartida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_PAAASPartida_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[Partida] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_Partida_FKIdConcepto_SIS_Concepto] FOREIGN KEY ([FKIdConcepto_SIS]) REFERENCES [SIS].[Concepto] ([PKIdConcepto]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[Partida] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_Partida_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[Partida] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_Partida_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Conteo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Conteo_IdEmpresa_FKIdPeriodoConteo_ALMA_PeriodoConteo] FOREIGN KEY ([IdEmpresa], [FKIdPeriodoConteo_ALMA]) REFERENCES [ALMA].[PeriodoConteo] ([IdEmpresa], [PKIdPeriodoConteo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Conteo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Conteo_IdEmpresa_FKIdTipoBien_ALMA_TipoBien] FOREIGN KEY ([IdEmpresa], [FKIdTipoBien_ALMA]) REFERENCES [ALMA].[TipoBien] ([IdEmpresa], [PKIdTipoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Conteo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Conteo_IdEmpresa_UsuarioCreacion_Usuario] FOREIGN KEY ([IdEmpresa], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Conteo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Conteo_IdEmpresa_UsuarioModificacion_Usuario] FOREIGN KEY ([IdEmpresa], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[TipoGasto] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_TipoGasto_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[TipoGasto] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_TipoGasto_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[FN] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_FN_FKIdGF_PRES_GF] FOREIGN KEY ([FKIdGF_PRES]) REFERENCES [PRES].[GF] ([PKIdGF]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[FN] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_FN_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[FN] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_FN_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Familia] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Familia_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Familia] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Familia_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[TipoDoctoPago] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_TipoDoctoPago_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[TipoDoctoPago] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_TipoDoctoPago_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[TipoDetallePoliza] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_TipoDetallePoliza_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[TipoDetallePoliza] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_TipoDetallePoliza_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[TipoCambio] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_TipoCambio_FKIdTipoMoneda_TES_TipoMoneda] FOREIGN KEY ([FKIdTipoMoneda_TES]) REFERENCES [TES].[TipoMoneda] ([PKIdTipoMoneda]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[TipoCambio] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_TipoCambio_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[TipoCambio] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_TipoCambio_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[RequisicionPartida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_RequisicionPartida_FKIdPartida_CONTA_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[RequisicionPartida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_RequisicionPartida_FKIdEmpresa_SIS_FKIdRequisicion_ORCO_Requisicion] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdRequisicion_ORCO]) REFERENCES [ORCO].[Requisicion] ([FKIdEmpresa_SIS], [PKIdRequisicion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[RequisicionPartida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_RequisicionPartida_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[RequisicionPartida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_RequisicionPartida_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[RequisicionPartida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_RequisicionPartida_FKIdEmpresa_SIS_FKIdEgresoAutorizado_PRES_EgresoAutorizado] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdEgresoAutorizado_PRES]) REFERENCES [PRES].[EgresoAutorizado] ([FKIdEmpresa_SIS], [PKIdEgresoAutorizado]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Programa] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Programa_FKIdActividadInstitucional_SIS_ActividadInstitucional] FOREIGN KEY ([FKIdActividadInstitucional_SIS]) REFERENCES [SIS].[ActividadInstitucional] ([PKIdActividadInstitucional]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Programa] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Programa_FKIdAnio_SIS_Anio] FOREIGN KEY ([FKIdAnio_SIS]) REFERENCES [SIS].[Anio] ([PKIdAnio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Programa] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Programa_FKIdEje_PRES_Eje] FOREIGN KEY ([FKIdEje_PRES]) REFERENCES [PRES].[Eje] ([PKIdEje]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Programa] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Programa_FKIdFinalidad_PRES_Finalidad] FOREIGN KEY ([FKIdFinalidad_PRES]) REFERENCES [PRES].[Finalidad] ([PKIdFinalidad]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Programa] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Programa_FKIdFN_PRES_FN] FOREIGN KEY ([FKIdFN_PRES]) REFERENCES [PRES].[FN] ([PKIdFN]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Programa] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Programa_FKIdFuenteFinanciamiento_PRES_FuenteFinanciamiento] FOREIGN KEY ([FKIdFuenteFinanciamiento_PRES]) REFERENCES [PRES].[FuenteFinanciamiento] ([PKIdFuenteFinanciamiento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Programa] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Programa_FKIdGF_PRES_GF] FOREIGN KEY ([FKIdGF_PRES]) REFERENCES [PRES].[GF] ([PKIdGF]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Programa] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Programa_FKIdResultado_PRES_Resultado] FOREIGN KEY ([FKIdResultado_PRES]) REFERENCES [PRES].[Resultado] ([PKIdResultado]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Programa] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Programa_FKIdSector_PRES_Sector] FOREIGN KEY ([FKIdSector_PRES]) REFERENCES [PRES].[Sector] ([PKIdSector]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Programa] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Programa_FKIdSF_PRES_SF] FOREIGN KEY ([FKIdSF_PRES]) REFERENCES [PRES].[SF] ([PKIdSF]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Programa] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Programa_FKIdSubEje_PRES_SubEje] FOREIGN KEY ([FKIdSubEje_PRES]) REFERENCES [PRES].[SubEje] ([PKIdSubEje]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Programa] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Programa_FKIdSubresultado_PRES_Subresultado] FOREIGN KEY ([FKIdSubresultado_PRES]) REFERENCES [PRES].[Subresultado] ([PKIdSubresultado]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Programa] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Programa_FKIdSubSector_PRES_SubSector] FOREIGN KEY ([FKIdSubSector_PRES]) REFERENCES [PRES].[SubSector] ([PKIdSubSector]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Programa] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Programa_FKIdSubSubEje_PRES_SubSubEje] FOREIGN KEY ([FKIdSubSubEje_PRES]) REFERENCES [PRES].[SubSubEje] ([PKIdSubSubEje]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Programa] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Programa_FKIdTipoRecurso_PRES_TipoRecurso] FOREIGN KEY ([FKIdTipoRecurso_PRES]) REFERENCES [PRES].[TipoRecurso] ([PKIdTipoRecurso]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Programa] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Programa_FKIdUR_PRES_UR] FOREIGN KEY ([FKIdUR_PRES]) REFERENCES [PRES].[UR] ([PKIdUR]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Programa] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Programa_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Programa] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Programa_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Programa] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Programa_FKIdVertienteGasto_PRES_VertienteGasto] FOREIGN KEY ([FKIdVertienteGasto_PRES]) REFERENCES [PRES].[VertienteGasto] ([PKIdVertienteGasto]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ConteoDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ConteoDetalle_IdEmpresa_FKIdConteo_ALMA_Conteo] FOREIGN KEY ([IdEmpresa], [FKIdConteo_ALMA]) REFERENCES [ALMA].[Conteo] ([IdEmpresa], [PKIdConteo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ConteoDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ConteoDetalle_IdEmpresa_FKIdPersona_Responsable_ResponsableOperativo] FOREIGN KEY ([IdEmpresa], [FKIdPersona_Responsable]) REFERENCES [SIS].[ResponsableOperativo] ([IdEmpresa], [IdResponsableOperativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ConteoDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ConteoDetalle_IdEmpresa_UsuarioCreacion_Usuario] FOREIGN KEY ([IdEmpresa], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ConteoDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ConteoDetalle_IdEmpresa_UsuarioModificacion_Usuario] FOREIGN KEY ([IdEmpresa], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[ConsecutivoPoliza] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_ConsecutivoPoliza_FK_IdAnio__SIS_Anio] FOREIGN KEY ([FK_IdAnio__SIS]) REFERENCES [SIS].[Anio] ([PKIdAnio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[ConsecutivoPoliza] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_ConsecutivoPoliza_FK_IdTipoPoliza__SIS_TipoPoliza] FOREIGN KEY ([FK_IdTipoPoliza__SIS]) REFERENCES [SIS].[TipoPoliza] ([PKIdTipoPoliza]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ConteoDetalleEscaneo_IdEmpresa_FKIdConteo_ALMA_Conteo] FOREIGN KEY ([IdEmpresa], [FKIdConteo_ALMA]) REFERENCES [ALMA].[Conteo] ([IdEmpresa], [PKIdConteo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ConteoDetalleEscaneo_IdEmpresa_FKIdPersona_Responsable_ResponsableOperativo] FOREIGN KEY ([IdEmpresa], [FKIdPersona_Responsable]) REFERENCES [SIS].[ResponsableOperativo] ([IdEmpresa], [IdResponsableOperativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ConteoDetalleEscaneo_IdEmpresa_FKIdTipoBien_ALMA_TipoBien] FOREIGN KEY ([IdEmpresa], [FKIdTipoBien_ALMA]) REFERENCES [ALMA].[TipoBien] ([IdEmpresa], [PKIdTipoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ConteoDetalleEscaneo_IdEmpresa_UsuarioCreacion_Usuario] FOREIGN KEY ([IdEmpresa], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ConteoDetalleEscaneo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ConteoDetalleEscaneo_IdEmpresa_UsuarioModificacion_Usuario] FOREIGN KEY ([IdEmpresa], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[DocumentoAnotacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_DocumentoAnotacion_IdEmpresa_FkidDocumento_Documento] FOREIGN KEY ([IdEmpresa], [FkidDocumento]) REFERENCES [SIS].[Documento] ([FkidEmpresaSis], [PkidDocumento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[DocumentoAnotacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_DocumentoAnotacion_FkidDocumentoTipoAnotacion_DocumentoTipoAnotacion] FOREIGN KEY ([FkidDocumentoTipoAnotacion]) REFERENCES [SIS].[DocumentoTipoAnotacion] ([PkidDocumentoTipoAnotacion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[FacturaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_FacturaDetalle_FKIdEmpresa_SIS_FKIdContratoDetalle_PRES_ContratoDetalle] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdContratoDetalle_PRES]) REFERENCES [PRES].[ContratoDetalle] ([FKIdEmpresa_SIS], [PKIdContratoDetalle]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[FacturaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_FacturaDetalle_FKIdEmpresa_SIS_FKIdFactura_PRES_Factura] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdFactura_PRES]) REFERENCES [PRES].[Factura] ([FKIdEmpresa_SIS], [PKIdFactura]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[FacturaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_FacturaDetalle_FKIdPartida_CONTA_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[FacturaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_FacturaDetalle_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[FacturaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_FacturaDetalle_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[PP] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_PP_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[PP] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_PP_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[TipoAdquisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_TipoAdquisicion_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[TipoAdquisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_TipoAdquisicion_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[TipoRecurso] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_TipoRecurso_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[TipoRecurso] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_TipoRecurso_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Suficiencia] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Suficiencia_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Suficiencia] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Suficiencia_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[CalendarioInventario] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_CalendarioInventario_FKIdArea_SIS_Area] FOREIGN KEY ([FKIdArea_SIS]) REFERENCES [SIS].[Area] ([PKIdArea]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[PeriodoConteo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_PeriodoConteo_FKIdEstatus_ALMA_EstatusPeriodo] FOREIGN KEY ([FKIdEstatus_ALMA]) REFERENCES [ALMA].[EstatusPeriodo] ([PKIdEstatusPeriodo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[PeriodoConteo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_PeriodoConteo_IdEmpresa_FKIdResponsable_SIS_Usuario] FOREIGN KEY ([IdEmpresa], [FKIdResponsable_SIS]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[PeriodoConteo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_PeriodoConteo_IdEmpresa_FKIdSucursal_SIS_Sucursal] FOREIGN KEY ([IdEmpresa], [FKIdSucursal_SIS]) REFERENCES [SIS].[Sucursal] ([FKIdEmpresa_SIS], [PKIdSucursal]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[PeriodoConteo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_PeriodoConteo_IdEmpresa_FKIdSupervisor_SIS_Usuario] FOREIGN KEY ([IdEmpresa], [FKIdSupervisor_SIS]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[PeriodoConteo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_PeriodoConteo_FKIdTipoConteo_ALMA_TipoConteo] FOREIGN KEY ([FKIdTipoConteo_ALMA]) REFERENCES [ALMA].[TipoConteo] ([PKIdTipoConteo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[PeriodoConteo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_PeriodoConteo_IdEmpresa_UsuarioCreacion_Usuario] FOREIGN KEY ([IdEmpresa], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[PeriodoConteo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_PeriodoConteo_IdEmpresa_UsuarioModificacion_Usuario] FOREIGN KEY ([IdEmpresa], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ResguardoMovimiento] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ResguardoMovimiento_IdEmpresa_FKIdBien_ALMA_Bien] FOREIGN KEY ([IdEmpresa], [FKIdBien_ALMA]) REFERENCES [ALMA].[Bien] ([FKIdEmpresa_SIS], [PKIdBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ResguardoMovimiento] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ResguardoMovimiento_IdEmpresa_FKIdResguardoDestino_ALMA_Resguardo] FOREIGN KEY ([IdEmpresa], [FKIdResguardoDestino_ALMA]) REFERENCES [ALMA].[Resguardo] ([FKIdEmpresa_SIS], [PKIdResguardo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ResguardoMovimiento] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ResguardoMovimiento_IdEmpresa_FKIdResguardoDetalle_ALMA_ResguardoDetalle] FOREIGN KEY ([IdEmpresa], [FKIdResguardoDetalle_ALMA]) REFERENCES [ALMA].[ResguardoDetalle] ([IdEmpresa], [PKIdResguardoDetalle]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ResguardoMovimiento] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ResguardoMovimiento_IdEmpresa_FKIdResguardoOrigen_ALMA_Resguardo] FOREIGN KEY ([IdEmpresa], [FKIdResguardoOrigen_ALMA]) REFERENCES [ALMA].[Resguardo] ([FKIdEmpresa_SIS], [PKIdResguardo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[Concepto] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_Concepto_FKIdCapitulo_CONTA_Capitulo] FOREIGN KEY ([FKIdCapitulo_CONTA]) REFERENCES [CONTA].[Capitulo] ([PKIdCapitulo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[Concepto] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_Concepto_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[Concepto] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_Concepto_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[TipoProveedor] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_TipoProveedor_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[TipoProveedor] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_TipoProveedor_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[ChequePartidas] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_ChequePartidas_FKIdEmpresa_SIS_FKIdCheque_PRES_Cheque] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdCheque_PRES]) REFERENCES [PRES].[Cheque] ([FKIdEmpresa_SIS], [PKIdCheque]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[ChequePartidas] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_ChequePartidas_FKIdEmpresa_SIS_FKIdCLCDetalle_PRES_CLCDetalle] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdCLCDetalle_PRES]) REFERENCES [PRES].[CLCDetalle] ([FKIdEmpresa_SIS], [PKIdCLCDetalle]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[ChequePartidas] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_ChequePartidas_FKIdPartida_CONTA_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[ChequePartidas] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_ChequePartidas_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[ChequePartidas] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_ChequePartidas_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Marca] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Marca_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Marca] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Marca_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Material] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Material_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Material] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Material_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizConversion] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizConversion_FKIdTipoGasto_PRES_TipoGasto] FOREIGN KEY ([FKIdTipoGasto_PRES]) REFERENCES [PRES].[TipoGasto] ([PKIdTipoGasto]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizConversion] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizConversion_FKIdAnio_SIS_Anio] FOREIGN KEY ([FKIdAnio_SIS]) REFERENCES [SIS].[Anio] ([PKIdAnio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizConversion] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizConversion_IdEmpresa_FKIdCuentaContableAprobado_CuentaContable] FOREIGN KEY ([IdEmpresa], [FKIdCuentaContableAprobado]) REFERENCES [CONTA].[CuentaContable] ([FKIdEmpresa_SIS], [PKIdCuentaContable]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizConversion] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizConversion_IdEmpresa_FKIdCuentaContableComprometido_CuentaContable] FOREIGN KEY ([IdEmpresa], [FKIdCuentaContableComprometido]) REFERENCES [CONTA].[CuentaContable] ([FKIdEmpresa_SIS], [PKIdCuentaContable]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizConversion] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizConversion_IdEmpresa_FKIdCuentaContableDevengado_CuentaContable] FOREIGN KEY ([IdEmpresa], [FKIdCuentaContableDevengado]) REFERENCES [CONTA].[CuentaContable] ([FKIdEmpresa_SIS], [PKIdCuentaContable]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizConversion] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizConversion_IdEmpresa_FKIdCuentaContableEjercido_CuentaContable] FOREIGN KEY ([IdEmpresa], [FKIdCuentaContableEjercido]) REFERENCES [CONTA].[CuentaContable] ([FKIdEmpresa_SIS], [PKIdCuentaContable]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizConversion] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizConversion_IdEmpresa_FKIdCuentaContableGasto_CuentaContable] FOREIGN KEY ([IdEmpresa], [FKIdCuentaContableGasto]) REFERENCES [CONTA].[CuentaContable] ([FKIdEmpresa_SIS], [PKIdCuentaContable]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizConversion] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizConversion_IdEmpresa_FKIdCuentaContableModificado_CuentaContable] FOREIGN KEY ([IdEmpresa], [FKIdCuentaContableModificado]) REFERENCES [CONTA].[CuentaContable] ([FKIdEmpresa_SIS], [PKIdCuentaContable]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizConversion] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizConversion_IdEmpresa_FKIdCuentaContablePagado_CuentaContable] FOREIGN KEY ([IdEmpresa], [FKIdCuentaContablePagado]) REFERENCES [CONTA].[CuentaContable] ([FKIdEmpresa_SIS], [PKIdCuentaContable]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizConversion] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizConversion_IdEmpresa_FKIdCuentaContablePorEjercer_CuentaContable] FOREIGN KEY ([IdEmpresa], [FKIdCuentaContablePorEjercer]) REFERENCES [CONTA].[CuentaContable] ([FKIdEmpresa_SIS], [PKIdCuentaContable]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizConversion] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizConversion_FKIdPartida_SIS_Partida] FOREIGN KEY ([FKIdPartida_SIS]) REFERENCES [SIS].[Partida] ([PKIdPartida]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizConversion] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizConversion_FKIdPrograma_PRES_Programa] FOREIGN KEY ([FKIdPrograma_PRES]) REFERENCES [PRES].[Programa] ([PKIdPrograma]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizConversion] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizConversion_IdEmpresa_UsuarioCreacion_Usuario] FOREIGN KEY ([IdEmpresa], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizConversion] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizConversion_IdEmpresa_UsuarioModificacion_Usuario] FOREIGN KEY ([IdEmpresa], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Contrato] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Contrato_FKIdEmpresa_SIS_FKIdAutorizacionSuficiencia_PRES_AutorizacionSuficiencia] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdAutorizacionSuficiencia_PRES]) REFERENCES [PRES].[AutorizacionSuficiencia] ([FKIdEmpresa_SIS], [PKIdAutorizacionSuficiencia]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Contrato] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Contrato_FKIdEmpresa_SIS_FKIdPoliza_CONTA_Poliza] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdPoliza_CONTA]) REFERENCES [CONTA].[Poliza] ([IdEmpresa], [PKIdPoliza]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Contrato] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Contrato_FKIdProveedor_SIS_Proveedor] FOREIGN KEY ([FKIdProveedor_SIS]) REFERENCES [SIS].[Proveedor] ([PKIdProveedor]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Contrato] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Contrato_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Contrato] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Contrato_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[Banco] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_Banco_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[Banco] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_Banco_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[CotizacionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_CotizacionDetalle_IdEmpresa_FKIdCotizacion_ORCO_Cotizacion] FOREIGN KEY ([IdEmpresa], [FKIdCotizacion_ORCO]) REFERENCES [ORCO].[Cotizacion] ([IdEmpresa], [PKIdCotizacion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[CotizacionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_CotizacionDetalle_IdEmpresa_FKIdRequisicionDetalle_ORCO_RequisicionDetalle] FOREIGN KEY ([IdEmpresa], [FKIdRequisicionDetalle_ORCO]) REFERENCES [ORCO].[RequisicionDetalle] ([FKIdEmpresa_SIS], [PKIdRequisicionDetalle]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[CotizacionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_CotizacionDetalle_IdEmpresa_UsuarioCreacion_Usuario] FOREIGN KEY ([IdEmpresa], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[CotizacionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_CotizacionDetalle_IdEmpresa_UsuarioModificacion_Usuario] FOREIGN KEY ([IdEmpresa], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgreAdecuacionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgreAdecuacionDetalle_IdEmpresa_FKIdEgreAdecuacion_PRES_EgreAdecuacion] FOREIGN KEY ([IdEmpresa], [FKIdEgreAdecuacion_PRES]) REFERENCES [PRES].[EgreAdecuacion] ([FKIdEmpresa_SIS], [PKIdEgreAdecuacion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgreAdecuacionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgreAdecuacionDetalle_IdEmpresa_FKIdEgresoAutorizado_PRES_EgresoAutorizado] FOREIGN KEY ([IdEmpresa], [FKIdEgresoAutorizado_PRES]) REFERENCES [PRES].[EgresoAutorizado] ([FKIdEmpresa_SIS], [PKIdEgresoAutorizado]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgreAdecuacionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgreAdecuacionDetalle_FKIdTipoMovimiento_PRES_TipoMovimiento] FOREIGN KEY ([FKIdTipoMovimiento_PRES]) REFERENCES [PRES].[TipoMovimiento] ([PKIdTipoMovimiento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[PAAAS] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_PAAAS_FKIdAnio_SIS_Anio] FOREIGN KEY ([FKIdAnio_SIS]) REFERENCES [SIS].[Anio] ([PKIdAnio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[PAAAS] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_PAAAS_FKIdArea_SIS_Area] FOREIGN KEY ([FKIdArea_SIS]) REFERENCES [SIS].[Area] ([PKIdArea]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[PAAAS] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_PAAAS_FKIdFuenteFinanciamiento_PRES_FuenteFinanciamiento] FOREIGN KEY ([FKIdFuenteFinanciamiento_PRES]) REFERENCES [PRES].[FuenteFinanciamiento] ([PKIdFuenteFinanciamiento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[PAAAS] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_PAAAS_FKIdEmpresa_SIS_FKIdPersona_Responsable_ResponsableOperativo] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdPersona_Responsable]) REFERENCES [SIS].[ResponsableOperativo] ([IdEmpresa], [IdResponsableOperativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[PAAAS] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_PAAAS_FKIdPrograma_PRES_Programa] FOREIGN KEY ([FKIdPrograma_PRES]) REFERENCES [PRES].[Programa] ([PKIdPrograma]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[PAAAS] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_PAAAS_FKIdProyecto_ORCO_Proyecto] FOREIGN KEY ([FKIdProyecto_ORCO]) REFERENCES [ORCO].[Proyecto] ([PKIdProyecto]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[PAAAS] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_PAAAS_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[PAAAS] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_PAAAS_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Almacen] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Almacen_FKIdArea_SIS_Area] FOREIGN KEY ([FKIdArea_SIS]) REFERENCES [SIS].[Area] ([PKIdArea]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Almacen] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Almacen_FKIdMotivoES_ALMA_MotivoES] FOREIGN KEY ([FKIdMotivoES_ALMA]) REFERENCES [ALMA].[MotivoES] ([PKIdMotivoES]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Almacen] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Almacen_FKIdEmpresa_SIS_FKIdTipoBien_ALMA_TipoBien] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdTipoBien_ALMA]) REFERENCES [ALMA].[TipoBien] ([IdEmpresa], [PKIdTipoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Almacen] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Almacen_FKIdAnio_SIS_Anio] FOREIGN KEY ([FKIdAnio_SIS]) REFERENCES [SIS].[Anio] ([PKIdAnio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[FundamentoProcedimiento] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_FundamentoProcedimiento_FKIdNormaJuridicaVersion_SIS_NormaJuridicaVersion] FOREIGN KEY ([FKIdNormaJuridicaVersion_SIS]) REFERENCES [SIS].[NormaJuridicaVersion] ([PKIdNormaJuridicaVersion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgreAdecuacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgreAdecuacion_FKIdAccionAdecuacionMaster_PRES_AccionAdecuacionMaster] FOREIGN KEY ([FKIdAccionAdecuacionMaster_PRES]) REFERENCES [PRES].[AccionAdecuacionMaster] ([PKIdAccionAdecuacionMaster]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgreAdecuacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgreAdecuacion_FKIdEstatusAdecuacion_PRES_EstatusAdecuacion] FOREIGN KEY ([FKIdEstatusAdecuacion_PRES]) REFERENCES [PRES].[EstatusAdecuacion] ([PKIdEstatusAdecuacion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgreAdecuacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgreAdecuacion_FKIdTipoAdecuacion_PRES_TipoAdecuacion] FOREIGN KEY ([FKIdTipoAdecuacion_PRES]) REFERENCES [PRES].[TipoAdecuacion] ([PKIdTipoAdecuacion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[TipoBaja] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_TipoBaja_FKIdEstadoBienDestino_ALMA_EstadoBien] FOREIGN KEY ([FKIdEstadoBienDestino_ALMA]) REFERENCES [ALMA].[EstadoBien] ([PKIdEstadoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[CLC] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_CLC_FKIdEmpresa_SIS_FKIdContrato_PRES_Contrato] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdContrato_PRES]) REFERENCES [PRES].[Contrato] ([FKIdEmpresa_SIS], [PKIdContrato]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[CLC] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_CLC_FKIdEmpresa_SIS_FKIdPoliza_CONTA_Poliza] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdPoliza_CONTA]) REFERENCES [CONTA].[Poliza] ([IdEmpresa], [PKIdPoliza]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[CLC] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_CLC_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[CLC] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_CLC_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[SolicitudSalida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_SolicitudSalida_FKIdAreaEntrega_SIS_Area] FOREIGN KEY ([FKIdAreaEntrega_SIS]) REFERENCES [SIS].[Area] ([PKIdArea]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[SolicitudSalida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_SolicitudSalida_FKIdAnio_SIS_Anio] FOREIGN KEY ([FKIdAnio_SIS]) REFERENCES [SIS].[Anio] ([PKIdAnio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[SolicitudSalida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_SolicitudSalida_FKIdAreaSolicita_SIS_Area] FOREIGN KEY ([FKIdAreaSolicita_SIS]) REFERENCES [SIS].[Area] ([PKIdArea]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[SolicitudSalida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_SolicitudSalida_FKIdEstatusSolicitudSalida_ALMA_EstatusSolicitudSalida] FOREIGN KEY ([FKIdEstatusSolicitudSalida_ALMA]) REFERENCES [ALMA].[EstatusSolicitudSalida] ([PKIdEstatusSolicitudSalida]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[SolicitudSalida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_SolicitudSalida_FKIdEmpresa_SIS_FKIdPoliza_CONTA_Poliza] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdPoliza_CONTA]) REFERENCES [CONTA].[Poliza] ([IdEmpresa], [PKIdPoliza]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[Proveedor] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_Proveedor_FKIdEstado_SIS_Estados] FOREIGN KEY ([FKIdEstado_SIS]) REFERENCES [SIS].[Estados] ([PKIdEstado]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[Proveedor] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_Proveedor_FKIdEstatusProveedor_SIS_EstatusProveedor] FOREIGN KEY ([FKIdEstatusProveedor_SIS]) REFERENCES [SIS].[EstatusProveedor] ([PKIdEstatusProveedor]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[Proveedor] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_Proveedor_FKIdMunicipio_SIS_Municipios] FOREIGN KEY ([FKIdMunicipio_SIS]) REFERENCES [SIS].[Municipios] ([PKIdMunicipio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[Proveedor] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_Proveedor_FKIdPais_SIS_Paises] FOREIGN KEY ([FKIdPais_SIS]) REFERENCES [SIS].[Paises] ([PKIdPais]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[Proveedor] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_Proveedor_FkIdTipoProveedor_SIS_TipoProveedor] FOREIGN KEY ([FkIdTipoProveedor_SIS]) REFERENCES [SIS].[TipoProveedor] ([PkIdTipoProveedor]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[Notificacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_Notificacion_Fk_IdNotificacionTipo_NotificacionTipo] FOREIGN KEY ([Fk_IdNotificacionTipo]) REFERENCES [SIS].[NotificacionTipo] ([Pk_IdNotificacionTipo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_SolicitudSuficienciaDetalle_FKIdPartida_CONTA_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_SolicitudSuficienciaDetalle_FKIdEmpresa_SIS_FKIdRequisicionDetalle_ORCO_RequisicionDetalle] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdRequisicionDetalle_ORCO]) REFERENCES [ORCO].[RequisicionDetalle] ([FKIdEmpresa_SIS], [PKIdRequisicionDetalle]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_SolicitudSuficienciaDetalle_FKIdEmpresa_SIS_FKIdSolicitudSuficiencia_PRES_SolicitudSuficiencia] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdSolicitudSuficiencia_PRES]) REFERENCES [PRES].[SolicitudSuficiencia] ([FKIdEmpresa_SIS], [PKIdSolicitudSuficiencia]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_SolicitudSuficienciaDetalle_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[SolicitudSuficienciaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_SolicitudSuficienciaDetalle_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Unidades] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Unidades_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Unidades] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Unidades_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[CuentaEspecial] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_CuentaEspecial_IdEmpresa_FKIdCuentaContable_CONTA_CuentaContable] FOREIGN KEY ([IdEmpresa], [FKIdCuentaContable_CONTA]) REFERENCES [CONTA].[CuentaContable] ([FKIdEmpresa_SIS], [PKIdCuentaContable]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[TipoContrato] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_TipoContrato_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[TipoContrato] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_TipoContrato_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Cheque] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Cheque_FKIdEmpresa_SIS_FKIdCLC_PRES_CLC] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdCLC_PRES]) REFERENCES [PRES].[CLC] ([FKIdEmpresa_SIS], [PKIdCLC]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Cheque] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Cheque_FKIdEmpresa_SIS_FKIdCuentaBancaria_TES_CuentaBancaria] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdCuentaBancaria_TES]) REFERENCES [TES].[CuentaBancaria] ([FKIdEmpresa_SIS], [PKIdCuentaBancaria]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Cheque] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Cheque_FKIdEmpresa_SIS_FKIdPoliza_CONTA_Poliza] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdPoliza_CONTA]) REFERENCES [CONTA].[Poliza] ([IdEmpresa], [PKIdPoliza]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Cheque] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Cheque_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Cheque] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Cheque_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[DestinoGasto] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_DestinoGasto_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[DestinoGasto] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_DestinoGasto_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Ramo] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Ramo_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Ramo] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Ramo_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[PlanConteoCiclico] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_PlanConteoCiclico_IdEmpresa_FKIdTipoBien_ALMA_TipoBien] FOREIGN KEY ([IdEmpresa], [FKIdTipoBien_ALMA]) REFERENCES [ALMA].[TipoBien] ([IdEmpresa], [PKIdTipoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[PlanConteoCiclico] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_PlanConteoCiclico_FKIdArea_SIS_Area] FOREIGN KEY ([FKIdArea_SIS]) REFERENCES [SIS].[Area] ([PKIdArea]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[IngreAdecuacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_IngreAdecuacion_FKIdAccionAdecuacionMaster_PRES_AccionAdecuacionMaster] FOREIGN KEY ([FKIdAccionAdecuacionMaster_PRES]) REFERENCES [PRES].[AccionAdecuacionMaster] ([PKIdAccionAdecuacionMaster]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[IngreAdecuacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_IngreAdecuacion_FKIdAnio_SIS_Anio] FOREIGN KEY ([FKIdAnio_SIS]) REFERENCES [SIS].[Anio] ([PKIdAnio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[IngreAdecuacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_IngreAdecuacion_FKIdEstatusAdecuacion_PRES_EstatusAdecuacion] FOREIGN KEY ([FKIdEstatusAdecuacion_PRES]) REFERENCES [PRES].[EstatusAdecuacion] ([PKIdEstatusAdecuacion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[IngreAdecuacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_IngreAdecuacion_IdEmpresa_FKIdPoliza_CONTA_Poliza] FOREIGN KEY ([IdEmpresa], [FKIdPoliza_CONTA]) REFERENCES [CONTA].[Poliza] ([IdEmpresa], [PKIdPoliza]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[IngreAdecuacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_IngreAdecuacion_FKIdTipoAdecuacion_PRES_TipoAdecuacion] FOREIGN KEY ([FKIdTipoAdecuacion_PRES]) REFERENCES [PRES].[TipoAdecuacion] ([PKIdTipoAdecuacion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[DocumentoEvento] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_DocumentoEvento_IdEmpresa_FkidDocumento_Documento] FOREIGN KEY ([IdEmpresa], [FkidDocumento]) REFERENCES [SIS].[Documento] ([FkidEmpresaSis], [PkidDocumento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[TipoMoneda] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_TipoMoneda_FKIdPais_SIS_Paises] FOREIGN KEY ([FKIdPais_SIS]) REFERENCES [SIS].[Paises] ([PKIdPais]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[TipoMoneda] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_TipoMoneda_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[TipoMoneda] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_TipoMoneda_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[EstadoBien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_EstadoBien_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[EstadoBien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_EstadoBien_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[RequisicionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_RequisicionDetalle_FKIdEmpresa_SIS_FKIdRequisicion_ORCO_Requisicion] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdRequisicion_ORCO]) REFERENCES [ORCO].[Requisicion] ([FKIdEmpresa_SIS], [PKIdRequisicion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[RequisicionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_RequisicionDetalle_FKIdEmpresa_SIS_FKIdTipoBien_ALMA_TipoBien] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdTipoBien_ALMA]) REFERENCES [ALMA].[TipoBien] ([IdEmpresa], [PKIdTipoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[RequisicionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_RequisicionDetalle_FKIdUnidades_ALMA_Unidades] FOREIGN KEY ([FKIdUnidades_ALMA]) REFERENCES [ALMA].[Unidades] ([PKIdUnidades]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[RequisicionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_RequisicionDetalle_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[RequisicionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_RequisicionDetalle_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[TipoCuenta] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_TipoCuenta_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[TipoCuenta] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_TipoCuenta_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[NormaJuridicaVersion] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_NormaJuridicaVersion_FKIdNormaJuridica_SIS_NormaJuridica] FOREIGN KEY ([FKIdNormaJuridica_SIS]) REFERENCES [SIS].[NormaJuridica] ([PKIdNormaJuridica]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Inventario] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Inventario_FKIdArea_SIS_Area] FOREIGN KEY ([FKIdArea_SIS]) REFERENCES [SIS].[Area] ([PKIdArea]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Inventario] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Inventario_FKIdEmpresa_SIS_FKIdCalendarioInventario_ALMA_CalendarioInventario] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdCalendarioInventario_ALMA]) REFERENCES [ALMA].[CalendarioInventario] ([FKIdEmpresa_SIS], [PKIdCalendarioInventario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Inventario] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Inventario_FKIdEstatusInventario_ALMA_EstatusInventario] FOREIGN KEY ([FKIdEstatusInventario_ALMA]) REFERENCES [ALMA].[EstatusInventario] ([PKIdEstatusInventario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizIngreso] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizIngreso_IdEmpresa_Fk_IdCuentaContableModificado_CuentaContable] FOREIGN KEY ([IdEmpresa], [Fk_IdCuentaContableModificado]) REFERENCES [CONTA].[CuentaContable] ([FKIdEmpresa_SIS], [PKIdCuentaContable]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizIngreso] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizIngreso_IdEmpresa_Fk_IdCuentaContablePorEjercer_CuentaContable] FOREIGN KEY ([IdEmpresa], [Fk_IdCuentaContablePorEjercer]) REFERENCES [CONTA].[CuentaContable] ([FKIdEmpresa_SIS], [PKIdCuentaContable]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizIngreso] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizIngreso_IdEmpresa_Fk_IdCuentaContableRecaudado_CuentaContable] FOREIGN KEY ([IdEmpresa], [Fk_IdCuentaContableRecaudado]) REFERENCES [CONTA].[CuentaContable] ([FKIdEmpresa_SIS], [PKIdCuentaContable]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizIngreso] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizIngreso_Fk_IdOrigen_Origen] FOREIGN KEY ([Fk_IdOrigen]) REFERENCES [PRES].[Origen] ([PKIdOrigen]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizIngreso] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizIngreso_Fk_IdPrograma_Programa] FOREIGN KEY ([Fk_IdPrograma]) REFERENCES [PRES].[Programa] ([PKIdPrograma]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizIngreso] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizIngreso_IdEmpresa_UsuarioCreacion_Usuario] FOREIGN KEY ([IdEmpresa], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizIngreso] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizIngreso_IdEmpresa_UsuarioModificacion_Usuario] FOREIGN KEY ([IdEmpresa], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizIngreso] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizIngreso_FK_IdAnio__SIS_Anio] FOREIGN KEY ([FK_IdAnio__SIS]) REFERENCES [SIS].[Anio] ([PKIdAnio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizIngreso] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizIngreso_IdEmpresa_Fk_IdCuentaContableAutorizado_CuentaContable] FOREIGN KEY ([IdEmpresa], [Fk_IdCuentaContableAutorizado]) REFERENCES [CONTA].[CuentaContable] ([FKIdEmpresa_SIS], [PKIdCuentaContable]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizIngreso] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizIngreso_IdEmpresa_Fk_IdCuentaContableDeposito_CuentaContable] FOREIGN KEY ([IdEmpresa], [Fk_IdCuentaContableDeposito]) REFERENCES [CONTA].[CuentaContable] ([FKIdEmpresa_SIS], [PKIdCuentaContable]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[MatrizIngreso] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_MatrizIngreso_IdEmpresa_Fk_IdCuentaContableDevengado_CuentaContable] FOREIGN KEY ([IdEmpresa], [Fk_IdCuentaContableDevengado]) REFERENCES [CONTA].[CuentaContable] ([FKIdEmpresa_SIS], [PKIdCuentaContable]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ResguardoDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ResguardoDetalle_IdEmpresa_FKIdBien_ALMA_Bien] FOREIGN KEY ([IdEmpresa], [FKIdBien_ALMA]) REFERENCES [ALMA].[Bien] ([FKIdEmpresa_SIS], [PKIdBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ResguardoDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ResguardoDetalle_FKIdEstadoBien_ALMA_EstadoBien] FOREIGN KEY ([FKIdEstadoBien_ALMA]) REFERENCES [ALMA].[EstadoBien] ([PKIdEstadoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[ResguardoDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_ResguardoDetalle_IdEmpresa_FKIdResguardo_ALMA_Resguardo] FOREIGN KEY ([IdEmpresa], [FKIdResguardo_ALMA]) REFERENCES [ALMA].[Resguardo] ([FKIdEmpresa_SIS], [PKIdResguardo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Requisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Requisicion_FKIdAnio_SIS_Anio] FOREIGN KEY ([FKIdAnio_SIS]) REFERENCES [SIS].[Anio] ([PKIdAnio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Requisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Requisicion_FKIdArea_SIS_Area] FOREIGN KEY ([FKIdArea_SIS]) REFERENCES [SIS].[Area] ([PKIdArea]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Requisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Requisicion_FKIdEmpresa_SIS_FKIdAutorizo_Responsable_ResponsableOperativo] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdAutorizo_Responsable]) REFERENCES [SIS].[ResponsableOperativo] ([IdEmpresa], [IdResponsableOperativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Requisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Requisicion_FKIdDestinoGasto_PRES_DestinoGasto] FOREIGN KEY ([FKIdDestinoGasto_PRES]) REFERENCES [PRES].[DestinoGasto] ([PKIdDestinoGasto]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Requisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Requisicion_FKIdDigitoIdentificador_PRES_DigitoIdentificador] FOREIGN KEY ([FKIdDigitoIdentificador_PRES]) REFERENCES [PRES].[DigitoIdentificador] ([PKIdDigitoIdentificador]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Requisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Requisicion_FKIdEmpresa_SIS_FKIdEgresoAutorizado_PRES_EgresoAutorizado] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdEgresoAutorizado_PRES]) REFERENCES [PRES].[EgresoAutorizado] ([FKIdEmpresa_SIS], [PKIdEgresoAutorizado]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Requisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Requisicion_FKIdFuenteFinanciamiento_PRES_FuenteFinanciamiento] FOREIGN KEY ([FKIdFuenteFinanciamiento_PRES]) REFERENCES [PRES].[FuenteFinanciamiento] ([PKIdFuenteFinanciamiento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Requisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Requisicion_FKIdEmpresa_SIS_FKIdJefeAlmacen_Responsable_ResponsableOperativo] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdJefeAlmacen_Responsable]) REFERENCES [SIS].[ResponsableOperativo] ([IdEmpresa], [IdResponsableOperativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Requisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Requisicion_FKIdEmpresa_SIS_FKIdPAutorizo_Responsable_ResponsableOperativo] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdPAutorizo_Responsable]) REFERENCES [SIS].[ResponsableOperativo] ([IdEmpresa], [IdResponsableOperativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Requisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Requisicion_FKIdEmpresa_SIS_FKIdPersona_Responsable_ResponsableOperativo] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdPersona_Responsable]) REFERENCES [SIS].[ResponsableOperativo] ([IdEmpresa], [IdResponsableOperativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Requisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Requisicion_FKIdEmpresa_SIS_FKIdPJefeAlmacen_Responsable_ResponsableOperativo] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdPJefeAlmacen_Responsable]) REFERENCES [SIS].[ResponsableOperativo] ([IdEmpresa], [IdResponsableOperativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Requisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Requisicion_FKIdPrograma_PRES_Programa] FOREIGN KEY ([FKIdPrograma_PRES]) REFERENCES [PRES].[Programa] ([PKIdPrograma]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Requisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Requisicion_FKIdProyecto_ORCO_Proyecto] FOREIGN KEY ([FKIdProyecto_ORCO]) REFERENCES [ORCO].[Proyecto] ([PKIdProyecto]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Requisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Requisicion_FKIdEmpresa_SIS_FKIdPSolicita_Responsable_ResponsableOperativo] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdPSolicita_Responsable]) REFERENCES [SIS].[ResponsableOperativo] ([IdEmpresa], [IdResponsableOperativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Requisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Requisicion_FKIdEmpresa_SIS_FKIdPSuficiencia_Responsable_ResponsableOperativo] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdPSuficiencia_Responsable]) REFERENCES [SIS].[ResponsableOperativo] ([IdEmpresa], [IdResponsableOperativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Requisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Requisicion_FKIdEmpresa_SIS_FKIdPSuperviso_Responsable_ResponsableOperativo] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdPSuperviso_Responsable]) REFERENCES [SIS].[ResponsableOperativo] ([IdEmpresa], [IdResponsableOperativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Requisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Requisicion_FKIdSuficiencia_PRES_Suficiencia] FOREIGN KEY ([FKIdSuficiencia_PRES]) REFERENCES [PRES].[Suficiencia] ([PKIdSuficiencia]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Requisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Requisicion_FKIdEmpresa_SIS_FKIdSuperviso_Responsable_ResponsableOperativo] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdSuperviso_Responsable]) REFERENCES [SIS].[ResponsableOperativo] ([IdEmpresa], [IdResponsableOperativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Requisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Requisicion_FKIdTipoGasto_PRES_TipoGasto] FOREIGN KEY ([FKIdTipoGasto_PRES]) REFERENCES [PRES].[TipoGasto] ([PKIdTipoGasto]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Requisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Requisicion_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Requisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Requisicion_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[Anio] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_Anio_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[Anio] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_Anio_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[GF] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_GF_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[GF] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_GF_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[CuentaContable] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_CuentaContable_FKIdTipoCuenta_CONTA_TipoCuenta] FOREIGN KEY ([FKIdTipoCuenta_CONTA]) REFERENCES [CONTA].[TipoCuenta] ([PKIdTipoCuenta]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[CuentaContable] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_CuentaContable_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[CuentaContable] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_CuentaContable_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[Partida] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_Partida_FKIdConcepto_SIS_Concepto] FOREIGN KEY ([FKIdConcepto_SIS]) REFERENCES [CONTA].[Concepto] ([PKIdConcepto]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[Partida] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_Partida_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[Partida] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_Partida_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[CuentaBancaria] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_CuentaBancaria_FKIdEmpresa_SIS_FKIdBanco_TES_Banco] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdBanco_TES]) REFERENCES [TES].[Banco] ([FKIdEmpresa_SIS], [PKIdBanco]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[CuentaBancaria] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_CuentaBancaria_FKIdEmpresa_SIS_FKIdCuentaContable_SIS_CuentaContable] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdCuentaContable_SIS]) REFERENCES [CONTA].[CuentaContable] ([FKIdEmpresa_SIS], [PKIdCuentaContable]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[CuentaBancaria] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_CuentaBancaria_FKIdTipoMoneda_TES_TipoMoneda] FOREIGN KEY ([FKIdTipoMoneda_TES]) REFERENCES [TES].[TipoMoneda] ([PKIdTipoMoneda]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[CuentaBancaria] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_CuentaBancaria_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [TES].[CuentaBancaria] WITH CHECK ADD CONSTRAINT [FK_EXUX_TES_CuentaBancaria_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Fraccion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Fraccion_FKIdArticulo_ORCO_Articulo] FOREIGN KEY ([FKIdArticulo_ORCO]) REFERENCES [ORCO].[Articulo] ([PKIdArticulo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Fraccion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Fraccion_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Fraccion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Fraccion_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[AutorizacionSuficiencia] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_AutorizacionSuficiencia_FKIdEmpresa_SIS_AutorizadoPor_Responsable_ResponsableOperativo] FOREIGN KEY ([FKIdEmpresa_SIS], [AutorizadoPor_Responsable]) REFERENCES [SIS].[ResponsableOperativo] ([IdEmpresa], [IdResponsableOperativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[AutorizacionSuficiencia] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_AutorizacionSuficiencia_FKIdEmpresa_SIS_FKIdSolicitudSuficiencia_PRES_SolicitudSuficiencia] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdSolicitudSuficiencia_PRES]) REFERENCES [PRES].[SolicitudSuficiencia] ([FKIdEmpresa_SIS], [PKIdSolicitudSuficiencia]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[AutorizacionSuficiencia] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_AutorizacionSuficiencia_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[AutorizacionSuficiencia] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_AutorizacionSuficiencia_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[Municipios] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_Municipios_FKIdEstado_SIS_Estados] FOREIGN KEY ([FKIdEstado_SIS]) REFERENCES [SIS].[Estados] ([PKIdEstado]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[PAAASDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_PAAASDetalle_FKIdEmpresa_SIS_FKIdTipoBien_ALMA_TipoBien] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdTipoBien_ALMA]) REFERENCES [ALMA].[TipoBien] ([IdEmpresa], [PKIdTipoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[PAAASDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_PAAASDetalle_FKIdUnidades_ALMA_Unidades] FOREIGN KEY ([FKIdUnidades_ALMA]) REFERENCES [ALMA].[Unidades] ([PKIdUnidades]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[PAAASDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_PAAASDetalle_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[PAAASDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_PAAASDetalle_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[PAAASDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_PAAASDetalle_FKIdEmpresa_SIS_FKIdPAAASPartida_ORCO_PAAASPartida] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdPAAASPartida_ORCO]) REFERENCES [ORCO].[PAAASPartida] ([FKIdEmpresa_SIS], [PKIdPAAASPartida]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[OrdenCompra] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_OrdenCompra_FKIdEmpresa_SIS_FKIdCotizacion_ORCO_Cotizacion] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdCotizacion_ORCO]) REFERENCES [ORCO].[Cotizacion] ([IdEmpresa], [PKIdCotizacion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[OrdenCompra] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_OrdenCompra_FKIdEstatusOrdenCompra_ORCO_EstatusOrdenCompra] FOREIGN KEY ([FKIdEstatusOrdenCompra_ORCO]) REFERENCES [ORCO].[EstatusOrdenCompra] ([PK_IdEstatusOrdenCompra]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[OrdenCompra] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_OrdenCompra_FKIdEmpresa_SIS_FKIdPoliza_CONTA_Poliza] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdPoliza_CONTA]) REFERENCES [CONTA].[Poliza] ([IdEmpresa], [PKIdPoliza]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[OrdenCompra] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_OrdenCompra_FKIdProveedor_SIS_Proveedor] FOREIGN KEY ([FKIdProveedor_SIS]) REFERENCES [SIS].[Proveedor] ([PKIdProveedor]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[OrdenCompra] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_OrdenCompra_FKIdEmpresa_SIS_FKIdRequisicion_ORCO_Requisicion] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdRequisicion_ORCO]) REFERENCES [ORCO].[Requisicion] ([FKIdEmpresa_SIS], [PKIdRequisicion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bajas] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bajas_FKIdArea_SIS_Area] FOREIGN KEY ([FKIdArea_SIS]) REFERENCES [SIS].[Area] ([PKIdArea]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bajas] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bajas_FKIdEmpresa_SIS_FKIdBien_ALMA_Bien] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdBien_ALMA]) REFERENCES [ALMA].[Bien] ([FKIdEmpresa_SIS], [PKIdBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bajas] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bajas_FKIdEstadoBienAnterior_ALMA_EstadoBien] FOREIGN KEY ([FKIdEstadoBienAnterior_ALMA]) REFERENCES [ALMA].[EstadoBien] ([PKIdEstadoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bajas] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bajas_FKIdEstadoBienDestino_ALMA_EstadoBien] FOREIGN KEY ([FKIdEstadoBienDestino_ALMA]) REFERENCES [ALMA].[EstadoBien] ([PKIdEstadoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bajas] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bajas_FKIdEstatusBaja_ALMA_EstatusBaja] FOREIGN KEY ([FKIdEstatusBaja_ALMA]) REFERENCES [ALMA].[EstatusBaja] ([PKIdEstatusBaja]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bajas] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bajas_FKIdEmpresa_SIS_FKIdPoliza_CONTA_Poliza] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdPoliza_CONTA]) REFERENCES [CONTA].[Poliza] ([IdEmpresa], [PKIdPoliza]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bajas] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bajas_FKIdTipoBaja_ALMA_TipoBaja] FOREIGN KEY ([FKIdTipoBaja_ALMA]) REFERENCES [ALMA].[TipoBaja] ([PKIdTipoBaja]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bajas] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bajas_FKIdAnio_SIS_Anio] FOREIGN KEY ([FKIdAnio_SIS]) REFERENCES [SIS].[Anio] ([PKIdAnio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Resguardo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Resguardo_FKIdArea_SIS_Area] FOREIGN KEY ([FKIdArea_SIS]) REFERENCES [SIS].[Area] ([PKIdArea]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EstudioMercado] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EstudioMercado_FKIdAnio_SIS_Anio] FOREIGN KEY ([FKIdAnio_SIS]) REFERENCES [SIS].[Anio] ([PKIdAnio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EstudioMercado] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EstudioMercado_FKIdEmpresa_SIS_FKIdResponsable_Responsable_ResponsableOperativo] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdResponsable_Responsable]) REFERENCES [SIS].[ResponsableOperativo] ([IdEmpresa], [IdResponsableOperativo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EstudioMercado] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EstudioMercado_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EstudioMercado] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EstudioMercado_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[ContratoDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_ContratoDetalle_FKIdEmpresa_SIS_FKIdAutorizacionSuficienciaDetalle_PRES_AutorizacionSuficienciaDetalle] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdAutorizacionSuficienciaDetalle_PRES]) REFERENCES [PRES].[AutorizacionSuficienciaDetalle] ([FKIdEmpresa_SIS], [PKIdAutorizacionSuficienciaDetalle]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[ContratoDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_ContratoDetalle_FKIdEmpresa_SIS_FKIdContrato_PRES_Contrato] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdContrato_PRES]) REFERENCES [PRES].[Contrato] ([FKIdEmpresa_SIS], [PKIdContrato]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[ContratoDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_ContratoDetalle_FKIdPartida_CONTA_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[ContratoDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_ContratoDetalle_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[ContratoDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_ContratoDetalle_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[RegresoChequeSuficiencia] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_RegresoChequeSuficiencia_FKIdEmpresa_SIS_FKIdCheque_PRES_Cheque] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdCheque_PRES]) REFERENCES [PRES].[Cheque] ([FKIdEmpresa_SIS], [PKIdCheque]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[RegresoChequeSuficiencia] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_RegresoChequeSuficiencia_FKIdEmpresa_SIS_FKIdSolicitudSuficiencia_PRES_SolicitudSuficiencia] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdSolicitudSuficiencia_PRES]) REFERENCES [PRES].[SolicitudSuficiencia] ([FKIdEmpresa_SIS], [PKIdSolicitudSuficiencia]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[RegresoChequeSuficiencia] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_RegresoChequeSuficiencia_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Origen] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Origen_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Origen] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Origen_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[Capitulo] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_Capitulo_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[Capitulo] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_Capitulo_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[PG] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_PG_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[PG] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_PG_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[MotivoES] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_MotivoES_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[MotivoES] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_MotivoES_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[ActividadInstitucional] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_ActividadInstitucional_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[ActividadInstitucional] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_ActividadInstitucional_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[TipoPatrimonio] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_TipoPatrimonio_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[TipoPatrimonio] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_TipoPatrimonio_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Articulo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Articulo_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Articulo] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Articulo_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[RegresoChequeSuficienciaPoliza] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_RegresoChequeSuficienciaPoliza_IdEmpresa_FKIdRegresoChequeSuficiencia_PRES_RegresoChequeSuficiencia] FOREIGN KEY ([IdEmpresa], [FKIdRegresoChequeSuficiencia_PRES]) REFERENCES [PRES].[RegresoChequeSuficiencia] ([FKIdEmpresa_SIS], [PKIdRegresoChequeSuficiencia]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[RegresoChequeSuficienciaPoliza] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_RegresoChequeSuficienciaPoliza_IdEmpresa_FKIdPolizaOriginal_CONTA_Poliza] FOREIGN KEY ([IdEmpresa], [FKIdPolizaOriginal_CONTA]) REFERENCES [CONTA].[Poliza] ([IdEmpresa], [PKIdPoliza]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[RegresoChequeSuficienciaPoliza] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_RegresoChequeSuficienciaPoliza_IdEmpresa_FKIdPolizaReversion_CONTA_Poliza] FOREIGN KEY ([IdEmpresa], [FKIdPolizaReversion_CONTA]) REFERENCES [CONTA].[Poliza] ([IdEmpresa], [PKIdPoliza]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[RegresoChequeSuficienciaPoliza] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_RegresoChequeSuficienciaPoliza_IdEmpresa_UsuarioCreacion_Usuario] FOREIGN KEY ([IdEmpresa], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[PolizaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_PolizaDetalle_IdEmpresa_FKIdCuentaContable_CONTA_CuentaContable] FOREIGN KEY ([IdEmpresa], [FKIdCuentaContable_CONTA]) REFERENCES [CONTA].[CuentaContable] ([FKIdEmpresa_SIS], [PKIdCuentaContable]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[PolizaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_PolizaDetalle_IdEmpresa_FKIdPoliza_CONTA_Poliza] FOREIGN KEY ([IdEmpresa], [FKIdPoliza_CONTA]) REFERENCES [CONTA].[Poliza] ([IdEmpresa], [PKIdPoliza]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[PolizaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_PolizaDetalle_FKIdTipoDetallePoliza_SIS_TipoDetallePoliza] FOREIGN KEY ([FKIdTipoDetallePoliza_SIS]) REFERENCES [SIS].[TipoDetallePoliza] ([PkIdTipoDetallePoliza]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[PolizaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_PolizaDetalle_IdEmpresa_UsuarioCreacion_Usuario] FOREIGN KEY ([IdEmpresa], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[PolizaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_PolizaDetalle_IdEmpresa_UsuarioModificacion_Usuario] FOREIGN KEY ([IdEmpresa], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Nivel] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Nivel_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Nivel] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Nivel_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[Capitulo] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_Capitulo_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [CONTA].[Capitulo] WITH CHECK ADD CONSTRAINT [FK_EXUX_CONTA_Capitulo_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[CLCDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_CLCDetalle_FKIdEmpresa_SIS_FKIdCLC_PRES_CLC] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdCLC_PRES]) REFERENCES [PRES].[CLC] ([FKIdEmpresa_SIS], [PKIdCLC]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[CLCDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_CLCDetalle_FKIdEmpresa_SIS_FKIdContratoDetalle_PRES_ContratoDetalle] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdContratoDetalle_PRES]) REFERENCES [PRES].[ContratoDetalle] ([FKIdEmpresa_SIS], [PKIdContratoDetalle]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[CLCDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_CLCDetalle_FKIdPartida_CONTA_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[CLCDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_CLCDetalle_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[CLCDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_CLCDetalle_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[TipoPoliza] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_TipoPoliza_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[TipoPoliza] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_TipoPoliza_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[TipoBien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_TipoBien_IdEmpresa_FKIdCuentaContable_CONTA_CuentaContable] FOREIGN KEY ([IdEmpresa], [FKIdCuentaContable_CONTA]) REFERENCES [CONTA].[CuentaContable] ([FKIdEmpresa_SIS], [PKIdCuentaContable]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[TipoBien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_TipoBien_FKIdGrupoBien_ALMA_GrupoBien] FOREIGN KEY ([FKIdGrupoBien_ALMA]) REFERENCES [ALMA].[GrupoBien] ([PKIdGrupoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[TipoBien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_TipoBien_FKIdNivel_ALMA_Nivel] FOREIGN KEY ([FKIdNivel_ALMA]) REFERENCES [ALMA].[Nivel] ([PKIdNivel]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[TipoBien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_TipoBien_FKIdPartida_CONTA_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[TipoBien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_TipoBien_FKIdUnidades_ALMA_Unidades] FOREIGN KEY ([FKIdUnidades_ALMA]) REFERENCES [ALMA].[Unidades] ([PKIdUnidades]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[TipoBien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_TipoBien_FKIdUnidades_Equivalente_Unidades] FOREIGN KEY ([FKIdUnidades_Equivalente]) REFERENCES [ALMA].[Unidades] ([PKIdUnidades]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[TipoBien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_TipoBien_IdEmpresa_UsuarioCreacion_Usuario] FOREIGN KEY ([IdEmpresa], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[TipoBien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_TipoBien_IdEmpresa_UsuarioModificacion_Usuario] FOREIGN KEY ([IdEmpresa], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[PY] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_PY_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[PY] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_PY_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[OrdenCompraPartida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_OrdenCompraPartida_FKIdFuenteFinanciamiento_PRES_FuenteFinanciamiento] FOREIGN KEY ([FKIdFuenteFinanciamiento_PRES]) REFERENCES [PRES].[FuenteFinanciamiento] ([PKIdFuenteFinanciamiento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[OrdenCompraPartida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_OrdenCompraPartida_IdEmpresa_FKIdOrdenCompra_ORCO_OrdenCompra] FOREIGN KEY ([IdEmpresa], [FKIdOrdenCompra_ORCO]) REFERENCES [ORCO].[OrdenCompra] ([FKIdEmpresa_SIS], [PKIdOrdenCompra]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[OrdenCompraPartida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_OrdenCompraPartida_FKIdPartida_CONTA_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[SolicitudCotizacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_SolicitudCotizacion_FKIdEmpresa_SIS_FKIdEstudioMercado_ORCO_EstudioMercado] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdEstudioMercado_ORCO]) REFERENCES [ORCO].[EstudioMercado] ([FKIdEmpresa_SIS], [PKIdEstudioMercado]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[SolicitudCotizacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_SolicitudCotizacion_FKIdProveedor_SIS_Proveedor] FOREIGN KEY ([FKIdProveedor_SIS]) REFERENCES [SIS].[Proveedor] ([PKIdProveedor]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[SolicitudCotizacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_SolicitudCotizacion_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[SolicitudCotizacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_SolicitudCotizacion_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Contratos] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Contratos_FKIdEmpresa_SIS_FKIdOrdenCompra_ORCO_OrdenCompra] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdOrdenCompra_ORCO]) REFERENCES [ORCO].[OrdenCompra] ([FKIdEmpresa_SIS], [PKIdOrdenCompra]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Contratos] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Contratos_FKIdArticulo_ORCO_Articulo] FOREIGN KEY ([FKIdArticulo_ORCO]) REFERENCES [ORCO].[Articulo] ([PKIdArticulo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Contratos] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Contratos_FKIdEstatusContrato_ORCO_EstatusContrato] FOREIGN KEY ([FKIdEstatusContrato_ORCO]) REFERENCES [ORCO].[EstatusContrato] ([PKIdEstatusContrato]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Contratos] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Contratos_FKIdFraccion_ORCO_Fraccion] FOREIGN KEY ([FKIdFraccion_ORCO]) REFERENCES [ORCO].[Fraccion] ([PKIdFraccion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Contratos] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Contratos_FKIdFundamentoJuridico_ORCO_FundamentoJuridico] FOREIGN KEY ([FKIdFundamentoJuridico_ORCO]) REFERENCES [ORCO].[FundamentoJuridico] ([PKIdFundamentoJuridico]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Contratos] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Contratos_FKIdModalidad_ORCO_Modalidad] FOREIGN KEY ([FKIdModalidad_ORCO]) REFERENCES [ORCO].[Modalidad] ([PKIdModalidad]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Contratos] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Contratos_FKIdProcedimientoContratacion_ORCO_ProcedimientoContratacion] FOREIGN KEY ([FKIdProcedimientoContratacion_ORCO]) REFERENCES [ORCO].[ProcedimientoContratacion] ([PKIdProcedimientoContratacion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Contratos] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Contratos_FKIdTipoContrato_ORCO_TipoContrato] FOREIGN KEY ([FKIdTipoContrato_ORCO]) REFERENCES [ORCO].[TipoContrato] ([PKIdTipoContrato]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Contratos] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Contratos_FKIdTipoDocumento_ORCO_TipoDocumento] FOREIGN KEY ([FKIdTipoDocumento_ORCO]) REFERENCES [ORCO].[TipoDocumento] ([PKIdTipoDocumento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Contratos] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Contratos_FKIdTipoGarantia_ORCO_TipoGarantia] FOREIGN KEY ([FKIdTipoGarantia_ORCO]) REFERENCES [ORCO].[TipoGarantia] ([PKIdTipoGarantia]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bien_FKIdArea_SIS_Area] FOREIGN KEY ([FKIdArea_SIS]) REFERENCES [SIS].[Area] ([PKIdArea]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bien_FKIdEstadoBien_ALMA_EstadoBien] FOREIGN KEY ([FKIdEstadoBien_ALMA]) REFERENCES [ALMA].[EstadoBien] ([PKIdEstadoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bien_FKIdGrupoBien_ALMA_GrupoBien] FOREIGN KEY ([FKIdGrupoBien_ALMA]) REFERENCES [ALMA].[GrupoBien] ([PKIdGrupoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bien_FKIdMarca_ALMA_Marca] FOREIGN KEY ([FKIdMarca_ALMA]) REFERENCES [ALMA].[Marca] ([PKIdMarca]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bien_FKIdMaterial_ALMA_Material] FOREIGN KEY ([FKIdMaterial_ALMA]) REFERENCES [ALMA].[Material] ([PKIdMaterial]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bien_FKIdPartida_CONTA_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bien_FKIdProveedor_SIS_Proveedor] FOREIGN KEY ([FKIdProveedor_SIS]) REFERENCES [SIS].[Proveedor] ([PKIdProveedor]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bien_FKIdTipoAdq_ALMA_TipoAdquisicion] FOREIGN KEY ([FKIdTipoAdq_ALMA]) REFERENCES [ALMA].[TipoAdquisicion] ([PKIdTipoAdq]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bien_FKIdEmpresa_SIS_FKIdTipoBien_ALMA_TipoBien] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdTipoBien_ALMA]) REFERENCES [ALMA].[TipoBien] ([IdEmpresa], [PKIdTipoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bien_FKIdTipoPatrimonio_ALMA_TipoPatrimonio] FOREIGN KEY ([FKIdTipoPatrimonio_ALMA]) REFERENCES [ALMA].[TipoPatrimonio] ([PKIdTipoPatrimonio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bien_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[Bien] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_Bien_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Proyecto] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Proyecto_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Proyecto] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Proyecto_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Sector] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Sector_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Sector] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Sector_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[EstatusSolicitud] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_EstatusSolicitud_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[EstatusSolicitud] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_EstatusSolicitud_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoAutorizado_FKIdArea_SIS_Area] FOREIGN KEY ([FKIdArea_SIS]) REFERENCES [SIS].[Area] ([PKIdArea]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoAutorizado_FKIdDestinoGasto_PRES_DestinoGasto] FOREIGN KEY ([FKIdDestinoGasto_PRES]) REFERENCES [PRES].[DestinoGasto] ([PKIdDestinoGasto]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoAutorizado_FKIdDigitoIdentificador_PRES_DigitoIdentificador] FOREIGN KEY ([FKIdDigitoIdentificador_PRES]) REFERENCES [PRES].[DigitoIdentificador] ([PKIdDigitoIdentificador]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoAutorizado_FKIdEmpresa_SIS_FKIdEgresoProyectado_PRES_EgresoProyectado] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdEgresoProyectado_PRES]) REFERENCES [PRES].[EgresoProyectado] ([FKIdEmpresa_SIS], [PKIdEgresoProyectado]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoAutorizado_FKIdFuenteFinanciamiento_PRES_FuenteFinanciamiento] FOREIGN KEY ([FKIdFuenteFinanciamiento_PRES]) REFERENCES [PRES].[FuenteFinanciamiento] ([PKIdFuenteFinanciamiento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoAutorizado_FKIdPartida_CONTA_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoAutorizado_FKIdEmpresa_SIS_FKIdPoliza_CONTA_Poliza] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdPoliza_CONTA]) REFERENCES [CONTA].[Poliza] ([IdEmpresa], [PKIdPoliza]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoAutorizado_FKIdPrograma_PRES_Programa] FOREIGN KEY ([FKIdPrograma_PRES]) REFERENCES [PRES].[Programa] ([PKIdPrograma]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoAutorizado_FKIdPY_PRES_PY] FOREIGN KEY ([FKIdPY_PRES]) REFERENCES [PRES].[PY] ([PKIdPY]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoAutorizado_FKIdTipoGasto_PRES_TipoGasto] FOREIGN KEY ([FKIdTipoGasto_PRES]) REFERENCES [PRES].[TipoGasto] ([PKIdTipoGasto]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoAutorizado_FKIdEmpresa_SIS_UsuarioAutorizacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioAutorizacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoAutorizado_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoAutorizado_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[TipoDocumento] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_TipoDocumento_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[TipoDocumento] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_TipoDocumento_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[IngresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_IngresoAutorizado_FKIdDestinoGasto_PRES_DestinoGasto] FOREIGN KEY ([FKIdDestinoGasto_PRES]) REFERENCES [PRES].[DestinoGasto] ([PKIdDestinoGasto]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[IngresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_IngresoAutorizado_FKIdDigitoIdentificador_PRES_DigitoIdentificador] FOREIGN KEY ([FKIdDigitoIdentificador_PRES]) REFERENCES [PRES].[DigitoIdentificador] ([PKIdDigitoIdentificador]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[IngresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_IngresoAutorizado_FKIdFuenteFinanciamiento_PRES_FuenteFinanciamiento] FOREIGN KEY ([FKIdFuenteFinanciamiento_PRES]) REFERENCES [PRES].[FuenteFinanciamiento] ([PKIdFuenteFinanciamiento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[IngresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_IngresoAutorizado_FKIdOrigen_PRES_Origen] FOREIGN KEY ([FKIdOrigen_PRES]) REFERENCES [PRES].[Origen] ([PKIdOrigen]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[IngresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_IngresoAutorizado_IdEmpresa_FKIdPoliza_CONTA_Poliza] FOREIGN KEY ([IdEmpresa], [FKIdPoliza_CONTA]) REFERENCES [CONTA].[Poliza] ([IdEmpresa], [PKIdPoliza]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[IngresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_IngresoAutorizado_FKIdPrograma_PRES_Programa] FOREIGN KEY ([FKIdPrograma_PRES]) REFERENCES [PRES].[Programa] ([PKIdPrograma]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[IngresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_IngresoAutorizado_FKIdTipoGasto_PRES_TipoGasto] FOREIGN KEY ([FKIdTipoGasto_PRES]) REFERENCES [PRES].[TipoGasto] ([PKIdTipoGasto]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[IngresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_IngresoAutorizado_IdEmpresa_UsuarioAutorizacion_Usuario] FOREIGN KEY ([IdEmpresa], [UsuarioAutorizacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[IngresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_IngresoAutorizado_IdEmpresa_UsuarioCreacion_Usuario] FOREIGN KEY ([IdEmpresa], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[IngresoAutorizado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_IngresoAutorizado_IdEmpresa_UsuarioModificacion_Usuario] FOREIGN KEY ([IdEmpresa], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Factura] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Factura_FKIdEmpresa_SIS_FKIdContrato_PRES_Contrato] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdContrato_PRES]) REFERENCES [PRES].[Contrato] ([FKIdEmpresa_SIS], [PKIdContrato]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Factura] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Factura_FKIdEmpresa_SIS_FKIdPoliza_CONTA_Poliza] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdPoliza_CONTA]) REFERENCES [CONTA].[Poliza] ([IdEmpresa], [PKIdPoliza]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Factura] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Factura_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[Factura] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_Factura_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[DigitoIdentificador] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_DigitoIdentificador_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[DigitoIdentificador] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_DigitoIdentificador_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_AutorizacionSuficienciaDetalle_FKIdEmpresa_SIS_FKIdAutorizacionSuficiencia_PRES_AutorizacionSuficiencia] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdAutorizacionSuficiencia_PRES]) REFERENCES [PRES].[AutorizacionSuficiencia] ([FKIdEmpresa_SIS], [PKIdAutorizacionSuficiencia]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_AutorizacionSuficienciaDetalle_FKIdPartida_CONTA_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_AutorizacionSuficienciaDetalle_FKIdEmpresa_SIS_FKIdSolicitudSuficienciaDetalle_PRES_SolicitudSuficienciaDetalle] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdSolicitudSuficienciaDetalle_PRES]) REFERENCES [PRES].[SolicitudSuficienciaDetalle] ([FKIdEmpresa_SIS], [PKIdSolicitudSuficienciaDetalle]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_AutorizacionSuficienciaDetalle_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[AutorizacionSuficienciaDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_AutorizacionSuficienciaDetalle_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[CierreInventario] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_CierreInventario_FKIdAnio_SIS_Anio] FOREIGN KEY ([FKIdAnio_SIS]) REFERENCES [SIS].[Anio] ([PKIdAnio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[CierreInventario] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_CierreInventario_FKIdEmpresa_SIS_FKIdTipoBien_ALMA_TipoBien] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdTipoBien_ALMA]) REFERENCES [ALMA].[TipoBien] ([IdEmpresa], [PKIdTipoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[CierreInventario] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_CierreInventario_FKIdUnidades_ALMA_Unidades] FOREIGN KEY ([FKIdUnidades_ALMA]) REFERENCES [ALMA].[Unidades] ([PKIdUnidades]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[EstatusProveedor] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_EstatusProveedor_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[EstatusProveedor] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_EstatusProveedor_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[Concepto] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_Concepto_FKIdCapitulo_SIS_Capitulo] FOREIGN KEY ([FKIdCapitulo_SIS]) REFERENCES [SIS].[Capitulo] ([PKIdCapitulo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[Concepto] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_Concepto_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[Concepto] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_Concepto_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[IngreAdecuacionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_IngreAdecuacionDetalle_IdEmpresa_FKIdIngreAdecuacion_PRES_IngreAdecuacion] FOREIGN KEY ([IdEmpresa], [FKIdIngreAdecuacion_PRES]) REFERENCES [PRES].[IngreAdecuacion] ([IdEmpresa], [PKIdIngreAdecuacion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[IngreAdecuacionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_IngreAdecuacionDetalle_IdEmpresa_FKIdIngresoAutorizado_PRES_IngresoAutorizado] FOREIGN KEY ([IdEmpresa], [FKIdIngresoAutorizado_PRES]) REFERENCES [PRES].[IngresoAutorizado] ([IdEmpresa], [PKIdIngresoAutorizado]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[IngreAdecuacionDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_IngreAdecuacionDetalle_FKIdTipoMovimiento_PRES_TipoMovimiento] FOREIGN KEY ([FKIdTipoMovimiento_PRES]) REFERENCES [PRES].[TipoMovimiento] ([PKIdTipoMovimiento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Cotizacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Cotizacion_FKIdAnio_SIS_Anio] FOREIGN KEY ([FKIdAnio_SIS]) REFERENCES [SIS].[Anio] ([PKIdAnio]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Cotizacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Cotizacion_FKIdProveedor_SIS_Proveedor] FOREIGN KEY ([FKIdProveedor_SIS]) REFERENCES [SIS].[Proveedor] ([PKIdProveedor]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Cotizacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Cotizacion_IdEmpresa_FKIdRequisicion_ORCO_Requisicion] FOREIGN KEY ([IdEmpresa], [FKIdRequisicion_ORCO]) REFERENCES [ORCO].[Requisicion] ([FKIdEmpresa_SIS], [PKIdRequisicion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Cotizacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Cotizacion_IdEmpresa_UsuarioCreacion_Usuario] FOREIGN KEY ([IdEmpresa], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Cotizacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Cotizacion_IdEmpresa_UsuarioModificacion_Usuario] FOREIGN KEY ([IdEmpresa], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalleCosto] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EstudioMercadoDetalleCosto_FKIdEmpresa_SIS_FKIdEstudioMercadoDetalle_ORCO_EstudioMercadoDetalle] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdEstudioMercadoDetalle_ORCO]) REFERENCES [ORCO].[EstudioMercadoDetalle] ([FKIdEmpresa_SIS], [PKIdEstudioMercadoDetalle]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalleCosto] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EstudioMercadoDetalleCosto_FKIdEmpresa_SIS_FKIdSolicitudCotizacion_ORCO_SolicitudCotizacion] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdSolicitudCotizacion_ORCO]) REFERENCES [ORCO].[SolicitudCotizacion] ([FKIdEmpresa_SIS], [PKIdSolicitudCotizacion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalleCosto] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EstudioMercadoDetalleCosto_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EstudioMercadoDetalleCosto] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EstudioMercadoDetalleCosto_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[TipoGarantia] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_TipoGarantia_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[TipoGarantia] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_TipoGarantia_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[FuenteFinanciamiento] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_FuenteFinanciamiento_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[FuenteFinanciamiento] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_FuenteFinanciamiento_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[InventarioDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_InventarioDetalle_IdEmpresa_FKIdBien_ALMA_Bien] FOREIGN KEY ([IdEmpresa], [FKIdBien_ALMA]) REFERENCES [ALMA].[Bien] ([FKIdEmpresa_SIS], [PKIdBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[InventarioDetalle] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_InventarioDetalle_IdEmpresa_FKIdInventario_ALMA_Inventario] FOREIGN KEY ([IdEmpresa], [FKIdInventario_ALMA]) REFERENCES [ALMA].[Inventario] ([FKIdEmpresa_SIS], [PKIdInventario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[ProveedorCumplimiento] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_ProveedorCumplimiento_FKIdProveedor_ORCO_Proveedor] FOREIGN KEY ([FKIdProveedor_ORCO]) REFERENCES [SIS].[Proveedor] ([PKIdProveedor]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Modalidad] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Modalidad_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[Modalidad] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_Modalidad_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[SolicitudSuficiencia] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_SolicitudSuficiencia_FKIdEmpresa_SIS_FKIdRequisicion_ORCO_Requisicion] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdRequisicion_ORCO]) REFERENCES [ORCO].[Requisicion] ([FKIdEmpresa_SIS], [PKIdRequisicion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[SolicitudSuficiencia] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_SolicitudSuficiencia_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[SolicitudSuficiencia] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_SolicitudSuficiencia_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[CLCFactura] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_CLCFactura_FKIdEmpresa_SIS_FKIdCLC_PRES_CLC] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdCLC_PRES]) REFERENCES [PRES].[CLC] ([FKIdEmpresa_SIS], [PKIdCLC]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[CLCFactura] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_CLCFactura_FKIdEmpresa_SIS_FKIdFactura_PRES_Factura] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdFactura_PRES]) REFERENCES [PRES].[Factura] ([FKIdEmpresa_SIS], [PKIdFactura]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[CLCFactura] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_CLCFactura_FKIdEmpresa_SIS_FKIdFacturaDetalle_PRES_FacturaDetalle] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdFacturaDetalle_PRES]) REFERENCES [PRES].[FacturaDetalle] ([FKIdEmpresa_SIS], [PKIdFacturaDetalle]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[CLCFactura] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_CLCFactura_FKIdEmpresa_SIS_FKIdIngresoAutorizado_PRES_IngresoAutorizado] FOREIGN KEY ([FKIdEmpresa_SIS], [FKIdIngresoAutorizado_PRES]) REFERENCES [PRES].[IngresoAutorizado] ([IdEmpresa], [PKIdIngresoAutorizado]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[CLCFactura] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_CLCFactura_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[CLCFactura] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_CLCFactura_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[SF] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_SF_FKIdFN_PRES_FN] FOREIGN KEY ([FKIdFN_PRES]) REFERENCES [PRES].[FN] ([PKIdFN]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[SF] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_SF_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[SF] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_SF_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EstatusRequisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EstatusRequisicion_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[EstatusRequisicion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_EstatusRequisicion_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoProyectado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoProyectado_FKIdDestinoGasto_PRES_DestinoGasto] FOREIGN KEY ([FKIdDestinoGasto_PRES]) REFERENCES [PRES].[DestinoGasto] ([PKIdDestinoGasto]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoProyectado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoProyectado_FKIdDigitoIdentificador_PRES_DigitoIdentificador] FOREIGN KEY ([FKIdDigitoIdentificador_PRES]) REFERENCES [PRES].[DigitoIdentificador] ([PKIdDigitoIdentificador]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoProyectado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoProyectado_FKIdFuenteFinanciamiento_PRES_FuenteFinanciamiento] FOREIGN KEY ([FKIdFuenteFinanciamiento_PRES]) REFERENCES [PRES].[FuenteFinanciamiento] ([PKIdFuenteFinanciamiento]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoProyectado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoProyectado_FKIdPartida_CONTA_Partida] FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoProyectado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoProyectado_FKIdPrograma_PRES_Programa] FOREIGN KEY ([FKIdPrograma_PRES]) REFERENCES [PRES].[Programa] ([PKIdPrograma]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoProyectado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoProyectado_FKIdPY_PRES_PY] FOREIGN KEY ([FKIdPY_PRES]) REFERENCES [PRES].[PY] ([PKIdPY]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoProyectado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoProyectado_FKIdTipoGasto_PRES_TipoGasto] FOREIGN KEY ([FKIdTipoGasto_PRES]) REFERENCES [PRES].[TipoGasto] ([PKIdTipoGasto]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoProyectado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoProyectado_FKIdEmpresa_SIS_UsuarioCreacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoProyectado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoProyectado_FKIdEmpresa_SIS_UsuarioModificacion_Usuario] FOREIGN KEY ([FKIdEmpresa_SIS], [UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([FKIdEmpresa_SIS], [PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [PRES].[EgresoProyectado] WITH CHECK ADD CONSTRAINT [FK_EXUX_PRES_EgresoProyectado_FKIdArea_SIS_Area] FOREIGN KEY ([FKIdArea_SIS]) REFERENCES [SIS].[Area] ([PKIdArea]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[NotificacionDestino] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_NotificacionDestino_Fk_IdNotificacionEstado_NotificacionEstado] FOREIGN KEY ([Fk_IdNotificacionEstado]) REFERENCES [SIS].[NotificacionEstado] ([Pk_IdNotificacionEstado]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [SIS].[NotificacionDestino] WITH CHECK ADD CONSTRAINT [FK_EXUX_SIS_NotificacionDestino_IdEmpresa_Fk_IdNotificacion_Notificacion] FOREIGN KEY ([IdEmpresa], [Fk_IdNotificacion]) REFERENCES [SIS].[Notificacion] ([IdEmpresa], [Pk_IdNotificacion]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[ProcedimientoContratacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_ProcedimientoContratacion_UsuarioCreacion_Usuario] FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ORCO].[ProcedimientoContratacion] WITH CHECK ADD CONSTRAINT [FK_EXUX_ORCO_ProcedimientoContratacion_UsuarioModificacion_Usuario] FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[DetalleSolicitudSalida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_DetalleSolicitudSalida_IdEmpresa_FKIdAlmacen_ALMA_Almacen] FOREIGN KEY ([IdEmpresa], [FKIdAlmacen_ALMA]) REFERENCES [ALMA].[Almacen] ([FKIdEmpresa_SIS], [PKIdAlmacen]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[DetalleSolicitudSalida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_DetalleSolicitudSalida_IdEmpresa_FKIdSolicitudSalida_ALMA_SolicitudSalida] FOREIGN KEY ([IdEmpresa], [FKIdSolicitudSalida_ALMA]) REFERENCES [ALMA].[SolicitudSalida] ([FKIdEmpresa_SIS], [PKIdSolicitudSalida]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [ALMA].[DetalleSolicitudSalida] WITH CHECK ADD CONSTRAINT [FK_EXUX_ALMA_DetalleSolicitudSalida_IdEmpresa_FKIdTipoBien_ALMA_TipoBien] FOREIGN KEY ([IdEmpresa], [FKIdTipoBien_ALMA]) REFERENCES [ALMA].[TipoBien] ([IdEmpresa], [PKIdTipoBien]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
CREATE VIEW [ALMA].[vExistenciasPorAlmacen]
AS
WITH Mov AS (
 SELECT d.IdEmpresa,d.IdPartidaStock,SUM(d.Cantidad) Existencia,SUM(d.ImporteValoracion) ValorInventario
 FROM ALMA.MovimientoInventarioDetalle d
 JOIN ALMA.MovimientoInventario m ON m.IdMovimientoInventario=d.IdMovimiento AND m.IdEmpresa=d.IdEmpresa
 WHERE m.Estado='APLICADO' GROUP BY d.IdEmpresa,d.IdPartidaStock
), Res AS (
 SELECT IdEmpresa,IdPartidaStock,SUM(Cantidad) Reservado FROM ALMA.ReservaStock
 WHERE Estado='ACTIVA' GROUP BY IdEmpresa,IdPartidaStock
)
SELECT p.IdEmpresa,p.IdAlmacen,p.IdPartidaStock,p.IdProductoAlmacen,p.IdTipoBien,p.IdUbicacion,p.IdLote,p.Condicion,
 ISNULL(m.Existencia,0) Existencia,ISNULL(r.Reservado,0) Reservado,
 ISNULL(m.Existencia,0)-ISNULL(r.Reservado,0) Disponible,ISNULL(m.ValorInventario,0) ValorInventario
FROM ALMA.PartidaStock p LEFT JOIN Mov m ON m.IdEmpresa=p.IdEmpresa AND m.IdPartidaStock=p.IdPartidaStock
LEFT JOIN Res r ON r.IdEmpresa=p.IdEmpresa AND r.IdPartidaStock=p.IdPartidaStock;
GO
CREATE TRIGGER [ALMA].[TR_EXUX_MovimientoInmutable]
ON [ALMA].[MovimientoInventario] AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM deleted WHERE Estado='APLICADO')
  THROW 51100,N'Un movimiento aplicado es inmutable: registrar reversa, no editar ni eliminar.',1;
 IF EXISTS(SELECT 1 FROM inserted i WHERE i.Estado='APLICADO' AND NOT EXISTS(SELECT 1 FROM ALMA.MovimientoInventarioDetalle d WHERE d.IdMovimiento=i.IdMovimientoInventario))
  THROW 51101,N'No se puede aplicar un movimiento sin partidas.',1;
 IF EXISTS(SELECT 1 FROM inserted i JOIN ALMA.MovimientoInventarioDetalle d ON d.IdMovimiento=i.IdMovimientoInventario
   WHERE i.Estado='APLICADO' AND ((i.Tipo IN ('ENTRADA','SALDO_INICIAL') AND d.Cantidad<=0) OR (i.Tipo='SALIDA' AND d.Cantidad>=0)))
  THROW 51102,N'El signo de cantidad no corresponde a la entrada o salida.',1;
 IF EXISTS(SELECT 1 FROM inserted i JOIN ALMA.MovimientoInventario m ON m.IdMovimientoInventario=i.IdMovimientoReversa
   WHERE i.Estado='APLICADO' AND i.Tipo='REVERSA' AND m.Estado<>'APLICADO')
  THROW 51103,N'Solo se puede revertir un movimiento aplicado.',1;
 IF EXISTS(
  SELECT i.IdMovimientoInventario,x.IdPartidaStock FROM inserted i
  CROSS APPLY (
   SELECT d.IdPartidaStock,d.Cantidad,d.ImporteValoracion FROM ALMA.MovimientoInventarioDetalle d WHERE d.IdMovimiento=i.IdMovimientoInventario
   UNION ALL
   SELECT d.IdPartidaStock,d.Cantidad,d.ImporteValoracion FROM ALMA.MovimientoInventarioDetalle d WHERE d.IdMovimiento=i.IdMovimientoReversa
  ) x WHERE i.Estado='APLICADO' AND i.Tipo='REVERSA'
  GROUP BY i.IdMovimientoInventario,x.IdPartidaStock HAVING SUM(x.Cantidad)<>0 OR SUM(x.ImporteValoracion)<>0
 ) THROW 51104,N'La reversa debe compensar cantidades y valoración del original por partida.',1;
 IF EXISTS(SELECT 1 FROM inserted i JOIN ALMA.MovimientoInventarioDetalle d ON d.IdMovimiento=i.IdMovimientoInventario
   WHERE i.Estado='APLICADO' AND i.Tipo='TRANSFERENCIA' AND d.IdTransferenciaDetalle IS NULL)
  THROW 51105,N'Una transferencia necesita origen documental en todas sus partidas.',1;
 IF EXISTS(SELECT i.IdMovimientoInventario,d.IdTransferenciaDetalle FROM inserted i
   JOIN ALMA.MovimientoInventarioDetalle d ON d.IdMovimiento=i.IdMovimientoInventario
   WHERE i.Estado='APLICADO' AND i.Tipo='TRANSFERENCIA'
   GROUP BY i.IdMovimientoInventario,d.IdTransferenciaDetalle HAVING SUM(d.Cantidad)<>0 OR SUM(d.ImporteValoracion)<>0 OR COUNT(DISTINCT d.IdAlmacen)<2)
  THROW 51106,N'La transferencia debe compensar cantidad y valor entre al menos dos almacenes.',1;
END;
GO
CREATE TRIGGER [ALMA].[TR_EXUX_DetalleMovimientoInmutable]
ON [ALMA].[MovimientoInventarioDetalle] AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted i JOIN ALMA.MovimientoInventario m WITH (UPDLOCK,HOLDLOCK) ON m.IdMovimientoInventario=i.IdMovimiento WHERE m.Estado='APLICADO')
 OR EXISTS(SELECT 1 FROM deleted d JOIN ALMA.MovimientoInventario m WITH (UPDLOCK,HOLDLOCK) ON m.IdMovimientoInventario=d.IdMovimiento WHERE m.Estado='APLICADO')
  THROW 51107,N'Las partidas de un movimiento aplicado son inmutables. Use una reversa.',1;
END;
GO
CREATE TRIGGER [CONTA].[TR_EXUX_PolizaAutorizada]
ON [CONTA].[Poliza] AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM deleted WHERE Autorizado=1)
  THROW 51200,N'Una póliza autorizada es inmutable. Registre una póliza de reversa.',1;
 IF EXISTS(SELECT i.PKIdPoliza FROM inserted i LEFT JOIN CONTA.PolizaDetalle d ON d.FKIdPoliza_CONTA=i.PKIdPoliza AND d.Activo=1
   WHERE i.Autorizado=1 GROUP BY i.PKIdPoliza
   HAVING COUNT(d.PKIdPolizaDetalle)<2 OR SUM(ISNULL(d.ImporteDebe,0))<>SUM(ISNULL(d.ImporteHaber,0)) OR SUM(ISNULL(d.ImporteDebe,0))<=0)
  THROW 51201,N'Una póliza autorizada necesita al menos dos partidas, debe y haber iguales y monto positivo.',1;
END;
GO
CREATE TRIGGER [CONTA].[TR_EXUX_PolizaDetalleAutorizada]
ON [CONTA].[PolizaDetalle] AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted i JOIN CONTA.Poliza p WITH (UPDLOCK,HOLDLOCK) ON p.PKIdPoliza=i.FKIdPoliza_CONTA WHERE p.Autorizado=1)
 OR EXISTS(SELECT 1 FROM deleted d JOIN CONTA.Poliza p WITH (UPDLOCK,HOLDLOCK) ON p.PKIdPoliza=d.FKIdPoliza_CONTA WHERE p.Autorizado=1)
  THROW 51202,N'No es posible modificar las partidas de una póliza autorizada.',1;
END;
GO
