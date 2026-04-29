-- =============================================
-- SCRIPT REDUCIDO: DOS EMPRESAS + TRES USUARIOS
-- =============================================
USE [GestionEmpresarial]
GO

-- =============================================
-- 1. CATÁLOGOS BASE MÍNIMOS
-- =============================================
INSERT INTO SIS.Idioma (Nombre, CodigoISO639_1, NombreNativo) VALUES
('Español', 'es', 'Español'),
('Inglés', 'en', 'English');

INSERT INTO SIS.Moneda (Nombre, CodigoISO4217, Simbolo, Decimales) VALUES
('Peso Mexicano', 'MXN', '$', 2),
('Dólar Estadounidense', 'USD', 'US$', 2);

INSERT INTO SIS.Paises (Nombre, CodigoISO2, CodigoISO3, FKIdIdiomaPrincipal_SIS, FKIdMonedaPrincipal_SIS) VALUES
('México', 'MX', 'MEX', 1, 1);

INSERT INTO SIS.Estados (FKIdPais_SIS, Nombre, CodigoEstado) VALUES
(1, 'Ciudad de México', 'CDMX'),
(1, 'Jalisco', 'JAL');

INSERT INTO SIS.CatTipoSucursal (Descripcion) VALUES ('Matriz/Central');

-- =============================================
-- 2. EMPRESAS (solo dos)
-- =============================================
INSERT INTO SIS.Empresa (Nombre, RFC, RazonSocial, Giro, FKIdMonedaBase_SIS, FKIdIdiomaPreferido_SIS, UsuarioCreacion) VALUES
('IFT', 'IFT110101AAA', 'Instituto Federal de Telecomunicaciones', 'Tecnología', 1, 1, 1),
('Grupo Constructor Delta', 'GCD020202BBB', 'Delta Construcciones y Servicios', 'Construcción', 1, 1, 1);


INSERT INTO [SIS].[EmpresaEstado]
           ([FKIdEmpresa_SIS]
           ,[FKIdEstado_SIS]
           ,[FechaApertura]
           ,[EsOficinaPrincipal]
           ,[Activo])
     VALUES
           (1
           ,1
           ,getdate()
           ,1
           ,1)
INSERT INTO [SIS].[EmpresaEstado]
           ([FKIdEmpresa_SIS]
           ,[FKIdEstado_SIS]
           ,[FechaApertura]
           ,[EsOficinaPrincipal]
           ,[Activo])
     VALUES
           (2
           ,2
           ,getdate()
           ,1
           ,1)

-- =============================================
-- 3. SUCURSALES (una matriz por empresa)
-- =============================================
-- Sucursal para IFT (CDMX)
INSERT INTO SIS.Sucursal (FKIdEmpresa_SIS, FKIdEstado_SIS, Nombre, CodigoSucursal, Alias,
    FKIdTipoSucursal, FKIdMonedaLocal_SIS, Direccion, Colonia, Ciudad, CodigoPostal,
    TelefonoPrincipal, Email, EsMatriz, EsActiva, UsuarioCreacion)
VALUES (1, 1, 'IFT Matriz', 'IFT-MAT-001', 'Oficinas Centrales', 1, 1,
        'Av. Santa Fe 505', 'Santa Fe', 'Ciudad de México', '01210',
        '55-5123-4500', 'matriz@ift.com', 1, 1, 1);

-- Sucursal para Grupo Constructor Delta (CDMX)
INSERT INTO SIS.Sucursal (FKIdEmpresa_SIS, FKIdEstado_SIS, Nombre, CodigoSucursal, Alias,
    FKIdTipoSucursal, FKIdMonedaLocal_SIS, Direccion, Colonia, Ciudad, CodigoPostal,
    TelefonoPrincipal, Email, EsMatriz, EsActiva, UsuarioCreacion)
VALUES (2, 1, 'Delta Matriz', 'DELTA-MAT-001', 'Oficinas Centrales', 1, 1,
        'Av. Constitución 1500', 'Centro', 'Ciudad de México', '64000',
        '55-8340-1010', 'contacto@delta.com', 1, 1, 1);

-- =============================================
-- 4. DEPARTAMENTOS MÍNIMOS
-- =============================================
-- Para IFT
INSERT INTO SIS.Departamento (FKIdEmpresa_SIS, FKIdSucursal_SIS, Nombre, Descripcion, NivelJerarquico, UsuarioCreacion)
VALUES (1, 1, 'DIRECCIÓN GENERAL', 'Dirección General', 1, 1);

