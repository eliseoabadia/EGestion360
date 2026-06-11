USE [GestionEmpresarial];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;

DECLARE @RoleId NVARCHAR(128) = (SELECT TOP (1) Id FROM dbo.AspNetRoles WHERE Code = N'10000');

IF @RoleId IS NULL
BEGIN
    THROW 51000, 'No existe el rol con Code = 10000.', 1;
END;

DECLARE @MenuFix TABLE
(
    PKIdMenu INT NOT NULL PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL,
    Tipo INT NOT NULL,
    FKIdMenu_SIS INT NULL,
    LegacyName NVARCHAR(80) NOT NULL,
    Ruta NVARCHAR(300) NOT NULL,
    ImageUrl NVARCHAR(50) NOT NULL,
    Orden INT NOT NULL
);

INSERT INTO @MenuFix (PKIdMenu, Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta, ImageUrl, Orden)
VALUES
    (52,  N'Menú', 2, 50, N'Menu', N'/configuracion/sistema/menu', N'FaTable', 2),
    (219, N'Programas Presupuestales', 2, 100, N'Programas_Presupuestales', N'/configuracion/presupuestales/programas-presupuesta', N'FaListAlt', 1),
    (221, N'Unidad Responsable', 2, 220, N'UnidadResponsable', N'/configuracion/presupuestales/clave-programa/unidad-responsable', N'FaList', 1),
    (223, N'Función', 2, 220, N'Funcion', N'/configuracion/presupuestales/clave-programa/funcion', N'FaList', 3),
    (225, N'Actividad Institucional', 2, 220, N'Actividad_Institucional', N'/configuracion/presupuestales/clave-programa/actividad-institucional', N'FaList', 5),
    (228, N'Programa Presupuestal', 2, 220, N'Programa_Presupuestal', N'/configuracion/presupuestales/clave-programa/programa-presupuestal', N'FaList', 8),
    (232, N'Años', 2, 220, N'Anios', N'/configuracion/presupuestales/clave-programa/anios', N'FaList', 12),
    (235, N'Tipo Recurso', 2, 220, N'TipoRecurso', N'/configuracion/presupuestales/clave-programa/tipo-recurso', N'FaList', 15),
    (236, N'Fuente Financiamiento', 2, 220, N'Fuente_Financiamiento', N'/configuracion/presupuestales/clave-programa/fuente-financiamiento', N'FaList', 16),
    (241, N'Tipo Pólizas', 2, 240, N'Tipo_Polizas', N'/configuracion/contabilidad/tipo-polizas', N'FaList', 1),
    (242, N'Tipo Detalles Pólizas', 2, 240, N'Tipo_detalles_Polizas', N'/configuracion/contabilidad/tipo-detalles-polizas', N'FaList', 2),
    (243, N'Matriz Conversión', 2, 240, N'Matriz_Conversion', N'/configuracion/contabilidad/matriz-conversion', N'FaList', 3),
    (244, N'Matriz Conversión Ingresos', 2, 240, N'Matriz_Conversion_Ingresos', N'/configuracion/contabilidad/matriz-conversion-ingresos', N'FaList', 4),
    (245, N'Partidas Presupuestales', 2, 240, N'Partidas_Presupuestales', N'/configuracion/contabilidad/partidas-presupuestales', N'FaList', 5),
    (246, N'Cuentas Contables', 2, 240, N'Cuentas_Contables', N'/configuracion/contabilidad/cuentas-contables', N'FaList', 6),
    (247, N'Formas Pago', 2, 240, N'Formas_Pago', N'/configuracion/contabilidad/formas-pago', N'FaList', 7),
    (252, N'Tipo de Contrato', 2, 250, N'Tipo_Contrato', N'/configuracion/adquisiciones/tipo-contrato', N'FaList', 2),
    (253, N'Tipo de Documentos', 2, 250, N'Tipo_Documentos', N'/configuracion/adquisiciones/tipo-documento', N'FaList', 3),
    (254, N'Tipo de Garantía', 2, 250, N'Tipo_Garantia', N'/configuracion/adquisiciones/tipo-garantia', N'FaList', 4),
    (255, N'Procedimientos de Contratación', 2, 250, N'Procedimientos_Contratacion', N'/configuracion/adquisiciones/procedimientos-contratacion', N'FaList', 5),
    (256, N'Estatus Requisición', 2, 250, N'Estatus_Requisicion', N'/configuracion/adquisiciones/estatus-requisicion', N'FaList', 6),
    (258, N'Artículo', 2, 250, N'Articulo', N'/configuracion/adquisiciones/articulo', N'FaList', 8),
    (259, N'Fracción', 2, 250, N'Fraccion', N'/configuracion/adquisiciones/fraccion', N'FaList', 9),
    (262, N'Grupo Bien', 2, 260, N'Grupo_Bien', N'/configuracion/Patrimonio/Grupo_Bien', N'FaList', 2),
    (263, N'Bienes y Servicios', 2, 260, N'Bienes_Servicios', N'/configuracion/Patrimonio/Bienes_Servicios', N'FaList', 3),
    (264, N'Tipo de Patrimonio', 2, 260, N'Tipo_Patrimonio', N'/configuracion/Patrimonio/Tipo_Patrimonio', N'FaList', 4),
    (265, N'Tipo de Adquisición', 2, 260, N'Tipo_Adquisicion', N'/configuracion/Patrimonio/Tipo_Adquisicion', N'FaList', 5),
    (271, N'Motivo de Entradas Salidas', 2, 270, N'Movimiento_Entrada_Salida', N'/configuracion/almacen/Motivo_Entradas_Salidas', N'FaList', 1),
    (272, N'Estatus Solicitud', 2, 270, N'Estatus_Solicitud', N'/configuracion/almacen/Estatus_Solicitud', N'FaList', 2),
    (274, N'Periodo de Conteo', 2, 270, N'Conteo_Periodo', N'/configuracion/almacen/Perido_Conteo', N'FaList', 4),
    (281, N'Tipo de Cambio', 2, 280, N'Tipo_Cambio', N'/configuracion/tesoreria/Tipo_Cambio', N'FaList', 1),
    (282, N'Tipo Inversión', 2, 280, N'Tipo_Inversion', N'/configuracion/tesoreria/Tipo_Inversion', N'FaList', 2),
    (283, N'Tipo Moneda', 2, 280, N'Tipo_Moneda', N'/configuracion/tesoreria/Tipo_Moneda', N'FaList', 3),
    (284, N'Tipo de Pago', 2, 280, N'Tipo_Pago', N'/configuracion/tesoreria/Tipo_Pago', N'FaList', 4),
    (285, N'Tipo de Pago SF', 2, 280, N'Tipo_PagoSF', N'/configuracion/tesoreria/Tipo_PagoSF', N'FaList', 5),
    (286, N'Tipo Solicitud CLC', 2, 280, N'Tipo_SolicitudCLC', N'/configuracion/tesoreria/Tipo_Solicitud_CLC', N'FaList', 6),
    (287, N'Tipo Documento CLC', 2, 280, N'Tipo_DoctoCLC', N'/configuracion/tesoreria/Tipo_Documento_CLC', N'FaList', 7),
    (301, N'Presupuesto Autorizado', 2, 300, N'Presupuesto_Autorizado', N'/Presupuesto/Egreso/Presupuesto_Autorizado', N'FaLock', 1),
    (311, N'Anteproyecto de Egresos', 2, 310, N'Anteproyecto_Egresos', N'/Presupuesto/Egreso/Planeacion/Anteproyecto_Egresos', N'FaLock', 1),
    (313, N'Solicitud Suficiencia', 2, 312, N'Solicitud_Suficiencia', N'/Presupuesto/Egreso/Presupuesto_Comprometido/Solicitud_Suficiencia', N'FaLock', 1),
    (314, N'Autorización Suficiencia', 2, 312, N'Autorizacion_Suficiencia', N'/Presupuesto/Egreso/Presupuesto_Comprometido/Autorizacion_Suficiencia', N'FaLock', 2),
    (315, N'Registro Comprometido', 2, 312, N'Registro_Comprometido', N'/Presupuesto/Egreso/Presupuesto_Comprometido/Registro_Comprometido', N'FaLock', 3),
    (331, N'Adecuaciones Compensadas', 2, 330, N'Adecuaciones_Compensadas', N'/Presupuesto/Egreso/Presupesto_Modificado/Adecuaciones_Compensadas', N'FaLock', 1),
    (332, N'Ampliaciones', 2, 330, N'Ampliaciones', N'/Presupuesto/Egreso/Presupesto_Modificado/Adecuaciones', N'FaLock', 2),
    (333, N'Reducciones', 2, 330, N'Reducciones', N'/Presupuesto/Egreso/Presupesto_Modificado/Reducciones', N'FaLock', 3),
    (352, N'Recepción de Facturas y Comprobantes de Pago', 2, 351, N'RecepcionFactura_ComprobantePago', N'/Presupuesto/Tesorería/CuentasXPagar/Factura_Pago', N'FaLock', 1),
    (353, N'Provisión del Pago', 2, 351, N'Provision_Pago', N'/Presupuesto/Tesorería/CuentasXPagar/Provision_Pago', N'FaLock', 2),
    (354, N'Elaboración de Cheques o Transferencias', 2, 351, N'ElaboracionCheque_Transferencia', N'/Presupuesto/Tesorería/CuentasXPagar/Cheque_Transferencia', N'FaLock', 3),
    (371, N'Banco', 2, 370, N'Banco', N'/Presupuesto/Tesorería/Inversiones/Banco', N'FaLock', 1),
    (372, N'Cuenta Bancaria', 2, 370, N'Cuenta_Bancaria', N'/Presupuesto/Tesorería/Inversiones/Cuenta_Bancaria', N'FaLock', 2),
    (373, N'Intermediarios Financiero', 2, 370, N'Intermediarios_Financiero', N'/Presupuesto/Tesorería/Inversiones/Intermediarios_Financiero', N'FaLock', 3),
    (374, N'Instrumentos de Inversión', 2, 370, N'Instrumentos_Inversion', N'/Presupuesto/Tesorería/Inversiones/Instrumentos_Inversion', N'FaLock', 4),
    (375, N'Listado de Inversiones', 2, 370, N'Listado_Inversiones', N'/Presupuesto/Tesorería/Inversiones/Listado_Inversiones', N'FaLock', 5),
    (376, N'Tipo de Plazos', 2, 370, N'Tipo_Plazos', N'/Presupuesto/Tesorería/Inversiones/Tipo_Plazos', N'FaLock', 6),
    (377, N'Tipo de Retiro', 2, 370, N'Tipo_Retiro', N'/Presupuesto/Tesorería/Inversiones/Tipo_Retiro', N'FaLock', 7),
    (400, N'Programa Anual', 2, 4, N'Programa_Anual_Adquisiciones', N'/Adquisiciones/Programa_Anual', N'FaDocument', 1),
    (401, N'Requisición', 2, 4, N'requisicion', N'/Adquisiciones/Requisicion', N'FaDocument', 2),
    (402, N'Cotización', 2, 4, N'Cotizacion', N'/Adquisiciones/Cotizacion', N'FaDocument', 3),
    (403, N'Solicitud Suficiencia', 2, 4, N'SolicitudSuficiencia', N'/Adquisiciones/Solicitud_Suficiencia', N'FaDocument', 4),
    (404, N'Orden de Compra', 2, 4, N'OrdenCompra', N'/Adquisiciones/Orden_Compra', N'FaDocument', 8),
    (500, N'Pólizas', 2, 3, N'Polizas', N'/Contabilidad/Polizas', N'FaDocument', 1),
    (601, N'Bienes', 2, 5, N'Bienes', N'/Patrimonio/Bienes', N'FaLock', 2),
    (602, N'Clasificación de Bienes Muebles', 2, 5, N'Clasificacion_Bienes_Muebles', N'/Patrimonio/Clasificacion_Bienes_Muebles', N'FaLock', 3),
    (603, N'Bajas', 2, 5, N'Bajas', N'/Patrimonio/Bajas', N'FaLock', 4),
    (604, N'Calendario de Inventarios', 2, 5, N'Calendario_Inventarios', N'/Patrimonio/Calendario_Inventarios', N'FaLock', 5),
    (605, N'Inventarios', 2, 5, N'Inventarios', N'/Patrimonio/Inventarios', N'FaLock', 6),
    (606, N'Cédula de Diferencia', 2, 5, N'Cedula_Diferencia', N'/Patrimonio/Cedula_Diferencia', N'FaLock', 7),
    (607, N'Resguardos', 2, 5, N'Resguardos', N'/Patrimonio/Resguardos', N'FaLock', 8),
    (608, N'Firma Resguardos', 2, 5, N'Firma_Resguardos', N'/Patrimonio/Firma_Resguardos', N'FaLock', 9),
    (609, N'Resguardo Histórico', 2, 5, N'Resguardo_Historico', N'/Patrimonio/Resguardo_Historico', N'FaLock', 10),
    (700, N'Recepción de Pedidos', 2, 6, N'Recepcion_Pedidos', N'/Almacen/Recepcion_Pedidos', N'FaLock', 1),
    (701, N'Entradas por Ajuste', 2, 6, N'Entradas_Ajuste', N'/Almacen/Entradas_Ajuste', N'FaLock', 2),
    (709, N'Salidas por Ajuste', 2, 6, N'Salidas_Ajuste', N'/Almacen/Salidas_Ajuste', N'FaLock', 3),
    (702, N'Solicitudes de Salida', 2, 6, N'Solicitudes_Salida', N'/Almacen/Solicitudes_Salida', N'FaLock', 4),
    (703, N'Suministros de Salida', 2, 6, N'Suministros_Salida', N'/Almacen/Suministros_Salida', N'FaLock', 5),
    (704, N'Existencias Registradas', 2, 6, N'Existencias_Registradas', N'/Almacen/Existencias_Registradas', N'FaLock', 6),
    (705, N'Conteo Cíclico', 2, 6, N'conteo_ciclico', N'/Almacen/Conteo_ciclico', N'FaLock', 7),
    (706, N'Reporte de Diferencias de Conteo', 2, 6, N'Reporte_diferencias_Conteo', N'/Almacen/Reporte_diferencias_Conteo', N'FaLock', 8),
    (707, N'Conteo Cíclico Anual', 2, 6, N'conteo_ciclico_anual', N'/Almacen/Conteo_ciclico_anual', N'FaLock', 9),
    (708, N'Reporte de Diferencias de Conteo Anual', 2, 6, N'Reporte_diferencias_conteo_anual', N'/Almacen/Reporte_diferencias_Conteo_anual', N'FaLock', 10);

