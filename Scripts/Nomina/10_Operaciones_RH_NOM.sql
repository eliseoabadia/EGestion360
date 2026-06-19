-- Operaciones RH/NOM migradas desde BD_GRP_INVEA.
-- Este script completa las rutas operativas que en el front estaban como pendientes.
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ARITHABORT ON;
SET NUMERIC_ROUNDABORT OFF;
SET NOCOUNT ON;

IF SCHEMA_ID(N'NOM') IS NULL
    EXEC(N'CREATE SCHEMA NOM');
GO

IF OBJECT_ID(N'[NOM].[PeriodoNomina]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[PeriodoNomina] (
        [PKIdPeriodoNomina] int IDENTITY(1,1) NOT NULL CONSTRAINT [PK_NOM_PeriodoNomina] PRIMARY KEY,
        [TipoPeriodo] nvarchar(30) NOT NULL,
        [LegacyTable] nvarchar(128) NOT NULL,
        [LegacyId] int NOT NULL,
        [Anio] int NULL,
        [Mes] int NULL,
        [Periodo] int NULL,
        [FechaInicio] date NULL,
        [FechaFin] date NULL,
        [DiasHabiles] int NULL,
        [DiasInhabiles] int NULL,
        [DiasPeriodo] int NULL,
        [FKIdEmpresa_SIS] int NULL,
        [EsFinMes] bit NULL,
        [EsFinBimestre] bit NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_NOM_PeriodoNomina_Activo] DEFAULT 1
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_NOM_PeriodoNomina_Legacy' AND object_id = OBJECT_ID(N'[NOM].[PeriodoNomina]'))
    CREATE UNIQUE INDEX [UX_NOM_PeriodoNomina_Legacy] ON [NOM].[PeriodoNomina] ([LegacyTable], [LegacyId]);
GO

IF OBJECT_ID(N'[NOM].[TablaFiscal]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[TablaFiscal] (
        [PKIdTablaFiscal] int IDENTITY(1,1) NOT NULL CONSTRAINT [PK_NOM_TablaFiscal] PRIMARY KEY,
        [Catalogo] nvarchar(80) NOT NULL,
        [LegacyTable] nvarchar(128) NOT NULL,
        [LegacyId] int NOT NULL,
        [Clave] nvarchar(50) NULL,
        [Descripcion] nvarchar(250) NULL,
        [Valor1] decimal(19,4) NULL,
        [Valor2] decimal(19,4) NULL,
        [Valor3] decimal(19,4) NULL,
        [Valor4] decimal(19,4) NULL,
        [FechaInicio] date NULL,
        [FechaFin] date NULL,
        [FKIdCatalogoPadre_NOM] int NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_NOM_TablaFiscal_Activo] DEFAULT 1
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_NOM_TablaFiscal_Legacy' AND object_id = OBJECT_ID(N'[NOM].[TablaFiscal]'))
    CREATE UNIQUE INDEX [UX_NOM_TablaFiscal_Legacy] ON [NOM].[TablaFiscal] ([LegacyTable], [LegacyId]);
GO

IF OBJECT_ID(N'[NOM].[EmpleadoExpediente]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[EmpleadoExpediente] (
        [PKIdExpediente] int NOT NULL CONSTRAINT [PK_NOM_EmpleadoExpediente] PRIMARY KEY,
        [FKIdPersona_NOM] int NOT NULL,
        [NombreDocumento] nvarchar(255) NULL,
        [Ruta] nvarchar(1000) NULL,
        [Descripcion] nvarchar(1000) NULL,
        [FechaExpedicion] date NULL,
        [NecesitaRenovacion] bit NULL,
        [FechaRenovacion] date NULL,
        [FKIdTipoExpediente_NOM] int NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_NOM_EmpleadoExpediente_Activo] DEFAULT 1
    );
END;
GO

IF OBJECT_ID(N'[NOM].[PersonaPension]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[PersonaPension] (
        [PKIdPension] int NOT NULL CONSTRAINT [PK_NOM_PersonaPension] PRIMARY KEY,
        [FKIdPersona_NOM] int NOT NULL,
        [NombreBeneficiario] nvarchar(150) NULL,
        [Documento] nvarchar(50) NULL,
        [FechaDocumento] date NULL,
        [Porcentaje] decimal(9,4) NULL,
        [FKIdTipoPension_NOM] int NULL,
        [FechaInicio] datetime2(6) NULL,
        [FechaFin] datetime2(6) NULL,
        [Banco] nvarchar(50) NULL,
        [CuentaBancaria] nvarchar(50) NULL,
        [Clabe] nvarchar(50) NULL,
        [FormaPago] nvarchar(50) NULL,
        [FKIdCuentaContable_SIS] int NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_NOM_PersonaPension_Activo] DEFAULT 1
    );
END;
GO

IF OBJECT_ID(N'[NOM].[MotivoMovimiento]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[MotivoMovimiento] (
        [PKIdMotivoMovimiento] int NOT NULL CONSTRAINT [PK_NOM_MotivoMovimiento] PRIMARY KEY,
        [FKIdMovimiento_RH] int NULL,
        [FKIdClaseMovimiento_RH] int NULL,
        [ClaseMovimiento] nvarchar(100) NULL,
        [Clave] int NULL,
        [Motivo] int NULL,
        [Descripcion] nvarchar(255) NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_NOM_MotivoMovimiento_Activo] DEFAULT 1
    );
END;
GO

IF OBJECT_ID(N'[NOM].[PlazaAutorizada]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[PlazaAutorizada] (
        [PKIdPlazaAutorizada] int NOT NULL CONSTRAINT [PK_NOM_PlazaAutorizada] PRIMARY KEY,
        [FKIdPuesto_NOM] int NULL,
        [FKIdArea_SIS] int NULL,
        [FKIdSituacionPlaza_RH] int NULL,
        [SituacionPlaza] nvarchar(70) NULL,
        [Plaza] int NULL,
        [FechaInicio] datetime2(6) NULL,
        [FechaFin] datetime2(6) NULL,
        [TipoPlaza] int NULL,
        [Documento] nvarchar(255) NULL,
        [FechaDocumento] datetime2(6) NULL,
        [Descripcion] nvarchar(500) NULL,
        [FKIdEmpresa_SIS] int NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_NOM_PlazaAutorizada_Activo] DEFAULT 1
    );
END;
GO

IF OBJECT_ID(N'[NOM].[PersonaPlaza]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[PersonaPlaza] (
        [PKIdPersonaPlaza] int NOT NULL CONSTRAINT [PK_NOM_PersonaPlaza] PRIMARY KEY,
        [FKIdPersona_NOM] int NOT NULL,
        [FKIdPlazaAutorizada_NOM] int NULL,
        [FKIdSituacionPersona_RH] int NULL,
        [SituacionPersona] nvarchar(70) NULL,
        [FKIdNombramiento_NOM] int NULL,
        [FKIdPuesto_NOM] int NULL,
        [FKIdMotivoMovimiento_NOM] int NULL,
        [ZonaEconomica] int NULL,
        [FechaInicio] datetime2(6) NULL,
        [FechaFin] datetime2(6) NULL,
        [Horas] decimal(18,4) NULL,
        [QuincenaInicio] int NULL,
        [QuincenaFin] int NULL,
        [Documento] nvarchar(255) NULL,
        [FormaPago] nvarchar(100) NULL,
        [ChecaTarjeta] smallint NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_NOM_PersonaPlaza_Activo] DEFAULT 1
    );
END;
GO

