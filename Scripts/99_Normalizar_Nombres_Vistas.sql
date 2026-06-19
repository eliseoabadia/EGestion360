USE [GestionEmpresarial];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

/*
    Normaliza todas las vistas al formato:

        [Esquema].[Vw_Entidad]

    Ejemplos:
        [NOM].[VwTipoNomina]       -> [NOM].[Vw_TipoNomina]
        [NOM].[VW_Empleado]        -> [NOM].[Vw_Empleado]
        [NOM].[TipoNomina]         -> [NOM].[Vw_TipoNomina]

    Excepcion semantica conocida:
        [NOM].[VW_ContratoLaboral] -> [NOM].[Vw_ContratoLaboralDetalle]

    Si la vista objetivo ya existe y solamente envuelve a la vista antigua,
    ambas se consolidan conservando la implementacion de la vista antigua.

    Uso:
        1. Ejecute con @AplicarCambios = 0 para revisar el plan.
        2. Resuelva los registros BLOQUEADO_COLISION o REVISION_MANUAL.
        3. Cambie @AplicarCambios a 1 y vuelva a ejecutar.

    Este es un cambio estricto: no crea alias ni sinonimos. El script reescribe
    las referencias de modulos SQL; despues se deben regenerar los modelos con
    EF Core Power Tools y actualizar los consumidores externos.
*/

DECLARE @AplicarCambios bit = 0;
DECLARE @Esquema sysname = NULL; -- NULL = todos; ejemplo: N'NOM'

IF DB_NAME() <> N'GestionEmpresarial'
    THROW 51000, 'Este script solo debe ejecutarse en GestionEmpresarial.', 1;

IF @Esquema IS NOT NULL AND SCHEMA_ID(@Esquema) IS NULL
    THROW 51001, 'El esquema indicado no existe.', 1;

DROP TABLE IF EXISTS #PlanVistas;

CREATE TABLE #PlanVistas
(
    Id int IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    ObjectId int NOT NULL,
    Esquema sysname NOT NULL,
    NombreActual sysname NOT NULL,
    NombreObjetivo nvarchar(260) NOT NULL,
    Dependencias int NOT NULL,
    Estado varchar(40) NOT NULL,
    Nota nvarchar(1000) NULL
);

