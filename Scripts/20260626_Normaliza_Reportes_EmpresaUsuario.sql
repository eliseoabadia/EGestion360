USE [GestionEmpresarial];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
SET XACT_ABORT ON;
GO

/*
    Parte 1 - Base de datos solamente.

    Objetivo:
      1. Normalizar [CONTA].[SaldoInicialBalanzaComprobacion] para exponer/usar
         FKIdCuentaContable en lugar del alias heredado FK_IdCuentacuenta.
      2. Actualizar modulos que todavia referencian FK_IdCuentacuenta.
      3. Agregar @IdEmpresa y @IdEmpleado como parametros opcionales a los
         reportes [CONTA].[SPR_%] que aun no los tienen.

    Nota:
      - Este script no cambia codigo C#.
      - La logica de filtro por empresa se hara reporte por reporte en la
        segunda parte; aqui solo se normaliza el contrato de BD.
*/

PRINT N'Normalizando [CONTA].[SaldoInicialBalanzaComprobacion]';

DECLARE @SaldoObjectId int = OBJECT_ID(N'[CONTA].[SaldoInicialBalanzaComprobacion]');
DECLARE @SaldoObjectType char(2) = (
    SELECT [type]
    FROM sys.objects
    WHERE object_id = @SaldoObjectId
);

IF @SaldoObjectId IS NULL
BEGIN
    THROW 51000, N'No existe [CONTA].[SaldoInicialBalanzaComprobacion].', 1;
END;

IF @SaldoObjectType = 'V'
BEGIN
    DECLARE @CreateSaldoViewSql nvarchar(max) = N'
CREATE OR ALTER VIEW [CONTA].[SaldoInicialBalanzaComprobacion]
AS
SELECT
    sm.[FKIdCuentaContable] AS [FKIdCuentaContable],
    cc.[ClaveOrd] AS [NoCuenta],
    sm.[FKIdAnio_SIS],
    sm.[FKIdMes_SIS],
    sm.[SaldoInicial],
    sm.[Cargos],
    sm.[Abonos],
    sm.[SaldoFinal]
FROM [CONTA].[SaldoMensual] AS sm
INNER JOIN [CONTA].[CuentaContable] AS cc ON cc.[PKIdCuentaContable] = sm.[FKIdCuentaContable]
WHERE sm.[Activo] = 1
  AND cc.[Activo] = 1;
';

    EXEC sys.sp_executesql @CreateSaldoViewSql;
END
ELSE IF @SaldoObjectType = 'U'
BEGIN
    IF COL_LENGTH(N'[CONTA].[SaldoInicialBalanzaComprobacion]', N'FK_IdCuentacuenta') IS NOT NULL
       AND COL_LENGTH(N'[CONTA].[SaldoInicialBalanzaComprobacion]', N'FKIdCuentaContable') IS NULL
    BEGIN
        EXEC sys.sp_rename
            @objname = N'[CONTA].[SaldoInicialBalanzaComprobacion].[FK_IdCuentacuenta]',
            @newname = N'FKIdCuentaContable',
            @objtype = N'COLUMN';
    END;

    DECLARE @NewFkName sysname = N'FK_SaldoInicialBalanzaComprobacion_CuentaContable';
    DECLARE @CurrentFkName sysname;

    SELECT TOP (1)
        @CurrentFkName = fk.[name]
    FROM sys.foreign_keys AS fk
    INNER JOIN sys.foreign_key_columns AS fkc ON fkc.constraint_object_id = fk.object_id
    WHERE fk.parent_object_id = @SaldoObjectId
      AND COL_NAME(fkc.parent_object_id, fkc.parent_column_id) = N'FKIdCuentaContable'
      AND OBJECT_NAME(fkc.referenced_object_id) = N'CuentaContable'
    ORDER BY fk.[name];

    IF @CurrentFkName IS NOT NULL
       AND @CurrentFkName <> @NewFkName
       AND NOT EXISTS
       (
           SELECT 1
           FROM sys.foreign_keys
           WHERE parent_object_id = @SaldoObjectId
             AND [name] = @NewFkName
       )
    BEGIN
        DECLARE @CurrentFkObjectName nvarchar(300) = QUOTENAME(N'CONTA') + N'.' + QUOTENAME(@CurrentFkName);

        EXEC sys.sp_rename
            @objname = @CurrentFkObjectName,
            @newname = @NewFkName,
            @objtype = N'OBJECT';
    END;
