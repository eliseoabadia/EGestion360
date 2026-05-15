USE [GestionEmpresarial];
GO

-- =============================================
-- VISTAS DEL SISTEMA GestionEmpresarial
-- =============================================

-- =============================================
-- CONTA
-- =============================================

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [CONTA].[Vw_Cuentas]
AS
SELECT 
    cc.PKIdCuentaContable AS PkIdCuenta,
    cc.ClaveOrd,
    cc.NivelCuenta,
    cc.Descripcion,
    cc.Activo,
    cc.TipoCuenta,
    cc.Padre,
	cc.Hijo,
	cc.ClaveOrd + ' ' + cc.Descripcion  AS ClaveNombre,
	cc.Descripcion AS Nombre 
FROM CONTA.CuentaContable cc
WHERE Activo = 1
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [CONTA].[Vw_MatrizConversionColumnas] AS
SELECT 
    -- Identificador de la matriz
    mc.PKIdMatrizConversion,
    -- Año
    a.Clave AS AnioClave,
    -- Programa (clave + descripci�n)
    p.Clave AS ProgramaClave,
    p.Descripcion AS ProgramaDescripcion,
    -- Partida (clave + descripci�n)
    pt.Clave AS PartidaClave,
    CONCAT(pt.Clave, ' ', pt.Descripcion) AS PartidaDescripcion,
    -- Cuenta Aprobado
    ctaA.ClaveNombre AS CuentaAprobado,
    -- Cuenta por Ejercer
    ctaPJ.ClaveNombre AS CuentaPorEjercer,
    -- Cuenta Modificado
    ctaM.ClaveNombre AS CuentaModificado,
    -- Cuenta Comprometido
    ctaC.ClaveNombre AS CuentaComprometido,
    -- Cuenta Devengado
    ctaD.ClaveNombre AS CuentaDevengado,
    -- Cuenta Ejercido
    ctaE.ClaveNombre AS CuentaEjercido,
    -- Cuenta Pagado
    ctaPag.ClaveNombre AS CuentaPagado,
    -- Cuenta Gasto
    ctaG.ClaveNombre AS CuentaGasto,
    -- Datos de auditor�a
    mc.Activo,
    mc.FechaCreacion,
    mc.UsuarioCreacion
FROM CONTA.MatrizConversion mc
INNER JOIN SIS.Anio a ON mc.FKIdAnio_SIS = a.PKIdAnio
INNER JOIN PRES.Programa p ON mc.FKIdPrograma_PRES = p.PKIdPrograma
INNER JOIN SIS.Partida pt ON mc.FKIdPartida_SIS = pt.PKIdPartida
LEFT JOIN CONTA.Vw_Cuentas ctaA ON mc.FKIdCuentaContableAprobado = ctaA.PkIdCuenta AND ctaA.ClaveOrd LIKE '8 2 1%' AND ctaA.NivelCuenta = 7
LEFT JOIN CONTA.Vw_Cuentas ctaPJ ON mc.FKIdCuentaContablePorEjercer = ctaPJ.PkIdCuenta AND ctaPJ.ClaveOrd LIKE '8 2 2%'
LEFT JOIN CONTA.Vw_Cuentas ctaM ON mc.FKIdCuentaContableModificado = ctaM.PkIdCuenta AND ctaM.ClaveOrd LIKE '8 2 3%'
LEFT JOIN CONTA.Vw_Cuentas ctaC ON mc.FKIdCuentaContableComprometido = ctaC.PkIdCuenta AND ctaC.ClaveOrd LIKE '8 2 4%'
LEFT JOIN CONTA.Vw_Cuentas ctaD ON mc.FKIdCuentaContableDevengado = ctaD.PkIdCuenta AND ctaD.ClaveOrd LIKE '8 2 5%'
LEFT JOIN CONTA.Vw_Cuentas ctaE ON mc.FKIdCuentaContableEjercido = ctaE.PkIdCuenta AND ctaE.ClaveOrd LIKE '8 2 6%'
LEFT JOIN CONTA.Vw_Cuentas ctaPag ON mc.FKIdCuentaContablePagado = ctaPag.PkIdCuenta AND ctaPag.ClaveOrd LIKE '8 2 7%'
LEFT JOIN CONTA.Vw_Cuentas ctaG ON mc.FKIdCuentaContableGasto = ctaG.PkIdCuenta AND ctaA.ClaveOrd LIKE '5%'
WHERE mc.Activo = 1
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [CONTA].[Vw_MatrizIngresoColumnas]
AS
SELECT 
    -- Identificador de la matriz
    mi.Pk_IdMatrizIngreso,
    -- A�o
    a.Clave AS AnioClave,
    -- Programa
    p.Clave AS ProgramaClave,
    p.Descripcion AS ProgramaDescripcion,
    -- Origen (fuente del ingreso)
    o.Clave AS OrigenClave,
    o.Descripcion AS OrigenDescripcion,
    -- Cuenta Autorizado
    ctaAut.ClaveNombre AS CuentaAutorizado,
    -- Cuenta por Ejercer
    ctaPJE.ClaveNombre AS CuentaPorEjercer,
    -- Cuenta Modificado
    ctaMod.ClaveNombre AS CuentaModificado,
    -- Cuenta Devengado
    ctaDev.ClaveNombre AS CuentaDevengado,
    -- Cuenta Recaudado
    ctaRec.ClaveNombre AS CuentaRecaudado,
    -- Cuenta Dep�sito
    ctaDep.ClaveNombre AS CuentaDeposito,
    -- Datos de auditor�a
    mi.Activo,
    mi.FechaCreacion,
    mi.UsuarioCreacion
FROM CONTA.MatrizIngreso mi
LEFT JOIN SIS.Anio a ON mi.FK_IdAnio__SIS = a.PKIdAnio
LEFT JOIN PRES.Programa p ON mi.Fk_IdPrograma = p.PKIdPrograma
LEFT JOIN PRES.Origen o ON mi.Fk_IdOrigen = o.PKIdOrigen
LEFT JOIN CONTA.Vw_Cuentas ctaAut ON mi.Fk_IdCuentaContableAutorizado = ctaAut.PkIdCuenta AND ctaAut.ClaveOrd LIKE '8 1%' AND ctaAut.NivelCuenta = 7
LEFT JOIN CONTA.Vw_Cuentas ctaPJE ON mi.Fk_IdCuentaContablePorEjercer = ctaPJE.PkIdCuenta AND ctaPJE.ClaveOrd LIKE '8 1%' AND ctaPJE.NivelCuenta = 7
LEFT JOIN CONTA.Vw_Cuentas ctaMod ON mi.Fk_IdCuentaContableModificado = ctaMod.PkIdCuenta AND ctaMod.ClaveOrd LIKE '8 1%' AND ctaMod.NivelCuenta = 7
LEFT JOIN CONTA.Vw_Cuentas ctaDev ON mi.Fk_IdCuentaContableDevengado = ctaDev.PkIdCuenta AND ctaDev.ClaveOrd LIKE '8 1%' AND ctaDev.NivelCuenta = 7
LEFT JOIN CONTA.Vw_Cuentas ctaRec ON mi.Fk_IdCuentaContableRecaudado = ctaRec.PkIdCuenta AND ctaRec.ClaveOrd LIKE '8 1%' AND ctaRec.NivelCuenta = 7
LEFT JOIN CONTA.Vw_Cuentas ctaDep ON mi.Fk_IdCuentaContableDeposito = ctaDep.PkIdCuenta AND ctaDep.ClaveOrd LIKE '1%' AND ctaDep.NivelCuenta = 7
WHERE mi.Activo = 1;
GO

-- =============================================
-- ALMA
-- =============================================

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [ALMA].[vw_Bien]
AS
SELECT 
    b.PKIdBien,
    b.Clave,
    b.ClaveAnt,
    b.Descripcion,
    b.Modelo,
    b.Serie,
    b.Costo,
    b.FechaAdq,
    b.Factura,
    b.Requisicion,
    b.Referencia,
    b.Notas,
    b.Ubicacion,
    b.AAdquisicion,
    b.Frente,
    b.Fondo,
    b.Altura,
    b.Diametro,
    b.VerificacionesDias,
    b.MantenimientoDias,
    b.Mantenimiento,
    b.Calibracion,
    b.Rango,
    b.Resolucion,
    b.FechaUltInv,
    b.FechaReqscn,
    b.Estatus,
    b.Caracteristicas,
    b.Resguardo,
    b.ResguardoAnterior,
    b.RelId,
    b.ValorRescate,
    b.ValorActual,
    b.Antiguedad,
    b.Progresivo,
    b.Consecutivo,
    b.ClaveHist,
    b.EstaResguardado,
    b.FechaResguardado,
    b.Localizado,
    b.esContabilizado,
    b.Activo,
    b.FechaCreacion,
    b.UsuarioCreacion,
    b.FechaModificacion,
    b.UsuarioModificacion,

    -- Informaci�n de GrupoBien
    gb.Descripcion AS GrupoBienDescripcion,
    gb.Clave AS GrupoBienClave,

    -- Informaci�n de TipoBien
    tb.CodigoClave AS TipoBienCodigoClave,
    tb.Descripcion AS TipoBienDescripcion,
    tb.CABMS AS TipoBienCABMS,
    tb.Identificador AS TipoBienIdentificador,
    tb.CUCOP_PLUS AS TipoBienCUCOP_PLUS,

    -- Informaci�n de �rea (SIS.Area)
    a.Nombre AS AreaNombre,
    a.Clave AS AreaClave,

    -- Informaci�n de Proveedor
    p.Nombre AS ProveedorNombre,
    p.RFC AS ProveedorRFC,
    p.Clave AS ProveedorClave,

    -- Informaci�n de EstadoBien
    eb.DESCRIPCION_GENERAL AS EstadoBienDescripcionGeneral,
    eb.DESCRIPCION_ESPECIFICA AS EstadoBienDescripcionEspecifica,
    eb.DESCRIPCION_CORTA AS EstadoBienDescripcionCorta,

    -- Informaci�n de TipoPatrimonio
    tp.Descripcion AS TipoPatrimonioDescripcion,

    -- Informaci�n de Marca
    m.Descripcion AS MarcaDescripcion,

    -- Informaci�n de Material
    mat.Descripcion AS MaterialDescripcion,

    -- Informaci�n de TipoAdquisicion
    ta.Clave AS TipoAdquisicionClave,
    ta.Descripcion AS TipoAdquisicionDescripcion,
    ta.Descripmovto AS TipoAdquisicionDescripcionMovto,

    -- Informaci�n de Partida (CONTA.Partida)
    part.Clave AS PartidaClave,
    part.Descripcion AS PartidaDescripcion

