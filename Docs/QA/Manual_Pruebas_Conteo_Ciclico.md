# Manual de pruebas — Conteo cíclico

**Versión del manual:** 1.0  
**Fecha:** 24/07/2026  
**Módulo:** Almacén / Conteo cíclico  
**Objetivo:** validar la planeación ABC, generación de conteos, conteo a ciegas, revisión de diferencias y cierre.

> Ejecutar únicamente en un ambiente de pruebas. No utilizar datos ni períodos productivos.

## 1. Alcance

El flujo que debe aprobarse es:

1. Preparar existencias y mínimos.
2. Calcular la clasificación ABC.
3. Programar ubicación, frecuencia y próxima fecha.
4. Generar conteos sugeridos por fecha o existencia mínima.
5. Iniciar el período.
6. Realizar el conteo a ciegas.
7. Completar y revisar diferencias.
8. Aprobar y cerrar.

Estados esperados:

`Pendiente → En Proceso → Completado → Cerrado`

## 2. Perfiles necesarios

Preparar tres usuarios distintos cuando sea posible:

| Perfil | Uso en las pruebas |
|---|---|
| Administrador de almacén | Crear período, calcular ABC y generar sugeridos. |
| Responsable | Ejecutar lecturas o escaneos del conteo. |
| Supervisor | Revisar diferencias y cerrar períodos que requieren aprobación. |

El administrador debe contar con permisos de consulta, alta, modificación y autorización del submódulo de conteo.

## 3. Datos previos

Crear o identificar al menos cuatro tipos de bien:

| Dato | Configuración requerida |
|---|---|
| BIEN-A | Existencia positiva, costo alto y mínimo menor que la existencia. |
| BIEN-B | Existencia positiva, costo medio y mínimo menor que la existencia. |
| BIEN-C | Existencia positiva y costo bajo. |
| BIEN-UMBRAL | Existencia positiva igual o menor que su existencia mínima. |

Recomendaciones:

- Asignar entradas de almacén a un área física.
- Verificar que los artículos tengan costo unitario o costo promedio.
- Para probar lecturas individuales, registrar bienes identificables correspondientes al tipo de bien.
- Crear un período con estatus `Pendiente`, responsable y supervisor.
- Activar “Requiere aprobación de supervisor” para probar el cierre restringido.

Si todas las existencias y costos están en cero, es correcto que todos los artículos queden clasificados como `C`. Un artículo con existencia cero no debe generar una alerta de existencia mínima.

## 4. Evidencia requerida

Por cada caso guardar:

- Captura antes de ejecutar la acción.
- Captura del mensaje mostrado por el sistema.
- Captura del resultado final o del estatus.
- Usuario utilizado.
- Fecha y hora.
- Identificador del período y del conteo.
- Resultado: `APROBADO` o `RECHAZADO`.

Nombre sugerido para archivos:

`CC-<caso>_<periodo>_<resultado>_<fecha>.png`

Ejemplo: `CC-05_PER-ABC-01_APROBADO_20260724.png`.

## 5. Casos funcionales

### CC-01 — Crear período válido

1. Abrir **Configuración → Almacén → Períodos de conteo**.
2. Pulsar el botón de alta.
3. Capturar código, nombre, sucursal, responsable y fechas.
4. Seleccionar supervisor y activar la aprobación de supervisor.
5. Guardar.

**Resultado esperado**

- El período se guarda en estatus `Pendiente`.
- Se muestra responsable, supervisor y sucursal correctos.
- Aparece la atención `Falta iniciar`.
- El avance inicial es cero.

### CC-02 — Validaciones del período

Repetir el alta omitiendo, uno por uno:

- Código.
- Nombre.
- Sucursal.
- Responsable.
- Supervisor cuando se requiere aprobación.

Después intentar crear otro período con el mismo código y sucursal.

**Resultado esperado**

- El sistema no guarda datos incompletos.
- Informa claramente qué dato falta.
- No permite códigos activos duplicados en la misma sucursal.

