USE [GestionEmpresarial];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

/*
    Convencion objetivo
    -------------------
    PK constraint : PK_<Tabla>
    PK columna    : PKId<Entidad> (las PK compuestas pueden usar FKId*)
    FK constraint : FK_<TablaOrigen>_<TablaDestinoORol>
    FK columna    : FKId<EntidadORol>_<EsquemaDestino>
    Vista         : <Esquema>.Vw_<Entidad>

    Uso recomendado
    ---------------
    1. El archivo viene listo para aplicar constraints y vistas con ALIAS.
    2. ALIAS crea el nombre canonico sin romper consumidores que aun usan el
       nombre anterior.
    3. Los nombres de columnas son un cambio rompiente. Actualizar primero
       vistas, procedimientos, EF y codigo; despues habilitar ese bloque.

    La estrategia RENAME para vistas requiere confirmar cambios rompientes.
    ALIAS es la estrategia de transicion recomendada.
*/

DECLARE @AplicarConstraints bit = 1;
DECLARE @AplicarVistas bit = 1;
DECLARE @EstrategiaVistas varchar(10) = 'ALIAS'; -- ALIAS | RENAME
DECLARE @AplicarColumnas bit = 0;
DECLARE @ConfirmarCambiosRompientes bit = 0;

IF DB_NAME() <> N'GestionEmpresarial'
    THROW 50000, 'Este script solo debe ejecutarse en GestionEmpresarial.', 1;

SET @EstrategiaVistas = UPPER(@EstrategiaVistas);

IF @EstrategiaVistas NOT IN ('ALIAS', 'RENAME')
    THROW 50001, 'Estrategia de vistas invalida. Use ALIAS o RENAME.', 1;

IF @AplicarColumnas = 1 AND @ConfirmarCambiosRompientes = 0
    THROW 50002, 'Para renombrar columnas active @ConfirmarCambiosRompientes.', 1;

IF @AplicarVistas = 1
   AND @EstrategiaVistas = 'RENAME'
   AND @ConfirmarCambiosRompientes = 0
    THROW 50003, 'RENAME de vistas requiere @ConfirmarCambiosRompientes.', 1;

DROP TABLE IF EXISTS #Acciones;
DROP TABLE IF EXISTS #Hallazgos;

CREATE TABLE #Acciones
(
    Id int IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    Categoria varchar(30) NOT NULL,
    Esquema sysname NOT NULL,
    Objeto sysname NOT NULL,
    NombreActual sysname NOT NULL,
    NombreObjetivo sysname NULL,
    Estado varchar(30) NOT NULL,
    Riesgo varchar(10) NOT NULL,
    Dependencias int NOT NULL CONSTRAINT DF_Acciones_Dependencias DEFAULT (0),
    Comando nvarchar(max) NULL,
    Nota nvarchar(2000) NULL
);

CREATE TABLE #Hallazgos
(
    Id int IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    Categoria varchar(40) NOT NULL,
    Severidad varchar(10) NOT NULL,
    Esquema sysname NULL,
    Objeto sysname NULL,
    Elemento sysname NULL,
    Detalle nvarchar(2000) NOT NULL
);

