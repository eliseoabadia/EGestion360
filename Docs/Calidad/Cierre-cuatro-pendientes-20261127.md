# Validación de los cuatro pendientes — 27 de noviembre de 2026

Entorno exclusivo de desarrollo local. Revisión y validación realizadas por el mismo agente, sin delegación. Cambios aplicados en el proyecto; sin despliegue, commits, push ni respaldos de código. Las pruebas no enviaron correo externo.

## Flujo transaccional de compras

`PurchasingJourneySqlTests` ejecuta los servicios registrados de Application y Business contra SQL Server local. Crea una requisición con una posición presupuestal disponible y solicitante operativo, partida y bien; registra tres proveedores y sus precios; genera suficiencia, autorización y compromiso; autoriza el compromiso; crea orden, detalle y partida; autoriza la orden; recibe el bien; solicita y autoriza su salida; entrega el bien y comprueba la póliza resultante.

Se verificó que la póliza tiene movimientos positivos y cargos iguales a abonos. La transacción exterior se revierte y se comprueba la ausencia de la requisición, orden, solicitud de salida y entrada de almacén de la prueba. Los servicios respetan la propiedad de la transacción: sólo confirman o revierten la que ellos mismos abrieron. El repositorio de envíos incorpora la transacción vigente en sus comandos de lectura.

La prueba usa datos nuevos identificados como técnicos y catálogos existentes legítimos; no clona documentos de negocio ni altera importes presupuestales para superar validaciones. La reversión no implica restaurar los contadores de identidad de SQL Server. No se probaron todas las variantes fiscales, cancelaciones, tipos de contratación ni integraciones externas.

## Separación de responsabilidades

Los controladores conservan contratos de Application. Los servicios de Application delegan las operaciones a Business y Business contiene las consultas, procedimientos y persistencia. Se trasladaron también las familias de catálogos, nómina, presupuesto, contratos, cuentas por pagar, patrimonio y almacén; se conservaron contratos públicos, rutas y modelos generados.

El inventario anterior de 74 archivos no incluía todas las consultas ejecutadas mediante servicios genéricos. Se revisaron también esas familias. El escaneo final de contexto SQL, conexiones, acceso Database y ejecución asíncrona de consultas devuelve **cero candidatos en Application**. Las pruebas compiladas comprueban que sus constructores no reciben contextos SQL/EF, que los controladores no reciben persistencia o Business, que Business no referencia Application y que las dependencias de Business usadas por las fachadas están registradas.

El resultado no significa que Application carezca de toda referencia a tipos de infraestructura: permanecen bases de compatibilidad y tipos genéricos existentes. La condición comprobada es que la ejecución de persistencia reside en Business/Infrastructure. No se presenta el escaneo como revisión manual de cada línea.

## Concurrencia e integridad

`OrderReceiptSqlTests` ejecuta el escritor real de recepción con 16 contextos SQL simultáneos para una orden con capacidad de cinco unidades. **Cinco operaciones se aceptaron y once se rechazaron**, con saldo final de cinco. Empresa incorrecta, ejercicio incorrecto, cantidad negativa, exceso y reversión no dejan incremento de recepción.

La prueba remapea únicamente tres entidades a tablas técnicas vacías con nombre único; no copia documentos existentes. Las elimina al terminar. El escritor actualiza el contador de recepción en una sola sentencia condicionada por saldo, empresa, ejercicio y estado autorizado. Cantidad y fecha de modificación de almacén son tokens de concurrencia mediante configuración manual de EF, sin modificar archivos generados ni el esquema.

Se conserva la prueba real del repositorio de envíos: 16 competidores, un único token ganador, confirmación/rechazo/reenvío/cancelación y lectura desde otra conexión. Estas pruebas cubren esas carreras concretas; no certifican toda operación concurrente de cada módulo.

## Revisión visual nueva y correcciones

El navegador integrado sí estuvo disponible en esta revisión. Se inició sesión con la cuenta de desarrollo autorizada y se comprobó empresa, sucursal, usuario Eliseo Abadia y ejercicio 2026.

- Inicio y panel de Adquisiciones: módulos y ayuda de navegación.
- Cotización: lista y detalle; bienes precargados y acciones principales visibles.
- Orden de compra: lista y detalle; bienes y partidas precargados; acciones de modificación deshabilitadas al estar autorizada; acceso a recepción.
- Recepción: lista de órdenes, selección automática de orden, saldos y estado recibido.
- Requisición: lista y formulario de alta en escritorio y móvil; cierre sin guardar.
- Escritorio de 1440 × 900 y móvil de 390 × 844. En recepción móvil se midieron ancho visible y ancho del documento iguales a 390; el desplazamiento de contenido mantuvo encabezado y pie. Se revisaron los temas Oscuro, Claro y Morena; se restauró Oscuro y se retiró la medida de pantalla temporal.

