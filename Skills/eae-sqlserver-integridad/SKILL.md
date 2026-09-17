---
name: eae-sqlserver-integridad
description: Preparar cambios de esquema, catalogos, bajas logicas y correcciones de integridad en SQL Server con o sin Entity Framework. Usar para scripts o persistencia; no para asesoramiento fiscal ni administracion de otros motores.
---

# SQL Server e integridad de datos

Determina si el proyecto usa migraciones EF, esquema administrado mediante scripts o modelos generados desde la base. Sigue ese mecanismo; no introduzcas migraciones sobre un esquema generado sin revisar como se mantiene. Inspecciona nombres y relaciones reales antes de escribir SQL.

## Preparar cambios

- Identifica base y ambiente mediante configuracion autorizada sin imprimir credenciales. Parametriza nombres de despliegue en documentos; nunca copies contrasenas de una conversacion a una skill o ejemplo.
- Revisa PK, FK, restricciones unicas, nulabilidad, precision decimal, auditoria y dependencias activas. No decidas precision de importes o redondeo sin evidencia de la regla de negocio.
- Para bajas logicas, conserva historial y valida las referencias activas que impidan desactivar. Aplica esa regla en servidor y considera concurrencia; una consulta previa aislada no protege contra otra escritura simultanea. No conviertas baja logica a borrado fisico.
- Prepara scripts repetibles cuando correspondan a catalogos o despliegue. Una comprobacion de existencia debe verificar estructura relevante, no solo nombre. Si una estructura existente es incompatible, informa o falla antes de continuar con datos incorrectos.
- Evita colisiones de claves de catalogo: busca por clave estable de negocio; no supongas que un numero esta libre. En migraciones de datos conserva PK solo si la solicitud lo requiere y las FK y colisiones lo permiten.
- En cambios atomicos usa transaccion, `XACT_ABORT` y manejo de error adecuados a SQL Server. En EF con reintentos, sigue la estrategia de ejecucion de la aplicacion. No mezcles silenciosamente varias conexiones en una transaccion aparente.

## Validar sin confundir preparar con ejecutar

Generar SQL no autoriza ejecutarlo contra produccion. Usa metadatos o una base de prueba autorizada para validar. Antes de una ejecucion solicitada comprueba destino, impacto y posibilidad de recuperacion; no repitas una escritura tras un timeout sin determinar si ya se aplico.

Comprueba casos relevantes: segunda ejecucion, registro existente, FK invalida, duplicado, dependencia activa y rollback. Para optimizacion, usa evidencia de consulta y plan si estan disponibles; no agregues indices de forma indiscriminada.

Entrega el script, precondiciones, mecanismo de recuperacion realista y verificaciones antes/despues. No prometas rollback sin perdida si la operacion transforma o elimina informacion.
