-- Generado a partir de los modulos actuales; no contiene copias de datos.
SET NOCOUNT ON; SET XACT_ABORT ON; SET LOCK_TIMEOUT 5000;
IF DB_NAME() <> N'GestionEmpresarial' THROW 51200, 'Destino incorrecto.', 1;
IF (SELECT is_read_committed_snapshot_on FROM sys.databases WHERE database_id=DB_ID())<>1 THROW 51201, 'Se requiere RCSI activo.', 1;
BEGIN TRY
BEGIN TRANSACTION;
-- [ALMA].[SP_CargaInicialConteo] : hints retirados=0; XACT_ABORT=True
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(1514488474))),2) <> '6EC1094D638F53378B7BCE61B9120E64A5914A7317F02544B9660EC76CB362E9' OR OBJECT_DEFINITION(1514488474) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'
ALTER   PROCEDURE [ALMA].[SP_CargaInicialConteo]
    @P_Partida INT = NULL,
    @P_Periodo INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @P_Periodo IS NULL OR NOT EXISTS
    (
        SELECT 1
        FROM [ALMA].[PeriodoConteo]
        WHERE [PKIdPeriodoConteo] = @P_Periodo
          AND [Activo] = 1
    )
    BEGIN
        THROW 51013, ''El periodo de conteo es requerido y debe estar activo.'', 1;
    END;

    IF @P_Partida IS NOT NULL AND (@P_Partida <= 20000 OR @P_Partida >= 30000)
    BEGIN
        THROW 51012, ''Solo se permiten partidas del capitulo 20000.'', 1;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE E
        FROM [ALMA].[ConteoDetalleEscaneo] E
        INNER JOIN [ALMA].[Conteo] C ON C.[PKIdConteo] = E.[FKIdConteo_ALMA]
        WHERE C.[FKIdPeriodoConteo_ALMA] = @P_Periodo;

        DELETE D
        FROM [ALMA].[ConteoDetalle] D
        INNER JOIN [ALMA].[Conteo] C ON C.[PKIdConteo] = D.[FKIdConteo_ALMA]
        WHERE C.[FKIdPeriodoConteo_ALMA] = @P_Periodo;

        DELETE FROM [ALMA].[Conteo]
        WHERE [FKIdPeriodoConteo_ALMA] = @P_Periodo;

        INSERT INTO [ALMA].[Conteo]
        (
            [FKIdTipoBien_ALMA],
            [CantidadInventario],
            [Descripcion],
            [FechaInicio],
            [FKIdPeriodoConteo_ALMA],
            [Activo],
            [FechaCreacion],
            [UsuarioCreacion]
        )
        SELECT
            E.[PKIdTipoBien],
            SUM(ISNULL(E.[Existencias], 0)),
            MAX(E.[Descripcion]),
            SYSDATETIME(),
            @P_Periodo,
            1,
            SYSDATETIME(),
            1
        FROM [ALMA].[Vw_Existencias] E
        INNER JOIN [ALMA].[TipoBien] TB ON TB.[PKIdTipoBien] = E.[PKIdTipoBien]
        WHERE TB.[Activo] = 1
          AND TB.[FKIdPartida_CONTA] > 20000
          AND TB.[FKIdPartida_CONTA] < 30000
          AND (@P_Partida IS NULL OR TB.[FKIdPartida_CONTA] = @P_Partida)
          AND ISNULL(E.[Existencias], 0) > 0
        GROUP BY E.[PKIdTipoBien];

        COMMIT TRANSACTION;

        SELECT JSON_QUERY(CONCAT(
            ''{"tipo":"OK","mensaje":"Carga inicial generada para el periodo '',
            @P_Periodo,
            ''.","liga":""}''
        )) AS ResultJson;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
';
-- [CONTA].[SPR_EstadoAnaliticoDelActivo] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(1946490013))),2) <> '89031C714A31ED98DB1501550D921A1409BB54D339A480E9584BD08800FA784C' OR OBJECT_DEFINITION(1946490013) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_EstadoAnaliticoDelActivo] ''2025-05-01'',''2025-05-30''
ALTER   PROCEDURE [CONTA].[SPR_EstadoAnaliticoDelActivo]
	  @p_FecInicio nvarchar(24),
	@p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''RepAnaActi''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')


	SELECT id=1,Concepto = CAST(''Activo'' as nvarchar(500)), [SI] = ''$ 2,222,891,419.00 '', [CP] = ''$ 11,960.00 '', [AP] = ''$ 0.00'', [SF] = ''$ 2,222,903,379.00'', [VP] = ''''
	INTO #tblEstadoAnaliticoDelActivo
	UNION
	SELECT id=2,Concepto = ''Activo Circulante '', [SI] = ''$ 2,222,891,419.00'', [CP] = ''$ 11,960.00'', [AP] = ''$ 0.00'', [SF] = ''$ 2,222,903,379.00'', [VP] = ''$ 11,960.00''
	UNION
	SELECT id=3,Concepto = ''Efectivo y Equivalentes'', [SI] = ''$ 149,981,834.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ 149,981,834.00'', [VP] = ''$ 0.00''
	UNION
	SELECT id=4,Concepto = ''Derechos a Recibir Efectivo o Equivalentes'', [SI] = ''$ 2,336,111,208.00'', [CP] = ''$ 11,960.00'', [AP] = ''$ 0.00'', [SF] = ''$ 2,336,123,168.00'', [VP] = ''$ 11,960.00''
	UNION
	SELECT id=5,Concepto = ''Derechos a Recibir Bienes o Servicios'', [SI] = ''$ 0.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ 0.00'', [VP] = ''$ 0.00''
	UNION
	SELECT id=6,Concepto = ''Inventarios'', [SI] = ''$ 0.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ 0.00'', [VP] = ''$ 0.00''
	UNION
	SELECT id=7,Concepto = ''Almacenes'', [SI] = ''$ 650,258.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ 650,258.00'', [VP] = ''$ 0.00''
	UNION
	SELECT id=8,Concepto = ''Estimación por Pérdida o Deterioro de Activos Circulantes'', [SI] = ''$ -263,851,881.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ -263,851,881.00'', [VP] = ''$ 0.00''
	UNION
	SELECT id=9,Concepto = ''Otros Activos Circulantes'', [SI] = ''$ 0.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ 0.00'', [VP] = ''$ 0.00''
	--
	UNION
	SELECT id=10,Concepto = ''ACTIVOS NO CIRCULANTES'', [SI] = '''', [CP] = '''', [AP] = '''', [SF] = '''', [VP] = ''''
	--
	UNION
	SELECT id=11,Concepto = ''Inversiones Financieras a Largo Plazo'', [SI] = ''$ 0.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ 0.00'', [VP] = ''$ 0.00''
	UNION
	SELECT id=12,Concepto = ''Derechos a Recibir Efectivo o Equivalentes a Largo Plazo'', [SI] = ''$ 0.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ 0.00'', [VP] = ''$ 0.00''
	UNION
	SELECT id=13,Concepto = ''Bienes Inmuebles, Infraestructura y Construcciones en Proceso'', [SI] = '''', [CP] = '''', [AP] = '''', [SF] = '''', [VP] = ''''
	UNION
	--
	SELECT id=14,Concepto = ''Bienes Muebles'', [SI] = ''$ 7,162,122.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ 7,162,122.00'', [VP] = ''$ 0.00''
	UNION
	SELECT id=15,Concepto = ''Activos Intangibles'', [SI] = ''$ 2,541,228.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ 2,541,228.00'', [VP] = ''$ 0.00''
	UNION
	SELECT id=16,Concepto = ''Depreciación, Deterioro y Amortización Acumulada de Bienes'', [SI] = ''$ -5,934,956.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ -5,934,956.00'', [VP] = ''$ 0.00''
	UNION
	SELECT id=17,Concepto = ''Activos Diferidos'', [SI] = ''$ 0.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ 0.00'', [VP] = ''$ 0.00''
	UNION
	SELECT id=18,Concepto = ''Estimación por Pérdida o Deterioro de Activos No Circulantes'', [SI] = ''$ 0.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ 0.00'', [VP] = ''$ 0.00''
	UNION
	SELECT id=19,Concepto = ''Otros Activos no Circulantes'', [SI] = ''$ 0.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ 0.00'', [VP] = ''$ 0.00''
	


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
		, Titulo = CAST(CONCAT(''DEL '' , FORMAT(@p_FechaInicio, ''dd \de MMMM \del yyyy'', ''es-MX'') , '' AL '' ,  FORMAT(@p_FechaFin, ''dd \de MMMM \del yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tblEstadoAnaliticoDelActivo
	
END';
-- [CONTA].[SPR_EstadoAnaliticoDeudaPasivos] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(1962490070))),2) <> '5C3FC19A4BFEF6265444AE194CFB88ED4BA3CD4B381D09500D6C487CCF479E8A' OR OBJECT_DEFINITION(1962490070) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_EstadoAnaliticoDeudaPasivos] ''2024-01-01'',''2024-01-30''
ALTER   PROCEDURE [CONTA].[SPR_EstadoAnaliticoDeudaPasivos]
	 @p_FecInicio nvarchar(24),
	@p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin

	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''RepEstadoAnaDeuda''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')

	SELECT id=1,DD = CAST(''DEUDA PÚBLICA'' as nvarchar(500)), [MC] = '''', [I] = '''', [SI] = ''0'', [SF] = ''0''
	into #tlbRepEstadoAnaliticoDeudaPasivos
	UNION
	SELECT id=2,DD = ''			Corto Plazo'', [MC] = '''', [I] = '''', [SI] = '''', [SF] = ''''
	UNION
	SELECT id=3,DD = '''', [MC] = '''', [I] = '''', [SI] = '''', [SF] = ''''
	UNION
	SELECT id=4,DD = '''', [MC] = '''', [I] = '''', [SI] = '''', [SF] = ''''
	UNION
	SELECT id=5,DD = '''', [MC] = '''', [I] = '''', [SI] = '''', [SF] = ''''
	UNION
	SELECT id=6,DD = '''', [MC] = '''', [I] = '''', [SI] = '''', [SF] = ''''
	UNION
	SELECT id=7,DD = '''', [MC] = '''', [I] = '''', [SI] = '''', [SF] = ''''
	UNION
	SELECT id=8,DD = '''', [MC] = '''', [I] = '''', [SI] = '''', [SF] = ''''
	UNION
	SELECT id=9,DD = '''', [MC] = '''', [I] = '''', [SI] = '''', [SF] = ''''
	UNION
	SELECT id=10,DD = '''', [MC] = '''', [I] = '''', [SI] = '''', [SF] = ''''
	UNION
	SELECT id=11,DD = '''', [MC] = '''', [I] = '''', [SI] = '''', [SF] = ''''
	UNION
	SELECT id=12,DD = '''', [MC] = '''', [I] = '''', [SI] = '''', [SF] = ''''
	UNION
	SELECT id=13,DD = '''', [MC] = '''', [I] = '''', [SI] = '''', [SF] = ''''
	UNION
	SELECT id=14,DD = '''', [MC] = '''', [I] = '''', [SI] = '''', [SF] = ''''
	UNION
	SELECT id=15,DD = '''', [MC] = '''', [I] = '''', [SI] = '''', [SF] = ''''
	UNION
	SELECT id=16,DD = '''', [MC] = '''', [I] = '''', [SI] = '''', [SF] = ''''
	UNION
	SELECT id=17,DD = '''', [MC] = '''', [I] = '''', [SI] = '''', [SF] = ''''
	UNION
	SELECT id=18,DD = '''', [MC] = '''', [I] = '''', [SI] = '''', [SF] = ''''
	UNION
	SELECT id=19,DD = '''', [MC] = '''', [I] = '''', [SI] = '''', [SF] = ''''
	UNION
	SELECT id=20,DD = '''', [MC] = '''', [I] = '''', [SI] = '''', [SF] = ''''
	UNION
	SELECT id=21,DD = '''', [MC] = '''', [I] = '''', [SI] = '''', [SF] = ''''
	--UNION
	--SELECT id=,DD = '''', [MC] = '''', [I] = '''', [SI] = '''', [SF] = ''''
	
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
		, Titulo = CAST(CONCAT(''DEL '' , FORMAT(@p_FechaInicio, ''dd \de MMMM \del yyyy'', ''es-MX'') , '' AL '' ,  FORMAT(@p_FechaFin, ''dd \de MMMM \del yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tlbRepEstadoAnaliticoDeudaPasivos

	
END';
-- [CONTA].[SPR_EstadoDeSitucionFinanciera] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(1978490127))),2) <> 'A7D438DC1909D4B40CFD767E5D473FAA909F7C34A901B729BBDFAE408B9E777D' OR OBJECT_DEFINITION(1978490127) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- =============================================
-- Author:		JCOL
-- CREATE OR ALTER date: 01/05/2013
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
ALTER   PROCEDURE [CONTA].[SPR_EstadoDeSitucionFinanciera]
	 @p_FecInicio nvarchar(24),
	@p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''RepEstadoCambiosSitFin''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')


	SELECT id=1,Concepto1 = CAST(''ACTIVO'' as nvarchar(500)), [A2023] = '''', [A2024] = '''',Concepto2 =''PASIVO'', [P2023] = '''', [P2024] = ''''
	INTO #tlbEstadoDeSitucionFinanciera
	UNION
	SELECT id=2,Concepto1 = ''ACTIVO CIRCULANTE'', [A2023] = '''', [A2024] = '''',Concepto2 =''PASIVO CIRCULANTE'', [P2023] = '''', [P2024] = ''''
	UNION
	SELECT id=3,Concepto1 = ''Efectivo y Equivalentes'', [A2023] = ''149,981,834.00'', [A2024] = ''149,981,834.00'',Concepto2 =''Cuentas por Pagar a Corto Plazo'', [P2023] = ''-32,518,832.00'', [P2024] = ''-31,969,450.00''
	UNION
	SELECT id=4,Concepto1 = ''Derechos a Recibir Efectivo o Equivalentes'', [A2023] = ''2,336,111,208.00'', [A2024] = ''2,336,123,168.00'',Concepto2 =''Documentos por Pagar a Corto Plazo'', [P2023] = ''2,541,228.00'', [P2024] = ''2,541,228.00''
	UNION
	SELECT id=6,Concepto1 = ''Derechos a Recibir Bienes o Servicios'', [A2023] = ''0.00'', [A2024] = ''0.00'',Concepto2 =''Porción a Corto Plazo de la Deuda Pública a Largo Plazo'', [P2023] = ''0.00'', [P2024] = ''0.00''
	UNION
	SELECT id=7,Concepto1 = ''Inventarios'', [A2023] = ''0.00'', [A2024] = ''0.00'',Concepto2 =''Títulos y Valores a Corto Plazo'', [P2023] = ''0.00'', [P2024] = ''0.00''
	UNION
	SELECT id=8,Concepto1 = ''Almacenes'', [A2023] = ''650,258.00'', [A2024] = ''650,258.00'',Concepto2 =''Pasivos Diferidos a Corto Plazo'', [P2023] = ''2,541,228.00'', [P2024] = ''2,541,228.00''
	UNION
	SELECT id=9,Concepto1 = ''Estimación por Pérdida o Deterioro de Activos Circulantes'', [A2023] = ''-263,851,881.00'', [A2024] = ''-263,851,881.00'',Concepto2 =''Fondos y Bienes de Terceros en Garantía y/o Administración a Corto Plazo'', [P2023] = ''2,541,228.00'', [P2024] = ''2,541,228.00''
	UNION
	SELECT id=10,Concepto1 = ''Otros Activos Circulantes'', [A2023] = ''0.00'', [A2024] = ''0.00'',Concepto2 =''Provisiones a Corto Plazo'', [P2023] = ''4,902,525.00'', [P2024] = ''4,902,525.00''
	UNION
	SELECT id=11,Concepto1 = '''', [A2023] = '''', [A2024] = '''',Concepto2 =''Otros Pasivos a Corto Plazo'', [P2023] = ''0.00'', [P2024] = ''0.00''
	UNION
	SELECT id=12,Concepto1 = ''Total de Activos Circulantes'', [A2023] = ''2,222,891,419.0'', [A2024] = ''2,222,903,379.0'',Concepto2 =''Otros Pasivos a Corto Plazo'', [P2023] = ''-29,797,673.00'', [P2024] = ''-29,248,291.00''
	UNION
	SELECT id=13,Concepto1 = '''', [A2023] = '''', [A2024] = '''',Concepto2 ='''', [P2023] = '''', [P2024] = ''''
	--
	UNION
	SELECT id=15,Concepto1 = ''Activo No Circulante'', [A2023] = '''', [A2024] = '''',Concepto2 =''Pasivo No Circulante'', [P2023] = '''', [P2024] = ''''
	UNION
	SELECT id=16,Concepto1 = ''Inversiones financieras a Largo Plazo '', [A2023] = ''0.00'', [A2024] = ''0.00'',Concepto2 =''Cuentas por Pagar a Largo Plazo'', [P2023] = ''0.00'', [P2024] = ''0.00''
	UNION
	SELECT id=17,Concepto1 = ''Derechos a Recibir Efectivo o Equivalentes a Largo Plazo'', [A2023] = ''0.00'', [A2024] = ''0.00'',Concepto2 =''Documentos por Pagar a Largo Plazo'', [P2023] = ''0.00'', [P2024] = ''0.00''
	UNION
	SELECT id=18,Concepto1 = ''Bienes Inmuebles, Infraestructura y Construcciones en Proceso'', [A2023] = ''0.00'', [A2024] = ''0.00'',Concepto2 =''Deuda Pública a Plazo'', [P2023] = ''0.00'', [P2024] = ''0.00''
	UNION
	SELECT id=19,Concepto1 = ''Bienes Muebles'', [A2023] = ''7,162,122.00'', [A2024] = ''7,162,122.00'',Concepto2 =''Pasivos Diferidos a Largo Plazo'', [P2023] = ''0.00'', [P2024] = ''0.00''
	UNION
	SELECT id=20,Concepto1 = ''Activos Intangibles'', [A2023] = ''2,541,228.00'', [A2024] = ''2,541,228.00'',Concepto2 =''Fondos y Bienes de Terceros en Garantía y/o Administración Largo Plazo'', [P2023] = ''0.00'', [P2024] = ''0.00''
	UNION
	SELECT id=21,Concepto1 = ''Depreciación, Deterioro y Amortización Acumulada de Bienes'', [A2023] = ''-5,934,956.00'', [A2024] = ''-5,934,956.00'',Concepto2 =''Provisiones a Largo Plazo'', [P2023] = ''0.00'', [P2024] = ''0.00''
	UNION
	SELECT id=22,Concepto1 = ''Activos Diferidos'', [A2023] = ''2,541,228.00'', [A2024] = ''2,541,228.00'',Concepto2 ='''', [P2023] = '''', [P2024] = ''''
	UNION
	SELECT id=23,Concepto1 = ''Estimación por Perdida o Deterioro de Activos no Circulantes'', [A2023] = ''0.00'', [A2024] = ''0.00'',Concepto2 =''Total de Pasivos No Circulantes'', [P2023] = ''0.00'', [P2024] = ''0.00''
	UNION
	SELECT id=24,Concepto1 = ''Otros Activos no Circulantes'', [A2023] = ''0.00'', [A2024] = ''0.00'',Concepto2 ='''', [P2023] = '''', [P2024] = ''''
	UNION
	SELECT id=25,Concepto1 = '''', [A2023] = '''', [A2024] = '''',Concepto2 =''Total del Pasivo'', [P2023] = ''0.00'', [P2024] = ''0.00''
	UNION
	SELECT id=26,Concepto1 = '''', [A2023] = '''', [A2024] = '''',Concepto2 =''HACIENDA PÚBLICA / PATRIMONIO'', [P2023] = '''', [P2024] = ''''
	UNION
	SELECT id=28,Concepto1 = '''', [A2023] = '''', [A2024] = '''',Concepto2 =''Hacienda Pública / Patrimonio Contribuido'', [P2023] = ''-3,112,907,042.'', [P2024] = ''-3,112,907,042.''
	UNION
	SELECT id=29,Concepto1 = '''', [A2023] = '''', [A2024] = '''',Concepto2 ='''', [P2023] = '''', [P2024] = ''''
	--
	UNION
	SELECT id=30,Concepto1 = '''', [A2023] = '''', [A2024] = '''',Concepto2 =''Aportaciones'', [P2023] = ''-3,112,907,042.'', [P2024] = ''-3,112,907,042.''
	UNION
	SELECT id=31,Concepto1 = '''', [A2023] = '''', [A2024] = '''',Concepto2 ='''', [P2023] = '''', [P2024] = ''''
	--
	UNION
	SELECT id=32,Concepto1 = '''', [A2023] = '''', [A2024] = '''',Concepto2 =''Donaciones de Capital '', [P2023] = ''0.00'', [P2024] = ''0.00''
	UNION
	SELECT id=33,Concepto1 = '''', [A2023] = '''', [A2024] = '''',Concepto2 =''Actualización de la Hacienda Publica/Patrimonio'', [P2023] = ''0.00'', [P2024] = ''0.00''
	UNION
	SELECT id=34,Concepto1 = '''', [A2023] = '''', [A2024] = '''',Concepto2 =''Hacienda Pública / Patrimonio Generado'', [P2023] = ''61,949,312.00'', [P2024] = ''61,949,312.00''
	UNION
	SELECT id=35,Concepto1 = '''', [A2023] = '''', [A2024] = '''',Concepto2 =''Resultados del Ejercicio (Ahorro / Desahorro)'', [P2023] = ''532,861,201.00'', [P2024] = ''532,861,201.00''
	UNION
	SELECT id=36,Concepto1 = '''', [A2023] = '''', [A2024] = '''',Concepto2 =''Resultados de Ejercicios Anteriores'', [P2023] = ''-471,636,791.00'', [P2024] = ''-471,636,791.00''
	UNION
	SELECT id=37,Concepto1 = '''', [A2023] = '''', [A2024] = '''',Concepto2 =''Revalúos'', [P2023] = ''724,902.00'', [P2024] = ''724,902.00''
	UNION
	SELECT id=38,Concepto1 = '''', [A2023] = '''', [A2024] = '''',Concepto2 =''Reservas'', [P2023] = ''0.00'', [P2024] = ''0.00''
	UNION
	SELECT id=39,Concepto1 = '''', [A2023] = '''', [A2024] = '''',Concepto2 =''Rectificaciones de Resultados de Ejercicios Anteriores'', [P2023] = ''0.00'', [P2024] = ''0.00''
	UNION
	SELECT id=40,Concepto1 = '''', [A2023] = '''', [A2024] = '''',Concepto2 =''Exceso o Insuficiencia en la Actualización de la Hacienda Pública/Patrimonio'', [P2023] = ''0.00'', [P2024] = ''0.00''
	UNION
	SELECT id=41,Concepto1 = '''', [A2023] = '''', [A2024] = '''',Concepto2 =''Resultado por Posición Monetaria'', [P2023] = ''0.00'', [P2024] = ''0.00''
	UNION
	SELECT id=42,Concepto1 = '''', [A2023] = '''', [A2024] = '''',Concepto2 =''Resultado por Tenencia de Activos no Monetarios'', [P2023] = ''0.00'', [P2024] = ''0.00''
	UNION
	SELECT id=43,Concepto1 = ''Total de Activos No Circulantes'', [A2023] = ''6,309,622.00'', [A2024] = ''6,309,622.00'',Concepto2 =''Total Hacienda Pública / Patrimonio'', [P2023] = ''-3,050,957,730.'', [P2024] = ''-3,050,957,730.''
	UNION
	SELECT id=44,Concepto1 = '''', [A2023] = '''', [A2024] = '''',Concepto2 ='''', [P2023] = '''', [P2024] = ''''
	--
	UNION
	SELECT id=45,Concepto1 = ''Total de Activo'', [A2023] = ''2,229,201,041.0 '', [A2024] = ''2,229,213,001.0'',Concepto2 =''Total del Pasivo y Hacienda Pública / Patrimonio'', [P2023] = ''-3,050,957,730.'', [P2024] = ''-3,050,957,730.''
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
		, Titulo = CAST(CONCAT(''DEL '' , FORMAT(@p_FechaInicio, ''dd \de MMMM \del yyyy'', ''es-MX'') , '' AL '' ,  FORMAT(@p_FechaFin, ''dd \de MMMM \del yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tlbEstadoDeSitucionFinanciera

END';
-- [CONTA].[SPR_EstadoVariacionHaciendaPublica] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(2026490298))),2) <> 'FAE336DA066825D665C343B3E21DE6AB30D76179BC1EA43F3FD37808CB39A670' OR OBJECT_DEFINITION(2026490298) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_EstadoVariacionHaciendaPublica] ''2024-01-01'',''2024-01-30'' 
ALTER   PROCEDURE [CONTA].[SPR_EstadoVariacionHaciendaPublica]
	 @p_FecInicio nvarchar(24), -- = ''20250101'', 
	@p_FecFin nvarchar(24)-- = ''20250131'', 
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @FechaInicio datetime = @p_FecInicio,	-- = ''20250101'', 
	@FechaFin datetime	= @p_FecFin	-- = ''20250131'', 


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
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''RepVariacionHdaPub''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')

	SELECT id=1,Concepto = CAST(''Hacienda Pública / Patrimonio Contribuido Neto de 2024'' as nvarchar(500)), [HP/PC] = ''-3,112,907,042.00'', [HP/PGEA] = ''0.00'',[HP/PGE] =''0.00'', [EIAHP/P] = ''0.00'', [Total] = ''-3,112,907,042.00''
	into #tlbEstadoVariacionHaciendaPublica
	UNION
	SELECT id=2,Concepto = ''Aportaciones'', [HP/PC] = ''-3,112,907,042.00'', [HP/PGEA] = ''0.00'',[HP/PGE] =''0.00'', [EIAHP/P] = ''0.00'', [Total] = ''-3,112,907,042.00''
	UNION
	SELECT id=3,Concepto = ''Donaciones de Capital'', [HP/PC] = ''0.00'', [HP/PGEA] = ''0.00'',[HP/PGE] =''0.00'', [EIAHP/P] = ''0.00'', [Total] = ''0.00''
	UNION
	SELECT id=4,Concepto = ''Actualizacion de la Hacienda Pública / Patrimonio'', [HP/PC] = ''0.00'', [HP/PGEA] = ''0.00'',[HP/PGE] =''0.00'', [EIAHP/P] = ''0.00'', [Total] = ''0.00''
	UNION
	SELECT id=5,Concepto = ''Hacienda Pública / Patrimonio Generado Neto de 2024'', [HP/PC] = ''0.00'', [HP/PGEA] = ''-470,911,889.00'',[HP/PGE] =''532,861,201.00'', [EIAHP/P] = ''0.00'', [Total] = ''61,949,312.00''
	UNION
	SELECT id=6,Concepto = ''Resultados del Ejercicio (Ahorro / Desahorro)'', [HP/PC] = ''0.00'', [HP/PGEA] = ''0.00'',[HP/PGE] =''532,861,201.00'', [EIAHP/P] = ''0.00'', [Total] = ''532,861,201.00''
	UNION
	SELECT id=7,Concepto = ''Resultados de Ejercicios Anteriores'', [HP/PC] = ''0.00'', [HP/PGEA] = ''-471,636,791.00'',[HP/PGE] =''0.00'', [EIAHP/P] = ''0.00'', [Total] = ''-471,636,791.00''
	UNION
	SELECT id=8,Concepto = ''Revalúos'', [HP/PC] = ''0.00'', [HP/PGEA] = ''724,902.00 '',[HP/PGE] =''0.00'', [EIAHP/P] = ''0.00'', [Total] = ''724,902.00 ''
	UNION
	SELECT id=9,Concepto = ''Reservas'', [HP/PC] = ''0.00'', [HP/PGEA] = ''0.00'',[HP/PGE] =''0.00'', [EIAHP/P] = ''0.00'', [Total] = ''0.00''
	UNION
	SELECT id=10,Concepto = ''Rectificaciones de Resultados de Ejercicios Anteriores'', [HP/PC] = ''0.00'', [HP/PGEA] = ''0.00'',[HP/PGE] =''0.00'', [EIAHP/P] = ''0.00'', [Total] = ''0.00''
	UNION
	SELECT id=11,Concepto = ''Exceso o Insuficiencia en la Actualizacion de la Hacienda Pública / Patrimonio Neto de 2024'', [HP/PC] = ''0.00'', [HP/PGEA] = ''0.00'',[HP/PGE] =''0.00'', [EIAHP/P] = ''0.00'', [Total] = ''0.00''
	UNION
	SELECT id=12,Concepto = ''Resultado por Posición Monetaria'', [HP/PC] = ''0.00'', [HP/PGEA] = ''0.00'',[HP/PGE] =''0.00'', [EIAHP/P] = ''0.00'', [Total] = ''0.00''
	UNION
	SELECT id=13,Concepto = ''Resultado por Tenencia de Activos Monetarios'', [HP/PC] = ''0.00'', [HP/PGEA] = ''0.00'',[HP/PGE] =''0.00'', [EIAHP/P] = ''0.00'', [Total] = ''0.00''
	UNION
	SELECT id=14,Concepto = ''Hacienda Pública / Patrimonio Neto Final 2024'', [HP/PC] = ''-3,112,907,042.00'', [HP/PGEA] = ''-470,911,889.00'',[HP/PGE] =''532,861,201.00'', [EIAHP/P] = ''0.00'', [Total] = ''-3,112,907,042.00''
	UNION
	SELECT id=15,Concepto = ''Cambios en la Hacienda Pública / Patrimonio Contribuido Neto 2023'', [HP/PC] = ''-3,112,907,042.00'', [HP/PGEA] = ''0.00'',[HP/PGE] =''0.00'', [EIAHP/P] = ''0.00'', [Total] = ''-3,112,907,042.00''
	UNION
	SELECT id=16,Concepto = ''Aportaciones'', [HP/PC] = ''-3,112,907,042.00'', [HP/PGEA] = ''0.00'',[HP/PGE] =''0.00'', [EIAHP/P] = ''0.00'', [Total] = ''-3,112,907,042.00''
	UNION
	SELECT id=17,Concepto = ''Donaciones de Capital'', [HP/PC] = ''0.00'', [HP/PGEA] = ''0.00'',[HP/PGE] =''0.00'', [EIAHP/P] = ''0.00'', [Total] = ''0.00''
	UNION
	SELECT id=18,Concepto = ''Actualización de la Hacienda Pública / Patrimonio'', [HP/PC] = ''0.00'', [HP/PGEA] = ''0.00'',[HP/PGE] =''0.00'', [EIAHP/P] = ''0.00'', [Total] = ''0.00''
	UNION
	SELECT id=19,Concepto = ''Variaciones de la Hacienda Pública / Patrimonio Generado Neto de 2023'', [HP/PC] = ''0.00'', [HP/PGEA] = ''-471,636,791.00'',[HP/PGE] =''1,065,722,402.00'', [EIAHP/P] = ''0.00'', [Total] = ''0.00''
	UNION
	SELECT id=20,Concepto = ''Resultados del Ejercicio (Ahorro / Desahorro)'', [HP/PC] = ''0.00'', [HP/PGEA] = ''0.00'',[HP/PGE] =''532,861,201.00'', [EIAHP/P] = ''0.00'', [Total] = ''532,861,201.00''
	UNION
	SELECT id=21,Concepto = ''Resultados de Ejercicio Anteriores '', [HP/PC] = ''0.00'', [HP/PGEA] = ''-471,636,791.00'',[HP/PGE] =''532,861,201.00'', [EIAHP/P] = ''0.00'', [Total] = ''61,224,410.00''
	UNION
	SELECT id=22,Concepto = ''Revalúos'', [HP/PC] = ''0.00'', [HP/PGEA] = ''0.00'',[HP/PGE] =''0.00'', [EIAHP/P] = ''0.00'', [Total] = ''0.00''
	UNION
	SELECT id=23,Concepto = ''Reservas'', [HP/PC] = ''0.00'', [HP/PGEA] = ''0.00'',[HP/PGE] =''0.00'', [EIAHP/P] = ''0.00'', [Total] = ''0.00''
	UNION
	SELECT id=24,Concepto = ''Rectificaciones de Resultados de Ejercicios Anteriores'', [HP/PC] = ''0.00'', [HP/PGEA] = ''0.00'',[HP/PGE] =''0.00'', [EIAHP/P] = ''0.00'', [Total] = ''0.00''
	UNION
	SELECT id=25,Concepto = ''Cambios en el Exceso o Insuficiencia en la Actualización de la Hacienda Pública / Patrimonio Neto de 2023'', [HP/PC] = ''0.00'', [HP/PGEA] = ''0.00'',[HP/PGE] =''0.00'', [EIAHP/P] = ''0.00'', [Total] = ''0.00''
	UNION
	SELECT id=26,Concepto = ''Resultado por Posición Monetaria'', [HP/PC] = ''0.00'', [HP/PGEA] = ''0.00'',[HP/PGE] =''0.00'', [EIAHP/P] = ''0.00'', [Total] = ''0.00''
	UNION
	SELECT id=27,Concepto = ''Resultado por Tenencia de Activos Monetarios'', [HP/PC] = ''0.00'', [HP/PGEA] = ''0.00'',[HP/PGE] =''0.00'', [EIAHP/P] = ''0.00'', [Total] = ''0.00''
	UNION
	SELECT id=28,Concepto = ''Hacienda Pública / Patrimonio Neto Final de 2023'', [HP/PC] = ''-6,225,814,084.00'', [HP/PGEA] = ''-942,548,680.00'',[HP/PGE] =''1,598,583,603.00'', [EIAHP/P] = ''0.00'', [Total] = ''-3,112,907,042.00''

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
		, Titulo = CAST(CONCAT(''DEL '' , FORMAT(@FechaInicio, ''dd \de MMMM \del yyyy'', ''es-MX'') , '' AL '' ,  FORMAT(@FechaFin, ''dd \de MMMM \del yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tlbEstadoVariacionHaciendaPublica
	
END';
-- [CONTA].[SPR_LibroMayor] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(2122490640))),2) <> '0DBA05C0D3AE5BABCDED0BCE3F7FD47E987A9C5A73BC954FC5C941381514C05C' OR OBJECT_DEFINITION(2122490640) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
EXEC sys.sp_executesql N'ALTER   PROCEDURE [CONTA].[SPR_LibroMayor]
    @p_FecInicio NVARCHAR(24) = NULL,
    @p_FecFin NVARCHAR(24) = NULL,
    @NumCuenta INT = NULL,
    @EsCierre INT = 0
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
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
        CONCAT(P.Nombre, '' '', P.Paterno, '' '', P.Materno) AS Nombre
    FROM [SIS].[Reporte] AS R 
    INNER JOIN [SIS].[FirmaAutorizada] AS F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
    INNER JOIN [RHCT].[Persona] AS P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
    WHERE R.Controlador = ''RepLibroMayor''
      AND R.Activo = 1
      AND F.Activo = 1;

    DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 1), N'''');
    DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 2), N'''');
    DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 3), N'''');
    DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 1), N'''');
    DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 2), N'''');
    DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 3), N'''');
    DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP (1) Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, '' '', Paterno, '' '', Materno) LIKE ''%'' + @Nombre1 + ''%''), N'''');
    DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP (1) Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, '' '', Paterno, '' '', Materno) LIKE ''%'' + @Nombre2 + ''%''), N'''');
    DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP (1) Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, '' '', Paterno, '' '', Materno) LIKE ''%'' + @Nombre3 + ''%''), N'''');

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
            WHEN p.FKIdTipoPoliza_SIS = 1 THEN ''Dr''
            WHEN p.FKIdTipoPoliza_SIS = 2 THEN ''Eg''
            WHEN p.FKIdTipoPoliza_SIS = 3 THEN ''Ig''
            WHEN p.FKIdTipoPoliza_SIS = 4 THEN ''Pr''
        END AS VARCHAR(2)) AS TipoPoliza,
        CAST(CONVERT(VARCHAR(10), p.FechaPoliza, 103) + '' '' + ISNULL(dp.Descripcion, '''') AS VARCHAR(631)) AS ConceptoMovimiento,
        ISNULL((SELECT SUM(SaldoFinal) FROM @SaldoInicial), 0) AS SaldoInicial,
        dp.ImporteDebe AS Cargos,
        dp.ImporteHaber AS Abonos,
        dp.ImporteDebe AS Saldos,
        CAST('''' AS VARCHAR(1)) AS TotalSaldos,
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
        WHEN T.TipoCuenta = ''1'' THEN T.SaldoInicial - ISNULL(T.Cargos, 0) + ISNULL(T.Abonos, 0)
        WHEN T.TipoCuenta = ''2'' THEN T.SaldoInicial + ISNULL(T.Cargos, 0) - ISNULL(T.Abonos, 0)
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
            WHEN T.TipoCuenta = ''1'' THEN @SaldoInicialActual - ISNULL(T.Cargos, 0) + ISNULL(T.Abonos, 0)
            WHEN T.TipoCuenta = ''2'' THEN @SaldoInicialActual + ISNULL(T.Cargos, 0) - ISNULL(T.Abonos, 0)
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
        CAST(CONCAT(''DEL '', FORMAT(@FechaInicio, ''dd \de MMMM \del yyyy'', ''es-MX''), '' AL '', FORMAT(@FechaFin, ''dd \de MMMM \del yyyy'', ''es-MX'')) AS NVARCHAR(128)) AS Titulo
    FROM @tmp
    ORDER BY num;
END';
-- [CONTA].[SPR_RepAnaActi] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(7007106))),2) <> 'BF5F6AC2BD311496157B368ACB1564A75282ADDF60D87321B6D35FA4F13892A3' OR OBJECT_DEFINITION(7007106) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [Conta].[SPR_RepAnaActi] '''',''''
ALTER   PROCEDURE [Conta].[SPR_RepAnaActi]
	 @p_FecInicio nvarchar(24),
	@p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	

	DECLARE @FechaInicio DATE = @p_FecInicio, @FechaFin DATE = @p_FecFin

	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''RepAnaActi''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')

	SELECT id=1,Concepto = CAST(''Activo'' as nvarchar(500)), [SI] = ''$ 2,222,891,419.00 '', [CP] = ''$ 11,960.00 '', [AP] = ''$ 0.00'', [SF] = ''$ 2,222,903,379.00'', [VP] = ''''
	into #tlbRepAnaActiv
	UNION
	SELECT id=2,Concepto = ''Activo Circulante '', [SI] = ''$ 2,222,891,419.00'', [CP] = ''$ 11,960.00'', [AP] = ''$ 0.00'', [SF] = ''$ 2,222,903,379.00'', [VP] = ''$ 11,960.00''
	UNION
	SELECT id=3,Concepto = ''Efectivo y Equivalentes'', [SI] = ''$ 149,981,834.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ 149,981,834.00'', [VP] = ''$ 0.00''
	UNION
	SELECT id=4,Concepto = ''Derechos a Recibir Efectivo o Equivalentes'', [SI] = ''$ 2,336,111,208.00'', [CP] = ''$ 11,960.00'', [AP] = ''$ 0.00'', [SF] = ''$ 2,336,123,168.00'', [VP] = ''$ 11,960.00''
	UNION
	SELECT id=5,Concepto = ''Derechos a Recibir Bienes o Servicios'', [SI] = ''$ 0.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ 0.00'', [VP] = ''$ 0.00''
	UNION
	SELECT id=6,Concepto = ''Inventarios'', [SI] = ''$ 0.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ 0.00'', [VP] = ''$ 0.00''
	UNION
	SELECT id=7,Concepto = ''Almacenes'', [SI] = ''$ 650,258.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ 650,258.00'', [VP] = ''$ 0.00''
	UNION
	SELECT id=8,Concepto = ''Estimación por Pérdida o Deterioro de Activos Circulantes'', [SI] = ''$ -263,851,881.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ -263,851,881.00'', [VP] = ''$ 0.00''
	UNION
	SELECT id=9,Concepto = ''Otros Activos Circulantes'', [SI] = ''$ 0.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ 0.00'', [VP] = ''$ 0.00''
	--
	UNION
	SELECT id=10,Concepto = ''ACTIVOS NO CIRCULANTES'', [SI] = '''', [CP] = '''', [AP] = '''', [SF] = '''', [VP] = ''''
	--
	UNION
	SELECT id=11,Concepto = ''Inversiones Financieras a Largo Plazo'', [SI] = ''$ 0.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ 0.00'', [VP] = ''$ 0.00''
	UNION
	SELECT id=12,Concepto = ''Derechos a Recibir Efectivo o Equivalentes a Largo Plazo'', [SI] = ''$ 0.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ 0.00'', [VP] = ''$ 0.00''
	UNION
	SELECT id=13,Concepto = ''Bienes Inmuebles, Infraestructura y Construcciones en Proceso'', [SI] = '''', [CP] = '''', [AP] = '''', [SF] = '''', [VP] = ''''
	UNION
	--
	SELECT id=14,Concepto = ''Bienes Muebles'', [SI] = ''$ 7,162,122.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ 7,162,122.00'', [VP] = ''$ 0.00''
	UNION
	SELECT id=15,Concepto = ''Activos Intangibles'', [SI] = ''$ 2,541,228.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ 2,541,228.00'', [VP] = ''$ 0.00''
	UNION
	SELECT id=16,Concepto = ''Depreciación, Deterioro y Amortización Acumulada de Bienes'', [SI] = ''$ -5,934,956.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ -5,934,956.00'', [VP] = ''$ 0.00''
	UNION
	SELECT id=17,Concepto = ''Activos Diferidos'', [SI] = ''$ 0.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ 0.00'', [VP] = ''$ 0.00''
	UNION
	SELECT id=18,Concepto = ''Estimación por Pérdida o Deterioro de Activos No Circulantes'', [SI] = ''$ 0.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ 0.00'', [VP] = ''$ 0.00''
	UNION
	SELECT id=19,Concepto = ''Otros Activos no Circulantes'', [SI] = ''$ 0.00'', [CP] = ''$ 0.00'', [AP] = ''$ 0.00'', [SF] = ''$ 0.00'', [VP] = ''$ 0.00''
	
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
		, Titulo = CAST(CONCAT(''DEL '' , FORMAT(@FechaInicio, ''dd \de MMMM \del yyyy'', ''es-MX'') , '' AL '' ,  FORMAT(@FechaFin, ''dd \de MMMM \del yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tlbRepAnaActiv

	--FIN
	
END';
-- [CONTA].[SPR_RepAnalisSaldosCuPa] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(23007163))),2) <> '17A6F8BDDB043FDD5441B3A1C6350C06496DB8DD3828D9996C26F7286B3939BA' OR OBJECT_DEFINITION(23007163) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_RepAnalisSaldosCuPa] ''2025-07-31''
ALTER   PROCEDURE [CONTA].[SPR_RepAnalisSaldosCuPa]
	  @p_FecInicio nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''RepAnalisSaldosCuPa''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')

	
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
		, Titulo = CAST(CONCAT(''AL '' , FORMAT(@p_FechaInicio, ''dd \DE MMMM \DEL yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tblRepAnalisSaldosCuPa
	
END';
-- [CONTA].[SPR_RepAntigSaldosCuPa] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(39007220))),2) <> 'E32909788EB0D1B58CFDCC134E8288E2D9499CB56CECEE8A4E19B605DCD3855F' OR OBJECT_DEFINITION(39007220) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_RepAntigSaldosCuPa] ''2025-07-31''
ALTER   PROCEDURE [CONTA].[SPR_RepAntigSaldosCuPa]
	  @p_FecInicio nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''RepAntigSaldosCuPa''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')

	
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
		, Titulo = CAST(CONCAT(''AL '' , FORMAT(@p_FechaInicio, ''dd \DE MMMM \DEL yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tblRepAntigSaldosCuPa
	
END';
-- [CONTA].[SPR_RepClasAdministrativa] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(119007505))),2) <> 'D330912819D6F47C1247E78776F1C53C7A90CE075AC85E403308FF443B85E8B3' OR OBJECT_DEFINITION(119007505) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_RepClasAdministrativa] ''2025-05-01'',''2025-05-30''
ALTER   PROCEDURE [CONTA].[SPR_RepClasAdministrativa]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''RepClasAdministrativa''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')

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
		, Titulo = CAST(CONCAT(''DEL '' , FORMAT(@p_FechaInicio, ''yyyy'', ''es-MX'') , '' AL '' ,  FORMAT(@p_FechaFin, ''yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tblRepClasificacionAdministrativa
	
END';
-- [CONTA].[SPR_RepClasEconomica] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(135007562))),2) <> 'FD1F8C806A316F9CB584A4E306DDDACEF8945432A144A65C3129D8F7928DEA26' OR OBJECT_DEFINITION(135007562) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_RepClasEconomica] ''2025-05-01'',''2025-05-30''
ALTER   PROCEDURE [CONTA].[SPR_RepClasEconomica]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''RepClasEconomica''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')

	SELECT ID = 1, [Concepto] = ''Gasto Corriente'' , [Subejercicio] = 500000.00 , [Aprobado] = 25000000.00 , [AmplReduc] = 1500000.00 , [Modificado] = 26500000.00 , [Devengado] = 26000000.00 , [Pagado] = 25500000.00 
	INTO #tblRepClasificacionEconomica
	UNION 
	SELECT 2, ''Gasto de Capital'', 200000.00, 15000000.00, 1000000.00, 16000000.00, 15800000.00, 15500000.00
	UNION 
	SELECT 3, ''Amortización de la Deuda y Disminución de Pasivos'', 300000.00, 18000000.00, 1200000.00, 19200000.00, 19000000.00, 18700000.00
	UNION 
	SELECT 4, ''Pensiones y Jubilaciones'', 100000.00, 8000000.00, 500000.00, 8500000.00, 8400000.00, 8300000.00
	UNION 
	SELECT 5, ''Participaciones'', 150000.00, 6000000.00, 300000.00, 6300000.00, 6200000.00, 6150000.00

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
		, Titulo = CAST(CONCAT(''DEL '' , FORMAT(@p_FechaInicio, ''yyyy'', ''es-MX'') , '' AL '' ,  FORMAT(@p_FechaFin, ''yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tblRepClasificacionEconomica
	
END';
-- [CONTA].[SPR_RepClasFuncional] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(151007619))),2) <> '32E04CF699F576451C736F82DA77BED496753F708ACF7EB0F5A76DC419064990' OR OBJECT_DEFINITION(151007619) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_RepClasFuncional] ''2025-05-01'',''2025-05-30''
ALTER   PROCEDURE [CONTA].[SPR_RepClasFuncional]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''RepClasFuncional''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')

	SELECT ID = 1, [Concepto] = ''Gobierno'', [Subejercicio] = NULL , [Aprobado] = NULL , [AmplReduc] = NULL , [Modificado] = NULL , [Devengado] = NULL , [Pagado] = NULL 
	INTO #tblRepClasificacionFuncional
	UNION 
	SELECT 2, ''Legislación'', 150000.00, 3000000.00, 200000.00, 3200000.00, 3050000.00, 2950000.00
	UNION 
	SELECT 3, ''Justicia'', 250000.00, 5000000.00, 300000.00, 5300000.00, 5050000.00, 5000000.00
	UNION 
	SELECT 4, ''Coordinación de la Política de Gobierno'', 80000.00, 1200000.00, 100000.00, 1300000.00, 1220000.00, 1180000.00
	UNION 
	SELECT 5, ''Relaciones Exteriores'', 90000.00, 1400000.00, 80000.00, 1480000.00, 1390000.00, 1350000.00
	UNION 
	SELECT 6, ''Asuntos Financieros y Hacendarios'', 300000.00, 6000000.00, 400000.00, 6400000.00, 6100000.00, 6050000.00
	UNION 
	SELECT 7, ''Seguridad Nacional'', 200000.00, 4500000.00, 250000.00, 4750000.00, 4550000.00, 4500000.00
	UNION 
	SELECT 8, ''Asuntos de Orden Público y de Seguridad'', 180000.00, 3500000.00, 220000.00, 3720000.00, 3540000.00, 3500000.00
	UNION 
	SELECT 9, ''Interior'', 100000.00, 2700000.00, 150000.00, 2850000.00, 2750000.00, 2700000.00
	UNION 
	SELECT 10, ''Otros Servicios Generales'', 60000.00, 1800000.00, 100000.00, 1900000.00, 1840000.00, 1800000.00
	UNION 
	SELECT 11, ''Desarrollo Social'', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 12, ''Protección Ambiental'', 120000.00, 2500000.00, 100000.00, 2600000.00, 2480000.00, 2450000.00
	UNION 
	SELECT 13, ''Vivienda y Servicios a la Comunidad'', 90000.00, 3200000.00, 200000.00, 3400000.00, 3310000.00, 3250000.00
	UNION 
	SELECT 14, ''Salud'', 200000.00, 7000000.00, 300000.00, 7300000.00, 7100000.00, 7050000.00
	UNION 
	SELECT 15, ''Recreación, Cultura y Otras Manifestaciones Sociales'', 110000.00, 2800000.00, 120000.00, 2920000.00, 2810000.00, 2770000.00
	UNION 
	SELECT 16, ''Educación'', 400000.00, 9500000.00, 500000.00, 10000000.00, 9600000.00, 9500000.00
	UNION 
	SELECT 17, ''Protección Social'', 170000.00, 3600000.00, 180000.00, 3780000.00, 3610000.00, 3550000.00
	UNION 
	SELECT 18, ''Otros Asuntos Sociales'', 60000.00, 1800000.00, 100000.00, 1900000.00, 1840000.00, 1800000.00
	UNION 
	SELECT 19, ''Desarrollo Económico'', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 20, ''Asuntos Económicos, Comerciales y Laborales en General'', 80000.00, 2600000.00, 150000.00, 2750000.00, 2670000.00, 2620000.00
	UNION 
	SELECT 21, ''Agropecuaria, Silvicultura, Pesca y Caza'', 100000.00, 3400000.00, 200000.00, 3600000.00, 3500000.00, 3450000.00
	UNION 
	SELECT 22, ''Combustibles y Energía'', 150000.00, 3800000.00, 250000.00, 4050000.00, 3900000.00, 3850000.00
	UNION 
	SELECT 23, ''Minería, Manufacturas y Construcción'', 90000.00, 2100000.00, 130000.00, 2230000.00, 2140000.00, 2100000.00
	UNION 
	SELECT 24, ''Transporte'', 200000.00, 4200000.00, 300000.00, 4500000.00, 4300000.00, 4250000.00
	UNION 
	SELECT 25, ''Comunicaciones'', 130000.00, 3000000.00, 180000.00, 3180000.00, 3050000.00, 3000000.00
	UNION 
	SELECT 26, ''Turismo'', 70000.00, 1700000.00, 90000.00, 1790000.00, 1720000.00, 1700000.00
	UNION 
	SELECT 27, ''Ciencia, Tecnología e Innovación'', 120000.00, 2900000.00, 200000.00, 3100000.00, 2980000.00, 2950000.00
	UNION 
	SELECT 28, ''Otras Industrias y Otros Asuntos Económicos'', 60000.00, 1500000.00, 80000.00, 1580000.00, 1520000.00, 1500000.00
	UNION 
	SELECT 29, ''Otras no Clasificadas en Funciones Anteriores'', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 30, ''Transacciones de la Deuda Publica / Costo Financiero de la Deuda'', 100000.00, 5000000.00, 400000.00, 5400000.00, 5300000.00, 5250000.00
	UNION 
	SELECT 31, ''Transferencias, Participaciones y Aportaciones entre diferentes Niveles y Ordenes de Gobierno'', 250000.00, 8000000.00, 500000.00, 8500000.00, 8250000.00, 8200000.00
	UNION 
	SELECT 32, ''Saneamiento del Sistema Financiero'', 50000.00, 1000000.00, 100000.00, 1100000.00, 1050000.00, 1040000.00
	UNION 
	SELECT 33, ''Adeudos de Ejercicios Fiscales Anteriores'', 75000.00, 1200000.00, 150000.00, 1350000.00, 1300000.00, 1290000.00

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
		, Titulo = CAST(CONCAT(''DEL '' , FORMAT(@p_FechaInicio, ''yyyy'', ''es-MX'') , '' AL '' ,  FORMAT(@p_FechaFin, ''yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tblRepClasificacionFuncional
	
END';
-- [CONTA].[SPR_RepClasObjGasto] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(167007676))),2) <> '82AD263E1104C15B1FA7D473B1D539339D21B99A61FF2ADBAD1CF5E3B5BE75EE' OR OBJECT_DEFINITION(167007676) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_RepClasObjGasto] ''2025-05-01'',''2025-05-30''
ALTER   PROCEDURE [CONTA].[SPR_RepClasObjGasto]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''RepClasObjGasto''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')

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
		, Titulo = CAST(CONCAT(''DEL '' , FORMAT(@p_FechaInicio, ''yyyy'', ''es-MX'') , '' AL '' ,  FORMAT(@p_FechaFin, ''yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tblRepClasificacionObjetoGasto
	
END';
-- [CONTA].[SPR_RepDepAcum] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(183007733))),2) <> '76E64A13638C12B0233E69B0F189E7C81E312DF21737C54CDA375F75A6CC732C' OR OBJECT_DEFINITION(183007733) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_RepDepAcum] ''2025-05-01''
ALTER   PROCEDURE [CONTA].[SPR_RepDepAcum]
	  @p_FecInicio nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''RepDepAcum''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')

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
		, Titulo = CAST(CONCAT(''CORRESPONDIENTE AL MES DE: '' , FORMAT(@p_FechaInicio, '' MMMM \DE yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tblDepreciacionAcumulada
	
END';
-- [CONTA].[SPR_RepEndeudamientoNeto] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(215007847))),2) <> 'EE147CA37F55F8AD472098B7FC13E8DB490721630CC7CE1A3110A61EF6194928' OR OBJECT_DEFINITION(215007847) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_RepEndeudamientoNeto]''2025-01-01'',''2025-06-30''
ALTER   PROCEDURE [CONTA].[SPR_RepEndeudamientoNeto]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''#RepEndeudamiento''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')

	SELECT 
    ID = 1, [IDEN] = ''CR-001'', [CONCOL] = 1200000.00, [AM] = 400000.00,[ENDENETO] = 800000.00
	INTO #tbRepEndeudamientoResultado1
	UNION
	SELECT 
    2,''CR-002'', 900000.00, 300000.00, 600000.00
	UNION
	SELECT 
    3,''CR-003'', 1500000.00, 500000.00, 1000000.00;
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
		, Titulo = CAST(CONCAT(''Del '' , FORMAT(@p_FechaInicio, ''dd \de MMMM'', ''es-MX'') , '' al '' ,  FORMAT(@p_FechaFin, ''dd \de MMMM \de yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tbRepEndeudamientoResultado1

	SELECT
	ID = 1, [IDEN] = ''CR-007'', [CONCOL] = 12000.00, [AM] = 2000.00,[ENDENETO] = 4000.00
	INTO #tbRepEndeudamientoResultado2
	UNION
	SELECT 
    2,''CR-008'', 12000.00, 36000.00, 20000.00
	UNION
	SELECT 
    3,''CR-009'', 25000.00, 40000.00, 15000.00;
	--FIN
	-- Segundo resultset retirado: DevExpress/EF deben recibir una sola salida principal.
	
END';
-- [CONTA].[SPR_RepEstatCuentaBancario] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(231007904))),2) <> 'FF07D7B08C9BD8E35DFDFB1340D27F87DC94DF41CB14AFEDA26BCBF6CC77B9CA' OR OBJECT_DEFINITION(231007904) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_RepEstatCuentaBancario] ''2024-01-01'', ''2024-01-30'', 259568
ALTER   PROCEDURE [CONTA].[SPR_RepEstatCuentaBancario]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24),
	  @p_Fk_ICuentaContable INT

,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
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
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''RepEstatCuentaBancario''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')
	--****
	
    -- Drop temp table if it exists
    IF OBJECT_ID(''tempdb..#tmp_saldoInicial'') IS NOT NULL DROP TABLE #tmp_saldoInicial;

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
    IF OBJECT_ID(''tempdb..#tmp_data'') IS NOT NULL DROP TABLE #tmp_data;

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
		, FORMAT(@p_FechaInicio, ''MMMM yyyy'') AS IniPeriodo
		, FORMAT(@p_FechaFin, ''MMMM yyyy'') AS FinPeriodo
		, p.FechaPoliza  AS FechaActual -- FORMAT(GETDATE(), ''dd/MM/yyyy'')
		, cc.ClaveNombre AS Cuenta
		, p.NombrePoliza
		, p.ClavePoliza
		, CASE 
			WHEN FKIdTipoPoliza_SIS = 1 THEN ''Dr''
			WHEN FKIdTipoPoliza_SIS = 2 THEN ''Eg''
			WHEN FKIdTipoPoliza_SIS = 3 THEN ''Ig''
			WHEN FKIdTipoPoliza_SIS = 4 THEN ''Pr''
		  END AS TipoPoliza
		, FORMAT(p.FechaPoliza, ''dd/MM/yyyy'') + '' '' + dp.Descripcion AS ConceptoMovimiento
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
		print ''Saldo inicial: '' + Cast(@v_SaldoInicial AS Varchar(20))
		print ''Cargos: '' + Cast(@v_Cargo AS Varchar(20))
		print ''Abonos: '' + Cast(@v_Abono AS Varchar(20))
		print ''Saldo : '' + Cast(@v_Saldo AS Varchar(20))*/
        
        UPDATE #tmp_data 
		SET Saldos = @v_Saldo , SaldoInicial = @v_SaldoInicial
		WHERE Num = @v_Indice;
		

        FETCH NEXT FROM c INTO  @v_Indice, @v_SaldoInicial, @v_Cargo, @v_Abono;
    END;

    CLOSE c;
    DEALLOCATE c;
	
	SELECT  PKIdPoliza AS ID
			, Cuenta AS [nocuenta]
			, ''530802'' AS[nociente]
			,  ''IFT 980201 GG3'' AS [rfc]
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
		, Titulo = CAST(CONCAT(''PERIODO DEL '' , FORMAT(@p_FechaInicio, ''dd \de MMMM \del yyyy'', ''es-MX'') , '' AL '' ,  FORMAT(@p_FechaFin, ''dd \de MMMM \del yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tblRepEstatCuentaBancario
	
END';
-- [CONTA].[SPR_RepEstatCuentaCuPa] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(247007961))),2) <> '3273AD9008ED8A6096D5C6C87DBA231ED32342A140714C98E15D012A9923C432' OR OBJECT_DEFINITION(247007961) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_RepEstatCuentaCuPa]  ''2024-01-01'', ''2024-01-30'', 259568
ALTER   PROCEDURE [CONTA].[SPR_RepEstatCuentaCuPa]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24),
	  @p_Fk_ICuentaContable INT
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
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
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''RepEstatCuentaCuPa''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')

		--****
	
    -- Drop temp table if it exists
    IF OBJECT_ID(''tempdb..#tmp_saldoInicial'') IS NOT NULL DROP TABLE #tmp_saldoInicial;

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
    IF OBJECT_ID(''tempdb..#tmp_data'') IS NOT NULL DROP TABLE #tmp_data;

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
		, FORMAT(@p_FechaInicio, ''MMMM yyyy'') AS IniPeriodo
		, FORMAT(@p_FechaFin, ''MMMM yyyy'') AS FinPeriodo
		, p.FechaPoliza  AS FechaActual -- FORMAT(GETDATE(), ''dd/MM/yyyy'')
		, cc.ClaveNombre AS Cuenta
		, p.NombrePoliza
		, p.ClavePoliza
		, CASE 
			WHEN FKIdTipoPoliza_SIS = 1 THEN ''Dr''
			WHEN FKIdTipoPoliza_SIS = 2 THEN ''Eg''
			WHEN FKIdTipoPoliza_SIS = 3 THEN ''Ig''
			WHEN FKIdTipoPoliza_SIS = 4 THEN ''Pr''
		  END AS TipoPoliza
		, FORMAT(p.FechaPoliza, ''dd/MM/yyyy'') + '' '' + dp.Descripcion AS ConceptoMovimiento
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
		print ''Saldo inicial: '' + Cast(@v_SaldoInicial AS Varchar(20))
		print ''Cargos: '' + Cast(@v_Cargo AS Varchar(20))
		print ''Abonos: '' + Cast(@v_Abono AS Varchar(20))
		print ''Saldo : '' + Cast(@v_Saldo AS Varchar(20))*/
        
        UPDATE #tmp_data 
		SET Saldos = @v_Saldo , SaldoInicial = @v_SaldoInicial
		WHERE Num = @v_Indice;
		

        FETCH NEXT FROM c INTO  @v_Indice, @v_SaldoInicial, @v_Cargo, @v_Abono;
    END;

    CLOSE c;
    DEALLOCATE c;
	
	SELECT  PKIdPoliza AS ID
			, Cuenta AS [nocuenta]
			, ''530802'' AS[nociente]
			,  ''IFT 980201 GG3'' AS [rfc]
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
		, Titulo = CAST(CONCAT(''PERIODO DEL '' , FORMAT(@p_FechaInicio, ''dd \de MMMM \del yyyy'', ''es-MX'') , '' AL '' ,  FORMAT(@p_FechaFin, ''dd \de MMMM \del yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tblRepEstatCuentaCuPa
	
END';
-- [CONTA].[SPR_RepIndicadoresPF] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(263008018))),2) <> '94A8656D8C34BF4212771252CA9D81E93FA210EDFCC5C4B1AE30512D522B7B03' OR OBJECT_DEFINITION(263008018) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_RepIndicadoresPF] ''2025-10-01'',''2025-10-01''
ALTER   PROCEDURE [CONTA].[SPR_RepIndicadoresPF]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''RepIndicadoresPF''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')

	SELECT 
    ID = 1, [Concepto] = ''I. Ingresos Presupuestarios'', [EstApro] = 0.00, [Deve] = 0.00, [RecPag] = 0.00
	INTO #tbRepIndicadoresPF
	UNION
	SELECT 
    2,''1. Ingresos del Gobierno de la Entidad Federativa'', 0.00, 0.00, 0.00
	UNION
	SELECT 
    3,''2. Ingresos del Sector Paraestatal'', 0.00, 0.00, 0.00
	UNION
	SELECT 
    4,''II. Egresos Presupuestarios'', 0.00, 0.00, 0.00
	UNION
	SELECT 
    5,''3. Egresos del Gobierno de la Entidad Federativa'', 0.00, 0.00, 0.00
	UNION
	SELECT 
    6,''4. Egresos del Sector Paraestatal'', 0.00, 0.00, 0.00
	UNION
	SELECT 
    7,''III. Balance Presupuestario (Superávit o Déficit)'', 0.00, 0.00, 0.00
	UNION
	SELECT 
    8,''III. Balance presupuestario (Superávit o Déficit)'', 0.00, 0.00, 0.00
	UNION
	SELECT 
    9,''IV. Intereses, Comisiones y Gastos de la Deuda'', 0.00, 0.00, 0.00
	UNION
	SELECT 
    10,''V. Balance Primario (Superávit o Déficit)'', 0.00, 0.00, 0.00
	UNION
	SELECT 
    11,''A. Financiamiento'', 0.00, 0.00, 0.00
	UNION
	SELECT 
    12,''B. Amortización de la deuda'', 0.00, 0.00, 0.00
	UNION
	SELECT 
    13,''C. Financiamiento Neto'', 0.00, 0.00, 0.00
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
		, Titulo = CAST(CONCAT(''DEL '' , UPPER(FORMAT(@p_FechaInicio, ''dd \DE MMMM \DEL yyyy'', ''es-MX'')) , '' AL '' ,  UPPER(FORMAT(@p_FechaFin, ''dd \DE MMMM \DEL yyyy'', ''es-MX''))) AS NVARCHAR(128))
	FROM #tbRepIndicadoresPF
	
END';
-- [CONTA].[SPR_RepInformesProg] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(279008075))),2) <> '16EF8755D22AF9248911D7A3EEC44D34F3FF5DA1D298AD0041FD5CBAC4716DAE' OR OBJECT_DEFINITION(279008075) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_RepInformesProg]''2025-01-01'',''2025-06-30''
ALTER   PROCEDURE [CONTA].[SPR_RepInformesProg]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''#RepInformesProg''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')

	SELECT 
    ID = 1, [CONCEPTO] = ''Subsidios: Sector Social y Privado o Entidades'',[AP] = 200000.00,
    [AMPREC] = 80000.00, [MOD] = 120000.00, [DEV] = 20000.00, [PAG] = 20000.00, [SUBEJE] = 20000.00
	INTO #tbRepInformesProg
	UNION
	SELECT 
    2,''Federativas y Municipios'',500000.00,250000.00,250000.00,80000.00,90000.00,40000.00
	UNION
	SELECT 
    3,''Sujetos a Reglas de Operación'',120000.00,60000.00,60000.00,15000.00,20000.00,15000.00

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
		, Titulo = CAST(CONCAT(''Del '' , FORMAT(@p_FechaInicio, ''dd \de MMMM'', ''es-MX'') , '' al '' ,  FORMAT(@p_FechaFin, ''dd \de MMMM \de yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tbRepInformesProg
	
END';
-- [CONTA].[SPR_RepIngEgre] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(295008132))),2) <> 'B09FB8C16466D1BDE882E816E77E1F76A09A946105791271CCF27C9A31F4FA31' OR OBJECT_DEFINITION(295008132) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_RepIngEgre] ''2025-05-01'',''2025-05-30''
ALTER   PROCEDURE [CONTA].[SPR_RepIngEgre]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''RepIngEgre''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')

	SELECT ID = 1, [CONCEPTO] = ''1. Total de Ingresos Presupuestarios'', [Monto] = 25000000.00
	INTO #tblFormatoConciliacionEgresos
	UNION 
	SELECT 2, ''2. Más Ingresos Contables No Presupuestarios'', 3580000.00
	UNION 
	SELECT 3, ''2.1 Ingresos Financieros'', 1200000.00
	UNION 
	SELECT 4, ''2.2 Incremento por Variación de Inventarios'', 350000.00
	UNION 
	SELECT 5, ''2.3 Disminución del Exceso de Estimaciones por Pérdida o Deterioro u Obsolescencia'', 420000.00
	UNION 
	SELECT 6, ''2.4 Disminución del Exceso de Provisiones'', 300000.00
	UNION 
	SELECT 7, ''2.5 Otros Ingresos y Beneficios Varios'', 800000.00
	UNION 
	SELECT 8, ''2.6 Otros Ingresos Contables No Presupuestarios'', 510000.00
	UNION 
	SELECT 9, ''3. Menos Ingresos Presupuestarios No Contables'', 5150000.00
	UNION 
	SELECT 10, ''3.1 Aprovechamientos Patrimoniales'', 1800000.00
	UNION 
	SELECT 11, ''3.2 Ingresos Derivados de Financiamientos'', 2500000.00
	UNION 
	SELECT 12, ''3.3 Otros Ingresos Presupuestarios No Contables'', 850000.00
	UNION 
	SELECT 13, ''4. Total de Ingresos Contables'', 23430000.00


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
		, Titulo = CAST(CONCAT(''DEL '' , FORMAT(@p_FechaInicio, ''yyyy'', ''es-MX'') , '' AL '' ,  FORMAT(@p_FechaFin, ''yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tblFormatoConciliacionEgresos
	
END';
-- [CONTA].[SPR_RepIngreAna] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(311008189))),2) <> '63E5AA2D3D5D3850F3DD56A5AD48FEEDE4B1EDAEFC0B6431F70738D383A1674B' OR OBJECT_DEFINITION(311008189) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_RepIngreAna] ''2025-05-01'',''2025-05-30''
ALTER   PROCEDURE [CONTA].[SPR_RepIngreAna]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''RepIngreAna''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')

	SELECT ID = 1, [RUBRO] = ''IMPUESTOS'' , [ESTIMADO] = 12000000.00 , [AMPRED] = 500000.00 , [MODIFICADO] = 12500000.00 , [DEVENGADO] = 12200000.00 , [RECAUDADO] = 12150000.00 , [DIFERENCIA] = -350000.00  
	INTO #tblEstadoAnaliticoIngresos
	UNION 
	SELECT 2, ''CUOTAS Y APORTACIONES DE SEGURIDAD SOCIAL'', 8000000.00, 200000.00, 8200000.00, 8150000.00, 8120000.00, -800000.00
	UNION 
	SELECT 3, ''CONTRIBUCIONES DE MEJORAS'', 300000.00, 0.00, 300000.00, 280000.00, 275000.00, -25000.00
	UNION 
	SELECT 4, ''DERECHOS'', 2500000.00, 100000.00, 2600000.00, 2580000.00, 2550000.00, -50000.00
	UNION 
	SELECT 5, ''PRODUCTOS'', 1800000.00, 30000.00, 1830000.00, 1820000.00, 1805000.00, -25000.00
	UNION 
	SELECT 6, ''APROVECHAMIENTOS'', 1500000.00, -50000.00, 1450000.00, 1400000.00, 1380000.00, -70000.00
	UNION 
	SELECT 7, ''INGRESOS POR VENTAS DE BIENES, PRESTACIÓN DE SERVICIOS Y OTROS INGRESOS'', 2200000.00, 80000.00, 2280000.00, 2260000.00, 2240000.00, -40000.00
	UNION 
	SELECT 8, ''PARTICIPACIONES,APORTACIONES, CONVENIOS, INCENTIVOS DERIVADOS DE LA COLABORACIÓN FISCAL Y FONDOS DISTINTOS DE APORTACIONES'', 10000000.00, 500000.00, 10500000.00, 10400000.00, 10350000.00, -150000.00
	UNION 
	SELECT 9, ''TRANSFERENCIAS, ASIGNACIONES, SUBSIDIOS Y SUBVENCIONES, Y PENSIONES Y JUBILACIONES'', 9000000.00, 300000.00, 9300000.00, 9250000.00, 9200000.00, -100000.00
	UNION 
	SELECT 10, ''INGRESOS DERIVADOS DE FINANCIAMIENTOS'', 7000000.00, 0.00, 7000000.00, 6900000.00, 6800000.00, -200000.00
	UNION 
	SELECT 11, ''INGRESOS DEL PODER EJECUTIVO FEDERAL O ESTATAL Y DE LOS MUNICIPIOS'', 4000000.00, 100000.00, 4100000.00, 4050000.00, 4000000.00, -100000.00
	UNION 
	SELECT 12, ''IMPUESTOS'', 13000000.00, 300000.00, 13300000.00, 13050000.00, 13000000.00, -300000.00
	UNION 
	SELECT 13, ''CUOTAS Y APORTACIONES DE SEGURIDAD SOCIAL'', 8500000.00, 250000.00, 8750000.00, 8700000.00, 8680000.00, -70000.00
	UNION 
	SELECT 14, ''CONTRIBUCIONES DE MEJORAS'', 350000.00, 0.00, 350000.00, 340000.00, 338000.00, -12000.00
	UNION 
	SELECT 15, ''DERECHOS'', 2700000.00, 50000.00, 2750000.00, 2700000.00, 2680000.00, -70000.00
	UNION 
	SELECT 16, ''PRODUCTOS'', 1900000.00, 40000.00, 1940000.00, 1920000.00, 1910000.00, -30000.00
	UNION 
	SELECT 17, ''APROVECHAMIENTOS'', 1600000.00, -100000.00, 1500000.00, 1450000.00, 1440000.00, -60000.00
	UNION 
	SELECT 18, ''PARTICIPACIONES,APORTACIONES, CONVENIOS, INCENTIVOS DERIVADOS DE LA COLABORACIÓN FISCAL Y FONDOS DISTINTOS DE APORTACIONES'', 11000000.00, 600000.00, 11600000.00, 11500000.00, 11400000.00, -200000.00
	UNION 
	SELECT 19, ''TRANSFERENCIAS, ASIGNACIONES, SUBSIDIOS Y SUBVENCIONES, Y PENSIONES Y JUBILACIONES'', 9500000.00, 350000.00, 9850000.00, 9800000.00, 9700000.00, -150000.00
	UNION 
	SELECT 20, ''INGRESOS DE LOS ENTES PÚBLICOS DE LOS PODERES LEGISLATIVO Y JUDICIAL, DE LOS ÓRGANOS AUTÓNOMOS Y DEL SECTOR PARAESTATAL O PARAMUNICIPAL, ASÍ COMO DE LAS EMPRESAS PRODUCTIVAS DEL ESTADO'', 3000000.00, 100000.00, 3100000.00, 3050000.00, 3000000.00, -100000.00
	UNION 
	SELECT 21, ''CUOTAS Y APORTACIONES DE SEGURIDAD SOCIAL'', 9000000.00, 200000.00, 9200000.00, 9150000.00, 9100000.00, -100000.00
	UNION 
	SELECT 22, ''PRODUCTOS'', 2000000.00, 60000.00, 2060000.00, 2040000.00, 2020000.00, -40000.00
	UNION 
	SELECT 23, ''INGRESOS POR VENTAS DE BIENES, PRESTACIÓN DE SERVICIOS Y OTROS INGRESOS'', 2300000.00, 100000.00, 2400000.00, 2380000.00, 2360000.00, -40000.00
	UNION 
	SELECT 24, ''TRANSFERENCIAS, ASIGNACIONES, SUBSIDIOS Y SUBVENCIONES, Y PENSIONES Y JUBILACIONES'', 9700000.00, 380000.00, 10080000.00, 10020000.00, 9950000.00, -150000.00
	UNION 
	SELECT 25, ''INGRESOS DERIVADOS DE FINANCIAMIENTO'', 7200000.00, 150000.00, 7350000.00, 7300000.00, 7250000.00, -100000.00

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
		, Titulo = CAST(CONCAT(''DEL '' , FORMAT(@p_FechaInicio, ''dd \de MMMM \del yyyy'', ''es-MX'') , '' AL '' ,  FORMAT(@p_FechaFin, ''dd \de MMMM \del yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tblEstadoAnaliticoIngresos
	
END';
-- [CONTA].[SPR_RepInteresesDeuda] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(327008246))),2) <> '4829177EA72DB357277DF8C870EBF9EEDE7D498D6B4192E83951D6E34DE78320' OR OBJECT_DEFINITION(327008246) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_RepInteresesDeuda]''2025-01-01'',''2025-06-30''
ALTER   PROCEDURE [CONTA].[SPR_RepInteresesDeuda]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''#RepInteresesDeuda''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')

	SELECT 
    ID = 1, [IDEN] = ''CR-001'', [DEV] = 1200000.00, [PAG] = 400000.00
	INTO #tbRepInteresesDeudaResultado1
	UNION
	SELECT 
    2,''CR-002'', 900000.00, 300000.00
	UNION
	SELECT 
    3,''CR-003'', 1500000.00, 500000.00
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
		, Titulo = CAST(CONCAT(''Del '' , FORMAT(@p_FechaInicio, ''dd \de MMMM'', ''es-MX'') , '' al '' ,  FORMAT(@p_FechaFin, ''dd \de MMMM \de yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tbRepInteresesDeudaResultado1

	SELECT
	ID = 1, [IDEN] = ''CR-007'', [DEV] = 12000.00, [PAG] = 2000.00
	INTO #tbRepInteresesDeudaResultado2
	UNION
	SELECT 
    2,''CR-008'', 12000.00, 36000.00
	UNION
	SELECT 
    3,''CR-009'', 25000.00, 40000.00
	--FIN
	-- Segundo resultset retirado: DevExpress/EF deben recibir una sola salida principal.
	
END';
-- [CONTA].[SPR_RepInteSaldosCuPa] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(343008303))),2) <> '731901763306F2B8CBC7E94D7C763826209C2F149D371FC6AFEF33A2E20C5628' OR OBJECT_DEFINITION(343008303) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_RepInteSaldosCuPa] ''2025-07-31''
ALTER   PROCEDURE [CONTA].[SPR_RepInteSaldosCuPa]
	  @p_FecInicio nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio,
	
	 @DiasVencidos int = 20 -- DEFINIR CON EL USUARIO el parametro a partir de cuantos dias se  generan intereses 


	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''RepInteSaldosCuPa''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')

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
		, Titulo = CAST(CONCAT(''AL '' , FORMAT(@p_FechaInicio, ''dd \DE MMMM \DEL yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tblRepInteSaldosCuPa
	
END';
-- [CONTA].[SPR_RepKardexGralporPeriod] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(359008360))),2) <> 'DEF846E0AF5091397C33F8605AA23C3603336913B4E661A7636C85359B49B519' OR OBJECT_DEFINITION(359008360) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_RepKardexGralporPeriod]''2025-07-01'',''2025-07-31''
ALTER   PROCEDURE [CONTA].[SPR_RepKardexGralporPeriod]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''RepKardexGralporPeriod''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')

	SELECT ID = 1, [PP] = ''2161'', [cabmsdf] = ''2111000032'' , [clave] = ''2161E001'', [concepto] = ''Escoba de plástico con bastón de madera'' , [exist] = 1939.52,
	[entrada] = 0.00, [salida] = 484.88, [saldos] = 1454.64, [saldounidad] = 30, [costoprom] = 48.49, [um] = ''PIEZA''
	INTO #tblRepKardexGralporPeriod
	UNION
	SELECT ID = 2, ''2161'', ''2111000104'', ''2161E002'', ''Escobeta de plástico (largo 9 cm, altura 5 cm)'', 550.30, 0.00, 0.00, 550.30, 40, 13.76, ''PIEZA''
	UNION
	SELECT ID = 3, ''2161'', ''2111000104'', ''2161E003'', ''Escobillón para W.C. con base'', 1248.92, 0.00, 0.00,  1248.92, 29, 43.07, ''PIEZA''
	UNION
	SELECT ID = 4, ''2161'', ''2111000104'', ''2161E004'', ''Fibra acerina/metálica'', 771.40, 0.00, 0.00, 771.40, 50, 15.43, ''PIEZA''
	UNION
	SELECT ID = 5, ''2161'', ''2111000104'', ''2161E005'', ''Fibra negra'', 1205.82, 0.00, 0.00, 1205.82, 30, 40.19, ''PIEZA''

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
		, Titulo = CAST(CONCAT(''PERIODO DEL '' , FORMAT(@p_FechaInicio, ''dd \de MMMM \del yyyy'', ''es-MX'') , '' AL '' ,  FORMAT(@p_FechaFin, ''dd \de MMMM \del yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tblRepKardexGralporPeriod
	
END';
-- [CONTA].[SPR_RepKardexporArticulo] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(375008417))),2) <> '91B2AE3D46592F1024652BCF071C3B1CE0BBC3803A8886F0F459F1F2EF3AED72' OR OBJECT_DEFINITION(375008417) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_RepKardexporArticulo] ''2025-07-01'',''2025-07-31''
ALTER   PROCEDURE [CONTA].[SPR_RepKardexporArticulo]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''RepKardexporArticulo''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')

	SELECT ID = 1, [articulo] = ''DEDAL DE HULE No. 112'', [unidad] = ''PIEZA'', [almacen] = ''IZTAPALAPA'' , [clave] = ''2111D001'' , [fecha] = ''16/05/2022'' , [ref] = ''ROAD-13'' , [entrada] = ''150'' ,
	[salida] = ''0'' , [exist] = ''150'', [preunit] = 7.00, [promedio] = 7.00, [debe] = 1050.00 , [haber] = 0.00, [saldo] = 1050.00
	INTO #tblRepKardexporArticulo
	UNION
	SELECT 2, ''DEDAL DE HULE No. 112'', ''PIEZA'', ''IZTAPALAPA'', ''2111D001'', ''19/06/2022'', ''JUDOP-97'', ''0'', ''6'', ''144'', 0.00, 7.00, 0.00, 42.00, 1008.00
	UNION
	SELECT 3, ''DEDAL DE HULE No. 112'', ''PIEZA'', ''IZTAPALAPA'', ''2111D001'', ''21/06/2022'', ''DCMV-98'', ''0'', ''10'', ''134'', 0.00, 7.00, 0.00, 70.00, 938.00
	UNION
	SELECT 4, ''DEDAL DE HULE No. 112'', ''PIEZA'', ''IZTAPALAPA'', ''2111D001'', ''25/06/2022'', ''SAyO'', ''0'', ''4'', ''130'', 0.00, 7.00, 0.00, 28.00, 910.00
	UNION
	SELECT 5, ''DEDAL DE HULE No. 112'', ''PIEZA'', ''IZTAPALAPA'', ''2111D001'', ''27/06/2022'', ''DG-128'', ''0'', ''5'', ''125'', 0.00, 7.00, 0.00, 35.00, 875.00

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
		, Titulo = CAST(CONCAT(''PERIODO DEL '' , FORMAT(@p_FechaInicio, ''dd \de MMMM \del yyyy'', ''es-MX'') , '' AL '' ,  FORMAT(@p_FechaFin, ''dd \de MMMM \del yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tblRepKardexporArticulo
	
END';
-- [CONTA].[SPR_ReporteEdoFlujoEfec] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(391008474))),2) <> '6CC4BDF14626A2C24E4D151A000F7A9046E6451795DE3F3E7D4C9CDC42F2D263' OR OBJECT_DEFINITION(391008474) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [Conta].[SPR_ReporteEdoFlujoEfec] ''2025-05-01'',''2025-05-30''
ALTER   PROCEDURE [Conta].[SPR_ReporteEdoFlujoEfec]
	 @p_FecInicio nvarchar(24),
	@p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	

	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''ReporteEdoFlujoEfec''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')


	SELECT id=1,Concepto = CAST(''Flujo de Efectivo de las Actividades de Operación'' as nvarchar(500)), [Anio1] = '''', [Anio2] = ''''
	into #tlbReporteEdoFlujoEfec
	UNION
	SELECT id=2,Concepto = ''Origen'' , [2023] = ''19,715,058.00'', [2024] = ''19,715,058.00''
	UNION
	SELECT id=3,Concepto = ''Impuestos'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=4,Concepto = ''Cuotas y Aportaciones de Seguridad Social'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=5,Concepto = ''Contribuciones de Mejoras'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=6,Concepto = ''Derechos'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=7,Concepto = ''Productos'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=8,Concepto = ''Aprovechamiento'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=9,Concepto = ''Ingresos por Ventas de Bienes y Prestación de Servicios'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=10,Concepto = ''Participaciones, Aportaciones, Convenios, Incentivos Derivados de la Colaboración Fiscal y Fondos Distintos de Aportaciones'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=11,Concepto = ''Transferencias, Asignaciones, Subsidios Subvenciones y Pensiones y Jubilaciones'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=12,Concepto = ''Otros Orígenes de Operación'' , [2023] = ''19,715,058.00'', [2024] = ''19,718,759.00''
	UNION
	SELECT id=13,Concepto = ''Aplicación'' , [2023] = ''37,339,840.00'', [2024] = ''38,134,248.00''
	UNION
	SELECT id=14,Concepto = ''Servicios Personales'' , [2023] = ''19,033,387.00'', [2024] = ''19,827,795.00''
	UNION
	SELECT id=15,Concepto = ''Materiales y Suministros'' , [2023] = ''1,128,044.00'', [2024] = ''1,128,044.00''
	UNION
	SELECT id=16,Concepto = ''Servicios Generales'' , [2023] = ''17,178,409.00'', [2024] = ''17,178,409.00''
	UNION
	SELECT id=17,Concepto = ''Transferencias Internas y Asignaciones al Sector Público'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=18,Concepto = ''Subsidios y Subvenciones'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=19,Concepto = ''Ayudas Sociales'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=20,Concepto = ''Pensiones y Jubilaciones'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=21,Concepto = ''Transferencias a Fideicomisos, Mandatos y Contratos Análogos'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=22,Concepto = ''Transferencias a la Seguridad Social'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=23,Concepto = ''Donativos'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=24,Concepto = ''Transferencias al Exterior'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=25,Concepto = ''Participaciones'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=26,Concepto = ''Aportaciones'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=27,Concepto = ''Convenios'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=28,Concepto = ''Otras Aplicaciones de Operación'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=29,Concepto = ''Flujos Netos de Efectivo por Actividades de Operación'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=30,Concepto = ''Flujos de Efectivo de las Actividades de Inversión'' , [2023] = '''', [2024] = ''''
	UNION
	SELECT id=31,Concepto = ''Origen'' , [2023] = ''-37,339,840.00'', [2024] = ''-38,134,248.00''
	UNION
	SELECT id=32,Concepto = ''Bienes Inmuebles, Infraestructura y Construcciones en Proceso'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=33,Concepto = ''Bienes Muebles'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=34,Concepto = ''Otros Orígenes de Inversión'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=35,Concepto = ''Aplicación'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=36,Concepto = ''Bienes Inmuebles, Infraestructura y Construcciones en Proceso '' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=37,Concepto = ''Bienes Muebles'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=38,Concepto = ''Otras Aplicaciones de Inversión'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=39,Concepto = ''Flujos Netos de Efectivo por Actividades de Inversión'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=40,Concepto = ''Flujos de Efectivo de las Actividades de Financiamiento'' , [2023] = '''', [2024] = ''''
	UNION
	SELECT id=41,Concepto = ''Origen'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=42,Concepto = ''Endeudamiento Neto'' , [2023] = '''', [2024] = ''''
	UNION
	SELECT id=43,Concepto = ''Interno'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=44,Concepto = ''Externo'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=45,Concepto = ''Otros Orígenes de Financiamiento'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=46,Concepto = ''Aplicación'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=47,Concepto = ''Servicios de la Deuda'' , [2023] = '''', [2024] = ''''
	UNION
	SELECT id=48,Concepto = ''Interno'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=49,Concepto = ''Externo'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=50,Concepto = ''Otras Aplicaciones de Financiamiento'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=51,Concepto = ''Flujos Neto de Efectivo por Actividades de Financiamiento'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=52,Concepto = ''Incremento / Disminución Neta en el Efectivo y Equivalentes al Efectivo'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=53,Concepto = ''Efectivo y Equivalentes al Efectivo al Inicio del Ejercicio'' , [2023] = ''0.00'', [2024] = ''0.00''
	UNION
	SELECT id=54,Concepto = ''Efectivo y Equivalentes al Efectivo al Final del Ejercicio'' , [2023] = ''0.00'', [2024] = ''0.00''
	

	SELECT *,@Funcion1 Funcion1
		,@Funcion2 Funcion2
		,@Funcion3 Funcion3
		,@Nombre1 Nombre1
		,@Nombre2 Nombre2
		,@Nombre3 Nombre3
		,@Puesto1 Puesto1
		,@Puesto2 Puesto2
		,@Puesto3 Puesto3
		, Titulo = CAST(CONCAT(''DEL '' , FORMAT(@p_FechaInicio, ''dd \de MMMM \del yyyy'', ''es-MX'') , '' AL '' ,  FORMAT(@p_FechaFin, ''dd \de MMMM \del yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tlbReporteEdoFlujoEfec
	--FIN
	
END';
-- [CONTA].[SPR_RepPasivosContingentes] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(407008531))),2) <> 'BDBC886D2577D5BCCC4CEA2AC64D03B8321BE209FDC7BC59EBC174D9CF0C1087' OR OBJECT_DEFINITION(407008531) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_RepPasivosContingentes] ''2025-05-01'',''2025-05-30''
ALTER   PROCEDURE [CONTA].[SPR_RepPasivosContingentes]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''RepPasivosContingentes''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')

	SELECT Rubro = ''Servicios Personales'', Monto = ''$ 1,250,000.00''
	INTO #tblPasivoContingente
	UNION
	SELECT ''Materiales y Suministros'', ''$ 320,000.00''
	UNION
	SELECT ''Servicios Generales'', ''$ 410,500.00''
	UNION
	SELECT ''Transferencias y Subsidios'', ''$ 980,000.00''
	UNION
	SELECT ''Bienes Muebles e Intangibles'', ''$ 210,000.00''
	UNION
	SELECT ''Inversión Pública'', ''$ 1,500,000.00''
	UNION
	SELECT ''Deuda Pública'', ''$ 670,000.00''
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
		, Titulo = CAST(CONCAT(''DEL '' , FORMAT(@p_FechaInicio, ''dd \de MMMM \del yyyy'', ''es-MX'') , '' AL '' ,  FORMAT(@p_FechaFin, ''dd \de MMMM \del yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tblPasivoContingente
	
END';
-- [CONTA].[SPR_RepProyEgresos] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(423008588))),2) <> '6E4114D0631CD82442E84D699390A319AA7DF56FE82D2AB9C2C26F5DC11BC23A' OR OBJECT_DEFINITION(423008588) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_RepProyEgresos] ''2025-05-01'',''2025-05-30''
ALTER   PROCEDURE [CONTA].[SPR_RepProyEgresos]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''RepProyEgresos''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')

	SELECT id = 1, Concepto = ''1. Gasto No Etiquetado'', [AnioC] = NULL, [Anio1] = NULL, [Anio2] = NULL, [Anio3] = NULL, [Anio5] = NULL
	INTO #tblProyeccionDeEgresos
	UNION
	SELECT 2, ''A. Servicios Personales'', ''$ 500,000.00'', ''$ 510,000.00'', ''$ 520,000.00'', ''$ 530,000.00'', ''$ 550,000.00''
	UNION
	SELECT 3, ''B. Materiales y Suministros'', ''$ 120,000.00'', ''$ 125,000.00'', ''$ 130,000.00'', ''$ 135,000.00'', ''$ 140,000.00''
	UNION
	SELECT 4, ''C. Servicios Generales'', ''$ 150,000.00'', ''$ 155,000.00'', ''$ 160,000.00'', ''$ 165,000.00'', ''$ 170,000.00''
	UNION
	SELECT 5, ''D. Transferencias, Asignaciones, Subsidios y Otras Ayudas'', ''$ 300,000.00'', ''$ 310,000.00'', ''$ 320,000.00'', ''$ 330,000.00'', ''$ 350,000.00''
	UNION
	SELECT 6, ''E. Bienes Muebles, Inmuebles e Intangibles'', ''$ 100,000.00'', ''$ 105,000.00'', ''$ 110,000.00'', ''$ 115,000.00'', ''$ 120,000.00''
	UNION
	SELECT 7, ''F. Inversión Pública'', ''$ 400,000.00'', ''$ 410,000.00'', ''$ 420,000.00'', ''$ 430,000.00'', ''$ 450,000.00''
	UNION
	SELECT 8, ''G. Inversiones Financieras y Otras Provisiones'', ''$ 80,000.00'', ''$ 82,000.00'', ''$ 84,000.00'', ''$ 86,000.00'', ''$ 90,000.00''
	UNION
	SELECT 9, ''H. Participaciones y Aportaciones'', ''$ 200,000.00'', ''$ 205,000.00'', ''$ 210,000.00'', ''$ 215,000.00'', ''$ 220,000.00''
	UNION
	SELECT 10, ''I. Deuda Pública'', ''$ 50,000.00'', ''$ 52,000.00'', ''$ 54,000.00'', ''$ 56,000.00'', ''$ 60,000.00''
	UNION
	SELECT 11, ''2. Gasto Etiquetado'', NULL, NULL, NULL, NULL, NULL
	UNION
	SELECT 12, ''A. Servicios Personales'', ''$ 600,000.00'', ''$ 610,000.00'', ''$ 620,000.00'', ''$ 630,000.00'', ''$ 650,000.00''
	UNION
	SELECT 13, ''B. Materiales y Suministros'', ''$ 130,000.00'', ''$ 135,000.00'', ''$ 140,000.00'', ''$ 145,000.00'', ''$ 150,000.00''
	UNION
	SELECT 14, ''C. Servicios Generales'', ''$ 160,000.00'', ''$ 165,000.00'', ''$ 170,000.00'', ''$ 175,000.00'', ''$ 180,000.00''
	UNION
	SELECT 15, ''D. Transferencias, Asignaciones, Subsidios y Otras Ayudas'', ''$ 310,000.00'', ''$ 320,000.00'', ''$ 330,000.00'', ''$ 340,000.00'', ''$ 360,000.00''
	UNION
	SELECT 16, ''E. Bienes Muebles, Inmuebles e Intangibles'', ''$ 110,000.00'', ''$ 115,000.00'', ''$ 120,000.00'', ''$ 125,000.00'', ''$ 130,000.00''
	UNION
	SELECT 17, ''F. Inversión Pública'', ''$ 420,000.00'', ''$ 430,000.00'', ''$ 440,000.00'', ''$ 450,000.00'', ''$ 470,000.00''
	UNION
	SELECT 18, ''G. Inversiones Financieras y Otras Provisiones'', ''$ 85,000.00'', ''$ 87,000.00'', ''$ 89,000.00'', ''$ 91,000.00'', ''$ 95,000.00''
	UNION
	SELECT 19, ''H. Participaciones y Aportaciones'', ''$ 210,000.00'', ''$ 215,000.00'', ''$ 220,000.00'', ''$ 225,000.00'', ''$ 230,000.00''
	UNION
	SELECT 20, ''I. Deuda Pública'', ''$ 55,000.00'', ''$ 57,000.00'', ''$ 59,000.00'', ''$ 61,000.00'', ''$ 65,000.00''
	UNION
	SELECT 21, ''3. Total de Egresos Proyectados'', ''$ 3,580,000.00'', ''$ 3,680,000.00'', ''$ 3,780,000.00'', ''$ 3,880,000.00'', ''$ 4,080,000.00''
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
		, Titulo = CAST(CONCAT(''DEL '' , FORMAT(@p_FechaInicio, ''dd \de MMMM \del yyyy'', ''es-MX'') , '' AL '' ,  FORMAT(@p_FechaFin, ''dd \de MMMM \del yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tblProyeccionDeEgresos
	
END';
-- [CONTA].[SPR_RepProyIngresos] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(439008645))),2) <> '167261C8209CE3713477C7D1BC0CEBE52DA4380735CC26AD5CF2396FF3873D2C' OR OBJECT_DEFINITION(439008645) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_RepProyIngresos] ''2025-05-01''
ALTER   PROCEDURE [CONTA].[SPR_RepProyIngresos]
	  @p_FecInicio nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''RepProyIngresos''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')

	SELECT [ID] = 1, [CONCEPTO] = ''1. Ingresos de Libre Disposición'', [2025] = 85000000.00 , [2026] = 87000000.00 , [2027] = 89000000.00 , [2028] = 91000000.00 , [2029] = 93000000.00 , [2030] = 95000000.00  
	INTO #tblRepProyIngre
	UNION 
	SELECT 2, ''A. Impuestos'', 30000000.00, 31000000.00, 32000000.00, 33000000.00, 34000000.00, 35000000.00
	UNION 
	SELECT 3, ''B. Cuotas y Aportaciones de Seguridad Social'', 5000000.00, 5200000.00, 5300000.00, 5400000.00, 5500000.00, 5600000.00
	UNION 
	SELECT 4, ''C. Contribuciones de Mejoras'', 800000.00, 850000.00, 870000.00, 900000.00, 920000.00, 950000.00
	UNION 
	SELECT 5, ''D. Derechos'', 4000000.00, 4200000.00, 4300000.00, 4400000.00, 4500000.00, 4600000.00
	UNION 
	SELECT 6, ''E. Productos'', 2500000.00, 2600000.00, 2700000.00, 2800000.00, 2900000.00, 3000000.00
	UNION 
	SELECT 7, ''F. Aprovechamientos'', 1200000.00, 1250000.00, 1300000.00, 1350000.00, 1400000.00, 1450000.00
	UNION 
	SELECT 8, ''G. Ingresos por Ventas de Bienes y Servicios'', 1800000.00, 1850000.00, 1900000.00, 1950000.00, 2000000.00, 2050000.00
	UNION 
	SELECT 9, ''H. Participaciones'', 12000000.00, 12200000.00, 12400000.00, 12600000.00, 12800000.00, 13000000.00
	UNION 
	SELECT 10, ''I. Incentivos Derivados de la Colaboración Fiscal'', 2000000.00, 2100000.00, 2200000.00, 2300000.00, 2400000.00, 2500000.00
	UNION 
	SELECT 11, ''J. Transferencias'', 6000000.00, 6100000.00, 6200000.00, 6300000.00, 6400000.00, 6500000.00
	UNION 
	SELECT 12, ''K. Convenios'', 3000000.00, 3100000.00, 3200000.00, 3300000.00, 3400000.00, 3500000.00
	UNION 
	SELECT 13, ''L. Otros Ingresos de Libre Disposición'', 5000000.00, 5100000.00, 5200000.00, 5300000.00, 5400000.00, 5500000.00

	UNION 
	SELECT 14, ''2. Transferencias Federales Etiquetadas'', 65000000.00, 67000000.00, 69000000.00, 71000000.00, 73000000.00, 75000000.00
	UNION 
	SELECT 15, ''A. Aportaciones'', 35000000.00, 36000000.00, 37000000.00, 38000000.00, 39000000.00, 40000000.00
	UNION 
	SELECT 16, ''B. Convenios'', 12000000.00, 12500000.00, 13000000.00, 13500000.00, 14000000.00, 14500000.00
	UNION 
	SELECT 17, ''C. Fondos Distintos de Aportaciones'', 8000000.00, 8200000.00, 8400000.00, 8600000.00, 8800000.00, 9000000.00
	UNION 
	SELECT 18, ''D. Transferencias, Subsidios y Subvenciones, y Pensiones y Jubilaciones'', 8000000.00, 8500000.00, 9000000.00, 9500000.00, 10000000.00, 10500000.00
	UNION 
	SELECT 19, ''E. Otras Transferencias Federales Etiquetadas'', 2000000.00, 2100000.00, 2200000.00, 2300000.00, 2400000.00, 2500000.00

	UNION 
	SELECT 20, ''3. Ingresos Derivados de Financiamientos'', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00
	UNION 
	SELECT 21, ''A. Ingresos Derivados de Financiamientos'', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00

	UNION 
	SELECT 22, ''4. Total de Ingresos Proyectados'', 150000000.00, 154000000.00, 158000000.00, 162000000.00, 166000000.00, 170000000.00


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
		, Titulo = CAST(CONCAT('''', FORMAT(@p_FechaInicio, ''dd \de MMMM \del yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tblRepProyIngre
	
