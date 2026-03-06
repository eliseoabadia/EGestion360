

drop table if exists [CONTA].[TipoCuenta]

CREATE TABLE [CONTA].[TipoCuenta](
	[PKIdTipoCuenta] [int] IDENTITY(1,1) NOT NULL,
	[Color] [nvarchar](5) NOT NULL,
	[Descripcion] [nvarchar](25) NOT NULL,
	Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
	CONSTRAINT SIS_TipoCuenta_PK_IdTipoCuenta PRIMARY KEY CLUSTERED ([PKIdTipoCuenta]),
	)


	INSERT INTO [CONTA].[TipoCuenta]
           ([Color]
           ,[Descripcion]
           ,[UsuarioCreacion]
           ,[FechaCreacion]
           ,[Activo])
     VALUES
           ('1'           ,'ACREEDORA'           ,1           ,GETDATE()           ,1),
           ('2'           ,'ACREEDORA'           ,1           ,GETDATE()           ,1)

drop table if exists CONTA.CuentaContable
CREATE TABLE CONTA.CuentaContable (
    PKIdCuentaContable INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
	[FKIdTipoCuenta_CONTA] INT NOT NULL,
    [Cuenta] [nvarchar](5) NOT NULL,
	[SubCuenta] [nvarchar](5) NOT NULL,
	[SubSubCuenta] [nvarchar](5) NOT NULL,
	[SubSubSubCuenta] [nvarchar](5) NOT NULL,
	[SubSubSubSubCuenta] [nvarchar](5) NOT NULL,
	[Saldo] [numeric](18, 2) NOT NULL,
	[Descripcion] [varchar](250) NULL,
	Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
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
    CONSTRAINT PK_CuentaContable PRIMARY KEY (PKIdCuentaContable),
    CONSTRAINT FK_CuentaContable_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
	CONSTRAINT FK_CuentaContable_TipoCuenta FOREIGN KEY ([FKIdTipoCuenta_CONTA]) REFERENCES [CONTA].[TipoCuenta]([PKIdTipoCuenta])
);

insert into CONTA.CuentaContable ([FKIdEmpresa_SIS]
           ,[FKIdTipoCuenta_CONTA]
           ,[Cuenta]
           ,[SubCuenta]
           ,[SubSubCuenta]
           ,[SubSubSubCuenta]
           ,[SubSubSubSubCuenta]
           ,[Saldo]
           ,[Descripcion]
           ,[Activo]
           ,[FechaCreacion]
           ,[UsuarioCreacion]
           ,[S5]
           ,[S6]
           ,[S7]
           ,[ClaveOrd]
           ,[Padre]
           ,[Hijo]
           ,[NivelCuenta]
           ,[Cta_Coi]
           ,[Desc_Coi]
           ,[TipoCuenta]
           ,[S8]
           ,[S9]
           ,[S10])
select 1,  FK_IdTipoCuenta__SIS
           ,[Cuenta]
           ,[SubCuenta]
           ,[SubSubCuenta]
           ,[SubSubSubCuenta]
           ,[SubSubSubSubCuenta]
           ,[Saldo]
           ,[Descripcion]
           ,CT_LIVE
           ,[CT_CreatedDate]
           ,[CT_CreatedBy]
           ,[S5]
           ,[S6]
           ,[S7]
           ,[ClaveOrd]
           ,[Padre]
           ,[Hijo]
           ,[NivelCuenta]
           ,[Cta_Coi]
           ,[Desc_Coi]
           ,[TipoCuenta]
           ,[S8]
           ,[S9]
           ,[S10] from [BD_PRESUPUESTO].SIS.CuentaContable
           where FK_IdTipoCuenta__SIS in (1,2)



CREATE TABLE [ALMA].[Unidades](
	[PKIdUnidades] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](50) NOT NULL,
	Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT ALMA_Unidades_PK_IdUnidades PRIMARY KEY CLUSTERED ([PKIdUnidades]),
    )
    
    	INSERT INTO [ALMA].[Unidades]
           ([Descripcion]
           ,[UsuarioCreacion]
           ,[FechaCreacion]
           ,[Activo])
     SELECT Descripcion,1,CT_CreatedDate,1 FROM [BD_PRESUPUESTO].alma.Unidades
     
    drop table if exists [CONTA].[Capitulo]
CREATE TABLE [CONTA].[Capitulo](
	[PKIdCapitulo] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [nvarchar](30) NULL,
	[Descripcion] [nvarchar](120) NULL,
	Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
     CONSTRAINT CONTA_Capitulo_PK_IdCapitulo PRIMARY KEY CLUSTERED ([PKIdCapitulo]),
    )

    --insert into [CONTA].[Capitulo]
    --       ([Clave]
    --       ,[Descripcion]
    --       ,[UsuarioCreacion]
    --       ,[FechaCreacion]
    --       ,[Activo])
    -- SELECT Clave,Descripcion,[CT_CreatedBy],CT_CreatedDate,1 FROM [BD_PRESUPUESTO].SIS.Capitulo
     
     
-- Activar INSERT con IDs específicos
SET IDENTITY_INSERT [CONTA].[Capitulo] ON

-- Insertar los datos manteniendo el ID original
INSERT INTO [CONTA].[Capitulo] (
    [PKIdCapitulo],           -- El ID original de la fuente
    [Clave],
    [Descripcion],
    [UsuarioCreacion],
    [FechaCreacion],
    [FechaModificacion],
    [UsuarioModificacion],
    [Activo]
)
SELECT 
    s.[PK_IdCapitulo],         -- Mismo ID que en origen
    s.[Clave],
    s.[Descripcion],
    ISNULL(s.[CT_CreatedBy], 1),  -- Si es NULL, asignar usuario por defecto
    ISNULL(s.[CT_CreatedDate], GETDATE()),  -- Si es NULL, usar fecha actual
    s.[CT_ModifiedDate],       -- Puede ser NULL
    s.[CT_ModifiedBy],         -- Puede ser NULL
    ISNULL(s.[CT_LIVE], 1)     -- Si es NULL, activo por defecto
FROM [BD_PRESUPUESTO].SIS.Capitulo s
WHERE NOT EXISTS (  -- Evitar duplicados
    SELECT 1 
    FROM [CONTA].[Capitulo] c 
    WHERE c.PKIdCapitulo = s.[PK_IdCapitulo]
)

-- Desactivar INSERT con IDs específicos
SET IDENTITY_INSERT [CONTA].[Capitulo] OFF


