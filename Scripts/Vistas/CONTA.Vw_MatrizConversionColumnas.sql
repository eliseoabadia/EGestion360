-- =============================================
-- Vista: CONTA.VwCuentas
-- Descripción: Proporciona los datos de cuentas contables
--              para ser utilizados en los métodos:
--              GetCuentaContableAprobado, PorEjercer, Modificado,
--              Comprometido, Devengado, Ejercido, Pagado, Gasto.
-- =============================================
IF OBJECT_ID('CONTA.Vw_Cuentas', 'V') IS NOT NULL DROP VIEW CONTA.VwCuentas;
GO

CREATE VIEW CONTA.Vw_Cuentas
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




-- =============================================
-- Vista única: CONTA.VwCuentasPorTipo
-- Descripción: Proporciona todas las cuentas contables de nivel detalle
--              (NivelCuenta = 7, Activo = 1) clasificadas por tipo de
--              presupuesto según el prefijo de ClaveOrd.
-- Columnas: PkIdCuenta, ClaveNombre, TipoPresupuesto
-- =============================================
IF OBJECT_ID('CONTA.Vw_MatrizConversionColumnas', 'V') IS NOT NULL DROP VIEW CONTA.Vw_MatrizConversionColumnas;
GO

CREATE VIEW CONTA.Vw_MatrizConversionColumnas AS
SELECT 
    -- Identificador de la matriz
    mc.PKIdMatrizConversion,
    -- Año
    a.Clave AS AnioClave,
    -- Programa (clave + descripción)
    p.Clave AS ProgramaClave,
    p.Descripcion AS ProgramaDescripcion,
    -- Partida (clave + descripción)
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
    -- Datos de auditoría
    mc.Activo,
    mc.FechaCreacion,
    mc.UsuarioCreacion
FROM CONTA.MatrizConversion mc
INNER JOIN SIS.Anio a ON mc.FKIdAnio_SIS = a.PKIdAnio
INNER JOIN PRES.Programa p ON mc.FKIdPrograma_PRES = p.PKIdPrograma
INNER JOIN SIS.Partida pt ON mc.FKIdPartida_SIS = pt.PKIdPartida
INNER JOIN CONTA.Vw_Cuentas ctaA ON mc.FKIdCuentaContableAprobado = ctaA.PkIdCuenta
INNER JOIN CONTA.Vw_Cuentas ctaPJ ON mc.FKIdCuentaContablePorEjercer = ctaPJ.PkIdCuenta
INNER JOIN CONTA.Vw_Cuentas ctaM ON mc.FKIdCuentaContableModificado = ctaM.PkIdCuenta
INNER JOIN CONTA.Vw_Cuentas ctaC ON mc.FKIdCuentaContableComprometido = ctaC.PkIdCuenta
INNER JOIN CONTA.Vw_Cuentas ctaD ON mc.FKIdCuentaContableDevengado = ctaD.PkIdCuenta
INNER JOIN CONTA.Vw_Cuentas ctaE ON mc.FKIdCuentaContableEjercido = ctaE.PkIdCuenta
INNER JOIN CONTA.Vw_Cuentas ctaPag ON mc.FKIdCuentaContablePagado = ctaPag.PkIdCuenta
INNER JOIN CONTA.Vw_Cuentas ctaG ON mc.FKIdCuentaContableGasto = ctaG.PkIdCuenta
WHERE mc.Activo = 1
--and p.Clave= '02030101'
--and mc.PKIdMatrizConversion = 6874;