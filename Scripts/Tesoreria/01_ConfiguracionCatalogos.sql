-- =============================================
-- Script de configuración para catálogos de Tesorería
-- =============================================

-- 1. Registrar los menús en la base de datos
-- =============================================

-- Tipo de Cambio
INSERT INTO Menu (Nombre, LegacyName, Tipo, Orden, Activo, Lenguaje, FechaCreacion)
VALUES ('Tipo de Cambio', 'Tipo_Cambio', 'M', 1, 1, 'ESP', GETDATE());
DECLARE @TipoCambioMenuId BIGINT = SCOPE_IDENTITY();

-- Tipo de Inversión
INSERT INTO Menu (Nombre, LegacyName, Tipo, Orden, Activo, Lenguaje, FechaCreacion)
VALUES ('Tipo de Inversión', 'Tipo_Inversion', 'M', 2, 1, 'ESP', GETDATE());
DECLARE @TipoInversionMenuId BIGINT = SCOPE_IDENTITY();

-- Tipo de Moneda
INSERT INTO Menu (Nombre, LegacyName, Tipo, Orden, Activo, Lenguaje, FechaCreacion)
VALUES ('Tipo de Moneda', 'Tipo_Moneda', 'M', 3, 1, 'ESP', GETDATE());
DECLARE @TipoMonedaMenuId BIGINT = SCOPE_IDENTITY();

-- Tipo de Pago
INSERT INTO Menu (Nombre, LegacyName, Tipo, Orden, Activo, Lenguaje, FechaCreacion)
VALUES ('Tipo de Pago', 'Tipo_Pago', 'M', 4, 1, 'ESP', GETDATE());
DECLARE @TipoPagoMenuId BIGINT = SCOPE_IDENTITY();

-- Tipo de Pago SF
INSERT INTO Menu (Nombre, LegacyName, Tipo, Orden, Activo, Lenguaje, FechaCreacion)
VALUES ('Tipo de Pago SF', 'Tipo_Pago_SF', 'M', 5, 1, 'ESP', GETDATE());
DECLARE @TipoPagoSFMenuId BIGINT = SCOPE_IDENTITY();

-- Tipo de Solicitud CLC
INSERT INTO Menu (Nombre, LegacyName, Tipo, Orden, Activo, Lenguaje, FechaCreacion)
VALUES ('Tipo de Solicitud CLC', 'Tipo_Solicitud_CLC', 'M', 6, 1, 'ESP', GETDATE());
DECLARE @TipoSolicitudCLCMenuId BIGINT = SCOPE_IDENTITY();

-- 2. Configurar permisos con spConfiguracionDeRolYClaims
-- =============================================

EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'Tipo_Cambio', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'Tipo_Inversion', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'Tipo_Moneda', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'Tipo_Pago', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'Tipo_Pago_SF', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Tesoreria', 'Tipo_Solicitud_CLC', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';

-- 3. Asignar menú al padre "Tesorería" (si existe)
-- =============================================
-- Asumiendo que el menú padre "Tesorería" tiene Id = 280 (ajustar según corresponda)
DECLARE @TesoreriaPadreId BIGINT = 280;

UPDATE Menu SET FkidMenuSis = @TesoreriaPadreId WHERE PkidMenu = @TipoCambioMenuId;
UPDATE Menu SET FkidMenuSis = @TesoreriaPadreId WHERE PkidMenu = @TipoInversionMenuId;
UPDATE Menu SET FkidMenuSis = @TesoreriaPadreId WHERE PkidMenu = @TipoMonedaMenuId;
UPDATE Menu SET FkidMenuSis = @TesoreriaPadreId WHERE PkidMenu = @TipoPagoMenuId;
UPDATE Menu SET FkidMenuSis = @TesoreriaPadreId WHERE PkidMenu = @TipoPagoSFMenuId;
UPDATE Menu SET FkidMenuSis = @TesoreriaPadreId WHERE PkidMenu = @TipoSolicitudCLCMenuId;

-- 4. Verificar inserciones
-- =============================================
SELECT 'Tipo Cambio' AS Catalogo, @TipoCambioMenuId AS MenuId
UNION ALL
SELECT 'Tipo Inversion' AS Catalogo, @TipoInversionMenuId AS MenuId
UNION ALL
SELECT 'Tipo Moneda' AS Catalogo, @TipoMonedaMenuId AS MenuId
UNION ALL
SELECT 'Tipo Pago' AS Catalogo, @TipoPagoMenuId AS MenuId
UNION ALL
SELECT 'Tipo Pago SF' AS Catalogo, @TipoPagoSFMenuId AS MenuId
UNION ALL
SELECT 'Tipo Solicitud CLC' AS Catalogo, @TipoSolicitudCLCMenuId AS MenuId;
