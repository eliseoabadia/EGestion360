USE [GestionEmpresarial]
GO


-- =============================================
-- Vista: ALMA.Vw_GrupoBien
-- Descripción: Lista los grupos de bienes con la descripción y clave de su familia.
-- =============================================
IF OBJECT_ID('ALMA.Vw_GrupoBien', 'V') IS NOT NULL DROP VIEW ALMA.Vw_GrupoBien;
GO

CREATE VIEW ALMA.Vw_GrupoBien
AS
SELECT 
    gb.PKIdGrupoBien,
    gb.FKIdFamilia_ALMA,
    gb.Descripcion AS GrupoBienDescripcion,
    gb.Clave AS GrupoBienClave,
    gb.ClaveAN,
    gb.CABM_ACT,
    gb.CLAVE_CUCOP,
    gb.MEDIDA,
    gb.Activo,
    gb.FechaCreacion,
    gb.UsuarioCreacion,
    gb.FechaModificacion,
    gb.UsuarioModificacion,
    -- Datos de la familia
    f.Descripcion AS FamiliaDescripcion,
    f.Clave AS FamiliaClave
FROM ALMA.GrupoBien gb
inner JOIN ALMA.Familia f ON gb.FKIdFamilia_ALMA = f.PKIdFamilia
WHERE gb.Activo = 1 AND f.Activo = 1;
GO

--GRANT SELECT ON ALMA.Vw_GrupoBien TO PUBLIC;
--GO
