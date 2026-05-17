USE [GestionEmpresarial];
GO

SET IDENTITY_INSERT SIS.Menu ON;
GO

MERGE INTO SIS.Menu AS TARGET
USING (VALUES
    (301, N'Presupuesto Autorizado', 1, 300, N'Presupuesto Autorizado', N'/Presupuesto/Egreso/Presupuesto_Autorizado', N'FaTag', 1, 'ESP', 2, 1, GETDATE())
) AS SOURCE (PKIdMenu, Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta, ImageUrl, Activo, Lenguaje, Orden, CreatedByOperatorId, CreatedDateTime)
ON TARGET.PKIdMenu = SOURCE.PKIdMenu
WHEN MATCHED THEN
    UPDATE SET
        TARGET.Nombre = SOURCE.Nombre,
        TARGET.Tipo = SOURCE.Tipo,
        TARGET.FKIdMenu_SIS = SOURCE.FKIdMenu_SIS,
        TARGET.LegacyName = SOURCE.LegacyName,
        TARGET.Ruta = SOURCE.Ruta,
        TARGET.ImageUrl = SOURCE.ImageUrl,
        TARGET.Activo = SOURCE.Activo,
        TARGET.Lenguaje = SOURCE.Lenguaje,
        TARGET.Orden = SOURCE.Orden
WHEN NOT MATCHED THEN
    INSERT (PKIdMenu, Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta, ImageUrl, Activo, Lenguaje, Orden, CreatedByOperatorId, CreatedDateTime)
    VALUES (SOURCE.PKIdMenu, SOURCE.Nombre, SOURCE.Tipo, SOURCE.FKIdMenu_SIS, SOURCE.LegacyName, SOURCE.Ruta, SOURCE.ImageUrl, SOURCE.Activo, SOURCE.Lenguaje, SOURCE.Orden, SOURCE.CreatedByOperatorId, SOURCE.CreatedDateTime);
GO

SET IDENTITY_INSERT SIS.Menu OFF;
GO

EXEC spConfiguracionDeRolYClaims 'Egreso', 'Presupuesto_Autorizado', '10000', 'view,view-menu,delete,new,update';
GO
