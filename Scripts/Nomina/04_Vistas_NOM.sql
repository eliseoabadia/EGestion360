-- Vistas operativas de Nomina.
-- Ejecutar despues de crear o migrar las tablas NOM en la BD destino.

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'NOM')
    EXEC(N'CREATE SCHEMA [NOM]');
GO

CREATE OR ALTER VIEW [NOM].[VwConcepto]
AS
SELECT
    c.[PKIdConcepto],
    LTRIM(RTRIM(CONVERT(nvarchar(20), c.[Clave]))) AS [Clave],
    LTRIM(RTRIM(CONVERT(nvarchar(20), c.[SubClave]))) AS [SubClave],
    LTRIM(RTRIM(CONVERT(nvarchar(5), c.[PerDed]))) AS [PerDed],
    CASE LTRIM(RTRIM(CONVERT(nvarchar(5), c.[PerDed])))
        WHEN N'P' THEN N'Percepcion'
        WHEN N'D' THEN N'Deduccion'
        WHEN N'A' THEN N'Aportacion'
        ELSE N'Otro'
    END AS [TipoMovimiento],
    COALESCE(c.[Nombre], N'') AS [Nombre],
    CONCAT(LTRIM(RTRIM(CONVERT(nvarchar(20), c.[Clave]))), N' - ', COALESCE(c.[Nombre], N'')) AS [ClaveNombre],
    c.[FKIdFormaCalculo_NOM] AS [FormaCalculoId],
    CAST(NULL AS int) AS [EmpresaId],
    CAST(N'' AS nvarchar(250)) AS [EmpresaNombre],
    c.[Activo],
    c.[UsuarioCreacion],
    c.[FechaCreacion],
    c.[UsuarioModificacion],
    c.[FechaModificacion]
FROM [NOM].[Concepto] c;
GO

CREATE OR ALTER VIEW [NOM].[VwPersona]
AS
SELECT
    p.[PKIdPersona],
    p.[Clave],
    COALESCE(p.[Nombre], N'') AS [Nombre],
    COALESCE(p.[Paterno], N'') AS [Paterno],
    COALESCE(p.[Materno], N'') AS [Materno],
    LTRIM(RTRIM(CONCAT(COALESCE(p.[Nombre], N''), N' ', COALESCE(p.[Paterno], N''), N' ', COALESCE(p.[Materno], N'')))) AS [NombreCompleto],
    CONCAT(COALESCE(p.[Clave], N''), N' - ', LTRIM(RTRIM(CONCAT(COALESCE(p.[Nombre], N''), N' ', COALESCE(p.[Paterno], N''), N' ', COALESCE(p.[Materno], N''))))) AS [ClaveNombre],
    p.[RFC] AS [Rfc],
    p.[Curp],
    p.[PUESTO] AS [Puesto],
    CAST(COALESCE(p.[SUELDO_BASE], 0) AS decimal(19,4)) AS [SueldoBase],
    CAST(COALESCE(p.[COMPENSACION_GARANTIZADA], 0) AS decimal(19,4)) AS [CompensacionGarantizada],
    CAST(NULL AS int) AS [EmpresaId],
    CAST(N'' AS nvarchar(250)) AS [EmpresaNombre],
    p.[Activo],
    p.[FechaCreacion],
    p.[UsuarioCreacion],
    p.[FechaModificacion],
    p.[UsuarioModificacion]
FROM [NOM].[Persona] p;
GO

CREATE OR ALTER VIEW [NOM].[VwPersonaArea]
AS
SELECT
    pa.[PKIdPersonaArea],
    pa.[FKIdPersona_NOM] AS [PersonaId],
    vp.[ClaveNombre] AS [PersonaClaveNombre],
    pa.[FKIdArea_SIS] AS [AreaId],
    COALESCE(a.[Clave], N'') AS [AreaClave],
    COALESCE(a.[Nombre], N'') AS [AreaNombre],
    CONCAT(COALESCE(a.[Clave], N''), N' - ', COALESCE(a.[Nombre], N'')) AS [AreaClaveNombre],
    pa.[IsAdscrito],
    COALESCE(pa.[EsSolicitante], CONVERT(bit, 0)) AS [EsSolicitante],
    COALESCE(pa.[EsAutorizador], CONVERT(bit, 0)) AS [EsAutorizador],
    CAST(NULL AS int) AS [EmpresaId],
    CAST(N'' AS nvarchar(250)) AS [EmpresaNombre],
    pa.[Activo],
    pa.[FechaCreacion],
    pa.[UsuarioCreacion],
    pa.[FechaModificacion],
    pa.[UsuarioModificacion]
FROM [NOM].[PersonaArea] pa
LEFT JOIN [NOM].[VwPersona] vp ON vp.[PKIdPersona] = pa.[FKIdPersona_NOM]
LEFT JOIN [SIS].[Area] a ON a.[PKIdArea] = pa.[FKIdArea_SIS];
GO

CREATE OR ALTER VIEW [NOM].[VwConceptoFactor]
AS
SELECT
    cf.[PKIdConceptoFactor],
    cf.[FKIdConcepto_NOM] AS [ConceptoId],
    vc.[Clave] AS [ConceptoClave],
    vc.[Nombre] AS [ConceptoNombre],
    vc.[ClaveNombre] AS [ConceptoClaveNombre],
    CAST(cf.[Factor] AS decimal(19,4)) AS [Factor],
    cf.[QuincenaInicio],
    cf.[QuincenaFin],
    COALESCE(cf.[Observaciones], N'') AS [Observaciones],
    CAST(NULL AS int) AS [EmpresaId],
    CAST(N'' AS nvarchar(250)) AS [EmpresaNombre],
    cf.[Activo],
    cf.[UsuarioCreacion],
    cf.[FechaCreacion],
    cf.[UsuarioModificacion],
    cf.[FechaModificacion]
