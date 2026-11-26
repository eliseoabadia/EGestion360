# Integración EAE: estado comprobado

Fecha: 23 de noviembre de 2026. Proyecto: EGestion360.

Actualización: 25 de noviembre de 2026. Las secciones 1–7 documentan la revisión inicial; las continuaciones al final registran los formularios comprobados en navegador y los cambios posteriores en tableros. El resultado más reciente es 345 pruebas correctas y 346 vistas que todavía contienen código dentro del Razor.

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
## Continuación: actualización del nombre de empresa

Se comprobaron los consumidores de SetEmpresaInfoAsync: encabezado principal y sincronización tras editar una empresa. Este método ahora sólo actualiza información descriptiva de la empresa ya activa; no puede cambiar empresa ni recuperar una sesión limpiada. El encabezado descarta respuestas cuyo identificador ya no coincide con la selección y exige una respuesta satisfactoria con la empresa solicitada. El fallback tras error también respeta esa selección.

Tres pruebas nuevas verifican una respuesta de otra empresa, una respuesta recibida después de limpiar la sesión y la actualización válida conservando la sucursal. Suite: 250 pruebas correctas; auditoría sin infracciones. No se presenta esta prueba del servicio como recorrido de navegador ni comprobación de aislamiento SQL. Se conserva la configuración de UAT para el despliegue solicitado.
## Continuación: selector de sucursal

SelectSucursalDialog separa la coordinación en code-behind, bloquea las opciones durante el guardado y muestra progreso, ausencia de opciones y error recuperable. Verifica que la opción pertenezca a la lista y contenga sucursal y empresa válidas; la autorización real permanece en el servidor. El diálogo sólo cierra tras completar el guardado y libera su bloqueo en finally.

SetSucursalAsync limpia la selección en memoria y el encabezado si falla guardar en el navegador; notifica el contexto vacío. No publica notificaciones tardías si otra selección ya reemplazó la operación. Una prueba de regresión verifica el fallo con empresa anterior y confirma que no queda el encabezado de la selección parcial. Suite: 251 pruebas correctas. El almacenamiento de dos claves del navegador no es una transacción; no se afirma atomicidad entre claves ni aceptación visual del nuevo selector. Sigue pendiente su recorrido interactivo en navegador.
## Continuación: guardados concurrentes del contexto

Las escrituras de selección, actualización descriptiva y limpieza comparten una exclusión asíncrona. Cada escritura usa la misma instantánea de sucursal y empresa; las operaciones superadas se descartan antes de comenzar. Si una escritura ya comenzó, la selección vigente se escribe después, evitando que el guardado anterior termine sobrescribiéndola. La restauración inicial espera también ese guardado y respeta la versión de selección.

GetEmpresaIdAsync utiliza el estado validado de sucursal y sólo lo inicializa si hace falta. No restaura por separado la clave antigua de empresa; eso evitaba la limpieza tras un fallo del navegador. Se mantienen firmas y claves existentes para los consumidores.

Cuatro regresiones con operaciones demoradas o almacenamiento simulado cubren dos selecciones superpuestas, limpieza durante guardado, clave aislada de empresa y consulta tras fallo de limpieza. Suite: 255 pruebas correctas; auditoría sin infracciones. La coordinación es por instancia del servicio, no entre pestañas diferentes. No convierte las dos claves de localStorage en una transacción ni permite garantizar persistencia si el navegador rechaza las escrituras. No sustituye la validación de alcance del servidor. La revisión interactiva del selector sigue pendiente.
## Continuación: limpieza de sesión y cambio de usuario

AuthenticationProviderJWT limpia primero permisos, autorización y estado autenticado en memoria. Intenta independientemente retirar token, permisos persistidos, identificador y nombre de usuario, sucursal/empresa y ejercicio; un fallo no impide intentar las demás limpiezas. El proveedor conserva el estado anónimo en esa instancia tras cerrar sesión aunque no pueda retirar una clave del navegador. Al iniciar un nuevo acceso retira el contexto anterior antes de activar el nuevo token. AnioPresupuestalStateService notifica la limpieza en finally aun si falla el almacenamiento.

