from pathlib import Path
import json, re, html, base64, math, hashlib, xml.etree.ElementTree as ET
from collections import defaultdict
from reportlab.pdfgen import canvas
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib.colors import HexColor
from reportlab.lib.utils import ImageReader
ROOT=Path.cwd();WORK=ROOT/'tmp/maya_fitgap';OUT=ROOT/'output/pdf/universidad-maya/Diagramas_Capas_EXUX';OUT.mkdir(parents=True,exist_ok=True)
M=json.loads((WORK/'sql_model.json').read_text(encoding='utf8'));T=M['tables'];R=M['relations'];MOD=M['modules'];NEW=set(M['new']);COPIED=set(M['copied'])
EP=json.loads((WORK/'sql_metadata/EmptyProjects.json').read_text(encoding='utf8'));GE=json.loads((WORK/'sql_metadata/GestionEmpresarial.json').read_text(encoding='utf8'))
SOURCES={**{t['schema']+'.'+t['name']:t for t in GE['tables']},**{t['schema']+'.'+t['name']:t for t in EP['tables']}}
LOGO=Path('C:/Users/Eliseo/Downloads/PHOTO-2026-09-17-18-05-35.jpg');LOGODATA='data:image/jpeg;base64,'+base64.b64encode(LOGO.read_bytes()).decode()
pdfmetrics.registerFont(TTFont('Arial','C:/Windows/Fonts/arial.ttf'));pdfmetrics.registerFont(TTFont('ArialBold','C:/Windows/Fonts/arialbd.ttf'))
PAL=dict(ink='#143044',muted='#5E7282',blue='#087CB4',pale='#EEF7FD',green='#287B62',lightgreen='#EFF8F3',amber='#9E6B16',lightamber='#FCF5E8',line='#A8BCCC',bg='#F5F8FB',white='#FFFFFF',purple='#78619F',lightpurple='#F5F1FA')
NAMES={1:'Base y organización',2:'Pólizas y contabilidad',3:'Presupuesto',4:'Almacén',5:'Patrimonio',6:'Compras y proveedores',7:'Cuentas por pagar',8:'Bancos y tesorería',9:'Caja chica',10:'Viáticos',11:'Cumplimiento',12:'Fiscal',13:'Workflow y notificaciones',14:'Documentos',15:'Control y auditoría'}
SLUG={1:'Base_Organizacion',2:'Polizas_Contabilidad',3:'Presupuesto',4:'Almacen',5:'Patrimonio',6:'Compras_Proveedores',7:'Cuentas_por_Pagar',8:'Bancos_Tesoreria',9:'Caja_Chica',10:'Viaticos',11:'Cumplimiento',12:'Fiscal',13:'Workflow_Notificaciones',14:'Documentos',15:'Control_Auditoria'}
CONFIG={
1:('Una base común para todas las empresas y campus.',['SIS.Corporativo','SIS.Empresa','SIS.Sucursal','SIS.Usuario','SIS.ResponsableOperativo','SIS.CentroCosto','SIS.OperacionNegocio'],'Se conserva la seguridad de EmptyProjects. El responsable operativo permite compras y custodia sin incorporar RH.'),
2:('Cada afectación contable conserva su empresa y origen.',['CONTA.CuentaContable','CONTA.Poliza','CONTA.PolizaDetalle','SIS.OperacionNegocio','SIS.TipoPoliza','PAG.PagoPoliza'],'La clave de póliza incluye empresa. Las pólizas autorizadas se corrigen por reversa; su detalle debe balancear.'),
3:('Planificar, autorizar y reservar antes de comprometer recursos.',['PRES.PresupuestoVersion','PRES.EgresoProyectado','PRES.EgresoAutorizado','PRES.ReservaPresupuestal','PRES.EgreAdecuacionDetalle','SIS.CentroCosto'],'La reserva no sustituye la conciliación de disponibilidad presupuestal. Los meses y la reserva conservan decimal(18,2).'),
4:('Separar el almacén físico del registro histórico de entradas.',['ALMA.AlmacenCatalogo','ALMA.ProductoAlmacen','ALMA.UbicacionAlmacen','ALMA.PartidaStock','ALMA.MovimientoInventarioDetalle','ALMA.ReservaStock'],'Existencia = movimientos aplicados. Disponible = existencia menos reservas activas. ALMA.Almacen conserva su significado histórico.'),
5:('Conocer dónde está cada bien, quién lo custodia y cómo cambia su valor.',['ALMA.Bien','ALMA.Resguardo','ALMA.ResguardoDetalle','PAT.HistorialUbicacionBien','PAT.IdentificadorBien','PAT.DepreciacionBienPeriodo'],'La ubicación puede ser patrimonial o de almacén. Los responsables operativos sustituyen dependencias de nómina.'),
6:('Vincular necesidad, orden, destino y recepción por partida.',['ORCO.Requisicion','ORCO.OrdenCompra','ORCO.OrdenCompraDetalle','ORCO.DestinoOrdenCompra','ORCO.Recepcion','ORCO.RecepcionDetalle'],'El destino distingue almacén y centro de costo. Una aceptación de servicio no debe generar inventario.'),
7:('Separar la deuda, su programación y los pagos parciales.',['PRES.Factura','PAG.CompromisoPago','PAG.ProgramacionPago','PAG.Pago','PAG.AplicacionPago','PAG.NotaCredito'],'Compromiso y pago son entidades distintas. Cada aplicación exige coherencia de empresa y moneda.'),
8:('Conservar trazabilidad desde la cuenta hasta la conciliación.',['TES.CuentaBancaria','TES.ConexionBancaria','TES.OperacionBancaria','TES.IntentoEnvioBancario','TES.MovimientoBancario','TES.ConciliacionDetalle'],'La integración bancaria es posterior. Las tablas conservan idempotencia, intentos y referencia segura a credenciales.'),
9:('Administrar fondo, vales, comprobación y reposiciones.',['CAJA.FondoCaja','CAJA.ValeCaja','CAJA.MovimientoFondo','CAJA.ComprobacionCaja','CAJA.ReposicionCaja','CAJA.ReposicionDetalle'],'Antes de operar debe controlarse la aplicación acumulada del comprobante, incluso entre caja y viáticos.'),
10:('Relacionar comisión, anticipo, comprobación y reintegro.',['SIS.ResponsableOperativo','VIA.SolicitudViatico','VIA.AnticipoViatico','VIA.ComprobacionViatico','VIA.ReintegroViatico','FIS.ComprobanteGasto'],'El expediente pertenece a la empresa y al responsable operativo. No incorpora cálculo ni procesos de RH.'),
11:('Asignar responsables y evidencias a cada vencimiento.',['CUM.CatalogoObligacion','CUM.ObligacionEmpresa','CUM.VencimientoObligacion','CUM.EvidenciaCumplimiento','SIS.ResponsableOperativo','SIS.Documento'],'El calendario institucional conecta obligación, vencimiento y evidencia. Las reglas concretas deben aprobarse antes de operar.'),
12:('Conectar CFDI, evidencia y versiones de la declaración.',['FIS.Cfdi','FIS.CfdiConcepto','FIS.CfdiImpuesto','FIS.DeclaracionVersion','FIS.DeclaracionCfdi','FIS.DeterminacionImpuesto'],'El esquema conserva datos y versiones; no sustituye SAT/PAC ni incorpora tasas o cálculos fiscales aprobados.'),
13:('Controlar decisiones, plazos y avisos por operación.',['SIS.OperacionNegocio','SIS.EnvioWorkflow','PBR.WorkflowTemplate','WF.ReglaAutorizacion','WF.DecisionAutorizacion','WF.EventoPendiente'],'Las decisiones conservan actor y regla. Las políticas de autorización requieren aplicación en los servicios de negocio.'),
14:('Una evidencia documental compartida por todos los procesos.',['SIS.OperacionNegocio','DOC.OperacionDocumento','SIS.Documento','DOC.ExtraccionDocumento','DOC.CampoExtraido','SIS.DocumentoEvento'],'El documento pertenece a una empresa. La extracción asistida conserva confianza y revisión humana.'),
15:('Vincular cambios, riesgos y conflictos de funciones.',['SIS.OperacionNegocio','PBR.AuditoriaCambio','CTL.ReglaRiesgo','CTL.CasoRiesgo','CTL.ReglaSegregacion','SIS.ResponsableOperativo'],'El modelo soporta evidencia y seguimiento. La prevención de fraude exige reglas, procesos y controles efectivos.')}

