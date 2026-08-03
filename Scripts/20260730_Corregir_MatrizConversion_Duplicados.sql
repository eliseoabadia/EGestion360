/*
    Correccion de datos de CONTA.MatrizConversion.

    Criterio respaldado por BD_PRESUPUESTO.CONTA.MatrizConversion:
    - Se conservan las reglas historicas PK 4598 a 4605.
    - Se eliminan las matrices con Activo = 0 y ocho altas duplicadas del
      01/01/2026; seis contienen cuentas ajenas a la partida y dos son
      copias exactas.
    - Se restaura PK 6875 desde su registro homologo en BD_PRESUPUESTO.
    - Se impide una nueva duplicidad activa por anio/programa/partida/tipo.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER ON;
SET NUMERIC_ROUNDABORT OFF;

BEGIN TRANSACTION;

DECLARE @Ahora datetime2(7) = SYSDATETIME();
DECLARE @UsuarioSistema int = 1;

DECLARE @Duplicados TABLE (PKIdMatrizConversion int NOT NULL PRIMARY KEY);
INSERT INTO @Duplicados (PKIdMatrizConversion)
VALUES (4683), (4870), (4937), (4993), (6224), (6229), (6297), (6483);

DECLARE @Eliminados TABLE (PKIdMatrizConversion int NOT NULL PRIMARY KEY);
DECLARE @DuplicadosActivos int = (
    SELECT COUNT(*)
    FROM CONTA.MatrizConversion WITH (UPDLOCK, HOLDLOCK)
    WHERE PKIdMatrizConversion IN (SELECT PKIdMatrizConversion FROM @Duplicados)
      AND Activo = 1);

IF @DuplicadosActivos NOT IN (0, 8)
BEGIN
    THROW 51001, 'La correccion se detuvo: el conjunto de duplicados no coincide con el esperado.', 1;
END;

IF NOT EXISTS (
    SELECT 1
    FROM CONTA.MatrizConversion destino WITH (UPDLOCK, HOLDLOCK)
    INNER JOIN BD_PRESUPUESTO.CONTA.MatrizConversion origen
        ON origen.PK_IdMatrizConversion = destino.PKIdMatrizConversion
    WHERE destino.PKIdMatrizConversion = 6875
      AND destino.Activo = 1
      AND origen.CT_LIVE = 1)
BEGIN
    THROW 51002, 'La correccion se detuvo: no se encontro el origen activo de la matriz 6875.', 1;
END;

DELETE FROM CONTA.MatrizConversion
OUTPUT DELETED.PKIdMatrizConversion INTO @Eliminados (PKIdMatrizConversion)
WHERE Activo = 0;

DELETE FROM CONTA.MatrizConversion
OUTPUT DELETED.PKIdMatrizConversion INTO @Eliminados (PKIdMatrizConversion)
WHERE PKIdMatrizConversion IN (SELECT PKIdMatrizConversion FROM @Duplicados)
  AND Activo = 1;

IF EXISTS (SELECT 1 FROM CONTA.MatrizConversion WHERE Activo = 0)
BEGIN
    THROW 51004, 'La correccion se detuvo: quedaron matrices con Activo = 0.', 1;
END;

UPDATE destino
SET FKIdAnio_SIS = origen.FK_IdAnio__SIS,
    FKIdPrograma_PRES = origen.FK_IdPrograma__PRES,
    FKIdPartida_SIS = origen.FK_IdPartida__SIS,
    FKIdTipoGasto_PRES = 1,
    FKIdCuentaContableAprobado = origen.FK_IdCuentaContableAprobado,
    FKIdCuentaContablePorEjercer = origen.FK_IdCuentaContablePorEjercer,
    FKIdCuentaContableModificado = origen.FK_IdCuentaContableModificado,
    FKIdCuentaContableComprometido = origen.FK_IdCuentaContableComprometido,
    FKIdCuentaContableDevengado = origen.FK_IdCuentaContableDevengado,
    FKIdCuentaContableEjercido = origen.FK_IdCuentaContableEjercido,
    FKIdCuentaContablePagado = origen.FK_IdCuentaContablePagado,
    FKIdCuentaContableGasto = origen.FK_IdCuentaContableGasto,
    FechaModificacion = @Ahora,
    UsuarioModificacion = @UsuarioSistema
FROM CONTA.MatrizConversion destino
INNER JOIN BD_PRESUPUESTO.CONTA.MatrizConversion origen
    ON origen.PK_IdMatrizConversion = destino.PKIdMatrizConversion
WHERE destino.PKIdMatrizConversion = 6875;

IF EXISTS (
    SELECT 1
    FROM CONTA.MatrizConversion
    WHERE Activo = 1
    GROUP BY FKIdAnio_SIS, FKIdPrograma_PRES, FKIdPartida_SIS, FKIdTipoGasto_PRES
    HAVING COUNT(*) > 1)
BEGIN
    THROW 51003, 'La correccion se detuvo: aun existen combinaciones activas duplicadas.', 1;
END;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'CONTA.MatrizConversion')
      AND name = N'UX_MatrizConversion_Clasificacion_Activa')
BEGIN
    CREATE UNIQUE INDEX UX_MatrizConversion_Clasificacion_Activa
        ON CONTA.MatrizConversion
            (FKIdAnio_SIS, FKIdPrograma_PRES, FKIdPartida_SIS, FKIdTipoGasto_PRES)
        WHERE Activo = 1;
END;

COMMIT TRANSACTION;

SELECT
    MatricesActivas = COUNT(*),
    GruposDuplicados = SUM(CASE WHEN Repetidos > 1 THEN 1 ELSE 0 END)
FROM (
    SELECT
        FKIdAnio_SIS,
        FKIdPrograma_PRES,
        FKIdPartida_SIS,
        FKIdTipoGasto_PRES,
        COUNT(*) AS Repetidos
    FROM CONTA.MatrizConversion
    WHERE Activo = 1
    GROUP BY FKIdAnio_SIS, FKIdPrograma_PRES, FKIdPartida_SIS, FKIdTipoGasto_PRES
) AS resumen;

SELECT PKIdMatrizConversion, Resultado = 'ELIMINADO'
FROM @Eliminados
ORDER BY PKIdMatrizConversion;

SELECT
    PKIdMatrizConversion,
    FKIdAnio_SIS,
    FKIdPrograma_PRES,
    FKIdPartida_SIS,
    FKIdTipoGasto_PRES,
    FKIdCuentaContableAprobado,
    Activo
FROM CONTA.MatrizConversion
WHERE PKIdMatrizConversion = 6875;
