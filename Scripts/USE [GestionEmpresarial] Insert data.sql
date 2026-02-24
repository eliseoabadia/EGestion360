-- =============================================
-- DATOS DE EJEMPLO COMPLETOS
-- =============================================

USE [GestionEmpresarial]
GO


-- =============================================
-- 1. CATÁLOGOS BASE
-- =============================================

-- Idiomas
INSERT INTO SIS.Idioma (Nombre, CodigoISO639_1, NombreNativo) VALUES
('Español', 'es', 'Español'),
('Inglés', 'en', 'English'),
('Francés', 'fr', 'Français'),
('Alemán', 'de', 'Deutsch'),
('Italiano', 'it', 'Italiano'),
('Portugués', 'pt', 'Português');
GO

-- Monedas
INSERT INTO SIS.Moneda (Nombre, CodigoISO4217, Simbolo, Decimales) VALUES
('Peso Mexicano', 'MXN', '$', 2),
('Dólar Estadounidense', 'USD', 'US$', 2),
('Euro', 'EUR', '€', 2),
('Dólar Canadiense', 'CAD', 'C$', 2),
('Real Brasileño', 'BRL', 'R$', 2),
('Peso Argentino', 'ARS', '$', 2),
('Peso Colombiano', 'COP', '$', 2),
('Peso Chileno', 'CLP', '$', 0),
('Sol Peruano', 'PEN', 'S/', 2),
('Libra Esterlina', 'GBP', '£', 2);
GO

-- Países
INSERT INTO SIS.Paises (Nombre, CodigoISO2, CodigoISO3, FKIdIdiomaPrincipal_SIS, FKIdMonedaPrincipal_SIS) VALUES
('México', 'MX', 'MEX', 1, 1),
('Estados Unidos', 'US', 'USA', 2, 2),
('Canadá', 'CA', 'CAN', 3, 4),
('Brasil', 'BR', 'BRA', 6, 5),
('Argentina', 'AR', 'ARG', 1, 6),
('Colombia', 'CO', 'COL', 1, 7),
('Chile', 'CL', 'CHL', 1, 8),
('Perú', 'PE', 'PER', 1, 9),
('España', 'ES', 'ESP', 1, 3),
('Francia', 'FR', 'FRA', 3, 3),
('Alemania', 'DE', 'DEU', 4, 3),
('Italia', 'IT', 'ITA', 5, 3),
('Reino Unido', 'GB', 'GBR', 2, 10);
GO

-- Estados de México
INSERT INTO SIS.Estados (FKIdPais_SIS, Nombre, CodigoEstado) VALUES
(1, 'Aguascalientes', 'AGS'),
(1, 'Baja California', 'BC'),
(1, 'Baja California Sur', 'BCS'),
(1, 'Campeche', 'CAMP'),
(1, 'Coahuila', 'COAH'),
(1, 'Colima', 'COL'),
(1, 'Chiapas', 'CHIS'),
(1, 'Chihuahua', 'CHIH'),
(1, 'Ciudad de México', 'CDMX'),
(1, 'Durango', 'DGO'),
(1, 'Guanajuato', 'GTO'),
(1, 'Guerrero', 'GRO'),
(1, 'Hidalgo', 'HGO'),
(1, 'Jalisco', 'JAL'),
(1, 'México', 'MEX'),
(1, 'Michoacán', 'MICH'),
(1, 'Morelos', 'MOR'),
(1, 'Nayarit', 'NAY'),
(1, 'Nuevo León', 'NL'),
(1, 'Oaxaca', 'OAX'),
(1, 'Puebla', 'PUE'),
(1, 'Querétaro', 'QRO'),
(1, 'Quintana Roo', 'QROO'),
(1, 'San Luis Potosí', 'SLP'),
(1, 'Sinaloa', 'SIN'),
(1, 'Sonora', 'SON'),
(1, 'Tabasco', 'TAB'),
(1, 'Tamaulipas', 'TAMPS'),
(1, 'Tlaxcala', 'TLAX'),
(1, 'Veracruz', 'VER'),
(1, 'Yucatán', 'YUC'),
(1, 'Zacatecas', 'ZAC');

-- Estados de USA (algunos ejemplos)
INSERT INTO SIS.Estados (FKIdPais_SIS, Nombre, CodigoEstado) VALUES
(2, 'California', 'CA'),
(2, 'Texas', 'TX'),
(2, 'Florida', 'FL'),
(2, 'Nueva York', 'NY'),
(2, 'Illinois', 'IL'),
(2, 'Arizona', 'AZ');

-- Estados de Canadá
INSERT INTO SIS.Estados (FKIdPais_SIS, Nombre, CodigoEstado) VALUES
(3, 'Ontario', 'ON'),
(3, 'Quebec', 'QC'),
(3, 'Columbia Británica', 'BC'),
(3, 'Alberta', 'AB');
GO

-- =============================================
-- 2. TIPOS DE SUCURSAL
-- =============================================
INSERT INTO SIS.CatTipoSucursal (Descripcion) VALUES
('Matriz/Central'),
('Sucursal Comercial'),
('Almacén/Logística'),
('Oficina Regional'),
('Punto de Venta'),
('Centro de Distribución'),
('Oficina Administrativa');
GO

