-- Inserts sugeridos para menu/claims de Nomina.
-- El usuario indico NO aplicarlos automaticamente. Ajustar IDs si ya existen.

EXEC spConfiguracionDeRolYClaims 'Nomina', 'Concepto', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Concepto_Factor', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Concepto_Fijo', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Concepto_Porcentaje', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Concepto_Proporcional', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Concepto_Tabular', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Concepto_Variable', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Contrato_Terceros', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Credito', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Descuento_Credito', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Descuento_Infonavit', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Estatus_Pago', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Factor_Integracion', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Infonavit', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Periodo_Activo', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Salario_Minimo', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Sueldo_Especial', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Sueldo_LiqFin', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Sueldo_Mensual', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Sueldo_Quincenal', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Sueldo_Semanal', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Tipo_Incapacidad', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Tipo_Pago', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Tipo_Pension', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Empresa_Nomina', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Universo', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Nivel', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Clase_Puesto', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Puesto', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Nombramiento', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Importe_Nivel', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Contrato_Laboral', '10000', 'view,view-menu,delete,new,update,CanExportToExcel';
EXEC spConfiguracionDeRolYClaims 'Nomina', 'Procesos', '10000', 'view,view-menu,new,authorize';

MERGE INTO SIS.Menu AS TARGET
USING (VALUES
    -- Modulo principal
    (7, N'Nómina', 1, NULL, N'Nómina', N'/', N'FaMoneyBillWave', 1, N'ESP', 7, 1, GETDATE()),

    -- Nómina -> Configuración -> Catálogos
    (750, N'Configuración', 1, 7, N'Configuración', N'/', N'FaCog', 1, N'ESP', 1, 1, GETDATE()),
    (751, N'Catálogos', 1, 750, N'Catálogos', N'/', N'FaFolderOpen', 1, N'ESP', 1, 1, GETDATE()),
    (752, N'Conceptos', 2, 751, N'Conceptos', N'/nomina/configuracion/catalogos/conceptos', N'FaPayments', 1, N'ESP', 1, 1, GETDATE()),
    (753, N'Factores de concepto', 2, 751, N'Factores de concepto', N'/nomina/configuracion/catalogos/concepto-factor', N'FaCalculate', 1, N'ESP', 2, 1, GETDATE()),
    (754, N'Conceptos fijos', 2, 751, N'Conceptos fijos', N'/nomina/configuracion/catalogos/conceptos-fijos', N'FaAttachMoney', 1, N'ESP', 3, 1, GETDATE()),
    (755, N'Conceptos porcentaje', 2, 751, N'Conceptos porcentaje', N'/nomina/configuracion/catalogos/conceptos-porcentaje', N'FaPercent', 1, N'ESP', 4, 1, GETDATE()),
    (756, N'Conceptos proporcionales', 2, 751, N'Conceptos proporcionales', N'/nomina/configuracion/catalogos/conceptos-proporcionales', N'FaPieChart', 1, N'ESP', 5, 1, GETDATE()),
    (757, N'Conceptos tabulares', 2, 751, N'Conceptos tabulares', N'/nomina/configuracion/catalogos/conceptos-tabulares', N'FaTableRows', 1, N'ESP', 6, 1, GETDATE()),
    (758, N'Conceptos variables', 2, 751, N'Conceptos variables', N'/nomina/configuracion/catalogos/conceptos-variables', N'FaTune', 1, N'ESP', 7, 1, GETDATE()),
    (759, N'Contratos de terceros', 2, 751, N'Contratos de terceros', N'/nomina/configuracion/catalogos/contratos-terceros', N'FaAssignment', 1, N'ESP', 8, 1, GETDATE()),
    (760, N'Créditos', 2, 751, N'Créditos', N'/nomina/configuracion/catalogos/creditos', N'FaCreditCard', 1, N'ESP', 9, 1, GETDATE()),
    (761, N'Descuentos crédito', 2, 751, N'Descuentos crédito', N'/nomina/configuracion/catalogos/descuentos-credito', N'FaMoneyOff', 1, N'ESP', 10, 1, GETDATE()),
    (762, N'Descuentos Infonavit', 2, 751, N'Descuentos Infonavit', N'/nomina/configuracion/catalogos/descuentos-infonavit', N'FaHomeWork', 1, N'ESP', 11, 1, GETDATE()),
    (763, N'Estatus de pago', 2, 751, N'Estatus de pago', N'/nomina/configuracion/catalogos/estatus-pago', N'FaVerified', 1, N'ESP', 12, 1, GETDATE()),
    (764, N'Factores de integración', 2, 751, N'Factores de integración', N'/nomina/configuracion/catalogos/factores-integracion', N'FaFunctions', 1, N'ESP', 13, 1, GETDATE()),
    (765, N'Infonavit', 2, 751, N'Infonavit', N'/nomina/configuracion/catalogos/infonavit', N'FaHouse', 1, N'ESP', 14, 1, GETDATE()),
    (766, N'Periodos activos', 2, 751, N'Periodos activos', N'/nomina/configuracion/catalogos/periodos-activos', N'FaEventAvailable', 1, N'ESP', 15, 1, GETDATE()),
    (767, N'Salarios mínimos', 2, 751, N'Salarios mínimos', N'/nomina/configuracion/catalogos/salarios-minimos', N'FaPriceChange', 1, N'ESP', 16, 1, GETDATE()),
    (768, N'Sueldos especiales', 2, 751, N'Sueldos especiales', N'/nomina/configuracion/catalogos/sueldos-especiales', N'FaStar', 1, N'ESP', 17, 1, GETDATE()),
    (769, N'Sueldos liquidación finiquito', 2, 751, N'Sueldos liquidación finiquito', N'/nomina/configuracion/catalogos/sueldos-liquidacion-finiquito', N'FaReceiptLong', 1, N'ESP', 18, 1, GETDATE()),
    (770, N'Sueldos mensuales', 2, 751, N'Sueldos mensuales', N'/nomina/configuracion/catalogos/sueldos-mensuales', N'FaCalendarMonth', 1, N'ESP', 19, 1, GETDATE()),
    (771, N'Sueldos quincenales', 2, 751, N'Sueldos quincenales', N'/nomina/configuracion/catalogos/sueldos-quincenales', N'FaDateRange', 1, N'ESP', 20, 1, GETDATE()),
    (772, N'Sueldos semanales', 2, 751, N'Sueldos semanales', N'/nomina/configuracion/catalogos/sueldos-semanales', N'FaViewWeek', 1, N'ESP', 21, 1, GETDATE()),
    (773, N'Tipos de incapacidad', 2, 751, N'Tipos de incapacidad', N'/nomina/configuracion/catalogos/tipos-incapacidad', N'FaSick', 1, N'ESP', 22, 1, GETDATE()),
    (774, N'Tipos de pago nómina', 2, 751, N'Tipos de pago nómina', N'/nomina/configuracion/catalogos/tipos-pago', N'FaPointOfSale', 1, N'ESP', 23, 1, GETDATE()),
    (775, N'Tipos de pensión', 2, 751, N'Tipos de pensión', N'/nomina/configuracion/catalogos/tipos-pension', N'FaFamilyRestroom', 1, N'ESP', 24, 1, GETDATE()),

    -- Nómina -> Procesos
    (790, N'Empresas de nomina', 2, 751, N'Empresas de nomina', N'/nomina/configuracion/catalogos/empresas-nomina', N'FaBuilding', 1, N'ESP', 25, 1, GETDATE()),
    (791, N'Universos', 2, 751, N'Universos', N'/nomina/configuracion/catalogos/universos', N'FaLayerGroup', 1, N'ESP', 26, 1, GETDATE()),
    (792, N'Niveles', 2, 751, N'Niveles', N'/nomina/configuracion/catalogos/niveles', N'FaSitemap', 1, N'ESP', 27, 1, GETDATE()),
    (793, N'Clases de puesto', 2, 751, N'Clases de puesto', N'/nomina/configuracion/catalogos/clases-puesto', N'FaUserTie', 1, N'ESP', 28, 1, GETDATE()),
    (794, N'Puestos', 2, 751, N'Puestos', N'/nomina/configuracion/catalogos/puestos', N'FaIdBadge', 1, N'ESP', 29, 1, GETDATE()),
    (795, N'Nombramientos', 2, 751, N'Nombramientos', N'/nomina/configuracion/catalogos/nombramientos', N'FaAddressCard', 1, N'ESP', 30, 1, GETDATE()),
    (796, N'Importes por nivel', 2, 751, N'Importes por nivel', N'/nomina/configuracion/catalogos/importes-nivel', N'FaMoneyBillWave', 1, N'ESP', 31, 1, GETDATE()),
    (797, N'Contratos laborales', 2, 751, N'Contratos laborales', N'/nomina/configuracion/catalogos/contratos-laborales', N'FaFileContract', 1, N'ESP', 32, 1, GETDATE()),

    (780, N'Procesos', 1, 7, N'Procesos', N'/', N'FaGears', 1, N'ESP', 2, 1, GETDATE()),
    (781, N'Procesos de Nómina', 2, 780, N'Procesos de Nómina', N'/nomina/procesos', N'FaCalculate', 1, N'ESP', 1, 1, GETDATE())
) AS SOURCE (PKIdMenu, Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta, ImageUrl, Activo, Lenguaje, [Orden], CreatedByOperatorId, CreatedDateTime)
ON TARGET.PKIdMenu = SOURCE.PKIdMenu
WHEN MATCHED THEN
    UPDATE SET
        TARGET.Nombre = SOURCE.Nombre,
        TARGET.Tipo = SOURCE.Tipo,
        TARGET.FKIdMenu_SIS = SOURCE.FKIdMenu_SIS,
        TARGET.LegacyName = SOURCE.LegacyName,
        TARGET.Ruta = SOURCE.Ruta,
        TARGET.ImageUrl = SOURCE.ImageUrl,
        TARGET.Activo = SOURCE.Activo,
        TARGET.Lenguaje = SOURCE.Lenguaje,
        TARGET.[Orden] = SOURCE.[Orden],
        TARGET.CreatedByOperatorId = SOURCE.CreatedByOperatorId,
        TARGET.CreatedDateTime = SOURCE.CreatedDateTime
WHEN NOT MATCHED BY TARGET THEN
    INSERT (PKIdMenu, Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta, ImageUrl, Activo, Lenguaje, [Orden], CreatedByOperatorId, CreatedDateTime)
    VALUES (SOURCE.PKIdMenu, SOURCE.Nombre, SOURCE.Tipo, SOURCE.FKIdMenu_SIS, SOURCE.LegacyName, SOURCE.Ruta, SOURCE.ImageUrl, SOURCE.Activo, SOURCE.Lenguaje, SOURCE.[Orden], SOURCE.CreatedByOperatorId, SOURCE.CreatedDateTime);
