USE [GestionEmpresarial]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[ORCO].[Contratos]', 'U') IS NULL
BEGIN
    CREATE TABLE [ORCO].[Contratos]
    (
        [PKIdContrato] INT IDENTITY(1,1) NOT NULL CONSTRAINT [PK_ORCO_Contratos] PRIMARY KEY,
        [FKIdEmpresa_SIS] INT NOT NULL,
        [FKIdOrdenCompra_ORCO] INT NULL,
        [FKIdTipoContrato_ORCO] INT NOT NULL,
        [FKIdTipoDocumento_ORCO] INT NOT NULL,
        [FKIdArea_SIS] INT NULL,
        [FKIdTipoGarantia_ORCO] INT NULL,
        [FKIdProcedimientoContratacion_ORCO] INT NULL,
        [FKIdFundamentoJuridico_ORCO] INT NULL,
        [FundamentoJuridico] NVARCHAR(MAX) NULL,
        [Numero] NVARCHAR(50) NOT NULL CONSTRAINT [DF_ORCO_Contratos_Numero] DEFAULT(''),
        [Descripcion] NVARCHAR(MAX) NOT NULL,
        [FechaContrato] DATE NOT NULL,
        [FechaRecepcion] DATE NULL,
        [FechaFirmaContrato] DATE NULL,
        [FechaVigenciaInicio] DATE NULL,
        [FechaVigenciaFin] DATE NULL,
        [FKIdModalidad_ORCO] INT NULL,
        [MontoMaximo] DECIMAL(18,4) NOT NULL CONSTRAINT [DF_ORCO_Contratos_MontoMaximo] DEFAULT(0),
        [MontoMinimo] DECIMAL(18,4) NOT NULL CONSTRAINT [DF_ORCO_Contratos_MontoMinimo] DEFAULT(0),
        [Penalizacion] DECIMAL(18,4) NULL,
        [PlazoEjecucion] NVARCHAR(250) NULL,
        [FL_Archivo] NVARCHAR(250) NULL,
        [Justificacion] NVARCHAR(MAX) NULL,
        [FKIdArticulo_ORCO] INT NULL,
        [FKIdFraccion_ORCO] INT NULL,
        [SesionSubcomite] NVARCHAR(150) NULL,
        [IsSesionExtraordinaria] BIT NOT NULL CONSTRAINT [DF_ORCO_Contratos_IsSesionExtraordinaria] DEFAULT(0),
        [FechaSesionSubcomite] DATE NULL,
        [FKIdEstatusContrato_ORCO] INT NOT NULL CONSTRAINT [DF_ORCO_Contratos_Estatus] DEFAULT(1),
        [Activo] BIT NOT NULL CONSTRAINT [DF_ORCO_Contratos_Activo] DEFAULT(1),
        [FechaCreacion] DATETIME NOT NULL CONSTRAINT [DF_ORCO_Contratos_FechaCreacion] DEFAULT(GETDATE()),
        [UsuarioCreacion] INT NOT NULL,
        [FechaModificacion] DATETIME NULL,
        [UsuarioModificacion] INT NULL
    );
END
GO

IF COL_LENGTH('ORCO.Contratos', 'FKIdEmpresa_SIS') IS NULL
BEGIN
    ALTER TABLE [ORCO].[Contratos]
        ADD [FKIdEmpresa_SIS] INT NOT NULL
            CONSTRAINT [DF_ORCO_Contratos_FKIdEmpresa_SIS] DEFAULT(1);

    EXEC sys.sp_executesql N'
        UPDATE c
           SET [FKIdEmpresa_SIS] = oc.[FKIdEmpresa_SIS]
          FROM [ORCO].[Contratos] c
          INNER JOIN [ORCO].[OrdenCompra] oc ON oc.[PKIdOrdenCompra] = c.[FKIdOrdenCompra_ORCO];';
END
GO