FROM [NOM].[ConceptoFactor] cf
LEFT JOIN [NOM].[VwConcepto] vc ON vc.[PKIdConcepto] = cf.[FKIdConcepto_NOM];
GO

CREATE OR ALTER VIEW [NOM].[VwConceptoFijo]
AS
SELECT
    cf.[PKIdConceptoFijo],
    cf.[FKIdEmpresa_SIS] AS [EmpresaId],
    COALESCE(e.[Nombre], N'') AS [EmpresaNombre],
    cf.[FKIdConcepto_NOM] AS [ConceptoId],
    vc.[Clave] AS [ConceptoClave],
    vc.[Nombre] AS [ConceptoNombre],
    vc.[ClaveNombre] AS [ConceptoClaveNombre],
    cf.[FKIdPuesto_NOM] AS [PuestoId],
    CAST(cf.[ImporteMensualFijo] AS decimal(19,4)) AS [ImporteMensualFijo],
    cf.[FechaIni] AS [FechaInicio],
    cf.[FechaFin],
    CAST(
        CASE
            WHEN cf.[Activo] = 1
             AND (cf.[FechaIni] IS NULL OR cf.[FechaIni] <= CONVERT(date, SYSDATETIME()))
             AND (cf.[FechaFin] IS NULL OR cf.[FechaFin] >= CONVERT(date, SYSDATETIME()))
            THEN 1 ELSE 0
        END AS bit
    ) AS [Vigente],
    cf.[Activo],
    cf.[UsuarioCreacion],
    cf.[FechaCreacion],
    cf.[UsuarioModificacion],
    cf.[FechaModificacion]
FROM [NOM].[ConceptoFijo] cf
LEFT JOIN [SIS].[Empresa] e ON e.[PKIdEmpresa] = cf.[FKIdEmpresa_SIS]
LEFT JOIN [NOM].[VwConcepto] vc ON vc.[PKIdConcepto] = cf.[FKIdConcepto_NOM];
GO

CREATE OR ALTER VIEW [NOM].[VwConceptoProporcional]
AS
SELECT
    cp.[PKIdConceptoProporcional],
    cp.[FKIdEmpresa_SIS] AS [EmpresaId],
    COALESCE(e.[Nombre], N'') AS [EmpresaNombre],
    cp.[FKIdPuesto_NOM] AS [PuestoId],
    cp.[FKIdConcepto_NOM] AS [ConceptoId],
    vc.[Clave] AS [ConceptoClave],
    vc.[Nombre] AS [ConceptoNombre],
    vc.[ClaveNombre] AS [ConceptoClaveNombre],
    cp.[Activo],
    cp.[UsuarioCreacion],
    cp.[FechaCreacion],
    cp.[UsuarioModificacion],
    cp.[FechaModificacion]
FROM [NOM].[ConceptoProporcional] cp
LEFT JOIN [SIS].[Empresa] e ON e.[PKIdEmpresa] = cp.[FKIdEmpresa_SIS]
LEFT JOIN [NOM].[VwConcepto] vc ON vc.[PKIdConcepto] = cp.[FKIdConcepto_NOM];
GO

CREATE OR ALTER VIEW [NOM].[VwConceptoPorcentaje]
AS
SELECT
    cpo.[PKIdConceptoPorcentaje],
    cpo.[FKIdConceptoProporcional_NOM] AS [ConceptoProporcionalId],
    vcp.[EmpresaId],
    vcp.[EmpresaNombre],
    vcp.[PuestoId],
    vcp.[ConceptoClaveNombre] AS [ConceptoProporcionalClaveNombre],
    cpo.[FKIdConcepto_NOM] AS [ConceptoId],
    vc.[Clave] AS [ConceptoClave],
    vc.[Nombre] AS [ConceptoNombre],
    vc.[ClaveNombre] AS [ConceptoClaveNombre],
    CAST(cpo.[Porcentaje] AS decimal(19,4)) AS [Porcentaje],
    cpo.[Activo],
    cpo.[UsuarioCreacion],
    cpo.[FechaCreacion],
    cpo.[UsuarioModificacion],
    cpo.[FechaModificacion]
FROM [NOM].[ConceptoPorcentaje] cpo
LEFT JOIN [NOM].[VwConceptoProporcional] vcp ON vcp.[PKIdConceptoProporcional] = cpo.[FKIdConceptoProporcional_NOM]
LEFT JOIN [NOM].[VwConcepto] vc ON vc.[PKIdConcepto] = cpo.[FKIdConcepto_NOM];
GO

CREATE OR ALTER VIEW [NOM].[VwConceptoTabular]
AS
SELECT
    ct.[PKIdConceptoTabulador],
    ct.[FKIdEmpresa_SIS] AS [EmpresaId],
    COALESCE(e.[Nombre], N'') AS [EmpresaNombre],
    ct.[FKIdConcepto_NOM] AS [ConceptoId],
    vc.[Clave] AS [ConceptoClave],
    vc.[Nombre] AS [ConceptoNombre],
    vc.[ClaveNombre] AS [ConceptoClaveNombre],
    ct.[FKIdPuesto_NOM] AS [PuestoId],
    CAST(ct.[ImporteMensual] AS decimal(19,4)) AS [ImporteMensual],
    ct.[FechaInicio],
    ct.[FechaFin],
    CAST(
        CASE
            WHEN ct.[Activo] = 1
             AND (ct.[FechaInicio] IS NULL OR ct.[FechaInicio] <= CONVERT(date, SYSDATETIME()))
             AND (ct.[FechaFin] IS NULL OR ct.[FechaFin] >= CONVERT(date, SYSDATETIME()))
            THEN 1 ELSE 0
        END AS bit
    ) AS [Vigente],
    ct.[Activo],
    ct.[UsuarioCreacion],
    ct.[FechaCreacion],
    ct.[UsuarioModificacion],
    ct.[FechaModificacion]