Tres pruebas nuevas compilan las mismas clases usadas por el frontend: cierre de sesión con almacenamiento fallido, notificación de limpieza de ejercicio y nuevo acceso que retira empresa y ejercicio anteriores. Suite: 258 pruebas correctas, sin fallos ni omisiones; auditoría sin infracciones y comprobación de espacios correcta. Esto no revoca tokens en servidor y no garantiza retirar claves si el navegador rechaza operaciones; tampoco es prueba de aislamiento de SQL ni recorrido autenticado en navegador. El despliegue y la prueba SMTP de UAT continúan fuera de esta ejecución por indicación del usuario.
## Continuación: respuestas de sesión fuera de contexto

El proveedor de autenticación identifica la versión de sesión al iniciar lecturas de token y permisos. Antes de aplicar sus resultados o activar un token comprueba que la sesión siga vigente. También descarta pasos de inicio, limpieza y notificación que otra operación haya reemplazado. Las escrituras de token y permisos y sus eliminaciones se ordenan con exclusión asíncrona por instancia para que una escritura pendiente no termine después de la limpieza final.

Tres pruebas adicionales demoran explícitamente la lectura del token, la lectura de permisos persistidos y la escritura de permisos. Tras cerrar sesión, verifican que no se restaure autenticación, permiso ni encabezado; la escritura pendiente queda eliminada. Suite completa: 261 correctas, cero fallos u omisiones; auditoría sin infracciones y diff sin errores de espacios. Son pruebas del proveedor real con almacenamiento simulado, no de revocación JWT del servidor ni de sincronización entre pestañas. El recorrido interactivo sigue pendiente y UAT permanece reservado para el despliegue.
## Continuación: permisos vinculados al acceso que los solicitó

LoadClaimsFromDbAsync requiere el token con el que el inicio de sesión solicitó los permisos y comprueba que siga siendo el activo antes de modificar memoria o almacenamiento. Devuelve explícitamente si aplicó los permisos. El componente Login utiliza ese resultado para detener el flujo anterior si cambió la sesión, en lugar de continuar con las sucursales de la solicitud reemplazada.

Una regresión inicia dos cuentas consecutivas, aplica los permisos de la vigente y entrega después los permisos de la cuenta anterior: confirma que éstos se rechazan y se conservan token, permisos y almacenamiento actuales. Suite: 262 correctas; auditoría sin infracciones y diff sin errores de espacios. Esta comprobación usa el proveedor frontend real con almacenamiento simulado; no equivale a validar firmas JWT ni permisos de servidor. Permanece pendiente el recorrido visual con cuentas del entorno. Sin despliegue, commits, subidas o respaldos.
## Continuación: vigencia del estado autenticado en memoria

El proveedor vuelve a comprobar la expiración antes de devolver una sesión cacheada. HasPermission y la lectura síncrona del identificador rechazan una sesión vencida. Si el token falta en el navegador, se limpia el estado anterior. Se conserva el margen previo existente de 30 segundos; una expiración ausente, inválida o fuera del rango DateTimeOffset ya no puede activar una sesión.

GetUserId no espera operaciones JS ni tareas asíncronas: sólo utiliza el estado vigente cargado. Se agregó GetUserIdAsync para quien necesite inicializarlo. No había consumidores del método síncrono en el inventario revisado. El reloj del proveedor puede suministrarse como TimeProvider en pruebas y conserva TimeProvider.System por defecto.

Seis regresiones comprueban vencimiento con reloj controlado sin esperas, expiración ausente/no numérica/fuera de rango y retirada del token del navegador. Suite: 268 pruebas correctas; auditoría sin infracciones y diff sin errores de espacios. La comprobación se realiza cuando se consulta el estado o los permisos; no se agregó un temporizador ni revocación de servidor. La prueba no equivale a un recorrido autenticado en navegador ni certificación global de seguridad. Sin despliegue, commits, subidas o respaldos.
## Continuación: organización y ciclo de vida del acceso

