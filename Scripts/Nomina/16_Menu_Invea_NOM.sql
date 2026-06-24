-- Menu Invea de Nomina/RH migrado al arbol 610-930.
-- Aplica las filas del menu entregadas para Nomina y sincroniza claims del rol 10000.

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @RoleCode NVARCHAR(10) = N'10000';
DECLARE @Now DATETIME = GETDATE();
DECLARE @RoleId NVARCHAR(128);

SELECT @RoleId = Id
FROM dbo.AspNetRoles
WHERE Code = @RoleCode;

IF @RoleId IS NULL
BEGIN
    RAISERROR('No existe rol con Code=%s para migrar el menu de Nomina.', 16, 1, @RoleCode);
    RETURN;
END;

IF NOT EXISTS (SELECT 1 FROM SIS.Menu WHERE PKIdMenu = 7)
BEGIN
    RAISERROR('No existe el menu raiz PKIdMenu=7 para Nomina.', 16, 1);
    RETURN;
END;

IF OBJECT_ID('tempdb..#NominaMenuInvea') IS NOT NULL
    DROP TABLE #NominaMenuInvea;

CREATE TABLE #NominaMenuInvea
(
    PKIdMenu INT NOT NULL PRIMARY KEY,
    Nombre NVARCHAR(150) NOT NULL,
    Tipo INT NOT NULL,
    FKIdMenu_SIS INT NULL,
    LegacyName NVARCHAR(100) NULL,
    Ruta NVARCHAR(200) NULL,
    ImageUrl NVARCHAR(120) NULL,
    Activo BIT NOT NULL,
    Lenguaje CHAR(3) NOT NULL,
    [Orden] INT NULL,
    CreatedByOperatorId INT NOT NULL,
    CreatedDateTime DATETIME NOT NULL
);

INSERT INTO #NominaMenuInvea
    (PKIdMenu, Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta, ImageUrl, Activo, Lenguaje, [Orden], CreatedByOperatorId, CreatedDateTime)