FROM [NOM].[ConceptoTabular] ct
LEFT JOIN [SIS].[Empresa] e ON e.[PKIdEmpresa] = ct.[FKIdEmpresa_SIS]
LEFT JOIN [NOM].[VwConcepto] vc ON vc.[PKIdConcepto] = ct.[FKIdConcepto_NOM];
GO

CREATE OR ALTER VIEW [NOM].[VwConceptoVariable]
AS
SELECT
    cv.[PKIdConceptoVariable],
    cv.[FKIdEmpresa_SIS] AS [EmpresaId],
    COALESCE(e.[Nombre], N'') AS [EmpresaNombre],
    cv.[FKIdPersona_NOM] AS [PersonaId],
    vp.[ClaveNombre] AS [PersonaClaveNombre],
    cv.[FKIdPeriodo] AS [PeriodoId],
    cv.[FKIdConcepto_NOM] AS [ConceptoId],
    vc.[Clave] AS [ConceptoClave],
    vc.[Nombre] AS [ConceptoNombre],
    vc.[ClaveNombre] AS [ConceptoClaveNombre],
    CAST(cv.[Importe] AS decimal(19,4)) AS [Importe],
    COALESCE(cv.[Referencia], N'') AS [Referencia],
    cv.[Activo],
    cv.[UsuarioCreacion],
    cv.[FechaCreacion],
    cv.[UsuarioModificacion],
    cv.[FechaModificacion]
FROM [NOM].[ConceptoVariable] cv
LEFT JOIN [SIS].[Empresa] e ON e.[PKIdEmpresa] = cv.[FKIdEmpresa_SIS]
LEFT JOIN [NOM].[VwPersona] vp ON vp.[PKIdPersona] = cv.[FKIdPersona_NOM]
LEFT JOIN [NOM].[VwConcepto] vc ON vc.[PKIdConcepto] = cv.[FKIdConcepto_NOM];
GO

CREATE OR ALTER VIEW [NOM].[VwContratoTerceros]
AS
SELECT
    ct.[PKIdContratoTercero],
    ct.[FKIdEmpresa_SIS] AS [EmpresaId],
    COALESCE(e.[Nombre], N'') AS [EmpresaNombre],
    ct.[NombreContrato],
    ct.[Descripcion],
    CONCAT(ct.[NombreContrato], N' - ', ct.[Descripcion]) AS [ClaveNombre],
    ct.[Activo],
    ct.[UsuarioCreacion],
    ct.[FechaCreacion],
    ct.[UsuarioModificacion],
    ct.[FechaModificacion]
FROM [NOM].[ContratoTerceros] ct
LEFT JOIN [SIS].[Empresa] e ON e.[PKIdEmpresa] = ct.[FKIdEmpresa_SIS];
GO

CREATE OR ALTER VIEW [NOM].[VwCredito]
AS
SELECT
    c.[PKIdCredito],
    vct.[EmpresaId],
    vct.[EmpresaNombre],
    c.[FKIdPersona_NOM] AS [PersonaId],
    vp.[ClaveNombre] AS [PersonaClaveNombre],
    c.[FKIdContratoTercero_NOM] AS [ContratoTerceroId],
    vct.[NombreContrato],
    c.[MotivoCredito],
    CAST(c.[ImporteCredito] AS decimal(19,4)) AS [ImporteCredito],
    CAST(c.[TasaInteres] AS decimal(19,4)) AS [TasaInteres],
    c.[NumeroPagos],
    c.[FKIdPeriodoInicial] AS [PeriodoInicialId],
    CAST(c.[ImportePago] AS decimal(19,4)) AS [ImportePago],
    COUNT(dc.[PKIdDescuentoCredito]) AS [PagosRegistrados],
    SUM(CASE WHEN dc.[EstaDescontado] = 1 THEN 1 ELSE 0 END) AS [PagosDescontados],
    CAST(c.[ImporteCredito] - (SUM(CASE WHEN dc.[EstaDescontado] = 1 THEN 1 ELSE 0 END) * c.[ImportePago]) AS decimal(19,4)) AS [SaldoEstimado],
    c.[Activo],
    c.[FechaCreacion],
    c.[UsuarioCreacion],
    c.[FechaModificacion],
    c.[UsuarioModificacion]
FROM [NOM].[Credito] c
LEFT JOIN [NOM].[VwPersona] vp ON vp.[PKIdPersona] = c.[FKIdPersona_NOM]
LEFT JOIN [NOM].[VwContratoTerceros] vct ON vct.[PKIdContratoTercero] = c.[FKIdContratoTercero_NOM]
LEFT JOIN [NOM].[DescuentoCredito] dc ON dc.[FKIdCredito_NOM] = c.[PKIdCredito]
GROUP BY
    c.[PKIdCredito], vct.[EmpresaId], vct.[EmpresaNombre], c.[FKIdPersona_NOM], vp.[ClaveNombre],
    c.[FKIdContratoTercero_NOM], vct.[NombreContrato], c.[MotivoCredito], c.[ImporteCredito],
    c.[TasaInteres], c.[NumeroPagos], c.[FKIdPeriodoInicial], c.[ImportePago],
    c.[Activo], c.[FechaCreacion], c.[UsuarioCreacion], c.[FechaModificacion], c.[UsuarioModificacion];
GO