drop table if exists [CONTA].[Concepto]
 CREATE TABLE [CONTA].[Concepto](
    [PKIdConcepto] [int] IDENTITY(1,1) NOT NULL,
    [FKIdCapitulo_CONTA] [int] NOT NULL,
	[Clave] [nvarchar](30) NULL,
	[Descripcion] [nvarchar](120) NULL,
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
	CONSTRAINT CONTA_Concepto_PK_IdConcepto PRIMARY KEY CLUSTERED ([PKIdConcepto]),
    CONSTRAINT CONTA_FK_IdCapitulo FOREIGN KEY ([FKIdCapitulo_CONTA]) REFERENCES [CONTA].[Capitulo]([PKIdCapitulo])
    )

    --insert into [CONTA].[Concepto]
    --       ([FKIdCapitulo_CONTA],[Clave],[Descripcion],Activo,FechaCreacion,FechaModificacion)
    -- SELECT [FK_IdCapitulo__SIS]
    --  ,[Clave]
    --  ,[Descripcion]
    --  ,[CT_CreatedBy]
    --  ,[CT_CreatedDate]
    --  ,[CT_ModifiedBy]
    --  ,[CT_ModifiedDate]
    --  ,[CT_LIVE]
    -- FROM [BD_PRESUPUESTO].SIS.Concepto

     -- PASO 3: Si todo está OK, hacer la migración
SET IDENTITY_INSERT [CONTA].[Concepto] ON

INSERT INTO [CONTA].[Concepto] (
    [PKIdConcepto],
    [FKIdCapitulo_CONTA],
    [Clave],
    [Descripcion],
    [Activo],
    [FechaCreacion],
    [UsuarioCreacion]
)
SELECT 
    s.[PK_IdConcepto],
    s.[FK_IdCapitulo__SIS],
    s.[Clave],
    s.[Descripcion],
    s.[CT_LIVE],   -- Si es NULL, poner 1 por defecto
    s.[CT_CreatedDate],
    s.[CT_CreatedBy]
FROM [BD_PRESUPUESTO].SIS.Concepto s
WHERE NOT EXISTS (  -- Evitar duplicados
    SELECT 1 
    FROM [CONTA].[Concepto] c 
    WHERE c.PKIdConcepto = s.PK_IdConcepto
)

SET IDENTITY_INSERT [CONTA].[Concepto] OFF


drop table if exists [CONTA].[Partida]
CREATE TABLE [CONTA].[Partida](
	[PKIdPartida] [int] IDENTITY(1,1) NOT NULL,
	[FKIdConcepto_SIS] [int] NULL,
	[Clave] [nvarchar](10) NOT NULL,
	[Descripcion] [nvarchar](255) NOT NULL,
	Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
 CONSTRAINT CONTA_Patida_PK_IdPartida PRIMARY KEY ([PKIdPartida]),
    CONSTRAINT CONTA_FK_IdConcepto FOREIGN KEY ([FKIdConcepto_SIS]) REFERENCES [CONTA].[Concepto]([PKIdConcepto])
    )


-- Activar INSERT con IDs específicos
SET IDENTITY_INSERT [CONTA].[Partida] ON

-- Insertar todos los registros
INSERT INTO [CONTA].[Partida] (
    [PKIdPartida],
    [FKIdConcepto_SIS],
    [Clave],
    [Descripcion],
    [UsuarioCreacion],
    [FechaCreacion],
    [UsuarioModificacion],
    [FechaModificacion],
    [Activo]
)
SELECT 
    s.[PK_IdPartida],
    s.[FK_IdConcepto__SIS],
    s.[Clave],
    s.[Descripcion],
    ISNULL(s.[CT_CreatedBy], 1),
    ISNULL(s.[CT_CreatedDate], GETDATE()),
    s.[CT_ModifiedBy],
    s.[CT_ModifiedDate],
    ISNULL(s.[CT_LIVE], 1)
FROM [BD_PRESUPUESTO].SIS.Partida s
INNER JOIN [CONTA].[Concepto] c ON s.FK_IdConcepto__SIS = c.PKIdConcepto
LEFT JOIN [CONTA].[Partida] p ON s.PK_IdPartida = p.PKIdPartida
WHERE p.PKIdPartida IS NULL  -- Solo insertar los que no existen

-- Desactivar INSERT con IDs específicos
SET IDENTITY_INSERT [CONTA].[Partida] OFF


CREATE TABLE [ALMA].[Nivel](
	[PKIdNivel] [int] IDENTITY(1,1) NOT NULL,
	[Nivel] [int] NOT NULL,
	[Descipcion] [nvarchar](20) NOT NULL,
	Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT ALMA_Nivel_PK_IdNivel PRIMARY KEY ([PKIdNivel])
    )

    -- Activar INSERT con IDs específicos
SET IDENTITY_INSERT [ALMA].[Nivel] ON

-- Insertar los datos manteniendo el ID original
INSERT INTO [ALMA].[Nivel] (
    [PKIdNivel],               -- El ID original de la fuente
    [Nivel],
    [Descipcion],              -- Nota: hay un typo en el nombre (Descipcion vs Descripcion)
    [UsuarioCreacion],
    [FechaCreacion],
    [FechaModificacion],
    [UsuarioModificacion],
    [Activo]
)
SELECT 
    s.[PK_IdNivel],             -- Mismo ID que en origen
    s.[Nivel],
    s.[Descipcion],             -- Mantenemos el typo para coincidir con la estructura
    ISNULL(s.[CT_CreatedBy], 1),
    ISNULL(s.[CT_CreatedDate], GETDATE()),
    s.[CT_ModifiedDate],
    s.[CT_ModifiedBy],
    ISNULL(s.[CT_LIVE], 1)
FROM [BD_PRESUPUESTO].[SICOP].[Nivel] s
WHERE NOT EXISTS (  -- Evitar duplicados
    SELECT 1 
    FROM [ALMA].[Nivel] n 
    WHERE n.PKIdNivel = s.PK_IdNivel
)

-- Desactivar INSERT con IDs específicos
SET IDENTITY_INSERT [ALMA].[Nivel] OFF



CREATE TABLE [ALMA].[Familia](
	[PKIdFamilia] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](80) NOT NULL,
	[Clave] [nvarchar](50) NULL,
	Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT ALMA_Familia_PK_IdFamilia PRIMARY KEY ([PKIdFamilia])
    )

    -- Activar INSERT con IDs específicos
SET IDENTITY_INSERT [ALMA].[Familia] ON

-- Insertar los datos manteniendo el ID original
INSERT INTO [ALMA].[Familia] (
    [PKIdFamilia],              -- El ID original de la fuente
    [Descripcion],
    [Clave],
    [UsuarioCreacion],
    [FechaCreacion],
    [FechaModificacion],
    [UsuarioModificacion],
    [Activo]
)
SELECT 
    s.[PK_IdFamilia],            -- Mismo ID que en origen
    s.[Descripcion],
    s.[Clave],
    ISNULL(s.[CT_CreatedBy], 1),
    ISNULL(s.[CT_CreatedDate], GETDATE()),
    s.[CT_ModifiedDate],
    s.[CT_ModifiedBy],
    ISNULL(s.[CT_LIVE], 1)
