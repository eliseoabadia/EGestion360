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

CREATE OR ALTER VIEW [SIS].[VW_SucursalEmpresaEstado]
AS
SELECT 
    s.PKIdSucursal,
    s.FKIdEmpresa_SIS,
    s.FKIdEstado_SIS,
    s.Nombre,
    s.CodigoSucursal,
    s.Alias,
    s.FKIdTipoSucursal,
    s.FKIdMonedaLocal_SIS,
    s.Direccion,
    s.Colonia,
    s.Ciudad,
    s.CodigoPostal,
    s.TelefonoPrincipal,
    s.TelefonoSecundario,
    s.Email,
    s.HorarioApertura,
    s.HorarioCierre,
    s.EsMatriz,
    s.EsActiva,
    s.Latitud,
    s.Longitud,
    -- Información adicional de la empresa
    e.Nombre AS NombreEmpresa,
    e.RFC,
    -- Información del estado
    est.Nombre AS NombreEstado,
    est.CodigoEstado,
    p.Nombre AS NombrePais
FROM [SIS].Sucursal s WITH (NOLOCK)
INNER JOIN [SIS].Empresa e WITH (NOLOCK) 
    ON s.FKIdEmpresa_SIS = e.PKIdEmpresa 
    AND e.Activo = 1
INNER JOIN [SIS].Estados est WITH (NOLOCK) 
    ON s.FKIdEstado_SIS = est.PKIdEstado 
    AND est.Activo = 1
INNER JOIN [SIS].Paises p WITH (NOLOCK) 
    ON est.FKIdPais_SIS = p.PKIdPais 
    AND p.Activo = 1
WHERE s.Activo = 1;
GO

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