CREATE OR ALTER VIEW [NOM].[VwDescuentoCredito]
AS
SELECT
    dc.[PKIdDescuentoCredito],
    vc.[EmpresaId],
    vc.[EmpresaNombre],
    dc.[FKIdCredito_NOM] AS [CreditoId],
    vc.[MotivoCredito],
    vc.[PersonaClaveNombre],
    dc.[FKIdPeriodo] AS [PeriodoId],
    dc.[NumeroPago],
    dc.[EstaDescontado],
    dc.[FechaDescuento],
    dc.[Activo],
    dc.[UsuarioCreacion],
    dc.[FechaCreacion],
    dc.[UsuarioModificacion],
    dc.[FechaModificacion]
FROM [NOM].[DescuentoCredito] dc
LEFT JOIN [NOM].[VwCredito] vc ON vc.[PKIdCredito] = dc.[FKIdCredito_NOM];
GO

CREATE OR ALTER VIEW [NOM].[VwEstatusPago]
AS
SELECT
    ep.[PKIdEstatusPago],
    ep.[Descripcion],
    CAST(NULL AS int) AS [EmpresaId],
    CAST(N'' AS nvarchar(250)) AS [EmpresaNombre],
    ep.[Activo],
    ep.[FechaCreacion],
    ep.[UsuarioCreacion],
    ep.[FechaModificacion],
    ep.[UsuarioModificacion]
FROM [NOM].[EstatusPago] ep;
GO

CREATE OR ALTER VIEW [NOM].[VwFactorInt]
AS
SELECT
    fi.[PKIdFactor],
    fi.[Anio],
    fi.[Vacaciones],
    CAST(fi.[Vacacional] AS decimal(19,4)) AS [Vacacional],
    fi.[Aguinaldo],
    CAST(fi.[Integracion] AS decimal(19,4)) AS [Integracion],
    CAST(fi.[PrimaDominical] AS decimal(19,4)) AS [PrimaDominical],
    CAST(NULL AS int) AS [EmpresaId],
    CAST(N'' AS nvarchar(250)) AS [EmpresaNombre],
    fi.[Activo],
    fi.[UsuarioCreacion],
    fi.[FechaCreacion],
    fi.[UsuarioModificacion],
    fi.[FechaModificacion]
FROM [NOM].[FactorInt] fi;
GO

CREATE OR ALTER VIEW [NOM].[VwInfonavit]
AS
SELECT
    i.[PKIdInfonavit],
    CAST(NULL AS int) AS [EmpresaId],
    CAST(N'' AS nvarchar(250)) AS [EmpresaNombre],
    i.[FKIdPersona_NOM] AS [PersonaId],
    vp.[ClaveNombre] AS [PersonaClaveNombre],
    i.[FKIdUnidadInfonavit_NOM] AS [UnidadInfonavitId],
    i.[MotivoInfonavit],
    CAST(i.[ImporteInfonavit] AS decimal(19,4)) AS [ImporteInfonavit],
    CAST(i.[TasaInteres] AS decimal(19,4)) AS [TasaInteres],
    i.[NumeroPagos],
    i.[FKIdPeriodoInicial] AS [PeriodoInicialId],
    i.[FKIdPeriodoFinal] AS [PeriodoFinalId],
    i.[FechaInicial],
    i.[FechaFinal],
    CAST(i.[ImportePago] AS decimal(19,4)) AS [ImportePago],
    COUNT(di.[PKIdDescuentoInfonavit]) AS [PagosRegistrados],
    SUM(CASE WHEN di.[EstaDescontado] = 1 THEN 1 ELSE 0 END) AS [PagosDescontados],
    CAST(i.[ImporteInfonavit] - (SUM(CASE WHEN di.[EstaDescontado] = 1 THEN 1 ELSE 0 END) * i.[ImportePago]) AS decimal(19,4)) AS [SaldoEstimado],
    i.[Activo],
    i.[FechaCreacion],
    i.[UsuarioCreacion],
    i.[FechaModificacion],
    i.[UsuarioModificacion]
FROM [NOM].[Infonavit] i
LEFT JOIN [NOM].[VwPersona] vp ON vp.[PKIdPersona] = i.[FKIdPersona_NOM]
LEFT JOIN [NOM].[DescuentoInfonavit] di ON di.[FKIdInfonavit_NOM] = i.[PKIdInfonavit]
GROUP BY
    i.[PKIdInfonavit], i.[FKIdPersona_NOM], vp.[ClaveNombre], i.[FKIdUnidadInfonavit_NOM],
    i.[MotivoInfonavit], i.[ImporteInfonavit], i.[TasaInteres], i.[NumeroPagos],
    i.[FKIdPeriodoInicial], i.[FKIdPeriodoFinal], i.[FechaInicial], i.[FechaFinal],
    i.[ImportePago], i.[Activo], i.[FechaCreacion], i.[UsuarioCreacion],
    i.[FechaModificacion], i.[UsuarioModificacion];
GO

CREATE OR ALTER VIEW [NOM].[VwDescuentoInfonavit]
AS
SELECT
    di.[PKIdDescuentoInfonavit],
    vi.[EmpresaId],
    vi.[EmpresaNombre],
    di.[FKIdInfonavit_NOM] AS [InfonavitId],
    vi.[MotivoInfonavit],
    vi.[PersonaClaveNombre],
    di.[FKIdPeriodo] AS [PeriodoId],
    di.[NumeroPago],
    CAST(CASE WHEN di.[EstaDescontado] = 1 THEN 1 ELSE 0 END AS bit) AS [EstaDescontado],
    di.[FechaDescuento],
    di.[Activo],
    di.[UsuarioCreacion],
    di.[FechaCreacion],
    di.[UsuarioModificacion],
    di.[FechaModificacion]
FROM [NOM].[DescuentoInfonavit] di
LEFT JOIN [NOM].[VwInfonavit] vi ON vi.[PKIdInfonavit] = di.[FKIdInfonavit_NOM];
GO

