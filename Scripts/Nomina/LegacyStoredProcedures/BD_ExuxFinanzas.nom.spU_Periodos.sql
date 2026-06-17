-- Source: BD_ExuxFinanzas.[nom].[spU_Periodos]
-- Extracted for Nomina migration. Review schema/table mappings before applying to GestionEmpresarial.
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [nom].[spU_Periodos] 
(
    @IdPeriodo int
   ,@EsCerrada bit
   ,@EsActivo bit
   ,@Fk_IdPeriodicidad int
)
AS
BEGIN
   IF(@Fk_IdPeriodicidad = 2)
   BEGIN 
      UPDATE nom.PeriodoSemanal SET EsActivo = @EsActivo, EsCerrada = @EsCerrada WHERE Pk_IdPeriodoSemanal = @IdPeriodo
   END
   ELSE IF(@Fk_IdPeriodicidad = 4)
   BEGIN
      UPDATE nom.PeriodoQuincenal SET EsActivo = @EsActivo, EsCerrada = @EsCerrada WHERE Pk_IdPeriodoQuincenal = @IdPeriodo
   END
   ELSE IF(@Fk_IdPeriodicidad = 5)
   BEGIN
      UPDATE nom.PeriodoMensual SET EsActivo = @EsActivo, EsCerrada = @EsCerrada WHERE Pk_IdPeriodoMensual = @IdPeriodo
   END
END
GO
