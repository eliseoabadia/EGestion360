USE [GestionEmpresarial];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF SCHEMA_ID(N'PBR') IS NULL
    EXEC(N'CREATE SCHEMA PBR AUTHORIZATION dbo;');
GO

IF OBJECT_ID(N'PBR.MigracionMap', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.MigracionMap
    (
        EntidadOrigen sysname NOT NULL,
        IdOrigen int NOT NULL,
        EntidadDestino nvarchar(256) NOT NULL,
        IdDestino int NOT NULL,
        Clave nvarchar(100) NULL,
        Descripcion nvarchar(1000) NULL,
        FechaMigracion datetime2(7) NOT NULL CONSTRAINT DF_PBR_MigracionMap_Fecha DEFAULT sysdatetime(),
        CONSTRAINT PK_PBR_MigracionMap PRIMARY KEY (EntidadOrigen, IdOrigen)
    );
END;
GO

IF OBJECT_ID(N'PBR.AlertaConfig', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[AlertaConfig]
    (
        [PKIdAlertaConfig] int IDENTITY(1,1) NOT NULL,
        [FKIdProgramaPresupuestario_PBR] int NOT NULL,
        [FKIdIndicador_PBR] int NULL,
        [Nombre] nvarchar(400) NOT NULL,
        [Tipo] nvarchar(20) NOT NULL CONSTRAINT [DF_PBR_AlertaConfig_Tipo] DEFAULT ('WARNING'),
        [Umbral] decimal(5,2) NOT NULL CONSTRAINT [DF_PBR_AlertaConfig_Umbral] DEFAULT ((80.0)),
        [Direccion] nvarchar(20) NOT NULL CONSTRAINT [DF_PBR_AlertaConfig_Direccion] DEFAULT ('BAJO'),
        [Activa] bit NOT NULL CONSTRAINT [DF_PBR_AlertaConfig_Activa] DEFAULT ((1)),
        [UltimaRevision] datetime2(7) NULL,
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_AlertaConfig_FechaCreacion] DEFAULT (getdate()),
        [FechaModificacion] datetime2(7) NULL,
        CONSTRAINT [PK_PBR_AlertaConfig] PRIMARY KEY ([PKIdAlertaConfig])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[AlertaConfig])
BEGIN
    SET IDENTITY_INSERT PBR.[AlertaConfig] ON;
    INSERT INTO PBR.[AlertaConfig] ([PKIdAlertaConfig], [FKIdProgramaPresupuestario_PBR], [FKIdIndicador_PBR], [Nombre], [Tipo], [Umbral], [Direccion], [Activa], [UltimaRevision], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdAlertaConfig], [FKIdProgramaPresupuestario_PBR], [FKIdIndicador_PBR], [Nombre], [Tipo], [Umbral], [Direccion], [Activa], [UltimaRevision], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[AlertaConfig];
    SET IDENTITY_INSERT PBR.[AlertaConfig] OFF;
END;
GO

IF OBJECT_ID(N'PBR.AuditoriaCambio', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[AuditoriaCambio]
    (
        [PKIdAuditoria] int IDENTITY(1,1) NOT NULL,
        [Entidad] nvarchar(200) NOT NULL,
        [EntidadId] nvarchar(200) NOT NULL,
        [Accion] nvarchar(20) NOT NULL,
        [FKIdUsuario_PBR] int NULL,
        [Cambios] nvarchar(max) NULL,
        [Ip] nvarchar(100) NULL,
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_AuditoriaCambio_FechaCreacion] DEFAULT (getdate()),
        CONSTRAINT [PK_PBR_AuditoriaCambio] PRIMARY KEY ([PKIdAuditoria])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[AuditoriaCambio])
BEGIN
    SET IDENTITY_INSERT PBR.[AuditoriaCambio] ON;
    INSERT INTO PBR.[AuditoriaCambio] ([PKIdAuditoria], [Entidad], [EntidadId], [Accion], [FKIdUsuario_PBR], [Cambios], [Ip], [FechaCreacion])
    SELECT [PKIdAuditoria], [Entidad], [EntidadId], [Accion], [FKIdUsuario_PBR], [Cambios], [Ip], [FechaCreacion]
    FROM [GE_Datos].PBR.[AuditoriaCambio];
    SET IDENTITY_INSERT PBR.[AuditoriaCambio] OFF;
END;
GO

IF OBJECT_ID(N'PBR.ConfiguracionSistema', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[ConfiguracionSistema]
    (
        [PKIdConfiguracion] int IDENTITY(1,1) NOT NULL,
        [Clave] nvarchar(100) NOT NULL,
        [Valor] nvarchar(1000) NOT NULL,
        [Tipo] nvarchar(20) NOT NULL CONSTRAINT [DF_PBR_ConfiguracionSistema_Tipo] DEFAULT ('STRING'),
        [Descripcion] nvarchar(1000) NULL,
        [Modulo] nvarchar(60) NOT NULL CONSTRAINT [DF_PBR_ConfiguracionSistema_Modulo] DEFAULT ('GENERAL'),
        [Activo] bit NOT NULL CONSTRAINT [DF_PBR_ConfiguracionSistema_Activo] DEFAULT ((1)),
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_ConfiguracionSistema_FechaCreacion] DEFAULT (getdate()),
        [FechaModificacion] datetime2(7) NULL,
        CONSTRAINT [PK_PBR_ConfiguracionSistema] PRIMARY KEY ([PKIdConfiguracion]),
        CONSTRAINT [UQ_PBR_ConfiguracionSistema_Clave] UNIQUE ([Clave])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[ConfiguracionSistema])
BEGIN
    SET IDENTITY_INSERT PBR.[ConfiguracionSistema] ON;
    INSERT INTO PBR.[ConfiguracionSistema] ([PKIdConfiguracion], [Clave], [Valor], [Tipo], [Descripcion], [Modulo], [Activo], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdConfiguracion], [Clave], [Valor], [Tipo], [Descripcion], [Modulo], [Activo], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[ConfiguracionSistema];
    SET IDENTITY_INSERT PBR.[ConfiguracionSistema] OFF;
END;
GO

IF OBJECT_ID(N'PBR.Notificacion', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[Notificacion]
    (
        [PKIdNotificacion] int IDENTITY(1,1) NOT NULL,
        [FKIdUsuario_PBR] int NOT NULL,
        [Tipo] nvarchar(20) NOT NULL CONSTRAINT [DF_PBR_Notificacion_Tipo] DEFAULT ('INFO'),
        [Titulo] nvarchar(400) NOT NULL,
        [Mensaje] nvarchar(1000) NOT NULL,
        [Link] nvarchar(1000) NULL,
        [Leida] bit NOT NULL CONSTRAINT [DF_PBR_Notificacion_Leida] DEFAULT ((0)),
        [InformeId] nvarchar(200) NULL,
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_Notificacion_FechaCreacion] DEFAULT (getdate()),
        CONSTRAINT [PK_PBR_Notificacion] PRIMARY KEY ([PKIdNotificacion])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[Notificacion])
BEGIN
    SET IDENTITY_INSERT PBR.[Notificacion] ON;
    INSERT INTO PBR.[Notificacion] ([PKIdNotificacion], [FKIdUsuario_PBR], [Tipo], [Titulo], [Mensaje], [Link], [Leida], [InformeId], [FechaCreacion])
    SELECT [PKIdNotificacion], [FKIdUsuario_PBR], [Tipo], [Titulo], [Mensaje], [Link], [Leida], [InformeId], [FechaCreacion]
    FROM [GE_Datos].PBR.[Notificacion];
    SET IDENTITY_INSERT PBR.[Notificacion] OFF;
END;
GO

IF OBJECT_ID(N'PBR.Anteproyecto', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[Anteproyecto]
    (
        [PKIdAnteproyecto] int IDENTITY(1,1) NOT NULL,
        [FKIdProgramaPresupuestario_PBR] int NOT NULL,
        [Anio] int NOT NULL,
        [MontoSolicitado] decimal(18,2) NOT NULL,
        [MontoAutorizado] decimal(18,2) NULL,
        [Estatus] nvarchar(20) NOT NULL CONSTRAINT [DF_PBR_Anteproyecto_Estatus] DEFAULT ('BORRADOR'),
        [Justificacion] nvarchar(500) NULL,
        [Observaciones] nvarchar(500) NULL,
        [FKIdUsuario_PBR] int NOT NULL,
        [FKIdPresupuestoPrograma_PBR] int NULL,
        [FKIdMirVersion_PBR] int NULL,
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_Anteproyecto_FechaCreacion] DEFAULT (getdate()),
        [FechaModificacion] datetime2(7) NULL,
        CONSTRAINT [PK_PBR_Anteproyecto] PRIMARY KEY ([PKIdAnteproyecto])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[Anteproyecto])
BEGIN
    SET IDENTITY_INSERT PBR.[Anteproyecto] ON;
    INSERT INTO PBR.[Anteproyecto] ([PKIdAnteproyecto], [FKIdProgramaPresupuestario_PBR], [Anio], [MontoSolicitado], [MontoAutorizado], [Estatus], [Justificacion], [Observaciones], [FKIdUsuario_PBR], [FKIdPresupuestoPrograma_PBR], [FKIdMirVersion_PBR], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdAnteproyecto], [FKIdProgramaPresupuestario_PBR], [Anio], [MontoSolicitado], [MontoAutorizado], [Estatus], [Justificacion], [Observaciones], [FKIdUsuario_PBR], [FKIdPresupuestoPrograma_PBR], [FKIdMirVersion_PBR], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[Anteproyecto];
    SET IDENTITY_INSERT PBR.[Anteproyecto] OFF;
END;
GO

IF OBJECT_ID(N'PBR.Aprobacion', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[Aprobacion]
    (
        [PKIdAprobacion] int IDENTITY(1,1) NOT NULL,
        [WorkflowCodigo] nvarchar(30) NOT NULL,
        [EntidadId] nvarchar(100) NOT NULL,
        [EstadoAnterior] nvarchar(30) NULL,
        [EstadoNuevo] nvarchar(30) NOT NULL,
        [Comentario] nvarchar(500) NULL,
        [FKIdUsuario_PBR] int NOT NULL,
        [FirmaHash] nvarchar(200) NULL,
        [Ip] nvarchar(50) NULL,
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_Aprobacion_FechaCreacion] DEFAULT (getdate()),
        CONSTRAINT [PK_PBR_Aprobacion] PRIMARY KEY ([PKIdAprobacion])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[Aprobacion])
BEGIN
    SET IDENTITY_INSERT PBR.[Aprobacion] ON;
    INSERT INTO PBR.[Aprobacion] ([PKIdAprobacion], [WorkflowCodigo], [EntidadId], [EstadoAnterior], [EstadoNuevo], [Comentario], [FKIdUsuario_PBR], [FirmaHash], [Ip], [FechaCreacion])
    SELECT [PKIdAprobacion], [WorkflowCodigo], [EntidadId], [EstadoAnterior], [EstadoNuevo], [Comentario], [FKIdUsuario_PBR], [FirmaHash], [Ip], [FechaCreacion]
    FROM [GE_Datos].PBR.[Aprobacion];
    SET IDENTITY_INSERT PBR.[Aprobacion] OFF;
END;
GO

IF OBJECT_ID(N'PBR.ArbolNodo', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[ArbolNodo]
    (
        [PKIdArbolNodo] int IDENTITY(1,1) NOT NULL,
        [FKIdDiagnostico_PBR] int NOT NULL,
        [Tipo] nvarchar(20) NOT NULL,
        [FKIdArbolNodo_Padre_PBR] int NULL,
        [Codigo] nvarchar(20) NOT NULL,
        [Descripcion] nvarchar(500) NOT NULL,
        [Orden] int NOT NULL CONSTRAINT [DF_PBR_ArbolNodo_Orden] DEFAULT ((0)),
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_ArbolNodo_FechaCreacion] DEFAULT (getdate()),
        [FechaModificacion] datetime2(7) NULL,
        CONSTRAINT [PK_PBR_ArbolNodo] PRIMARY KEY ([PKIdArbolNodo])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[ArbolNodo])
BEGIN
    SET IDENTITY_INSERT PBR.[ArbolNodo] ON;
    INSERT INTO PBR.[ArbolNodo] ([PKIdArbolNodo], [FKIdDiagnostico_PBR], [Tipo], [FKIdArbolNodo_Padre_PBR], [Codigo], [Descripcion], [Orden], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdArbolNodo], [FKIdDiagnostico_PBR], [Tipo], [FKIdArbolNodo_Padre_PBR], [Codigo], [Descripcion], [Orden], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[ArbolNodo];
    SET IDENTITY_INSERT PBR.[ArbolNodo] OFF;
END;
GO

IF OBJECT_ID(N'PBR.Asm', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[Asm]
    (
        [PKIdAsm] int IDENTITY(1,1) NOT NULL,
        [FKIdEvaluacion_PBR] int NOT NULL,
        [Titulo] nvarchar(200) NOT NULL,
        [Descripcion] nvarchar(500) NULL,
        [Prioridad] nvarchar(10) NOT NULL CONSTRAINT [DF_PBR_Asm_Prioridad] DEFAULT ('MEDIA'),
        [TipoAsm] nvarchar(30) NOT NULL CONSTRAINT [DF_PBR_Asm_TipoAsm] DEFAULT ('ESPECIFICO'),
        [FechaTermino] datetime2(7) NULL,
        [ResultadoEsperado] nvarchar(500) NULL,
        [Avance] int NOT NULL CONSTRAINT [DF_PBR_Asm_Avance] DEFAULT ((0)),
        [Estado] nvarchar(20) NOT NULL CONSTRAINT [DF_PBR_Asm_Estado] DEFAULT ('ABIERTO'),
        [FKIdResponsable_PBR] int NOT NULL,
        [Observaciones] nvarchar(500) NULL,
        [Evidencia] nvarchar(max) NULL,
        [AccionesPamge] nvarchar(max) NULL,
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_Asm_FechaCreacion] DEFAULT (getdate()),
        [FechaModificacion] datetime2(7) NULL,
        CONSTRAINT [PK_PBR_Asm] PRIMARY KEY ([PKIdAsm])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[Asm])
BEGIN
    SET IDENTITY_INSERT PBR.[Asm] ON;
    INSERT INTO PBR.[Asm] ([PKIdAsm], [FKIdEvaluacion_PBR], [Titulo], [Descripcion], [Prioridad], [TipoAsm], [FechaTermino], [ResultadoEsperado], [Avance], [Estado], [FKIdResponsable_PBR], [Observaciones], [Evidencia], [AccionesPamge], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdAsm], [FKIdEvaluacion_PBR], [Titulo], [Descripcion], [Prioridad], [TipoAsm], [FechaTermino], [ResultadoEsperado], [Avance], [Estado], [FKIdResponsable_PBR], [Observaciones], [Evidencia], [AccionesPamge], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[Asm];
    SET IDENTITY_INSERT PBR.[Asm] OFF;
END;
GO

IF OBJECT_ID(N'PBR.AvanceIndicador', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[AvanceIndicador]
    (
        [PKIdAvanceIndicador] int IDENTITY(1,1) NOT NULL,
        [FKIdIndicador_PBR] int NOT NULL,
        [Anio] int NOT NULL,
        [Trimestre] int NOT NULL,
        [ValorProgramado] decimal(18,2) NULL,
        [ValorAlcanzado] decimal(18,2) NULL,
        [FechaReporte] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_AvanceIndicador_FechaReporte] DEFAULT (getdate()),
        [FKIdUsuario_PBR] int NULL,
        [Observaciones] nvarchar(500) NULL,
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_AvanceIndicador_FechaCreacion] DEFAULT (getdate()),
        [FechaModificacion] datetime2(7) NULL,
        CONSTRAINT [PK_PBR_AvanceIndicador] PRIMARY KEY ([PKIdAvanceIndicador])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[AvanceIndicador])
