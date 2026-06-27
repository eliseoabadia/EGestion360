SET NOCOUNT ON;

EXEC spConfiguracionDeRolYClaims
    'Sistema',
    'Configurar_Accesos',
    '10000',
    'view,view-menu,delete,new,update,CanExportToExcel,authorize';

DECLARE @MenuId int;

SELECT @MenuId = PKIdMenu
FROM SIS.Menu
WHERE LegacyName = N'Configurar_Accesos'
   OR Ruta = N'/configuracion/sistema/Configurar_Accesos';

IF @MenuId IS NULL
BEGIN
    SELECT @MenuId =
        CASE
            WHEN NOT EXISTS (SELECT 1 FROM SIS.Menu WHERE PKIdMenu = 26) THEN 26
            ELSE ISNULL(MAX(PKIdMenu), 0) + 1
        END
    FROM SIS.Menu;

    INSERT INTO SIS.Menu
        (PKIdMenu, Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta, ImageUrl, Activo, Lenguaje, Orden, CreatedByOperatorId, CreatedDateTime)
    VALUES
        (@MenuId, N'Configurar Accesos', 2, 20, N'Configurar_Accesos', N'/configuracion/sistema/Configurar_Accesos', N'FaGears', 1, N'ESP', 3, 1, GETDATE());
END
ELSE
BEGIN
    UPDATE SIS.Menu
    SET Nombre = N'Configurar Accesos',
        Tipo = 2,
        FKIdMenu_SIS = 20,
        LegacyName = N'Configurar_Accesos',
        Ruta = N'/configuracion/sistema/Configurar_Accesos',
        ImageUrl = N'FaGears',
        Activo = 1,
        Lenguaje = N'ESP',
        Orden = 3,
        ModifiedByOperatorId = 1,
        ModifiedDateTime = GETDATE()
    WHERE PKIdMenu = @MenuId;
END;

MERGE INTO SIS.MenuRole AS TARGET
USING (
    SELECT DISTINCT
        M.PKIdMenu,
        R.Id AS RoleId,
        1 AS Activo,
        1 AS CreatedByOperatorId,
        GETDATE() AS CreatedDateTime
    FROM dbo.AspNetRoles AS R
    INNER JOIN dbo.AspNetUserRoles AS UR ON R.Id = UR.RoleId
    INNER JOIN dbo.AspNetUsers AS U ON U.Id = UR.UserId
    INNER JOIN SIS.Usuario AS SU ON SU.PKIdUsuario = U.PkIdUsuario AND SU.Activo = 1
    INNER JOIN dbo.AspNetClaims AS C ON C.RoleId = R.Id
    INNER JOIN dbo.AspNetClaimValues AS CV ON C.Id = CV.ClaimId
    INNER JOIN SIS.Menu AS M ON M.Activo = 1
        AND NULLIF(LTRIM(RTRIM(M.LegacyName)), '') = NULLIF(LTRIM(RTRIM(C.SubGroup)), '')
    WHERE CV.Value LIKE '%view-menu%'
) AS SOURCE (FKIdMenu_SIS, RoleId, Activo, CreatedByOperatorId, CreatedDateTime)
ON (TARGET.FKIdMenu_SIS = SOURCE.FKIdMenu_SIS AND TARGET.RoleId = SOURCE.RoleId)
WHEN MATCHED THEN
    UPDATE SET
        TARGET.Activo = SOURCE.Activo,
        TARGET.CreatedByOperatorId = SOURCE.CreatedByOperatorId,
        TARGET.CreatedDateTime = SOURCE.CreatedDateTime,
        TARGET.ModifiedByOperatorId = 1,
        TARGET.ModifiedDateTime = GETDATE()
WHEN NOT MATCHED BY TARGET THEN
    INSERT (FKIdMenu_SIS, RoleId, Activo, CreatedByOperatorId, CreatedDateTime)
    VALUES (SOURCE.FKIdMenu_SIS, SOURCE.RoleId, SOURCE.Activo, SOURCE.CreatedByOperatorId, SOURCE.CreatedDateTime)
WHEN NOT MATCHED BY SOURCE THEN DELETE;