/* PK constraints: PK_<Tabla>. */
;WITH Inventario AS
(
    SELECT
        kc.object_id,
        s.schema_id,
        s.name AS Esquema,
        t.name AS Tabla,
        kc.name AS NombreActual,
        CONVERT(sysname, N'PK_' + t.name) AS NombreObjetivo
    FROM sys.key_constraints kc
    INNER JOIN sys.tables t ON t.object_id = kc.parent_object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    WHERE kc.type = 'PK'
      AND t.is_ms_shipped = 0
), Acciones AS
(
    SELECT
        i.*,
        colision.object_id AS IdColision
    FROM Inventario i
    OUTER APPLY
    (
        SELECT TOP (1) o.object_id
        FROM sys.objects o
        WHERE o.schema_id = i.schema_id
          AND o.name = i.NombreObjetivo
          AND o.object_id <> i.object_id
    ) colision
    WHERE i.NombreActual COLLATE Latin1_General_100_BIN2
       <> i.NombreObjetivo COLLATE Latin1_General_100_BIN2
)
INSERT #Acciones
(
    Categoria, Esquema, Objeto, NombreActual, NombreObjetivo,
    Estado, Riesgo, Dependencias, Comando, Nota
)
SELECT
    'PK_CONSTRAINT',
    a.Esquema,
    a.Tabla,
    a.NombreActual,
    a.NombreObjetivo,
    CASE
        WHEN LEN(a.NombreObjetivo) > 128 THEN 'BLOQUEADO_LONGITUD'
        WHEN a.IdColision IS NOT NULL THEN 'BLOQUEADO_COLISION'
        ELSE 'LISTO'
    END,
    'BAJO',
    0,
    CASE
        WHEN LEN(a.NombreObjetivo) <= 128 AND a.IdColision IS NULL THEN
            N'EXEC sys.sp_rename N' + NCHAR(39)
            + REPLACE(
                QUOTENAME(a.Esquema) + N'.' + QUOTENAME(a.NombreActual),
                NCHAR(39), NCHAR(39) + NCHAR(39)
              )
            + NCHAR(39) + N', N' + NCHAR(39)
            + REPLACE(a.NombreObjetivo, NCHAR(39), NCHAR(39) + NCHAR(39))
            + NCHAR(39) + N', N' + NCHAR(39) + N'OBJECT' + NCHAR(39) + N';'
    END,
    N'Renombre de constraint; no modifica datos ni columnas.'
FROM Acciones a;

/* FK constraints: FK_<TablaOrigen>_<TablaDestinoORol>. */
;WITH Base AS
(
    SELECT
        fk.object_id,
        ps.schema_id,
        ps.name AS Esquema,
        pt.name AS Tabla,
        rt.name AS TablaDestino,
        fk.name AS NombreActual,
        CONVERT(sysname,
            CASE
                WHEN fk.name LIKE N'FK_' + ps.name + N'_' + pt.name + N'[_]%'
                    THEN N'FK_' + pt.name + N'_'
                         + SUBSTRING(
                             fk.name,
                             LEN(N'FK_' + ps.name + N'_' + pt.name + N'_') + 1,
                             128
                         )
                WHEN fk.name LIKE N'CONSTRAINT_FK_' + pt.name + N'[_]%'
                    THEN N'FK_' + pt.name + N'_'
                         + SUBSTRING(
                             fk.name,
                             LEN(N'CONSTRAINT_FK_' + pt.name + N'_') + 1,
                             128
                         )
                WHEN fk.name LIKE N'FK_' + pt.name + N'[_]%'
                    THEN fk.name
                ELSE N'FK_' + pt.name + N'_' + rt.name
            END
        ) AS NombreObjetivo
    FROM sys.foreign_keys fk
    INNER JOIN sys.tables pt ON pt.object_id = fk.parent_object_id
    INNER JOIN sys.schemas ps ON ps.schema_id = pt.schema_id
    INNER JOIN sys.tables rt ON rt.object_id = fk.referenced_object_id
    WHERE pt.is_ms_shipped = 0
), Acciones AS
(
    SELECT
        b.*,
        colision.object_id AS IdColision
    FROM Base b
    OUTER APPLY
    (
        SELECT TOP (1) o.object_id
        FROM sys.objects o
        WHERE o.schema_id = b.schema_id
          AND o.name = b.NombreObjetivo
          AND o.object_id <> b.object_id
    ) colision
    WHERE b.NombreActual COLLATE Latin1_General_100_BIN2
       <> b.NombreObjetivo COLLATE Latin1_General_100_BIN2
)
INSERT #Acciones
(
    Categoria, Esquema, Objeto, NombreActual, NombreObjetivo,
    Estado, Riesgo, Dependencias, Comando, Nota
)
SELECT
    'FK_CONSTRAINT',
    a.Esquema,
    a.Tabla,
    a.NombreActual,
    a.NombreObjetivo,
    CASE
        WHEN LEN(a.NombreObjetivo) > 128 THEN 'BLOQUEADO_LONGITUD'
        WHEN a.IdColision IS NOT NULL THEN 'BLOQUEADO_COLISION'
        ELSE 'LISTO'
    END,
    'BAJO',
    0,
    CASE
        WHEN LEN(a.NombreObjetivo) <= 128 AND a.IdColision IS NULL THEN
            N'EXEC sys.sp_rename N' + NCHAR(39)
            + REPLACE(
                QUOTENAME(a.Esquema) + N'.' + QUOTENAME(a.NombreActual),
                NCHAR(39), NCHAR(39) + NCHAR(39)
              )
            + NCHAR(39) + N', N' + NCHAR(39)
            + REPLACE(a.NombreObjetivo, NCHAR(39), NCHAR(39) + NCHAR(39))
            + NCHAR(39) + N', N' + NCHAR(39) + N'OBJECT' + NCHAR(39) + N';'
    END,
    N'Renombre de constraint; conserva el rol existente cuando esta expresado en el nombre.'
