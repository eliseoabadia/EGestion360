---
name: eae-deploy-iis
description: Preparar paquetes de frontend y backend .NET para IIS o diagnosticar su arranque, proxy HTTPS y acceso externo. Usar para ZIP y configuradores de IIS; no para desplegar en proveedores ajenos a IIS.
---

# Publicacion .NET en IIS

Obtén de la solicitud o configuracion del destino: nombres de paquetes y sitios, carpetas, URL publica, enlace interno, arquitectura y origen seguro de la conexion. No reutilices IP, puertos, bases ni contrasenas de despliegues previos por defecto. Lee [references/iis.md](references/iis.md) al preparar un configurador o diagnosticar conectividad.

## Preparar la entrega

- Revisa cambios locales y `.csproj`; publica el estado solicitado sin deshacer trabajo del usuario. Usa carpetas nuevas o controla explicitamente las colisiones; no mezcles archivos viejos sin saber su compatibilidad.
- Compila y publica con la version del proyecto. Mantén cliente, manifiestos, hashes y archivos comprimidos consistentes. No sustituyas DLLs dentro de Blazor publicado. Si ajustas configuracion estatica despues de publicar, elimina o regenera sus variantes comprimidas y revisa si figura en un manifiesto con hash.
- Configura la API local desde el servidor mediante proxy del frontend si ese es el diseño. `localhost` en JavaScript apunta al equipo del visitante; utiliza origen relativo para la API y un destino interno en IIS.
- Verifica configuracion efectiva de produccion: conexion, CORS, issuer/audience si corresponden, entorno, rutas de archivos, logging y precedencia de variables. No incluyas credenciales en el frontend, guia publica o salida de validacion.
- Inspecciona inicializadores del backend antes de arrancarlo como prueba: pueden crear tablas o datos. Preparar paquetes no implica ejecutarlos contra produccion.
- Si piden IIS con persistencia tras reinicio, configura sitios y pools de IIS; no lo sustituyas por procesos de consola o tareas programadas. Un ejecutable configurador es opcional y debe comprobar prerrequisitos, colisiones y respaldos antes de cambiar el servidor.

## Validacion y entrega

Verifica estructura interna y lectura del archivo comprimido, configuracion y SHA-256. Para scripts PowerShell revisa sintaxis y la diferencia entre comparar una cadena y filtrar un arreglo (`-match`/`-notmatch`); registra codigos de salida de herramientas nativas.

Entrega paquetes, instrucciones de instalacion y limites de verificacion. Separa compilacion, instalacion, arranque local, proxy, acceso externo, consulta de BD y prueba tras reinicio: un ping exitoso no demuestra todas esas condiciones. Solo afirma cada una cuando haya evidencia. No reinicies servicios compartidos o el servidor como diagnostico inicial.