VALUES
    (610, N'Calculo', 1, 7, N'Nomina_Calculo', N'/nom/calcnomina', N'FaCalculate', 1, N'ESP', 2, 1, @Now),
    (620, N'Auxiliares', 1, 7, N'Nomina_Auxiliares', N'/', N'FaFolderOpen', 1, N'ESP', 3, 1, @Now),
    (621, N'Calculo ISSSTE', 2, 620, N'Calculo_ISSSTE_4134', N'/aux/auxcalcissste', N'FaPercent', 1, N'ESP', 1, 1, @Now),
    (622, N'Calculo ISR', 2, 620, N'Calculo_ISR_2053', N'/aux/auxcalcisrquincenal', N'FaPercent', 1, N'ESP', 2, 1, @Now),
    (623, N'Calculo FOVISSSTE', 2, 620, N'Calculo_FOVISSSTE_4136', N'/aux/auxcalcfovissste', N'FaHouse', 1, N'ESP', 3, 1, @Now),
    (624, N'Calculo Infonavit', 2, 620, N'Calculo_Infonavit_139', N'/aux/auxcalcinfonavitquincenal', N'FaHomeWork', 1, N'ESP', 4, 1, @Now),
    (625, N'Calculo Cuotas IMSS', 2, 620, N'Calculo_IMSS_3084', N'/aux/auxcalcimssquincenal', N'FaPercent', 1, N'ESP', 5, 1, @Now),
    (630, N'Productos', 1, 7, N'Nomina_Productos', N'/', N'FaFolderOpen', 1, N'ESP', 4, 1, @Now),
    (631, N'Resumen', 2, 630, N'Resumen_Nomina', N'/nom/resumennomina', N'FaChartPie', 1, N'ESP', 1, 1, @Now),
    (632, N'Recibos', 2, 630, N'Recibos_Nomina', N'/nom/recibonomina', N'FaReceiptLong', 1, N'ESP', 2, 1, @Now),
    (633, N'Archivos de Dispersion', 2, 630, N'Archivos_Dispersion', N'/nom/archivodispercion', N'FaFile', 1, N'ESP', 3, 1, @Now),
    (634, N'Archivos de Timbrado', 2, 630, N'Archivos_Timbrado', N'/nom/timbradopercepciones', N'FaVerified', 1, N'ESP', 4, 1, @Now),
    (635, N'Reporte Cuotas IMSS', 2, 630, N'Reporte_IMSS', N'/aux/imssquincenal_rep', N'FaChartBar', 1, N'ESP', 5, 1, @Now),
    (636, N'Reporte Nomina Actual', 2, 630, N'Reporte_Nomina', N'/nom/reportenomina', N'FaDocument', 1, N'ESP', 6, 1, @Now),
    (640, N'Incidencias', 1, 7, N'Nomina_Incidencias', N'/', N'RiListCheck2', 1, N'ESP', 5, 1, @Now),
    (641, N'Captura de Incidencias', 2, 640, N'Captura_Incidencias', N'/rh/incidencia', N'FaEdit', 1, N'ESP', 1, 1, @Now),
    (642, N'Justificacion de Incidencias', 2, 640, N'Justificacion_Incidencias', N'/rh/justificacion', N'FaVerified', 1, N'ESP', 2, 1, @Now),
    (643, N'Reporte de Incidencias', 2, 640, N'Reporte_Incidencias', N'/rh/incidenciareport', N'FaChartLine', 1, N'ESP', 3, 1, @Now),
    (650, N'Pagos Extraordinarios', 1, 7, N'Concepto_Variable', N'/nom/conceptovariable', N'FaAttachMoney', 1, N'ESP', 6, 1, @Now),
    (660, N'Cierre de Periodo', 1, 7, N'Nomina_Cierre_Periodo', N'/nom/cierraperiodo', N'FaLock', 1, N'ESP', 7, 1, @Now),
    (670, N'Finiquito/Liquidacion', 1, 7, N'Nomina_Finiquito_Liquidacion', N'/rh/liquidacion', N'FaReceiptLong', 1, N'ESP', 8, 1, @Now),
    (680, N'Nominas Especiales', 1, 7, N'Nominas_Especiales', N'/', N'FaCog', 1, N'ESP', 9, 1, @Now),
    (681, N'Calculo de Aguinaldo', 2, 680, N'Calc_Aguinaldo', N'/nom/calcaguinaldo', N'FaStar', 1, N'ESP', 1, 1, @Now),
    (682, N'Configura Aguinaldo', 2, 680, N'Configura_Aguinaldo', N'/sis/nominaespecial', N'FaCog', 1, N'ESP', 2, 1, @Now),
    (683, N'Aguinaldo', 2, 680, N'Aguinaldo', N'/sis/vwnominaespecial', N'FaStar', 1, N'ESP', 3, 1, @Now),
    (684, N'Faltas Especiales', 2, 680, N'Faltas_Especial', N'/emp/faltasxempresa', N'FaClock', 1, N'ESP', 4, 1, @Now),
    (700, N'Historicos de Nomina', 0, 7, N'Nomina_Historicos', N'/', N'FaClock', 1, N'ESP', 10, 1, @Now),
    (710, N'Productos', 1, 700, N'Nomina_Productos_Historicos', N'/', N'FaFolderOpen', 1, N'ESP', 1, 1, @Now),
    (711, N'Consulta de Nomina', 2, 710, N'Consulta_Nomina', N'/nomina/historicos/consulta', N'FaSearch', 1, N'ESP', 1, 1, @Now),
    (712, N'Analisis', 2, 710, N'Analisis', N'/nomina/historicos/analisis', N'FaChartLine', 1, N'ESP', 2, 1, @Now),
    (713, N'Recibos', 2, 710, N'Recibos_Historicos', N'/nomina/historicos/recibos', N'FaReceiptLong', 1, N'ESP', 3, 1, @Now),
    (714, N'Archivos de Dispersion', 2, 710, N'Archivos_Dispersion_Historicos', N'/nomina/historicos/dispersion', N'FaFile', 1, N'ESP', 4, 1, @Now),
    (715, N'Archivos de Timbrado', 2, 710, N'Archivos_Timbrado_Historicos', N'/nomina/historicos/timbrado', N'FaVerified', 1, N'ESP', 5, 1, @Now),
    (716, N'Reporte Nomina Quincenal', 2, 710, N'Reporte_Nomina_Quincenal', N'/nomina/historicos/reportequincenal', N'FaDateRange', 1, N'ESP', 6, 1, @Now),
    (717, N'Resumen de Nomina Historica', 2, 710, N'Resumen_Nomina_Historica', N'/nomina/historicos/resumen', N'FaChartPie', 1, N'ESP', 7, 1, @Now),
    (718, N'Reporte de Nomina Historica', 2, 710, N'Reporte_Nomina_Historica', N'/nomina/historicos/reportehistorico', N'FaDocument', 1, N'ESP', 8, 1, @Now),
    (719, N'Cubo Nomina Historica', 2, 710, N'Cubo_Nomina_Historica', N'/nomina/historicos/cubo', N'FaTable', 1, N'ESP', 9, 1, @Now),
    (720, N'Reportes del IMSS', 1, 700, N'Reportes_IMSS_Historicos', N'/', N'FaChartBar', 1, N'ESP', 2, 1, @Now),
    (721, N'Salario Base de Cotizacion', 2, 720, N'Salario_Base_Cotizacion', N'/nomina/historicos/sbc', N'FaPercent', 1, N'ESP', 1, 1, @Now),
    (722, N'Acumulados IMSS', 2, 720, N'Acumulados_IMSS', N'/nomina/historicos/acumuladosimss', N'FaChartBar', 1, N'ESP', 2, 1, @Now),
    (723, N'SBC Historico', 2, 720, N'SBC_Historico', N'/nomina/historicos/sbchistorico', N'FaClock', 1, N'ESP', 3, 1, @Now),
    (724, N'Acumulados en el Bimestre IMSS', 2, 720, N'Acumulados_Bimestre_IMSS', N'/nomina/historicos/acumuladosbimestre', N'FaDateRange', 1, N'ESP', 4, 1, @Now),
    (730, N'Reportes del SAT', 1, 700, N'Reportes_SAT_Historicos', N'/', N'FaChartLine', 1, N'ESP', 3, 1, @Now),
    (731, N'Acumulado Mensual ISR', 2, 730, N'Acumulado_Mensual_ISR', N'/nomina/historicos/isr_mensual', N'FaPercent', 1, N'ESP', 1, 1, @Now),
    (732, N'Acumulados de ISR', 2, 730, N'Acumulados_ISR', N'/nomina/historicos/isr_acumulados', N'FaChartLine', 1, N'ESP', 2, 1, @Now),
    (740, N'Impuestos sobre Nomina locales', 1, 700, N'Impuestos_Locales_Historicos', N'/nomina/historicos/impuestoslocales', N'FaHouse', 1, N'ESP', 4, 1, @Now),
    (800, N'Configuracion Nominas', 0, 7, N'Configuracion_Nominas', N'/', N'FaCog', 1, N'ESP', 11, 1, @Now),
    (810, N'Catalogos', 1, 800, N'Nomina_Catalogos', N'/', N'FaFolderOpen', 1, N'ESP', 1, 1, @Now),
    (811, N'Tipo de Nomina', 2, 810, N'Tipo_Nomina', N'/nomina/configuracion/catalogos/tipo-nomina', N'FaEventAvailable', 1, N'ESP', 1, 1, @Now),
    (812, N'Cuotas IMSS', 2, 810, N'Cuotas_IMSS', N'/nomina/configuracion/catalogos/cuotas-imss', N'FaPercent', 1, N'ESP', 2, 1, @Now),
    (813, N'Conceptos de Nomina', 2, 810, N'Conceptos_Nomina', N'/nomina/configuracion/catalogos/conceptos', N'FaPayments', 1, N'ESP', 3, 1, @Now),
    (814, N'UMA', 2, 810, N'UMA', N'/nomina/configuracion/catalogos/uma', N'FaPriceChange', 1, N'ESP', 4, 1, @Now),
    (815, N'Tipo de Contratacion', 2, 810, N'Tipo_Contratacion', N'/nomina/configuracion/catalogos/tipo-contratacion', N'FaUserGroup', 1, N'ESP', 5, 1, @Now),
    (816, N'Tipo de descanso', 2, 810, N'Tipo_Descanso', N'/nomina/configuracion/catalogos/tipo-descanso', N'FaClock', 1, N'ESP', 6, 1, @Now),
    (817, N'Tipo de Incidencia', 2, 810, N'Tipo_Incidencia', N'/nomina/configuracion/catalogos/tipo-incidencia', N'FaSick', 1, N'ESP', 7, 1, @Now),
    (818, N'Conceptos de importe Fijo', 2, 810, N'Concepto_Fijo', N'/nomina/configuracion/catalogos/concepto-fijo', N'FaAttachMoney', 1, N'ESP', 8, 1, @Now),
    (819, N'Tipo de Justificacion', 2, 810, N'Tipo_Justificacion', N'/nomina/configuracion/catalogos/tipo-justificacion', N'FaVerified', 1, N'ESP', 9, 1, @Now),
    (820, N'Tabulador', 2, 810, N'Tabulador', N'/nomina/configuracion/catalogos/tabulador', N'FaTableRows', 1, N'ESP', 10, 1, @Now),
    (821, N'Unidad Infonavit', 2, 810, N'Unidad_Infonavit', N'/nomina/configuracion/catalogos/unidad-infonavit', N'FaHomeWork', 1, N'ESP', 11, 1, @Now),
    (822, N'Salario Minimo General', 2, 810, N'Salario_Minimo', N'/nomina/configuracion/catalogos/smg', N'FaMoneyBillWave', 1, N'ESP', 12, 1, @Now),
    (823, N'Forma de Pago', 2, 810, N'Forma_Pago', N'/nomina/configuracion/catalogos/forma-pago', N'FaPointOfSale', 1, N'ESP', 13, 1, @Now),
    (824, N'Forma de Calculo', 2, 810, N'Forma_Calculo', N'/nomina/configuracion/catalogos/forma-calculo', N'FaFunctions', 1, N'ESP', 14, 1, @Now),
    (825, N'Capitulos', 2, 810, N'Capitulos', N'/nomina/configuracion/catalogos/capitulos', N'RiListCheck2', 1, N'ESP', 15, 1, @Now),
    (830, N'Periodos', 1, 800, N'Nomina_Periodos', N'/', N'FaCalendarMonth', 1, N'ESP', 2, 1, @Now),
    (831, N'Semanal', 2, 830, N'Periodo_Semanal', N'/nomina/configuracion/periodos/semanal', N'FaViewWeek', 1, N'ESP', 1, 1, @Now),
    (832, N'Quincenal', 2, 830, N'Periodo_Quincenal', N'/nomina/configuracion/periodos/quincenal', N'FaDateRange', 1, N'ESP', 2, 1, @Now),
    (833, N'Mensual', 2, 830, N'Periodo_Mensual', N'/nomina/configuracion/periodos/mensual', N'FaCalendarMonth', 1, N'ESP', 3, 1, @Now),
    (834, N'Bimestral', 2, 830, N'Periodo_Bimestral', N'/nomina/configuracion/periodos/bimestral', N'FaCalendar', 1, N'ESP', 4, 1, @Now),
    (840, N'Tablas ISR', 1, 800, N'Nomina_Tablas_ISR', N'/', N'FaTable', 1, N'ESP', 3, 1, @Now),
    (841, N'Semanal', 2, 840, N'Tabla_ISR_Semanal', N'/nomina/configuracion/isr/semanal', N'FaPercent', 1, N'ESP', 1, 1, @Now),
    (842, N'Quincenal', 2, 840, N'Tabla_ISR_Quincenal', N'/nomina/configuracion/isr/quincenal', N'FaPercent', 1, N'ESP', 2, 1, @Now),
    (843, N'Mensual', 2, 840, N'Tabla_ISR_Mensual', N'/nomina/configuracion/isr/mensual', N'FaPercent', 1, N'ESP', 3, 1, @Now),
    (850, N'Prestaciones', 1, 800, N'Nomina_Prestaciones', N'/', N'FaStar', 1, N'ESP', 4, 1, @Now),
    (860, N'Subsidios ISR', 1, 800, N'Nomina_Subsidios_ISR', N'/', N'FaPercent', 1, N'ESP', 5, 1, @Now),
    (861, N'Semanal', 2, 860, N'Subsidio_ISR_Semanal', N'/nomina/configuracion/subsidios/semanal', N'FaPercent', 1, N'ESP', 1, 1, @Now),
    (862, N'Quincenal', 2, 860, N'Subsidio_ISR_Quincenal', N'/nomina/configuracion/subsidios/quincenal', N'FaPercent', 1, N'ESP', 2, 1, @Now),
    (863, N'Mensual', 2, 860, N'Subsidio_ISR_Mensual', N'/nomina/configuracion/subsidios/mensual', N'FaPercent', 1, N'ESP', 3, 1, @Now),
    (870, N'Impuestos', 1, 800, N'Nomina_Impuestos', N'/', N'FaPercent', 1, N'ESP', 6, 1, @Now),
    (871, N'Base Gravable', 2, 870, N'Base_Gravable', N'/nomina/configuracion/impuestos/base-gravable', N'FaPercent', 1, N'ESP', 1, 1, @Now),
    (872, N'Impuestos Locales', 2, 870, N'Impuestos_Locales', N'/nomina/configuracion/impuestos/locales', N'FaHouse', 1, N'ESP', 2, 1, @Now),
    (880, N'IMSS', 1, 800, N'Nomina_IMSS', N'/', N'FaUsers', 1, N'ESP', 7, 1, @Now),
    (881, N'Prestaciones Minimas de Ley', 2, 880, N'Prestaciones_Minimas', N'/nomina/configuracion/imss/prestaciones', N'FaDocument', 1, N'ESP', 1, 1, @Now),
    (882, N'Clase IMSS', 2, 880, N'Clase_IMSS', N'/nomina/configuracion/imss/clase', N'FaVerified', 1, N'ESP', 2, 1, @Now),
    (883, N'Fraccion IMSS', 2, 880, N'Fraccion_IMSS', N'/nomina/configuracion/imss/fraccion', N'FaPercent', 1, N'ESP', 3, 1, @Now),
    (884, N'Base Gravable IMSS', 2, 880, N'Base_Gravable_IMSS', N'/nomina/configuracion/imss/base-gravable', N'FaPercent', 1, N'ESP', 4, 1, @Now),
    (900, N'Configuracion RH', 0, 7, N'Configuracion_RH', N'/rh/configuracion', N'FaGears', 1, N'ESP', 12, 1, @Now),
    (901, N'Plazas Autorizadas', 1, 900, N'Plazas_Autorizadas', N'/rh/configuracion/plazas', N'FaVerified', 1, N'ESP', 1, 1, @Now),
    (902, N'Universo', 1, 900, N'Universo', N'/rh/configuracion/universo', N'FaUsers', 1, N'ESP', 2, 1, @Now),
    (903, N'Nivel', 1, 900, N'Nivel', N'/rh/configuracion/nivel', N'FaChartBar', 1, N'ESP', 3, 1, @Now),
    (904, N'Sexo', 1, 900, N'Sexo', N'/rh/configuracion/sexo', N'FaUsers', 1, N'ESP', 4, 1, @Now),
    (905, N'Estado Civil', 1, 900, N'Estado_Civil', N'/rh/configuracion/estado-civil', N'FaHeart', 1, N'ESP', 5, 1, @Now),
    (906, N'Escolaridad', 1, 900, N'Escolaridad', N'/rh/configuracion/escolaridad', N'FaDocument', 1, N'ESP', 6, 1, @Now),
    (907, N'Tipo de Parentesco', 1, 900, N'Tipo_Parentesco', N'/rh/configuracion/parentesco', N'FaUsers', 1, N'ESP', 7, 1, @Now),
    (908, N'Estado', 1, 900, N'Estado', N'/rh/configuracion/estado', N'FaHouse', 1, N'ESP', 8, 1, @Now),
    (909, N'Banco', 1, 900, N'Banco', N'/rh/configuracion/banco', N'FaHouse', 1, N'ESP', 9, 1, @Now),
    (910, N'Municipio', 1, 900, N'Municipio', N'/rh/configuracion/municipio', N'FaHouse', 1, N'ESP', 10, 1, @Now),
    (911, N'Contratos', 1, 900, N'Contratos', N'/rh/configuracion/contratos', N'FaDocument', 1, N'ESP', 11, 1, @Now),
    (912, N'Base Pago', 2, 911, N'Base_Pago', N'/rh/configuracion/contratos/base-pago', N'FaMoneyBillWave', 1, N'ESP', 1, 1, @Now),
    (913, N'Metodo de Pago', 2, 911, N'Metodo_Pago', N'/rh/configuracion/contratos/metodo-pago', N'FaCreditCard', 1, N'ESP', 2, 1, @Now),
    (914, N'Tipo de Regimen', 2, 911, N'Tipo_Regimen', N'/rh/configuracion/contratos/tipo-regimen', N'FaDocument', 1, N'ESP', 3, 1, @Now),
    (915, N'Base de Cotizacion', 2, 911, N'Base_Cotizacion', N'/rh/configuracion/contratos/base-cotizacion', N'FaPercent', 1, N'ESP', 4, 1, @Now),
    (916, N'Zona Geografica', 2, 911, N'Zona_Geografica', N'/rh/configuracion/contratos/zona-geografica', N'FaHouse', 1, N'ESP', 5, 1, @Now),
    (917, N'Dia de la Semana', 2, 911, N'Dia_Semana', N'/rh/configuracion/contratos/dia-semana', N'FaCalendar', 1, N'ESP', 6, 1, @Now),
    (918, N'Tipo de Sangre', 1, 900, N'Tipo_Sangre', N'/rh/configuracion/tipo-sangre', N'FaUsers', 1, N'ESP', 12, 1, @Now),
    (919, N'Profesion', 1, 900, N'Profesion', N'/rh/configuracion/profesion', N'FaDocument', 1, N'ESP', 13, 1, @Now),
    (920, N'Regimen Fiscal', 1, 900, N'Regimen_Fiscal', N'/rh/configuracion/regimen-fiscal', N'FaDocument', 1, N'ESP', 14, 1, @Now),
    (921, N'Pais', 1, 900, N'Pais', N'/rh/configuracion/pais', N'FaHouse', 1, N'ESP', 15, 1, @Now),
    (922, N'Periodo de Pago', 1, 900, N'Periodo_Pago', N'/rh/configuracion/periodo-pago', N'FaCalendar', 1, N'ESP', 16, 1, @Now),
    (923, N'Tipo Documento RH', 1, 900, N'Tipo_Documento_RH', N'/rh/configuracion/tipo-documento', N'FaDocument', 1, N'ESP', 17, 1, @Now),
    (924, N'Tipo Expediente', 1, 900, N'Tipo_Expediente', N'/rh/configuracion/tipo-expediente', N'FaDocument', 1, N'ESP', 18, 1, @Now),
    (925, N'Opcion Jubilacion', 1, 900, N'Opcion_Jubilacion', N'/rh/configuracion/opcion-jubilacion', N'FaDocument', 1, N'ESP', 19, 1, @Now),
    (926, N'Situacion Persona', 1, 900, N'Situacion_Persona', N'/rh/configuracion/situacion-persona', N'FaUsers', 1, N'ESP', 20, 1, @Now),
    (927, N'Situacion Plaza', 1, 900, N'Situacion_Plaza', N'/rh/configuracion/situacion-plaza', N'FaVerified', 1, N'ESP', 21, 1, @Now),
    (928, N'Situacion Movimiento', 1, 900, N'Situacion_Movimiento', N'/rh/configuracion/situacion-movimiento', N'FaDocument', 1, N'ESP', 22, 1, @Now),
    (929, N'Clase Movimiento', 1, 900, N'Clase_Movimiento', N'/rh/configuracion/clase-movimiento', N'FaDocument', 1, N'ESP', 23, 1, @Now),
    (930, N'Movimiento RH', 1, 900, N'Movimiento_RH', N'/rh/configuracion/movimiento', N'FaDocument', 1, N'ESP', 24, 1, @Now);

