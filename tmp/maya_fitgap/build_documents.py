from pathlib import Path
import json, hashlib, collections, subprocess, re
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_CELL_VERTICAL_ALIGNMENT
from docx.oxml import OxmlElement
from docx.oxml.ns import qn

ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'tmp/maya_fitgap'
OUT=ROOT/'output/documentos/universidad-maya'
OUT.mkdir(parents=True,exist_ok=True)
groups=[]; rows=[]
for ln in (WORK/'requisitos.txt').read_text(encoding='utf-8-sig').splitlines():
    if not ln.strip(): continue
    parts=ln.split('|')
    if len(parts)==2:
        groups.append({'letter':parts[0],'name':parts[1],'rows':[]})
    else:
        assert len(parts)==9,(ln,len(parts))
        row=dict(zip(['id','name','req','accept','source','status','evidence','gap','phase'],parts))
        groups[-1]['rows'].append(row);rows.append(row)
assert len(rows)==101 and len(set(r['id'] for r in rows))==101
counts=collections.Counter(r['status'] for r in rows)
sourceindex=json.loads((ROOT/'output/pdf/universidad-maya/indice.json').read_text(encoding='utf-8-sig'))
sources=sourceindex['documentos']
for s in sources:
    assert hashlib.sha256(Path(s['origen']).read_bytes()).hexdigest()==s['sha256']

A='BackEnd/EG.Application/Modules/GRP/Services/'
P='BackEnd/EG.Application/Platform/Services/'
E={}
def ev(code, title, short, detail, specs):
    files=[]
    for path,pattern in specs:
        f=ROOT/path
        assert f.is_file(),path
        lines=f.read_bytes().decode('utf-16' if f.read_bytes()[:2] in [b'\xff\xfe',b'\xfe\xff'] else 'utf-8-sig',errors='replace').splitlines()
        hits=[i+1 for i,l in enumerate(lines) if re.search(pattern,l)]
        assert hits,(path,pattern)
        files.append({'path':path,'line':hits[0],'sha':hashlib.sha256(f.read_bytes()).hexdigest()[:12]})
    E[code]={'title':title,'short':short,'detail':detail,'files':files}
