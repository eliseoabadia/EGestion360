

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


--drop table if exists [CONTA].[Partida]
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
	[Descripcion] [nvarchar](20) NOT NULL,
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


CREATE TABLE [ALMA].[TipoPatrimonio](
	[PKIdTipoPatrimonio] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](50) NOT NULL,
	-- Auditoría
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
     CONSTRAINT PK_TipoPatrimonio_Id PRIMARY KEY ([PKIdTipoPatrimonio])
     )


INSERT INTO [ALMA].[TipoPatrimonio] ([Descripcion],UsuarioCreacion) VALUES
('BIENES PROPIOS',1),
('ARRENDADOS',1),
('BIENES NO PERTENECIENTES AL INSTITUTO',1)
GO

--drop table [SIS].[TipoProveedor] if exists [SIS].[TipoProveedor]
CREATE TABLE [SIS].[TipoProveedor](
	[PkIdTipoProveedor] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](80) NOT NULL,
	-- Auditoría
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
     CONSTRAINT PK_TipoProveedor_Id PRIMARY KEY ([PkIdTipoProveedor])
     )

     INSERT INTO [SIS].[TipoProveedor] ([Descripcion],UsuarioCreacion) VALUES
    ('Fabricante',1),
    ('Distribuidor',1),
    ('MiPyME',1)
GO

CREATE TABLE [SIS].[EstatusProveedor](
	[PKIdEstatusProveedor] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](150) NOT NULL,
	[Color] [nvarchar](8) NULL,
	-- Auditoría
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
     CONSTRAINT PK_EstatusProveedor_Id PRIMARY KEY ([PKIdEstatusProveedor])
     )

 
INSERT INTO [SIS].[EstatusProveedor] (Descripcion,Color,UsuarioCreacion) values('Normal','#D3D3D3',1)
INSERT INTO [SIS].[EstatusProveedor] (Descripcion,Color,UsuarioCreacion) values('Validado','#CBE1E8',1)
INSERT INTO [SIS].[EstatusProveedor] (Descripcion,Color,UsuarioCreacion) values('Contrato Marco','#D1B7EA',1)
INSERT INTO [SIS].[EstatusProveedor] (Descripcion,Color,UsuarioCreacion) values('Inhabilitado','#F59494',1)



--drop table [SIS].[Proveedor] 
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
    -- Auditoría
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,

    CONSTRAINT PK_Proveedor_Id PRIMARY KEY ([PKIdProveedor]),

    CONSTRAINT FK_Proveedor_FkIdTipoProveedor FOREIGN KEY ([FkIdTipoProveedor_SIS]) REFERENCES [SIS].[TipoProveedor]([PkIdTipoProveedor]),
    CONSTRAINT FK_Proveedor_FKIdEstatusProveedor FOREIGN KEY ([FKIdEstatusProveedor_SIS]) REFERENCES [SIS].[EstatusProveedor]([PKIdEstatusProveedor]),
    CONSTRAINT FK_Proveedor_FKIdCuentaContable FOREIGN KEY ([FKIdCuentaContable_SIS]) REFERENCES CONTA.CuentaContable([PKIdCuentaContable]),
    CONSTRAINT FK_Proveedor_FKIdMunicipio FOREIGN KEY ([FKIdMunicipio_SIS]) REFERENCES SIS.Municipios([PKIdMunicipio]),
    CONSTRAINT FK_Proveedor_FKIdEstado FOREIGN KEY ([FKIdEstado_SIS]) REFERENCES SIS.Estados([PKIdEstado]),
    CONSTRAINT FK_Proveedor_FKIdPais FOREIGN KEY ([FKIdPais_SIS]) REFERENCES SIS.Paises([PKIdPais]),
    )

    -- Activar INSERT con IDs específicos
SET IDENTITY_INSERT [SIS].[Proveedor] ON