CREATE OR ALTER VIEW [NOM].[VwPeriodoActivo]
AS
SELECT
    pa.[PKIdPeriodoActivo],
    pa.[FKIdEmpresa_SIS] AS [EmpresaId],
    COALESCE(e.[Nombre], N'') AS [EmpresaNombre],
    pa.[IdPeriodo] AS [PeriodoId],
    pa.[EstaCerrado],
    COALESCE(pa.[EstaComprometido], CONVERT(bit, 0)) AS [EstaComprometido],
    COALESCE(pa.[EstaDevengado], CONVERT(bit, 0)) AS [EstaDevengado],
    COALESCE(pa.[EstaEjercido], CONVERT(bit, 0)) AS [EstaEjercido],
    pa.[Activo],
    pa.[FechaCreacion],
    pa.[UsuarioCreacion],
    pa.[FechaModificacion],
    pa.[UsuarioModificacion]
FROM [NOM].[PeriodoActivo] pa
LEFT JOIN [SIS].[Empresa] e ON e.[PKIdEmpresa] = pa.[FKIdEmpresa_SIS];
GO

CREATE OR ALTER VIEW [NOM].[VwSalarioMinimo]
AS
SELECT
    sm.[PKIdSalarioMinimo],
    sm.[ZonaEconomica],
    sm.[QuincenaInicio],
    sm.[QuincenaFin],
    CAST(sm.[Importe] AS decimal(19,4)) AS [Importe],
    CAST(NULL AS int) AS [EmpresaId],
    CAST(N'' AS nvarchar(250)) AS [EmpresaNombre],
    sm.[Activo],
    sm.[UsuarioCreacion],
    sm.[FechaCreacion],
    sm.[UsuarioModificacion],
    sm.[FechaModificacion]
FROM [NOM].[SalarioMinimo] sm;
GO

CREATE OR ALTER VIEW [NOM].[VwSueldoMensual]
AS
SELECT
    sm.[PKIdSueldoMensual] AS [IdMovimiento],
    sm.[PKIdSueldoMensual],
    N'Mensual' AS [TipoNomina],
    sm.[FKIdEmpresa_SIS] AS [EmpresaId],
    COALESCE(e.[Nombre], N'') AS [EmpresaNombre],
    sm.[FKIdPersona_NOM] AS [PersonaId],
    vp.[ClaveNombre] AS [PersonaClaveNombre],
    sm.[FKIdPeriodoMensual_NOM] AS [PeriodoId],
    sm.[FKIdConcepto_NOM] AS [ConceptoId],
    vc.[Clave] AS [ConceptoClave],
    vc.[Nombre] AS [ConceptoNombre],
    vc.[ClaveNombre] AS [ConceptoClaveNombre],
    CAST(COALESCE(sm.[Percepcion], 0) AS decimal(19,4)) AS [Percepcion],
    CAST(COALESCE(sm.[Deduccion], 0) AS decimal(19,4)) AS [Deduccion],
    CAST(COALESCE(sm.[Aportacion], 0) AS decimal(19,4)) AS [Aportacion],
    CAST(COALESCE(sm.[Percepcion], 0) - COALESCE(sm.[Deduccion], 0) AS decimal(19,4)) AS [Neto],
    COALESCE(sm.[Referencia], N'') AS [Referencia],
    sm.[Activo],
    sm.[FechaCreacion],
    sm.[UsuarioCreacion],
    sm.[FechaModificacion],
    sm.[UsuarioModificacion]
FROM [NOM].[SueldoMensual] sm
LEFT JOIN [SIS].[Empresa] e ON e.[PKIdEmpresa] = sm.[FKIdEmpresa_SIS]
LEFT JOIN [NOM].[VwPersona] vp ON vp.[PKIdPersona] = sm.[FKIdPersona_NOM]
LEFT JOIN [NOM].[VwConcepto] vc ON vc.[PKIdConcepto] = sm.[FKIdConcepto_NOM];
GO

CREATE OR ALTER VIEW [NOM].[VwSueldoQuincenal]
AS
SELECT
    sq.[PKIdSueldoQuincenal] AS [IdMovimiento],
    sq.[PKIdSueldoQuincenal],
    N'Quincenal' AS [TipoNomina],
    sq.[FKIdEmpresa_SIS] AS [EmpresaId],
    COALESCE(e.[Nombre], N'') AS [EmpresaNombre],
    sq.[FKIdPersona_NOM] AS [PersonaId],
    vp.[ClaveNombre] AS [PersonaClaveNombre],
    sq.[FKIdPeriodoQuincenal_NOM] AS [PeriodoId],
    sq.[FKIdConcepto_NOM] AS [ConceptoId],
    vc.[Clave] AS [ConceptoClave],
    vc.[Nombre] AS [ConceptoNombre],
    vc.[ClaveNombre] AS [ConceptoClaveNombre],
    CAST(COALESCE(sq.[Percepcion], 0) AS decimal(19,4)) AS [Percepcion],
    CAST(COALESCE(sq.[Deduccion], 0) AS decimal(19,4)) AS [Deduccion],
    CAST(COALESCE(sq.[Aportacion], 0) AS decimal(19,4)) AS [Aportacion],
    CAST(COALESCE(sq.[Percepcion], 0) - COALESCE(sq.[Deduccion], 0) AS decimal(19,4)) AS [Neto],
    COALESCE(sq.[Referencia], N'') AS [Referencia],
    sq.[Activo],
    sq.[FechaCreacion],
    sq.[UsuarioCreacion],
    sq.[FechaModificacion],
    sq.[UsuarioModificacion]
