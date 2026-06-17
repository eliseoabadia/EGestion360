-- Source: BD_PRESUPUESTO.[PRES].[SP_CREATE_EgresoEjercido]
-- Extracted for Nomina migration. Review schema/table mappings before applying to GestionEmpresarial.
GO
CREATE           PROCEDURE [PRES].[SP_CREATE_EgresoEjercido]
    @p_Fk_IdFactura__PRES INT, 
    @p_NumCLC CHAR(20), 
    @p_Importe DECIMAL(18,2), 
    @p_Comentarios VARCHAR(250), 
    @p_Fecha DATE, 
    @p_Fk_IdPoliza__CONTA INT, 
    @p_FK_IdCuentaAbono INT, 
    @p_FK_IdCuentaCargo INT, 
    @p_GastoNoProg VARCHAR(3), 
    @p_IdGastoNP INT, 
    @p_Ene DECIMAL(18,2), 
    @p_Feb DECIMAL(18,2), 
    @p_Mar DECIMAL(18,2), 
    @p_Abr DECIMAL(18,2), 
    @p_May DECIMAL(18,2), 
    @p_Jun DECIMAL(18,2), 
    @p_Jul DECIMAL(18,2), 
    @p_Ago DECIMAL(18,2), 
    @p_Sep DECIMAL(18,2), 
    @p_Oct DECIMAL(18,2), 
    @p_Nov DECIMAL(18,2), 
    @p_Dic DECIMAL(18,2),
	@p_FK_IdCLCFactura__PRES int,
	@p_FK_IdCLCContenedorFactura__PRES int,
	@p_FK_IdCLCContenedorMultiFactura__PRES int,
    @CT_CreatedBy int
