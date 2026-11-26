# Revisión de la base de EGestion360

Fecha: 25/11/2026. Destino revisado: servidor local `.`, base `GestionEmpresarial`. Alcance: lectura de metadatos y métricas agregadas. No se ejecutaron procedimientos de negocio, cambios de esquema, traslados, correcciones de datos ni respaldos.

El párrafo anterior describe el diagnóstico inicial. Tras la autorización expresa de aplicar directamente, se ejecutó el lote detallado al final de este informe; sus resultados sustituyen los conteos iniciales afectados.

## Resultado

La base ya tiene una separación funcional considerable. Conviene una refactorización incremental de responsabilidades y de consultas concretas, no renombrar todos los esquemas ni reproducir automáticamente el diseño de GE.UNI360. Las prioridades son representación monetaria, consistencia de lectura, revisión de transacciones y simplificación de dependencias.

Esta revisión no acredita la integridad semántica de todos los datos, el aislamiento de todas las empresas ni el rendimiento en producción. Los inventarios de patrones SQL son búsquedas textuales: comentarios y SQL dinámico pueden producir falsos positivos; requieren inspección antes de editar.

## Referencia cotejada de GE.UNI360

Se leyó `../GE.UNI360/docs/revision-sistema/NormalizacionEsquemasYUsoGenericos.md` desde este checkout hermano. El informe del 14/11/2026 registra 321 tablas clasificadas, 60 traslados, 60 sinónimos de compatibilidad, conservación de claves y filas, y regeneración real de EF Power Tools. También registra consumidores legados aún pendientes y diferencias entre el inventario inicial y el modelo efectivo.

Aplicación a EGestion360: inventariar todas las tablas, decidir el propietario funcional, estudiar dependencias y permisos, trasladar por lotes y regenerar EFPT conservando nombres CLR. Los alias temporales requieren un plan de retiro; no son una normalización terminada. No se ejecutó ni se copió el aplicador de GE.UNI360.

## Estado comprobado

| Elemento | Resultado local | Interpretación |
|---|---:|---|
| Tablas de usuario | 315 | Inventario completo de tablas físicas |
| Esquemas con tablas | 11 | Ya existe separación por módulos |
| Tablas sin PK | 0 | No hace falta una campaña de PK |
| Relaciones FK | 667 | Ninguna deshabilitada ni marcada como no confiable |
| Restricciones CHECK | 28 | El conteo no acredita todas las reglas de negocio |
| Índices | 1,280 | El número por sí solo no demuestra exceso |
| FK sin índice inicial compatible | 86 | Candidatos; no crear 86 índices automáticamente |
| Tablas con rowversion | 13 | Ya existen protecciones parciales de concurrencia |
| Columnas monetarias candidatas con float | 2 | Persona.SUELDO_BASE y COMPENSACION_GARANTIZADA |
| Columnas text obsoletas | 2 | ORCO.ProcedimientoContratacion.FundamentoJuridico y SolicitudCotizacion.Comentarios |
| Objetos con NOLOCK/READUNCOMMITTED textual | 35 | Incluye reportes contables y acceso |
| Objetos con BEGIN TRAN sin XACT_ABORT textual | 7 | Revisar propiedad y tratamiento de transacciones |
| Objetos con patrón SELECT * | 132 | Inspección textual; no equivale a 132 consultas ineficientes |
| Objetos con patrón CURSOR | 7 | Reescribir solo con evidencia y equivalencia |

SQL Server: versión 16.0.1220.3, compatibilidad 160. `READ_COMMITTED_SNAPSHOT` ya está encendido; `SNAPSHOT_ISOLATION` está apagado, son opciones distintas. Query Store está en READ_WRITE (2 MB de 1,000 MB configurados). AUTO_CLOSE y AUTO_SHRINK están apagados. No se modificó ninguna de estas opciones.

Distribución: SIS 56, PRES 53, NOM 48, PBR 44, ALMA 37, ORCO 31, TES 16, CONTA 15, dbo 7, LIC 6 e HIS 2 tablas.

## Mejoras propuestas, por prioridad

### 1. Importes exactos y lectura coherente

`NOM.Persona.SUELDO_BASE` y `COMPENSACION_GARANTIZADA` son float. Proponer decimal con precisión/escala derivadas del contrato y valores reales, revisar modelos EF, DTO y cálculos y comprobar ida/vuelta. Todavía no se midieron desbordamientos ni diferencias de redondeo; no corresponde elegir decimal(18,2) por costumbre. `SIS.TipoIncidencia.DiasPenalizacion` también es float: determinar si admite fracciones y su escala antes de modificarlo.

