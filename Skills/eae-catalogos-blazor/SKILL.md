---
name: eae-catalogos-blazor
description: Crear o mejorar catalogos y formularios CRUD en Blazor con MudBlazor, integrados a una API existente. Usar para tablas, edicion y seleccion de registros; no para sitios de marketing ni interfaces de otra tecnologia.
---

# Catalogos y formularios Blazor

Identifica las versiones instaladas, un catalogo comparable y los componentes compartidos. En EGestion busca `Pages/Shared/GenericTable.razor` y los catalogos bajo `Pages/Modules/Nomina/Configuration/Catalogos`; no presupongas que esas rutas existan fuera de esa familia.

## Contrato y comportamiento

- Comprueba el DTO, nombres JSON, rutas, paginacion y envoltura de respuesta que consume el cliente. Un HTTP 200 puede contener un resultado de negocio fallido; muestra exito solo cuando ambos criterios del contrato lo indiquen.
- Usa los componentes existentes para busqueda, carga, tabla, dialogos y mensajes. Antes de modificar un componente generico, revisa sus consumidores; una necesidad de una pantalla no debe cambiar todas por accidente.
- Define estados de carga, vacio, error, edicion y guardado. Restablece indicadores en `finally`; impide doble envio mientras la peticion esta activa y conserva lo escrito si falla.
- En FK muestra etiquetas utiles y conserva el ID real. Para registros historicos con una referencia inactiva, permite verla sin ofrecerla como nueva seleccion si esa es la regla del proyecto.
- Valida requeridos, rangos y dependencias en UI y servidor. No uses valores arbitrarios como claves de usuario, sucursal, ejercicio o entidad relacionada.
- Evita cargar todo el catalogo para cada fila. Reutiliza consultas y pagina en servidor cuando el volumen lo exija. Maneja respuestas tardias al cambiar rapidamente filtros.
- Mantén filtros y pagina al cerrar un dialogo; tras una baja ajusta la pagina si queda vacia. Solo confirma el cierre cuando haya cambios sin guardar y ese comportamiento corresponda al producto.

## Apariencia y acceso

Respeta el sistema visual actual: etiquetas claras, acciones consistentes y dialogos que se ajusten al contenido y al ancho disponible. Conserva navegacion por teclado y foco razonable al abrir/cerrar dialogos. Ocultar un boton no sustituye el permiso del endpoint.

Verifica renderizado y al menos un guardado real en un entorno autorizado. Para un cambio visual aislado no agregues pruebas que solo repitan el marcado. Si no hay navegador disponible, compila y explicita la limitacion visual. Entrega la ruta de la pantalla y el comportamiento que cambio.
