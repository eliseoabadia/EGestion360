from pathlib import Path
import json
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_CELL_VERTICAL_ALIGNMENT
from docx.enum.section import WD_ORIENT

OUT=Path('artifacts/implementacion_2026')
w=json.loads((OUT/'actividades.json').read_text(encoding='utf-8'))
doc=Document(); s=doc.sections[0]; s.orientation=WD_ORIENT.LANDSCAPE
s.page_width=Inches(11.69); s.page_height=Inches(8.27)
s.top_margin=Inches(.62); s.bottom_margin=Inches(.58); s.left_margin=Inches(.67); s.right_margin=Inches(.67)
s.header_distance=Inches(.25); s.footer_distance=Inches(.25)
for name in ['Normal','Title','Subtitle','Heading 1','Heading 2','Heading 3']:
 st=doc.styles[name]; st.font.name='Calibri'; st.font.color.rgb=RGBColor(0,0,0)
 st.paragraph_format.space_after=Pt(6); st.paragraph_format.line_spacing=1.06
 st.font.size=Pt({'Title':27,'Subtitle':14,'Heading 1':20,'Heading 2':13,'Heading 3':11}.get(name,11))
doc.styles['Title'].font.bold=True
for name in ['Heading 1','Heading 2','Heading 3']:doc.styles[name].font.bold=True
header=s.header.paragraphs[0];header.text='GOBIERNO DE TABASCO  |  EGESTION360  |  IMPLEMENTACIÓN 2026';header.runs[0].font.size=Pt(9)
f=s.footer.paragraphs[0]; f.alignment=WD_ALIGN_PARAGRAPH.RIGHT
f.add_run('Plan propuesto v1.0  •  20 sep a 31 dic 2026  |  ').font.size=Pt(9)
fld=OxmlElement('w:fldSimple');fld.set(qn('w:instr'),'PAGE');f._p.append(fld)
doc.core_properties.title='Calendario de implementación de Presupuesto y Contabilidad para el Gobierno de Tabasco'
doc.core_properties.subject='Plan detallado del 20 de septiembre al 31 de diciembre de 2026'
doc.core_properties.author='Equipo de implementación EGestion360'
page_count=0

def page(title,lead=None):
 global page_count
 if page_count: doc.add_page_break()
 page_count+=1
 doc.add_heading(title,0 if page_count==1 else 1)
 if lead: p(lead)

def p(text,style=None):return doc.add_paragraph(text,style)
def h(t):doc.add_heading(t,2)
def table(headers,rows,widths=None,size=10.5):
 t=doc.add_table(rows=1, cols=len(headers));t.alignment=WD_TABLE_ALIGNMENT.CENTER;t.autofit=False
 if widths:
  for c,v in zip(t.columns,widths):c.width=Inches(v)
 for i,text in enumerate(headers):t.rows[0].cells[i].text=str(text)
 for row in rows:
  cells=t.add_row().cells
  for i,text in enumerate(row):cells[i].text=str(text)
 for ri,row in enumerate(t.rows):
  if widths:
   for c,v in zip(row.cells,widths):c.width=Inches(v)
  trPr=row._tr.get_or_add_trPr();ns=OxmlElement('w:cantSplit');trPr.append(ns)
  if ri==0:
   repeat=OxmlElement('w:tblHeader');trPr.append(repeat)
  for cell in row.cells:
   cell.vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER
   pr=cell._tc.get_or_add_tcPr();shade=OxmlElement('w:shd');shade.set(qn('w:fill'),'243A50' if ri==0 else ('F2F5F8' if ri%2==0 else 'FFFFFF'));pr.append(shade)
   margins=OxmlElement('w:tcMar')
   for side in ['top','bottom','left','right']:
    e=OxmlElement('w:'+side);e.set(qn('w:w'),'80');e.set(qn('w:type'),'dxa');margins.append(e)
   pr.append(margins)
   for pp in cell.paragraphs:
    pp.paragraph_format.space_after=Pt(2);pp.paragraph_format.space_before=Pt(2);pp.paragraph_format.line_spacing=1.02
    for r in pp.runs:r.font.name='Calibri';r.font.size=Pt(size);r.font.bold=ri==0;r.font.color.rgb=RGBColor.from_string('FFFFFF' if ri==0 else '000000')
 borders=OxmlElement('w:tblBorders')
 for edge in ['top','left','bottom','right','insideH','insideV']:
  e=OxmlElement('w:'+edge);e.set(qn('w:val'),'single');e.set(qn('w:sz'),'4');e.set(qn('w:color'),'D9D9D9');borders.append(e)
 t._tbl.tblPr.append(borders)
 return t