FROM [BD_PRESUPUESTO].[SICOP].[Familia] s
WHERE NOT EXISTS (  -- Evitar duplicados
    SELECT 1 
    FROM [ALMA].[Familia] f 
    WHERE f.PKIdFamilia = s.PK_IdFamilia
)

-- Desactivar INSERT con IDs específicos
SET IDENTITY_INSERT [ALMA].[Familia] OFF


CREATE TABLE [ALMA].[GrupoBien](
	[PKIdGrupoBien] [int] IDENTITY(1,1) NOT NULL,
	[FKIdFamilia_ALMA] [int] NOT NULL,
	[Descripcion] [nvarchar](800) NULL,
	[Clave] [int] NULL,
	[ClaveAN] [nvarchar](50) NULL,
	[CABM_ACT] [nvarchar](50) NULL,
	[CLAVE_CUCOP] [nvarchar](50) NULL,
	[MEDIDA] [nvarchar](50) NULL,
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
     CONSTRAINT ALMA_GrupoBien_PK_IdGrupoBien PRIMARY KEY ([PKIdGrupoBien]),
    CONSTRAINT  ALMA_FK_IdFamilia FOREIGN KEY ([FKIdFamilia_ALMA]) REFERENCES [ALMA].[Familia]([PKIdFamilia])
    )


    -- Activar INSERT con IDs específicos
SET IDENTITY_INSERT [ALMA].[GrupoBien] ON

-- Insertar los datos manteniendo el ID original
INSERT INTO [ALMA].[GrupoBien] (
    [PKIdGrupoBien],           -- El ID original de la fuente
    [FKIdFamilia_ALMA],
    [Descripcion],
    [Clave],
    [ClaveAN],
    [CABM_ACT],
    [CLAVE_CUCOP],
    [MEDIDA],
    [UsuarioCreacion],
    [FechaCreacion],
    [FechaModificacion],
    [UsuarioModificacion],
    [Activo]
)
SELECT 
    s.[PK_IdGrupoBien],         -- Mismo ID que en origen
    s.[FK_IdFamilia__SICOP],    -- Este ID debe existir en ALMA.Familia
    s.[Descripcion],
    s.[Clave],
    s.[ClaveAN],
    s.[CABM_ACT],
    s.[CLAVE_CUCOP],
    s.[MEDIDA],
    ISNULL(s.[CT_CreatedBy], 1),
    ISNULL(s.[CT_CreatedDate], GETDATE()),
    s.[CT_ModifiedDate],
    s.[CT_ModifiedBy],
    ISNULL(s.[CT_LIVE], 1)
FROM [BD_PRESUPUESTO].[SICOP].[GrupoBien] s
INNER JOIN [ALMA].[Familia] f ON s.FK_IdFamilia__SICOP = f.PKIdFamilia  -- Solo si la familia existe
WHERE NOT EXISTS (  -- Evitar duplicados
    SELECT 1 
    FROM [ALMA].[GrupoBien] g 
    WHERE g.PKIdGrupoBien = s.PK_IdGrupoBien
)

-- Desactivar INSERT con IDs específicos
SET IDENTITY_INSERT [ALMA].[GrupoBien] OFF

CREATE TABLE [ALMA].[TipoBien](
	[PKIdTipoBien] [int] IDENTITY(1,1) NOT NULL,
	[FKIdGrupoBien_ALMA] [int] NULL,
	[FKIdNivel_ALMA] [int] NULL,
	[FKIdPartida_CONTA] [int] NULL,
	[FKIdCuentaContable_CONTA] [int] NULL,
	[FKIdUnidades_ALMA] [int] NULL,
	[FKIdLocalizacion_ALMA] [int] NULL, --//Aún no aplicado
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
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    [FKIdUnidades_Equivalente] [int] NULL,
	[Cantidad_Equivalente] [int] NULL,
    CONSTRAINT ALMA_TipoBien_PK_IdGrupoBien PRIMARY KEY ([PKIdTipoBien]),
    CONSTRAINT  ALMA_TipoBien_FK_IdFamilia FOREIGN KEY ([FKIdGrupoBien_ALMA]) REFERENCES [ALMA].[GrupoBien](PKIdGrupoBien),
     CONSTRAINT  ALMA_TipoBien_FK_IdNivel FOREIGN KEY ([FKIdNivel_ALMA]) REFERENCES [ALMA].[Nivel](PKIdNivel),
      CONSTRAINT  ALMA_TipoBien_FK_IdPartida FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida](PKIdPartida),
      CONSTRAINT  ALMA_TipoBien_FK_IdCuentaContable FOREIGN KEY ([FKIdCuentaContable_CONTA]) REFERENCES [CONTA].[CuentaContable](PKIdCuentaContable),
      CONSTRAINT  ALMA_TipoBien_FK_IdUnidades FOREIGN KEY ([FKIdUnidades_ALMA]) REFERENCES [ALMA].[Unidades](PKIdUnidades),
      CONSTRAINT  ALMA_TipoBien_FK_IdUnidadesEquivalente FOREIGN KEY ([FKIdUnidades_Equivalente]) REFERENCES [ALMA].[Unidades](PKIdUnidades)
    )

    -- Activar INSERT con IDs específicos
SET IDENTITY_INSERT [ALMA].[TipoBien] ON

-- Insertar los datos manteniendo el ID original
INSERT INTO [ALMA].[TipoBien] (
    [PKIdTipoBien],
    [FKIdGrupoBien_ALMA],
    [FKIdNivel_ALMA],
    [FKIdPartida_CONTA],
    [FKIdCuentaContable_CONTA],
    [FKIdUnidades_ALMA],
    [FKIdLocalizacion_ALMA],
    [CodigoClave],
    [Descripcion],
    [DepreciacionAnual],
    [Consecutivo],
    [CABMS],
    [Identificador],
    [ExistenciaMinima],
    [ExistenciaMaxima],
    [TiempoVida],
    [Pk_IdTratadoInt],
    [Cuota],
    [ProveeduriaNac],
    [CatalogoBasico],
    [CUCOP_PLUS],
    [FKIdUnidades_Equivalente],
    [Cantidad_Equivalente],
    [UsuarioCreacion],
    [FechaCreacion],
    [FechaModificacion],
    [UsuarioModificacion],
    [Activo]
)
SELECT 
    s.[PK_IdTipoBien],
    s.[FK_IdGrupoBien__SICOP],
    s.[FK_IdNivel__SICOP],
    s.[FK_IdPartida__SIS],
    s.[FK_IdCuentaContable__SIS],
    s.[FK_IdUnidades__ALMA],
    s.[FK_IdLocalizacion__ALMA],
    s.[CodigoClave],
    s.[Descripcion],
    s.[DepreciacionAnual],
    s.[Consecutivo],
    s.[CABMS],
    s.[Identificador],
    s.[ExistenciaMinima],
    s.[ExistenciaMaxima],
    s.[TiempoVida],
    s.[Pk_IdTratadoInt],
    s.[Cuota],
    s.[ProveeduriaNac],
    s.[CatalogoBasico],
    s.[CUCOP_PLUS],
    s.[FK_IdUnidades_Equivalente],
    s.[Cantidad_Equivalente],
    ISNULL(s.[CT_CreatedBy], 1),
    ISNULL(s.[CT_CreatedDate], GETDATE()),
    s.[CT_ModifiedDate],
    s.[CT_ModifiedBy],
    ISNULL(s.[CT_LIVE], 1)