INSERT INTO [SIS].[Proveedor]
           ([PKIdProveedor]
           ,[FkIdTipoProveedor_SIS]
           ,[FKIdEstatusProveedor_SIS]
           ,[FKIdCuentaContable_SIS]
           ,[FKIdMunicipio_SIS]
           ,[FKIdEstado_SIS]
           ,[FKIdPais_SIS]
           --,[FKIdResponsable_SIS]
           --,[FKIdAESector_SIS]
           --,[FKIdAEDivision_SIS]
           --,[FKIdAEGrupo_SIS]
           --,[FKIdAEClase_SIS]
           ,[Nombre]
           ,[RFC]
           ,[Colonia]
           ,[CP]
           ,[Ciudad]
           ,[EMAIL]
           ,[Clave]
           ,[Calle]
           ,[Numero]
           ,[FechaAlta]
           ,[TelefonoInstitucional]
           ,[Notas]
           ,[PaginaWeb]
           ,[NumeroInt]
           ,[CURP]
           ,[Activo]
           ,[FechaCreacion]
           ,[UsuarioCreacion])
    SELECT p.[PK_IdProveedor]
      ,p.[Fk_IdTipoProveedor]
      ,p.[FK_IdEstatusProveedor]
      ,[FK_IdCuentaContable__SIS] = tp2.PKIdCuentaContable
      ,p.[FK_IdMunicipio__SIS]
      ,p.[FK_IdEstado__SIS]
      ,p.[FK_IdPais__SIS]
      --,[FK_IdResponsable__SIS]
      --,[FK_IdAESector__SIS]
      --,[FK_IdAEDivision__SIS]
      --,[FK_IdAEGrupo__SIS]
      --,[FK_IdAEClase__SIS]
      ,p.[Nombre]
      ,p.[RFC]
      ,p.[Colonia]
      ,p.[CP]
      ,p.[Ciudad]
      ,p.[EMAIL]
      ,p.[Clave]
      ,p.[Calle]
      ,p.[Numero]
      ,p.[FechaAlta]
      ,p.[TelefonoInstitucional]
      ,p.[Notas]
      ,p.[PaginaWeb]
      ,p.[NumeroInt]
      ,p.[CURP]
      ,p.[CT_LIVE]
      ,p.[CT_CreatedDate]
      ,p.[CT_CreatedBy]
  FROM [BD_PRESUPUESTO].[SIS].[Proveedor] p
  inner join [BD_PRESUPUESTO].[SIS].CuentaContable c on p.FK_IdCuentaContable__SIS = c.PK_IdCuentaContable
  inner join [GestionEmpresarial].CONTA.CuentaContable tp2 on c.Descripcion = tp2.Descripcion
  where [Fk_IdTipoProveedor] is not null and [FK_IdEstatusProveedor] is not null and [FK_IdEstado__SIS] is not null and [FK_IdPais__SIS] is not null
  and p.FK_IdMunicipio__SIS in (select PKIdMunicipio from sis.Municipios)

  -- Desactivar INSERT con IDs específicos
SET IDENTITY_INSERT [SIS].[Proveedor] OFF

--drop table [NOM].[Persona]
CREATE TABLE  [NOM].[Persona](
	[PKIdPersona] [int] IDENTITY(1,1) NOT NULL,
	[Clave] [nvarchar](15) NOT NULL,
	[Nombre] [nvarchar](50) NOT NULL,
	[Paterno] [nvarchar](50) NOT NULL,
	[Materno] [nvarchar](50) NOT NULL,
	[Telefono_particular] [nvarchar](15) NULL,
	[Telefono_movil] [nvarchar](15) NULL,
	[Fecha_de_Inicio] [datetime] NOT NULL,
	[Fecha_Fin] [datetime] NULL,
	[RFC] [nvarchar](15) NOT NULL,
	[Curp] [nvarchar](18) NOT NULL,
	[FechaNacimiento] [datetime] NOT NULL,
	[Sexo] [nvarchar](10) NULL,
	[ESTADO_CIVIL] [nvarchar](20) NULL,
	[Municipio] [nvarchar](20) NULL,
	[REG_IMSS] [nvarchar](12) NULL,
	[NoCartilla] [nvarchar](16) NULL,
	[NoLicencia] [nvarchar](16) NULL,
	[NoPasaporte] [nvarchar](16) NULL,
	[NoCredencialElector] [nvarchar](32) NULL,
	[Calle] [nvarchar](40) NULL,
	[Num_exterior] [nvarchar](10) NULL,
	[Num_interior] [nvarchar](10) NULL,
	[Colonia] [nvarchar](40) NULL,
	[CP] [nvarchar](6) NULL,
	[Estado] [nvarchar](30) NULL,
	[CORREO_ELECTRONICO] [nvarchar](250) NULL,
	[TIPO_CONTRATACION] [nvarchar](50) NULL,
	[PUESTO] [nvarchar](100) NULL,
	[SUELDO_BASE] [float] NULL,
	[COMPENSACION_GARANTIZADA] [float] NULL,
	[BANCO] [nvarchar](100) NULL,
	[NUMERO_CUENTA] [nvarchar](25) NULL,
	[CLABE] [nvarchar](50) NULL,
	-- Auditoría
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Persona_Id PRIMARY KEY ([PKIdPersona]),
    )


    SET IDENTITY_INSERT [NOM].[Persona] ON