;WITH Base AS
(
    SELECT
        v.object_id,
        s.name AS Esquema,
        v.name AS NombreActual,
        v.create_date AS FechaCreacion,
        CONVERT(nvarchar(260),
            CASE
                WHEN s.name = N'NOM'
                 AND v.name COLLATE Latin1_General_100_BIN2 = N'VW_ContratoLaboral'
                    THEN N'Vw_ContratoLaboralDetalle'
                WHEN LEFT(v.name, 3) COLLATE Latin1_General_100_CI_AI = N'Vw_'
                    THEN N'Vw_' + SUBSTRING(v.name, 4, 128)
                WHEN LEFT(v.name, 2) COLLATE Latin1_General_100_CI_AI = N'Vw'
                    THEN N'Vw_' + SUBSTRING(v.name, 3, 128)
                ELSE N'Vw_' + v.name
            END
        ) AS NombreObjetivo
    FROM sys.views v
    INNER JOIN sys.schemas s ON s.schema_id = v.schema_id
    WHERE v.is_ms_shipped = 0
      AND (@Esquema IS NULL OR s.name = @Esquema)
), AntiguedadEsquema AS
(
    SELECT
        b.Esquema,
        b.NombreObjetivo COLLATE Latin1_General_100_BIN2 AS NombreObjetivo,
        MIN(b.FechaCreacion) AS PrimeraCreacion
    FROM Base b
    GROUP BY
        b.Esquema,
        b.NombreObjetivo COLLATE Latin1_General_100_BIN2
), PrioridadEsquema AS
(
    SELECT
        a.*,
        COUNT(*) OVER
        (
            PARTITION BY a.NombreObjetivo COLLATE Latin1_General_100_BIN2
        ) AS CantidadEsquemas,
        ROW_NUMBER() OVER
        (
            PARTITION BY a.NombreObjetivo COLLATE Latin1_General_100_BIN2
            ORDER BY a.PrimeraCreacion, a.Esquema
        ) AS OrdenAntiguedad
    FROM AntiguedadEsquema a
), Inventario AS
(
    SELECT
        b.object_id,
        b.Esquema,
        b.NombreActual,
        b.FechaCreacion,
        CONVERT(nvarchar(260),
            CASE
                WHEN p.CantidadEsquemas > 1 AND p.OrdenAntiguedad > 1
                    THEN N'Vw_' + b.Esquema + N'_'
                       + SUBSTRING(b.NombreObjetivo, 4, 257)
                ELSE b.NombreObjetivo
            END
        ) AS NombreObjetivo
    FROM Base b
    INNER JOIN PrioridadEsquema p
        ON p.Esquema = b.Esquema
       AND p.NombreObjetivo COLLATE Latin1_General_100_BIN2
         = b.NombreObjetivo COLLATE Latin1_General_100_BIN2
), Evaluacion AS
(
    SELECT
        i.*,
        deps.Cantidad AS Dependencias,
        destino.object_id AS ObjectIdDestino,
        destino.DestinoReferenciaOrigen,
        duplicados.Cantidad AS ObjetivosIguales
    FROM Inventario i
    OUTER APPLY
    (
        SELECT COUNT(DISTINCT d.referencing_id) AS Cantidad
        FROM sys.sql_expression_dependencies d
        WHERE d.referenced_id = i.object_id
    ) deps
    OUTER APPLY
    (
        SELECT
            o.object_id,
            CONVERT(bit,
                CASE WHEN EXISTS
                (
                    SELECT 1
                    FROM sys.sql_expression_dependencies d
                    WHERE d.referencing_id = o.object_id
                      AND d.referenced_id = i.object_id
                ) THEN 1 ELSE 0 END
            ) AS DestinoReferenciaOrigen
        FROM sys.objects o
        INNER JOIN sys.schemas os ON os.schema_id = o.schema_id
        WHERE os.name = i.Esquema
          AND o.name COLLATE Latin1_General_100_BIN2
            = i.NombreObjetivo COLLATE Latin1_General_100_BIN2
    ) destino
    OUTER APPLY
    (
        SELECT COUNT(*) AS Cantidad
        FROM Inventario i2
        WHERE i2.Esquema = i.Esquema
          AND i2.NombreObjetivo COLLATE Latin1_General_100_BIN2
            = i.NombreObjetivo COLLATE Latin1_General_100_BIN2
    ) duplicados
)
INSERT INTO #PlanVistas
(
    ObjectId,
    Esquema,
    NombreActual,
    NombreObjetivo,
    Dependencias,
    Estado,
    Nota
)
SELECT
    e.object_id,
    e.Esquema,
    e.NombreActual,
    e.NombreObjetivo,
    ISNULL(e.Dependencias, 0),
    CASE
        WHEN e.NombreActual COLLATE Latin1_General_100_BIN2
           = e.NombreObjetivo COLLATE Latin1_General_100_BIN2
            THEN 'YA_NORMALIZADA'
        WHEN LEN(e.NombreObjetivo) > 128
            THEN 'BLOQUEADO_LONGITUD'
        WHEN e.NombreObjetivo = N'Vw_'
            THEN 'REVISION_MANUAL'
        WHEN e.ObjectIdDestino IS NOT NULL
         AND e.ObjectIdDestino <> e.object_id
         AND e.DestinoReferenciaOrigen = 1
            THEN 'LISTO_CONSOLIDAR'
        WHEN e.ObjetivosIguales > 1
            THEN 'BLOQUEADO_DUPLICADO'
        WHEN e.ObjectIdDestino IS NOT NULL
         AND e.ObjectIdDestino <> e.object_id
            THEN 'BLOQUEADO_COLISION'
        ELSE 'LISTO'
    END,
    CASE
        WHEN e.NombreActual COLLATE Latin1_General_100_BIN2
           = e.NombreObjetivo COLLATE Latin1_General_100_BIN2
            THEN N'La vista ya cumple [Esquema].[Vw_Entidad].'
        WHEN e.ObjectIdDestino IS NOT NULL
         AND e.ObjectIdDestino <> e.object_id
         AND e.DestinoReferenciaOrigen = 1
            THEN N'La vista objetivo envuelve a la anterior; se consolidaran en un solo objeto.'
        WHEN e.ObjetivosIguales > 1
            THEN N'Mas de una vista genera el mismo nombre objetivo.'
        WHEN e.ObjectIdDestino IS NOT NULL
         AND e.ObjectIdDestino <> e.object_id
            THEN N'Ya existe otro objeto con el nombre objetivo.'
        ELSE N'Se conservara el object_id, permisos y propiedades de la vista original.'
    END