-- =============================================
-- VISTA: VwUsuarioSucursal
-- Descripción: Vista completa de usuarios con sus sucursales asignadas y permisos
-- =============================================
CREATE OR ALTER VIEW SIS.Vw_UsuarioSucursal
AS
SELECT 
    -- Datos del Usuario
    u.PkIdUsuario,
    u.AspNetUserId,
    u.FKIdEmpresa_SIS AS IdEmpresa,
    u.Nombre,
    u.ApellidoPaterno,
    u.ApellidoMaterno,
    CONCAT(u.Nombre, ' ', u.ApellidoPaterno, ' ', ISNULL(u.ApellidoMaterno, '')) AS NombreCompleto,
    u.Iniciales,
    UPPER(LEFT(u.Nombre, 1) + LEFT(u.ApellidoPaterno, 1)) AS InicialesNombre,
    u.PayrollID AS PayrollId,
    u.CodigoPostal AS CodigoPostalUsuario,
    u.Telefono AS TelefonoUsuario,
    u.Direccion1,
    u.Direccion2,
    u.Email,
    u.NumeroSocial,
    u.Gafete,
    u.Sexo,
    CASE WHEN u.Sexo = 1 THEN 'Masculino' ELSE 'Femenino' END AS SexoDescripcion,
    u.FechaIngreso,
    FORMAT(u.FechaIngreso, 'dd/MM/yyyy') AS FechaIngresoFormat,
    DATEDIFF(YEAR, u.FechaIngreso, GETDATE()) AS AntigüedadAños,
    
    -- Idioma preferido
    u.FKIdIdiomaPreferido_SIS AS IdIdiomaPreferido,
    i.Nombre AS IdiomaPreferido,
    
    -- Moneda preferida
    u.FKIdMonedaPreferida_SIS AS IdMonedaPreferida,
    m.Nombre AS MonedaPreferida,
    m.Simbolo AS SimboloMoneda,
    
    -- Datos de usuario
    u.EsAdministrador,
    u.Activo AS UsuarioActivo,
    --u.FechaCreacion AS UsuarioFechaCreacion,
    --FORMAT(u.FechaCreacion, 'dd/MM/yyyy HH:mm') AS UsuarioFechaCreacionFormat,
    --u.UsuarioCreacion AS UsuarioCreadorId,
    --u.FechaModificacion AS UsuarioFechaModificacion,
    --u.UsuarioModificacion,
    
    -- Datos de la Empresa
    e.PKIdEmpresa AS PkidEmpresa,
    e.Nombre AS NombreEmpresa,
    e.RFC AS RfcEmpresa,
    e.RazonSocial AS RazonSocialEmpresa,
    e.Giro AS GiroEmpresa,
    e.FKIdMonedaBase_SIS AS IdMonedaBaseEmpresa,
    mb.Nombre AS MonedaBaseEmpresa,
    mb.Simbolo AS SimboloMonedaBase,
    --e.Activa AS EmpresaActiva,
    e.FechaCreacion AS EmpresaFechaCreacion,
    
    -- Datos de la Sucursal asignada
    s.PKIdSucursal AS IdSucursal,
    s.Nombre AS NombreSucursal,
    s.CodigoSucursal,
    s.Direccion AS DireccionSucursal,
    --s.Telefono AS TelefonoSucursal,
    s.EsMatriz,
    --s.Activa AS SucursalActiva,
    
    -- Permisos específicos de la asignación
    us.PuedeAcceder,
    us.PuedeConfigurar,
    us.PuedeOperar,
    us.PuedeReportes,
    us.EsGerente,
    us.EsSupervisor,
    --us.FechaAsignacion,
    --FORMAT(us.FechaAsignacion, 'dd/MM/yyyy') AS FechaAsignacionFormat,
    --us.FechaFinAsignacion,
    --FORMAT(us.FechaFinAsignacion, 'dd/MM/yyyy') AS FechaFinAsignacionFormat,
    us.Activo AS AsignacionActiva,
    
    ---- Indicadores adicionales
    --CASE 
    --    WHEN us.EsGerente = 1 THEN 'Gerente'
    --    WHEN us.EsSupervisor = 1 THEN 'Supervisor'
    --    ELSE 'Empleado'
    --END AS RolEnSucursal,
    
    --CASE 
    --    WHEN us.FechaFinAsignacion IS NOT NULL AND us.FechaFinAsignacion < GETDATE() THEN 'Vencida'
    --    WHEN us.Activo = 0 THEN 'Inactiva'
    --    ELSE 'Activa'
    --END AS EstadoAsignacion,
    
    ---- Conteo de departamentos en esta sucursal donde participa
    --(
    --    SELECT COUNT(DISTINCT ud.FKIdDepartamento_SIS)
    --    FROM SIS.UsuarioDepartamento ud
    --    INNER JOIN SIS.Departamento d ON ud.FKIdDepartamento_SIS = d.PKIdDepartamento
    --    WHERE ud.FKIdUsuario_SIS = u.PkIdUsuario
    --    AND d.FKIdSucursal_SIS = s.PKIdSucursal
    --    AND ud.Activo = 1
    --    AND (ud.FechaFinAsignacion IS NULL OR ud.FechaFinAsignacion >= GETDATE())
    --) AS TotalDepartamentosEnSucursal,
    
    ---- Lista de departamentos en esta sucursal
    --STUFF((
    --    SELECT ', ' + d.Nombre
    --    FROM SIS.UsuarioDepartamento ud
    --    INNER JOIN SIS.Departamento d ON ud.FKIdDepartamento_SIS = d.PKIdDepartamento
    --    WHERE ud.FKIdUsuario_SIS = u.PkIdUsuario
    --    AND d.FKIdSucursal_SIS = s.PKIdSucursal
    --    AND ud.Activo = 1
    --    AND (ud.FechaFinAsignacion IS NULL OR ud.FechaFinAsignacion >= GETDATE())
    --    FOR XML PATH('')
    --), 1, 2, '') AS DepartamentosEnSucursal,
    
    -- Indicador de si es jefe en algún departamento de esta sucursal
    CASE 
        WHEN EXISTS (
            SELECT 1
            FROM SIS.UsuarioDepartamento ud
            INNER JOIN SIS.Departamento d ON ud.FKIdDepartamento_SIS = d.PKIdDepartamento
            WHERE ud.FKIdUsuario_SIS = u.PkIdUsuario
            AND d.FKIdSucursal_SIS = s.PKIdSucursal
            AND ud.EsJefe = 1
            AND ud.Activo = 1
            AND (ud.FechaFinAsignacion IS NULL OR ud.FechaFinAsignacion >= GETDATE())
        ) THEN 1 ELSE 0 
    END AS EsJefeEnSucursal

FROM SIS.Usuario u
INNER JOIN SIS.Empresa e ON u.FKIdEmpresa_SIS = e.PKIdEmpresa
LEFT JOIN SIS.Idioma i ON u.FKIdIdiomaPreferido_SIS = i.PKIdIdioma
LEFT JOIN SIS.Moneda m ON u.FKIdMonedaPreferida_SIS = m.PKIdMoneda
LEFT JOIN SIS.Moneda mb ON e.FKIdMonedaBase_SIS = mb.PKIdMoneda
INNER JOIN SIS.UsuarioSucursal us ON u.PkIdUsuario = us.FKIdUsuario_SIS
INNER JOIN SIS.Sucursal s ON us.FKIdSucursal_SIS = s.PKIdSucursal
WHERE us.Activo = 1 
  AND (us.FechaFinAsignacion IS NULL OR us.FechaFinAsignacion >= GETDATE())
  AND u.Activo = 1;



-- =============================================
-- VISTA: ALMA.VistaPeriodoConteo
-- Descripción: Vista completa para Periodos de Conteo
-- =============================================