Login.razor conserva presentación y bindings; la lógica se trasladó a Login.razor.cs. El bloqueo de doble envío empieza antes de sincronizar credenciales del navegador y validar MudForm, dentro del mismo try/finally. Antes quedaba una ventana de reentrada durante esos awaits. Al disponer la pantalla se evita suscribir el tema tras inicialización tardía, se detienen resultados de acceso y sucursales y se evita navegación posterior. Se admite un resultado nulo de diálogo como cancelación.

El inventario actualizado registra 347 vistas con código dentro de Razor; sigue siendo una señal de organización, no una medición de rendimiento. La suite de reglas y sesión permanece en 268 correctas; la extracción de Login y sus guardas no tienen nueva prueba interactiva. Auditoría sin infracciones y diff sin errores de espacios. La revisión visual de Login, selector y tableros sigue pendiente; las pruebas de formularios de adecuación documentadas antes no se presentan como evidencia de estas pantallas.
## Continuación: cargas de la tabla compartida

GenericDataGrid ahora coordina las respuestas mediante LatestGridRequest: una carga superada devuelve el resultado de la vigente en vez de reemplazarlo con filas anteriores. Sólo la petición vigente actualiza contador, error y progreso. Un fallo de una petición antigua no muestra un aviso sobre la consulta nueva. La coordinación libera los consumidores que esperan al disponer la tabla y cubre cadenas de más de dos cargas. Las búsquedas permanecen disponibles mientras se lee información; siguen bloqueadas durante una acción como exportar. Se conservan las firmas de los parámetros públicos y los callbacks de búsqueda existentes.

Se revisó la implementación oficial correspondiente a MudBlazor 9.6.0 para comprobar la aplicación de resultados de ServerData y su cancelación: https://raw.githubusercontent.com/MudBlazor/MudBlazor/v9.6.0/src/MudBlazor/Components/DataGrid/MudDataGrid.razor.cs. No se cambió de versión ni se copió el componente del proveedor.

El Razor compartido conserva markup y bindings; su coordinación pasó a GenericDataGrid.razor.cs. El inventario registra 188 consumidores directos de tablas compartidas y 346 vistas con código inline. Esto expresa alcance potencial del componente y organización, sin afirmar revisión manual o mejora medida de todas esas pantallas.

Cuatro regresiones prueban respuesta anterior tras la nueva, tres cargas superpuestas, carga vigente completada antes de la anterior y disposición con esperas pendientes. Suite: 272 correctas. Auditoría sin infracciones y diff sin errores de espacios. Son pruebas del coordinador usado por la tabla; todavía falta verificar interactivamente búsquedas, paginación, ordenación y errores en pantallas consumidoras. No se afirma reducción del tiempo de SQL ni cancelación física de servicios que ignoran el token. Sin commits, subidas, respaldos ni despliegue.
## Continuación: identidad autenticada compartida

Se contrastó el emisor TokenService: genera NameIdentifier y sub con el identificador real del usuario. AuthService obtiene el identificador sólo de una identidad autenticada, con prioridad explícita de claims conocidos, formato entero completo positivo y rango Int32. Se retiran la extracción de dígitos de texto y la lectura alternativa de userId desde localStorage. El constructor ya no depende de JS; se comprobaron los consumidores locales y el registro por DI.

DynamicMenu utiliza exclusivamente AuthService para resolver usuario. Se eliminan su parseo JWT duplicado, la búsqueda de dígitos, las lecturas directas de token/userId y sus helpers sin consumidores. Una identidad inválida conserva el manejo de error existente del menú en vez de consultar otro usuario.

Doce casos añadidos comprueban números válidos, valores mezclados, cero, negativos, rangos, identidad anónima, prioridad de claim canónico y alias compatibles. Suite: 284 correctas; auditoría sin infracciones y comprobación de espacios correcta. No se cambió la autorización del servidor: el cliente representa identidad y no sustituye el alcance autenticado de la API. Sigue pendiente el recorrido de menú y acceso con cuentas reales en navegador. Sin despliegue, commits, subidas ni respaldos.
## Continuación: ciclo de vida del menú compartido

