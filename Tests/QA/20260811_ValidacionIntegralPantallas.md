# Validación integral de pantallas operativas

Fecha: 11 de agosto de 2026  
Ambiente: local, empresa 1, ejercicio 2026, sucursal **Sucursal Operativa**.  
Alcance: presupuesto, adquisiciones, cuentas por pagar, almacén y patrimonio.

## Resultado ejecutivo

La cadena completa fue comprobada previamente con dos expedientes aislados:

- **Normal `QAINT-NORMAL-20260811-215922`**: presupuesto → requisición → cotización → suficiencia → autorización → contrato/orden → recepción → suministro → resguardo.
- **Reversa `QAINT-REV-20260811-220307`**: presupuesto → requisición → cotización → suficiencia → autorización → contrato → factura → CLC → cheque → regreso a requisición. Se crearon las pólizas inversas 1020 a 1023, todas balanceadas.

La ronda actual probó las reglas de rechazo sin crear ni modificar documentos adicionales. Todas respondieron como se esperaba y con un mensaje apto para el usuario.

| Pantalla | Validación ejecutada | Resultado y mensaje visible |
|---|---|---|
| Anteproyecto de egresos | Guardar sin importe mensual | Bloqueado: “El anteproyecto debe contener al menos un importe mensual mayor a cero.” |
| Presupuesto autorizado | Crear sin anteproyecto activo | Bloqueado: “El presupuesto autorizado debe originarse en un anteproyecto activo.” |
| Requisición | Guardar sin área | Bloqueado: “El área solicitante es requerida.” |
| Detalle de requisición | Guardar sin requisición válida | Bloqueado: detalle o requisición inexistente/inactiva/no perteneciente a la empresa. |
| Cotización | Guardar sin requisición | Bloqueado: “Debe seleccionar una requisición.” |
| Detalle de cotización | Guardar vacío, con precio cero y sobre cotización ya ligada | Bloqueado: selección requerida; “El precio unitario debe ser mayor a cero”; o bloqueo por suficiencia, según corresponda. |
| Solicitud de suficiencia | Generar sin requisición | Bloqueado: “Debe seleccionar una requisición.” |
| Autorización de suficiencia | Guardar sin solicitud | Bloqueado: “Debe seleccionar una solicitud de suficiencia.” |
| Contrato | Guardar sin autorización | Bloqueado: “Debe seleccionar una autorización de suficiencia.” |
| Orden de compra | Guardar sin requisición | Bloqueado: “Debe seleccionar una requisición.” |
| Recepción de almacén | Guardar sin bien/servicio | Bloqueado: “Debe seleccionar un bien o servicio.” |
| Solicitud de salida | Guardar sin ejercicio | Bloqueado: “Debe seleccionar un ejercicio presupuestal.” |
| Resguardo | Guardar sin responsable | Bloqueado: “Debe seleccionar la persona responsable.” |
| Detalle de resguardo | Guardar sin resguardo | Bloqueado: “Debe seleccionar el resguardo.” |
| Factura | Guardar sin contrato/importe | Bloqueado: contrato autorizado y total mayor a cero requeridos. |
| CLC | Guardar sin contrato/importe | Bloqueado: contrato e importe mayor a cero requeridos. |
| Cheque / transferencia | Guardar sin CLC | Bloqueado: “Debe seleccionar una CLC para generar la provisión de pago.” |

## Reglas de flujo comprobadas

| Regla | Resultado |
|---|---|
| Autorizar presupuesto inexistente | Bloqueado con `NOT_FOUND`; no existe o no está activo. |
| Reautorizar una orden autorizada | Bloqueado con `LOCKED`; sólo se autorizan órdenes en estatus inicial. |
| Reautorizar una salida final | Bloqueado con `LOCKED`; la solicitud está autorizada/final. |
| Modificar/eliminar cotización usada por una suficiencia | Bloqueado con `LOCKED`; se conserva la trazabilidad. |
| Motivo de reversa menor a 10 caracteres | Bloqueado; se solicita un motivo suficiente. |
| Reversa repetida del mismo cheque | Exitosa e idempotente; se reutiliza el regreso existente y no duplica pólizas. |
| Cuerpo de reversa vacío o malformado | Bloqueado con el mismo mensaje de motivo requerido, sin error 500. |

## Validación visual

- Inicio de sesión correcto y selección explícita de sucursal cuando el usuario tiene más de una.
- La pantalla **Cotización** presenta el mensaje “Selecciona un año presupuestal en el encabezado” si se entra sin el contexto requerido.
- Las pantallas de listado conservan un estado vacío explicativo: “Revisa el contexto activo, permisos o filtros aplicados.”

## Mejoras aplicadas durante la prueba

1. **Detalle de cotización** valida en el servidor cotización, bien de la misma requisición, importe positivo, empresa, ejercicio y bloqueos posteriores. Evita mensajes genéricos y cualquier edición/eliminación después de suficiencia u orden de compra.
2. **Reversa de cheque** convierte un cuerpo de solicitud vacío/malformado en la validación recuperable del motivo requerido.

## Nota de operación

Una reversa financiera completa no puede coexistir con una salida de almacén activa, recepción cerrada o recepción contabilizada. Para probar devolución física se requiere un proceso formal de devolución de almacén antes de ejecutar el regreso del cheque.
