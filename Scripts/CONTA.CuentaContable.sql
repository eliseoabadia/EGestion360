USE [GestionEmpresarial];
GO

-- =============================================
-- TABLAS DEL MÓDULO DE CONTABILIDAD
-- =============================================

DROP TABLE IF EXISTS [CONTA].[TipoCuenta];
GO

CREATE TABLE [CONTA].[TipoCuenta] (
    [PKIdTipoCuenta]        INT            IDENTITY(1, 1) NOT NULL,
    [Color]                 NVARCHAR(5)    NOT NULL,
    [Descripcion]           NVARCHAR(25)   NOT NULL,
    [Activo]                BIT            NOT NULL CONSTRAINT DF_TipoCuenta_Activo DEFAULT (1),
    [FechaCreacion]         DATETIME       CONSTRAINT DF_TipoCuenta_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]       INT            NOT NULL,
    [FechaModificacion]     DATETIME       NULL,
    [UsuarioModificacion]   INT            NULL,
    CONSTRAINT PK_TipoCuenta PRIMARY KEY CLUSTERED ([PKIdTipoCuenta])
);
GO

INSERT INTO [CONTA].[TipoCuenta] ([Color], [Descripcion], [UsuarioCreacion], [FechaCreacion], [Activo])
VALUES ('1', 'ACREEDORA', 1, GETDATE(), 1),
       ('2', 'DEUDORA',   1, GETDATE(), 1);
GO

DROP TABLE IF EXISTS [CONTA].[CuentaContable];
GO

CREATE TABLE [CONTA].[CuentaContable] (
    [PKIdCuentaContable]        INT               IDENTITY(1, 1) NOT NULL,
    [FKIdEmpresa_SIS]           INT               NOT NULL,
    [FKIdTipoCuenta_CONTA]      INT               NOT NULL,
    [Cuenta]                    NVARCHAR(5)       NOT NULL,
    [SubCuenta]                 NVARCHAR(5)       NOT NULL,
    [SubSubCuenta]              NVARCHAR(5)       NOT NULL,
    [SubSubSubCuenta]           NVARCHAR(5)       NOT NULL,
    [SubSubSubSubCuenta]        NVARCHAR(5)       NOT NULL,
    [Saldo]                     NUMERIC(18, 2)    NOT NULL,
    [Descripcion]               VARCHAR(250)      NULL,
    [Activo]                    BIT               NOT NULL CONSTRAINT DF_CuentaContable_Activo DEFAULT (1),
    [FechaCreacion]             DATETIME          CONSTRAINT DF_CuentaContable_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]           INT               NOT NULL,
    [FechaModificacion]         DATETIME          NULL,
    [UsuarioModificacion]       INT               NULL,
    [S5]                        NVARCHAR(5)       NULL,
    [S6]                        NVARCHAR(5)       NULL,
    [S7]                        NVARCHAR(5)       NULL,
    [ClaveOrd]                  VARCHAR(50)       NULL,
    [Padre]                     VARCHAR(10)       NULL,
    [Hijo]                      VARCHAR(20)       NULL,
    [NivelCuenta]               INT               NULL,
    [Cta_Coi]                   NVARCHAR(20)      NULL,
    [Desc_Coi]                  NVARCHAR(160)     NULL,
    [TipoCuenta]                NCHAR(1)          NULL,
    [S8]                        NVARCHAR(5)       NULL,
    [S9]                        NVARCHAR(5)       NULL,
    [S10]                       NVARCHAR(5)       NULL,
    [IsCuentaDetalle]           AS (CASE WHEN [TipoCuenta] = 'D' THEN 1 ELSE 0 END),
    CONSTRAINT PK_CuentaContable PRIMARY KEY ([PKIdCuentaContable]),
    CONSTRAINT FK_CuentaContable_Empresa FOREIGN KEY ([FKIdEmpresa_SIS]) REFERENCES [SIS].[Empresa] ([PKIdEmpresa]),
    CONSTRAINT FK_CuentaContable_TipoCuenta FOREIGN KEY ([FKIdTipoCuenta_CONTA]) REFERENCES [CONTA].[TipoCuenta] ([PKIdTipoCuenta])
);
GO

SET IDENTITY_INSERT [CONTA].[CuentaContable] ON;
INSERT INTO [CONTA].[CuentaContable] (
    [PKIdCuentaContable], [FKIdEmpresa_SIS], [FKIdTipoCuenta_CONTA],
    [Cuenta], [SubCuenta], [SubSubCuenta], [SubSubSubCuenta], [SubSubSubSubCuenta],
    [Saldo], [Descripcion], [Activo], [FechaCreacion], [UsuarioCreacion],
    [S5], [S6], [S7], [ClaveOrd], [Padre], [Hijo], [NivelCuenta],
    [Cta_Coi], [Desc_Coi], [TipoCuenta], [S8], [S9], [S10]
)
SELECT
    s.[PK_IdCuentaContable], 1, s.[FK_IdTipoCuenta__SIS],
    s.[Cuenta], s.[SubCuenta], s.[SubSubCuenta], s.[SubSubSubCuenta], s.[SubSubSubSubCuenta],
    s.[Saldo], s.[Descripcion], s.[CT_LIVE], s.[CT_CreatedDate], s.[CT_CreatedBy],
    s.[S5], s.[S6], s.[S7], s.[ClaveOrd], s.[Padre], s.[Hijo], s.[NivelCuenta],
    s.[Cta_Coi], s.[Desc_Coi], s.[TipoCuenta], s.[S8], s.[S9], s.[S10]
FROM [BD_PRESUPUESTO].[SIS].[CuentaContable] s
WHERE s.[FK_IdTipoCuenta__SIS] IN (1, 2);
SET IDENTITY_INSERT [CONTA].[CuentaContable] OFF;
GO

-- =============================================
-- TABLAS DEL MÓDULO DE ALMACÉN (CATÁLOGOS)
-- =============================================

DROP TABLE IF EXISTS [ALMA].[Unidades];
GO

CREATE TABLE [ALMA].[Unidades] (
    [PKIdUnidades]          INT            IDENTITY(1, 1) NOT NULL,
    [Descripcion]           NVARCHAR(50)   NOT NULL,
    [Activo]                BIT            NOT NULL CONSTRAINT DF_Unidades_Activo DEFAULT (1),
    [FechaCreacion]         DATETIME       CONSTRAINT DF_Unidades_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]       INT            NOT NULL,
    [FechaModificacion]     DATETIME       NULL,
    [UsuarioModificacion]   INT            NULL,
    CONSTRAINT PK_Unidades PRIMARY KEY ([PKIdUnidades])
);
GO

INSERT INTO [ALMA].[Unidades] ([Descripcion], [UsuarioCreacion], [FechaCreacion], [Activo])
SELECT [Descripcion], 1, [CT_CreatedDate], 1
FROM [BD_PRESUPUESTO].[alma].[Unidades];
GO

DROP TABLE IF EXISTS [CONTA].[Capitulo];
GO

CREATE TABLE [CONTA].[Capitulo] (
    [PKIdCapitulo]          INT            IDENTITY(1, 1) NOT NULL,
    [Clave]                 NVARCHAR(30)   NULL,
    [Descripcion]           NVARCHAR(120)  NULL,
    [Activo]                BIT            NOT NULL CONSTRAINT DF_Capitulo_Activo DEFAULT (1),
    [FechaCreacion]         DATETIME       CONSTRAINT DF_Capitulo_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]       INT            NOT NULL,
    [FechaModificacion]     DATETIME       NULL,
    [UsuarioModificacion]   INT            NULL,
    CONSTRAINT PK_Capitulo PRIMARY KEY ([PKIdCapitulo])
);
GO

SET IDENTITY_INSERT [CONTA].[Capitulo] ON;
INSERT INTO [CONTA].[Capitulo] (
    [PKIdCapitulo], [Clave], [Descripcion],
    [UsuarioCreacion], [FechaCreacion], [FechaModificacion], [UsuarioModificacion], [Activo]
)
SELECT
    s.[PK_IdCapitulo], s.[Clave], s.[Descripcion],
    ISNULL(s.[CT_CreatedBy], 1), ISNULL(s.[CT_CreatedDate], GETDATE()),
    s.[CT_ModifiedDate], s.[CT_ModifiedBy], ISNULL(s.[CT_LIVE], 1)
FROM [BD_PRESUPUESTO].[SIS].[Capitulo] s
WHERE NOT EXISTS (SELECT 1 FROM [CONTA].[Capitulo] c WHERE c.[PKIdCapitulo] = s.[PK_IdCapitulo]);
SET IDENTITY_INSERT [CONTA].[Capitulo] OFF;
GO

DROP TABLE IF EXISTS [CONTA].[Concepto];
GO