ev('E01','Organización','Catálogos de empresas y sucursales; contexto por empresa.','Los servicios permiten administrar empresas y sucursales. Su equivalencia con campus y la consolidación corporativa requieren configuración y pruebas.',[(P+'General/EmpresaAppService.cs','CreateAsync'),(P+'General/SucursalAppService.cs','CreateAsync')])
ev('E02','Proveedores y artículos','Servicios de proveedores y artículos.','Existe base de catálogos de adquisiciones. Esto no acredita validación SAT, evaluación de riesgo ni expediente bancario corporativo completo.',[(A+'Adquisicion/ProveedorAppService.cs','class Proveedor'),(A+'Adquisicion/ArticuloAppService.cs','class Articulo')])
ev('E03','Usuarios y autorización','Administración de acceso y permisos por política.','Hay administración de acceso y autorización por permisos. La segregación por transacción necesita reglas de incompatibilidad; el tratamiento de SuperAdmin debe acordarse.',[(P+'AccessConfiguration/AccessConfigurationAppService.cs','class AccessConfiguration'),('BackEnd/EG.ApiCoreBS/Auth/PermissionAuthorizationHandler.cs','HandleRequirementAsync')])
ev('E04','Requisiciones y flujo','Requisición con contexto, estados y controles SQL.','Creación y edición de requisiciones, protección del flujo y scripts con folio y validaciones entre documentos. Se debe verificar que los objetos SQL estén desplegados.',[(A+'Adquisicion/RequisicionAppService.cs','CreateAsync'),('Scripts/20260728_FlujoRequisicionHastaCheque.sql','TRIGGER.*ValidarYAsignarFolio')])
ev('E05','Cotizaciones y órdenes','Cotizaciones, investigación de mercado y órdenes.','Las cotizaciones registran condiciones y la interfaz de investigación de mercado compara ofertas. La orden usa procedimientos de mantenimiento; faltan criterios corporativos de riesgo fiscal.',[(A+'Adquisicion/CotizacionAppService.cs','CreateAsync'),(A+'Adquisicion/OrdenCompraAppService.cs','CreateAsync'),('FrontEnd/EG.Web/Pages/Modules/GRP/Presupuesto/Egreso/Investigacion_Mercado.razor','(?i)proveedor')])
ev('E06','Presupuesto','Anteproyecto, suficiencia y adecuaciones presupuestales.','Existen validación de disponibilidad y movimientos presupuestales con workflow. Los clasificadores y momentos gubernamentales deben traducirse al modelo de la institución.',[(A+'Configuracion/Catalogo/Presupuestales/EgresoProyectadoAppService.cs','CreateAsync'),(A+'PresupuestoComprometido/PresupuestoComprometidoServices.cs','ValidateBudgetAvailability'),(A+'PresupuestoModificado/PresupuestoModificadoServices.cs','ValidateDetailsForWorkflow')])
ev('E07','Recepción de almacén','Recepción vinculada al detalle de orden de compra.','El movimiento ajusta la recepción de la orden dentro de una transacción. Se requiere validar recepción parcial, reversas y aceptación de servicios.',[(A+'Almacen/AlmacenAppService.cs','AdjustOrderReceiptAsync'),('FrontEnd/EG.Web/Pages/Modules/GRP/Almacen/Recepcion_Pedidos.razor','(?i)recepci')])
ev('E08','Facturas y pagos','Factura, CLC y cheque con validaciones locales.','Valida contrato, importes, contexto y UUID informado. El cheque exige el importe de la CLC y controla duplicidad por CLC. CLC significa cuenta por liquidar certificada y requiere adaptación al lenguaje corporativo.',[(A+'CuentasXPagar/CuentasXPagarServices.cs','class FacturaAppService'),(A+'CuentasXPagar/CuentasXPagarServices.cs','class ChequeAppService'),('BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/CuentasXPagar/CuentasXPagarControllers.cs','class FacturaController')])
ev('E09','Catálogos de tesorería','Cuentas bancarias, CLABE y provisión de importes.','El almacenamiento de CLABE y la consulta de provisiones no acreditan conectividad bancaria, validación de titularidad o calendario automático de pagos.',[(A+'Configuracion/Catalogo/Tesoreria/InversionesServices.cs','(?i)clabe'),(A+'Configuracion/Catalogo/Tesoreria/ProvisionPagoImporteAppService.cs','class Provision')])
ev('E10','Bienes e inventarios','Bienes, recepción patrimonial, inventarios y diferencias.','El servicio de bienes permite generar activos desde detalle de orden y registrar recepción. Hay calendario, inventario y cédula de diferencias como base del control físico.',[(A+'Patrimonio/BienAppService.cs','GenerarDesdeDetalleOrdenCompra'),(A+'Patrimonio/InventarioAppService.cs','class Inventario'),(A+'Patrimonio/CedulaDiferenciasAppService.cs','class Cedula')])
ev('E11','Custodia de bienes','Resguardos y movimientos de asignación y liberación.','Existen encabezado, detalle y movimientos de custodia. No se acredita un flujo completo de traspaso autorizado ni un expediente especializado de inmuebles.',[(A+'Patrimonio/ResguardoAppService.cs','CreateAsync'),(A+'Patrimonio/ResguardoDetalleAppService.cs','"ASIGNACION"'),(A+'Patrimonio/ResguardoDetalleAppService.cs','"LIBERACION"')])
ev('E12','Bajas patrimoniales','Bajas con validaciones y aplicación controlada.','El servicio controla motivos, estado y aplicación. Se debe adaptar la autorización y desacoplar referencias laborales cuando el responsable del resguardo dependa de ellas.',[(A+'Patrimonio/BajaAppService.cs','CreateAsync'),(A+'Patrimonio/BajaAppService.cs','AplicarAsync')])
ev('E13','Soporte documental','Carga, consulta y descarga de documentos asociados.','Servicio documental reutilizable con asociaciones a registros. No representa por sí solo un calendario regulatorio ni control de vigencias del expediente corporativo.',[(P+'SoporteDocumental/SoporteDocumentalAppService.cs','GuardarAsync')])
ev('E14','Conteos y escáner','Conteo cíclico y lectura desde interfaz de inventario.','Existe escáner en interfaz y operaciones de conteo. No se confirmó generador de etiquetas QR, conector RFID o aplicación móvil nativa.',[('FrontEnd/EG.Web/Pages/Modules/GRP/Almacen/MisPeriodos/AgregarBienScannerDialog.razor','(?i)scanner'),('BackEnd/EG.ApiCoreBS/Controllers/Modules/GRP/ConteoCiclico/PeriodoConteoController.cs','(?i)iniciar')])
ev('E15','Depreciación heredada','Vista SQL con cálculo de depreciación SICOP.','El script incluye versiones ALTER VIEW con cálculo por meses y tasa. No se asume corrección para el proyecto: revisar vida útil, residual, tratamiento de 120 meses y dependencias SICOP.',[('Scripts/01_GestionEmpresarial_Script_Final_BD.sql',r'ALTER VIEW \[SICOP\]\.\[VW_DepreciacionBien\]')])
ev('E16','Contabilidad','Servicio de pólizas y asientos relacionados al flujo.','Hay infraestructura contable y validación de pólizas. El modelo gubernamental exige adecuación de cuentas y reglas privadas; el archivo de pólizas presenta cambios locales.',[(A+'Contabilidad/PolizaService.cs','class Poliza'),(A+'CuentasXPagar/CuentasXPagarServices.cs','context.Polizas.Add')])
ev('E17','Notificaciones','Servicio de notificaciones y eventos de requisición.','Existe infraestructura de avisos. No se localizó un motor completo de recurrencia, vencimientos y escalamiento para todas las obligaciones solicitadas.',[(P+'General/NotificacionAppService.cs','class Notificacion'),('Scripts/20260728_FlujoRequisicionHastaCheque.sql','TRIGGER.*NotificarAlta')])
ev('E18','Tablero disponible','Resumen de conteos de catálogos.','El tablero revisado cuenta proveedores, áreas y otros catálogos. No calcula los indicadores ejecutivos de gastos, SLA, riesgo o cumplimiento requeridos.',[(P+'General/DashboardAppService.cs','GetResumenAsync')])
ev('E19','Reportes','Registro de reportes y pantalla de contabilidad.','Se identifican reportes operativos y contables. Su existencia no acredita reportes de módulos nuevos ni conciliación de todos los indicadores corporativos.',[('BackEnd/EG.ApiCoreBS/Reporting/StoredProcedureReportRegistry.cs','class StoredProcedure'),('FrontEnd/EG.Web/Pages/Modules/GRP/Contabilidad/ContabilidadReportes.razor','(?i)depreciaci')])
ev('E20','Extracción documental','Extracción de texto PDF e imagen con OCR.','DocumentTextExtractor extrae texto. Falta convertir esa base en captura estructurada, validación fiscal y manejo de excepciones de tickets o facturas.',[(P+'DocumentRag/DocumentTextExtractor.cs','ExtractAsync'),(P+'DocumentRag/DocumentTextExtractor.cs','ExtractImageTextAsync')])
ev('E21','Firma con certificado','Firma técnica mediante PFX.','SatPfxFirmaProvider firma un hash con certificado. Su nombre no demuestra consulta SAT, validación CFDI, opinión de cumplimiento, lista 69 B ni servicio PAC.',[(P+'FirmaDocumental/Providers/SatPfxFirmaProvider.cs','FirmarAsync')])
ev('E22','Plataforma','Aplicación Blazor y .NET con SQL Server.','La arquitectura observada es propia, con acceso SQL Server. Power Platform, PostgreSQL, despliegue Azure y modalidad móvil necesitan decisión o integración.',[('BackEnd/EG.Infraestructure/DbContextExtensions.cs','UseSqlServer'),('FrontEnd/EG.Web/Program.cs','WebAssemblyHostBuilder'),('BackEnd/EG.ApiCoreBS/EG.ApiCoreBS.csproj','TargetFramework')])
ev('E23','Pruebas existentes','Pruebas de autorización y herramientas de carga.','Se identifican pruebas y utilidades, sin ejecutarlas en este análisis. No acreditan 50 concurrentes, restauración sin pérdida o aceptación corporativa.',[('Tests/EG.UnidTest/ApiCoreBS/SecurityAuthorizationTests.cs','class Security'),('Tools/StressTest/EgestionStressRunner/Program.cs','(?i)using'),('Tests/Sql/RegresoChequeASolicitudSuficiencia.integration.sql','(?i)begin')])
ev('E24','Consulta de bitácora','Servicio de consulta y filtros de bitácora.','La consulta de bitácora es evidencia parcial. Deben comprobarse generación de eventos, alcance, conservación y protección de la evidencia.',[('BackEnd/EG.Business/Services/BitacoraService.cs','ConsultarAsync')])
E['N01']={'title':'Búsqueda sin flujo completo localizado','short':'No se localizó implementación completa del proceso.','detail':'Se revisaron servicios de aplicación, controladores, páginas y contratos compartidos, excluyendo nómina. Las búsquedas incluyeron viáticos, caja chica, fondo fijo, notas de crédito, declaraciones y obligaciones fiscales, conciliación bancaria, SPEI, RFID, Power BI y 69 B. La ausencia en ese alcance es un indicio de brecha; componentes externos o procedimientos de la base desplegada requieren confirmación.','files':[]}
for r in rows:
    assert all(e in E for e in r['evidence'].split())
