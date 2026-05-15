USE [GestionEmpresarial];
GO

SET IDENTITY_INSERT SIS.Menu ON;

MERGE INTO SIS.Menu AS TARGET
USING (VALUES
    (219, N'Programas Presupuestales', 2, 100, N'Programas Presupuestales.', N'/configuracion/presupuestales/programas-presupuesta', N'FaKey', 1, 'ESP', 1, 1, GETDATE())
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

SET IDENTITY_INSERT SIS.Menu OFF;
GO

EXEC spConfiguracionDeRolYClaims 'Catalogos_presupuestales', 'Programas_Presupuestales', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
GO