FROM [BD_PRESUPUESTO].[SICOP].[TipoBien] s
INNER JOIN [ALMA].[GrupoBien] g ON s.FK_IdGrupoBien__SICOP = g.PKIdGrupoBien
INNER JOIN [ALMA].[Nivel] n ON s.FK_IdNivel__SICOP = n.PKIdNivel
INNER JOIN [CONTA].[Partida] p ON s.FK_IdPartida__SIS = p.PKIdPartida
LEFT JOIN [CONTA].[CuentaContable] c ON s.FK_IdCuentaContable__SIS = c.PKIdCuentaContable
INNER JOIN [ALMA].[Unidades] u1 ON s.FK_IdUnidades__ALMA = u1.PKIdUnidades
LEFT JOIN [ALMA].[Unidades] u2 ON s.FK_IdUnidades_Equivalente = u2.PKIdUnidades
WHERE NOT EXISTS (
    SELECT 1 FROM [ALMA].[TipoBien] t WHERE t.PKIdTipoBien = s.PK_IdTipoBien
)

-- Desactivar INSERT con IDs específicos
SET IDENTITY_INSERT [ALMA].[TipoBien] OFF



/* Lógica del conteo cíclico */
-- =============================================
-- MÓDULO DE CONTEO CÍCLICO (MODELO DE REGISTROS)
-- Esquema: ALMA
-- Permite N conteos por artículo (máximo 3 por regla de negocio)
-- =============================================

-- =============================================
-- CATÁLOGOS BASE
-- =============================================

-- Estatus del periodo de conteo
CREATE TABLE ALMA.EstatusPeriodo (
    PKIdEstatusPeriodo INT IDENTITY(1,1) NOT NULL,
    Nombre NVARCHAR(30) NOT NULL,  -- 'Pendiente', 'En Proceso', 'Completado', 'Cerrado'
    Descripcion NVARCHAR(100) NULL,
    Activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_EstatusPeriodo PRIMARY KEY (PKIdEstatusPeriodo),
    CONSTRAINT UQ_EstatusPeriodo_Nombre UNIQUE (Nombre)
)
GO

-- Estatus del artículo en el conteo
CREATE TABLE ALMA.EstatusArticuloConteo (
    PKIdEstatusArticulo INT IDENTITY(1,1) NOT NULL,
    Nombre NVARCHAR(30) NOT NULL,  -- 'Pendiente 1er Conteo', 'Pendiente 2do Conteo', 'Requiere 3er Conteo', 'Concluido', 'En Discrepancia'
    Descripcion NVARCHAR(100) NULL,
    Orden INT NOT NULL,  -- Para flujo
    Activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_EstatusArticulo PRIMARY KEY (PKIdEstatusArticulo),
    CONSTRAINT UQ_EstatusArticulo_Nombre UNIQUE (Nombre)
)
GO

-- Tipos de conteo
CREATE TABLE ALMA.TipoConteo (
    PKIdTipoConteo INT IDENTITY(1,1) NOT NULL,
    Nombre NVARCHAR(30) NOT NULL,  -- 'Cíclico', 'Anual', 'Auditoría', 'Aleatorio'
    Descripcion NVARCHAR(100) NULL,
    Activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_TipoConteo PRIMARY KEY (PKIdTipoConteo)
)
GO

-- =============================================
-- PERIODO DE CONTEO (POR SUCURSAL)
-- =============================================

CREATE TABLE ALMA.PeriodoConteo (
    PKIdPeriodoConteo INT IDENTITY(1,1) NOT NULL,
    FKIdSucursal_SIS INT NOT NULL,
    FKIdTipoConteo_ALMA INT NOT NULL,
    FKIdEstatus_ALMA INT NOT NULL,
    
    -- Identificación
    CodigoPeriodo NVARCHAR(20) NOT NULL,      -- Ej: 'CIC-2026-001'
    Nombre NVARCHAR(100) NOT NULL,
    Descripcion NVARCHAR(500) NULL,
    
    -- Fechas
    FechaInicio DATE NOT NULL,
    FechaFin DATE NULL,
    FechaCierre DATETIME2 NULL,
    
    -- Configuración del periodo
    MaximoConteosPorArticulo INT NOT NULL DEFAULT 3,  -- Máximo de conteos permitidos
    RequiereAprobacionSupervisor BIT NOT NULL DEFAULT 1,
    
    -- Responsables
    FKIdResponsable_SIS INT NULL,  -- Encargado del periodo
    FKIdSupervisor_SIS INT NULL,   -- Supervisor que aprueba
    
    -- Estadísticas resumen
    TotalArticulos INT NULL,
    ArticulosConcluidos INT NULL,
    ArticulosConDiferencia INT NULL,
    
    -- Auditoría
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    
    CONSTRAINT PK_PeriodoConteo PRIMARY KEY (PKIdPeriodoConteo),
    CONSTRAINT FK_PeriodoConteo_Sucursal FOREIGN KEY (FKIdSucursal_SIS) REFERENCES SIS.Sucursal(PKIdSucursal),
    CONSTRAINT FK_PeriodoConteo_Tipo FOREIGN KEY (FKIdTipoConteo_ALMA) REFERENCES ALMA.TipoConteo(PKIdTipoConteo),
    CONSTRAINT FK_PeriodoConteo_Estatus FOREIGN KEY (FKIdEstatus_ALMA) REFERENCES ALMA.EstatusPeriodo(PKIdEstatusPeriodo),
    CONSTRAINT FK_PeriodoConteo_Responsable FOREIGN KEY (FKIdResponsable_SIS) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_PeriodoConteo_Supervisor FOREIGN KEY (FKIdSupervisor_SIS) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT UQ_PeriodoConteo_Codigo UNIQUE (FKIdSucursal_SIS, CodigoPeriodo)
)
GO

-- Índices para PeriodoConteo
CREATE INDEX IX_PeriodoConteo_Sucursal ON ALMA.PeriodoConteo(FKIdSucursal_SIS, FechaInicio) WHERE Activo = 1
CREATE INDEX IX_PeriodoConteo_Estatus ON ALMA.PeriodoConteo(FKIdEstatus_ALMA) WHERE Activo = 1
GO

-- =============================================
-- ARTÍCULOS A CONTAR EN EL PERIODO
-- =============================================