### CC-03 — Calcular clasificación ABC

1. Abrir el panel **Planeación inteligente ABC, ubicación y umbrales**.
2. Pulsar **Recalcular ABC**.
3. Esperar el mensaje de confirmación.
4. Revisar los indicadores A, B y C.
5. Localizar BIEN-A, BIEN-B y BIEN-C.

**Resultado esperado**

- Cada artículo aparece una sola vez.
- Los artículos de mayor valor aparecen primero y tienden a clasificación `A`.
- Los de valor intermedio se clasifican `B`.
- Los de menor valor se clasifican `C`.
- Valores predeterminados: A cada 30 días, B cada 90 y C cada 180.
- La ubicación corresponde al área con mayor existencia registrada, cuando existe.

### CC-04 — Recalcular sin valor de inventario

1. Identificar un artículo con existencia y costo en cero.
2. Recalcular ABC.

**Resultado esperado**

- El artículo puede quedar clasificado como `C`.
- No aparece como `Bajo mínimo` solamente por tener existencia cero.
- No se genera automáticamente un conteo por umbral para ese artículo.

### CC-05 — Editar programación por artículo

1. En el panel ABC, pulsar el icono de calendario de un artículo.
2. Seleccionar un área física.
3. Capturar frecuencia de `17` días.
4. Capturar como próxima fecha el día actual.
5. Mantener activa la generación por existencia mínima.
6. Guardar.
7. Pulsar **Recalcular ABC** nuevamente.

**Resultado esperado**

- El artículo muestra el área seleccionada.
- Conserva la frecuencia personalizada de 17 días después del recálculo.
- La próxima fecha queda visible.
- Una frecuencia cero, negativa o mayor que 3650 debe rechazarse.
- Una próxima fecha anterior al día actual debe rechazarse.

### CC-06 — Detectar existencia mínima

1. Confirmar que BIEN-UMBRAL tenga existencia positiva.
2. Configurar una existencia mínima igual o mayor que la existencia actual.
3. Recalcular ABC.

**Resultado esperado**

- BIEN-UMBRAL aparece con motivo `Bajo mínimo`.
- El indicador “requieren atención” aumenta.
- Un artículo con existencia cero no se marca por umbral.

### CC-07 — Generar conteos sugeridos

1. Mantener el período en `Pendiente`.
2. Dejar al menos un artículo con próxima fecha igual al día actual.
3. Dejar BIEN-UMBRAL bajo mínimo.
4. En la fila del período, pulsar el icono de varita.
5. Abrir los conteos correspondientes al período.

**Resultado esperado**

- Se muestra cuántos conteos fueron generados.
- Los vencidos incluyen una etiqueta como `[ABC-A]`, `[ABC-B]` o `[ABC-C]`.
- Los generados por mínimo incluyen `[UMBRAL]`.
- La descripción puede incluir el área física.
- Solo se generan artículos vencidos o bajo mínimo.
- El total de artículos del período se actualiza.

### CC-08 — Evitar duplicados

1. Volver a pulsar la varita en el mismo período.
2. Revisar nuevamente los conteos.

**Resultado esperado**

- No se crea un segundo conteo para el mismo tipo de bien.
- El sistema informa que no hay nuevos artículos pendientes o genera únicamente los nuevos.
- Un artículo que ya tiene un conteo en otro período activo tampoco se duplica.

### CC-09 — Bloquear generación fuera de Pendiente

1. Iniciar un período.
2. Intentar invocar nuevamente la generación de sugeridos.

**Resultado esperado**

- La operación se rechaza.
- El mensaje indica que solo se permite en períodos pendientes.
- No se agregan conteos.

### CC-10 — Iniciar período

1. En un período `Pendiente` con conteos, pulsar **Iniciar conteo**.
2. Confirmar la operación.

**Resultado esperado**