-- =============================================
-- 3. EMPRESAS
-- =============================================
INSERT INTO SIS.Empresa (Nombre, RFC, RazonSocial, Giro, FKIdMonedaBase_SIS, FKIdIdiomaPreferido_SIS, UsuarioCreacion) VALUES
('TechNova S.A. de C.V.', 'TEC110101AAA', 'TechNova Soluciones Tecnológicas', 'Tecnología', 1, 1, 1),
('Grupo Constructor Delta', 'GCD020202BBB', 'Delta Construcciones y Servicios', 'Construcción', 1, 1, 1),
('Alimentos La Laguna', 'ALL030303CCC', 'Industrias Alimenticias La Laguna', 'Alimentos', 1, 1, 1),
('Farmacias del Norte', 'FDN040404DDD', 'Farmacias del Norte S.A. de C.V.', 'Farmacéutico', 1, 1, 1),
('Autopartes Mexicanas', 'AMX050505EEE', 'Autopartes Mexicanas S.A. de C.V.', 'Automotriz', 1, 1, 1),
('Consultoría Estratégica', 'CEX060606FFF', 'Consultoría Estratégica Profesional', 'Consultoría', 1, 1, 1);
GO

-- =============================================
-- 4. EMPRESA-ESTADO (dónde opera cada empresa)
-- =============================================
INSERT INTO SIS.EmpresaEstado (FKIdEmpresa_SIS, FKIdEstado_SIS, FechaApertura, EsOficinaPrincipal) VALUES
-- TechNova
(1, 9, '2020-01-15', 1),  -- CDMX
(1, 14, '2021-03-10', 0), -- Jalisco
(1, 19, '2021-06-20', 0), -- Nuevo León
(1, 21, '2022-02-14', 0), -- Puebla

-- Constructora Delta
(2, 19, '2019-05-10', 1), -- Nuevo León
(2, 14, '2020-08-22', 0), -- Jalisco
(2, 9, '2021-01-30', 0),  -- CDMX

-- Alimentos La Laguna
(3, 10, '2018-11-05', 1), -- Durango
(3, 14, '2019-09-15', 0), -- Jalisco
(3, 5, '2020-04-25', 0),  -- Coahuila

-- Farmacias del Norte
(4, 19, '2019-07-01', 1), -- Nuevo León
(4, 5, '2020-03-12', 0),  -- Coahuila
(4, 2, '2021-10-05', 0),  -- Baja California

-- Autopartes Mexicanas
(5, 11, '2020-02-20', 1), -- Guanajuato
(5, 19, '2021-05-17', 0), -- Nuevo León
(5, 14, '2022-01-08', 0), -- Jalisco

-- Consultoría Estratégica
(6, 9, '2021-09-01', 1); -- CDMX
GO

-- =============================================
-- 5. SUCURSALES
-- =============================================
INSERT INTO SIS.Sucursal (
    FKIdEmpresa_SIS, FKIdEstado_SIS, Nombre, CodigoSucursal, Alias,
    FKIdTipoSucursal, FKIdMonedaLocal_SIS, Direccion, Colonia, Ciudad,
    CodigoPostal, TelefonoPrincipal, TelefonoSecundario, Email,
    HorarioApertura, HorarioCierre, EsMatriz, EsActiva, Latitud, Longitud, UsuarioCreacion
) VALUES
-- TechNova - Matriz CDMX
(1, 9, 'TechNova Matriz Santa Fe', 'TECH-MAT-001', 'Matriz CDMX', 1, 1,
 'Av. Santa Fe 505, Torre A Piso 15', 'Santa Fe', 'Ciudad de México',
 '01210', '55-5123-4500', '55-5123-4501', 'matriz@technova.com',
 '09:00', '18:00', 1, 1, 19.3612, -99.2598, 1),

-- TechNova - Sucursales
(1, 14, 'TechNova Guadalajara', 'TECH-GDL-001', 'GDL Centro', 2, 1,
 'Av. Vallarta 1234', 'Ladrón de Guevara', 'Guadalajara',
 '44100', '33-3610-2020', '33-3610-2021', 'gdl@technova.com',
 '09:00', '19:00', 0, 1, 20.6736, -103.3750, 1),

(1, 19, 'TechNova Monterrey', 'TECH-MTY-001', 'MTY San Pedro', 2, 1,
 'Av. Vasconcelos 888', 'San Pedro Garza García', 'Monterrey',
 '66220', '81-8888-1000', '81-8888-1001', 'mty@technova.com',
 '09:00', '19:00', 0, 1, 25.6525, -100.2910, 1),

(1, 21, 'TechNova Puebla', 'TECH-PUE-001', 'Puebla Centro', 2, 1,
 'Av. Juárez 2702', 'Centro', 'Puebla',
 '72000', '22-2123-4567', '22-2123-4568', 'puebla@technova.com',
 '09:00', '20:00', 0, 1, 19.0437, -98.1982, 1),

(1, 15, 'TechNova Toluca', 'TECH-TOL-001', 'Toluca', 2, 1,
 'Paseo Tollocan 900', 'Universidad', 'Toluca',
 '50130', '72-2123-4567', '72-2123-4568', 'toluca@technova.com',
 '09:00', '18:00', 0, 1, 19.2847, -99.6495, 1),

(1, 1, 'TechNova Aguascalientes', 'TECH-AGS-001', 'Ags', 2, 1,
 'Av. Independencia 567', 'Centro', 'Aguascalientes',
 '20000', '44-9123-4567', '44-9123-4568', 'ags@technova.com',
 '09:00', '18:00', 0, 1, 21.8853, -102.2916, 1),

-- TechNova - Centros de Distribución
(1, 15, 'TechNova CEDIS Toluca', 'TECH-CED-001', 'CEDIS Toluca', 3, 1,
 'Parque Industrial Toluca 2000', 'San Cayetano', 'Toluca',
 '50200', '72-2123-5000', '72-2123-5001', 'cedis.toluca@technova.com',
 '07:00', '20:00', 0, 1, 19.3000, -99.6500, 1),