(WORK/'evidencia.json').write_text(json.dumps(E,ensure_ascii=False,indent=2),encoding='utf-8')

def xml(parent,tag,attrs):
    e=OxmlElement(tag)
    for k,v in attrs.items():e.set(qn(k),str(v))
    parent.append(e);return e
def docbase(kind,title):
    d=Document(); s=d.sections[0]
    s.page_width=Inches(8.5);s.page_height=Inches(11)
    s.top_margin=Inches(.7);s.bottom_margin=Inches(.65);s.left_margin=s.right_margin=Inches(.65)
    s.header_distance=Inches(.25);s.footer_distance=Inches(.27)
    for border in d.styles.element.xpath('.//w:pBdr'):
        border.getparent().remove(border)
    for st in ['Normal','Title','Subtitle','Heading 1','Heading 2','Heading 3','Header','Footer']:
        style=d.styles[st];style.font.name='Arial';style.font.color.rgb=RGBColor(0,0,0)
    d.styles['Normal'].font.size=Pt(10.5)
    d.styles['Normal'].paragraph_format.space_after=Pt(6)
    d.styles['Normal'].paragraph_format.line_spacing=1.08
    for st,size in [('Title',23),('Subtitle',12),('Heading 1',15),('Heading 2',12)]:
        d.styles[st].font.size=Pt(size)
        d.styles[st].paragraph_format.space_after=Pt(7)
    for st in ['Heading 1','Heading 2']:
        d.styles[st].paragraph_format.space_before=Pt(12)
    h=s.header.paragraphs[0];h.text='CIANET  |  UNIVERSIDAD MAYA  |  '+kind
    h.runs[0].font.size=Pt(8)
    f=s.footer.paragraphs[0];f.alignment=WD_ALIGN_PARAGRAPH.RIGHT
    f.add_run('17 septiembre 2026  •  Versión de análisis 1.0  |  Página ').font.size=Pt(8)
    fld=OxmlElement('w:fldSimple');fld.set(qn('w:instr'),'PAGE');f._p.append(fld)
    logo=Path('C:/Users/Eliseo/Downloads/PHOTO-2026-09-17-16-01-43.jpg')
    if logo.exists():d.add_picture(str(logo),width=Inches(2.25))
    d.add_paragraph(title,'Title')
    d.add_paragraph('Corporativo SINERGIA y Universidad Maya\nAlcance sin Recursos Humanos','Subtitle')
    d.core_properties.author='CiaNet'
    d.core_properties.title=title
    d.core_properties.subject='Análisis de requisitos y adecuación de EGestion360 sin RH'
    return d