SET IDENTITY_INSERT SIS.Menu ON;

MERGE SIS.Menu AS target
USING @MenuFix AS source
ON target.PKIdMenu = source.PKIdMenu
WHEN MATCHED THEN
    UPDATE SET
        target.Nombre = source.Nombre,
        target.Tipo = source.Tipo,
        target.FKIdMenu_SIS = source.FKIdMenu_SIS,
        target.LegacyName = source.LegacyName,
        target.Ruta = source.Ruta,
        target.ImageUrl = source.ImageUrl,
        target.Activo = 1,
        target.Lenguaje = N'ESP',
        target.Orden = source.Orden,
        target.ModifiedByOperatorId = 1,
        target.ModifiedDateTime = GETDATE()
WHEN NOT MATCHED BY TARGET THEN
    INSERT
    (
        PKIdMenu, Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta, ImageUrl,
        Activo, Lenguaje, Orden, CreatedByOperatorId, CreatedDateTime
    )
    VALUES
    (
        source.PKIdMenu, source.Nombre, source.Tipo, source.FKIdMenu_SIS, source.LegacyName,
        source.Ruta, source.ImageUrl, 1, N'ESP', source.Orden, 1, GETDATE()
    );

SET IDENTITY_INSERT SIS.Menu OFF;

INSERT INTO SIS.MenuRole (FKIdMenu_SIS, RoleId, Activo, CreatedByOperatorId, CreatedDateTime)
SELECT m.PKIdMenu, @RoleId, 1, 1, GETDATE()
FROM SIS.Menu AS m
WHERE m.Activo = 1
  AND NOT EXISTS
  (
      SELECT 1
      FROM SIS.MenuRole AS mr
      WHERE mr.FKIdMenu_SIS = m.PKIdMenu
        AND mr.RoleId = @RoleId
  );