CREATE TABLE ALMA.ArticuloConteo (
    PKIdArticuloConteo INT IDENTITY(1,1) NOT NULL,
    FKIdPeriodoConteo_ALMA INT NOT NULL,
    FKIdTipoBien_ALMA INT NOT NULL,
    FKIdSucursal_SIS INT NOT NULL,  -- Denormalizado para consultas rápidas
    FKIdEstatus_ALMA INT NOT NULL,  -- Estatus actual del artículo
    
    -- Información base del artículo
    CodigoBarras NVARCHAR(50) NULL,
    DescripcionArticulo NVARCHAR(1200) NULL,
    UnidadMedida NVARCHAR(50) NULL,
    Ubicacion NVARCHAR(100) NULL,  -- Ubicación física (estante, rack, etc.)
    
    -- Información del sistema
    ExistenciaSistema DECIMAL(18,4) NOT NULL,  -- Lo que dice el sistema al iniciar
    FechaUltimoConteoAnterior DATETIME2 NULL,  -- Última vez que se contó
    
    -- Resultados finales (se calculan al concluir)
    ExistenciaFinal DECIMAL(18,4) NULL,        -- Valor aceptado después de los conteos
    Diferencia DECIMAL(18,4) NULL,             -- ExistenciaFinal - ExistenciaSistema
    PorcentajeDiferencia DECIMAL(18,4) NULL,   -- (Diferencia / ExistenciaSistema) * 100
    
    -- Control de conteos
    ConteosRealizados INT NOT NULL DEFAULT 0,  -- Número de conteos realizados
    ConteosPendientes INT NOT NULL DEFAULT 1,  -- Conteos que faltan (inicia en 1)
    
    -- Fechas de control
    FechaInicioConteo DATETIME2 NULL,
    FechaConclusion DATETIME2 NULL,
    FKIdUsuarioConcluyo_SIS INT NULL,
    
    -- Auditoría
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    
    CONSTRAINT PK_ArticuloConteo PRIMARY KEY (PKIdArticuloConteo),
    CONSTRAINT FK_ArticuloConteo_Periodo FOREIGN KEY (FKIdPeriodoConteo_ALMA) REFERENCES ALMA.PeriodoConteo(PKIdPeriodoConteo),
    CONSTRAINT FK_ArticuloConteo_TipoBien FOREIGN KEY (FKIdTipoBien_ALMA) REFERENCES ALMA.TipoBien(PKIdTipoBien),
    CONSTRAINT FK_ArticuloConteo_Sucursal FOREIGN KEY (FKIdSucursal_SIS) REFERENCES SIS.Sucursal(PKIdSucursal),
    CONSTRAINT FK_ArticuloConteo_Estatus FOREIGN KEY (FKIdEstatus_ALMA) REFERENCES ALMA.EstatusArticuloConteo(PKIdEstatusArticulo),
    CONSTRAINT FK_ArticuloConteo_UsuarioConcluyo FOREIGN KEY (FKIdUsuarioConcluyo_SIS) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT UQ_ArticuloConteo_Periodo_Bien UNIQUE (FKIdPeriodoConteo_ALMA, FKIdTipoBien_ALMA)
)
GO

-- Índices para ArticuloConteo
CREATE INDEX IX_ArticuloConteo_Periodo ON ALMA.ArticuloConteo(FKIdPeriodoConteo_ALMA) 
    INCLUDE (FKIdTipoBien_ALMA, ExistenciaSistema, FKIdEstatus_ALMA, ConteosPendientes)

CREATE INDEX IX_ArticuloConteo_Estatus ON ALMA.ArticuloConteo(FKIdEstatus_ALMA, FKIdPeriodoConteo_ALMA) 
    INCLUDE (FKIdTipoBien_ALMA) 
    WHERE Activo = 1

CREATE INDEX IX_ArticuloConteo_Pendientes ON ALMA.ArticuloConteo(FKIdPeriodoConteo_ALMA) 
    WHERE ConteosPendientes > 0 AND Activo = 1
GO

-- =============================================
-- REGISTRO DE CONTEO (TABLA DE EVENTOS)
-- =============================================

CREATE TABLE ALMA.RegistroConteo (
    PKIdRegistroConteo INT IDENTITY(1,1) NOT NULL,
    FKIdArticuloConteo_ALMA INT NOT NULL,
    FKIdPeriodoConteo_ALMA INT NOT NULL,  -- Denormalizado para consultas rápidas
    FKIdSucursal_SIS INT NOT NULL,        -- Denormalizado para consultas rápidas
    
    -- Número de conteo (secuencial por artículo)
    NumeroConteo INT NOT NULL,  -- 1, 2, 3, 4... (secuencial por artículo)
    
    -- Resultado del conteo
    CantidadContada DECIMAL(18,4) NOT NULL,
    FechaConteo DATETIME2 NOT NULL,
    FKIdUsuario_SIS INT NOT NULL,
    
    -- Información adicional
    Observaciones NVARCHAR(500) NULL,
    EsReconteo BIT NOT NULL DEFAULT 0,  -- Indica si es un reconteo por discrepancia
    
    -- Evidencia (opcional)
    FotoPath NVARCHAR(500) NULL,
    
    -- Coordenadas (si usan dispositivos móviles)
    Latitud DECIMAL(9,6) NULL,
    Longitud DECIMAL(9,6) NULL,
    
    -- Auditoría
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    
    CONSTRAINT PK_RegistroConteo PRIMARY KEY (PKIdRegistroConteo),
    CONSTRAINT FK_RegistroConteo_Articulo FOREIGN KEY (FKIdArticuloConteo_ALMA) REFERENCES ALMA.ArticuloConteo(PKIdArticuloConteo),
    CONSTRAINT FK_RegistroConteo_Periodo FOREIGN KEY (FKIdPeriodoConteo_ALMA) REFERENCES ALMA.PeriodoConteo(PKIdPeriodoConteo),
    CONSTRAINT FK_RegistroConteo_Sucursal FOREIGN KEY (FKIdSucursal_SIS) REFERENCES SIS.Sucursal(PKIdSucursal),
    CONSTRAINT FK_RegistroConteo_Usuario FOREIGN KEY (FKIdUsuario_SIS) REFERENCES SIS.Usuario(PkIdUsuario),
    -- Un usuario no puede contar el mismo artículo dos veces en el mismo periodo
    CONSTRAINT UQ_RegistroConteo_Articulo_Usuario UNIQUE (FKIdArticuloConteo_ALMA, FKIdUsuario_SIS)
)
GO

-- Índices para RegistroConteo
CREATE INDEX IX_RegistroConteo_Articulo ON ALMA.RegistroConteo(FKIdArticuloConteo_ALMA, NumeroConteo) 
    INCLUDE (CantidadContada, FKIdUsuario_SIS, FechaConteo)