INSERT INTO [NOM].[Persona]
           ([PKIdPersona]
           ,[Clave]
           ,[Nombre]
           ,[Paterno]
           ,[Materno]
           ,[Telefono_particular]
           ,[Telefono_movil]
           ,[Fecha_de_Inicio]
           ,[Fecha_Fin]
           ,[RFC]
           ,[Curp]
           ,[FechaNacimiento]
           ,[Sexo]
           ,[ESTADO_CIVIL]
           ,[Municipio]
           ,[REG_IMSS]
           ,[NoCartilla]
           ,[NoLicencia]
           ,[NoPasaporte]
           ,[NoCredencialElector]
           ,[Calle]
           ,[Num_exterior]
           ,[Num_interior]
           ,[Colonia]
           ,[CP]
           ,[Estado]
           ,[CORREO_ELECTRONICO]
           ,[TIPO_CONTRATACION]
           ,[PUESTO]
           ,[SUELDO_BASE]
           ,[COMPENSACION_GARANTIZADA]
           ,[BANCO]
           ,[NUMERO_CUENTA]
           ,[CLABE]
           ,[Activo]
           ,[FechaCreacion]
           ,[UsuarioCreacion])
    SELECT [PK_IdPersona]
      ,[Clave]
      ,[Nombre]
      ,[Paterno]
      ,[Materno]
      ,[Telefono_particular]
      ,[Telefono_movil]
      ,[Fecha_de_Inicio]
      ,[Fecha_Fin]
      ,[RFC]
      ,[Curp]
      ,[FechaNacimiento]
      ,[Sexo]
      ,[ESTADO_CIVIL]
      ,[Municipio]
      ,[REG_IMSS]
      ,[NoCartilla]
      ,[NoLicencia]
      ,[NoPasaporte]
      ,[NoCredencialElector]
      ,[Calle]
      ,[Num_exterior]
      ,[Num_interior]
      ,[Colonia]
      ,[CP]
      ,[Estado]
      ,[CORREO_ELECTRONICO]
      ,[TIPO_CONTRATACION]
      ,[PUESTO]
      ,[SUELDO_BASE]
      ,[COMPENSACION_GARANTIZADA]
      ,[BANCO]
      ,[NUMERO_CUENTA]
      ,[CLABE]
      ,[CT_LIVE]
      ,[CT_CreatedDate]
      ,[CT_CreatedBy]
  FROM [BD_PRESUPUESTO].[RHCT].[Persona]

  -- Desactivar INSERT con IDs específicos
SET IDENTITY_INSERT [NOM].[Persona] OFF


GO


