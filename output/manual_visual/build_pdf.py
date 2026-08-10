from pathlib import Path
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Image, Table, TableStyle, PageBreak, KeepTogether
from PIL import Image as PILImage

ROOT = Path(__file__).resolve().parent
CAP = ROOT / "capturas"
OUT = ROOT / "Manual_visual_presupuesto_a_orden_compra.pdf"
BLUE = colors.HexColor("#2E74B5")
NAVY = colors.HexColor("#17365D")
LIGHT = colors.HexColor("#EAF2F8")
GREEN = colors.HexColor("#E2F0D9")
AMBER = colors.HexColor("#FFF2CC")
RED = colors.HexColor("#FCE4D6")
GRAY = colors.HexColor("#F2F2F2")

styles = getSampleStyleSheet()
styles.add(ParagraphStyle(name="Cover", parent=styles["Title"], fontName="Helvetica-Bold", fontSize=24, leading=29, textColor=NAVY, alignment=TA_CENTER, spaceAfter=18))
styles.add(ParagraphStyle(name="H1x", parent=styles["Heading1"], fontName="Helvetica-Bold", fontSize=16, leading=19, textColor=BLUE, spaceAfter=8))
styles.add(ParagraphStyle(name="H2x", parent=styles["Heading2"], fontName="Helvetica-Bold", fontSize=12, leading=14, textColor=NAVY, spaceBefore=5, spaceAfter=4))
styles.add(ParagraphStyle(name="Bodyx", parent=styles["BodyText"], fontName="Helvetica", fontSize=9.2, leading=11.3, spaceAfter=4))
styles.add(ParagraphStyle(name="Smallx", parent=styles["BodyText"], fontName="Helvetica", fontSize=7.8, leading=9.2, textColor=colors.HexColor("#595959")))
styles.add(ParagraphStyle(name="Routex", parent=styles["BodyText"], fontName="Helvetica-Bold", fontSize=8.2, leading=10, textColor=NAVY))
styles.add(ParagraphStyle(name="Captionx", parent=styles["BodyText"], fontName="Helvetica-Oblique", fontSize=7.6, leading=9, alignment=TA_CENTER, textColor=colors.HexColor("#595959")))
styles.add(ParagraphStyle(name="Headerx", parent=styles["BodyText"], fontName="Helvetica-Bold", fontSize=7.8, leading=9.2, textColor=colors.white))

def P(text, style="Bodyx"):
    return Paragraph(text, styles[style])

def footer(canvas, doc):
    canvas.saveState()
    canvas.setFont("Helvetica", 8)
    canvas.setFillColor(colors.HexColor("#666666"))
    canvas.drawCentredString(letter[0]/2, 0.38*inch, f"PCI · Manual visual · {doc.page}")
    canvas.restoreState()

def box(title, body, fill=LIGHT):
    t = Table([[P(f"<b>{title}</b><br/>{body}", "Bodyx")]], colWidths=[7.0*inch])
    t.setStyle(TableStyle([("BACKGROUND",(0,0),(-1,-1),fill),("BOX",(0,0),(-1,-1),0.5,NAVY),("LEFTPADDING",(0,0),(-1,-1),8),("RIGHTPADDING",(0,0),(-1,-1),8),("TOPPADDING",(0,0),(-1,-1),6),("BOTTOMPADDING",(0,0),(-1,-1),6)]))
    return [t, Spacer(1,6)]

def route(path, owner):
    t=Table([[P("MENÚ › "+path,"Routex"),P("RESPONSABLE › "+owner,"Routex")]],colWidths=[5.05*inch,1.95*inch])
    t.setStyle(TableStyle([("BACKGROUND",(0,0),(-1,-1),LIGHT),("BOX",(0,0),(-1,-1),0.4,BLUE),("VALIGN",(0,0),(-1,-1),"MIDDLE"),("LEFTPADDING",(0,0),(-1,-1),6),("RIGHTPADDING",(0,0),(-1,-1),6)]))
    return [t,Spacer(1,6)]

def steps(items):
    return [P(f"<b>{i}.</b> {x}") for i,x in enumerate(items,1)]

