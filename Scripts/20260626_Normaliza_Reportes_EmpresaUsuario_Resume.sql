USE [GestionEmpresarial];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
SET XACT_ABORT ON;
GO

/*
    Resume del cambio de reportes.

    Reglas:
      - Sin acentos ni caracteres fuera de ASCII en nombres canonicos nuevos.
      - No toca codigo C#.
      - No elimina objetos heredados con nombres no ASCII hasta que se ajuste el codigo.
      - Es idempotente: se puede ejecutar mas de una vez.
*/

BEGIN TRY
    BEGIN TRANSACTION;

    PRINT N'Normalizando vista base de saldos';

    DECLARE @SaldoObjectId int = OBJECT_ID(N'[CONTA].[SaldoInicialBalanzaComprobacion]');
    DECLARE @SaldoObjectType char(2) = (
        SELECT [type]
        FROM sys.objects
        WHERE object_id = @SaldoObjectId
    );

    IF @SaldoObjectId IS NULL
    BEGIN
        THROW 51000, N'No existe CONTA.SaldoInicialBalanzaComprobacion.', 1;
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
    END
    ELSE
    BEGIN
        THROW 51001, N'CONTA.SaldoInicialBalanzaComprobacion debe ser tabla o vista.', 1;
    END;

    PRINT N'Creando nombre canonico sin acento para reporte de almacen';

    DECLARE
        @CanonicalAlmacenName sysname = N'SPR_AlmacendeMateriales',
        @SourceAlmacenObjectId int,
        @SourceAlmacenName sysname,
        @AlmacenDefinition nvarchar(max);

    SELECT TOP (1)
        @SourceAlmacenObjectId = p.object_id,
        @SourceAlmacenName = p.[name]
    FROM sys.procedures AS p
    WHERE SCHEMA_NAME(p.schema_id) = N'CONTA'
      AND
      (
          p.[name] = @CanonicalAlmacenName
          OR
          (
              p.[name] LIKE N'SPR_Almac%ndeMateriales'
              AND p.[name] COLLATE Latin1_General_BIN2 LIKE N'%[^ -~]%'
          )
      )
    ORDER BY
        CASE WHEN p.[name] = @CanonicalAlmacenName THEN 0 ELSE 1 END,
        p.modify_date DESC;

    IF @SourceAlmacenObjectId IS NOT NULL
    BEGIN
        SET @AlmacenDefinition = OBJECT_DEFINITION(@SourceAlmacenObjectId);
        SET @AlmacenDefinition = REPLACE(@AlmacenDefinition, CHAR(13), N'');
        SET @AlmacenDefinition = REPLACE(@AlmacenDefinition, QUOTENAME(@SourceAlmacenName), QUOTENAME(@CanonicalAlmacenName));
        SET @AlmacenDefinition = STUFF(@AlmacenDefinition, CHARINDEX(N'CREATE', UPPER(@AlmacenDefinition)), LEN(N'CREATE'), N'CREATE OR ALTER');

        EXEC sys.sp_executesql @AlmacenDefinition;
    END;

    PRINT N'Actualizando modulos restantes';

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
        CASE
            WHEN CHARINDEX(N'FK_IdCuentacuenta', m.[definition]) > 0
              OR CHARINDEX(N'SIS.TipoCuenta', m.[definition] COLLATE Latin1_General_CI_AS) > 0
              OR CHARINDEX(N'[SIS].[TipoCuenta]', m.[definition] COLLATE Latin1_General_CI_AS) > 0
              OR CHARINDEX(N'PK_IdTipoCuenta', m.[definition]) > 0
              OR CHARINDEX(N'SaldosInicialesBalanzaComprobacion', m.[definition] COLLATE Latin1_General_CI_AS) > 0
            THEN 1 ELSE 0
        END,
        CASE
            WHEN o.[type] = 'P'
             AND s.[name] = N'CONTA'
             AND o.[name] LIKE N'SPR[_]%'
             AND o.[name] COLLATE Latin1_General_BIN2 NOT LIKE N'%[^ -~]%'
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
          CHARINDEX(N'FK_IdCuentacuenta', m.[definition]) > 0
          OR CHARINDEX(N'SIS.TipoCuenta', m.[definition] COLLATE Latin1_General_CI_AS) > 0
          OR CHARINDEX(N'[SIS].[TipoCuenta]', m.[definition] COLLATE Latin1_General_CI_AS) > 0
          OR CHARINDEX(N'PK_IdTipoCuenta', m.[definition]) > 0
          OR CHARINDEX(N'SaldosInicialesBalanzaComprobacion', m.[definition] COLLATE Latin1_General_CI_AS) > 0
          OR
          (
              o.[type] = 'P'
              AND s.[name] = N'CONTA'
              AND o.[name] LIKE N'SPR[_]%'
              AND o.[name] COLLATE Latin1_General_BIN2 NOT LIKE N'%[^ -~]%'
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
        @CleanLine nvarchar(max),
        @ParamLines nvarchar(max),
        @ParamBlock nvarchar(max),
        @BeforeAs nvarchar(max),
        @TrimBeforeAs nvarchar(max),
        @CloseParenPos int,
        @ReverseCloseParenOffset int,
        @LastLineStart int,
        @LastLine nvarchar(max),
        @UseClosingParamParen bit,
        @InsertPos int,
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
            PRINT N'Se omitio un modulo sin definicion legible.';
        END
        ELSE
        BEGIN
            SET @Definition = REPLACE(@Definition, CHAR(13), N'');

            IF @NeedsAlias = 1
            BEGIN
                SET @Definition = REPLACE(@Definition COLLATE Latin1_General_CI_AS, N'[SIS].[TipoCuenta]', N'[CONTA].[TipoCuenta]');
                SET @Definition = REPLACE(@Definition COLLATE Latin1_General_CI_AS, N'SIS.TipoCuenta', N'CONTA.TipoCuenta');
                SET @Definition = REPLACE(@Definition, N'FK_IdCuentacuenta', N'FKIdCuentaContable');
                SET @Definition = REPLACE(@Definition, N'PK_IdTipoCuenta', N'PKIdTipoCuenta');
                SET @Definition = REPLACE(@Definition COLLATE Latin1_General_CI_AS, N'select SaldoFinal from conta.SaldosInicialesBalanzaComprobacion', N'select SUM(SaldoFinal) from conta.SaldoInicialBalanzaComprobacion');
                SET @Definition = REPLACE(@Definition COLLATE Latin1_General_CI_AS, N'SELECT SaldoFinal FROM [CONTA].[SaldosInicialesBalanzaComprobacion]', N'SELECT SUM(SaldoFinal) FROM [CONTA].[SaldoInicialBalanzaComprobacion]');
                SET @Definition = REPLACE(@Definition COLLATE Latin1_General_CI_AS, N'SaldosInicialesBalanzaComprobacion', N'SaldoInicialBalanzaComprobacion');
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
                    SET @CleanLine = UPPER(REPLACE(REPLACE(REPLACE(@Line, NCHAR(9), N''), N' ', N''), N';', N''));

                    IF @CleanLine = N'AS'
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
                SET @TrimBeforeAs = RTRIM(REPLACE(@BeforeAs, NCHAR(9), N' '));
                WHILE LEN(@TrimBeforeAs) > 0
                  AND RIGHT(@TrimBeforeAs, 1) IN (N' ', NCHAR(9), CHAR(10))
                BEGIN
                    SET @TrimBeforeAs = LEFT(@TrimBeforeAs, LEN(@TrimBeforeAs) - 1);
                END;
                SET @ReverseCloseParenOffset = CHARINDEX(N')', REVERSE(@BeforeAs));
                SET @CloseParenPos = CASE
                    WHEN @ReverseCloseParenOffset > 0
                    THEN LEN(@BeforeAs) - @ReverseCloseParenOffset + 1
                    ELSE 0
                END;
                SET @LastLineStart = CASE
                    WHEN CHARINDEX(CHAR(10), REVERSE(@TrimBeforeAs)) > 0
                    THEN LEN(@TrimBeforeAs) - CHARINDEX(CHAR(10), REVERSE(@TrimBeforeAs)) + 2
                    ELSE 1
                END;
                SET @LastLine = LTRIM(RTRIM(SUBSTRING(@TrimBeforeAs, @LastLineStart, LEN(@TrimBeforeAs))));
                SET @UseClosingParamParen = CASE WHEN @LastLine = N')' THEN 1 ELSE 0 END;

                IF @ExistingParamCount = 0
                BEGIN
                    SET @ParamBlock = CHAR(10) + @ParamLines + CHAR(10);
                END
                ELSE
                BEGIN
                    SET @ParamBlock = N',' + CHAR(10) + @ParamLines + CHAR(10);
                END;

                IF @CloseParenPos > 0
                   AND SUBSTRING(@Definition, @CloseParenPos, 1) = N')'
                   AND @UseClosingParamParen = 1
                BEGIN
                    SET @Definition = STUFF(@Definition, @CloseParenPos, 0, @ParamBlock);
                END
                ELSE
                BEGIN
                    SET @InsertPos = LEN(RTRIM(@BeforeAs)) + 1;
                    SET @Definition = STUFF(@Definition, @InsertPos, 0, @ParamBlock);
                END;
            END;

            PRINT N'Actualizando modulo';
            EXEC sys.sp_executesql @Definition;
        END;

        FETCH NEXT FROM ModuleCursor
        INTO @ObjectId, @SchemaName, @ObjectName, @ObjectType, @NeedsAlias, @NeedsReportParams, @NeedsIdEmpresa, @NeedsIdEmpleado, @ExistingParamCount;
    END;

    CLOSE ModuleCursor;
    DEALLOCATE ModuleCursor;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF CURSOR_STATUS('local', 'ModuleCursor') >= 0
    BEGIN
        CLOSE ModuleCursor;
    END;

    IF CURSOR_STATUS('local', 'ModuleCursor') > -3
    BEGIN
        DEALLOCATE ModuleCursor;
    END;

    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;

    THROW;
END CATCH;
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

PRINT N'Reportes CONTA.SPR_% sin parametros de empresa o empleado';
SELECT
    p.[name] AS procedure_name,
    MAX(CASE WHEN prm.[name] = N'@IdEmpresa' THEN 1 ELSE 0 END) AS has_IdEmpresa,
    MAX(CASE WHEN prm.[name] = N'@IdEmpleado' THEN 1 ELSE 0 END) AS has_IdEmpleado
FROM sys.procedures AS p
LEFT JOIN sys.parameters AS prm ON prm.object_id = p.object_id
WHERE SCHEMA_NAME(p.schema_id) = N'CONTA'
  AND p.[name] LIKE N'SPR[_]%'
  AND p.[name] COLLATE Latin1_General_BIN2 NOT LIKE N'%[^ -~]%'
GROUP BY p.[name]
HAVING MAX(CASE WHEN prm.[name] = N'@IdEmpresa' THEN 1 ELSE 0 END) = 0
    OR MAX(CASE WHEN prm.[name] = N'@IdEmpleado' THEN 1 ELSE 0 END) = 0
ORDER BY p.[name];
GO

PRINT N'Objetos CONTA con nombres no ASCII pendientes de retirar en la parte de codigo';
SELECT
    o.[name] AS object_name,
    o.[type_desc]
FROM sys.objects AS o
WHERE SCHEMA_NAME(o.schema_id) = N'CONTA'
  AND o.[name] COLLATE Latin1_General_BIN2 LIKE N'%[^ -~]%'
ORDER BY o.[name];
GO

PRINT N'Modulos con nombres viejos de TipoCuenta o saldos pendientes';
SELECT
    SCHEMA_NAME(o.schema_id) AS schema_name,
    o.[name] AS object_name,
    o.[type_desc]
FROM sys.sql_modules AS m
INNER JOIN sys.objects AS o ON o.object_id = m.object_id
WHERE CHARINDEX(N'SIS.TipoCuenta', m.[definition] COLLATE Latin1_General_CI_AS) > 0
   OR CHARINDEX(N'[SIS].[TipoCuenta]', m.[definition] COLLATE Latin1_General_CI_AS) > 0
   OR CHARINDEX(N'PK_IdTipoCuenta', m.[definition]) > 0
   OR CHARINDEX(N'FK_IdCuentacuenta', m.[definition]) > 0
   OR CHARINDEX(N'SaldosInicialesBalanzaComprobacion', m.[definition] COLLATE Latin1_General_CI_AS) > 0
ORDER BY schema_name, object_name;
GO
