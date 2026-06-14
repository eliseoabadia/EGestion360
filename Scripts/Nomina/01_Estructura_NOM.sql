-- Estructura base migrada de Nomina desde INVEA a EGestion360.
-- No ejecutar sin respaldar y validar dependencias de catalogos comunes.
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'NOM')
    EXEC(N'CREATE SCHEMA [NOM]');
GO

IF OBJECT_ID(N'[NOM].[Concepto]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[Concepto] (
        [PKIdConcepto] int IDENTITY(1,1) NOT NULL,
        [Clave] nchar(4) NOT NULL,
        [SubClave] nchar(4) NOT NULL,
        [PerDed] nchar(1) NOT NULL,
        [Nombre] nvarchar(500) NULL,
        [FKIdFormaCalculo_NOM] int NOT NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL DEFAULT 1,
        CONSTRAINT [PK_NOM_Concepto] PRIMARY KEY ([PKIdConcepto])
    );
END
GO

IF OBJECT_ID(N'[NOM].[ConceptoFactor]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[ConceptoFactor] (
        [PKIdConceptoFactor] int IDENTITY(1,1) NOT NULL,
        [FKIdConcepto_NOM] int NOT NULL,
        [Factor] decimal(18,4) NOT NULL,
        [QuincenaInicio] int NOT NULL,
        [QuincenaFin] int NOT NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL DEFAULT 1,
        [Observaciones] nvarchar(200) NULL,
        CONSTRAINT [PK_NOM_ConceptoFactor] PRIMARY KEY ([PKIdConceptoFactor])
    );
END
GO

IF OBJECT_ID(N'[NOM].[ConceptoFijo]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[ConceptoFijo] (
        [PKIdConceptoFijo] int IDENTITY(1,1) NOT NULL,
        [FKIdEmpresa_SIS] int NOT NULL,
        [FKIdConcepto_NOM] int NOT NULL,
        [FKIdPuesto_NOM] int NOT NULL,
        [ImporteMensualFijo] decimal(19,4) NOT NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL DEFAULT 1,
        [FechaIni] date NULL,
        [FechaFin] date NULL,
        CONSTRAINT [PK_NOM_ConceptoFijo] PRIMARY KEY ([PKIdConceptoFijo])
    );
END
GO

IF OBJECT_ID(N'[NOM].[ConceptoPorcentaje]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[ConceptoPorcentaje] (
        [PKIdConceptoPorcentaje] int IDENTITY(1,1) NOT NULL,
        [FKIdConceptoProporcional_NOM] int NOT NULL,
        [FKIdConcepto_NOM] int NOT NULL,
        [Porcentaje] decimal(18,2) NOT NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL DEFAULT 1,
        CONSTRAINT [PK_NOM_ConceptoPorcentaje] PRIMARY KEY ([PKIdConceptoPorcentaje])
    );
END
GO

IF OBJECT_ID(N'[NOM].[ConceptoProporcional]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[ConceptoProporcional] (
        [PKIdConceptoProporcional] int IDENTITY(1,1) NOT NULL,
        [FKIdEmpresa_SIS] int NULL,
        [FKIdPuesto_NOM] int NULL,
        [FKIdConcepto_NOM] int NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL DEFAULT 1,
        CONSTRAINT [PK_NOM_ConceptoProporcional] PRIMARY KEY ([PKIdConceptoProporcional])
    );
END
GO

IF OBJECT_ID(N'[NOM].[ConceptoTabular]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[ConceptoTabular] (
        [PKIdConceptoTabulador] int IDENTITY(1,1) NOT NULL,
        [FKIdEmpresa_SIS] int NOT NULL,
        [FKIdConcepto_NOM] int NOT NULL,
        [FKIdPuesto_NOM] int NOT NULL,
        [ImporteMensual] decimal(19,4) NOT NULL,
        [FechaInicio] date NULL,
        [FechaFin] date NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL DEFAULT 1,
        CONSTRAINT [PK_NOM_ConceptoTabular] PRIMARY KEY ([PKIdConceptoTabulador])
    );
END
GO

