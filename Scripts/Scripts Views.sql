/*Vistas*/
CREATE    VIEW  [SIS].[VW_EmpresaDepartamanto]
AS
SELECT E.PKIdEmpresa,
	   E.Nombre AS EmpresaNombre,
	   E.RFC,
	   D.PKIdDepartamento,
	   D.Nombre AS DepartamentoNombre,
	   D.Activo AS DepartamentoActivo,
	   E.Activo AS EmpresaActivo
FROM [SIS].[Empresa] E WITH (NOLOCK)
INNER JOIN [SIS].[Departamento] D WITH (NOLOCK) ON E.PKIdEmpresa = D.FKIdEmpresa_SIS
WHERE E.Activo = 1 AND D.Activo = 1 ;

GO


CREATE    VIEW  [SIS].[VW_EstadoEmpresa]
AS
SELECT E.PKIdEstado,
	   E.Nombre AS EstadoNombre,
	   T.PKIdEmpresa,
	   T.Nombre AS EmpresaNombre,
	   T.RFC,
	   T.Activo AS EmpresaActivo
FROM [SIS].Estados E WITH (NOLOCK)
INNER JOIN [SIS].[Empresa] T WITH (NOLOCK) ON E.PKIdEstado = T.PKIdEmpresa
WHERE T.Activo = 1 ;

GO


CREATE or ALTER VIEW SIS.VW_UsuarioSucursal
AS
SELECT 
    -- Datos del Usuario
    u.PkIdUsuario,
    u.FKIdEmpresa_SIS AS IdEmpresa,
    e.Nombre AS NombreEmpresa,
    e.Rfc AS RfcEmpresa, -- Agregado RFC de la empresa
    u.Nombre + ' ' + u.ApellidoPaterno + ' ' + ISNULL(u.ApellidoMaterno, '') AS NombreCompleto,
    u.Nombre AS NombreUsuario,
    u.ApellidoPaterno,
    u.ApellidoMaterno,
    u.Iniciales,
    u.PayrollID,
    u.CodigoPostal AS CodigoPostalUsuario,
    u.Telefono AS TelefonoUsuario,
    u.Direccion1,
    u.Direccion2,
    u.Email,
    u.NumeroSocial,
    u.Gafete,
    CASE WHEN u.Sexo = 1 THEN 'Masculino' ELSE 'Femenino' END AS SexoDescripcion,
    u.Sexo,
    u.Activo AS UsuarioActivo,
    u.FechaCreacion AS UsuarioFechaCreacion,
    u.UsuarioCreacion AS UsuarioCreadorId
    
    -- Datos de la Sucursal
    --s.PKIdSucursal,
    --s.Nombre AS NombreSucursal,
    --s.CodigoSucursal,
    --s.Alias AS AliasSucursal,
    --s.TipoSucursal,
    --ct.Descripcion AS TipoSucursalDescripcion,
    --s.Direccion AS DireccionSucursal,
    --s.Colonia,
    --s.Ciudad,
    --s.CodigoPostal AS CodigoPostalSucursal,
    --s.TelefonoPrincipal,
    --s.TelefonoSecundario,
    --s.Email AS EmailSucursal,
    --s.HorarioApertura,
    --s.HorarioCierre,
    --s.EsMatriz,
    --CASE WHEN s.EsMatriz = 1 THEN 'Matriz' ELSE 'Sucursal' END AS TipoSucursalLabel,
    --s.EsActiva,
    --s.Latitud,
    --s.Longitud,
    --s.MetrosCuadrados,
    --s.CapacidadPersonas,
    --s.Activo AS SucursalActivo,
    
    ---- Datos del Estado - CORREGIDO: Usar solo columnas que existen
    --est.PKIdEstado,
    --est.Nombre AS NombreEstado,
    ---- Eliminadas: Clave, PaisId, NombrePais (no existen en tu tabla)
    
    ---- Datos de la Relación Usuario-Sucursal
    --us.FKIdDepartamento_SIS AS IdDepartamento,
    --d.Nombre AS NombreDepartamento,
    --us.EsGerente,
    --us.EsSupervisor,
    --us.PuedeAcceder,
    --us.PuedeConfigurar,
    --us.PuedeOperar,
    --us.PuedeReportes,
    --us.FechaAsignacion,
    --us.FechaFinAsignacion,
    --us.Activo AS RelacionActiva,
    
    ---- Información adicional
    --CASE 
    --    WHEN us.EsGerente = 1 THEN 'Gerente'
    --    WHEN us.EsSupervisor = 1 THEN 'Supervisor'
    --    ELSE 'Operador'
    --END AS RolUsuario,
    
    --CASE 
    --    WHEN us.PuedeAcceder = 1 AND us.PuedeConfigurar = 1 AND us.PuedeReportes = 1 THEN 'Acceso Total'
    --    WHEN us.PuedeAcceder = 1 AND us.PuedeOperar = 1 THEN 'Operador'
    --    WHEN us.PuedeAcceder = 1 AND us.PuedeReportes = 1 THEN 'Consultor'
    --    WHEN us.PuedeAcceder = 1 THEN 'Acceso Básico'
    --    ELSE 'Sin Acceso'
    --END AS NivelAcceso,
    
    ---- Auditoría de la relación
    --us.FechaCreacion AS RelacionFechaCreacion,
    --us.UsuarioCreacion AS RelacionUsuarioCreacion,
    --us.FechaModificacion AS RelacionFechaModificacion,
    --us.UsuarioModificacion AS RelacionUsuarioModificacion