SET IDENTITY_INSERT SIS.Menu ON;

MERGE INTO SIS.Menu AS TARGET
USING #NominaMenuInvea AS SOURCE
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
    SELECT PKIdMenu, @RoleId AS RoleId, 1 AS Activo, 1 AS CreatedByOperatorId, @Now AS CreatedDateTime
    FROM #NominaMenuInvea
    WHERE Activo = 1
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

IF OBJECT_ID('tempdb..#NominaClaimSyncInvea') IS NOT NULL
    DROP TABLE #NominaClaimSyncInvea;

CREATE TABLE #NominaClaimSyncInvea
(
    ModuleName NVARCHAR(100) NOT NULL,
    SubModuleName NVARCHAR(100) NOT NULL,
    [Values] VARCHAR(MAX) NOT NULL
);

INSERT INTO #NominaClaimSyncInvea (ModuleName, SubModuleName, [Values])
VALUES
    (N'Nomina', N'Recursos_Humanos', 'view,view-menu'),
    (N'Nomina', N'Empleados', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Nomina', N'Movimientos_Personal', 'view,view-menu,CanExportToExcel'),
    (N'Nomina', N'De_Personal', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Nomina', N'Reporte Quincenal MP', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Nomina', N'Creditos_Trabajadores', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Nomina', N'Nomina_Nomina', 'view,view-menu'),
    (N'Calculo', N'Calculo_2050', 'view,view-menu,delete,new,update,authorize'),
    (N'Auxiliares', N'Auxiliares', 'view,view-menu'),
    (N'Auxiliares', N'Calculo_ISSSTE_4134', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Auxiliares', N'Calculo_ISR_2053', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Auxiliares', N'Calculo_FOVISSSTE_4136', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Auxiliares', N'Calculo_Infonavit_139', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Auxiliares', N'Calculo_IMSS_3084', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Productos', N'Resumen', 'view,view-menu,CanExportToExcel'),
    (N'Productos', N'Recibos', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Productos', N'Archivos_Dispersion', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Productos', N'Archivos_Timbrado', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Productos', N'Reporte_Cuotas_IMSS', 'view,view-menu,CanExportToExcel'),
    (N'Productos', N'Reporte_Nomina', 'view,view-menu,CanExportToExcel'),
    (N'Productos', N'Reporte_ISR', 'view,view-menu,CanExportToExcel'),
    (N'Productos', N'Editar_Reg_Quincenal', 'view,view-menu,delete,new,update'),
    (N'Productos', N'Editar_Reg_Mensual', 'view,view-menu,delete,new,update'),
    (N'Incidencias', N'Captura_Incidencias', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Incidencias', N'Justificacion_Incidencias', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Incidencias', N'Reporte_Incidencias', 'view,view-menu,CanExportToExcel'),
    (N'Pagos_Extraordinarios', N'Conceptos_Variables', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Cierre_Periodo', N'Cierre_Periodo', 'view,view-menu,delete,new,update,authorize'),
    (N'Finiquito_Liquidacion', N'Liquidacion', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Nominas_Especiales', N'Calc_Aguinaldo', 'view,view-menu,delete,new,update,authorize'),
    (N'Nominas_Especiales', N'Configura_Aguinaldo', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Nominas_Especiales', N'Aguinaldo', 'view,view-menu,CanExportToExcel'),
    (N'Nominas_Especiales', N'Faltas_Especial', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Historicos', N'Historicos_Nomina', 'view,view-menu'),
    (N'Productos_Historicos', N'Consulta_Nomina', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Productos_Historicos', N'Analisis', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Productos_Historicos', N'Recibos_Historicos', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Productos_Historicos', N'Archivos_Dispersion_Historicos', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Productos_Historicos', N'Archivos_Timbrado_Historicos', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Productos_Historicos', N'Reporte_Nomina_Quincenal', 'view,view-menu,CanExportToExcel'),
    (N'Productos_Historicos', N'Resumen_Nomina_Historica', 'view,view-menu,CanExportToExcel'),
    (N'Productos_Historicos', N'Reporte_Nomina_Historica', 'view,view-menu,CanExportToExcel'),
    (N'Productos_Historicos', N'Cubo_Nomina_Historica', 'view,view-menu,CanExportToExcel'),
    (N'Reportes_IMSS_Historicos', N'Salario_Base_Cotizacion', 'view,view-menu,CanExportToExcel'),
    (N'Reportes_IMSS_Historicos', N'Acumulados_IMSS', 'view,view-menu,CanExportToExcel'),
    (N'Reportes_IMSS_Historicos', N'SBC_Historico', 'view,view-menu,CanExportToExcel'),
    (N'Reportes_IMSS_Historicos', N'Acumulados_Bimestre_IMSS', 'view,view-menu,CanExportToExcel'),
    (N'Reportes_SAT_Historicos', N'Acumulado_Mensual_ISR', 'view,view-menu,CanExportToExcel'),
    (N'Reportes_SAT_Historicos', N'Acumulados_ISR', 'view,view-menu,CanExportToExcel'),
    (N'Impuestos_Locales_Historicos', N'Impuestos_Locales', 'view,view-menu,CanExportToExcel'),
    (N'Configuracion_Nominas', N'Configuracion_Nominas', 'view,view-menu'),
    (N'Catalogos', N'Tipo_Nomina', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Catalogos', N'Cuotas_IMSS', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Catalogos', N'Conceptos_Nomina', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Catalogos', N'UMA', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Catalogos', N'Tipo_Contratacion', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Catalogos', N'Tipo_Descanso', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Catalogos', N'Tipo_Incidencia', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Catalogos', N'Concepto_Fijo', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Catalogos', N'Tipo_Justificacion', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Catalogos', N'Tabulador', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Catalogos', N'Unidad_Infonavit', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Catalogos', N'Salario_Minimo', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Catalogos', N'Forma_Pago', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Catalogos', N'Forma_Calculo', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Catalogos', N'Capitulos', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Periodos', N'Periodo_Semanal', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Periodos', N'Periodo_Quincenal', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Periodos', N'Periodo_Mensual', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Periodos', N'Periodo_Bimestral', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Tablas_ISR', N'Tabla_ISR_Semanal', 'view,view-menu,delete,new,update'),
    (N'Tablas_ISR', N'Tabla_ISR_Quincenal', 'view,view-menu,delete,new,update'),
    (N'Tablas_ISR', N'Tabla_ISR_Mensual', 'view,view-menu,delete,new,update'),
    (N'Prestaciones', N'Prestaciones', 'view,view-menu,delete,new,update'),
    (N'Subsidios_ISR', N'Subsidio_ISR_Semanal', 'view,view-menu,delete,new,update'),
    (N'Subsidios_ISR', N'Subsidio_ISR_Quincenal', 'view,view-menu,delete,new,update'),
    (N'Subsidios_ISR', N'Subsidio_ISR_Mensual', 'view,view-menu,delete,new,update'),
    (N'Impuestos', N'Base_Gravable', 'view,view-menu,delete,new,update'),
    (N'Impuestos', N'Impuestos_Locales', 'view,view-menu,delete,new,update'),
    (N'IMSS', N'Prestaciones_Minimas', 'view,view-menu,delete,new,update'),
    (N'IMSS', N'Clase_IMSS', 'view,view-menu,delete,new,update'),
    (N'IMSS', N'Fraccion_IMSS', 'view,view-menu,delete,new,update'),
    (N'IMSS', N'Base_Gravable_IMSS', 'view,view-menu,delete,new,update'),
    (N'Configuracion_RH', N'Configuracion_RH', 'view,view-menu'),
    (N'Plazas_Autorizadas', N'Plazas_Autorizadas', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Universo', N'Universo', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Nivel', N'Nivel', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Sexo', N'Sexo', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Estado_Civil', N'Estado_Civil', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Escolaridad', N'Escolaridad', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Tipo_Parentesco', N'Tipo_Parentesco', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Estado', N'Estado', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Banco', N'Banco', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Municipio', N'Municipio', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Tipo_Sangre', N'Tipo_Sangre', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Profesion', N'Profesion', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Regimen_Fiscal', N'Regimen_Fiscal', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Pais', N'Pais', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Periodo_Pago', N'Periodo_Pago', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Tipo_Documento', N'Tipo_Documento', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Tipo_Documento_RH', N'Tipo_Documento_RH', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Tipo_Expediente', N'Tipo_Expediente', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Opcion_Jubilacion', N'Opcion_Jubilacion', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Situacion_Persona', N'Situacion_Persona', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Situacion_Plaza', N'Situacion_Plaza', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Situacion_Movimiento', N'Situacion_Movimiento', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Clase_Movimiento', N'Clase_Movimiento', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Movimiento_RH', N'Movimiento_RH', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Contratos', N'Contratos', 'view,view-menu'),
    (N'Contratos', N'Base_Pago', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Contratos', N'Metodo_Pago', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Contratos', N'Tipo_Regimen', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Contratos', N'Base_Cotizacion', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Contratos', N'Zona_Geografica', 'view,view-menu,delete,new,update,CanExportToExcel'),
    (N'Contratos', N'Dia_Semana', 'view,view-menu,delete,new,update,CanExportToExcel');

;WITH ClaimsBase AS
(
    SELECT
        ModuleName,
        SubModuleName,
        [Values],
        ROW_NUMBER() OVER (ORDER BY ModuleName, SubModuleName) AS RowNumber
    FROM #NominaClaimSyncInvea
)
INSERT INTO dbo.AspNetClaims
(
    ClaimTypeId,
    Name,
    [Group],
    RoleId,
    TokenFormat,
    Created,
    SubGroup,
    Code,
    [Description],
    [Values],
    ReferenceId
)
SELECT
    2,
    ModuleName,
    ModuleName,
    NULL,
    N'app://{0}/{1}',
    @Now,
    SubModuleName,
    CONCAT(N'NOMINV', RIGHT(CONCAT(N'0000', RowNumber), 4)),
    SubModuleName,
    [Values],
    0
FROM ClaimsBase source
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.AspNetClaims target
    WHERE target.RoleId IS NULL
      AND target.[Group] = source.ModuleName
      AND target.SubGroup = source.SubModuleName
);

DECLARE @ModuleName NVARCHAR(100);
DECLARE @SubModuleName NVARCHAR(100);
DECLARE @Values VARCHAR(MAX);

DECLARE claim_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT ModuleName, SubModuleName, [Values]
FROM #NominaClaimSyncInvea;

OPEN claim_cursor;
FETCH NEXT FROM claim_cursor INTO @ModuleName, @SubModuleName, @Values;

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC dbo.spConfiguracionDeRolYClaims @ModuleName, @SubModuleName, @RoleCode, @Values;
    FETCH NEXT FROM claim_cursor INTO @ModuleName, @SubModuleName, @Values;
END;

CLOSE claim_cursor;
DEALLOCATE claim_cursor;

UPDATE target
SET target.[Values] = source.[Values]
FROM dbo.AspNetClaims target
INNER JOIN #NominaClaimSyncInvea source
    ON source.ModuleName = target.[Group]
    AND source.SubModuleName = target.SubGroup
WHERE target.RoleId IS NULL
   OR target.RoleId = @RoleId;

DROP TABLE #NominaClaimSyncInvea;
DROP TABLE #NominaMenuInvea;

PRINT N'Menu Invea de Nomina/RH y claims sincronizados correctamente.';