DynamicMenu separa markup y coordinación en su code-behind y escucha los cambios de autenticación. Al cambiar sesión limpia opciones, caché, índices de búsqueda y expansión antes de cargar el menú vigente. Las respuestas y errores se aplican sólo mientras siga vigente su generación de carga; la identidad recibida se comprueba antes de guardarse en el componente. Al disponer el menú se invalidan las consultas y se retiran las suscripciones de autenticación y navegación, además de cancelar la búsqueda pendiente.

Se conservan las rutas, los parámetros públicos y la construcción de opciones existentes. La disposición también evita publicar la búsqueda o solicitar renders finales de navegación cuando el componente ya fue retirado. Se reutiliza EditorRequestState, que cuenta con las pruebas de respuestas antiguas y disposición documentadas en los formularios; no se presenta esto como una prueba funcional de los eventos del menú.

Compilación completa y auditoría configurada satisfactorias, sin errores de espacios en el diff. No hay nuevas pruebas de componente en esta continuación; la última suite sigue en 284 correctas. El inventario mantiene 374 vistas y 346 vistas con código inline dentro del alcance del escáner. La aceptación interactiva de cambio de cuenta, búsqueda y navegación sigue pendiente. UAT queda reservado para el despliegue; no se hicieron commits, subidas o respaldos.
## Continuación: revisión interactiva de la tabla compartida

Se ejecutó GenericDataGrid compilado con las hojas de estilo reales en un host local temporal de Blazor Server. El host sólo generó filas simuladas; no usó API de negocio, SQL, SMTP ni UAT. Se revisó en Chrome mediante controles nativos de Windows, sin introducir credenciales.

| Caso | Observación |
|---|---|
| Dos consultas con respuesta en orden inverso | La anterior esperó dos segundos e ignoró deliberadamente la cancelación. Al terminar ambas, todas las filas visibles conservaron VIGENTE, consulta 3, y el contador mostró 32. |
| Fallo de lectura | Aparecieron el mensaje controlado y el botón Intentar nuevamente, sin conservar las filas como si fueran una lectura satisfactoria. |
| Reintento | Recuperó 10 filas de la consulta 5 y el contador 32; la tabla volvió a ser operable. |
| Página siguiente | Se observaron filas 11–20 y el rango 11–20 de 32. |
| Tema claro | Filas, barra de búsqueda, contador y paginación visibles. |
| Tema oscuro | Se detectó bajo contraste en los títulos ordenables. Se ajustó su color con la variable de texto primario del tema y se volvió a revisar: Id y Descripción quedaron visibles. |

El cambio persistente está en GenericDataGrid.razor.css: el texto del encabezado y sus etiquetas ordenables usa la paleta activa. Frontend compilado sin errores ni advertencias; auditoría sin infracciones y diff sin errores de espacios. La suite previa permanece en 284 pruebas; no se añadieron pruebas que sólo repliquen CSS.

Las capturas se mostraron durante la revisión, sin guardar copias del proyecto. El host se detuvo y su carpeta temporal se eliminó tras verificar que estaba dentro del workspace. Esta revisión confirma los casos anteriores en escritorio con servicios simulados; no certifica las 188 pantallas consumidoras, tamaños móviles, el resto de funciones de columnas ni el recorrido de WebAssembly autenticado. La aceptación del selector, Login y tableros completos conserva sus pendientes anteriores.
## Continuación: captura y autorización de adecuaciones de ingresos

Se siguió el recorrido de los controllers, servicios y las definiciones finales de los procedimientos en el script fuente, sin ejecutarlos. La captura ordinaria compartía DTO y parámetros de procedimiento con el workflow; permitía enviar Autorizado, acción y fechas de solicitud/autorización. IncomeCaptureRules fuerza alta sin autorizar, acción inicial y fechas de workflow vacías. En edición conserva desde el registro persistido el estado, acción, fechas, clave, ejercicio, póliza, estatus, activo y auditoría de creación. El texto de justificación sigue siendo editable. Cambiar ejercicio o póliza se rechaza, siguiendo la regla ya presente en el procedimiento SQL.

