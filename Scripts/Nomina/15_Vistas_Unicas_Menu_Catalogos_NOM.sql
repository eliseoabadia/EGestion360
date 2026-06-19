/*
    Vistas de catalogos alineadas con el menu definido en:
        Scripts/00.GestionEmpresarial.sql

    IMPORTANTE:
    - Este script NO modifica SIS.Menu, SIS.MenuRole ni claims.
    - 00.GestionEmpresarial.sql conserva toda la autoridad sobre menu y permisos.
    - Cada opcion navegable de configuracion de Nomina/RH queda asociada a una
      vista distinta; no se reutiliza NOM.Vw_CatalogoSimple entre menus.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET QUOTED_IDENTIFIER ON;

IF SCHEMA_ID(N'NOM') IS NULL
    EXEC(N'CREATE SCHEMA NOM');

IF OBJECT_ID(N'NOM.CatalogoSimple', N'U') IS NULL
    THROW 51000, 'Falta NOM.CatalogoSimple. Ejecute primero los scripts base de Nomina.', 1;

IF OBJECT_ID(N'NOM.PeriodoNomina', N'U') IS NULL
    THROW 51000, 'Falta NOM.PeriodoNomina. Ejecute primero los scripts base de Nomina.', 1;

IF OBJECT_ID(N'NOM.TablaFiscal', N'U') IS NULL
    THROW 51000, 'Falta NOM.TablaFiscal. Ejecute primero los scripts base de Nomina.', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    /*
        Completa tres catalogos que existen en el menu maestro y en la base
        legacy, pero no estaban migrados a las tablas consolidadas.
    */
    IF DB_ID(N'BD_GRP_INVEA') IS NOT NULL
    BEGIN
        MERGE NOM.CatalogoSimple AS target
        USING
        (
            SELECT
                N'Forma_Pago' AS Catalogo,
                N'SIS_FormaPago' AS LegacyTable,
                src.Pk_IdFormaPago AS LegacyId,
                CAST(NULL AS nvarchar(50)) AS Clave,
                src.Descripcion,
                src.Pk_IdFormaPago AS Orden,
                src.CT_CreatedBy AS UsuarioCreacion,
                COALESCE(src.CT_CreatedDate, SYSDATETIME()) AS FechaCreacion,
                src.CT_ModifiedBy AS UsuarioModificacion,
                src.CT_ModifiedDate AS FechaModificacion,
                COALESCE(src.CT_LIVE, 1) AS Activo
            FROM BD_GRP_INVEA.dbo.SIS_FormaPago AS src
        ) AS source
        ON target.Catalogo = source.Catalogo
        AND target.LegacyTable = source.LegacyTable
        AND target.LegacyId = source.LegacyId
        WHEN MATCHED THEN
            UPDATE SET
                target.Clave = source.Clave,
                target.Descripcion = source.Descripcion,
                target.Orden = source.Orden,
                target.UsuarioModificacion = source.UsuarioModificacion,
                target.FechaModificacion = source.FechaModificacion,
                target.Activo = source.Activo
        WHEN NOT MATCHED BY TARGET THEN
            INSERT
            (
                Catalogo, LegacyTable, LegacyId, Clave, Descripcion, Orden,
                UsuarioCreacion, FechaCreacion, UsuarioModificacion,
                FechaModificacion, Activo
            )
            VALUES
            (
                source.Catalogo, source.LegacyTable, source.LegacyId,
                source.Clave, source.Descripcion, source.Orden,
                source.UsuarioCreacion, source.FechaCreacion,
                source.UsuarioModificacion, source.FechaModificacion,
                source.Activo
            );

        MERGE NOM.PeriodoNomina AS target
        USING
        (
            SELECT
                N'Bimestral' AS TipoPeriodo,
                N'SIS_PeriodoBimestral' AS LegacyTable,
                src.Pk_IdPeriodoBimestral AS LegacyId,
                src.Fk_IdAnio__SIS AS Anio,
                src.Periodo,
                src.F_Inicio AS FechaInicio,
                src.F_Fin AS FechaFin,
                src.DiasHabiles,
                src.DiasInhabiles,
                src.CT_CreatedBy AS UsuarioCreacion,
                COALESCE(src.CT_CreatedDate, SYSDATETIME()) AS FechaCreacion,
                src.CT_ModifiedBy AS UsuarioModificacion,
                src.CT_ModifiedDate AS FechaModificacion,
                COALESCE(src.CT_LIVE, 1) AS Activo
            FROM BD_GRP_INVEA.dbo.SIS_PeriodoBimestral AS src
        ) AS source
        ON target.LegacyTable = source.LegacyTable
        AND target.LegacyId = source.LegacyId
        WHEN MATCHED THEN
            UPDATE SET
                target.TipoPeriodo = source.TipoPeriodo,
                target.Anio = source.Anio,
                target.Periodo = source.Periodo,
                target.FechaInicio = source.FechaInicio,
                target.FechaFin = source.FechaFin,
                target.DiasHabiles = source.DiasHabiles,
                target.DiasInhabiles = source.DiasInhabiles,
                target.UsuarioModificacion = source.UsuarioModificacion,
                target.FechaModificacion = source.FechaModificacion,
                target.Activo = source.Activo
        WHEN NOT MATCHED BY TARGET THEN
            INSERT
            (
                TipoPeriodo, LegacyTable, LegacyId, Anio, Periodo,
                FechaInicio, FechaFin, DiasHabiles, DiasInhabiles,
                UsuarioCreacion, FechaCreacion, UsuarioModificacion,
                FechaModificacion, Activo
            )
            VALUES
            (
                source.TipoPeriodo, source.LegacyTable, source.LegacyId,
                source.Anio, source.Periodo, source.FechaInicio,
                source.FechaFin, source.DiasHabiles, source.DiasInhabiles,
                source.UsuarioCreacion, source.FechaCreacion,
                source.UsuarioModificacion, source.FechaModificacion,
                source.Activo
            );

        MERGE NOM.TablaFiscal AS target
        USING
        (
            SELECT
                N'Base_Gravable_IMSS' AS Catalogo,
                N'SIS_BaseGravableIMSS' AS LegacyTable,
                src.Pk_IdBaseGravableIMSS AS LegacyId,
                CONVERT(nvarchar(50), src.Fk_IdConcepto__NOM) AS Clave,
                CONCAT(N'Concepto ', src.Fk_IdConcepto__NOM) AS Descripcion,
                CONVERT(decimal(18,4), src.Porcentaje) AS Valor1,
                CONVERT(decimal(18,4), src.TopeSemanal) AS Valor2,
                CONVERT(decimal(18,4), src.TopeQuincenal) AS Valor3,
                CONVERT(decimal(18,4), src.TopeMensual) AS Valor4,
                src.CT_CreatedBy AS UsuarioCreacion,
                COALESCE(src.CT_CreatedDate, SYSDATETIME()) AS FechaCreacion,
                src.CT_ModifiedBy AS UsuarioModificacion,
                src.CT_ModifiedDate AS FechaModificacion,
                COALESCE(src.CT_LIVE, 1) AS Activo
            FROM BD_GRP_INVEA.dbo.SIS_BaseGravableIMSS AS src
        ) AS source
        ON target.LegacyTable = source.LegacyTable
        AND target.LegacyId = source.LegacyId
        WHEN MATCHED THEN
            UPDATE SET
                target.Catalogo = source.Catalogo,
                target.Clave = source.Clave,
                target.Descripcion = source.Descripcion,
                target.Valor1 = source.Valor1,
                target.Valor2 = source.Valor2,
                target.Valor3 = source.Valor3,
                target.Valor4 = source.Valor4,
                target.UsuarioModificacion = source.UsuarioModificacion,
                target.FechaModificacion = source.FechaModificacion,
                target.Activo = source.Activo
        WHEN NOT MATCHED BY TARGET THEN
            INSERT
            (
                Catalogo, LegacyTable, LegacyId, Clave, Descripcion,
                Valor1, Valor2, Valor3, Valor4, UsuarioCreacion,
                FechaCreacion, UsuarioModificacion, FechaModificacion, Activo
            )
            VALUES
            (
                source.Catalogo, source.LegacyTable, source.LegacyId,
                source.Clave, source.Descripcion, source.Valor1,
                source.Valor2, source.Valor3, source.Valor4,
                source.UsuarioCreacion, source.FechaCreacion,
                source.UsuarioModificacion, source.FechaModificacion,
                source.Activo
            );
    END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