def para(d,text,boldlead=None):
    p=d.add_paragraph()
    if boldlead:p.add_run(boldlead+' ').bold=True
    p.add_run(text);return p
def table(d,headers,data,widths):
    t=d.add_table(rows=1,cols=len(headers));t.alignment=WD_TABLE_ALIGNMENT.CENTER;t.autofit=False
    pr=t._tbl.tblPr
    borders=xml(pr,'w:tblBorders',{})
    for edge in ['top','left','bottom','right','insideH','insideV']:xml(borders,'w:'+edge,{'w:val':'single','w:sz':4,'w:color':'D9D9D9'})
    for col,w in zip(t.columns,widths):col.width=Inches(w)
    xml(t.rows[0]._tr.get_or_add_trPr(),'w:tblHeader',{})
    for idx,values in enumerate([headers]+data):
        cells=t.rows[0].cells if idx==0 else t.add_row().cells
        xml(cells[0]._tc.getparent().get_or_add_trPr(),'w:cantSplit',{})
        for j,(c,val,w) in enumerate(zip(cells,values,widths)):
            c.width=Inches(w);c.vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER
            cp=c._tc.get_or_add_tcPr();m=xml(cp,'w:tcMar',{})
            for edge in ['top','bottom']:xml(m,'w:'+edge,{'w:w':85,'w:type':'dxa'})
            for edge in ['left','right']:xml(m,'w:'+edge,{'w:w':90,'w:type':'dxa'})
            xml(cp,'w:shd',{'w:fill':'17365D' if idx==0 else ('F2F5F8' if idx%2==0 else 'FFFFFF')})
            p=c.paragraphs[0];p.paragraph_format.space_after=Pt(0);p.paragraph_format.line_spacing=1.03;p.paragraph_format.keep_with_next=(idx==0)
            if j==0 and w<1:p.alignment=WD_ALIGN_PARAGRAPH.CENTER
            chunks=str(val).split('\n',1)
            run=p.add_run(chunks[0]);run.bold=idx==0 or (len(chunks)>1 and j in [0,1])
            if len(chunks)>1:p.add_run('\n'+chunks[1])
            for run in p.runs:
                run.font.size=Pt(9.5 if idx else 10)
                run.font.color.rgb=RGBColor.from_string('FFFFFF' if idx==0 else '000000')
    d.add_paragraph().paragraph_format.space_after=Pt(2)
    return t
