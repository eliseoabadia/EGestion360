/*
    Cambio: dejar bancos solo en TES.Banco.
    - Migra bancos existentes desde SIS.Banco hacia TES.Banco conservando PKIdBanco.
    - Cambia TES.CuentaBancaria.FKIdBanco_SIS a FKIdBanco_TES.
    - Reapunta FK y vistas hacia TES.Banco.
    - Elimina SIS.Banco cuando ya no tenga referencias.
*/

SET XACT_ABORT ON;
GO

IF OBJECT_ID(N'[TES].[Banco]', N'U') IS NULL
    THROW 51000, 'No existe TES.Banco. Ejecuta primero la estructura TES.', 1;
GO

IF OBJECT_ID(N'[SIS].[Banco]', N'U') IS NOT NULL
BEGIN
    IF EXISTS (
        SELECT 1
        FROM [SIS].[Banco] s
        INNER JOIN [TES].[Banco] t ON t.[PKIdBanco] = s.[PKIdBanco]
        WHERE ISNULL(t.[Clave], N'') <> ISNULL(s.[Clave], N'')
           OR ISNULL(t.[Nombre], N'') <> ISNULL(s.[Nombre], N'')
    )
        THROW 51001, 'Hay bancos con el mismo PKIdBanco pero datos distintos entre SIS.Banco y TES.Banco. Revisa antes de migrar.', 1;

    SET IDENTITY_INSERT [TES].[Banco] ON;

    INSERT INTO [TES].[Banco]
        ([PKIdBanco], [FKIdEmpresa_SIS], [Clave], [Nombre], [NombreCorto], [Activo],
         [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion])
    SELECT
        s.[PKIdBanco], s.[FKIdEmpresa_SIS], s.[Clave], s.[Nombre], s.[NombreCorto], s.[Activo],
        s.[FechaCreacion], s.[UsuarioCreacion], s.[FechaModificacion], s.[UsuarioModificacion]
    FROM [SIS].[Banco] s
    WHERE NOT EXISTS (
        SELECT 1
        FROM [TES].[Banco] t
        WHERE t.[PKIdBanco] = s.[PKIdBanco]
    );

    SET IDENTITY_INSERT [TES].[Banco] OFF;
END
GO

IF OBJECT_ID(N'[SIS].[Vw_Banco]', N'V') IS NOT NULL
    DROP VIEW [SIS].[Vw_Banco];
GO

IF OBJECT_ID(N'[TES].[Vw_CuentaBancaria]', N'V') IS NOT NULL
    DROP VIEW [TES].[Vw_CuentaBancaria];
GO

IF OBJECT_ID(N'[TES].[VW_Inversiones]', N'V') IS NOT NULL
    DROP VIEW [TES].[VW_Inversiones];
GO

IF EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE [name] = N'FK_CuentaBancaria_Banco'
      AND parent_object_id = OBJECT_ID(N'[TES].[CuentaBancaria]')
)
    ALTER TABLE [TES].[CuentaBancaria] DROP CONSTRAINT [FK_CuentaBancaria_Banco];
GO

IF COL_LENGTH(N'TES.CuentaBancaria', N'FKIdBanco_TES') IS NULL
   AND COL_LENGTH(N'TES.CuentaBancaria', N'FKIdBanco_SIS') IS NOT NULL
    EXEC sp_rename N'TES.CuentaBancaria.FKIdBanco_SIS', N'FKIdBanco_TES', N'COLUMN';
GO

IF COL_LENGTH(N'TES.CuentaBancaria', N'FKIdBanco_TES') IS NULL
    THROW 51002, 'No existe TES.CuentaBancaria.FKIdBanco_TES ni FKIdBanco_SIS para renombrar.', 1;
GO

IF EXISTS (
    SELECT 1
    FROM [TES].[CuentaBancaria] cb
    LEFT JOIN [TES].[Banco] b ON b.[PKIdBanco] = cb.[FKIdBanco_TES]
    WHERE cb.[FKIdBanco_TES] IS NOT NULL
      AND b.[PKIdBanco] IS NULL
)
    THROW 51003, 'Existen cuentas bancarias con FKIdBanco_TES sin banco en TES.Banco.', 1;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE [name] = N'FK_CuentaBancaria_Banco'
      AND parent_object_id = OBJECT_ID(N'[TES].[CuentaBancaria]')
)
BEGIN
    ALTER TABLE [TES].[CuentaBancaria] WITH CHECK ADD CONSTRAINT [FK_CuentaBancaria_Banco]
        FOREIGN KEY([FKIdBanco_TES]) REFERENCES [TES].[Banco]([PKIdBanco]);

    ALTER TABLE [TES].[CuentaBancaria] CHECK CONSTRAINT [FK_CuentaBancaria_Banco];
END
GO

CREATE OR ALTER VIEW [TES].[Vw_Banco] AS
SELECT
    b.[PKIdBanco],
    b.[FKIdEmpresa_SIS],
    b.[Clave],
    b.[Nombre],
    b.[NombreCorto],
    b.[Activo],
    b.[FechaCreacion],
    b.[UsuarioCreacion],
    b.[FechaModificacion],
    b.[UsuarioModificacion],
    emp.[Nombre] AS [EmpresaNombre],
    emp.[RFC] AS [EmpresaRFC],
    CONCAT(b.[Clave], ' - ', b.[Nombre]) AS [ClaveNombre]