CREATE TABLE [CONTA].[Concepto] (
    [PKIdConcepto]          INT            IDENTITY(1, 1) NOT NULL,
    [FKIdCapitulo_CONTA]    INT            NOT NULL,
    [Clave]                 NVARCHAR(30)   NULL,
    [Descripcion]           NVARCHAR(120)  NULL,
    [Activo]                BIT            NOT NULL CONSTRAINT DF_Concepto_Activo DEFAULT (1),
    [FechaCreacion]         DATETIME       CONSTRAINT DF_Concepto_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]       INT            NOT NULL,
    [FechaModificacion]     DATETIME       NULL,
    [UsuarioModificacion]   INT            NULL,
    CONSTRAINT PK_Concepto PRIMARY KEY ([PKIdConcepto]),
    CONSTRAINT FK_Concepto_Capitulo FOREIGN KEY ([FKIdCapitulo_CONTA]) REFERENCES [CONTA].[Capitulo] ([PKIdCapitulo])
);
GO

SET IDENTITY_INSERT [CONTA].[Concepto] ON;
INSERT INTO [CONTA].[Concepto] (
    [PKIdConcepto], [FKIdCapitulo_CONTA], [Clave], [Descripcion],
    [Activo], [FechaCreacion], [UsuarioCreacion]
)
SELECT
    s.[PK_IdConcepto], s.[FK_IdCapitulo__SIS], s.[Clave], s.[Descripcion],
    s.[CT_LIVE], s.[CT_CreatedDate], s.[CT_CreatedBy]
FROM [BD_PRESUPUESTO].[SIS].[Concepto] s
WHERE NOT EXISTS (SELECT 1 FROM [CONTA].[Concepto] c WHERE c.[PKIdConcepto] = s.[PK_IdConcepto]);
SET IDENTITY_INSERT [CONTA].[Concepto] OFF;
GO

DROP TABLE IF EXISTS [CONTA].[Partida];
GO

CREATE TABLE [CONTA].[Partida] (
    [PKIdPartida]           INT            IDENTITY(1, 1) NOT NULL,
    [FKIdConcepto_SIS]      INT            NULL,
    [Clave]                 NVARCHAR(10)   NOT NULL,
    [Descripcion]           NVARCHAR(255)  NOT NULL,
    [Activo]                BIT            NOT NULL CONSTRAINT DF_Partida_Activo DEFAULT (1),
    [FechaCreacion]         DATETIME       CONSTRAINT DF_Partida_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]       INT            NOT NULL,
    [FechaModificacion]     DATETIME       NULL,
    [UsuarioModificacion]   INT            NULL,
    CONSTRAINT PK_Partida PRIMARY KEY ([PKIdPartida]),
    CONSTRAINT FK_Partida_Concepto FOREIGN KEY ([FKIdConcepto_SIS]) REFERENCES [CONTA].[Concepto] ([PKIdConcepto])
);
GO

SET IDENTITY_INSERT [CONTA].[Partida] ON;
INSERT INTO [CONTA].[Partida] (
    [PKIdPartida], [FKIdConcepto_SIS], [Clave], [Descripcion],
    [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo]
)
SELECT
    s.[PK_IdPartida], s.[FK_IdConcepto__SIS], s.[Clave], s.[Descripcion],
    ISNULL(s.[CT_CreatedBy], 1), ISNULL(s.[CT_CreatedDate], GETDATE()),
    s.[CT_ModifiedBy], s.[CT_ModifiedDate], ISNULL(s.[CT_LIVE], 1)
FROM [BD_PRESUPUESTO].[SIS].[Partida] s
INNER JOIN [CONTA].[Concepto] c ON s.[FK_IdConcepto__SIS] = c.[PKIdConcepto]
LEFT JOIN [CONTA].[Partida] p ON s.[PK_IdPartida] = p.[PKIdPartida]
WHERE p.[PKIdPartida] IS NULL;
SET IDENTITY_INSERT [CONTA].[Partida] OFF;
GO

DROP TABLE IF EXISTS [ALMA].[Nivel];
GO

CREATE TABLE [ALMA].[Nivel] (
    [PKIdNivel]             INT            IDENTITY(1, 1) NOT NULL,
    [Nivel]                 INT            NOT NULL,
    [Descripcion]           NVARCHAR(20)   NOT NULL,
    [Activo]                BIT            NOT NULL CONSTRAINT DF_Nivel_Activo DEFAULT (1),
    [FechaCreacion]         DATETIME       CONSTRAINT DF_Nivel_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]       INT            NOT NULL,
    [FechaModificacion]     DATETIME       NULL,
    [UsuarioModificacion]   INT            NULL,
    CONSTRAINT PK_Nivel PRIMARY KEY ([PKIdNivel])
);
GO

SET IDENTITY_INSERT [ALMA].[Nivel] ON;
INSERT INTO [ALMA].[Nivel] (
    [PKIdNivel], [Nivel], [Descripcion],
    [UsuarioCreacion], [FechaCreacion], [FechaModificacion], [UsuarioModificacion], [Activo]
)
SELECT
    s.[PK_IdNivel], s.[Nivel], s.[Descipcion],
    ISNULL(s.[CT_CreatedBy], 1), ISNULL(s.[CT_CreatedDate], GETDATE()),
    s.[CT_ModifiedDate], s.[CT_ModifiedBy], ISNULL(s.[CT_LIVE], 1)
FROM [BD_PRESUPUESTO].[SICOP].[Nivel] s
WHERE NOT EXISTS (SELECT 1 FROM [ALMA].[Nivel] n WHERE n.[PKIdNivel] = s.[PK_IdNivel]);
SET IDENTITY_INSERT [ALMA].[Nivel] OFF;
GO

DROP TABLE IF EXISTS [ALMA].[Familia];
GO

CREATE TABLE [ALMA].[Familia] (
    [PKIdFamilia]           INT            IDENTITY(1, 1) NOT NULL,
    [Descripcion]           NVARCHAR(80)   NOT NULL,
    [Clave]                 NVARCHAR(50)   NULL,
    [Activo]                BIT            NOT NULL CONSTRAINT DF_Familia_Activo DEFAULT (1),
    [FechaCreacion]         DATETIME       CONSTRAINT DF_Familia_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]       INT            NOT NULL,
    [FechaModificacion]     DATETIME       NULL,
    [UsuarioModificacion]   INT            NULL,
    CONSTRAINT PK_Familia PRIMARY KEY ([PKIdFamilia])
);
GO

SET IDENTITY_INSERT [ALMA].[Familia] ON;
INSERT INTO [ALMA].[Familia] (
    [PKIdFamilia], [Descripcion], [Clave],
    [UsuarioCreacion], [FechaCreacion], [FechaModificacion], [UsuarioModificacion], [Activo]
)
SELECT
    s.[PK_IdFamilia], s.[Descripcion], s.[Clave],
    ISNULL(s.[CT_CreatedBy], 1), ISNULL(s.[CT_CreatedDate], GETDATE()),
    s.[CT_ModifiedDate], s.[CT_ModifiedBy], ISNULL(s.[CT_LIVE], 1)
FROM [BD_PRESUPUESTO].[SICOP].[Familia] s
WHERE NOT EXISTS (SELECT 1 FROM [ALMA].[Familia] f WHERE f.[PKIdFamilia] = s.[PK_IdFamilia]);
SET IDENTITY_INSERT [ALMA].[Familia] OFF;
GO

DROP TABLE IF EXISTS [ALMA].[GrupoBien];
GO

CREATE TABLE [ALMA].[GrupoBien] (
    [PKIdGrupoBien]         INT            IDENTITY(1, 1) NOT NULL,
    [FKIdFamilia_ALMA]      INT            NOT NULL,
    [Descripcion]           NVARCHAR(800)  NULL,
    [Clave]                 INT            NULL,
    [ClaveAN]               NVARCHAR(50)   NULL,
    [CABM_ACT]              NVARCHAR(50)   NULL,
    [CLAVE_CUCOP]           NVARCHAR(50)   NULL,
    [MEDIDA]                NVARCHAR(50)   NULL,
    [Activo]                BIT            NOT NULL CONSTRAINT DF_GrupoBien_Activo DEFAULT (1),
    [FechaCreacion]         DATETIME       CONSTRAINT DF_GrupoBien_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]       INT            NOT NULL,
    [FechaModificacion]     DATETIME       NULL,
    [UsuarioModificacion]   INT            NULL,
    CONSTRAINT PK_GrupoBien PRIMARY KEY ([PKIdGrupoBien]),
    CONSTRAINT FK_GrupoBien_Familia FOREIGN KEY ([FKIdFamilia_ALMA]) REFERENCES [ALMA].[Familia] ([PKIdFamilia])
);
GO

SET IDENTITY_INSERT [ALMA].[GrupoBien] ON;
INSERT INTO [ALMA].[GrupoBien] (
    [PKIdGrupoBien], [FKIdFamilia_ALMA], [Descripcion], [Clave], [ClaveAN], [CABM_ACT], [CLAVE_CUCOP], [MEDIDA],
    [UsuarioCreacion], [FechaCreacion], [FechaModificacion], [UsuarioModificacion], [Activo]
)
SELECT
    s.[PK_IdGrupoBien], s.[FK_IdFamilia__SICOP], s.[Descripcion], s.[Clave], s.[ClaveAN], s.[CABM_ACT], s.[CLAVE_CUCOP], s.[MEDIDA],
    ISNULL(s.[CT_CreatedBy], 1), ISNULL(s.[CT_CreatedDate], GETDATE()),
    s.[CT_ModifiedDate], s.[CT_ModifiedBy], ISNULL(s.[CT_LIVE], 1)
