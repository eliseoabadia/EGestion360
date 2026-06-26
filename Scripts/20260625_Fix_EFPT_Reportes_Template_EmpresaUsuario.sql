USE [GestionEmpresarial]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

PRINT N'Aplicando [CONTA].[FN_FormatoImporteReporte]';
GO
CREATE OR ALTER FUNCTION [CONTA].[FN_FormatoImporteReporte]
(
    @Importe DECIMAL(18, 2),
    @Cultura NVARCHAR(10)
)
RETURNS NVARCHAR(60)
AS
BEGIN
    DECLARE @Valor DECIMAL(18, 2) = ISNULL(@Importe, 0);
    DECLARE @CulturaAplicada NVARCHAR(10) = ISNULL(NULLIF(@Cultura, N''), N'es-MX');

    RETURN CASE
        WHEN @Valor < 0 THEN N'(' + FORMAT(ROUND(ABS(@Valor), -2), N'N0', @CulturaAplicada) + N')'
        ELSE FORMAT(ROUND(@Valor, -2), N'N0', @CulturaAplicada)
    END;
END
GO

PRINT N'Aplicando [CONTA].[SPR_CambiosSituacionFinanciera] template Empresa/Usuario EFPT';
GO
CREATE OR ALTER PROCEDURE [CONTA].[SPR_CambiosSituacionFinanciera]
    @FechaInicio DATETIME = NULL,
    @IsCierre BIT = 0,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF;

    -- @IdEmpleado queda reservado para auditoria de ejecucion del reporte.
    SET @FechaInicio = ISNULL(@FechaInicio, GETDATE());

    DECLARE @Mes INT = MONTH(@FechaInicio);
    DECLARE @Anio INT = (
        SELECT TOP (1) A.PKIdAnio
        FROM [SIS].[Anio] AS A
        WHERE A.Clave = YEAR(@FechaInicio)
    );
    DECLARE @Cultura NVARCHAR(10) = N'es-MX';

    IF @IsCierre = 1
    BEGIN
        SET @Mes = 13;
    END;

    SELECT @Cultura = CASE M.CodigoISO4217
            WHEN N'MXN' THEN N'es-MX'
            WHEN N'USD' THEN N'en-US'
            WHEN N'EUR' THEN N'es-ES'
            ELSE N'es-MX'
        END
    FROM [SIS].[Empresa] AS E
    INNER JOIN [SIS].[Moneda] AS M ON E.FKIdMonedaBase_SIS = M.PKIdMoneda
    WHERE E.PKIdEmpresa = @IdEmpresa;

    SET @Cultura = ISNULL(@Cultura, N'es-MX');

    DECLARE @MesInicio NVARCHAR(50) = CASE @Mes
        WHEN 1 THEN N'ENERO'
        WHEN 2 THEN N'FEBRERO'
        WHEN 3 THEN N'MARZO'
        WHEN 4 THEN N'ABRIL'
        WHEN 5 THEN N'MAYO'
        WHEN 6 THEN N'JUNIO'
        WHEN 7 THEN N'JULIO'
        WHEN 8 THEN N'AGOSTO'
        WHEN 9 THEN N'SEPTIEMBRE'
        WHEN 10 THEN N'OCTUBRE'
        WHEN 11 THEN N'NOVIEMBRE'
        WHEN 12 THEN N'DICIEMBRE'
        WHEN 13 THEN N'DICIEMBRE'
        ELSE N''
    END;

    DECLARE @Saldos TABLE
    (
        NoCuenta VARCHAR(50) NOT NULL PRIMARY KEY,
        SaldoFinal DECIMAL(18, 2) NOT NULL
    );

    INSERT INTO @Saldos (NoCuenta, SaldoFinal)
    SELECT
        X.NoCuenta,
        SUM(ISNULL(X.SaldoFinal, 0)) AS SaldoFinal
    FROM [CONTA].[SaldoInicialBalanzaComprobacion] AS X
    WHERE X.FKIdAnio_SIS = @Anio
      AND X.FKIdMes_SIS = @Mes
      AND X.NoCuenta IN
      (
          '1110000000', '1120000000', '1150000000', '1240000000', '1250000000',
          '1260000000', '2110000000', '2160000000', '3122300000', '3122200000',
          '3210000000', '3220000000', '3250000000', '4212000000', '4100000000',
          '4213000000', '4300000000', '4413000000', '5110000000', '5120000000',
          '5130000000', '5212200000', '5280000000', '5510000000', '5590000000'
      )
      AND (
          @IdEmpresa IS NULL
          OR @IdEmpresa <= 0
          OR EXISTS
          (
              SELECT 1
              FROM [CONTA].[CuentaContable] AS CC
              WHERE CC.PKIdCuentaContable = X.FK_IdCuentacuenta
                AND CC.FKIdEmpresa_SIS = @IdEmpresa
          )
      )
    GROUP BY X.NoCuenta;

    DECLARE
        @C1110000000 DECIMAL(18, 2) = 0,
        @C1120000000 DECIMAL(18, 2) = 0,
        @C1150000000 DECIMAL(18, 2) = 0,
        @C1240000000 DECIMAL(18, 2) = 0,
        @C1250000000 DECIMAL(18, 2) = 0,
        @C1260000000 DECIMAL(18, 2) = 0,
        @C2110000000 DECIMAL(18, 2) = 0,
        @C2160000000 DECIMAL(18, 2) = 0,
        @C3122300000 DECIMAL(18, 2) = 0,
        @C3122200000 DECIMAL(18, 2) = 0,
        @C3220000000 DECIMAL(18, 2) = 0,
        @C3250000000 DECIMAL(18, 2) = 0,
        @C4212000000 DECIMAL(18, 2) = 0,
        @OtrosIngresos DECIMAL(18, 2) = 0,
        @C5110000000 DECIMAL(18, 2) = 0,
        @C5120000000 DECIMAL(18, 2) = 0,
        @C5130000000 DECIMAL(18, 2) = 0,
        @C5212200000 DECIMAL(18, 2) = 0,
        @C5080000000 DECIMAL(18, 2) = 0,
        @C5500000000 DECIMAL(18, 2) = 0,
        @C5590000000 DECIMAL(18, 2) = 0;

    SELECT
        @C1110000000 = ISNULL(SUM(CASE WHEN NoCuenta = '1110000000' THEN SaldoFinal END), 0),
        @C1120000000 = ISNULL(SUM(CASE WHEN NoCuenta = '1120000000' THEN SaldoFinal END), 0),
        @C1150000000 = ISNULL(SUM(CASE WHEN NoCuenta = '1150000000' THEN SaldoFinal END), 0),
        @C1240000000 = ISNULL(SUM(CASE WHEN NoCuenta = '1240000000' THEN SaldoFinal END), 0),
        @C1250000000 = ISNULL(SUM(CASE WHEN NoCuenta = '1250000000' THEN SaldoFinal END), 0),
        @C1260000000 = ISNULL(SUM(CASE WHEN NoCuenta = '1260000000' THEN SaldoFinal END), 0),
        @C2110000000 = ISNULL(SUM(CASE WHEN NoCuenta = '2110000000' THEN SaldoFinal END), 0),
        @C2160000000 = ISNULL(SUM(CASE WHEN NoCuenta = '2160000000' THEN SaldoFinal END), 0),
        @C3122300000 = ISNULL(SUM(CASE WHEN NoCuenta = '3122300000' THEN SaldoFinal END), 0),
        @C3122200000 = ISNULL(SUM(CASE WHEN NoCuenta = '3122200000' THEN SaldoFinal END), 0),
        @C3220000000 = ISNULL(SUM(CASE WHEN NoCuenta = '3220000000' THEN SaldoFinal END), 0),
        @C3250000000 = ISNULL(SUM(CASE WHEN NoCuenta = '3250000000' THEN SaldoFinal END), 0),
        @C4212000000 = ISNULL(SUM(CASE WHEN NoCuenta = '4212000000' THEN SaldoFinal END), 0),
        @OtrosIngresos = ISNULL(SUM(CASE WHEN NoCuenta IN ('4100000000', '4213000000', '4300000000', '4413000000') THEN SaldoFinal END), 0),
        @C5110000000 = ISNULL(SUM(CASE WHEN NoCuenta = '5110000000' THEN SaldoFinal END), 0),
        @C5120000000 = ISNULL(SUM(CASE WHEN NoCuenta = '5120000000' THEN SaldoFinal END), 0),
        @C5130000000 = ISNULL(SUM(CASE WHEN NoCuenta = '5130000000' THEN SaldoFinal END), 0),
        @C5212200000 = ISNULL(SUM(CASE WHEN NoCuenta = '5212200000' THEN SaldoFinal END), 0),
        @C5080000000 = ISNULL(SUM(CASE WHEN NoCuenta = '5280000000' THEN SaldoFinal END), 0),
        @C5500000000 = ISNULL(SUM(CASE WHEN NoCuenta = '5510000000' THEN SaldoFinal END), 0),
        @C5590000000 = ISNULL(SUM(CASE WHEN NoCuenta = '5590000000' THEN SaldoFinal END), 0)
    FROM @Saldos;

    DECLARE @T_PATASYOA DECIMAL(18, 2) = @C4212000000;
    DECLARE @T_OIYB DECIMAL(18, 2) = @OtrosIngresos;
    DECLARE @SubTotalIngresosOtrosBeneficios DECIMAL(18, 2) = @T_PATASYOA + @T_OIYB;
    DECLARE @T_GDF DECIMAL(18, 2) = @C5110000000 + @C5120000000 + @C5130000000;
    DECLARE @T_TASYOA DECIMAL(18, 2) = @C5080000000 + @C5212200000;
    DECLARE @T_OGYPE DECIMAL(18, 2) = @C5500000000 + @C5590000000;
    DECLARE @SubtotalGastosYOtrasPerdidas DECIMAL(18, 2) = @T_GDF + @T_OGYPE + @T_TASYOA;
    DECLARE @TotalAhorroYDesahorro DECIMAL(18, 2) = @SubTotalIngresosOtrosBeneficios - @SubtotalGastosYOtrasPerdidas;
    DECLARE @T_ORIGEN DECIMAL(18, 2) = @C1110000000 - @C1260000000 + @C2160000000 + @C3122300000 + @C3250000000;
    DECLARE @T_APLICACION DECIMAL(18, 2) = @C1120000000 + @C1150000000 + @C1240000000 + @C1250000000 + @C2110000000 + @C3122200000 + @TotalAhorroYDesahorro + @C3220000000;

    SELECT
        CAST(DAY(@FechaInicio) AS VARCHAR(2)) + ' DE ' + @MesInicio + ' DEL ' + CAST(YEAR(@FechaInicio) AS VARCHAR(4)) AS Fecha,
        YEAR(@FechaInicio) AS Anio,
        [CONTA].[FN_FormatoImporteReporte](@C1110000000, @Cultura) AS R_1110000000,
        [CONTA].[FN_FormatoImporteReporte](@C1120000000, @Cultura) AS R_1120000000,
        [CONTA].[FN_FormatoImporteReporte](@C1150000000, @Cultura) AS R_1150000000,
        [CONTA].[FN_FormatoImporteReporte](@C1240000000, @Cultura) AS R_1240000000,
        [CONTA].[FN_FormatoImporteReporte](@C1250000000, @Cultura) AS R_1250000000,
        CASE
            WHEN @C1260000000 < 0 THEN [CONTA].[FN_FormatoImporteReporte](@C1260000000, @Cultura)
            ELSE N'(' + [CONTA].[FN_FormatoImporteReporte](@C1260000000, @Cultura) + N')'
        END AS R_1260000000,
        [CONTA].[FN_FormatoImporteReporte](@C2110000000, @Cultura) AS R_2110000000,
        [CONTA].[FN_FormatoImporteReporte](@C2160000000, @Cultura) AS R_2160000000,
        [CONTA].[FN_FormatoImporteReporte](@C3122300000, @Cultura) AS R_3122300000,
        [CONTA].[FN_FormatoImporteReporte](@C3122200000, @Cultura) AS R_3122200000,
        [CONTA].[FN_FormatoImporteReporte](@TotalAhorroYDesahorro, @Cultura) AS R_3210000000,
        [CONTA].[FN_FormatoImporteReporte](@C3220000000, @Cultura) AS R_3220000000,
        [CONTA].[FN_FormatoImporteReporte](@C3250000000, @Cultura) AS R_3250000000,
        [CONTA].[FN_FormatoImporteReporte](@T_ORIGEN, @Cultura) AS R_T_ORIGEN,
        [CONTA].[FN_FormatoImporteReporte](@T_APLICACION, @Cultura) AS R_T_APLICACION;