CREATE OR ALTER VIEW ALMA.Vw_PeriodoConteo
AS
SELECT 
    pc.PKIdPeriodoConteo AS Id,
    pc.FKIdSucursal_SIS AS SucursalId,
    s.Nombre AS SucursalNombre,
    pc.FKIdTipoConteo_ALMA AS TipoConteoId,
    tc.Nombre AS TipoConteoNombre,
    pc.FKIdEstatus_ALMA AS EstatusId,
    ep.Nombre AS EstatusNombre,
    pc.CodigoPeriodo,
    pc.Nombre,
    pc.Descripcion,
    pc.FechaInicio,
    pc.FechaFin,
    pc.FechaCierre,
    pc.MaximoConteosPorArticulo,
    pc.RequiereAprobacionSupervisor,
    pc.FKIdResponsable_SIS AS ResponsableId,
    CONCAT(r.Nombre, ' ', r.ApellidoPaterno) AS ResponsableNombre,
    pc.FKIdSupervisor_SIS AS SupervisorId,
    CONCAT(sv.Nombre, ' ', sv.ApellidoPaterno) AS SupervisorNombre,
    pc.TotalArticulos,
    pc.ArticulosConcluidos,
    pc.ArticulosConDiferencia,
    -- Campos calculados
    (pc.TotalArticulos - pc.ArticulosConcluidos) AS ArticulosPendientes,
    CASE 
        WHEN pc.TotalArticulos > 0 
        THEN CAST((CAST(pc.ArticulosConcluidos AS DECIMAL(10,2)) / pc.TotalArticulos * 100) AS DECIMAL(5,2))
        ELSE 0 
    END AS PorcentajeAvance,
    -- Fechas de auditoría
    pc.Activo,
    pc.FechaCreacion,
    uCreacion.Nombre + ' ' + uCreacion.ApellidoPaterno AS UsuarioCreacionNombre,
    pc.FechaModificacion,
    uModificacion.Nombre + ' ' + uModificacion.ApellidoPaterno AS UsuarioModificacionNombre
FROM ALMA.PeriodoConteo pc
INNER JOIN SIS.Sucursal s ON pc.FKIdSucursal_SIS = s.PKIdSucursal
INNER JOIN ALMA.TipoConteo tc ON pc.FKIdTipoConteo_ALMA = tc.PKIdTipoConteo
INNER JOIN ALMA.EstatusPeriodo ep ON pc.FKIdEstatus_ALMA = ep.PKIdEstatusPeriodo
LEFT JOIN SIS.Usuario r ON pc.FKIdResponsable_SIS = r.PkIdUsuario
LEFT JOIN SIS.Usuario sv ON pc.FKIdSupervisor_SIS = sv.PkIdUsuario
LEFT JOIN SIS.Usuario uCreacion ON pc.UsuarioCreacion = uCreacion.PkIdUsuario
LEFT JOIN SIS.Usuario uModificacion ON pc.UsuarioModificacion = uModificacion.PkIdUsuario
WHERE pc.Activo = 1
GO


-- =============================================
-- VISTA: ALMA.VistaArticuloConteo
-- Descripción: Vista completa para Artículos en Conteo
-- =============================================

-- =============================================
-- VISTA CORREGIDA: ALMA.VistaArticuloConteo
-- Basada en la estructura real de tablas
-- =============================================

