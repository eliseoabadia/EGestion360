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

-- Nodo padre sugerido:
-- (9000, N'Nomina', 1, NULL, N'Nomina', N'/nomina', N'FaMoneyBillWave', 1, N'ESP', 50, 1, GETDATE())

MERGE INTO SIS.Menu AS TARGET
USING (VALUES
(9001, N'Conceptos', 2, 9000, N'Conceptos', N'/nomina/configuracion/catalogos/conceptos', N'FaPayments', 1, N'ESP', 1, 1, GETDATE()),
(9002, N'Factores de concepto', 2, 9000, N'Factores de concepto', N'/nomina/configuracion/catalogos/concepto-factor', N'FaCalculate', 1, N'ESP', 2, 1, GETDATE()),
(9003, N'Conceptos fijos', 2, 9000, N'Conceptos fijos', N'/nomina/configuracion/catalogos/conceptos-fijos', N'FaAttachMoney', 1, N'ESP', 3, 1, GETDATE()),
(9004, N'Conceptos porcentaje', 2, 9000, N'Conceptos porcentaje', N'/nomina/configuracion/catalogos/conceptos-porcentaje', N'FaPercent', 1, N'ESP', 4, 1, GETDATE()),
(9005, N'Conceptos proporcionales', 2, 9000, N'Conceptos proporcionales', N'/nomina/configuracion/catalogos/conceptos-proporcionales', N'FaPieChart', 1, N'ESP', 5, 1, GETDATE()),
(9006, N'Conceptos tabulares', 2, 9000, N'Conceptos tabulares', N'/nomina/configuracion/catalogos/conceptos-tabulares', N'FaTableRows', 1, N'ESP', 6, 1, GETDATE()),
(9007, N'Conceptos variables', 2, 9000, N'Conceptos variables', N'/nomina/configuracion/catalogos/conceptos-variables', N'FaTune', 1, N'ESP', 7, 1, GETDATE()),
(9008, N'Contratos de terceros', 2, 9000, N'Contratos de terceros', N'/nomina/configuracion/catalogos/contratos-terceros', N'FaAssignment', 1, N'ESP', 8, 1, GETDATE()),
(9009, N'Creditos', 2, 9000, N'Creditos', N'/nomina/configuracion/catalogos/creditos', N'FaCreditCard', 1, N'ESP', 9, 1, GETDATE()),
(9010, N'Descuentos credito', 2, 9000, N'Descuentos credito', N'/nomina/configuracion/catalogos/descuentos-credito', N'FaMoneyOff', 1, N'ESP', 10, 1, GETDATE()),
(9011, N'Descuentos Infonavit', 2, 9000, N'Descuentos Infonavit', N'/nomina/configuracion/catalogos/descuentos-infonavit', N'FaHomeWork', 1, N'ESP', 11, 1, GETDATE()),
(9012, N'Estatus de pago', 2, 9000, N'Estatus de pago', N'/nomina/configuracion/catalogos/estatus-pago', N'FaVerified', 1, N'ESP', 12, 1, GETDATE()),
(9013, N'Factores de integracion', 2, 9000, N'Factores de integracion', N'/nomina/configuracion/catalogos/factores-integracion', N'FaFunctions', 1, N'ESP', 13, 1, GETDATE()),
(9014, N'Infonavit', 2, 9000, N'Infonavit', N'/nomina/configuracion/catalogos/infonavit', N'FaHouse', 1, N'ESP', 14, 1, GETDATE()),
(9015, N'Periodos activos', 2, 9000, N'Periodos activos', N'/nomina/configuracion/catalogos/periodos-activos', N'FaEventAvailable', 1, N'ESP', 15, 1, GETDATE()),
(9016, N'Salarios minimos', 2, 9000, N'Salarios minimos', N'/nomina/configuracion/catalogos/salarios-minimos', N'FaPriceChange', 1, N'ESP', 16, 1, GETDATE()),
(9017, N'Sueldos especiales', 2, 9000, N'Sueldos especiales', N'/nomina/configuracion/catalogos/sueldos-especiales', N'FaStar', 1, N'ESP', 17, 1, GETDATE()),
(9018, N'Sueldos liquidacion finiquito', 2, 9000, N'Sueldos liquidacion finiquito', N'/nomina/configuracion/catalogos/sueldos-liquidacion-finiquito', N'FaReceiptLong', 1, N'ESP', 18, 1, GETDATE()),
(9019, N'Sueldos mensuales', 2, 9000, N'Sueldos mensuales', N'/nomina/configuracion/catalogos/sueldos-mensuales', N'FaCalendarMonth', 1, N'ESP', 19, 1, GETDATE()),
(9020, N'Sueldos quincenales', 2, 9000, N'Sueldos quincenales', N'/nomina/configuracion/catalogos/sueldos-quincenales', N'FaDateRange', 1, N'ESP', 20, 1, GETDATE()),
(9021, N'Sueldos semanales', 2, 9000, N'Sueldos semanales', N'/nomina/configuracion/catalogos/sueldos-semanales', N'FaViewWeek', 1, N'ESP', 21, 1, GETDATE()),
(9022, N'Tipos de incapacidad', 2, 9000, N'Tipos de incapacidad', N'/nomina/configuracion/catalogos/tipos-incapacidad', N'FaSick', 1, N'ESP', 22, 1, GETDATE()),
(9023, N'Tipos de pago nomina', 2, 9000, N'Tipos de pago nomina', N'/nomina/configuracion/catalogos/tipos-pago', N'FaPointOfSale', 1, N'ESP', 23, 1, GETDATE()),
(9024, N'Tipos de pension', 2, 9000, N'Tipos de pension', N'/nomina/configuracion/catalogos/tipos-pension', N'FaFamilyRestroom', 1, N'ESP', 24, 1, GETDATE())
) AS SOURCE ([PKIdMenu], [Nombre], [Tipo], [FKIdPadre], [Descripcion], [Url], [Icono], [Activo], [Idioma], [Orden], [Visible], [FechaCreacion])
ON TARGET.[PKIdMenu] = SOURCE.[PKIdMenu]
WHEN MATCHED THEN
    UPDATE SET
        [Nombre] = SOURCE.[Nombre],
        [Tipo] = SOURCE.[Tipo],
        [FKIdPadre] = SOURCE.[FKIdPadre],
        [Descripcion] = SOURCE.[Descripcion],
        [Url] = SOURCE.[Url],
        [Icono] = SOURCE.[Icono],
        [Activo] = SOURCE.[Activo],
        [Idioma] = SOURCE.[Idioma],
        [Orden] = SOURCE.[Orden],
        [Visible] = SOURCE.[Visible]
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([PKIdMenu], [Nombre], [Tipo], [FKIdPadre], [Descripcion], [Url], [Icono], [Activo], [Idioma], [Orden], [Visible], [FechaCreacion])
    VALUES (SOURCE.[PKIdMenu], SOURCE.[Nombre], SOURCE.[Tipo], SOURCE.[FKIdPadre], SOURCE.[Descripcion], SOURCE.[Url], SOURCE.[Icono], SOURCE.[Activo], SOURCE.[Idioma], SOURCE.[Orden], SOURCE.[Visible], SOURCE.[FechaCreacion]);