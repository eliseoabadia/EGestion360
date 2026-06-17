-- Menu y claims de Nomina.
-- Arbol alineado al menu legado: Nomina operativa y Configuracion Nominas como raiz independiente.
-- Los nodos sin pagina/API migrada quedan inactivos para evitar rutas rotas.

SET NOCOUNT ON;

DECLARE @RoleCode NVARCHAR(10) = N'10000';
DECLARE @Now DATETIME = GETDATE();

IF OBJECT_ID('tempdb..#NominaClaims') IS NOT NULL
    DROP TABLE #NominaClaims;

CREATE TABLE #NominaClaims
(
    ClaimTypeId INT NOT NULL,
    Name NVARCHAR(150) NOT NULL,
    [Group] NVARCHAR(100) NOT NULL,
    RoleId NVARCHAR(128) NULL,
    TokenFormat NVARCHAR(50) NOT NULL,
    Created DATETIME NOT NULL,
    SubGroup NVARCHAR(100) NOT NULL,
    Code NVARCHAR(10) NOT NULL,
    [Description] NVARCHAR(200) NOT NULL,
    [Values] VARCHAR(MAX) NOT NULL,
    ReferenceId INT NOT NULL
);

INSERT INTO #NominaClaims (ClaimTypeId, Name, [Group], RoleId, TokenFormat, Created, SubGroup, Code, [Description], [Values], ReferenceId)
VALUES
(2, N'Nomina', N'Nomina', NULL, N'app://{0}/{1}', @Now, N'Nomina', N'NOM001', N'Nomina', 'view,view-menu', 0),
(2, N'Nomina', N'Nomina', NULL, N'app://{0}/{1}', @Now, N'Nomina_Calculo', N'NOM002', N'Calculo', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina', NULL, N'app://{0}/{1}', @Now, N'Concepto_Variable', N'NOM003', N'Pagos Extraordinarios', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina', NULL, N'app://{0}/{1}', @Now, N'Infonavit', N'NOM004', N'Infonavit', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina', NULL, N'app://{0}/{1}', @Now, N'Procesos', N'NOM005', N'Procesos', 'view,view-menu,delete,new,update', 0),

(2, N'Nomina', N'Configuracion_Nominas', NULL, N'app://{0}/{1}', @Now, N'Nomina_Catalogos', N'NOM100', N'Catalogos', 'view,view-menu', 0),
(2, N'Nomina', N'Configuracion_Nominas', NULL, N'app://{0}/{1}', @Now, N'Nomina_Periodos', N'NOM101', N'Periodos', 'view,view-menu', 0),
(2, N'Nomina', N'Configuracion_Nominas', NULL, N'app://{0}/{1}', @Now, N'Nomina_Tablas_ISR', N'NOM102', N'Tablas ISR', 'view,view-menu', 0),
(2, N'Nomina', N'Configuracion_Nominas', NULL, N'app://{0}/{1}', @Now, N'Nomina_Subsidios_ISR', N'NOM103', N'Subsidios ISR', 'view,view-menu', 0),
(2, N'Nomina', N'Configuracion_Nominas', NULL, N'app://{0}/{1}', @Now, N'Nomina_IMSS', N'NOM104', N'IMSS', 'view,view-menu', 0),

(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Concepto', N'NOM200', N'Conceptos de Nomina', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Concepto_Factor', N'NOM201', N'Factores de concepto', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Concepto_Fijo', N'NOM202', N'Conceptos fijos', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Concepto_Porcentaje', N'NOM203', N'Conceptos porcentaje', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Concepto_Proporcional', N'NOM204', N'Conceptos proporcionales', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Concepto_Tabular', N'NOM205', N'Tabulador', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Concepto_Variable', N'NOM206', N'Conceptos variables', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Contrato_Terceros', N'NOM207', N'Contratos de terceros', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Credito', N'NOM208', N'Creditos', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Descuento_Credito', N'NOM209', N'Descuentos credito', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Descuento_Infonavit', N'NOM210', N'Descuentos Infonavit', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Estatus_Pago', N'NOM211', N'Estatus de pago', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Factor_Integracion', N'NOM212', N'Factor de integracion', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Infonavit', N'NOM213', N'Infonavit', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Periodo_Activo', N'NOM214', N'Periodos activos', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Salario_Minimo', N'NOM215', N'Salario Minimo General', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Sueldo_Especial', N'NOM216', N'Sueldos especiales', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Sueldo_LiqFin', N'NOM217', N'Sueldos liquidacion finiquito', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Sueldo_Mensual', N'NOM218', N'Sueldos mensuales', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Sueldo_Quincenal', N'NOM219', N'Sueldos quincenales', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Sueldo_Semanal', N'NOM220', N'Sueldos semanales', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Tipo_Incapacidad', N'NOM221', N'Tipos de incapacidad', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Tipo_Pago', N'NOM222', N'Tipo de Pago', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Tipo_Pension', N'NOM223', N'Tipos de pension', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Empresa_Nomina', N'NOM224', N'Empresas de nomina', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Universo', N'NOM225', N'Universos', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Nivel', N'NOM226', N'Niveles', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Clase_Puesto', N'NOM227', N'Clases de puesto', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Puesto', N'NOM228', N'Puestos', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Nombramiento', N'NOM229', N'Nombramientos', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Importe_Nivel', N'NOM230', N'Importes por nivel', 'view,view-menu,delete,new,update', 0),
(2, N'Nomina', N'Nomina_Catalogos', NULL, N'app://{0}/{1}', @Now, N'Contrato_Laboral', N'NOM231', N'Contratos laborales', 'view,view-menu,delete,new,update', 0);

INSERT INTO dbo.AspNetClaims (ClaimTypeId, Name, [Group], RoleId, TokenFormat, Created, SubGroup, Code, [Description], [Values], ReferenceId)
SELECT c.ClaimTypeId, c.Name, c.[Group], c.RoleId, c.TokenFormat, c.Created, c.SubGroup, c.Code, c.[Description], c.[Values], c.ReferenceId
FROM #NominaClaims c
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.AspNetClaims ac
    WHERE ac.RoleId IS NULL
      AND ac.[Group] = c.[Group]
      AND ac.SubGroup = c.SubGroup
);

EXEC spConfiguracionDeRolYClaims 'Nomina', 'Nomina', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Nomina_Calculo', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Concepto_Variable', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Infonavit', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Procesos', '10000', 'view,view-menu,delete,new,update';

EXEC spConfiguracionDeRolYClaims 'Configuracion_Nominas', 'Nomina_Catalogos', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Configuracion_Nominas', 'Nomina_Periodos', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Configuracion_Nominas', 'Nomina_Tablas_ISR', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Configuracion_Nominas', 'Nomina_Subsidios_ISR', '10000', 'view,view-menu';
EXEC spConfiguracionDeRolYClaims 'Configuracion_Nominas', 'Nomina_IMSS', '10000', 'view,view-menu';

EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Concepto', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Concepto_Factor', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Concepto_Fijo', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Concepto_Porcentaje', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Concepto_Proporcional', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Concepto_Tabular', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Concepto_Variable', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Contrato_Terceros', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Credito', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Descuento_Credito', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Descuento_Infonavit', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Estatus_Pago', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Factor_Integracion', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Infonavit', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Periodo_Activo', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Salario_Minimo', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Sueldo_Especial', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Sueldo_LiqFin', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Sueldo_Mensual', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Sueldo_Quincenal', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Sueldo_Semanal', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Tipo_Incapacidad', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Tipo_Pago', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Tipo_Pension', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Empresa_Nomina', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Universo', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Nivel', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Clase_Puesto', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Puesto', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Nombramiento', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Importe_Nivel', '10000', 'view,view-menu,delete,new,update';
EXEC spConfiguracionDeRolYClaims 'Nomina_Catalogos', 'Contrato_Laboral', '10000', 'view,view-menu,delete,new,update';

IF OBJECT_ID('tempdb..#NominaMenu') IS NOT NULL
    DROP TABLE #NominaMenu;

CREATE TABLE #NominaMenu
(
    PKIdMenu INT NOT NULL PRIMARY KEY,
    Nombre NVARCHAR(150) NOT NULL,
    Tipo INT NOT NULL,
    FKIdMenu_SIS INT NULL,
    LegacyName NVARCHAR(80) NULL,
    Ruta NVARCHAR(200) NULL,
    ImageUrl NVARCHAR(120) NULL,
    Lenguaje CHAR(3) NOT NULL,
    [Orden] INT NULL,
    Activo BIT NOT NULL,
    CreatedByOperatorId INT NULL,
    CreatedDateTime DATETIME NOT NULL
);

INSERT INTO #NominaMenu (PKIdMenu, Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta, ImageUrl, Lenguaje, [Orden], Activo, CreatedByOperatorId, CreatedDateTime)
VALUES
(7, N'Nomina', 1, NULL, N'Nomina', N'/', N'FaMoneyBillWave', N'ESP', 2, 1, 1, @Now),
(720, N'Finiquito/Liquidacion', 2, 7, N'Nomina_Finiquito_Liquidacion', N'/', N'FaReceiptLong', N'ESP', 1, 0, 1, @Now),
(721, N'Auxiliares', 1, 7, N'Nomina_Auxiliares', N'/', N'FaFolderOpen', N'ESP', 2, 0, 1, @Now),
(730, N'Incidencias', 1, 7, N'Nomina_Incidencias', N'/', N'RiListCheck2', N'ESP', 3, 0, 1, @Now),
(731, N'Captura de Incidencias', 2, 730, N'Captura_Incidencias', N'/', N'FaEdit', N'ESP', 1, 0, 1, @Now),
(732, N'Justificacion de Incidencias', 2, 730, N'Justificacion_Incidencias', N'/', N'FaVerified', N'ESP', 2, 0, 1, @Now),
(733, N'Pagos Extraordinarios', 2, 7, N'Concepto_Variable', N'/nom/conceptovariable', N'FaAttachMoney', N'ESP', 4, 1, 1, @Now),
(734, N'Calculo', 2, 7, N'Nomina_Calculo', N'/nom/calcnomina', N'FaCalculate', N'ESP', 5, 1, 1, @Now),
(735, N'Productos', 1, 7, N'Nomina_Productos', N'/', N'FaFolderOpen', N'ESP', 6, 0, 1, @Now),
(736, N'Cierre de Periodo', 2, 7, N'Nomina_Cierre_Periodo', N'/', N'FaLock', N'ESP', 7, 0, 1, @Now),
(737, N'Pension Alimenticia', 2, 7, N'Pension_Alimenticia', N'/', N'FaFamilyRestroom', N'ESP', 8, 0, 1, @Now),
(738, N'Infonavit', 2, 7, N'Infonavit', N'/nom/infonavit', N'FaHouse', N'ESP', 9, 1, 1, @Now),
(739, N'Procesos', 2, 7, N'Procesos', N'/nomina/procesos', N'FaGears', N'ESP', 10, 1, 1, @Now),

(740, N'Configuracion Nominas', 1, NULL, N'Configuracion_Nominas', N'/', N'FaCog', N'ESP', 6, 1, 1, @Now),
(741, N'Periodos', 1, 740, N'Nomina_Periodos', N'/', N'RiListCheck2', N'ESP', 1, 0, 1, @Now),
(742, N'Semanal', 2, 741, N'Periodo_Semanal', N'/', N'FaViewWeek', N'ESP', 1, 0, 1, @Now),
(743, N'Quincenal', 2, 741, N'Periodo_Quincenal', N'/', N'FaDateRange', N'ESP', 2, 0, 1, @Now),
(744, N'Mensual', 2, 741, N'Periodo_Mensual', N'/', N'FaCalendarMonth', N'ESP', 3, 0, 1, @Now),
(745, N'Bimestral', 2, 741, N'Periodo_Bimestral', N'/', N'FaCalendar', N'ESP', 4, 0, 1, @Now),
(746, N'Tablas ISR', 1, 740, N'Nomina_Tablas_ISR', N'/', N'FaTable', N'ESP', 2, 0, 1, @Now),
(747, N'Subsidios ISR', 1, 740, N'Nomina_Subsidios_ISR', N'/', N'FaPayments', N'ESP', 3, 0, 1, @Now),
(748, N'IMSS', 1, 740, N'Nomina_IMSS', N'/', N'FaVerified', N'ESP', 4, 0, 1, @Now),
(749, N'Catalogos', 1, 740, N'Nomina_Catalogos', N'/', N'FaFolderOpen', N'ESP', 5, 1, 1, @Now),

(750, N'Forma de Pago', 2, 749, N'Tipo_Pago', N'/nomina/configuracion/catalogos/tipos-pago', N'FaPointOfSale', N'ESP', 1, 1, 1, @Now),
(751, N'Tipo de Contratacion', 2, 749, N'Tipo_Contratacion', N'/', N'FaAssignment', N'ESP', 2, 0, 1, @Now),
(752, N'Tipo de descanso', 2, 749, N'Tipo_Descanso', N'/', N'FaClock', N'ESP', 3, 0, 1, @Now),
(753, N'Tipo de Incidencia', 2, 749, N'Tipo_Incidencia', N'/', N'FaSick', N'ESP', 4, 0, 1, @Now),
(754, N'Tipo de Justificacion', 2, 749, N'Tipo_Justificacion', N'/', N'FaVerified', N'ESP', 5, 0, 1, @Now),
(755, N'Tipo de Nomina', 2, 749, N'Tipo_Nomina', N'/', N'FaEventAvailable', N'ESP', 6, 0, 1, @Now),
(756, N'Tabulador', 2, 749, N'Concepto_Tabular', N'/nom/conceptotabular', N'FaTableRows', N'ESP', 7, 1, 1, @Now),
(757, N'Cuotas IMSS', 2, 749, N'Cuotas_IMSS', N'/', N'FaPercent', N'ESP', 8, 0, 1, @Now),
(758, N'UMA', 2, 749, N'UMA', N'/', N'FaPriceChange', N'ESP', 9, 0, 1, @Now),
(759, N'Conceptos de Nomina', 2, 749, N'Concepto', N'/nom/concepto', N'FaPayments', N'ESP', 10, 1, 1, @Now),
(760, N'Unidad Infonavit', 2, 749, N'Unidad_Infonavit', N'/', N'FaHomeWork', N'ESP', 11, 0, 1, @Now),
(761, N'Salario Minimo General', 2, 749, N'Salario_Minimo', N'/sis/smg', N'FaPriceChange', N'ESP', 12, 1, 1, @Now),
(762, N'Forma de Calculo', 2, 749, N'Forma_Calculo', N'/', N'FaFunctions', N'ESP', 13, 0, 1, @Now),
(763, N'Capitulos', 2, 749, N'Capitulos', N'/', N'RiListCheck2', N'ESP', 14, 0, 1, @Now),
(764, N'Conceptos de importe Fijo', 2, 749, N'Concepto_Fijo', N'/nom/conceptofijo', N'FaAttachMoney', N'ESP', 15, 1, 1, @Now),

(765, N'Prestaciones', 1, 740, N'Nomina_Prestaciones', N'/', N'FaAssignment', N'ESP', 6, 0, 1, @Now),
(766, N'Impuestos', 1, 740, N'Nomina_Impuestos', N'/', N'FaPercent', N'ESP', 7, 0, 1, @Now);

SET IDENTITY_INSERT SIS.Menu ON;

MERGE INTO SIS.Menu AS TARGET
USING #NominaMenu AS SOURCE
ON TARGET.PKIdMenu = SOURCE.PKIdMenu
WHEN MATCHED THEN
    UPDATE SET
        TARGET.Nombre = SOURCE.Nombre,
        TARGET.Tipo = SOURCE.Tipo,
        TARGET.FKIdMenu_SIS = SOURCE.FKIdMenu_SIS,
        TARGET.LegacyName = SOURCE.LegacyName,
        TARGET.Ruta = SOURCE.Ruta,
        TARGET.ImageUrl = SOURCE.ImageUrl,
        TARGET.Lenguaje = SOURCE.Lenguaje,
        TARGET.[Orden] = SOURCE.[Orden],
        TARGET.Activo = SOURCE.Activo,
        TARGET.ModifiedByOperatorId = SOURCE.CreatedByOperatorId,
        TARGET.ModifiedDateTime = SOURCE.CreatedDateTime
WHEN NOT MATCHED BY TARGET THEN
    INSERT (PKIdMenu, Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta, ImageUrl, Lenguaje, [Orden], Activo, CreatedByOperatorId, CreatedDateTime)
    VALUES (SOURCE.PKIdMenu, SOURCE.Nombre, SOURCE.Tipo, SOURCE.FKIdMenu_SIS, SOURCE.LegacyName, SOURCE.Ruta, SOURCE.ImageUrl, SOURCE.Lenguaje, SOURCE.[Orden], SOURCE.Activo, SOURCE.CreatedByOperatorId, SOURCE.CreatedDateTime);

SET IDENTITY_INSERT SIS.Menu OFF;

MERGE INTO SIS.MenuRole AS TARGET
USING
(
    SELECT DISTINCT M.PKIdMenu, R.Id AS RoleId, 1 AS Activo, 1 AS CreatedByOperatorId, @Now AS CreatedDateTime
    FROM dbo.AspNetRoles AS R
    INNER JOIN dbo.AspNetClaims AS C ON C.RoleId = R.Id
    INNER JOIN dbo.AspNetClaimValues AS CV ON C.Id = CV.ClaimId
    INNER JOIN SIS.Menu AS M ON M.Activo = 1
    WHERE CV.Value LIKE '%view-menu%'
      AND R.Code = @RoleCode
      AND M.LegacyName IN
      (
          C.[Group],
          C.SubGroup,
          N'Nomina',
          N'Configuracion_Nominas'
      )
) AS SOURCE
ON TARGET.FKIdMenu_SIS = SOURCE.PKIdMenu
AND TARGET.RoleId = SOURCE.RoleId
WHEN MATCHED THEN
    UPDATE SET
        TARGET.Activo = SOURCE.Activo,
        TARGET.ModifiedByOperatorId = SOURCE.CreatedByOperatorId,
        TARGET.ModifiedDateTime = SOURCE.CreatedDateTime
WHEN NOT MATCHED BY TARGET THEN
    INSERT (FKIdMenu_SIS, RoleId, Activo, CreatedByOperatorId, CreatedDateTime)
    VALUES (SOURCE.PKIdMenu, SOURCE.RoleId, SOURCE.Activo, SOURCE.CreatedByOperatorId, SOURCE.CreatedDateTime);

DROP TABLE #NominaMenu;
DROP TABLE #NominaClaims;

-- Endurecimiento contra menus legacy ya aplicados: deja activo el arbol visible
-- con rutas que existen en Blazor y con iconos disponibles en IconosDisponibles.
IF OBJECT_ID('tempdb..#NominaMenuActivo') IS NOT NULL
    DROP TABLE #NominaMenuActivo;

CREATE TABLE #NominaMenuActivo
(
    PKIdMenu INT NOT NULL PRIMARY KEY,
    Nombre NVARCHAR(150) NOT NULL,
    Tipo INT NOT NULL,
    FKIdMenu_SIS INT NULL,
    LegacyName NVARCHAR(80) NULL,
    Ruta NVARCHAR(200) NULL,
    ImageUrl NVARCHAR(120) NULL,
    Lenguaje CHAR(3) NOT NULL,
    [Orden] INT NULL,
    Activo BIT NOT NULL
);

INSERT INTO #NominaMenuActivo (PKIdMenu, Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta, ImageUrl, Lenguaje, [Orden], Activo)
VALUES
(740, N'Configuracion Nominas', 1, 7, N'Configuracion_Nominas', N'/', N'FaGears', N'ESP', 1, 1),
(741, N'Catalogos', 1, 740, N'Nomina_Catalogos', N'/', N'FaFolderOpen', N'ESP', 1, 1),
(742, N'Periodos', 1, 740, N'Nomina_Periodos', N'/', N'FaEventAvailable', N'ESP', 2, 1),
(743, N'Tablas ISR', 1, 740, N'Nomina_Tablas_ISR', N'/', N'FaTable', N'ESP', 3, 1),
(744, N'Prestaciones', 1, 740, N'Nomina_Prestaciones', N'/', N'FaPayments', N'ESP', 4, 1),
(745, N'Subsidios ISR', 1, 740, N'Nomina_Subsidios_ISR', N'/', N'FaPercent', N'ESP', 5, 1),
(746, N'Impuestos', 1, 740, N'Nomina_Impuestos', N'/', N'FaReceiptLong', N'ESP', 6, 1),
(747, N'IMSS', 1, 740, N'Nomina_IMSS', N'/', N'FaHomeWork', N'ESP', 7, 1),
(751, N'Tipo de Nomina', 2, 741, N'Tipo_Nomina', N'/nomina/configuracion/catalogos/tipo-nomina', N'FaEventAvailable', N'ESP', 1, 1),
(752, N'Cuotas IMSS', 2, 741, N'Cuotas_IMSS', N'/nomina/configuracion/catalogos/cuotas-imss', N'FaHomeWork', N'ESP', 2, 1),
(753, N'Conceptos de Nomina', 2, 741, N'Concepto', N'/nomina/configuracion/catalogos/conceptos', N'FaPayments', N'ESP', 3, 1),
(754, N'UMA', 2, 741, N'UMA', N'/nomina/configuracion/catalogos/uma', N'FaPriceChange', N'ESP', 4, 1),
(755, N'Tipo de Contratacion', 2, 741, N'Tipo_Contratacion', N'/nomina/configuracion/catalogos/tipo-contratacion', N'FaAssignment', N'ESP', 5, 1),
(756, N'Tipo de descanso', 2, 741, N'Tipo_Descanso', N'/nomina/configuracion/catalogos/tipo-descanso', N'FaCalendar', N'ESP', 6, 1),
(757, N'Tipo de Incidencia', 2, 741, N'Tipo_Incidencia', N'/nomina/configuracion/catalogos/tipos-incidencia', N'FaFlag', N'ESP', 7, 1),
(758, N'Conceptos de Importe Fijo', 2, 741, N'Concepto_Fijo', N'/nomina/configuracion/catalogos/conceptos-fijos', N'FaAttachMoney', N'ESP', 8, 1),
(759, N'Tipo de Justificacion', 2, 741, N'Tipo_Justificacion', N'/nomina/configuracion/catalogos/tipo-justificacion', N'FaVerified', N'ESP', 9, 1),
(760, N'Tabulador', 2, 741, N'Concepto_Tabular', N'/nomina/configuracion/catalogos/conceptos-tabulares', N'FaTableRows', N'ESP', 10, 1),
(761, N'Unidad Infonavit', 2, 741, N'Unidad_Infonavit', N'/nomina/configuracion/catalogos/unidad-infonavit', N'FaHouse', N'ESP', 11, 1),
(762, N'Salario Minimo General', 2, 741, N'Salario_Minimo', N'/nomina/configuracion/catalogos/salarios-minimos', N'FaPriceChange', N'ESP', 12, 1),
(763, N'Forma de Pago', 2, 741, N'Tipo_Pago', N'/nomina/configuracion/catalogos/tipos-pago', N'FaPointOfSale', N'ESP', 13, 1),
(764, N'Forma de Calculo', 2, 741, N'Forma_Calculo', N'/nomina/configuracion/catalogos/forma-calculo', N'FaCalculate', N'ESP', 14, 1),
(765, N'Capitulos', 2, 741, N'Capitulos', N'/nomina/configuracion/catalogos/capitulos', N'FaFolder', N'ESP', 15, 1),
(766, N'Semanal', 2, 742, N'Periodo_Semanal', N'/nomina/configuracion/periodos/semanal', N'FaViewWeek', N'ESP', 1, 1),
(767, N'Quincenal', 2, 742, N'Periodo_Quincenal', N'/nomina/configuracion/periodos/quincenal', N'FaDateRange', N'ESP', 2, 1),
(768, N'Mensual', 2, 742, N'Periodo_Mensual', N'/nomina/configuracion/periodos/mensual', N'FaCalendarMonth', N'ESP', 3, 1),
(769, N'Bimestral', 2, 742, N'Periodo_Bimestral', N'/nomina/configuracion/periodos/bimestral', N'FaCalendar', N'ESP', 4, 1),
(770, N'Semanal', 2, 743, N'ISR_Semanal', N'/nomina/configuracion/tablas-isr/semanal', N'FaViewWeek', N'ESP', 1, 1),
(771, N'Quincenal', 2, 743, N'ISR_Quincenal', N'/nomina/configuracion/tablas-isr/quincenal', N'FaDateRange', N'ESP', 2, 1),
(772, N'Mensual', 2, 743, N'ISR_Mensual', N'/nomina/configuracion/tablas-isr/mensual', N'FaCalendarMonth', N'ESP', 3, 1),
(773, N'Semanal', 2, 745, N'Subsidio_ISR_Semanal', N'/nomina/configuracion/subsidios-isr/semanal', N'FaViewWeek', N'ESP', 1, 1),
(774, N'Quincenal', 2, 745, N'Subsidio_ISR_Quincenal', N'/nomina/configuracion/subsidios-isr/quincenal', N'FaDateRange', N'ESP', 2, 1),
(775, N'Mensual', 2, 745, N'Subsidio_ISR_Mensual', N'/nomina/configuracion/subsidios-isr/mensual', N'FaCalendarMonth', N'ESP', 3, 1),
(776, N'Base Gravable', 2, 746, N'Base_Gravable', N'/nomina/configuracion/impuestos/base-gravable', N'FaReceiptLong', N'ESP', 1, 1),
(777, N'Impuestos Locales', 2, 746, N'Impuestos_Locales', N'/nomina/configuracion/impuestos/locales', N'FaPercent', N'ESP', 2, 1),
(778, N'Prestaciones Minimas de Ley', 2, 747, N'Prestaciones_Minimas_Ley', N'/nomina/configuracion/imss/prestaciones-minimas', N'FaVerified', N'ESP', 1, 1),
(779, N'Clase IMSS', 2, 747, N'Clase_IMSS', N'/nomina/configuracion/imss/clase-imss', N'FaHomeWork', N'ESP', 2, 1),
(780, N'Procesos de Nomina', 2, 7, N'Procesos', N'/nomina/procesos', N'FaCalculate', N'ESP', 2, 1),
(781, N'Fraccion IMSS', 2, 747, N'Fraccion_IMSS', N'/nomina/configuracion/imss/fraccion-imss', N'RiListCheck2', N'ESP', 3, 1);

SET IDENTITY_INSERT SIS.Menu ON;

MERGE INTO SIS.Menu AS TARGET
USING #NominaMenuActivo AS SOURCE
ON TARGET.PKIdMenu = SOURCE.PKIdMenu
WHEN MATCHED THEN
    UPDATE SET
        TARGET.Nombre = SOURCE.Nombre,
        TARGET.Tipo = SOURCE.Tipo,
        TARGET.FKIdMenu_SIS = SOURCE.FKIdMenu_SIS,
        TARGET.LegacyName = SOURCE.LegacyName,
        TARGET.Ruta = SOURCE.Ruta,
        TARGET.ImageUrl = SOURCE.ImageUrl,
        TARGET.Lenguaje = SOURCE.Lenguaje,
        TARGET.[Orden] = SOURCE.[Orden],
        TARGET.Activo = SOURCE.Activo,
        TARGET.ModifiedByOperatorId = 1,
        TARGET.ModifiedDateTime = @Now
WHEN NOT MATCHED BY TARGET THEN
    INSERT (PKIdMenu, Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta, ImageUrl, Lenguaje, [Orden], Activo, CreatedByOperatorId, CreatedDateTime)
    VALUES (SOURCE.PKIdMenu, SOURCE.Nombre, SOURCE.Tipo, SOURCE.FKIdMenu_SIS, SOURCE.LegacyName, SOURCE.Ruta, SOURCE.ImageUrl, SOURCE.Lenguaje, SOURCE.[Orden], SOURCE.Activo, 1, @Now);

SET IDENTITY_INSERT SIS.Menu OFF;

MERGE INTO SIS.MenuRole AS TARGET
USING
(
    SELECT m.PKIdMenu, r.Id AS RoleId, 1 AS Activo, 1 AS CreatedByOperatorId, @Now AS CreatedDateTime
    FROM #NominaMenuActivo m
    CROSS JOIN dbo.AspNetRoles r
    WHERE m.Activo = 1
      AND r.Code = @RoleCode
) AS SOURCE
ON TARGET.FKIdMenu_SIS = SOURCE.PKIdMenu
AND TARGET.RoleId = SOURCE.RoleId
WHEN MATCHED THEN
    UPDATE SET
        TARGET.Activo = SOURCE.Activo,
        TARGET.ModifiedByOperatorId = SOURCE.CreatedByOperatorId,
        TARGET.ModifiedDateTime = SOURCE.CreatedDateTime
WHEN NOT MATCHED BY TARGET THEN
    INSERT (FKIdMenu_SIS, RoleId, Activo, CreatedByOperatorId, CreatedDateTime)
    VALUES (SOURCE.PKIdMenu, SOURCE.RoleId, SOURCE.Activo, SOURCE.CreatedByOperatorId, SOURCE.CreatedDateTime);

DROP TABLE #NominaMenuActivo;
