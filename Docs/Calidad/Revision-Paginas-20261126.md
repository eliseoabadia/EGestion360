# Revisión de páginas y consultas

**Fecha:** 26 de noviembre de 2026  
**Alcance:** compilación, pruebas automatizadas, inventario de rutas y navegación autenticada en desarrollo.

## Cobertura de pantallas

- Inventario estático: 406 archivos de página (376 Razor y 30 code-behind), 188 componentes con rutas y 469 declaraciones de ruta, incluidas rutas alternativas y parametrizadas.
- Navegación automatizada: 185 rutas principales, una por componente con ruta, excluyendo sólo las pantallas de acceso y recuperación. Las 13 rutas del catálogo fiscal compartido también se revisaron individualmente.
- Se repitieron las pantallas con errores previos y las afectadas por paginación. En las rutas finales comprobadas no hubo excepciones de Blazor, desbordamiento horizontal ni llamadas de escritura bloqueadas.
- Las nueve navegaciones de comprobación final promediaron 4.1 segundos en el navegador local. Incluyen la carga y estabilización de Blazor; no representan el tiempo de una solicitud API.

## Correcciones aplicadas

- La vista de órdenes de compra ahora aplica empresa y ejercicio a través de la requisición relacionada; la vista no contiene directamente el campo de ejercicio.
- Se agregó un modelo de lectura para facturas CLC de ingresos que enlaza la autorización y su ejercicio. Sus importes usan precisión decimal `20,4`, igual al tipo `dbo.dmoney`.
- Se registró el servicio faltante de tablas fiscales que impedía mostrar varias rutas de ISR, subsidio e IMSS.
- El resumen documental por fila se reemplazó por una solicitud agrupada por página. En Matriz PBR, Bienes y Recepción de pedidos, 10 filas generaron una sola llamada `resumen-lote` en vez de 10 llamadas individuales.
- Se consolidó `PagedCollectionReader`, que solicita páginas de hasta 250 filas, valida que el total no cambie y rechaza páginas incompletas. Los diálogos y validaciones de conteo, suficiencia, requisiciones y facturas ya no intentan descargar `int.MaxValue` filas en una sola respuesta. Conteos de negocio mayores a 10,000 se detienen con aviso; los catálogos de tipos y períodos tienen un límite de 5,000 y avisan si se alcanza.
- Se probó la exportación de 1,032 bienes filtrados en cinco páginas de 250 filas. Se contaron 1,032 claves únicas y se interceptó la descarga, sin guardar un archivo de datos.
- Los selectores de áreas de PAAA, Salida de almacén y tres formularios de planeación presupuestal ahora reutilizan durante la apertura del diálogo la lista de áreas/personas asignadas al usuario. Las búsquedas y páginas del selector ya no vuelven a solicitar la misma respuesta a la API; sólo se conserva una carga exitosa y los errores permiten reintentar. Se mantuvo el endpoint limitado a la identidad autenticada; no se sustituyó por un listado global.
- Requisiciones dejó de mostrar la clave primaria en la tabla y en el encabezado. La pantalla usa la descripción y, cuando existe, el oficio; las etiquetas de soporte documental y del asistente ya no imprimen el ID. Los nombres de propiedades usados en filtros y ordenamiento se expresan con `nameof` para detectar renombres durante la compilación.
- La consulta de imagen de perfil quedó limitada al usuario autenticado y devuelve `204 No Content` cuando no hay fotografía; el Super Admin de sistema puede carecer de foto sin generar un `404`.
- Los logs de `Microsoft.EntityFrameworkCore.Database.Command` quedaron en nivel `Warning` en la configuración general y de desarrollo. En la repetición final, el log de la API fue de unos 3 KB y no registró cada sentencia SQL.

## Fallos encontrados y estado

| Hallazgo durante la primera pasada | Estado |
| --- | --- |
| Filtro de ejercicio inexistente en la vista de órdenes de compra | Corregido y revalidado |
| Vista de facturas de ingresos no exponía ejercicio/ingreso autorizado | Corregido y revalidado |
| Registro faltante del servicio fiscal | Corregido; 13 rutas fiscales revisadas |
| Error visible en ISR semanal | Corregido y revalidado |
| La bitácora intentó cargar filtros con POST; el arnés la bloqueó inicialmente como escritura | Ruta de lectura permitida y revalidada; no se guardaron cambios |
| Imagen de perfil del usuario autenticado respondía HTTP 404 si no había foto | Corregido: ahora devuelve HTTP 204; además se bloquea la consulta de imágenes de otros usuarios |

## Verificaciones

- Solución .NET 10: compilación completa con cero advertencias y cero errores.
- Después del último ajuste se recompiló el portal Blazor: cero advertencias y cero errores.
- Pruebas automatizadas: 393 aprobadas, cero fallidas.
- Estado local al cierre: portal HTTP 200 en `localhost:5242`; API HTTP 401 en `localhost:5198` sin credencial, respuesta esperada para un endpoint autenticado.
- `Tools/Quality/Audit-CodeQuality.ps1 -FailOnViolations`: cero violaciones en las reglas revisadas de capturas vacías, mensajes técnicos al usuario, acceso a persistencia desde controladores y alineación de rutas/carpeta.
- La carga de usuarios y el muestreo de SQL se documentan en [Capacidad-Desarrollo-20261126.md](Capacidad-Desarrollo-20261126.md).

## Oportunidades estáticas restantes

La revisión todavía encuentra 30 manejadores `async void` y 23 llamadas `GetAllAsync` en la interfaz. Son candidatos para revisión individual: el conteo estático no demuestra por sí solo que cada caso sea un error, porque algunos son eventos síncronos o catálogos pequeños. Las llamadas de áreas en los cinco formularios descritos arriba se hacen una vez por apertura y se reutilizan. Los seis usos restantes de `int.MaxValue` son valores de ordenamiento para ordenar al final los registros sin posición, no tamaños de página.

El escaneo de rutas comprueba la ruta principal de cada componente; no navega individualmente las 469 URL alternativas. Las rutas alternativas que comparten componente conservan la misma lógica, y las 13 fiscales se verificaron además por separado.