FROM [BD_PRESUPUESTO].[SICOP].[GrupoBien] s
INNER JOIN [ALMA].[Familia] f ON s.[FK_IdFamilia__SICOP] = f.[PKIdFamilia]
WHERE NOT EXISTS (SELECT 1 FROM [ALMA].[GrupoBien] g WHERE g.[PKIdGrupoBien] = s.[PK_IdGrupoBien]);
SET IDENTITY_INSERT [ALMA].[GrupoBien] OFF;
GO

DROP TABLE IF EXISTS [ALMA].[TipoBien];
GO

CREATE TABLE [ALMA].[TipoBien] (
    [PKIdTipoBien]                  INT               IDENTITY(1, 1) NOT NULL,
    [FKIdGrupoBien_ALMA]            INT               NULL,
    [FKIdNivel_ALMA]                INT               NULL,
    [FKIdPartida_CONTA]             INT               NULL,
    [FKIdCuentaContable_CONTA]      INT               NULL,
    [FKIdUnidades_ALMA]             INT               NULL,
    [FKIdLocalizacion_ALMA]         INT               NULL,
    [CodigoClave]                   NVARCHAR(200)     NULL,
    [Descripcion]                   NVARCHAR(1200)    NULL,
    [DepreciacionAnual]             DECIMAL(18, 4)    NULL,
    [Consecutivo]                   INT               NULL,
    [CABMS]                         NVARCHAR(50)      NULL,
    [Identificador]                 NVARCHAR(50)      NULL,
    [ExistenciaMinima]              DECIMAL(18, 4)    NULL,
    [ExistenciaMaxima]              DECIMAL(18, 4)    NULL,
    [TiempoVida]                    INT               NULL,
    [Pk_IdTratadoInt]               INT               NULL,
    [Cuota]                         NUMERIC(8, 2)     NULL,
    [ProveeduriaNac]                BIT               NULL,
    [CatalogoBasico]                BIT               NULL,
    [CUCOP_PLUS]                    VARCHAR(25)       NULL,
    [Activo]                        BIT               NOT NULL CONSTRAINT DF_TipoBien_Activo DEFAULT (1),
    [FechaCreacion]                 DATETIME          CONSTRAINT DF_TipoBien_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]               INT               NOT NULL,
    [FechaModificacion]             DATETIME          NULL,
    [UsuarioModificacion]           INT               NULL,
    [FKIdUnidades_Equivalente]      INT               NULL,
    [Cantidad_Equivalente]          INT               NULL,
    CONSTRAINT PK_TipoBien PRIMARY KEY ([PKIdTipoBien]),
    CONSTRAINT FK_TipoBien_GrupoBien FOREIGN KEY ([FKIdGrupoBien_ALMA]) REFERENCES [ALMA].[GrupoBien] ([PKIdGrupoBien]),
    CONSTRAINT FK_TipoBien_Nivel FOREIGN KEY ([FKIdNivel_ALMA]) REFERENCES [ALMA].[Nivel] ([PKIdNivel]),
    CONSTRAINT FK_TipoBien_Partida FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida]),
    CONSTRAINT FK_TipoBien_CuentaContable FOREIGN KEY ([FKIdCuentaContable_CONTA]) REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable]),
    CONSTRAINT FK_TipoBien_Unidades FOREIGN KEY ([FKIdUnidades_ALMA]) REFERENCES [ALMA].[Unidades] ([PKIdUnidades]),
    CONSTRAINT FK_TipoBien_UnidadesEquivalente FOREIGN KEY ([FKIdUnidades_Equivalente]) REFERENCES [ALMA].[Unidades] ([PKIdUnidades])
);
GO

SET IDENTITY_INSERT [ALMA].[TipoBien] ON;
INSERT INTO [ALMA].[TipoBien] (
    [PKIdTipoBien], [FKIdGrupoBien_ALMA], [FKIdNivel_ALMA], [FKIdPartida_CONTA], [FKIdCuentaContable_CONTA],
    [FKIdUnidades_ALMA], [FKIdLocalizacion_ALMA], [CodigoClave], [Descripcion], [DepreciacionAnual], [Consecutivo],
    [CABMS], [Identificador], [ExistenciaMinima], [ExistenciaMaxima], [TiempoVida], [Pk_IdTratadoInt], [Cuota],
    [ProveeduriaNac], [CatalogoBasico], [CUCOP_PLUS], [FKIdUnidades_Equivalente], [Cantidad_Equivalente],
    [UsuarioCreacion], [FechaCreacion], [FechaModificacion], [UsuarioModificacion], [Activo]
)
SELECT
    s.[PK_IdTipoBien], s.[FK_IdGrupoBien__SICOP], s.[FK_IdNivel__SICOP], s.[FK_IdPartida__SIS], s.[FK_IdCuentaContable__SIS],
    s.[FK_IdUnidades__ALMA], s.[FK_IdLocalizacion__ALMA], s.[CodigoClave], s.[Descripcion], s.[DepreciacionAnual], s.[Consecutivo],
    s.[CABMS], s.[Identificador], s.[ExistenciaMinima], s.[ExistenciaMaxima], s.[TiempoVida], s.[Pk_IdTratadoInt], s.[Cuota],
    s.[ProveeduriaNac], s.[CatalogoBasico], s.[CUCOP_PLUS], s.[FK_IdUnidades_Equivalente], s.[Cantidad_Equivalente],
    ISNULL(s.[CT_CreatedBy], 1), ISNULL(s.[CT_CreatedDate], GETDATE()),
    s.[CT_ModifiedDate], s.[CT_ModifiedBy], ISNULL(s.[CT_LIVE], 1)
FROM [BD_PRESUPUESTO].[SICOP].[TipoBien] s
INNER JOIN [ALMA].[GrupoBien] g ON s.[FK_IdGrupoBien__SICOP] = g.[PKIdGrupoBien]
INNER JOIN [ALMA].[Nivel] n ON s.[FK_IdNivel__SICOP] = n.[PKIdNivel]
INNER JOIN [CONTA].[Partida] p ON s.[FK_IdPartida__SIS] = p.[PKIdPartida]
LEFT JOIN [CONTA].[CuentaContable] c ON s.[FK_IdCuentaContable__SIS] = c.[PKIdCuentaContable]
INNER JOIN [ALMA].[Unidades] u1 ON s.[FK_IdUnidades__ALMA] = u1.[PKIdUnidades]
LEFT JOIN [ALMA].[Unidades] u2 ON s.[FK_IdUnidades_Equivalente] = u2.[PKIdUnidades]
WHERE NOT EXISTS (SELECT 1 FROM [ALMA].[TipoBien] t WHERE t.[PKIdTipoBien] = s.[PK_IdTipoBien]);
SET IDENTITY_INSERT [ALMA].[TipoBien] OFF;
GO

-- =============================================
-- MÓDULO DE CONTEO CÍCLICO
-- =============================================

DROP TABLE IF EXISTS [ALMA].[EstatusPeriodo];
GO

CREATE TABLE [ALMA].[EstatusPeriodo] (
    [PKIdEstatusPeriodo]    INT            IDENTITY(1, 1) NOT NULL,
    [Nombre]                NVARCHAR(30)   NOT NULL,
    [Descripcion]           NVARCHAR(100)  NULL,
    [Activo]                BIT            NOT NULL CONSTRAINT DF_EstatusPeriodo_Activo DEFAULT (1),
    CONSTRAINT PK_EstatusPeriodo PRIMARY KEY ([PKIdEstatusPeriodo]),
    CONSTRAINT UQ_EstatusPeriodo_Nombre UNIQUE ([Nombre])
);
GO

INSERT INTO [ALMA].[EstatusPeriodo] ([Nombre], [Descripcion], [Activo])
VALUES ('Pendiente',   'Periodo de conteo pendiente de iniciar', 1),
       ('En Proceso',  'Periodo de conteo en proceso',           1),
       ('Completado',  'Periodo de conteo completado',           1),
       ('Cerrado',     'Periodo de conteo cerrado',              1);
GO

DROP TABLE IF EXISTS [ALMA].[TipoConteo];
GO

CREATE TABLE [ALMA].[TipoConteo] (
    [PKIdTipoConteo]        INT            IDENTITY(1, 1) NOT NULL,
    [Nombre]                NVARCHAR(30)   NOT NULL,
    [Descripcion]           NVARCHAR(100)  NULL,
    [Activo]                BIT            NOT NULL CONSTRAINT DF_TipoConteo_Activo DEFAULT (1),
    CONSTRAINT PK_TipoConteo PRIMARY KEY ([PKIdTipoConteo])
);
GO

INSERT INTO [ALMA].[TipoConteo] ([Nombre], [Descripcion], [Activo])
VALUES ('Cíclico',   'Conteo cíclico programado',       1),
       ('Anual',     'Conteo anual de inventario',      1),
       ('Auditoría', 'Conteo por auditoría externa',    1),
       ('Aleatorio', 'Conteo aleatorio no programado',  1);
GO

DROP TABLE IF EXISTS [ALMA].[EstatusArticuloConteo];
GO