Revisar los 35 objetos con indicios de lecturas sucias, priorizando CONTA.SPR_RepIngEgre, SPR_RepRetenciones, SPR_RepResultIngresos, SPR_RepKardexGralporPeriod, SIS.LoginInformationEmployee y Vw_SucursalEmpresaEstado. Con RCSI activo, estudiar retirar NOLOCK y comprobar resultados durante escrituras concurrentes. RCSI ofrece coherencia por sentencia; no garantiza por sí solo coherencia entre varias sentencias de un reporte.

### 2. Transacciones y concurrencia operativa

Siete candidatos sin XACT_ABORT textual: ALMA.SP_CargaInicialConteo y SIS.spDocumentoGuardar, spDocumentoAnotacionCrear, spDocumentoAnotacionEliminar, spDocumentoEliminar, sp_NotificacionCrear y spEliminarUsuarioSucursal. Revisar el cuerpo completo, quién abre la transacción, XACT_STATE y si una operación llama a otra antes de cambiar el manejo de errores.

Rowversion ya existe en Poliza, Requisicion, OrdenCompra, EgresoAutorizado, EgresoProyectado, Factura, Cheque, Documento, DocumentoAnotacion y cuatro tablas LIC. El código genérico y servicios específicos ya transportan/comprueban versiones; verificar cada recorrido de escritura antes de extenderlas a otras tablas. Una columna sin comparación atómica al actualizar no evita pérdida de cambios.

### 3. Índices y estadísticas con evidencia

Hay 86 FK sin un índice no filtrado cuyas columnas iniciales coincidan en orden. Este criterio es conservador: para FK compuestas, un orden alternativo podría servir para ciertas consultas. Las tablas más pobladas entre los candidatos son ALMA.PlanConteoCiclico (661 filas), NOM.ConceptoTabular (625), NOM.PeriodoNomina (219) y NOM.PeriodoActivo (110). Varias tablas están vacías. Priorizar filtros reales, planes y crecimiento, incluyendo empresa/activo cuando proceda.

No se encontraron grupos de índices con idéntica firma de columnas clave, incluidas, unicidad, tipo y filtro según el inventario. Sí hay cinco grupos con las mismas claves iniciales que ameritan comparar cobertura, restricciones y uso:

- ALMA.TipoBaja: IX_TipoBaja_Clave_1243867498 / UQ_TipoBaja_Clave.
- CONTA.CuentaEspecial: IX_CuentaEspecial_Clave_1035866757 / UQ_CuentaEspecial_Clave.
- SIS.DocumentoTipoAnotacion: IX_DocumentoTipoAnotacion_Clave_2127346643 / UX_DocumentoTipoAnotacion_Clave.
- SIS.NotificacionTipo: IX_NotificacionTipo_Clave_943342425 / UQ__Notifica__E8181E1184A89DCD.
- SIS.PerfilUsuario: IX_PerfilUsuario_FKIdUsuario_SIS_702625546 / PK__PerfilUs__98F09D6BFA1343A2.

No retirar PK/UQ para ahorrar índices. No se midieron tamaño individual ni costo de escritura de esos grupos. Las métricas de uso corresponden al arranque de SQL Server del 25/11/2026; cero lecturas desde ese momento no justifica eliminar un índice.

El filtro de estadísticas seleccionó 54 objetos en ocho tablas: SystemLog, PlanConteoCiclico, AspNetClaims, Menu, MenuRole, PolizaDetalle, AspNetClaimValues y NotificacionDestino. Por ejemplo, varias estadísticas de SystemLog fueron calculadas con 35 filas y acumulan 3,362 modificaciones desde julio; la tabla tiene aproximadamente 913 filas actualmente. Evaluar actualización focalizada y efecto en planes; no se ejecutó UPDATE STATISTICS ni reconstrucción de índices.

### 4. Reorganización funcional como en GE.UNI360

[Mapa completo de 315 tablas](Mapa-Esquemas-BD-20261125.csv): 29 propuestas iniciales de traslado y 286 conservaciones provisionales. No es una aprobación de cada clasificación; las candidatas requieren cotejar SQL dinámico, código, reportes, permisos e integraciones.