FROM [TES].[Banco] b
LEFT JOIN [SIS].[Empresa] emp ON b.[FKIdEmpresa_SIS] = emp.[PKIdEmpresa] AND emp.[Activo] = 1
WHERE b.[Activo] = 1;
GO

CREATE OR ALTER VIEW [TES].[Vw_CuentaBancaria] AS
SELECT
    cb.[PKIdCuentaBancaria],
    cb.[FKIdEmpresa_SIS],
    cb.[FKIdBanco_TES],
    cb.[FKIdCuentaContable_SIS],
    cb.[FKIdTipoMoneda_TES],
    cb.[NumeroCuenta],
    cb.[CLABE],
    cb.[Titular],
    cb.[SaldoInicial],
    cb.[SaldoActual],
    cb.[FechaApertura],
    cb.[Activo],
    cb.[FechaCreacion],
    cb.[UsuarioCreacion],
    cb.[FechaModificacion],
    cb.[UsuarioModificacion],
    emp.[Nombre] AS [EmpresaNombre],
    banco.[Nombre] AS [BancoNombre],
    banco.[Clave] AS [BancoClave],
    tm.[Descripcion] AS [TipoMonedaDescripcion],
    tm.[CodigoISO4217] AS [TipoMonedaCodigo],
    tm.[Simbolo] AS [TipoMonedaSimbolo],
    CONCAT(cb.[NumeroCuenta], ' - ', ISNULL(banco.[Nombre], 'Sin banco')) AS [ClaveNombre]
FROM [TES].[CuentaBancaria] cb
LEFT JOIN [SIS].[Empresa] emp ON cb.[FKIdEmpresa_SIS] = emp.[PKIdEmpresa] AND emp.[Activo] = 1
LEFT JOIN [TES].[Banco] banco ON cb.[FKIdBanco_TES] = banco.[PKIdBanco] AND banco.[Activo] = 1
LEFT JOIN [TES].[TipoMoneda] tm ON cb.[FKIdTipoMoneda_TES] = tm.[PKIdTipoMoneda] AND tm.[Activo] = 1
WHERE cb.[Activo] = 1;
GO

CREATE OR ALTER VIEW [TES].[VW_Inversiones]
AS
SELECT
    inv.[PKIdInversion],
    CONCAT(cb.[NumeroCuenta], ' - ', b.[Nombre]) AS [CuentaBan],
    ins.[Nombre] AS [Instrumento],
    inv.[Monto],
    inv.[FechaInversion],
    inv.[FechaVencimiento],
    inv.[UsuarioCreacion] AS [CT_CreatedBy],
    inv.[FechaCreacion] AS [CT_CreatedDate],
    inv.[UsuarioModificacion] AS [CT_ModifiedBy],
    inv.[FechaModificacion] AS [CT_ModifiedDate],
    inv.[Activo] AS [CT_LIVE],
    ISNULL(SUM(inte.[Monto]), 0) AS [Intereses],
    ISNULL(SUM(ret.[Monto]), 0) AS [Retiros],
    ISNULL(inv.[Monto], 0) + ISNULL(SUM(inte.[Monto]), 0) - ISNULL(SUM(ret.[Monto]), 0) AS [Saldo],
    inv.[FKIdInstrumento],
    inv.[FKIdCuentaBancaria]
FROM [TES].[Inversion] inv
INNER JOIN [TES].[Instrumento] ins ON inv.[FKIdInstrumento] = ins.[PKIdInstrumento]
INNER JOIN [TES].[CuentaBancaria] cb ON inv.[FKIdCuentaBancaria] = cb.[PKIdCuentaBancaria]
INNER JOIN [TES].[Banco] b ON cb.[FKIdBanco_TES] = b.[PKIdBanco]
LEFT JOIN [TES].[Interes] inte ON inte.[FKIdInversion] = inv.[PKIdInversion] AND inte.[Activo] = 1
LEFT JOIN [TES].[Retiro] ret ON ret.[FKIdInversion] = inv.[PKIdInversion] AND ret.[Activo] = 1
WHERE inv.[Activo] = 1
  AND ins.[Activo] = 1
  AND cb.[Activo] = 1
GROUP BY
    inv.[PKIdInversion],
    inv.[FKIdInstrumento],
    inv.[FKIdCuentaBancaria],
    inv.[Monto],
    inv.[FechaInversion],
    inv.[FechaVencimiento],
    inv.[UsuarioCreacion],
    inv.[FechaCreacion],
    inv.[UsuarioModificacion],
    inv.[FechaModificacion],
    inv.[Activo],
    cb.[NumeroCuenta],
    b.[Nombre],
    ins.[Nombre];
GO

IF OBJECT_ID(N'[SIS].[Banco]', N'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE referenced_object_id = OBJECT_ID(N'[SIS].[Banco]')
    )
        DROP TABLE [SIS].[Banco];
    ELSE
        THROW 51004, 'No se eliminó SIS.Banco porque todavía hay llaves foráneas referenciándola.', 1;
END
GO