END';
-- [CONTA].[SPR_RepResultIngresos] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(455008702))),2) <> 'F5B7F98BA10CF8CA235711EFC6BBCB3B4F8BC68C3B8E9D20E9B60730ED45082F' OR OBJECT_DEFINITION(455008702) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_RepResultIngresos] ''2025-07-01''
ALTER   PROCEDURE [CONTA].[SPR_RepResultIngresos]
	  @p_FecInicio nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''RepResultIngresos''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')

	SELECT ID = 1, [concepto] = ''1. Ingresos de Libre Disposición '', [2020] = 466813153.00, [2021] = 486435611.00 , [2022] = 486554486.00 , [2023] = 492837844.00 , [2024] = 492331181.00, 
	[2025] = 512495160.00
	INTO #tblRepResultIngresos
	UNION 
	SELECT 2, ''A. Impuestos'', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 3, ''B. Cuotas y Aportaciones de Seguridad Social'', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 4, ''C. Contribuciones de Mejoras'', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 5, ''D. Derechos'', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 6, ''E. Productos'', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 7, ''F. Aprovechamientos'', 698571.00, 159645.00, 96349.00, 142526.00, 453474.00, 19629.00
	UNION 
	SELECT 8, ''G. Ingresos por Ventas de Bienes y Servicios'', 251028.00, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 9, ''H. Participaciones'', 38525.00, 3036.00, NULL, 55388.00, 335404.00, 645890
	UNION 
	SELECT 10, ''I. Incentivos Derivados de la Colaboración Fiscal'', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 11, ''J. Transferencias'', 465825029.00, 486272930.00, 486458137.00, 492639930.00, 491542303.00, 511829641.00
	UNION 
	SELECT 12, ''K. Convenios'', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 13, ''L. Otros Ingresos de Libre Disposición'', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 14, ''2. Transferencias Federales Etiquetadas'', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 15, ''A. Aportaciones'', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 16, ''B. Convenios'', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 17, ''C. Fondos Distintos de Aportaciones'', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 18, ''D. Transferencias, Subsidios y Subvenciones, y Pensiones y Jubilaciones'', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 19, ''E. Otras Transferencias Federales Etiquetadas'', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 20, ''3. Ingresos Derivados de Financiamientos'', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 21, ''A. Ingresos Derivados de Financiamientos'', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 22, ''4. Total de Resultados de  Ingresos'', 466813153.00, 486435611.00, 486554486.00, 492837844.00, 492331181.00, 512495160.00
	UNION 
	SELECT 23, ''Datos Informativos'', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 24, ''1. Ingresos Derivados de Financiamientos con Fuente de Pago de Recursos de Libre Disposición'', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 25, ''2. Ingresos derivados de Financiamientos con Fuente de Pago de Transferencias Federales Etiquetadas'', NULL, NULL, NULL, NULL, NULL, NULL
	UNION 
	SELECT 26, ''3. Ingresos Derivados de Financiamiento'', NULL, NULL, NULL, NULL, NULL, NULL

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
		, Titulo = CAST(CONCAT('''' , FORMAT(@p_FechaInicio, ''dd \de MMMM \del yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tblRepResultIngresos
	
END';
-- [CONTA].[SPR_RepRetenciones] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(471008759))),2) <> '6639CBAC2FB0134D9C42605AAB782BFC0CD69FDDACF1729E6E4995AA723EA2FF' OR OBJECT_DEFINITION(471008759) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_RepRetenciones] ''2025-05-01'',''2025-05-30''
ALTER   PROCEDURE [CONTA].[SPR_RepRetenciones]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''RepRetenciones''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')

	SELECT id = 1, [Concepto] = ''IMPUESTO SOBRE LA RENTA (ISR)'', 
       [Inicial] = ''$ 50,000.00'', [RetenidoPeriodo] = ''$ 12,000.00'', 
       [EnteradoPeriodo] = ''$ 10,000.00'', [PorEnterar] = ''$ 52,000.00''
	INTO #tblRepRetenciones
	UNION
	SELECT 2, ''RETENCIONES DE ISR POR SUELDOS Y SALARIOS'', 
		   ''$ 30,000.00'', ''$ 8,000.00'', ''$ 7,500.00'', ''$ 30,500.00''
	UNION
	SELECT 3, ''RETENCIONES DE ISR POR SERVICIOS PROFESIONALES (HONORARIOS)'', 
		   ''$ 10,000.00'', ''$ 3,000.00'', ''$ 2,800.00'', ''$ 10,200.00''
	UNION
	SELECT 4, ''RETENCIONES DE ISR POR PAGOS AL EXTRANJERO'', 
		   ''$ 5,000.00'', ''$ 1,500.00'', ''$ 1,000.00'', ''$ 5,500.00''
	UNION
	SELECT 5, ''RETENCIONES DE ISR POR HONORARIOS ASIMILADOS A SALARIOS'', 
		   ''$ 7,500.00'', ''$ 2,000.00'', ''$ 1,800.00'', ''$ 7,700.00''
	UNION
	SELECT 6, ''ISR POR PAGOS POR CUENTA DE TERCEROS O RETENCIONES POR ARRENDAMIENTO DE INMUEBLES'', 
		   ''$ 6,000.00'', ''$ 1,200.00'', ''$ 1,000.00'', ''$ 6,200.00''
	UNION
	SELECT 7, ''RETENCIONES DE ISR POR REGIMEN SIMPLICADO DE CONFIANZA'', 
		   ''$ 4,000.00'', ''$ 900.00'', ''$ 800.00'', ''$ 4,100.00''
	UNION
	SELECT 8, ''IMPUESTO AL VALOR AGREGADO'', 
		   ''$ 60,000.00'', ''$ 15,000.00'', ''$ 14,000.00'', ''$ 61,000.00''
	UNION
	SELECT 9, ''RETENCIONES DE IVA'', 
		   ''$ 20,000.00'', ''$ 5,000.00'', ''$ 4,500.00'', ''$ 20,500.00''
	UNION
	SELECT 10, ''IVA ACTOS ACCIDENTALES'', 
		   ''$ 2,000.00'', ''$ 500.00'', ''$ 400.00'', ''$ 2,100.00''


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
		, Titulo = CAST(CONCAT(''DEL '' , FORMAT(@p_FechaInicio, ''yyyy'', ''es-MX'') , '' AL '' ,  FORMAT(@p_FechaFin, ''yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tblRepRetenciones
	
END';
-- [CONTA].[SPR_ResultadoEgresos] : hints retirados=3; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(487008816))),2) <> '4A0B3E56E6DFC4E1EAE7CB989FF47C43D1619054DF9E1974DCD3205F27A5CA0D' OR OBJECT_DEFINITION(487008816) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_ResultadoEgresos] ''2025-05-01'',''2025-05-30''
ALTER   PROCEDURE [CONTA].[SPR_ResultadoEgresos]
	  @p_FecInicio nvarchar(24),
	  @p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	DECLARE @p_FechaInicio DATE = @p_FecInicio, @p_FechaFin DATE = @p_FecFin
	
	DECLARE @tablaFirma as table (
	id  [int] IDENTITY(1,1) NOT NULL,
	Funcion NVARCHAR(64) NULL,
	Nombre NVARCHAR(254) NULL
	)

	INSERT INTO @tablaFirma (Funcion,Nombre)
	SELECT F.Funcion, Nombre = CONCAT (P.Nombre,'' '' ,p.Paterno, '' '' ,p.Materno)
		FROM [SIS].[Reporte] R 
		JOIN [SIS].[FirmaAutorizada] F  ON R.Pk_IdReporte = F.Fk_IdReporte__SIS
		join [RHCT].[Persona] P  ON F.Fk_IdPersona__RHCT = P.PK_IdPersona
		WHERE R.Controlador = ''RepResultEgre''
		AND R.Activo = 1
		AND F.Activo = 1

	DECLARE @Funcion1 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 1),'''')
	DECLARE @Funcion2 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 2),'''')
	DECLARE @Funcion3 NVARCHAR(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE ID = 3),'''')
									 											  
	DECLARE @Nombre1 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 1) ,'''')
	DECLARE @Nombre2 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 2) ,'''')
	DECLARE @Nombre3 NVARCHAR(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE ID = 3) ,'''')

	DECLARE @Puesto1 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre1 + ''%'') ,'''')
	DECLARE @Puesto2 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre2 + ''%'') ,'''')
	DECLARE @Puesto3 NVARCHAR(254) = ISNULL((SELECT TOP 1 Puesto FROM Rhct.Persona WHERE CONCAT(Nombre, '' '', paterno, '' '' , materno) like ''%'' + @Nombre3 + ''%'') ,'''')


	SELECT id=1,Concepto = CAST(''1. Gasto No Etiquetado'' as nvarchar(500)), [Año5] = '''', [Año4] = '''', [Año3] = '''',
		   [Año2] = '''', [Año1] = '''', [Vigente] = ''''
	INTO #tblResultadoDeEgresos
	UNION
	SELECT 2, ''A. Servicios Personales'',        ''$ 150,000.00'', ''$ 155,000.00'', ''$ 160,000.00'', ''$ 165,000.00'', ''$ 170,000.00'', ''$ 175,000.00''
	UNION
	SELECT 3, ''B. Materiales y Suministros'',     ''$ 40,000.00'',  ''$ 42,000.00'',  ''$ 43,000.00'',  ''$ 45,000.00'',  ''$ 47,000.00'',  ''$ 50,000.00''
	UNION
	SELECT 4, ''C. Servicios Generales'',          ''$ 35,000.00'',  ''$ 36,000.00'',  ''$ 38,000.00'',  ''$ 39,000.00'',  ''$ 40,000.00'',  ''$ 42,000.00''
	UNION
	SELECT 5, ''D. Transferencias, Asignaciones, Subsidios y Otras Ayudas'',''$ 25,000.00'',  ''$ 26,000.00'',  ''$ 27,000.00'',  ''$ 28,000.00'',  ''$ 30,000.00'',  ''$ 32,000.00''
	UNION
	SELECT 6, ''E. Bienes Muebles, Inmuebles e Intangibles'',''$ 10,000.00'',  ''$ 11,000.00'',  ''$ 12,000.00'',  ''$ 13,000.00'',  ''$ 13,500.00'',  ''$ 14,000.00''
	UNION
	SELECT 7, ''F. Inversión Pública'',            ''$ 5,000.00'',   ''$ 5,500.00'',   ''$ 6,000.00'',   ''$ 6,500.00'',   ''$ 7,000.00'',   ''$ 8,000.00''
	UNION
	SELECT 8, ''G. Inversiones Financieras y Otras Provisiones'',''$ 3,000.00'',   ''$ 3,200.00'',   ''$ 3,500.00'',   ''$ 3,800.00'',   ''$ 4,000.00'',   ''$ 4,200.00''
	UNION
	SELECT 9, ''H. Participaciones y Aportaciones'', ''$ 7,000.00'',   ''$ 7,500.00'',   ''$ 8,000.00'',   ''$ 8,500.00'',   ''$ 9,000.00'',   ''$ 9,500.00''
	UNION
	SELECT 10, ''I. Deuda Pública'',              ''$ 2,000.00'',   ''$ 2,200.00'',   ''$ 2,300.00'',   ''$ 2,400.00'',   ''$ 2,600.00'',   ''$ 2,800.00''
	UNION
	SELECT 11, ''Subtotal Gasto No Etiquetado'',  ''$ 277,000.00'', ''$ 288,400.00'', ''$ 299,800.00'', ''$ 311,200.00'', ''$ 323,100.00'', ''$ 337,500.00''
	UNION
	SELECT 12, ''2. Gasto Etiquetado'', '''', '''', '''', '''', '''', ''''
	UNION
	SELECT 13, ''A. Servicios Personales'',       ''$ 180,000.00'', ''$ 185,000.00'', ''$ 190,000.00'', ''$ 195,000.00'', ''$ 200,000.00'', ''$ 210,000.00''
	UNION
	SELECT 14, ''B. Materiales y Suministros'',   ''$ 30,000.00'',  ''$ 32,000.00'',  ''$ 33,000.00'',  ''$ 34,000.00'',  ''$ 35,000.00'',  ''$ 36,000.00''
	UNION
	SELECT 15, ''C. Servicios Generales'',        ''$ 28,000.00'',  ''$ 29,000.00'',  ''$ 30,000.00'',  ''$ 31,000.00'',  ''$ 32,000.00'',  ''$ 33,000.00''
	UNION
	SELECT 16, ''D. Transferencias, Asignaciones, Subsidios y Otras Ayudas'',''$ 40,000.00'',  ''$ 41,000.00'',  ''$ 42,000.00'',  ''$ 43,000.00'',  ''$ 44,000.00'',  ''$ 45,000.00''
	UNION
	SELECT 17, ''E. Bienes Muebles, Inmuebles e Intangibles'',''$ 15,000.00'',  ''$ 15,500.00'',  ''$ 16,000.00'',  ''$ 16,500.00'',  ''$ 17,000.00'',  ''$ 18,000.00''
	UNION
	SELECT 18, ''F. Inversión Pública'',          ''$ 20,000.00'',  ''$ 21,000.00'',  ''$ 22,000.00'',  ''$ 23,000.00'',  ''$ 24,000.00'',  ''$ 25,000.00''
	UNION
	SELECT 19, ''G. Inversiones Financieras y Otras Provisiones'',''$ 5,000.00'',   ''$ 5,200.00'',   ''$ 5,400.00'',   ''$ 5,600.00'',   ''$ 5,800.00'',   ''$ 6,000.00''
	UNION
	SELECT 20, ''H. Participaciones y Aportaciones'',''$ 10,000.00'',  ''$ 10,500.00'',  ''$ 11,000.00'',  ''$ 11,500.00'',  ''$ 12,000.00'',  ''$ 12,500.00''
	UNION
	SELECT 21, ''I. Deuda Pública'',              ''$ 3,000.00'',   ''$ 3,100.00'',   ''$ 3,200.00'',   ''$ 3,300.00'',   ''$ 3,400.00'',   ''$ 3,600.00''
	UNION
	SELECT 22, ''Subtotal Gasto Etiquetado'',     ''$ 331,000.00'', ''$ 342,300.00'', ''$ 352,600.00'', ''$ 362,900.00'', ''$ 373,200.00'', ''$ 389,100.00''

	UNION
	SELECT 23, ''3. Total del Resultado de Egresos'',''$ 608,000.00'', ''$ 630,700.00'', ''$ 652,400.00'', ''$ 674,100.00'', ''$ 696,300.00'', ''$ 726,600.00''


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
		, Titulo = CAST(CONCAT(''DEL '' , FORMAT(@p_FechaInicio, ''dd \de MMMM \del yyyy'', ''es-MX'') , '' AL '' ,  FORMAT(@p_FechaFin, ''dd \de MMMM \del yyyy'', ''es-MX'')) AS NVARCHAR(128))
	FROM #tblResultadoDeEgresos
	
