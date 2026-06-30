SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'dbo.AspNetRoles', N'U') IS NULL
        THROW 51000, 'No existe dbo.AspNetRoles.', 1;

    IF OBJECT_ID(N'dbo.AspNetClaims', N'U') IS NULL
        THROW 51001, 'No existe dbo.AspNetClaims.', 1;

    DECLARE @Menu NVARCHAR(MAX) = N'view,view-menu';
    DECLARE @Read NVARCHAR(MAX) = N'view,view-menu,CanExportToExcel';
    DECLARE @Capture NVARCHAR(MAX) = N'view,view-menu,new,update,CanExportToExcel';
    DECLARE @Review NVARCHAR(MAX) = N'view,view-menu,update,CanExportToExcel';
    DECLARE @Auth NVARCHAR(MAX) = N'view,view-menu,update,CanExportToExcel,authorize';
    DECLARE @Full NVARCHAR(MAX) = N'view,view-menu,delete,new,update,CanExportToExcel';
    DECLARE @FullAuth NVARCHAR(MAX) = N'view,view-menu,delete,new,update,CanExportToExcel,authorize';

    DECLARE @Assignments TABLE
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        RoleCode NVARCHAR(10) NOT NULL,
        [Group] NVARCHAR(100) NOT NULL,
        SubGroup NVARCHAR(100) NOT NULL,
        [Values] NVARCHAR(MAX) NOT NULL
    );

    /* ============================================================
       PATRIMONIO 400xx
       ============================================================ */

    INSERT INTO @Assignments (RoleCode, [Group], SubGroup, [Values])
    VALUES
    (N'40010', N'Patrimonio', N'Patrimonio', @Menu),
    (N'40020', N'Patrimonio', N'Patrimonio', @Menu),
    (N'40030', N'Patrimonio', N'Patrimonio', @Menu),
    (N'40040', N'Patrimonio', N'Patrimonio', @Menu),
    (N'40050', N'Patrimonio', N'Patrimonio', @Menu),
    (N'40060', N'Patrimonio', N'Patrimonio', @Menu),
    (N'40070', N'Patrimonio', N'Patrimonio', @Menu),
    (N'40080', N'Patrimonio', N'Patrimonio', @Menu),

    (N'40010', N'Patrimonio', N'Bienes', @Full),
    (N'40010', N'Patrimonio', N'Clasificacion_Bienes_Muebles', @Full),
    (N'40010', N'Patrimonio', N'Bajas', @FullAuth),
    (N'40010', N'Patrimonio', N'Calendario_Inventarios', @Full),
    (N'40010', N'Patrimonio', N'Inventarios', @FullAuth),
    (N'40010', N'Patrimonio', N'Cedula_Diferencia', @Full),
    (N'40010', N'Patrimonio', N'Resguardos', @FullAuth),
    (N'40010', N'Patrimonio', N'Firma_Resguardos', @FullAuth),
    (N'40010', N'Patrimonio', N'Resguardo_Historico', @Read),

    (N'40020', N'Patrimonio', N'Bienes', @Capture),
    (N'40020', N'Patrimonio', N'Clasificacion_Bienes_Muebles', @Capture),
    (N'40020', N'Patrimonio', N'Resguardo_Historico', @Read),

    (N'40030', N'Patrimonio', N'Resguardos', @Capture),
    (N'40030', N'Patrimonio', N'Firma_Resguardos', @Capture),
    (N'40030', N'Patrimonio', N'Resguardo_Historico', @Read),

    (N'40040', N'Patrimonio', N'Calendario_Inventarios', @Capture),
    (N'40040', N'Patrimonio', N'Inventarios', @Capture),
    (N'40040', N'Patrimonio', N'Cedula_Diferencia', @Review),
    (N'40040', N'conteociclico', N'mis-periodos', @Capture),

    (N'40050', N'Patrimonio', N'Bajas', @Capture),
    (N'40050', N'Patrimonio', N'Bienes', @Read),
    (N'40050', N'Patrimonio', N'Resguardos', @Read),

    (N'40060', N'Patrimonio', N'Bajas', @Auth),
    (N'40060', N'Patrimonio', N'Inventarios', @Auth),
    (N'40060', N'Patrimonio', N'Resguardos', @Auth),
    (N'40060', N'Patrimonio', N'Firma_Resguardos', @Auth),

    (N'40070', N'Configuracion', N'Patrimonio', @Menu),
    (N'40070', N'Patrimonio', N'Familia', @Full),
    (N'40070', N'Patrimonio', N'Grupo_Bien', @Full),
    (N'40070', N'Patrimonio', N'Bienes_Servicios', @Full),
    (N'40070', N'Patrimonio', N'Tipo_Patrimonio', @Full),
    (N'40070', N'Patrimonio', N'Tipo_Adquisicion', @Full),
    (N'40070', N'Patrimonio', N'Marca', @Full),
    (N'40070', N'Patrimonio', N'Personas', @Full),

    (N'40080', N'Patrimonio', N'Bienes', @Read),
    (N'40080', N'Patrimonio', N'Clasificacion_Bienes_Muebles', @Read),
    (N'40080', N'Patrimonio', N'Bajas', @Read),
    (N'40080', N'Patrimonio', N'Calendario_Inventarios', @Read),
    (N'40080', N'Patrimonio', N'Inventarios', @Read),
    (N'40080', N'Patrimonio', N'Cedula_Diferencia', @Read),
    (N'40080', N'Patrimonio', N'Resguardos', @Read),
    (N'40080', N'Patrimonio', N'Firma_Resguardos', @Read),
    (N'40080', N'Patrimonio', N'Resguardo_Historico', @Read);

    /* ============================================================
       CONTABILIDAD 500xx
       ============================================================ */

    INSERT INTO @Assignments (RoleCode, [Group], SubGroup, [Values])
    VALUES
    (N'50010', N'Contabilidad', N'Contabilidad', @Menu),
    (N'50020', N'Contabilidad', N'Contabilidad', @Menu),
    (N'50030', N'Contabilidad', N'Contabilidad', @Menu),
    (N'50040', N'Contabilidad', N'Contabilidad', @Menu),
    (N'50050', N'Contabilidad', N'Contabilidad', @Menu),
    (N'50060', N'Contabilidad', N'Contabilidad', @Menu),
    (N'50070', N'Contabilidad', N'Contabilidad', @Menu),

    (N'50010', N'Contabilidad', N'Polizas', @FullAuth),
    (N'50010', N'Contabilidad', N'Autorizacion_Polizas', @FullAuth),
    (N'50010', N'Contabilidad', N'Balanza_Comprobacion', @Full),
    (N'50010', N'Contabilidad', N'Auxiliares', @Full),
    (N'50010', N'Contabilidad', N'Cierre_Mensual', @FullAuth),
    (N'50010', N'Contabilidad', N'Conciliacion_IE', @Full),
    (N'50010', N'Contabilidad', N'Reportes_Contabilidad', @Menu),
    (N'50010', N'Contabilidad', N'EI_Contable', @Menu),
    (N'50010', N'Contabilidad', N'EI_Presupuestarios', @Menu),
    (N'50010', N'Contabilidad', N'EI_Programaticos', @Read),
    (N'50010', N'Contabilidad', N'Indicadores_Postura_Fiscal', @Read),

    (N'50020', N'Contabilidad', N'Polizas', @Capture),
    (N'50020', N'Contabilidad', N'Balanza_Comprobacion', @Read),
    (N'50020', N'Contabilidad', N'Auxiliares', @Read),

    (N'50030', N'Contabilidad', N'Polizas', @Review),
    (N'50030', N'Contabilidad', N'Autorizacion_Polizas', @Review),
    (N'50030', N'Contabilidad', N'Balanza_Comprobacion', @Read),
    (N'50030', N'Contabilidad', N'Auxiliares', @Read),

    (N'50040', N'Contabilidad', N'Cierre_Mensual', @FullAuth),
    (N'50040', N'Contabilidad', N'Conciliacion_IE', @Full),
    (N'50040', N'Contabilidad', N'Polizas', @Read),

    (N'50050', N'Contabilidad', N'Autorizacion_Polizas', @Auth),
    (N'50050', N'Contabilidad', N'Cierre_Mensual', @Auth),
    (N'50050', N'Contabilidad', N'Polizas', @Read),

    (N'50060', N'Configuracion', N'Contabilidad', @Menu),
    (N'50060', N'Contabilidad', N'Tipo_Polizas', @Full),
    (N'50060', N'Contabilidad', N'Tipo_detalles_Polizas', @Full),
    (N'50060', N'Contabilidad', N'Matriz_Conversion', @Full),
    (N'50060', N'Contabilidad', N'Matriz_Conversion_Ingresos', @Full),
    (N'50060', N'Contabilidad', N'Partidas_Presupuestales', @Full),
    (N'50060', N'Contabilidad', N'Cuentas_Contables', @Full),
    (N'50060', N'Contabilidad', N'Formas_Pago', @Full),

    (N'50070', N'Contabilidad', N'Reportes_Contabilidad', @Menu),
    (N'50070', N'Reportes_Contabilidad', N'Libro_Diario', @Read),
    (N'50070', N'Reportes_Contabilidad', N'Libro_Mayor', @Read),
    (N'50070', N'Reportes_Contabilidad', N'Libro_Inventarios_Materiales', @Read),
    (N'50070', N'Reportes_Contabilidad', N'Libro_Almacen_Suministros', @Read),
    (N'50070', N'Reportes_Contabilidad', N'Libro_Inventarios_Muebles', @Read),
    (N'50070', N'Reportes_Contabilidad', N'Polizas', @Read),
    (N'50070', N'Reportes_Contabilidad', N'Reporte_Retenciones', @Read),
    (N'50070', N'Reportes_Contabilidad', N'Reporte_Depreciacion_Acumulada', @Read),
    (N'50070', N'Reportes_Contabilidad', N'Reporte_Activos_Fijos', @Read),
    (N'50070', N'Reportes_Contabilidad', N'Reporte_Facturas_Emitidas', @Read),
    (N'50070', N'Reportes_Contabilidad', N'Reporte_DIOT', @Read),
    (N'50070', N'Contabilidad', N'EI_Contable', @Menu),
    (N'50070', N'EI_Contable', N'Estados_Actividades', @Read),
    (N'50070', N'EI_Contable', N'Estado_Situacion_Financiera', @Read),
    (N'50070', N'EI_Contable', N'Estado_VHP', @Read),
    (N'50070', N'EI_Contable', N'Estados_CSF', @Read),
    (N'50070', N'EI_Contable', N'Estado_Flujos_Efectivo', @Read),
    (N'50070', N'EI_Contable', N'Estado_Analitico_Activo', @Read),
    (N'50070', N'EI_Contable', N'Estado_ADOP', @Read),
    (N'50070', N'EI_Contable', N'Informe_Pasivos_Contingentes', @Read),
    (N'50070', N'EI_Contable', N'Notas_Estados_Financieros', @Read),
    (N'50070', N'Contabilidad', N'EI_Presupuestarios', @Menu),
    (N'50070', N'EI_Presupuestarios', N'Estado_Analitico_Ingresos', @Read),
    (N'50070', N'EI_Presupuestarios', N'Estado_AECA', @Read),
    (N'50070', N'EI_Presupuestarios', N'Estado_AECE', @Read),
    (N'50070', N'EI_Presupuestarios', N'Estado_AECOG', @Read),
    (N'50070', N'EI_Presupuestarios', N'Estado_AECF', @Read),
    (N'50070', N'EI_Presupuestarios', N'Endeudamiento_Neto', @Read),
    (N'50070', N'EI_Presupuestarios', N'Intereses_Deuda', @Read),
    (N'50070', N'EI_Presupuestarios', N'Proyecciones_Egresos', @Read),
    (N'50070', N'EI_Presupuestarios', N'Proyecciones_Ingresos', @Read),
    (N'50070', N'EI_Presupuestarios', N'Indicadores_APP', @Read),
    (N'50070', N'EI_Presupuestarios', N'Pp_Inversion', @Read),
    (N'50070', N'EI_Presupuestarios', N'Resultados_Ingresos', @Read),
    (N'50070', N'EI_Presupuestarios', N'Resultados_Egresos', @Read);

    /* ============================================================
       ALMACEN 600xx
       ============================================================ */

    INSERT INTO @Assignments (RoleCode, [Group], SubGroup, [Values])
    VALUES
    (N'60010', N'Almacen', N'Almacen', @Menu),
    (N'60020', N'Almacen', N'Almacen', @Menu),
    (N'60030', N'Almacen', N'Almacen', @Menu),
    (N'60040', N'Almacen', N'Almacen', @Menu),
    (N'60050', N'Almacen', N'Almacen', @Menu),
    (N'60060', N'Almacen', N'Almacen', @Menu),
    (N'60070', N'Almacen', N'Almacen', @Menu),
    (N'60080', N'Almacen', N'Almacen', @Menu),

    (N'60010', N'Almacen', N'Recepcion_Pedidos', @FullAuth),
    (N'60010', N'Almacen', N'Entradas_Ajuste', @FullAuth),
    (N'60010', N'Almacen', N'Salidas_Ajuste', @FullAuth),
    (N'60010', N'Almacen', N'Solicitudes_Salida', @FullAuth),
    (N'60010', N'Almacen', N'Suministros_Salida', @FullAuth),
    (N'60010', N'Almacen', N'Existencias_Registradas', @Read),
    (N'60010', N'Almacen', N'conteo_ciclico', @Full),
    (N'60010', N'Almacen', N'Reporte_diferencias_Conteo', @Read),
    (N'60010', N'Almacen', N'conteo_ciclico_anual', @Full),
    (N'60010', N'Almacen', N'Reporte_diferencias_conteo_anual', @Read),

    (N'60020', N'Almacen', N'Solicitudes_Salida', @Capture),
    (N'60020', N'Almacen', N'Suministros_Salida', @Read),
    (N'60020', N'Almacen', N'Existencias_Registradas', @Read),

    (N'60030', N'Almacen', N'Recepcion_Pedidos', @Capture),
    (N'60030', N'Almacen', N'Entradas_Ajuste', @Capture),
    (N'60030', N'Almacen', N'Salidas_Ajuste', @Capture),
    (N'60030', N'Almacen', N'Suministros_Salida', @Capture),
    (N'60030', N'Almacen', N'Existencias_Registradas', @Read),

    (N'60040', N'Almacen', N'conteo_ciclico', @Capture),
    (N'60040', N'Almacen', N'conteo_ciclico_anual', @Capture),
    (N'60040', N'Almacen', N'Reporte_diferencias_Conteo', @Read),
    (N'60040', N'Almacen', N'Reporte_diferencias_conteo_anual', @Read),
    (N'60040', N'Almacen', N'Existencias_Registradas', @Read),

    (N'60050', N'Almacen', N'Recepcion_Pedidos', @Review),
    (N'60050', N'Almacen', N'Entradas_Ajuste', @Review),
    (N'60050', N'Almacen', N'Salidas_Ajuste', @Review),
    (N'60050', N'Almacen', N'Solicitudes_Salida', @Review),
    (N'60050', N'Almacen', N'Suministros_Salida', @Review),
    (N'60050', N'Almacen', N'Reporte_diferencias_Conteo', @Read),
    (N'60050', N'Almacen', N'Reporte_diferencias_conteo_anual', @Read),

    (N'60060', N'Almacen', N'Recepcion_Pedidos', @Auth),
    (N'60060', N'Almacen', N'Entradas_Ajuste', @Auth),
    (N'60060', N'Almacen', N'Salidas_Ajuste', @Auth),
    (N'60060', N'Almacen', N'Solicitudes_Salida', @Auth),
    (N'60060', N'Almacen', N'Suministros_Salida', @Auth),

    (N'60070', N'Configuracion', N'Almacen', @Menu),
    (N'60070', N'Almacen', N'Movimiento_Entrada_Salida', @Full),
    (N'60070', N'Almacen', N'Estatus_Solicitud', @Full),
    (N'60070', N'Almacen', N'Unidades', @Full),
    (N'60070', N'Almacen', N'Conteo_Periodo', @Full),
    (N'60070', N'Almacen', N'Familia', @Full),
    (N'60070', N'Almacen', N'Tipo_Bien', @Full),
    (N'60070', N'Almacen', N'Bien', @Full),
    (N'60070', N'Almacen', N'Numero_Conteo', @Full),

    (N'60080', N'Almacen', N'Recepcion_Pedidos', @Read),
    (N'60080', N'Almacen', N'Entradas_Ajuste', @Read),
    (N'60080', N'Almacen', N'Salidas_Ajuste', @Read),
    (N'60080', N'Almacen', N'Solicitudes_Salida', @Read),
    (N'60080', N'Almacen', N'Suministros_Salida', @Read),
    (N'60080', N'Almacen', N'Existencias_Registradas', @Read),
    (N'60080', N'Almacen', N'conteo_ciclico', @Read),
    (N'60080', N'Almacen', N'Reporte_diferencias_Conteo', @Read),
    (N'60080', N'Almacen', N'conteo_ciclico_anual', @Read),
    (N'60080', N'Almacen', N'Reporte_diferencias_conteo_anual', @Read);

    /* ============================================================
       ADQUISICIONES 700xx
       ============================================================ */

    INSERT INTO @Assignments (RoleCode, [Group], SubGroup, [Values])
    VALUES
    (N'70010', N'Adquisiciones', N'Adquisiciones', @Menu),
    (N'70020', N'Adquisiciones', N'Adquisiciones', @Menu),
    (N'70030', N'Adquisiciones', N'Adquisiciones', @Menu),
    (N'70040', N'Adquisiciones', N'Adquisiciones', @Menu),
    (N'70050', N'Adquisiciones', N'Adquisiciones', @Menu),
    (N'70060', N'Adquisiciones', N'Adquisiciones', @Menu),
    (N'70070', N'Adquisiciones', N'Adquisiciones', @Menu),
    (N'70080', N'Adquisiciones', N'Adquisiciones', @Menu),

    (N'70010', N'Adquisiciones', N'Programa_Anual_Adquisiciones', @FullAuth),
    (N'70010', N'Adquisiciones', N'requisicion', @FullAuth),
    (N'70010', N'Adquisiciones', N'Requisicion', @FullAuth),
    (N'70010', N'Adquisiciones', N'Cotizacion', @FullAuth),
    (N'70010', N'Adquisiciones', N'SolicitudSuficiencia', @FullAuth),
    (N'70010', N'Adquisiciones', N'OrdenCompra', @FullAuth),
    (N'70010', N'Adquisiciones', N'Contratos', @Menu),
    (N'70010', N'Contratos', N'Contratos', @Menu),
    (N'70010', N'Contratos', N'Registro_Compromiso', @Full),
    (N'70010', N'Contratos', N'Saldos_Contratos', @Read),
    (N'70010', N'Contratos', N'Estado_Contrato', @Full),

    (N'70020', N'Adquisiciones', N'requisicion', @Capture),
    (N'70020', N'Adquisiciones', N'Requisicion', @Capture),
    (N'70020', N'Adquisiciones', N'SolicitudSuficiencia', @Capture),
    (N'70020', N'Adquisiciones', N'Programa_Anual_Adquisiciones', @Read),

    (N'70030', N'Adquisiciones', N'Cotizacion', @Capture),
    (N'70030', N'Adquisiciones', N'OrdenCompra', @Capture),
    (N'70030', N'Adquisiciones', N'requisicion', @Read),
    (N'70030', N'Adquisiciones', N'Requisicion', @Read),
    (N'70030', N'Adquisiciones', N'SolicitudSuficiencia', @Read),

    (N'70040', N'Adquisiciones', N'Contratos', @Menu),
    (N'70040', N'Contratos', N'Contratos', @Menu),
    (N'70040', N'Contratos', N'Registro_Compromiso', @Capture),
    (N'70040', N'Contratos', N'Saldos_Contratos', @Read),
    (N'70040', N'Contratos', N'Estado_Contrato', @Capture),
    (N'70040', N'Adquisiciones', N'OrdenCompra', @Read),

    (N'70050', N'Adquisiciones', N'Programa_Anual_Adquisiciones', @Review),
    (N'70050', N'Adquisiciones', N'requisicion', @Review),
    (N'70050', N'Adquisiciones', N'Requisicion', @Review),
    (N'70050', N'Adquisiciones', N'Cotizacion', @Review),
    (N'70050', N'Adquisiciones', N'SolicitudSuficiencia', @Review),
    (N'70050', N'Adquisiciones', N'OrdenCompra', @Review),

    (N'70060', N'Adquisiciones', N'Programa_Anual_Adquisiciones', @Auth),
    (N'70060', N'Adquisiciones', N'requisicion', @Auth),
    (N'70060', N'Adquisiciones', N'Requisicion', @Auth),
    (N'70060', N'Adquisiciones', N'Cotizacion', @Auth),
    (N'70060', N'Adquisiciones', N'SolicitudSuficiencia', @Auth),
    (N'70060', N'Adquisiciones', N'OrdenCompra', @Auth),

    (N'70070', N'Configuracion', N'Adquisiciones', @Menu),
    (N'70070', N'Adquisiciones', N'Modalidad', @Full),
    (N'70070', N'Adquisiciones', N'Tipo_Contrato', @Full),
    (N'70070', N'Adquisiciones', N'Tipo_Documentos', @Full),
    (N'70070', N'Adquisiciones', N'Tipo_Garantia', @Full),
    (N'70070', N'Adquisiciones', N'Procedimientos_Contratacion', @Full),
    (N'70070', N'Adquisiciones', N'Estatus_Requisicion', @Full),
    (N'70070', N'Adquisiciones', N'Proveedores', @Full),
    (N'70070', N'Adquisiciones', N'Articulo', @Full),
    (N'70070', N'Adquisiciones', N'Fraccion', @Full),

    (N'70080', N'Adquisiciones', N'Programa_Anual_Adquisiciones', @Read),
    (N'70080', N'Adquisiciones', N'requisicion', @Read),
    (N'70080', N'Adquisiciones', N'Requisicion', @Read),
    (N'70080', N'Adquisiciones', N'Cotizacion', @Read),
    (N'70080', N'Adquisiciones', N'SolicitudSuficiencia', @Read),
    (N'70080', N'Adquisiciones', N'OrdenCompra', @Read),
    (N'70080', N'Contratos', N'Registro_Compromiso', @Read),
    (N'70080', N'Contratos', N'Saldos_Contratos', @Read),
    (N'70080', N'Contratos', N'Estado_Contrato', @Read);

    /* ============================================================
       NOMINA 800xx
       ============================================================ */

    INSERT INTO @Assignments (RoleCode, [Group], SubGroup, [Values])
    VALUES
    (N'80010', N'Nomina', N'Nomina', @Menu),
    (N'80020', N'Nomina', N'Nomina', @Menu),
    (N'80030', N'Nomina', N'Nomina', @Menu),
    (N'80040', N'Nomina', N'Nomina', @Menu),
    (N'80050', N'Nomina', N'Nomina', @Menu),
    (N'80060', N'Nomina', N'Nomina', @Menu),
    (N'80070', N'Nomina', N'Nomina', @Menu),
    (N'80080', N'Nomina', N'Nomina', @Menu),
    (N'80090', N'Nomina', N'Nomina', @Menu),
    (N'80100', N'Nomina', N'Nomina', @Menu),

    (N'80010', N'Nomina', N'Recursos_Humanos', @Menu),
    (N'80010', N'Nomina', N'Empleados', @Full),
    (N'80010', N'Recursos_Humanos', N'Empleados', @Full),
    (N'80010', N'Nomina', N'Movimientos_Personal', @Read),
    (N'80010', N'Nomina', N'De_Personal', @Full),
    (N'80010', N'Nomina', N'Creditos_Trabajadores', @Full),
    (N'80010', N'Nomina', N'Nomina_Calculo', @FullAuth),
    (N'80010', N'Calculo', N'Calculo_2050', @FullAuth),
    (N'80010', N'Incidencias', N'Captura_Incidencias', @Full),
    (N'80010', N'Incidencias', N'Justificacion_Incidencias', @Full),
    (N'80010', N'Productos', N'Recibos', @Full),
    (N'80010', N'Productos', N'Archivos_Dispersion', @Full),
    (N'80010', N'Productos', N'Archivos_Timbrado', @Full),
    (N'80010', N'Vacaciones', N'Solicitud_Vacaciones', @Full),
    (N'80010', N'Vacaciones', N'Autorizacion_Vacaciones', @FullAuth),
    (N'80010', N'Cierre_Periodo', N'Cierre_Periodo', @FullAuth),
    (N'80010', N'Nominas_Especiales', N'Calc_Aguinaldo', @FullAuth),

    (N'80020', N'Nomina', N'Recursos_Humanos', @Menu),
    (N'80020', N'Nomina', N'Empleados', @Full),
    (N'80020', N'Recursos_Humanos', N'Empleados', @Full),
    (N'80020', N'Nomina', N'Movimientos_Personal', @Read),
    (N'80020', N'Nomina', N'De_Personal', @Full),
    (N'80020', N'Nomina', N'Reporte Quincenal MP', @Read),
    (N'80020', N'Nomina', N'Creditos_Trabajadores', @Full),

    (N'80030', N'Nomina', N'Nomina_Incidencias', @Menu),
    (N'80030', N'Incidencias', N'Captura_Incidencias', @Full),
    (N'80030', N'Incidencias', N'Justificacion_Incidencias', @Full),
    (N'80030', N'Incidencias', N'Reporte_Incidencias', @Read),
    (N'80030', N'Pagos_Extraordinarios', N'Conceptos_Variables', @Full),

    (N'80040', N'Nomina', N'Nomina_Calculo', @FullAuth),
    (N'80040', N'Nomina', N'Nomina_Auxiliares', @Menu),
    (N'80040', N'Nomina', N'Infonavit', @Full),
    (N'80040', N'Nomina', N'Procesos', @FullAuth),
    (N'80040', N'Calculo', N'Calculo_2050', @FullAuth),
    (N'80040', N'Auxiliares', N'Auxiliares', @Menu),
    (N'80040', N'Auxiliares', N'Calculo_ISSSTE_4134', @Full),
    (N'80040', N'Auxiliares', N'Calculo_ISR_2053', @Full),
    (N'80040', N'Auxiliares', N'Calculo_FOVISSSTE_4136', @Full),
    (N'80040', N'Auxiliares', N'Calculo_Infonavit_139', @Full),
    (N'80040', N'Auxiliares', N'Calculo_IMSS_3084', @Full),

    (N'80050', N'Nomina', N'Nomina_Productos', @Menu),
    (N'80050', N'Productos', N'Resumen', @Read),
    (N'80050', N'Productos', N'Recibos', @Full),
    (N'80050', N'Productos', N'Archivos_Dispersion', @Full),
    (N'80050', N'Productos', N'Archivos_Timbrado', @Full),
    (N'80050', N'Productos', N'Reporte_Cuotas_IMSS', @Read),
    (N'80050', N'Productos', N'Reporte_Nomina', @Read),
    (N'80050', N'Productos', N'Reporte_ISR', @Read),
    (N'80050', N'Productos', N'Editar_Reg_Quincenal', @Full),
    (N'80050', N'Productos', N'Editar_Reg_Mensual', @Full),

    (N'80060', N'Nomina', N'Nomina_Vacaciones', @Menu),
    (N'80060', N'Nomina', N'Vacaciones', @Menu),
    (N'80060', N'Vacaciones', N'Solicitud_Vacaciones', @Capture),
    (N'80060', N'Nomina_Vacaciones', N'Solicitud_Vacaciones', @Capture),

    (N'80070', N'Nomina', N'Nomina_Vacaciones', @Menu),
    (N'80070', N'Nomina', N'Vacaciones', @Menu),
    (N'80070', N'Vacaciones', N'Solicitud_Vacaciones', @Read),
    (N'80070', N'Vacaciones', N'Autorizacion_Vacaciones', @Auth),
    (N'80070', N'Nomina_Vacaciones', N'Autorizacion_Vacaciones', @Auth),

    (N'80080', N'Cierre_Periodo', N'Cierre_Periodo', @FullAuth),
    (N'80080', N'Nominas_Especiales', N'Calc_Aguinaldo', @FullAuth),
    (N'80080', N'Nominas_Especiales', N'Aguinaldo', @Read),
    (N'80080', N'Calculo', N'Calculo_2050', @Auth),

    (N'80090', N'Configuracion_Nominas', N'Configuracion_Nominas', @Menu),
    (N'80090', N'Configuracion_Nominas', N'Nomina_Catalogos', @Menu),
    (N'80090', N'Configuracion_Nominas', N'Nomina_Periodos', @Menu),
    (N'80090', N'Configuracion_Nominas', N'Nomina_Tablas_ISR', @Menu),
    (N'80090', N'Configuracion_Nominas', N'Nomina_Subsidios_ISR', @Menu),
    (N'80090', N'Configuracion_Nominas', N'Nomina_IMSS', @Menu),
    (N'80090', N'Catalogos', N'Tipo_Nomina', @Full),
    (N'80090', N'Catalogos', N'Cuotas_IMSS', @Full),
    (N'80090', N'Catalogos', N'Conceptos_Nomina', @Full),
    (N'80090', N'Catalogos', N'UMA', @Full),
    (N'80090', N'Catalogos', N'Tipo_Contratacion', @Full),
    (N'80090', N'Catalogos', N'Tipo_Descanso', @Full),
    (N'80090', N'Catalogos', N'Tipo_Incidencia', @Full),
    (N'80090', N'Catalogos', N'Concepto_Fijo', @Full),
    (N'80090', N'Catalogos', N'Tipo_Justificacion', @Full),
    (N'80090', N'Catalogos', N'Tabulador', @Full),
    (N'80090', N'Catalogos', N'Unidad_Infonavit', @Full),
    (N'80090', N'Catalogos', N'Salario_Minimo', @Full),
    (N'80090', N'Catalogos', N'Forma_Pago', @Full),
    (N'80090', N'Catalogos', N'Forma_Calculo', @Full),
    (N'80090', N'Catalogos', N'Capitulos', @Full),
    (N'80090', N'Periodos', N'Periodo_Semanal', @Full),
    (N'80090', N'Periodos', N'Periodo_Quincenal', @Full),
    (N'80090', N'Periodos', N'Periodo_Mensual', @Full),
    (N'80090', N'Periodos', N'Periodo_Bimestral', @Full),
    (N'80090', N'Tablas_ISR', N'Tabla_ISR_Semanal', @Full),
    (N'80090', N'Tablas_ISR', N'Tabla_ISR_Quincenal', @Full),
    (N'80090', N'Tablas_ISR', N'Tabla_ISR_Mensual', @Full),
    (N'80090', N'Prestaciones', N'Prestaciones', @Full),
    (N'80090', N'Subsidios_ISR', N'Subsidio_ISR_Semanal', @Full),
    (N'80090', N'Subsidios_ISR', N'Subsidio_ISR_Quincenal', @Full),
    (N'80090', N'Subsidios_ISR', N'Subsidio_ISR_Mensual', @Full),
    (N'80090', N'Impuestos', N'Base_Gravable', @Full),
    (N'80090', N'Impuestos', N'Impuestos_Locales', @Full),
    (N'80090', N'IMSS', N'Prestaciones_Minimas', @Full),
    (N'80090', N'IMSS', N'Clase_IMSS', @Full),
    (N'80090', N'IMSS', N'Fraccion_IMSS', @Full),
    (N'80090', N'IMSS', N'Base_Gravable_IMSS', @Full),
    (N'80090', N'Contratos', N'Contratos', @Menu),
    (N'80090', N'Contratos', N'Base_Pago', @Full),
    (N'80090', N'Contratos', N'Metodo_Pago', @Full),
    (N'80090', N'Contratos', N'Tipo_Regimen', @Full),
    (N'80090', N'Contratos', N'Base_Cotizacion', @Full),
    (N'80090', N'Contratos', N'Zona_Geografica', @Full),
    (N'80090', N'Contratos', N'Dia_Semana', @Full),
    (N'80090', N'Configuracion_RH', N'Configuracion_RH', @Menu),
    (N'80090', N'Plazas_Autorizadas', N'Plazas_Autorizadas', @Full),
    (N'80090', N'Universo', N'Universo', @Full),
    (N'80090', N'Nivel', N'Nivel', @Full),
    (N'80090', N'Sexo', N'Sexo', @Full),
    (N'80090', N'Estado_Civil', N'Estado_Civil', @Full),
    (N'80090', N'Escolaridad', N'Escolaridad', @Full),
    (N'80090', N'Tipo_Parentesco', N'Tipo_Parentesco', @Full),
    (N'80090', N'Estado', N'Estado', @Full),
    (N'80090', N'Banco', N'Banco', @Full),
    (N'80090', N'Municipio', N'Municipio', @Full),
    (N'80090', N'Tipo_Sangre', N'Tipo_Sangre', @Full),
    (N'80090', N'Profesion', N'Profesion', @Full),
    (N'80090', N'Regimen_Fiscal', N'Regimen_Fiscal', @Full),
    (N'80090', N'Pais', N'Pais', @Full),
    (N'80090', N'Periodo_Pago', N'Periodo_Pago', @Full),
    (N'80090', N'Tipo_Documento_RH', N'Tipo_Documento_RH', @Full),
    (N'80090', N'Tipo_Expediente', N'Tipo_Expediente', @Full),
    (N'80090', N'Opcion_Jubilacion', N'Opcion_Jubilacion', @Full),
    (N'80090', N'Situacion_Persona', N'Situacion_Persona', @Full),
    (N'80090', N'Situacion_Plaza', N'Situacion_Plaza', @Full),
    (N'80090', N'Situacion_Movimiento', N'Situacion_Movimiento', @Full),
    (N'80090', N'Clase_Movimiento', N'Clase_Movimiento', @Full),
    (N'80090', N'Movimiento_RH', N'Movimiento_RH', @Full),

    (N'80100', N'Historicos', N'Historicos_Nomina', @Menu),
    (N'80100', N'Nomina_Historicos', N'Nomina_Productos_Historicos', @Menu),
    (N'80100', N'Nomina_Historicos', N'Reportes_IMSS_Historicos', @Menu),
    (N'80100', N'Nomina_Historicos', N'Reportes_SAT_Historicos', @Menu),
    (N'80100', N'Productos_Historicos', N'Consulta_Nomina', @Read),
    (N'80100', N'Productos_Historicos', N'Analisis', @Read),
    (N'80100', N'Productos_Historicos', N'Recibos_Historicos', @Read),
    (N'80100', N'Productos_Historicos', N'Archivos_Dispersion_Historicos', @Read),
    (N'80100', N'Productos_Historicos', N'Archivos_Timbrado_Historicos', @Read),
    (N'80100', N'Productos_Historicos', N'Reporte_Nomina_Quincenal', @Read),
    (N'80100', N'Productos_Historicos', N'Resumen_Nomina_Historica', @Read),
    (N'80100', N'Productos_Historicos', N'Reporte_Nomina_Historica', @Read),
    (N'80100', N'Productos_Historicos', N'Cubo_Nomina_Historica', @Read),
    (N'80100', N'Reportes_IMSS_Historicos', N'Salario_Base_Cotizacion', @Read),
    (N'80100', N'Reportes_IMSS_Historicos', N'Acumulados_IMSS', @Read),
    (N'80100', N'Reportes_IMSS_Historicos', N'SBC_Historico', @Read),
    (N'80100', N'Reportes_IMSS_Historicos', N'Acumulados_Bimestre_IMSS', @Read),
    (N'80100', N'Reportes_SAT_Historicos', N'Acumulado_Mensual_ISR', @Read),
    (N'80100', N'Reportes_SAT_Historicos', N'Acumulados_ISR', @Read),
    (N'80100', N'Impuestos_Locales_Historicos', N'Impuestos_Locales', @Read);

    /* ============================================================
       PBR 900xx
       ============================================================ */

    INSERT INTO @Assignments (RoleCode, [Group], SubGroup, [Values])
    VALUES
    (N'90010', N'PBR', N'PBR', @Menu),
    (N'90020', N'PBR', N'PBR', @Menu),
    (N'90030', N'PBR', N'PBR', @Menu),
    (N'90040', N'PBR', N'PBR', @Menu),
    (N'90050', N'PBR', N'PBR', @Menu),
    (N'90060', N'PBR', N'PBR', @Menu),
    (N'90070', N'PBR', N'PBR', @Menu),

    (N'90010', N'PBR', N'MiTablero', @Read),
    (N'90010', N'PBR', N'MapaProcesos', @Read),
    (N'90010', N'PBR', N'Anteproyectos', @FullAuth),
    (N'90010', N'PBR', N'Presupuestos', @FullAuth),
    (N'90010', N'PBR', N'MatrizIndicadores', @Full),
    (N'90010', N'PBR', N'MIR', @Full),

    (N'90020', N'PBR', N'MiTablero', @Read),
    (N'90020', N'PBR', N'MapaProcesos', @Read),
    (N'90020', N'PBR', N'Anteproyectos', @Capture),
    (N'90020', N'PBR', N'Presupuestos', @Read),

    (N'90030', N'PBR', N'MatrizIndicadores', @Full),
    (N'90030', N'PBR', N'MIR', @Full),
    (N'90030', N'PBR', N'MiTablero', @Read),

    (N'90040', N'PBR', N'MiTablero', @Read),
    (N'90040', N'PBR', N'MapaProcesos', @Read),
    (N'90040', N'PBR', N'Anteproyectos', @Review),
    (N'90040', N'PBR', N'Presupuestos', @Review),
    (N'90040', N'PBR', N'MatrizIndicadores', @Review),
    (N'90040', N'PBR', N'MIR', @Review),

    (N'90050', N'PBR', N'Anteproyectos', @Auth),
    (N'90050', N'PBR', N'Presupuestos', @Auth),
    (N'90050', N'PBR', N'MatrizIndicadores', @Review),
    (N'90050', N'PBR', N'MIR', @Review),

    (N'90060', N'Catalogos_presupuestales', N'Programas_Presupuestales', @Full),
    (N'90060', N'ClavePrograma', N'UnidadResponsable', @Full),
    (N'90060', N'ClavePrograma', N'Funcion', @Full),
    (N'90060', N'ClavePrograma', N'Actividad_Institucional', @Full),
    (N'90060', N'ClavePrograma', N'Programa_Presupuestal', @Full),
    (N'90060', N'ClavePrograma', N'Anios', @Full),
    (N'90060', N'ClavePrograma', N'TipoRecurso', @Full),
    (N'90060', N'ClavePrograma', N'Fuente_Financiamiento', @Full),

    (N'90070', N'PBR', N'MiTablero', @Read),
    (N'90070', N'PBR', N'MapaProcesos', @Read),
    (N'90070', N'PBR', N'Anteproyectos', @Read),
    (N'90070', N'PBR', N'Presupuestos', @Read),
    (N'90070', N'PBR', N'MatrizIndicadores', @Read),
    (N'90070', N'PBR', N'MIR', @Read);

    /* ============================================================
       PRESUPUESTO 910xx
       ============================================================ */

    INSERT INTO @Assignments (RoleCode, [Group], SubGroup, [Values])
    VALUES
    (N'91010', N'Presupuesto', N'Presupuesto', @Menu),
    (N'91020', N'Presupuesto', N'Presupuesto', @Menu),
    (N'91030', N'Presupuesto', N'Presupuesto', @Menu),
    (N'91040', N'Presupuesto', N'Presupuesto', @Menu),
    (N'91050', N'Presupuesto', N'Presupuesto', @Menu),
    (N'91060', N'Presupuesto', N'Presupuesto', @Menu),
    (N'91070', N'Presupuesto', N'Presupuesto', @Menu),
    (N'91080', N'Presupuesto', N'Presupuesto', @Menu),
    (N'91090', N'Presupuesto', N'Presupuesto', @Menu),

    (N'91010', N'Presupuesto', N'Egreso', @Menu),
    (N'91010', N'Egreso', N'Planeacion', @Menu),
    (N'91010', N'Egreso', N'Catalogos_Planeacion', @Menu),
    (N'91010', N'Planeacion', N'Anteproyecto_Egresos', @FullAuth),
    (N'91010', N'Egreso', N'Presupuesto_Autorizado', @FullAuth),
    (N'91010', N'Egreso', N'Presupuesto_Disponible', @Read),
    (N'91010', N'Egreso', N'Presupuesto_Modificado', @Menu),
    (N'91010', N'Presupuesto_Modificado', N'Adecuaciones_Compensadas', @FullAuth),
    (N'91010', N'Presupuesto_Modificado', N'Ampliaciones', @FullAuth),
    (N'91010', N'Presupuesto_Modificado', N'Reducciones', @FullAuth),
    (N'91010', N'Presupuesto_Modificado', N'Aumento_Presupuesto', @FullAuth),
    (N'91010', N'Presupuesto_Modificado', N'Reduccion_Presupuesto', @FullAuth),
    (N'91010', N'Egreso', N'Presupuesto_Comprometido', @Menu),
    (N'91010', N'Presupuesto_Comprometido', N'Solicitud_Suficiencia', @FullAuth),
    (N'91010', N'Presupuesto_Comprometido', N'Autorizacion_Suficiencia', @FullAuth),
    (N'91010', N'Presupuesto_Comprometido', N'Registro_Comprometido', @FullAuth),

    (N'91020', N'Presupuesto', N'Egreso', @Menu),
    (N'91020', N'Egreso', N'Planeacion', @Menu),
    (N'91020', N'Egreso', N'Catalogos_Planeacion', @Menu),
    (N'91020', N'Planeacion', N'Anteproyecto_Egresos', @Capture),

    (N'91030', N'Presupuesto', N'Egreso', @Menu),
    (N'91030', N'Egreso', N'Presupuesto_Autorizado', @Capture),
    (N'91030', N'Egreso', N'Presupuesto_Disponible', @Read),

    (N'91040', N'Presupuesto', N'Egreso', @Menu),
    (N'91040', N'Egreso', N'Presupuesto_Modificado', @Menu),
    (N'91040', N'Presupuesto_Modificado', N'Adecuaciones_Compensadas', @Capture),
    (N'91040', N'Presupuesto_Modificado', N'Ampliaciones', @Capture),
    (N'91040', N'Presupuesto_Modificado', N'Reducciones', @Capture),
    (N'91040', N'Presupuesto_Modificado', N'Aumento_Presupuesto', @Capture),
    (N'91040', N'Presupuesto_Modificado', N'Reduccion_Presupuesto', @Capture),

    (N'91050', N'Presupuesto', N'Egreso', @Menu),
    (N'91050', N'Egreso', N'Presupuesto_Modificado', @Menu),
    (N'91050', N'Presupuesto_Modificado', N'Adecuaciones_Compensadas', @Review),
    (N'91050', N'Presupuesto_Modificado', N'Ampliaciones', @Review),
    (N'91050', N'Presupuesto_Modificado', N'Reducciones', @Review),
    (N'91050', N'Presupuesto_Modificado', N'Aumento_Presupuesto', @Review),
    (N'91050', N'Presupuesto_Modificado', N'Reduccion_Presupuesto', @Review),

    (N'91060', N'Presupuesto', N'Egreso', @Menu),
    (N'91060', N'Egreso', N'Presupuesto_Modificado', @Menu),
    (N'91060', N'Presupuesto_Modificado', N'Adecuaciones_Compensadas', @Auth),
    (N'91060', N'Presupuesto_Modificado', N'Ampliaciones', @Auth),
    (N'91060', N'Presupuesto_Modificado', N'Reducciones', @Auth),
    (N'91060', N'Presupuesto_Modificado', N'Aumento_Presupuesto', @Auth),
    (N'91060', N'Presupuesto_Modificado', N'Reduccion_Presupuesto', @Auth),

    (N'91070', N'Presupuesto', N'Egreso', @Menu),
    (N'91070', N'Egreso', N'Presupuesto_Comprometido', @Menu),
    (N'91070', N'Presupuesto_Comprometido', N'Solicitud_Suficiencia', @Capture),
    (N'91070', N'Presupuesto_Comprometido', N'Autorizacion_Suficiencia', @Auth),
    (N'91070', N'Presupuesto_Comprometido', N'Registro_Comprometido', @Capture),

    (N'91080', N'Catalogos_presupuestales', N'Programas_Presupuestales', @Full),
    (N'91080', N'ClavePrograma', N'UnidadResponsable', @Full),
    (N'91080', N'ClavePrograma', N'Funcion', @Full),
    (N'91080', N'ClavePrograma', N'Actividad_Institucional', @Full),
    (N'91080', N'ClavePrograma', N'Programa_Presupuestal', @Full),
    (N'91080', N'ClavePrograma', N'Anios', @Full),
    (N'91080', N'ClavePrograma', N'TipoRecurso', @Full),
    (N'91080', N'ClavePrograma', N'Fuente_Financiamiento', @Full),

    (N'91090', N'Presupuesto', N'Egreso', @Menu),
    (N'91090', N'Egreso', N'Planeacion', @Menu),
    (N'91090', N'Planeacion', N'Anteproyecto_Egresos', @Read),
    (N'91090', N'Egreso', N'Presupuesto_Autorizado', @Read),
    (N'91090', N'Egreso', N'Presupuesto_Disponible', @Read),
    (N'91090', N'Egreso', N'Presupuesto_Modificado', @Menu),
    (N'91090', N'Presupuesto_Modificado', N'Adecuaciones_Compensadas', @Read),
    (N'91090', N'Presupuesto_Modificado', N'Ampliaciones', @Read),
    (N'91090', N'Presupuesto_Modificado', N'Reducciones', @Read),
    (N'91090', N'Egreso', N'Presupuesto_Comprometido', @Menu),
    (N'91090', N'Presupuesto_Comprometido', N'Solicitud_Suficiencia', @Read),
    (N'91090', N'Presupuesto_Comprometido', N'Autorizacion_Suficiencia', @Read),
    (N'91090', N'Presupuesto_Comprometido', N'Registro_Comprometido', @Read);

    /* ============================================================
       TESORERIA 920xx
       ============================================================ */

    INSERT INTO @Assignments (RoleCode, [Group], SubGroup, [Values])
    VALUES
    (N'92010', N'Presupuesto', N'Tesoreria', @Menu),
    (N'92020', N'Presupuesto', N'Tesoreria', @Menu),
    (N'92030', N'Presupuesto', N'Tesoreria', @Menu),
    (N'92040', N'Presupuesto', N'Tesoreria', @Menu),
    (N'92050', N'Presupuesto', N'Tesoreria', @Menu),
    (N'92060', N'Presupuesto', N'Tesoreria', @Menu),
    (N'92070', N'Presupuesto', N'Tesoreria', @Menu),
    (N'92080', N'Presupuesto', N'Tesoreria', @Menu),

    (N'92010', N'Tesoreria', N'CuentasXPagar', @Menu),
    (N'92010', N'CuentasXPagar', N'PEF_Unipartida_TES', @Menu),
    (N'92010', N'PEF_Unipartida_TES', N'RecepcionFactura_ComprobantePago', @FullAuth),
    (N'92010', N'PEF_Unipartida_TES', N'Provision_Pago', @FullAuth),
    (N'92010', N'PEF_Unipartida_TES', N'ElaboracionCheque_Transferencia', @FullAuth),
    (N'92010', N'CuentasXPagar', N'RecepcionFactura_ComprobantePago', @FullAuth),
    (N'92010', N'CuentasXPagar', N'Provision_Pago', @FullAuth),
    (N'92010', N'CuentasXPagar', N'ElaboracionCheque_Transferencia', @FullAuth),
    (N'92010', N'Tesoreria', N'CuentasXCobrar', @Menu),
    (N'92010', N'CuentasXCobrar', N'Ley_Ingresos_Estimados', @FullAuth),
    (N'92010', N'CuentasXCobrar', N'Ingresos_Devengados', @Menu),
    (N'92010', N'Ingresos_Devengados', N'Ingresos', @FullAuth),
    (N'92010', N'Ingresos_Devengados', N'Ingresos_Propios', @FullAuth),
    (N'92010', N'CuentasXCobrar', N'Ingresos_Recaudar', @FullAuth),
    (N'92010', N'CuentasXCobrar', N'Depositos_CLC', @FullAuth),
    (N'92010', N'CuentasXCobrar', N'Otros_Ingresos', @FullAuth),
    (N'92010', N'CuentasXCobrar', N'Reportes_CxC', @Menu),
    (N'92010', N'Tesoreria', N'Planeacion_Gastos', @Full),
    (N'92010', N'Tesoreria', N'Saldos_Cuentas', @Read),
    (N'92010', N'Tesoreria', N'Solicitud_Reintegros', @Full),
    (N'92010', N'Tesoreria', N'Autorizar_Solicitud_Reingresos', @FullAuth),
    (N'92010', N'Tesoreria', N'Provision_Pago', @Full),
    (N'92010', N'Tesoreria', N'Inversiones', @Menu),
    (N'92010', N'Inversiones', N'Banco', @Full),
    (N'92010', N'Inversiones', N'Cuenta_Bancaria', @Full),
    (N'92010', N'Inversiones', N'Intermediarios_Financiero', @Full),
    (N'92010', N'Inversiones', N'Instrumentos_Inversion', @Full),
    (N'92010', N'Inversiones', N'Listado_Inversiones', @Full),
    (N'92010', N'Inversiones', N'Tipo_Instrumentos', @Full),
    (N'92010', N'Inversiones', N'Tipo_Plazos', @Full),
    (N'92010', N'Inversiones', N'Tipo_Retiro', @Full),
    (N'92010', N'Inversiones', N'Simulador', @Full),

    (N'92020', N'Tesoreria', N'CuentasXPagar', @Menu),
    (N'92020', N'CuentasXPagar', N'PEF_Unipartida_TES', @Menu),
    (N'92020', N'PEF_Unipartida_TES', N'RecepcionFactura_ComprobantePago', @Capture),
    (N'92020', N'PEF_Unipartida_TES', N'Provision_Pago', @Capture),
    (N'92020', N'PEF_Unipartida_TES', N'ElaboracionCheque_Transferencia', @Capture),
    (N'92020', N'CuentasXPagar', N'RecepcionFactura_ComprobantePago', @Capture),
    (N'92020', N'CuentasXPagar', N'Provision_Pago', @Capture),
    (N'92020', N'CuentasXPagar', N'ElaboracionCheque_Transferencia', @Capture),

    (N'92030', N'Tesoreria', N'CuentasXPagar', @Menu),
    (N'92030', N'CuentasXPagar', N'PEF_Unipartida_TES', @Menu),
    (N'92030', N'PEF_Unipartida_TES', N'RecepcionFactura_ComprobantePago', @Auth),
    (N'92030', N'PEF_Unipartida_TES', N'Provision_Pago', @Auth),
    (N'92030', N'PEF_Unipartida_TES', N'ElaboracionCheque_Transferencia', @Auth),
    (N'92030', N'CuentasXPagar', N'RecepcionFactura_ComprobantePago', @Auth),
    (N'92030', N'CuentasXPagar', N'Provision_Pago', @Auth),
    (N'92030', N'CuentasXPagar', N'ElaboracionCheque_Transferencia', @Auth),

    (N'92040', N'Tesoreria', N'CuentasXCobrar', @Menu),
    (N'92040', N'CuentasXCobrar', N'Ley_Ingresos_Estimados', @Capture),
    (N'92040', N'CuentasXCobrar', N'Ingresos_Devengados', @Menu),
    (N'92040', N'Ingresos_Devengados', N'Ingresos', @Capture),
    (N'92040', N'Ingresos_Devengados', N'Ingresos_Propios', @Capture),
    (N'92040', N'CuentasXCobrar', N'Ingresos_Recaudar', @Capture),
    (N'92040', N'CuentasXCobrar', N'Depositos_CLC', @Capture),
    (N'92040', N'CuentasXCobrar', N'Otros_Ingresos', @Capture),

    (N'92050', N'Tesoreria', N'CuentasXCobrar', @Menu),
    (N'92050', N'CuentasXCobrar', N'Ley_Ingresos_Estimados', @Auth),
    (N'92050', N'Ingresos_Devengados', N'Ingresos', @Auth),
    (N'92050', N'Ingresos_Devengados', N'Ingresos_Propios', @Auth),
    (N'92050', N'CuentasXCobrar', N'Ingresos_Recaudar', @Auth),
    (N'92050', N'CuentasXCobrar', N'Depositos_CLC', @Auth),
    (N'92050', N'CuentasXCobrar', N'Otros_Ingresos', @Auth),

    (N'92060', N'Tesoreria', N'Inversiones', @Menu),
    (N'92060', N'Inversiones', N'Banco', @Full),
    (N'92060', N'Inversiones', N'Cuenta_Bancaria', @Full),
    (N'92060', N'Inversiones', N'Intermediarios_Financiero', @Full),
    (N'92060', N'Inversiones', N'Instrumentos_Inversion', @Full),
    (N'92060', N'Inversiones', N'Listado_Inversiones', @Full),
    (N'92060', N'Inversiones', N'Tipo_Instrumentos', @Full),
    (N'92060', N'Inversiones', N'Tipo_Plazos', @Full),
    (N'92060', N'Inversiones', N'Tipo_Retiro', @Full),
    (N'92060', N'Inversiones', N'Simulador', @Full),

    (N'92070', N'Tesoreria', N'Tipo_Cambio', @Full),
    (N'92070', N'Tesoreria', N'Tipo_Inversion', @Full),
    (N'92070', N'Tesoreria', N'Tipo_Moneda', @Full),
    (N'92070', N'Tesoreria', N'Tipo_Pago', @Full),
    (N'92070', N'Tesoreria', N'Tipo_PagoSF', @Full),
    (N'92070', N'Tesoreria', N'Tipo_SolicitudCLC', @Full),
    (N'92070', N'Tesoreria', N'Tipo_DoctoCLC', @Full),

    (N'92080', N'Tesoreria', N'CuentasXPagar', @Menu),
    (N'92080', N'Tesoreria', N'CuentasXCobrar', @Menu),
    (N'92080', N'Tesoreria', N'Inversiones', @Menu),
    (N'92080', N'CuentasXPagar', N'RecepcionFactura_ComprobantePago', @Read),
    (N'92080', N'CuentasXPagar', N'Provision_Pago', @Read),
    (N'92080', N'CuentasXPagar', N'ElaboracionCheque_Transferencia', @Read),
    (N'92080', N'CuentasXCobrar', N'Ley_Ingresos_Estimados', @Read),
    (N'92080', N'Ingresos_Devengados', N'Ingresos', @Read),
    (N'92080', N'Ingresos_Devengados', N'Ingresos_Propios', @Read),
    (N'92080', N'CuentasXCobrar', N'Ingresos_Recaudar', @Read),
    (N'92080', N'CuentasXCobrar', N'Depositos_CLC', @Read),
    (N'92080', N'CuentasXCobrar', N'Otros_Ingresos', @Read),
    (N'92080', N'CuentasXCobrar', N'Reportes_CxC', @Menu),
    (N'92080', N'Reportes_CxC', N'Integracion_Saldos', @Read),
    (N'92080', N'Reportes_CxC', N'Estado_Cuenta', @Read),
    (N'92080', N'Reportes_CxC', N'Analisis_Saldos', @Read),
    (N'92080', N'Reportes_CxC', N'Consulta_Documentos', @Read),
    (N'92080', N'Tesoreria', N'Saldos_Cuentas', @Read),
    (N'92080', N'Inversiones', N'Listado_Inversiones', @Read),
    (N'92080', N'Inversiones', N'Simulador', @Read);

    /* ============================================================
       Validation
       ============================================================ */

    IF EXISTS
    (
        SELECT 1
        FROM @Assignments a
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.AspNetRoles r
            WHERE CONVERT(NVARCHAR(10), r.Code) = a.RoleCode
        )
    )
    BEGIN
        SELECT DISTINCT a.RoleCode AS MissingRoleCode
        FROM @Assignments a
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.AspNetRoles r
            WHERE CONVERT(NVARCHAR(10), r.Code) = a.RoleCode
        )
        ORDER BY a.RoleCode;

        THROW 51002, 'Faltan roles en dbo.AspNetRoles. Ejecuta primero el script de roles.', 1;
    END;

    /* ============================================================
       Apply claims safely.
       This does not call spConfiguracionDeRolYClaims because that proc
       can append duplicated action lists when executed more than once.
       ============================================================ */

    DECLARE
        @Id INT,
        @RoleCode NVARCHAR(10),
        @Group NVARCHAR(100),
        @SubGroup NVARCHAR(100),
        @Values NVARCHAR(MAX),
        @RoleId NVARCHAR(128),
        @ClaimId INT,
        @CurrentValues NVARCHAR(MAX),
        @MergedValues NVARCHAR(MAX),
        @Token NVARCHAR(100),
        @ClaimCode NVARCHAR(10),
        @Description NVARCHAR(200),
        @ReferenceId INT;

    DECLARE assignment_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT Id, RoleCode, [Group], SubGroup, [Values]
        FROM @Assignments
        ORDER BY Id;

    OPEN assignment_cursor;
    FETCH NEXT FROM assignment_cursor INTO @Id, @RoleCode, @Group, @SubGroup, @Values;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @RoleId = r.Id
        FROM dbo.AspNetRoles r
        WHERE CONVERT(NVARCHAR(10), r.Code) = @RoleCode;

        SELECT
            @ClaimId = c.Id,
            @CurrentValues = CONVERT(NVARCHAR(MAX), c.[Values])
        FROM dbo.AspNetClaims c
        WHERE c.RoleId = @RoleId
          AND c.[Group] = @Group
          AND c.SubGroup = @SubGroup;

        IF @ClaimId IS NULL
        BEGIN
            SET @ClaimCode = NULL;
            SET @Description = NULL;
            SET @ReferenceId = 0;

            SELECT TOP (1)
                @ClaimCode = c.Code,
                @Description = c.[Description],
                @ReferenceId = c.Id
            FROM dbo.AspNetClaims c
            WHERE c.[Group] = @Group
              AND c.SubGroup = @SubGroup
            ORDER BY CASE WHEN c.RoleId IS NULL THEN 0 ELSE 1 END, c.Id;

            IF @ClaimCode IS NULL
            BEGIN
                SELECT TOP (1) @ClaimCode = c.Code
                FROM dbo.AspNetClaims c
                WHERE c.[Group] = @Group
                  AND c.Code IS NOT NULL
                ORDER BY c.Id;
            END;

            IF @Description IS NULL
                SET @Description = @SubGroup;

            IF @ReferenceId IS NULL
                SET @ReferenceId = 0;

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
            VALUES
            (
                2,
                @Group,
                @Group,
                @RoleId,
                N'app://{0}/{1}',
                GETDATE(),
                @SubGroup,
                @ClaimCode,
                @Description,
                CONVERT(VARCHAR(MAX), @Values),
                @ReferenceId
            );
        END
        ELSE
        BEGIN
            SET @MergedValues = ISNULL(@CurrentValues, N'');

            DECLARE token_cursor CURSOR LOCAL FAST_FORWARD FOR
                SELECT LTRIM(RTRIM([value]))
                FROM STRING_SPLIT(@Values, N',')
                WHERE LTRIM(RTRIM([value])) <> N'';

            OPEN token_cursor;
            FETCH NEXT FROM token_cursor INTO @Token;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                IF CONCAT(N',', REPLACE(ISNULL(@MergedValues, N''), N' ', N''), N',')
                   NOT LIKE CONCAT(N'%,', REPLACE(@Token, N' ', N''), N',%')
                BEGIN
                    SET @MergedValues =
                        CASE
                            WHEN NULLIF(LTRIM(RTRIM(ISNULL(@MergedValues, N''))), N'') IS NULL THEN @Token
                            ELSE CONCAT(@MergedValues, N',', @Token)
                        END;
                END;

                FETCH NEXT FROM token_cursor INTO @Token;
            END;

            CLOSE token_cursor;
            DEALLOCATE token_cursor;

            IF ISNULL(@CurrentValues, N'') <> ISNULL(@MergedValues, N'')
            BEGIN
                UPDATE dbo.AspNetClaims
                SET [Values] = CONVERT(VARCHAR(MAX), @MergedValues)
                WHERE Id = @ClaimId;
            END;
        END;

        SET @RoleId = NULL;
        SET @ClaimId = NULL;
        SET @CurrentValues = NULL;
        SET @MergedValues = NULL;

        FETCH NEXT FROM assignment_cursor INTO @Id, @RoleCode, @Group, @SubGroup, @Values;
    END;

    CLOSE assignment_cursor;
    DEALLOCATE assignment_cursor;

    COMMIT TRANSACTION;

    SELECT
        r.Code,
        r.Name AS RoleName,
        c.[Group],
        c.SubGroup,
        c.[Values]
    FROM dbo.AspNetRoles r
    INNER JOIN dbo.AspNetClaims c
        ON c.RoleId = r.Id
    WHERE EXISTS
    (
        SELECT 1
        FROM @Assignments a
        WHERE a.RoleCode = CONVERT(NVARCHAR(10), r.Code)
          AND a.[Group] = c.[Group]
          AND a.SubGroup = c.SubGroup
    )
    ORDER BY r.Code, c.[Group], c.SubGroup;
END TRY
BEGIN CATCH
    IF CURSOR_STATUS('local', 'token_cursor') >= 0
    BEGIN
        CLOSE token_cursor;
    END;

    IF CURSOR_STATUS('local', 'token_cursor') >= -1
    BEGIN
        DEALLOCATE token_cursor;
    END;

    IF CURSOR_STATUS('local', 'assignment_cursor') >= 0
    BEGIN
        CLOSE assignment_cursor;
    END;

    IF CURSOR_STATUS('local', 'assignment_cursor') >= -1
    BEGIN
        DEALLOCATE assignment_cursor;
    END;

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