FROM [NOM].[SueldoQuincenal] sq
LEFT JOIN [SIS].[Empresa] e ON e.[PKIdEmpresa] = sq.[FKIdEmpresa_SIS]
LEFT JOIN [NOM].[VwPersona] vp ON vp.[PKIdPersona] = sq.[FKIdPersona_NOM]
LEFT JOIN [NOM].[VwConcepto] vc ON vc.[PKIdConcepto] = sq.[FKIdConcepto_NOM];
GO

CREATE OR ALTER VIEW [NOM].[VwSueldoSemanal]
AS
SELECT
    ss.[PKIdSueldoSemanal] AS [IdMovimiento],
    ss.[PKIdSueldoSemanal],
    N'Semanal' AS [TipoNomina],
    ss.[FKIdEmpresa_SIS] AS [EmpresaId],
    COALESCE(e.[Nombre], N'') AS [EmpresaNombre],
    ss.[FKIdPersona_NOM] AS [PersonaId],
    vp.[ClaveNombre] AS [PersonaClaveNombre],
    ss.[FKIdPeriodoSemanal_NOM] AS [PeriodoId],
    ss.[FKIdConcepto_NOM] AS [ConceptoId],
    vc.[Clave] AS [ConceptoClave],
    vc.[Nombre] AS [ConceptoNombre],
    vc.[ClaveNombre] AS [ConceptoClaveNombre],
    CAST(COALESCE(ss.[Percepcion], 0) AS decimal(19,4)) AS [Percepcion],
    CAST(COALESCE(ss.[Deduccion], 0) AS decimal(19,4)) AS [Deduccion],
    CAST(COALESCE(ss.[Aportacion], 0) AS decimal(19,4)) AS [Aportacion],
    CAST(COALESCE(ss.[Percepcion], 0) - COALESCE(ss.[Deduccion], 0) AS decimal(19,4)) AS [Neto],
    COALESCE(ss.[Referencia], N'') AS [Referencia],
    ss.[Activo],
    ss.[FechaCreacion],
    ss.[UsuarioCreacion],
    ss.[FechaModificacion],
    ss.[UsuarioModificacion]
FROM [NOM].[SueldoSemanal] ss
LEFT JOIN [SIS].[Empresa] e ON e.[PKIdEmpresa] = ss.[FKIdEmpresa_SIS]
LEFT JOIN [NOM].[VwPersona] vp ON vp.[PKIdPersona] = ss.[FKIdPersona_NOM]
LEFT JOIN [NOM].[VwConcepto] vc ON vc.[PKIdConcepto] = ss.[FKIdConcepto_NOM];
GO

CREATE OR ALTER VIEW [NOM].[VwSueldoEspecial]
AS
SELECT
    se.[PKIdSueldoEspecial] AS [IdMovimiento],
    se.[PKIdSueldoEspecial],
    N'Especial' AS [TipoNomina],
    se.[FKIdEmpresa_SIS] AS [EmpresaId],
    COALESCE(e.[Nombre], N'') AS [EmpresaNombre],
    se.[FKIdPersona_NOM] AS [PersonaId],
    vp.[ClaveNombre] AS [PersonaClaveNombre],
    se.[FKIdNominaEspecial_NOM] AS [PeriodoId],
    se.[FKIdConcepto_NOM] AS [ConceptoId],
    vc.[Clave] AS [ConceptoClave],
    vc.[Nombre] AS [ConceptoNombre],
    vc.[ClaveNombre] AS [ConceptoClaveNombre],
    CAST(COALESCE(se.[Percepcion], 0) AS decimal(19,4)) AS [Percepcion],
    CAST(COALESCE(se.[Deduccion], 0) AS decimal(19,4)) AS [Deduccion],
    CAST(COALESCE(se.[Aportacion], 0) AS decimal(19,4)) AS [Aportacion],
    CAST(COALESCE(se.[Percepcion], 0) - COALESCE(se.[Deduccion], 0) AS decimal(19,4)) AS [Neto],
    COALESCE(se.[Referencia], N'') AS [Referencia],
    se.[Activo],
    se.[FechaCreacion],
    se.[UsuarioCreacion],
    se.[FechaModificacion],
    se.[UsuarioModificacion]
FROM [NOM].[SueldoEspecial] se
LEFT JOIN [SIS].[Empresa] e ON e.[PKIdEmpresa] = se.[FKIdEmpresa_SIS]
LEFT JOIN [NOM].[VwPersona] vp ON vp.[PKIdPersona] = se.[FKIdPersona_NOM]
LEFT JOIN [NOM].[VwConcepto] vc ON vc.[PKIdConcepto] = se.[FKIdConcepto_NOM];
GO

CREATE OR ALTER VIEW [NOM].[VwSueldoLiqFin]
AS
SELECT
    sl.[PKIdSueldoLiqFin] AS [IdMovimiento],
    sl.[PKIdSueldoLiqFin],
    N'Liquidacion/Finiquito' AS [TipoNomina],
    c.[FKIdEmpresa_SIS] AS [EmpresaId],
    COALESCE(e.[Nombre], N'') AS [EmpresaNombre],
    CAST(NULL AS int) AS [PersonaId],
    CAST(N'' AS nvarchar(600)) AS [PersonaClaveNombre],
    sl.[FKIdContrato_PRES] AS [ContratoId],
    c.[NumeroContrato],
    sl.[FKIdConcepto_NOM] AS [ConceptoId],
    vc.[Clave] AS [ConceptoClave],
    vc.[Nombre] AS [ConceptoNombre],
    vc.[ClaveNombre] AS [ConceptoClaveNombre],
    CAST(COALESCE(sl.[Percepcion], 0) AS decimal(19,4)) AS [Percepcion],
    CAST(COALESCE(sl.[Deduccion], 0) AS decimal(19,4)) AS [Deduccion],
    CAST(COALESCE(sl.[Aportacion], 0) AS decimal(19,4)) AS [Aportacion],
    CAST(COALESCE(sl.[Percepcion], 0) - COALESCE(sl.[Deduccion], 0) AS decimal(19,4)) AS [Neto],
    COALESCE(sl.[Referencia], N'') AS [Referencia],
    sl.[Activo],
    sl.[FechaCreacion],
    sl.[UsuarioCreacion],
    sl.[FechaModificacion],
    sl.[UsuarioModificacion]