AS
BEGIN
SET NOCOUNT ON;
	 
	declare @v_IdCLC int;

	declare @v_Error varchar(max);

	DECLARE @tipo NVARCHAR(100)
	DECLARE @message NVARCHAR(MAX)

	declare @v_FK_IdAnio__SIS int;
	declare @v_FK_IdMes__SIS int;
	declare @v_FK_IdTipoPoliza__SIS int;
	declare @v_NombrePoliza varchar(1000);
	declare @v_FechaPoliza datetime2(6);
	declare @v_FL_FOTO varchar(1000);

	declare @v_anio int;
	declare @v_CuentaContableEjercido int;
	declare @v_CuentaContableDevengado int;
	declare @v_Importe decimal(18,2);
	declare @v_Fk_IdPartida__SIS int;
	declare @v_Fk_IdPrograma__PRES int;
	
	DECLARE @Poliza_Nueva Int = @p_Fk_IdPoliza__CONTA;	
	--DECLARE @message NVARCHAR(Max)
	DECLARE @SinConsulta Bit = 1;  -- Los SPs relacionados no regresan mensaje de respuesta
	DECLARE @MensajeNotificacion NVARCHAR(MAX);
	DECLARE @idMenu int = 96
	
	
	SET @v_anio = YEAR(@p_Fecha);
 SELECT @v_FK_IdAnio__SIS = sa.Pk_IdAnio  FROM SIS.Anio sa  WHERE sa.Clave  = @v_anio AND CT_LIVE = 1;
	SET @v_FK_IdMes__SIS = MONTH(@p_Fecha);
	SET @v_FK_IdTipoPoliza__SIS = 4; 
	SET @v_NombrePoliza = 'Presupuesto de Egresos Ejercido:' + CAST(@v_anio AS char ) + @p_Comentarios;
	SET @v_FechaPoliza = @p_Fecha;
	SET @v_FL_FOTO = '';

	IF EXISTS(SELECT 1 FROM PRES.CLC WHERE Fk_IdFactura = @p_Fk_IdFactura__PRES AND CT_LIVE = 1)
	BEGIN
		SET @message = '¡Ya existe la Provisión del Pago dada de alta!'
		SELECT JSON_QUERY( 
				CONCAT( '{', '"tipo":"', 'ERROR', 
								'",', '"mensaje":"', @message, 
								'",', '"liga":"', '', '"', '}' ) 
			) 
		AS ResultJson 
		RETURN;
	END
	
	Select @v_Fk_IdPrograma__PRES = pea.Fk_IdPrograma, @v_Fk_IdPartida__SIS = pea.Fk_IdPartida
	from PRES.VW_Factura pvf 
	join PRES.VW_Contrato pvc on pvf.Fk_IdContrato = pvc.Pk_IdContrato 
	Join PRES.VW_AutorizacionSuficiencia pvas on pvc.Fk_IdAutorizacionSuficiencia = pvas.Pk_IdAutorizacionSuficiencia 
	Join PRES.VW_SolicitudSuficiencia pvss  on pvas.Fk_IdSolicitudSuficiencia__PRES = pvss.Pk_IdSolicitudSuficiencia 
	join orco.Requisicion req (NOLOCK) on pvss.FK_IdRequisicion__ORCO = req.PK_IdRequisicion
	Join PRES.EgresoAutorizado pea (NOLOCK) on req.Fk_IdEgresoAutorizado = pea.Pk_IdEgresoAutorizado 
	WHERE pvf.Pk_IdFactura  = @p_Fk_IdFactura__PRES AND req.CT_LIVE = 1 AND pea.CT_LIVE = 1;

    SELECT 
        @v_CuentaContableEjercido = cmc.FK_IdCuentaContableEjercido, @v_CuentaContableDevengado = cmc.FK_IdCuentaContableDevengado 
    FROM CONTA.MatrizConversion cmc 
    WHERE cmc.Fk_IdAnio__SIS = @v_FK_IdAnio__SIS 
        AND cmc.Fk_IdPrograma__PRES = @v_Fk_IdPrograma__PRES 
        AND cmc.Fk_IdPartida__SIS = @v_Fk_IdPartida__SIS
		AND cmc.CT_LIVE = 1;
	
    IF @v_CuentaContableEjercido IS NULL OR @v_CuentaContableDevengado IS NULL 
		BEGIN
			SET @message = '¡En la matriz de conversión !'
			SELECT JSON_QUERY( 
					CONCAT( '{', '"tipo":"', 'ERROR', 
								   '",', '"mensaje":"', @message, 
								   '",', '"liga":"', '', '"', '}' ) 
				) 
			AS ResultJson 
			RETURN;
		END

	
	IF @p_Fk_IdPoliza__CONTA = 0 or ISNULL((SELECT TOP 1 [ClavePoliza] FROM CONTA.POLIZA WHERE [PK_IdPoliza]=@p_Fk_IdPoliza__CONTA ),'')='NUEVA'
			BEGIN		
			
				EXEC CONTA.SP_CREATE_Poliza @v_FK_IdAnio__SIS, @v_FK_IdMes__SIS, @v_FK_IdTipoPoliza__SIS, @v_NombrePoliza, @v_FechaPoliza, @v_FL_FOTO, @CT_CreatedBy, @Poliza_Nueva output, @v_Error output, @SinConsulta; 
				
				IF @p_Fk_IdPoliza__CONTA = @Poliza_Nueva 
					BEGIN
						SET @message = '¡No se pudo generar la poliza !'
						SELECT JSON_QUERY( 
								CONCAT( '{', '"tipo":"', 'ERROR', 
											   '",', '"mensaje":"', @message, 
											   '",', '"liga":"', '', '"', '}' ) 
							) 
						AS ResultJson 
						RETURN;
					END
			END 



    INSERT INTO PRES.CLC
    (Fk_IdFactura
        , NumCLC
        , Importe
        , Comentarios
        , Fecha
        , Fk_IdPoliza
        , FK_IdCuentaAbono
        , FK_IdCuentaCargo
        , GastoNoProg
        , IdGastoNP
        , Ene
        , Feb
        , Mar
        , Abr
        , May
        , Jun
        , Jul
        , Ago
        , Sep
        , Oct
        , Nov
        , Dic
		, FK_IdCLCFactura__PRES
		, FK_ContenedorCLCFide__PRES
		, FK_ContenedorMultiCLC__PRES
        , CT_CreatedBy
        , CT_CreatedDate
        ) 
        VALUES(
        @p_Fk_IdFactura__PRES
        , @p_NumCLC
        , @p_Importe
        , @p_Comentarios
        , @p_Fecha
        , @Poliza_Nueva
        , @p_FK_IdCuentaAbono
        , @p_FK_IdCuentaCargo
        , @p_GastoNoProg
        , @p_IdGastoNP
        , @p_Ene
        , @p_Feb
        , @p_Mar
        , @p_Abr
        , @p_May
        , @p_Jun
        , @p_Jul
        , @p_Ago
        , @p_Sep
        , @p_Oct
        , @p_Nov
        , @p_Dic
		, @p_FK_IdCLCFactura__PRES
		, @p_FK_IdCLCContenedorFactura__PRES
		, @p_FK_IdCLCContenedorMultiFactura__PRES
        , @CT_CreatedBy
        , GETDATE()
        );

	SET @v_IdCLC = @@IDENTITY;
	
	SET @Message = CONCAT('Se ha creado la Provisión del Pago PEF: ',@v_IdCLC)

		EXEC [SIS].[SP_MantenimientoNotificacion] @Action = 1, @Fk_IdUsuarioOrigen = @CT_CreatedBy, @Fk_IdMenu = @idMenu, @Fk_IdAccionSuscrita = 1, @Mensaje = @MensajeNotificacion, @IdUser = @CT_CreatedBy, @Controlador = null,
		@Pk_IdNotificacion = null, @Fk_IdNotificacionPadre = null, @Fk_IdUnidades = null, @Fk_IdEstadoNotificacion = null, @Fk_IdCliente = null, @Fk_IdEmpresa = null,
		@Importe = null,@IdRegistro = @v_IdCLC, @FechaCreacion = null, @FechaRecibido = null,@IntervaloNormal = null,@IntervaloAlerta = null, 
		@IntervaloCritico = null, @Fk_IdUsuarioDestino = null
	
	SET @v_importe =  ISNULL(@p_Ene,0) + ISNULL(@p_Feb,0) + ISNULL(@p_Mar,0) + ISNULL(@p_Abr,0) + ISNULL(@p_May,0) + ISNULL(@p_Jun,0) + ISNULL(@p_Jul,0) + ISNULL(@p_Ago,0) + ISNULL(@p_Sep,0) + ISNULL(@p_Oct,0) + ISNULL(@p_Nov,0) + ISNULL(@p_Dic,0);


    EXEC CONTA.SP_CREATE_DetallePoliza @v_CuentaContableEjercido, @Poliza_Nueva, @v_NombrePoliza, @v_Importe, 0, @v_IdCLC, 1, @CT_CreatedBy, @v_Error output, @SinConsulta;
    EXEC CONTA.SP_CREATE_DetallePoliza @v_CuentaContableDevengado, @Poliza_Nueva, @v_NombrePoliza, 0, @v_Importe, @v_IdCLC, 2, @CT_CreatedBy, @v_Error output, @SinConsulta;

	EXEC CONTA.SP_UPDATE_PolizaBalanceada @Poliza_Nueva, @CT_CreatedBy, @v_Error output;
   	
		--SELECT JSON_QUERY( 
		--		CONCAT( '{', '"tipo":"', 'OK', 
		--				   '",', '"mensaje":"', CONCAT('Se registró correctamente el presupuesto ejercido '
		--					, 'Presupuesto afectado ', @v_Importe, ' Verifique Poliza'), 
		--					   '",', '"liga":"idPoliza: ', @Poliza_Nueva, '"', '}' ) 
		--		) 
		--	AS ResultJson

		SELECT @tipo =  CONCAT('{', '"tipo":"', 'OK', '(',@v_IdCLC,')')
				,@message = CONCAT('¡Se Generó la Provisión del Pago Correctamente!','<BR> Presupuesto afectado: ',FORMAT(@v_Importe, 'C', 'es-MX'),'<BR>Para consultar la información, ir al menú : Provisión del Pago')
    
		SELECT JSON_QUERY( 
						CONCAT( @tipo,   '",', '"mensaje":"', @message, 
									   '",', '"liga":": ', @Poliza_Nueva, '"', '}' ) 
					) 
				AS ResultJson
	
	END;
GO