FROM ALMA.Bien b
LEFT JOIN ALMA.GrupoBien gb ON b.FKIdGrupoBien_ALMA = gb.PKIdGrupoBien
LEFT JOIN ALMA.TipoBien tb ON b.FKIdTipoBien_ALMA = tb.PKIdTipoBien
LEFT JOIN SIS.Area a ON b.FKIdArea_SIS = a.PKIdArea
LEFT JOIN SIS.Proveedor p ON b.FKIdProveedor_SIS = p.PKIdProveedor
LEFT JOIN ALMA.EstadoBien eb ON b.FKIdEstadoBien_ALMA = eb.PKIdEstadoBien
LEFT JOIN ALMA.TipoPatrimonio tp ON b.FKIdTipoPatrimonio_ALMA = tp.PKIdTipoPatrimonio
LEFT JOIN ALMA.Marca m ON b.FKIdMarca_ALMA = m.PKIdMarca
LEFT JOIN ALMA.Material mat ON b.FKIdMaterial_ALMA = mat.PKIdMaterial
LEFT JOIN ALMA.TipoAdquisicion ta ON b.FKIdTipoAdq_ALMA = ta.PKIdTipoAdq
LEFT JOIN CONTA.Partida part ON b.FKIdPartida_CONTA = part.PKIdPartida
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [ALMA].[VW_Conteo]
AS
SELECT
    c.[PKIdConteo],
    c.[CantidadInventario],
    c.[Descripcion],
    c.[FechaInicio],
    c.[FechaFin],
    c.[Activo],
    c.[FechaCreacion],
    c.[UsuarioCreacion],
    c.[FechaModificacion],
    c.[UsuarioModificacion],

    -- Datos del periodo de conteo
    pc.[PKIdPeriodoConteo]          AS [IdPeriodoConteo],
    pc.[CodigoPeriodo]              AS [CodigoPeriodo],
    pc.[Nombre]                     AS [NombrePeriodo],
    pc.[FechaInicio]                AS [PeriodoFechaInicio],
    pc.[FechaFin]                   AS [PeriodoFechaFin],

    -- Tipo de conteo (a trav�s de PeriodoConteo)
    tc.[PKIdTipoConteo]             AS [IdTipoConteo],
    tc.[Nombre]                     AS [TipoConteo],
    tc.[Descripcion]                AS [DescripcionTipoConteo],

    -- Estatus del periodo
    ep.[PKIdEstatusPeriodo]         AS [IdEstatusPeriodo],
    ep.[Nombre]                     AS [EstatusPeriodo],
    ep.[Descripcion]                AS [DescripcionEstatusPeriodo],

    -- Tipo de bien
    tb.[PKIdTipoBien]               AS [IdTipoBien],
    tb.[CodigoClave]                AS [CodigoClaveTipoBien],
    tb.[Descripcion]                AS [DescripcionTipoBien],

    -- Grupo y familia
    gb.[PKIdGrupoBien]              AS [IdGrupoBien],
    gb.[Descripcion]                AS [GrupoBien],
    f.[PKIdFamilia]                 AS [IdFamilia],
    f.[Descripcion]                 AS [Familia],

    -- Unidad de medida
    u.[PKIdUnidades]                AS [IdUnidad],
    u.[Descripcion]                 AS [UnidadMedida],

    -- Usuarios (con datos de persona)
    uc.[PkIdUsuario]                AS [IdUsuarioCreacion],
    ISNULL(puc.[Nombre], '') + ' ' + ISNULL(puc.[Paterno], '') + ' ' + ISNULL(puc.[Materno], '') AS [NombreUsuarioCreacion],
    um.[PkIdUsuario]                AS [IdUsuarioModificacion],
    ISNULL(pum.[Nombre], '') + ' ' + ISNULL(pum.[Paterno], '') + ' ' + ISNULL(pum.[Materno], '') AS [NombreUsuarioModificacion],

    -- M�tricas desde ConteoDetalle
    ISNULL(COUNT(DISTINCT cd.[PKIdDetalleConteo]), 0)      AS [TotalLecturas],
    ISNULL(SUM(cd.[Cantidad]), 0)                          AS [TotalCantidadContada],
    ISNULL(COUNT(DISTINCT cd.[FKIdPersona_NOM]), 0)        AS [PersonasParticipantes],

    -- Estado del conteo individual
    CASE
        WHEN c.[FechaFin] IS NOT NULL AND c.[FechaFin] <= GETDATE() THEN 'Finalizado'
        WHEN c.[FechaInicio] <= GETDATE() AND (c.[FechaFin] IS NULL OR c.[FechaFin] > GETDATE()) THEN 'En Proceso'
        WHEN c.[FechaInicio] > GETDATE() THEN 'Programado'
        ELSE 'Indeterminado'
    END AS [EstadoConteo]

FROM [ALMA].[Conteo] c

INNER JOIN [ALMA].[PeriodoConteo] pc
    ON c.[FKIdPeriodoConteo_ALMA] = pc.[PKIdPeriodoConteo]

LEFT JOIN [ALMA].[TipoConteo] tc
    ON pc.[FKIdTipoConteo_ALMA] = tc.[PKIdTipoConteo]

LEFT JOIN [ALMA].[EstatusPeriodo] ep
    ON pc.[FKIdEstatus_ALMA] = ep.[PKIdEstatusPeriodo]

LEFT JOIN [ALMA].[TipoBien] tb
    ON c.[FKIdTipoBien_ALMA] = tb.[PKIdTipoBien]

LEFT JOIN [ALMA].[GrupoBien] gb
    ON tb.[FKIdGrupoBien_ALMA] = gb.[PKIdGrupoBien]

LEFT JOIN [ALMA].[Familia] f
    ON gb.[FKIdFamilia_ALMA] = f.[PKIdFamilia]

LEFT JOIN [ALMA].[Unidades] u
    ON tb.[FKIdUnidades_ALMA] = u.[PKIdUnidades]

LEFT JOIN [SIS].[Usuario] uc
    ON c.[UsuarioCreacion] = uc.[PkIdUsuario]

LEFT JOIN [SIS].[Usuario] um
    ON c.[UsuarioModificacion] = um.[PkIdUsuario]

LEFT JOIN [NOM].[Persona] puc
    ON uc.[FKIdPersona_NOM] = puc.[PKIdPersona]

LEFT JOIN [NOM].[Persona] pum
    ON um.[FKIdPersona_NOM] = pum.[PKIdPersona]

LEFT JOIN [ALMA].[ConteoDetalle] cd
    ON c.[PKIdConteo] = cd.[FKIdConteo_ALMA]
       AND cd.[Activo] = 1

WHERE c.[Activo] = 1

GROUP BY
    c.[PKIdConteo],
    c.[CantidadInventario],
    c.[Descripcion],
    c.[FechaInicio],
    c.[FechaFin],
    c.[Activo],
    c.[FechaCreacion],
    c.[UsuarioCreacion],
    c.[FechaModificacion],
    c.[UsuarioModificacion],
    pc.[PKIdPeriodoConteo],
    pc.[CodigoPeriodo],
    pc.[Nombre],
    pc.[FechaInicio],
    pc.[FechaFin],
    tc.[PKIdTipoConteo],
    tc.[Nombre],
    tc.[Descripcion],
    ep.[PKIdEstatusPeriodo],
    ep.[Nombre],
    ep.[Descripcion],
    tb.[PKIdTipoBien],
    tb.[CodigoClave],
    tb.[Descripcion],
    gb.[PKIdGrupoBien],
    gb.[Descripcion],
    f.[PKIdFamilia],
    f.[Descripcion],
    u.[PKIdUnidades],
    u.[Descripcion],
    uc.[PkIdUsuario],
    puc.[Nombre],
    puc.[Paterno],
    puc.[Materno],
    um.[PkIdUsuario],
    pum.[Nombre],
    pum.[Paterno],
    pum.[Materno];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [ALMA].[VW_ConteoDetalle]
AS
SELECT
    -- Campos del encabezado (Conteo)
    C.[PKIdConteo],
    C.[FKIdTipoBien_ALMA],
    TB.[Descripcion]          AS [TipoBienDescripcion],
    C.[CantidadInventario]    AS [CantidadInventarioInicial],
    C.[Descripcion]           AS [ConteoDescripcion],
    C.[FechaInicio],
    C.[FechaFin],
    C.[Activo]                AS [ConteoActivo],
    C.[FechaCreacion]         AS [ConteoFechaCreacion],
    C.[UsuarioCreacion]       AS [ConteoUsuarioCreacion],
    C.[FechaModificacion]     AS [ConteoFechaModificacion],
    C.[UsuarioModificacion]   AS [ConteoUsuarioModificacion],

    -- Campos del detalle (ConteoDetalle)
    CD.[PKIdDetalleConteo],
    CD.[FKIdConteo_ALMA],
    CD.[FKIdNumeroConteo_ALMA],
    CD.[FKIdPersona_NOM],
    P.[Nombre]                AS [PersonaNombre],
    P.[Paterno]               AS [PersonaPaterno],
    P.[Materno]               AS [PersonaMaterno],
    CD.[Cantidad]             AS [CantidadContada],
    CD.[Fecha]                AS [FechaConteo],
    CD.[Activo]               AS [DetalleActivo],
    CD.[FechaCreacion]        AS [DetalleFechaCreacion],
    CD.[UsuarioCreacion]      AS [DetalleUsuarioCreacion],
    CD.[FechaModificacion]    AS [DetalleFechaModificacion],
    CD.[UsuarioModificacion]  AS [DetalleUsuarioModificacion]

FROM [ALMA].[Conteo] C
INNER JOIN [ALMA].[ConteoDetalle] CD
    ON C.[PKIdConteo] = CD.[FKIdConteo_ALMA]
LEFT JOIN [ALMA].[TipoBien] TB
    ON C.[FKIdTipoBien_ALMA] = TB.[PKIdTipoBien]
LEFT JOIN [NOM].[Persona] P
    ON CD.[FKIdPersona_NOM] = P.[PKIdPersona];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [ALMA].[VW_ConteoDetalleEscaneo]
AS
SELECT
    cde.[PKIdDetalleEscaneo],
    cde.[FKIdConteo_ALMA],
    cde.[FKIdPersona_NOM],
    cde.[CodigoBarras],
    cde.[FKIdTipoBien_ALMA],
    cde.[FKIdBien_ALMA],
    cde.[FechaEscaneo],
    cde.[Activo],
    cde.[FechaCreacion],
    cde.[UsuarioCreacion],
    cde.[FechaModificacion],
    cde.[UsuarioModificacion],
    -- Informaci�n del Conteo
    c.[Descripcion]             AS [ConteoDescripcion],
    c.[FechaInicio]             AS [ConteoFechaInicio],
    c.[FechaFin]                AS [ConteoFechaFin],
    c.[CantidadInventario]      AS [ConteoCantidadInventario],
    -- Informaci�n del Tipo de Bien
    tb.[Descripcion]            AS [TipoBienDescripcion],
    tb.[CodigoClave]            AS [TipoBienCodigoClave],
    -- Informaci�n de la Persona que escane�
    p.[Nombre]                  AS [PersonaNombre],
    p.[Paterno]                 AS [PersonaPaterno],
    p.[Materno]                 AS [PersonaMaterno],
    p.[Clave]                   AS [PersonaClave],
    -- Informaci�n del Bien (si est� asociado)
    b.[Clave]                   AS [BienClave],
    b.[Serie]                   AS [BienSerie],
    b.[Modelo]                  AS [BienModelo],
    b.[Descripcion]             AS [BienDescripcion]
FROM [ALMA].[ConteoDetalleEscaneo] cde
INNER JOIN [ALMA].[Conteo] c ON cde.[FKIdConteo_ALMA] = c.[PKIdConteo]
INNER JOIN [ALMA].[TipoBien] tb ON cde.[FKIdTipoBien_ALMA] = tb.[PKIdTipoBien]
INNER JOIN [NOM].[Persona] p ON cde.[FKIdPersona_NOM] = p.[PKIdPersona]
LEFT JOIN [ALMA].[Bien] b ON cde.[FKIdBien_ALMA] = b.[PKIdBien];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [ALMA].[VW_Existencias]
AS

WITH Existencias AS
(
    SELECT
        TB.PKIdTipoBien,
        TB.FKIdPartida_CONTA,
        GB.CLAVE_CUCOP AS CUCOP,
        GB.CABM_ACT + ' / ' + GB.ClaveAN AS CABMS,
        TB.CodigoClave,
        TB.Descripcion,
        COUNT(B.PKIdBien) AS Existencias,
        AU.Descripcion AS Unidades,
        0 AS FK_IdAnio__SIS,
        CAST('' AS NVARCHAR(MAX)) AS Message,
        IIF(TB.Cantidad_Equivalente > 1, TB.FKIdUnidades_Equivalente, TB.FKIdUnidades_ALMA) AS FK_IdUnidades__ALMA,
        AVG(B.Costo) AS CostoUnitario,
        AVG(B.Costo) AS CostoPromedio
    FROM
        ALMA.TipoBien TB
        INNER JOIN ALMA.GrupoBien GB ON TB.FKIdGrupoBien_ALMA = GB.PKIdGrupoBien
        INNER JOIN ALMA.Unidades AU ON IIF(TB.Cantidad_Equivalente > 1, TB.FKIdUnidades_Equivalente, TB.FKIdUnidades_ALMA) = AU.PKIdUnidades
        LEFT JOIN ALMA.Bien B ON TB.PKIdTipoBien = B.FKIdTipoBien_ALMA AND B.Activo = 1
    WHERE
        TB.Activo = 1
        AND GB.Activo = 1
        AND AU.Activo = 1
    GROUP BY
        TB.PKIdTipoBien,
        TB.FKIdPartida_CONTA,
        GB.CLAVE_CUCOP,
        GB.CABM_ACT,
        GB.ClaveAN,
        TB.CodigoClave,
        TB.Descripcion,
        AU.Descripcion,
        IIF(TB.Cantidad_Equivalente > 1, TB.FKIdUnidades_Equivalente, TB.FKIdUnidades_ALMA)
)
SELECT
    E.PKIdTipoBien,
    E.FKIdPartida_CONTA,
    E.CUCOP,
    E.CABMS,
    E.CodigoClave,
    E.Descripcion,
    E.Existencias,
    E.Unidades,
    E.FK_IdAnio__SIS,
    CASE
        WHEN E.Existencias < TB.ExistenciaMinima THEN 'No alcanza el m�nimo de unidades'
        WHEN E.Existencias > TB.ExistenciaMaxima THEN 'Excede el M�ximo de Unidades'
        ELSE 'OK'
    END AS Message,
    E.FK_IdUnidades__ALMA,
    ISNULL(E.CostoUnitario, 0) AS CostoUnitario,
    ISNULL(E.CostoPromedio, 0) AS CostoPromedio
