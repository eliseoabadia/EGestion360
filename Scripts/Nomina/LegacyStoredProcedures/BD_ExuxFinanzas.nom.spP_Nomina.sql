-- Source: BD_ExuxFinanzas.[nom].[spP_Nomina]
-- Extracted for Nomina migration. Review schema/table mappings before applying to GestionEmpresarial.
GO
-- =============================================
-- Autor: Luis Antonio Moreno Ortiz
-- Fecha de Creación: 31122024
-- Description:	Calcula una Nómina 
-- =============================================
CREATE   PROCEDURE [nom].[spP_Nomina]
(	   
    @IdCliente int
   ,@IdPeriodoActivo int
   ,@IdEmpresa int
   ,@IdPeriodicidadPago int
)
AS
BEGIN
   SET NOCOUNT ON;

	--Se Borran los datos de la Nomina actual, con el fin de prevenir 
   DECLARE @idBimestre int
          ,@idEsquema int
          ,@esFinMes bit
		  ,@esIsrMasAlto bit
		  ,@fechaFinPeriodo date
          ,@fechaInicioPeriodo date
		  ,@salarioMinimoGeneral decimal(18,2)
		  ,@diasPago decimal(18,2)
		  ,@diasImss decimal(18,2)
		  ,@factorDescuentoFalta decimal(18,2)

   SELECT @IdPeriodicidadPago = IdPeriodicidadPago
         ,@fechaFinPeriodo = FechaFin
         ,@fechaInicioPeriodo = FechaInicio
		 ,@esFinMes = EsfinMes
		 ,@idBimestre = Fk_IdPeriodoBimestral 
     FROM nom.VW_PeriodoActivo 
	WHERE Fk_IdCliente = @IdCliente
	  AND IdPeriodicidadPago = @IdPeriodicidadPago
	  AND IdPeriodo = @IdPeriodoActivo

   SELECT @IdEsquema = FK_IdTipoEsquema
     FROM nom.PreNominas
    WHERE Fk_IdCliente = @IdCliente
	  AND Fk_IdPeriodo = @IdPeriodoActivo
	  AND Fk_IdPeriodicidadPago = @IdPeriodicidadPago

   IF((SELECT Fk_IdZonaGeografica FROM emp.EmpresaPlazas WHERE Fk_IdEmpresa = @IdEmpresa) = 1)
   BEGIN
      SET @salarioMinimoGeneral = (SELECT Valor
	                                 FROM nom.SalariosMinimosGeneral 
			  					    WHERE @FechaFinPeriodo > FechaInicio 
									  AND @FechaFinPeriodo <= FechaFin)
    END
    ELSE
    BEGIN
	   SET @salarioMinimoGeneral = (SELECT ValorFrontera 
		                              FROM nom.SalariosMinimosGeneral
			   						 WHERE @FechaFinPeriodo > FechaInicio 
									   AND @FechaFinPeriodo <= FechaFin)
    END

   EXECUTE nom.spP_Limpiar @IdCliente, @IdEmpresa, @IdPeriodoActivo, @idPeriodicidadPago;

   SELECT @diasPago = DiasPago	
	     ,@diasImss = DiasImss	
		 ,@factorDescuentoFalta = FactorDescuentoFalta	
		 ,@esIsrMasAlto = EsIsrMasAlto	
	 FROM com.ClienteNominas 
	WHERE Fk_IdCliente = @IdCliente
	  AND FechaFin IS NULL;

   EXECUTE nom.spP_LlenarSueldo @IdCliente, @IdPeriodoActivo, @IdPeriodicidadPago, @IdEmpresa, @IdEsquema, @diasPago

   IF(@IdEsquema = 1 OR @IdEsquema = 2)
   BEGIN
	  EXECUTE nom.spP_CalculoIsr @IdEmpresa, @IdPeriodoActivo, @fechaFinPeriodo, @salarioMinimoGeneral, @IdCliente, @idPeriodicidadPago;
   END
   ELSE
   BEGIN
      EXECUTE nom.SD_IMSS @IdCliente,@IdPeriodoActivo,@idPeriodicidadPago,@IdEmpresa;
	  IF(@esFinMes = 1)
	     EXECUTE nom.spP_CalculoIsr @IdEmpresa, @IdPeriodoActivo, @fechaFinPeriodo, @salarioMinimoGeneral, @IdCliente, @idPeriodicidadPago;
	  ELSE
         EXECUTE nom.spP_CalculoIsr @IdEmpresa, @IdPeriodoActivo, @fechaFinPeriodo, @salarioMinimoGeneral, @IdCliente, @idPeriodicidadPago;

      IF(@IdEsquema = 3)
	     EXECUTE nom.spP_LlenadoExcedente  @IdPeriodoActivo,@IdCliente,@IdPeriodicidadPago;
   END

   EXECUTE nom.spP_LlenadoTimbrado @IdCliente ,@IdPeriodoActivo ,@IdPeriodicidadPago, @FechaInicioPeriodo,@FechaFinPeriodo;

   
       IF @IdPeriodicidadPago = 7 -- Decenal
    BEGIN
        UPDATE nom.PeriodoDecenal
        SET EsCalculada = 1
        WHERE Pk_IdPeriodoDecenal = @IdPeriodoActivo
          AND Fk_IdCliente = @IdCliente;
    END
    ELSE IF @IdPeriodicidadPago = 1 -- Diario
    BEGIN
        UPDATE nom.PeriodoDiario
        SET EsCalculada = 1
        WHERE Pk_IdPeriodoDiario = @IdPeriodoActivo
          AND Fk_IdCliente = @IdCliente;
    END
    ELSE IF @IdPeriodicidadPago = 5 -- Mensual
    BEGIN
        UPDATE nom.PeriodoMensual
        SET EsCalculada = 1
        WHERE Pk_IdPeriodoMensual = @IdPeriodoActivo
          AND Fk_IdCliente = @IdCliente;
    END
    ELSE IF @IdPeriodicidadPago = 4 -- Quincenal
    BEGIN
        UPDATE nom.PeriodoQuincenal
        SET EsCalculada = 1
        WHERE Pk_IdPeriodoQuincenal = @IdPeriodoActivo
          AND Fk_IdCliente = @IdCliente;
    END
    ELSE IF @IdPeriodicidadPago = 2 -- Semanal
    BEGIN
        UPDATE nom.PeriodoSemanal
        SET EsCalculada = 1
        WHERE Pk_IdPeriodoSemanal = @IdPeriodoActivo
          AND Fk_IdCliente = @IdCliente;
    END
END
GO
