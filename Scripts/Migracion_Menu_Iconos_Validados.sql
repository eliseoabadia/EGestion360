MERGE INTO SIS.Menu AS TARGET
USING (VALUES
    -- Módulos principales
    (1, N'Configuración', 1, NULL, N'Configuración', N'/', N'FaCog', 1, N'ESP', 1, 1, GETDATE()),
    (2, N'Presupuesto', 1, NULL, N'Presupuesto', N'/', N'FaChartPie', 1, N'ESP', 2, 1, GETDATE()),
    (3, N'Contabilidad', 1, NULL, N'Contabilidad', N'/', N'FaTable', 1, N'ESP', 3, 1, GETDATE()),
    (4, N'Adquisiciones', 1, NULL, N'Adquisiciones', N'/', N'RiListCheck2', 1, N'ESP', 4, 1, GETDATE()),
    (5, N'Patrimonio', 1, NULL, N'Patrimonio', N'/', N'FaFolder', 1, N'ESP', 5, 1, GETDATE()),
    (6, N'Almacén', 1, NULL, N'Almacén', N'/', N'FaFolderOpen', 1, N'ESP', 6, 1, GETDATE()),
    (7, N'Nómina', 1, NULL, N'Nómina', N'/', N'FaMoneyBillWave', 1, N'ESP', 7, 1, GETDATE()),
    (8, N'Reportes CxC', 1, NULL, N'Reportes CxC', N'/', N'FaChartLine', 1, N'ESP', 8, 1, GETDATE()),
    (9, N'Ayuda', 2, NULL, N'Ayuda', N'/ayuda', N'FaInfo', 1, N'ESP', 9, 1, GETDATE()),

    -- Configuración -> Sistema
    (10, N'Sistema', 1, 1, N'Sistema', N'/', N'FaTools', 1, N'ESP', 1, 1, GETDATE()),
    (11, N'Usuario', 2, 10, N'Usuario', N'/configuracion/sistema/usuarios', N'FaUserCircle', 1, N'ESP', 2, 1, GETDATE()),
    (12, N'Meníº', 2, 10, N'Meníº', N'/configuracion/sistema/menu', N'RiMenuLine', 1, N'ESP', 3, 1, GETDATE()),
    (13, N'General', 2, 10, N'General', N'/configuracion/sistema/general', N'FaGears', 1, N'ESP', 4, 1, GETDATE()),
    (14, N'Empresa', 2, 10, N'Empresa', N'/configuracion/sistema/empresa', N'FaHome', 1, N'ESP', 5, 1, GETDATE()),
    (15, N'Departamento', 2, 10, N'Departamento', N'/configuracion/sistema/departamento', N'FaUserGroup', 1, N'ESP', 6, 1, GETDATE()),

    -- Configuración -> Presupuestales
    (20, N'Presupuestales', 1, 1, N'Presupuestales', N'/', N'FaChartBar', 1, N'ESP', 2, 1, GETDATE()),
    (21, N'Programas Presupuestales', 2, 20, N'Programas Presupuestales.', N'/configuracion/presupuestales/programas-presupuesta', N'FaFolderOpen', 1, N'ESP', 1, 1, GETDATE()),
    (22, N'Clave del Programa', 2, 20, N'Clave del Programa', N'/configuracion/presupuestales/programa-presupuestal', N'FaKey', 1, N'ESP', 2, 1, GETDATE()),
    (23, N'Unidad Responsable', 2, 22, N'Unidad Responsable', N'/configuracion/presupuestales/clave-programa/unidad-responsable', N'FaUserGroup', 1, N'ESP', 1, 1, GETDATE()),
    (24, N'Finalidad', 2, 22, N'Finalidad', N'/configuracion/presupuestales/clave-programa/finalidad', N'FaFlag', 1, N'ESP', 2, 1, GETDATE()),
    (25, N'Función', 2, 22, N'Función', N'/configuracion/presupuestales/clave-programa/funcion', N'FaGears', 1, N'ESP', 3, 1, GETDATE()),
    (26, N'SubFunción', 2, 22, N'SubFunción', N'/configuracion/presupuestales/clave-programa/subfuncion', N'FaTools', 1, N'ESP', 4, 1, GETDATE()),
    (27, N'Actividad Institucional', 2, 22, N'Actividad Institucional', N'/configuracion/presupuestales/clave-programa/actividad-institucional', N'RiListCheck2', 1, N'ESP', 5, 1, GETDATE()),
    (28, N'Programa Presupuestal', 2, 22, N'Programa Presupuestal', N'/configuracion/presupuestales/clave-programa/programa-presupuestal', N'FaDocument', 1, N'ESP', 6, 1, GETDATE()),
    (29, N'Aí±os', 2, 22, N'Aí±os', N'/configuracion/presupuestales/clave-programa/anios', N'FaCalendar', 1, N'ESP', 7, 1, GETDATE()),
    (30, N'Sector', 2, 22, N'Sector', N'/configuracion/presupuestales/clave-programa/sector', N'FaFolder', 1, N'ESP', 8, 1, GETDATE()),
    (31, N'Tipo Recurso', 2, 22, N'Tipo Recurso', N'/configuracion/presupuestales/clave-programa/tipo-recurso', N'FaTag', 1, N'ESP', 9, 1, GETDATE()),
    (32, N'Fuente Financiamiento', 2, 22, N'Fuente Financiamiento', N'/configuracion/presupuestales/clave-programa/fuente-financiamiento', N'FaChartPie', 1, N'ESP', 10, 1, GETDATE()),
    (33, N'PG', 2, 22, N'PG', N'/configuracion/presupuestales/clave-programa/pg', N'FaDocument', 1, N'ESP', 11, 1, GETDATE()),
    (34, N'Ramo', 2, 22, N'Ramo', N'/configuracion/presupuestales/clave-programa/ramo', N'FaFolderOpen', 1, N'ESP', 12, 1, GETDATE()),
    (35, N'Proyecto', 2, 22, N'Proyecto', N'/configuracion/presupuestales/clave-programa/proyecto', N'FaFolder', 1, N'ESP', 13, 1, GETDATE()),

    -- Configuración -> Contabilidad
    (40, N'Contabilidad', 1, 1, N'Contabilidad', N'/', N'FaTable', 1, N'ESP', 3, 1, GETDATE()),
    (41, N'Tipo Pólizas', 2, 40, N'Tipo Pólizas', N'/configuracion/contabilidad/tipo-polizas', N'FaDocument', 1, N'ESP', 1, 1, GETDATE()),
    (42, N'Tipo Detalles Pólizas', 2, 40, N'Tipo Detalles Pólizas', N'/configuracion/contabilidad/tipo-detalles-polizas', N'RiListCheck2', 1, N'ESP', 2, 1, GETDATE()),
    (43, N'Matriz Conversión', 2, 40, N'Matriz Conversión', N'/configuracion/contabilidad/matriz-conversion', N'FaGears', 1, N'ESP', 3, 1, GETDATE()),
    (44, N'Matriz Conversión Ingresos', 2, 40, N'Matriz Conversión Ingresos', N'/configuracion/contabilidad/matriz-conversion-ingresos', N'FaChartBar', 1, N'ESP', 4, 1, GETDATE()),
    (45, N'Partidas Presupuestales', 2, 40, N'Partidas Presupuestales', N'/configuracion/contabilidad/partidas-presupuestales', N'FaTag', 1, N'ESP', 5, 1, GETDATE()),
    (46, N'Cuentas Contables', 2, 40, N'Cuentas Contables', N'/configuracion/contabilidad/cuentas-contables', N'FaTable', 1, N'ESP', 6, 1, GETDATE()),
    (47, N'Formas Pago', 2, 40, N'Formas Pago', N'/configuracion/contabilidad/formas-pago', N'FaSave', 1, N'ESP', 7, 1, GETDATE()),

    -- Configuración -> Adquisiciones
    (50, N'Adquisiciones', 1, 1, N'Adquisiciones', N'/', N'RiListCheck2', 1, N'ESP', 4, 1, GETDATE()),
    (51, N'Modalidad', 2, 50, N'Modalidad', N'/configuracion/adquisiciones/modalidad', N'FaTag', 1, N'ESP', 1, 1, GETDATE()),
    (52, N'Tipo de Contrato', 2, 50, N'Tipo de Contrato', N'/configuracion/adquisiciones/tipo-contrato', N'FaDocument', 1, N'ESP', 2, 1, GETDATE()),
    (53, N'Tipo de Documentos', 2, 50, N'Tipo de Documentos', N'/configuracion/adquisiciones/tipo-documento', N'FaFile', 1, N'ESP', 3, 1, GETDATE()),
    (54, N'Tipo de Garantí­a', 2, 50, N'Tipo de Garantí­a', N'/configuracion/adquisiciones/tipo-garantia', N'FaLock', 1, N'ESP', 4, 1, GETDATE()),
    (55, N'Procedimientos de Contratación', 2, 50, N'Procedimientos de Contratación', N'/configuracion/adquisiciones/procedimientos-contratacion', N'FaGears', 1, N'ESP', 5, 1, GETDATE()),
    (56, N'Estatus Requisición', 2, 50, N'Estatus Requisición', N'/configuracion/adquisiciones/estatus-requisicion', N'FaFlag', 1, N'ESP', 6, 1, GETDATE()),
    (57, N'Proveedores', 2, 50, N'Proveedores', N'/configuracion/adquisiciones/proveedores', N'FaUsers', 1, N'ESP', 7, 1, GETDATE()),
    (58, N'Artí­culo', 2, 50, N'Artí­culo', N'/configuracion/adquisiciones/articulo', N'FaTag', 1, N'ESP', 8, 1, GETDATE()),
    (59, N'Fracción', 2, 50, N'Fracción', N'/configuracion/adquisiciones/fraccion', N'RiListCheck2', 1, N'ESP', 9, 1, GETDATE()),

    -- Configuración -> Patrimonio
    (60, N'Patrimonio', 1, 1, N'Patrimonio', N'/', N'FaFolder', 1, N'ESP', 5, 1, GETDATE()),
    (61, N'Familia', 2, 60, N'Familia', N'/configuracion/Patrimonio/Familia', N'FaFolder', 1, N'ESP', 1, 1, GETDATE()),
    (62, N'Grupo Bien', 2, 60, N'Grupo Bien', N'/configuracion/Patrimonio/Grupo_Bien', N'FaFolderOpen', 1, N'ESP', 2, 1, GETDATE()),
    (63, N'Bienes y Servicios', 2, 60, N'Bienes y Servicios', N'/configuracion/Patrimonio/Bienes_Servicios', N'FaTag', 1, N'ESP', 3, 1, GETDATE()),
    (64, N'Tipo de Patrimonio', 2, 60, N'Tipo de Patrimonio', N'/configuracion/Patrimonio/Tipo_Patrimonio', N'FaFolder', 1, N'ESP', 4, 1, GETDATE()),
    (65, N'Tipo de Adquisición', 2, 60, N'Tipo de Adquisición', N'/configuracion/Patrimonio/Tipo_Adquisicion', N'FaTag', 1, N'ESP', 5, 1, GETDATE()),
    (66, N'Marca', 2, 60, N'Marca', N'/configuracion/Patrimonio/Marca', N'FaStar', 1, N'ESP', 6, 1, GETDATE()),
    (67, N'Personas', 2, 60, N'Personas', N'/configuracion/Patrimonio/Personas', N'FaUsers', 1, N'ESP', 7, 1, GETDATE()),

    -- Configuración -> Almacén
    (70, N'Almacén', 1, 1, N'Almacén', N'/', N'FaFolderOpen', 1, N'ESP', 6, 1, GETDATE()),
    (71, N'Motivo de Entradas Salidas', 2, 70, N'Motivo de Entradas Salidas', N'/configuracion/almacen/Motivo_Entradas_Salidas', N'FaTools', 1, N'ESP', 1, 1, GETDATE()),
    (72, N'Estatus Solicitud', 2, 70, N'Estatus Solicitud', N'/configuracion/almacen/Estatus_Solicitud', N'FaFlag', 1, N'ESP', 2, 1, GETDATE()),
    (73, N'Unidades', 2, 70, N'Unidades', N'/configuracion/almacen/Unidades', N'RiListCheck2', 1, N'ESP', 3, 1, GETDATE()),
    (74, N'Periodo de Conteo', 2, 70, N'Periodo de Conteo', N'/configuracion/almacen/Perido_Conteo', N'FaCalendar', 1, N'ESP', 4, 1, GETDATE()),
    (75, N'Familia', 2, 70, N'Familia', N'/configuracion/almacen/Familia', N'FaFolder', 1, N'ESP', 5, 1, GETDATE()),
    (76, N'Tipo Bien', 2, 70, N'Tipo Bien', N'/configuracion/almacen/Tipo_Bien', N'FaTag', 1, N'ESP', 6, 1, GETDATE()),
    (77, N'Bien', 2, 70, N'Bien', N'/configuracion/almacen/Bien', N'FaTag', 1, N'ESP', 7, 1, GETDATE()),
    (78, N'Níºmero Conteo', 2, 70, N'Níºmero Conteo', N'/configuracion/almacen/Numero_Conteo', N'RiListCheck2', 1, N'ESP', 8, 1, GETDATE()),

    -- Configuración -> Tesorerí­a
    (80, N'Tesorerí­a', 1, 1, N'Tesorerí­a', N'/', N'FaChartLine', 1, N'ESP', 7, 1, GETDATE()),
    (81, N'Tipo de Cambio', 2, 80, N'Tipo de Cambio', N'/configuracion/tesoreria/Tipo_Cambio', N'FaChartLine', 1, N'ESP', 1, 1, GETDATE()),
    (82, N'Tipo Inversión', 2, 80, N'Tipo Inversión', N'/configuracion/tesoreria/Tipo_Inversion', N'FaChartBar', 1, N'ESP', 2, 1, GETDATE()),
    (83, N'Tipo Moneda', 2, 80, N'Tipo Moneda', N'/configuracion/tesoreria/Tipo_Moneda', N'FaTag', 1, N'ESP', 3, 1, GETDATE()),
    (84, N'Tipo de Pago', 2, 80, N'Tipo de Pago', N'/configuracion/tesoreria/Tipo_Pago', N'FaDocument', 1, N'ESP', 4, 1, GETDATE()),
    (85, N'Tipo de Pago SF', 2, 80, N'Tipo de Pago SF', N'/configuracion/tesoreria/Tipo_PagoSF', N'FaDocument', 1, N'ESP', 5, 1, GETDATE()),
    (86, N'Tipo Solicitud CLC', 2, 80, N'Tipo Solicitud CLC', N'/configuracion/tesoreria/Tipo_Solicitud_CLC', N'FaFile', 1, N'ESP', 6, 1, GETDATE()),
    (87, N'Tipo Documento CLC', 2, 80, N'Tipo Documento CLC', N'/configuracion/tesoreria/Tipo_Documento_CLC', N'FaDocument', 1, N'ESP', 7, 1, GETDATE()),

    -- Presupuesto -> Egreso
    (100, N'Egreso', 1, 2, N'Egreso', N'/', N'FaChartPie', 1, N'ESP', 1, 1, GETDATE()),
    (101, N'Planeación', 1, 100, N'Planeación', N'/', N'FaCalendar', 1, N'ESP', 1, 1, GETDATE()),
    (102, N'Anteproyecto de Egresos', 2, 101, N'Anteproyecto de Egresos', N'/Presupuesto/Egreso/Planeacion/Anteproyecto_Egresos', N'FaDocument', 1, N'ESP', 1, 1, GETDATE()),
    (103, N'Presupuesto Autorizado', 2, 100, N'Presupuesto Autorizado', N'/Presupuesto/Egreso/Presupuesto_Autorizado', N'FaLock', 1, N'ESP', 2, 1, GETDATE()),
    (104, N'Presupuesto Modificado', 1, 100, N'Presupuesto Modificado', N'/', N'FaEdit', 1, N'ESP', 3, 1, GETDATE()),
    (105, N'Adecuaciones Compensadas', 2, 104, N'Adecuaciones Compensadas', N'/Presupuesto/Egreso/Presupesto_Modificado/Adecuaciones_Compensadas', N'FaDocument', 1, N'ESP', 1, 1, GETDATE()),
    (106, N'Adecuaciones', 2, 104, N'Adecuaciones', N'/Presupuesto/Egreso/Presupesto_Modificado/Adecuaciones', N'FaDocument', 1, N'ESP', 2, 1, GETDATE()),
    (107, N'Reducciones', 2, 104, N'Reducciones', N'/Presupuesto/Egreso/Presupesto_Modificado/Reducciones', N'FaDocument', 1, N'ESP', 3, 1, GETDATE()),
    (108, N'Presupuesto Comprometido', 1, 100, N'Presupuesto Comprometido', N'/', N'FaLock', 1, N'ESP', 4, 1, GETDATE()),
    (109, N'Solicitud Suficiencia', 2, 108, N'Solicitud Suficiencia', N'/Presupuesto/Egreso/Presupuesto_Comprometido/Solicitud_Suficiencia', N'FaDocument', 1, N'ESP', 1, 1, GETDATE()),
    (110, N'Autorización Suficiencia', 2, 108, N'Autorización Suficiencia', N'/Presupuesto/Egreso/Presupuesto_Comprometido/Autorizacion_Suficiencia', N'FaFlag', 1, N'ESP', 2, 1, GETDATE()),
    (111, N'Registro Comprometido', 2, 108, N'Registro Comprometido', N'/Presupuesto/Egreso/Presupuesto_Comprometido/Registro_Comprometido', N'FaSave', 1, N'ESP', 3, 1, GETDATE()),

    -- Presupuesto -> Tesorerí­a
    (120, N'Tesorerí­a', 1, 2, N'Tesorerí­a', N'/', N'FaChartLine', 1, N'ESP', 2, 1, GETDATE()),
    (121, N'Cuentas por Pagar', 1, 120, N'Cuentas por Pagar', N'/', N'FaDocument', 1, N'ESP', 1, 1, GETDATE()),
    (122, N'Recepción de Facturas y Comprobantes de Pago', 2, 121, N'Recepción de Facturas y Comprobantes de Pago', N'/Presupuesto/Tesoreria/CuentasXPagar/Factura_Pago', N'FaFile', 1, N'ESP', 1, 1, GETDATE()),
    (123, N'Provisión del Pago', 2, 121, N'Provisión del Pago', N'/Presupuesto/Tesoreria/CuentasXPagar/Provision_Pago', N'FaClock', 1, N'ESP', 2, 1, GETDATE()),
    (124, N'Elaboración de Cheques o Transferencias', 2, 121, N'Elaboración de Cheques o Transferencias', N'/Presupuesto/Tesoreria/CuentasXPagar/Cheque_Transferencia', N'FaSave', 1, N'ESP', 3, 1, GETDATE()),
    (125, N'Inversiones', 1, 120, N'Inversiones', N'/', N'FaChartBar', 1, N'ESP', 2, 1, GETDATE()),
    (126, N'Banco', 2, 125, N'Banco', N'/Presupuesto/Tesoreria/Inversiones/Banco', N'FaHome', 1, N'ESP', 1, 1, GETDATE()),
    (127, N'Cuenta Bancaria', 2, 125, N'Cuenta Bancaria', N'/Presupuesto/Tesoreria/Inversiones/Cuenta_Bancaria', N'FaFile', 1, N'ESP', 2, 1, GETDATE()),
    (128, N'Intermediarios Financiero', 2, 125, N'Intermediarios Financiero', N'/Presupuesto/Tesoreria/Inversiones/Intermediarios_Financiero', N'FaUsers', 1, N'ESP', 3, 1, GETDATE()),
    (129, N'Instrumentos de Inversión', 2, 125, N'Instrumentos de Inversión', N'/Presupuesto/Tesoreria/Inversiones/Instrumentos_Inversion', N'FaChartPie', 1, N'ESP', 4, 1, GETDATE()),
    (130, N'Listado de Inversiones', 2, 125, N'Listado de Inversiones', N'/Presupuesto/Tesoreria/Inversiones/Listado_Inversiones', N'RiListCheck2', 1, N'ESP', 5, 1, GETDATE()),
    (131, N'Tipo de Plazos', 2, 125, N'Tipo de Plazos', N'/Presupuesto/Tesoreria/Inversiones/Tipo_Plazos', N'FaClock', 1, N'ESP', 6, 1, GETDATE()),
    (132, N'Tipo de Retiro', 2, 125, N'Tipo de Retiro', N'/Presupuesto/Tesoreria/Inversiones/Tipo_Retiro', N'FaLockOpen', 1, N'ESP', 7, 1, GETDATE()),

    -- Contabilidad
    (200, N'Pólizas', 2, 3, N'Pólizas', N'/Contabilidad/Polizas', N'FaDocument', 1, N'ESP', 1, 1, GETDATE()),

    -- Adquisiciones
    (300, N'Programa Anual', 2, 4, N'Programa Anual', N'/Adquisiciones/Programa_Anual', N'FaCalendar', 1, N'ESP', 1, 1, GETDATE()),
    (301, N'Requisición', 2, 4, N'Requisición', N'/Adquisiciones/Requisicion', N'RiListCheck2', 1, N'ESP', 2, 1, GETDATE()),
    (302, N'Cotización', 2, 4, N'Cotización', N'/Adquisiciones/Cotizacion', N'FaDocument', 1, N'ESP', 3, 1, GETDATE()),
    (303, N'Solicitud Suficiencia', 2, 4, N'Solicitud Suficiencia', N'/Adquisiciones/Solicitud_Suficiencia', N'FaDocument', 1, N'ESP', 4, 1, GETDATE()),
    (304, N'Orden de Compra', 2, 4, N'Orden de Compra', N'/Adquisiciones/Orden_Compra', N'FaDocument', 1, N'ESP', 5, 1, GETDATE()),

    -- Patrimonio
    (400, N'Bienes', 2, 5, N'Bienes', N'/Patrimonio/Bienes', N'FaFolderOpen', 1, N'ESP', 1, 1, GETDATE()),
    (401, N'Clasificación de Bienes Muebles', 2, 5, N'Clasificación de Bienes Muebles', N'/Patrimonio/Clasificacion_Bienes_Muebles', N'FaFolder', 1, N'ESP', 2, 1, GETDATE()),
    (402, N'Bajas', 2, 5, N'Bajas', N'/Patrimonio/Bajas', N'FaTrash', 1, N'ESP', 3, 1, GETDATE()),
    (403, N'Calendario de Inventarios', 2, 5, N'Calendario de Inventarios', N'/Patrimonio/Calendario_Inventarios', N'FaCalendar', 1, N'ESP', 4, 1, GETDATE()),
    (404, N'Inventarios', 2, 5, N'Inventarios', N'/Patrimonio/Inventarios', N'RiListCheck2', 1, N'ESP', 5, 1, GETDATE()),
    (405, N'Cédula de Diferencia', 2, 5, N'Cédula de Diferencia', N'/Patrimonio/Cedula_Diferencia', N'FaDocument', 1, N'ESP', 6, 1, GETDATE()),
    (406, N'Resguardos', 2, 5, N'Resguardos', N'/Patrimonio/Resguardos', N'FaLock', 1, N'ESP', 7, 1, GETDATE()),
    (407, N'Firma Resguardos', 2, 5, N'Firma Resguardos', N'/Patrimonio/Firma_Resguardos', N'FaEdit', 1, N'ESP', 8, 1, GETDATE()),
    (408, N'Resguardo Histórico', 2, 5, N'Resguardo Histórico', N'/Patrimonio/Resguardo_Historico', N'FaFile', 1, N'ESP', 9, 1, GETDATE()),

    -- Almacén
    (500, N'Recepción de Pedidos', 2, 6, N'Recepción de Pedidos', N'/Almacen/Recepcion_Pedidos', N'FaFolderOpen', 1, N'ESP', 1, 1, GETDATE()),
    (501, N'Entradas por Ajuste', 2, 6, N'Entradas por Ajuste', N'/Almacen/Entradas_Ajuste', N'FaPlus', 1, N'ESP', 2, 1, GETDATE()),
    (502, N'Solicitudes de Salida', 2, 6, N'Solicitudes de Salida', N'/Almacen/Solicitudes_Salida', N'RiListCheck2', 1, N'ESP', 3, 1, GETDATE()),
    (503, N'Suministros de Salida', 2, 6, N'Suministros de Salida', N'/Almacen/Suministros_Salida', N'FaFile', 1, N'ESP', 4, 1, GETDATE()),
    (504, N'Existencias Registradas', 2, 6, N'Existencias Registradas', N'/Almacen/Existencias_Registradas', N'FaTable', 1, N'ESP', 5, 1, GETDATE()),
    (505, N'Conteo Cí­clico', 2, 6, N'Conteo Cí­clico', N'/Almacen/Conteo_ciclico', N'RiListCheck2', 1, N'ESP', 6, 1, GETDATE()),
    (506, N'Reporte de Diferencias de Conteo', 2, 6, N'Reporte de Diferencias de Conteo', N'/Almacen/Reporte_diferencias_Conteo', N'FaChartBar', 1, N'ESP', 7, 1, GETDATE()),
    (507, N'Conteo Cí­clico Anual', 2, 6, N'Conteo Cí­clico Anual', N'/Almacen/Conteo_ciclico_anual', N'FaCalendar', 1, N'ESP', 8, 1, GETDATE()),
    (508, N'Reporte de Diferencias de Conteo Anual', 2, 6, N'Reporte de Diferencias de Conteo Anual', N'/Almacen/Reporte_diferencias_Conteo_anual', N'FaChartLine', 1, N'ESP', 9, 1, GETDATE()),

    -- Nómina -> Recursos Humanos
    (600, N'Recursos Humanos', 1, 7, N'Nomina_Recursos_Humanos', N'/', N'FaUsers', 1, N'ESP', 1, 1, GETDATE()),
    (601, N'Empleados', 2, 600, N'Empleados', N'/nomina/empleados', N'FaUser', 1, N'ESP', 1, 1, GETDATE()),
    (602, N'Movimientos de Personal', 2, 600, N'Movimientos_Personal', N'/nomina/movimientos', N'FaEdit', 1, N'ESP', 2, 1, GETDATE()),
    (603, N'De Personal', 2, 600, N'De_Personal', N'/nomina/depersonal', N'FaUsers', 1, N'ESP', 3, 1, GETDATE()),
    (604, N'Reporte Quincenal MP', 2, 600, N'Reporte_Quincenal_MP', N'/nomina/reportequincenal', N'FaDateRange', 1, N'ESP', 4, 1, GETDATE()),
    (605, N'Créditos Trabajadores', 2, 600, N'Creditos_Trabajadores', N'/nomina/creditos', N'FaMoneyBillWave', 1, N'ESP', 5, 1, GETDATE()),

    -- Nómina -> Cálculo
    (610, N'Cálculo', 1, 7, N'Nomina_Calculo', N'/nom/calcnomina', N'FaCalculate', 1, N'ESP', 2, 1, GETDATE()),

    -- Nómina -> Auxiliares
    (620, N'Auxiliares', 1, 7, N'Nomina_Auxiliares', N'/', N'FaFolderOpen', 1, N'ESP', 3, 1, GETDATE()),
    (621, N'Calculo ISSSTE', 2, 620, N'Calculo_ISSSTE_4134', N'/aux/auxcalcissste', N'FaPercent', 1, N'ESP', 1, 1, GETDATE()),
    (622, N'Calculo ISR', 2, 620, N'Calculo_ISR_2053', N'/aux/auxcalcisrquincenal', N'FaPercent', 1, N'ESP', 2, 1, GETDATE()),
    (623, N'Calculo FOVISSSTE', 2, 620, N'Calculo_FOVISSSTE_4136', N'/aux/auxcalcfovissste', N'FaHouse', 1, N'ESP', 3, 1, GETDATE()),
    (624, N'Calculo Infonavit', 2, 620, N'Calculo_Infonavit_139', N'/aux/auxcalcinfonavitquincenal', N'FaHomeWork', 1, N'ESP', 4, 1, GETDATE()),
    (625, N'Calculo Cuotas IMSS', 2, 620, N'Calculo_IMSS_3084', N'/aux/auxcalcimssquincenal', N'FaPercent', 1, N'ESP', 5, 1, GETDATE()),

    -- Nómina -> Productos
    (630, N'Productos', 1, 7, N'Nomina_Productos', N'/', N'FaFolderOpen', 1, N'ESP', 4, 1, GETDATE()),
    (631, N'Resumen', 2, 630, N'Resumen_Nomina', N'/nom/resumennomina', N'FaChartPie', 1, N'ESP', 1, 1, GETDATE()),
    (632, N'Recibos', 2, 630, N'Recibos_Nomina', N'/nom/recibonomina', N'FaReceiptLong', 1, N'ESP', 2, 1, GETDATE()),
    (633, N'Archivos de Dispersión', 2, 630, N'Archivos_Dispersion', N'/nom/archivodispercion', N'FaFile', 1, N'ESP', 3, 1, GETDATE()),
    (634, N'Archivos de Timbrado', 2, 630, N'Archivos_Timbrado', N'/nom/timbradopercepciones', N'FaVerified', 1, N'ESP', 4, 1, GETDATE()),
    (635, N'Reporte Cuotas IMSS', 2, 630, N'Reporte_IMSS', N'/aux/imssquincenal_rep', N'FaChartBar', 1, N'ESP', 5, 1, GETDATE()),
    (636, N'Reporte Nómina Actual', 2, 630, N'Reporte_Nomina', N'/nom/reportenomina', N'FaDocument', 1, N'ESP', 6, 1, GETDATE()),

    -- Nómina -> Incidencias
    (640, N'Incidencias', 1, 7, N'Nomina_Incidencias', N'/', N'RiListCheck2', 1, N'ESP', 5, 1, GETDATE()),
    (641, N'Captura de Incidencias', 2, 640, N'Captura_Incidencias', N'/rh/incidencia', N'FaEdit', 1, N'ESP', 1, 1, GETDATE()),
    (642, N'Justificación de Incidencias', 2, 640, N'Justificacion_Incidencias', N'/rh/justificacion', N'FaVerified', 1, N'ESP', 2, 1, GETDATE()),
    (643, N'Reporte de Incidencias', 2, 640, N'Reporte_Incidencias', N'/rh/incidenciareport', N'FaChartLine', 1, N'ESP', 3, 1, GETDATE()),

    -- Nómina -> Pagos Extraordinarios
    (650, N'Pagos Extraordinarios', 1, 7, N'Concepto_Variable', N'/nom/conceptovariable', N'FaAttachMoney', 1, N'ESP', 6, 1, GETDATE()),

    -- Nómina -> Cierre de Periodo
    (660, N'Cierre de Periodo', 1, 7, N'Nomina_Cierre_Periodo', N'/nom/cierraperiodo', N'FaLock', 1, N'ESP', 7, 1, GETDATE()),

    -- Nómina -> Finiquito/Liquidación
    (670, N'Finiquito/Liquidación', 1, 7, N'Nomina_Finiquito_Liquidacion', N'/rh/liquidacion', N'FaReceiptLong', 1, N'ESP', 8, 1, GETDATE()),

    -- Nómina -> Nóminas Especiales
    (680, N'Nominas Especiales', 1, 7, N'Nominas_Especiales', N'/', N'FaCog', 1, N'ESP', 9, 1, GETDATE()),
    (681, N'Cálculo de Aguinaldo', 2, 680, N'Calc_Aguinaldo', N'/nom/calcaguinaldo', N'FaStar', 1, N'ESP', 1, 1, GETDATE()),
    (682, N'Configura Aguinaldo', 2, 680, N'Configura_Aguinaldo', N'/sis/nominaespecial', N'FaCog', 1, N'ESP', 2, 1, GETDATE()),
    (683, N'Aguinaldo', 2, 680, N'Aguinaldo', N'/sis/vwnominaespecial', N'FaStar', 1, N'ESP', 3, 1, GETDATE()),
    (684, N'Faltas Especiales', 2, 680, N'Faltas_Especial', N'/emp/faltasxempresa', N'FaClock', 1, N'ESP', 4, 1, GETDATE()),

    -- Nómina -> Históricos
    (700, N'Históricos de Nómina', 0, 7, N'Nomina_Historicos', N'/', N'FaClock', 1, N'ESP', 10, 1, GETDATE()),
    (710, N'Productos', 1, 700, N'Nomina_Productos_Historicos', N'/', N'FaFolderOpen', 1, N'ESP', 1, 1, GETDATE()),
    (711, N'Consulta de Nómina', 2, 710, N'Consulta_Nomina', N'/nomina/historicos/consulta', N'FaSearch', 1, N'ESP', 1, 1, GETDATE()),
    (712, N'Análisis', 2, 710, N'Analisis', N'/nomina/historicos/analisis', N'FaChartLine', 1, N'ESP', 2, 1, GETDATE()),
    (713, N'Recibos', 2, 710, N'Recibos_Historicos', N'/nomina/historicos/recibos', N'FaReceiptLong', 1, N'ESP', 3, 1, GETDATE()),
    (714, N'Archivos de Dispersión', 2, 710, N'Archivos_Dispersion_Historicos', N'/nomina/historicos/dispersion', N'FaFile', 1, N'ESP', 4, 1, GETDATE()),
    (715, N'Archivos de Timbrado', 2, 710, N'Archivos_Timbrado_Historicos', N'/nomina/historicos/timbrado', N'FaVerified', 1, N'ESP', 5, 1, GETDATE()),
    (716, N'Reporte Nómina Quincenal', 2, 710, N'Reporte_Nomina_Quincenal', N'/nomina/historicos/reportequincenal', N'FaDateRange', 1, N'ESP', 6, 1, GETDATE()),
    (717, N'Resumen de Nómina Histórica', 2, 710, N'Resumen_Nomina_Historica', N'/nomina/historicos/resumen', N'FaChartPie', 1, N'ESP', 7, 1, GETDATE()),
    (718, N'Reporte de Nómina Histórica', 2, 710, N'Reporte_Nomina_Historica', N'/nomina/historicos/reportehistorico', N'FaDocument', 1, N'ESP', 8, 1, GETDATE()),
    (719, N'Cubo Nómina Histórica', 2, 710, N'Cubo_Nomina_Historica', N'/nomina/historicos/cubo', N'FaTable', 1, N'ESP', 9, 1, GETDATE()),

    (720, N'Reportes del IMSS', 1, 700, N'Reportes_IMSS_Historicos', N'/', N'FaChartBar', 1, N'ESP', 2, 1, GETDATE()),
    (721, N'Salario Base de Cotización', 2, 720, N'Salario_Base_Cotizacion', N'/nomina/historicos/sbc', N'FaPercent', 1, N'ESP', 1, 1, GETDATE()),
    (722, N'Acumulados IMSS', 2, 720, N'Acumulados_IMSS', N'/nomina/historicos/acumuladosimss', N'FaChartBar', 1, N'ESP', 2, 1, GETDATE()),
    (723, N'SBC Histórico', 2, 720, N'SBC_Historico', N'/nomina/historicos/sbchistorico', N'FaClock', 1, N'ESP', 3, 1, GETDATE()),
    (724, N'Acumulados en el Bimestre IMSS', 2, 720, N'Acumulados_Bimestre_IMSS', N'/nomina/historicos/acumuladosbimestre', N'FaDateRange', 1, N'ESP', 4, 1, GETDATE()),

    (730, N'Reportes del SAT', 1, 700, N'Reportes_SAT_Historicos', N'/', N'FaChartLine', 1, N'ESP', 3, 1, GETDATE()),
    (731, N'Acumulado Mensual ISR', 2, 730, N'Acumulado_Mensual_ISR', N'/nomina/historicos/isr_mensual', N'FaPercent', 1, N'ESP', 1, 1, GETDATE()),
    (732, N'Acumulados de ISR', 2, 730, N'Acumulados_ISR', N'/nomina/historicos/isr_acumulados', N'FaChartLine', 1, N'ESP', 2, 1, GETDATE()),

    (740, N'Impuestos sobre Nómina locales', 1, 700, N'Impuestos_Locales_Historicos', N'/nomina/historicos/impuestoslocales', N'FaHouse', 1, N'ESP', 4, 1, GETDATE()),

    -- Nómina -> Configuración Nóminas
    (800, N'Configuración Nóminas', 0, 7, N'Configuracion_Nominas', N'/', N'FaCog', 1, N'ESP', 11, 1, GETDATE()),
    (810, N'Catálogos', 1, 800, N'Nomina_Catalogos', N'/', N'FaFolderOpen', 1, N'ESP', 1, 1, GETDATE()),
    (811, N'Tipo de Nómina', 2, 810, N'Tipo_Nomina', N'/nomina/configuracion/catalogos/tipo-nomina', N'FaEventAvailable', 1, N'ESP', 1, 1, GETDATE()),
    (812, N'Cuotas IMSS', 2, 810, N'Cuotas_IMSS', N'/nomina/configuracion/catalogos/cuotas-imss', N'FaPercent', 1, N'ESP', 2, 1, GETDATE()),
    (813, N'Conceptos de Nómina', 2, 810, N'Conceptos_Nomina', N'/nomina/configuracion/catalogos/conceptos', N'FaPayments', 1, N'ESP', 3, 1, GETDATE()),
    (814, N'UMA', 2, 810, N'UMA', N'/nomina/configuracion/catalogos/uma', N'FaPriceChange', 1, N'ESP', 4, 1, GETDATE()),
    (815, N'Tipo de Contratación', 2, 810, N'Tipo_Contratacion', N'/nomina/configuracion/catalogos/tipo-contratacion', N'FaUserGroup', 1, N'ESP', 5, 1, GETDATE()),
    (816, N'Tipo de descanso', 2, 810, N'Tipo_Descanso', N'/nomina/configuracion/catalogos/tipo-descanso', N'FaClock', 1, N'ESP', 6, 1, GETDATE()),
    (817, N'Tipo de Incidencia', 2, 810, N'Tipo_Incidencia', N'/nomina/configuracion/catalogos/tipo-incidencia', N'FaSick', 1, N'ESP', 7, 1, GETDATE()),
    (818, N'Conceptos de importe Fijo', 2, 810, N'Concepto_Fijo', N'/nomina/configuracion/catalogos/concepto-fijo', N'FaAttachMoney', 1, N'ESP', 8, 1, GETDATE()),
    (819, N'Tipo de Justificación', 2, 810, N'Tipo_Justificacion', N'/nomina/configuracion/catalogos/tipo-justificacion', N'FaVerified', 1, N'ESP', 9, 1, GETDATE()),
    (820, N'Tabulador', 2, 810, N'Tabulador', N'/nomina/configuracion/catalogos/tabulador', N'FaTableRows', 1, N'ESP', 10, 1, GETDATE()),
    (821, N'Unidad Infonavit', 2, 810, N'Unidad_Infonavit', N'/nomina/configuracion/catalogos/unidad-infonavit', N'FaHomeWork', 1, N'ESP', 11, 1, GETDATE()),
    (822, N'Salario Mí­nimo General', 2, 810, N'Salario_Minimo', N'/nomina/configuracion/catalogos/smg', N'FaMoneyBillWave', 1, N'ESP', 12, 1, GETDATE()),
    (823, N'Forma de Pago', 2, 810, N'Forma_Pago', N'/nomina/configuracion/catalogos/forma-pago', N'FaPointOfSale', 1, N'ESP', 13, 1, GETDATE()),
    (824, N'Forma de Cálculo', 2, 810, N'Forma_Calculo', N'/nomina/configuracion/catalogos/forma-calculo', N'FaFunctions', 1, N'ESP', 14, 1, GETDATE()),
    (825, N'Capí­tulos', 2, 810, N'Capitulos', N'/nomina/configuracion/catalogos/capitulos', N'RiListCheck2', 1, N'ESP', 15, 1, GETDATE()),

    (830, N'Periodos', 1, 800, N'Nomina_Periodos', N'/', N'FaCalendarMonth', 1, N'ESP', 2, 1, GETDATE()),
    (831, N'Semanal', 2, 830, N'Periodo_Semanal', N'/nomina/configuracion/periodos/semanal', N'FaViewWeek', 1, N'ESP', 1, 1, GETDATE()),
    (832, N'Quincenal', 2, 830, N'Periodo_Quincenal', N'/nomina/configuracion/periodos/quincenal', N'FaDateRange', 1, N'ESP', 2, 1, GETDATE()),
    (833, N'Mensual', 2, 830, N'Periodo_Mensual', N'/nomina/configuracion/periodos/mensual', N'FaCalendarMonth', 1, N'ESP', 3, 1, GETDATE()),
    (834, N'Bimestral', 2, 830, N'Periodo_Bimestral', N'/nomina/configuracion/periodos/bimestral', N'FaCalendar', 1, N'ESP', 4, 1, GETDATE()),

    (840, N'Tablas ISR', 1, 800, N'Nomina_Tablas_ISR', N'/', N'FaTable', 1, N'ESP', 3, 1, GETDATE()),
    (841, N'Semanal', 2, 840, N'Tabla_ISR_Semanal', N'/nomina/configuracion/isr/semanal', N'FaPercent', 1, N'ESP', 1, 1, GETDATE()),
    (842, N'Quincenal', 2, 840, N'Tabla_ISR_Quincenal', N'/nomina/configuracion/isr/quincenal', N'FaPercent', 1, N'ESP', 2, 1, GETDATE()),
    (843, N'Mensual', 2, 840, N'Tabla_ISR_Mensual', N'/nomina/configuracion/isr/mensual', N'FaPercent', 1, N'ESP', 3, 1, GETDATE()),

    (850, N'Prestaciones', 1, 800, N'Nomina_Prestaciones', N'/', N'FaStar', 1, N'ESP', 4, 1, GETDATE()),

    (860, N'Subsidios ISR', 1, 800, N'Nomina_Subsidios_ISR', N'/', N'FaPercent', 1, N'ESP', 5, 1, GETDATE()),
    (861, N'Semanal', 2, 860, N'Subsidio_ISR_Semanal', N'/nomina/configuracion/subsidios/semanal', N'FaPercent', 1, N'ESP', 1, 1, GETDATE()),
    (862, N'Quincenal', 2, 860, N'Subsidio_ISR_Quincenal', N'/nomina/configuracion/subsidios/quincenal', N'FaPercent', 1, N'ESP', 2, 1, GETDATE()),
    (863, N'Mensual', 2, 860, N'Subsidio_ISR_Mensual', N'/nomina/configuracion/subsidios/mensual', N'FaPercent', 1, N'ESP', 3, 1, GETDATE()),

    (870, N'Impuestos', 1, 800, N'Nomina_Impuestos', N'/', N'FaPercent', 1, N'ESP', 6, 1, GETDATE()),
    (871, N'Base Gravable', 2, 870, N'Base_Gravable', N'/nomina/configuracion/impuestos/base-gravable', N'FaPercent', 1, N'ESP', 1, 1, GETDATE()),
    (872, N'Impuestos Locales', 2, 870, N'Impuestos_Locales', N'/nomina/configuracion/impuestos/locales', N'FaHouse', 1, N'ESP', 2, 1, GETDATE()),

    (880, N'IMSS', 1, 800, N'Nomina_IMSS', N'/', N'FaUsers', 1, N'ESP', 7, 1, GETDATE()),
    (881, N'Prestaciones Mí­nimas de Ley', 2, 880, N'Prestaciones_Minimas', N'/nomina/configuracion/imss/prestaciones', N'FaDocument', 1, N'ESP', 1, 1, GETDATE()),
    (882, N'Clase IMSS', 2, 880, N'Clase_IMSS', N'/nomina/configuracion/imss/clase', N'FaVerified', 1, N'ESP', 2, 1, GETDATE()),
    (883, N'Fracción IMSS', 2, 880, N'Fraccion_IMSS', N'/nomina/configuracion/imss/fraccion', N'FaPercent', 1, N'ESP', 3, 1, GETDATE()),
    (884, N'Base Gravable IMSS', 2, 880, N'Base_Gravable_IMSS', N'/nomina/configuracion/imss/base-gravable', N'FaPercent', 1, N'ESP', 4, 1, GETDATE()),

    -- Nómina -> Configuración RH
    (900, N'Configuración RH', 0, 7, N'Configuracion_RH', N'/rh/configuracion', N'FaGears', 1, N'ESP', 12, 1, GETDATE()),
    (901, N'Plazas Autorizadas', 1, 900, N'Plazas_Autorizadas', N'/rh/configuracion/plazas', N'FaVerified', 1, N'ESP', 1, 1, GETDATE()),
    (902, N'Universo', 1, 900, N'Universo', N'/rh/configuracion/universo', N'FaUsers', 1, N'ESP', 2, 1, GETDATE()),
    (903, N'Nivel', 1, 900, N'Nivel', N'/rh/configuracion/nivel', N'FaChartBar', 1, N'ESP', 3, 1, GETDATE()),
    (904, N'Sexo', 1, 900, N'Sexo', N'/rh/configuracion/sexo', N'FaUsers', 1, N'ESP', 4, 1, GETDATE()),
    (905, N'Estado Civil', 1, 900, N'Estado_Civil', N'/rh/configuracion/estado-civil', N'FaHeart', 1, N'ESP', 5, 1, GETDATE()),
    (906, N'Escolaridad', 1, 900, N'Escolaridad', N'/rh/configuracion/escolaridad', N'FaDocument', 1, N'ESP', 6, 1, GETDATE()),
    (907, N'Tipo de Parentesco', 1, 900, N'Tipo_Parentesco', N'/rh/configuracion/parentesco', N'FaUsers', 1, N'ESP', 7, 1, GETDATE()),
    (908, N'Estado', 1, 900, N'Estado', N'/rh/configuracion/estado', N'FaHouse', 1, N'ESP', 8, 1, GETDATE()),
    (909, N'Banco', 1, 900, N'Banco', N'/rh/configuracion/banco', N'FaHouse', 1, N'ESP', 9, 1, GETDATE()),
    (910, N'Municipio', 1, 900, N'Municipio', N'/rh/configuracion/municipio', N'FaHouse', 1, N'ESP', 10, 1, GETDATE()),
    (911, N'Contratos', 1, 900, N'Contratos', N'/rh/configuracion/contratos', N'FaDocument', 1, N'ESP', 11, 1, GETDATE()),
    (912, N'Base Pago', 2, 911, N'Base_Pago', N'/rh/configuracion/contratos/base-pago', N'FaMoneyBillWave', 1, N'ESP', 1, 1, GETDATE()),
    (913, N'Método de Pago', 2, 911, N'Metodo_Pago', N'/rh/configuracion/contratos/metodo-pago', N'FaCreditCard', 1, N'ESP', 2, 1, GETDATE()),
    (914, N'Tipo de Régimen', 2, 911, N'Tipo_Regimen', N'/rh/configuracion/contratos/tipo-regimen', N'FaDocument', 1, N'ESP', 3, 1, GETDATE()),
    (915, N'Base de Cotización', 2, 911, N'Base_Cotizacion', N'/rh/configuracion/contratos/base-cotizacion', N'FaPercent', 1, N'ESP', 4, 1, GETDATE()),
    (916, N'Zona Geográfica', 2, 911, N'Zona_Geografica', N'/rh/configuracion/contratos/zona-geografica', N'FaHouse', 1, N'ESP', 5, 1, GETDATE()),
    (917, N'Dí­a de la Semana', 2, 911, N'Dia_Semana', N'/rh/configuracion/contratos/dia-semana', N'FaCalendar', 1, N'ESP', 6, 1, GETDATE())
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