CREATE INDEX IX_RegistroConteo_Periodo ON ALMA.RegistroConteo(FKIdPeriodoConteo_ALMA) 
    INCLUDE (FKIdArticuloConteo_ALMA, CantidadContada, FKIdUsuario_SIS)

CREATE INDEX IX_RegistroConteo_Usuario ON ALMA.RegistroConteo(FKIdUsuario_SIS, FKIdPeriodoConteo_ALMA) 
    WHERE Activo = 1
GO

-- =============================================
-- HISTORIAL DE CAMBIOS DE ESTATUS
-- =============================================

CREATE TABLE ALMA.HistorialEstatusArticulo (
    PKIdHistorial INT IDENTITY(1,1) NOT NULL,
    FKIdArticuloConteo_ALMA INT NOT NULL,
    FKIdEstatusAnterior_ALMA INT NULL,
    FKIdEstatusNuevo_ALMA INT NOT NULL,
    FKIdRegistroConteo_ALMA INT NULL,  -- Opcional, si el cambio fue por un conteo
    Observaciones NVARCHAR(500) NULL,
    FKIdUsuario_SIS INT NOT NULL,
    FechaCambio DATETIME2 DEFAULT SYSDATETIME(),
    
    CONSTRAINT PK_HistorialEstatus PRIMARY KEY (PKIdHistorial),
    CONSTRAINT FK_Historial_Articulo FOREIGN KEY (FKIdArticuloConteo_ALMA) REFERENCES ALMA.ArticuloConteo(PKIdArticuloConteo),
    CONSTRAINT FK_Historial_EstatusAnterior FOREIGN KEY (FKIdEstatusAnterior_ALMA) REFERENCES ALMA.EstatusArticuloConteo(PKIdEstatusArticulo),
    CONSTRAINT FK_Historial_EstatusNuevo FOREIGN KEY (FKIdEstatusNuevo_ALMA) REFERENCES ALMA.EstatusArticuloConteo(PKIdEstatusArticulo),
    CONSTRAINT FK_Historial_Registro FOREIGN KEY (FKIdRegistroConteo_ALMA) REFERENCES ALMA.RegistroConteo(PKIdRegistroConteo),
    CONSTRAINT FK_Historial_Usuario FOREIGN KEY (FKIdUsuario_SIS) REFERENCES SIS.Usuario(PkIdUsuario)
)
GO

CREATE INDEX IX_Historial_Articulo ON ALMA.HistorialEstatusArticulo(FKIdArticuloConteo_ALMA, FechaCambio)
GO

-- =============================================
-- TABLA PARA DISCREPANCIAS (CUANDO HAY DIFERENCIAS)
-- =============================================

CREATE TABLE ALMA.DiscrepanciaConteo (
    PKIdDiscrepancia INT IDENTITY(1,1) NOT NULL,
    FKIdArticuloConteo_ALMA INT NOT NULL,
    
    -- Valores en disputa
    Valor1 DECIMAL(18,4) NOT NULL,
    Valor2 DECIMAL(18,4) NOT NULL,
    Valor3 DECIMAL(18,4) NULL,
    
    -- Resolución
    ValorAceptado DECIMAL(18,4) NULL,
    MetodoResolucion NVARCHAR(50) NULL,  -- 'Promedio', 'Decisión Supervisor', 'Nuevo Conteo'
    
    FKIdSupervisor_SIS INT NULL,
    FechaResolucion DATETIME2 NULL,
    ObservacionesResolucion NVARCHAR(500) NULL,
    
    -- Auditoría
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    
    CONSTRAINT PK_DiscrepanciaConteo PRIMARY KEY (PKIdDiscrepancia),
    CONSTRAINT FK_Discrepancia_Articulo FOREIGN KEY (FKIdArticuloConteo_ALMA) REFERENCES ALMA.ArticuloConteo(PKIdArticuloConteo),
    CONSTRAINT FK_Discrepancia_Supervisor FOREIGN KEY (FKIdSupervisor_SIS) REFERENCES SIS.Usuario(PkIdUsuario)
)
GO

-- =============================================
-- DATOS DE INICIALIZACIÓN
-- =============================================

-- Insertar Estatus de Periodo
INSERT INTO ALMA.EstatusPeriodo (Nombre, Descripcion) VALUES
('Pendiente', 'Periodo creado, pendiente de iniciar'),
('En Proceso', 'Periodo en curso con artículos siendo contados'),
('Completado', 'Todos los artículos han sido concluidos'),
('Cerrado', 'Periodo cerrado, no se permiten más modificaciones')
GO

-- Insertar Estatus de Artículo
INSERT INTO ALMA.EstatusArticuloConteo (Nombre, Descripcion, Orden) VALUES
('Pendiente 1er Conteo', 'Artículo listo para primer conteo', 1),
('Pendiente 2do Conteo', 'Primer conteo realizado, esperando segundo', 2),
('Pendiente 3er Conteo', 'Discrepancia, requiere tercer conteo', 3),
('Concluido Sin Diferencia', 'Conteos coinciden, sin diferencia', 4),
('Concluido Con Diferencia', 'Conteos finalizados con diferencia', 5),
('En Discrepancia', 'Requiere intervención de supervisor', 6)
GO

-- Insertar Tipos de Conteo
INSERT INTO ALMA.TipoConteo (Nombre, Descripcion) VALUES
('Cíclico', 'Conteo programado por rotación de inventario'),
('Anual', 'Conteo general de fin de año'),
('Auditoría', 'Conteo solicitado por auditoría'),
('Aleatorio', 'Conteo sorpresa sin programación')
GO

-- =============================================
-- PROCEDIMIENTOS ALMACENADOS
-- =============================================