FROM SIS.Usuario u
INNER JOIN SIS.Empresa e ON u.FKIdEmpresa_SIS = e.PKIdEmpresa
--INNER JOIN SIS.UsuarioSucursal us ON u.PkIdUsuario = us.FKIdUsuario_SIS
--INNER JOIN SIS.Sucursal s ON us.FKIdSucursal_SIS = s.PKIdSucursal
--INNER JOIN SIS.Estados est ON s.FKIdEstado_SIS = est.PKIdEstado
--LEFT JOIN SIS.CatTipoSucursal ct ON s.TipoSucursal = ct.PKIdTipoSucursal
--LEFT JOIN SIS.Departamento d ON us.FKIdDepartamento_SIS = d.PKIdDepartamento
WHERE 
    u.Activo = 1 
    /*AND s.Activo = 1 
    AND us.Activo = 1*/;
GO

-- Permisos
GRANT SELECT ON SIS.VW_UsuarioSucursal TO PUBLIC;
GO

CREATE OR ALTER VIEW SIS.VW_UsuarioSucursal_Simplificada
AS
SELECT 
    -- Usuario
    u.PkIdUsuario,
    u.Nombre + ' ' + u.ApellidoPaterno + ' ' + ISNULL(u.ApellidoMaterno, '') AS UsuarioNombre,
    u.Email,
    u.Iniciales,
    u.Gafete,
    u.PayrollID,
    
    -- Empresa
    u.FKIdEmpresa_SIS AS IdEmpresa,
    e.Nombre AS EmpresaNombre,
    e.Rfc AS EmpresaRfc,
    
    -- Sucursal
    s.PKIdSucursal,
    s.Nombre AS SucursalNombre,
    s.CodigoSucursal,
    s.Alias AS SucursalAlias,
    ct.Descripcion AS TipoSucursal,
    s.Ciudad,
    est.Nombre AS Estado,
    s.EsMatriz,
    s.EsActiva AS SucursalActiva,
    
    -- Departamento
    us.FKIdDepartamento_SIS AS IdDepartamento,
    d.Nombre AS DepartamentoNombre,
    
    -- Accesos
    us.EsGerente,
    us.EsSupervisor,
    us.PuedeAcceder,
    us.PuedeConfigurar,
    us.PuedeOperar,
    us.PuedeReportes,
    
    -- Fechas
    us.FechaAsignacion,
    us.FechaFinAsignacion,
    
    -- Estado de la relación
    us.Activo AS RelacionActiva

