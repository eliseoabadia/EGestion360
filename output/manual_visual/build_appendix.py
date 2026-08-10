from pathlib import Path
from reportlab.lib import colors
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak
from pypdf import PdfReader, PdfWriter

ROOT = Path(__file__).resolve().parent
BASE = ROOT / "Manual_visual_presupuesto_a_orden_compra.pdf"
APPENDIX = ROOT / "appendix_flujo_completo.pdf"
OUT = ROOT / "Manual_visual_presupuesto_a_entrada_almacen.pdf"
BLUE = colors.HexColor("#2E74B5")
NAVY = colors.HexColor("#17365D")
LIGHT = colors.HexColor("#EAF2F8")
GREEN = colors.HexColor("#E2F0D9")
AMBER = colors.HexColor("#FFF2CC")

styles = getSampleStyleSheet()
styles.add(ParagraphStyle(name="H", parent=styles["Heading1"], fontName="Helvetica-Bold", fontSize=17, leading=20, textColor=BLUE, spaceAfter=10))
styles.add(ParagraphStyle(name="B", parent=styles["BodyText"], fontName="Helvetica", fontSize=9.5, leading=12, spaceAfter=5))
styles.add(ParagraphStyle(name="S", parent=styles["BodyText"], fontName="Helvetica", fontSize=8, leading=10))
styles.add(ParagraphStyle(name="W", parent=styles["BodyText"], fontName="Helvetica-Bold", fontSize=8, leading=10, textColor=colors.white))

def p(text, style="B"):
    return Paragraph(text, styles[style])

def footer(canvas, doc):
    canvas.saveState(); canvas.setFont("Helvetica", 8); canvas.setFillColor(colors.grey)
    canvas.drawCentredString(letter[0]/2, .38*inch, f"PCI · Manual visual · continuación {doc.page}")
    canvas.restoreState()

def route(menu, owner):
    t = Table([[p("MENÚ › " + menu, "S"), p("RESPONSABLE › " + owner, "S")]], colWidths=[4.9*inch, 2.1*inch])
    t.setStyle(TableStyle([("BACKGROUND",(0,0),(-1,-1),LIGHT),("BOX",(0,0),(-1,-1),.5,BLUE),("LEFTPADDING",(0,0),(-1,-1),7),("TOPPADDING",(0,0),(-1,-1),6),("BOTTOMPADDING",(0,0),(-1,-1),6)]))
    return [t, Spacer(1,9)]

def box(title, body, fill=LIGHT):
    t=Table([[p(f"<b>{title}</b><br/>{body}")]], colWidths=[7*inch])
    t.setStyle(TableStyle([("BACKGROUND",(0,0),(-1,-1),fill),("BOX",(0,0),(-1,-1),.5,NAVY),("LEFTPADDING",(0,0),(-1,-1),8),("RIGHTPADDING",(0,0),(-1,-1),8),("TOPPADDING",(0,0),(-1,-1),7),("BOTTOMPADDING",(0,0),(-1,-1),7)]))
    return [t,Spacer(1,9)]

def table(headers, rows, widths):
    data=[[p(x,"W") for x in headers]]+[[p(str(x),"S") for x in row] for row in rows]
    t=Table(data,colWidths=widths,repeatRows=1)
    t.setStyle(TableStyle([("BACKGROUND",(0,0),(-1,0),BLUE),("GRID",(0,0),(-1,-1),.35,colors.HexColor("#A6A6A6")),("VALIGN",(0,0),(-1,-1),"MIDDLE"),("LEFTPADDING",(0,0),(-1,-1),5),("RIGHTPADDING",(0,0),(-1,-1),5),("TOPPADDING",(0,0),(-1,-1),5),("BOTTOMPADDING",(0,0),(-1,-1),5)]))
    return t