FROM
    Existencias E
    INNER JOIN ALMA.TipoBien TB ON E.PKIdTipoBien = TB.PKIdTipoBien
WHERE
    TB.Activo = 1
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [ALMA].[Vw_GrupoBien] AS
SELECT 
    gb.PKIdGrupoBien,
    gb.FKIdFamilia_ALMA,
    gb.Descripcion,
    gb.Clave,
    gb.ClaveAN,
    gb.CABM_ACT,
    gb.CLAVE_CUCOP,
    gb.MEDIDA,
    gb.Activo,
    gb.FechaCreacion,
    gb.UsuarioCreacion,
    gb.FechaModificacion,
    gb.UsuarioModificacion,
    -- FK resuelta: Familia
    f.Descripcion AS FamiliaDescripcion,
    f.Clave AS FamiliaClave,
    CONCAT_WS(' / ', gb.ClaveAN, gb.CABM_ACT, gb.Descripcion) AS CatalogoCAMBS
FROM ALMA.GrupoBien gb
LEFT JOIN ALMA.Familia f ON gb.FKIdFamilia_ALMA = f.PKIdFamilia AND f.Activo = 1
WHERE gb.Activo = 1;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [ALMA].[VW_PeriodoConteo]
AS
SELECT
    pc.[PKIdPeriodoConteo],
    pc.[CodigoPeriodo],
    pc.[Nombre],
    pc.[Descripcion],
    pc.[FechaInicio],
    pc.[FechaFin],
    pc.[FechaCierre],
    pc.[MaximoConteosPorArticulo],
    pc.[RequiereAprobacionSupervisor],
    pc.[TotalArticulos],
    pc.[ArticulosConcluidos],
    pc.[ArticulosConDiferencia],
    pc.[Activo],
    pc.[FechaCreacion],
    pc.[UsuarioCreacion],
    pc.[FechaModificacion],
    pc.[UsuarioModificacion],

    -- Sucursal
    s.[PKIdSucursal]            AS [IdSucursal],
    s.[Nombre]                  AS [Sucursal],

    -- Tipo de conteo
    tc.[PKIdTipoConteo]         AS [IdTipoConteo],
    tc.[Nombre]                 AS [TipoConteo],
    tc.[Descripcion]            AS [DescripcionTipoConteo],

    -- Estatus del periodo
    ep.[PKIdEstatusPeriodo]     AS [IdEstatusPeriodo],
    ep.[Nombre]                 AS [EstatusPeriodo],
    ep.[Descripcion]            AS [DescripcionEstatusPeriodo],

    -- Responsable
    r.[PkIdUsuario]             AS [IdResponsable],
    ISNULL(pr.[Nombre], '') + ' ' + ISNULL(pr.[Paterno], '') + ' ' + ISNULL(pr.[Materno], '') AS [Responsable],
    -- Supervisor
    sup.[PkIdUsuario]           AS [IdSupervisor],
    ISNULL(psup.[Nombre], '') + ' ' + ISNULL(psup.[Paterno], '') + ' ' + ISNULL(psup.[Materno], '') AS [Supervisor]

FROM [ALMA].[PeriodoConteo] pc
LEFT JOIN [SIS].[Sucursal] s
    ON pc.[FKIdSucursal_SIS] = s.[PKIdSucursal]
LEFT JOIN [ALMA].[TipoConteo] tc
    ON pc.[FKIdTipoConteo_ALMA] = tc.[PKIdTipoConteo]
LEFT JOIN [ALMA].[EstatusPeriodo] ep
    ON pc.[FKIdEstatus_ALMA] = ep.[PKIdEstatusPeriodo]
LEFT JOIN [SIS].[Usuario] r
    ON pc.[FKIdResponsable_SIS] = r.[PkIdUsuario]
LEFT JOIN [SIS].[Usuario] sup
    ON pc.[FKIdSupervisor_SIS] = sup.[PkIdUsuario]
LEFT JOIN [NOM].[Persona] pr
    ON r.[FKIdPersona_NOM] = pr.[PKIdPersona]
LEFT JOIN [NOM].[Persona] psup
    ON sup.[FKIdPersona_NOM] = psup.[PKIdPersona];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [ALMA].[Vw_TipoBien]
AS
SELECT 
    tb.PKIdTipoBien,
    tb.FKIdGrupoBien_ALMA,
    tb.FKIdNivel_ALMA,
    tb.FKIdPartida_CONTA,
    tb.FKIdCuentaContable_CONTA,
    tb.FKIdUnidades_ALMA,
    tb.FKIdLocalizacion_ALMA,
    tb.FKIdUnidades_Equivalente,
    tb.CodigoClave,
    CONCAT(tb.Descripcion, ' ', tb.CodigoClave) AS TipoBienDescripcion,
    tb.DepreciacionAnual,
    tb.Consecutivo,
    tb.CABMS,
    tb.Identificador,
    tb.ExistenciaMinima,
    tb.ExistenciaMaxima,
    tb.TiempoVida,
    tb.Pk_IdTratadoInt,
    tb.Cuota,
    tb.ProveeduriaNac,
    tb.CatalogoBasico,
    tb.CUCOP_PLUS,
    tb.Cantidad_Equivalente,
    tb.Activo,
    tb.FechaCreacion,
    tb.UsuarioCreacion,
    tb.FechaModificacion,
    tb.UsuarioModificacion,
    -- GrupoBien y Familia (activos)
    gb.Descripcion AS GrupoBienDescripcion,
    gb.Clave AS GrupoBienClave,
    gb.ClaveAN,
    gb.CABM_ACT,
    gb.CLAVE_CUCOP,
    gb.MEDIDA AS GrupoBienMedida,
    f.Descripcion AS FamiliaDescripcion,
    f.Clave AS FamiliaClave,
    -- Nivel (activo)
    n.Nivel,
    n.Descripcion AS NivelDescripcion,
    -- Partida (activo)
    p.Clave AS PartidaClave,
    p.Descripcion AS PartidaDescripcion,
    -- CuentaContable (activo)
    cc.Cta_Coi,
    cc.Desc_Coi AS CuentaDescripcion,
    cc.TipoCuenta,
    -- Unidades (activo)
    u.Descripcion AS UnidadMedida,
    -- Unidades Equivalente (activo)
    ue.Descripcion AS UnidadEquivalenteMedida
FROM ALMA.TipoBien tb
LEFT JOIN ALMA.GrupoBien gb ON tb.FKIdGrupoBien_ALMA = gb.PKIdGrupoBien AND gb.Activo = 1
LEFT JOIN ALMA.Familia f ON gb.FKIdFamilia_ALMA = f.PKIdFamilia AND f.Activo = 1
LEFT JOIN ALMA.Nivel n ON tb.FKIdNivel_ALMA = n.PKIdNivel AND n.Activo = 1
LEFT JOIN CONTA.Partida p ON tb.FKIdPartida_CONTA = p.PKIdPartida AND p.Activo = 1
LEFT JOIN CONTA.CuentaContable cc ON tb.FKIdCuentaContable_CONTA = cc.PKIdCuentaContable AND cc.Activo = 1
LEFT JOIN ALMA.Unidades u ON tb.FKIdUnidades_ALMA = u.PKIdUnidades AND u.Activo = 1
LEFT JOIN ALMA.Unidades ue ON tb.FKIdUnidades_Equivalente = ue.PKIdUnidades AND ue.Activo = 1
WHERE tb.Activo = 1;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [ALMA].[Vw_TipoBienConteo]
AS
SELECT 
    -- ========================
    -- Campos originales de la vista (se mantienen)
    -- ========================
    tb.PKIdTipoBien,
    tb.CodigoClave AS CodigoArticulo,
    tb.Descripcion AS DescripcionArticulo,
    tb.Activo,
    
    -- Unidades
    u.Descripcion AS UnidadMedida,
    ue.Descripcion AS UnidadEquivalente,
    tb.Cantidad_Equivalente,
    
    -- Clasificaci�n
    f.Descripcion AS Familia,
    gb.Descripcion AS GrupoBien,
    n.Descripcion AS Nivel,
    
    -- Partida y cuenta contable
    p.Clave AS PartidaClave,
    p.Descripcion AS PartidaDescripcion,
    cc.Cuenta + '.' + cc.SubCuenta + '.' + cc.SubSubCuenta + '.' + cc.SubSubSubCuenta + '.' + cc.SubSubSubSubCuenta AS CuentaCompleta,
    cc.Descripcion AS CuentaDescripcion,
    tc.Descripcion AS TipoCuenta,
    
    -- Par�metros del art�culo
    tb.ExistenciaMinima,
    tb.ExistenciaMaxima,
    tb.CABMS,
    tb.CUCOP_PLUS,
    tb.DepreciacionAnual,
    tb.TiempoVida,
    tb.ProveeduriaNac,
    tb.CatalogoBasico,
    
    -- Auditor�a
    tb.FechaCreacion,
    tb.UsuarioCreacion,
    tb.FechaModificacion,
    tb.UsuarioModificacion,

    -- ========================
    -- NUEVOS CAMPOS requeridos por el CRUD (solo los que no exist�an)
    -- ========================
    -- IDs de las relaciones (necesarios para combos y FK)
    tb.FKIdGrupoBien_ALMA AS FkIdGrupoBienSicop,
    tb.FKIdNivel_ALMA AS FkIdNivel,
    tb.FKIdPartida_CONTA AS FkIdPartidaSis,
    tb.FKIdCuentaContable_CONTA AS FkIdCuentaContable,
    tb.FKIdUnidades_ALMA AS FkIdUnidadesAlma,
    tb.FKIdUnidades_Equivalente AS FkIdUnidadesEquivalente,
    
    -- Otros campos �tiles que no estaban en la vista original
    tb.Consecutivo,
    tb.Identificador

FROM 
    ALMA.TipoBien tb
    INNER JOIN ALMA.GrupoBien gb ON tb.FKIdGrupoBien_ALMA = gb.PKIdGrupoBien
    INNER JOIN ALMA.Familia f ON gb.FKIdFamilia_ALMA = f.PKIdFamilia
    INNER JOIN ALMA.Nivel n ON tb.FKIdNivel_ALMA = n.PKIdNivel
    INNER JOIN CONTA.Partida p ON tb.FKIdPartida_CONTA = p.PKIdPartida
    LEFT JOIN CONTA.CuentaContable cc ON tb.FKIdCuentaContable_CONTA = cc.PKIdCuentaContable
    LEFT JOIN CONTA.TipoCuenta tc ON cc.FKIdTipoCuenta_CONTA = tc.PKIdTipoCuenta
    INNER JOIN ALMA.Unidades u ON tb.FKIdUnidades_ALMA = u.PKIdUnidades
    LEFT JOIN ALMA.Unidades ue ON tb.FKIdUnidades_Equivalente = ue.PKIdUnidades
WHERE 
    tb.Activo = 1;
GO

-- =============================================
-- ORCO
-- =============================================

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [ORCO].[Vw_Fraccion] AS
SELECT 
    f.PKIdFraccion,
    f.FKIdArticulo_ORCO,
    f.Clave,
    f.Descripcion,
    f.Activo,
    f.FechaCreacion,
    f.UsuarioCreacion,
    f.FechaModificacion,
    f.UsuarioModificacion,
    a.Descripcion AS ArticuloDescripcion,
    a.Clave AS ArticuloClave,
    CONCAT(a.Clave, ' - ', a.Descripcion) AS ArticuloClaveNombre