--drop table [SIS].[Area]
CREATE TABLE [SIS].[Area](
	[PKIdArea] [int] IDENTITY(1,1) NOT NULL,
	[FKIdArea_SIS] [int] NULL,
	--[FK_IdPersona__RHCT] [int] NULL,
	[FKIdAreaDocto_SIS] [int]  NULL,
	[Clave] [nvarchar](15) NOT NULL,
	[Nombre] [nvarchar](200) NOT NULL,
	[UltimoInv] [datetime] NULL,
	[ZonaEconomica] [nvarchar](100) NULL,
	[Direccion] [nvarchar](64) NULL,
	[Colonia] [nvarchar](64) NULL,
	[CP] [nvarchar](5) NULL,
	[Telefono] [nvarchar](32) NULL,
	--[FL_Foto] [nvarchar](max) NULL,
	--[IM_Foto] [image] NULL,
	[Aprovado] BIT NOT NULL DEFAULT 01,
	-- Auditoría
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,

    CONSTRAINT PK_Area_Id PRIMARY KEY ([PKIdArea]),

    CONSTRAINT FK_Area_FKIdArea FOREIGN KEY ([FKIdArea_SIS]) REFERENCES [SIS].[Area]([PKIdArea])
    )

    SET IDENTITY_INSERT [SIS].[Area] ON

-- Insertar los datos manteniendo el ID original
INSERT INTO [SIS].[Area] (
    [PKIdArea]
      ,[FKIdArea_SIS]
      --,[FK_IdAreaDocto__SIS]
      ,[Clave]
      ,[Nombre]
      ,[UltimoInv]
      ,[ZonaEconomica]
      ,[Direccion]
      ,[Colonia]
      ,[CP]
      ,[Telefono]
      ,[Aprovado]
      ,[Activo]
      ,[FechaCreacion]
      ,[UsuarioCreacion]
)
SELECT 
    [PK_IdArea]
      ,[FK_IdArea__SIS]
      ,[Clave]
      ,[Nombre]
      --,[FK_IdPersona__RHCT]
      --,[FK_IdAreaDocto__SIS]
      ,[UltimoInv]
      ,[ZonaEconomica]
      ,[Direccion]
      ,[Colonia]
      ,[CP]
      ,[Telefono]
      --,[FL_Foto]
      --,[IM_Foto]
      ,[Aprovado]
      ,[CT_LIVE]
      ,[CT_CreatedDate]
      ,[CT_CreatedBy]
FROM [BD_PRESUPUESTO].[SIS].[Area]

-- Desactivar INSERT con IDs específicos
SET IDENTITY_INSERT [SIS].[Area] OFF

    GO
    --drop table [NOM].[PersonaArea]
    CREATE TABLE [NOM].[PersonaArea](
	[PKIdPersonaArea] [int] IDENTITY(1,1) NOT NULL,
	[FKIdPersona_NOM] [int] NOT NULL,
	[FKIdArea_SIS] [int] NOT NULL,
	[IsAdscrito] [bit] NOT NULL,
	[EsSolicitante] [bit] NULL,
	[EsAutorizador] [bit] NULL,
	-- Auditoría
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_PKIdPersonaArea_Id PRIMARY KEY ([PKIdPersonaArea]),

    CONSTRAINT FK_PersonaArea_FKIdPersona FOREIGN KEY ([FKIdPersona_NOM]) REFERENCES [NOM].[Persona]([PKIdPersona]),
    CONSTRAINT FK_PersonaArea_FKIdArea FOREIGN KEY ([FKIdArea_SIS]) REFERENCES [SIS].[Area]([PKIdArea])
    )

    -- Insertar los datos manteniendo el ID original
    SET IDENTITY_INSERT [NOM].[PersonaArea] ON

INSERT INTO [NOM].[PersonaArea] (
    [PKIdPersonaArea]
      ,[FKIdPersona_NOM]
      ,[FKIdArea_SIS]
      ,[IsAdscrito]
      ,[EsSolicitante]
      ,[EsAutorizador]
      ,[Activo]
      ,[FechaCreacion]
      ,[UsuarioCreacion]
)
SELECT [PK_IdPersonaArea]
      ,[FK_IdPersona]
      ,[FK_IdArea]
      ,[IsAdscrito]
      ,[EsSolicitante]
      ,[EsAutorizador]
      ,[CT_LIVE]
      ,[CT_CreatedDate]
      ,[CT_CreatedBy]
FROM [BD_PRESUPUESTO].[RHCT].[PersonaArea]

-- Desactivar INSERT con IDs específicos
SET IDENTITY_INSERT [NOM].[PersonaArea] OFF

GO