FROM SIS.Usuario u
INNER JOIN SIS.Empresa e ON u.FKIdEmpresa_SIS = e.PKIdEmpresa
INNER JOIN SIS.UsuarioSucursal us ON u.PkIdUsuario = us.FKIdUsuario_SIS
INNER JOIN SIS.Sucursal s ON us.FKIdSucursal_SIS = s.PKIdSucursal
INNER JOIN SIS.Estados est ON s.FKIdEstado_SIS = est.PKIdEstado
LEFT JOIN SIS.CatTipoSucursal ct ON s.TipoSucursal = ct.PKIdTipoSucursal
LEFT JOIN SIS.Departamento d ON us.FKIdDepartamento_SIS = d.PKIdDepartamento
WHERE 
    u.Activo = 1 
    AND s.Activo = 1 
    AND us.Activo = 1;
GO

GRANT SELECT ON SIS.VW_UsuarioSucursal_Simplificada TO PUBLIC;
GO

-- Vista principal
CREATE OR ALTER VIEW SIS.vw_Menu AS
WITH MenuJerarquico AS (
    SELECT 
        m.PKIdMenu,
        m.Nombre,
        m.Tipo,
        -- Descripción del tipo
        CASE m.Tipo
            WHEN 1 THEN 'Contenedor (tiene submenús)'
            WHEN 2 THEN 'Item final'
            ELSE 'Desconocido'
        END AS TipoDescripcion,
        m.FKIdMenu_SIS,
        -- Nombre del menú padre
        p.Nombre AS NombreMenuPadre,
        -- Tipo del menú padre
        p.Tipo AS TipoMenuPadre,
        CASE p.Tipo
            WHEN 1 THEN 'Contenedor'
            WHEN 2 THEN 'Item final'
            ELSE 'Desconocido'
        END AS TipoMenuPadreDescripcion,
        m.LegacyName,
        m.Ruta,
        m.ImageUrl,
        m.Lenguaje,
        m.Orden,
        m.Activo,
        -- Estado del menú
        CASE m.Activo
            WHEN 1 THEN 'Activo'
            ELSE 'Inactivo'
        END AS Estado,
        m.CreatedByOperatorId,
        m.CreatedDateTime,
        m.ModifiedByOperatorId,
        m.ModifiedDateTime,
        -- Nivel jerárquico
        CASE 
            WHEN m.FKIdMenu_SIS IS NULL THEN 0
            ELSE 1
        END AS NivelJerarquico,
        -- Ruta completa del menú (para breadcrumbs)
        CASE 
            WHEN m.FKIdMenu_SIS IS NOT NULL AND p.Nombre IS NOT NULL 
                THEN p.Nombre + ' > ' + m.Nombre
            ELSE m.Nombre
        END AS RutaCompleta,
        -- Indicador si tiene submenús (solo aplica para Tipo=1)
        CASE 
            WHEN m.Tipo = 1 AND EXISTS (SELECT 1 FROM SIS.Menu h WHERE h.FKIdMenu_SIS = m.PKIdMenu) 
            THEN 1 
            ELSE 0 
        END AS TieneSubmenus,
        -- Validación de consistencia
        CASE 
            WHEN m.Tipo = 2 AND EXISTS (SELECT 1 FROM SIS.Menu h WHERE h.FKIdMenu_SIS = m.PKIdMenu) 
            THEN 'INCONSISTENCIA: Item final tiene submenús'
            WHEN m.Tipo = 1 AND m.Ruta IS NOT NULL AND EXISTS (SELECT 1 FROM SIS.Menu h WHERE h.FKIdMenu_SIS = m.PKIdMenu) 
            THEN 'INCONSISTENCIA: Contenedor con ruta y submenús'
            ELSE 'OK'
        END AS ValidacionEstructura
    FROM SIS.Menu m
    LEFT JOIN SIS.Menu p ON m.FKIdMenu_SIS = p.PKIdMenu
)
SELECT 
    PKIdMenu,
    Nombre,
    Tipo,
    TipoDescripcion,
    FKIdMenu_SIS,
    NombreMenuPadre,
    TipoMenuPadre,
    TipoMenuPadreDescripcion,
    LegacyName,
    Ruta,
    ImageUrl,
    Lenguaje,
    Orden,
    Activo,
    Estado,
    CreatedByOperatorId,
    CreatedDateTime,
    ModifiedByOperatorId,
    ModifiedDateTime,
    NivelJerarquico,
    RutaCompleta,
    TieneSubmenus,
    ValidacionEstructura
FROM MenuJerarquico;
GO