FROM ORCO.Fraccion f
LEFT JOIN ORCO.Articulo a ON f.FKIdArticulo_ORCO = a.PKIdArticulo AND a.Activo = 1
WHERE f.Activo = 1;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [ORCO].[Vw_PAAAS]
AS
SELECT 
    p.PKIdPAAAS,
    p.FKIdEmpresa_SIS,
    p.FKIdAnio_SIS,
    p.FKIdArea_SIS,
    p.FKIdPersona_NOM,
    p.Descripcion,
    p.Observaciones,
    p.Fecha,
    p.FKIdProyecto_ORCO,
    p.FKIdPrograma_PRES,
    p.FKIdFuenteFinanciamiento_PRES,
    p.Activo,
    p.FechaCreacion,
    p.UsuarioCreacion,
    p.FechaModificacion,
    p.UsuarioModificacion,
    -- Resoluci�n de claves for�neas
    a.Clave AS AnioClave,
    a.Clave AS AnioDescripcion,
    area.Nombre AS AreaNombre,
    area.Clave AS AreaClave,
    per.Nombre AS ResponsableNombre,
    per.Paterno AS ResponsablePaterno,
    per.Materno AS ResponsableMaterno,
    CONCAT(per.Nombre, ' ', per.Paterno, ' ', COALESCE(per.Materno, '')) AS ResponsableCompleto,
    proy.Descripcion AS ProyectoDescripcion,
    prog.Clave AS ProgramaClave,
    prog.Descripcion AS ProgramaDescripcion,
    ff.Descripcion AS FuenteFinanciamientoDescripcion,
    ff.Clave AS FuenteFinanciamientoClave,
    -- Columna adicional para combos
    CONCAT('PAAAS ', p.PKIdPAAAS, ' - ', area.Nombre, ' (', a.Clave, ')') AS ClaveNombre
FROM ORCO.PAAAS p
LEFT JOIN SIS.Anio a ON p.FKIdAnio_SIS = a.PKIdAnio
LEFT JOIN SIS.Area area ON p.FKIdArea_SIS = area.PKIdArea AND area.Activo = 1
LEFT JOIN NOM.Persona per ON p.FKIdPersona_NOM = per.PKIdPersona AND per.Activo = 1
LEFT JOIN ORCO.Proyecto proy ON p.FKIdProyecto_ORCO = proy.PKIdProyecto AND proy.Activo = 1
LEFT JOIN PRES.Programa prog ON p.FKIdPrograma_PRES = prog.PKIdPrograma AND prog.Activo = 1
LEFT JOIN PRES.FuenteFinanciamiento ff ON p.FKIdFuenteFinanciamiento_PRES = ff.PKIdFuenteFinanciamiento AND ff.Activo = 1
WHERE p.Activo = 1;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [ORCO].[Vw_PAAASDetalle]
AS
SELECT 
    dp.PKIdPAAASDetalle,
    dp.FKIdEmpresa_SIS,
    dp.FKIdPAAASPartida_ORCO,
    dp.FKIdTipoBien_ALMA,
    dp.FKIdUnidades_ALMA,
    dp.Cantidad,
    dp.Observaciones,
    dp.LugarEntrega,
    dp.Activo,
    dp.FechaCreacion,
    dp.UsuarioCreacion,
    dp.FechaModificacion,
    dp.UsuarioModificacion,
    -- Resoluci�n de claves for�neas
    tb.Descripcion AS TipoBienDescripcion,
    tb.CodigoClave AS TipoBienCodigoClave,
    tb.CABMS,
    tb.Identificador,
    tb.ExistenciaMinima,
    tb.ExistenciaMaxima,
    u.Descripcion AS UnidadMedida,
    -- Datos de la partida y PAAAS
    pp.FKIdPAAAS_ORCO,
    pp.FKIdPartida_CONTA,
    part.Clave AS PartidaClave,
    part.Descripcion AS PartidaDescripcion,
    -- Columna combinada para mostrar el bien
    CONCAT(tb.CodigoClave, ' - ', tb.Descripcion) AS BienClaveNombre
FROM ORCO.PAAASDetalle dp
LEFT JOIN ALMA.TipoBien tb ON dp.FKIdTipoBien_ALMA = tb.PKIdTipoBien AND tb.Activo = 1
LEFT JOIN ALMA.Unidades u ON dp.FKIdUnidades_ALMA = u.PKIdUnidades AND u.Activo = 1
LEFT JOIN ORCO.PAAASPartida pp ON dp.FKIdPAAASPartida_ORCO = pp.PKIdPAAASPartida AND pp.Activo = 1
LEFT JOIN CONTA.Partida part ON pp.FKIdPartida_CONTA = part.PKIdPartida AND part.Activo = 1
WHERE dp.Activo = 1;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [ORCO].[Vw_PAAASPartida]
AS
SELECT 
    pp.PKIdPAAASPartida,
    pp.FKIdEmpresa_SIS,
    pp.FKIdPAAAS_ORCO,
    pp.FKIdPartida_CONTA,
    pp.Observaciones,
    pp.Activo,
    pp.FechaCreacion,
    pp.UsuarioCreacion,
    pp.FechaModificacion,
    pp.UsuarioModificacion,
    -- Resoluci�n de claves for�neas
    part.Clave AS PartidaClave,
    part.Descripcion AS PartidaDescripcion,
    -- Datos del PAAAS padre
    paaas.Descripcion AS PAAASDescripcion,
    -- Columna para combos
    CONCAT(part.Clave, ' - ', part.Descripcion) AS ClaveNombre
FROM ORCO.PAAASPartida pp
LEFT JOIN CONTA.Partida part ON pp.FKIdPartida_CONTA = part.PKIdPartida AND part.Activo = 1
LEFT JOIN ORCO.PAAAS paaas ON pp.FKIdPAAAS_ORCO = paaas.PKIdPAAAS AND paaas.Activo = 1
WHERE pp.Activo = 1;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [ORCO].[Vw_Requisicion]
AS
SELECT
    r.PKIdRequisicion,
    r.FKIdEmpresa_SIS,
    r.FKIdPersona_NOM,
    r.FKIdArea_SIS,
    r.Descripcion,
    r.Observaciones,
    r.FechaRequisicion,
    r.Servicio,
    r.FL_FOTO,
    r.FKIdProyecto_ORCO,
    r.FechaRequiereInicio,
    r.FechaRequiereFin,
    r.FKIdPrograma_PRES,
    r.Importe,
    r.FKIdJefeAlmacen_NOM,
    r.FKIdSuficiencia_PRES,
    r.FKIdSuperviso_NOM,
    r.FKIdAutorizo_NOM,
    r.FKIdPSolicita_NOM,
    r.FKIdPJefeAlmacen_NOM,
    r.FKIdPSuficiencia_NOM,
    r.FKIdPSuperviso_NOM,
    r.FKIdPAutorizo_NOM,
    r.FKIdFuenteFinanciamiento_PRES,
    r.FKIdAnio_SIS,
    r.FKIdTipoGasto_PRES,
    r.FKIdDigitoIdentificador_PRES,
    r.FKIdDestinoGasto_PRES,
    r.FKIdEgresoAutorizado_PRES,
    r.Oficio,
    r.FechaOficio,
    r.CompraDirecta,
    r.Activo,
    r.FechaCreacion,
    r.UsuarioCreacion,
    r.FechaModificacion,
    r.UsuarioModificacion,
    emp.Nombre AS EmpresaNombre,
    emp.RFC AS EmpresaRFC,
    a.Clave AS AnioClave,
    area.Nombre AS AreaNombre,
    area.Clave AS AreaClave,
    per.Nombre AS SolicitanteNombre,
    per.Paterno AS SolicitantePaterno,
    per.Materno AS SolicitanteMaterno,
    CONCAT(per.Nombre, ' ', per.Paterno, ' ', COALESCE(per.Materno, '')) AS SolicitanteCompleto,
    proy.Descripcion AS ProyectoDescripcion,
    prog.Clave AS ProgramaClave,
    prog.Descripcion AS ProgramaDescripcion,
    ff.Clave AS FuenteFinanciamientoClave,
    ff.Descripcion AS FuenteFinanciamientoDescripcion,
    tg.Clave AS TipoGastoClave,
    tg.Descripcion AS TipoGastoDescripcion,
    di.Clave AS DigitoIdentificadorClave,
    di.Descripcion AS DigitoIdentificadorDescripcion,
    dg.Clave AS DestinoGastoClave,
    dg.Descripcion AS DestinoGastoDescripcion,
    suf.Descripcion AS SuficienciaDescripcion,
    ea.Descripcion AS EgresoAutorizadoDescripcion,
    ea.Fecha AS EgresoAutorizadoFecha,
    jefe.Nombre AS JefeAlmacenNombre,
    jefe.Paterno AS JefeAlmacenPaterno,
    jefe.Materno AS JefeAlmacenMaterno,
    CONCAT(jefe.Nombre, ' ', jefe.Paterno, ' ', COALESCE(jefe.Materno, '')) AS JefeAlmacenCompleto,
    superviso.Nombre AS SupervisoNombre,
    superviso.Paterno AS SupervisoPaterno,
    superviso.Materno AS SupervisoMaterno,
    CONCAT(superviso.Nombre, ' ', superviso.Paterno, ' ', COALESCE(superviso.Materno, '')) AS SupervisoCompleto,
    autorizo.Nombre AS AutorizoNombre,
    autorizo.Paterno AS AutorizoPaterno,
    autorizo.Materno AS AutorizoMaterno,
    CONCAT(autorizo.Nombre, ' ', autorizo.Paterno, ' ', COALESCE(autorizo.Materno, '')) AS AutorizoCompleto,
    psolicita.Nombre AS PSolicitaNombre,
    psolicita.Paterno AS PSolicitaPaterno,
    psolicita.Materno AS PSolicitaMaterno,
    CONCAT(psolicita.Nombre, ' ', psolicita.Paterno, ' ', COALESCE(psolicita.Materno, '')) AS PSolicitaCompleto,
    pjefe.Nombre AS PJefeAlmacenNombre,
    pjefe.Paterno AS PJefeAlmacenPaterno,
    pjefe.Materno AS PJefeAlmacenMaterno,
    CONCAT(pjefe.Nombre, ' ', pjefe.Paterno, ' ', COALESCE(pjefe.Materno, '')) AS PJefeAlmacenCompleto,
    psuf.Nombre AS PSuficienciaNombre,
    psuf.Paterno AS PSuficienciaPaterno,
    psuf.Materno AS PSuficienciaMaterno,
    CONCAT(psuf.Nombre, ' ', psuf.Paterno, ' ', COALESCE(psuf.Materno, '')) AS PSuficienciaCompleto,
    psuperviso.Nombre AS PSupervisoNombre,
    psuperviso.Paterno AS PSupervisoPaterno,
    psuperviso.Materno AS PSupervisoMaterno,
    CONCAT(psuperviso.Nombre, ' ', psuperviso.Paterno, ' ', COALESCE(psuperviso.Materno, '')) AS PSupervisoCompleto,
    pautorizo.Nombre AS PAutorizoNombre,
    pautorizo.Paterno AS PAutorizoPaterno,
    pautorizo.Materno AS PAutorizoMaterno,
    CONCAT(pautorizo.Nombre, ' ', pautorizo.Paterno, ' ', COALESCE(pautorizo.Materno, '')) AS PAutorizoCompleto,
    CONCAT('REQ ', r.PKIdRequisicion, ' - ', r.Descripcion) AS ClaveNombre