BEGIN
    SET IDENTITY_INSERT PBR.[AvanceIndicador] ON;
    INSERT INTO PBR.[AvanceIndicador] ([PKIdAvanceIndicador], [FKIdIndicador_PBR], [Anio], [Trimestre], [ValorProgramado], [ValorAlcanzado], [FechaReporte], [FKIdUsuario_PBR], [Observaciones], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdAvanceIndicador], [FKIdIndicador_PBR], [Anio], [Trimestre], [ValorProgramado], [ValorAlcanzado], [FechaReporte], [FKIdUsuario_PBR], [Observaciones], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[AvanceIndicador];
    SET IDENTITY_INSERT PBR.[AvanceIndicador] OFF;
END;
GO

IF OBJECT_ID(N'PBR.CalendarioPresupuesto', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[CalendarioPresupuesto]
    (
        [PKIdCalendario] int IDENTITY(1,1) NOT NULL,
        [Anio] int NOT NULL,
        [Fecha] datetime2(7) NOT NULL,
        [FechaFin] datetime2(7) NULL,
        [Titulo] nvarchar(200) NOT NULL,
        [Descripcion] nvarchar(500) NULL,
        [Etapa] nvarchar(20) NOT NULL CONSTRAINT [DF_PBR_CalendarioPresupuesto_Etapa] DEFAULT ('GENERAL'),
        [FKIdProgramaPresupuestario_PBR] int NULL,
        [Tipo] nvarchar(10) NOT NULL CONSTRAINT [DF_PBR_CalendarioPresupuesto_Tipo] DEFAULT ('HITO'),
        [Orden] int NOT NULL CONSTRAINT [DF_PBR_CalendarioPresupuesto_Orden] DEFAULT ((0)),
        [Color] nvarchar(7) NULL,
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_CalendarioPresupuesto_FechaCreacion] DEFAULT (getdate()),
        [FechaModificacion] datetime2(7) NULL,
        CONSTRAINT [PK_PBR_CalendarioPresupuesto] PRIMARY KEY ([PKIdCalendario])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[CalendarioPresupuesto])
BEGIN
    SET IDENTITY_INSERT PBR.[CalendarioPresupuesto] ON;
    INSERT INTO PBR.[CalendarioPresupuesto] ([PKIdCalendario], [Anio], [Fecha], [FechaFin], [Titulo], [Descripcion], [Etapa], [FKIdProgramaPresupuestario_PBR], [Tipo], [Orden], [Color], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdCalendario], [Anio], [Fecha], [FechaFin], [Titulo], [Descripcion], [Etapa], [FKIdProgramaPresupuestario_PBR], [Tipo], [Orden], [Color], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[CalendarioPresupuesto];
    SET IDENTITY_INSERT PBR.[CalendarioPresupuesto] OFF;
END;
GO

IF OBJECT_ID(N'PBR.CRI', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[CRI]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [Codigo] nvarchar(10) NOT NULL,
        [Nombre] nvarchar(500) NOT NULL,
        [Rubro] nvarchar(100) NOT NULL,
        [Tipo] nvarchar(100) NOT NULL,
        [Clase] nvarchar(100) NOT NULL,
        [Concepto] nvarchar(100) NOT NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_PBR_CRI_Activo] DEFAULT ((1)),
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_CRI_FechaCreacion] DEFAULT (getdate()),
        CONSTRAINT [PK_PBR_CRI] PRIMARY KEY ([Id])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[CRI])
BEGIN
    SET IDENTITY_INSERT PBR.[CRI] ON;
    INSERT INTO PBR.[CRI] ([Id], [Codigo], [Nombre], [Rubro], [Tipo], [Clase], [Concepto], [Activo], [FechaCreacion])
    SELECT [Id], [Codigo], [Nombre], [Rubro], [Tipo], [Clase], [Concepto], [Activo], [FechaCreacion]
    FROM [GE_Datos].PBR.[CRI];
    SET IDENTITY_INSERT PBR.[CRI] OFF;
END;
GO

IF OBJECT_ID(N'PBR.Cuenta', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[Cuenta]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [Codigo] nvarchar(10) NOT NULL,
        [Nombre] nvarchar(500) NOT NULL,
        [Tipo] nvarchar(50) NOT NULL CONSTRAINT [DF_PBR_Cuenta_Tipo] DEFAULT ('ACTIVO'),
        [Activa] bit NOT NULL CONSTRAINT [DF_PBR_Cuenta_Activa] DEFAULT ((1)),
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_Cuenta_FechaCreacion] DEFAULT (getdate()),
        CONSTRAINT [PK_PBR_Cuenta] PRIMARY KEY ([Id])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[Cuenta])
BEGIN
    SET IDENTITY_INSERT PBR.[Cuenta] ON;
    INSERT INTO PBR.[Cuenta] ([Id], [Codigo], [Nombre], [Tipo], [Activa], [FechaCreacion])
    SELECT [Id], [Codigo], [Nombre], [Tipo], [Activa], [FechaCreacion]
    FROM [GE_Datos].PBR.[Cuenta];
    SET IDENTITY_INSERT PBR.[Cuenta] OFF;
END;
GO

IF OBJECT_ID(N'PBR.Dependencia', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[Dependencia]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [Nombre] nvarchar(200) NOT NULL,
        [Siglas] nvarchar(20) NOT NULL,
        [Activa] bit NOT NULL CONSTRAINT [DF_PBR_Dependencia_Activa] DEFAULT ((1)),
        [createdAt] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_Dependencia_createdAt] DEFAULT (getdate()),
        [UsuarioCreacion] int NULL CONSTRAINT [DF_PBR_Dependencia_UsuarioCreacion] DEFAULT ((1)),
        [FechaModificacion] datetime2(7) NULL,
        [UsuarioModificacion] int NULL,
        CONSTRAINT [PK_PBR_Dependencia] PRIMARY KEY ([Id])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[Dependencia])
BEGIN
    SET IDENTITY_INSERT PBR.[Dependencia] ON;
    INSERT INTO PBR.[Dependencia] ([Id], [Nombre], [Siglas], [Activa], [createdAt], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion])
    SELECT [Id], [Nombre], [Siglas], [Activa], [createdAt], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]
    FROM [GE_Datos].PBR.[Dependencia];
    SET IDENTITY_INSERT PBR.[Dependencia] OFF;
END;
GO

IF OBJECT_ID(N'PBR.Diagnostico', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[Diagnostico]
    (
        [PKIdDiagnostico] int IDENTITY(1,1) NOT NULL,
        [FKIdProgramaPresupuestario_PBR] int NOT NULL,
        [ProblemaCentral] nvarchar(500) NULL,
        [Metodologia] nvarchar(200) NULL,
        [Estado] nvarchar(20) NOT NULL CONSTRAINT [DF_PBR_Diagnostico_Estado] DEFAULT ('BORRADOR'),
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_Diagnostico_FechaCreacion] DEFAULT (getdate()),
        [FechaModificacion] datetime2(7) NULL,
        CONSTRAINT [PK_PBR_Diagnostico] PRIMARY KEY ([PKIdDiagnostico])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[Diagnostico])
BEGIN
    SET IDENTITY_INSERT PBR.[Diagnostico] ON;
    INSERT INTO PBR.[Diagnostico] ([PKIdDiagnostico], [FKIdProgramaPresupuestario_PBR], [ProblemaCentral], [Metodologia], [Estado], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdDiagnostico], [FKIdProgramaPresupuestario_PBR], [ProblemaCentral], [Metodologia], [Estado], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[Diagnostico];
    SET IDENTITY_INSERT PBR.[Diagnostico] OFF;
END;
GO

IF OBJECT_ID(N'PBR.EjercicioGasto', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[EjercicioGasto]
    (
        [PKIdEjercicioGasto] int IDENTITY(1,1) NOT NULL,
        [FKIdPartidaGasto_PBR] int NOT NULL,
        [Trimestre] int NOT NULL,
        [MontoEjercido] decimal(18,2) NOT NULL CONSTRAINT [DF_PBR_EjercicioGasto_MontoEjercido] DEFAULT ((0)),
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_EjercicioGasto_FechaCreacion] DEFAULT (getdate()),
        CONSTRAINT [PK_PBR_EjercicioGasto] PRIMARY KEY ([PKIdEjercicioGasto])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[EjercicioGasto])
BEGIN
    SET IDENTITY_INSERT PBR.[EjercicioGasto] ON;
    INSERT INTO PBR.[EjercicioGasto] ([PKIdEjercicioGasto], [FKIdPartidaGasto_PBR], [Trimestre], [MontoEjercido], [FechaCreacion])
    SELECT [PKIdEjercicioGasto], [FKIdPartidaGasto_PBR], [Trimestre], [MontoEjercido], [FechaCreacion]
    FROM [GE_Datos].PBR.[EjercicioGasto];
    SET IDENTITY_INSERT PBR.[EjercicioGasto] OFF;
END;
GO

IF OBJECT_ID(N'PBR.Entidad', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[Entidad]
    (
        [PKIdEntidad] int IDENTITY(1,1) NOT NULL,
        [Codigo] nvarchar(2) NOT NULL,
        [Nombre] nvarchar(200) NOT NULL,
        [Siglas] nvarchar(20) NOT NULL,
        [Tipo] nvarchar(30) NOT NULL CONSTRAINT [DF_PBR_Entidad_Tipo] DEFAULT ('DEPENDENCIA'),
        [Activa] bit NOT NULL CONSTRAINT [DF_PBR_Entidad_Activa] DEFAULT ((1)),
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_Entidad_FechaCreacion] DEFAULT (getdate()),
        [UsuarioCreacion] int NOT NULL,
        [FechaModificacion] datetime2(7) NULL,
        [UsuarioModificacion] int NULL,
        CONSTRAINT [PK_PBR_Entidad] PRIMARY KEY ([PKIdEntidad])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[Entidad])