FROM [NOM].[SueldoLiqFin] sl
LEFT JOIN [PRES].[Contrato] c ON c.[PKIdContrato] = sl.[FKIdContrato_PRES]
LEFT JOIN [SIS].[Empresa] e ON e.[PKIdEmpresa] = c.[FKIdEmpresa_SIS]
LEFT JOIN [NOM].[VwConcepto] vc ON vc.[PKIdConcepto] = sl.[FKIdConcepto_NOM];
GO

CREATE OR ALTER VIEW [NOM].[VwMovimientosNomina]
AS
SELECT
    [IdMovimiento],
    [TipoNomina],
    [EmpresaId],
    [EmpresaNombre],
    [PersonaId],
    [PersonaClaveNombre],
    [PeriodoId],
    [ConceptoId],
    [ConceptoClave],
    [ConceptoNombre],
    [ConceptoClaveNombre],
    [Percepcion],
    [Deduccion],
    [Aportacion],
    [Neto],
    [Referencia],
    [Activo],
    [FechaCreacion],
    [UsuarioCreacion],
    [FechaModificacion],
    [UsuarioModificacion]
FROM [NOM].[VwSueldoMensual]
UNION ALL
SELECT
    [IdMovimiento], [TipoNomina], [EmpresaId], [EmpresaNombre], [PersonaId], [PersonaClaveNombre],
    [PeriodoId], [ConceptoId], [ConceptoClave], [ConceptoNombre], [ConceptoClaveNombre],
    [Percepcion], [Deduccion], [Aportacion], [Neto], [Referencia], [Activo],
    [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]
FROM [NOM].[VwSueldoQuincenal]
UNION ALL
SELECT
    [IdMovimiento], [TipoNomina], [EmpresaId], [EmpresaNombre], [PersonaId], [PersonaClaveNombre],
    [PeriodoId], [ConceptoId], [ConceptoClave], [ConceptoNombre], [ConceptoClaveNombre],
    [Percepcion], [Deduccion], [Aportacion], [Neto], [Referencia], [Activo],
    [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]
FROM [NOM].[VwSueldoSemanal]
UNION ALL
SELECT
    [IdMovimiento], [TipoNomina], [EmpresaId], [EmpresaNombre], [PersonaId], [PersonaClaveNombre],
    [PeriodoId], [ConceptoId], [ConceptoClave], [ConceptoNombre], [ConceptoClaveNombre],
    [Percepcion], [Deduccion], [Aportacion], [Neto], [Referencia], [Activo],
    [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]
FROM [NOM].[VwSueldoEspecial]
UNION ALL
SELECT
    [IdMovimiento], [TipoNomina], [EmpresaId], [EmpresaNombre], [PersonaId], [PersonaClaveNombre],
    [ContratoId], [ConceptoId], [ConceptoClave], [ConceptoNombre], [ConceptoClaveNombre],
    [Percepcion], [Deduccion], [Aportacion], [Neto], [Referencia], [Activo],
    [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]
FROM [NOM].[VwSueldoLiqFin]
UNION ALL
SELECT
    cv.[PKIdConceptoVariable],
    N'Variable',
    cv.[EmpresaId],
    cv.[EmpresaNombre],
    cv.[PersonaId],
    cv.[PersonaClaveNombre],
    cv.[PeriodoId],
    cv.[ConceptoId],
    cv.[ConceptoClave],
    cv.[ConceptoNombre],
    cv.[ConceptoClaveNombre],
    CAST(CASE WHEN vc.[PerDed] = N'D' THEN 0 ELSE cv.[Importe] END AS decimal(19,4)),
    CAST(CASE WHEN vc.[PerDed] = N'D' THEN cv.[Importe] ELSE 0 END AS decimal(19,4)),
    CAST(0 AS decimal(19,4)),
    CAST(CASE WHEN vc.[PerDed] = N'D' THEN -cv.[Importe] ELSE cv.[Importe] END AS decimal(19,4)),
    cv.[Referencia],
    cv.[Activo],
    cv.[FechaCreacion],
    cv.[UsuarioCreacion],
    cv.[FechaModificacion],
    cv.[UsuarioModificacion]
FROM [NOM].[VwConceptoVariable] cv
LEFT JOIN [NOM].[VwConcepto] vc ON vc.[PKIdConcepto] = cv.[ConceptoId];
GO

CREATE OR ALTER VIEW [NOM].[VwResumenPeriodo]
AS
SELECT
    [EmpresaId],
    MAX([EmpresaNombre]) AS [EmpresaNombre],
    [PeriodoId],
    COUNT_BIG(*) AS [TotalMovimientos],
    CAST(SUM([Percepcion]) AS decimal(19,4)) AS [TotalPercepcion],
    CAST(SUM([Deduccion]) AS decimal(19,4)) AS [TotalDeduccion],
    CAST(SUM([Aportacion]) AS decimal(19,4)) AS [TotalAportacion],
    CAST(SUM([Neto]) AS decimal(19,4)) AS [TotalNeto]
FROM [NOM].[VwMovimientosNomina]
WHERE [EmpresaId] IS NOT NULL
  AND [PeriodoId] IS NOT NULL
  AND [Activo] = 1
GROUP BY [EmpresaId], [PeriodoId];
GO