def type_of(c):
 b=c.get('base_type_name',c['type_name'])
 if b in ('nvarchar','nchar','varchar','char','varbinary','binary'):return b+'('+('max' if c['max_length']==-1 else str(c['max_length']//(2 if b in ['nvarchar','nchar'] else 1)))+')'
 if b in ('numeric','decimal'):return b+f"({c['precision']},{c['scale']})"
 if b in ('datetime2','time'):return b+f"({c['scale']})"
 return 'rowversion' if b=='timestamp' else b

def pks(n):return [c['name'] for i in T[n].get('indexes',[]) if i.get('is_primary_key') for c in i['columns']]
def kind(n):return 'new' if n in NEW else 'adapted' if n in COPIED or n=='SIS.Empresa' else 'base'
def fields(n):
 fks={c for r in R if r['child']==n for c in r['cols']};keys=pks(n);cs=T[n]['columns'];added=[c['name'] for c in cs if c['name'] not in {x['name'] for x in SOURCES.get(n,{}).get('columns',[])}]
 chosen=list(keys)
 for f in ['IdEmpresa','FKIdEmpresa_SIS','IdAlmacen','IdPartidaStock','IdProductoAlmacen','IdOperacion']+added+[c['name'] for c in cs if c['name'] in fks]+[c['name'] for c in cs]:
  if f in {c['name'] for c in cs} and f not in chosen and f not in ['CreadoUtc','VersionFila','FechaCreacion','UsuarioCreacion','UsuarioModificacion','PayrollID'] and '_NOM' not in f:chosen.append(f)
 return [('PK ' if x in keys else 'FK ' if x in fks else '')+x for x in chosen[:4]]

def node(id,title,x,y,w=310,h=134,lines=None,kind='neutral',action=None,tag=None):return dict(id=id,title=title,x=x,y=y,w=w,h=h,lines=lines or [],kind=kind,action=action,tag=tag)
def edge(a,b,label='',kind='flow'):return dict(a=a,b=b,label=label,kind=kind)
V=[]
def view(id,level,title,subtitle,nodes,edges,note,legend='Las flechas muestran el recorrido conceptual.',mod=None):
 assert len({n['id'] for n in nodes})==len(nodes)
 assert all(e['a'] in {n['id'] for n in nodes} and e['b'] in {n['id'] for n in nodes} for e in edges)
 v=dict(id=id,level=level,title=title,subtitle=subtitle,nodes=nodes,edges=edges,note=note,legend=legend,mod=mod);V.append(v);return v

view('contexto',0,'El ERP dentro de la institución','De la operación diaria a la información para decidir.',[
node('areas','Áreas y campus',30,45,310,124,['Solicitan bienes y servicios','Comprueban uso y entrega'],action='view:modulos'),
node('operadores','Operadores y responsables',30,260,310,124,['Compras, almacén y patrimonio','Tesorería, contabilidad y control'],action='view:modulos'),
node('erp','ERP institucional EXUX',510,215,330,204,['Procesos conectados','Trazabilidad por empresa','Evidencia y autorización','Sin RH en el nuevo alcance'],kind='hero',action='view:capas',tag='ARQUITECTURA OBJETIVO'),
node('dir','Dirección y auditoría',30,475,310,124,['Supervisan resultados','Revisan información y evidencia'],action='view:modulos'),
node('externos','Servicios externos',1020,80,300,144,['Bancos · SAT/PAC · OCR','Interfaces por definir'],kind='external',action='view:capas',tag='INTEGRACIÓN PENDIENTE'),
node('proveedor','Proveedores',1020,430,300,124,['Ofertas, facturas y entregas','Expediente y validación'],action='module:6')],
[edge('areas','erp','solicitudes'),edge('operadores','erp','operación'),edge('erp','dir','consulta'),edge('erp','externos','interfaces','external'),edge('proveedor','erp','documentos')],
'Este mapa describe el objetivo de la reestructura; no representa una solución ya desplegada.')

view('capas',1,'La solución organizada por capas','Cada capa cumple una responsabilidad y se apoya en las otras.',[
node('personas','1 · Personas y acceso',80,20,1180,94,['Áreas, responsables y auditores · Empresa, sucursal y permisos'],kind='base',action='module:1'),
node('experiencia','2 · Experiencia de usuario',80,150,1180,94,['Portales y pantallas para solicitar, operar, autorizar y consultar'],action='view:modulos'),
node('negocio','3 · Procesos y servicios de negocio',80,280,1180,94,['15 módulos · Reglas, validaciones y transacciones coordinadas'],kind='hero',action='view:modulos'),
node('datos','4 · Persistencia y evidencia',80,410,1180,94,['SQL Server · EmptyProjects + complemento de GestionEmpresarial + ERD EXUX'],kind='adapted',action='view:modulos'),
node('integracion','5 · Intercambio con otros sistemas',80,540,1180,94,['Contratos de banco, SAT/PAC y OCR por definir · No se implementaron conectores'],kind='external',action='view:despliegue')],
[edge('personas','experiencia'),edge('experiencia','negocio'),edge('negocio','datos'),edge('negocio','integracion','interfaces posteriores','external')],
'Las capas superiores son una propuesta de organización. Los scripts entregados concretan principalmente la capa de datos.',legend='Dependencia conceptual entre responsabilidades; no son claves foráneas.')

# The capability map uses grouping, not false FK paths across modules.
groups=[('Fundación',[1]),('Operación',[6,4,5]),('Finanzas',[3,2,7,8,9,10]),('Cumplimiento',[11,12]),('Servicios comunes',[13,14,15])]
mapnodes=[]
for row,(g,ids) in enumerate(groups):
 widths={1:1180,3:365,6:178,2:575}[len(ids)]
 for j,m in enumerate(ids):
  w=widths;x=80+j*(w+28)
  mapnodes.append(node('m'+str(m),NAMES[m],x,27+row*128,w,102,[f'Módulo {m:02}'],kind='hero' if m==4 else 'neutral',action='module:'+str(m),tag=g.upper() if j==0 else None))
view('modulos',2,'Mapa de módulos','Una plataforma común con responsabilidades separadas.',mapnodes,[],
'Cada módulo tiene archivos propios de estructura y relaciones. Las dependencias cruzadas impiden tratarlos como instalaciones totalmente aisladas.',legend='Agrupación funcional. Selecciona un módulo para ver sus entidades principales.')

# Module snapshots: exact FK relationships between the selected physical tables.
for mod,(sub,entities,note_) in CONFIG.items():
 nodes=[]
 slots=[(30,30),(510,30),(990,30),(30,265),(510,265),(990,265),(510,500)]
 for j,n in enumerate(entities):
  x,y=slots[j];nodes.append(node(n,n.split('.')[1],x,y,330,150,fields(n),kind(n),'table:'+n,tag=n.split('.')[0]))
 edges=[];pairs=defaultdict(list)
 for r in R:
  if r['child'] in entities and r['parent'] in entities:pairs[(r['child'],r['parent'])].append(r)
 for (a,b),rels in pairs.items():edges.append(edge(a,b,'FK'+(' ×'+str(len(rels)) if len(rels)>1 else ''),'fk'))
 # To keep an isolated entity honest, display it without invented connectivity.
 view('mod-'+str(mod),3,NAMES[mod],sub,nodes,edges,note_,legend='FK: la flecha va desde la tabla dependiente hacia la tabla referenciada. Vista parcial; el explorador contiene el catálogo completo.',mod=mod)

view('multi-org',3,'Una empresa, varios campus y almacenes','Ejemplo de organización: un mismo producto puede existir en varios puntos.',[
node('empresa','Empresa',510,10,330,104,['Contexto compartido y separado'],kind='base',action='table:SIS.Empresa'),
node('sa','Campus A',180,190,330,104,['Sucursal de la empresa'],kind='base',action='table:SIS.Sucursal'),
node('sb','Campus B',850,190,330,104,['Otra sucursal de la empresa'],kind='base',action='table:SIS.Sucursal'),
node('a','Almacén A1',0,420,280,124,['Stock por producto y ubicación','Catálogo físico nuevo'],kind='new',action='table:ALMA.AlmacenCatalogo'),
node('a2','Almacén A2',350,420,280,124,['Stock independiente','Mismo catálogo de productos'],kind='new',action='table:ALMA.ProductoAlmacen'),
node('b','Almacén B1',720,420,280,124,['Recepciones y salidas propias','Cierres y conteos por almacén'],kind='new',action='table:ALMA.PeriodoConteo'),
node('tr','Almacén en tránsito',1070,420,280,124,['Pendiente de recibir','Tipo TRANSITO'],kind='new',action='view:transferencia')],
[edge('empresa','sa','contiene'),edge('empresa','sb','contiene'),edge('sa','a'),edge('sa','a2'),edge('sb','b'),edge('sb','tr')],
'Los nombres A/B son ilustrativos. El almacén en tránsito también pertenece a una empresa y sucursal; no representa existencias disponibles en destino.',legend='Jerarquía organizativa ilustrativa; no son datos cargados en la base.')

entities=['ALMA.AlmacenCatalogo','ALMA.ProductoAlmacen','ALMA.UbicacionAlmacen','ALMA.Lote','ALMA.PartidaStock','ALMA.MovimientoInventarioDetalle','ALMA.ReservaStock']
nodes=[node(n,n.split('.')[1],x,y,330,150,fields(n),kind(n),'table:'+n,tag=n.split('.')[0]) for n,(x,y) in zip(entities,[(30,20),(510,20),(990,20),(30,255),(510,255),(990,255),(510,490)])]
pairs=defaultdict(list)
for r in R:
 if r['child'] in entities and r['parent'] in entities:pairs[(r['child'],r['parent'])].append(r)
view('multi-datos',4,'El núcleo de datos multi almacén','La partida de stock reúne almacén, producto, ubicación, lote y condición.',nodes,[edge(a,b,'FK'+(' ×'+str(len(rs)) if len(rs)>1 else ''),'fk') for (a,b),rs in pairs.items()],
'Las FK compuestas verifican coherencia de empresa, almacén y producto. La disponibilidad concurrente debe protegerse al reservar y aplicar movimientos.',legend='Relaciones reales del SQL propuesto. ALMA.Almacen es el registro legado, no el catálogo físico nuevo.')

view('transferencia',4,'Transferencia con recepción parcial','Ejemplo didáctico: 120 unidades en total, conservadas durante el traslado.',[
node('o0','Origen · 100',40,30,330,125,['INICIO','Disponible en almacén de origen'],kind='base'),node('t0','Tránsito · 0',515,30,330,125,['INICIO','Sin mercancía enviada'],kind='base'),node('d0','Destino · 20',990,30,330,125,['INICIO','Existencia previa en destino'],kind='base'),
node('o1','Origen · 60',40,275,330,125,['ENVÍO DE 40','Movimiento de salida: -40'],kind='new'),node('t1','Tránsito · 40',515,275,330,125,['ENVÍO DE 40','Movimiento de entrada: +40'],kind='hero'),node('d1','Destino · 20',990,275,330,125,['ENVÍO DE 40','Aún no recibe'],kind='base'),
node('o2','Origen · 60',40,520,330,125,['RECEPCIÓN DE 25','No cambia con la recepción'],kind='base'),node('t2','Tránsito · 15',515,520,330,125,['RECEPCIÓN DE 25','Salida: -25; faltan por recibir 15'],kind='hero'),node('d2','Destino · 45',990,520,330,125,['RECEPCIÓN DE 25','Movimiento de entrada: +25'],kind='new')],
[edge('o1','t1','40 enviadas'),edge('t2','d2','25 recibidas')],
'Cada envío y recepción genera movimientos compensados. Las 15 unidades en tránsito no se cuentan como recibidas en destino.',legend='Ejemplo operativo, no transacciones ejecutadas. Cada fila suma 120 unidades.')

view('despliegue',4,'Del diseño a una base preparada','Los scripts están generados; su aplicación requiere una decisión posterior.',[
node('base','EmptyProjects',10,170,285,175,['26 tablas de origen','Seguridad y organización','Base destino de referencia'],kind='base',action='module:1'),
node('complemento','Complemento seleccionado',360,170,300,175,['169 tablas de GestionEmpresarial','Sin módulo RH','Adaptaciones por reestructura'],kind='adapted',action='view:modulos'),
node('nuevo','Ampliación ERD EXUX',725,170,285,175,['90 tablas nuevas','Multi almacén y brechas','128 entidades trazadas'],kind='new',action='view:multi-datos'),
node('sql','Paquete modular',1080,170,270,175,['35 archivos SQL','A · Estructuras','B · Relaciones','C · Controles'],kind='hero',action='sql:00_Leer_Primero.sql'),
node('pendiente','Pendiente para operar',330,495,700,112,['Aplicación autorizada · Carga de catálogos y saldos · Adaptación de servicios · Pruebas'],kind='external')],
[edge('base','complemento','base'),edge('complemento','nuevo','ampliación'),edge('nuevo','sql','archivo'),edge('sql','pendiente','trabajo posterior','external')],
'Se revisaron sintaxis y modelo sin ejecutar los scripts. El diseño de tablas no acredita integración, carga de datos ni operación del sistema.',legend='Ruta de preparación propuesta. No se crearon ni alteraron objetos en las bases.')

# Build detail model, without RH. Keep every table used by the proposed graph or assigned to a module.
include={n for n in MOD if not n.startswith('NOM.')}|{r['parent'] for r in R}|{r['child'] for r in R}
detail={}
for n in sorted(include):
 keys=set(pks(n));fkcols={c for r in R if r['child']==n for c in r['cols']};original={c['name']:c for c in SOURCES.get(n,{}).get('columns',[])}
 cs=[]
 for c in T[n]['columns']:
  old=original.get(c['name']);change='Nueva' if old is None else ('Ajustada' if type_of(old)!=type_of(c) or old['is_nullable']!=c['is_nullable'] else 'Conservada')
  cs.append(dict(name=c['name'],type=type_of(c),nullable=c['is_nullable'],pk=c['name'] in keys,fk=c['name'] in fkcols,change=change))
 detail[n]=dict(name=n,mod=MOD.get(n,1),kind=kind(n),fields=cs,checks=[x['definition'] for x in T[n].get('checks',[])],unique=[[c['name'] for c in x['columns'] if not c.get('is_included_column')] for x in T[n].get('indexes',[]) if x['is_unique']],changes=[f'{field}: {why}' for name,field,why in M['changes'] if name==n])

# A deterministic orthogonal router: path candidates stay outside node interiors.
DW,DH=1380,690
def intersects(a,b,r):
 x,y,w,h=r
 if abs(a[0]-b[0])<.01:return x-5<a[0]<x+w+5 and max(min(a[1],b[1]),y-5)<min(max(a[1],b[1]),y+h+5)
 return y-5<a[1]<y+h+5 and max(min(a[0],b[0]),x-5)<min(max(a[0],b[0]),x+w+5)
def routing(v):
 by={n['id']:n for n in v['nodes']};used=[]
 for j,e in enumerate(v['edges']):
  a,b=by[e['a']],by[e['b']];ax,ay,aw,ah=a['x'],a['y'],a['w'],a['h'];bx,by_,bw,bh=b['x'],b['y'],b['w'],b['h']
  ap=[(ax+aw/2,ay),(ax+aw,ay+ah/2),(ax+aw/2,ay+ah),(ax,ay+ah/2)];bp=[(bx+bw/2,by_),(bx+bw,by_+bh/2),(bx+bw/2,by_+bh),(bx,by_+bh/2)]
  obstacles=[(n['x'],n['y'],n['w'],n['h']) for n in v['nodes']]
  candidates=[]
  for aa in ap:
   for bb in bp:
    candidates+=[[aa,(bb[0],aa[1]),bb],[aa,(aa[0],bb[1]),bb]]
    for x in [15,380,440,900,960,1365,(aa[0]+bb[0])/2]:candidates.append([aa,(x,aa[1]),(x,bb[1]),bb])
    for y in [12,195,230,450,475,668,(aa[1]+bb[1])/2]:candidates.append([aa,(aa[0],y),(bb[0],y),bb])
  best=None
  for pp in candidates:
   p=[pp[0]]
   for pt in pp[1:]:
    if pt!=p[-1]:p.append(pt)
   if len(p)<2:continue
   seg=list(zip(p,p[1:]));hits=0
   for k,(u,z) in enumerate(seg):
    for r in obstacles:
     # Ignore endpoint contact, but do not allow a route to enter its own node.
     if r==(ax,ay,aw,ah) and k==0:
      mid=((u[0]*.99+z[0]*.01),(u[1]*.99+z[1]*.01));hits+=100 if ax<mid[0]<ax+aw and ay<mid[1]<ay+ah else 0;continue
     if r==(bx,by_,bw,bh) and k==len(seg)-1:
      mid=((u[0]*.01+z[0]*.99),(u[1]*.01+z[1]*.99));hits+=100 if bx<mid[0]<bx+bw and by_<mid[1]<by_+bh else 0;continue
     hits+=int(intersects(u,z,r))
   length=sum(abs(u[0]-z[0])+abs(u[1]-z[1]) for u,z in seg)
   overlap=sum(1 for u,z in seg for p1,p2 in used if (u[0]==z[0]==p1[0]==p2[0] and max(min(u[1],z[1]),min(p1[1],p2[1]))<min(max(u[1],z[1]),max(p1[1],p2[1]))) or (u[1]==z[1]==p1[1]==p2[1] and max(min(u[0],z[0]),min(p1[0],p2[0]))<min(max(u[0],z[0]),max(p1[0],p2[0]))))
   score=hits*100000+length+len(p)*20+overlap*180
   if best is None or score<best[0]:best=(score,p)
  e['points']=best[1];used+=list(zip(best[1],best[1][1:]))
for v in V:
 routing(v)
 labels=[]
 for e in v['edges']:
  e['labelPoint']=None
  if not e['label']:continue
  width=pdfmetrics.stringWidth(e['label'],'Arial',12)+18
  for a,b in sorted(zip(e['points'],e['points'][1:]),key=lambda q:-(abs(q[1][0]-q[0][0])+abs(q[1][1]-q[0][1]))):
   for ratio in [.5,.35,.65,.2,.8]:
    x=a[0]+(b[0]-a[0])*ratio;y=a[1]+(b[1]-a[1])*ratio;box=(x-width/2,y-12,width,22)
    def overlapping(r,s):return max(r[0],s[0])<min(r[0]+r[2],s[0]+s[2]) and max(r[1],s[1])<min(r[1]+r[3],s[1]+s[3])
    if not any(overlapping(box,(n['x']-4,n['y']-4,n['w']+8,n['h']+8)) for n in v['nodes']) and not any(overlapping(box,r) for r in labels):
     e['labelPoint']=[x,y];labels.append(box);break
   if e['labelPoint']:break

# Text fitting uses actual font metrics; titles can wrap instead of shrinking into tiny labels.
def wrap(s,width,font='Arial',size=16):
 parts=[];line=''
 for word in str(s).split():
  if pdfmetrics.stringWidth((line+' '+word).strip(),font,size)>width and line:parts.append(line);line=word
  else:line=(line+' '+word).strip()
 if line:parts.append(line)
 return parts

def textlines(n):
 title=wrap(n['title'],n['w']-36,'ArialBold',19)
 if any(pdfmetrics.stringWidth(s,'ArialBold',19)>n['w']-36 for s in title):
  title=wrap(n['title'],n['w']-36,'ArialBold',16);ts=16
 else:ts=19
 # long physical identifiers stay intact at readable 14px minimum.
 if any(pdfmetrics.stringWidth(s,'ArialBold',ts)>n['w']-36 for s in title):
  title=[n['title']];ts=max(14,min(ts,(n['w']-36)/pdfmetrics.stringWidth(n['title'],'ArialBold',1)))
 lines=[];y=23 if not n.get('tag') else 42
 if n.get('tag'):lines.append((18,18,n['tag'],10,'ArialBold','tag'))
 for l in title:lines.append((18,y,l,ts,'ArialBold','title'));y+=ts+4
 y+=7
 for f in n['lines']:
  for l in wrap(f,n['w']-36,'Arial',14):
   lines.append((18,y,l,14,'Arial','body'));y+=20
 assert y-12<=n['h'],(n['id'],y,n['h'],lines)
 return lines
for v in V:
 for n in v['nodes']:textlines(n)

COLORS={'neutral':(PAL['white'],PAL['line'],PAL['ink']),'base':('#F0F4F8','#ABBDC9',PAL['ink']),'new':(PAL['lightgreen'],'#7FBAA5',PAL['ink']),'adapted':(PAL['lightamber'],'#D0AC69',PAL['ink']),'external':(PAL['lightpurple'],'#AA95C4',PAL['ink']),'hero':('#096D9B','#096D9B','#FFFFFF')}
def esc(s):return html.escape(str(s),quote=True)
def svg(v,interactive=True):
 out=[f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {DW} {DH}" role="img" aria-label="{esc(v["title"])}"><title>{esc(v["title"])}</title><defs><marker id="arrow-{v["id"]}" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto"><path d="M0,0 L8,4 L0,8 z" fill="#658A9F"/></marker></defs>']
 for e in v['edges']:
  d='M '+' L '.join(f'{x},{y}' for x,y in e['points']);dash=' stroke-dasharray="7 5"' if e['kind']=='external' else ''
  out.append(f'<path d="{d}" fill="none" stroke="#658A9F" stroke-width="1.6"{dash} marker-end="url(#arrow-{v["id"]})"/>')
  if e['label'] and e.get('labelPoint'):
   x,y=e['labelPoint']
   w=pdfmetrics.stringWidth(e['label'],'Arial',12)+14
   out.append(f'<rect x="{x-w/2}" y="{y-11}" width="{w}" height="19" rx="4" fill="#F5F8FB"/><text x="{x}" y="{y+3}" text-anchor="middle" fill="#456A80" font-family="Arial" font-size="12">{esc(e["label"])}</text>')
 for n in v['nodes']:
  fill,border,ink=COLORS[n['kind']];x=n['x'];y=n['y'];action=n.get('action')
  out.append(f'<g'+(f' class="node" role="button" tabindex="0" data-action="{esc(action)}" aria-label="Abrir {esc(n["title"])}"' if interactive and action else '')+'>')
  out.append(f'<rect x="{x}" y="{y}" width="{n["w"]}" height="{n["h"]}" rx="12" fill="{fill}" stroke="{border}" stroke-width="1.2"/>')
  for dx,dy,txt,size,font,part in textlines(n):
   color=ink if part=='title' or n['kind']=='hero' else '#4B6577'
   out.append(f'<text x="{x+dx}" y="{y+dy}" font-family="Arial" font-size="{size}" font-weight="{700 if font=="ArialBold" else 400}" fill="{color}">{esc(txt)}</text>')
  out.append('</g>')
 out.append('</svg>');return ''.join(out)
for v in V:v['svg']=svg(v)
DATA=dict(views=V,names=NAMES,slugs=SLUG,details=detail,relations=R,config={k:dict(subtitle=x[0],note=x[2]) for k,x in CONFIG.items()},stats=dict(modules=15,erd=128,new=90,inherited=169,relations=len(R)))
(WORK/'layers_data.json').write_text(json.dumps(DATA,ensure_ascii=False),encoding='utf8')
# Preserve high resolution vector masters for later edits/exports.
for v in V:(OUT/(v['id']+'.svg')).write_text(svg(v,False),encoding='utf8')
print('Views',len(V),'tables in explorer',len(detail),'all geometry fitted')
# Standalone navigable explorer; all data and artwork remain local.
template=(WORK/'layers_template.html').read_text(encoding='utf-8-sig')
json_data=json.dumps(DATA,ensure_ascii=False,separators=(',',':')).replace('</','<\\/')
(OUT/'Arquitectura_EXUX.html').write_text(template.replace('__LOGO__',LOGODATA).replace('__DATA__',json_data),encoding='utf8')
# Print companion, A3 landscape, vector diagrams with chapter links.
PW,PH=1190.551,841.89
PDF=OUT/'04_Diagramas_Capas_EXUX.pdf';c=canvas.Canvas(str(PDF),pagesize=(PW,PH));c.setTitle('EXUX - Arquitectura por capas - Universidad Maya');c.setAuthor('EXUX');c.setSubject('Contexto, capas, módulos, entidades y detalle multi almacén. Diseño propuesto sin aplicar.')
def color(h):return HexColor(h)
def txt(x,y,text,size=12,font='Arial',fill=None):c.setFillColor(color(fill or PAL['ink']));c.setFont(font,size);c.drawString(x,y,str(text))
def para(x,y,text,width,size=12,font='Arial',fill=None,leading=None):
 for line in wrap(text,width,font,size):txt(x,y,line,size,font,fill);y-=leading or size*1.45
 return y

def chrome(page,level):
 c.setFillColor(color('#FFFFFF'));c.rect(0,0,PW,PH,stroke=0,fill=1)
 txt(38,PH-30,'UNIVERSIDAD MAYA  /  ARQUITECTURA OBJETIVO',9,'ArialBold',PAL['muted'])
 c.drawImage(str(LOGO),PW-178,PH-58,140,39,mask='auto')
 c.setStrokeColor(color('#DDE7EE'));c.line(38,PH-66,PW-38,PH-66)
 for j,(label,dest) in enumerate([('Contexto','contexto'),('Capas','capas'),('Módulos','modulos'),('Multi almacén','multi-org')]):
  x=38+j*93;txt(x,22,label,8,'Arial',PAL['blue']);c.linkRect('',dest,(x,17,x+86,34),relative=0,thickness=0)
 txt(475,22,'EXUX  |  PROPUESTA SIN APLICAR  |  SIN RH',8,'Arial',PAL['muted'])
 txt(PW-115,22,f'{page:02} / {len(V)+1:02}',9,'ArialBold',PAL['muted'])

# Cover and reading route.
chrome(1,0);c.bookmarkPage('inicio');c.addOutlineEntry('Inicio: guía de lectura','inicio',0)
txt(55,PH-126,'ARQUITECTURA',42,'ArialBold');txt(55,PH-178,'POR CAPAS',42,'ArialBold',PAL['blue'])
para(57,PH-221,'Del panorama institucional al detalle de las tablas.',960,20,fill=PAL['muted'])
txt(58,PH-278,'EmptyProjects + GestionEmpresarial + ampliación ERD EXUX',16,'ArialBold')
levels_cover=[('0','Contexto institucional','Quién participa y qué intercambia con el ERP.','contexto'),('1','Capas de la solución','Acceso, experiencia, negocio, datos e integración.','capas'),('2','Módulos','15 responsabilidades, desde almacén hasta auditoría.','modulos'),('3','Entidades','Las tablas principales y las relaciones por módulo.','mod-4'),('4','Detalle de datos','Multi almacén, transferencias y exploración de campos.','multi-datos')]
for j,(num,title,desc,dest) in enumerate(levels_cover):
 y=490-j*76;c.setFillColor(color('#EAF4FA'));c.roundRect(56,y-24,45,45,10,stroke=0,fill=1);txt(70,y-7,num,21,'ArialBold',PAL['blue']);txt(123,y+1,title,18,'ArialBold');txt(123,y-22,desc,13,fill=PAL['muted']);c.linkRect('',dest,(54,y-32,1070,y+25),relative=0,thickness=0)
para(60,69,'Lectura rápida en PDF. El explorador HTML permite abrir cada módulo, consultar sus tablas y recorrer las relaciones completas.',1030,11,fill=PAL['muted'])
c.showPage()

def draw_graph(v):
 scale=(PW-76)/DW;ox=38;top=PH-163
 def pt(p):return ox+p[0]*scale,top-p[1]*scale
 for e in v['edges']:
  c.setStrokeColor(color('#658A9F'));c.setLineWidth(1.3)
  c.setDash(5,4) if e['kind']=='external' else c.setDash()
  p=c.beginPath();xx,yy=pt(e['points'][0]);p.moveTo(xx,yy)
  for xy in e['points'][1:]:p.lineTo(*pt(xy))
  c.drawPath(p)
  c.setDash();a,b=e['points'][-2:];xx,yy=pt(b);dx=b[0]-a[0];dy=-(b[1]-a[1]);length=math.hypot(dx,dy);ux,uy=dx/length,dy/length
  p=c.beginPath();p.moveTo(xx,yy);p.lineTo(xx-ux*7-uy*3,yy-uy*7+ux*3);p.lineTo(xx-ux*7+uy*3,yy-uy*7-ux*3);p.close();c.setFillColor(color('#658A9F'));c.drawPath(p,stroke=0,fill=1)
  if e['label'] and e.get('labelPoint'):
   x,y=pt(e['labelPoint']);w=pdfmetrics.stringWidth(e['label'],'Arial',9)+10;c.setFillColor(color('#FFFFFF'));c.roundRect(x-w/2,y-7,w,16,3,stroke=0,fill=1);txt(x-w/2+5,y-3,e['label'],9,fill='#456A80')
 for n in v['nodes']:
  fill,border,ink=COLORS[n['kind']];x,y=pt((n['x'],n['y']));w,h=n['w']*scale,n['h']*scale
  c.setFillColor(color(fill));c.setStrokeColor(color(border));c.setLineWidth(.9);c.roundRect(x,y-h,w,h,9,stroke=1,fill=1)
  for dx,dy,t,size,font,part in textlines(n):txt(x+dx*scale,y-dy*scale,t,size*scale,font,ink if part=='title' or n['kind']=='hero' else '#4B6577')
  action=n.get('action');dest=None
  if action and action.startswith('view:'):dest=action[5:]
  if action and action.startswith('module:'):dest='mod-'+action[7:]
  if dest and dest in {vv['id'] for vv in V}:c.linkRect('',dest,(x,y-h,x+w,y),relative=0,thickness=0)

for j,v in enumerate(V,2):
 chrome(j,v['level']);c.bookmarkPage(v['id']);c.addOutlineEntry(f"N{v['level']} · {v['title']}",v['id'],0)
 txt(38,PH-91,'NIVEL '+str(v['level']),9,'ArialBold',PAL['blue']);txt(38,PH-122,v['title'],27,'ArialBold')
 txt(38,PH-145,v['subtitle'],12,'Arial',PAL['muted'])
 draw_graph(v)
 # Persistent physical-model legend is text plus color, not color alone.
 if v['mod'] or v['id']=='multi-datos':
  for k,(label,colr) in enumerate([('Base compartida','#91A7B8'),('Reutilizada / adaptada','#CBA25B'),('Nueva en el ERD','#49947B')]):
   xx=42+k*190;c.setFillColor(color(colr));c.roundRect(xx,110,7,7,2,stroke=0,fill=1);txt(xx+13,109,label,9,fill=PAL['muted'])
 para(42,90,v['legend'],PW-84,9,fill=PAL['muted'],leading=12)
 para(42,60,v['note'],PW-84,11,fill=PAL['ink'],leading=14)
 c.showPage()
c.save()
# diagrams.net file: each layer is a separate editable page with native shapes and connectors.
mx=ET.Element('mxfile',host='app.diagrams.net',agent='EXUX',version='24.7.17')
for v in V:
 diagram=ET.SubElement(mx,'diagram',id=v['id'],name=f"N{v['level']} - {v['title']}")
 model=ET.SubElement(diagram,'mxGraphModel',dx='1440',dy='1000',grid='1',gridSize='10',page='1',pageScale='1',pageWidth='1440',pageHeight='1000',math='0',shadow='0');root=ET.SubElement(model,'root');ET.SubElement(root,'mxCell',id='0');ET.SubElement(root,'mxCell',id='1',parent='0')
 def cell(id,value,style,x,y,w,h):
  cc=ET.SubElement(root,'mxCell',id=id,value=value,style=style,vertex='1',parent='1');ET.SubElement(cc,'mxGeometry',x=str(x),y=str(y),width=str(w),height=str(h),**{'as':'geometry'});return cc
 cell('header','EXUX | UNIVERSIDAD MAYA | PROPUESTA SIN APLICAR','text;html=0;align=left;fontSize=12;fontColor=#587286;',25,15,1300,30)
 cell('title',v['title'],'text;html=0;align=left;fontSize=26;fontStyle=1;fontColor=#143044;',25,50,1340,50)
 for i,n in enumerate(v['nodes']):
  fill,border,ink=COLORS[n['kind']];value='<b>'+esc(n['title'])+'</b><br><font style="font-size:12px">'+'<br>'.join(esc(s) for s in n['lines'])+'</font>'
  cell('n'+str(i),value,f'rounded=1;whiteSpace=wrap;html=1;align=left;verticalAlign=top;spacing=16;fontSize=17;fontFamily=Arial;fillColor={fill};strokeColor={border};fontColor={ink};',n['x']+25,n['y']+120,n['w'],n['h'])
 by={n['id']:(i,n) for i,n in enumerate(v['nodes'])}
 for i,e in enumerate(v['edges']):
  ai,a=by[e['a']];bi,b=by[e['b']];start=e['points'][0];end=e['points'][-1]
  style=f"edgeStyle=orthogonalEdgeStyle;rounded=0;html=1;endArrow=block;endFill=1;strokeColor=#658A9F;fontColor=#456A80;fontSize=12;exitX={(start[0]-a['x'])/a['w']};exitY={(start[1]-a['y'])/a['h']};entryX={(end[0]-b['x'])/b['w']};entryY={(end[1]-b['y'])/b['h']};exitPerimeter=0;entryPerimeter=0;"+('dashed=1;' if e['kind']=='external' else '')
  cc=ET.SubElement(root,'mxCell',id='e'+str(i),value=e['label'],style=style,edge='1',parent='1',source='n'+str(ai),target='n'+str(bi));geo=ET.SubElement(cc,'mxGeometry',relative='1',**{'as':'geometry'});arr=ET.SubElement(geo,'Array',**{'as':'points'})
  for x,y in e['points'][1:-1]:ET.SubElement(arr,'mxPoint',x=str(x+25),y=str(y+120))
 cell('legend',v['legend'],'text;html=0;whiteSpace=wrap;align=left;fontSize=12;fontColor=#5E7282;',25,840,1330,35)
 cell('note',v['note'],'text;html=0;whiteSpace=wrap;align=left;fontSize=15;fontColor=#143044;',25,885,1330,65)
ET.ElementTree(mx).write(OUT/'Arquitectura_EXUX.drawio',encoding='utf-8',xml_declaration=True)
print('PDF',PDF.name,'pages',len(V)+1,'HTML bytes',(OUT/'Arquitectura_EXUX.html').stat().st_size)