/*
    Catalogos simples: una vista fisica distinta por opcion de menu.
*/
IF OBJECT_ID('tempdb..#VistasCatalogoSimple') IS NOT NULL
    DROP TABLE #VistasCatalogoSimple;

CREATE TABLE #VistasCatalogoSimple
(
    Vista sysname NOT NULL PRIMARY KEY,
    Catalogo nvarchar(80) NOT NULL UNIQUE
);

INSERT INTO #VistasCatalogoSimple (Vista, Catalogo)
VALUES
    (N'Vw_TipoNomina', N'Tipo_Nomina'),
    (N'Vw_CuotasIMSS', N'Cuotas_IMSS'),
    (N'Vw_UMA', N'UMA'),
    (N'Vw_TipoContratacion', N'Tipo_Contratacion'),
    (N'Vw_TipoDescanso', N'Tipo_Descanso'),
    (N'Vw_TipoIncidencia', N'Tipo_Incidencia'),
    (N'Vw_TipoJustificacion', N'Tipo_Justificacion'),
    (N'Vw_UnidadInfonavit', N'Unidad_Infonavit'),
    (N'Vw_FormaPago', N'Forma_Pago'),
    (N'Vw_FormaCalculo', N'Forma_Calculo'),
    (N'Vw_CapituloNomina', N'Capitulos'),
    (N'Vw_Sexo', N'Sexo'),
    (N'Vw_EstadoCivil', N'Estado_Civil'),
    (N'Vw_Escolaridad', N'Escolaridad'),
    (N'Vw_TipoParentesco', N'Tipo_Parentesco'),
    (N'Vw_Estado', N'Estado'),
    (N'Vw_NOM_Banco', N'Banco'),
    (N'Vw_Municipio', N'Municipio'),
    (N'Vw_BasePago', N'Base_Pago'),
    (N'Vw_MetodoPago', N'Metodo_Pago'),
    (N'Vw_TipoRegimen', N'Tipo_Regimen'),
    (N'Vw_BaseCotizacion', N'Base_Cotizacion'),
    (N'Vw_ZonaGeografica', N'Zona_Geografica'),
    (N'Vw_DiaSemana', N'Dia_Semana');

