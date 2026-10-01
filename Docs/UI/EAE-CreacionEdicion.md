# Creación y edición · EAE compacto

Fecha: 30 de septiembre de 2026. Proyecto: EGestion360.

## Alcance

Se aplicó el skill eae-diseno-compacto y las convenciones EAE a los editores de alta y modificación. Se consultaron el editor de Usuarios y los estilos EAE de GE.UNI360. El editor de Usuarios adopta esa composición conservando íntegro su bloque de código local. No se cambiaron contratos, servicios de negocio, permisos ni base de datos.

- BaseCrudDialog: encabezado compacto, contexto de alta/actualización y cierre accesible; acciones en DialogActions, fuera del cuerpo desplazable. Se contempla el contenedor real mud-focus-trap de MudBlazor 9.6.
- BaseEntityForm y CrudFormSection: paneles con títulos, bordes del tema y rejillas adaptables; controles nativos con Margin.Dense.
- eae-forms.css: presentación compartida y limitada a los editores. Se retiraron reglas antiguas del pie y paneles; la heurística anterior de anchura se excluye de los formularios nuevos.
- Nómina y PBR: se agrupa la lista efectiva Fields/EditableProperties; hasta cuatro campos conservan la presentación sencilla. Los bucles mensuales permanecen completos.
- Usuarios: identidad, datos de persona y asignaciones; las columnas se apilan según el ancho del cuerpo y se conservan las pestañas independientes.

## Verificación

- Compilación final de EG.Web (net10.0): correcta, cero errores y cero advertencias.
- Comparación de 128 componentes modificados: mismos controles, bindings, validadores, eventos y bloques de código de dominio; únicamente varía su presentación.
- Navegador Edge con componentes reales en un host temporal y servicios simulados: 128 escenarios, sin desbordamiento horizontal del cuerpo, acciones visibles antes y después del desplazamiento y sin errores JavaScript.
- Familias: Artículo, Persona, Empleado, Usuario, Tabla fiscal, renderer PBR, distribución mensual y Menú. Alta/edición, temas claro/oscuro, 1440×900, 768×1024, 390×844 y 1440×600.
- Tabla fiscal: error junto al campo requerido, formulario abierto tras rechazo simulado y botón Guardar disponible para reintentar.
- Revisión adicional: 48 observaciones de Usuarios con persona vinculada y pestañas, Entidades y Proveedores; alta/edición, ambos temas y anchos 1440, 768 y 390 px.

Estas son pruebas por familias con datos simulados. No se realizaron escrituras reales, pruebas de permisos contra el backend ni una revisión individual en navegador de cada catálogo. Las restantes pantallas del inventario quedan verificadas por compilación y comparación de código; sus estados particulares de negocio requieren una sesión de aceptación con datos autorizados.

## Inventario

129 editores. La columna de campos cuenta controles declarados de captura/consulta; en las pantallas condicionales no todos aparecen simultáneamente. No se cuentan filtros ni celdas de las tablas de asignación como campos del formulario de Usuarios. Los renderers se cuentan por sus listas efectivas y los meses se expanden a doce. Se revisan alta y edición en el mismo componente.