CREATE OR ALTER VIEW ALMA.Vw_ArticuloConteo
AS
SELECT 
    ac.PKIdArticuloConteo AS Id,
    ac.FKIdPeriodoConteo_ALMA AS PeriodoId,
    pc.CodigoPeriodo,
    pc.Nombre AS PeriodoNombre,
    ac.FKIdTipoBien_ALMA AS TipoBienId,
    tb.CodigoClave AS CodigoArticulo,
    tb.Descripcion AS DescripcionArticulo,
    ac.FKIdSucursal_SIS AS SucursalId,
    s.Nombre AS SucursalNombre,
    ac.FKIdEstatus_ALMA AS EstatusId,
    eac.Nombre AS EstatusNombre,
    eac.Descripcion AS EstatusDescripcion,
    ac.CodigoBarras,
    -- UnidadMedida no existe en TipoBien, lo omitimos
    -- Si existe en otra tabla, habría que agregarlo con JOIN
    ac.Ubicacion,
    
    -- Información del sistema
    ac.ExistenciaSistema,
    ac.ExistenciaFinal,
    ac.Diferencia,
    ac.PorcentajeDiferencia,
    -- FechaUltimoConteoAnterior no existe, lo omitimos
    NULL AS FechaUltimoConteoAnterior,
    
    -- Control de conteos
    ac.ConteosRealizados,
    ac.ConteosPendientes,
    pc.MaximoConteosPorArticulo,
    (pc.MaximoConteosPorArticulo - ac.ConteosRealizados) AS ConteosRestantes,
    
    -- Flags de estado - Usamos los campos que existen en la tabla
    -- En lugar de EstaConcluido, usamos ConteosPendientes = 0 como indicador
    CASE WHEN ac.ConteosPendientes = 0 THEN 1 ELSE 0 END AS EstaConcluido,
    CASE WHEN ac.ConteosPendientes = 0 THEN 'Sí' ELSE 'No' END AS EstaConcluidoTexto,
    
    -- RequiereTercerConteo no existe, lo calculamos
    CASE 
        WHEN ac.ConteosRealizados = 2 AND ac.ConteosPendientes = 1 THEN 1 
        ELSE 0 
    END AS RequiereTercerConteo,
    
    -- Fechas importantes
    ac.FechaInicioConteo,
    ac.FechaConclusion,
    ac.FKIdUsuarioConcluyo_SIS AS UsuarioConcluyoId,
    CONCAT(uConcluye.Nombre, ' ', uConcluye.ApellidoPaterno) AS UsuarioConcluyoNombre,
    
    -- Información de la discrepancia (si existe)
    d.PKIdDiscrepancia AS DiscrepanciaId,
    d.Valor1 AS DiscrepanciaValor1,
    d.Valor2 AS DiscrepanciaValor2,
    d.Valor3 AS DiscrepanciaValor3,
    d.ValorAceptado AS DiscrepanciaValorAceptado,
    d.MetodoResolucion AS DiscrepanciaMetodo,
    CASE WHEN d.ValorAceptado IS NULL AND d.PKIdDiscrepancia IS NOT NULL THEN 1 ELSE 0 END AS TieneDiscrepanciaPendiente,
    
    -- Resumen de conteos realizados
    (
        SELECT STRING_AGG(
            CONCAT('Conteo ', r.NumeroConteo, ': ', r.CantidadContada, ' (', 
                   CONCAT(u.Nombre, ' ', u.ApellidoPaterno), ')'), 
            ' | ')
        FROM ALMA.RegistroConteo r
        INNER JOIN SIS.Usuario u ON r.FKIdUsuario_SIS = u.PkIdUsuario
        WHERE r.FKIdArticuloConteo_ALMA = ac.PKIdArticuloConteo
        AND r.Activo = 1
    ) AS HistorialConteosTexto,
    
    -- Último conteo realizado
    (
        SELECT TOP 1 CantidadContada
        FROM ALMA.RegistroConteo r
        WHERE r.FKIdArticuloConteo_ALMA = ac.PKIdArticuloConteo
        AND r.Activo = 1
        ORDER BY r.NumeroConteo DESC
    ) AS UltimoConteo,
    
    -- Primer conteo
    (
        SELECT TOP 1 CantidadContada
        FROM ALMA.RegistroConteo r
        WHERE r.FKIdArticuloConteo_ALMA = ac.PKIdArticuloConteo
        AND r.Activo = 1
        ORDER BY r.NumeroConteo ASC
    ) AS PrimerConteo,
    
    -- Segundo conteo (si existe)
    (
        SELECT CantidadContada
        FROM ALMA.RegistroConteo r
        WHERE r.FKIdArticuloConteo_ALMA = ac.PKIdArticuloConteo
        AND r.NumeroConteo = 2
        AND r.Activo = 1
    ) AS SegundoConteo,
    
    -- Tercer conteo (si existe)
    (
        SELECT CantidadContada
        FROM ALMA.RegistroConteo r
        WHERE r.FKIdArticuloConteo_ALMA = ac.PKIdArticuloConteo
        AND r.NumeroConteo = 3
        AND r.Activo = 1
    ) AS TercerConteo,
    
    -- Conteos por usuario (JSON para frontend)
    (
        SELECT 
            r.NumeroConteo,
            r.CantidadContada,
            r.FechaConteo,
            u.PkIdUsuario AS UsuarioId,
            CONCAT(u.Nombre, ' ', u.ApellidoPaterno) AS UsuarioNombre,
            r.Observaciones
        FROM ALMA.RegistroConteo r
        INNER JOIN SIS.Usuario u ON r.FKIdUsuario_SIS = u.PkIdUsuario
        WHERE r.FKIdArticuloConteo_ALMA = ac.PKIdArticuloConteo
        AND r.Activo = 1
        ORDER BY r.NumeroConteo
        FOR JSON PATH
    ) AS ConteosJSON,
    
    -- Colores e iconos para UI
    CASE eac.Nombre
        WHEN 'Pendiente 1er Conteo' THEN 'error'
        WHEN 'Pendiente 2do Conteo' THEN 'warning'
        WHEN 'Pendiente 3er Conteo' THEN 'warning'
        WHEN 'Concluido Sin Diferencia' THEN 'success'
        WHEN 'Concluido Con Diferencia' THEN 'info'
        WHEN 'En Discrepancia' THEN 'error'
        ELSE 'default'
    END AS ColorEstatus,
    
    CASE eac.Nombre
        WHEN 'Pendiente 1er Conteo' THEN '⏳'
        WHEN 'Pendiente 2do Conteo' THEN '🔄'
        WHEN 'Pendiente 3er Conteo' THEN '⚠️'
        WHEN 'Concluido Sin Diferencia' THEN '✅'
        WHEN 'Concluido Con Diferencia' THEN '⚠️✅'
        WHEN 'En Discrepancia' THEN '❌'
        ELSE '📦'
    END AS IconoEstatus,
    
    -- Badge para UI
    CASE 
        WHEN ac.ConteosPendientes = 0 AND ac.Diferencia = 0 THEN 'Coincide'
        WHEN ac.ConteosPendientes = 0 AND ac.Diferencia != 0 THEN 'Con diferencia'
        WHEN ac.ConteosRealizados = 2 AND ac.ConteosPendientes = 1 THEN 'Requiere 3er conteo'
        WHEN ac.ConteosRealizados = 0 THEN 'Sin iniciar'
        WHEN ac.ConteosRealizados = 1 THEN '1er conteo listo'
        WHEN ac.ConteosRealizados = 2 THEN '2do conteo listo'
        ELSE eac.Nombre
    END AS BadgeTexto,
    
    -- Auditoría
    ac.Activo,
    ac.FechaCreacion,
    CONCAT(uCreacion.Nombre, ' ', uCreacion.ApellidoPaterno) AS UsuarioCreacionNombre,
    ac.FechaModificacion,
    CONCAT(uModificacion.Nombre, ' ', uModificacion.ApellidoPaterno) AS UsuarioModificacionNombre
    