-------------------------------------- marca -------------------------------------- 
CREATE TABLE [ALMA].[Marca](
	[PKIdMarca] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](50) NOT NULL,
	-- Auditoría
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Marca_Id PRIMARY KEY ([PKIdMarca]),
)

  -- Insertar los datos manteniendo el ID original
    SET IDENTITY_INSERT [ALMA].[Marca] ON

    INSERT INTO [ALMA].[Marca] (
        [PKIdMarca]
        ,[Descripcion]
        ,[Activo]
        ,[UsuarioCreacion]
        ,[FechaCreacion]
    )
    SELECT [PK_IdMarca]
          ,[Descripcion]
          ,[CT_LIVE]
          ,[CT_CreatedBy]
          ,[CT_CreatedDate]
    FROM [BD_PRESUPUESTO].[SICOP].[Marca]

    -- Desactivar INSERT con IDs específicos
    SET IDENTITY_INSERT [ALMA].[Marca] OFF
-------------------------------------- EstadoBien --------------------------------------

CREATE TABLE [ALMA].[EstadoBien](
    [PKIdEstadoBien] [int] IDENTITY(1,1) NOT NULL,
    [DESCRIPCION_GENERAL] [nvarchar](150) NOT NULL,
	[DESCRIPCION_ESPECIFICA] [nvarchar](200) NOT NULL,
	[DESCRIPCION_CORTA] [nvarchar](100) NOT NULL,
    -- Auditoría
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_EstadoBien_Id PRIMARY KEY ([PKIdEstadoBien]),
)
  -- Insertar los datos manteniendo el ID original
SET IDENTITY_INSERT [ALMA].[EstadoBien] ON
    INSERT INTO [ALMA].[EstadoBien] (
        [PKIdEstadoBien]
        ,[DESCRIPCION_GENERAL]
        ,[DESCRIPCION_ESPECIFICA]
        ,[DESCRIPCION_CORTA]
        ,[Activo]
        ,[UsuarioCreacion]
        ,[FechaCreacion]
    )
    SELECT [PK_IdEstadoBien]
          ,[DESCRIPCION_GENERAL]
          ,[DESCRIPCION_ESPECIFICA]
          ,[DESCRIPCION_CORTA]
          ,[CT_LIVE]
          ,[CT_CreatedBy]
          ,[CT_CreatedDate]
    FROM [BD_PRESUPUESTO].[SICOP].[EstadoBien]
    -- Desactivar INSERT con IDs específicos
    SET IDENTITY_INSERT [ALMA].[EstadoBien] OFF

-------------------------------------- Material --------------------------------------
CREATE TABLE [ALMA].[Material](
    [PKIdMaterial] [int] IDENTITY(1,1) NOT NULL,
    [Descripcion] [nvarchar](50) NOT NULL,
    -- Auditoría
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Material_Id PRIMARY KEY ([PKIdMaterial]),
)
  -- Insertar los datos manteniendo el ID original
    SET IDENTITY_INSERT [ALMA].[Material] ON
    INSERT INTO [ALMA].[Material] (
        [PKIdMaterial]
        ,[Descripcion]
        ,[Activo]
        ,[UsuarioCreacion]
        ,[FechaCreacion]
    )
    SELECT [PK_IdMaterial]
          ,[Descripcion]
          ,[CT_LIVE]
          ,[CT_CreatedBy]
          ,[CT_CreatedDate]
    FROM [BD_PRESUPUESTO].[SICOP].[Material]
    -- Desactivar INSERT con IDs específicos
    SET IDENTITY_INSERT [ALMA].[Material] OFF