BEGIN
    SET IDENTITY_INSERT PBR.[Entidad] ON;
    INSERT INTO PBR.[Entidad] ([PKIdEntidad], [Codigo], [Nombre], [Siglas], [Tipo], [Activa], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion])
    SELECT [PKIdEntidad], [Codigo], [Nombre], [Siglas], [Tipo], [Activa], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]
    FROM [GE_Datos].PBR.[Entidad];
    SET IDENTITY_INSERT PBR.[Entidad] OFF;
END;
GO

IF OBJECT_ID(N'PBR.EntidadesExternas', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[EntidadesExternas]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [Codigo] nvarchar(10) NOT NULL,
        [Nombre] nvarchar(500) NOT NULL,
        [Tipo] nvarchar(50) NOT NULL CONSTRAINT [DF_PBR_EntidadesExternas_Tipo] DEFAULT ('ORGANISMO_DESCENTRALIZADO'),
        [Activa] bit NOT NULL CONSTRAINT [DF_PBR_EntidadesExternas_Activa] DEFAULT ((1)),
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_EntidadesExternas_FechaCreacion] DEFAULT (getdate()),
        CONSTRAINT [PK_PBR_EntidadesExternas] PRIMARY KEY ([Id])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[EntidadesExternas])
BEGIN
    SET IDENTITY_INSERT PBR.[EntidadesExternas] ON;
    INSERT INTO PBR.[EntidadesExternas] ([Id], [Codigo], [Nombre], [Tipo], [Activa], [FechaCreacion])
    SELECT [Id], [Codigo], [Nombre], [Tipo], [Activa], [FechaCreacion]
    FROM [GE_Datos].PBR.[EntidadesExternas];
    SET IDENTITY_INSERT PBR.[EntidadesExternas] OFF;
END;
GO

IF OBJECT_ID(N'PBR.Evaluacion', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[Evaluacion]
    (
        [PKIdEvaluacion] int IDENTITY(1,1) NOT NULL,
        [FKIdProgramaPresupuestario_PBR] int NOT NULL,
        [Tipo] nvarchar(30) NOT NULL,
        [Nombre] nvarchar(200) NOT NULL,
        [EjercicioFiscal] int NOT NULL,
        [PaeAnio] int NULL,
        [Estado] nvarchar(20) NOT NULL CONSTRAINT [DF_PBR_Evaluacion_Estado] DEFAULT ('PLANEADA'),
        [FechaInicio] datetime2(7) NULL,
        [FechaFin] datetime2(7) NULL,
        [FKIdResponsable_PBR] int NOT NULL,
        [EvaluadorExterno] nvarchar(200) NULL,
        [Recomendaciones] nvarchar(max) NULL,
        [RespuestaDependencia] nvarchar(max) NULL,
        [InformeUrl] nvarchar(500) NULL,
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_Evaluacion_FechaCreacion] DEFAULT (getdate()),
        [FechaModificacion] datetime2(7) NULL,
        CONSTRAINT [PK_PBR_Evaluacion] PRIMARY KEY ([PKIdEvaluacion])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[Evaluacion])
BEGIN
    SET IDENTITY_INSERT PBR.[Evaluacion] ON;
    INSERT INTO PBR.[Evaluacion] ([PKIdEvaluacion], [FKIdProgramaPresupuestario_PBR], [Tipo], [Nombre], [EjercicioFiscal], [PaeAnio], [Estado], [FechaInicio], [FechaFin], [FKIdResponsable_PBR], [EvaluadorExterno], [Recomendaciones], [RespuestaDependencia], [InformeUrl], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdEvaluacion], [FKIdProgramaPresupuestario_PBR], [Tipo], [Nombre], [EjercicioFiscal], [PaeAnio], [Estado], [FechaInicio], [FechaFin], [FKIdResponsable_PBR], [EvaluadorExterno], [Recomendaciones], [RespuestaDependencia], [InformeUrl], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[Evaluacion];
    SET IDENTITY_INSERT PBR.[Evaluacion] OFF;
END;
GO

IF OBJECT_ID(N'PBR.EvaluacionConsistencia', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[EvaluacionConsistencia]
    (
        [PKIdEvaluacionConsistencia] int IDENTITY(1,1) NOT NULL,
        [FKIdProgramaPresupuestario_PBR] int NOT NULL,
        [Anio] int NOT NULL,
        [Estado] nvarchar(20) NOT NULL CONSTRAINT [DF_PBR_EvaluacionConsistencia_Estado] DEFAULT ('BORRADOR'),
        [PuntuacionTotal] decimal(5,2) NULL,
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_EvaluacionConsistencia_FechaCreacion] DEFAULT (getdate()),
        [FechaModificacion] datetime2(7) NULL,
        CONSTRAINT [PK_PBR_EvaluacionConsistencia] PRIMARY KEY ([PKIdEvaluacionConsistencia])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[EvaluacionConsistencia])
BEGIN
    SET IDENTITY_INSERT PBR.[EvaluacionConsistencia] ON;
    INSERT INTO PBR.[EvaluacionConsistencia] ([PKIdEvaluacionConsistencia], [FKIdProgramaPresupuestario_PBR], [Anio], [Estado], [PuntuacionTotal], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdEvaluacionConsistencia], [FKIdProgramaPresupuestario_PBR], [Anio], [Estado], [PuntuacionTotal], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[EvaluacionConsistencia];
    SET IDENTITY_INSERT PBR.[EvaluacionConsistencia] OFF;
END;
GO

IF OBJECT_ID(N'PBR.EvaluacionConsistenciaPregunta', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[EvaluacionConsistenciaPregunta]
    (
        [PKIdPregunta] int IDENTITY(1,1) NOT NULL,
        [Seccion] int NOT NULL,
        [SeccionNombre] nvarchar(200) NOT NULL,
        [Numero] int NOT NULL,
        [Pregunta] nvarchar(500) NOT NULL,
        [TipoRespuesta] nvarchar(20) NOT NULL CONSTRAINT [DF_PBR_EvaluacionConsistenciaPregunta_TipoRespuesta] DEFAULT ('SI_NO_PARCIAL'),
        [Peso] decimal(5,2) NOT NULL CONSTRAINT [DF_PBR_EvaluacionConsistenciaPregunta_Peso] DEFAULT ((1.0)),
        [Activa] bit NOT NULL CONSTRAINT [DF_PBR_EvaluacionConsistenciaPregunta_Activa] DEFAULT ((1)),
        [Orden] int NOT NULL,
        CONSTRAINT [PK_PBR_EvaluacionConsistenciaPregunta] PRIMARY KEY ([PKIdPregunta])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[EvaluacionConsistenciaPregunta])
BEGIN
    SET IDENTITY_INSERT PBR.[EvaluacionConsistenciaPregunta] ON;
    INSERT INTO PBR.[EvaluacionConsistenciaPregunta] ([PKIdPregunta], [Seccion], [SeccionNombre], [Numero], [Pregunta], [TipoRespuesta], [Peso], [Activa], [Orden])
    SELECT [PKIdPregunta], [Seccion], [SeccionNombre], [Numero], [Pregunta], [TipoRespuesta], [Peso], [Activa], [Orden]
    FROM [GE_Datos].PBR.[EvaluacionConsistenciaPregunta];
    SET IDENTITY_INSERT PBR.[EvaluacionConsistenciaPregunta] OFF;
END;
GO

IF OBJECT_ID(N'PBR.EvaluacionConsistenciaRespuesta', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[EvaluacionConsistenciaRespuesta]
    (
        [PKIdRespuesta] int IDENTITY(1,1) NOT NULL,
        [FKIdEvaluacionConsistencia_PBR] int NOT NULL,
        [FKIdPregunta_PBR] int NOT NULL,
        [Respuesta] nvarchar(20) NULL,
        [Justificacion] nvarchar(500) NULL,
        [Puntuacion] decimal(5,2) NULL,
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_EvaluacionConsistenciaRespuesta_FechaCreacion] DEFAULT (getdate()),
        CONSTRAINT [PK_PBR_EvaluacionConsistenciaRespuesta] PRIMARY KEY ([PKIdRespuesta])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[EvaluacionConsistenciaRespuesta])
BEGIN
    SET IDENTITY_INSERT PBR.[EvaluacionConsistenciaRespuesta] ON;
    INSERT INTO PBR.[EvaluacionConsistenciaRespuesta] ([PKIdRespuesta], [FKIdEvaluacionConsistencia_PBR], [FKIdPregunta_PBR], [Respuesta], [Justificacion], [Puntuacion], [FechaCreacion])
    SELECT [PKIdRespuesta], [FKIdEvaluacionConsistencia_PBR], [FKIdPregunta_PBR], [Respuesta], [Justificacion], [Puntuacion], [FechaCreacion]
    FROM [GE_Datos].PBR.[EvaluacionConsistenciaRespuesta];
    SET IDENTITY_INSERT PBR.[EvaluacionConsistenciaRespuesta] OFF;
END;
GO

IF OBJECT_ID(N'PBR.Indicador', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[Indicador]
    (
        [PKIdIndicador] int IDENTITY(1,1) NOT NULL,
        [FKIdMirNivel_PBR] int NOT NULL,
        [Nombre] nvarchar(500) NOT NULL,
        [Definicion] nvarchar(1000) NULL,
        [Tipo] nvarchar(20) NOT NULL,
        [Dimension] nvarchar(20) NOT NULL,
        [Formula] nvarchar(500) NOT NULL,
        [Algoritmo] nvarchar(200) NOT NULL,
        [Frecuencia] nvarchar(20) NOT NULL,
        [Unidad] nvarchar(100) NOT NULL,
        [LineaBase] nvarchar(200) NOT NULL,
        [Meta] nvarchar(200) NOT NULL,
        [MedioVerificacion] nvarchar(500) NOT NULL,
        [Supuesto] nvarchar(500) NOT NULL,
        [Sentido] nvarchar(20) NOT NULL CONSTRAINT [DF_PBR_Indicador_Sentido] DEFAULT ('Ascendente'),
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_Indicador_FechaCreacion] DEFAULT (getdate()),
        [FechaModificacion] datetime2(7) NULL,
        CONSTRAINT [PK_PBR_Indicador] PRIMARY KEY ([PKIdIndicador])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[Indicador])
BEGIN
    SET IDENTITY_INSERT PBR.[Indicador] ON;
    INSERT INTO PBR.[Indicador] ([PKIdIndicador], [FKIdMirNivel_PBR], [Nombre], [Definicion], [Tipo], [Dimension], [Formula], [Algoritmo], [Frecuencia], [Unidad], [LineaBase], [Meta], [MedioVerificacion], [Supuesto], [Sentido], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdIndicador], [FKIdMirNivel_PBR], [Nombre], [Definicion], [Tipo], [Dimension], [Formula], [Algoritmo], [Frecuencia], [Unidad], [LineaBase], [Meta], [MedioVerificacion], [Supuesto], [Sentido], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[Indicador];
    SET IDENTITY_INSERT PBR.[Indicador] OFF;
END;
GO

IF OBJECT_ID(N'PBR.InformeTrimestral', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[InformeTrimestral]
    (
        [PKIdInformeTrimestral] int IDENTITY(1,1) NOT NULL,
        [FKIdProgramaPresupuestario_PBR] int NOT NULL,
        [Anio] int NOT NULL,
        [Trimestre] int NOT NULL,
        [Estatus] nvarchar(20) NOT NULL CONSTRAINT [DF_PBR_InformeTrimestral_Estatus] DEFAULT ('BORRADOR'),
        [Observaciones] nvarchar(500) NULL,
        [Analisis] nvarchar(max) NULL,
        [FKIdUsuario_PBR] int NOT NULL,
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_InformeTrimestral_FechaCreacion] DEFAULT (getdate()),
        [FechaModificacion] datetime2(7) NULL,
        [EnviadoAt] datetime2(7) NULL,
        CONSTRAINT [PK_PBR_InformeTrimestral] PRIMARY KEY ([PKIdInformeTrimestral])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[InformeTrimestral])
BEGIN
    SET IDENTITY_INSERT PBR.[InformeTrimestral] ON;
    INSERT INTO PBR.[InformeTrimestral] ([PKIdInformeTrimestral], [FKIdProgramaPresupuestario_PBR], [Anio], [Trimestre], [Estatus], [Observaciones], [Analisis], [FKIdUsuario_PBR], [FechaCreacion], [FechaModificacion], [EnviadoAt])
    SELECT [PKIdInformeTrimestral], [FKIdProgramaPresupuestario_PBR], [Anio], [Trimestre], [Estatus], [Observaciones], [Analisis], [FKIdUsuario_PBR], [FechaCreacion], [FechaModificacion], [EnviadoAt]
    FROM [GE_Datos].PBR.[InformeTrimestral];
    SET IDENTITY_INSERT PBR.[InformeTrimestral] OFF;
END;
GO

IF OBJECT_ID(N'PBR.MetaODS', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[MetaODS]
    (
        [PKIdMetaODS] int IDENTITY(1,1) NOT NULL,
        [FKIdObjetivoODS_PBR] int NOT NULL,
        [Numero] nvarchar(10) NOT NULL,
        [Descripcion] nvarchar(500) NOT NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_PBR_MetaODS_Activo] DEFAULT ((1)),
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_MetaODS_FechaCreacion] DEFAULT (getdate()),
        CONSTRAINT [PK_PBR_MetaODS] PRIMARY KEY ([PKIdMetaODS])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[MetaODS])