El detalle no puede trasladarse de una adecuación a otra en una edición: se consulta el registro actual antes de validar su padre. Esto evita elegir un padre desbloqueado para intentar modificar un detalle de un proceso bloqueado. La autorización efectiva de acciones continúa en los endpoints existentes.

StoredProcedureCrudAppService incorpora un punto de validación virtual antes de ejecutar el procedimiento de actualización, dentro de la transacción serializable existente. Sólo los servicios de ingresos modificados añaden validación ahí; los demás conservan el comportamiento predeterminado. Cabecera y detalle repiten la comprobación del estado y relaciones antes de escribir, reutilizando las mismas reglas. No se crearon nuevas conexiones ni se alteraron procedimientos o modelos generados.

Ocho regresiones verifican alta sin autorización, conservación de campos de control frente a payload alterado, rechazo de cabecera bloqueada, cambio de ejercicio, traslado de detalle y comprobaciones inmediatamente anteriores al procedimiento. Los casos de rechazo usan los servicios reales con lecturas sustituidas y sin conexión de escritura; las pruebas del punto transaccional comprueban su validación, no bloqueos ni rollback reales de SQL Server. Suite: 292 correctas; solución completa sin errores ni advertencias; auditoría y diff correctos.

**Limitación de alcance confirmada:** los modelos persistidos IngreAdecuacion, su detalle y la vista VwIngresoAdecuacion carecen de una clave de empresa. Exigir empresa activa no equivale a filtrar esos datos; el filtro genérico sólo se aplica si encuentra la propiedad correspondiente. No se infirió la empresa por creador, ejercicio o póliza, porque tampoco establece una relación inequívoca en el esquema revisado. La separación por empresa requiere preparar el vínculo persistente, el tratamiento de los registros existentes y las vistas/procedimientos antes de declararla cubierta. Este pendiente impide certificar aislamiento por empresa de ingresos.

También siguen pendientes las pruebas concurrentes y transaccionales contra SQL Server de pruebas y la aceptación del workflow completo. Las correcciones de captura descritas no certifican las demás transiciones o bajas ante concurrencia. Sin despliegue, cambios de instancia, commits, subidas ni respaldos.
## Continuación: importes de movimientos de ingresos

Se contrastaron los parámetros y la variable de total del procedimiento fuente PRES.sp_MantenimientoAdecuacionDisminucionIngreso: utilizan decimal(18,2), exigen magnitudes no negativas, total positivo y tipos 3/4. El servicio convertía los doce importes con Math.Abs antes de enviarlos, ocultando entradas negativas frente a esa regla.

IncomeCaptureRules valida el contrato antes de persistir: referencias positivas, fecha explícitamente no predeterminada, movimiento de ingresos permitido, cada mes no negativo, rango decimal(18,2), máximo dos decimales y total positivo dentro del mismo rango del procedimiento. No redondea, no cambia signos y no suma valores fuera de rango. El detalle usa esa regla en alta, edición y en el punto de revalidación transaccional; los parámetros conservan los importes recibidos.

Veinticinco regresiones adicionales cubren negativos en los doce meses, importe cero, centavo, importe habitual, milésima, límite exacto, exceso del límite, extremos decimal, exceso de total y tipos de movimiento válidos/ajenos. Los negativos se prueban contra el servicio real sin conexión de persistencia, comprobando rechazo controlado y conservación del valor. Suite: 317 correctas; auditoría sin infracciones y diff sin errores de espacios.

No se cambiaron precisión de BD ni procedimientos, y no se ejecutaron scripts. Esta continuación verifica servidor y reglas; no incorpora nueva prueba visual ni viaje completo contra SQL. El rechazo de Fecha predeterminada no detecta una propiedad omitida mientras el DTO conserve su inicialización histórica a hoy: ese caso no se presenta como resuelto. Permanecen los pendientes de separación por empresa y aceptación SQL documentados antes. Sin despliegues, commits, subidas o respaldos.
### Cierre adicional: fecha omitida en el contrato de ingresos

