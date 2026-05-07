select * from [PRES].[Fn]
select * from [PRES].[SF]

USE [GestionEmpresarial];
GO

-- =============================================
-- Vista: PRES.Vw_SubFuncion
-- Descripción: Lista las subfunciones presupuestales (SF)
--              junto con los datos de la función padre (FN).
-- =============================================
IF OBJECT_ID('PRES.Vw_SubFuncion', 'V') IS NOT NULL DROP VIEW PRES.Vw_SubFuncion;
GO

CREATE VIEW PRES.Vw_SubFuncion
AS
SELECT 
    sf.PKIdSF,
    sf.Clave AS SubFuncionClave,
    sf.Descripcion AS SubFuncionDescripcion,
    sf.FKIdFN_PRES,
    sf.Activo,
    -- Datos de la Función padre
    fn.Clave AS FuncionClave,
    fn.Descripcion AS FuncionDescripcion,
    -- Opcional: concatenación útil para combos
    CAST(sf.Clave AS NVARCHAR(10)) + ' - ' + sf.Descripcion AS SubFuncionClaveNombre,
    CAST(fn.Clave AS NVARCHAR(10)) + ' - ' + fn.Descripcion AS FuncionClaveNombre
FROM PRES.SF sf
LEFT JOIN PRES.FN fn ON sf.FKIdFN_PRES = fn.PKIdFN AND fn.Activo = 1
WHERE sf.Activo = 1;
GO