CREATE OR ALTER VIEW [ORCO].[VwContratos]
AS
SELECT
    c.[PKIdContrato],
    c.[FKIdEmpresa_SIS],
    emp.[Nombre] AS [EmpresaNombre],
    c.[FKIdOrdenCompra_ORCO],
    oc.[NumeroOrdenCompra],
    oc.[Descripcion] AS [OrdenCompraDescripcion],
    oc.[FKIdRequisicion_ORCO],
    req.[Descripcion] AS [RequisicionDescripcion],
    oc.[FKIdProveedor_SIS],
    prov.[Nombre] AS [ProveedorNombre],
    prov.[RFC] AS [ProveedorRfc],
    c.[FKIdTipoContrato_ORCO],
    tc.[Descripcion] AS [TipoContratoDescripcion],
    c.[FKIdTipoDocumento_ORCO],
    td.[Descripcion] AS [TipoDocumentoDescripcion],
    c.[FKIdArea_SIS],
    area.[Nombre] AS [AreaNombre],
    c.[FKIdTipoGarantia_ORCO],
    tg.[Descripcion] AS [TipoGarantiaDescripcion],
    c.[FKIdProcedimientoContratacion_ORCO],
    pc.[Descripcion] AS [ProcedimientoContratacionDescripcion],
    c.[FKIdFundamentoJuridico_ORCO],
    CAST(NULL AS NVARCHAR(250)) AS [FundamentoJuridicoDescripcion],
    c.[FundamentoJuridico],
    c.[Numero],
    c.[Descripcion],
    c.[FechaContrato],
    c.[FechaRecepcion],
    c.[FechaFirmaContrato],
    c.[FechaVigenciaInicio],
    c.[FechaVigenciaFin],
    c.[FKIdModalidad_ORCO],
    mo.[Descripcion] AS [ModalidadDescripcion],
    c.[MontoMaximo],
    c.[MontoMinimo],
    c.[Penalizacion],
    c.[PlazoEjecucion],
    c.[FL_Archivo],
    c.[Justificacion],
    c.[FKIdArticulo_ORCO],
    art.[Descripcion] AS [ArticuloDescripcion],
    c.[FKIdFraccion_ORCO],
    fra.[Descripcion] AS [FraccionDescripcion],
    c.[SesionSubcomite],
    c.[IsSesionExtraordinaria],
    c.[FechaSesionSubcomite],
    c.[FKIdEstatusContrato_ORCO],
    CASE c.[FKIdEstatusContrato_ORCO]
        WHEN 1 THEN 'Inicial'
        WHEN 2 THEN 'Autorizado'
        WHEN 3 THEN 'Cerrado'
        WHEN 4 THEN 'Cancelado'
        ELSE 'Sin estado'
    END AS [EstatusDescripcion],
    c.[Activo],
    c.[FechaCreacion],
    c.[UsuarioCreacion],
    c.[FechaModificacion],
    c.[UsuarioModificacion]
FROM [ORCO].[Contratos] c
LEFT JOIN [SIS].[Empresa] emp ON emp.[PKIdEmpresa] = c.[FKIdEmpresa_SIS]
LEFT JOIN [ORCO].[OrdenCompra] oc ON oc.[PKIdOrdenCompra] = c.[FKIdOrdenCompra_ORCO]
LEFT JOIN [ORCO].[Requisicion] req ON req.[PKIdRequisicion] = oc.[FKIdRequisicion_ORCO]
LEFT JOIN [SIS].[Proveedor] prov ON prov.[PKIdProveedor] = oc.[FKIdProveedor_SIS]
LEFT JOIN [SIS].[Area] area ON area.[PKIdArea] = c.[FKIdArea_SIS]
LEFT JOIN [ORCO].[TipoContrato] tc ON tc.[PKIdTipoContrato] = c.[FKIdTipoContrato_ORCO]
LEFT JOIN [ORCO].[TipoDocumento] td ON td.[PKIdTipoDocumento] = c.[FKIdTipoDocumento_ORCO]
LEFT JOIN [ORCO].[TipoGarantia] tg ON tg.[PKIdTipoGarantia] = c.[FKIdTipoGarantia_ORCO]
LEFT JOIN [ORCO].[ProcedimientoContratacion] pc ON pc.[PKIdProcedimientoContratacion] = c.[FKIdProcedimientoContratacion_ORCO]
LEFT JOIN [ORCO].[Modalidad] mo ON mo.[PKIdModalidad] = c.[FKIdModalidad_ORCO]
LEFT JOIN [ORCO].[Articulo] art ON art.[PKIdArticulo] = c.[FKIdArticulo_ORCO]
LEFT JOIN [ORCO].[Fraccion] fra ON fra.[PKIdFraccion] = c.[FKIdFraccion_ORCO];
GO

