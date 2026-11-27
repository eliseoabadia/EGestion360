# Prueba de capacidad en desarrollo

**Fecha:** 26 de noviembre de 2026  
**Entorno:** API y portal locales, perfil `Development`, SQL Server local  
**Modo:** consultas paginadas autenticadas, sin operaciones de negocio de escritura

## Carga aplicada

Cada usuario virtual ejecutó en rotación cinco consultas `GetAllPaginado` de 10 filas: requisiciones, órdenes de compra, pólizas, bienes y empleados. Se compartió una sesión autenticada de desarrollo entre los usuarios virtuales. Cada nivel duró 15 segundos, con una pausa de 1 segundo entre solicitudes y máximo de 200 usuarios, límite del ejecutor.

| Usuarios virtuales | Solicitudes | Fallidas | Solicitudes/s | p95 | p99 | Máximo |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 20 | 300 | 0 | 19.00 | 62 ms | 75 ms | 91 ms |
| 40 | 597 | 0 | 37.38 | 39 ms | 56 ms | 68 ms |
| 80 | 1,165 | 0 | 73.01 | 59 ms | 80 ms | 132 ms |
| 120 | 1,738 | 0 | 108.79 | 139 ms | 233 ms | 315 ms |
| 160 | 2,281 | 0 | 141.76 | 174 ms | 284 ms | 516 ms |
| 200 | 2,787 | 0 | 172.37 | 373 ms | 511 ms | 650 ms |

Después se bajó el nivel de log de comandos SQL a `Warning` y se repitieron los dos niveles superiores con el portal y la API ya calientes:

| Usuarios virtuales | Solicitudes | Fallidas | Solicitudes/s | p95 | p99 | Máximo |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 120 | 1,772 | 0 | 111.29 | 24 ms | 38 ms | 100 ms |
| 200 | 2,963 | 0 | 185.24 | 22 ms | 31 ms | 46 ms |

El resultado observado es **al menos 200 usuarios virtuales para este patrón de lecturas**; no se alcanzó el techo de capacidad. La segunda medición es la más representativa de la configuración final, con 185 solicitudes por segundo y cero fallos.

## SQL Server

Se tomaron 93 muestras, una cada 2 segundos durante las dos ventanas de carga. No se observaron solicitudes bloqueadas, consultas de más de 5 segundos ni incrementos en el contador de deadlocks del servidor. Por el intervalo de muestreo, esto descarta bloqueos prolongados en esas ventanas; no demuestra que nunca pueda existir un bloqueo breve.

## Límites de interpretación

- Los 200 usuarios virtuales compartieron una sesión autenticada; no se probaron 200 inicios de sesión independientes.
- Sólo se probaron cinco consultas de lectura paginada. No se probaron escrituras, importaciones, reportes pesados, autorizaciones ni carga de producción.
- El límite de 200 pertenece al ejecutor de la prueba; no es el límite medido de la aplicación.
- La API ejecuta sus inicializadores normales al arrancar. Además de verificar esquemas, el servicio de licenciamiento actualiza su estado interno en `LIC.EstadoInstalacion`. Las solicitudes de carga no llamaron endpoints de alta, edición ni autorización de negocio.

## Evidencia local

Los resultados sin credenciales ni tokens quedaron en `tmp/capacity-dev/capacity-final.json`, `tmp/capacity-dev/capacity-final-postlog.json` y `tmp/capacity-dev/resources-final.json`. La prueba de exportación filtrada está resumida en `tmp/capacity-dev/export-check.json`.