FROM Evaluacion e;

/* Vista previa: este resultado debe revisarse antes de habilitar la ejecucion. */
SELECT
    Estado,
    COUNT(*) AS Cantidad
FROM #PlanVistas
GROUP BY Estado
ORDER BY Estado;

SELECT
    Id,
    Esquema,
    NombreActual,
    NombreObjetivo,
    Dependencias,
    Estado,
    Nota
FROM #PlanVistas
ORDER BY
    CASE Estado
        WHEN 'LISTO' THEN 1
        WHEN 'LISTO_CONSOLIDAR' THEN 2
        WHEN 'YA_NORMALIZADA' THEN 3
        ELSE 4
    END,
    Esquema,
    NombreActual;

IF @AplicarCambios = 0
BEGIN
    PRINT N'Modo vista previa: no se aplicaron cambios.';
    RETURN;
END;

IF EXISTS
(
    SELECT 1
    FROM #PlanVistas
    WHERE Estado IN
    (
        'BLOQUEADO_LONGITUD',
        'BLOQUEADO_DUPLICADO',
        'BLOQUEADO_COLISION',
        'REVISION_MANUAL'
    )
)
    THROW 51002, 'Existen vistas bloqueadas. Revise el plan antes de aplicar.', 1;

/*
    Conserva las definiciones actuales para actualizar referencias internas.
    Se excluyen las vistas envoltorio que seran eliminadas por consolidacion.
*/
DROP TABLE IF EXISTS #DefinicionesModulo;

CREATE TABLE #DefinicionesModulo
(
    ObjectId int NOT NULL PRIMARY KEY,
    Esquema sysname NOT NULL,
    Nombre sysname NOT NULL,
    Tipo char(2) NOT NULL,
    DefinicionOriginal nvarchar(max) NOT NULL,
    DefinicionNueva nvarchar(max) NOT NULL
);

INSERT INTO #DefinicionesModulo
(
    ObjectId,
    Esquema,
    Nombre,
    Tipo,
    DefinicionOriginal,
    DefinicionNueva
)
SELECT
    o.object_id,
    s.name,
    o.name,
    o.type,
    sm.definition,
    sm.definition
FROM sys.sql_modules sm
INNER JOIN sys.objects o ON o.object_id = sm.object_id
INNER JOIN sys.schemas s ON s.schema_id = o.schema_id
WHERE o.is_ms_shipped = 0
  AND o.type IN ('V', 'P', 'FN', 'IF', 'TF', 'TR')
  AND sm.definition IS NOT NULL
  AND NOT EXISTS
  (
      SELECT 1
      FROM #PlanVistas p
      INNER JOIN sys.objects destino
          ON destino.name COLLATE Latin1_General_100_BIN2
           = p.NombreObjetivo COLLATE Latin1_General_100_BIN2
      INNER JOIN sys.schemas sd ON sd.schema_id = destino.schema_id
      WHERE p.Estado = 'LISTO_CONSOLIDAR'
        AND sd.name = p.Esquema
        AND destino.object_id = o.object_id
  );

DECLARE
    @Id int,
    @ObjectId int,
    @SchemaName sysname,
    @OldName sysname,
    @NewName sysname,
    @TemporaryName sysname,
    @Sql nvarchar(max),
    @MismoNombreSegunCollation bit;

DECLARE vistas_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT
    Id,
    ObjectId,
    Esquema,
    NombreActual,
    CONVERT(sysname, NombreObjetivo)
