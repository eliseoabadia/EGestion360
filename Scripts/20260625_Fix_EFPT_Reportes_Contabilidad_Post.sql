USE [GestionEmpresarial];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF SCHEMA_ID(N'CONTA') IS NULL
    EXEC(N'CREATE SCHEMA [CONTA]');
GO

CREATE OR ALTER VIEW [CONTA].[SaldoInicialBalanzaComprobacion]
AS
SELECT
    sm.[FKIdCuentaContable] AS [FK_IdCuentacuenta],
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
GO

CREATE OR ALTER FUNCTION [dbo].[FechaMesNumeroToFechaMesNombre]
(
    @Fecha varchar(30),
    @IncluirDia bit
)
RETURNS varchar(80)
AS
BEGIN
    DECLARE @FechaDate date = COALESCE(
        TRY_CONVERT(date, @Fecha, 112),
        TRY_CONVERT(date, @Fecha, 120),
        TRY_CONVERT(date, @Fecha, 103),
        TRY_CONVERT(date, @Fecha)
    );

    IF @FechaDate IS NULL
        RETURN NULL;

    DECLARE @Mes varchar(15) = CASE MONTH(@FechaDate)
        WHEN 1 THEN 'ENERO'
        WHEN 2 THEN 'FEBRERO'
        WHEN 3 THEN 'MARZO'
        WHEN 4 THEN 'ABRIL'
        WHEN 5 THEN 'MAYO'
        WHEN 6 THEN 'JUNIO'
        WHEN 7 THEN 'JULIO'
        WHEN 8 THEN 'AGOSTO'
        WHEN 9 THEN 'SEPTIEMBRE'
        WHEN 10 THEN 'OCTUBRE'
        WHEN 11 THEN 'NOVIEMBRE'
        WHEN 12 THEN 'DICIEMBRE'
    END;

    RETURN CASE WHEN ISNULL(@IncluirDia, 0) = 1
        THEN RIGHT('00' + CONVERT(varchar(2), DAY(@FechaDate)), 2) + ' DE ' + @Mes + ' DE ' + CONVERT(varchar(4), YEAR(@FechaDate))
        ELSE @Mes + ' DE ' + CONVERT(varchar(4), YEAR(@FechaDate))
    END;
END;
GO

CREATE OR ALTER PROCEDURE [CONTA].[SPR_InventariosdeMaterias]
    @p_FecInicio nvarchar(24),
    @p_FecFin nvarchar(24)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    DECLARE @FechaFin date = TRY_CONVERT(date, NULLIF(@p_FecFin, N''));

    SELECT
        E.[PKIdTipoBien] AS [id],
        ISNULL(CC.[ClaveNombre], 'Configure Cuenta') AS [CODIGO],
        E.[Descripcion] AS [S/PG],
        SUM(E.[Existencias]) AS [CANTIDAD],
        E.[Unidades] AS [UM],
        ISNULL(MAX(E.[CostoPromedio]), 0) AS [CU],
        SUM(E.[Existencias]) * ISNULL(MAX(E.[CostoPromedio]), 0) AS [MONTO],
        CAST('Al: ' + UPPER(FORMAT(ISNULL(@FechaFin, GETDATE()), 'dd \DE MMMM \DEL yyyy', 'es-MX')) AS varchar(60)) AS [titulo]
    FROM [ALMA].[Vw_Existencias] AS E
    LEFT JOIN [ALMA].[TipoBien] AS TB ON TB.[PKIdTipoBien] = E.[PKIdTipoBien] AND TB.[Activo] = 1
    LEFT JOIN [CONTA].[VW_CUENTAS] AS CC ON CC.[Pk_IdCuenta] = TB.[FKIdCuentaContable_CONTA]
    GROUP BY
        E.[PKIdTipoBien],
        CC.[ClaveNombre],
        E.[Descripcion],
        E.[Unidades];
END;
GO
