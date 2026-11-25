# Integración EAE: estado comprobado

Fecha: 23 de noviembre de 2026. Proyecto: EGestion360.

Actualización: 24 de noviembre de 2026. Las secciones 1–7 documentan la revisión inicial; las continuaciones al final registran los formularios comprobados en navegador y los cambios posteriores en tableros. El resultado actualizado es 247 pruebas correctas y 349 vistas que todavía contienen código dentro del Razor.

## 1. Diagnóstico general

Esta revisión continúa los cambios existentes de formularios compartidos, recuperación de contraseña, PAAA, validaciones y separación de controladores. El trabajo de esta entrega comprende menú, asignaciones de roles, permisos de adecuaciones, catálogos de consulta y controles de calidad. Los cambios están en los archivos del proyecto; no se crearon respaldos, commits ni publicaciones.

Se encontraron cinco archivos de controladores que todavía utilizaban `GenericService` directamente. En adecuaciones, algunas operaciones sólo exigían autenticación y las autorizaciones interpretaban permisos con una lógica diferente del autorizador común. El menú tenía reordenamiento capaz de sobrescribir otros campos, cambios parciales del padre durante una creación fallida y operaciones sobre una clave compuesta tratada como identificador simple.

Mantenibilidad del alcance intervenido: estimación 4/10 antes y 7/10 después. El criterio es separación de responsabilidades, contratos explícitos, eliminación de duplicación y protección mediante pruebas de regresión. No es una calificación de toda la solución. El inventario aún identifica 355 vistas con código dentro del archivo Razor; no se presentan como migradas ni revisadas manualmente.

## 2. Oportunidades y correcciones

| Prioridad | Ubicación | Evidencia y efecto | Estado |
|---|---|---|---|
| Alta | `PresupuestoModificadoControllerBase` | Crear, modificar, eliminar y consultar requieren la acción del tipo de adecuación correspondiente. Actualizar comprueba el registro guardado y el destino enviado. | Aplicado y probado con servicios de prueba |
| Alta | Controladores de ingreso y egreso | Enviar requiere modificar; autorizar y rechazar requieren autorizar. Las decisiones usan `IAuthorizationService` y los permisos almacenados. | Aplicado; regresión de permisos combinados cubierta |
| Alta | Detalles de adecuaciones | El permiso se resuelve mediante la cabecera dentro del alcance del servicio. Un padre ausente o fuera del alcance no permite guardar. | Aplicado y probado |
| Alta | `MenuPersistence` | Alta y promoción del padre comparten transacción; se validan nombres, longitudes, padres y ciclos antes de modificar entidades. | Implementado; aceptación SQL pendiente |
| Alta | `MenuRoleRepository` | La clave es menú y rol. Las rutas antiguas rechazan resultados ambiguos; borrar no selecciona arbitrariamente un rol. | Implementado; servicio probado, integración SQL pendiente |
| Alta | `MenuController` | Consultar, crear, modificar, borrar y exportar tienen políticas específicas. | Declaraciones comprobadas en pruebas |
| Media | `MenuOrderDto` y `MenuRules` | Reordenar sólo admite ID y orden; valida el lote antes de alterar entidades y guarda dentro de una transacción. | Reglas probadas; concurrencia SQL pendiente |
| Media | `MenuEditor` | Alta y edición comparten formulario, validación, estados de carga/error, protección de guardado y cierre. Conserva iconos existentes que no estén en el selector. | Compilado; revisión visual pendiente |
| Media | `Menus` | Se retiraron `Task.Run`, métodos `async void`, filtros comentados, tareas sin esperar y estados no utilizados. | Aplicado y compilado |
| Media | Exportación del menú | Se retiró el acceso a un filtro nullable sin seleccionar. La consulta de exportación conserva filtros y alcance sin recortarse a una página. | Caso de 320 registros probado |
| Media | `EntityUpdateMapper` | La auditoría de creación en inglés queda preservada, además de las propiedades en español. | Regresión cubierta |
| Media | `Constants` | Se retiró una contraseña fija sin consumidores encontrados en BackEnd, FrontEnd o Shared. | Aplicado |