CREATE OR ALTER PROCEDURE [ORCO].[SP_MantenimientoContratos]
    @Action INT,
    @PKIdContrato INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdOrdenCompra_ORCO INT = NULL,
    @FKIdTipoContrato_ORCO INT = NULL,
    @FKIdTipoDocumento_ORCO INT = NULL,
    @FKIdArea_SIS INT = NULL,
    @FKIdTipoGarantia_ORCO INT = NULL,
    @FKIdProcedimientoContratacion_ORCO INT = NULL,
    @FKIdFundamentoJuridico_ORCO INT = NULL,
    @FundamentoJuridico NVARCHAR(MAX) = NULL,
    @Numero NVARCHAR(50) = NULL,
    @Descripcion NVARCHAR(MAX) = NULL,
    @FechaContrato DATE = NULL,
    @FechaRecepcion DATE = NULL,
    @FechaFirmaContrato DATE = NULL,
    @FechaVigenciaInicio DATE = NULL,
    @FechaVigenciaFin DATE = NULL,
    @FKIdModalidad_ORCO INT = NULL,
    @MontoMaximo DECIMAL(18,4) = NULL,
    @MontoMinimo DECIMAL(18,4) = NULL,
    @Penalizacion DECIMAL(18,4) = NULL,
    @PlazoEjecucion NVARCHAR(250) = NULL,
    @FL_Archivo NVARCHAR(250) = NULL,
    @Justificacion NVARCHAR(MAX) = NULL,
    @FKIdArticulo_ORCO INT = NULL,
    @FKIdFraccion_ORCO INT = NULL,
    @SesionSubcomite NVARCHAR(150) = NULL,
    @IsSesionExtraordinaria BIT = NULL,
    @FechaSesionSubcomite DATE = NULL,
    @FKIdEstatusContrato_ORCO INT = NULL,
    @IdUser INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 1
    BEGIN
        INSERT INTO [ORCO].[Contratos]
        (
            [FKIdEmpresa_SIS], [FKIdOrdenCompra_ORCO], [FKIdTipoContrato_ORCO], [FKIdTipoDocumento_ORCO],
            [FKIdArea_SIS], [FKIdTipoGarantia_ORCO], [FKIdProcedimientoContratacion_ORCO], [FKIdFundamentoJuridico_ORCO],
            [FundamentoJuridico], [Numero], [Descripcion], [FechaContrato], [FechaRecepcion], [FechaFirmaContrato],
            [FechaVigenciaInicio], [FechaVigenciaFin], [FKIdModalidad_ORCO], [MontoMaximo], [MontoMinimo],
            [Penalizacion], [PlazoEjecucion], [FL_Archivo], [Justificacion], [FKIdArticulo_ORCO], [FKIdFraccion_ORCO],
            [SesionSubcomite], [IsSesionExtraordinaria], [FechaSesionSubcomite], [FKIdEstatusContrato_ORCO], [UsuarioCreacion]
        )
        VALUES
        (
            @FKIdEmpresa_SIS, @FKIdOrdenCompra_ORCO, @FKIdTipoContrato_ORCO, @FKIdTipoDocumento_ORCO,
            @FKIdArea_SIS, @FKIdTipoGarantia_ORCO, @FKIdProcedimientoContratacion_ORCO, @FKIdFundamentoJuridico_ORCO,
            @FundamentoJuridico, ISNULL(@Numero, ''), @Descripcion, ISNULL(@FechaContrato, CONVERT(DATE, GETDATE())),
            @FechaRecepcion, @FechaFirmaContrato, @FechaVigenciaInicio, @FechaVigenciaFin, @FKIdModalidad_ORCO,
            ISNULL(@MontoMaximo, 0), ISNULL(@MontoMinimo, 0), @Penalizacion, @PlazoEjecucion, @FL_Archivo,
            @Justificacion, @FKIdArticulo_ORCO, @FKIdFraccion_ORCO, @SesionSubcomite,
            ISNULL(@IsSesionExtraordinaria, 0), @FechaSesionSubcomite, ISNULL(@FKIdEstatusContrato_ORCO, 1), @IdUser
        );

        SELECT 1 AS Tipo, 'Registro de compromiso creado correctamente.' AS Mensaje, SCOPE_IDENTITY() AS Id, NULL AS Liga;
        RETURN;
    END

    IF @Action = 2
    BEGIN
        UPDATE [ORCO].[Contratos]
           SET [FKIdEmpresa_SIS] = ISNULL(@FKIdEmpresa_SIS, [FKIdEmpresa_SIS]),
               [FKIdOrdenCompra_ORCO] = @FKIdOrdenCompra_ORCO,
               [FKIdTipoContrato_ORCO] = @FKIdTipoContrato_ORCO,
               [FKIdTipoDocumento_ORCO] = @FKIdTipoDocumento_ORCO,
               [FKIdArea_SIS] = @FKIdArea_SIS,
               [FKIdTipoGarantia_ORCO] = @FKIdTipoGarantia_ORCO,
               [FKIdProcedimientoContratacion_ORCO] = @FKIdProcedimientoContratacion_ORCO,
               [FKIdFundamentoJuridico_ORCO] = @FKIdFundamentoJuridico_ORCO,
               [FundamentoJuridico] = @FundamentoJuridico,
               [Numero] = ISNULL(@Numero, ''),
               [Descripcion] = @Descripcion,
               [FechaContrato] = ISNULL(@FechaContrato, [FechaContrato]),
               [FechaRecepcion] = @FechaRecepcion,
               [FechaFirmaContrato] = @FechaFirmaContrato,
               [FechaVigenciaInicio] = @FechaVigenciaInicio,
               [FechaVigenciaFin] = @FechaVigenciaFin,
               [FKIdModalidad_ORCO] = @FKIdModalidad_ORCO,
               [MontoMaximo] = ISNULL(@MontoMaximo, 0),
               [MontoMinimo] = ISNULL(@MontoMinimo, 0),
               [Penalizacion] = @Penalizacion,
               [PlazoEjecucion] = @PlazoEjecucion,
               [FL_Archivo] = @FL_Archivo,
               [Justificacion] = @Justificacion,
               [FKIdArticulo_ORCO] = @FKIdArticulo_ORCO,
               [FKIdFraccion_ORCO] = @FKIdFraccion_ORCO,
               [SesionSubcomite] = @SesionSubcomite,
               [IsSesionExtraordinaria] = ISNULL(@IsSesionExtraordinaria, 0),
               [FechaSesionSubcomite] = @FechaSesionSubcomite,
               [FKIdEstatusContrato_ORCO] = ISNULL(@FKIdEstatusContrato_ORCO, [FKIdEstatusContrato_ORCO]),
               [FechaModificacion] = GETDATE(),
               [UsuarioModificacion] = @IdUser
         WHERE [PKIdContrato] = @PKIdContrato;

        SELECT 1 AS Tipo, 'Registro de compromiso actualizado correctamente.' AS Mensaje, @PKIdContrato AS Id, NULL AS Liga;
        RETURN;
    END

    IF @Action = 3
    BEGIN
        UPDATE [ORCO].[Contratos]
           SET [Activo] = 0,
               [FechaModificacion] = GETDATE(),
               [UsuarioModificacion] = @IdUser
         WHERE [PKIdContrato] = @PKIdContrato;

        SELECT 1 AS Tipo, 'Registro de compromiso eliminado correctamente.' AS Mensaje, @PKIdContrato AS Id, NULL AS Liga;
        RETURN;
    END