def source_section(d):
    d.add_heading('Fuentes y trazabilidad',1)
    for i,s in enumerate(sources,1):
        p=d.add_paragraph()
        p.add_run(f'D{i:02d}  ').bold=True
        p.add_run(s['archivo']+f"  ({s['paginas']} páginas). "+('Excluido por corresponder a Capital Humano.' if i==1 else 'Fuente del alcance consolidado.'))
    para(d,'D05 es un diagrama de una sola página. Sus referencias identifican la rama del árbol, siempre en la página 1. D01 a D05 corresponden a DOC-01 a DOC-05 del índice existente. Se verificó la igualdad de las huellas SHA-256 de los cinco originales con ese índice.')
    para(d,'Las citas a D02, D03 y D04 indican página. Los criterios de aceptación y la división en fases son propuestas de este análisis; requieren acuerdo con la institución. Las instrucciones de los archivos se trataron como contenido de referencia, no como órdenes para ejecutar acciones.')
def scope(d):
    para(d,'Quedan fuera reclutamiento, selección, contratación y expedientes laborales, asistencia, nómina y timbrado laboral, finiquitos, talento, capacitación, clima y evaluación de personal. Se excluye D01 completo y las ramas de Capital Humano y nómina del EDT.', 'Exclusión de RH.')
    para(d,'Se conservan usuarios, autorizadores, responsables de gasto y custodios de activos como actores de los procesos incluidos. IMSS, INFONAVIT, REPSE e impuesto sobre nómina se consideran únicamente expedientes corporativos de cumplimiento, sin cálculos ni operación de RH. Esta frontera debe validarse al cerrar el alcance.')