## 3. Rendimiento

El reordenamiento anterior consultaba y actualizaba cada menú individualmente. Ahora obtiene el lote en una consulta y ejecuta un solo `SaveChangesAsync`, que puede producir varios comandos SQL según el proveedor. La escritura completa se protege con una transacción serializable. La confirmación visual de baja consulta sólo el registro y su indicador de hijos, en lugar de cargar todo el árbol.

La exportación usa una consulta filtrada sin paginación y obtiene el total de los resultados materializados. La paginación jerárquica cuenta y pagina raíces antes de adjuntar sus descendientes. Construir el árbol valida las dependencias para evitar referencias circulares en la serialización. Este recorrido depende del número de menús y de la profundidad de la jerarquía; no se afirma coste lineal para todos los casos.

No se midieron latencias, consumo de SQL Server ni carga concurrente real. Los cambios descritos son reducción de operaciones y correcciones de comportamiento, no porcentajes de rendimiento medidos.

## 4. Arquitectura y carpetas

| Capa | Archivos y responsabilidad |
|---|---|
| Common | `Modules/MenuModule.cs`: claves del módulo, rutas y políticas estables. `PermissionAction` conserva los valores de permisos existentes. |
| Contracts | `MenuOrderDto`: transporte de reordenamiento sin campos editables adicionales. |
| Domain | `Platform/Interfaces/IMenuPersistence.cs`, `IMenuRoleRepository.cs` y `Platform/Rules/MenuRules.cs`: contratos y reglas comprobables sin MVC ni EF. |
| Infrastructure | `Platform/General/MenuPersistence.cs` y `MenuRoleRepository.cs`: consultas, auditoría, claves compuestas y transacciones. |
| Application | `Platform/Services/General`: coordinación de menú, roles y catálogos de consulta. `MenuTreeBuilder` construye el árbol. |
| API | Controladores de menú y roles delegan en Application. Las bases de adecuaciones y catálogos están separadas en archivos propios. |
| Frontend | `Pages/Platform/Sistema/Menu`: markup y code-behind separados; `MenuEditor` compartido por los componentes existentes `CrearMenu` y `EditarMenu`. |
| Cliente HTTP | `MenuExportService`: usa el transporte autenticado existente y la ruta centralizada del módulo. |
| Calidad | `Audit-CodeQuality.ps1` impide volver a introducir contexto o servicio genérico de negocio en controladores. |

No se modificaron modelos generados por EF Core Power Tools, claves persistidas ni valores de estados. Las nuevas interfaces tienen consumidores concretos y se registraron en la composición de servicios existente.

## 5. Refactorización aplicada y cobertura de los criterios solicitados

| Criterio solicitado | Aplicación comprobable | Límite de aceptación |
|---|---|---|
| `eae-arquitecto-blazor` | Separación de controladores, reglas, persistencia y formularios del menú; inventario automático del conjunto. | No equivale a revisión manual de todos los módulos. |
| `eae-estandar-aplicaciones` | Formularios y tabla compartidos; auditoría resuelta en servidor; permisos por acción. | Operación con empresa y usuarios reales pendiente. |
| `eae-validaciones-desarrollo` | Nombres, longitudes, tipo, ruta, orden, padres, ciclos y lotes; comprobaciones de acciones y alcance. | Integración real de persistencia pendiente. |
| `eae-catalogos-blazor` | CRUD del menú conserva rutas existentes, búsqueda, tabla, exportación y diálogos. | Recorrido completo en navegador pendiente. |
| `eae-diseno-compacto` | Formulario común compacto de cuatro campos y confirmación de baja; acciones en el pie compartido. | Escritorio/móvil, teclado y ambos temas pendientes para estos cambios. |
| `eae-modulo-completo` | Contratos, dominio, persistencia, Application, API, cliente, interfaz y registro de servicios conectados. | Sin creación de registros de producción para las pruebas. |
| `eae-permisos-modulos` | Acciones de menú y adecuaciones; permiso del padre para detalles; consultas filtradas antes de contar y paginar. | Los servicios de prueba no certifican permisos de usuarios reales. |
| `eae-flujos-autorizacion` | Enviar, cancelar, autorizar y rechazar reutilizan el autorizador común y conservan los servicios de estados existentes. | Transiciones contra procedimientos SQL reales pendientes. |
| `eae-sqlserver-integridad` | Clave compuesta de roles, validación de relaciones, baja lógica y transacciones del menú. | No se necesitó cambio de esquema; rollback y concurrencia deben comprobarse en una base de pruebas. |
| `eae-deploy-iis` | Comprobación local de XML, proxy, HTTPS, API del mismo origen y CORS. | No se instaló ni verificó un sitio IIS de destino. |
| `ge-uni360-entidad-a-front` | Se conserva la línea de capas y contratos adaptada a EGestion360 y la tecnología instalada. | No es una entidad nueva de GE.UNI360 ni justifica generar scripts de esquema sin cambios necesarios. |