IF OBJECT_ID(N'[NOM].[ConceptoVariable]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[ConceptoVariable] (
        [PKIdConceptoVariable] int IDENTITY(1,1) NOT NULL,
        [FKIdEmpresa_SIS] int NOT NULL,
        [FKIdPersona_NOM] int NOT NULL,
        [FKIdPeriodo] int NOT NULL,
        [FKIdConcepto_NOM] int NOT NULL,
        [Importe] decimal(19,4) NOT NULL,
        [Referencia] nvarchar(50) NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL DEFAULT 1,
        CONSTRAINT [PK_NOM_ConceptoVariable] PRIMARY KEY ([PKIdConceptoVariable])
    );
END
GO

IF OBJECT_ID(N'[NOM].[ContratoTerceros]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[ContratoTerceros] (
        [PKIdContratoTercero] int IDENTITY(1,1) NOT NULL,
        [FKIdEmpresa_SIS] int NOT NULL,
        [NombreContrato] nvarchar(80) NOT NULL,
        [Descripcion] nvarchar(300) NOT NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL DEFAULT 1,
        CONSTRAINT [PK_NOM_ContratoTerceros] PRIMARY KEY ([PKIdContratoTercero])
    );
END
GO

IF OBJECT_ID(N'[NOM].[Credito]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[Credito] (
        [PKIdCredito] int IDENTITY(1,1) NOT NULL,
        [FKIdPersona_NOM] int NOT NULL,
        [FKIdContratoTercero_NOM] int NOT NULL,
        [MotivoCredito] nvarchar(80) NOT NULL,
        [ImporteCredito] decimal(19,4) NOT NULL,
        [TasaInteres] decimal(19,4) NOT NULL,
        [NumeroPagos] int NOT NULL,
        [FKIdPeriodoInicial] int NOT NULL,
        [ImportePago] decimal(19,4) NOT NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL DEFAULT 1,
        CONSTRAINT [PK_NOM_Credito] PRIMARY KEY ([PKIdCredito])
    );
END
GO

IF OBJECT_ID(N'[NOM].[DescuentoCredito]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[DescuentoCredito] (
        [PKIdDescuentoCredito] int IDENTITY(1,1) NOT NULL,
        [FKIdCredito_NOM] int NOT NULL,
        [FKIdPeriodo] int NOT NULL,
        [NumeroPago] int NOT NULL,
        [EstaDescontado] bit NOT NULL DEFAULT 0,
        [FechaDescuento] date NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL DEFAULT 1,
        CONSTRAINT [PK_NOM_DescuentoCredito] PRIMARY KEY ([PKIdDescuentoCredito])
    );
END
GO

IF OBJECT_ID(N'[NOM].[DescuentoInfonavit]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[DescuentoInfonavit] (
        [PKIdDescuentoInfonavit] int IDENTITY(1,1) NOT NULL,
        [FKIdInfonavit_NOM] int NOT NULL,
        [FKIdPeriodo] int NOT NULL,
        [NumeroPago] int NOT NULL,
        [EstaDescontado] int NOT NULL,
        [FechaDescuento] date NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL DEFAULT 1,
        CONSTRAINT [PK_NOM_DescuentoInfonavit] PRIMARY KEY ([PKIdDescuentoInfonavit])
    );
END
GO

IF OBJECT_ID(N'[NOM].[EstatusPago]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[EstatusPago] (
        [PKIdEstatusPago] int IDENTITY(1,1) NOT NULL,
        [Descripcion] nvarchar(100) NOT NULL,
        [Activo] bit NOT NULL DEFAULT 1,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioCreacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        CONSTRAINT [PK_NOM_EstatusPago] PRIMARY KEY ([PKIdEstatusPago])
    );
END
GO

IF OBJECT_ID(N'[NOM].[FactorInt]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[FactorInt] (
        [PKIdFactor] int IDENTITY(1,1) NOT NULL,
        [Anio] int NOT NULL,
        [Vacaciones] int NOT NULL,
        [Vacacional] decimal(4,2) NOT NULL,
        [Aguinaldo] int NOT NULL,
        [Integracion] decimal(6,4) NULL,
        [PrimaDominical] decimal(4,2) NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL DEFAULT 1,
        CONSTRAINT [PK_NOM_FactorInt] PRIMARY KEY ([PKIdFactor])
    );