FROM ALMA.ArticuloConteo ac
INNER JOIN ALMA.PeriodoConteo pc ON ac.FKIdPeriodoConteo_ALMA = pc.PKIdPeriodoConteo
INNER JOIN ALMA.TipoBien tb ON ac.FKIdTipoBien_ALMA = tb.PKIdTipoBien
INNER JOIN SIS.Sucursal s ON ac.FKIdSucursal_SIS = s.PKIdSucursal
INNER JOIN ALMA.EstatusArticuloConteo eac ON ac.FKIdEstatus_ALMA = eac.PKIdEstatusArticulo
LEFT JOIN ALMA.DiscrepanciaConteo d ON ac.PKIdArticuloConteo = d.FKIdArticuloConteo_ALMA
LEFT JOIN SIS.Usuario uConcluye ON ac.FKIdUsuarioConcluyo_SIS = uConcluye.PkIdUsuario
LEFT JOIN SIS.Usuario uCreacion ON ac.UsuarioCreacion = uCreacion.PkIdUsuario
LEFT JOIN SIS.Usuario uModificacion ON ac.UsuarioModificacion = uModificacion.PkIdUsuario
WHERE ac.Activo = 1
GO

-- =============================================
-- VISTA: ALMA.VistaRegistroConteo
-- Descripción: Vista completa para Registros de Conteo
-- =============================================

-- =============================================
-- VISTA CORREGIDA: ALMA.VistaRegistroConteo
-- Descripción: Vista completa para Registros de Conteo
-- SIN la columna UsuarioCreacion que no existe
-- =============================================

