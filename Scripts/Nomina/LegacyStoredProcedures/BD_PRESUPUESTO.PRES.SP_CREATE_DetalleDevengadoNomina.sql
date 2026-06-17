-- Source: BD_PRESUPUESTO.[PRES].[SP_CREATE_DetalleDevengadoNomina]
-- Extracted for Nomina migration. Review schema/table mappings before applying to GestionEmpresarial.
GO
CREATE PROCEDURE [PRES].[SP_CREATE_DetalleDevengadoNomina]
--Parametros Iniciales
			--@IdFondoRevolvente int, --Identificador del Fondo Revolvente o Gasto a Comprobar
			--@IdDetEgreFondoRevolvente int,  --Este parametro solo es util en el caso de fondo revolvente, en cualquier otro debe ser CERO
            @Fk_IdEgresoAutorizado int  -- 
		    --,@Fk_IdEgreAut int --Aqui se define el mes y el importe disponible		   
		   ,@Importe float -- Importe del comprobante de gasto
           ,@Fecha date
           ,@Justificacion nvarchar(250)
           ,@FK_IdPoliza int
           ,@DescDetDev nvarchar(250)		
		  
		   ,@IdContrato int
		   ,@EgreComp int
		   ,@Id_Gasto int

		   ,@error varchar(500) OUTPUT
AS
BEGIN
  BEGIN TRY
			--SE Declaran las variables para obtener las cuentas contables de las polizas

			DECLARE
			@CuentaContableComprometido int
			,@CuentaContablePorEjercer int
			,@CuentaContableDevengado int
			,@CuentaContableEjercido int
			,@CuentaContablePagado int
			,@CuentaContableGasto int
			--Variables para identificar la matriz
			,@Fk_IdPrograma int
			,@Fk_IdPartida int
			,@Fk_IdAnio int
			,@Fk_IdMes int -- Aqui se define el mes en el que se esta gastando el dinero
			--,@Id_Gasto int -- Identificador del gasto
			--,@mtipo varchar(4) --Esta variable se usa para concatenarla en la descripción de los detalles de momentos contables
			,@Mensaje_Poliza varchar(200) --Concatena Detalle de Poliza

			--Variable para identificar al deudor y la cuenta de origen del recurso
			,@FK_IdCuentaCargo int   --Cuenta contable del deudor a del fondo revolvente o del Gasto a Comprobar
		    ,@FK_IdCuentaAbono int   --Cuenta de donde salieron los recursos del FR, GC o 
			
			, @Tipo nvarchar(2)

			SET @Tipo = 'NM'

			--Se determina el programa y la partida para poder determinar las cuentas contables en la matriz de conversion
			SELECT @Fk_IdPrograma = [Fk_IdPrograma], @Fk_IdPartida = Fk_IdPartida FROM [PRES].[EgresoAutorizado] WHERE [Pk_IdEgresoAutorizado] = @Fk_IdEgresoAutorizado
			--SET @Fk_IdPartida = (SELECT TOP 1 @Fk_IdPartida FROM [PRES].[EgresoAutorizado] WHERE [Pk_IdEgresoAutorizado] = @Fk_IdEgresoAutorizado)
			SET @Fk_IdAnio = (SELECT PK_IdAnio FROM [SIS].[Anio] WHERE Clave = YEAR(@Fecha))
			SET @Fk_IdMes = MONTH(@Fecha)

			SELECT @CuentaContablePorEjercer = [FK_IdCuentaContablePorEjercer]
			, @CuentaContableComprometido = [FK_IdCuentaContableComprometido]
			,@CuentaContableDevengado = [FK_IdCuentaContableDevengado]
			,@CuentaContableEjercido = [FK_IdCuentaContableEjercido]
			,@CuentaContablePagado = [FK_IdCuentaContablePagado]
			,@CuentaContableGasto = [FK_IdCuentaContableGasto]
			 FROM [CONTA].[MatrizConversion] WHERE  FK_IdAnio__SIS = @Fk_IdAnio AND [FK_IdPrograma__PRES] = @Fk_IdPrograma AND [FK_IdPartida__SIS] = @Fk_IdPartida



--************************************************************************
			-- Presupuesto devengado

			DECLARE 
			  @IdFactura int
			, @EgreDev int
			
			
			INSERT INTO [PRES].[Factura]
			           ([Fk_IdContrato]
			           ,[NumFactura]
			           ,[Importe]
			           ,[Fecha]
			           --,[FLDocto]
			           ,[FK_IdPoliza]					   
					   ,[GastoNoProg]
					   ,[IdGastoNP]
					   )
			     VALUES
			           (@IdContrato
			           ,@DescDetDev  -- Descripcion del detealle del devengado 
			           ,@Importe
			           ,@Fecha
			           --,<FLDocto, nvarchar(100),>
			           ,@FK_IdPoliza				   
					   ,@Tipo
					   ,@Id_Gasto
					   )
			
			SET @IdFactura = @@IDENTITY
			
			--Detalle de EgreDev
			
			INSERT INTO [PRES].[EgreDev]
			           ([Fk_IdEgreComp]
			           ,[Fk_IdFactura]
			           ,[Fk_IdMes]
			           ,[Importe]
			           ,[Descripcion]
			           ,[Fecha]
			           --,[FK_IdDetallePoliza]					   
					   ,[GastoNoProg]
					   ,[IdGastoNP]
					   )
			     VALUES
			           (@EgreComp
			           ,@IdFactura
			           ,@Fk_IdMes
			           ,@Importe
			           ,'Pago de NM: '+  @Justificacion --Descripcion detalle
			           ,@Fecha
			           --,1--<FK_IdDetallePoliza, int,>)					   			   
					   ,@Tipo
					   ,@Id_Gasto
					   )
			
					   SET @EgreDev = @@IDENTITY

			-- Se insertan los detalles de Cargo de la poliza 

			Set @Mensaje_Poliza =  'NM Presupuesto Devengado ' + @Justificacion --Descripcion del Movimiento

				EXEC [CONTA].[SP_CREATE_DetallePoliza]
					@FK_IdCuentaContable__SIS = @CuentaContableDevengado,
					@Descripcion =  @Mensaje_Poliza, 
					@ImporteDebe = @Importe,
					@ImporteHaber = 0,
					@FK_IdPoliza__CONTA = @FK_IdPoliza,
					@Fk_IdReferencia = @EgreDev, --El Id del Momento contable
					@Fk_IdTipoDetallePoliza = 4,
					@Error = @Error OUTPUT
			
			-- Se insertan los detalles de Abono de la poliza 
				EXEC [CONTA].[SP_CREATE_DetallePoliza]
					@FK_IdCuentaContable__SIS = @CuentaContableComprometido,
					@Descripcion =  @Mensaje_Poliza, 
					@ImporteDebe = 0,
					@ImporteHaber = @Importe,
					@FK_IdPoliza__CONTA = @FK_IdPoliza,
					@Fk_IdReferencia = @EgreDev, --El Id del Momento contable
					@Fk_IdTipoDetallePoliza = 3,
					@Error = @Error OUTPUT


END TRY
	BEGIN CATCH
		--Se maneja el error
		SET @error = ERROR_MESSAGE();
		RETURN
	END CATCH
END
GO