(1, 19, 'TechNova CEDIS Monterrey', 'TECH-CED-002', 'CEDIS MTY', 3, 1,
 'Parque Industrial Apodaca', 'Apodaca', 'Monterrey',
 '66600', '81-8888-7000', '81-8888-7001', 'cedis.mty@technova.com',
 '07:00', '20:00', 0, 1, 25.7500, -100.2000, 1),

-- TechNova - Oficinas Regionales
(1, 14, 'TechNova Oficinas Occidente', 'TECH-OCC-001', 'Oficinas GDL', 4, 1,
 'Av. Américas 1500', 'Americas', 'Guadalajara',
 '44100', '33-3610-3000', '33-3610-3001', 'occidente@technova.com',
 '09:00', '18:00', 0, 1, 20.6800, -103.4000, 1),

(1, 19, 'TechNova Oficinas Norte', 'TECH-NTE-001', 'Oficinas MTY', 4, 1,
 'Av. Gómez Morín 999', 'Valle', 'Monterrey',
 '66220', '81-8888-4000', '81-8888-4001', 'norte@technova.com',
 '09:00', '18:00', 0, 1, 25.6600, -100.3000, 1),

-- Constructora Delta
(2, 19, 'Constructora Delta Matriz', 'DELTA-MAT-001', 'Matriz MTY', 1, 1,
 'Av. Constitución 1500', 'Centro', 'Monterrey',
 '64000', '81-8340-1010', '81-8340-1011', 'contacto@delta.com.mx',
 '08:00', '17:00', 1, 1, 25.6675, -100.3167, 1),

(2, 14, 'Constructora Delta Guadalajara', 'DELTA-GDL-001', 'GDL', 2, 1,
 'Av. México 2222', 'Vallarta', 'Guadalajara',
 '44100', '33-3630-2020', '33-3630-2021', 'gdl@delta.com.mx',
 '08:00', '17:00', 0, 1, 20.6825, -103.3917, 1),

(2, 9, 'Constructora Delta CDMX', 'DELTA-CDMX-001', 'CDMX', 2, 1,
 'Insurgentes Sur 1800', 'Del Valle', 'Ciudad de México',
 '03100', '55-5550-3030', '55-5550-3031', 'cdmx@delta.com.mx',
 '08:00', '17:00', 0, 1, 19.3917, -99.1667, 1),

-- Alimentos La Laguna
(3, 10, 'Alimentos La Laguna Principal', 'ALL-DGO-001', 'Matriz DGO', 1, 1,
 'Blvd. José Rebollo Acosta 500', 'Las Alamedas', 'Durango',
 '34000', '61-8123-4567', '61-8123-4568', 'contacto@all.com.mx',
 '08:00', '18:00', 1, 1, 24.0277, -104.6532, 1),

(3, 14, 'Alimentos La Laguna GDL', 'ALL-GDL-001', 'Planta GDL', 3, 1,
 'Av. López Mateos Sur 5000', 'Jardines del Bosque', 'Guadalajara',
 '44500', '33-3880-1122', '33-3880-1123', 'planta.gdl@all.com.mx',
 '07:00', '19:00', 0, 1, 20.6400, -103.4400, 1),

-- Farmacias del Norte
(4, 19, 'Farmacias del Norte Central', 'FDN-MTY-001', 'Central MTY', 1, 1,
 'Av. Gonzalitos 1500', 'Mitras Centro', 'Monterrey',
 '64460', '81-8330-4455', '81-8330-4456', 'central@farmaciasnorte.com',
 '08:00', '20:00', 1, 1, 25.6925, -100.3542, 1),

(4, 5, 'Farmacias del Norte Saltillo', 'FDN-SAL-001', 'Saltillo', 2, 1,
 'Blvd. Venustiano Carranza 2500', 'Zona Centro', 'Saltillo',
 '25000', '84-4412-3456', '84-4412-3457', 'saltillo@farmaciasnorte.com',
 '08:00', '22:00', 0, 1, 25.4231, -101.0053, 1),

(4, 2, 'Farmacias del Norte Tijuana', 'FDN-TIJ-001', 'Tijuana', 2, 2,  -- Moneda local USD
 'Paseo de los Héroes 1200', 'Zona Río', 'Tijuana',
 '22000', '66-4688-1234', '66-4688-1235', 'tijuana@farmaciasnorte.com',
 '08:00', '22:00', 0, 1, 32.5289, -117.0192, 1),

-- Autopartes Mexicanas
(5, 11, 'Autopartes Mexicanas Planta', 'AMX-GTO-001', 'Planta GTO', 1, 1,
 'Parque Industrial Puerto Interior 500', 'Silao', 'Guanajuato',
 '36275', '47-2746-7890', '47-2746-7891', 'contacto@autopartes.com',
 '06:00', '22:00', 1, 1, 20.9583, -101.4500, 1),

(5, 19, 'Autopartes Mexicanas MTY', 'AMX-MTY-001', 'Oficinas MTY', 4, 1,
 'Av. Lázaro Cárdenas 2500', 'Vista Hermosa', 'Monterrey',
 '64620', '81-8888-9999', '81-8888-9998', 'mty@autopartes.com',
 '09:00', '18:00', 0, 1, 25.6850, -100.3250, 1),

-- Consultoría Estratégica
(6, 9, 'Consultoría Estratégica', 'CEX-CDMX-001', 'Matriz CDMX', 1, 1,
 'Av. Paseo de la Reforma 300', 'Juárez', 'Ciudad de México',
 '06600', '55-5566-7788', '55-5566-7789', 'info@conse.com.mx',
 '09:00', '19:00', 1, 1, 19.4333, -99.1667, 1);