END
GO

IF OBJECT_ID(N'[NOM].[Infonavit]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[Infonavit] (
        [PKIdInfonavit] int IDENTITY(1,1) NOT NULL,
        [FKIdPersona_NOM] int NOT NULL,
        [FKIdUnidadInfonavit_NOM] int NOT NULL,
        [MotivoInfonavit] nvarchar(80) NOT NULL,
        [ImporteInfonavit] decimal(19,4) NOT NULL,
        [TasaInteres] decimal(19,4) NOT NULL,
        [NumeroPagos] int NOT NULL,
        [FKIdPeriodoInicial] int NOT NULL,
        [ImportePago] decimal(19,4) NOT NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL DEFAULT 1,
        [FKIdPeriodoFinal] int NULL,
        [FechaInicial] date NOT NULL,
        [FechaFinal] date NOT NULL DEFAULT '9999-12-31',
        CONSTRAINT [PK_NOM_Infonavit] PRIMARY KEY ([PKIdInfonavit])
    );
END
GO

IF OBJECT_ID(N'[NOM].[PeriodoActivo]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[PeriodoActivo] (
        [PKIdPeriodoActivo] int IDENTITY(1,1) NOT NULL,
        [FKIdEmpresa_SIS] int NOT NULL,
        [IdPeriodo] int NOT NULL,
        [EstaCerrado] bit NOT NULL DEFAULT 0,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL DEFAULT 1,
        [EstaComprometido] bit NULL DEFAULT 0,
        [EstaDevengado] bit NULL DEFAULT 0,
        [EstaEjercido] bit NULL DEFAULT 0,
        CONSTRAINT [PK_NOM_PeriodoActivo] PRIMARY KEY ([PKIdPeriodoActivo])
    );
END
GO

IF OBJECT_ID(N'[NOM].[SalarioMinimo]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[SalarioMinimo] (
        [PKIdSalarioMinimo] int IDENTITY(1,1) NOT NULL,
        [ZonaEconomica] int NOT NULL,
        [QuincenaInicio] int NOT NULL,
        [QuincenaFin] int NOT NULL,
        [Importe] decimal(14,2) NOT NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL DEFAULT 1,
        CONSTRAINT [PK_NOM_SalarioMinimo] PRIMARY KEY ([PKIdSalarioMinimo])
    );
END
GO

IF OBJECT_ID(N'[NOM].[SueldoEspecial]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[SueldoEspecial] (
        [PKIdSueldoEspecial] int IDENTITY(1,1) NOT NULL,
        [FKIdEmpresa_SIS] int NOT NULL,
        [FKIdPersona_NOM] int NOT NULL,
        [FKIdNominaEspecial_NOM] int NOT NULL,
        [FKIdConcepto_NOM] int NOT NULL,
        [Percepcion] decimal(19,4) NULL DEFAULT 0.0000,
        [Deduccion] decimal(19,4) NULL DEFAULT 0.0000,
        [Referencia] nvarchar(500) NULL,
        [Aportacion] decimal(19,4) NULL DEFAULT 0.0000,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL DEFAULT 1,
        CONSTRAINT [PK_NOM_SueldoEspecial] PRIMARY KEY ([PKIdSueldoEspecial])
    );
END
GO

IF OBJECT_ID(N'[NOM].[SueldoLiqFin]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[SueldoLiqFin] (
        [PKIdSueldoLiqFin] int IDENTITY(1,1) NOT NULL,
        [FKIdContrato_PRES] int NOT NULL,
        [FKIdConcepto_NOM] int NOT NULL,
        [Percepcion] decimal(19,4) NOT NULL DEFAULT 0.0000,
        [Deduccion] decimal(19,4) NOT NULL DEFAULT 0.0000,
        [Referencia] nvarchar(250) NULL,
        [Aportacion] decimal(19,4) NULL DEFAULT 0.0000,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL DEFAULT 1,
        CONSTRAINT [PK_NOM_SueldoLiqFin] PRIMARY KEY ([PKIdSueldoLiqFin])
    );