FROM ORCO.Requisicion r
LEFT JOIN SIS.Empresa emp ON r.FKIdEmpresa_SIS = emp.PKIdEmpresa AND emp.Activo = 1
LEFT JOIN SIS.Anio a ON r.FKIdAnio_SIS = a.PKIdAnio AND a.Activo = 1
LEFT JOIN SIS.Area area ON r.FKIdArea_SIS = area.PKIdArea AND area.Activo = 1
LEFT JOIN NOM.Persona per ON r.FKIdPersona_NOM = per.PKIdPersona AND per.Activo = 1
LEFT JOIN ORCO.Proyecto proy ON r.FKIdProyecto_ORCO = proy.PKIdProyecto AND proy.Activo = 1
LEFT JOIN PRES.Programa prog ON r.FKIdPrograma_PRES = prog.PKIdPrograma AND prog.Activo = 1
LEFT JOIN PRES.FuenteFinanciamiento ff ON r.FKIdFuenteFinanciamiento_PRES = ff.PKIdFuenteFinanciamiento AND ff.Activo = 1
LEFT JOIN PRES.TipoGasto tg ON r.FKIdTipoGasto_PRES = tg.PKIdTipoGasto AND tg.Activo = 1
LEFT JOIN PRES.DigitoIdentificador di ON r.FKIdDigitoIdentificador_PRES = di.PKIdDigitoIdentificador AND di.Activo = 1
LEFT JOIN PRES.DestinoGasto dg ON r.FKIdDestinoGasto_PRES = dg.PKIdDestinoGasto AND dg.Activo = 1
LEFT JOIN PRES.Suficiencia suf ON r.FKIdSuficiencia_PRES = suf.PKIdSuficiencia AND suf.Activo = 1
LEFT JOIN PRES.EgresoAutorizado ea ON r.FKIdEgresoAutorizado_PRES = ea.PKIdEgresoAutorizado AND ea.Activo = 1
LEFT JOIN NOM.Persona jefe ON r.FKIdJefeAlmacen_NOM = jefe.PKIdPersona AND jefe.Activo = 1
LEFT JOIN NOM.Persona superviso ON r.FKIdSuperviso_NOM = superviso.PKIdPersona AND superviso.Activo = 1
LEFT JOIN NOM.Persona autorizo ON r.FKIdAutorizo_NOM = autorizo.PKIdPersona AND autorizo.Activo = 1
LEFT JOIN NOM.Persona psolicita ON r.FKIdPSolicita_NOM = psolicita.PKIdPersona AND psolicita.Activo = 1
LEFT JOIN NOM.Persona pjefe ON r.FKIdPJefeAlmacen_NOM = pjefe.PKIdPersona AND pjefe.Activo = 1
LEFT JOIN NOM.Persona psuf ON r.FKIdPSuficiencia_NOM = psuf.PKIdPersona AND psuf.Activo = 1
LEFT JOIN NOM.Persona psuperviso ON r.FKIdPSuperviso_NOM = psuperviso.PKIdPersona AND psuperviso.Activo = 1
LEFT JOIN NOM.Persona pautorizo ON r.FKIdPAutorizo_NOM = pautorizo.PKIdPersona AND pautorizo.Activo = 1
WHERE r.Activo = 1;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [ORCO].[Vw_RequisicionPartida]
AS
SELECT
    rp.PKIdRequisicionPartida,
    rp.FKIdEmpresa_SIS,
    rp.FKIdRequisicion_ORCO,
    rp.FKIdPartida_CONTA,
    rp.Monto,
    rp.Observaciones,
    rp.Activo,
    rp.FechaCreacion,
    rp.UsuarioCreacion,
    rp.FechaModificacion,
    rp.UsuarioModificacion,
    emp.Nombre AS EmpresaNombre,
    req.Descripcion AS RequisicionDescripcion,
    req.FechaRequisicion,
    req.Importe AS RequisicionImporte,
    part.Clave AS PartidaClave,
    part.Descripcion AS PartidaDescripcion,
    CONCAT(part.Clave, ' - ', part.Descripcion) AS ClaveNombre
FROM ORCO.RequisicionPartida rp
LEFT JOIN SIS.Empresa emp ON rp.FKIdEmpresa_SIS = emp.PKIdEmpresa AND emp.Activo = 1
LEFT JOIN ORCO.Requisicion req ON rp.FKIdRequisicion_ORCO = req.PKIdRequisicion AND req.Activo = 1
LEFT JOIN CONTA.Partida part ON rp.FKIdPartida_CONTA = part.PKIdPartida AND part.Activo = 1
WHERE rp.Activo = 1;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [ORCO].[Vw_DetalleRequisicion]
AS
SELECT
    dr.PKIdDetalleRequisicion,
    dr.FKIdEmpresa_SIS,
    dr.FKIdRequisicion_ORCO,
    dr.FKIdTipoBien_ALMA,
    dr.FKIdUnidades_ALMA,
    dr.Cantidad,
    dr.Observaciones,
    dr.Activo,
    dr.FechaCreacion,
    dr.UsuarioCreacion,
    dr.FechaModificacion,
    dr.UsuarioModificacion,
    emp.Nombre AS EmpresaNombre,
    req.Descripcion AS RequisicionDescripcion,
    req.FechaRequisicion,
    req.Servicio AS RequisicionServicio,
    tb.Descripcion AS TipoBienDescripcion,
    tb.CodigoClave AS TipoBienCodigoClave,
    tb.CABMS,
    tb.Identificador,
    tb.ExistenciaMinima,
    tb.ExistenciaMaxima,
    u.Descripcion AS UnidadMedida,
    CONCAT(tb.CodigoClave, ' - ', tb.Descripcion) AS BienClaveNombre
FROM ORCO.DetalleRequisicion dr
LEFT JOIN SIS.Empresa emp ON dr.FKIdEmpresa_SIS = emp.PKIdEmpresa AND emp.Activo = 1
LEFT JOIN ORCO.Requisicion req ON dr.FKIdRequisicion_ORCO = req.PKIdRequisicion AND req.Activo = 1
LEFT JOIN ALMA.TipoBien tb ON dr.FKIdTipoBien_ALMA = tb.PKIdTipoBien AND tb.Activo = 1
LEFT JOIN ALMA.Unidades u ON dr.FKIdUnidades_ALMA = u.PKIdUnidades AND u.Activo = 1
WHERE dr.Activo = 1;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [ORCO].[VW_ReporteBienesProgramaAnual] AS
WITH 
-- 1. Resumen de �reas solicitantes por bien
AreasPorBien AS (
    SELECT 
        dp.FKIdTipoBien_ALMA,
        COUNT(DISTINCT p.FKIdArea_SIS) AS TotalAreasSolicitantes
    FROM ORCO.PAAASDetalle dp
    INNER JOIN ORCO.PAAASPartida pp ON dp.FKIdPAAASPartida_ORCO = pp.PKIdPAAASPartida
    INNER JOIN ORCO.PAAAS p ON pp.FKIdPAAAS_ORCO = p.PKIdPAAAS
    WHERE dp.Activo = 1 AND pp.Activo = 1 AND p.Activo = 1
    GROUP BY dp.FKIdTipoBien_ALMA
),

-- 2. Cantidad total solicitada por bien
CantidadTotalPorBien AS (
    SELECT 
        FKIdTipoBien_ALMA,
        SUM(Cantidad) AS CantidadTotalSolicitada
    FROM ORCO.PAAASDetalle
    WHERE Activo = 1
    GROUP BY FKIdTipoBien_ALMA
),

-- 3. Resumen de cotizaciones por bien
CotizacionesPorBien AS (
    SELECT 
        emd.FKIdTipoBien_ALMA,
        COUNT(DISTINCT sc.FKIdProveedor_SIS) AS TotalProveedoresCotizaron,
        COUNT(cd.PKIdCotizacionDetalle) AS TotalCotizacionesRecibidas,
        MIN(cd.PrecioUnitario) AS PrecioMinimo,
        MAX(cd.PrecioUnitario) AS PrecioMaximo,
        AVG(CAST(cd.PrecioUnitario AS DECIMAL(20,4))) AS PrecioPromedio,
        MAX(cd.FechaRespuesta) AS UltimaCotizacion
    FROM ORCO.EstudioMercadoDetalle emd
    INNER JOIN ORCO.CotizacionDetalle cd ON emd.PKIdEstudioMercadoDetalle = cd.FKIdEstudioMercadoDetalle_ORCO
    INNER JOIN ORCO.SolicitudCotizacion sc ON cd.FKIdSolicitudCotizacion_ORCO = sc.PKIdSolicitudCotizacion
    WHERE emd.Activo = 1 AND cd.Activo = 1 AND sc.Activo = 1
    GROUP BY emd.FKIdTipoBien_ALMA
)

-- 4. Vista final consolidada
SELECT 
    tb.PKIdTipoBien,
    tb.Descripcion AS NombreBien,
    tb.CodigoClave AS ClaveBien,
    u.Descripcion AS UnidadMedida,
    
    -- Cantidad de �reas que lo solicitaron
    ISNULL(apb.TotalAreasSolicitantes, 0) AS TotalAreasSolicitantes,
    
    -- Cantidad total de bienes solicitada
    ISNULL(cb.CantidadTotalSolicitada, 0) AS CantidadTotalSolicitada,
    
    -- Estad�sticas de cotizaciones
    ISNULL(cpb.TotalProveedoresCotizaron, 0) AS ProveedoresQueCotizaron,
    ISNULL(cpb.TotalCotizacionesRecibidas, 0) AS TotalCotizacionesRecibidas,
    
    -- Precios
    cpb.PrecioMinimo,
    cpb.PrecioMaximo,
    cpb.PrecioPromedio,
    
    -- Fecha de �ltima actualizaci�n
    cpb.UltimaCotizacion,
    
    -- Fecha de �ltima modificaci�n del registro del bien
    tb.FechaModificacion AS UltimaActualizacionBien,
    
    -- Indicadores de estado
    CASE 
        WHEN cpb.TotalCotizacionesRecibidas > 0 THEN 'Cotizado'
        WHEN cb.CantidadTotalSolicitada > 0 THEN 'Solicitado sin cotizar'
        ELSE 'Sin actividad'
    END AS Estatus

FROM ALMA.TipoBien tb
LEFT JOIN ALMA.Unidades u ON tb.FKIdUnidades_ALMA = u.PKIdUnidades
LEFT JOIN AreasPorBien apb ON tb.PKIdTipoBien = apb.FKIdTipoBien_ALMA
LEFT JOIN CantidadTotalPorBien cb ON tb.PKIdTipoBien = cb.FKIdTipoBien_ALMA
LEFT JOIN CotizacionesPorBien cpb ON tb.PKIdTipoBien = cpb.FKIdTipoBien_ALMA
WHERE tb.Activo = 1;
GO