def shot(name, caption, maxh=3.55*inch):
    path=CAP/name
    with PILImage.open(path) as im: w,h=im.size
    maxw=7.0*inch
    scale=min(maxw/w,maxh/h)
    img=Image(str(path),width=w*scale,height=h*scale)
    img.hAlign="CENTER"
    return [img,Spacer(1,3),P(caption,"Captionx"),Spacer(1,6)]

story=[]
story += [Spacer(1,0.75*inch),P("PCI","H1x"),P("Del presupuesto proyectado<br/>a la orden de compra","Cover"),P("Manual visual paso a paso · Ejercicio completo en EGestion360","Cover"),Spacer(1,0.15*inch)]
story += box("CASO PRÁCTICO","Compra de 10 millares de papel bond tamaño carta para ALMACÉN TULTITLÁN. Presupuesto: $12,000. Requisición: $2,500. Orden: $2,400.",GREEN)
coverdata=[[P("Usuario","Routex"),P("ADMIN001 · Gabriela Corona Espinosa")],[P("Entidad","Routex"),P("Plataforma de Compras Integral · Sucursal Operativa")],[P("Área","Routex"),P("208C0101320202T · ALMACÉN TULTITLÁN")],[P("Ejercicio","Routex"),P("2026")],[P("Fecha","Routex"),P("10 de agosto de 2026")]]
t=Table(coverdata,colWidths=[1.35*inch,5.65*inch]); t.setStyle(TableStyle([("BACKGROUND",(0,0),(0,-1),LIGHT),("GRID",(0,0),(-1,-1),0.35,colors.HexColor("#A6A6A6")),("VALIGN",(0,0),(-1,-1),"MIDDLE"),("LEFTPADDING",(0,0),(-1,-1),7),("TOPPADDING",(0,0),(-1,-1),5),("BOTTOMPADDING",(0,0),(-1,-1),5)])); story += [t,Spacer(1,12),P("Documento generado sobre una base local/de prueba. No contiene contraseñas.","Captionx"),PageBreak()]

story += [P("1. Ruta completa y resultado","H1x"),P("Respete este orden: el sistema valida dependencias entre usuario, área, presupuesto, cotizaciones y proveedor adjudicado.")]
rows=[["Etapa","Resultado","Menú"],["0. Usuario","Solicitante en ALMACÉN TULTITLÁN","Configuración › Usuario"],["1. Proyectar","Anteproyecto 2 · $12,000","Presupuesto › Proyectado"],["2. Autorizar","Presupuesto autorizado 12","Presupuesto › Autorizado"],["3. Requerir","REQ-000011 · $2,500","Adquisiciones › Requisición"],["4. Cotizar","Cotizaciones 26, 27 y 28","Adquisiciones › Cotización"],["5. Suficiencia","Solicitud 15 · autorización 13","Presupuesto › Comprometido"],["6. Ordenar","COMP-MANUAL... · OC-2026-0001","Comprometido / Orden Compra"]]
td=[[P(c,"Headerx" if i==0 else "Smallx") for c in row] for i,row in enumerate(rows)]
t=Table(td,colWidths=[1.15*inch,2.85*inch,3.0*inch],repeatRows=1); style=[("BACKGROUND",(0,0),(-1,0),BLUE),("TEXTCOLOR",(0,0),(-1,0),colors.white),("GRID",(0,0),(-1,-1),0.35,colors.HexColor("#A6A6A6")),("VALIGN",(0,0),(-1,-1),"MIDDLE"),("LEFTPADDING",(0,0),(-1,-1),5),("TOPPADDING",(0,0),(-1,-1),5),("BOTTOMPADDING",(0,0),(-1,-1),5)]; t.setStyle(TableStyle(style)); story += [t,Spacer(1,10)]
story += box("IMPORTES","Presupuesto $12,000 → requisición/suficiencia $2,500 → oferta y orden $2,400. El compromiso conserva el techo autorizado de $2,500.",AMBER)
story += box("ÉXITO","La orden termina con 1 detalle, 1 partida, total $2,400 y GRUPO EMPRESARIAL EMPROVE.",GREEN)
story += [PageBreak()]