FROM #PlanVistas
WHERE Estado IN ('LISTO', 'LISTO_CONSOLIDAR')
ORDER BY
    CASE
        WHEN Esquema = N'NOM'
         AND NombreActual COLLATE Latin1_General_100_BIN2 = N'VW_ContratoLaboral'
            THEN 0
        ELSE 1
    END,
    Id;

BEGIN TRY
    BEGIN TRANSACTION;

    OPEN vistas_cursor;
    FETCH NEXT FROM vistas_cursor
        INTO @Id, @ObjectId, @SchemaName, @OldName, @NewName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM #PlanVistas
            WHERE Id = @Id
              AND Estado = 'LISTO_CONSOLIDAR'
        )
        BEGIN
            SET @Sql = N'DROP VIEW '
                + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@NewName) + N';';
            EXEC sys.sp_executesql @Sql;
        END;

        SET @MismoNombreSegunCollation =
            CASE WHEN @OldName = @NewName THEN 1 ELSE 0 END;

        /*
            En collations no sensibles a mayusculas, un cambio como VW_X -> Vw_X
            necesita pasar primero por un nombre temporal.
        */
        IF @MismoNombreSegunCollation = 1
        BEGIN
            SET @TemporaryName = CONVERT(sysname, N'__VwNorm_' + CONVERT(nvarchar(20), @ObjectId));

            SET @Sql = N'EXEC sys.sp_rename N'''
                + REPLACE(QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@OldName), N'''', N'''''')
                + N''', N'''
                + REPLACE(@TemporaryName, N'''', N'''''')
                + N''', N''OBJECT'';';
            EXEC sys.sp_executesql @Sql;

            SET @Sql = N'EXEC sys.sp_rename N'''
                + REPLACE(QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TemporaryName), N'''', N'''''')
                + N''', N'''
                + REPLACE(@NewName, N'''', N'''''')
                + N''', N''OBJECT'';';
            EXEC sys.sp_executesql @Sql;
        END
        ELSE
        BEGIN
            SET @Sql = N'EXEC sys.sp_rename N'''
                + REPLACE(QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@OldName), N'''', N'''''')
                + N''', N'''
                + REPLACE(@NewName, N'''', N'''''')
                + N''', N''OBJECT'';';
            EXEC sys.sp_executesql @Sql;
        END;

        UPDATE #PlanVistas
        SET Estado = 'APLICADO'
        WHERE Id = @Id;

        FETCH NEXT FROM vistas_cursor
            INTO @Id, @ObjectId, @SchemaName, @OldName, @NewName;
    END;

    CLOSE vistas_cursor;
    DEALLOCATE vistas_cursor;

    /* Actualiza referencias y encabezados de vistas, SPs y funciones. */
    DECLARE referencias_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT
        Esquema,
        NombreActual,
        CONVERT(sysname, NombreObjetivo)
    FROM #PlanVistas
    WHERE Estado = 'APLICADO'
    ORDER BY LEN(NombreActual) DESC, Id;

    OPEN referencias_cursor;
    FETCH NEXT FROM referencias_cursor
        INTO @SchemaName, @OldName, @NewName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        UPDATE #DefinicionesModulo
        SET DefinicionNueva =
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
                DefinicionNueva,
                QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@OldName),
                QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@NewName)),
                @SchemaName + N'.' + QUOTENAME(@OldName),
                QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@NewName)),
                QUOTENAME(@SchemaName) + N'.' + @OldName,
                QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@NewName)),
                @SchemaName + N'.' + @OldName,
                QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@NewName));

        /* Referencias sin esquema: solo se sustituyen identificadores delimitados. */
        UPDATE #DefinicionesModulo
        SET DefinicionNueva = REPLACE(
                DefinicionNueva,
                QUOTENAME(@OldName),
                QUOTENAME(@NewName)
            )
        WHERE Esquema = @SchemaName;

        FETCH NEXT FROM referencias_cursor
            INTO @SchemaName, @OldName, @NewName;
    END;

    CLOSE referencias_cursor;
    DEALLOCATE referencias_cursor;

    DECLARE
        @ModuleObjectId int,
        @ModuleDefinition nvarchar(max);

    DECLARE modulos_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT ObjectId, DefinicionNueva
    FROM #DefinicionesModulo
    WHERE DefinicionNueva COLLATE Latin1_General_100_BIN2
       <> DefinicionOriginal COLLATE Latin1_General_100_BIN2
    ORDER BY
        CASE Tipo WHEN 'V' THEN 0 ELSE 1 END,
        Esquema,
        Nombre;

    OPEN modulos_cursor;
    FETCH NEXT FROM modulos_cursor INTO @ModuleObjectId, @ModuleDefinition;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @ModuleDefinition = REPLACE(@ModuleDefinition, N'CREATE OR ALTER VIEW', N'ALTER VIEW');
        SET @ModuleDefinition = REPLACE(@ModuleDefinition, N'CREATE    VIEW', N'ALTER VIEW');
        SET @ModuleDefinition = REPLACE(@ModuleDefinition, N'CREATE   VIEW', N'ALTER VIEW');
        SET @ModuleDefinition = REPLACE(@ModuleDefinition, N'CREATE  VIEW', N'ALTER VIEW');
        SET @ModuleDefinition = REPLACE(@ModuleDefinition, N'CREATE VIEW', N'ALTER VIEW');
        SET @ModuleDefinition = REPLACE(@ModuleDefinition, N'CREATE OR ALTER PROCEDURE', N'ALTER PROCEDURE');
        SET @ModuleDefinition = REPLACE(@ModuleDefinition, N'CREATE    PROCEDURE', N'ALTER PROCEDURE');
        SET @ModuleDefinition = REPLACE(@ModuleDefinition, N'CREATE   PROCEDURE', N'ALTER PROCEDURE');
        SET @ModuleDefinition = REPLACE(@ModuleDefinition, N'CREATE  PROCEDURE', N'ALTER PROCEDURE');
        SET @ModuleDefinition = REPLACE(@ModuleDefinition, N'CREATE PROCEDURE', N'ALTER PROCEDURE');
        SET @ModuleDefinition = REPLACE(@ModuleDefinition, N'CREATE OR ALTER PROC', N'ALTER PROC');
        SET @ModuleDefinition = REPLACE(@ModuleDefinition, N'CREATE PROC', N'ALTER PROC');
        SET @ModuleDefinition = REPLACE(@ModuleDefinition, N'CREATE OR ALTER FUNCTION', N'ALTER FUNCTION');
        SET @ModuleDefinition = REPLACE(@ModuleDefinition, N'CREATE FUNCTION', N'ALTER FUNCTION');
        SET @ModuleDefinition = REPLACE(@ModuleDefinition, N'CREATE OR ALTER TRIGGER', N'ALTER TRIGGER');
        SET @ModuleDefinition = REPLACE(@ModuleDefinition, N'CREATE TRIGGER', N'ALTER TRIGGER');

        EXEC sys.sp_executesql @ModuleDefinition;
        FETCH NEXT FROM modulos_cursor INTO @ModuleObjectId, @ModuleDefinition;
    END;

    CLOSE modulos_cursor;
    DEALLOCATE modulos_cursor;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF CURSOR_STATUS('local', 'vistas_cursor') >= 0
        CLOSE vistas_cursor;
    IF CURSOR_STATUS('local', 'vistas_cursor') > -3
        DEALLOCATE vistas_cursor;
    IF CURSOR_STATUS('local', 'referencias_cursor') >= 0
        CLOSE referencias_cursor;
    IF CURSOR_STATUS('local', 'referencias_cursor') > -3
        DEALLOCATE referencias_cursor;
    IF CURSOR_STATUS('local', 'modulos_cursor') >= 0
        CLOSE modulos_cursor;
    IF CURSOR_STATUS('local', 'modulos_cursor') > -3
        DEALLOCATE modulos_cursor;

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

SELECT
    Esquema,
    NombreActual,
    NombreObjetivo,
    Estado
FROM #PlanVistas
WHERE Estado = 'APLICADO'
ORDER BY Esquema, NombreObjetivo;

PRINT N'Normalizacion de vistas terminada correctamente.';
GO