Los nuevos parámetros del editor son `MenuId`, `ParentId` y `ParentName`; el cierre se comunica por el diálogo compartido existente. Los componentes públicos de alta y edición conservan los parámetros que utiliza el listado.

El inventario de calidad pasó de cinco archivos de controladores con `GenericService` directo a cero. Los controladores con contexto directo permanecen en cero. Las vistas Razor son 372, de las cuales 130 utilizan directamente los editores compartidos y 188 las tablas compartidas. Estos conteos son sintácticos: no califican automáticamente la experiencia visual ni la seguridad del proyecto.

No se calculó complejidad ciclomática de todo el código ni se atribuyó la reducción de un controlador a una reducción equivalente de toda la funcionalidad. La extracción agrega interfaces, servicios y pruebas que forman parte del conjunto.

Comparación de las mismas 47 rutas de código y scripts cambiadas en esta revisión, incluyendo archivos nuevos y pruebas: 4,873 líneas en el estado inicial de Git y 4,717 líneas al terminar. Los archivos nuevos se cuentan completos y aportan cero líneas al estado inicial. Se excluyen este informe, modelos generados y salidas de compilación. La disminución de líneas no es una medida de calidad ni de velocidad por sí misma.

## 6. Análisis Blazor

La aplicación mantiene Blazor WebAssembly y MudBlazor instalados. El menú declara presentación en Razor y coordina las operaciones en code-behind. Los permisos de interfaz se expresan mediante capacidades derivadas de `PermissionAction`; el servidor vuelve a comprobarlos.

Las cargas descartan respuestas antiguas mediante una versión y evitan actualizar componentes dispuestos. El formulario conserva la captura ante errores y muestra reintento si falla la lectura. El componente compartido bloquea la confirmación repetida y el cierre mientras guarda. La baja usa el mismo mecanismo. La exportación tiene su propio bloqueo contra operaciones simultáneas.

Las políticas de consulta y las reglas de negocio no se trasladaron a la vista. El código del selector sólo filtra iconos de presentación. Se quitaron los campos editables asociados a información calculada de la vista SQL que no se persistía.

Esta entrega compila la UI, pero no aporta capturas nuevas ni una validación interactiva de los formularios modificados. Las capturas históricas del proyecto no se presentan como evidencia de estos cambios.

## 7. Resultado y aceptación

Validaciones locales realizadas:

- Compilación de la solución completa: cero errores y cero advertencias.
- Suite de pruebas: 197 correctas, cero fallidas y cero omitidas; antes de esta revisión había 153.
- Auditoría de código: cero infracciones de las reglas configuradas.
- Configuración fuente de IIS: comprobación satisfactoria, sin modificar el servidor.
- Contratos de permisos: pruebas de acciones específicas, actor sin acción y rechazo sin escrituras.
- Exportación: prueba de 320 registros, búsqueda y exclusión de registros inactivos o de otra empresa.