CREATE TABLE [ALMA].[EstatusArticuloConteo] (
    [PKIdEstatusArticulo]   INT            IDENTITY(1, 1) NOT NULL,
    [Nombre]                NVARCHAR(30)   NOT NULL,
    [Descripcion]           NVARCHAR(100)  NULL,
    [Orden]                 INT            NOT NULL,
    [Color]                 NVARCHAR(8)    NULL,
    [Icono]                 NVARCHAR(30)   NULL,
    [BadgeTexto]            NVARCHAR(50)   NULL,
    [Activo]                BIT            NOT NULL CONSTRAINT DF_EstatusArticuloConteo_Activo DEFAULT (1),
    CONSTRAINT PK_EstatusArticuloConteo PRIMARY KEY ([PKIdEstatusArticulo]),
    CONSTRAINT UQ_EstatusArticuloConteo_Nombre UNIQUE ([Nombre])
);
GO

INSERT INTO [ALMA].[EstatusArticuloConteo] ([Nombre], [Descripcion], [Orden], [Color], [Icono], [BadgeTexto], [Activo])
VALUES ('Pendiente 1er Conteo',  'Artículo pendiente de primer conteo',    1, '#FFA500', 'pending', '1er Conteo', 1),
       ('Pendiente 2do Conteo',  'Artículo pendiente de segundo conteo',   2, '#FF8C00', 'pending', '2do Conteo', 1),
       ('Requiere 3er Conteo',   'Artículo que requiere un tercer conteo', 3, '#FF4500', 'warning', '3er Conteo', 1),
       ('Concluido',             'Artículo con conteo finalizado',         4, '#28A745', 'check',   'Concluido',  1),
       ('En Discrepancia',       'Artículo con diferencias sin resolver',  5, '#DC3545', 'error',   'Discrepancia', 1);
GO

DROP TABLE IF EXISTS [ALMA].[PeriodoConteo];
GO

CREATE TABLE [ALMA].[PeriodoConteo] (
    [PKIdPeriodoConteo]             INT            IDENTITY(1, 1) NOT NULL,
    [FKIdSucursal_SIS]              INT            NOT NULL,
    [FKIdTipoConteo_ALMA]           INT            NOT NULL,
    [FKIdEstatus_ALMA]              INT            NOT NULL,
    [CodigoPeriodo]                 NVARCHAR(20)   NOT NULL,
    [Nombre]                        NVARCHAR(100)  NOT NULL,
    [Descripcion]                   NVARCHAR(500)  NULL,
    [FechaInicio]                   DATE           NOT NULL,
    [FechaFin]                      DATE           NULL,
    [FechaCierre]                   DATETIME       NULL,
    [MaximoConteosPorArticulo]      INT            NOT NULL CONSTRAINT DF_PeriodoConteo_MaxConteos DEFAULT (3),
    [RequiereAprobacionSupervisor]  BIT            NOT NULL CONSTRAINT DF_PeriodoConteo_ReqAprobacion DEFAULT (1),
    [FKIdResponsable_SIS]           INT            NULL,
    [FKIdSupervisor_SIS]            INT            NULL,
    [TotalArticulos]                INT            NULL,
    [ArticulosConcluidos]           INT            NULL,
    [ArticulosConDiferencia]        INT            NULL,
    [Activo]                        BIT            NOT NULL CONSTRAINT DF_PeriodoConteo_Activo DEFAULT (1),
    [FechaCreacion]                 DATETIME       CONSTRAINT DF_PeriodoConteo_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]               INT            NOT NULL,
    [FechaModificacion]             DATETIME       NULL,
    [UsuarioModificacion]           INT            NULL,
    CONSTRAINT PK_PeriodoConteo PRIMARY KEY ([PKIdPeriodoConteo]),
    CONSTRAINT FK_PeriodoConteo_Sucursal FOREIGN KEY ([FKIdSucursal_SIS]) REFERENCES [SIS].[Sucursal] ([PKIdSucursal]),
    CONSTRAINT FK_PeriodoConteo_TipoConteo FOREIGN KEY ([FKIdTipoConteo_ALMA]) REFERENCES [ALMA].[TipoConteo] ([PKIdTipoConteo]),
    CONSTRAINT FK_PeriodoConteo_Estatus FOREIGN KEY ([FKIdEstatus_ALMA]) REFERENCES [ALMA].[EstatusPeriodo] ([PKIdEstatusPeriodo]),
    CONSTRAINT FK_PeriodoConteo_Responsable FOREIGN KEY ([FKIdResponsable_SIS]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]),
    CONSTRAINT FK_PeriodoConteo_Supervisor FOREIGN KEY ([FKIdSupervisor_SIS]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]),
    CONSTRAINT UQ_PeriodoConteo_Codigo UNIQUE ([FKIdSucursal_SIS], [CodigoPeriodo])
);
GO

CREATE INDEX IX_PeriodoConteo_Sucursal ON [ALMA].[PeriodoConteo] ([FKIdSucursal_SIS], [FechaInicio]) WHERE [Activo] = 1;
CREATE INDEX IX_PeriodoConteo_Estatus ON [ALMA].[PeriodoConteo] ([FKIdEstatus_ALMA]) WHERE [Activo] = 1;
GO

-- =============================================
-- OTROS CATÁLOGOS
-- =============================================

DROP TABLE IF EXISTS [ALMA].[TipoPatrimonio];
GO

CREATE TABLE [ALMA].[TipoPatrimonio] (
    [PKIdTipoPatrimonio]    INT            IDENTITY(1, 1) NOT NULL,
    [Descripcion]           NVARCHAR(50)   NOT NULL,
    [Activo]                BIT            NOT NULL CONSTRAINT DF_TipoPatrimonio_Activo DEFAULT (1),
    [FechaCreacion]         DATETIME       CONSTRAINT DF_TipoPatrimonio_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]       INT            NOT NULL,
    [FechaModificacion]     DATETIME       NULL,
    [UsuarioModificacion]   INT            NULL,
    CONSTRAINT PK_TipoPatrimonio PRIMARY KEY ([PKIdTipoPatrimonio])
);
GO

INSERT INTO [ALMA].[TipoPatrimonio] ([Descripcion], [UsuarioCreacion])
VALUES ('BIENES PROPIOS', 1),
       ('ARRENDADOS', 1),
       ('BIENES NO PERTENECIENTES AL INSTITUTO', 1);
GO

DROP TABLE IF EXISTS [SIS].[TipoProveedor];
GO

CREATE TABLE [SIS].[TipoProveedor] (
    [PkIdTipoProveedor]     INT            IDENTITY(1, 1) NOT NULL,
    [Descripcion]           VARCHAR(80)    NOT NULL,
    [Activo]                BIT            NOT NULL CONSTRAINT DF_TipoProveedor_Activo DEFAULT (1),
    [FechaCreacion]         DATETIME       CONSTRAINT DF_TipoProveedor_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]       INT            NOT NULL,
    [FechaModificacion]     DATETIME       NULL,
    [UsuarioModificacion]   INT            NULL,
    CONSTRAINT PK_TipoProveedor PRIMARY KEY ([PkIdTipoProveedor])
);
GO

INSERT INTO [SIS].[TipoProveedor] ([Descripcion], [UsuarioCreacion])
VALUES ('Fabricante', 1),
       ('Distribuidor', 1),
       ('MiPyME', 1);
GO

DROP TABLE IF EXISTS [SIS].[EstatusProveedor];
GO

CREATE TABLE [SIS].[EstatusProveedor] (
    [PKIdEstatusProveedor]  INT            IDENTITY(1, 1) NOT NULL,
    [Descripcion]           NVARCHAR(150)  NOT NULL,
    [Color]                 NVARCHAR(8)    NULL,
    [Activo]                BIT            NOT NULL CONSTRAINT DF_EstatusProveedor_Activo DEFAULT (1),
    [FechaCreacion]         DATETIME       CONSTRAINT DF_EstatusProveedor_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]       INT            NOT NULL,
    [FechaModificacion]     DATETIME       NULL,
    [UsuarioModificacion]   INT            NULL,
    CONSTRAINT PK_EstatusProveedor PRIMARY KEY ([PKIdEstatusProveedor])
);
GO

INSERT INTO [SIS].[EstatusProveedor] ([Descripcion], [Color], [UsuarioCreacion])
VALUES ('Normal',         '#D3D3D3', 1),
       ('Validado',       '#CBE1E8', 1),
       ('Contrato Marco', '#D1B7EA', 1),
       ('Inhabilitado',   '#F59494', 1);
GO

DROP TABLE IF EXISTS [SIS].[Proveedor];
GO

