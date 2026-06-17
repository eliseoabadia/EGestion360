-- Source: BD_ExuxFinanzas.[nom].[SPR_NominaActual]
-- Extracted for Nomina migration. Review schema/table mappings before applying to GestionEmpresarial.
GO
CREATE   PROCEDURE [nom].[SPR_NominaActual]
(
   @IdPeriodoActivo INT
)
AS
BEGIN

   DECLARE @Periodicidad int , 
           @NumPeriodo int ,
		   @Fk_IdCliente int ,
		   @FechaInicio date,
		   @FechaFin date ,
		   @DiasPago decimal(9,3)

	SELECT @NumPeriodo = IdPeriodo, @Periodicidad = Fk_IdPeriodicidadPago, @Fk_IdCLiente = Fk_IdCliente 
	FROM nom.PeriodoActivo WHERE Pk_IdPeriodoActivo = @IdPeriodoActivo
	
	SELECT @FechaInicio = FechaInicio, @FechaFin = FechaFin 
	FROM nom.VW_Periodos WHERE Fk_IdCliente = @Fk_IdCliente AND IdPeriodicidadPago = @Periodicidad AND IdPeriodo = @NumPeriodo

	SELECT 
				@DiasPago = (CASE WHEN @Periodicidad = 1 THEN DiasPago
								  WHEN @Periodicidad = 2 THEN DiasPago
								  WHEN @Periodicidad = 3 THEN DiasPago
								  WHEN @Periodicidad = 4 THEN DiasPago
								  WHEN @Periodicidad = 11 THEN 1
								  ELSE DiasPago END
							) 
				FROM 
					com.ClienteNominas 
					WHERE Fk_IdCliente = @Fk_IdCliente

   SELECT Pk_IdSueldo
	     ,NA.Fk_IdCliente
	     ,NA.Fk_IdEmpleado
	     ,NA.Fk_IdPeriodo
		 ,Fk_IdConceptoNomina
	     ,RazonSocial
		 ,RFCEmpresa 
		 ,RFCPersona
		 ,NoEmpleado
		 ,RegistroIMSS
		 ,CURP
		 ,DP
		 ,case 
			when NA.Fk_IdEmpleado IN (3295,3274,3217) AND NA.Fk_IdPeriodo IN (2260,1373) THEN 30 
			ELSE DT.DiasTrabajados - ISNULL(F.Faltas, 0) - ISNULL(F.Incapacidades,0) END DT
		 ,ROUND(SD,2) AS SD
		 ,ROUND(ISNULL(SalarioBaseCotizacion,PS.SalarioBaseCotizacion),2) AS SBC
	     ,EMPLEADO
		 ,AÑO
	     ,MesPago
		 ,NA.FechaInicio
	     ,FechaFin
		 ,Clave
		 ,PercepcionDeduccion
	     ,Concepto
		 ,Percepcion
	     ,Deduccion
		 ,Aportacion
		 ,Referencia
	     ,Periodo
		 ,PorcentajeGrava
	     ,ImporteXPorcentaje
	     ,Tope
	     ,GrabableAl100
		 ,BaseGravable
		 ,'O' as TipoNomina
		 ,NA.AplicaCalculo
	 FROM 
		nom.VW_NominaActual NA LEFT JOIN 
		nom.FN_FaltasActualXEmpresa (@Fk_IdCliente, @NumPeriodo, @FechaInicio, @FechaFin, 1) F ON F.Pk_IdEmpleado = NA.Fk_IdEmpleado INNER JOIN 
		nom.FN_ObtenerTablaDiasTrabajados(@DiasPago ,@FechaInicio,@FechaFin, @Periodicidad) DT ON NA.Fk_IdEmpleado = DT.IdEmpleado LEFT JOIN 
		rh.EmpleadoSalarios PS ON PS.Fk_IdEmpleado = NA.Fk_IdEmpleado AND PS.FechaInicio < NA.FechaFin AND PS.FechaFinal >= NA.FechaFin
		WHERE na.Fk_IdCliente = @Fk_IdCliente
			AND na.IdPeriodicidadPago = @Periodicidad
		    AND na.Fk_IdPeriodo = @NumPeriodo
			AND na.PercepcionDeduccion != 'A'		
	UNION ALL
		 SELECT 
		 SLF.Pk_IdSueldoFiniquitoOLiquidacion AS Pk_IdSueldo
		 ,P.Fk_IdCliente
	     ,LIQ.Fk_IdEmpleado
	     ,PER.IdPeriodo
		 ,SLF.Fk_IdConceptoNomina
	     ,E.RazonSocial
		 ,E.RFC AS RFCEmpresa
		 ,ef.RFC AS RFCPersona
		 ,P.Empleado AS NoEmpleado
		 ,ef.RegistroIMSS
		 ,ef.CURP
		 ,30
		 ,30
		 ,ROUND(PS.SalarioDiario,2) AS SD
		 ,ROUND(ISNULL(PS.SalarioBaseCotizacion,0),2) AS SBC
	     ,P.ApellidoPaterno + ' ' + P.ApellidoMaterno + ' ' + P.Nombre AS EMPLEADO
		 ,YEAR(LIQ.FechaBaja) AS AÑO
	     ,M.Descripcion AS MesPago
		 ,PER.FechaInicio
	     ,PER.FechaFin
		 ,C.Clave
		 ,C.PercepcionDeduccion
	     ,C.Nombre AS Concepto
		 ,SLF.Percepcion
	     ,SLF.Deduccion
		 ,0 as Aportacion
		 ,SLF.Referencia
	     ,ISNULL(PER.FechasPeriodo,LIQ.FechaBaja) Periodo
		 ,ISNULL(BG.Porcentaje,0) AS PorcentajeGrava
	     ,ISNULL(SLF.Percepcion * (BG.Porcentaje / 100), 0) ImporteXPorcentaje
	     ,ISNULL(BG.TopeMensual,0) AS Tope
	     ,CASE 
			WHEN BG.Porcentaje IS NOT NULL THEN (CASE 
														WHEN ISNULL(BG.TopeMensual,0) > SLF.Percepcion THEN (SLF.Percepcion - BG.TopeMensual) * (BG.Porcentaje/100)
														ELSE SLF.Percepcion * (BG.Porcentaje/100)														
												 END
												)
			ELSE 0
		 END GrabableAl100
		 ,CASE 
			WHEN BG.Porcentaje IS NOT NULL THEN (CASE 
														WHEN ISNULL(BG.TopeMensual,0) > SLF.Percepcion THEN (SLF.Percepcion - BG.TopeMensual) * (BG.Porcentaje/100)
														ELSE SLF.Percepcion * (BG.Porcentaje/100)														
												 END
												)
			ELSE 0
		 END BaseGravable
		 ,'E' as TipoNomina
		 ,CAST(1 AS BIT) AS AplicaCalculo
		FROM 
			NOM.SueldosFiniquitoOLiquidacion SLF INNER JOIN 			
			rh.FiniquitosOLiquidaciones LIQ ON LIQ.Pk_IdFiniquitoOLiquidacion = SLF.Fk_IdFiniquitoOLiquidacion INNER JOIN 
			rh.EmpleadoContratos CT ON LIQ.Fk_IdEmpleadoContrato = CT.Pk_IdEmpleadoContrato INNER JOIN 
			rh.Empleados P ON LIQ.Fk_IdEmpleado = P.Pk_IdEmpleado
		    INNER JOIN rh.EmpleadoDatosFiscales ef ON P.Pk_IdEmpleado = ef.Fk_IdEmpleado
			INNER JOIN 
			cat.ConceptosNomina C ON SLF.Fk_IdConceptoNomina = C.Pk_IdConceptoNomina INNER JOIN 
			com.Clientes E ON E.Pk_IdCliente = P.Fk_IdCliente LEFT JOIN 
			cat.BaseGravable BG ON C.Pk_IdConceptoNomina = BG.Fk_IdConceptoNomina LEFT JOIN 
			rh.EmpleadoSalarios PS ON PS.Fk_IdEmpleado = LIQ.Fk_IdEmpleado AND PS.FechaInicio < LIQ.FechaBaja AND PS.FechaFinal >= LIQ.FechaBaja LEFT JOIN 
			nom.VW_Periodos PER ON @NumPeriodo = PER.IdPeriodo AND @Periodicidad = PER.IdPeriodicidadPago AND P.Fk_IdCliente = PER.Fk_IdCliente INNER JOIN 
			sat.Meses M ON M.Pk_IdMes = MONTH(LIQ.FechaBaja)
		WHERE 
			P.Fk_IdCliente = @Fk_IdCliente AND LIQ.EsAutorizada = 1 
			AND LIQ.FechaBaja >= @FechaInicio AND LIQ.FechaBaja <= @FechaFin
			AND LIQ.Pk_IdFiniquitoOLiquidacion != 1192
			AND CT.Fk_IdPeriodicidadPago = @Periodicidad		
END
GO
