SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/*
    Consolida NOM.EmpresaNomina en SIS.Empresa.

    Mapeo autorizado para conservar los datos existentes:
      6 (Estructura)          -> 1 (IFT)
      7 (Eventual)            -> 1 (IFT)
      8 (Honorarios)          -> 2 (Grupo Constructor Delta)
      9 (Eventual Servicios)  -> 2 (Grupo Constructor Delta)

    El script:
      - agrega a SIS.Empresa los atributos exclusivos de nomina;
      - cambia todas las columnas NOM FKIdEmpresaNomina_NOM a FKIdEmpresa_SIS;
      - normaliza todos los FKIdEmpresa_SIS del esquema NOM;
      - actualiza vistas y procedimientos almacenados dependientes;
      - crea FKs contra SIS.Empresa y elimina NOM.EmpresaNomina.
*/

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'[SIS].[Empresa]', N'U') IS NULL
        THROW 51000, N'No existe SIS.Empresa.', 1;

    IF NOT EXISTS (SELECT 1 FROM [SIS].[Empresa] WHERE [PKIdEmpresa] = 1)
       OR NOT EXISTS (SELECT 1 FROM [SIS].[Empresa] WHERE [PKIdEmpresa] = 2)
        THROW 51001, N'Deben existir SIS.Empresa 1 (IFT) y 2 (Grupo Constructor Delta).', 1;

    IF COL_LENGTH(N'SIS.Empresa', N'RegIMSS') IS NULL
        ALTER TABLE [SIS].[Empresa] ADD [RegIMSS] nvarchar(25) NULL;
    IF COL_LENGTH(N'SIS.Empresa', N'RegInfonavit') IS NULL
        ALTER TABLE [SIS].[Empresa] ADD [RegInfonavit] nvarchar(25) NULL;
    IF COL_LENGTH(N'SIS.Empresa', N'CedEmpadronam') IS NULL
        ALTER TABLE [SIS].[Empresa] ADD [CedEmpadronam] nvarchar(25) NULL;
    IF COL_LENGTH(N'SIS.Empresa', N'NoFonacot') IS NULL
        ALTER TABLE [SIS].[Empresa] ADD [NoFonacot] nvarchar(25) NULL;
    IF COL_LENGTH(N'SIS.Empresa', N'UsAdmin') IS NULL
        ALTER TABLE [SIS].[Empresa] ADD [UsAdmin] nvarchar(100) NULL;
    IF COL_LENGTH(N'SIS.Empresa', N'EmailAdmin') IS NULL
        ALTER TABLE [SIS].[Empresa] ADD [EmailAdmin] nvarchar(100) NULL;
    IF COL_LENGTH(N'SIS.Empresa', N'FKIdPeriodoPago_SIS') IS NULL
        ALTER TABLE [SIS].[Empresa] ADD [FKIdPeriodoPago_SIS] int NULL;
    IF COL_LENGTH(N'SIS.Empresa', N'PrimaRiesgoIMSS') IS NULL
        ALTER TABLE [SIS].[Empresa] ADD [PrimaRiesgoIMSS] decimal(18,4) NULL;
    IF COL_LENGTH(N'SIS.Empresa', N'UsaSueldoTabular') IS NULL
        ALTER TABLE [SIS].[Empresa] ADD [UsaSueldoTabular] bit NOT NULL
            CONSTRAINT [DF_SIS_Empresa_UsaSueldoTabular] DEFAULT (0) WITH VALUES;
    IF COL_LENGTH(N'SIS.Empresa', N'FKIdTipoPago_NOM') IS NULL
        ALTER TABLE [SIS].[Empresa] ADD [FKIdTipoPago_NOM] int NULL;

    -- Conserva la identidad legal de SIS.Empresa y migra solamente atributos de nomina.
    IF OBJECT_ID(N'[NOM].[EmpresaNomina]', N'U') IS NOT NULL
    BEGIN
        EXEC sys.sp_executesql N'
            ;WITH DatosNomina AS
            (
                SELECT
                    CASE WHEN [PKIdEmpresaNomina] IN (6, 7) THEN 1 ELSE 2 END AS [PKIdEmpresa],
                    MAX(NULLIF(LTRIM(RTRIM([RegIMSS])), N'''')) AS [RegIMSS],
                    MAX(NULLIF(LTRIM(RTRIM([RegInfonavit])), N'''')) AS [RegInfonavit],
                    MAX(NULLIF(LTRIM(RTRIM([CedEmpadronam])), N'''')) AS [CedEmpadronam],
                    MAX(NULLIF(LTRIM(RTRIM([NoFonacot])), N'''')) AS [NoFonacot],
                    MAX(NULLIF(LTRIM(RTRIM([UsAdmin])), N'''')) AS [UsAdmin],
                    MAX(NULLIF(LTRIM(RTRIM([EmailAdmin])), N'''')) AS [EmailAdmin],
                    MAX([FKIdPeriodoPago_SIS]) AS [FKIdPeriodoPago_SIS],
                    MAX([PrimaRiesgoIMSS]) AS [PrimaRiesgoIMSS],
                    CONVERT(bit, MAX(CONVERT(tinyint, [UsaSueldoTabular]))) AS [UsaSueldoTabular],
                    MAX([FKIdTipoPago_NOM]) AS [FKIdTipoPago_NOM]
                FROM [NOM].[EmpresaNomina]
                WHERE [PKIdEmpresaNomina] IN (6, 7, 8, 9)
                GROUP BY CASE WHEN [PKIdEmpresaNomina] IN (6, 7) THEN 1 ELSE 2 END
            )
            UPDATE empresa
            SET
                [RegIMSS] = datos.[RegIMSS],
                [RegInfonavit] = datos.[RegInfonavit],
                [CedEmpadronam] = datos.[CedEmpadronam],
                [NoFonacot] = datos.[NoFonacot],
                [UsAdmin] = datos.[UsAdmin],
                [EmailAdmin] = datos.[EmailAdmin],
                [FKIdPeriodoPago_SIS] = datos.[FKIdPeriodoPago_SIS],
                [PrimaRiesgoIMSS] = datos.[PrimaRiesgoIMSS],
                [UsaSueldoTabular] = datos.[UsaSueldoTabular],
                [FKIdTipoPago_NOM] = datos.[FKIdTipoPago_NOM]
            FROM [SIS].[Empresa] empresa
            INNER JOIN DatosNomina datos ON datos.[PKIdEmpresa] = empresa.[PKIdEmpresa];';
    END;

    -- Quita cualquier FK que todavía apunte a la tabla que será eliminada.
    DECLARE @Sql nvarchar(max) = N'';
    SELECT @Sql +=
        N'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME([parent_object_id])) + N'.' +
        QUOTENAME(OBJECT_NAME([parent_object_id])) + N' DROP CONSTRAINT ' + QUOTENAME([name]) + N';'
    FROM sys.foreign_keys
    WHERE [referenced_object_id] = OBJECT_ID(N'[NOM].[EmpresaNomina]');
    IF @Sql <> N'' EXEC sys.sp_executesql @Sql;

    -- Renombra las cuatro columnas historicas conocidas sin perder datos ni indices.
    DECLARE @Esquema sysname, @Tabla sysname, @ColumnaCompleta nvarchar(776);
    DECLARE ColumnasEmpresa CURSOR LOCAL FAST_FORWARD FOR
        SELECT SCHEMA_NAME(t.[schema_id]), t.[name]
        FROM sys.tables t
        INNER JOIN sys.columns c ON c.[object_id] = t.[object_id]
        WHERE SCHEMA_NAME(t.[schema_id]) = N'NOM'
          AND c.[name] = N'FKIdEmpresaNomina_NOM';

    OPEN ColumnasEmpresa;
    FETCH NEXT FROM ColumnasEmpresa INTO @Esquema, @Tabla;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF COL_LENGTH(@Esquema + N'.' + @Tabla, N'FKIdEmpresa_SIS') IS NOT NULL
            THROW 51002, N'Una tabla NOM contiene simultaneamente FKIdEmpresaNomina_NOM y FKIdEmpresa_SIS.', 1;

        SET @ColumnaCompleta = @Esquema + N'.' + @Tabla + N'.FKIdEmpresaNomina_NOM';
        EXEC sys.sp_rename
            @objname = @ColumnaCompleta,
            @newname = N'FKIdEmpresa_SIS',
            @objtype = N'COLUMN';

        FETCH NEXT FROM ColumnasEmpresa INTO @Esquema, @Tabla;
    END;
    CLOSE ColumnasEmpresa;
    DEALLOCATE ColumnasEmpresa;

    -- Normaliza todas las tablas NOM, incluidas las que ya usaban el nombre correcto.
    SET @Sql = N'';
    SELECT @Sql +=
        N'UPDATE ' + QUOTENAME(SCHEMA_NAME(t.[schema_id])) + N'.' + QUOTENAME(t.[name]) +
        N' SET [FKIdEmpresa_SIS] = CASE WHEN [FKIdEmpresa_SIS] IN (6,7) THEN 1 '
        + N'WHEN [FKIdEmpresa_SIS] IN (8,9) THEN 2 ELSE [FKIdEmpresa_SIS] END '
        + N'WHERE [FKIdEmpresa_SIS] IN (6,7,8,9);'
    FROM sys.tables t
    INNER JOIN sys.columns c ON c.[object_id] = t.[object_id]
    WHERE SCHEMA_NAME(t.[schema_id]) = N'NOM'
      AND c.[name] = N'FKIdEmpresa_SIS';
    IF @Sql <> N'' EXEC sys.sp_executesql @Sql;

    -- Reescribe vistas y SPs; conserva nombres/columnas de salida que no son llaves fisicas.
    DECLARE @Objeto nvarchar(517), @Definicion nvarchar(max);
    DECLARE ModulosEmpresa CURSOR LOCAL FAST_FORWARD FOR
        SELECT QUOTENAME(SCHEMA_NAME(o.[schema_id])) + N'.' + QUOTENAME(o.[name]), m.[definition]
        FROM sys.sql_modules m
        INNER JOIN sys.objects o ON o.[object_id] = m.[object_id]
        WHERE m.[definition] LIKE N'%EmpresaNomina%'
        ORDER BY
            CASE o.[type]
                WHEN N'V' THEN 0
                WHEN N'P' THEN 1
                ELSE 2
            END,
            CASE o.[name]
                WHEN N'Vw_Puesto' THEN 0
                WHEN N'Vw_ContratoLaboral' THEN 0
                WHEN N'Vw_ContratoLaboralDetalle' THEN 0
                WHEN N'Vw_CorridaNomina' THEN 0
                WHEN N'Vw_EmpresaNomina' THEN 0
                WHEN N'Vw_RhEmpleado' THEN 1
                WHEN N'Vw_ConceptoFijo' THEN 1
                WHEN N'Vw_ConceptoProporcional' THEN 1
                WHEN N'Vw_ConceptoTabular' THEN 1
                WHEN N'Vw_CorridaNominaDetalle' THEN 1
                WHEN N'Vw_RhEmpleadoDetalle' THEN 2
                WHEN N'Vw_UsuarioNomina' THEN 2
                WHEN N'spUsuariosNomina_AdaptarDemo' THEN 3
                WHEN N'spCorridaNomina_Demo' THEN 4
                ELSE 2
            END,
            o.[name];

    OPEN ModulosEmpresa;
    FETCH NEXT FROM ModulosEmpresa INTO @Objeto, @Definicion;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Definicion = REPLACE(@Definicion, N'[NOM].[EmpresaNomina]', N'[SIS].[Empresa]');
        SET @Definicion = REPLACE(@Definicion, N'NOM.EmpresaNomina', N'SIS.Empresa');
        SET @Definicion = REPLACE(@Definicion, N'[PKIdEmpresaNomina]', N'[PKIdEmpresa]');
        SET @Definicion = REPLACE(@Definicion, N'PKIdEmpresaNomina', N'PKIdEmpresa');
        SET @Definicion = REPLACE(@Definicion, N'[FKIdEmpresaNomina_NOM]', N'[FKIdEmpresa_SIS]');
        SET @Definicion = REPLACE(@Definicion, N'FKIdEmpresaNomina_NOM', N'FKIdEmpresa_SIS');
        SET @Definicion = REPLACE(@Definicion, N'CREATE OR ALTER VIEW', N'ALTER VIEW');
        SET @Definicion = REPLACE(@Definicion, N'CREATE    VIEW', N'ALTER VIEW');
        SET @Definicion = REPLACE(@Definicion, N'CREATE   VIEW', N'ALTER VIEW');
        SET @Definicion = REPLACE(@Definicion, N'CREATE  VIEW', N'ALTER VIEW');
        SET @Definicion = REPLACE(@Definicion, N'CREATE VIEW', N'ALTER VIEW');
        SET @Definicion = REPLACE(@Definicion, N'CREATE OR ALTER PROCEDURE', N'ALTER PROCEDURE');
        SET @Definicion = REPLACE(@Definicion, N'CREATE    PROCEDURE', N'ALTER PROCEDURE');
        SET @Definicion = REPLACE(@Definicion, N'CREATE   PROCEDURE', N'ALTER PROCEDURE');
        SET @Definicion = REPLACE(@Definicion, N'CREATE  PROCEDURE', N'ALTER PROCEDURE');
        SET @Definicion = REPLACE(@Definicion, N'CREATE PROCEDURE', N'ALTER PROCEDURE');
        SET @Definicion = REPLACE(@Definicion, N'CREATE OR ALTER PROC', N'ALTER PROC');
        SET @Definicion = REPLACE(@Definicion, N'CREATE    PROC', N'ALTER PROC');
        SET @Definicion = REPLACE(@Definicion, N'CREATE   PROC', N'ALTER PROC');
        SET @Definicion = REPLACE(@Definicion, N'CREATE  PROC', N'ALTER PROC');
        SET @Definicion = REPLACE(@Definicion, N'CREATE PROC', N'ALTER PROC');

        BEGIN TRY
            EXEC sys.sp_executesql @Definicion;
        END TRY
        BEGIN CATCH
            DECLARE @ErrorModulo nvarchar(2048) = CONCAT(N'No se pudo actualizar ', @Objeto, N': ', ERROR_MESSAGE());
            THROW 51003, @ErrorModulo, 1;
        END CATCH;

        FETCH NEXT FROM ModulosEmpresa INTO @Objeto, @Definicion;
    END;
    CLOSE ModulosEmpresa;
    DEALLOCATE ModulosEmpresa;

    -- Impide eliminar la tabla si queda algun modulo con una referencia fisica real.
    IF EXISTS
    (
        SELECT 1
        FROM sys.sql_modules
        WHERE [definition] LIKE N'%[[]NOM[]].[[]EmpresaNomina[]]%'
           OR [definition] LIKE N'%NOM.EmpresaNomina%'
    )
        THROW 51004, N'Quedaron vistas o SPs apuntando a NOM.EmpresaNomina.', 1;

    IF OBJECT_ID(N'[NOM].[EmpresaNomina]', N'U') IS NOT NULL
        DROP TABLE [NOM].[EmpresaNomina];

    -- Valida y crea una FK SIS.Empresa para cada columna de empresa del esquema NOM.
    DECLARE @TablaCompleta nvarchar(517), @NombreFK sysname, @Huerfanos int;
    DECLARE FksEmpresa CURSOR LOCAL FAST_FORWARD FOR
        SELECT
            QUOTENAME(SCHEMA_NAME(t.[schema_id])) + N'.' + QUOTENAME(t.[name]),
            CONVERT(sysname, N'FK_NOM_' + t.[name] + N'_Empresa')
        FROM sys.tables t
        INNER JOIN sys.columns c ON c.[object_id] = t.[object_id]
        WHERE SCHEMA_NAME(t.[schema_id]) = N'NOM'
          AND c.[name] = N'FKIdEmpresa_SIS';

    OPEN FksEmpresa;
    FETCH NEXT FROM FksEmpresa INTO @TablaCompleta, @NombreFK;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Huerfanos = 0;
        SET @Sql = N'SELECT @Cantidad = COUNT(*) FROM ' + @TablaCompleta +
            N' t LEFT JOIN [SIS].[Empresa] e ON e.[PKIdEmpresa] = t.[FKIdEmpresa_SIS] '
            + N'WHERE t.[FKIdEmpresa_SIS] IS NOT NULL AND e.[PKIdEmpresa] IS NULL;';
        EXEC sys.sp_executesql @Sql, N'@Cantidad int OUTPUT', @Cantidad = @Huerfanos OUTPUT;

        IF @Huerfanos > 0
        BEGIN
            DECLARE @ErrorHuerfanos nvarchar(2048) = CONCAT(@TablaCompleta, N' contiene ', @Huerfanos, N' empresas inexistentes.');
            THROW 51005, @ErrorHuerfanos, 1;
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM sys.foreign_keys fk
            INNER JOIN sys.foreign_key_columns fkc ON fkc.[constraint_object_id] = fk.[object_id]
            INNER JOIN sys.columns c ON c.[object_id] = fkc.[parent_object_id]
                                      AND c.[column_id] = fkc.[parent_column_id]
            WHERE fk.[parent_object_id] = OBJECT_ID(@TablaCompleta)
              AND c.[name] = N'FKIdEmpresa_SIS'
              AND fk.[referenced_object_id] = OBJECT_ID(N'[SIS].[Empresa]')
        )
        BEGIN
            SET @Sql = N'ALTER TABLE ' + @TablaCompleta + N' WITH CHECK ADD CONSTRAINT ' +
                QUOTENAME(@NombreFK) + N' FOREIGN KEY ([FKIdEmpresa_SIS]) '
                + N'REFERENCES [SIS].[Empresa] ([PKIdEmpresa]); '
                + N'ALTER TABLE ' + @TablaCompleta + N' CHECK CONSTRAINT ' + QUOTENAME(@NombreFK) + N';';
            EXEC sys.sp_executesql @Sql;
        END;

        FETCH NEXT FROM FksEmpresa INTO @TablaCompleta, @NombreFK;
    END;
    CLOSE FksEmpresa;
    DEALLOCATE FksEmpresa;

    IF EXISTS
    (
        SELECT 1
        FROM sys.columns c
        INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]
        WHERE SCHEMA_NAME(t.[schema_id]) = N'NOM'
          AND c.[name] = N'FKIdEmpresaNomina_NOM'
    )
        THROW 51006, N'Quedaron columnas FKIdEmpresaNomina_NOM.', 1;

    COMMIT TRANSACTION;
    PRINT N'Consolidacion de empresas completada correctamente.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