GO

-- =============================================
-- 6. DEPARTAMENTOS
-- =============================================
INSERT INTO SIS.Departamento (FKIdEmpresa_SIS, FKIdSucursal_SIS, Nombre, Descripcion, NivelJerarquico, UsuarioCreacion) VALUES
-- TechNova - Departamentos Corporativos (sin sucursal)
(1, NULL, 'DIRECCIÓN GENERAL', 'Dirección General Corporativa', 1, 1),
(1, NULL, 'DIRECCIÓN DE OPERACIONES', 'Operaciones Corporativas', 1, 1),
(1, NULL, 'DIRECCIÓN DE FINANZAS', 'Finanzas Corporativas', 1, 1),
(1, NULL, 'RECURSOS HUMANOS CORPORATIVO', 'RH Corporativo', 2, 1),
(1, NULL, 'SISTEMAS CORPORATIVO', 'TI Corporativa', 2, 1),
(1, NULL, 'MARKETING CORPORATIVO', 'Marketing y Publicidad', 2, 1),

-- TechNova - Departamentos por sucursal
-- Matriz CDMX
(1, 1, 'GERENCIA GENERAL CDMX', 'Gerencia Matriz', 1, 1),
(1, 1, 'VENTAS CDMX', 'Ventas Matriz', 2, 1),
(1, 1, 'ATENCIÓN A CLIENTES CDMX', 'Atención a Clientes', 3, 1),
(1, 1, 'ALMACÉN CDMX', 'Almacén Matriz', 2, 1),

-- Guadalajara
(1, 2, 'GERENCIA GDL', 'Gerencia Sucursal GDL', 1, 1),
(1, 2, 'VENTAS GDL', 'Ventas Guadalajara', 2, 1),
(1, 2, 'SERVICIO TÉCNICO GDL', 'Servicio Técnico', 2, 1),

-- Monterrey
(1, 3, 'GERENCIA MTY', 'Gerencia Sucursal MTY', 1, 1),
(1, 3, 'VENTAS MTY', 'Ventas Monterrey', 2, 1),
(1, 3, 'SERVICIO TÉCNICO MTY', 'Servicio Técnico', 2, 1),

-- Puebla
(1, 4, 'GERENCIA PUEBLA', 'Gerencia Sucursal Puebla', 1, 1),
(1, 4, 'VENTAS PUEBLA', 'Ventas Puebla', 2, 1),

-- CEDIS
(1, 7, 'GERENCIA CEDIS TOLUCA', 'Gerencia CEDIS', 1, 1),
(1, 7, 'LOGÍSTICA CEDIS TOLUCA', 'Logística', 2, 1),
(1, 7, 'INVENTARIOS CEDIS TOLUCA', 'Control de Inventarios', 2, 1),

(1, 8, 'GERENCIA CEDIS MTY', 'Gerencia CEDIS', 1, 1),
(1, 8, 'LOGÍSTICA CEDIS MTY', 'Logística', 2, 1),

-- Constructora Delta
(2, 11, 'DIRECCIÓN GENERAL DELTA', 'Dirección General', 1, 1),
(2, 11, 'PROYECTOS Y OBRA', 'Gestión de Proyectos', 2, 1),
(2, 11, 'ARQUITECTURA', 'Departamento de Arquitectura', 2, 1),
(2, 11, 'INGENIERÍA CIVIL', 'Ingeniería', 2, 1),
(2, 12, 'SUCURSAL GDL', 'Operaciones GDL', 1, 1),
(2, 13, 'SUCURSAL CDMX', 'Operaciones CDMX', 1, 1),

-- Alimentos La Laguna
(3, 14, 'DIRECCIÓN GENERAL ALL', 'Dirección', 1, 1),
(3, 14, 'PRODUCCIÓN', 'Planta de Producción', 2, 1),
(3, 14, 'CONTROL DE CALIDAD', 'Laboratorio', 2, 1),
(3, 14, 'VENTAS ALL', 'Ventas Corporativo', 2, 1),
(3, 15, 'PLANTA GDL', 'Operaciones GDL', 1, 1),
(3, 15, 'PRODUCCIÓN GDL', 'Producción GDL', 2, 1),

-- Farmacias del Norte
(4, 16, 'DIRECCIÓN GENERAL FDN', 'Dirección', 1, 1),
(4, 16, 'COMPRAS', 'Compras Corporativo', 2, 1),
(4, 16, 'FARMACIAS', 'Operación de Farmacias', 2, 1),
(4, 17, 'FARMACIA SALTILLO', 'Operación Saltillo', 1, 1),
(4, 18, 'FARMACIA TIJUANA', 'Operación Tijuana', 1, 1),

-- Autopartes Mexicanas
(5, 19, 'DIRECCIÓN GENERAL AMX', 'Dirección', 1, 1),
(5, 19, 'PRODUCCIÓN AUTOPARTES', 'Línea de Producción', 2, 1),
(5, 19, 'CONTROL DE CALIDAD AMX', 'Calidad', 2, 1),
(5, 19, 'VENTAS INDUSTRIALES', 'Ventas a Maquiladoras', 2, 1),

-- Consultoría Estratégica
(6, 21, 'DIRECCIÓN GENERAL CONSE', 'Dirección', 1, 1),
(6, 21, 'CONSULTORÍA FINANCIERA', 'Consultoría en Finanzas', 2, 1),
(6, 21, 'CONSULTORÍA ESTRATÉGICA', 'Consultoría de Negocios', 2, 1),
(6, 21, 'CONSULTORÍA TECNOLÓGICA', 'Consultoría TI', 2, 1);
GO