- El estatus cambia a `En Proceso`.
- Ya no se permite editar ni eliminar el período.
- Los conteos existentes se conservan.
- Si no existen conteos sugeridos, el sistema genera conteos para existencias positivas.
- Si no hay ninguna existencia positiva ni conteo manual, el inicio se rechaza.

### CC-11 — Conteo a ciegas

1. Ingresar con el usuario responsable.
2. Abrir **Mis conteos**.
3. Abrir un conteo en proceso.

**Resultado esperado**

- Durante `En Proceso` no se muestra la cantidad esperada de inventario.
- El responsable puede ver qué artículo debe contar y registrar sus lecturas.
- La cantidad esperada y la diferencia aparecen después de completar.

### CC-12 — Registrar lectura válida

1. Abrir el escáner de un conteo en proceso.
2. Leer o capturar un bien perteneciente al tipo esperado.
3. Guardar la lectura.

**Resultado esperado**

- La lectura queda asociada al conteo correcto.
- Se registra como persona participante al usuario autenticado.
- El contador de lecturas aumenta.
- La fecha mostrada corresponde a la operación real.

### CC-13 — Rechazar lectura inválida o duplicada

Ejecutar por separado:

1. Escanear dos veces el mismo bien.
2. Escanear un bien de otro tipo.
3. Intentar capturar cantidad negativa.
4. Intentar registrar una fecha fuera del período.
5. Intentar agregar lecturas cuando el período no está `En Proceso`.

**Resultado esperado**

- Ninguna lectura inválida se guarda.
- El mensaje explica si es duplicado, tipo incorrecto, cantidad inválida, fecha inválida o estatus no permitido.
- El total de lecturas válidas no cambia.

### CC-14 — Completar con conteos pendientes

1. Dejar al menos un conteo con existencia esperada positiva sin lecturas.
2. Pulsar **Completar conteo**.

**Resultado esperado**

- El período permanece `En Proceso`.
- El sistema identifica los conteos que todavía no tienen lecturas.

### CC-15 — Completar período y mostrar diferencias

1. Registrar lecturas en todos los conteos con existencia positiva.
2. En un artículo registrar la cantidad exacta.
3. En otro registrar una cantidad diferente.
4. Pulsar **Completar conteo**.

**Resultado esperado**

- El estatus cambia a `Completado`.
- Se muestra cantidad esperada, cantidad contada y diferencia.
- El avance y el total de artículos se actualizan.
- El artículo exacto aparece concluido.
- El artículo distinto aparece como diferencia y requiere atención.

### CC-16 — Restringir cierre con diferencias

1. Ingresar como responsable, sin privilegio de supervisor.
2. Intentar cerrar un período completado con diferencias.

**Resultado esperado**

- El cierre se rechaza.
- Se informa que un supervisor debe revisar las diferencias.
- El período permanece `Completado`.

### CC-17 — Cerrar como supervisor

1. Ingresar como el supervisor asignado.
2. Revisar las diferencias.
3. Pulsar **Cerrar conteo** y confirmar.

**Resultado esperado**

- El estatus cambia a `Cerrado`.
- Se registra la fecha de cierre.
- Ya no se permiten lecturas ni modificaciones.
- Para los artículos contados se actualiza la última fecha de conteo.
- La próxima fecha se calcula sumando su frecuencia configurada.
- La alerta por umbral queda atendida hasta el siguiente recálculo de existencias.

### CC-18 — Búsqueda y paginación

1. Buscar por código, nombre y sucursal.
2. Cambiar el tamaño de página.
3. Avanzar y regresar entre páginas.

**Resultado esperado**

- Los resultados corresponden al filtro.
- No se repiten ni desaparecen registros al cambiar de página.
- El total informado coincide con los registros disponibles.

## 6. Pruebas de concurrencia recomendadas

### CC-19 — Dos usuarios escanean el mismo bien

1. Abrir el mismo conteo con dos usuarios.
2. Intentar registrar simultáneamente el mismo bien.

**Resultado esperado**

- Solo una lectura queda registrada.
- El segundo usuario recibe el mensaje de duplicado.