END
GO

CREATE OR ALTER VIEW [PRES].[VW_EgreCompNoDev]
AS
WITH ContratoCalendario AS
(
    SELECT
        cd.[FKIdContrato_PRES],
        SUM(ISNULL(cd.[Enero], 0)) AS Ene,
        SUM(ISNULL(cd.[Febrero], 0)) AS Feb,
        SUM(ISNULL(cd.[Marzo], 0)) AS Mar,
        SUM(ISNULL(cd.[Abril], 0)) AS Abr,
        SUM(ISNULL(cd.[Mayo], 0)) AS May,
        SUM(ISNULL(cd.[Junio], 0)) AS Jun,
        SUM(ISNULL(cd.[Julio], 0)) AS Jul,
        SUM(ISNULL(cd.[Agosto], 0)) AS Ago,
        SUM(ISNULL(cd.[Septiembre], 0)) AS Sep,
        SUM(ISNULL(cd.[Octubre], 0)) AS Oct,
        SUM(ISNULL(cd.[Noviembre], 0)) AS Nov,
        SUM(ISNULL(cd.[Diciembre], 0)) AS Dic,
        SUM(ISNULL(cd.[Total], 0)) AS TotalContratado
    FROM [PRES].[ContratoDetalle] cd
    WHERE cd.[Activo] = 1
    GROUP BY cd.[FKIdContrato_PRES]
),
FacturaAplicada AS
(
    SELECT
        cd.[FKIdContrato_PRES],
        SUM(ISNULL(fd.[MontoAplicado], 0)) AS TotalDevengado
    FROM [PRES].[FacturaDetalle] fd
    INNER JOIN [PRES].[Factura] f ON f.[PKIdFactura] = fd.[FKIdFactura_PRES] AND f.[Activo] = 1
    INNER JOIN [PRES].[ContratoDetalle] cd ON cd.[PKIdContratoDetalle] = fd.[FKIdContratoDetalle_PRES] AND cd.[Activo] = 1
    WHERE fd.[Activo] = 1
    GROUP BY cd.[FKIdContrato_PRES]
)
SELECT
    c.[PKIdContrato],
    c.[FKIdEmpresa_SIS],
    c.[FKIdAutorizacionSuficiencia_PRES],
    ss.[FKIdRequisicion_ORCO],
    c.[FKIdPoliza_CONTA],
    c.[FKIdProveedor_SIS],
    p.[FKIdAnio_SIS],
    ea.[PKIdEgresoAutorizado] AS [FKIdEgresoAutorizado_PRES],
    p.[PKIdPrograma] AS [FKIdPrograma_PRES],
    ea.[FKIdFuenteFinanciamiento_PRES],
    c.[NumeroContrato],
    c.[Descripcion],
    c.[FechaContrato],
    c.[FechaInicioVigencia],
    c.[FechaFinVigencia],
    c.[MontoTotal],
    c.[PlazoEjecucion],
    c.[Observaciones],
    c.[Estatus],
    ISNULL(cc.Ene, 0) AS Ene,
    ISNULL(cc.Feb, 0) AS Feb,
    ISNULL(cc.Mar, 0) AS Mar,
    ISNULL(cc.Abr, 0) AS Abr,
    ISNULL(cc.May, 0) AS May,
    ISNULL(cc.Jun, 0) AS Jun,
    ISNULL(cc.Jul, 0) AS Jul,
    ISNULL(cc.Ago, 0) AS Ago,
    ISNULL(cc.Sep, 0) AS Sep,
    ISNULL(cc.Oct, 0) AS Oct,
    ISNULL(cc.Nov, 0) AS Nov,
    ISNULL(cc.Dic, 0) AS Dic,
    ISNULL(cc.TotalContratado, 0) AS TotalContratado,
    ISNULL(fa.TotalDevengado, 0) AS TotalDevengado,
    ISNULL(cc.TotalContratado, 0) - ISNULL(fa.TotalDevengado, 0) AS Total,
    CAST('' AS VARCHAR(MAX)) AS [Message]