-- =============================================
-- 7. USUARIOS (con AspNetUserId simulados)
-- =============================================
INSERT INTO SIS.Usuario (
    FKIdEmpresa_SIS, AspNetUserId, Nombre, ApellidoPaterno, ApellidoMaterno,
    Iniciales, PayrollID,  Telefono, Direccion1, Direccion2,
    Email, NumeroSocial, Gafete, Sexo, FechaIngreso,
    FKIdIdiomaPreferido_SIS, FKIdMonedaPreferida_SIS, EsAdministrador, UsuarioCreacion
) VALUES
-- TechNova - Administradores y Directivos
(1, 'aspnet-user-admin-001', 'Carlos', 'Rodríguez', 'Martínez', 'CRM', 'ADM001',
 '55-1234-5678', 'Av. Reforma 123, Piso 10', 'Col. Juárez', 'carlos.rodriguez@technova.com',
 'NS1234567890', 'ADM001', 1, '2018-05-15', 1, 1, 1, 1),

(1, 'aspnet-user-dir-001', 'Laura', 'Sánchez', 'Torres', 'LST', 'DIR001', 
 '55-2345-6789', 'Av. Santa Fe 505', 'Col. Santa Fe', 'laura.sanchez@technova.com',
 'NS0987654321', 'DIR001', 0, '2019-03-10', 1, 1, 0, 1),

(1, 'aspnet-user-dir-002', 'Roberto', 'Gómez', 'Flores', 'RGF', 'DIR002', 
 '55-3456-7890', 'Av. Santa Fe 505', 'Col. Santa Fe', 'roberto.gomez@technova.com',
 'NS5678901234', 'DIR002', 1, '2020-01-20', 1, 1, 0, 1),

-- TechNova - Gerentes de Sucursal
(1, 'aspnet-user-ger-001', 'Ana', 'Martínez', 'Luna', 'AML', 'GER001', 
 '33-1234-5678', 'Av. Vallarta 1234', 'Col. Ladrón de Guevara', 'ana.martinez@technova.com',
 'NS1111111111', 'GER001', 0, '2021-02-15', 1, 1, 0, 1),

(1, 'aspnet-user-ger-002', 'Jorge', 'Herrera', 'Castro', 'JHC', 'GER002', 
 '81-1234-5678', 'Av. Vasconcelos 888', 'San Pedro', 'jorge.herrera@technova.com',
 'NS2222222222', 'GER002', 1, '2021-03-10', 1, 1, 0, 1),

(1, 'aspnet-user-ger-003', 'Patricia', 'Núñez', 'Ortiz', 'PNO', 'GER003', 
 '22-1234-5678', 'Av. Juárez 2702', 'Centro', 'patricia.nunez@technova.com',
 'NS3333333333', 'GER003', 0, '2021-04-05', 1, 1, 0, 1),

(1, 'aspnet-user-ger-004', 'Fernando', 'Castro', 'Ríos', 'FCR', 'GER004', 
 '72-1234-5678', 'Paseo Tollocan 900', 'Universidad', 'fernando.castro@technova.com',
 'NS4444444444', 'GER004', 1, '2021-05-20', 1, 1, 0, 1),

(1, 'aspnet-user-ger-005', 'Diana', 'Mendoza', 'Silva', 'DMS', 'GER005', 
 '44-1234-5678', 'Av. Independencia 567', 'Centro', 'diana.mendoza@technova.com',
 'NS5555555555', 'GER005', 0, '2022-01-15', 1, 1, 0, 1),

-- TechNova - Vendedores y Personal
(1, 'aspnet-user-vta-001', 'Luis', 'Fernández', 'Ruiz', 'LFR', 'VTA001',
 '33-2345-6789', 'Av. México 500', 'Col. Moderna', 'luis.fernandez@technova.com',
 'NS6666666666', 'VTA001', 1, '2022-02-10', 1, 1, 0, 1),

(1, 'aspnet-user-vta-002', 'Gabriela', 'Torres', 'Mora', 'GTM', 'VTA002', 
 '33-3456-7890', 'Av. López Mateos 1500', 'Jardines', 'gabriela.torres@technova.com',
 'NS7777777777', 'VTA002', 0, '2022-03-05', 2, 2, 0, 1),  -- Prefiere inglés y USD

(1, 'aspnet-user-vta-003', 'Miguel', 'Ángel', 'Ramos', 'MAR', 'VTA003', 
 '81-2345-6789', 'Av. Gómez Morín 999', 'Valle', 'miguel.ramos@technova.com',
 'NS8888888888', 'VTA003', 1, '2022-04-12', 1, 1, 0, 1),

(1, 'aspnet-user-vta-004', 'Sofía', 'Cortés', 'Nava', 'SCN', 'VTA004', 
 '81-3456-7890', 'Av. Constitución 1500', 'Centro', 'sofia.cortes@technova.com',
 'NS9999999999', 'VTA004', 0, '2022-05-18', 1, 1, 0, 1),

(1, 'aspnet-user-vta-005', 'Ricardo', 'Paredes', 'Luna', 'RPL', 'VTA005', 
 '22-2345-6789', 'Av. Juárez 2702', 'Centro', 'ricardo.paredes@technova.com',
 'NS1010101010', 'VTA005', 1, '2022-06-22', 1, 1, 0, 1),

(1, 'aspnet-user-vta-006', 'Alejandra', 'Reyes', 'Solís', 'ARS', 'VTA006', 
 '22-3456-7890', 'Calle 5 de Mayo 100', 'Centro', 'alejandra.reyes@technova.com',
 'NS1111111112', 'VTA006', 0, '2022-07-30', 1, 1, 0, 1),