page('Calendario de implementación de Presupuesto y Contabilidad')
p('Gobierno de Tabasco','Subtitle');p('EGestion360  |  Del 20 de septiembre al 31 de diciembre de 2026','Subtitle')
h('Objetivo y propuesta de ejecución')
p('Implantar el alcance aprobado de Presupuesto y Contabilidad mediante configuración institucional, migración conciliada de datos, pruebas de integración, aceptación de usuarios y operación asistida. Se propone la salida a producción del ente piloto y las unidades expresamente aprobadas el 30 de noviembre, condicionada a la autorización del comité y a la conciliación del corte.')
p('El plan contiene 90 actividades distribuidas en 15 semanas operativas, seis liberaciones base y una liberación condicionada de correcciones. El 20 de septiembre es el inicio formal; el kickoff operativo se realizará el lunes 21. Diciembre se reserva para estabilización, transferencia y preparación del cierre del ejercicio.')
table(['Decisión','Fecha objetivo','Resultado esperado'],[
('Inicio institucional','20 y 21 septiembre','Inicio formal y kickoff con responsables, alcance y reglas de aprobación.'),
('Diseño y datos','9 octubre','Procesos, catálogos, reglas de migración y estrategia de conciliación firmados.'),
('Autorización productiva','27 y 30 noviembre','Go No Go y apertura de usuarios después del corte conciliado.'),
('Entrega de implantación','31 diciembre','Operación transferida y pendientes de enero bajo responsabilidad institucional.')],[2,1.65,6.65],11)
p('Versión 1.0 • Emisión 8 de septiembre de 2026 • Destinatarios: patrocinio institucional, áreas de Presupuesto y Contabilidad, TI y equipo de implementación. Fechas propuestas para aprobación en kickoff; no constituyen aceptación ya otorgada ni garantía de despliegue estatal completo.')
page('Alcance y condiciones de la línea base','La cobertura por entes, unidades, fuentes de datos e históricos se fijará en G0 para evitar que una ampliación silenciosa comprometa las fechas de salida.')
table(['Incluido en la implantación','Límite y condición'],[
('Presupuesto de egresos','Estructura y catálogos; anteproyecto, autorizado, adecuaciones, disponibilidad, suficiencia y compromisos; validación de momentos posteriores.'),
('Presupuesto de ingresos','Estimado o autorizado, modificaciones y conexión a registros de ingreso; confirmar fuentes y operaciones aplicables en G0.'),
('Contabilidad','Plan de cuentas, matrices, pólizas, saldos, auxiliares, balanza, reportes priorizados y controles de cierre.'),
('Datos y adopción','ETL institucional, conciliación, capacitación, UAT, despliegue, recuperación y transferencia operativa.'),
('Integraciones necesarias','Adquisiciones, Tesorería, Almacén, Patrimonio y Nómina solo por eventos que afecten estos módulos; no se da por implantado su alcance completo.'),
('Fuera del compromiso base','Expansión a todos los entes, nuevas fuentes, desarrollos mayores no estimados y certificaciones normativas se someten a cambio de alcance.')],[2.3,8],11)
h('Condiciones de capacidad y calendario')
p('Se requiere acceso a fuentes durante la primera semana, usuarios clave disponibles, dos especialistas de datos para cargas y conciliación simultáneas, y ambientes separados. La volumetría y el esfuerzo se ajustarán al concluir el perfilado; la duración de una actividad no equivale a horas de desarrollo.')
p('La jornada propuesta es de lunes a viernes en horario de Tabasco. Se reserva el 16 de noviembre sin talleres y el 25 de diciembre sin cambios planeados; 24 y 31 de diciembre tendrán guardia. Las suspensiones institucionales y ventanas de operación se confirmarán en G0. Si una condición crítica se incumple, el comité reprograma la salida y conserva el sistema vigente.')
page('Alcance funcional sustentado en el código','La reindexación al 8 de septiembre identificó 2,291 archivos, 11,280 símbolos y rutas, 467 páginas Razor y 14 proyectos. La existencia de código no representa aprobación de usuarios ni funcionamiento certificado.')
table(['Área observada','Trabajo requerido para implantar','Evidencia'],[
('Anteproyecto y mensualización','Validar doce meses y carga previa a autorizado. El importador asigna a enero un total sin meses: corregir o bloquear para la migración.','E01'),
('Autorizado y adecuaciones','Validar origen, autorizaciones, reversas, disponible y efectos contables; probar con movimientos posteriores.','E02 E03'),
('Suficiencia y compromiso','Depurar usuario y persona autorizadora; comprobar reservas, concurrencia y cancelaciones.','E04'),
('Ingresos e integración de pagos','Definir interfaces por documento y momento; conciliar con Tesorería y Contabilidad.','E05'),
('Cuentas y matrices','Aprobar equivalencias institucionales y cada combinación que genere asiento.','E06'),
('Pólizas e importación','Validar cuadre, estados, períodos, evidencia documental, permisos y reejecución del lote.','E07'),
('Cierre y cambio de ejercicio','Resolver alcance por ente y mes 13; ensayar interrupción, restauración, reejecución y transición 2027.','E08'),
('Reportes institucionales','DIOT e indicadores APP figuran sin plantilla; decidir aplicabilidad. Verificar plantilla de cambios en situación financiera.','E09'),
('Despliegue y operación','Probar mismo origen HTTPS, proxy a localhost 5555, arranque automático y recuperación después de reinicio.','E10')],[2,7.4,.9],10.5)
p('El inventario de evidencias al final del documento permite localizar los componentes. Las correcciones de cierre, segregación y datos son condiciones de salida; no se trasladan a producción como pendientes menores.')
page('Gobierno del proyecto y responsabilidades','Los nombres y suplentes se asignarán en el kickoff. Cada entregable tendrá ejecutor y aprobador institucional; las firmas técnicas no sustituyen la aceptación de los responsables de información.')
table(['Rol','Responsabilidad','Decisión o evidencia'],[
('COM Comité y patrocinio','Institución y dirección del proyecto; sesión semanal y decisiones de liberación.','Aprueba alcance, recursos, cambios y Go No Go.'),
('PM Dirección del proyecto','Plan, dependencias, riesgos, minutas y control de entregables.','Integra expediente y eleva desviaciones.'),
('FP Responsable de Presupuesto','Diseño, catálogos, cifras y flujos presupuestarios.','Acepta Presupuesto y conciliación de sus fuentes.'),
('FC Responsable de Contabilidad','Cuentas, matrices, saldos, estados y reglas de cierre.','Acepta cifras, reportes y procedimiento de cierre.'),
('DAT Equipo de datos','Dos especialistas para extracción, transformación, cargas y manifiestos.','Entrega conciliación y evidencia reproducible.'),
('DEV Equipo técnico','Ajustes de aplicación y SQL, versionado y correcciones con pruebas.','Entrega versión y plan de reversión.'),
('QA Calidad','Casos, pruebas integradas, regresión, rendimiento y evidencia independiente.','Recomienda aprobación técnica o bloqueo.'),
('OPS TI y operación','Ambientes, seguridad, copias, despliegue, monitoreo y recuperación.','Ejecuta dentro de la ventana autorizada.'),
('UK Usuarios clave','Ejecutan casos del trabajo real y revisan resultados por rol.','Firman UAT con FP y FC.'),
('CAP Capacitación','Manuales, sesiones, evaluación y transferencia a mesa de ayuda.','Demuestra autonomía de operadores.')],[1.85,5.85,2.6],10.5)
p('Cadencia: reunión diaria de 15 minutos en pruebas y corte; seguimiento de dependencias martes y jueves; comité viernes. Una decisión vencida más de dos días hábiles o una desviación de la ruta crítica se eleva al COM con opciones de corrección, alcance o fecha.')
page('Kickoff institucional del 21 de septiembre','Reunión propuesta de 09:00 a 13:00 horas de Tabasco. Participan COM, PM, FP, FC, TI, DAT, QA y las unidades piloto. El 20 de septiembre queda registrado como inicio formal del proyecto.')
table(['Horario','Actividad','Salida requerida'],[
('09:00 a 09:20','Objetivo y expectativas','Definición compartida del alcance y resultado de diciembre.'),
('09:20 a 10:00','Procesos y entidades de la primera ola','Ente piloto, unidades, ejercicios y fuentes; interfaces y exclusiones.'),
('10:00 a 10:35','Gobierno y responsables','Titulares, suplentes, aprobadores, contacto y tiempos de decisión.'),
('10:35 a 11:10','Datos y ETL','Extracciones, volumetría inicial, protección y responsables de conciliación.'),
('11:10 a 11:45','Calendario y liberaciones','Fechas objetivo, ventanas, criterios de aceptación y ruta crítica.'),
('11:45 a 12:20','Riesgos y decisiones técnicas','Ambientes, brechas, seguridad, recuperación y cierre de año.'),
('12:20 a 13:00','Acuerdos y próximos pasos','Minuta y pendientes con dueño y fecha; G0 previsto el 25 de septiembre.')],[1.25,3.25,5.8],11)
h('Preparación y compromisos posteriores')
p('PM distribuirá agenda y formatos el 21 antes de la sesión. Cada área aportará procesos, reportes indispensables, fuentes y usuarios propuestos. Durante las siguientes 48 horas se abrirá el registro de decisiones, se asignarán dueños de datos y se solicitarán extracciones de lectura. La ausencia de un insumo se convertirá en actividad con responsable y vencimiento.')
p('G0 contendrá acta constitutiva, alcance por unidad, matriz de responsabilidades, fuentes, comunicaciones, calendario laboral validado y riesgos. Los participantes aprobarán expresamente qué reportes y cierres son obligatorios para la primera salida.')
page('Calendario maestro y liberaciones','R identifica una versión liberada a un ambiente; G identifica una decisión con evidencia. Las fechas son objetivos condicionados. Ninguna fecha autoriza por sí sola una carga o un cierre contable.')
table(['Hito','Fecha','Ambiente y contenido','Condición de salida'],[
('G0','25 sep','Alcance y gobierno','Acta, fuentes y responsables confirmados.'),
('R0','2 oct','Pruebas y seguridad inicial','Acceso y recuperación de copia demostrados.'),
('G1','9 oct','Diseño funcional y de datos','Mapeos, reglas, pruebas y brechas priorizadas.'),
('R1','16 oct','Pruebas con maestros','Catálogos, permisos y ETL uno aceptados.'),
('G2 y R2','30 oct','Integración con ETL dos','Saldos y movimientos conciliados.'),
('G3 y R3','13 nov','Integración estabilizada','SIT aprobado y ETL tres reproducible.'),
('G4 y R4','27 nov','Candidato de producción','UAT firmado, soporte y reversión probados.'),
('R5','30 nov','Producción del alcance aprobado','Conciliación del delta y Go operativo.'),
('G5 y R6','10 y 11 dic','Correcciones si aplican y estabilidad','Regresión aprobada y transferencia operativa.'),
('G6','31 dic','Entrega de implantación','Expediente y continuidad de enero.')],[1.15,1.1,3.55,4.5],10.5)
p('Ruta crítica: G0 → perfilado y diseño G1 → maestros R1 → ETL dos G2 → pruebas y ensayo G3 → UAT y G4 → corte R5 → estabilidad G5 → entrega G6. Cada puerta pendiente bloquea a su sucesora. La preparación puede solaparse; la aceptación formal requiere resultados completos.')
p('Las páginas siguientes forman el calendario operativo. Cada actividad tiene identificador, ventana, responsable, dependencia y resultado verificable. El control semanal registrará avance real, fecha de terminación, enlace de evidencia y desviación; no se asignan porcentajes iniciales de avance.')
for no,(dates,title,gate,acts) in enumerate(w,1):
 page(f'Semana {no:02d} {title}', f'{dates} de 2026. Resultado de la semana: {gate}.')
 rows=[]
 for i,(date,act,role,dep,outcome) in enumerate(acts,1):rows.append((f'A{(no-1)*6+i:03d}',date,act,role.replace(' ','\n'),dep,outcome))
 table(['ID','Ventana','Actividad','Rol','Dependencia','Entregable y criterio de terminación'],rows,[.5,1.05,2.05,.75,1.45,4],11)
 h('Control de la semana')
 p('PM consolida evidencias y fechas reales; FP y FC revisan los resultados de su dominio. QA registra desviaciones y bloqueos. Una actividad termina cuando su entregable está revisado y tiene aceptación del responsable, no cuando concluye la ventana de tiempo.')
 if no==9:p('El 16 de noviembre se reserva sin talleres. UAT y firmas se concentran del 17 al 20; confirmar disponibilidad de usuarios y suplentes antes de G3.')
 elif no==11:p('El 30 de noviembre coincide con fin de mes. El comité decidirá qué sistema realiza el cierre de noviembre y la fecha contable de inicio en EGestion360. Queda prohibida la doble captura sin conciliación formal.')
 elif no==15:p('G6 cierra la implantación del alcance acordado. Los ajustes posteriores, el cierre contable definitivo y la cuenta pública seguirán el calendario y las autorizaciones institucionales.')
 else:p('Si una dependencia se retrasa, conservar la fecha objetivo solo cuando exista capacidad y evidencia de recuperación. El comité debe aprobar la reprogramación de cualquier liberación afectada.')