| Grupo actual | Propuesta | Cantidad |
|---|---|---:|
| dbo.AspNet* | SIS | 6 |
| SIS.ActividadInstitucional, Capitulo, Partida | PRES | 3 |
| SIS.TipoPoliza, TipoDetallePoliza | CONTA | 2 |
| SIS.Proveedor, TipoProveedor, EstatusProveedor | ORCO | 3 |
| Bienes, resguardos, inventarios patrimoniales y catálogos asociados en ALMA | Nuevo PATRI | 12 |
| SIS.Escolaridad, Parentesco, TipoContratacion | NOM; valorar RH si se separa Capital Humano | 3 |

No unir SIS.Concepto y NOM.Concepto por coincidir el nombre. No mover ALMA.TipoBien automáticamente: se comparte con existencias y compras. Persona/PersonaArea y otros objetos laborales podrían justificar RH en una segunda fase; el inventario los conserva provisionalmente hasta definir la separación laboral/nómina. El catálogo dbo.SIS_EstadoCivil también requiere decidir alcance global/laboral antes de trasladarlo.

Los traslados mejoran propiedad y mantenimiento; no se espera que ALTER SCHEMA haga más rápida una consulta por sí solo. Conservar nombres ORCO, CONTA, TES y PRES evita una renombrada global sin beneficio demostrado.

### 5. Contratos SQL, empresa y despliegues

Sustituir text por nvarchar solo después de verificar Unicode, tamaños, reportes y modelos. Revisar SELECT * en consultas de aplicación y SP expuestos a EFPT antes que en scripts de diagnóstico. No ejecutar sp_refreshsqlmodule masivamente como prueba: puede cambiar metadatos o invalidar módulos firmados.

Hay 67 tablas con columna cuyo nombre contiene Empresa. Las demás pueden ser catálogos globales o detalles con alcance heredado; este conteo no demuestra una fuga. Revisar FK y recorridos completos en compras, presupuesto y patrimonio para impedir asociaciones entre empresas, considerando padres/detalles e importaciones.

El catálogo de dependencias devolvió 29 referencias sin object_id; todas corresponden a inserted/deleted de triggers. Excluidas esas pseudotablas quedan cero referencias no resueltas en ese inventario. Esto no comprueba SQL dinámico, nombres guardados en tablas, código, reportes ni otras bases.

`Scripts/06_Rendimiento_Concurrencia.sql` incluye activar RCSI con ROLLBACK IMMEDIATE, creación de índices/versiones y sustitución de SP en un mismo archivo. No ejecutarlo indiscriminadamente: RCSI ya está activado aquí. Dividir futuros cambios en incrementales por objetivo, verificando estructura y datos antes de aplicarlos. Mantener seguimiento de scripts aplicados y regeneración EFPT coordinados.

## Tiempos y bloqueos observados

Query Store conserva actividad desde al menos octubre. Gran parte de las consultas más costosas corresponden a introspección/diagnóstico, incluida esta revisión. Una clasificación textual las separó de candidatas de aplicación; estas últimas todavía requieren identificación precisa.

Como referencias puntuales: una sentencia de SIS.spNodeMenu registra cuatro ejecuciones con media ponderada de 27.21 ms y máximo 43.39 ms; SIS.spGetClaimsByUser registra cuatro con 13.95/19.70 ms. Son estadísticas por sentencia, no duración de todo el procedimiento ni del portal. No hay evidencia suficiente de carga operativa representativa para atribuir una pantalla lenta a un índice concreto.

En la muestra no había solicitudes de usuario activas en esta base, consultas superiores a cinco segundos ni bloqueos. El ring buffer de system_health retenía cero eventos de deadlock y estaba marcado como truncado. No se descartan deadlocks históricos; falta consultar archivos de eventos con retención suficiente o capturar una sesión representativa. No se indujeron bloqueos ni se corrió carga con escrituras.

## Entregables y siguiente ejecución

- [Diagnóstico de estructura](../../Tools/Quality/Review-Database.sql): ejecutado en local, solo lectura.
- [Diagnóstico de carga y dependencias](../../Tools/Quality/Review-Database-Workload.sql): ejecutado en local, solo lectura.
- [FK candidatas](Relaciones-SinIndiceInicial-20261125.csv): 86, pendientes de plan y beneficio.
- [Objetos SQL candidatos](ObjetosSQL-Revision-20261125.csv): filtros textuales de consistencia/transacciones.
- [Mapa de esquemas](Mapa-Esquemas-BD-20261125.csv): 315 tablas, propuesta sin aplicar.