CREATE OR ALTER VIEW ALMA.Vw_RegistroConteo
AS
SELECT 
    rc.PKIdRegistroConteo AS Id,
    rc.FKIdArticuloConteo_ALMA AS ArticuloConteoId,
    rc.FKIdPeriodoConteo_ALMA AS PeriodoId,
    rc.FKIdSucursal_SIS AS SucursalId,
    
    -- Información del período
    pc.CodigoPeriodo,
    pc.Nombre AS PeriodoNombre,
    
    -- Información de la sucursal
    s.Nombre AS SucursalNombre,
    
    -- Información del artículo
    ac.FKIdTipoBien_ALMA AS TipoBienId,
    tb.CodigoClave AS CodigoArticulo,
    tb.Descripcion AS DescripcionArticulo,
    ac.ExistenciaSistema,
    
    -- Información del conteo
    rc.NumeroConteo,
    rc.CantidadContada,
    rc.FechaConteo,
    rc.Observaciones,
    rc.EsReconteo,
    rc.FotoPath,
    rc.Latitud,
    rc.Longitud,
    
    -- Información del usuario que realizó el conteo
    rc.FKIdUsuario_SIS AS UsuarioId,
    CONCAT(u.Nombre, ' ', u.ApellidoPaterno, ISNULL(' ' + u.ApellidoMaterno, '')) AS UsuarioNombre,
    u.Email AS UsuarioEmail,
    u.Iniciales AS UsuarioIniciales,
    
    -- Comparación con otros conteos del mismo artículo
    (
        SELECT AVG(CantidadContada)
        FROM ALMA.RegistroConteo r
        WHERE r.FKIdArticuloConteo_ALMA = rc.FKIdArticuloConteo_ALMA
        AND r.Activo = 1
    ) AS PromedioConteos,
    
    -- Diferencia vs existencia del sistema
    (rc.CantidadContada - ac.ExistenciaSistema) AS DiferenciaVsSistema,
    
    -- Porcentaje de diferencia vs sistema
    CASE 
        WHEN ac.ExistenciaSistema > 0 
        THEN ((rc.CantidadContada - ac.ExistenciaSistema) / ac.ExistenciaSistema * 100)
        ELSE 0
    END AS PorcentajeVsSistema,
    
    -- Indicadores para UI
    CASE 
        WHEN rc.NumeroConteo = 1 THEN 'Primer conteo'
        WHEN rc.NumeroConteo = 2 THEN 'Segundo conteo'
        WHEN rc.NumeroConteo = 3 THEN 'Tercer conteo'
        ELSE 'Conteo ' + CAST(rc.NumeroConteo AS NVARCHAR)
    END AS ConteoDescripcion,
    
    -- Color según el número de conteo
    CASE rc.NumeroConteo
        WHEN 1 THEN 'info'
        WHEN 2 THEN 'warning'
        WHEN 3 THEN 'error'
        ELSE 'default'
    END AS ColorConteo,
    
    -- Icono según el número de conteo
    CASE rc.NumeroConteo
        WHEN 1 THEN '①'
        WHEN 2 THEN '②'
        WHEN 3 THEN '③'
        ELSE CAST(rc.NumeroConteo AS NVARCHAR)
    END AS IconoConteo,
    
    -- ¿Es el último conteo?
    CASE 
        WHEN rc.NumeroConteo = (
            SELECT MAX(r.NumeroConteo)
            FROM ALMA.RegistroConteo r
            WHERE r.FKIdArticuloConteo_ALMA = rc.FKIdArticuloConteo_ALMA
            AND r.Activo = 1
        ) THEN 1
        ELSE 0
    END AS EsUltimoConteo,
    
    -- Auditoría (solo FechaCreacion, que sí existe)
    rc.Activo,
    rc.FechaCreacion
    
FROM ALMA.RegistroConteo rc
INNER JOIN ALMA.PeriodoConteo pc ON rc.FKIdPeriodoConteo_ALMA = pc.PKIdPeriodoConteo
INNER JOIN SIS.Sucursal s ON rc.FKIdSucursal_SIS = s.PKIdSucursal
INNER JOIN ALMA.ArticuloConteo ac ON rc.FKIdArticuloConteo_ALMA = ac.PKIdArticuloConteo
INNER JOIN ALMA.TipoBien tb ON ac.FKIdTipoBien_ALMA = tb.PKIdTipoBien
INNER JOIN SIS.Usuario u ON rc.FKIdUsuario_SIS = u.PkIdUsuario
WHERE rc.Activo = 1
GO

-- ====
CREATE OR ALTER VIEW ALMA.Vw_TipoBienConteo
AS
SELECT 
    tb.PKIdTipoBien,
    tb.CodigoClave AS CodigoArticulo,
    tb.Descripcion AS DescripcionArticulo,
    tb.Activo,
    
    -- Unidades
    u.Descripcion AS UnidadMedida,
    ue.Descripcion AS UnidadEquivalente,
    tb.Cantidad_Equivalente,
    
    -- Clasificación (Familia, Grupo, Nivel)
    f.Descripcion AS Familia,
    gb.Descripcion AS GrupoBien,
    n.Descripcion AS Nivel,
    
    -- Ubicación (si se define)
    -- (Actualmente no hay tabla de localizaciones, se puede agregar después)
    
    -- Datos de partida y cuenta contable
    p.Clave AS PartidaClave,
    p.Descripcion AS PartidaDescripcion,
    cc.Cuenta + '.' + cc.SubCuenta + '.' + cc.SubSubCuenta + '.' + cc.SubSubSubCuenta + '.' + cc.SubSubSubSubCuenta AS CuentaCompleta,
    cc.Descripcion AS CuentaDescripcion,
    tc.Descripcion AS TipoCuenta,  -- 'ACREEDORA' u 'DEUDORA'
    
    -- Parámetros del artículo
    tb.ExistenciaMinima,
    tb.ExistenciaMaxima,
    tb.CABMS,
    tb.CUCOP_PLUS,
    tb.DepreciacionAnual,
    tb.TiempoVida,
    tb.ProveeduriaNac,
    tb.CatalogoBasico,
    
    -- Auditoría
    tb.FechaCreacion,
    tb.UsuarioCreacion