FROM Acciones a;

/*
   PK columns: solo corrige variantes mecanicas PK_Id, Pk_Id, Pkid y PkId.
   No fuerza que el sufijo sea igual al nombre de tabla porque existen entidades
   deliberadamente singulares sobre tablas plurales y PK compartidas.
*/
;WITH Inventario AS
(
    SELECT
        t.object_id,
        c.column_id,
        s.name AS Esquema,
        t.name AS Tabla,
        c.name AS NombreActual,
        COUNT(*) OVER (PARTITION BY t.object_id) AS ColumnasPK,
        CONVERT(sysname,
            CASE
                WHEN LEFT(c.name, 5) COLLATE Latin1_General_100_CI_AI = N'PK_ID'
                    THEN N'PKId' + SUBSTRING(c.name, 6, 128)
                WHEN LEFT(c.name, 4) COLLATE Latin1_General_100_CI_AI = N'PKID'
                    THEN N'PKId' + SUBSTRING(c.name, 5, 128)
            END
        ) AS NombreObjetivo
    FROM sys.key_constraints kc
    INNER JOIN sys.tables t ON t.object_id = kc.parent_object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.index_columns ic
        ON ic.object_id = t.object_id
       AND ic.index_id = kc.unique_index_id
    INNER JOIN sys.columns c
        ON c.object_id = t.object_id
       AND c.column_id = ic.column_id
    WHERE kc.type = 'PK'
      AND t.is_ms_shipped = 0
      AND s.name <> N'dbo'
), Acciones AS
(
    SELECT
        i.*,
        deps.Cantidad AS Dependencias,
        colision.column_id AS IdColision
    FROM Inventario i
    OUTER APPLY
    (
        SELECT COUNT(DISTINCT d.referencing_id) AS Cantidad
        FROM sys.sql_expression_dependencies d
        WHERE d.referenced_id = i.object_id
          AND d.referenced_minor_id = i.column_id
    ) deps
    OUTER APPLY
    (
        SELECT TOP (1) c2.column_id
        FROM sys.columns c2
        WHERE c2.object_id = i.object_id
          AND c2.name = i.NombreObjetivo
          AND c2.column_id <> i.column_id
    ) colision
    WHERE i.ColumnasPK = 1
      AND i.NombreObjetivo IS NOT NULL
      AND i.NombreActual COLLATE Latin1_General_100_BIN2
       <> i.NombreObjetivo COLLATE Latin1_General_100_BIN2
)
INSERT #Acciones
(
    Categoria, Esquema, Objeto, NombreActual, NombreObjetivo,
    Estado, Riesgo, Dependencias, Comando, Nota
)
SELECT
    'PK_COLUMNA',
    a.Esquema,
    a.Tabla,
    a.NombreActual,
    a.NombreObjetivo,
    CASE
        WHEN LEN(a.NombreObjetivo) > 128 THEN 'BLOQUEADO_LONGITUD'
        WHEN a.IdColision IS NOT NULL THEN 'BLOQUEADO_COLISION'
        WHEN @ConfirmarCambiosRompientes = 0 THEN 'BLOQUEADO_CONFIRMACION'
        ELSE 'LISTO'
    END,
    'ALTO',
    ISNULL(a.Dependencias, 0),
    N'EXEC sys.sp_rename N' + NCHAR(39)
        + REPLACE(
            QUOTENAME(a.Esquema) + N'.' + QUOTENAME(a.Tabla) + N'.' + QUOTENAME(a.NombreActual),
            NCHAR(39), NCHAR(39) + NCHAR(39)
          )
        + NCHAR(39) + N', N' + NCHAR(39)
        + REPLACE(a.NombreObjetivo, NCHAR(39), NCHAR(39) + NCHAR(39))
        + NCHAR(39) + N', N' + NCHAR(39) + N'COLUMN' + NCHAR(39) + N';',
    N'Cambio rompiente: actualizar SQL, EF, DTOs y consumidores externos.'
