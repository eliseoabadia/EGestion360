from pathlib import Path
import json,copy,re,hashlib
ROOT=Path.cwd(); WORK=ROOT/'tmp/maya_fitgap'; OUT=ROOT/'output/sql/universidad_maya/EXUX_ERP_Modular'
OUT.mkdir(parents=True,exist_ok=True)
EP=json.loads((WORK/'sql_metadata/EmptyProjects.json').read_text())
GE=json.loads((WORK/'sql_metadata/GestionEmpresarial.json').read_text())
BASE={t['schema']+'.'+t['name']:copy.deepcopy(t) for t in EP['tables']}
SRC={t['schema']+'.'+t['name']:t for t in GE['tables']}
T=copy.deepcopy(BASE); MOD={}; CHANGES=[]; ADDED={}; NEW=set(); COPIED=set(); CUSTOM={}; REL=[]
MODULES={1:'Base_Organizacion',2:'Polizas_Contabilidad',3:'Presupuesto',4:'Almacen',5:'Patrimonio',6:'Compras_Proveedores',7:'Cuentas_por_Pagar',8:'Bancos_Tesoreria',9:'Caja_Chica',10:'Viaticos',11:'Cumplimiento',12:'Fiscal',13:'Workflow_Notificaciones',14:'Documentos',15:'Control_Auditoria'}
def q(n):return '['+n.replace(']',']]')+']'
def fq(n):return '.'.join(q(x) for x in n.split('.'))
def lit(s):return "N'"+str(s).replace("'","''")+"'"
def pk(n):
 keys=[x for x in T[n].get('indexes',[]) if x.get('is_primary_key')]
 assert len(keys)==1,(n,keys)
 cols=[c['name'] for c in keys[0]['columns'] if not c.get('is_included_column')]
 assert len(cols)==1,(n,cols)
 return cols[0]
