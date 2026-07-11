SET XACT_ABORT ON;
GO

IF OBJECT_ID(N'SIS.NormaJuridica', N'U') IS NULL
BEGIN
    CREATE TABLE SIS.NormaJuridica
    (
        PKIdNormaJuridica int IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_NormaJuridica PRIMARY KEY,
        Clave nvarchar(30) NOT NULL,
        Nombre nvarchar(500) NOT NULL,
        Jurisdiccion nvarchar(100) NOT NULL,
        Ambito nvarchar(30) NOT NULL,
        OrigenRecurso nvarchar(30) NOT NULL,
        Activo bit NOT NULL CONSTRAINT DF_NormaJuridica_Activo DEFAULT (1),
        FechaCreacion datetime2 NOT NULL CONSTRAINT DF_NormaJuridica_Fecha DEFAULT (sysdatetime()),
        UsuarioCreacion int NOT NULL,
        CONSTRAINT UX_NormaJuridica UNIQUE (Clave, Jurisdiccion, OrigenRecurso)
    );
END;
GO

IF OBJECT_ID(N'SIS.NormaJuridicaVersion', N'U') IS NULL
BEGIN
    CREATE TABLE SIS.NormaJuridicaVersion
    (
        PKIdNormaJuridicaVersion int IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_NormaJuridicaVersion PRIMARY KEY,
        FKIdNormaJuridica_SIS int NOT NULL,
        IdentificadorVersion nvarchar(100) NOT NULL,
        Publicacion date NOT NULL,
        VigenciaDesde date NOT NULL,
        VigenciaHasta date NULL,
        UrlFuenteOficial nvarchar(1000) NOT NULL,
        HuellaDocumento varchar(64) NULL,
        Activo bit NOT NULL CONSTRAINT DF_NormaJuridicaVersion_Activo DEFAULT (1),
        FechaCreacion datetime2 NOT NULL CONSTRAINT DF_NormaJuridicaVersion_Fecha DEFAULT (sysdatetime()),
        UsuarioCreacion int NOT NULL,
        CONSTRAINT FK_NormaJuridicaVersion_Norma FOREIGN KEY (FKIdNormaJuridica_SIS)
            REFERENCES SIS.NormaJuridica(PKIdNormaJuridica),
        CONSTRAINT CK_NormaJuridicaVersion_Vigencia CHECK (VigenciaHasta IS NULL OR VigenciaHasta >= VigenciaDesde),
        CONSTRAINT UX_NormaJuridicaVersion UNIQUE (FKIdNormaJuridica_SIS, IdentificadorVersion)
    );
END;
GO

IF OBJECT_ID(N'ORCO.FundamentoProcedimiento', N'U') IS NULL
BEGIN
    CREATE TABLE ORCO.FundamentoProcedimiento
    (
        PKIdFundamentoProcedimiento bigint IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_FundamentoProcedimiento PRIMARY KEY,
        FKIdProcedimientoContratacion_ORCO int NOT NULL,
        FKIdNormaJuridicaVersion_SIS int NOT NULL,
        Articulo nvarchar(50) NOT NULL,
        Fraccion nvarchar(50) NULL,
        Fundamento nvarchar(2000) NOT NULL,
        Motivacion nvarchar(4000) NOT NULL,
        EsExcepcion bit NOT NULL CONSTRAINT DF_FundamentoProcedimiento_Excepcion DEFAULT (0),
        Activo bit NOT NULL CONSTRAINT DF_FundamentoProcedimiento_Activo DEFAULT (1),
        FechaCreacion datetime2 NOT NULL CONSTRAINT DF_FundamentoProcedimiento_Fecha DEFAULT (sysdatetime()),
        UsuarioCreacion int NOT NULL,
        CONSTRAINT FK_FundamentoProcedimiento_NormaVersion FOREIGN KEY (FKIdNormaJuridicaVersion_SIS)
            REFERENCES SIS.NormaJuridicaVersion(PKIdNormaJuridicaVersion)
    );
END;
GO

IF OBJECT_ID(N'ORCO.ProveedorCumplimiento', N'U') IS NULL
BEGIN
    CREATE TABLE ORCO.ProveedorCumplimiento
    (
        PKIdProveedorCumplimiento bigint IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_ProveedorCumplimiento PRIMARY KEY,
        FKIdProveedor_ORCO int NOT NULL,
        FechaVerificacion datetime2 NOT NULL,
        VigenteHasta datetime2 NULL,
        CumplimientoFiscal bit NOT NULL,
        Inhabilitado bit NOT NULL,
        ConflictoInteres bit NOT NULL,
        DeclaracionIntegridad bit NOT NULL,
        FuenteConsulta nvarchar(1000) NOT NULL,
        FolioEvidencia nvarchar(200) NOT NULL,
        HuellaEvidencia varchar(64) NULL,
        Observaciones nvarchar(2000) NULL,
        Activo bit NOT NULL CONSTRAINT DF_ProveedorCumplimiento_Activo DEFAULT (1),
        UsuarioCreacion int NOT NULL,
        CONSTRAINT FK_ProveedorCumplimiento_Proveedor FOREIGN KEY (FKIdProveedor_ORCO)
            REFERENCES SIS.Proveedor(PKIdProveedor),
        CONSTRAINT CK_ProveedorCumplimiento_Vigencia CHECK (VigenteHasta IS NULL OR VigenteHasta >= FechaVerificacion)
    );

    CREATE INDEX IX_ProveedorCumplimiento_ProveedorFecha
        ON ORCO.ProveedorCumplimiento(FKIdProveedor_ORCO, FechaVerificacion DESC);
END;
GO

IF OBJECT_ID(N'ORCO.ExpedienteContratacionControl', N'U') IS NULL
BEGIN
    CREATE TABLE ORCO.ExpedienteContratacionControl
    (
        PKIdExpedienteContratacionControl bigint IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_ExpedienteContratacionControl PRIMARY KEY,
        TipoDocumento nvarchar(100) NOT NULL,
        FolioProcedimiento nvarchar(200) NOT NULL,
        InvestigacionMercado bit NOT NULL,
        NumeroCotizaciones smallint NOT NULL CONSTRAINT DF_Expediente_NumeroCotizaciones DEFAULT (0),
        ValidacionNoFraccionamiento bit NOT NULL,
        ValidacionConflicto bit NOT NULL,
        ValidacionSanciones bit NOT NULL,
        ValidacionFiscal bit NOT NULL,
        Evidencia nvarchar(1000) NOT NULL,
        HuellaEvidencia varchar(64) NULL,
        FechaControl datetime2 NOT NULL CONSTRAINT DF_Expediente_Fecha DEFAULT (sysdatetime()),
        UsuarioControl int NOT NULL,
        Activo bit NOT NULL CONSTRAINT DF_Expediente_Activo DEFAULT (1),
        CONSTRAINT CK_Expediente_Cotizaciones CHECK (NumeroCotizaciones >= 0)
    );
END;
GO

PRINT N'Estructura juridica versionada creada. Debe cargarse la norma aplicable por jurisdiccion y origen del recurso.';
GO