(1, 'aspnet-user-alm-001', 'José', 'Luis', 'Hernández', 'JLH', 'ALM001', 
 '72-2345-6789', 'Parque Industrial Toluca 2000', 'San Cayetano', 'jose.luis@technova.com',
 'NS1212121212', 'ALM001', 1, '2021-08-14', 1, 1, 0, 1),

(1, 'aspnet-user-alm-002', 'Martha', 'Jiménez', 'Pérez', 'MJP', 'ALM002', 
 '81-4567-8901', 'Parque Industrial Apodaca', 'Apodaca', 'martha.jimenez@technova.com',
 'NS1313131313', 'ALM002', 0, '2021-09-25', 1, 1, 0, 1),

-- Constructora Delta
(2, 'aspnet-user-delta-001', 'Alejandro', 'Treviño', 'Garza', 'ATG', 'DEL001', 
 '81-8340-1010', 'Av. Constitución 1500', 'Centro', 'alejandro.trevino@delta.com.mx',
 'NS1414141414', 'DEL001', 1, '2019-05-10', 1, 1, 1, 1),

(2, 'aspnet-user-delta-002', 'Verónica', 'Cantú', 'González', 'VCG', 'DEL002', 
 '81-8340-1011', 'Av. Constitución 1500', 'Centro', 'veronica.cantu@delta.com.mx',
 'NS1515151515', 'DEL002', 0, '2020-01-20', 1, 1, 0, 1),

-- Alimentos La Laguna
(3, 'aspnet-user-all-001', 'Javier', 'Soto', 'Ramírez', 'JSR', 'ALL001', 
 '61-8123-4567', 'Blvd. José Rebollo Acosta 500', 'Las Alamedas', 'javier.soto@all.com.mx',
 'NS1616161616', 'ALL001', 1, '2018-11-05', 1, 1, 1, 1),

(3, 'aspnet-user-all-002', 'Claudia', 'Navarro', 'López', 'CNL', 'ALL002', 
 '61-8123-4568', 'Blvd. José Rebollo Acosta 500', 'Las Alamedas', 'claudia.navarro@all.com.mx',
 'NS1717171717', 'ALL002', 0, '2020-06-15', 1, 1, 0, 1),

-- Farmacias del Norte
(4, 'aspnet-user-fdn-001', 'Ramón', 'Garza', 'Flores', 'RGF', 'FDN001', 
 '81-8330-4455', 'Av. Gonzalitos 1500', 'Mitras Centro', 'ramon.garza@farmaciasnorte.com',
 'NS1818181818', 'FDN001', 1, '2019-07-01', 1, 1, 1, 1),

(4, 'aspnet-user-fdn-002', 'Marisol', 'Villarreal', 'Sánchez', 'MVS', 'FDN002', 
 '84-4412-3456', 'Blvd. Venustiano Carranza 2500', 'Centro', 'marisol.villarreal@farmaciasnorte.com',
 'NS1919191919', 'FDN002', 0, '2020-03-12', 1, 1, 0, 1),

(4, 'aspnet-user-fdn-003', 'Francisco', 'Zambrano', 'Ruiz', 'FZR', 'FDN003', 
 '66-4688-1234', 'Paseo de los Héroes 1200', 'Zona Río', 'francisco.zambrano@farmaciasnorte.com',
 'NS2020202020', 'FDN003', 1, '2021-10-05', 2, 2, 0, 1),  -- Prefiere inglés

-- Autopartes Mexicanas
(5, 'aspnet-user-amx-001', 'Gustavo', 'León', 'Mendoza', 'GLM', 'AMX001', 
 '47-2746-7890', 'Parque Industrial Puerto Interior 500', 'Silao', 'gustavo.leon@autopartes.com',
 'NS2121212121', 'AMX001', 1, '2020-02-20', 1, 1, 1, 1),

(5, 'aspnet-user-amx-002', 'Teresa', 'Vega', 'Rojas', 'TVR', 'AMX002', 
 '47-2746-7891', 'Parque Industrial Puerto Interior 500', 'Silao', 'teresa.vega@autopartes.com',
 'NS2222222222', 'AMX002', 0, '2021-05-17', 1, 1, 0, 1),

-- Consultoría Estratégica
(6, 'aspnet-user-con-001', 'Ricardo', 'Fuentes', 'Mejía', 'RFM', 'CON001', 
 '55-5566-7788', 'Av. Paseo de la Reforma 300', 'Juárez', 'ricardo.fuentes@conse.com.mx',
 'NS2323232323', 'CON001', 1, '2021-09-01', 2, 3, 1, 1),  -- Prefiere inglés y EUR

(6, 'aspnet-user-con-002', 'Paulina', 'Serrano', 'Cruz', 'PSC', 'CON002', 
 '55-5566-7789', 'Av. Paseo de la Reforma 300', 'Juárez', 'paulina.serrano@conse.com.mx',
 'NS2424242424', 'CON002', 0, '2022-02-14', 1, 1, 0, 1);
GO

-- =============================================
-- 8. USUARIO-SUCURSAL (acceso directo)
-- =============================================
INSERT INTO SIS.UsuarioSucursal (
    FKIdUsuario_SIS, FKIdSucursal_SIS, PuedeAcceder, PuedeConfigurar,
    PuedeOperar, PuedeReportes, EsGerente, EsSupervisor, UsuarioCreacion
) VALUES
-- Carlos Rodríguez (Admin) - acceso a todas las sucursales
(1, 1, 1, 1, 1, 1, 1, 1, 1),  -- Matriz
(1, 2, 1, 1, 1, 1, 1, 1, 1),  -- GDL
(1, 3, 1, 1, 1, 1, 1, 1, 1),  -- MTY
(1, 4, 1, 1, 1, 1, 1, 1, 1),  -- Puebla
(1, 5, 1, 1, 1, 1, 1, 1, 1),  -- Toluca
(1, 6, 1, 1, 1, 1, 1, 1, 1),  -- Aguascalientes
(1, 7, 1, 1, 1, 1, 1, 1, 1),  -- CEDIS Toluca
(1, 8, 1, 1, 1, 1, 1, 1, 1),  -- CEDIS MTY