-- Para Delta
INSERT INTO SIS.Departamento (FKIdEmpresa_SIS, FKIdSucursal_SIS, Nombre, Descripcion, NivelJerarquico, UsuarioCreacion)
VALUES (2, 2, 'DIRECCIÓN GENERAL', 'Dirección General', 1, 1);

-- =============================================
-- 5. USUARIOS (Administrador, Soporte, CONFIGURATION)
-- =============================================
-- Nota: Los tres usuarios pertenecen a la empresa IFT (ID=1)
INSERT INTO SIS.Usuario (FKIdEmpresa_SIS, AspNetUserId, Nombre, ApellidoPaterno, ApellidoMaterno,
    Iniciales, PayrollID, Telefono, Email, Sexo, FechaIngreso,
    FKIdIdiomaPreferido_SIS, FKIdMonedaPreferida_SIS, EsAdministrador, UsuarioCreacion, Direccion1,NumeroSocial,Gafete)
VALUES
(1, 'adm-001', 'Administrador', 'Sistema', 'Global', 'ASG', 'ADM001',
 '55-0000-0001', 'admin@ift.com', 1, '2020-01-01', 1, 1, 1, 1,'Dis 01','Social001','Gafete01'),  -- Administrador

(1, 'sop-001', 'Soporte', 'Técnico', 'Sistemas', 'STS', 'SOP001',
 '55-0000-0002', 'soporte@ift.com', 1, '2020-01-01', 1, 1, 0, 1,'Dis 01','Social001','Gafete02'),  -- Soporte

(1, 'cfg-001', 'CONFIGURATION', 'Config', 'User', 'CCU', 'CFG001',
 '55-0000-0003', 'config@ift.com', 1, '2020-01-01', 1, 1, 0, 1,'Dis 01','Social001','Gafete03');  -- CONFIGURATION

-- =============================================
-- 6. ASIGNACIONES (Usuario-Sucursal y Usuario-Departamento)
-- =============================================
-- UsuarioSucursal: permisos diferenciados
-- Administrador: todos los permisos (acceder, configurar, operar, reportes, gerente)
INSERT INTO SIS.UsuarioSucursal (FKIdUsuario_SIS, FKIdSucursal_SIS, PuedeAcceder, PuedeConfigurar,
    PuedeOperar, PuedeReportes, EsGerente, EsSupervisor, UsuarioCreacion)
VALUES (1, 1, 1, 1, 1, 1, 1, 1, 1);

-- Soporte: acceso, operación y reportes, pero NO configuración
INSERT INTO SIS.UsuarioSucursal (FKIdUsuario_SIS, FKIdSucursal_SIS, PuedeAcceder, PuedeConfigurar,
    PuedeOperar, PuedeReportes, EsGerente, EsSupervisor, UsuarioCreacion)
VALUES (2, 1, 1, 0, 1, 1, 0, 0, 1);

-- CONFIGURATION: acceso y configuración (puede configurar pero no operar ni reportes)
INSERT INTO SIS.UsuarioSucursal (FKIdUsuario_SIS, FKIdSucursal_SIS, PuedeAcceder, PuedeConfigurar,
    PuedeOperar, PuedeReportes, EsGerente, EsSupervisor, UsuarioCreacion)
VALUES (3, 1, 1, 1, 0, 0, 0, 0, 1);

-- UsuarioDepartamento: solo el Administrador como jefe del departamento de Dirección General
INSERT INTO SIS.UsuarioDepartamento (FKIdUsuario_SIS, FKIdDepartamento_SIS, EsJefe, FechaAsignacion, UsuarioCreacion)
VALUES (1, 1, 1, GETDATE(), 1);

-- Los usuarios de Soporte y CONFIGURATION no tienen asignación de departamento (solo acceso por sucursal)

-- =============================================
-- VERIFICACIÓN RÁPIDA
-- =============================================
SELECT 'Empresas insertadas:' AS Mensaje, COUNT(*) FROM SIS.Empresa;
SELECT 'Usuarios insertados:' AS Mensaje, COUNT(*) FROM SIS.Usuario;
SELECT u.Nombre, u.EsAdministrador, us.PuedeConfigurar, us.PuedeOperar
FROM SIS.Usuario u
INNER JOIN SIS.UsuarioSucursal us ON u.PkIdUsuario = us.FKIdUsuario_SIS
WHERE u.FKIdEmpresa_SIS = 1;

select * from SIS.UsuarioDepartamento