UPDATE mr
SET Activo = 1,
    ModifiedByOperatorId = 1,
    ModifiedDateTime = GETDATE()
FROM SIS.MenuRole AS mr
WHERE mr.RoleId = @RoleId
  AND EXISTS (SELECT 1 FROM SIS.Menu AS m WHERE m.PKIdMenu = mr.FKIdMenu_SIS AND m.Activo = 1);

DECLARE @ClaimFix TABLE
(
    [Group] NVARCHAR(100) NOT NULL,
    SubGroup NVARCHAR(100) NOT NULL,
    [Values] NVARCHAR(MAX) NOT NULL,
    Code NVARCHAR(10) NULL,
    [Description] NVARCHAR(200) NULL,
    PRIMARY KEY ([Group], SubGroup)
);

INSERT INTO @ClaimFix ([Group], SubGroup, [Values], Code, [Description])
VALUES
    (N'Sistema', N'Menu', N'view,view-menu,delete,new,update,CanExportToExcel', N'SIS001', N'Sistema'),
    (N'Catalogos_presupuestales', N'Programas_Presupuestales', N'view,view-menu,delete,new,update,CanExportToExcel', N'PRE001', N'Catálogos presupuestales'),
    (N'ClavePrograma', N'UnidadResponsable', N'view,view-menu,delete,new,update,CanExportToExcel', N'CP001', N'Clave Programa'),
    (N'ClavePrograma', N'Funcion', N'view,view-menu,delete,new,update,CanExportToExcel', N'CP003', N'Clave Programa'),
    (N'ClavePrograma', N'Actividad_Institucional', N'view,view-menu,delete,new,update,CanExportToExcel', N'CP005', N'Clave Programa'),
    (N'ClavePrograma', N'Programa_Presupuestal', N'view,view-menu,delete,new,update,CanExportToExcel', N'CP008', N'Clave Programa'),
    (N'ClavePrograma', N'Anios', N'view,view-menu,delete,new,update,CanExportToExcel', N'CP012', N'Clave Programa'),
    (N'ClavePrograma', N'TipoRecurso', N'view,view-menu,delete,new,update,CanExportToExcel', N'CP015', N'Clave Programa'),
    (N'ClavePrograma', N'Fuente_Financiamiento', N'view,view-menu,delete,new,update,CanExportToExcel', N'CP016', N'Clave Programa'),
    (N'Contabilidad', N'Tipo_Polizas', N'view,view-menu,delete,new,update,CanExportToExcel', N'CON001', N'Contabilidad'),
    (N'Contabilidad', N'Tipo_detalles_Polizas', N'view,view-menu,delete,new,update,CanExportToExcel', N'CON002', N'Contabilidad'),
    (N'Contabilidad', N'Matriz_Conversion', N'view,view-menu,delete,new,update,CanExportToExcel', N'CON003', N'Contabilidad'),
    (N'Contabilidad', N'Matriz_Conversion_Ingresos', N'view,view-menu,delete,new,update,CanExportToExcel', N'CON004', N'Contabilidad'),
    (N'Contabilidad', N'Partidas_Presupuestales', N'view,view-menu,delete,new,update,CanExportToExcel', N'CON005', N'Contabilidad'),
    (N'Contabilidad', N'Cuentas_Contables', N'view,view-menu,delete,new,update,CanExportToExcel', N'CON006', N'Contabilidad'),
    (N'Contabilidad', N'Formas_Pago', N'view,view-menu,delete,new,update,CanExportToExcel', N'CON007', N'Contabilidad'),
    (N'Contabilidad', N'Polizas', N'view,view-menu,delete,new,update,CanExportToExcel', N'CONPOL01', N'Contabilidad'),
    (N'Adquisiciones', N'Tipo_Contrato', N'view,view-menu,delete,new,update,CanExportToExcel', N'ADQ002', N'Adquisiciones'),
    (N'Adquisiciones', N'Tipo_Documentos', N'view,view-menu,delete,new,update,CanExportToExcel', N'ADQ003', N'Adquisiciones'),
    (N'Adquisiciones', N'Tipo_Garantia', N'view,view-menu,delete,new,update,CanExportToExcel', N'ADQ004', N'Adquisiciones'),
    (N'Adquisiciones', N'Procedimientos_Contratacion', N'view,view-menu,delete,new,update,CanExportToExcel', N'ADQ005', N'Adquisiciones'),
    (N'Adquisiciones', N'Estatus_Requisicion', N'view,view-menu,delete,new,update,CanExportToExcel', N'ADQ006', N'Adquisiciones'),
    (N'Adquisiciones', N'Articulo', N'view,view-menu,delete,new,update,CanExportToExcel', N'ADQ008', N'Adquisiciones'),
    (N'Adquisiciones', N'Fraccion', N'view,view-menu,delete,new,update,CanExportToExcel', N'ADQ009', N'Adquisiciones'),
    (N'Adquisiciones', N'Programa_Anual_Adquisiciones', N'view,view-menu,delete,new,update', N'ADQPAA01', N'Adquisiciones'),
    (N'Adquisiciones', N'requisicion', N'view,view-menu,delete,new,update,CanExportToExcel,authorize', N'ADQREQ01', N'Adquisiciones'),
    (N'Adquisiciones', N'Cotizacion', N'view,view-menu,delete,new,update,CanExportToExcel,authorize', N'ADQCOT01', N'Adquisiciones'),
    (N'Adquisiciones', N'SolicitudSuficiencia', N'view,view-menu,delete,new,update,CanExportToExcel,authorize', N'ADQSUF01', N'Adquisiciones'),
    (N'Adquisiciones', N'OrdenCompra', N'view,view-menu,delete,new,update,CanExportToExcel,authorize', N'ADQORD01', N'Adquisiciones'),
    (N'Patrimonio', N'Grupo_Bien', N'view,view-menu,delete,new,update,CanExportToExcel', N'PAT002', N'Patrimonio'),
    (N'Patrimonio', N'Bienes_Servicios', N'view,view-menu,delete,new,update,CanExportToExcel', N'PAT003', N'Patrimonio'),
    (N'Patrimonio', N'Tipo_Patrimonio', N'view,view-menu,delete,new,update,CanExportToExcel', N'PAT004', N'Patrimonio'),
    (N'Patrimonio', N'Tipo_Adquisicion', N'view,view-menu,delete,new,update,CanExportToExcel', N'PAT005', N'Patrimonio'),
    (N'Patrimonio', N'Bienes', N'view,view-menu,delete,new,update,CanExportToExcel', N'PATBIEN001', N'Patrimonio'),
    (N'Patrimonio', N'Clasificacion_Bienes_Muebles', N'view,view-menu,delete,new,update,CanExportToExcel', N'PATBIEN002', N'Patrimonio'),
    (N'Patrimonio', N'Bajas', N'view,view-menu,delete,new,update,CanExportToExcel', N'PATBIEN003', N'Patrimonio'),
    (N'Patrimonio', N'Calendario_Inventarios', N'view,view-menu,delete,new,update,CanExportToExcel', N'PATBIEN004', N'Patrimonio'),
    (N'Patrimonio', N'Inventarios', N'view,view-menu,delete,new,update,CanExportToExcel', N'PATBIEN005', N'Patrimonio'),
    (N'Patrimonio', N'Cedula_Diferencia', N'view,view-menu,delete,new,update,CanExportToExcel', N'PATBIEN006', N'Patrimonio'),
    (N'Patrimonio', N'Resguardos', N'view,view-menu,delete,new,update,CanExportToExcel', N'PATBIEN007', N'Patrimonio'),
    (N'Patrimonio', N'Firma_Resguardos', N'view,view-menu,delete,new,update,CanExportToExcel', N'PATBIEN008', N'Patrimonio'),
    (N'Patrimonio', N'Resguardo_Historico', N'view,view-menu,delete,new,update,CanExportToExcel', N'PATBIEN009', N'Patrimonio'),
    (N'Almacen', N'Movimiento_Entrada_Salida', N'view,view-menu,delete,new,update,CanExportToExcel', N'ALCFG01', N'Almacén'),
    (N'Almacen', N'Estatus_Solicitud', N'view,view-menu,delete,new,update,CanExportToExcel', N'ALCFG02', N'Almacén'),
    (N'Almacen', N'Conteo_Periodo', N'view,view-menu,delete,new,update,CanExportToExcel', N'ALCFG04', N'Almacén'),
    (N'Almacen', N'Recepcion_Pedidos', N'view,view-menu', N'AL0001', N'Almacén'),
    (N'Almacen', N'Entradas_Ajuste', N'view,view-menu', N'AL0002', N'Almacén'),
    (N'Almacen', N'Salidas_Ajuste', N'view,view-menu,new,CanExportToExcel', N'AL0010', N'Almacén'),
    (N'Almacen', N'Solicitudes_Salida', N'view,view-menu', N'AL0003', N'Almacén'),
    (N'Almacen', N'Suministros_Salida', N'view,view-menu', N'AL0004', N'Almacén'),
    (N'Almacen', N'Existencias_Registradas', N'view,view-menu', N'AL0005', N'Almacén'),
    (N'Almacen', N'conteo_ciclico', N'view,view-menu', N'AL0006', N'Almacén'),
    (N'Almacen', N'Reporte_diferencias_Conteo', N'view,view-menu', N'AL0007', N'Almacén'),
    (N'Almacen', N'conteo_ciclico_anual', N'view,view-menu', N'AL0008', N'Almacén'),
    (N'Almacen', N'Reporte_diferencias_conteo_anual', N'view,view-menu', N'AL0009', N'Almacén'),
    (N'Tesoreria', N'Tipo_Cambio', N'view,view-menu,delete,new,update,CanExportToExcel', N'TES001', N'Tesorería'),
    (N'Tesoreria', N'Tipo_Inversion', N'view,view-menu,delete,new,update,CanExportToExcel', N'TES002', N'Tesorería'),
    (N'Tesoreria', N'Tipo_Moneda', N'view,view-menu,delete,new,update,CanExportToExcel', N'TES003', N'Tesorería'),
    (N'Tesoreria', N'Tipo_Pago', N'view,view-menu,delete,new,update,CanExportToExcel', N'TES004', N'Tesorería'),
    (N'Tesoreria', N'Tipo_PagoSF', N'view,view-menu,delete,new,update,CanExportToExcel', N'TES005', N'Tesorería'),
    (N'Tesoreria', N'Tipo_SolicitudCLC', N'view,view-menu,delete,new,update,CanExportToExcel', N'TES006', N'Tesorería'),
    (N'Tesoreria', N'Tipo_DoctoCLC', N'view,view-menu,delete,new,update,CanExportToExcel', N'TES007', N'Tesorería'),
    (N'Egreso', N'Presupuesto_Autorizado', N'view,view-menu,delete,new,update,CanExportToExcel,authorize', N'EGR001', N'Egreso'),
    (N'Planeacion', N'Anteproyecto_Egresos', N'view,view-menu,delete,new,update,CanExportToExcel,authorize', N'PLA001', N'Planeación'),
    (N'Presupuesto_Modificado', N'Adecuaciones_Compensadas', N'view,view-menu,CanExportToExcel,authorize', N'PM001', N'Presupuesto Modificado'),
    (N'Presupuesto_Modificado', N'Ampliaciones', N'view,view-menu,CanExportToExcel,authorize', N'PM002', N'Presupuesto Modificado'),
    (N'Presupuesto_Modificado', N'Reducciones', N'view,view-menu,CanExportToExcel,authorize', N'PM003', N'Presupuesto Modificado'),
    (N'Presupuesto_Comprometido', N'Solicitud_Suficiencia', N'view,view-menu,CanExportToExcel,authorize', N'PC001', N'Presupuesto Comprometido'),
    (N'Presupuesto_Comprometido', N'Autorizacion_Suficiencia', N'view,view-menu,delete,new,update,CanExportToExcel,authorize', N'PC002', N'Presupuesto Comprometido'),
    (N'Presupuesto_Comprometido', N'Registro_Comprometido', N'view,view-menu,delete,new,update,CanExportToExcel,authorize', N'PC003', N'Presupuesto Comprometido'),
    (N'CuentasXPagar', N'RecepcionFactura_ComprobantePago', N'view,view-menu,delete,new,update,CanExportToExcel,authorize', N'CXP001', N'Cuentas por pagar'),
    (N'CuentasXPagar', N'Provision_Pago', N'view,view-menu,delete,new,update,CanExportToExcel,authorize', N'CXP002', N'Cuentas por pagar'),
    (N'CuentasXPagar', N'ElaboracionCheque_Transferencia', N'view,view-menu,delete,new,update,CanExportToExcel,authorize', N'CXP003', N'Cuentas por pagar'),
    (N'Inversiones', N'Banco', N'view,view-menu,delete,new,update,CanExportToExcel', N'INV001', N'Inversiones'),
    (N'Inversiones', N'Cuenta_Bancaria', N'view,view-menu,delete,new,update,CanExportToExcel', N'INV002', N'Inversiones'),
    (N'Inversiones', N'Intermediarios_Financiero', N'view,view-menu,delete,new,update,CanExportToExcel', N'INV003', N'Inversiones'),
    (N'Inversiones', N'Instrumentos_Inversion', N'view,view-menu,delete,new,update,CanExportToExcel', N'INV004', N'Inversiones'),
    (N'Inversiones', N'Listado_Inversiones', N'view,view-menu,delete,new,update,CanExportToExcel', N'INV005', N'Inversiones'),
    (N'Inversiones', N'Tipo_Plazos', N'view,view-menu,delete,new,update,CanExportToExcel', N'INV006', N'Inversiones'),
    (N'Inversiones', N'Tipo_Retiro', N'view,view-menu,delete,new,update,CanExportToExcel', N'INV007', N'Inversiones');

