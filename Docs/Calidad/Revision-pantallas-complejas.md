# Revisión de pantallas complejas

## Orientación operativa transversal

Se incorporó `NextTaskPanel` a PageHeader, OperationActionPanel, ProcessAssistancePanel y BaseCrudDialog. Responde “Qué sigue”, “Quién lo hace” y “Qué puedes hacer tú”. Los encabezados sin diagnóstico específico ofrecen orientación de consulta/captura; cuando se desconoce el responsable, lo dicen expresamente en lugar de inventarlo. La orientación de listas no atribuye un estado a sus registros. Los formularios distinguen consulta de captura sin confundir un formulario inválido con falta de permisos.

El inventario encontró 305 archivos Razor consumidores de estos componentes; ese número expresa alcance estructural, no 305 pantallas comprobadas visualmente. En encabezados con guía existente se usa su panel de acciones y se evita un segundo bloque genérico. Las páginas con composición propia requieren todavía la revisión individual del inventario.

En cotizaciones se diferencia la ausencia de bienes de la revisión de precios; en órdenes se distingue captura de consulta de recepciones; en suficiencias se distingue revisión, bloqueo por autorización en curso y estado autorizado. El paso posterior no se presenta como disponible por el solo hecho de tener suficiencia: debe comprobarse el compromiso. Los botones conservan permisos, condiciones y callbacks existentes; no se crean acciones externas.

Se creó el skill global `eae-ux-siguiente-paso` en la carpeta personal de skills del usuario, independiente del repositorio y de la tecnología. Incluye instrucciones para estados confirmados/parciales/por verificar, responsabilidades, permisos, modales sin pérdida de contexto y verificación visual. Se revisaron metadatos y estructura; el validador oficial Python no pudo ejecutarse porque el intérprete no está disponible en este equipo.

## Patrón aplicado

Se incorporó `ContextSummaryDialog` como componente compartido para resúmenes secundarios. Mantiene botón de acceso, cierre, Escape y tamaño adaptable mediante MudDialog. Conserva los datos originales y deja un indicador principal visible cuando el resumen del listado se contrae. Los textos compartidos del componente están en Common.

No se sustituyen tablas, búsquedas, columnas, exportaciones, paginación, permisos ni operaciones. Los modales muestran el contenido ya consultado; no agregan peticiones al servidor. Las acciones principales y los diagnósticos del proceso permanecen visibles.

## Inventario de esta intervención

| Familia | Pantallas | Cambio aplicado | Estado |
|---|---|---|---|
| Compras | Requisiciones | Contexto detallado en modal; área e importe visibles | Implementada; revisión visual pendiente |
| Compras | Cotizaciones | Resumen de lista y contexto de detalle en modal; bienes e importe visibles | Implementada; revisión visual pendiente |
| Compras | Orden de compra | Resumen de lista y contexto de detalle en modal; fecha e importe visibles | Implementada; revisión visual pendiente |
| Compras | Solicitudes de suficiencia | Indicador principal visible y resto del resumen en modal | Implementada; revisión visual pendiente |
| Almacén | Suministros, solicitudes de salida, entradas por ajuste, salidas por ajuste, existencias registradas | Indicador principal visible y resto del resumen en modal | Implementadas; revisión visual pendiente |
| Patrimonio | Bienes, bajas, calendario de inventarios, inventarios, resguardos, firma de resguardos | Indicador principal visible y resto del resumen en modal | Implementadas; revisión visual pendiente |
| Presupuesto | Investigación de mercado, anteproyecto de egresos, solicitud de suficiencia presupuestal | Indicador principal visible y resto del resumen en modal | Implementadas; revisión visual pendiente |
| Nómina | Conceptos variables | Indicador principal visible y resto del resumen en modal | Implementada; revisión visual pendiente |

Total: 19 pantallas que consumen el componente. La pantalla de recepción mantiene los ajustes previos de compactación y resumen modal.

## Segunda pasada: acciones y ayuda contextual

Se añadió un modo compacto optativo a `OperationActionPanel`. Conserva título, descripción y acciones existentes; reduce el espacio del encabezado y abre la guía rápida en modal, evitando que su consulta desplace las tablas. Las pantallas que no habilitan el modo conservan el comportamiento anterior.

Modo activado en cotización, orden de compra, solicitudes de suficiencia de Compras y Presupuesto, solicitudes y suministros de salida de almacén, bajas, resguardos, inventarios e investigación de mercado: diez pantallas.

En requisiciones, el asistente muestra directamente la siguiente acción calculada, el responsable y el estado. La explicación ampliada y la ruta de menú se consultan en “Detalle del proceso”. Los botones para ejecutar la acción y avisar al responsable conservan sus eventos y condiciones; no se añadió ningún envío automático.

Esta segunda pasada cubre presentación de acciones y ayuda. No equivale a terminar la revisión individual de todos los formularios, cálculos y reportes del plan general. La verificación visual de los cambios sigue pendiente.

## Pendientes del plan general

### Seguimiento solicitado en el resumen de requisición

Se añadió un flujo informativo de nueve pasos: requisición, cotización, suficiencia autorizada, compromiso autorizado, orden de compra, recepción, factura, provisión/CLC y cheque. Muestra palomita cuando el criterio del paso está comprobado, círculo pendiente o recepción parcial. No incluye enlaces, por indicación del usuario; su eventual navegación deberá respetar los permisos de cada destino.

Business obtiene los documentos por relaciones reales y con empresa/ejercicio del contexto. Factura y CLC se vinculan mediante el compromiso presupuestal, su autorización y la solicitud de suficiencia de la requisición. Cheque se vincula mediante CLC. El recorrido se consulta al obtener el detalle de una requisición, no por cada fila del listado. Los documentos de la misma etapa pueden tener estados y montos diferentes; la existencia no certifica liquidación total ni cheque cobrado.

La prueba SQL del recorrido completo pasó con comprobaciones de las seis primeras etapas realizadas, las tres últimas pendientes y ausencia de resultados al cambiar empresa o ejercicio. No crea factura o cheque para simular pago. Todos los documentos de prueba se revierten al terminar. La comprobación visual permanece pendiente mientras no exista acceso al navegador de pruebas.

La aplicación del patrón de resumen no completa por sí sola la revisión de cada pantalla. Quedan la comprobación visual de esta intervención en escritorio, panel estrecho, móvil y temas; la revisión individual de formularios y acciones de las familias; y la evaluación específica de autorizaciones/compromisos, pólizas, cálculos de nómina, usuarios/permisos y reportes complejos. No se marcan como verificados por similitud o por compilación.

La validación de compilación se realiza sin copiar los binarios que mantiene bloqueados Visual Studio. Se requiere recompilar con la aplicación detenida para ejecutar y revisar la versión nueva. No se realizaron despliegues, commits, push ni respaldos.

Comprobación realizada: `MSBuild.dll FrontEnd/EG.Web/EG.Web.csproj -t:Compile` con SDK 10.0.404 terminó con código cero. Las diferencias pasaron la revisión de espacios. No se ejecutaron nuevas pruebas de negocio porque esta intervención sólo compone presentación existente.

Se intentó abrir el navegador para la comprobación visual; la herramienta informó que el acceso al navegador local no está disponible en este chat. Por ello se conserva explícitamente el estado de revisión visual pendiente.
