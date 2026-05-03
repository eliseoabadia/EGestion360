-- =============================================
-- Script de configuración para catálogo de Función (Finalidad)
-- Módulo: PRES.GF - Grupo Funcional
-- =============================================

-- 1. Registrar el menú de Función (Finalidad)
-- =============================================
DECLARE @ClaveProgramaPadreId BIGINT;
SELECT @ClaveProgramaPadreId = PkidMenu FROM Menu WHERE LegacyName = 'ClavePrograma' AND Activo = 1;

IF @ClaveProgramaPadreId IS NOT NULL
BEGIN
    -- Insertar menú de Función
    INSERT INTO Menu (Nombre, LegacyName, Tipo, Orden, Activo, Lenguaje, FechaCreacion, FkidMenuSis)
    VALUES ('Función', 'Finalidad', 'M', 1, 1, 'ESP', GETDATE(), @ClaveProgramaPadreId);
    
    DECLARE @FuncionMenuId BIGINT = SCOPE_IDENTITY();
    
    -- 2. Configurar permisos con spConfiguracionDeRolYClaims
    -- =============================================
    EXEC spConfiguracionDeRolYClaims 'Presupuestales', 'Finalidad', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
    
    PRINT 'Menú de Función registrado con ID: ' + CAST(@FuncionMenuId AS VARCHAR);
    PRINT 'Padre: ClavePrograma (ID: ' + CAST(@ClaveProgramaPadreId AS VARCHAR) + ')';
END
ELSE
BEGIN
    PRINT 'Error: No se encontró el menú padre ClavePrograma';
END

-- 3. Verificar inserción
-- =============================================
SELECT 
    'Función' AS Catalogo, 
    m.PkidMenu AS MenuId,
    m.Nombre AS Nombre,
    m.LegacyName AS LegacyName,
    m.FkidMenuSis AS PadreId,
    p.PkidPermiso AS PermisoId
FROM Menu m
LEFT JOIN Permiso p ON p.FkidMenuSis = m.PkidMenu AND p.ClaveAccion = 'view'
WHERE m.LegacyName = 'Finalidad';