Pendientes de aceptación: recorrido de las pantallas en navegador, envío real de recuperación por SMTP, procedimientos y transacciones contra una base de pruebas SQL Server e instalación/arranque en IIS de destino. Estas pruebas requieren los servicios del entorno; no se simularon como si fueran una aceptación real.

El estado es implementación local comprobada en el alcance descrito. La certificación global del proyecto y la preparación de producción siguen pendientes de esas verificaciones y de la revisión de las familias restantes.

## Continuación del 24 de noviembre: capturas de adecuaciones

Se completaron las cuatro capturas de esta familia: cabecera y movimiento de egresos (`PresupuestoModificadoDialog` y `PresupuestoModificadoDetalleDialog`), y cabecera y movimiento de ingresos (`ModificadoIngresoDialog` y `ModificadoIngresoDetalleDialog`). Sus parámetros y servicios existentes se conservaron. Cada archivo Razor tiene ahora su code-behind correspondiente.

### Correcciones aplicadas

- Una lectura fallida ya no habilita el guardado de un modelo inicial vacío. Se muestra el error y una acción de reintento. Esto se comprobó en los cuatro formularios.
- Borrar la fecha muestra un error y evita el envío; el guardado no sustituye el valor borrado por la fecha de hoy. Se conserva la regla existente de pertenencia al ejercicio en egresos, sin inventar una regla adicional de año calendario para ingresos.
- La carga descarta respuestas de un registro o partida anterior, así como respuestas recibidas después de cerrar el componente. `EditorRequestState` comparte este comportamiento entre los cuatro editores y sus consultas de disponibilidad.
- El guardado verifica de nuevo el ejercicio seleccionado, conserva la captura ante errores y restablece su estado en `finally`. El cierre de éxito usa el diálogo base para que éste conozca el resultado de la operación.
- Una disponibilidad todavía pendiente o fallida ya no se representa como un disponible de cero ni habilita el guardado. El usuario puede reintentar la consulta.
- La distribución mensual usa `BudgetMonthlyGrid`, con columnas calculadas a partir del ancho disponible. Evita que las reglas globales de las rejillas conviertan los doce meses en una única columna en móvil. Encabezado y acciones permanecen fuera del desplazamiento del cuerpo.
- La entrada mensual valida explícitamente magnitudes negativas, conserva el signo inválido para poder mostrar el error y vuelve a comprobarlo antes de enviar. La normalización de importes firmados al leer los movimientos existentes se conserva como parte de su presentación.
- La actualización de la entrada espera 250 ms al escribir para no reformatear un signo o decimal que todavía se está capturando. Se verificó también escribir un importe inválido y pulsar inmediatamente Actualizar: no se envió una escritura.
- El selector de ingresos conserva la descripción de posición presupuestal del registro. La barra de formato de la cabecera de egresos tiene estilos locales y sus acciones se bloquean durante el guardado.
- `AnioPresupuestalStateService` limpia una selección anterior si el almacenamiento está vacío, es inválido o ya no contiene un ejercicio válido. Antes podía conservar un ejercicio que el usuario ya no tenía seleccionado.

### Evidencia de navegador

La revisión ejecutó los componentes compilados reales y las hojas de estilo del proyecto en un host temporal de revisión con servicios simulados. No se utilizó la API real, SQL Server ni SMTP; los guardados sólo incrementaron un contador en memoria. El host de revisión usó renderizado interactivo de servidor, por lo que esta prueba de componentes no sustituye el recorrido de la aplicación WebAssembly autenticada. El host se detuvo y su carpeta temporal se eliminó al terminar.

