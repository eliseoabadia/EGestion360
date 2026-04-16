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
      --,E.Activo
      ,E.FechaCreacion,E.UsuarioCreacion,E.FechaModificacion,E.UsuarioModificacion
FROM [SIS].[Empresa] E WITH (NOLOCK)
INNER JOIN [SIS].[Departamento] D WITH (NOLOCK) ON E.PKIdEmpresa = D.FKIdEmpresa_SIS
WHERE E.Activo = 1 AND D.Activo = 1 ;

GO


CREATE OR ALTER VIEW SIS.VW_EstadoEmpresa
AS
SELECT 
    -- Campos de Empresa
    EM.PKIdEmpresa,
    EM.Nombre AS EmpresaNombre,
    EM.RFC,
    EM.RazonSocial,
    EM.Giro,
    EM.FKIdMonedaBase_SIS,
    EM.FKIdIdiomaPreferido_SIS,
    EM.Logo,
    EM.Activo AS EmpresaActivo,
    EM.FechaCreacion AS EmpresaFechaCreacion,
    EM.UsuarioCreacion AS EmpresaUsuarioCreacion,
    EM.FechaModificacion AS EmpresaFechaModificacion,
    EM.UsuarioModificacion AS EmpresaUsuarioModificacion,

    -- Campos de Estado
    E.PKIdEstado,
    E.FKIdPais_SIS,
    E.Nombre AS EstadoNombre,
    E.CodigoEstado,
    E.Activo AS EstadoActivo,

    -- Campos de la relación (EmpresaEstado)
    EE.FechaApertura,
    EE.EsOficinaPrincipal,
    EE.Activo AS RelacionActiva

FROM SIS.Empresa EM
INNER JOIN SIS.EmpresaEstado EE ON EM.PKIdEmpresa = EE.FKIdEmpresa_SIS
INNER JOIN SIS.Estados E ON EE.FKIdEstado_SIS = E.PKIdEstado
WHERE EM.Activo = 1        -- Solo empresas activas
  AND E.Activo = 1         -- Solo estados activos
  -- AND EE.Activo = 1     -- Opcional: si quieres filtrar solo relaciones activas


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
    ,E.Activo
    ,E.FechaCreacion,E.UsuarioCreacion,E.FechaModificacion,E.UsuarioModificacion
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
    
FROM MenuJerarquico m;
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
     --,m.Activo
       ,u.FechaCreacion,u.UsuarioCreacion
       ,u.FechaModificacion AS UsuarioModifyId,u.UsuarioModificacion AS UsuarioFechaModificacion
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
    --,m.Activo
       ,u.FechaCreacion,u.UsuarioCreacion,u.FechaModificacion,u.UsuarioModificacion
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


  GO

  CREATE OR ALTER VIEW ALMA.Vw_TipoBienConteo
AS
SELECT 
    -- ========================
    -- Campos originales de la vista (se mantienen)
    -- ========================
    tb.PKIdTipoBien,
    tb.CodigoClave AS CodigoArticulo,
    tb.Descripcion AS DescripcionArticulo,
    tb.Activo,
    
    -- Unidades
    u.Descripcion AS UnidadMedida,
    ue.Descripcion AS UnidadEquivalente,
    tb.Cantidad_Equivalente,
    
    -- Clasificación
    f.Descripcion AS Familia,
    gb.Descripcion AS GrupoBien,
    n.Descripcion AS Nivel,
    
    -- Partida y cuenta contable
    p.Clave AS PartidaClave,
    p.Descripcion AS PartidaDescripcion,
    cc.Cuenta + '.' + cc.SubCuenta + '.' + cc.SubSubCuenta + '.' + cc.SubSubSubCuenta + '.' + cc.SubSubSubSubCuenta AS CuentaCompleta,
    cc.Descripcion AS CuentaDescripcion,
    tc.Descripcion AS TipoCuenta,
    
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
    tb.UsuarioCreacion,
    tb.FechaModificacion,
    tb.UsuarioModificacion,

    -- ========================
    -- NUEVOS CAMPOS requeridos por el CRUD (solo los que no existían)
    -- ========================
    -- IDs de las relaciones (necesarios para combos y FK)
    tb.FKIdGrupoBien_ALMA AS FkIdGrupoBienSicop,
    tb.FKIdNivel_ALMA AS FkIdNivel,
    tb.FKIdPartida_CONTA AS FkIdPartidaSis,
    tb.FKIdCuentaContable_CONTA AS FkIdCuentaContable,
    tb.FKIdUnidades_ALMA AS FkIdUnidadesAlma,
    tb.FKIdUnidades_Equivalente AS FkIdUnidadesEquivalente,
    
    -- Otros campos útiles que no estaban en la vista original
    tb.Consecutivo,
    tb.Identificador

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
    tb.Activo = 1;

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


