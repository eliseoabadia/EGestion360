USE [GestionEmpresarial]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

PRINT N'Aplicando [CONTA].[SP_SaldoMensual] sin #temp para EFPT';
GO
CREATE OR ALTER PROCEDURE [CONTA].[SP_SaldoMensual]
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE Spanish;

    DECLARE @v_FK_IdMesAnterior INT;
    DECLARE @v_FK_IdMesActual INT;
    DECLARE @v_FK_IdAnioAnterior INT;
    DECLARE @v_FK_IdAnioActual INT;
    DECLARE @v_FK_IdMesSiguiente INT;
    DECLARE @v_FK_IdAnioSiguiente INT;
    DECLARE @v_mesesActuales INT;
    DECLARE @tipo NVARCHAR(100);
    DECLARE @message NVARCHAR(4000);

    SELECT @v_mesesActuales = COUNT(cmab.Actual)
    FROM [CONTA].[MesActual] AS cmab
    WHERE cmab.Actual = 1;

    IF @v_mesesActuales <> 1
    BEGIN
        SET @message = CONCAT('ERROR: Verifique el anio y mes actual que pretende cerrar, Verifique la tabla ', 'CONTA.MesActual');
        SELECT CAST(JSON_QUERY(CONCAT('{', '"tipo":"ERROR"', ',', '"mensaje":"', @message, '"', ',', '"liga":""', '}')) AS NVARCHAR(4000)) AS ResultJson;
        RETURN;
    END;

    SELECT
        @v_FK_IdAnioActual = cmab.FKIdAnio_SIS,
        @v_FK_IdMesActual = cmab.FKIdMes_SIS
    FROM [CONTA].[MesActual] AS cmab
    WHERE cmab.Actual = 1;

    IF @v_FK_IdAnioActual IS NULL OR @v_FK_IdMesActual IS NULL
    BEGIN
        SET @message = CONCAT('ERROR: Verifique el anio y mes actual que pretende cerrar, Verifique la tabla ', 'CONTA.MesActual');
        SELECT CAST(JSON_QUERY(CONCAT('{', '"tipo":"ERROR"', ',', '"mensaje":"', @message, '"', ',', '"liga":""', '}')) AS NVARCHAR(4000)) AS ResultJson;
        RETURN;
    END;

    SET @v_FK_IdMesSiguiente = CASE WHEN @v_FK_IdMesActual + 1 > 13 THEN 1 ELSE @v_FK_IdMesActual + 1 END;
    SET @v_FK_IdAnioSiguiente = CASE WHEN @v_FK_IdMesActual + 1 > 13 THEN @v_FK_IdAnioActual + 1 ELSE @v_FK_IdAnioActual END;
    SET @v_FK_IdMesAnterior = CASE WHEN @v_FK_IdMesActual = 1 THEN 13 ELSE @v_FK_IdMesActual - 1 END;
    SET @v_FK_IdAnioAnterior = CASE WHEN @v_FK_IdMesActual = 1 THEN @v_FK_IdAnioActual - 1 ELSE @v_FK_IdAnioActual END;

    DECLARE @tmp_SaldoMensual TABLE
    (
        FKIdAnio_SIS INT,
        FKIdMes_SIS INT,
        FKIdCuentaContable INT,
        FKIdTipoCuenta_CONTA INT,
        SaldoInicial DECIMAL(38, 2),
        Cargos DECIMAL(38, 2),
        Abonos DECIMAL(38, 2),
        SaldoFinal DECIMAL(38, 2),
        FechaCreacion DATETIME2(6)
    );

    INSERT INTO @tmp_SaldoMensual
    (
        FKIdAnio_SIS,
        FKIdMes_SIS,
        FKIdCuentaContable,
        FKIdTipoCuenta_CONTA,
        SaldoInicial,
        Cargos,
        Abonos,
        SaldoFinal,
        FechaCreacion
    )
    SELECT
        @v_FK_IdAnioActual AS FKIdAnio_SIS,
        @v_FK_IdMesActual AS FKIdMes_SIS,
        cb.FKIdCuentaContable,
        scc2.FKIdTipoCuenta_CONTA,
        ISNULL(cb.SaldoFinal, 0) AS SaldoInicial,
        0 AS Cargos,
        0 AS Abonos,
        0 AS SaldoFinal,
        SYSDATETIME()
    FROM [CONTA].[SaldoMensual] AS cb
    INNER JOIN [CONTA].[CuentaContable] AS scc2 ON cb.FKIdCuentaContable = scc2.PKIdCuentaContable
    WHERE cb.FKIdAnio_SIS = @v_FK_IdAnioAnterior
      AND cb.FKIdMes_SIS = @v_FK_IdMesAnterior
      AND scc2.IsCuentaDetalle = 1
      AND cb.Activo = 1
      AND scc2.Activo = 1
    UNION ALL
    SELECT
        @v_FK_IdAnioActual AS FKIdAnio_SIS,
        @v_FK_IdMesActual AS FKIdMes_SIS,
        cdp.FKIdCuentaContable_CONTA,
        scc.FKIdTipoCuenta_CONTA,
        0 AS SaldoInicial,
        SUM(cdp.ImporteDebe) AS Cargos,
        SUM(cdp.ImporteHaber) AS Abonos,
        0 AS SaldoFinal,
        SYSDATETIME()
    FROM [CONTA].[Poliza] AS cp
    INNER JOIN [CONTA].[PolizaDetalle] AS cdp ON cdp.FKIdPoliza_CONTA = cp.PKIdPoliza
    INNER JOIN [CONTA].[CuentaContable] AS scc ON cdp.FKIdCuentaContable_CONTA = scc.PKIdCuentaContable
    WHERE cp.FKIdAnio_SIS = @v_FK_IdAnioActual
      AND cp.FKIdMes_SIS = @v_FK_IdMesActual
      AND scc.IsCuentaDetalle = 1
      AND cp.Activo = 1
      AND cdp.Activo = 1
    GROUP BY scc.FKIdTipoCuenta_CONTA, cdp.FKIdCuentaContable_CONTA;

    DELETE FROM [CONTA].[SaldoMensual]
    WHERE FKIdAnio_SIS = @v_FK_IdAnioActual
      AND FKIdMes_SIS = @v_FK_IdMesActual;

    INSERT INTO [CONTA].[SaldoMensual]
    (
        FKIdAnio_SIS,
        FKIdMes_SIS,
        FKIdCuentaContable,
        SaldoInicial,
        Cargos,
        Abonos,
        SaldoFinal,
        FechaCreacion
    )
    SELECT
        cb.FKIdAnio_SIS,
        cb.FKIdMes_SIS,
        cb.FKIdCuentaContable,
        ISNULL(SUM(cb.SaldoInicial), 0) AS SaldoInicial,
        ISNULL(SUM(cb.Cargos), 0) AS Cargos,
        ISNULL(SUM(cb.Abonos), 0) AS Abonos,
        CASE
            WHEN cb.FKIdTipoCuenta_CONTA = 1 THEN ISNULL(SUM(cb.SaldoInicial), 0) - ISNULL(SUM(cb.Cargos), 0) + ISNULL(SUM(cb.Abonos), 0)
            WHEN cb.FKIdTipoCuenta_CONTA = 2 THEN ISNULL(SUM(cb.SaldoInicial), 0) + ISNULL(SUM(cb.Cargos), 0) - ISNULL(SUM(cb.Abonos), 0)
            ELSE ISNULL(SUM(cb.SaldoInicial), 0) + ISNULL(SUM(cb.Cargos), 0) - ISNULL(SUM(cb.Abonos), 0)
        END AS SaldoFinal,
        MAX(cb.FechaCreacion) AS FechaCreacion
    FROM @tmp_SaldoMensual AS cb
    WHERE cb.FKIdAnio_SIS = @v_FK_IdAnioActual
      AND cb.FKIdMes_SIS = @v_FK_IdMesActual
    GROUP BY cb.FKIdAnio_SIS, cb.FKIdMes_SIS, cb.FKIdCuentaContable, cb.FKIdTipoCuenta_CONTA;

    UPDATE [CONTA].[MesActual]
    SET Actual = 0
    WHERE FKIdAnio_SIS = @v_FK_IdAnioActual
      AND FKIdMes_SIS = @v_FK_IdMesActual;

    INSERT INTO [CONTA].[MesActual]
    (
        FKIdAnio_SIS,
        FKIdMes_SIS,
        Actual,
        UsuarioCreacion,
        FechaCreacion,
        Activo
    )
    VALUES
    (
        @v_FK_IdAnioSiguiente,
        @v_FK_IdMesSiguiente,
        1,
        1,
        GETDATE(),
        1
    );

    SELECT
        @tipo = CONCAT('{', '"tipo":"', 'OK'),
        @message = CONCAT('Se cerro correctamente el mes de ', DATENAME(MONTH, DATEFROMPARTS(@v_FK_IdAnioActual, @v_FK_IdMesActual, 1)), ' ', CAST(@v_FK_IdAnioActual AS VARCHAR(10)));

    SELECT CAST(JSON_QUERY(CONCAT(@tipo, '"', ',', '"mensaje":"', @message, '"', ',', '"liga":": ', '', '"', '}')) AS NVARCHAR(4000)) AS ResultJson;