-- Laura Sánchez (Directora) - acceso a matriz y oficinas
(2, 1, 1, 1, 1, 1, 1, 0, 1),  -- Matriz
(2, 9, 1, 1, 1, 1, 0, 1, 1),  -- Oficinas Occidente
(2, 10, 1, 1, 1, 1, 0, 1, 1), -- Oficinas Norte

-- Roberto Gómez (Director) - acceso a matriz
(3, 1, 1, 1, 1, 1, 1, 0, 1),

-- Ana Martínez (Gerente GDL) - solo GDL
(4, 2, 1, 1, 1, 1, 1, 0, 1),

-- Jorge Herrera (Gerente MTY) - solo MTY
(5, 3, 1, 1, 1, 1, 1, 0, 1),

-- Patricia Núñez (Gerente Puebla) - solo Puebla
(6, 4, 1, 1, 1, 1, 1, 0, 1),

-- Fernando Castro (Gerente Toluca) - solo Toluca
(7, 5, 1, 1, 1, 1, 1, 0, 1),

-- Diana Mendoza (Gerente Aguascalientes) - solo Aguascalientes
(8, 6, 1, 1, 1, 1, 1, 0, 1),

-- Luis Fernández (Vendedor GDL)
(9, 2, 1, 0, 1, 0, 0, 0, 1),

-- Gabriela Torres (Vendedora GDL)
(10, 2, 1, 0, 1, 0, 0, 0, 1),

-- Miguel Ramos (Vendedor MTY)
(11, 3, 1, 0, 1, 0, 0, 1, 1),  -- Es supervisor

-- Sofía Cortés (Vendedora MTY)
(12, 3, 1, 0, 1, 0, 0, 0, 1),

-- Ricardo Paredes (Vendedor Puebla)
(13, 4, 1, 0, 1, 0, 0, 0, 1),

-- Alejandra Reyes (Vendedora Puebla)
(14, 4, 1, 0, 1, 0, 0, 0, 1),

-- José Luis (Almacén Toluca)
(15, 7, 1, 0, 1, 1, 0, 1, 1),  -- Puede reportes, es supervisor

-- Martha Jiménez (Almacén MTY)
(16, 8, 1, 0, 1, 0, 0, 0, 1),

-- Constructora Delta
(17, 11, 1, 1, 1, 1, 1, 1, 1),  -- Alejandro Treviño - Matriz
(17, 12, 1, 0, 1, 1, 0, 1, 1),  -- GDL
(17, 13, 1, 0, 1, 1, 0, 1, 1),  -- CDMX
(18, 12, 1, 1, 1, 1, 1, 0, 1),  -- Verónica Cantú - Gerente GDL

-- Alimentos La Laguna
(19, 14, 1, 1, 1, 1, 1, 1, 1),  -- Javier Soto - Matriz
(20, 15, 1, 1, 1, 1, 1, 0, 1),  -- Claudia Navarro - Gerente Planta GDL

-- Farmacias del Norte
(21, 16, 1, 1, 1, 1, 1, 1, 1),  -- Ramón Garza - Matriz
(22, 17, 1, 1, 1, 1, 1, 0, 1),  -- Marisol Villarreal - Gerente Saltillo
(23, 18, 1, 1, 1, 1, 1, 0, 1),  -- Francisco Zambrano - Gerente Tijuana

-- Autopartes Mexicanas
(24, 19, 1, 1, 1, 1, 1, 1, 1),  -- Gustavo León - Matriz
(25, 20, 1, 1, 1, 1, 1, 0, 1),  -- Teresa Vega - Gerente MTY

-- Consultoría Estratégica
(26, 21, 1, 1, 1, 1, 1, 1, 1),  -- Ricardo Fuentes - Matriz
(27, 21, 1, 0, 1, 0, 0, 0, 1);  -- Paulina Serrano - Consultora
GO

-- =============================================
-- 9. USUARIO-DEPARTAMENTO
-- =============================================
INSERT INTO SIS.UsuarioDepartamento (
    FKIdUsuario_SIS, FKIdDepartamento_SIS, EsJefe, FechaAsignacion, UsuarioCreacion
) VALUES
-- Carlos Rodríguez - Director General
(1, 1, 1, '2018-05-15', 1),  -- DIRECCIÓN GENERAL

-- Laura Sánchez - Directora de Operaciones
(2, 2, 1, '2019-03-10', 1),  -- DIRECCIÓN DE OPERACIONES

-- Roberto Gómez - Director de Finanzas
(3, 3, 1, '2020-01-20', 1),  -- DIRECCIÓN DE FINANZAS

-- Ana Martínez - Gerente GDL
(4, 12, 1, '2021-02-15', 1),  -- GERENCIA GDL
(4, 13, 0, '2021-02-15', 1),  -- VENTAS GDL (miembro)

-- Jorge Herrera - Gerente MTY
(5, 15, 1, '2021-03-10', 1),  -- GERENCIA MTY
(5, 16, 0, '2021-03-10', 1),  -- VENTAS MTY (miembro)