DECLARE @Vista sysname;
DECLARE @Catalogo nvarchar(80);
DECLARE @Sql nvarchar(max);

DECLARE vistas_catalogo_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT Vista, Catalogo
FROM #VistasCatalogoSimple
ORDER BY Vista;

OPEN vistas_catalogo_cursor;
FETCH NEXT FROM vistas_catalogo_cursor INTO @Vista, @Catalogo;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Sql = N'
CREATE OR ALTER VIEW NOM.' + QUOTENAME(@Vista) + N'
AS
SELECT
    c.PKIdCatalogoSimple,
    c.LegacyId,
    c.Clave,
    c.Descripcion,
    c.DescripcionCorta,
    c.FKIdCatalogoPadre_NOM,
    padre.Descripcion AS CatalogoPadreDescripcion,
    c.ValorDecimal1,
    c.ValorDecimal2,
    c.ValorEntero1,
    c.ValorEntero2,
    c.FechaInicio,
    c.FechaFin,
    c.DatoExtra1,
    c.DatoExtra2,
    c.Orden,
    c.UsuarioCreacion,
    c.FechaCreacion,
    c.UsuarioModificacion,
    c.FechaModificacion,
    c.Activo
FROM NOM.CatalogoSimple AS c
LEFT JOIN NOM.CatalogoSimple AS padre
    ON padre.PKIdCatalogoSimple = c.FKIdCatalogoPadre_NOM
WHERE c.Catalogo = N''' + REPLACE(@Catalogo, N'''', N'''''') + N''';';

    EXEC sys.sp_executesql @Sql;
    FETCH NEXT FROM vistas_catalogo_cursor INTO @Vista, @Catalogo;
END;

CLOSE vistas_catalogo_cursor;
DEALLOCATE vistas_catalogo_cursor;
DROP TABLE #VistasCatalogoSimple;

/*
    Periodos: cada frecuencia del menu tiene su propia vista.
*/
IF OBJECT_ID('tempdb..#VistasPeriodo') IS NOT NULL
    DROP TABLE #VistasPeriodo;

CREATE TABLE #VistasPeriodo
(
    Vista sysname NOT NULL PRIMARY KEY,
    TipoPeriodo nvarchar(30) NOT NULL UNIQUE
);