IF OBJECT_ID(N'[NOM].[MovimientoPersonal]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[MovimientoPersonal] (
        [PKIdMovimientoPersonal] int NOT NULL CONSTRAINT [PK_NOM_MovimientoPersonal] PRIMARY KEY,
        [FKIdPersona_NOM] int NOT NULL,
        [FKIdPlazaAutorizada_NOM] int NULL,
        [FKIdMotivoMovimiento_NOM] int NULL,
        [FKIdNombramiento_NOM] int NULL,
        [FKIdSituacionMovimiento_RH] int NULL,
        [SituacionMovimiento] nvarchar(64) NULL,
        [FKIdPuesto_NOM] int NULL,
        [FKIdArea_SIS] int NULL,
        [Documento] nvarchar(255) NULL,
        [FechaDocumento] date NULL,
        [FechaCaptura] date NULL,
        [QuincenaInicioProceso] int NULL,
        [Observaciones] nvarchar(1000) NULL,
        [ChecaTarjeta] smallint NULL,
        [AplicaMovimiento] smallint NULL,
        [FechaInicio] date NULL,
        [FechaFin] date NULL,
        [Horas] int NULL,
        [Importe] decimal(19,4) NULL,
        [Consecutivo] int NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_NOM_MovimientoPersonal_Activo] DEFAULT 1
    );
END;
GO

IF OBJECT_ID(N'[NOM].[Incidencia]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[Incidencia] (
        [PKIdIncidencia] int NOT NULL CONSTRAINT [PK_NOM_Incidencia] PRIMARY KEY,
        [FKIdPersona_NOM] int NOT NULL,
        [FKIdTipoIncidencia_NOM] int NULL,
        [Fecha] date NULL,
        [Comentario] nvarchar(1000) NULL,
        [FKIdTipoJustificacion_NOM] int NULL,
        [AplicaDescuento] bit NULL,
        [ComentarioJustificacion] nvarchar(1000) NULL,
        [FKIdPeriodoQuincenal_SIS] int NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_NOM_Incidencia_Activo] DEFAULT 1
    );
END;
GO

IF OBJECT_ID(N'[NOM].[Vacacion]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[Vacacion] (
        [PKIdVacacion] int NOT NULL CONSTRAINT [PK_NOM_Vacacion] PRIMARY KEY,
        [FKIdPeriodoVacaciones_SIS] int NULL,
        [FKIdPersona_NOM] int NOT NULL,
        [FechaInicio] datetime2(6) NULL,
        [FechaFin] datetime2(6) NULL,
        [FKIdPersonaJefeFirma_NOM] int NULL,
        [Validado] int NULL,
        [FKIdPersonaJefeValida_NOM] int NULL,
        [FKIdEmpresa_SIS] int NULL,
        [Dias] int NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_NOM_Vacacion_Activo] DEFAULT 1
    );
END;
GO

IF OBJECT_ID(N'[NOM].[Liquidacion]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[Liquidacion] (
        [PKIdLiquidacion] int NOT NULL CONSTRAINT [PK_NOM_Liquidacion] PRIMARY KEY,
        [FKIdContrato_PRES] int NULL,
        [DiasPendientesPago] int NULL,
        [FechaInicioParaAguinaldo] date NULL,
        [FechaBaja] date NULL,
        [DiasDeVacacionesParaCalculo] int NULL,
        [SaldoPendienteVacaciones] decimal(19,4) NULL,
        [BasePorDisminuir] decimal(19,4) NULL,
        [SalarioDiarioBruto] decimal(19,4) NULL,
        [SalarioDiarioIntegrado] decimal(19,4) NULL,
        [FactorIntegracion] decimal(19,4) NULL,
        [VariableDiaria] decimal(19,4) NULL,
        [DiasAguinaldo] decimal(19,4) NULL,
        [DiasVacaciones] decimal(19,4) NULL,
        [PrimaVacacional] decimal(19,4) NULL,
        [FechaUltimoAniversario] date NULL,
        [AnioAntiguedad] decimal(19,4) NULL,
        [DiasPrima] int NULL,
        [SalarioDiarioIntegradoLiquidacion] decimal(19,4) NULL,
        [EsLiquidacion] bit NULL,
        [VacacionesEjercicioAnt] decimal(19,4) NULL,
        [DescuentosXFaltas] int NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_NOM_Liquidacion_Activo] DEFAULT 1
    );
END;
GO