DECLARE
    @Group NVARCHAR(100),
    @SubGroup NVARCHAR(100),
    @Values NVARCHAR(MAX),
    @Code NVARCHAR(10),
    @Description NVARCHAR(200),
    @BaseClaimId INT,
    @RoleClaimId INT;

DECLARE claim_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT [Group], SubGroup, [Values], Code, [Description]
FROM @ClaimFix;

OPEN claim_cursor;
FETCH NEXT FROM claim_cursor INTO @Group, @SubGroup, @Values, @Code, @Description;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @BaseClaimId = NULL;
    SET @RoleClaimId = NULL;

    SELECT @BaseClaimId = Id
    FROM dbo.AspNetClaims
    WHERE RoleId IS NULL
      AND [Group] = @Group
      AND SubGroup = @SubGroup;

    IF @BaseClaimId IS NULL
    BEGIN
        INSERT INTO dbo.AspNetClaims
        (
            ClaimTypeId, Name, [Group], RoleId, TokenFormat, Created,
            SubGroup, Code, [Description], [Values], ReferenceId
        )
        VALUES
        (
            2, @Group, @Group, NULL, N'app://{0}/{1}', GETDATE(),
            @SubGroup, @Code, @Description, @Values, 0
        );

        SET @BaseClaimId = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.AspNetClaims
        SET [Values] = @Values,
            Code = COALESCE(NULLIF(@Code, N''), Code),
            [Description] = COALESCE(@Description, [Description])
        WHERE Id = @BaseClaimId;
    END;

    SELECT @RoleClaimId = Id
    FROM dbo.AspNetClaims
    WHERE RoleId = @RoleId
      AND [Group] = @Group
      AND SubGroup = @SubGroup;

    IF @RoleClaimId IS NULL
    BEGIN
        INSERT INTO dbo.AspNetClaims
        (
            ClaimTypeId, Name, [Group], RoleId, TokenFormat, Created,
            SubGroup, Code, [Description], [Values], ReferenceId
        )
        VALUES
        (
            2, @Group, @Group, @RoleId, N'app://{0}/{1}', GETDATE(),
            @SubGroup, @Code, @Description, @Values, @BaseClaimId
        );

        SET @RoleClaimId = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.AspNetClaims
        SET [Values] = @Values,
            Code = COALESCE(NULLIF(@Code, N''), Code),
            [Description] = COALESCE(@Description, [Description]),
            ReferenceId = @BaseClaimId
        WHERE Id = @RoleClaimId;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.AspNetClaimValues
        WHERE ClaimId = @RoleClaimId
          AND Value = @Values
    )
    BEGIN
        INSERT INTO dbo.AspNetClaimValues (ClaimId, Value, Created)
        VALUES (@RoleClaimId, @Values, GETDATE());
    END;

    FETCH NEXT FROM claim_cursor INTO @Group, @SubGroup, @Values, @Code, @Description;