CREATE OR ALTER VIEW [NOM].[VwPeriodoActivoResumen]
AS
SELECT
    pa.[PKIdPeriodoActivo],
    pa.[EmpresaId],
    pa.[EmpresaNombre],
    pa.[PeriodoId],
    pa.[EstaCerrado],
    pa.[EstaComprometido],
    pa.[EstaDevengado],
    pa.[EstaEjercido],
    COALESCE(r.[TotalMovimientos], 0) AS [TotalMovimientos],
    COALESCE(r.[TotalPercepcion], 0) AS [TotalPercepcion],
    COALESCE(r.[TotalDeduccion], 0) AS [TotalDeduccion],
    COALESCE(r.[TotalAportacion], 0) AS [TotalAportacion],
    COALESCE(r.[TotalNeto], 0) AS [TotalNeto],
    pa.[Activo],
    pa.[FechaCreacion],
    pa.[UsuarioCreacion],
    pa.[FechaModificacion],
    pa.[UsuarioModificacion]
FROM [NOM].[VwPeriodoActivo] pa
LEFT JOIN [NOM].[VwResumenPeriodo] r
    ON r.[EmpresaId] = pa.[EmpresaId]
   AND r.[PeriodoId] = pa.[PeriodoId];
GO

CREATE OR ALTER VIEW [NOM].[VwConceptoConfiguracion]
AS
SELECT
    cf.[PKIdConceptoFijo] AS [IdConfiguracion],
    N'Fijo' AS [TipoConfiguracion],
    cf.[EmpresaId],
    cf.[EmpresaNombre],
    CAST(NULL AS int) AS [PersonaId],
    CAST(N'' AS nvarchar(600)) AS [PersonaClaveNombre],
    cf.[PuestoId],
    CAST(NULL AS int) AS [PeriodoId],
    cf.[ConceptoId],
    cf.[ConceptoClave],
    cf.[ConceptoNombre],
    cf.[ConceptoClaveNombre],
    cf.[ImporteMensualFijo] AS [Importe],
    cf.[FechaInicio],
    cf.[FechaFin],
    cf.[Vigente],
    cf.[Activo],
    cf.[FechaCreacion],
    cf.[UsuarioCreacion],
    cf.[FechaModificacion],
    cf.[UsuarioModificacion]
FROM [NOM].[VwConceptoFijo] cf
UNION ALL
SELECT
    ct.[PKIdConceptoTabulador],
    N'Tabular',
    ct.[EmpresaId],
    ct.[EmpresaNombre],
    CAST(NULL AS int),
    CAST(N'' AS nvarchar(600)),
    ct.[PuestoId],
    CAST(NULL AS int),
    ct.[ConceptoId],
    ct.[ConceptoClave],
    ct.[ConceptoNombre],
    ct.[ConceptoClaveNombre],
    ct.[ImporteMensual],
    ct.[FechaInicio],
    ct.[FechaFin],
    ct.[Vigente],
    ct.[Activo],
    ct.[FechaCreacion],
    ct.[UsuarioCreacion],
    ct.[FechaModificacion],
    ct.[UsuarioModificacion]
FROM [NOM].[VwConceptoTabular] ct
UNION ALL
SELECT
    cv.[PKIdConceptoVariable],
    N'Variable',
    cv.[EmpresaId],
    cv.[EmpresaNombre],
    cv.[PersonaId],
    cv.[PersonaClaveNombre],
    CAST(NULL AS int),
    cv.[PeriodoId],
    cv.[ConceptoId],
    cv.[ConceptoClave],
    cv.[ConceptoNombre],
    cv.[ConceptoClaveNombre],
    cv.[Importe],
    CAST(NULL AS date),
    CAST(NULL AS date),
    cv.[Activo],
    cv.[Activo],
    cv.[FechaCreacion],
    cv.[UsuarioCreacion],
    cv.[FechaModificacion],
    cv.[UsuarioModificacion]
FROM [NOM].[VwConceptoVariable] cv;
GO

CREATE OR ALTER VIEW [NOM].[VwTipoIncapacidad]
AS
SELECT
    ti.[PKIdTipoIncapacidad],
    ti.[Clave],
    ti.[Descripcion],
    CONCAT(CONVERT(nvarchar(20), ti.[Clave]), N' - ', ti.[Descripcion]) AS [ClaveNombre],
    CAST(NULL AS int) AS [EmpresaId],
    CAST(N'' AS nvarchar(250)) AS [EmpresaNombre],
    ti.[Activo],
    ti.[UsuarioCreacion],
    ti.[FechaCreacion],
    ti.[UsuarioModificacion],
    ti.[FechaModificacion]
FROM [NOM].[TipoIncapacidad] ti;
GO

CREATE OR ALTER VIEW [NOM].[VwTipoPago]
AS
SELECT
    tp.[PKIdTipoPago],
    tp.[Descripcion],
    tp.[TotalPeriodos],
    tp.[Descripcion] AS [ClaveNombre],
    CAST(NULL AS int) AS [EmpresaId],
    CAST(N'' AS nvarchar(250)) AS [EmpresaNombre],
    tp.[Activo],
    tp.[UsuarioCreacion],
    tp.[FechaCreacion],
    tp.[UsuarioModificacion],
    tp.[FechaModificacion]
FROM [NOM].[TipoPago] tp;
GO

CREATE OR ALTER VIEW [NOM].[VwTipoPension]
AS
SELECT
    tp.[PKIdTipoPension],
    tp.[Descripcion],
    tp.[Descripcion] AS [ClaveNombre],
    CAST(NULL AS int) AS [EmpresaId],
    CAST(N'' AS nvarchar(250)) AS [EmpresaNombre],
    tp.[Activo],
    tp.[UsuarioCreacion],
    tp.[FechaCreacion],
    tp.[UsuarioModificacion],
    tp.[FechaModificacion]
FROM [NOM].[TipoPension] tp;
GO
