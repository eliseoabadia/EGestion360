# Backlog de implementación: licenciamiento por instalación

> **Estado actualizado:** este backlog corresponde a la opción centralizada. El backlog vigente para la primera versión está en [PLAN_IMPLEMENTACION_SIMPLE.md](PLAN_IMPLEMENTACION_SIMPLE.md).

Este backlog convierte el [plan](PLAN_LICENCIAMIENTO_MODULAR.md), el [modelo de datos](MODELO_DATOS_LICENCIAMIENTO.md) y la [matriz de capacidades](MATRIZ_CAPACIDADES_INICIALES.md) en trabajo entregable. No incluye cambios ejecutados todavía.

## Hito 0 — Decisiones de producto

| ID | Trabajo | Resultado para cerrar el hito |
|---|---|---|
| L0.1 | Delimitar Núcleo y Administración funcional | Lista aprobada de pantallas, catálogos y operaciones que siempre están disponibles |
| L0.2 | Aprobar los ocho módulos y las integraciones vendibles | Matriz con propietario, requisito, inclusión comercial y comportamiento sin el módulo dependiente |
| L0.3 | Confirmar prueba, suscripción, gracia, consulta histórica y operación offline | Política `ESTANDAR-V1` aprobada con días y tiempos exactos |
| L0.4 | Elegir hospedaje, dominio e identidad del panel central | Ambientes, responsable de claves, respaldo y monitoreo definidos |
| L0.5 | Revisar procedimientos, triggers y trabajos reales | Lista de procesos fuera de HTTP y sus capacidades asignadas |

No iniciar desarrollo de filtros masivos mientras L0.1 y L0.2 sigan abiertos. Sin esas reglas podríamos bloquear operaciones que ya vendimos o habilitar una integración no contratada.

## Hito 1 — Fundaciones centrales

| ID | Trabajo | Dependencia | Definición de terminado |
|---|---|---|---|
| L1.1 | Crear solución y despliegue del servicio central | L0.4 | API, panel y base separados del sistema del cliente; configuración sin secretos versionados |
| L1.2 | Implementar tablas centrales y scripts repetibles | L0.3 | Modelo `LIC` instalado dos veces en prueba sin duplicados; PK, FK, checks, índices y RowVersion validados |
| L1.3 | Sembrar módulos, política y capacidades aprobadas | L0.1-L0.3 | Catálogo inmutable por versión y validador de dependencias funcionando |
| L1.4 | Crear administración comercial de clientes e instalaciones | L1.2 | Alta, edición y auditoría con roles comerciales separados de usuarios cliente |
| L1.5 | Implementar comandos idempotentes | L1.2 | Otorgar, renovar, suspender, reactivar y transferir no duplican días ni eventos al reintentarse |
| L1.6 | Implementar firma, rotación y custodia de claves | L0.4 | Clave privada fuera de la base; `kid`, emisión y verificación con pruebas de rotación |

## Hito 2 — Activación y evaluación local

| ID | Trabajo | Dependencia | Definición de terminado |
|---|---|---|---|
| L2.1 | Crear tablas locales y almacenamiento de sobre firmado | L1.2 | La instalación no puede crear derechos modificando campos locales |
| L2.2 | Generar y proteger identidad criptográfica local | L1.6 | La privada no aparece en logs, configuración, navegador ni respaldo SQL normal |
| L2.3 | Consumir código de activación de un solo uso | L1.5-L2.2 | Dos activaciones concurrentes producen un solo resultado; reintento mismo RequestId recupera el resultado |
| L2.4 | Sincronizador de fondo y validación de firma | L1.6-L2.1 | Arranque no falla si la central está caída; reintentos acotados, cancelación ordenada y registro de diagnóstico |
| L2.5 | Evaluador local por capacidad | L2.4 | Distingue no contratado, vencido, suspendido, offline vencido y dependencia faltante |
| L2.6 | Pantalla local de licencia y avisos | L2.5 | Administrador ve módulos, fechas, último contacto y mensajes sin secretos |

## Hito 3 — Control transversal en EGestion

