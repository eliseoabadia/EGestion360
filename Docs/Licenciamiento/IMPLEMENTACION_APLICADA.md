# Implementación aplicada y operación

Fecha: 12 de septiembre de 2026.

## Lo que ya quedó integrado

- Ocho módulos comerciales con códigos estables.
- Archivo `.lic` firmado con RSA-PSS/SHA-256 y clave pública incorporada en el backend.
- Identidad de instalación, serial y reloj guardados con protección de datos de ASP.NET Core.
- Tablas locales repetibles bajo el esquema `LIC`, creadas por el inicializador del backend.
- Pantalla **Configuración > Sistema > Licencia** para copiar la solicitud, importar el archivo y apagar o encender módulos contratados.
- Filtro global de API, filtrado del menú, protección de reportes y verificaciones de integraciones conocidas.
- Vencimiento calculado en cada operación; no necesita reiniciar IIS.
- Auditoría de importaciones aceptadas o rechazadas y cambios de estado local.

Las integraciones protegidas de forma explícita incluyen suficiencia Adquisiciones–Presupuesto, recepción desde orden Adquisiciones–Almacén, alta patrimonial desde orden, procesos presupuestales de Nómina y la generación de póliza al completar una salida de Almacén.

## Cómo emitir una licencia

1. En la instalación del cliente, abrir **Configuración > Sistema > Licencia** y copiar la solicitud.
2. En el equipo autorizado de GE360, preparar el contrato con un serial mayor al anterior, módulos y vigencias.
3. Ejecutar `GE360.Licensing.Generator.exe issue --request solicitud.json --contract contrato.json --out cliente.lic`.
4. Entregar únicamente `cliente.lic` e importarlo desde la pantalla.

La clave privada está en el almacén de certificados del usuario de Windows que inicializó el generador. No está en el repositorio, el `.exe`, IIS, SQL Server ni el archivo `.lic`. Otro usuario o equipo no podrá emitir con esa clave. Si se pierde el equipo, se debe crear un nuevo `kid`, incorporar su clave pública al backend y distribuir una versión actualizada antes de emitir renovaciones.

## Validación antes de producción

1. Respaldar una base de pruebas representativa.
2. Desplegar backend y frontend en IIS con una identidad estable para el pool de aplicaciones.
3. Confirmar que el inicializador crea las tablas `LIC` y que la solicitud conserva el mismo identificador después de reciclar el pool.
4. Emitir una licencia de prueba corta, importar y comprobar el vencimiento sin reinicio.
5. Probar llamadas directas a API para un módulo no contratado y confirmar respuesta `403` sin cambios de datos.
6. Probar las integraciones listadas con uno de sus módulos apagado.
7. Crear una cuenta técnica SQL con permisos mínimos y retirar `sa` de la cadena productiva.

No se ejecutó el script contra la base productiva ni se modificó IIS como parte de esta implementación de código.