La limitación de fecha omitida indicada en la continuación anterior se corrigió después de comprobar sus consumidores. Se retiró la inicialización automática a hoy sólo de IngreAdecuacionResponse y su detalle. Los dos formularios ya establecen explícitamente su fecha inicial al abrir una captura nueva, por lo que mantienen ese comportamiento visible.

El servidor rechaza Fecha predeterminada al crear y editar cabecera, incluida la revalidación previa al procedimiento. El detalle utiliza su validación de captura. Dos pruebas deserializan JSON real sin Fecha y verifican que el servicio devuelve VALIDATION antes de cualquier persistencia, sin sustituirla por hoy. La suite actualizada es de 319 pruebas correctas. Esto cierra la omisión de fecha en esos dos contratos; no establece una regla nueva de pertenencia al año calendario para ingresos ni modifica las fechas históricas de otros módulos.

## Continuación: validación compartida de importes en la captura

La regla de ingresos comparte ahora el límite decimal(18,2), el rechazo de negativos y la escala máxima de dos decimales entre la validación del servidor y la captura mensual. La suma de pantalla se invalida completa si un mes excede las reglas o si el acumulado supera el límite; no presenta ni guarda un total parcial.

Cinco pruebas cubren límite, escala, suma fuera de rango e importes vacíos/cero. Suite completa: 324 pruebas correctas; auditoría de calidad sin infracciones y `git diff --check` sin errores de espacios. No se completó una nueva comprobación visual de navegador en esta continuación. El primer intento de compilación en el entorno restringido produjo MSB4216/MSB4027 al iniciar el host MSBuild x64 de WebAssembly; con permiso para ejecutar el host, la solución completa compiló con cero advertencias y errores. Sin cambios en BD, despliegues, commits, subidas ni respaldos.

### Revisión del enlace de restablecimiento

Al leer el token desde el fragmento de la URL, el portal ahora reemplaza la entrada actual del historial por la misma dirección sin el token. El token permanece sólo en memoria del componente para completar la solicitud. La recuperación conserva el token de un solo uso, vencimiento, respuestas que no enumeran cuentas y limitación de intentos existentes. La solución completa compiló con el SDK 10.0.404: cero advertencias y errores; suite: 324 correctas; auditoría de calidad: cero infracciones. El recorrido de correo no se ejecutó en UAT.

### Solicitudes de recuperación nulas

Como la API desactiva el filtro automático de ModelState, los servicios de recuperación ahora aceptan explícitamente un cuerpo nulo y devuelven una validación controlada antes de consultar cuentas o modificar contraseñas. Dos pruebas cubren esos caminos; suite actual: 326 correctas. Se corrigió además el código de salida de `Audit-CodeQuality.ps1`: con `-FailOnViolations`, cero infracciones produce ahora salida 0 de forma consistente. Auditoría: cero infracciones; diff sin errores de espacios.

Intenté comprobar la pantalla en navegador con el frontend local iniciado, pero el navegador no pudo alcanzar `localhost:5419`; cerré la pestaña y detuve el servidor temporal. La vista no se considera revisada visualmente. No se envió una solicitud de recuperación ni se contactó SMTP/UAT.

## Continuación: consultas de adecuaciones de egreso

Se verificó el origen del listado sin paginación: `GenericService.GetQueryWithIncludes` ya añade los filtros de empresa, ejercicio y activo a la consulta EF para las vistas que contienen esas propiedades. Se retiró el segundo recorrido `Where` en memoria del servicio de egresos y se conserva la validación del contexto antes de delegar la consulta. El alcance continúa aplicándose en SQL mediante el servicio genérico.

La compilación completa posterior a la revisión PBR fue correcta; se repetirá tras esta corrección. No corrige adecuaciones de ingreso, cuyo esquema no contiene una empresa asociable de forma inequívoca. No se cambió la BD ni se ejecutó SQL.

