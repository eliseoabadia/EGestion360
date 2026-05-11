USE [GestionEmpresarial]
GO


-- =============================================
-- VISTA: VwUsuarioSucursal
-- Descripción: Vista completa de usuarios con sus sucursales asignadas y permisos
-- =============================================
CREATE OR ALTER   VIEW [SIS].[Vw_UsuarioSucursal]
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
       -- Datos de Persona (NOM)
    ,p.PKIdPersona AS IdPersona
    ,p.Clave AS ClavePersona
    ,p.Nombre AS PersonaNombre
    ,p.Paterno AS PersonaPaterno
    ,p.Materno AS PersonaMaterno
    ,CONCAT(p.Nombre, ' ', p.Paterno, ' ', ISNULL(p.Materno, '')) AS NombreCompletoPersona
    ,p.RFC
    ,p.Curp
    ,p.CORREO_ELECTRONICO AS EmailPersona
    ,p.Telefono_particular AS TelefonoParticular
    ,p.Telefono_movil AS TelefonoMovil
    , u.FKIdEmpresa_SIS AS IdEmpresaPersona
FROM SIS.Usuario u
INNER JOIN SIS.Empresa e ON u.FKIdEmpresa_SIS = e.PKIdEmpresa
LEFT JOIN SIS.Idioma i ON u.FKIdIdiomaPreferido_SIS = i.PKIdIdioma
LEFT JOIN SIS.Moneda m ON u.FKIdMonedaPreferida_SIS = m.PKIdMoneda
LEFT JOIN SIS.Moneda mb ON e.FKIdMonedaBase_SIS = mb.PKIdMoneda
INNER JOIN SIS.UsuarioSucursal us ON u.PkIdUsuario = us.FKIdUsuario_SIS
INNER JOIN SIS.Sucursal s ON us.FKIdSucursal_SIS = s.PKIdSucursal
-- Datos de Persona
LEFT JOIN NOM.Persona p ON u.FKIdPersona_NOM = p.PKIdPersona AND p.Activo = 1
WHERE us.Activo = 1 
  AND (us.FechaFinAsignacion IS NULL OR us.FechaFinAsignacion >= GETDATE())
  AND u.Activo = 1;
GO