FROM [PRES].[Contrato] c
INNER JOIN [PRES].[AutorizacionSuficiencia] aut ON aut.[PKIdAutorizacionSuficiencia] = c.[FKIdAutorizacionSuficiencia_PRES]
INNER JOIN [PRES].[SolicitudSuficiencia] ss ON ss.[PKIdSolicitudSuficiencia] = aut.[FKIdSolicitudSuficiencia_PRES]
INNER JOIN [ORCO].[Requisicion] req ON req.[PKIdRequisicion] = ss.[FKIdRequisicion_ORCO]
INNER JOIN [PRES].[EgresoAutorizado] ea ON ea.[PKIdEgresoAutorizado] = req.[FKIdEgresoAutorizado_PRES]
INNER JOIN [PRES].[Programa] p ON p.[PKIdPrograma] = ea.[FKIdPrograma_PRES]
LEFT JOIN ContratoCalendario cc ON cc.[FKIdContrato_PRES] = c.[PKIdContrato]
LEFT JOIN FacturaAplicada fa ON fa.[FKIdContrato_PRES] = c.[PKIdContrato]
WHERE ea.[FKIdFuenteFinanciamiento_PRES] <> 6
  AND c.[Activo] = 1;
GO

CREATE OR ALTER PROCEDURE [CONTA].[CierreMensual]
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [CONTA].[SP_SaldoMensual];
END
GO

EXEC spConfiguracionDeRolYClaims 'Contratos', 'Registro_Compromiso', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contratos', 'Saldos_Contratos', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Contratos', 'Estado_Contrato', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
GO
