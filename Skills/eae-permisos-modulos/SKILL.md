---
name: eae-permisos-modulos
description: Implementar o revisar permisos por accion y alcance de datos al agregar modulos, menus y endpoints empresariales. Usar para roles, claims, areas o sucursales; no como auditoria general de seguridad por defecto.
---

# Permisos y alcance de datos

Mapea como el repositorio resuelve identidad, roles/claims, acciones y alcance organizacional. Identifica cual es la fuente de verdad para menu, endpoint y consulta. En EGestion localiza `IUserContextService`, los usos de `Authorize` y los servicios de area; verifica su implementacion antes de copiarla.

## Implementacion

- Especifica acciones relevantes: consultar, crear, modificar, desactivar y autorizar, solo las que existan en el modulo. Distingue autenticacion de permiso para ejecutar una accion.
- Resuelve identidad y ambitos en servidor. Si el cliente envia area, empresa, sucursal o ejercicio, valida que pertenezcan al usuario y que el registro solicitado este dentro del mismo alcance.
- Aplica el filtro de alcance antes de paginar o contar. Incluye consulta por ID, exportacion, adjuntos y operaciones por lote cuando formen parte del cambio; filtrar solo la lista deja vias de acceso abiertas.
- Alinea menu y botones con las mismas capacidades del servidor. Usa los mecanismos existentes de registro, sin asignar todas las acciones a todos los usuarios para hacer aparecer una pantalla.
- Evita permitir cambios de propietario o campos de auditoria mediante un DTO editable. Conserva la excepcion administrativa solo si esta definida en el proyecto; no inventes accesos privilegiados.
- Registra rechazos con el sistema de auditoria existente sin incluir tokens, contrasenas ni documentos completos.

## Evidencia

Prueba un actor autorizado, otro sin la accion y otro fuera del alcance. Para mutaciones verifica que el rechazo no haya cambiado datos. Comprueba una llamada directa al endpoint, no solo la visibilidad del boton. Usa identidades de prueba autorizadas; no cambies permisos de usuarios reales para simplificar la prueba.

Entrega la relacion accion/permiso/alcance aplicada, donde se valida y cuales casos se probaron. Si falta una decision sobre quien puede autorizar, deja esa operacion pendiente y continua las partes independientes en vez de conceder acceso por defecto.
