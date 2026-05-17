USE [GestionEmpresarial];
GO

MERGE INTO SIS.Menu AS TARGET
USING (VALUES
    (N'Anteproyecto de Egresos', 1, 100, N'Planeacion', N'/Planeacion/Anteproyecto_Egresos', N'FaKey', 1, 'ESP', 2, 1, GETDATE())
) AS SOURCE (Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta, ImageUrl, Activo, Lenguaje, Orden, CreatedByOperatorId, CreatedDateTime)
ON TARGET.Ruta = SOURCE.Ruta
WHEN MATCHED THEN
    UPDATE SET
        TARGET.Nombre = SOURCE.Nombre,
        TARGET.Tipo = SOURCE.Tipo,
        TARGET.FKIdMenu_SIS = SOURCE.FKIdMenu_SIS,
        TARGET.LegacyName = SOURCE.LegacyName,
        TARGET.ImageUrl = SOURCE.ImageUrl,
        TARGET.Activo = SOURCE.Activo,
        TARGET.Lenguaje = SOURCE.Lenguaje,
        TARGET.Orden = SOURCE.Orden
WHEN NOT MATCHED THEN
    INSERT (Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta, ImageUrl, Activo, Lenguaje, Orden, CreatedByOperatorId, CreatedDateTime)
    VALUES (SOURCE.Nombre, SOURCE.Tipo, SOURCE.FKIdMenu_SIS, SOURCE.LegacyName, SOURCE.Ruta, SOURCE.ImageUrl, SOURCE.Activo, SOURCE.Lenguaje, SOURCE.Orden, SOURCE.CreatedByOperatorId, SOURCE.CreatedDateTime);
GO

EXEC spConfiguracionDeRolYClaims 'Planeacion', 'anteproyecto', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
GO