CREATE TABLE [SIS].[Proveedor] (
    [PKIdProveedor]                 INT            IDENTITY(1, 1) NOT NULL,
    [FkIdTipoProveedor_SIS]         INT            NULL,
    [FKIdEstatusProveedor_SIS]      INT            NULL,
    [FKIdCuentaContable_SIS]        INT            NULL,
    [FKIdMunicipio_SIS]             INT            NOT NULL,
    [FKIdEstado_SIS]                INT            NOT NULL,
    [FKIdPais_SIS]                  INT            NOT NULL,
    [FKIdResponsable_SIS]           INT            NULL,
    [FKIdAESector_SIS]              INT            NULL,
    [FKIdAEDivision_SIS]            INT            NULL,
    [FKIdAEGrupo_SIS]               INT            NULL,
    [FKIdAEClase_SIS]               INT            NULL,
    [Nombre]                        NVARCHAR(500)  NOT NULL,
    [RFC]                           NVARCHAR(50)   NULL,
    [Colonia]                       NVARCHAR(50)   NULL,
    [CP]                            NVARCHAR(50)   NULL,
    [Ciudad]                        NVARCHAR(50)   NULL,
    [EMAIL]                         NVARCHAR(50)   NULL,
    [Clave]                         NVARCHAR(10)   NOT NULL,
    [Calle]                         NVARCHAR(50)   NULL,
    [Numero]                        NVARCHAR(10)   NULL,
    [FechaAlta]                     DATETIME       NULL,
    [TelefonoInstitucional]         NVARCHAR(20)   NULL,
    [Notas]                         NVARCHAR(MAX)  NULL,
    [PaginaWeb]                     NVARCHAR(100)  NULL,
    [NumeroInt]                     NVARCHAR(10)   NULL,
    [CURP]                          NVARCHAR(18)   NULL,
    [Activo]                        BIT            NOT NULL CONSTRAINT DF_Proveedor_Activo DEFAULT (1),
    [FechaCreacion]                 DATETIME       CONSTRAINT DF_Proveedor_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]               INT            NOT NULL,
    [FechaModificacion]             DATETIME       NULL,
    [UsuarioModificacion]           INT            NULL,
    CONSTRAINT PK_Proveedor PRIMARY KEY ([PKIdProveedor]),
    CONSTRAINT FK_Proveedor_TipoProveedor FOREIGN KEY ([FkIdTipoProveedor_SIS]) REFERENCES [SIS].[TipoProveedor] ([PkIdTipoProveedor]),
    CONSTRAINT FK_Proveedor_EstatusProveedor FOREIGN KEY ([FKIdEstatusProveedor_SIS]) REFERENCES [SIS].[EstatusProveedor] ([PKIdEstatusProveedor]),
    CONSTRAINT FK_Proveedor_CuentaContable FOREIGN KEY ([FKIdCuentaContable_SIS]) REFERENCES [CONTA].[CuentaContable] ([PKIdCuentaContable]),
    CONSTRAINT FK_Proveedor_Municipio FOREIGN KEY ([FKIdMunicipio_SIS]) REFERENCES [SIS].[Municipios] ([PKIdMunicipio]),
    CONSTRAINT FK_Proveedor_Estado FOREIGN KEY ([FKIdEstado_SIS]) REFERENCES [SIS].[Estados] ([PKIdEstado]),
    CONSTRAINT FK_Proveedor_Pais FOREIGN KEY ([FKIdPais_SIS]) REFERENCES [SIS].[Paises] ([PKIdPais])
);
GO

SET IDENTITY_INSERT [SIS].[Proveedor] ON;
INSERT INTO [SIS].[Proveedor] (
    [PKIdProveedor], [FkIdTipoProveedor_SIS], [FKIdEstatusProveedor_SIS], [FKIdCuentaContable_SIS],
    [FKIdMunicipio_SIS], [FKIdEstado_SIS], [FKIdPais_SIS],
    [Nombre], [RFC], [Colonia], [CP], [Ciudad], [EMAIL], [Clave], [Calle], [Numero],
    [FechaAlta], [TelefonoInstitucional], [Notas], [PaginaWeb], [NumeroInt], [CURP],
    [Activo], [FechaCreacion], [UsuarioCreacion]
)
SELECT
    p.[PK_IdProveedor], p.[Fk_IdTipoProveedor], p.[FK_IdEstatusProveedor], tp2.[PKIdCuentaContable],
    p.[FK_IdMunicipio__SIS], p.[FK_IdEstado__SIS], p.[FK_IdPais__SIS],
    p.[Nombre], p.[RFC], p.[Colonia], p.[CP], p.[Ciudad], p.[EMAIL], p.[Clave], p.[Calle], p.[Numero],
    p.[FechaAlta], p.[TelefonoInstitucional], p.[Notas], p.[PaginaWeb], p.[NumeroInt], p.[CURP],
    p.[CT_LIVE], p.[CT_CreatedDate], p.[CT_CreatedBy]
FROM [BD_PRESUPUESTO].[SIS].[Proveedor] p
INNER JOIN [BD_PRESUPUESTO].[SIS].[CuentaContable] c ON p.[FK_IdCuentaContable__SIS] = c.[PK_IdCuentaContable]
INNER JOIN [GestionEmpresarial].[CONTA].[CuentaContable] tp2 ON c.[Descripcion] = tp2.[Descripcion]
WHERE p.[Fk_IdTipoProveedor] IS NOT NULL
  AND p.[FK_IdEstatusProveedor] IS NOT NULL
  AND p.[FK_IdEstado__SIS] IS NOT NULL
  AND p.[FK_IdPais__SIS] IS NOT NULL
  AND p.[FK_IdMunicipio__SIS] IN (SELECT [PKIdMunicipio] FROM [SIS].[Municipios]);
SET IDENTITY_INSERT [SIS].[Proveedor] OFF;
GO

DROP TABLE IF EXISTS [NOM].[Persona];
GO

CREATE TABLE [NOM].[Persona] (
    [PKIdPersona]                INT            IDENTITY(1, 1) NOT NULL,
    [Clave]                      NVARCHAR(15)   NOT NULL,
    [Nombre]                     NVARCHAR(50)   NOT NULL,
    [Paterno]                    NVARCHAR(50)   NOT NULL,
    [Materno]                    NVARCHAR(50)   NOT NULL,
    [Telefono_particular]        NVARCHAR(15)   NULL,
    [Telefono_movil]             NVARCHAR(15)   NULL,
    [Fecha_de_Inicio]            DATETIME       NOT NULL,
    [Fecha_Fin]                  DATETIME       NULL,
    [RFC]                        NVARCHAR(15)   NOT NULL,
    [Curp]                       NVARCHAR(18)   NOT NULL,
    [FechaNacimiento]            DATETIME       NOT NULL,
    [Sexo]                       NVARCHAR(10)   NULL,
    [ESTADO_CIVIL]               NVARCHAR(20)   NULL,
    [Municipio]                  NVARCHAR(20)   NULL,
    [REG_IMSS]                   NVARCHAR(12)   NULL,
    [NoCartilla]                 NVARCHAR(16)   NULL,
    [NoLicencia]                 NVARCHAR(16)   NULL,
    [NoPasaporte]                NVARCHAR(16)   NULL,
    [NoCredencialElector]        NVARCHAR(32)   NULL,
    [Calle]                      NVARCHAR(40)   NULL,
    [Num_exterior]               NVARCHAR(10)   NULL,
    [Num_interior]               NVARCHAR(10)   NULL,
    [Colonia]                    NVARCHAR(40)   NULL,
    [CP]                         NVARCHAR(6)    NULL,
    [Estado]                     NVARCHAR(30)   NULL,
    [CORREO_ELECTRONICO]         NVARCHAR(250)  NULL,
    [TIPO_CONTRATACION]          NVARCHAR(50)   NULL,
    [PUESTO]                     NVARCHAR(100)  NULL,
    [SUELDO_BASE]                FLOAT          NULL,
    [COMPENSACION_GARANTIZADA]   FLOAT          NULL,
    [BANCO]                      NVARCHAR(100)  NULL,
    [NUMERO_CUENTA]              NVARCHAR(25)   NULL,
    [CLABE]                      NVARCHAR(50)   NULL,
    [Activo]                     BIT            NOT NULL CONSTRAINT DF_Persona_Activo DEFAULT (1),
    [FechaCreacion]              DATETIME       CONSTRAINT DF_Persona_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]            INT            NOT NULL,
    [FechaModificacion]          DATETIME       NULL,
    [UsuarioModificacion]        INT            NULL,
    CONSTRAINT PK_Persona PRIMARY KEY ([PKIdPersona])
);
GO

SET IDENTITY_INSERT [NOM].[Persona] ON;
INSERT INTO [NOM].[Persona] (
    [PKIdPersona], [Clave], [Nombre], [Paterno], [Materno],
    [Telefono_particular], [Telefono_movil], [Fecha_de_Inicio], [Fecha_Fin],
    [RFC], [Curp], [FechaNacimiento], [Sexo], [ESTADO_CIVIL], [Municipio],
    [REG_IMSS], [NoCartilla], [NoLicencia], [NoPasaporte], [NoCredencialElector],
    [Calle], [Num_exterior], [Num_interior], [Colonia], [CP], [Estado],
    [CORREO_ELECTRONICO], [TIPO_CONTRATACION], [PUESTO], [SUELDO_BASE], [COMPENSACION_GARANTIZADA],
    [BANCO], [NUMERO_CUENTA], [CLABE], [Activo], [FechaCreacion], [UsuarioCreacion]
)
SELECT
    [PK_IdPersona], [Clave], [Nombre], [Paterno], [Materno],
    [Telefono_particular], [Telefono_movil], [Fecha_de_Inicio], [Fecha_Fin],
    [RFC], [Curp], [FechaNacimiento], [Sexo], [ESTADO_CIVIL], [Municipio],
    [REG_IMSS], [NoCartilla], [NoLicencia], [NoPasaporte], [NoCredencialElector],
    [Calle], [Num_exterior], [Num_interior], [Colonia], [CP], [Estado],
    [CORREO_ELECTRONICO], [TIPO_CONTRATACION], [PUESTO], [SUELDO_BASE], [COMPENSACION_GARANTIZADA],
    [BANCO], [NUMERO_CUENTA], [CLABE], [CT_LIVE], [CT_CreatedDate], [CT_CreatedBy]