FROM Acciones a;

/*
   FK columns: normaliza prefijo y sufijo de esquema solo cuando el nombre ya
   representa una FK (FKId, FkId, Fkid o FK_Id). Los nombres de auditoria y los
   campos semanticos como UsuarioAutorizacion se conservan como excepciones.
*/
;WITH Inventario AS
(
    SELECT DISTINCT
        pt.object_id,
        pc.column_id,
        ps.name AS Esquema,
        pt.name AS Tabla,
        pc.name AS NombreActual,
        rs.name AS EsquemaDestino,
        rt.name AS TablaDestino,
        CASE
            WHEN LEFT(pc.name, 5) COLLATE Latin1_General_100_CI_AI = N'FK_ID'
                THEN N'FKId' + SUBSTRING(pc.name, 6, 128)
            WHEN LEFT(pc.name, 4) COLLATE Latin1_General_100_CI_AI = N'FKID'
                THEN N'FKId' + SUBSTRING(pc.name, 5, 128)
        END AS NombreBase
    FROM sys.foreign_keys fk
    INNER JOIN sys.tables pt ON pt.object_id = fk.parent_object_id
    INNER JOIN sys.schemas ps ON ps.schema_id = pt.schema_id
    INNER JOIN sys.tables rt ON rt.object_id = fk.referenced_object_id
    INNER JOIN sys.schemas rs ON rs.schema_id = rt.schema_id
    INNER JOIN sys.foreign_key_columns fkc
        ON fkc.constraint_object_id = fk.object_id
    INNER JOIN sys.columns pc
        ON pc.object_id = fkc.parent_object_id
       AND pc.column_id = fkc.parent_column_id
    WHERE pt.is_ms_shipped = 0
      AND ps.name <> N'dbo'
      AND pc.name NOT IN (N'UsuarioCreacion', N'UsuarioModificacion')
), UltimoToken AS
(
    SELECT
        i.*,
        CASE
            WHEN CHARINDEX(N'_', REVERSE(i.NombreBase)) > 0
                THEN RIGHT(i.NombreBase, CHARINDEX(N'_', REVERSE(i.NombreBase)) - 1)
        END AS SufijoActual
    FROM Inventario i
    WHERE i.NombreBase IS NOT NULL
), SinEsquemaAnterior AS
(
    SELECT
        u.*,
        CASE
            WHEN EXISTS
            (
                SELECT 1
                FROM sys.schemas sx
                WHERE sx.name COLLATE Latin1_General_100_CI_AI
                    = u.SufijoActual COLLATE Latin1_General_100_CI_AI
            )
                THEN LEFT(u.NombreBase, LEN(u.NombreBase) - LEN(u.SufijoActual) - 1)
            ELSE u.NombreBase
        END AS NombreSinEsquema
    FROM UltimoToken u
), Canonico AS
(
    SELECT
        s.*,
        CONVERT(sysname,
            LEFT(
                s.NombreSinEsquema,
                LEN(s.NombreSinEsquema)
                - CASE
                    WHEN PATINDEX(N'%[^_]%', REVERSE(s.NombreSinEsquema)) = 0
                        THEN LEN(s.NombreSinEsquema)
                    ELSE PATINDEX(N'%[^_]%', REVERSE(s.NombreSinEsquema)) - 1
                  END
            )
            + N'_' + s.EsquemaDestino
        ) AS NombreObjetivo
    FROM SinEsquemaAnterior s
), Acciones AS
(
    SELECT
        c.*,
        deps.Cantidad AS Dependencias,
        colision.column_id AS IdColision
    FROM Canonico c
    OUTER APPLY
    (
        SELECT COUNT(DISTINCT d.referencing_id) AS Cantidad
        FROM sys.sql_expression_dependencies d
        WHERE d.referenced_id = c.object_id
          AND d.referenced_minor_id = c.column_id
    ) deps
    OUTER APPLY
    (
        SELECT TOP (1) c2.column_id
        FROM sys.columns c2
        WHERE c2.object_id = c.object_id
          AND c2.name = c.NombreObjetivo
          AND c2.column_id <> c.column_id
    ) colision
    WHERE c.NombreActual COLLATE Latin1_General_100_BIN2
       <> c.NombreObjetivo COLLATE Latin1_General_100_BIN2
)
INSERT #Acciones
(
    Categoria, Esquema, Objeto, NombreActual, NombreObjetivo,
    Estado, Riesgo, Dependencias, Comando, Nota
)
SELECT
    'FK_COLUMNA',
    a.Esquema,
    a.Tabla,
    a.NombreActual,
    a.NombreObjetivo,
    CASE
        WHEN LEN(a.NombreObjetivo) > 128 THEN 'BLOQUEADO_LONGITUD'
        WHEN a.IdColision IS NOT NULL THEN 'BLOQUEADO_COLISION'
        WHEN @ConfirmarCambiosRompientes = 0 THEN 'BLOQUEADO_CONFIRMACION'
        ELSE 'LISTO'
    END,
    'ALTO',
    ISNULL(a.Dependencias, 0),
    N'EXEC sys.sp_rename N' + NCHAR(39)
        + REPLACE(
            QUOTENAME(a.Esquema) + N'.' + QUOTENAME(a.Tabla) + N'.' + QUOTENAME(a.NombreActual),
            NCHAR(39), NCHAR(39) + NCHAR(39)
          )
        + NCHAR(39) + N', N' + NCHAR(39)
        + REPLACE(a.NombreObjetivo, NCHAR(39), NCHAR(39) + NCHAR(39))
        + NCHAR(39) + N', N' + NCHAR(39) + N'COLUMN' + NCHAR(39) + N';',
    N'Referencia a ' + QUOTENAME(a.EsquemaDestino) + N'.' + QUOTENAME(a.TablaDestino)
        + N'. Cambio rompiente: actualizar SQL, EF y consumidores.'