BEGIN
    SET IDENTITY_INSERT PBR.[MetaODS] ON;
    INSERT INTO PBR.[MetaODS] ([PKIdMetaODS], [FKIdObjetivoODS_PBR], [Numero], [Descripcion], [Activo], [FechaCreacion])
    SELECT [PKIdMetaODS], [FKIdObjetivoODS_PBR], [Numero], [Descripcion], [Activo], [FechaCreacion]
    FROM [GE_Datos].PBR.[MetaODS];
    SET IDENTITY_INSERT PBR.[MetaODS] OFF;
END;
GO

IF OBJECT_ID(N'PBR.MirNivel', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[MirNivel]
    (
        [PKIdMirNivel] int IDENTITY(1,1) NOT NULL,
        [FKIdProgramaPresupuestario_PBR] int NOT NULL,
        [Nivel] nvarchar(20) NOT NULL,
        [Objetivo] nvarchar(500) NOT NULL,
        [Descripcion] nvarchar(500) NULL,
        [Orden] int NOT NULL,
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_MirNivel_FechaCreacion] DEFAULT (getdate()),
        [FechaModificacion] datetime2(7) NULL,
        CONSTRAINT [PK_PBR_MirNivel] PRIMARY KEY ([PKIdMirNivel])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[MirNivel])
BEGIN
    SET IDENTITY_INSERT PBR.[MirNivel] ON;
    INSERT INTO PBR.[MirNivel] ([PKIdMirNivel], [FKIdProgramaPresupuestario_PBR], [Nivel], [Objetivo], [Descripcion], [Orden], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdMirNivel], [FKIdProgramaPresupuestario_PBR], [Nivel], [Objetivo], [Descripcion], [Orden], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[MirNivel];
    SET IDENTITY_INSERT PBR.[MirNivel] OFF;
END;
GO

IF OBJECT_ID(N'PBR.MirVersion', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[MirVersion]
    (
        [PKIdMirVersion] int IDENTITY(1,1) NOT NULL,
        [FKIdProgramaPresupuestario_PBR] int NOT NULL,
        [Version] int NOT NULL,
        [Snapshot] nvarchar(max) NOT NULL,
        [FKIdUsuario_PBR] int NOT NULL,
        [Comentario] nvarchar(500) NULL,
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_MirVersion_FechaCreacion] DEFAULT (getdate()),
        CONSTRAINT [PK_PBR_MirVersion] PRIMARY KEY ([PKIdMirVersion])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[MirVersion])
BEGIN
    SET IDENTITY_INSERT PBR.[MirVersion] ON;
    INSERT INTO PBR.[MirVersion] ([PKIdMirVersion], [FKIdProgramaPresupuestario_PBR], [Version], [Snapshot], [FKIdUsuario_PBR], [Comentario], [FechaCreacion])
    SELECT [PKIdMirVersion], [FKIdProgramaPresupuestario_PBR], [Version], [Snapshot], [FKIdUsuario_PBR], [Comentario], [FechaCreacion]
    FROM [GE_Datos].PBR.[MirVersion];
    SET IDENTITY_INSERT PBR.[MirVersion] OFF;
END;
GO

IF OBJECT_ID(N'PBR.ObjetivoODS', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[ObjetivoODS]
    (
        [PKIdObjetivoODS] int IDENTITY(1,1) NOT NULL,
        [Numero] int NOT NULL,
        [Nombre] nvarchar(200) NOT NULL,
        [Descripcion] nvarchar(500) NULL,
        [Icono] nvarchar(50) NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_PBR_ObjetivoODS_Activo] DEFAULT ((1)),
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_ObjetivoODS_FechaCreacion] DEFAULT (getdate()),
        CONSTRAINT [PK_PBR_ObjetivoODS] PRIMARY KEY ([PKIdObjetivoODS])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[ObjetivoODS])
BEGIN
    SET IDENTITY_INSERT PBR.[ObjetivoODS] ON;
    INSERT INTO PBR.[ObjetivoODS] ([PKIdObjetivoODS], [Numero], [Nombre], [Descripcion], [Icono], [Activo], [FechaCreacion])
    SELECT [PKIdObjetivoODS], [Numero], [Nombre], [Descripcion], [Icono], [Activo], [FechaCreacion]
    FROM [GE_Datos].PBR.[ObjetivoODS];
    SET IDENTITY_INSERT PBR.[ObjetivoODS] OFF;
END;
GO

IF OBJECT_ID(N'PBR.ObjetivoPED', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[ObjetivoPED]
    (
        [PKIdObjetivoPED] int IDENTITY(1,1) NOT NULL,
        [Codigo] nvarchar(20) NOT NULL,
        [Eje] nvarchar(200) NOT NULL,
        [Objetivo] nvarchar(500) NOT NULL,
        [Indicador] nvarchar(500) NULL,
        [Meta] nvarchar(200) NULL,
        [ODS] nvarchar(10) NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_PBR_ObjetivoPED_Activo] DEFAULT ((1)),
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_ObjetivoPED_FechaCreacion] DEFAULT (getdate()),
        [UsuarioCreacion] int NOT NULL,
        [FechaModificacion] datetime2(7) NULL,
        [UsuarioModificacion] int NULL,
        CONSTRAINT [PK_PBR_ObjetivoPED] PRIMARY KEY ([PKIdObjetivoPED])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[ObjetivoPED])
BEGIN
    SET IDENTITY_INSERT PBR.[ObjetivoPED] ON;
    INSERT INTO PBR.[ObjetivoPED] ([PKIdObjetivoPED], [Codigo], [Eje], [Objetivo], [Indicador], [Meta], [ODS], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion])
    SELECT [PKIdObjetivoPED], [Codigo], [Eje], [Objetivo], [Indicador], [Meta], [ODS], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]
    FROM [GE_Datos].PBR.[ObjetivoPED];
    SET IDENTITY_INSERT PBR.[ObjetivoPED] OFF;
END;
GO

IF OBJECT_ID(N'PBR.PartidaGenerica', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[PartidaGenerica]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [Codigo] nvarchar(10) NOT NULL,
        [Nombre] nvarchar(500) NOT NULL,
        [Descripcion] nvarchar(max) NULL,
        [FKIdConcepto_SIS] int NOT NULL,
        [Activa] bit NOT NULL CONSTRAINT [DF_PBR_PartidaGenerica_Activa] DEFAULT ((1)),
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_PartidaGenerica_FechaCreacion] DEFAULT (getdate()),
        CONSTRAINT [PK_PBR_PartidaGenerica] PRIMARY KEY ([Id])
    );
END;
GO

IF OBJECT_ID(N'PBR.PartidaGasto', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[PartidaGasto]
    (
        [PKIdPartidaGasto] int IDENTITY(1,1) NOT NULL,
        [FKIdPresupuestoPrograma_PBR] int NOT NULL,
        [FKIdCapitulo_SIS] int NULL,
        [FKIdConcepto_SIS] int NULL,
        [FKIdPartida_SIS] int NULL,
        [CapituloClave] nvarchar(4) NOT NULL,
        [Descripcion] nvarchar(500) NOT NULL,
        [MontoAnual] decimal(18,2) NOT NULL CONSTRAINT [DF_PBR_PartidaGasto_MontoAnual] DEFAULT ((0)),
        [MontoModificado] decimal(18,2) NULL,
        [FKIdTipoGasto_PRES] int NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_PBR_PartidaGasto_Activo] DEFAULT ((1)),
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_PartidaGasto_FechaCreacion] DEFAULT (getdate()),
        [UsuarioCreacion] int NOT NULL,
        [FechaModificacion] datetime2(7) NULL,
        [UsuarioModificacion] int NULL,
        CONSTRAINT [PK_PBR_PartidaGasto] PRIMARY KEY ([PKIdPartidaGasto])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[PartidaGasto])
BEGIN
    SET IDENTITY_INSERT PBR.[PartidaGasto] ON;
    INSERT INTO PBR.[PartidaGasto] ([PKIdPartidaGasto], [FKIdPresupuestoPrograma_PBR], [FKIdCapitulo_SIS], [FKIdConcepto_SIS], [FKIdPartida_SIS], [CapituloClave], [Descripcion], [MontoAnual], [MontoModificado], [FKIdTipoGasto_PRES], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion])
    SELECT [PKIdPartidaGasto], [FKIdPresupuestoPrograma_PBR], [FKIdCapitulo_SIS], [FKIdConcepto_SIS], [FKIdPartida_SIS], [CapituloClave], [Descripcion], [MontoAnual], [MontoModificado], [FKIdTipoGasto_PRES], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]
    FROM [GE_Datos].PBR.[PartidaGasto];
    SET IDENTITY_INSERT PBR.[PartidaGasto] OFF;
END;
GO

IF OBJECT_ID(N'PBR.PoblacionObjetivo', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[PoblacionObjetivo]
    (
        [PKIdPoblacionObjetivo] int IDENTITY(1,1) NOT NULL,
        [FKIdProgramaPresupuestario_PBR] int NOT NULL,
        [Anio] int NOT NULL,
        [PoblacionPotencial] decimal(18,2) NULL,
        [PoblacionObjetivo] decimal(18,2) NULL,
        [PoblacionReferencia] decimal(18,2) NULL,
        [Metodologia] nvarchar(500) NULL,
        [Fuente] nvarchar(200) NULL,
        [Notas] nvarchar(500) NULL,
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_PoblacionObjetivo_FechaCreacion] DEFAULT (getdate()),
        [FechaModificacion] datetime2(7) NULL,
        CONSTRAINT [PK_PBR_PoblacionObjetivo] PRIMARY KEY ([PKIdPoblacionObjetivo])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[PoblacionObjetivo])
BEGIN
    SET IDENTITY_INSERT PBR.[PoblacionObjetivo] ON;
    INSERT INTO PBR.[PoblacionObjetivo] ([PKIdPoblacionObjetivo], [FKIdProgramaPresupuestario_PBR], [Anio], [PoblacionPotencial], [PoblacionObjetivo], [PoblacionReferencia], [Metodologia], [Fuente], [Notas], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdPoblacionObjetivo], [FKIdProgramaPresupuestario_PBR], [Anio], [PoblacionPotencial], [PoblacionObjetivo], [PoblacionReferencia], [Metodologia], [Fuente], [Notas], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[PoblacionObjetivo];
    SET IDENTITY_INSERT PBR.[PoblacionObjetivo] OFF;
END;
GO

IF OBJECT_ID(N'PBR.PresupuestoPrograma', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[PresupuestoPrograma]
    (
        [PKIdPresupuestoPrograma] int IDENTITY(1,1) NOT NULL,
        [FKIdProgramaPresupuestario_PBR] int NOT NULL,
        [Anio] int NOT NULL,
        [PresupuestoAnual] decimal(18,2) NOT NULL CONSTRAINT [DF_PBR_PresupuestoPrograma_PresupuestoAnual] DEFAULT ((0)),
        [PresupuestoModificado] decimal(18,2) NULL,
        [FKIdEntidad_PBR] int NULL,
        [FKIdUnidadResponsable_PRES] int NULL,
        [FKIdFuenteFinanciamiento_PRES] int NULL,
        [FKIdActividadInstitucional_SIS] int NULL,
        [FKIdProyectoInversion_PRES] int NULL,
        [FKIdRegion_PBR] int NULL,
        [ComponenteActivado] nvarchar(50) NULL,
        [Futuro] nvarchar(50) NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_PBR_PresupuestoPrograma_Activo] DEFAULT ((1)),
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_PresupuestoPrograma_FechaCreacion] DEFAULT (getdate()),
        [UsuarioCreacion] int NOT NULL,
        [FechaModificacion] datetime2(7) NULL,
        [UsuarioModificacion] int NULL,
        CONSTRAINT [PK_PBR_PresupuestoPrograma] PRIMARY KEY ([PKIdPresupuestoPrograma])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[PresupuestoPrograma])