GO

-- =============================================
-- Vista: [ALMA].[VW_Existencias]
-- Adaptada al nuevo modelo:
--   - Ahora se basa en [ALMA].[Bien] (activos individuales)
--   - La existencia es el conteo de activos por tipo de bien
--   - Los costos se toman como el promedio de los costos de los activos individuales
--   - Se conservan los mensajes de umbral mínimo/máximo según la configuración del tipo de bien
-- =============================================
CREATE OR ALTER VIEW [ALMA].[VW_Existencias]
AS

WITH Existencias AS
(
    SELECT
        TB.PKIdTipoBien,
        TB.FKIdPartida_CONTA,
        GB.CLAVE_CUCOP AS CUCOP,
        GB.CABM_ACT + ' / ' + GB.ClaveAN AS CABMS,
        TB.CodigoClave,
        TB.Descripcion,
        COUNT(B.PKIdBien) AS Existencias,                 -- Conteo de bienes activos por tipo
        AU.Descripcion AS Unidades,
        -- Para mantener la compatibilidad, el año se fija a 0 (no se usa en este modelo)
        0 AS FK_IdAnio__SIS,
        CAST('' AS NVARCHAR(MAX)) AS Message,
        -- Unidad de medida según la lógica de equivalencia
        IIF(TB.Cantidad_Equivalente > 1, TB.FKIdUnidades_Equivalente, TB.FKIdUnidades_ALMA) AS FK_IdUnidades__ALMA,
        -- CostoUnitario y CostoPromedio: se usa el costo promedio de los bienes activos de este tipo
        AVG(B.Costo) AS CostoUnitario,
        AVG(B.Costo) AS CostoPromedio
    FROM
        ALMA.TipoBien TB
        INNER JOIN ALMA.GrupoBien GB ON TB.FKIdGrupoBien_ALMA = GB.PKIdGrupoBien
        INNER JOIN ALMA.Unidades AU ON IIF(TB.Cantidad_Equivalente > 1, TB.FKIdUnidades_Equivalente, TB.FKIdUnidades_ALMA) = AU.PKIdUnidades
        LEFT JOIN ALMA.Bien B ON TB.PKIdTipoBien = B.FKIdTipoBien_ALMA AND B.Activo = 1
    WHERE
        TB.Activo = 1
        AND GB.Activo = 1
        AND AU.Activo = 1
    GROUP BY
        TB.PKIdTipoBien,
        TB.FKIdPartida_CONTA,
        GB.CLAVE_CUCOP,
        GB.CABM_ACT,
        GB.ClaveAN,
        TB.CodigoClave,
        TB.Descripcion,
        AU.Descripcion,
        IIF(TB.Cantidad_Equivalente > 1, TB.FKIdUnidades_Equivalente, TB.FKIdUnidades_ALMA)
)
SELECT
    E.PKIdTipoBien,
    E.FKIdPartida_CONTA,
    E.CUCOP,
    E.CABMS,
    E.CodigoClave,
    E.Descripcion,
    E.Existencias,
    E.Unidades,
    E.FK_IdAnio__SIS,
    -- Mensaje según comparación con umbrales del tipo de bien
    CASE
        WHEN E.Existencias < TB.ExistenciaMinima THEN 'No alcanza el mínimo de unidades'
        WHEN E.Existencias > TB.ExistenciaMaxima THEN 'Excede el Máximo de Unidades'
        ELSE 'OK'
    END AS Message,
    E.FK_IdUnidades__ALMA,
    ISNULL(E.CostoUnitario, 0) AS CostoUnitario,
    ISNULL(E.CostoPromedio, 0) AS CostoPromedio
FROM
    Existencias E
    INNER JOIN ALMA.TipoBien TB ON E.PKIdTipoBien = TB.PKIdTipoBien
WHERE
    TB.Activo = 1
GO