-- =============================================
-- PRES
-- =============================================

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [PRES].[VwPrograma]
AS
SELECT
    p.PKIdPrograma,
    p.Clave,
    p.Descripcion,
    p.Objetivo,
    CONCAT(p.Clave, ' - ', ISNULL(p.Descripcion, '')) AS ClaveNombre,

    p.FKIdUR_PRES,
    ur.Clave AS URClave,
    ur.Descripcion AS URDescripcion,
    CASE WHEN ur.PKIdUR IS NULL THEN NULL ELSE CONCAT(ur.Clave, ' - ', ur.Descripcion) END AS URClaveNombre,

    p.FKIdGF_PRES,
    gf.Clave AS GFClave,
    gf.Descripcion AS GFDescripcion,
    CASE WHEN gf.PKIdGF IS NULL THEN NULL ELSE CONCAT(gf.Clave, ' - ', gf.Descripcion) END AS GFClaveNombre,

    p.FKIdFN_PRES,
    fn.Clave AS FNClave,
    fn.Descripcion AS FNDescripcion,
    CASE WHEN fn.PKIdFN IS NULL THEN NULL ELSE CONCAT(fn.Clave, ' - ', fn.Descripcion) END AS FNClaveNombre,

    p.FKIdSF_PRES,
    sf.Clave AS SFClave,
    sf.Descripcion AS SFDescripcion,
    CASE WHEN sf.PKIdSF IS NULL THEN NULL ELSE CONCAT(sf.Clave, ' - ', sf.Descripcion) END AS SFClaveNombre,

    p.FKIdActividadInstitucional_SIS,
    ai.Clave AS ActividadInstitucionalClave,
    ai.Descripcion AS ActividadInstitucionalDescripcion,
    CASE WHEN ai.PKIdActividadInstitucional IS NULL THEN NULL ELSE CONCAT(ai.Clave, ' - ', ai.Descripcion) END AS ActividadInstitucionalClaveNombre,

    p.FKIdEje_PRES,
    eje.Clave AS EjeClave,
    eje.Descripcion AS EjeDescripcion,
    CASE WHEN eje.PKIdEje IS NULL THEN NULL ELSE CONCAT(eje.Clave, ' - ', eje.Descripcion) END AS EjeClaveNombre,

    p.FKIdSubEje_PRES,
    se.Clave AS SubEjeClave,
    se.Descripcion AS SubEjeDescripcion,
    CASE WHEN se.PKIdSubEje IS NULL THEN NULL ELSE CONCAT(se.Clave, ' - ', se.Descripcion) END AS SubEjeClaveNombre,

    p.FKIdSubSubEje_PRES,
    sse.Clave AS SubSubEjeClave,
    sse.Descripcion AS SubSubEjeDescripcion,
    CASE WHEN sse.PKIdSubSubEje IS NULL THEN NULL ELSE CONCAT(sse.Clave, ' - ', sse.Descripcion) END AS SubSubEjeClaveNombre,

    p.FKIdFinalidad_PRES,
    fin.Clave AS FinalidadClave,
    fin.Descripcion AS FinalidadDescripcion,
    CASE WHEN fin.PKIdFinalidad IS NULL THEN NULL ELSE CONCAT(fin.Clave, ' - ', fin.Descripcion) END AS FinalidadClaveNombre,

    p.FKIdVertienteGasto_PRES,
    vg.Clave AS VertienteGastoClave,
    vg.Descripcion AS VertienteGastoDescripcion,
    CASE WHEN vg.PKIdVertienteGasto IS NULL THEN NULL ELSE CONCAT(vg.Clave, ' - ', vg.Descripcion) END AS VertienteGastoClaveNombre,

    p.FKIdResultado_PRES,
    res.Clave AS ResultadoClave,
    res.Descripcion AS ResultadoDescripcion,
    CASE WHEN res.PKIdResultado IS NULL THEN NULL ELSE CONCAT(res.Clave, ' - ', res.Descripcion) END AS ResultadoClaveNombre,

    p.FKIdSubresultado_PRES,
    subres.Clave AS SubresultadoClave,
    subres.Descripcion AS SubresultadoDescripcion,
    CASE WHEN subres.PKIdSubresultado IS NULL THEN NULL ELSE CONCAT(subres.Clave, ' - ', subres.Descripcion) END AS SubresultadoClaveNombre,

    p.FKIdAnio_SIS,
    anio.Clave AS AnioClave,

    p.FKIdSector_PRES,
    sec.Clave AS SectorClave,
    sec.Descripcion AS SectorDescripcion,
    CASE WHEN sec.PKIdSector IS NULL THEN NULL ELSE CONCAT(sec.Clave, ' - ', sec.Descripcion) END AS SectorClaveNombre,

    p.FKIdSubSector_PRES,
    subsec.Clave AS SubSectorClave,
    subsec.Descripcion AS SubSectorDescripcion,
    CASE WHEN subsec.PKIdSubSector IS NULL THEN NULL ELSE CONCAT(subsec.Clave, ' - ', subsec.Descripcion) END AS SubSectorClaveNombre,

    p.FKIdTipoRecurso_PRES,
    tr.Clave AS TipoRecursoClave,
    tr.Descripcion AS TipoRecursoDescripcion,
    CASE WHEN tr.PKIdTipoRecurso IS NULL THEN NULL ELSE CONCAT(tr.Clave, ' - ', tr.Descripcion) END AS TipoRecursoClaveNombre,

    p.FKIdFuenteFinanciamiento_PRES,
    ff.Clave AS FuenteFinanciamientoClave,
    ff.Descripcion AS FuenteFinanciamientoDescripcion,
    ff.FF,
    ff.FG,
    ff.FE,
    ff.AD,
    ff.ORI,
    CASE WHEN ff.PKIdFuenteFinanciamiento IS NULL THEN NULL ELSE CONCAT(ff.Clave, ' - ', ff.Descripcion) END AS FuenteFinanciamientoClaveNombre,

    p.FKIdPP_PRES,
    pp.Clave AS PPClave,
    pp.Descripcion AS PPDescripcion,
    CASE WHEN pp.PKIdPP IS NULL THEN NULL ELSE CONCAT(pp.Clave, ' - ', pp.Descripcion) END AS PPClaveNombre,

    p.Activo,
    p.FechaCreacion,
    p.UsuarioCreacion,
    p.FechaModificacion,
    p.UsuarioModificacion
FROM PRES.Programa p
LEFT JOIN PRES.UR ur ON p.FKIdUR_PRES = ur.PKIdUR AND ur.Activo = 1
LEFT JOIN PRES.GF gf ON p.FKIdGF_PRES = gf.PKIdGF AND gf.Activo = 1
LEFT JOIN PRES.FN fn ON p.FKIdFN_PRES = fn.PKIdFN AND fn.Activo = 1
LEFT JOIN PRES.SF sf ON p.FKIdSF_PRES = sf.PKIdSF AND sf.Activo = 1
LEFT JOIN SIS.ActividadInstitucional ai ON p.FKIdActividadInstitucional_SIS = ai.PKIdActividadInstitucional AND ai.Activo = 1
LEFT JOIN PRES.Eje eje ON p.FKIdEje_PRES = eje.PKIdEje AND eje.Activo = 1
LEFT JOIN PRES.SubEje se ON p.FKIdSubEje_PRES = se.PKIdSubEje AND se.Activo = 1
LEFT JOIN PRES.SubSubEje sse ON p.FKIdSubSubEje_PRES = sse.PKIdSubSubEje AND sse.Activo = 1
LEFT JOIN PRES.Finalidad fin ON p.FKIdFinalidad_PRES = fin.PKIdFinalidad AND fin.Activo = 1
LEFT JOIN PRES.VertienteGasto vg ON p.FKIdVertienteGasto_PRES = vg.PKIdVertienteGasto AND vg.Activo = 1
LEFT JOIN PRES.Resultado res ON p.FKIdResultado_PRES = res.PKIdResultado AND res.Activo = 1
LEFT JOIN PRES.Subresultado subres ON p.FKIdSubresultado_PRES = subres.PKIdSubresultado AND subres.Activo = 1
LEFT JOIN SIS.Anio anio ON p.FKIdAnio_SIS = anio.PKIdAnio AND anio.Activo = 1
LEFT JOIN PRES.Sector sec ON p.FKIdSector_PRES = sec.PKIdSector AND sec.Activo = 1
LEFT JOIN PRES.SubSector subsec ON p.FKIdSubSector_PRES = subsec.PKIdSubSector AND subsec.Activo = 1
LEFT JOIN PRES.TipoRecurso tr ON p.FKIdTipoRecurso_PRES = tr.PKIdTipoRecurso AND tr.Activo = 1
LEFT JOIN PRES.FuenteFinanciamiento ff ON p.FKIdFuenteFinanciamiento_PRES = ff.PKIdFuenteFinanciamiento AND ff.Activo = 1
LEFT JOIN PRES.PP pp ON p.FKIdPP_PRES = pp.PKIdPP AND pp.Activo = 1
WHERE p.Activo = 1;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [PRES].[Vw_Programa]
AS
SELECT *
FROM [PRES].[VwPrograma];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [PRES].[Vw_SubFuncion]
AS
SELECT 
    sf.PKIdSF,
    sf.Clave AS SubFuncionClave,
    sf.Descripcion AS SubFuncionDescripcion,
    sf.FKIdFN_PRES,
    sf.Activo,
    -- Datos de la Funci�n padre
    fn.Clave AS FuncionClave,
    fn.Descripcion AS FuncionDescripcion,
    -- Opcional: concatenaci�n �til para combos
    CAST(sf.Clave AS NVARCHAR(10)) + ' - ' + sf.Descripcion AS SubFuncionClaveNombre,
    CAST(fn.Clave AS NVARCHAR(10)) + ' - ' + fn.Descripcion AS FuncionClaveNombre
FROM PRES.SF sf
LEFT JOIN PRES.FN fn ON sf.FKIdFN_PRES = fn.PKIdFN AND fn.Activo = 1
WHERE sf.Activo = 1;
GO

-- =============================================
-- SIS
-- =============================================

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [SIS].[Vw_Area] AS
SELECT 
    a.PKIdArea,
    a.FKIdArea_SIS,
    a.Clave,
    a.Nombre,
    a.UltimoInv,
    a.Activo,
    a.FechaCreacion,
    a.UsuarioCreacion,
    a.FechaModificacion,
    a.UsuarioModificacion,
    a_padre.Nombre AS AreaPadreNombre,
    a_padre.Clave AS AreaPadreClave
FROM SIS.Area a
LEFT JOIN SIS.Area a_padre ON a.FKIdArea_SIS = a_padre.PKIdArea AND a_padre.Activo = 1
WHERE a.Activo = 1;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [SIS].[Vw_Concepto] AS
SELECT 
    c.PKIdConcepto,
    c.FKIdCapitulo_SIS,
    c.Clave,
    c.Descripcion,
    c.Activo,
    c.FechaCreacion,
    c.UsuarioCreacion,
    c.FechaModificacion,
    c.UsuarioModificacion,
    cap.Descripcion AS CapituloDescripcion,
    cap.Clave AS CapituloClave
FROM SIS.Concepto c
LEFT JOIN SIS.Capitulo cap ON c.FKIdCapitulo_SIS = cap.PKIdCapitulo AND cap.Activo = 1
WHERE c.Activo = 1;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [SIS].[VW_EmpresaDepartamanto]
AS
SELECT E.PKIdEmpresa,
	   E.Nombre AS EmpresaNombre,
	   E.RFC,
	   D.PKIdDepartamento,
	   D.Nombre AS DepartamentoNombre,
	   D.Activo AS DepartamentoActivo,
	   E.Activo AS EmpresaActivo,
      E.FechaCreacion,E.UsuarioCreacion,E.FechaModificacion,E.UsuarioModificacion
FROM [SIS].[Empresa] E WITH (NOLOCK)
INNER JOIN [SIS].[Departamento] D WITH (NOLOCK) ON E.PKIdEmpresa = D.FKIdEmpresa_SIS
WHERE E.Activo = 1 AND D.Activo = 1 ;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [SIS].[VW_EstadoEmpresa]
AS
SELECT 
    -- Campos de Empresa
    EM.PKIdEmpresa,
    EM.Nombre AS EmpresaNombre,
    EM.RFC,
    EM.RazonSocial,
    EM.Giro,
    EM.FKIdMonedaBase_SIS,
    EM.FKIdIdiomaPreferido_SIS,
    EM.Logo,
    EM.Activo AS EmpresaActivo,
    EM.FechaCreacion AS EmpresaFechaCreacion,
    EM.UsuarioCreacion AS EmpresaUsuarioCreacion,
    EM.FechaModificacion AS EmpresaFechaModificacion,
    EM.UsuarioModificacion AS EmpresaUsuarioModificacion,

    -- Campos de Estado
    E.PKIdEstado,
    E.FKIdPais_SIS,
    E.Nombre AS EstadoNombre,
    E.CodigoEstado,
    E.Activo AS EstadoActivo,

    -- Campos de la relaci�n (EmpresaEstado)
    EE.FechaApertura,
    EE.EsOficinaPrincipal,
    EE.Activo AS RelacionActiva