END
GO

PRINT N'Aplicando [CONTA].[SPR_EstadoActividades] template Empresa/Usuario EFPT';
GO
CREATE OR ALTER PROCEDURE [CONTA].[SPR_EstadoActividades]
    @FechaInicio DATETIME = NULL,
    @FechaFin DATETIME = NULL,
    @FKIdMes_SIS INT = NULL,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF;

    -- @IdEmpleado queda reservado para auditoria de ejecucion del reporte.
    SET @FechaInicio = ISNULL(@FechaInicio, GETDATE());
    SET @FechaFin = ISNULL(@FechaFin, @FechaInicio);

    DECLARE @Mes INT = ISNULL(@FKIdMes_SIS, MONTH(@FechaInicio));
    DECLARE @MesConsulta INT = CASE WHEN @Mes = 13 THEN 12 ELSE @Mes END;
    DECLARE @FKIdAnio_SIS INT = (
        SELECT TOP (1) A.PKIdAnio
        FROM [SIS].[Anio] AS A
        WHERE A.Clave = YEAR(@FechaInicio)
    );
    DECLARE @Cultura NVARCHAR(10) = N'es-MX';

    SELECT @Cultura = CASE M.CodigoISO4217
            WHEN N'MXN' THEN N'es-MX'
            WHEN N'USD' THEN N'en-US'
            WHEN N'EUR' THEN N'es-ES'
            ELSE N'es-MX'
        END
    FROM [SIS].[Empresa] AS E
    INNER JOIN [SIS].[Moneda] AS M ON E.FKIdMonedaBase_SIS = M.PKIdMoneda
    WHERE E.PKIdEmpresa = @IdEmpresa;

    SET @Cultura = ISNULL(@Cultura, N'es-MX');

    DECLARE @MesInicio NVARCHAR(50) = CASE MONTH(@FechaInicio)
        WHEN 1 THEN N'ENERO'
        WHEN 2 THEN N'FEBRERO'
        WHEN 3 THEN N'MARZO'
        WHEN 4 THEN N'ABRIL'
        WHEN 5 THEN N'MAYO'
        WHEN 6 THEN N'JUNIO'
        WHEN 7 THEN N'JULIO'
        WHEN 8 THEN N'AGOSTO'
        WHEN 9 THEN N'SEPTIEMBRE'
        WHEN 10 THEN N'OCTUBRE'
        WHEN 11 THEN N'NOVIEMBRE'
        WHEN 12 THEN N'DICIEMBRE'
        ELSE N''
    END;

    DECLARE @MesFin NVARCHAR(50) = CASE MONTH(@FechaFin)
        WHEN 1 THEN N'ENERO'
        WHEN 2 THEN N'FEBRERO'
        WHEN 3 THEN N'MARZO'
        WHEN 4 THEN N'ABRIL'
        WHEN 5 THEN N'MAYO'
        WHEN 6 THEN N'JUNIO'
        WHEN 7 THEN N'JULIO'
        WHEN 8 THEN N'AGOSTO'
        WHEN 9 THEN N'SEPTIEMBRE'
        WHEN 10 THEN N'OCTUBRE'
        WHEN 11 THEN N'NOVIEMBRE'
        WHEN 12 THEN N'DICIEMBRE'
        ELSE N''
    END;

    DECLARE @Saldos TABLE
    (
        NoCuenta VARCHAR(50) NOT NULL PRIMARY KEY,
        SaldoFinal DECIMAL(18, 2) NOT NULL
    );

    INSERT INTO @Saldos (NoCuenta, SaldoFinal)
    SELECT
        X.NoCuenta,
        SUM(ISNULL(X.SaldoFinal, 0)) AS SaldoFinal
    FROM [CONTA].[SaldoInicialBalanzaComprobacion] AS X
    WHERE X.FKIdAnio_SIS = @FKIdAnio_SIS
      AND X.FKIdMes_SIS = @MesConsulta
      AND X.NoCuenta IN
      (
          '4212000000', '4100000000', '4213000000', '4300000000', '4413000000',
          '5110000000', '5120000000', '5130000000', '5212200000', '5280000000',
          '5510000000', '5590000000'
      )
      AND (
          @IdEmpresa IS NULL
          OR @IdEmpresa <= 0
          OR EXISTS
          (
              SELECT 1
              FROM [CONTA].[CuentaContable] AS CC
              WHERE CC.PKIdCuentaContable = X.FK_IdCuentacuenta
                AND CC.FKIdEmpresa_SIS = @IdEmpresa
          )
      )
    GROUP BY X.NoCuenta;

    DECLARE
        @C4212000000 DECIMAL(18, 2) = 0,
        @OtrosIngresos DECIMAL(18, 2) = 0,
        @C5110000000 DECIMAL(18, 2) = 0,
        @C5120000000 DECIMAL(18, 2) = 0,
        @C5130000000 DECIMAL(18, 2) = 0,
        @C5212200000 DECIMAL(18, 2) = 0,
        @C5080000000 DECIMAL(18, 2) = 0,
        @C5500000000 DECIMAL(18, 2) = 0,
        @C5590000000 DECIMAL(18, 2) = 0;

    SELECT
        @C4212000000 = ISNULL(SUM(CASE WHEN NoCuenta = '4212000000' THEN SaldoFinal END), 0),
        @OtrosIngresos = ISNULL(SUM(CASE WHEN NoCuenta IN ('4100000000', '4213000000', '4300000000', '4413000000') THEN SaldoFinal END), 0),
        @C5110000000 = ISNULL(SUM(CASE WHEN NoCuenta = '5110000000' THEN SaldoFinal END), 0),
        @C5120000000 = ISNULL(SUM(CASE WHEN NoCuenta = '5120000000' THEN SaldoFinal END), 0),
        @C5130000000 = ISNULL(SUM(CASE WHEN NoCuenta = '5130000000' THEN SaldoFinal END), 0),
        @C5212200000 = ISNULL(SUM(CASE WHEN NoCuenta = '5212200000' THEN SaldoFinal END), 0),
        @C5080000000 = ISNULL(SUM(CASE WHEN NoCuenta = '5280000000' THEN SaldoFinal END), 0),
        @C5500000000 = ISNULL(SUM(CASE WHEN NoCuenta = '5510000000' THEN SaldoFinal END), 0),
        @C5590000000 = ISNULL(SUM(CASE WHEN NoCuenta = '5590000000' THEN SaldoFinal END), 0)
    FROM @Saldos;

    DECLARE @T_PATASYOA DECIMAL(18, 2) = @C4212000000;
    DECLARE @T_OIYB DECIMAL(18, 2) = @OtrosIngresos;
    DECLARE @SubTotalIngresosOtrosBeneficios DECIMAL(18, 2) = @T_PATASYOA + @T_OIYB;
    DECLARE @T_GDF DECIMAL(18, 2) = @C5110000000 + @C5120000000 + @C5130000000;
    DECLARE @T_TASYOA DECIMAL(18, 2) = @C5080000000 + @C5212200000;
    DECLARE @T_OGYPE DECIMAL(18, 2) = @C5500000000 + @C5590000000;
    DECLARE @SubtotalGastosYOtrasPerdidas DECIMAL(18, 2) = @T_GDF + @T_OGYPE + @T_TASYOA;
    DECLARE @TotalAhorroYDesahorro DECIMAL(18, 2) = @SubTotalIngresosOtrosBeneficios - @SubtotalGastosYOtrasPerdidas;

    SELECT
        CAST(DAY(@FechaInicio) AS VARCHAR(2)) + ' DE ' + @MesInicio + ' AL ' + CAST(DAY(@FechaFin) AS VARCHAR(2)) + ' DE ' + @MesFin + ' DE ' + CAST(YEAR(@FechaFin) AS VARCHAR(4)) AS Fecha,
        YEAR(@FechaInicio) AS Anio,
        [CONTA].[FN_FormatoImporteReporte](@C4212000000, @Cultura) AS IOB_4212000000,
        [CONTA].[FN_FormatoImporteReporte](@OtrosIngresos, @Cultura) AS IOB_OtrosIngresos,
        [CONTA].[FN_FormatoImporteReporte](@T_PATASYOA, @Cultura) AS T_PATASYOA,
        [CONTA].[FN_FormatoImporteReporte](@T_OIYB, @Cultura) AS T_OIYB,
        [CONTA].[FN_FormatoImporteReporte](@SubTotalIngresosOtrosBeneficios, @Cultura) AS SubTotalIngresosOtrosBeneficios,
        [CONTA].[FN_FormatoImporteReporte](@C5110000000, @Cultura) AS GOP_5110000000,
        [CONTA].[FN_FormatoImporteReporte](@C5120000000, @Cultura) AS GOP_5120000000,
        [CONTA].[FN_FormatoImporteReporte](@C5130000000, @Cultura) AS GOP_5130000000,
        [CONTA].[FN_FormatoImporteReporte](@T_GDF, @Cultura) AS T_GDF,
        [CONTA].[FN_FormatoImporteReporte](@C5212200000, @Cultura) AS TASYOA_5212200000,
        [CONTA].[FN_FormatoImporteReporte](@C5080000000, @Cultura) AS TASYOA_5080000000,
        [CONTA].[FN_FormatoImporteReporte](@T_TASYOA, @Cultura) AS T_TASYOA,
        [CONTA].[FN_FormatoImporteReporte](@C5500000000, @Cultura) AS GOP_5500000000,
        [CONTA].[FN_FormatoImporteReporte](@C5590000000, @Cultura) AS GOP_5590000000,
        [CONTA].[FN_FormatoImporteReporte](@T_OGYPE, @Cultura) AS T_OGYPE,
        [CONTA].[FN_FormatoImporteReporte](@SubtotalGastosYOtrasPerdidas, @Cultura) AS SubtotalGastosYOtrasPerdidas,
        [CONTA].[FN_FormatoImporteReporte](@TotalAhorroYDesahorro, @Cultura) AS TotalAhorroYDesahorro;
END
GO