END
GO

IF OBJECT_ID(N'[NOM].[SueldoMensual]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[SueldoMensual] (
        [PKIdSueldoMensual] int IDENTITY(1,1) NOT NULL,
        [FKIdEmpresa_SIS] int NOT NULL,
        [FKIdPersona_NOM] int NOT NULL,
        [FKIdPeriodoMensual_NOM] int NOT NULL,
        [FKIdConcepto_NOM] int NOT NULL,
        [Percepcion] decimal(19,4) NULL DEFAULT 0.0000,
        [Deduccion] decimal(19,4) NULL DEFAULT 0.0000,
        [Referencia] nvarchar(100) NULL,
        [Aportacion] decimal(19,4) NULL DEFAULT 0.0000,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL DEFAULT 1,
        CONSTRAINT [PK_NOM_SueldoMensual] PRIMARY KEY ([PKIdSueldoMensual])
    );
END
GO

IF OBJECT_ID(N'[NOM].[SueldoQuincenal]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[SueldoQuincenal] (
        [PKIdSueldoQuincenal] int IDENTITY(1,1) NOT NULL,
        [FKIdEmpresa_SIS] int NOT NULL,
        [FKIdPersona_NOM] int NOT NULL,
        [FKIdPeriodoQuincenal_NOM] int NOT NULL,
        [FKIdConcepto_NOM] int NOT NULL,
        [Percepcion] decimal(19,4) NULL DEFAULT 0.0000,
        [Deduccion] decimal(19,4) NULL DEFAULT 0.0000,
        [Referencia] nvarchar(100) NULL,
        [Aportacion] decimal(19,4) NULL DEFAULT 0.0000,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL DEFAULT 1,
        CONSTRAINT [PK_NOM_SueldoQuincenal] PRIMARY KEY ([PKIdSueldoQuincenal])
    );
END
GO

IF OBJECT_ID(N'[NOM].[SueldoSemanal]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[SueldoSemanal] (
        [PKIdSueldoSemanal] int IDENTITY(1,1) NOT NULL,
        [FKIdEmpresa_SIS] int NOT NULL,
        [FKIdPersona_NOM] int NOT NULL,
        [FKIdPeriodoSemanal_NOM] int NOT NULL,
        [FKIdConcepto_NOM] int NOT NULL,
        [Percepcion] decimal(19,4) NULL DEFAULT 0.0000,
        [Deduccion] decimal(19,4) NULL DEFAULT 0.0000,
        [Referencia] nvarchar(100) NULL,
        [Aportacion] decimal(19,4) NULL DEFAULT 0.0000,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL DEFAULT 1,
        CONSTRAINT [PK_NOM_SueldoSemanal] PRIMARY KEY ([PKIdSueldoSemanal])
    );
END
GO

IF OBJECT_ID(N'[NOM].[TipoIncapacidad]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[TipoIncapacidad] (
        [PKIdTipoIncapacidad] int IDENTITY(1,1) NOT NULL,
        [Clave] int NOT NULL,
        [Descripcion] nvarchar(100) NOT NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL DEFAULT 1,
        CONSTRAINT [PK_NOM_TipoIncapacidad] PRIMARY KEY ([PKIdTipoIncapacidad])
    );
END
GO

IF OBJECT_ID(N'[NOM].[TipoPago]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[TipoPago] (
        [PKIdTipoPago] int IDENTITY(1,1) NOT NULL,
        [Descripcion] nvarchar(100) NOT NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL DEFAULT 1,
        [TotalPeriodos] int NOT NULL,
        CONSTRAINT [PK_NOM_TipoPago] PRIMARY KEY ([PKIdTipoPago])
    );
END
GO

IF OBJECT_ID(N'[NOM].[TipoPension]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[TipoPension] (
        [PKIdTipoPension] int IDENTITY(1,1) NOT NULL,
        [Descripcion] nvarchar(32) NOT NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL DEFAULT 1,
        CONSTRAINT [PK_NOM_TipoPension] PRIMARY KEY ([PKIdTipoPension])
    );
END
GO