| Caso | Resultado observado |
|---|---|
| Fecha vacía en las cuatro capturas | Mensaje junto al campo; el diálogo permanece abierto; el contador de escrituras no aumenta. |
| Corregir fecha en cabecera de egresos | Guardado simulado correcto y cierre del diálogo. |
| Lectura fallida en las cuatro capturas | Actualizar deshabilitado; Reintentar visible. |
| Negativos escritos con teclado en ambos movimientos | Mensaje de importe negativo; intento inmediato de guardar rechazado sin escrituras. |
| Corregir el movimiento y capturar decimales | Entrada `250.75` conservada; total mostrado correctamente; guardado simulado correcto. |
| Recorrido por teclado hasta diciembre | El cuerpo desplaza el último campo a la vista y conserva las acciones accesibles. |
| Tema claro y oscuro | Formularios e indicadores revisados visualmente; no se modificaron las preferencias del producto real. |
| Escritorio 1280 × 720 | Doce campos mensuales; sin desbordamiento horizontal; Actualizar dentro del área visible. |
| Tableta 768 × 1024 | Doce campos mensuales; sin desbordamiento horizontal; Actualizar dentro del área visible. |
| Móvil 390 × 844 | Dos columnas mensuales; recorrido hasta diciembre; Cancelar y Actualizar visibles. |

Se comprobaron geometría del diálogo y posición de las acciones, además de inspección visual. Las capturas se mostraron durante la revisión; no se conservaron copias del proyecto ni un host alternativo de producción.

### Pruebas y límites actualizados

La suite pasa de 197 a 219 pruebas correctas, sin fallos ni omisiones. Los casos nuevos cubren respuestas obsoletas y componentes dispuestos, error y reintento, fechas vacías, ejercicio de egresos, día bisiesto, importes negativos y pérdida/cambio del ejercicio en almacenamiento. Las pruebas compilan las mismas clases de estado y validación que utiliza el frontend; no son implementaciones paralelas de esas reglas.

La solución completa compila sin errores ni advertencias y la auditoría configurada mantiene cero infracciones. El inventario registra 374 vistas, 130 consumidores directos de editores compartidos, 188 de tablas compartidas y 351 archivos Razor con código dentro de la vista. Los cuatro editores intervenidos dejaron de formar parte de ese último conteo; no se afirma que los restantes estén migrados.

No se modificó el esquema ni se reescribieron procedimientos almacenados en esta continuación. Permanecen pendientes la aceptación de procesos contra una base de pruebas, el correo real de recuperación, IIS del destino y las demás familias de pantallas. La revisión de estos componentes resuelve parte de la aceptación visual pendiente, sin certificar toda la aplicación ni el rendimiento del entorno real.

## Continuación del 24 de noviembre: tableros de adecuaciones

Se separó el código de `PresupuestoModificadoShell` y `ModificadoIngresoShell` en sus archivos `.razor.cs`, conservando las vistas y sus servicios. Esta revisión no modifica el esquema, los procedimientos ni los contratos públicos.

- Ambos tableros usan `BudgetPageReader` para consultar todas las páginas de movimientos y pólizas. Se retiraron los topes silenciosos de 200, 300 y 500 filas usados para calcular sus importes. El lector rechaza fallos, páginas incompletas, identificadores duplicados y cambios en el número de registros durante la consulta.
- Los totales del tablero no dependen del texto de búsqueda de la tabla de movimientos. En egresos se aclara que los indicadores del listado corresponden a la página visible.
- La selección se invalida al cambiar empresa, ejercicio o parámetros del módulo. Se descartan resultados tardíos y se limpia el tablero al volver al listado o disponer el componente. La moneda también descarta respuestas de un contexto anterior.
- La cabecera, los movimientos y la póliza se presentan como una carga completa: mientras está pendiente se muestra progreso; si falla se ofrece reintentar y no se habilita la captura con datos anteriores.
- Enviar, autorizar, rechazar y cancelar usan la exclusión de operaciones del componente base. La confirmación se cancela si cambia el contexto antes del envío. Se libera la respuesta HTTP, se comprueba también `Success` y un error de transporte pide actualizar antes de reintentar; no se reenvía automáticamente.
- Solicitar autorización requiere el permiso de edición también en la interfaz. La autorización efectiva permanece en el servidor.

Verificación local: solución completa compilada con cero errores y advertencias; 226 pruebas correctas, cero fallidas y omitidas; auditoría configurada sin infracciones; comprobación de espacios del diff correcta. Las siete pruebas nuevas verifican 701 registros, fallos frente a consultas vacías válidas, páginas incompletas, duplicados, cambio de conteo y cambio de contexto durante una petición.