IF DB_ID(N'BD_GRP_INVEA') IS NOT NULL
BEGIN
    DECLARE @Now datetime2(6) = SYSUTCDATETIME();

    IF EXISTS (
        SELECT 1
        FROM [BD_GRP_INVEA].dbo.RH_Persona src
        WHERE NOT EXISTS (SELECT 1 FROM [NOM].[Persona] dst WHERE dst.PKIdPersona = src.Pk_IdPersona)
    )
    BEGIN
        SET IDENTITY_INSERT [NOM].[Persona] ON;

        INSERT INTO [NOM].[Persona] (
            [PKIdPersona], [Clave], [Nombre], [Paterno], [Materno], [Sexo], [FechaNacimiento],
            [ESTADO_CIVIL], [RFC], [Curp], [REG_IMSS], [CORREO_ELECTRONICO],
            [Telefono_particular], [Telefono_movil], [Calle], [Num_exterior], [Num_interior],
            [Colonia], [CP], [Municipio], [Estado], [Fecha_de_Inicio], [TIPO_CONTRATACION],
            [BANCO], [NUMERO_CUENTA], [CLABE], [Activo], [FechaCreacion], [UsuarioCreacion],
            [FechaModificacion], [UsuarioModificacion])
        SELECT
            src.Pk_IdPersona,
            LEFT(COALESCE(NULLIF(src.Empleado, N''), CONVERT(nvarchar(15), src.Pk_IdPersona)), 15),
            LEFT(src.Nombre, 50),
            LEFT(src.Paterno, 50),
            LEFT(src.Materno, 50),
            LEFT(sexo.Descripcion, 10),
            src.FechaNac,
            LEFT(estadoCivil.Descripcion, 20),
            LEFT(src.RFC, 15),
            LEFT(src.CURP, 18),
            LEFT(src.RegIMSS, 12),
            LEFT(src.Email, 250),
            LEFT(src.TelefonoCasa, 15),
            LEFT(src.Celular, 15),
            LEFT(src.Calle, 40),
            LEFT(src.Numero, 10),
            LEFT(src.Interior, 10),
            LEFT(src.Colonia, 40),
            LEFT(src.CP, 6),
            LEFT(municipio.Descripcion, 20),
            LEFT(estado.Descripcion, 30),
            src.FechaIngreso,
            CAST(NULL AS nvarchar(255)),
            LEFT(banco.Descripcion, 100),
            LEFT(src.CuentaBancaria, 25),
            LEFT(src.Clabe, 50),
            CASE WHEN COALESCE(src.CT_LIVE, 1) = 1 THEN 1 ELSE 0 END,
            COALESCE(src.CT_CreatedDate, @Now),
            COALESCE(src.CT_CreatedBy, 1),
            src.CT_ModifiedDate,
            src.CT_ModifiedBy
        FROM [BD_GRP_INVEA].dbo.RH_Persona src
        LEFT JOIN [NOM].[CatalogoSimple] sexo ON sexo.Catalogo = N'Sexo' AND sexo.LegacyId = src.Fk_IdSexo__SIS
        LEFT JOIN [NOM].[CatalogoSimple] estadoCivil ON estadoCivil.Catalogo = N'Estado_Civil' AND estadoCivil.LegacyId = src.Fk_IdEstadoCivil__SIS
        LEFT JOIN [NOM].[CatalogoSimple] municipio ON municipio.Catalogo = N'Municipio' AND municipio.LegacyId = src.Fk_IdMunicipio__SIS
        LEFT JOIN [NOM].[CatalogoSimple] estado ON estado.Catalogo = N'Estado' AND estado.LegacyId = src.Fk_IdEstado__SIS
        LEFT JOIN [NOM].[CatalogoSimple] banco ON banco.Catalogo = N'Banco' AND banco.LegacyId = src.Fk_IdBanco__SIS
        WHERE NOT EXISTS (SELECT 1 FROM [NOM].[Persona] dst WHERE dst.PKIdPersona = src.Pk_IdPersona);

        SET IDENTITY_INSERT [NOM].[Persona] OFF;
    END;

    INSERT INTO [NOM].[CatalogoSimple] ([Catalogo], [LegacyTable], [LegacyId], [Descripcion], [Orden], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT N'Tipo_Expediente', N'SIS_TipoExpediente', src.Pk_IdTipoExpediente, src.Descripcion, src.Pk_IdTipoExpediente, src.CT_CreatedBy, COALESCE(src.CT_CreatedDate, @Now), src.CT_ModifiedBy, src.CT_ModifiedDate, COALESCE(src.CT_LIVE, 1)
    FROM [BD_GRP_INVEA].dbo.SIS_TipoExpediente src
    WHERE NOT EXISTS (
        SELECT 1 FROM [NOM].[CatalogoSimple] dst
        WHERE dst.[Catalogo] = N'Tipo_Expediente'
          AND dst.[LegacyTable] = N'SIS_TipoExpediente'
          AND dst.[LegacyId] = src.Pk_IdTipoExpediente
    );

    INSERT INTO [NOM].[CatalogoSimple] ([Catalogo], [LegacyTable], [LegacyId], [Descripcion], [Orden], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT N'Situacion_Persona', N'RH_SituacionPersona', src.Pk_IdSituacionPersona, src.Descripcion, src.Pk_IdSituacionPersona, src.CT_CreatedBy, COALESCE(src.CT_CreatedDate, @Now), src.CT_ModifiedBy, src.CT_ModifiedDate, COALESCE(src.CT_LIVE, 1)
    FROM [BD_GRP_INVEA].dbo.RH_SituacionPersona src
    WHERE NOT EXISTS (
        SELECT 1 FROM [NOM].[CatalogoSimple] dst
        WHERE dst.[Catalogo] = N'Situacion_Persona'
          AND dst.[LegacyTable] = N'RH_SituacionPersona'
          AND dst.[LegacyId] = src.Pk_IdSituacionPersona
    );

    INSERT INTO [NOM].[CatalogoSimple] ([Catalogo], [LegacyTable], [LegacyId], [Descripcion], [Orden], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT N'Situacion_Plaza', N'RH_SituacionPlaza', src.Pk_IdSituacionPlaza, src.Descripcion, src.Pk_IdSituacionPlaza, src.CT_CreatedBy, COALESCE(src.CT_CreatedDate, @Now), src.CT_ModifiedBy, src.CT_ModifiedDate, COALESCE(src.CT_LIVE, 1)
    FROM [BD_GRP_INVEA].dbo.RH_SituacionPlaza src
    WHERE NOT EXISTS (
        SELECT 1 FROM [NOM].[CatalogoSimple] dst
        WHERE dst.[Catalogo] = N'Situacion_Plaza'
          AND dst.[LegacyTable] = N'RH_SituacionPlaza'
          AND dst.[LegacyId] = src.Pk_IdSituacionPlaza
    );

    INSERT INTO [NOM].[PeriodoNomina] ([TipoPeriodo], [LegacyTable], [LegacyId], [Anio], [Mes], [Periodo], [FechaInicio], [FechaFin], [DiasHabiles], [DiasInhabiles], [EsFinMes], [EsFinBimestre], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT N'Semanal', N'SIS_PeriodoSemanal', Pk_IdPeriodoSemanal, Fk_IdAnio__SIS, Fk_IdMes__SIS, Periodo, F_Inicio, F_Fin, DiasHabiles, DiasInhabiles, EsfinMes, EsfinBimestre, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, COALESCE(CT_LIVE, 1)
    FROM [BD_GRP_INVEA].dbo.SIS_PeriodoSemanal src
    WHERE NOT EXISTS (SELECT 1 FROM [NOM].[PeriodoNomina] dst WHERE dst.LegacyTable = N'SIS_PeriodoSemanal' AND dst.LegacyId = src.Pk_IdPeriodoSemanal);

    INSERT INTO [NOM].[PeriodoNomina] ([TipoPeriodo], [LegacyTable], [LegacyId], [Anio], [Mes], [Periodo], [FechaInicio], [FechaFin], [DiasHabiles], [DiasInhabiles], [EsFinMes], [EsFinBimestre], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT N'Quincenal', N'SIS_PeriodoQuincenal', Pk_IdPeriodoQuincenal, Fk_IdAnio__SIS, Fk_IdMes__SIS, Periodo, F_Inicio, F_Fin, DiasHabiles, DiasInhabiles, EsfinMes, EsfinBimestre, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, COALESCE(CT_LIVE, 1)
    FROM [BD_GRP_INVEA].dbo.SIS_PeriodoQuincenal src
    WHERE NOT EXISTS (SELECT 1 FROM [NOM].[PeriodoNomina] dst WHERE dst.LegacyTable = N'SIS_PeriodoQuincenal' AND dst.LegacyId = src.Pk_IdPeriodoQuincenal);

    INSERT INTO [NOM].[PeriodoNomina] ([TipoPeriodo], [LegacyTable], [LegacyId], [Anio], [Mes], [Periodo], [FechaInicio], [FechaFin], [DiasHabiles], [DiasInhabiles], [EsFinMes], [EsFinBimestre], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT N'Mensual', N'SIS_PeriodoMensual', Pk_IdPeriodoMensual, Fk_IdAnio__SIS, Fk_IdMes__SIS, Periodo, F_Inicio, F_Fin, DiasHabiles, DiasInhabiles, EsfinMes, EsfinBimestre, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, COALESCE(CT_LIVE, 1)
    FROM [BD_GRP_INVEA].dbo.SIS_PeriodoMensual src
    WHERE NOT EXISTS (SELECT 1 FROM [NOM].[PeriodoNomina] dst WHERE dst.LegacyTable = N'SIS_PeriodoMensual' AND dst.LegacyId = src.Pk_IdPeriodoMensual);

    INSERT INTO [NOM].[PeriodoNomina] ([TipoPeriodo], [LegacyTable], [LegacyId], [Anio], [Periodo], [FechaInicio], [FechaFin], [DiasPeriodo], [FKIdEmpresa_SIS], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT N'Vacaciones', N'SIS_PeriodoVacaciones', Pk_IdPeriodoVacaciones, Fk_IdAnio__SIS, Periodo, F_Inicio, F_Fin, DiasPeriodo, Fk_IdEmpresa__EMP, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, COALESCE(CT_LIVE, 1)
    FROM [BD_GRP_INVEA].dbo.SIS_PeriodoVacaciones src
    WHERE NOT EXISTS (SELECT 1 FROM [NOM].[PeriodoNomina] dst WHERE dst.LegacyTable = N'SIS_PeriodoVacaciones' AND dst.LegacyId = src.Pk_IdPeriodoVacaciones);

    INSERT INTO [NOM].[TablaFiscal] ([Catalogo], [LegacyTable], [LegacyId], [Descripcion], [Valor1], [Valor2], [Valor3], [Valor4], [FechaInicio], [FechaFin], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT N'ISR_Semanal', N'SIS_ISRSemanal', Pk_IdISR_Semanal, N'ISR semanal', Lim_Inf, Lim_Sup, CuotaFija, Porcentaje, FechaIni, FechaFin, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, COALESCE(CT_LIVE, 1)
    FROM [BD_GRP_INVEA].dbo.SIS_ISRSemanal src
    WHERE NOT EXISTS (SELECT 1 FROM [NOM].[TablaFiscal] dst WHERE dst.LegacyTable = N'SIS_ISRSemanal' AND dst.LegacyId = src.Pk_IdISR_Semanal);

    INSERT INTO [NOM].[TablaFiscal] ([Catalogo], [LegacyTable], [LegacyId], [Descripcion], [Valor1], [Valor2], [Valor3], [Valor4], [FechaInicio], [FechaFin], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT N'ISR_Quincenal', N'SIS_ISRQuincenal', Pk_IdISR_Quincenal, N'ISR quincenal', Lim_Inf, Lim_Sup, CuotaFija, Porcentaje, FechaIni, FechaFin, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, COALESCE(CT_LIVE, 1)
    FROM [BD_GRP_INVEA].dbo.SIS_ISRQuincenal src
    WHERE NOT EXISTS (SELECT 1 FROM [NOM].[TablaFiscal] dst WHERE dst.LegacyTable = N'SIS_ISRQuincenal' AND dst.LegacyId = src.Pk_IdISR_Quincenal);

    INSERT INTO [NOM].[TablaFiscal] ([Catalogo], [LegacyTable], [LegacyId], [Descripcion], [Valor1], [Valor2], [Valor3], [Valor4], [FechaInicio], [FechaFin], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT N'ISR_Mensual', N'SIS_ISRMensual', Pk_IdISR_Mensual, N'ISR mensual', Lim_Inf, Lim_Sup, CuotaFija, Porcentaje, FechaIni, FechaFin, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, COALESCE(CT_LIVE, 1)
    FROM [BD_GRP_INVEA].dbo.SIS_ISRMensual src
    WHERE NOT EXISTS (SELECT 1 FROM [NOM].[TablaFiscal] dst WHERE dst.LegacyTable = N'SIS_ISRMensual' AND dst.LegacyId = src.Pk_IdISR_Mensual);

    INSERT INTO [NOM].[TablaFiscal] ([Catalogo], [LegacyTable], [LegacyId], [Descripcion], [Valor1], [Valor2], [Valor3], [FechaInicio], [FechaFin], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT N'Subsidio_Semanal', N'SIS_SubsidioSemanal', Pk_IdSubsidioSemanal, N'Subsidio semanal', Lim_Inf, LimSup, Subsidio, FechaIni, FechaFin, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, COALESCE(CT_LIVE, 1)
    FROM [BD_GRP_INVEA].dbo.SIS_SubsidioSemanal src
    WHERE NOT EXISTS (SELECT 1 FROM [NOM].[TablaFiscal] dst WHERE dst.LegacyTable = N'SIS_SubsidioSemanal' AND dst.LegacyId = src.Pk_IdSubsidioSemanal);

    INSERT INTO [NOM].[TablaFiscal] ([Catalogo], [LegacyTable], [LegacyId], [Descripcion], [Valor1], [Valor2], [Valor3], [FechaInicio], [FechaFin], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT N'Subsidio_Quincenal', N'SIS_SubsidioQuincenal', Pk_IdSubsidioQuincenal, N'Subsidio quincenal', Lim_Inf, LimSup, Subsidio, FechaIni, FechaFin, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, COALESCE(CT_LIVE, 1)
    FROM [BD_GRP_INVEA].dbo.SIS_SubsidioQuincenal src
    WHERE NOT EXISTS (SELECT 1 FROM [NOM].[TablaFiscal] dst WHERE dst.LegacyTable = N'SIS_SubsidioQuincenal' AND dst.LegacyId = src.Pk_IdSubsidioQuincenal);

    INSERT INTO [NOM].[TablaFiscal] ([Catalogo], [LegacyTable], [LegacyId], [Descripcion], [Valor1], [Valor2], [Valor3], [FechaInicio], [FechaFin], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT N'Subsidio_Mensual', N'SIS_SubsidioMensual', Pk_IdSubsidioMensual, N'Subsidio mensual', Lim_Inf, LimSup, Subsidio, FechaIni, FechaFin, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, COALESCE(CT_LIVE, 1)
    FROM [BD_GRP_INVEA].dbo.SIS_SubsidioMensual src
    WHERE NOT EXISTS (SELECT 1 FROM [NOM].[TablaFiscal] dst WHERE dst.LegacyTable = N'SIS_SubsidioMensual' AND dst.LegacyId = src.Pk_IdSubsidioMensual);

    INSERT INTO [NOM].[TablaFiscal] ([Catalogo], [LegacyTable], [LegacyId], [Descripcion], [Valor1], [Valor2], [Valor3], [Valor4], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT N'Base_Gravable', N'SIS_BaseGravable', Pk_IdBaseGravable, CONCAT(N'Concepto ', Fk_IdConcepto__NOM), Porcentaje, TopeSemanal, TopeQuincenal, TopeMensual, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, COALESCE(CT_LIVE, 1)
    FROM [BD_GRP_INVEA].dbo.SIS_BaseGravable src
    WHERE NOT EXISTS (SELECT 1 FROM [NOM].[TablaFiscal] dst WHERE dst.LegacyTable = N'SIS_BaseGravable' AND dst.LegacyId = src.Pk_IdBaseGravable);

    INSERT INTO [NOM].[TablaFiscal] ([Catalogo], [LegacyTable], [LegacyId], [Clave], [Descripcion], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT N'IMSS_Clase', N'SIS_IMSSClase', Pk_IdIMSS_Clase, Clave, Descripcion, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, COALESCE(CT_LIVE, 1)
    FROM [BD_GRP_INVEA].dbo.SIS_IMSSClase src
    WHERE NOT EXISTS (SELECT 1 FROM [NOM].[TablaFiscal] dst WHERE dst.LegacyTable = N'SIS_IMSSClase' AND dst.LegacyId = src.Pk_IdIMSS_Clase);

    INSERT INTO [NOM].[TablaFiscal] ([Catalogo], [LegacyTable], [LegacyId], [Clave], [Descripcion], [FKIdCatalogoPadre_NOM], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT N'IMSS_Fraccion', N'SIS_IMSSFraccion', src.Pk_IdIMSS_Fraccion, src.Clave, src.Descripcion, parent.PKIdTablaFiscal, src.CT_CreatedBy, COALESCE(src.CT_CreatedDate, @Now), src.CT_ModifiedBy, src.CT_ModifiedDate, COALESCE(src.CT_LIVE, 1)
    FROM [BD_GRP_INVEA].dbo.SIS_IMSSFraccion src
    LEFT JOIN [NOM].[TablaFiscal] parent ON parent.LegacyTable = N'SIS_IMSSClase' AND parent.LegacyId = src.Fk_IdIMSSClase__SIS
    WHERE NOT EXISTS (SELECT 1 FROM [NOM].[TablaFiscal] dst WHERE dst.LegacyTable = N'SIS_IMSSFraccion' AND dst.LegacyId = src.Pk_IdIMSS_Fraccion);

    INSERT INTO [NOM].[TablaFiscal] ([Catalogo], [LegacyTable], [LegacyId], [Descripcion], [Valor1], [FKIdCatalogoPadre_NOM], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT N'Impuesto_Local', N'SIS_ImpuestoLocal', src.Pk_IdImpuestoLocal, src.NombreImpuesto, src.Porcentaje, parent.PKIdCatalogoSimple, src.CT_CreatedBy, COALESCE(src.CT_CreatedDate, @Now), src.CT_ModifiedBy, src.CT_ModifiedDate, COALESCE(src.CT_LIVE, 1)
    FROM [BD_GRP_INVEA].dbo.SIS_ImpuestoLocal src
    LEFT JOIN [NOM].[CatalogoSimple] parent ON parent.Catalogo = N'Estado' AND parent.LegacyId = src.Fk_IdEstado__SIS
    WHERE NOT EXISTS (SELECT 1 FROM [NOM].[TablaFiscal] dst WHERE dst.LegacyTable = N'SIS_ImpuestoLocal' AND dst.LegacyId = src.Pk_IdImpuestoLocal);

    INSERT INTO [NOM].[MotivoMovimiento] ([PKIdMotivoMovimiento], [FKIdMovimiento_RH], [FKIdClaseMovimiento_RH], [ClaseMovimiento], [Clave], [Motivo], [Descripcion], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT src.Pk_IdMotivoMovto, src.Fk_IdMovimiento__RH, src.Fk_IdClaseMovto__RH, clase.Descripcion, src.Clave, src.Motivo, src.Descripcion, src.CT_CreatedBy, COALESCE(src.CT_CreatedDate, @Now), src.CT_ModifiedBy, src.CT_ModifiedDate, COALESCE(src.CT_LIVE, 1)
    FROM [BD_GRP_INVEA].dbo.RH_MotivoMovto src
    LEFT JOIN [BD_GRP_INVEA].dbo.RH_ClaseMovto clase ON clase.Pk_IdClaseMovto = src.Fk_IdClaseMovto__RH
    WHERE NOT EXISTS (SELECT 1 FROM [NOM].[MotivoMovimiento] dst WHERE dst.PKIdMotivoMovimiento = src.Pk_IdMotivoMovto);

    INSERT INTO [NOM].[EmpleadoExpediente] ([PKIdExpediente], [FKIdPersona_NOM], [NombreDocumento], [Ruta], [Descripcion], [FechaExpedicion], [NecesitaRenovacion], [FechaRenovacion], [FKIdTipoExpediente_NOM], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT src.Pk_IdExpediente, src.Fk_IdPersona__RH, src.NombreDocto, src.Ruta, src.Descripcion, src.FechaExpedicion, src.Renovacion, src.FechaRenovacion, tipo.PKIdCatalogoSimple, src.CT_CreatedBy, COALESCE(src.CT_CreatedDate, @Now), src.CT_ModifiedBy, src.CT_ModifiedDate, COALESCE(src.CT_LIVE, 1)
    FROM [BD_GRP_INVEA].dbo.RH_Expediente src
    LEFT JOIN [NOM].[CatalogoSimple] tipo ON tipo.Catalogo = N'Tipo_Expediente' AND tipo.LegacyId = src.Fk_IdTipoExpediente__SIS
    WHERE NOT EXISTS (SELECT 1 FROM [NOM].[EmpleadoExpediente] dst WHERE dst.PKIdExpediente = src.Pk_IdExpediente);

    INSERT INTO [NOM].[PersonaPension] ([PKIdPension], [FKIdPersona_NOM], [NombreBeneficiario], [Documento], [FechaDocumento], [Porcentaje], [FKIdTipoPension_NOM], [FechaInicio], [FechaFin], [Banco], [CuentaBancaria], [Clabe], [FormaPago], [FKIdCuentaContable_SIS], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT Pk_IdPension, Fk_IdPersona__RH, NombreBeneficiario, Documento, Fecha, Porcentaje, Fk_IdTipoPension__NOM, FechaInicio, FechaFin, Fk_IdBanco, CuentaBancaria, Clabe, Fk_IdFormaPago, FK_IdCuentaContable__SIS, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, COALESCE(CT_LIVE, 1)
    FROM [BD_GRP_INVEA].dbo.RH_Pensiones src
    WHERE NOT EXISTS (SELECT 1 FROM [NOM].[PersonaPension] dst WHERE dst.PKIdPension = src.Pk_IdPension);

    INSERT INTO [NOM].[PlazaAutorizada] ([PKIdPlazaAutorizada], [FKIdPuesto_NOM], [FKIdArea_SIS], [FKIdSituacionPlaza_RH], [SituacionPlaza], [Plaza], [FechaInicio], [FechaFin], [TipoPlaza], [Documento], [FechaDocumento], [Descripcion], [FKIdEmpresa_SIS], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT src.Pk_IdPlazaAutorizada, src.FK_IdPuesto__RHCT, src.Fk_IdArea__SIS, src.Fk_IdSituacionPlaza__RH, sit.Descripcion, src.Plaza, src.FechaInicio, src.FechaFin, src.TipoPlaza, src.Documento, src.FechaDocumento, src.Descripcion, src.Fk_IdEmpresa__EMP, src.CT_CreatedBy, COALESCE(src.CT_CreatedDate, @Now), src.CT_ModifiedBy, src.CT_ModifiedDate, CASE WHEN COALESCE(src.CT_LIVE, 1) = 1 THEN 1 ELSE 0 END
    FROM [BD_GRP_INVEA].dbo.RH_PlazaAutorizada src
    LEFT JOIN [BD_GRP_INVEA].dbo.RH_SituacionPlaza sit ON sit.Pk_IdSituacionPlaza = src.Fk_IdSituacionPlaza__RH
    WHERE NOT EXISTS (SELECT 1 FROM [NOM].[PlazaAutorizada] dst WHERE dst.PKIdPlazaAutorizada = src.Pk_IdPlazaAutorizada);

    INSERT INTO [NOM].[PersonaPlaza] ([PKIdPersonaPlaza], [FKIdPersona_NOM], [FKIdPlazaAutorizada_NOM], [FKIdSituacionPersona_RH], [SituacionPersona], [FKIdNombramiento_NOM], [FKIdPuesto_NOM], [FKIdMotivoMovimiento_NOM], [ZonaEconomica], [FechaInicio], [FechaFin], [Horas], [QuincenaInicio], [QuincenaFin], [Documento], [FormaPago], [ChecaTarjeta], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT src.Pk_IdPersonaPlaza, src.Fk_IdPersona__RH, src.Fk_IdPlazaAutorizada__RH, src.Fk_IdSituacionPersona__RH, sit.Descripcion, src.Fk_IdNombramiento__RH, src.Fk_IdPuesto__RH, src.Fk_IdMotivoMovto__RH, src.ZonaEconomica, src.FechaInicio, src.FechaFin, src.Horas, src.QuincenaInicio, src.QuincenaFin, src.Documento, src.FormaPago, src.ChecaTarjeta, src.CT_CreatedBy, COALESCE(src.CT_CreatedDate, @Now), src.CT_ModifiedBy, src.CT_ModifiedDate, CASE WHEN COALESCE(src.CT_LIVE, 1) = 1 THEN 1 ELSE 0 END
    FROM [BD_GRP_INVEA].dbo.RH_PersonaPlaza src
    LEFT JOIN [BD_GRP_INVEA].dbo.RH_SituacionPersona sit ON sit.Pk_IdSituacionPersona = src.Fk_IdSituacionPersona__RH
    WHERE NOT EXISTS (SELECT 1 FROM [NOM].[PersonaPlaza] dst WHERE dst.PKIdPersonaPlaza = src.Pk_IdPersonaPlaza);

    INSERT INTO [NOM].[MovimientoPersonal] ([PKIdMovimientoPersonal], [FKIdPersona_NOM], [FKIdPlazaAutorizada_NOM], [FKIdMotivoMovimiento_NOM], [FKIdNombramiento_NOM], [FKIdSituacionMovimiento_RH], [SituacionMovimiento], [FKIdPuesto_NOM], [FKIdArea_SIS], [Documento], [FechaDocumento], [FechaCaptura], [QuincenaInicioProceso], [Observaciones], [ChecaTarjeta], [AplicaMovimiento], [FechaInicio], [FechaFin], [Horas], [Importe], [Consecutivo], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT src.PK_IdDatosMovto, src.FK_IdPersona__RH, src.FK_IdPlazaAutorizada__RH, src.FK_IdMotivoMovto__RH, src.FK_IdNombramiento__RH, src.FK_IdSituacionMovimiento__RH, sit.Descripcion, src.FK_IdPuesto__EMP, src.FK_IdArea__SIS, src.Documento, src.FechaDocumento, src.FechaCaptura, src.QuincenaInicioProceso, src.Observaciones, src.ChecaTarjeta, src.AplicaMovto, src.FechaInicio, src.FechaFin, src.Horas, src.Importe, src.Consecutivo, src.CT_CreatedBy, COALESCE(src.CT_CreatedDate, @Now), src.CT_ModifiedBy, src.CT_ModifiedDate, CASE WHEN COALESCE(src.CT_LIVE, 1) = 1 THEN 1 ELSE 0 END
    FROM [BD_GRP_INVEA].dbo.RH_DatosMovto src
    LEFT JOIN [BD_GRP_INVEA].dbo.RH_SituacionMovimiento sit ON sit.Pk_IdSituacionMovimiento = src.FK_IdSituacionMovimiento__RH
    WHERE NOT EXISTS (SELECT 1 FROM [NOM].[MovimientoPersonal] dst WHERE dst.PKIdMovimientoPersonal = src.PK_IdDatosMovto);

    INSERT INTO [NOM].[Incidencia] ([PKIdIncidencia], [FKIdPersona_NOM], [FKIdTipoIncidencia_NOM], [Fecha], [Comentario], [FKIdTipoJustificacion_NOM], [AplicaDescuento], [ComentarioJustificacion], [FKIdPeriodoQuincenal_SIS], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT src.Pk_IdIncidencia, src.Fk_IdPersona__RH, tipo.PKIdCatalogoSimple, src.Fecha, src.Comentario, justi.PKIdCatalogoSimple, src.AplicaDescuento, src.CometarioJustificacion, src.Fk_IdPeriodoQuincenal__SIS, src.CT_CreatedBy, COALESCE(src.CT_CreatedDate, @Now), src.CT_ModifiedBy, src.CT_ModifiedDate, COALESCE(src.CT_LIVE, 1)
    FROM [BD_GRP_INVEA].dbo.RH_Incidencia src
    LEFT JOIN [NOM].[CatalogoSimple] tipo ON tipo.Catalogo = N'Tipo_Incidencia' AND tipo.LegacyId = src.Fk_IdTipoIncidencia__SIS
    LEFT JOIN [NOM].[CatalogoSimple] justi ON justi.Catalogo = N'Tipo_Justificacion' AND justi.LegacyId = src.Fk_IdTipoJustificacion__SIS
    WHERE NOT EXISTS (SELECT 1 FROM [NOM].[Incidencia] dst WHERE dst.PKIdIncidencia = src.Pk_IdIncidencia);

    INSERT INTO [NOM].[Vacacion] ([PKIdVacacion], [FKIdPeriodoVacaciones_SIS], [FKIdPersona_NOM], [FechaInicio], [FechaFin], [FKIdPersonaJefeFirma_NOM], [Validado], [FKIdPersonaJefeValida_NOM], [FKIdEmpresa_SIS], [Dias], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT Pk_IdVacaciones, Fk_IdPeriodoVacaciones__SIS, Fk_IdPersona__RH, F_Inicio, F_Fin, Fk_IdPersonaJefeFirma, Validado, Fk_IdPersonaJefeValida, Fk_IdEmpresa__EMP, Dias, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, COALESCE(CT_LIVE, 1)
    FROM [BD_GRP_INVEA].dbo.RH_Vacaciones src
    WHERE NOT EXISTS (SELECT 1 FROM [NOM].[Vacacion] dst WHERE dst.PKIdVacacion = src.Pk_IdVacaciones);

    INSERT INTO [NOM].[Liquidacion] ([PKIdLiquidacion], [FKIdContrato_PRES], [DiasPendientesPago], [FechaInicioParaAguinaldo], [FechaBaja], [DiasDeVacacionesParaCalculo], [SaldoPendienteVacaciones], [BasePorDisminuir], [SalarioDiarioBruto], [SalarioDiarioIntegrado], [FactorIntegracion], [VariableDiaria], [DiasAguinaldo], [DiasVacaciones], [PrimaVacacional], [FechaUltimoAniversario], [AnioAntiguedad], [DiasPrima], [SalarioDiarioIntegradoLiquidacion], [EsLiquidacion], [VacacionesEjercicioAnt], [DescuentosXFaltas], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
    SELECT Pk_IdLiquidacion, Fk_IdContrato__PRES, DiasPendientesPago, FechaInicioParaAguinaldo, FechaBaja, DiasDeVacacionesParaCalculo, SaldoPendientedeVacaciones, BaseporDisminuir, SalarioDiarioBruto, SalarioDiarioIntegrado, FactorIntegracion, VariableDiaria, DiasAguinaldo, DiasVacaciones, PrimaVacacional, FechaUltimoAniversario, AnioAntiguedad, DiasPrima, SalarioDiarioIntegradoLiquidacion, EsLiquidacion, VacacionesEjercicioAnt, DescuentosXFaltas, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, COALESCE(CT_LIVE, 1)
    FROM [BD_GRP_INVEA].dbo.RH_Liquidacion src
    WHERE NOT EXISTS (SELECT 1 FROM [NOM].[Liquidacion] dst WHERE dst.PKIdLiquidacion = src.Pk_IdLiquidacion);
END;
GO

CREATE OR ALTER VIEW [NOM].[Vw_OperacionNomina]
AS
    SELECT
        N'empleados' AS Operacion,
        p.PKIdPersona AS Id,
        p.Clave,
        CONCAT_WS(N' ', p.Nombre, p.Paterno, p.Materno) AS Persona,
        p.Clave AS Empleado,
        p.PUESTO AS Empresa,
        CAST(NULL AS nvarchar(100)) AS Periodo,
        p.TIPO_CONTRATACION AS Tipo,
        CASE WHEN p.Activo = 1 THEN N'Activo' ELSE N'Inactivo' END AS Estatus,
        CAST(p.Fecha_de_Inicio AS datetime2(6)) AS Fecha,
        CAST(p.Fecha_de_Inicio AS datetime2(6)) AS FechaInicio,
        CAST(p.Fecha_Fin AS datetime2(6)) AS FechaFin,
        CAST(p.SUELDO_BASE AS decimal(19,4)) AS Importe,
        CAST(NULL AS decimal(19,4)) AS Percepcion,
        CAST(NULL AS decimal(19,4)) AS Deduccion,
        CAST(NULL AS decimal(19,4)) AS Neto,
        p.RFC AS Documento,
        p.Curp AS Descripcion,
        p.CORREO_ELECTRONICO AS Comentario,
        CONCAT_WS(N' ', p.Calle, p.Num_exterior, p.Num_interior, p.Colonia, p.CP) AS Observaciones,
        p.Activo
    FROM [NOM].[Persona] p

    UNION ALL
    SELECT
        N'expedientes', e.PKIdExpediente, CAST(e.PKIdExpediente AS nvarchar(50)),
        CONCAT_WS(N' ', p.Nombre, p.Paterno, p.Materno), p.Clave, CAST(NULL AS nvarchar(200)), tipo.Descripcion,
        COALESCE(tipo.Descripcion, N'Expediente'),
        CASE WHEN e.NecesitaRenovacion = 1 THEN N'Requiere renovacion' ELSE N'Vigente' END,
        CAST(e.FechaExpedicion AS datetime2(6)), CAST(e.FechaExpedicion AS datetime2(6)), CAST(e.FechaRenovacion AS datetime2(6)),
        NULL, NULL, NULL, NULL, e.Ruta, e.NombreDocumento, e.Descripcion, e.Ruta, e.Activo
    FROM [NOM].[EmpleadoExpediente] e
    LEFT JOIN [NOM].[Persona] p ON p.PKIdPersona = e.FKIdPersona_NOM
    LEFT JOIN [NOM].[CatalogoSimple] tipo ON tipo.PKIdCatalogoSimple = e.FKIdTipoExpediente_NOM

    UNION ALL
    SELECT
        N'pensiones', pe.PKIdPension, CAST(pe.PKIdPension AS nvarchar(50)),
        CONCAT_WS(N' ', p.Nombre, p.Paterno, p.Materno), p.Clave, CAST(NULL AS nvarchar(200)), CAST(NULL AS nvarchar(100)),
        COALESCE(tp.Descripcion, N'Pension'), CASE WHEN pe.Activo = 1 THEN N'Activa' ELSE N'Inactiva' END,
        pe.FechaInicio, pe.FechaInicio, pe.FechaFin,
        pe.Porcentaje, NULL, NULL, NULL, pe.Documento, pe.NombreBeneficiario,
        CONCAT(N'Banco: ', COALESCE(pe.Banco, N''), N' Cuenta: ', COALESCE(pe.CuentaBancaria, N'')), pe.Clabe, pe.Activo
    FROM [NOM].[PersonaPension] pe
    LEFT JOIN [NOM].[Persona] p ON p.PKIdPersona = pe.FKIdPersona_NOM
    LEFT JOIN [NOM].[TipoPension] tp ON tp.PKIdTipoPension = pe.FKIdTipoPension_NOM

    UNION ALL
    SELECT
        N'movimientos', m.PKIdMovimientoPersonal, CAST(m.PKIdMovimientoPersonal AS nvarchar(50)),
        CONCAT_WS(N' ', p.Nombre, p.Paterno, p.Materno), p.Clave, CAST(pa.Plaza AS nvarchar(200)),
        CAST(m.QuincenaInicioProceso AS nvarchar(100)), COALESCE(mm.Descripcion, N'Movimiento'),
        COALESCE(m.SituacionMovimiento, CASE WHEN m.Activo = 1 THEN N'Activo' ELSE N'Inactivo' END),
        CAST(m.FechaCaptura AS datetime2(6)), CAST(m.FechaInicio AS datetime2(6)), CAST(m.FechaFin AS datetime2(6)),
        m.Importe, NULL, NULL, NULL, m.Documento, COALESCE(mm.Descripcion, m.SituacionMovimiento),
        m.Observaciones, CONCAT(N'Consecutivo: ', COALESCE(CAST(m.Consecutivo AS nvarchar(20)), N'')), m.Activo
    FROM [NOM].[MovimientoPersonal] m
    LEFT JOIN [NOM].[Persona] p ON p.PKIdPersona = m.FKIdPersona_NOM
    LEFT JOIN [NOM].[MotivoMovimiento] mm ON mm.PKIdMotivoMovimiento = m.FKIdMotivoMovimiento_NOM
    LEFT JOIN [NOM].[PlazaAutorizada] pa ON pa.PKIdPlazaAutorizada = m.FKIdPlazaAutorizada_NOM

    UNION ALL
    SELECT
        N'plazas', pa.PKIdPlazaAutorizada, CAST(pa.Plaza AS nvarchar(50)),
        CAST(NULL AS nvarchar(250)), CAST(pa.Plaza AS nvarchar(50)), CAST(pa.FKIdEmpresa_SIS AS nvarchar(200)),
        CAST(NULL AS nvarchar(100)), COALESCE(pa.SituacionPlaza, N'Plaza'),
        COALESCE(pa.SituacionPlaza, CASE WHEN pa.Activo = 1 THEN N'Activa' ELSE N'Inactiva' END),
        pa.FechaInicio, pa.FechaInicio, pa.FechaFin, NULL, NULL, NULL, NULL, pa.Documento, pa.Descripcion,
        CONCAT(N'Area: ', COALESCE(CAST(pa.FKIdArea_SIS AS nvarchar(20)), N'')), CAST(pa.TipoPlaza AS nvarchar(50)), pa.Activo
    FROM [NOM].[PlazaAutorizada] pa

    UNION ALL
    SELECT
        N'incidencias', i.PKIdIncidencia, CAST(i.PKIdIncidencia AS nvarchar(50)),
        CONCAT_WS(N' ', p.Nombre, p.Paterno, p.Materno), p.Clave, CAST(NULL AS nvarchar(200)),
        CAST(i.FKIdPeriodoQuincenal_SIS AS nvarchar(100)), COALESCE(ti.Descripcion, N'Incidencia'),
        CASE WHEN i.AplicaDescuento = 1 THEN N'Descuenta dia' ELSE N'No descuenta' END,
        CAST(i.Fecha AS datetime2(6)), CAST(i.Fecha AS datetime2(6)), CAST(NULL AS datetime2(6)),
        NULL, NULL, NULL, NULL, CAST(i.FKIdPeriodoQuincenal_SIS AS nvarchar(200)), COALESCE(ti.Descripcion, N'Incidencia'),
        i.ComentarioJustificacion, i.Comentario, i.Activo
    FROM [NOM].[Incidencia] i
    LEFT JOIN [NOM].[Persona] p ON p.PKIdPersona = i.FKIdPersona_NOM
    LEFT JOIN [NOM].[CatalogoSimple] ti ON ti.PKIdCatalogoSimple = i.FKIdTipoIncidencia_NOM

    UNION ALL
    SELECT
        N'vacaciones', v.PKIdVacacion, CAST(v.PKIdVacacion AS nvarchar(50)),
        CONCAT_WS(N' ', p.Nombre, p.Paterno, p.Materno), p.Clave, CAST(v.FKIdEmpresa_SIS AS nvarchar(200)),
        CAST(v.FKIdPeriodoVacaciones_SIS AS nvarchar(100)), N'Vacaciones',
        CASE WHEN v.Validado = 1 THEN N'Autorizada' ELSE N'Pendiente' END,
        v.FechaInicio, v.FechaInicio, v.FechaFin, CAST(v.Dias AS decimal(19,4)), NULL, NULL, NULL,
        CAST(v.FKIdPersonaJefeFirma_NOM AS nvarchar(200)), N'Solicitud de vacaciones',
        CONCAT(N'Jefe valida: ', COALESCE(CAST(v.FKIdPersonaJefeValida_NOM AS nvarchar(20)), N'')),
        CONCAT(N'Dias: ', COALESCE(CAST(v.Dias AS nvarchar(20)), N'')), v.Activo
    FROM [NOM].[Vacacion] v
    LEFT JOIN [NOM].[Persona] p ON p.PKIdPersona = v.FKIdPersona_NOM

    UNION ALL
    SELECT
        N'liquidaciones', l.PKIdLiquidacion, CAST(l.PKIdLiquidacion AS nvarchar(50)),
        CAST(NULL AS nvarchar(250)), CAST(l.FKIdContrato_PRES AS nvarchar(50)), CAST(NULL AS nvarchar(200)),
        CAST(NULL AS nvarchar(100)), CASE WHEN l.EsLiquidacion = 1 THEN N'Liquidacion' ELSE N'Finiquito' END,
        CASE WHEN l.Activo = 1 THEN N'Activa' ELSE N'Inactiva' END,
        CAST(l.FechaBaja AS datetime2(6)), CAST(l.FechaInicioParaAguinaldo AS datetime2(6)), CAST(l.FechaBaja AS datetime2(6)),
        l.SalarioDiarioIntegradoLiquidacion, l.SalarioDiarioBruto, l.SaldoPendienteVacaciones, NULL,
        CAST(l.FKIdContrato_PRES AS nvarchar(200)), N'Liquidacion/Finiquito',
        CONCAT(N'Dias pendientes: ', COALESCE(CAST(l.DiasPendientesPago AS nvarchar(20)), N'')),
        CONCAT(N'Vacaciones: ', COALESCE(CAST(l.DiasVacaciones AS nvarchar(20)), N'')), l.Activo
    FROM [NOM].[Liquidacion] l

    UNION ALL
    SELECT
        N'concepto-variable', cv.PKIdConceptoVariable, CAST(cv.PKIdConceptoVariable AS nvarchar(50)),
        CONCAT_WS(N' ', p.Nombre, p.Paterno, p.Materno), p.Clave, CAST(cv.FKIdEmpresa_SIS AS nvarchar(200)),
        CAST(cv.FKIdPeriodo AS nvarchar(100)), COALESCE(c.Nombre, N'Concepto variable'),
        CASE WHEN cv.Activo = 1 THEN N'Activo' ELSE N'Inactivo' END,
        cv.FechaCreacion, NULL, NULL, cv.Importe, cv.Importe, NULL, cv.Importe,
        CAST(cv.FKIdConcepto_NOM AS nvarchar(200)), COALESCE(c.Nombre, N'Concepto variable'), cv.Referencia, cv.Referencia, cv.Activo
    FROM [NOM].[ConceptoVariable] cv
    LEFT JOIN [NOM].[Persona] p ON p.PKIdPersona = cv.FKIdPersona_NOM
    LEFT JOIN [NOM].[Concepto] c ON c.PKIdConcepto = cv.FKIdConcepto_NOM

    UNION ALL
    SELECT
        N'periodos', pn.PKIdPeriodoNomina, CAST(pn.LegacyId AS nvarchar(50)),
        CAST(NULL AS nvarchar(250)), CAST(pn.Periodo AS nvarchar(50)), CAST(pn.FKIdEmpresa_SIS AS nvarchar(200)),
        CONCAT(pn.Anio, N' / ', pn.Periodo), pn.TipoPeriodo,
        CASE WHEN pn.Activo = 1 THEN N'Activo' ELSE N'Inactivo' END,
        CAST(pn.FechaInicio AS datetime2(6)), CAST(pn.FechaInicio AS datetime2(6)), CAST(pn.FechaFin AS datetime2(6)),
        CAST(COALESCE(pn.DiasPeriodo, pn.DiasHabiles) AS decimal(19,4)), NULL, NULL, NULL,
        pn.LegacyTable, CONCAT(N'Periodo ', pn.TipoPeriodo), CONCAT(N'Mes: ', COALESCE(CAST(pn.Mes AS nvarchar(20)), N'')), pn.LegacyTable, pn.Activo
    FROM [NOM].[PeriodoNomina] pn

    UNION ALL
    SELECT
        N'tablas-fiscales', tf.PKIdTablaFiscal, COALESCE(tf.Clave, CAST(tf.LegacyId AS nvarchar(50))),
        CAST(NULL AS nvarchar(250)), COALESCE(tf.Clave, CAST(tf.LegacyId AS nvarchar(50))), CAST(NULL AS nvarchar(200)),
        tf.Catalogo, tf.Catalogo, CASE WHEN tf.Activo = 1 THEN N'Activo' ELSE N'Inactivo' END,
        CAST(tf.FechaInicio AS datetime2(6)), CAST(tf.FechaInicio AS datetime2(6)), CAST(tf.FechaFin AS datetime2(6)),
        tf.Valor1, tf.Valor2, tf.Valor3, tf.Valor4, tf.LegacyTable, tf.Descripcion,
        CONCAT(N'Valor4: ', COALESCE(CAST(tf.Valor4 AS nvarchar(50)), N'')), tf.LegacyTable, tf.Activo
    FROM [NOM].[TablaFiscal] tf

    UNION ALL
    SELECT
        N'productos-nomina', c.PKIdCorridaNomina, CAST(c.PKIdCorridaNomina AS nvarchar(50)),
        CAST(NULL AS nvarchar(250)), CAST(c.TotalPersonas AS nvarchar(50)), en.RazonSocial,
        CAST(c.IdPeriodo AS nvarchar(100)), c.TipoCorrida, c.Estatus,
        c.FechaProceso, c.FechaProceso, NULL, c.TotalNeto, c.TotalPercepcion, c.TotalDeduccion, c.TotalNeto,
        CAST(c.PKIdCorridaNomina AS nvarchar(200)), N'Corrida de nomina',
        c.Observaciones, CONCAT(N'Movimientos: ', c.TotalMovimientos), c.Activo
    FROM [NOM].[CorridaNomina] c
    LEFT JOIN [NOM].[EmpresaNomina] en ON en.PKIdEmpresaNomina = c.FKIdEmpresaNomina_NOM;
GO

CREATE OR ALTER PROCEDURE [NOM].[spOperacionNomina_List]
    @Operacion nvarchar(80),
    @Page int = 1,
    @PageSize int = 10,
    @Filtro nvarchar(250) = N'',
    @SortLabel nvarchar(80) = N'Fecha',
    @SortDirection nvarchar(20) = N'Descending'
AS
BEGIN
    SET NOCOUNT ON;

    SET @Page = CASE WHEN ISNULL(@Page, 0) <= 0 THEN 1 ELSE @Page END;
    SET @PageSize = CASE WHEN ISNULL(@PageSize, 0) <= 0 THEN 10 ELSE @PageSize END;
    SET @Filtro = LTRIM(RTRIM(ISNULL(@Filtro, N'')));
    SET @Operacion = LTRIM(RTRIM(ISNULL(@Operacion, N'')));

    IF @SortLabel NOT IN (N'Id', N'Clave', N'Persona', N'Empleado', N'Empresa', N'Periodo', N'Tipo', N'Estatus', N'Fecha', N'FechaInicio', N'FechaFin', N'Importe', N'Percepcion', N'Deduccion', N'Neto', N'Documento', N'Descripcion', N'Activo')
        SET @SortLabel = N'Fecha';

    IF UPPER(ISNULL(@SortDirection, N'')) NOT IN (N'ASCENDING', N'ASC', N'DESCENDING', N'DESC')
        SET @SortDirection = N'Descending';

    DECLARE @Direction nvarchar(4) = CASE WHEN UPPER(@SortDirection) IN (N'ASCENDING', N'ASC') THEN N'ASC' ELSE N'DESC' END;
    DECLARE @Offset int = (@Page - 1) * @PageSize;
    DECLARE @Sql nvarchar(max) = N'
        SELECT
            Operacion, Id, Clave, Persona, Empleado, Empresa, Periodo, Tipo, Estatus,
            Fecha, FechaInicio, FechaFin, Importe, Percepcion, Deduccion, Neto,
            Documento, Descripcion, Comentario, Observaciones, Activo,
            COUNT(1) OVER() AS TotalCount
        FROM [NOM].[Vw_OperacionNomina]
        WHERE (@Operacion = N'''' OR Operacion = @Operacion)
          AND (
                @Filtro = N''''
                OR COALESCE(Clave, N'''') LIKE N''%'' + @Filtro + N''%''
                OR COALESCE(Persona, N'''') LIKE N''%'' + @Filtro + N''%''
                OR COALESCE(Empleado, N'''') LIKE N''%'' + @Filtro + N''%''
                OR COALESCE(Empresa, N'''') LIKE N''%'' + @Filtro + N''%''
                OR COALESCE(Periodo, N'''') LIKE N''%'' + @Filtro + N''%''
                OR COALESCE(Tipo, N'''') LIKE N''%'' + @Filtro + N''%''
                OR COALESCE(Estatus, N'''') LIKE N''%'' + @Filtro + N''%''
                OR COALESCE(Documento, N'''') LIKE N''%'' + @Filtro + N''%''
                OR COALESCE(Descripcion, N'''') LIKE N''%'' + @Filtro + N''%''
                OR COALESCE(Comentario, N'''') LIKE N''%'' + @Filtro + N''%''
                OR COALESCE(Observaciones, N'''') LIKE N''%'' + @Filtro + N''%''
          )
        ORDER BY ' + QUOTENAME(@SortLabel) + N' ' + @Direction + N', Id DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;';

    EXEC sp_executesql
        @Sql,
        N'@Operacion nvarchar(80), @Filtro nvarchar(250), @Offset int, @PageSize int',
        @Operacion = @Operacion,
        @Filtro = @Filtro,
        @Offset = @Offset,
        @PageSize = @PageSize;
END;
GO

SELECT Operacion, COUNT(1) AS Registros
FROM [NOM].[Vw_OperacionNomina]
GROUP BY Operacion
ORDER BY Operacion;
GO