-------------------------------------- TipoAdquisicion --------------------------------------
CREATE TABLE [ALMA].[TipoAdquisicion](
    [PKIdTipoAdq] [int] IDENTITY(1,1) NOT NULL,
    [Clave] [nvarchar](10) NOT NULL,
	[Descripcion] [nvarchar](100) NOT NULL,
	[Descripmovto] [nvarchar](100) NOT NULL,
    -- Auditoría
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_TipoAdq_Id PRIMARY KEY ([PKIdTipoAdq]),
)
  -- Insertar los datos manteniendo el ID original
    SET IDENTITY_INSERT [ALMA].[TipoAdquisicion] ON
    INSERT INTO [ALMA].[TipoAdquisicion] (
        [PKIdTipoAdq]
        , [Clave]
          ,[Descripcion]
          ,[Descripmovto]
        ,[Activo]
        ,[UsuarioCreacion]
        ,[FechaCreacion]
    )
    SELECT [PK_IdTipoAdq]
          , [Clave]
          ,[Descripcion]
          ,[Descripmovto]
          ,[CT_LIVE]
          ,[CT_CreatedBy]
          ,[CT_CreatedDate]
    FROM [BD_PRESUPUESTO].[SICOP].[TipoAdq]
    -- Desactivar INSERT con IDs específicos
    SET IDENTITY_INSERT [ALMA].[TipoAdquisicion] OFF

