-- Source: BD_PRESUPUESTO.[NOMI].[SP_WS_GetNomina]
-- Extracted for Nomina migration. Review schema/table mappings before applying to GestionEmpresarial.
GO
CREATE   PROCEDURE [NOMI].[SP_WS_GetNomina]
	@Quincena INT = NULL,
	@Ejercicio INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @message NVARCHAR(100)

	DECLARE @GetNomiScriptPath nvarchar(max) = (
	SELECT SPV.[Value]
	FROM SIS.SystemParamCatalog SPC JOIN SIS.SystemParamValue SPV
	ON SPC.PK_IdSystemParamCatalog = SPV.FK_IdSystemParamCatalog__SIS
	WHERE [Name] = 'GetNomiScript')
	
	--PRINT @GetNomiScriptPath

	if (@Quincena IS NULL OR @Ejercicio IS NULL)
		SELECT @Quincena = Quincena, @Ejercicio = Fk_IdAnio__SIS
		FROM Nomi.QuincenaActual
		Where Actual = 1

	DELETE FROM NOMI.DatosFinancieros
	WHERE intEjercicio = @Ejercicio 
	AND intQuincena = @Quincena;

    DECLARE @psCommand NVARCHAR(4000) = 'pwsh.exe -ExecutionPolicy Bypass -File ' + @GetNomiScriptPath + ' ' + CAST(@Quincena as nvarchar(2)) + ' ' + CAST(@Ejercicio as nvarchar(4))
    
	--PRINT @psCommand
	
	EXEC xp_cmdshell @psCommand;

	SET @message = 'Se ejecuto correctamente'
	SELECT JSON_QUERY( 
			CONCAT( '{', '"tipo":"', 'OK', 
							'",', '"mensaje":"', @message, 
							'",', '"liga":"', '[NOMI].[SP_WS_GetNomina]', '"', '}' ) 
		) 
	AS ResultJson 
	RETURN;
END
GO