FROM Acciones a;

/* FK columns que no siguen FKId* y requieren una decision semantica. */
INSERT #Hallazgos (Categoria, Severidad, Esquema, Objeto, Elemento, Detalle)
SELECT DISTINCT
    'FK_COLUMNA_EXCEPCION',
    'MEDIA',
    ps.name,
    pt.name,
    pc.name,
    N'FK activa hacia ' + QUOTENAME(rs.name) + N'.' + QUOTENAME(rt.name)
        + N', pero el nombre no sigue FKId*. Revisar manualmente.'
FROM sys.foreign_keys fk
INNER JOIN sys.tables pt ON pt.object_id = fk.parent_object_id
INNER JOIN sys.schemas ps ON ps.schema_id = pt.schema_id
INNER JOIN sys.tables rt ON rt.object_id = fk.referenced_object_id
INNER JOIN sys.schemas rs ON rs.schema_id = rt.schema_id
INNER JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
INNER JOIN sys.columns pc
    ON pc.object_id = fkc.parent_object_id
   AND pc.column_id = fkc.parent_column_id
WHERE pt.is_ms_shipped = 0
  AND ps.name <> N'dbo'
  AND pc.name NOT IN (N'UsuarioCreacion', N'UsuarioModificacion')
  AND LEFT(pc.name, 5) COLLATE Latin1_General_100_CI_AI <> N'FK_ID'
  AND LEFT(pc.name, 4) COLLATE Latin1_General_100_CI_AI <> N'FKID';