### CC-20 — Cambio de estatus durante captura

1. El responsable mantiene abierto el diálogo de captura.
2. El supervisor completa o cierra el período desde otra sesión.
3. El responsable intenta guardar otra lectura.

**Resultado esperado**

- El servidor rechaza la lectura por estatus.
- La interfaz muestra el error y no simula un guardado exitoso.

## 7. Consultas de verificación para QA técnico

Estas consultas son de solo lectura.

### Distribución ABC

```sql
SELECT ClasificacionABC,
       COUNT(*) AS Articulos,
       MIN(FrecuenciaDias) AS FrecuenciaMinima,
       MAX(FrecuenciaDias) AS FrecuenciaMaxima
FROM ALMA.PlanConteoCiclico
WHERE Activo = 1
GROUP BY ClasificacionABC
ORDER BY ClasificacionABC;
```

### Artículos vencidos o bajo mínimo

```sql
SELECT P.PKIdPlanConteoCiclico,
       T.Descripcion,
       P.ClasificacionABC,
       P.ExistenciaActual,
       P.ExistenciaMinima,
       P.ProximaFechaConteo,
       P.RequiereConteoPorUmbral
FROM ALMA.PlanConteoCiclico P
INNER JOIN ALMA.TipoBien T
        ON T.PKIdTipoBien = P.FKIdTipoBien_ALMA
WHERE P.Activo = 1
  AND (P.ProximaFechaConteo <= CONVERT(date, GETDATE())
       OR P.RequiereConteoPorUmbral = 1)
ORDER BY P.ProximaFechaConteo, T.Descripcion;
```

### Duplicados dentro de un período

```sql
SELECT FKIdPeriodoConteo_ALMA,
       FKIdTipoBien_ALMA,
       COUNT(*) AS Total
FROM ALMA.Conteo
WHERE Activo = 1
GROUP BY FKIdPeriodoConteo_ALMA, FKIdTipoBien_ALMA
HAVING COUNT(*) > 1;
```

El resultado esperado es cero filas.

### Conteos generados automáticamente

```sql
SELECT C.PKIdConteo,
       C.FKIdPeriodoConteo_ALMA,
       C.Descripcion,
       C.CantidadInventario,
       C.FechaInicio
FROM ALMA.Conteo C
WHERE C.Activo = 1
  AND (C.Descripcion LIKE '[[]ABC-%'
       OR C.Descripcion LIKE '[[]UMBRAL[]]%')
ORDER BY C.PKIdConteo DESC;
```

## 8. Criterios para aprobar la entrega

La funcionalidad se considera aprobada cuando:

- Los casos CC-01 a CC-18 están aprobados.
- No existen duplicados activos por período y tipo de bien.
- El conteo a ciegas oculta la existencia durante la captura.
- Ninguna lectura puede registrarse fuera de `En Proceso`.
- Las diferencias requieren revisión de supervisor cuando corresponde.
- El cierre actualiza la programación futura.
- No quedan datos temporales creados por pruebas fallidas.
- No hay errores de consola o respuestas HTTP 500 durante el recorrido.

Los casos CC-19 y CC-20 son recomendados antes de liberar a producción.

## 9. Formato de reporte de incidencia

```text
Caso: CC-__
Ambiente:
Usuario / perfil:
Sucursal:
Período:
Conteo:
Pasos realizados:
Resultado obtenido:
Resultado esperado:
Fecha y hora:
Evidencia adjunta:
Se puede reproducir: Sí / No
Severidad: Bloqueante / Alta / Media / Baja
```

Severidades sugeridas:

- **Bloqueante:** no se puede iniciar, capturar, completar o cerrar el flujo.
- **Alta:** permite duplicados, muestra inventario durante el conteo a ciegas o permite cerrar sin autorización.
- **Media:** cálculo, mensaje, filtro o indicador incorrecto sin detener el flujo.
- **Baja:** texto, alineación o presentación visual.
