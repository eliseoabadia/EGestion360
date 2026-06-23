USE [GestionEmpresarial];
GO

IF NOT EXISTS (
    SELECT 1
    FROM dbo.AspNetClaims
    WHERE [Group] = 'Almacen'
      AND SubGroup = 'Tipo_Bien'
)
BEGIN
    INSERT INTO dbo.AspNetClaims
    (
        ClaimTypeId,
        Name,
        [Group],
        RoleId,
        TokenFormat,
        Created,
        SubGroup,
        Code,
        [Description],
        [Values],
        ReferenceId
    )
    VALUES
    (
        2,
        'Configuracion',
        'Almacen',
        NULL,
        'app://{0}/{1}',
        GETDATE(),
        'Tipo_Bien',
        'CONALS06',
        'Tipo Bien',
        'view,view-menu,delete,new,update,CanExportToExcel',
        76
    );
END
ELSE
BEGIN
    UPDATE dbo.AspNetClaims
    SET
        Name = 'Configuracion',
        Code = 'CONALS06',
        [Description] = 'Tipo Bien',
        [Values] = 'view,view-menu,delete,new,update,CanExportToExcel',
        ReferenceId = 76
    WHERE [Group] = 'Almacen'
      AND SubGroup = 'Tipo_Bien';
END
GO

EXEC spConfiguracionDeRolYClaims
    'Almacen',
    'Tipo_Bien',
    '10000',
    'view,view-menu,delete,new,update,CanExportToExcel';
GO

IF NOT EXISTS (SELECT 1 FROM SIS.Menu WHERE PKIdMenu = 76)
BEGIN
    SET IDENTITY_INSERT SIS.Menu ON;

    INSERT INTO SIS.Menu
    (
        PKIdMenu,
        Nombre,
        Tipo,
        FKIdMenu_SIS,
        LegacyName,
        Ruta,
        ImageUrl,
        Activo,
        Lenguaje,
        [Orden],
        CreatedByOperatorId,
        CreatedDateTime
    )
    VALUES
    (
        76,
        N'Tipo Bien',
        2,
        70,
        N'Tipo Bien',
        N'/configuracion/almacen/Tipo_Bien',
        N'FaTag',
        1,
        'ESP',
        6,
        1,
        GETDATE()
    );

    SET IDENTITY_INSERT SIS.Menu OFF;
END
ELSE
BEGIN
    UPDATE SIS.Menu
    SET
        Nombre = N'Tipo Bien',
        Tipo = 2,
        FKIdMenu_SIS = 70,
        LegacyName = N'Tipo Bien',
        Ruta = N'/configuracion/almacen/Tipo_Bien',
        ImageUrl = N'FaTag',
        Activo = 1,
        [Orden] = 6
    WHERE PKIdMenu = 76;
END
GO