-------------------------------------- Bien --------------------------------------
--select distinct FK_IdProveedor__SIS from [BD_PRESUPUESTO].sicop.Bien
--update [BD_PRESUPUESTO].sicop.Bien set FK_IdProveedor__SIS = 2 where FK_IdProveedor__SIS <> 1 
--select * from SIS.Proveedor where pkidproveedor in (156,1)

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
	--[FK_IdAreaUlt__SIS] [int] NULL,

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
	--[FK_IdPersona__RHCT] [int] NULL,
	[Ubicacion] [nvarchar](50) NULL,
	[AAdquisicion] [nvarchar](2) NULL,
	--[FL_FOTO] [nvarchar](1000) NULL,
	--[FK_IdColor__SICOP] [int] NULL,
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
	--[FL_Factura] [nvarchar](1000) NULL,
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
    -- Auditoría
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,

    CONSTRAINT PK_Bien_IdBien PRIMARY KEY ([PKIdBien]),

    CONSTRAINT FK_Bien_IdGrupoBien FOREIGN KEY ([FKIdGrupoBien_ALMA]) REFERENCES [ALMA].[GrupoBien]([PKIdGrupoBien]),
    CONSTRAINT FK_Bien_IdTipoBien FOREIGN KEY ([FKIdTipoBien_ALMA]) REFERENCES [ALMA].[TipoBien]([PKIdTipoBien]),
    CONSTRAINT FK_Bien_IdArea FOREIGN KEY ([FKIdArea_SIS]) REFERENCES [SIS].[Area]([PKIdArea]),
    CONSTRAINT FK_Bien_IdProveedor FOREIGN KEY ([FKIdProveedor_SIS]) REFERENCES [SIS].[Proveedor]([PKIdProveedor]),
    CONSTRAINT FK_Bien_IdEstadoBien FOREIGN KEY ([FKIdEstadoBien_ALMA]) REFERENCES [ALMA].[EstadoBien]([PKIdEstadoBien]),
    CONSTRAINT FK_Bien_IdTipoPatrimonio FOREIGN KEY ([FKIdTipoPatrimonio_ALMA]) REFERENCES [ALMA].[TipoPatrimonio]([PKIdTipoPatrimonio]),
    CONSTRAINT FK_Bien_IdMarca FOREIGN KEY ([FKIdMarca_ALMA]) REFERENCES [ALMA].[Marca]([PKIdMarca]),
    CONSTRAINT FK_Bien_IdMaterial FOREIGN KEY ([FKIdMaterial_ALMA]) REFERENCES [ALMA].[Material]([PKIdMaterial]),
    CONSTRAINT FK_Bien_TipoAdquisicion FOREIGN KEY ([FKIdTipoAdq_ALMA]) REFERENCES [ALMA].[TipoAdquisicion]([PKIdTipoAdq]),
    CONSTRAINT FK_Bien_Partida FOREIGN KEY ([FKIdPartida_CONTA]) REFERENCES [CONTA].[Partida]([PKIdPartida])
        
    )

    -- Insertar los datos manteniendo el ID original
     SET IDENTITY_INSERT [ALMA].[Bien] ON
        INSERT INTO [ALMA].[Bien] (
            [PKIdBien]        ,[FKIdGrupoBien_ALMA]        ,[FKIdTipoBien_ALMA]        ,[FKIdArea_SIS]        ,[FKIdProveedor_SIS]        ,[FKIdEstadoBien_ALMA]
            ,[FKIdTipoPatrimonio_ALMA]        ,[FKIdMarca_ALMA]        ,[FKIdMaterial_ALMA]        ,[FKIdTipoAdq_ALMA]        ,[FKIdPartida_CONTA]
            --,[FK_IdDetalleOrdenCompra_ORCO]
            --,[FK_IdAreaUlt__SIS]
            ,[Clave]        ,[ClaveAnt]        ,[Descripcion]        ,[Modelo]        ,[Serie]        ,[Requisicion]        ,[Factura]        ,[Costo]
            ,[FechaAdq]        ,[Referencia]        ,[Notas]
            --,[FK_IdPersona__RHCT] 
            ,[Ubicacion]        ,[AAdquisicion]
            --,[FL_FOTO]
            --,[FK_IdColor__SICOP]
            ,[Frente]    ,[Fondo]    ,[Altura]    ,[Diametro]    ,[VerificacionesDias]    ,[MantenimientoDias]    ,[Mantenimiento]    ,[Calibracion]    ,[Rango] ,[Resolucion]    ,[FechaUltInv]    ,[FechaReqscn]
        --,[FL_Factura]
        ,[Estatus]    ,[Caracteristicas]    ,[Resguardo]    ,[ResguardoAnterior]    ,[RelId]    ,[ValorRescate]    ,[ValorActual]    ,[Antiguedad],  [Progresivo]
        ,[Consecutivo]    ,[ClaveHist]    ,[EstaResguardado]    ,[FechaResguardado]    ,[Localizado]    ,[esContabilizado]    ,[Activo]    ,[FechaCreacion]    ,[UsuarioCreacion]
            )
            SELECT [PK_IdBien]            ,[FK_IdGrupoBien__SICOP]            ,[FK_IdTipoBien__SICOP]            ,[FK_IdAreaUlt__SIS]            ,[FK_IdProveedor__SIS]            ,[FK_IdEstadoBien__SICOP]
            ,[FK_IdTipoPatrimonio__SICOP]            ,[FK_IdMarca__SICOP]            ,[FK_IdMaterial__SICOP]            ,[FK_IdTipoAdq__SICOP]            ,[FK_IdPartida__SIS]
            --,[FK_IdDetalleOrdenCompra]
            --,[FK_IdAreaUlt__SIS]
            ,[Clave]            ,[ClaveAnt]            ,[Descripcion]            ,[Modelo]            ,[Serie]            ,[Requisicion]            ,[Factura]            ,[Costo]
            ,[FechaAdq]            ,[Referencia]            ,[Notas]
            --,[FK_IdPersona__RHCT]
            ,[Ubicacion]            ,[AAdquisicion]
            --,[FL_FOTO]
            --,[FK_IdColor__SICOP]
            ,[Frente]    ,[Fondo]    ,[Altura]    ,[Diametro]    ,[VerificacionesDias]    ,[MantenimientoDias]    ,[Mantenimiento]    ,[Calibracion]    ,[Rango]    ,[Resolucion]    ,[FechaUltInv]    ,[FechaReqscn]
            --,[FL_Factura]
            ,[Estatus]    ,[Caracteristicas]    ,[Resguardo]    ,[ResguardoAnterior]    ,[RelId]    ,[ValorRescate]    ,[ValorActual]    ,[Antiguedad]    ,[Progresivo]
            ,[Consecutivo]    ,[ClaveHist]    ,[EstaResguardado]    ,[FechaResguardado]    ,[Localizado]    ,[esContabilizado]    ,[CT_LIVE]    ,[CT_CreatedDate]    ,[CT_CreatedBy]
            FROM [BD_PRESUPUESTO].[SICOP].[Bien]
            where FK_IdPartida__SIS in (select PKIdPartida from CONTA.Partida)
            and FK_IdProveedor__SIS in (select PKIdProveedor from SIS.Proveedor)
            AND FK_IdTipoBien__SICOP in (select PKIdTipoBien from ALMA.TipoBien)
            -- Desactivar INSERT con IDs específicos
    SET IDENTITY_INSERT [ALMA].[Bien] OFF



