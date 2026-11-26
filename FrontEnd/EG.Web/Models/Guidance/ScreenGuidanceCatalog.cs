namespace EG.Web.Models.Guidance;

public sealed record ModuleGuidanceLink(string Module, string SubModule, string Href, string Text);
public sealed record ScreenGuidance(string Title, string Description, IReadOnlyList<string> Steps, string? CreateText = null, IReadOnlyList<ModuleGuidanceLink>? Links = null);

public static class ScreenGuidanceCatalog
{
    private static readonly IReadOnlyDictionary<string, ScreenGuidance> Entries = Build();
    private static readonly HashSet<string> CatalogRoutes = new(StringComparer.OrdinalIgnoreCase)
    {
        "rh/configuracion/universo",
        "rh/universo",
        "nomina/configuracion/catalogos/tipos-pension",
        "nomina/configuracion/catalogos/tipos-pago",
        "nomina/configuracion/catalogos/forma-pago",
        "sis/formapago",
        "nomina/configuracion/catalogos/tipo-justificacion",
        "sis/tipojustificacion",
        "nomina/configuracion/catalogos/tipo-incidencia",
        "nomina/configuracion/catalogos/tipos-incidencia",
        "sis/tipoincidencia",
        "nomina/configuracion/catalogos/tipos-incapacidad",
        "nomina/configuracion/catalogos/tipo-contratacion",
        "sis/tipocontratacion",
        "nomina/configuracion/isr/semanal",
        "sis/isrsemanal",
        "nomina/configuracion/isr/quincenal",
        "sis/isrquincenal",
        "nomina/configuracion/isr/mensual",
        "sis/isrmensual",
        "nomina/configuracion/tablas-isr/semanal",
        "nomina/configuracion/tablas-isr/quincenal",
        "nomina/configuracion/tablas-isr/mensual",
        "nomina/configuracion/subsidios/semanal",
        "sis/subsidiosemanal",
        "nomina/configuracion/subsidios/quincenal",
        "sis/subsidioquincenal",
        "nomina/configuracion/subsidios/mensual",
        "sis/subsidiomensual",
        "nomina/configuracion/subsidios-isr/semanal",
        "nomina/configuracion/subsidios-isr/quincenal",
        "nomina/configuracion/subsidios-isr/mensual",
        "nomina/configuracion/impuestos/base-gravable",
        "sis/basegravable",
        "nomina/configuracion/impuestos/locales",
        "nomina/configuracion/imss/clase",
        "sis/imssclase",
        "nomina/configuracion/imss/clase-imss",
        "nomina/configuracion/imss/fraccion",
        "sis/imssfraccion",
        "nomina/configuracion/imss/fraccion-imss",
        "nomina/configuracion/imss/base-gravable",
        "sis/basegravableimss",
        "nomina/configuracion/catalogos/sueldos-semanales",
        "nomina/configuracion/catalogos/sueldos-quincenales",
        "nom/sueldoquincenal",
        "nomina/configuracion/catalogos/sueldos-mensuales",
        "nom/sueldomensual",
        "nomina/configuracion/catalogos/sueldos-liquidacion-finiquito",
        "nomina/configuracion/catalogos/sueldos-especiales",
        "nomina/configuracion/catalogos/salarios-minimos",
        "nomina/configuracion/catalogos/smg",
        "sis/smg",
        "nomina/configuracion/catalogos/puestos",
        "rh/configuracion/plazas",
        "emp/plazasautorizadas",
        "nomina/configuracion/catalogos/periodos-activos",
        "nomina/configuracion/periodos/semanal",
        "sis/periodosemanal",
        "nomina/configuracion/periodos/quincenal",
        "sis/periodoquincenal",
        "nomina/configuracion/periodos/mensual",
        "sis/periodomensual",
        "nomina/configuracion/periodos/bimestral",
        "sis/periodobimestral",
        "rh/configuracion/parentesco",
        "sis/tipoparentesco",
        "sis/parentesco",
        "nomina/configuracion/catalogos/nombramientos",
        "rh/configuracion/nivel",
        "rh/nivel",
        "rh/configuracion/contratos/metodo-pago",
        "sis/metodopago",
        "sis/medodopago",
        "nomina/configuracion/catalogos/infonavit",
        "nom/infonavit",
        "nomina/configuracion/catalogos/importes-nivel",
        "nomina/configuracion/catalogos/factores-integracion",
        "nom/factorint",
        "nomina/configuracion/imss/prestaciones",
        "sis/deprecar",
        "nomina/configuracion/imss/prestaciones-minimas",
        "sis/deprecar1",
        "nomina/configuracion/catalogos/estatus-pago",
        "rh/configuracion/estado-civil",
        "sis/estadocivil",
        "rh/configuracion/escolaridad",
        "sis/escolaridad",
        "nomina/configuracion/catalogos/empresas-nomina",
        "rh/configuracion/contratos/dia-semana",
        "sis/diasemana",
        "nomina/configuracion/catalogos/descuentos-infonavit",
        "nomina/configuracion/catalogos/descuentos-credito",
        "nomina/configuracion/catalogos/creditos",
        "nomina/creditos",
        "emp/credito",
        "nom/credito",
        "nomina/configuracion/catalogos/contratos-terceros",
        "rh/configuracion/contratos",
        "rh/contrato",
        "rh/contratolaboral",
        "nomina/configuracion/catalogos/conceptos-variables",
        "nomina/configuracion/catalogos/conceptos-tabulares",
        "nomina/configuracion/catalogos/tabulador",
        "nom/conceptotabular",
        "nomina/configuracion/catalogos/conceptos",
        "nom/concepto",
        "nomina/configuracion/catalogos/conceptos-proporcionales",
        "nomina/configuracion/catalogos/conceptos-porcentaje",
        "nomina/configuracion/catalogos/conceptos-fijos",
        "nomina/configuracion/catalogos/concepto-fijo",
        "nom/conceptofijo",
        "nomina/configuracion/catalogos/concepto-factor",
        "nomina/configuracion/catalogos/clases-puesto",
        "rh/configuracion/sexo",
        "sis/sexo",
        "rh/configuracion/tipo-sangre",
        "sis/tiposangre",
        "rh/configuracion/profesion",
        "sis/profesion",
        "rh/configuracion/regimen-fiscal",
        "sis/regimenfiscal",
        "rh/configuracion/pais",
        "sis/pais",
        "rh/configuracion/periodo-pago",
        "sis/periodopago",
        "rh/configuracion/tipo-documento",
        "rh/tipodocumento",
        "sis/tipodocumento",
        "rh/configuracion/tipo-expediente",
        "rh/tipoexpediente",
        "sis/tipoexpediente",
        "rh/configuracion/opcion-jubilacion",
        "rh/opcionjubilacion",
        "rh/configuracion/situacion-persona",
        "rh/situacionpersona",
        "rh/configuracion/situacion-plaza",
        "rh/situacionplaza",
        "rh/configuracion/situacion-movimiento",
        "rh/situacionmovimiento",
        "rh/configuracion/clase-movimiento",
        "rh/clasemovto",
        "rh/configuracion/movimiento",
        "rh/movimiento",
        "rh/configuracion/estado",
        "sis/estado",
        "rh/configuracion/banco",
        "sis/banco",
        "rh/configuracion/municipio",
        "sis/municipio",
        "rh/configuracion/contratos/base-pago",
        "sis/basepago",
        "rh/configuracion/contratos/tipo-regimen",
        "sis/tiporegimen",
        "rh/configuracion/contratos/base-cotizacion",
        "sis/basecotizacion",
        "rh/configuracion/contratos/zona-geografica",
        "sis/zonageografica",
        "nomina/configuracion/catalogos/tipo-nomina",
        "sis/tiponomina",
        "nomina/configuracion/catalogos/cuotas-imss",
        "sis/cuotasimss",
        "nomina/configuracion/catalogos/uma",
        "sis/uma",
        "nomina/configuracion/catalogos/tipo-descanso",
        "sis/tipodescanso",
        "nomina/configuracion/catalogos/unidad-infonavit",
        "sis/unidadinfonavit",
        "nomina/configuracion/catalogos/forma-calculo",
        "sis/formacalculo",
        "nomina/configuracion/catalogos/capitulos",
        "sis/capitulos",
    };
    private static readonly ScreenGuidance CatalogHelp = new(
        "Consulta y captura del catálogo", "Busca el registro y revisa sus datos antes de modificarlo.",
        ["Usa la búsqueda y las columnas para localizar el registro.", "Nuevo abre la captura si tu perfil tiene permiso; editar conserva los datos del registro seleccionado.", "Guardar valida la captura. Si aparece un error, corrige el dato indicado antes de volver a guardar."]);