-- =============================================
-- VISTA: VW_ConteoDetalle
-- Propósito: Unir encabezado de conteo con sus líneas de detalle,
--            mostrando también datos descriptivos del tipo de bien y del contador.
-- =============================================
CREATE OR ALTER VIEW [ALMA].[VW_ConteoDetalle]
AS
SELECT
    -- Campos del encabezado (Conteo)
    C.[PKIdConteo],
    C.[FKIdTipoBien_ALMA],
    TB.[Descripcion]          AS [TipoBienDescripcion],
    C.[CantidadInventario]    AS [CantidadInventarioInicial],
    C.[Descripcion]           AS [ConteoDescripcion],
    C.[FechaInicio],
    C.[FechaFin],
    C.[Activo]                AS [ConteoActivo],
    C.[FechaCreacion]         AS [ConteoFechaCreacion],
    C.[UsuarioCreacion]       AS [ConteoUsuarioCreacion],
    C.[FechaModificacion]     AS [ConteoFechaModificacion],
    C.[UsuarioModificacion]   AS [ConteoUsuarioModificacion],

    -- Campos del detalle (ConteoDetalle)
    CD.[PKIdDetalleConteo],
    CD.[FKIdConteo_ALMA],
    CD.[FKIdNumeroConteo_ALMA],
    CD.[FKIdPersona_NOM],
    P.[Nombre]                AS [PersonaNombre],
    P.[Paterno]               AS [PersonaPaterno],
    P.[Materno]               AS [PersonaMaterno],
    CD.[Cantidad]             AS [CantidadContada],
    CD.[Fecha]                AS [FechaConteo],
    CD.[Activo]               AS [DetalleActivo],
    CD.[FechaCreacion]        AS [DetalleFechaCreacion],
    CD.[UsuarioCreacion]      AS [DetalleUsuarioCreacion],
    CD.[FechaModificacion]    AS [DetalleFechaModificacion],
    CD.[UsuarioModificacion]  AS [DetalleUsuarioModificacion]

FROM [ALMA].[Conteo] C
INNER JOIN [ALMA].[ConteoDetalle] CD
    ON C.[PKIdConteo] = CD.[FKIdConteo_ALMA]
LEFT JOIN [ALMA].[TipoBien] TB
    ON C.[FKIdTipoBien_ALMA] = TB.[PKIdTipoBien]
LEFT JOIN [NOM].[Persona] P
    ON CD.[FKIdPersona_NOM] = P.[PKIdPersona];
GO


-- =============================================
-- VISTA: ALMA.VW_PeriodoConteo
-- Descripción: Vista descriptiva de los periodos de conteo cíclico.
-- =============================================
CREATE OR ALTER VIEW [ALMA].[VW_PeriodoConteo]
AS
SELECT
    pc.[PKIdPeriodoConteo],
    pc.[CodigoPeriodo],
    pc.[Nombre],
    pc.[Descripcion],
    pc.[FechaInicio],
    pc.[FechaFin],
    pc.[FechaCierre],
    pc.[MaximoConteosPorArticulo],
    pc.[RequiereAprobacionSupervisor],
    pc.[TotalArticulos],
    pc.[ArticulosConcluidos],
    pc.[ArticulosConDiferencia],
    pc.[Activo],
    pc.[FechaCreacion],
    pc.[UsuarioCreacion],
    pc.[FechaModificacion],
    pc.[UsuarioModificacion],

    -- Sucursal
    s.[PKIdSucursal]            AS [IdSucursal],
    s.[Nombre]                  AS [Sucursal],
    --s.[Clave]                   AS [ClaveSucursal],

    -- Tipo de conteo
    tc.[PKIdTipoConteo]         AS [IdTipoConteo],
    tc.[Nombre]                 AS [TipoConteo],
    tc.[Descripcion]            AS [DescripcionTipoConteo],

    -- Estatus del periodo
    ep.[PKIdEstatusPeriodo]     AS [IdEstatusPeriodo],
    ep.[Nombre]                 AS [EstatusPeriodo],
    ep.[Descripcion]            AS [DescripcionEstatusPeriodo],

    -- Responsable
    r.[PkIdUsuario]             AS [IdResponsable],
    CONCAT(r.[Nombre], ' ' ,r.[ApellidoPaterno], ' ',r.[ApellidoMaterno])          AS [Responsable],       -- Ajusta según el campo real de SIS.Usuario
    -- Supervisor
    sup.[PkIdUsuario]           AS [IdSupervisor],
    CONCAT(sup.[Nombre], ' ' ,sup.[ApellidoPaterno], ' ',sup.[ApellidoMaterno])        AS [Supervisor]         -- Ajusta según el campo real de SIS.Usuario

FROM [ALMA].[PeriodoConteo] pc
LEFT JOIN [SIS].[Sucursal] s
    ON pc.[FKIdSucursal_SIS] = s.[PKIdSucursal]
LEFT JOIN [ALMA].[TipoConteo] tc
    ON pc.[FKIdTipoConteo_ALMA] = tc.[PKIdTipoConteo]
LEFT JOIN [ALMA].[EstatusPeriodo] ep
    ON pc.[FKIdEstatus_ALMA] = ep.[PKIdEstatusPeriodo]