BEGIN
    SET IDENTITY_INSERT PBR.[PresupuestoPrograma] ON;
    INSERT INTO PBR.[PresupuestoPrograma] ([PKIdPresupuestoPrograma], [FKIdProgramaPresupuestario_PBR], [Anio], [PresupuestoAnual], [PresupuestoModificado], [FKIdEntidad_PBR], [FKIdUnidadResponsable_PRES], [FKIdFuenteFinanciamiento_PRES], [FKIdActividadInstitucional_SIS], [FKIdProyectoInversion_PRES], [FKIdRegion_PBR], [ComponenteActivado], [Futuro], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion])
    SELECT [PKIdPresupuestoPrograma], [FKIdProgramaPresupuestario_PBR], [Anio], [PresupuestoAnual], [PresupuestoModificado], [FKIdEntidad_PBR], [FKIdUnidadResponsable_PRES], [FKIdFuenteFinanciamiento_PRES], [FKIdActividadInstitucional_SIS], [FKIdProyectoInversion_PRES], [FKIdRegion_PBR], [ComponenteActivado], [Futuro], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]
    FROM [GE_Datos].PBR.[PresupuestoPrograma];
    SET IDENTITY_INSERT PBR.[PresupuestoPrograma] OFF;
END;
GO

IF OBJECT_ID(N'PBR.ProyeccionMultianual', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[ProyeccionMultianual]
    (
        [PKIdProyeccion] int IDENTITY(1,1) NOT NULL,
        [FKIdProgramaPresupuestario_PBR] int NOT NULL,
        [AnioBase] int NOT NULL,
        [Anio] int NOT NULL,
        [MontoProyectado] decimal(18,2) NOT NULL,
        [TasaCrecimiento] decimal(5,2) NULL,
        [TipoEscenario] nvarchar(20) NOT NULL CONSTRAINT [DF_PBR_ProyeccionMultianual_TipoEscenario] DEFAULT ('BASE'),
        [Metodo] nvarchar(20) NOT NULL CONSTRAINT [DF_PBR_ProyeccionMultianual_Metodo] DEFAULT ('INERCIA'),
        [Notas] nvarchar(500) NULL,
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_ProyeccionMultianual_FechaCreacion] DEFAULT (getdate()),
        [FechaModificacion] datetime2(7) NULL,
        CONSTRAINT [PK_PBR_ProyeccionMultianual] PRIMARY KEY ([PKIdProyeccion])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[ProyeccionMultianual])
BEGIN
    SET IDENTITY_INSERT PBR.[ProyeccionMultianual] ON;
    INSERT INTO PBR.[ProyeccionMultianual] ([PKIdProyeccion], [FKIdProgramaPresupuestario_PBR], [AnioBase], [Anio], [MontoProyectado], [TasaCrecimiento], [TipoEscenario], [Metodo], [Notas], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdProyeccion], [FKIdProgramaPresupuestario_PBR], [AnioBase], [Anio], [MontoProyectado], [TasaCrecimiento], [TipoEscenario], [Metodo], [Notas], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[ProyeccionMultianual];
    SET IDENTITY_INSERT PBR.[ProyeccionMultianual] OFF;
END;
GO

IF OBJECT_ID(N'PBR.RecomendacionEvaluacion', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[RecomendacionEvaluacion]
    (
        [PKIdRecomendacion] int IDENTITY(1,1) NOT NULL,
        [FKIdEvaluacion_PBR] int NOT NULL,
        [Numero] int NOT NULL,
        [Descripcion] nvarchar(500) NOT NULL,
        [Tipo] nvarchar(20) NOT NULL CONSTRAINT [DF_PBR_RecomendacionEvaluacion_Tipo] DEFAULT ('ESPECIFICA'),
        [Prioridad] nvarchar(10) NOT NULL CONSTRAINT [DF_PBR_RecomendacionEvaluacion_Prioridad] DEFAULT ('MEDIA'),
        [FKIdResponsable_PBR] int NOT NULL,
        [FechaLimite] datetime2(7) NULL,
        [MedioVerificacion] nvarchar(500) NULL,
        [Avance] int NOT NULL CONSTRAINT [DF_PBR_RecomendacionEvaluacion_Avance] DEFAULT ((0)),
        [Estado] nvarchar(20) NOT NULL CONSTRAINT [DF_PBR_RecomendacionEvaluacion_Estado] DEFAULT ('ABIERTO'),
        [Observaciones] nvarchar(500) NULL,
        [Evidencia] nvarchar(max) NULL,
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_RecomendacionEvaluacion_FechaCreacion] DEFAULT (getdate()),
        [FechaModificacion] datetime2(7) NULL,
        CONSTRAINT [PK_PBR_RecomendacionEvaluacion] PRIMARY KEY ([PKIdRecomendacion])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[RecomendacionEvaluacion])
BEGIN
    SET IDENTITY_INSERT PBR.[RecomendacionEvaluacion] ON;
    INSERT INTO PBR.[RecomendacionEvaluacion] ([PKIdRecomendacion], [FKIdEvaluacion_PBR], [Numero], [Descripcion], [Tipo], [Prioridad], [FKIdResponsable_PBR], [FechaLimite], [MedioVerificacion], [Avance], [Estado], [Observaciones], [Evidencia], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdRecomendacion], [FKIdEvaluacion_PBR], [Numero], [Descripcion], [Tipo], [Prioridad], [FKIdResponsable_PBR], [FechaLimite], [MedioVerificacion], [Avance], [Estado], [Observaciones], [Evidencia], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[RecomendacionEvaluacion];
    SET IDENTITY_INSERT PBR.[RecomendacionEvaluacion] OFF;
END;
GO

IF OBJECT_ID(N'PBR.Region', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[Region]
    (
        [Id] int IDENTITY(1,1) NOT NULL,
        [Codigo] nvarchar(10) NOT NULL,
        [Nombre] nvarchar(500) NOT NULL,
        [Tipo] nvarchar(50) NOT NULL CONSTRAINT [DF_PBR_Region_Tipo] DEFAULT ('MUNICIPIO'),
        [Activa] bit NOT NULL CONSTRAINT [DF_PBR_Region_Activa] DEFAULT ((1)),
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_Region_FechaCreacion] DEFAULT (getdate()),
        CONSTRAINT [PK_PBR_Region] PRIMARY KEY ([Id])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[Region])
BEGIN
    SET IDENTITY_INSERT PBR.[Region] ON;
    INSERT INTO PBR.[Region] ([Id], [Codigo], [Nombre], [Tipo], [Activa], [FechaCreacion])
    SELECT [Id], [Codigo], [Nombre], [Tipo], [Activa], [FechaCreacion]
    FROM [GE_Datos].PBR.[Region];
    SET IDENTITY_INSERT PBR.[Region] OFF;
END;
GO

IF OBJECT_ID(N'PBR.ReglaOperacion', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[ReglaOperacion]
    (
        [PKIdReglaOperacion] int IDENTITY(1,1) NOT NULL,
        [FKIdProgramaPresupuestario_PBR] int NOT NULL,
        [Version] int NOT NULL,
        [Titulo] nvarchar(200) NOT NULL,
        [Descripcion] nvarchar(500) NULL,
        [Secciones] nvarchar(max) NULL,
        [PdfUrl] nvarchar(500) NULL,
        [FKIdUsuario_PBR] int NOT NULL,
        [Activa] bit NOT NULL CONSTRAINT [DF_PBR_ReglaOperacion_Activa] DEFAULT ((0)),
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_ReglaOperacion_FechaCreacion] DEFAULT (getdate()),
        [FechaModificacion] datetime2(7) NULL,
        CONSTRAINT [PK_PBR_ReglaOperacion] PRIMARY KEY ([PKIdReglaOperacion])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[ReglaOperacion])
BEGIN
    SET IDENTITY_INSERT PBR.[ReglaOperacion] ON;
    INSERT INTO PBR.[ReglaOperacion] ([PKIdReglaOperacion], [FKIdProgramaPresupuestario_PBR], [Version], [Titulo], [Descripcion], [Secciones], [PdfUrl], [FKIdUsuario_PBR], [Activa], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdReglaOperacion], [FKIdProgramaPresupuestario_PBR], [Version], [Titulo], [Descripcion], [Secciones], [PdfUrl], [FKIdUsuario_PBR], [Activa], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[ReglaOperacion];
    SET IDENTITY_INSERT PBR.[ReglaOperacion] OFF;
END;
GO

IF OBJECT_ID(N'PBR.TechoGasto', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[TechoGasto]
    (
        [PKIdTechoGasto] int IDENTITY(1,1) NOT NULL,
        [FKIdEntidad_PBR] int NOT NULL,
        [Anio] int NOT NULL,
        [MontoTecho] decimal(18,2) NOT NULL,
        [TipoTecho] nvarchar(20) NOT NULL CONSTRAINT [DF_PBR_TechoGasto_TipoTecho] DEFAULT ('TENTATIVO'),
        [FechaAsignacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_TechoGasto_FechaAsignacion] DEFAULT (getdate()),
        [FKIdUsuario_PBR] int NULL,
        [Notas] nvarchar(500) NULL,
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_TechoGasto_FechaCreacion] DEFAULT (getdate()),
        [FechaModificacion] datetime2(7) NULL,
        CONSTRAINT [PK_PBR_TechoGasto] PRIMARY KEY ([PKIdTechoGasto])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[TechoGasto])
BEGIN
    SET IDENTITY_INSERT PBR.[TechoGasto] ON;
    INSERT INTO PBR.[TechoGasto] ([PKIdTechoGasto], [FKIdEntidad_PBR], [Anio], [MontoTecho], [TipoTecho], [FechaAsignacion], [FKIdUsuario_PBR], [Notas], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdTechoGasto], [FKIdEntidad_PBR], [Anio], [MontoTecho], [TipoTecho], [FechaAsignacion], [FKIdUsuario_PBR], [Notas], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[TechoGasto];
    SET IDENTITY_INSERT PBR.[TechoGasto] OFF;
END;
GO

IF OBJECT_ID(N'PBR.TipologiaPrograma', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[TipologiaPrograma]
    (
        [PKIdTipologia] int IDENTITY(1,1) NOT NULL,
        [Codigo] nvarchar(2) NOT NULL,
        [Nombre] nvarchar(200) NOT NULL,
        [Descripcion] nvarchar(500) NULL,
        [Activa] bit NOT NULL CONSTRAINT [DF_PBR_TipologiaPrograma_Activa] DEFAULT ((1)),
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_TipologiaPrograma_FechaCreacion] DEFAULT (getdate()),
        [UsuarioCreacion] int NOT NULL,
        [FechaModificacion] datetime2(7) NULL,
        [UsuarioModificacion] int NULL,
        CONSTRAINT [PK_PBR_TipologiaPrograma] PRIMARY KEY ([PKIdTipologia])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[TipologiaPrograma])
BEGIN
    SET IDENTITY_INSERT PBR.[TipologiaPrograma] ON;
    INSERT INTO PBR.[TipologiaPrograma] ([PKIdTipologia], [Codigo], [Nombre], [Descripcion], [Activa], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion])
    SELECT [PKIdTipologia], [Codigo], [Nombre], [Descripcion], [Activa], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]
    FROM [GE_Datos].PBR.[TipologiaPrograma];
    SET IDENTITY_INSERT PBR.[TipologiaPrograma] OFF;
END;
GO

IF OBJECT_ID(N'PBR.VinculacionProgramaODS', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[VinculacionProgramaODS]
    (
        [PKIdVinculacionODS] int IDENTITY(1,1) NOT NULL,
        [FKIdProgramaPresupuestario_PBR] int NOT NULL,
        [FKIdObjetivoODS_PBR] int NOT NULL,
        [FKIdMetaODS_PBR] int NULL,
        [Contribucion] nvarchar(500) NULL,
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_VinculacionProgramaODS_FechaCreacion] DEFAULT (getdate()),
        CONSTRAINT [PK_PBR_VinculacionProgramaODS] PRIMARY KEY ([PKIdVinculacionODS])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[VinculacionProgramaODS])
BEGIN
    SET IDENTITY_INSERT PBR.[VinculacionProgramaODS] ON;
    INSERT INTO PBR.[VinculacionProgramaODS] ([PKIdVinculacionODS], [FKIdProgramaPresupuestario_PBR], [FKIdObjetivoODS_PBR], [FKIdMetaODS_PBR], [Contribucion], [FechaCreacion])
    SELECT [PKIdVinculacionODS], [FKIdProgramaPresupuestario_PBR], [FKIdObjetivoODS_PBR], [FKIdMetaODS_PBR], [Contribucion], [FechaCreacion]
    FROM [GE_Datos].PBR.[VinculacionProgramaODS];
    SET IDENTITY_INSERT PBR.[VinculacionProgramaODS] OFF;
END;
GO