def col(n,k):return next(c for c in T[n]['columns'] if c['name'].lower()==k.lower())
def sc(n):return next((c['name'] for c in T[n]['columns'] if c['name'].lower() in ['idempresa','fkidempresa_sis','fkidempresasis']),None)
def typ(c):
 b=c.get('base_type_name',c['type_name'])
 if b in ('nvarchar','nchar'):return b+'('+('max' if c['max_length']==-1 else str(c['max_length']//2))+')'
 if b in ('varchar','char','binary','varbinary'):return b+'('+('max' if c['max_length']==-1 else str(c['max_length']))+')'
 if b in ('decimal','numeric'):return b+f"({c['precision']},{c['scale']})"
 if b in ('datetime2','time','datetimeoffset'):return b+f"({c['scale']})"
 return 'rowversion' if b=='timestamp' else b

def cmeta(name,ty,nullable=False,default=None,identity=False):
 m=re.fullmatch(r'(\w+)(?:\((max|\d+)(?:,(\d+))?\))?',ty);assert m,(name,ty)
 b,a,s=m.groups();b=b.lower();prec=0;scale=0
 if b in ['nvarchar','nchar','varchar','char','binary','varbinary']:length=-1 if a=='max' else int(a)*(2 if b.startswith('n') else 1)
 elif b in ['decimal','numeric']:prec=int(a);scale=int(s);length=5 if prec<=9 else 9 if prec<=19 else 13 if prec<=28 else 17
 elif b=='int':length=4;prec=10
 elif b=='bigint':length=8;prec=19
 elif b=='smallint':length=2;prec=5
 elif b=='tinyint':length=1;prec=3
 elif b=='bit':length=1;prec=1
 elif b=='date':length=3;prec=10
 elif b=='datetime2':scale=int(a or 7);prec=20+scale;length=6 if scale<=2 else 7 if scale<=4 else 8
 elif b=='time':scale=int(a or 7);prec=8+scale;length=3 if scale<=2 else 4 if scale<=4 else 5
 elif b=='uniqueidentifier':length=16
 elif b=='rowversion':b='timestamp';length=8
 elif b=='float':length=8;prec=53
 else:raise ValueError(ty)
 return dict(name=name,type_name=b,base_type_name=b,max_length=length,precision=prec,scale=scale,is_nullable=nullable,is_identity=identity,is_computed=False,**({'default_definition':default} if default else {}),**({'identity_seed':'1','identity_increment':'1'} if identity else {}))

def index(n,cols,unique=True,where=None,name=None,primary=False):
 name=name or ('UX_' if unique else 'IX_')+n.replace('.','_')+'_'+'_'.join(cols)
 if len(name)>125:name=name[:108]+'_'+hashlib.sha1(name.encode()).hexdigest()[:12]
 i=dict(name=name,is_unique=unique,is_primary_key=primary,is_unique_constraint=False,type_desc='CLUSTERED' if primary else 'NONCLUSTERED',columns=[dict(name=c,key_ordinal=j+1,is_descending_key=False,is_included_column=False) for j,c in enumerate(cols)])
 if where:i['filter_definition']=where
 T[n].setdefault('indexes',[]).append(i);return i

def check(n,expr,label):T[n].setdefault('checks',[]).append({'name':'CK_EXUX_'+n.replace('.','_')+'_'+label,'definition':expr})
def add(n,name,ty,nullable=True,default=None,ref=None):
 assert not any(c['name'].lower()==name.lower() for c in T[n]['columns']),(n,name)
 c=cmeta(name,ty,nullable,default);T[n]['columns'].append(c)
 if n in BASE:ADDED.setdefault(n,[]).append(name)
 if ref:REL.append((n,[name],ref,[pk(ref)],True))
 return c

def new(mod,n,spec,unique=(),checks=(),scoped=True):
 assert n not in T,n
 schema,name=n.split('.');T[n]=dict(schema=schema,name=name,columns=[],indexes=[],foreign_keys=[],checks=[],origin='ERD EXUX')
 MOD[n]=mod;NEW.add(n)
 key='Id'+name;T[n]['columns'].append(cmeta(key,'bigint',False,identity=True));index(n,[key],primary=True)
 if scoped:add(n,'IdEmpresa','int',False,ref='SIS.Empresa')
 for line in spec.split('|'):
  if not line.strip():continue
  left,*df=line.strip().split('=',1);field,ty=left.split(':',1);nullable=ty.endswith('?');ty=ty.rstrip('?')
  if ty.startswith('@'):
   ref=ty[1:];assert ref in T,(n,ref);ct=typ(col(ref,pk(ref)));add(n,field,ct,nullable,df[0] if df else None,ref)
  else:add(n,field,ty,nullable,df[0] if df else None)
 add(n,'CreadoUtc','datetime2(7)',False,'SYSUTCDATETIME()');add(n,'VersionFila','rowversion',False)
 for u in unique:index(n,u)
 for j,e in enumerate(checks):check(n,e,str(j+1))
 return n

pat=set('Bajas Bien Inventario InventarioDetalle Resguardo ResguardoDetalle ResguardoMovimiento EstadoBien EstatusBaja EstatusInventario TipoAdquisicion TipoBaja TipoPatrimonio Marca Material CalendarioInventario'.split())
pay=set('Factura FacturaDetalle CLCFactura'.split());treasury=set('Cheque ChequePartidas RegresoChequeSuficiencia RegresoChequeSuficienciaPoliza'.split())
contract=set('Contrato ContratoDetalle'.split())
def module(n):
 s,x=n.split('.')
 if s=='ALMA':return 5 if x in pat else 4
 if s=='CONTA':return 2
 if s=='ORCO':return 6
 if s=='PRES':return 7 if x in pay else 8 if x in treasury else 6 if x in contract else 3
 if s=='TES':return 8
 if s=='PBR':return 15 if x=='AuditoriaCambio' else 13
 if x.startswith('Documento'):return 14
 if x.startswith('Notificacion') or x=='EnvioWorkflow':return 13
 if x in ['Proveedor','EstatusProveedor','TipoProveedor','NormaJuridica','NormaJuridicaVersion','Municipios']:return 6
 return 1
selected={n for n in SRC if n.split('.')[0] in ['ALMA','CONTA','ORCO','PRES']}
selected|={'TES.'+x for x in ['Banco','CuentaBancaria','TipoMoneda','TipoCambio']}
selected|={'SIS.'+x for x in ['Documento','DocumentoAnotacion','DocumentoEvento','DocumentoExtensionPermitida','DocumentoTipoAnotacion','EnvioWorkflow','Notificacion','NotificacionDestino','NotificacionEstado','NotificacionRegla','NotificacionTipo','Proveedor','Anio','TipoPoliza','TipoDetallePoliza','AccionAutorizar']}
selected|={'PBR.'+x for x in ['WorkflowTemplate','WorkflowEstado','WorkflowTransicion','AuditoriaCambio']}
while True:
 prev=set(selected)
 for n in list(selected):
  for fk in SRC[n].get('foreign_keys',[]):
   target=fk['referenced_schema']+'.'+fk['referenced_table']
   if target not in BASE and fk['referenced_schema']!='NOM':selected.add(target)
 if prev==selected:break
for n in sorted(selected):
 if n in BASE:continue
 assert n in SRC,n
 T[n]=copy.deepcopy(SRC[n]);T[n]['origin']='GestionEmpresarial.'+n;MOD[n]=module(n);COPIED.add(n)
 # Alias dbo.dmoney becomes decimal(20,4), without creating source alias types.
 for c in T[n]['columns']:
  if c['type_name']!=c['base_type_name']:CHANGES.append((n,c['name'],'Alias '+c['type_name']+' -> '+typ(c)))
 # All employee dependencies become operational responsibility, never payroll.
 rename={c['name']:c['name'].replace('_NOM','_Responsable') for c in T[n]['columns'] if c['name'].endswith('_NOM')}
 for old,replacement in rename.items():
  c=col(n,old);c['name']=replacement;c.update(type_name='bigint',base_type_name='bigint',max_length=8,precision=19,scale=0)
  CHANGES.append((n,old,'Sustituido por '+replacement+' -> SIS.ResponsableOperativo'))
 for fk in T[n].get('foreign_keys',[]):
  for c in fk['columns']:c['column']=rename.get(c['column'],c['column'])
  if fk['referenced_schema']=='NOM':
   assert fk['referenced_table']=='Persona',(n,fk)
   fk['referenced_schema']='SIS';fk['referenced_table']='ResponsableOperativo'
   for c in fk['columns']:c['referenced_column']='IdResponsableOperativo'
 for i in T[n].get('indexes',[]):
  for c in i['columns']:c['name']=rename.get(c['name'],c['name'])
 for ck in T[n].get('checks',[]):
  for old,replacement in rename.items():ck['definition']=ck['definition'].replace('['+old+']','['+replacement+']')
 CUSTOM[n]=[]
# New shared entities.
new(1,'SIS.Corporativo','Codigo:nvarchar(30)|Nombre:nvarchar(200)|Activo:bit=1',unique=[['Codigo']],scoped=False)
new(1,'SIS.ResponsableOperativo','IdUsuario:@SIS.Usuario?|Codigo:nvarchar(30)|Nombre:nvarchar(200)|Correo:nvarchar(254)?|Telefono:nvarchar(40)?|Activo:bit=1',unique=[['IdEmpresa','Codigo']])
index('SIS.ResponsableOperativo',['IdUsuario'],where='[IdUsuario] IS NOT NULL')
new(1,'SIS.CentroCosto','IdSucursal:@SIS.Sucursal|Codigo:nvarchar(30)|Nombre:nvarchar(200)|VigenciaDesde:date|VigenciaHasta:date?|Activo:bit=1',unique=[['IdEmpresa','Codigo']],checks=['VigenciaHasta IS NULL OR VigenciaHasta >= VigenciaDesde'])
new(1,'SIS.OperacionNegocio','Proceso:varchar(40)|Folio:nvarchar(60)|Fecha:datetime2(7)|ClaveOperacion:uniqueidentifier|Estado:varchar(20)',unique=[['IdEmpresa','ClaveOperacion'],['IdEmpresa','Proceso','Folio']])
for n,mod in [('SIS.Empresa',1),('SIS.Usuario',1),('SIS.Sucursal',1)]:MOD[n]=mod
add('SIS.Empresa','IdCorporativo','bigint',True,ref='SIS.Corporativo')
# BASE already contains NOM.Persona/PersonaArea: preserve those legacy objects, do not extend or load them.
add('SIS.Usuario','IdResponsableOperativo','bigint',True,ref='SIS.ResponsableOperativo')
# Avoid two competing user mappings: ResponsableOperativo.IdUsuario is canonical; legacy Usuario field is not needed.
T['SIS.Usuario']['columns'].pop();ADDED['SIS.Usuario'].pop();REL=[r for r in REL if not (r[0]=='SIS.Usuario' and r[1]==['IdResponsableOperativo'])]
# New copied transaction tables can require company immediately because no rows are migrated.
transaction_names='CONTA.Poliza ALMA.Conteo ALMA.ConteoDetalle ALMA.ConteoDetalleEscaneo ALMA.PlanConteoCiclico ALMA.PeriodoConteo ALMA.ResguardoDetalle ALMA.ResguardoMovimiento ALMA.InventarioDetalle ORCO.OrdenCompraDetalle ORCO.CotizacionDetalle PBR.WorkflowTemplate PBR.WorkflowEstado PBR.WorkflowTransicion PBR.AuditoriaCambio SIS.EnvioWorkflow SIS.Notificacion SIS.NotificacionRegla'.split()
for n in transaction_names:
 if not sc(n):add(n,'IdEmpresa','int',False,ref='SIS.Empresa');CHANGES.append((n,'IdEmpresa','Nueva pertenencia obligatoria a empresa'))
for n in ['ALMA.Conteo','ALMA.ConteoDetalle']:
 for c in T[n]['columns']:
  if c['name'] in ['CantidadInventario','Cantidad']:
   c.update(type_name='decimal',base_type_name='decimal',precision=20,scale=4,max_length=13);CHANGES.append((n,c['name'],'decimal(20,4), alineado a ALMA.Almacen'))
# Complete the non-FK legacy personnel slots as operational references.
for n in COPIED:
 for c in T[n]['columns']:
  if c['name'].endswith('_Responsable') and not any(any(fc['column']==c['name'] for fc in fk['columns']) for fk in T[n].get('foreign_keys',[])):
   REL.append((n,[c['name']],'SIS.ResponsableOperativo',['IdResponsableOperativo'],True))
# 04 ALMACEN: physical warehouse is independent from the legacy ALMA.Almacen entry.
new(4,'ALMA.AlmacenCatalogo','IdSucursal:@SIS.Sucursal|Codigo:nvarchar(30)|Nombre:nvarchar(150)|Tipo:varchar(12)|Activo:bit=1',unique=[['IdEmpresa','Codigo']],checks=["Tipo IN ('FISICO','TRANSITO')"])
new(4,'ALMA.UsuarioAlmacen','IdUsuario:@SIS.Usuario|IdAlmacen:@ALMA.AlmacenCatalogo|PuedeConsultar:bit=1|PuedeOperar:bit=0|PuedeAutorizar:bit=0|Activo:bit=1',unique=[['IdUsuario','IdAlmacen']])
new(4,'ALMA.ProductoAlmacen','IdAlmacen:@ALMA.AlmacenCatalogo|IdTipoBien:@ALMA.TipoBien|Minimo:decimal(20,4)=0|Maximo:decimal(20,4)?|PuntoReposicion:decimal(20,4)=0|Activo:bit=1',unique=[['IdAlmacen','IdTipoBien']],checks=['Minimo >= 0 AND PuntoReposicion >= 0 AND (Maximo IS NULL OR Maximo >= Minimo)'])
new(4,'ALMA.UbicacionAlmacen','IdAlmacen:@ALMA.AlmacenCatalogo|Codigo:nvarchar(40)|Zona:nvarchar(40)?|Pasillo:nvarchar(40)?|Anaquel:nvarchar(40)?|Activo:bit=1',unique=[['IdAlmacen','Codigo']])
new(4,'ALMA.Lote','IdTipoBien:@ALMA.TipoBien|Numero:nvarchar(80)|Caducidad:date?',unique=[['IdEmpresa','IdTipoBien','Numero']])
new(4,'ALMA.PartidaStock','IdAlmacen:@ALMA.AlmacenCatalogo|IdProductoAlmacen:@ALMA.ProductoAlmacen|IdTipoBien:@ALMA.TipoBien|IdUbicacion:@ALMA.UbicacionAlmacen|IdLote:@ALMA.Lote?|Condicion:varchar(20)|Activo:bit=1',unique=[['IdProductoAlmacen','IdUbicacion','IdLote','Condicion']],checks=["Condicion IN ('DISPONIBLE','CUARENTENA','DANADO','BLOQUEADO')"])
new(4,'ALMA.Transferencia','IdAlmacenOrigen:@ALMA.AlmacenCatalogo|IdAlmacenDestino:@ALMA.AlmacenCatalogo|IdAlmacenTransito:@ALMA.AlmacenCatalogo|IdOperacion:@SIS.OperacionNegocio|Folio:nvarchar(60)|Fecha:datetime2(7)|Estado:varchar(20)',unique=[['IdEmpresa','Folio'],['IdOperacion']],checks=['IdAlmacenOrigen <> IdAlmacenDestino AND IdAlmacenTransito <> IdAlmacenOrigen AND IdAlmacenTransito <> IdAlmacenDestino',"Estado IN ('BORRADOR','AUTORIZADA','EN_TRANSITO','PARCIAL','RECIBIDA','CANCELADA')"])
new(4,'ALMA.TransferenciaDetalle','IdTransferencia:@ALMA.Transferencia|IdTipoBien:@ALMA.TipoBien|CantidadSolicitada:decimal(20,4)',checks=['CantidadSolicitada > 0'])
new(4,'ALMA.MovimientoInventario','IdOperacion:@SIS.OperacionNegocio|Tipo:varchar(20)|Fecha:datetime2(7)|Estado:varchar(20)|ClaveOperacion:uniqueidentifier|AplicadoUtc:datetime2(7)?|IdUsuarioAplicacion:@SIS.Usuario?',unique=[['IdEmpresa','ClaveOperacion'],['IdOperacion']],checks=["Tipo IN ('ENTRADA','SALIDA','AJUSTE','TRANSFERENCIA','SALDO_INICIAL','REVERSA')","Estado IN ('BORRADOR','APLICADO','CANCELADO')","(Estado='APLICADO' AND AplicadoUtc IS NOT NULL AND IdUsuarioAplicacion IS NOT NULL) OR (Estado<>'APLICADO' AND AplicadoUtc IS NULL AND IdUsuarioAplicacion IS NULL)"])
add('ALMA.MovimientoInventario','IdMovimientoReversa','bigint',True,ref='ALMA.MovimientoInventario');index('ALMA.MovimientoInventario',['IdMovimientoReversa'],where='[IdMovimientoReversa] IS NOT NULL');check('ALMA.MovimientoInventario',"(Tipo='REVERSA' AND IdMovimientoReversa IS NOT NULL AND IdMovimientoReversa<>IdMovimientoInventario) OR (Tipo<>'REVERSA' AND IdMovimientoReversa IS NULL)",'Reversa')
new(4,'ALMA.MovimientoInventarioDetalle','IdMovimiento:@ALMA.MovimientoInventario|IdPartidaStock:@ALMA.PartidaStock|IdDetalleSolicitudSalida:@ALMA.DetalleSolicitudSalida?|IdTransferenciaDetalle:@ALMA.TransferenciaDetalle?|Cantidad:decimal(20,4)|CostoUnitario:decimal(20,4)|ImporteValoracion:decimal(20,4)|IdEntradaLegada:@ALMA.Almacen?',checks=['Cantidad <> 0 AND CostoUnitario >= 0'])
new(4,'ALMA.ReservaStock','IdPartidaStock:@ALMA.PartidaStock|IdDetalleSolicitudSalida:@ALMA.DetalleSolicitudSalida|Cantidad:decimal(20,4)|Vencimiento:datetime2(7)?|Estado:varchar(16)|ClaveOperacion:uniqueidentifier',unique=[['IdEmpresa','ClaveOperacion']],checks=['Cantidad > 0',"Estado IN ('ACTIVA','CONSUMIDA','LIBERADA','VENCIDA')"])
for n,key,ref in [('ALMA.SolicitudSalida','IdAlmacen','ALMA.AlmacenCatalogo'),('ALMA.PeriodoConteo','IdAlmacen','ALMA.AlmacenCatalogo'),('ALMA.Conteo','IdPartidaStock','ALMA.PartidaStock'),('ALMA.PlanConteoCiclico','IdProductoAlmacen','ALMA.ProductoAlmacen'),('ALMA.CierreInventario','IdPartidaStock','ALMA.PartidaStock')]:
 add(n,key,'bigint',False,ref=ref)
add('ALMA.Almacen','IdPartidaStock','bigint',True,ref='ALMA.PartidaStock')
add('ALMA.DetalleSolicitudSalida','IdAlmacen','bigint',False,ref='ALMA.AlmacenCatalogo')
add('ALMA.Conteo','IdMovimientoAjuste','bigint',True,ref='ALMA.MovimientoInventario')
for n,old,newcols in [('ALMA.PlanConteoCiclico','UQ_PlanConteoCiclico_TipoBien',['IdProductoAlmacen']),('ALMA.CierreInventario','UQ_CierreInventario_EmpresaAnioBienMes',['IdPartidaStock','FKIdAnio_SIS','Mes']),('ALMA.PeriodoConteo','UQ_PeriodoConteo_Codigo',['IdAlmacen','CodigoPeriodo'])]:
 T[n]['indexes']=[i for i in T[n]['indexes'] if i['name']!=old];index(n,newcols);CHANGES.append((n,old,'Unicidad rediseñada: '+', '.join(newcols)))
# 05 PATRIMONIO: field aliases remain explicit in inherited ALMA tables.
new(5,'PAT.UbicacionPatrimonial','IdSucursal:@SIS.Sucursal|Codigo:nvarchar(40)|Edificio:nvarchar(100)?|Planta:nvarchar(50)?|Espacio:nvarchar(100)|Activo:bit=1',unique=[['IdEmpresa','IdSucursal','Codigo']])
new(5,'PAT.HistorialUbicacionBien','IdBien:@ALMA.Bien|IdUbicacionPatrimonial:@PAT.UbicacionPatrimonial?|IdUbicacionAlmacen:@ALMA.UbicacionAlmacen?|IdOperacion:@SIS.OperacionNegocio|Desde:datetime2(7)|Hasta:datetime2(7)?',checks=['(IdUbicacionPatrimonial IS NOT NULL AND IdUbicacionAlmacen IS NULL) OR (IdUbicacionPatrimonial IS NULL AND IdUbicacionAlmacen IS NOT NULL)','Hasta IS NULL OR Hasta > Desde'])
index('PAT.HistorialUbicacionBien',['IdBien'],where='[Hasta] IS NULL')
new(5,'PAT.IdentificadorBien','IdBien:@ALMA.Bien|Tipo:varchar(10)|Codigo:nvarchar(180)|Desde:datetime2(7)|Hasta:datetime2(7)?',unique=[['IdEmpresa','Tipo','Codigo']],checks=["Tipo IN ('QR','BARRAS','RFID')",'Hasta IS NULL OR Hasta >= Desde'])
new(5,'PAT.InmuebleDetalle','IdBien:@ALMA.Bien|ClaveCatastral:nvarchar(80)?|Superficie:decimal(20,4)?|Domicilio:nvarchar(500)|DocumentoPropiedad:@SIS.Documento?',unique=[['IdBien']],checks=['Superficie IS NULL OR Superficie > 0'])
new(5,'PAT.PoliticaDepreciacionVersion','Codigo:nvarchar(40)|Version:int|Metodo:varchar(30)|VidaUtilMeses:int|PorcentajeResidual:decimal(9,6)|Desde:date|Hasta:date?|IdUsuarioAprobacion:@SIS.Usuario?|AprobadaUtc:datetime2(7)?',unique=[['IdEmpresa','Codigo','Version']],checks=['Version > 0 AND VidaUtilMeses > 0 AND PorcentajeResidual BETWEEN 0 AND 1','Hasta IS NULL OR Hasta >= Desde'])
new(5,'PAT.DepreciacionBienPeriodo','IdBien:@ALMA.Bien|IdPoliticaVersion:@PAT.PoliticaDepreciacionVersion|IdPoliza:@CONTA.Poliza?|Ejercicio:smallint|Mes:tinyint|Base:decimal(20,4)|Importe:decimal(20,4)|Estado:varchar(16)',unique=[['IdBien','Ejercicio','Mes']],checks=['Mes BETWEEN 1 AND 12 AND Base >= 0 AND Importe >= 0'])
add('ALMA.Resguardo','IdResponsableOperativo','bigint',False,ref='SIS.ResponsableOperativo')
for n in ['ALMA.Bien','ALMA.InventarioDetalle']:
 add(n,'IdUbicacionPatrimonial','bigint',True,ref='PAT.UbicacionPatrimonial');add(n,'IdUbicacionAlmacen','bigint',True,ref='ALMA.UbicacionAlmacen');check(n,'IdUbicacionPatrimonial IS NULL OR IdUbicacionAlmacen IS NULL','DestinoExclusivo')
# 03 PRESUPUESTO
new(3,'PRES.PresupuestoVersion','IdAnio:@SIS.Anio|Version:int|Estado:varchar(16)|IdUsuarioAprobacion:@SIS.Usuario?|FechaAprobacion:datetime2(7)?',unique=[['IdEmpresa','IdAnio','Version']],checks=['Version > 0',"Estado IN ('BORRADOR','APROBADO','CERRADO','CANCELADO')"])
new(3,'PRES.ReservaPresupuestal','IdEgresoAutorizado:@PRES.EgresoAutorizado|IdOperacion:@SIS.OperacionNegocio|Mes:tinyint|Importe:decimal(18,2)|Estado:varchar(16)|Fecha:datetime2(7)|FechaLiberacion:datetime2(7)?|ClaveOperacion:uniqueidentifier',unique=[['IdEmpresa','ClaveOperacion']],checks=['Importe > 0 AND Mes BETWEEN 1 AND 12',"Estado IN ('RESERVADA','COMPROMETIDA','LIBERADA','CANCELADA')"])
for n in ['PRES.EgresoProyectado','PRES.EgresoAutorizado']:
 add(n,'IdPresupuestoVersion','bigint',False,ref='PRES.PresupuestoVersion');add(n,'IdCentroCosto','bigint',False,ref='SIS.CentroCosto')
# 06 COMPRAS AND CORPORATE SUPPLIERS
new(6,'ORCO.CriterioEvaluacion','Codigo:nvarchar(30)|Version:int|Nombre:nvarchar(180)|Peso:decimal(9,6)|Desde:date|Hasta:date?',unique=[['IdEmpresa','Codigo','Version']],checks=['Peso BETWEEN 0 AND 1 AND Version > 0','Hasta IS NULL OR Hasta >= Desde'])
new(6,'ORCO.EvaluacionOferta','IdCotizacionDetalle:@ORCO.CotizacionDetalle|IdCriterio:@ORCO.CriterioEvaluacion|Puntuacion:decimal(9,4)|IdDocumentoEvidencia:@SIS.Documento?|IdUsuarioEvaluacion:@SIS.Usuario|Fecha:datetime2(7)',unique=[['IdCotizacionDetalle','IdCriterio']],checks=['Puntuacion >= 0'])
new(6,'ORCO.DestinoOrdenCompra','IdOrdenCompraDetalle:@ORCO.OrdenCompraDetalle|IdAlmacen:@ALMA.AlmacenCatalogo?|IdCentroCosto:@SIS.CentroCosto?|Cantidad:decimal(18,4)',checks=['Cantidad > 0','(IdAlmacen IS NOT NULL AND IdCentroCosto IS NULL) OR (IdAlmacen IS NULL AND IdCentroCosto IS NOT NULL)'])
new(6,'ORCO.Recepcion','IdOperacion:@SIS.OperacionNegocio|Folio:nvarchar(60)|Fecha:datetime2(7)|IdResponsable:@SIS.ResponsableOperativo|Estado:varchar(16)',unique=[['IdEmpresa','Folio'],['IdOperacion']],checks=["Estado IN ('BORRADOR','ACEPTADA','RECHAZADA','CANCELADA')"])
new(6,'ORCO.RecepcionDetalle','IdRecepcion:@ORCO.Recepcion|IdDestinoOrdenCompra:@ORCO.DestinoOrdenCompra|CantidadAceptada:decimal(18,4)|CantidadRechazada:decimal(18,4)=0|Tipo:varchar(10)',checks=['CantidadAceptada >= 0 AND CantidadRechazada >= 0 AND CantidadAceptada + CantidadRechazada > 0',"Tipo IN ('BIEN','SERVICIO')"])
new(6,'SIS.ProveedorEmpresa','IdProveedor:@SIS.Proveedor|Condiciones:nvarchar(600)?|DiasCredito:int=0|Estatus:varchar(16)|Activo:bit=1',unique=[['IdEmpresa','IdProveedor']],checks=['DiasCredito >= 0'])
new(6,'ORCO.CuentaProveedor','IdProveedorEmpresa:@SIS.ProveedorEmpresa|IdBanco:@TES.Banco|CLABE:char(18)|Titular:nvarchar(200)|EstadoValidacion:varchar(20)|ValidadaUtc:datetime2(7)?|IdUsuarioValidacion:@SIS.Usuario?',unique=[['IdProveedorEmpresa','CLABE']],checks=["CLABE NOT LIKE '%[^0-9]%'"])
new(6,'ORCO.EvaluacionFiscalProveedor','IdProveedorEmpresa:@SIS.ProveedorEmpresa|TipoConsulta:varchar(30)|RFC:varchar(13)|Fecha:datetime2(7)|Resultado:nvarchar(250)|IdDocumentoEvidencia:@SIS.Documento?|Fuente:nvarchar(200)')
add('ORCO.Requisicion','IdCentroCosto','bigint',False,ref='SIS.CentroCosto');add('ORCO.Requisicion','Prioridad','tinyint',False,'2');check('ORCO.Requisicion','Prioridad BETWEEN 1 AND 5','Prioridad')
add('ALMA.MovimientoInventarioDetalle','IdRecepcionDetalle','bigint',True,ref='ORCO.RecepcionDetalle')
new(7,'PAG.FacturaRecepcion','IdFacturaDetalle:@PRES.FacturaDetalle|IdRecepcionDetalle:@ORCO.RecepcionDetalle|Cantidad:decimal(20,4)|ImporteConciliado:decimal(20,4)',unique=[['IdFacturaDetalle','IdRecepcionDetalle']],checks=['Cantidad > 0 AND ImporteConciliado >= 0'])
# 12 FISCAL CORE AND EXPENSE SUPPORT shared by treasury modules.
new(12,'FIS.Cfdi','UUID:uniqueidentifier|Tipo:char(1)|RFCEmisor:varchar(13)|RFCReceptor:varchar(13)|FechaEmision:datetime2(7)|IdMoneda:@SIS.Moneda|Subtotal:decimal(20,4)|Total:decimal(20,4)|Estado:varchar(20)|IdDocumentoXml:@SIS.Documento|IdDocumentoPdf:@SIS.Documento?',unique=[['IdEmpresa','UUID']],checks=["Tipo IN ('I','E','T','N','P')",'Total >= 0'])
new(12,'FIS.CfdiConcepto','IdCfdi:@FIS.Cfdi|Renglon:int|ClaveProductoServicio:varchar(12)|ClaveUnidad:varchar(10)|Descripcion:nvarchar(1000)|Cantidad:decimal(20,4)|ValorUnitario:decimal(20,4)|Importe:decimal(20,4)|Descuento:decimal(20,4)=0',unique=[['IdCfdi','Renglon']],checks=['Renglon > 0 AND Cantidad > 0 AND ValorUnitario >= 0 AND Importe >= 0 AND Descuento >= 0'])
new(12,'FIS.CfdiImpuesto','IdCfdiConcepto:@FIS.CfdiConcepto|CodigoImpuesto:varchar(3)|Tipo:varchar(12)|TipoFactor:varchar(10)|Base:decimal(20,4)|TasaOCuota:decimal(18,6)?|Importe:decimal(20,4)?',checks=["Tipo IN ('TRASLADO','RETENCION')",'Base >= 0'])
new(12,'FIS.ValidacionCfdi','IdCfdi:@FIS.Cfdi|Fecha:datetime2(7)|Fuente:nvarchar(150)|Resultado:nvarchar(500)|IdDocumentoEvidencia:@SIS.Documento?')
new(12,'FIS.EventoCfdi','IdCfdi:@FIS.Cfdi|Tipo:varchar(30)|Fecha:datetime2(7)|IdDocumentoAcuse:@SIS.Documento?|ClaveOperacion:uniqueidentifier',unique=[['IdEmpresa','ClaveOperacion']])
new(12,'FIS.ComprobanteGasto','IdDocumento:@SIS.Documento|IdCfdi:@FIS.Cfdi?|Fecha:date|IdMoneda:@SIS.Moneda|Total:decimal(20,4)|Concepto:nvarchar(500)',checks=['Total > 0'])
index('FIS.ComprobanteGasto',['IdDocumento']);index('FIS.ComprobanteGasto',['IdCfdi'],where='[IdCfdi] IS NOT NULL')
# 07 PAYABLES: explicit origin in commitments prevents unconstrained origin IDs.
new(7,'PAG.CompromisoPago','IdOperacion:@SIS.OperacionNegocio|IdProveedorEmpresa:@SIS.ProveedorEmpresa?|IdResponsable:@SIS.ResponsableOperativo?|BeneficiarioNombre:nvarchar(200)|IdMoneda:@SIS.Moneda|Importe:decimal(20,4)|Vencimiento:date|Estado:varchar(20)|IdFactura:@PRES.Factura?',unique=[['IdOperacion']],checks=['Importe > 0','IdProveedorEmpresa IS NULL OR IdResponsable IS NULL',"Estado IN ('PENDIENTE','AUTORIZADO','PARCIAL','PAGADO','CANCELADO')"])
new(7,'PAG.NotaCredito','IdProveedorEmpresa:@SIS.ProveedorEmpresa|IdCfdi:@FIS.Cfdi|IdMoneda:@SIS.Moneda|Fecha:date|Importe:decimal(20,4)',unique=[['IdCfdi']],checks=['Importe > 0'])
new(7,'PAG.AplicacionNotaCredito','IdNotaCredito:@PAG.NotaCredito|IdFactura:@PRES.Factura|Importe:decimal(20,4)|Fecha:datetime2(7)|ClaveOperacion:uniqueidentifier',unique=[['IdEmpresa','ClaveOperacion']],checks=['Importe <> 0'])
add('PAG.AplicacionNotaCredito','IdAplicacionReversa','bigint',True,ref='PAG.AplicacionNotaCredito');index('PAG.AplicacionNotaCredito',['IdAplicacionReversa'],where='[IdAplicacionReversa] IS NOT NULL')
new(7,'PAG.ProgramacionPago','IdCompromiso:@PAG.CompromisoPago|Version:int|FechaPrevista:date|Prioridad:tinyint|Motivo:nvarchar(500)?',unique=[['IdCompromiso','Version']],checks=['Version > 0 AND Prioridad BETWEEN 1 AND 5'])
new(7,'PAG.Pago','IdOperacion:@SIS.OperacionNegocio|IdCuentaBancaria:@TES.CuentaBancaria|IdMoneda:@SIS.Moneda|IdProveedorEmpresa:@SIS.ProveedorEmpresa?|IdResponsable:@SIS.ResponsableOperativo?|BeneficiarioNombre:nvarchar(200)|Importe:decimal(20,4)|Fecha:datetime2(7)|Estado:varchar(20)|ClaveOperacion:uniqueidentifier',unique=[['IdEmpresa','ClaveOperacion'],['IdOperacion']],checks=['Importe > 0','IdProveedorEmpresa IS NULL OR IdResponsable IS NULL',"Estado IN ('BORRADOR','AUTORIZADO','ENVIADO','CONFIRMADO','RECHAZADO','CANCELADO')"])
new(7,'PAG.AplicacionPago','IdPago:@PAG.Pago|IdCompromiso:@PAG.CompromisoPago|IdMoneda:@SIS.Moneda|Importe:decimal(20,4)|Fecha:datetime2(7)|ClaveOperacion:uniqueidentifier',unique=[['IdEmpresa','ClaveOperacion']],checks=['Importe <> 0'])
add('PAG.AplicacionPago','IdAplicacionReversa','bigint',True,ref='PAG.AplicacionPago');index('PAG.AplicacionPago',['IdAplicacionReversa'],where='[IdAplicacionReversa] IS NOT NULL')
new(7,'PAG.PagoPoliza','IdPago:@PAG.Pago|IdPoliza:@CONTA.Poliza|Tipo:varchar(20)',unique=[['IdPago','IdPoliza']])
new(8,'TES.EventoCheque','IdCheque:@PRES.Cheque|Tipo:varchar(16)|Fecha:datetime2(7)|IdDocumentoAcuse:@SIS.Documento?|Observaciones:nvarchar(500)?',checks=["Tipo IN ('ENTREGA','CANCELACION','COBRO','DEVOLUCION')"])
add('PRES.Cheque','IdPago','bigint',True,ref='PAG.Pago');index('PRES.Cheque',['IdPago'],where='[IdPago] IS NOT NULL')
for n,c in [('PRES.Factura','FKIdContrato_PRES'),('PRES.Factura','FKIdPoliza_CONTA'),('PRES.FacturaDetalle','FKIdContratoDetalle_PRES'),('PRES.Cheque','FKIdCLC_PRES'),('PRES.Cheque','FKIdPoliza_CONTA')]:
 col(n,c)['is_nullable']=True;CHANGES.append((n,c,'Ahora opcional en estructura nueva; vinculación contable por operación'))
add('PRES.Factura','IdProveedorEmpresa','bigint',False,ref='SIS.ProveedorEmpresa');add('PRES.Factura','IdCfdi','bigint',True,ref='FIS.Cfdi');add('PRES.Factura','Vencimiento','date',False);add('PRES.Factura','IdMoneda','int',False,ref='SIS.Moneda');index('PRES.Factura',['IdCfdi'],where='[IdCfdi] IS NOT NULL')
# 08 BANKING
new(8,'TES.ConexionBancaria','IdCuentaBancaria:@TES.CuentaBancaria|Convenio:nvarchar(100)|Ambiente:varchar(12)|ReferenciaSecreto:nvarchar(500)|Activo:bit=1',unique=[['IdCuentaBancaria','Ambiente']],checks=["Ambiente IN ('PRUEBAS','PRODUCCION')"])
new(8,'TES.LoteDispersion','IdOperacion:@SIS.OperacionNegocio|IdCuentaBancaria:@TES.CuentaBancaria|Fecha:datetime2(7)|Estado:varchar(20)|TotalControl:decimal(20,4)|NumeroOperaciones:int',unique=[['IdOperacion']],checks=['TotalControl >= 0 AND NumeroOperaciones >= 0'])
new(8,'TES.OperacionBancaria','IdPago:@PAG.Pago|IdConexion:@TES.ConexionBancaria|IdLoteDispersion:@TES.LoteDispersion?|ClaveIdempotencia:uniqueidentifier|Estado:varchar(20)|ReferenciaBanco:nvarchar(150)?|IdDocumentoAcuse:@SIS.Documento?',unique=[['IdPago'],['IdEmpresa','ClaveIdempotencia']])
new(8,'TES.IntentoEnvioBancario','IdOperacionBancaria:@TES.OperacionBancaria|NumeroIntento:int|Fecha:datetime2(7)|CodigoRespuesta:nvarchar(60)?|Respuesta:nvarchar(1500)?',unique=[['IdOperacionBancaria','NumeroIntento']],checks=['NumeroIntento > 0'])
new(8,'TES.MovimientoBancario','IdCuentaBancaria:@TES.CuentaBancaria|ReferenciaExterna:nvarchar(150)|FechaValor:date|FechaOperacion:datetime2(7)|IdMoneda:@SIS.Moneda|Importe:decimal(20,4)|Concepto:nvarchar(500)?|IdDocumentoEstadoCuenta:@SIS.Documento?',unique=[['IdCuentaBancaria','ReferenciaExterna']],checks=['Importe <> 0'])
new(8,'TES.ConciliacionDetalle','IdMovimientoBancario:@TES.MovimientoBancario|IdPago:@PAG.Pago|Importe:decimal(20,4)|Estado:varchar(16)|Fecha:datetime2(7)',unique=[['IdMovimientoBancario','IdPago']],checks=['Importe > 0',"Estado IN ('PROPUESTA','CONCILIADA','REVERSADA')"])
new(8,'TES.PrevisionTesoreria','Fecha:date|IdMoneda:@SIS.Moneda|Escenario:nvarchar(60)|Sentido:varchar(8)|Importe:decimal(20,4)|IdOperacion:@SIS.OperacionNegocio?|Concepto:nvarchar(500)',checks=["Sentido IN ('ENTRADA','SALIDA')",'Importe >= 0'])
# 09 PETTY CASH
new(9,'CAJA.FondoCaja','IdResponsable:@SIS.ResponsableOperativo|IdCentroCosto:@SIS.CentroCosto|Codigo:nvarchar(30)|IdMoneda:@SIS.Moneda|MontoAutorizado:decimal(20,4)|Activo:bit=1',unique=[['IdEmpresa','Codigo']],checks=['MontoAutorizado > 0'])
new(9,'CAJA.ValeCaja','IdFondo:@CAJA.FondoCaja|IdOperacion:@SIS.OperacionNegocio|Importe:decimal(20,4)|Fecha:date|Estado:varchar(20)|Concepto:nvarchar(500)',unique=[['IdOperacion']],checks=['Importe > 0'])
new(9,'CAJA.MovimientoFondo','IdFondo:@CAJA.FondoCaja|IdOperacion:@SIS.OperacionNegocio|IdVale:@CAJA.ValeCaja?|Tipo:varchar(20)|Importe:decimal(20,4)|Fecha:datetime2(7)|ClaveOperacion:uniqueidentifier',unique=[['IdEmpresa','ClaveOperacion']],checks=['Importe <> 0',"Tipo IN ('APERTURA','GASTO','REPOSICION','REINTEGRO','REVERSA')"])
add('CAJA.MovimientoFondo','IdMovimientoReversa','bigint',True,ref='CAJA.MovimientoFondo');index('CAJA.MovimientoFondo',['IdMovimientoReversa'],where='[IdMovimientoReversa] IS NOT NULL')
new(9,'CAJA.ArqueoCaja','IdFondo:@CAJA.FondoCaja|Fecha:datetime2(7)|SaldoTeorico:decimal(20,4)|SaldoFisico:decimal(20,4)|IdResponsable:@SIS.ResponsableOperativo|Observaciones:nvarchar(600)?',checks=['SaldoFisico >= 0'])
new(9,'CAJA.ArqueoDetalle','IdArqueo:@CAJA.ArqueoCaja|Denominacion:decimal(20,4)|Cantidad:int',unique=[['IdArqueo','Denominacion']],checks=['Denominacion > 0 AND Cantidad >= 0'])
new(9,'CAJA.ComprobacionCaja','IdVale:@CAJA.ValeCaja|IdComprobanteGasto:@FIS.ComprobanteGasto|ImporteAceptado:decimal(20,4)|Estado:varchar(20)|Fecha:datetime2(7)',unique=[['IdVale','IdComprobanteGasto']],checks=['ImporteAceptado > 0'])
new(9,'CAJA.ReposicionCaja','IdFondo:@CAJA.FondoCaja|IdOperacion:@SIS.OperacionNegocio|Importe:decimal(20,4)|Estado:varchar(20)|Fecha:datetime2(7)',unique=[['IdOperacion']],checks=['Importe > 0'])
new(9,'CAJA.ReposicionDetalle','IdReposicion:@CAJA.ReposicionCaja|IdComprobacionCaja:@CAJA.ComprobacionCaja|Importe:decimal(20,4)',unique=[['IdComprobacionCaja']],checks=['Importe > 0'])
add('PAG.CompromisoPago','IdReposicionCaja','bigint',True,ref='CAJA.ReposicionCaja');add('CAJA.MovimientoFondo','IdReposicion','bigint',True,ref='CAJA.ReposicionCaja')
# 10 TRAVEL, no payroll.
new(10,'VIA.SolicitudViatico','IdOperacion:@SIS.OperacionNegocio|IdResponsable:@SIS.ResponsableOperativo|IdCentroCosto:@SIS.CentroCosto|IdMoneda:@SIS.Moneda|Comision:nvarchar(800)|Destino:nvarchar(300)|FechaInicio:date|FechaFin:date|Estado:varchar(20)',unique=[['IdOperacion']],checks=['FechaFin >= FechaInicio'])
new(10,'VIA.AnticipoViatico','IdSolicitud:@VIA.SolicitudViatico|Importe:decimal(20,4)|Fecha:date|Estado:varchar(20)',checks=['Importe > 0'])
new(10,'VIA.ComprobacionViatico','IdSolicitud:@VIA.SolicitudViatico|IdComprobanteGasto:@FIS.ComprobanteGasto|ImporteAceptado:decimal(20,4)|Estado:varchar(20)|Fecha:datetime2(7)',unique=[['IdSolicitud','IdComprobanteGasto']],checks=['ImporteAceptado > 0'])
new(10,'VIA.ReintegroViatico','IdSolicitud:@VIA.SolicitudViatico|IdMovimientoBancario:@TES.MovimientoBancario?|Importe:decimal(20,4)|Fecha:datetime2(7)|IdDocumentoEvidencia:@SIS.Documento',checks=['Importe > 0'])
add('PAG.CompromisoPago','IdAnticipoViatico','bigint',True,ref='VIA.AnticipoViatico')
# 11 INSTITUTIONAL COMPLIANCE
new(11,'CUM.CatalogoObligacion','Codigo:nvarchar(40)|Nombre:nvarchar(200)|Tipo:varchar(30)|Jurisdiccion:nvarchar(150)|Periodicidad:varchar(30)|Activo:bit=1',unique=[['IdEmpresa','Codigo']])
new(11,'CUM.ObligacionEmpresa','IdCatalogo:@CUM.CatalogoObligacion|IdResponsable:@SIS.ResponsableOperativo|IdSucursal:@SIS.Sucursal?|Desde:date|Hasta:date?|Activo:bit=1',unique=[['IdEmpresa','IdCatalogo','IdSucursal','Desde']],checks=['Hasta IS NULL OR Hasta >= Desde'])
new(11,'CUM.VencimientoObligacion','IdObligacion:@CUM.ObligacionEmpresa|Periodo:nvarchar(30)|FechaLimite:datetime2(7)|Estado:varchar(20)|IdOperacion:@SIS.OperacionNegocio',unique=[['IdObligacion','Periodo'],['IdOperacion']])
new(11,'CUM.EvidenciaCumplimiento','IdVencimiento:@CUM.VencimientoObligacion|IdDocumento:@SIS.Documento|Fecha:datetime2(7)|EstadoValidacion:varchar(20)|IdResponsable:@SIS.ResponsableOperativo',unique=[['IdVencimiento','IdDocumento']])
add('PAG.CompromisoPago','IdVencimientoObligacion','bigint',True,ref='CUM.VencimientoObligacion')
# 12 TAX DECLARATIONS, no rates or official calculations seeded.
new(12,'FIS.Declaracion','IdVencimiento:@CUM.VencimientoObligacion|Tipo:varchar(40)|Ejercicio:smallint|Periodo:nvarchar(30)|Estado:varchar(20)',unique=[['IdVencimiento','Tipo']])
new(12,'FIS.DeclaracionVersion','IdDeclaracion:@FIS.Declaracion|Version:int|Complementaria:bit=0|Fecha:datetime2(7)|IdDocumentoAcuse:@SIS.Documento?|IdUsuarioValidacion:@SIS.Usuario?|ValidadaUtc:datetime2(7)?',unique=[['IdDeclaracion','Version']],checks=['Version > 0'])
new(12,'FIS.ReglaFiscalVersion','Impuesto:varchar(40)|Version:int|ParametrosJson:nvarchar(max)|Fuente:nvarchar(1000)|Desde:date|Hasta:date?|IdUsuarioAprobacion:@SIS.Usuario?|AprobadaUtc:datetime2(7)?',unique=[['IdEmpresa','Impuesto','Version']],checks=['Version > 0 AND ISJSON(ParametrosJson)=1','Hasta IS NULL OR Hasta >= Desde'])
new(12,'FIS.DeterminacionImpuesto','IdDeclaracionVersion:@FIS.DeclaracionVersion|IdReglaFiscalVersion:@FIS.ReglaFiscalVersion|Base:decimal(20,4)|ImporteImpuesto:decimal(20,4)|ResultadoJson:nvarchar(max)?',unique=[['IdDeclaracionVersion','IdReglaFiscalVersion']],checks=['ResultadoJson IS NULL OR ISJSON(ResultadoJson)=1'])
new(12,'FIS.ActualizacionRecargo','IdDeterminacion:@FIS.DeterminacionImpuesto|Periodo:nvarchar(30)|ParametrosJson:nvarchar(max)|Actualizacion:decimal(20,4)|Recargo:decimal(20,4)',checks=['ISJSON(ParametrosJson)=1 AND Actualizacion >= 0 AND Recargo >= 0'])
new(12,'FIS.DeclaracionCfdi','IdDeclaracionVersion:@FIS.DeclaracionVersion|IdCfdi:@FIS.Cfdi|Importe:decimal(20,4)|Criterio:nvarchar(500)',unique=[['IdDeclaracionVersion','IdCfdi']])
new(12,'FIS.AuditoriaFiscal','Autoridad:nvarchar(200)|Periodo:nvarchar(100)|Expediente:nvarchar(100)|FechaInicio:date|FechaFin:date?|Estado:varchar(20)',unique=[['IdEmpresa','Autoridad','Expediente']],checks=['FechaFin IS NULL OR FechaFin >= FechaInicio'])
new(12,'FIS.ObservacionFiscal','IdAuditoria:@FIS.AuditoriaFiscal|Descripcion:nvarchar(1500)|Vencimiento:date|Estado:varchar(20)|IdDocumentoEvidencia:@SIS.Documento?')
new(12,'FIS.SancionFiscal','IdObservacion:@FIS.ObservacionFiscal|Concepto:nvarchar(500)|Importe:decimal(20,4)|Vencimiento:date|IdMoneda:@SIS.Moneda',checks=['Importe >= 0'])
add('PAG.CompromisoPago','IdSancionFiscal','bigint',True,ref='FIS.SancionFiscal')
check('PAG.CompromisoPago','(CASE WHEN IdFactura IS NULL THEN 0 ELSE 1 END + CASE WHEN IdReposicionCaja IS NULL THEN 0 ELSE 1 END + CASE WHEN IdAnticipoViatico IS NULL THEN 0 ELSE 1 END + CASE WHEN IdVencimientoObligacion IS NULL THEN 0 ELSE 1 END + CASE WHEN IdSancionFiscal IS NULL THEN 0 ELSE 1 END) = 1','OrigenUnico')
# 13 WORKFLOW / NOTIFICATIONS
new(13,'WF.ReglaAutorizacion','IdTemplate:@PBR.WorkflowTemplate|IdSucursal:@SIS.Sucursal?|RoleId:nvarchar(128)|Nivel:int|Version:int|MontoDesde:decimal(20,4)|MontoHasta:decimal(20,4)?|Desde:date|Hasta:date?',checks=['Nivel > 0 AND Version > 0 AND MontoDesde >= 0 AND (MontoHasta IS NULL OR MontoHasta >= MontoDesde)','Hasta IS NULL OR Hasta >= Desde'])
# EmptyProjects AspNetRoles key length is taken from actual metadata, not assumed.
col('WF.ReglaAutorizacion','RoleId').update({k:v for k,v in col('dbo.AspNetRoles','Id').items() if k in ['type_name','base_type_name','max_length','precision','scale','collation_name']})
REL.append(('WF.ReglaAutorizacion',['RoleId'],'dbo.AspNetRoles',['Id'],False))
new(13,'WF.DecisionAutorizacion','IdEnvio:@SIS.EnvioWorkflow|IdRegla:@WF.ReglaAutorizacion|IdUsuario:@SIS.Usuario|Decision:varchar(16)|Fecha:datetime2(7)|Motivo:nvarchar(1000)?|ClaveOperacion:uniqueidentifier',unique=[['IdEmpresa','ClaveOperacion']],checks=["Decision IN ('AUTORIZAR','RECHAZAR','DEVOLVER')"])
new(13,'WF.CalendarioAtencion','Codigo:nvarchar(30)|ZonaHoraria:nvarchar(100)|HorarioJson:nvarchar(max)|ExcepcionesJson:nvarchar(max)?|Activo:bit=1',unique=[['IdEmpresa','Codigo']],checks=['ISJSON(HorarioJson)=1','ExcepcionesJson IS NULL OR ISJSON(ExcepcionesJson)=1'])
new(13,'WF.PoliticaSLA','IdTemplate:@PBR.WorkflowTemplate|IdCalendario:@WF.CalendarioAtencion|Etapa:nvarchar(60)|PlazoMinutos:int|EscalamientoJson:nvarchar(max)?|Version:int',unique=[['IdTemplate','Etapa','Version']],checks=['PlazoMinutos > 0 AND Version > 0','EscalamientoJson IS NULL OR ISJSON(EscalamientoJson)=1'])
new(13,'WF.PlazoOperacion','IdEnvio:@SIS.EnvioWorkflow|IdPoliticaSLA:@WF.PoliticaSLA|Inicio:datetime2(7)|Limite:datetime2(7)|MinutosPausa:int=0|Cierre:datetime2(7)?',checks=['Limite >= Inicio AND MinutosPausa >= 0 AND (Cierre IS NULL OR Cierre >= Inicio)'])
new(13,'WF.EventoPendiente','IdOperacion:@SIS.OperacionNegocio|Tipo:varchar(60)|FechaPrevista:datetime2(7)|Estado:varchar(16)|ClaveOperacion:uniqueidentifier|Intentos:int=0|UltimoError:nvarchar(1000)?|DatosJson:nvarchar(max)?',unique=[['IdEmpresa','ClaveOperacion']],checks=['Intentos >= 0','DatosJson IS NULL OR ISJSON(DatosJson)=1',"Estado IN ('PENDIENTE','PROCESANDO','ENVIADO','ERROR','CANCELADO')"])
add('SIS.EnvioWorkflow','IdOperacion','bigint',False,ref='SIS.OperacionNegocio');add('SIS.EnvioWorkflow','IdTemplate','int',False,ref='PBR.WorkflowTemplate');add('PBR.WorkflowTemplate','Version','int',False,'1');add('PBR.WorkflowTemplate','VigenciaDesde','date',False);add('PBR.WorkflowTemplate','VigenciaHasta','date',True)
add('SIS.Notificacion','IdEventoPendiente','bigint',True,ref='WF.EventoPendiente');add('SIS.Notificacion','IdRegla','int',True,ref='SIS.NotificacionRegla')
# 14 DOCUMENTS / OCR
new(14,'DOC.OperacionDocumento','IdOperacion:@SIS.OperacionNegocio|IdDocumento:@SIS.Documento|Rol:varchar(40)|Clasificacion:varchar(30)|VigenteDesde:datetime2(7)|VigenteHasta:datetime2(7)?',unique=[['IdOperacion','IdDocumento','Rol']],checks=['VigenteHasta IS NULL OR VigenteHasta >= VigenteDesde'])
new(14,'DOC.ExtraccionDocumento','IdDocumento:@SIS.Documento|Motor:nvarchar(100)|VersionMotor:nvarchar(60)|EstadoRevision:varchar(20)|IdUsuarioRevision:@SIS.Usuario?|FechaRevision:datetime2(7)?')
new(14,'DOC.CampoExtraido','IdExtraccion:@DOC.ExtraccionDocumento|Nombre:nvarchar(100)|ValorDetectado:nvarchar(max)?|Confianza:decimal(9,6)?|ValorCorregido:nvarchar(max)?|Validado:bit=0',checks=['Confianza IS NULL OR Confianza BETWEEN 0 AND 1'])
# 15 AUDIT, SEGREGATION, RISK
new(15,'CTL.ReglaRiesgo','Codigo:nvarchar(40)|Version:int|Escenario:nvarchar(300)|ParametrosJson:nvarchar(max)|Desde:date|Hasta:date?|Activo:bit=1',unique=[['IdEmpresa','Codigo','Version']],checks=['Version > 0 AND ISJSON(ParametrosJson)=1','Hasta IS NULL OR Hasta >= Desde'])
new(15,'CTL.CasoRiesgo','IdRegla:@CTL.ReglaRiesgo|IdOperacion:@SIS.OperacionNegocio|IdDocumentoEvidencia:@SIS.Documento?|Descripcion:nvarchar(1500)|Estado:varchar(20)|AbiertoUtc:datetime2(7)|CerradoUtc:datetime2(7)?|IdResponsable:@SIS.ResponsableOperativo?',checks=['CerradoUtc IS NULL OR CerradoUtc >= AbiertoUtc'])
new(15,'CTL.ReglaSegregacion','Codigo:nvarchar(40)|AccionA:nvarchar(120)|AccionB:nvarchar(120)|Desde:date|Hasta:date?|Activo:bit=1',unique=[['IdEmpresa','Codigo']],checks=['AccionA <> AccionB','Hasta IS NULL OR Hasta >= Desde'])
add('PBR.AuditoriaCambio','IdOperacion','bigint',True,ref='SIS.OperacionNegocio')
# 02 ACCOUNTING traceability. Original PK/decimal precision remain intact.
add('CONTA.Poliza','IdOperacion','bigint',True,ref='SIS.OperacionNegocio');add('CONTA.Poliza','IdPolizaReversa','int',True,ref='CONTA.Poliza');index('CONTA.Poliza',['IdPolizaReversa'],where='[IdPolizaReversa] IS NOT NULL')
check('CONTA.Poliza','IdPolizaReversa IS NULL OR IdPolizaReversa <> PKIdPoliza','NoAutorreversa')
check('CONTA.PolizaDetalle','ISNULL(ImporteDebe,0) >= 0 AND ISNULL(ImporteHaber,0) >= 0 AND NOT (ISNULL(ImporteDebe,0)>0 AND ISNULL(ImporteHaber,0)>0)','DebeHaber')
T['CONTA.Poliza']['indexes']=[i for i in T['CONTA.Poliza']['indexes'] if i['name']!='UQ_Poliza_Anio_Tipo_Clave'];index('CONTA.Poliza',['IdEmpresa','FKIdAnio_SIS','FKIdTipoPoliza_SIS','ClavePoliza'])
CHANGES.append(('CONTA.Poliza','UQ_Poliza_Anio_Tipo_Clave','Ahora incluye empresa'))
# Versioned templates must permit two versions of the same workflow code.
for i in T['PBR.WorkflowTemplate'].get('indexes',[]):
 if i['is_unique'] and not i['is_primary_key'] and any(c['name']=='Codigo' for c in i['columns']):
  i['columns']=[dict(name=c,key_ordinal=j+1,is_descending_key=False,is_included_column=False) for j,c in enumerate(['IdEmpresa','Codigo','Version'])];i['name']='UX_EXUX_WorkflowTemplate_EmpresaCodigoVersion'
# All operational headers have a concrete business-operation FK; no orphan polymorphic source.
for n in ['ORCO.Requisicion','ORCO.OrdenCompra','PRES.EgresoAutorizado','PRES.EgreAdecuacion','PRES.CLC','PRES.Factura','ALMA.SolicitudSalida','ALMA.Bajas','ALMA.Resguardo']:
 if not any(c['name']=='IdOperacion' for c in T[n]['columns']):add(n,'IdOperacion','bigint',False,ref='SIS.OperacionNegocio');index(n,['IdOperacion'])
# Source Documento's company was optional: new deployment requires ownership.
col('SIS.Documento','FkidEmpresaSis')['is_nullable']=False
CHANGES.append(('SIS.Documento','FkidEmpresaSis','Obligatoria; protección de pertenencia documental'))
# Supplier is a shared catalog; its accounting account belongs to each company association.
T['SIS.Proveedor']['foreign_keys']=[fk for fk in T['SIS.Proveedor'].get('foreign_keys',[]) if not any(c['column']=='FKIdCuentaContable_SIS' for c in fk['columns'])]
T['SIS.Proveedor']['indexes']=[i for i in T['SIS.Proveedor']['indexes'] if not any(c['name']=='FKIdCuentaContable_SIS' for c in i['columns'])]
T['SIS.Proveedor']['columns']=[c for c in T['SIS.Proveedor']['columns'] if c['name']!='FKIdCuentaContable_SIS']
add('SIS.ProveedorEmpresa','IdCuentaContable','int',True,ref='CONTA.CuentaContable')
CHANGES.append(('SIS.Proveedor','FKIdCuentaContable_SIS','Trasladada a ProveedorEmpresa.IdCuentaContable para permitir proveedor compartido'))
for n,old,cols in [('ALMA.Resguardo','UQ_Resguardo_Folio',['FKIdEmpresa_SIS','Folio']),('ALMA.Bajas','UQ_Bajas_Folio',['FKIdEmpresa_SIS','Folio']),('ORCO.OrdenCompra','UQ_OrdenCompra_Numero',['FKIdEmpresa_SIS','NumeroOrdenCompra'])]:
 T[n]['indexes']=[i for i in T[n]['indexes'] if i['name']!=old];index(n,cols);CHANGES.append((n,old,'Unicidad por empresa'))
# Currency coherence is referential; conversion across currencies is not implicit.
add('TES.CuentaBancaria','IdMoneda','int',False,ref='SIS.Moneda')
# Propagate company to inherited child transactions (never through audit-user FKs).
while True:
 changed=False
 for n in sorted(COPIED):
  if sc(n):continue
  candidates=[fk for fk in T[n].get('foreign_keys',[]) if fk['referenced_schema']+'.'+fk['referenced_table'] in T and sc(fk['referenced_schema']+'.'+fk['referenced_table']) and not all(c['column'].lower() in ['usuariocreacion','usuariomodificacion','usuarioautorizacion'] for c in fk['columns']) and fk['referenced_table']!='Usuario']
  if candidates:
   add(n,'IdEmpresa','int',False,ref='SIS.Empresa');CHANGES.append((n,'IdEmpresa','Contexto obligatorio por relación de negocio'));changed=True
 if not changed:break
# Enforce consistency beyond simple identity: warehouse, product, lot, and stock.
def rel(child,cols,parent,refs):REL.append((child,cols,parent,refs,False))
rel('ALMA.PartidaStock',['IdEmpresa','IdProductoAlmacen','IdAlmacen','IdTipoBien'],'ALMA.ProductoAlmacen',['IdEmpresa','IdProductoAlmacen','IdAlmacen','IdTipoBien'])
rel('ALMA.PartidaStock',['IdEmpresa','IdUbicacion','IdAlmacen'],'ALMA.UbicacionAlmacen',['IdEmpresa','IdUbicacionAlmacen','IdAlmacen'])
rel('ALMA.PartidaStock',['IdEmpresa','IdLote','IdTipoBien'],'ALMA.Lote',['IdEmpresa','IdLote','IdTipoBien'])
rel('ALMA.PlanConteoCiclico',['IdEmpresa','IdProductoAlmacen','FKIdTipoBien_ALMA'],'ALMA.ProductoAlmacen',['IdEmpresa','IdProductoAlmacen','IdTipoBien'])
rel('ALMA.CierreInventario',['FKIdEmpresa_SIS','IdPartidaStock','FKIdTipoBien_ALMA'],'ALMA.PartidaStock',['IdEmpresa','IdPartidaStock','IdTipoBien'])
add('ALMA.Conteo','IdAlmacen','bigint',False,ref='ALMA.AlmacenCatalogo')
rel('ALMA.Conteo',['IdEmpresa','IdPartidaStock','IdAlmacen','FKIdTipoBien_ALMA'],'ALMA.PartidaStock',['IdEmpresa','IdPartidaStock','IdAlmacen','IdTipoBien'])
rel('ALMA.Conteo',['IdEmpresa','FKIdPeriodoConteo_ALMA','IdAlmacen'],'ALMA.PeriodoConteo',['IdEmpresa','PKIdPeriodoConteo','IdAlmacen'])
rel('ALMA.PeriodoConteo',['IdEmpresa','IdAlmacen','FKIdSucursal_SIS'],'ALMA.AlmacenCatalogo',['IdEmpresa','IdAlmacenCatalogo','IdSucursal'])
for n in ['ALMA.ReservaStock','ALMA.MovimientoInventarioDetalle']:
 add(n,'IdAlmacen','bigint',False,ref='ALMA.AlmacenCatalogo');add(n,'IdTipoBien','int',False,ref='ALMA.TipoBien')
 rel(n,['IdEmpresa','IdPartidaStock','IdAlmacen','IdTipoBien'],'ALMA.PartidaStock',['IdEmpresa','IdPartidaStock','IdAlmacen','IdTipoBien'])
rel('ALMA.ReservaStock',['IdEmpresa','IdDetalleSolicitudSalida','IdAlmacen','IdTipoBien'],'ALMA.DetalleSolicitudSalida',[sc('ALMA.DetalleSolicitudSalida'),'PKIdDetalleSolicitudSalida','IdAlmacen','FKIdTipoBien_ALMA'])
rel('ALMA.DetalleSolicitudSalida',[sc('ALMA.DetalleSolicitudSalida'),'FKIdSolicitudSalida_ALMA','IdAlmacen'],'ALMA.SolicitudSalida',['FKIdEmpresa_SIS','PKIdSolicitudSalida','IdAlmacen'])
rel('ALMA.MovimientoInventarioDetalle',['IdEmpresa','IdDetalleSolicitudSalida','IdAlmacen','IdTipoBien'],'ALMA.DetalleSolicitudSalida',[sc('ALMA.DetalleSolicitudSalida'),'PKIdDetalleSolicitudSalida','IdAlmacen','FKIdTipoBien_ALMA'])
rel('ALMA.MovimientoInventarioDetalle',['IdEmpresa','IdTransferenciaDetalle','IdTipoBien'],'ALMA.TransferenciaDetalle',['IdEmpresa','IdTransferenciaDetalle','IdTipoBien'])
# Complete workflow references absent from the inspected source.
for child,c,parent in [('PBR.WorkflowEstado','FKIdWorkflowTemplate_PBR','PBR.WorkflowTemplate'),('PBR.WorkflowTransicion','FKIdWorkflowTemplate_PBR','PBR.WorkflowTemplate'),('PBR.WorkflowTransicion','FKIdEstadoOrigen_PBR','PBR.WorkflowEstado'),('PBR.WorkflowTransicion','FKIdEstadoDestino_PBR','PBR.WorkflowEstado'),('PBR.AuditoriaCambio','FKIdUsuario_PBR','SIS.Usuario')]:REL.append((child,[c],parent,[pk(parent)],True))
for c in ['FKIdEstadoOrigen_PBR','FKIdEstadoDestino_PBR']:
 rel('PBR.WorkflowTransicion',['IdEmpresa','FKIdWorkflowTemplate_PBR',c],'PBR.WorkflowEstado',['IdEmpresa','FKIdWorkflowTemplate_PBR','PKIdWorkflowEstado'])
# All scoped tables have a direct company FK, including inherited fields without source FK.
for n in COPIED|NEW:
 company=sc(n)
 if company:REL.append((n,[company],'SIS.Empresa',['PKIdEmpresa'],False))
rel('PAG.AplicacionPago',['IdEmpresa','IdPago','IdMoneda'],'PAG.Pago',['IdEmpresa','IdPago','IdMoneda'])
rel('PAG.AplicacionPago',['IdEmpresa','IdCompromiso','IdMoneda'],'PAG.CompromisoPago',['IdEmpresa','IdCompromisoPago','IdMoneda'])
rel('PAG.Pago',['IdEmpresa','IdCuentaBancaria','IdMoneda'],'TES.CuentaBancaria',['FKIdEmpresa_SIS','PKIdCuentaBancaria','IdMoneda'])
rel('TES.MovimientoBancario',['IdEmpresa','IdCuentaBancaria','IdMoneda'],'TES.CuentaBancaria',['FKIdEmpresa_SIS','PKIdCuentaBancaria','IdMoneda'])
# Expand source foreign keys, honoring shared-company constraints; no cascade deletes in proposal.
for n in COPIED:
 for fk in T[n].get('foreign_keys',[]):
  REL.append((n,[c['column'] for c in fk['columns']],fk['referenced_schema']+'.'+fk['referenced_table'],[c['referenced_column'] for c in fk['columns']],True))
RESOLVED=[]; seen=set()
for child,cols,parent,refs,scoped in REL:
 assert child in T and parent in T,(child,parent)
 cols=list(cols);refs=list(refs)
 if scoped and sc(child) and sc(parent) and sc(child) not in cols and sc(parent) not in refs:
  cols=[sc(child)]+cols;refs=[sc(parent)]+refs
 for a,b in zip(cols,refs):
  ca,cb=col(child,a),col(parent,b)
  assert typ(ca)==typ(cb),(child,a,typ(ca),parent,b,typ(cb))
 sig=(child,tuple(cols),parent,tuple(refs))
 if sig in seen:continue
 seen.add(sig)
 # SQL Server requires the exact referenced tuple to have an unfiltered unique key.
 if not any(i['is_unique'] and not i.get('filter_definition') and [c['name'] for c in i['columns'] if not c.get('is_included_column')]==refs for i in T[parent].get('indexes',[])):
  index(parent,refs)
  if parent in BASE:MOD[parent]=1
 name='FK_EXUX_'+child.replace('.','_')+'_'+'_'.join(cols)+'_'+parent.split('.')[-1]
 if len(name)>125:name=name[:108]+'_'+hashlib.sha1(name.encode()).hexdigest()[:12]
 RESOLVED.append(dict(child=child,cols=cols,parent=parent,refs=refs,name=name))
# Declare indexes for the common large-read paths only, not every foreign key.
for n,cols in [('ALMA.MovimientoInventarioDetalle',['IdPartidaStock','IdMovimiento']),('ALMA.ReservaStock',['IdPartidaStock','Estado']),('PAG.CompromisoPago',['IdEmpresa','Estado','Vencimiento']),('TES.MovimientoBancario',['IdCuentaBancaria','FechaValor']),('WF.EventoPendiente',['Estado','FechaPrevista']),('PBR.AuditoriaCambio',['IdEmpresa','IdOperacion','FechaCreacion'])]:index(n,cols,False)
# Validate internal design graph before SQL emission.
for n in COPIED|NEW:
 names=[c['name'].lower() for c in T[n]['columns']];assert len(names)==len(set(names)),n
 assert all(c.get('base_type_name',c['type_name'])!='dmoney' for c in T[n]['columns'])
 for i in T[n].get('indexes',[]):
  for c in i['columns']:col(n,c['name'])
 assert not any(r['parent'].startswith('NOM.') for r in RESOLVED if r['child']==n),n

SETTINGS='SET NOCOUNT ON;\nSET XACT_ABORT ON;\nSET ANSI_NULLS ON;\nSET QUOTED_IDENTIFIER ON;\nSET ANSI_PADDING ON;\nSET ANSI_WARNINGS ON;\nSET ARITHABORT ON;\nSET CONCAT_NULL_YIELDS_NULL ON;\nSET NUMERIC_ROUNDABORT OFF;\n'
GUARD="DECLARE @BaseDestino sysname = N'EmptyProjects';\nIF DB_NAME() <> @BaseDestino THROW 51000, N'Base incorrecta. Seleccione EmptyProjects o edite @BaseDestino para una copia autorizada.', 1;\nIF DB_NAME() IN (N'GestionEmpresarial',N'master',N'model',N'msdb',N'tempdb') THROW 51000, N'Destino protegido: este paquete no se aplica en la base origen.', 1;\nIF @@TRANCOUNT <> 0 THROW 51000, N'Ejecute cada archivo fuera de una transacción previa.', 1;\n"
START=SETTINGS+GUARD+'BEGIN TRY\nBEGIN TRANSACTION;\n'
END="COMMIT TRANSACTION;\nEND TRY\nBEGIN CATCH\n IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;\n THROW;\nEND CATCH;\n"
def execsql(s):return 'EXEC sys.sp_executesql '+lit(s)+';\n'
def normalized(s):return re.sub(r'[\s\[\]\(\)]','',s or '').lower()
def normsql(s):
 for old in [' ','[',']','(',')','\r','\n','\t']:s='REPLACE('+s+','+lit(old)+",N'')"
 return 'LOWER('+s+')'
def header(title,detail):return '/*\nEXUX | Universidad Maya | Propuesta de reestructura SQL Server 2022\n'+title+'\nGenerado a partir de metadatos: EmptyProjects (26 tablas) y GestionEmpresarial (309 tablas).\nSOLO ARCHIVO GENERADO. NO APLICADO. SIN DATOS, SIN USUARIOS, SIN CREDENCIALES.\n'+detail+'\n*/\n\n'
def definition(n):
 t=T[n];lines=[]
 for c in t['columns']:
  if c.get('is_computed'):
   lines.append(q(c['name'])+' AS '+c['computed_definition']+(' PERSISTED' if c.get('is_persisted') else ''));continue
  s=q(c['name'])+' '+typ(c)
  if c.get('collation_name') and c['base_type_name'] in ['varchar','nvarchar','char','nchar','text','ntext']:s+=' COLLATE '+c['collation_name']
  if c.get('is_identity'):s+=' IDENTITY('+c.get('identity_seed','1')+','+c.get('identity_increment','1')+')'
  s+=' NULL' if c['is_nullable'] else ' NOT NULL'
  if c.get('default_definition'):s+=' DEFAULT '+c['default_definition']
  lines.append(s)
 p=next(i for i in t['indexes'] if i['is_primary_key'])
 lines.append('CONSTRAINT '+q(p['name'])+' PRIMARY KEY '+p['type_desc']+' ('+', '.join(q(c['name'])+(' DESC' if c.get('is_descending_key') else ' ASC') for c in p['columns'])+')')
 return 'CREATE TABLE '+fq(n)+' (\n '+',\n '.join(lines)+'\n);'
def column_assert(n,cs):
 expected=[dict(name=c['name'],type=c['base_type_name'],length=c['max_length'],precision=c['precision'],scale=c['scale'],nullable=int(c['is_nullable']),identity=int(c['is_identity']),computed=int(c.get('is_computed',False))) for c in cs]
 # timestamp/rowversion nullable reported by SQL Server is consistent with metadata.
 js=json.dumps(expected,ensure_ascii=False,separators=(',',':'))
 return f"IF EXISTS (\n SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]\n FROM OPENJSON({lit(js)}) WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)\n EXCEPT\n SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)\n FROM sys.columns c WHERE c.object_id=OBJECT_ID({lit(n)},N'U')\n) THROW 51001,{lit('Estructura incompatible: '+n+'. No se modifica ni sustituye automáticamente.')},1;\n"
def defaults_assert(n,cs):
 result=''
 for c in cs:
  if c.get('default_definition'):
   result+=f"IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.default_constraints d ON d.object_id=c.default_object_id WHERE c.object_id=OBJECT_ID({lit(n)}) AND c.name={lit(c['name'])} AND {normsql('d.definition')}={lit(normalized(c['default_definition']))}) THROW 51002,{lit('DEFAULT incompatible: '+n+'.'+c['name'])},1;\n"
  if c.get('is_computed'):
   result+=f"IF NOT EXISTS (SELECT 1 FROM sys.computed_columns c WHERE c.object_id=OBJECT_ID({lit(n)}) AND c.name={lit(c['name'])} AND c.is_persisted={int(c.get('is_persisted',False))} AND {normsql('c.definition')}={lit(normalized(c['computed_definition']))}) THROW 51002,{lit('Columna calculada incompatible: '+n+'.'+c['name'])},1;\n"
 return result

def index_sql(n,i):
 keys=[c for c in i['columns'] if not c.get('is_included_column')];includes=[c for c in i['columns'] if c.get('is_included_column')]
 sql=''
 if not i['is_primary_key']:
  ddl='CREATE '+('UNIQUE ' if i['is_unique'] else '')+i['type_desc']+' INDEX '+q(i['name'])+' ON '+fq(n)+' ('+', '.join(q(c['name'])+(' DESC' if c.get('is_descending_key') else ' ASC') for c in keys)+')'
  if includes:ddl+=' INCLUDE ('+', '.join(q(c['name']) for c in includes)+')'
  if i.get('filter_definition'):ddl+=' WHERE '+i['filter_definition']
  sql+=f"IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID({lit(n)}) AND name={lit(i['name'])})\n"+execsql(ddl+';')
 expkeys=json.dumps([dict(name=c['name'],ordinal=c['key_ordinal'],descending=int(c.get('is_descending_key',False)),included=int(c.get('is_included_column',False))) for c in i['columns']],separators=(',',':'))
 sql+=f"IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID({lit(n)}) AND name={lit(i['name'])} AND is_unique={int(i['is_unique'])} AND is_primary_key={int(i['is_primary_key'])} AND type_desc={lit(i['type_desc'])} AND is_disabled=0 AND {normsql('ISNULL(filter_definition,N\'\')')}={lit(normalized(i.get('filter_definition')))}) THROW 51003,{lit('Índice incompatible: '+n+'.'+i['name'])},1;\n"
 sql+=f"IF EXISTS(SELECT name,ordinal,descending,included FROM OPENJSON({lit(expkeys)}) WITH(name sysname,ordinal int,descending int,included int) EXCEPT SELECT c.name,ic.key_ordinal,CONVERT(int,ic.is_descending_key),CONVERT(int,ic.is_included_column) FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id WHERE i.object_id=OBJECT_ID({lit(n)}) AND i.name={lit(i['name'])}) THROW 51003,{lit('Columnas de índice incompatibles: '+n+'.'+i['name'])},1;\n"
 sql+=f"IF (SELECT COUNT(*) FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.object_id=OBJECT_ID({lit(n)}) AND i.name={lit(i['name'])})<>{len(i['columns'])} THROW 51003,{lit('Número de columnas de índice incompatible: '+n+'.'+i['name'])},1;\n"
 return sql

def check_sql(n,ck):
 result=f"IF OBJECT_ID({lit(T[n]['schema']+'.'+ck['name'])},N'C') IS NULL\n"+execsql('ALTER TABLE '+fq(n)+' WITH CHECK ADD CONSTRAINT '+q(ck['name'])+' CHECK ('+ck['definition']+');')
 return result+f"IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID({lit(n)}) AND name={lit(ck['name'])} AND is_disabled=0 AND is_not_trusted=0 AND {normsql('definition')}={lit(normalized(ck['definition']))}) THROW 51004,{lit('CHECK incompatible: '+n+'.'+ck['name'])},1;\n"

def fksql(r):
 n=r['child'];target=r['parent'];name=r['name'];cols=r['cols'];refs=r['refs']
 ddl='ALTER TABLE '+fq(n)+' WITH CHECK ADD CONSTRAINT '+q(name)+' FOREIGN KEY ('+', '.join(map(q,cols))+') REFERENCES '+fq(target)+' ('+', '.join(map(q,refs))+') ON DELETE NO ACTION ON UPDATE NO ACTION;'
 sql=f"IF OBJECT_ID({lit(T[n]['schema']+'.'+name)},N'F') IS NULL\n"+execsql(ddl)
 expected=json.dumps([dict(ordinal=j+1,parent=a,referenced=b) for j,(a,b) in enumerate(zip(cols,refs))],separators=(',',':'))
 sql+=f"IF NOT EXISTS(SELECT 1 FROM sys.foreign_keys WHERE parent_object_id=OBJECT_ID({lit(n)}) AND name={lit(name)} AND referenced_object_id=OBJECT_ID({lit(target)}) AND delete_referential_action=0 AND update_referential_action=0 AND is_disabled=0 AND is_not_trusted=0) THROW 51005,{lit('FK incompatible: '+name)},1;\n"
 sql+=f"IF EXISTS(SELECT ordinal,parent,referenced FROM OPENJSON({lit(expected)}) WITH(ordinal int,parent sysname,referenced sysname) EXCEPT SELECT fc.constraint_column_id,pc.name,rc.name FROM sys.foreign_key_columns fc JOIN sys.foreign_keys fk ON fk.object_id=fc.constraint_object_id JOIN sys.columns pc ON pc.object_id=fc.parent_object_id AND pc.column_id=fc.parent_column_id JOIN sys.columns rc ON rc.object_id=fc.referenced_object_id AND rc.column_id=fc.referenced_column_id WHERE fk.parent_object_id=OBJECT_ID({lit(n)}) AND fk.name={lit(name)}) THROW 51005,{lit('Columnas FK incompatibles: '+name)},1;\n"
 sql+=f"IF (SELECT COUNT(*) FROM sys.foreign_key_columns WHERE constraint_object_id=OBJECT_ID({lit(T[n]['schema']+'.'+name)})) <> {len(cols)} THROW 51005,{lit('Número de columnas FK incompatible: '+name)},1;\n"
 return sql

# Generate simple baseline preconditions; no source database needs to be connected at apply time.
def prerequisite_base():
 return ''.join(column_assert(n,BASE[n]['columns']) for n in ['SIS.Empresa','SIS.Sucursal','SIS.Usuario','dbo.AspNetRoles','SIS.Moneda'])
for mod,label in MODULES.items():
 owned=sorted(n for n,m in MOD.items() if m==mod and (n not in BASE or ADDED.get(n) or len(T[n]['indexes'])!=len(BASE[n]['indexes'])))
 folder=OUT/f'{mod:02}_{label}';folder.mkdir(exist_ok=True)
 deps=sorted({MOD.get(r['parent'],1) for r in RESOLVED if MOD.get(r['child'])==mod and MOD.get(r['parent'],1)!=mod})
 doc='FASE A: tablas, columnas, PK, índices y CHECK. No crea relaciones a otros módulos.\nFASE B: ejecutar 02_Relaciones.sql después de todas las FASE A.\nDependencias para cerrar relaciones: '+', '.join(f'{d:02} {MODULES[d]}' for d in deps)+'.\nSe conservan nombres heredados; el detalle de reestructura se enumera debajo.\nSin cargas de catálogos: requerirán preparación funcional posterior.'
 text=header(f'MÓDULO {mod:02}: {label}',doc)+START+prerequisite_base()
 for schema in sorted({T[n]['schema'] for n in owned}):text+=f"IF SCHEMA_ID({lit(schema)}) IS NULL\n"+execsql('CREATE SCHEMA '+q(schema)+' AUTHORIZATION [dbo];')
 for n in owned:
  text+='\n-- '+n+' | '+T[n].get('origin','EmptyProjects: existente')+'\n'
  for obj,field,reason in CHANGES:
   if obj==n:text+='-- CAMBIO '+field+': '+reason+'\n'
  if n in BASE:
   # Only additive changes; never rewrite security tables or data.
   for cname in ADDED.get(n,[]):
    c=col(n,cname);ddl='ALTER TABLE '+fq(n)+' ADD '+q(cname)+' '+typ(c)+(' NULL' if c['is_nullable'] else ' NOT NULL')
    if c.get('default_definition'):ddl+=' DEFAULT '+c['default_definition']
    text+=f"IF COL_LENGTH({lit(n)},{lit(cname)}) IS NULL\n"+execsql(ddl+';')
   text+=column_assert(n,T[n]['columns'])
   baseidx={i['name'] for i in BASE[n]['indexes']}
   for i in T[n]['indexes']:
    if i['name'] not in baseidx:text+=index_sql(n,i)
  else:
   text+=f"IF OBJECT_ID({lit(n)},N'U') IS NULL\n"+execsql(definition(n))
   text+=column_assert(n,T[n]['columns'])+defaults_assert(n,T[n]['columns'])
   for i in T[n]['indexes']:text+=index_sql(n,i)
   for ck in T[n].get('checks',[]):text+=check_sql(n,ck)
 text+=END+f"PRINT {lit('FASE A completa: '+label+'. Relaciones pendientes en 02_Relaciones.sql.')};\n"
 (folder/'01_Estructura.sql').write_text(text,encoding='utf-8-sig')
 relations=[r for r in RESOLVED if MOD.get(r['child'])==mod]
 text=header(f'MÓDULO {mod:02}: {label} / Relaciones','FASE B. Ejecutar tras completar FASE A de todos los módulos y antes de cargar datos.\nTransacción propia; no ejecuta ni importa objetos de GestionEmpresarial.\nLas FK se validan WITH CHECK y nunca se deshabilitan.')+START
 for n in sorted({r['child'] for r in relations}|{r['parent'] for r in relations}):text+=column_assert(n,T[n]['columns'])
 for r in relations:text+='\n-- '+r['child']+' -> '+r['parent']+'\n'+fksql(r)
 text+=END+f"PRINT {lit('FASE B completa: '+label)};\n"
 (folder/'02_Relaciones.sql').write_text(text,encoding='utf-8-sig')

# Offline model artifact used for graph validation, not delivered.
(WORK/'sql_model.json').write_text(json.dumps(dict(tables=T,modules=MOD,new=sorted(NEW),copied=sorted(COPIED),relations=RESOLVED,changes=CHANGES),ensure_ascii=False,indent=2),encoding='utf8')
(WORK/'sql_ddl_offline.sql').write_text('\nGO\n'.join(definition(n) for n in sorted(COPIED|NEW)),encoding='utf8')
print(json.dumps({'new_erd_tables':len(NEW),'inherited_tables':len(COPIED),'relationships':len(RESOLVED),'modules':len(MODULES),'sql_files':len(list(OUT.rglob('*.sql')))},ensure_ascii=False))
# FASE C: explicit database controls, not source procedures or application code.
ledger_view=r'''CREATE OR ALTER VIEW [ALMA].[vExistenciasPorAlmacen]
AS
WITH Mov AS (
 SELECT d.IdEmpresa,d.IdPartidaStock,SUM(d.Cantidad) Existencia,SUM(d.ImporteValoracion) ValorInventario
 FROM ALMA.MovimientoInventarioDetalle d
 JOIN ALMA.MovimientoInventario m ON m.IdMovimientoInventario=d.IdMovimiento AND m.IdEmpresa=d.IdEmpresa
 WHERE m.Estado='APLICADO' GROUP BY d.IdEmpresa,d.IdPartidaStock
), Res AS (
 SELECT IdEmpresa,IdPartidaStock,SUM(Cantidad) Reservado FROM ALMA.ReservaStock
 WHERE Estado='ACTIVA' GROUP BY IdEmpresa,IdPartidaStock
)
SELECT p.IdEmpresa,p.IdAlmacen,p.IdPartidaStock,p.IdProductoAlmacen,p.IdTipoBien,p.IdUbicacion,p.IdLote,p.Condicion,
 ISNULL(m.Existencia,0) Existencia,ISNULL(r.Reservado,0) Reservado,
 ISNULL(m.Existencia,0)-ISNULL(r.Reservado,0) Disponible,ISNULL(m.ValorInventario,0) ValorInventario
FROM ALMA.PartidaStock p LEFT JOIN Mov m ON m.IdEmpresa=p.IdEmpresa AND m.IdPartidaStock=p.IdPartidaStock
LEFT JOIN Res r ON r.IdEmpresa=p.IdEmpresa AND r.IdPartidaStock=p.IdPartidaStock;'''
ledger_header=r'''CREATE OR ALTER TRIGGER [ALMA].[TR_EXUX_MovimientoInmutable]
ON [ALMA].[MovimientoInventario] AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM deleted WHERE Estado='APLICADO')
  THROW 51100,N'Un movimiento aplicado es inmutable: registrar reversa, no editar ni eliminar.',1;
 IF EXISTS(SELECT 1 FROM inserted i WHERE i.Estado='APLICADO' AND NOT EXISTS(SELECT 1 FROM ALMA.MovimientoInventarioDetalle d WHERE d.IdMovimiento=i.IdMovimientoInventario))
  THROW 51101,N'No se puede aplicar un movimiento sin partidas.',1;
 IF EXISTS(SELECT 1 FROM inserted i JOIN ALMA.MovimientoInventarioDetalle d ON d.IdMovimiento=i.IdMovimientoInventario
   WHERE i.Estado='APLICADO' AND ((i.Tipo IN ('ENTRADA','SALDO_INICIAL') AND d.Cantidad<=0) OR (i.Tipo='SALIDA' AND d.Cantidad>=0)))
  THROW 51102,N'El signo de cantidad no corresponde a la entrada o salida.',1;
 IF EXISTS(SELECT 1 FROM inserted i JOIN ALMA.MovimientoInventario m ON m.IdMovimientoInventario=i.IdMovimientoReversa
   WHERE i.Estado='APLICADO' AND i.Tipo='REVERSA' AND m.Estado<>'APLICADO')
  THROW 51103,N'Solo se puede revertir un movimiento aplicado.',1;
 IF EXISTS(
  SELECT i.IdMovimientoInventario,x.IdPartidaStock FROM inserted i
  CROSS APPLY (
   SELECT d.IdPartidaStock,d.Cantidad,d.ImporteValoracion FROM ALMA.MovimientoInventarioDetalle d WHERE d.IdMovimiento=i.IdMovimientoInventario
   UNION ALL
   SELECT d.IdPartidaStock,d.Cantidad,d.ImporteValoracion FROM ALMA.MovimientoInventarioDetalle d WHERE d.IdMovimiento=i.IdMovimientoReversa
  ) x WHERE i.Estado='APLICADO' AND i.Tipo='REVERSA'
  GROUP BY i.IdMovimientoInventario,x.IdPartidaStock HAVING SUM(x.Cantidad)<>0 OR SUM(x.ImporteValoracion)<>0
 ) THROW 51104,N'La reversa debe compensar cantidades y valoración del original por partida.',1;
 IF EXISTS(SELECT 1 FROM inserted i JOIN ALMA.MovimientoInventarioDetalle d ON d.IdMovimiento=i.IdMovimientoInventario
   WHERE i.Estado='APLICADO' AND i.Tipo='TRANSFERENCIA' AND d.IdTransferenciaDetalle IS NULL)
  THROW 51105,N'Una transferencia necesita origen documental en todas sus partidas.',1;
 IF EXISTS(SELECT i.IdMovimientoInventario,d.IdTransferenciaDetalle FROM inserted i
   JOIN ALMA.MovimientoInventarioDetalle d ON d.IdMovimiento=i.IdMovimientoInventario
   WHERE i.Estado='APLICADO' AND i.Tipo='TRANSFERENCIA'
   GROUP BY i.IdMovimientoInventario,d.IdTransferenciaDetalle HAVING SUM(d.Cantidad)<>0 OR SUM(d.ImporteValoracion)<>0 OR COUNT(DISTINCT d.IdAlmacen)<2)
  THROW 51106,N'La transferencia debe compensar cantidad y valor entre al menos dos almacenes.',1;
END;'''
ledger_detail=r'''CREATE OR ALTER TRIGGER [ALMA].[TR_EXUX_DetalleMovimientoInmutable]
ON [ALMA].[MovimientoInventarioDetalle] AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted i JOIN ALMA.MovimientoInventario m WITH (UPDLOCK,HOLDLOCK) ON m.IdMovimientoInventario=i.IdMovimiento WHERE m.Estado='APLICADO')
 OR EXISTS(SELECT 1 FROM deleted d JOIN ALMA.MovimientoInventario m WITH (UPDLOCK,HOLDLOCK) ON m.IdMovimientoInventario=d.IdMovimiento WHERE m.Estado='APLICADO')
  THROW 51107,N'Las partidas de un movimiento aplicado son inmutables. Use una reversa.',1;
END;'''
account_header=r'''CREATE OR ALTER TRIGGER [CONTA].[TR_EXUX_PolizaAutorizada]
ON [CONTA].[Poliza] AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM deleted WHERE Autorizado=1)
  THROW 51200,N'Una póliza autorizada es inmutable. Registre una póliza de reversa.',1;
 IF EXISTS(SELECT i.PKIdPoliza FROM inserted i LEFT JOIN CONTA.PolizaDetalle d ON d.FKIdPoliza_CONTA=i.PKIdPoliza AND d.Activo=1
   WHERE i.Autorizado=1 GROUP BY i.PKIdPoliza
   HAVING COUNT(d.PKIdPolizaDetalle)<2 OR SUM(ISNULL(d.ImporteDebe,0))<>SUM(ISNULL(d.ImporteHaber,0)) OR SUM(ISNULL(d.ImporteDebe,0))<=0)
  THROW 51201,N'Una póliza autorizada necesita al menos dos partidas, debe y haber iguales y monto positivo.',1;
END;'''
account_detail=r'''CREATE OR ALTER TRIGGER [CONTA].[TR_EXUX_PolizaDetalleAutorizada]
ON [CONTA].[PolizaDetalle] AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted i JOIN CONTA.Poliza p WITH (UPDLOCK,HOLDLOCK) ON p.PKIdPoliza=i.FKIdPoliza_CONTA WHERE p.Autorizado=1)
 OR EXISTS(SELECT 1 FROM deleted d JOIN CONTA.Poliza p WITH (UPDLOCK,HOLDLOCK) ON p.PKIdPoliza=d.FKIdPoliza_CONTA WHERE p.Autorizado=1)
  THROW 51202,N'No es posible modificar las partidas de una póliza autorizada.',1;
END;'''
controls={4:[ledger_view,ledger_header,ledger_detail],2:[account_header,account_detail]}
for mod,stmts in controls.items():
 label=MODULES[mod]
 text=header(label+' / Controles de persistencia','FASE C, después de todas las estructuras y relaciones.\nCREATE OR ALTER permite revisar y volver a generar las definiciones propuestas.\nLa aplicación debe crear cabecera BORRADOR, agregar detalle y aplicar/autorizar al final.\nNo se importan los procedimientos de la aplicación antigua.')+START
 for stmt in stmts:text+=execsql(stmt)+'\n'
 text+=END
 (OUT/f'{mod:02}_{label}'/'03_Controles.sql').write_text(text,encoding='utf-8-sig')

# SQL-only navigation, plan and explicit limits; no automatic runner.
readme='''DESTINO Y ALCANCE
- Base destino de referencia: EmptyProjects existente, conservando su seguridad y organización.
- Complemento de estructura obtenido de GestionEmpresarial; no se conecta a esa base al ejecutar estos archivos.
- No se crea otra base, no se copian filas, no se asignan usuarios, no se cargan credenciales ni contraseñas.
- El proyecto anterior necesita adaptar sus modelos y servicios: esto es una REESTRUCTURA, no una migración compatible del código actual.
- No se crean ni amplían tablas RH. EmptyProjects ya contiene NOM.Persona y NOM.PersonaArea: permanecen intactas
  para conservar seguridad heredada. Las NUEVAS referencias de negocio apuntan a SIS.ResponsableOperativo.
- No se importan funciones, vistas, triggers ni procedimientos heredados de GestionEmpresarial.
  Sus automatismos quedarían sujetos a la arquitectura nueva; solo se incluyen los controles explícitos de FASE C.
- Las 128 entidades del ERD están trazadas en 98_Trazabilidad_ERD.sql. 'Baja' se materializa como ALMA.Bajas.

ORDEN MANUAL (estos comentarios NO ejecutan otros archivos)
1. Revisar 00_Leer_Primero.sql; su parte ejecutable solo consulta metadatos.
2. FASE A: ejecutar 01_Estructura.sql de las carpetas 01 a 15, en orden numérico.
3. FASE B: ejecutar 02_Relaciones.sql de las carpetas 01 a 15; antes deben existir TODAS las estructuras.
4. FASE C: ejecutar 02_Polizas_Contabilidad/03_Controles.sql y 04_Almacen/03_Controles.sql.
5. Ejecutar 99_Verificar_Estructura.sql. Es comprobación de metadatos; no prueba funcional ni carga de datos.
Los módulos son archivos separados, pero NO todos son instalables aisladamente: las cabeceras enumeran dependencias.
Las relaciones se dejan para FASE B porque existen ciclos funcionales entre compras, almacén, presupuesto y contabilidad.
Cada archivo tiene transacción y revierte su propio trabajo si falla; la totalidad del paquete NO es una sola transacción.

REESTRUCTURA MULTI ALMACÉN
- ALMA.Almacen conserva el significado de entrada histórica, NO se usa como catálogo de almacenes físicos.
- ALMA.AlmacenCatalogo distingue almacenes FISICO y TRANSITO por empresa y sucursal.
- ProductoAlmacen, UbicacionAlmacen, Lote y PartidaStock separan producto, ubicación, lote y condición.
- Las claves compuestas validan empresa, almacén y producto entre las entidades relacionadas.
- PlanConteoCiclico deja la unicidad global por tipo de bien y la cambia a producto por almacén.
- CierreInventario se identifica por partida, ejercicio y mes. No se suma al libro de movimientos.
- La existencia de vExistenciasPorAlmacen sale SOLO de movimientos aplicados; reserva activa reduce disponible.
- El traslado normal ocurre dentro de una empresa. Operaciones entre empresas requieren otro flujo financiero.
- Crear primero todas las partidas en BORRADOR y después aplicar la cabecera. Los aplicados son inmutables.
- No se infiere ubicación para saldos antiguos. La carga de apertura exige clasificación y conciliación previas.

PRECISIONES Y MONEDA
- Se conserva la precisión de GestionEmpresarial: dmoney se expresa como decimal(20,4), sin alias dependiente.
- Presupuesto proyectado/autorizado y reservas nuevas usan decimal(18,2), coherente con sus meses existentes.
- Stock y conteos nuevos usan decimal(20,4); OrdenCompraDetalle mantiene decimal(18,4) para cantidad.
- Tasas/porcentajes son parámetros con 6 decimales; no se siembran valores fiscales ni reglas de redondeo.
- La nueva IdMoneda de CuentaBancaria necesita correspondencia aprobada con el catálogo anterior TipoMoneda.
- Pago y compromiso de una aplicación deben tener la misma moneda. No se implementa conversión implícita.

LO QUE REQUIERE LÓGICA DE NEGOCIO POSTERIOR (NO AFIRMAR OPERACIÓN COMPLETA POR TENER TABLAS)
- Reservar/consumir stock y aplicar movimientos con bloqueo transaccional por partida, evitando saldo negativo.
- Validar cantidades acumuladas pedidas, enviadas, recibidas y facturadas; impedir sobre-recepción y sobre-facturación.
- En transferencias, validar almacén TRANSITO, rutas de salida/recepción y cantidades pendientes antes de aplicar.
- Evitar sobrepago y sobreaplicación de notas; validar mismo beneficiario y documentos admitidos.
- Sumar comprobaciones de caja y viáticos bajo bloqueo del comprobante para impedir doble aplicación entre módulos.
- Autorizar presupuesto con disponibilidad real, conciliando reservas y afectaciones existentes sin duplicar descuentos.
- Aplicar segregación de funciones, decisiones de workflow y autorización por almacén desde la API.
- Integrar SAT/PAC, bancos, OCR y notificaciones sin almacenar secretos directamente en estas tablas.
- Cargar catálogos funcionales, tipos, estados, moneda y reglas aprobadas antes de iniciar operaciones.
- Validar concurrencia, reversas, reintentos y migración en ambiente de prueba cuando se autorice ejecutar.

REPETICIÓN Y RECUPERACIÓN
- La estructura existente se verifica por columnas, tipo, longitud, precisión, nulabilidad y claves.
- Si existe una definición incompatible el archivo falla; no borra ni convierte tablas automáticamente.
- Un archivo fallido revierte su propia transacción. No se suministra DROP masivo como supuesto rollback.
- Para deshacer todo tras cargar datos se requiere recuperación de respaldo o migración inversa revisada.
- Para otra copia de EmptyProjects, cambiar @BaseDestino en cada archivo tras revisar el destino.
'''
summary=f'CONTENIDO: {len(MODULES)} módulos; {len(COPIED)} tablas tomadas de GestionEmpresarial; {len(NEW)} tablas nuevas ERD; {len(RESOLVED)} relaciones verificables.\n'
summary+='\n'.join(f'{i:02} {label}: '+str(len([n for n,m in MOD.items() if m==i]))+' entidades propias/reutilizadas.' for i,label in MODULES.items())
text=header('00 / Instrucciones y prevalidación de solo lectura',readme+'\n'+summary)+SETTINGS+GUARD
text+="IF TRY_CONVERT(int,SERVERPROPERTY('ProductMajorVersion')) < 16 THROW 51000,N'Este paquete está preparado para SQL Server 2022 o posterior.',1;\nIF (SELECT compatibility_level FROM sys.databases WHERE name=DB_NAME()) < 130 THROW 51000,N'OPENJSON requiere compatibilidad 130 o superior.',1;\n"
text+=prerequisite_base()+"SELECT DB_NAME() AS BaseSeleccionada,N'Prevalidación de esquema base; ningún cambio ejecutado por este archivo' AS Resultado;\n"
(OUT/'00_Leer_Primero.sql').write_text(text,encoding='utf-8-sig')
# Exact ERD to physical name mapping, including inherited columns changed.
import ast
entities=set()
for node in ast.walk(ast.parse((WORK/'build_erd_pdf.py').read_text(encoding='utf-8-sig'))):
 if isinstance(node,ast.Call) and isinstance(node.func,ast.Name) and node.func.id=='graph' and len(node.args)>2 and isinstance(node.args[2],ast.Constant):entities.update(x.split(':')[0] for x in node.args[2].value.split())
maplines=[]
for entity in sorted(entities):
 physical=['ALMA.Bajas'] if entity=='Baja' else [n for n in T if n.split('.')[1]==entity]
 if entity=='Notificacion':physical=['SIS.Notificacion']
 assert physical,(entity,'Not represented')
 maplines.append(entity+' -> '+', '.join(physical))
trace='ENTIDADES DEL ERD ('+str(len(entities))+')\n'+'\n'.join(maplines)+'\n\nCAMBIOS EXPLÍCITOS RESPECTO DE LOS ORÍGENES\n'+'\n'.join(n+'.'+c+' -> '+why for n,c,why in CHANGES)
trace+='\n\nCambios adicionales: las cabeceras identifican OperacionNegocio; Factura agrega proveedor, vencimiento y CFDI;\nDocumento exige empresa; responsables no dependen de RH; las FK y UQ compuestas protegen pertenencia.\n'
(OUT/'98_Trazabilidad_ERD.sql').write_text(header('98 / Mapa ERD y reestructura',trace)+'-- Archivo de comentarios; no contiene instrucciones de modificación.\n',encoding='utf-8-sig')
# Read-only postverification of all newly created columns, keys and FK status.
text=header('99 / Verificación posterior de solo lectura','Ejecutar manualmente tras completar fases A, B y C. No genera ni modifica objetos.\nVerifica el contrato de columnas y presencia/estado de PK, CHECK y FK.\nLa comprobación completa de definición de índices y FK también está incluida en cada script modular.')+SETTINGS+GUARD
for n in sorted(COPIED|NEW|set(ADDED)):
 if n in ADDED and not ADDED[n]:continue
 text+=column_assert(n,T[n]['columns'])
for r in RESOLVED:
 text+=f"IF NOT EXISTS(SELECT 1 FROM sys.foreign_keys WHERE name={lit(r['name'])} AND parent_object_id=OBJECT_ID({lit(r['child'])}) AND referenced_object_id=OBJECT_ID({lit(r['parent'])}) AND is_disabled=0 AND is_not_trusted=0) THROW 51300,{lit('Relación ausente o no validada: '+r['name'])},1;\n"
for n in sorted(COPIED|NEW):
 text+=f"IF NOT EXISTS(SELECT 1 FROM sys.key_constraints WHERE parent_object_id=OBJECT_ID({lit(n)}) AND type='PK') THROW 51301,{lit('Falta PK: '+n)},1;\n"
 for ck in T[n].get('checks',[]):text+=f"IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID({lit(n)}) AND name={lit(ck['name'])} AND is_disabled=0 AND is_not_trusted=0) THROW 51302,{lit('Falta CHECK validado: '+n+'.'+ck['name'])},1;\n"
for name,kind in [('ALMA.vExistenciasPorAlmacen','V'),('ALMA.TR_EXUX_MovimientoInmutable','TR'),('ALMA.TR_EXUX_DetalleMovimientoInmutable','TR'),('CONTA.TR_EXUX_PolizaAutorizada','TR'),('CONTA.TR_EXUX_PolizaDetalleAutorizada','TR')]:text+=f"IF OBJECT_ID({lit(name)},{lit(kind)}) IS NULL THROW 51303,{lit('Falta FASE C: '+name)},1;\n"
text+="SELECT DB_NAME() BaseSeleccionada,N'Estructura verificada. Las pruebas funcionales requieren ejecución autorizada por separado.' Resultado;\n"
(OUT/'99_Verificar_Estructura.sql').write_text(text,encoding='utf-8-sig')
# Pure schema fixture for offline DacFx resolution (includes existing EmptyProjects tables ONLY in this local fixture).
raw=['CREATE SCHEMA '+q(s)+';' for s in sorted({t['schema'] for t in T.values()}-{'dbo'})]
raw += [definition(n) for n in sorted(T)]
for n in sorted(T):
 for i in T[n]['indexes']:
  if i['is_primary_key']:continue
  m=re.search(r"EXEC sys.sp_executesql N'((?:[^']|'')*)';",index_sql(n,i),re.S)
  if m:raw.append(m[1].replace("''","'"))
 for ck in T[n].get('checks',[]):raw.append('ALTER TABLE '+fq(n)+' ADD CONSTRAINT '+q(ck['name'])+' CHECK ('+ck['definition']+');')
for r in RESOLVED:
 m=re.search(r"EXEC sys.sp_executesql N'((?:[^']|'')*)';",fksql(r),re.S);raw.append(m[1].replace("''","'"))
raw += [s.replace('CREATE OR ALTER','CREATE') for stmts in controls.values() for s in stmts]
(WORK/'sql_complete_model_offline.sql').write_text('\nGO\n'.join(raw)+'\nGO\n',encoding='utf-8-sig')
print('Complete package:',len(list(OUT.rglob('*.sql'))),'SQL files; ERD mappings:',len(entities))
