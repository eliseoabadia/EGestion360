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
    (2, N'Presupuesto', 1, NULL, N'Presupuesto', N'/', N'FaChartPie', 1, N'ESP', 2, 1),
    (120, N'Tesoreria', 1, 2, N'Tesoreria', N'/', N'FaChartLine', 1, N'ESP', 2, 1),
    (121, N'Cuentas por Cobrar', 1, 120, N'Cuentas por Cobrar', N'/', N'FaFileInvoiceDollar', 1, N'ESP', 1, 1),
    (127, N'Modificado de Ingresos', 1, 121, N'Presupuesto_Modificado', N'/', N'FaMoneyBillTransfer', 1, N'ESP', 2, 1),
    (128, N'Adecuaciones Compensadas de Ingresos', 2, 127, N'Adecuaciones_Compensadas', N'/Presupuesto/Tesoreria/Cuentas_Cobrar/Modificado_Ingreso/Adecuaciones_Compensadas_Ingresos', N'FaScaleBalanced', 1, N'ESP', 1, 1),
    (129, N'Aumentos al presupuesto de Ingresos', 2, 127, N'Ampliaciones', N'/Presupuesto/Tesoreria/Cuentas_Cobrar/Modificado_Ingreso/Aumentos_Presupuesto_Ingreso', N'FaArrowTrendUp', 1, N'ESP', 2, 1),
    (130, N'Reduccion al presupuesto de Ingresos', 2, 127, N'Reducciones', N'/Presupuesto/Tesoreria/Cuentas_Cobrar/Modificado_Ingreso/Reduccion_Presupuesto_Ingreso', N'FaArrowTrendDown', 1, N'ESP', 3, 1)
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
        'Presupuesto_Modificado', 'Adecuaciones_Compensadas', '10000',
        'view,view-menu,new,update,delete,CanExportToExcel,authorize';

    EXEC dbo.spConfiguracionDeRolYClaims
        'Presupuesto_Modificado', 'Ampliaciones', '10000',
        'view,view-menu,new,update,delete,CanExportToExcel,authorize';

    EXEC dbo.spConfiguracionDeRolYClaims
        'Presupuesto_Modificado', 'Reducciones', '10000',
        'view,view-menu,new,update,delete,CanExportToExcel,authorize';
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
        WHERE menu.PKIdMenu IN (2, 120, 121, 127, 128, 129, 130)
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

/*
    Notifica a los usuarios cuyos roles contienen el permiso solicitado para
    el modulo/submodulo. Se usa al enviar una adecuacion a autorizacion.
*/
CREATE OR ALTER PROCEDURE SIS.sp_NotificacionCrearPorPermiso
    @ClaveTipo nvarchar(80),
    @Fk_IdUsuarioOrigen int = NULL,
    @Modulo nvarchar(120),
    @SubModulo nvarchar(120),
    @Accion nvarchar(80),
    @Evento nvarchar(120),
    @Entidad nvarchar(150) = NULL,
    @Fk_IdEntidad bigint = NULL,
    @Titulo nvarchar(250),
    @Mensaje nvarchar(max),
    @Url nvarchar(1000) = NULL,
    @JsonData nvarchar(max) = NULL,
    @IdUser int = NULL,
    @IdNotificacion bigint OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Usuarios SIS.NotificacionUsuarioType;

    INSERT INTO @Usuarios (Fk_IdUsuarioDestino)
    SELECT DISTINCT users.PkIdUsuario
    FROM dbo.AspNetUsers users
    INNER JOIN dbo.AspNetUserRoles userRole
        ON users.Id = userRole.UserId
    INNER JOIN dbo.AspNetRoles roles
        ON userRole.RoleId = roles.Id
    LEFT JOIN dbo.AspNetClaims claims
        ON roles.Id = claims.RoleId
    WHERE users.PkIdUsuario IS NOT NULL
      AND users.PkIdUsuario <> ISNULL(@Fk_IdUsuarioOrigen, -1)
      AND (
            roles.Name = N'SuperAdmin'
            OR (
                claims.[Group] = @Modulo
                AND claims.SubGroup = @SubModulo
                AND CONCAT(',', REPLACE(ISNULL(claims.[Values], ''), ' ', ''), ',')
                    LIKE CONCAT('%,', REPLACE(@Accion, ' ', ''), ',%')
            )
          );

    EXEC SIS.sp_NotificacionCrear
        @ClaveTipo = @ClaveTipo,
        @Fk_IdUsuarioOrigen = @Fk_IdUsuarioOrigen,
        @Modulo = @Modulo,
        @SubModulo = @SubModulo,
        @Evento = @Evento,
        @Entidad = @Entidad,
        @Fk_IdEntidad = @Fk_IdEntidad,
        @Titulo = @Titulo,
        @Mensaje = @Mensaje,
        @Url = @Url,
        @JsonData = @JsonData,
        @Usuarios = @Usuarios,
        @IdUser = @IdUser,
        @IdNotificacion = @IdNotificacion OUTPUT;
END
GO

PRINT N'Fase 2 de adecuaciones de ingresos configurada.';
GO