FROM 
    ALMA.TipoBien tb
    INNER JOIN ALMA.GrupoBien gb ON tb.FKIdGrupoBien_ALMA = gb.PKIdGrupoBien
    INNER JOIN ALMA.Familia f ON gb.FKIdFamilia_ALMA = f.PKIdFamilia
    INNER JOIN ALMA.Nivel n ON tb.FKIdNivel_ALMA = n.PKIdNivel
    INNER JOIN CONTA.Partida p ON tb.FKIdPartida_CONTA = p.PKIdPartida
    LEFT JOIN CONTA.CuentaContable cc ON tb.FKIdCuentaContable_CONTA = cc.PKIdCuentaContable
    LEFT JOIN CONTA.TipoCuenta tc ON cc.FKIdTipoCuenta_CONTA = tc.PKIdTipoCuenta
    INNER JOIN ALMA.Unidades u ON tb.FKIdUnidades_ALMA = u.PKIdUnidades
    LEFT JOIN ALMA.Unidades ue ON tb.FKIdUnidades_Equivalente = ue.PKIdUnidades
WHERE 
    tb.Activo = 1
GO

-- =============================================
-- VISTAS PARA REPORTES
-- =============================================

-- Vista de resumen por periodo
GO
CREATE OR ALTER VIEW ALMA.Vw_ResumenPeriodo AS
SELECT 
    p.PKIdPeriodoConteo,
    p.CodigoPeriodo,
    p.Nombre as Periodo,
    s.Nombre as Sucursal,
    tc.Nombre as TipoConteo,
    ep.Nombre as Estatus,
    p.FechaInicio,
    p.FechaFin,
    p.FechaCierre,
    p.TotalArticulos,
    p.ArticulosConcluidos,
    p.ArticulosConDiferencia,
    (p.TotalArticulos - ISNULL(p.ArticulosConcluidos, 0)) as ArticulosPendientes,
    COUNT(DISTINCT r.FKIdUsuario_SIS) as ContadoresParticiparon,
    COUNT(r.PKIdRegistroConteo) as TotalConteosRegistrados
FROM ALMA.PeriodoConteo p
INNER JOIN SIS.Sucursal s ON p.FKIdSucursal_SIS = s.PKIdSucursal
INNER JOIN ALMA.TipoConteo tc ON p.FKIdTipoConteo_ALMA = tc.PKIdTipoConteo
INNER JOIN ALMA.EstatusPeriodo ep ON p.FKIdEstatus_ALMA = ep.PKIdEstatusPeriodo
LEFT JOIN ALMA.RegistroConteo r ON p.PKIdPeriodoConteo = r.FKIdPeriodoConteo_ALMA
GROUP BY p.PKIdPeriodoConteo, p.CodigoPeriodo, p.Nombre, s.Nombre, tc.Nombre, 
         ep.Nombre, p.FechaInicio, p.FechaFin, p.FechaCierre, 
         p.TotalArticulos, p.ArticulosConcluidos, p.ArticulosConDiferencia
GO

-- Vista de detalle de artículos en conteo
CREATE OR ALTER VIEW ALMA.Vw_DetalleArticulos AS
SELECT 
    a.PKIdArticuloConteo,
    p.CodigoPeriodo,
    p.Nombre as Periodo,
    s.Nombre as Sucursal,
    tb.CodigoClave as CodigoArticulo,
    tb.Descripcion as Articulo,
    a.ExistenciaSistema,
    a.ExistenciaFinal,
    a.Diferencia,
    a.PorcentajeDiferencia,
    eac.Nombre as Estatus,
    a.ConteosRealizados,
    a.ConteosPendientes,
    a.FechaInicioConteo,
    a.FechaConclusion,
    u.Nombre + ' ' + u.ApellidoPaterno as ConcluidoPor,
    (SELECT STRING_AGG(CONCAT('Conteo', rc.NumeroConteo, ': ', rc.CantidadContada, ' (', uc.Nombre, ')'), ' | ') 
     FROM ALMA.RegistroConteo rc
     INNER JOIN SIS.Usuario uc ON rc.FKIdUsuario_SIS = uc.PkIdUsuario
     WHERE rc.FKIdArticuloConteo_ALMA = a.PKIdArticuloConteo) as HistorialConteos
