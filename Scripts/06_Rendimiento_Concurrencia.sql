/*
    Mejoras incrementales de rendimiento, consistencia y concurrencia.
    El script es idempotente y valida duplicados antes de crear restricciones.
*/
USE [GestionEmpresarial];
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

/* READ_COMMITTED_SNAPSHOT permite retirar NOLOCK sin aumentar bloqueos de lectura. */
IF (SELECT is_read_committed_snapshot_on FROM sys.databases WHERE database_id = DB_ID()) = 0
BEGIN
    DECLARE @rcsiSql nvarchar(max) =
        N'ALTER DATABASE ' + QUOTENAME(DB_NAME()) +
        N' SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE;';
    EXEC sys.sp_executesql @rcsiSql;
END;
GO

/* Concurrencia optimista para encabezados críticos. */
DECLARE @rowVersionTables TABLE (SchemaName sysname, TableName sysname);
INSERT @rowVersionTables (SchemaName, TableName)
VALUES
    (N'CONTA', N'Poliza'),
    (N'ORCO', N'Requisicion'),
    (N'PRES', N'EgresoAutorizado'),
    (N'PRES', N'EgresoProyectado'),
    (N'ORCO', N'OrdenCompra'),
    (N'PRES', N'Factura'),
    (N'PRES', N'Cheque');

DECLARE @schemaName sysname, @tableName sysname, @sql nvarchar(max);
DECLARE rv_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT SchemaName, TableName FROM @rowVersionTables;

OPEN rv_cursor;
FETCH NEXT FROM rv_cursor INTO @schemaName, @tableName;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF COL_LENGTH(QUOTENAME(@schemaName) + N'.' + QUOTENAME(@tableName), N'RowVersion') IS NULL
    BEGIN
        SET @sql = N'ALTER TABLE ' + QUOTENAME(@schemaName) + N'.' + QUOTENAME(@tableName) +
                   N' ADD [RowVersion] rowversion NOT NULL;';
        EXEC sys.sp_executesql @sql;
    END;
    FETCH NEXT FROM rv_cursor INTO @schemaName, @tableName;
END;
CLOSE rv_cursor;
DEALLOCATE rv_cursor;
GO

/* Reglas únicas de negocio. Se detiene el despliegue si existen duplicados. */
IF EXISTS
(
    SELECT 1 FROM [CONTA].[Poliza]
    GROUP BY [FKIdAnio_SIS], [FKIdTipoPoliza_SIS], [ClavePoliza]
    HAVING COUNT_BIG(*) > 1
)
    THROW 51010, 'Existen pólizas duplicadas por ejercicio, tipo y clave.', 1;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[CONTA].[Poliza]') AND name = N'UQ_Poliza_Anio_Tipo_Clave')
    CREATE UNIQUE INDEX [UQ_Poliza_Anio_Tipo_Clave]
        ON [CONTA].[Poliza] ([FKIdAnio_SIS], [FKIdTipoPoliza_SIS], [ClavePoliza]);
GO

IF EXISTS
(
    SELECT 1 FROM [PRES].[Cheque]
    GROUP BY [FKIdEmpresa_SIS], [FKIdCuentaBancaria_TES], [NumeroCheque]
    HAVING COUNT_BIG(*) > 1
)
    THROW 51011, 'Existen números de cheque duplicados para la misma entidad y cuenta bancaria.', 1;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[PRES].[Cheque]') AND name = N'UQ_Cheque_Entidad_Cuenta_Numero')
    CREATE UNIQUE INDEX [UQ_Cheque_Entidad_Cuenta_Numero]
        ON [PRES].[Cheque] ([FKIdEmpresa_SIS], [FKIdCuentaBancaria_TES], [NumeroCheque]);
GO

IF EXISTS
(
    SELECT 1 FROM [PRES].[Factura]
    WHERE [UUID] IS NOT NULL
    GROUP BY [FKIdEmpresa_SIS], [UUID]
    HAVING COUNT_BIG(*) > 1
)
    THROW 51012, 'Existen UUID de factura duplicados para la misma entidad.', 1;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[PRES].[Factura]') AND name = N'UQ_Factura_Entidad_UUID')
    CREATE UNIQUE INDEX [UQ_Factura_Entidad_UUID]
        ON [PRES].[Factura] ([FKIdEmpresa_SIS], [UUID])
        WHERE [UUID] IS NOT NULL;
GO

/* Único duplicado exacto encontrado en la auditoría. */
IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[NOM].[PersonaDependiente]') AND name = N'IX_NOM_PersonaDependiente_PersonaActivo')
   AND EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[NOM].[PersonaDependiente]') AND name = N'IX_NOM_PersonaDependiente_Persona')
    DROP INDEX [IX_NOM_PersonaDependiente_PersonaActivo] ON [NOM].[PersonaDependiente];
GO

