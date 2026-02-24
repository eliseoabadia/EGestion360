/*Vistas*/
CREATE OR ALTER VIEW  [SIS].[VW_EmpresaDepartamanto]
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


CREATE OR ALTER VIEW  [SIS].[VW_EstadoEmpresa]
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


CREATE OR ALTER VIEW SIS.VW_UsuarioEmpresa
AS
WITH SucursalesResumen AS (
    -- Acceso directo por UsuarioSucursal
    SELECT 
        us.FKIdUsuario_SIS AS IdUsuario,
        STRING_AGG(s.Nombre, ', ') WITHIN GROUP (ORDER BY s.Nombre) AS SucursalesDirectas,
        COUNT(DISTINCT s.PKIdSucursal) AS TotalSucursalesDirectas,
        SUM(CASE WHEN us.EsGerente = 1 THEN 1 ELSE 0 END) AS TotalGerente,
        SUM(CASE WHEN us.EsSupervisor = 1 THEN 1 ELSE 0 END) AS TotalSupervisor,
        MAX(CASE WHEN s.EsMatriz = 1 THEN s.Nombre ELSE NULL END) AS SucursalMatriz
    FROM SIS.UsuarioSucursal us
    INNER JOIN SIS.Sucursal s ON us.FKIdSucursal_SIS = s.PKIdSucursal
    WHERE us.Activo = 1 AND s.Activo = 1 AND us.PuedeAcceder = 1
    GROUP BY us.FKIdUsuario_SIS
    
    UNION ALL
    
    -- Acceso por Departamento
    SELECT 
        ud.FKIdUsuario_SIS AS IdUsuario,
        STRING_AGG(s.Nombre, ', ') WITHIN GROUP (ORDER BY s.Nombre) AS SucursalesDirectas,
        COUNT(DISTINCT s.PKIdSucursal) AS TotalSucursalesDirectas,
        0 AS TotalGerente,
        0 AS TotalSupervisor,
        MAX(CASE WHEN s.EsMatriz = 1 THEN s.Nombre ELSE NULL END) AS SucursalMatriz
    FROM SIS.UsuarioDepartamento ud
    INNER JOIN SIS.Departamento d ON ud.FKIdDepartamento_SIS = d.PKIdDepartamento
    INNER JOIN SIS.Sucursal s ON d.FKIdSucursal_SIS = s.PKIdSucursal
    WHERE ud.Activo = 1 AND d.Activo = 1 AND s.Activo = 1
    GROUP BY ud.FKIdUsuario_SIS
),
SucursalesConsolidadas AS (
    SELECT 
        IdUsuario,
        STRING_AGG(SucursalesDirectas, ', ') AS ListaSucursales,
        SUM(TotalSucursalesDirectas) AS TotalSucursales,
        MAX(TotalGerente) AS EsGerente,
        MAX(TotalSupervisor) AS EsSupervisor,
        MAX(SucursalMatriz) AS SucursalMatrizAsignada
    FROM SucursalesResumen
    GROUP BY IdUsuario
)
SELECT 
    -- Datos del Usuario
    u.PkIdUsuario,
    u.AspNetUserId,
    u.FKIdEmpresa_SIS AS IdEmpresa,
    u.Nombre + ' ' + u.ApellidoPaterno + ' ' + ISNULL(u.ApellidoMaterno, '') AS NombreCompleto,
    u.Nombre AS Nombre,
    u.ApellidoPaterno,
    u.ApellidoMaterno,
    u.Iniciales,
    u.PayrollID,
    --u.NombreLogin,
    u.CodigoPostal AS CodigoPostalUsuario,
    u.Telefono AS TelefonoUsuario,
    u.Direccion1,
    u.Direccion2,
    u.Email,
    u.NumeroSocial,
    u.Gafete,
    CASE WHEN u.Sexo = 1 THEN 'Masculino' ELSE 'Femenino' END AS SexoDescripcion,
    u.Sexo,
    u.FechaIngreso,
    FORMAT(u.FechaIngreso, 'dd/MM/yyyy') AS FechaIngresoFormat,
    DATEDIFF(YEAR, u.FechaIngreso, GETDATE()) AS AntigüedadAños,
    u.FKIdIdiomaPreferido_SIS AS IdIdiomaPreferido,
    i.Nombre AS IdiomaPreferido,
    u.FKIdMonedaPreferida_SIS AS IdMonedaPreferida,
    m.Nombre AS MonedaPreferida,
    m.Simbolo AS SimboloMoneda,
    u.EsAdministrador,
    u.Activo AS UsuarioActivo,
    u.FechaCreacion AS UsuarioFechaCreacion,
    FORMAT(u.FechaCreacion, 'dd/MM/yyyy HH:mm') AS UsuarioFechaCreacionFormat,
    u.UsuarioCreacion AS UsuarioCreadorId,
    
    -- Datos de Empresa
    e.PKIdEmpresa,
    e.Nombre AS NombreEmpresa,
    e.RFC AS RfcEmpresa,
    e.RazonSocial AS RazonSocialEmpresa,
    e.Giro AS GiroEmpresa,
    e.FKIdMonedaBase_SIS AS IdMonedaBaseEmpresa,
    mb.Nombre AS MonedaBaseEmpresa,
    mb.Simbolo AS SimboloMonedaBase,
    e.Activo AS EmpresaActiva,
    e.FechaCreacion AS EmpresaFechaCreacion,
    
    -- Resumen de Departamentos
    (
        SELECT STRING_AGG(d.Nombre, ', ') 
        FROM SIS.UsuarioDepartamento ud2
        INNER JOIN SIS.Departamento d ON ud2.FKIdDepartamento_SIS = d.PKIdDepartamento
        WHERE ud2.FKIdUsuario_SIS = u.PkIdUsuario AND ud2.Activo = 1 AND d.Activo = 1
    ) AS ListaDepartamentos,
    
    (
        SELECT COUNT(DISTINCT d2.PKIdDepartamento)
        FROM SIS.UsuarioDepartamento ud2
        INNER JOIN SIS.Departamento d2 ON ud2.FKIdDepartamento_SIS = d2.PKIdDepartamento
        WHERE ud2.FKIdUsuario_SIS = u.PkIdUsuario AND ud2.Activo = 1 AND d2.Activo = 1
    ) AS TotalDepartamentos,
    
    -- Indicadores de jefatura
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM SIS.UsuarioDepartamento ud3
            WHERE ud3.FKIdUsuario_SIS = u.PkIdUsuario AND ud3.EsJefe = 1 AND ud3.Activo = 1
        ) THEN 1 ELSE 0 
    END AS EsJefeAlgunDepartamento,
    
    (
        SELECT STRING_AGG(d4.Nombre, ', ')
        FROM SIS.UsuarioDepartamento ud4
        INNER JOIN SIS.Departamento d4 ON ud4.FKIdDepartamento_SIS = d4.PKIdDepartamento
        WHERE ud4.FKIdUsuario_SIS = u.PkIdUsuario AND ud4.EsJefe = 1 AND ud4.Activo = 1
    ) AS DepartamentosComoJefe,
    
    -- Resumen de Sucursales (consolidado)
    sc.ListaSucursales,
    ISNULL(sc.TotalSucursales, 0) AS TotalSucursales,
    sc.SucursalMatrizAsignada,
    
    -- Indicadores de rol
    CASE 
        WHEN u.EsAdministrador = 1 THEN 'Administrador Global'
        WHEN sc.EsGerente = 1 THEN 'Gerente de Sucursal'
        WHEN sc.EsSupervisor = 1 THEN 'Supervisor'
        WHEN EXISTS (
            SELECT 1 FROM SIS.UsuarioDepartamento ud5
            WHERE ud5.FKIdUsuario_SIS = u.PkIdUsuario AND ud5.EsJefe = 1 AND ud5.Activo = 1
        ) THEN 'Jefe de Departamento'
        ELSE 'Empleado'
    END AS RolPrincipal,
    
    -- Metadatos adicionales
    CASE 
        WHEN sc.TotalSucursales > 5 THEN 'Multi-sucursal'
        WHEN sc.TotalSucursales > 1 THEN 'Varias sucursales'
        WHEN sc.TotalSucursales = 1 THEN 'Una sucursal'
        ELSE 'Sin sucursal'
    END AS CoberturaSucursales,
    
    -- Fecha del último acceso (si tuvieras una tabla de auditoría)
    NULL AS UltimoAcceso,
    
    -- Para ordenamiento y filtros
    u.PayrollID AS NumeroEmpleado,
    UPPER(LEFT(u.Nombre, 1) + LEFT(u.ApellidoPaterno, 1)) AS InicialesNombre

FROM SIS.Usuario u

-- Relación con Empresa
INNER JOIN SIS.Empresa e ON u.FKIdEmpresa_SIS = e.PKIdEmpresa

-- Moneda base de la empresa
LEFT JOIN SIS.Moneda mb ON e.FKIdMonedaBase_SIS = mb.PKIdMoneda

-- Preferencias de idioma y moneda
LEFT JOIN SIS.Idioma i ON u.FKIdIdiomaPreferido_SIS = i.PKIdIdioma
LEFT JOIN SIS.Moneda m ON u.FKIdMonedaPreferida_SIS = m.PKIdMoneda

-- Sucursales consolidadas
LEFT JOIN SucursalesConsolidadas sc ON u.PkIdUsuario = sc.IdUsuario

WHERE u.Activo = 1;
GO