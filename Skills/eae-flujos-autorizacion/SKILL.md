---
name: eae-flujos-autorizacion
description: Implementar o corregir flujos de envio, autorizacion, rechazo y reenvio con estados persistentes y proteccion contra duplicados. Usar para procesos de negocio; no para automatizaciones programadas de Codex.
---

# Flujos de autorizacion persistentes

Deriva los estados de los requisitos y del codigo actual. No impongas un conjunto fijo a todos los proyectos. En EGestion inspecciona `BackEnd/EG.Application/Platform/Services/General/EnvioWorkflowService.cs` y sus consumidores; `SIS.EnvioWorkflow` es una convencion local, no una tabla universal.

## Invariantes del proceso

- Construye una tabla breve con origen, accion, destino, actor, condiciones y efecto. Distingue estado de envio de estado del documento: enviar a firma no equivale a estar firmado.
- Valida transiciones y campos editables en servidor, incluyendo llamadas directas. Bloquea una segunda solicitud incompatible mientras la primera esta en curso; no dependas solo de deshabilitar el boton.
- Define el identificador de operacion, actualizacion condicionada o mecanismo de concurrencia existente que garantiza un unico efecto. Examina que ocurre con doble clic, reintento HTTP y reinicio tras una escritura parcial.
- Cuando un efecto externo y una transaccion SQL no pueden ser atomicos, usa el mecanismo del proyecto para idempotencia, outbox o reconciliacion. No marques exito antes de confirmar el efecto ni reenvies a ciegas tras un timeout.
- En rechazo registra actor, fecha y motivo segun el contrato. Permite corregir y reenviar solo desde estados autorizados. Conserva trazabilidad; no borres el envio anterior para simular un documento nuevo.
- La UI debe reconstruir el estado desde la persistencia al recargar. Invalida cache local despues de una transicion y muestra el motivo de bloqueo o rechazo que el usuario necesita.

## Verificacion

Comprueba envio valido, doble envio, rechazo, correccion, reenvio, actor sin permiso y recarga. Agrega concurrencia y recuperacion tras fallo cuando el cambio toca esos mecanismos. No envies correos, documentos a firma ni solicitudes a terceros como prueba sin autorizacion explicita para ese envio.

Entrega la tabla de transiciones final, los efectos protegidos y evidencia de que un intento rechazado no altera el estado. No presentes un workflow visual como terminado si no persiste ni protege las transiciones.
