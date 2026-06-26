USE [GestionEmpresarial];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
SET XACT_ABORT ON;
GO

/*
    Fix puntual para errores de reportes CONTA por nombres viejos.

    Corrige en modulos SQL:
      - SIS.TipoCuenta -> CONTA.TipoCuenta
      - [SIS].[TipoCuenta] -> [CONTA].[TipoCuenta]
      - PK_IdTipoCuenta -> PKIdTipoCuenta
      - FK_IdCuentacuenta -> FKIdCuentaContable
      - SaldosInicialesBalanzaComprobacion -> SaldoInicialBalanzaComprobacion

    Nota:
      - La tabla plural anterior no existe en GestionEmpresarial.
      - Al reemplazarla por la vista singular, las lecturas escalares usan SUM(SaldoFinal)
        porque la vista regresa una fila por cuenta contable.
*/

DECLARE @Targets table
(
    RowId int IDENTITY(1, 1) NOT NULL,
    ObjectId int NOT NULL,
    SchemaName sysname NOT NULL,
    ObjectName sysname NOT NULL,
    ObjectType char(2) NOT NULL
);

INSERT INTO @Targets (ObjectId, SchemaName, ObjectName, ObjectType)
SELECT
    o.object_id,
    SCHEMA_NAME(o.schema_id),
    o.[name],
    o.[type]
FROM sys.sql_modules AS m
INNER JOIN sys.objects AS o ON o.object_id = m.object_id
WHERE o.[type] IN ('P', 'V', 'IF', 'TF', 'FN')
  AND
  (
      CHARINDEX(N'SIS.TipoCuenta', m.[definition] COLLATE Latin1_General_CI_AS) > 0
      OR CHARINDEX(N'[SIS].[TipoCuenta]', m.[definition] COLLATE Latin1_General_CI_AS) > 0
      OR CHARINDEX(N'PK_IdTipoCuenta', m.[definition]) > 0
      OR CHARINDEX(N'FK_IdCuentacuenta', m.[definition]) > 0
      OR CHARINDEX(N'SaldosInicialesBalanzaComprobacion', m.[definition] COLLATE Latin1_General_CI_AS) > 0
  );

DECLARE
    @ObjectId int,
    @SchemaName sysname,
    @ObjectName sysname,
    @ObjectType char(2),
    @Definition nvarchar(max),
    @Upper nvarchar(max),
    @CreatePos int,
    @KeywordPos int,
    @SearchPos int,
    @Candidate int,
    @AfterCreatePos int,
    @ErrorMessage nvarchar(2048);

DECLARE FixCursor CURSOR LOCAL FAST_FORWARD FOR
SELECT ObjectId, SchemaName, ObjectName, ObjectType
FROM @Targets
ORDER BY SchemaName, ObjectName;

OPEN FixCursor;

FETCH NEXT FROM FixCursor
INTO @ObjectId, @SchemaName, @ObjectName, @ObjectType;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Definition = OBJECT_DEFINITION(@ObjectId);

    IF @Definition IS NOT NULL
    BEGIN
        SET @Definition = REPLACE(@Definition, CHAR(13), N'');

        SET @Definition = REPLACE(@Definition COLLATE Latin1_General_CI_AS, N'[SIS].[TipoCuenta]', N'[CONTA].[TipoCuenta]');
        SET @Definition = REPLACE(@Definition COLLATE Latin1_General_CI_AS, N'SIS.TipoCuenta', N'CONTA.TipoCuenta');
        SET @Definition = REPLACE(@Definition, N'FK_IdCuentacuenta', N'FKIdCuentaContable');
        SET @Definition = REPLACE(@Definition, N'PK_IdTipoCuenta', N'PKIdTipoCuenta');

        SET @Definition = REPLACE(@Definition COLLATE Latin1_General_CI_AS,
            N'select SaldoFinal from conta.SaldosInicialesBalanzaComprobacion',
            N'select SUM(SaldoFinal) from conta.SaldoInicialBalanzaComprobacion');
        SET @Definition = REPLACE(@Definition COLLATE Latin1_General_CI_AS,
            N'SELECT SaldoFinal FROM [CONTA].[SaldosInicialesBalanzaComprobacion]',
            N'SELECT SUM(SaldoFinal) FROM [CONTA].[SaldoInicialBalanzaComprobacion]');
        SET @Definition = REPLACE(@Definition COLLATE Latin1_General_CI_AS,
            N'SaldosInicialesBalanzaComprobacion',
            N'SaldoInicialBalanzaComprobacion');

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

            IF (@ObjectType = 'P' AND (SUBSTRING(@Upper, @AfterCreatePos, LEN(N'PROCEDURE')) = N'PROCEDURE' OR SUBSTRING(@Upper, @AfterCreatePos, LEN(N'PROC')) = N'PROC'))
               OR (@ObjectType = 'V' AND SUBSTRING(@Upper, @AfterCreatePos, LEN(N'VIEW')) = N'VIEW')
               OR (@ObjectType IN ('IF', 'TF', 'FN') AND SUBSTRING(@Upper, @AfterCreatePos, LEN(N'FUNCTION')) = N'FUNCTION')
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
            THROW 51010, @ErrorMessage, 1;
        END;

        SET @Definition = STUFF(@Definition, @CreatePos, @KeywordPos - @CreatePos, N'CREATE OR ALTER ');

        PRINT N'Actualizando ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@ObjectName);
        EXEC sys.sp_executesql @Definition;
    END;

    FETCH NEXT FROM FixCursor
    INTO @ObjectId, @SchemaName, @ObjectName, @ObjectType;
END;

CLOSE FixCursor;
DEALLOCATE FixCursor;
GO

PRINT N'Modulos pendientes con nombres viejos';
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