/* Views: <Esquema>.Vw_<Entidad>. */
;WITH Inventario AS
(
    SELECT
        v.object_id,
        s.schema_id,
        s.name AS Esquema,
        v.name AS NombreActual,
        CONVERT(sysname,
            CASE
                WHEN v.name COLLATE Latin1_General_100_BIN2 LIKE N'Vw[_]%'
                    THEN v.name
                WHEN v.name COLLATE Latin1_General_100_CI_AI LIKE N'vw[_]%'
                    THEN N'Vw_' + SUBSTRING(v.name, 4, 128)
                WHEN v.name COLLATE Latin1_General_100_CI_AI LIKE N'vw%'
                    THEN N'Vw_' + SUBSTRING(v.name, 3, 128)
            END
        ) AS NombreObjetivo
    FROM sys.views v
    INNER JOIN sys.schemas s ON s.schema_id = v.schema_id
    WHERE v.is_ms_shipped = 0
), Acciones AS
(
    SELECT
        i.*,
        target.object_id AS IdObjetivo,
        deps.Cantidad AS Dependencias,
        CASE
            WHEN i.NombreObjetivo IS NOT NULL
             AND i.NombreActual COLLATE Latin1_General_100_CI_AI
               = i.NombreObjetivo COLLATE Latin1_General_100_CI_AI
                THEN 1 ELSE 0
        END AS SoloMayusculas
    FROM Inventario i
    OUTER APPLY
    (
        SELECT TOP (1) v2.object_id
        FROM sys.views v2
        WHERE v2.schema_id = i.schema_id
          AND v2.name = i.NombreObjetivo
    ) target
    OUTER APPLY
    (
        SELECT COUNT(DISTINCT d.referencing_id) AS Cantidad
        FROM sys.sql_expression_dependencies d
        WHERE d.referenced_id = i.object_id
    ) deps
    WHERE i.NombreObjetivo IS NULL
       OR i.NombreActual COLLATE Latin1_General_100_BIN2
       <> i.NombreObjetivo COLLATE Latin1_General_100_BIN2
)
INSERT #Acciones
(
    Categoria, Esquema, Objeto, NombreActual, NombreObjetivo,
    Estado, Riesgo, Dependencias, Comando, Nota
)
SELECT
    'VISTA',
    a.Esquema,
    a.NombreActual,
    a.NombreActual,
    a.NombreObjetivo,
    CASE
        WHEN a.NombreObjetivo IS NULL THEN 'REVISION_MANUAL'
        WHEN LEN(a.NombreObjetivo) > 128 THEN 'BLOQUEADO_LONGITUD'
        WHEN a.IdObjetivo IS NOT NULL AND a.IdObjetivo <> a.object_id THEN 'BLOQUEADO_COLISION'
        WHEN @EstrategiaVistas = 'RENAME'
         AND a.SoloMayusculas = 0
         AND @ConfirmarCambiosRompientes = 0 THEN 'BLOQUEADO_CONFIRMACION'
        ELSE 'LISTO'
    END,
    CASE
        WHEN a.SoloMayusculas = 1 THEN 'BAJO'
        WHEN @EstrategiaVistas = 'ALIAS' THEN 'BAJO'
        ELSE 'ALTO'
    END,
    ISNULL(a.Dependencias, 0),
    CASE
        WHEN a.NombreObjetivo IS NULL THEN NULL
        WHEN LEN(a.NombreObjetivo) > 128 THEN NULL
        WHEN a.IdObjetivo IS NOT NULL AND a.IdObjetivo <> a.object_id THEN NULL
        WHEN a.SoloMayusculas = 1 THEN
            N'EXEC sys.sp_rename N' + NCHAR(39)
            + REPLACE(
                QUOTENAME(a.Esquema) + N'.' + QUOTENAME(a.NombreActual),
                NCHAR(39), NCHAR(39) + NCHAR(39)
              )
            + NCHAR(39) + N', N' + NCHAR(39)
            + N'__norm_' + CONVERT(nvarchar(20), a.object_id)
            + NCHAR(39) + N', N' + NCHAR(39) + N'OBJECT' + NCHAR(39) + N'; '
            + N'EXEC sys.sp_rename N' + NCHAR(39)
            + REPLACE(
                QUOTENAME(a.Esquema) + N'.'
                    + QUOTENAME(N'__norm_' + CONVERT(nvarchar(20), a.object_id)),
                NCHAR(39), NCHAR(39) + NCHAR(39)
              )
            + NCHAR(39) + N', N' + NCHAR(39)
            + REPLACE(a.NombreObjetivo, NCHAR(39), NCHAR(39) + NCHAR(39))
            + NCHAR(39) + N', N' + NCHAR(39) + N'OBJECT' + NCHAR(39) + N';'
        WHEN @EstrategiaVistas = 'ALIAS' THEN
            N'EXEC sys.sp_executesql N' + NCHAR(39)
            + REPLACE(
                N'CREATE VIEW '
                + QUOTENAME(a.Esquema) + N'.' + QUOTENAME(a.NombreObjetivo)
                + N' AS SELECT * FROM '
                + QUOTENAME(a.Esquema) + N'.' + QUOTENAME(a.NombreActual)
                + N';',
                NCHAR(39), NCHAR(39) + NCHAR(39)
              )
            + NCHAR(39) + N';'
        WHEN @ConfirmarCambiosRompientes = 1 THEN
            N'EXEC sys.sp_rename N' + NCHAR(39)
            + REPLACE(
                QUOTENAME(a.Esquema) + N'.' + QUOTENAME(a.NombreActual),
                NCHAR(39), NCHAR(39) + NCHAR(39)
              )
            + NCHAR(39) + N', N' + NCHAR(39)
            + REPLACE(a.NombreObjetivo, NCHAR(39), NCHAR(39) + NCHAR(39))
            + NCHAR(39) + N', N' + NCHAR(39) + N'OBJECT' + NCHAR(39) + N';'
    END,
    CASE
        WHEN a.IdObjetivo IS NOT NULL AND a.IdObjetivo <> a.object_id
            THEN N'Ya existe la vista objetivo; comparar definiciones y consolidar manualmente.'
        WHEN a.SoloMayusculas = 1
            THEN N'Ajuste de capitalizacion mediante nombre temporal.'
        WHEN @EstrategiaVistas = 'ALIAS'
            THEN N'Crea una vista canonica de compatibilidad y conserva el nombre anterior.'
        ELSE N'Renombre estricto; actualizar dependencias internas y consumidores externos.'
    END