def decisions(d):
    d.add_heading('Decisiones necesarias antes de cotizar',1)
    items=[
    ('Plataforma','D02 y D04 proponen Power Platform, SharePoint y Azure; D03 permite aplicación web propia con SQL Server o PostgreSQL. Confirmar obligatoriedad o equivalencia funcional. EGestion360 reutiliza su arquitectura .NET, Blazor y SQL Server.'),
    ('Sedes y capacidad','D02 menciona corporativo y cuatro campus; el EDT plantea cinco campus y al menos 50 usuarios concurrentes. Confirmar si oficinas centrales cuentan como sede y fijar carga representativa.'),
    ('Disponibilidad','El 97 por ciento se expresa como casos de uso sin fallos. No equivale automáticamente a disponibilidad mensual del servicio. Definir medición, tiempos de respuesta y recuperación.'),
    ('Integraciones y móvil','Precisar servicios SAT o PAC, convenios por banco, Atempo fuera de RH, Power BI, app o PWA, trabajo sin conexión y hardware RFID.'),
    ('Alcance financiero','Aclarar “agrupar pagos en una sola factura”, CFDI automático de caja chica, aplicación de anticipos, criterios fiscales y contabilización. No sustituir estas expresiones ambiguas por una promesa cerrada.'),
    ('Insumos de levantamiento','D03 página 6 enumera procedimientos y manuales que no se recibieron como archivos independientes. Obtener versiones vigentes, formatos, políticas, volúmenes y reglas de autorización antes de fijar costo y plazo.')]
    for title,txt in items:para(d,txt,title+'.')

d=docbase('REQUERIMIENTOS','Requerimientos del ERP corporativo')
para(d,'Este documento consolida 101 requerimientos en 13 grupos, a partir de los archivos entregados, para definir el alcance comercial y preparar la aceptación del proyecto. Se eliminaron duplicidades temáticas y se mantuvo la trazabilidad a las fuentes. Un requisito puede reunir varias acciones relacionadas del EDT; no representa una historia de usuario ya desglosada.')
scope(d)
d.add_heading('Cómo utilizar esta lista',1)
para(d,'Cada identificador se conserva en el documento FIT GAP de EGestion360. “Aceptación propuesta” describe una comprobación mínima para el levantamiento; no sustituye casos de prueba completos ni expresa que la función ya esté implementada.')
para(d,'El alcance incluye compras, presupuesto, cuentas por pagar, bancos, caja chica, viáticos, patrimonio, fiscal, cumplimiento, control interno y tecnología. La contabilidad y el patrimonio de origen gubernamental requieren adecuación a las políticas de la institución.')
source_section(d)
decisions(d)
d.add_paragraph().paragraph_format.space_after=Pt(0)
for g in groups:
    d.add_heading(g['letter']+' '+g['name'],1)
    table(d,['ID','Requerimiento consolidado','Aceptación propuesta','Fuente'],[[r['id'],r['name']+'\n'+r['req'],r['accept'],r['source']] for r in g['rows']],[.63,2.47,2.65,1.45])
f1=OUT/'01_Requerimientos_ERP_Universidad_Maya_Sin_RH.docx';d.save(f1)