FROM ALMA.ArticuloConteo a
INNER JOIN ALMA.PeriodoConteo p ON a.FKIdPeriodoConteo_ALMA = p.PKIdPeriodoConteo
INNER JOIN SIS.Sucursal s ON a.FKIdSucursal_SIS = s.PKIdSucursal
INNER JOIN ALMA.TipoBien tb ON a.FKIdTipoBien_ALMA = tb.PKIdTipoBien
INNER JOIN ALMA.EstatusArticuloConteo eac ON a.FKIdEstatus_ALMA = eac.PKIdEstatusArticulo
LEFT JOIN SIS.Usuario u ON a.FKIdUsuarioConcluyo_SIS = u.PkIdUsuario
WHERE a.Activo = 1
GO


CREATE OR ALTER VIEW ALMA.vw_Bien
AS
SELECT 
    b.PKIdBien,
    b.Clave,
    b.ClaveAnt,
    b.Descripcion,
    b.Modelo,
    b.Serie,
    b.Costo,
    b.FechaAdq,
    b.Factura,
    b.Requisicion,
    b.Referencia,
    b.Notas,
    b.Ubicacion,
    b.AAdquisicion,
    b.Frente,
    b.Fondo,
    b.Altura,
    b.Diametro,
    b.VerificacionesDias,
    b.MantenimientoDias,
    b.Mantenimiento,
    b.Calibracion,
    b.Rango,
    b.Resolucion,
    b.FechaUltInv,
    b.FechaReqscn,
    b.Estatus,
    b.Caracteristicas,
    b.Resguardo,
    b.ResguardoAnterior,
    b.RelId,
    b.ValorRescate,
    b.ValorActual,
    b.Antiguedad,
    b.Progresivo,
    b.Consecutivo,
    b.ClaveHist,
    b.EstaResguardado,
    b.FechaResguardado,
    b.Localizado,
    b.esContabilizado,
    b.Activo,
    b.FechaCreacion,
    b.UsuarioCreacion,
    b.FechaModificacion,
    b.UsuarioModificacion,

    -- Información de GrupoBien
    gb.Descripcion AS GrupoBienDescripcion,
    gb.Clave AS GrupoBienClave,

    -- Información de TipoBien
    tb.CodigoClave AS TipoBienCodigoClave,
    tb.Descripcion AS TipoBienDescripcion,
    tb.CABMS AS TipoBienCABMS,
    tb.Identificador AS TipoBienIdentificador,
    tb.CUCOP_PLUS AS TipoBienCUCOP_PLUS,

    -- Información de Área (SIS.Area)
    a.Nombre AS AreaNombre,
    a.Clave AS AreaClave,

    -- Información de Proveedor
    p.Nombre AS ProveedorNombre,
    p.RFC AS ProveedorRFC,
    p.Clave AS ProveedorClave,

    -- Información de EstadoBien
    eb.DESCRIPCION_GENERAL AS EstadoBienDescripcionGeneral,
    eb.DESCRIPCION_ESPECIFICA AS EstadoBienDescripcionEspecifica,
    eb.DESCRIPCION_CORTA AS EstadoBienDescripcionCorta,

    -- Información de TipoPatrimonio
    tp.Descripcion AS TipoPatrimonioDescripcion,

    -- Información de Marca
    m.Descripcion AS MarcaDescripcion,

    -- Información de Material
    mat.Descripcion AS MaterialDescripcion,

    -- Información de TipoAdquisicion
    ta.Clave AS TipoAdquisicionClave,
    ta.Descripcion AS TipoAdquisicionDescripcion,
    ta.Descripmovto AS TipoAdquisicionDescripcionMovto,

    -- Información de Partida (CONTA.Partida)
    part.Clave AS PartidaClave,
    part.Descripcion AS PartidaDescripcion

FROM ALMA.Bien b
LEFT JOIN ALMA.GrupoBien gb ON b.FKIdGrupoBien_ALMA = gb.PKIdGrupoBien
LEFT JOIN ALMA.TipoBien tb ON b.FKIdTipoBien_ALMA = tb.PKIdTipoBien
LEFT JOIN SIS.Area a ON b.FKIdArea_SIS = a.PKIdArea
LEFT JOIN SIS.Proveedor p ON b.FKIdProveedor_SIS = p.PKIdProveedor
LEFT JOIN ALMA.EstadoBien eb ON b.FKIdEstadoBien_ALMA = eb.PKIdEstadoBien
LEFT JOIN ALMA.TipoPatrimonio tp ON b.FKIdTipoPatrimonio_ALMA = tp.PKIdTipoPatrimonio
LEFT JOIN ALMA.Marca m ON b.FKIdMarca_ALMA = m.PKIdMarca
LEFT JOIN ALMA.Material mat ON b.FKIdMaterial_ALMA = mat.PKIdMaterial
LEFT JOIN ALMA.TipoAdquisicion ta ON b.FKIdTipoAdq_ALMA = ta.PKIdTipoAdq
LEFT JOIN CONTA.Partida part ON b.FKIdPartida_CONTA = part.PKIdPartida