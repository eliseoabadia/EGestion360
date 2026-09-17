import json
from pathlib import Path

WEEKS = [
('21 al 25 de septiembre','Inicio y definición del alcance','G0 Acta y alcance inicial',[
('21 sep','Kickoff institucional','PM','Inicio','Alinear objetivos, entes participantes, gobierno y criterios de éxito; aprobar minuta y calendario de decisiones.'),
('21–22 sep','Inventario de procesos y responsables','FP FC','Kickoff','Levantar gasto e ingreso, pólizas, reportes y cierre; cada proceso tendrá dueño y usuario aprobador.'),
('22–23 sep','Inventario de fuentes y extracciones','DAT','Kickoff','Registrar sistemas, tablas, archivos, responsables, cortes y volumen estimado; obtener acceso de lectura autorizado.'),
('22–24 sep','Inventario técnico y ambientes','DEV OPS','Kickoff','Revisar índice del código, dependencias SQL, despliegue local y permisos; separar desarrollo, pruebas y producción.'),
('23–24 sep','Definir ente piloto y alcance de la ola','PM FP FC','Inventario','Seleccionar un ente y unidades representativas; acordar exclusiones y reglas para incorporar dependencias adicionales.'),
('25 sep','Aprobar acta y matriz de alcance','COM','Trabajos S01','G0 firmado con roles, disponibilidad, fuentes, riesgos y entregables; cualquier ampliación seguirá control de cambios.')]),
('28 de septiembre al 2 de octubre','Diagnóstico y primera extracción','R0 Ambiente de pruebas',[
('28–29 sep','Taller de estructura presupuestaria','FP','G0','Mapear ejercicio, unidad, programa, fuente y clasificadores; catálogo de equivalencias con responsables.'),
('28–29 sep','Taller contable y reglas de registro','FC','G0','Revisar cuentas, niveles, naturaleza, eventos y períodos contra manual aplicable; matriz de decisión funcional.'),
('29–30 sep','Extracción de perfilado ETL cero','DAT','Inventario fuentes','Obtener copia controlada con fecha de corte y huella; perfilar duplicados, nulos, importes y claves inválidas.'),
('29 sep–1 oct','Diagnóstico de brechas de cierre y reportes','DEV FC','Índice técnico','Reproducir período 13, ámbito por ente y plantillas pendientes; documentar evidencia y plan de solución.'),
('30 sep–1 oct','Habilitar ambiente y seguridad inicial','OPS QA','Inventario técnico','Restaurar copia protegida; comprobar HTTPS, API local, arranque automático, perfiles y bitácora.'),
('2 oct','Liberar ambiente de trabajo R0','PM OPS','Tareas S02','Prueba de acceso y recuperación aprobada; usuarios clave pueden ejecutar talleres sin tocar producción.')]),
('5 al 9 de octubre','Diseño funcional y de datos','G1 Diseño y contratos de datos',[
('5–6 oct','Diseñar flujo de egresos','FP','G0 R0','Documentar anteproyecto, autorizado, adecuaciones, suficiencia y compromiso; definir estados, reversas y autorizadores.'),
('5–6 oct','Diseñar pólizas e integración','FC DEV','Taller contable','Relacionar evento presupuestario con asiento y documento origen; controles de cuadre, reversa y no duplicación.'),
('6–7 oct','Firmar mapeo ETL y reglas de limpieza','DAT FP FC','Perfilado ETL cero','Diccionario fuente destino por campo, tipo, longitud, obligatoriedad, transformación y tratamiento de rechazos.'),
('6–8 oct','Acordar alcance de reportes y cierres','FC','Brechas S02','Clasificar reportes obligatorios y opcionales; decidir DIOT e indicadores APP; aprobar diseño de cierre por ente.'),
('7–8 oct','Diseñar UAT y segregación de funciones','QA UK','Diseño funcional','Casos con resultado esperado por rol; incluir cruces de ente, ejercicio, permisos y trazabilidad.'),
('9 oct','Aprobar diseño y estrategia de migración','COM','Tareas S03','G1 firmado; fijar fecha base, delta, responsables de conciliación y backlog priorizado con estimación.')]),
('12 al 16 de octubre','Configuración base y ETL uno','R1 Catálogos y configuración',[
('12–13 oct','Configurar estructura institucional','FP OPS','G1','Cargar entes piloto, áreas, ejercicios, usuarios y permisos; matriz de accesos verificada por usuario clave.'),
('12–14 oct','Configurar clasificadores y calendario','FP DAT','G1','Cargar catálogos, relaciones y doce meses; suma mensual debe coincidir con total anual por clave.'),
('12–14 oct','Configurar plan de cuentas y eventos','FC DEV','G1','Validar jerarquías, cuentas activas, naturaleza, eventos y cuentas permitidas; resolver claves sin correspondencia.'),
('13–15 oct','Construir ETL uno de maestros','DAT','Mapeo aprobado','Ejecutar extracción, depuración, carga de staging y rechazo por fila; repetir lote sin crear duplicados.'),
('14–15 oct','Corregir controles prioritarios','DEV QA','Backlog G1','Atender mensualización incompleta, aislamiento por ente y diseño del cierre; pruebas automatizadas de riesgo.'),
('16 oct','Demostrar y liberar R1 en pruebas','PM FP FC','Tareas S04','Catálogos y perfiles aceptados; evidencias de ETL uno y diferencias resueltas antes de movimientos.')]),
('19 al 23 de octubre','Presupuesto y saldos iniciales','Preparación de R2',[
('19–20 oct','Cargar presupuesto base y autorizado','FP DAT','R1','Validar claves y meses; probar secuencia anteproyecto a autorizado sin duplicar registro ni efecto contable.'),
('19–21 oct','Validar adecuaciones y disponibilidad','FP QA','R1','Ejecutar ampliación, reducción, transferencia y calendario; demostrar autorización y disponibilidad por clave.'),
('19–21 oct','Preparar saldos y auxiliares','FC DAT','R1','Conciliar corte con balanza fuente por cuenta, ente y período; documentar partidas de enlace y diferencias.'),
('20–22 oct','Construir carga de movimientos históricos','DAT DEV','G1 R1','Definir documentos, detalles y vínculos; incluir control de folios, estados, fechas y reversas.'),
('21–22 oct','Probar pólizas manuales e importación','FC QA','R1','Cuadre cargos abonos, edición autorizada, rechazo de cuenta inválida y trazabilidad del documento.'),
('23 oct','Cerrar conciliación de maestros','FP FC DAT','Tareas S05','Acta de maestros y base presupuestaria; cero diferencias monetarias no explicadas para avanzar a ETL dos.')]),
('26 al 30 de octubre','ETL dos e integración funcional','G2 y R2 Migración conciliada',[
('26–27 oct','Ejecutar ETL dos completo en pruebas','DAT','Conciliación S05','Cargar maestros, saldos, presupuesto y movimientos del corte; registrar lote, conteos e importes.'),
('26–28 oct','Validar suficiencias y compromisos','FP QA','R1 base cargada','Probar importe excedido, cancelación y reenvío; disponible y reservado deben reconciliar sin doble afectación.'),
('27–28 oct','Validar devengado ejercido y pagado','FP FC QA','ETL dos','Recorrer documentos de cuentas por pagar y tesorería dentro del alcance; verificar momento y asiento.'),
('27–29 oct','Validar ingresos y recaudación','FP FC QA','ETL dos','Probar estimado, modificación y etapas de ingreso aplicables; comprobar integración contable y reversas.'),
('28–29 oct','Conciliar presupuesto y contabilidad','FC DAT','ETL dos','Cruzar totales por clave, cuenta y momento; separar ajustes legítimos de errores y obtener firmas.'),
('30 oct','Aprobar G2 y liberar R2','COM','Tareas S06','Carga reproducible, sin rechazos críticos ni diferencias inexplicadas; conjunto integrado listo para pruebas.')]),
('2 al 6 de noviembre','Pruebas integrales y cierre','SIT ciclo uno',[
('2–3 nov','Ejecutar casos de egreso de extremo a extremo','QA FP','G2 R2','Desde presupuesto a documento y póliza; cubrir rechazo, devolución, cancelación y reintento.'),
('2–4 nov','Probar cierre mensual y separación por ente','QA FC DEV','Correcciones prioritarias','Cerrar y repetir en copia; verificar que un ente no altere otro y que los saldos anteriores se conserven.'),
('3–4 nov','Probar período trece y cambio de ejercicio','FC DEV QA','Diseño G1','Verificar ajustes y traspaso a 2027 con respaldo; impedir fechas inválidas y cierres duplicados.'),
('3–5 nov','Validar reportes prioritarios','FC QA','G2','Conciliar balanza, auxiliares, estados y ejecución presupuestaria con casos trazables; revisar formato y filtros.'),
('4–5 nov','Probar concurrencia y seguridad','QA OPS','R2','Medir cargas acordadas; ensayar sesión, rol, ente, folio concurrente, bitácora y error recuperable.'),
('6 nov','Triage de defectos y plan de cierre','PM DEV QA','SIT uno','Clasificar severidad, asignar dueño y fecha; bloquear liberación con errores de saldo, permiso o duplicación.')]),
('9 al 13 de noviembre','Regresión y ensayo ETL tres','G3 y R3 Integración aprobada',[
('9–10 nov','Corregir y reprobar defectos críticos','DEV QA','SIT uno','Adjuntar reproducción, corrección y evidencia independiente; completar pruebas de no regresión.'),
('9–11 nov','Ejecutar ensayo ETL tres con delta','DAT','G2 y defectos resueltos','Simular corte más novedades, cancelaciones y actualizaciones; demostrar idempotencia y conciliación final.'),
('10–11 nov','Medir ventana de corte y restauración','OPS DAT','ETL tres','Registrar tiempos de respaldo, carga, validación y reversión; confirmar que caben en ventana de producción.'),
('10–12 nov','Completar paquete de pruebas de integración','QA FP FC','Correcciones y ETL tres','Todos los casos críticos pasan; evidencia de controles de saldo, ente y período completa.'),
('11–12 nov','Preparar capacitación y manuales por rol','CAP UK','Flujos estabilizados','Guías de captura, revisión, autorización, cierre y atención; material probado por usuarios representativos.'),
('13 nov','Aprobar G3 y liberar R3','COM','Tareas S08','Entrada a UAT autorizada; cero defectos críticos o altos que afecten operación, datos o seguridad.')]),
('16 al 20 de noviembre','Aceptación de usuarios','UAT funcional',[
('17 nov','Capacitar responsables y habilitar UAT','CAP QA','G3 R3','Sesión práctica con datos del piloto; asistencia y evaluación individual registradas.'),
('17–18 nov','Ejecutar UAT Presupuesto','UK FP','Capacitación','Usuarios validan autorizado, modificaciones, suficiencia y compromiso; evidencias con firma funcional.'),
('17–19 nov','Ejecutar UAT Contabilidad','UK FC','Capacitación','Usuarios validan pólizas, balanza, auxiliares y cierre en copia; concilian contra resultados esperados.'),
('18–19 nov','Validar reportes institucionales y permisos','UK QA','G3','Revisar formatos acordados, segregación de tareas y consultas entre entes; registrar desviaciones.'),
('18–20 nov','Corregir observaciones y repetir casos','DEV QA','Resultados UAT','Atender defectos sin ampliar alcance; ejecutar regresión y documentar aceptación del usuario.'),
('20 nov','Emitir preaceptación funcional','FP FC PM','Tareas S09','Lista cerrada de pendientes, severidad y responsables; ningún pendiente crítico pasa a preparación de corte.')]),
('23 al 27 de noviembre','Preparación y autorización productiva','G4 y R4 Candidato de producción',[
('23–24 nov','Realizar UAT final y firma por módulo','UK FP FC','Preaceptación','100 por ciento de casos críticos aprobados; observaciones menores con tratamiento y vencimiento.'),
('23–24 nov','Ensayar despliegue y restauración final','OPS QA','G3 y ETL tres','Repetir instalador en ambiente equivalente; probar backend automático, proxy, respaldos y retorno.'),
('24–25 nov','Preparar corte de fuentes y delta final','DAT FP FC','UAT final','Fijar hora y zona del corte, responsables fuente, folios y cifras de control; comunicar suspensión autorizada.'),
('24–26 nov','Verificar soporte y usuarios productivos','CAP OPS','Manuales y R3','Confirmar cuentas nominales, perfiles, mesa de ayuda, guardias y canal de incidentes.'),
('26 nov','Preparar versión R4 y expediente de salida','DEV QA','Ensayo final','Versionar Front, Back, instalador y SQL; comprobar huellas, configuración, evidencia y cambios incluidos.'),
('27 nov','Comité Go No Go G4','COM','Tareas S10','Autorizar o rechazar corte; sin firma, diferencias de saldo o restauración probada se mantiene el sistema vigente.')]),
('30 de noviembre al 4 de diciembre','Salida a producción y operación asistida','R5 Producción del alcance aprobado',[
('30 nov','Ejecutar ventana de corte autorizada','OPS DAT','G4','Respaldar, cerrar fuente, cargar delta y publicar; aplicar secuencia y puntos de reversión del runbook.'),
('30 nov','Conciliar y habilitar usuarios','FP FC QA','Corte técnico','Firmar cifras finales, probar operación y reportes; abrir captura solo tras autorización funcional.'),
('1–2 dic','Acompañar primeras operaciones','UK FP FC','R5','Supervisar lotes y pólizas iniciales; contrastar contra fuente y registrar incidencias con prioridad.'),
('1–3 dic','Monitorear estabilidad y automatismos','OPS QA','R5','Comprobar reinicio, logs, acceso HTTPS, respaldos, consumo y tiempos; API por mismo origen sin 8440.'),
('2–3 dic','Ejecutar primera revisión de saldos','FC DAT','Operación inicial','Conciliar movimientos, balanza y ejecución; resolver diferencias antes de nuevos cierres.'),
('4 dic','Comité de estabilización','PM FP FC','Tareas S11','Aprobar continuidad de operación asistida y plan de incidencias; sin ampliación automática a otros entes.')]),
('7 al 11 de diciembre','Estabilización y entrega operativa','G5 y R6 Correcciones controladas',[
('7–8 dic','Cerrar incidencias de salida','DEV QA','Comité S11','Probar correcciones con caso reproducible; no cambiar reglas contables sin aprobación funcional.'),
('7–9 dic','Validar primer ciclo operativo completo','UK FP FC','R5','Revisar presupuesto, integración, auxiliares y cierre del período permitido; evidencia de usuario.'),
('8–9 dic','Revisar reportes y conciliación acumulada','FC DAT','Operación estable','Comparar saldos por ente y mes; obtener aceptación de responsables de información.'),
('9–10 dic','Transferir administración y soporte','OPS CAP','Manuales finales','Entregar accesos bajo custodia, monitoreo, arranque, parada, respaldo y recuperación; ejercicio supervisado.'),
('10 dic','Liberar R6 si hay cambios autorizados','DEV OPS','Defectos probados','Aplicar solo correcciones aceptadas, con regresión y respaldo; si no hay cambios, conservar R5.'),
('11 dic','Aprobar estabilidad G5','COM','Tareas S12','Aceptar operación del alcance implantado, pendientes menores y responsables; autorizar congelamiento funcional.')]),
('14 al 18 de diciembre','Preparación del cierre anual','Congelamiento y ensayo de cierre',[
('14 dic','Iniciar congelamiento de funcionalidad','PM OPS','G5','Permitir únicamente correcciones urgentes aprobadas; mantener evidencia de versiones y autorizaciones.'),
('14–15 dic','Ejecutar ensayo de cierre anual en copia','FC QA','Cierre corregido y G5','Ensayar ajustes, período trece y saldos 2027; demostrar que la repetición no duplica ni altera otros entes.'),
('15–16 dic','Conciliar pendientes presupuestarios','FP FC','Operación acumulada','Identificar compromisos, devengados, pagos y adecuaciones pendientes con documento, dueño y tratamiento.'),
('15–17 dic','Validar formatos de información anual','FC UK','Catálogo reportes firmado','Comparar estados y conciliaciones aprobadas; programar aclaraciones que dependan del cierre efectivo.'),
('16–17 dic','Ensayar recuperación y continuidad de guardia','OPS QA','G5','Restaurar respaldo en ambiente separado; registrar tiempo y pérdida recuperable contra objetivos aprobados.'),
('18 dic','Autorizar procedimiento de fin de año','COM','Tareas S13','Firmar checklist, responsables y guardias; fijar recepción de ajustes y actividades posteriores a diciembre.')]),
('21 al 25 de diciembre','Operación vigilada y preparación final','Guardias sin liberaciones mayores',[
('21 dic','Revisar pendientes críticos y saldos','FP FC','Procedimiento aprobado','Confirmar tratamiento de excepciones y folios abiertos; escalar diferencias con impacto al cierre.'),
('21–22 dic','Preparar paquete de evidencias','PM QA','G5','Consolidar actas, UAT, ETL, conciliaciones, versiones, incidencias y manuales; índice por entregable.'),
('22 dic','Validar usuarios de guardia y escalamiento','OPS CAP','Plan continuidad','Probar contacto, permisos y acceso seguro de guardias; confirmar respaldo titular y suplente.'),
('22–23 dic','Verificar respaldos y espacio disponible','OPS','R5 R6','Validar ejecución, retención y copia recuperable; sin tareas pendientes que requieran consola manual.'),
('23 dic','Conciliar avance antes de guardia','DAT FP FC','Pendientes S14','Emitir corte de control y lista de diferencias explicadas; no aplicar cargas masivas fuera de autorización.'),
('24–25 dic','Mantener guardia de continuidad','OPS','Responsables confirmados','Atender solo incidentes; 25 sin talleres ni cambios planeados. Registrar cualquier intervención y su aprobación.')]),
('28 al 31 de diciembre','Corte de seguimiento y cierre de implantación','G6 Entrega del proyecto',[
('28 dic','Revisar conciliación y pendientes finales','FP FC DAT','Corte S14','Contrastar presupuesto y contabilidad al corte acordado; clasificar ajustes que continúan en enero.'),
('28–29 dic','Validar administración autónoma','OPS UK','Transferencia S12','Operadores ejecutan checklist de operación y recuperación sin asistencia del equipo de desarrollo.'),
('29 dic','Entregar expediente y backlog residual','PM QA','Evidencias S14','Entregar originales controlados, incidentes menores y fechas; asegurar custodio y acceso institucional.'),
('30 dic','Sesión de aceptación de implantación','COM FP FC','Tareas de entrega','Aprobar alcance operando y restricciones; no sustituye el cierre contable definitivo ni la cuenta pública.'),
('30–31 dic','Ejecutar corte y resguardo autorizado','FC OPS','Procedimiento fin de año','Guardar evidencias y respaldos del corte; no cerrar automáticamente períodos ni adelantar cifras definitivas.'),
('31 dic','Emitir G6 y continuidad de enero','PM COM','Aceptación y corte','Acta de entrega con pendientes, responsables y soporte; tratamiento de ajustes y cierre anual continúa según calendario oficial.')])]
Path('artifacts/implementacion_2026/actividades.json').write_text(json.dumps(WEEKS,ensure_ascii=False,indent=2),encoding='utf-8')
print('Semanas',len(WEEKS),'actividades',sum(len(x[3]) for x in WEEKS))