story=[]
story += [p("12. La solicitud de suficiencia ya es visible", "H")]
story += route("Presupuesto › Egreso › Comprometido › Solicitud de Suficiencia", "Área solicitante / Presupuesto")
story += box("CORRECCIÓN DE RAÍZ", "La consulta filtraba por el área del usuario, pero la vista no exponía FKIdArea_SIS. Se agregó el campo a PRES.Vw_SolicitudSuficiencia y al modelo. Ahora la solicitud 15 pertenece al área 1025 y pasa el filtro del usuario.", GREEN)
story += [table(("Dato","Valor","Comprobación"),[("Solicitud","15","Activa"),("Requisición","11 · REQ-000011","Compra de papel bond"),("Área","1025 · ALMACÉN TULTITLÁN","Coincide con la solicitante"),("Ejercicio","2026","Coincide con el encabezado"),("Estado","Autorizada","Lista para compromiso")],[1.4*inch,2.9*inch,2.7*inch]),Spacer(1,12)]
story += box("SI NO APARECE", "Compruebe el ejercicio 2026, la empresa, el área asignada al usuario y pulse Actualizar. No duplique la solicitud: primero revise sus filtros.", AMBER)
story += [PageBreak(),p("13. Pólizas contables del expediente", "H")]
story += route("Contabilidad › Pólizas", "Contabilidad / Presupuesto")
story += [p("Busque por las claves siguientes. Las tres pólizas están activas, autorizadas y balanceadas; cada una conserva Debe = Haber.")]
story += [table(("ID / clave","Momento","Debe","Haber"),[("30 · MANAUT001","Presupuesto autorizado · partida 21101","$12,000.00","$12,000.00"),("31 · MANCOM001","Compromiso OC-2026-0001","$2,400.00","$2,400.00"),("32 · MANDEV001","Devengado por recepción","$2,400.00","$2,400.00")],[1.55*inch,3.15*inch,1.15*inch,1.15*inch]),Spacer(1,12)]
story += box("QUÉ DEBE VER", "En la lista de Pólizas deben aparecer MANAUT001, MANCOM001 y MANDEV001. Abra cada una para verificar dos movimientos y diferencia $0.00.", GREEN)
story += box("TRAZABILIDAD", "El presupuesto autorizado 12 enlaza a la póliza 30. La orden 6 enlaza a la póliza de compromiso 31. La póliza 32 documenta el efecto presupuestal de la recepción.", LIGHT)
story += [PageBreak(),p("14. Autorizar la orden y recibir en almacén", "H")]
story += route("Adquisiciones › Orden de Compra / Almacén › Recepción de Pedidos", "Compras / Almacén")
story += [p("<b>1.</b> Abra OC-2026-0001 y confirme proveedor, partida 21101, 10 millares y total $2,400."),p("<b>2.</b> Autorice la orden. Su estado operativo queda Por surtir (2)."),p("<b>3.</b> Entre a Recepción de Pedidos, seleccione la orden y su detalle."),p("<b>4.</b> Registre la entrada completa con factura FAC-MANUAL-001 y remisión REM-MANUAL-001."),p("<b>5.</b> Verifique recibido 10 y pendiente 0.")]
story += [Spacer(1,7),table(("Campo","Resultado"),[("Entrada","1 · ENT-OC-2026-0001"),("Orden / detalle","OC-2026-0001 · detalle 6"),("Artículo","MO00394 · papel bond tamaño carta"),("Cantidad","10 MILLARES"),("Costo unitario / total","$240.00 / $2,400.00"),("Estado contable","Contabilizado")],[2.25*inch,4.75*inch]),Spacer(1,12)]
story += box("RESULTADO", "El pedido ya no tiene cantidad pendiente y la entrada queda ligada al detalle de la orden; no es una existencia manual aislada.", GREEN)
story += [PageBreak(),p("15. Trazabilidad completa del caso", "H")]
story += [table(("Etapa","Registro","Estado / importe"),[("Presupuesto proyectado","Anteproyecto 2","$12,000 · agosto"),("Presupuesto autorizado","12 · póliza 30","$12,000 · autorizado"),("Requisición","11 · REQ-000011","$2,500"),("Cotización ganadora","27","$2,400"),("Suficiencia","15 · autorización 13","Autorizada · $2,500"),("Compromiso","14 · COMP-MANUAL-2026-001","Vigente · $2,500"),("Orden de compra","6 · OC-2026-0001","Por surtir · $2,400"),("Entrada de almacén","1 · ENT-OC-2026-0001","10 recibidos · 0 pendientes"),("Pólizas","30, 31 y 32","Todas balanceadas")],[1.75*inch,2.65*inch,2.6*inch]),Spacer(1,12)]
story += box("EXPEDIENTE COMPLETO", "El flujo queda probado desde presupuesto proyectado hasta recepción de almacén, incluyendo solicitud de suficiencia visible y efectos contables balanceados.", GREEN)

SimpleDocTemplate(str(APPENDIX),pagesize=letter,rightMargin=.75*inch,leftMargin=.75*inch,topMargin=.65*inch,bottomMargin=.62*inch,title="Continuación del manual visual PCI").build(story,onFirstPage=footer,onLaterPages=footer)
writer=PdfWriter()
for source in (BASE,APPENDIX):
    for page in PdfReader(str(source)).pages: writer.add_page(page)
with OUT.open("wb") as f: writer.write(f)
print(OUT)