FROM Acciones a;

/* Columnas que parecen FK pero no tienen constraint. No se crean automaticamente. */
INSERT #Hallazgos (Categoria, Severidad, Esquema, Objeto, Elemento, Detalle)
SELECT
    'FK_SIN_CONSTRAINT',
    'ALTA',
    s.name,
    t.name,
    c.name,
    N'La columna parece FK pero no participa en sys.foreign_key_columns. '
      + N'Definir destino, revisar huerfanos y crear la FK con WITH CHECK.'
FROM sys.tables t
INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
INNER JOIN sys.columns c ON c.object_id = t.object_id
WHERE t.is_ms_shipped = 0
  AND s.name <> N'dbo'
  AND c.name COLLATE Latin1_General_100_CI_AI LIKE N'FK%Id%'
  AND NOT EXISTS
  (
      SELECT 1
      FROM sys.foreign_key_columns fkc
      WHERE fkc.parent_object_id = t.object_id
        AND fkc.parent_column_id = c.column_id
  );

/* Integridad adicional. */
INSERT #Hallazgos (Categoria, Severidad, Esquema, Objeto, Elemento, Detalle)
SELECT
    'TABLA_SIN_PK',
    'ALTA',
    s.name,
    t.name,
    NULL,
    N'La tabla no tiene primary key.'
