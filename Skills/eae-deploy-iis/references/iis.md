# IIS: configuracion y diagnostico por etapas

## Configurador

Verifica IIS, ASP.NET Core Module V2 del Hosting Bundle, y URL Rewrite/ARR si se usa proxy. Un backend self-contained sigue necesitando el modulo de IIS. Consulta documentacion oficial actual si hay dudas de compatibilidad; no descargues instaladores de origen desconocido.

Para un backend privado, configura un enlace loopback explicito y usa la misma direccion numerica en el proxy y en el ping del instalador. `localhost` puede resolver a IPv6 mientras IIS solo escucha IPv4; comprueba ambas direcciones antes de declarar que el backend fallo.

Pools dedicados, arquitectura compatible, sin CLR administrado para ASP.NET Core, inicio automatico y servicios WAS/W3SVC automaticos segun el destino. Si se necesita precarga, verifica Application Initialization y configura preload; no confundas disponibilidad bajo demanda con proceso precargado. Aplica permisos de lectura/ejecucion a los archivos y escritura solo a directorios que la aplicacion necesite.

Compara nombres, rutas y enlaces antes de modificar sitios existentes. Respalda archivos y configuracion; nunca reutilices un pool compartido sin revisar sus otros sitios. Un fallo parcial debe informar la etapa, lo que cambio y donde estan los respaldos, sin rollback automatico que sobrescriba datos nuevos.

## HTTPS y renovacion

Selecciona por SAN que cubra el dominio/IP, vigencia y clave privada; FriendlyName no basta. Al pegar una huella normaliza separadores y caracteres invisibles, verifica su formato y comprueba el certificado en el almacen correcto. Nunca registres claves privadas o contrasenas PFX.

Si ya hay renovacion automatica, inspecciona su configuracion e incluye el nuevo enlace en ese mecanismo preservando los existentes. Elegir un certificado vigente una vez no garantiza renovacion futura del puerto nuevo. No cambies la politica de confianza ni desactives validacion TLS para declarar una prueba exitosa.

## Diagnostico: probar la siguiente frontera

| Evidencia | Siguiente comprobacion |
|---|---|
| Ping loopback no responde | Estado sitio/pool, binding exacto, HTTP y logs; probar IP numerica y localhost |
| HTTP 500.19 | Modulos, XML, secciones bloqueadas y permisos |
| HTTP 500.30/500.31 | Hosting Bundle, arquitectura, eventos y fallo de arranque, incluida SQL |
| Ping interno funciona, proxy devuelve 502 | ARR, destino y regla de rewrite |
| HTTPS funciona en servidor pero fuera agota tiempo | Binding de frontend, firewall Windows y politica del proveedor realmente asignada |
| Error TLS | SAN, vigencia, cadena, enlace y certificado servido |
| UI carga pero no consulta | Red del navegador, configuracion API, autorizacion y respuesta del servidor |

Conserva codigo HTTP o error concreto. Captura la excepcion de los intentos de arranque; no la ocultes tras un mensaje generico. Reintenta de forma acotada solo cuando haya un cambio aplicado o una operacion en progreso.

En un firewall de proveedor, no basta con que una politica incluya el puerto: debe estar asignada al servidor objetivo. Agrega el puerto publico necesario a la politica correcta sin quitar acceso de administracion u otros sitios. Mantén privado el puerto de backend. No desactives firewalls para diagnosticar.

Fuentes para comprobar versiones y procedimientos cuando se necesiten:
- https://learn.microsoft.com/aspnet/core/host-and-deploy/iis/
- https://www.iis.net/downloads/microsoft/url-rewrite
- https://www.iis.net/downloads/microsoft/application-request-routing