END
GO

PRINT N'Aplicando [CONTA].[SPR_LibroMayor] sin #temp para EFPT';
GO
CREATE OR ALTER PROCEDURE [CONTA].[SPR_LibroMayor]
    @p_FecInicio NVARCHAR(24) = NULL,
    @p_FecFin NVARCHAR(24) = NULL,
    @NumCuenta INT = NULL,
    @EsCierre INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF;

    DECLARE @FechaInicio DATETIME = ISNULL(TRY_CONVERT(DATETIME, @p_FecInicio), GETDATE());
    DECLARE @FechaFin DATETIME = ISNULL(TRY_CONVERT(DATETIME, @p_FecFin), @FechaInicio);
    DECLARE @Mes_Inicio INT = MONTH(@FechaInicio);
    DECLARE @Mes_Fin INT = MONTH(@FechaFin);
    DECLARE @FKIdAnio_SIS INT = (SELECT TOP (1) [PKIdAnio] FROM [SIS].[Anio] WHERE [Clave] = YEAR(@FechaInicio));
    DECLARE @Fk_IdMes__SIS_Anterior INT = @Mes_Inicio - 1;
    DECLARE @Fk_IdAnio__SIS_Anterior INT = @FKIdAnio_SIS - 1;

    DECLARE @tablaFirma TABLE
    (
        id INT IDENTITY(1, 1) NOT NULL,
        Funcion NVARCHAR(64) NULL,
        Nombre NVARCHAR(254) NULL
    );

    INSERT INTO @tablaFirma (Funcion, Nombre)
    SELECT
        F.Funcion,
        CONCAT(P.Nombre, ' ', P.Paterno, ' ', P.Materno) AS Nombre
    FROM [SIS].[Reporte] AS R WITH (NOLOCK)
    INNER JOIN [SIS].[FirmaAutorizada] AS F WITH (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
    INNER JOIN [RHCT].[Persona] AS P WITH (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
    WHERE R.Controlador = 'RepLibroMayor'
      AND R.Activo = 1
      AND F.Activo = 1;

    DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 1), N'');
    DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 2), N'');
    DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 3), N'');
    DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 1), N'');
    DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 2), N'');
    DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 3), N'');
    DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP (1) Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, ' ', Paterno, ' ', Materno) LIKE '%' + @Nombre1 + '%'), N'');
    DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP (1) Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, ' ', Paterno, ' ', Materno) LIKE '%' + @Nombre2 + '%'), N'');
    DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP (1) Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, ' ', Paterno, ' ', Materno) LIKE '%' + @Nombre3 + '%'), N'');

    IF @EsCierre = 1
    BEGIN
        SET @Mes_Inicio = 13;
        SET @Mes_Fin = 13;
    END;

    DECLARE @SaldoInicial TABLE (SaldoFinal DECIMAL(18, 2) NOT NULL);

    INSERT INTO @SaldoInicial (SaldoFinal)
    SELECT ISNULL(SaldoFinal, 0) AS SaldoFinal
    FROM [CONTA].[SaldoMensual]
    WHERE FKIdCuentaContable = @NumCuenta
      AND (
          (@Mes_Inicio = 1 AND FKIdMes_SIS = 13 AND FKIdAnio_SIS = @Fk_IdAnio__SIS_Anterior)
          OR
          (@Mes_Inicio <> 1 AND FKIdMes_SIS = @Fk_IdMes__SIS_Anterior AND FKIdAnio_SIS = @FKIdAnio_SIS)
      );

    DECLARE @tmp TABLE
    (
        num BIGINT NOT NULL,
        PKIdPoliza INT NOT NULL,
        PKIdPolizaDetalle INT NOT NULL,
        TipoCuenta NVARCHAR(10) NULL,
        Pk_IdCuenta INT NOT NULL,
        IniPeriodo VARCHAR(80) NULL,
        FinPeriodo VARCHAR(80) NULL,
        FechaActual VARCHAR(80) NULL,
        Cuenta VARCHAR(50) NULL,
        NombrePoliza VARCHAR(250) NULL,
        ClavePoliza VARCHAR(10) NULL,
        TipoPoliza VARCHAR(2) NULL,
        ConceptoMovimiento VARCHAR(631) NULL,
        SaldoInicial DECIMAL(18, 2) NOT NULL,
        Cargos DECIMAL(20, 4) NULL,
        Abonos DECIMAL(20, 4) NULL,
        Saldos DECIMAL(20, 4) NULL,
        TotalSaldos VARCHAR(1) NULL,
        totalCargos DECIMAL(38, 4) NULL,
        totalAbonos DECIMAL(38, 4) NULL,
        fechaPoliza VARCHAR(30) NULL,
        concepto VARCHAR(600) NULL
    );

    INSERT INTO @tmp
    (
        num,
        PKIdPoliza,
        PKIdPolizaDetalle,
        TipoCuenta,
        Pk_IdCuenta,
        IniPeriodo,
        FinPeriodo,
        FechaActual,
        Cuenta,
        NombrePoliza,
        ClavePoliza,
        TipoPoliza,
        ConceptoMovimiento,
        SaldoInicial,
        Cargos,
        Abonos,
        Saldos,
        TotalSaldos,
        totalCargos,
        totalAbonos,
        fechaPoliza,
        concepto
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY p.PKIdPoliza, dp.PKIdPolizaDetalle) AS num,
        p.PKIdPoliza,
        dp.PKIdPolizaDetalle,
        cc.TipoCuenta,
        cc.Pk_IdCuenta,
        CAST([dbo].[FechaMesNumeroToFechaMesNombre](CONVERT(VARCHAR(8), @FechaInicio, 112), 0) AS VARCHAR(80)) AS IniPeriodo,
        CAST([dbo].[FechaMesNumeroToFechaMesNombre](CONVERT(VARCHAR(8), @FechaFin, 112), 0) AS VARCHAR(80)) AS FinPeriodo,
        CAST([dbo].[FechaMesNumeroToFechaMesNombre](CONVERT(VARCHAR(8), GETDATE(), 112), 1) AS VARCHAR(80)) AS FechaActual,
        CAST(cc.ClaveOrd AS VARCHAR(50)) AS Cuenta,
        CAST(cc.Nombre AS VARCHAR(250)) AS NombrePoliza,
        CAST(p.ClavePoliza AS VARCHAR(10)) AS ClavePoliza,
        CAST(CASE
            WHEN p.FKIdTipoPoliza_SIS = 1 THEN 'Dr'
            WHEN p.FKIdTipoPoliza_SIS = 2 THEN 'Eg'
            WHEN p.FKIdTipoPoliza_SIS = 3 THEN 'Ig'
            WHEN p.FKIdTipoPoliza_SIS = 4 THEN 'Pr'
        END AS VARCHAR(2)) AS TipoPoliza,
        CAST(CONVERT(VARCHAR(10), p.FechaPoliza, 103) + ' ' + ISNULL(dp.Descripcion, '') AS VARCHAR(631)) AS ConceptoMovimiento,
        ISNULL((SELECT SUM(SaldoFinal) FROM @SaldoInicial), 0) AS SaldoInicial,
        dp.ImporteDebe AS Cargos,
        dp.ImporteHaber AS Abonos,
        dp.ImporteDebe AS Saldos,
        CAST('' AS VARCHAR(1)) AS TotalSaldos,
        (
            SELECT SUM(dp2.ImporteDebe)
            FROM [CONTA].[PolizaDetalle] AS dp2
            INNER JOIN [CONTA].[Poliza] AS p2 ON dp2.FKIdPoliza_CONTA = p2.PKIdPoliza
            INNER JOIN [CONTA].[VW_CUENTAS] AS cc2 ON dp2.FKIdCuentaContable_CONTA = cc2.Pk_IdCuenta
            WHERE cc2.Pk_IdCuenta = @NumCuenta
              AND p2.FechaPoliza BETWEEN @FechaInicio AND @FechaFin
              AND p2.FKIdMes_SIS BETWEEN @Mes_Inicio AND @Mes_Fin
              AND p2.Activo = 1
        ) AS totalCargos,
        (
            SELECT SUM(dp2.ImporteHaber)
            FROM [CONTA].[PolizaDetalle] AS dp2
            INNER JOIN [CONTA].[Poliza] AS p2 ON dp2.FKIdPoliza_CONTA = p2.PKIdPoliza
            INNER JOIN [CONTA].[VW_CUENTAS] AS cc2 ON dp2.FKIdCuentaContable_CONTA = cc2.Pk_IdCuenta
            WHERE cc2.Pk_IdCuenta = @NumCuenta
              AND p2.FechaPoliza BETWEEN @FechaInicio AND @FechaFin
              AND p2.FKIdMes_SIS BETWEEN @Mes_Inicio AND @Mes_Fin
              AND p2.Activo = 1
        ) AS totalAbonos,
        CAST(CONVERT(VARCHAR(10), p.FechaPoliza, 103) AS VARCHAR(30)) AS fechaPoliza,
        CAST(dp.Descripcion AS VARCHAR(600)) AS concepto
    FROM [CONTA].[PolizaDetalle] AS dp
    INNER JOIN [CONTA].[Poliza] AS p ON dp.FKIdPoliza_CONTA = p.PKIdPoliza
    INNER JOIN [CONTA].[VW_CUENTAS] AS cc ON dp.FKIdCuentaContable_CONTA = cc.Pk_IdCuenta
    WHERE cc.Pk_IdCuenta = @NumCuenta
      AND p.FechaPoliza BETWEEN @FechaInicio AND @FechaFin
      AND p.FKIdMes_SIS BETWEEN @Mes_Inicio AND @Mes_Fin
      AND p.Activo = 1;

    UPDATE T
    SET Saldos = CASE
        WHEN T.TipoCuenta = '1' THEN T.SaldoInicial - ISNULL(T.Cargos, 0) + ISNULL(T.Abonos, 0)
        WHEN T.TipoCuenta = '2' THEN T.SaldoInicial + ISNULL(T.Cargos, 0) - ISNULL(T.Abonos, 0)
        ELSE T.SaldoInicial + ISNULL(T.Cargos, 0) - ISNULL(T.Abonos, 0)
    END
    FROM @tmp AS T
    WHERE T.num = 1;

    DECLARE @TotalRegistros INT = (SELECT COUNT(num) FROM @tmp);
    DECLARE @Indice INT = 2;
    DECLARE @SaldoInicialActual DECIMAL(20, 4) = (SELECT Saldos FROM @tmp WHERE num = 1);

    WHILE @Indice <= @TotalRegistros
    BEGIN
        UPDATE T
        SET Saldos = CASE
            WHEN T.TipoCuenta = '1' THEN @SaldoInicialActual - ISNULL(T.Cargos, 0) + ISNULL(T.Abonos, 0)
            WHEN T.TipoCuenta = '2' THEN @SaldoInicialActual + ISNULL(T.Cargos, 0) - ISNULL(T.Abonos, 0)
            ELSE @SaldoInicialActual + ISNULL(T.Cargos, 0) - ISNULL(T.Abonos, 0)
        END
        FROM @tmp AS T
        WHERE T.num = @Indice;

        SET @SaldoInicialActual = (SELECT Saldos FROM @tmp WHERE num = @Indice);
        SET @Indice = @Indice + 1;
    END;

    SELECT
        num,
        PKIdPoliza,
        PKIdPolizaDetalle,
        TipoCuenta,
        Pk_IdCuenta,
        IniPeriodo,
        FinPeriodo,
        FechaActual,
        Cuenta,
        NombrePoliza,
        ClavePoliza,
        TipoPoliza,
        ConceptoMovimiento,
        SaldoInicial,
        Cargos,
        Abonos,
        Saldos,
        TotalSaldos,
        totalCargos,
        totalAbonos,
        fechaPoliza,
        concepto,
        CAST(@Funcion1 AS NVARCHAR(64)) AS Funcion1,
        CAST(@Funcion2 AS NVARCHAR(64)) AS Funcion2,
        CAST(@Funcion3 AS NVARCHAR(64)) AS Funcion3,
        CAST(@Nombre1 AS NVARCHAR(254)) AS Nombre1,
        CAST(@Nombre2 AS NVARCHAR(254)) AS Nombre2,
        CAST(@Nombre3 AS NVARCHAR(254)) AS Nombre3,
        CAST(@Puesto1 AS NVARCHAR(254)) AS Puesto1,
        CAST(@Puesto2 AS NVARCHAR(254)) AS Puesto2,
        CAST(@Puesto3 AS NVARCHAR(254)) AS Puesto3,
        CAST(CONCAT('DEL ', FORMAT(@FechaInicio, 'dd \de MMMM \del yyyy', 'es-MX'), ' AL ', FORMAT(@FechaFin, 'dd \de MMMM \del yyyy', 'es-MX')) AS NVARCHAR(128)) AS Titulo
    FROM @tmp
    ORDER BY num;
END
GO
