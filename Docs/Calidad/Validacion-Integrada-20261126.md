# Validación integrada del plan — 26 de noviembre de 2026

Entorno: desarrollo local. Revisión realizada por el mismo agente, por indicación del usuario, sin delegar en otra IA. No hubo despliegue, commits, push, respaldos de código ni envíos de correo reales.

## 1. Diagnóstico y estado de los siete puntos

| Punto | Trabajo comprobado | Estado y límite |
|---|---|---|
| 1. Seguridad | Identidad estricta, alcance de empresa, permisos de lectura, auditoría de rechazos, errores controlados y rutas documentales. Se repitieron 14 consultas directas contra la API final. | Correcciones aplicadas y verificadas en este alcance; no es certificación de todos los endpoints. |
| 2. Flujos completos | Pruebas de validación y transporte de errores; ejecución del flujo persistente de envío, rechazo, reenvío, cancelación y recarga; protección de correos inciertos en cotizaciones y estudios de mercado. | Verificación del mecanismo compartido terminada. Sigue pendiente ejecutar el recorrido completo de un documento nuevo: requisición → cotización → orden → recepción → contabilización, con sus efectos reales y datos de prueba aislados. |
| 3. Concurrencia | 16 conexiones simultáneas disputaron el mismo envío: exactamente una obtuvo el token. Un token incorrecto o anterior no completó ni canceló otro envío. Se comprobó el estado al recargar desde otra conexión. | Comprobado para el repositorio real de envíos. No equivale a verificar todas las carreras de existencias, importes o autorizaciones de cada módulo. |
| 4. Arquitectura | Soporte documental sigue controller → Application → Business → SQL/archivos. Application impone empresa e identidad del contexto. El alcance de ejercicio de órdenes reside en Business. | Refactorización aplicada en esas responsabilidades. El inventario conserva 74 archivos de Application candidatos a revisar por referencias a persistencia; no se declara terminada la separación global. |
| 5. Vistas | Se comprobó entrega HTTP del portal y seis rutas de recursos de arranque del manifiesto vigente. | La revisión visual nueva quedó bloqueada: el navegador integrado no estuvo disponible y la herramienta de Windows se detuvo al no poder verificar la URL. No se reutiliza una revisión anterior como evidencia de los cambios nuevos. |
| 6. Carga | Repetición final con 160 y 200 lectores virtuales, cinco consultas paginadas autenticadas y muestreo SQL. | Completada para ese patrón de lectura. No mide usuarios distintos, escrituras, reportes pesados ni capacidad máxima de producción. |
| 7. Autovalidación | Segunda pasada sobre el recorrido y los cambios: encontró y corrigió permisos de lectura ausentes, límite de rutas, alcance de ejercicio y liberación insegura de envíos de correo. | Completada para los cambios de esta revisión; no se presenta como auditoría independiente externa. |

## 2. Hallazgos y correcciones

| Prioridad | Hallazgo confirmado | Resultado |
|---|---|---|
| Alta | Una selección de empresa rechazada podía sustituirse por la empresa del token. | Rechazo antes del controlador; la empresa del token también se valida contra el acceso vigente. |
| Alta | Identificadores mezclados con texto o claims contradictorios podían producir una identidad numérica. | Lectura estricta y compartida de identidad en Common. |
| Alta | Lecturas de cotizaciones, órdenes y recepción sólo exigían autenticación. | Trece acciones requieren ahora el permiso de lectura de su módulo; políticas compartidas en Common. Tres consultas directas con identidad técnica sin permisos devolvieron 403. |
| Alta | El filtro de año de la vista de órdenes dependía del filtro enviado por el cliente. | El servicio de lectura de Business agrega siempre empresa y ejercicio antes de contar, paginar, consultar por clave o exportar. Se retiró la duplicación del mismo predicado en Application. |
| Alta | La validación de rutas aceptaba un prefijo de carpeta, sin comprobar el separador. | La ruta normalizada debe permanecer dentro del directorio configurado; rutas absolutas, superiores o de carpetas vecinas se rechazan. |
| Alta | Una entrega SMTP seguida de un fallo SQL podía liberar el envío y permitir duplicarlo. | Cotizaciones y estudios de mercado reutilizan WorkflowEmailDelivery. Sólo un rechazo VALIDATION anterior al envío libera el token. Una entrega incierta o un fallo de confirmación conserva PROCESANDO para revisión; no se reenvía automáticamente. |
| Media | Validaciones de empresa y año hacían consultas síncronas en la solicitud HTTP. | Inicialización asíncrona antes del controlador y reutilización del contexto dentro de la petición. Las cancelaciones del cliente no se convierten en error 500. |
| Media | Persistencia documental implementada en Application. | Trasladada a Business; la fachada de Application conserva el contrato y vuelve a imponer identidad y empresa. |

Un envío incierto requiere comprobar la entrega y reconciliar su estado antes de desbloquearlo. No se añadió una liberación automática que pudiera duplicar mensajes.

## 3. Rendimiento medido

La primera pasada de 30 segundos por nivel pasó hasta 160 lectores, pero el nivel de 200 produjo 173 fallos de 5,005 solicitudes, con timeouts de 15 segundos. Esa evidencia se conserva: no se sustituye por la repetición exitosa.