pages=[
("2. Preparar usuario, persona y área","Configuración › Sistema › Usuario","Administrador del sistema",["Busque a Gabriela Corona Espinosa y abra Editar usuario.","Asigne ALMACÉN TULTITLÁN.","Active Adscrito y Es solicitante; confirme la asignación.","Mantenga activo al usuario."],["04_usuario_area_asignada.png","Resultado: área asignada y habilitada para solicitar."],("SI APARECE EL ERROR DE SOLICITANTE","Revise usuario activo, persona vinculada, área y marca Es solicitante.",RED)),
("3. Crear presupuesto proyectado","Presupuesto › Egreso › Proyectado › Anteproyecto","Área de Presupuesto",["Pulse Nuevo; seleccione ejercicio 2026, programa 02030201 y ALMACÉN TULTITLÁN.","Use partida 21101, Ingresos propios, TG 1, DI 1, DG 1 y proyecto 10766.","Capture $12,000 en agosto y guarde.","Compruebe que el total sea $12,000."],["05_anteproyecto_capturado.png","Ejemplo de captura inicial. La imagen muestra septiembre; para este caso cambie el importe a agosto antes de guardar."],("CONTROL CLAVE","El saldo debe estar en el mismo mes de la requisición; aquí, agosto.",AMBER)),
("4. Autorizar presupuesto","Presupuesto › Egreso › Proyectado › Autorizar","Responsable presupuestal",["Localice el anteproyecto y pulse Autorizar.","Revise programa, partida, fuente, área, proyecto y total.","Confirme y verifique el registro autorizado."],["08_autorizar_anteproyecto.png","Confirme la autorización sólo después de revisar importe y clasificación."],("NO AUTORICE SI…","Importe, mes o clasificación no corresponden al expediente.",RED)),
("5. Crear la requisición","Adquisiciones › Requisición","Área solicitante / Compras",["Capture $2,500, tipo Bien, procedimiento Ordinario y solicitante Gabriela.","Elija la posición presupuestal autorizada.","Guarde REQ-000011.","Agregue partida 21101 por $2,500 y MO00394: 10 MILLARES."],["16_requisicion_completa.png","Resultado: requisición con partida y bien."],("SI EL BIEN NO SE AGREGA","Solicite a Almacén revisar catálogo, unidad y disponibilidad/configuración.",RED)),
("6. Registrar tres cotizaciones","Adquisiciones › Cotización","Compras / Padrón de proveedores",["Cree una cotización ligada a la requisición 11.","Agregue el bien y precio unitario.","Repita con tres proveedores distintos.","Adjudique COT-27 por $2,400."],["21_tres_cotizaciones.png","Tres ofertas completas; COT-27 es la menor."],("VALIDACIÓN","Cada proveedor debe cotizar todos los bienes activos.",AMBER)),
("7. Solicitar y autorizar suficiencia","Presupuesto › Comprometido › Suficiencia","Área solicitante / Presupuesto",["Seleccione requisición 11 y ejecute precálculo.","Compruebe 3 cotizaciones, partida 21101, agosto y $2,500.","Genere solicitud 15.","Autorice con persona facultada; autorización 13."],["22_suficiencia_precalculo.png","Precálculo de suficiencia antes de guardar."],("NO CONTINÚE SI…","Falta cotización, saldo mensual, clasificación o autorizador.",RED)),
("8. Registrar compromiso","Presupuesto › Comprometido › Registro Comprometido","Presupuesto / Contratos",["Seleccione autorización 13.","Use el proveedor ganador GRUPO EMPRESARIAL EMPROVE.","Capture COMP-MANUAL-2026-001, fecha y $2,500.","Guarde con estatus Vigente."],["29_registro_comprometido_creado.png","Compromiso vigente por el techo autorizado."],("POR QUÉ $2,500","El compromiso corresponde a la suficiencia; la orden usa el precio adjudicado $2,400.",AMBER)),
("9. Crear y completar orden","Adquisiciones › Orden de Compra","Compras",["Seleccione requisición 11 y COT-27.","Cree OC-2026-0001.","Agregue MO00394: 10 × $240.","Agregue partida 21101, Ingresos propios, $2,400.","Verifique total, 1 detalle y 1 partida."],["31_orden_compra_creada_final.png","OC-2026-0001 completa por $2,400."],("COMMITMENT_REQUIRED","Vaya a Registro Comprometido y cree un compromiso vigente con el mismo proveedor.",RED)),
]
for title,path,owner,items,im,alert in pages:
    story += [P(title,"H1x")]+route(path,owner)+steps(items)+[Spacer(1,4)]+shot(im[0],im[1],3.65*inch)+box(*alert)+[PageBreak()]