-- Patricia Núñez - Gerente Puebla
(6, 18, 1, '2021-04-05', 1),  -- GERENCIA PUEBLA
(6, 19, 0, '2021-04-05', 1),  -- VENTAS PUEBLA (miembro)

-- Fernando Castro - Gerente Toluca
(7, 20, 1, '2021-05-20', 1),  -- GERENCIA CEDIS TOLUCA
(7, 21, 0, '2021-05-20', 1),  -- LOGÍSTICA CEDIS TOLUCA

-- Diana Mendoza - Gerente Aguascalientes
(8, 11, 1, '2022-01-15', 1),  -- VENTAS AGS (departamento de ventas)

-- Luis Fernández - Vendedor GDL
(9, 13, 0, '2022-02-10', 1),  -- VENTAS GDL

-- Gabriela Torres - Vendedora GDL
(10, 13, 0, '2022-03-05', 1),  -- VENTAS GDL

-- Miguel Ramos - Vendedor MTY (Supervisor)
(11, 16, 0, '2022-04-12', 1),  -- VENTAS MTY
(11, 17, 0, '2022-04-12', 1),  -- SERVICIO TÉCNICO MTY

-- Sofía Cortés - Vendedora MTY
(12, 16, 0, '2022-05-18', 1),  -- VENTAS MTY

-- Ricardo Paredes - Vendedor Puebla
(13, 19, 0, '2022-06-22', 1),  -- VENTAS PUEBLA

-- Alejandra Reyes - Vendedora Puebla
(14, 19, 0, '2022-07-30', 1),  -- VENTAS PUEBLA

-- José Luis - Almacén Toluca
(15, 21, 1, '2021-08-14', 1),  -- LOGÍSTICA CEDIS TOLUCA (jefe)

-- Martha Jiménez - Almacén MTY
(16, 23, 0, '2021-09-25', 1),  -- LOGÍSTICA CEDIS MTY

-- Constructora Delta
(17, 24, 1, '2019-05-10', 1),  -- DIRECCIÓN GENERAL DELTA
(18, 27, 1, '2020-01-20', 1),  -- SUCURSAL GDL (Gerente)

-- Alimentos La Laguna
(19, 29, 1, '2018-11-05', 1),  -- DIRECCIÓN GENERAL ALL
(20, 33, 1, '2020-06-15', 1),  -- PLANTA GDL (Gerente)

-- Farmacias del Norte
(21, 35, 1, '2019-07-01', 1),  -- DIRECCIÓN GENERAL FDN
(22, 37, 1, '2020-03-12', 1),  -- FARMACIA SALTILLO
(23, 38, 1, '2021-10-05', 1),  -- FARMACIA TIJUANA

-- Autopartes Mexicanas
(24, 39, 1, '2020-02-20', 1),  -- DIRECCIÓN GENERAL AMX
(25, 42, 1, '2021-05-17', 1),  -- VENTAS INDUSTRIALES

-- Consultoría Estratégica
(26, 43, 1, '2021-09-01', 1),  -- DIRECCIÓN GENERAL CONSE
(27, 44, 0, '2022-02-14', 1);  -- CONSULTORÍA FINANCIERA
GO

-- =============================================
-- 10. VERIFICACIÓN DE DATOS
-- =============================================

-- Verificar usuarios por empresa
SELECT 
    e.Nombre AS Empresa,
    COUNT(*) AS TotalUsuarios
FROM SIS.Usuario u
INNER JOIN SIS.Empresa e ON u.FKIdEmpresa_SIS = e.PKIdEmpresa
GROUP BY e.Nombre
ORDER BY TotalUsuarios DESC;

-- Verificar asignaciones por sucursal
SELECT 
    s.Nombre AS Sucursal,
    COUNT(DISTINCT us.FKIdUsuario_SIS) AS UsuariosDirectos,
    COUNT(DISTINCT ud.FKIdUsuario_SIS) AS UsuariosPorDepto
FROM SIS.Sucursal s
LEFT JOIN SIS.UsuarioSucursal us ON s.PKIdSucursal = us.FKIdSucursal_SIS AND us.Activo = 1
LEFT JOIN SIS.Departamento d ON s.PKIdSucursal = d.FKIdSucursal_SIS
LEFT JOIN SIS.UsuarioDepartamento ud ON d.PKIdDepartamento = ud.FKIdDepartamento_SIS AND ud.Activo = 1
GROUP BY s.PKIdSucursal, s.Nombre
ORDER BY s.Nombre;

-- Ver usuarios con múltiples asignaciones
SELECT 
    u.Nombre + ' ' + u.ApellidoPaterno AS Usuario,
    COUNT(DISTINCT us.FKIdSucursal_SIS) AS SucursalesDirectas,
    COUNT(DISTINCT d.FKIdSucursal_SIS) AS SucursalesPorDepto
FROM SIS.Usuario u
LEFT JOIN SIS.UsuarioSucursal us ON u.PkIdUsuario = us.FKIdUsuario_SIS AND us.Activo = 1
LEFT JOIN SIS.UsuarioDepartamento ud ON u.PkIdUsuario = ud.FKIdUsuario_SIS AND ud.Activo = 1
LEFT JOIN SIS.Departamento d ON ud.FKIdDepartamento_SIS = d.PKIdDepartamento
GROUP BY u.PkIdUsuario, u.Nombre, u.ApellidoPaterno
HAVING COUNT(DISTINCT us.FKIdSucursal_SIS) > 1 OR COUNT(DISTINCT d.FKIdSucursal_SIS) > 1
ORDER BY Usuario;

-- Ver estructura completa con la vista
SELECT * FROM SIS.VW_UsuarioInfo;
SELECT * FROM SIS.VW_SucursalesPorUsuario;
GO