| Editor (relativo a Pages) | Campos | Estado / composición |
| --- | --- | --- |
| Modules/GRP/Adquisiciones/Contratos/EstadoContratoDialog.razor | 15 | Adaptado: paneles explícitos · Contrato y referencias; Vigencia e importe; Observaciones |
| Modules/GRP/Adquisiciones/Contratos/RegistroCompromisoDialog.razor | 28 | Adaptado: paneles explícitos · Origen del compromiso; Clasificación del contrato; Importes y vigencia; Fundamento y sesiones |
| Modules/GRP/Adquisiciones/CotizacionDetalleDialog.razor | 2 | Compacto; sin paneles adicionales |
| Modules/GRP/Adquisiciones/CotizacionDialog.razor | 10 | Adaptado: paneles explícitos · Solicitud y proveedor; Fechas de cotización; Condiciones de entrega |
| Modules/GRP/Adquisiciones/OrdenCompraDetalleDialog.razor | 10 | Adaptado: paneles explícitos · Bien o servicio; Cantidades e importes |
| Modules/GRP/Adquisiciones/OrdenCompraDialog.razor | 14 | Adaptado: paneles explícitos · Orden y referencias; Fechas de entrega; Moneda y condiciones |
| Modules/GRP/Adquisiciones/OrdenCompraPartidaDialog.razor | 4 | Compacto; sin paneles adicionales |
| Modules/GRP/Adquisiciones/PaaaDialog.razor | 8 | Adaptado: paneles explícitos · Datos del programa; Asignación presupuestal |
| Modules/GRP/Adquisiciones/PaaasDetalleDialog.razor | 6 | Adaptado: paneles explícitos · Bien y programación; Entrega |
| Modules/GRP/Adquisiciones/PaaasPartidaDialog.razor | 2 | Compacto; sin paneles adicionales |
| Modules/GRP/Adquisiciones/RequisicionDetalleDialog.razor | 6 | Adaptado: paneles explícitos · Origen y bien solicitado; Cantidad y observaciones |
| Modules/GRP/Adquisiciones/RequisicionDialog.razor | 19 | Ya estructurado; densidad y tema actualizados |
| Modules/GRP/Adquisiciones/RequisicionPartidaDialog.razor | 4 | Compacto; sin paneles adicionales |
| Modules/GRP/Adquisiciones/SolicitudSuficienciaDetalleDialog.razor | 13 | Ya estructurado; densidad y tema actualizados |
| Modules/GRP/Adquisiciones/SolicitudSuficienciaDialog.razor | 8 | Adaptado: paneles explícitos · Solicitud y estado; Clasificación y justificación |
| Modules/GRP/Almacen/AlmacenDialog.razor | 13 | Adaptado: paneles explícitos · Entrada y ubicación; Cantidad y recepción; Referencias del ingreso |
| Modules/GRP/Almacen/DetalleSolicitudSalidaDialog.razor | 8 | Adaptado: paneles explícitos · Bien solicitado; Cantidades; Observaciones |
| Modules/GRP/Almacen/MisPeriodos/ConteoDialog.razor | 6 | Adaptado: paneles explícitos · Datos del conteo; Cantidad y periodo |
| Modules/GRP/Almacen/SalidaAjusteDialog.razor | 10 | Adaptado: paneles explícitos · Salida y motivo; Existencia e importe; Referencias |
| Modules/GRP/Almacen/SolicitudSalidaDialog.razor | 9 | Adaptado: paneles explícitos · Solicitud y responsables; Fechas y justificación |
| Modules/GRP/Configuration/Catalogos/Adquisicion/ArticuloDialog.razor | 2 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Adquisicion/EstatusRequisicionDialog.razor | 4 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Adquisicion/FraccionDialog.razor | 3 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Adquisicion/ModalidadDialog.razor | 1 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Adquisicion/ProcedimientoContratacionDialog.razor | 2 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Adquisicion/ProveedorDialog.razor | 19 | Ya estructurado; densidad y tema actualizados |
| Modules/GRP/Configuration/Catalogos/Adquisicion/TipoContratoDialog.razor | 1 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Adquisicion/TipoDocumentoDialog.razor | 1 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Adquisicion/TipoGarantiaDialog.razor | 1 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Almacen/EstatusSolicitudDialog.razor | 2 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Almacen/MotivoEsDialog.razor | 3 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Almacen/PeriodoConteoDialog.razor | 11 | Adaptado: paneles explícitos · Identificación del periodo; Responsables del conteo; Periodo y supervisión |
| Modules/GRP/Configuration/Catalogos/Almacen/PlanConteoCiclicoDialog.razor | 4 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Almacen/UnidadesDialog.razor | 1 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/ClavePrograma/FuncionDialog.razor | 3 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/ClavePrograma/GrupoFuncionalDialog.razor | 2 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/ClavePrograma/SubFuncionDialog.razor | 3 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Contabilidad/ConceptoDialog.razor | 2 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Contabilidad/CuentaContableDialog.razor | 2 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Contabilidad/FormaPagoDialog.razor | 1 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Contabilidad/MatrizConversionDialog.razor | 11 | Ya estructurado; densidad y tema actualizados |
| Modules/GRP/Configuration/Catalogos/Contabilidad/MatrizIngresoDialog.razor | 8 | Ya estructurado; densidad y tema actualizados |
| Modules/GRP/Configuration/Catalogos/Contabilidad/TipoDetallePolizaDialog.razor | 1 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Contabilidad/TipoPolizaDialog.razor | 1 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Patrimonio/FamiliaDialog.razor | 2 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Patrimonio/GrupoBienDialog.razor | 7 | Adaptado: paneles explícitos · Identificación del grupo; Clasificación y medida |
| Modules/GRP/Configuration/Catalogos/Patrimonio/MarcaDialog.razor | 1 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Patrimonio/PersonaDialog.razor | 7 | Adaptado: paneles explícitos · Datos personales; Identificadores y contacto |
| Modules/GRP/Configuration/Catalogos/Patrimonio/TipoAdquisicionDialog.razor | 3 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Patrimonio/TipoBienDialog.razor | 20 | Adaptado: paneles explícitos · Información General; Unidades y Medidas; Financiero y Control |
| Modules/GRP/Configuration/Catalogos/Patrimonio/TipoPatrimonioDialog.razor | 1 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Presupuestales/ActividadInstitucionalDialog.razor | 2 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Presupuestales/AniosDialog.razor | 2 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Presupuestales/FuenteFinanciamientoDialog.razor | 2 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Presupuestales/PgDialog.razor | 2 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Presupuestales/ProgramaDialog.razor | 12 | Ya estructurado; densidad y tema actualizados |
| Modules/GRP/Configuration/Catalogos/Presupuestales/ProgramaPresupuestalDialog.razor | 2 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Presupuestales/ProyectoDialog.razor | 2 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Presupuestales/RamoDialog.razor | 2 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Presupuestales/SectorDialog.razor | 2 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Presupuestales/TipoRecursoDialog.razor | 2 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Presupuestales/UnidadResponsableDialog.razor | 2 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Tesoreria/TipoCambioDialog.razor | 3 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Tesoreria/TipoDoctoClcDialog.razor | 3 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Tesoreria/TipoInversionDialog.razor | 1 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Tesoreria/TipoMonedaDialog.razor | 5 | Adaptado: paneles explícitos · Identificación de la moneda; Representación |
| Modules/GRP/Configuration/Catalogos/Tesoreria/TipoPagoDialog.razor | 1 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Tesoreria/TipoPagoSFDialog.razor | 1 | Compacto; sin paneles adicionales |
| Modules/GRP/Configuration/Catalogos/Tesoreria/TipoSolicitudCLCDialog.razor | 1 | Compacto; sin paneles adicionales |
| Modules/GRP/Contabilidad/PolizaDetalleDialog.razor | 5 | Adaptado: paneles explícitos · Cuenta y concepto; Importes |
| Modules/GRP/Contabilidad/PolizaDialog.razor | 9 | Adaptado: paneles explícitos · Periodo y tipo; Datos contables; Control |
| Modules/GRP/Patrimonio/BajaDialog.razor | 14 | Adaptado: paneles explícitos · Bien y solicitud de baja; Referencias y destinatario; Motivo y sustento |
| Modules/GRP/Patrimonio/BienDialog.razor | 21 | Adaptado: paneles explícitos · Identificación del bien; Características; Adquisición y valores |
| Modules/GRP/Patrimonio/CalendarioInventarioDialog.razor | 7 | Adaptado: paneles explícitos · Calendario y área; Periodo y descripción |
| Modules/GRP/Patrimonio/InventarioDetalleDialog.razor | 8 | Adaptado: paneles explícitos · Inventario y bien; Ubicación y verificación |
| Modules/GRP/Patrimonio/InventarioDialog.razor | 9 | Adaptado: paneles explícitos · Inventario y calendario; Responsable y observaciones |
| Modules/GRP/Patrimonio/ResguardoDetalleDialog.razor | 3 | Compacto; sin paneles adicionales |
| Modules/GRP/Patrimonio/ResguardoDialog.razor | 5 | Adaptado: paneles explícitos · Asignación del resguardo; Fecha y observaciones |
| Modules/GRP/Presupuesto/Egreso/InvestigacionMercadoDetalleDialog.razor | 4 | Compacto; sin paneles adicionales |
| Modules/GRP/Presupuesto/Egreso/InvestigacionMercadoDialog.razor | 6 | Adaptado: paneles explícitos · Datos del estudio; Responsable y seguimiento |
| Modules/GRP/Presupuesto/Egreso/Planeacion/AnteproyectoEgresosDialog.razor | 22 | Adaptado: paneles explícitos · Datos del anteproyecto; Clasificación presupuestal; Distribución mensual |
| Modules/GRP/Presupuesto/Egreso/Planeacion/PresupuestoAutorizadoDialog.razor | 21 + 12 meses | Adaptado: paneles explícitos · Posición presupuestal; Datos del presupuesto; Distribución mensual; Distribución mensual |
| Modules/GRP/Presupuesto/Egreso/PresupuestoComprometido/AutorizacionSuficienciaDetalleDialog.razor | 4 + 12 meses | Adaptado: paneles explícitos · Origen presupuestal; Distribución mensual |
| Modules/GRP/Presupuesto/Egreso/PresupuestoComprometido/AutorizacionSuficienciaDialog.razor | 8 | Adaptado: paneles explícitos · Origen y autorización; Clasificación y observaciones |
| Modules/GRP/Presupuesto/Egreso/PresupuestoComprometido/ContratoDetalleDialog.razor | 4 + 12 meses | Adaptado: paneles explícitos · Origen presupuestal; Distribución mensual |
| Modules/GRP/Presupuesto/Egreso/PresupuestoComprometido/ContratoDialog.razor | 13 | Adaptado: paneles explícitos · Contrato y referencias; Vigencia e importe |
| Modules/GRP/Presupuesto/Egreso/PresupuestoModificado/PresupuestoModificadoDetalleDialog.razor | 4 + 12 meses | Adaptado: paneles explícitos · Origen y movimiento; Distribución mensual |
| Modules/GRP/Presupuesto/Egreso/PresupuestoModificado/PresupuestoModificadoDialog.razor | 3 | Compacto; sin paneles adicionales |
| Modules/GRP/Presupuesto/Tesoreria/CuentasXCobrar/DepositoDialog.razor | 22 | Adaptado: paneles explícitos · Referencia del depósito; Registro contable; Distribución mensual |
| Modules/GRP/Presupuesto/Tesoreria/CuentasXCobrar/IngresoAutorizadoDialog.razor | 20 | Adaptado: paneles explícitos · Origen del ingreso; Clasificación presupuestal; Distribución mensual |
| Modules/GRP/Presupuesto/Tesoreria/CuentasXCobrar/ModificadoIngreso/ModificadoIngresoDetalleDialog.razor | 4 + 12 meses | Adaptado: paneles explícitos · Origen y movimiento; Distribución mensual |
| Modules/GRP/Presupuesto/Tesoreria/CuentasXCobrar/ModificadoIngreso/ModificadoIngresoDialog.razor | 3 | Compacto; sin paneles adicionales |
| Modules/GRP/Presupuesto/Tesoreria/CuentasXPagar/ChequeDialog.razor | 9 | Adaptado: paneles explícitos · Origen y cuenta bancaria; Emisión y pago |
| Modules/GRP/Presupuesto/Tesoreria/CuentasXPagar/ChequePartidaDialog.razor | 5 | Adaptado: paneles explícitos · Origen presupuestal; Aplicación del pago |
| Modules/GRP/Presupuesto/Tesoreria/CuentasXPagar/CLCDetalleDialog.razor | 4 + 12 meses | Adaptado: paneles explícitos · Origen presupuestal; Distribución mensual |
| Modules/GRP/Presupuesto/Tesoreria/CuentasXPagar/CLCDialog.razor | 8 | Adaptado: paneles explícitos · Datos de la CLC; Fechas e importe |
| Modules/GRP/Presupuesto/Tesoreria/CuentasXPagar/CLCFacturaDialog.razor | 5 | Adaptado: paneles explícitos · Factura de origen; Aplicación |
| Modules/GRP/Presupuesto/Tesoreria/CuentasXPagar/FacturaDetalleDialog.razor | 5 | Adaptado: paneles explícitos · Origen presupuestal; Aplicación |
| Modules/GRP/Presupuesto/Tesoreria/CuentasXPagar/FacturaDialog.razor | 14 | Adaptado: paneles explícitos · Factura y contrato; Fechas; Importes; Identificación fiscal y estado |
| Modules/GRP/Presupuesto/Tesoreria/Inversiones/BancoDialog.razor | 3 | Compacto; sin paneles adicionales |
| Modules/GRP/Presupuesto/Tesoreria/Inversiones/CuentaBancariaDialog.razor | 9 | Adaptado: paneles explícitos · Banco y cuenta; Saldos y apertura |
| Modules/GRP/Presupuesto/Tesoreria/Inversiones/InstrumentoInversionDialog.razor | 11 | Adaptado: paneles explícitos · Datos del instrumento; Condiciones y vigencia |
| Modules/GRP/Presupuesto/Tesoreria/Inversiones/IntermediarioFinancieroDialog.razor | 4 | Compacto; sin paneles adicionales |
| Modules/GRP/Presupuesto/Tesoreria/Inversiones/InversionContabilidadDialog.razor | 6 | Adaptado: paneles explícitos · Registro contable; Importes |
| Modules/GRP/Presupuesto/Tesoreria/Inversiones/InversionDialog.razor | 5 | Adaptado: paneles explícitos · Cuenta e instrumento; Importe y vigencia |
| Modules/GRP/Presupuesto/Tesoreria/Inversiones/InversionInteresDialog.razor | 2 | Compacto; sin paneles adicionales |
| Modules/GRP/Presupuesto/Tesoreria/Inversiones/InversionRetiroDialog.razor | 3 | Compacto; sin paneles adicionales |
| Modules/GRP/Presupuesto/Tesoreria/Inversiones/TipoPlazoDialog.razor | 2 | Compacto; sin paneles adicionales |
| Modules/GRP/Presupuesto/Tesoreria/Inversiones/TipoRetiroDialog.razor | 1 | Compacto; sin paneles adicionales |
| Modules/Nomina/Configuration/Catalogos/NomCatalogoSimpleDialog.razor | Según Fields / EditableProperties | Adaptado: grupos por campos visibles · @fieldGroup.Title |
| Modules/Nomina/Configuration/Catalogos/NominaCatalogDialog.razor | Según Fields / EditableProperties | Adaptado: grupos por campos visibles · @fieldGroup.Title |
| Modules/Nomina/Configuration/Catalogos/NomTablaFiscalDialog.razor | Según Fields / EditableProperties | Adaptado: grupos por campos visibles · @fieldGroup.Title |
| Modules/Nomina/Nomina/Incidencias/IncidenciasDialog.razor | 8 | Ya estructurado; densidad y tema actualizados |
| Modules/Nomina/Nomina/Incidencias/JustificacionIncidenciasDialog.razor | 4 | Ya estructurado; densidad y tema actualizados |
| Modules/Nomina/Nomina/Incidencias/NominaRhIncidenciaDialog.razor | 7 | Ya estructurado; densidad y tema actualizados |
| Modules/Nomina/Nomina/PagosExtraordinarios/ConceptosVariablesDialog.razor | 5 | Adaptado: paneles explícitos · Concepto e importe |
| Modules/Nomina/RH/NominaRhContratoDialog.razor | 9 | Adaptado: paneles explícitos · Identificación y vigencia; Asignación laboral |
| Modules/Nomina/RH/NominaRhDependienteDialog.razor | 4 | Compacto; sin paneles adicionales |
| Modules/Nomina/RH/NominaRhEmpleadoDialog.razor | 35 | Adaptado: paneles explícitos · Identificacion; Documentos de identidad; Contacto y domicilio; Datos laborales y pago |
| Modules/Nomina/RH/NominaRhExpedienteDialog.razor | 6 | Adaptado: paneles explícitos · Documento del expediente; Fechas y descripción |
| Modules/Nomina/RH/NominaRhPensionDialog.razor | 12 | Adaptado: paneles explícitos · Beneficiario y pensión; Sustento y vigencia; Datos bancarios |
| Modules/PBR/Shared/PbrCrudDialog.razor | Según Fields / EditableProperties | Adaptado: grupos por campos visibles · @fieldGroup.Title |
| Platform/Sistema/Departamento/DepartamentoDialog.razor | 4 | Compacto; sin paneles adicionales |
| Platform/Sistema/Empresa/EmpresaDialog.razor | 18 | Adaptado: paneles explícitos · Identidad de la entidad; Ubicación y apertura |
| Platform/Sistema/Menu/CrearMenu.razor | 5 | Adaptado: paneles explícitos · Nombre y navegación; Presentación y validación |
| Platform/Sistema/Menu/EditarMenu.razor | 5 | Adaptado: paneles explícitos · Nombre y navegación; Presentación y validación |
| Platform/Sistema/Sucursal/SucursalDialog.razor | 14 | Adaptado: paneles explícitos · Entidad e identificación; Contacto y domicilio; Estado de la sucursal |
| Platform/Sistema/Usuario/UsuarioDialog.razor | Por pestaña, persona y asignaciones | Agrupación existente conservada |
| Shared/DeleteDialog.razor | 0 | Compacto; sin paneles adicionales |

## No aplicables a este cambio

Login, Perfil, confirmaciones de baja, selección de sucursal, consulta de bitácora, soporte documental, reportes y vistas de sólo lectura. Los asistentes de importación y capturas masivas (IA de pólizas/anteproyectos, recepción de cotizaciones, selector de bienes y constructor de investigación) conservan su estructura especializada de tablas; no se convirtieron a formularios CRUD ni se modificaron sus operaciones.

## Evidencia

Los resultados estructurados y las capturas representativas se encuentran en output/eae-compacto-20260930. El host de revisión y sus servicios simulados fueron temporales y no se integran al frontend de producción.