page('ETL y objetos de migración','ETL significa extracción, transformación y carga. La estrategia propuesta es una base de saldos a un corte aprobado más movimientos y novedades posteriores; el histórico completo requiere perfilado y capacidad suficientes. Se evitará contabilizar dos veces saldos, presupuesto y pólizas históricas.')
table(['Objeto','Secuencia y transformación','Control de aceptación','Dueño'],[
('Entes y unidades','Primero; claves externas a identificadores destino.','Sin duplicados, relaciones válidas y ámbito autorizado.','FP OPS'),
('Usuarios y autorizadores','Después de estructura; asociar persona y perfil.','Usuario nominal, permisos y suplencia comprobados.','OPS FP'),
('Clasificadores y programas','Homologar claves, ejercicio y combinaciones.','Todas las claves utilizadas con equivalencia.','FP'),
('Plan de cuentas','Jerarquía, naturaleza, detalle y vigencia.','Sin huérfanas ni equivalencias ambiguas.','FC'),
('Matrices y eventos','Vincular presupuesto con cuentas y momentos.','Asiento esperado aprobado por combinación.','FP FC'),
('Presupuesto mensual','Doce meses explícitos, anual y vigencia.','Suma mensual igual al anual; no enviar total a enero.','FP'),
('Adecuaciones y compromisos','Estado, documento, folio y monto pendiente.','No exceder disponible; conservar documento origen.','FP'),
('Saldos y auxiliares','Corte, ente, cuenta, período y detalle.','Balanza firmada y diferencias explicadas.','FC'),
('Pólizas y documentos abiertos','Cabecera y detalle con claves de vínculo.','Cargos igual a abonos; estados y trazabilidad completos.','FC'),
('Delta y reversas','Nuevos, modificados y cancelados desde corte.','Marca de agua, idempotencia y sin doble efecto.','DAT FC')],[1.6,3.05,4.8,.85],10.5)
p('Cada lote conservará origen, corte, responsable, huella, versión de mapeo, conteos e importes antes y después. Conteo fuente = aceptados + rechazados + exclusiones formalizadas. Los importes se conciliarán por ente, ejercicio, mes, clave, cuenta y momento; no se compensarán diferencias entre partidas sin justificación.')
page('Ensayos ETL y control de calidad de datos','Las importaciones existentes son componentes de apoyo. El proyecto debe construir el proceso completo con staging, bitácora, validación, rechazo, reejecución y recuperación. Los datos reales se usarán con autorización y protección apropiadas al ambiente.')
table(['Ciclo','Fechas','Propósito y evidencia','Salida'],[
('ETL cero','29 a 30 sep','Perfilado, volumetría, muestras y defectos.','Reglas y esfuerzo ajustados en G1.'),
('ETL uno','13 a 15 oct','Maestros, equivalencias y reejecución de lote.','R1 con catálogos aprobados.'),
('ETL dos','26 a 29 oct','Migración representativa de extremo a extremo.','G2 con saldos conciliados.'),
('ETL tres','9 a 12 nov','Base más delta, tiempo total y restauración.','G3 con ventana demostrada.'),
('Productivo','30 nov','Corte autorizado y delta final sin doble captura.','Go operativo con firma de FP y FC.')],[1.1,1.3,5.3,2.6],11)
h('Secuencia obligatoria de cada ejecución')
p('1 Preparar copia y manifiesto. 2 Extraer al corte. 3 Calcular conteos e importes fuente. 4 Transformar con diccionario versionado. 5 Cargar staging y validar. 6 Resolver o rechazar filas con causa. 7 Cargar por dependencias con identificadores externos. 8 Reconciliar destino contra fuente. 9 Ejecutar casos de negocio. 10 Obtener firma del dueño. 11 Resguardar evidencias. 12 Probar reejecución o reversión.')
h('Criterios de bloqueo')
p('No se autoriza producción con claves sin equivalencia, documentos huérfanos, pérdida de trazabilidad, pólizas descuadradas, datos de otro ente o diferencias monetarias no explicadas. El objetivo es cero diferencia a centavos; cualquier tolerancia de redondeo debe definirse por escrito, por objeto y causa, antes del ensayo. DAT no aprueba por sí mismo la validez de las cifras.')
p('Los rechazos se corrigen en origen o con transformación aprobada; no se borran de la conciliación. Cada cambio genera nueva versión de lote. Los tiempos se miden con la volumetría del corte; si el ensayo no cabe en la ventana, se reduce alcance o se cambia fecha antes de G4.')
page('Pruebas y criterios de liberación','SIT corresponde a pruebas de integración y UAT a aceptación de usuarios. QA coordina evidencia; los usuarios institucionales validan resultados. Una prueba técnica no sustituye la conciliación financiera.')
table(['Caso obligatorio','Resultado esperado','Evidencia'],[
('Presupuesto y doce meses','Anual conciliado y claves válidas; incluir archivo sin meses.','Plantilla y resultado antes después.'),
('Autorizado y adecuaciones','Estados, reversas y pólizas correctos; rechazo de saldo excedido.','Flujo firmado por FP.'),
('Reservas y concurrencia','Dos solicitudes no consumen el mismo disponible; reintentos sin duplicación.','Casos paralelos y saldos.'),
('Cadena a pago y reversa','Momento, documento y asiento coinciden en las etapas acordadas.','Matriz evento a póliza.'),
('Pólizas y permisos','Cargos igual a abonos; roles segregados; documentos protegidos.','Casos positivos y negativos.'),
('Ente y ejercicio','No consultar, modificar ni cerrar datos de un ente ajeno.','Pruebas con dos entes y perfiles.'),
('Cierre y período trece','Pendientes bloqueados; recierre y cambio 2027 sin duplicación ni fecha inválida.','Copia y balanza posterior.'),
('Reportes','Totales, filtros, signos y formato coinciden con control aprobado.','Muestra hasta documento origen.'),
('Operación y recuperación','Reinicio, API HTTPS, respaldo restaurable y tiempos medidos.','Bitácora y ensayo cronometrado.')],[2.2,5.45,2.65],10.5)
p('Puerta de producción: 100 por ciento de casos críticos aprobados; cero defectos críticos y altos que comprometan operación, seguridad o cifras; conciliación firmada; respaldo restaurado; responsables capacitados. Los defectos menores requieren solución temporal aceptada, dueño y fecha. COM registra la decisión y las excepciones no financieras admisibles.')
p('Rendimiento propuesto para acordar en G1: percentil 95 de consultas habituales menor a 3 segundos, captura menor a 5 segundos y cero errores de integridad bajo concurrencia validada. Son objetivos, no mediciones obtenidas. Reportes masivos y ETL tendrán umbrales específicos de volumen.')
page('Plan de corte y reversión del 30 de noviembre','Ventana propuesta de 06:00 a 10:00 horas de Tabasco, sujeta al ensayo del 12 de noviembre y a G4. La autorización del 27 permite ejecutar la ventana; abrir usuarios exige una segunda decisión después de conciliar.')
table(['Hora propuesta','Paso','Rol','Control para continuar'],[
('06:00','Confirmar Go técnico y congelar fuente','PM OPS','Responsables presentes, respaldo y comunicación activa.'),
('06:00 a 06:20','Respaldo y cifras de control','OPS FP FC','Corte único, folios, conteos e importes resguardados.'),
('06:20 a 07:00','Extraer y validar delta final','DAT','Cambios completos y sin rechazos críticos.'),
('07:00 a 07:40','Cargar y desplegar versión','DAT OPS','Paquetes y SQL aprobados; automatismos y configuración correctos.'),
('07:40 a 08:30','Conciliar y probar operación','FP FC QA','Saldos, momentos, pólizas y casos críticos aceptados.'),
('08:30','Go operativo o reversión','COM FP FC','Sin firmas, con diferencias no aprobadas o prueba fallida: revertir.'),
('08:30 a 09:30','Restaurar si hubo No Go','OPS DAT','Volver a versión y datos respaldados; validar integridad.'),
('09:30 a 10:00','Abrir sistema autorizado','PM UK','Comunicación única; fuente anterior queda en consulta si hay Go.'),
('Desde 10:00','Monitorear y asistir','OPS FP FC','Mesa de ayuda, primeros lotes e incidentes registrados.')],[1.25,2.7,1.05,5.3],10.5)
p('El ensayo debe demostrar reversión en un máximo propuesto de 60 minutos. Si no lo demuestra, COM cambia ventana o fecha. La hora límite para decidir reversión es 08:30. PM comunica la reapertura del origen con FP y FC, una vez verificada la consistencia.')
p('Después de abrir usuarios, restaurar puede perder operaciones nuevas: se suspende captura, se inventarían movimientos y se acuerda recuperación o compensación. No se restaura automáticamente ni se reabre origen sin conciliación. G4 decidirá quién cierra noviembre y la fecha contable de inicio, por coincidir con fin de mes.')
page('Capacitación soporte y capacidad','La operación debe continuar sin una consola abierta y sin dependencia diaria de desarrollo. Habrá acompañamiento desde la salida hasta la entrega, con atención especial al cierre del ejercicio.')
table(['Frente','Fechas y cobertura','Evidencia'],[
('Usuarios clave','11 a 20 nov; procesos, datos y UAT.','Asistencia y casos resueltos por rol.'),
('Operadores y autorizadores','23 a 26 nov; captura, revisión y autorización.','Evaluación de al menos 80 por ciento y casos críticos completos.'),
('TI y mesa de ayuda','9 a 10 dic; arranque, parada, logs, copias y recuperación.','Operación supervisada y manual con suplente.'),
('Cierre y guardias','14 a 23 dic; pendientes, reversión y escalamiento.','Ensayo de cierre, contactos y permisos.'),
('Soporte de salida','30 nov a 11 dic; revisión diaria con FP y FC.','Incidentes y aceptación G5.'),
('Continuidad','14 a 31 dic; urgencias bajo control de cambios.','Bitácora, guardias y entrega a enero.')],[2.1,4.7,3.5],11)
h('Capacidad mínima propuesta')
p('Equipo: 1 PM, 2 consultores funcionales, 2 especialistas DAT, 2 desarrolladores, 2 personas QA, 0.5 equivalente de OPS y 0.5 de CAP. Total estimado: 10 equivalentes de tiempo completo, más titulares y suplentes institucionales con al menos 25 por ciento de disponibilidad en diseño y hasta 50 por ciento en UAT y corte. Confirmar en G0; no representa una plantilla contratada.')
h('Atención y medición')
p('Prioridad 1: operación detenida, datos o seguridad comprometidos; acuse propuesto en 15 minutos y decisión de contención en 60 durante cobertura acordada. Prioridad 2: función crítica degradada; acuse en 1 hora y plan en el día. Otros casos se programan en comité. Estos objetivos se formalizan en G4, con guardias para ventanas fuera de jornada.')
p('Indicadores: actividades aceptadas frente a plan, decisiones vencidas, casos críticos aprobados, defectos, diferencias de conciliación, usuarios capacitados e incidentes reabiertos. La aceptación financiera exige cifras conciliadas aunque el avance de actividades sea favorable.')
page('Riesgos y gestión de cambios','El registro se revisará cada viernes. Cada riesgo tendrá dueño, señal y respuesta; si compromete la ruta crítica, se presenta al COM con impacto en fecha y alcance.')
table(['Riesgo','Señal y respuesta prevista','Dueño'],[
('Datos tardíos o inconsistentes','Fuentes sin corte o equivalencias; escalar en S02, repetir perfilado y bloquear ETL productivo.','DAT FP FC'),
('Alcance no dimensionado','Nuevos entes o históricos después de G0; estimar ola adicional con recursos y calendario propios.','PM COM'),
('Meses implícitos','Total cargado a enero; exigir doce meses, regla aprobada y caso de prueba antes de R2.','FP DEV'),
('Cierre global o mes trece','Alteración de otro ente o fecha inválida; corregir y probar en copia antes de producción.','FC DEV'),
('Doble afectación contable','Saldos e históricos duplican efecto; conciliar por documento, cuenta y momento.','DAT FC'),
('Reportes no aceptados','Plantilla ausente o mapeo ambiguo; decidir obligatoriedad en G1 y construir o excluir formalmente.','FC COM'),
('Corte insuficiente','Ensayo supera tiempo; ajustar volumen, técnica o fecha antes de G4.','OPS DAT'),
('Disponibilidad institucional','UAT sin usuarios o firmas; activar suplentes y mantener origen si no hay aprobación.','PM UK'),
('Cambios en cierre anual','Urgencias sin prueba; congelar desde 14 dic y autorizar solo lo indispensable.','OPS COM')],[2.2,6.85,1.25],10.5)
p('Solicitud de cambio: necesidad, procesos, fuentes, pruebas, seguridad, esfuerzo y fecha afectada. FP y FC evalúan impacto; DEV y DAT estiman; PM recalcula dependencias. Solo COM modifica la línea base. Ningún cambio se introduce como corrección de datos sin trazabilidad.')
p('Si G4 se rechaza, se continúa en origen y se replanifica la salida conservando entregables aceptados. No se compensan defectos de integridad con capacitación o aceptación tácita. Diciembre conserva actividades de preparación y entrega solo si COM aprueba el alcance revisado.')
page('Aceptación y continuidad del ejercicio siguiente','La entrega del 31 de diciembre documenta la implantación. El cierre contable definitivo de 2026, los ajustes y la cuenta pública dependen de información y autorizaciones; no concluyen por emitir el acta del proyecto.')
table(['Paquete','Entrega','Aprobación y evidencia'],[
('Gobierno y alcance','PM','COM firma G0, decisiones, cambios y límites por ente.'),
('Diseño y catálogos','FP FC DAT','Firmas institucionales de procesos, mapeos y catálogos.'),
('Migración','DAT','FP y FC aceptan conteos, saldos, rechazos y conciliación final.'),
('Pruebas y versión','QA DEV','UAT, regresión, versión y contenido de liberación.'),
('Operación','OPS','TI acepta acceso, monitoreo, copias y restauración.'),
('Capacitación','CAP','Usuarios acreditan ejecución autónoma.'),
('Cierre de implantación','PM','COM firma G6 y pendientes con dueño y vencimiento.')],[2,1.7,6.6],11)
h('Continuidad para enero de 2027')
p('Ajustes posteriores al corte, cierre anual definitivo, período trece y saldos de apertura en el momento autorizado, información definitiva de reportes e incidencias menores. La preparación y el ensayo deben concluir antes del 18 de diciembre; la ejecución real seguirá el calendario oficial.')
h('Registro de aceptación')
p('Patrocinio institucional: ____________________  Fecha: __________\nResponsable de Presupuesto: _________________  Fecha: __________\nResponsable de Contabilidad: _________________  Fecha: __________\nResponsable de TI y operación: ________________  Fecha: __________\nDirección del proyecto: ______________________  Fecha: __________')
p('La firma confirma los entregables y restricciones documentados. Un pendiente sin responsable, criterio y fecha no se considera transferido.')
page('Evidencias del código y referencias de trabajo','Corte técnico al 8 de septiembre de 2026. Índice actualizado a partir del commit 211aecb674e73fe750cf8f78a390ab8ba9a247f8 e incluyendo cambios locales. La revisión estática no ejecutó operaciones de producción.')
table(['ID','Referencia','Archivos localizables en el índice'],[
('E01','Mensualización','EgresoProyectadoAppService.cs y EgresoProyectadoAiImportParser.cs, líneas 121 a 125 del parser.'),
('E02','Autorizado','EgresoAutorizadoAppService.cs, creación desde anteproyecto y controles de reversa.'),
('E03','Adecuaciones','PresupuestoModificadoServices.cs y 20260729_PresupuestoModificado_Egresos_Contexto_Flujo.sql.'),
('E04','Suficiencia','PresupuestoComprometidoServices.cs, validaciones de ejercicio, reserva y autorizador.'),
('E05','Momentos y pagos','CuentasXPagarServices.cs e IngresoAutorizadoAppService.cs.'),
('E06','Cuentas y matrices','CuentaContableService.cs, MatrizConversionService.cs y MatrizIngresoService.cs.'),
('E07','Pólizas','PolizaService.cs, PolizaAiImportParser.cs y PolizaController.cs.'),
('E08','Cierre','CierreMensualService.cs y Scripts/01_GestionEmpresarial_Script_Final_BD.sql, CONTA.SP_SaldoMensual.'),
('E09','Reportes','FrontEnd/EG.Web/Pages/Modules/GRP/Contabilidad/ContabilidadReportes.razor, opciones y plantillas.'),
('E10','Despliegue','FrontEnd/EG.Web/wwwroot/index.html, FrontEnd/EG.Web/web.config y Tools/DeployLocalInstaller/Instalar.ps1.')],[.6,1.5,8.2],10)
p('Índice de referencia: artifacts/implementacion_2026/indice_codigo/PROJECT_MAP.md, files.txt y symbols.tsv. Contiene 1,645 declaraciones de rutas y páginas; no equivalen a endpoints únicos. La extracción usa expresiones regulares y XML; no mide avance, cobertura ni aprobación funcional.')
p('Referencias institucionales para G1: CEAC Tabasco, Manual de Contabilidad Gubernamental, publicación identificada del 29 de julio de 2026: https://ceac.tabasco.gob.mx/content/manual-de-contabilidad-gubernamental. CONAC, normatividad vigente: https://www.conac.gob.mx/es/CONAC/Normatividad_Vigente. Portal de Finanzas: https://tabasco.gob.mx/finanzas. Consulta 8 de septiembre de 2026. FP y FC confirmarán instrumentos aplicables y actualizaciones; esta planeación no certifica cumplimiento normativo.')
for para in doc.paragraphs:
 if para.style.name.startswith('Heading'):para.paragraph_format.keep_with_next=True
 for run in para.runs:
  pr=run._r.get_or_add_rPr();lang=OxmlElement('w:lang');lang.set(qn('w:val'),'es-MX');pr.append(lang)
filename=OUT/'Calendario_Implementacion_Presupuesto_Contabilidad_Tabasco_2026.docx'
for st in doc.styles:
 for b in list(st.element.iter(qn('w:pBdr'))): b.getparent().remove(b)
for para in doc.paragraphs:
 for b in list(para._p.iter(qn('w:pBdr'))): b.getparent().remove(b)
doc.save(filename)
print('Paginas planeadas:',page_count,'Actividades:',sum(len(x[3]) for x in w),'Archivo:',filename)