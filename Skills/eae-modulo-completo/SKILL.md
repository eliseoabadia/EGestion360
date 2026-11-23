---
name: eae-modulo-completo
description: Crear o ampliar un modulo empresarial de extremo a extremo en una aplicacion existente, conectando persistencia, API, interfaz, menu y permisos. Usar para un modulo completo, no para ajustes aislados de apariencia.
---

# Modulo empresarial completo

Trabaja en el repositorio actual. Identifica su tecnologia y un modulo vecino antes de elegir carpetas, nombres o abstracciones. Las convenciones EGestion de [references/egestion.md](references/egestion.md) aplican solo si existen las rutas alli descritas; en otro proyecto usa sus equivalentes, sin convertirlo a .NET o Blazor.

## Del requerimiento a una operacion utilizable

- Extrae entidades, actores, operaciones, estados y limites organizacionales del pedido. Separa una duda de negocio que bloquea una operacion de una decision tecnica que puedes resolver con el codigo existente. No inventes reglas fiscales, contables ni de aprobacion.
- Traza una operacion vecina completa: ruta de pantalla, servicio HTTP, endpoint, contrato, servicio de aplicacion, persistencia y permiso. Busca por simbolo con `rg`; excluye publicaciones, binarios y dependencias. Si existe un indice, comprueba sus rutas contra el codigo actual antes de usarlo.
- Implementa una seccion vertical que realmente persista y consulte datos. Completa registros de dependencias, mapeos, validadores, endpoints, menu, permisos y pantalla que requiera el alcance. No presentes datos de ejemplo como integracion terminada.
- Mantén los contratos de transporte libres de dependencias de persistencia. Verifica consumidores antes de cambiar nombres o tipos. Prefiere cambios aditivos compatibles cuando el cliente pueda publicarse por separado.
- Resuelve en servidor el usuario y los ambitos autorizados; no confies en campos de auditoria enviados por el navegador. Aplica invariantes tambien a llamadas directas de API.
- Usa transacciones para cambios que deban ser atomicos. Si hay reintentos del proveedor, usa el mecanismo transaccional compatible ya existente. Evita duplicar efectos externos dentro de un bloque reintentable.

## Comprobacion y entrega

Compila los proyectos afectados. Verifica un recorrido de alta, consulta y modificacion, mas los casos que amenacen la integridad: acceso ajeno, FK invalida, duplicado o transicion prohibida segun el modulo. Distingue pruebas ejecutadas de propuestas; no ejecutes pruebas que escriban en una base real sin que ese destino forme parte del alcance autorizado.

Entrega rutas de entrada, cambios de esquema preparados, archivos relevantes y resultados de verificacion. No declares el modulo terminado si solo existen DTOs o pantallas. Una solicitud de codigo no implica instalarlo en produccion.