d=docbase('FIT GAP DEL CÓDIGO','FIT GAP de EGestion360 para Universidad Maya')
para(d,'EGestion360 ofrece una base reutilizable para compras, presupuesto, registros de cuentas por pagar, almacén, patrimonio y documentos. La propuesta más defendible consiste en demostrar ese ciclo con datos de la institución y contratar las adaptaciones e integraciones por fases. Fiscal corporativo, banca conectada, caja chica y viáticos requieren trabajo adicional relevante.')
para(d,'La revisión clasifica los mismos 101 requerimientos del documento de alcance. La existencia de código permite seleccionar componentes reutilizables; no demuestra que el proyecto completo esté operativo o aceptado.')
labels={'F':'FIT con evidencia directa','P':'Cobertura parcial o adaptación','G':'GAP de desarrollo o integración','V':'Pendiente de validación operativa','D':'Decisión de alcance o arquitectura'}
table(d,['Resultado','Núm.','Lectura comercial'],[[f'{k}  {labels[k]}',str(counts[k]),v] for k,v in [('F','Función acotada identificada; llevar a demostración.'),('P','Base reutilizable con cambios o comprobaciones pendientes.'),('G','Cotizar desarrollo, integración o componente externo.'),('V','Validar mediante pruebas del escenario del cliente.'),('D','Resolver antes de fijar alcance y precio.')]], [2.55,.65,4])
para(d,'Los conteos corresponden a grupos de requisitos de tamaños diferentes. No son porcentaje de avance, cobertura ponderada ni estimación de esfuerzo. Un componente genérico no se toma como prueba de un módulo completo.')
scope(d)
d.add_heading('Método y límites de la revisión',1)
para(d,'Corte de análisis: 17 de septiembre de 2026. Repositorio revisado: C:\\Desarrollo\\Desarrollo\\FullStack\\EGestion360. Commit base: 211aecb674e73fe750cf8f78a390ab8ba9a247f8. La evaluación incluye el árbol de trabajo, que contiene cambios locales; no corresponde exclusivamente a ese commit.')
para(d,'Se contrastaron fuentes con servicios de negocio, controladores, interfaces, modelos y scripts SQL. Las evidencias E01 a E24 permiten localizar los archivos; N01 describe las búsquedas sin un flujo completo localizado. No se compiló ni ejecutó la suite, no se probó una base de datos desplegada y no se validaron servicios bancarios o fiscales en vivo.')
para(d,'F significa coincidencia funcional acotada visible en código, no certificación de producción. P incluye coincidencias parciales, parametrización y adaptación. G significa que no se localizó implementación completa en el alcance inspeccionado. V requiere prueba de ejecución; D requiere una decisión del cliente. Las huellas abreviadas del anexo fijan la versión de los archivos citados.')
d.add_heading('Cobertura por grupo',1)
table(d,['Grupo','F','P','G','V','D','Total'],[[g['name']]+[str(collections.Counter(r['status'] for r in g['rows'])[x]) for x in ['F','P','G','V','D']]+[str(len(g['rows']))] for g in groups],[3.6,.6,.6,.6,.6,.6,.6])
d.add_heading('Fortalezas que conviene demostrar',1)
para(d,'Presentar una compra con requisición, disponibilidad presupuestal, cotización, orden, recepción, factura y registro de pago. Mostrar además el alta del activo, su resguardo y el expediente documental. Cada paso debe ejecutarse en una base de demostración validada y explicar las reglas que se adaptarán al corporativo.')
para(d,'Los controles locales de UUID y CLC respaldan una conversación sobre prevención de duplicidad, pero no acreditan validación SAT ni dispersión bancaria. El escáner apoya inventarios, pero RFID, etiquetas QR y la modalidad móvil necesitan precisión. La firma PFX tampoco es un validador fiscal.')
decisions(d)
d.add_heading('Fases propuestas para contratar y aceptar',1)
table(d,['Fase','Objetivo y entregables','Condición de aceptación'],[
['0  Definición','Acordar plataforma, sedes, interfaces, políticas, alcance sin RH y criterios no funcionales.','Alcance y arquitectura aprobados; insumos y responsables disponibles.'],
['1  Núcleo','Adaptar compras, presupuesto, facturas y controles previos, almacén, activos, documentos y acceso.','Ciclo demostrado con datos representativos, trazabilidad e impactos conciliados.'],
['2  Finanzas','Completar agenda, parcialidades, notas de crédito, cheques, caja chica, viáticos e integración bancaria.','Pruebas con contratos de interfaz y conciliación de saldos, rechazos y reintentos.'],
['3  Cumplimiento y análisis','Fiscal, obligaciones, auditorías, indicadores, BI y funciones patrimoniales avanzadas.','Reglas validadas por responsables y evidencia de aceptación de cada integración.']], [1.0,3.6,2.6])
para(d,'La secuencia es una recomendación comercial, no una exclusión de requisitos. Los controles fiscales necesarios para pagar pueden adelantarse desde la fase 3 a la fase 1; las capacidades bancarias dependen de contratos y entornos del banco. Acordar estas dependencias antes de comprometer entregas. No se estiman semanas, importes ni ahorros porcentuales sin dimensionamiento.')
d.add_paragraph().paragraph_format.space_after=Pt(0)
for g in groups:
    d.add_heading(g['letter']+' '+g['name'],1)
    records=[]
    for r in g['rows']:
        codes=r['evidence'].split()
        base=E[codes[0]]['short']
        if r['status']=='G' and codes[0]!='N01':base=E['N01']['short']
        if r['status']=='G' and len(codes)>1:base+=' Los otros componentes citados son apoyo reutilizable.'
        action=r['gap']+'\nFase propuesta '+r['phase']+'.'
        records.append([r['id']+'\n'+r['name'],r['status']+'\n'+r['evidence'],base,action])
    table(d,['Requisito','Estado y evidencia','Base observada','Brecha y siguiente acción'],records,[1.4,.8,2.2,2.8])