FROM [BD_PRESUPUESTO].[RHCT].[Persona];
SET IDENTITY_INSERT [NOM].[Persona] OFF;
GO

DROP TABLE IF EXISTS [SIS].[Area];
GO

CREATE TABLE [SIS].[Area] (
    [PKIdArea]              INT            IDENTITY(1, 1) NOT NULL,
    [FKIdArea_SIS]          INT            NULL,
    [FKIdAreaDocto_SIS]     INT            NULL,
    [Clave]                 NVARCHAR(15)   NOT NULL,
    [Nombre]                NVARCHAR(200)  NOT NULL,
    [UltimoInv]             DATETIME       NULL,
    [ZonaEconomica]         NVARCHAR(100)  NULL,
    [Direccion]             NVARCHAR(64)   NULL,
    [Colonia]               NVARCHAR(64)   NULL,
    [CP]                    NVARCHAR(5)    NULL,
    [Telefono]              NVARCHAR(32)   NULL,
    [Aprovado]              BIT            NOT NULL CONSTRAINT DF_Area_Aprovado DEFAULT (0),
    [Activo]                BIT            NOT NULL CONSTRAINT DF_Area_Activo DEFAULT (1),
    [FechaCreacion]         DATETIME       CONSTRAINT DF_Area_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]       INT            NOT NULL,
    [FechaModificacion]     DATETIME       NULL,
    [UsuarioModificacion]   INT            NULL,
    CONSTRAINT PK_Area PRIMARY KEY ([PKIdArea]),
    CONSTRAINT FK_Area_Padre FOREIGN KEY ([FKIdArea_SIS]) REFERENCES [SIS].[Area] ([PKIdArea])
);
GO

SET IDENTITY_INSERT [SIS].[Area] ON;
INSERT INTO [SIS].[Area] (
    [PKIdArea], [FKIdArea_SIS], [Clave], [Nombre], [UltimoInv], [ZonaEconomica],
    [Direccion], [Colonia], [CP], [Telefono], [Aprovado], [Activo], [FechaCreacion], [UsuarioCreacion]
)
SELECT
    [PK_IdArea], [FK_IdArea__SIS], [Clave], [Nombre], [UltimoInv], [ZonaEconomica],
    [Direccion], [Colonia], [CP], [Telefono], [Aprovado], [CT_LIVE], [CT_CreatedDate], [CT_CreatedBy]
FROM [BD_PRESUPUESTO].[SIS].[Area];
SET IDENTITY_INSERT [SIS].[Area] OFF;
GO

DROP TABLE IF EXISTS [NOM].[PersonaArea];
GO

CREATE TABLE [NOM].[PersonaArea] (
    [PKIdPersonaArea]       INT            IDENTITY(1, 1) NOT NULL,
    [FKIdPersona_NOM]       INT            NOT NULL,
    [FKIdArea_SIS]          INT            NOT NULL,
    [IsAdscrito]            BIT            NOT NULL,
    [EsSolicitante]         BIT            NULL,
    [EsAutorizador]         BIT            NULL,
    [Activo]                BIT            NOT NULL CONSTRAINT DF_PersonaArea_Activo DEFAULT (1),
    [FechaCreacion]         DATETIME       CONSTRAINT DF_PersonaArea_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]       INT            NOT NULL,
    [FechaModificacion]     DATETIME       NULL,
    [UsuarioModificacion]   INT            NULL,
    CONSTRAINT PK_PersonaArea PRIMARY KEY ([PKIdPersonaArea]),
    CONSTRAINT FK_PersonaArea_Persona FOREIGN KEY ([FKIdPersona_NOM]) REFERENCES [NOM].[Persona] ([PKIdPersona]),
    CONSTRAINT FK_PersonaArea_Area FOREIGN KEY ([FKIdArea_SIS]) REFERENCES [SIS].[Area] ([PKIdArea])
);
GO

SET IDENTITY_INSERT [NOM].[PersonaArea] ON;
INSERT INTO [NOM].[PersonaArea] (
    [PKIdPersonaArea], [FKIdPersona_NOM], [FKIdArea_SIS], [IsAdscrito],
    [EsSolicitante], [EsAutorizador], [Activo], [FechaCreacion], [UsuarioCreacion]
)
SELECT
    [PK_IdPersonaArea], [FK_IdPersona], [FK_IdArea], [IsAdscrito],
    [EsSolicitante], [EsAutorizador], [CT_LIVE], [CT_CreatedDate], [CT_CreatedBy]
FROM [BD_PRESUPUESTO].[RHCT].[PersonaArea];
SET IDENTITY_INSERT [NOM].[PersonaArea] OFF;
GO

DROP TABLE IF EXISTS [ALMA].[Marca];
GO

CREATE TABLE [ALMA].[Marca] (
    [PKIdMarca]             INT            IDENTITY(1, 1) NOT NULL,
    [Descripcion]           NVARCHAR(50)   NOT NULL,
    [Activo]                BIT            NOT NULL CONSTRAINT DF_Marca_Activo DEFAULT (1),
    [FechaCreacion]         DATETIME       CONSTRAINT DF_Marca_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]       INT            NOT NULL,
    [FechaModificacion]     DATETIME       NULL,
    [UsuarioModificacion]   INT            NULL,
    CONSTRAINT PK_Marca PRIMARY KEY ([PKIdMarca])
);
GO

SET IDENTITY_INSERT [ALMA].[Marca] ON;
INSERT INTO [ALMA].[Marca] ([PKIdMarca], [Descripcion], [Activo], [UsuarioCreacion], [FechaCreacion])
SELECT [PK_IdMarca], [Descripcion], [CT_LIVE], [CT_CreatedBy], [CT_CreatedDate]
FROM [BD_PRESUPUESTO].[SICOP].[Marca];
SET IDENTITY_INSERT [ALMA].[Marca] OFF;
GO

DROP TABLE IF EXISTS [ALMA].[EstadoBien];
GO

CREATE TABLE [ALMA].[EstadoBien] (
    [PKIdEstadoBien]        INT            IDENTITY(1, 1) NOT NULL,
    [DESCRIPCION_GENERAL]   NVARCHAR(150)  NOT NULL,
    [DESCRIPCION_ESPECIFICA] NVARCHAR(200) NOT NULL,
    [DESCRIPCION_CORTA]     NVARCHAR(100)  NOT NULL,
    [Activo]                BIT            NOT NULL CONSTRAINT DF_EstadoBien_Activo DEFAULT (1),
    [FechaCreacion]         DATETIME       CONSTRAINT DF_EstadoBien_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]       INT            NOT NULL,
    [FechaModificacion]     DATETIME       NULL,
    [UsuarioModificacion]   INT            NULL,
    CONSTRAINT PK_EstadoBien PRIMARY KEY ([PKIdEstadoBien])
);
GO

SET IDENTITY_INSERT [ALMA].[EstadoBien] ON;
INSERT INTO [ALMA].[EstadoBien] (
    [PKIdEstadoBien], [DESCRIPCION_GENERAL], [DESCRIPCION_ESPECIFICA], [DESCRIPCION_CORTA],
    [Activo], [UsuarioCreacion], [FechaCreacion]
)
SELECT
    [PK_IdEstadoBien], [DESCRIPCION_GENERAL], [DESCRIPCION_ESPECIFICA], [DESCRIPCION_CORTA],
    [CT_LIVE], [CT_CreatedBy], [CT_CreatedDate]
FROM [BD_PRESUPUESTO].[SICOP].[EstadoBien];
SET IDENTITY_INSERT [ALMA].[EstadoBien] OFF;
GO

DROP TABLE IF EXISTS [ALMA].[Material];
GO

CREATE TABLE [ALMA].[Material] (
    [PKIdMaterial]          INT            IDENTITY(1, 1) NOT NULL,
    [Descripcion]           NVARCHAR(50)   NOT NULL,
    [Activo]                BIT            NOT NULL CONSTRAINT DF_Material_Activo DEFAULT (1),
    [FechaCreacion]         DATETIME       CONSTRAINT DF_Material_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]       INT            NOT NULL,
    [FechaModificacion]     DATETIME       NULL,
    [UsuarioModificacion]   INT            NULL,
    CONSTRAINT PK_Material PRIMARY KEY ([PKIdMaterial])
);
GO

SET IDENTITY_INSERT [ALMA].[Material] ON;
INSERT INTO [ALMA].[Material] ([PKIdMaterial], [Descripcion], [Activo], [UsuarioCreacion], [FechaCreacion])
SELECT [PK_IdMaterial], [Descripcion], [CT_LIVE], [CT_CreatedBy], [CT_CreatedDate]
FROM [BD_PRESUPUESTO].[SICOP].[Material];
SET IDENTITY_INSERT [ALMA].[Material] OFF;
GO