END
ELSE
BEGIN
    THROW 51001, N'[CONTA].[SaldoInicialBalanzaComprobacion] debe ser tabla o vista.', 1;
END;
GO

PRINT N'Actualizando referencias y parametros de reportes CONTA.SPR_%';

DECLARE @Targets table
(
    RowId int IDENTITY(1, 1) NOT NULL,
    ObjectId int NOT NULL,
    SchemaName sysname NOT NULL,
    ObjectName sysname NOT NULL,
    ObjectType char(2) NOT NULL,
    NeedsAlias bit NOT NULL,
    NeedsReportParams bit NOT NULL,
    NeedsIdEmpresa bit NOT NULL,
    NeedsIdEmpleado bit NOT NULL,
    ExistingParamCount int NOT NULL
);

INSERT INTO @Targets
(
    ObjectId,
    SchemaName,
    ObjectName,
    ObjectType,
    NeedsAlias,
    NeedsReportParams,
    NeedsIdEmpresa,
    NeedsIdEmpleado,
    ExistingParamCount
)
SELECT
    o.object_id,
    s.[name],
    o.[name],
    o.[type],
    CASE WHEN m.[definition] LIKE N'%FK[_]IdCuentacuenta%' THEN 1 ELSE 0 END,
    CASE
        WHEN o.[type] = 'P'
         AND s.[name] = N'CONTA'
         AND o.[name] LIKE N'SPR[_]%'
         AND
         (
             NOT EXISTS
             (
                 SELECT 1
                 FROM sys.parameters AS p
                 WHERE p.object_id = o.object_id
                   AND p.[name] = N'@IdEmpresa'
             )
             OR NOT EXISTS
             (
                 SELECT 1
                 FROM sys.parameters AS p
                 WHERE p.object_id = o.object_id
                   AND p.[name] = N'@IdEmpleado'
             )
         )
        THEN 1 ELSE 0
    END,
    CASE
        WHEN NOT EXISTS
        (
            SELECT 1
            FROM sys.parameters AS p
            WHERE p.object_id = o.object_id
              AND p.[name] = N'@IdEmpresa'
        )
        THEN 1 ELSE 0
    END,
    CASE
        WHEN NOT EXISTS
        (
            SELECT 1
            FROM sys.parameters AS p
            WHERE p.object_id = o.object_id
              AND p.[name] = N'@IdEmpleado'
        )
        THEN 1 ELSE 0
    END,
    (
        SELECT COUNT(1)
        FROM sys.parameters AS p
        WHERE p.object_id = o.object_id
          AND p.parameter_id > 0
    )
FROM sys.objects AS o
INNER JOIN sys.schemas AS s ON s.schema_id = o.schema_id
INNER JOIN sys.sql_modules AS m ON m.object_id = o.object_id
WHERE o.[type] IN ('P', 'V')
  AND
  (
      m.[definition] LIKE N'%FK[_]IdCuentacuenta%'
      OR
      (
          o.[type] = 'P'
          AND s.[name] = N'CONTA'
          AND o.[name] LIKE N'SPR[_]%'
          AND
          (
              NOT EXISTS
              (
                  SELECT 1
                  FROM sys.parameters AS p
                  WHERE p.object_id = o.object_id
                    AND p.[name] = N'@IdEmpresa'
              )
              OR NOT EXISTS
              (
                  SELECT 1
                  FROM sys.parameters AS p
                  WHERE p.object_id = o.object_id
                    AND p.[name] = N'@IdEmpleado'
              )
          )
      )
  )
  AND NOT (s.[name] = N'CONTA' AND o.[name] = N'SaldoInicialBalanzaComprobacion');