## Continuación: ejercicio fiscal en editores PBR

El diálogo CRUD compartido ya no sustituye el ejercicio faltante por el año del navegador ni actualiza la fecha de creación del servidor desde el cliente. Conserva el ejercicio del registro si no hay uno seleccionado y bloquea el guardado de entidades anuales cuando no existe un ejercicio válido. La regla se aplica a anteproyectos, presupuestos por programa y partidas que usan el editor genérico; las entidades sin propiedad `Anio` no requieren ese contexto.

Seis pruebas cubren ausencia de año, conservación de registros, aplicación intencional del contexto, propiedad nullable y entidad no anual. Suite: 332 correctas. Compilación completa: cero advertencias y errores; auditoría y diff sin infracciones. No hubo recorrido visual porque el navegador disponible no alcanzó el servidor local.

## Continuación: fechas de requisición y suministro

La captura de requisiciones ya no convierte una fecha vacía a la fecha del equipo al guardar. La regla compartida entre formulario y servicio exige fecha de requisición y rango de suministro, compara días calendario y rechaza fecha de solicitud posterior al inicio, así como un inicio posterior al fin. El servicio vuelve a validar al recibir la solicitud, aunque se omita la pantalla.

Cinco casos de prueba cubren campos requeridos, fechas posteriores al inicio, rango invertido y fechas del mismo día. Suite completa: 338 pruebas correctas. Compilación de solución: cero advertencias y errores; auditoría de calidad: cero infracciones; diff sin errores de espacios. No se modificaron procedimientos ni esquema SQL; no se hizo despliegue, commit, subida ni respaldo.

## Continuación: ejercicio explícito en tableros PBR

Los tableros PBR y Mi Tablero dejaron de tomar el año del reloj cuando no hay selección presupuestal. Ahora solicitan seleccionar el ejercicio, limpian los datos visibles si se quita la selección y no llaman al servicio con un año inválido. Cuatro casos verifican selección ausente, cero, año negativo y año positivo. Suite: 342 pruebas correctas. La solución compila sin advertencias ni errores y la auditoría no reporta infracciones. Pendiente revisión visual en navegador.

## Continuación: fecha requerida en solicitudes de salida de almacén

La pantalla de solicitud de salida conserva la validación de empresa, área y ejercicio y ahora rechaza una fecha de solicitud vacía sin reemplazarla por el día actual. El servicio aplica la misma regla al cuerpo recibido directamente y sólo genera folio y fecha persistida después de validarla. La comprobación del año calendario del registro contra el ejercicio seleccionado se mantiene.

Tres pruebas cubren fecha nula, fecha predeterminada y fecha explícita válida. La misma regla protege el calendario de inventarios de patrimonio: la pantalla no sustituye una fecha de edición faltante y el servicio rechaza payloads sin fecha antes de validar su rango contra el calendario. Suite: 345 correctas. Compilación completa: cero advertencias y errores; auditoría: cero infracciones; diff: sin errores de espacios. No se alteró la base de datos ni los procedimientos de almacén/patrimonio.

## Continuación: calendario patrimonial y solicitudes de baja

El servicio de calendarios ya no deduce fecha de inicio ni fecha fin de valores vacíos; exige ambas antes de aplicar las reglas existentes de rango, año y traslape por área. En bajas patrimoniales, fecha de solicitud es obligatoria en pantalla y API; las fechas de referencia y baja siguen opcionales según el flujo existente y se conserva la validación de fecha de referencia respecto a la baja.

Suite: 345 correctas. Compilación completa sin advertencias ni errores; auditoría de calidad sin infracciones; diff sin errores de espacios. No se ejecutó SQL ni se cambió el esquema. Pendiente revisión visual de estas pantallas.

## Continuación: fecha de cotización y fecha de adquisición patrimonial

La fecha de solicitud de cotización ahora se rechaza si llega vacía o predeterminada por API y se envía al procedimiento sólo después de validarse. Los campos opcionales de fecha comprometida y cotización conservan su comportamiento actual. El alta de bienes exige una fecha de adquisición antes de llamar al procedimiento; el formulario la marca como requerida y el servidor normaliza la fecha validada al día calendario.

