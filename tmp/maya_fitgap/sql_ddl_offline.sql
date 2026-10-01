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