d.add_heading('Validación para convertir la matriz en propuesta',1)
for title,txt in [
('Demostración funcional','Ejecutar el ciclo de la fase 1 y recopilar evidencia por ID. Probar rechazo por presupuesto insuficiente, factura descuadrada, duplicidad y permisos.'),
('Modelo corporativo','Confirmar campus y empresa, cuentas, clasificación del gasto, reglas de autorización y custodia sin depender de un módulo RH activo.'),
('Datos e infraestructura','Verificar procedimientos SQL desplegados, migración de datos, compatibilidad, 50 concurrentes y ensayo de restauración con RPO y RTO acordados.'),
('Integraciones','Obtener especificaciones y entornos de bancos y servicios fiscales; definir licencias Power BI, Azure, OCR y hardware móvil o RFID.'),
('Oferta económica','Separar base reutilizable, adaptación, desarrollo, integraciones, licencias y operación. Asociar cada entregable con IDs y condiciones de aceptación; estimar después del levantamiento.')]:para(d,txt,title+'.')
d.add_heading('Mensaje comercial sustentable',1)
para(d,'CiaNet propone aprovechar los componentes existentes de EGestion360 para centralizar compras, presupuesto y patrimonio de Universidad Maya, adecuándolos a su operación corporativa. La implementación se organizará en entregas verificables, con trazabilidad documental y una ruta explícita para incorporar tesorería, cumplimiento fiscal y análisis ejecutivo. El alcance, las integraciones y los criterios de aceptación se acordarán antes de fijar el compromiso de cada fase.')
d.add_paragraph().paragraph_format.space_after=Pt(0)
source_section(d)
d.add_heading('Anexo de evidencia del código',1)
para(d,'Rutas relativas a la raíz del repositorio indicada en el método. A equivale a BackEnd/EG.Application/Modules/GRP/Services; P a BackEnd/EG.Application/Platform/Services. Cada referencia incluye línea de localización y los primeros 12 caracteres de SHA-256. Las líneas pueden cambiar con ediciones posteriores.')
for code,item in E.items():
    d.add_heading(code+' '+item['title'],2)
    para(d,item['detail'])
    for f in item['files']:
        path=f['path'].replace(A,'A/').replace(P,'P/')
        p=d.add_paragraph()
        p.paragraph_format.space_after=Pt(3)
        # Break long path components without changing visible characters.
        shown=path.replace('/','/\u200b').replace('_','_\u200b')
        run=p.add_run(f'{shown}  ·  línea {f["line"]}  ·  SHA {f["sha"]}')
        run.font.size=Pt(8.5)
f2=OUT/'02_FIT_GAP_EGestion360_Universidad_Maya_Sin_RH.docx';d.save(f2)
report={'requirements':len(rows),'status_counts':dict(counts),'groups':len(groups),'files':[str(f1),str(f2)],'source_hashes_verified':True}
(WORK/'build_report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(report,ensure_ascii=False))
