-- Source: BD_PRESUPUESTO.[NOMI].[SP_DevengaQuincena]
-- Extracted for Nomina migration. Review schema/table mappings before applying to GestionEmpresarial.
GO
CREATE   PROCEDURE [NOMI].[SP_DevengaQuincena]
	@intIdTipoNomina INT,
	@ClcIngresos INT

AS
BEGIN
SET NOCOUNT ON;    
    DECLARE @v_FK_IdAnioAnterior INT;
	DECLARE @v_FK_IdMesAnterior INT;
	DECLARE @v_QuincenaAnterior INT;
    
	DECLARE @v_FK_IdAnioActual INT;	
	DECLARE @v_FK_IdMesActual INT;
	DECLARE @v_QuincenaActual INT;
	
	DECLARE @v_FechaInicio Date;
 
	DECLARE @v_FK_IdAnioSiguiente INT;	
    DECLARE @v_FK_IdMesSiguiente INT;
	DECLARE @v_QuincenaSiguiente INT;

	DECLARE @v_QuincenasActuales INT;
	DECLARE @message NVARCHAR(100)

	-- Variables para para cursores
	Declare @Area int, @Partida int

	-- Variable para verificar que exixte la CLC de Ingresos
	DECLARE @ExisteCLC Int = 0;



	SELECT @v_QuincenasActuales = COUNT(QAc.Actual ) 
	FROM NOMI.QuincenaActual QAc WHERE QAc.Actual = 1;

	

	-- Se valida que no haya mas de un mes actual en la tabla
	IF @v_QuincenasActuales <> 1
    BEGIN

		SET @message = 'Verifique el año, mes actual y quincena que pretende cerrar. Revise la tabla NOMI.QuincenaActual.'
				SELECT JSON_QUERY( 
						CONCAT( '{', '"tipo":"', 'ERROR', 
									   '",', '"mensaje":"', @message, 
									   '",', '"liga":"', 'NOMI.QuincenaActual', '"', '}' ) 
					) 
				AS ResultJson 
				RETURN;
    END

	-- Se valida que haya un mes actual configurado
	SELECT @v_FK_IdAnioActual = QAc.Fk_IdAnio__SIS, @v_FK_IdMesActual = QAc.Fk_IdMes__SIS,  @v_QuincenaActual = QAc.Quincena
	FROM NOMI.QuincenaActual QAc WHERE QAc.Actual = 1;

	IF @v_FK_IdAnioActual IS NULL OR @v_QuincenaActual IS NULL 
    BEGIN 

			SET @message = 'Verifique el año, mes actual y quincena que pretende cerrar. Verifique la tabla'
				SELECT JSON_QUERY( 
						CONCAT( '{', '"tipo":"', 'ERROR', 
									   '",', '"mensaje":"', @message, 
									   '",', '"liga":"', 'NOMI.QuincenaActual', '"', '}' ) 
					) 
				AS ResultJson 
				RETURN;
    END 

	DECLARE @v_registros int = 0

	SELECT @v_registros = COUNT(*) 
	FROM NOMI.VW_DevengaNomina	
	WHERE intEjercicio = @v_FK_IdAnioActual
		AND intQuincena = @v_QuincenaActual
		AND intIdTipoNomina = @intIdTipoNomina
		AND EstaProcesado = 0  -- Se toman en cuenta los registros no procesados

	IF @v_registros = 0
    BEGIN 

			SET @message = 'No hay registros que procesar, verifique si la quincena ha sido procesada'
				SELECT JSON_QUERY( 
						CONCAT( '{', '"tipo":"', 'ERROR', 
									   '",', '"mensaje":"', @message, 
									   '",', '"liga":"', 'NOMI.QuincenaActual', '"', '}' ) 
					) 
				AS ResultJson 
				RETURN;
    END 

	


	--Se valida que existe CLC de Ingresos	
	SELECT @ExisteCLC = Pk_IdCLCFactura
	FROM PRES.CLCFactura WHERE Pk_IdCLCFactura =  @ClcIngresos 

	IF @ExisteCLC = 0
    BEGIN 
		
		SET @message = 'No existe la CLC de Ingresos, No hay recursos para procesar la nómina'
			SELECT JSON_QUERY( 
					CONCAT( '{', '"tipo":"', 'ERROR', 
								   '",', '"mensaje":"', @message, 
								   '",', '"liga":"', 'NOMI.QuincenaActual', '"', '}' ) 
				) 
			AS ResultJson 
			RETURN;

    END 
	

	-- Se configura el mes año anterior y siguiente
	SET @v_QuincenaSiguiente = (CASE WHEN @v_QuincenaActual + 1 > 24 THEN 1 ELSE @v_QuincenaActual + 1  END);
	SET @v_FK_IdMesSiguiente = (CASE WHEN @v_FK_IdMesActual + 1 > 12 THEN 1 ELSE @v_FK_IdMesActual + 1 END);
	SET @v_FK_IdAnioSiguiente = (CASE WHEN @v_QuincenaActual + 1 > 24  THEN @v_FK_IdAnioActual + 1 ELSE @v_FK_IdAnioActual  END);

	
	SET @v_QuincenaAnterior = (CASE WHEN @v_QuincenaActual = 1 THEN 24 ELSE @v_QuincenaActual - 1 END);
	SET @v_FK_IdMesAnterior = (CASE WHEN @v_FK_IdMesActual = 1 THEN 13 ELSE @v_FK_IdMesActual - 1 END);
	SET @v_FK_IdAnioAnterior = (CASE WHEN @v_QuincenaActual = 1  THEN @v_FK_IdAnioActual - 1 ELSE @v_FK_IdAnioActual  END);
	
	--*************************************************************
	--****** Principia Lógica de Devengado de Nónina
	--*************************************************************
	
	DECLARE @intEjercicio int = @v_FK_IdAnioActual;
	DECLARE @intQuincena int = @v_QuincenaActual;
	DECLARE @Fecha Date = GetDate();


		
			
			
			DECLARE @mes int =  CASE @intQuincena
						WHEN 1 THEN	 1
						WHEN 2 THEN	 1
						WHEN 3 THEN	 2
						WHEN 4 THEN	 2
						WHEN 5 THEN	 3
						WHEN 6 THEN	 3
						WHEN 7 THEN	 4
						WHEN 8 THEN	 4
						WHEN 9 THEN	 5
						WHEN 10 THEN 5
						WHEN 11 THEN 6
						WHEN 12 THEN 6
						WHEN 12 THEN 7
						WHEN 14 THEN 7
						WHEN 15 THEN 8
						WHEN 16 THEN 8
						WHEN 17 THEN 9
						WHEN 18 THEN 9
						WHEN 19 THEN 10
						WHEN 20 THEN 10
						WHEN 21 THEN 11
						WHEN 22 THEN 11
						WHEN 23 THEN 12
						WHEN 24 THEN 12
					END;


	
			DECLARE @TieneNegativos int;
			DECLARE @tipo NVARCHAR(100)
			

			SET @TieneNegativos =	(SELECT Count(*)
									FROM [NOMI].[VW_DevengaNomina] DN
									WHERE DN.intEjercicio = @intEjercicio
									AND DN.intQuincena = @intQuincena
									AND  DN.SaldoMes - DN.Importe < 0)

			IF @TieneNegativos > 0
				BEGIN					
					-- se declara un cursor para regresar las partidas que tienen error
					DECLARE cursor_PartidasSinPres CURSOR FOR	
					
					SELECT 				
						 ISNULL(strUnidadAdm, 0)
						,intPartida				
						FROM [NOMI].[VW_DevengaNomina] DN
						WHERE DN.intEjercicio = @intEjercicio
						AND DN.intQuincena = @intQuincena
						AND  DN.SaldoMes - DN.Importe < 0
					
					-- abre cursor
					OPEN cursor_PartidasSinPres;
					 
					-- loop en el cursor
					FETCH NEXT FROM cursor_PartidasSinPres INTO @Area, @partida
					WHILE @@FETCH_STATUS = 0
					    BEGIN
						SET @message = @message +'(A: ' + CAST(@Area AS varchar(5)) + ' P: ' + CAST(@partida AS varchar(5))+'), ';
					   -- PRINT @v_ErrorMatriz
					    FETCH NEXT FROM cursor_PartidasSinPres INTO @Area, @partida;
					    END;
					 
					-- Cierra y libera cursor
					CLOSE cursor_PartidasSinPres;
					DEALLOCATE cursor_PartidasSinPres;
					
					--PRINT '1'
					--PRINT @@v_ErrorPartidas
	
					IF @message <> ''
						BEGIN
							SET @message = '¡Las siguientes partidas no tienen presupuesto autorizado suficiente: ' + @message
							SELECT JSON_QUERY( 
									CONCAT( '{', '"tipo":"', 'ERROR', 
												   '",', '"mensaje":"', @message, 
												   '",', '"liga":"', '', '"', '}' ) 
								) 
							AS ResultJson 
							RETURN;
						END
				END

			---- INICIA CRECIÓN DE POLIZA GENERAL PARA TODOS LOS MOMENTOS CONTABLES ------------
			--Variables para la poliza
					
			DECLARE
				@Poliza_Nueva INT,
				--@message NVARCHAR(Max),
				@SinConsulta Bit = 1,  -- Los SPs relacionados no regresan mensaje de respuesta
				@v_FK_IdAnio__SIS INT = @intEjercicio,
				@v_FK_IdMes__SIS INT =  @mes,  
				@v_FK_IdTipoPoliza__SIS INT = 1,
				@v_NombrePoliza VARCHAR(1000) = CONCAT_WS(' ', 'Nomina-', CAST(@intEjercicio as varchar(4)), '-Q ', CAST(@intQuincena as varchar(2)), '-N', CAST(@intIdTipoNomina as varchar(2)) ),
				
				@v_FechaPoliza DATETIME = @Fecha,
				@v_Error NVARCHAR(Max);

			EXEC CONTA.SP_CREATE_Poliza
				@v_FK_IdAnio__SIS, @v_FK_IdMes__SIS, @v_FK_IdTipoPoliza__SIS,
				@v_NombrePoliza, @v_FechaPoliza, '',
				1, @Poliza_Nueva output, @v_Error output, @SinConsulta;
			
			IF @Poliza_Nueva IS NULL		
			BEGIN
				SET @message = '¡No se pudo generar la poliza !'
				SELECT JSON_QUERY(CONCAT( '{', '"tipo":"', 'ERROR', 
										'",', '"mensaje":"', @message, 
										'",', '"liga":"', '', '"', '}' )) AS ResultJson 
				RETURN;
			END
			---- TERMINA CRECIÓN DE POLIZA GENERAL PARA TODOS LOS MOMENTOS NOMIBLES ----------

			--******************************************************
			-- Se agrega la requisición
			--******************************************************
			
			INSERT INTO [ORCO].[Requisicion]
			       ([FK_IdPersona__RHCT]
				   , [FK_IdArea__SIS]
				   , [Descripcion]
				   , [Observaciones]
				   , [FechaRequisicion]
				   , [Service]
				   , [CT_CreatedBy]
				   , [CT_CreatedDate]
				   , [CT_LIVE]
				   , [Importe]
				   , [FK_IdFuenteFinanciamiento__PRES]
				   , [FK_IdPrograma__PRES]
				   , [FK_IdPartida__SIS]
				   , [FK_IdAnio__SIS]
				   , [Fk_IdEgresoAutorizado]
				   , [Oficio])
				 
			(Select 0 as FK_IdPersona__RHCT
					, CAST(DN.strUnidadAdm AS Int) AS FK_IdArea__SIS
					, 'NOM-' + CAST(DN.intEjercicio as varchar(4)) + '-Q' + CAST(DN.intQuincena as varchar(2))+ '-N' + CAST(DN.intIdTipoNomina as varchar(2)) as Descripcion
					, LEFT(DN.ConceptoArea,99) as Observaciones
					, @Fecha as FechaRequisicion
					, 0 AS Service
					, 1 AS CT_CreatedBy
					, GETDATE() AS CT_CreatedDate
					, 1 as CT_LIVE
					, DN.Importe as Importe
					, 1 as FK_IdFuenteFinanciamiento__PRES
					, DN.Fk_IdPrograma__PRES
					, DN.intPartida
					, DN.intEjercicio as FK_IdAnio__SIS
					, DN.Fk_IdEgresoAutorizado
					, 'Nomina'
			FROM [NOMI].[VW_DevengaNomina] DN
										WHERE DN.intEjercicio = @intEjercicio
										AND DN.intQuincena = @intQuincena
										AND DN.intIdTipoNomina = @intIdTipoNomina	
										AND DN.EstaProcesado = 0)  -- No esta procesado

			--******************************************************
			----- INICIA INSERT DE SOLICITUD DE SUFICIENCIA ---------------
			--******************************************************
			
			INSERT INTO PRES.SolicitudSuficiencia(
				Fecha, Justificacion, FK_IdPoliza, FK_IdRequisicion__ORCO, 
				GastoNoProg, IdGastoNP, IdCompNomina,
				Ene, Feb, Mar, Abr, May, Jun, Jul, Ago, Sep, Oct, Nov, Dic, 
				CT_CreatedBy, CT_CreatedDate,CT_LIVE)
			(SELECT
				@Fecha
				, NR.Observaciones
				, @Poliza_Nueva
				, NR.PK_IdRequisicion
				, 'NOM' AS GastoNoProg
				, @intQuincena AS IdGastoNP
				, @intEjercicio * 1000 + @intQuincena * 10 + @intIdTipoNomina AS IdCompNomina
				, CASE WHEN @Mes = 1  THEN NR.Importe ELSE 0  END AS Ene
				, CASE WHEN @Mes = 2  THEN NR.Importe ELSE 0  END AS Feb
				, CASE WHEN @Mes = 3  THEN NR.Importe ELSE 0  END AS Mar
				, CASE WHEN @Mes = 4  THEN NR.Importe ELSE 0  END AS Abr
				, CASE WHEN @Mes = 5  THEN NR.Importe ELSE 0  END AS May
				, CASE WHEN @Mes = 6  THEN NR.Importe ELSE 0  END AS Jun
				, CASE WHEN @Mes = 7  THEN NR.Importe ELSE 0  END AS Jul
				, CASE WHEN @Mes = 8  THEN NR.Importe ELSE 0  END AS Ago
				, CASE WHEN @Mes = 9  THEN NR.Importe ELSE 0  END AS Sep
				, CASE WHEN @Mes = 10 THEN NR.Importe ELSE 0  END AS Oct
				, CASE WHEN @Mes = 11 THEN NR.Importe ELSE 0  END AS Nov
				, CASE WHEN @Mes = 12 THEN NR.Importe ELSE 0  END AS Dic
				, 1
				, GETDATE()
				, 1
			FROM ORCO.VW_Requisicion_NOM  NR
			WHERE Descripcion =  'NOM-' + CAST(@intEjercicio as varchar(4)) + '-Q' + CAST(@intQuincena as varchar(2)) + '-N' + CAST(@intIdTipoNomina as varchar(2))
			)
			----- TERMINA INSERT DE SOLICITUD DE SUFICIENCIA ---------------

			--******************************************************					   
			----- INICIA INSERT AUTORIZACION SUFICIENCIA -------------------
			--******************************************************
			
			INSERT INTO PRES.AutorizacionSuficiencia(
				Fk_IdSolicitudSuficiencia, Fecha, Justificacion, FK_IdPoliza, GastoNoProg, IdGastoNP, IdCompNomina,
				Ene, Feb, Mar, Abr, May, Jun, Jul, Ago, Sep, Oct, Nov, Dic,
				CT_CreatedBy, CT_CreatedDate, CT_LIVE)
			(SELECT
				Pk_IdSolicitudSuficiencia, Fecha, CONCAT_WS(' ', 'Nomina de ', Justificacion  ), 0, GastoNoProg, IdGastoNP, IdCompNomina,
				Ene, Feb, Mar, Abr, May, Jun, Jul, Ago, Sep, Oct, Nov, Dic,
				CT_CreatedBy, CT_CreatedDate, CT_LIVE
			FROM PRES.SolicitudSuficiencia PSS 
			WHERE IdCompNomina =  @intEjercicio * 1000 + @intQuincena * 10 + @intIdTipoNomina)
			----- TERMINA INSERT AUTORIZACION SUFICIENCIA -------------------
			
			--******************************************************
			----- INICIA INSERT CONTRATO Y DETALLE DE POLIZA CORRESPONDIENTE AL CONTRATO -------------
			--******************************************************
			
			INSERT INTO PRES.Contrato(
				Fk_IdAutorizacionSuficiencia, Descripcion, Fecha, Fk_IdPoliza,  GastoNoProg, IdGastoNP,  IdCompNomina,
				Ene, Feb, Mar, Abr, May, Jun, Jul, Ago, Sep, Oct, Nov, Dic,
				CT_CreatedBy, CT_CreatedDate)
			(SELECT
				Pk_IdAutorizacionSuficiencia, Justificacion, Fecha, @Poliza_Nueva, GastoNoProg, IdGastoNP, IdCompNomina,
				Ene, Feb, Mar, Abr, May, Jun, Jul, Ago, Sep, Oct, Nov, Dic,
				PAS.CT_CreatedBy, PAS.CT_CreatedDate 
			FROM PRES.AutorizacionSuficiencia PAS
			WHERE IdCompNomina =  @intEjercicio * 1000 + @intQuincena * 10 + @intIdTipoNomina);
					
			------ Cargos de Presupuesto Comprometido ----
			INSERT INTO [CONTA].[DetallePoliza]
			       ([FK_IdCuentaContable__SIS]
			       ,[FK_IdPoliza__CONTA]
			       ,[Descripcion]
			       ,[ImporteDebe]
			       ,[ImporteHaber]
			       ,[Fk_IdReferencia]
			       ,[Fk_IdTipoDetallePoliza]
			       ,[CT_CreatedBy]
			       ,[CT_CreatedDate]
			       ,[CT_LIVE])
			(SELECT MC.FK_IdCuentaContableComprometido
				, @Poliza_Nueva
				, CONCAT('Presupuesto Comprometido ',  PC.Descripcion)
				, Req.Importe
				, 0
				, Req.PK_IdRequisicion
				, 1
				, 1 --CT_CreatedBy
				, GETDATE() -- CT_CreatedDate
				, 1 -- CT_LIVE
			FROM PRES.Contrato PC 
				JOIN PRES.AutorizacionSuficiencia AuSuf ON PC.Fk_IdAutorizacionSuficiencia = AuSuf.Pk_IdAutorizacionSuficiencia
				JOIN PRES.SolicitudSuficiencia SS ON AuSuf.Fk_IdSolicitudSuficiencia =SS.Pk_IdSolicitudSuficiencia
				JOIN ORCO.Requisicion Req ON SS.FK_IdRequisicion__ORCO = Req.PK_IdRequisicion
				JOIN CONTA.MatrizConversion MC ON Req.FK_IdAnio__SIS = MC.FK_IdAnio__SIS 
												AND Req.FK_IdPrograma__PRES = MC.FK_IdPrograma__PRES 
												AND Req.FK_IdPartida__SIS = MC.FK_IdPartida__SIS
			WHERE PC.IdCompNomina =  @intEjercicio * 1000 + @intQuincena * 10 + @intIdTipoNomina)

			------ Abonos de Presupuesto Comprometido ----
			INSERT INTO [CONTA].[DetallePoliza]
			       ([FK_IdCuentaContable__SIS]
			       ,[FK_IdPoliza__CONTA]
			       ,[Descripcion]
			       ,[ImporteDebe]
			       ,[ImporteHaber]
			       ,[Fk_IdReferencia]
			       ,[Fk_IdTipoDetallePoliza]
			       ,[CT_CreatedBy]
			       ,[CT_CreatedDate]
			       ,[CT_LIVE])
			(SELECT MC.FK_IdCuentaContablePorEjercer
				, @Poliza_Nueva
				, CONCAT('Presupuesto por ejercer ',  PC.Descripcion)
				, 0		
				, Req.Importe
				, Req.PK_IdRequisicion
				, 2
				, 1 --CT_CreatedBy
				, GETDATE() -- CT_CreatedDate
				, 1 -- CT_LIVE
			FROM PRES.Contrato PC 
				JOIN PRES.AutorizacionSuficiencia AuSuf ON PC.Fk_IdAutorizacionSuficiencia = AuSuf.Pk_IdAutorizacionSuficiencia
				JOIN PRES.SolicitudSuficiencia SS ON AuSuf.Fk_IdSolicitudSuficiencia =SS.Pk_IdSolicitudSuficiencia
				JOIN ORCO.Requisicion Req ON SS.FK_IdRequisicion__ORCO = Req.PK_IdRequisicion
				JOIN CONTA.MatrizConversion MC ON Req.FK_IdAnio__SIS = MC.FK_IdAnio__SIS 
												AND Req.FK_IdPrograma__PRES = MC.FK_IdPrograma__PRES 
												AND Req.FK_IdPartida__SIS = MC.FK_IdPartida__SIS
			WHERE PC.IdCompNomina =  @intEjercicio * 1000 + @intQuincena * 10 + @intIdTipoNomina)

			----- TERMINA INSERT CONTRATO Y DETALLE DE POLIZA CORRESPONDIENTE AL CONTRATO -------------
		
			--******************************************************			
			----- INICIA INSERT FACTURA Y DETALLE DE POLIZA CORRESPONDIENTE A LA FACTURA) -------------
			--******************************************************
			
			INSERT INTO PRES.Factura(
				Fk_IdContrato, NumFactura, Importe, Fecha, Fk_IdPoliza, GastoNoProg, IdGastoNP, IdNomina,
				Ene, Feb, Mar, Abr, May, Jun, Jul, Ago, Sep, Oct, Nov, Dic, CT_CreatedBy, CT_CreatedDate, CT_LIVE)
			SELECT
				Pk_IdContrato, 'SF NOM-'+ CAST(@intEjercicio as varchar(4)) + '-Q' + CAST(@intQuincena as varchar(2)), 0, Fecha, @Poliza_Nueva, GastoNoProg, IdGastoNP, IdCompNomina,
				Ene, Feb, Mar, Abr, May, Jun, Jul, Ago, Sep, Oct, Nov, Dic, pc.CT_CreatedBy, pc.CT_CreatedDate, pc.CT_LIVE 
			FROM PRES.Contrato pc 
			WHERE pc.IdCompNomina =  @intEjercicio * 1000 + @intQuincena * 10 + @intIdTipoNomina


			------ Cargos de Presupuesto Devengado ----
			INSERT INTO [CONTA].[DetallePoliza]
			       ([FK_IdCuentaContable__SIS]
			       ,[FK_IdPoliza__CONTA]
			       ,[Descripcion]
			       ,[ImporteDebe]
			       ,[ImporteHaber]
			       ,[Fk_IdReferencia]
			       ,[Fk_IdTipoDetallePoliza]
			       ,[CT_CreatedBy]
			       ,[CT_CreatedDate]
			       ,[CT_LIVE])
			(SELECT MC.FK_IdCuentaContableDevengado
				, @Poliza_Nueva
				, CONCAT('Presupuesto Devengado ',  PC.Descripcion)
				, Fac.Total
				, 0
				, Fac.Pk_IdFactura
				, 3
				, 1 --CT_CreatedBy
				, GETDATE() -- CT_CreatedDate
				, 1 -- CT_LIVE
			FROM PRES.Factura Fac
				JOIN PRES.Contrato PC ON Fac.Fk_IdContrato = Pc.Pk_IdContrato
				JOIN PRES.AutorizacionSuficiencia AuSuf ON PC.Fk_IdAutorizacionSuficiencia = AuSuf.Pk_IdAutorizacionSuficiencia
				JOIN PRES.SolicitudSuficiencia SS ON AuSuf.Fk_IdSolicitudSuficiencia =SS.Pk_IdSolicitudSuficiencia
				JOIN ORCO.Requisicion Req ON SS.FK_IdRequisicion__ORCO = Req.PK_IdRequisicion
				JOIN CONTA.MatrizConversion MC ON Req.FK_IdAnio__SIS = MC.FK_IdAnio__SIS 
												AND Req.FK_IdPrograma__PRES = MC.FK_IdPrograma__PRES 
												AND Req.FK_IdPartida__SIS = MC.FK_IdPartida__SIS
			WHERE Fac.IdNomina =  @intEjercicio * 1000 + @intQuincena * 10 + @intIdTipoNomina)

			------ Abonos de Presupuesto Devengado ----
			INSERT INTO [CONTA].[DetallePoliza]
			       ([FK_IdCuentaContable__SIS]
			       ,[FK_IdPoliza__CONTA]
			       ,[Descripcion]
			       ,[ImporteDebe]
			       ,[ImporteHaber]
			       ,[Fk_IdReferencia]
			       ,[Fk_IdTipoDetallePoliza]
			       ,[CT_CreatedBy]
			       ,[CT_CreatedDate]
			       ,[CT_LIVE])
			(SELECT MC.FK_IdCuentaContableComprometido
				, @Poliza_Nueva
				, CONCAT('Presupuesto Comprometido ',  PC.Descripcion)
				, 0		
				, Fac.Total
				, Fac.Pk_IdFactura
				, 4
				, 1 --CT_CreatedBy
				, GETDATE() -- CT_CreatedDate
				, 1 -- CT_LIVE
			FROM PRES.Factura Fac
				JOIN PRES.Contrato PC ON Fac.Fk_IdContrato = Pc.Pk_IdContrato
				JOIN PRES.AutorizacionSuficiencia AuSuf ON PC.Fk_IdAutorizacionSuficiencia = AuSuf.Pk_IdAutorizacionSuficiencia
				JOIN PRES.SolicitudSuficiencia SS ON AuSuf.Fk_IdSolicitudSuficiencia =SS.Pk_IdSolicitudSuficiencia
				JOIN ORCO.Requisicion Req ON SS.FK_IdRequisicion__ORCO = Req.PK_IdRequisicion
				JOIN CONTA.MatrizConversion MC ON Req.FK_IdAnio__SIS = MC.FK_IdAnio__SIS 
												AND Req.FK_IdPrograma__PRES = MC.FK_IdPrograma__PRES 
												AND Req.FK_IdPartida__SIS = MC.FK_IdPartida__SIS
			WHERE Fac.IdNomina =  @intEjercicio * 1000 + @intQuincena * 10 + @intIdTipoNomina)

			----- TERMINA INSERT FACTURA Y DETALLE DE POLIZA CORRESPONDIENTE A LA FACTURA) -------------
			
			--******************************************************			
			----- INICIA INSERT CLC Y DETALLE DE POLIZA CORRESPONDIENTE A LA CLC) -------------
			--******************************************************
			DECLARE @c_IdCLC nChar(20) = (SELECT NumReferenciaDocto FROM PRES.CLCFactura WHERE Pk_IdCLCFactura = @ClcIngresos) ;

			--PRINT @c_IdCLC

			INSERT INTO PRES.CLC(
				Fk_IdFactura, NumCLC, Importe, Comentarios, Fecha, Fk_IdPoliza, GastoNoProg, IdGastoNP, idNomina,
				CT_CreatedBy,CT_CreatedDate,CT_LIVE,
				Ene, Feb, Mar, Abr, May, Jun, Jul, Ago, Sep, Oct, Nov, Dic, FK_IdCLCFactura__PRES) 
			(SELECT
				Pk_IdFactura, @c_IdCLC, Total, NumFactura, Fecha, @Poliza_Nueva, GastoNoProg, IdGastoNP, IdNomina,
				CT_CreatedBy,CT_CreatedDate,CT_LIVE,
				Ene, Feb, Mar, Abr, May, Jun, Jul, Ago, Sep, Oct, Nov, Dic, @ClcIngresos
			FROM PRES.Factura 
				WHERE IdNomina =  @intEjercicio * 1000 + @intQuincena * 10 + @intIdTipoNomina)
				
			------ Cargos de Presupuesto Ejercido ----
			INSERT INTO [CONTA].[DetallePoliza]
			       ([FK_IdCuentaContable__SIS]
			       ,[FK_IdPoliza__CONTA]
			       ,[Descripcion]
			       ,[ImporteDebe]
			       ,[ImporteHaber]
			       ,[Fk_IdReferencia]
			       ,[Fk_IdTipoDetallePoliza]
			       ,[CT_CreatedBy]
			       ,[CT_CreatedDate]
			       ,[CT_LIVE])
			(SELECT MC.FK_IdCuentaContableEjercido
				, @Poliza_Nueva
				, CONCAT('Presupuesto Ejercido ',  PC.Descripcion)
				, clc.Total
				, 0
				, clc.Pk_IdCLC
				, 5
				, 1 --CT_CreatedBy
				, GETDATE() -- CT_CreatedDate
				, 1 -- CT_LIVE
			FROM PRES.Clc clc 
				JOIN PRES.Factura Fac ON clc.Fk_IdFactura = Fac.Pk_IdFactura
				JOIN PRES.Contrato PC ON Fac.Fk_IdContrato = Pc.Pk_IdContrato
				JOIN PRES.AutorizacionSuficiencia AuSuf ON PC.Fk_IdAutorizacionSuficiencia = AuSuf.Pk_IdAutorizacionSuficiencia
				JOIN PRES.SolicitudSuficiencia SS ON AuSuf.Fk_IdSolicitudSuficiencia =SS.Pk_IdSolicitudSuficiencia
				JOIN ORCO.Requisicion Req ON SS.FK_IdRequisicion__ORCO = Req.PK_IdRequisicion
				JOIN CONTA.MatrizConversion MC ON Req.FK_IdAnio__SIS = MC.FK_IdAnio__SIS 
												AND Req.FK_IdPrograma__PRES = MC.FK_IdPrograma__PRES 
												AND Req.FK_IdPartida__SIS = MC.FK_IdPartida__SIS
			WHERE Clc.IdNomina =  @intEjercicio * 1000 + @intQuincena * 10 + @intIdTipoNomina)

			------ Abonos de Presupuesto Ejercido ----
			INSERT INTO [CONTA].[DetallePoliza]
			       ([FK_IdCuentaContable__SIS]
			       ,[FK_IdPoliza__CONTA]
			       ,[Descripcion]
			       ,[ImporteDebe]
			       ,[ImporteHaber]
			       ,[Fk_IdReferencia]
			       ,[Fk_IdTipoDetallePoliza]
			       ,[CT_CreatedBy]
			       ,[CT_CreatedDate]
			       ,[CT_LIVE])
			(SELECT MC.FK_IdCuentaContableDevengado
				, @Poliza_Nueva
				, CONCAT('Presupuesto Devengado ',  PC.Descripcion)
				, 0
				, clc.Total
				, clc.Pk_IdCLC
				, 6
				, 1 --CT_CreatedBy
				, GETDATE() -- CT_CreatedDate
				, 1 -- CT_LIVE
			FROM PRES.Clc clc 
				JOIN PRES.Factura Fac ON clc.Fk_IdFactura = Fac.Pk_IdFactura
				JOIN PRES.Contrato PC ON Fac.Fk_IdContrato = Pc.Pk_IdContrato
				JOIN PRES.AutorizacionSuficiencia AuSuf ON PC.Fk_IdAutorizacionSuficiencia = AuSuf.Pk_IdAutorizacionSuficiencia
				JOIN PRES.SolicitudSuficiencia SS ON AuSuf.Fk_IdSolicitudSuficiencia =SS.Pk_IdSolicitudSuficiencia
				JOIN ORCO.Requisicion Req ON SS.FK_IdRequisicion__ORCO = Req.PK_IdRequisicion
				JOIN CONTA.MatrizConversion MC ON Req.FK_IdAnio__SIS = MC.FK_IdAnio__SIS 
												AND Req.FK_IdPrograma__PRES = MC.FK_IdPrograma__PRES 
												AND Req.FK_IdPartida__SIS = MC.FK_IdPartida__SIS
			WHERE Clc.IdNomina =  @intEjercicio * 1000 + @intQuincena * 10 + @intIdTipoNomina)

		--	SELECT * FROM PRES.SolicitudSuficiencia WHERE IdCompNomina =  @intEjercicio * 10000 + @intQuincena * 100
		--  SELECT *  FROM PRES.AutorizacionSuficiencia WHERE IdCompNomina =  @intEjercicio * 10000 + @intQuincena * 100	
		--  SELECT *  FROM PRES.Contrato WHERE IdCompNomina =  @intEjercicio * 10000 + @intQuincena * 100
		--  SELECT *  FROM PRES.Factura WHERE IdNomina =  @intEjercicio * 10000 + @intQuincena * 100
		--  SELECT *  FROM PRES.CLC WHERE IdNomina =  @intEjercicio * 10000 + @intQuincena * 100
		--  SELECT * FROM NOMI.DetallePoliza WHERE FK_IdPoliza__NOMI = @Poliza_Nueva

	--*************************************************************
	--****** Termina Lógica de Devengado de Nónina
	--*************************************************************
	-- Actualiza los datos de origen a procesados
	UPDATE NOMI.DatosFinancieros 
	SET EstaProcesado = 1
	WHERE intEjercicio = @intEjercicio
	AND intQuincena = @intQuincena
	AND intIdTipoNomina = @intIdTipoNomina

	-- Se actualiza quincena
	UPDATE NOMI.QuincenaActual
	SET Actual = 0
	WHERE 
	Fk_IdAnio__SIS = @v_FK_IdAnioActual AND Fk_IdMes__SIS = @v_FK_IdMesActual And Quincena = @v_QuincenaActual
	;

	INSERT INTO NOMI.QuincenaActual
	(Fk_IdAnio__SIS, Fk_IdMes__SIS, Quincena, Actual, CT_CreatedBy, CT_CreatedDate, CT_LIVE)
	VALUES(@v_FK_IdAnioSiguiente, @v_FK_IdMesSiguiente, @v_QuincenaSiguiente, 1, 1, GETDATE(),  1);
	
	
		SET @message = 'Se comprometio, devengo y ejercio correctamente la quincena.' + CAST(@v_QuincenaActual AS VARCHAR) + ' ' + CAST(@v_FK_IdAnioActual AS VARCHAR) + ' Verifique Reporte'
				SELECT JSON_QUERY( 
						CONCAT( '{', '"tipo":"', 'OK', 
									   '",', '"mensaje":"', @message, 
									   '",', '"liga":"', 'mes', '"', '}' ) 
					) 
				AS ResultJson 
				RETURN;

		
END;
GO