END;

CLOSE claim_cursor;
DEALLOCATE claim_cursor;

COMMIT TRANSACTION;

SELECT
    m.PKIdMenu,
    m.Nombre,
    m.Tipo,
    m.LegacyName,
    m.Ruta,
    HasRoleClaim = CASE WHEN EXISTS
    (
        SELECT 1
        FROM dbo.AspNetClaims AS c
        WHERE c.RoleId = @RoleId
          AND c.SubGroup = m.LegacyName
          AND c.[Values] LIKE '%view-menu%'
    ) THEN 1 ELSE 0 END
FROM SIS.Menu AS m
WHERE m.Activo = 1
  AND ISNULL(NULLIF(LTRIM(RTRIM(m.Ruta)), N''), N'/') <> N'/'
ORDER BY m.PKIdMenu;

SELECT
    PendientesTipo = COUNT(*)
FROM SIS.Menu AS m
WHERE m.Activo = 1
  AND ISNULL(NULLIF(LTRIM(RTRIM(m.Ruta)), N''), N'/') <> N'/'
  AND m.Tipo <> 2
  AND NOT EXISTS
  (
      SELECT 1
      FROM SIS.Menu AS child
      WHERE child.FKIdMenu_SIS = m.PKIdMenu
        AND child.Activo = 1
  );
GO