DROP TABLE IF EXISTS [ALMA].[TipoAdquisicion];
GO

CREATE TABLE [ALMA].[TipoAdquisicion] (
    [PKIdTipoAdq]           INT            IDENTITY(1, 1) NOT NULL,
    [Clave]                 NVARCHAR(10)   NOT NULL,
    [Descripcion]           NVARCHAR(100)  NOT NULL,
    [Descripmovto]          NVARCHAR(100)  NOT NULL,
    [Activo]                BIT            NOT NULL CONSTRAINT DF_TipoAdquisicion_Activo DEFAULT (1),
    [FechaCreacion]         DATETIME       CONSTRAINT DF_TipoAdquisicion_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]       INT            NOT NULL,
    [FechaModificacion]     DATETIME       NULL,
    [UsuarioModificacion]   INT            NULL,
    CONSTRAINT PK_TipoAdquisicion PRIMARY KEY ([PKIdTipoAdq])
);
GO

SET IDENTITY_INSERT [ALMA].[TipoAdquisicion] ON;
INSERT INTO [ALMA].[TipoAdquisicion] (
    [PKIdTipoAdq], [Clave], [Descripcion], [Descripmovto], [Activo], [UsuarioCreacion], [FechaCreacion]
)
SELECT
    [PK_IdTipoAdq], [Clave], [Descripcion], [Descripmovto], [CT_LIVE], [CT_CreatedBy], [CT_CreatedDate]
FROM [BD_PRESUPUESTO].[SICOP].[TipoAdq];
SET IDENTITY_INSERT [ALMA].[TipoAdquisicion] OFF;
GO

DROP TABLE IF EXISTS [ALMA].[Bien];
GO

CREATE TABLE [ALMA].[Bien] (
    [PKIdBien]                      INT               IDENTITY(1, 1) NOT NULL,
    [FKIdGrupoBien_ALMA]            INT               NULL,
    [FKIdTipoBien_ALMA]             INT               NOT NULL,
    [FKIdArea_SIS]                  INT               NULL,
    [FKIdProveedor_SIS]             INT               NULL,
    [FKIdEstadoBien_ALMA]           INT               NULL,
    [FKIdTipoPatrimonio_ALMA]       INT               NULL,
    [FKIdMarca_ALMA]                INT               NULL,
    [FKIdMaterial_ALMA]             INT               NULL,
    [FKIdTipoAdq_ALMA]              INT               NULL,
    [FKIdPartida_CONTA]             INT               NULL,
    [FKIdDetalleOrdenCompra_ORCO]   INT               NULL,
    [Clave]                         NVARCHAR(50)      NULL,
    [ClaveAnt]                      NVARCHAR(50)      NULL,
    [Descripcion]                   NVARCHAR(1000)    NULL,
    [Modelo]                        NVARCHAR(50)      NULL,
    [Serie]                         NVARCHAR(1000)    NULL,
    [Requisicion]                   NVARCHAR(25)      NULL,
    [Factura]                       NVARCHAR(50)      NULL,
    [Costo]                         [dbo].[dmoney]    NULL,
    [FechaAdq]                      DATETIME          NULL,
    [Referencia]                    NVARCHAR(50)      NULL,
    [Notas]                         NVARCHAR(250)     NULL,
    [Ubicacion]                     NVARCHAR(50)      NULL,
    [AAdquisicion]                  NVARCHAR(2)       NULL,
    [Frente]                        INT               NULL,
    [Fondo]                         INT               NULL,
    [Altura]                        INT               NULL,
    [Diametro]                      INT               NULL,
    [VerificacionesDias]            INT               NOT NULL,
    [MantenimientoDias]             INT               NOT NULL,
    [Mantenimiento]                 BIT               NOT NULL,
    [Calibracion]                   BIT               NOT NULL,
    [Rango]                         NVARCHAR(20)      NULL,
    [Resolucion]                    NVARCHAR(20)      NULL,
    [FechaUltInv]                   DATETIME          NULL,
    [FechaReqscn]                   DATETIME          NULL,
    [Estatus]                       NVARCHAR(1)       NULL,
    [Caracteristicas]               NVARCHAR(50)      NULL,
    [Resguardo]                     INT               NULL,
    [ResguardoAnterior]             INT               NULL,
    [RelId]                         INT               NULL,
    [ValorRescate]                  [dbo].[dmoney]    NULL,
    [ValorActual]                   [dbo].[dmoney]    NULL,
    [Antiguedad]                    INT               NULL,
    [Progresivo]                    INT               NULL,
    [Consecutivo]                   INT               NULL,
    [ClaveHist]                     NVARCHAR(50)      NULL,
    [EstaResguardado]               BIT               NULL,
    [FechaResguardado]              DATETIME          NULL,
    [Localizado]                    BIT               NULL,
    [esContabilizado]               BIT               NULL,
    [Activo]                        BIT               NOT NULL CONSTRAINT DF_Bien_Activo DEFAULT (1),
    [FechaCreacion]                 DATETIME          CONSTRAINT DF_Bien_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]               INT               NOT NULL,
    [FechaModificacion]             DATETIME          NULL,
    [UsuarioModificacion]           INT               NULL,
    CONSTRAINT PK_Bien PRIMARY KEY ([PKIdBien]),
    CONSTRAINT FK_Bien_GrupoBien FOREIGN KEY ([FKIdGrupoBien_ALMA]) REFERENCES [ALMA].[GrupoBien] ([PKIdGrupoBien]),
    CONSTRAINT FK_Bien_TipoBien FOREIGN KEY ([FKIdTipoBien_ALMA]) REFERENCES [ALMA].[TipoBien] ([PKIdTipoBien]),
    CONSTRAINT FK_Bien_Area FOREIGN KEY ([FKIdArea_SIS]) REFERENCES [SIS].[Area] ([PKIdArea]),
    CONSTRAINT FK_Bien_Proveedor FOREIGN KEY ([FKIdProveedor_SIS]) REFERENCES [SIS].[Proveedor] ([PKIdProveedor]),
    CONSTRAINT FK_Bien_EstadoBien FOREIGN KEY ([FKIdEstadoBien_ALMA]) REFERENCES [ALMA].[EstadoBien] ([PKIdEstadoBien]),
    CONSTRAINT FK_Bien_TipoPatrimonio FOREIGN KEY ([FKIdTipoPatrimonio_ALMA]) REFERENCES [ALMA].[TipoPatrimonio] ([PKIdTipoPatrimonio]),
    CONSTRAINT FK_Bien_Marca FOREIGN KEY ([FKIdMarca_ALMA]) REFERENCES [ALMA].[Marca] ([PKIdMarca]),
    CONSTRAINT FK_Bien_Material FOREIGN KEY ([FKIdMaterial_ALMA]) REFERENCES [ALMA].[Material] ([PKIdMaterial]),
    CONSTRAINT FK_Bien_TipoAdquisicion FOREIGN KEY ([FKIdTipoAdq_ALMA]) REFERENCES [ALMA].[TipoAdquisicion] ([PKIdTipoAdq]),
    CONSTRAINT FK_Bien_Partida FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida] ([PKIdPartida])
);
GO

SET IDENTITY_INSERT [ALMA].[Bien] ON;
INSERT INTO [ALMA].[Bien] (
    [PKIdBien], [FKIdGrupoBien_ALMA], [FKIdTipoBien_ALMA], [FKIdArea_SIS], [FKIdProveedor_SIS],
    [FKIdEstadoBien_ALMA], [FKIdTipoPatrimonio_ALMA], [FKIdMarca_ALMA], [FKIdMaterial_ALMA],
    [FKIdTipoAdq_ALMA], [FKIdPartida_CONTA], [Clave], [ClaveAnt], [Descripcion], [Modelo], [Serie],
    [Requisicion], [Factura], [Costo], [FechaAdq], [Referencia], [Notas], [Ubicacion], [AAdquisicion],
    [Frente], [Fondo], [Altura], [Diametro], [VerificacionesDias], [MantenimientoDias], [Mantenimiento],
    [Calibracion], [Rango], [Resolucion], [FechaUltInv], [FechaReqscn], [Estatus], [Caracteristicas],
    [Resguardo], [ResguardoAnterior], [RelId], [ValorRescate], [ValorActual], [Antiguedad], [Progresivo],
    [Consecutivo], [ClaveHist], [EstaResguardado], [FechaResguardado], [Localizado], [esContabilizado],
    [Activo], [FechaCreacion], [UsuarioCreacion]
)
SELECT
    [PK_IdBien], [FK_IdGrupoBien__SICOP], [FK_IdTipoBien__SICOP], [FK_IdAreaUlt__SIS], [FK_IdProveedor__SIS],
    [FK_IdEstadoBien__SICOP], [FK_IdTipoPatrimonio__SICOP], [FK_IdMarca__SICOP], [FK_IdMaterial__SICOP],
    [FK_IdTipoAdq__SICOP], [FK_IdPartida__SIS], [Clave], [ClaveAnt], [Descripcion], [Modelo], [Serie],
    [Requisicion], [Factura], [Costo], [FechaAdq], [Referencia], [Notas], [Ubicacion], [AAdquisicion],
    [Frente], [Fondo], [Altura], [Diametro], [VerificacionesDias], [MantenimientoDias], [Mantenimiento],
    [Calibracion], [Rango], [Resolucion], [FechaUltInv], [FechaReqscn], [Estatus], [Caracteristicas],
    [Resguardo], [ResguardoAnterior], [RelId], [ValorRescate], [ValorActual], [Antiguedad], [Progresivo],
    [Consecutivo], [ClaveHist], [EstaResguardado], [FechaResguardado], [Localizado], [esContabilizado],
    [CT_LIVE], [CT_CreatedDate], [CT_CreatedBy]