END';
-- [CONTA].[VW_CUENTAS_LibroMayor] : hints retirados=2; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(2017442261))),2) <> '3B88EA85600FA8386D5E6341AB112203D51D06FF9E36CB80915D4C4209471B13' OR OBJECT_DEFINITION(2017442261) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
EXEC sys.sp_executesql N'ALTER VIEW [CONTA].[VW_CUENTAS_LibroMayor]
AS
SELECT cc.Pk_IdCuenta,
       cc.NivelCuenta,
       cc.ClaveOrd,
       cc.ClaveNombre,
       cc.Nombre,
       po.FechaPoliza,
       YEAR(po.FechaPoliza) AS AnioPoliza,
       UPPER(FORMAT(po.FechaPoliza, ''MMMM'', ''es-MX'')) AS MesPoliza
FROM [CONTA].[Vw_Cuentas] cc
JOIN (
    SELECT dp.FKIdCuentaContable_CONTA, p.FechaPoliza
    FROM [CONTA].[Poliza] p 
    INNER JOIN [CONTA].[PolizaDetalle] dp  ON p.PKIdPoliza = dp.FKIdPoliza_CONTA
    WHERE p.Activo = 1 AND dp.Activo = 1
) po ON po.FKIdCuentaContable_CONTA = cc.Pk_IdCuenta;';
-- [SIS].[LoginInformationEmployee] : hints retirados=4; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(355532350))),2) <> '8B963B87BC6D5C87AAF08B1B2FE9B64F1CED40BE6DC8C1A8385F02196D3C711A' OR OBJECT_DEFINITION(355532350) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
EXEC sys.sp_executesql N'--EXEC [SIS].[LoginInformationEmployee] @PayrollID = ''ADMIN001''
ALTER   PROCEDURE [SIS].[LoginInformationEmployee](
	@PayrollID NVARCHAR(60)
)
AS BEGIN
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	SELECT e.PkIdUsuario
    , iif(e.FKIdPersona_NOM IS NULL,0,e.FKIdPersona_NOM) FKIdPersonaNOM
    , e.PayrollID
    , iif(p.Gafete is null,e.PayrollID,p.Gafete) Gafete
    , ANU.PasswordHash
    , rol.Name
    , iif(p.CORREO_ELECTRONICO IS NULL ,''ADMIN@eg.COM'',p.CORREO_ELECTRONICO) AS Email
    , NombreUsuario = IIF(p.Nombre IS NULL,''Admin'',CONCAT(p.Nombre, '' '', p.Paterno, '' '', p.Materno))
	FROM SIS.Usuario AS e 
	LEFT JOIN NOM.Persona p ON e.FKIdPersona_NOM = p.PKIdPersona
	INNER JOIN dbo.AspNetUsers AS ANU  ON ANU.PkIdUsuario = e.PkIdUsuario
	INNER JOIN [dbo].[AspNetUserRoles] AS UR  ON UR.UserId = ANU.Id
	INNER JOIN AspNetRoles AS rol  ON UR.RoleId = rol.Id
	WHERE e.PayrollID = @PayrollID AND e.Activo = 1