IF OBJECT_ID(N'PBR.VinculacionProgramaPED', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[VinculacionProgramaPED]
    (
        [PKIdVinculacionPED] int IDENTITY(1,1) NOT NULL,
        [FKIdProgramaPresupuestario_PBR] int NOT NULL,
        [FKIdObjetivoPED_PBR] int NOT NULL,
        [LineaAccion] nvarchar(500) NULL,
        [Contribucion] nvarchar(500) NULL,
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_VinculacionProgramaPED_FechaCreacion] DEFAULT (getdate()),
        CONSTRAINT [PK_PBR_VinculacionProgramaPED] PRIMARY KEY ([PKIdVinculacionPED])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[VinculacionProgramaPED])
BEGIN
    SET IDENTITY_INSERT PBR.[VinculacionProgramaPED] ON;
    INSERT INTO PBR.[VinculacionProgramaPED] ([PKIdVinculacionPED], [FKIdProgramaPresupuestario_PBR], [FKIdObjetivoPED_PBR], [LineaAccion], [Contribucion], [FechaCreacion])
    SELECT [PKIdVinculacionPED], [FKIdProgramaPresupuestario_PBR], [FKIdObjetivoPED_PBR], [LineaAccion], [Contribucion], [FechaCreacion]
    FROM [GE_Datos].PBR.[VinculacionProgramaPED];
    SET IDENTITY_INSERT PBR.[VinculacionProgramaPED] OFF;
END;
GO