FROM [BD_PRESUPUESTO].[SICOP].[Bien]
WHERE [FK_IdPartida__SIS] IN (SELECT [PKIdPartida] FROM [CONTA].[Partida])
  AND [FK_IdProveedor__SIS] IN (SELECT [PKIdProveedor] FROM [SIS].[Proveedor])
  AND [FK_IdTipoBien__SICOP] IN (SELECT [PKIdTipoBien] FROM [ALMA].[TipoBien]);
SET IDENTITY_INSERT [ALMA].[Bien] OFF;
GO

-- =============================================
-- TABLAS DE CONTEO (MIGRACIÓN PARCIAL)
-- =============================================
-- Nota: La tabla NumeroConteo no existe en el destino, por lo que la FK se omite.
-- =============================================

DROP TABLE  [ALMA].[Conteo];
GO

CREATE TABLE [ALMA].[Conteo] (
    [PKIdConteo]            INT              IDENTITY(1, 1) NOT NULL,
    [FKIdTipoBien_ALMA]     INT              NOT NULL,
    [CantidadInventario]    DECIMAL(18, 2)   NOT NULL,
    [Descripcion]           NVARCHAR(MAX)    NOT NULL,
    [FechaInicio]           DATETIME         NOT NULL,
    [FechaFin]              DATETIME         NULL,
    [Activo]                        BIT               NOT NULL CONSTRAINT DF_Bien_Conteo_Activo DEFAULT (1),
    [FechaCreacion]                 DATETIME          CONSTRAINT DF_Bien_Conteo_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]               INT               NOT NULL,
    [FechaModificacion]             DATETIME          NULL,
    [UsuarioModificacion]           INT               NULL,
    CONSTRAINT PK_Conteo PRIMARY KEY ([PKIdConteo]),
    CONSTRAINT FK_Conteo_TipoBien FOREIGN KEY ([FKIdTipoBien_ALMA]) REFERENCES [ALMA].[TipoBien] ([PKIdTipoBien]),
    CONSTRAINT FK_Conteo_UsuarioCreacion FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]),
    CONSTRAINT FK_Conteo_UsuarioModificacion FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario])
);
GO

DROP TABLE  [ALMA].[ConteoDetalle];
GO

CREATE TABLE [ALMA].[ConteoDetalle] (
    [PKIdDetalleConteo]     INT              IDENTITY(1, 1) NOT NULL,
    [FKIdConteo_ALMA]       INT              NOT NULL,
    [FKIdNumeroConteo_ALMA] INT              NOT NULL,   -- Tabla NumeroConteo no existe, se omite FK
    [FKIdPersona_NOM]       INT              NOT NULL,
    [Cantidad]              DECIMAL(18, 2)   NOT NULL,
    [Fecha]                 DATETIME         NOT NULL,
    [Activo]                        BIT               NOT NULL CONSTRAINT DF_Bien_ConteoDetalle_Activo DEFAULT (1),
    [FechaCreacion]                 DATETIME          CONSTRAINT DF_Bien_ConteoDetalle_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]               INT               NOT NULL,
    [FechaModificacion]             DATETIME          NULL,
    [UsuarioModificacion]           INT               NULL,
    CONSTRAINT PK_ConteoDetalle PRIMARY KEY ([PKIdDetalleConteo]),
    CONSTRAINT FK_ConteoDetalle_Conteo FOREIGN KEY ([FKIdConteo_ALMA]) REFERENCES [ALMA].[Conteo] ([PKIdConteo]),
    CONSTRAINT FK_ConteoDetalle_Persona FOREIGN KEY ([FKIdPersona_NOM]) REFERENCES [NOM].[Persona] ([PKIdPersona]),
    CONSTRAINT FK_ConteoDetalle_UsuarioCreacion FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]),
    CONSTRAINT FK_ConteoDetalle_UsuarioModificacion FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario])
);
GO

-- =============================================
-- TABLA PARA CONTEO POR CÓDIGO DE BARRAS (ÍTEMS INDIVIDUALES)
-- =============================================
DROP TABLE IF EXISTS [ALMA].[ConteoDetalleEscaneo];
GO

CREATE TABLE [ALMA].[ConteoDetalleEscaneo] (
    [PKIdDetalleEscaneo]    INT              IDENTITY(1, 1) NOT NULL,
    [FKIdConteo_ALMA]       INT              NOT NULL,          -- Conteo al que pertenece el escaneo
    [FKIdPersona_NOM]       INT              NOT NULL,          -- Persona que realizó el escaneo
    [CodigoBarras]          NVARCHAR(100)    NOT NULL,          -- Código de barras del bien escaneado
    [FKIdTipoBien_ALMA]     INT              NOT NULL,          -- Tipo de bien (se puede deducir del código o del bien maestro)
    [FKIdBien_ALMA]         INT              NULL,              -- Opcional: referencia al bien maestro si existe (ej. tabla ALMA.Bien)
    [FechaEscaneo]          DATETIME         NOT NULL CONSTRAINT DF_ConteoDetalleEscaneo_FechaEscaneo DEFAULT SYSDATETIME(),
    [Activo]                BIT              NOT NULL CONSTRAINT DF_ConteoDetalleEscaneo_Activo DEFAULT (1),
    [FechaCreacion]         DATETIME         CONSTRAINT DF_ConteoDetalleEscaneo_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]       INT              NOT NULL,
    [FechaModificacion]     DATETIME         NULL,
    [UsuarioModificacion]   INT              NULL,
    CONSTRAINT PK_ConteoDetalleEscaneo PRIMARY KEY ([PKIdDetalleEscaneo]),
    CONSTRAINT FK_ConteoDetalleEscaneo_Conteo FOREIGN KEY ([FKIdConteo_ALMA]) REFERENCES [ALMA].[Conteo] ([PKIdConteo]),
    CONSTRAINT FK_ConteoDetalleEscaneo_Persona FOREIGN KEY ([FKIdPersona_NOM]) REFERENCES [NOM].[Persona] ([PKIdPersona]),
    CONSTRAINT FK_ConteoDetalleEscaneo_TipoBien FOREIGN KEY ([FKIdTipoBien_ALMA]) REFERENCES [ALMA].[TipoBien] ([PKIdTipoBien]),
    CONSTRAINT FK_ConteoDetalleEscaneo_UsuarioCreacion FOREIGN KEY ([UsuarioCreacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario]),
    CONSTRAINT FK_ConteoDetalleEscaneo_UsuarioModificacion FOREIGN KEY ([UsuarioModificacion]) REFERENCES [SIS].[Usuario] ([PkIdUsuario])
);
GO

-- Índice sugerido para búsquedas por código de barras dentro de un conteo
CREATE INDEX IX_ConteoDetalleEscaneo_CodigoBarras ON [ALMA].[ConteoDetalleEscaneo] ([FKIdConteo_ALMA], [CodigoBarras]);
GO

DROP TABLE  [ALMA].[ConteoHist];
GO

CREATE TABLE [ALMA].[ConteoHist] (
    [PKIdConteoHist]        INT              IDENTITY(1, 1) NOT NULL,
    [PKIdConteo]            INT              NOT NULL,
    [FKIdTipoBien_ALMA]     INT              NOT NULL,
    [CantidadInventario]    DECIMAL(18, 2)   NOT NULL,
    [Descripcion]           NVARCHAR(MAX)    NOT NULL,
    [FechaInicio]           DATETIME         NOT NULL,
    [FechaFin]              DATETIME         NULL,
    [PrimerConteo]          DECIMAL(18, 2)   NOT NULL,
    [SegundoConteo]         DECIMAL(18, 2)   NOT NULL,
    [TercerConteo]          DECIMAL(18, 2)   NOT NULL,
    [Diferencias]           NVARCHAR(MAX)    NOT NULL,
    [Activo]                        BIT               NOT NULL CONSTRAINT DF_Bien_ConteoHist_Activo DEFAULT (1),
    [FechaCreacion]                 DATETIME          CONSTRAINT DF_Bien_ConteoHist_FechaCreacion DEFAULT SYSDATETIME(),
    [UsuarioCreacion]               INT               NOT NULL,
    [FechaModificacion]             DATETIME          NULL,
    [UsuarioModificacion]           INT               NULL,
    [Nivel]                 INT              NOT NULL,
    CONSTRAINT PK_ConteoHist PRIMARY KEY ([PKIdConteoHist])
);
GO