/* Columna sargable para las cuentas auxiliares 2.1.1.2. */
IF COL_LENGTH(N'[CONTA].[CuentaContable]', N'ClaveOrdNormalizada') IS NULL
    ALTER TABLE [CONTA].[CuentaContable]
        ADD [ClaveOrdNormalizada] AS REPLACE([ClaveOrd], N' ', N'') PERSISTED;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[CONTA].[CuentaContable]') AND name = N'IX_CuentaContable_ClaveOrdNormalizada_Detalle')
    CREATE INDEX [IX_CuentaContable_ClaveOrdNormalizada_Detalle]
        ON [CONTA].[CuentaContable] ([ClaveOrdNormalizada], [IsCuentaDetalle])
        INCLUDE ([PKIdCuentaContable], [Descripcion])
        WHERE [Activo] = 1;
GO

/* Acceso frecuente roles -> menús activos. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SIS].[MenuRole]') AND name = N'IX_MenuRole_Role_Menu_Activo')
    CREATE INDEX [IX_MenuRole_Role_Menu_Activo]
        ON [SIS].[MenuRole] ([RoleId], [FKIdMenu_SIS])
        WHERE [Activo] = 1;
GO

CREATE OR ALTER PROCEDURE [SIS].[spGetClaimsByUser]
    @PkIdUser int,
    @EsParaLogin bit = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT C.[Group], C.[SubGroup], C.[Values]
    FROM dbo.AspNetClaims AS C
    WHERE C.[Group] IS NOT NULL
      AND C.[SubGroup] IS NOT NULL
      AND EXISTS
      (
          SELECT 1
          FROM SIS.Usuario AS U
          INNER JOIN dbo.AspNetUsers AS AU ON AU.PkIdUsuario = U.PkIdUsuario
          INNER JOIN dbo.AspNetUserRoles AS UR ON UR.UserId = AU.Id
          WHERE U.PkIdUsuario = @PkIdUser
            AND U.Activo = 1
            AND UR.RoleId = C.RoleId
      )
      AND
      (
          @EsParaLogin = 0
          OR EXISTS
          (
              SELECT 1
              FROM SIS.MenuRole AS MR
              INNER JOIN SIS.Menu AS M ON M.PKIdMenu = MR.FKIdMenu_SIS
              WHERE MR.RoleId = C.RoleId
                AND MR.Activo = 1
                AND M.Activo = 1
          )
      )
    GROUP BY C.[Group], C.[SubGroup], C.[Values]
    ORDER BY C.[Group], C.[SubGroup], C.[Values];
END;
GO

CREATE OR ALTER PROCEDURE [SIS].[spNodeMenu]
    @NoEmploye int,
    @Lenguaje char(3)
AS
BEGIN
    SET NOCOUNT ON;

    IF @NoEmploye <= 0
    BEGIN
        SELECT TOP (0)
            M.[PKIdMenu], M.[Nombre], M.[Tipo],
            CONVERT(int, 0) AS [FKIdMenuSIS], M.[LegacyName], M.[Ruta],
            M.[ImageUrl], M.[Activo], M.[Lenguaje], CONVERT(nvarchar(450), N'') AS [UserId], M.[Orden]
        FROM SIS.Menu AS M;
        RETURN;
    END;

    ;WITH UserRoles AS
    (
        SELECT DISTINCT UR.RoleId, UR.UserId
        FROM SIS.Usuario AS U
        INNER JOIN dbo.AspNetUsers AS AU ON AU.PkIdUsuario = U.PkIdUsuario
        INNER JOIN dbo.AspNetUserRoles AS UR ON UR.UserId = AU.Id
        WHERE U.PkIdUsuario = @NoEmploye
          AND U.Activo = 1
    )
    SELECT DISTINCT
        M.PKIdMenu, M.Nombre, M.Tipo, M.FKIdMenu_SIS, M.LegacyName,
        M.Ruta, M.ImageUrl, M.Activo, M.Lenguaje, UR.UserId, M.Orden
    INTO #AllowedMenu
    FROM UserRoles AS UR
    INNER JOIN SIS.MenuRole AS MR
        ON MR.RoleId = UR.RoleId AND MR.Activo = 1
    INNER JOIN SIS.Menu AS M
        ON M.PKIdMenu = MR.FKIdMenu_SIS
    WHERE M.Activo = 1
      AND M.Lenguaje = @Lenguaje;

    CREATE UNIQUE CLUSTERED INDEX [IX_AllowedMenu_Id] ON #AllowedMenu ([PKIdMenu]);
    CREATE INDEX [IX_AllowedMenu_Parent] ON #AllowedMenu ([FKIdMenu_SIS]);

    ;WITH MenuTree AS
    (
        SELECT * FROM #AllowedMenu WHERE FKIdMenu_SIS IS NULL
        UNION ALL
        SELECT Child.*
        FROM MenuTree AS Parent
        INNER JOIN #AllowedMenu AS Child ON Child.FKIdMenu_SIS = Parent.PKIdMenu
    )
    SELECT DISTINCT
        T.PKIdMenu, T.Nombre, T.Tipo,
        ISNULL(T.FKIdMenu_SIS, 0) AS FKIdMenuSIS,
        T.LegacyName, T.Ruta, T.ImageUrl, T.Activo, T.Lenguaje, T.UserId, T.Orden
    FROM MenuTree AS T
    ORDER BY T.PKIdMenu
    OPTION (MAXRECURSION 100);
END;
GO