IF OBJECT_ID(N'PBR.WorkflowEstado', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[WorkflowEstado]
    (
        [PKIdWorkflowEstado] int IDENTITY(1,1) NOT NULL,
        [FKIdWorkflowTemplate_PBR] int NOT NULL,
        [Codigo] nvarchar(30) NOT NULL,
        [Nombre] nvarchar(200) NOT NULL,
        [Orden] int NOT NULL,
        [EsInicial] bit NOT NULL CONSTRAINT [DF_PBR_WorkflowEstado_EsInicial] DEFAULT ((0)),
        [EsFinal] bit NOT NULL CONSTRAINT [DF_PBR_WorkflowEstado_EsFinal] DEFAULT ((0)),
        [Activo] bit NOT NULL CONSTRAINT [DF_PBR_WorkflowEstado_Activo] DEFAULT ((1)),
        CONSTRAINT [PK_PBR_WorkflowEstado] PRIMARY KEY ([PKIdWorkflowEstado])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[WorkflowEstado])
BEGIN
    SET IDENTITY_INSERT PBR.[WorkflowEstado] ON;
    INSERT INTO PBR.[WorkflowEstado] ([PKIdWorkflowEstado], [FKIdWorkflowTemplate_PBR], [Codigo], [Nombre], [Orden], [EsInicial], [EsFinal], [Activo])
    SELECT [PKIdWorkflowEstado], [FKIdWorkflowTemplate_PBR], [Codigo], [Nombre], [Orden], [EsInicial], [EsFinal], [Activo]
    FROM [GE_Datos].PBR.[WorkflowEstado];
    SET IDENTITY_INSERT PBR.[WorkflowEstado] OFF;
END;
GO

IF OBJECT_ID(N'PBR.WorkflowTemplate', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[WorkflowTemplate]
    (
        [PKIdWorkflowTemplate] int IDENTITY(1,1) NOT NULL,
        [Codigo] nvarchar(30) NOT NULL,
        [Nombre] nvarchar(200) NOT NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_PBR_WorkflowTemplate_Activo] DEFAULT ((1)),
        [FechaCreacion] datetime2(7) NOT NULL CONSTRAINT [DF_PBR_WorkflowTemplate_FechaCreacion] DEFAULT (getdate()),
        CONSTRAINT [PK_PBR_WorkflowTemplate] PRIMARY KEY ([PKIdWorkflowTemplate])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[WorkflowTemplate])
BEGIN
    SET IDENTITY_INSERT PBR.[WorkflowTemplate] ON;
    INSERT INTO PBR.[WorkflowTemplate] ([PKIdWorkflowTemplate], [Codigo], [Nombre], [Activo], [FechaCreacion])
    SELECT [PKIdWorkflowTemplate], [Codigo], [Nombre], [Activo], [FechaCreacion]
    FROM [GE_Datos].PBR.[WorkflowTemplate];
    SET IDENTITY_INSERT PBR.[WorkflowTemplate] OFF;
END;
GO

IF OBJECT_ID(N'PBR.WorkflowTransicion', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.[WorkflowTransicion]
    (
        [PKIdWorkflowTransicion] int IDENTITY(1,1) NOT NULL,
        [FKIdWorkflowTemplate_PBR] int NOT NULL,
        [FKIdEstadoOrigen_PBR] int NOT NULL,
        [FKIdEstadoDestino_PBR] int NOT NULL,
        [Nombre] nvarchar(200) NOT NULL,
        [RolesPermitidos] nvarchar(500) NULL,
        [RequiereFirma] bit NOT NULL CONSTRAINT [DF_PBR_WorkflowTransicion_RequiereFirma] DEFAULT ((0)),
        [Activo] bit NOT NULL CONSTRAINT [DF_PBR_WorkflowTransicion_Activo] DEFAULT ((1)),
        CONSTRAINT [PK_PBR_WorkflowTransicion] PRIMARY KEY ([PKIdWorkflowTransicion])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[WorkflowTransicion])
BEGIN
    SET IDENTITY_INSERT PBR.[WorkflowTransicion] ON;
    INSERT INTO PBR.[WorkflowTransicion] ([PKIdWorkflowTransicion], [FKIdWorkflowTemplate_PBR], [FKIdEstadoOrigen_PBR], [FKIdEstadoDestino_PBR], [Nombre], [RolesPermitidos], [RequiereFirma], [Activo])
    SELECT [PKIdWorkflowTransicion], [FKIdWorkflowTemplate_PBR], [FKIdEstadoOrigen_PBR], [FKIdEstadoDestino_PBR], [Nombre], [RolesPermitidos], [RequiereFirma], [Activo]
    FROM [GE_Datos].PBR.[WorkflowTransicion];
    SET IDENTITY_INSERT PBR.[WorkflowTransicion] OFF;
END;
GO

BEGIN TRY
    BEGIN TRAN;

    DECLARE @UsuarioSistema int = 1;
    DECLARE @GFDefault int = (SELECT TOP (1) PKIdGF FROM PRES.GF ORDER BY PKIdGF);
    DECLARE @FNDefault int = (SELECT TOP (1) PKIdFN FROM PRES.FN ORDER BY PKIdFN);
    DECLARE @SFDefault int = (SELECT TOP (1) PKIdSF FROM PRES.SF ORDER BY PKIdSF);
    DECLARE @URDefault int = (SELECT TOP (1) PKIdUR FROM PRES.UR ORDER BY PKIdUR);
    DECLARE @GrupoPresupuestoDefault int = (SELECT TOP (1) PKIdGrupoPresupuesto FROM PRES.GrupoPresupuesto ORDER BY PKIdGrupoPresupuesto);
    DECLARE @ActividadDefault int = (SELECT TOP (1) PKIdActividadInstitucional FROM SIS.ActividadInstitucional ORDER BY PKIdActividadInstitucional);
    DECLARE @CapituloDefault int = (SELECT TOP (1) PKIdCapitulo FROM SIS.Capitulo ORDER BY PKIdCapitulo);

    INSERT INTO SIS.Concepto (FKIdCapitulo_SIS, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
    SELECT
        COALESCE(sc.PKIdCapitulo, @CapituloDefault),
        LEFT(cg.Codigo, 60),
        LEFT(cg.Nombre, 240),
        cg.Activo,
        COALESCE(cg.FechaCreacion, sysdatetime()),
        @UsuarioSistema
    FROM [GE_Datos].PBR.ConceptoGasto cg
    LEFT JOIN [GE_Datos].PBR.CapituloGasto cap ON cap.Id = cg.FKIdCapitulo
    LEFT JOIN SIS.Capitulo sc ON sc.Clave = cap.Codigo
    WHERE NOT EXISTS (SELECT 1 FROM SIS.Concepto x WHERE x.Clave = cg.Codigo);

    ;WITH Dest AS
    (
        SELECT Clave, MIN(PKIdConcepto) AS PKIdConcepto
        FROM SIS.Concepto
        GROUP BY Clave
    )
    MERGE PBR.MigracionMap AS tgt
    USING
    (
        SELECT N'ConceptoGasto' AS EntidadOrigen, cg.Id AS IdOrigen, N'SIS.Concepto' AS EntidadDestino,
               d.PKIdConcepto AS IdDestino, cg.Codigo AS Clave, cg.Nombre AS Descripcion
        FROM [GE_Datos].PBR.ConceptoGasto cg
        INNER JOIN Dest d ON d.Clave = cg.Codigo
    ) AS src
    ON tgt.EntidadOrigen = src.EntidadOrigen AND tgt.IdOrigen = src.IdOrigen
    WHEN MATCHED THEN UPDATE SET EntidadDestino = src.EntidadDestino, IdDestino = src.IdDestino,
        Clave = src.Clave, Descripcion = src.Descripcion, FechaMigracion = sysdatetime()
    WHEN NOT MATCHED THEN INSERT (EntidadOrigen, IdOrigen, EntidadDestino, IdDestino, Clave, Descripcion)
        VALUES (src.EntidadOrigen, src.IdOrigen, src.EntidadDestino, src.IdDestino, src.Clave, src.Descripcion);

    IF NOT EXISTS (SELECT 1 FROM PBR.PartidaGenerica)
    BEGIN
        SET IDENTITY_INSERT PBR.PartidaGenerica ON;
        INSERT INTO PBR.PartidaGenerica
        (
            Id,
            Codigo,
            Nombre,
            Descripcion,
            FKIdConcepto_SIS,
            Activa,
            FechaCreacion
        )
        SELECT
            pg.Id,
            LEFT(pg.Codigo, 10),
            LEFT(pg.Nombre, 500),
            pg.Descripcion,
            mm.IdDestino,
            pg.Activa,
            COALESCE(pg.FechaCreacion, sysdatetime())
        FROM [GE_Datos].PBR.PartidaGenerica pg
        INNER JOIN PBR.MigracionMap mm ON mm.EntidadOrigen = N'ConceptoGasto' AND mm.IdOrigen = pg.FKIdConcepto;
        SET IDENTITY_INSERT PBR.PartidaGenerica OFF;
    END;

    INSERT INTO SIS.Partida (FKIdConcepto_SIS, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
    SELECT
        mm.IdDestino,
        LEFT(pe.Codigo, 20),
        LEFT(pe.Nombre, 510),
        pe.Activa,
        COALESCE(pe.FechaCreacion, sysdatetime()),
        @UsuarioSistema
    FROM [GE_Datos].PBR.PartidaEspecifica pe
    LEFT JOIN [GE_Datos].PBR.PartidaGenerica pg ON pg.Id = pe.FKIdGenerica
    LEFT JOIN PBR.MigracionMap mm ON mm.EntidadOrigen = N'ConceptoGasto' AND mm.IdOrigen = pg.FKIdConcepto
    WHERE NOT EXISTS (SELECT 1 FROM SIS.Partida x WHERE x.Clave = pe.Codigo);

    ;WITH Dest AS
    (
        SELECT Clave, MIN(PKIdPartida) AS PKIdPartida
        FROM SIS.Partida
        GROUP BY Clave
    )
    MERGE PBR.MigracionMap AS tgt
    USING
    (
        SELECT N'PartidaEspecifica' AS EntidadOrigen, pe.Id AS IdOrigen, N'SIS.Partida' AS EntidadDestino,
               d.PKIdPartida AS IdDestino, pe.Codigo AS Clave, pe.Nombre AS Descripcion
        FROM [GE_Datos].PBR.PartidaEspecifica pe
        INNER JOIN Dest d ON d.Clave = pe.Codigo
    ) AS src
    ON tgt.EntidadOrigen = src.EntidadOrigen AND tgt.IdOrigen = src.IdOrigen
    WHEN MATCHED THEN UPDATE SET EntidadDestino = src.EntidadDestino, IdDestino = src.IdDestino,
        Clave = src.Clave, Descripcion = src.Descripcion, FechaMigracion = sysdatetime()
    WHEN NOT MATCHED THEN INSERT (EntidadOrigen, IdOrigen, EntidadDestino, IdDestino, Clave, Descripcion)
        VALUES (src.EntidadOrigen, src.IdOrigen, src.EntidadDestino, src.IdDestino, src.Clave, src.Descripcion);

    INSERT INTO PRES.PY (Clave, Descripcion, NombreProyecto, ProyectoInversion, DescripcionProyecto, Activo, FechaCreacion, UsuarioCreacion)
    SELECT LEFT(pi.Codigo, 15), LEFT(pi.Nombre, 300), LEFT(pi.Nombre, 1000), 1,
           LEFT(COALESCE(CONVERT(nvarchar(max), pi.Descripcion), pi.Nombre), 1000),
           pi.Activo, COALESCE(pi.FechaCreacion, sysdatetime()), @UsuarioSistema
    FROM [GE_Datos].PBR.ProyectoInversion pi
    WHERE NOT EXISTS (SELECT 1 FROM PRES.PY x WHERE x.Clave = pi.Codigo);

    ;WITH Dest AS
    (
        SELECT Clave, MIN(PKIdPY) AS PKIdPY
        FROM PRES.PY
        GROUP BY Clave
    )
    MERGE PBR.MigracionMap AS tgt
    USING
    (
        SELECT N'ProyectoInversion' AS EntidadOrigen, pi.PKIdProyectoInversion AS IdOrigen, N'PRES.PY' AS EntidadDestino,
               d.PKIdPY AS IdDestino, pi.Codigo AS Clave, pi.Nombre AS Descripcion
        FROM [GE_Datos].PBR.ProyectoInversion pi
        INNER JOIN Dest d ON d.Clave = pi.Codigo
    ) AS src
    ON tgt.EntidadOrigen = src.EntidadOrigen AND tgt.IdOrigen = src.IdOrigen
    WHEN MATCHED THEN UPDATE SET EntidadDestino = src.EntidadDestino, IdDestino = src.IdDestino,
        Clave = src.Clave, Descripcion = src.Descripcion, FechaMigracion = sysdatetime()
    WHEN NOT MATCHED THEN INSERT (EntidadOrigen, IdOrigen, EntidadDestino, IdDestino, Clave, Descripcion)
        VALUES (src.EntidadOrigen, src.IdOrigen, src.EntidadDestino, src.IdDestino, src.Clave, src.Descripcion);

    INSERT INTO PRES.FN (FKIdGF_PRES, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
    SELECT COALESCE(gf.PKIdGF, @GFDefault), TRY_CONVERT(int, f.Codigo), LEFT(f.Nombre, 100),
           f.Activo, COALESCE(f.FechaCreacion, sysdatetime()), @UsuarioSistema
    FROM [GE_Datos].PBR.Funcion f
    LEFT JOIN [GE_Datos].PBR.Finalidad pf ON pf.PKIdFinalidad = f.FKIdFinalidad_PBR
    LEFT JOIN PRES.GF gf ON CONVERT(nvarchar(20), gf.Clave) = pf.Codigo
    WHERE TRY_CONVERT(int, f.Codigo) IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM PRES.FN x WHERE x.Clave = TRY_CONVERT(int, f.Codigo));

    ;WITH Dest AS
    (
        SELECT Clave, MIN(PKIdFN) AS PKIdFN
        FROM PRES.FN
        GROUP BY Clave
    )
    MERGE PBR.MigracionMap AS tgt
    USING
    (
        SELECT N'Funcion' AS EntidadOrigen, f.PKIdFuncion AS IdOrigen, N'PRES.FN' AS EntidadDestino,
               d.PKIdFN AS IdDestino, f.Codigo AS Clave, f.Nombre AS Descripcion
        FROM [GE_Datos].PBR.Funcion f
        INNER JOIN Dest d ON d.Clave = TRY_CONVERT(int, f.Codigo)
    ) AS src
    ON tgt.EntidadOrigen = src.EntidadOrigen AND tgt.IdOrigen = src.IdOrigen
    WHEN MATCHED THEN UPDATE SET EntidadDestino = src.EntidadDestino, IdDestino = src.IdDestino,
        Clave = src.Clave, Descripcion = src.Descripcion, FechaMigracion = sysdatetime()
    WHEN NOT MATCHED THEN INSERT (EntidadOrigen, IdOrigen, EntidadDestino, IdDestino, Clave, Descripcion)
        VALUES (src.EntidadOrigen, src.IdOrigen, src.EntidadDestino, src.IdDestino, src.Clave, src.Descripcion);

    INSERT INTO PRES.SF (FKIdFN_PRES, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
    SELECT COALESCE(mm.IdDestino, @FNDefault), TRY_CONVERT(int, sf.Codigo), LEFT(sf.Nombre, 100),
           sf.Activa, COALESCE(sf.FechaCreacion, sysdatetime()), @UsuarioSistema
    FROM [GE_Datos].PBR.Subfuncion sf
    LEFT JOIN PBR.MigracionMap mm ON mm.EntidadOrigen = N'Funcion' AND mm.IdOrigen = sf.FKIdFuncion_PBR
    WHERE TRY_CONVERT(int, sf.Codigo) IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM PRES.SF x WHERE x.Clave = TRY_CONVERT(int, sf.Codigo));

    ;WITH Dest AS
    (
        SELECT Clave, MIN(PKIdSF) AS PKIdSF
        FROM PRES.SF
        GROUP BY Clave
    )
    MERGE PBR.MigracionMap AS tgt
    USING
    (
        SELECT N'Subfuncion' AS EntidadOrigen, sf.PKIdSubfuncion AS IdOrigen, N'PRES.SF' AS EntidadDestino,
               d.PKIdSF AS IdDestino, sf.Codigo AS Clave, sf.Nombre AS Descripcion
        FROM [GE_Datos].PBR.Subfuncion sf
        INNER JOIN Dest d ON d.Clave = TRY_CONVERT(int, sf.Codigo)
    ) AS src
    ON tgt.EntidadOrigen = src.EntidadOrigen AND tgt.IdOrigen = src.IdOrigen
    WHEN MATCHED THEN UPDATE SET EntidadDestino = src.EntidadDestino, IdDestino = src.IdDestino,
        Clave = src.Clave, Descripcion = src.Descripcion, FechaMigracion = sysdatetime()
    WHEN NOT MATCHED THEN INSERT (EntidadOrigen, IdOrigen, EntidadDestino, IdDestino, Clave, Descripcion)
        VALUES (src.EntidadOrigen, src.IdOrigen, src.EntidadDestino, src.IdDestino, src.Clave, src.Descripcion);

    INSERT INTO PRES.UR (FKIdGrupoPresupuesto_PRES, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
    SELECT @GrupoPresupuestoDefault, LEFT(ur.Codigo, 20), LEFT(ur.Nombre, 100),
           ur.Activa, COALESCE(ur.FechaCreacion, sysdatetime()), COALESCE(ur.UsuarioCreacion, @UsuarioSistema)
    FROM [GE_Datos].PBR.UnidadResponsable ur
    WHERE NOT EXISTS (SELECT 1 FROM PRES.UR x WHERE x.Clave = ur.Codigo);

    ;WITH Dest AS
    (
        SELECT Clave, MIN(PKIdUR) AS PKIdUR
        FROM PRES.UR
        GROUP BY Clave
    )
    MERGE PBR.MigracionMap AS tgt
    USING
    (
        SELECT N'UnidadResponsable' AS EntidadOrigen, ur.PKIdUnidadResponsable AS IdOrigen, N'PRES.UR' AS EntidadDestino,
               d.PKIdUR AS IdDestino, ur.Codigo AS Clave, ur.Nombre AS Descripcion
        FROM [GE_Datos].PBR.UnidadResponsable ur
        INNER JOIN Dest d ON d.Clave = ur.Codigo
    ) AS src
    ON tgt.EntidadOrigen = src.EntidadOrigen AND tgt.IdOrigen = src.IdOrigen
    WHEN MATCHED THEN UPDATE SET EntidadDestino = src.EntidadDestino, IdDestino = src.IdDestino,
        Clave = src.Clave, Descripcion = src.Descripcion, FechaMigracion = sysdatetime()
    WHEN NOT MATCHED THEN INSERT (EntidadOrigen, IdOrigen, EntidadDestino, IdDestino, Clave, Descripcion)
        VALUES (src.EntidadOrigen, src.IdOrigen, src.EntidadDestino, src.IdDestino, src.Clave, src.Descripcion);

    ;WITH Src AS
    (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY Codigo ORDER BY PKIdProgramaPresupuestario) AS rn
        FROM [GE_Datos].PBR.ProgramaPresupuestario
    )
    INSERT INTO PRES.Programa
    (
        Clave,
        Descripcion,
        Activo,
        FechaCreacion,
        UsuarioCreacion,
        FKIdUR_PRES,
        FKIdGF_PRES,
        FKIdFN_PRES,
        FKIdSF_PRES,
        FKIdActividadInstitucional_SIS,
        Objetivo
    )
    SELECT LEFT(pp.Codigo, 100), LEFT(pp.Nombre, 510), pp.Activo, COALESCE(pp.FechaCreacion, sysdatetime()),
           COALESCE(pp.UsuarioCreacion, @UsuarioSistema), @URDefault, @GFDefault,
           COALESCE(mfn.IdDestino, @FNDefault), COALESCE(msf.IdDestino, @SFDefault),
           @ActividadDefault, LEFT(pp.DescripcionPrograma, 1000)
    FROM Src pp
    LEFT JOIN PBR.MigracionMap mfn ON mfn.EntidadOrigen = N'Funcion' AND mfn.IdOrigen = pp.FKIdFuncion_PBR
    LEFT JOIN PBR.MigracionMap msf ON msf.EntidadOrigen = N'Subfuncion' AND msf.IdOrigen = pp.FKIdSubfuncion_PBR
    WHERE pp.rn = 1
      AND NOT EXISTS (SELECT 1 FROM PRES.Programa x WHERE x.Clave = pp.Codigo);

    ;WITH Dest AS
    (
        SELECT Clave, MIN(PKIdPrograma) AS PKIdPrograma
        FROM PRES.Programa
        GROUP BY Clave
    )
    MERGE PBR.MigracionMap AS tgt
    USING
    (
        SELECT N'ProgramaPresupuestario' AS EntidadOrigen, pp.PKIdProgramaPresupuestario AS IdOrigen,
               N'PRES.Programa' AS EntidadDestino, d.PKIdPrograma AS IdDestino, pp.Codigo AS Clave,
               pp.Nombre AS Descripcion
        FROM [GE_Datos].PBR.ProgramaPresupuestario pp
        INNER JOIN Dest d ON d.Clave = pp.Codigo
    ) AS src
    ON tgt.EntidadOrigen = src.EntidadOrigen AND tgt.IdOrigen = src.IdOrigen
    WHEN MATCHED THEN UPDATE SET EntidadDestino = src.EntidadDestino, IdDestino = src.IdDestino,
        Clave = src.Clave, Descripcion = src.Descripcion, FechaMigracion = sysdatetime()
    WHEN NOT MATCHED THEN INSERT (EntidadOrigen, IdOrigen, EntidadDestino, IdDestino, Clave, Descripcion)
        VALUES (src.EntidadOrigen, src.IdOrigen, src.EntidadDestino, src.IdDestino, src.Clave, src.Descripcion);

    COMMIT;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK;
    THROW;
END CATCH;
GO

CREATE OR ALTER VIEW PBR.vwPartidaGenerica
AS
SELECT pg.*, c.Descripcion AS ConceptoDescripcion
FROM PBR.PartidaGenerica pg
LEFT JOIN SIS.Concepto c ON c.PKIdConcepto = pg.FKIdConcepto_SIS;
GO

CREATE OR ALTER VIEW PBR.vwAlertaConfig
AS
SELECT ac.*, prog.IdDestino AS FKIdPrograma_PRES, prog.Descripcion AS ProgramaDescripcion,
       i.Nombre AS IndicadorNombre, i.Meta AS IndicadorMeta
FROM PBR.AlertaConfig ac
LEFT JOIN PBR.MigracionMap prog ON prog.EntidadOrigen = N'ProgramaPresupuestario' AND prog.IdOrigen = ac.FKIdProgramaPresupuestario_PBR
LEFT JOIN PBR.Indicador i ON i.PKIdIndicador = ac.FKIdIndicador_PBR;
GO

CREATE OR ALTER VIEW PBR.vwAuditoriaCambio
AS
SELECT *
FROM PBR.AuditoriaCambio;
GO

CREATE OR ALTER VIEW PBR.vwNotificacion
AS
SELECT *
FROM PBR.Notificacion;
GO

CREATE OR ALTER VIEW PBR.vwPartidaGasto
AS
SELECT pg.*, pp.Anio, prog.IdDestino AS FKIdPrograma_PRES, prog.Descripcion AS ProgramaDescripcion,
       cap.Descripcion AS CapituloDescripcion, con.Descripcion AS ConceptoDescripcion,
       par.Descripcion AS PartidaDescripcion, tg.Descripcion AS TipoGastoDescripcion
FROM PBR.PartidaGasto pg
LEFT JOIN PBR.PresupuestoPrograma pp ON pp.PKIdPresupuestoPrograma = pg.FKIdPresupuestoPrograma_PBR
LEFT JOIN PBR.MigracionMap prog ON prog.EntidadOrigen = N'ProgramaPresupuestario' AND prog.IdOrigen = pp.FKIdProgramaPresupuestario_PBR
LEFT JOIN SIS.Capitulo cap ON cap.PKIdCapitulo = pg.FKIdCapitulo_SIS
LEFT JOIN SIS.Concepto con ON con.PKIdConcepto = pg.FKIdConcepto_SIS
LEFT JOIN SIS.Partida par ON par.PKIdPartida = pg.FKIdPartida_SIS
LEFT JOIN PRES.TipoGasto tg ON tg.PKIdTipoGasto = pg.FKIdTipoGasto_PRES;
GO

CREATE OR ALTER VIEW PBR.vwPresupuestoPrograma
AS
SELECT pp.*, prog.IdDestino AS FKIdPrograma_PRES, prog.Clave AS ProgramaClave, prog.Descripcion AS ProgramaDescripcion,
       ent.Nombre AS EntidadNombre, ur.Descripcion AS UnidadResponsableDescripcion,
       ff.Descripcion AS FuenteFinanciamientoDescripcion, py.Descripcion AS ProyectoInversionDescripcion, r.Nombre AS RegionNombre
FROM PBR.PresupuestoPrograma pp
LEFT JOIN PBR.MigracionMap prog ON prog.EntidadOrigen = N'ProgramaPresupuestario' AND prog.IdOrigen = pp.FKIdProgramaPresupuestario_PBR
LEFT JOIN PBR.Entidad ent ON ent.PKIdEntidad = pp.FKIdEntidad_PBR
LEFT JOIN PRES.UR ur ON ur.PKIdUR = pp.FKIdUnidadResponsable_PRES
LEFT JOIN PRES.FuenteFinanciamiento ff ON ff.PKIdFuenteFinanciamiento = pp.FKIdFuenteFinanciamiento_PRES
LEFT JOIN PRES.PY py ON py.PKIdPY = pp.FKIdProyectoInversion_PRES
LEFT JOIN PBR.Region r ON r.Id = pp.FKIdRegion_PBR;
GO

CREATE OR ALTER VIEW PBR.vwAnteproyecto
AS
SELECT a.*, prog.IdDestino AS FKIdPrograma_PRES, prog.Descripcion AS ProgramaDescripcion,
       pp.Anio AS PresupuestoAnio, mv.Version AS MirVersion
FROM PBR.Anteproyecto a
LEFT JOIN PBR.MigracionMap prog ON prog.EntidadOrigen = N'ProgramaPresupuestario' AND prog.IdOrigen = a.FKIdProgramaPresupuestario_PBR
LEFT JOIN PBR.PresupuestoPrograma pp ON pp.PKIdPresupuestoPrograma = a.FKIdPresupuestoPrograma_PBR
LEFT JOIN PBR.MirVersion mv ON mv.PKIdMirVersion = a.FKIdMirVersion_PBR;
GO

CREATE OR ALTER VIEW PBR.vwCalendarioPresupuesto
AS
SELECT c.*, prog.IdDestino AS FKIdPrograma_PRES, prog.Descripcion AS ProgramaDescripcion
FROM PBR.CalendarioPresupuesto c
LEFT JOIN PBR.MigracionMap prog ON prog.EntidadOrigen = N'ProgramaPresupuestario' AND prog.IdOrigen = c.FKIdProgramaPresupuestario_PBR;
GO

CREATE OR ALTER VIEW PBR.vwDiagnostico
AS
SELECT d.*, prog.IdDestino AS FKIdPrograma_PRES, prog.Descripcion AS ProgramaDescripcion
FROM PBR.Diagnostico d
LEFT JOIN PBR.MigracionMap prog ON prog.EntidadOrigen = N'ProgramaPresupuestario' AND prog.IdOrigen = d.FKIdProgramaPresupuestario_PBR;
GO

CREATE OR ALTER VIEW PBR.vwMirNivel
AS
SELECT mn.*, prog.IdDestino AS FKIdPrograma_PRES, prog.Descripcion AS ProgramaDescripcion
FROM PBR.MirNivel mn
LEFT JOIN PBR.MigracionMap prog ON prog.EntidadOrigen = N'ProgramaPresupuestario' AND prog.IdOrigen = mn.FKIdProgramaPresupuestario_PBR;
GO

CREATE OR ALTER VIEW PBR.vwIndicador
AS
SELECT i.*, mn.Nivel, mn.Objetivo AS MirObjetivo, prog.IdDestino AS FKIdPrograma_PRES, prog.Descripcion AS ProgramaDescripcion
FROM PBR.Indicador i
LEFT JOIN PBR.MirNivel mn ON mn.PKIdMirNivel = i.FKIdMirNivel_PBR
LEFT JOIN PBR.MigracionMap prog ON prog.EntidadOrigen = N'ProgramaPresupuestario' AND prog.IdOrigen = mn.FKIdProgramaPresupuestario_PBR;
GO

CREATE OR ALTER VIEW PBR.vwAvanceIndicador
AS
SELECT ai.*, i.Nombre AS IndicadorNombre, i.Meta AS IndicadorMeta
FROM PBR.AvanceIndicador ai
LEFT JOIN PBR.Indicador i ON i.PKIdIndicador = ai.FKIdIndicador_PBR;
GO

CREATE OR ALTER VIEW PBR.vwEvaluacion
AS
SELECT e.*, prog.IdDestino AS FKIdPrograma_PRES, prog.Descripcion AS ProgramaDescripcion
FROM PBR.Evaluacion e
LEFT JOIN PBR.MigracionMap prog ON prog.EntidadOrigen = N'ProgramaPresupuestario' AND prog.IdOrigen = e.FKIdProgramaPresupuestario_PBR;
GO

CREATE OR ALTER VIEW PBR.vwEvaluacionConsistencia
AS
SELECT ec.*, prog.IdDestino AS FKIdPrograma_PRES, prog.Descripcion AS ProgramaDescripcion
FROM PBR.EvaluacionConsistencia ec
LEFT JOIN PBR.MigracionMap prog ON prog.EntidadOrigen = N'ProgramaPresupuestario' AND prog.IdOrigen = ec.FKIdProgramaPresupuestario_PBR;
GO

CREATE OR ALTER VIEW PBR.vwEvaluacionConsistenciaRespuesta
AS
SELECT r.*, p.Seccion, p.Numero, p.Pregunta, ec.Anio, ec.Estado AS EvaluacionEstado
FROM PBR.EvaluacionConsistenciaRespuesta r
LEFT JOIN PBR.EvaluacionConsistenciaPregunta p ON p.PKIdPregunta = r.FKIdPregunta_PBR
LEFT JOIN PBR.EvaluacionConsistencia ec ON ec.PKIdEvaluacionConsistencia = r.FKIdEvaluacionConsistencia_PBR;
GO

CREATE OR ALTER VIEW PBR.vwInformeTrimestral
AS
SELECT it.*, prog.IdDestino AS FKIdPrograma_PRES, prog.Descripcion AS ProgramaDescripcion
FROM PBR.InformeTrimestral it
LEFT JOIN PBR.MigracionMap prog ON prog.EntidadOrigen = N'ProgramaPresupuestario' AND prog.IdOrigen = it.FKIdProgramaPresupuestario_PBR;
GO

CREATE OR ALTER VIEW PBR.vwPoblacionObjetivo
AS
SELECT po.*, prog.IdDestino AS FKIdPrograma_PRES, prog.Descripcion AS ProgramaDescripcion
FROM PBR.PoblacionObjetivo po
LEFT JOIN PBR.MigracionMap prog ON prog.EntidadOrigen = N'ProgramaPresupuestario' AND prog.IdOrigen = po.FKIdProgramaPresupuestario_PBR;
GO

CREATE OR ALTER VIEW PBR.vwProyeccionMultianual
AS
SELECT pm.*, prog.IdDestino AS FKIdPrograma_PRES, prog.Descripcion AS ProgramaDescripcion
FROM PBR.ProyeccionMultianual pm
LEFT JOIN PBR.MigracionMap prog ON prog.EntidadOrigen = N'ProgramaPresupuestario' AND prog.IdOrigen = pm.FKIdProgramaPresupuestario_PBR;
GO

CREATE OR ALTER VIEW PBR.vwReglaOperacion
AS
SELECT ro.*, prog.IdDestino AS FKIdPrograma_PRES, prog.Descripcion AS ProgramaDescripcion
FROM PBR.ReglaOperacion ro
LEFT JOIN PBR.MigracionMap prog ON prog.EntidadOrigen = N'ProgramaPresupuestario' AND prog.IdOrigen = ro.FKIdProgramaPresupuestario_PBR;
GO

CREATE OR ALTER VIEW PBR.vwVinculacionProgramaODS
AS
SELECT v.*, prog.IdDestino AS FKIdPrograma_PRES, prog.Descripcion AS ProgramaDescripcion,
       ods.Numero AS ObjetivoODSNumero, ods.Nombre AS ObjetivoODSNombre,
       meta.Numero AS MetaODSNumero, meta.Descripcion AS MetaODSDescripcion
FROM PBR.VinculacionProgramaODS v
LEFT JOIN PBR.MigracionMap prog ON prog.EntidadOrigen = N'ProgramaPresupuestario' AND prog.IdOrigen = v.FKIdProgramaPresupuestario_PBR
LEFT JOIN PBR.ObjetivoODS ods ON ods.PKIdObjetivoODS = v.FKIdObjetivoODS_PBR
LEFT JOIN PBR.MetaODS meta ON meta.PKIdMetaODS = v.FKIdMetaODS_PBR;
GO

CREATE OR ALTER VIEW PBR.vwVinculacionProgramaPED
AS
SELECT v.*, prog.IdDestino AS FKIdPrograma_PRES, prog.Descripcion AS ProgramaDescripcion,
       ped.Codigo AS ObjetivoPEDCodigo, ped.Objetivo AS ObjetivoPEDDescripcion
FROM PBR.VinculacionProgramaPED v
LEFT JOIN PBR.MigracionMap prog ON prog.EntidadOrigen = N'ProgramaPresupuestario' AND prog.IdOrigen = v.FKIdProgramaPresupuestario_PBR
LEFT JOIN PBR.ObjetivoPED ped ON ped.PKIdObjetivoPED = v.FKIdObjetivoPED_PBR;
GO

CREATE OR ALTER VIEW PBR.vwArbolNodo
AS
SELECT n.*, p.Codigo AS PadreCodigo, p.Descripcion AS PadreDescripcion, d.ProblemaCentral
FROM PBR.ArbolNodo n
LEFT JOIN PBR.ArbolNodo p ON p.PKIdArbolNodo = n.FKIdArbolNodo_Padre_PBR
LEFT JOIN PBR.Diagnostico d ON d.PKIdDiagnostico = n.FKIdDiagnostico_PBR;
GO

CREATE OR ALTER VIEW PBR.vwAsm
AS
SELECT a.*, e.Nombre AS EvaluacionNombre, e.EjercicioFiscal
FROM PBR.Asm a
LEFT JOIN PBR.Evaluacion e ON e.PKIdEvaluacion = a.FKIdEvaluacion_PBR;
GO

CREATE OR ALTER VIEW PBR.vwRecomendacionEvaluacion
AS
SELECT r.*, e.Nombre AS EvaluacionNombre, e.EjercicioFiscal
FROM PBR.RecomendacionEvaluacion r
LEFT JOIN PBR.Evaluacion e ON e.PKIdEvaluacion = r.FKIdEvaluacion_PBR;
GO

CREATE OR ALTER VIEW PBR.vwTechoGasto
AS
SELECT tg.*, e.Nombre AS EntidadNombre
FROM PBR.TechoGasto tg
LEFT JOIN PBR.Entidad e ON e.PKIdEntidad = tg.FKIdEntidad_PBR;
GO

CREATE OR ALTER VIEW PBR.vwWorkflowEstado
AS
SELECT e.*, t.Codigo AS WorkflowCodigo, t.Nombre AS WorkflowNombre
FROM PBR.WorkflowEstado e
LEFT JOIN PBR.WorkflowTemplate t ON t.PKIdWorkflowTemplate = e.FKIdWorkflowTemplate_PBR;
GO

CREATE OR ALTER VIEW PBR.vwWorkflowTransicion
AS
SELECT tr.*, t.Codigo AS WorkflowCodigo, t.Nombre AS WorkflowNombre,
       eo.Codigo AS EstadoOrigenCodigo, eo.Nombre AS EstadoOrigenNombre,
       ed.Codigo AS EstadoDestinoCodigo, ed.Nombre AS EstadoDestinoNombre
FROM PBR.WorkflowTransicion tr
LEFT JOIN PBR.WorkflowTemplate t ON t.PKIdWorkflowTemplate = tr.FKIdWorkflowTemplate_PBR
LEFT JOIN PBR.WorkflowEstado eo ON eo.PKIdWorkflowEstado = tr.FKIdEstadoOrigen_PBR
LEFT JOIN PBR.WorkflowEstado ed ON ed.PKIdWorkflowEstado = tr.FKIdEstadoDestino_PBR;
GO