END;';
-- [SIS].[sp_NotificacionCrear] : hints retirados=0; XACT_ABORT=True
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(403532521))),2) <> '93EA757EA8C36E28BB35D142BCCD86322E7EDB66856AB703B2C4AB9E4FF9A25D' OR OBJECT_DEFINITION(403532521) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
EXEC sys.sp_executesql N'ALTER   PROCEDURE SIS.sp_NotificacionCrear
(
    @ClaveTipo NVARCHAR(80),
    @Fk_IdUsuarioOrigen INT = NULL,

    @Modulo NVARCHAR(120),
    @SubModulo NVARCHAR(120) = NULL,
    @Evento NVARCHAR(120),

    @Entidad NVARCHAR(150) = NULL,
    @Fk_IdEntidad BIGINT = NULL,

    @Titulo NVARCHAR(250),
    @Mensaje NVARCHAR(MAX),
    @Url NVARCHAR(1000) = NULL,
    @JsonData NVARCHAR(MAX) = NULL,

    @Usuarios SIS.NotificacionUsuarioType READONLY,
    @IdUser INT = NULL,
    @IdNotificacion BIGINT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Fk_IdNotificacionTipo INT;

    SELECT @Fk_IdNotificacionTipo = Pk_IdNotificacionTipo
    FROM SIS.NotificacionTipo
    WHERE Clave = @ClaveTipo
      AND Activo = 1;

    IF @Fk_IdNotificacionTipo IS NULL
    BEGIN
        THROW 51000, ''Tipo de notificación no válido.'', 1;
    END;

    BEGIN TRY
        BEGIN TRAN;

        INSERT INTO SIS.Notificacion (
            Fk_IdNotificacionTipo,
            Fk_IdUsuarioOrigen,
            Modulo,
            SubModulo,
            Evento,
            Entidad,
            Fk_IdEntidad,
            Titulo,
            Mensaje,
            Url,
            JsonData,
            CT_CreatedBy,
            CT_CreatedDate,
            CT_LIVE
        )
        VALUES (
            @Fk_IdNotificacionTipo,
            @Fk_IdUsuarioOrigen,
            @Modulo,
            @SubModulo,
            @Evento,
            @Entidad,
            @Fk_IdEntidad,
            @Titulo,
            @Mensaje,
            @Url,
            @JsonData,
            @IdUser,
            GETDATE(),
            1
        );

        SET @IdNotificacion = SCOPE_IDENTITY();

        INSERT INTO SIS.NotificacionDestino (
            Fk_IdNotificacion,
            Fk_IdUsuarioDestino,
            Fk_IdNotificacionEstado,
            CT_CreatedBy,
            CT_CreatedDate,
            CT_LIVE
        )
        SELECT DISTINCT
            @IdNotificacion,
            u.Fk_IdUsuarioDestino,
            1,
            @IdUser,
            GETDATE(),
            1
        FROM @Usuarios u
        WHERE u.Fk_IdUsuarioDestino IS NOT NULL;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;';
-- [SIS].[spDocumentoAnotacionCrear] : hints retirados=0; XACT_ABORT=True
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(515532920))),2) <> '171F02376C702A684496B860DA30CDDBCB209BFE4D482F1B4E976BAC091655FE' OR OBJECT_DEFINITION(515532920) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
EXEC sys.sp_executesql N'/* ============================================================
   8. SPS ANOTACIONES
   ============================================================ */

