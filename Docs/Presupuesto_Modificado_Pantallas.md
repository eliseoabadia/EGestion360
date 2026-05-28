# Presupuesto Modificado - Pantallas

## Catalogos base

### PRES.EstatusAdecuacion

| Id | Descripcion | Color | Activo |
| --- | --- | --- | --- |
| 1 | REGISTRADO | #ADD8E6 | 1 |
| 2 | ELIMINADO | #FFCCCB | 1 |
| 3 | CONTABILIZADO | #90EE90 | 1 |
| 4 | RECHAZADO | #FFA07A | 1 |

### PRES.TipoAdecuacion

| Id | Descripcion | Uso |
| --- | --- | --- |
| 1 | COMPENSADA | Pantalla de adecuaciones compensadas |
| 2 | REDUCCION LIQUIDA | Pantalla de reducciones |
| 3 | AMPLIACION LIQUIDA | Pantalla de ampliaciones |

### PRES.TipoMovimiento

| Id | Descripcion | Uso |
| --- | --- | --- |
| 1 | Aumento Egresos | Movimientos de ampliacion |
| 2 | Reduccion Egresos | Movimientos de reduccion |

### PRES.AccionAdecuacionMaster

| Id | Accion | Comportamiento |
| --- | --- | --- |
| 1 | Solicitud creada | La captura se puede editar |
| 2 | Solicitar Autorizacion | La solicitud queda enviada para autorizacion |
| 3 | Autorizar Adecuacion | Bloquea altas, edicion y eliminacion |
| 4 | Rechazar Adecuacion | Marca el tramite como rechazado |

## Pantallas requeridas

### 1. Adecuaciones Compensadas

Ruta: `/Presupuesto/Egreso/Presupesto_Modificado/Adecuaciones_Compensadas`

Tablas:
- `PRES.EgreAdecuacion`
- `PRES.EgreAdecuacionDetalle`

Reglas:
- `FKIdTipoAdecuacion_PRES = 1`.
- El encabezado captura la justificacion general de la adecuacion: por que se requiere mover presupuesto.
- El detalle se divide en dos grids visibles al mismo tiempo:
  - `AMPLIACIONES`: registros con `FKIdTipoMovimiento_PRES = 1`.
  - `REDUCCIONES`: registros con `FKIdTipoMovimiento_PRES = 2`.
- Ambos grids se pueden crear, editar y eliminar mientras la adecuacion no este autorizada.
- Al autorizar, ambos grids quedan solo lectura.
- La pantalla debe mostrar claramente las acciones por fila en cada grid.
- El neto de una compensada debe ser visible: `ampliaciones - reducciones`.

Datos del detalle:
- El detalle debe tomar la informacion presupuestal desde autorizacion/suficiencia disponible segun el flujo de presupuesto.
- Cada movimiento debe conservar egreso/autorizacion origen, justificacion, fecha y montos mensuales.

### 2. Ampliaciones

Ruta: `/Presupuesto/Egreso/Presupesto_Modificado/Ampliaciones`

Reglas:
- `FKIdTipoAdecuacion_PRES = 3`.
- Solo captura movimientos de aumento: `FKIdTipoMovimiento_PRES = 1`.
- El encabezado describe por que se requiere el aumento.
- El grid de detalle debe mostrar acciones visibles para crear, editar y eliminar mientras no este autorizada.
- Al autorizar, la pantalla queda bloqueada.

### 3. Reducciones

Ruta: `/Presupuesto/Egreso/Presupesto_Modificado/Reducciones`

Reglas:
- `FKIdTipoAdecuacion_PRES = 2`.
- Solo captura movimientos de reduccion: `FKIdTipoMovimiento_PRES = 2`.
- El encabezado describe por que se requiere la reduccion.
- El grid de detalle debe mostrar acciones visibles para crear, editar y eliminar mientras no este autorizada.
- Al autorizar, la pantalla queda bloqueada.

## Acciones visibles

En el grid principal:
- Abrir detalle.
- Enviar solicitud de autorizacion.
- Autorizar, solo con claim `authorize`.
- Editar encabezado, mientras no este autorizado.
- Eliminar encabezado, mientras no este autorizado.

En los grids de detalle:
- Crear movimiento.
- Editar movimiento.
- Eliminar movimiento.

Las acciones deben seguir visibles como columna `Acciones`; si no aplican por estado, deben mostrarse deshabilitadas.

## Estados y autorizacion

- Una adecuacion inicia en `Solicitud creada`.
- El usuario puede enviar solicitud cuando el registro este completo y balanceado segun la regla contable/presupuestal aplicable.
- El usuario con permiso `authorize` puede autorizar.
- Una vez autorizada:
  - No se puede editar encabezado.
  - No se pueden crear, editar ni eliminar detalles.
  - Las acciones permanecen visibles pero deshabilitadas.

## Diseño

La pantalla de detalle debe seguir el estilo oscuro actual:
- Header con clave, justificacion larga y acciones principales.
- KPIs de ampliaciones, reducciones y neto.
- En adecuaciones compensadas, el area principal debe tener dos grids lado a lado: ampliaciones y reducciones.
- En ampliaciones/reducciones liquidas, el area principal puede usar un grid de movimientos y el panel contable.