La revisión detectó y corrigió un bloqueo real del superadministrador: el formulario sólo consultaba sus áreas personales aunque el servidor le permitía actuar por solicitantes operativos. El nuevo catálogo `api/Requisicion/Solicitantes` se obtiene desde Application/Business, exige permiso de requisiciones, deriva usuario y empresa del contexto y conserva el alcance de los usuarios normales. Filtra personas, relaciones y áreas activas. La persona técnica del administrador no figura como solicitante; la prueba SQL también lo comprueba. Se verificó visualmente la selección de área y persona operativa después de compilar y reiniciar.

También se separaron clave y descripción de bien en móvil y se corrigió la ayuda: la orden exige compromiso presupuestal autorizado; el contrato jurídico es un trámite distinto. Las capturas y el DOM de la versión nueva se comprobaron en navegador, no se reutilizó la auditoría visual histórica. Este recorrido no equivale a inspeccionar visualmente las 377 vistas y todos sus diálogos.

Durante el reinicio intencional de API se observaron mensajes controlados de comunicación y menú no disponible. Con la API lista, la recarga recuperó menú, ejercicio y datos. Los errores de consola de esa interrupción no se contabilizan como errores posteriores de consultas o del recorrido SQL.

## Validación final

- Solución completa compilada con SDK .NET 10.
- **487 pruebas aprobadas, cero fallidas y cero omitidas**, con integración SQL habilitada explícitamente.
- Folio de salida demasiado largo rechazado antes de guardar mediante el límite del modelo EF.
- Mensajes de procedimientos sin nombre de aplicación o línea SQL; detalles técnicos conservados en el registro del servidor y mensajes de negocio conservados cuando son seguros.
- Revisión de diferencias sin errores de espacios. Auditoría de calidad del repositorio ejecutada.

## Evidencias

- `Tests/EG.UnidTest/Business/PurchasingJourneySqlTests.cs`
- `Tests/EG.UnidTest/Business/OrderReceiptSqlTests.cs`
- `Tests/EG.UnidTest/Business/StoredProcedureMessageTests.cs`
- `Tests/EG.UnidTest/Architecture/ControllerLayerTests.cs`
- `Tests/EG.UnidTest/ApiCoreBS/PurchasingReadPermissionTests.cs`
- `tmp/quality-integrated/integrated-20261127-final.trx`
- `tmp/quality-integrated/architecture-20261127.json`

## Carga de la compilación final

Se repitió la medición después de terminar compilaciones y pruebas SQL. Cinco consultas paginadas autenticadas: requisiciones, órdenes, pólizas, bienes y empleados. Cada etapa duró 30 segundos y cada lector esperó un segundo entre consultas.

| Lectores virtuales | Consultas | Errores | Consultas/s | p95 | p99 |
|---:|---:|---:|---:|---:|---:|
| 40 | 1,193 | 0 | 38.49 | 20 ms | 29 ms |
| 80 | 2,370 | 0 | 76.45 | 22 ms | 30 ms |
| 160 | 4,752 | 0 | 153.20 | 26 ms | 36 ms |
| 200 | 5,901 | 0 | 190.74 | 25 ms | 33 ms |

Las 72 muestras SQL tuvieron máximo de cero solicitudes bloqueadas, cero de más de cinco segundos y delta cero del contador de deadlocks del servidor. El muestreo no descarta bloqueos breves entre observaciones.

Son lectores virtuales que comparten un perfil autenticado, no 200 cuentas distintas ni una mezcla de escrituras, reportes y trabajos de fondo. Se alcanzó el límite configurado del ejecutor; no se midió el máximo de capacidad ni se extrapola a producción. Los resultados anteriores, incluida la primera etapa con timeouts, permanecen en el informe del 26 de noviembre.

Después de la carga se verificaron consultas HTTP de requisición, cotización, orden, almacén, solicitud de salida, póliza, bien y empleado: todas devolvieron éxito. Almacén y salida recibieron el filtro de ejercicio exigido por su contrato; se comprobó también que omitirlo produce YEAR_REQUIRED, una validación controlada. La consulta autorizada de solicitantes devolvió datos y la anónima HTTP 401. Portal y las ocho rutas JavaScript de arranque distintas del manifiesto vigente devolvieron HTTP 200.

Evidencia adicional:

- `tmp/capacity-dev/capacity-layer-final-20261127.json`
- `tmp/capacity-dev/resources-layer-final-20261127.json`
- `tmp/quality-integrated/api-20261127-final.json`
- `tmp/quality-integrated/portal-assets-20261127.json`
- `tmp/quality-integrated/summary-20261127.json`

## Estado de cierre

Los cuatro pendientes quedan completados para el alcance de desarrollo descrito: recorrido real de compras hasta contabilidad, separación de persistencia de Application, concurrencia de recepción/envíos y medición de lectores, y revisión visual nueva de las pantallas principales de compras. API y portal permanecen ejecutándose con la compilación final. Los límites indicados no se sustituyen por una certificación global de todas las pantallas, carreras posibles o capacidad de producción.