-- SP para registrar un conteo (con lógica de negocio)
GO
CREATE OR ALTER PROCEDURE ALMA.sp_RegistrarConteo
    @PKIdArticuloConteo INT,
    @CantidadContada DECIMAL(18,4),
    @FKIdUsuario_SIS INT,
    @Observaciones NVARCHAR(500) = NULL,
    @Latitud DECIMAL(9,6) = NULL,
    @Longitud DECIMAL(9,6) = NULL,
    @FotoPath NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE @FKIdPeriodoConteo INT
    DECLARE @FKIdSucursal INT
    DECLARE @ConteosRealizados INT
    DECLARE @MaximoConteos INT
    DECLARE @ExistenciaSistema DECIMAL(18,4)
    DECLARE @EstatusActual INT
    DECLARE @NuevoEstatus INT
    DECLARE @NumeroConteo INT
    DECLARE @FechaActual DATETIME2 = GETDATE()
    
    BEGIN TRANSACTION
    
    BEGIN TRY
        -- Obtener información del artículo con bloqueo
        SELECT 
            @FKIdPeriodoConteo = ac.FKIdPeriodoConteo_ALMA,
            @FKIdSucursal = ac.FKIdSucursal_SIS,
            @ConteosRealizados = ac.ConteosRealizados,
            @ExistenciaSistema = ac.ExistenciaSistema,
            @EstatusActual = ac.FKIdEstatus_ALMA,
            @MaximoConteos = p.MaximoConteosPorArticulo
        FROM ALMA.ArticuloConteo ac WITH (UPDLOCK)
        INNER JOIN ALMA.PeriodoConteo p ON ac.FKIdPeriodoConteo_ALMA = p.PKIdPeriodoConteo
        WHERE ac.PKIdArticuloConteo = @PKIdArticuloConteo AND ac.Activo = 1
        
        -- Validaciones
        IF @EstatusActual IN (4, 5, 6) -- Concluido o en discrepancia
        BEGIN
            RAISERROR('Este artículo ya ha sido concluido', 16, 1)
            ROLLBACK
            RETURN
        END
        
        IF @ConteosRealizados >= @MaximoConteos
        BEGIN
            RAISERROR('Se alcanzó el máximo de conteos permitidos para este artículo', 16, 1)
            ROLLBACK
            RETURN
        END
        
        -- Verificar que el usuario no haya contado antes este artículo
        IF EXISTS (
            SELECT 1 FROM ALMA.RegistroConteo 
            WHERE FKIdArticuloConteo_ALMA = @PKIdArticuloConteo 
            AND FKIdUsuario_SIS = @FKIdUsuario_SIS
        )
        BEGIN
            RAISERROR('Este usuario ya realizó un conteo para este artículo', 16, 1)
            ROLLBACK
            RETURN
        END
        
        -- Determinar el número de conteo
        SET @NumeroConteo = @ConteosRealizados + 1
        
        -- Insertar el registro de conteo
        INSERT INTO ALMA.RegistroConteo (
            FKIdArticuloConteo_ALMA,
            FKIdPeriodoConteo_ALMA,
            FKIdSucursal_SIS,
            NumeroConteo,
            CantidadContada,
            FechaConteo,
            FKIdUsuario_SIS,
            Observaciones,
            Latitud,
            Longitud,
            FotoPath
        ) VALUES (
            @PKIdArticuloConteo,
            @FKIdPeriodoConteo,
            @FKIdSucursal,
            @NumeroConteo,
            @CantidadContada,
            @FechaActual,
            @FKIdUsuario_SIS,
            @Observaciones,
            @Latitud,
            @Longitud,
            @FotoPath
        )
        
        -- Actualizar contador en el artículo
        UPDATE ALMA.ArticuloConteo
        SET ConteosRealizados = @ConteosRealizados + 1,
            ConteosPendientes = CASE 
                WHEN @ConteosRealizados + 1 >= @MaximoConteos THEN 0
                ELSE 1
            END,
            FechaModificacion = @FechaActual,
            UsuarioModificacion = @FKIdUsuario_SIS
        WHERE PKIdArticuloConteo = @PKIdArticuloConteo
        
        -- Determinar el nuevo estatus basado en la lógica de negocio
        DECLARE @Conteos TABLE (Numero INT, Cantidad DECIMAL(18,4))
        
        INSERT INTO @Conteos
        SELECT NumeroConteo, CantidadContada
        FROM ALMA.RegistroConteo
        WHERE FKIdArticuloConteo_ALMA = @PKIdArticuloConteo
        ORDER BY NumeroConteo
        
        DECLARE @TotalConteos INT = (SELECT COUNT(*) FROM @Conteos)
        
        -- Lógica de negocio para determinar estatus
        IF @TotalConteos = 1
        BEGIN
            -- Primer conteo realizado, esperar segundo
            SET @NuevoEstatus = 2 -- Pendiente 2do Conteo
        END
        ELSE IF @TotalConteos = 2
        BEGIN
            -- Segundo conteo, verificar si coinciden
            DECLARE @Cantidad1 DECIMAL(18,4) = (SELECT Cantidad FROM @Conteos WHERE Numero = 1)
            DECLARE @Cantidad2 DECIMAL(18,4) = (SELECT Cantidad FROM @Conteos WHERE Numero = 2)
            
            IF @Cantidad1 = @Cantidad2
            BEGIN
                -- Coinciden, concluir sin diferencia
                SET @NuevoEstatus = 4 -- Concluido Sin Diferencia
                
                -- Actualizar valores finales
                UPDATE ALMA.ArticuloConteo
                SET ExistenciaFinal = @Cantidad1,
                    Diferencia = @Cantidad1 - @ExistenciaSistema,
                    PorcentajeDiferencia = CASE 
                        WHEN @ExistenciaSistema = 0 THEN 0
                        ELSE ((@Cantidad1 - @ExistenciaSistema) / @ExistenciaSistema) * 100
                    END,
                    FechaConclusion = @FechaActual,
                    FKIdUsuarioConcluyo_SIS = @FKIdUsuario_SIS
                WHERE PKIdArticuloConteo = @PKIdArticuloConteo
            END
            ELSE
            BEGIN
                -- No coinciden, verificar si podemos hacer tercer conteo
                IF @MaximoConteos >= 3
                BEGIN
                    SET @NuevoEstatus = 3 -- Pendiente 3er Conteo
                END
                ELSE
                BEGIN
                    -- No hay más conteos permitidos, pasa a discrepancia
                    SET @NuevoEstatus = 6 -- En Discrepancia
                    
                    -- Insertar en tabla de discrepancias
                    INSERT INTO ALMA.DiscrepanciaConteo (
                        FKIdArticuloConteo_ALMA,
                        Valor1,
                        Valor2,
                        FechaCreacion,
                        UsuarioCreacion
                    ) VALUES (
                        @PKIdArticuloConteo,
                        @Cantidad1,
                        @Cantidad2,
                        @FechaActual,
                        @FKIdUsuario_SIS
                    )
                END
            END
        END
        ELSE IF @TotalConteos = 3
        BEGIN
            -- Tercer conteo, determinar resultado
            DECLARE @Cant3 DECIMAL(18,4) = (SELECT Cantidad FROM @Conteos WHERE Numero = 3)
            DECLARE @ValorFinal DECIMAL(18,4)
            
            -- Buscar si alguna cantidad coincide
            IF @Cant3 = @Cantidad1 OR @Cant3 = @Cantidad2
            BEGIN
                -- Coincide con alguno anterior
                SET @ValorFinal = @Cant3
                SET @NuevoEstatus = 4 -- Concluido Sin Diferencia
            END
            ELSE IF @Cantidad1 = @Cantidad2
            BEGIN
                -- Los dos primeros coinciden, ese es el bueno
                SET @ValorFinal = @Cantidad1
                SET @NuevoEstatus = 4 -- Concluido Sin Diferencia
            END
            ELSE
            BEGIN
                -- Los tres son diferentes, pasa a discrepancia
                SET @NuevoEstatus = 6 -- En Discrepancia
                
                INSERT INTO ALMA.DiscrepanciaConteo (
                    FKIdArticuloConteo_ALMA,
                    Valor1,
                    Valor2,
                    Valor3,
                    FechaCreacion,
                    UsuarioCreacion
                ) VALUES (
                    @PKIdArticuloConteo,
                    @Cantidad1,
                    @Cantidad2,
                    @Cant3,
                    @FechaActual,
                    @FKIdUsuario_SIS
                )
            END
            
            IF @NuevoEstatus = 4 -- Si concluyó, actualizar valores finales
            BEGIN
                UPDATE ALMA.ArticuloConteo
                SET ExistenciaFinal = @ValorFinal,
                    Diferencia = @ValorFinal - @ExistenciaSistema,
                    PorcentajeDiferencia = CASE 
                        WHEN @ExistenciaSistema = 0 THEN 0
                        ELSE ((@ValorFinal - @ExistenciaSistema) / @ExistenciaSistema) * 100
                    END,
                    FechaConclusion = @FechaActual,
                    FKIdUsuarioConcluyo_SIS = @FKIdUsuario_SIS
                WHERE PKIdArticuloConteo = @PKIdArticuloConteo
            END
        END
        
        -- Actualizar el estatus si cambió
        IF @NuevoEstatus IS NOT NULL AND @NuevoEstatus != @EstatusActual
        BEGIN
            -- Guardar en historial
            INSERT INTO ALMA.HistorialEstatusArticulo (
                FKIdArticuloConteo_ALMA,
                FKIdEstatusAnterior_ALMA,
                FKIdEstatusNuevo_ALMA,
                FKIdRegistroConteo_ALMA,
                Observaciones,
                FKIdUsuario_SIS,
                FechaCambio
            ) VALUES (
                @PKIdArticuloConteo,
                @EstatusActual,
                @NuevoEstatus,
                SCOPE_IDENTITY(), -- Último registro de conteo insertado
                'Cambio automático por regla de negocio',
                @FKIdUsuario_SIS,
                @FechaActual
            )
            
            -- Actualizar artículo
            UPDATE ALMA.ArticuloConteo
            SET FKIdEstatus_ALMA = @NuevoEstatus
            WHERE PKIdArticuloConteo = @PKIdArticuloConteo
        END
        
        COMMIT TRANSACTION
        
        -- Retornar resultado
        SELECT 
            'Éxito' as Resultado,
            @NumeroConteo as ConteoRegistrado,
            (SELECT Nombre FROM ALMA.EstatusArticuloConteo WHERE PKIdEstatusArticulo = ISNULL(@NuevoEstatus, @EstatusActual)) as NuevoEstatus,
            CASE 
                WHEN @NuevoEstatus = 4 THEN 'Artículo concluido - Coincidencia'
                WHEN @NuevoEstatus = 5 THEN 'Artículo concluido con diferencia'
                WHEN @NuevoEstatus = 6 THEN 'Artículo en discrepancia - Requiere supervisor'
                WHEN @NuevoEstatus = 3 THEN 'Requiere tercer conteo'
                ELSE 'Conteo registrado exitosamente'
            END as Mensaje
            
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW
    END CATCH