Tras la inicialización asíncrona, reinicio y una repetición sin compilaciones simultáneas, se observaron estos resultados en etapas de 45 segundos:

| Lectores virtuales | Solicitudes | Fallos | Solicitudes/s | p95 | p99 |
|---:|---:|---:|---:|---:|---:|
| 160 | 7,046 | 0 | 153.55 | 40 ms | 62 ms |
| 200 | 8,819 | 0 | 191.67 | 49 ms | 76 ms |

Las 55 muestras SQL, tomadas cada dos segundos, tuvieron máximo de cero solicitudes bloqueadas, cero solicitudes de más de cinco segundos y delta de cero en el contador de deadlocks del servidor. El muestreo no descarta bloqueos breves entre muestras.

Los lectores compartieron una cuenta autenticada y rotaron requisiciones, órdenes, pólizas, bienes y empleados, con pausa de un segundo entre consultas. No se alcanzó ni se buscó superar el límite de 200 del ejecutor. No se aisló experimentalmente cada diferencia entre las dos pasadas: los resultados no demuestran por sí solos que una única modificación explique toda la variación.

## 4. Estructura y métricas

- Application: SoporteDocumentalAppService coordina el contexto y delega en ISoporteDocumentalService; WorkflowEmailDelivery coordina el efecto externo con el estado persistente.
- Business: SoporteDocumentalService contiene consultas y almacenamiento; OrdenCompraReadService impone el alcance de ejercicio; UserContextQueries implementa las consultas asíncronas de alcance.
- Common: políticas de lectura, mensajes de operación incierta y DocumentPathBoundary, sin dependencias de MudBlazor.
- API: controladores con políticas, validación de contexto anterior a las acciones, auditoría envolvente y cancelación diferenciada.

Inventario sintáctico final: 2,247 archivos C#/Razor en BackEnd, FrontEnd y Shared, incluidos modelos generados; 377 vistas Razor; cero controladores detectados con persistencia directa; 74 candidatos de Application con referencias a persistencia y 22 archivos con async void. Esos conteos no equivalen a defectos confirmados ni a revisión manual de cada línea.

La implementación documental anterior tenía 576 líneas. La fachada actual tiene 46; Business contiene 571 y su contrato 17: 634 en conjunto. La mejora es separación de responsabilidades y control del contexto, no una reducción artificial del total de código. No se asigna una calificación numérica global de mantenibilidad sin revisar los candidatos restantes.

## 5. Verificaciones finales

- Solución completa .NET 10 compilada sin errores ni advertencias observadas.
- **470 pruebas aprobadas, cero fallidas y cero omitidas**, incluida la integración SQL activada explícitamente.
- Flujo SQL: fixture técnico con proceso único, sin documentos de negocio ni correos; eliminado en finally.
- Seis casos de correo simulado: confirmación, validación, respuesta incierta, fallo SQL posterior a entrega, excepción durante entrega y token vacío. Ninguno contactó SMTP.
- Catorce consultas directas finales devolvieron los estados previstos. El resumen documental ignoró la empresa proporcionada en el cuerpo y conservó la empresa autenticada.
- Portal HTTP 200 y seis rutas de arranque del manifiesto actual HTTP 200. Esto verifica entrega de recursos, no renderizado visual.
- Auditoría de calidad existente: cero infracciones. Diferencias sin errores de espacio detectados.

## 6. Evidencia reproducible

- Tests/EG.UnidTest/Application/WorkflowSqlIntegrationTests.cs: prueba SQL optativa mediante EG_RUN_DEV_SQL_TESTS=1; destino fijo local de desarrollo.
- Tests/EG.UnidTest/Application/WorkflowEmailDeliveryTests.cs: proveedor simulado y control de cancelación del token.
- Tests/EG.UnidTest/ApiCoreBS/AsyncUserContextTests.cs: carga asíncrona y reutilización sin recurrir a consultas síncronas.
- Tests/EG.UnidTest/ApiCoreBS/PurchasingReadPermissionTests.cs: permisos de las trece lecturas.
- Tests/EG.UnidTest/Business/OrderReadScopeTests.cs y DocumentPathBoundaryTests.cs: traducción del alcance y límites de rutas.
- tmp/quality-integrated/integrated-review-final.trx y api-final-results.json: resultados sin credenciales ni tokens.
- tmp/capacity-dev/capacity-security-integrated.json: primera pasada con el fallo a 200.
- tmp/capacity-dev/capacity-async-final.json y resources-async-final.json: repetición final y muestras SQL.
- tmp/architecture-current.json: lista de candidatos arquitectónicos restantes.

## 7. Pendientes de aceptación

No se dan los siete puntos por cerrados globalmente. Quedan el recorrido transaccional completo de compras, las carreras específicas de otros procesos, la separación de los candidatos restantes de Application y la revisión visual nueva en navegador con acceso operativo. El código verificado queda aplicado en desarrollo y la API y el portal fueron reiniciados con la compilación final. No se certifica producción a partir de estas pruebas locales.
