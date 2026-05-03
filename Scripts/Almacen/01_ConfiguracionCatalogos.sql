-- =============================================
-- Script de configuración para catálogos de Almacén
-- =============================================

-- 1. Registrar los menús en la base de datos
-- =============================================

-- Motivo de Entradas y Salidas
INSERT INTO Menu (Nombre, LegacyName, Tipo, Orden, Activo, Lenguaje, FechaCreacion)
VALUES ('Motivo de Entradas Salidas', 'Movimiento_Entrada_Salida', 'M', 1, 1, 'ESP', GETDATE());
DECLARE @MotivoMenuId BIGINT = SCOPE_IDENTITY();

-- Estatus Solicitud
INSERT INTO Menu (Nombre, LegacyName, Tipo, Orden, Activo, Lenguaje, FechaCreacion)
VALUES ('Estatus Solicitud', 'Estatus_Solicitud', 'M', 2, 1, 'ESP', GETDATE());
DECLARE @EstatusMenuId BIGINT = SCOPE_IDENTITY();

-- Unidades
INSERT INTO Menu (Nombre, LegacyName, Tipo, Orden, Activo, Lenguaje, FechaCreacion)
VALUES ('Unidades', 'Unidades', 'M', 3, 1, 'ESP', GETDATE());
DECLARE @UnidadesMenuId BIGINT = SCOPE_IDENTITY();

-- Período de Conteo
INSERT INTO Menu (Nombre, LegacyName, Tipo, Orden, Activo, Lenguaje, FechaCreacion)
VALUES ('Período de Conteo', 'Conteo_Periodo', 'M', 4, 1, 'ESP', GETDATE());
DECLARE @PeriodoMenuId BIGINT = SCOPE_IDENTITY();

-- 2. Configurar permisos con spConfiguracionDeRolYClaims
-- =============================================

-- Motivo de Entradas y Salidas
EXEC spConfiguracionDeRolYClaims 'Almacen', 'Movimiento_Entrada_Salida', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';

-- Estatus Solicitud
EXEC spConfiguracionDeRolYClaims 'Almacen', 'Estatus_Solicitud', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';

-- Unidades
EXEC spConfiguracionDeRolYClaims 'Almacen', 'Unidades', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';

-- Período de Conteo
EXEC spConfiguracionDeRolYClaims 'Almacen', 'Conteo_Periodo', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';

-- 3. Asignar menú al padre "Almacén" (si existe)
-- =============================================
-- Asumiendo que el menú padre "Almacén" tiene Id = 270 (ajustar según corresponda)
DECLARE @AlmacenPadreId BIGINT = 270;

UPDATE Menu SET FkidMenuSis = @AlmacenPadreId WHERE PkidMenu = @MotivoMenuId;
UPDATE Menu SET FkidMenuSis = @AlmacenPadreId WHERE PkidMenu = @EstatusMenuId;
UPDATE Menu SET FkidMenuSis = @AlmacenPadreId WHERE PkidMenu = @UnidadesMenuId;
UPDATE Menu SET FkidMenuSis = @AlmacenPadreId WHERE PkidMenu = @PeriodoMenuId;

-- 4. Verificar inserciones
-- =============================================
SELECT 'Motivo ES' AS Catalogo, @MotivoMenuId AS MenuId
UNION ALL
SELECT 'Estatus Sol' AS Catalogo, @EstatusMenuId AS MenuId
UNION ALL
SELECT 'Unidades' AS Catalogo, @UnidadesMenuId AS MenuId
UNION ALL
SELECT 'Periodo Conteo' AS Catalogo, @PeriodoMenuId AS MenuId;