END
GO

-- =============================================
-- VISTAS PARA REPORTES
-- =============================================

-- Vista de resumen por periodo
GO
CREATE OR ALTER VIEW ALMA.Vw_ResumenPeriodo AS
SELECT 
    p.PKIdPeriodoConteo,
    p.CodigoPeriodo,
    p.Nombre as Periodo,
    s.Nombre as Sucursal,
    tc.Nombre as TipoConteo,
    ep.Nombre as Estatus,
    p.FechaInicio,
    p.FechaFin,
    p.FechaCierre,
    p.TotalArticulos,
    p.ArticulosConcluidos,
    p.ArticulosConDiferencia,
    (p.TotalArticulos - ISNULL(p.ArticulosConcluidos, 0)) as ArticulosPendientes,
    COUNT(DISTINCT r.FKIdUsuario_SIS) as ContadoresParticiparon,
    COUNT(r.PKIdRegistroConteo) as TotalConteosRegistrados
FROM ALMA.PeriodoConteo p
INNER JOIN SIS.Sucursal s ON p.FKIdSucursal_SIS = s.PKIdSucursal
INNER JOIN ALMA.TipoConteo tc ON p.FKIdTipoConteo_ALMA = tc.PKIdTipoConteo
INNER JOIN ALMA.EstatusPeriodo ep ON p.FKIdEstatus_ALMA = ep.PKIdEstatusPeriodo
LEFT JOIN ALMA.RegistroConteo r ON p.PKIdPeriodoConteo = r.FKIdPeriodoConteo_ALMA
GROUP BY p.PKIdPeriodoConteo, p.CodigoPeriodo, p.Nombre, s.Nombre, tc.Nombre, 
         ep.Nombre, p.FechaInicio, p.FechaFin, p.FechaCierre, 
         p.TotalArticulos, p.ArticulosConcluidos, p.ArticulosConDiferencia
GO

-- Vista de detalle de artículos en conteo
CREATE OR ALTER VIEW ALMA.Vw_DetalleArticulos AS
SELECT 
    a.PKIdArticuloConteo,
    p.CodigoPeriodo,
    p.Nombre as Periodo,
    s.Nombre as Sucursal,
    tb.CodigoClave as CodigoArticulo,
    tb.Descripcion as Articulo,
    a.ExistenciaSistema,
    a.ExistenciaFinal,
    a.Diferencia,
    a.PorcentajeDiferencia,
    eac.Nombre as Estatus,
    a.ConteosRealizados,
    a.ConteosPendientes,
    a.FechaInicioConteo,
    a.FechaConclusion,
    u.Nombre + ' ' + u.ApellidoPaterno as ConcluidoPor,
    (SELECT STRING_AGG(CONCAT('Conteo', rc.NumeroConteo, ': ', rc.CantidadContada, ' (', uc.Nombre, ')'), ' | ') 
     FROM ALMA.RegistroConteo rc
     INNER JOIN SIS.Usuario uc ON rc.FKIdUsuario_SIS = uc.PkIdUsuario
     WHERE rc.FKIdArticuloConteo_ALMA = a.PKIdArticuloConteo) as HistorialConteos
FROM ALMA.ArticuloConteo a
INNER JOIN ALMA.PeriodoConteo p ON a.FKIdPeriodoConteo_ALMA = p.PKIdPeriodoConteo
INNER JOIN SIS.Sucursal s ON a.FKIdSucursal_SIS = s.PKIdSucursal
INNER JOIN ALMA.TipoBien tb ON a.FKIdTipoBien_ALMA = tb.PKIdTipoBien
INNER JOIN ALMA.EstatusArticuloConteo eac ON a.FKIdEstatus_ALMA = eac.PKIdEstatusArticulo
LEFT JOIN SIS.Usuario u ON a.FKIdUsuarioConcluyo_SIS = u.PkIdUsuario
WHERE a.Activo = 1
GO
