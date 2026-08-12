SET NOCOUNT ON;
GO

EXEC dbo.spConfiguracionDeRolYClaims
    'Almacen', 'Solicitudes_Salida', '10000',
    'view,view-menu,delete,new,update,authorize,CanExportToExcel';

EXEC dbo.spConfiguracionDeRolYClaims
    'Almacen', 'Suministros_Salida', '10000',
    'view,view-menu,update,authorize,CanExportToExcel';
GO

DECLARE @RoleId nvarchar(128) = (SELECT Id FROM dbo.AspNetRoles WHERE Code = '10000');

INSERT dbo.AspNetClaimValues (ClaimId, Value, Created)
SELECT claim.Id, 'authorize', GETDATE()
FROM dbo.AspNetClaims claim
WHERE claim.RoleId = @RoleId
  AND claim.[Group] = 'Almacen'
  AND claim.SubGroup IN ('Solicitudes_Salida', 'Suministros_Salida')
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.AspNetClaimValues value
      WHERE value.ClaimId = claim.Id
        AND value.Value = 'authorize'
  );
GO