INSERT INTO #VistasPeriodo (Vista, TipoPeriodo)
VALUES
    (N'Vw_PeriodoSemanal', N'Semanal'),
    (N'Vw_PeriodoQuincenal', N'Quincenal'),
    (N'Vw_PeriodoMensual', N'Mensual'),
    (N'Vw_PeriodoBimestral', N'Bimestral');

DECLARE vistas_periodo_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT Vista, TipoPeriodo
FROM #VistasPeriodo
ORDER BY Vista;

OPEN vistas_periodo_cursor;
FETCH NEXT FROM vistas_periodo_cursor INTO @Vista, @Catalogo;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Sql = N'
CREATE OR ALTER VIEW NOM.' + QUOTENAME(@Vista) + N'
AS
SELECT
    p.PKIdPeriodoNomina,
    p.LegacyId,
    p.Anio,
    p.Mes,
    p.Periodo,
    p.FechaInicio,
    p.FechaFin,
    p.DiasHabiles,
    p.DiasInhabiles,
    p.DiasPeriodo,
    p.FKIdEmpresa_SIS,
    e.RazonSocial AS EmpresaNombre,
    p.EsFinMes,
    p.EsFinBimestre,
    p.UsuarioCreacion,
    p.FechaCreacion,
    p.UsuarioModificacion,
    p.FechaModificacion,
    p.Activo
FROM NOM.PeriodoNomina AS p
LEFT JOIN SIS.Empresa AS e
    ON e.PKIdEmpresa = p.FKIdEmpresa_SIS
WHERE p.TipoPeriodo = N''' + REPLACE(@Catalogo, N'''', N'''''') + N''';';

    EXEC sys.sp_executesql @Sql;
    FETCH NEXT FROM vistas_periodo_cursor INTO @Vista, @Catalogo;
END;

CLOSE vistas_periodo_cursor;
DEALLOCATE vistas_periodo_cursor;
DROP TABLE #VistasPeriodo;

/*
    Tablas fiscales e IMSS: una vista por opcion de menu.
    Los catalogos semanales se crean aunque hoy no tengan registros legacy.
*/
IF OBJECT_ID('tempdb..#VistasFiscales') IS NOT NULL
    DROP TABLE #VistasFiscales;

CREATE TABLE #VistasFiscales
(
    Vista sysname NOT NULL PRIMARY KEY,
    Catalogo nvarchar(80) NOT NULL UNIQUE
);

INSERT INTO #VistasFiscales (Vista, Catalogo)
VALUES
    (N'Vw_TablaISRSemanal', N'ISR_Semanal'),
    (N'Vw_TablaISRQuincenal', N'ISR_Quincenal'),
    (N'Vw_TablaISRMensual', N'ISR_Mensual'),
    (N'Vw_SubsidioISRSemanal', N'Subsidio_Semanal'),
    (N'Vw_SubsidioISRQuincenal', N'Subsidio_Quincenal'),
    (N'Vw_SubsidioISRMensual', N'Subsidio_Mensual'),
    (N'Vw_BaseGravable', N'Base_Gravable'),
    (N'Vw_ImpuestoLocal', N'Impuesto_Local'),
    (N'Vw_ClaseIMSS', N'IMSS_Clase'),
    (N'Vw_FraccionIMSS', N'IMSS_Fraccion'),
    (N'Vw_BaseGravableIMSS', N'Base_Gravable_IMSS');

DECLARE vistas_fiscales_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT Vista, Catalogo
FROM #VistasFiscales
ORDER BY Vista;

OPEN vistas_fiscales_cursor;
FETCH NEXT FROM vistas_fiscales_cursor INTO @Vista, @Catalogo;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Sql = N'
CREATE OR ALTER VIEW NOM.' + QUOTENAME(@Vista) + N'
AS
SELECT
    f.PKIdTablaFiscal,
    f.LegacyId,
    f.Clave,
    f.Descripcion,
    f.Valor1,
    f.Valor2,
    f.Valor3,
    f.Valor4,
    f.FechaInicio,
    f.FechaFin,
    f.FKIdCatalogoPadre_NOM,
    COALESCE(padreFiscal.Descripcion, padreSimple.Descripcion) AS CatalogoPadreDescripcion,
    f.UsuarioCreacion,
    f.FechaCreacion,
    f.UsuarioModificacion,
    f.FechaModificacion,
    f.Activo