story += [P("10. Bloqueos y responsables","H1x")]
issues=[("Solicitante sin área","Configuración › Usuario","Administrador","Asignar área y Es solicitante."),("Sin posición presupuestal","Presupuesto › Proyectado/Autorizado","Presupuesto","Crear/autorizar saldo en agosto."),("Exige 3 cotizaciones","Adquisiciones › Cotización","Compras","Completar 3 proveedores distintos."),("Suficiencia insuficiente","Presupuesto › Suficiencia","Presupuesto","Revisar mes, partida, fuente e importe."),("COMMITMENT_REQUIRED","Registro Comprometido","Presupuesto/Contratos","Misma autorización y proveedor."),("Orden en $0","Orden de Compra › Ver detalle","Compras","Agregar detalle y partida.")]
data=[[P(x,"Headerx" if i==0 else "Smallx") for x in row] for i,row in enumerate([("Síntoma","Dónde ir","Responsable","Acción")]+issues)]
t=Table(data,colWidths=[1.45*inch,2.0*inch,1.4*inch,2.15*inch],repeatRows=1); t.setStyle(TableStyle([("BACKGROUND",(0,0),(-1,0),BLUE),("TEXTCOLOR",(0,0),(-1,0),colors.white),("GRID",(0,0),(-1,-1),0.35,colors.HexColor("#A6A6A6")),("VALIGN",(0,0),(-1,-1),"MIDDLE"),("LEFTPADDING",(0,0),(-1,-1),4),("RIGHTPADDING",(0,0),(-1,-1),4),("TOPPADDING",(0,0),(-1,-1),5),("BOTTOMPADDING",(0,0),(-1,-1),5)])); story += [t,Spacer(1,10),P("Checklist final","H2x")]
for x in ["Usuario activo, área y permiso solicitante.","Presupuesto autorizado en agosto.","Requisición con partida y bien; tres cotizaciones.","Suficiencia autorizada y compromiso vigente.","Orden con 1 detalle, 1 partida y $2,400."]: story.append(P("• "+x))
story += [PageBreak(),P("11. Trazabilidad del ejercicio","H1x")]
records=[("Anteproyecto","2","$12,000","Agosto 2026"),("Autorizado","12","$12,000","21101"),("Requisición","11 / REQ-000011","$2,500","10 millares"),("Cotizaciones","26, 27, 28","$2,400 ganadora","COT-27"),("Suficiencia","15 / autorización 13","$2,500","Autorizada"),("Compromiso","14 / COMP-MANUAL-2026-001","$2,500","Vigente"),("Orden","6 / OC-2026-0001","$2,400","1 detalle · 1 partida")]
data=[[P(x,"Headerx" if i==0 else "Smallx") for x in row] for i,row in enumerate([("Entidad","ID","Importe","Referencia")]+records)]
t=Table(data,colWidths=[1.45*inch,2.35*inch,1.35*inch,1.85*inch],repeatRows=1); t.setStyle(TableStyle([("BACKGROUND",(0,0),(-1,0),BLUE),("TEXTCOLOR",(0,0),(-1,0),colors.white),("GRID",(0,0),(-1,-1),0.35,colors.HexColor("#A6A6A6")),("VALIGN",(0,0),(-1,-1),"MIDDLE"),("LEFTPADDING",(0,0),(-1,-1),5),("TOPPADDING",(0,0),(-1,-1),5),("BOTTOMPADDING",(0,0),(-1,-1),5)])); story += [t,Spacer(1,12)]+box("CIERRE","El expediente quedó trazado hasta OC-2026-0001. El siguiente paso operativo es revisar y autorizar la orden conforme a permisos y políticas.",GREEN)

doc=SimpleDocTemplate(str(OUT),pagesize=letter,rightMargin=0.75*inch,leftMargin=0.75*inch,topMargin=0.65*inch,bottomMargin=0.62*inch,title="Manual visual: presupuesto a orden de compra",author="EGestion360")
doc.build(story,onFirstPage=footer,onLaterPages=footer)
print(OUT)
