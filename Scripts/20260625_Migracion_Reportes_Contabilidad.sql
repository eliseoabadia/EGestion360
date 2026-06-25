-- Migracion de reportes Contabilidad desde BD_PRESUPUESTO hacia GestionEmpresarial
-- Generado automaticamente el 2026-06-25.
SET NOCOUNT ON;
GO
IF SCHEMA_ID(N'CONTA') IS NULL EXEC(N'CREATE SCHEMA [CONTA]');
GO
IF SCHEMA_ID(N'ALMA') IS NULL EXEC(N'CREATE SCHEMA [ALMA]');
GO
IF SCHEMA_ID(N'ORCO') IS NULL EXEC(N'CREATE SCHEMA [ORCO]');
GO
IF SCHEMA_ID(N'PRES') IS NULL EXEC(N'CREATE SCHEMA [PRES]');
GO
IF SCHEMA_ID(N'SICOP') IS NULL EXEC(N'CREATE SCHEMA [SICOP]');
GO
IF SCHEMA_ID(N'SIS') IS NULL EXEC(N'CREATE SCHEMA [SIS]');
GO
IF OBJECT_ID(N'SIS.Mes', N'V') IS NULL AND OBJECT_ID(N'SIS.Mes', N'U') IS NULL
    EXEC(N'CREATE VIEW [SIS].[Mes] AS SELECT CAST(1 AS int) AS PKIdMes');
GO
CREATE OR ALTER VIEW [SIS].[Mes]
AS
SELECT v.PKIdMes,
       v.Color,
       v.Descripcion,
       CAST(1 AS int) AS UsuarioCreacion,
       CONVERT(datetime2, '2024-01-01') AS FechaCreacion,
       CAST(NULL AS int) AS UsuarioModificacion,
       CAST(NULL AS datetime2) AS FechaModificacion,
       CAST(1 AS bit) AS Activo,
       v.Abreviatura
FROM (VALUES
    (1, N'#1976d2', N'Enero', 'ENE'),
    (2, N'#1976d2', N'Febrero', 'FEB'),
    (3, N'#1976d2', N'Marzo', 'MAR'),
    (4, N'#1976d2', N'Abril', 'ABR'),
    (5, N'#1976d2', N'Mayo', 'MAY'),
    (6, N'#1976d2', N'Junio', 'JUN'),
    (7, N'#1976d2', N'Julio', 'JUL'),
    (8, N'#1976d2', N'Agosto', 'AGO'),
    (9, N'#1976d2', N'Septiembre', 'SEP'),
    (10, N'#1976d2', N'Octubre', 'OCT'),
    (11, N'#1976d2', N'Noviembre', 'NOV'),
    (12, N'#1976d2', N'Diciembre', 'DIC'),
    (13, N'#455a64', N'Mes trece', 'M13')
) v(PKIdMes, Color, Descripcion, Abreviatura);
GO

IF OBJECT_ID(N'SIS.AccionAutorizar', N'U') IS NULL
BEGIN
    CREATE TABLE [SIS].[AccionAutorizar]
    (
        [PkIdAccionAutorizar] int NOT NULL CONSTRAINT [PK_AccionAutorizar] PRIMARY KEY,
        [Accion] nvarchar(150) NOT NULL,
        [Comentario] nvarchar(500) NULL,
        [UsuarioCreacion] int NOT NULL CONSTRAINT [DF_AccionAutorizar_UsuarioCreacion] DEFAULT (1),
        [FechaCreacion] datetime2 NOT NULL CONSTRAINT [DF_AccionAutorizar_FechaCreacion] DEFAULT (sysdatetime()),
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2 NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_AccionAutorizar_Activo] DEFAULT (1)
    );
END
GO
IF NOT EXISTS (SELECT 1 FROM [SIS].[AccionAutorizar])
BEGIN
    INSERT INTO [SIS].[AccionAutorizar] ([PkIdAccionAutorizar], [Accion], [Comentario], [UsuarioCreacion], [FechaCreacion], [Activo]) VALUES
    (1, N'Solicitud creada', NULL, 1, sysdatetime(), 1),
    (2, N'Solicitar Autorizacion', NULL, 1, sysdatetime(), 1),
    (3, N'Autorizar Adecuacion', NULL, 1, sysdatetime(), 1),
    (4, N'Rechazar Adecuacion', NULL, 1, sysdatetime(), 1);
END
GO

IF OBJECT_ID(N'CONTA.MesActual', N'U') IS NULL
BEGIN
    CREATE TABLE [CONTA].[MesActual]
    (
        [PKIdMesActual] int IDENTITY(1,1) NOT NULL CONSTRAINT [PK_MesActual] PRIMARY KEY,
        [FKIdAnio_SIS] int NOT NULL,
        [FKIdMes_SIS] int NOT NULL,
        [Actual] tinyint NOT NULL,
        [UsuarioCreacion] int NOT NULL CONSTRAINT [DF_MesActual_UsuarioCreacion] DEFAULT (1),
        [FechaCreacion] datetime2 NOT NULL CONSTRAINT [DF_MesActual_FechaCreacion] DEFAULT (sysdatetime()),
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2 NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_MesActual_Activo] DEFAULT (1)
    );
END
GO
IF NOT EXISTS (SELECT 1 FROM [CONTA].[MesActual] WHERE [Actual] = 1 AND [Activo] = 1)
BEGIN
    INSERT INTO [CONTA].[MesActual] ([FKIdAnio_SIS], [FKIdMes_SIS], [Actual], [UsuarioCreacion], [FechaCreacion], [Activo])
    VALUES (YEAR(GETDATE()), MONTH(GETDATE()), 1, 1, sysdatetime(), 1);
END
GO

IF OBJECT_ID(N'CONTA.SaldoMensual', N'U') IS NULL
BEGIN
    CREATE TABLE [CONTA].[SaldoMensual]
    (
        [PKIdSaldoMensual] int IDENTITY(1,1) NOT NULL CONSTRAINT [PK_SaldoMensual] PRIMARY KEY,
        [FKIdAnio_SIS] int NOT NULL,
        [FKIdMes_SIS] int NOT NULL,
        [FKIdCuentaContable] int NOT NULL,
        [SaldoInicial] decimal(20,2) NULL,
        [Cargos] decimal(20,2) NULL,
        [Abonos] decimal(20,2) NULL,
        [SaldoFinal] decimal(20,2) NULL,
        [UsuarioCreacion] int NOT NULL CONSTRAINT [DF_SaldoMensual_UsuarioCreacion] DEFAULT (1),
        [FechaCreacion] datetime2 NOT NULL CONSTRAINT [DF_SaldoMensual_FechaCreacion] DEFAULT (sysdatetime()),
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2 NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_SaldoMensual_Activo] DEFAULT (1)
    );
END
GO

IF OBJECT_ID(N'CONTA.Hist_SaldoMensual', N'U') IS NULL
BEGIN
    CREATE TABLE [CONTA].[Hist_SaldoMensual]
    (
        [PKIdHistSaldoMensual] int IDENTITY(1,1) NOT NULL CONSTRAINT [PK_HistSaldoMensual] PRIMARY KEY,
        [FKIdCuenta] int NULL,
        [FKIdAnio_SIS] int NULL,
        [FKIdMes_SIS] int NULL,
        [Anio] int NULL,
        [Mes] varchar(25) NOT NULL,
        [Cuentastr] varchar(100) NOT NULL,
        [NombreCta] varchar(500) NOT NULL,
        [Cuentastr_Esp] varchar(100) NOT NULL,
        [NombreCta_Esp] varchar(500) NOT NULL,
        [SaldoInicial] decimal(18,0) NULL,
        [Cargos] decimal(18,0) NULL,
        [Abonos] decimal(18,0) NULL,
        [SaldoFinal] decimal(18,0) NULL,
        [FechaCreacion] datetime2 NULL,
        [nivel] int NULL
    );
END
GO

CREATE OR ALTER VIEW [CONTA].[Vw_Cuentas]
AS
SELECT cc.PKIdCuentaContable AS PkIdCuenta,
       cc.PKIdCuentaContable AS Pk_IdCuenta,
       cc.ClaveOrd AS Clave,
       cc.Padre,
       cc.Hijo,
       cc.NivelCuenta,
       cc.ClaveOrd,
       cc.ClaveOrd + ' ' + cc.Descripcion AS ClaveNombre,
       cc.ClaveOrd + ' ' + cc.Descripcion AS ClaveNombr,
       cc.Descripcion AS Nombre,
       cc.Descripcion,
       cc.Activo,
       cc.TipoCuenta
FROM [CONTA].[CuentaContable] cc
WHERE cc.Activo = 1;
GO

CREATE OR ALTER VIEW [CONTA].[VW_CUENTAS_LibroMayor]
AS
SELECT cc.Pk_IdCuenta,
       cc.NivelCuenta,
       cc.ClaveOrd,
       cc.ClaveNombre,
       cc.Nombre,
       po.FechaPoliza,
       YEAR(po.FechaPoliza) AS AnioPoliza,
       UPPER(FORMAT(po.FechaPoliza, 'MMMM', 'es-MX')) AS MesPoliza
FROM [CONTA].[Vw_Cuentas] cc
JOIN (
    SELECT dp.FKIdCuentaContable_CONTA, p.FechaPoliza
    FROM [CONTA].[Poliza] p WITH (NOLOCK)
    INNER JOIN [CONTA].[PolizaDetalle] dp WITH (NOLOCK) ON p.PKIdPoliza = dp.FKIdPoliza_CONTA
    WHERE p.Activo = 1 AND dp.Activo = 1
) po ON po.FKIdCuentaContable_CONTA = cc.Pk_IdCuenta;
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SP_SaldoMensual]';
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
	DECLARE @v_AnioActual INT;

	DECLARE @v_FechaInicio Date;
 
    DECLARE @v_FK_IdMesSiguiente INT;
	DECLARE @v_FK_IdAnioSiguiente INT;
	DECLARE @v_mesesActuales INT;

	DECLARE @tipo NVARCHAR(100)
	DECLARE @message NVARCHAR(100)

	SELECT @v_mesesActuales = COUNT(cmab.Actual ) 
	FROM CONTA.MesActual cmab WHERE cmab.Actual = 1;


	-- Se valida que no haya mas de un mes actual en la tabla
	IF @v_mesesActuales <> 1
    BEGIN

		SET @message = CONCAT('ERROR: Verifique el año y mes actual que pretende cerrar, Verifique la tabla ','CONTA.MesActual')
		SELECT JSON_QUERY( 
						CONCAT( '{', '"tipo":"', 'ERROR', 
									   '",', '"mensaje":"', @message, 
									   '",', '"liga":"', '', '"', '}' ) 
					) 
				AS ResultJson 

		--SELECT 
		--	(
		--		SELECT 
		--			'ERROR' AS tipo,
		--			'ERROR: Verifique el año y mes actual que pretende cerrar. Revise la tabla CONTA.MesActual.' AS mensaje,
		--			'CONTA.MesActual' AS liga
		--		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		--	) AS result;

        RETURN;
    END

	-- Se valida que haya un mes actual configurado
	SELECT @v_FK_IdAnioActual = cmab.FKIdAnio_SIS, @v_FK_IdMesActual = cmab.FKIdMes_SIS 
	FROM CONTA.MesActual cmab WHERE cmab.Actual = 1;

	IF @v_FK_IdAnioActual IS NULL OR @v_FK_IdMesActual IS NULL 
    BEGIN 

		SET @message = CONCAT('ERROR: Verifique el año y mes actual que pretende cerrar, Verifique la tabla ','CONTA.MesActual')
		SELECT JSON_QUERY( 
						CONCAT( '{', '"tipo":"', 'ERROR', 
									   '",', '"mensaje":"', @message, 
									   '",', '"liga":"', '', '"', '}' ) 
					) 
				AS ResultJson 

		--SELECT 
		--	(
		--		SELECT 
		--			'ERROR' AS tipo,
		--			'ERROR: ERROR Verifique el año y mes actual que pretende cerrar, Verifique la tabla' AS mensaje,
		--			'CONTA.MesActual' AS liga
		--		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		--	) AS result;

    END 

	-- Se configura el mes año anterior y siguiente

	SET @v_FK_IdMesSiguiente = (CASE WHEN @v_FK_IdMesActual + 1 > 13 THEN 1 ELSE @v_FK_IdMesActual + 1 END);

	SET @v_FK_IdAnioSiguiente = (CASE WHEN @v_FK_IdMesActual + 1 > 13 THEN @v_FK_IdAnioActual + 1 ELSE @v_FK_IdAnioActual  END);

	SET @v_FK_IdMesAnterior = (CASE WHEN @v_FK_IdMesActual = 1 THEN 13 ELSE @v_FK_IdMesActual - 1 END);

	SET @v_FK_IdAnioAnterior = (CASE WHEN @v_FK_IdMesActual = 1  THEN @v_FK_IdAnioActual - 1 ELSE @v_FK_IdAnioActual  END);
	

	--Se trea una tabla temporal para el saldo mensual
   IF OBJECT_ID('tempdb..#tmp_SaldoMensual') IS NOT NULL DROP TABLE #tmp_SaldoMensual;
    CREATE TABLE #tmp_SaldoMensual (
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

	--Se trea una tabla temporal para el saldo mensual agrupado
   	IF OBJECT_ID('tempdb..#tmp_SaldoMensual_Agrup') IS NOT NULL DROP TABLE #tmp_SaldoMensual_Agrup;
	CREATE TABLE #tmp_SaldoMensual_Agrup  
	(
		FKIdAnio_SIS INT
		, FKIdMes_SIS INT
		, FKIdCuentaContable INT
		, FKIdTipoCuenta_CONTA int
		, Anio INT
		, Mes VarChar(50)
		, Cuenta VarChar(5)
		, SubCuenta VarChar(5)
		, SubSubCuenta VarChar(5)
		, SubSubSubCuenta VarChar(5)
		, SubSubSubSubCuenta VarChar(5)
		, S5 VarChar(5)
		, S6 VarChar(5)
		, s7 VarChar(5)		
		, S8 VarChar(5)
		, S9 VarChar(5)
		, s10 VarChar(5)
		, SaldoInicial DECIMAL(38,2)
		, Cargos DECIMAL(38,2)
		, Abonos DECIMAL(38,2)
		, SaldoFinal DECIMAL(38,2)
		, FechaCreacion datetime2(6)		
	);


	--Se trea una tabla temporal para el saldo mensual agrupado por nivel   
	IF OBJECT_ID('tempdb..#tmp_SaldoMensual_Agrup2') IS NOT NULL DROP TABLE #tmp_SaldoMensual_Agrup2;
	CREATE TABLE #tmp_SaldoMensual_Agrup2
	(
		FKIdAnio_SIS INT
		, FKIdMes_SIS INT
		, Anio INT
		, Mes VarChar(50)
		, Cuentastr VarChar(30)
		, EspaciosNivel Varchar(14)
		, SaldoInicial DECIMAL(38,2)
		, Cargos DECIMAL(38,2)
		, Abonos DECIMAL(38,2)
		, SaldoFinal DECIMAL(38,2)
		, FechaCreacion datetime2(6)	
		, nivel Int
	);

	--PRINT 'SE CREARON LAS TABLAS'

 INSERT INTO #tmp_SaldoMensual
 (FKIdAnio_SIS, FKIdMes_SIS, FKIdCuentaContable, FKIdTipoCuenta_CONTA, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
 
	--Saldos registrados en el cierre anterior del mes anterior
	SELECT @v_FK_IdAnioActual AS FKIdAnio_SIS
	, @v_FK_IdMesActual AS FKIdMes_SIS
	, cb.FKIdCuentaContable
	, scc2.FKIdTipoCuenta_CONTA 
	, CASE WHEN cb.SaldoFinal IS NULL THEN  0 ELSE cb.SaldoFinal END AS SaldoInicial
	, 0 AS Debe  --
	, 0 AS Haber --
	, 0 as SaldoFinal
	, GETDATE()   
	FROM CONTA.SaldoMensual cb 
	JOIN CONTA.CuentaContable scc2 ON cb.FKIdCuentaContable = scc2.PKIdCuentaContable  
	WHERE cb.FKIdAnio_SIS = @v_FK_IdAnioAnterior 
	AND cb.FKIdMes_SIS =  @v_FK_IdMesAnterior
	AND scc2.IsCuentaDetalle =1
	AND cb.Activo = 1 AND scc2.Activo = 1
	
	UNION ALL
	--Movimientos del mes actual
	SELECT @v_FK_IdAnioActual AS FKIdAnio_SIS
	, @v_FK_IdMesActual AS FKIdMes_SIS
	, cdp.FKIdCuentaContable_CONTA
	, scc.FKIdTipoCuenta_CONTA 
	, 0 as SaldoInicial 
	, SUM(cdp.ImporteDebe) AS Debe 
	, SUM( cdp.ImporteHaber) AS Haber
	, 0 AS Saldo
	, GETDATE()  
	FROM CONTA.Poliza cp
	JOIN CONTA.PolizaDetalle cdp ON cdp.FKIdPoliza_CONTA = cp.PKIdPoliza  
	JOIN CONTA.CuentaContable scc ON cdp.FKIdCuentaContable_CONTA = scc.PKIdCuentaContable 	
	WHERE cp.FKIdAnio_SIS =  @v_FK_IdAnioActual 
	And cp.FKIdMes_SIS  =  @v_FK_IdMesActual
	AND scc.IsCuentaDetalle = 1
	AND cp.Activo = 1 AND cdp.Activo = 1
	GROUP BY scc.FKIdTipoCuenta_CONTA , cdp.FKIdCuentaContable_CONTA   
	;

	

DELETE FROM  CONTA.SaldoMensual 
WHERE FKIdAnio_SIS = @v_FK_IdAnioActual AND FKIdMes_SIS = @v_FK_IdMesActual;

INSERT INTO CONTA.SaldoMensual 
	(FKIdAnio_SIS, FKIdMes_SIS, FKIdCuentaContable, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)

	SELECT cb.FKIdAnio_SIS
	, cb.FKIdMes_SIS
	, cb.FKIdCuentaContable
	, ISNULL(SUM(SaldoInicial), 0) as SaldoInicial
	, ISNULL(SUM(Cargos), 0) as Cargos
	, ISNULL(SUM(Abonos), 0) as Abonos
	
	, CASE 	WHEN cb.FKIdTipoCuenta_CONTA = 1 THEN ISNULL(SUM(cb.SaldoInicial), 0) - ISNULL(SUM(cb.Cargos), 0) + ISNULL(SUM( cb.Abonos), 0)
			WHEN cb.FKIdTipoCuenta_CONTA = 2 THEN ISNULL(SUM(cb.SaldoInicial), 0) + ISNULL(SUM(cb.Cargos), 0) - ISNULL(SUM( cb.Abonos), 0)	
	  END AS SaldoFinal
	
	, FechaCreacion   
	FROM #tmp_SaldoMensual cb 
	WHERE cb.FKIdAnio_SIS = @v_FK_IdAnioActual AND cb.FKIdMes_SIS = @v_FK_IdMesActual
	GROUP BY cb.FKIdAnio_SIS, cb.FKIdMes_SIS, cb.FKIdCuentaContable, FKIdTipoCuenta_CONTA, FechaCreacion
	;

/*
	
	INSERT INTO #tmp_SaldoMensual_Agrup
  	(FKIdAnio_SIS, FKIdMes_SIS, FKIdCuentaContable
			, Anio
			, Mes
			, Cuenta 
			, SubCuenta
			, SubSubCuenta
			, SubSubSubCuenta 
			, SubSubSubSubCuenta 
			, S5 
			, S6 
			, s7 			
			, S8 
			, S9 
			, s10 
			,SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)


	SELECT cb.FKIdAnio_SIS
		, cb.FKIdMes_SIS
		, cb.FKIdCuentaContable
		, sa.Clave as Anio
		, sm.Descripcion as Mes
		, scc.Cuenta 
		, scc.SubCuenta 
		, scc.SubSubCuenta
		, scc.SubSubSubCuenta
		, scc.SubSubSubSubCuenta 
		, scc.S5 
		, scc.S6 
		, scc.s7		
		, scc.S8 
		, scc.S9 
		, scc.S10
		, SUM(SaldoInicial) AS SaldoInicial
		, SUM(Cargos) AS Cargos
		, SUM(Abonos) AS Abonos

		, CASE 	WHEN cb.FKIdTipoCuenta_CONTA = 1 THEN SUM(cb.SaldoInicial) - SUM(cb.Cargos) + SUM( cb.Abonos)
				WHEN cb.FKIdTipoCuenta_CONTA = 2 THEN SUM(cb.SaldoInicial) + SUM(cb.Cargos) - SUM( cb.Abonos)	
  		END AS SaldoFinal
		, cb.FechaCreacion   
	FROM #tmp_SaldoMensual cb 
		JOIN CONTA.CuentaContable scc ON cb.FKIdCuentaContable = scc.PKIdCuentaContable 
		JOIN SIS.Anio sa ON cb.FKIdAnio_SIS = sa.PKIdAnio 
		JOIN SIS.Mes sm ON cb.FKIdMes_SIS = sm.PKIdMes 
	GROUP BY cb.FKIdAnio_SIS, cb.FKIdMes_SIS, cb.FKIdCuentaContable, cb.FechaCreacion;
		

	
	INSERT INTO #tmp_SaldoMensual_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuentastr, EspaciosNivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
	SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, S6, s7, s8, s9, s10 ) AS Cuentastr
	,'                    ' AS EspaciosNivel
	,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
	FROM #tmp_SaldoMensual_Agrup 
	GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, S6, s7, s8, s9, s10, FechaCreacion;
	
	INSERT INTO #tmp_SaldoMensual_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuentastr, EspaciosNivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
	SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, S6,  s7, s8, s9, '0000' ) AS Cuentastr
	,'                  ' AS EspaciosNivel
	,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
	FROM #tmp_SaldoMensual_Agrup 
	GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, S6, s7, s8, s9, FechaCreacion;
	
	INSERT INTO #tmp_SaldoMensual_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
	SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, S6, s7, s8, '0000', '0000') AS Cuentastr
	,'                ' AS EspaciosNivel
	,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
	FROM #tmp_SaldoMensual_Agrup 
	GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5,S6, s7, s8, FechaCreacion;
	
	INSERT INTO #tmp_SaldoMensual_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
	SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes,CONCAT( Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, s6,  s7, '0000', '0000', '0000') AS Cuentastr
	,'              ' AS EspaciosNivel
	,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
	FROM #tmp_SaldoMensual_Agrup 
	GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, S6, s7, FechaCreacion;
	
	INSERT INTO #tmp_SaldoMensual_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
	SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes,CONCAT( Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, s6,  '0000', '0000', '0000', '0000') AS Cuentastr
	,'            ' AS EspaciosNivel
	,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
	FROM #tmp_SaldoMensual_Agrup 
	GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, S6, FechaCreacion;

	INSERT INTO #tmp_SaldoMensual_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
	SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, S5, '0000', '0000', '0000', '0000', '0000') AS Cuentastr
	,'          ' AS EspaciosNivel
	,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
	FROM #tmp_SaldoMensual_Agrup 
	GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, S5, FechaCreacion;
	
	INSERT INTO #tmp_SaldoMensual_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
	SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, '0000', '0000', '0000', '0000', '0000', '0000') AS Cuentastr
	,'        ' AS EspaciosNivel
	,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
	FROM #tmp_SaldoMensual_Agrup 
	GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, FechaCreacion;
	
	INSERT INTO #tmp_SaldoMensual_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
	SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, SubCuenta, SubSubCuenta, '0', '0000', '0000', '0000', '0000', '0000', '0000') AS Cuentastr
	,'      ' AS EspaciosNivel
	,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
	FROM #tmp_SaldoMensual_Agrup 
	GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, FechaCreacion;

	INSERT INTO #tmp_SaldoMensual_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
	SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, SubCuenta, '0', '0', '0000', '0000', '0000', '0000', '0000', '0000') AS Cuentastr
	,'    ' AS EspaciosNivel
	,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
	FROM #tmp_SaldoMensual_Agrup 
	GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, FechaCreacion;

	
	INSERT INTO #tmp_SaldoMensual_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
	SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, '0', '0', '0', '0000', '0000', '0000', '0000', '0000', '0000') AS Cuentastr
	,'  ' EspaciosNivel
	,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
	FROM #tmp_SaldoMensual_Agrup 
	GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, FechaCreacion;
*/
	UPDATE CONTA.MesActual
	SET Actual = 0
	WHERE 
	FKIdAnio_SIS = @v_FK_IdAnioActual AND FKIdMes_SIS = @v_FK_IdMesActual 
	;

	INSERT INTO CONTA.MesActual
	(FKIdAnio_SIS, FKIdMes_SIS, Actual, UsuarioCreacion, FechaCreacion, Activo)
	VALUES(@v_FK_IdAnioSiguiente, @v_FK_IdMesSiguiente, 1, 1, GETDATE(),  1)
	;

		SELECT	@tipo =  CONCAT('{', '"tipo":"', 'OK'),
					@message = CONCAT('Se cerró correctamente el mes de ', DATENAME(MONTH, DATEFROMPARTS(@v_FK_IdAnioActual, @v_FK_IdMesActual, 1)), ' ', CAST(@v_FK_IdAnioActual AS VARCHAR));

	SELECT JSON_QUERY( 
						CONCAT( @tipo,   '",', '"mensaje":"', @message, 
									   '",', '"liga":": ', '', '"', '}' ) 
					) 
				AS ResultJson

	--SELECT 
	--	(
	--		SELECT 
	--			'OK' AS tipo,
	--			'Ok: Se Cerro correctamente el mes.' + CAST(@v_FK_IdMesActual AS VARCHAR) + ' ' + CAST(@v_FK_IdAnioActual AS VARCHAR)  AS mensaje,
	--			'mes' AS liga
	--		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	--	) AS result;

		
END;

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_AlmacéndeMateriales]';
GO
-- exec [CONTA].[SPR_AlmacéndeMateriales] '2025-01-01','2025-12-31'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_AlmacéndeMateriales]

@p_FecInicio nvarchar(24),
@p_FecFin nvarchar(24)
AS
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;


DECLARE	  @FechaInicio DATE = @p_FecInicio
		, @FechaFin DATE = @p_FecFin
		--, @Anio int
		, @titulo Varchar(60) 
		
		SET @titulo = (SELECT 'Al: ' + FORMAT(@FechaFin, 'dd \DE MMMM \DEL yyyy', 'es-MX'))

		
		
SET LANGUAGE 'español';
			---***********************
			WITH Existencias   -- @Tabla que agrupa, sumariza las existencias
				AS (			

						SELECT TB.PK_IdTipoBien
						, TB.FK_IdPartida__SIS
						, GB.CLAVE_CUCOP AS CUCOP
						,  GB.CABM_ACT + ' / ' + GB.ClaveAN  AS CABMS
						,   TB.CodigoClave
						, TB.Descripcion
						, SUM(aa.Cantidad) AS Existencias
						, au.Descripcion AS Unidades
						, aa.FKIdAnio_SIS, CAST('' AS VARCHAR(MAX)) AS Message
						, IIF(TB.Cantidad_Equivalente > 1,TB.FK_IdUnidades_Equivalente,TB.FK_IdUnidades__ALMA) AS FK_IdUnidades__ALMA
						,aa.Costo AS CostoUnitario  -- Llenar en el stript desde el costo de factura
						,aa.Costo AS CostoPromedio  -- Calcular
						FROM     ALMA.Almacen AS aa 
								INNER JOIN SICOP.TipoBien AS TB ON aa.FK_IdTipoBien__SICOP = TB.PK_IdTipoBien 
								INNER JOIN ALMA.Unidades AS au ON IIF(TB.Cantidad_Equivalente > 1,TB.FK_IdUnidades_Equivalente,TB.FK_IdUnidades__ALMA) = au.PK_IdUnidades 
								INNER JOIN SICOP.GrupoBien as GB ON TB.FK_IdGrupoBien__SICOP = GB.PK_IdGrupoBien
						WHERE aa.InventarioCerrado = 0 AND AA.Activo = 1 AND TB.Activo = 1 AND AU.Activo = 1 AND GB.Activo = 1
						GROUP BY TB.PK_IdTipoBien, TB.FK_IdPartida__SIS,  GB.CLAVE_CUCOP,  GB.CABM_ACT, GB.ClaveAN, TB.CodigoClave, TB.Descripcion, au.Descripcion, aa.FKIdAnio_SIS, IIF(TB.Cantidad_Equivalente > 1,TB.FK_IdUnidades_Equivalente,TB.FK_IdUnidades__ALMA), aa.Costo

						UNION ALL 

						SELECT TB.PK_IdTipoBien, TB.FK_IdPartida__SIS
							, GB.CLAVE_CUCOP AS CUCOP
							, GB.CABM_ACT + ' / ' + GB.ClaveAN  AS CABMS
							, TB.CodigoClave
							, TB.Descripcion
							, CI.Existencias
							, AU.Descripcion AS Unidades
							, CI.FKIdAnio_SIS
							, '' AS Message	
							, IIF(TB.Cantidad_Equivalente > 1, TB.FK_IdUnidades_Equivalente,TB.FK_IdUnidades__ALMA) AS FK_IdUnidades__ALMA
							, CI.CostoExistencias  -- TODO  Cambiar a CostoUnitario despues de la magia de Alex
							, CI.CostoPromedioEntradasMes
						FROM     SICOP.TipoBien AS TB 
								INNER JOIN SICOP.GrupoBien GB ON TB.FK_IdGrupoBien__SICOP = GB.PK_IdGrupoBien
								INNER JOIN ALMA.Unidades AS AU ON IIF(TB.Cantidad_Equivalente > 1,TB.FK_IdUnidades_Equivalente,TB.FK_IdUnidades__ALMA) = AU.PK_IdUnidades 
								RIGHT OUTER JOIN ALMA.CierreInventario AS CI ON TB.PK_IdTipoBien = CI.FK_IdTipoBien__SICOP
						WHERE TB.Activo = 1 AND GB.Activo = 1 AND AU.Activo = 1 AND CI.Activo = 1
				)	

				SELECT	E.[PK_IdTipoBien] AS id,
					ISNULL(CC.ClaveNombre, 'Configure Cuenta') as CODIGO,
					-- E.[FK_IdPartida__SIS],
					-- E.[CUCOP],
					-- E.[CABMS],
					-- E.[CodigoClave],
					E.[Descripcion]  [S/PG],
					SUM(E.[Existencias]) AS CANTIDAD,
					E.[Unidades] AS UM,
					-- 0 [FKIdAnio_SIS] ,
					--E.FK_IdUnidades__ALMA,
					isnull(MAX(E.CostoPromedio),0) AS CU,  --TODO Revisar estas formulas  ROG 20250525
					SUM(E.[Existencias]) * isnull(MAX(E.CostoPromedio),0) AS MONTO
					into #tlbAlmacéndeMateriales
				FROM Existencias E 
				JOIN SICOP.TipoBien TB ON E.PK_IdTipoBien = TB.PK_IdTipoBien
				LEFT JOIN CONTA.VW_CUENTAS CC ON TB.FKIdCuentaContable_CONTA = CC.Pk_IdCuenta
				WHERE TB.Activo = 1
				GROUP BY 
					CC.ClaveNombre,
					E.[PK_IdTipoBien],
					E.[FK_IdPartida__SIS],
					E.[CUCOP],
					E.[CABMS],
					E.[CodigoClave],
					E.[Descripcion] ,
					E.[Unidades],
					--E.[FKIdAnio_SIS],
					TB.ExistenciaMinima, 
					TB.ExistenciaMaxima,
					E.FK_IdUnidades__ALMA




	select * , titulo = @titulo   --'AL 31 DE DICIEMBRE DE ' + CAST(@Anio AS varchar(4))
	from #tlbAlmacéndeMateriales
	--FIN
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_CambiosSituacionFinanciera]';
GO
CREATE OR ALTER PROCEDURE [CONTA].[SPR_CambiosSituacionFinanciera]
	@FechaInicio DATETIME,-- = '20160101',
	@IsCierre BIT = 0
AS
BEGIN
set fmtonly off;
	DECLARE @Mes INT = MONTH(@FechaInicio)
	      , @Anio INT = (SELECT PKIdAnio FROM SIS.ANIO AS A  WHERE A.Clave = YEAR(@FechaInicio))
	--SELECT @Mes, @Anio 


	--================================================================
		DECLARE
		 @4212000000 DECIMAL(18, 2)		= (SELECT X.SaldoFinal FROM conta.SaldoMensual AS X WHERE X.FKIdCuentaContable = '4212000000' AND X.FKIdAnio_SIS = @Anio AND X.FKIdMes_SIS = @Mes)
		,@OtrosIngresos DECIMAL(18, 2)	= (SELECT SUM(X.SaldoFinal) FROM conta.SaldoMensual AS X WHERE X.FKIdCuentaContable IN ('4100000000','4213000000', '4300000000','4413000000') AND X.FKIdAnio_SIS = @Anio AND X.FKIdMes_SIS = @Mes)
		,@5110000000 DECIMAL(18, 2)		= (SELECT X.SaldoFinal FROM conta.SaldoMensual AS X WHERE X.FKIdCuentaContable = '5110000000' AND X.FKIdAnio_SIS = @Anio AND X.FKIdMes_SIS = @Mes)
		,@5120000000 DECIMAL(18, 2)		= (SELECT X.SaldoFinal FROM conta.SaldoMensual AS X WHERE X.FKIdCuentaContable = '5120000000' AND X.FKIdAnio_SIS = @Anio AND X.FKIdMes_SIS = @Mes)
		,@5130000000 DECIMAL(18, 2)		= (SELECT X.SaldoFinal FROM conta.SaldoMensual AS X WHERE X.FKIdCuentaContable = '5130000000' AND X.FKIdAnio_SIS = @Anio AND X.FKIdMes_SIS = @Mes)
		,@5212200000 DECIMAL(18, 2)		= (SELECT X.SaldoFinal FROM conta.SaldoMensual AS X WHERE X.FKIdCuentaContable = '5212200000' AND X.FKIdAnio_SIS = @Anio AND X.FKIdMes_SIS = @Mes)
		,@5080000000 DECIMAL(18, 2)		= (SELECT X.SaldoFinal FROM conta.SaldoMensual AS X WHERE X.FKIdCuentaContable = '5280000000' AND X.FKIdAnio_SIS = @Anio AND X.FKIdMes_SIS = @Mes)
		,@5500000000 DECIMAL(18, 2)		= (SELECT X.SaldoFinal FROM conta.SaldoMensual AS X WHERE X.FKIdCuentaContable = '5510000000' AND X.FKIdAnio_SIS = @Anio AND X.FKIdMes_SIS = @Mes)-- Esta cuenta se cambio por la 550
		,@5590000000 DECIMAL(18, 2)		= (SELECT X.SaldoFinal FROM conta.SaldoMensual AS X WHERE X.FKIdCuentaContable = '5590000000' AND X.FKIdAnio_SIS = @Anio AND X.FKIdMes_SIS = @Mes)

	DECLARE @T_PATASYOA DECIMAL(18, 2) = @4212000000
	DECLARE @T_OIYB DECIMAL(18, 2) = @OtrosIngresos
	DECLARE @SubTotalIngresosOtrosBeneficios DECIMAL(18, 2) = @T_PATASYOA + @T_OIYB
	DECLARE @T_GDF DECIMAL(18, 2) = @5110000000 + @5120000000 + @5130000000
	DECLARE @T_TASYOA DECIMAL(18, 2) = @5080000000 + @5212200000
	DECLARE @T_OGYPE DECIMAL(18, 2) = @5500000000 + @5590000000
	DECLARE @SubtotalGastosYOtrasPerdidas DECIMAL(18, 2) = @T_GDF + @T_OGYPE + @T_TASYOA
	DECLARE @TotalAhorroYDesahorro DECIMAL(18, 2) = @SubTotalIngresosOtrosBeneficios - @SubtotalGastosYOtrasPerdidas
	--================================================================
	
	IF @IsCierre = 1
	BEGIN
		SET @Mes = 13;
	END

		DECLARE @MesInicio NVARCHAR(50) = CASE WHEN @Mes = 1 THEN 'ENERO'
											   WHEN @Mes = 2 THEN 'FEBRERO'
											   WHEN @Mes = 3 THEN 'MARZO'
											   WHEN @Mes = 4 THEN 'ABRIL'
											   WHEN @Mes = 5 THEN 'MAYO'
											   WHEN @Mes = 6 THEN 'JUNIO'
											   WHEN @Mes = 7 THEN 'JULIO'
											   WHEN @Mes = 8 THEN 'AGOSTO'
											   WHEN @Mes = 9 THEN 'SEPTIEMBRE'
											   WHEN @Mes = 10 THEN 'OCTUBRE'
											   WHEN @Mes = 11 THEN 'NOVIEMBRE'
											   WHEN @Mes = 12 THEN 'DICIEMBRE'
									       END;
	DECLARE 
		 @1110000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM conta.SaldoMensual WHERE FKIdCuentaContable = '1110000000' AND FKIdAnio_SIS = @Anio AND FKIdMes_SIS = @Mes)
		,@1120000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM conta.SaldoMensual WHERE FKIdCuentaContable = '1120000000' AND FKIdAnio_SIS = @Anio AND FKIdMes_SIS = @Mes)
		,@1150000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM conta.SaldoMensual WHERE FKIdCuentaContable = '1150000000' AND FKIdAnio_SIS = @Anio AND FKIdMes_SIS = @Mes)
		,@1240000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM conta.SaldoMensual WHERE FKIdCuentaContable = '1240000000' AND FKIdAnio_SIS = @Anio AND FKIdMes_SIS = @Mes)
		,@1250000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM conta.SaldoMensual WHERE FKIdCuentaContable = '1250000000' AND FKIdAnio_SIS = @Anio AND FKIdMes_SIS = @Mes)
		,@1260000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM conta.SaldoMensual WHERE FKIdCuentaContable = '1260000000' AND FKIdAnio_SIS = @Anio AND FKIdMes_SIS = @Mes)
		,@2110000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM conta.SaldoMensual WHERE FKIdCuentaContable = '2110000000' AND FKIdAnio_SIS = @Anio AND FKIdMes_SIS = @Mes)
		,@2160000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM conta.SaldoMensual WHERE FKIdCuentaContable = '2160000000' AND FKIdAnio_SIS = @Anio AND FKIdMes_SIS = @Mes)
		,@3122300000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM conta.SaldoMensual WHERE FKIdCuentaContable = '3122300000' AND FKIdAnio_SIS = @Anio AND FKIdMes_SIS = @Mes)
		,@3122200000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM conta.SaldoMensual WHERE FKIdCuentaContable = '3122200000' AND FKIdAnio_SIS = @Anio AND FKIdMes_SIS = @Mes)
		,@3210000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM conta.SaldoMensual WHERE FKIdCuentaContable = '3210000000' AND FKIdAnio_SIS = @Anio AND FKIdMes_SIS = @Mes)
		,@3220000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM conta.SaldoMensual WHERE FKIdCuentaContable = '3220000000' AND FKIdAnio_SIS = @Anio AND FKIdMes_SIS = @Mes)
		,@3250000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM conta.SaldoMensual WHERE FKIdCuentaContable = '3250000000' AND FKIdAnio_SIS = @Anio AND FKIdMes_SIS = @Mes)

	DECLARE @T_ORIGEN DECIMAL(18, 2) = @1110000000 - @1260000000 + @2160000000 + @3122300000 + @3250000000
	       ,@T_APLICACION DECIMAL(18, 2) = @1120000000 + @1150000000 + @1240000000 + @1250000000 + @2110000000 + @3122200000 + @TotalAhorroYDesahorro + @3220000000

	SELECT  CASE WHEN @1110000000   < 0 THEN '('+FORMAT(ROUND(@1110000000 , 0)* -1,'N','EN-US')  +')' ELSE  FORMAT(ROUND(@1110000000, -2 ),'N','EN-US')  END AS R_1110000000
		   ,CASE WHEN @1120000000   < 0 THEN '('+FORMAT(ROUND(@1120000000 , 0)* -1,'N','EN-US')  +')' ELSE  FORMAT(ROUND(@1120000000, -2 ),'N','EN-US')  END AS R_1120000000
		   ,CASE WHEN @1150000000   < 0 THEN '('+FORMAT(ROUND(@1150000000 , 0)* -1,'N','EN-US')  +')' ELSE  FORMAT(ROUND(@1150000000, -2 ),'N','EN-US')  END AS R_1150000000
		   ,CASE WHEN @1240000000   < 0 THEN '('+FORMAT(ROUND(@1240000000 , 0)* -1,'N','EN-US')  +')' ELSE  FORMAT(ROUND(@1240000000, -2 ),'N','EN-US')  END AS R_1240000000
		   ,CASE WHEN @1250000000   < 0 THEN '('+FORMAT(ROUND(@1250000000 , 0)* -1,'N','EN-US')  +')' ELSE  FORMAT(ROUND(@1250000000, -2 ),'N','EN-US')  END AS R_1250000000
		   ,CASE WHEN @1260000000   < 0 THEN '('+FORMAT(ROUND(@1260000000 , 0)* -1,'N','EN-US')  +')' ELSE  FORMAT(ROUND(@1260000000, -2 ),'N','EN-US')  END AS R_1260000000
		   ,CASE WHEN @2110000000	< 0 THEN '('+FORMAT(ROUND(@2110000000 , 0)* -1,'N','EN-US')  +')' ELSE  FORMAT(ROUND(@2110000000, -2 ),'N','EN-US')  END AS R_2110000000
		   ,CASE WHEN @2160000000	< 0 THEN '('+FORMAT(ROUND(@2160000000 , 0)* -1,'N','EN-US')  +')' ELSE  FORMAT(ROUND(@2160000000, -2 ),'N','EN-US')  END AS R_2160000000
		   ,CASE WHEN @3122300000   < 0 THEN '('+FORMAT(ROUND(@3122300000 , 0)* -1,'N','EN-US')  +')' ELSE  FORMAT(ROUND(@3122300000, -2 ),'N','EN-US')  END AS R_3122300000
		   ,CASE WHEN @3122200000   < 0 THEN '('+FORMAT(ROUND(@3122200000 , 0)* -1,'N','EN-US')  +')' ELSE  FORMAT(ROUND(@3122200000, -2 ),'N','EN-US')  END AS R_3122200000
		   ,CASE WHEN @3210000000   < 0 THEN '('+FORMAT(ROUND(@3210000000 , 0)* -1,'N','EN-US')  +')' ELSE  FORMAT(ROUND(@3210000000, -2 ),'N','EN-US')  END AS R_3210000000
		   ,CASE WHEN @TotalAhorroYDesahorro < 0 THEN '(' + FORMAT(ROUND(@TotalAhorroYDesahorro, 0)* -1,'N','EN-US') +')' ELSE FORMAT(ROUND(@TotalAhorroYDesahorro, -2),'N','EN-US') END AS TAYD
		   ,CASE WHEN @3220000000   < 0 THEN '('+FORMAT(ROUND(@3220000000 , 0)* -1,'N','EN-US')  +')' ELSE  FORMAT(ROUND(@3220000000, -2 ),'N','EN-US')  END AS R_3220000000
		   ,CASE WHEN @3250000000   < 0 THEN '('+FORMAT(ROUND(@3250000000 , 0)* -1,'N','EN-US')  +')' ELSE  FORMAT(ROUND(@3250000000, -2 ),'N','EN-US')  END AS R_3250000000
		   ,CASE WHEN @T_ORIGEN     < 0 THEN '('+FORMAT(ROUND(@T_ORIGEN   , 0)* -1,'N','EN-US')  +')' ELSE  FORMAT(ROUND(@T_ORIGEN  , -2 ),'N','EN-US')  END AS R_T_ORIGEN
		   ,CASE WHEN @T_APLICACION < 0 THEN '('+FORMAT(ROUND(@T_APLICACION , 0)* -1,'N','EN-US')+')' ELSE  FORMAT(ROUND(@T_APLICACION,-2),'N','EN-US')END AS   R_T_APLICACION
	INTO #TMP

	SELECT
		 CAST(DAY(@FechaInicio) AS VARCHAR)  + ' DE ' + @MesInicio + ' DEL ' + CAST(YEAR(@FechaInicio) AS VARCHAR)  AS Fecha
		,YEAR(@FechaInicio) AS Anio
		,REPLACE(R_1110000000,'0,000','')  AS R_1110000000 
		,REPLACE(R_1120000000,'0,000','')  AS R_1120000000
		,REPLACE(R_1150000000,'0,000','')  AS R_1150000000
		,REPLACE(R_1240000000,'0,000','')  AS R_1240000000
		,REPLACE(R_1250000000,'0,000','')  AS R_1250000000
		,'(' + REPLACE(R_1260000000,'00.00','') +')'  AS R_1260000000
		,REPLACE(R_2110000000,'0,000','')  AS R_2110000000
		,REPLACE(R_2160000000,'0,000','')  AS R_2160000000 
		,REPLACE(R_3122300000,'0,000','')  AS R_3122300000
		,REPLACE(R_3122200000,'0,000','')  AS R_3122200000
		,REPLACE(TAYD,'0,000','')  AS R_3210000000
		,REPLACE(R_3220000000,'0,000','')  AS R_3220000000
		,REPLACE(R_3250000000,'0,000','')  AS R_3250000000
		,REPLACE(R_T_ORIGEN	 ,'0,000','')  AS R_T_ORIGEN
		,REPLACE(R_T_APLICACION,'0,000','')AS R_T_APLICACION
	FROM #TMP
	DROP TABLE #TMP
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_EstadoActividades]';
GO
/*
Determinar las cuentas correctas
ROG 20250602
*/
CREATE OR ALTER PROCEDURE [CONTA].[SPR_EstadoActividades]
		 @FechaInicio DATETIME
		,@FechaFin DATETIME
		,@FKIdMes_SIS INT
AS
BEGIN
SET FMTONLY OFF;
DECLARE @Mes INT = @FKIdMes_SIS;
DECLARE @FKIdAnio_SIS INT =(SELECT A.PKIdAnio 
	                              FROM SIS.Anio AS A 
								  WHERE A.Clave =  YEAR(@FechaInicio));

IF (@FKIdMes_SIS = 13) SET @Mes = 12; 

	DECLARE @MesInicio NVARCHAR(50) = CASE WHEN MONTH(@FechaInicio) = 1 THEN 'ENERO'
										   WHEN MONTH(@FechaInicio) = 2 THEN 'FEBRERO'
										   WHEN MONTH(@FechaInicio) = 3 THEN 'MARZO'
										   WHEN MONTH(@FechaInicio) = 4 THEN 'ABRIL'
										   WHEN MONTH(@FechaInicio) = 5 THEN 'MAYO'
										   WHEN MONTH(@FechaInicio) = 6 THEN 'JUNIO'
										   WHEN MONTH(@FechaInicio) = 7 THEN 'JULIO'
										   WHEN MONTH(@FechaInicio) = 8 THEN 'AGOSTO'
										   WHEN MONTH(@FechaInicio) = 9 THEN 'SEPTIEMBRE'
										   WHEN MONTH(@FechaInicio) = 10 THEN 'OCTUBRE'
										   WHEN MONTH(@FechaInicio) = 11 THEN 'NOVIEMBRE'
										   WHEN MONTH(@FechaInicio) = 12 THEN 'DICIEMBRE'
									  END;

	DECLARE @MesFin NVARCHAR(50) = CASE WHEN MONTH(@FechaFin) = 1 THEN 'ENERO'
										WHEN MONTH(@FechaFin) = 2 THEN 'FEBRERO'
										WHEN MONTH(@FechaFin) = 3 THEN 'MARZO'
										WHEN MONTH(@FechaFin) = 4 THEN 'ABRIL'
										WHEN MONTH(@FechaFin) = 5 THEN 'MAYO'
										WHEN MONTH(@FechaFin) = 6 THEN 'JUNIO'
										WHEN MONTH(@FechaFin) = 7 THEN 'JULIO'
										WHEN MONTH(@FechaFin) = 8 THEN 'AGOSTO'
										WHEN MONTH(@FechaFin) = 9 THEN 'SEPTIEMBRE'
										WHEN MONTH(@FechaFin) = 10 THEN 'OCTUBRE'
										WHEN MONTH(@FechaFin) = 11 THEN 'NOVIEMBRE'
										WHEN MONTH(@FechaFin) = 12 THEN 'DICIEMBRE'
									END;
	
	DECLARE
		 @4212000000 DECIMAL(18, 2)		= (SELECT X.SaldoFinal FROM conta.SaldoMensual AS X WHERE X.FKIdCuentaContable = '4212000000' AND X.FKIdAnio_SIS = @FKIdAnio_SIS AND X.FKIdMes_SIS = @Mes)
		,@OtrosIngresos DECIMAL(18, 2)	= (SELECT SUM(X.SaldoFinal) FROM conta.SaldoMensual AS X WHERE X.FKIdCuentaContable IN ('4100000000','4213000000', '4300000000','4413000000') AND X.FKIdAnio_SIS = @FKIdAnio_SIS AND X.FKIdMes_SIS = @Mes)
		,@5110000000 DECIMAL(18, 2)		= (SELECT X.SaldoFinal FROM conta.SaldoMensual AS X WHERE X.FKIdCuentaContable = '5110000000' AND X.FKIdAnio_SIS = @FKIdAnio_SIS AND X.FKIdMes_SIS = @Mes)
		,@5120000000 DECIMAL(18, 2)		= (SELECT X.SaldoFinal FROM conta.SaldoMensual AS X WHERE X.FKIdCuentaContable = '5120000000' AND X.FKIdAnio_SIS = @FKIdAnio_SIS AND X.FKIdMes_SIS = @Mes)
		,@5130000000 DECIMAL(18, 2)		= (SELECT X.SaldoFinal FROM conta.SaldoMensual AS X WHERE X.FKIdCuentaContable = '5130000000' AND X.FKIdAnio_SIS = @FKIdAnio_SIS AND X.FKIdMes_SIS = @Mes)
		,@5212200000 DECIMAL(18, 2)		= (SELECT X.SaldoFinal FROM conta.SaldoMensual AS X WHERE X.FKIdCuentaContable = '5212200000' AND X.FKIdAnio_SIS = @FKIdAnio_SIS AND X.FKIdMes_SIS = @Mes)
		,@5080000000 DECIMAL(18, 2)		= (SELECT X.SaldoFinal FROM conta.SaldoMensual AS X WHERE X.FKIdCuentaContable = '5280000000' AND X.FKIdAnio_SIS = @FKIdAnio_SIS AND X.FKIdMes_SIS = @Mes)
		,@5500000000 DECIMAL(18, 2)		= (SELECT X.SaldoFinal FROM conta.SaldoMensual AS X WHERE X.FKIdCuentaContable = '5510000000' AND X.FKIdAnio_SIS = @FKIdAnio_SIS AND X.FKIdMes_SIS = @Mes)-- Esta cuenta se cambio por la 550
		,@5590000000 DECIMAL(18, 2)		= (SELECT X.SaldoFinal FROM conta.SaldoMensual AS X WHERE X.FKIdCuentaContable = '5590000000' AND X.FKIdAnio_SIS = @FKIdAnio_SIS AND X.FKIdMes_SIS = @Mes)

	DECLARE @T_PATASYOA DECIMAL(18, 2) = @4212000000
	DECLARE @T_OIYB DECIMAL(18, 2) = @OtrosIngresos
	DECLARE @SubTotalIngresosOtrosBeneficios DECIMAL(18, 2) = @T_PATASYOA + @T_OIYB
	DECLARE @T_GDF DECIMAL(18, 2) = @5110000000 + @5120000000 + @5130000000
	DECLARE @T_TASYOA DECIMAL(18, 2) = @5080000000 + @5212200000
	DECLARE @T_OGYPE DECIMAL(18, 2) = @5500000000 + @5590000000
	DECLARE @SubtotalGastosYOtrasPerdidas DECIMAL(18, 2) = @T_GDF + @T_OGYPE + @T_TASYOA
	DECLARE @TotalAhorroYDesahorro DECIMAL(18, 2) = @SubTotalIngresosOtrosBeneficios - @SubtotalGastosYOtrasPerdidas
	
	
	
	SELECT  FORMAT(ROUND(@4212000000, -2),'N','EN-US') AS IOB_4212000000
		   ,FORMAT(ROUND(@OtrosIngresos, -2),'N','EN-US') AS IOB_OtrosIngresos
		   ,FORMAT(ROUND(@T_PATASYOA, -2),'N','EN-US')	AS T_PATASYOA
		   ,FORMAT(ROUND(@T_OIYB, -2),'N','EN-US')	AS T_OIYB
		   ,FORMAT(ROUND(@SubTotalIngresosOtrosBeneficios, -2),'N','EN-US') AS SubTotalIngresosOtrosBeneficios
		   --//
		   ,FORMAT(ROUND(@5110000000, -2),'N','EN-US')	AS GOP_5110000000
		   ,FORMAT(ROUND(@5120000000, -2),'N','EN-US')	AS GOP_5120000000
		   ,FORMAT(ROUND(@5130000000, -2),'N','EN-US')	AS GOP_5130000000   
		   ,FORMAT(ROUND(@T_GDF, -2),'N','EN-US') AS T_GDF
		   ,FORMAT(ROUND(@5212200000, -2),'N','EN-US') AS TASYOA_5212200000
		   ,FORMAT(ROUND(@5080000000, -2),'N','EN-US') AS TASYOA_5080000000
		   ,FORMAT(ROUND(@T_TASYOA, -2),'N','EN-US') AS T_TASYOA
		   ,FORMAT(ROUND(@5500000000, -2),'N','EN-US')	AS GOP_5500000000
		   ,FORMAT(ROUND(@5590000000, -2),'N','EN-US') AS GOP_5590000000	
		   ,FORMAT(ROUND(@T_OGYPE, -2),'N','EN-US') AS T_OGYPE
		   ,FORMAT(ROUND(@SubtotalGastosYOtrasPerdidas, -2),'N','EN-US') AS SubtotalGastosYOtrasPerdidas
	       --//
		   ,FORMAT(ROUND(@TotalAhorroYDesahorro, -2),'N','EN-US') AS TotalAhorroYDesahorro
	INTO #EstadoActividades
	
	SELECT
		 CAST(DAY(@FechaInicio) AS VARCHAR) + ' DE '+ @MesInicio +' AL '+ CAST(DAY(@FechaFin) AS VARCHAR) + ' DE ' + @MesFin + ' DE ' + CAST(YEAR(@FechaFin) AS VARCHAR) AS Fecha 
		,YEAR(@FechaInicio) AS Anio
		,REPLACE(IOB_4212000000,'00.00','') AS IOB_4212000000
		,REPLACE(IOB_OtrosIngresos,'00.00','') AS IOB_OtrosIngresos
		,REPLACE(T_PATASYOA,'00.00','') AS T_PATASYOA
		,REPLACE(T_OIYB,'00.00','') AS T_OIYB
		,REPLACE(SubTotalIngresosOtrosBeneficios,'00.00','') AS SubTotalIngresosOtrosBeneficios
		,REPLACE(GOP_5110000000,'00.00','') AS GOP_5110000000
		,REPLACE(GOP_5120000000,'00.00','') AS GOP_5120000000
		,REPLACE(GOP_5130000000,'00.00','') AS GOP_5130000000
		,REPLACE(T_GDF,'00.00','') AS T_GDF
		,REPLACE(TASYOA_5212200000,'00.00','') AS TASYOA_5212200000
		,REPLACE(TASYOA_5080000000,'00.00','') AS TASYOA_5080000000
		,REPLACE(T_TASYOA,'00.00','') AS T_TASYOA
		,REPLACE(GOP_5500000000,'00.00','') AS GOP_5500000000
		,REPLACE(GOP_5590000000,'00.00','') AS GOP_5590000000
		,REPLACE(T_OGYPE,'00.00','') AS T_OGYPE
		,REPLACE(SubtotalGastosYOtrasPerdidas,'00.00','') AS SubtotalGastosYOtrasPerdidas
		,REPLACE(TotalAhorroYDesahorro,'00.00','') AS TotalAhorroYDesahorro
	FROM #EstadoActividades
	DROP TABLE #EstadoActividades
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_EstadoAnaliticoActivo_DevEx]';
GO
CREATE OR ALTER PROCEDURE [CONTA].[SPR_EstadoAnaliticoActivo_DevEx]
		  @FechaInicio datetime = null
		 ,@FechaFin datetime = null
		 ,@PK_IdMes__SIS int
		AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	declare @Anio int = (select PKIdAnio from sis.anio where Clave =  datepart(yyyy,@FechaInicio))
	      , @AnioAnterior int = (select top 1 a.PKIdAnio from SIS.Anio a where a.Clave = year(@FechaInicio) - 1)
          , @Mes int = @PK_IdMes__SIS
		  , @TMPSaldoAnt nvarchar(max)
		  , @TMP_Cargos nvarchar(max)
		  , @TMP_Abonos nvarchar(max)
		  , @FechaBase datetime;
	--- EFM Se declaró la variable para la impresión por nivel

Set @FechaBase=CAST(STR(YEAR(@FechaInicio))+'/01/'+ STR(DAY(@FechaInicio)) AS date)

CREATE TABLE #SaldoAnt (FK_IdCuentaContable__CONTA INT, SaldoAnterior DECIMAL(18,2), Cuenta NVARCHAR(6), PK_IdTipoCuenta INT);

	SET @TMPSaldoAnt = '
	SELECT
		CC.PKIdCuentaContable AS FK_IdCuentaContable__CONTA
		,SaldoAnterior = case when '+ CAST(@Mes AS varchar)  +' =  1 and '+CAST(@Anio AS VARCHAR)+' = 4 then ISNULL(SUM(DP.ImporteDebe),0) - ISNULL(SUM(DP.ImporteHaber),0)
							  when '+ CAST(@Mes AS VARCHAR)  +' =  1 then (select SaldoFinal from conta.SaldoInicialBalanzaComprobacion sa where sa.FKIdAnio_SIS = '+ cast(@AnioAnterior as varchar) +' and sa.FKIdMes_SIS = 13 and cc.PKIdCuentaContable = sa.FK_IdCuentacuenta)
		                      when '+ CAST(@Mes AS VARCHAR)  +' =  2 then (select SaldoFinal from conta.SaldoInicialBalanzaComprobacion sa where sa.FKIdAnio_SIS = '+ cast(@AnioAnterior as varchar) +' and sa.FKIdMes_SIS = 13 and cc.PKIdCuentaContable = sa.FK_IdCuentacuenta)
							  when '+ CAST(@Mes AS varchar)  +' =  3 then (select SaldoFinal from conta.SaldoInicialBalanzaComprobacion sa where sa.FKIdAnio_SIS = '+ cast(@AnioAnterior as varchar) +' and sa.FKIdMes_SIS = 13 and cc.PKIdCuentaContable = sa.FK_IdCuentacuenta)
							  when '+ CAST(@Mes AS VARCHAR)  +' =  4 then (select SaldoFinal from conta.SaldoInicialBalanzaComprobacion sa where sa.FKIdAnio_SIS = '+ cast(@AnioAnterior as varchar) +' and sa.FKIdMes_SIS = 13 and cc.PKIdCuentaContable = sa.FK_IdCuentacuenta)
							  when '+ CAST(@Mes AS VARCHAR)  +' =  5 then (select SaldoFinal from conta.SaldoInicialBalanzaComprobacion sa where sa.FKIdAnio_SIS = '+ cast(@AnioAnterior as varchar) +' and sa.FKIdMes_SIS = 13 and cc.PKIdCuentaContable = sa.FK_IdCuentacuenta)
							  when '+ CAST(@Mes AS VARCHAR)  +' =  6 then (select SaldoFinal from conta.SaldoInicialBalanzaComprobacion sa where sa.FKIdAnio_SIS = '+ cast(@AnioAnterior as varchar) +' and sa.FKIdMes_SIS = 13 and cc.PKIdCuentaContable = sa.FK_IdCuentacuenta)
							  when '+ CAST(@Mes AS VARCHAR)  +' =  7 then (select SaldoFinal from conta.SaldoInicialBalanzaComprobacion sa where sa.FKIdAnio_SIS = '+ cast(@AnioAnterior as varchar) +' and sa.FKIdMes_SIS = 13 and cc.PKIdCuentaContable = sa.FK_IdCuentacuenta)
							  when '+ CAST(@Mes AS VARCHAR)  +' =  8 then (select SaldoFinal from conta.SaldoInicialBalanzaComprobacion sa where sa.FKIdAnio_SIS = '+ cast(@AnioAnterior as varchar) +' and sa.FKIdMes_SIS = 13 and cc.PKIdCuentaContable = sa.FK_IdCuentacuenta)
							  when '+ CAST(@Mes AS VARCHAR)  +' =  9 then (select SaldoFinal from conta.SaldoInicialBalanzaComprobacion sa where sa.FKIdAnio_SIS = '+ cast(@AnioAnterior as varchar) +' and sa.FKIdMes_SIS = 13 and cc.PKIdCuentaContable = sa.FK_IdCuentacuenta)
							  when '+ CAST(@Mes AS VARCHAR)  +' = 10 then (select SaldoFinal from conta.SaldoInicialBalanzaComprobacion sa where sa.FKIdAnio_SIS = '+ cast(@AnioAnterior as varchar) +' and sa.FKIdMes_SIS = 13 and cc.PKIdCuentaContable = sa.FK_IdCuentacuenta)
							  when '+ CAST(@Mes AS VARCHAR)  +' = 11 then (select SaldoFinal from conta.SaldoInicialBalanzaComprobacion sa where sa.FKIdAnio_SIS = '+ cast(@AnioAnterior as varchar) +' and sa.FKIdMes_SIS = 13 and cc.PKIdCuentaContable = sa.FK_IdCuentacuenta)
							  when '+ CAST(@Mes AS VARCHAR)  +' = 12 then (select SaldoFinal from conta.SaldoInicialBalanzaComprobacion sa where sa.FKIdAnio_SIS = '+ cast(@AnioAnterior as varchar) +' and sa.FKIdMes_SIS = 13 and cc.PKIdCuentaContable = sa.FK_IdCuentacuenta)
							  when '+ CAST(@Mes AS VARCHAR)  +' = 13 then (select SaldoFinal from conta.SaldoInicialBalanzaComprobacion sa where sa.FKIdAnio_SIS = '+ cast(@AnioAnterior as varchar) +' and sa.FKIdMes_SIS = 13 and cc.PKIdCuentaContable = sa.FK_IdCuentacuenta)
							  end 
		,cc.Cuenta
		,tc.PK_IdTipoCuenta
	FROM CONTA.CuentaContable CC INNER JOIN CONTA.PolizaDetalle DP ON CC.PKIdCuentaContable = DP.FKIdCuentaContable_CONTA 
	                           INNER JOIN conta.Poliza P         ON DP.FKIdPoliza_CONTA = P.PKIdPoliza 
							   INNER JOIN SIS.TipoCuenta TC      ON CC.FKIdTipoCuenta_CONTA = TC.PK_IdTipoCuenta
	WHERE CC.Activo = 1 '
	 
IF @Mes = 13 BEGIN   
SET @TMPSaldoAnt = @TMPSaldoAnt + 'AND CC.S6 NOT LIKE '''+CAST(0000 AS VARCHAR)+'''
	                               AND TC.PK_IdTipoCuenta IN (1,2) -- 1 ACREEDORA, 2 DEUDORA
	                               ---AND (DP.ImporteDebe != 0 AND DP.ImporteHaber != 0)
	                               And P.FKIdAnio_SIS >3   -- Se creo la poliza 20200 para mostrar los resultados del año 2014 y se metio en diciembre del 14 pero en el ejercicio 2015
	                               							--Fk_IdAnio = 4.
	                               							--Esta linea debe removerse tan pronto se solventen las diferencias de 2014  
	                               							--ROG
	                               GROUP BY CC.PKIdCuentaContable,tc.Descripcion, Cuenta, PK_IdTipoCuenta
	                               ORDER BY CC.PKIdCuentaContable'
END
ELSE BEGIN
SET @TMPSaldoAnt = @TMPSaldoAnt + 'AND P.FechaPoliza < '''+CAST(@FechaInicio AS varchar)+''' 
	                               AND CC.S6 NOT LIKE '''+CAST(0000 AS VARCHAR)+'''
	                               AND TC.PK_IdTipoCuenta IN (1,2) -- 1 ACREEDORA, 2 DEUDORA
	                              --- AND (DP.ImporteDebe != 0 AND DP.ImporteHaber != 0)
	                               And P.FKIdAnio_SIS >3   -- Se creo la poliza 20200 para mostrar los resultados del año 2014 y se metio en diciembre del 14 pero en el ejercicio 2015
	                               							--Fk_IdAnio = 4.
	                               							--Esta linea debe removerse tan pronto se solventen las diferencias de 2014  
	                               							--ROG
	                               GROUP BY CC.PKIdCuentaContable,tc.Descripcion, Cuenta, PK_IdTipoCuenta
	                               ORDER BY CC.PKIdCuentaContable'
END
---SELECT @TMPSaldoAnt
INSERT INTO #SaldoAnt EXEC SP_EXECUTESQL @TMPSaldoAnt;
---EFM MUESTRA SALDOS ANTERIORES
---SELECT 'MUESTRA SALDOS ANTERIORES' 
---SELECT * FROM #SaldoAnt WHERE FK_IdCuentaContable__CONTA IN (8,9) ;
---
--00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
	SELECT CC.PKIdCuentaContable FK_IdCuentaContable__CONTA,
		   ISNULL((SELECT TOP 1 SA.SaldoAnterior
					FROM #SaldoAnt SA
					WHERE SA.FK_IdCuentaContable__CONTA = CC.PKIdCuentaContable),0) AS SaldoAnterior
	INTO #SaldoAnt1
	FROM CONTA.CuentaContable CC
	WHERE CC.Activo = 1
	AND CC.S6 NOT LIKE '0000'

---EFM MUESTRA SALDOS ANTERIORES #SaldoAnt1
---SELECT 'MUESTRA SALDOS ANTERIORES #SaldoAnt1' 
---SELECT * FROM #SaldoAnt1 WHERE FK_IdCuentaContable__CONTA IN (8,9);

	/*Cargos
	Se calcula como la sumatoria de todos los DEBE de todas las cuentas acreedoras o deudoras con fecha de movimiento mayor al parámeto @FechaInicio
	*/

	set @TMP_Cargos = '	select 
				    		 CC.PKIdCuentaContable FK_IdCuentaContable__CONTA
				    		,sum(DP.ImporteDebe) Debe
				    		,cc.Cuenta
						from CONTA.CuentaContable CC inner join CONTA.PolizaDetalle DP  on CC.PKIdCuentaContable = DP.FKIdCuentaContable_CONTA 
												   inner join conta.Poliza P          on DP.FKIdPoliza_CONTA = P.PKIdPoliza 
												   inner join SIS.TipoCuenta TC       on CC.FKIdTipoCuenta_CONTA = TC.PK_IdTipoCuenta'
	
	IF @Mes = 13 begin 
	set @TMP_Cargos = @TMP_Cargos + ' where P.FKIdMes_SIS = '+ cast(@Mes as varchar)+' and FKIdAnio_SIS = '+ cast((select a.PKIdAnio from sis.Anio a where a.Clave = year(@FechaInicio)) as varchar)+'
										and DP.ImporteDebe != 0
									  	and PK_IdTipoCuenta in (1, 2)
									  	and CC.Activo = 1 
									  group by CC.PKIdCuentaContable, cc.Cuenta
									  order by CC.PKIdCuentaContable asc'
	end
	else begin
	set @TMP_Cargos = @TMP_Cargos + ' where P.FechaPoliza between '''+cast(@FechaBase as varchar)+''' and '''+ cast(@FechaFin as varchar)+'''
										---and p.FKIdMes_SIS = '+cast(@Mes as varchar)+' 
										and DP.ImporteDebe != 0 
										and PK_IdTipoCuenta in (1, 2)
										and CC.Activo = 1 
									  group by CC.PKIdCuentaContable, cc.Cuenta
									  order by CC.PKIdCuentaContable asc' 
	end

	CREATE TABLE #Cargos (FK_IdCuentaContable__CONTA int, Debe decimal(18, 2), Cuenta int)
	INSERT INTO #Cargos exec sp_executesql @TMP_Cargos;

---EFM MUESTRA CARGOS
SELECT 'MUESTRA CARGOS' 
SELECT @TMP_Cargos
SELECT * FROM #Cargos WHERE FK_IdCuentaContable__CONTA IN (8,9);

/*Abonos
	Se calcula como la sumatoria de todos los HABER de todas las cuentas acreedoras o deudoras con fecha de movimiento mayoy al parámeto @FechaInicio
	*/
	set @TMP_Cargos = '	select 
							 CC.PKIdCuentaContable FK_IdCuentaContable__CONTA
							,sum(DP.ImporteHaber) Haber
						from CONTA.CuentaContable CC inner join CONTA.PolizaDetalle DP  on CC.PKIdCuentaContable = DP.FKIdCuentaContable_CONTA 
												   inner join conta.Poliza P          on DP.FKIdPoliza_CONTA = P.PKIdPoliza 
												   inner join SIS.TipoCuenta TC       on CC.FKIdTipoCuenta_CONTA = TC.PK_IdTipoCuenta'

	IF @Mes = 13 begin 
	set @TMP_Cargos = @TMP_Cargos + ' where P.FKIdMes_SIS = '+ cast(@Mes as varchar)+' and FKIdAnio_SIS = '+ cast((select a.PKIdAnio from sis.Anio a where a.Clave = year(@FechaInicio)) as varchar)+'
									  	and PK_IdTipoCuenta in (1, 2)
										and DP.ImporteHaber != 0 
										and CC.Activo = 1 
									  group by CC.PKIdCuentaContable
									  order by CC.PKIdCuentaContable asc'
	end
	else begin
	set @TMP_Cargos = @TMP_Cargos + ' where P.FechaPoliza between '''+ cast(@FechaBase as varchar)+''' and '''+cast(@FechaFin as varchar)+'''
										---and p.FKIdMes_SIS = '+cast(@Mes as varchar)+'
										and PK_IdTipoCuenta in (1, 2)
										and DP.ImporteHaber != 0 
										and CC.Activo = 1 
									  group by CC.PKIdCuentaContable
									  order by CC.PKIdCuentaContable asc' 
	end
	
	
		
	CREATE TABLE #Abonos (FK_IdCuentaContable__CONTA int, Haber decimal(18, 2))
	INSERT INTO #Abonos exec sp_executesql @TMP_Cargos;
---EFM MUESTRA ABONOS
SELECT 'MUESTRA ABONOS' 
SELECT * FROM #Abonos WHERE FK_IdCuentaContable__CONTA IN (8,9);
	
	--#AuxConta es la balanza para todas las cuentas nivel 6 (S6 !='0000'),
		--estos son nuestros datos de trabajo por que sólo se pueden 
		--hacer detalles de poliza a estas cuentas y todas las demás son cuentas agrupadoras o de mayor

	SELECT
	SA.FK_IdCuentaContable__CONTA
	,CC.Cuenta,CC.SubCuenta,CC.SubSubCuenta,CC.SubSubSubCuenta,CC.SubSubSubSubCuenta,CC.S5,CC.S6
	,SA.SaldoAnterior SaldoAnterior
	,ISNULL((SELECT C.Debe FROM #Cargos C WHERE C.FK_IdCuentaContable__CONTA = SA.FK_IdCuentaContable__CONTA),0) AS IMPORTE_DEBE
	,ISNULL((SELECT A.Haber FROM #Abonos A WHERE A.FK_IdCuentaContable__CONTA = SA.FK_IdCuentaContable__CONTA),0) AS IMPORTE_HABER
	-- 1 Acredora
	-- 2 Deudora
	,IMPORTE_TOTAL = case when cc.FKIdTipoCuenta_CONTA = 1 then SA.SaldoAnterior - ISNULL((SELECT C.Debe FROM #Cargos C WHERE C.FK_IdCuentaContable__CONTA = sa.FK_IdCuentaContable__CONTA),0) + ISNULL((SELECT A.Haber FROM #Abonos A WHERE A.FK_IdCuentaContable__CONTA = sa.FK_IdCuentaContable__CONTA),0)
	                      when cc.FKIdTipoCuenta_CONTA = 2 then SA.SaldoAnterior + ISNULL((SELECT C.Debe FROM #Cargos C WHERE C.FK_IdCuentaContable__CONTA = sa.FK_IdCuentaContable__CONTA),0) - ISNULL((SELECT A.Haber FROM #Abonos A WHERE A.FK_IdCuentaContable__CONTA = sa.FK_IdCuentaContable__CONTA),0)
					 end
	--,SA.SaldoAnterior
	--	+ISNULL((SELECT C.Debe FROM #Cargos C WHERE C.FK_IdCuentaContable__CONTA = sa.FK_IdCuentaContable__CONTA),0)
	--	-ISNULL((SELECT A.Haber FROM #Abonos A WHERE A.FK_IdCuentaContable__CONTA = sa.FK_IdCuentaContable__CONTA),0) AS IMPORTE_TOTAL
	INTO #AuxConta
	FROM #SaldoAnt1 SA INNER JOIN CONTA.CuentaContable CC
	ON SA.FK_IdCuentaContable__CONTA = CC.PKIdCuentaContable
	Where CC.Activo = 1  --ROG20161131
	ORDER BY CC.Cuenta,CC.SubCuenta,CC.SubSubCuenta,CC.SubSubSubCuenta,CC.SubSubSubSubCuenta,CC.S5,CC.S6

---EFM CREA AUXILIAR CON LAS 3 CONSULTAS ANTERIORES
SELECT 'MUESTRA #AuxConta' 
SELECT * FROM #AuxConta WHERE FK_IdCuentaContable__CONTA IN (8,9);;
	
	--@Balanza almacenará los valores calculados de las agrupación según el nivel de cada cuenta, es la Balanza propiamente dicha
DECLARE @Balanza TABLE (
	FKIdCuentaContable_CONTA int
	, IMPORTE_ANTERIOR decimal(18,2)
	, IMPORTE_DEBE decimal(18,2)
	, IMPORTE_HABER decimal(18,2)
	, IMPORTE_TOTAL decimal(18,2)
)

	-- Variables para el cursor
DECLARE @PKIdCuentaContable INT,
	@Cuenta nvarchar(1),
	@SubCuenta nvarchar(1),
	@SubSubCuenta nvarchar(1),
	@SubSubSubCuenta nvarchar(1),
	@SubSubSubSubCuenta nvarchar(1),
	@S5 nvarchar(1),
	@S6 nvarchar(4)

	--Inicia Cursor 
DECLARE CuentaContableCursor CURSOR
FOR	SELECT
		PKIdCuentaContable
		,Cuenta
		,SubCuenta
		,SubSubCuenta
		,SubSubSubCuenta
		,SubSubSubSubCuenta
		,S5
		,S6
	 FROM CONTA.CuentaContable
	 WHERE Activo = 1
OPEN CuentaContableCursor
FETCH NEXT FROM CuentaContableCursor
INTO
		@PKIdCuentaContable
		,@Cuenta
		,@SubCuenta
		,@SubSubCuenta
		,@SubSubSubCuenta
		,@SubSubSubSubCuenta
		,@S5
		,@S6
WHILE @@FETCH_STATUS = 0
	BEGIN

	IF @S6 != '0000'
	BEGIN
		--PRINT  @Cuenta+@SubCuenta+@SubSubCuenta+@SubSubSubCuenta+@SubSubSubSubCuenta+@S5+@S6+' - Es nivel 6'
		--efm
		--IF @NIVEL>=6
			--BEGIN 
			INSERT INTO @Balanza( FKIdCuentaContable_CONTA,IMPORTE_ANTERIOR, IMPORTE_DEBE, IMPORTE_HABER, IMPORTE_TOTAL)
			SELECT AC.FK_IdCuentaContable__CONTA, AC.SaldoAnterior, AC.IMPORTE_DEBE,AC.IMPORTE_HABER,AC.IMPORTE_TOTAL
			FROM #AuxConta AC
			WHERE AC.FK_IdCuentaContable__CONTA = @PKIdCuentaContable
			--END

	END
	ELSE
		BEGIN
		IF @S5 != '0'
		BEGIN
			--PRINT  @Cuenta+@SubCuenta+@SubSubCuenta+@SubSubSubCuenta+@SubSubSubSubCuenta+@S5+@S6+' - Es nivel 5'
			----efm
			--IF @NIVEL>=5
			--	BEGIN 
					INSERT INTO @Balanza(FKIdCuentaContable_CONTA,IMPORTE_ANTERIOR, IMPORTE_DEBE, IMPORTE_HABER, IMPORTE_TOTAL)
					SELECT @PKIdCuentaContable, ISNULL(SUM(AC.SaldoAnterior),0),ISNULL(SUM(AC.IMPORTE_DEBE),0),ISNULL(SUM(AC.IMPORTE_HABER),0),ISNULL(SUM(AC.IMPORTE_TOTAL),0)
					FROM #AuxConta AC
					WHERE @Cuenta = AC.Cuenta
					AND @SubCuenta = AC.SubCuenta
					AND @SubSubCuenta = AC.SubSubCuenta
					AND @SubSubSubCuenta = AC.SubSubSubCuenta
					AND @SubSubSubSubCuenta = AC.SubSubSubSubCuenta
					AND @S5 = AC.S5
				--END
		END
		ELSE
			BEGIN
			IF @SubSubSubSubCuenta != '0'
			BEGIN
				--PRINT  @Cuenta+@SubCuenta+@SubSubCuenta+@SubSubSubCuenta+@SubSubSubSubCuenta+@S5+@S6+' - Es nivel 4'
				----efm
				--IF @NIVEL>=4
				--	BEGIN 
						INSERT INTO @Balanza(FKIdCuentaContable_CONTA,IMPORTE_ANTERIOR, IMPORTE_DEBE, IMPORTE_HABER, IMPORTE_TOTAL)
						SELECT @PKIdCuentaContable, ISNULL(SUM(AC.SaldoAnterior),0),ISNULL(SUM(AC.IMPORTE_DEBE),0),ISNULL(SUM(AC.IMPORTE_HABER),0),ISNULL(SUM(AC.IMPORTE_TOTAL),0)
						FROM #AuxConta AC
						WHERE @Cuenta = AC.Cuenta
						AND @SubCuenta = AC.SubCuenta
						AND @SubSubCuenta = AC.SubSubCuenta
						AND @SubSubSubCuenta = AC.SubSubSubCuenta
						AND @SubSubSubSubCuenta = AC.SubSubSubSubCuenta
					--END
			END
			ELSE
				BEGIN
				IF @SubSubSubCuenta != '0'
				BEGIN
					--PRINT  @Cuenta+@SubCuenta+@SubSubCuenta+@SubSubSubCuenta+@SubSubSubSubCuenta+@S5+@S6+' - Es nivel 3'
					----efm
					--IF @NIVEL>=3
					--	BEGIN 
							INSERT INTO @Balanza(FKIdCuentaContable_CONTA,IMPORTE_ANTERIOR, IMPORTE_DEBE, IMPORTE_HABER, IMPORTE_TOTAL)
							SELECT @PKIdCuentaContable, ISNULL(SUM(AC.SaldoAnterior),0),ISNULL(SUM(AC.IMPORTE_DEBE),0),ISNULL(SUM(AC.IMPORTE_HABER),0),ISNULL(SUM(AC.IMPORTE_TOTAL),0)
							FROM #AuxConta AC
							WHERE @Cuenta = AC.Cuenta
							AND @SubCuenta = AC.SubCuenta
							AND @SubSubCuenta = AC.SubSubCuenta
							AND @SubSubSubCuenta = AC.SubSubSubCuenta
						--END
				END
				ELSE
					BEGIN
					IF @SubSubCuenta != '0'
					BEGIN
						--PRINT  @Cuenta+@SubCuenta+@SubSubCuenta+@SubSubSubCuenta+@SubSubSubSubCuenta+@S5+@S6+' - Es nivel 2'
						INSERT INTO @Balanza(FKIdCuentaContable_CONTA,IMPORTE_ANTERIOR, IMPORTE_DEBE, IMPORTE_HABER, IMPORTE_TOTAL)
						SELECT @PKIdCuentaContable, ISNULL(SUM(AC.SaldoAnterior),0),ISNULL(SUM(AC.IMPORTE_DEBE),0),ISNULL(SUM(AC.IMPORTE_HABER),0),ISNULL(SUM(AC.IMPORTE_TOTAL),0)
						FROM #AuxConta AC
						WHERE @Cuenta = AC.Cuenta
						AND @SubCuenta = AC.SubCuenta
						AND @SubSubCuenta = AC.SubSubCuenta
					END
					ELSE
						BEGIN
						IF @SubCuenta != '0' BEGIN
							--PRINT  @Cuenta+@SubCuenta+@SubSubCuenta+@SubSubSubCuenta+@SubSubSubSubCuenta+@S5+@S6+' - Es nivel 1'
							INSERT INTO @Balanza(FKIdCuentaContable_CONTA,IMPORTE_ANTERIOR, IMPORTE_DEBE, IMPORTE_HABER, IMPORTE_TOTAL)
							SELECT @PKIdCuentaContable, ISNULL(SUM(AC.SaldoAnterior),0),ISNULL(SUM(AC.IMPORTE_DEBE),0),ISNULL(SUM(AC.IMPORTE_HABER),0),ISNULL(SUM(AC.IMPORTE_TOTAL),0)
							FROM #AuxConta AC
							WHERE @Cuenta = AC.Cuenta
							AND @SubCuenta = AC.SubCuenta
						END
						ELSE
							BEGIN
								--PRINT  @Cuenta+@SubCuenta+@SubSubCuenta+@SubSubSubCuenta+@SubSubSubSubCuenta+@S5+@S6+' - Es nivel 0'
								INSERT INTO @Balanza(FKIdCuentaContable_CONTA,IMPORTE_ANTERIOR, IMPORTE_DEBE, IMPORTE_HABER, IMPORTE_TOTAL)
								SELECT @PKIdCuentaContable, ISNULL(SUM(AC.SaldoAnterior),0),ISNULL(SUM(AC.IMPORTE_DEBE),0),ISNULL(SUM(AC.IMPORTE_HABER),0),ISNULL(SUM(AC.IMPORTE_TOTAL),0)
								FROM #AuxConta AC
								WHERE @Cuenta = AC.Cuenta
						END
					END
				END
			END
		END
	END
	

	FETCH NEXT FROM CuentaContableCursor
	INTO
		@PKIdCuentaContable
		,@Cuenta
		,@SubCuenta
		,@SubSubCuenta
		,@SubSubSubCuenta
		,@SubSubSubSubCuenta
		,@S5
		,@S6
	END
CLOSE CuentaContableCursor;
DEALLOCATE CuentaContableCursor;
	

	declare @SaldoAnterior decimal(20,2) = (select sum(SaldoAnterior) - (select sum(SaldoAnterior) from #SaldoAnt where Cuenta = 1 and PK_IdTipoCuenta = 2)   
	                                        from #SaldoAnt where Cuenta = 1 and PK_IdTipoCuenta = 1)
	
	     if (@Mes = 1 and Year(@FechaInicio) ! = '2015') set @SaldoAnterior = (select SaldoFinal from conta.SaldosInicialesBalanzaComprobacion where FKIdAnio_SIS  = (select PKIdAnio from sis.anio where clave =  year(@FechaInicio) - 1) and FKIdMes_SIS = 13 )
	else if (@Mes = 2 ) set @SaldoAnterior = (select SaldoFinal from conta.SaldosInicialesBalanzaComprobacion where FKIdMes_SIS = 1	AND FKIdAnio_SIS = @Anio)
	else if (@Mes = 3 ) set @SaldoAnterior = (select SaldoFinal from conta.SaldosInicialesBalanzaComprobacion where FKIdMes_SIS = 2	AND FKIdAnio_SIS = @Anio)
	else if (@Mes = 4 ) set @SaldoAnterior = (select SaldoFinal from conta.SaldosInicialesBalanzaComprobacion where FKIdMes_SIS = 3	AND FKIdAnio_SIS = @Anio)
	else if (@Mes = 5 ) set @SaldoAnterior = (select SaldoFinal from conta.SaldosInicialesBalanzaComprobacion where FKIdMes_SIS = 4	AND FKIdAnio_SIS = @Anio)
	else if (@Mes = 6 ) set @SaldoAnterior = (select SaldoFinal from conta.SaldosInicialesBalanzaComprobacion where FKIdMes_SIS = 5	AND FKIdAnio_SIS = @Anio)
	else if (@Mes = 7 ) set @SaldoAnterior = (select SaldoFinal from conta.SaldosInicialesBalanzaComprobacion where FKIdMes_SIS = 6	AND FKIdAnio_SIS = @Anio)
	else if (@Mes = 8 ) set @SaldoAnterior = (select SaldoFinal from conta.SaldosInicialesBalanzaComprobacion where FKIdMes_SIS = 7	AND FKIdAnio_SIS = @Anio)
	else if (@mes = 9 ) set @SaldoAnterior = (select SaldoFinal from conta.SaldosInicialesBalanzaComprobacion where FKIdMes_SIS = 8	AND FKIdAnio_SIS = @Anio)
	else if (@Mes = 10) set @SaldoAnterior = (select SaldoFinal from conta.SaldosInicialesBalanzaComprobacion where FKIdMes_SIS = 9	AND FKIdAnio_SIS = @Anio)
	else if (@Mes = 11) set @SaldoAnterior = (select SaldoFinal from conta.SaldosInicialesBalanzaComprobacion where FKIdMes_SIS = 10	AND FKIdAnio_SIS = @Anio)
	else if (@Mes = 12) set @SaldoAnterior = (select SaldoFinal from conta.SaldosInicialesBalanzaComprobacion where FKIdMes_SIS = 11	AND FKIdAnio_SIS = @Anio)
	else if (@Mes = 13) set @SaldoAnterior = (select SaldoFinal from conta.SaldosInicialesBalanzaComprobacion where FKIdMes_SIS = 12	AND FKIdAnio_SIS = @Anio)
																																						   
    
	declare @Saldofinal decimal(20,2) = (select top 1 abs(@SaldoAnterior) - (IMPORTE_HABER - IMPORTE_DEBE) 	
	FROM CONTA.CuentaContable  CC LEFT JOIN @Balanza T
		ON CC.PKIdCuentaContable = T.FKIdCuentaContable_CONTA
		Where CC.Activo = 1 
		AND (t.IMPORTE_DEBE + t.IMPORTE_HABER != 0.00) or (t.IMPORTE_ANTERIOR + t.IMPORTE_DEBE + t.IMPORTE_HABER + t.IMPORTE_TOTAL != 0.00)
	ORDER BY CC.Cuenta,CC.SubCuenta,CC.SubSubCuenta,CC.SubSubSubCuenta,CC.SubSubSubSubCuenta,CC.S5,CC.S6)
  
    declare @Deprec decimal(20,2) = (select 
     	t.IMPORTE_ANTERIOR
    FROM CONTA.CuentaContable  CC LEFT JOIN @Balanza T ON CC.PKIdCuentaContable = T.FKIdCuentaContable_CONTA
    Where CC.Activo = 1
    and CC.Cuenta+CC.SubCuenta+CC.SubSubCuenta+CC.SubSubSubCuenta+CC.SubSubSubSubCuenta+CC.S5+CC.S6 = '1260000000')
	-- Termina cursor

	declare @ActivosIntangibles decimal(20,2) = (select 
     	t.IMPORTE_ANTERIOR 
    FROM CONTA.CuentaContable  CC LEFT JOIN @Balanza T ON CC.PKIdCuentaContable = T.FKIdCuentaContable_CONTA
    Where CC.Activo = 1
    and CC.Cuenta+CC.SubCuenta+CC.SubSubCuenta+CC.SubSubSubCuenta+CC.SubSubSubSubCuenta+CC.S5+CC.S6 = '1250000000')

	declare @ActivosIntangiblesFinal decimal(20,2) = (select 
     	t.IMPORTE_TOTAL
    FROM CONTA.CuentaContable  CC LEFT JOIN @Balanza T ON CC.PKIdCuentaContable = T.FKIdCuentaContable_CONTA
    Where CC.Activo = 1
    and CC.Cuenta+CC.SubCuenta+CC.SubSubCuenta+CC.SubSubSubCuenta+CC.SubSubSubSubCuenta+CC.S5+CC.S6 = '1250000000')
		

	declare @BienesMuebles decimal(20,2) = (select 
     	t.IMPORTE_ANTERIOR  - @Deprec + @ActivosIntangibles
    FROM CONTA.CuentaContable  CC LEFT JOIN @Balanza T ON CC.PKIdCuentaContable = T.FKIdCuentaContable_CONTA
    Where CC.Activo = 1
    and CC.Cuenta+CC.SubCuenta+CC.SubSubCuenta+CC.SubSubSubCuenta+CC.SubSubSubSubCuenta+CC.S5+CC.S6 = '1240000000')

	declare @BienesMueblesFinal decimal(20,2) = (select 
     	@BienesMuebles + t.IMPORTE_DEBE - t.IMPORTE_HABER
    FROM CONTA.CuentaContable  CC LEFT JOIN @Balanza T ON CC.PKIdCuentaContable = T.FKIdCuentaContable_CONTA
    Where CC.Activo = 1
    and CC.Cuenta+CC.SubCuenta+CC.SubSubCuenta+CC.SubSubSubCuenta+CC.SubSubSubSubCuenta+CC.S5+CC.S6 = '1200000000')
	
--// 
	SELECT CC.PKIdCuentaContable 
		, CC.Cuenta
		, CC.SubCuenta
		, CC.SubSubCuenta
		, CC.SubSubSubCuenta
		, CC.SubSubSubSubCuenta
		, CC.S5
		, CC.S6
		, CC.Cuenta+CC.SubCuenta+CC.SubSubCuenta+CC.SubSubSubCuenta+CC.SubSubSubSubCuenta+CC.S5+CC.S6 as CtaFull
		, Descripcion = case when CC.s6                 != '0000'  then '            '+CC.Descripcion
						     when CC.S5                 != '0'	   then '         '+CC.Descripcion
						     when CC.SubSubSubSubCuenta != '0'	   then '       '+CC.Descripcion
						     when CC.SubSubSubCuenta    != '0'	   then '     '+CC.Descripcion
						     when CC.SubSubCuenta       != '0'	   then '   '+CC.Descripcion
						     when CC.SubCuenta          != '0'	   then ' '+CC.Descripcion else CC.Descripcion end
		, Fecha = CASE WHEN @Mes != 13 THEN [dbo].[FechaMesNumeroToFechaMesNombre](@FechaFin,1) ELSE 'Ajt' + cast(year(@FechaInicio) as varchar) END
		, cc.FKIdTipoCuenta_CONTA
		, IMPORTE_ANTERIOR = case when PKIdCuentaContable = 1 then abs(@SaldoAnterior) 
		                          when CC.Cuenta+CC.SubCuenta+CC.SubSubCuenta+CC.SubSubSubCuenta+CC.SubSubSubSubCuenta+CC.S5+CC.S6 = '1200000000' then @BienesMuebles else isnull(T.IMPORTE_ANTERIOR,0) end		
		, isnull(T.IMPORTE_DEBE,0)IMPORTE_DEBE
		, isnull(T.IMPORTE_HABER,0)IMPORTE_HABER
		, IMPORTE_TOTAL = case when PKIdCuentaContable = 1 then @Saldofinal
		                       when CC.Cuenta+CC.SubCuenta+CC.SubSubCuenta+CC.SubSubSubCuenta+CC.SubSubSubSubCuenta+CC.S5+CC.S6 = '1200000000'then @BienesMueblesFinal else isnull(T.IMPORTE_TOTAL,0) end

	INTO #BalanzaComprobacion
	FROM CONTA.CuentaContable  CC LEFT JOIN @Balanza T ON CC.PKIdCuentaContable = T.FKIdCuentaContable_CONTA
	Where CC.Activo = 1  --ROG20161104
	--AND (t.IMPORTE_DEBE + t.IMPORTE_HABER != 0.00) or (t.IMPORTE_ANTERIOR + t.IMPORTE_DEBE + t.IMPORTE_HABER + t.IMPORTE_TOTAL != 0.00)
	--AND CC.Cuenta != '8'
	ORDER BY CC.Cuenta,CC.SubCuenta,CC.SubSubCuenta,CC.SubSubSubCuenta,CC.SubSubSubSubCuenta,CC.S5,CC.S6

---EFM TEMPORAL DE BALANZA
SELECT 'TABLA #BalanzaComprobacion'
SELECT * FROM #BalanzaComprobacion
	
	--// Se crea la consulta que genera la Balanza.
	DECLARE @Miles DECIMAL(18, 2) = (select bc.IMPORTE_ANTERIOR from #BalanzaComprobacion bc WHERE BC.CtaFull = '1000000000')
	       ,@DosMil DECIMAL(18, 2) = (select bc.IMPORTE_ANTERIOR from #BalanzaComprobacion bc WHERE BC.CtaFull = '2000000000')
		   ,@TresMil DECIMAL(18, 2) = (select bc.IMPORTE_ANTERIOR from #BalanzaComprobacion bc WHERE BC.CtaFull = '3000000000')
		   ,@CuatroMil DECIMAL(18, 2) = (select bc.IMPORTE_ANTERIOR from #BalanzaComprobacion bc WHERE BC.CtaFull = '4000000000')
		   ,@CincoMil DECIMAL(18, 2) = (select bc.IMPORTE_ANTERIOR from #BalanzaComprobacion bc WHERE BC.CtaFull = '5000000000')


	DECLARE 
	--ACTIVO
			@1110000000_INICIAL DECIMAL(18 ,2) = (SELECT IMPORTE_ANTERIOR FROM #BalanzaComprobacion WHERE CtaFull = '1110000000')	--- EFECTIVO Y EQUIVALENTES
	       ,@1110000000_DEBE    DECIMAL(18 ,2) = (SELECT IMPORTE_DEBE FROM #BalanzaComprobacion WHERE CtaFull = '1110000000')		
	       ,@1110000000_HABER   DECIMAL(18 ,2) = (SELECT IMPORTE_HABER FROM #BalanzaComprobacion WHERE CtaFull = '1110000000')
	       ,@1110000000_FINAL   DECIMAL(18 ,2) = (SELECT IMPORTE_TOTAL FROM #BalanzaComprobacion WHERE CtaFull = '1110000000')
		   ,@1120000000_INICIAL DECIMAL(18 ,2) = (SELECT IMPORTE_ANTERIOR FROM #BalanzaComprobacion WHERE CtaFull = '1120000000')	--- DERECHOS A RECIBIR EFECTIVO O EQUIVALENTES
	       ,@1120000000_DEBE    DECIMAL(18 ,2) = (SELECT IMPORTE_DEBE FROM #BalanzaComprobacion WHERE CtaFull =  '1120000000')
	       ,@1120000000_HABER   DECIMAL(18 ,2) = (SELECT IMPORTE_HABER FROM #BalanzaComprobacion WHERE CtaFull = '1120000000')
	       ,@1120000000_FINAL   DECIMAL(18 ,2) = (SELECT IMPORTE_TOTAL FROM #BalanzaComprobacion WHERE CtaFull = '1120000000')
		   ,@1150000000_INICIAL DECIMAL(18 ,2) = (SELECT IMPORTE_ANTERIOR FROM #BalanzaComprobacion WHERE CtaFull = '1150000000')	--- ALMACENES
	       ,@1150000000_DEBE    DECIMAL(18 ,2) = (SELECT IMPORTE_DEBE FROM #BalanzaComprobacion WHERE CtaFull  = '1150000000')
	       ,@1150000000_HABER   DECIMAL(18 ,2) = (SELECT IMPORTE_HABER FROM #BalanzaComprobacion WHERE CtaFull = '1150000000')
	       ,@1150000000_FINAL   DECIMAL(18 ,2) = (SELECT IMPORTE_TOTAL FROM #BalanzaComprobacion WHERE CtaFull = '1150000000')

	-- ACTIVO NO CIRCULANTE   1200000000
		   ,@1240000000_INICIAL DECIMAL(18 ,2) = (SELECT IMPORTE_ANTERIOR FROM #BalanzaComprobacion WHERE CtaFull = '1240000000')	--- BIENES MUEBLES
	       ,@1240000000_DEBE    DECIMAL(18 ,2) = (SELECT IMPORTE_DEBE FROM #BalanzaComprobacion WHERE CtaFull  = '1240000000')
	       ,@1240000000_HABER   DECIMAL(18 ,2) = (SELECT IMPORTE_HABER FROM #BalanzaComprobacion WHERE CtaFull = '1240000000')
	       ,@1240000000_FINAL   DECIMAL(18 ,2) = (SELECT IMPORTE_TOTAL FROM #BalanzaComprobacion WHERE CtaFull = '1240000000')
		   ,@1250000000_INICIAL DECIMAL(18 ,2) = (SELECT IMPORTE_ANTERIOR FROM #BalanzaComprobacion WHERE CtaFull = '1250000000')	--- ACTIVOS INTANGIBLES
	       ,@1250000000_DEBE    DECIMAL(18 ,2) = (SELECT IMPORTE_DEBE FROM #BalanzaComprobacion WHERE CtaFull  = '1250000000')
	       ,@1250000000_HABER   DECIMAL(18 ,2) = (SELECT IMPORTE_HABER FROM #BalanzaComprobacion WHERE CtaFull = '1250000000')
	       ,@1250000000_FINAL   DECIMAL(18 ,2) = (SELECT IMPORTE_TOTAL FROM #BalanzaComprobacion WHERE CtaFull = '1250000000')
		   ,@1260000000_INICIAL DECIMAL(18 ,2) = (SELECT IMPORTE_ANTERIOR FROM #BalanzaComprobacion WHERE CtaFull = '1260000000')	---    DEPRECIACIÓN, DETERIORO Y AMORTIZACIÓN ACUMULADA DE BIENES
	       ,@1260000000_DEBE    DECIMAL(18 ,2) = (SELECT IMPORTE_DEBE FROM #BalanzaComprobacion WHERE CtaFull  = '1260000000')
	       ,@1260000000_HABER   DECIMAL(18 ,2) = (SELECT IMPORTE_HABER FROM #BalanzaComprobacion WHERE CtaFull = '1260000000')
	       ,@1260000000_FINAL   DECIMAL(18 ,2) = (SELECT IMPORTE_TOTAL FROM #BalanzaComprobacion WHERE CtaFull = '1260000000')

	--totales
	DECLARE @SubTotal_Inicial_Activo DECIMAL(18, 2) = @1110000000_INICIAL + @1120000000_INICIAL + @1150000000_INICIAL
	      , @SubTotal_Debe_Activo  DECIMAL(18, 2) = @1110000000_DEBE + @1120000000_DEBE + @1150000000_DEBE
		  , @SubTotal_Haber_Activo DECIMAL(18, 2) = @1110000000_HABER + @1120000000_HABER + @1150000000_HABER
		  , @Subtotal_Final_Activo DECIMAL(18, 2) = @1110000000_FINAL + @1120000000_FINAL + @1150000000_FINAL

	DECLARE @SubTotal_Inicial_Circulante DECIMAL(18, 2) = @1240000000_INICIAL + @1250000000_INICIAL - @1260000000_INICIAL
          , @SubTotal_Debe_Circulante  DECIMAL(18, 2) = @1240000000_DEBE + @1250000000_DEBE + @1260000000_DEBE
		  , @SubTotal_Haber_Circulante DECIMAL(18, 2) = @1240000000_HABER + @1250000000_HABER + @1260000000_HABER
		  , @SubTotal_Final_Circulante DECIMAL(18, 2) = @1240000000_FINAL + @1250000000_FINAL - @1260000000_FINAL
	
	DECLARE @Total_Inicial DECIMAL(18, 2) = @SubTotal_Inicial_Activo + @SubTotal_Inicial_Circulante
	      , @Total_Debe  DECIMAL(18, 2) = @SubTotal_Debe_Activo + @SubTotal_Debe_Circulante
	      , @Total_Haber DECIMAL(18, 2) = @SubTotal_Haber_Activo + @SubTotal_Haber_Circulante
	      , @Total_Final DECIMAL(18, 2) = @Subtotal_Final_Activo + @SubTotal_Final_Circulante

	--Variacion
	DECLARE  @V_1110000000 DECIMAL(18, 2) = @1110000000_INICIAL - @1110000000_FINAL
	       , @V_1120000000 DECIMAL(18, 2) = @1120000000_INICIAL - @1120000000_FINAL
	       , @V_1150000000 DECIMAL(18, 2) = @1150000000_INICIAL - @1150000000_FINAL
		   , @v_SubTotalActivo DECIMAL(18, 2) = @SubTotal_Inicial_Activo - @Subtotal_Final_Activo

	DECLARE  @V_1240000000 DECIMAL(18, 2) = @1240000000_INICIAL - @1240000000_FINAL
			,@V_1250000000 DECIMAL(18, 2) = @1250000000_INICIAL - @1250000000_FINAL
			,@V_1260000000 DECIMAL(18, 2) = @1260000000_INICIAL - @1260000000_FINAL
			,@V_SubTotalCirculante DECIMAL(18, 2) = @SubTotal_Inicial_Circulante - @SubTotal_Final_Circulante
			,@v_Total DECIMAL(18, 2) = @Total_Inicial - @Total_Final

	DECLARE @MesInicio NVARCHAR(50) = CASE WHEN MONTH(@FechaFin) = 1 THEN 'ENERO'
										   WHEN MONTH(@FechaFin) = 2 THEN 'FEBRERO'
										   WHEN MONTH(@FechaFin) = 3 THEN 'MARZO'
										   WHEN MONTH(@FechaFin) = 4 THEN 'ABRIL'
										   WHEN MONTH(@FechaFin) = 5 THEN 'MAYO'
										   WHEN MONTH(@FechaFin) = 6 THEN 'JUNIO'
										   WHEN MONTH(@FechaFin) = 7 THEN 'JULIO'
										   WHEN MONTH(@FechaFin) = 8 THEN 'AGOSTO'
										   WHEN MONTH(@FechaFin) = 9 THEN 'SEPTIEMBRE'
										   WHEN MONTH(@FechaFin) = 10 THEN 'OCTUBRE'
										   WHEN MONTH(@FechaFin) = 11 THEN 'NOVIEMBRE'
										   WHEN MONTH(@FechaFin) = 12 THEN 'DICIEMBRE'
									  END;
	--SELECT  CAST(DAY(@FechaFin) AS VARCHAR) + ' DE ' + @MesInicio + ' DEL ' + CAST(YEAR(@FechaFin) AS VARCHAR) AS Fecha
	--      ,FORMAT(ROUND(@1110000000_INICIAL, -2),'N','EN-US') AS R_1110000000_INICIAL
	--      ,FORMAT(ROUND(@1110000000_DEBE, -2),'N','EN-US')	  AS R_1110000000_DEBE
	--	  ,FORMAT(ROUND(@1110000000_HABER, -2),'N','EN-US')	  AS R_1110000000_HABER
	--	  ,FORMAT(ROUND(@1110000000_FINAL, -2),'N','EN-US')	  AS R_1110000000_FINAL
	--	  ,CASE WHEN @V_1110000000 < 0 THEN '(' + FORMAT(ROUND(@V_1110000000 * -1, -2),'N','EN-US') + ')' ELSE FORMAT(ROUND(@V_1110000000, -2),'N','EN-US') END	AS R_V_1110000000
	--	  ,FORMAT(ROUND(@1120000000_INICIAL, -2),'N','EN-US') AS R_1120000000_INICIAL
	--	  ,FORMAT(ROUND(@1120000000_DEBE, -2),'N','EN-US')	  AS R_1120000000_DEBE
	--	  ,FORMAT(ROUND(@1120000000_HABER, -2),'N','EN-US')	  AS R_1120000000_HABER
	--	  ,FORMAT(ROUND(@1120000000_FINAL, -2),'N','EN-US')	  AS R_1120000000_FINAL
	--	  ,CASE WHEN @V_1120000000 < 0 THEN '('+FORMAT(ROUND(@V_1120000000 * -1, -2),'N','EN-US') +')' ELSE FORMAT(ROUND(@V_1120000000, -2),'N','EN-US') END	AS R_V_1120000000
	--	  ,FORMAT(ROUND(@1150000000_INICIAL, -2),'N','EN-US') AS R_1150000000_INICIAL
	--	  ,FORMAT(ROUND(@1150000000_DEBE, -2),'N','EN-US')	  AS R_1150000000_DEBE
	--	  ,FORMAT(ROUND(@1150000000_HABER, -2),'N','EN-US')	  AS R_1150000000_HABER
	--	  ,FORMAT(ROUND(@1150000000_FINAL, -2),'N','EN-US')	  AS R_1150000000_FINAL
	--	  ,CASE WHEN @V_1150000000 < 0 THEN '('+FORMAT(ROUND(@V_1150000000 * -1, -2),'N','EN-US') +')' ELSE FORMAT(ROUND(@V_1150000000, -2),'N','EN-US') END	AS R_V_1150000000
	--	  ,FORMAT(ROUND(@1240000000_INICIAL, -2),'N','EN-US') AS R_1240000000_INICIAL
	--	  ,FORMAT(ROUND(@1240000000_DEBE, -2),'N','EN-US')	  AS R_1240000000_DEBE
	--	  ,FORMAT(ROUND(@1240000000_HABER, -2),'N','EN-US')	  AS R_1240000000_HABER
	--	  ,FORMAT(ROUND(@1240000000_FINAL, -2),'N','EN-US')	  AS R_1240000000_FINAL
	--	  ,CASE WHEN @V_1240000000 < 0 THEN '('+FORMAT(ROUND(@V_1240000000 * -1, -2),'N','EN-US') +')' ELSE FORMAT(ROUND(@V_1240000000, -2),'N','EN-US')	END	AS R_V_1240000000
	--	  ,FORMAT(ROUND(@1250000000_INICIAL, -2),'N','EN-US') AS R_1250000000_INICIAL
	--	  ,FORMAT(ROUND(@1250000000_DEBE, -2),'N','EN-US')	  AS R_1250000000_DEBE
	--	  ,FORMAT(ROUND(@1250000000_HABER, -2),'N','EN-US')	  AS R_1250000000_HABER
	--	  ,FORMAT(ROUND(@1250000000_FINAL, -2),'N','EN-US')	  AS R_1250000000_FINAL
	--	  ,CASE WHEN @V_1250000000 < 0 THEN  '('+FORMAT(ROUND(@V_1250000000 * -1, -2),'N','EN-US') +')' ELSE FORMAT(ROUND(@V_1250000000, -2),'N','EN-US') END AS R_V_1250000000
	--	  ,'(' + FORMAT(ROUND(@1260000000_INICIAL, -2),'N','EN-US') + ')' AS R_1260000000_INICIAL
	--	  ,FORMAT(ROUND(@1260000000_DEBE, -2),'N','EN-US')	   AS R_1260000000_DEBE
	--	  ,FORMAT(ROUND(@1260000000_HABER, -2),'N','EN-US')	   AS R_1260000000_HABER
	--	  ,'(' + FORMAT(ROUND(@1260000000_FINAL, -2),'N','EN-US') + ')' AS R_1260000000_FINAL
	--	  ,CASE WHEN @V_1260000000 < 0 THEN '('+FORMAT(ROUND(@V_1260000000 * -1, -2),'N','EN-US')+')' ELSE FORMAT(ROUND(@V_1260000000, -2),'N','EN-US') END AS R_V_1260000000
	--	  ,FORMAT(ROUND(@SubTotal_Inicial_Activo, -2),'N','EN-US') AS R_SubTotal_Inicial_Activo
	--	  ,FORMAT(ROUND(@SubTotal_Debe_Activo, -2),'N','EN-US')	   AS R_SubTotal_Debe_Activo
	--	  ,FORMAT(ROUND(@SubTotal_Haber_Activo, -2),'N','EN-US')   AS R_SubTotal_Haber_Activo
	--	  ,FORMAT(ROUND(@Subtotal_Final_Activo, -2),'N','EN-US')   AS R_Subtotal_Final_Activo
	--	  ,FORMAT(ROUND(@SubTotal_Inicial_Circulante, -2),'N','EN-US') AS R_SubTotal_Inicial_Circulante
	--	  ,FORMAT(ROUND(@SubTotal_Debe_Circulante, -2),'N','EN-US')	   AS R_SubTotal_Debe_Circulante
	--	  ,FORMAT(ROUND(@SubTotal_Haber_Circulante, -2),'N','EN-US')   AS R_SubTotal_Haber_Circulante
	--	  ,FORMAT(ROUND(@SubTotal_Final_Circulante, -2),'N','EN-US')   AS R_SubTotal_Final_Circulante
	--	  ,FORMAT(ROUND(@Total_Inicial, -2),'N','EN-US')	AS R_Total_Inicial
	--	  ,FORMAT(ROUND(@Total_Debe, -2),'N','EN-US')		AS R_Total_Debe
	--	  ,FORMAT(ROUND(@Total_Haber, -2),'N','EN-US')		AS R_Total_Haber
	--	  ,FORMAT(ROUND(@Total_Final, -2),'N','EN-US')		AS R_Total_Final
	--	  ,CASE WHEN @v_SubTotalActivo < 0 THEN '('+FORMAT(ROUND(@v_SubTotalActivo * -1, -2),'N','EN-US')+')' ELSE FORMAT(ROUND(@v_SubTotalActivo, -2),'N','EN-US') END AS R_V_SubTotalActivo 
	--	  ,CASE WHEN @V_SubTotalCirculante < 0 THEN '('+FORMAT(ROUND(@V_SubTotalCirculante * -1, -2),'N','EN-US')+')' ELSE FORMAT(ROUND(@V_SubTotalCirculante, -2),'N','EN-US') END AS R_V_SubTotalCirculante
	--	  ,CASE WHEN @v_Total < 0 THEN FORMAT(ROUND(@v_Total * -1, -2),'N','EN-US') ELSE FORMAT(ROUND(@v_Total, -2),'N','EN-US') END AS R_v_Total
	--INTO #TMP

	SELECT  CAST(DAY(@FechaFin) AS VARCHAR) + ' DE ' + @MesInicio + ' DEL ' + CAST(YEAR(@FechaFin) AS VARCHAR) AS Fecha
	      ,FORMAT(ROUND(@1110000000_INICIAL, 0),'N','EN-US') AS R_1110000000_INICIAL
	      ,FORMAT(ROUND(@1110000000_DEBE, 0),'N','EN-US')	  AS R_1110000000_DEBE
		  ,FORMAT(ROUND(@1110000000_HABER, 0),'N','EN-US')	  AS R_1110000000_HABER
		  ,FORMAT(ROUND(@1110000000_FINAL, 0),'N','EN-US')	  AS R_1110000000_FINAL
		  ,CASE WHEN @V_1110000000 < 0 THEN '(' + FORMAT(ROUND(@V_1110000000 * -1, 0),'N','EN-US') + ')' ELSE FORMAT(ROUND(@V_1110000000, 0),'N','EN-US') END	AS R_V_1110000000
		  ,FORMAT(ROUND(@1120000000_INICIAL, 0),'N','EN-US') AS R_1120000000_INICIAL
		  ,FORMAT(ROUND(@1120000000_DEBE, 0),'N','EN-US')	  AS R_1120000000_DEBE
		  ,FORMAT(ROUND(@1120000000_HABER, 0),'N','EN-US')	  AS R_1120000000_HABER
		  ,FORMAT(ROUND(@1120000000_FINAL, 0),'N','EN-US')	  AS R_1120000000_FINAL
		  ,CASE WHEN @V_1120000000 < 0 THEN '('+FORMAT(ROUND(@V_1120000000 * -1, 0),'N','EN-US') +')' ELSE FORMAT(ROUND(@V_1120000000, 0),'N','EN-US') END	AS R_V_1120000000
		  ,FORMAT(ROUND(@1150000000_INICIAL, 0),'N','EN-US') AS R_1150000000_INICIAL
		  ,FORMAT(ROUND(@1150000000_DEBE, 0),'N','EN-US')	  AS R_1150000000_DEBE
		  ,FORMAT(ROUND(@1150000000_HABER, 0),'N','EN-US')	  AS R_1150000000_HABER
		  ,FORMAT(ROUND(@1150000000_FINAL, 0),'N','EN-US')	  AS R_1150000000_FINAL
		  ,CASE WHEN @V_1150000000 < 0 THEN '('+FORMAT(ROUND(@V_1150000000 * -1, 0),'N','EN-US') +')' ELSE FORMAT(ROUND(@V_1150000000, 0),'N','EN-US') END	AS R_V_1150000000
		  ,FORMAT(ROUND(@1240000000_INICIAL, 0),'N','EN-US') AS R_1240000000_INICIAL
		  ,FORMAT(ROUND(@1240000000_DEBE, 0),'N','EN-US')	  AS R_1240000000_DEBE
		  ,FORMAT(ROUND(@1240000000_HABER, 0),'N','EN-US')	  AS R_1240000000_HABER
		  ,FORMAT(ROUND(@1240000000_FINAL, 0),'N','EN-US')	  AS R_1240000000_FINAL
		  ,CASE WHEN @V_1240000000 < 0 THEN '('+FORMAT(ROUND(@V_1240000000 * -1, 0),'N','EN-US') +')' ELSE FORMAT(ROUND(@V_1240000000, 0),'N','EN-US')	END	AS R_V_1240000000
		  ,FORMAT(ROUND(@1250000000_INICIAL, 0),'N','EN-US') AS R_1250000000_INICIAL
		  ,FORMAT(ROUND(@1250000000_DEBE, 0),'N','EN-US')	  AS R_1250000000_DEBE
		  ,FORMAT(ROUND(@1250000000_HABER, 0),'N','EN-US')	  AS R_1250000000_HABER
		  ,FORMAT(ROUND(@1250000000_FINAL, 0),'N','EN-US')	  AS R_1250000000_FINAL
		  ,CASE WHEN @V_1250000000 < 0 THEN  '('+FORMAT(ROUND(@V_1250000000 * -1, 0),'N','EN-US') +')' ELSE FORMAT(ROUND(@V_1250000000, 0),'N','EN-US') END AS R_V_1250000000
		  ,'(' + FORMAT(ROUND(@1260000000_INICIAL, 0),'N','EN-US') + ')' AS R_1260000000_INICIAL
		  ,FORMAT(ROUND(@1260000000_DEBE, 0),'N','EN-US')	   AS R_1260000000_DEBE
		  ,FORMAT(ROUND(@1260000000_HABER, 0),'N','EN-US')	   AS R_1260000000_HABER
		  ,'(' + FORMAT(ROUND(@1260000000_FINAL, 0),'N','EN-US') + ')' AS R_1260000000_FINAL
		  ,CASE WHEN @V_1260000000 < 0 THEN '('+FORMAT(ROUND(@V_1260000000 * -1, 0),'N','EN-US')+')' ELSE FORMAT(ROUND(@V_1260000000, 0),'N','EN-US') END AS R_V_1260000000
		  ,FORMAT(ROUND(@SubTotal_Inicial_Activo, 0),'N','EN-US') AS R_SubTotal_Inicial_Activo
		  ,FORMAT(ROUND(@SubTotal_Debe_Activo, 0),'N','EN-US')	   AS R_SubTotal_Debe_Activo
		  ,FORMAT(ROUND(@SubTotal_Haber_Activo, 0),'N','EN-US')   AS R_SubTotal_Haber_Activo
		  ,FORMAT(ROUND(@Subtotal_Final_Activo, 0),'N','EN-US')   AS R_Subtotal_Final_Activo
		  ,FORMAT(ROUND(@SubTotal_Inicial_Circulante, 0),'N','EN-US') AS R_SubTotal_Inicial_Circulante
		  ,FORMAT(ROUND(@SubTotal_Debe_Circulante, 0),'N','EN-US')	   AS R_SubTotal_Debe_Circulante
		  ,FORMAT(ROUND(@SubTotal_Haber_Circulante, 0),'N','EN-US')   AS R_SubTotal_Haber_Circulante
		  ,FORMAT(ROUND(@SubTotal_Final_Circulante, 0),'N','EN-US')   AS R_SubTotal_Final_Circulante
		  ,FORMAT(ROUND(@Total_Inicial, 0),'N','EN-US')	AS R_Total_Inicial
		  ,FORMAT(ROUND(@Total_Debe, 0),'N','EN-US')		AS R_Total_Debe
		  ,FORMAT(ROUND(@Total_Haber, 0),'N','EN-US')		AS R_Total_Haber
		  ,FORMAT(ROUND(@Total_Final, 0),'N','EN-US')		AS R_Total_Final
		  ,CASE WHEN @v_SubTotalActivo < 0 THEN '('+FORMAT(ROUND(@v_SubTotalActivo * -1, 0),'N','EN-US')+')' ELSE FORMAT(ROUND(@v_SubTotalActivo, 0),'N','EN-US') END AS R_V_SubTotalActivo 
		  ,CASE WHEN @V_SubTotalCirculante < 0 THEN '('+FORMAT(ROUND(@V_SubTotalCirculante * -1, 0),'N','EN-US')+')' ELSE FORMAT(ROUND(@V_SubTotalCirculante, 0),'N','EN-US') END AS R_V_SubTotalCirculante
		  ,CASE WHEN @v_Total < 0 THEN FORMAT(ROUND(@v_Total * -1, 0),'N','EN-US') ELSE FORMAT(ROUND(@v_Total, 0),'N','EN-US') END AS R_v_Total
	INTO #TMP



--// insert a tabla saldofinales

	SELECT
		Fecha
		,REPLACE(R_1110000000_INICIAL,'00.00','') AS R_1110000000_INICIAL
		,REPLACE(R_1110000000_DEBE,'00.00','') AS R_1110000000_DEBE
		,REPLACE(R_1110000000_HABER,'00.00','') AS R_1110000000_HABER
		,REPLACE(R_1110000000_FINAL,'00.00','') AS R_1110000000_FINAL
		,REPLACE(R_V_1110000000,'00.00','') AS R_V_1110000000
		,REPLACE(R_1120000000_INICIAL,'00.00','') AS R_1120000000_INICIAL
		,REPLACE(R_1120000000_DEBE,'00.00','') AS R_1120000000_DEBE
		,REPLACE(R_1120000000_HABER,'00.00','') AS R_1120000000_HABER
		,REPLACE(R_1120000000_FINAL,'00.00','') AS R_1120000000_FINAL
		,REPLACE(R_V_1120000000,'00.00','') AS R_V_1120000000
		,REPLACE(R_1150000000_INICIAL,'00.00','') AS R_1150000000_INICIAL
		,REPLACE(R_1150000000_DEBE,'00.00','') AS R_1150000000_DEBE
		,REPLACE(R_1150000000_HABER,'00.00','') AS R_1150000000_HABER
		,REPLACE(R_1150000000_FINAL,'00.00','') AS R_1150000000_FINAL
		,REPLACE(R_V_1150000000,'00.00','') AS R_V_1150000000
		,REPLACE(R_1240000000_INICIAL,'00.00','') AS R_1240000000_INICIAL
		,REPLACE(R_1240000000_DEBE,'00.00','') AS R_1240000000_DEBE
		,REPLACE(R_1240000000_HABER,'00.00','') AS R_1240000000_HABER
		,REPLACE(R_1240000000_FINAL,'00.00','') AS R_1240000000_FINAL
		,REPLACE(R_V_1240000000,'00.00','') AS R_V_1240000000
		,REPLACE(R_1250000000_INICIAL,'00.00','') AS R_1250000000_INICIAL
		,REPLACE(R_1250000000_DEBE,'00.00','') AS R_1250000000_DEBE
		,REPLACE(R_1250000000_HABER,'00.00','') AS R_1250000000_HABER
		,REPLACE(R_1250000000_FINAL,'00.00','') AS R_1250000000_FINAL
		,REPLACE(R_V_1250000000,'00.00','') AS R_V_1250000000
		,REPLACE(R_1260000000_INICIAL,'00.00','') AS R_1260000000_INICIAL
		,REPLACE(R_1260000000_DEBE,'00.00','') AS R_1260000000_DEBE
		,REPLACE(R_1260000000_HABER,'00.00','') AS R_1260000000_HABER
		,REPLACE(R_1260000000_FINAL,'00.00','') AS R_1260000000_FINAL
		,REPLACE(R_V_1260000000,'00.00','') AS R_V_1260000000
		,REPLACE(R_SubTotal_Inicial_Activo,'00.00','') AS R_SubTotal_Inicial_Activo
		,REPLACE(R_SubTotal_Debe_Activo,'00.00','') AS R_SubTotal_Debe_Activo
		,REPLACE(R_SubTotal_Haber_Activo,'00.00','') AS R_SubTotal_Haber_Activo
		,REPLACE(R_Subtotal_Final_Activo,'00.00','') AS R_Subtotal_Final_Activo
		,REPLACE(R_SubTotal_Inicial_Circulante,'00.00','') AS R_SubTotal_Inicial_Circulante
		,REPLACE(R_SubTotal_Debe_Circulante,'00.00','') AS R_SubTotal_Debe_Circulante
		,REPLACE(R_SubTotal_Haber_Circulante,'00.00','') AS R_SubTotal_Haber_Circulante
		,REPLACE(R_SubTotal_Final_Circulante,'00.00','') AS R_SubTotal_Final_Circulante
		,REPLACE(R_Total_Inicial,'00.00','') AS R_Total_Inicial
		,REPLACE(R_Total_Debe,'00.00','') AS R_Total_Debe
		,REPLACE(R_Total_Haber,'00.00','') AS R_Total_Haber
		,REPLACE(R_Total_Final,'00.00','') AS R_Total_Final
		,REPLACE(R_V_SubTotalActivo,'00.00','') AS R_V_SubTotalActivo
		,REPLACE(R_V_SubTotalCirculante,'00.00','') AS R_V_SubTotalCirculante
		,REPLACE(R_v_Total,'00.00','') AS R_v_Total
	FROM #TMP
--drops
DROP TABLE #SaldoAnt,#SaldoAnt1, #Cargos, #Abonos, #AuxConta, #BalanzaComprobacion, #TMP
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_EstadoAnaliticoDelActivo]';
GO
-- exec [CONTA].[SPR_EstadoAnaliticoDelActivo] '2025-05-01','2025-05-30'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_EstadoAnaliticoDelActivo]
	  @p_FecInicio nvarchar(24),
	@p_FecFin nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepAnaActi'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')


	SELECT id=1,Concepto = CAST('Activo' as nvarchar(500)), [SI] = '$ 2,222,891,419.00 ', [CP] = '$ 11,960.00 ', [AP] = '$ 0.00', [SF] = '$ 2,222,903,379.00', [VP] = ''
	INTO #tblEstadoAnaliticoDelActivo
	UNION
	SELECT id=2,Concepto = 'Activo Circulante ', [SI] = '$ 2,222,891,419.00', [CP] = '$ 11,960.00', [AP] = '$ 0.00', [SF] = '$ 2,222,903,379.00', [VP] = '$ 11,960.00'
	UNION
	SELECT id=3,Concepto = 'Efectivo y Equivalentes', [SI] = '$ 149,981,834.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ 149,981,834.00', [VP] = '$ 0.00'
	UNION
	SELECT id=4,Concepto = 'Derechos a Recibir Efectivo o Equivalentes', [SI] = '$ 2,336,111,208.00', [CP] = '$ 11,960.00', [AP] = '$ 0.00', [SF] = '$ 2,336,123,168.00', [VP] = '$ 11,960.00'
	UNION
	SELECT id=5,Concepto = 'Derechos a Recibir Bienes o Servicios', [SI] = '$ 0.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ 0.00', [VP] = '$ 0.00'
	UNION
	SELECT id=6,Concepto = 'Inventarios', [SI] = '$ 0.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ 0.00', [VP] = '$ 0.00'
	UNION
	SELECT id=7,Concepto = 'Almacenes', [SI] = '$ 650,258.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ 650,258.00', [VP] = '$ 0.00'
	UNION
	SELECT id=8,Concepto = 'Estimación por Pérdida o Deterioro de Activos Circulantes', [SI] = '$ -263,851,881.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ -263,851,881.00', [VP] = '$ 0.00'
	UNION
	SELECT id=9,Concepto = 'Otros Activos Circulantes', [SI] = '$ 0.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ 0.00', [VP] = '$ 0.00'
	--
	UNION
	SELECT id=10,Concepto = 'ACTIVOS NO CIRCULANTES', [SI] = '', [CP] = '', [AP] = '', [SF] = '', [VP] = ''
	--
	UNION
	SELECT id=11,Concepto = 'Inversiones Financieras a Largo Plazo', [SI] = '$ 0.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ 0.00', [VP] = '$ 0.00'
	UNION
	SELECT id=12,Concepto = 'Derechos a Recibir Efectivo o Equivalentes a Largo Plazo', [SI] = '$ 0.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ 0.00', [VP] = '$ 0.00'
	UNION
	SELECT id=13,Concepto = 'Bienes Inmuebles, Infraestructura y Construcciones en Proceso', [SI] = '', [CP] = '', [AP] = '', [SF] = '', [VP] = ''
	UNION
	--
	SELECT id=14,Concepto = 'Bienes Muebles', [SI] = '$ 7,162,122.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ 7,162,122.00', [VP] = '$ 0.00'
	UNION
	SELECT id=15,Concepto = 'Activos Intangibles', [SI] = '$ 2,541,228.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ 2,541,228.00', [VP] = '$ 0.00'
	UNION
	SELECT id=16,Concepto = 'Depreciación, Deterioro y Amortización Acumulada de Bienes', [SI] = '$ -5,934,956.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ -5,934,956.00', [VP] = '$ 0.00'
	UNION
	SELECT id=17,Concepto = 'Activos Diferidos', [SI] = '$ 0.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ 0.00', [VP] = '$ 0.00'
	UNION
	SELECT id=18,Concepto = 'Estimación por Pérdida o Deterioro de Activos No Circulantes', [SI] = '$ 0.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ 0.00', [VP] = '$ 0.00'
	UNION
	SELECT id=19,Concepto = 'Otros Activos no Circulantes', [SI] = '$ 0.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ 0.00', [VP] = '$ 0.00'
	


	--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('DEL ' , FORMAT(@p_FechaInicio, 'dd \de MMMM \del yyyy', 'es-MX') , ' AL ' ,  FORMAT(@p_FechaFin, 'dd \de MMMM \del yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tblEstadoAnaliticoDelActivo
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_EstadoAnaliticoDeudaPasivos]';
GO
-- exec [CONTA].[SPR_EstadoAnaliticoDeudaPasivos] '2024-01-01','2024-01-30'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_EstadoAnaliticoDeudaPasivos]
	 @p_FecInicio nvarchar(24),
	@p_FecFin nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin

	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepEstadoAnaDeuda'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	SELECT id=1,DD = CAST('DEUDA PÚBLICA' as nvarchar(500)), [MC] = '', [I] = '', [SI] = '0', [SF] = '0'
	into #tlbRepEstadoAnaliticoDeudaPasivos
	UNION
	SELECT id=2,DD = '			Corto Plazo', [MC] = '', [I] = '', [SI] = '', [SF] = ''
	UNION
	SELECT id=3,DD = '', [MC] = '', [I] = '', [SI] = '', [SF] = ''
	UNION
	SELECT id=4,DD = '', [MC] = '', [I] = '', [SI] = '', [SF] = ''
	UNION
	SELECT id=5,DD = '', [MC] = '', [I] = '', [SI] = '', [SF] = ''
	UNION
	SELECT id=6,DD = '', [MC] = '', [I] = '', [SI] = '', [SF] = ''
	UNION
	SELECT id=7,DD = '', [MC] = '', [I] = '', [SI] = '', [SF] = ''
	UNION
	SELECT id=8,DD = '', [MC] = '', [I] = '', [SI] = '', [SF] = ''
	UNION
	SELECT id=9,DD = '', [MC] = '', [I] = '', [SI] = '', [SF] = ''
	UNION
	SELECT id=10,DD = '', [MC] = '', [I] = '', [SI] = '', [SF] = ''
	UNION
	SELECT id=11,DD = '', [MC] = '', [I] = '', [SI] = '', [SF] = ''
	UNION
	SELECT id=12,DD = '', [MC] = '', [I] = '', [SI] = '', [SF] = ''
	UNION
	SELECT id=13,DD = '', [MC] = '', [I] = '', [SI] = '', [SF] = ''
	UNION
	SELECT id=14,DD = '', [MC] = '', [I] = '', [SI] = '', [SF] = ''
	UNION
	SELECT id=15,DD = '', [MC] = '', [I] = '', [SI] = '', [SF] = ''
	UNION
	SELECT id=16,DD = '', [MC] = '', [I] = '', [SI] = '', [SF] = ''
	UNION
	SELECT id=17,DD = '', [MC] = '', [I] = '', [SI] = '', [SF] = ''
	UNION
	SELECT id=18,DD = '', [MC] = '', [I] = '', [SI] = '', [SF] = ''
	UNION
	SELECT id=19,DD = '', [MC] = '', [I] = '', [SI] = '', [SF] = ''
	UNION
	SELECT id=20,DD = '', [MC] = '', [I] = '', [SI] = '', [SF] = ''
	UNION
	SELECT id=21,DD = '', [MC] = '', [I] = '', [SI] = '', [SF] = ''
	--UNION
	--SELECT id=,DD = '', [MC] = '', [I] = '', [SI] = '', [SF] = ''
	
	--FIN

	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('DEL ' , FORMAT(@p_FechaInicio, 'dd \de MMMM \del yyyy', 'es-MX') , ' AL ' ,  FORMAT(@p_FechaFin, 'dd \de MMMM \del yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tlbRepEstadoAnaliticoDeudaPasivos

	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_EstadoDeSitucionFinanciera]';
GO
-- =============================================
-- Author:		JCOL
-- Create date: 01/05/2013
-- Description:	REPORTE DE VALE DE SALIDA
-- =============================================
-- =============================================
-- Editor:		[.0.
-- Create date: 01/05/2013
-- Description:	Se arraglaron firmasAutorizadas,
--				Se corrigieron nombres de los nodos para coincidir con Flex
--				Se agregó CostoPromedio y CostoTotal
-- =============================================
-- =============================================
-- Editor:		[.0.
-- Create date: 14/08/2013
-- Description:	Costo promedio viene ahora de la tabla ALMA.CostoPromedio
-- Nota: Siempre saldrá el costo promedio al momento de llamar al reporte, no el costo promedio a la fecha de la salida
-- =============================================

-- exec [CONTA].[SPR_EstadoDeSitucionFinanciera] 0
CREATE OR ALTER PROCEDURE [CONTA].[SPR_EstadoDeSitucionFinanciera]
	 @p_FecInicio nvarchar(24),
	@p_FecFin nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepEstadoCambiosSitFin'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')


	SELECT id=1,Concepto1 = CAST('ACTIVO' as nvarchar(500)), [A2023] = '', [A2024] = '',Concepto2 ='PASIVO', [P2023] = '', [P2024] = ''
	INTO #tlbEstadoDeSitucionFinanciera
	UNION
	SELECT id=2,Concepto1 = 'ACTIVO CIRCULANTE', [A2023] = '', [A2024] = '',Concepto2 ='PASIVO CIRCULANTE', [P2023] = '', [P2024] = ''
	UNION
	SELECT id=3,Concepto1 = 'Efectivo y Equivalentes', [A2023] = '149,981,834.00', [A2024] = '149,981,834.00',Concepto2 ='Cuentas por Pagar a Corto Plazo', [P2023] = '-32,518,832.00', [P2024] = '-31,969,450.00'
	UNION
	SELECT id=4,Concepto1 = 'Derechos a Recibir Efectivo o Equivalentes', [A2023] = '2,336,111,208.00', [A2024] = '2,336,123,168.00',Concepto2 ='Documentos por Pagar a Corto Plazo', [P2023] = '2,541,228.00', [P2024] = '2,541,228.00'
	UNION
	SELECT id=6,Concepto1 = 'Derechos a Recibir Bienes o Servicios', [A2023] = '0.00', [A2024] = '0.00',Concepto2 ='Porción a Corto Plazo de la Deuda Pública a Largo Plazo', [P2023] = '0.00', [P2024] = '0.00'
	UNION
	SELECT id=7,Concepto1 = 'Inventarios', [A2023] = '0.00', [A2024] = '0.00',Concepto2 ='Títulos y Valores a Corto Plazo', [P2023] = '0.00', [P2024] = '0.00'
	UNION
	SELECT id=8,Concepto1 = 'Almacenes', [A2023] = '650,258.00', [A2024] = '650,258.00',Concepto2 ='Pasivos Diferidos a Corto Plazo', [P2023] = '2,541,228.00', [P2024] = '2,541,228.00'
	UNION
	SELECT id=9,Concepto1 = 'Estimación por Pérdida o Deterioro de Activos Circulantes', [A2023] = '-263,851,881.00', [A2024] = '-263,851,881.00',Concepto2 ='Fondos y Bienes de Terceros en Garantía y/o Administración a Corto Plazo', [P2023] = '2,541,228.00', [P2024] = '2,541,228.00'
	UNION
	SELECT id=10,Concepto1 = 'Otros Activos Circulantes', [A2023] = '0.00', [A2024] = '0.00',Concepto2 ='Provisiones a Corto Plazo', [P2023] = '4,902,525.00', [P2024] = '4,902,525.00'
	UNION
	SELECT id=11,Concepto1 = '', [A2023] = '', [A2024] = '',Concepto2 ='Otros Pasivos a Corto Plazo', [P2023] = '0.00', [P2024] = '0.00'
	UNION
	SELECT id=12,Concepto1 = 'Total de Activos Circulantes', [A2023] = '2,222,891,419.0', [A2024] = '2,222,903,379.0',Concepto2 ='Otros Pasivos a Corto Plazo', [P2023] = '-29,797,673.00', [P2024] = '-29,248,291.00'
	UNION
	SELECT id=13,Concepto1 = '', [A2023] = '', [A2024] = '',Concepto2 ='', [P2023] = '', [P2024] = ''
	--
	UNION
	SELECT id=15,Concepto1 = 'Activo No Circulante', [A2023] = '', [A2024] = '',Concepto2 ='Pasivo No Circulante', [P2023] = '', [P2024] = ''
	UNION
	SELECT id=16,Concepto1 = 'Inversiones financieras a Largo Plazo ', [A2023] = '0.00', [A2024] = '0.00',Concepto2 ='Cuentas por Pagar a Largo Plazo', [P2023] = '0.00', [P2024] = '0.00'
	UNION
	SELECT id=17,Concepto1 = 'Derechos a Recibir Efectivo o Equivalentes a Largo Plazo', [A2023] = '0.00', [A2024] = '0.00',Concepto2 ='Documentos por Pagar a Largo Plazo', [P2023] = '0.00', [P2024] = '0.00'
	UNION
	SELECT id=18,Concepto1 = 'Bienes Inmuebles, Infraestructura y Construcciones en Proceso', [A2023] = '0.00', [A2024] = '0.00',Concepto2 ='Deuda Pública a Plazo', [P2023] = '0.00', [P2024] = '0.00'
	UNION
	SELECT id=19,Concepto1 = 'Bienes Muebles', [A2023] = '7,162,122.00', [A2024] = '7,162,122.00',Concepto2 ='Pasivos Diferidos a Largo Plazo', [P2023] = '0.00', [P2024] = '0.00'
	UNION
	SELECT id=20,Concepto1 = 'Activos Intangibles', [A2023] = '2,541,228.00', [A2024] = '2,541,228.00',Concepto2 ='Fondos y Bienes de Terceros en Garantía y/o Administración Largo Plazo', [P2023] = '0.00', [P2024] = '0.00'
	UNION
	SELECT id=21,Concepto1 = 'Depreciación, Deterioro y Amortización Acumulada de Bienes', [A2023] = '-5,934,956.00', [A2024] = '-5,934,956.00',Concepto2 ='Provisiones a Largo Plazo', [P2023] = '0.00', [P2024] = '0.00'
	UNION
	SELECT id=22,Concepto1 = 'Activos Diferidos', [A2023] = '2,541,228.00', [A2024] = '2,541,228.00',Concepto2 ='', [P2023] = '', [P2024] = ''
	UNION
	SELECT id=23,Concepto1 = 'Estimación por Perdida o Deterioro de Activos no Circulantes', [A2023] = '0.00', [A2024] = '0.00',Concepto2 ='Total de Pasivos No Circulantes', [P2023] = '0.00', [P2024] = '0.00'
	UNION
	SELECT id=24,Concepto1 = 'Otros Activos no Circulantes', [A2023] = '0.00', [A2024] = '0.00',Concepto2 ='', [P2023] = '', [P2024] = ''
	UNION
	SELECT id=25,Concepto1 = '', [A2023] = '', [A2024] = '',Concepto2 ='Total del Pasivo', [P2023] = '0.00', [P2024] = '0.00'
	UNION
	SELECT id=26,Concepto1 = '', [A2023] = '', [A2024] = '',Concepto2 ='HACIENDA PÚBLICA / PATRIMONIO', [P2023] = '', [P2024] = ''
	UNION
	SELECT id=28,Concepto1 = '', [A2023] = '', [A2024] = '',Concepto2 ='Hacienda Pública / Patrimonio Contribuido', [P2023] = '-3,112,907,042.', [P2024] = '-3,112,907,042.'
	UNION
	SELECT id=29,Concepto1 = '', [A2023] = '', [A2024] = '',Concepto2 ='', [P2023] = '', [P2024] = ''
	--
	UNION
	SELECT id=30,Concepto1 = '', [A2023] = '', [A2024] = '',Concepto2 ='Aportaciones', [P2023] = '-3,112,907,042.', [P2024] = '-3,112,907,042.'
	UNION
	SELECT id=31,Concepto1 = '', [A2023] = '', [A2024] = '',Concepto2 ='', [P2023] = '', [P2024] = ''
	--
	UNION
	SELECT id=32,Concepto1 = '', [A2023] = '', [A2024] = '',Concepto2 ='Donaciones de Capital ', [P2023] = '0.00', [P2024] = '0.00'
	UNION
	SELECT id=33,Concepto1 = '', [A2023] = '', [A2024] = '',Concepto2 ='Actualización de la Hacienda Publica/Patrimonio', [P2023] = '0.00', [P2024] = '0.00'
	UNION
	SELECT id=34,Concepto1 = '', [A2023] = '', [A2024] = '',Concepto2 ='Hacienda Pública / Patrimonio Generado', [P2023] = '61,949,312.00', [P2024] = '61,949,312.00'
	UNION
	SELECT id=35,Concepto1 = '', [A2023] = '', [A2024] = '',Concepto2 ='Resultados del Ejercicio (Ahorro / Desahorro)', [P2023] = '532,861,201.00', [P2024] = '532,861,201.00'
	UNION
	SELECT id=36,Concepto1 = '', [A2023] = '', [A2024] = '',Concepto2 ='Resultados de Ejercicios Anteriores', [P2023] = '-471,636,791.00', [P2024] = '-471,636,791.00'
	UNION
	SELECT id=37,Concepto1 = '', [A2023] = '', [A2024] = '',Concepto2 ='Revalúos', [P2023] = '724,902.00', [P2024] = '724,902.00'
	UNION
	SELECT id=38,Concepto1 = '', [A2023] = '', [A2024] = '',Concepto2 ='Reservas', [P2023] = '0.00', [P2024] = '0.00'
	UNION
	SELECT id=39,Concepto1 = '', [A2023] = '', [A2024] = '',Concepto2 ='Rectificaciones de Resultados de Ejercicios Anteriores', [P2023] = '0.00', [P2024] = '0.00'
	UNION
	SELECT id=40,Concepto1 = '', [A2023] = '', [A2024] = '',Concepto2 ='Exceso o Insuficiencia en la Actualización de la Hacienda Pública/Patrimonio', [P2023] = '0.00', [P2024] = '0.00'
	UNION
	SELECT id=41,Concepto1 = '', [A2023] = '', [A2024] = '',Concepto2 ='Resultado por Posición Monetaria', [P2023] = '0.00', [P2024] = '0.00'
	UNION
	SELECT id=42,Concepto1 = '', [A2023] = '', [A2024] = '',Concepto2 ='Resultado por Tenencia de Activos no Monetarios', [P2023] = '0.00', [P2024] = '0.00'
	UNION
	SELECT id=43,Concepto1 = 'Total de Activos No Circulantes', [A2023] = '6,309,622.00', [A2024] = '6,309,622.00',Concepto2 ='Total Hacienda Pública / Patrimonio', [P2023] = '-3,050,957,730.', [P2024] = '-3,050,957,730.'
	UNION
	SELECT id=44,Concepto1 = '', [A2023] = '', [A2024] = '',Concepto2 ='', [P2023] = '', [P2024] = ''
	--
	UNION
	SELECT id=45,Concepto1 = 'Total de Activo', [A2023] = '2,229,201,041.0 ', [A2024] = '2,229,213,001.0',Concepto2 ='Total del Pasivo y Hacienda Pública / Patrimonio', [P2023] = '-3,050,957,730.', [P2024] = '-3,050,957,730.'
	--FIN

	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('DEL ' , FORMAT(@p_FechaInicio, 'dd \de MMMM \del yyyy', 'es-MX') , ' AL ' ,  FORMAT(@p_FechaFin, 'dd \de MMMM \del yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tlbEstadoDeSitucionFinanciera

END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_EstadoSituacionFinanciera_DevEx]';
GO
CREATE OR ALTER PROCEDURE [CONTA].[SPR_EstadoSituacionFinanciera_DevEx]
		@FechaFin DATETIME,
		@FKIdMes_SIS INT
AS
BEGIN
	DECLARE @FKIdAnio_SIS INT =(SELECT A.PKIdAnio 
	                              FROM SIS.Anio AS A 
								  WHERE A.Clave =  YEAR(@FechaFin))

--//
	DECLARE
	-- Activo
	 @_1110000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '1110000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_1120000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '1120000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_1130000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '1130000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_1140000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '1140000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_1150000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '1150000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_1160000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '1160000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_1170000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '1170000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	-- Pasivo																																				@FKIdAnio_SIS						@FKIdMes_SIS
	,@_2110000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '2110000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_2120000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '2120000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_2130000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '2130000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_2140000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '2140000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_2150000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '2150000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_2160000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '2160000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_2170000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '2170000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_2180000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '2180000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	-- Activo No Circulante																																	@FKIdAnio_SIS						@FKIdMes_SIS
	,@_1210000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '1210000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_1220000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '1220000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_1230000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '1230000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_1240000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '1240000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_1250000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '1250000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_1260000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '1260000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_1270000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '1270000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_1280000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '1280000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_1290000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '1290000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	-- Pasivo No Circulante																																	@FKIdAnio_SIS						@FKIdMes_SIS
	,@_2210000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '2210000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_2220000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '2220000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_2230000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '2230000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_2240000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '2240000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_2250000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '2250000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_2260000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '2260000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	-- Hacienda Publica / Patrimonio Contribuido																											@FKIdAnio_SIS						@FKIdMes_SIS
	,@_3122300000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '3122300000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_3122200000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '3122200000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_3122100000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '3122100000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	-- Hacienda Publica / Patrimonio Generado																												@FKIdAnio_SIS						@FKIdMes_SIS
	,@_3210000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '3210000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_3220000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '3220000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_3230000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '3230000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_3240000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '3240000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	,@_3250000000 DECIMAL(18, 2) = (SELECT SaldoFinal FROM [CONTA].[SaldoInicialBalanzaComprobacion] WHERE [NoCuenta] = '3250000000' AND [FKIdAnio_SIS] = @FKIdAnio_SIS AND [FKIdMes_SIS] = @FKIdMes_SIS)
	-- Exceso o Insuf.
	,@_Exc01 DECIMAL(18, 2) = 0
	,@_Exc02 DECIMAL(18, 2) = 0

		--//

IF (@FKIdMes_SIS = 13)
SET @FKIdMes_SIS = @FKIdMes_SIS - 1;

		DECLARE
		 @4212000000 DECIMAL(18, 2) = (SELECT X.SaldoFinal FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta = '4212000000' AND X.FKIdAnio_SIS = @FKIdAnio_SIS AND X.FKIdMes_SIS = @FKIdMes_SIS)
		,@OtrosIngresos DECIMAL(18, 2) = (SELECT SUM(X.SaldoFinal) FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta IN ('4100000000','4213000000', '4300000000','4413000000') AND X.FKIdAnio_SIS = @FKIdAnio_SIS AND X.FKIdMes_SIS = @FKIdMes_SIS)
		,@5110000000 DECIMAL(18, 2) = (SELECT X.SaldoFinal FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta = '5110000000' AND X.FKIdAnio_SIS = @FKIdAnio_SIS AND X.FKIdMes_SIS = @FKIdMes_SIS)
		,@5120000000 DECIMAL(18, 2) = (SELECT X.SaldoFinal FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta = '5120000000' AND X.FKIdAnio_SIS = @FKIdAnio_SIS AND X.FKIdMes_SIS = @FKIdMes_SIS)
		,@5130000000 DECIMAL(18, 2) = (SELECT X.SaldoFinal FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta = '5130000000' AND X.FKIdAnio_SIS = @FKIdAnio_SIS AND X.FKIdMes_SIS = @FKIdMes_SIS)
		,@5212200000 DECIMAL(18, 2) = (SELECT X.SaldoFinal FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta = '5212200000' AND X.FKIdAnio_SIS = @FKIdAnio_SIS AND X.FKIdMes_SIS = @FKIdMes_SIS)
		,@5080000000 DECIMAL(18, 2) = (SELECT X.SaldoFinal FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta = '5280000000' AND X.FKIdAnio_SIS = @FKIdAnio_SIS AND X.FKIdMes_SIS = @FKIdMes_SIS)
		,@5500000000 DECIMAL(18, 2) = (SELECT X.SaldoFinal FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta = '5510000000' AND X.FKIdAnio_SIS = @FKIdAnio_SIS AND X.FKIdMes_SIS = @FKIdMes_SIS)
		,@5590000000 DECIMAL(18, 2) = (SELECT X.SaldoFinal FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta = '5590000000' AND X.FKIdAnio_SIS = @FKIdAnio_SIS AND X.FKIdMes_SIS = @FKIdMes_SIS)
	
	DECLARE @T_PATASYOA DECIMAL(18, 2) = @4212000000
	DECLARE @T_OIYB DECIMAL(18, 2) = @OtrosIngresos
	DECLARE @SubTotalIngresosOtrosBeneficios DECIMAL(18, 2) = @T_PATASYOA + @T_OIYB
	DECLARE @T_GDF DECIMAL(18, 2) = @5110000000 + @5120000000 + @5130000000
	DECLARE @T_TASYOA DECIMAL(18, 2) = @5080000000 + @5212200000
	DECLARE @T_OGYPE DECIMAL(18, 2) = @5500000000 + @5590000000
	DECLARE @SubtotalGastosYOtrasPerdidas DECIMAL(18, 2) = @T_GDF + @T_OGYPE + @T_TASYOA
	DECLARE @TotalAhorroYDesahorro DECIMAL(18, 2) = @SubTotalIngresosOtrosBeneficios - @SubtotalGastosYOtrasPerdidas

	SET @_3210000000 = @TotalAhorroYDesahorro
	
	--//
	
	-- TOTALES
	DECLARE @T_Activo DECIMAL(18, 2) = (		ROUND(ISNULL(@_1110000000, 0), -2) 
										   +	ROUND(ISNULL(@_1120000000, 0), -2) 
										   +	ROUND(ISNULL(@_1130000000, 0), -2)
										   +	ROUND(ISNULL(@_1140000000, 0), -2)
										   +	ROUND(ISNULL(@_1150000000, 0), -2)
										   +	ROUND(ISNULL(@_1160000000, 0), -2)
										   +	ROUND(ISNULL(@_1170000000, 0), -2)
									   );
	
	DECLARE @T_Pasivo DECIMAL(18, 2) = (    	ROUND(ISNULL(@_2110000000, 0), -2)
										   +	ROUND(ISNULL(@_2120000000, 0), -2)
										   +	ROUND(ISNULL(@_2130000000, 0), -2)
										   +	ROUND(ISNULL(@_2140000000, 0), -2)
										   +	ROUND(ISNULL(@_2150000000, 0), -2)
										   +	ROUND(ISNULL(@_2160000000, 0), -2)
										   +	ROUND(ISNULL(@_2170000000, 0), -2)
										   +	ROUND(ISNULL(@_2180000000, 0), -2)
									  );
	
	DECLARE @T_ActNoCirculante DECIMAL(18, 2) = (	    ROUND(ISNULL(@_1210000000, 0), -2)
												   +	ROUND(ISNULL(@_1220000000, 0), -2)
												   +	ROUND(ISNULL(@_1230000000, 0), -2)
												   +	ROUND(ISNULL(@_1240000000, 0), -2)
												   +	ROUND(ISNULL(@_1250000000, 0), -2)
												   -	ROUND(ISNULL(@_1260000000, 0), -2)
												   +	ROUND(ISNULL(@_1270000000, 0), -2)
												   +	ROUND(ISNULL(@_1280000000, 0), -2)
												   +	ROUND(ISNULL(@_1290000000, 0), -2)
	                                            );
	DECLARE @T_PasNoCirculante DECIMAL(18, 2) = (
														ROUND(ISNULL(@_2210000000, 0), -2)
													+	ROUND(ISNULL(@_2220000000, 0), -2)
													+	ROUND(ISNULL(@_2230000000, 0), -2)
													+	ROUND(ISNULL(@_2240000000, 0), -2)
													+	ROUND(ISNULL(@_2250000000, 0), -2)
													+	ROUND(ISNULL(@_2260000000, 0), -2)
	                                            );
	DECLARE @T_HPPC DECIMAL(18, 2) = (
											ROUND(ISNULL(@_3122300000, 0), -2)
										+	ROUND(ISNULL(@_3122200000, 0), -2)
										+	ROUND(ISNULL(@_3122100000, 0), -2)
	                                 );
	DECLARE @T_HPPG DECIMAL(18, 2) = (
										  ROUND(ISNULL(@_3210000000, 0), -2)
										+ ROUND(ISNULL(@_3220000000, 0), -2)
										+ ROUND(ISNULL(@_3230000000, 0), -2)
										+ ROUND(ISNULL(@_3240000000, 0), -2)
										+ ROUND(ISNULL(@_3250000000, 0), -2)
	                                 );
	
	DECLARE @T_EOF DECIMAL(18 ,2) = ROUND(ISNULL(@_Exc01, 0), -2) +	ROUND(ISNULL(@_Exc02, 0), -2);
	

	DECLARE @Mes NVARCHAR(50) = CASE WHEN MONTH(@FechaFin) = 1 THEN 'ENERO'
								     WHEN MONTH(@FechaFin) = 2 THEN 'FEBRERO'
									 WHEN MONTH(@FechaFin) = 3 THEN 'MARZO'
									 WHEN MONTH(@FechaFin) = 4 THEN 'ABRIL'
									 WHEN MONTH(@FechaFin) = 5 THEN 'MAYO'
									 WHEN MONTH(@FechaFin) = 6 THEN 'JUNIO'
									 WHEN MONTH(@FechaFin) = 7 THEN 'JULIO'
									 WHEN MONTH(@FechaFin) = 8 THEN 'AGOSTO'
									 WHEN MONTH(@FechaFin) = 9 THEN 'SEPTIEMBRE'
									 WHEN MONTH(@FechaFin) = 10 THEN 'OCTUBRE'
									 WHEN MONTH(@FechaFin) = 11 THEN 'NOVIEMBRE'
									 WHEN MONTH(@FechaFin) = 12 THEN 'DICIEMBRE'
								END;
								 

	SELECT
	      CAST(DAY(@FechaFin) AS VARCHAR) +' DE '+ @Mes + ' DE ' + CAST(YEAR(@FechaFin) AS VARCHAR) AS Fecha
		 ,YEAR(@FechaFin) AS Anio
		 ,CASE WHEN @_1110000000 < 0 THEN '('+ FORMAT(ROUND(@_1110000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_1110000000, NULL), -2),'N', 'EN-US') END AS A_111  
	     ,CASE WHEN @_1120000000 < 0 THEN '('+ FORMAT(ROUND(@_1120000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_1120000000, NULL), -2),'N', 'EN-US') END AS A_112  
		 ,CASE WHEN @_1130000000 < 0 THEN '('+ FORMAT(ROUND(@_1130000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_1130000000, NULL), -2),'N', 'EN-US') END AS A_113  
		 ,CASE WHEN @_1140000000 < 0 THEN '('+ FORMAT(ROUND(@_1140000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_1140000000, NULL), -2),'N', 'EN-US') END AS A_114  
		 ,CASE WHEN @_1150000000 < 0 THEN '('+ FORMAT(ROUND(@_1150000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_1150000000, NULL), -2),'N', 'EN-US') END AS A_115  
		 ,CASE WHEN @_1160000000 < 0 THEN '('+ FORMAT(ROUND(@_1160000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_1160000000, NULL), -2),'N', 'EN-US') END AS A_116  
		 ,CASE WHEN @_1170000000 < 0 THEN '('+ FORMAT(ROUND(@_1170000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_1170000000, NULL), -2),'N', 'EN-US') END AS A_117  
		 ,CASE WHEN @_2110000000 < 0 THEN '('+ FORMAT(ROUND(@_2110000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_2110000000, NULL), -2),'N', 'EN-US') END AS P_211  
		 ,CASE WHEN @_2120000000 < 0 THEN '('+ FORMAT(ROUND(@_2120000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_2120000000, NULL), -2),'N', 'EN-US') END AS P_212  
		 ,CASE WHEN @_2130000000 < 0 THEN '('+ FORMAT(ROUND(@_2130000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_2130000000, NULL), -2),'N', 'EN-US') END AS P_213  
		 ,CASE WHEN @_2140000000 < 0 THEN '('+ FORMAT(ROUND(@_2140000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_2140000000, NULL), -2),'N', 'EN-US') END AS P_214  
		 ,CASE WHEN @_2150000000 < 0 THEN '('+ FORMAT(ROUND(@_2150000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_2150000000, NULL), -2),'N', 'EN-US') END AS P_215  
		 ,CASE WHEN @_2160000000 < 0 THEN '('+ FORMAT(ROUND(@_2160000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_2160000000, NULL), -2),'N', 'EN-US') END AS P_216  
		 ,CASE WHEN @_2170000000 < 0 THEN '('+ FORMAT(ROUND(@_2170000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_2170000000, NULL), -2),'N', 'EN-US') END AS P_217  
		 ,CASE WHEN @_2180000000 < 0 THEN '('+ FORMAT(ROUND(@_2180000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_2180000000, NULL), -2),'N', 'EN-US') END AS P_218   
		 ,CASE WHEN @_1210000000 < 0 THEN '('+ FORMAT(ROUND(@_1210000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_1210000000, NULL), -2),'N', 'EN-US') END AS ANC_121
		 ,CASE WHEN @_1220000000 < 0 THEN '('+ FORMAT(ROUND(@_1220000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_1220000000, NULL), -2),'N', 'EN-US') END AS ANC_122
		 ,CASE WHEN @_1230000000 < 0 THEN '('+ FORMAT(ROUND(@_1230000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_1230000000, NULL), -2),'N', 'EN-US') END AS ANC_123
		 ,CASE WHEN @_1240000000 < 0 THEN '('+ FORMAT(ROUND(@_1240000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_1240000000, NULL), -2),'N', 'EN-US') END AS ANC_124
		 ,CASE WHEN @_1250000000 < 0 THEN '('+ FORMAT(ROUND(@_1250000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_1250000000, NULL), -2),'N', 'EN-US') END AS ANC_125
		 ,CASE WHEN @_1260000000 < 0 THEN '('+ FORMAT(ROUND(@_1260000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_1260000000, NULL), -2),'N', 'EN-US') END AS ANC_126
		 ,CASE WHEN @_1270000000 < 0 THEN '('+ FORMAT(ROUND(@_1270000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_1270000000, NULL), -2),'N', 'EN-US') END AS ANC_127
		 ,CASE WHEN @_1280000000 < 0 THEN '('+ FORMAT(ROUND(@_1280000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_1280000000, NULL), -2),'N', 'EN-US') END AS ANC_128
		 ,CASE WHEN @_1290000000 < 0 THEN '('+ FORMAT(ROUND(@_1290000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_1290000000, NULL), -2),'N', 'EN-US') END AS ANC_129
		 ,CASE WHEN @_2210000000 < 0 THEN '('+ FORMAT(ROUND(@_2210000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_2210000000, NULL), -2),'N', 'EN-US') END AS PNC_221
		 ,CASE WHEN @_2220000000 < 0 THEN '('+ FORMAT(ROUND(@_2220000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_2220000000, NULL), -2),'N', 'EN-US') END AS PNC_222
		 ,CASE WHEN @_2230000000 < 0 THEN '('+ FORMAT(ROUND(@_2230000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_2230000000, NULL), -2),'N', 'EN-US') END AS PNC_223
		 ,CASE WHEN @_2240000000 < 0 THEN '('+ FORMAT(ROUND(@_2240000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_2240000000, NULL), -2),'N', 'EN-US') END AS PNC_224
		 ,CASE WHEN @_2250000000 < 0 THEN '('+ FORMAT(ROUND(@_2250000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_2250000000, NULL), -2),'N', 'EN-US') END AS PNC_225
		 ,CASE WHEN @_2260000000 < 0 THEN '('+ FORMAT(ROUND(@_2260000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_2260000000, NULL), -2),'N', 'EN-US') END AS PNC_226
		 ,CASE WHEN @_3122300000 < 0 THEN '('+ FORMAT(ROUND(@_3122300000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_3122300000, NULL), -2),'N', 'EN-US') END AS HPPC_31223
		 ,CASE WHEN @_3122200000 < 0 THEN '('+ FORMAT(ROUND(@_3122200000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_3122200000, NULL), -2),'N', 'EN-US') END AS HPPC_31222
		 ,CASE WHEN @_3122100000 < 0 THEN '('+ FORMAT(ROUND(@_3122100000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_3122100000, NULL), -2),'N', 'EN-US') END AS HPPC_31221
		 ,CASE WHEN @_3210000000 < 0 THEN '('+ FORMAT(ROUND(@_3210000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_3210000000, NULL), -2),'N', 'EN-US') END AS HPPG_321
	     ,CASE WHEN @_3220000000 < 0 THEN '('+ FORMAT(ROUND(@_3220000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_3220000000, NULL), -2),'N','EN-US') END AS HPPG_322
		 ,CASE WHEN @_3230000000 < 0 THEN '('+ FORMAT(ROUND(@_3230000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_3230000000, NULL), -2),'N','EN-US') END AS HPPG_323
		 ,CASE WHEN @_3240000000 < 0 THEN '('+ FORMAT(ROUND(@_3240000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_3240000000, NULL), -2),'N','EN-US') END AS HPPG_324
	     ,CASE WHEN @_3250000000 < 0 THEN '('+ FORMAT(ROUND(@_3250000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_3250000000, NULL), -2),'N','EN-US') END AS HPPG_325
		 ,CASE WHEN @_Exc01 < 0 THEN '('+ FORMAT(ROUND(ISNULL(@_Exc01 * -1, 0), -2),'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_Exc01, NULL), -2),'N','EN-US') END AS Exc01 
		 ,CASE WHEN @_Exc02 < 0 THEN '('+ FORMAT(ROUND(ISNULL(@_Exc02 * -1, 0), -2),'N','EN-US') +')' ELSE FORMAT(ROUND(ISNULL(@_Exc02, NULL), -2),'N','EN-US') END AS Exc02
		 ,CASE WHEN @T_Activo < 0 THEN '('+ FORMAT(@T_Activo * -1, 'N','EN-US') +')' ELSE FORMAT(ISNULL(@T_Activo, NULL), 'N','EN-US') END AS T_Activo
		 ,CASE WHEN @T_Pasivo < 0 THEN '('+ FORMAT(@T_Pasivo * -1, 'N','EN-US') +')' ELSE FORMAT(ISNULL(@T_Pasivo, NULL), 'N','EN-US') END AS T_Pasivo
		 ,CASE WHEN @T_ActNoCirculante < 0 THEN '('+ FORMAT(@T_ActNoCirculante * -1, 'N','EN-US') +')' ELSE FORMAT(ISNULL(@T_ActNoCirculante, NULL), 'N','EN-US') END AS T_ActNoCirculante
		 ,CASE WHEN @T_PasNoCirculante < 0 THEN '('+ FORMAT(@T_PasNoCirculante * -1, 'N','EN-US') +')' ELSE FORMAT(ISNULL(@T_PasNoCirculante, NULL), 'N','EN-US') END AS T_PasNoCirculante
		 ,CASE WHEN @T_HPPC < 0 THEN '('+ FORMAT(@T_HPPC * -1, 'N','EN-US') +')' ELSE FORMAT(ISNULL(@T_HPPC, NULL), 'N','EN-US') END AS T_HPPC
		 ,CASE WHEN @T_HPPG < 0 THEN '('+ FORMAT(@T_HPPG * -1, 'N','EN-US') +')' ELSE FORMAT(ISNULL(@T_HPPG, NULL), 'N','EN-US') END AS T_HPPG
		 ,CASE WHEN @T_EOF < 0 THEN '(' + FORMAT(@T_EOF * -1,'N','EN-US') + ')'  ELSE FORMAT(ISNULL(@T_EOF,NULL),'N','EN-US') END AS T_EOF
		 ,FORMAT(@T_Activo + @T_ActNoCirculante,'N','EN-US') AS TOTAL_ACTIVO
		 ,FORMAT(@T_Pasivo + @T_PasNoCirculante,'N','EN-US') AS TOTAL_PASIVO
		 ,FORMAT(@T_HPPC + @T_HPPG + @T_EOF,'N','EN-US') AS TOTAL_HACIENDA
		 ,FORMAT(@T_Pasivo + @T_PasNoCirculante + @T_HPPC + @T_HPPG +  @T_EOF,'N','EN-US') AS TOTAL_PASIVO_HACIENDA
		 INTO #PRUEBA

		 SELECT
		     Fecha
			,Anio
			,REPLACE(A_111,'00.00','') AS A_111  
			,REPLACE(A_112,'00.00','') AS A_112  
			,REPLACE(A_113,'00.00','') AS A_113  
			,REPLACE(A_114,'00.00','') AS A_114  
			,REPLACE(A_115,'00.00','') AS A_115  
			,REPLACE(A_116,'00.00','') AS A_116  
			,REPLACE(A_117,'00.00','') AS A_117  
			,REPLACE(P_211,'00.00','') AS P_211  
			,REPLACE(P_212,'00.00','') AS P_212  
			,REPLACE(P_213,'00.00','') AS P_213  
			,REPLACE(P_214,'00.00','') AS P_214  
			,REPLACE(P_215,'00.00','') AS P_215  
			,REPLACE(P_216,'00.00','') AS P_216  
			,REPLACE(P_217,'00.00','') AS P_217  
			,REPLACE(P_218,'00.00','') AS P_218   
			,REPLACE(ANC_121,'00.00','') AS ANC_121
			,REPLACE(ANC_122,'00.00','') AS ANC_122
			,REPLACE(ANC_123,'00.00','') AS ANC_123
			,REPLACE(ANC_124,'00.00','') AS ANC_124
			,REPLACE(ANC_125,'00.00','') AS ANC_125
			,'(' + REPLACE(ANC_126,'00.00','') +')' AS ANC_126
			,REPLACE(ANC_127,'00.00','') AS ANC_127
			,REPLACE(ANC_128,'00.00','') AS ANC_128
			,REPLACE(ANC_129,'00.00','') AS ANC_129
			,REPLACE(PNC_221,'00.00','') AS PNC_221
			,REPLACE(PNC_222,'00.00','') AS PNC_222
			,REPLACE(PNC_223,'00.00','') AS PNC_223
			,REPLACE(PNC_224,'00.00','') AS PNC_224
			,REPLACE(PNC_225,'00.00','') AS PNC_225
			,REPLACE(PNC_226,'00.00','') AS PNC_226
			,REPLACE(HPPC_31223,'00.00','') AS HPPC_31223
			,REPLACE(HPPC_31222,'00.00','') AS HPPC_31222
			,REPLACE(HPPC_31221,'00.00','') AS HPPC_31221
			,REPLACE(HPPG_321,'00.00','') AS HPPG_321
			,REPLACE(HPPG_322,'00.00','') AS HPPG_322
			,REPLACE(HPPG_323,'00.00','') AS HPPG_323
			,REPLACE(HPPG_324,'00.00','') AS HPPG_324
			,REPLACE(HPPG_325,'00.00','') AS HPPG_325
			,CASE WHEN Exc01 = '0.00' THEN ''  ELSE REPLACE(Exc01,'00.00','') END AS Exc01
			,CASE WHEN Exc02 = '0.00' THEN ''  ELSE REPLACE(Exc02,'00.00','') END AS Exc02
			,CASE WHEN T_Activo = '0.00' THEN '' ELSE REPLACE(T_Activo,'00.00','') END AS T_Activo
			,CASE WHEN T_Pasivo = '0.00' THEN '' ELSE REPLACE(T_Pasivo,'00.00','') END AS T_Pasivo
			,CASE WHEN T_ActNoCirculante = '0.00' THEN '' ELSE REPLACE(T_ActNoCirculante,'00.00','') END AS T_ActNoCirculante
			,CASE WHEN T_PasNoCirculante = '0.00' THEN '' ELSE REPLACE(T_PasNoCirculante,'00.00','') END AS T_PasNoCirculante
			,CASE WHEN T_HPPC = '0.00' THEN '' ELSE REPLACE(T_HPPC,'00.00','') END AS T_HPPC
			,CASE WHEN T_HPPG = '0.00' THEN '' ELSE REPLACE(T_HPPG,'00.00','') END AS T_HPPG
			,CASE WHEN T_EOF = '0.00' THEN '' ELSE REPLACE(T_EOF,'00.00','') END AS T_EOF
			,CASE WHEN TOTAL_ACTIVO = '0.00' THEN '' ELSE REPLACE(TOTAL_ACTIVO,'00.00','') END AS TOTAL_ACTIVO
			,CASE WHEN TOTAL_PASIVO = '0.00' THEN '' ELSE REPLACE(TOTAL_PASIVO,'00.00','') END AS TOTAL_PASIVO
			,CASE WHEN TOTAL_HACIENDA = '0.00' THEN '' ELSE REPLACE(TOTAL_HACIENDA,'00.00','') END AS TOTAL_HACIENDA
			,CASE WHEN TOTAL_PASIVO_HACIENDA = '0.00' THEN '' ELSE REPLACE(TOTAL_PASIVO_HACIENDA,'00.00','') END AS TOTAL_PASIVO_HACIENDA
		 FROM #PRUEBA
		 DROP TABLE #PRUEBA
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_EstadoSituacionFinancieraComparativo_DevEx]';
GO
CREATE OR ALTER PROCEDURE [CONTA].[SPR_EstadoSituacionFinancieraComparativo_DevEx]
		@FechaFin DATETIME,-- = '20160430',
		@EsCierre BIT = 0
AS
BEGIN
SET FMTONLY OFF;
	DECLARE @AnioActual INT = (SELECT PKIdAnio FROM SIS.Anio WHERE Clave = YEAR(@FechaFin))
	       ,@AnioAnterior INT = (SELECT PKIdAnio FROM SIS.Anio WHERE Clave = YEAR(@FechaFin ) - 1)
		   ,@Mes INT = MONTH(@FechaFin)

	DECLARE @FechaPeriodo NVARCHAR(100) = CAST(DAY(@FechaFin) AS VARCHAR) +' DE '+ CASE WHEN @Mes = 1 THEN 'ENERO'
	                                                                   WHEN @Mes = 2 THEN 'FEBRERO'
																	   WHEN @Mes = 3 THEN 'MARZO'
																	   WHEN @Mes = 4 THEN 'ABRIL'
																	   WHEN @Mes = 5 THEN 'MAYO'
																	   WHEN @Mes = 6 THEN 'JUNIO'
																	   WHEN @Mes = 7 THEN 'JULIO'
																	   WHEN @Mes = 8 THEN 'AGOSTO'
																	   WHEN @Mes = 9 THEN 'SEPTIEMBRE'
																	   WHEN @Mes = 10 THEN 'OCTUBRE'
																	   WHEN @Mes = 11 THEN 'NOVIEMBRE'
																	   WHEN @Mes = 12 THEN 'DICIEMBRE'
																	END + ' DEL ' + CAST(YEAR(@FechaFin) AS VARCHAR)
	--================================================================================
	--// Se recuperan los saldos finales de cuantas especificas del año de conculta
	SELECT
		-- FK_IdCuentacuenta
		 [1110000000] AS A_1110000000,[1120000000] AS A_1120000000,[1130000000] AS A_1130000000,[1140000000] AS A_1140000000,[1150000000] AS A_1150000000,[1160000000] AS A_1160000000,[1170000000] AS A_1170000000
		,[2110000000] AS A_2110000000,[2120000000] AS A_2120000000,[2130000000] AS A_2130000000,[2140000000] AS A_2140000000,[2150000000] AS A_2150000000,[2160000000] AS A_2160000000,[2170000000] AS A_2170000000,[2180000000] AS A_2180000000
		,[1210000000] AS A_1210000000,[1220000000] AS A_1220000000,[1230000000] AS A_1230000000,[1240000000] AS A_1240000000,[1250000000] AS A_1250000000,[1260000000] AS A_1260000000,[1270000000] AS A_1270000000,[1280000000] AS A_1280000000,[1290000000] AS A_1290000000
		,[2210000000] AS A_2210000000,[2220000000] AS A_2220000000,[2230000000] AS A_2230000000,[2240000000] AS A_2240000000,[2250000000] AS A_2250000000,[2260000000] AS A_2260000000			    							 
		,[3122300000] AS A_3122300000,[3122200000] AS A_3122200000,[3122100000] AS A_3122100000
		,[3210000000] AS A_3210000000,[3220000000] AS A_3220000000,[3230000000] AS A_3230000000,[3240000000] AS A_3240000000,[3250000000] AS A_3250000000
		,[Exc01] AS A_Exc01,[Exc02] AS A_Exc02
	INTO #SaldosFinalesAnioActual
	FROM (
			SELECT
				[SF].[NoCuenta] AS NoCuenta, SUM([SF].[SaldoFinal]) AS SaldoFinal
			FROM [conta].[SaldoInicialBalanzaComprobacion] AS [SF]
			WHERE [SF].[FKIdAnio_SIS] = @AnioActual
			AND [SF].[FKIdMes_SIS] = @Mes
			GROUP BY [SF].[NoCuenta]) AS DataSource
	PIVOT(
		SUM(SaldoFinal)
		FOR NoCuenta IN (
						 [1110000000],[1120000000],[1130000000],[1140000000],[1150000000],[1160000000],[1170000000]
						,[2110000000],[2120000000],[2130000000],[2140000000],[2150000000],[2160000000],[2170000000],[2180000000]
						,[1210000000],[1220000000],[1230000000],[1240000000],[1250000000],[1260000000],[1270000000],[1280000000],[1290000000]
						,[2210000000],[2220000000],[2230000000],[2240000000],[2250000000],[2260000000]
						,[3122300000],[3122200000],[3122100000]
						,[3210000000],[3220000000],[3230000000],[3240000000],[3250000000]
						,[Exc01],[Exc02])
	) AS PivotSource
	
	--// Se recuperan los saldos finales de cuentas especificas del año anterior al año de consulta.
	--   Esto para realizar el comparativo entre cuentas.
	--========================================================================================================================
	SELECT
		-- FK_IdCuentacuenta
		 [1110000000] AS B_1110000000,[1120000000] AS B_1120000000,[1130000000] AS B_1130000000,[1140000000] AS B_1140000000,[1150000000] AS B_1150000000,[1160000000] AS B_1160000000,[1170000000] AS B_1170000000
		,[2110000000] AS B_2110000000,[2120000000] AS B_2120000000,[2130000000] AS B_2130000000,[2140000000] AS B_2140000000,[2150000000] AS B_2150000000,[2160000000] AS B_2160000000,[2170000000] AS B_2170000000,[2180000000] AS B_2180000000
		,[1210000000] AS B_1210000000,[1220000000] AS B_1220000000,[1230000000] AS B_1230000000,[1240000000] AS B_1240000000,[1250000000] AS B_1250000000,[1260000000] AS B_1260000000,[1270000000] AS B_1270000000,[1280000000] AS B_1280000000,[1290000000] AS B_1290000000
		,[2210000000] AS B_2210000000,[2220000000] AS B_2220000000,[2230000000] AS B_2230000000,[2240000000] AS B_2240000000,[2250000000] AS B_2250000000,[2260000000] AS B_2260000000							 			 
		,[3122300000] AS B_3122300000,[3122200000] AS B_3122200000,[3122100000] AS B_3122100000,[3210000000] AS B_3210000000,[3220000000] AS B_3220000000,[3230000000] AS B_3230000000,[3240000000] AS B_3240000000,[3250000000] AS B_3250000000
		,[Exc01] AS B_Exc01,[Exc02] AS B_Exc02
	INTO #SaldosFinalesAnioAnterior
	FROM (
			SELECT
				[SF].[NoCuenta] AS NoCuenta, SUM([SF].[SaldoFinal]) AS SaldoFinal
			FROM [conta].[SaldoInicialBalanzaComprobacion] AS [SF]
			WHERE [SF].[FKIdAnio_SIS] = @AnioAnterior
			AND [SF].[FKIdMes_SIS] = @Mes
			GROUP BY [SF].[NoCuenta]) AS DataSource
	PIVOT(
		SUM(SaldoFinal)
		FOR NoCuenta IN (
						 [1110000000],[1120000000],[1130000000],[1140000000],[1150000000],[1160000000],[1170000000]
						,[2110000000],[2120000000],[2130000000],[2140000000],[2150000000],[2160000000],[2170000000],[2180000000]
						,[1210000000],[1220000000],[1230000000],[1240000000],[1250000000],[1260000000],[1270000000],[1280000000],[1290000000]
						,[2210000000],[2220000000],[2230000000],[2240000000],[2250000000],[2260000000]
						,[3122300000],[3122200000],[3122100000],[3210000000],[3220000000],[3230000000],[3240000000],[3250000000]
						,[Exc01],[Exc02])
	) AS PivotSource

	--======================================================================
	--//Anio Actual - Reporte de Actividades
	DECLARE
		 @4212000000 DECIMAL(18, 2) = (SELECT X.SaldoFinal FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta = '4212000000' AND X.FKIdAnio_SIS = @AnioActual AND X.FKIdMes_SIS = @Mes)
		,@OtrosIngresos DECIMAL(18, 2) = (SELECT SUM(X.SaldoFinal) FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta IN ('4100000000','4213000000', '4300000000','4413000000') AND X.FKIdAnio_SIS = @AnioActual AND X.FKIdMes_SIS = @Mes)
		,@5110000000 DECIMAL(18, 2) = (SELECT X.SaldoFinal FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta = '5110000000' AND X.FKIdAnio_SIS = @AnioActual AND X.FKIdMes_SIS = @Mes)
		,@5120000000 DECIMAL(18, 2) = (SELECT X.SaldoFinal FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta = '5120000000' AND X.FKIdAnio_SIS = @AnioActual AND X.FKIdMes_SIS = @Mes)
		,@5130000000 DECIMAL(18, 2) = (SELECT X.SaldoFinal FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta = '5130000000' AND X.FKIdAnio_SIS = @AnioActual AND X.FKIdMes_SIS = @Mes)
		,@5212200000 DECIMAL(18, 2) = (SELECT X.SaldoFinal FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta = '5212200000' AND X.FKIdAnio_SIS = @AnioActual AND X.FKIdMes_SIS = @Mes)
		,@5080000000 DECIMAL(18, 2) = (SELECT X.SaldoFinal FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta = '5280000000' AND X.FKIdAnio_SIS = @AnioActual AND X.FKIdMes_SIS = @Mes)
		,@5500000000 DECIMAL(18, 2) = (SELECT X.SaldoFinal FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta = '5510000000' AND X.FKIdAnio_SIS = @AnioActual AND X.FKIdMes_SIS = @Mes)
		,@5590000000 DECIMAL(18, 2) = (SELECT X.SaldoFinal FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta = '5590000000' AND X.FKIdAnio_SIS = @AnioActual AND X.FKIdMes_SIS = @Mes)
	
	DECLARE @T_PATASYOA DECIMAL(18, 2) = @4212000000
	DECLARE @T_OIYB DECIMAL(18, 2) = @OtrosIngresos
	DECLARE @SubTotalIngresosOtrosBeneficios DECIMAL(18, 2) = @T_PATASYOA + @T_OIYB
	DECLARE @T_GDF DECIMAL(18, 2) = @5110000000 + @5120000000 + @5130000000
	DECLARE @T_TASYOA DECIMAL(18, 2) = @5080000000 + @5212200000
	DECLARE @T_OGYPE DECIMAL(18, 2) = @5500000000 + @5590000000
	DECLARE @SubtotalGastosYOtrasPerdidas DECIMAL(18, 2) = @T_GDF + @T_OGYPE + @T_TASYOA
	DECLARE @TotalAhorroYDesahorro DECIMAL(18, 2) = @SubTotalIngresosOtrosBeneficios - @SubtotalGastosYOtrasPerdidas

	UPDATE #SaldosFinalesAnioActual
	SET A_3210000000 = @TotalAhorroYDesahorro
	--SET @_3210000000 = @TotalAhorroYDesahorro
	
--//Fin de Reporte Actividades

--//Anio Actual - Reporte de Actividades
	DECLARE
		 @AnioAnterior_4212000000 DECIMAL(18, 2) = (SELECT X.SaldoFinal FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta = '4212000000' AND X.FKIdAnio_SIS = @AnioAnterior AND X.FKIdMes_SIS = @Mes)
		,@AnioAnterior_OtrosIngresos DECIMAL(18, 2) = (SELECT SUM(X.SaldoFinal) FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta IN ('4100000000','4213000000', '4300000000','4413000000') AND X.FKIdAnio_SIS = @AnioAnterior AND X.FKIdMes_SIS = @Mes)
		,@AnioAnterior_5110000000 DECIMAL(18, 2) = (SELECT X.SaldoFinal FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta = '5110000000' AND X.FKIdAnio_SIS = @AnioAnterior AND X.FKIdMes_SIS = @Mes)
		,@AnioAnterior_5120000000 DECIMAL(18, 2) = (SELECT X.SaldoFinal FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta = '5120000000' AND X.FKIdAnio_SIS = @AnioAnterior AND X.FKIdMes_SIS = @Mes)
		,@AnioAnterior_5130000000 DECIMAL(18, 2) = (SELECT X.SaldoFinal FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta = '5130000000' AND X.FKIdAnio_SIS = @AnioAnterior AND X.FKIdMes_SIS = @Mes)
		,@AnioAnterior_5212200000 DECIMAL(18, 2) = (SELECT X.SaldoFinal FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta = '5212200000' AND X.FKIdAnio_SIS = @AnioAnterior AND X.FKIdMes_SIS = @Mes)
		,@AnioAnterior_5080000000 DECIMAL(18, 2) = (SELECT X.SaldoFinal FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta = '5280000000' AND X.FKIdAnio_SIS = @AnioAnterior AND X.FKIdMes_SIS = @Mes)
		,@AnioAnterior_5500000000 DECIMAL(18, 2) = (SELECT X.SaldoFinal FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta = '5510000000' AND X.FKIdAnio_SIS = @AnioAnterior AND X.FKIdMes_SIS = @Mes)
		,@AnioAnterior_5590000000 DECIMAL(18, 2) = (SELECT X.SaldoFinal FROM conta.SaldoInicialBalanzaComprobacion AS X WHERE X.NoCuenta = '5590000000' AND X.FKIdAnio_SIS = @AnioAnterior AND X.FKIdMes_SIS = @Mes)
	
	DECLARE @AnioAnterior_T_PATASYOA DECIMAL(18, 2) = @AnioAnterior_4212000000
	DECLARE @AnioAnterior_T_OIYB DECIMAL(18, 2) = @AnioAnterior_OtrosIngresos
	DECLARE @AnioAnterior_SubTotalIngresosOtrosBeneficios DECIMAL(18, 2) = @AnioAnterior_T_PATASYOA + @AnioAnterior_T_OIYB
	DECLARE @AnioAnterior_T_GDF DECIMAL(18, 2) = @AnioAnterior_5110000000 + @AnioAnterior_5120000000 + @AnioAnterior_5130000000
	DECLARE @AnioAnterior_T_TASYOA DECIMAL(18, 2) = @AnioAnterior_5080000000 + @AnioAnterior_5212200000
	DECLARE @AnioAnterior_T_OGYPE DECIMAL(18, 2) = @AnioAnterior_5500000000 + @AnioAnterior_5590000000
	DECLARE @AnioAnterior_SubtotalGastosYOtrasPerdidas DECIMAL(18, 2) = @AnioAnterior_T_GDF + @AnioAnterior_T_OGYPE + @AnioAnterior_T_TASYOA
	DECLARE @AnioAnterior_TotalAhorroYDesahorro DECIMAL(18, 2) = @AnioAnterior_SubTotalIngresosOtrosBeneficios - @AnioAnterior_SubtotalGastosYOtrasPerdidas

	UPDATE #SaldosFinalesAnioAnterior
	SET B_3210000000 = @AnioAnterior_TotalAhorroYDesahorro
	
	--======================================================================
	-- se calcula variacion entre cuentas Anio actual menos el anio Anterior.
	--======================================================================
	SELECT
		 V_1110000000 = ISNULL(A_1110000000, 0) - ISNULL(B_1110000000, 0)
		,V_1120000000 = ISNULL(A_1120000000, 0) - ISNULL(B_1120000000, 0)
		,V_1130000000 = ISNULL(A_1130000000, 0) - ISNULL(B_1130000000, 0)
		,V_1140000000 = ISNULL(A_1140000000, 0) - ISNULL(B_1140000000, 0)
		,V_1150000000 = ISNULL(A_1150000000, 0) - ISNULL(B_1150000000, 0)
		,V_1160000000 = ISNULL(A_1160000000, 0) - ISNULL(B_1160000000, 0)
		,V_1170000000 = ISNULL(A_1170000000, 0) - ISNULL(B_1170000000, 0)
		,V_2110000000 = ISNULL(A_2110000000, 0) - ISNULL(B_2110000000, 0)
		,V_2120000000 = ISNULL(A_2120000000, 0) - ISNULL(B_2120000000, 0)
		,V_2130000000 = ISNULL(A_2130000000, 0) - ISNULL(B_2130000000, 0)
		,V_2140000000 = ISNULL(A_2140000000, 0) - ISNULL(B_2140000000, 0)
		,V_2150000000 = ISNULL(A_2150000000, 0) - ISNULL(B_2150000000, 0)
		,V_2160000000 = ISNULL(A_2160000000, 0) - ISNULL(B_2160000000, 0)
		,V_2170000000 = ISNULL(A_2170000000, 0) - ISNULL(B_2170000000, 0)
		,V_2180000000 = ISNULL(A_2180000000, 0) - ISNULL(B_2180000000, 0)
		,V_1210000000 = ISNULL(A_1210000000, 0) - ISNULL(B_1210000000, 0)
		,V_1220000000 = ISNULL(A_1220000000, 0) - ISNULL(B_1220000000, 0)
		,V_1230000000 = ISNULL(A_1230000000, 0) - ISNULL(B_1230000000, 0)
		,V_1240000000 = ISNULL(A_1240000000, 0) - ISNULL(B_1240000000, 0)
		,V_1250000000 = ISNULL(A_1250000000, 0) - ISNULL(B_1250000000, 0)
		,V_1260000000 = ISNULL(A_1260000000, 0) - ISNULL(B_1260000000, 0)
		,V_1270000000 = ISNULL(A_1270000000, 0) - ISNULL(B_1270000000, 0)
		,V_1280000000 = ISNULL(A_1280000000, 0) - ISNULL(B_1280000000, 0)
		,V_1290000000 = ISNULL(A_1290000000, 0) - ISNULL(B_1290000000, 0)
		,V_2210000000 = ISNULL(A_2210000000, 0) - ISNULL(B_2210000000, 0)
		,V_2220000000 = ISNULL(A_2220000000, 0) - ISNULL(B_2220000000, 0)
		,V_2230000000 = ISNULL(A_2230000000, 0) - ISNULL(B_2230000000, 0)
		,V_2240000000 = ISNULL(A_2240000000, 0) - ISNULL(B_2240000000, 0)
		,V_2250000000 = ISNULL(A_2250000000, 0) - ISNULL(B_2250000000, 0)
		,V_2260000000 = ISNULL(A_2260000000, 0) - ISNULL(B_2260000000, 0)
		,V_3122300000 = ISNULL(A_3122300000, 0) - ISNULL(B_3122300000, 0)
		,V_3122200000 = ISNULL(A_3122200000, 0) - ISNULL(B_3122200000, 0)
		,V_3122100000 = ISNULL(A_3122100000, 0) - ISNULL(B_3122100000, 0)
		,V_3210000000 = ISNULL(A_3210000000, 0) - ISNULL(B_3210000000, 0)
		,V_3220000000 = ISNULL(A_3220000000, 0) - ISNULL(B_3220000000, 0)
		,V_3230000000 = ISNULL(A_3230000000, 0) - ISNULL(B_3230000000, 0)
		,V_3240000000 = ISNULL(A_3240000000, 0) - ISNULL(B_3240000000, 0)
		,V_3250000000 = ISNULL(A_3250000000, 0) - ISNULL(B_3250000000, 0)
		,V_Exc01 = ISNULL(A_Exc01, 0) - ISNULL(B_Exc01, 0)
		,V_Exc02 = ISNULL(A_Exc02, 0) - ISNULL(B_Exc02, 0)
	INTO #Variacion
	FROM #SaldosFinalesAnioActual AS A, #SaldosFinalesAnioAnterior AS B
	
	SELECT CASE WHEN  (ISNULL(B_1110000000, 0)
					  +ISNULL(B_1120000000, 0)
					  +ISNULL(B_1130000000, 0)
					  +ISNULL(B_1140000000, 0)
					  +ISNULL(B_1150000000, 0)
					  +ISNULL(B_1160000000, 0)
					  +ISNULL(B_1170000000, 0)) = 0 THEN '0.00'
													ELSE  
														(SELECT (ISNULL(V_1110000000, 0)+ISNULL(V_1120000000, 0)+ISNULL(V_1130000000, 0)+ISNULL(V_1140000000, 0)+ISNULL(V_1150000000, 0)+ISNULL(V_1160000000, 0)+ISNULL(V_1170000000, 0)) * 100 
														FROM #Variacion) / (ISNULL(B_1110000000, 0)+ISNULL(B_1120000000, 0)+ISNULL(B_1130000000, 0)+ISNULL(B_1140000000, 0)+ISNULL(B_1150000000, 0)+ISNULL(B_1160000000, 0)+ISNULL(B_1170000000, 0))
													END AS SubTotal_V_ActivoCirculante 
		--****************************************************************************************************
		,CASE WHEN  (ISNULL(B_1210000000, 0)
		            +ISNULL(B_1220000000, 0)
		            +ISNULL(B_1230000000, 0)
		            +ISNULL(B_1240000000, 0)
		            +ISNULL(B_1250000000, 0)
		            -ISNULL(B_1260000000, 0)
		            +ISNULL(B_1270000000, 0)
		            +ISNULL(B_1280000000, 0)
		            +ISNULL(B_1290000000, 0)) < 0 THEN '0.00'
												  ELSE (SELECT (ISNULL(V_1210000000, 0)
											      		       +ISNULL(V_1220000000, 0)
											      		       +ISNULL(V_1230000000, 0)
											      		       +ISNULL(V_1240000000, 0)
											      		       +ISNULL(V_1250000000, 0)
											      		       -ISNULL(V_1260000000, 0)
											      		       +ISNULL(V_1270000000, 0)
											      		       +ISNULL(V_1280000000, 0)
											      		       +ISNULL(V_1290000000, 0)) * 100 FROM #Variacion) / (ISNULL(B_1210000000, 0)
											      													             +ISNULL(B_1220000000, 0)
											      													             +ISNULL(B_1230000000, 0)
											      													             +ISNULL(B_1240000000, 0)
											      													             +ISNULL(B_1250000000, 0)
											      													             -ISNULL(B_1260000000, 0)
											      													             +ISNULL(B_1270000000, 0)
											      													             +ISNULL(B_1280000000, 0)
											      													             +ISNULL(B_1290000000, 0)) 
											     END AS SubTotal_V_ActivoNoCirculante

		,CASE WHEN (ISNULL(B_1110000000, 0)
                   +ISNULL(B_1120000000, 0)
                   +ISNULL(B_1130000000, 0)
                   +ISNULL(B_1140000000, 0)
                   +ISNULL(B_1150000000, 0)
                   +ISNULL(B_1160000000, 0)
                   +ISNULL(B_1170000000, 0)
                   +ISNULL(B_1210000000, 0)
                   +ISNULL(B_1220000000, 0)
                   +ISNULL(B_1230000000, 0)
                   +ISNULL(B_1240000000, 0)
                   +ISNULL(B_1250000000, 0)
                   -ISNULL(B_1260000000, 0)
                   +ISNULL(B_1270000000, 0)
                   +ISNULL(B_1280000000, 0)
                   +ISNULL(B_1290000000, 0)) = 0 THEN '0.00'
												 ELSE (SELECT (ISNULL(V_1110000000, 0)
                                                              +ISNULL(V_1120000000, 0)
                                                              +ISNULL(V_1130000000, 0)
                                                              +ISNULL(V_1140000000, 0)
                                                              +ISNULL(V_1150000000, 0)
                                                              +ISNULL(V_1160000000, 0)
                                                              +ISNULL(V_1170000000, 0)
                                                              +ISNULL(V_1210000000, 0)
                                                              +ISNULL(V_1220000000, 0)
                                                              +ISNULL(V_1230000000, 0)
                                                              +ISNULL(V_1240000000, 0)
                                                              +ISNULL(V_1250000000, 0)
                                                              -ISNULL(V_1260000000, 0)
                                                              +ISNULL(V_1270000000, 0)
                                                              +ISNULL(V_1280000000, 0)
                                                              +ISNULL(V_1290000000, 0)) * 100 
												       FROM #Variacion) / (ISNULL(B_1110000000, 0)
                                                                          +ISNULL(B_1120000000, 0)
                                                                          +ISNULL(B_1130000000, 0)
                                                                          +ISNULL(B_1140000000, 0)
                                                                          +ISNULL(B_1150000000, 0)
                                                                          +ISNULL(B_1160000000, 0)
                                                                          +ISNULL(B_1170000000, 0)
                                                                          +ISNULL(B_1210000000, 0)
                                                                          +ISNULL(B_1220000000, 0)
                                                                          +ISNULL(B_1230000000, 0)
                                                                          +ISNULL(B_1240000000, 0)
                                                                          +ISNULL(B_1250000000, 0)
                                                                          -ISNULL(B_1260000000, 0)
                                                                          +ISNULL(B_1270000000, 0)
                                                                          +ISNULL(B_1280000000, 0)
                                                                          +ISNULL(B_1290000000, 0))
														END AS TOTAL_P_ACTIVO 
		--*********************************************************************************
		,CASE WHEN (ISNULL(B_2110000000, 0)
		           +ISNULL(B_2120000000, 0)
		           +ISNULL(B_2130000000, 0)
		           +ISNULL(B_2140000000, 0)
		           +ISNULL(B_2150000000, 0)
		           +ISNULL(B_2160000000, 0)
		           +ISNULL(B_2170000000, 0)
		           +ISNULL(B_2180000000, 0)) = 0 THEN '0.00'
												 ELSE (SELECT (ISNULL(V_2110000000, 0)
												              +ISNULL(V_2120000000, 0)
												              +ISNULL(V_2130000000, 0)
												              +ISNULL(V_2140000000, 0)
												              +ISNULL(V_2150000000, 0)
												              +ISNULL(V_2160000000, 0)
												              +ISNULL(V_2170000000, 0)
												              +ISNULL(V_2180000000, 0)) * 100 FROM #Variacion) / (ISNULL(B_2110000000, 0)
												              									                 +ISNULL(B_2120000000, 0)
												              									                 +ISNULL(B_2130000000, 0)
												              									                 +ISNULL(B_2140000000, 0)
												              									                 +ISNULL(B_2150000000, 0)
												              									                 +ISNULL(B_2160000000, 0)
												              									                 +ISNULL(B_2170000000, 0)
												              									                 +ISNULL(B_2180000000, 0))
												END AS SubTotal_V_Pasivo
		--*****************************************************************************************
	   ,CASE WHEN ( ISNULL(B_2210000000, 0 )
	   			  + ISNULL(B_2220000000, 0 )
	   			  + ISNULL(B_2220000000, 0 )
	   			  + ISNULL(B_2230000000, 0 )
	   			  + ISNULL(B_2240000000, 0 )
	   			  + ISNULL(B_2250000000, 0 )
	   			  + ISNULL(B_2260000000, 0 )) = 0.00 THEN '0.00'
												  ELSE (SELECT (ISNULL(V_2210000000, 0) 
                                                		      + ISNULL(V_2220000000, 0) 
                                                		      + ISNULL(V_2220000000, 0) 
                                                		      + ISNULL(V_2230000000, 0) 
                                                		      + ISNULL(V_2240000000, 0) 
                                                		      + ISNULL(V_2250000000, 0) 
                                                		      + ISNULL(V_2260000000, 0)) * 100 FROM #Variacion) / (ISNULL(B_2210000000, 0 )
                                                		                                                         + ISNULL(B_2220000000, 0 )
                                                		                                                         + ISNULL(B_2220000000, 0 )
                                                		                                                         + ISNULL(B_2230000000, 0 )
                                                		                                                         + ISNULL(B_2240000000, 0 )
                                                		                                                         + ISNULL(B_2250000000, 0 )
                                                		                                                         + ISNULL(B_2260000000, 0 ))
                                                  END AS SubTotal_V_Pasivo_No_C
		,CASE WHEN (ISNULL(B_2110000000, 0)
                   +ISNULL(B_2120000000, 0)
                   +ISNULL(B_2130000000, 0)
                   +ISNULL(B_2140000000, 0)
                   +ISNULL(B_2150000000, 0)
                   +ISNULL(B_2160000000, 0)
                   +ISNULL(B_2170000000, 0)
                   +ISNULL(B_2180000000, 0)
                   +ISNULL(B_2210000000, 0)
                   +ISNULL(B_2220000000, 0)
                   +ISNULL(B_2220000000, 0)
                   +ISNULL(B_2230000000, 0)
                   +ISNULL(B_2240000000, 0)
                   +ISNULL(B_2250000000, 0)
                   +ISNULL(B_2260000000, 0)) = 0 THEN '0.00'
				                                 ELSE (SELECT (ISNULL(V_2110000000, 0)
															  +ISNULL(V_2120000000, 0)
															  +ISNULL(V_2130000000, 0)
															  +ISNULL(V_2140000000, 0)
															  +ISNULL(V_2150000000, 0)
															  +ISNULL(V_2160000000, 0)
															  +ISNULL(V_2170000000, 0)
															  +ISNULL(V_2180000000, 0)
															  +ISNULL(V_2210000000, 0)
															  +ISNULL(V_2220000000, 0)
															  +ISNULL(V_2220000000, 0)
															  +ISNULL(V_2230000000, 0)
															  +ISNULL(V_2240000000, 0)
															  +ISNULL(V_2250000000, 0)
															  +ISNULL(V_2260000000, 0)) * 100
												       FROM #Variacion) / ( ISNULL(B_2110000000, 0)
																			+ISNULL(B_2120000000, 0)
																			+ISNULL(B_2130000000, 0)
																			+ISNULL(B_2140000000, 0)
																			+ISNULL(B_2150000000, 0)
																			+ISNULL(B_2160000000, 0)
																			+ISNULL(B_2170000000, 0)
																			+ISNULL(B_2180000000, 0)
																			+ISNULL(B_2210000000, 0)
																			+ISNULL(B_2220000000, 0)
																			+ISNULL(B_2220000000, 0)
																			+ISNULL(B_2230000000, 0)
																			+ISNULL(B_2240000000, 0)
																			+ISNULL(B_2250000000, 0)
																			+ISNULL(B_2260000000, 0))
												END AS TOTAL_P_PASIVO 
		,CASE WHEN ( ISNULL(B_3122300000, 0)
				    +ISNULL(B_3122200000, 0)
				    +ISNULL(B_3122100000, 0)) = 0 THEN '0.00'
					                              ELSE (SELECT (ISNULL(V_3122300000, 0)
															   +ISNULL(V_3122200000, 0)
															   +ISNULL(V_3122100000, 0)) * 100
												        FROM #Variacion) / ( ISNULL(B_3122300000, 0)
				                                                            +ISNULL(B_3122200000, 0)
				                                                            +ISNULL(B_3122100000, 0))
												END AS SubTotal_V_PatrimonioContribuido
		,CASE WHEN ( ISNULL(B_3210000000, 0)
				    +ISNULL(B_3220000000, 0)
				    +ISNULL(B_3230000000, 0)
				    +ISNULL(B_3240000000, 0)
				    +ISNULL(B_3250000000, 0)) = 0 THEN '0.00'
					                           ELSE (SELECT(ISNULL(V_3210000000, 0)
											               +ISNULL(V_3220000000, 0)
											               +ISNULL(V_3230000000, 0)
											               +ISNULL(V_3240000000, 0)
											               +ISNULL(V_3250000000, 0)) * 100
											   FROM #Variacion) / ( ISNULL(B_3210000000, 0)
				                                                   +ISNULL(B_3220000000, 0)
				                                                   +ISNULL(B_3230000000, 0)
				                                                   +ISNULL(B_3240000000, 0)
				                                                   +ISNULL(B_3250000000, 0))
											END AS SubTotal_V_PatrimonioGenerado
		,CASE WHEN ( ISNULL(B_3122300000, 0)
                    +ISNULL(B_3122200000, 0)
                    +ISNULL(B_3122100000, 0)
                    +ISNULL(B_3210000000, 0)
                    +ISNULL(B_3220000000, 0)
                    +ISNULL(B_3230000000, 0)
                    +ISNULL(B_3240000000, 0)
                    +ISNULL(B_3250000000, 0)) = 0 THEN '0.00'
					                              ELSE (SELECT(ISNULL(V_3122300000, 0)
														      +ISNULL(V_3122200000, 0)
														      +ISNULL(V_3122100000, 0)
														      +ISNULL(V_3210000000, 0)
														      +ISNULL(V_3220000000, 0)
														      +ISNULL(V_3230000000, 0)
														      +ISNULL(V_3240000000, 0)
														      +ISNULL(V_3250000000, 0)) * 100 
												  FROM #Variacion) / ( ISNULL(B_3122300000, 0)
																	  +ISNULL(B_3122200000, 0)
																	  +ISNULL(B_3122100000, 0)
																	  +ISNULL(B_3210000000, 0)
																	  +ISNULL(B_3220000000, 0)
																	  +ISNULL(B_3230000000, 0)
																	  +ISNULL(B_3240000000, 0)
																	  +ISNULL(B_3250000000, 0))
												END AS TOTAL_P_HACIENDA
		,(SELECT (ISNULL(V_2110000000, 0)
                 +ISNULL(V_2120000000, 0)
                 +ISNULL(V_2130000000, 0)
                 +ISNULL(V_2140000000, 0)
                 +ISNULL(V_2150000000, 0)
                 +ISNULL(V_2160000000, 0)
                 +ISNULL(V_2170000000, 0)
                 +ISNULL(V_2180000000, 0)
                 +ISNULL(V_2210000000, 0)
                 +ISNULL(V_2220000000, 0)
                 +ISNULL(V_2220000000, 0)
                 +ISNULL(V_2230000000, 0)
                 +ISNULL(V_2240000000, 0)
                 +ISNULL(V_2250000000, 0)
                 +ISNULL(V_2260000000, 0)
                 +ISNULL(V_3122300000, 0)
                 +ISNULL(V_3122200000, 0)
                 +ISNULL(V_3122100000, 0)
                 +ISNULL(V_3210000000, 0)
                 +ISNULL(V_3220000000, 0)
                 +ISNULL(V_3230000000, 0)
                 +ISNULL(V_3240000000, 0)
                 +ISNULL(V_3250000000, 0)) * 100 FROM #Variacion) / (ISNULL(B_2110000000, 0)
                                                                    +ISNULL(B_2120000000, 0)
                                                                    +ISNULL(B_2130000000, 0)
                                                                    +ISNULL(B_2140000000, 0)
                                                                    +ISNULL(B_2150000000, 0)
                                                                    +ISNULL(B_2160000000, 0)
                                                                    +ISNULL(B_2170000000, 0)
                                                                    +ISNULL(B_2180000000, 0)
                                                                    +ISNULL(B_2210000000, 0)
                                                                    +ISNULL(B_2220000000, 0)
                                                                    +ISNULL(B_2220000000, 0)
                                                                    +ISNULL(B_2230000000, 0)
                                                                    +ISNULL(B_2240000000, 0)
                                                                    +ISNULL(B_2250000000, 0)
                                                                    +ISNULL(B_2260000000, 0)
                                                                    +ISNULL(B_3122300000, 0)
                                                                    +ISNULL(B_3122200000, 0)
                                                                    +ISNULL(B_3122100000, 0)
                                                                    +ISNULL(B_3210000000, 0)
                                                                    +ISNULL(B_3220000000, 0)
                                                                    +ISNULL(B_3230000000, 0)
                                                                    +ISNULL(B_3240000000, 0)
                                                                    +ISNULL(B_3250000000, 0)) AS TOTAL_PORCENTAJE
	INTO #TMP_Porcentaje
	FROM #SaldosFinalesAnioAnterior

	SELECT
		 p_1110000000 = CASE WHEN B_1110000000 = 0 THEN 0.00 ELSE (V_1110000000 * 100) / B_1110000000 END
		,p_1120000000 = CASE WHEN B_1120000000 = 0 THEN 0.00 ELSE (V_1120000000 * 100) / B_1120000000 END
		,p_1130000000 = CASE WHEN B_1130000000 = 0 THEN 0.00 ELSE (V_1130000000 * 100) / B_1130000000 END
		,p_1140000000 = CASE WHEN B_1140000000 = 0 THEN 0.00 ELSE (V_1140000000 * 100) / B_1140000000 END
		,p_1150000000 = CASE WHEN B_1150000000 = 0 THEN 0.00 ELSE (V_1150000000 * 100) / B_1150000000 END
		,p_1160000000 = CASE WHEN B_1160000000 = 0 THEN 0.00 ELSE (V_1160000000 * 100) / B_1160000000 END
		,p_1170000000 = CASE WHEN B_1170000000 = 0 THEN 0.00 ELSE (V_1170000000 * 100) / B_1170000000 END
		,p_2110000000 = CASE WHEN B_2110000000 = 0 THEN 0.00 ELSE (V_2110000000 * 100) / B_2110000000 END
		,p_2120000000 = CASE WHEN B_2120000000 = 0 THEN 0.00 ELSE (V_2120000000 * 100) / B_2120000000 END
		,p_2130000000 = CASE WHEN B_2130000000 = 0 THEN 0.00 ELSE (V_2130000000 * 100) / B_2130000000 END
		,p_2140000000 = CASE WHEN B_2140000000 = 0 THEN 0.00 ELSE (V_2140000000 * 100) / B_2140000000 END
		,p_2150000000 = CASE WHEN B_2150000000 = 0 THEN 0.00 ELSE (V_2150000000 * 100) / B_2150000000 END
		,p_2160000000 = CASE WHEN B_2160000000 = 0 THEN 0.00 ELSE (V_2160000000 * 100) / B_2160000000 END
		,p_2170000000 = CASE WHEN B_2170000000 = 0 THEN 0.00 ELSE (V_2170000000 * 100) / B_2170000000 END
		,p_2180000000 = CASE WHEN B_2180000000 = 0 THEN 0.00 ELSE (V_2180000000 * 100) / B_2180000000 END
		,p_1210000000 = CASE WHEN B_1210000000 = 0 THEN 0.00 ELSE (V_1210000000 * 100) / B_1210000000 END
		,p_1220000000 = CASE WHEN B_1220000000 = 0 THEN 0.00 ELSE (V_1220000000 * 100) / B_1220000000 END
		,p_1230000000 = CASE WHEN B_1230000000 = 0 THEN 0.00 ELSE (V_1230000000 * 100) / B_1230000000 END
		,p_1240000000 = CASE WHEN B_1240000000 = 0 THEN 0.00 ELSE (V_1240000000 * 100) / B_1240000000 END
		,p_1250000000 = CASE WHEN B_1250000000 = 0 THEN 0.00 ELSE (V_1250000000 * 100) / B_1250000000 END
		,p_1260000000 = CASE WHEN B_1260000000 = 0 THEN 0.00 ELSE (V_1260000000 * 100) / B_1260000000 END
		,p_1270000000 = CASE WHEN B_1270000000 = 0 THEN 0.00 ELSE (V_1270000000 * 100) / B_1270000000 END
		,p_1280000000 = CASE WHEN B_1280000000 = 0 THEN 0.00 ELSE (V_1280000000 * 100) / B_1280000000 END
		,p_1290000000 = CASE WHEN B_1290000000 = 0 THEN 0.00 ELSE (V_1290000000 * 100) / B_1290000000 END
		,p_2210000000 = CASE WHEN B_2210000000 = 0 THEN 0.00 ELSE (V_2210000000 * 100) / B_2210000000 END
		,p_2220000000 = CASE WHEN B_2220000000 = 0 THEN 0.00 ELSE (V_2220000000 * 100) / B_2220000000 END
		,p_2230000000 = CASE WHEN B_2230000000 = 0 THEN 0.00 ELSE (V_2230000000 * 100) / B_2230000000 END
		,p_2240000000 = CASE WHEN B_2240000000 = 0 THEN 0.00 ELSE (V_2240000000 * 100) / B_2240000000 END
		,p_2250000000 = CASE WHEN B_2250000000 = 0 THEN 0.00 ELSE (V_2250000000 * 100) / B_2250000000 END
		,p_2260000000 = CASE WHEN B_2260000000 = 0 THEN 0.00 ELSE (V_2260000000 * 100) / B_2260000000 END
		,p_3122300000 = CASE WHEN B_3122300000 = 0 THEN 0.00 ELSE (V_3122300000 * 100) / B_3122300000 END
		,p_3122200000 = CASE WHEN B_3122200000 = 0 THEN 0.00 ELSE (V_3122200000 * 100) / B_3122200000 END
		,p_3122100000 = CASE WHEN B_3122100000 = 0 THEN 0.00 ELSE (V_3122100000 * 100) / B_3122100000 END
		,p_3210000000 = CASE WHEN B_3210000000 = 0 THEN 0.00 ELSE (V_3210000000 * 100) / B_3210000000 END
		,p_3220000000 = CASE WHEN B_3220000000 = 0 THEN 0.00 ELSE (V_3220000000 * 100) / B_3220000000 END
		,p_3230000000 = CASE WHEN B_3230000000 = 0 THEN 0.00 ELSE (V_3230000000 * 100) / B_3230000000 END
		,p_3240000000 = CASE WHEN B_3240000000 = 0 THEN 0.00 ELSE (V_3240000000 * 100) / B_3240000000 END
		,p_3250000000 = CASE WHEN B_3250000000 = 0 THEN 0.00 ELSE (V_3250000000 * 100) / B_3250000000 END
		,p_Exc01 = 0
		,p_Exc02 = 0
	INTO #Porcentaje
	FROM #Variacion, #SaldosFinalesAnioAnterior

	--===============================================================================
	SELECT 
		 CASE WHEN A_1110000000 < 0 THEN '('+ FORMAT(ROUND(A_1110000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(A_1110000000, 0), 'N','EN-US') END AS A_1110000000
		,CASE WHEN A_1120000000 < 0 THEN '('+ FORMAT(ROUND(A_1120000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(A_1120000000, 0), 'N','EN-US') END AS A_1120000000
		,CASE WHEN A_1130000000 < 0 THEN '('+ FORMAT(ROUND(A_1130000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(A_1130000000, 0), 'N','EN-US') END AS A_1130000000
		,CASE WHEN A_1140000000 < 0 THEN '('+ FORMAT(ROUND(A_1140000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(A_1140000000, 0), 'N','EN-US') END AS A_1140000000
		,CASE WHEN A_1150000000 < 0 THEN '('+ FORMAT(ROUND(A_1150000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(A_1150000000, 0), 'N','EN-US') END AS A_1150000000
		,CASE WHEN A_1160000000 < 0 THEN '('+ FORMAT(ROUND(A_1160000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(A_1160000000, 0), 'N','EN-US') END AS A_1160000000
		,CASE WHEN A_1170000000 < 0 THEN '('+ FORMAT(ROUND(A_1170000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(A_1170000000, 0), 'N','EN-US') END AS A_1170000000
		,FORMAT(ROUND(ISNULL(A_1110000000, 0)
		             +ISNULL(A_1120000000, 0)
		             +ISNULL(A_1130000000, 0)
		             +ISNULL(A_1140000000, 0)
		             +ISNULL(A_1150000000, 0)
		             +ISNULL(A_1160000000, 0)
		             +ISNULL(A_1170000000, 0), 0),'N','EN-US') AS SubTotalActivosCirculantes
		,CASE WHEN A_2110000000 < 0 THEN '('+ FORMAT(ROUND(A_2110000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(A_2110000000, 0), 'N','EN-US') END AS A_2110000000
		,CASE WHEN A_2120000000 < 0 THEN '('+ FORMAT(ROUND(A_2120000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(A_2120000000, 0), 'N','EN-US') END AS A_2120000000
		,CASE WHEN A_2130000000 < 0 THEN '('+ FORMAT(ROUND(A_2130000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(A_2130000000, 0), 'N','EN-US') END AS A_2130000000
		,CASE WHEN A_2140000000 < 0 THEN '('+ FORMAT(ROUND(A_2140000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(A_2140000000, 0), 'N','EN-US') END AS A_2140000000
		,CASE WHEN A_2150000000 < 0 THEN '('+ FORMAT(ROUND(A_2150000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(A_2150000000, 0), 'N','EN-US') END AS A_2150000000
		,CASE WHEN A_2160000000 < 0 THEN '('+ FORMAT(ROUND(A_2160000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(A_2160000000, 0), 'N','EN-US') END AS A_2160000000
		,CASE WHEN A_2170000000 < 0 THEN '('+ FORMAT(ROUND(A_2170000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(A_2170000000, 0), 'N','EN-US') END AS A_2170000000
		,CASE WHEN A_2180000000 < 0 THEN '('+ FORMAT(ROUND(A_2180000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(A_2180000000, 0), 'N','EN-US') END AS A_2180000000
		,FORMAT(ROUND(ISNULL(A_2110000000, 0)
		             +ISNULL(A_2120000000, 0)
		             +ISNULL(A_2130000000, 0)
		             +ISNULL(A_2140000000, 0)
		             +ISNULL(A_2150000000, 0)
		             +ISNULL(A_2160000000, 0)
		             +ISNULL(A_2170000000, 0)
		             +ISNULL(A_2180000000, 0), 0),'N','EN-US') AS SubTotalPasivoCirculantes
		,CASE WHEN A_1210000000 < 0 THEN '('+ FORMAT(ROUND(A_1210000000 * -1, 0), 'N','EN-US')+ ')' ELSE FORMAT(ROUND(A_1210000000, 0), 'N','EN-US') END AS A_1210000000
		,CASE WHEN A_1220000000 < 0 THEN '('+ FORMAT(ROUND(A_1220000000 * -1, 0), 'N','EN-US')+ ')' ELSE FORMAT(ROUND(A_1220000000, 0), 'N','EN-US') END AS A_1220000000
		,CASE WHEN A_1230000000 < 0 THEN '('+ FORMAT(ROUND(A_1230000000 * -1, 0), 'N','EN-US')+ ')' ELSE FORMAT(ROUND(A_1230000000, 0), 'N','EN-US') END AS A_1230000000
		,CASE WHEN A_1240000000 < 0 THEN '('+ FORMAT(ROUND(A_1240000000 * -1, 0), 'N','EN-US')+ ')' ELSE FORMAT(ROUND(A_1240000000, 0), 'N','EN-US') END AS A_1240000000
		,CASE WHEN A_1250000000 < 0 THEN '('+ FORMAT(ROUND(A_1250000000 * -1, 0), 'N','EN-US')+ ')' ELSE FORMAT(ROUND(A_1250000000, 0), 'N','EN-US') END AS A_1250000000
		--,CASE WHEN A_1260000000 < 0 THEN '('+ FORMAT(ROUND(A_1260000000 * -1, -2), 'N','EN-US')+ ')' ELSE FORMAT(ROUND(A_1260000000, -2), 'N','EN-US') END AS A_1260000000
		,'('+ FORMAT(ROUND(A_1260000000, 0), 'N','EN-US')+ ')' AS A_1260000000
		,CASE WHEN A_1270000000 < 0 THEN '('+ FORMAT(ROUND(A_1270000000 * -1, 0), 'N','EN-US')+ ')' ELSE FORMAT(ROUND(A_1270000000, 0), 'N','EN-US') END AS A_1270000000
		,CASE WHEN A_1280000000 < 0 THEN '('+ FORMAT(ROUND(A_1280000000 * -1, 0), 'N','EN-US')+ ')' ELSE FORMAT(ROUND(A_1280000000, 0), 'N','EN-US') END AS A_1280000000
		,CASE WHEN A_1290000000 < 0 THEN '('+ FORMAT(ROUND(A_1290000000 * -1, 0), 'N','EN-US')+ ')' ELSE FORMAT(ROUND(A_1290000000, 0), 'N','EN-US') END AS A_1290000000
		,FORMAT(ROUND( ISNULL(A_1210000000, 0)
		              +ISNULL(A_1220000000, 0)
		              +ISNULL(A_1230000000, 0)
		              +ISNULL(A_1240000000, 0)
		              +ISNULL(A_1250000000, 0)
		              -ISNULL(A_1260000000, 0)
		              +ISNULL(A_1270000000, 0)
		              +ISNULL(A_1280000000, 0)
		              +ISNULL(A_1290000000, 0), 0),'N','EN-US') AS SubTotalActivosNoCirculantes
		,CASE WHEN A_2210000000 < 0 THEN '('+ FORMAT(ROUND(A_2210000000 * -1, -2), 'N','EN-US')+')' ELSE FORMAT(ROUND(A_2210000000, -2), 'N','EN-US') END AS A_2210000000
		,CASE WHEN A_2220000000 < 0 THEN '('+ FORMAT(ROUND(A_2220000000 * -1, -2), 'N','EN-US')+')' ELSE FORMAT(ROUND(A_2220000000, -2), 'N','EN-US') END AS A_2220000000
		,CASE WHEN A_2230000000 < 0 THEN '('+ FORMAT(ROUND(A_2230000000 * -1, -2), 'N','EN-US')+')' ELSE FORMAT(ROUND(A_2230000000, -2), 'N','EN-US') END AS A_2230000000
		,CASE WHEN A_2240000000 < 0 THEN '('+ FORMAT(ROUND(A_2240000000 * -1, -2), 'N','EN-US')+')' ELSE FORMAT(ROUND(A_2240000000, -2), 'N','EN-US') END AS A_2240000000
		,CASE WHEN A_2250000000 < 0 THEN '('+ FORMAT(ROUND(A_2250000000 * -1, -2), 'N','EN-US')+')' ELSE FORMAT(ROUND(A_2250000000, -2), 'N','EN-US') END AS A_2250000000
		,CASE WHEN A_2260000000 < 0 THEN '('+ FORMAT(ROUND(A_2260000000 * -1, -2), 'N','EN-US')+')' ELSE FORMAT(ROUND(A_2260000000, -2), 'N','EN-US') END AS A_2260000000
		,FORMAT(ROUND(ISNULL(A_2210000000, 0)
		             +ISNULL(A_2220000000, 0)
		             +ISNULL(A_2230000000, 0)
		             +ISNULL(A_2240000000, 0)
		             +ISNULL(A_2250000000, 0)
		             +ISNULL(A_2260000000, 0), 0),'N','EN-US') AS SubTotalPasivoNoCirculantes
		,CASE WHEN A_3122300000 < 0 THEN '(' +FORMAT(ROUND(A_3122300000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(A_3122300000, -2), 'N','EN-US') END AS A_3122300000
		,CASE WHEN A_3122200000 < 0 THEN '(' +FORMAT(ROUND(A_3122200000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(A_3122200000, -2), 'N','EN-US') END AS A_3122200000
		,CASE WHEN A_3122100000 < 0 THEN '(' +FORMAT(ROUND(A_3122100000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(A_3122100000, -2), 'N','EN-US') END AS A_3122100000
		,FORMAT(ROUND(ISNULL(A_3122300000, 0)
		             +ISNULL(A_3122200000, 0)
		             +ISNULL(A_3122100000, 0), 0),'N','EN-US') AS SubTotalPatrimonioContribuido
		,CASE WHEN A_3210000000 < 0 THEN '('+FORMAT(ROUND(A_3210000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(A_3210000000, -2), 'N','EN-US') END AS A_3210000000
		,CASE WHEN A_3220000000 < 0 THEN '('+FORMAT(ROUND(A_3220000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(A_3220000000, -2), 'N','EN-US') END AS A_3220000000
		,CASE WHEN A_3230000000 < 0 THEN '('+FORMAT(ROUND(A_3230000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(A_3230000000, -2), 'N','EN-US') END AS A_3230000000
		,CASE WHEN A_3240000000 < 0 THEN '('+FORMAT(ROUND(A_3240000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(A_3240000000, -2), 'N','EN-US') END AS A_3240000000
		,CASE WHEN A_3250000000 < 0 THEN '('+FORMAT(ROUND(A_3250000000 * -1, -2), 'N','EN-US') +')' ELSE FORMAT(ROUND(A_3250000000, -2), 'N','EN-US') END AS A_3250000000
		,CASE WHEN (ISNULL(A_3210000000, 0) 
		          + ISNULL(A_3220000000, 0) 
				  + ISNULL(A_3230000000, 0) 
				  + ISNULL(A_3240000000, 0) 
				  + ISNULL(A_3250000000, 0)) < 0 THEN '('+ FORMAT(ROUND( (ISNULL(A_3210000000, 0)
																									                      +ISNULL(A_3220000000, 0)
																									                      +ISNULL(A_3230000000, 0)
																									                      +ISNULL(A_3240000000, 0)
																									                      +ISNULL(A_3250000000, 0)) * -1, -2),'N','EN-US') + ')'
																								ELSE FORMAT(ROUND( ISNULL(A_3210000000, 0)
																									              +ISNULL(A_3220000000, 0)
																									              +ISNULL(A_3230000000, 0)
																									              +ISNULL(A_3240000000, 0)
																									              +ISNULL(A_3250000000, 0), -2),'N','EN-US')
																								END AS SubTotalPatrimonioGenerado
		,FORMAT(ROUND(A_Exc01, - 2),'N','EN-US') AS A_Exc01
		,FORMAT(ROUND(A_Exc02, - 2),'N','EN-US') AS A_Exc02
--=====================================================================
	    ,CASE WHEN B_1110000000 < 0 THEN '('+ FORMAT(ROUND(B_1110000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_1110000000, -2), 'N','EN-US') END AS B_1110000000
		,CASE WHEN B_1120000000 < 0 THEN '('+ FORMAT(ROUND(B_1120000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_1120000000, -2), 'N','EN-US') END AS B_1120000000
		,CASE WHEN B_1130000000 < 0 THEN '('+ FORMAT(ROUND(B_1130000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_1130000000, -2), 'N','EN-US') END AS B_1130000000
		,CASE WHEN B_1140000000 < 0 THEN '('+ FORMAT(ROUND(B_1140000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_1140000000, -2), 'N','EN-US') END AS B_1140000000
		,CASE WHEN B_1150000000 < 0 THEN '('+ FORMAT(ROUND(B_1150000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_1150000000, -2), 'N','EN-US') END AS B_1150000000
		,CASE WHEN B_1160000000 < 0 THEN '('+ FORMAT(ROUND(B_1160000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_1160000000, -2), 'N','EN-US') END AS B_1160000000
		,CASE WHEN B_1170000000 < 0 THEN '('+ FORMAT(ROUND(B_1170000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_1170000000, -2), 'N','EN-US') END AS B_1170000000
		,FORMAT(ROUND(ISNULL(B_1110000000, 0)
		             +ISNULL(B_1120000000, 0)
		             +ISNULL(B_1130000000, 0)
		             +ISNULL(B_1140000000, 0)
		             +ISNULL(B_1150000000, 0)
		             +ISNULL(B_1160000000, 0)
		             +ISNULL(B_1170000000, 0), -2),'N','EN-US') AS SubTotalActivoCirculanteAnterior
		,CASE WHEN B_2110000000 < 0 THEN '('+ FORMAT(ROUND(B_2110000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_2110000000, -2), 'N','EN-US') END AS B_2110000000
		,CASE WHEN B_2120000000 < 0 THEN '('+ FORMAT(ROUND(B_2120000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_2120000000, -2), 'N','EN-US') END AS B_2120000000
		,CASE WHEN B_2130000000 < 0 THEN '('+ FORMAT(ROUND(B_2130000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_2130000000, -2), 'N','EN-US') END AS B_2130000000
		,CASE WHEN B_2140000000 < 0 THEN '('+ FORMAT(ROUND(B_2140000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_2140000000, -2), 'N','EN-US') END AS B_2140000000
		,CASE WHEN B_2150000000 < 0 THEN '('+ FORMAT(ROUND(B_2150000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_2150000000, -2), 'N','EN-US') END AS B_2150000000
		,CASE WHEN B_2160000000 < 0 THEN '('+ FORMAT(ROUND(B_2160000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_2160000000, -2), 'N','EN-US') END AS B_2160000000
		,CASE WHEN B_2170000000 < 0 THEN '('+ FORMAT(ROUND(B_2170000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_2170000000, -2), 'N','EN-US') END AS B_2170000000
		,CASE WHEN B_2180000000 < 0 THEN '('+ FORMAT(ROUND(B_2180000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_2180000000, -2), 'N','EN-US') END AS B_2180000000
		,format(round(isnull(B_2110000000, 0)
		             +isnull(B_2120000000, 0)
		             +isnull(B_2130000000, 0)
		             +isnull(B_2140000000, 0)
		             +isnull(B_2150000000, 0)
		             +isnull(B_2160000000, 0)
		             +isnull(B_2170000000, 0)
		             +isnull(B_2180000000, 0), -2),'N','EN-US') AS SubTotalPasivoCirculanteAnterior
		,CASE WHEN B_1210000000 < 0 THEN '('+ FORMAT(ROUND(B_1210000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_1210000000, -2), 'N','EN-US') END AS B_1210000000
		,CASE WHEN B_1220000000 < 0 THEN '('+ FORMAT(ROUND(B_1220000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_1220000000, -2), 'N','EN-US') END AS B_1220000000
		,CASE WHEN B_1230000000 < 0 THEN '('+ FORMAT(ROUND(B_1230000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_1230000000, -2), 'N','EN-US') END AS B_1230000000
		,CASE WHEN B_1240000000 < 0 THEN '('+ FORMAT(ROUND(B_1240000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_1240000000, -2), 'N','EN-US') END AS B_1240000000
		,CASE WHEN B_1250000000 < 0 THEN '('+ FORMAT(ROUND(B_1250000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_1250000000, -2), 'N','EN-US') END AS B_1250000000
		--,CASE WHEN B_1260000000 < 0 THEN '('+ FORMAT(ROUND(B_1260000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_1260000000, -2), 'N','EN-US') END AS B_1260000000
		,'('+ FORMAT(ROUND(B_1260000000, 0), 'N','EN-US') + ')' AS B_1260000000
		,CASE WHEN B_1270000000 < 0 THEN '('+ FORMAT(ROUND(B_1270000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_1270000000, -2), 'N','EN-US') END AS B_1270000000
		,CASE WHEN B_1280000000 < 0 THEN '('+ FORMAT(ROUND(B_1280000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_1280000000, -2), 'N','EN-US') END AS B_1280000000
		,CASE WHEN B_1290000000 < 0 THEN '('+ FORMAT(ROUND(B_1290000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_1290000000, -2), 'N','EN-US') END AS B_1290000000
		,FORMAT(ROUND(ISNULL(B_1210000000, 0)
		             +ISNULL(B_1220000000, 0)
		             +ISNULL(B_1230000000, 0)
		             +ISNULL(B_1240000000, 0)
		             +ISNULL(B_1250000000, 0)
		             -ISNULL(B_1260000000, 0)
		             +ISNULL(B_1270000000, 0)
		             +ISNULL(B_1280000000, 0)
		             +ISNULL(B_1290000000, 0), 0),'N','EN-US') AS SubTotalActivoNoCirculanteAnterior
		,CASE WHEN B_2210000000 < 0 THEN '('+ FORMAT(ROUND(B_2210000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_2210000000, -2), 'N','EN-US') END AS B_2210000000
		,CASE WHEN B_2220000000 < 0 THEN '('+ FORMAT(ROUND(B_2220000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_2220000000, -2), 'N','EN-US') END AS B_2220000000
		,CASE WHEN B_2230000000 < 0 THEN '('+ FORMAT(ROUND(B_2230000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_2230000000, -2), 'N','EN-US') END AS B_2230000000
		,CASE WHEN B_2240000000 < 0 THEN '('+ FORMAT(ROUND(B_2240000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_2240000000, -2), 'N','EN-US') END AS B_2240000000
		,CASE WHEN B_2250000000 < 0 THEN '('+ FORMAT(ROUND(B_2250000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_2250000000, -2), 'N','EN-US') END AS B_2250000000
		,CASE WHEN B_2260000000 < 0 THEN '('+ FORMAT(ROUND(B_2260000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_2260000000, -2), 'N','EN-US') END AS B_2260000000
		,FORMAT(ROUND(ISNULL(B_2210000000, 0)
		             +ISNULL(B_2220000000, 0)
		             +ISNULL(B_2230000000, 0)
		             +ISNULL(B_2240000000, 0)
		             +ISNULL(B_2250000000, 0)
		             +ISNULL(B_2260000000, 0), 0),'N','EN-US') AS SubTotalPasivoNoCirculanteAnterior 
		,CASE WHEN B_3122300000 < 0 THEN '(' + FORMAT(ROUND(B_3122300000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_3122300000, -2), 'N','EN-US') END AS B_3122300000
		,CASE WHEN B_3122200000 < 0 THEN '(' + FORMAT(ROUND(B_3122200000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_3122200000, -2), 'N','EN-US') END AS B_3122200000
		,CASE WHEN B_3122100000 < 0 THEN '(' + FORMAT(ROUND(B_3122100000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_3122100000, -2), 'N','EN-US') END AS B_3122100000
		,FORMAT(ROUND( ISNULL(B_3122300000, 0)
		              +ISNULL(B_3122200000, 0)
		              +ISNULL(B_3122100000, 0), 0),'N','EN-US') AS SubTotalPatrimoniContribuidoAnterior 
		,CASE WHEN B_3210000000 < 0 THEN '(' + FORMAT(ROUND(B_3210000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_3210000000, -2), 'N','EN-US') END AS B_3210000000
		,CASE WHEN B_3220000000 < 0 THEN '(' + FORMAT(ROUND(B_3220000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_3220000000, -2), 'N','EN-US') END AS B_3220000000
		,CASE WHEN B_3230000000 < 0 THEN '(' + FORMAT(ROUND(B_3230000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_3230000000, -2), 'N','EN-US') END AS B_3230000000
		,CASE WHEN B_3240000000 < 0 THEN '(' + FORMAT(ROUND(B_3240000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_3240000000, -2), 'N','EN-US') END AS B_3240000000
		,CASE WHEN B_3250000000 < 0 THEN '(' + FORMAT(ROUND(B_3250000000 * -1, -2), 'N','EN-US') + ')' ELSE FORMAT(ROUND(B_3250000000, -2), 'N','EN-US') END AS B_3250000000
		,CASE WHEN ( ISNULL(B_3210000000, 0)             
		            +ISNULL(B_3220000000, 0)             
		            +ISNULL(B_3230000000, 0)             
		            +ISNULL(B_3240000000, 0)             
		            +ISNULL(B_3250000000, 0)) < 0 THEN '(' + FORMAT(ROUND( (ISNULL(B_3210000000, 0) 
													                       +ISNULL(B_3220000000, 0)
													                       +ISNULL(B_3230000000, 0)
													                       +ISNULL(B_3240000000, 0)
													                       +ISNULL(B_3250000000, 0)) * -1, 0),'N','EN-US') + ')' 
												  ELSE FORMAT(ROUND( ISNULL(B_3210000000, 0)
												  	   +ISNULL(B_3220000000, 0)
												  	   +ISNULL(B_3230000000, 0)
												  	   +ISNULL(B_3240000000, 0)
												  	   +ISNULL(B_3250000000, 0), 0),'N','EN-US')-- AS SubTotalPatrimonioGeneradoAnterior
												  END AS SubTotalPatrimonioGeneradoAnterior
					
					
					  
		,FORMAT(ROUND(B_Exc01, - 2),'N','EN-US') AS B_Exc01
		,FORMAT(ROUND(B_Exc02, - 2),'N','EN-US') AS B_Exc02
        ,CASE WHEN V_1110000000 < 0 THEN '('+ FORMAT(ROUND(V_1110000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_1110000000, 0), 'N','EN-US') END AS V_1110000000
		,CASE WHEN V_1120000000 < 0 THEN '('+ FORMAT(ROUND(V_1120000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_1120000000, 0), 'N','EN-US') END AS V_1120000000
		,CASE WHEN V_1130000000 < 0 THEN '('+ FORMAT(ROUND(V_1130000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_1130000000, 0), 'N','EN-US') END AS V_1130000000
		,CASE WHEN V_1140000000 < 0 THEN '('+ FORMAT(ROUND(V_1140000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_1140000000, 0), 'N','EN-US') END AS V_1140000000
		,CASE WHEN V_1150000000 < 0 THEN '('+ FORMAT(ROUND(V_1150000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_1150000000, 0), 'N','EN-US') END AS V_1150000000
		,CASE WHEN V_1160000000 < 0 THEN '('+ FORMAT(ROUND(V_1160000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_1160000000, 0), 'N','EN-US') END AS V_1160000000
		,CASE WHEN V_1170000000 < 0 THEN '('+ FORMAT(ROUND(V_1170000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_1170000000, 0), 'N','EN-US') END AS V_1170000000
		,CASE WHEN ( ISNULL(V_1110000000, 0)
				     +ISNULL(V_1120000000, 0)
				     +ISNULL(V_1130000000, 0)
				     +ISNULL(V_1140000000, 0)
				     +ISNULL(V_1150000000, 0)
				     +ISNULL(V_1160000000, 0)
				     +ISNULL(V_1170000000, 0)) < 0 THEN '(' + FORMAT(ROUND( (ISNULL(V_1110000000, 0)
					                                                       +ISNULL(V_1120000000, 0)
					                                                       +ISNULL(V_1130000000, 0)
					                                                       +ISNULL(V_1140000000, 0)
					                                                       +ISNULL(V_1150000000, 0)
					                                                       +ISNULL(V_1160000000, 0)
					                                                       +ISNULL(V_1170000000, 0)) * -1 , 0),'N','EN-US') + ')'
												    ELSE FORMAT(ROUND( ISNULL(V_1110000000, 0)
														              +ISNULL(V_1120000000, 0)
														              +ISNULL(V_1130000000, 0)
														              +ISNULL(V_1140000000, 0)
														              +ISNULL(V_1150000000, 0)
														              +ISNULL(V_1160000000, 0)
														              +ISNULL(V_1170000000, 0), 0),'N','EN-US')
													END AS SubTotal_V_Activo
		,CASE WHEN V_2110000000 < 0 THEN '(' + FORMAT(ROUND(V_2110000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_2110000000, 0), 'N','EN-US') END AS V_2110000000
		,CASE WHEN V_2120000000 < 0 THEN '(' + FORMAT(ROUND(V_2120000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_2120000000, 0), 'N','EN-US') END AS V_2120000000
		,CASE WHEN V_2130000000 < 0 THEN '(' + FORMAT(ROUND(V_2130000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_2130000000, 0), 'N','EN-US') END AS V_2130000000
		,CASE WHEN V_2140000000 < 0 THEN '(' + FORMAT(ROUND(V_2140000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_2140000000, 0), 'N','EN-US') END AS V_2140000000
		,CASE WHEN V_2150000000 < 0 THEN '(' + FORMAT(ROUND(V_2150000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_2150000000, 0), 'N','EN-US') END AS V_2150000000
		,CASE WHEN V_2160000000 < 0 THEN '(' + FORMAT(ROUND(V_2160000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_2160000000, 0), 'N','EN-US') END AS V_2160000000
		,CASE WHEN V_2170000000 < 0 THEN '(' + FORMAT(ROUND(V_2170000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_2170000000, 0), 'N','EN-US') END AS V_2170000000
		,CASE WHEN V_2180000000 < 0 THEN '(' + FORMAT(ROUND(V_2180000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_2180000000, 0), 'N','EN-US') END AS V_2180000000
		,CASE WHEN (ISNULL(V_2110000000, 0)       
				   +ISNULL(V_2120000000, 0)      
				   +ISNULL(V_2130000000, 0)      
				   +ISNULL(V_2140000000, 0)      
				   +ISNULL(V_2150000000, 0)      
				   +ISNULL(V_2160000000, 0)      
				   +ISNULL(V_2170000000, 0)      
				   +ISNULL(V_2180000000, 0)) < 0  THEN '(' + FORMAT(ROUND((ISNULL(V_2110000000, 0)
													                     +ISNULL(V_2120000000, 0)
													                     +ISNULL(V_2130000000, 0)
													                     +ISNULL(V_2140000000, 0)
													                     +ISNULL(V_2150000000, 0)
													                     +ISNULL(V_2160000000, 0)
													                     +ISNULL(V_2170000000, 0)
													                     +ISNULL(V_2180000000, 0)) * -1	, 0),'N','EN-US') + ')'
												  ELSE FORMAT(ROUND(ISNULL(V_2110000000, 0)
													   +ISNULL(V_2120000000, 0)
													   +ISNULL(V_2130000000, 0)
													   +ISNULL(V_2140000000, 0)
													   +ISNULL(V_2150000000, 0)
													   +ISNULL(V_2160000000, 0)
													   +ISNULL(V_2170000000, 0)
													   +ISNULL(V_2180000000, 0), 0),'N','EN-US') 
												  END AS SubTotal_V_Pasivo
		,CASE WHEN V_1210000000 < 0 THEN '('+ FORMAT(ROUND(V_1210000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_1210000000, 0), 'N','EN-US') END AS V_1210000000
		,CASE WHEN V_1220000000 < 0 THEN '('+ FORMAT(ROUND(V_1220000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_1220000000, 0), 'N','EN-US') END AS V_1220000000
		,CASE WHEN V_1230000000 < 0 THEN '('+ FORMAT(ROUND(V_1230000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_1230000000, 0), 'N','EN-US') END AS V_1230000000
		,CASE WHEN V_1240000000 < 0 THEN '('+ FORMAT(ROUND(V_1240000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_1240000000, 0), 'N','EN-US') END AS V_1240000000
		,CASE WHEN V_1250000000 < 0 THEN '('+ FORMAT(ROUND(V_1250000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_1250000000, 0), 'N','EN-US') END AS V_1250000000
		,CASE WHEN V_1260000000 < 0 THEN '('+ FORMAT(ROUND(V_1260000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_1260000000, 0), 'N','EN-US') END AS V_1260000000
		,CASE WHEN V_1270000000 < 0 THEN '('+ FORMAT(ROUND(V_1270000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_1270000000, 0), 'N','EN-US') END AS V_1270000000
		,CASE WHEN V_1280000000 < 0 THEN '('+ FORMAT(ROUND(V_1280000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_1280000000, 0), 'N','EN-US') END AS V_1280000000
		,CASE WHEN V_1290000000 < 0 THEN '('+ FORMAT(ROUND(V_1290000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_1290000000, 0), 'N','EN-US') END AS V_1290000000
		,CASE WHEN ( ISNULL(V_1210000000, 0)
				    +ISNULL(V_1220000000, 0)
				    +ISNULL(V_1230000000, 0)
				    +ISNULL(V_1240000000, 0)
				    +ISNULL(V_1250000000, 0)
				    -ISNULL(V_1260000000, 0)
				    +ISNULL(V_1270000000, 0)
				    +ISNULL(V_1280000000, 0)
				    +ISNULL(V_1290000000, 0)) < 0 THEN '(' + FORMAT(ROUND((ISNULL(V_1210000000, 0)
					                                                      +ISNULL(V_1220000000, 0)
					                                                      +ISNULL(V_1230000000, 0)
					                                                      +ISNULL(V_1240000000, 0)
					                                                      +ISNULL(V_1250000000, 0)
					                                                      -ISNULL(V_1260000000, 0)
					                                                      +ISNULL(V_1270000000, 0)
					                                                      +ISNULL(V_1280000000, 0)
					                                                      +ISNULL(V_1290000000, 0)) * -1, 0),'N','EN-US') + ')'
		                                           ELSE  FORMAT(ROUND( ISNULL(V_1210000000, 0)
		                                                  			  +ISNULL(V_1220000000, 0)
		                                                  			  +ISNULL(V_1230000000, 0)
		                                                  			  +ISNULL(V_1240000000, 0)
		                                                  			  +ISNULL(V_1250000000, 0)
		                                                  			  -ISNULL(V_1260000000, 0)
		                                                  			  +ISNULL(V_1270000000, 0)
		                                                  			  +ISNULL(V_1280000000, 0)
		                                                  			  +ISNULL(V_1290000000, 0), 0),'N','EN-US') 
												   END AS SubTotal_V_Activo_No_C
		,CASE WHEN V_2210000000 < 0 THEN '(' +FORMAT(ROUND(V_2210000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_2210000000, 0), 'N','EN-US') END AS V_2210000000
		,CASE WHEN V_2220000000 < 0 THEN '(' +FORMAT(ROUND(V_2220000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_2220000000, 0), 'N','EN-US') END AS V_2220000000
		,CASE WHEN V_2230000000 < 0 THEN '(' +FORMAT(ROUND(V_2230000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_2230000000, 0), 'N','EN-US') END AS V_2230000000
		,CASE WHEN V_2240000000 < 0 THEN '(' +FORMAT(ROUND(V_2240000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_2240000000, 0), 'N','EN-US') END AS V_2240000000
		,CASE WHEN V_2250000000 < 0 THEN '(' +FORMAT(ROUND(V_2250000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_2250000000, 0), 'N','EN-US') END AS V_2250000000
		,CASE WHEN V_2260000000 < 0 THEN '(' +FORMAT(ROUND(V_2260000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_2260000000, 0), 'N','EN-US') END AS V_2260000000
		,FORMAT(ROUND( ISNULL(V_2210000000, 0)
					  +ISNULL(V_2220000000, 0)
					  +ISNULL(V_2230000000, 0)
					  +ISNULL(V_2240000000, 0)
					  +ISNULL(V_2250000000, 0)
					  +ISNULL(V_2260000000, 0), -2),'N','EN-US') AS SubTotal_V_Pasivo_No_C
		,CASE WHEN V_3122300000 < 0 THEN '(' + FORMAT(ROUND(V_3122300000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_3122300000, 0), 'N','EN-US') END AS V_3122300000
		,CASE WHEN V_3122200000 < 0 THEN '(' + FORMAT(ROUND(V_3122200000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_3122200000, 0), 'N','EN-US') END AS V_3122200000
		,CASE WHEN V_3122100000 < 0 THEN '(' + FORMAT(ROUND(V_3122100000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_3122100000, 0), 'N','EN-US') END AS V_3122100000
		,CASE WHEN ( ISNULL(V_3122300000, 0)            
		            +ISNULL(V_3122200000, 0)            
		            +ISNULL(V_3122100000, 0)) < 0 THEN '(' + FORMAT(ROUND((ISNULL(V_3122300000, 0)
													                      +ISNULL(V_3122200000, 0)
													                      +ISNULL(V_3122100000, 0)) * -1, 0),'N','EN-US') + ')'
												  ELSE FORMAT(ROUND( ISNULL(V_3122300000, 0)
													                +ISNULL(V_3122200000, 0)
													                +ISNULL(V_3122100000, 0), 0),'N','EN-US') 
												  END AS SubTotal_V_PatrimonioContribuido
		,CASE WHEN V_3210000000 < 0 THEN '(' + FORMAT(ROUND(V_3210000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_3210000000, 0), 'N','EN-US') END AS V_3210000000
		,CASE WHEN V_3220000000 < 0 THEN '(' + FORMAT(ROUND(V_3220000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_3220000000, 0), 'N','EN-US') END AS V_3220000000
		,CASE WHEN V_3230000000 < 0 THEN '(' + FORMAT(ROUND(V_3230000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_3230000000, 0), 'N','EN-US') END AS V_3230000000
		,CASE WHEN V_3240000000 < 0 THEN '(' + FORMAT(ROUND(V_3240000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_3240000000, 0), 'N','EN-US') END AS V_3240000000
		,CASE WHEN V_3250000000 < 0 THEN '(' + FORMAT(ROUND(V_3250000000 * -1, 0), 'N','EN-US') + ')' ELSE FORMAT(ROUND(V_3250000000, 0), 'N','EN-US') END AS V_3250000000
		,CASE WHEN (ISNULL(V_3210000000, 0)
				   +ISNULL(V_3220000000, 0)
				   +ISNULL(V_3230000000, 0)
				   +ISNULL(V_3240000000, 0)
				   +ISNULL(V_3250000000, 0)) < 0 THEN '('+FORMAT(ROUND((ISNULL(V_3210000000, 0)
													                  +ISNULL(V_3220000000, 0)
													                  +ISNULL(V_3230000000, 0)
													                  +ISNULL(V_3240000000, 0)
													                  +ISNULL(V_3250000000, 0)) * -1, 0),'N','EN-US') + ')'
												ELSE FORMAT(ROUND(ISNULL(V_3210000000, 0)
		                                                         +ISNULL(V_3220000000, 0)
		                                                         +ISNULL(V_3230000000, 0)
		                                                         +ISNULL(V_3240000000, 0)
		                                                         +ISNULL(V_3250000000, 0), 0),'N','EN-US') 
												END AS SubTotal_V_PatrimonioGenerado
		,CASE WHEN (ISNULL(V_2110000000, 0)
                   +ISNULL(V_2120000000, 0)
                   +ISNULL(V_2130000000, 0)
                   +ISNULL(V_2140000000, 0)
                   +ISNULL(V_2150000000, 0)
                   +ISNULL(V_2160000000, 0)
                   +ISNULL(V_2170000000, 0)
                   +ISNULL(V_2180000000, 0)
                   +ISNULL(V_2210000000, 0)
                   +ISNULL(V_2220000000, 0)
                   +ISNULL(V_2230000000, 0)
                   +ISNULL(V_2240000000, 0)
                   +ISNULL(V_2250000000, 0)
                   +ISNULL(V_2260000000, 0)
                   +ISNULL(V_3122300000, 0)
                   +ISNULL(V_3122200000, 0)
                   +ISNULL(V_3122100000, 0)
                   +ISNULL(V_3210000000, 0)
                   +ISNULL(V_3220000000, 0)
                   +ISNULL(V_3230000000, 0)
                   +ISNULL(V_3240000000, 0)
                   +ISNULL(V_3250000000, 0)) < 0 THEN '(' +FORMAT(ROUND((ISNULL(V_2110000000, 0)
													                    +ISNULL(V_2120000000, 0)
													                    +ISNULL(V_2130000000, 0)
													                    +ISNULL(V_2140000000, 0)
													                    +ISNULL(V_2150000000, 0)
													                    +ISNULL(V_2160000000, 0)
													                    +ISNULL(V_2170000000, 0)
													                    +ISNULL(V_2180000000, 0)
													                    +ISNULL(V_2210000000, 0)
													                    +ISNULL(V_2220000000, 0)
													                    +ISNULL(V_2230000000, 0)
													                    +ISNULL(V_2240000000, 0)
													                    +ISNULL(V_2250000000, 0)
													                    +ISNULL(V_2260000000, 0)
													                    +ISNULL(V_3122300000, 0)
													                    +ISNULL(V_3122200000, 0)
													                    +ISNULL(V_3122100000, 0)
													                    +ISNULL(V_3210000000, 0)
													                    +ISNULL(V_3220000000, 0)
													                    +ISNULL(V_3230000000, 0)
													                    +ISNULL(V_3240000000, 0)
													                    +ISNULL(V_3250000000, 0)) * -1, 0),'N','EN-US') 
													ELSE FORMAT(ROUND(ISNULL(V_2110000000, 0)
														             +ISNULL(V_2120000000, 0)
														             +ISNULL(V_2130000000, 0)
														             +ISNULL(V_2140000000, 0)
														             +ISNULL(V_2150000000, 0)
														             +ISNULL(V_2160000000, 0)
														             +ISNULL(V_2170000000, 0)
														             +ISNULL(V_2180000000, 0)
														             +ISNULL(V_2210000000, 0)
														             +ISNULL(V_2220000000, 0)
														             +ISNULL(V_2230000000, 0)
														             +ISNULL(V_2240000000, 0)
														             +ISNULL(V_2250000000, 0)
														             +ISNULL(V_2260000000, 0)
														             +ISNULL(V_3122300000, 0)
														             +ISNULL(V_3122200000, 0)
														             +ISNULL(V_3122100000, 0)
														             +ISNULL(V_3210000000, 0)
														             +ISNULL(V_3220000000, 0)
														             +ISNULL(V_3230000000, 0)
														             +ISNULL(V_3240000000, 0)
														             +ISNULL(V_3250000000, 0), 0),'N','EN-US')
													END AS TOTAL_VARIACION
		,FORMAT(ROUND(V_Exc01, 0),'N','EN-US') AS V_Exc01
		,FORMAT(ROUND(V_Exc02, 0),'N','EN-US') AS V_Exc02
		,CASE WHEN P_1110000000 < 0 THEN '('+ FORMAT(P_1110000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_1110000000, 'N','EN-US') END AS P_1110000000
        ,CASE WHEN P_1120000000 < 0 THEN '('+ FORMAT(P_1120000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_1120000000, 'N','EN-US') END AS P_1120000000
		,CASE WHEN P_1130000000 < 0 THEN '('+ FORMAT(P_1130000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_1130000000, 'N','EN-US') END AS P_1130000000
		,CASE WHEN P_1140000000 < 0 THEN '('+ FORMAT(P_1140000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_1140000000, 'N','EN-US') END AS P_1140000000
		,CASE WHEN P_1150000000 < 0 THEN '('+ FORMAT(P_1150000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_1150000000, 'N','EN-US') END AS P_1150000000
		,CASE WHEN P_1160000000 < 0 THEN '('+ FORMAT(P_1160000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_1160000000, 'N','EN-US') END AS P_1160000000
		,CASE WHEN P_1170000000 < 0 THEN '('+ FORMAT(P_1170000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_1170000000, 'N','EN-US') END AS P_1170000000
		,CASE WHEN P_2110000000 < 0 THEN '('+ FORMAT(P_2110000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_2110000000, 'N','EN-US') END AS P_2110000000
		,CASE WHEN P_2120000000 < 0 THEN '('+ FORMAT(P_2120000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_2120000000, 'N','EN-US') END AS P_2120000000
		,CASE WHEN P_2130000000 < 0 THEN '('+ FORMAT(P_2130000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_2130000000, 'N','EN-US') END AS P_2130000000
		,CASE WHEN P_2140000000 < 0 THEN '('+ FORMAT(P_2140000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_2140000000, 'N','EN-US') END AS P_2140000000
		,CASE WHEN P_2150000000 < 0 THEN '('+ FORMAT(P_2150000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_2150000000, 'N','EN-US') END AS P_2150000000
		,CASE WHEN P_2160000000 < 0 THEN '('+ FORMAT(P_2160000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_2160000000, 'N','EN-US') END AS P_2160000000
		,CASE WHEN P_2170000000 < 0 THEN '('+ FORMAT(P_2170000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_2170000000, 'N','EN-US') END AS P_2170000000
		,CASE WHEN P_2180000000 < 0 THEN '('+ FORMAT(P_2180000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_2180000000, 'N','EN-US') END AS P_2180000000
		,CASE WHEN P_1210000000 < 0 THEN '('+ FORMAT(P_1210000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_1210000000, 'N','EN-US') END AS P_1210000000
		,CASE WHEN P_1220000000 < 0 THEN '('+ FORMAT(P_1220000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_1220000000, 'N','EN-US') END AS P_1220000000
		,CASE WHEN P_1230000000 < 0 THEN '('+ FORMAT(P_1230000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_1230000000, 'N','EN-US') END AS P_1230000000
		,CASE WHEN P_1240000000 < 0 THEN '('+ FORMAT(P_1240000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_1240000000, 'N','EN-US') END AS P_1240000000
		,CASE WHEN P_1250000000 < 0 THEN '('+ FORMAT(P_1250000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_1250000000, 'N','EN-US') END AS P_1250000000
		,CASE WHEN P_1260000000 < 0 THEN '('+ FORMAT(P_1260000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_1260000000, 'N','EN-US') END AS P_1260000000
		,CASE WHEN P_1270000000 < 0 THEN '('+ FORMAT(P_1270000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_1270000000, 'N','EN-US') END AS P_1270000000
		,CASE WHEN P_1280000000 < 0 THEN '('+ FORMAT(P_1280000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_1280000000, 'N','EN-US') END AS P_1280000000
		,CASE WHEN P_1290000000 < 0 THEN '('+ FORMAT(P_1290000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_1290000000, 'N','EN-US') END AS P_1290000000
		,CASE WHEN P_2210000000 < 0 THEN '('+ FORMAT(P_2210000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_2210000000, 'N','EN-US') END AS P_2210000000
		,CASE WHEN P_2220000000 < 0 THEN '('+ FORMAT(P_2220000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_2220000000, 'N','EN-US') END AS P_2220000000
		,CASE WHEN P_2230000000 < 0 THEN '('+ FORMAT(P_2230000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_2230000000, 'N','EN-US') END AS P_2230000000
		,CASE WHEN P_2240000000 < 0 THEN '('+ FORMAT(P_2240000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_2240000000, 'N','EN-US') END AS P_2240000000
		,CASE WHEN P_2250000000 < 0 THEN '('+ FORMAT(P_2250000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_2250000000, 'N','EN-US') END AS P_2250000000
		,CASE WHEN P_2260000000 < 0 THEN '('+ FORMAT(P_2260000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_2260000000, 'N','EN-US') END AS P_2260000000
		,CASE WHEN P_3122300000 < 0 THEN '('+ FORMAT(P_3122300000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_3122300000, 'N','EN-US') END AS P_3122300000
		,CASE WHEN P_3122200000 < 0 THEN '('+ FORMAT(P_3122200000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_3122200000, 'N','EN-US') END AS P_3122200000
		,CASE WHEN P_3122100000 < 0 THEN '('+ FORMAT(P_3122100000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_3122100000, 'N','EN-US') END AS P_3122100000
		,CASE WHEN P_3210000000 < 0 THEN '('+ FORMAT(P_3210000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_3210000000, 'N','EN-US') END AS P_3210000000
		,CASE WHEN P_3220000000 < 0 THEN '('+ FORMAT(P_3220000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_3220000000, 'N','EN-US') END AS P_3220000000
		,CASE WHEN P_3230000000 < 0 THEN '('+ FORMAT(P_3230000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_3230000000, 'N','EN-US') END AS P_3230000000
		,CASE WHEN P_3240000000 < 0 THEN '('+ FORMAT(P_3240000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_3240000000, 'N','EN-US') END AS P_3240000000
		,CASE WHEN P_3250000000 < 0 THEN '('+ FORMAT(P_3250000000 * -1, 'N','EN-US') +')' ELSE FORMAT(P_3250000000, 'N','EN-US') END AS P_3250000000
		,FORMAT(P_Exc01,'N','EN-US') AS P_Exc01
		,FORMAT(P_Exc02,'N','EN-US') AS P_Exc02
		,FORMAT(ROUND(ISNULL(A_1110000000, 0)
                     +ISNULL(A_1120000000, 0)
                     +ISNULL(A_1130000000, 0)
                     +ISNULL(A_1140000000, 0)
                     +ISNULL(A_1150000000, 0)
                     +ISNULL(A_1160000000, 0)
                     +ISNULL(A_1170000000, 0)
                     +ISNULL(A_1210000000, 0)
                     +ISNULL(A_1220000000, 0)
                     +ISNULL(A_1230000000, 0)
                     +ISNULL(A_1240000000, 0)
                     +ISNULL(A_1250000000, 0)
                     -ISNULL(A_1260000000, 0)
                     +ISNULL(A_1270000000, 0)
                     +ISNULL(A_1280000000, 0)
                     +ISNULL(A_1290000000, 0), 0),'N','EN-US') AS TOTAL_ACTIVO
		,FORMAT(ROUND(ISNULL(B_1110000000, 0)
                     +ISNULL(B_1120000000, 0)
                     +ISNULL(B_1130000000, 0)
                     +ISNULL(B_1140000000, 0)
                     +ISNULL(B_1150000000, 0)
                     +ISNULL(B_1160000000, 0)
                     +ISNULL(B_1170000000, 0)
                     +ISNULL(B_1210000000, 0)
                     +ISNULL(B_1220000000, 0)
                     +ISNULL(B_1230000000, 0)
                     +ISNULL(B_1240000000, 0)
                     +ISNULL(B_1250000000, 0)
                     -ISNULL(B_1260000000, 0)
                     +ISNULL(B_1270000000, 0)
                     +ISNULL(B_1280000000, 0)
                     +ISNULL(B_1290000000, 0), 0),'N','EN-US') AS TOTAL_ACTIVO_ANTERIOR
		,FORMAT(ROUND(ISNULL(A_2110000000, 0)
		             +ISNULL(A_2120000000, 0)
		             +ISNULL(A_2130000000, 0)
		             +ISNULL(A_2140000000, 0)
		             +ISNULL(A_2150000000, 0)
		             +ISNULL(A_2160000000, 0)
		             +ISNULL(A_2170000000, 0)
		             +ISNULL(A_2180000000, 0)
					 +ISNULL(A_2210000000, 0)
					 +ISNULL(A_2220000000, 0)
					 +ISNULL(A_2230000000, 0)
					 +ISNULL(A_2240000000, 0)
					 +ISNULL(A_2250000000, 0)
					 +ISNULL(A_2260000000, 0), 0),'N','EN-US') AS TOTAL_PASIVO_CIRCULANTE
		,FORMAT(ROUND(ISNULL(B_2110000000, 0)
		             +ISNULL(B_2120000000, 0)
		             +ISNULL(B_2130000000, 0)
		             +ISNULL(B_2140000000, 0)
		             +ISNULL(B_2150000000, 0)
		             +ISNULL(B_2160000000, 0)
		             +ISNULL(B_2170000000, 0)
		             +ISNULL(B_2180000000, 0)
					 +ISNULL(B_2210000000, 0)
					 +ISNULL(B_2220000000, 0)
					 +ISNULL(B_2230000000, 0)
					 +ISNULL(B_2240000000, 0)
					 +ISNULL(B_2250000000, 0)
					 +ISNULL(B_2260000000, 0), 0),'N','EN-US') AS TOTAL_PASIVO_CIRCULANTE_ANTERIOR
		,FORMAT(ROUND(ISNULL(A_3122300000, 0)
                     +ISNULL(A_3122200000, 0)
                     +ISNULL(A_3122100000, 0)
                     +ISNULL(A_3210000000, 0)
                     +ISNULL(A_3220000000, 0)
                     +ISNULL(A_3230000000, 0)
                     +ISNULL(A_3240000000, 0)
                     +ISNULL(A_3250000000, 0), 0),'N','EN-US') AS TOTAL_HACIENDA
		,FORMAT(ROUND(ISNULL(B_3122300000, 0)
                     +ISNULL(B_3122200000, 0)
                     +ISNULL(B_3122100000, 0)
                     +ISNULL(B_3210000000, 0)
                     +ISNULL(B_3220000000, 0)
                     +ISNULL(B_3230000000, 0)
                     +ISNULL(B_3240000000, 0)
                     +ISNULL(B_3250000000, 0), 0),'N','EN-US') AS TOTAL_HACIENDA_HACIENDA
		,CASE WHEN (ISNULL(V_1110000000, 0)
					+ISNULL(V_1120000000, 0)
					+ISNULL(V_1130000000, 0)
					+ISNULL(V_1140000000, 0)
					+ISNULL(V_1150000000, 0)
					+ISNULL(V_1160000000, 0)
					+ISNULL(V_1170000000, 0)
					+ISNULL(V_1210000000, 0)
					+ISNULL(V_1220000000, 0)
					+ISNULL(V_1230000000, 0)
					+ISNULL(V_1240000000, 0)
					+ISNULL(V_1250000000, 0)
					-ISNULL(V_1260000000, 0)
					+ISNULL(V_1270000000, 0)
					+ISNULL(V_1280000000, 0)
					+ISNULL(V_1290000000, 0)) < 0 THEN '(' + FORMAT(ROUND((ISNULL(V_1110000000, 0)
													   			          +ISNULL(V_1120000000, 0)
													   			          +ISNULL(V_1130000000, 0)
													   			          +ISNULL(V_1140000000, 0)
													   			          +ISNULL(V_1150000000, 0)
													   			          +ISNULL(V_1160000000, 0)
													   			          +ISNULL(V_1170000000, 0)
													   			          +ISNULL(V_1210000000, 0)
													   			          +ISNULL(V_1220000000, 0)
													   			          +ISNULL(V_1230000000, 0)
													   			          +ISNULL(V_1240000000, 0)
													   			          +ISNULL(V_1250000000, 0)
													   			          -ISNULL(V_1260000000, 0)
													   			          +ISNULL(V_1270000000, 0)
													   			          +ISNULL(V_1280000000, 0)
													   			          +ISNULL(V_1290000000, 0)) * -1, 0),'N','EN-US') + ')'
												ELSE FORMAT(ROUND(ISNULL(V_1110000000, 0)
													 			 +ISNULL(V_1120000000, 0)
													 			 +ISNULL(V_1130000000, 0)
													 			 +ISNULL(V_1140000000, 0)
													 			 +ISNULL(V_1150000000, 0)
													 			 +ISNULL(V_1160000000, 0)
													 			 +ISNULL(V_1170000000, 0)
													 			 +ISNULL(V_1210000000, 0)
													 			 +ISNULL(V_1220000000, 0)
													 			 +ISNULL(V_1230000000, 0)
													 			 +ISNULL(V_1240000000, 0)
													 			 +ISNULL(V_1250000000, 0)
													 			 -ISNULL(V_1260000000, 0)
					 								 			 +ISNULL(V_1270000000, 0)
					 								 			 +ISNULL(V_1280000000, 0)
					 								 			 +ISNULL(V_1290000000, 0), 0),'N','EN-US')
					                            END AS TOTAL_V_ACTIVO			  
		,CASE WHEN (ISNULL(V_2110000000, 0)
					+ISNULL(V_2120000000, 0)
					+ISNULL(V_2130000000, 0)
					+ISNULL(V_2140000000, 0)
					+ISNULL(V_2150000000, 0)
					+ISNULL(V_2160000000, 0)
					+ISNULL(V_2170000000, 0)
					+ISNULL(V_2180000000, 0)
					+ISNULL(V_2210000000, 0)
					+ISNULL(V_2220000000, 0)
					+ISNULL(V_2230000000, 0)
					+ISNULL(V_2240000000, 0)
					+ISNULL(V_2250000000, 0)
					+ISNULL(V_2260000000, 0)) < 0 THEN '(' + FORMAT(ROUND((ISNULL(V_2110000000, 0)
					                                                     +ISNULL(V_2120000000, 0)
					                                                     +ISNULL(V_2130000000, 0)
					                                                     +ISNULL(V_2140000000, 0)
					                                                     +ISNULL(V_2150000000, 0)
					                                                     +ISNULL(V_2160000000, 0)
					                                                     +ISNULL(V_2170000000, 0)
					                                                     +ISNULL(V_2180000000, 0)
					                                                     +ISNULL(V_2210000000, 0)
					                                                     +ISNULL(V_2220000000, 0)
					                                                     +ISNULL(V_2230000000, 0)
					                                                     +ISNULL(V_2240000000, 0)
					                                                     +ISNULL(V_2250000000, 0)
					                                                     +ISNULL(V_2260000000, 0))* - 1, 0),'N','EN-US') + ')'
												ELSE FORMAT(ROUND(ISNULL(V_2110000000, 0)
					                                             +ISNULL(V_2120000000, 0)
					                                             +ISNULL(V_2130000000, 0)
					                                             +ISNULL(V_2140000000, 0)
					                                             +ISNULL(V_2150000000, 0)
					                                             +ISNULL(V_2160000000, 0)
					                                             +ISNULL(V_2170000000, 0)
					                                             +ISNULL(V_2180000000, 0)
					                                             +ISNULL(V_2210000000, 0)
					                                             +ISNULL(V_2220000000, 0)
					                                             +ISNULL(V_2230000000, 0)
					                                             +ISNULL(V_2240000000, 0)
					                                             +ISNULL(V_2250000000, 0)
					                                             +ISNULL(V_2260000000, 0), 0),'N','EN-US')
												END AS TOTAL_V_PASIVO	
		,FORMAT(ROUND(ISNULL(V_3122300000, 0)
		             +ISNULL(V_3122200000, 0)
		             +ISNULL(V_3122100000, 0)
					 +ISNULL(V_3210000000, 0)
					 +ISNULL(V_3220000000, 0)
					 +ISNULL(V_3230000000, 0)
					 +ISNULL(V_3240000000, 0)
					 +ISNULL(V_3250000000, 0), 0),'N','EN-US') AS TOTAL_V_HACIENDA

--=========================================================================================
		,FORMAT(ROUND(
		              ISNULL(A_2110000000, 0)
		             +ISNULL(A_2120000000, 0)
		             +ISNULL(A_2130000000, 0)
		             +ISNULL(A_2140000000, 0)
		             +ISNULL(A_2150000000, 0)
		             +ISNULL(A_2160000000, 0)
		             +ISNULL(A_2170000000, 0)
		             +ISNULL(A_2180000000, 0)
		             +ISNULL(A_2210000000, 0)
		             +ISNULL(A_2220000000, 0)
		             +ISNULL(A_2230000000, 0)
		             +ISNULL(A_2240000000, 0)
		             +ISNULL(A_2250000000, 0)
		             +ISNULL(A_2260000000, 0)
		             +ISNULL(A_3122300000, 0)
		             +ISNULL(A_3122200000, 0)
		             +ISNULL(A_3122100000, 0)
		             +ISNULL(A_3210000000, 0)
		             +ISNULL(A_3220000000, 0)
		             +ISNULL(A_3230000000, 0)
		             +ISNULL(A_3240000000, 0)
		             +ISNULL(A_3250000000, 0), 0),'N','EN-US') AS TOTAL
		,FORMAT(ROUND(ISNULL(B_2110000000, 0)
		             +ISNULL(B_2120000000, 0)
		             +ISNULL(B_2130000000, 0)
		             +ISNULL(B_2140000000, 0)
		             +ISNULL(B_2150000000, 0)
		             +ISNULL(B_2160000000, 0)
		             +ISNULL(B_2170000000, 0)
		             +ISNULL(B_2180000000, 0)
		             +ISNULL(B_2210000000, 0)
		             +ISNULL(B_2220000000, 0)
		             +ISNULL(B_2230000000, 0)
		             +ISNULL(B_2240000000, 0)
		             +ISNULL(B_2250000000, 0)
		             +ISNULL(B_2260000000, 0)
		             +ISNULL(B_3122300000, 0)
		             +ISNULL(B_3122200000, 0)
		             +ISNULL(B_3122100000, 0)
		             +ISNULL(B_3210000000, 0)
		             +ISNULL(B_3220000000, 0)
		             +ISNULL(B_3230000000, 0)
		             +ISNULL(B_3240000000, 0)
		             +ISNULL(B_3250000000, 0), 0),'N','EN-US') AS TOTAL_ANTERIOR
	INTO #TMP
	FROM #SaldosFinalesAnioActual, #SaldosFinalesAnioAnterior, #Variacion, #Porcentaje
	
	SELECT 0.00 AS TOTAL_P_ACTIVO 
	INTO #TOTAL_PORCENTAJE
	FROM #TMP
	--============================================================
	SELECT 
		@FechaPeriodo AS Periodo
		,YEAR(@FechaFin) AS AnioActual
		,YEAR(@FechaFin) - 1 AS AnioAnterior
		,REPLACE(A_1110000000,'00.00','') AS A_1110000000
		,REPLACE(A_1120000000,'00.00','') AS A_1120000000
		,REPLACE(A_1130000000,'00.00','') AS A_1130000000
		,REPLACE(A_1140000000,'00.00','') AS A_1140000000
		,REPLACE(A_1150000000,'00.00','') AS A_1150000000
		,REPLACE(A_1160000000,'00.00','') AS A_1160000000
		,REPLACE(A_1170000000,'00.00','') AS A_1170000000
		,REPLACE(SubTotalActivosCirculantes,'00.00','') AS SubTotalActivosCirculantes
		,REPLACE(A_2110000000,'00.00','') AS A_2110000000
		,REPLACE(A_2120000000,'00.00','') AS A_2120000000
		,REPLACE(A_2130000000,'00.00','') AS A_2130000000
		,REPLACE(A_2140000000,'00.00','') AS A_2140000000
		,REPLACE(A_2150000000,'00.00','') AS A_2150000000
		,REPLACE(A_2160000000,'00.00','') AS A_2160000000
		,REPLACE(A_2170000000,'00.00','') AS A_2170000000
		,REPLACE(A_2180000000,'00.00','') AS A_2180000000
		,REPLACE(SubTotalPasivoCirculantes,'00.00','') AS SubTotalPasivoCirculantes 
		,REPLACE(A_1210000000,'00.00','') AS A_1210000000
		,REPLACE(A_1220000000,'00.00','') AS A_1220000000
		,REPLACE(A_1230000000,'00.00','') AS A_1230000000
		,REPLACE(A_1240000000,'00.00','') AS A_1240000000
		,REPLACE(A_1250000000,'00.00','') AS A_1250000000
		,REPLACE(A_1260000000,'00.00','') AS A_1260000000
		,REPLACE(A_1270000000,'00.00','') AS A_1270000000
		,REPLACE(A_1280000000,'00.00','') AS A_1280000000
		,REPLACE(A_1290000000,'00.00','') AS A_1290000000
		,REPLACE(SubTotalActivosNoCirculantes,'00.00','') AS SubTotalActivosNoCirculantes
		,REPLACE(A_2210000000,'00.00','') AS A_2210000000
		,REPLACE(A_2220000000,'00.00','') AS A_2220000000
		,REPLACE(A_2230000000,'00.00','') AS A_2230000000
		,REPLACE(A_2240000000,'00.00','') AS A_2240000000
		,REPLACE(A_2250000000,'00.00','') AS A_2250000000
		,REPLACE(A_2260000000,'00.00','') AS A_2260000000
		,REPLACE(SubTotalPasivoNoCirculantes,'00.00','') AS SubTotalPasivoNoCirculantes
		,REPLACE(A_3122300000,'00.00','') AS A_3122300000
		,REPLACE(A_3122200000,'00.00','') AS A_3122200000
		,REPLACE(A_3122100000,'00.00','') AS A_3122100000
		,REPLACE(SubTotalPatrimonioContribuido,'00.00','') AS SubTotalPatrimonioContribuido
		,REPLACE(A_3210000000,'00.00','') AS A_3210000000
		,REPLACE(A_3220000000,'00.00','') AS A_3220000000
		,REPLACE(A_3230000000,'00.00','') AS A_3230000000
		,REPLACE(A_3240000000,'00.00','') AS A_3240000000
		,REPLACE(A_3250000000,'00.00','') AS A_3250000000
		,REPLACE(SubTotalPatrimonioGenerado,'00.00','') AS SubTotalPatrimonioGenerado
		,REPLACE(A_Exc01,'00.00','') AS A_Exc01
		,REPLACE(A_Exc02,'00.00','') AS A_Exc02
	    ,REPLACE(B_1110000000,'00.00','') AS B_1110000000
		,REPLACE(B_1120000000,'00.00','') AS B_1120000000
		,REPLACE(B_1130000000,'00.00','') AS B_1130000000
		,REPLACE(B_1140000000,'00.00','') AS B_1140000000
		,REPLACE(B_1150000000,'00.00','') AS B_1150000000
		,REPLACE(B_1160000000,'00.00','') AS B_1160000000
		,REPLACE(B_1170000000,'00.00','') AS B_1170000000
		,REPLACE(SubTotalActivoCirculanteAnterior,'00.00','') AS SubTotalActivoCirculanteAnterior
		,REPLACE(B_2110000000,'00.00','') AS B_2110000000
		,REPLACE(B_2120000000,'00.00','') AS B_2120000000
		,REPLACE(B_2130000000,'00.00','') AS B_2130000000
		,REPLACE(B_2140000000,'00.00','') AS B_2140000000
		,REPLACE(B_2150000000,'00.00','') AS B_2150000000
		,REPLACE(B_2160000000,'00.00','') AS B_2160000000
		,REPLACE(B_2170000000,'00.00','') AS B_2170000000
		,REPLACE(B_2180000000,'00.00','') AS B_2180000000
		,REPLACE(SubTotalPasivoCirculanteAnterior,'00.00','') AS SubTotalPasivoCirculanteAnterior
		,REPLACE(B_1210000000,'00.00','') AS B_1210000000
		,REPLACE(B_1220000000,'00.00','') AS B_1220000000
		,REPLACE(B_1230000000,'00.00','') AS B_1230000000
		,REPLACE(B_1240000000,'00.00','') AS B_1240000000
		,REPLACE(B_1250000000,'00.00','') AS B_1250000000
		,REPLACE(B_1260000000,'00.00','') AS B_1260000000
		,REPLACE(B_1270000000,'00.00','') AS B_1270000000
		,REPLACE(B_1280000000,'00.00','') AS B_1280000000
		,REPLACE(B_1290000000,'00.00','') AS B_1290000000
		,replace(SubTotalActivoNoCirculanteAnterior,'00.00','') AS SubTotalActivoNoCirculanteAnterior
		,REPLACE(B_2210000000,'00.00','') AS B_2210000000
		,REPLACE(B_2220000000,'00.00','') AS B_2220000000
		,REPLACE(B_2230000000,'00.00','') AS B_2230000000
		,REPLACE(B_2240000000,'00.00','') AS B_2240000000
		,REPLACE(B_2250000000,'00.00','') AS B_2250000000
		,REPLACE(B_2260000000,'00.00','') AS B_2260000000
		,REPLACE(SubTotalPasivoNoCirculanteAnterior,'00.00','') AS SubTotalPasivoNoCirculanteAnterior
		,REPLACE(B_3122300000,'00.00','') AS B_3122300000
		,REPLACE(B_3122200000,'00.00','') AS B_3122200000
		,REPLACE(B_3122100000,'00.00','') AS B_3122100000
		,REPLACE(SubTotalPatrimoniContribuidoAnterior,'00.00','') AS SubTotalPatrimoniContribuidoAnterior
		,REPLACE(B_3210000000,'00.00','') AS B_3210000000
		,REPLACE(B_3220000000,'00.00','') AS B_3220000000
		,REPLACE(B_3230000000,'00.00','') AS B_3230000000
		,REPLACE(B_3240000000,'00.00','') AS B_3240000000
		,REPLACE(B_3250000000,'00.00','') AS B_3250000000
		,REPLACE(SubTotalPatrimonioGeneradoAnterior,'00.00','') AS SubTotalPatrimonioGeneradoAnterior
		,REPLACE(B_Exc01,'00.00','') AS B_Exc01
		,REPLACE(B_Exc02,'00.00','') AS B_Exc02
		,CASE WHEN V_1110000000 = '0.00' THEN ' ' ELSE REPLACE(V_1110000000,'00.00','') END  AS V_1110000000
		,CASE WHEN V_1120000000 = '0.00' THEN ' ' ELSE REPLACE(V_1120000000,'00.00','') END  AS V_1120000000
		,CASE WHEN V_1130000000 = '0.00' THEN ' ' ELSE REPLACE(V_1130000000,'00.00','') END  AS V_1130000000
		,CASE WHEN V_1140000000 = '0.00' THEN ' ' ELSE REPLACE(V_1140000000,'00.00','') END  AS V_1140000000
		,CASE WHEN V_1150000000 = '0.00' THEN ' ' ELSE REPLACE(V_1150000000,'00.00','') END  AS V_1150000000
		,CASE WHEN V_1160000000 = '0.00' THEN ' ' ELSE REPLACE(V_1160000000,'00.00','') END  AS V_1160000000
		,CASE WHEN V_1170000000 = '0.00' THEN ' ' ELSE REPLACE(V_1170000000,'00.00','') END  AS V_1170000000
		,CASE WHEN SubTotal_V_Activo = '0.00' THEN ' ' ELSE REPLACE(SubTotal_V_Activo,'00.00','') END AS SubTotal_V_Activo
		,CASE WHEN V_2110000000 = '0.00' THEN ' ' ELSE REPLACE(V_2110000000,'00.00','') END  AS V_2110000000
		,CASE WHEN V_2120000000 = '0.00' THEN ' ' ELSE REPLACE(V_2120000000,'00.00','') END  AS V_2120000000
		,CASE WHEN V_2130000000 = '0.00' THEN ' ' ELSE REPLACE(V_2130000000,'00.00','') END  AS V_2130000000
		,CASE WHEN V_2140000000 = '0.00' THEN ' ' ELSE REPLACE(V_2140000000,'00.00','') END  AS V_2140000000
		,CASE WHEN V_2150000000 = '0.00' THEN ' ' ELSE REPLACE(V_2150000000,'00.00','') END  AS V_2150000000
		,CASE WHEN V_2160000000 = '0.00' THEN ' ' ELSE REPLACE(V_2160000000,'00.00','') END  AS V_2160000000
		,CASE WHEN V_2170000000 = '0.00' THEN ' ' ELSE REPLACE(V_2170000000,'00.00','') END  AS V_2170000000
		,CASE WHEN V_2180000000 = '0.00' THEN ' ' ELSE REPLACE(V_2180000000,'00.00','') END  AS V_2180000000
		,CASE WHEN SubTotal_V_Pasivo = '0.00' THEN ' ' ELSE REPLACE(SubTotal_V_Pasivo,'00.00','') END AS SubTotal_V_Pasivo
		,CASE WHEN V_1210000000 = '0.00' THEN ' ' ELSE REPLACE(V_1210000000,'00.00','') END  AS V_1210000000
		,CASE WHEN V_1220000000 = '0.00' THEN ' ' ELSE REPLACE(V_1220000000,'00.00','') END  AS V_1220000000
		,CASE WHEN V_1230000000 = '0.00' THEN ' ' ELSE REPLACE(V_1230000000,'00.00','') END  AS V_1230000000
		,CASE WHEN V_1240000000 = '0.00' THEN ' ' ELSE REPLACE(V_1240000000,'00.00','') END  AS V_1240000000
		,CASE WHEN V_1250000000 = '0.00' THEN ' ' ELSE REPLACE(V_1250000000,'00.00','') END  AS V_1250000000
		,CASE WHEN V_1260000000 = '0.00' THEN ' ' ELSE REPLACE(V_1260000000,'00.00','') END  AS V_1260000000
		,CASE WHEN V_1270000000 = '0.00' THEN ' ' ELSE REPLACE(V_1270000000,'00.00','') END  AS V_1270000000
		,CASE WHEN V_1280000000 = '0.00' THEN ' ' ELSE REPLACE(V_1280000000,'00.00','') END  AS V_1280000000
		,CASE WHEN V_1290000000 = '0.00' THEN ' ' ELSE REPLACE(V_1290000000,'00.00','') END  AS V_1290000000
		,CASE WHEN SubTotal_V_Activo_No_C = '0.00' THEN ' ' ELSE REPLACE(SubTotal_V_Activo_No_C,'00.00','') END AS SubTotal_V_Activo_No_C
		,CASE WHEN V_2210000000 = '0.00' THEN ' ' ELSE REPLACE(V_2210000000,'00.00','') END  AS V_2210000000
		,CASE WHEN V_2220000000 = '0.00' THEN ' ' ELSE REPLACE(V_2220000000,'00.00','') END  AS V_2220000000
		,CASE WHEN V_2230000000 = '0.00' THEN ' ' ELSE REPLACE(V_2230000000,'00.00','') END  AS V_2230000000
		,CASE WHEN V_2240000000 = '0.00' THEN ' ' ELSE REPLACE(V_2240000000,'00.00','') END  AS V_2240000000
		,CASE WHEN V_2250000000 = '0.00' THEN ' ' ELSE REPLACE(V_2250000000,'00.00','') END  AS V_2250000000
		,CASE WHEN V_2260000000 = '0.00' THEN ' ' ELSE REPLACE(V_2260000000,'00.00','') END  AS V_2260000000
		,CASE WHEN SubTotal_V_Pasivo_No_C = '0.00' THEN ' ' ELSE REPLACE(SubTotal_V_Pasivo_No_C,'00.00','') END AS SubTotal_V_Pasivo_No_C
		,CASE WHEN V_3122300000 = '0.00' THEN ' ' ELSE REPLACE(V_3122300000,'00.00','') END  AS V_3122300000
		,CASE WHEN V_3122200000 = '0.00' THEN ' ' ELSE REPLACE(V_3122200000,'00.00','') END  AS V_3122200000
		,CASE WHEN V_3122100000 = '0.00' THEN ' ' ELSE REPLACE(V_3122100000,'00.00','') END  AS V_3122100000
		,CASE WHEN SubTotal_V_PatrimonioContribuido = '0.00' THEN ' ' ELSE REPLACE(SubTotal_V_PatrimonioContribuido,'00.00','') END AS SubTotal_V_PatrimonioContribuido
		,CASE WHEN V_3210000000 = '0.00' THEN ' ' ELSE REPLACE(V_3210000000,'00.00','') END  AS V_3210000000
		,CASE WHEN V_3220000000 = '0.00' THEN ' ' ELSE REPLACE(V_3220000000,'00.00','') END  AS V_3220000000
		,CASE WHEN V_3230000000 = '0.00' THEN ' ' ELSE REPLACE(V_3230000000,'00.00','') END  AS V_3230000000
		,CASE WHEN V_3240000000 = '0.00' THEN ' ' ELSE REPLACE(V_3240000000,'00.00','') END  AS V_3240000000
		,CASE WHEN V_3250000000 = '0.00' THEN ' ' ELSE REPLACE(V_3250000000,'00.00','') END  AS V_3250000000
		,CASE WHEN SubTotal_V_PatrimonioGenerado = '0.00' THEN ' ' ELSE REPLACE(SubTotal_V_PatrimonioGenerado,'00.00','') END AS SubTotal_V_PatrimonioGenerado 
		,REPLACE(V_Exc01,'00.00','') AS V_Exc01
		,REPLACE(V_Exc02,'00.00','') AS V_Exc02
		,REPLACE(P_1110000000,'00.00','') AS P_1110000000
		,REPLACE(P_1120000000,'00.00','') AS P_1120000000
		,REPLACE(P_1130000000,'00.00','') AS P_1130000000
		,REPLACE(P_1140000000,'00.00','') AS P_1140000000
		,REPLACE(P_1150000000,'00.00','') AS P_1150000000
		,REPLACE(P_1160000000,'00.00','') AS P_1160000000
		,REPLACE(P_1170000000,'00.00','') AS P_1170000000
		,REPLACE(P_2110000000,'00.00','') AS P_2110000000
		,REPLACE(P_2120000000,'00.00','') AS P_2120000000
		,REPLACE(P_2130000000,'00.00','') AS P_2130000000
		,REPLACE(P_2140000000,'00.00','') AS P_2140000000
		,REPLACE(P_2150000000,'00.00','') AS P_2150000000
		,REPLACE(P_2160000000,'00.00','') AS P_2160000000
		,REPLACE(P_2170000000,'00.00','') AS P_2170000000
		,REPLACE(P_2180000000,'00.00','') AS P_2180000000
		,REPLACE(P_1210000000,'00.00','') AS P_1210000000
		,REPLACE(P_1220000000,'00.00','') AS P_1220000000
		,REPLACE(P_1230000000,'00.00','') AS P_1230000000
		,REPLACE(P_1240000000,'00.00','') AS P_1240000000
		,REPLACE(P_1250000000,'00.00','') AS P_1250000000
		,REPLACE(P_1260000000,'00.00','') AS P_1260000000
		,REPLACE(P_1270000000,'00.00','') AS P_1270000000
		,REPLACE(P_1280000000,'00.00','') AS P_1280000000
		,REPLACE(P_1290000000,'00.00','') AS P_1290000000
		,REPLACE(P_2210000000,'00.00','') AS P_2210000000
		,REPLACE(P_2220000000,'00.00','') AS P_2220000000
		,REPLACE(P_2230000000,'00.00','') AS P_2230000000
		,REPLACE(P_2240000000,'00.00','') AS P_2240000000
		,REPLACE(P_2250000000,'00.00','') AS P_2250000000
		,REPLACE(P_2260000000,'00.00','') AS P_2260000000
		,REPLACE(P_3122300000,'00.00','') AS P_3122300000
		,REPLACE(P_3122200000,'00.00','') AS P_3122200000
		,REPLACE(P_3122100000,'00.00','') AS P_3122100000
		,REPLACE(P_3210000000,'00.00','') AS P_3210000000
		,REPLACE(P_3220000000,'00.00','') AS P_3220000000
		,REPLACE(P_3230000000,'00.00','') AS P_3230000000
		,REPLACE(P_3240000000,'00.00','') AS P_3240000000
		,REPLACE(P_3250000000,'00.00','') AS P_3250000000
		,REPLACE(P_Exc01,'00.00','') AS P_Exc01
		,REPLACE(P_Exc02,'00.00','') AS P_Exc02
		,(SELECT CASE WHEN P.SubTotal_V_ActivoCirculante < 0 THEN '('+ FORMAT(P.SubTotal_V_ActivoCirculante * -1,'N','EN-US') +')' 
		                                                     ELSE FORMAT(P.SubTotal_V_ActivoCirculante,'N','EN-US') END 
		  FROM #TMP_Porcentaje AS P) AS SubTotal_P_Activo
		,(SELECT CASE WHEN P.SubTotal_V_ActivoNoCirculante < 0 THEN '('+FORMAT(P.SubTotal_V_ActivoNoCirculante * -1,'N','EN-US') + ')' 
		                                                       ELSE FORMAT(P.SubTotal_V_ActivoNoCirculante,'N','EN-US') END 
		 FROM #TMP_Porcentaje AS P) AS SubTotal_P_Activo_No_C
		,(SELECT CASE WHEN P.TOTAL_P_ACTIVO < 0 THEN '('+FORMAT(P.TOTAL_P_ACTIVO * -1,'N','EN-US') + ')' 
		                                        ELSE FORMAT(P.TOTAL_P_ACTIVO,'N','EN-US') END 
	     FROM #TMP_Porcentaje AS P ) AS TOTAL_P_ACTIVO
		,(SELECT CASE WHEN P.SubTotal_V_Pasivo < 0 THEN '('+FORMAT(P.SubTotal_V_Pasivo * -1,'N','EN-US') + ')' 
		                                           ELSE FORMAT(P.SubTotal_V_Pasivo,'N','EN-US') END 
		  FROM #TMP_Porcentaje AS P) AS SubTotal_P_Pasivo
		,(SELECT CASE WHEN P.SubTotal_V_Pasivo_No_C < 0 THEN '('+FORMAT(P.SubTotal_V_Pasivo_No_C * -1,'N','EN-US') + ')' 
		                                                ELSE FORMAT(P.SubTotal_V_Pasivo_No_C,'N','EN-US') END 
		 FROM #TMP_Porcentaje AS P) AS SubTotal_P_Pasivo_No_C
		,(SELECT CASE WHEN P.TOTAL_P_PASIVO < 0 THEN '('+FORMAT(P.TOTAL_P_PASIVO * -1,'N','EN-US') + ')' 
		                                        ELSE FORMAT(P.TOTAL_P_PASIVO,'N','EN-US') END 
		  FROM #TMP_Porcentaje AS P) AS TOTAL_P_PASIVO  
		,(SELECT CASE WHEN P.SubTotal_V_PatrimonioContribuido < 0 THEN '('+FORMAT(P.SubTotal_V_PatrimonioContribuido * -1, 'N','EN-US') + ')' 
		                                                          ELSE FORMAT(P.SubTotal_V_PatrimonioContribuido,'N','EN-US') END 
		  FROM #TMP_Porcentaje AS P) AS SubTotal_P_PatrimonioContibuido
		,(SELECT CASE WHEN P.SubTotal_V_PatrimonioGenerado < 0 THEN '('+FORMAT(P.SubTotal_V_PatrimonioGenerado * -1,'N','EN-US') + ')' 
		                                                       ELSE FORMAT(P.SubTotal_V_PatrimonioGenerado,'N','EN-US') END 
		  FROM #TMP_Porcentaje AS P) AS SubTotal_P_PatrimonioGenerado
		,(SELECT CASE WHEN P.TOTAL_P_HACIENDA < 0 THEN '('+FORMAT(P.TOTAL_P_HACIENDA * -1,'N','EN-US')+')' 
		                                          ELSE FORMAT(P.TOTAL_P_HACIENDA,'N','EN-US') END 
		  FROM #TMP_Porcentaje AS P) AS TOTAL_P_HACIENDA 
		,REPLACE(TOTAL_ACTIVO,'00.00','') AS  TOTAL_ACTIVOS
		,REPLACE(TOTAL_ACTIVO_ANTERIOR,'00.00','') AS TOTAL_ACTIVO_ANTERIOR
		,REPLACE(TOTAL_PASIVO_CIRCULANTE,'00.00','') AS TOTAL_PASIVOnoCIRCULANTE
		,REPLACE(TOTAL_PASIVO_CIRCULANTE_ANTERIOR,'00.00','') AS TOTAL_PASIVO_CIRCULANTE_ANTERIOR
		,REPLACE(TOTAL_PASIVO_CIRCULANTE,'00.00','') AS TOTAL_PASIVO_CIRCULANTE
		,REPLACE(TOTAL_PASIVO_CIRCULANTE_ANTERIOR,'00.000','') AS TOTAL_PASIVO_CIRCULANTE_ANTERIOR
		,REPLACE(TOTAL_HACIENDA,'00.00','') AS TOTAL_HACIENDA
		,REPLACE(TOTAL_HACIENDA_HACIENDA,'00.00','') AS TOTAL_HACIENDA_HACIENDA
		,REPLACE(TOTAL_V_ACTIVO,'00.00','') AS TOTAL_V_ACTIVO
		,REPLACE(TOTAL_V_PASIVO,'00.00','') AS TOTAL_V_PASIVO
		,REPLACE(TOTAL_V_HACIENDA,'00.00','') AS TOTAL_V_HACIENDA 
		,REPLACE(TOTAL,'00.00','') AS TOTAL
		,REPLACE(TOTAL_ANTERIOR,'00.00','') AS TOTAL_ANTERIOR
		,REPLACE(TOTAL_VARIACION,'00.00','') AS TOTAL_VARIACION
		,(SELECT CASE WHEN P.TOTAL_PORCENTAJE < 0 THEN '('+ FORMAT(P.TOTAL_PORCENTAJE * -1,'N','EN-US') + ')'
												  ELSE FORMAT(P.TOTAL_PORCENTAJE,'N','EN-US') END
		 FROM #TMP_Porcentaje AS P) AS TOTAL_PORCENTAJE
	FROM #TMP

	DROP TABLE #SaldosFinalesAnioActual, #SaldosFinalesAnioAnterior, #Variacion, #Porcentaje,#TMP, #TOTAL_PORCENTAJE
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_EstadoVariacionHaciendaPublica]';
GO
-- exec [CONTA].[SPR_EstadoVariacionHaciendaPublica] '2024-01-01','2024-01-30' 
CREATE OR ALTER PROCEDURE [CONTA].[SPR_EstadoVariacionHaciendaPublica]
	 @p_FecInicio nvarchar(24), -- = '20250101', 
	@p_FecFin nvarchar(24)-- = '20250131', 
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @FechaInicio datetime = @p_FecInicio,	-- = '20250101', 
	@FechaFin datetime	= @p_FecFin	-- = '20250131', 


	declare @Mes_Inicio int = month(@FechaInicio)
	declare @Mes_Fin int = month(@FechaFin)
	declare @FKIdAnio_SIS int = (select [PKIdAnio] from [SIS].[Anio] where [Clave] = year(@FechaInicio));
	declare @Fk_IdMes__SIS_Anterior  int = @Mes_Inicio - 1;
	declare @Fk_IdAnio__SIS_Anterior int = @FKIdAnio_SIS - 1;


	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepVariacionHdaPub'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	SELECT id=1,Concepto = CAST('Hacienda Pública / Patrimonio Contribuido Neto de 2024' as nvarchar(500)), [HP/PC] = '-3,112,907,042.00', [HP/PGEA] = '0.00',[HP/PGE] ='0.00', [EIAHP/P] = '0.00', [Total] = '-3,112,907,042.00'
	into #tlbEstadoVariacionHaciendaPublica
	UNION
	SELECT id=2,Concepto = 'Aportaciones', [HP/PC] = '-3,112,907,042.00', [HP/PGEA] = '0.00',[HP/PGE] ='0.00', [EIAHP/P] = '0.00', [Total] = '-3,112,907,042.00'
	UNION
	SELECT id=3,Concepto = 'Donaciones de Capital', [HP/PC] = '0.00', [HP/PGEA] = '0.00',[HP/PGE] ='0.00', [EIAHP/P] = '0.00', [Total] = '0.00'
	UNION
	SELECT id=4,Concepto = 'Actualizacion de la Hacienda Pública / Patrimonio', [HP/PC] = '0.00', [HP/PGEA] = '0.00',[HP/PGE] ='0.00', [EIAHP/P] = '0.00', [Total] = '0.00'
	UNION
	SELECT id=5,Concepto = 'Hacienda Pública / Patrimonio Generado Neto de 2024', [HP/PC] = '0.00', [HP/PGEA] = '-470,911,889.00',[HP/PGE] ='532,861,201.00', [EIAHP/P] = '0.00', [Total] = '61,949,312.00'
	UNION
	SELECT id=6,Concepto = 'Resultados del Ejercicio (Ahorro / Desahorro)', [HP/PC] = '0.00', [HP/PGEA] = '0.00',[HP/PGE] ='532,861,201.00', [EIAHP/P] = '0.00', [Total] = '532,861,201.00'
	UNION
	SELECT id=7,Concepto = 'Resultados de Ejercicios Anteriores', [HP/PC] = '0.00', [HP/PGEA] = '-471,636,791.00',[HP/PGE] ='0.00', [EIAHP/P] = '0.00', [Total] = '-471,636,791.00'
	UNION
	SELECT id=8,Concepto = 'Revalúos', [HP/PC] = '0.00', [HP/PGEA] = '724,902.00 ',[HP/PGE] ='0.00', [EIAHP/P] = '0.00', [Total] = '724,902.00 '
	UNION
	SELECT id=9,Concepto = 'Reservas', [HP/PC] = '0.00', [HP/PGEA] = '0.00',[HP/PGE] ='0.00', [EIAHP/P] = '0.00', [Total] = '0.00'
	UNION
	SELECT id=10,Concepto = 'Rectificaciones de Resultados de Ejercicios Anteriores', [HP/PC] = '0.00', [HP/PGEA] = '0.00',[HP/PGE] ='0.00', [EIAHP/P] = '0.00', [Total] = '0.00'
	UNION
	SELECT id=11,Concepto = 'Exceso o Insuficiencia en la Actualizacion de la Hacienda Pública / Patrimonio Neto de 2024', [HP/PC] = '0.00', [HP/PGEA] = '0.00',[HP/PGE] ='0.00', [EIAHP/P] = '0.00', [Total] = '0.00'
	UNION
	SELECT id=12,Concepto = 'Resultado por Posición Monetaria', [HP/PC] = '0.00', [HP/PGEA] = '0.00',[HP/PGE] ='0.00', [EIAHP/P] = '0.00', [Total] = '0.00'
	UNION
	SELECT id=13,Concepto = 'Resultado por Tenencia de Activos Monetarios', [HP/PC] = '0.00', [HP/PGEA] = '0.00',[HP/PGE] ='0.00', [EIAHP/P] = '0.00', [Total] = '0.00'
	UNION
	SELECT id=14,Concepto = 'Hacienda Pública / Patrimonio Neto Final 2024', [HP/PC] = '-3,112,907,042.00', [HP/PGEA] = '-470,911,889.00',[HP/PGE] ='532,861,201.00', [EIAHP/P] = '0.00', [Total] = '-3,112,907,042.00'
	UNION
	SELECT id=15,Concepto = 'Cambios en la Hacienda Pública / Patrimonio Contribuido Neto 2023', [HP/PC] = '-3,112,907,042.00', [HP/PGEA] = '0.00',[HP/PGE] ='0.00', [EIAHP/P] = '0.00', [Total] = '-3,112,907,042.00'
	UNION
	SELECT id=16,Concepto = 'Aportaciones', [HP/PC] = '-3,112,907,042.00', [HP/PGEA] = '0.00',[HP/PGE] ='0.00', [EIAHP/P] = '0.00', [Total] = '-3,112,907,042.00'
	UNION
	SELECT id=17,Concepto = 'Donaciones de Capital', [HP/PC] = '0.00', [HP/PGEA] = '0.00',[HP/PGE] ='0.00', [EIAHP/P] = '0.00', [Total] = '0.00'
	UNION
	SELECT id=18,Concepto = 'Actualización de la Hacienda Pública / Patrimonio', [HP/PC] = '0.00', [HP/PGEA] = '0.00',[HP/PGE] ='0.00', [EIAHP/P] = '0.00', [Total] = '0.00'
	UNION
	SELECT id=19,Concepto = 'Variaciones de la Hacienda Pública / Patrimonio Generado Neto de 2023', [HP/PC] = '0.00', [HP/PGEA] = '-471,636,791.00',[HP/PGE] ='1,065,722,402.00', [EIAHP/P] = '0.00', [Total] = '0.00'
	UNION
	SELECT id=20,Concepto = 'Resultados del Ejercicio (Ahorro / Desahorro)', [HP/PC] = '0.00', [HP/PGEA] = '0.00',[HP/PGE] ='532,861,201.00', [EIAHP/P] = '0.00', [Total] = '532,861,201.00'
	UNION
	SELECT id=21,Concepto = 'Resultados de Ejercicio Anteriores ', [HP/PC] = '0.00', [HP/PGEA] = '-471,636,791.00',[HP/PGE] ='532,861,201.00', [EIAHP/P] = '0.00', [Total] = '61,224,410.00'
	UNION
	SELECT id=22,Concepto = 'Revalúos', [HP/PC] = '0.00', [HP/PGEA] = '0.00',[HP/PGE] ='0.00', [EIAHP/P] = '0.00', [Total] = '0.00'
	UNION
	SELECT id=23,Concepto = 'Reservas', [HP/PC] = '0.00', [HP/PGEA] = '0.00',[HP/PGE] ='0.00', [EIAHP/P] = '0.00', [Total] = '0.00'
	UNION
	SELECT id=24,Concepto = 'Rectificaciones de Resultados de Ejercicios Anteriores', [HP/PC] = '0.00', [HP/PGEA] = '0.00',[HP/PGE] ='0.00', [EIAHP/P] = '0.00', [Total] = '0.00'
	UNION
	SELECT id=25,Concepto = 'Cambios en el Exceso o Insuficiencia en la Actualización de la Hacienda Pública / Patrimonio Neto de 2023', [HP/PC] = '0.00', [HP/PGEA] = '0.00',[HP/PGE] ='0.00', [EIAHP/P] = '0.00', [Total] = '0.00'
	UNION
	SELECT id=26,Concepto = 'Resultado por Posición Monetaria', [HP/PC] = '0.00', [HP/PGEA] = '0.00',[HP/PGE] ='0.00', [EIAHP/P] = '0.00', [Total] = '0.00'
	UNION
	SELECT id=27,Concepto = 'Resultado por Tenencia de Activos Monetarios', [HP/PC] = '0.00', [HP/PGEA] = '0.00',[HP/PGE] ='0.00', [EIAHP/P] = '0.00', [Total] = '0.00'
	UNION
	SELECT id=28,Concepto = 'Hacienda Pública / Patrimonio Neto Final de 2023', [HP/PC] = '-6,225,814,084.00', [HP/PGEA] = '-942,548,680.00',[HP/PGE] ='1,598,583,603.00', [EIAHP/P] = '0.00', [Total] = '-3,112,907,042.00'

	--FIN


	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('DEL ' , FORMAT(@FechaInicio, 'dd \de MMMM \del yyyy', 'es-MX') , ' AL ' ,  FORMAT(@FechaFin, 'dd \de MMMM \del yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tlbEstadoVariacionHaciendaPublica
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_FacturasEmitidas]';
GO
CREATE OR ALTER PROCEDURE [CONTA].[SPR_FacturasEmitidas]
      @p_FecInicio nvarchar(24),
      @p_FecFin nvarchar(24)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    DECLARE @p_FechaInicio date = @p_FecInicio,
            @p_FechaFin date = @p_FecFin;

    DECLARE @Funcion1 nvarchar(64) = N'',
            @Funcion2 nvarchar(64) = N'',
            @Funcion3 nvarchar(64) = N'',
            @Nombre1 nvarchar(254) = N'',
            @Nombre2 nvarchar(254) = N'',
            @Nombre3 nvarchar(254) = N'',
            @Puesto1 nvarchar(254) = N'',
            @Puesto2 nvarchar(254) = N'',
            @Puesto3 nvarchar(254) = N'';

    SELECT f.PKIdFactura AS Id,
           f.NumFactura AS [Número de Factura],
           COALESCE(f.FechaEmision, f.FechaRecepcion) AS Fecha,
           COALESCE(p.RFC, N'') AS RFC,
           COALESCE(f.ProveedorNombre, p.Nombre, N'') AS [Emitida a Nombre de],
           COALESCE(fd.Observaciones, f.Observaciones, N'') AS Concepto,
           ISNULL(f.Subtotal, 0) AS [Importe Neto],
           ISNULL(f.IVA, 0) AS IVA,
           ISNULL(f.Retencion, 0) AS Otros,
           ISNULL(f.Total, 0) AS Total
    INTO #tblFacturasEmitidas
    FROM [PRES].[Vw_Factura] f
    LEFT JOIN [SIS].[Proveedor] p ON p.PKIdProveedor = f.FKIdProveedor_SIS
    OUTER APPLY (
        SELECT TOP (1) d.Observaciones
        FROM [PRES].[Vw_FacturaDetalle] d
        WHERE d.FKIdFactura_PRES = f.PKIdFactura
        ORDER BY d.PKIdFacturaDetalle
    ) fd
    WHERE f.Activo = 1
      AND COALESCE(f.FechaEmision, f.FechaRecepcion) BETWEEN @p_FechaInicio AND @p_FechaFin;

    SELECT *,
           @Funcion1 AS Funcion1,
           @Funcion2 AS Funcion2,
           @Funcion3 AS Funcion3,
           @Nombre1 AS Nombre1,
           @Nombre2 AS Nombre2,
           @Nombre3 AS Nombre3,
           @Puesto1 AS Puesto1,
           @Puesto2 AS Puesto2,
           @Puesto3 AS Puesto3,
           CAST(CONCAT('PERIODO: DEL ', FORMAT(@p_FechaInicio, 'dd', 'es-MX'), ' AL ', FORMAT(@p_FechaFin, 'dd', 'es-MX'), ' DE ', UPPER(FORMAT(@p_FechaFin, 'MMMM', 'es-MX')), ' DE ', FORMAT(@p_FechaFin, 'yyyy', 'es-MX')) AS nvarchar(128)) AS Titulo
    FROM #tblFacturasEmitidas;
END
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_Get_Balanza]';
GO
--exec [CONTA].[SPR_Get_Balanza] '2024-01-01','2024-01-31',2,1,0


CREATE OR ALTER PROCEDURE [CONTA].[SPR_Get_Balanza]
(
@p_FecInicio nvarchar(24),
@p_FecFin nvarchar(24),
@p_nivel INT,
@p_UsaMesTrece INT,
@p_SoloCuentasPres INT
)
AS
BEGIN
SET NOCOUNT ON;    


	DECLARE @p_FechaInicio DATE = @p_FecInicio,
	@p_FechaFin DATE = @p_FecFin

    DECLARE @v_FK_IdMesAnterior INT;
    DECLARE @v_FK_IdMesActual INT;
DECLARE @v_FK_IdAnioAnterior INT;
DECLARE @v_FK_IdAnioActual INT;
DECLARE @v_AnioActual INT;

DECLARE @v_FechaInicio Date;



SELECT @v_FK_IdMesActual = MONTH(@p_FechaInicio);
SELECT @v_AnioActual = YEAR (@p_FechaInicio);

SELECT @v_FK_IdAnioAnterior = PKIdAnio FROM SIS.Anio sa WHERE Clave = @v_AnioActual;

SET @v_FechaInicio = DATEFROMPARTS(@v_AnioActual, @v_FK_IdMesActual, 1);



If (@v_FK_IdMesActual = 1) BEGIN
SET @v_FK_IdMesAnterior = 12;
END
ELSE BEGIN
SET @v_FK_IdMesAnterior = @v_FK_IdMesActual - 1;
END

IF (@v_FK_IdMesAnterior = 12) BEGIN
SET @v_FK_IdAnioAnterior = @v_FK_IdAnioAnterior - 1;
END

If (@v_FK_IdMesAnterior = 12 AND @p_UsaMesTrece = 1) BEGIN
SET @v_FK_IdMesAnterior = 13;
END  


-- DEBUG
PRINT 'Fecha inicio'
PRINT @v_FechaInicio
PRINT @v_FK_IdAnioAnterior
PRINT @v_FK_IdMesAnterior
PRINT '*****************'
PRINT @v_AnioActual
PRINT @v_FK_IdMesActual
PRINT @v_FK_IdAnioActual


IF OBJECT_ID('tempdb..#tmp_balanza') IS NOT NULL DROP TABLE #tmp_balanza;
    CREATE TABLE #tmp_balanza
(
FKIdAnio_SIS INT
, FKIdMes_SIS INT
, FKIdCuentaContable INT
, FKIdTipoCuenta_CONTA int
, SaldoInicial DECIMAL(38,2)
, Cargos DECIMAL(38,2)
, Abonos DECIMAL(38,2)
, SaldoFinal DECIMAL(38,2)
, FechaCreacion datetime2(6)
);



IF OBJECT_ID('tempdb..#tmp_balanza_Agrup') IS NOT NULL DROP TABLE #tmp_balanza_Agrup;
CREATE TABLE #tmp_balanza_Agrup
(
FKIdAnio_SIS INT
, FKIdMes_SIS INT
, FKIdCuentaContable INT
, FKIdTipoCuenta_CONTA int
, Anio INT
, Mes VarChar(50)
, Cuenta VarChar(5)
, SubCuenta VarChar(5)
, SubSubCuenta VarChar(5)
, SubSubSubCuenta VarChar(5)
, SubSubSubSubCuenta VarChar(5)
, S5 VarChar(5)
, S6 VarChar(5)
, s7 VarChar(5)
, s8 VarChar(5)
, s9 VarChar(5)
, s10 VarChar(5)
, SaldoInicial DECIMAL(38,2)
, Cargos DECIMAL(38,2)
, Abonos DECIMAL(38,2)
, SaldoFinal DECIMAL(38,2)
, FechaCreacion datetime2(6)
);



IF OBJECT_ID('tempdb..#tmp_balanza_Agrup2') IS NOT NULL DROP TABLE #tmp_balanza_Agrup2;
CREATE TABLE #tmp_balanza_Agrup2
(
FKIdAnio_SIS INT
, FKIdMes_SIS INT
, Anio INT
, Mes VarChar(50)
, Cuentastr VarChar(50)
, EspaciosNivel Varchar(14)
, Nivel Varchar(2)
, SaldoInicial DECIMAL(38,2)
, Cargos DECIMAL(38,2)
, Abonos DECIMAL(38,2)
, SaldoFinal DECIMAL(38,2)
, FechaCreacion datetime2(6)
);



INSERT INTO #tmp_balanza
(FKIdAnio_SIS, FKIdMes_SIS, FKIdCuentaContable, FKIdTipoCuenta_CONTA, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)


SELECT @v_AnioActual AS FKIdAnio_SIS
, @v_FK_IdMesActual AS FKIdMes_SIS
, cb.FKIdCuentaContable
, scc2.FKIdTipoCuenta_CONTA
, ISNULL(cb.SaldoFinal, 0) AS SaldoInicial
, 0 AS Debe
, 0 AS Haber
, 0 as Saldo
, GETDATE()  
FROM CONTA.SaldoMensual cb
JOIN CONTA.CuentaContable scc2 ON cb.FKIdCuentaContable = scc2.PKIdCuentaContable  
WHERE cb.FKIdAnio_SIS = @v_FK_IdAnioAnterior
AND cb.FKIdMes_SIS =  @v_FK_IdMesAnterior
AND scc2.IsCuentaDetalle =1
AND cb.Activo = 1 AND scc2.Activo = 1

UNION ALL

SELECT @v_AnioActual AS FKIdAnio_SIS
, @v_FK_IdMesActual AS FKIdMes_SIS
, cdp.FKIdCuentaContable_CONTA
, scc.FKIdTipoCuenta_CONTA
, 0 as SaldoInicial
, SUM(cdp.ImporteDebe) AS Debe
, SUM( cdp.ImporteHaber) AS Haber
, 0 AS Saldo
, GETDATE()  
FROM CONTA.Poliza cp
JOIN CONTA.PolizaDetalle cdp ON cdp.FKIdPoliza_CONTA = cp.PKIdPoliza  
JOIN CONTA.CuentaContable scc ON cdp.FKIdCuentaContable_CONTA = scc.PKIdCuentaContable
WHERE cp.FechaPoliza >= @v_FechaInicio AND cp.FechaPoliza <= @p_FechaFin
AND scc.IsCuentaDetalle = 1
AND cp.Activo = 1 AND cdp.Activo = 1
GROUP BY scc.FKIdTipoCuenta_CONTA , cdp.FKIdCuentaContable_CONTA  
;

--SELECT * FROM #tmp_balanza


IF @p_SoloCuentasPres = 1 BEGIN

INSERT INTO #tmp_balanza_Agrup
  (FKIdAnio_SIS, FKIdMes_SIS, FKIdCuentaContable
, Anio
, Mes
, Cuenta
, SubCuenta
, SubSubCuenta
, SubSubSubCuenta
, SubSubSubSubCuenta
, S5
, S6
, s7
, s8
, s9
, s10
,SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)


SELECT cb.FKIdAnio_SIS
, cb.FKIdMes_SIS
, cb.FKIdCuentaContable
, sa.Clave as Anio
, sm.Descripcion as Mes
, scc.Cuenta
, scc.SubCuenta
, scc.SubSubCuenta
, scc.SubSubSubCuenta
, NULLIF(RIGHT('0000' + scc.SubSubSubSubCuenta,4),'') --scc.SubSubSubSubCuenta
, NULLIF(RIGHT('0000' + scc.s5,4),'')
, NULLIF(RIGHT('0000' + scc.s6,4),'')
, NULLIF(RIGHT('0000' + scc.s7,4),'')
, NULLIF(RIGHT('0000' + scc.s8,4),'')
, NULLIF(RIGHT('0000' + scc.s9,4),'')
, NULLIF(RIGHT('0000' + scc.s10,4),'')
, SUM(SaldoInicial) AS SaldoInicial
, SUM(Cargos) AS Cargos
, SUM(Abonos) AS Abonos

, CASE 	WHEN cb.FKIdTipoCuenta_CONTA = 1 THEN ISNULL(SUM(cb.SaldoInicial), 0) - ISNULL(SUM(cb.Cargos), 0) + ISNULL(SUM( cb.Abonos), 0)
		WHEN cb.FKIdTipoCuenta_CONTA = 2 THEN ISNULL(SUM(cb.SaldoInicial), 0) + ISNULL(SUM(cb.Cargos), 0) - ISNULL(SUM( cb.Abonos), 0)	
	END AS SaldoFinal	
, cb.FechaCreacion  
FROM #tmp_balanza cb
JOIN CONTA.CuentaContable scc ON cb.FKIdCuentaContable = scc.PKIdCuentaContable
JOIN SIS.Anio sa ON cb.FKIdAnio_SIS = sa.PKIdAnio
JOIN SIS.Mes sm ON cb.FKIdMes_SIS = sm.PKIdMes
WHERE scc.Cuenta = '8'
GROUP BY cb.FKIdAnio_SIS, cb.FKIdMes_SIS, cb.FKIdCuentaContable, cb.FechaCreacion, sa.Clave, sm.Descripcion
, scc.Cuenta
, scc.SubCuenta
, scc.SubSubCuenta
, scc.SubSubSubCuenta
, scc.SubSubSubSubCuenta
, scc.S5
, scc.S6
, scc.s7
, scc.s8
, scc.s9
, scc.s10
, cb.FKIdTipoCuenta_CONTA;


END
ELSE BEGIN

INSERT INTO #tmp_balanza_Agrup
  (FKIdAnio_SIS, FKIdMes_SIS, FKIdCuentaContable
, Anio
, Mes
, Cuenta
, SubCuenta
, SubSubCuenta
, SubSubSubCuenta
, SubSubSubSubCuenta
, S5
, S6
, s7
, s8
, s9
, s10
,SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)


SELECT cb.FKIdAnio_SIS
, cb.FKIdMes_SIS
, cb.FKIdCuentaContable
, sa.Clave as Anio
, sm.Descripcion as Mes
, scc.Cuenta
, scc.SubCuenta
, scc.SubSubCuenta
, scc.SubSubSubCuenta
, NULLIF(RIGHT('0000' + scc.SubSubSubSubCuenta,4),'') --scc.SubSubSubSubCuenta
, NULLIF(RIGHT('0000' + scc.s5,4),'')
, NULLIF(RIGHT('0000' + scc.s6,4),'')
, NULLIF(RIGHT('0000' + scc.s7,4),'')
, NULLIF(RIGHT('0000' + scc.s8,4),'')
, NULLIF(RIGHT('0000' + scc.s9,4),'')
, NULLIF(RIGHT('0000' + scc.s10,4),'')
, SUM(SaldoInicial) AS SaldoInicial
, SUM(Cargos) AS Cargos
, SUM(Abonos) AS Abonos
, CASE 	WHEN cb.FKIdTipoCuenta_CONTA = 1 THEN ISNULL(SUM(cb.SaldoInicial), 0) - ISNULL(SUM(cb.Cargos), 0) + ISNULL(SUM( cb.Abonos), 0)
		WHEN cb.FKIdTipoCuenta_CONTA = 2 THEN ISNULL(SUM(cb.SaldoInicial), 0) + ISNULL(SUM(cb.Cargos), 0) - ISNULL(SUM( cb.Abonos), 0)	
	  END AS SaldoFinal
, cb.FechaCreacion  
FROM #tmp_balanza cb
JOIN CONTA.CuentaContable scc ON cb.FKIdCuentaContable = scc.PKIdCuentaContable
JOIN SIS.Anio sa ON cb.FKIdAnio_SIS = sa.PKIdAnio
JOIN SIS.Mes sm ON cb.FKIdMes_SIS = sm.PKIdMes
GROUP BY cb.FKIdAnio_SIS, cb.FKIdMes_SIS, cb.FKIdCuentaContable, cb.FechaCreacion, sa.Clave, sm.Descripcion
, scc.Cuenta
, scc.SubCuenta
, scc.SubSubCuenta
, scc.SubSubSubCuenta
, scc.SubSubSubSubCuenta
, scc.S5
, scc.S6
, scc.s7
, scc.s8
, scc.s9
, scc.s10
, cb.FKIdTipoCuenta_CONTA;
END

--SELECT * FROM #tmp_balanza_Agrup

IF @p_nivel = 11 BEGIN


INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' ', SubSubSubSubCuenta, ' ' , S5, ' ', S6, ' ',  s7, ' ' , s8, ' ', s9, ' ',  s10) AS Cuentastr
,'          ' AS EspaciosNivel, '11' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, S6, s7, s8, s9, s10, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' ', SubSubSubSubCuenta, ' ', S5, ' ', S6, ' ',  s7, ' ',  s8, ' ', s9, ' 0000' ) AS Cuentastr
,'         ' AS EspaciosNivel, '10' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, S6, s7, s8, s9, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' ', SubSubSubSubCuenta, ' ', S5, ' ', S6, ' ',  s7, ' ',  s8, ' 0000', ' 0000') AS Cuentastr
,'        ' AS EspaciosNivel, '09' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta,  SubSubSubSubCuenta, S5,S6, s7, s8, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes,CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' ', SubSubSubSubCuenta, ' ', S5, ' ', S6, ' ',  s7, ' 0000', ' 0000', ' 0000') AS Cuentastr
,'       ' AS EspaciosNivel, '08' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, S6, s7, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes,CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' ', SubSubSubSubCuenta, ' ', S5, ' ', S6,  ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'      ' AS EspaciosNivel, '07' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, S6, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' ', SubSubSubSubCuenta, ' ', S5, ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'     ' AS EspaciosNivel, '06' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta,  ' ', SubSubSubSubCuenta, ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'    ' AS EspaciosNivel, '05' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'   ' AS EspaciosNivel, '04' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'  ' AS EspaciosNivel,'03' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' 0', ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,' ' AS EspaciosNivel, '02' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' 0', ' 0', ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'' EspaciosNivel, '01' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, FechaCreacion;

END
ELSE IF @p_nivel = 10 BEGIN

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' ', SubSubSubSubCuenta, ' ', S5, ' ', S6, ' ',  s7, ' ',  s8, ' ', s9, ' 0000' ) AS Cuentastr
,'         ' AS EspaciosNivel, '10' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, S6, s7, s8, s9, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' ', SubSubSubSubCuenta, ' ', S5, ' ', S6, ' ',  s7, ' ',  s8, ' 0000', ' 0000') AS Cuentastr
,'        ' AS EspaciosNivel, '09' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta,  SubSubSubSubCuenta, S5,S6, s7, s8, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes,CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' ', SubSubSubSubCuenta, ' ', S5, ' ', S6, ' ',  s7, ' 0000', ' 0000', ' 0000') AS Cuentastr
,'       ' AS EspaciosNivel, '08' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, S6, s7, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes,CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' ', SubSubSubSubCuenta, ' ', S5, ' ', S6,  ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'      ' AS EspaciosNivel, '07' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, S6, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' ', SubSubSubSubCuenta, ' ', S5, ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'     ' AS EspaciosNivel, '06' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta,  ' ', SubSubSubSubCuenta, ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'    ' AS EspaciosNivel, '05' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'   ' AS EspaciosNivel, '04' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'  ' AS EspaciosNivel, '03' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' 0', ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,' ' AS EspaciosNivel, '02' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' 0', ' 0', ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'' EspaciosNivel, '01' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, FechaCreacion;

END
ELSE IF @p_nivel = 9 BEGIN

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' ', SubSubSubSubCuenta, ' ', S5, ' ', S6, ' ',  s7, ' ',  s8, ' 0000', ' 0000') AS Cuentastr
,'        ' AS EspaciosNivel, '09' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta,  SubSubSubSubCuenta, S5,S6, s7, s8, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes,CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' ', SubSubSubSubCuenta, ' ', S5, ' ', S6, ' ',  s7, ' 0000', ' 0000', ' 0000') AS Cuentastr
,'       ' AS EspaciosNivel, '08' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, S6, s7, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes,CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' ', SubSubSubSubCuenta, ' ', S5, ' ', S6,  ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'      ' AS EspaciosNivel, '07' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, S6, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' ', SubSubSubSubCuenta, ' ', S5, ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'     ' AS EspaciosNivel, '06' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta,  ' ', SubSubSubSubCuenta, ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'    ' AS EspaciosNivel, '05' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'   ' AS EspaciosNivel, '04' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'  ' AS EspaciosNivel, '03' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' 0', ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,' ' AS EspaciosNivel, '02' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' 0', ' 0', ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'' EspaciosNivel, '01' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, FechaCreacion;

END
ELSE IF @p_nivel = 8 BEGIN

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes,CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' ', SubSubSubSubCuenta, ' ', S5, ' ', S6, ' ',  s7, ' 0000', ' 0000', ' 0000') AS Cuentastr
,'       ' AS EspaciosNivel, '08' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, S6, s7, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes,CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' ', SubSubSubSubCuenta, ' ', S5, ' ', S6,  ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'      ' AS EspaciosNivel, '07' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, S6, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' ', SubSubSubSubCuenta, ' ', S5, ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'     ' AS EspaciosNivel, '06' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta,  ' ', SubSubSubSubCuenta, ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'    ' AS EspaciosNivel, '05' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'   ' AS EspaciosNivel, '04' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'  ' AS EspaciosNivel, '03' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' 0', ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,' ' AS EspaciosNivel, '02' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' 0', ' 0', ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'' EspaciosNivel, '01' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, FechaCreacion;

END
ELSE IF @p_nivel = 7 BEGIN

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes,CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' ', SubSubSubSubCuenta, ' ', S5, ' ', S6,  ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'      ' AS EspaciosNivel, '07' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, S6, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' ', SubSubSubSubCuenta, ' ', S5, ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'     ' AS EspaciosNivel, '06' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta,  ' ', SubSubSubSubCuenta, ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'    ' AS EspaciosNivel, '05' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'   ' AS EspaciosNivel, '04' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'  ' AS EspaciosNivel, '03' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' 0', ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,' ' AS EspaciosNivel, '02' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' 0', ' 0', ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'' EspaciosNivel, '01' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, FechaCreacion;

END
ELSE IF @p_nivel = 6 BEGIN

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' ', SubSubSubSubCuenta, ' ', S5, ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'     ' AS EspaciosNivel, '06' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, S5, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta,  ' ', SubSubSubSubCuenta, ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'    ' AS EspaciosNivel, '05' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'   ' AS EspaciosNivel, '04' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'  ' AS EspaciosNivel, '03' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' 0', ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,' ' AS EspaciosNivel, '02' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' 0', ' 0', ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'' EspaciosNivel, '01' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, FechaCreacion;
END

ELSE IF @p_nivel = 5 BEGIN

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta,  ' ', SubSubSubSubCuenta, ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'    ' AS EspaciosNivel, '05' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'   ' AS EspaciosNivel, '04' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'  ' AS EspaciosNivel, '03' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' 0', ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,' ' AS EspaciosNivel, '02' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' 0', ' 0', ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'' EspaciosNivel, '01' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, FechaCreacion;

END
ELSE IF @p_nivel = 4 BEGIN

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' ', SubSubSubCuenta, ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'   ' AS EspaciosNivel, '04' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'  ' AS EspaciosNivel, '03' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' 0', ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,' ' AS EspaciosNivel, '02' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' 0', ' 0', ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'' EspaciosNivel, '01' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, FechaCreacion;

END
ELSE IF @p_nivel = 3 BEGIN

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' ', SubSubCuenta, ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'  ' AS EspaciosNivel, '03' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, SubSubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' 0', ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,' ' AS EspaciosNivel, '02' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' 0', ' 0', ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'' EspaciosNivel, '01' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, FechaCreacion;

END
ELSE IF @p_nivel = 2 BEGIN

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' ', SubCuenta, ' 0', ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,' ' AS EspaciosNivel, '02' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, SubCuenta, FechaCreacion;

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' 0', ' 0', ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'' EspaciosNivel, '01' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, FechaCreacion;


END
ELSE IF @p_nivel = 1 BEGIN

INSERT INTO #tmp_balanza_Agrup2 (FKIdAnio_SIS, FKIdMes_SIS,  Anio, Mes, Cuentastr, EspaciosNivel, Nivel, SaldoInicial, Cargos, Abonos, SaldoFinal, FechaCreacion)
SELECT FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, CONCAT( Cuenta, ' 0', ' 0', ' 0', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000', ' 0000') AS Cuentastr
,'' EspaciosNivel, '01' AS Nivel
,SUM(SaldoInicial) AS SaldoInicial, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(SaldoFinal) AS SaldoFinal, FechaCreacion
FROM #tmp_balanza_Agrup
GROUP BY FKIdAnio_SIS, FKIdMes_SIS, Anio, Mes, Cuenta, FechaCreacion;

END

--ELSE BEGIN

--  SELECT * FROM #tmp_balanza_Agrup;

--END

 SELECT
		ba2.FKIdAnio_SIS,
		ba2.FKIdMes_SIS,  
		ba2.Anio,
		ba2.Mes,
		CONCAT(EspaciosNivel, ba2.Cuentastr) as Cuenta,
		EspaciosNivel COLLATE Modern_Spanish_CI_AS + CASE WHEN vc.Nombre IS NULL THEN  'Configurar cuenta agrupadora' ELSE vc.Nombre END,
		ba2.SaldoInicial,
		ba2.Cargos,
		ba2.Abonos,
		ba2.SaldoFinal,
		ba2.FechaCreacion,
		@p_nivel nivel,
		YEAR(@p_FechaInicio) anio,
		UPPER(FORMAT(@p_FechaInicio, 'MMMM', 'es-ES')) AS NombreMes ,
		CONVERT(VARCHAR, @p_FechaFin, 103) FEcha

 FROM #tmp_balanza_Agrup2 ba2
 LEFT JOIN CONTA.VW_CUENTAS vc ON vc.ClaveOrd COLLATE Modern_Spanish_CI_AS = TRIM(' ' FROM ba2.Cuentastr) COLLATE Modern_Spanish_CI_AS
ORDER BY ba2.CuentaStr, Nivel;


END;

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_InventariosdeBienes]';
GO
-- exec [CONTA].[SPR_InventariosdeBienes] '','2025-09-28'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_InventariosdeBienes]

@p_FecInicio nvarchar(24),
@p_FecFin nvarchar(24)
AS
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

DECLARE @FechaInicio DATE = @p_FecInicio, @FechaFin DATE = @p_FecFin

	SELECT bn.PK_IdBien AS Id
      ,bn.Clave AS NInventario
      ,bn.Descripcion AS [S/PG]
	  ,1 as [CANTIDAD]
	  ,Un.Descripcion as [UM]
      ,bn.Costo AS [CU]
	  , bn.Costo * 1  as [MONTO]
      --,bn.ValorRescate
      --,bn.ValorActual
	  , Titulo = CAST(CONCAT('AL ', UPPER(FORMAT(@FechaFin, 'dd \DE MMMM \DEL yyyy', 'es-MX'))) AS NVARCHAR(128))
  FROM [SICOP].[VW_Bien] Bn
  JOIN SICOP.TipoBien TB ON Bn.FK_IdTipoBien__SICOP = TB.PK_IdTipoBien
  JOIN ALMA.Unidades Un ON Tb.FK_IdUnidades_Equivalente = Un.PK_IdUnidades
  ORDER BY Bn.Clave
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_InventariosdeMaterias]';
GO
-- exec [CONTA].[SPR_InventariosdeMaterias] '','2025-09-29'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_InventariosdeMaterias]

@p_FecInicio nvarchar(24),
@p_FecFin nvarchar(24)
AS
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;


DECLARE @FechaInicio DATE = @p_FecInicio, @FechaFin DATE = @p_FecFin

		, @titulo Varchar(60) 
		
		SET @titulo = (SELECT 'Al: ' + FORMAT(@FechaFin, 'dd \DE MMMM \DEL yyyy', 'es-MX'))


		
SET LANGUAGE 'español';
			---***********************
			WITH Existencias   -- @Tabla que agrupa, sumariza las existencias
				AS (			

						SELECT TB.PK_IdTipoBien
						, TB.FK_IdPartida__SIS
						, GB.CLAVE_CUCOP AS CUCOP
						,  GB.CABM_ACT + ' / ' + GB.ClaveAN  AS CABMS
						,   TB.CodigoClave
						, TB.Descripcion
						, SUM(aa.Cantidad) AS Existencias
						, au.Descripcion AS Unidades
						, aa.FKIdAnio_SIS, CAST('' AS VARCHAR(MAX)) AS Message
						, IIF(TB.Cantidad_Equivalente > 1,TB.FK_IdUnidades_Equivalente,TB.FK_IdUnidades__ALMA) AS FK_IdUnidades__ALMA
						,aa.Costo AS CostoUnitario  -- Llenar en el stript desde el costo de factura
						,aa.Costo AS CostoPromedio  -- Calcular
						FROM     ALMA.Almacen AS aa 
								INNER JOIN SICOP.TipoBien AS TB ON aa.FK_IdTipoBien__SICOP = TB.PK_IdTipoBien 
								INNER JOIN ALMA.Unidades AS au ON IIF(TB.Cantidad_Equivalente > 1,TB.FK_IdUnidades_Equivalente,TB.FK_IdUnidades__ALMA) = au.PK_IdUnidades 
								INNER JOIN SICOP.GrupoBien as GB ON TB.FK_IdGrupoBien__SICOP = GB.PK_IdGrupoBien
						WHERE aa.InventarioCerrado = 0 AND AA.Activo = 1 AND TB.Activo = 1 AND AU.Activo = 1 AND GB.Activo = 1
						GROUP BY TB.PK_IdTipoBien, TB.FK_IdPartida__SIS,  GB.CLAVE_CUCOP,  GB.CABM_ACT, GB.ClaveAN, TB.CodigoClave, TB.Descripcion, au.Descripcion, aa.FKIdAnio_SIS, IIF(TB.Cantidad_Equivalente > 1,TB.FK_IdUnidades_Equivalente,TB.FK_IdUnidades__ALMA), aa.Costo

						UNION ALL 

						SELECT TB.PK_IdTipoBien, TB.FK_IdPartida__SIS
							, GB.CLAVE_CUCOP AS CUCOP
							, GB.CABM_ACT + ' / ' + GB.ClaveAN  AS CABMS
							, TB.CodigoClave
							, TB.Descripcion
							, CI.Existencias
							, AU.Descripcion AS Unidades
							, CI.FKIdAnio_SIS
							, '' AS Message	
							, IIF(TB.Cantidad_Equivalente > 1, TB.FK_IdUnidades_Equivalente,TB.FK_IdUnidades__ALMA) AS FK_IdUnidades__ALMA
							, CI.CostoExistencias  -- TODO  Cambiar a CostoUnitario despues de la magia de Alex
							, CI.CostoPromedioEntradasMes
						FROM     SICOP.TipoBien AS TB 
								INNER JOIN SICOP.GrupoBien GB ON TB.FK_IdGrupoBien__SICOP = GB.PK_IdGrupoBien
								INNER JOIN ALMA.Unidades AS AU ON IIF(TB.Cantidad_Equivalente > 1,TB.FK_IdUnidades_Equivalente,TB.FK_IdUnidades__ALMA) = AU.PK_IdUnidades 
								RIGHT OUTER JOIN ALMA.CierreInventario AS CI ON TB.PK_IdTipoBien = CI.FK_IdTipoBien__SICOP
						WHERE TB.Activo = 1 AND GB.Activo = 1 AND AU.Activo = 1 AND CI.Activo = 1
				)	

				SELECT	E.[PK_IdTipoBien] AS id,
					ISNULL(CC.ClaveNombre, 'Configure Cuenta') as CODIGO,
					-- E.[FK_IdPartida__SIS],
					-- E.[CUCOP],
					-- E.[CABMS],
					-- E.[CodigoClave],
					E.[Descripcion]  [S/PG],
					SUM(E.[Existencias]) AS CANTIDAD,
					E.[Unidades] AS UM,
					-- 0 [FKIdAnio_SIS] ,
					--E.FK_IdUnidades__ALMA,
					isnull(MAX(E.CostoPromedio),0) AS CU,  --TODO Revisar estas formulas  ROG 20250525
					SUM(E.[Existencias]) * isnull(MAX(E.CostoPromedio),0) AS MONTO
					into #tlbAlmacéndeMateriales
				FROM Existencias E 
				JOIN SICOP.TipoBien TB ON E.PK_IdTipoBien = TB.PK_IdTipoBien
				LEFT JOIN CONTA.VW_CUENTAS CC ON TB.FKIdCuentaContable_CONTA = CC.Pk_IdCuenta
				WHERE TB.Activo = 1
				GROUP BY 
					CC.ClaveNombre,
					E.[PK_IdTipoBien],
					E.[FK_IdPartida__SIS],
					E.[CUCOP],
					E.[CABMS],
					E.[CodigoClave],
					E.[Descripcion] ,
					E.[Unidades],
					--E.[FKIdAnio_SIS],
					TB.ExistenciaMinima, 
					TB.ExistenciaMaxima,
					E.FK_IdUnidades__ALMA




	select * , titulo = @titulo   --'AL 31 DE DICIEMBRE DE ' + CAST(@Anio AS varchar(4))
	from #tlbAlmacéndeMateriales
	--FIN

END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_LibroDiario]';
GO
--exec [CONTA].[SPR_LibroDiario] '2025-09-24','2025-09-24'

CREATE OR ALTER PROCEDURE [CONTA].[SPR_LibroDiario]
(
@p_FechaInicio2 nvarchar(24),
@p_FechaFin2 nvarchar(24)
)
AS
BEGIN
SET NOCOUNT ON;    

DECLARE @p_FechaInicio DATE = @p_FechaInicio2, @p_FechaFin DATE = @p_FechaFin2

;WITH mireporte(Fecha
, NumEvento
, Asiento
, DocumentoFuente
, ContableCodigo
, ContableNombre
, PresupuestalCodigo
, PresupuestalNombre
, Descripcion
, ImporteDebe
, ImporteHaber
)
AS
(SELECT
cp.FechaPoliza AS Fecha
, row_number() over(order by cp.PKIdPoliza) AS NumEvento
, cp.ClavePoliza As Asiento
, CONCAT( ' ', case
when cp.FKIdTipoPoliza_SIS = 1 then 'Dr'
when cp.FKIdTipoPoliza_SIS = 2 then 'Eg'
when cp.FKIdTipoPoliza_SIS = 3 then 'Ig'
when cp.FKIdTipoPoliza_SIS = 4 then 'Pr'
end
, cp.ClavePoliza) as DocumentoFuente

, Case When LEFT (vcc.ClaveOrd, 1) <> '8' Then vcc.ClaveOrd  end AS ContableCodigo
, Case When LEFT (vcc.ClaveOrd, 1) <> '8' Then vcc.Nombre end AS ContableNombre
, Case When LEFT (vcc.ClaveOrd, 1) = '8' Then vcc.ClaveOrd end AS PresupuestalCodigo
, Case When LEFT (vcc.ClaveOrd, 1) = '8' Then vcc.Nombre end AS PresupuestalNombre
, cdp.Descripcion

, cdp.ImporteDebe
, cdp.ImporteHaber
FROM CONTA.Poliza cp
JOIN CONTA.PolizaDetalle cdp ON cp.PKIdPoliza = cdp.FKIdPoliza_CONTA
JOIN CONTA.VW_CUENTAS vcc on cdp.FKIdCuentaContable_CONTA = vcc.Pk_IdCuenta
WHERE cp.FechaPoliza >= @p_FechaInicio and cp.FechaPoliza < DATEADD(DAY, 1, @p_FechaFin)
)
--RESULTADO

SELECT Fecha=convert(nvarchar,Fecha,103 )
, NumEvento
, Asiento
, DocumentoFuente
, ContableCodigo
, ContableNombre
, PresupuestalCodigo
, PresupuestalNombre
, Descripcion
, CONCAT('$ ', FORMAT(CAST(ImporteDebe AS decimal(18, 2)), 'N2')) AS ImporteDebe
, CONCAT('$ ', FORMAT(CAST(ImporteHaber AS decimal(18, 2)), 'N2')) AS ImporteHaber
, Titulo = 'DEL ' + 
       FORMAT(@p_FechaInicio, 'dd \de MMMM \del yyyy', 'es-MX') + 
       ' AL ' + 
       FORMAT(@p_FechaFin, 'dd \de MMMM \del yyyy', 'es-MX')
FROM mireporte



END;

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_LibroMayor]';
GO
--exec [CONTA].[SPR_LibroMayor] '2024-01-01','2024-01-30' ,268281, 0

CREATE OR ALTER PROCEDURE [CONTA].[SPR_LibroMayor]
	@p_FecInicio nvarchar(24), -- = '20250101', 
	@p_FecFin nvarchar(24),-- = '20250131', 
	@NumCuenta int,			-- = 266465
	@EsCierre INT			-- = 0
as
begin
set fmtonly off;

	declare @sqlResult nvarchar(max);

	DECLARE @FechaInicio datetime = @p_FecInicio,	-- = '20250101', 
	@FechaFin datetime	= @p_FecFin	-- = '20250131', 

	declare @Mes_Inicio int = month(@FechaInicio)
	declare @Mes_Fin int = month(@FechaFin)
	declare @FKIdAnio_SIS int = (select [PKIdAnio] from [SIS].[Anio] where [Clave] = year(@FechaInicio));
	declare @Fk_IdMes__SIS_Anterior  int = @Mes_Inicio - 1;
	declare @Fk_IdAnio__SIS_Anterior int = @FKIdAnio_SIS - 1;


	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepLibroMayor'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')


	if @EsCierre = 1
	begin
		set @Mes_Inicio = 13;
		set @Mes_Fin = 13;
	end

--=============================================
--	Saldo inicial de la cuenta
	
	create table #SaldoInicial (SaldoFinal decimal(18, 2))
	set @sqlResult = 'select isnull([SaldoFinal], 0) as SaldoFinal
					  from CONTA.SaldoMensual
					  where FKIdCuentaContable = ' + cast(@NumCuenta as varchar)
	
	if @Mes_Inicio = 1 
	begin
		set @sqlResult = @sqlResult + ' and [FKIdMes_SIS] = 13
					                    and [FKIdAnio_SIS] = ' + cast(@Fk_IdAnio__SIS_Anterior as varchar)
	end
	else begin
		set @sqlResult = @sqlResult + ' and [FKIdMes_SIS] = ' + cast(@Fk_IdMes__SIS_Anterior as varchar) +  
					                  ' and [FKIdAnio_SIS] =  ' + cast(@FKIdAnio_SIS as varchar); 
	end

	insert into #SaldoInicial exec sp_executesql @sqlResult;

--=============================================
	select row_number() over(order by p.PKIdPoliza, dp.PKIdPolizaDetalle) num, --TODO Check th
		p.PKIdPoliza,
		dp.PKIdPolizaDetalle,
		cc.TipoCuenta,
		cc.Pk_IdCuenta,
		IniPeriodo  = [dbo].[FechaMesNumeroToFechaMesNombre](convert(varchar,@FechaInicio,112),0),
		FinPeriodo  = [dbo].[FechaMesNumeroToFechaMesNombre](convert(varchar,@FechaFin,112   ),0),
		FechaActual = [dbo].[FechaMesNumeroToFechaMesNombre](convert(varchar,getdate(),112   ),1),
		cc.ClaveOrd Cuenta,
		cc.Nombre as  NombrePoliza,  --TODO check Name
		p.ClavePoliza,
		TipoPoliza = (case when FKIdTipoPoliza_SIS = 1 then 'Dr'
						   when FKIdTipoPoliza_SIS = 2 then 'Eg'
						   when FKIdTipoPoliza_SIS = 3 then 'Ig'
						   when FKIdTipoPoliza_SIS = 4 then 'Pr' end),
		convert(varchar,p.FechaPoliza,103)+' '+dp.Descripcion ConceptoMovimiento,
		SaldoInicial = isnull((select [SaldoFinal] from #SaldoInicial), 0),
		/*SaldoInicial = case when month(@FechaInicio) = 1 and cc.Cuenta = 4 then 0.00
		                    when month(@FechaInicio) = 1 and cc.Cuenta = 5 then 0.00
							when month(@FechaInicio) = 1 and cc.Cuenta = 8 then 0.00 
							else isnull((select [SaldoFinal] from #SaldoInicial), 0) end,*/
		dp.ImporteDebe Cargos,
		dp.ImporteHaber Abonos,
		Saldos = dp.ImporteDebe,
		TotalSaldos = '',
		totalCargos = (select sum(ImporteDebe) 
		               from CONTA.PolizaDetalle dp inner join conta.Poliza p on dp.FKIdPoliza_CONTA = p.PKIdPoliza 
							inner join CONTA.VW_CUENTAS cc on dp.FKIdCuentaContable_CONTA = cc.Pk_IdCuenta
					   where cc.Pk_IdCuenta = @NumCuenta
					   and FechaPoliza between @FechaInicio and @FechaFin
					   and p.FKIdMes_SIS between @Mes_Inicio and @Mes_Fin
					   and p.Activo = 1),
		totalAbonos = (select sum(ImporteHaber) from CONTA.PolizaDetalle dp inner join conta.Poliza p on dp.FKIdPoliza_CONTA = p.PKIdPoliza 
									  inner join CONTA.VW_CUENTAS cc on dp.FKIdCuentaContable_CONTA = cc.Pk_IdCuenta
								where cc.Pk_IdCuenta  = @NumCuenta
								and FechaPoliza between @FechaInicio and @FechaFin
								and p.FKIdMes_SIS between @Mes_Inicio and @Mes_Fin
								and p.Activo = 1 ),
	fechaPoliza = convert(varchar,p.FechaPoliza,103),
	concepto=dp.Descripcion 
	into #tmp
	from CONTA.PolizaDetalle dp inner join conta.Poliza p on dp.FKIdPoliza_CONTA = p.PKIdPoliza 
									  inner join CONTA.VW_CUENTAS cc on dp.FKIdCuentaContable_CONTA = cc.Pk_IdCuenta
	where cc.Pk_IdCuenta = @NumCuenta
	and FechaPoliza between @FechaInicio and @FechaFin
	and FKIdMes_SIS between @Mes_Inicio and @Mes_Fin
	and p.Activo = 1
	order by cc.ClaveOrd, FechaPoliza

	-- 1 Acredora
	-- 2 Deudora

	update #tmp
	set Saldos = case when TipoCuenta = 1 then SaldoInicial - Cargos + Abonos
	                  when TipoCuenta = 2 then SaldoInicial + Cargos - Abonos
				end
	where #tmp.num = 1

	declare @TotalRegistros int = (select count(num) from #tmp);
	declare @Indice int = 2
	declare @SaldoInicial decimal(18, 2) = (select Saldos from #tmp where num = 1)
	declare @totalSaldos decimal(18, 2);

	while @Indice <= @TotalRegistros
	begin
		update #tmp
		set Saldos = case when TipoCuenta = 1 then @SaldoInicial - Cargos + Abonos
		                  when TipoCuenta = 2 then @SaldoInicial + Cargos - Abonos
					 end
		where #tmp.num = @Indice

		set @SaldoInicial  = (select Saldos from #tmp where num = @Indice)
		set @Indice = @Indice + 1 
	end

	select * ,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('DEL ' , FORMAT(@FechaInicio, 'dd \de MMMM \del yyyy', 'es-MX') , ' AL ' ,  FORMAT(@FechaFin, 'dd \de MMMM \del yyyy', 'es-MX')) AS NVARCHAR(128))
	from #tmp

-- ====================
-- Se elimina la tabla temporal:
	drop table #SaldoInicial, #tmp;
end

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepActFijos]';
GO
-- exec [CONTA].[SPR_RepActFijos] '2025-05-01'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepActFijos]
	  @p_FecInicio nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	DECLARE @p_FechaInicio DATE = @p_FecInicio
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepLibroInventarioBienes'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	SELECT --bn.PK_IdBien
      --,bn.FK_IdTipoBien__SICOP
	  --,TB.CodigoClave
      bn.Clave AS Codigo
      ,bn.Descripcion
	 -- ,1 as Cantidad
	 -- ,Un.Descripcion as Unidades
      ,bn.Costo AS Valor
	  --, bn.Costo * 1  as Monto
      --,bn.ValorRescate
      --,bn.ValorActual
		,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('AL ', UPPER(FORMAT(@p_FechaInicio, 'dd \DE MMMM \DEL yyyy', 'es-MX'))) AS NVARCHAR(128))
  FROM [SICOP].[VW_Bien] Bn
  JOIN SICOP.TipoBien TB ON Bn.FK_IdTipoBien__SICOP = TB.PK_IdTipoBien
  JOIN ALMA.Unidades Un ON Tb.FK_IdUnidades_Equivalente = Un.PK_IdUnidades
  ORDER BY Bn.Clave
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepAnaActi]';
GO
-- exec [Conta].[SPR_RepAnaActi] '',''
CREATE OR ALTER PROCEDURE [Conta].[SPR_RepAnaActi]
	 @p_FecInicio nvarchar(24),
	@p_FecFin nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	

	DECLARE @FechaInicio DATE = @p_FecInicio, @FechaFin DATE = @p_FecFin

	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepAnaActi'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	SELECT id=1,Concepto = CAST('Activo' as nvarchar(500)), [SI] = '$ 2,222,891,419.00 ', [CP] = '$ 11,960.00 ', [AP] = '$ 0.00', [SF] = '$ 2,222,903,379.00', [VP] = ''
	into #tlbRepAnaActiv
	UNION
	SELECT id=2,Concepto = 'Activo Circulante ', [SI] = '$ 2,222,891,419.00', [CP] = '$ 11,960.00', [AP] = '$ 0.00', [SF] = '$ 2,222,903,379.00', [VP] = '$ 11,960.00'
	UNION
	SELECT id=3,Concepto = 'Efectivo y Equivalentes', [SI] = '$ 149,981,834.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ 149,981,834.00', [VP] = '$ 0.00'
	UNION
	SELECT id=4,Concepto = 'Derechos a Recibir Efectivo o Equivalentes', [SI] = '$ 2,336,111,208.00', [CP] = '$ 11,960.00', [AP] = '$ 0.00', [SF] = '$ 2,336,123,168.00', [VP] = '$ 11,960.00'
	UNION
	SELECT id=5,Concepto = 'Derechos a Recibir Bienes o Servicios', [SI] = '$ 0.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ 0.00', [VP] = '$ 0.00'
	UNION
	SELECT id=6,Concepto = 'Inventarios', [SI] = '$ 0.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ 0.00', [VP] = '$ 0.00'
	UNION
	SELECT id=7,Concepto = 'Almacenes', [SI] = '$ 650,258.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ 650,258.00', [VP] = '$ 0.00'
	UNION
	SELECT id=8,Concepto = 'Estimación por Pérdida o Deterioro de Activos Circulantes', [SI] = '$ -263,851,881.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ -263,851,881.00', [VP] = '$ 0.00'
	UNION
	SELECT id=9,Concepto = 'Otros Activos Circulantes', [SI] = '$ 0.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ 0.00', [VP] = '$ 0.00'
	--
	UNION
	SELECT id=10,Concepto = 'ACTIVOS NO CIRCULANTES', [SI] = '', [CP] = '', [AP] = '', [SF] = '', [VP] = ''
	--
	UNION
	SELECT id=11,Concepto = 'Inversiones Financieras a Largo Plazo', [SI] = '$ 0.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ 0.00', [VP] = '$ 0.00'
	UNION
	SELECT id=12,Concepto = 'Derechos a Recibir Efectivo o Equivalentes a Largo Plazo', [SI] = '$ 0.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ 0.00', [VP] = '$ 0.00'
	UNION
	SELECT id=13,Concepto = 'Bienes Inmuebles, Infraestructura y Construcciones en Proceso', [SI] = '', [CP] = '', [AP] = '', [SF] = '', [VP] = ''
	UNION
	--
	SELECT id=14,Concepto = 'Bienes Muebles', [SI] = '$ 7,162,122.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ 7,162,122.00', [VP] = '$ 0.00'
	UNION
	SELECT id=15,Concepto = 'Activos Intangibles', [SI] = '$ 2,541,228.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ 2,541,228.00', [VP] = '$ 0.00'
	UNION
	SELECT id=16,Concepto = 'Depreciación, Deterioro y Amortización Acumulada de Bienes', [SI] = '$ -5,934,956.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ -5,934,956.00', [VP] = '$ 0.00'
	UNION
	SELECT id=17,Concepto = 'Activos Diferidos', [SI] = '$ 0.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ 0.00', [VP] = '$ 0.00'
	UNION
	SELECT id=18,Concepto = 'Estimación por Pérdida o Deterioro de Activos No Circulantes', [SI] = '$ 0.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ 0.00', [VP] = '$ 0.00'
	UNION
	SELECT id=19,Concepto = 'Otros Activos no Circulantes', [SI] = '$ 0.00', [CP] = '$ 0.00', [AP] = '$ 0.00', [SF] = '$ 0.00', [VP] = '$ 0.00'
	
	SELECT *
		,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('DEL ' , FORMAT(@FechaInicio, 'dd \de MMMM \del yyyy', 'es-MX') , ' AL ' ,  FORMAT(@FechaFin, 'dd \de MMMM \del yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tlbRepAnaActiv

	--FIN
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepAnalisSaldosCuPa]';
GO
-- exec [CONTA].[SPR_RepAnalisSaldosCuPa] '2025-07-31'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepAnalisSaldosCuPa]
	  @p_FecInicio nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepAnalisSaldosCuPa'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	
	SELECT ID, [nocuenta], [nomdeno], [saldo],  [fechaemi], 30 AS [diasplazo], DATEADD(dd, 30, [fechaemi]) AS  [fechaven],  [diasvencidos], [rango01], [rango31], [rango61], [rango90mas], [motivo]
	INTO #tblRepAnalisSaldosCuPa
	FROM PRES.[VW_FacturasPendientesPago]

	--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('AL ' , FORMAT(@p_FechaInicio, 'dd \DE MMMM \DEL yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tblRepAnalisSaldosCuPa
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepAntigSaldosCuPa]';
GO
-- exec [CONTA].[SPR_RepAntigSaldosCuPa] '2025-07-31'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepAntigSaldosCuPa]
	  @p_FecInicio nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepAntigSaldosCuPa'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	
	SELECT ID, [nocuenta], [nomdeno], [saldo], [fechaemi], [diasvencidos], [rango01], [rango31], [rango61], [rango90mas]
	INTO #tblRepAntigSaldosCuPa
	FROM PRES.[VW_FacturasPendientesPago]
	--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('AL ' , FORMAT(@p_FechaInicio, 'dd \DE MMMM \DEL yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tblRepAntigSaldosCuPa
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepArtFaltporSurtir]';
GO
-- exec [CONTA].[SPR_RepArtFaltporSurtir] '2025-07-01','2025-07-31'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepArtFaltporSurtir]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepArtFaltporSurtir'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	SELECT [PK_IdDetalleOrdenCompra] AS ID
      ,[FK_IdPartida__SIS] AS [PP]
      ,[CodigoClave] AS [cabmsdf]
      ,[Bien] AS [concepto]
      --,[Cantidad]
      --,[PrecioUnitario]
      --,[Subtotal]
      --,[Recibidos]
      ,[Pendientes] AS [exissurtir]
      --,[Estado]
      --,[FK_IdDetalleRequisicion__ORCO]
      --,[FK_IdTipoBien__SICOP]
      --,[FK_IdOrdenCompra__ORCO]
      --,[Unidades]
      --,[TIPO]
      --,[Color]
      --,[Cantidad_Equivalente]
      --,[FK_IdUnidades_Equivalente]
  INTO #tblRepArtFaltporSurtir
  FROM [BD_IFT].[ORCO].[VW_DetalleOrdenCompra]


	--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('PERIODO DEL ' , FORMAT(@p_FechaInicio, 'dd \de MMMM \del yyyy', 'es-MX') , ' AL ' ,  FORMAT(@p_FechaFin, 'dd \de MMMM \del yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tblRepArtFaltporSurtir
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepAuxiliares]';
GO
/*
select * from sis.Pantalla where Nombre like '%auxili%'
~/ReporteAuxConta
exec [CONTA].[SPR_RepAuxiliares] '2024-01-01', '2024-01-30', 259568
*/
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepAuxiliares]
(
   @p_FecInicio nvarchar(24), -- = '20250101', 
	@p_FecFin nvarchar(24),-- = '20250131', 
    @p_Fk_ICuentaContable INT
)
AS
BEGIN
    SET NOCOUNT ON;


	DECLARE @p_FechaInicio DATETIME2(3) = @p_FecInicio, 
    @p_FechaFin DATETIME2(3) = @p_FecFin

    DECLARE @v_Mes_Inicio INT;
    --DECLARE @v_Mes_Fin INT;
    DECLARE @v_Fk_IdAnio__SIS INT;
    DECLARE @v_FK_IdMesAnterior INT;
    DECLARE @v_FK_IdAnioAnterior INT;
   -- DECLARE @v_TotalRegistros INT;
    DECLARE @v_Indice INT;
    DECLARE @v_SaldoInicial DECIMAL(18, 2);
    --DECLARE @v_Fk_ICuentaContable INT;

	-- Se configura el mes año anterior 
    SET @v_Mes_Inicio = MONTH(@p_FechaInicio);
    --SET @v_Mes_Fin = MONTH(@p_FechaFin);    
    SELECT @v_Fk_IdAnio__SIS = YEAR(@p_FechaInicio);
	
	SET @v_FK_IdMesAnterior = (CASE WHEN @v_Mes_Inicio = 1 THEN 13 ELSE @v_Mes_Inicio - 1 END);

	SET @v_FK_IdAnioAnterior = (CASE WHEN @v_Mes_Inicio = 1  THEN @v_Fk_IdAnio__SIS - 1 ELSE @v_Fk_IdAnio__SIS  END);


    -- Drop temp table if it exists
    IF OBJECT_ID('tempdb..#tmp_saldoInicial') IS NOT NULL DROP TABLE #tmp_saldoInicial;

    -- Create temp table
    CREATE TABLE #tmp_saldoInicial (SaldoFinal DECIMAL(18, 2));

    -- Insert saldo inicial
    INSERT INTO #tmp_saldoInicial (SaldoFinal)
    SELECT ISNULL(SaldoFinal, 0)
    FROM CONTA.SaldoMensual
    WHERE FKIdCuentaContable = @p_Fk_ICuentaContable
    AND (
        ( FKIdMes_SIS = @v_FK_IdMesAnterior
         
        AND FKIdAnio_SIS = @v_FK_IdAnioAnterior)
    );
	
	--DEBUG 
	--SELECT * FROM #tmp_saldoInicial

    -- Drop temp table if it exists
    IF OBJECT_ID('tempdb..#tmp_data') IS NOT NULL DROP TABLE #tmp_data;

    -- Create temp table
    CREATE TABLE #tmp_data (
        Num INT IDENTITY(1,1),
        PKIdPoliza INT,
        PKIdPolizaDetalle INT,
        FKIdTipoCuenta_CONTA INT,
        PKIdCuentaContable INT,
        IniPeriodo NVARCHAR(50),
        FinPeriodo NVARCHAR(50),
        FechaActual NVARCHAR(50),
        Cuenta NVARCHAR(250),
        NombrePoliza NVARCHAR(250),
        ClavePoliza NVARCHAR(250),
        TipoPoliza NVARCHAR(50),
        ConceptoMovimiento NVARCHAR(500),
        SaldoInicial DECIMAL(20, 2),
        Cargos DECIMAL(20, 2),
        Abonos DECIMAL(20, 2),
        Saldos DECIMAL(20, 2),
        TotalSaldos NVARCHAR(250),
        totalCargos DECIMAL(20, 2),
        totalAbonos DECIMAL(20, 2)
    );

    -- Insert data
    INSERT INTO #tmp_data (
        PKIdPoliza, PKIdPolizaDetalle, FKIdTipoCuenta_CONTA, PKIdCuentaContable,
        IniPeriodo, FinPeriodo, FechaActual, Cuenta, NombrePoliza, ClavePoliza, TipoPoliza,
        ConceptoMovimiento, SaldoInicial, Cargos, Abonos, Saldos, TotalSaldos, totalCargos, totalAbonos
    )
    SELECT  
        p.PKIdPoliza, dp.PKIdPolizaDetalle, cc.TipoCuenta, cc.Pk_IdCuenta,
        FORMAT(@p_FechaInicio, 'MMMM yyyy') AS IniPeriodo,
        FORMAT(@p_FechaFin, 'MMMM yyyy') AS FinPeriodo,
        FORMAT(GETDATE(), 'dd/MM/yyyy') AS FechaActual,
        cc.ClaveNombre AS Cuenta, p.NombrePoliza, p.ClavePoliza,
        CASE 
            WHEN FKIdTipoPoliza_SIS = 1 THEN 'Dr'
            WHEN FKIdTipoPoliza_SIS = 2 THEN 'Eg'
            WHEN FKIdTipoPoliza_SIS = 3 THEN 'Ig'
            WHEN FKIdTipoPoliza_SIS = 4 THEN 'Pr'
        END AS TipoPoliza,
        FORMAT(p.FechaPoliza, 'dd/MM/yyyy') + ' ' + dp.Descripcion AS ConceptoMovimiento,
        ISNULL((SELECT SaldoFinal FROM #tmp_saldoInicial), 0) AS SaldoInicial,
        dp.ImporteDebe AS Cargos, dp.ImporteHaber AS Abonos,
        dp.ImporteDebe AS Saldos, '' AS TotalSaldos,
        (SELECT SUM(ImporteDebe) FROM CONTA.PolizaDetalle dp 
         INNER JOIN CONTA.Poliza p ON dp.FKIdPoliza_CONTA = p.PKIdPoliza 
         WHERE p.FechaPoliza BETWEEN @p_FechaInicio AND @p_FechaFin
         AND dp.FKIdCuentaContable_CONTA = @p_Fk_ICuentaContable) AS totalCargos,
        (SELECT SUM(ImporteHaber) FROM CONTA.PolizaDetalle dp 
         INNER JOIN CONTA.Poliza p ON dp.FKIdPoliza_CONTA = p.PKIdPoliza 
         WHERE p.FechaPoliza BETWEEN @p_FechaInicio AND @p_FechaFin
         AND dp.FKIdCuentaContable_CONTA = @p_Fk_ICuentaContable) AS totalAbonos
    FROM CONTA.PolizaDetalle dp 
    INNER JOIN CONTA.Poliza p ON dp.FKIdPoliza_CONTA = p.PKIdPoliza 
    INNER JOIN CONTA.VW_CUENTAS cc ON dp.FKIdCuentaContable_CONTA = cc.Pk_IdCuenta
    WHERE cc.Pk_IdCuenta = @p_Fk_ICuentaContable
    AND p.FechaPoliza BETWEEN @p_FechaInicio AND @p_FechaFin
	AND dp.Activo = 1 AND p.Activo = 1 ;

	--DEBUG
	--SELECT * from #tmp_data

    -- Update saldo calculation
    DECLARE @v_Saldo DECIMAL(20, 2),
			@v_Cargo DECIMAL(20, 2), 
			@v_Abono DECIMAL(20, 2);
    DECLARE c CURSOR FOR 
    SELECT Num, SaldoInicial, Cargos, Abonos  FROM #tmp_data ORDER BY Num;
    
    OPEN c;
    FETCH NEXT FROM c INTO @v_Indice, @v_SaldoInicial, @v_Cargo, @v_Abono;

    WHILE @@FETCH_STATUS = 0
    BEGIN
		If @v_Indice  > 1
		  SET @v_SaldoInicial = @v_Saldo
        SET @v_Saldo = @v_SaldoInicial + @v_Cargo - @v_Abono
		/*  DEBUG
		print @v_Indice
		print 'Saldo inicial: ' + Cast(@v_SaldoInicial AS Varchar(20))
		print 'Cargos: ' + Cast(@v_Cargo AS Varchar(20))
		print 'Abonos: ' + Cast(@v_Abono AS Varchar(20))
		print 'Saldo : ' + Cast(@v_Saldo AS Varchar(20))*/
        
        UPDATE #tmp_data 
		SET Saldos = @v_Saldo , SaldoInicial = @v_SaldoInicial
		WHERE Num = @v_Indice;
		

        FETCH NEXT FROM c INTO  @v_Indice, @v_SaldoInicial, @v_Cargo, @v_Abono;
    END;

    CLOSE c;
    DEALLOCATE c;

    -- Return results
    SELECT *
	 , Titulo = CAST(CONCAT('Del ' , FORMAT(@p_FechaInicio, 'dd \de MMMM \del yyyy', 'es-MX') , ' AL ' ,  FORMAT(@p_FechaFin, 'dd \de MMMM \del yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tmp_data ORDER BY Num;
END;

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepBienLentNulMovPer]';
GO
-- exec [CONTA].[SPR_RepBienLentNulMovPer]'2025-07-01','2025-07-31'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepBienLentNulMovPer]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepBienLentNulMovPer'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')
		
	SELECT [PK_IdTipoBien] AS [ID]
      ,[FK_IdPartida__SIS] AS [PP]
      --,[CUCOP]
      --,[CABMS] 
      ,[CodigoClave] AS [cabmsdf]
      ,[Descripcion] AS [concepto]
      ,[Unidades] AS [um]
      ,[Existencias] AS [cant]	  
      ,[CostoPromedio] AS [costprom]
	  ,[Existencias] * [CostoPromedio] AS [total]
	  ,NULL AS [B]
	  ,NULL AS [R]
	  ,NULL AS [BN]
	  ,'Almacén Boston' AS [UBBien]
	  , NULL AS [RespBien]
      --,[FKIdAnio_SIS]
      --,[Message]
      --,[FK_IdUnidades__ALMA]
      --,[CostoUnitario]
  INTO #tblRepBienLentNulMovPer
  FROM [BD_IFT].[ALMA].[VW_Existencias]
  WHERE [PK_IdTipoBien] NOT IN (

-- Entradas 
  SELECT FK_IdTipoBien__SICOP 
  FROM ALMA.Almacen 
  WHERE FK_IdDetalleOrdenCompra__ORCO is not null
  AND FechaEntrada >  @p_FecInicio 
  AND FechaEntrada <  @p_FecFin 
  )
  AND
  [PK_IdTipoBien] NOT IN (
  --Salidas
  SELECT FK_IdTipoBien__SICOP
  FROM ALMA.Almacen 
  WHERE FK_IdDetalleSolicitudSalida__ALMA is not null
  AND FechaEntrada >  @p_FecInicio 
  AND FechaEntrada <  @p_FecFin 
  )

	--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('PERIODO DEL ' , FORMAT(@p_FechaInicio, 'dd \de MMMM \del yyyy', 'es-MX') , ' AL ' ,  FORMAT(@p_FechaFin, 'dd \de MMMM \del yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tblRepBienLentNulMovPer
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepCheques]';
GO
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepCheques]
      @p_FecInicio nvarchar(24),
      @p_FecFin nvarchar(24)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    DECLARE @p_FechaInicio date = CAST(@p_FecInicio AS date),
            @p_FechaFin date = CAST(@p_FecFin AS date),
            @Funcion1 nvarchar(64) = N'',
            @Funcion2 nvarchar(64) = N'',
            @Funcion3 nvarchar(64) = N'',
            @Nombre1 nvarchar(254) = N'',
            @Nombre2 nvarchar(254) = N'',
            @Nombre3 nvarchar(254) = N'',
            @Puesto1 nvarchar(254) = N'',
            @Puesto2 nvarchar(254) = N'',
            @Puesto3 nvarchar(254) = N'';

    SELECT ch.PKIdCheque AS ID,
           ch.NumeroCheque AS nocheq,
           ch.FechaEmision AS fechaem,
           COALESCE(ch.EmpresaNombre, N'') AS bene,
           ISNULL(ch.ImporteTotal, 0) AS monto,
           CASE WHEN ch.Estatus = 1 THEN DATEADD(day, 7, ch.FechaEmision) ELSE ch.FechaEmision END AS fechacobes,
           COALESCE(ch.EstatusDescripcion, CASE WHEN ch.Estatus = 1 THEN 'DESCONOCIDO' ELSE 'COBRADO' END) AS estado,
           COALESCE(ch.Observaciones, ch.Concepto, N'') AS obs
    INTO #tblRepCheques
    FROM [PRES].[Vw_Cheque] ch
    WHERE ch.Activo = 1
      AND ch.FechaEmision BETWEEN @p_FechaInicio AND @p_FechaFin;

    SELECT *,
           @Funcion1 AS Funcion1,
           @Funcion2 AS Funcion2,
           @Funcion3 AS Funcion3,
           @Nombre1 AS Nombre1,
           @Nombre2 AS Nombre2,
           @Nombre3 AS Nombre3,
           @Puesto1 AS Puesto1,
           @Puesto2 AS Puesto2,
           @Puesto3 AS Puesto3,
           CAST(CONCAT('PERIODO DEL ', FORMAT(@p_FechaInicio, 'dd \de MMMM \del yyyy', 'es-MX'), ' AL ', FORMAT(@p_FechaFin, 'dd \de MMMM \del yyyy', 'es-MX')) AS nvarchar(128)) AS Titulo
    FROM #tblRepCheques;
END
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepClasAdministrativa]';
GO
-- exec [CONTA].[SPR_RepClasAdministrativa] '2025-05-01','2025-05-30'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepClasAdministrativa]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepClasAdministrativa'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	SELECT Fk_IdArea__SIS, Area AS Concepto, SUM(Disponible) AS Subejercicio, SUM(EgresoAutorizado) AS Aprobado, 0.00 AS AmplReduc, SUM(Adecuaciones) AS Modificado, SUM(Devengado) AS Devengado, SUM(Pagado) AS Pagado
	INTO #tblRepClasificacionAdministrativa
	FROM     PRES.VW_ClasificacionEgreso
	GROUP BY Fk_IdArea__SIS, Area
	Order By Fk_IdArea__SIS

	--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('DEL ' , FORMAT(@p_FechaInicio, 'yyyy', 'es-MX') , ' AL ' ,  FORMAT(@p_FechaFin, 'yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tblRepClasificacionAdministrativa
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepClasEconomica]';
GO
-- exec [CONTA].[SPR_RepClasEconomica] '2025-05-01','2025-05-30'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepClasEconomica]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepClasEconomica'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	SELECT ID = 1, [Concepto] = 'Gasto Corriente' , [Subejercicio] = 500000.00 , [Aprobado] = 25000000.00 , [AmplReduc] = 1500000.00 , [Modificado] = 26500000.00 , [Devengado] = 26000000.00 , [Pagado] = 25500000.00 
	INTO #tblRepClasificacionEconomica
	UNION 
	SELECT 2, 'Gasto de Capital', 200000.00, 15000000.00, 1000000.00, 16000000.00, 15800000.00, 15500000.00
	UNION 
	SELECT 3, 'Amortización de la Deuda y Disminución de Pasivos', 300000.00, 18000000.00, 1200000.00, 19200000.00, 19000000.00, 18700000.00
	UNION 
	SELECT 4, 'Pensiones y Jubilaciones', 100000.00, 8000000.00, 500000.00, 8500000.00, 8400000.00, 8300000.00
	UNION 
	SELECT 5, 'Participaciones', 150000.00, 6000000.00, 300000.00, 6300000.00, 6200000.00, 6150000.00

	--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('DEL ' , FORMAT(@p_FechaInicio, 'yyyy', 'es-MX') , ' AL ' ,  FORMAT(@p_FechaFin, 'yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tblRepClasificacionEconomica
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepClasFuncional]';
GO
-- exec [CONTA].[SPR_RepClasFuncional] '2025-05-01','2025-05-30'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepClasFuncional]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepClasFuncional'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	SELECT ID = 1, [Concepto] = 'Gobierno', [Subejercicio] = NULL , [Aprobado] = NULL , [AmplReduc] = NULL , [Modificado] = NULL , [Devengado] = NULL , [Pagado] = NULL 
	INTO #tblRepClasificacionFuncional
	UNION 
	SELECT 2, 'Legislación', 150000.00, 3000000.00, 200000.00, 3200000.00, 3050000.00, 2950000.00
	UNION 
	SELECT 3, 'Justicia', 250000.00, 5000000.00, 300000.00, 5300000.00, 5050000.00, 5000000.00
	UNION 
	SELECT 4, 'Coordinación de la Política de Gobierno', 80000.00, 1200000.00, 100000.00, 1300000.00, 1220000.00, 1180000.00
	UNION 
	SELECT 5, 'Relaciones Exteriores', 90000.00, 1400000.00, 80000.00, 1480000.00, 1390000.00, 1350000.00
	UNION 
	SELECT 6, 'Asuntos Financieros y Hacendarios', 300000.00, 6000000.00, 400000.00, 6400000.00, 6100000.00, 6050000.00
	UNION 
	SELECT 7, 'Seguridad Nacional', 200000.00, 4500000.00, 250000.00, 4750000.00, 4550000.00, 4500000.00
	UNION 
	SELECT 8, 'Asuntos de Orden Público y de Seguridad', 180000.00, 3500000.00, 220000.00, 3720000.00, 3540000.00, 3500000.00
	UNION 
	SELECT 9, 'Interior', 100000.00, 2700000.00, 150000.00, 2850000.00, 2750000.00, 2700000.00
	UNION 
	SELECT 10, 'Otros Servicios Generales', 60000.00, 1800000.00, 100000.00, 1900000.00, 1840000.00, 1800000.00
	UNION 
	SELECT 11, 'Desarrollo Social', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 12, 'Protección Ambiental', 120000.00, 2500000.00, 100000.00, 2600000.00, 2480000.00, 2450000.00
	UNION 
	SELECT 13, 'Vivienda y Servicios a la Comunidad', 90000.00, 3200000.00, 200000.00, 3400000.00, 3310000.00, 3250000.00
	UNION 
	SELECT 14, 'Salud', 200000.00, 7000000.00, 300000.00, 7300000.00, 7100000.00, 7050000.00
	UNION 
	SELECT 15, 'Recreación, Cultura y Otras Manifestaciones Sociales', 110000.00, 2800000.00, 120000.00, 2920000.00, 2810000.00, 2770000.00
	UNION 
	SELECT 16, 'Educación', 400000.00, 9500000.00, 500000.00, 10000000.00, 9600000.00, 9500000.00
	UNION 
	SELECT 17, 'Protección Social', 170000.00, 3600000.00, 180000.00, 3780000.00, 3610000.00, 3550000.00
	UNION 
	SELECT 18, 'Otros Asuntos Sociales', 60000.00, 1800000.00, 100000.00, 1900000.00, 1840000.00, 1800000.00
	UNION 
	SELECT 19, 'Desarrollo Económico', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 20, 'Asuntos Económicos, Comerciales y Laborales en General', 80000.00, 2600000.00, 150000.00, 2750000.00, 2670000.00, 2620000.00
	UNION 
	SELECT 21, 'Agropecuaria, Silvicultura, Pesca y Caza', 100000.00, 3400000.00, 200000.00, 3600000.00, 3500000.00, 3450000.00
	UNION 
	SELECT 22, 'Combustibles y Energía', 150000.00, 3800000.00, 250000.00, 4050000.00, 3900000.00, 3850000.00
	UNION 
	SELECT 23, 'Minería, Manufacturas y Construcción', 90000.00, 2100000.00, 130000.00, 2230000.00, 2140000.00, 2100000.00
	UNION 
	SELECT 24, 'Transporte', 200000.00, 4200000.00, 300000.00, 4500000.00, 4300000.00, 4250000.00
	UNION 
	SELECT 25, 'Comunicaciones', 130000.00, 3000000.00, 180000.00, 3180000.00, 3050000.00, 3000000.00
	UNION 
	SELECT 26, 'Turismo', 70000.00, 1700000.00, 90000.00, 1790000.00, 1720000.00, 1700000.00
	UNION 
	SELECT 27, 'Ciencia, Tecnología e Innovación', 120000.00, 2900000.00, 200000.00, 3100000.00, 2980000.00, 2950000.00
	UNION 
	SELECT 28, 'Otras Industrias y Otros Asuntos Económicos', 60000.00, 1500000.00, 80000.00, 1580000.00, 1520000.00, 1500000.00
	UNION 
	SELECT 29, 'Otras no Clasificadas en Funciones Anteriores', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 30, 'Transacciones de la Deuda Publica / Costo Financiero de la Deuda', 100000.00, 5000000.00, 400000.00, 5400000.00, 5300000.00, 5250000.00
	UNION 
	SELECT 31, 'Transferencias, Participaciones y Aportaciones entre diferentes Niveles y Ordenes de Gobierno', 250000.00, 8000000.00, 500000.00, 8500000.00, 8250000.00, 8200000.00
	UNION 
	SELECT 32, 'Saneamiento del Sistema Financiero', 50000.00, 1000000.00, 100000.00, 1100000.00, 1050000.00, 1040000.00
	UNION 
	SELECT 33, 'Adeudos de Ejercicios Fiscales Anteriores', 75000.00, 1200000.00, 150000.00, 1350000.00, 1300000.00, 1290000.00

	--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('DEL ' , FORMAT(@p_FechaInicio, 'yyyy', 'es-MX') , ' AL ' ,  FORMAT(@p_FechaFin, 'yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tblRepClasificacionFuncional
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepClasObjGasto]';
GO
-- exec [CONTA].[SPR_RepClasObjGasto] '2025-05-01','2025-05-30'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepClasObjGasto]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepClasObjGasto'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	SELECT Fk_IdPartida__SIS, Descripcion AS Concepto, SUM(Disponible) AS Subejercicio, SUM(EgresoAutorizado) AS Aprobado, 0.00 AS AmplReduc, SUM(Adecuaciones) AS Modificado, SUM(Devengado) AS Devengado, SUM(Pagado) AS Pagado
	INTO #tblRepClasificacionObjetoGasto
	FROM     PRES.VW_ClasificacionEgreso
	GROUP BY Fk_IdPartida__SIS, Descripcion

	--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('DEL ' , FORMAT(@p_FechaInicio, 'yyyy', 'es-MX') , ' AL ' ,  FORMAT(@p_FechaFin, 'yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tblRepClasificacionObjetoGasto
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepDepAcum]';
GO
-- exec [CONTA].[SPR_RepDepAcum] '2025-05-01'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepDepAcum]
	  @p_FecInicio nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepDepAcum'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	SELECT FK_IdPartida__SIS AS ID, partida AS Concepto, SUM(DepreciacionAcumulada - DepreciacionMes) AS [IMPMESANT],  SUM(DepreciacionMes) AS [DEPMES], SUM(DepreciacionAcumulada) AS [IMPACUM] 
	INTO #tblDepreciacionAcumulada	
	FROM  [SICOP].[VW_DepreciacionBien]
	GROUP BY  FK_IdPartida__SIS, partida 

	--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('CORRESPONDIENTE AL MES DE: ' , FORMAT(@p_FechaInicio, ' MMMM \DE yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tblDepreciacionAcumulada
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepDIOT]';
GO
-- exec [CONTA].[SPR_RepDIOT]
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepDIOT]
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	SELECT 
	[TTer] = '04', [TOp] = '02' , [ReFeCon] = 'PES111111QW1' , [NumIdFis] = '' , [NomEx] = '' , [PaJuReFis] = '' , [EsJuFis] = '' ,
	[VTAPFN] = '1000', [DDBAArfn] = '10' , [VtaAaprfs] = '1000' , [DDBAAefs] = '10' , [VtapAAtpiva] = '1000' , [DDBAatpiva] = '10' , [VTAPAAPIiva] = '1000' ,
	[DDBAAIiva] = '10', [VTAAPAAPIbiva] = '1000' , [DDBAAPIBiva] = '10' , [EAGAAPRFN] = '10' , [ASAPAAPRFN] = '10' , [EXAGAAPRFS] = '10' , [AAAPAAPRFS] = '10' ,
	[EAGAATPiva] = '10', [ASAPAARiva] = '10' , [EXAGAAPIAiva] = '10' , [AAAPAAPIAiva] = '10' , [EXAGAAPIBiva] = '10' , [AAAPAAPIBiva] = '10' , [AAAPAAPRFN] = '1' , [AANCRAAPRFN] = '1' ,
	[AAEAAPRFN] = '1', [AANOBAAPRFN] = '1' , [AAPAPRAAPRFS] = '1' , [AANCRAAPRFS] = '1' , [AAEXAAPRFS] = '1' , [AANOBAAPRFS] = '1' , [AACAPRAATPiva] = '1' ,
	[ASANCRAATPiva] = '1', [ASAEXAATPiva] = '1' , [ASANBAATPiva] = '1' , [ASAPCAPAAPIPABiva] = '1' , [AANCRAAPIABiva] = '1' , [AAEXAAPIPABiva] = '1' , [AAPCAPAOAPIBiva] = '1' ,
	[ASANCRAAPIBIiva] = '1', [ASAEXAAPIBISiva] = '1' , [ASANOAAPIBISiva] = '1' , [IVARPC] = '1' , [AAPIBSPNPIVAEX] = '100' , [AAPPNPIVAEX] = '100' , [DAAPTCIVA] = '100' ,
	[AANOBIVARTN] = '100', [AANOIVANCETN] = '100' , [MEFCAORPR] = '01' 
	INTO #tblRepDiot
	UNION
	SELECT 
	[TTer] = '04', [TOp] = '85' , [ReFeCon] = 'GUSA620523456' , [NumIdFis] = '1' , [NomEx] = 'Mario Pech Soliz' , [PaJuReFis] = 'ZZZ' , [EsJuFis] = 'MiCasa' ,
	[VTAPFN] = '1000', [DDBAArfn] = '10' , [VtaAaprfs] = '1000' , [DDBAAefs] = '10' , [VtapAAtpiva] = '1000' , [DDBAatpiva] = '10' , [VTAPAAPIiva] = '1000' ,
	[DDBAAIiva] = '10', [VTAAPAAPIbiva] = '1000' , [DDBAAPIBiva] = '10' , [EAGAAPRFN] = '10' , [ASAPAAPRFN] = '10' , [EXAGAAPRFS] = '10' , [AAAPAAPRFS] = '10' ,
	[EAGAATPiva] = '10', [ASAPAARiva] = '10' , [EXAGAAPIAiva] = '10' , [AAAPAAPIAiva] = '10' , [EXAGAAPIBiva] = '10' , [AAAPAAPIBiva] = '10' , [AAAPAAPRFN] = '1' , [AANCRAAPRFN] = '1' ,
	[AAEAAPRFN] = '1', [AANOBAAPRFN] = '1' , [AAPAPRAAPRFS] = '1' , [AANCRAAPRFS] = '1' , [AAEXAAPRFS] = '1' , [AANOBAAPRFS] = '1' , [AACAPRAATPiva] = '1' ,
	[ASANCRAATPiva] = '1', [ASAEXAATPiva] = '1' , [ASANBAATPiva] = '1' , [ASAPCAPAAPIPABiva] = '1' , [AANCRAAPIABiva] = '1' , [AAEXAAPIPABiva] = '1' , [AAPCAPAOAPIBiva] = '1' ,
	[ASANCRAAPIBIiva] = '1', [ASAEXAAPIBISiva] = '1' , [ASANOAAPIBISiva] = '1' , [IVARPC] = '1' , [AAPIBSPNPIVAEX] = '100' , [AAPPNPIVAEX] = '100' , [DAAPTCIVA] = '100' ,
	[AANOBIVARTN] = '100', [AANOIVANCETN] = '100' , [MEFCAORPR] = '01' 
	--FIN
	SELECT *
	FROM #tblRepDiot
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepEndeudamientoNeto]';
GO
-- exec [CONTA].[SPR_RepEndeudamientoNeto]'2025-01-01','2025-06-30'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepEndeudamientoNeto]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = '#RepEndeudamiento'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	SELECT 
    ID = 1, [IDEN] = 'CR-001', [CONCOL] = 1200000.00, [AM] = 400000.00,[ENDENETO] = 800000.00
	INTO #tbRepEndeudamientoResultado1
	UNION
	SELECT 
    2,'CR-002', 900000.00, 300000.00, 600000.00
	UNION
	SELECT 
    3,'CR-003', 1500000.00, 500000.00, 1000000.00;
	--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('Del ' , FORMAT(@p_FechaInicio, 'dd \de MMMM', 'es-MX') , ' al ' ,  FORMAT(@p_FechaFin, 'dd \de MMMM \de yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tbRepEndeudamientoResultado1

	SELECT
	ID = 1, [IDEN] = 'CR-007', [CONCOL] = 12000.00, [AM] = 2000.00,[ENDENETO] = 4000.00
	INTO #tbRepEndeudamientoResultado2
	UNION
	SELECT 
    2,'CR-008', 12000.00, 36000.00, 20000.00
	UNION
	SELECT 
    3,'CR-009', 25000.00, 40000.00, 15000.00;
	--FIN
	SELECT * FROM #tbRepEndeudamientoResultado2
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepEstatCuentaBancario]';
GO
-- exec [CONTA].[SPR_RepEstatCuentaBancario] '2024-01-01', '2024-01-30', 259568
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepEstatCuentaBancario]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24),
	  @p_Fk_ICuentaContable INT

AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
		
	DECLARE @p_FechaInicio DATETIME2(3) = @p_FecInicio, 
    @p_FechaFin DATETIME2(3) = @p_FecFin

    DECLARE @v_Mes_Inicio INT;
    DECLARE @v_Fk_IdAnio__SIS INT;
    DECLARE @v_FK_IdMesAnterior INT;
    DECLARE @v_FK_IdAnioAnterior INT;
    DECLARE @v_Indice INT;
    DECLARE @v_SaldoInicial DECIMAL(18, 2);

	-- Se configura el mes año anterior 
    SET @v_Mes_Inicio = MONTH(@p_FechaInicio);
    --SET @v_Mes_Fin = MONTH(@p_FechaFin);    
    SELECT @v_Fk_IdAnio__SIS = YEAR(@p_FechaInicio);
	
	SET @v_FK_IdMesAnterior = (CASE WHEN @v_Mes_Inicio = 1 THEN 13 ELSE @v_Mes_Inicio - 1 END);

	SET @v_FK_IdAnioAnterior = (CASE WHEN @v_Mes_Inicio = 1  THEN @v_Fk_IdAnio__SIS - 1 ELSE @v_Fk_IdAnio__SIS  END);

	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepEstatCuentaBancario'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')
	--****
	
    -- Drop temp table if it exists
    IF OBJECT_ID('tempdb..#tmp_saldoInicial') IS NOT NULL DROP TABLE #tmp_saldoInicial;

    -- Create temp table
    CREATE TABLE #tmp_saldoInicial (SaldoFinal DECIMAL(18, 2));

    -- Insert saldo inicial
    INSERT INTO #tmp_saldoInicial (SaldoFinal)
    SELECT ISNULL(SaldoFinal, 0)
    FROM CONTA.SaldoMensual
    WHERE FKIdCuentaContable = @p_Fk_ICuentaContable
    AND (
        ( FKIdMes_SIS = @v_FK_IdMesAnterior
         
        AND FKIdAnio_SIS = @v_FK_IdAnioAnterior)
    );
	
	--DEBUG 
	--SELECT * FROM #tmp_saldoInicial

    -- Drop temp table if it exists
    IF OBJECT_ID('tempdb..#tmp_data') IS NOT NULL DROP TABLE #tmp_data;

    -- Create temp table
    CREATE TABLE #tmp_data (
        Num INT IDENTITY(1,1),
        PKIdPoliza INT,
        PKIdPolizaDetalle INT,
        FKIdTipoCuenta_CONTA INT,
        PKIdCuentaContable INT,
        IniPeriodo NVARCHAR(50),
        FinPeriodo NVARCHAR(50),
        FechaActual NVARCHAR(50),
        Cuenta NVARCHAR(250),
        NombrePoliza NVARCHAR(250),
        ClavePoliza NVARCHAR(250),
        TipoPoliza NVARCHAR(50),
        ConceptoMovimiento NVARCHAR(500),
        SaldoInicial DECIMAL(20, 2),
        Cargos DECIMAL(20, 2),
        Abonos DECIMAL(20, 2),
        Saldos DECIMAL(20, 2),
    );

    -- Insert data
    INSERT INTO #tmp_data (
        PKIdPoliza, PKIdPolizaDetalle, FKIdTipoCuenta_CONTA, PKIdCuentaContable,
        IniPeriodo, FinPeriodo, FechaActual, Cuenta, NombrePoliza, ClavePoliza, TipoPoliza,
        ConceptoMovimiento, SaldoInicial, Cargos, Abonos, Saldos
    )
    SELECT  
        p.PKIdPoliza
		, dp.PKIdPolizaDetalle
		, cc.TipoCuenta
		, cc.Pk_IdCuenta
		, FORMAT(@p_FechaInicio, 'MMMM yyyy') AS IniPeriodo
		, FORMAT(@p_FechaFin, 'MMMM yyyy') AS FinPeriodo
		, p.FechaPoliza  AS FechaActual -- FORMAT(GETDATE(), 'dd/MM/yyyy')
		, cc.ClaveNombre AS Cuenta
		, p.NombrePoliza
		, p.ClavePoliza
		, CASE 
			WHEN FKIdTipoPoliza_SIS = 1 THEN 'Dr'
			WHEN FKIdTipoPoliza_SIS = 2 THEN 'Eg'
			WHEN FKIdTipoPoliza_SIS = 3 THEN 'Ig'
			WHEN FKIdTipoPoliza_SIS = 4 THEN 'Pr'
		  END AS TipoPoliza
		, FORMAT(p.FechaPoliza, 'dd/MM/yyyy') + ' ' + dp.Descripcion AS ConceptoMovimiento
		, ISNULL((SELECT SaldoFinal FROM #tmp_saldoInicial), 0) AS SaldoInicial
		, dp.ImporteDebe AS Cargos
		, dp.ImporteHaber AS Abonos
		, dp.ImporteDebe AS Saldos		
	FROM CONTA.PolizaDetalle dp 
		INNER JOIN CONTA.Poliza p ON dp.FKIdPoliza_CONTA = p.PKIdPoliza 
		INNER JOIN CONTA.VW_CUENTAS cc ON dp.FKIdCuentaContable_CONTA = cc.Pk_IdCuenta
    WHERE cc.Pk_IdCuenta = @p_Fk_ICuentaContable
		AND p.FechaPoliza BETWEEN @p_FechaInicio AND @p_FechaFin
		AND dp.Activo = 1 AND p.Activo = 1 
	ORDER BY p.PKIdPoliza;

    -- Update saldo calculation
    DECLARE @v_Saldo DECIMAL(20, 2),
			@v_Cargo DECIMAL(20, 2), 
			@v_Abono DECIMAL(20, 2);
    DECLARE c CURSOR FOR 
    SELECT Num, SaldoInicial, Cargos, Abonos  FROM #tmp_data ORDER BY Num;
    
    OPEN c;
    FETCH NEXT FROM c INTO @v_Indice, @v_SaldoInicial, @v_Cargo, @v_Abono;

    WHILE @@FETCH_STATUS = 0
    BEGIN
		If @v_Indice  > 1
		  SET @v_SaldoInicial = @v_Saldo

        SET @v_Saldo = @v_SaldoInicial + @v_Cargo - @v_Abono
		/*  DEBUG
		print @v_Indice
		print 'Saldo inicial: ' + Cast(@v_SaldoInicial AS Varchar(20))
		print 'Cargos: ' + Cast(@v_Cargo AS Varchar(20))
		print 'Abonos: ' + Cast(@v_Abono AS Varchar(20))
		print 'Saldo : ' + Cast(@v_Saldo AS Varchar(20))*/
        
        UPDATE #tmp_data 
		SET Saldos = @v_Saldo , SaldoInicial = @v_SaldoInicial
		WHERE Num = @v_Indice;
		

        FETCH NEXT FROM c INTO  @v_Indice, @v_SaldoInicial, @v_Cargo, @v_Abono;
    END;

    CLOSE c;
    DEALLOCATE c;
	
	SELECT  PKIdPoliza AS ID
			, Cuenta AS [nocuenta]
			, '530802' AS[nociente]
			,  'IFT 980201 GG3' AS [rfc]
			, FechaActual AS [fechoper]
			, ClavePoliza AS [mov]
			, TipoPoliza AS [clave]
			, NombrePoliza AS [concepto]
			, ConceptoMovimiento AS [ref]
			, SaldoInicial As saldoinicial  -- OJO, Este campo es nuevo
			, Cargos AS cargo
			, Abonos AS abono
			, Saldos AS saldo
	INTO #tblRepEstatCuentaBancario	
	FROM #tmp_data
	ORDER BY Num
	--***
	
	--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('PERIODO DEL ' , FORMAT(@p_FechaInicio, 'dd \de MMMM \del yyyy', 'es-MX') , ' AL ' ,  FORMAT(@p_FechaFin, 'dd \de MMMM \del yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tblRepEstatCuentaBancario
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepEstatCuentaCuPa]';
GO
-- exec [CONTA].[SPR_RepEstatCuentaCuPa]  '2024-01-01', '2024-01-30', 259568
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepEstatCuentaCuPa]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24),
	  @p_Fk_ICuentaContable INT
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATETIME2(3) = @p_FecInicio, 
    @p_FechaFin DATETIME2(3) = @p_FecFin

    DECLARE @v_Mes_Inicio INT;
    DECLARE @v_Fk_IdAnio__SIS INT;
    DECLARE @v_FK_IdMesAnterior INT;
    DECLARE @v_FK_IdAnioAnterior INT;
    DECLARE @v_Indice INT;
    DECLARE @v_SaldoInicial DECIMAL(18, 2);

	-- Se configura el mes año anterior 
    SET @v_Mes_Inicio = MONTH(@p_FechaInicio);
    --SET @v_Mes_Fin = MONTH(@p_FechaFin);    
    SELECT @v_Fk_IdAnio__SIS = YEAR(@p_FechaInicio);
	
	SET @v_FK_IdMesAnterior = (CASE WHEN @v_Mes_Inicio = 1 THEN 13 ELSE @v_Mes_Inicio - 1 END);

	SET @v_FK_IdAnioAnterior = (CASE WHEN @v_Mes_Inicio = 1  THEN @v_Fk_IdAnio__SIS - 1 ELSE @v_Fk_IdAnio__SIS  END);
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepEstatCuentaCuPa'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

		--****
	
    -- Drop temp table if it exists
    IF OBJECT_ID('tempdb..#tmp_saldoInicial') IS NOT NULL DROP TABLE #tmp_saldoInicial;

    -- Create temp table
    CREATE TABLE #tmp_saldoInicial (SaldoFinal DECIMAL(18, 2));

    -- Insert saldo inicial
    INSERT INTO #tmp_saldoInicial (SaldoFinal)
    SELECT ISNULL(SaldoFinal, 0)
    FROM CONTA.SaldoMensual
    WHERE FKIdCuentaContable = @p_Fk_ICuentaContable
    AND (
        ( FKIdMes_SIS = @v_FK_IdMesAnterior
         
        AND FKIdAnio_SIS = @v_FK_IdAnioAnterior)
    );
	
	--DEBUG 
	--SELECT * FROM #tmp_saldoInicial

    -- Drop temp table if it exists
    IF OBJECT_ID('tempdb..#tmp_data') IS NOT NULL DROP TABLE #tmp_data;

    -- Create temp table
    CREATE TABLE #tmp_data (
        Num INT IDENTITY(1,1),
        PKIdPoliza INT,
        PKIdPolizaDetalle INT,
        FKIdTipoCuenta_CONTA INT,
        PKIdCuentaContable INT,
        IniPeriodo NVARCHAR(50),
        FinPeriodo NVARCHAR(50),
        FechaActual NVARCHAR(50),
        Cuenta NVARCHAR(250),
        NombrePoliza NVARCHAR(250),
        ClavePoliza NVARCHAR(250),
        TipoPoliza NVARCHAR(50),
        ConceptoMovimiento NVARCHAR(500),
        SaldoInicial DECIMAL(20, 2),
        Cargos DECIMAL(20, 2),
        Abonos DECIMAL(20, 2),
        Saldos DECIMAL(20, 2),
    );

    -- Insert data
    INSERT INTO #tmp_data (
        PKIdPoliza, PKIdPolizaDetalle, FKIdTipoCuenta_CONTA, PKIdCuentaContable,
        IniPeriodo, FinPeriodo, FechaActual, Cuenta, NombrePoliza, ClavePoliza, TipoPoliza,
        ConceptoMovimiento, SaldoInicial, Cargos, Abonos, Saldos
    )
    SELECT  
        p.PKIdPoliza
		, dp.PKIdPolizaDetalle
		, cc.TipoCuenta
		, cc.Pk_IdCuenta
		, FORMAT(@p_FechaInicio, 'MMMM yyyy') AS IniPeriodo
		, FORMAT(@p_FechaFin, 'MMMM yyyy') AS FinPeriodo
		, p.FechaPoliza  AS FechaActual -- FORMAT(GETDATE(), 'dd/MM/yyyy')
		, cc.ClaveNombre AS Cuenta
		, p.NombrePoliza
		, p.ClavePoliza
		, CASE 
			WHEN FKIdTipoPoliza_SIS = 1 THEN 'Dr'
			WHEN FKIdTipoPoliza_SIS = 2 THEN 'Eg'
			WHEN FKIdTipoPoliza_SIS = 3 THEN 'Ig'
			WHEN FKIdTipoPoliza_SIS = 4 THEN 'Pr'
		  END AS TipoPoliza
		, FORMAT(p.FechaPoliza, 'dd/MM/yyyy') + ' ' + dp.Descripcion AS ConceptoMovimiento
		, ISNULL((SELECT SaldoFinal FROM #tmp_saldoInicial), 0) AS SaldoInicial
		, dp.ImporteDebe AS Cargos
		, dp.ImporteHaber AS Abonos
		, dp.ImporteDebe AS Saldos		
	FROM CONTA.PolizaDetalle dp 
		INNER JOIN CONTA.Poliza p ON dp.FKIdPoliza_CONTA = p.PKIdPoliza 
		INNER JOIN CONTA.VW_CUENTAS cc ON dp.FKIdCuentaContable_CONTA = cc.Pk_IdCuenta
    WHERE cc.Pk_IdCuenta = @p_Fk_ICuentaContable
		AND p.FechaPoliza BETWEEN @p_FechaInicio AND @p_FechaFin
		AND dp.Activo = 1 AND p.Activo = 1 
	ORDER BY p.PKIdPoliza;

    -- Update saldo calculation
    DECLARE @v_Saldo DECIMAL(20, 2),
			@v_Cargo DECIMAL(20, 2), 
			@v_Abono DECIMAL(20, 2);
    DECLARE c CURSOR FOR 
    SELECT Num, SaldoInicial, Cargos, Abonos  FROM #tmp_data ORDER BY Num;
    
    OPEN c;
    FETCH NEXT FROM c INTO @v_Indice, @v_SaldoInicial, @v_Cargo, @v_Abono;

    WHILE @@FETCH_STATUS = 0
    BEGIN
		If @v_Indice  > 1
		  SET @v_SaldoInicial = @v_Saldo

        SET @v_Saldo = @v_SaldoInicial + @v_Cargo - @v_Abono
		/*  DEBUG
		print @v_Indice
		print 'Saldo inicial: ' + Cast(@v_SaldoInicial AS Varchar(20))
		print 'Cargos: ' + Cast(@v_Cargo AS Varchar(20))
		print 'Abonos: ' + Cast(@v_Abono AS Varchar(20))
		print 'Saldo : ' + Cast(@v_Saldo AS Varchar(20))*/
        
        UPDATE #tmp_data 
		SET Saldos = @v_Saldo , SaldoInicial = @v_SaldoInicial
		WHERE Num = @v_Indice;
		

        FETCH NEXT FROM c INTO  @v_Indice, @v_SaldoInicial, @v_Cargo, @v_Abono;
    END;

    CLOSE c;
    DEALLOCATE c;
	
	SELECT  PKIdPoliza AS ID
			, Cuenta AS [nocuenta]
			, '530802' AS[nociente]
			,  'IFT 980201 GG3' AS [rfc]
			, FechaActual AS [fechoper]
			, ClavePoliza AS [mov]
			, TipoPoliza AS [clave]
			, NombrePoliza AS [concepto]
			, ConceptoMovimiento AS [ref]
			, SaldoInicial As saldoinicial  -- OJO, Este campo es nuevo
			, Cargos AS cargo
			, Abonos AS abono
			, Saldos AS saldo
	INTO #tblRepEstatCuentaCuPa	
	FROM #tmp_data
	ORDER BY Num
	--***
	--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('PERIODO DEL ' , FORMAT(@p_FechaInicio, 'dd \de MMMM \del yyyy', 'es-MX') , ' AL ' ,  FORMAT(@p_FechaFin, 'dd \de MMMM \del yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tblRepEstatCuentaCuPa
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepIndicadoresPF]';
GO
-- exec [CONTA].[SPR_RepIndicadoresPF] '2025-10-01','2025-10-01'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepIndicadoresPF]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepIndicadoresPF'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	SELECT 
    ID = 1, [Concepto] = 'I. Ingresos Presupuestarios', [EstApro] = 0.00, [Deve] = 0.00, [RecPag] = 0.00
	INTO #tbRepIndicadoresPF
	UNION
	SELECT 
    2,'1. Ingresos del Gobierno de la Entidad Federativa', 0.00, 0.00, 0.00
	UNION
	SELECT 
    3,'2. Ingresos del Sector Paraestatal', 0.00, 0.00, 0.00
	UNION
	SELECT 
    4,'II. Egresos Presupuestarios', 0.00, 0.00, 0.00
	UNION
	SELECT 
    5,'3. Egresos del Gobierno de la Entidad Federativa', 0.00, 0.00, 0.00
	UNION
	SELECT 
    6,'4. Egresos del Sector Paraestatal', 0.00, 0.00, 0.00
	UNION
	SELECT 
    7,'III. Balance Presupuestario (Superávit o Déficit)', 0.00, 0.00, 0.00
	UNION
	SELECT 
    8,'III. Balance presupuestario (Superávit o Déficit)', 0.00, 0.00, 0.00
	UNION
	SELECT 
    9,'IV. Intereses, Comisiones y Gastos de la Deuda', 0.00, 0.00, 0.00
	UNION
	SELECT 
    10,'V. Balance Primario (Superávit o Déficit)', 0.00, 0.00, 0.00
	UNION
	SELECT 
    11,'A. Financiamiento', 0.00, 0.00, 0.00
	UNION
	SELECT 
    12,'B. Amortización de la deuda', 0.00, 0.00, 0.00
	UNION
	SELECT 
    13,'C. Financiamiento Neto', 0.00, 0.00, 0.00
	--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('DEL ' , UPPER(FORMAT(@p_FechaInicio, 'dd \DE MMMM \DEL yyyy', 'es-MX')) , ' AL ' ,  UPPER(FORMAT(@p_FechaFin, 'dd \DE MMMM \DEL yyyy', 'es-MX'))) AS NVARCHAR(128))
	FROM #tbRepIndicadoresPF
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepInformesProg]';
GO
-- exec [CONTA].[SPR_RepInformesProg]'2025-01-01','2025-06-30'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepInformesProg]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = '#RepInformesProg'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	SELECT 
    ID = 1, [CONCEPTO] = 'Subsidios: Sector Social y Privado o Entidades',[AP] = 200000.00,
    [AMPREC] = 80000.00, [MOD] = 120000.00, [DEV] = 20000.00, [PAG] = 20000.00, [SUBEJE] = 20000.00
	INTO #tbRepInformesProg
	UNION
	SELECT 
    2,'Federativas y Municipios',500000.00,250000.00,250000.00,80000.00,90000.00,40000.00
	UNION
	SELECT 
    3,'Sujetos a Reglas de Operación',120000.00,60000.00,60000.00,15000.00,20000.00,15000.00

	--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('Del ' , FORMAT(@p_FechaInicio, 'dd \de MMMM', 'es-MX') , ' al ' ,  FORMAT(@p_FechaFin, 'dd \de MMMM \de yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tbRepInformesProg
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepIngEgre]';
GO
-- exec [CONTA].[SPR_RepIngEgre] '2025-05-01','2025-05-30'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepIngEgre]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepIngEgre'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	SELECT ID = 1, [CONCEPTO] = '1. Total de Ingresos Presupuestarios', [Monto] = 25000000.00
	INTO #tblFormatoConciliacionEgresos
	UNION 
	SELECT 2, '2. Más Ingresos Contables No Presupuestarios', 3580000.00
	UNION 
	SELECT 3, '2.1 Ingresos Financieros', 1200000.00
	UNION 
	SELECT 4, '2.2 Incremento por Variación de Inventarios', 350000.00
	UNION 
	SELECT 5, '2.3 Disminución del Exceso de Estimaciones por Pérdida o Deterioro u Obsolescencia', 420000.00
	UNION 
	SELECT 6, '2.4 Disminución del Exceso de Provisiones', 300000.00
	UNION 
	SELECT 7, '2.5 Otros Ingresos y Beneficios Varios', 800000.00
	UNION 
	SELECT 8, '2.6 Otros Ingresos Contables No Presupuestarios', 510000.00
	UNION 
	SELECT 9, '3. Menos Ingresos Presupuestarios No Contables', 5150000.00
	UNION 
	SELECT 10, '3.1 Aprovechamientos Patrimoniales', 1800000.00
	UNION 
	SELECT 11, '3.2 Ingresos Derivados de Financiamientos', 2500000.00
	UNION 
	SELECT 12, '3.3 Otros Ingresos Presupuestarios No Contables', 850000.00
	UNION 
	SELECT 13, '4. Total de Ingresos Contables', 23430000.00


	--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('DEL ' , FORMAT(@p_FechaInicio, 'yyyy', 'es-MX') , ' AL ' ,  FORMAT(@p_FechaFin, 'yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tblFormatoConciliacionEgresos
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepIngreAna]';
GO
-- exec [CONTA].[SPR_RepIngreAna] '2025-05-01','2025-05-30'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepIngreAna]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepIngreAna'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	SELECT ID = 1, [RUBRO] = 'IMPUESTOS' , [ESTIMADO] = 12000000.00 , [AMPRED] = 500000.00 , [MODIFICADO] = 12500000.00 , [DEVENGADO] = 12200000.00 , [RECAUDADO] = 12150000.00 , [DIFERENCIA] = -350000.00  
	INTO #tblEstadoAnaliticoIngresos
	UNION 
	SELECT 2, 'CUOTAS Y APORTACIONES DE SEGURIDAD SOCIAL', 8000000.00, 200000.00, 8200000.00, 8150000.00, 8120000.00, -800000.00
	UNION 
	SELECT 3, 'CONTRIBUCIONES DE MEJORAS', 300000.00, 0.00, 300000.00, 280000.00, 275000.00, -25000.00
	UNION 
	SELECT 4, 'DERECHOS', 2500000.00, 100000.00, 2600000.00, 2580000.00, 2550000.00, -50000.00
	UNION 
	SELECT 5, 'PRODUCTOS', 1800000.00, 30000.00, 1830000.00, 1820000.00, 1805000.00, -25000.00
	UNION 
	SELECT 6, 'APROVECHAMIENTOS', 1500000.00, -50000.00, 1450000.00, 1400000.00, 1380000.00, -70000.00
	UNION 
	SELECT 7, 'INGRESOS POR VENTAS DE BIENES, PRESTACIÓN DE SERVICIOS Y OTROS INGRESOS', 2200000.00, 80000.00, 2280000.00, 2260000.00, 2240000.00, -40000.00
	UNION 
	SELECT 8, 'PARTICIPACIONES,APORTACIONES, CONVENIOS, INCENTIVOS DERIVADOS DE LA COLABORACIÓN FISCAL Y FONDOS DISTINTOS DE APORTACIONES', 10000000.00, 500000.00, 10500000.00, 10400000.00, 10350000.00, -150000.00
	UNION 
	SELECT 9, 'TRANSFERENCIAS, ASIGNACIONES, SUBSIDIOS Y SUBVENCIONES, Y PENSIONES Y JUBILACIONES', 9000000.00, 300000.00, 9300000.00, 9250000.00, 9200000.00, -100000.00
	UNION 
	SELECT 10, 'INGRESOS DERIVADOS DE FINANCIAMIENTOS', 7000000.00, 0.00, 7000000.00, 6900000.00, 6800000.00, -200000.00
	UNION 
	SELECT 11, 'INGRESOS DEL PODER EJECUTIVO FEDERAL O ESTATAL Y DE LOS MUNICIPIOS', 4000000.00, 100000.00, 4100000.00, 4050000.00, 4000000.00, -100000.00
	UNION 
	SELECT 12, 'IMPUESTOS', 13000000.00, 300000.00, 13300000.00, 13050000.00, 13000000.00, -300000.00
	UNION 
	SELECT 13, 'CUOTAS Y APORTACIONES DE SEGURIDAD SOCIAL', 8500000.00, 250000.00, 8750000.00, 8700000.00, 8680000.00, -70000.00
	UNION 
	SELECT 14, 'CONTRIBUCIONES DE MEJORAS', 350000.00, 0.00, 350000.00, 340000.00, 338000.00, -12000.00
	UNION 
	SELECT 15, 'DERECHOS', 2700000.00, 50000.00, 2750000.00, 2700000.00, 2680000.00, -70000.00
	UNION 
	SELECT 16, 'PRODUCTOS', 1900000.00, 40000.00, 1940000.00, 1920000.00, 1910000.00, -30000.00
	UNION 
	SELECT 17, 'APROVECHAMIENTOS', 1600000.00, -100000.00, 1500000.00, 1450000.00, 1440000.00, -60000.00
	UNION 
	SELECT 18, 'PARTICIPACIONES,APORTACIONES, CONVENIOS, INCENTIVOS DERIVADOS DE LA COLABORACIÓN FISCAL Y FONDOS DISTINTOS DE APORTACIONES', 11000000.00, 600000.00, 11600000.00, 11500000.00, 11400000.00, -200000.00
	UNION 
	SELECT 19, 'TRANSFERENCIAS, ASIGNACIONES, SUBSIDIOS Y SUBVENCIONES, Y PENSIONES Y JUBILACIONES', 9500000.00, 350000.00, 9850000.00, 9800000.00, 9700000.00, -150000.00
	UNION 
	SELECT 20, 'INGRESOS DE LOS ENTES PÚBLICOS DE LOS PODERES LEGISLATIVO Y JUDICIAL, DE LOS ÓRGANOS AUTÓNOMOS Y DEL SECTOR PARAESTATAL O PARAMUNICIPAL, ASÍ COMO DE LAS EMPRESAS PRODUCTIVAS DEL ESTADO', 3000000.00, 100000.00, 3100000.00, 3050000.00, 3000000.00, -100000.00
	UNION 
	SELECT 21, 'CUOTAS Y APORTACIONES DE SEGURIDAD SOCIAL', 9000000.00, 200000.00, 9200000.00, 9150000.00, 9100000.00, -100000.00
	UNION 
	SELECT 22, 'PRODUCTOS', 2000000.00, 60000.00, 2060000.00, 2040000.00, 2020000.00, -40000.00
	UNION 
	SELECT 23, 'INGRESOS POR VENTAS DE BIENES, PRESTACIÓN DE SERVICIOS Y OTROS INGRESOS', 2300000.00, 100000.00, 2400000.00, 2380000.00, 2360000.00, -40000.00
	UNION 
	SELECT 24, 'TRANSFERENCIAS, ASIGNACIONES, SUBSIDIOS Y SUBVENCIONES, Y PENSIONES Y JUBILACIONES', 9700000.00, 380000.00, 10080000.00, 10020000.00, 9950000.00, -150000.00
	UNION 
	SELECT 25, 'INGRESOS DERIVADOS DE FINANCIAMIENTO', 7200000.00, 150000.00, 7350000.00, 7300000.00, 7250000.00, -100000.00

	--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('DEL ' , FORMAT(@p_FechaInicio, 'dd \de MMMM \del yyyy', 'es-MX') , ' AL ' ,  FORMAT(@p_FechaFin, 'dd \de MMMM \del yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tblEstadoAnaliticoIngresos
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepInteresesDeuda]';
GO
-- exec [CONTA].[SPR_RepInteresesDeuda]'2025-01-01','2025-06-30'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepInteresesDeuda]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = '#RepInteresesDeuda'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	SELECT 
    ID = 1, [IDEN] = 'CR-001', [DEV] = 1200000.00, [PAG] = 400000.00
	INTO #tbRepInteresesDeudaResultado1
	UNION
	SELECT 
    2,'CR-002', 900000.00, 300000.00
	UNION
	SELECT 
    3,'CR-003', 1500000.00, 500000.00
	--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('Del ' , FORMAT(@p_FechaInicio, 'dd \de MMMM', 'es-MX') , ' al ' ,  FORMAT(@p_FechaFin, 'dd \de MMMM \de yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tbRepInteresesDeudaResultado1

	SELECT
	ID = 1, [IDEN] = 'CR-007', [DEV] = 12000.00, [PAG] = 2000.00
	INTO #tbRepInteresesDeudaResultado2
	UNION
	SELECT 
    2,'CR-008', 12000.00, 36000.00
	UNION
	SELECT 
    3,'CR-009', 25000.00, 40000.00
	--FIN
	SELECT * FROM #tbRepInteresesDeudaResultado2
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepInteSaldosCuPa]';
GO
-- exec [CONTA].[SPR_RepInteSaldosCuPa] '2025-07-31'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepInteSaldosCuPa]
	  @p_FecInicio nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio,
	
	 @DiasVencidos int = 20 -- DEFINIR CON EL USUARIO el parametro a partir de cuantos dias se  generan intereses 


	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepInteSaldosCuPa'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	SELECT ID, [nocuenta], [nomdeno], [saldo],  [fechaemi], diasvencidos AS [diasvencidos], [rango01], [rango31], [rango61], [rango90mas] --, [motivo]
	INTO #tblRepInteSaldosCuPa
	FROM PRES.[VW_FacturasPendientesPago]

	WHERE diasvencidos > @DiasVencidos -- Definir el parametro

--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('AL ' , FORMAT(@p_FechaInicio, 'dd \DE MMMM \DEL yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tblRepInteSaldosCuPa
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepKardexGralporPeriod]';
GO
-- exec [CONTA].[SPR_RepKardexGralporPeriod]'2025-07-01','2025-07-31'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepKardexGralporPeriod]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepKardexGralporPeriod'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	SELECT ID = 1, [PP] = '2161', [cabmsdf] = '2111000032' , [clave] = '2161E001', [concepto] = 'Escoba de plástico con bastón de madera' , [exist] = 1939.52,
	[entrada] = 0.00, [salida] = 484.88, [saldos] = 1454.64, [saldounidad] = 30, [costoprom] = 48.49, [um] = 'PIEZA'
	INTO #tblRepKardexGralporPeriod
	UNION
	SELECT ID = 2, '2161', '2111000104', '2161E002', 'Escobeta de plástico (largo 9 cm, altura 5 cm)', 550.30, 0.00, 0.00, 550.30, 40, 13.76, 'PIEZA'
	UNION
	SELECT ID = 3, '2161', '2111000104', '2161E003', 'Escobillón para W.C. con base', 1248.92, 0.00, 0.00,  1248.92, 29, 43.07, 'PIEZA'
	UNION
	SELECT ID = 4, '2161', '2111000104', '2161E004', 'Fibra acerina/metálica', 771.40, 0.00, 0.00, 771.40, 50, 15.43, 'PIEZA'
	UNION
	SELECT ID = 5, '2161', '2111000104', '2161E005', 'Fibra negra', 1205.82, 0.00, 0.00, 1205.82, 30, 40.19, 'PIEZA'

	--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('PERIODO DEL ' , FORMAT(@p_FechaInicio, 'dd \de MMMM \del yyyy', 'es-MX') , ' AL ' ,  FORMAT(@p_FechaFin, 'dd \de MMMM \del yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tblRepKardexGralporPeriod
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepKardexporArticulo]';
GO
-- exec [CONTA].[SPR_RepKardexporArticulo] '2025-07-01','2025-07-31'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepKardexporArticulo]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepKardexporArticulo'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	SELECT ID = 1, [articulo] = 'DEDAL DE HULE No. 112', [unidad] = 'PIEZA', [almacen] = 'IZTAPALAPA' , [clave] = '2111D001' , [fecha] = '16/05/2022' , [ref] = 'ROAD-13' , [entrada] = '150' ,
	[salida] = '0' , [exist] = '150', [preunit] = 7.00, [promedio] = 7.00, [debe] = 1050.00 , [haber] = 0.00, [saldo] = 1050.00
	INTO #tblRepKardexporArticulo
	UNION
	SELECT 2, 'DEDAL DE HULE No. 112', 'PIEZA', 'IZTAPALAPA', '2111D001', '19/06/2022', 'JUDOP-97', '0', '6', '144', 0.00, 7.00, 0.00, 42.00, 1008.00
	UNION
	SELECT 3, 'DEDAL DE HULE No. 112', 'PIEZA', 'IZTAPALAPA', '2111D001', '21/06/2022', 'DCMV-98', '0', '10', '134', 0.00, 7.00, 0.00, 70.00, 938.00
	UNION
	SELECT 4, 'DEDAL DE HULE No. 112', 'PIEZA', 'IZTAPALAPA', '2111D001', '25/06/2022', 'SAyO', '0', '4', '130', 0.00, 7.00, 0.00, 28.00, 910.00
	UNION
	SELECT 5, 'DEDAL DE HULE No. 112', 'PIEZA', 'IZTAPALAPA', '2111D001', '27/06/2022', 'DG-128', '0', '5', '125', 0.00, 7.00, 0.00, 35.00, 875.00

	--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('PERIODO DEL ' , FORMAT(@p_FechaInicio, 'dd \de MMMM \del yyyy', 'es-MX') , ' AL ' ,  FORMAT(@p_FechaFin, 'dd \de MMMM \del yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tblRepKardexporArticulo
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_ReporteEdoFlujoEfec]';
GO
-- exec [Conta].[SPR_ReporteEdoFlujoEfec] '2025-05-01','2025-05-30'
CREATE OR ALTER PROCEDURE [Conta].[SPR_ReporteEdoFlujoEfec]
	 @p_FecInicio nvarchar(24),
	@p_FecFin nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	

	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'ReporteEdoFlujoEfec'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')


	SELECT id=1,Concepto = CAST('Flujo de Efectivo de las Actividades de Operación' as nvarchar(500)), [Anio1] = '', [Anio2] = ''
	into #tlbReporteEdoFlujoEfec
	UNION
	SELECT id=2,Concepto = 'Origen' , [2023] = '19,715,058.00', [2024] = '19,715,058.00'
	UNION
	SELECT id=3,Concepto = 'Impuestos' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=4,Concepto = 'Cuotas y Aportaciones de Seguridad Social' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=5,Concepto = 'Contribuciones de Mejoras' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=6,Concepto = 'Derechos' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=7,Concepto = 'Productos' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=8,Concepto = 'Aprovechamiento' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=9,Concepto = 'Ingresos por Ventas de Bienes y Prestación de Servicios' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=10,Concepto = 'Participaciones, Aportaciones, Convenios, Incentivos Derivados de la Colaboración Fiscal y Fondos Distintos de Aportaciones' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=11,Concepto = 'Transferencias, Asignaciones, Subsidios Subvenciones y Pensiones y Jubilaciones' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=12,Concepto = 'Otros Orígenes de Operación' , [2023] = '19,715,058.00', [2024] = '19,718,759.00'
	UNION
	SELECT id=13,Concepto = 'Aplicación' , [2023] = '37,339,840.00', [2024] = '38,134,248.00'
	UNION
	SELECT id=14,Concepto = 'Servicios Personales' , [2023] = '19,033,387.00', [2024] = '19,827,795.00'
	UNION
	SELECT id=15,Concepto = 'Materiales y Suministros' , [2023] = '1,128,044.00', [2024] = '1,128,044.00'
	UNION
	SELECT id=16,Concepto = 'Servicios Generales' , [2023] = '17,178,409.00', [2024] = '17,178,409.00'
	UNION
	SELECT id=17,Concepto = 'Transferencias Internas y Asignaciones al Sector Público' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=18,Concepto = 'Subsidios y Subvenciones' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=19,Concepto = 'Ayudas Sociales' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=20,Concepto = 'Pensiones y Jubilaciones' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=21,Concepto = 'Transferencias a Fideicomisos, Mandatos y Contratos Análogos' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=22,Concepto = 'Transferencias a la Seguridad Social' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=23,Concepto = 'Donativos' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=24,Concepto = 'Transferencias al Exterior' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=25,Concepto = 'Participaciones' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=26,Concepto = 'Aportaciones' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=27,Concepto = 'Convenios' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=28,Concepto = 'Otras Aplicaciones de Operación' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=29,Concepto = 'Flujos Netos de Efectivo por Actividades de Operación' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=30,Concepto = 'Flujos de Efectivo de las Actividades de Inversión' , [2023] = '', [2024] = ''
	UNION
	SELECT id=31,Concepto = 'Origen' , [2023] = '-37,339,840.00', [2024] = '-38,134,248.00'
	UNION
	SELECT id=32,Concepto = 'Bienes Inmuebles, Infraestructura y Construcciones en Proceso' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=33,Concepto = 'Bienes Muebles' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=34,Concepto = 'Otros Orígenes de Inversión' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=35,Concepto = 'Aplicación' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=36,Concepto = 'Bienes Inmuebles, Infraestructura y Construcciones en Proceso ' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=37,Concepto = 'Bienes Muebles' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=38,Concepto = 'Otras Aplicaciones de Inversión' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=39,Concepto = 'Flujos Netos de Efectivo por Actividades de Inversión' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=40,Concepto = 'Flujos de Efectivo de las Actividades de Financiamiento' , [2023] = '', [2024] = ''
	UNION
	SELECT id=41,Concepto = 'Origen' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=42,Concepto = 'Endeudamiento Neto' , [2023] = '', [2024] = ''
	UNION
	SELECT id=43,Concepto = 'Interno' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=44,Concepto = 'Externo' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=45,Concepto = 'Otros Orígenes de Financiamiento' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=46,Concepto = 'Aplicación' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=47,Concepto = 'Servicios de la Deuda' , [2023] = '', [2024] = ''
	UNION
	SELECT id=48,Concepto = 'Interno' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=49,Concepto = 'Externo' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=50,Concepto = 'Otras Aplicaciones de Financiamiento' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=51,Concepto = 'Flujos Neto de Efectivo por Actividades de Financiamiento' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=52,Concepto = 'Incremento / Disminución Neta en el Efectivo y Equivalentes al Efectivo' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=53,Concepto = 'Efectivo y Equivalentes al Efectivo al Inicio del Ejercicio' , [2023] = '0.00', [2024] = '0.00'
	UNION
	SELECT id=54,Concepto = 'Efectivo y Equivalentes al Efectivo al Final del Ejercicio' , [2023] = '0.00', [2024] = '0.00'
	

	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('DEL ' , FORMAT(@p_FechaInicio, 'dd \de MMMM \del yyyy', 'es-MX') , ' AL ' ,  FORMAT(@p_FechaFin, 'dd \de MMMM \del yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tlbReporteEdoFlujoEfec
	--FIN
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepPasivosContingentes]';
GO
-- exec [CONTA].[SPR_RepPasivosContingentes] '2025-05-01','2025-05-30'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepPasivosContingentes]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepPasivosContingentes'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	SELECT Rubro = 'Servicios Personales', Monto = '$ 1,250,000.00'
	INTO #tblPasivoContingente
	UNION
	SELECT 'Materiales y Suministros', '$ 320,000.00'
	UNION
	SELECT 'Servicios Generales', '$ 410,500.00'
	UNION
	SELECT 'Transferencias y Subsidios', '$ 980,000.00'
	UNION
	SELECT 'Bienes Muebles e Intangibles', '$ 210,000.00'
	UNION
	SELECT 'Inversión Pública', '$ 1,500,000.00'
	UNION
	SELECT 'Deuda Pública', '$ 670,000.00'
	--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('DEL ' , FORMAT(@p_FechaInicio, 'dd \de MMMM \del yyyy', 'es-MX') , ' AL ' ,  FORMAT(@p_FechaFin, 'dd \de MMMM \del yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tblPasivoContingente
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepProyEgresos]';
GO
-- exec [CONTA].[SPR_RepProyEgresos] '2025-05-01','2025-05-30'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepProyEgresos]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepProyEgresos'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	SELECT id = 1, Concepto = '1. Gasto No Etiquetado', [AnioC] = NULL, [Anio1] = NULL, [Anio2] = NULL, [Anio3] = NULL, [Anio5] = NULL
	INTO #tblProyeccionDeEgresos
	UNION
	SELECT 2, 'A. Servicios Personales', '$ 500,000.00', '$ 510,000.00', '$ 520,000.00', '$ 530,000.00', '$ 550,000.00'
	UNION
	SELECT 3, 'B. Materiales y Suministros', '$ 120,000.00', '$ 125,000.00', '$ 130,000.00', '$ 135,000.00', '$ 140,000.00'
	UNION
	SELECT 4, 'C. Servicios Generales', '$ 150,000.00', '$ 155,000.00', '$ 160,000.00', '$ 165,000.00', '$ 170,000.00'
	UNION
	SELECT 5, 'D. Transferencias, Asignaciones, Subsidios y Otras Ayudas', '$ 300,000.00', '$ 310,000.00', '$ 320,000.00', '$ 330,000.00', '$ 350,000.00'
	UNION
	SELECT 6, 'E. Bienes Muebles, Inmuebles e Intangibles', '$ 100,000.00', '$ 105,000.00', '$ 110,000.00', '$ 115,000.00', '$ 120,000.00'
	UNION
	SELECT 7, 'F. Inversión Pública', '$ 400,000.00', '$ 410,000.00', '$ 420,000.00', '$ 430,000.00', '$ 450,000.00'
	UNION
	SELECT 8, 'G. Inversiones Financieras y Otras Provisiones', '$ 80,000.00', '$ 82,000.00', '$ 84,000.00', '$ 86,000.00', '$ 90,000.00'
	UNION
	SELECT 9, 'H. Participaciones y Aportaciones', '$ 200,000.00', '$ 205,000.00', '$ 210,000.00', '$ 215,000.00', '$ 220,000.00'
	UNION
	SELECT 10, 'I. Deuda Pública', '$ 50,000.00', '$ 52,000.00', '$ 54,000.00', '$ 56,000.00', '$ 60,000.00'
	UNION
	SELECT 11, '2. Gasto Etiquetado', NULL, NULL, NULL, NULL, NULL
	UNION
	SELECT 12, 'A. Servicios Personales', '$ 600,000.00', '$ 610,000.00', '$ 620,000.00', '$ 630,000.00', '$ 650,000.00'
	UNION
	SELECT 13, 'B. Materiales y Suministros', '$ 130,000.00', '$ 135,000.00', '$ 140,000.00', '$ 145,000.00', '$ 150,000.00'
	UNION
	SELECT 14, 'C. Servicios Generales', '$ 160,000.00', '$ 165,000.00', '$ 170,000.00', '$ 175,000.00', '$ 180,000.00'
	UNION
	SELECT 15, 'D. Transferencias, Asignaciones, Subsidios y Otras Ayudas', '$ 310,000.00', '$ 320,000.00', '$ 330,000.00', '$ 340,000.00', '$ 360,000.00'
	UNION
	SELECT 16, 'E. Bienes Muebles, Inmuebles e Intangibles', '$ 110,000.00', '$ 115,000.00', '$ 120,000.00', '$ 125,000.00', '$ 130,000.00'
	UNION
	SELECT 17, 'F. Inversión Pública', '$ 420,000.00', '$ 430,000.00', '$ 440,000.00', '$ 450,000.00', '$ 470,000.00'
	UNION
	SELECT 18, 'G. Inversiones Financieras y Otras Provisiones', '$ 85,000.00', '$ 87,000.00', '$ 89,000.00', '$ 91,000.00', '$ 95,000.00'
	UNION
	SELECT 19, 'H. Participaciones y Aportaciones', '$ 210,000.00', '$ 215,000.00', '$ 220,000.00', '$ 225,000.00', '$ 230,000.00'
	UNION
	SELECT 20, 'I. Deuda Pública', '$ 55,000.00', '$ 57,000.00', '$ 59,000.00', '$ 61,000.00', '$ 65,000.00'
	UNION
	SELECT 21, '3. Total de Egresos Proyectados', '$ 3,580,000.00', '$ 3,680,000.00', '$ 3,780,000.00', '$ 3,880,000.00', '$ 4,080,000.00'
	--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('DEL ' , FORMAT(@p_FechaInicio, 'dd \de MMMM \del yyyy', 'es-MX') , ' AL ' ,  FORMAT(@p_FechaFin, 'dd \de MMMM \del yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tblProyeccionDeEgresos
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepProyIngresos]';
GO
-- exec [CONTA].[SPR_RepProyIngresos] '2025-05-01'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepProyIngresos]
	  @p_FecInicio nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepProyIngresos'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	SELECT [ID] = 1, [CONCEPTO] = '1. Ingresos de Libre Disposición', [2025] = 85000000.00 , [2026] = 87000000.00 , [2027] = 89000000.00 , [2028] = 91000000.00 , [2029] = 93000000.00 , [2030] = 95000000.00  
	INTO #tblRepProyIngre
	UNION 
	SELECT 2, 'A. Impuestos', 30000000.00, 31000000.00, 32000000.00, 33000000.00, 34000000.00, 35000000.00
	UNION 
	SELECT 3, 'B. Cuotas y Aportaciones de Seguridad Social', 5000000.00, 5200000.00, 5300000.00, 5400000.00, 5500000.00, 5600000.00
	UNION 
	SELECT 4, 'C. Contribuciones de Mejoras', 800000.00, 850000.00, 870000.00, 900000.00, 920000.00, 950000.00
	UNION 
	SELECT 5, 'D. Derechos', 4000000.00, 4200000.00, 4300000.00, 4400000.00, 4500000.00, 4600000.00
	UNION 
	SELECT 6, 'E. Productos', 2500000.00, 2600000.00, 2700000.00, 2800000.00, 2900000.00, 3000000.00
	UNION 
	SELECT 7, 'F. Aprovechamientos', 1200000.00, 1250000.00, 1300000.00, 1350000.00, 1400000.00, 1450000.00
	UNION 
	SELECT 8, 'G. Ingresos por Ventas de Bienes y Servicios', 1800000.00, 1850000.00, 1900000.00, 1950000.00, 2000000.00, 2050000.00
	UNION 
	SELECT 9, 'H. Participaciones', 12000000.00, 12200000.00, 12400000.00, 12600000.00, 12800000.00, 13000000.00
	UNION 
	SELECT 10, 'I. Incentivos Derivados de la Colaboración Fiscal', 2000000.00, 2100000.00, 2200000.00, 2300000.00, 2400000.00, 2500000.00
	UNION 
	SELECT 11, 'J. Transferencias', 6000000.00, 6100000.00, 6200000.00, 6300000.00, 6400000.00, 6500000.00
	UNION 
	SELECT 12, 'K. Convenios', 3000000.00, 3100000.00, 3200000.00, 3300000.00, 3400000.00, 3500000.00
	UNION 
	SELECT 13, 'L. Otros Ingresos de Libre Disposición', 5000000.00, 5100000.00, 5200000.00, 5300000.00, 5400000.00, 5500000.00

	UNION 
	SELECT 14, '2. Transferencias Federales Etiquetadas', 65000000.00, 67000000.00, 69000000.00, 71000000.00, 73000000.00, 75000000.00
	UNION 
	SELECT 15, 'A. Aportaciones', 35000000.00, 36000000.00, 37000000.00, 38000000.00, 39000000.00, 40000000.00
	UNION 
	SELECT 16, 'B. Convenios', 12000000.00, 12500000.00, 13000000.00, 13500000.00, 14000000.00, 14500000.00
	UNION 
	SELECT 17, 'C. Fondos Distintos de Aportaciones', 8000000.00, 8200000.00, 8400000.00, 8600000.00, 8800000.00, 9000000.00
	UNION 
	SELECT 18, 'D. Transferencias, Subsidios y Subvenciones, y Pensiones y Jubilaciones', 8000000.00, 8500000.00, 9000000.00, 9500000.00, 10000000.00, 10500000.00
	UNION 
	SELECT 19, 'E. Otras Transferencias Federales Etiquetadas', 2000000.00, 2100000.00, 2200000.00, 2300000.00, 2400000.00, 2500000.00

	UNION 
	SELECT 20, '3. Ingresos Derivados de Financiamientos', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00
	UNION 
	SELECT 21, 'A. Ingresos Derivados de Financiamientos', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00

	UNION 
	SELECT 22, '4. Total de Ingresos Proyectados', 150000000.00, 154000000.00, 158000000.00, 162000000.00, 166000000.00, 170000000.00


	--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('', FORMAT(@p_FechaInicio, 'dd \de MMMM \del yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tblRepProyIngre
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepResultIngresos]';
GO
-- exec [CONTA].[SPR_RepResultIngresos] '2025-07-01'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepResultIngresos]
	  @p_FecInicio nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepResultIngresos'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	SELECT ID = 1, [concepto] = '1. Ingresos de Libre Disposición ', [2020] = 466813153.00, [2021] = 486435611.00 , [2022] = 486554486.00 , [2023] = 492837844.00 , [2024] = 492331181.00, 
	[2025] = 512495160.00
	INTO #tblRepResultIngresos
	UNION 
	SELECT 2, 'A. Impuestos', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 3, 'B. Cuotas y Aportaciones de Seguridad Social', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 4, 'C. Contribuciones de Mejoras', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 5, 'D. Derechos', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 6, 'E. Productos', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 7, 'F. Aprovechamientos', 698571.00, 159645.00, 96349.00, 142526.00, 453474.00, 19629.00
	UNION 
	SELECT 8, 'G. Ingresos por Ventas de Bienes y Servicios', 251028.00, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 9, 'H. Participaciones', 38525.00, 3036.00, NULL, 55388.00, 335404.00, 645890
	UNION 
	SELECT 10, 'I. Incentivos Derivados de la Colaboración Fiscal', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 11, 'J. Transferencias', 465825029.00, 486272930.00, 486458137.00, 492639930.00, 491542303.00, 511829641.00
	UNION 
	SELECT 12, 'K. Convenios', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 13, 'L. Otros Ingresos de Libre Disposición', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 14, '2. Transferencias Federales Etiquetadas', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 15, 'A. Aportaciones', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 16, 'B. Convenios', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 17, 'C. Fondos Distintos de Aportaciones', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 18, 'D. Transferencias, Subsidios y Subvenciones, y Pensiones y Jubilaciones', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 19, 'E. Otras Transferencias Federales Etiquetadas', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 20, '3. Ingresos Derivados de Financiamientos', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 21, 'A. Ingresos Derivados de Financiamientos', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 22, '4. Total de Resultados de  Ingresos', 466813153.00, 486435611.00, 486554486.00, 492837844.00, 492331181.00, 512495160.00
	UNION 
	SELECT 23, 'Datos Informativos', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 24, '1. Ingresos Derivados de Financiamientos con Fuente de Pago de Recursos de Libre Disposición', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 25, '2. Ingresos derivados de Financiamientos con Fuente de Pago de Transferencias Federales Etiquetadas', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 26, '3. Ingresos Derivados de Financiamiento', NULL, NULL, NULL, NULL, NULL, NULL

	--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('' , FORMAT(@p_FechaInicio, 'dd \de MMMM \del yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tblRepResultIngresos
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_RepRetenciones]';
GO
-- exec [CONTA].[SPR_RepRetenciones] '2025-05-01','2025-05-30'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepRetenciones]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepRetenciones'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	SELECT id = 1, [Concepto] = 'IMPUESTO SOBRE LA RENTA (ISR)', 
       [Inicial] = '$ 50,000.00', [RetenidoPeriodo] = '$ 12,000.00', 
       [EnteradoPeriodo] = '$ 10,000.00', [PorEnterar] = '$ 52,000.00'
	INTO #tblRepRetenciones
	UNION
	SELECT 2, 'RETENCIONES DE ISR POR SUELDOS Y SALARIOS', 
		   '$ 30,000.00', '$ 8,000.00', '$ 7,500.00', '$ 30,500.00'
	UNION
	SELECT 3, 'RETENCIONES DE ISR POR SERVICIOS PROFESIONALES (HONORARIOS)', 
		   '$ 10,000.00', '$ 3,000.00', '$ 2,800.00', '$ 10,200.00'
	UNION
	SELECT 4, 'RETENCIONES DE ISR POR PAGOS AL EXTRANJERO', 
		   '$ 5,000.00', '$ 1,500.00', '$ 1,000.00', '$ 5,500.00'
	UNION
	SELECT 5, 'RETENCIONES DE ISR POR HONORARIOS ASIMILADOS A SALARIOS', 
		   '$ 7,500.00', '$ 2,000.00', '$ 1,800.00', '$ 7,700.00'
	UNION
	SELECT 6, 'ISR POR PAGOS POR CUENTA DE TERCEROS O RETENCIONES POR ARRENDAMIENTO DE INMUEBLES', 
		   '$ 6,000.00', '$ 1,200.00', '$ 1,000.00', '$ 6,200.00'
	UNION
	SELECT 7, 'RETENCIONES DE ISR POR REGIMEN SIMPLICADO DE CONFIANZA', 
		   '$ 4,000.00', '$ 900.00', '$ 800.00', '$ 4,100.00'
	UNION
	SELECT 8, 'IMPUESTO AL VALOR AGREGADO', 
		   '$ 60,000.00', '$ 15,000.00', '$ 14,000.00', '$ 61,000.00'
	UNION
	SELECT 9, 'RETENCIONES DE IVA', 
		   '$ 20,000.00', '$ 5,000.00', '$ 4,500.00', '$ 20,500.00'
	UNION
	SELECT 10, 'IVA ACTOS ACCIDENTALES', 
		   '$ 2,000.00', '$ 500.00', '$ 400.00', '$ 2,100.00'


	--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('DEL ' , FORMAT(@p_FechaInicio, 'yyyy', 'es-MX') , ' AL ' ,  FORMAT(@p_FechaFin, 'yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tblRepRetenciones
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [CONTA].[SPR_ResultadoEgresos]';
GO
-- exec [CONTA].[SPR_ResultadoEgresos] '2025-05-01','2025-05-30'
CREATE OR ALTER PROCEDURE [CONTA].[SPR_ResultadoEgresos]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepResultEgre'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')


	SELECT id=1,Concepto = CAST('1. Gasto No Etiquetado' as nvarchar(500)), [Año5] = '', [Año4] = '', [Año3] = '',
		   [Año2] = '', [Año1] = '', [Vigente] = ''
	INTO #tblResultadoDeEgresos
	UNION
	SELECT 2, 'A. Servicios Personales',        '$ 150,000.00', '$ 155,000.00', '$ 160,000.00', '$ 165,000.00', '$ 170,000.00', '$ 175,000.00'
	UNION
	SELECT 3, 'B. Materiales y Suministros',     '$ 40,000.00',  '$ 42,000.00',  '$ 43,000.00',  '$ 45,000.00',  '$ 47,000.00',  '$ 50,000.00'
	UNION
	SELECT 4, 'C. Servicios Generales',          '$ 35,000.00',  '$ 36,000.00',  '$ 38,000.00',  '$ 39,000.00',  '$ 40,000.00',  '$ 42,000.00'
	UNION
	SELECT 5, 'D. Transferencias, Asignaciones, Subsidios y Otras Ayudas','$ 25,000.00',  '$ 26,000.00',  '$ 27,000.00',  '$ 28,000.00',  '$ 30,000.00',  '$ 32,000.00'
	UNION
	SELECT 6, 'E. Bienes Muebles, Inmuebles e Intangibles','$ 10,000.00',  '$ 11,000.00',  '$ 12,000.00',  '$ 13,000.00',  '$ 13,500.00',  '$ 14,000.00'
	UNION
	SELECT 7, 'F. Inversión Pública',            '$ 5,000.00',   '$ 5,500.00',   '$ 6,000.00',   '$ 6,500.00',   '$ 7,000.00',   '$ 8,000.00'
	UNION
	SELECT 8, 'G. Inversiones Financieras y Otras Provisiones','$ 3,000.00',   '$ 3,200.00',   '$ 3,500.00',   '$ 3,800.00',   '$ 4,000.00',   '$ 4,200.00'
	UNION
	SELECT 9, 'H. Participaciones y Aportaciones', '$ 7,000.00',   '$ 7,500.00',   '$ 8,000.00',   '$ 8,500.00',   '$ 9,000.00',   '$ 9,500.00'
	UNION
	SELECT 10, 'I. Deuda Pública',              '$ 2,000.00',   '$ 2,200.00',   '$ 2,300.00',   '$ 2,400.00',   '$ 2,600.00',   '$ 2,800.00'
	UNION
	SELECT 11, 'Subtotal Gasto No Etiquetado',  '$ 277,000.00', '$ 288,400.00', '$ 299,800.00', '$ 311,200.00', '$ 323,100.00', '$ 337,500.00'
	UNION
	SELECT 12, '2. Gasto Etiquetado', '', '', '', '', '', ''
	UNION
	SELECT 13, 'A. Servicios Personales',       '$ 180,000.00', '$ 185,000.00', '$ 190,000.00', '$ 195,000.00', '$ 200,000.00', '$ 210,000.00'
	UNION
	SELECT 14, 'B. Materiales y Suministros',   '$ 30,000.00',  '$ 32,000.00',  '$ 33,000.00',  '$ 34,000.00',  '$ 35,000.00',  '$ 36,000.00'
	UNION
	SELECT 15, 'C. Servicios Generales',        '$ 28,000.00',  '$ 29,000.00',  '$ 30,000.00',  '$ 31,000.00',  '$ 32,000.00',  '$ 33,000.00'
	UNION
	SELECT 16, 'D. Transferencias, Asignaciones, Subsidios y Otras Ayudas','$ 40,000.00',  '$ 41,000.00',  '$ 42,000.00',  '$ 43,000.00',  '$ 44,000.00',  '$ 45,000.00'
	UNION
	SELECT 17, 'E. Bienes Muebles, Inmuebles e Intangibles','$ 15,000.00',  '$ 15,500.00',  '$ 16,000.00',  '$ 16,500.00',  '$ 17,000.00',  '$ 18,000.00'
	UNION
	SELECT 18, 'F. Inversión Pública',          '$ 20,000.00',  '$ 21,000.00',  '$ 22,000.00',  '$ 23,000.00',  '$ 24,000.00',  '$ 25,000.00'
	UNION
	SELECT 19, 'G. Inversiones Financieras y Otras Provisiones','$ 5,000.00',   '$ 5,200.00',   '$ 5,400.00',   '$ 5,600.00',   '$ 5,800.00',   '$ 6,000.00'
	UNION
	SELECT 20, 'H. Participaciones y Aportaciones','$ 10,000.00',  '$ 10,500.00',  '$ 11,000.00',  '$ 11,500.00',  '$ 12,000.00',  '$ 12,500.00'
	UNION
	SELECT 21, 'I. Deuda Pública',              '$ 3,000.00',   '$ 3,100.00',   '$ 3,200.00',   '$ 3,300.00',   '$ 3,400.00',   '$ 3,600.00'
	UNION
	SELECT 22, 'Subtotal Gasto Etiquetado',     '$ 331,000.00', '$ 342,300.00', '$ 352,600.00', '$ 362,900.00', '$ 373,200.00', '$ 389,100.00'

	UNION
	SELECT 23, '3. Total del Resultado de Egresos','$ 608,000.00', '$ 630,700.00', '$ 652,400.00', '$ 674,100.00', '$ 696,300.00', '$ 726,600.00'


	--FIN
	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('DEL ' , FORMAT(@p_FechaInicio, 'dd \de MMMM \del yyyy', 'es-MX') , ' AL ' ,  FORMAT(@p_FechaFin, 'dd \de MMMM \del yyyy', 'es-MX')) AS NVARCHAR(128))
	FROM #tblResultadoDeEgresos
	
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [ALMA].[SPR_LibroAlmacenSuministros]';
GO
CREATE OR ALTER PROCEDURE [ALMA].[SPR_LibroAlmacenSuministros]
	@Error NVARCHAR(MAX) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRAN;

	----------------------------------------------
	
	SET LANGUAGE 'español';
			---***********************
			WITH Existencias   -- @Tabla que agrupa, sumariza las existencias
				AS (			

						SELECT TB.PK_IdTipoBien
						, TB.FK_IdPartida__SIS
						, GB.CLAVE_CUCOP AS CUCOP
						,  GB.CABM_ACT + ' / ' + GB.ClaveAN  AS CABMS
						,   TB.CodigoClave
						, TB.Descripcion
						, SUM(aa.Cantidad) AS Existencias
						, au.Descripcion AS Unidades
						, aa.FKIdAnio_SIS, CAST('' AS VARCHAR(MAX)) AS Message
						, IIF(TB.Cantidad_Equivalente > 1,TB.FK_IdUnidades_Equivalente,TB.FK_IdUnidades__ALMA) AS FK_IdUnidades__ALMA
						,aa.Costo AS CostoUnitario  -- Llenar en el stript desde el costo de factura
						,aa.Costo AS CostoPromedio  -- Calcular
						FROM     ALMA.Almacen AS aa 
								INNER JOIN SICOP.TipoBien AS TB ON aa.FK_IdTipoBien__SICOP = TB.PK_IdTipoBien 
								INNER JOIN ALMA.Unidades AS au ON IIF(TB.Cantidad_Equivalente > 1,TB.FK_IdUnidades_Equivalente,TB.FK_IdUnidades__ALMA) = au.PK_IdUnidades 
								INNER JOIN SICOP.GrupoBien as GB ON TB.FK_IdGrupoBien__SICOP = GB.PK_IdGrupoBien
						WHERE aa.InventarioCerrado = 0 AND AA.Activo = 1 AND TB.Activo = 1 AND AU.Activo = 1 AND GB.Activo = 1
						GROUP BY TB.PK_IdTipoBien, TB.FK_IdPartida__SIS,  GB.CLAVE_CUCOP,  GB.CABM_ACT, GB.ClaveAN, TB.CodigoClave, TB.Descripcion, au.Descripcion, aa.FKIdAnio_SIS, IIF(TB.Cantidad_Equivalente > 1,TB.FK_IdUnidades_Equivalente,TB.FK_IdUnidades__ALMA), aa.Costo

						UNION ALL 

						SELECT TB.PK_IdTipoBien, TB.FK_IdPartida__SIS
							, GB.CLAVE_CUCOP AS CUCOP
							, GB.CABM_ACT + ' / ' + GB.ClaveAN  AS CABMS
							, TB.CodigoClave
							, TB.Descripcion
							, CI.Existencias
							, AU.Descripcion AS Unidades
							, CI.FKIdAnio_SIS
							, '' AS Message	
							, IIF(TB.Cantidad_Equivalente > 1, TB.FK_IdUnidades_Equivalente,TB.FK_IdUnidades__ALMA) AS FK_IdUnidades__ALMA
							, CI.CostoExistencias  -- TODO  Cambiar a CostoUnitario despues de la magia de Alex
							, CI.CostoPromedioEntradasMes
						FROM     SICOP.TipoBien AS TB 
								INNER JOIN SICOP.GrupoBien GB ON TB.FK_IdGrupoBien__SICOP = GB.PK_IdGrupoBien
								INNER JOIN ALMA.Unidades AS AU ON IIF(TB.Cantidad_Equivalente > 1,TB.FK_IdUnidades_Equivalente,TB.FK_IdUnidades__ALMA) = AU.PK_IdUnidades 
								RIGHT OUTER JOIN ALMA.CierreInventario AS CI ON TB.PK_IdTipoBien = CI.FK_IdTipoBien__SICOP
						WHERE TB.Activo = 1 AND GB.Activo = 1 AND AU.Activo = 1 AND CI.Activo = 1
				)	

				SELECT	E.[PK_IdTipoBien],
					ISNULL(CC.ClaveNombre, 'Configure Cuenta') as Codigo,
					-- E.[FK_IdPartida__SIS],
					-- E.[CUCOP],
					-- E.[CABMS],
					-- E.[CodigoClave],
					E.[Descripcion] ,
					SUM(E.[Existencias]) AS Cantidad,
					E.[Unidades],
					-- 0 [FKIdAnio_SIS] ,
					E.FK_IdUnidades__ALMA,
					isnull(MAX(E.CostoPromedio),0) AS CostoUnitario,  --TODO Revisar estas formulas  ROG 20250525
					SUM(E.[Existencias]) * isnull(MAX(E.CostoPromedio),0) AS Monto
					
				FROM Existencias E 
				JOIN SICOP.TipoBien TB ON E.PK_IdTipoBien = TB.PK_IdTipoBien
				LEFT JOIN CONTA.VW_CUENTAS CC ON TB.FKIdCuentaContable_CONTA = CC.Pk_IdCuenta
				WHERE TB.Activo = 1
				GROUP BY 
					CC.ClaveNombre,
					E.[PK_IdTipoBien],
					E.[FK_IdPartida__SIS],
					E.[CUCOP],
					E.[CABMS],
					E.[CodigoClave],
					E.[Descripcion] ,
					E.[Unidades],
					--E.[FKIdAnio_SIS],
					TB.ExistenciaMinima, 
					TB.ExistenciaMaxima,
					E.FK_IdUnidades__ALMA
					--E.CostoUnitario,
					--E.CostoPromedio

			---***********************
	IF (@@ERROR <> 0) BEGIN SET @Error = @@ERROR; GOTO ERR_HANDLER; END
	
	COMMIT TRAN;
	RETURN 0;
			
	ERR_HANDLER:
	IF @@TRANCOUNT > 0 COMMIT;
	ELSE ROLLBACK;
	RETURN 1;
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [ALMA].[SPR_LibroAlmacenSuministros_DevEx]';
GO
CREATE OR ALTER PROCEDURE [ALMA].[SPR_LibroAlmacenSuministros_DevEx]
	@FechaInicio datetime,-- = 
	@FechaFin datetime,-- = 
	@Error NVARCHAR(MAX) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRAN;

	----------------------------------------------
	
	DECLARE @FK_IdPersona__RHCT INT,
	        @FK_IdModulo__SIS INT,
	        @Funcion NVARCHAR(50),
	        @Nombre NVARCHAR(50),
	        @Puesto NVARCHAR(100);
	
	IF (@@ERROR <> 0) BEGIN SET @Error = @@ERROR; GOTO ERR_HANDLER; END
	
	SELECT @Nombre = PE.Nombre + ' ' + PE.Paterno + ' ' + PE.Materno,
	       @Puesto = PU.Descripcion1
	  FROM RHCT.Persona PE, RHCT.PersonaPlaza PP, RHCT.PlazaAutorizada PA, RHCT.Puesto PU
	 WHERE PE.PK_IdPersona = @FK_IdPersona__RHCT
	   AND PE.PK_IdPersona = PP.FK_IdPersona__RHCT
	   AND PA.PK_IdPlazaAutorizada = PP.FK_IdPlazaAutorizada__RHCT
	   AND PA.FK_IdPuesto__RHCT = PU.PK_IdPuesto
	   AND PE.Activo = 1
	   AND PP.Activo = 1
	   AND PA.Activo = 1
	   AND PU.Activo = 1;
	IF (@@ERROR <> 0) BEGIN SET @Error = @@ERROR; GOTO ERR_HANDLER; END
	
	SET LANGUAGE 'español';
			SELECT 
				   PE.Clave AS ClavePersona,
				   PE.Nombre + ' ' + PE.Paterno + ' ' + PE.Materno AS Persona,
				   NombreAutoriza = @Nombre,
				   PuestoAutoriza = @Puesto,
				   PuestoSolicita = PU.Descripcion1,
				   
				   SS.Observaciones AS DescripcionSolicitud,
				   RIGHT('00'+DATEPART(DD,SS.FechaSolicitudSalida),2) AS Dia,
				   DATENAME(MONTH,SS.FechaSolicitudSalida) AS Mes,
				   DATEPART(YYYY,SS.FechaSolicitudSalida) AS Anio,
				   ROW_NUMBER() OVER (ORDER BY SS.FechaSolicitudSalida) AS Consecutivo,
				   CONVERT(NVARCHAR,SS.FechaSolicitudSalida,103) AS FechaSolicitud,
					AR.Clave AS ClaveArea,
					AR.Nombre AS Area,
					SS.Clave AS NumeroVale,
					TB.CodigoClave AS ClaveArticulo,
					LEFT(TB.CABMS,4) AS Partida,
					GB.Descripcion AS Subcuenta,
					'PROGRAMA' as Programa,
					DS.Cantidad,
					UN.Descripcion AS Unidad,
					TB.Descripcion AS DesArticulo,
					DS.Cantidad as Salidas,
					(SELECT TOP 1 CP.CostoPromedio
							FROM ALMA.CostoPromedio CP
							WHERE CP.FK_IdTipoBien__SICOP = TB.PK_IdTipoBien ) AS CostoUnitario,
					(SELECT TOP 1 CP.CostoPromedio 
							FROM ALMA.CostoPromedio CP
							WHERE CP.FK_IdTipoBien__SICOP = TB.PK_IdTipoBien ) * DS.Cantidad AS Monto							
				   
			FROM ALMA.SolicitudSalida SS,
					ALMA.DetalleSolicitudSalida DS,
					ALMA.Almacen AL,
					SICOP.TipoBien TB,
					SICOP.GrupoBien GB,
					ALMA.Unidades UN,
					SIS.Area AR,
					RHCT.Persona PE, 
					RHCT.PersonaPlaza PP, 
					RHCT.PlazaAutorizada PA, 
					RHCT.Puesto PU
			 WHERE SS.FK_IdArea__SIS = AR.PK_IdArea
				AND SS.FK_IdPersona__RHCT = PE.PK_IdPersona
				AND DS.FK_IdSolicitudSalida__ALMA = SS.PK_IdSolicitudSalida
				AND DS.FK_IdTipoBien__SICOP = TB.PK_IdTipoBien
				AND TB.FK_IdGrupoBien__SICOP = GB.PK_IdGrupoBien
				AND DS.FK_IdUnidades__ALMA = UN.PK_IdUnidades
				AND AL.FK_IdDetalleSolicitudSalida__ALMA = DS.PK_IdDetalleSolicitudSalida
				AND SS.FechaSolicitudSalida BETWEEN @FechaInicio AND @FechafIN
			   AND PE.PK_IdPersona = PP.FK_IdPersona__RHCT
			   AND PA.PK_IdPlazaAutorizada = PP.FK_IdPlazaAutorizada__RHCT
			   AND PA.FK_IdPuesto__RHCT = PU.PK_IdPuesto
			   AND PE.Activo = 1
			   AND PP.Activo = 1
			   AND PA.Activo = 1
			   AND PU.Activo = 1
			   --AND AR.Activo = 1
			   AND SS.Activo = 1
			   AND DS.Activo = 1 order by FechaSolicitud

	IF (@@ERROR <> 0) BEGIN SET @Error = @@ERROR; GOTO ERR_HANDLER; END
	
	COMMIT TRAN;
	RETURN 0;
			
	ERR_HANDLER:
	IF @@TRANCOUNT > 0 COMMIT;
	ELSE ROLLBACK;
	RETURN 1;
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [ORCO].[SPR_EstadoActividad]';
GO
-- =============================================
-- Author:		JCOL
-- Create date: 01/05/2013
-- Description:	REPORTE DE VALE DE SALIDA
-- =============================================
-- =============================================
-- Editor:		[.0.
-- Create date: 01/05/2013
-- Description:	Se arraglaron firmasAutorizadas,
--				Se corrigieron nombres de los nodos para coincidir con Flex
--				Se agregó CostoPromedio y CostoTotal
-- =============================================
-- =============================================
-- Editor:		[.0.
-- Create date: 14/08/2013
-- Description:	Costo promedio viene ahora de la tabla ALMA.CostoPromedio
-- Nota: Siempre saldrá el costo promedio al momento de llamar al reporte, no el costo promedio a la fecha de la salida
-- =============================================

-- exec [ORCO].[SPR_EstadoActividad] 0
CREATE OR ALTER PROCEDURE [ORCO].[SPR_EstadoActividad]
	 @PK_Id INT NULL
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	

	SELECT id=1,Concepto = CAST('INGRESOS Y OTROS BENEFICIOS' as nvarchar(500)), [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=2,Concepto = '  Ingresos de Gestión', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=3,Concepto = '    Impuestos', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=4,Concepto = '    Cuotas y Aportaciones de Seguridad Social', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=5,Concepto = '    Contribuciones de Mejoras', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=6,Concepto = '    Derechos', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=7,Concepto = '    Productos', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=8,Concepto = '    Aprovechamientos', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=9,Concepto = '    Ingresos por Venta de Bienes y Prestación de Servicios', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=10,Concepto = ' ', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	--
	UNION
	SELECT id=12,Concepto = '  Participaciones, Aportaciones, Convenios, Incentivos Derivados de la Colaboración Fiscal, Fondos Distintos de Aportaciones, Transferencias, Asignaciones, Subsidios y Subvenciones, y Pensiones y Jubilaciones', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=13,Concepto = '    Participaciones, Aportaciones, Convenios, Incentivos Derivados de la Colaboración Fiscal y Fondos Distintos de Aportaciones', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=14,Concepto = '    Transferencias, Asignaciones, Subsidios y Subvenciones, y Pensiones y Jubilaciones', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=15,Concepto = ' ', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	--
	UNION
	SELECT id=16,Concepto = '  Otros Ingresos y Beneficios', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=17,Concepto = '    Ingresos Financieros', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=18,Concepto = '    Incremento por Variación de Inventarios', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=19,Concepto = '    Disminución del Exceso de Estimaciones por Pérdida o Deterioro u Obsolescencia', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=20,Concepto = '    Disminución del Exceso de Provisiones', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=21,Concepto = '    Otros Ingresos y Beneficios Varios', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=22,Concepto = ' ', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	--
	UNION
	SELECT id=23,Concepto = 'Total de Ingresos y Otros Beneficios', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=24,Concepto = ' ', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	--
	UNION
	SELECT id=25,Concepto = 'GASTOS Y OTRAS PÉRDIDAS', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=26,Concepto = '  Gastos de Funcionamiento', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=27,Concepto = '    Servicios Personales', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=28,Concepto = '    Materiales y Suministros', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=29,Concepto = '    Servicios Generales', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=30,Concepto = ' ', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	--
	UNION
	SELECT id=31,Concepto = '  Transferencias, Asignaciones, Subsidios y Otras Ayudas', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=32,Concepto = '    Transferencias Internas y Asignaciones al Sector Público', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=33,Concepto = '    Transferencias al Resto del Sector Público', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=34,Concepto = '    Subsidios y Subvenciones', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=35,Concepto = '    Ayudas Sociales', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=36,Concepto = '    Pensiones y Jubilaciones', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=37,Concepto = '    Transferencias a Fideicomisos, Mandatos y Contratos Análogos', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=38,Concepto = '    Transferencias a la Seguridad Social', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=39,Concepto = '    Donativos', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=40,Concepto = '    Transferencias al Exterior', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=41,Concepto = ' ', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	--
	UNION
	SELECT id=42,Concepto = '  Participaciones y Aportaciones', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=43,Concepto = '    Participaciones', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=44,Concepto = '    Aportaciones', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=45,Concepto = '    Convenios', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=46,Concepto = ' ', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	--
	UNION
	SELECT id=47,Concepto = '  Intereses, Comisiones y Otros Gastos de la Deuda Pública', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=48,Concepto = '    Intereses de la Deuda Pública', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=49,Concepto = '    Comisiones de la Deuda Pública', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=50,Concepto = '    Gastos de la Deuda Pública', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=51,Concepto = '    Costo por Coberturas', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=52,Concepto = '    Apoyos Financieros', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=53,Concepto = ' ', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	--
	UNION
	SELECT id=54,Concepto = '  Otros Gastos y Pérdidas Extraordinarias', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=55,Concepto = '    Estimaciones, Depreciaciones, Deterioros, Obsolescencia y Amortizaciones', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=56,Concepto = '    Provisiones', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=57,Concepto = '    Disminución de Inventarios', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=58,Concepto = '    Otros Gastos', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=59,Concepto = ' ', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	--
	UNION
	SELECT id=60,Concepto = '  Inversión Pública', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=61,Concepto = '    Inversión Pública no Capitalizable', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=62,Concepto = ' ', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	--
	UNION
	SELECT id=63,Concepto = 'Total de Gastos y Otras Pérdidas', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=64,Concepto = ' ', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	--
	UNION
	SELECT id=65,Concepto = 'Resultados del Ejercicio (Ahorro/Desahorro)', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	UNION
	SELECT id=66,Concepto = ' ', [20XN] = 0, [20XN1] = 0, Firma1 = 'Eliseo', Firma2 = 'Yo', Firma3 = 'otro yo'
	--FIN
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [PRES].[SPR_PY]';
GO
-- =============================================
-- Author:		ROG
-- Create date: 20250521
-- Description:	Este SP es para poblar el formato de Proyectos PY
-- =============================================


CREATE OR ALTER PROCEDURE [PRES].[SPR_PY]
	@idPY int

AS
BEGIN
	SET NOCOUNT ON;

	
SELECT [PKIdPY]
      ,[Clave]
      ,[Descripcion]
      ,[NombreProyecto]
      ,[InicioProyecto]
      ,[FinProyecto]
      ,[Plurianual]
      ,[TieneTICS]
      ,[EsPAT]
      ,[AnexosTransversales]
      ,[ProgramaPresupuestario]
      ,[ProyectoInversion]
      ,[RecursosAdicionales]
      ,[Prioridad]
      ,[FuenteFinanciamiento]
      ,[DescripcionProyecto]
      ,[ResponsableProyecto]
      ,[ObjetivoProyecto]
      ,[LineaEstrategica]
      ,[LineaAccionRegulatoria]
      ,[TemaAccionRegulatoria]
      ,[FundamentoLegal]
      ,[Justificacion]
      ,[Beneficios]
      ,[Indicador]
      ,[Meta]
  FROM [PRES].[PY]
	WHERE PKIdPY  = @idPY
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [SICOP].[SPR_LibroInventarioBienes]';
GO
-- exec [SICOP].[SPR_LibroInventarioBienes] '2025-05-31'
CREATE OR ALTER PROCEDURE [SICOP].[SPR_LibroInventarioBienes]
	@p_FecInicio nvarchar(24)
		AS 
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	DECLARE @p_FechaInicio DATE = @p_FecInicio
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,' ' ,p.Paterno, ' ' ,p.Materno)
		FROM [SIS].[Reporte] R (NOLOCK)
		JOIN [SIS].[FirmaAutorizada] F (NOLOCK) ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P (NOLOCK) ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = 'RepLibroInventarioBienes'
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre1 + '%') ,'')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre2 + '%') ,'')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, ' ', paterno, ' ' , materno) like '%' + @Nombre3 + '%') ,'')

	SELECT bn.PK_IdBien
      --,bn.FK_IdTipoBien__SICOP
	  --,TB.CodigoClave
      ,bn.Clave AS NumeroInventario
      ,bn.Descripcion
	  ,1 as Cantidad
	  ,Un.Descripcion as Unidades
      ,bn.Costo
	  , bn.Costo * 1  as Monto
      --,bn.ValorRescate
      --,bn.ValorActual
		,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT('AL ', UPPER(FORMAT(@p_FechaInicio, 'dd \DE MMMM \DEL yyyy', 'es-MX'))) AS NVARCHAR(128))
  FROM [SICOP].[VW_Bien] Bn
  JOIN SICOP.TipoBien TB ON Bn.FK_IdTipoBien__SICOP = TB.PK_IdTipoBien
  JOIN ALMA.Unidades Un ON Tb.FK_IdUnidades_Equivalente = Un.PK_IdUnidades
  ORDER BY Bn.Clave
END

GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
PRINT N'Aplicando [SICOP].[SPR_LibroInventarioBienes_DevEx]';
GO
CREATE OR ALTER PROCEDURE [SICOP].[SPR_LibroInventarioBienes_DevEx]
		@FechaFin datetime
		AS 
BEGIN
	SET NOCOUNT ON;
	SELECT '13P' as URG, Clave as Codigo, GrupoBien as Descripcion, Clave, TipoBien, '1' as cantidad, Costo, 'Pza' as unidad, costo as Monto
	FROM dbo.pivotBien where FechaAdq <= @FechaFin and costo >0 and Persona <> '' AND PK_IDBIEN NOT IN (SELECT FK_IdBien__SICOP FROM SICOP.Bajas)
	ORDER BY Clave; 
END

GO