FROM NOM.TablaFiscal AS f
LEFT JOIN NOM.TablaFiscal AS padreFiscal
    ON padreFiscal.PKIdTablaFiscal = f.FKIdCatalogoPadre_NOM
LEFT JOIN NOM.CatalogoSimple AS padreSimple
    ON padreSimple.PKIdCatalogoSimple = f.FKIdCatalogoPadre_NOM
WHERE f.Catalogo = N''' + REPLACE(@Catalogo, N'''', N'''''') + N''';';

    EXEC sys.sp_executesql @Sql;
    FETCH NEXT FROM vistas_fiscales_cursor INTO @Vista, @Catalogo;
END;

CLOSE vistas_fiscales_cursor;
DEALLOCATE vistas_fiscales_cursor;
DROP TABLE #VistasFiscales;

/*
    Prestaciones minimas de ley. NOM.FactorInt ya contiene la tabla por
    antiguedad usada para vacaciones, prima vacacional y aguinaldo.
*/
EXEC(N'
CREATE OR ALTER VIEW NOM.Vw_PrestacionesMinimas
AS
SELECT
    f.PKIdFactor AS PKIdPrestacionMinima,
    f.Anio AS AniosAntiguedad,
    f.Vacaciones AS DiasVacaciones,
    f.Vacacional AS PrimaVacacional,
    f.Aguinaldo AS DiasAguinaldo,
    f.Integracion AS FactorIntegracion,
    f.PrimaDominical,
    f.UsuarioCreacion,
    f.FechaCreacion,
    f.UsuarioModificacion,
    f.FechaModificacion,
    f.Activo
FROM NOM.FactorInt AS f;
');

/*
    Plazas autorizadas. Antes la ruta del menu terminaba mostrando puestos;
    esta vista deja disponible el catalogo que realmente nombra el menu 901.
*/
EXEC(N'
CREATE OR ALTER VIEW NOM.Vw_PlazaAutorizada
AS
SELECT
    p.PKIdPlazaAutorizada,
    p.FKIdPuesto_NOM,
    puesto.Nombre AS PuestoNombre,
    p.FKIdArea_SIS,
    area.Clave AS AreaClave,
    area.Nombre AS AreaNombre,
    p.FKIdSituacionPlaza_RH,
    p.SituacionPlaza,
    p.Plaza,
    p.FechaInicio,
    p.FechaFin,
    p.TipoPlaza,
    p.Documento,
    p.FechaDocumento,
    p.Descripcion,
    p.FKIdEmpresa_SIS,
    empresa.RazonSocial AS EmpresaNombre,
    p.UsuarioCreacion,
    p.FechaCreacion,
    p.UsuarioModificacion,
    p.FechaModificacion,
    p.Activo
FROM NOM.PlazaAutorizada AS p
LEFT JOIN NOM.Puesto AS puesto
    ON puesto.PKIdPuesto = p.FKIdPuesto_NOM
LEFT JOIN SIS.Area AS area
    ON area.PKIdArea = p.FKIdArea_SIS
LEFT JOIN SIS.Empresa AS empresa
    ON empresa.PKIdEmpresa = p.FKIdEmpresa_SIS;
');

/*
    Validacion contra las opciones navegables de configuracion existentes en
    00.GestionEmpresarial.sql al generar este script.

    La restriccion UNIQUE sobre Vista impide asignar una misma vista a dos
    menus dentro de este contrato de conciliacion.
*/
IF OBJECT_ID('tempdb..#MenuVistaNomina') IS NOT NULL
    DROP TABLE #MenuVistaNomina;

CREATE TABLE #MenuVistaNomina
(
    PKIdMenu int NOT NULL PRIMARY KEY,
    LegacyName nvarchar(100) NOT NULL UNIQUE,
    Vista sysname NOT NULL UNIQUE
);

INSERT INTO #MenuVistaNomina (PKIdMenu, LegacyName, Vista)
VALUES
    (811, N'Tipo_Nomina', N'Vw_TipoNomina'),
    (812, N'Cuotas_IMSS', N'Vw_CuotasIMSS'),
    (813, N'Conceptos_Nomina', N'Vw_NOM_Concepto'),
    (814, N'UMA', N'Vw_UMA'),
    (815, N'Tipo_Contratacion', N'Vw_TipoContratacion'),
    (816, N'Tipo_Descanso', N'Vw_TipoDescanso'),
    (817, N'Tipo_Incidencia', N'Vw_TipoIncidencia'),
    (818, N'Concepto_Fijo', N'Vw_ConceptoFijo'),
    (819, N'Tipo_Justificacion', N'Vw_TipoJustificacion'),
    (820, N'Tabulador', N'Vw_ConceptoTabular'),
    (821, N'Unidad_Infonavit', N'Vw_UnidadInfonavit'),
    (822, N'Salario_Minimo', N'Vw_SalarioMinimo'),
    (823, N'Forma_Pago', N'Vw_FormaPago'),
    (824, N'Forma_Calculo', N'Vw_FormaCalculo'),
    (825, N'Capitulos', N'Vw_CapituloNomina'),
    (831, N'Periodo_Semanal', N'Vw_PeriodoSemanal'),
    (832, N'Periodo_Quincenal', N'Vw_PeriodoQuincenal'),
    (833, N'Periodo_Mensual', N'Vw_PeriodoMensual'),
    (834, N'Periodo_Bimestral', N'Vw_PeriodoBimestral'),
    (841, N'Tabla_ISR_Semanal', N'Vw_TablaISRSemanal'),
    (842, N'Tabla_ISR_Quincenal', N'Vw_TablaISRQuincenal'),
    (843, N'Tabla_ISR_Mensual', N'Vw_TablaISRMensual'),
    (861, N'Subsidio_ISR_Semanal', N'Vw_SubsidioISRSemanal'),
    (862, N'Subsidio_ISR_Quincenal', N'Vw_SubsidioISRQuincenal'),
    (863, N'Subsidio_ISR_Mensual', N'Vw_SubsidioISRMensual'),
    (871, N'Base_Gravable', N'Vw_BaseGravable'),
    (872, N'Impuestos_Locales', N'Vw_ImpuestoLocal'),
    (881, N'Prestaciones_Minimas', N'Vw_PrestacionesMinimas'),
    (882, N'Clase_IMSS', N'Vw_ClaseIMSS'),
    (883, N'Fraccion_IMSS', N'Vw_FraccionIMSS'),
    (884, N'Base_Gravable_IMSS', N'Vw_BaseGravableIMSS'),
    (901, N'Plazas_Autorizadas', N'Vw_PlazaAutorizada'),
    (902, N'Universo', N'Vw_Universo'),
    (903, N'Nivel', N'Vw_Nivel'),
    (904, N'Sexo', N'Vw_Sexo'),
    (905, N'Estado_Civil', N'Vw_EstadoCivil'),
    (906, N'Escolaridad', N'Vw_Escolaridad'),
    (907, N'Tipo_Parentesco', N'Vw_TipoParentesco'),
    (908, N'Estado', N'Vw_Estado'),
    (909, N'Banco', N'Vw_NOM_Banco'),
    (910, N'Municipio', N'Vw_Municipio'),
    (911, N'Contratos', N'Vw_ContratoLaboral'),
    (912, N'Base_Pago', N'Vw_BasePago'),
    (913, N'Metodo_Pago', N'Vw_MetodoPago'),
    (914, N'Tipo_Regimen', N'Vw_TipoRegimen'),
    (915, N'Base_Cotizacion', N'Vw_BaseCotizacion'),
    (916, N'Zona_Geografica', N'Vw_ZonaGeografica'),
    (917, N'Dia_Semana', N'Vw_DiaSemana');

IF EXISTS
(
    SELECT 1
    FROM #MenuVistaNomina AS mapa
    WHERE OBJECT_ID(N'NOM.' + QUOTENAME(mapa.Vista), N'V') IS NULL
)
BEGIN
    SELECT
        mapa.PKIdMenu,
        mapa.LegacyName,
        mapa.Vista
    FROM #MenuVistaNomina AS mapa
    WHERE OBJECT_ID(N'NOM.' + QUOTENAME(mapa.Vista), N'V') IS NULL;

    THROW 51000, 'Existen menus de Nomina sin su vista unica.', 1;
END;

SELECT
    mapa.PKIdMenu,
    mapa.LegacyName,
    N'NOM.' + QUOTENAME(mapa.Vista) AS Vista
FROM #MenuVistaNomina AS mapa
ORDER BY mapa.PKIdMenu;

DROP TABLE #MenuVistaNomina;

PRINT N'Vistas unicas de catalogos de Nomina/RH creadas correctamente.';
