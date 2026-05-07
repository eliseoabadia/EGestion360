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
LEFT JOIN CONTA.Vw_Cuentas ctaA ON mc.FKIdCuentaContableAprobado = ctaA.PkIdCuenta AND ctaA.ClaveOrd LIKE '8 2 1%' AND ctaA.NivelCuenta = 7
LEFT JOIN CONTA.Vw_Cuentas ctaPJ ON mc.FKIdCuentaContablePorEjercer = ctaPJ.PkIdCuenta AND ctaPJ.ClaveOrd LIKE '8 2 2%'
LEFT JOIN CONTA.Vw_Cuentas ctaM ON mc.FKIdCuentaContableModificado = ctaM.PkIdCuenta AND ctaM.ClaveOrd LIKE '8 2 3%'
LEFT JOIN CONTA.Vw_Cuentas ctaC ON mc.FKIdCuentaContableComprometido = ctaC.PkIdCuenta AND ctaC.ClaveOrd LIKE '8 2 4%'
LEFT JOIN CONTA.Vw_Cuentas ctaD ON mc.FKIdCuentaContableDevengado = ctaD.PkIdCuenta AND ctaD.ClaveOrd LIKE '8 2 5%'
LEFT JOIN CONTA.Vw_Cuentas ctaE ON mc.FKIdCuentaContableEjercido = ctaE.PkIdCuenta AND ctaE.ClaveOrd LIKE '8 2 6%'
LEFT JOIN CONTA.Vw_Cuentas ctaPag ON mc.FKIdCuentaContablePagado = ctaPag.PkIdCuenta AND ctaPag.ClaveOrd LIKE '8 2 7%'
LEFT JOIN CONTA.Vw_Cuentas ctaG ON mc.FKIdCuentaContableGasto = ctaG.PkIdCuenta AND ctaA.ClaveOrd LIKE '5%'
WHERE mc.Activo = 1
--and p.Clave= '02030101'
--and mc.PKIdMatrizConversion = 6874;

select * from CONTA.Vw_Cuentas ctaA where ctaA.ClaveOrd LIKE '8 2 1%' AND ctaA.NivelCuenta = 7

-- =============================================
-- Vista: CONTA.Vw_MatrizIngresoColumnas
-- Descripción: Presenta la matriz de conversión de ingresos
--              con los datos de Año, Programa, Origen y las
--              6 cuentas contables en columnas separadas.
-- =============================================
IF OBJECT_ID('CONTA.Vw_MatrizIngresoColumnas', 'V') IS NOT NULL 
    DROP VIEW CONTA.Vw_MatrizIngresoColumnas;
GO

CREATE VIEW CONTA.Vw_MatrizIngresoColumnas
AS
SELECT 
    -- Identificador de la matriz
    mi.Pk_IdMatrizIngreso,
    -- Año
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
    -- Cuenta Depósito
    ctaDep.ClaveNombre AS CuentaDeposito,
    -- Datos de auditoría
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