Evidencia local de metadatos, sin filas de negocio ni texto de consultas: tmp/database-review/metadata-20261125.json, workload-20261125.json y classified-workload-20261125.json. No son respaldos de base de datos.

Orden sugerido de implementación: validar importes y reportes → revisar transacciones/actualizaciones concurrentes → medir operaciones representativas y ajustar índices/estadísticas → reorganizar identidad y catálogos → separar patrimonio con compatibilidad y EFPT. Para cada lote: destino autorizado, diferencias previas, dependencias, permisos, ensayo real autorizado, validación de datos/modelo/consumidores y procedimiento de reversión. Se respeta la instrucción vigente de no crear respaldos ni publicar en Git; no se realizó ninguna migración que los presuponga.

## Lote aplicado directamente a la base local

Autorización del usuario: «aplica directo en la bd». Destino confirmado: `./GestionEmpresarial`. Sin respaldos, publicaciones ni cambios de filas de negocio durante la aplicación.

| Incremental | Aplicación y alcance |
|---|---|
| `20261125_Consistencia_Procedimientos.sql` | 42 módulos: retirada de hints NOLOCK/READUNCOMMITTED individuales en 35 objetos; READ COMMITTED en los que fijaban aislamiento sucio; XACT_ABORT en siete procedimientos; cierre de la transacción propia en la rama sin asignación de spEliminarUsuarioSucursal |
| `20261125_Consistencia_Aislamiento.sql` | 19 módulos adicionales con SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED: sustitución por READ COMMITTED, que usa RCSI ya activado |
| `20261125_Consolidar_Indices.sql` | Cuatro índices no únicos retirados, conservando índices únicos con idénticas columnas clave/incluidas, orden y cobertura; PerfilUsuario conservado por diferencia de tipo de índice |
| `20261125_Estadisticas_Focalizadas.sql` | FULLSCAN en las ocho tablas pequeñas identificadas; protección de volumen de 50,000 filas por tabla |

Preparación reproducible: `Tools/Quality/Prepare-DatabaseImprovements.ps1`. Solo prepara el incremental; no lo aplica. Tokeniza cadenas, identificadores y comentarios antes de cambiar hints. Las definiciones finales SQL se guardan como código de despliegue, no como respaldos. No sustituye SQL dentro de literales. Los incrementales de módulos están vinculados a identificadores y huellas SHA-256 de las definiciones locales revisadas: no ejecutarlos en otro servidor o versión sin preparar/verificar otro incremental. No son instaladores universales ni deben repetirse tras cambiar las definiciones.

Los tres incrementales DDL se ensayaron dentro de una transacción externa con rollback y después se confirmaron. Se verificó la rama de asignación inexistente con IDs negativos comprobados ausentes: devuelve el rechazo sin insertar/eliminar filas y conserva el contador de transacciones de entrada. No se ejecutaron procesos de compras, nómina, autorizaciones ni reportes para probar escrituras reales.

Resultado posterior: 315 tablas, 1,276 índices (antes 1,280), cero módulos con referencias textuales NOLOCK/READUNCOMMITTED/READ UNCOMMITTED, siete procedimientos con XACT_ABORT, cero FK deshabilitadas/no confiables, cero solicitudes de usuario largas/bloqueadas en la muestra y cero transacciones abiertas en la conexión de aplicación. No se atribuye una mejora porcentual de rendimiento a estos cambios: falta comparar carga operativa representativa.

Reversión: los cambios DDL fueron reversibles durante el ensayo antes de confirmar. Tras confirmar, no existe un respaldo creado por esta tarea ni un revertidor automático. La cobertura retirada puede recuperarse recreando cada índice no único sobre Clave, pero restaura redundancia; cualquier cambio posterior de módulos debe coordinarse con su versión de código. No se promete reversión automática de todo el lote.

Pendiente: conversión de float y tipos text, definición de escala monetaria con comprobación de valores, traslados del mapa, regeneración EFPT y consumidores de cada recorrido. Los cuatro índices retirados todavía aparecen como metadatos de scaffold en EGestionContext; no hay migraciones automáticas ejecutadas y ese mapeo no recrea índices durante consultas/CRUD. Se deben reconciliar mediante EFPT antes de generar una futura migración. Las 86 FK candidatas no recibieron índices indiscriminadamente.