Suite: 345 correctas; compilación completa sin advertencias ni errores. Estos cambios reutilizan la regla de fecha requerida probada anteriormente. No se modificó SQL ni se ejecutó el procedimiento. Pendiente la aceptación visual y funcional de pantallas con datos reales.

## Continuación: arranque local y flujo de licenciamiento

La API validaba configuración obligatoria en dos pasos, por lo que cada reinicio mostraba sólo la primera clave ausente. Ahora enumera conexión y firma JWT en un mismo diagnóstico. Las transacciones explícitas de inicialización/importación/cambio de licencias se ejecutan dentro de la estrategia de reintentos SQL Server. Se corrigieron los alias de `InstallationStateRow` y se quitaron terminadores de sentencias SQL que EF agregaba dentro de consultas componibles.

Se configuró User Secrets local con autenticación Windows a la base `GestionEmpresarial` y una clave JWT aleatoria; los valores permanecen fuera del repositorio. API `http://localhost:5198/api/Navigate/ping` y portal `http://localhost:5242/` respondieron HTTP 200 en la comprobación. La compilación completa terminó sin advertencias ni errores. El arranque inicial verificó/creó los objetos de licenciamiento y envío workflow de la base local. No se hicieron commits ni respaldos.

## Continuación: lecturas y filtrados reutilizados en catálogos

El diálogo de requisición reutiliza durante su vida una sola lectura de áreas/personas solicitantes para disponibilidad, búsqueda de persona, selección de área y comprobación del registro editado; la autorización definitiva al guardar permanece en el servidor. El autocompletado compartido conserva un conjunto de IDs para deduplicar elementos de forma constante, en vez de recorrer todos los elementos ya cargados por cada resultado. En catálogos locales calcula la lista filtrada una vez por término y pagina esa misma lista. Cada opción muestra el texto completo con el atributo `title` y no crea un `MudTooltip` adicional por fila, manteniendo la presentación compacta de las listas.

Compilación completa: cero advertencias y errores. No se añadieron pruebas ni se ejecutó SQL para estos cambios de interfaz.

## 26/11/2026: recepción de pedidos con menos pasos

Recepcion_Pedidos conserva su ruta y sus servicios genéricos. La vista muestra recepción rápida, un resumen con alcance explícito y cuatro órdenes próximas dentro de la página actual; prepara automáticamente una orden y su primer renglón pendiente visible. La captura básica confirma cantidad/fecha en la misma pantalla; ubicación, factura, remisión y lote siguen disponibles en el formulario existente. El listado completo se despliega y el historial se consulta bajo demanda. No se inventaron importes pendientes ni métricas SLA.

La inicialización espera empresa/ejercicio antes de montar los listados. Los cambios de contexto invalidan respuestas anteriores. El formulario valida conversión, obligatoriedad, cantidad positiva, saldo, cuatro decimales y ejercicio; la API existente conserva las validaciones definitivas. Se evita doble envío y se requiere revisar saldo/historial tras un resultado incierto. El menú móvil ahora comienza cerrado y se abre como una capa sobre el contenido.

Verificaciones: compilación de EG.Web en salida habitual, cero advertencias/errores; auditoría de código sin violaciones; interfaz WASM real con API/identidad simuladas en 1440x1080 (claro/oscuro) y 390x844. Confirmación disponible al cargar, cantidad excesiva sin POST, corrección seguida de doble clic con un solo POST, saldo actualizado tras respuesta, ancho móvil sin desbordamiento y apertura/cierre del menú móvil. Evidencia en tmp/recepcion-design: desktop-dark.png, desktop-light.png, mobile-dark.png, mobile-capture.png y result.json. La instancia simulada solicita un recurso opcional de hot reload inexistente; sus 404 quedaron registrados y no son fallos de la lógica de recepción. No se ejecutó una recepción contra SQL ni se validaron permisos reales mediante esa simulación.