LEFT JOIN [SIS].[Usuario] r
    ON pc.[FKIdResponsable_SIS] = r.[PkIdUsuario]
LEFT JOIN [SIS].[Usuario] sup
    ON pc.[FKIdSupervisor_SIS] = sup.[PkIdUsuario];
GO


-- =============================================
-- VISTA: ALMA.VW_Conteo (con PeriodoConteo y TipoConteo)
-- =============================================
CREATE OR ALTER VIEW [ALMA].[VW_Conteo]
AS
SELECT
    c.[PKIdConteo],
    c.[CantidadInventario],
    c.[Descripcion],
    c.[FechaInicio],
    c.[FechaFin],
    c.[Activo],
    c.[FechaCreacion],
    c.[UsuarioCreacion],
    c.[FechaModificacion],
    c.[UsuarioModificacion],

    -- Datos del periodo de conteo
    pc.[PKIdPeriodoConteo]          AS [IdPeriodoConteo],
    pc.[CodigoPeriodo]              AS [CodigoPeriodo],
    pc.[Nombre]                     AS [NombrePeriodo],
    pc.[FechaInicio]                AS [PeriodoFechaInicio],
    pc.[FechaFin]                   AS [PeriodoFechaFin],

    -- Tipo de conteo (a través de PeriodoConteo)
    tc.[PKIdTipoConteo]             AS [IdTipoConteo],
    tc.[Nombre]                     AS [TipoConteo],
    tc.[Descripcion]                AS [DescripcionTipoConteo],

    -- Estatus del periodo
    ep.[PKIdEstatusPeriodo]         AS [IdEstatusPeriodo],
    ep.[Nombre]                     AS [EstatusPeriodo],
    ep.[Descripcion]                AS [DescripcionEstatusPeriodo],

    -- Tipo de bien
    tb.[PKIdTipoBien]               AS [IdTipoBien],
    tb.[CodigoClave]                AS [CodigoClaveTipoBien],
    tb.[Descripcion]                AS [DescripcionTipoBien],

    -- Grupo y familia
    gb.[PKIdGrupoBien]              AS [IdGrupoBien],
    gb.[Descripcion]                AS [GrupoBien],
    f.[PKIdFamilia]                 AS [IdFamilia],
    f.[Descripcion]                 AS [Familia],

    -- Unidad de medida
    u.[PKIdUnidades]                AS [IdUnidad],
    u.[Descripcion]                 AS [UnidadMedida],

    -- Usuarios
    uc.[PkIdUsuario]                AS [IdUsuarioCreacion],
    CONCAT(uc.[Nombre], ' ', uc.[ApellidoPaterno], ' ', uc.[ApellidoMaterno]) AS [NombreUsuarioCreacion],
    um.[PkIdUsuario]                AS [IdUsuarioModificacion],
    CONCAT(um.[Nombre], ' ', um.[ApellidoPaterno], ' ', um.[ApellidoMaterno]) AS [NombreUsuarioModificacion],

    -- Métricas desde ConteoDetalle
    ISNULL(COUNT(DISTINCT cd.[PKIdDetalleConteo]), 0)      AS [TotalLecturas],
    ISNULL(SUM(cd.[Cantidad]), 0)                          AS [TotalCantidadContada],
    ISNULL(COUNT(DISTINCT cd.[FKIdPersona_NOM]), 0)        AS [PersonasParticipantes],

    -- Estado del conteo individual
    CASE
        WHEN c.[FechaFin] IS NOT NULL AND c.[FechaFin] <= GETDATE() THEN 'Finalizado'
        WHEN c.[FechaInicio] <= GETDATE() AND (c.[FechaFin] IS NULL OR c.[FechaFin] > GETDATE()) THEN 'En Proceso'
        WHEN c.[FechaInicio] > GETDATE() THEN 'Programado'
        ELSE 'Indeterminado'
    END AS [EstadoConteo]

FROM [ALMA].[Conteo] c

INNER JOIN [ALMA].[PeriodoConteo] pc
    ON c.[FKIdPeriodoConteo_ALMA] = pc.[PKIdPeriodoConteo]

LEFT JOIN [ALMA].[TipoConteo] tc
    ON pc.[FKIdTipoConteo_ALMA] = tc.[PKIdTipoConteo]

LEFT JOIN [ALMA].[EstatusPeriodo] ep
    ON pc.[FKIdEstatus_ALMA] = ep.[PKIdEstatusPeriodo]

LEFT JOIN [ALMA].[TipoBien] tb
    ON c.[FKIdTipoBien_ALMA] = tb.[PKIdTipoBien]

