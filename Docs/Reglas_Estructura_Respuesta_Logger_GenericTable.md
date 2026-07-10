# Reglas de estructura, respuesta al usuario y tablas

Este documento define las reglas transversales aplicadas a EGestion360. Su objetivo es que cada funcionalidad sea localizable, que ninguna operacion deje al usuario sin respuesta y que los detalles tecnicos permanezcan exclusivamente en los registros.

## 1. Carpetas alineadas con el menu

La pertenencia funcional tiene prioridad sobre el tipo tecnico del archivo.

```text
Pages/Modules/GRP/{Area}/{Subarea}/{Flujo}
Services/Modules/GRP/{Area}/{Subarea}
Controllers/Modules/GRP/{Area}/{Subarea}
```

Reglas:

- La primera carpeta funcional debe coincidir con el area principal de la ruta del menu.
- La pantalla, sus dialogos y componentes exclusivos deben permanecer juntos.
- Un dialogo sin ruta propia pertenece a la carpeta de la pantalla que lo abre.
- No se crean carpetas por tipo (`Dialogs`, `Pages`, `Models`) dentro de un flujo si eso separa archivos que evolucionan juntos.
- Los adaptadores que concentran muchas rutas heredadas pueden permanecer compartidos mientras todas las rutas terminen en la misma experiencia.

Se corrigieron dos grupos que no cumplian la regla:

- `Presupuesto/Egreso/Inversiones` paso a `Presupuesto/Tesoreria/Inversiones`.
- `Patrimonio/MisPeriodos` paso a `Almacen/MisPeriodos`.

Excepciones intencionales:

- `NominaOperaciones.razor` y `NomCatalogosSimples.razor` son adaptadores de rutas heredadas.
- `ContabilidadReportes.razor` concentra destinos de reportes que comparten la misma implementacion.
- `MenuPendiente.razor` representa opciones del menu aun no implementadas; no es una pantalla funcional definitiva.

Estas excepciones deben dividirse solo cuando exista una implementacion independiente, no para duplicar el mismo componente.

## 2. Contrato de respuesta al usuario

Toda operacion iniciada por el usuario debe terminar en uno de estos estados:

1. Confirmacion de exito.
2. Validacion accionable que indique que debe corregir.
3. Estado vacio que explique por que no hay informacion.
4. Error recuperable con opcion de reintento o siguiente paso.

Nunca se muestra `Exception.Message`, SQL, stack trace, rutas internas ni nombres de clases al usuario.

### Frontend

- Los servicios comunes devuelven `Success`, `Message`, `Code`, `Data` o `Items`; no devuelven objetos vacios sin explicacion.
- `BaseService` traduce errores HTTP a mensajes de sesion, permisos, datos invalidos, conflicto, limite de solicitudes o error inesperado.
- `BaseCrudPage` siempre informa acceso denegado, operacion concurrente, carga fallida, dialogo sin resultado, eliminacion y exportacion.
- `UserFacingExceptionMessages.ForDisplay` registra la excepcion completa y devuelve solo un mensaje sanitizado.
- Los procesos auxiliares que pueden usar un valor alternativo lo informan; por ejemplo, moneda predeterminada.
- Las cancelaciones esperadas y limpiezas se registran en nivel `Debug` sin mostrar una alarma innecesaria.
- `ErrorBoundary` evita una pantalla muerta ante un error no controlado y ofrece recargar la aplicacion.

### Backend

- `ApiExceptionMiddleware` registra excepciones no controladas con ruta, usuario, IP y `TraceId`.
- `ApiResultSanitizationFilter` registra todas las respuestas HTTP fallidas.
- Toda respuesta `5xx` se reemplaza por un mensaje seguro y conserva el `TraceId`.
- Las respuestas `4xx` conservan validaciones de negocio entendibles, pero se sustituyen si contienen patrones tecnicos de .NET, SQL o stack trace.
- El detalle original se conserva en Logger, nunca en el cuerpo entregado al navegador.

## 3. GenericTable

`GenericTable` es el punto comun para listados. Incluye:

- bloqueo y mensaje visible durante cargas o acciones;
- recarga manual con confirmacion;
- busqueda con debounce, Enter y opcion para limpiar;
- estado vacio distinto para lista sin datos, busqueda sin coincidencias y error de carga;
- reintento directo cuando falla la fuente de datos;
- selector de densidad compacta o comoda;
- selector de columnas que impide ocultar la ultima columna visible;
- ocultamiento automatico de columnas tecnicas de auditoria;
- persistencia local de densidad y columnas por tipo de tabla;
- opcion `Restablecer vista`;
- redimensionamiento y reordenamiento de columnas como mejora opcional;
- feedback seguro y Logger para exportar, agregar, recargar y acciones de fila.

Una pantalla nueva debe usar `GenericTable` salvo que su interaccion requiera una estructura distinta. En ese caso, debe documentar por que el componente comun no aplica.

## 4. Verificacion automatizada

Ejecutar desde la raiz del repositorio:

```powershell
powershell -ExecutionPolicy Bypass -File Tools\Quality\Audit-CodeQuality.ps1 -FailOnViolations
```

La auditoria falla si encuentra:

- `catch` vacios;
- `ex.Message` enviado a Snackbar;
- excepciones asignadas directamente a respuestas visuales;
- pantallas GRP cuya carpeta funcional no coincide con ninguna de sus rutas;
- ausencia del filtro global de sanitizacion de API.

## 5. Lista de revision para codigo nuevo

- La carpeta coincide con el area del menu y los dialogos estan junto a su pantalla.
- Cada `catch` registra la excepcion o una cancelacion esperada.
- El usuario recibe confirmacion, validacion, estado vacio o error recuperable.
- Ninguna respuesta usa directamente `ex.Message`.
- Los servicios devuelven un contrato completo aun cuando la API no responda.
- Los listados reutilizan `GenericTable` y prueban carga, vacio, error, reintento, busqueda y permisos.