    public static ScreenGuidance? Find(string route)
    {
        var key = route.Trim('/');
        if (Entries.TryGetValue(key, out var guidance)) return guidance;
        return key.StartsWith("configuracion/", StringComparison.OrdinalIgnoreCase) || CatalogRoutes.Contains(key) ? CatalogHelp : null;
    }

    private static IReadOnlyDictionary<string, ScreenGuidance> Build()
    {
        var result = new Dictionary<string, ScreenGuidance>(StringComparer.OrdinalIgnoreCase);
        Add(result, new(
            "Distribución del anteproyecto",
            "Revisa programa, partida, área y distribución mensual antes de continuar con la autorización.",
            [
                "Los totales del listado corresponden a los registros visibles. Usa búsqueda y columnas para localizar una partida.",
                "Nuevo permite capturar una partida; Alta desde Excel abre la vista previa de importación.",
                "Autorizar y quitar autorización conservan las confirmaciones y restricciones del proceso.",
            ],
            "Nueva partida",
            null),
            "/Presupuesto/Egreso/Planeacion/Anteproyecto_Egresos");
        Add(result, new(
            "Consulta del presupuesto autorizado",
            "Los importes y su origen se muestran por programa, partida y área.",
            [
                "Confirma el ejercicio y busca la partida que necesitas.",
                "Los indicadores del encabezado corresponden a esta página.",
                "Los registros ligados a un anteproyecto conservan las restricciones del flujo de origen.",
            ],
            "Nueva partida",
            null),
            "/Presupuesto/Egreso/Presupuesto_Autorizado");
        Add(result, new(
            "Revisa la disponibilidad",
            "Consulta el saldo por programa y partida en el ejercicio seleccionado.",
            [
                "Verifica el ejercicio del encabezado.",
                "Busca por programa o partida; conserva los filtros al revisar las columnas.",
                "Los saldos mostrados se consultan al servidor; actualizar vuelve a cargar los resultados.",
            ],
            null,
            null),
            "/Presupuesto/Egreso/Presupuesto_Disponible");
        Add(result, new(
            "Planeación de los ingresos",
            "Captura y consulta la distribución del ingreso estimado.",
            [
                "Confirma ejercicio, programa y clasificación del registro.",
                "Los totales del listado corresponden a la página visible.",
                "La generación de póliza y autorización siguen usando el flujo y permisos existentes.",
            ],
            "Nuevo ingreso",
            null),
            "/Presupuesto/Tesoreria/Cuentas_Cobrar/Ingresos_Estimados");
        Add(result, new(
            "Registro y seguimiento del depósito",
            "Revisa referencia, aportante, importe y estado antes de continuar.",
            [
                "Nuevo depósito abre la captura en el ejercicio seleccionado.",
                "Consulta la póliza y el estado del depósito desde las acciones del registro.",
                "Autorizar conserva la confirmación y las restricciones del proceso.",
            ],
            "Nuevo depósito",
            null),
            "/Presupuesto/Tesoreria/Cuentas_Cobrar/Depositos_CLC",
            "/Tesoreria/Cuentas_Cobrar/Depositos_CLC");
        Add(result, new(
            "Consulta del ingreso por ejercer",
            "La captura de origen se realiza en Ley de Ingresos Estimados.",
            [
                "Verifica ejercicio y búsqueda para localizar el registro.",
                "Los importes del resumen corresponden a la página visible.",
                "Usa el acceso a Ley de Ingresos Estimados si necesitas trabajar con la captura de origen.",
            ],
            null,
            new ModuleGuidanceLink[] { new("CuentasXCobrar", "Ley_Ingresos_Estimados", "/Presupuesto/Tesoreria/Cuentas_Cobrar/Ingresos_Estimados", "Ley de ingresos estimados") }),
            "/Presupuesto/Tesoreria/Cuentas_Cobrar/Ingresos_Devengados/Ingresos_Propios");
        Add(result, new(
            "Seguimiento de ingresos por recaudar",
            "Consulta origen, programa, área y distribución del ejercicio.",
            [
                "Confirma el ejercicio antes de revisar importes.",
                "La búsqueda y la selección de columnas ayudan a localizar el concepto.",
                "Los totales visibles corresponden a la página actual; usa la paginación para los demás registros.",
            ],
            null,
            null),
            "/Presupuesto/Tesoreria/Cuentas_Cobrar/Ingresos_Recaudar");
        Add(result, new(
            "Consulta consolidada de CLC",
            "Los registros de origen se capturan desde Depósitos CLC.",
            [
                "Busca la CLC o referencia que necesitas revisar.",
                "Los indicadores corresponden a los registros visibles.",
                "El acceso a Depósitos CLC conserva el permiso del módulo de origen.",
            ],
            null,
            new ModuleGuidanceLink[] { new("CuentasXCobrar", "Depositos_CLC", "/Presupuesto/Tesoreria/Cuentas_Cobrar/Depositos_CLC", "Depósitos CLC") }),
            "/Presupuesto/Tesoreria/Cuentas_Cobrar/Ingresos_Devengados/Ingresos");
        Add(result, new(
            "Consulta de la provisión",
            "Revisa las facturas y sus importes antes de continuar con el proceso de pago.",
            [
                "Localiza el registro con la búsqueda.",
                "Consulta las columnas e importes de la página actual.",
                "La consulta no registra un pago; las operaciones del flujo conservan sus controles.",
            ],
            null,
            null),
            "/Presupuesto/Tesoreria/Provision_Pago");
        Add(result, new(
            "Preparación del cierre mensual",
            "Revisa las validaciones del período antes de cerrar el mes.",
            [
                "Comprueba pólizas pendientes, balance y movimientos del período.",
                "Si hay pendientes, revisa sus pólizas antes de volver a actualizar el estado.",
                "Cerrar mes conserva su confirmación y sólo se habilita cuando las reglas y permisos del proceso lo permiten.",
            ],
            null,
            new ModuleGuidanceLink[] { new("Contabilidad", "Polizas", "/Contabilidad/Polizas", "Revisar pólizas") }),
            "/Contabilidad/Cierre_Mensual");
        Add(result, new(
            "Parámetros del reporte",
            "Selecciona el reporte y revisa los filtros disponibles antes de abrirlo.",
            [
                "Verifica la empresa y los parámetros que muestra esta vista.",
                "Cuando existan fechas de inicio y fin, revisa el rango antes de generar el documento.",
                "Ver reporte abre el reporte configurado; si falta configuración, la pantalla lo indica.",
            ],
            null,
            null),
            "/Contabilidad/Autorizacion_Polizas",
            "/Contabilidad/Balanza_Comprobacion",
            "/Contabilidad/Auxiliares",
            "/Contabilidad/Reportes_Contabilidad",
            "/Contabilidad/Reportes_Contabilidad/Libro_Diario",
            "/Contabilidad/Reportes_Contabilidad/Libro_Mayor",
            "/Contabilidad/Reportes_Contabilidad/Libro_Inventarios_Materiales",
            "/Contabilidad/Reportes_Contabilidad/Libro_Almacen_Suministros",
            "/Contabilidad/Reportes_Contabilidad/Libro_Inventarios_Muebles",
            "/Contabilidad/Reportes_Contabilidad/Polizas",
            "/Contabilidad/Reportes_Contabilidad/Reporte_Retenciones",
            "/Contabilidad/Reportes_Contabilidad/Reporte_Depreciacion_Acumulada",
            "/Contabilidad/Reportes_Contabilidad/Reporte_Activos_Fijos",
            "/Contabilidad/Reportes_Contabilidad/Reporte_Facturas_Emitidas",
            "/Contabilidad/Reportes_Contabilidad/Reporte_DIOT",
            "/Contabilidad/EI_Contable",
            "/Contabilidad/EI_Contable/Estados_Actividades",
            "/Contabilidad/EI_Contable/Estado_Situacion_Financiera",
            "/Contabilidad/EI_Contable/Estado_VHP",
            "/Contabilidad/EI_Contable/Estados_CSF",
            "/Contabilidad/EI_Contable/Estado_Flujos_Efectivo",
            "/Contabilidad/EI_Contable/Estado_Analitico_Activo",
            "/Contabilidad/EI_Contable/Estado_ADOP",
            "/Contabilidad/EI_Contable/Informe_Pasivos_Contingentes",
            "/Contabilidad/EI_Contable/Notas_Estados_Financieros",
            "/Contabilidad/Conciliacion_IE",
            "/Contabilidad/EI_Presupuestarios",
            "/Contabilidad/EI_Presupuestarios/Estado_Analitico_Ingresos",
            "/Contabilidad/EI_Presupuestarios/Estado_AECA",
            "/Contabilidad/EI_Presupuestarios/Estado_AECE",
            "/Contabilidad/EI_Presupuestarios/Estado_AECOG",
            "/Contabilidad/EI_Presupuestarios/Estado_AECF",
            "/Contabilidad/EI_Presupuestarios/Endeudamiento_Neto",
            "/Contabilidad/EI_Presupuestarios/Intereses_Deuda",
            "/Contabilidad/EI_Presupuestarios/Proyecciones_Egresos",
            "/Contabilidad/EI_Presupuestarios/Proyecciones_Ingresos",
            "/Contabilidad/EI_Presupuestarios/Indicadores_APP",
            "/Contabilidad/EI_Presupuestarios/Pp_Inversion",
            "/Contabilidad/EI_Presupuestarios/Resultados_Ingresos",
            "/Contabilidad/EI_Presupuestarios/Resultados_Egresos",
            "/Contabilidad/EI_Programaticos",
            "/Contabilidad/Indicadores_Postura_Fiscal");
        Add(result, new(
            "Captura de entradas por ajuste",
            "Revisa el bien y el motivo del movimiento antes de registrar la entrada.",
            [
                "Confirma empresa, ejercicio y el bien que vas a ajustar.",
                "La captura conserva sus validaciones de cantidad y fecha.",
                "Consulta el registro y su soporte documental desde el listado.",
            ],
            "Nueva entrada",
            null),
            "/Almacen/Entradas_Ajuste");
        Add(result, new(
            "Captura de salidas por ajuste",
            "Revisa el bien y el motivo antes de registrar el movimiento.",
            [
                "Comprueba el contexto y localiza el bien.",
                "Nuevo abre la captura del ajuste; los saldos se validan al guardar.",
                "Consulta el movimiento y sus documentos en el listado.",
            ],
            "Nueva salida",
            null),
            "/Almacen/Salidas_Ajuste");
        Add(result, new(
            "Consulta de existencias",
            "Busca el bien o código para consultar los registros disponibles.",
            [
                "Confirma el contexto del encabezado.",
                "Usa búsqueda y columnas para localizar el bien y sus cantidades.",
                "Actualizar vuelve a consultar los resultados del listado.",
            ],
            null,
            null),
            "/Almacen/Existencias_Registradas");
        Add(result, new(
            "Preparación del conteo cíclico",
            "Consulta el período, avance y cantidades del conteo.",
            [
                "Localiza el período o descripción mediante la búsqueda.",
                "Compara inventario y cantidad contada en las filas del listado.",
                "La captura se realiza en Mis Períodos de Conteo, según el permiso del responsable.",
            ],
            null,
            new ModuleGuidanceLink[] { new("Almacen", "Numero_Conteo", "/ALMAConteo", "Mis períodos de conteo") }),
            "/Almacen/Conteo_ciclico");
        Add(result, new(
            "Preparación del conteo anual",
            "Consulta el período, avance y cantidades del conteo.",
            [
                "Localiza el período o descripción mediante la búsqueda.",
                "Compara inventario y cantidad contada en las filas del listado.",
                "La captura se realiza en Mis Períodos de Conteo, según el permiso del responsable.",
            ],
            null,
            new ModuleGuidanceLink[] { new("Almacen", "Numero_Conteo", "/ALMAConteo", "Mis períodos de conteo") }),
            "/Almacen/Conteo_ciclico_anual");
        Add(result, new(
            "Revisión de diferencias",
            "Localiza el conteo y consulta sus diferencias.",
            [
                "Localiza el período y el tipo de bien en la búsqueda.",
                "Compara inventario teórico, cantidad contada y diferencia de cada fila.",
                "Esta consulta no registra un ajuste de inventario.",
            ],
            null,
            null),
            "/Almacen/Reporte_diferencias_Conteo");
        Add(result, new(
            "Revisión de diferencias anuales",
            "Consulta el resultado del conteo anual seleccionado.",
            [
                "Localiza el período y el tipo de bien en la búsqueda.",
                "Compara inventario teórico, cantidad contada y diferencia de cada fila.",
                "Esta consulta no registra un ajuste de inventario.",
            ],
            null,
            null),
            "/Almacen/Reporte_diferencias_Conteo_anual");
        Add(result, new(
            "Conteos y escaneo de bienes",
            "Selecciona el período para capturar y revisar los bienes de ese conteo.",
            [
                "Escanear bienes abre la captura del conteo elegido.",
                "Revisa la pestaña de detalles para consultar los bienes capturados.",
                "Los botones conservan los permisos y validaciones del período.",
            ],
            "Nuevo período",
            null),
            "/ALMAConteo",
            "/configuracion/almacen/Numero_Conteo");
        Add(result, new(
            "Consulta y captura del bien",
            "Revisa identificación, estado y asignación del bien.",
            [
                "Busca por la identificación o descripción disponible.",
                "Nuevo bien abre la captura; las acciones del registro permiten consultar su detalle y asignaciones.",
                "Los cambios conservan las validaciones y el estado del proceso.",
            ],
            "Nuevo bien",
            null),
            "/Patrimonio/Bienes",
            "/configuracion/almacen/Bien");
        Add(result, new(
            "Planeación del inventario",
            "Organiza y consulta el calendario antes del levantamiento.",
            [
                "Verifica área, responsable y fechas del calendario.",
                "Las acciones del registro abren la captura y seguimiento correspondientes.",
                "La validación de fechas y los bloqueos del calendario permanecen activos.",
            ],
            "Nuevo calendario",
            null),
            "/Patrimonio/Calendario_Inventarios");
        Add(result, new(
            "Recepción y clasificación patrimonial",
            "Consulta las órdenes y bienes que participan en la recepción.",
            [
                "Selecciona el registro de origen para revisar los bienes.",
                "La recepción conserva las cantidades, relaciones y permisos del proceso.",
                "Revisa los bienes registrados antes de continuar con su asignación.",
            ],
            null,
            null),
            "/Patrimonio/Clasificacion_Bienes_Muebles");
        Add(result, new(
            "Consulta y firma del resguardo",
            "Revisa responsable y bienes antes de continuar con la firma.",
            [
                "Selecciona el resguardo para consultar su contenido.",
                "Comprueba la persona responsable y los bienes asignados.",
                "Revisa el soporte documental y las acciones habilitadas para tu perfil.",
            ],
            null,
            null),
            "/Patrimonio/Firma_Resguardos");
        Add(result, new(
            "Historial de asignaciones",
            "Consulta movimientos y responsables del bien.",
            [
                "Localiza el registro con la búsqueda.",
                "Revisa fechas y personas de cada movimiento.",
                "El historial es una consulta y no cambia la asignación actual.",
            ],
            null,
            null),
            "/Patrimonio/Resguardo_Historico");
        Add(result, new(
            "Revisión de la cédula",
            "Consulta las diferencias detectadas durante el inventario.",
            [
                "Revisa el contexto y los filtros disponibles.",
                "Localiza el bien o registro que necesitas consultar.",
                "Las acciones conservan los permisos y validaciones del proceso.",
            ],
            null,
            null),
            "/Patrimonio/Cedula_Diferencia");
        Add(result, new(
            "Seguimiento del contrato",
            "Consulta saldo e importes del contrato antes de continuar.",
            [
                "Localiza contrato o proveedor con la búsqueda.",
                "Revisa estado e importes de los registros visibles.",
                "Los movimientos posteriores conservan sus permisos y restricciones.",
            ],
            null,
            null),
            "/Contratos/Saldos_Contratos",
            "/Adquisiciones/Contratos/Saldos_Contratos");
        Add(result, new(
            "Consulta y captura de tipo de retiro",
            "Busca el registro y revisa sus datos antes de modificarlo.",
            [
                "La búsqueda y las columnas permiten localizar el registro.",
                "Nuevo registro abre la captura si tu perfil tiene permiso.",
                "Guardar conserva las validaciones de campos y relaciones del catálogo.",
            ],
            "Nuevo registro",
            null),
            "/Presupuesto/Tesoreria/Inversiones/Tipo_Retiro",
            "/Presupuesto/Tesorería/Inversiones/Tipo_Retiro");
        Add(result, new(
            "Consulta y captura de instrumentos de inversion",
            "Busca el registro y revisa sus datos antes de modificarlo.",
            [
                "La búsqueda y las columnas permiten localizar el registro.",
                "Nuevo registro abre la captura si tu perfil tiene permiso.",
                "Guardar conserva las validaciones de campos y relaciones del catálogo.",
            ],
            "Nuevo registro",
            null),
            "/Presupuesto/Tesoreria/Inversiones/Instrumentos_Inversion",
            "/Presupuesto/Tesoreria/Instrumentos_Inversion",
            "/Presupuesto/Tesorería/Inversiones/Instrumentos_Inversion");
        Add(result, new(
            "Consulta y captura de cuenta bancaria",
            "Busca el registro y revisa sus datos antes de modificarlo.",
            [
                "La búsqueda y las columnas permiten localizar el registro.",
                "Nuevo registro abre la captura si tu perfil tiene permiso.",
                "Guardar conserva las validaciones de campos y relaciones del catálogo.",
            ],
            "Nuevo registro",
            null),
            "/Presupuesto/Tesoreria/Inversiones/Cuenta_Bancaria",
            "/Presupuesto/Tesorería/Inversiones/Cuenta_Bancaria");
        Add(result, new(
            "Consulta y captura de tipo de plazos",
            "Busca el registro y revisa sus datos antes de modificarlo.",
            [
                "La búsqueda y las columnas permiten localizar el registro.",
                "Nuevo registro abre la captura si tu perfil tiene permiso.",
                "Guardar conserva las validaciones de campos y relaciones del catálogo.",
            ],
            "Nuevo registro",
            null),
            "/Presupuesto/Tesoreria/Inversiones/Tipo_Plazos",
            "/Presupuesto/Tesorería/Inversiones/Tipo_Plazos");
        Add(result, new(
            "Consulta y captura de banco",
            "Busca el registro y revisa sus datos antes de modificarlo.",
            [
                "La búsqueda y las columnas permiten localizar el registro.",
                "Nuevo registro abre la captura si tu perfil tiene permiso.",
                "Guardar conserva las validaciones de campos y relaciones del catálogo.",
            ],
            "Nuevo registro",
            null),
            "/Presupuesto/Tesoreria/Inversiones/Banco",
            "/Presupuesto/Tesorería/Inversiones/Banco");
        Add(result, new(
            "Consulta y captura de intermediarios financieros",
            "Busca el registro y revisa sus datos antes de modificarlo.",
            [
                "La búsqueda y las columnas permiten localizar el registro.",
                "Nuevo registro abre la captura si tu perfil tiene permiso.",
                "Guardar conserva las validaciones de campos y relaciones del catálogo.",
            ],
            "Nuevo registro",
            null),
            "/Presupuesto/Tesoreria/Inversiones/Intermediarios_Financiero",
            "/Presupuesto/Tesorería/Inversiones/Intermediarios_Financiero");
        Add(result, new(
            "Seguimiento del PBR",
            "Consulta el avance y continúa hacia presupuesto o indicadores.",
            [
                "Los indicadores del tablero utilizan las consultas del módulo.",
                "Usa los accesos a presupuesto y matriz para revisar el detalle.",
                "Actualiza el tablero para volver a consultar sus datos.",
            ],
            null,
            null),
            "/PBR");
        Add(result, new(
            "Planeación del anteproyecto PBR",
            "Revisa el registro antes de continuar con su autorización.",
            [
                "Busca el anteproyecto por los datos disponibles.",
                "Nuevo abre la captura y las acciones de fila permiten editar o autorizar según el proceso.",
                "Los importes y estados se mantienen sujetos a las validaciones existentes.",
            ],
            "Nuevo anteproyecto",
            null),
            "/PBR/Anteproyectos");
        Add(result, new(
            "Programa y distribución del PBR",
            "Abre el presupuesto para consultar sus partidas.",
            [
                "Abrir presupuesto carga las partidas del programa seleccionado.",
                "Agregar partida conserva el presupuesto de origen en el formulario.",
                "Revisa importes y clasificación antes de guardar.",
            ],
            "Nuevo presupuesto",
            null),
            "/PBR/Presupuestos");
        Add(result, new(
            "Niveles e indicadores de la MIR",
            "Abre un nivel para consultar sus indicadores asociados.",
            [
                "Abrir nivel muestra los indicadores de la matriz seleccionada.",
                "Usa Agregar indicador para capturar en el nivel actual.",
                "Los campos y relaciones conservan sus validaciones al guardar.",
            ],
            "Nuevo nivel",
            null),
            "/PBR/MatrizIndicadores",
            "/Presupuesto/Egreso/Planeacion/Catalogos_Planeacion/Indicadores",
            "/Presupuesto/Egreso/Planeacion/Catalogos_Planeacion/Resumen_Narrativo");
        Add(result, new(
            "Accesos de trabajo PBR",
            "Continúa hacia presupuesto, matriz, mapa o anteproyectos.",
            [
                "Elige el proceso que necesitas revisar.",
                "Cada pantalla conserva su búsqueda y detalle.",
                "Las operaciones de captura mantienen sus validaciones y permisos.",
            ],
            null,
            null),
            "/PBR/MiTablero");
        Add(result, new(
            "Ruta de trabajo del PBR",
            "Consulta las etapas y abre el proceso que necesitas.",
            [
                "Revisa las etapas del mapa.",
                "Usa los accesos de cada etapa para continuar en la pantalla correspondiente.",
                "El mapa no ejecuta por sí mismo una autorización ni una captura.",
            ],
            null,
            null),
            "/PBR/MapaProcesos");
        Add(result, new(
            "Expediente y datos del personal",
            "Abre el expediente para revisar los datos relacionados del empleado.",
            [
                "Localiza al empleado con la búsqueda.",
                "Abrir expediente muestra sus datos y opciones relacionadas.",
                "La captura y edición conservan los permisos y validaciones del módulo.",
            ],
            "Nuevo empleado",
            null),
            "/nomina/empleados",
            "/rh/persona");
        Add(result, new(
            "Preparación de los procesos de nómina",
            "Comprueba empresa, período y la acción antes de ejecutar un proceso.",
            [
                "Revisa el contexto activo y los filtros disponibles.",
                "Las acciones de proceso conservan su validación y confirmación.",
                "Consulta el resultado antes de iniciar otra operación.",
            ],
            null,
            null),
            "/nomina/procesos",
            "/nom/calcnomina",
            "/nom/cierraperiodo",
            "/nom/calcaguinaldo",
            "/nom/primavacacionalind");
        Add(result, new(
            "Consulta y operación de nómina",
            "Revisa el contexto, filtros y estado de los registros del proceso seleccionado.",
            [
                "Selecciona empresa y período cuando la pantalla los solicite.",
                "Busca el registro y revisa los datos antes de continuar con una acción.",
                "Los envíos y autorizaciones disponibles conservan sus permisos y confirmaciones.",
            ],
            null,
            null),
            "/nomina/movimientos",
            "/rh/datormovto",
            "/rh/datosmovto",
            "/nomina/depersonal",
            "/nomina/reportequincenal",
            "/aux/auxcalcissste",
            "/aux/auxcalcisrquincenal",
            "/aux/auxcalcisrmensual",
            "/aux/auxcalcisrsemanal",
            "/aux/auxcalcfovissste",
            "/aux/auxcalcinfonavitquincenal",
            "/aux/auxcalcimssquincenal",
            "/aux/auxcalcimssmensual",
            "/aux/auxcalcimsssemanal",
            "/nom/resumennomina",
            "/nom/resnommen",
            "/nom/recibonomina",
            "/nom/archivodispercion",
            "/nom/archivodispercion__",
            "/nom/timbradopercepciones",
            "/aux/imssquincenal_rep",
            "/aux/imssmensual_rep",
            "/aux/imsssemanal_rep",
            "/nom/reportenomina",
            "/nom/reportenomina_b",
            "/nom/reporteisr_actual_rep",
            "/nom/nomactualquincenal",
            "/nom/nomactualmensual",
            "/rh/liquidacion",
            "/rh/vacaciones",
            "/sis/nominaespecial",
            "/sis/vwnominaespecial",
            "/emp/faltasxempresa",
            "/sis/solicitudvacaciones",
            "/sis/autorizacionvacaciones",
            "/nomina/historicos/consulta",
            "/nomina/historicos/analisis",
            "/nomina/historicos/recibos",
            "/nomina/historicos/dispersion",
            "/nomina/historicos/timbrado",
            "/nomina/historicos/reportequincenal",
            "/nomina/historicos/resumen",
            "/nomina/historicos/reportehistorico",
            "/nomina/historicos/cubo",
            "/nomina/historicos/sbc",
            "/nomina/historicos/acumuladosimss",
            "/nomina/historicos/sbchistorico",
            "/nomina/historicos/acumuladosbimestre",
            "/nomina/historicos/isr_mensual",
            "/nomina/historicos/isr_acumulados",
            "/nomina/historicos/impuestoslocales",
            "/nhis/vwnomhistoricaquincenal",
            "/nhis/vwnomhistoricaquincenal_pivot",
            "/nhis/vwnomhistoricaquincenal_rep",
            "/nhis/dispercion__2",
            "/nhis/timbrado__2",
            "/nhis/nominareport",
            "/nhis/nominareport_b",
            "/nhis/auxcalcimssquincenal_repbim",
            "/nhis/auxcalcimssquincenal_repmens",
            "/nhis/auxcalcisrquincenal_repmens",
            "/nhis/auxcalcisrquincenal_rep",
            "/nhis/sbcbimestral",
            "/nhis/sbc_rep",
            "/rh/configuracion");
        Add(result, new(
            "Captura de conceptos variables",
            "Revisa el empleado, concepto y período de la captura.",
            [
                "Busca el registro en el contexto activo.",
                "Nuevo concepto abre la captura; revisa sus campos antes de guardar.",
                "Los cambios conservan las validaciones y permisos del módulo.",
            ],
            "Nuevo concepto",
            null),
            "/nom/conceptovariable");
        Add(result, new(
            "Captura y revisión de incidencias",
            "Revisa empleado, tipo y fechas de la incidencia.",
            [
                "Localiza el registro con la búsqueda.",
                "Nueva incidencia abre la captura y mantiene las validaciones de fechas y relaciones.",
                "Revisa el estado antes de editar o eliminar.",
            ],
            "Nueva incidencia",
            null),
            "/rh/incidencia");
        Add(result, new(
            "Revisión de la justificación",
            "Consulta la incidencia y su justificación antes de autorizar.",
            [
                "Busca el registro que corresponde revisar.",
                "Editar permite completar los datos disponibles para tu perfil.",
                "Autorizar conserva la confirmación y las validaciones del proceso.",
            ],
            null,
            null),
            "/rh/justificacion");
        Add(result, new(
            "Consulta de incidencias",
            "Revisa los registros y abre el detalle de la incidencia.",
            [
                "Localiza el registro mediante los filtros y búsqueda.",
                "Ver detalle permite consultar sus datos.",
                "La consulta no modifica la incidencia.",
            ],
            null,
            null),
            "/rh/incidenciareport");
        return result;
    }

    private static void Add(Dictionary<string, ScreenGuidance> target, ScreenGuidance guidance, params string[] routes)
    {
        foreach (var route in routes) target.Add(route.Trim('/'), guidance);
    }
}