LEFT JOIN [ALMA].[GrupoBien] gb
    ON tb.[FKIdGrupoBien_ALMA] = gb.[PKIdGrupoBien]

LEFT JOIN [ALMA].[Familia] f
    ON gb.[FKIdFamilia_ALMA] = f.[PKIdFamilia]

LEFT JOIN [ALMA].[Unidades] u
    ON tb.[FKIdUnidades_ALMA] = u.[PKIdUnidades]

LEFT JOIN [SIS].[Usuario] uc
    ON c.[UsuarioCreacion] = uc.[PkIdUsuario]

LEFT JOIN [SIS].[Usuario] um
    ON c.[UsuarioModificacion] = um.[PkIdUsuario]

LEFT JOIN [ALMA].[ConteoDetalle] cd
    ON c.[PKIdConteo] = cd.[FKIdConteo_ALMA]
       AND cd.[Activo] = 1

WHERE c.[Activo] = 1

GROUP BY
    c.[PKIdConteo],
    c.[CantidadInventario],
    c.[Descripcion],
    c.[FechaInicio],
    c.[FechaFin],
    c.[Activo],
    c.[FechaCreacion],
    c.[UsuarioCreacion],
    c.[FechaModificacion],
    c.[UsuarioModificacion],
    pc.[PKIdPeriodoConteo],
    pc.[CodigoPeriodo],
    pc.[Nombre],
    pc.[FechaInicio],
    pc.[FechaFin],
    tc.[PKIdTipoConteo],
    tc.[Nombre],
    tc.[Descripcion],
    ep.[PKIdEstatusPeriodo],
    ep.[Nombre],
    ep.[Descripcion],
    tb.[PKIdTipoBien],
    tb.[CodigoClave],
    tb.[Descripcion],
    gb.[PKIdGrupoBien],
    gb.[Descripcion],
    f.[PKIdFamilia],
    f.[Descripcion],
    u.[PKIdUnidades],
    u.[Descripcion],
    uc.[PkIdUsuario],
    uc.[Nombre],
    uc.[ApellidoPaterno],
    uc.[ApellidoMaterno],
    um.[PkIdUsuario],
    um.[Nombre],
    um.[ApellidoPaterno],
    um.[ApellidoMaterno];


GO

-- =============================================
-- VISTA: VW_ConteoDetalleEscaneo
-- Descripción: Muestra los detalles de escaneo de códigos de barras con información asociada
-- =============================================
CREATE OR ALTER VIEW [ALMA].[VW_ConteoDetalleEscaneo]
AS
SELECT
    cde.[PKIdDetalleEscaneo],
    cde.[FKIdConteo_ALMA],
    cde.[FKIdPersona_NOM],
    cde.[CodigoBarras],
    cde.[FKIdTipoBien_ALMA],
    cde.[FKIdBien_ALMA],
    cde.[FechaEscaneo],
    cde.[Activo],
    cde.[FechaCreacion],
    cde.[UsuarioCreacion],
    cde.[FechaModificacion],
    cde.[UsuarioModificacion],
    -- Información del Conteo
    c.[Descripcion]             AS [ConteoDescripcion],
    c.[FechaInicio]             AS [ConteoFechaInicio],
    c.[FechaFin]                AS [ConteoFechaFin],
    c.[CantidadInventario]      AS [ConteoCantidadInventario],
    -- Información del Tipo de Bien
    tb.[Descripcion]            AS [TipoBienDescripcion],
    tb.[CodigoClave]            AS [TipoBienCodigoClave],
    -- Información de la Persona que escaneó
    p.[Nombre]                  AS [PersonaNombre],
    p.[Paterno]                 AS [PersonaPaterno],
    p.[Materno]                 AS [PersonaMaterno],
    p.[Clave]                   AS [PersonaClave],
    -- Información del Bien (si está asociado)
    b.[Clave]                   AS [BienClave],
    b.[Serie]                   AS [BienSerie],
    b.[Modelo]                  AS [BienModelo],
    b.[Descripcion]             AS [BienDescripcion]
FROM [ALMA].[ConteoDetalleEscaneo] cde
INNER JOIN [ALMA].[Conteo] c ON cde.[FKIdConteo_ALMA] = c.[PKIdConteo]
INNER JOIN [ALMA].[TipoBien] tb ON cde.[FKIdTipoBien_ALMA] = tb.[PKIdTipoBien]
INNER JOIN [NOM].[Persona] p ON cde.[FKIdPersona_NOM] = p.[PKIdPersona]
LEFT JOIN [ALMA].[Bien] b ON cde.[FKIdBien_ALMA] = b.[PKIdBien];
GO