DECLARE
    @ObjectId int,
    @SchemaName sysname,
    @ObjectName sysname,
    @ObjectType char(2),
    @NeedsAlias bit,
    @NeedsReportParams bit,
    @NeedsIdEmpresa bit,
    @NeedsIdEmpleado bit,
    @ExistingParamCount int,
    @Definition nvarchar(max),
    @Upper nvarchar(max),
    @CreatePos int,
    @KeywordPos int,
    @SearchPos int,
    @Candidate int,
    @AfterCreatePos int,
    @AsPos int,
    @ScanPos int,
    @LineEnd int,
    @Line nvarchar(max),
    @ParamLines nvarchar(max),
    @ParamBlock nvarchar(max),
    @BeforeAs nvarchar(max),
    @TrimBeforeAs nvarchar(max),
    @CloseParenPos int,
    @ErrorMessage nvarchar(2048);

DECLARE ModuleCursor CURSOR LOCAL FAST_FORWARD FOR
SELECT
    ObjectId,
    SchemaName,
    ObjectName,
    ObjectType,
    NeedsAlias,
    NeedsReportParams,
    NeedsIdEmpresa,
    NeedsIdEmpleado,
    ExistingParamCount
FROM @Targets
ORDER BY SchemaName, ObjectName;

OPEN ModuleCursor;

FETCH NEXT FROM ModuleCursor
INTO @ObjectId, @SchemaName, @ObjectName, @ObjectType, @NeedsAlias, @NeedsReportParams, @NeedsIdEmpresa, @NeedsIdEmpleado, @ExistingParamCount;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Definition = OBJECT_DEFINITION(@ObjectId);

    IF @Definition IS NULL
    BEGIN
        PRINT N'Se omitio modulo sin definicion legible: ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@ObjectName);
    END
    ELSE
    BEGIN
        SET @Definition = REPLACE(@Definition, CHAR(13), N'');

        IF @NeedsAlias = 1
        BEGIN
            SET @Definition = REPLACE(@Definition, N'FK_IdCuentacuenta', N'FKIdCuentaContable');
        END;

        SET @Upper = UPPER(@Definition);
        SET @CreatePos = 0;
        SET @KeywordPos = 0;
        SET @SearchPos = 1;

        WHILE @SearchPos <= LEN(@Upper)
        BEGIN
            SET @Candidate = CHARINDEX(N'CREATE', @Upper, @SearchPos);

            IF @Candidate = 0
                BREAK;

            SET @AfterCreatePos = @Candidate + LEN(N'CREATE');

            WHILE @AfterCreatePos <= LEN(@Upper)
              AND SUBSTRING(@Upper, @AfterCreatePos, 1) IN (N' ', NCHAR(9), NCHAR(10))
            BEGIN
                SET @AfterCreatePos += 1;
            END;

            IF SUBSTRING(@Upper, @AfterCreatePos, LEN(N'OR ALTER')) = N'OR ALTER'
            BEGIN
                SET @AfterCreatePos += LEN(N'OR ALTER');

                WHILE @AfterCreatePos <= LEN(@Upper)
                  AND SUBSTRING(@Upper, @AfterCreatePos, 1) IN (N' ', NCHAR(9), NCHAR(10))
                BEGIN
                    SET @AfterCreatePos += 1;
                END;
            END;

            IF @ObjectType = 'P'
               AND
               (
                   SUBSTRING(@Upper, @AfterCreatePos, LEN(N'PROCEDURE')) = N'PROCEDURE'
                   OR SUBSTRING(@Upper, @AfterCreatePos, LEN(N'PROC')) = N'PROC'
               )
            BEGIN
                SET @CreatePos = @Candidate;
                SET @KeywordPos = @AfterCreatePos;
                BREAK;
            END;

            IF @ObjectType = 'V'
               AND SUBSTRING(@Upper, @AfterCreatePos, LEN(N'VIEW')) = N'VIEW'
            BEGIN
                SET @CreatePos = @Candidate;
                SET @KeywordPos = @AfterCreatePos;
                BREAK;
            END;

            SET @SearchPos = @Candidate + LEN(N'CREATE');
        END;

        IF @CreatePos = 0 OR @KeywordPos = 0
        BEGIN
            SET @ErrorMessage = N'No se pudo ubicar CREATE en ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@ObjectName) + N'.';
            THROW 51002, @ErrorMessage, 1;
        END;

        SET @Definition = STUFF(@Definition, @CreatePos, @KeywordPos - @CreatePos, N'CREATE OR ALTER ');

        IF @NeedsReportParams = 1
        BEGIN
            SET @ParamLines = N'';

            IF @NeedsIdEmpresa = 1
            BEGIN
                SET @ParamLines = N'    @IdEmpresa INT = NULL';
            END;

            IF @NeedsIdEmpleado = 1
            BEGIN
                SET @ParamLines = @ParamLines
                    + CASE WHEN @ParamLines = N'' THEN N'' ELSE N',' + CHAR(10) END
                    + N'    @IdEmpleado INT = NULL';
            END;

            IF @ExistingParamCount = 0
            BEGIN
                SET @ParamBlock = CHAR(10) + @ParamLines + CHAR(10);
            END
            ELSE
            BEGIN
                SET @ParamBlock = N',' + CHAR(10) + @ParamLines + CHAR(10);
            END;

            SET @AsPos = 0;
            SET @ScanPos = @CreatePos;

            WHILE @ScanPos <= LEN(@Definition)
            BEGIN
                SET @LineEnd = CHARINDEX(CHAR(10), @Definition, @ScanPos);

                IF @LineEnd = 0
                BEGIN
                    SET @LineEnd = LEN(@Definition) + 1;
                END;

                SET @Line = SUBSTRING(@Definition, @ScanPos, @LineEnd - @ScanPos);

                IF UPPER(LTRIM(RTRIM(@Line))) = N'AS'
                BEGIN
                    SET @AsPos = @ScanPos;
                    BREAK;
                END;

                SET @ScanPos = @LineEnd + 1;
            END;

            IF @AsPos = 0
            BEGIN
                SET @ErrorMessage = N'No se pudo ubicar AS en ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@ObjectName) + N'.';
                THROW 51003, @ErrorMessage, 1;
            END;

            SET @BeforeAs = LEFT(@Definition, @AsPos - 1);
            SET @TrimBeforeAs = RTRIM(@BeforeAs);
            SET @CloseParenPos = LEN(@TrimBeforeAs);

            IF @CloseParenPos > 0
               AND SUBSTRING(@TrimBeforeAs, @CloseParenPos, 1) = N')'
            BEGIN
                SET @Definition = STUFF(@Definition, @CloseParenPos, 0, @ParamBlock);
            END
            ELSE
            BEGIN
                SET @Definition = STUFF(@Definition, @AsPos, 0, @ParamBlock);
            END;
        END;

        PRINT N'Actualizando ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@ObjectName);
        EXEC sys.sp_executesql @Definition;
    END;

    FETCH NEXT FROM ModuleCursor
    INTO @ObjectId, @SchemaName, @ObjectName, @ObjectType, @NeedsAlias, @NeedsReportParams, @NeedsIdEmpresa, @NeedsIdEmpleado, @ExistingParamCount;
