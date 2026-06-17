-- Source: BD_ExuxFinanzas.[nom].[spU_NominaAutorizar]
-- Extracted for Nomina migration. Review schema/table mappings before applying to GestionEmpresarial.
GO
-- =============================================
-- Autor: Luis Antonio Moreno 
-- Fecha de creación: 16122025
-- Descripción: Se autoriza la nómina	
-- =============================================
CREATE   PROCEDURE [nom].[spU_NominaAutorizar]
(
    @IdPeriodo int
   ,@IdCliente int
   ,@IdPeriodicidad int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
   SET NOCOUNT ON;

   IF(@IdPeriodicidad = 1)
      UPDATE nom.PeriodoDiario 
         SET EsAutorizada = 1 
       WHERE Pk_IdPeriodoDiario = @IdPeriodo 
         AND Fk_IdCliente = @IdCliente;

   IF(@IdPeriodicidad = 2)
      UPDATE nom.PeriodoSemanal
         SET EsAutorizada = 1 
       WHERE Pk_IdPeriodoSemanal = @IdPeriodo 
         AND Fk_IdCliente = @IdCliente;
         
   IF(@IdPeriodicidad = 3)
      UPDATE nom.PeriodoCatorcenal
         SET EsAutorizada = 1 
       WHERE Pk_IdPeriodoCatorcenal = @IdPeriodo 
         AND Fk_IdCliente = @IdCliente;
         
   IF(@IdPeriodicidad = 4)   
      UPDATE nom.PeriodoQuincenal 
         SET EsAutorizada = 1 
       WHERE Pk_IdPeriodoQuincenal = @IdPeriodo 
         AND Fk_IdCliente = @IdCliente;
         
   IF(@IdPeriodicidad = 5)
      UPDATE nom.PeriodoMensual
         SET EsAutorizada = 1 
       WHERE Pk_IdPeriodoMensual = @IdPeriodo 
         AND Fk_IdCliente = @IdCliente;
         
END
GO