| ID | Trabajo | Dependencia | Definición de terminado |
|---|---|---|---|
| L3.1 | Registrar evaluador en el backend | L2.5 | Licencia se verifica después de autenticación y antes de operaciones comerciales |
| L3.2 | Eliminar bypass comercial de SuperAdmin | L3.1 | SuperAdmin conserva permisos funcionales, pero no puede ejecutar módulo vencido o suspendido |
| L3.3 | Controlar menú, inicio, búsqueda y navegación directa | L2.6-L3.1 | Menú se refresca al cambiar revisión; una URL directa recibe motivo correcto desde servidor |
| L3.4 | Clasificar endpoints y servicios | L0.5-L3.1 | Recurso comercial sin capacidad asignada falla de manera segura y queda diagnosticado |
| L3.5 | Clasificar reportes, exportaciones y documentos | L0.5-L3.1 | Un visor compartido no permite obtener datos de otro módulo por nombre o URL |
| L3.6 | Actualizar cachés de menú y permisos | L3.3 | Una sesión abierta recibe el cambio sin exigir cierre de sesión y sin permitir operación antigua |

## Hito 4 — Piloto: Almacén y sus dependencias

| ID | Trabajo | Dependencia | Definición de terminado |
|---|---|---|---|
| L4.1 | Inventariar Almacén, recepción y salidas | L0.2 | Cada endpoint, pantalla, servicio y SP tiene capacidad y efecto clasificados |
| L4.2 | Resolver recepción desde orden | L4.1 | Con GRP.ALMA sin GRP.ADQ queda clara la operación permitida; no hay consulta general de compras por accidente |
| L4.3 | Resolver póliza de salida | L4.1 | Regla aprobada para GRP.CONTA; una salida no queda incompleta ni genera póliza sin derecho de integración |
| L4.4 | Pruebas de vencimiento/suspensión | L3.1-L4.3 | Cambiar licencia no interrumpe una transacción ni permite la siguiente operación no autorizada |

## Hito 5 — Extensión por dominio

| Orden | Dominio | Trabajo de cierre |
|---|---|---|
| 1 | Adquisiciones y Presupuesto | Requisiciones, disponibilidad, suficiencia, operaciones presupuestales y reportes |
| 2 | Patrimonio | Alta independiente, bienes desde compra, inventario, bajas y documentos |
| 3 | Nómina | Cálculo, catálogos, acciones presupuestales y procesos recurrentes |
| 4 | PBR | Anteproyectos, MIR, indicadores, programas, tablero y consultas compartidas |
| 5 | Administración funcional | Lo que no haya quedado en Núcleo; evitar vender controles indispensables para recuperar una licencia |

Cada dominio se entrega con pruebas de usuario autorizado, usuario sin permiso, módulo no contratado, vencido, suspendido, URL directa, reporte/exportación y operación integrada.

## Hito 6 — Operación comercial y despliegue

| ID | Trabajo | Resultado para cerrar el hito |
|---|---|---|
| L6.1 | Historial, búsqueda y soporte | Operador ve quién cambió la licencia, qué cambió, cuándo y si la instalación confirmó la revisión |
| L6.2 | Alertas de vencimiento | Avisos en aplicación y panel; sin enviar mensajes externos no autorizados |
| L6.3 | Transferencia y recuperación | Procedimiento probado de cambio de servidor, restauración y revocación de identidad anterior |
| L6.4 | Actualización de instalaciones existentes | Perfil inicial explícito, respaldo y reversión documentada; nunca asumir que todo debe quedar habilitado |
| L6.5 | Observabilidad y respaldo | Monitoreo de sincronización, fallos de firma, versiones, copias de la base central y prueba de restauración |

## Primer incremento demostrable

La primera demostración no necesita todos los módulos. Debe demostrar el ciclo completo con una instalación de prueba:

1. Crear cliente e instalación en el panel central.
2. Conceder `GRP.ALMA` como prueba de 15 días.
3. Activar mediante código de un uso.
4. Mostrar Almacén en menú y bloquear una operación de otro módulo.
5. Suspender Almacén desde el panel y observar el cambio en la instalación conectada.
6. Renovarlo y comprobar recuperación sin reinstalar.
7. Simular pérdida de conexión y comprobar el límite offline acordado.

Este incremento valida arquitectura, firma, base de datos, sincronización, interfaz y control real del servidor antes de clasificar todas las pantallas.

## Riesgos que no se deben dejar para el final

- Dependencias que ejecutan procedimientos SQL dentro de una transacción.
- Reportes y exportaciones que recuperan datos por un nombre genérico.
- Procesos en segundo plano, triggers o tareas SQL sin una llamada HTTP visible.
- Cachés de menú, permisos y estado de autenticación en sesiones ya abiertas.
- Diferencia entre vencer comercialmente, suspender por falta de pago y revocar una identidad comprometida.
- Restauración de respaldos o cambios de reloj para intentar reiniciar una prueba.

Un hito no se considera terminado por tener tablas o pantallas: debe demostrar el comportamiento bajo un caso permitido y uno rechazado, conservar auditoría y no modificar datos cuando rechaza.