FROM SIS.Empresa EM
INNER JOIN SIS.EmpresaEstado EE ON EM.PKIdEmpresa = EE.FKIdEmpresa_SIS
INNER JOIN SIS.Estados E ON EE.FKIdEstado_SIS = E.PKIdEstado
WHERE EM.Activo = 1
  AND E.Activo = 1
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [SIS].[vw_Menu] AS
WITH MenuJerarquico AS (
    SELECT 
        m.PKIdMenu,
        m.Nombre,
        m.Tipo,
        -- Descripci�n del tipo
        CASE m.Tipo
            WHEN 1 THEN 'Contenedor (tiene submen�s)'
            WHEN 2 THEN 'Item final'
            ELSE 'Desconocido'
        END AS TipoDescripcion,
        m.FKIdMenu_SIS,
        -- Nombre del men� padre
        p.Nombre AS NombreMenuPadre,
        -- Tipo del men� padre
        p.Tipo AS TipoMenuPadre,
        CASE p.Tipo
            WHEN 1 THEN 'Contenedor'
            WHEN 2 THEN 'Item final'
            ELSE 'Desconocido'
        END AS TipoMenuPadreDescripcion,
        m.LegacyName,
        m.Ruta,
        m.ImageUrl,
        m.Lenguaje,
        m.Orden,
        m.Activo,
        -- Estado del men�
        CASE m.Activo
            WHEN 1 THEN 'Activo'
            ELSE 'Inactivo'
        END AS Estado,
        m.CreatedByOperatorId,
        m.CreatedDateTime,
        m.ModifiedByOperatorId,
        m.ModifiedDateTime,
        -- Nivel jer�rquico
        CASE 
            WHEN m.FKIdMenu_SIS IS NULL THEN 0
            ELSE 1
        END AS NivelJerarquico,
        -- Ruta completa del men� (para breadcrumbs)
        CASE 
            WHEN m.FKIdMenu_SIS IS NOT NULL AND p.Nombre IS NOT NULL 
                THEN p.Nombre + ' > ' + m.Nombre
            ELSE m.Nombre
        END AS RutaCompleta,
        -- Indicador si tiene submen�s (solo aplica para Tipo=1)
        CASE 
            WHEN m.Tipo = 1 AND EXISTS (SELECT 1 FROM SIS.Menu h WHERE h.FKIdMenu_SIS = m.PKIdMenu) 
            THEN 1 
            ELSE 0 
        END AS TieneSubmenus,
        -- Validaci�n de consistencia
        CASE 
            WHEN m.Tipo = 2 AND EXISTS (SELECT 1 FROM SIS.Menu h WHERE h.FKIdMenu_SIS = m.PKIdMenu) 
            THEN 'INCONSISTENCIA: Item final tiene submen�s'
            WHEN m.Tipo = 1 AND m.Ruta IS NOT NULL AND EXISTS (SELECT 1 FROM SIS.Menu h WHERE h.FKIdMenu_SIS = m.PKIdMenu) 
            THEN 'INCONSISTENCIA: Contenedor con ruta y submen�s'
            ELSE 'OK'
        END AS ValidacionEstructura
       
    FROM SIS.Menu m
    LEFT JOIN SIS.Menu p ON m.FKIdMenu_SIS = p.PKIdMenu
)
SELECT 
    PKIdMenu,
    Nombre,
    Tipo,
    TipoDescripcion,
    FKIdMenu_SIS,
    NombreMenuPadre,
    TipoMenuPadre,
    TipoMenuPadreDescripcion,
    LegacyName,
    Ruta,
    ImageUrl,
    Lenguaje,
    Orden,
    Activo,
    Estado,
    CreatedByOperatorId,
    CreatedDateTime,
    ModifiedByOperatorId,
    ModifiedDateTime,
    NivelJerarquico,
    RutaCompleta,
    TieneSubmenus,
    ValidacionEstructura
    
FROM MenuJerarquico m;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [SIS].[Vw_Proveedor] AS
SELECT 
    prov.PKIdProveedor,
    prov.FkIdTipoProveedor_SIS,
    prov.FKIdEstatusProveedor_SIS,
    prov.FKIdCuentaContable_SIS,
    prov.FKIdMunicipio_SIS,
    prov.FKIdEstado_SIS,
    prov.FKIdPais_SIS,
    prov.Nombre,
    prov.RFC,
    prov.Clave,
    prov.Activo,
    prov.FechaCreacion,
    prov.UsuarioCreacion,
    prov.FechaModificacion,
    prov.UsuarioModificacion,
    tp.Descripcion AS TipoProveedorDesc,
    ep.Descripcion AS EstatusProveedorDesc,
    cc.Cta_Coi AS CuentaContableClave,
    m.Nombre AS MunicipioNombre,
    e.Nombre AS EstadoNombre,
    pa.Nombre AS PaisNombre
FROM SIS.Proveedor prov
LEFT JOIN SIS.TipoProveedor tp ON prov.FkIdTipoProveedor_SIS = tp.PkIdTipoProveedor AND tp.Activo = 1
LEFT JOIN SIS.EstatusProveedor ep ON prov.FKIdEstatusProveedor_SIS = ep.PKIdEstatusProveedor AND ep.Activo = 1
LEFT JOIN CONTA.CuentaContable cc ON prov.FKIdCuentaContable_SIS = cc.PKIdCuentaContable AND cc.Activo = 1
LEFT JOIN SIS.Municipios m ON prov.FKIdMunicipio_SIS = m.PKIdMunicipio AND m.Activo = 1
LEFT JOIN SIS.Estados e ON prov.FKIdEstado_SIS = e.PKIdEstado AND e.Activo = 1
LEFT JOIN SIS.Paises pa ON prov.FKIdPais_SIS = pa.PKIdPais AND pa.Activo = 1
WHERE prov.Activo = 1;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [SIS].[VW_SucursalEmpresaEstado]
AS
SELECT 
    s.PKIdSucursal,
    s.FKIdEmpresa_SIS,
    s.FKIdEstado_SIS,
    s.Nombre,
    s.CodigoSucursal,
    s.Alias,
    s.FKIdTipoSucursal,
    s.FKIdMonedaLocal_SIS,
    s.Direccion,
    s.Colonia,
    s.Ciudad,
    s.CodigoPostal,
    s.TelefonoPrincipal,
    s.TelefonoSecundario,
    s.Email,
    s.HorarioApertura,
    s.HorarioCierre,
    s.EsMatriz,
    s.EsActiva,
    s.Latitud,
    s.Longitud,
    -- Informaci�n adicional de la empresa
    e.Nombre AS NombreEmpresa,
    e.RFC,
    -- Informaci�n del estado
    est.Nombre AS NombreEstado,
    est.CodigoEstado,
    p.Nombre AS NombrePais,
    E.Activo,
    E.FechaCreacion,E.UsuarioCreacion,E.FechaModificacion,E.UsuarioModificacion
FROM [SIS].Sucursal s WITH (NOLOCK)
INNER JOIN [SIS].Empresa e WITH (NOLOCK) 
    ON s.FKIdEmpresa_SIS = e.PKIdEmpresa 
    AND e.Activo = 1
INNER JOIN [SIS].Estados est WITH (NOLOCK) 
    ON s.FKIdEstado_SIS = est.PKIdEstado 
    AND est.Activo = 1
INNER JOIN [SIS].Paises p WITH (NOLOCK) 
    ON est.FKIdPais_SIS = p.PKIdPais 
    AND p.Activo = 1
WHERE s.Activo = 1;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [SIS].[VW_UsuarioEmpresa]
AS
WITH SucursalesResumen AS (
    -- Acceso directo por UsuarioSucursal
    SELECT 
        us.FKIdUsuario_SIS AS IdUsuario,
        STRING_AGG(s.Nombre, ', ') WITHIN GROUP (ORDER BY s.Nombre) AS SucursalesDirectas,
        COUNT(DISTINCT s.PKIdSucursal) AS TotalSucursalesDirectas,
        SUM(CASE WHEN us.EsGerente = 1 THEN 1 ELSE 0 END) AS TotalGerente,
        SUM(CASE WHEN us.EsSupervisor = 1 THEN 1 ELSE 0 END) AS TotalSupervisor,
        MAX(CASE WHEN s.EsMatriz = 1 THEN s.Nombre ELSE NULL END) AS SucursalMatriz
    FROM SIS.UsuarioSucursal us
    INNER JOIN SIS.Sucursal s ON us.FKIdSucursal_SIS = s.PKIdSucursal
    WHERE us.Activo = 1 AND s.Activo = 1 AND us.PuedeAcceder = 1
    GROUP BY us.FKIdUsuario_SIS
    
    UNION ALL
    
    -- Acceso por Departamento
    SELECT 
        ud.FKIdUsuario_SIS AS IdUsuario,
        STRING_AGG(s.Nombre, ', ') WITHIN GROUP (ORDER BY s.Nombre) AS SucursalesDirectas,
        COUNT(DISTINCT s.PKIdSucursal) AS TotalSucursalesDirectas,
        0 AS TotalGerente,
        0 AS TotalSupervisor,
        MAX(CASE WHEN s.EsMatriz = 1 THEN s.Nombre ELSE NULL END) AS SucursalMatriz
    FROM SIS.UsuarioDepartamento ud
    INNER JOIN SIS.Departamento d ON ud.FKIdDepartamento_SIS = d.PKIdDepartamento
    INNER JOIN SIS.Sucursal s ON d.FKIdSucursal_SIS = s.PKIdSucursal
    WHERE ud.Activo = 1 AND d.Activo = 1 AND s.Activo = 1
    GROUP BY ud.FKIdUsuario_SIS
),
SucursalesConsolidadas AS (
    SELECT 
        IdUsuario,
        STRING_AGG(SucursalesDirectas, ', ') AS ListaSucursales,
        SUM(TotalSucursalesDirectas) AS TotalSucursales,
        MAX(TotalGerente) AS EsGerente,
        MAX(TotalSupervisor) AS EsSupervisor,
        MAX(SucursalMatriz) AS SucursalMatrizAsignada
    FROM SucursalesResumen
    GROUP BY IdUsuario
)
SELECT 
    -- Datos del Usuario
    u.PkIdUsuario,
    u.AspNetUserId,
    u.FKIdEmpresa_SIS AS IdEmpresa,
    CONCAT(p.Nombre, ' ', p.Paterno, ' ', ISNULL(p.Materno, '')) AS NombreCompleto,
    p.Nombre,
    p.Paterno AS ApellidoPaterno,
    p.Materno AS ApellidoMaterno,
    p.Iniciales,
    u.PayrollID,
    p.CP AS CodigoPostal,
    p.Telefono_particular AS Telefono,
    p.Calle AS Direccion1,
    p.Colonia AS Direccion2,
    p.CORREO_ELECTRONICO AS Email,
    p.NoCredencialElector AS NumeroSocial,
    p.Gafete,
    p.Sexo AS SexoDescripcion,
    p.Sexo,
    p.Fecha_de_Inicio AS FechaIngreso,
    FORMAT(p.Fecha_de_Inicio, 'dd/MM/yyyy') AS FechaIngresoFormat,
    DATEDIFF(YEAR, p.Fecha_de_Inicio, GETDATE()) AS AntiguedadAnios,
    u.FKIdIdiomaPreferido_SIS AS IdIdiomaPreferido,
    i.Nombre AS IdiomaPreferido,
    u.FKIdMonedaPreferida_SIS AS IdMonedaPreferida,
    m.Nombre AS MonedaPreferida,
    m.Simbolo AS SimboloMoneda,
    u.EsAdministrador,
    u.Activo AS UsuarioActivo,
    u.FechaCreacion AS UsuarioFechaCreacion,
    FORMAT(u.FechaCreacion, 'dd/MM/yyyy HH:mm') AS UsuarioFechaCreacionFormat,
    u.UsuarioCreacion,
    u.FechaModificacion AS UsuarioFechaModificacion,
    u.UsuarioModificacion,
    
    -- Datos de Persona (NOM)
    p.PKIdPersona AS IdPersona,
    p.Clave AS ClavePersona,
    p.Nombre AS PersonaNombre,
    p.Paterno AS PersonaPaterno,
    p.Materno AS PersonaMaterno,
    CONCAT(p.Nombre, ' ', p.Paterno, ' ', ISNULL(p.Materno, '')) AS NombreCompletoPersona,
    p.RFC,
    p.Curp,
    p.CORREO_ELECTRONICO AS EmailPersona,
    p.Telefono_particular AS TelefonoParticular,
    p.Telefono_movil AS TelefonoMovil,
    p.Fecha_de_Inicio AS FechaInicioPersona,
    p.Fecha_Fin AS FechaFinPersona,
    FORMAT(p.FechaNacimiento, 'dd/MM/yyyy') AS FechaNacimientoFormat,
    p.Sexo AS SexoPersona,
    p.ESTADO_CIVIL AS EstadoCivil,
    p.Municipio,
    p.REG_IMSS,
    p.NoCartilla,
    p.NoLicencia,
    p.NoPasaporte,
    p.NoCredencialElector,
    p.Calle,
    p.Num_exterior,
    p.Num_interior,
    p.Colonia,
    p.CP AS CodigoPostalPersona,
    p.Estado,
    p.TIPO_CONTRATACION,
    p.PUESTO,
    p.SUELDO_BASE,
    p.COMPENSACION_GARANTIZADA,
    p.BANCO,
    p.NUMERO_CUENTA,
    p.CLABE,
    p.Activo AS PersonaActivo,
    
    -- Datos de Empresa
    e.PKIdEmpresa,
    e.Nombre AS NombreEmpresa,
    e.RFC AS RfcEmpresa,
    e.RazonSocial AS RazonSocialEmpresa,
    e.Giro AS GiroEmpresa,
    e.FKIdMonedaBase_SIS AS IdMonedaBaseEmpresa,
    mb.Nombre AS MonedaBaseEmpresa,
    mb.Simbolo AS SimboloMonedaBase,
    e.Activo AS EmpresaActiva,
    e.FechaCreacion AS EmpresaFechaCreacion,
    
    -- Resumen de Departamentos
    (
        SELECT STRING_AGG(d.Nombre, ', ') 
        FROM SIS.UsuarioDepartamento ud2
        INNER JOIN SIS.Departamento d ON ud2.FKIdDepartamento_SIS = d.PKIdDepartamento
        WHERE ud2.FKIdUsuario_SIS = u.PkIdUsuario AND ud2.Activo = 1 AND d.Activo = 1
    ) AS ListaDepartamentos,
    
    (
        SELECT COUNT(DISTINCT d2.PKIdDepartamento)
        FROM SIS.UsuarioDepartamento ud2
        INNER JOIN SIS.Departamento d2 ON ud2.FKIdDepartamento_SIS = d2.PKIdDepartamento
        WHERE ud2.FKIdUsuario_SIS = u.PkIdUsuario AND ud2.Activo = 1 AND d2.Activo = 1
    ) AS TotalDepartamentos,
    
    -- Indicadores de jefatura
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM SIS.UsuarioDepartamento ud3
            WHERE ud3.FKIdUsuario_SIS = u.PkIdUsuario AND ud3.EsJefe = 1 AND ud3.Activo = 1
        ) THEN 1 ELSE 0 
    END AS EsJefeAlgunDepartamento,
    
    (
        SELECT STRING_AGG(d4.Nombre, ', ')
        FROM SIS.UsuarioDepartamento ud4
        INNER JOIN SIS.Departamento d4 ON ud4.FKIdDepartamento_SIS = d4.PKIdDepartamento
        WHERE ud4.FKIdUsuario_SIS = u.PkIdUsuario AND ud4.EsJefe = 1 AND ud4.Activo = 1
    ) AS DepartamentosComoJefe,
    
    -- Resumen de Sucursales (consolidado)
    sc.ListaSucursales,
    ISNULL(sc.TotalSucursales, 0) AS TotalSucursales,
    sc.SucursalMatrizAsignada,
    
    -- Indicadores de rol
    CASE 
        WHEN u.EsAdministrador = 1 THEN 'Administrador Global'
        WHEN sc.EsGerente = 1 THEN 'Gerente de Sucursal'
        WHEN sc.EsSupervisor = 1 THEN 'Supervisor'
        WHEN EXISTS (
            SELECT 1 FROM SIS.UsuarioDepartamento ud5
            WHERE ud5.FKIdUsuario_SIS = u.PkIdUsuario AND ud5.EsJefe = 1 AND ud5.Activo = 1
        ) THEN 'Jefe de Departamento'
        ELSE 'Empleado'
    END AS RolPrincipal,
    
    -- Metadatos adicionales
    CASE 
        WHEN sc.TotalSucursales > 5 THEN 'Multi-sucursal'
        WHEN sc.TotalSucursales > 1 THEN 'Varias sucursales'
        WHEN sc.TotalSucursales = 1 THEN 'Una sucursal'
        ELSE 'Sin sucursal'
    END AS CoberturaSucursales,
    
    NULL AS UltimoAcceso,
    
    u.PayrollID AS NumeroEmpleado,
    ISNULL(UPPER(CONCAT(LEFT(p.Nombre, 1), LEFT(p.Paterno, 1))), '') AS InicialesNombre