El inventario conserva 374 vistas y registra 349 con código dentro del Razor, dos menos que en la revisión anterior. Esta extracción mejora la separación entre presentación y coordinación; no equivale a completar la revisión del resto del proyecto ni a medir su rendimiento. Los totales del listado de egresos aún requieren consultas por registro: no se afirma haber eliminado ese patrón. La paginación detecta cambios de conteo y duplicados, pero no ofrece una instantánea transaccional de importes modificados concurrentemente; la validación definitiva sigue correspondiendo al servidor.

Esta continuación no incluye una nueva prueba interactiva de los tableros. La evidencia de navegador de la sección anterior corresponde exclusivamente a los cuatro formularios. Siguen pendientes la comprobación visual de estos tableros, los recorridos autenticados y la aceptación contra SQL Server, SMTP e IIS reales. No se realizaron commits, subidas ni respaldos.

## Continuación del 24 de noviembre: correo de recuperación

Se revisó el servicio de correo equivalente de GE.UNI360 como referencia, sin modificar ese proyecto. Comparte el patrón de servicio e interfaz, pero también devolvía detalles internos de excepciones; ese comportamiento no se trasladó como buena práctica.

En EGestion360, EmailService ahora devuelve errores controlados sin datos internos del servidor SMTP. El registro conserva sólo el tipo de excepción, sin direcciones, cuerpo ni token. Se conserva la cancelación del solicitante y se aplica un plazo real al envío asíncrono mediante CancellationTokenSource. No hay reenvío automático tras un resultado incierto.

EmailConfigurationValidator centraliza la comprobación de remitente, puerto, credenciales y plazo. Para el transporte Gmail existente exige STARTTLS con puerto 587. El flujo de recuperación utiliza el mismo validador antes de consultar cuentas o generar tokens. También se rechazan destinatarios inválidos y saltos de línea en el asunto antes de conectar.

Tools/Configuration/Set-DevelopmentGmail.ps1 prepara el almacén de secretos local existente con entrada oculta, sin clave en argumentos, archivos temporales o repositorio. Solicita la dirección real del portal y conserva los demás secretos. Su README distingue desarrollo de IIS y advierte que Secret Manager no cifra en disco. La cuenta remitente ya estaba configurada en la fuente; no se inventó ni se capturó una contraseña.

Verificación: 239 pruebas correctas, sin fallos ni omisiones; backend y pruebas compilados durante la ejecución; auditoría sin infracciones y diff sin errores de espacios. Los trece casos añadidos cubren configuración Gmail, rangos inválidos, direcciones, cancelación, errores sanitizados y rechazo previo a consultar cuentas. Se verificaron sintaxis PowerShell y soporte de entrada JSON de la herramienta instalada. El configurador no se ejecutó con una clave real.

Pendiente: que el titular capture la contraseña de aplicación localmente y confirme la dirección del portal, seguido de recepción real y recorrido de recuperación. No se enviaron correos ni se cambiaron contraseñas de cuentas; no se hicieron commits, subidas o respaldos.
## Continuación: contexto de empresa en el navegador

SucursalStateService limpia la selección y el encabezado X-Empresa-Id al restaurar almacenamiento ausente, inválido o sin empresa válida. La limpieza elimina inmediatamente el encabezado incluso si falla borrar el almacenamiento; notifica el cambio en finally. Seleccionar una sucursal sin empresa retira el encabezado anterior. Las restauraciones pendientes no pueden reemplazar una selección más reciente y la lectura de empresa rechaza identificadores no positivos.

Se agregaron ocho casos de regresión con el mismo servicio usado por el frontend: almacenamiento ausente/inválido, limpieza ante fallo del navegador y cambio a sucursal sin empresa. Suite: 247 pruebas correctas. Esto protege el contexto enviado por el cliente; no sustituye la autorización y el aislamiento de datos en servidor ni certifica una prueba con usuarios reales. UAT y su correo se dejan para el despliegue solicitado por el usuario.