ALTER   PROCEDURE SIS.spDocumentoAnotacionCrear
    @FkidDocumento BIGINT,
    @TipoAnotacion NVARCHAR(30),
    @Comentario NVARCHAR(MAX) = NULL,
    @TextoSeleccionado NVARCHAR(MAX) = NULL,
    @Pagina INT = NULL,
    @PosicionX DECIMAL(9,6) = NULL,
    @PosicionY DECIMAL(9,6) = NULL,
    @Ancho DECIMAL(9,6) = NULL,
    @Alto DECIMAL(9,6) = NULL,
    @Color NVARCHAR(20) = N''#FFE066'',
    @IdUser INT,
    @PkidDocumentoAnotacion BIGINT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @message NVARCHAR(MAX);
    DECLARE @FkidDocumentoTipoAnotacion INT;

    BEGIN TRY
        SELECT @FkidDocumentoTipoAnotacion = PkidDocumentoTipoAnotacion
        FROM SIS.DocumentoTipoAnotacion
        WHERE Clave = UPPER(LTRIM(RTRIM(@TipoAnotacion)))
          AND Activo = 1;

        IF @FkidDocumentoTipoAnotacion IS NULL
            THROW 51030, ''Tipo de anotación inválido.'', 1;

        IF NOT EXISTS (SELECT 1 FROM SIS.Documento WHERE PkidDocumento = @FkidDocumento AND Activo = 1)
            THROW 51031, ''Documento no encontrado o inactivo.'', 1;

        IF UPPER(LTRIM(RTRIM(@TipoAnotacion))) = N''COMENTARIO''
           AND NULLIF(LTRIM(RTRIM(ISNULL(@Comentario, N''''))), N'''') IS NULL
            THROW 51032, ''El comentario es requerido.'', 1;

        IF UPPER(LTRIM(RTRIM(@TipoAnotacion))) = N''RESALTADO''
           AND (
                @Pagina IS NULL
                OR @PosicionX IS NULL
                OR @PosicionY IS NULL
                OR @Ancho IS NULL
                OR @Alto IS NULL
           )
            THROW 51033, ''El resaltado requiere página y coordenadas.'', 1;

        BEGIN TRANSACTION;

        INSERT INTO SIS.DocumentoAnotacion
        (
            FkidDocumento,
            FkidDocumentoTipoAnotacion,
            Comentario,
            TextoSeleccionado,
            Pagina,
            PosicionX,
            PosicionY,
            Ancho,
            Alto,
            Color,
            Activo,
            CT_CreatedBy,
            CT_CreatedDate
        )
        VALUES
        (
            @FkidDocumento,
            @FkidDocumentoTipoAnotacion,
            @Comentario,
            @TextoSeleccionado,
            @Pagina,
            @PosicionX,
            @PosicionY,
            @Ancho,
            @Alto,
            ISNULL(@Color, N''#FFE066''),
            1,
            @IdUser,
            SYSDATETIME()
        );

        SET @PkidDocumentoAnotacion = SCOPE_IDENTITY();

        INSERT INTO SIS.DocumentoEvento (FkidDocumento, Evento, Comentario, CT_CreatedBy)
        VALUES (@FkidDocumento, N''ANOTACION_CREADA'', N''Se agregó una anotación al documento.'', @IdUser);

        COMMIT TRANSACTION;

        SET @message = N''Se agregó correctamente la anotación.'';

        SELECT JSON_QUERY(CONCAT(
            ''{'',
            ''"tipo":"OK",'',
            ''"mensaje":"'', @message, ''",'',
            ''"id":'', @PkidDocumentoAnotacion, '','',
            ''"liga":""'',
            ''}''
        )) AS ResultJson;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        SET @message = CONCAT(''Error: '', ERROR_MESSAGE(), '' Linea: '', ERROR_LINE());

        SELECT JSON_QUERY(CONCAT(
            ''{'',
            ''"tipo":"ERROR",'',
            ''"mensaje":"'', REPLACE(REPLACE(@message, ''"'', ''''), '':'', '' ''), ''",'',
            ''"liga":""'',
            ''}''
        )) AS ResultJson;
    END CATCH
END';
-- [SIS].[spDocumentoAnotacionEliminar] : hints retirados=0; XACT_ABORT=True
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(531532977))),2) <> 'C1FD0C25FB248B3EC3FBCC294BA4C2825655CB11B09F8DBB1534DA90EF4F575A' OR OBJECT_DEFINITION(531532977) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
EXEC sys.sp_executesql N'ALTER   PROCEDURE SIS.spDocumentoAnotacionEliminar
    @PkidDocumentoAnotacion BIGINT,
    @IdUser INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @message NVARCHAR(MAX);
    DECLARE @FkidDocumento BIGINT;

    BEGIN TRY
        SELECT @FkidDocumento = FkidDocumento
        FROM SIS.DocumentoAnotacion
        WHERE PkidDocumentoAnotacion = @PkidDocumentoAnotacion
          AND Activo = 1;

        IF @FkidDocumento IS NULL
            THROW 51040, ''Anotación no encontrada o inactiva.'', 1;

        BEGIN TRANSACTION;

        UPDATE SIS.DocumentoAnotacion
        SET Activo = 0,
            CT_ModifiedBy = @IdUser,
            CT_ModifiedDate = SYSDATETIME()
        WHERE PkidDocumentoAnotacion = @PkidDocumentoAnotacion
          AND Activo = 1;

        INSERT INTO SIS.DocumentoEvento (FkidDocumento, Evento, Comentario, CT_CreatedBy)
        VALUES (@FkidDocumento, N''ANOTACION_ELIMINADA'', N''Se eliminó lógicamente una anotación.'', @IdUser);

        COMMIT TRANSACTION;

        SET @message = N''Se eliminó correctamente la anotación.'';

        SELECT JSON_QUERY(CONCAT(
            ''{'',
            ''"tipo":"OK",'',
            ''"mensaje":"'', @message, ''",'',
            ''"liga":""'',
            ''}''
        )) AS ResultJson;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        SET @message = CONCAT(''Error: '', ERROR_MESSAGE(), '' Linea: '', ERROR_LINE());

        SELECT JSON_QUERY(CONCAT(
            ''{'',
            ''"tipo":"ERROR",'',
            ''"mensaje":"'', REPLACE(REPLACE(@message, ''"'', ''''), '':'', '' ''), ''",'',
            ''"liga":""'',
            ''}''
        )) AS ResultJson;
    END CATCH
END';
-- [SIS].[spDocumentoEliminar] : hints retirados=0; XACT_ABORT=True
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(563533091))),2) <> '679DD23728FC29E2CCEF6DD1C043789E4866BAFC18827F14C88A11E41BEA725B' OR OBJECT_DEFINITION(563533091) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
EXEC sys.sp_executesql N'ALTER   PROCEDURE SIS.spDocumentoEliminar
    @PkidDocumento BIGINT,
    @IdUser INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @message NVARCHAR(MAX);

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE SIS.Documento
        SET Activo = 0,
            CT_ModifiedBy = @IdUser,
            CT_ModifiedDate = SYSDATETIME()
        WHERE PkidDocumento = @PkidDocumento
          AND Activo = 1;

        INSERT INTO SIS.DocumentoEvento (FkidDocumento, Evento, Comentario, CT_CreatedBy)
        VALUES (@PkidDocumento, N''ELIMINADO'', N''Documento eliminado lógicamente.'', @IdUser);

        COMMIT TRANSACTION;

        SET @message = N''Se eliminó correctamente el documento.'';

        SELECT JSON_QUERY(CONCAT(
            ''{'',
            ''"tipo":"OK",'',
            ''"mensaje":"'', @message, ''",'',
            ''"liga":""'',
            ''}''
        )) AS ResultJson;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        SET @message = CONCAT(''Error: '', ERROR_MESSAGE(), '' Linea: '', ERROR_LINE());

        SELECT JSON_QUERY(CONCAT(
            ''{'',
            ''"tipo":"ERROR",'',
            ''"mensaje":"'', REPLACE(REPLACE(@message, ''"'', ''''), '':'', '' ''), ''",'',
            ''"liga":""'',
            ''}''
        )) AS ResultJson;
    END CATCH
END';
-- [SIS].[spDocumentoGuardar] : hints retirados=0; XACT_ABORT=True
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(579533148))),2) <> 'BF4938BEFC14D40648B788AD3A5AF14A5101CBFB189D08035C674E61E0020912' OR OBJECT_DEFINITION(579533148) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
EXEC sys.sp_executesql N'/* ============================================================
   7. SPS DOCUMENTOS
   ============================================================ */

ALTER   PROCEDURE SIS.spDocumentoGuardar
    @PkidDocumento BIGINT = NULL OUTPUT,
    @Modulo NVARCHAR(120),
    @SubModulo NVARCHAR(120) = NULL,
    @Controlador NVARCHAR(160) = NULL,
    @Servicio NVARCHAR(160) = NULL,
    @EntidadId BIGINT,
    @FkidEmpresaSis INT = NULL,
    @Titulo NVARCHAR(250) = NULL,
    @Descripcion NVARCHAR(MAX) = NULL,
    @NombreOriginal NVARCHAR(260),
    @NombreAlmacenado NVARCHAR(260) = NULL,
    @Extension NVARCHAR(16),
    @TipoMime NVARCHAR(120),
    @TamanoBytes BIGINT,
    @ModoAlmacenamiento NVARCHAR(20),
    @ContenidoArchivo VARBINARY(MAX) = NULL,
    @RutaRelativa NVARCHAR(700) = NULL,
    @IdUser INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @message NVARCHAR(MAX);
    DECLARE @EsImagen BIT = NULL;
    DECLARE @EsPdf BIT = NULL;

    BEGIN TRY
        SET @ModoAlmacenamiento = UPPER(LTRIM(RTRIM(@ModoAlmacenamiento)));
        SET @Extension = LOWER(LTRIM(RTRIM(@Extension)));

        IF LEFT(@Extension, 1) <> N''.''
            SET @Extension = CONCAT(N''.'', @Extension);

        IF NULLIF(LTRIM(RTRIM(ISNULL(@NombreAlmacenado, N''''))), N'''') IS NULL
            SET @NombreAlmacenado = CONCAT(REPLACE(CONVERT(VARCHAR(36), NEWID()), ''-'', ''''), @Extension);

        SELECT
            @EsImagen = EsImagen,
            @EsPdf = EsPdf
        FROM SIS.DocumentoExtensionPermitida
        WHERE Extension = @Extension
          AND Activo = 1;

        IF @ModoAlmacenamiento NOT IN (N''DATABASE'', N''FILESYSTEM'')
            THROW 51000, ''Modo de almacenamiento inválido.'', 1;

        IF @EsImagen IS NULL AND @EsPdf IS NULL
            THROW 51001, ''Extensión de documento no permitida.'', 1;

        IF @EntidadId IS NULL OR @EntidadId <= 0
            THROW 51002, ''EntidadId inválido.'', 1;

        IF @ModoAlmacenamiento = N''DATABASE'' AND @PkidDocumento IS NULL AND @ContenidoArchivo IS NULL
            THROW 51003, ''El archivo binario es requerido para almacenamiento en base de datos.'', 1;

        IF @ModoAlmacenamiento = N''FILESYSTEM''
           AND (
                NULLIF(LTRIM(RTRIM(ISNULL(@RutaRelativa, N''''))), N'''') IS NULL
                OR @RutaRelativa LIKE N''%..%''
                OR @RutaRelativa LIKE N''%:%''
           )
            THROW 51004, ''Ruta relativa inválida para almacenamiento en carpeta.'', 1;

        BEGIN TRANSACTION;

        IF @PkidDocumento IS NULL OR @PkidDocumento = 0
        BEGIN
            INSERT INTO SIS.Documento
            (
                Modulo, SubModulo, Controlador, Servicio, EntidadId, FkidEmpresaSis,
                Titulo, Descripcion, NombreOriginal, NombreAlmacenado, Extension,
                TipoMime, TamanoBytes, ModoAlmacenamiento, ContenidoArchivo,
                RutaRelativa, HashSha256, EsImagen, EsPdf, Activo,
                CT_CreatedBy, CT_CreatedDate
            )
            VALUES
            (
                @Modulo, @SubModulo, @Controlador, @Servicio, @EntidadId, @FkidEmpresaSis,
                @Titulo, @Descripcion, @NombreOriginal, @NombreAlmacenado, @Extension,
                @TipoMime, @TamanoBytes, @ModoAlmacenamiento, @ContenidoArchivo,
                @RutaRelativa,
                CASE WHEN @ContenidoArchivo IS NOT NULL THEN HASHBYTES(''SHA2_256'', @ContenidoArchivo) ELSE NULL END,
                @EsImagen, @EsPdf, 1,
                @IdUser, SYSDATETIME()
            );

            SET @PkidDocumento = SCOPE_IDENTITY();

            INSERT INTO SIS.DocumentoEvento (FkidDocumento, Evento, Comentario, CT_CreatedBy)
            VALUES (@PkidDocumento, N''CREADO'', N''Documento agregado al soporte documental.'', @IdUser);

            SET @message = CONCAT(N''Se agregó correctamente el documento '', @NombreOriginal);
        END
        ELSE
        BEGIN
            UPDATE SIS.Documento
            SET
                Titulo = @Titulo,
                Descripcion = @Descripcion,
                NombreOriginal = @NombreOriginal,
                NombreAlmacenado = @NombreAlmacenado,
                Extension = @Extension,
                TipoMime = @TipoMime,
                TamanoBytes = @TamanoBytes,
                ModoAlmacenamiento = @ModoAlmacenamiento,
                ContenidoArchivo = CASE WHEN @ContenidoArchivo IS NULL THEN ContenidoArchivo ELSE @ContenidoArchivo END,
                RutaRelativa = @RutaRelativa,
                HashSha256 = CASE WHEN @ContenidoArchivo IS NULL THEN HashSha256 ELSE HASHBYTES(''SHA2_256'', @ContenidoArchivo) END,
                EsImagen = @EsImagen,
                EsPdf = @EsPdf,
                CT_ModifiedBy = @IdUser,
                CT_ModifiedDate = SYSDATETIME()
            WHERE PkidDocumento = @PkidDocumento
              AND Activo = 1;

            INSERT INTO SIS.DocumentoEvento (FkidDocumento, Evento, Comentario, CT_CreatedBy)
            VALUES (@PkidDocumento, N''ACTUALIZADO'', N''Documento actualizado.'', @IdUser);

            SET @message = CONCAT(N''Se actualizó correctamente el documento '', @NombreOriginal);
        END

        COMMIT TRANSACTION;

        SELECT JSON_QUERY(CONCAT(
            ''{'',
            ''"tipo":"OK",'',
            ''"mensaje":"'', REPLACE(REPLACE(@message, ''"'', ''''), '':'', '' ''), ''",'',
            ''"id":'', @PkidDocumento, '','',
            ''"liga":""'',
            ''}''
        )) AS ResultJson;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        SET @message = CONCAT(''Error: '', ERROR_MESSAGE(), '' Linea: '', ERROR_LINE());

        SELECT JSON_QUERY(CONCAT(
            ''{'',
            ''"tipo":"ERROR",'',
            ''"mensaje":"'', REPLACE(REPLACE(@message, ''"'', ''''), '':'', '' ''), ''",'',
            ''"liga":""'',
            ''}''
        )) AS ResultJson;
    END CATCH
END';
-- [SIS].[spEliminarUsuarioSucursal] : hints retirados=0; XACT_ABORT=True
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(627533319))),2) <> '9FCFB7577B4467B5C12D008CC8EB29BE147B6ED32C5E243C42DD75AA29649186' OR OBJECT_DEFINITION(627533319) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
EXEC sys.sp_executesql N'ALTER   PROCEDURE [SIS].[spEliminarUsuarioSucursal]
    @FkidUsuarioSis INT,
    @FkidSucursalSis INT,
    @UsuarioModificacion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1 FROM SIS.UsuarioSucursal 
            WHERE FkidUsuario_Sis = @FkidUsuarioSis 
            AND FkidSucursal_Sis = @FkidSucursalSis
        )
        BEGIN
            SELECT 
                0 AS Success,
                ''No se encontr� la asignaci�n especificada'' AS Message,
                ''NOT_FOUND'' AS Code;
            COMMIT TRANSACTION; -- EG20261125: cierra la transaccion propia sin asignacion.
            RETURN;
        END

        DELETE FROM SIS.UsuarioSucursal 
        WHERE FkidUsuario_Sis = @FkidUsuarioSis 
        AND FkidSucursal_Sis = @FkidSucursalSis;

        COMMIT TRANSACTION;

        SELECT 
            1 AS Success,
            ''Asignaci�n eliminada correctamente'' AS Message,
            ''SUCCESS'' AS Code;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        SELECT 
            0 AS Success,
            @ErrorMessage AS Message,
            ''ERROR'' AS Code;

    END CATCH
END';
-- [SIS].[Vw_EmpresaDepartamanto] : hints retirados=2; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(1178487277))),2) <> '6184EE91D0B2CF74F5D645D433CFE42D4C3480B5D75448DBA6C40114559B2181' OR OBJECT_DEFINITION(1178487277) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
EXEC sys.sp_executesql N'ALTER VIEW [SIS].[Vw_EmpresaDepartamanto]
AS
SELECT E.PKIdEmpresa,
	   E.Nombre AS EmpresaNombre,
	   E.RFC,
	   D.PKIdDepartamento,
	   D.Nombre AS DepartamentoNombre,
	   D.Activo AS DepartamentoActivo,
	   E.Activo AS EmpresaActivo,
      E.FechaCreacion,E.UsuarioCreacion,E.FechaModificacion,E.UsuarioModificacion
FROM [SIS].[Empresa] E 
INNER JOIN [SIS].[Departamento] D  ON E.PKIdEmpresa = D.FKIdEmpresa_SIS
WHERE E.Activo = 1 AND D.Activo = 1 ;';
-- [SIS].[Vw_SucursalEmpresaEstado] : hints retirados=4; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(1258487562))),2) <> '6298FB3C97E878213EB6A03F238433467FC980F0A277A91A46684CABF8B5387A' OR OBJECT_DEFINITION(1258487562) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
EXEC sys.sp_executesql N'ALTER VIEW [SIS].[Vw_SucursalEmpresaEstado]
AS
SELECT 
    s.PKIdSucursal,
    s.FKIdEmpresa_SIS,
    s.FKIdEstado_SIS,
    s.Nombre,
    s.CodigoSucursal,
    s.Alias,
    s.FKIdTipoSucursal,
    s.FKIdMonedaLocal_SIS,
    s.Direccion,
    s.Colonia,
    s.Ciudad,
    s.CodigoPostal,
    s.TelefonoPrincipal,
    s.TelefonoSecundario,
    s.Email,
    s.HorarioApertura,
    s.HorarioCierre,
    s.EsMatriz,
    s.EsActiva,
    s.Latitud,
    s.Longitud,
    -- Informaci?n adicional de la empresa
    e.Nombre AS NombreEmpresa,
    e.RFC,
    -- Informaci?n del estado
    est.Nombre AS NombreEstado,
    est.CodigoEstado,
    p.Nombre AS NombrePais,
    E.Activo,
    E.FechaCreacion,E.UsuarioCreacion,E.FechaModificacion,E.UsuarioModificacion
FROM [SIS].Sucursal s 
INNER JOIN [SIS].Empresa e  
    ON s.FKIdEmpresa_SIS = e.PKIdEmpresa 
    AND e.Activo = 1
INNER JOIN [SIS].Estados est  
    ON s.FKIdEstado_SIS = est.PKIdEstado 
    AND est.Activo = 1
INNER JOIN [SIS].Paises p  
    ON est.FKIdPais_SIS = p.PKIdPais 
    AND p.Activo = 1
WHERE s.Activo = 1;';
COMMIT TRANSACTION;
END TRY BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK TRANSACTION; THROW; END CATCH;
