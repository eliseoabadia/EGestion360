USE [GestionEmpresarial];
GO

IF NOT EXISTS (
    SELECT 1
    FROM dbo.AspNetClaims
    WHERE [Group] = 'Almacen'
      AND SubGroup = 'Salidas_Ajuste'
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
        'Almacen',
        'Almacen',
        NULL,
        'app://{0}/{1}',
        GETDATE(),
        'Salidas_Ajuste',
        'AL0010',
        'Almacen',
        'view,view-menu,new,CanExportToExcel',
        0
    );
END
GO

EXEC spConfiguracionDeRolYClaims
    'Almacen',
    'Salidas_Ajuste',
    '10000',
    'view,view-menu,new,CanExportToExcel';
GO

IF NOT EXISTS (SELECT 1 FROM SIS.Menu WHERE PKIdMenu = 709)
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
        709,
        N'Salidas por Ajuste',
        1,
        6,
        N'Salidas por Ajuste',
        N'/Almacen/Salidas_Ajuste',
        N'FaLock',
        1,
        'ESP',
        3,
        1,
        GETDATE()
    );

    SET IDENTITY_INSERT SIS.Menu OFF;
END
ELSE
BEGIN
    UPDATE SIS.Menu
    SET
        Nombre = N'Salidas por Ajuste',
        LegacyName = N'Salidas por Ajuste',
        Ruta = N'/Almacen/Salidas_Ajuste',
        Activo = 1,
        [Orden] = 3
    WHERE PKIdMenu = 709;
END
GO