END;

CLOSE ModuleCursor;
DEALLOCATE ModuleCursor;
GO

PRINT N'Revision de columna normalizada';
SELECT
    c.column_id,
    c.[name] AS column_name,
    TYPE_NAME(c.user_type_id) AS type_name
FROM sys.columns AS c
WHERE c.object_id = OBJECT_ID(N'[CONTA].[SaldoInicialBalanzaComprobacion]')
ORDER BY c.column_id;
GO

PRINT N'Reportes CONTA.SPR_% que aun no tienen @IdEmpresa o @IdEmpleado';
SELECT
    p.[name] AS procedure_name,
    MAX(CASE WHEN prm.[name] = N'@IdEmpresa' THEN 1 ELSE 0 END) AS has_IdEmpresa,
    MAX(CASE WHEN prm.[name] = N'@IdEmpleado' THEN 1 ELSE 0 END) AS has_IdEmpleado
FROM sys.procedures AS p
LEFT JOIN sys.parameters AS prm ON prm.object_id = p.object_id
WHERE SCHEMA_NAME(p.schema_id) = N'CONTA'
  AND p.[name] LIKE N'SPR[_]%'
GROUP BY p.[name]
HAVING MAX(CASE WHEN prm.[name] = N'@IdEmpresa' THEN 1 ELSE 0 END) = 0
    OR MAX(CASE WHEN prm.[name] = N'@IdEmpleado' THEN 1 ELSE 0 END) = 0
ORDER BY p.[name];
GO