FROM sys.tables t
INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE t.is_ms_shipped = 0
  AND NOT EXISTS
  (
      SELECT 1
      FROM sys.key_constraints kc
      WHERE kc.parent_object_id = t.object_id
        AND kc.type = 'PK'
  );

INSERT #Hallazgos (Categoria, Severidad, Esquema, Objeto, Elemento, Detalle)
SELECT
    'FK_NO_CONFIABLE',
    'ALTA',
    s.name,
    t.name,
    fk.name,
    CASE
        WHEN fk.is_disabled = 1 AND fk.is_not_trusted = 1 THEN N'FK deshabilitada y no confiable.'
        WHEN fk.is_disabled = 1 THEN N'FK deshabilitada.'
        ELSE N'FK no confiable; validar con WITH CHECK CHECK CONSTRAINT.'
    END
FROM sys.foreign_keys fk
INNER JOIN sys.tables t ON t.object_id = fk.parent_object_id
INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE t.is_ms_shipped = 0
  AND (fk.is_disabled = 1 OR fk.is_not_trusted = 1);

/* Resumen y detalle de la vista previa. */
SELECT
    Categoria,
    Estado,
    Riesgo,
    COUNT(*) AS Cantidad
FROM #Acciones
GROUP BY Categoria, Estado, Riesgo
ORDER BY Categoria, Estado, Riesgo;

SELECT
    Id,
    Categoria,
    Esquema,
    Objeto,
    NombreActual,
    NombreObjetivo,
    Estado,
    Riesgo,
    Dependencias,
    Nota,
    Comando
FROM #Acciones
ORDER BY
    CASE Categoria
        WHEN 'PK_CONSTRAINT' THEN 1
        WHEN 'FK_CONSTRAINT' THEN 2
        WHEN 'PK_COLUMNA' THEN 3
        WHEN 'FK_COLUMNA' THEN 4
        WHEN 'VISTA' THEN 5
        ELSE 9
    END,
    Esquema,
    Objeto,
    NombreActual;

SELECT
    Categoria,
    Severidad,
    COUNT(*) AS Cantidad
FROM #Hallazgos
GROUP BY Categoria, Severidad
ORDER BY Severidad DESC, Categoria;

SELECT
    Id,
    Categoria,
    Severidad,
    Esquema,
    Objeto,
    Elemento,
    Detalle
FROM #Hallazgos
ORDER BY Categoria, Esquema, Objeto, Elemento;

/* Aplicacion atomica de las categorias habilitadas. */
DECLARE @Lote nvarchar(max);

SELECT @Lote = STRING_AGG(CONVERT(nvarchar(max), a.Comando), CHAR(13) + CHAR(10))
    WITHIN GROUP (ORDER BY a.Id)
FROM #Acciones a
WHERE a.Estado = 'LISTO'
  AND a.Comando IS NOT NULL
  AND
  (
      (@AplicarConstraints = 1 AND a.Categoria IN ('PK_CONSTRAINT', 'FK_CONSTRAINT'))
      OR (@AplicarVistas = 1 AND a.Categoria = 'VISTA')
      OR (@AplicarColumnas = 1 AND a.Categoria IN ('PK_COLUMNA', 'FK_COLUMNA'))
  );

IF NULLIF(@Lote, N'') IS NULL
BEGIN
    PRINT N'Modo diagnostico: no se aplicaron cambios.';
END
ELSE
BEGIN TRY
    BEGIN TRANSACTION;
    EXEC sys.sp_executesql @Lote;
    COMMIT TRANSACTION;
    PRINT N'Cambios aplicados correctamente.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