FROM SIS.Usuario u

-- Relaci�n con Empresa
INNER JOIN SIS.Empresa e ON u.FKIdEmpresa_SIS = e.PKIdEmpresa

-- Moneda base de la empresa
LEFT JOIN SIS.Moneda mb ON e.FKIdMonedaBase_SIS = mb.PKIdMoneda

-- Preferencias de idioma y moneda
LEFT JOIN SIS.Idioma i ON u.FKIdIdiomaPreferido_SIS = i.PKIdIdioma
LEFT JOIN SIS.Moneda m ON u.FKIdMonedaPreferida_SIS = m.PKIdMoneda

-- Datos de Persona
LEFT JOIN NOM.Persona p ON u.FKIdPersona_NOM = p.PKIdPersona AND p.Activo = 1

-- Sucursales consolidadas
LEFT JOIN SucursalesConsolidadas sc ON u.PkIdUsuario = sc.IdUsuario

WHERE u.Activo = 1;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [SIS].[VW_UsuarioPersonaArea]
AS
SELECT 
    u.PkIdUsuario,
    u.AspNetUserId,
    p.Nombre AS UsuarioNombre,
    p.Paterno AS ApellidoPaterno,
    p.Materno AS ApellidoMaterno,
    p.CORREO_ELECTRONICO AS Email,
    u.Activo AS UsuarioActivo,
    u.FechaCreacion AS UsuarioFechaCreacion,
    -- Datos de Persona
    p.PKIdPersona,
    p.Clave AS PersonaClave,
    p.Nombre AS PersonaNombre,
    p.Paterno AS PersonaPaterno,
    p.Materno AS PersonaMaterno,
    p.RFC,
    p.Curp,
    p.CORREO_ELECTRONICO,
    p.Activo AS PersonaActivo,
    -- Datos de �rea (a trav�s de PersonaArea)
    pa.PKIdPersonaArea,
    pa.IsAdscrito,
    pa.EsSolicitante,
    pa.EsAutorizador,
    a.PKIdArea,
    a.Clave AS AreaClave,
    a.Nombre AS AreaNombre,
    a.Activo AS AreaActivo,
    a.FKIdArea_SIS AS AreaPadreId,
    -- Campo combinado �til para frontend
    CONCAT(p.Nombre, ' ', p.Paterno, ' (', ISNULL(a.Nombre, 'Sin area'), ')') AS UsuarioAreaDescripcion
FROM SIS.Usuario u
LEFT JOIN NOM.Persona p ON u.FKIdPersona_NOM = p.PKIdPersona AND p.Activo = 1
LEFT JOIN NOM.PersonaArea pa ON p.PKIdPersona = pa.FKIdPersona_NOM AND pa.Activo = 1
LEFT JOIN SIS.Area a ON pa.FKIdArea_SIS = a.PKIdArea AND a.Activo = 1
WHERE u.Activo = 1;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [SIS].[Vw_UsuarioSucursal]
AS
SELECT 
    -- Datos del Usuario
    u.PkIdUsuario,
    u.AspNetUserId,
    u.FKIdEmpresa_SIS AS IdEmpresa,
    p.Nombre,
    p.Paterno AS ApellidoPaterno,
    p.Materno AS ApellidoMaterno,
    CONCAT(p.Nombre, ' ', p.Paterno, ' ', ISNULL(p.Materno, '')) AS NombreCompleto,
    p.Iniciales,
    ISNULL(UPPER(CONCAT(LEFT(p.Nombre, 1), LEFT(p.Paterno, 1))), '') AS InicialesNombre,
    u.PayrollID AS PayrollId,
    p.CP AS CodigoPostal,
    p.Telefono_particular AS Telefono,
    p.Calle AS Direccion1,
    p.Colonia AS Direccion2,
    p.CORREO_ELECTRONICO AS Email,
    p.NoCredencialElector AS NumeroSocial,
    p.Gafete,
    p.Sexo,
    p.Sexo AS SexoDescripcion,
    p.Fecha_de_Inicio AS FechaIngreso,
    FORMAT(p.Fecha_de_Inicio, 'dd/MM/yyyy') AS FechaIngresoFormat,
    DATEDIFF(YEAR, p.Fecha_de_Inicio, GETDATE()) AS AntiguedadAnios,
    
    -- Idioma preferido
    u.FKIdIdiomaPreferido_SIS AS IdIdiomaPreferido,
    i.Nombre AS IdiomaPreferido,
    
    -- Moneda preferida
    u.FKIdMonedaPreferida_SIS AS IdMonedaPreferida,
    m.Nombre AS MonedaPreferida,
    m.Simbolo AS SimboloMoneda,
    
    -- Datos de usuario
    u.EsAdministrador,
    u.Activo AS UsuarioActivo,
    
    -- Datos de la Empresa
    e.PKIdEmpresa AS PkidEmpresa,
    e.Nombre AS NombreEmpresa,
    e.RFC AS RfcEmpresa,
    e.RazonSocial AS RazonSocialEmpresa,
    e.Giro AS GiroEmpresa,
    e.FKIdMonedaBase_SIS AS IdMonedaBaseEmpresa,
    mb.Nombre AS MonedaBaseEmpresa,
    mb.Simbolo AS SimboloMonedaBase,
    e.FechaCreacion AS EmpresaFechaCreacion,
    
    -- Datos de la Sucursal asignada
    s.PKIdSucursal AS IdSucursal,
    s.Nombre AS NombreSucursal,
    s.CodigoSucursal,
    s.Direccion AS DireccionSucursal,
    s.EsMatriz,
    
    -- Permisos espec�ficos de la asignaci�n
    us.PuedeAcceder,
    us.PuedeConfigurar,
    us.PuedeOperar,
    us.PuedeReportes,
    us.EsGerente,
    us.EsSupervisor,
    us.Activo AS AsignacionActiva,
    
    -- Indicador de si es jefe en alg�n departamento de esta sucursal
    CASE 
        WHEN EXISTS (
            SELECT 1
            FROM SIS.UsuarioDepartamento ud
            INNER JOIN SIS.Departamento d ON ud.FKIdDepartamento_SIS = d.PKIdDepartamento
            WHERE ud.FKIdUsuario_SIS = u.PkIdUsuario
            AND d.FKIdSucursal_SIS = s.PKIdSucursal
            AND ud.EsJefe = 1
            AND ud.Activo = 1
            AND (ud.FechaFinAsignacion IS NULL OR ud.FechaFinAsignacion >= GETDATE())
        ) THEN 1 ELSE 0 
    END AS EsJefeEnSucursal,
    u.FechaCreacion,u.UsuarioCreacion,u.FechaModificacion,u.UsuarioModificacion,
    -- Datos de Persona (NOM)
    p.PKIdPersona AS IdPersona,
    p.Clave AS ClavePersona,
    p.Nombre AS PersonaNombre,
    p.Paterno AS PersonaPaterno,
    p.Materno AS PersonaMaterno,
    CONCAT(p.Nombre, ' ', p.Paterno, ' ', ISNULL(p.Materno, '')) AS NombreCompletoPersona,
    p.RFC,
    p.Curp,
    p.CORREO_ELECTRONICO AS EmailPersona,
    p.Telefono_particular AS TelefonoParticular,
    p.Telefono_movil AS TelefonoMovil,
    u.FKIdEmpresa_SIS AS IdEmpresaPersona
FROM SIS.Usuario u
INNER JOIN SIS.Empresa e ON u.FKIdEmpresa_SIS = e.PKIdEmpresa
LEFT JOIN SIS.Idioma i ON u.FKIdIdiomaPreferido_SIS = i.PKIdIdioma
LEFT JOIN SIS.Moneda m ON u.FKIdMonedaPreferida_SIS = m.PKIdMoneda
LEFT JOIN SIS.Moneda mb ON e.FKIdMonedaBase_SIS = mb.PKIdMoneda
INNER JOIN SIS.UsuarioSucursal us ON u.PkIdUsuario = us.FKIdUsuario_SIS
INNER JOIN SIS.Sucursal s ON us.FKIdSucursal_SIS = s.PKIdSucursal
-- Datos de Persona
LEFT JOIN NOM.Persona p ON u.FKIdPersona_NOM = p.PKIdPersona AND p.Activo = 1
WHERE us.Activo = 1 
  AND (us.FechaFinAsignacion IS NULL OR us.FechaFinAsignacion >= GETDATE())
  AND u.Activo = 1;
GO

-- =============================================
-- TES
-- =============================================

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [TES].[Vw_TipoCambio] AS
SELECT 
    tc.PKIdTipoCambio,
    tc.FKIdTipoMoneda_TES,
    tc.Cantidad,
    tc.Fecha,
    tc.Activo,
    tc.FechaCreacion,
    tc.UsuarioCreacion,
    tc.FechaModificacion,
    tc.UsuarioModificacion,
    tm.Descripcion AS MonedaDescripcion,
    tm.CodigoISO4217 AS MonedaCodigo
FROM TES.TipoCambio tc
LEFT JOIN TES.TipoMoneda tm ON tc.FKIdTipoMoneda_TES = tm.PKIdTipoMoneda AND tm.Activo = 1
WHERE tc.Activo = 1;
GO

PRINT 'Vistas creadas exitosamente.';
GO
