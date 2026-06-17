-- Source: BD_PRESUPUESTO.[PRES].[SP_CREATE_DetalleComprometidoNomina]
-- Extracted for Nomina migration. Review schema/table mappings before applying to GestionEmpresarial.
GO
CREATE PROCEDURE [PRES].[SP_CREATE_DetalleComprometidoNomina]
--Parametros Iniciales

            @Fk_IdEgresoAutorizado int  -- 
		   ,@Fk_IdEgreAut int --Aqui se define el mes y el importe disponible		   
		   ,@Importe float -- Importe del comprobante de gasto
           ,@Fecha date
           ,@Justificacion nvarchar(250)
           ,@FK_IdPoliza int
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
			,@Mensaje_Poliza varchar(200) --Concatena Detalle de Poliza

			 ,@Tipo VarChar(2) = 'NM' --Tipeado NM es un compromiso de nómina			    

			, @IdCompNomina int  = @Id_Gasto --Este campo se agregó con posterioridad al Stored en Idgasto viene el identificador de todos los movimientos del comprometido 
											 --Posteriormente @idgasto se re utiliza para almacenar el identificador de la suficiencia presupuestal que servira como identifidador de los tres momentos 
											 --Contables.
			, @NombreMes nVarchar(10)
			

			--Se determina el programa y la partida para poder determinar las cuentas contables en la matriz de conversion
			SELECT @Fk_IdPrograma = [Fk_IdPrograma], @Fk_IdPartida = Fk_IdPartida FROM [PRES].[EgresoAutorizado] WHERE [Pk_IdEgresoAutorizado] = @Fk_IdEgresoAutorizado
			--SET @Fk_IdPartida = (SELECT TOP 1 @Fk_IdPartida FROM [PRES].[EgresoAutorizado] WHERE [Pk_IdEgresoAutorizado] = @Fk_IdEgresoAutorizado)
			SET @Fk_IdAnio = (SELECT PK_IdAnio FROM [SIS].[Anio] WHERE Clave = YEAR(@Fecha))
			SET @Fk_IdMes = MONTH(@Fecha)
			SET @NombreMes = (SELECT [Descripcion] FROM [SIS].[Mes]  WHERE PK_IdMes = @Fk_IdMes)
			SET @Justificacion = @Justificacion + ' ' + @NombreMes


			SELECT @CuentaContablePorEjercer = [FK_IdCuentaContablePorEjercer]
			, @CuentaContableComprometido = [FK_IdCuentaContableComprometido]
			,@CuentaContableDevengado = [FK_IdCuentaContableDevengado]
			,@CuentaContableEjercido = [FK_IdCuentaContableEjercido]
			,@CuentaContablePagado = [FK_IdCuentaContablePagado]
			,@CuentaContableGasto = [FK_IdCuentaContableGasto]
			 FROM [CONTA].[MatrizConversion] WHERE  FK_IdAnio__SIS = @Fk_IdAnio AND [FK_IdPrograma__PRES] = @Fk_IdPrograma AND [FK_IdPartida__SIS] = @Fk_IdPartida

			 SET @NombreMes = (SELECT [Descripcion] FROM [SIS].[Mes]  WHERE PK_IdMes = @Fk_IdMes)


		
			--************************************************************************
			--****   Aqui comienza a insertar los momentos contables    **************
			--************************************************************************
			
			-- Se crean las variables para identificar
			Declare 
			@IdSolicitudSuficiencia int,
			@IdEgreSolSuf int
			
			--************************************************************************
			--************* Inserta Solicitud de Suficiencia
			
			INSERT INTO [PRES].[SolicitudSuficiencia]
			           ([Fk_IdEgresoAutorizado]
			           ,[Fecha]
			           ,[Justificacion]
			           ,[FK_IdPoliza]
			           --,[FK_IdRequisicion__ORCO]
					   ,[GastoNoProg]
					   ,[IdGastoNP]
					   ,[IdCompNomina]
					   )
			     VALUES
			           (@Fk_IdEgresoAutorizado
					   ,@Fecha 
			           ,'NOM: Solicitud de Suficiencia ' + @Justificacion --Descripcion Maestro
			           ,@FK_IdPoliza 
			           --,@FK_IdRequisicion__ORCO 
					   ,@Tipo
					   ,0 --Se agrega id gasto = 0 en todos los demas momentos contables el idgasto estará referenciado a el pk_idSolicitud de suficiencia
					   ,@IdCompNomina
					   )
			
			SET @IdSolicitudSuficiencia = (SELECT @@IDENTITY)
			SET @Id_Gasto = @IdSolicitudSuficiencia   -- Se utiliza el Id de la solicitud de Suficiencia como identificador de los otros tres momentos


			--Se actualiza el IdGasto de la solicitud de suficiencia para que todos los registros de la transacción tengan el mismo idgasto

			UPDATE [PRES].[SolicitudSuficiencia] SET [IdGastoNP] = @Id_Gasto WHERE Pk_IdSolicitudSuficiencia = @IdSolicitudSuficiencia
			
			--Inserta detalle de la solicitud de suficiencia
			
			INSERT INTO [PRES].[EgreSolSuf]
			           ([Fk_IdEgreAut]
			           ,[Fk_IdSolicitudSuficiencia]
			           ,[Fk_IdMes]
			           ,[Importe]
			           ,[Descripcion]
			           ,[Fecha]
			           --,[FK_IdDetallePoliza]
					   ,[GastoNoProg]
					   ,[IdGastoNP]					   
					   ,[IdCompNomina]
					   )
			     VALUES
			           (@Fk_IdEgreAut
			           ,@IdSolicitudSuficiencia
			           ,@Fk_IdMes
			           ,@Importe
			           ,'Pago de Nomina: ' + @Justificacion --Descripcion detalle
			           ,@Fecha
			           --,1--<FK_IdDetallePoliza, int,>)
					   ,@Tipo
					   ,@Id_Gasto
					   ,@IdCompNomina
					   )
			
			SET @IdEgreSolSuf = @@IDENTITY
			--No requiere Poliza

			--************************************************************************
			-- ***********************  Inserta la autorización de Suficiencia

			DECLARE
			@IdAutorizacionSuficiencia int, 
			@EgreAutSuf int
			
			INSERT INTO [PRES].[AutorizacionSuficiencia]
			           ([Fk_IdSolicitudSuficiencia]
			           ,[Fecha]
			           ,[Justificacion]
			           ,[FK_IdPoliza]					   
					   ,[GastoNoProg]
					   ,[IdGastoNP]				   
					   ,[IdCompNomina]
					   )
			     VALUES
			           (@IdSolicitudSuficiencia
			           ,@Fecha
			           ,'NOM: Autorización de Suficiencia ' + @Justificacion --Descripcion Maestro
			           ,@FK_IdPoliza 
					   ,@Tipo
					   ,@Id_Gasto
					   ,@IdCompNomina
					   )
			
			SET @IdAutorizacionSuficiencia = @@IDENTITY
			
			--Inserta el detalle de la Autorización Presupuestal
			
			
			INSERT INTO [PRES].[EgreAutSuf]
			           ([Fk_IdEgreSolSuf]
			           ,[Fk_IdAutorizacionSuficiencia]
			           ,[Importe]
			           ,[Descripcion]
			           ,[Fecha]
			           ,[FK_IdDetallePoliza] 
					   ,[GastoNoProg]
					   ,[IdGastoNP]				   
					   ,[IdCompNomina]
					   )
			     VALUES
			           (@IdEgreSolSuf
			           ,@IdAutorizacionSuficiencia
			           ,@Importe
			           ,'Pago de Nomina: ' + @Justificacion --Descripcion detalle
			           ,@Fecha
			           ,1  --<FK_IdDetallePoliza, int,>)
					   ,@Tipo
					   ,@Id_Gasto
					   ,@IdCompNomina
					   )
			
			
			SET @EgreAutSuf = @@IDENTITY
			--No requiere poliza

			--************************************************************************
			-- ************ Presupuesto Comprometido

			DECLARE 
			  @IdContrato int
			, @EgreComp int
			
			INSERT INTO [PRES].[Contrato]
			           ([Fk_IdAutorizacionSuficiencia]
			          -- ,[Fk_IdDocumento]
			           ,[Descripcion]
			           ,[Fecha]
			           ,[FK_IdPoliza]
					   ,[GastoNoProg]
					   ,[IdGastoNP]				   
					   ,[IdCompNomina]
					   )
			     VALUES
			           (@IdAutorizacionSuficiencia
			          -- ,<Fk_IdDocumento, int,>
			           ,'NOM: Presupuesto Comprometido ' + @Justificacion --Descripcion Maestro
			           ,@Fecha
			           ,@FK_IdPoliza
					   ,@Tipo
					   ,@Id_Gasto
					   ,@IdCompNomina
					   )
			
			SET @IdContrato = @@IDENTITY
			
			
			--Comprometido Detalle
			
			INSERT INTO [PRES].[EgreComp]
			           ([Fk_IdEgreAutSuf]
			           ,[Fk_IdContrato]
			           ,[Fk_IdMes]
			           ,[Importe]
			           ,[Descripcion]
			           ,[Fecha]
			           --,[FK_IdDetallePoliza]					   
					   ,[GastoNoProg]
					   ,[IdGastoNP]				   
					   ,[IdCompNomina]
					   )
			     VALUES
			           (@EgreAutSuf
			           ,@IdContrato
			           ,@Fk_IdMes
			           ,@Importe
			           ,'Pago de Nomina '+  @Justificacion --Descripcion detalle
			           ,@Fecha
			           --,1--<FK_IdDetallePoliza, int,>)					   
					   ,@Tipo
					   ,@Id_Gasto
					   ,@IdCompNomina
					   )
			SET @EgreComp = @@IDENTITY
			
			-- Se insertan los detalles de Cargo de la poliza 

			Set @Mensaje_Poliza = 'NOM: Presupuesto Comprometido ' + @Justificacion --Descripcion del Movimiento

				EXEC [CONTA].[SP_CREATE_DetallePoliza]
					@FK_IdCuentaContable__SIS = @CuentaContableComprometido,
					@Descripcion =  @Mensaje_Poliza, 
					@ImporteDebe = @Importe,
					@ImporteHaber = 0,
					@FK_IdPoliza__CONTA = @FK_IdPoliza,
					@Fk_IdReferencia = @EgreComp, --El Id del Momento contable
					@Fk_IdTipoDetallePoliza = 1,
					@Error = @Error OUTPUT
			
			-- Se insertan los detalles de Abono de la poliza 
				EXEC [CONTA].[SP_CREATE_DetallePoliza]
					@FK_IdCuentaContable__SIS = @CuentaContablePorEjercer,
					@Descripcion =  @Mensaje_Poliza, 
					@ImporteDebe = 0,
					@ImporteHaber = @Importe,
					@FK_IdPoliza__CONTA = @FK_IdPoliza,
					@Fk_IdReferencia = @EgreComp, --El Id del Momento contable
					@Fk_IdTipoDetallePoliza = 2,
					@Error = @Error OUTPUT

	

			
			
			
			
	END TRY
	BEGIN CATCH
		--Se maneja el error
		SET @error = ERROR_MESSAGE();
		RETURN
	END CATCH
END
GO
