USE [GestionEmpresarial]
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF OBJECT_ID(N'SIS.Menu', N'U') IS NULL
    THROW 51000, N'No existe SIS.Menu.', 1;
GO

SET IDENTITY_INSERT SIS.Menu ON;

MERGE SIS.Menu AS target
USING (VALUES
    (1100, N'PRB', 2, NULL, N'PRB', N'/PRB', N'FaChartLine', 1, N'ESP', 9, 1)
) AS source (
    PKIdMenu, Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta, ImageUrl,
    Activo, Lenguaje, Orden, CreatedByOperatorId
)
ON target.PKIdMenu = source.PKIdMenu
WHEN MATCHED THEN UPDATE SET
    target.Nombre = source.Nombre,
    target.Tipo = source.Tipo,
    target.FKIdMenu_SIS = source.FKIdMenu_SIS,
    target.LegacyName = source.LegacyName,
    target.Ruta = source.Ruta,
    target.ImageUrl = source.ImageUrl,
    target.Activo = source.Activo,
    target.Lenguaje = source.Lenguaje,
    target.Orden = source.Orden,
    target.ModifiedByOperatorId = 1,
    target.ModifiedDateTime = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    PKIdMenu, Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta, ImageUrl,
    Activo, Lenguaje, Orden, CreatedByOperatorId, CreatedDateTime
)
VALUES (
    source.PKIdMenu, source.Nombre, source.Tipo, source.FKIdMenu_SIS,
    source.LegacyName, source.Ruta, source.ImageUrl, source.Activo,
    source.Lenguaje, source.Orden, source.CreatedByOperatorId, GETDATE()
);

SET IDENTITY_INSERT SIS.Menu OFF;
GO

IF OBJECT_ID(N'dbo.spConfiguracionDeRolYClaims', N'P') IS NOT NULL
BEGIN
    EXEC dbo.spConfiguracionDeRolYClaims
        'PRB', 'PRB', '10000', 'view,view-menu';
END
GO

IF OBJECT_ID(N'SIS.MenuRole', N'U') IS NOT NULL
   AND EXISTS (SELECT 1 FROM dbo.AspNetRoles WHERE Id = N'10000')
BEGIN
    MERGE SIS.MenuRole AS target
    USING (
        SELECT menu.PKIdMenu, role.Id AS RoleId
        FROM SIS.Menu menu
        CROSS JOIN dbo.AspNetRoles role
        WHERE menu.PKIdMenu = 1100
          AND role.Id = N'10000'
    ) AS source
    ON target.FKIdMenu_SIS = source.PKIdMenu
   AND target.RoleId = source.RoleId
    WHEN MATCHED THEN UPDATE SET
        target.Activo = 1,
        target.ModifiedByOperatorId = 1,
        target.ModifiedDateTime = GETDATE()
    WHEN NOT MATCHED THEN INSERT (
        FKIdMenu_SIS, RoleId, Activo, CreatedByOperatorId, CreatedDateTime
    ) VALUES (
        source.PKIdMenu, source.RoleId, 1, 1, GETDATE()
    );
END
GO
